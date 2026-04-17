`timescale 1ns / 1ps

import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module dma_sim_tb();

  axi_vip_0_mst_t agent;
  xil_axi_resp_t resp;

  logic [31:0] data_rd;

  initial begin
    agent = new("my VIP agent", u_axi_lite_driver.inst.IF);
    agent.set_agent_tag("Master VIP");
    agent.set_verbosity(400);
    agent.start_master();
    agent.AXI4LITE_WRITE_BURST(32'h00000000, '0, 32'h00000001, resp);
    #20
    agent.AXI4LITE_READ_BURST(32'h00000000, '0, data_rd, resp);
  end

  logic clk;
  logic resetn;
  
  initial clk = 0;
  initial resetn=1;
  always #10 clk = ~clk; 

  logic [31:0] m_axi_awaddr  ;
  logic [2:0]  m_axi_awprot  ;
  logic        m_axi_awvalid ;
  logic        m_axi_awready ;
  logic [31:0] m_axi_wdata   ;
  logic [3:0]  m_axi_wstrb   ;
  logic        m_axi_wvalid  ;
  logic        m_axi_wready  ;
  logic [1:0]  m_axi_bresp   ;
  logic        m_axi_bvalid  ;
  logic        m_axi_bready  ;
  logic [31:0] m_axi_araddr  ;
  logic [2:0]  m_axi_arprot  ;
  logic        m_axi_arvalid ;
  logic        m_axi_arready ;
  logic [31:0] m_axi_rdata   ;
  logic [1:0]  m_axi_rresp   ;
  logic        m_axi_rvalid  ;
  logic        m_axi_rready  ;  
  
  axi_vip_0 u_axi_lite_driver (
    .aclk            (clk           ),
    .aresetn         (resetn        ),
    .m_axi_awaddr    (m_axi_awaddr  ),
    .m_axi_awprot    (m_axi_awprot  ),
    .m_axi_awvalid   (m_axi_awvalid ),
    .m_axi_awready   (m_axi_awready ),
    .m_axi_wdata     (m_axi_wdata   ),
    .m_axi_wstrb     (m_axi_wstrb   ),
    .m_axi_wvalid    (m_axi_wvalid  ),
    .m_axi_wready    (m_axi_wready  ),
    .m_axi_bresp     (m_axi_bresp   ),
    .m_axi_bvalid    (m_axi_bvalid  ),
    .m_axi_bready    (m_axi_bready  ),
    .m_axi_araddr    (m_axi_araddr  ),
    .m_axi_arprot    (m_axi_arprot  ),
    .m_axi_arvalid   (m_axi_arvalid ),
    .m_axi_arready   (m_axi_arready ),
    .m_axi_rdata     (m_axi_rdata   ),
    .m_axi_rresp     (m_axi_rresp   ),
    .m_axi_rvalid    (m_axi_rvalid  ),
    .m_axi_rready    (m_axi_rready  )
  );                    
           
  axi_dma_0 u_dma (
    .s_axi_lite_aclk     (clk          ),
    .m_axi_mm2s_aclk     (clk          ),
    .m_axi_s2mm_aclk     (clk          ),
    .axi_resetn          (resetn       ),
    
    .s_axi_lite_awvalid  (m_axi_awvalid),
    .s_axi_lite_awready  (m_axi_awready),
    .s_axi_lite_awaddr   (m_axi_awaddr [9:0]),
    .s_axi_lite_wvalid   (m_axi_wvalid ),
    .s_axi_lite_wready   (m_axi_wready ),
    .s_axi_lite_wdata    (m_axi_wdata  ),
    .s_axi_lite_bresp    (m_axi_bresp  ),
    .s_axi_lite_bvalid   (m_axi_bvalid ),
    .s_axi_lite_bready   (m_axi_bready ),
    .s_axi_lite_arvalid  (m_axi_arvalid),
    .s_axi_lite_arready  (m_axi_arready),
    .s_axi_lite_araddr   (m_axi_araddr [9:0]),
    .s_axi_lite_rvalid   (m_axi_rvalid ),
    .s_axi_lite_rready   (m_axi_rready ),
    .s_axi_lite_rdata    (m_axi_rdata  ),
    .s_axi_lite_rresp    (m_axi_rresp  ),
    
    /* Read AXI Port, only read signals */
    .m_axi_mm2s_araddr      (),
    .m_axi_mm2s_arlen       (),
    .m_axi_mm2s_arsize      (),
    .m_axi_mm2s_arburst     (),
    .m_axi_mm2s_arprot      (),
    .m_axi_mm2s_arcache     (),
    //.m_axi_mm2s_aruser      (),
    .m_axi_mm2s_arvalid     (),
    .m_axi_mm2s_arready     (),
    .m_axi_mm2s_rdata       (),
    .m_axi_mm2s_rresp       (),
    .m_axi_mm2s_rlast       (),
    .m_axi_mm2s_rvalid      (),
    .m_axi_mm2s_rready      (),
    .mm2s_prmry_reset_out_n (),
    
    .m_axis_mm2s_tdata      (),
    .m_axis_mm2s_tkeep      (),
    .m_axis_mm2s_tvalid     (),
    .m_axis_mm2s_tready     (),
    .m_axis_mm2s_tlast      (),
    //.m_axis_mm2s_tuser      (),
    //.m_axis_mm2s_tid        (),
    //.m_axis_mm2s_tdest      (),
    //.mm2s_cntrl_reset_out_n (),
          
    .m_axi_s2mm_awaddr      (),
    .m_axi_s2mm_awlen       (),
    .m_axi_s2mm_awsize      (),
    .m_axi_s2mm_awburst     (),
    .m_axi_s2mm_awprot      (),
    .m_axi_s2mm_awcache     (),
    //.m_axi_s2mm_awuser      (),
    .m_axi_s2mm_awvalid     (),
    .m_axi_s2mm_awready     (),
    .m_axi_s2mm_wdata       (),
    .m_axi_s2mm_wstrb       (),
    .m_axi_s2mm_wlast       (),
    .m_axi_s2mm_wvalid      (),
    .m_axi_s2mm_wready      (),
    .m_axi_s2mm_bresp       (),
    .m_axi_s2mm_bvalid      (),
    .m_axi_s2mm_bready      (),
    .s2mm_prmry_reset_out_n (),
    
    .s_axis_s2mm_tdata      (),
    .s_axis_s2mm_tkeep      (),
    .s_axis_s2mm_tvalid     (),
    .s_axis_s2mm_tready     (),
    .s_axis_s2mm_tlast      (),
    //.s_axis_s2mm_tuser      (),
    //.s_axis_s2mm_tid        (),
    //.s_axis_s2mm_tdest      (),
    //.s2mm_sts_reset_out_n   (),
    
    
    .mm2s_introut           (),
    .s2mm_introut           (),
    .axi_dma_tstvec         ()
    
    /* Unused */
    //.m_axis_mm2s_cntrl_tdata  (  ),
    //.m_axis_mm2s_cntrl_tkeep  (  ),
    //.m_axis_mm2s_cntrl_tvalid (  ),
    //.m_axis_mm2s_cntrl_tready ('0),
    //.m_axis_mm2s_cntrl_tlast  (  ),
    //
    //.s_axis_s2mm_sts_tdata    ('0),
    //.s_axis_s2mm_sts_tkeep    ('0),
    //.s_axis_s2mm_sts_tvalid   ('0),
    //.s_axis_s2mm_sts_tready   (  ),
    //.s_axis_s2mm_sts_tlast    ('0),
    //
    //.m_axi_sg_awaddr         (),
    //.m_axi_sg_awlen          (),
    //.m_axi_sg_awsize         (),
    //.m_axi_sg_awburst        (),
    //.m_axi_sg_awprot         (),
    //.m_axi_sg_awcache        (),
    //.m_axi_sg_awuser         (),
    //.m_axi_sg_awvalid        (),
    //.m_axi_sg_awready        ('0),
    //.m_axi_sg_wdata          (),
    //.m_axi_sg_wstrb          (),
    //.m_axi_sg_wlast          (),
    //.m_axi_sg_wvalid         (),
    //.m_axi_sg_wready         ('0),
    //.m_axi_sg_bresp          (),
    //.m_axi_sg_bvalid         ('0),
    //.m_axi_sg_bready         (),
    //.m_axi_sg_araddr         (),
    //.m_axi_sg_arlen          (),
    //.m_axi_sg_arsize         (),
    //.m_axi_sg_arburst        (),
    //.m_axi_sg_arprot         (),
    //.m_axi_sg_arcache        (),
    //.m_axi_sg_aruser         (),
    //.m_axi_sg_arvalid        (),
    //.m_axi_sg_arready        ('0),
    //.m_axi_sg_rdata          (),
    //.m_axi_sg_rresp          (),
    //.m_axi_sg_rlast          (),
    //.m_axi_sg_rvalid         (),
    //.m_axi_sg_rready         ('0)
    );           
           
                        
endmodule