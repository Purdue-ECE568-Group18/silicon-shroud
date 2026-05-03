#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <math.h>

#define BUF_SIZE 1500
#define PONG_PORT 6000
#define BOARD_IP "192.168.0.10"
#define STATS_WINDOW 100 

int main() {
    int sock;
    struct sockaddr_in serv_addr;
    char buffer[BUF_SIZE];
    
    // Timing and Stats Variables
    struct timeval start, end;
    double latencies[STATS_WINDOW];
    int packet_idx = 0;
    long current_usleep = 1000; // Starting usleep value

    // CSV File Setup
    FILE *csv_file = fopen("shroud_stats.csv", "w");
    if (csv_file == NULL) {
        perror("Failed to open CSV file");
        exit(1);
    }
    fprintf(csv_file, "Mean_Latency_us,StdDev_us,CV,Usleep_Val\n");

    sock = socket(PF_INET, SOCK_DGRAM, 0);
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(BOARD_IP);
    serv_addr.sin_port = htons(PONG_PORT);

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100000; 
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

    while(1) {
        size_t bytes_read = fread(buffer, 1, BUF_SIZE, stdin);
        if (bytes_read <= 0) break;

        gettimeofday(&start, NULL);
        sendto(sock, buffer, bytes_read, 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
        int received = recvfrom(sock, buffer, BUF_SIZE, 0, NULL, NULL);

        if (received > 0) {
            gettimeofday(&end, NULL);
            double latency = (end.tv_sec - start.tv_sec) * 1000000.0 + (end.tv_usec - start.tv_usec);
            latencies[packet_idx++] = latency;

            fwrite(buffer, 1, received, stdout);
            fflush(stdout);

            if (packet_idx >= STATS_WINDOW) {
                double sum = 0, sq_sum = 0;
                for (int i = 0; i < STATS_WINDOW; i++) sum += latencies[i];
                double mean = sum / STATS_WINDOW;

                for (int i = 0; i < STATS_WINDOW; i++) {
                    sq_sum += pow(latencies[i] - mean, 2);
                }
                double std_dev = sqrt(sq_sum / STATS_WINDOW);
                double cv = (mean > 0) ? (std_dev / mean) : 0;

                // 1. Export to CSV
                fprintf(csv_file, "%.2f,%.2f,%.4f,%ld\n", mean, std_dev, cv, current_usleep);
                fflush(csv_file);

                // 2. Adjust usleep based on CV (Jitter Compensation)
                // If CV is high (> 0.1), slow down slightly to stabilize the stream
                if (cv > 0.10 && current_usleep < 5000) {
                    current_usleep += 50; 
                } else if (cv < 0.05 && current_usleep > 500) {
                    current_usleep -= 50;
                }

                packet_idx = 0;
            }
        }
        usleep(current_usleep);
    }

    fclose(csv_file);
    close(sock);
    return 0;
}
