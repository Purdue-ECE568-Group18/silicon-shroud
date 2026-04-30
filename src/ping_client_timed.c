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
    struct timeval last_time, current_time;
    
    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    printf("Starting stream. Press Ctrl+C to stop.\n");

    while(1) {
        memset(buffer, 'A', BUF_SIZE);
        sendto(sock, buffer, BUF_SIZE, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
        
        recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);
        gettimeofday(&current_time, NULL);
        
        // Simple delta calculation (you can log these to a file for CV analysis)
        double dt = (current_time.tv_sec - last_time.tv_sec) * 1000000.0 + 
                    (current_time.tv_usec - last_time.tv_usec);
        printf("Packet round-trip delta: %.2f us\n", dt);
        
        last_time = current_time;
        usleep(2000); // 50ms sleep
    }
    close(sock);
    return 0;
}
