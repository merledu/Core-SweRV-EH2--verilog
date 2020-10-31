

module eh2_lsu_dccm_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (

   input wire clk,
   input wire lsu_free_c2_clk,
   input wire lsu_dccm_c1_dc3_clk,
   input wire lsu_c1_dc4_clk,
   input wire lsu_c1_dc5_clk,
   input wire lsu_c2_dc2_clk,
   input wire lsu_c2_dc3_clk,
   input wire lsu_pic_c1_dc3_clk,

   input wire rst_l,

   input                                   eh2_lsu_pkt_t lsu_pkt_dc5,        input                                   eh2_lsu_pkt_t lsu_pkt_dc4,        input                                   eh2_lsu_pkt_t lsu_pkt_dc3,        input                                   eh2_lsu_pkt_t lsu_pkt_dc2,        input                                   eh2_lsu_pkt_t lsu_pkt_dc1,
   input                                   eh2_lsu_pkt_t lsu_pkt_dc1_pre,
   input wire addr_in_dccm_region_dc1,        input wire addr_in_dccm_dc1,             input wire addr_in_pic_dc1,              input wire addr_in_pic_dc3,              input wire addr_in_dccm_dc2, addr_in_dccm_dc3, addr_in_dccm_dc4, addr_in_dccm_dc5,
   input wire addr_in_pic_dc5,
   input wire lsu_raw_fwd_lo_dc5, lsu_raw_fwd_hi_dc5,

   input wire dma_pic_wen,
   input wire dma_dccm_wen,
   input wire dma_dccm_spec_wen,
   input wire dma_dccm_spec_req,
   input wire dma_mem_write,
   input wire [31:0]                      dma_mem_addr,
   input wire [63:0]                      dma_mem_wdata,
   input wire [2:0]                       dma_mem_tag_dc3,

   input wire [31:0]                      lsu_addr_dc1,                 input wire [31:0]                      lsu_addr_dc2,                 input wire [31:0]                      lsu_addr_dc3,                 input wire [31:0]                      lsu_addr_dc4,                 input wire [31:0]                      lsu_addr_dc5,              
   input wire [31:0]                      end_addr_dc1,
   input wire [31:0]                      end_addr_dc2,
   input wire [31:0]                      end_addr_dc3,
   input wire [31:0]                      end_addr_dc4,
   input wire [31:0]                      end_addr_dc5,

   input wire stbuf_reqvld_any,             input wire [pt.LSU_SB_BITS-1:0]        stbuf_addr_any,            
   input wire [pt.DCCM_DATA_WIDTH-1:0]   stbuf_data_any,               input wire [pt.DCCM_DATA_WIDTH-1:0]   stbuf_fwddata_hi_dc3,         input wire [pt.DCCM_DATA_WIDTH-1:0]   stbuf_fwddata_lo_dc3,         input wire [pt.DCCM_BYTE_WIDTH-1:0]   stbuf_fwdbyteen_hi_dc3,       input wire [pt.DCCM_BYTE_WIDTH-1:0]   stbuf_fwdbyteen_lo_dc3,       input wire picm_fwd_en_dc2,
   input wire [31:0]                     picm_fwd_data_dc2,

   input wire lsu_commit_dc5,
   input wire lsu_sc_success_dc5,           input wire lsu_double_ecc_error_dc3,     input wire lsu_double_ecc_error_dc5,     input wire single_ecc_error_hi_dc3,      input wire single_ecc_error_lo_dc3,      input wire single_ecc_error_hi_dc4,      input wire single_ecc_error_lo_dc4,      input wire single_ecc_error_hi_dc5,      input wire single_ecc_error_lo_dc5,      input wire [pt.DCCM_DATA_WIDTH-1:0]   sec_data_hi_dc3,
   input wire [pt.DCCM_DATA_WIDTH-1:0]   sec_data_lo_dc3,

   input wire [pt.DCCM_DATA_WIDTH-1:0]   store_ecc_data_hi_dc3,      input wire [pt.DCCM_DATA_WIDTH-1:0]   store_ecc_data_lo_dc3,      input wire [31:0]                     amo_data_dc3,
   output logic [pt.DCCM_DATA_WIDTH-1:0]  dccm_data_hi_dc3,             output logic [pt.DCCM_DATA_WIDTH-1:0]  dccm_data_lo_dc3,             output logic [pt.DCCM_DATA_WIDTH-1:0]  dccm_datafn_hi_dc5,           output logic [pt.DCCM_DATA_WIDTH-1:0]  dccm_datafn_lo_dc5,           output logic [pt.DCCM_ECC_WIDTH-1:0]   dccm_data_ecc_hi_dc3,         output logic [pt.DCCM_ECC_WIDTH-1:0]   dccm_data_ecc_lo_dc3,
   output logic [63:0]                    store_data_ext_dc3, store_data_ext_dc4, store_data_ext_dc5,      output logic                           disable_ecc_check_lo_dc3,
   output logic                           disable_ecc_check_hi_dc3,
   output logic                           ld_single_ecc_error_dc3,
   output logic                           ld_single_ecc_error_dc5,
   output logic                           ld_single_ecc_error_dc5_ff,
   output logic                           ld_single_ecc_error_lo_dc5_ff,
   output logic                           ld_single_ecc_error_hi_dc5_ff,

   output logic [pt.DCCM_DATA_WIDTH-1:0]  sec_data_hi_dc5,             output logic [pt.DCCM_DATA_WIDTH-1:0]  sec_data_lo_dc5,          
   output logic [pt.DCCM_DATA_WIDTH-1:0]  lsu_dccm_data_dc3,           output logic [pt.DCCM_DATA_WIDTH-1:0]  lsu_dccm_data_corr_dc3,      output logic [31:0]                    picm_mask_data_dc3,           output logic [31:0]                    picm_rd_data_dc3,             output logic                           lsu_stbuf_commit_any,         output logic                           lsu_dccm_rden_dc3,         
   output logic                           dccm_dma_rvalid,              output logic                           dccm_dma_ecc_error,           output logic [2:0]                     dccm_dma_rtag,                output logic [63:0]                    dccm_dma_rdata,            
      output logic                           dccm_wren,                   output logic                           dccm_rden,                   output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_lo,             output logic [pt.DCCM_BITS-1:0]        dccm_wr_addr_hi,             output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_lo,             output logic [pt.DCCM_BITS-1:0]        dccm_rd_addr_hi,          
   input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo,             input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi,          
      output logic                            picm_wren,             output logic                            picm_rden,             output logic                            picm_mken,             output logic                            picm_rd_thr,         output logic [31:0]                     picm_rdaddr,           output logic [31:0]                     picm_wraddr,           output logic [31:0]                     picm_wr_data,          input wire [31:0]                      picm_rd_data,       
   input wire scan_mode           );

   localparam DCCM_WIDTH_BITS = $clog2(pt.DCCM_BYTE_WIDTH);

wire lsu_dccm_rden_dc1;
wire lsu_dccm_rden_dc2;
wire disable_ecc_check_lo_dc2;
wire disable_ecc_check_hi_dc2;
wire lsu_dccm_wren_dc1;
wire lsu_dccm_wren_spec_dc1;
reg [pt.DCCM_DATA_WIDTH-1:0] store_data_hi_dc4;
reg [pt.DCCM_DATA_WIDTH-1:0] store_data_lo_dc4;
wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_lo_dc4_in;
wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_hi_dc4_in;
wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_lo_dc5_in;
wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_hi_dc5_in;
reg [pt.DCCM_DATA_WIDTH-1:0] store_data_lo_dc5;
reg [pt.DCCM_DATA_WIDTH-1:0] store_data_hi_dc5;
wire [63:0] dccm_dout_dc3;
wire [63:0] dccm_corr_dout_dc3;
   wire [63:0]  stbuf_fwddata_dc3;
   wire [7:0]   stbuf_fwdbyteen_dc3;
wire [63:0] lsu_rdata_dc3;
wire [63:0] lsu_rdata_corr_dc3;
   reg [31:0]  picm_rd_data_dc2;
   reg [31:0]  picm_rd_dataQ;
wire [63:32] lsu_dccm_data_dc3_nc;
wire [63:32] lsu_dccm_data_corr_dc3_nc;

wire dccm_wr_bypass_c1_c2_hi;
wire dccm_wr_bypass_c1_c3_hi;
wire dccm_wr_bypass_c1_c4_hi;
wire dccm_wr_bypass_c1_c5_hi;
wire dccm_wr_bypass_c1_c2_lo;
wire dccm_wr_bypass_c1_c3_lo;
wire dccm_wr_bypass_c1_c4_lo;
wire dccm_wr_bypass_c1_c5_lo;
wire ld_single_ecc_error_lo_dc5;
wire ld_single_ecc_error_hi_dc5;
reg ld_single_ecc_error_lo_dc5_ns;
wire ld_single_ecc_error_hi_dc5_ns;
   reg         ld_single_ecc_error_dc4;
   wire         lsu_double_ecc_error_dc5_ff;
   wire         lsu_stbuf_ecc_block;
wire [pt.DCCM_BITS-1:0] ld_sec_addr_lo_dc5_ff;
wire [pt.DCCM_BITS-1:0] ld_sec_addr_hi_dc5_ff;

wire [7:0] ldst_byteen_dc2;
wire [7:0] ldst_byteen_dc3;
wire [7:0] ldst_byteen_dc4;
wire [7:0] ldst_byteen_dc5;
wire [7:0] ldst_byteen_ext_dc2;
reg [7:0] ldst_byteen_ext_dc3;
wire [7:0] ldst_byteen_ext_dc4;
wire [7:0] ldst_byteen_ext_dc5;
wire [31:0] store_data_hi_dc3;
wire [31:0] store_data_lo_dc3;

   wire         kill_ecc_corr_lo_dc5;
   wire         kill_ecc_corr_hi_dc5;

         
   assign dccm_dma_rvalid      = lsu_pkt_dc3.valid & lsu_pkt_dc3.load & lsu_pkt_dc3.dma;
   assign dccm_dma_ecc_error   = lsu_double_ecc_error_dc3;
   assign dccm_dma_rtag[2:0]   = dma_mem_tag_dc3[2:0];
   assign dccm_dma_rdata[63:0] = addr_in_pic_dc3 ? {2{picm_rd_data_dc3[31:0]}} : lsu_rdata_corr_dc3[63:0];

   assign {lsu_dccm_data_dc3_nc[63:32], lsu_dccm_data_dc3[31:0]} = lsu_rdata_dc3[63:0] >> 8*lsu_addr_dc3[1:0];
   assign {lsu_dccm_data_corr_dc3_nc[63:32], lsu_dccm_data_corr_dc3[31:0]} = lsu_rdata_corr_dc3[63:0] >> 8*lsu_addr_dc3[1:0];

   assign dccm_dout_dc3[63:0]      = {dccm_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0], dccm_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]};
   assign dccm_corr_dout_dc3[63:0] = {sec_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0], sec_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]};
   assign stbuf_fwddata_dc3[63:0]  = {stbuf_fwddata_hi_dc3[pt.DCCM_DATA_WIDTH-1:0], stbuf_fwddata_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]};
   assign stbuf_fwdbyteen_dc3[7:0] = {stbuf_fwdbyteen_hi_dc3[pt.DCCM_BYTE_WIDTH-1:0], stbuf_fwdbyteen_lo_dc3[pt.DCCM_BYTE_WIDTH-1:0]};

   for (genvar i=0; i<8; i++) begin: GenLoop
      assign lsu_rdata_dc3[(8*i)+7:8*i] = stbuf_fwdbyteen_dc3[i] ? stbuf_fwddata_dc3[(8*i)+7:8*i] : dccm_dout_dc3[(8*i)+7:8*i];
      assign lsu_rdata_corr_dc3[(8*i)+7:8*i] = stbuf_fwdbyteen_dc3[i] ? stbuf_fwddata_dc3[(8*i)+7:8*i] : dccm_corr_dout_dc3[(8*i)+7:8*i];
   end

   assign kill_ecc_corr_lo_dc5 = (((lsu_addr_dc1[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc1[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc1.valid & lsu_pkt_dc1.store & lsu_pkt_dc1.dma & addr_in_dccm_dc1) |
                                 (((lsu_addr_dc2[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc2[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc2.valid & lsu_pkt_dc2.store & lsu_pkt_dc2.dma & addr_in_dccm_dc2) |
                                 (((lsu_addr_dc3[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc3[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_pkt_dc3.dma & addr_in_dccm_dc3) |
                                 (((lsu_addr_dc4[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc4[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_pkt_dc4.dma & addr_in_dccm_dc4);

   assign kill_ecc_corr_hi_dc5 = (((lsu_addr_dc1[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc1[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc1.valid & lsu_pkt_dc1.store & lsu_pkt_dc1.dma & addr_in_dccm_dc1) |
                                 (((lsu_addr_dc2[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc2[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc2.valid & lsu_pkt_dc2.store & lsu_pkt_dc2.dma & addr_in_dccm_dc2) |
                                 (((lsu_addr_dc3[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc3[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc3.valid & lsu_pkt_dc3.store & lsu_pkt_dc3.dma & addr_in_dccm_dc3) |
                                 (((lsu_addr_dc4[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2]) | (end_addr_dc4[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2])) & lsu_pkt_dc4.valid & lsu_pkt_dc4.store & lsu_pkt_dc4.dma & addr_in_dccm_dc4);

   assign ld_single_ecc_error_lo_dc5 = (lsu_commit_dc5 | lsu_pkt_dc5.dma) & (lsu_pkt_dc5.load | lsu_pkt_dc5.lr) & single_ecc_error_lo_dc5 & ~lsu_raw_fwd_lo_dc5;
   assign ld_single_ecc_error_hi_dc5 = (lsu_commit_dc5 | lsu_pkt_dc5.dma) & (lsu_pkt_dc5.load | lsu_pkt_dc5.lr) & single_ecc_error_hi_dc5 & ~lsu_raw_fwd_hi_dc5;
   assign ld_single_ecc_error_dc3    = (lsu_pkt_dc3.load | lsu_pkt_dc3.lr) & (single_ecc_error_lo_dc3 | single_ecc_error_hi_dc3);     assign ld_single_ecc_error_dc4    = (lsu_pkt_dc4.load | lsu_pkt_dc4.lr) & (single_ecc_error_lo_dc4 | single_ecc_error_hi_dc4);     assign ld_single_ecc_error_dc5    = (ld_single_ecc_error_lo_dc5 | ld_single_ecc_error_hi_dc5) & ~lsu_double_ecc_error_dc5;       assign ld_single_ecc_error_lo_dc5_ns = ld_single_ecc_error_lo_dc5 & ~kill_ecc_corr_lo_dc5;
   assign ld_single_ecc_error_hi_dc5_ns = ld_single_ecc_error_hi_dc5 & ~kill_ecc_corr_hi_dc5;

   assign ld_single_ecc_error_dc5_ff = (ld_single_ecc_error_lo_dc5_ff | ld_single_ecc_error_hi_dc5_ff) & ~lsu_double_ecc_error_dc5_ff;

   assign sec_data_hi_dc5[pt.DCCM_DATA_WIDTH-1:0] = store_data_hi_dc5[pt.DCCM_DATA_WIDTH-1:0];
   assign sec_data_lo_dc5[pt.DCCM_DATA_WIDTH-1:0] = store_data_lo_dc5[pt.DCCM_DATA_WIDTH-1:0];

      assign lsu_stbuf_ecc_block = ld_single_ecc_error_dc3 | ld_single_ecc_error_dc4 | ld_single_ecc_error_dc5;
   assign lsu_stbuf_commit_any = stbuf_reqvld_any & ~lsu_stbuf_ecc_block &
                                 ((~(lsu_dccm_rden_dc1 | lsu_dccm_wren_spec_dc1 | ld_single_ecc_error_dc5_ff)) |
                                  (lsu_dccm_rden_dc1 & (~((stbuf_addr_any[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS] == lsu_addr_dc1[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]) |
                                                              (stbuf_addr_any[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS] == end_addr_dc1[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS])))));

         assign lsu_dccm_rden_dc1 = (lsu_pkt_dc1_pre.valid & (lsu_pkt_dc1_pre.load | lsu_pkt_dc1_pre.atomic | (lsu_pkt_dc1_pre.store & (~(lsu_pkt_dc1_pre.word | lsu_pkt_dc1_pre.dword) | (lsu_addr_dc1[1:0] != 2'b0)))) & addr_in_dccm_region_dc1) |
                              (dma_dccm_spec_req & ~dma_mem_write);   
      assign lsu_dccm_wren_dc1 = dma_dccm_wen;
   assign lsu_dccm_wren_spec_dc1 = dma_dccm_spec_wen;

      assign dccm_wren                             = lsu_stbuf_commit_any | ld_single_ecc_error_dc5_ff | lsu_dccm_wren_dc1;
   assign dccm_rden                             = lsu_dccm_rden_dc1;
   assign dccm_wr_addr_lo[pt.DCCM_BITS-1:0]     = lsu_dccm_wren_spec_dc1 ? lsu_addr_dc1[pt.DCCM_BITS-1:0] :
                                                  (ld_single_ecc_error_dc5_ff ? (ld_single_ecc_error_lo_dc5_ff ? ld_sec_addr_lo_dc5_ff[pt.DCCM_BITS-1:0] : ld_sec_addr_hi_dc5_ff[pt.DCCM_BITS-1:0]) : stbuf_addr_any[pt.DCCM_BITS-1:0]);
   assign dccm_wr_addr_hi[pt.DCCM_BITS-1:0]     = lsu_dccm_wren_spec_dc1 ? end_addr_dc1[pt.DCCM_BITS-1:0] :
                                                  (ld_single_ecc_error_dc5_ff ? (ld_single_ecc_error_hi_dc5_ff ? ld_sec_addr_hi_dc5_ff[pt.DCCM_BITS-1:0] : ld_sec_addr_lo_dc5_ff[pt.DCCM_BITS-1:0]) : stbuf_addr_any[pt.DCCM_BITS-1:0]);
   assign dccm_rd_addr_lo[pt.DCCM_BITS-1:0]     = lsu_addr_dc1[pt.DCCM_BITS-1:0];
   assign dccm_rd_addr_hi[pt.DCCM_BITS-1:0]     = end_addr_dc1[pt.DCCM_BITS-1:0];

       assign ldst_byteen_dc2[7:0] = ({8{lsu_pkt_dc2.by}}    & 8'b0000_0001) |
                                  ({8{lsu_pkt_dc2.half}}  & 8'b0000_0011) |
                                  ({8{lsu_pkt_dc2.word}}  & 8'b0000_1111) |
                                  ({8{lsu_pkt_dc2.dword}} & 8'b1111_1111);

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

   assign ldst_byteen_ext_dc2[7:0] = ldst_byteen_dc2[7:0] << lsu_addr_dc2[1:0];         assign ldst_byteen_ext_dc3[7:0] = ldst_byteen_dc3[7:0] << lsu_addr_dc3[1:0];
   assign ldst_byteen_ext_dc4[7:0] = ldst_byteen_dc4[7:0] << lsu_addr_dc4[1:0];
   assign ldst_byteen_ext_dc5[7:0] = ldst_byteen_dc5[7:0] << lsu_addr_dc5[1:0];

   assign dccm_wr_bypass_c1_c2_lo   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == lsu_addr_dc2[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc2;
   assign dccm_wr_bypass_c1_c2_hi   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == end_addr_dc2[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc2 & ~lsu_pkt_dc2.sc;   
   assign dccm_wr_bypass_c1_c3_lo   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == lsu_addr_dc3[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc3;
   assign dccm_wr_bypass_c1_c3_hi   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == end_addr_dc3[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc3 & ~lsu_pkt_dc3.sc;   
   assign dccm_wr_bypass_c1_c4_lo   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == lsu_addr_dc4[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc4;
   assign dccm_wr_bypass_c1_c4_hi   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == end_addr_dc4[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc4 & ~lsu_pkt_dc4.sc;   
   assign dccm_wr_bypass_c1_c5_lo   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == lsu_addr_dc5[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc5;
   assign dccm_wr_bypass_c1_c5_hi   = (stbuf_addr_any[pt.DCCM_BITS-1:2] == end_addr_dc5[pt.DCCM_BITS-1:2]) & addr_in_dccm_dc5 & ~lsu_pkt_dc5.sc;   
      assign store_data_lo_dc3[31:0]= (lsu_pkt_dc3.atomic & ~lsu_pkt_dc3.lr & ~lsu_pkt_dc3.sc) ? amo_data_dc3[31:0] : store_ecc_data_lo_dc3[31:0];
   assign store_data_hi_dc3[31:0]= (lsu_pkt_dc3.atomic & ~lsu_pkt_dc3.lr & ~lsu_pkt_dc3.sc) ? amo_data_dc3[31:0] : (lsu_pkt_dc3.atomic & lsu_pkt_dc3.sc) ? sec_data_lo_dc3[31:0] : store_ecc_data_hi_dc3[31:0];

      if (pt.LOAD_TO_USE_PLUS1 == 1) begin: GenL2U_1
      reg lsu_stbuf_commit_any_Q;
reg dccm_wr_bypass_c1_c2_lo_Q;
reg dccm_wr_bypass_c1_c2_hi_Q;
      reg [31:0] stbuf_data_any_Q;

      for (genvar i=0; i<4; i++) begin: Gen_dccm_data
         assign dccm_data_lo_dc3[(8*i)+7:(8*i)]     = dccm_rd_data_lo[(8*i)+7:(8*i)];
         assign dccm_data_hi_dc3[(8*i)+7:(8*i)]     = dccm_rd_data_hi[(8*i)+7:(8*i)];

         assign dccm_data_lo_dc4_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c3_lo & ~ldst_byteen_ext_dc3[i]) ? stbuf_data_any[(8*i)+7:(8*i)] :
                                                                          (lsu_stbuf_commit_any_Q & dccm_wr_bypass_c1_c2_lo_Q & ~ldst_byteen_ext_dc3[i]) ? stbuf_data_any_Q[(8*i)+7:(8*i)] : store_data_lo_dc3[(8*i)+7:(8*i)];
         assign dccm_data_hi_dc4_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c3_hi & ~ldst_byteen_ext_dc3[i+4]) ? stbuf_data_any[(8*i)+7:(8*i)] :
                                                                          (lsu_stbuf_commit_any_Q & dccm_wr_bypass_c1_c2_hi_Q & ~ldst_byteen_ext_dc3[i+4]) ? stbuf_data_any_Q[(8*i)+7:(8*i)] : store_data_hi_dc3[(8*i)+7:(8*i)];
      end

      assign dccm_data_ecc_lo_dc3[pt.DCCM_ECC_WIDTH-1:0] = dccm_rd_data_lo[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH];
      assign dccm_data_ecc_hi_dc3[pt.DCCM_ECC_WIDTH-1:0] = dccm_rd_data_hi[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH];

      rvdff #(1) stbuf_commit_ff (.din(lsu_stbuf_commit_any), .dout(lsu_stbuf_commit_any_Q), .clk(lsu_c2_dc3_clk), .*);
      rvdff #(1) dccm_wr_bypass_c1_c2_loff (.din(dccm_wr_bypass_c1_c2_lo), .dout(dccm_wr_bypass_c1_c2_lo_Q), .clk(lsu_c2_dc3_clk), .*);
      rvdff #(1) dccm_wr_bypass_c1_c2_hiff (.din(dccm_wr_bypass_c1_c2_hi), .dout(dccm_wr_bypass_c1_c2_hi_Q), .clk(lsu_c2_dc3_clk), .*);
      rvdffe #(32) stbuf_data_anyff (.din(stbuf_data_any[31:0]), .dout(stbuf_data_any_Q[31:0]), .en(lsu_stbuf_commit_any), .*);

   end else begin: GenL2U_0
reg [pt.DCCM_DATA_WIDTH-1:0] dccm_data_hi_dc2;
wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_lo_dc2;
wire [pt.DCCM_ECC_WIDTH-1:0] dccm_data_ecc_hi_dc2;
wire [pt.DCCM_ECC_WIDTH-1:0] dccm_data_ecc_lo_dc2;

      for (genvar i=0; i<4; i++) begin: Gen_dccm_data
         assign dccm_data_lo_dc2[(8*i)+7:(8*i)]     = (lsu_stbuf_commit_any &  lsu_pkt_dc2.store & dccm_wr_bypass_c1_c2_lo & ~ldst_byteen_ext_dc2[i])   ? stbuf_data_any[(8*i)+7:(8*i)] : dccm_rd_data_lo[(8*i)+7:(8*i)];          assign dccm_data_hi_dc2[(8*i)+7:(8*i)]     = (lsu_stbuf_commit_any &  lsu_pkt_dc2.store & dccm_wr_bypass_c1_c2_hi & ~ldst_byteen_ext_dc2[i+4]) ? stbuf_data_any[(8*i)+7:(8*i)] : dccm_rd_data_hi[(8*i)+7:(8*i)]; 
         assign dccm_data_lo_dc4_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c3_lo & ~ldst_byteen_ext_dc3[i])   ? stbuf_data_any[(8*i)+7:(8*i)] : store_data_lo_dc3[(8*i)+7:(8*i)];
         assign dccm_data_hi_dc4_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c3_hi & ~ldst_byteen_ext_dc3[i+4]) ? stbuf_data_any[(8*i)+7:(8*i)] : store_data_hi_dc3[(8*i)+7:(8*i)];
      end

      assign dccm_data_ecc_lo_dc2[pt.DCCM_ECC_WIDTH-1:0] = dccm_rd_data_lo[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH];
      assign dccm_data_ecc_hi_dc2[pt.DCCM_ECC_WIDTH-1:0] = dccm_rd_data_hi[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH];
      rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_hi_dc3ff (.*, .din(dccm_data_hi_dc2[pt.DCCM_DATA_WIDTH-1:0]),    .dout(dccm_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_dccm_c1_dc3_clk));
      rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_lo_dc3ff (.*, .din(dccm_data_lo_dc2[pt.DCCM_DATA_WIDTH-1:0]),    .dout(dccm_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_dccm_c1_dc3_clk));

      rvdff #(pt.DCCM_ECC_WIDTH) dccm_data_ecc_hi_ff (.*, .din(dccm_data_ecc_hi_dc2[pt.DCCM_ECC_WIDTH-1:0]), .dout(dccm_data_ecc_hi_dc3[pt.DCCM_ECC_WIDTH-1:0]), .clk(lsu_dccm_c1_dc3_clk));
      rvdff #(pt.DCCM_ECC_WIDTH) dccm_data_ecc_lo_ff (.*, .din(dccm_data_ecc_lo_dc2[pt.DCCM_ECC_WIDTH-1:0]), .dout(dccm_data_ecc_lo_dc3[pt.DCCM_ECC_WIDTH-1:0]), .clk(lsu_dccm_c1_dc3_clk));


   end


   for (genvar i=0; i<4; i++) begin: Gen_dccm_data_dc4_dc5
      assign dccm_data_lo_dc5_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c4_lo & ~ldst_byteen_ext_dc4[i])   ? stbuf_data_any[(8*i)+7:(8*i)] : store_data_lo_dc4[(8*i)+7:(8*i)];
      assign dccm_data_hi_dc5_in[(8*i)+7:(8*i)]  = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c4_hi & ~ldst_byteen_ext_dc4[i+4]) ? stbuf_data_any[(8*i)+7:(8*i)] : store_data_hi_dc4[(8*i)+7:(8*i)];

            assign dccm_datafn_lo_dc5[(8*i)+7:(8*i)]   = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c5_lo & ~ldst_byteen_ext_dc5[i]) ? stbuf_data_any[(8*i)+7:(8*i)] :
                                                                                 (lsu_pkt_dc5.atomic & lsu_pkt_dc5.sc & ~lsu_sc_success_dc5) ? store_data_hi_dc5[(8*i)+7:(8*i)] : store_data_lo_dc5[(8*i)+7:(8*i)];
      assign dccm_datafn_hi_dc5[(8*i)+7:(8*i)]   = (lsu_stbuf_commit_any &  dccm_wr_bypass_c1_c5_hi & ~ldst_byteen_ext_dc5[i+4]) ? stbuf_data_any[(8*i)+7:(8*i)] : store_data_hi_dc5[(8*i)+7:(8*i)];
   end 
      assign disable_ecc_check_lo_dc2 = lsu_stbuf_commit_any & lsu_pkt_dc2.store & dccm_wr_bypass_c1_c2_lo;
   assign disable_ecc_check_hi_dc2 = lsu_stbuf_commit_any & lsu_pkt_dc2.store & dccm_wr_bypass_c1_c2_hi;

      assign picm_wren          = (lsu_pkt_dc5.valid & lsu_pkt_dc5.store & addr_in_pic_dc5 & lsu_commit_dc5) | dma_pic_wen;
   assign picm_rden          = lsu_pkt_dc1.valid & lsu_pkt_dc1.load  & addr_in_pic_dc1;
   assign picm_mken          = lsu_pkt_dc1.valid & lsu_pkt_dc1.store & addr_in_pic_dc1;     assign picm_rd_thr        = lsu_pkt_dc1.tid;
   assign picm_rdaddr[31:0]  = lsu_addr_dc1[31:0];
   assign picm_wraddr[31:0]  = dma_pic_wen ? dma_mem_addr[31:0] : lsu_addr_dc5[31:0];
   assign picm_wr_data[31:0] = dma_pic_wen ? dma_mem_wdata[31:0] : store_data_lo_dc5[31:0];

      assign store_data_ext_dc3[63:0] = {store_ecc_data_hi_dc3[31:0], store_ecc_data_lo_dc3[31:0]};      assign store_data_ext_dc4[63:0] = {store_data_hi_dc4[31:0], store_data_lo_dc4[31:0]};
   assign store_data_ext_dc5[63:0] = {store_data_hi_dc5[31:0], store_data_lo_dc5[31:0]};

      assign picm_mask_data_dc3[31:0] = picm_rd_dataQ[31:0];      assign picm_rd_data_dc2 = picm_fwd_en_dc2 ? picm_fwd_data_dc2[31:0] : picm_rd_data[31:0];

   rvdff #(32) picm_data_ff    (.*, .din(picm_rd_data_dc2[31:0]), .dout(picm_rd_data_dc3[31:0]), .clk(lsu_pic_c1_dc3_clk));
   rvdff #(32) picm_rd_data_ff (.*, .din(picm_rd_data[31:0]),     .dout(picm_rd_dataQ[31:0]),    .clk(lsu_pic_c1_dc3_clk));

   rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_hi_dc4ff (.*, .din(dccm_data_hi_dc4_in[pt.DCCM_DATA_WIDTH-1:0]), .dout(store_data_hi_dc4[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_c1_dc4_clk));
   rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_lo_dc4ff (.*, .din(dccm_data_lo_dc4_in[pt.DCCM_DATA_WIDTH-1:0]), .dout(store_data_lo_dc4[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_c1_dc4_clk));

   rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_hi_dc5ff (.*, .din(dccm_data_hi_dc5_in[pt.DCCM_DATA_WIDTH-1:0]), .dout(store_data_hi_dc5[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_c1_dc5_clk));
   rvdff #(pt.DCCM_DATA_WIDTH) dccm_data_lo_dc5ff (.*, .din(dccm_data_lo_dc5_in[pt.DCCM_DATA_WIDTH-1:0]), .dout(store_data_lo_dc5[pt.DCCM_DATA_WIDTH-1:0]),    .clk(lsu_c1_dc5_clk));

   if (pt.DCCM_ENABLE == 1) begin: Gen_dccm_enable
      rvdff #(1) dccm_rden_dc2ff (.*, .din(lsu_dccm_rden_dc1), .dout(lsu_dccm_rden_dc2), .clk(lsu_c2_dc2_clk));
      rvdff #(1) dccm_rden_dc3ff (.*, .din(lsu_dccm_rden_dc2), .dout(lsu_dccm_rden_dc3), .clk(lsu_c2_dc3_clk));

      rvdff #(1) ecc_disable_hi_dc3ff (.*, .din(disable_ecc_check_hi_dc2),    .dout(disable_ecc_check_hi_dc3),    .clk(lsu_dccm_c1_dc3_clk));
      rvdff #(1) ecc_disable_lo_dc3ff (.*, .din(disable_ecc_check_lo_dc2),    .dout(disable_ecc_check_lo_dc3),    .clk(lsu_dccm_c1_dc3_clk));

      // ECC correction flops since dccm write happens next cycle
      // We are writing to dccm in dc5+1 for ecc correction since fast_int needs to be blocked in decode - 2.
      rvdff #(1) lsu_double_ecc_error_dc5ff     (.*, .din(lsu_double_ecc_error_dc5),   .dout(lsu_double_ecc_error_dc5_ff),   .clk(lsu_free_c2_clk));
      rvdff #(1) ld_single_ecc_error_hi_dc5ff   (.*, .din(ld_single_ecc_error_hi_dc5_ns), .dout(ld_single_ecc_error_hi_dc5_ff), .clk(lsu_free_c2_clk));
      rvdff #(1) ld_single_ecc_error_lo_dc5ff   (.*, .din(ld_single_ecc_error_lo_dc5_ns), .dout(ld_single_ecc_error_lo_dc5_ff), .clk(lsu_free_c2_clk));
      rvdffe #(pt.DCCM_BITS) ld_sec_addr_hi_rff (.*, .din(end_addr_dc5[pt.DCCM_BITS-1:0]), .dout(ld_sec_addr_hi_dc5_ff[pt.DCCM_BITS-1:0]), .en(ld_single_ecc_error_dc5), .clk(clk));
      rvdffe #(pt.DCCM_BITS) ld_sec_addr_lo_rff (.*, .din(lsu_addr_dc5[pt.DCCM_BITS-1:0]), .dout(ld_sec_addr_lo_dc5_ff[pt.DCCM_BITS-1:0]), .en(ld_single_ecc_error_dc5), .clk(clk));

   end else begin: Gen_dccm_disable
      assign lsu_dccm_rden_dc2 = '0;
      assign lsu_dccm_rden_dc3 = '0;
      assign disable_ecc_check_lo_dc3 = 1'b1;
      assign disable_ecc_check_hi_dc3 = 1'b1;

      assign lsu_double_ecc_error_dc5_ff = '0;
      assign ld_single_ecc_error_lo_dc5_ff = '0;
      assign ld_single_ecc_error_hi_dc5_ff = '0;
      assign ld_sec_addr_lo_dc5_ff[pt.DCCM_BITS-1:0] = '0;
      assign ld_sec_addr_hi_dc5_ff[pt.DCCM_BITS-1:0] = '0;
   end

endmodule
