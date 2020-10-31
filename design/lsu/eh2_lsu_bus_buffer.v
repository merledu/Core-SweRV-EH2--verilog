

module eh2_lsu_bus_buffer
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(
   input wire clk,
   input wire rst_l,
   input wire scan_mode,
   input wire dec_tlu_external_ldfwd_disable,        input wire dec_tlu_sideeffect_posted_disable,     input wire dec_tlu_wb_coalescing_disable,         input wire bus_coalescing_disable,
   input wire dec_tlu_force_halt,

      input wire lsu_c2_dc2_clk,
   input wire lsu_c2_dc3_clk,
   input wire lsu_c2_dc4_clk,
   input wire lsu_c2_dc5_clk,

   input wire lsu_bus_ibuf_c1_clk,
   input wire lsu_bus_obuf_c1_clk,
   input wire lsu_bus_buf_c1_clk,
   input wire lsu_free_c2_clk,
   input wire lsu_busm_clk,


   input                                eh2_lsu_pkt_t lsu_pkt_dc1_pre,           input                                eh2_lsu_pkt_t lsu_pkt_dc2,               input                                eh2_lsu_pkt_t lsu_pkt_dc3,               input                                eh2_lsu_pkt_t lsu_pkt_dc4,               input                                eh2_lsu_pkt_t lsu_pkt_dc5,            
   input wire tid,
   input wire bus_tid,
   input wire [31:0]                   lsu_addr_dc2,                        input wire [31:0]                   end_addr_dc2,                        input wire [31:0]                   lsu_addr_dc5,                        input wire [31:0]                   end_addr_dc5,                        input wire [63:0]                   store_data_ext_dc5,               
   input wire [3:0]                    ldst_byteen_hi_dc5,
   input wire [3:0]                    ldst_byteen_lo_dc5,
   input wire [31:0]                   store_data_hi_dc5,
   input wire [31:0]                   store_data_lo_dc5,

   input wire ldst_samedw_dc5,                     input wire is_aligned_dc5,                      input wire no_word_merge_dc5,                   input wire no_dword_merge_dc5,                  input wire lsu_busreq_dc1,                      input wire lsu_busreq_dc2,                      input wire lsu_busreq_dc3,                      input wire lsu_busreq_dc4,                      input wire lsu_busreq_dc5,                      input wire ld_full_hit_dc2,                     input wire lsu_commit_dc5,                      input wire is_sideeffects_dc5,                  input wire ldst_dual_dc1,                       input wire ldst_dual_dc2,                       input wire ldst_dual_dc3,                       input wire ldst_dual_dc4,                       input wire ldst_dual_dc5,                       input wire lsu_nonblock_load_valid_dc5,

   input wire [7:0]                    ldst_byteen_ext_dc2,

   input wire lsu_bus_cntr_overflow,
   input wire bus_cmd_sent, bus_cmd_ready,
   input wire bus_wcmd_sent, bus_wdata_sent,
   input wire bus_rsp_read, bus_rsp_write,
   input wire [pt.LSU_BUS_TAG-1:0]     bus_rsp_read_tag, bus_rsp_write_tag,
   input wire bus_rsp_read_tid, bus_rsp_write_tid,
   input wire bus_rsp_read_error, bus_rsp_write_error,
   input wire [63:0]                   bus_rsp_rdata,

   input wire bus_rsp_valid_q,
   input wire bus_rsp_ready_q,
   input wire bus_rsp_write_q,
   input wire bus_rsp_error_q,
   input wire bus_rsp_write_tid_q,
   input wire [63:0]                   bus_rsp_rdata_q,

   output logic                         bus_addr_match_pending,
   output logic                         lsu_bus_buffer_pend_any,             output logic                         lsu_bus_buffer_full_any,             output logic                         lsu_bus_buffer_empty_any,            input wire lsu_bus_idle_any,                 
   output logic [3:0]                   ld_byte_hit_buf_lo, ld_byte_hit_buf_hi,       output logic [31:0]                  ld_fwddata_buf_lo, ld_fwddata_buf_hi,      
   output logic                         lsu_imprecise_error_load_any,        output logic                         lsu_imprecise_error_store_any,       output logic [31:0]                  lsu_imprecise_error_addr_any,     
   output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] WrPtr0_dc1, WrPtr0_dc2, WrPtr0_dc5,

      output logic                               obuf_valid,
   output logic                               obuf_nosend,
   output logic                               obuf_write,
   output logic                               obuf_sideeffect,
   output logic [31:0]                        obuf_addr,
   output logic [63:0]                        obuf_data,
   output logic [1:0]                         obuf_sz,
   output logic [7:0]                         obuf_byteen,
   output logic                               obuf_cmd_done, obuf_data_done,
   output logic [pt.LSU_BUS_TAG-1:0]          obuf_tag0,
   output logic                               obuf_nxtready,

      input wire lsu_nonblock_load_data_tid,         output logic                               lsu_nonblock_load_data_ready,       output logic                               lsu_nonblock_load_data_valid,       output logic                               lsu_nonblock_load_data_error,       output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0] lsu_nonblock_load_data_tag,         output logic [31:0]                        lsu_nonblock_load_data,          
   input wire lsu_bus_clk_en,
   input wire lsu_bus_clk_en_q

);

localparam IDLE = 'd 0 ;localparam WAIT = 'd 1 ;localparam CMD = 'd 2 ;localparam RESP = 'd 3 ;localparam DONE_PARTIAL = 'd 4 ;localparam DONE_WAIT = 'd 5 ;localparam DONE = 'd 6 ;
   localparam DEPTH     = pt.LSU_NUM_NBLOAD;
   localparam DEPTH_LOG2 = pt.LSU_NUM_NBLOAD_WIDTH;
   localparam TIMER     = 8;      localparam TIMER_LOG2 = (TIMER < 2) ? 1 : $clog2(TIMER);
   localparam TIMER_MAX = (TIMER == 0) ? TIMER_LOG2'(0) : TIMER_LOG2'(TIMER - 1);  
wire [3:0] ldst_byteen_hi_dc2;
wire [3:0] ldst_byteen_lo_dc2;
wire [DEPTH-1:0] ld_addr_hitvec_lo;
wire [DEPTH-1:0] ld_addr_hitvec_hi;
reg [3:0] [DEPTH-1:0] ld_byte_hitvec_lo;
reg [3:0] [DEPTH-1:0] ld_byte_hitvec_hi;
reg [3:0] [DEPTH-1:0] ld_byte_hitvecfn_lo;
reg [3:0] [DEPTH-1:0] ld_byte_hitvecfn_hi;

wire ld_addr_ibuf_hit_lo;
wire ld_addr_ibuf_hit_hi;
wire [3:0] ld_byte_ibuf_hit_lo;
wire [3:0] ld_byte_ibuf_hit_hi;

reg [31:0] lsu_nonblock_load_data_hi;
reg [31:0] lsu_nonblock_load_data_lo;
wire [31:0] lsu_nonblock_data_unalgn;
   wire [1:0]                          lsu_nonblock_addr_offset;
   wire [1:0]                          lsu_nonblock_sz;
   reg                                lsu_nonblock_load_rtn_valid;
wire lsu_nonblock_unsign;
wire lsu_nonblock_dual;
   reg [DEPTH_LOG2-1:0]               lsu_imprecise_error_load_tag;
   reg [pt.LSU_BUS_TAG-1:0]           lsu_imprecise_error_store_tag;


wire [DEPTH-1:0] CmdPtr0Dec;
wire [DEPTH-1:0] CmdPtr1Dec;
   wire [DEPTH-1:0]                    RspPtrDec;
wire [DEPTH_LOG2-1:0] CmdPtr0;
wire [DEPTH_LOG2-1:0] CmdPtr1;
   wire [DEPTH_LOG2-1:0]               RspPtr;
reg [DEPTH_LOG2-1:0] WrPtr0_dc3;
reg [DEPTH_LOG2-1:0] WrPtr0_dc4;
reg [DEPTH_LOG2-1:0] WrPtr1_dc1;
reg [DEPTH_LOG2-1:0] WrPtr1_dc2;
reg [DEPTH_LOG2-1:0] WrPtr1_dc3;
reg [DEPTH_LOG2-1:0] WrPtr1_dc4;
reg [DEPTH_LOG2-1:0] WrPtr1_dc5;
reg found_wrptr0;
reg found_wrptr1;
wire found_cmdptr0;
wire found_cmdptr1;
reg [3:0] buf_numvld_any;
reg [3:0] buf_numvld_wrcmd_any;
reg [3:0] buf_numvld_pend_any;
reg [3:0] buf_numvld_cmd_any;
reg any_done_wait_state;
reg any_done_state;
   reg                                bus_sideeffect_pend;

      state_t [DEPTH-1:0]                  buf_state;
   wire   [DEPTH-1:0][1:0]             buf_sz;
   wire   [DEPTH-1:0][31:0]            buf_addr;
   wire   [DEPTH-1:0][3:0]             buf_byteen;
   wire   [DEPTH-1:0]                  buf_sideeffect;
   wire   [DEPTH-1:0]                  buf_write;
   wire   [DEPTH-1:0]                  buf_unsign;
   wire   [DEPTH-1:0]                  buf_dual;
   wire   [DEPTH-1:0]                  buf_samedw;
   wire   [DEPTH-1:0]                  buf_nomerge;
   wire   [DEPTH-1:0]                  buf_dualhi;
   wire   [DEPTH-1:0][DEPTH_LOG2-1:0]  buf_dualtag;
   reg   [DEPTH-1:0]                  buf_ldfwd;
   reg   [DEPTH-1:0][DEPTH_LOG2-1:0]  buf_ldfwdtag;
   reg   [DEPTH-1:0]                  buf_error;
   wire   [DEPTH-1:0][31:0]            buf_data;
reg [DEPTH-1:0] [DEPTH-1:0] buf_age;
reg [DEPTH-1:0] [DEPTH-1:0] buf_age_younger;
reg [DEPTH-1:0] [DEPTH-1:0] buf_rspage;
reg [DEPTH-1:0] [DEPTH-1:0] buf_rsp_pickage;

   state_t [DEPTH-1:0]                  buf_nxtstate;
   wire   [DEPTH-1:0]                  buf_rst;
   reg   [DEPTH-1:0]                  buf_state_en;
   reg   [DEPTH-1:0]                  buf_cmd_state_bus_en;
   reg   [DEPTH-1:0]                  buf_resp_state_bus_en;
   reg   [DEPTH-1:0]                  buf_state_bus_en;
   wire   [DEPTH-1:0]                  buf_dual_in;
   wire   [DEPTH-1:0]                  buf_samedw_in;
   wire   [DEPTH-1:0]                  buf_nomerge_in;
   wire   [DEPTH-1:0]                  buf_sideeffect_in;
   wire   [DEPTH-1:0]                  buf_unsign_in;
   wire   [DEPTH-1:0][1:0]             buf_sz_in;
   wire   [DEPTH-1:0]                  buf_write_in;
   wire   [DEPTH-1:0]                  buf_wr_en;
   wire   [DEPTH-1:0]                  buf_dualhi_in;
   wire   [DEPTH-1:0][DEPTH_LOG2-1:0]  buf_dualtag_in;
   reg   [DEPTH-1:0]                  buf_ldfwd_en;
   reg   [DEPTH-1:0]                  buf_ldfwd_in;
   reg   [DEPTH-1:0][DEPTH_LOG2-1:0]  buf_ldfwdtag_in;
   wire   [DEPTH-1:0][3:0]             buf_byteen_in;
   wire   [DEPTH-1:0][31:0]            buf_addr_in;
   wire   [DEPTH-1:0][31:0]            buf_data_in;
   reg   [DEPTH-1:0]                  buf_error_en;
   reg   [DEPTH-1:0]                  buf_data_en;
   wire   [DEPTH-1:0][DEPTH-1:0]       buf_age_set;
   wire   [DEPTH-1:0][DEPTH-1:0]       buf_age_in;
   reg   [DEPTH-1:0][DEPTH-1:0]       buf_ageQ;
   wire   [DEPTH-1:0][DEPTH-1:0]       buf_rspage_set;
   wire   [DEPTH-1:0][DEPTH-1:0]       buf_rspage_in;
   reg   [DEPTH-1:0][DEPTH-1:0]       buf_rspageQ;

      reg                               ibuf_valid;
   wire                               ibuf_dual;
   reg                               ibuf_samedw;
   reg                               ibuf_nomerge;
   wire [DEPTH_LOG2-1:0]              ibuf_tag;
   wire [DEPTH_LOG2-1:0]              ibuf_dualtag;
   reg                               ibuf_sideeffect;
   reg                               ibuf_unsign;
   reg                               ibuf_write;
   wire [1:0]                         ibuf_sz;
   wire [3:0]                         ibuf_byteen;
   reg [31:0]                        ibuf_addr;
   wire [31:0]                        ibuf_data;
   wire [TIMER_LOG2-1:0]              ibuf_timer;

   wire                               ibuf_byp;
   reg                               ibuf_wr_en;
   wire                               ibuf_rst;
   wire                               ibuf_force_drain;
   reg                               ibuf_drain_vld;
   wire [DEPTH-1:0]                   ibuf_drainvec_vld;
   wire [DEPTH_LOG2-1:0]              ibuf_tag_in;
   wire [DEPTH_LOG2-1:0]              ibuf_dualtag_in;
   wire [1:0]                         ibuf_sz_in;
   reg [31:0]                        ibuf_addr_in;
   wire [3:0]                         ibuf_byteen_in;
   wire [31:0]                        ibuf_data_in;
   wire [TIMER_LOG2-1:0]              ibuf_timer_in;
   wire [3:0]                         ibuf_byteen_out;
   wire [31:0]                        ibuf_data_out;
wire ibuf_merge_en;
wire ibuf_merge_in;

      wire                               obuf_merge;
   wire                               obuf_rdrsp_pend;
   wire [pt.LSU_BUS_TAG-1:0]          obuf_tag1;
   wire [pt.LSU_BUS_TAG-1:0]          obuf_rdrsp_tag;

   reg                               ibuf_buf_byp;
   wire                               obuf_force_wr_en;
   wire                               obuf_wr_wait;
wire obuf_wr_en;
reg obuf_wr_enQ;
   reg                               obuf_rst;
   wire                               obuf_write_in;
   wire                               obuf_nosend_in;
   wire                               obuf_rdrsp_pend_in;
   wire                               obuf_sideeffect_in;
   wire                               obuf_aligned_in;
   wire [31:0]                        obuf_addr_in;
   wire [63:0]                        obuf_data_in;
   wire [1:0]                         obuf_sz_in;
   wire [7:0]                         obuf_byteen_in;
wire obuf_cmd_done_in;
wire obuf_data_done_in;
   wire                               obuf_merge_in;
   wire [pt.LSU_BUS_TAG-1:0]          obuf_tag0_in;
   wire [pt.LSU_BUS_TAG-1:0]          obuf_tag1_in;
   wire [pt.LSU_BUS_TAG-1:0]          obuf_rdrsp_tag_in;

   wire                               obuf_merge_en;
wire [TIMER_LOG2-1:0] obuf_wr_timer;
wire [TIMER_LOG2-1:0] obuf_wr_timer_in;
wire [7:0] obuf_byteen0_in;
wire [7:0] obuf_byteen1_in;
wire [63:0] obuf_data0_in;
wire [63:0] obuf_data1_in;

      function automatic logic [2:0] f_Enc8to3;
      input [7:0] Dec_value;

      reg [2:0]       Enc_value;
      Enc_value[0] = Dec_value[1] | Dec_value[3] | Dec_value[5] | Dec_value[7];
      Enc_value[1] = Dec_value[2] | Dec_value[3] | Dec_value[6] | Dec_value[7];
      Enc_value[2] = Dec_value[4] | Dec_value[5] | Dec_value[6] | Dec_value[7];

      return Enc_value[2:0];
   endfunction 
         
         
      assign ldst_byteen_hi_dc2[3:0]   = ldst_byteen_ext_dc2[7:4];
   assign ldst_byteen_lo_dc2[3:0]   = ldst_byteen_ext_dc2[3:0];
   for (genvar i=0; i<DEPTH; i++) begin
            assign ld_addr_hitvec_lo[i] = (lsu_addr_dc2[31:2] == buf_addr[i][31:2]) & buf_write[i] & ((buf_state[i] == WAIT) | (buf_state[i] == CMD)) & (lsu_pkt_dc2.tid ~^ tid) & lsu_busreq_dc2;
      assign ld_addr_hitvec_hi[i] = (end_addr_dc2[31:2] == buf_addr[i][31:2]) & buf_write[i] & ((buf_state[i] == WAIT) | (buf_state[i] == CMD)) & (lsu_pkt_dc2.tid ~^ tid) & lsu_busreq_dc2;
   end

   for (genvar j=0; j<4; j++) begin
     assign ld_byte_hit_buf_lo[j] = |(ld_byte_hitvecfn_lo[j]) | ld_byte_ibuf_hit_lo[j];
     assign ld_byte_hit_buf_hi[j] = |(ld_byte_hitvecfn_hi[j]) | ld_byte_ibuf_hit_hi[j];
     for (genvar i=0; i<DEPTH; i++) begin
         assign ld_byte_hitvec_lo[j][i] = ld_addr_hitvec_lo[i] & buf_byteen[i][j] & ldst_byteen_lo_dc2[j];
         assign ld_byte_hitvec_hi[j][i] = ld_addr_hitvec_hi[i] & buf_byteen[i][j] & ldst_byteen_hi_dc2[j];

         assign ld_byte_hitvecfn_lo[j][i] = ld_byte_hitvec_lo[j][i] & ~(|(ld_byte_hitvec_lo[j] & buf_age_younger[i])) & ~ld_byte_ibuf_hit_lo[j];           assign ld_byte_hitvecfn_hi[j][i] = ld_byte_hitvec_hi[j][i] & ~(|(ld_byte_hitvec_hi[j] & buf_age_younger[i])) & ~ld_byte_ibuf_hit_hi[j];        end
   end

      assign ld_addr_ibuf_hit_lo = (lsu_addr_dc2[31:2] == ibuf_addr[31:2]) & (lsu_pkt_dc2.tid ~^ tid) & ibuf_write & ibuf_valid & lsu_busreq_dc2;
   assign ld_addr_ibuf_hit_hi = (end_addr_dc2[31:2] == ibuf_addr[31:2]) & (lsu_pkt_dc2.tid ~^ tid) & ibuf_write & ibuf_valid & lsu_busreq_dc2;

   for (genvar i=0; i<4; i++) begin
      assign ld_byte_ibuf_hit_lo[i] = ld_addr_ibuf_hit_lo & ibuf_byteen[i] & ldst_byteen_lo_dc2[i];
      assign ld_byte_ibuf_hit_hi[i] = ld_addr_ibuf_hit_hi & ibuf_byteen[i] & ldst_byteen_hi_dc2[i];
   end

   always @* begin
      ld_fwddata_buf_lo[31:0] = {{8{ld_byte_ibuf_hit_lo[3]}},{8{ld_byte_ibuf_hit_lo[2]}},{8{ld_byte_ibuf_hit_lo[1]}},{8{ld_byte_ibuf_hit_lo[0]}}} & ibuf_data[31:0];
      ld_fwddata_buf_hi[31:0] = {{8{ld_byte_ibuf_hit_hi[3]}},{8{ld_byte_ibuf_hit_hi[2]}},{8{ld_byte_ibuf_hit_hi[1]}},{8{ld_byte_ibuf_hit_hi[0]}}} & ibuf_data[31:0];
      for (int i=0; i<DEPTH; i++) begin
         ld_fwddata_buf_lo[7:0]   |= {8{ld_byte_hitvecfn_lo[0][i]}} & buf_data[i][7:0];
         ld_fwddata_buf_lo[15:8]  |= {8{ld_byte_hitvecfn_lo[1][i]}} & buf_data[i][15:8];
         ld_fwddata_buf_lo[23:16] |= {8{ld_byte_hitvecfn_lo[2][i]}} & buf_data[i][23:16];
         ld_fwddata_buf_lo[31:24] |= {8{ld_byte_hitvecfn_lo[3][i]}} & buf_data[i][31:24];

         ld_fwddata_buf_hi[7:0]   |= {8{ld_byte_hitvecfn_hi[0][i]}} & buf_data[i][7:0];
         ld_fwddata_buf_hi[15:8]  |= {8{ld_byte_hitvecfn_hi[1][i]}} & buf_data[i][15:8];
         ld_fwddata_buf_hi[23:16] |= {8{ld_byte_hitvecfn_hi[2][i]}} & buf_data[i][23:16];
         ld_fwddata_buf_hi[31:24] |= {8{ld_byte_hitvecfn_hi[3][i]}} & buf_data[i][31:24];
      end
   end

         
         
   assign ibuf_byp   = lsu_busreq_dc5 & ((lsu_pkt_dc5.load | no_word_merge_dc5) & ~ibuf_valid);       assign ibuf_wr_en = lsu_busreq_dc5 & lsu_commit_dc5 & (lsu_pkt_dc5.tid ~^ tid) & ~ibuf_byp;
   assign ibuf_rst   = (ibuf_drain_vld & ~ibuf_wr_en) | dec_tlu_force_halt;
   assign ibuf_force_drain = lsu_busreq_dc2 & ~lsu_busreq_dc3 & ~lsu_busreq_dc4 & ~lsu_busreq_dc5 & ibuf_valid & (lsu_pkt_dc2.load | (ibuf_addr[31:2] != lsu_addr_dc2[31:2]));     assign ibuf_drain_vld = ibuf_valid & (((ibuf_wr_en | (ibuf_timer == TIMER_MAX)) & ~(ibuf_merge_en & ibuf_merge_in)) | ibuf_byp | ibuf_force_drain | ibuf_sideeffect | ~ibuf_write | bus_coalescing_disable);
   assign ibuf_tag_in[DEPTH_LOG2-1:0] = (ibuf_merge_en & ibuf_merge_in) ? ibuf_tag[DEPTH_LOG2-1:0] : (ldst_dual_dc5 ? WrPtr1_dc5 : WrPtr0_dc5);
   assign ibuf_dualtag_in[DEPTH_LOG2-1:0] = WrPtr0_dc5;
   assign ibuf_sz_in[1:0]   = {lsu_pkt_dc5.word, lsu_pkt_dc5.half};    assign ibuf_addr_in[31:0] = ldst_dual_dc5 ? end_addr_dc5[31:0] : lsu_addr_dc5[31:0];
   assign ibuf_byteen_in[3:0] = (ibuf_merge_en & ibuf_merge_in) ? (ibuf_byteen[3:0] | ldst_byteen_lo_dc5[3:0]) : (ldst_dual_dc5 ? ldst_byteen_hi_dc5[3:0] : ldst_byteen_lo_dc5[3:0]);
   for (genvar i=0; i<4; i++) begin
      assign ibuf_data_in[(8*i)+7:(8*i)] = (ibuf_merge_en & ibuf_merge_in) ? (ldst_byteen_lo_dc5[i] ? store_data_lo_dc5[(8*i)+7:(8*i)] : ibuf_data[(8*i)+7:(8*i)]) :
                                                                             (ldst_dual_dc5 ? store_data_hi_dc5[(8*i)+7:(8*i)] : store_data_lo_dc5[(8*i)+7:(8*i)]);
   end
   assign ibuf_timer_in = ibuf_wr_en ? 'd0 : (ibuf_timer < TIMER_MAX) ? (ibuf_timer + 1'b1) : ibuf_timer;

   assign ibuf_merge_en = lsu_busreq_dc5 & lsu_commit_dc5 & (lsu_pkt_dc5.tid ~^ tid) & lsu_pkt_dc5.store &
                          ibuf_valid & ibuf_write & (lsu_addr_dc5[31:2] == ibuf_addr[31:2]) & ~is_sideeffects_dc5 & ~bus_coalescing_disable;
   assign ibuf_merge_in = ~ldst_dual_dc5;   
      for (genvar i=0; i<4; i++) begin
      assign ibuf_byteen_out[i] = (ibuf_merge_en & ~ibuf_merge_in) ? (ibuf_byteen[i] | ldst_byteen_lo_dc5[i]) : ibuf_byteen[i];
      assign ibuf_data_out[(8*i)+7:(8*i)] = (ibuf_merge_en & ~ibuf_merge_in) ? (ldst_byteen_lo_dc5[i] ? store_data_lo_dc5[(8*i)+7:(8*i)] : ibuf_data[(8*i)+7:(8*i)]) :
                                                                                                        ibuf_data[(8*i)+7:(8*i)];
   end
      rvdffsc #(.WIDTH(1))              ibuf_valid_ff     (.din(1'b1),                        .dout(ibuf_valid),      .en(ibuf_wr_en), .clear(ibuf_rst), .clk(lsu_free_c2_clk), .*);
   rvdffs  #(.WIDTH(DEPTH_LOG2))     ibuf_tagff        (.din(ibuf_tag_in),                 .dout(ibuf_tag),        .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(DEPTH_LOG2))     ibuf_dualtagff    (.din(ibuf_dualtag_in),             .dout(ibuf_dualtag),    .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_dualff       (.din(ldst_dual_dc5),               .dout(ibuf_dual),       .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_samedwff     (.din(ldst_samedw_dc5),             .dout(ibuf_samedw),     .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_nomergeff    (.din(no_dword_merge_dc5),          .dout(ibuf_nomerge),    .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_sideeffectff (.din(is_sideeffects_dc5),          .dout(ibuf_sideeffect), .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_unsignff     (.din(lsu_pkt_dc5.unsign),          .dout(ibuf_unsign),     .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              ibuf_writeff      (.din(lsu_pkt_dc5.store),           .dout(ibuf_write),      .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffs  #(.WIDTH(2))              ibuf_szff         (.din(ibuf_sz_in[1:0]),             .dout(ibuf_sz),         .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffe  #(.WIDTH(32))             ibuf_addrff       (.din(ibuf_addr_in[31:0]),          .dout(ibuf_addr),       .en(ibuf_wr_en),                                              .*);
   rvdffs  #(.WIDTH(4))              ibuf_byteenff     (.din(ibuf_byteen_in[3:0]),         .dout(ibuf_byteen),     .en(ibuf_wr_en),                   .clk(lsu_bus_ibuf_c1_clk), .*);
   rvdffe  #(.WIDTH(32))             ibuf_dataff       (.din(ibuf_data_in[31:0]),          .dout(ibuf_data),       .en(ibuf_wr_en),                                              .*);
   rvdff   #(.WIDTH(TIMER_LOG2))     ibuf_timerff      (.din(ibuf_timer_in),               .dout(ibuf_timer),                                         .clk(lsu_free_c2_clk),     .*);


         

            assign obuf_wr_wait = (buf_numvld_wrcmd_any[3:0] == 4'b1) & (buf_numvld_cmd_any[3:0] == 4'b1) & (obuf_wr_timer != TIMER_MAX) &
                         ~bus_coalescing_disable & ~buf_nomerge[CmdPtr0] & ~buf_sideeffect[CmdPtr0] & ~obuf_force_wr_en;
   assign obuf_wr_timer_in = obuf_wr_en ? 3'b0: (((buf_numvld_cmd_any > 4'b0) & (obuf_wr_timer < TIMER_MAX)) ? (obuf_wr_timer + 1'b1) : obuf_wr_timer);
   assign obuf_force_wr_en = lsu_busreq_dc2 & ~lsu_busreq_dc3 & ~lsu_busreq_dc4 & ~lsu_busreq_dc5 & ~ibuf_valid & (buf_numvld_cmd_any[3:0] == 4'b1) & (lsu_addr_dc2[31:2] != buf_addr[CmdPtr0][31:2]);      assign ibuf_buf_byp = ibuf_byp & (buf_numvld_pend_any[3:0] == 4'b0) & (~lsu_pkt_dc5.store | no_dword_merge_dc5);

   assign obuf_wr_en = ((ibuf_buf_byp & lsu_commit_dc5 & (lsu_pkt_dc5.tid ~^ tid) & ~(is_sideeffects_dc5 & bus_sideeffect_pend)) |
                        ((buf_state[CmdPtr0] == CMD) & found_cmdptr0 & ~buf_cmd_state_bus_en[CmdPtr0] & ~(buf_sideeffect[CmdPtr0] & bus_sideeffect_pend) &
                         (~(buf_dual[CmdPtr0] & buf_samedw[CmdPtr0] & ~buf_write[CmdPtr0]) | found_cmdptr1 | buf_nomerge[CmdPtr0] | obuf_force_wr_en))) &
                       ((bus_cmd_ready & (bus_tid == tid)) | ~obuf_valid | obuf_nosend) & ~obuf_wr_wait & ~lsu_bus_cntr_overflow & ~bus_addr_match_pending & lsu_bus_clk_en;
   assign obuf_nxtready = obuf_wr_en;      assign obuf_rst   = (((bus_cmd_sent & (bus_tid == tid)) | (obuf_valid & obuf_nosend)) & ~obuf_wr_en & lsu_bus_clk_en) | dec_tlu_force_halt;
   assign obuf_write_in = ibuf_buf_byp ? lsu_pkt_dc5.store : buf_write[CmdPtr0];
   assign obuf_sideeffect_in = ibuf_buf_byp ? is_sideeffects_dc5 : buf_sideeffect[CmdPtr0];
   assign obuf_addr_in[31:0] = ibuf_buf_byp ? lsu_addr_dc5[31:0] : buf_addr[CmdPtr0];
   assign obuf_sz_in[1:0]    = ibuf_buf_byp ? {lsu_pkt_dc5.word, lsu_pkt_dc5.half} : buf_sz[CmdPtr0];
   assign obuf_aligned_in    = ibuf_buf_byp ? is_aligned_dc5 : ((obuf_sz_in[1:0] == 2'b0) |
                                                                (obuf_sz_in[0] & ~obuf_addr_in[0]) |
                                                                (obuf_sz_in[1] & ~(|obuf_addr_in[1:0])));
   assign obuf_merge_in      = obuf_merge_en;
   assign obuf_tag0_in[pt.LSU_BUS_TAG-1:0] = ibuf_buf_byp ? (pt.LSU_BUS_TAG)'(WrPtr0_dc5) : (pt.LSU_BUS_TAG)'(CmdPtr0);
   assign obuf_tag1_in[pt.LSU_BUS_TAG-1:0] = ibuf_buf_byp ? (pt.LSU_BUS_TAG)'(WrPtr1_dc5) : (pt.LSU_BUS_TAG)'(CmdPtr1);

   assign obuf_cmd_done_in    = ~(obuf_wr_en | obuf_rst) & (obuf_cmd_done | (bus_wcmd_sent & (bus_tid == tid)));
   assign obuf_data_done_in   = ~(obuf_wr_en | obuf_rst) & (obuf_data_done | (bus_wdata_sent & (bus_tid == tid)));
   assign obuf_rdrsp_pend_in  = (~(obuf_wr_en & ~obuf_nosend_in) & obuf_rdrsp_pend & ~(bus_rsp_read & (bus_rsp_read_tid == tid) & (bus_rsp_read_tag == obuf_rdrsp_tag))) |
                                ((bus_cmd_sent & ~obuf_write & (bus_tid == tid))) & ~dec_tlu_force_halt ;
   assign obuf_rdrsp_tag_in[pt.LSU_BUS_TAG-1:0] = (bus_cmd_sent & ~obuf_write & (bus_tid == tid)) ? obuf_tag0[pt.LSU_BUS_TAG-1:0] : obuf_rdrsp_tag[pt.LSU_BUS_TAG-1:0];
      assign obuf_nosend_in      = (obuf_addr_in[31:3] == obuf_addr[31:3]) & obuf_aligned_in & ~obuf_sideeffect & ~obuf_write & ~obuf_write_in & ~dec_tlu_external_ldfwd_disable &
                                ((obuf_valid & ~obuf_nosend) | (obuf_rdrsp_pend & ~(bus_rsp_read & (bus_rsp_read_tid == tid) & (bus_rsp_read_tag == obuf_rdrsp_tag))));

   assign obuf_byteen0_in[7:0] = ibuf_buf_byp ? (lsu_addr_dc5[2] ? {ldst_byteen_lo_dc5[3:0],4'b0} : {4'b0,ldst_byteen_lo_dc5[3:0]}) :
                                                (buf_addr[CmdPtr0][2] ? {buf_byteen[CmdPtr0],4'b0} : {4'b0,buf_byteen[CmdPtr0]});
   assign obuf_byteen1_in[7:0] = ibuf_buf_byp ? (end_addr_dc5[2] ? {ldst_byteen_hi_dc5[3:0],4'b0} : {4'b0,ldst_byteen_hi_dc5[3:0]}) :
                                                (buf_addr[CmdPtr1][2] ? {buf_byteen[CmdPtr1],4'b0} : {4'b0,buf_byteen[CmdPtr1]});
   assign obuf_data0_in[63:0]  = ibuf_buf_byp ? (lsu_addr_dc5[2] ? {store_data_lo_dc5[31:0],32'b0} : {32'b0,store_data_lo_dc5[31:0]}) :
                                                (buf_addr[CmdPtr0][2] ? {buf_data[CmdPtr0],32'b0}  : {32'b0,buf_data[CmdPtr0]});
   assign obuf_data1_in[63:0]  = ibuf_buf_byp ? (lsu_addr_dc5[2] ? {store_data_hi_dc5[31:0],32'b0} :{32'b0,store_data_hi_dc5[31:0]}) :
                                                (buf_addr[CmdPtr1][2] ? {buf_data[CmdPtr1],32'b0} : {32'b0,buf_data[CmdPtr1]});
   for (genvar i=0 ;i<8; i++) begin
      assign obuf_byteen_in[i] = obuf_byteen0_in[i] | (obuf_merge_en & obuf_byteen1_in[i]);
      assign obuf_data_in[(8*i)+7:(8*i)] = (obuf_merge_en & obuf_byteen1_in[i]) ? obuf_data1_in[(8*i)+7:(8*i)] : obuf_data0_in[(8*i)+7:(8*i)];
   end

      assign obuf_merge_en = ((CmdPtr0 != CmdPtr1) & found_cmdptr0 & found_cmdptr1 & (buf_state[CmdPtr0] == CMD) & (buf_state[CmdPtr1] == CMD) &
                           ~buf_cmd_state_bus_en[CmdPtr0] & ~buf_sideeffect[CmdPtr0] &
                           ((buf_write[CmdPtr0] & buf_write[CmdPtr1] & (buf_addr[CmdPtr0][31:3] == buf_addr[CmdPtr1][31:3]) & ~bus_coalescing_disable & ~pt.BUILD_AXI_NATIVE) |
                            (~buf_write[CmdPtr0] & buf_dual[CmdPtr0] & ~buf_dualhi[CmdPtr0] & buf_samedw[CmdPtr0]))) |                            (ibuf_buf_byp & ldst_samedw_dc5 & ldst_dual_dc5);

   rvdff   #(.WIDTH(1))              obuf_wren_ff      (.din(obuf_wr_en),                  .dout(obuf_wr_enQ),                                        .clk(lsu_busm_clk), .*);
   rvdffsc #(.WIDTH(1))              obuf_valid_ff     (.din(1'b1),                        .dout(obuf_valid),      .en(obuf_wr_en), .clear(obuf_rst), .clk(lsu_free_c2_clk), .*);
   rvdffs  #(.WIDTH(1))              obuf_nosend_ff    (.din(obuf_nosend_in),              .dout(obuf_nosend),     .en(obuf_wr_en),                  .clk(lsu_free_c2_clk), .*);
   rvdff   #(.WIDTH(1))              obuf_cmd_done_ff  (.din(obuf_cmd_done_in),            .dout(obuf_cmd_done),                                      .clk(lsu_busm_clk), .*);
   rvdff   #(.WIDTH(1))              obuf_data_done_ff (.din(obuf_data_done_in),           .dout(obuf_data_done),                                     .clk(lsu_busm_clk), .*);
   rvdff   #(.WIDTH(1))              obuf_rdrsp_pend_ff(.din(obuf_rdrsp_pend_in),          .dout(obuf_rdrsp_pend),                                    .clk(lsu_busm_clk), .*);
   rvdff   #(.WIDTH(pt.LSU_BUS_TAG)) obuf_rdrsp_tagff  (.din(obuf_rdrsp_tag_in),           .dout(obuf_rdrsp_tag),                                     .clk(lsu_busm_clk), .*);
   rvdffs  #(.WIDTH(pt.LSU_BUS_TAG)) obuf_tag0ff       (.din(obuf_tag0_in),                .dout(obuf_tag0),       .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffs  #(.WIDTH(pt.LSU_BUS_TAG)) obuf_tag1ff       (.din(obuf_tag1_in),                .dout(obuf_tag1),       .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              obuf_mergeff      (.din(obuf_merge_in),               .dout(obuf_merge),      .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              obuf_writeff      (.din(obuf_write_in),               .dout(obuf_write),      .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffs  #(.WIDTH(1))              obuf_sideeffectff (.din(obuf_sideeffect_in),          .dout(obuf_sideeffect), .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffs  #(.WIDTH(2))              obuf_szff         (.din(obuf_sz_in[1:0]),             .dout(obuf_sz),         .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffe  #(.WIDTH(32))             obuf_addrff       (.din(obuf_addr_in[31:0]),          .dout(obuf_addr),       .en(obuf_wr_en),                                              .*);
   rvdffs  #(.WIDTH(8))              obuf_byteenff     (.din(obuf_byteen_in[7:0]),         .dout(obuf_byteen),     .en(obuf_wr_en),                   .clk(lsu_bus_obuf_c1_clk), .*);
   rvdffe  #(.WIDTH(64))             obuf_dataff       (.din(obuf_data_in[63:0]),          .dout(obuf_data),       .en(obuf_wr_en),                                              .*);
   rvdff   #(.WIDTH(TIMER_LOG2))     obuf_timerff      (.din(obuf_wr_timer_in),            .dout(obuf_wr_timer),                                      .clk(lsu_busm_clk), .*);

         
      always @* begin
      WrPtr0_dc1[DEPTH_LOG2-1:0] = '0;
      WrPtr1_dc1[DEPTH_LOG2-1:0] = '0;
      found_wrptr0  = '0;
      found_wrptr1  = '0;

            for (int i=0; i<DEPTH; i++) begin
         if (~found_wrptr0) begin
            WrPtr0_dc1[DEPTH_LOG2-1:0] = DEPTH_LOG2'(i);
            found_wrptr0 = (buf_state[i] == IDLE) & ~((ibuf_valid & (ibuf_tag == DEPTH_LOG2'(i)))                                               |
                                                      (lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ tid) & ((WrPtr0_dc2 == DEPTH_LOG2'(i)) | (ldst_dual_dc2 & (WrPtr1_dc2 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ tid) & ((WrPtr0_dc3 == DEPTH_LOG2'(i)) | (ldst_dual_dc3 & (WrPtr1_dc3 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ tid) & ((WrPtr0_dc4 == DEPTH_LOG2'(i)) | (ldst_dual_dc4 & (WrPtr1_dc4 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc5 & (lsu_pkt_dc5.tid ~^ tid) & ((WrPtr0_dc5 == DEPTH_LOG2'(i)) | (ldst_dual_dc5 & (WrPtr1_dc5 == DEPTH_LOG2'(i))))));
         end
      end

            for (int i=0; i<DEPTH; i++) begin
         if (~found_wrptr1) begin
            WrPtr1_dc1[DEPTH_LOG2-1:0] = DEPTH_LOG2'(i);
            found_wrptr1 = (buf_state[i] == IDLE) & ~((ibuf_valid & (ibuf_tag == DEPTH_LOG2'(i)))                                               |
                                                      (lsu_busreq_dc1 & (lsu_pkt_dc1_pre.tid ~^ tid) & (WrPtr0_dc1 == DEPTH_LOG2'(i)))                                         |
                                                      (lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ tid) & ((WrPtr0_dc2 == DEPTH_LOG2'(i)) | (ldst_dual_dc2 & (WrPtr1_dc2 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ tid) & ((WrPtr0_dc3 == DEPTH_LOG2'(i)) | (ldst_dual_dc3 & (WrPtr1_dc3 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ tid) & ((WrPtr0_dc4 == DEPTH_LOG2'(i)) | (ldst_dual_dc4 & (WrPtr1_dc4 == DEPTH_LOG2'(i))))) |
                                                      (lsu_busreq_dc5 & (lsu_pkt_dc5.tid ~^ tid) & ((WrPtr0_dc5 == DEPTH_LOG2'(i)) | (ldst_dual_dc5 & (WrPtr1_dc5 == DEPTH_LOG2'(i))))));
         end
      end
   end

      for (genvar i=0; i<DEPTH; i++) begin
            assign CmdPtr0Dec[i] = ~(|buf_age[i]) & (buf_state[i] == CMD) & ~buf_cmd_state_bus_en[i];
      assign CmdPtr1Dec[i] = ~(|(buf_age[i] & ~CmdPtr0Dec)) & ~CmdPtr0Dec[i] & (buf_state[i] == CMD) & ~buf_cmd_state_bus_en[i];
      assign RspPtrDec[i]  = ~(|buf_rsp_pickage[i]) & (buf_state[i] == DONE_WAIT);
   end

   assign found_cmdptr0 = |CmdPtr0Dec;
   assign found_cmdptr1 = |CmdPtr1Dec;
   assign CmdPtr0 = f_Enc8to3(8'(CmdPtr0Dec[DEPTH-1:0]));
   assign CmdPtr1 = f_Enc8to3(8'(CmdPtr1Dec[DEPTH-1:0]));
   assign RspPtr  = f_Enc8to3(8'(RspPtrDec[DEPTH-1:0]));

      for (genvar i=0; i<DEPTH; i++) begin: GenAgeVec
      for (genvar j=0; j<DEPTH; j++) begin
         assign buf_age_set[i][j] = ((buf_state[i] == IDLE) & buf_state_en[i]) &
                                           (((buf_state[j] == WAIT) | ((buf_state[j] == CMD) & ~buf_cmd_state_bus_en[j]))            |                                                   (ibuf_drain_vld & lsu_busreq_dc5 & (ibuf_byp | ldst_dual_dc5) & (lsu_pkt_dc5.tid ~^ tid) & (DEPTH_LOG2'(i) == WrPtr0_dc5) & (DEPTH_LOG2'(j) == ibuf_tag))  |                                                   (ibuf_byp & lsu_busreq_dc5 & ldst_dual_dc5 & (lsu_pkt_dc5.tid ~^ tid) & (DEPTH_LOG2'(i) == WrPtr1_dc5) & (DEPTH_LOG2'(j) == WrPtr0_dc5)));
         assign buf_age_in[i][j] = buf_age_set[i][j] | buf_age[i][j];
         assign buf_age[i][j]    = buf_ageQ[i][j] & ~((buf_state[j] == CMD) & buf_cmd_state_bus_en[j]);  
         assign buf_age_younger[i][j] = (i == j) ? 1'b0: (~buf_age[i][j] & (buf_state[j] != IDLE));         end
   end

      for (genvar i=0; i<DEPTH; i++) begin: GenRspAgeVec
      for (genvar j=0; j<DEPTH; j++) begin
         assign buf_rspage_set[i][j] = ((buf_state[i] == IDLE) & buf_state_en[i]) &
                                           (~((buf_state[j] == IDLE) | (buf_state[j] == DONE))                                         |                                                   (ibuf_drain_vld & lsu_busreq_dc5 & (ibuf_byp | ldst_dual_dc5) & (lsu_pkt_dc5.tid ~^ tid) & (DEPTH_LOG2'(i) == WrPtr0_dc5) & (DEPTH_LOG2'(j) == ibuf_tag))  |                                                   (ibuf_byp & lsu_busreq_dc5 & ldst_dual_dc5 & (lsu_pkt_dc5.tid ~^ tid) & (DEPTH_LOG2'(i) == WrPtr1_dc5) & (DEPTH_LOG2'(j) == WrPtr0_dc5)));
         assign buf_rspage_in[i][j] = buf_rspage_set[i][j] | buf_rspage[i][j];
         assign buf_rspage[i][j]    = buf_rspageQ[i][j] & ~((buf_state[j] == DONE) | (buf_state[j] == IDLE));           assign buf_rsp_pickage[i][j] = buf_rspageQ[i][j] & (buf_state[j] == DONE_WAIT);
     end
   end

            for (genvar i=0; i<DEPTH; i++) begin

      assign ibuf_drainvec_vld[i] = (ibuf_drain_vld & (i == ibuf_tag));
      assign buf_byteen_in[i]     = ibuf_drainvec_vld[i] ? ibuf_byteen_out[3:0] : ((ibuf_byp & ldst_dual_dc5 & (i == WrPtr1_dc5)) ? ldst_byteen_hi_dc5[3:0] : ldst_byteen_lo_dc5[3:0]);
      assign buf_addr_in[i]       = ibuf_drainvec_vld[i] ? ibuf_addr[31:0] : ((ibuf_byp & ldst_dual_dc5 & (i == WrPtr1_dc5)) ? end_addr_dc5[31:0] : lsu_addr_dc5[31:0]);
      assign buf_dual_in[i]       = ibuf_drainvec_vld[i] ? ibuf_dual : ldst_dual_dc5;
      assign buf_samedw_in[i]     = ibuf_drainvec_vld[i] ? ibuf_samedw : ldst_samedw_dc5;
      assign buf_nomerge_in[i]    = ibuf_drainvec_vld[i] ? (ibuf_nomerge | ibuf_force_drain) : no_dword_merge_dc5;
      assign buf_dualhi_in[i]     = ibuf_drainvec_vld[i] ? ibuf_dual : (ibuf_byp & ldst_dual_dc5 & (i == WrPtr1_dc5));         assign buf_dualtag_in[i]    = ibuf_drainvec_vld[i] ? ibuf_dualtag : ((ibuf_byp & ldst_dual_dc5 & (i == WrPtr1_dc5)) ? WrPtr0_dc5 : WrPtr1_dc5);
      assign buf_sideeffect_in[i] = ibuf_drainvec_vld[i] ? ibuf_sideeffect : is_sideeffects_dc5;
      assign buf_unsign_in[i]     = ibuf_drainvec_vld[i] ? ibuf_unsign : lsu_pkt_dc5.unsign;
      assign buf_sz_in[i]         = ibuf_drainvec_vld[i] ? ibuf_sz : {lsu_pkt_dc5.word, lsu_pkt_dc5.half};
      assign buf_write_in[i]      = ibuf_drainvec_vld[i] ? ibuf_write : lsu_pkt_dc5.store;


            always @* begin
         buf_nxtstate[i]          = IDLE;
         buf_state_en[i]          = '0;
         buf_cmd_state_bus_en[i]  = '0;
         buf_resp_state_bus_en[i] = '0;
         buf_state_bus_en[i]      = '0;
         buf_wr_en[i]             = '0;
         buf_data_in[i]           = '0;
         buf_data_en[i]           = '0;
         buf_error_en[i]          = '0;
         buf_rst[i]               = '0;
         buf_ldfwd_en[i]          = '0;
         buf_ldfwd_in[i]          = '0;
         buf_ldfwdtag_in[i]       = '0;

         case (buf_state[i])
            IDLE: begin
                     buf_nxtstate[i] = lsu_bus_clk_en ? CMD : WAIT;
                     buf_state_en[i] = (lsu_busreq_dc5 & lsu_commit_dc5 & (lsu_pkt_dc5.tid ~^ tid) & (((ibuf_byp | ldst_dual_dc5) & ~ibuf_merge_en & (i == WrPtr0_dc5)) | (ibuf_byp & ldst_dual_dc5 & (i == WrPtr1_dc5)))) |
                                       (ibuf_drain_vld & (i == ibuf_tag));
                     buf_wr_en[i]    = buf_state_en[i];
                     buf_data_en[i]  = buf_state_en[i];
                     buf_data_in[i]   = (ibuf_drain_vld & (i == ibuf_tag)) ? ibuf_data_out[31:0] : store_data_lo_dc5[31:0];
            end
            WAIT: begin
                     buf_nxtstate[i] = CMD;
                     buf_state_en[i] = lsu_bus_clk_en;
            end
            CMD: begin
                     buf_nxtstate[i]          = dec_tlu_force_halt ? IDLE : (obuf_nosend & bus_rsp_read & (bus_rsp_read_tid == tid) & (bus_rsp_read_tag == obuf_rdrsp_tag)) ? DONE_WAIT : RESP;
                     buf_cmd_state_bus_en[i]  = ((obuf_tag0 == i) | (obuf_merge & (obuf_tag1 == i))) & obuf_valid & obuf_wr_enQ;                       buf_state_bus_en[i]      = buf_cmd_state_bus_en[i];
                     buf_state_en[i]          = (buf_state_bus_en[i] & lsu_bus_clk_en) | dec_tlu_force_halt;
                     buf_ldfwd_in[i]          = 1'b1;
                     buf_ldfwd_en[i]          = buf_state_en[i] & ~buf_write[i] & obuf_nosend & ~dec_tlu_force_halt;
                     buf_ldfwdtag_in[i]       = DEPTH_LOG2'(obuf_rdrsp_tag[pt.LSU_BUS_TAG-2:0]);
                     buf_data_en[i]           = buf_state_bus_en[i] & lsu_bus_clk_en & obuf_nosend & bus_rsp_read;
                     buf_error_en[i]          = buf_state_bus_en[i] & lsu_bus_clk_en & obuf_nosend & bus_rsp_read_error;
                     buf_data_in[i]           = buf_error_en[i] ? bus_rsp_rdata[31:0] : (buf_addr[i][2] ? bus_rsp_rdata[63:32] : bus_rsp_rdata[31:0]);
           end
            RESP: begin
                     buf_nxtstate[i]           = (dec_tlu_force_halt | (buf_write[i] & ~(pt.BUILD_AXI_NATIVE & bus_rsp_write_error))) ? IDLE :                                                          (buf_dual[i] & ~buf_samedw[i] & ~buf_write[i] & (buf_state[buf_dualtag[i]] != DONE_PARTIAL)) ? DONE_PARTIAL :                                                            (buf_ldfwd[i] | any_done_wait_state | (any_done_state & (lsu_nonblock_load_data_tid^tid)) |
                                                            (buf_dual[i] & ~buf_samedw[i] & ~buf_write[i] & buf_ldfwd[buf_dualtag[i]] &
                                                             (buf_state[buf_dualtag[i]] == DONE_PARTIAL) & (any_done_wait_state | (any_done_state & (lsu_nonblock_load_data_tid^tid))))) ? DONE_WAIT : DONE;
                     buf_resp_state_bus_en[i]  = (bus_rsp_write & (bus_rsp_write_tid == tid) & (bus_rsp_write_tag == (pt.LSU_BUS_TAG)'(i))) |
                                                 (bus_rsp_read  & (bus_rsp_read_tid == tid)  & ((bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(i)) |
                                                                                                (buf_ldfwd[i] & (bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(buf_ldfwdtag[i]))) |
                                                                                                (buf_dual[i] & buf_dualhi[i] & ~buf_write[i] & buf_samedw[i] & (bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(buf_dualtag[i])))));
                     buf_state_bus_en[i]       = buf_resp_state_bus_en[i];
                     buf_state_en[i]           = (buf_state_bus_en[i] & lsu_bus_clk_en) | dec_tlu_force_halt;
                     buf_data_en[i]            = buf_state_bus_en[i] & bus_rsp_read & lsu_bus_clk_en;
                                           buf_error_en[i]           = buf_state_bus_en[i] & lsu_bus_clk_en & ((bus_rsp_read_error  & (bus_rsp_read_tag  == (pt.LSU_BUS_TAG)'(i))) |
                                                                                         (bus_rsp_read_error  & buf_ldfwd[i] & (bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(buf_ldfwdtag[i]))) |
                                                                                         (bus_rsp_write_error & pt.BUILD_AXI_NATIVE & (bus_rsp_write_tag == (pt.LSU_BUS_TAG)'(i))));
                     buf_data_in[i][31:0]      = (buf_state_en[i] & ~buf_error_en[i]) ? (buf_addr[i][2] ? bus_rsp_rdata[63:32] : bus_rsp_rdata[31:0]) : bus_rsp_rdata[31:0];
            end
            DONE_PARTIAL: begin                        buf_nxtstate[i]           = dec_tlu_force_halt ? IDLE : (buf_ldfwd[i] | buf_ldfwd[buf_dualtag[i]] | any_done_wait_state | (any_done_state & (lsu_nonblock_load_data_tid^tid))) ? DONE_WAIT : DONE;
                     buf_state_bus_en[i]       = bus_rsp_read & (bus_rsp_read_tid == tid) & ((bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(buf_dualtag[i])) |
                                                                                             (buf_ldfwd[buf_dualtag[i]] & (bus_rsp_read_tag == (pt.LSU_BUS_TAG)'(buf_ldfwdtag[buf_dualtag[i]]))));
                     buf_state_en[i]           = (buf_state_bus_en[i] & lsu_bus_clk_en) | dec_tlu_force_halt;
            end
            DONE_WAIT: begin                        buf_nxtstate[i]           = dec_tlu_force_halt ? IDLE : DONE;
                      buf_state_en[i]           = (((RspPtr == DEPTH_LOG2'(i)) | (buf_dual[i] & (buf_dualtag[i] == RspPtr))) & ((lsu_nonblock_load_data_tid == tid) | ~any_done_state)) | dec_tlu_force_halt;
            end
            DONE: begin
                     buf_nxtstate[i]           = IDLE;
                     buf_rst[i]                = buf_write[i] | ((lsu_nonblock_load_data_valid | lsu_nonblock_load_data_error) & (lsu_nonblock_load_data_tid == tid));
                     buf_state_en[i]           = buf_rst[i] | dec_tlu_force_halt;
                     buf_ldfwd_in[i]           = 1'b0;
                     buf_ldfwd_en[i]           = buf_state_en[i];
            end
             default : begin
                     buf_nxtstate[i]          = IDLE;

                     buf_state_en[i]          = '0;
                     buf_cmd_state_bus_en[i]  = '0;
                     buf_resp_state_bus_en[i] = '0;
                     buf_state_bus_en[i]      = '0;
                     buf_wr_en[i]             = '0;
                     buf_data_in[i]           = '0;
                     buf_data_en[i]           = '0;
                     buf_error_en[i]          = '0;
                     buf_rst[i]               = '0;
            end
         endcase
      end

      rvdffs  #(.WIDTH($bits(state_t))) buf_state_ff     (.din(buf_nxtstate[i]),             .dout({buf_state[i]}),    .en(buf_state_en[i]),                                        .clk(lsu_bus_buf_c1_clk), .*);
      rvdff   #(.WIDTH(DEPTH))          buf_ageff        (.din(buf_age_in[i]),               .dout(buf_ageQ[i]),                                                                    .clk(lsu_bus_buf_c1_clk), .*);
      rvdff   #(.WIDTH(DEPTH))          buf_rspageff     (.din(buf_rspage_in[i]),            .dout(buf_rspageQ[i]),                                                                 .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(DEPTH_LOG2))     buf_dualtagff    (.din(buf_dualtag_in[i]),           .dout(buf_dualtag[i]),    .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_dualff       (.din(buf_dual_in[i]),              .dout(buf_dual[i]),       .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_samedwff     (.din(buf_samedw_in[i]),            .dout(buf_samedw[i]),     .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_nomergeff    (.din(buf_nomerge_in[i]),           .dout(buf_nomerge[i]),    .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_dualhiff     (.din(buf_dualhi_in[i]),            .dout(buf_dualhi[i]),     .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_ldfwdff      (.din(buf_ldfwd_in[i]),             .dout(buf_ldfwd[i]),      .en(buf_ldfwd_en[i]),                                        .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(DEPTH_LOG2))     buf_ldfwdtagff   (.din(buf_ldfwdtag_in[i]),          .dout(buf_ldfwdtag[i]),   .en(buf_ldfwd_en[i]),                                        .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_sideeffectff (.din(buf_sideeffect_in[i]),        .dout(buf_sideeffect[i]), .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_unsignff     (.din(buf_unsign_in[i]),            .dout(buf_unsign[i]),     .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(1))              buf_writeff      (.din(buf_write_in[i]),             .dout(buf_write[i]),      .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffs  #(.WIDTH(2))              buf_szff         (.din(buf_sz_in[i]),                .dout(buf_sz[i]),         .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffe  #(.WIDTH(32))             buf_addrff       (.din(buf_addr_in[i][31:0]),        .dout(buf_addr[i]),       .en(buf_wr_en[i]),                                                                     .*);
      rvdffs  #(.WIDTH(4))              buf_byteenff     (.din(buf_byteen_in[i][3:0]),       .dout(buf_byteen[i]),     .en(buf_wr_en[i]),                                           .clk(lsu_bus_buf_c1_clk), .*);
      rvdffe  #(.WIDTH(32))             buf_dataff       (.din(buf_data_in[i][31:0]),        .dout(buf_data[i]),       .en(buf_data_en[i]),                                                                   .*);
      rvdffsc #(.WIDTH(1))              buf_errorff      (.din(1'b1),                        .dout(buf_error[i]),      .en(buf_error_en[i]),                    .clear(buf_rst[i]), .clk(lsu_bus_buf_c1_clk), .*);

   end

      always @* begin
      buf_numvld_any[3:0] =  ({3'b0,(lsu_pkt_dc1_pre.valid & (lsu_pkt_dc1_pre.tid ~^ tid))} << (lsu_pkt_dc1_pre.valid & ldst_dual_dc1)) +
                             ({3'b0,(lsu_busreq_dc2 & (lsu_pkt_dc2.tid ~^ tid))} << (lsu_busreq_dc2 & ldst_dual_dc2)) +
                             ({3'b0,(lsu_busreq_dc3 & (lsu_pkt_dc3.tid ~^ tid))} << (lsu_busreq_dc3 & ldst_dual_dc3)) +
                             ({3'b0,(lsu_busreq_dc4 & (lsu_pkt_dc4.tid ~^ tid))} << (lsu_busreq_dc4 & ldst_dual_dc4)) +
                             ({3'b0,(lsu_busreq_dc5 & (lsu_pkt_dc5.tid ~^ tid))} << (lsu_busreq_dc5 & ldst_dual_dc5)) +
                             {3'b0,ibuf_valid};
      buf_numvld_wrcmd_any[3:0] = 4'b0;
      buf_numvld_cmd_any[3:0] = 4'b0;
      buf_numvld_pend_any[3:0] = 4'b0;
      any_done_wait_state = 1'b0;
      any_done_state = 1'b0;
      for (int i=0; i<DEPTH; i++) begin
         buf_numvld_any[3:0] += {3'b0, (buf_state[i] != IDLE)};
         buf_numvld_wrcmd_any[3:0] += {3'b0, (buf_write[i] & (buf_state[i] == CMD) & ~buf_cmd_state_bus_en[i])};
         buf_numvld_cmd_any[3:0]   += {3'b0, ((buf_state[i] == CMD) & ~buf_cmd_state_bus_en[i])};
         buf_numvld_pend_any[3:0]   += {3'b0, ((buf_state[i] == WAIT) | ((buf_state[i] == CMD) & ~buf_cmd_state_bus_en[i]))};
         any_done_wait_state |= (buf_state[i] == DONE_WAIT);
         any_done_state      |= (buf_state[i] == DONE);
      end
   end

   assign lsu_bus_buffer_pend_any = (buf_numvld_pend_any != 0);
   assign lsu_bus_buffer_full_any = (buf_numvld_any[3:0] >= (DEPTH-1));
   assign lsu_bus_buffer_empty_any = ~(|buf_state[DEPTH-1:0]) & ~ibuf_valid & ~obuf_valid;

      always @* begin
      lsu_nonblock_load_data_ready   = '0;
      lsu_nonblock_load_rtn_valid    = '0;
      lsu_nonblock_load_data_error   = '0;
      lsu_nonblock_load_data_tag[DEPTH_LOG2-1:0] = '0;
      lsu_nonblock_load_data_lo[31:0] = '0;
      lsu_nonblock_load_data_hi[31:0] = '0;
      for (int i=0; i<DEPTH; i++) begin
          lsu_nonblock_load_data_ready         |= (buf_state[i] == DONE) & ~(pt.BUILD_AXI_NATIVE & buf_write[i]);
          lsu_nonblock_load_data_error         |= (buf_state[i] == DONE) & buf_error[i] & ~buf_write[i];
          lsu_nonblock_load_data_tag[DEPTH_LOG2-1:0]   |= DEPTH_LOG2'(i) & {DEPTH_LOG2{(~buf_write[i] & (buf_state[i] == DONE) & (~buf_dual[i] | ~buf_dualhi[i]))}};
          lsu_nonblock_load_data_lo[31:0]      |= buf_data[i][31:0] & {32{(~buf_write[i] & (buf_state[i] == DONE) & (~buf_dual[i] | ~buf_dualhi[i]))}};
          lsu_nonblock_load_data_hi[31:0]      |= buf_data[i][31:0] & {32{(~buf_write[i] & (buf_state[i] == DONE) & (buf_dual[i] & buf_dualhi[i]))}};
      end
   end

   assign lsu_nonblock_addr_offset[1:0] = buf_addr[lsu_nonblock_load_data_tag][1:0];
   assign lsu_nonblock_sz[1:0]          = buf_sz[lsu_nonblock_load_data_tag][1:0];
   assign lsu_nonblock_unsign           = buf_unsign[lsu_nonblock_load_data_tag];
   assign lsu_nonblock_dual             = buf_dual[lsu_nonblock_load_data_tag];
   assign lsu_nonblock_data_unalgn[31:0] = 32'({lsu_nonblock_load_data_hi[31:0], lsu_nonblock_load_data_lo[31:0]} >> 8*lsu_nonblock_addr_offset[1:0]);

   assign lsu_nonblock_load_data_valid = lsu_nonblock_load_data_ready & ~lsu_nonblock_load_data_error;
   assign lsu_nonblock_load_data = ({32{ lsu_nonblock_unsign & (lsu_nonblock_sz[1:0] == 2'b00)}} & {24'b0,lsu_nonblock_data_unalgn[7:0]}) |
                                   ({32{ lsu_nonblock_unsign & (lsu_nonblock_sz[1:0] == 2'b01)}} & {16'b0,lsu_nonblock_data_unalgn[15:0]}) |
                                   ({32{~lsu_nonblock_unsign & (lsu_nonblock_sz[1:0] == 2'b00)}} & {{24{lsu_nonblock_data_unalgn[7]}}, lsu_nonblock_data_unalgn[7:0]}) |
                                   ({32{~lsu_nonblock_unsign & (lsu_nonblock_sz[1:0] == 2'b01)}} & {{16{lsu_nonblock_data_unalgn[15]}},lsu_nonblock_data_unalgn[15:0]}) |
                                   ({32{(lsu_nonblock_sz[1:0] == 2'b10)}} & lsu_nonblock_data_unalgn[31:0]);

      always @* begin
      bus_sideeffect_pend = obuf_valid & obuf_sideeffect & dec_tlu_sideeffect_posted_disable;
      for (int i=0; i<DEPTH; i++) begin
         bus_sideeffect_pend |= ((buf_state[i] == RESP) & buf_sideeffect[i] & dec_tlu_sideeffect_posted_disable);
      end
   end

      always @* begin
      bus_addr_match_pending = '0;
      for (int i=0; i<DEPTH; i++) begin
         bus_addr_match_pending |= (pt.BUILD_AXI_NATIVE & obuf_valid & (obuf_addr[31:3] == buf_addr[i][31:3]) & (buf_state[i] == RESP) & ~((obuf_tag0 == (pt.LSU_BUS_TAG)'(i)) | (obuf_merge & (obuf_tag1 == (pt.LSU_BUS_TAG)'(i)))));
      end
   end

   always @* begin
      lsu_imprecise_error_store_any = '0;
      lsu_imprecise_error_store_tag = '0;
      for (int i=0; i<DEPTH; i++) begin
         lsu_imprecise_error_store_any |= lsu_bus_clk_en_q & (buf_state[i] == DONE) & buf_error[i] & buf_write[i];
         lsu_imprecise_error_store_tag |= DEPTH_LOG2'(i) & {DEPTH_LOG2{((buf_state[i] == DONE) & buf_error[i] & buf_write[i])}};
      end
   end
   assign lsu_imprecise_error_load_any       = lsu_nonblock_load_data_error & (lsu_nonblock_load_data_tid == tid) & ~lsu_imprecise_error_store_any;      assign lsu_imprecise_error_addr_any[31:0] = lsu_imprecise_error_store_any ? buf_addr[lsu_imprecise_error_store_tag] : buf_addr[lsu_nonblock_load_data_tag];
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr0_dc2ff (.din(WrPtr0_dc1), .dout(WrPtr0_dc2), .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr0_dc3ff (.din(WrPtr0_dc2), .dout(WrPtr0_dc3), .clk(lsu_c2_dc3_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr0_dc4ff (.din(WrPtr0_dc3), .dout(WrPtr0_dc4), .clk(lsu_c2_dc4_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr0_dc5ff (.din(WrPtr0_dc4), .dout(WrPtr0_dc5), .clk(lsu_c2_dc5_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr1_dc2ff (.din(WrPtr1_dc1), .dout(WrPtr1_dc2), .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr1_dc3ff (.din(WrPtr1_dc2), .dout(WrPtr1_dc3), .clk(lsu_c2_dc3_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr1_dc4ff (.din(WrPtr1_dc3), .dout(WrPtr1_dc4), .clk(lsu_c2_dc4_clk), .*);
   rvdff #(.WIDTH(DEPTH_LOG2)) lsu_WrPtr1_dc5ff (.din(WrPtr1_dc4), .dout(WrPtr1_dc5), .clk(lsu_c2_dc5_clk), .*);


`ifdef ASSERT_ON

   for (genvar i=0; i<4; i++) begin: GenByte
   end



`endif

endmodule 