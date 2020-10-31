
module eh2_lsu_bus_intf
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(
   input wire clk,
   input wire rst_l,
   input wire scan_mode,
   input wire dec_tlu_external_ldfwd_disable,        input wire dec_tlu_wb_coalescing_disable,         input wire dec_tlu_sideeffect_posted_disable,  
      input wire lsu_c1_dc2_clk,
   input wire lsu_c1_dc3_clk,
   input wire lsu_c1_dc4_clk,
   input wire lsu_c1_dc5_clk,
   input wire lsu_c2_dc2_clk,
   input wire lsu_c2_dc3_clk,
   input wire lsu_c2_dc4_clk,
   input wire lsu_c2_dc5_clk,

   input wire [pt.NUM_THREADS-1:0]     lsu_bus_ibuf_c1_clk,
   input wire [pt.NUM_THREADS-1:0]     lsu_bus_obuf_c1_clk,
   input wire [pt.NUM_THREADS-1:0]     lsu_bus_buf_c1_clk,
   input wire lsu_free_c2_clk,
   input wire free_clk,
   input wire lsu_busm_clk,

   input wire lsu_busreq_dc1,                   
   input                                eh2_lsu_pkt_t lsu_pkt_dc1_pre,           input                                eh2_lsu_pkt_t lsu_pkt_dc2,               input                                eh2_lsu_pkt_t lsu_pkt_dc3,               input                                eh2_lsu_pkt_t lsu_pkt_dc4,               input                                eh2_lsu_pkt_t lsu_pkt_dc5,            
   input wire [31:0]                   lsu_addr_dc1,                        input wire [31:0]                   lsu_addr_dc2,                        input wire [31:0]                   lsu_addr_dc3,                        input wire [31:0]                   lsu_addr_dc4,                        input wire [31:0]                   lsu_addr_dc5,                     
   input wire [31:0]                   end_addr_dc1,                        input wire [31:0]                   end_addr_dc2,                        input wire [31:0]                   end_addr_dc3,                        input wire [31:0]                   end_addr_dc4,                        input wire [31:0]                   end_addr_dc5,                     
   input wire [63:0]                   store_data_ext_dc3,                  input wire [63:0]                   store_data_ext_dc4,                  input wire [63:0]                   store_data_ext_dc5,                  input wire [pt.NUM_THREADS-1:0]     dec_tlu_force_halt,

   input wire core_ldst_dual_dc1,                  input wire lsu_commit_dc5,                      input wire is_sideeffects_dc2,                  input wire is_sideeffects_dc3,                  input wire [pt.NUM_THREADS-1:0]     flush_dc2_up,                        input wire [pt.NUM_THREADS-1:0]     flush_dc3,                           input wire [pt.NUM_THREADS-1:0]     flush_dc4,                        
   output logic                         lsu_busreq_dc5,                      output logic [pt.NUM_THREADS-1:0]    lsu_bus_idle_any,                    output logic [pt.NUM_THREADS-1:0]    lsu_bus_buffer_pend_any,             output logic [pt.NUM_THREADS-1:0]    lsu_bus_buffer_full_any,             output logic [pt.NUM_THREADS-1:0]    lsu_bus_buffer_empty_any,            output logic [31:0]                  bus_read_data_dc3,                   
   output logic [pt.NUM_THREADS-1:0]         lsu_imprecise_error_load_any,        output logic [pt.NUM_THREADS-1:0]         lsu_imprecise_error_store_any,       output logic [pt.NUM_THREADS-1:0][31:0]   lsu_imprecise_error_addr_any,     
      output logic                               lsu_nonblock_load_valid_dc1,        output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_tag_dc1,          output logic                               lsu_nonblock_load_inv_dc2,          output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_inv_tag_dc2,
   output logic                               lsu_nonblock_load_inv_dc5,          output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_inv_tag_dc5,      output logic                               lsu_nonblock_load_data_valid,       output logic                               lsu_nonblock_load_data_error,       output logic                               lsu_nonblock_load_data_tid,         output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_data_tag,         output logic [31:0]                        lsu_nonblock_load_data,          
      output logic [pt.NUM_THREADS-1:0]    lsu_pmu_bus_trxn,
   output logic [pt.NUM_THREADS-1:0]    lsu_pmu_bus_misaligned,
   output logic [pt.NUM_THREADS-1:0]    lsu_pmu_bus_error,
   output logic [pt.NUM_THREADS-1:0]    lsu_pmu_bus_busy,

         output logic                         lsu_axi_awvalid,
   input wire lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_awid,
   output logic [31:0]                  lsu_axi_awaddr,
   output logic [3:0]                   lsu_axi_awregion,
   output logic [7:0]                   lsu_axi_awlen,
   output logic [2:0]                   lsu_axi_awsize,
   output logic [1:0]                   lsu_axi_awburst,
   output logic                         lsu_axi_awlock,
   output logic [3:0]                   lsu_axi_awcache,
   output logic [2:0]                   lsu_axi_awprot,
   output logic [3:0]                   lsu_axi_awqos,

   output logic                         lsu_axi_wvalid,
   input wire lsu_axi_wready,
   output logic [63:0]                  lsu_axi_wdata,
   output logic [7:0]                   lsu_axi_wstrb,
   output logic                         lsu_axi_wlast,

   input wire lsu_axi_bvalid,
   output logic                         lsu_axi_bready,
   input wire [1:0]                   lsu_axi_bresp,
   input wire [pt.LSU_BUS_TAG-1:0]    lsu_axi_bid,

      output logic                         lsu_axi_arvalid,
   input wire lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]    lsu_axi_arid,
   output logic [31:0]                  lsu_axi_araddr,
   output logic [3:0]                   lsu_axi_arregion,
   output logic [7:0]                   lsu_axi_arlen,
   output logic [2:0]                   lsu_axi_arsize,
   output logic [1:0]                   lsu_axi_arburst,
   output logic                         lsu_axi_arlock,
   output logic [3:0]                   lsu_axi_arcache,
   output logic [2:0]                   lsu_axi_arprot,
   output logic [3:0]                   lsu_axi_arqos,

   input wire lsu_axi_rvalid,
   output logic                         lsu_axi_rready,
   input wire [pt.LSU_BUS_TAG-1:0]    lsu_axi_rid,
   input wire [63:0]                  lsu_axi_rdata,
   input wire [1:0]                   lsu_axi_rresp,

   input wire lsu_bus_clk_en

);

   reg              lsu_bus_clk_en_q;
wire ldst_dual_dc1;
reg ldst_dual_dc2;
reg ldst_dual_dc3;
reg ldst_dual_dc4;
reg ldst_dual_dc5;
reg lsu_busreq_dc2;
reg lsu_busreq_dc3;
reg lsu_busreq_dc4;
wire ldst_samedw_dc5;
wire is_aligned_dc5;

wire [3:0] ldst_byteen_dc2;
reg [3:0] ldst_byteen_dc3;
reg [3:0] ldst_byteen_dc4;
reg [3:0] ldst_byteen_dc5;
wire [7:0] ldst_byteen_ext_dc2;
wire [7:0] ldst_byteen_ext_dc3;
wire [7:0] ldst_byteen_ext_dc4;
wire [7:0] ldst_byteen_ext_dc5;
wire [3:0] ldst_byteen_hi_dc2;
wire [3:0] ldst_byteen_hi_dc3;
wire [3:0] ldst_byteen_hi_dc4;
wire [3:0] ldst_byteen_hi_dc5;
wire [3:0] ldst_byteen_lo_dc2;
wire [3:0] ldst_byteen_lo_dc3;
wire [3:0] ldst_byteen_lo_dc4;
wire [3:0] ldst_byteen_lo_dc5;
reg is_sideeffects_dc4;
reg is_sideeffects_dc5;

wire [31:0] store_data_hi_dc3;
wire [31:0] store_data_hi_dc4;
wire [31:0] store_data_hi_dc5;
wire [31:0] store_data_lo_dc3;
wire [31:0] store_data_lo_dc4;
wire [31:0] store_data_lo_dc5;

wire addr_match_dw_lo_dc5_dc4;
wire addr_match_dw_lo_dc5_dc3;
wire addr_match_dw_lo_dc5_dc2;
wire addr_match_word_lo_dc5_dc4;
wire addr_match_word_lo_dc5_dc3;
wire addr_match_word_lo_dc5_dc2;
wire no_word_merge_dc5;
wire no_dword_merge_dc5;

wire ld_addr_dc3hit_lo_lo;
wire ld_addr_dc3hit_hi_lo;
wire ld_addr_dc3hit_lo_hi;
wire ld_addr_dc3hit_hi_hi;
wire ld_addr_dc4hit_lo_lo;
wire ld_addr_dc4hit_hi_lo;
wire ld_addr_dc4hit_lo_hi;
wire ld_addr_dc4hit_hi_hi;
wire ld_addr_dc5hit_lo_lo;
wire ld_addr_dc5hit_hi_lo;
wire ld_addr_dc5hit_lo_hi;
wire ld_addr_dc5hit_hi_hi;

wire [3:0] ld_byte_dc3hit_lo_lo;
wire [3:0] ld_byte_dc3hit_hi_lo;
wire [3:0] ld_byte_dc3hit_lo_hi;
wire [3:0] ld_byte_dc3hit_hi_hi;
wire [3:0] ld_byte_dc4hit_lo_lo;
wire [3:0] ld_byte_dc4hit_hi_lo;
wire [3:0] ld_byte_dc4hit_lo_hi;
wire [3:0] ld_byte_dc4hit_hi_hi;
wire [3:0] ld_byte_dc5hit_lo_lo;
wire [3:0] ld_byte_dc5hit_hi_lo;
wire [3:0] ld_byte_dc5hit_lo_hi;
wire [3:0] ld_byte_dc5hit_hi_hi;

wire [3:0] ld_byte_hit_lo;
wire [3:0] ld_byte_dc3hit_lo;
wire [3:0] ld_byte_dc4hit_lo;
wire [3:0] ld_byte_dc5hit_lo;
wire [3:0] ld_byte_hit_hi;
wire [3:0] ld_byte_dc3hit_hi;
wire [3:0] ld_byte_dc4hit_hi;
wire [3:0] ld_byte_dc5hit_hi;

wire [31:0] ld_fwddata_dc3pipe_lo;
wire [31:0] ld_fwddata_dc4pipe_lo;
wire [31:0] ld_fwddata_dc5pipe_lo;
wire [31:0] ld_fwddata_dc3pipe_hi;
wire [31:0] ld_fwddata_dc4pipe_hi;
wire [31:0] ld_fwddata_dc5pipe_hi;

wire [pt.NUM_THREADS-1:0] [3:0] ld_byte_hit_buf_lo;
wire [pt.NUM_THREADS-1:0] [3:0] ld_byte_hit_buf_hi;
wire [pt.NUM_THREADS-1:0] [31:0] ld_fwddata_buf_lo;
wire [pt.NUM_THREADS-1:0] [31:0] ld_fwddata_buf_hi;

wire [31:0] ld_fwddata_lo;
wire [31:0] ld_fwddata_hi;
wire [31:0] ld_fwddata_dc2;
wire [31:0] ld_fwddata_dc3;

reg ld_full_hit_hi_dc2;
reg ld_full_hit_lo_dc2;
   wire              ld_full_hit_dc2;

wire [pt.NUM_THREADS-1:0] [pt.LSU_NUM_NBLOAD_WIDTH-1:0] WrPtr0_dc1;
wire [pt.NUM_THREADS-1:0] [pt.LSU_NUM_NBLOAD_WIDTH-1:0] WrPtr0_dc2;
wire [pt.NUM_THREADS-1:0] [pt.LSU_NUM_NBLOAD_WIDTH-1:0] WrPtr0_dc5;

   wire [63:32]     ld_fwddata_dc2_nc;

wire bus_tid;
wire nxt_bus_tid;
wire bus_tid_en;

      reg [pt.NUM_THREADS-1:0]                     obuf_valid;
   reg [pt.NUM_THREADS-1:0]                     obuf_nosend;
   reg [pt.NUM_THREADS-1:0]                     obuf_write;
   reg [pt.NUM_THREADS-1:0]                     obuf_sideeffect;
   reg [pt.NUM_THREADS-1:0][31:0]               obuf_addr;
   reg [pt.NUM_THREADS-1:0][63:0]               obuf_data;
   reg [pt.NUM_THREADS-1:0][1:0]                obuf_sz;
   reg [pt.NUM_THREADS-1:0][7:0]                obuf_byteen;
reg [pt.NUM_THREADS-1:0] obuf_cmd_done;
reg [pt.NUM_THREADS-1:0] obuf_data_done;
   reg [pt.NUM_THREADS-1:0][pt.LSU_BUS_TAG-1:0] obuf_tag0;
   reg [pt.NUM_THREADS-1:0]                     obuf_nxtready;

reg lsu_nonblock_load_valid_dc2;
reg lsu_nonblock_load_valid_dc3;
reg lsu_nonblock_load_valid_dc4;
reg lsu_nonblock_load_valid_dc5;
wire [pt.NUM_THREADS-1:0] [7:0] bus_pend_trxn;
wire [pt.NUM_THREADS-1:0] [7:0] bus_pend_trxn_ns;
wire [pt.NUM_THREADS-1:0] [7:0] bus_pend_trxnQ;
   wire [pt.NUM_THREADS-1:0]           lsu_bus_cntr_overflow;

   reg [pt.NUM_THREADS-1:0]           bus_addr_match_pending;
wire bus_cmd_valid;
wire bus_cmd_sent;
wire bus_cmd_ready;
wire bus_wcmd_sent;
wire bus_wdata_sent;

wire bus_rsp_read;
wire bus_rsp_write;
   reg                                bus_rsp_tid;
wire [pt.LSU_BUS_TAG-1:0] bus_rsp_read_tag;
wire [pt.LSU_BUS_TAG-1:0] bus_rsp_write_tag;
wire bus_rsp_read_tid;
wire bus_rsp_write_tid;
wire bus_rsp_read_error;
wire bus_rsp_write_error;
   wire [63:0]                         bus_rsp_rdata;

reg bus_rsp_valid_q;
reg bus_rsp_ready_q;
reg bus_rsp_write_q;
reg bus_rsp_error_q;
   wire                                bus_rsp_write_tid_q;
   reg [63:0]                         bus_rsp_rdata_q;

   reg [pt.NUM_THREADS-1:0] tid_bus_buffer_pend_any;

   reg [pt.NUM_THREADS-1:0][31:0] tid_imprecise_error_addr_any;     
      reg [pt.NUM_THREADS-1:0]                              tid_nonblock_load_data_ready;
   reg [pt.NUM_THREADS-1:0]                              tid_nonblock_load_data_valid;
   reg [pt.NUM_THREADS-1:0]                              tid_nonblock_load_data_error;
   reg [pt.NUM_THREADS-1:0][pt.LSU_NUM_NBLOAD_WIDTH-1:0] tid_nonblock_load_data_tag;
   reg [pt.NUM_THREADS-1:0][31:0]                        tid_nonblock_load_data;

reg lsu_axi_awvalid_q;
reg lsu_axi_awready_q;
reg lsu_axi_wvalid_q;
reg lsu_axi_wready_q;
reg lsu_axi_arvalid_q;
reg lsu_axi_arready_q;
reg lsu_axi_bvalid_q;
reg lsu_axi_bready_q;
reg lsu_axi_rvalid_q;
reg lsu_axi_rready_q;
reg [pt.LSU_BUS_TAG-1:0] lsu_axi_bid_q;
reg [pt.LSU_BUS_TAG-1:0] lsu_axi_rid_q;
reg [1:0] lsu_axi_bresp_q;
reg [1:0] lsu_axi_rresp_q;
   reg [63:0]            lsu_axi_rdata_q;

   wire                   bus_coalescing_disable;

         
   assign bus_coalescing_disable = dec_tlu_wb_coalescing_disable | pt.BUILD_AHB_LITE;  
   assign ldst_byteen_dc2[3:0] = ({4{lsu_pkt_dc2.by}}   & 4'b0001) |
                                 ({4{lsu_pkt_dc2.half}} & 4'b0011) |
                                 ({4{lsu_pkt_dc2.word}} & 4'b1111);
   assign ldst_dual_dc1   = core_ldst_dual_dc1;
   assign ldst_samedw_dc5 = (lsu_addr_dc5[3] == end_addr_dc5[3]);
   assign is_aligned_dc5    = (lsu_pkt_dc5.word & (lsu_addr_dc5[1:0] == 2'b0)) |
                              (lsu_pkt_dc5.half & (lsu_addr_dc5[0] == 1'b0)) |
                              lsu_pkt_dc5.by;

      assign addr_match_dw_lo_dc5_dc4 = (lsu_addr_dc5[31:3] == lsu_addr_dc4[31:3]);
   assign addr_match_dw_lo_dc5_dc3 = (lsu_addr_dc5[31:3] == lsu_addr_dc3[31:3]);
   assign addr_match_dw_lo_dc5_dc2 = (lsu_addr_dc5[31:3] == lsu_addr_dc2[31:3]);

   assign addr_match_word_lo_dc5_dc4 = addr_match_dw_lo_dc5_dc4 & ~(lsu_addr_dc5[2]^lsu_addr_dc4[2]);
   assign addr_match_word_lo_dc5_dc3 = addr_match_dw_lo_dc5_dc3 & ~(lsu_addr_dc5[2]^lsu_addr_dc3[2]);
   assign addr_match_word_lo_dc5_dc2 = addr_match_dw_lo_dc5_dc2 & ~(lsu_addr_dc5[2]^lsu_addr_dc2[2]);

   assign no_word_merge_dc5  = lsu_busreq_dc5 & ~ldst_dual_dc5 &
                               ((lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid) & (lsu_pkt_dc4.load | ~addr_match_word_lo_dc5_dc4)) |
                                (lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ lsu_pkt_dc5.tid) & ~(lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid)) & (lsu_pkt_dc3.load | ~addr_match_word_lo_dc5_dc3)) |
                                (lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid) & ~(lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ lsu_pkt_dc5.tid)) & ~(lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid)) & (lsu_pkt_dc2.load | ~addr_match_word_lo_dc5_dc2)));

   assign no_dword_merge_dc5  = lsu_busreq_dc5 & ~ldst_dual_dc5 &
                                ((lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid) & (lsu_pkt_dc4.load | ~addr_match_dw_lo_dc5_dc4)) |
                                 (lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ lsu_pkt_dc5.tid) & ~(lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid)) & (lsu_pkt_dc3.load | ~addr_match_dw_lo_dc5_dc3)) |
                                 (lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid) & ~(lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ lsu_pkt_dc5.tid))  & ~(lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ lsu_pkt_dc5.tid))  & (lsu_pkt_dc2.load | ~addr_match_dw_lo_dc5_dc2)));

      assign ldst_byteen_ext_dc2[7:0] = {4'b0,ldst_byteen_dc2[3:0]} << lsu_addr_dc2[1:0];
   assign ldst_byteen_ext_dc3[7:0] = {4'b0,ldst_byteen_dc3[3:0]} << lsu_addr_dc3[1:0];
   assign ldst_byteen_ext_dc4[7:0] = {4'b0,ldst_byteen_dc4[3:0]} << lsu_addr_dc4[1:0];
   assign ldst_byteen_ext_dc5[7:0] = {4'b0,ldst_byteen_dc5[3:0]} << lsu_addr_dc5[1:0];

   assign ldst_byteen_hi_dc2[3:0]   = ldst_byteen_ext_dc2[7:4];
   assign ldst_byteen_lo_dc2[3:0]   = ldst_byteen_ext_dc2[3:0];
   assign ldst_byteen_hi_dc3[3:0]   = ldst_byteen_ext_dc3[7:4];
   assign ldst_byteen_lo_dc3[3:0]   = ldst_byteen_ext_dc3[3:0];
   assign ldst_byteen_hi_dc4[3:0]   = ldst_byteen_ext_dc4[7:4];
   assign ldst_byteen_lo_dc4[3:0]   = ldst_byteen_ext_dc4[3:0];
   assign ldst_byteen_hi_dc5[3:0]   = ldst_byteen_ext_dc5[7:4];
   assign ldst_byteen_lo_dc5[3:0]   = ldst_byteen_ext_dc5[3:0];

   assign store_data_hi_dc3[31:0]   = store_data_ext_dc3[63:32];
   assign store_data_lo_dc3[31:0]   = store_data_ext_dc3[31:0];
   assign store_data_hi_dc4[31:0]   = store_data_ext_dc4[63:32];
   assign store_data_lo_dc4[31:0]   = store_data_ext_dc4[31:0];
   assign store_data_hi_dc5[31:0]   = store_data_ext_dc5[63:32];
   assign store_data_lo_dc5[31:0]   = store_data_ext_dc5[31:0];

   assign ld_addr_dc3hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc3.tid);
   assign ld_addr_dc3hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc3.tid);
   assign ld_addr_dc3hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc3.tid);
   assign ld_addr_dc3hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc3.tid);

   assign ld_addr_dc4hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc4.tid);
   assign ld_addr_dc4hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc4.tid);
   assign ld_addr_dc4hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc4.tid);
   assign ld_addr_dc4hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc4.tid);

   assign ld_addr_dc5hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid);
   assign ld_addr_dc5hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid);
   assign ld_addr_dc5hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid);
   assign ld_addr_dc5hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ lsu_pkt_dc5.tid);

   for (genvar i=0; i<4; i++) begin
      assign ld_byte_dc3hit_lo_lo[i] = ld_addr_dc3hit_lo_lo & ldst_byteen_lo_dc3[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc3hit_lo_hi[i] = ld_addr_dc3hit_lo_hi & ldst_byteen_lo_dc3[i] & ldst_byteen_hi_dc2[i];
      assign ld_byte_dc3hit_hi_lo[i] = ld_addr_dc3hit_hi_lo & ldst_byteen_hi_dc3[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc3hit_hi_hi[i] = ld_addr_dc3hit_hi_hi & ldst_byteen_hi_dc3[i] & ldst_byteen_hi_dc2[i];

      assign ld_byte_dc4hit_lo_lo[i] = ld_addr_dc4hit_lo_lo & ldst_byteen_lo_dc4[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc4hit_lo_hi[i] = ld_addr_dc4hit_lo_hi & ldst_byteen_lo_dc4[i] & ldst_byteen_hi_dc2[i];
      assign ld_byte_dc4hit_hi_lo[i] = ld_addr_dc4hit_hi_lo & ldst_byteen_hi_dc4[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc4hit_hi_hi[i] = ld_addr_dc4hit_hi_hi & ldst_byteen_hi_dc4[i] & ldst_byteen_hi_dc2[i];

      assign ld_byte_dc5hit_lo_lo[i] = ld_addr_dc5hit_lo_lo & ldst_byteen_lo_dc5[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc5hit_lo_hi[i] = ld_addr_dc5hit_lo_hi & ldst_byteen_lo_dc5[i] & ldst_byteen_hi_dc2[i];
      assign ld_byte_dc5hit_hi_lo[i] = ld_addr_dc5hit_hi_lo & ldst_byteen_hi_dc5[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_dc5hit_hi_hi[i] = ld_addr_dc5hit_hi_hi & ldst_byteen_hi_dc5[i] & ldst_byteen_hi_dc2[i];

      assign ld_byte_hit_lo[i] = ld_byte_dc3hit_lo_lo[i] | ld_byte_dc3hit_hi_lo[i] |
                                 ld_byte_dc4hit_lo_lo[i] | ld_byte_dc4hit_hi_lo[i] |
                                 ld_byte_dc5hit_lo_lo[i] | ld_byte_dc5hit_hi_lo[i] |
                                 ld_byte_hit_buf_lo[lsu_pkt_dc2.tid][i];
      assign ld_byte_hit_hi[i] = ld_byte_dc3hit_lo_hi[i] | ld_byte_dc3hit_hi_hi[i] |
                                 ld_byte_dc4hit_lo_hi[i] | ld_byte_dc4hit_hi_hi[i] |
                                 ld_byte_dc5hit_lo_hi[i] | ld_byte_dc5hit_hi_hi[i] |
                                 ld_byte_hit_buf_hi[lsu_pkt_dc2.tid][i];

      assign ld_byte_dc3hit_lo[i] = ld_byte_dc3hit_lo_lo[i] | ld_byte_dc3hit_hi_lo[i];
      assign ld_byte_dc4hit_lo[i] = ld_byte_dc4hit_lo_lo[i] | ld_byte_dc4hit_hi_lo[i];
      assign ld_byte_dc5hit_lo[i] = ld_byte_dc5hit_lo_lo[i] | ld_byte_dc5hit_hi_lo[i];

      assign ld_byte_dc3hit_hi[i] = ld_byte_dc3hit_lo_hi[i] | ld_byte_dc3hit_hi_hi[i];
      assign ld_byte_dc4hit_hi[i] = ld_byte_dc4hit_lo_hi[i] | ld_byte_dc4hit_hi_hi[i];
      assign ld_byte_dc5hit_hi[i] = ld_byte_dc5hit_lo_hi[i] | ld_byte_dc5hit_hi_hi[i];

      assign ld_fwddata_dc3pipe_lo[(8*i)+7:(8*i)] = ({8{ld_byte_dc3hit_lo_lo[i]}} & store_data_lo_dc3[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc3hit_hi_lo[i]}} & store_data_hi_dc3[(8*i)+7:(8*i)]);
      assign ld_fwddata_dc4pipe_lo[(8*i)+7:(8*i)] = ({8{ld_byte_dc4hit_lo_lo[i]}} & store_data_lo_dc4[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc4hit_hi_lo[i]}} & store_data_hi_dc4[(8*i)+7:(8*i)]);
      assign ld_fwddata_dc5pipe_lo[(8*i)+7:(8*i)] = ({8{ld_byte_dc5hit_lo_lo[i]}} & store_data_lo_dc5[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc5hit_hi_lo[i]}} & store_data_hi_dc5[(8*i)+7:(8*i)]);

      assign ld_fwddata_dc3pipe_hi[(8*i)+7:(8*i)] = ({8{ld_byte_dc3hit_lo_hi[i]}} & store_data_lo_dc3[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc3hit_hi_hi[i]}} & store_data_hi_dc3[(8*i)+7:(8*i)]);
      assign ld_fwddata_dc4pipe_hi[(8*i)+7:(8*i)] = ({8{ld_byte_dc4hit_lo_hi[i]}} & store_data_lo_dc4[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc4hit_hi_hi[i]}} & store_data_hi_dc4[(8*i)+7:(8*i)]);
      assign ld_fwddata_dc5pipe_hi[(8*i)+7:(8*i)] = ({8{ld_byte_dc5hit_lo_hi[i]}} & store_data_lo_dc5[(8*i)+7:(8*i)]) |
                                                    ({8{ld_byte_dc5hit_hi_hi[i]}} & store_data_hi_dc5[(8*i)+7:(8*i)]);

            assign ld_fwddata_lo[(8*i)+7:(8*i)] = ld_byte_dc3hit_lo[i]    ? ld_fwddata_dc3pipe_lo[(8*i)+7:(8*i)] :
                                            ld_byte_dc4hit_lo[i]    ? ld_fwddata_dc4pipe_lo[(8*i)+7:(8*i)] :
                                            ld_byte_dc5hit_lo[i]    ? ld_fwddata_dc5pipe_lo[(8*i)+7:(8*i)] :
                                                                      ld_fwddata_buf_lo[lsu_pkt_dc2.tid][(8*i)+7:(8*i)];

      assign ld_fwddata_hi[(8*i)+7:(8*i)] = ld_byte_dc3hit_hi[i]    ? ld_fwddata_dc3pipe_hi[(8*i)+7:(8*i)] :
                                            ld_byte_dc4hit_hi[i]    ? ld_fwddata_dc4pipe_hi[(8*i)+7:(8*i)] :
                                            ld_byte_dc5hit_hi[i]    ? ld_fwddata_dc5pipe_hi[(8*i)+7:(8*i)] :
                                                                      ld_fwddata_buf_hi[lsu_pkt_dc2.tid][(8*i)+7:(8*i)];

   end

   always @* begin
      ld_full_hit_lo_dc2 = 1'b1;
      ld_full_hit_hi_dc2 = 1'b1;
      for (int i=0; i<4; i++) begin
         ld_full_hit_lo_dc2 &= (ld_byte_hit_lo[i] | ~ldst_byteen_lo_dc2[i]);
         ld_full_hit_hi_dc2 &= (ld_byte_hit_hi[i] | ~ldst_byteen_hi_dc2[i]);
      end
   end

      assign ld_full_hit_dc2 = ld_full_hit_lo_dc2 & ld_full_hit_hi_dc2 & lsu_busreq_dc2 & lsu_pkt_dc2.load & ~is_sideeffects_dc2;
   assign {ld_fwddata_dc2_nc[63:32], ld_fwddata_dc2[31:0]} = {ld_fwddata_hi[31:0], ld_fwddata_lo[31:0]} >> (8*lsu_addr_dc2[1:0]);
   assign bus_read_data_dc3[31:0]                          = ld_fwddata_dc3[31:0];

      assign lsu_nonblock_load_valid_dc1 = lsu_busreq_dc1 & lsu_pkt_dc1_pre.valid & lsu_pkt_dc1_pre.load & ~flush_dc2_up[lsu_pkt_dc1_pre.tid];
   assign lsu_nonblock_load_tag_dc1[pt.LSU_NUM_NBLOAD_WIDTH-1:0] = WrPtr0_dc1[lsu_pkt_dc1_pre.tid][pt.LSU_NUM_NBLOAD_WIDTH-1:0];
   assign lsu_nonblock_load_inv_dc2 = lsu_nonblock_load_valid_dc2 & ld_full_hit_dc2;
   assign lsu_nonblock_load_inv_tag_dc2[pt.LSU_NUM_NBLOAD_WIDTH-1:0] = WrPtr0_dc2[lsu_pkt_dc2.tid][pt.LSU_NUM_NBLOAD_WIDTH-1:0];
   assign lsu_nonblock_load_inv_dc5 = lsu_nonblock_load_valid_dc5 & ~lsu_commit_dc5;
   assign lsu_nonblock_load_inv_tag_dc5[pt.LSU_NUM_NBLOAD_WIDTH-1:0] = WrPtr0_dc5[lsu_pkt_dc5.tid][pt.LSU_NUM_NBLOAD_WIDTH-1:0];      
      assign bus_cmd_ready                      = obuf_write[bus_tid] ? ((obuf_cmd_done[bus_tid] | obuf_data_done[bus_tid]) ? (obuf_cmd_done[bus_tid] ? lsu_axi_wready : lsu_axi_awready) : (lsu_axi_awready & lsu_axi_wready)) : lsu_axi_arready;
   assign bus_cmd_valid                      = lsu_axi_awvalid | lsu_axi_wvalid | lsu_axi_arvalid;
   assign bus_wcmd_sent                      = lsu_axi_awvalid & lsu_axi_awready;
   assign bus_wdata_sent                     = lsu_axi_wvalid & lsu_axi_wready;
   assign bus_cmd_sent                       = ((obuf_cmd_done[bus_tid] | bus_wcmd_sent) & (obuf_data_done[bus_tid] | bus_wdata_sent)) | (lsu_axi_arvalid & lsu_axi_arready);

   assign bus_rsp_read                       = lsu_axi_rvalid & lsu_axi_rready;
   assign bus_rsp_write                      = lsu_axi_bvalid & lsu_axi_bready;
   assign bus_rsp_read_tag[pt.LSU_BUS_TAG-1:0]  = lsu_axi_rid[pt.LSU_BUS_TAG-2:0];
   assign bus_rsp_write_tag[pt.LSU_BUS_TAG-1:0] = lsu_axi_bid[pt.LSU_BUS_TAG-2:0];
   assign bus_rsp_write_error                = bus_rsp_write & (lsu_axi_bresp[1:0] != 2'b0);
   assign bus_rsp_read_error                 = bus_rsp_read  & (lsu_axi_rresp[1:0] != 2'b0);
   assign bus_rsp_rdata[63:0]                = lsu_axi_rdata[63:0];
   assign bus_rsp_read_tid                   = lsu_axi_rid[pt.LSU_BUS_TAG-1];
   assign bus_rsp_write_tid                  = lsu_axi_bid[pt.LSU_BUS_TAG-1];

   assign bus_rsp_write_tid_q                = lsu_axi_bid_q[pt.LSU_BUS_TAG-1];

      assign lsu_axi_awvalid               = obuf_valid[bus_tid] & obuf_write[bus_tid] & ~obuf_cmd_done[bus_tid] & ~bus_addr_match_pending[bus_tid];
   assign lsu_axi_awid[pt.LSU_BUS_TAG-1:0] = (pt.LSU_BUS_TAG)'({bus_tid,obuf_tag0[bus_tid][pt.LSU_BUS_TAG-2:0]});
   assign lsu_axi_awaddr[31:0]          = obuf_sideeffect[bus_tid] ? obuf_addr[bus_tid][31:0] : {obuf_addr[bus_tid][31:3],3'b0};
   assign lsu_axi_awsize[2:0]           = obuf_sideeffect[bus_tid] ? {1'b0, obuf_sz[bus_tid][1:0]} : 3'b011;
   assign lsu_axi_awprot[2:0]           = '0;
   assign lsu_axi_awcache[3:0]          = obuf_sideeffect[bus_tid]? 4'b0 : 4'b1111;
   assign lsu_axi_awregion[3:0]         = obuf_addr[bus_tid][31:28];
   assign lsu_axi_awlen[7:0]            = '0;
   assign lsu_axi_awburst[1:0]          = 2'b01;
   assign lsu_axi_awqos[3:0]            = '0;
   assign lsu_axi_awlock                = '0;

   assign lsu_axi_wvalid                = obuf_valid[bus_tid] & obuf_write[bus_tid] & ~obuf_data_done[bus_tid] & ~bus_addr_match_pending[bus_tid];
   assign lsu_axi_wstrb[7:0]            = obuf_byteen[bus_tid][7:0] & {8{obuf_write[bus_tid]}};
   assign lsu_axi_wdata[63:0]           = obuf_data[bus_tid][63:0];
   assign lsu_axi_wlast                 = '1;

   assign lsu_axi_arvalid               = obuf_valid[bus_tid] & ~obuf_nosend[bus_tid] & ~obuf_write[bus_tid] & ~bus_addr_match_pending[bus_tid];
   assign lsu_axi_arid[pt.LSU_BUS_TAG-1:0] = (pt.LSU_BUS_TAG)'({bus_tid,obuf_tag0[bus_tid][pt.LSU_BUS_TAG-2:0]});
   assign lsu_axi_araddr[31:0]          = obuf_sideeffect[bus_tid] ? obuf_addr[bus_tid][31:0] : {obuf_addr[bus_tid][31:3],3'b0};
   assign lsu_axi_arsize[2:0]           = obuf_sideeffect[bus_tid] ? {1'b0, obuf_sz[bus_tid][1:0]} : 3'b011;
   assign lsu_axi_arprot[2:0]           = '0;
   assign lsu_axi_arcache[3:0]          = obuf_sideeffect[bus_tid] ? 4'b0 : 4'b1111;
   assign lsu_axi_arregion[3:0]         = obuf_addr[bus_tid][31:28];
   assign lsu_axi_arlen[7:0]            = '0;
   assign lsu_axi_arburst[1:0]          = 2'b01;
   assign lsu_axi_arqos[3:0]            = '0;
   assign lsu_axi_arlock                = '0;

   assign lsu_axi_bready = 1;
   assign lsu_axi_rready = 1;

      assign bus_pend_trxnQ[pt.NUM_THREADS-1:0]    = '0;
   assign bus_pend_trxn[pt.NUM_THREADS-1:0]     = '0;
   assign lsu_bus_cntr_overflow[pt.NUM_THREADS-1:0] = '0;
   assign lsu_bus_idle_any[pt.NUM_THREADS-1:0]  = {pt.NUM_THREADS{1'b1}};

      for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenPMU
      assign lsu_pmu_bus_trxn[i]       = ((lsu_axi_awvalid & lsu_axi_awready) | (lsu_axi_wvalid & lsu_axi_wready) | (lsu_axi_arvalid & lsu_axi_arready)) & (i == bus_tid);
      assign lsu_pmu_bus_misaligned[i] = lsu_busreq_dc5 & ldst_dual_dc5 & lsu_commit_dc5 & (i == lsu_pkt_dc5.tid);
      assign lsu_pmu_bus_error[i]      = lsu_imprecise_error_load_any[i] | lsu_imprecise_error_store_any[i];
      assign lsu_pmu_bus_busy[i]       = ((lsu_axi_awvalid & ~lsu_axi_awready) | (lsu_axi_wvalid & ~lsu_axi_wready) | (lsu_axi_arvalid & ~lsu_axi_arready)) & (i == bus_tid);
   end
   rvdff #(.WIDTH(1))               lsu_axi_awvalid_ff (.din(lsu_axi_awvalid),                .dout(lsu_axi_awvalid_q),                .clk(lsu_busm_clk), .*);
   rvdff #(.WIDTH(1))               lsu_axi_awready_ff (.din(lsu_axi_awready),                .dout(lsu_axi_awready_q),                .clk(lsu_busm_clk), .*);
   rvdff #(.WIDTH(1))               lsu_axi_wvalid_ff  (.din(lsu_axi_wvalid),                 .dout(lsu_axi_wvalid_q),                 .clk(lsu_busm_clk), .*);
   rvdff #(.WIDTH(1))               lsu_axi_wready_ff  (.din(lsu_axi_wready),                 .dout(lsu_axi_wready_q),                 .clk(lsu_busm_clk), .*);
   rvdff #(.WIDTH(1))               lsu_axi_arvalid_ff (.din(lsu_axi_arvalid),                .dout(lsu_axi_arvalid_q),                .clk(lsu_busm_clk), .*);
   rvdff #(.WIDTH(1))               lsu_axi_arready_ff (.din(lsu_axi_arready),                .dout(lsu_axi_arready_q),                .clk(lsu_busm_clk), .*);

   rvdff  #(.WIDTH(1))              lsu_axi_bvalid_ff  (.din(lsu_axi_bvalid),                 .dout(lsu_axi_bvalid_q),                 .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(1))              lsu_axi_bready_ff  (.din(lsu_axi_bready),                 .dout(lsu_axi_bready_q),                 .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(2))              lsu_axi_bresp_ff   (.din(lsu_axi_bresp[1:0]),             .dout(lsu_axi_bresp_q[1:0]),             .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(pt.LSU_BUS_TAG)) lsu_axi_bid_ff     (.din(lsu_axi_bid[pt.LSU_BUS_TAG-1:0]),.dout(lsu_axi_bid_q[pt.LSU_BUS_TAG-1:0]),.clk(lsu_busm_clk), .*);
   rvdffe #(.WIDTH(64))             lsu_axi_rdata_ff   (.din(lsu_axi_rdata[63:0]),            .dout(lsu_axi_rdata_q[63:0]),            .en(lsu_axi_rvalid & lsu_bus_clk_en), .*);

   rvdff  #(.WIDTH(1))              lsu_axi_rvalid_ff  (.din(lsu_axi_rvalid),                 .dout(lsu_axi_rvalid_q),                 .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(1))              lsu_axi_rready_ff  (.din(lsu_axi_rready),                 .dout(lsu_axi_rready_q),                 .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(2))              lsu_axi_rresp_ff   (.din(lsu_axi_rresp[1:0]),             .dout(lsu_axi_rresp_q[1:0]),             .clk(lsu_busm_clk), .*);
   rvdff  #(.WIDTH(pt.LSU_BUS_TAG)) lsu_axi_rid_ff     (.din(lsu_axi_rid[pt.LSU_BUS_TAG-1:0]),.dout(lsu_axi_rid_q[pt.LSU_BUS_TAG-1:0]),.clk(lsu_busm_clk), .*);


      for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenThreadLoop
            eh2_lsu_bus_buffer #(.pt(pt)) bus_buffer (
         .tid(1'(i)),
         .lsu_bus_ibuf_c1_clk(lsu_bus_ibuf_c1_clk[i]),
         .lsu_bus_buf_c1_clk(lsu_bus_buf_c1_clk[i]),
         .lsu_bus_obuf_c1_clk(lsu_bus_obuf_c1_clk[i]),
         .dec_tlu_force_halt(dec_tlu_force_halt[i]),
         .lsu_bus_cntr_overflow(lsu_bus_cntr_overflow[i]),
         .lsu_bus_idle_any(lsu_bus_idle_any[i]),

         .bus_addr_match_pending(bus_addr_match_pending[i]),
         .lsu_bus_buffer_pend_any(lsu_bus_buffer_pend_any[i]),
         .lsu_bus_buffer_full_any(lsu_bus_buffer_full_any[i]),
         .lsu_bus_buffer_empty_any(lsu_bus_buffer_empty_any[i]),

         .ld_byte_hit_buf_lo(ld_byte_hit_buf_lo[i]),
         .ld_byte_hit_buf_hi(ld_byte_hit_buf_hi[i]),
         .ld_fwddata_buf_lo(ld_fwddata_buf_lo[i]),
         .ld_fwddata_buf_hi(ld_fwddata_buf_hi[i]),

         .lsu_imprecise_error_load_any(lsu_imprecise_error_load_any[i]),
         .lsu_imprecise_error_store_any(lsu_imprecise_error_store_any[i]),
         .lsu_imprecise_error_addr_any(lsu_imprecise_error_addr_any[i]),

         .WrPtr0_dc1(WrPtr0_dc1[i]),
         .WrPtr0_dc2(WrPtr0_dc2[i]),
         .WrPtr0_dc5(WrPtr0_dc5[i]),

         .obuf_valid(obuf_valid[i]),
         .obuf_nosend(obuf_nosend[i]),
         .obuf_write(obuf_write[i]),
         .obuf_sideeffect(obuf_sideeffect[i]),
         .obuf_addr(obuf_addr[i]),
         .obuf_data(obuf_data[i]),
         .obuf_sz(obuf_sz[i]),
         .obuf_byteen(obuf_byteen[i]),
         .obuf_cmd_done(obuf_cmd_done[i]),
         .obuf_data_done(obuf_data_done[i]),
         .obuf_tag0(obuf_tag0[i]),
         .obuf_nxtready(obuf_nxtready[i]),

         .lsu_nonblock_load_data_ready(tid_nonblock_load_data_ready[i]),
         .lsu_nonblock_load_data_valid(tid_nonblock_load_data_valid[i]),
         .lsu_nonblock_load_data_error(tid_nonblock_load_data_error[i]),
         .lsu_nonblock_load_data_tag(tid_nonblock_load_data_tag[i]),
         .lsu_nonblock_load_data(tid_nonblock_load_data[i]),
         .*

      );
   end

                     
   always @* begin
      lsu_nonblock_load_data_valid = '0;
      lsu_nonblock_load_data_error = '0;
      lsu_nonblock_load_data_tag   = '0;
      lsu_nonblock_load_data       = '0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         lsu_nonblock_load_data_valid |= (tid_nonblock_load_data_valid[i] & (lsu_nonblock_load_data_tid == i));
         lsu_nonblock_load_data_error |= (tid_nonblock_load_data_error[i] & (lsu_nonblock_load_data_tid == i));
         lsu_nonblock_load_data_tag   |= {(pt.LSU_NUM_NBLOAD_WIDTH){lsu_nonblock_load_data_tid == i}} & tid_nonblock_load_data_tag[i];
         lsu_nonblock_load_data       |= {32{lsu_nonblock_load_data_tid == i}} & tid_nonblock_load_data[i];
      end
   end

      if (pt.NUM_THREADS == 2) begin: GenMT
      assign nxt_bus_tid = bus_tid ? (~(obuf_nxtready[0] | obuf_valid[0]) & obuf_nxtready[1]) :
                                     (~obuf_nxtready[0] | (obuf_nxtready[1] | obuf_valid[1]));
      assign bus_tid_en  = bus_cmd_sent | (~bus_cmd_valid & (obuf_nxtready[0] | obuf_nxtready[1]) & ~obuf_nxtready[bus_tid]) | (~obuf_valid[bus_tid] & obuf_valid[~bus_tid]);
     rvdffs #(.WIDTH(1)) bus_tidff (.din(nxt_bus_tid), .dout(bus_tid), .en(bus_tid_en), .clk(lsu_busm_clk), .*);

   end else begin: GenST
      assign bus_tid = 1'b0;
   end

      if (pt.NUM_THREADS == 2) begin: GenNBTID_MT
      rvarbiter2 nbtid_arbiter (
         .ready(tid_nonblock_load_data_ready[1:0]),
         .shift(lsu_nonblock_load_data_valid | lsu_nonblock_load_data_tid),
         .tid  (lsu_nonblock_load_data_tid),   
      .*);
   end else begin: GenNBTID_ST
      assign lsu_nonblock_load_data_tid = '0;
   end

      rvdff #(.WIDTH(32)) lsu_fwddata_dc3ff (.din(ld_fwddata_dc2[31:0]), .dout(ld_fwddata_dc3[31:0]), .clk(lsu_c1_dc3_clk), .*);

   rvdff #(.WIDTH(1)) clken_ff (.din(lsu_bus_clk_en), .dout(lsu_bus_clk_en_q), .clk(free_clk), .*);

   rvdff #(.WIDTH(1)) ldst_dual_dc2ff (.din(ldst_dual_dc1), .dout(ldst_dual_dc2), .clk(lsu_c1_dc2_clk), .*);
   rvdff #(.WIDTH(1)) ldst_dual_dc3ff (.din(ldst_dual_dc2), .dout(ldst_dual_dc3), .clk(lsu_c1_dc3_clk),  .*);
   rvdff #(.WIDTH(1)) ldst_dual_dc4ff (.din(ldst_dual_dc3), .dout(ldst_dual_dc4), .clk(lsu_c1_dc4_clk), .*);
   rvdff #(.WIDTH(1)) ldst_dual_dc5ff (.din(ldst_dual_dc4), .dout(ldst_dual_dc5), .clk(lsu_c1_dc5_clk), .*);
   rvdff #(.WIDTH(1)) is_sideeffects_dc4ff (.din(is_sideeffects_dc3), .dout(is_sideeffects_dc4), .clk(lsu_c1_dc4_clk), .*);
   rvdff #(.WIDTH(1)) is_sideeffects_dc5ff (.din(is_sideeffects_dc4), .dout(is_sideeffects_dc5), .clk(lsu_c1_dc5_clk), .*);

   rvdff #(4) lsu_byten_dc3ff (.*, .din(ldst_byteen_dc2[3:0]), .dout(ldst_byteen_dc3[3:0]), .clk(lsu_c1_dc3_clk));
   rvdff #(4) lsu_byten_dc4ff (.*, .din(ldst_byteen_dc3[3:0]), .dout(ldst_byteen_dc4[3:0]), .clk(lsu_c1_dc4_clk));
   rvdff #(4) lsu_byten_dc5ff (.*, .din(ldst_byteen_dc4[3:0]), .dout(ldst_byteen_dc5[3:0]), .clk(lsu_c1_dc5_clk));

   rvdff #(.WIDTH(1)) lsu_busreq_dc2ff (.din(lsu_busreq_dc1), .dout(lsu_busreq_dc2), .clk(lsu_c2_dc2_clk), .*);  // Don't want dc2 to dc3 propagation during freeze.
   rvdff #(.WIDTH(1)) lsu_busreq_dc3ff (.din(lsu_busreq_dc2 & ~ld_full_hit_dc2), .dout(lsu_busreq_dc3), .clk(lsu_c2_dc3_clk), .*);  // Don't want dc2 to dc3 propagation during freeze.
   rvdff #(.WIDTH(1)) lsu_busreq_dc4ff (.din(lsu_busreq_dc3 & ~flush_dc3[lsu_pkt_dc3.tid]),      .dout(lsu_busreq_dc4), .clk(lsu_c2_dc4_clk), .*);
   rvdff #(.WIDTH(1)) lsu_busreq_dc5ff (.din(lsu_busreq_dc4 & ~flush_dc4[lsu_pkt_dc4.tid]),      .dout(lsu_busreq_dc5), .clk(lsu_c2_dc5_clk), .*);

   rvdff #(.WIDTH(1)) lsu_nonblock_load_valid_dc2ff  (.din(lsu_nonblock_load_valid_dc1),  .dout(lsu_nonblock_load_valid_dc2), .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) lsu_nonblock_load_valid_dc3ff  (.din(lsu_nonblock_load_valid_dc2),  .dout(lsu_nonblock_load_valid_dc3), .clk(lsu_c2_dc3_clk), .*);
   rvdff #(.WIDTH(1)) lsu_nonblock_load_valid_dc4ff  (.din(lsu_nonblock_load_valid_dc3),  .dout(lsu_nonblock_load_valid_dc4), .clk(lsu_c2_dc4_clk), .*);
   rvdff #(.WIDTH(1)) lsu_nonblock_load_valid_dc5ff  (.din(lsu_nonblock_load_valid_dc4),  .dout(lsu_nonblock_load_valid_dc5), .clk(lsu_c2_dc5_clk), .*);

`ifdef ASSERT_ON

   











`endif

endmodule 