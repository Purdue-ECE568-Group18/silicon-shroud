#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/time.h>
#include <signal.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10" 

#define MODE_DMA 1
#define MODE_BYPASS 2
#define DEFAULT_TARGET_TX_BYTES 1500
#define DEFAULT_POLL_DELAY_US 10
#define AES_BLOCK_BYTES 16

#define UDP_MAX_BYTES               1500
#define DMA_BUFFER_WINDOW_BYTES     0x4000

// DMA Offsets
#define PAGE_SIZE 4096
#define DMA_REG_BASE_PHYS_ADDR 0x40400000 

#define MM2S_CTRL   0x0
#define MM2S_STAT   0x4
#define MM2S_SA_LWR 0x18
#define MM2S_LEN    0x28

#define S2MM_CTRL   0x30
#define S2MM_STAT   0x34
#define S2MM_DA_LWR 0x48
#define S2MM_LEN    0x58

// Shaping Constants
#define TARGET_BPS 5000000  
#define ADJUST_INTERVAL_PACKETS 101
#define DMA_IDLE_MASK 0x00000002

static volatile int keep_running = 1; // Global flag for clean exit

struct server_config
{
    int mode;
    int enable_padding;
    int enable_chaff;
    size_t target_tx_bytes;
    size_t align_bytes;
    unsigned int poll_delay_us;
    int verbose;
};

struct dma_context
{
    int udmabuf_fd;
    int devmem_fd;
    void *dma_window;
    volatile uint32_t *dma_regs; // Use uint32_t for register access
    unsigned long dma_phys_addr;
    // Arrays for your slot logic
    void *src_buffers[2];
    void *dst_buffers[2];
    uint32_t phys_offsets[2];
};

static void handle_signal(int signal_number)
{
    (void)signal_number;
    keep_running = 0;
}

static size_t align_up_bytes(size_t byte_count, size_t align_bytes)
{
    size_t remainder_bytes;

    if (align_bytes == 0)
    {
        return byte_count;
    }

    remainder_bytes = byte_count % align_bytes;

    if (remainder_bytes == 0)
    {
        return byte_count;
    }

    return byte_count + (align_bytes - remainder_bytes);
}

static void fill_chaff_bytes(uint8_t *buffer_ptr, size_t start_idx, size_t end_idx, uint32_t *lfsr_state_ptr)
{
    size_t idx;
    uint32_t lfsr_state;
    uint32_t lfsr_feedback;

    lfsr_state = *lfsr_state_ptr;

    if (lfsr_state == 0)
    {
        lfsr_state = 0x1ACEB00C;
    }

    for (idx = start_idx; idx < end_idx; idx++)
    {
        lfsr_feedback = ((lfsr_state >> 0) ^ (lfsr_state >> 2) ^ (lfsr_state >> 3) ^ (lfsr_state >> 5)) & 0x1;
        lfsr_state = (lfsr_state >> 1) | (lfsr_feedback << 31);
        buffer_ptr[idx] = (uint8_t)(lfsr_state & 0xFF);
    }

    *lfsr_state_ptr = lfsr_state;
}

static int dma_context_init(struct dma_context *context_ptr)
{
    int phys_addr_fd;
    ssize_t read_length;
    char attr_buffer[128];
    void *mapped_regs_base;
    size_t register_page_offset;

    memset(context_ptr, 0, sizeof(*context_ptr));
    context_ptr->udmabuf_fd = -1;
    context_ptr->devmem_fd = -1;

    /* READ PHYSICAL UDMABUF ADDRESS */
    phys_addr_fd = open("/sys/class/u-dma-buf/udmabuf0/phys_addr", O_RDONLY);
    if (phys_addr_fd < 0)
    {
        perror("OPEN phys_addr FAILED");
        return -1;
    }

    memset(attr_buffer, 0, sizeof(attr_buffer));
    read_length = read(phys_addr_fd, attr_buffer, sizeof(attr_buffer) - 1);
    close(phys_addr_fd);

    if (read_length <= 0)
    {
        perror("READ phys_addr FAILED");
        return -1;
    }

    context_ptr->dma_phys_addr = strtoul(attr_buffer, NULL, 0);

    /* MAP UDMABUF */
    context_ptr->udmabuf_fd = open("/dev/udmabuf0", O_RDWR | O_SYNC);
    if (context_ptr->udmabuf_fd < 0)
    {
        perror("OPEN /dev/udmabuf0 FAILED");
        return -1;
    }

    context_ptr->dma_window = mmap(NULL,
                                   DMA_BUFFER_WINDOW_BYTES,
                                   PROT_READ | PROT_WRITE,
                                   MAP_SHARED,
                                   context_ptr->udmabuf_fd,
                                   0);
    if (context_ptr->dma_window == MAP_FAILED)
    {
        perror("MMAP /dev/udmabuf0 FAILED");
        return -1;
    }

    // Inside dma_context_init...
    context_ptr->src_buffers[0] = (uint8_t *)context_ptr->dma_window + 0x0000;
    context_ptr->src_buffers[1] = (uint8_t *)context_ptr->dma_window + 0x2000;
    context_ptr->dst_buffers[0] = (uint8_t *)context_ptr->dma_window + 0x1000;
    context_ptr->dst_buffers[1] = (uint8_t *)context_ptr->dma_window + 0x3000;

    context_ptr->phys_offsets[0] = 0x0000;
    context_ptr->phys_offsets[1] = 0x2000;
    /* MAP AXI DMA REGISTERS */
    context_ptr->devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (context_ptr->devmem_fd < 0)
    {
        perror("OPEN /dev/mem FAILED");
        return -1;
    }

    mapped_regs_base = mmap(NULL,
                            PAGE_SIZE,
                            PROT_READ | PROT_WRITE,
                            MAP_SHARED,
                            context_ptr->devmem_fd,
                            DMA_REG_BASE_PHYS_ADDR & ~(PAGE_SIZE - 1));
    if (mapped_regs_base == MAP_FAILED)
    {
        perror("MMAP /dev/mem FAILED");
        return -1;
    }

    register_page_offset = DMA_REG_BASE_PHYS_ADDR % PAGE_SIZE;
    context_ptr->dma_regs = (volatile uint32_t *)((uint8_t *)mapped_regs_base + register_page_offset);

    return 0;
}

static int parse_args(int argc, char **argv, struct server_config *config_ptr)
{
    int idx;

    config_ptr->mode = MODE_DMA;
    config_ptr->enable_padding = 1;
    config_ptr->enable_chaff = 1;
    config_ptr->target_tx_bytes = DEFAULT_TARGET_TX_BYTES;
    config_ptr->align_bytes = AES_BLOCK_BYTES;
    config_ptr->poll_delay_us = DEFAULT_POLL_DELAY_US;
    config_ptr->verbose = 0;

    for (idx = 1; idx < argc; idx++)
    {
        if (strcmp(argv[idx], "--mode") == 0)
        {
            if ((idx + 1) >= argc)
            {
                return -1;
            }

            idx++;
            if (strcmp(argv[idx], "dma") == 0)
            {
                config_ptr->mode = MODE_DMA;
            }
            else if (strcmp(argv[idx], "bypass") == 0)
            {
                config_ptr->mode = MODE_BYPASS;
            }
            else
            {
                return -1;
            }
        }
        else if (strcmp(argv[idx], "--no-pad") == 0)
        {
            config_ptr->enable_padding = 0;
        }
        else if (strcmp(argv[idx], "--no-chaff") == 0)
        {
            config_ptr->enable_chaff = 0;
        }
        else if (strcmp(argv[idx], "--target-bytes") == 0)
        {
            if ((idx + 1) >= argc)
            {
                return -1;
            }
            idx++;
            config_ptr->target_tx_bytes = (size_t)strtoul(argv[idx], NULL, 0);
        }
        else if (strcmp(argv[idx], "--align-bytes") == 0)
        {
            if ((idx + 1) >= argc)
            {
                return -1;
            }
            idx++;
            config_ptr->align_bytes = (size_t)strtoul(argv[idx], NULL, 0);
        }
        else if (strcmp(argv[idx], "--poll-us") == 0)
        {
            if ((idx + 1) >= argc)
            {
                return -1;
            }
            idx++;
            config_ptr->poll_delay_us = (unsigned int)strtoul(argv[idx], NULL, 0);
        }
        else if (strcmp(argv[idx], "--verbose") == 0)
        {
            config_ptr->verbose = 1;
        }
        else
        {
            return -1;
        }
    }

    if (config_ptr->target_tx_bytes > UDP_MAX_BYTES)
    {
        fprintf(stderr, "TARGET BYTES MUST BE <= %d\n", UDP_MAX_BYTES);
        return -1;
    }

    if (config_ptr->align_bytes == 0 || config_ptr->align_bytes > config_ptr->target_tx_bytes)
    {
        fprintf(stderr, "ALIGN BYTES MUST BE > 0 AND <= TARGET BYTES\n");
        return -1;
    }

    return 0;
}

int main(int argc, char **argv) {
    struct server_config cfg;
    uint32_t chaff_state = 0x12345678;
    
    // 0. Parse Arguments
    if (parse_args(argc, argv, &cfg) != 0) {
        printf("Usage: ./shroud_server --mode dma --target-bytes 1500\n");
        return 1;
    }

    signal(SIGINT, handle_signal);

    int current_slot = 0;
    struct dma_context dma;
    
    if (dma_context_init(&dma) != 0) {
        fprintf(stderr, "Failed to initialize DMA context\n");
        return 1;
    }

    // 3. Setup Networking
    int sock = socket(PF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in serv_addr, clnt_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); 
    serv_addr.sin_port = htons(PONG_PORT);
    bind(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

    // 4. Shaping Variables
    long current_delay_ns = 2400000;  
    struct timespec sleep_time = {0, current_delay_ns};
    long total_bytes_sent = 0;
    int packet_count = 0;
    struct timeval start_time, end_time, tv;
    gettimeofday(&start_time, NULL);
    tv.tv_sec = 1; 
    tv.tv_usec = 0;
    if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv) < 0) {
        perror("setsockopt failed");
    }
    printf("Silicon Shroud Server Online. Mode: %s | Target: 5 Mbps\n", (cfg.mode == MODE_DMA) ? "DMA" : "BYPASS");

    while (keep_running) {
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        int str_len = recvfrom(sock, (char*)dma.src_buffers[current_slot], BUF_SIZE, 0, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
        if (str_len <= 0) continue;

        // --- STEP A: PADDING ---
        size_t dma_len = str_len;
        if (cfg.enable_padding) {
            dma_len = align_up_bytes(str_len, cfg.align_bytes);
            if (dma_len > cfg.target_tx_bytes) dma_len = cfg.target_tx_bytes;
            // Clear the padding area in the source buffer
            memset((uint8_t*)dma.src_buffers[current_slot] + str_len, 0, dma_len - str_len);
        }

	if (cfg.mode == MODE_DMA) {
            // Use the context struct's registers and offsets
            dma.dma_regs[S2MM_CTRL/4] = 0x1;
            dma.dma_regs[MM2S_CTRL/4] = 0x1;

            dma.dma_regs[MM2S_SA_LWR/4] = (uint32_t)dma.dma_phys_addr + dma.phys_offsets[current_slot];
            dma.dma_regs[S2MM_DA_LWR/4] = (uint32_t)dma.dma_phys_addr + dma.phys_offsets[current_slot] + 0x1000;
            
            dma.dma_regs[S2MM_LEN/4] = (uint32_t)dma_len;
            dma.dma_regs[MM2S_LEN/4] = (uint32_t)dma_len;

            while(!(dma.dma_regs[S2MM_STAT/4] & DMA_IDLE_MASK));
        } else {
            memcpy(dma.dst_buffers[current_slot], dma.src_buffers[current_slot], dma_len);
        }
        // --- STEP C: CHAFFING ---
        size_t final_tx_len = dma_len;
        if (cfg.enable_chaff && dma_len < cfg.target_tx_bytes) {
            fill_chaff_bytes(dma.dst_buffers[current_slot], dma_len, cfg.target_tx_bytes, &chaff_state);
            final_tx_len = cfg.target_tx_bytes;
        }

        // --- STEP D: SEND & SHAPE ---
        sendto(sock, (char*)dma.dst_buffers[current_slot], final_tx_len, 0, (struct sockaddr*)&clnt_addr, clnt_addr_size);

        total_bytes_sent += final_tx_len;
        if (++packet_count >= ADJUST_INTERVAL_PACKETS) {
            gettimeofday(&end_time, NULL);
            double seconds = (end_time.tv_sec - start_time.tv_sec) + (end_time.tv_usec - start_time.tv_usec) / 1000000.0;
            double actual_bps = (total_bytes_sent * 8.0) / seconds;

            if (actual_bps > TARGET_BPS) current_delay_ns += 10000;
            else if (actual_bps < TARGET_BPS && current_delay_ns > 10000) current_delay_ns -= 10000;
            
            sleep_time.tv_nsec = current_delay_ns;
            if (cfg.verbose) printf("Rate: %.2f Mbps | Delay: %ld ns\n", actual_bps / 1000000.0, current_delay_ns);

            packet_count = 0; total_bytes_sent = 0;
            gettimeofday(&start_time, NULL);
        }

        current_slot = !current_slot;
        nanosleep(&sleep_time, NULL);
    }
    
    // Clean up
    if (dma.dma_window != NULL) {
        munmap(dma.dma_window, DMA_BUFFER_WINDOW_BYTES);
    }
    // Note: To properly unmap dma_regs, you'd need to store the mapped_regs_base 
    // inside the struct. For a quick fix to pass compilation:
    close(dma.udmabuf_fd);
    close(dma.devmem_fd);
    close(sock);
    return 0;
}
