### shroud_server_pad-chaff

## Control Flow:
RECV UDP
IF ENABLE_PADDING
    PAD OR SHAPE RX BUFFER BEFORE DMA
IF ENABLE_DMA
    COPY TO DMA SRC
    START DMA
    WAIT FOR DONE
    READ DMA DST INTO TX BUFFER
ELSE
    COPY RX BUFFER TO TX BUFFER
IF ENABLE_CHAFF
    ADD CHAFF TO TX BUFFER
IF ENABLE_SCHEDULER
    WAIT UNTIL NEXT RELEASE TIME
SEND UDP RESPONSE

## Execution Flow:
1. `recvfrom()` receives a UDP payload
2. copy payload into DMA source buffer
3. apply **pad** logic before DMA
4. start DMA transfer
5. wait for DMA completion
6. copy DMA output into TX buffer
7. apply **chaff** logic after DMA
8. `sendto()` transmits the final UDP datagram

## Added behavior:
- **PAD BEFORE DMA**
  - pad the received payload before sending it into the DMA / AES path
  - intended for AES block alignment or fixed pre DMA sizing
- **CHAFF AFTER DMA**
  - after DMA completes, fill the remaining bytes in the TX buffer with chaff
  - intended to make the outgoing UDP datagram reach fixed size

### Modes:

## DMA mode
Uses the DMA path.
## BYPASS mode
Skips DMA and uses the software path only.
Can test socket + pad + chaff behavior without hardware in the loop.

## Options
- `--mode dma`
- `--mode bypass`
- `--no-pad`
- `--no-chaff`
- `--target-bytes <N>`
- `--align-bytes <N>`
- `--poll-us <N>`
- `--verbose`

## Example build
Cross-compile on the host:
```bash
arm-linux-gnueabihf-gcc -O2 -o shroud_server_pad_chaff shroud_server_pad_chaff.c -static
```

### 1. SW Only Loopback
```bash
sudo ./shroud_server_pad_chaff --mode bypass --no-pad --no-chaff --verbose
```
### 2. Pad Only
```bash
sudo ./shroud_server_pad_chaff --mode bypass --no-chaff --target-bytes 1500 --align-bytes 16 --verbose
```
### 3. DMA Only
```bash
sudo ./shroud_server_pad_chaff --mode dma --no-chaff --no-pad --verbose
```
### 4. Full Path
```bash
sudo ./shroud_server_pad_chaff --mode dma --target-bytes 1500 --align-bytes 16 --verbose
```

