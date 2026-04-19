// Task 3: Integration Orchestrator (Pipeline Heartbeat)
bool isDmaIdle() {
    // Check Status Register (0x04) - Bit 1 is 'Idle'
    return (dma_regs[0x04 / 4] & 0x02);
}

void orchestrateFlow(uint32_t* video_frame, uint32_t size) {
    if (isDmaIdle()) {
        // Clear potential interrupts (Status Reg bit 12)
        dma_regs[0x04 / 4] |= 0x1000; 
        
        // Feed the pipe
        streamPayload(video_frame, size);
    } else {
        // Handle Backpressure (optional: log a warning if DMA is too busy)
        std::cerr << "DMA starvation detected!" << std::endl;
    }
}
