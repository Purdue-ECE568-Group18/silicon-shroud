// Task 1: Efficient Streaming
// Focus: Zero-padding, direct memory access
void streamPayload(uint32_t* buffer, uint32_t length) {
    // 1. Point DMA to our raw video frame buffer
    dma_regs[0x18 / 4] = (uint32_t)buffer; 
    
    // 2. Trigger the DMA engine by setting the transfer length
    // This immediately starts the hardware "pull" of the video frame
    dma_regs[0x28 / 4] = length; 
}
