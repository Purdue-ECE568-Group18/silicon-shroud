#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/time.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10" 

// DMA Offsets
#define PAGE_SIZE 4096
#define PHYS_ADDR 0x40400000 
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

int main() {
    int fd, fd2, fd3;
    void *buf, *buf2, *map_base;
    volatile unsigned int *virt_addr;
    unsigned long phys_addr;
    unsigned char attr[1024];

    // 1. Setup DMA Memory (udmabuf)
    if ((fd3 = open("/sys/class/u-dma-buf/udmabuf0/phys_addr", O_RDONLY)) != -1) {
        read(fd3, attr, 1024);
        sscanf(attr, "%lx", &phys_addr);
        close(fd3);
    }
    fd = open("/dev/udmabuf0", O_RDWR | O_SYNC);
    // Map 0x4000 (16KB) to fit two 4KB "Ping-Pong" slots (each with a 1.5KB src and 1.5KB dst)
    buf = mmap(NULL, 0x4000, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    
    // Define memory offsets for the two slots
    void *src_buffers[2] = { buf, buf + 0x2000 };          // Source addresses
    void *dst_buffers[2] = { buf + 0x1000, buf + 0x3000 }; // Destination addresses
    unsigned int phys_offsets[2] = { 0x0000, 0x2000 };     // Physical offset for DMA
    int current_slot = 0;
    
    // 2. Setup DMA Registers (Axi DMA)
    fd2 = open("/dev/mem", O_RDWR | O_SYNC);
    map_base = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd2, PHYS_ADDR & ~(PAGE_SIZE - 1));
    virt_addr = (volatile unsigned int *)((char *)map_base + (PHYS_ADDR % PAGE_SIZE));

    // 3. Setup Networking
    int sock;
    struct sockaddr_in serv_addr, clnt_addr;
    sock = socket(PF_INET, SOCK_DGRAM, 0);
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
    struct timeval start_time, end_time;
    gettimeofday(&start_time, NULL);

    printf("Silicon Shroud Combined Server Online. Target: 5 Mbps\n");
    if (buf == MAP_FAILED) {
        perror("udmabuf mmap failed");
        exit(1);
    }
    if (map_base == MAP_FAILED) {
        perror("/dev/mem mmap failed (check sudo)");
        exit(1);
    }
    char temp_buffer[BUF_SIZE]; // Standard stack buffer for networking safety
    while (1) {
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        
        // RECEIVE: Use the current slot's source buffer
        int str_len = recvfrom(sock, (char*)src_buffers[current_slot], BUF_SIZE, 0, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
        if (str_len <= 0) continue;

        // START DMA: Use current slot's physical addresses
        *(volatile unsigned int*)((char*)virt_addr+MM2S_CTRL)   = 0x00000001;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_SA_LWR) = (unsigned int)phys_addr + phys_offsets[current_slot];
        *(volatile unsigned int*)((char*)virt_addr+MM2S_LEN)    = str_len;

        *(volatile unsigned int*)((char*)virt_addr+S2MM_CTRL)   = 0x00000001;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_DA_LWR) = (unsigned int)phys_addr + phys_offsets[current_slot] + 0x1000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_LEN)    = str_len;

        // POLL FOR COMPLETION
        volatile unsigned int status = 0;
        while(!(status & 0x02)) { 
            status = *(volatile unsigned int*)((char*)virt_addr+S2MM_STAT); 
        }

        // SEND: Back to PC from the current slot's destination buffer
        sendto(sock, (char*)dst_buffers[current_slot], str_len, 0, (struct sockaddr*)&clnt_addr, clnt_addr_size);

        // SHAPING LOGIC
        total_bytes_sent += str_len;
        packet_count++;
        if (packet_count >= ADJUST_INTERVAL_PACKETS) {
            gettimeofday(&end_time, NULL);
            double seconds = (end_time.tv_sec - start_time.tv_sec) + (end_time.tv_usec - start_time.tv_usec) / 1000000.0;
            double actual_bps = (total_bytes_sent * 8.0) / seconds;

            if (actual_bps > TARGET_BPS) current_delay_ns += 10000;
            else if (actual_bps < TARGET_BPS && current_delay_ns > 10000) current_delay_ns -= 10000;
            
            sleep_time.tv_nsec = current_delay_ns;
            printf("Rate: %.2f Mbps | Delay: %ld ns | Slot: %d\n", actual_bps / 1000000.0, current_delay_ns, current_slot);

            packet_count = 0; total_bytes_sent = 0;
            gettimeofday(&start_time, NULL);
        }

        // FLIP SLOTS: Prepare the other memory region for the next packet
        current_slot = (current_slot == 0) ? 1 : 0;
        
        nanosleep(&sleep_time, NULL);
    }
    
    return 0;
}
