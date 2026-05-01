vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_22
vlib questa_lib/msim/processing_system7_vip_v1_0_24
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/util_vector_logic_v2_0_5
vlib questa_lib/msim/axi_datamover_v5_1_37
vlib questa_lib/msim/axi_sg_v4_1_21
vlib questa_lib/msim/axi_dma_v7_1_37
vlib questa_lib/msim/proc_sys_reset_v5_0_17
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_register_slice_v2_1_36

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_22 questa_lib/msim/axi_vip_v1_1_22
vmap processing_system7_vip_v1_0_24 questa_lib/msim/processing_system7_vip_v1_0_24
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap util_vector_logic_v2_0_5 questa_lib/msim/util_vector_logic_v2_0_5
vmap axi_datamover_v5_1_37 questa_lib/msim/axi_datamover_v5_1_37
vmap axi_sg_v4_1_21 questa_lib/msim/axi_sg_v4_1_21
vmap axi_dma_v7_1_37 questa_lib/msim/axi_dma_v7_1_37
vmap proc_sys_reset_v5_0_17 questa_lib/msim/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_register_slice_v2_1_36 questa_lib/msim/axi_register_slice_v2_1_36

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"/opt/2025.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/opt/2025.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"/opt/2025.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/2025.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/opt/2025.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/opt/2025.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_24 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_processing_system7_0_0/sim/coraz7_zynq_ps_processing_system7_0_0.v" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_clk_wiz_0_0/coraz7_zynq_ps_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_clk_wiz_0_0/coraz7_zynq_ps_clk_wiz_0_0.v" \

vlog -work util_vector_logic_v2_0_5 -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/e056/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_util_vector_logic_0_0/sim/coraz7_zynq_ps_util_vector_logic_0_0.v" \

vcom -work axi_datamover_v5_1_37 -64 -93  \
"../../../../../../bd/coraz7_zynq_ps/ipshared/d44a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_21 -64 -93  \
"../../../../../../bd/coraz7_zynq_ps/ipshared/b193/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_37 -64 -93  \
"../../../../../../bd/coraz7_zynq_ps/ipshared/7f6a/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_axi_dma_0_0_1/sim/coraz7_zynq_ps_axi_dma_0_0.vhd" \

vcom -work proc_sys_reset_v5_0_17 -64 -93  \
"../../../../../../bd/coraz7_zynq_ps/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_1/sim/bd_c428_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/3d9a/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_2/sim/bd_c428_s00mmu_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/7785/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_3/sim/bd_c428_s00tr_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/3051/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_4/sim/bd_c428_s00sic_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/852f/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_5/sim/bd_c428_s00a2s_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_6/sim/bd_c428_sarn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_7/sim/bd_c428_srn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_8/sim/bd_c428_sawn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_9/sim/bd_c428_swn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_10/sim/bd_c428_sbn_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/fca9/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_11/sim/bd_c428_m00s2a_0.sv" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/e44a/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/ip/ip_12/sim/bd_c428_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/bd_0/sim/bd_c428.v" \

vcom -work smartconnect_v1_0 -64 -93  \
"../../../../../../bd/coraz7_zynq_ps/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.vhd" \

vlog -work smartconnect_v1_0 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.sv" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/0848/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work axi_register_slice_v2_1_36 -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../../../../bd/coraz7_zynq_ps/ipshared/bc4b/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_0_0_1/sim/coraz7_zynq_ps_smartconnect_0_0.sv" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_1/sim/bd_0479_psr_aclk_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_2/sim/bd_0479_s00mmu_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_3/sim/bd_0479_s00tr_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_4/sim/bd_0479_s00sic_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_5/sim/bd_0479_s00a2s_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_6/sim/bd_0479_sarn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_7/sim/bd_0479_srn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_8/sim/bd_0479_m00s2a_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/ip/ip_9/sim/bd_0479_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/bd_0/sim/bd_0479.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_1_0_1/sim/coraz7_zynq_ps_smartconnect_1_0.sv" \

vcom -work xil_defaultlib -64 -93  \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_1/sim/bd_0489_psr_aclk_0.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_2/sim/bd_0489_s00mmu_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_3/sim/bd_0489_s00tr_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_4/sim/bd_0489_s00sic_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_5/sim/bd_0489_s00a2s_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_6/sim/bd_0489_sawn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_7/sim/bd_0489_swn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_8/sim/bd_0489_sbn_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_9/sim/bd_0489_m00s2a_0.sv" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/ip/ip_10/sim/bd_0489_m00e_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/bd_0/sim/bd_0489.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L smartconnect_v1_0 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/ip/coraz7_zynq_ps_smartconnect_2_0_1/sim/coraz7_zynq_ps_smartconnect_2_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/ec67/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/9a25/hdl" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/a415" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/f0b6/hdl/verilog" "+incdir+../../../../../../bd/coraz7_zynq_ps/ipshared/00fe/hdl/verilog" "+incdir+../../../../../../../../../../../opt/2025.2/data/rsb/busdef" "+incdir+/opt/2025.2/data/xilinx_vip/include" \
"../../../bd/coraz7_zynq_ps/sim/coraz7_zynq_ps.v" \

vlog -work xil_defaultlib \
"glbl.v"

