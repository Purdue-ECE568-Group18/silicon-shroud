## Go Into the Board
## Access the Cora Z7 terminal via Minicom:
- sudo minicom -D /dev/ttyUSB1 -b 115200

## Find and Setting the Ethernet Port
- ip link show (Ex: enx000a35001e53)

### Bring the interface down
- sudo ifconfig enx000a35001e53 down

### Assign the IP, it has to be the same as the host Ip except the last number
- sudo ifconfig enx000a35001e53 192.168.0.10 netmask 255.255.255.0 up

### If you are just using a regular ethernet cord, its probably going to be eth0
- ifconfig enx000a35001e53

### Run if you did this already but have a hanging ssh key on the host side
- ssh-keygen -f '/home/zachebert/.ssh/known_hosts' -R '192.168.0.10'

## Executions
### run the command below on the client side, and then run the executable
- gcc -o ping_client_cv ping_client_cv.c

### run the command below on the server side, and then run the executable
- arm-linux-gnueabihf-gcc -o pong_server pong_server.c -static

### Notes
- The loopback is for if you run the client side first before the server, 
- Its good practice to run the server first

### Copy to the Board
- scp shroud_server petalinux@192.168.0.10:/home/petalinux/


## Code Workflow
1) The shroud_server operates using a Double-Buffered DMA Pipeline to ensure memory safety and timing precision:

2) RECV: recvfrom() receives a UDP payload into a source buffer slot.

3) STEP A (Padding): If enabled, the payload is aligned (default 16 bytes) for AES readiness.

4) STEP B (DMA): Data is moved through the FPGA AXI DMA engine to the destination buffer slot.

5) STEP C (Chaff): Remaining bytes up to the --target-bytes limit are filled with LFSR-generated noise.

6) SHAPE: The shaper waits until the next release time to maintain a strict 5 Mbps throughput.

7) SEND: sendto() transmits the uniform 1500-byte datagram.

## Start on the Board
- This is the standard operational mode for the Silicon Shroud. It ensures all outgoing packets are 1500 bytes with stabilized timing.
- Since this involve alot of map calls, you need to run the command below in sudo
- sudo ./shroud_server --mode dma --target-bytes 1500 --align-bytes 16 --verbose

### Bypass Mode
- sudo ./shroud_server --mode bypass --target-bytes 1500 --verbose

### Command Line Options
- --mode <dma/bypass> -> Choose between Hardware DMA or Software path.
- --target-bytes <N> -> The total size of every outgoing packet (default 1500).
- --align-bytes <N> -> Padding alignment for AES readiness (default 16).
- --no-pad / --no-chaff -> Disable specific security features.
- --verbose -> Enable real-time telemetry and throughput prints.

## Streaming the Video
- compile the ping_client_ffmpeg code using gcc on the host side
- Put the run this below
    - cat stream720p.ts | ./ping_client_cv | mpv --cache=yes --demuxer-lavf-format=mpegts -

## View Logs
- Can be found in the same directory called shroud_stats.csv

### Clean Exits
The server and client includes Signal Resilience. 
Pressing Ctrl+C triggers a graceful shutdown, closing memory mappings and sockets safely. 
A 1-second socket timeout ensures the server checks the shutdown flag even if no packets are being received
