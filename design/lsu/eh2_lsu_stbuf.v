module eh2_lsu_stbuf
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
(
   input wire clk,                                   input wire rst_l,                                 input wire scan_mode,

   input wire lsu_c1_dc3_clk,                     
   input wire lsu_stbuf_c1_clk,                      input wire lsu_free_c2_clk,                    
      input wire store_stbuf_reqvld_dc5,                input wire core_ldst_dual_dc1,                    input wire addr_in_dccm_dc2,                      input wire addr_in_dccm_dc3,                      input wire addr_in_dccm_dc4,                      input wire addr_in_dccm_dc5,                      input wire addr_in_pic_dc2,                       input wire [pt.DCCM_DATA_WIDTH-1:0] dccm_datafn_hi_dc5,                    input wire [pt.DCCM_DATA_WIDTH-1:0] dccm_datafn_lo_dc5,                    input wire [63:0]                   store_data_ext_dc3, store_data_ext_dc4, store_data_ext_dc5,   
   input wire lsu_commit_dc5,                     
      output logic                          stbuf_reqvld_any,                     output logic                          stbuf_reqvld_flushed_any,             output logic [pt.LSU_SB_BITS-1:0]     stbuf_addr_any,                       output logic [pt.DCCM_DATA_WIDTH-1:0] stbuf_data_any,                    
   input wire lsu_stbuf_commit_any,                 output logic [pt.NUM_THREADS-1:0]     lsu_stbuf_empty_any,                  output logic [pt.NUM_THREADS-1:0]     lsu_stbuf_full_any,                
   input wire [pt.LSU_SB_BITS-1:0]      lsu_addr_dc1,                         input wire [31:0]                    lsu_addr_dc2,
   input wire [31:0]                    lsu_addr_dc3,
   input wire [31:0]                    lsu_addr_dc4,
   input wire [31:0]                    lsu_addr_dc5,

   input wire [pt.LSU_SB_BITS-1:0]      end_addr_dc1,                         input wire [31:0]                    end_addr_dc2,
   input wire [31:0]                    end_addr_dc3,
   input wire [31:0]                    end_addr_dc4,
   input wire [31:0]                    end_addr_dc5,

      input wire lsu_cmpen_dc2,                          input eh2_lsu_pkt_t                  lsu_pkt_dc1_pre,
   input eh2_lsu_pkt_t                  lsu_pkt_dc2,
   input eh2_lsu_pkt_t                  lsu_pkt_dc3,
   input eh2_lsu_pkt_t                  lsu_pkt_dc4,
   input eh2_lsu_pkt_t                  lsu_pkt_dc5,

   output logic                          picm_fwd_en_dc2,
   output logic [31:0]                   picm_fwd_data_dc2,

   output logic [pt.DCCM_DATA_WIDTH-1:0] stbuf_fwddata_hi_dc3,        output logic [pt.DCCM_DATA_WIDTH-1:0] stbuf_fwddata_lo_dc3,
   output logic [pt.DCCM_BYTE_WIDTH-1:0] stbuf_fwdbyteen_hi_dc3,
   output logic [pt.DCCM_BYTE_WIDTH-1:0] stbuf_fwdbyteen_lo_dc3

);

   localparam DEPTH      = pt.LSU_STBUF_DEPTH;
   localparam DATA_WIDTH = pt.DCCM_DATA_WIDTH;
   localparam BYTE_WIDTH = pt.DCCM_BYTE_WIDTH;
   localparam DEPTH_LOG2 = $clog2(DEPTH);

      reg [DEPTH-1:0]                     stbuf_vld;
   reg [DEPTH-1:0]                     stbuf_dma_kill;
   reg [DEPTH-1:0][pt.LSU_SB_BITS-1:0] stbuf_addr;
   wire [DEPTH-1:0][BYTE_WIDTH-1:0]     stbuf_byteen;
   wire [DEPTH-1:0][DATA_WIDTH-1:0]     stbuf_data;
   wire [DEPTH-1:0]                     stbuf_tid;

   wire [DEPTH-1:0]                     sel_lo;
   wire [DEPTH-1:0]                     stbuf_wr_en;
   reg [DEPTH-1:0]                     stbuf_dma_kill_en;
   reg [DEPTH-1:0]                     stbuf_reset;
   reg [DEPTH-1:0][pt.LSU_SB_BITS-1:0] stbuf_addrin;
   wire [DEPTH-1:0][DATA_WIDTH-1:0]     stbuf_datain;
   wire [DEPTH-1:0][BYTE_WIDTH-1:0]     stbuf_byteenin;

   wire [7:0]                        store_byteen_ext_dc5;
   wire [BYTE_WIDTH-1:0]             store_byteen_hi_dc5;
   wire [BYTE_WIDTH-1:0]             store_byteen_lo_dc5;

wire WrPtrEn;
wire RdPtrEn;
wire [DEPTH_LOG2-1:0] WrPtr;
wire [DEPTH_LOG2-1:0] RdPtr;
reg [DEPTH_LOG2-1:0] NxtWrPtr;
wire [DEPTH_LOG2-1:0] NxtRdPtr;
wire [DEPTH_LOG2-1:0] WrPtrPlus1;
wire [DEPTH_LOG2-1:0] WrPtrPlus2;
wire [DEPTH_LOG2-1:0] RdPtrPlus1;
wire ldst_dual_dc1;
wire ldst_dual_dc2;
wire ldst_dual_dc3;
wire ldst_dual_dc4;
wire ldst_dual_dc5;
   wire                              isst_nodma_dc1;
wire dccm_st_nodma_dc2;
wire dccm_st_nodma_dc3;
wire dccm_st_nodma_dc4;
wire dccm_st_nodma_dc5;

   reg [3:0]                        stbuf_total_specvld_any;
wire [pt.NUM_THREADS-1:0] [3:0] stbuf_numvld_any;
wire [pt.NUM_THREADS-1:0] [3:0] stbuf_specvld_any;
wire [pt.NUM_THREADS-1:0] [3:0] stbuf_specvld_anyQ;
wire [pt.NUM_THREADS-1:0] [3:0] stbuf_tidvld_any;
wire [pt.NUM_THREADS-1:0] [1:0] stbuf_specvld_dc1;
wire [pt.NUM_THREADS-1:0] [1:0] stbuf_specvld_dc2;
wire [pt.NUM_THREADS-1:0] [1:0] stbuf_specvld_dc3;
wire [pt.NUM_THREADS-1:0] [1:0] stbuf_specvld_dc4;
wire [pt.NUM_THREADS-1:0] [1:0] stbuf_specvld_dc5;

wire cmpen_hi_dc2;
wire cmpen_lo_dc2;

wire [pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] cmpaddr_hi_dc2;
wire [pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] cmpaddr_lo_dc2;

reg [DEPTH-1:0] stbuf_match_hi;
reg [DEPTH-1:0] stbuf_match_lo;
wire [DEPTH-1:0] [BYTE_WIDTH-1:0] stbuf_fwdbyteenvec_hi;
wire [DEPTH-1:0] [BYTE_WIDTH-1:0] stbuf_fwdbyteenvec_lo;
wire [DEPTH-1:0] [DATA_WIDTH-1:0] stbuf_fwddatavec_hi;
wire [DEPTH-1:0] [DATA_WIDTH-1:0] stbuf_fwddatavec_lo;
reg [DATA_WIDTH-1:0] stbuf_fwddata_hi_dc2;
reg [DATA_WIDTH-1:0] stbuf_fwddata_lo_dc2;
wire [DATA_WIDTH-1:0] stbuf_fwddata_hi_fn_dc2;
wire [DATA_WIDTH-1:0] stbuf_fwddata_lo_fn_dc2;
reg [BYTE_WIDTH-1:0] stbuf_fwdbyteen_hi_dc2;
reg [BYTE_WIDTH-1:0] stbuf_fwdbyteen_lo_dc2;
wire [BYTE_WIDTH-1:0] stbuf_fwdbyteen_hi_fn_dc2;
wire [BYTE_WIDTH-1:0] stbuf_fwdbyteen_lo_fn_dc2;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_lo_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_hi_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_lo_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_hi_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_lo_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_hi_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_lo_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_hi_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_lo_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_hi_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_lo_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_hi_hi;

wire [BYTE_WIDTH-1:0] ld_byte_hit_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_lo;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_lo;
wire [BYTE_WIDTH-1:0] ld_byte_hit_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc3hit_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc4hit_hi;
wire [BYTE_WIDTH-1:0] ld_byte_dc5hit_hi;

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

wire [BYTE_WIDTH-1:0] ldst_byteen_hi_dc3;
wire [BYTE_WIDTH-1:0] ldst_byteen_hi_dc4;
wire [BYTE_WIDTH-1:0] ldst_byteen_hi_dc5;
wire [BYTE_WIDTH-1:0] ldst_byteen_lo_dc3;
wire [BYTE_WIDTH-1:0] ldst_byteen_lo_dc4;
wire [BYTE_WIDTH-1:0] ldst_byteen_lo_dc5;
wire [7:0] ldst_byteen_dc3;
wire [7:0] ldst_byteen_dc4;
wire [7:0] ldst_byteen_dc5;
wire [7:0] ldst_byteen_ext_dc3;
wire [7:0] ldst_byteen_ext_dc4;
wire [7:0] ldst_byteen_ext_dc5;

wire [31:0] store_data_hi_dc3;
wire [31:0] store_data_hi_dc4;
wire [31:0] store_data_hi_dc5;
wire [31:0] store_ecc_datafn_hi_dc5;
wire [31:0] store_data_lo_dc3;
wire [31:0] store_data_lo_dc4;
wire [31:0] store_data_lo_dc5;
wire [31:0] store_ecc_datafn_lo_dc5;
wire [31:0] ld_fwddata_dc3pipe_lo;
wire [31:0] ld_fwddata_dc4pipe_lo;
wire [31:0] ld_fwddata_dc5pipe_lo;
wire [31:0] ld_fwddata_dc3pipe_hi;
wire [31:0] ld_fwddata_dc4pipe_hi;
wire [31:0] ld_fwddata_dc5pipe_hi;
wire [DEPTH-1:0] store_matchvec_lo_dc5;
wire [DEPTH-1:0] store_matchvec_hi_dc5;
wire store_coalesce_lo_dc5;
wire store_coalesce_hi_dc5;

wire tid_match_c2c3;
wire tid_match_c2c4;
wire tid_match_c2c5;

         
wire [7:0] store_byteen_ext_dc3;
wire [7:0] ldst_byteen_tmp_dc3;
   wire [pt.DCCM_BYTE_WIDTH-1:0] stbuf_byteen_any;

    assign ldst_byteen_tmp_dc3[7:0] = ({8{lsu_pkt_dc3.by}}   & 8'b0000_0001) |
                                      ({8{lsu_pkt_dc3.half}} & 8'b0000_0011) |
                                      ({8{lsu_pkt_dc3.word}} & 8'b0000_1111) |
                                      ({8{lsu_pkt_dc3.dword}} & 8'b1111_1111);
   assign store_byteen_ext_dc3[7:0] = ldst_byteen_tmp_dc3[7:0] << lsu_addr_dc3[1:0];

   assign stbuf_byteen_any[BYTE_WIDTH-1:0] = stbuf_byteen[RdPtr][BYTE_WIDTH-1:0];       
      
      assign tid_match_c2c3      = (lsu_pkt_dc2.tid == lsu_pkt_dc3.tid);
   assign tid_match_c2c4      = (lsu_pkt_dc2.tid == lsu_pkt_dc4.tid);
   assign tid_match_c2c5      = (lsu_pkt_dc2.tid == lsu_pkt_dc5.tid);

      assign store_byteen_ext_dc5[7:0]           = ldst_byteen_dc5[7:0] << lsu_addr_dc5[1:0];
   assign store_byteen_hi_dc5[BYTE_WIDTH-1:0] = store_byteen_ext_dc5[7:4];
   assign store_byteen_lo_dc5[BYTE_WIDTH-1:0] = store_byteen_ext_dc5[3:0];

   assign RdPtrPlus1[DEPTH_LOG2-1:0]     = (RdPtr[DEPTH_LOG2-1:0] == (DEPTH -1)) ? {DEPTH_LOG2{1'b0}}           : RdPtr[DEPTH_LOG2-1:0] + 1'b1;
   assign WrPtrPlus1[DEPTH_LOG2-1:0]     = (WrPtr[DEPTH_LOG2-1:0] == (DEPTH -1)) ? {DEPTH_LOG2{1'b0}}           : WrPtr[DEPTH_LOG2-1:0] + 1'b1;
   assign WrPtrPlus2[DEPTH_LOG2-1:0]     = (WrPtr[DEPTH_LOG2-1:0] == (DEPTH -1)) ? {{DEPTH_LOG2-1{1'b0}}, 1'b1} : (WrPtr[DEPTH_LOG2-1:0] == DEPTH-2) ? {DEPTH_LOG2{1'b0}} : WrPtr[DEPTH_LOG2-1:0] + 2'b10;

      assign ldst_dual_dc1          = core_ldst_dual_dc1;
   assign ldst_dual_dc2          = (lsu_addr_dc2[2] != end_addr_dc2[2]);
   assign ldst_dual_dc3          = (lsu_addr_dc3[2] != end_addr_dc3[2]);
   assign ldst_dual_dc4          = (lsu_addr_dc4[2] != end_addr_dc4[2]);
   assign ldst_dual_dc5          = (lsu_addr_dc5[2] != end_addr_dc5[2]);

      for (genvar i=0; i<pt.DCCM_BYTE_WIDTH; i++) begin
      assign store_ecc_datafn_hi_dc5[(8*i)+7:(8*i)] = dccm_datafn_hi_dc5[(8*i)+7:(8*i)];
      assign store_ecc_datafn_lo_dc5[(8*i)+7:(8*i)] = dccm_datafn_lo_dc5[(8*i)+7:(8*i)];
   end

     for (genvar i=0; i<DEPTH; i++) begin: FindMatchEntry
       assign store_matchvec_lo_dc5[i] = (stbuf_addr[i][pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] == lsu_addr_dc5[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)]) & stbuf_vld[i] & ~stbuf_dma_kill[i] & lsu_commit_dc5 & ~stbuf_reset[i];
       assign store_matchvec_hi_dc5[i] = (stbuf_addr[i][pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] == end_addr_dc5[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)]) & stbuf_vld[i] & ~stbuf_dma_kill[i] & lsu_commit_dc5 & ldst_dual_dc5 & ~stbuf_reset[i];
   end: FindMatchEntry

   assign store_coalesce_lo_dc5 = |store_matchvec_lo_dc5[DEPTH-1:0];
   assign store_coalesce_hi_dc5 = |store_matchvec_hi_dc5[DEPTH-1:0];

                     for (genvar i=0; i<DEPTH; i++) begin: GenStBuf
      assign stbuf_wr_en[i] = store_stbuf_reqvld_dc5 & (
                                ( (i == WrPtr[DEPTH_LOG2-1:0])      &  ~store_coalesce_lo_dc5)   |                                                                             ( (i == WrPtr[DEPTH_LOG2-1:0])      &  ldst_dual_dc5 & ~store_coalesce_hi_dc5) |                                                               ( (i == WrPtrPlus1[DEPTH_LOG2-1:0]) &  ldst_dual_dc5 & ~(store_coalesce_lo_dc5 | store_coalesce_hi_dc5)) |                                     store_matchvec_lo_dc5[i] | store_matchvec_hi_dc5[i]);                                                                assign stbuf_reset[i] = (lsu_stbuf_commit_any | stbuf_reqvld_flushed_any) & (i == RdPtr[DEPTH_LOG2-1:0]);

            assign sel_lo[i]                         = ((~ldst_dual_dc5 | store_stbuf_reqvld_dc5) & (i == WrPtr[DEPTH_LOG2-1:0]) & ~store_coalesce_lo_dc5) |                                                    store_matchvec_lo_dc5[i];                                                                                                                 assign stbuf_addrin[i][pt.LSU_SB_BITS-1:0]  = sel_lo[i] ? lsu_addr_dc5[pt.LSU_SB_BITS-1:0]       : end_addr_dc5[pt.LSU_SB_BITS-1:0];
      assign stbuf_byteenin[i][BYTE_WIDTH-1:0] = sel_lo[i] ? (stbuf_byteen[i][BYTE_WIDTH-1:0] | store_byteen_lo_dc5[BYTE_WIDTH-1:0])          : (stbuf_byteen[i][BYTE_WIDTH-1:0] | store_byteen_hi_dc5[BYTE_WIDTH-1:0]);
      assign stbuf_datain[i][7:0]              = sel_lo[i] ? ((~stbuf_byteen[i][0] | store_byteen_lo_dc5[0]) ? store_ecc_datafn_lo_dc5[7:0]   : stbuf_data[i][7:0])    :
                                                             ((~stbuf_byteen[i][0] | store_byteen_hi_dc5[0]) ? store_ecc_datafn_hi_dc5[7:0]   : stbuf_data[i][7:0]);
      assign stbuf_datain[i][15:8]             = sel_lo[i] ? ((~stbuf_byteen[i][1] | store_byteen_lo_dc5[1]) ? store_ecc_datafn_lo_dc5[15:8]  : stbuf_data[i][15:8])    :
                                                             ((~stbuf_byteen[i][1] | store_byteen_hi_dc5[1]) ? store_ecc_datafn_hi_dc5[15:8]  : stbuf_data[i][15:8]);
      assign stbuf_datain[i][23:16]            = sel_lo[i] ? ((~stbuf_byteen[i][2] | store_byteen_lo_dc5[2]) ? store_ecc_datafn_lo_dc5[23:16] : stbuf_data[i][23:16])    :
                                                             ((~stbuf_byteen[i][2] | store_byteen_hi_dc5[2]) ? store_ecc_datafn_hi_dc5[23:16] : stbuf_data[i][23:16]);
      assign stbuf_datain[i][31:24]            = sel_lo[i] ? ((~stbuf_byteen[i][3] | store_byteen_lo_dc5[3]) ? store_ecc_datafn_lo_dc5[31:24] : stbuf_data[i][31:24])    :
                                                             ((~stbuf_byteen[i][3] | store_byteen_hi_dc5[3]) ? store_ecc_datafn_hi_dc5[31:24] : stbuf_data[i][31:24]);


      rvdffsc #(.WIDTH(1))              stbuf_vldff    (.din(1'b1),                                .dout(stbuf_vld[i]),                      .en(stbuf_wr_en[i]),       .clear(stbuf_reset[i]), .clk(lsu_free_c2_clk),  .*);
      rvdffsc #(.WIDTH(1))              stbuf_killff   (.din(1'b1),                                .dout(stbuf_dma_kill[i]),                 .en(stbuf_dma_kill_en[i]), .clear(stbuf_reset[i]), .clk(lsu_free_c2_clk),  .*);
      rvdffe  #(.WIDTH(pt.LSU_SB_BITS)) stbuf_addrff   (.din(stbuf_addrin[i][pt.LSU_SB_BITS-1:0]), .dout(stbuf_addr[i][pt.LSU_SB_BITS-1:0]), .en(stbuf_wr_en[i]),                                                       .*);
      rvdffsc #(.WIDTH(BYTE_WIDTH))     stbuf_byteenff (.din(stbuf_byteenin[i][BYTE_WIDTH-1:0]),   .dout(stbuf_byteen[i][BYTE_WIDTH-1:0]),   .en(stbuf_wr_en[i]),       .clear(stbuf_reset[i]), .clk(lsu_stbuf_c1_clk), .*);
      rvdffe  #(.WIDTH(DATA_WIDTH))     stbuf_dataff   (.din(stbuf_datain[i][DATA_WIDTH-1:0]),     .dout(stbuf_data[i][DATA_WIDTH-1:0]),     .en(stbuf_wr_en[i]),                                                       .*);
      rvdffsc #(.WIDTH(1))              stbuf_tidff    (.din(lsu_pkt_dc5.tid),                     .dout(stbuf_tid[i]),                      .en(stbuf_wr_en[i]),       .clear(stbuf_reset[i]), .clk(lsu_free_c2_clk),  .*);









   end
      assign stbuf_reqvld_flushed_any            = stbuf_vld[RdPtr] & stbuf_dma_kill[RdPtr];
   assign stbuf_reqvld_any                    = stbuf_vld[RdPtr] & ~stbuf_dma_kill[RdPtr] & ~(|stbuf_dma_kill_en[DEPTH-1:0]);     assign stbuf_addr_any[pt.LSU_SB_BITS-1:0]  = stbuf_addr[RdPtr][pt.LSU_SB_BITS-1:0];
   assign stbuf_data_any[DATA_WIDTH-1:0]      = stbuf_data[RdPtr][DATA_WIDTH-1:0];

      assign WrPtrEn                  = (store_stbuf_reqvld_dc5  & ~ldst_dual_dc5 & ~(store_coalesce_hi_dc5 | store_coalesce_lo_dc5))  |                                       (store_stbuf_reqvld_dc5  &  ldst_dual_dc5 & ~(store_coalesce_hi_dc5 & store_coalesce_lo_dc5));       assign NxtWrPtr[DEPTH_LOG2-1:0] = (store_stbuf_reqvld_dc5 & ldst_dual_dc5 & ~(store_coalesce_hi_dc5 | store_coalesce_lo_dc5)) ? WrPtrPlus2[DEPTH_LOG2-1:0] : WrPtrPlus1[DEPTH_LOG2-1:0];
   assign RdPtrEn                  = lsu_stbuf_commit_any | stbuf_reqvld_flushed_any;
   assign NxtRdPtr[DEPTH_LOG2-1:0] = RdPtrPlus1[DEPTH_LOG2-1:0];

   always @* begin
      stbuf_numvld_any[pt.NUM_THREADS-1:0] = '0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         for (int j=0; j<DEPTH; j++) begin
            stbuf_numvld_any[i][3:0] += {3'b0, (stbuf_vld[j] & (stbuf_tid[j] == 1'(i)))};
         end
      end
   end

   assign isst_nodma_dc1 = lsu_pkt_dc1_pre.valid & lsu_pkt_dc1_pre.store;
   assign dccm_st_nodma_dc2 = lsu_pkt_dc2.valid & lsu_pkt_dc2.store & ~lsu_pkt_dc2.dma & addr_in_dccm_dc2;
   assign dccm_st_nodma_dc3 = lsu_pkt_dc3.valid & lsu_pkt_dc3.store & ~lsu_pkt_dc3.dma & addr_in_dccm_dc3;
   assign dccm_st_nodma_dc4 = lsu_pkt_dc4.valid & lsu_pkt_dc4.store & ~lsu_pkt_dc4.dma & addr_in_dccm_dc4;
   assign dccm_st_nodma_dc5 = lsu_pkt_dc5.valid & lsu_pkt_dc5.store & ~lsu_pkt_dc5.dma & addr_in_dccm_dc5;

   for (genvar i=0; i <pt.NUM_THREADS; i++) begin
       assign stbuf_specvld_dc1[i][1:0] = {1'b0,(isst_nodma_dc1    & (lsu_pkt_dc1_pre.tid == 1'(i)))} << (isst_nodma_dc1    & ldst_dual_dc1);           assign stbuf_specvld_dc2[i][1:0] = {1'b0,(dccm_st_nodma_dc2 & (lsu_pkt_dc2.tid == 1'(i)))}     << (dccm_st_nodma_dc2 & ldst_dual_dc2);
       assign stbuf_specvld_dc3[i][1:0] = {1'b0,(dccm_st_nodma_dc3 & (lsu_pkt_dc3.tid == 1'(i)))}     << (dccm_st_nodma_dc3 & ldst_dual_dc3);
       assign stbuf_specvld_dc4[i][1:0] = {1'b0,(dccm_st_nodma_dc4 & (lsu_pkt_dc4.tid == 1'(i)))}     << (dccm_st_nodma_dc4 & ldst_dual_dc4);
       assign stbuf_specvld_dc5[i][1:0] = {1'b0,(dccm_st_nodma_dc5 & (lsu_pkt_dc5.tid == 1'(i)))}     << (dccm_st_nodma_dc5 & ldst_dual_dc5);
       assign stbuf_specvld_any[i][3:0] = stbuf_numvld_any[i][3:0] +  {2'b0, stbuf_specvld_dc1[i][1:0]} + {2'b0, stbuf_specvld_dc2[i][1:0]} +
                                          {2'b0, stbuf_specvld_dc3[i][1:0]} + {2'b0, stbuf_specvld_dc4[i][1:0]} + {2'b0, stbuf_specvld_dc5[i][1:0]} -
                                          {3'b0, ((lsu_stbuf_commit_any | stbuf_reqvld_flushed_any) & (stbuf_tid[RdPtr] == 1'(i)))};

       assign stbuf_tidvld_any[i][3:0] = stbuf_specvld_anyQ[i][3:0] + {2'b0,stbuf_specvld_dc1[i][1:0]};

              assign lsu_stbuf_full_any[i]     = ((pt.NUM_THREADS > 1) & (stbuf_tidvld_any[i][3:0] >= (DEPTH - 2))) | (stbuf_total_specvld_any[3:0] > (DEPTH - 2));
       assign lsu_stbuf_empty_any[i]    = (stbuf_numvld_any[i][3:0] == 4'b0);
      rvdff #(.WIDTH(4)) stbuf_specvldff (.din(stbuf_specvld_any[i][3:0]), .dout(stbuf_specvld_anyQ[i][3:0]), .clk(lsu_free_c2_clk), .*);

   end

      always @* begin
      stbuf_total_specvld_any[3:0] = '0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         stbuf_total_specvld_any[3:0] += stbuf_tidvld_any[i][3:0];
      end
   end

      assign cmpen_hi_dc2                                     = lsu_cmpen_dc2 & ldst_dual_dc2;
   assign cmpaddr_hi_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] = end_addr_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)];

   assign cmpen_lo_dc2                                     = lsu_cmpen_dc2;
   assign cmpaddr_lo_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] = lsu_addr_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)];

   always @* begin: GenLdFwd
      stbuf_fwdbyteen_hi_dc2[BYTE_WIDTH-1:0]   = '0;
      stbuf_fwdbyteen_lo_dc2[BYTE_WIDTH-1:0]   = '0;

      for (int i=0; i<DEPTH; i++) begin
         stbuf_match_hi[i] = (stbuf_addr[i][pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] == cmpaddr_hi_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)]) & stbuf_vld[i] & ~stbuf_dma_kill[i] & addr_in_dccm_dc2;
         stbuf_match_lo[i] = (stbuf_addr[i][pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)] == cmpaddr_lo_dc2[pt.LSU_SB_BITS-1:$clog2(BYTE_WIDTH)]) & stbuf_vld[i] & ~stbuf_dma_kill[i] &  addr_in_dccm_dc2;

                  stbuf_dma_kill_en[i] = (stbuf_match_hi[i] | stbuf_match_lo[i]) & lsu_pkt_dc2.valid & lsu_pkt_dc2.dma & lsu_pkt_dc2.store;

         for (int j=0; j<BYTE_WIDTH; j++) begin
            stbuf_fwdbyteenvec_hi[i][j] = stbuf_match_hi[i] & stbuf_byteen[i][j] & stbuf_vld[i];
            stbuf_fwdbyteen_hi_dc2[j]  |= stbuf_fwdbyteenvec_hi[i][j];

            stbuf_fwdbyteenvec_lo[i][j] = stbuf_match_lo[i] & stbuf_byteen[i][j] & stbuf_vld[i];
            stbuf_fwdbyteen_lo_dc2[j]  |= stbuf_fwdbyteenvec_lo[i][j];
         end
      end
   end 
   always @* begin : Finaldata
     stbuf_fwddata_hi_dc2[31:0]   = '0;
     stbuf_fwddata_lo_dc2[31:0]   = '0;
     for (int i=0; i<DEPTH; i++) begin
         stbuf_fwddata_hi_dc2[31:0] |= {32{stbuf_match_hi[i]}} & stbuf_data[i][31:0];
         stbuf_fwddata_lo_dc2[31:0] |= {32{stbuf_match_lo[i]}} & stbuf_data[i][31:0];
      end
   end

      assign ldst_byteen_dc3[7:0] = ({8{lsu_pkt_dc3.by}}    & 8'b0000_0001) |
                                 ({8{lsu_pkt_dc3.half}}  & 8'b0000_0011) |
                                 ({8{lsu_pkt_dc3.word}}  & 8'b0000_1111) |
                                 ({8{lsu_pkt_dc3.dword}} & 8'b1111_1111);

  assign ldst_byteen_dc4[7:0] =  ({8{lsu_pkt_dc4.by}}    & 8'b0000_0001) |
                                 ({8{lsu_pkt_dc4.half}}  & 8'b0000_0011) |
                                 ({8{lsu_pkt_dc4.word}}  & 8'b0000_1111) |
                                 ({8{lsu_pkt_dc4.dword}} & 8'b1111_1111);

  assign ldst_byteen_dc5[7:0] =  ({8{lsu_pkt_dc5.by}}    & 8'b0000_0001) |
                                 ({8{lsu_pkt_dc5.half}}  & 8'b0000_0011) |
                                 ({8{lsu_pkt_dc5.word}}  & 8'b0000_1111) |
                                 ({8{lsu_pkt_dc5.dword}} & 8'b1111_1111);

   assign ldst_byteen_ext_dc3[7:0] = ldst_byteen_dc3[7:0] << lsu_addr_dc3[1:0];
   assign ldst_byteen_ext_dc4[7:0] = ldst_byteen_dc4[7:0] << lsu_addr_dc4[1:0];
   assign ldst_byteen_ext_dc5[7:0] = ldst_byteen_dc5[7:0] << lsu_addr_dc5[1:0];

   assign store_data_hi_dc3[31:0]   = store_data_ext_dc3[63:32];
   assign store_data_lo_dc3[31:0]   = store_data_ext_dc3[31:0];
   assign store_data_hi_dc4[31:0]   = store_data_ext_dc4[63:32];
   assign store_data_lo_dc4[31:0]   = store_data_ext_dc4[31:0];
   assign store_data_hi_dc5[31:0]   = store_data_ext_dc5[63:32];
   assign store_data_lo_dc5[31:0]   = store_data_ext_dc5[31:0];

   assign ldst_byteen_hi_dc3[3:0]   = ldst_byteen_ext_dc3[7:4];
   assign ldst_byteen_lo_dc3[3:0]   = ldst_byteen_ext_dc3[3:0];
   assign ldst_byteen_hi_dc4[3:0]   = ldst_byteen_ext_dc4[7:4];
   assign ldst_byteen_lo_dc4[3:0]   = ldst_byteen_ext_dc4[3:0];
   assign ldst_byteen_hi_dc5[3:0]   = ldst_byteen_ext_dc5[7:4];
   assign ldst_byteen_lo_dc5[3:0]   = ldst_byteen_ext_dc5[3:0];

   assign ld_addr_dc3hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store  & ~lsu_pkt_dc3.dma & tid_match_c2c3;
   assign ld_addr_dc3hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store  & ~lsu_pkt_dc3.dma & tid_match_c2c3;
   assign ld_addr_dc3hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store  & ~lsu_pkt_dc3.dma & ldst_dual_dc3 & tid_match_c2c3;
   assign ld_addr_dc3hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc3[31:2]) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store  & ~lsu_pkt_dc3.dma & ldst_dual_dc3 & tid_match_c2c3;

   assign ld_addr_dc4hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & ~lsu_pkt_dc4.dma & tid_match_c2c4;
   assign ld_addr_dc4hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & ~lsu_pkt_dc4.dma & tid_match_c2c4;
   assign ld_addr_dc4hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & ~lsu_pkt_dc4.dma & ldst_dual_dc4 & tid_match_c2c4;
   assign ld_addr_dc4hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc4[31:2]) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & ~lsu_pkt_dc4.dma & ldst_dual_dc4 & tid_match_c2c4;

   assign ld_addr_dc5hit_lo_lo = (lsu_addr_dc2[31:2] == lsu_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & ~lsu_pkt_dc5.dma & tid_match_c2c5;
   assign ld_addr_dc5hit_lo_hi = (end_addr_dc2[31:2] == lsu_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & ~lsu_pkt_dc5.dma & tid_match_c2c5;
   assign ld_addr_dc5hit_hi_lo = (lsu_addr_dc2[31:2] == end_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & ~lsu_pkt_dc5.dma & ldst_dual_dc5 & tid_match_c2c5;
   assign ld_addr_dc5hit_hi_hi = (end_addr_dc2[31:2] == end_addr_dc5[31:2]) & lsu_pkt_dc5.valid & lsu_pkt_dc5.store & ~lsu_pkt_dc5.dma & ldst_dual_dc5 & tid_match_c2c5;

   for (genvar i=0; i<BYTE_WIDTH; i++) begin
      assign ld_byte_dc3hit_lo_lo[i] = ld_addr_dc3hit_lo_lo & ldst_byteen_lo_dc3[i];
      assign ld_byte_dc3hit_lo_hi[i] = ld_addr_dc3hit_lo_hi & ldst_byteen_lo_dc3[i];
      assign ld_byte_dc3hit_hi_lo[i] = ld_addr_dc3hit_hi_lo & ldst_byteen_hi_dc3[i];
      assign ld_byte_dc3hit_hi_hi[i] = ld_addr_dc3hit_hi_hi & ldst_byteen_hi_dc3[i];

      assign ld_byte_dc4hit_lo_lo[i] = ld_addr_dc4hit_lo_lo & ldst_byteen_lo_dc4[i];
      assign ld_byte_dc4hit_lo_hi[i] = ld_addr_dc4hit_lo_hi & ldst_byteen_lo_dc4[i];
      assign ld_byte_dc4hit_hi_lo[i] = ld_addr_dc4hit_hi_lo & ldst_byteen_hi_dc4[i];
      assign ld_byte_dc4hit_hi_hi[i] = ld_addr_dc4hit_hi_hi & ldst_byteen_hi_dc4[i];

      assign ld_byte_dc5hit_lo_lo[i] = ld_addr_dc5hit_lo_lo & ldst_byteen_lo_dc5[i];
      assign ld_byte_dc5hit_lo_hi[i] = ld_addr_dc5hit_lo_hi & ldst_byteen_lo_dc5[i];
      assign ld_byte_dc5hit_hi_lo[i] = ld_addr_dc5hit_hi_lo & ldst_byteen_hi_dc5[i];
      assign ld_byte_dc5hit_hi_hi[i] = ld_addr_dc5hit_hi_hi & ldst_byteen_hi_dc5[i];

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

      assign ld_byte_hit_lo[i] = ld_byte_dc3hit_lo_lo[i] | ld_byte_dc3hit_hi_lo[i] |
                                 ld_byte_dc4hit_lo_lo[i] | ld_byte_dc4hit_hi_lo[i] |
                                 ld_byte_dc5hit_lo_lo[i] | ld_byte_dc5hit_hi_lo[i];

      assign ld_byte_hit_hi[i] = ld_byte_dc3hit_lo_hi[i] | ld_byte_dc3hit_hi_hi[i] |
                                 ld_byte_dc4hit_lo_hi[i] | ld_byte_dc4hit_hi_hi[i] |
                                 ld_byte_dc5hit_lo_hi[i] | ld_byte_dc5hit_hi_hi[i];

      assign stbuf_fwdbyteen_hi_fn_dc2[i] = ld_byte_hit_hi[i] | stbuf_fwdbyteen_hi_dc2[i];
      assign stbuf_fwdbyteen_lo_fn_dc2[i] = ld_byte_hit_lo[i] | stbuf_fwdbyteen_lo_dc2[i];
            assign stbuf_fwddata_lo_fn_dc2[(8*i)+7:(8*i)] = ld_byte_dc3hit_lo[i]    ? ld_fwddata_dc3pipe_lo[(8*i)+7:(8*i)] :
                                                      ld_byte_dc4hit_lo[i]    ? ld_fwddata_dc4pipe_lo[(8*i)+7:(8*i)] :
                                                      ld_byte_dc5hit_lo[i]    ? ld_fwddata_dc5pipe_lo[(8*i)+7:(8*i)] :
                                                      stbuf_fwddata_lo_dc2[(8*i)+7:(8*i)];
            assign stbuf_fwddata_hi_fn_dc2[(8*i)+7:(8*i)] = ld_byte_dc3hit_hi[i]    ? ld_fwddata_dc3pipe_hi[(8*i)+7:(8*i)] :
                                                      ld_byte_dc4hit_hi[i]    ? ld_fwddata_dc4pipe_hi[(8*i)+7:(8*i)] :
                                                      ld_byte_dc5hit_hi[i]    ? ld_fwddata_dc5pipe_hi[(8*i)+7:(8*i)] :
                                                      stbuf_fwddata_hi_dc2[(8*i)+7:(8*i)];
   end

      assign picm_fwd_en_dc2         = addr_in_pic_dc2 & (|stbuf_fwdbyteen_lo_fn_dc2[3:0]);
   assign picm_fwd_data_dc2[31:0] = stbuf_fwddata_lo_fn_dc2[31:0];

   


   rvdffs #(.WIDTH(DEPTH_LOG2)) WrPtrff                 (.din(NxtWrPtr[DEPTH_LOG2-1:0]),                  .dout(WrPtr[DEPTH_LOG2-1:0]),                 .en(WrPtrEn),  .clk(lsu_stbuf_c1_clk), .*);
   rvdffs #(.WIDTH(DEPTH_LOG2)) RdPtrff                 (.din(NxtRdPtr[DEPTH_LOG2-1:0]),                  .dout(RdPtr[DEPTH_LOG2-1:0]),                 .en(RdPtrEn),  .clk(lsu_stbuf_c1_clk), .*);

   rvdff #(.WIDTH(BYTE_WIDTH)) stbuf_fwdbyteen_hi_dc3ff (.din(stbuf_fwdbyteen_hi_fn_dc2[BYTE_WIDTH-1:0]), .dout(stbuf_fwdbyteen_hi_dc3[BYTE_WIDTH-1:0]),               .clk(lsu_c1_dc3_clk),   .*);
   rvdff #(.WIDTH(BYTE_WIDTH)) stbuf_fwdbyteen_lo_dc3ff (.din(stbuf_fwdbyteen_lo_fn_dc2[BYTE_WIDTH-1:0]), .dout(stbuf_fwdbyteen_lo_dc3[BYTE_WIDTH-1:0]),               .clk(lsu_c1_dc3_clk),   .*);

   rvdff #(.WIDTH(DATA_WIDTH)) stbuf_fwddata_hi_dc3ff   (.din(stbuf_fwddata_hi_fn_dc2[DATA_WIDTH-1:0]),   .dout(stbuf_fwddata_hi_dc3[DATA_WIDTH-1:0]),                 .clk(lsu_c1_dc3_clk),   .*);
   rvdff #(.WIDTH(DATA_WIDTH)) stbuf_fwddata_lo_dc3ff   (.din(stbuf_fwddata_lo_fn_dc2[DATA_WIDTH-1:0]),   .dout(stbuf_fwddata_lo_dc3[DATA_WIDTH-1:0]),                 .clk(lsu_c1_dc3_clk),   .*);


   `ifdef ASSERT_ON

`endif
endmodule : eh2_lsu_stbuf
