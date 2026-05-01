## Find Ethernet Port
- ip link show (Ex: enx000a35001e53)

## Bring the interface down
- ifconfig enx000a35001e53 down

## Assign the IP, it has to be the same as the host Ip except the last number
- ifconfig enx000a35001e53 192.168.1.10 netmask 255.255.255.0 up

## If you are just using a regular ethernet cord, its probably going to be eth0
- ifconfig enx000a35001e53

### For the Above Im using a USB to Ethernet prot, thats why it looks so wierd

## Run if you did this already but have a hanging ssh key
- ssh-keygen -f '/home/zachebert22/.ssh/known_hosts' -R '192.168.1.10'

## Will need to install the ARM Compiler for it since gcc isnt available on petalinux
- arm-linux-gnueabihf-gcc -o pong_server pong_server.c -static

## run the command below on the client side, and then run the executable
- gcc -o ping_client ping_client.c

## run the command below on the server side, and then run the executable
- arm-linux-gnueabihf-gcc -o pong_server pong_server.c -static

## Notes
- The loopback is for if you run the client side first before the server, 
- Its good practice to run the server first

## Copy to the Board
scp pong_server petalinux@192.168.1.10:/home/petalinux/silicon-shroud/src/

## Streaming the Video
- compile the ping_client_ffmpeg code using gcc on the host side
- Put the run this below
    - cat stream720p.ts | ./ping_client_ffmpeg | mpv --cache=yes --demuxer-lavf-format=mpegts -
