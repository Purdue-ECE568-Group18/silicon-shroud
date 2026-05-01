#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10"

int main() {
    int sock;
    struct sockaddr_in serv_addr;
    char buffer[BUF_SIZE];
    
    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    // Set a short timeout so the client doesn't hang if a packet is dropped
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000; // 100ms
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    while(1) {
        // 1. Read raw video data from stdin
        size_t bytes_read = fread(buffer, 1, BUF_SIZE, stdin);
        
        if (bytes_read <= 0) {
            break; // End of file or pipe
        }

        // 2. Send the video packet to the Zynq Board
        sendto(sock, buffer, bytes_read, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

        // 3. Receive the processed packet back from the board
        int received = recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);

        if (received > 0) {
            // 4. Write the returned data to stdout for the video player
            fwrite(buffer, 1, received, stdout);
            fflush(stdout);
        }

        // Maintain a small delay to prevent overwhelming the UDP stack
        // 1000us (1ms) allows for up to ~12Mbps theoretical throughput
        usleep(1000); 
    }

    close(sock);
    return 0;
}
