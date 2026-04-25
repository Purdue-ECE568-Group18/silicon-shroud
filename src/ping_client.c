#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h> // Required for struct timeval

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.1.10"

int main() {
    int sock;
    struct sockaddr_in serv_addr;
    char buffer[BUF_SIZE];
    
    memset(buffer, 'A', BUF_SIZE);

    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    // 1. Set a 1-second timeout for recvfrom
    struct timeval tv;
    tv.tv_sec = 1;
    tv.tv_usec = 0;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    printf("Pinging board at %s:%d...\n", BOARD_IP, PONG_PORT);

    // 2. Wrap the logic in a loop
    while(1) {
        // Send the packet
        sendto(sock, buffer, BUF_SIZE, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
        
        // Wait for reply
        int received = recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);
        
        if (received > 0) {
            printf("Successfully received 1500-byte packet back from Board!\n");
            break; // Exit the loop on success
        } else {
            printf("Waiting for server response...\n");
        }
    }

    close(sock);
    return 0;
}
