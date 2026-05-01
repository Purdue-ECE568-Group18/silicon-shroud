`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Luke Moy
// 
// Create Date: 04/26/2026 03:25:33 PM
// Design Name: 
// Module Name: aes_axi_stream_wrapper
// Project Name: Silicon Shroud
// Target Devices: Zync-7000
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aes_axi_stream_wrapper #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 6
)(
    // AXI-Lite slave (for key loading from CPU)
    input  wire                          s_axi_aclk,
    input  wire                          s_axi_aresetn,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                          s_axi_awvalid,
    output wire                          s_axi_awready,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    input  wire                          s_axi_wvalid,
    output wire                          s_axi_wready,
    output wire [1:0]                    s_axi_bresp,
    output wire                          s_axi_bvalid,
    input  wire                          s_axi_bready,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                          s_axi_arvalid,
    output wire                          s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0]                    s_axi_rresp,
    output wire                          s_axi_rvalid,
    input  wire                          s_axi_rready,

    // AXI-Stream slave (plaintext in from DMA)
    input  wire                          s_axis_aclk,
    input  wire                          s_axis_aresetn,
    input  wire [127:0]                  s_axis_tdata,
    input  wire                          s_axis_tvalid,
    output wire                          s_axis_tready,
    input  wire                          s_axis_tlast,

    // AXI-Stream master (ciphertext out to DMA)
    input  wire                          m_axis_aclk,
    input  wire                          m_axis_aresetn,
    output wire [127:0]                  m_axis_tdata,
    output wire                          m_axis_tvalid,
    input  wire                          m_axis_tready,
    output wire                          m_axis_tlast
);

    // -------------------------
    // Key registers (4 x 32-bit = 128-bit key)
    // Written by CPU over AXI-Lite
    // -------------------------
    reg [31:0] key_reg [0:3];
    wire [127:0] aes_key = {key_reg[0], key_reg[1], key_reg[2], key_reg[3]};

    // -------------------------
    // AXI-Lite write logic (simplified)
    // -------------------------
    reg axi_awready_r, axi_wready_r, axi_bvalid_r;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr_r;

    assign s_axi_awready = axi_awready_r;
    assign s_axi_wready  = axi_wready_r;
    assign s_axi_bvalid  = axi_bvalid_r;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_arready = 1'b1;
    assign s_axi_rdata   = 32'b0;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rvalid  = 1'b0;

    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            axi_awready_r <= 1'b0;
            axi_wready_r  <= 1'b0;
            axi_bvalid_r  <= 1'b0;
        end else begin
            if (s_axi_awvalid && !axi_awready_r) begin
                axi_awready_r <= 1'b1;
                axi_awaddr_r  <= s_axi_awaddr;
            end else
                axi_awready_r <= 1'b0;

            if (s_axi_wvalid && !axi_wready_r) begin
                axi_wready_r <= 1'b1;
                // Address bits [3:2] select which 32-bit key slice
                key_reg[axi_awaddr_r[3:2]] <= s_axi_wdata;
            end else
                axi_wready_r <= 1'b0;

            if (axi_wready_r && s_axi_wvalid)
                axi_bvalid_r <= 1'b1;
            else if (s_axi_bready)
                axi_bvalid_r <= 1'b0;
        end
    end

    // -------------------------
    // AES core control state machine
    // -------------------------
    reg aes_ld;
    reg aes_busy;
    reg [127:0] text_in_reg;
    reg tlast_reg;

    wire aes_done;
    wire [127:0] aes_text_out;

    // Handshake: accept data when AES is idle
    assign s_axis_tready = !aes_busy;

    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn) begin
            aes_ld      <= 1'b0;
            aes_busy    <= 1'b0;
            text_in_reg <= 128'b0;
            tlast_reg   <= 1'b0;
        end else begin
            aes_ld <= 1'b0; // default

            if (!aes_busy && s_axis_tvalid) begin
                // Latch input data and start AES
                text_in_reg <= s_axis_tdata;
                tlast_reg   <= s_axis_tlast;
                aes_ld      <= 1'b1;
                aes_busy    <= 1'b1;
            end else if (aes_busy && aes_done) begin
                aes_busy <= 1'b0;
            end
        end
    end

    // -------------------------
    // AXI-Stream master output
    // -------------------------
    assign m_axis_tdata  = aes_text_out;
    assign m_axis_tvalid = aes_done && aes_busy;
    assign m_axis_tlast  = tlast_reg;

    // -------------------------
    // AES core instantiation
    // -------------------------
    aes_cipher_top u_aes_cipher (
        .clk      (s_axis_aclk),
        .rst      (!s_axis_aresetn),
        .ld       (aes_ld),
        .done     (aes_done),
        .key      (aes_key),
        .text_in  (text_in_reg),
        .text_out (aes_text_out)
    );

endmodule