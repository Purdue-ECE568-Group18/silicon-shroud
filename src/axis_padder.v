`timescale 1ns / 1ps

module axis_padder(
    input wire aclk,
    input wire aresetn,
    
    // Slave Interface (from Ethernet/Network)
    input wire [31:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,
    
    // Master Interface (to DMA)
    output reg [31:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg m_axis_tlast
);

    localparam FORWARDING = 0;
    localparam PADDING    = 1;
    
    reg state = 0;
    reg [10:0] byte_count = 0; // Counts up to 1500
    
    // AXI-Stream Ready Logic
    assign s_axis_tready = (state == FORWARDING) ? m_axis_tready : 1'b0;

    always @(posedge aclk) begin
        if (!aresetn) begin
            state <= FORWARDING;
            byte_count <= 0;
            m_axis_tvalid <= 0;
        end else begin
            case (state)
                FORWARDING: begin
                    m_axis_tdata  <= s_axis_tdata;
                    m_axis_tvalid <= s_axis_tvalid;
                    
                    if (s_axis_tvalid && m_axis_tready) begin
                        byte_count <= byte_count + 4; // Assuming 32-bit (4-byte) transfers
                        if (s_axis_tlast) begin
                            if (byte_count + 4 < 1500) begin
                                state <= PADDING;
                            end else begin
                                byte_count <= 0;
                            end
                        end
                    end
                end
                
                PADDING: begin
                    m_axis_tdata  <= 32'h00000000;
                    m_axis_tvalid <= 1'b1;
                    
                    if (m_axis_tready) begin
                        byte_count <= byte_count + 4;
                        if (byte_count + 4 >= 1500) begin
                            m_axis_tlast <= 1'b1;
                            state <= FORWARDING;
                            byte_count <= 0;
                        end
                    end
                end
            endcase
        end
    end
endmodule