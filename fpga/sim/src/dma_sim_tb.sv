`timescale 1ns / 1ps

import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module dma_sim_tb();

  axi_vip_0_mst_t agent;
  xil_axi_resp_t resp;

  logic [31:0] data_rd;

  logic clk;
  logic resetn;

  task axi_write(input logic [31:0] addr, input logic [31:0] data);
    agent.AXI4LITE_WRITE_BURST(addr, '0, data, resp);  
  endtask

  initial begin
    agent = new("my VIP agent", u_axi_lite_driver.inst.IF);
    agent.set_agent_tag("Master VIP");
    agent.set_verbosity(400);
    agent.start_master();
    #1us
    resetn = 0;
    #1us
    resetn = 1;
    #1us
    // setting the run/stop bit to 1 (MM2S_DMACR.RS = 1)
    axi_write(32'h00000000, 32'h00007001);
    #20
    // Write a valid source address to the MM2S_SA register. 
    axi_write(32'h00000018, 32'h00000000);
    #20
    axi_write(32'h0000001C, 32'h00000000);
    #20    
    // Write the number of bytes to transfer in the MM2S_LENGTH register. 
    // A non-zero value causes the MM2S_LENGTH number of bytes to be read 
    // on the MM2S AXI4 interface and transmitted out of the MM2S AXI4-Stream interface.
    axi_write(32'h00000028, 32'h00001000);
    #20
    // setting the run/stop bit to 1 (S2MM_DMACR.RS = 1).
    axi_write(32'h00000030, 32'h00000001);
    #20
    // Write a valid destination address to the S2MM_DA register. 
    axi_write(32'h00000048, 32'h00008000);
    #20
    axi_write(32'h0000004C, 32'h00000000);    
    #20
    // Write the length in bytes of the receive buffer in the S2MM_LENGTH register.    
    // A non-zero value causes a write on the S2MM AXI4 interface of the number of bytes 
    // received on the S2MM AXI4-Stream interface.   
    axi_write(32'h00000058, 32'h00001000); 
  end
  
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

  logic [31:0] m_axi_mm2s_araddr ;
  logic [7:0]  m_axi_mm2s_arlen  ;
  logic [1:0]  m_axi_mm2s_arsize ;
  logic [1:0]  m_axi_mm2s_arburst;
  logic [2:0]  m_axi_mm2s_arprot ;
  logic [3:0]  m_axi_mm2s_arcache; 
  logic [3:0]  m_axi_mm2s_aruser ;
  logic        m_axi_mm2s_arvalid;
  logic        m_axi_mm2s_arready;
  logic [31:0] m_axi_mm2s_rdata  ;
  logic [1:0]  m_axi_mm2s_rresp  ;
  logic        m_axi_mm2s_rlast  ;
  logic        m_axi_mm2s_rvalid ;
  logic        m_axi_mm2s_rready ;
  
  logic [31:0] m_axi_s2mm_awaddr ;
  logic [7:0]  m_axi_s2mm_awlen  ;
  logic [2:0]  m_axi_s2mm_awsize ;
  logic [1:0]  m_axi_s2mm_awburst;
  logic [2:0]  m_axi_s2mm_awprot ;
  logic [3:0]  m_axi_s2mm_awcache;
  logic [3:0]  m_axi_s2mm_awuser ;
  logic        m_axi_s2mm_awvalid;
  logic        m_axi_s2mm_awready;
  logic [31:0] m_axi_s2mm_wdata  ;
  logic [3:0]  m_axi_s2mm_wstrb  ;
  logic        m_axi_s2mm_wlast  ;
  logic        m_axi_s2mm_wvalid ;
  logic        m_axi_s2mm_wready ;
  logic [1:0]  m_axi_s2mm_bresp  ;
  logic        m_axi_s2mm_bvalid ;
  logic        m_axi_s2mm_bready ;
  
  logic        bram_a_s_axi_aclk   ;
  logic        bram_a_s_axi_aresetn; 
  logic [0:0]  bram_a_s_axi_awid   ;
  logic [14:0] bram_a_s_axi_awaddr ;
  logic [7:0]  bram_a_s_axi_awlen  ;
  logic [2:0]  bram_a_s_axi_awsize ;
  logic [1:0]  bram_a_s_axi_awburst;
  logic        bram_a_s_axi_awlock ;
  logic [3:0]  bram_a_s_axi_awcache;
  logic [2:0]  bram_a_s_axi_awprot ;
  logic        bram_a_s_axi_awvalid; 
  logic        bram_a_s_axi_awready;
  logic [31:0] bram_a_s_axi_wdata  ;
  logic [3:0]  bram_a_s_axi_wstrb  ;
  logic        bram_a_s_axi_wlast  ;
  logic        bram_a_s_axi_wvalid ;
  logic        bram_a_s_axi_wready ;
  logic [0:0]  bram_a_s_axi_bid    ;
  logic [1:0]  bram_a_s_axi_bresp  ;
  logic        bram_a_s_axi_bvalid ;
  logic        bram_a_s_axi_bready ;
  logic [0:0]  bram_a_s_axi_arid   ;
  logic [14:0] bram_a_s_axi_araddr ;
  logic [7:0]  bram_a_s_axi_arlen  ;
  logic [2:0]  bram_a_s_axi_arsize ;
  logic [1:0]  bram_a_s_axi_arburst;
  logic        bram_a_s_axi_arlock ;
  logic [3:0]  bram_a_s_axi_arcache; 
  logic [2:0]  bram_a_s_axi_arprot ;
  logic        bram_a_s_axi_arvalid;
  logic        bram_a_s_axi_arready; 
  logic [0:0]  bram_a_s_axi_rid    ;
  logic [31:0] bram_a_s_axi_rdata  ;
  logic [1:0]  bram_a_s_axi_rresp  ;
  logic        bram_a_s_axi_rlast  ;
  logic        bram_a_s_axi_rvalid ;
  logic        bram_a_s_axi_rready ;

  logic        bram_b_s_axi_aclk   ;
  logic        bram_b_s_axi_aresetn; 
  logic [0:0]  bram_b_s_axi_awid   ;
  logic [14:0] bram_b_s_axi_awaddr ;
  logic [7:0]  bram_b_s_axi_awlen  ;
  logic [2:0]  bram_b_s_axi_awsize ;
  logic [1:0]  bram_b_s_axi_awburst;
  logic        bram_b_s_axi_awlock ;
  logic [3:0]  bram_b_s_axi_awcache;
  logic [2:0]  bram_b_s_axi_awprot ;
  logic        bram_b_s_axi_awvalid; 
  logic        bram_b_s_axi_awready;
  logic [31:0] bram_b_s_axi_wdata  ;
  logic [3:0]  bram_b_s_axi_wstrb  ;
  logic        bram_b_s_axi_wlast  ;
  logic        bram_b_s_axi_wvalid ;
  logic        bram_b_s_axi_wready ;
  logic [0:0]  bram_b_s_axi_bid    ;
  logic [1:0]  bram_b_s_axi_bresp  ;
  logic        bram_b_s_axi_bvalid ;
  logic        bram_b_s_axi_bready ;
  logic [0:0]  bram_b_s_axi_arid   ;
  logic [14:0] bram_b_s_axi_araddr ;
  logic [7:0]  bram_b_s_axi_arlen  ;
  logic [2:0]  bram_b_s_axi_arsize ;
  logic [1:0]  bram_b_s_axi_arburst;
  logic        bram_b_s_axi_arlock ;
  logic [3:0]  bram_b_s_axi_arcache; 
  logic [2:0]  bram_b_s_axi_arprot ;
  logic        bram_b_s_axi_arvalid;
  logic        bram_b_s_axi_arready; 
  logic [0:0]  bram_b_s_axi_rid    ;
  logic [31:0] bram_b_s_axi_rdata  ;
  logic [1:0]  bram_b_s_axi_rresp  ;
  logic        bram_b_s_axi_rlast  ;
  logic        bram_b_s_axi_rvalid ;
  logic        bram_b_s_axi_rready ;
  
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

   logic [31:0]   m_axis_mm2s_tdata ;
   logic [3:0]    m_axis_mm2s_tkeep ;
   logic          m_axis_mm2s_tvalid;
   logic          m_axis_mm2s_tready;
   logic          m_axis_mm2s_tlast ;
   logic [3:0]    m_axis_mm2s_tuser ;
   logic [4:0]    m_axis_mm2s_tid   ;
   logic [4:0]    m_axis_mm2s_tdest ;

   logic [31:0]   s_axis_s2mm_tdata ;
   logic [3:0]    s_axis_s2mm_tkeep ;
   logic          s_axis_s2mm_tvalid; 
   logic          s_axis_s2mm_tready; 
   logic          s_axis_s2mm_tlast ;
   logic [3:0]    s_axis_s2mm_tuser ;
   logic [4:0]    s_axis_s2mm_tid   ;
   logic [4:0]    s_axis_s2mm_tdest ;

   assign s_axis_s2mm_tdata  = m_axis_mm2s_tdata;
   assign s_axis_s2mm_tkeep  = m_axis_mm2s_tkeep;
   assign s_axis_s2mm_tvalid = m_axis_mm2s_tvalid;
   assign s_axis_s2mm_tlast  = m_axis_mm2s_tlast;
   assign m_axis_mm2s_tready = s_axis_s2mm_tready;
           
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
    .m_axi_mm2s_araddr      (m_axi_mm2s_araddr ),
    .m_axi_mm2s_arlen       (m_axi_mm2s_arlen  ),
    .m_axi_mm2s_arsize      (m_axi_mm2s_arsize ),
    .m_axi_mm2s_arburst     (m_axi_mm2s_arburst),
    .m_axi_mm2s_arprot      (m_axi_mm2s_arprot ),
    .m_axi_mm2s_arcache     (m_axi_mm2s_arcache),
    //.m_axi_mm2s_aruser      (),
    .m_axi_mm2s_arvalid     (m_axi_mm2s_arvalid),
    .m_axi_mm2s_arready     (m_axi_mm2s_arready),
    .m_axi_mm2s_rdata       (m_axi_mm2s_rdata  ),
    .m_axi_mm2s_rresp       (m_axi_mm2s_rresp  ),
    .m_axi_mm2s_rlast       (m_axi_mm2s_rlast  ),
    .m_axi_mm2s_rvalid      (m_axi_mm2s_rvalid ),
    .m_axi_mm2s_rready      (m_axi_mm2s_rready ),
    .mm2s_prmry_reset_out_n (),
    
    .m_axis_mm2s_tdata      (m_axis_mm2s_tdata ),
    .m_axis_mm2s_tkeep      (m_axis_mm2s_tkeep ),
    .m_axis_mm2s_tvalid     (m_axis_mm2s_tvalid),
    .m_axis_mm2s_tready     (m_axis_mm2s_tready),
    .m_axis_mm2s_tlast      (m_axis_mm2s_tlast ),
    //.m_axis_mm2s_tuser      (),
    //.m_axis_mm2s_tid        (),
    //.m_axis_mm2s_tdest      (),
    //.mm2s_cntrl_reset_out_n (),
          
    .m_axi_s2mm_awaddr      (m_axi_s2mm_awaddr  ),
    .m_axi_s2mm_awlen       (m_axi_s2mm_awlen   ),
    .m_axi_s2mm_awsize      (m_axi_s2mm_awsize  ),
    .m_axi_s2mm_awburst     (m_axi_s2mm_awburst ),
    .m_axi_s2mm_awprot      (m_axi_s2mm_awprot  ),
    .m_axi_s2mm_awcache     (m_axi_s2mm_awcache ),
    //.m_axi_s2mm_awuser    (),
    .m_axi_s2mm_awvalid     (m_axi_s2mm_awvalid ),
    .m_axi_s2mm_awready     (m_axi_s2mm_awready ),
    .m_axi_s2mm_wdata       (m_axi_s2mm_wdata   ),
    .m_axi_s2mm_wstrb       (m_axi_s2mm_wstrb   ),
    .m_axi_s2mm_wlast       (m_axi_s2mm_wlast   ),
    .m_axi_s2mm_wvalid      (m_axi_s2mm_wvalid  ),
    .m_axi_s2mm_wready      (m_axi_s2mm_wready  ),
    .m_axi_s2mm_bresp       (m_axi_s2mm_bresp   ),
    .m_axi_s2mm_bvalid      (m_axi_s2mm_bvalid  ),
    .m_axi_s2mm_bready      (m_axi_s2mm_bready  ),
    .s2mm_prmry_reset_out_n (m_axi_s2mm_bready  ),
    
    .s_axis_s2mm_tdata      (s_axis_s2mm_tdata ),
    .s_axis_s2mm_tkeep      (s_axis_s2mm_tkeep ),
    .s_axis_s2mm_tvalid     (s_axis_s2mm_tvalid),
    .s_axis_s2mm_tready     (s_axis_s2mm_tready),
    .s_axis_s2mm_tlast      (s_axis_s2mm_tlast ),
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

  blk_mem_gen_0 bram_a (
    .rsta_busy     (                    ),         
    .rstb_busy     (                    ),         
    .s_aclk        (clk                 ),               
    .s_aresetn     (resetn              ),         
    .s_axi_awid    (bram_a_s_axi_awid   ),       
    .s_axi_awaddr  (bram_a_s_axi_awaddr ),   
    .s_axi_awlen   (bram_a_s_axi_awlen  ),     
    .s_axi_awsize  (bram_a_s_axi_awsize ),   
    .s_axi_awburst (bram_a_s_axi_awburst), 
    .s_axi_awvalid (bram_a_s_axi_awvalid), 
    .s_axi_awready (bram_a_s_axi_awready), 
    .s_axi_wdata   (bram_a_s_axi_wdata  ),     
    .s_axi_wstrb   (bram_a_s_axi_wstrb  ),     
    .s_axi_wlast   (bram_a_s_axi_wlast  ),     
    .s_axi_wvalid  (bram_a_s_axi_wvalid ),   
    .s_axi_wready  (bram_a_s_axi_wready ),   
    .s_axi_bid     (bram_a_s_axi_bid    ),         
    .s_axi_bresp   (bram_a_s_axi_bresp  ),     
    .s_axi_bvalid  (bram_a_s_axi_bvalid ),   
    .s_axi_bready  (bram_a_s_axi_bready ),   
    .s_axi_arid    (bram_a_s_axi_arid   ),       
    .s_axi_araddr  (bram_a_s_axi_araddr ),   
    .s_axi_arlen   (bram_a_s_axi_arlen  ),     
    .s_axi_arsize  (bram_a_s_axi_arsize ),   
    .s_axi_arburst (bram_a_s_axi_arburst), 
    .s_axi_arvalid (bram_a_s_axi_arvalid), 
    .s_axi_arready (bram_a_s_axi_arready), 
    .s_axi_rid     (bram_a_s_axi_rid    ),         
    .s_axi_rdata   (bram_a_s_axi_rdata  ),     
    .s_axi_rresp   (bram_a_s_axi_rresp  ),     
    .s_axi_rlast   (bram_a_s_axi_rlast  ),     
    .s_axi_rvalid  (bram_a_s_axi_rvalid ),   
    .s_axi_rready  (bram_a_s_axi_rready )    
  );

  blk_mem_gen_1 bram_b (
    .rsta_busy     (                    ),         
    .rstb_busy     (                    ),         
    .s_aclk        (clk                 ),               
    .s_aresetn     (resetn              ),         
    .s_axi_awid    (bram_b_s_axi_awid   ),       
    .s_axi_awaddr  (bram_b_s_axi_awaddr ),   
    .s_axi_awlen   (bram_b_s_axi_awlen  ),     
    .s_axi_awsize  (bram_b_s_axi_awsize ),   
    .s_axi_awburst (bram_b_s_axi_awburst), 
    .s_axi_awvalid (bram_b_s_axi_awvalid), 
    .s_axi_awready (bram_b_s_axi_awready), 
    .s_axi_wdata   (bram_b_s_axi_wdata  ),     
    .s_axi_wstrb   (bram_b_s_axi_wstrb  ),     
    .s_axi_wlast   (bram_b_s_axi_wlast  ),     
    .s_axi_wvalid  (bram_b_s_axi_wvalid ),   
    .s_axi_wready  (bram_b_s_axi_wready ),   
    .s_axi_bid     (bram_b_s_axi_bid    ),         
    .s_axi_bresp   (bram_b_s_axi_bresp  ),     
    .s_axi_bvalid  (bram_b_s_axi_bvalid ),   
    .s_axi_bready  (bram_b_s_axi_bready ),   
    .s_axi_arid    (bram_b_s_axi_arid   ),       
    .s_axi_araddr  (bram_b_s_axi_araddr ),   
    .s_axi_arlen   (bram_b_s_axi_arlen  ),     
    .s_axi_arsize  (bram_b_s_axi_arsize ),   
    .s_axi_arburst (bram_b_s_axi_arburst), 
    .s_axi_arvalid (bram_b_s_axi_arvalid), 
    .s_axi_arready (bram_b_s_axi_arready), 
    .s_axi_rid     (bram_b_s_axi_rid    ),         
    .s_axi_rdata   (bram_b_s_axi_rdata  ),     
    .s_axi_rresp   (bram_b_s_axi_rresp  ),     
    .s_axi_rlast   (bram_b_s_axi_rlast  ),     
    .s_axi_rvalid  (bram_b_s_axi_rvalid ),   
    .s_axi_rready  (bram_b_s_axi_rready )    
  );
    
  dma_sim_axi_routing u_dma_routing
  (
    .aclk_0             (clk                 ),
    .aresetn_0          (resetn              ),
    
    .M00_AXI_0_araddr   (bram_a_s_axi_araddr ),
    .M00_AXI_0_arburst  (bram_a_s_axi_arburst),
    .M00_AXI_0_arcache  (bram_a_s_axi_arcache),
    .M00_AXI_0_arlen    (bram_a_s_axi_arlen  ),
    .M00_AXI_0_arlock   (bram_a_s_axi_arlock ),
    .M00_AXI_0_arprot   (bram_a_s_axi_arprot ),
    .M00_AXI_0_arqos    (),
    .M00_AXI_0_arready  (bram_a_s_axi_arready),
    .M00_AXI_0_arsize   (bram_a_s_axi_arsize ),
    .M00_AXI_0_arvalid  (bram_a_s_axi_arvalid),
    .M00_AXI_0_awaddr   (bram_a_s_axi_awaddr ),
    .M00_AXI_0_awburst  (bram_a_s_axi_awburst),
    .M00_AXI_0_awcache  (bram_a_s_axi_awcache),
    .M00_AXI_0_awlen    (bram_a_s_axi_awlen  ),
    .M00_AXI_0_awlock   (bram_a_s_axi_awlock ),
    .M00_AXI_0_awprot   (bram_a_s_axi_awprot ),
    .M00_AXI_0_awqos    (),
    .M00_AXI_0_awready  (bram_a_s_axi_awready),
    .M00_AXI_0_awsize   (bram_a_s_axi_awsize ),
    .M00_AXI_0_awvalid  (bram_a_s_axi_awvalid),
    .M00_AXI_0_bready   (bram_a_s_axi_bready ),
    .M00_AXI_0_bresp    (bram_a_s_axi_bresp  ),
    .M00_AXI_0_bvalid   (bram_a_s_axi_bvalid ),
    .M00_AXI_0_rdata    (bram_a_s_axi_rdata  ),
    .M00_AXI_0_rlast    (bram_a_s_axi_rlast  ),
    .M00_AXI_0_rready   (bram_a_s_axi_rready ),
    .M00_AXI_0_rresp    (bram_a_s_axi_rresp  ),
    .M00_AXI_0_rvalid   (bram_a_s_axi_rvalid ),
    .M00_AXI_0_wdata    (bram_a_s_axi_wdata  ),
    .M00_AXI_0_wlast    (bram_a_s_axi_wlast  ),
    .M00_AXI_0_wready   (bram_a_s_axi_wready ),
    .M00_AXI_0_wstrb    (bram_a_s_axi_wstrb  ),
    .M00_AXI_0_wvalid   (bram_a_s_axi_wvalid ),
    
    .M01_AXI_0_araddr   (bram_b_s_axi_araddr ),
    .M01_AXI_0_arburst  (bram_b_s_axi_arburst),
    .M01_AXI_0_arcache  (bram_b_s_axi_arcache),
    .M01_AXI_0_arlen    (bram_b_s_axi_arlen  ),
    .M01_AXI_0_arlock   (bram_b_s_axi_arlock ),
    .M01_AXI_0_arprot   (),
    .M01_AXI_0_arqos    (bram_b_s_axi_arqos  ),
    .M01_AXI_0_arready  (bram_b_s_axi_arready),
    .M01_AXI_0_arsize   (bram_b_s_axi_arsize ),
    .M01_AXI_0_arvalid  (bram_b_s_axi_arvalid),
    .M01_AXI_0_awaddr   (bram_b_s_axi_awaddr ),
    .M01_AXI_0_awburst  (bram_b_s_axi_awburst),
    .M01_AXI_0_awcache  (bram_b_s_axi_awcache),
    .M01_AXI_0_awlen    (bram_b_s_axi_awlen  ),
    .M01_AXI_0_awlock   (bram_b_s_axi_awlock ),
    .M01_AXI_0_awprot   (bram_b_s_axi_awprot ),
    .M01_AXI_0_awqos    (),
    .M01_AXI_0_awready  (bram_b_s_axi_awready),
    .M01_AXI_0_awsize   (bram_b_s_axi_awsize ),
    .M01_AXI_0_awvalid  (bram_b_s_axi_awvalid),
    .M01_AXI_0_bready   (bram_b_s_axi_bready ),
    .M01_AXI_0_bresp    (bram_b_s_axi_bresp  ),
    .M01_AXI_0_bvalid   (bram_b_s_axi_bvalid ),
    .M01_AXI_0_rdata    (bram_b_s_axi_rdata  ),
    .M01_AXI_0_rlast    (bram_b_s_axi_rlast  ),
    .M01_AXI_0_rready   (bram_b_s_axi_rready ),
    .M01_AXI_0_rresp    (bram_b_s_axi_rresp  ),
    .M01_AXI_0_rvalid   (bram_b_s_axi_rvalid ),
    .M01_AXI_0_wdata    (bram_b_s_axi_wdata  ),
    .M01_AXI_0_wlast    (bram_b_s_axi_wlast  ),
    .M01_AXI_0_wready   (bram_b_s_axi_wready ),
    .M01_AXI_0_wstrb    (bram_b_s_axi_wstrb  ),
    .M01_AXI_0_wvalid   (bram_b_s_axi_wvalid ),

    .MM2S_AXI_araddr  (m_axi_mm2s_araddr     ),
    .MM2S_AXI_arburst (m_axi_mm2s_arburst    ),
    .MM2S_AXI_arcache (m_axi_mm2s_arcache    ),
    .MM2S_AXI_arlen   (m_axi_mm2s_arlen      ),
    .MM2S_AXI_arlock  ('0                    ),
    .MM2S_AXI_arprot  (m_axi_mm2s_arprot     ),
    .MM2S_AXI_arqos   ('0                    ),
    .MM2S_AXI_arready (m_axi_mm2s_arready    ),
    .MM2S_AXI_arsize  (m_axi_mm2s_arsize     ),
    .MM2S_AXI_arvalid (m_axi_mm2s_arvalid    ),
    .MM2S_AXI_awaddr  ('0                    ),
    .MM2S_AXI_awburst ('0                    ),
    .MM2S_AXI_awcache ('0                    ),
    .MM2S_AXI_awlen   ('0                    ),
    .MM2S_AXI_awlock  ('0                    ),
    .MM2S_AXI_awprot  ('0                    ),
    .MM2S_AXI_awqos   ('0                    ),
    .MM2S_AXI_awready (                      ),
    .MM2S_AXI_awsize  ('0                    ),
    .MM2S_AXI_awvalid ('0                    ),
    .MM2S_AXI_bready  ('1                    ),
    .MM2S_AXI_bresp   (                      ),
    .MM2S_AXI_bvalid  (                      ),
    .MM2S_AXI_rdata   (m_axi_mm2s_rdata      ),
    .MM2S_AXI_rlast   (m_axi_mm2s_rlast      ),
    .MM2S_AXI_rready  (m_axi_mm2s_rready     ),
    .MM2S_AXI_rresp   (m_axi_mm2s_rresp      ),
    .MM2S_AXI_rvalid  (m_axi_mm2s_rvalid     ),
    .MM2S_AXI_wdata   ('0                    ),
    .MM2S_AXI_wlast   ('0                    ),
    .MM2S_AXI_wready  (                      ),
    .MM2S_AXI_wstrb   ('0                    ),
    .MM2S_AXI_wvalid  ('0                    ),

    .S2MM_AXI_araddr  ('0                    ),
    .S2MM_AXI_arburst ('0                    ),
    .S2MM_AXI_arcache ('0                    ),
    .S2MM_AXI_arlen   ('0                    ),
    .S2MM_AXI_arlock  ('0                    ),
    .S2MM_AXI_arprot  ('0                    ),
    .S2MM_AXI_arqos   ('0                    ),
    .S2MM_AXI_arready (                      ),
    .S2MM_AXI_arsize  ('0                    ),
    .S2MM_AXI_arvalid ('0                    ),
    .S2MM_AXI_awaddr  (m_axi_s2mm_awaddr     ),
    .S2MM_AXI_awburst (m_axi_s2mm_awburst    ),
    .S2MM_AXI_awcache (m_axi_s2mm_awcache    ),
    .S2MM_AXI_awlen   (m_axi_s2mm_awlen      ),
    .S2MM_AXI_awlock  ('0                    ),
    .S2MM_AXI_awprot  (m_axi_s2mm_awprot     ),
    .S2MM_AXI_awqos   ('0                    ),
    .S2MM_AXI_awready (m_axi_s2mm_awready    ),
    .S2MM_AXI_awsize  (m_axi_s2mm_awsize     ),
    .S2MM_AXI_awvalid (m_axi_s2mm_awvalid    ),
    .S2MM_AXI_bready  (m_axi_s2mm_bvalid     ),
    .S2MM_AXI_bresp   (m_axi_s2mm_bresp      ),
    .S2MM_AXI_bvalid  (m_axi_s2mm_bvalid     ),
    .S2MM_AXI_rdata   (                      ),
    .S2MM_AXI_rlast   (                      ),
    .S2MM_AXI_rready  ('1                    ),
    .S2MM_AXI_rresp   (                      ),
    .S2MM_AXI_rvalid  (                      ),
    .S2MM_AXI_wdata   (m_axi_s2mm_wdata      ),
    .S2MM_AXI_wlast   (m_axi_s2mm_wlast      ),
    .S2MM_AXI_wready  (m_axi_s2mm_wready     ),
    .S2MM_AXI_wstrb   (m_axi_s2mm_wstrb      ),
    .S2MM_AXI_wvalid  (m_axi_s2mm_wvalid     )
  );

                        
endmodule