#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <time.h>
#include <sys/time.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10"

// Target: 5 Mbps (5,000,000 bits per second)
#define TARGET_BPS 5000000 
#define ADJUST_INTERVAL_PACKETS 100 

int main() {
    int sock;
    struct sockaddr_in serv_addr, clnt_addr;
    char buffer[BUF_SIZE];
    
    // Initial guess: 2.4ms (2,400,000 nanoseconds) for 5Mbps
    long current_delay_ns = 2400000; 
    struct timespec sleep_time = {0, current_delay_ns};

    long total_bytes_sent = 0;
    int packet_count = 0;
    struct timeval start_time, end_time;

    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    
    // Using INADDR_ANY to avoid "Cannot assign requested address" errors
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); 
    serv_addr.sin_port = htons(PONG_PORT);

    if (bind(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1) {
        perror("bind() error");
        exit(1);
    }

    printf("Dynamic Rate Pong Server active. Target: %d Mbps\n", TARGET_BPS / 1000000);
    gettimeofday(&start_time, NULL);

    while (1) {
        socklen_t clnt_addr_size = sizeof(clnt_addr);
        int str_len = recvfrom(sock, buffer, BUF_SIZE, 0, (struct sockaddr*)&clnt_addr, &clnt_addr_size);

        // Loopback the data
        sendto(sock, buffer, str_len, 0, (struct sockaddr*)&clnt_addr, clnt_addr_size);
        
        total_bytes_sent += str_len;
        packet_count++;

        // Every 100 packets, recalculate and adjust rate
        if (packet_count >= ADJUST_INTERVAL_PACKETS) {
            gettimeofday(&end_time, NULL);
            
            double seconds = (end_time.tv_sec - start_time.tv_sec) + 
                             (end_time.tv_usec - start_time.tv_usec) / 1000000.0;
            double actual_bps = (total_bytes_sent * 8.0) / seconds;

            // Simple adjustment logic
            if (actual_bps > TARGET_BPS) {
                current_delay_ns += 50000; // Increase delay by 50us (slow down)
            } else if (actual_bps < TARGET_BPS && current_delay_ns > 50000) {
                current_delay_ns -= 50000; // Decrease delay by 50us (speed up)
            }

            sleep_time.tv_nsec = current_delay_ns;
            
            // Print telemetry for debugging
            printf("Current Rate: %.2f Mbps | Delay: %ld ns\n", actual_bps / 1000000.0, current_delay_ns);

            // Reset window
            packet_count = 0;
            total_bytes_sent = 0;
            gettimeofday(&start_time, NULL);
        }

        nanosleep(&sleep_time, NULL);
    }

    close(sock);
    return 0;
}
