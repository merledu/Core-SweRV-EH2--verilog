
module eh2_swerv
import eh2_pkg::*;
#(
`include "eh2_param.vh"
) (
   input wire clk,
   input wire rst_l,
   input wire dbg_rst_l,
   input wire [31:1]           rst_vec,
   input wire nmi_int,
   input wire [31:1]           nmi_vec,
   output logic                 core_rst_l,   
   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_insn_ip,
   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_address_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_valid_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_exception_ip,
   output logic [pt.NUM_THREADS-1:0] [4:0]  trace_rv_i_ecause_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_interrupt_ip,
   output logic [pt.NUM_THREADS-1:0] [31:0] trace_rv_i_tval_ip,

   output logic                 dccm_clk_override,
   output logic                 icm_clk_override,
   output logic                 dec_tlu_core_ecc_disable,

   output logic [pt.NUM_THREADS-1:0] dec_tlu_mhartstart, 
      input wire [pt.NUM_THREADS-1:0] i_cpu_halt_req,       input wire [pt.NUM_THREADS-1:0] i_cpu_run_req,        output logic [pt.NUM_THREADS-1:0] o_cpu_halt_status,    output logic [pt.NUM_THREADS-1:0] o_cpu_halt_ack,       output logic [pt.NUM_THREADS-1:0] o_cpu_run_ack,        output logic [pt.NUM_THREADS-1:0] o_debug_mode_status, 
   input wire [31:4]     core_id, 
      input wire [pt.NUM_THREADS-1:0] mpc_debug_halt_req,    input wire [pt.NUM_THREADS-1:0] mpc_debug_run_req,    input wire [pt.NUM_THREADS-1:0] mpc_reset_run_req,    output logic [pt.NUM_THREADS-1:0] mpc_debug_halt_ack,    output logic [pt.NUM_THREADS-1:0] mpc_debug_run_ack,    output logic [pt.NUM_THREADS-1:0] debug_brkpt_status, 
   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt0,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt1,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt2,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt3, 
      output logic                           dccm_wren,
   output logic                           dccm_rden,
   output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_lo,
   output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_hi,
   output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_lo,
   output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_hi,
   output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_wr_data_lo,
   output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_wr_data_hi,

   input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo,
   input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi,

      output logic [pt.ICCM_BITS-1:1]  iccm_rw_addr,
   output logic [pt.NUM_THREADS-1:0]iccm_buf_correct_ecc_thr,                   output logic                     iccm_correction_state,                  output logic                     iccm_stop_fetch,                        output logic                     iccm_corr_scnd_fetch,                   output logic                  ifc_select_tid_f1,
   output logic                  iccm_wren,
   output logic                  iccm_rden,
   output logic [2:0]            iccm_wr_size,
   output logic [77:0]           iccm_wr_data,

   input wire [63:0]           iccm_rd_data,
   input wire [116:0]          iccm_rd_data_ecc,

      output logic [31:1]           ic_rw_addr,
   output logic [pt.ICACHE_NUM_WAYS-1:0]            ic_tag_valid,
   output logic [pt.ICACHE_NUM_WAYS-1:0]          ic_wr_en  ,            output logic                  ic_rd_en,

   output logic [pt.ICACHE_BANKS_WAY-1:0] [70:0]               ic_wr_data,              input wire [63:0]               ic_rd_data ,             input wire [70:0]               ic_debug_rd_data ,       input wire [25:0]               ictag_debug_rd_data,     output logic [70:0]               ic_debug_wr_data,     
   input wire [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr,       input wire [pt.ICACHE_BANKS_WAY-1:0] ic_parerr,


   output logic [63:0]               ic_premux_data,        output logic                      ic_sel_premux_data, 

   output logic [pt.ICACHE_INDEX_HI:3]            ic_debug_addr,         output logic                      ic_debug_rd_en,        output logic                      ic_debug_wr_en,        output logic                      ic_debug_tag_array,    output logic [pt.ICACHE_NUM_WAYS-1:0]          ic_debug_way,       

   input wire [pt.ICACHE_NUM_WAYS-1:0]            ic_rd_hit,
   input wire ic_tag_perr,        
         output logic                            lsu_axi_awvalid,
   input wire lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_awid,
   output logic [31:0]                     lsu_axi_awaddr,
   output logic [3:0]                      lsu_axi_awregion,
   output logic [7:0]                      lsu_axi_awlen,
   output logic [2:0]                      lsu_axi_awsize,
   output logic [1:0]                      lsu_axi_awburst,
   output logic                            lsu_axi_awlock,
   output logic [3:0]                      lsu_axi_awcache,
   output logic [2:0]                      lsu_axi_awprot,
   output logic [3:0]                      lsu_axi_awqos,

   output logic                            lsu_axi_wvalid,
   input wire lsu_axi_wready,
   output logic [63:0]                     lsu_axi_wdata,
   output logic [7:0]                      lsu_axi_wstrb,
   output logic                            lsu_axi_wlast,

   input wire lsu_axi_bvalid,
   output logic                            lsu_axi_bready,
   input wire [1:0]                      lsu_axi_bresp,
   input wire [pt.LSU_BUS_TAG-1:0]       lsu_axi_bid,

      output logic                            lsu_axi_arvalid,
   input wire lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_arid,
   output logic [31:0]                     lsu_axi_araddr,
   output logic [3:0]                      lsu_axi_arregion,
   output logic [7:0]                      lsu_axi_arlen,
   output logic [2:0]                      lsu_axi_arsize,
   output logic [1:0]                      lsu_axi_arburst,
   output logic                            lsu_axi_arlock,
   output logic [3:0]                      lsu_axi_arcache,
   output logic [2:0]                      lsu_axi_arprot,
   output logic [3:0]                      lsu_axi_arqos,

   input wire lsu_axi_rvalid,
   output logic                            lsu_axi_rready,
   input wire [pt.LSU_BUS_TAG-1:0]       lsu_axi_rid,
   input wire [63:0]                     lsu_axi_rdata,
   input wire [1:0]                      lsu_axi_rresp,
   input wire lsu_axi_rlast,

         output logic                            ifu_axi_awvalid,
   input wire ifu_axi_awready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_awid,
   output logic [31:0]                     ifu_axi_awaddr,
   output logic [3:0]                      ifu_axi_awregion,
   output logic [7:0]                      ifu_axi_awlen,
   output logic [2:0]                      ifu_axi_awsize,
   output logic [1:0]                      ifu_axi_awburst,
   output logic                            ifu_axi_awlock,
   output logic [3:0]                      ifu_axi_awcache,
   output logic [2:0]                      ifu_axi_awprot,
   output logic [3:0]                      ifu_axi_awqos,

   output logic                            ifu_axi_wvalid,
   input wire ifu_axi_wready,
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   input wire ifu_axi_bvalid,
   output logic                            ifu_axi_bready,
   input wire [1:0]                      ifu_axi_bresp,
   input wire [pt.IFU_BUS_TAG-1:0]       ifu_axi_bid,

      output logic                            ifu_axi_arvalid,
   input wire ifu_axi_arready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_arid,
   output logic [31:0]                     ifu_axi_araddr,
   output logic [3:0]                      ifu_axi_arregion,
   output logic [7:0]                      ifu_axi_arlen,
   output logic [2:0]                      ifu_axi_arsize,
   output logic [1:0]                      ifu_axi_arburst,
   output logic                            ifu_axi_arlock,
   output logic [3:0]                      ifu_axi_arcache,
   output logic [2:0]                      ifu_axi_arprot,
   output logic [3:0]                      ifu_axi_arqos,

   input wire ifu_axi_rvalid,
   output logic                            ifu_axi_rready,
   input wire [pt.IFU_BUS_TAG-1:0]       ifu_axi_rid,
   input wire [63:0]                     ifu_axi_rdata,
   input wire [1:0]                      ifu_axi_rresp,
   input wire ifu_axi_rlast,

         output logic                            sb_axi_awvalid,
   input wire sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_awid,
   output logic [31:0]                     sb_axi_awaddr,
   output logic [3:0]                      sb_axi_awregion,
   output logic [7:0]                      sb_axi_awlen,
   output logic [2:0]                      sb_axi_awsize,
   output logic [1:0]                      sb_axi_awburst,
   output logic                            sb_axi_awlock,
   output logic [3:0]                      sb_axi_awcache,
   output logic [2:0]                      sb_axi_awprot,
   output logic [3:0]                      sb_axi_awqos,

   output logic                            sb_axi_wvalid,
   input wire sb_axi_wready,
   output logic [63:0]                     sb_axi_wdata,
   output logic [7:0]                      sb_axi_wstrb,
   output logic                            sb_axi_wlast,

   input wire sb_axi_bvalid,
   output logic                            sb_axi_bready,
   input wire [1:0]                      sb_axi_bresp,
   input wire [pt.SB_BUS_TAG-1:0]        sb_axi_bid,

      output logic                            sb_axi_arvalid,
   input wire sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_arid,
   output logic [31:0]                     sb_axi_araddr,
   output logic [3:0]                      sb_axi_arregion,
   output logic [7:0]                      sb_axi_arlen,
   output logic [2:0]                      sb_axi_arsize,
   output logic [1:0]                      sb_axi_arburst,
   output logic                            sb_axi_arlock,
   output logic [3:0]                      sb_axi_arcache,
   output logic [2:0]                      sb_axi_arprot,
   output logic [3:0]                      sb_axi_arqos,

   input wire sb_axi_rvalid,
   output logic                            sb_axi_rready,
   input wire [pt.SB_BUS_TAG-1:0]        sb_axi_rid,
   input wire [63:0]                     sb_axi_rdata,
   input wire [1:0]                      sb_axi_rresp,
   input wire sb_axi_rlast,

         input wire dma_axi_awvalid,
   output logic                         dma_axi_awready,
   input wire [pt.DMA_BUS_TAG-1:0]    dma_axi_awid,
   input wire [31:0]                  dma_axi_awaddr,
   input wire [2:0]                   dma_axi_awsize,
   input wire [2:0]                   dma_axi_awprot,
   input wire [7:0]                   dma_axi_awlen,
   input wire [1:0]                   dma_axi_awburst,


   input wire dma_axi_wvalid,
   output logic                         dma_axi_wready,
   input wire [63:0]                  dma_axi_wdata,
   input wire [7:0]                   dma_axi_wstrb,
   input wire dma_axi_wlast,

   output logic                         dma_axi_bvalid,
   input wire dma_axi_bready,
   output logic [1:0]                   dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_bid,

      input wire dma_axi_arvalid,
   output logic                         dma_axi_arready,
   input wire [pt.DMA_BUS_TAG-1:0]    dma_axi_arid,
   input wire [31:0]                  dma_axi_araddr,
   input wire [2:0]                   dma_axi_arsize,
   input wire [2:0]                   dma_axi_arprot,
   input wire [7:0]                   dma_axi_arlen,
   input wire [1:0]                   dma_axi_arburst,

   output logic                         dma_axi_rvalid,
   input wire dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_rid,
   output logic [63:0]                  dma_axi_rdata,
   output logic [1:0]                   dma_axi_rresp,
   output logic                         dma_axi_rlast,

       output logic [31:0]           haddr,
   output logic [2:0]            hburst,
   output logic                  hmastlock,
   output logic [3:0]            hprot,
   output logic [2:0]            hsize,
   output logic [1:0]            htrans,
   output logic                  hwrite,

   input wire [63:0]           hrdata,
   input wire hready,
   input wire hresp,

      output logic [31:0]          lsu_haddr,
   output logic [2:0]           lsu_hburst,
   output logic                 lsu_hmastlock,
   output logic [3:0]           lsu_hprot,
   output logic [2:0]           lsu_hsize,
   output logic [1:0]           lsu_htrans,
   output logic                 lsu_hwrite,
   output logic [63:0]          lsu_hwdata,

   input wire [63:0]          lsu_hrdata,
   input wire lsu_hready,
   input wire lsu_hresp,

      output logic [31:0]          sb_haddr,
   output logic [2:0]           sb_hburst,
   output logic                 sb_hmastlock,
   output logic [3:0]           sb_hprot,
   output logic [2:0]           sb_hsize,
   output logic [1:0]           sb_htrans,
   output logic                 sb_hwrite,
   output logic [63:0]          sb_hwdata,

   input wire [63:0]          sb_hrdata,
   input wire sb_hready,
   input wire sb_hresp,

      input wire [31:0]            dma_haddr,
   input wire [2:0]             dma_hburst,
   input wire dma_hmastlock,
   input wire [3:0]             dma_hprot,
   input wire [2:0]             dma_hsize,
   input wire [1:0]             dma_htrans,
   input wire dma_hwrite,
   input wire [63:0]            dma_hwdata,
   input wire dma_hreadyin,
   input wire dma_hsel,

   output  logic [63:0]          dma_hrdata,
   output  logic                 dma_hreadyout,
   output  logic                 dma_hresp,

   input wire lsu_bus_clk_en,
   input wire ifu_bus_clk_en,
   input wire dbg_bus_clk_en,
   input wire dma_bus_clk_en,

      input wire dmi_reg_en,                   input wire [6:0]             dmi_reg_addr,                 input wire dmi_reg_wr_en,                input wire [31:0]            dmi_reg_wdata,                   output logic [31:0]            dmi_reg_rdata,
   input wire dmi_hard_reset,


   input wire [pt.PIC_TOTAL_INT:1]           extintsrc_req,
   input wire [pt.NUM_THREADS-1:0] timer_int,                                input wire [pt.NUM_THREADS-1:0] soft_int,                                input wire scan_mode
);


`define ADDRWIDTH 32

   reg [63:0]              hwdata_nc;

   reg                         lsu_axi_awready_ahb;
   reg                         lsu_axi_wready_ahb;
   reg                         lsu_axi_bvalid_ahb;
   reg                         lsu_axi_bready_ahb;
   reg [1:0]                   lsu_axi_bresp_ahb;
   reg [pt.LSU_BUS_TAG-1:0]    lsu_axi_bid_ahb;
   reg                         lsu_axi_arready_ahb;
   reg                         lsu_axi_rvalid_ahb;
   reg [pt.LSU_BUS_TAG-1:0]    lsu_axi_rid_ahb;
   reg [63:0]                  lsu_axi_rdata_ahb;
   reg [1:0]                   lsu_axi_rresp_ahb;
   reg                         lsu_axi_rlast_ahb;

   wire                         lsu_axi_awready_int;
   wire                         lsu_axi_wready_int;
   wire                         lsu_axi_bvalid_int;
   wire                         lsu_axi_bready_int;
   wire [1:0]                   lsu_axi_bresp_int;
   wire [pt.LSU_BUS_TAG-1:0]    lsu_axi_bid_int;
   wire                         lsu_axi_arready_int;
   wire                         lsu_axi_rvalid_int;
   wire [pt.LSU_BUS_TAG-1:0]    lsu_axi_rid_int;
   wire [63:0]                  lsu_axi_rdata_int;
   wire [1:0]                   lsu_axi_rresp_int;
   wire                         lsu_axi_rlast_int;

   reg                         ifu_axi_awready_ahb;
   reg                         ifu_axi_wready_ahb;
   reg                         ifu_axi_bvalid_ahb;
   reg                         ifu_axi_bready_ahb;
   reg [1:0]                   ifu_axi_bresp_ahb;
   reg [pt.IFU_BUS_TAG-1:0]    ifu_axi_bid_ahb;
   reg                         ifu_axi_arready_ahb;
   reg                         ifu_axi_rvalid_ahb;
   reg [pt.IFU_BUS_TAG-1:0]    ifu_axi_rid_ahb;
   reg [63:0]                  ifu_axi_rdata_ahb;
   reg [1:0]                   ifu_axi_rresp_ahb;
   reg                         ifu_axi_rlast_ahb;

   wire                         ifu_axi_awready_int;
   wire                         ifu_axi_wready_int;
   wire                         ifu_axi_bvalid_int;
   wire                         ifu_axi_bready_int;
   wire [1:0]                   ifu_axi_bresp_int;
   wire [pt.IFU_BUS_TAG-1:0]    ifu_axi_bid_int;
   wire                         ifu_axi_arready_int;
   wire                         ifu_axi_rvalid_int;
   wire [pt.IFU_BUS_TAG-1:0]    ifu_axi_rid_int;
   wire [63:0]                  ifu_axi_rdata_int;
   wire [1:0]                   ifu_axi_rresp_int;
   wire                         ifu_axi_rlast_int;

   reg                         sb_axi_awready_ahb;
   reg                         sb_axi_wready_ahb;
   reg                         sb_axi_bvalid_ahb;
   reg                         sb_axi_bready_ahb;
   reg [1:0]                   sb_axi_bresp_ahb;
   reg [pt.SB_BUS_TAG-1:0]     sb_axi_bid_ahb;
   reg                         sb_axi_arready_ahb;
   reg                         sb_axi_rvalid_ahb;
   reg [pt.SB_BUS_TAG-1:0]     sb_axi_rid_ahb;
   reg [63:0]                  sb_axi_rdata_ahb;
   reg [1:0]                   sb_axi_rresp_ahb;
   reg                         sb_axi_rlast_ahb;

   wire                         sb_axi_awready_int;
   wire                         sb_axi_wready_int;
   wire                         sb_axi_bvalid_int;
   wire                         sb_axi_bready_int;
   wire [1:0]                   sb_axi_bresp_int;
   wire [pt.SB_BUS_TAG-1:0]     sb_axi_bid_int;
   wire                         sb_axi_arready_int;
   wire                         sb_axi_rvalid_int;
   wire [pt.SB_BUS_TAG-1:0]     sb_axi_rid_int;
   wire [63:0]                  sb_axi_rdata_int;
   wire [1:0]                   sb_axi_rresp_int;
   wire                         sb_axi_rlast_int;

   reg                         dma_axi_awvalid_ahb;
   reg [pt.DMA_BUS_TAG-1:0]    dma_axi_awid_ahb;
   reg [31:0]                  dma_axi_awaddr_ahb;
   reg [2:0]                   dma_axi_awsize_ahb;
   reg [2:0]                   dma_axi_awprot_ahb;
   reg [7:0]                   dma_axi_awlen_ahb;
   reg [1:0]                   dma_axi_awburst_ahb;
   reg                         dma_axi_wvalid_ahb;
   reg [63:0]                  dma_axi_wdata_ahb;
   reg [7:0]                   dma_axi_wstrb_ahb;
   reg                         dma_axi_wlast_ahb;
   reg                         dma_axi_bready_ahb;
   reg                         dma_axi_arvalid_ahb;
   reg [pt.DMA_BUS_TAG-1:0]    dma_axi_arid_ahb;
   reg [31:0]                  dma_axi_araddr_ahb;
   reg [2:0]                   dma_axi_arsize_ahb;
   reg [2:0]                   dma_axi_arprot_ahb;
   reg [7:0]                   dma_axi_arlen_ahb;
   reg [1:0]                   dma_axi_arburst_ahb;
   reg                         dma_axi_rready_ahb;

   wire                         dma_axi_awvalid_int;
   wire [pt.DMA_BUS_TAG-1:0]    dma_axi_awid_int;
   wire [31:0]                  dma_axi_awaddr_int;
   wire [2:0]                   dma_axi_awsize_int;
   wire [2:0]                   dma_axi_awprot_int;
   wire [7:0]                   dma_axi_awlen_int;
   wire [1:0]                   dma_axi_awburst_int;
   wire                         dma_axi_wvalid_int;
   wire [63:0]                  dma_axi_wdata_int;
   wire [7:0]                   dma_axi_wstrb_int;
   wire                         dma_axi_wlast_int;
   wire                         dma_axi_bready_int;
   wire                         dma_axi_arvalid_int;
   wire [pt.DMA_BUS_TAG-1:0]    dma_axi_arid_int;
   wire [31:0]                  dma_axi_araddr_int;
   wire [2:0]                   dma_axi_arsize_int;
   wire [2:0]                   dma_axi_arprot_int;
   wire [7:0]                   dma_axi_arlen_int;
   wire [1:0]                   dma_axi_arburst_int;
   wire                         dma_axi_rready_int;

         
   reg [pt.NUM_THREADS-1:0][1:0] ifu_pmu_instr_aligned;
   reg [pt.NUM_THREADS-1:0]      ifu_pmu_align_stall;

   reg [pt.NUM_THREADS-1:0]  ifu_miss_state_idle;             reg [pt.NUM_THREADS-1:0]  ifu_ic_error_start;              reg [pt.NUM_THREADS-1:0]  ifu_iccm_rd_ecc_single_err;   
   reg [70:0]                  ifu_ic_debug_rd_data;

   reg ifu_ic_debug_rd_data_valid;    eh2_cache_debug_pkt_t dec_tlu_ic_diag_pkt;    reg [pt.NUM_THREADS-1:0] dec_tlu_i0_commit_cmt;

   reg  [31:0] gpr_i0_rs1_d;
   reg  [31:0] gpr_i0_rs2_d;
   reg  [31:0] gpr_i1_rs1_d;
   reg  [31:0] gpr_i1_rs2_d;

   reg [31:0] i0_rs1_bypass_data_d;
   reg [31:0] i0_rs2_bypass_data_d;
   reg [31:0] i1_rs1_bypass_data_d;
   reg [31:0] i1_rs2_bypass_data_d;
reg [31:0] exu_i0_result_e1;
reg [31:0] exu_i1_result_e1;
   reg [31:1] exu_i0_pc_e1;
   reg [31:1] exu_i1_pc_e1;     reg [pt.NUM_THREADS-1:0] [31:1] exu_npc_e4;

   eh2_alu_pkt_t  i0_ap, i1_ap;

      eh2_trigger_pkt_t [pt.NUM_THREADS-1:0][3:0]     trigger_pkt_any;
   reg [3:0]             lsu_trigger_match_dc4;
reg [pt.NUM_THREADS-1:0] dec_ib3_valid_d;
reg [pt.NUM_THREADS-1:0] dec_ib2_valid_d;

   reg [31:0] dec_i0_immed_d;
   reg [31:0] dec_i1_immed_d;

   reg [12:1] dec_i0_br_immed_d;
   reg [12:1] dec_i1_br_immed_d;

   reg         dec_i0_select_pc_d;
   reg         dec_i1_select_pc_d;

reg [31:1] dec_i0_pc_d;
reg [31:1] dec_i1_pc_d;
   reg        dec_i0_rs1_bypass_en_d;
   reg        dec_i0_rs2_bypass_en_d;
   reg        dec_i1_rs1_bypass_en_d;
   reg        dec_i1_rs2_bypass_en_d;


   reg         dec_i0_alu_decode_d;
   reg         dec_i1_alu_decode_d;

reg [pt.NUM_THREADS-1:0] ifu_i0_valid;
reg [pt.NUM_THREADS-1:0] ifu_i1_valid;
wire [pt.NUM_THREADS-1:0] [31:0] ifu_i0_instr;
wire [pt.NUM_THREADS-1:0] [31:0] ifu_i1_instr;
reg [pt.NUM_THREADS-1:0] [31:1] ifu_i0_pc;
reg [pt.NUM_THREADS-1:0] [31:1] ifu_i1_pc;
   reg [31:2]  dec_tlu_meihap; 
   reg [pt.NUM_THREADS-1:0]   flush_final_e3;                reg [pt.NUM_THREADS-1:0]   i0_flush_final_e3;          

   reg [pt.NUM_THREADS-1:0] [31:1] exu_flush_path_final;

   reg [31:0] exu_lsu_rs1_d;
   reg [31:0] exu_lsu_rs2_d;


   eh2_lsu_pkt_t    lsu_p;

   reg [11:0] dec_lsu_offset_d;
   reg        dec_i0_lsu_d;          reg        dec_i1_lsu_d;

   reg [pt.NUM_THREADS-1:0] dec_tlu_force_halt;

   reg [31:0]  lsu_result_dc3;
   reg [31:0]  lsu_result_corr_dc4;
   reg         lsu_sc_success_dc5;
   reg         lsu_single_ecc_error_incr;        eh2_lsu_error_pkt_t lsu_error_pkt_dc3;
   reg [pt.NUM_THREADS-1:0]        lsu_imprecise_error_load_any;
   reg [pt.NUM_THREADS-1:0]        lsu_imprecise_error_store_any;
   reg [pt.NUM_THREADS-1:0][31:0]  lsu_imprecise_error_addr_any;
   reg         lsu_fastint_stall_any;     
   reg [pt.NUM_THREADS-1:0] lsu_amo_stall_any;            reg [pt.NUM_THREADS-1:0] lsu_load_stall_any;           reg [pt.NUM_THREADS-1:0] lsu_store_stall_any;          reg [pt.NUM_THREADS-1:0] lsu_idle_any;              
   reg [31:1]  lsu_fir_addr;                 reg [1:0]   lsu_fir_error;             
      reg                                  lsu_nonblock_load_valid_dc1;
   reg [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_tag_dc1;
   reg                                  lsu_nonblock_load_inv_dc2;
   reg [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_inv_tag_dc2;
   reg                                  lsu_nonblock_load_inv_dc5;
   reg [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_inv_tag_dc5;
   reg                                  lsu_nonblock_load_data_valid;
   reg                                  lsu_nonblock_load_data_error;
   reg                                  lsu_nonblock_load_data_tid;
   reg [pt.LSU_NUM_NBLOAD_WIDTH-1:0]    lsu_nonblock_load_data_tag;
   reg [31:0]                           lsu_nonblock_load_data;


   reg [pt.NUM_THREADS-1:0] [31:1]      dec_tlu_flush_path_wb;     reg [pt.NUM_THREADS-1:0]             dec_tlu_flush_lower_wb;    reg [pt.NUM_THREADS-1:0]             dec_tlu_flush_noredir_wb ;    reg [pt.NUM_THREADS-1:0]             dec_tlu_flush_leak_one_wb;    reg [pt.NUM_THREADS-1:0]             dec_tlu_flush_err_wb;    reg [pt.NUM_THREADS-1:0]             dec_tlu_fence_i_wb;     

   reg        dec_i0_csr_ren_d;

   reg [31:0] exu_i0_csr_rs1_e1;

   reg        dec_tlu_i0_kill_writeb_wb;       reg        dec_tlu_i1_kill_writeb_wb;    
   reg dec_tlu_i0_valid_e4;
   reg dec_tlu_i1_valid_e4;
   reg [31:0] dec_tlu_mrac_ff;           reg [pt.NUM_THREADS-1:0] dec_tlu_lr_reset_wb; 

reg [pt.NUM_THREADS-1:0] ifu_i0_pc4;
reg [pt.NUM_THREADS-1:0] ifu_i1_pc4;

   eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i0_predecode;
   eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i1_predecode;



   eh2_mul_pkt_t  mul_p;

   reg [31:0] exu_mul_result_e3;

   reg dec_i0_mul_d;
   reg dec_i1_mul_d;

   eh2_div_pkt_t  div_p;

   reg        exu_div_wren;
   reg [31:0] exu_div_result;

   reg dec_i0_div_d;

   reg        dec_i1_valid_e1;

   reg [pt.NUM_THREADS-1:0][31:1] pred_correct_npc_e2; 
   reg [31:0] exu_i0_result_e4;
   reg [31:0] exu_i1_result_e4;

   reg        dec_i0_rs1_bypass_en_e3;
   reg        dec_i0_rs2_bypass_en_e3;
   reg        dec_i1_rs1_bypass_en_e3;
   reg        dec_i1_rs2_bypass_en_e3;
   reg [31:0] i0_rs1_bypass_data_e3;
   reg [31:0] i0_rs2_bypass_data_e3;
   reg [31:0] i1_rs1_bypass_data_e3;
   reg [31:0] i1_rs2_bypass_data_e3;
   reg        dec_i0_sec_decode_e3;
   reg        dec_i1_sec_decode_e3;
   reg [31:1] dec_i0_pc_e3;
   reg [31:1] dec_i1_pc_e3;

   reg        dec_i0_rs1_bypass_en_e2;
   reg        dec_i0_rs2_bypass_en_e2;
   reg        dec_i1_rs1_bypass_en_e2;
   reg        dec_i1_rs2_bypass_en_e2;
   reg [31:0] i0_rs1_bypass_data_e2;
   reg [31:0] i0_rs2_bypass_data_e2;
   reg [31:0] i1_rs1_bypass_data_e2;
   reg [31:0] i1_rs2_bypass_data_e2;

   reg [31:1] exu_i0_flush_path_e4;
   reg [31:1] exu_i1_flush_path_e4;

   eh2_br_tlu_pkt_t dec_tlu_br0_wb_pkt;
   eh2_br_tlu_pkt_t dec_tlu_br1_wb_pkt;

   eh2_predict_pkt_t [pt.NUM_THREADS-1:0]                    exu_mp_pkt;
   reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_eghr;
   reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_fghr;
   reg [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_mp_index;
   reg [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          exu_mp_btag;


   reg [pt.BHT_GHR_SIZE-1:0]  exu_i0_br_fghr_e4;
   reg [1:0]  exu_i0_br_hist_e4;
   reg        exu_i0_br_bank_e4;
   reg        exu_i0_br_error_e4;
   reg        exu_i0_br_start_error_e4;
   reg        exu_i0_br_valid_e4;
   reg        exu_i0_br_mp_e4;
   reg        exu_i0_br_ret_e4;
   reg        exu_i0_br_call_e4;
   reg        exu_i0_br_middle_e4;
   reg [pt.BHT_GHR_SIZE-1:0]  exu_i1_br_fghr_e4;
   reg dec_i0_tid_e4;
   reg dec_i1_tid_e4;

   reg [1:0]  exu_i1_br_hist_e4;
   reg        exu_i1_br_bank_e4;
   reg        exu_i1_br_error_e4;
   reg        exu_i1_br_start_error_e4;
   reg        exu_i1_br_valid_e4;
   reg        exu_i1_br_mp_e4;
   reg        exu_i1_br_ret_e4;
   reg        exu_i1_br_call_e4;
   reg        exu_i1_br_middle_e4;
   reg        exu_i0_br_way_e4;
   reg        exu_i1_br_way_e4;

   reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i0_br_index_e4;
   reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i1_br_index_e4;

   reg        dma_dccm_req;
   reg        dma_dccm_spec_req;
   reg        dma_iccm_req;
   reg        dma_mem_addr_in_dccm;
   reg [2:0]  dma_mem_tag;
   reg [31:0] dma_mem_addr;
   reg [2:0]  dma_mem_sz;
   reg        dma_mem_write;
   reg [63:0] dma_mem_wdata;

   reg        dccm_dma_rvalid;
   reg        dccm_dma_ecc_error;
   reg [2:0]  dccm_dma_rtag;
   reg [63:0] dccm_dma_rdata;
   reg        iccm_dma_rvalid;
   reg        iccm_dma_ecc_error;
   reg [2:0]  iccm_dma_rtag;
   reg [63:0] iccm_dma_rdata;

   reg        dma_dccm_stall_any;          reg        dma_iccm_stall_any;          reg        dccm_ready;
   reg        iccm_ready;

   reg        dma_pmu_dccm_read;
   reg        dma_pmu_dccm_write;
   reg        dma_pmu_any_read;
   reg        dma_pmu_any_write;

   reg [31:0] i0_result_e4_eff;
   reg [31:0] i1_result_e4_eff;

   reg [31:0] i0_result_e2;

   wire [pt.NUM_THREADS-1:0] [1:0]  ifu_i0_icaf_type;
   reg [pt.NUM_THREADS-1:0]        ifu_i0_icaf;
   reg [pt.NUM_THREADS-1:0]        ifu_i0_icaf_f1;
   reg [pt.NUM_THREADS-1:0]        ifu_i0_dbecc;
   reg                           iccm_dma_sb_error;

   reg [pt.NUM_THREADS-1:0] dec_i1_cancel_e1;

   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_brp;
   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_brp;
reg [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i0_bp_index;
reg [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i1_bp_index;
reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ifu_i0_bp_fghr;
reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ifu_i1_bp_fghr;
reg [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0] ifu_i0_bp_btag;
reg [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0] ifu_i1_bp_btag;


   eh2_predict_pkt_t  i0_predict_p_d;
   eh2_predict_pkt_t  i1_predict_p_d;

reg [pt.BHT_GHR_SIZE-1:0] i0_predict_fghr_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
reg [pt.BHT_GHR_SIZE-1:0] i1_predict_fghr_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
reg [pt.BHT_GHR_SIZE-1:0] i0_predict_index_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
reg [pt.BHT_GHR_SIZE-1:0] i1_predict_index_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
reg [pt.BHT_GHR_SIZE-1:0] i0_predict_btag_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
reg [pt.BHT_GHR_SIZE-1:0] i1_predict_btag_d [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] [pt.BTB_BTAG_SIZE-1:0];
   reg [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br0_fghr_wb;     reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br0_index_wb;    reg [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br1_fghr_wb;     reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br1_index_wb; 
         reg                  picm_rd_thr;
   reg                  picm_wren;
   reg                  picm_rden;
   reg                  picm_mken;
   reg [31:0]           picm_rdaddr;
   reg [31:0]           picm_wraddr;
   reg [31:0]           picm_wr_data;
   reg [31:0]           picm_rd_data;


   reg  dec_tlu_external_ldfwd_disable;
   reg  dec_tlu_bpred_disable;
   reg  dec_tlu_wb_coalescing_disable;
   reg  dec_tlu_sideeffect_posted_disable;
   reg [2:0] dec_tlu_dma_qos_prty;

      reg  dec_tlu_misc_clk_override;
   reg  dec_tlu_exu_clk_override;
   reg  dec_tlu_ifu_clk_override;
   reg  dec_tlu_lsu_clk_override;
   reg  dec_tlu_bus_clk_override;
   reg  dec_tlu_pic_clk_override;
   reg  dec_tlu_dccm_clk_override;
   reg  dec_tlu_icm_clk_override;

   
   reg [31:0]            dbg_cmd_addr;                 reg [31:0]            dbg_cmd_wrdata;               reg                   dbg_cmd_valid;                reg                   dbg_cmd_tid;                  reg                   dbg_cmd_write;                reg [1:0]             dbg_cmd_type;                 reg [1:0]             dbg_cmd_size;                 reg [pt.NUM_THREADS-1:0] dbg_halt_req;              reg [pt.NUM_THREADS-1:0] dbg_resume_req;            reg                   dbg_core_rst_l;            
   wire                   core_dbg_cmd_done;            wire                   core_dbg_cmd_fail;            wire [31:0]            core_dbg_rddata;           
   reg                   dma_dbg_cmd_done;             reg                   dma_dbg_cmd_fail;             reg [31:0]            dma_dbg_rddata;            
   reg                   dbg_dma_bubble;               reg                   dma_dbg_ready;             
   reg [31:0]            dec_dbg_rddata;               reg                   dec_dbg_cmd_done;             reg                   dec_dbg_cmd_fail;             reg                   dec_dbg_cmd_tid;              reg [pt.NUM_THREADS-1:0] dec_tlu_mpc_halted_only;      reg [pt.NUM_THREADS-1:0] dec_tlu_dbg_halted;           reg [pt.NUM_THREADS-1:0] dec_tlu_resume_ack;
   reg [pt.NUM_THREADS-1:0] dec_tlu_debug_mode;           reg                   dec_debug_wdata_rs1_d;

   reg [4:2]             dec_i0_data_en;
   reg [4:1]             dec_i0_ctl_en;
   reg [4:2]             dec_i1_data_en;
   reg [4:1]             dec_i1_ctl_en;

      reg                   exu_pmu_i0_br_misp;
   reg                   exu_pmu_i0_br_ataken;
   reg                   exu_pmu_i0_pc4;
   reg                   exu_pmu_i1_br_misp;
   reg                   exu_pmu_i1_br_ataken;
   reg                   exu_pmu_i1_pc4;

   reg [pt.NUM_THREADS-1:0]  lsu_pmu_load_external_dc3;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_store_external_dc3;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_misaligned_dc3;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_bus_trxn;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_bus_misaligned;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_bus_error;
   reg [pt.NUM_THREADS-1:0]  lsu_pmu_bus_busy;

   reg [pt.NUM_THREADS-1:0] ifu_pmu_fetch_stall;

   reg [pt.NUM_THREADS-1:0] ifu_pmu_ic_miss;                  reg [pt.NUM_THREADS-1:0] ifu_pmu_ic_hit;                   reg [pt.NUM_THREADS-1:0] ifu_pmu_bus_error;                reg [pt.NUM_THREADS-1:0] ifu_pmu_bus_busy;                 reg [pt.NUM_THREADS-1:0] ifu_pmu_bus_trxn;              
   wire                   active_state;
reg free_clk;
reg active_clk;
   reg                   dec_pause_state_cg;


   reg [pt.NUM_THREADS-1:0] [15:0]            ifu_i0_cinst;
   reg [pt.NUM_THREADS-1:0] [15:0]            ifu_i1_cinst;

   reg [31:0]                  lsu_rs1_dc1;

   reg                         dec_extint_stall;

   eh2_trace_pkt_t  [pt.NUM_THREADS-1:0] rv_trace_pkt;

   reg [pt.NUM_THREADS-1:0]    exu_flush_final;               reg [pt.NUM_THREADS-1:0]    exu_i0_flush_final;            reg [pt.NUM_THREADS-1:0]    exu_i1_flush_final;         
   reg [pt.NUM_THREADS-1:0]    exu_i0_flush_lower_e4;           reg [pt.NUM_THREADS-1:0]    exu_i1_flush_lower_e4;        
   reg                         dec_div_cancel;             
   reg                   jtag_tdoEn;

   wire [pt.NUM_THREADS-1:0] [7:0]  pic_claimid;
reg [pt.NUM_THREADS-1:0] [3:0] pic_pl;
reg [pt.NUM_THREADS-1:0] [3:0] dec_tlu_meicurpl;
reg [pt.NUM_THREADS-1:0] [3:0] dec_tlu_meipt;
   reg [pt.NUM_THREADS-1:0]        mexintpend;
   reg [pt.NUM_THREADS-1:0]        mhwakeup;




   assign        dccm_clk_override = dec_tlu_dccm_clk_override;      assign        icm_clk_override = dec_tlu_icm_clk_override;    

      assign active_state = (~dec_pause_state_cg | dec_tlu_flush_lower_wb[0]) | dec_tlu_exu_clk_override;
  rvoclkhdr free_cg   ( .en(1'b1),         .l1clk(free_clk), .* );
   rvoclkhdr active_cg ( .en(active_state), .l1clk(active_clk), .* );



   assign core_dbg_cmd_done = dma_dbg_cmd_done | dec_dbg_cmd_done;
   assign core_dbg_cmd_fail = dma_dbg_cmd_fail | dec_dbg_cmd_fail;
   assign core_dbg_rddata[31:0] = dma_dbg_cmd_done ? dma_dbg_rddata[31:0] : dec_dbg_rddata[31:0];

   eh2_dbg #(.pt(pt)) dbg (
      .clk_override(dec_tlu_misc_clk_override),

            .sb_axi_awready(sb_axi_awready_int),
      .sb_axi_wready(sb_axi_wready_int),
      .sb_axi_bvalid(sb_axi_bvalid_int),
      .sb_axi_bresp(sb_axi_bresp_int[1:0]),

      .sb_axi_arready(sb_axi_arready_int),
      .sb_axi_rvalid(sb_axi_rvalid_int),
      .sb_axi_rdata(sb_axi_rdata_int[63:0]),
      .sb_axi_rresp(sb_axi_rresp_int[1:0]),
        .*
   );

   assign core_rst_l = rst_l & (dbg_core_rst_l | scan_mode);

      eh2_ifu #(.pt(pt)) ifu (
       .clk_override(dec_tlu_ifu_clk_override),
       .rst_l(core_rst_l),

            .ifu_axi_arready(ifu_axi_arready_int),
      .ifu_axi_rvalid(ifu_axi_rvalid_int),
      .ifu_axi_rid(ifu_axi_rid_int[pt.IFU_BUS_TAG-1:0]),
      .ifu_axi_rdata(ifu_axi_rdata_int[63:0]),
      .ifu_axi_rresp(ifu_axi_rresp_int[1:0]),
        .*
   );



   eh2_dec #(.pt(pt)) dec (
            .dbg_cmd_wrdata(dbg_cmd_wrdata[1:0]),
            .rst_l(core_rst_l),
        .*            );

   eh2_exu #(.pt(pt)) exu (
      .clk_override(dec_tlu_exu_clk_override),
      .rst_l(core_rst_l),
               .*
   );

   eh2_lsu #(.pt(pt)) lsu (
      .clk_override(dec_tlu_lsu_clk_override),
      .rst_l(core_rst_l),

            .lsu_axi_awready(lsu_axi_awready_int),
      .lsu_axi_wready(lsu_axi_wready_int),
      .lsu_axi_bvalid(lsu_axi_bvalid_int),
      .lsu_axi_bid(lsu_axi_bid_int[pt.LSU_BUS_TAG-1:0]),
      .lsu_axi_bresp(lsu_axi_bresp_int[1:0]),

      .lsu_axi_arready(lsu_axi_arready_int),
      .lsu_axi_rvalid(lsu_axi_rvalid_int),
      .lsu_axi_rid(lsu_axi_rid_int[pt.LSU_BUS_TAG-1:0]),
      .lsu_axi_rdata(lsu_axi_rdata_int[63:0]),
      .lsu_axi_rresp(lsu_axi_rresp_int[1:0]),
      .lsu_axi_rlast(lsu_axi_rlast_int),
        .*
   );

   eh2_pic_ctrl #(.pt(pt))  pic_ctrl_inst (
                  .clk_override(dec_tlu_pic_clk_override),
                  .picm_mken (picm_mken),
                  .extintsrc_req({extintsrc_req[pt.PIC_TOTAL_INT:1],1'b0}),
                  .pl_out(pic_pl),
                  .claimid_out(pic_claimid),
                  .mexintpend_out(mexintpend),
                  .mhwakeup_out(mhwakeup),
                  .rst_l(core_rst_l),
        .*
   );

   eh2_dma_ctrl #(.pt(pt)) dma_ctrl (
      .rst_l(core_rst_l),
      .clk_override(dec_tlu_misc_clk_override),

            .dma_axi_awvalid(dma_axi_awvalid_int),
      .dma_axi_awid(dma_axi_awid_int[pt.DMA_BUS_TAG-1:0]),
      .dma_axi_awaddr(dma_axi_awaddr_int[31:0]),
      .dma_axi_awsize(dma_axi_awsize_int[2:0]),
      .dma_axi_wvalid(dma_axi_wvalid_int),
      .dma_axi_wdata(dma_axi_wdata_int[63:0]),
      .dma_axi_wstrb(dma_axi_wstrb_int[7:0]),
      .dma_axi_bready(dma_axi_bready_int),

      .dma_axi_arvalid(dma_axi_arvalid_int),
      .dma_axi_arid(dma_axi_arid_int[pt.DMA_BUS_TAG-1:0]),
      .dma_axi_araddr(dma_axi_araddr_int[31:0]),
      .dma_axi_arsize(dma_axi_arsize_int[2:0]),
      .dma_axi_rready(dma_axi_rready_int),
        .*
   );

   if (pt.BUILD_AHB_LITE == 1) begin: Gen_AXI_To_AHB

            axi4_to_ahb #(.pt(pt),
                    .TAG(pt.LSU_BUS_TAG)) lsu_axi4_to_ahb (
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(lsu_bus_clk_en),

                  .axi_awvalid(lsu_axi_awvalid),
         .axi_awready(lsu_axi_awready_ahb),
         .axi_awid(lsu_axi_awid[pt.LSU_BUS_TAG-1:0]),
         .axi_awaddr(lsu_axi_awaddr[31:0]),
         .axi_awsize(lsu_axi_awsize[2:0]),
         .axi_awprot(lsu_axi_awprot[2:0]),

         .axi_wvalid(lsu_axi_wvalid),
         .axi_wready(lsu_axi_wready_ahb),
         .axi_wdata(lsu_axi_wdata[63:0]),
         .axi_wstrb(lsu_axi_wstrb[7:0]),
         .axi_wlast(lsu_axi_wlast),

         .axi_bvalid(lsu_axi_bvalid_ahb),
         .axi_bready(lsu_axi_bready),
         .axi_bresp(lsu_axi_bresp_ahb[1:0]),
         .axi_bid(lsu_axi_bid_ahb[pt.LSU_BUS_TAG-1:0]),

                  .axi_arvalid(lsu_axi_arvalid),
         .axi_arready(lsu_axi_arready_ahb),
         .axi_arid(lsu_axi_arid[pt.LSU_BUS_TAG-1:0]),
         .axi_araddr(lsu_axi_araddr[31:0]),
         .axi_arsize(lsu_axi_arsize[2:0]),
         .axi_arprot(lsu_axi_arprot[2:0]),

         .axi_rvalid(lsu_axi_rvalid_ahb),
         .axi_rready(lsu_axi_rready),
         .axi_rid(lsu_axi_rid_ahb[pt.LSU_BUS_TAG-1:0]),
         .axi_rdata(lsu_axi_rdata_ahb[63:0]),
         .axi_rresp(lsu_axi_rresp_ahb[1:0]),
         .axi_rlast(lsu_axi_rlast_ahb),

                  .ahb_haddr(lsu_haddr[31:0]),
         .ahb_hburst(lsu_hburst),
         .ahb_hmastlock(lsu_hmastlock),
         .ahb_hprot(lsu_hprot[3:0]),
         .ahb_hsize(lsu_hsize[2:0]),
         .ahb_htrans(lsu_htrans[1:0]),
         .ahb_hwrite(lsu_hwrite),
         .ahb_hwdata(lsu_hwdata[63:0]),

         .ahb_hrdata(lsu_hrdata[63:0]),
         .ahb_hready(lsu_hready),
         .ahb_hresp(lsu_hresp),
        .*
      );

      axi4_to_ahb #(.pt(pt),
                    .TAG(pt.IFU_BUS_TAG)) ifu_axi4_to_ahb (
         .clk(clk),
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(ifu_bus_clk_en),

                   .ahb_haddr(haddr[31:0]),
         .ahb_hburst(hburst),
         .ahb_hmastlock(hmastlock),
         .ahb_hprot(hprot[3:0]),
         .ahb_hsize(hsize[2:0]),
         .ahb_htrans(htrans[1:0]),
         .ahb_hwrite(hwrite),
         .ahb_hwdata(hwdata_nc[63:0]),

         .ahb_hrdata(hrdata[63:0]),
         .ahb_hready(hready),
         .ahb_hresp(hresp),

                  .axi_awvalid(ifu_axi_awvalid),
         .axi_awready(ifu_axi_awready_ahb),
         .axi_awid(ifu_axi_awid[pt.IFU_BUS_TAG-1:0]),
         .axi_awaddr(ifu_axi_awaddr[31:0]),
         .axi_awsize(ifu_axi_awsize[2:0]),
         .axi_awprot(ifu_axi_awprot[2:0]),

         .axi_wvalid(ifu_axi_wvalid),
         .axi_wready(ifu_axi_wready_ahb),
         .axi_wdata(ifu_axi_wdata[63:0]),
         .axi_wstrb(ifu_axi_wstrb[7:0]),
         .axi_wlast(ifu_axi_wlast),

         .axi_bvalid(ifu_axi_bvalid_ahb),
         .axi_bready(1'b1),
         .axi_bresp(ifu_axi_bresp_ahb[1:0]),
         .axi_bid(ifu_axi_bid_ahb[pt.IFU_BUS_TAG-1:0]),

                  .axi_arvalid(ifu_axi_arvalid),
         .axi_arready(ifu_axi_arready_ahb),
         .axi_arid(ifu_axi_arid[pt.IFU_BUS_TAG-1:0]),
         .axi_araddr(ifu_axi_araddr[31:0]),
         .axi_arsize(ifu_axi_arsize[2:0]),
         .axi_arprot(ifu_axi_arprot[2:0]),

         .axi_rvalid(ifu_axi_rvalid_ahb),
         .axi_rready(ifu_axi_rready),
         .axi_rid(ifu_axi_rid_ahb[pt.IFU_BUS_TAG-1:0]),
         .axi_rdata(ifu_axi_rdata_ahb[63:0]),
         .axi_rresp(ifu_axi_rresp_ahb[1:0]),
         .axi_rlast(ifu_axi_rlast_ahb),
        .*
      );

            axi4_to_ahb #(.pt(pt),
                    .TAG(pt.SB_BUS_TAG)) sb_axi4_to_ahb (
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(dbg_bus_clk_en),

                  .axi_awvalid(sb_axi_awvalid),
         .axi_awready(sb_axi_awready_ahb),
         .axi_awid(sb_axi_awid[pt.SB_BUS_TAG-1:0]),
         .axi_awaddr(sb_axi_awaddr[31:0]),
         .axi_awsize(sb_axi_awsize[2:0]),
         .axi_awprot(sb_axi_awprot[2:0]),

         .axi_wvalid(sb_axi_wvalid),
         .axi_wready(sb_axi_wready_ahb),
         .axi_wdata(sb_axi_wdata[63:0]),
         .axi_wstrb(sb_axi_wstrb[7:0]),
         .axi_wlast(sb_axi_wlast),

         .axi_bvalid(sb_axi_bvalid_ahb),
         .axi_bready(sb_axi_bready),
         .axi_bresp(sb_axi_bresp_ahb[1:0]),
         .axi_bid(sb_axi_bid_ahb[pt.SB_BUS_TAG-1:0]),

                  .axi_arvalid(sb_axi_arvalid),
         .axi_arready(sb_axi_arready_ahb),
         .axi_arid(sb_axi_arid[pt.SB_BUS_TAG-1:0]),
         .axi_araddr(sb_axi_araddr[31:0]),
         .axi_arsize(sb_axi_arsize[2:0]),
         .axi_arprot(sb_axi_arprot[2:0]),

         .axi_rvalid(sb_axi_rvalid_ahb),
         .axi_rready(sb_axi_rready),
         .axi_rid(sb_axi_rid_ahb[pt.SB_BUS_TAG-1:0]),
         .axi_rdata(sb_axi_rdata_ahb[63:0]),
         .axi_rresp(sb_axi_rresp_ahb[1:0]),
         .axi_rlast(sb_axi_rlast_ahb),

                  .ahb_haddr(sb_haddr[31:0]),
         .ahb_hburst(sb_hburst),
         .ahb_hmastlock(sb_hmastlock),
         .ahb_hprot(sb_hprot[3:0]),
         .ahb_hsize(sb_hsize[2:0]),
         .ahb_htrans(sb_htrans[1:0]),
         .ahb_hwrite(sb_hwrite),
         .ahb_hwdata(sb_hwdata[63:0]),

         .ahb_hrdata(sb_hrdata[63:0]),
         .ahb_hready(sb_hready),
         .ahb_hresp(sb_hresp),
        .*
      );

            ahb_to_axi4 #(.pt(pt),
                    .TAG(pt.DMA_BUS_TAG)) dma_ahb_to_axi4 (
         .clk_override(dec_tlu_bus_clk_override),
         .bus_clk_en(dma_bus_clk_en),

                  .axi_awvalid(dma_axi_awvalid_ahb),
         .axi_awready(dma_axi_awready),
         .axi_awid(dma_axi_awid_ahb[pt.DMA_BUS_TAG-1:0]),
         .axi_awaddr(dma_axi_awaddr_ahb[31:0]),
         .axi_awsize(dma_axi_awsize_ahb[2:0]),
         .axi_awprot(dma_axi_awprot_ahb[2:0]),
         .axi_awlen(dma_axi_awlen_ahb[7:0]),
         .axi_awburst(dma_axi_awburst_ahb[1:0]),

         .axi_wvalid(dma_axi_wvalid_ahb),
         .axi_wready(dma_axi_wready),
         .axi_wdata(dma_axi_wdata_ahb[63:0]),
         .axi_wstrb(dma_axi_wstrb_ahb[7:0]),
         .axi_wlast(dma_axi_wlast_ahb),

         .axi_bvalid(dma_axi_bvalid),
         .axi_bready(dma_axi_bready_ahb),
         .axi_bresp(dma_axi_bresp[1:0]),
         .axi_bid(dma_axi_bid[pt.DMA_BUS_TAG-1:0]),

                  .axi_arvalid(dma_axi_arvalid_ahb),
         .axi_arready(dma_axi_arready),
         .axi_arid(dma_axi_arid_ahb[pt.DMA_BUS_TAG-1:0]),
         .axi_araddr(dma_axi_araddr_ahb[31:0]),
         .axi_arsize(dma_axi_arsize_ahb[2:0]),
         .axi_arprot(dma_axi_arprot_ahb[2:0]),
         .axi_arlen(dma_axi_arlen_ahb[7:0]),
         .axi_arburst(dma_axi_arburst_ahb[1:0]),

         .axi_rvalid(dma_axi_rvalid),
         .axi_rready(dma_axi_rready_ahb),
         .axi_rid(dma_axi_rid[pt.DMA_BUS_TAG-1:0]),
         .axi_rdata(dma_axi_rdata[63:0]),
         .axi_rresp(dma_axi_rresp[1:0]),

                   .ahb_haddr(dma_haddr[31:0]),
         .ahb_hburst(dma_hburst),
         .ahb_hmastlock(dma_hmastlock),
         .ahb_hprot(dma_hprot[3:0]),
         .ahb_hsize(dma_hsize[2:0]),
         .ahb_htrans(dma_htrans[1:0]),
         .ahb_hwrite(dma_hwrite),
         .ahb_hwdata(dma_hwdata[63:0]),

         .ahb_hrdata(dma_hrdata[63:0]),
         .ahb_hreadyout(dma_hreadyout),
         .ahb_hresp(dma_hresp),
         .ahb_hreadyin(dma_hreadyin),
         .ahb_hsel(dma_hsel),
        .*      );

   end

      assign lsu_axi_awready_int                 = pt.BUILD_AHB_LITE ? lsu_axi_awready_ahb : lsu_axi_awready;
   assign lsu_axi_wready_int                  = pt.BUILD_AHB_LITE ? lsu_axi_wready_ahb : lsu_axi_wready;
   assign lsu_axi_bvalid_int                  = pt.BUILD_AHB_LITE ? lsu_axi_bvalid_ahb : lsu_axi_bvalid;
   assign lsu_axi_bready_int                  = pt.BUILD_AHB_LITE ? lsu_axi_bready_ahb : lsu_axi_bready;
   assign lsu_axi_bresp_int[1:0]              = pt.BUILD_AHB_LITE ? lsu_axi_bresp_ahb[1:0] : lsu_axi_bresp[1:0];
   assign lsu_axi_bid_int[pt.LSU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? lsu_axi_bid_ahb[pt.LSU_BUS_TAG-1:0] : lsu_axi_bid[pt.LSU_BUS_TAG-1:0];
   assign lsu_axi_arready_int                 = pt.BUILD_AHB_LITE ? lsu_axi_arready_ahb : lsu_axi_arready;
   assign lsu_axi_rvalid_int                  = pt.BUILD_AHB_LITE ? lsu_axi_rvalid_ahb : lsu_axi_rvalid;
   assign lsu_axi_rid_int[pt.LSU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? lsu_axi_rid_ahb[pt.LSU_BUS_TAG-1:0] : lsu_axi_rid[pt.LSU_BUS_TAG-1:0];
   assign lsu_axi_rdata_int[63:0]             = pt.BUILD_AHB_LITE ? lsu_axi_rdata_ahb[63:0] : lsu_axi_rdata[63:0];
   assign lsu_axi_rresp_int[1:0]              = pt.BUILD_AHB_LITE ? lsu_axi_rresp_ahb[1:0] : lsu_axi_rresp[1:0];
   assign lsu_axi_rlast_int                   = pt.BUILD_AHB_LITE ? lsu_axi_rlast_ahb : lsu_axi_rlast;

   assign ifu_axi_awready_int                 = pt.BUILD_AHB_LITE ? ifu_axi_awready_ahb : ifu_axi_awready;
   assign ifu_axi_wready_int                  = pt.BUILD_AHB_LITE ? ifu_axi_wready_ahb : ifu_axi_wready;
   assign ifu_axi_bvalid_int                  = pt.BUILD_AHB_LITE ? ifu_axi_bvalid_ahb : ifu_axi_bvalid;
   assign ifu_axi_bready_int                  = pt.BUILD_AHB_LITE ? ifu_axi_bready_ahb : ifu_axi_bready;
   assign ifu_axi_bresp_int[1:0]              = pt.BUILD_AHB_LITE ? ifu_axi_bresp_ahb[1:0] : ifu_axi_bresp[1:0];
   assign ifu_axi_bid_int[pt.IFU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? ifu_axi_bid_ahb[pt.IFU_BUS_TAG-1:0] : ifu_axi_bid[pt.IFU_BUS_TAG-1:0];
   assign ifu_axi_arready_int                 = pt.BUILD_AHB_LITE ? ifu_axi_arready_ahb : ifu_axi_arready;
   assign ifu_axi_rvalid_int                  = pt.BUILD_AHB_LITE ? ifu_axi_rvalid_ahb : ifu_axi_rvalid;
   assign ifu_axi_rid_int[pt.IFU_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? ifu_axi_rid_ahb[pt.IFU_BUS_TAG-1:0] : ifu_axi_rid[pt.IFU_BUS_TAG-1:0];
   assign ifu_axi_rdata_int[63:0]             = pt.BUILD_AHB_LITE ? ifu_axi_rdata_ahb[63:0] : ifu_axi_rdata[63:0];
   assign ifu_axi_rresp_int[1:0]              = pt.BUILD_AHB_LITE ? ifu_axi_rresp_ahb[1:0] : ifu_axi_rresp[1:0];
   assign ifu_axi_rlast_int                   = pt.BUILD_AHB_LITE ? ifu_axi_rlast_ahb : ifu_axi_rlast;

   assign sb_axi_awready_int                  = pt.BUILD_AHB_LITE ? sb_axi_awready_ahb : sb_axi_awready;
   assign sb_axi_wready_int                   = pt.BUILD_AHB_LITE ? sb_axi_wready_ahb : sb_axi_wready;
   assign sb_axi_bvalid_int                   = pt.BUILD_AHB_LITE ? sb_axi_bvalid_ahb : sb_axi_bvalid;
   assign sb_axi_bready_int                   = pt.BUILD_AHB_LITE ? sb_axi_bready_ahb : sb_axi_bready;
   assign sb_axi_bresp_int[1:0]               = pt.BUILD_AHB_LITE ? sb_axi_bresp_ahb[1:0] : sb_axi_bresp[1:0];
   assign sb_axi_bid_int[pt.SB_BUS_TAG-1:0]   = pt.BUILD_AHB_LITE ? sb_axi_bid_ahb[pt.SB_BUS_TAG-1:0] : sb_axi_bid[pt.SB_BUS_TAG-1:0];
   assign sb_axi_arready_int                  = pt.BUILD_AHB_LITE ? sb_axi_arready_ahb : sb_axi_arready;
   assign sb_axi_rvalid_int                   = pt.BUILD_AHB_LITE ? sb_axi_rvalid_ahb : sb_axi_rvalid;
   assign sb_axi_rid_int[pt.SB_BUS_TAG-1:0]   = pt.BUILD_AHB_LITE ? sb_axi_rid_ahb[pt.SB_BUS_TAG-1:0] : sb_axi_rid[pt.SB_BUS_TAG-1:0];
   assign sb_axi_rdata_int[63:0]              = pt.BUILD_AHB_LITE ? sb_axi_rdata_ahb[63:0] : sb_axi_rdata[63:0];
   assign sb_axi_rresp_int[1:0]               = pt.BUILD_AHB_LITE ? sb_axi_rresp_ahb[1:0] : sb_axi_rresp[1:0];
   assign sb_axi_rlast_int                    = pt.BUILD_AHB_LITE ? sb_axi_rlast_ahb : sb_axi_rlast;

   assign dma_axi_awvalid_int                  = pt.BUILD_AHB_LITE ? dma_axi_awvalid_ahb : dma_axi_awvalid;
   assign dma_axi_awid_int[pt.DMA_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? dma_axi_awid_ahb[pt.DMA_BUS_TAG-1:0] : dma_axi_awid[pt.DMA_BUS_TAG-1:0];
   assign dma_axi_awaddr_int[31:0]             = pt.BUILD_AHB_LITE ? dma_axi_awaddr_ahb[31:0] : dma_axi_awaddr[31:0];
   assign dma_axi_awsize_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_awsize_ahb[2:0] : dma_axi_awsize[2:0];
   assign dma_axi_awprot_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_awprot_ahb[2:0] : dma_axi_awprot[2:0];
   assign dma_axi_awlen_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_awlen_ahb[7:0] : dma_axi_awlen[7:0];
   assign dma_axi_awburst_int[1:0]             = pt.BUILD_AHB_LITE ? dma_axi_awburst_ahb[1:0] : dma_axi_awburst[1:0];
   assign dma_axi_wvalid_int                   = pt.BUILD_AHB_LITE ? dma_axi_wvalid_ahb : dma_axi_wvalid;
   assign dma_axi_wdata_int[63:0]              = pt.BUILD_AHB_LITE ? dma_axi_wdata_ahb[63:0] : dma_axi_wdata;
   assign dma_axi_wstrb_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_wstrb_ahb[7:0] : dma_axi_wstrb[7:0];
   assign dma_axi_wlast_int                    = pt.BUILD_AHB_LITE ? dma_axi_wlast_ahb : dma_axi_wlast;
   assign dma_axi_bready_int                   = pt.BUILD_AHB_LITE ? dma_axi_bready_ahb : dma_axi_bready;
   assign dma_axi_arvalid_int                  = pt.BUILD_AHB_LITE ? dma_axi_arvalid_ahb : dma_axi_arvalid;
   assign dma_axi_arid_int[pt.DMA_BUS_TAG-1:0] = pt.BUILD_AHB_LITE ? dma_axi_arid_ahb[pt.DMA_BUS_TAG-1:0] : dma_axi_arid[pt.DMA_BUS_TAG-1:0];
   assign dma_axi_araddr_int[31:0]             = pt.BUILD_AHB_LITE ? dma_axi_araddr_ahb[31:0] : dma_axi_araddr[31:0];
   assign dma_axi_arsize_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_arsize_ahb[2:0] : dma_axi_arsize[2:0];
   assign dma_axi_arprot_int[2:0]              = pt.BUILD_AHB_LITE ? dma_axi_arprot_ahb[2:0] : dma_axi_arprot[2:0];
   assign dma_axi_arlen_int[7:0]               = pt.BUILD_AHB_LITE ? dma_axi_arlen_ahb[7:0] : dma_axi_arlen[7:0];
   assign dma_axi_arburst_int[1:0]             = pt.BUILD_AHB_LITE ? dma_axi_arburst_ahb[1:0] : dma_axi_arburst[1:0];
   assign dma_axi_rready_int                   = pt.BUILD_AHB_LITE ? dma_axi_rready_ahb : dma_axi_rready;

   if  (pt.BUILD_AHB_LITE == 1) begin
   `ifdef ASSERT_ON


`endif
   end 


            
   for (genvar i=0; i<pt.NUM_THREADS; i++) begin : trace_rewire

      assign trace_rv_i_insn_ip[i][63:0]     = rv_trace_pkt[i].rv_i_insn_ip[63:0];
      assign trace_rv_i_address_ip[i][63:0]  = rv_trace_pkt[i].rv_i_address_ip[63:0];
      assign trace_rv_i_valid_ip[i][2:0]     = rv_trace_pkt[i].rv_i_valid_ip[2:0];
      assign trace_rv_i_exception_ip[i][2:0] = rv_trace_pkt[i].rv_i_exception_ip[2:0];
      assign trace_rv_i_ecause_ip[i][4:0]    = rv_trace_pkt[i].rv_i_ecause_ip[4:0];
      assign trace_rv_i_interrupt_ip[i][2:0] = rv_trace_pkt[i].rv_i_interrupt_ip[2:0];
      assign trace_rv_i_tval_ip[i][31:0]     = rv_trace_pkt[i].rv_i_tval_ip[31:0];
   end


endmodule 
