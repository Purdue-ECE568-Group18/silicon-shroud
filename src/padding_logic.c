#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define SERVER_PORT                 6000
#define SERVER_IP                   "0.0.0.0"

#define UDP_MAX_BYTES               1500
#define DMA_BUFFER_WINDOW_BYTES     0x2000
#define DMA_SOURCE_OFFSET_BYTES     0x0000
#define DMA_DEST_OFFSET_BYTES       0x1000

#define DMA_REG_BASE_PHYS_ADDR      0x40400000
#define PAGE_BYTES                  4096

#define AES_BLOCK_BYTES             16
#define DEFAULT_TARGET_TX_BYTES     1500
#define DEFAULT_POLL_DELAY_US       10

/* AXI DMA REGISTER OFFSETS */
#define MM2S_CTRL_OFFSET            0x00
#define MM2S_STAT_OFFSET            0x04
#define MM2S_SA_LWR_OFFSET          0x18
#define MM2S_LEN_OFFSET             0x28

#define S2MM_CTRL_OFFSET            0x30
#define S2MM_STAT_OFFSET            0x34
#define S2MM_DA_LWR_OFFSET          0x48
#define S2MM_LEN_OFFSET             0x58

/* SIMPLE POLLING CHECK USED BY THE EXISTING WORKING CODE */
#define DMA_IDLE_MASK               0x00000002

/* SIMPLE MODES */
#define MODE_DMA                    1
#define MODE_BYPASS                 2

static volatile sig_atomic_t keep_running = 1;

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
    volatile uint8_t *dma_regs;
    unsigned long dma_phys_addr;
    uint8_t *dma_source_ptr;
    uint8_t *dma_dest_ptr;
};

struct server_stats
{
    unsigned long packets_rx;
    unsigned long packets_tx;
    unsigned long packets_dma;
    unsigned long packets_bypass;
    unsigned long packets_padded;
    unsigned long packets_chaffed;
    unsigned long bytes_rx;
    unsigned long bytes_tx;
};

static void handle_signal(int signal_number)
{
    (void)signal_number;
    keep_running = 0;
}

static void print_usage(const char *program_name)
{
    printf("USAGE: %s [OPTIONS]\n", program_name);
    printf("  --mode dma|bypass\n");
    printf("  --no-pad\n");
    printf("  --no-chaff\n");
    printf("  --target-bytes N\n");
    printf("  --align-bytes N\n");
    printf("  --poll-us N\n");
    printf("  --verbose\n");
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

static uint32_t dma_reg_read32(volatile uint8_t *dma_regs_ptr, size_t register_offset)
{
    return *(volatile uint32_t *)(dma_regs_ptr + register_offset);
}

static void dma_reg_write32(volatile uint8_t *dma_regs_ptr, size_t register_offset, uint32_t register_value)
{
    *(volatile uint32_t *)(dma_regs_ptr + register_offset) = register_value;
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

    context_ptr->dma_source_ptr = (uint8_t *)context_ptr->dma_window + DMA_SOURCE_OFFSET_BYTES;
    context_ptr->dma_dest_ptr = (uint8_t *)context_ptr->dma_window + DMA_DEST_OFFSET_BYTES;

    /* MAP AXI DMA REGISTERS */
    context_ptr->devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (context_ptr->devmem_fd < 0)
    {
        perror("OPEN /dev/mem FAILED");
        return -1;
    }

    mapped_regs_base = mmap(NULL,
                            PAGE_BYTES,
                            PROT_READ | PROT_WRITE,
                            MAP_SHARED,
                            context_ptr->devmem_fd,
                            DMA_REG_BASE_PHYS_ADDR & ~(PAGE_BYTES - 1));
    if (mapped_regs_base == MAP_FAILED)
    {
        perror("MMAP /dev/mem FAILED");
        return -1;
    }

    register_page_offset = DMA_REG_BASE_PHYS_ADDR % PAGE_BYTES;
    context_ptr->dma_regs = (volatile uint8_t *)mapped_regs_base + register_page_offset;

    return 0;
}

static void dma_context_cleanup(struct dma_context *context_ptr)
{
    if (context_ptr->dma_window != NULL && context_ptr->dma_window != MAP_FAILED)
    {
        munmap(context_ptr->dma_window, DMA_BUFFER_WINDOW_BYTES);
    }

    if (context_ptr->dma_regs != NULL && context_ptr->dma_regs != MAP_FAILED)
    {
        munmap((void *)(context_ptr->dma_regs - (DMA_REG_BASE_PHYS_ADDR % PAGE_BYTES)), PAGE_BYTES);
    }

    if (context_ptr->udmabuf_fd >= 0)
    {
        close(context_ptr->udmabuf_fd);
    }

    if (context_ptr->devmem_fd >= 0)
    {
        close(context_ptr->devmem_fd);
    }
}

static int dma_run_transfer(struct dma_context *context_ptr, size_t transfer_bytes, unsigned int poll_delay_us)
{
    uint32_t dma_status;
    unsigned long spin_count;

    /* START CHANNELS */
    dma_reg_write32(context_ptr->dma_regs, MM2S_CTRL_OFFSET, 0x00000001);
    dma_reg_write32(context_ptr->dma_regs, S2MM_CTRL_OFFSET, 0x00000001);

    /* PROGRAM ADDRESSES */
    dma_reg_write32(context_ptr->dma_regs, MM2S_SA_LWR_OFFSET, (uint32_t)(context_ptr->dma_phys_addr + DMA_SOURCE_OFFSET_BYTES));
    dma_reg_write32(context_ptr->dma_regs, S2MM_DA_LWR_OFFSET, (uint32_t)(context_ptr->dma_phys_addr + DMA_DEST_OFFSET_BYTES));

    /* LENGTH WRITE TRIGGERS TRANSFER */
    dma_reg_write32(context_ptr->dma_regs, S2MM_LEN_OFFSET, (uint32_t)transfer_bytes);
    dma_reg_write32(context_ptr->dma_regs, MM2S_LEN_OFFSET, (uint32_t)transfer_bytes);

    /* POLL FOR COMPLETION */
    spin_count = 0;
    dma_status = 0;
    while ((dma_status & DMA_IDLE_MASK) == 0)
    {
        dma_status = dma_reg_read32(context_ptr->dma_regs, S2MM_STAT_OFFSET);
        spin_count++;

        if (poll_delay_us != 0)
        {
            usleep(poll_delay_us);
        }

        if (spin_count > 1000000UL)
        {
            fprintf(stderr, "DMA TIMEOUT: S2MM_STAT=0x%08X\n", dma_status);
            return -1;
        }
    }

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

static void print_stats(const struct server_stats *stats_ptr)
{
    printf("RX_PKTS=%lu TX_PKTS=%lu DMA_PKTS=%lu BYPASS_PKTS=%lu PAD_PKTS=%lu CHAFF_PKTS=%lu RX_BYTES=%lu TX_BYTES=%lu\n",
           stats_ptr->packets_rx,
           stats_ptr->packets_tx,
           stats_ptr->packets_dma,
           stats_ptr->packets_bypass,
           stats_ptr->packets_padded,
           stats_ptr->packets_chaffed,
           stats_ptr->bytes_rx,
           stats_ptr->bytes_tx);
}

int main(int argc, char **argv)
{
    struct server_config server_cfg;
    struct dma_context dma_ctx;
    struct server_stats server_stats;
    int socket_fd;
    struct sockaddr_in server_addr;
    struct sockaddr_in client_addr;
    socklen_t client_addr_size;
    ssize_t rx_bytes;
    size_t dma_input_bytes;
    size_t tx_bytes;
    uint8_t socket_rx_buffer[UDP_MAX_BYTES];
    uint8_t socket_tx_buffer[UDP_MAX_BYTES];
    uint32_t chaff_state;

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    if (parse_args(argc, argv, &server_cfg) != 0)
    {
        print_usage(argv[0]);
        return 1;
    }

    memset(&server_stats, 0, sizeof(server_stats));
    chaff_state = 0x12345678;

    if (dma_context_init(&dma_ctx) != 0)
    {
        fprintf(stderr, "DMA INIT FAILED\n");
        return 1;
    }

    socket_fd = socket(PF_INET, SOCK_DGRAM, 0);
    if (socket_fd < 0)
    {
        perror("SOCKET FAILED");
        dma_context_cleanup(&dma_ctx);
        return 1;
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(SERVER_IP);
    server_addr.sin_port = htons(SERVER_PORT);

    if (bind(socket_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0)
    {
        perror("BIND FAILED");
        close(socket_fd);
        dma_context_cleanup(&dma_ctx);
        return 1;
    }

    printf("SHROUD SERVER ONLINE\n");
    printf("MODE=%s PAD=%d CHAFF=%d TARGET=%zu ALIGN=%zu\n",
           (server_cfg.mode == MODE_DMA) ? "DMA" : "BYPASS",
           server_cfg.enable_padding,
           server_cfg.enable_chaff,
           server_cfg.target_tx_bytes,
           server_cfg.align_bytes);

    while (keep_running != 0)
    {
        client_addr_size = sizeof(client_addr);
        rx_bytes = recvfrom(socket_fd,
                            socket_rx_buffer,
                            sizeof(socket_rx_buffer),
                            0,
                            (struct sockaddr *)&client_addr,
                            &client_addr_size);
        if (rx_bytes < 0)
        {
            if (errno == EINTR)
            {
                continue;
            }

            perror("RECVFROM FAILED");
            break;
        }

        if (rx_bytes == 0)
        {
            continue;
        }

        server_stats.packets_rx++;
        server_stats.bytes_rx += (unsigned long)rx_bytes;

        memset(dma_ctx.dma_source_ptr, 0, UDP_MAX_BYTES);
        memset(dma_ctx.dma_dest_ptr, 0, UDP_MAX_BYTES);
        memset(socket_tx_buffer, 0, sizeof(socket_tx_buffer));

        /* RX -> DMA SOURCE */
        memcpy(dma_ctx.dma_source_ptr, socket_rx_buffer, (size_t)rx_bytes);

        /* PADDING BEFORE DMA */
        if (server_cfg.enable_padding != 0)
        {
            dma_input_bytes = align_up_bytes((size_t)rx_bytes, server_cfg.align_bytes);
            if (dma_input_bytes > server_cfg.target_tx_bytes)
            {
                dma_input_bytes = server_cfg.target_tx_bytes;
            }

            if (dma_input_bytes > (size_t)rx_bytes)
            {
                memset(dma_ctx.dma_source_ptr + rx_bytes, 0, dma_input_bytes - (size_t)rx_bytes);
                server_stats.packets_padded++;
            }
        }
        else
        {
            dma_input_bytes = (size_t)rx_bytes;
        }

        if (server_cfg.mode == MODE_DMA)
        {
            if (dma_run_transfer(&dma_ctx, dma_input_bytes, server_cfg.poll_delay_us) != 0)
            {
                fprintf(stderr, "DMA TRANSFER FAILED\n");
                break;
            }

            memcpy(socket_tx_buffer, dma_ctx.dma_dest_ptr, dma_input_bytes);
            server_stats.packets_dma++;
        }
        else
        {
            memcpy(socket_tx_buffer, dma_ctx.dma_source_ptr, dma_input_bytes);
            server_stats.packets_bypass++;
        }

        tx_bytes = dma_input_bytes;

        /* CHAFF AFTER DMA, BEFORE TX */
        if (server_cfg.enable_chaff != 0 && tx_bytes < server_cfg.target_tx_bytes)
        {
            fill_chaff_bytes(socket_tx_buffer, tx_bytes, server_cfg.target_tx_bytes, &chaff_state);
            tx_bytes = server_cfg.target_tx_bytes;
            server_stats.packets_chaffed++;
        }

        if (sendto(socket_fd,
                   socket_tx_buffer,
                   tx_bytes,
                   0,
                   (struct sockaddr *)&client_addr,
                   client_addr_size) < 0)
        {
            perror("SENDTO FAILED");
            break;
        }

        server_stats.packets_tx++;
        server_stats.bytes_tx += (unsigned long)tx_bytes;

        if (server_cfg.verbose != 0)
        {
            printf("RX=%zd DMA_IN=%zu TX=%zu\n", rx_bytes, dma_input_bytes, tx_bytes);
        }
    }

    print_stats(&server_stats);
    close(socket_fd);
    dma_context_cleanup(&dma_ctx);
    return 0;
}
