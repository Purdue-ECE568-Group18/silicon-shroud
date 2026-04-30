#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.4"

int main() {
    int sock;
    struct sockaddr_in serv_addr;
    char buffer[BUF_SIZE];
    struct timeval last_time, current_time;
    
    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    printf("Starting stream. Press Ctrl+C to stop.\n");

    memset(buffer, 'A', BUF_SIZE);
    for (size_t i = 0; i < BUF_SIZE; i++) {
        printf("%x\n", buffer[i]);
    }
    sendto(sock, buffer, BUF_SIZE, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    printf("\n\n\n");
        
    recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);
    for (size_t i = 0; i < BUF_SIZE; i++) {
        printf("%x\n", buffer[i]);
    }    
    
    gettimeofday(&current_time, NULL);
        
    // Simple delta calculation (you can log these to a file for CV analysis)
    double dt = (current_time.tv_sec - last_time.tv_sec) * 1000000.0 + 
                (current_time.tv_usec - last_time.tv_usec);
    printf("Packet round-trip delta: %.2f us\n", dt);
        
    last_time = current_time;

        
    close(sock);
    return 0;
}
