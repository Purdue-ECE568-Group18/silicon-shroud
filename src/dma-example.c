/*
* Copyright (C) 2013-2022  Xilinx, Inc.  All rights reserved.
* Copyright (c) 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in this
* Software without prior written authorization from Xilinx.
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

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

int main(int argc, char** argv)
{
	printf("Running main\n");
    int fd, fd2, fd3;
    int buf_size = 0x2000;  
    void* buf = NULL;
    int i;

    unsigned char  attr[1024];
    unsigned long  phys_addr;
    if ((fd3  = open("/sys/class/u-dma-buf/udmabuf0/phys_addr", O_RDONLY)) != -1) {
        read(fd3, attr, 1024);
        sscanf(attr, "%x", &phys_addr);
	printf("%x\n", phys_addr);
        close(fd3);
    }

    printf("Size of void pointer: %zu bytes\n", sizeof(buf));

    if ((fd  = open("/dev/udmabuf0", O_RDWR | O_SYNC)) != -1) {
        buf = mmap(NULL, buf_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
        /* Do some read/write access to buf */
        printf("Writing the TX buffer, first 4096 bytes\n");
        for(i = 0; i < 1024; i++) // 4kB buffer Int pointer, 4 bytes at a time per increment
        {
            *((volatile unsigned int*)buf+i) = i;        
        }
	printf("Reading TX Buffer\n");
        for(i = 0; i < 1024; i++) // 4kB buffer Int pointer, 4 bytes at a time per increment
        {
            printf("%d: %x\n", i, *((volatile unsigned int*)buf+i));        
        }

        printf("Reading RX buffer, pre-DMA\n");
        for(i = 1024; i < 2048; i++) // 4kB buffer int pointer, 4 bytes
        {
            printf("%d: %x\n", i, *((volatile unsigned int*)buf+i));        
        }

        printf("Doing DMA\n");
        void *map_base;
        volatile unsigned int *virt_addr;

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
        
        
        *(volatile unsigned int*)((char*)virt_addr+MM2S_CTRL)    = 0x00007001;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_SA_LWR)  = (unsigned int) phys_addr;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_SA_UPR)  = 0x00000000;
        *(volatile unsigned int*)((char*)virt_addr+MM2S_LEN)     = 0x00001000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_CTRL)    = 0x00000001;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_DA_LWR)  = (unsigned int) phys_addr+0x1000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_DA_UPR)  = 0x00000000;
        *(volatile unsigned int*)((char*)virt_addr+S2MM_LEN)     = 0x00001000;
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
	printf("S2MM Stat: %x\n", return_val);


        munmap(map_base, PAGE_SIZE);
        close(fd2);

        printf("Reading RX buffer, post-DMA\n");
        for(i = 1024; i < 2048; i++)
        {
            printf("%d: %x\n", i, *((volatile unsigned int*)buf+i));        
        }  
        
        close(fd);
    }
    else
    {
	    printf("Could not open the file\n");
    }

};
