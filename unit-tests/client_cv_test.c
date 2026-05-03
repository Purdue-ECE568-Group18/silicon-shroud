#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <math.h> // Required for sqrt() and pow()

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10"
#define STATS_WINDOW 100 // Calculate CV every 100 packets

int main() {
    int sock;
    struct sockaddr_in serv_addr;
    char buffer[BUF_SIZE];

    // Variables for CV calculation
    struct timeval start, end;
    double latencies[STATS_WINDOW];
    int packet_idx = 0;

    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000; // 100ms
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    while(1) {
        size_t bytes_read = fread(buffer, 1, BUF_SIZE, stdin);
        if (bytes_read <= 0) break;

        // Start timing BEFORE sendto
        gettimeofday(&start, NULL);

        sendto(sock, buffer, bytes_read, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));

        int received = recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);

        if (received > 0) {
            // End timing AFTER recvfrom
            gettimeofday(&end, NULL);
            
            // Calculate round-trip latency in microseconds
            double latency = (end.tv_sec - start.tv_sec) * 1000000.0 + (end.tv_usec - start.tv_usec);
            latencies[packet_idx++] = latency;

            // Output video data to stdout
            fwrite(buffer, 1, received, stdout);
            fflush(stdout);

            // Calculate CV when window is full
            if (packet_idx >= STATS_WINDOW) {
                double sum = 0, sq_sum = 0;
                
                for (int i = 0; i < STATS_WINDOW; i++) sum += latencies[i];
                double mean = sum / STATS_WINDOW;

                for (int i = 0; i < STATS_WINDOW; i++) {
                    sq_sum += pow(latencies[i] - mean, 2);
                }
                double std_dev = sqrt(sq_sum / STATS_WINDOW);
                double cv = (mean > 0) ? (std_dev / mean) : 0;

                // stderr is used so it doesn't corrupt the video stream pipe
                fprintf(stderr, "\n[STATS] Mean Latency: %.2f us | StdDev: %.2f | CV: %.4f\n", mean, std_dev, cv);
                
                packet_idx = 0;
            }
        }

        usleep(1000); 
    }

    close(sock);
    return 0;
}
