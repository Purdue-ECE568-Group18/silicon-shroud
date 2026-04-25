#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define BUF_SIZE 1500  // Corrected to 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.1.10" // Board IP

void error_handling(char *message) {
    perror(message);
    exit(1);
}

int main() {
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
        int str_len = recvfrom(sock, buffer, BUF_SIZE, 0, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
        
        // Loopback: send exact same buffer back
        sendto(sock, buffer, str_len, 0, (struct sockaddr*)&clnt_addr, clnt_addr_size);
    }
    close(sock);
    return 0;
}
