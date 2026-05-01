#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <sys/mman.h>

#define BUF_SIZE 1500  // Corrected to 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.4" // Board IP

#define PAGE_SIZE 4096
#define PHYS_ADDR 0x40400000  // from my design
#define MM2S_CTRL   0x0
#define MM2S_STAT   0x4
#define MM2S_SA_LWR 0x18
#define MM2S_SA_UPR 0x1C
#define MM2S_LEN    0x28
#define S2MM_CTRL   0x30
#define S2MM_STAT   0x34
#define S2MM_DA_LWR 0x48
#define S2MM_DA_UPR 0x4C
#define S2MM_LEN    0x58

void error_handling(char *message) {
    perror(message);
    exit(1);
}

int main() {
    int fd, fd2, fd3;
    void* buf  = NULL;
    void* buf2 = NULL;
    int i;
    int buf_size = 0x2000;  
    void *map_base;
    volatile unsigned int *virt_addr;

    unsigned char  attr[1024];
    unsigned long  phys_addr;
    if ((fd3  = open("/sys/class/u-dma-buf/udmabuf0/phys_addr", O_RDONLY)) != -1) {
        read(fd3, attr, 1024);
        sscanf(attr, "%x", &phys_addr);
        close(fd3);
    }

   // Open file for physical buffer
    if ((fd = open("/dev/udmabuf0", O_RDWR | O_SYNC)) < 0) {
        perror("Failed to open /dev/mem");
        return 1;
    }
    // Get pointer to the physical buffer
    buf = mmap(NULL, buf_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    buf2 = buf+0x1000;

    // 1. Open /dev/mem
    if ((fd2 = open("/dev/mem", O_RDWR | O_SYNC)) < 0) {
        perror("Failed to open /dev/mem");
        return 1;
    }
    // 2. Map physical address to virtual address
    // Note: phys_addr should be page-aligned for the base address
    map_base = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd2, PHYS_ADDR & ~(PAGE_SIZE - 1));
    if (map_base == MAP_FAILED) {
        perror("mmap failed");
        close(fd2);
        return 1;
    }
    // 3. Calculate offset within the page
    virt_addr = (volatile unsigned int *)((char *)map_base + (PHYS_ADDR % PAGE_SIZE));

    
    int sock;
    struct sockaddr_in serv_addr, clnt_addr;
    char buffer[BUF_SIZE];
    
    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    if (bind(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
        error_handling("bind() error");

    printf("Pong Server listening on %s:%d\n", BOARD_IP, PONG_PORT);

    while (1) {
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        int str_len = recvfrom(sock, (char*)buf, BUF_SIZE, 0, (struct sockaddr*)&clnt_addr, &clnt_addr_size);

/*
        for(i = 0; i < 100; i++)
        {
            printf("%d: %x\n", i, *(int*)(buf+i));        
        }    
*/
        
        *(volatile unsigned int*)((char*)virt_addr+MM2S_CTRL)    = 0x00007001;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_SA_LWR)  = (unsigned int) phys_addr;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_SA_UPR)  = 0x00000000;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_LEN)     = 0x00001000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_CTRL)    = 0x00000001;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_DA_LWR)  = (unsigned int) phys_addr+0x1000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_DA_UPR)  = 0x00000000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_LEN)     = 0x00001000;
        // This is where the polling comes in, hopefully this doesnt screw us 
        volatile unsigned int return_val=0;
        while(!( (return_val >> 1) & 1))
        {
            return_val = *(volatile unsigned int*)((char*)virt_addr+MM2S_STAT);
        }
        printf("MM2S Stat: %x\n", return_val);

        return_val = 0;
        while(!( (return_val >> 1) & 1))
        {
            return_val = *(volatile unsigned int*)((char*)virt_addr+S2MM_STAT);
        }        

/*
        for(i = 1024; i < 1124; i++)
        {
            printf("%d: %x\n", i, *(int*)(buf+i));        
        }   
        
        for(i = 0; i < 100; i++)
        {
            printf("%d: %x\n", i, *(int*)(buf2+i));        
        }   
*/        
        
        // Loopback: send exact same buffer back
        sendto(sock, (char*)buf2, str_len, 0, (struct sockaddr*)&clnt_addr, clnt_addr_size);
    }
    close(sock);
    return 0;
}
