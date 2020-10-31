
module eh2_ifu
 import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
 (
   input wire free_clk,
   input wire active_clk,
   input wire clk,
   input wire clk_override,
   input wire rst_l,

   input wire [pt.NUM_THREADS-1:0]        dec_i1_cancel_e1,

   input wire [pt.NUM_THREADS-1:0]        dec_ib3_valid_d,              input wire [pt.NUM_THREADS-1:0]        dec_ib2_valid_d,           
   input wire dec_i0_tid_e4,    input wire dec_i1_tid_e4,

   input wire exu_i0_br_ret_e4,     input wire exu_i1_br_ret_e4,     input wire exu_i0_br_call_e4,    input wire exu_i1_br_call_e4, 
   input wire [pt.NUM_THREADS-1:0][31:1] exu_flush_path_final,    input wire [31:0]  dec_tlu_mrac_ff ,
   input wire dec_tlu_bpred_disable,    input wire dec_tlu_core_ecc_disable,  

   input wire [pt.NUM_THREADS-1:0]        exu_flush_final,
   input wire [pt.NUM_THREADS-1:0]        dec_tlu_flush_err_wb ,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_flush_noredir_wb,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_flush_lower_wb,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_fence_i_wb,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_flush_leak_one_wb,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_force_halt , 
        output logic                            ifu_axi_awvalid,
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
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   output logic                            ifu_axi_bready,

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


   input wire ifu_bus_clk_en,

   input wire dma_iccm_req,
   input wire [2:0]                dma_mem_tag,
   input wire [31:0]               dma_mem_addr,
   input wire [2:0]                dma_mem_sz,
   input wire dma_mem_write,
   input wire [63:0]               dma_mem_wdata,
   input wire dma_iccm_stall_any,


   output logic                      iccm_dma_ecc_error,
   output logic                      iccm_dma_rvalid,
   output logic [2:0]                iccm_dma_rtag,
   output logic [63:0]               iccm_dma_rdata,
   output logic                      iccm_ready,

   output logic [pt.NUM_THREADS-1:0][1:0] ifu_pmu_instr_aligned,
   output logic [pt.NUM_THREADS-1:0]      ifu_pmu_align_stall,

   output logic [pt.NUM_THREADS-1:0] ifu_pmu_fetch_stall,

   output logic [31:1]               ic_rw_addr,            output logic [pt.ICACHE_NUM_WAYS-1:0]                ic_wr_en,              output logic                      ic_rd_en,           
   output logic [pt.ICACHE_BANKS_WAY-1:0] [70:0]               ic_wr_data,              input wire [63:0]               ic_rd_data ,             input wire [70:0]               ic_debug_rd_data ,       input wire [25:0]               ictag_debug_rd_data,     output logic [70:0]               ic_debug_wr_data,        output logic [70:0]               ifu_ic_debug_rd_data, 
   input wire [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr,       input wire [pt.ICACHE_BANKS_WAY-1:0] ic_parerr,



   output logic [63:0]               ic_premux_data,        output logic                      ic_sel_premux_data, 
   output logic [pt.ICACHE_INDEX_HI:3]  ic_debug_addr,         output logic                         ic_debug_rd_en,        output logic                         ic_debug_wr_en,        output logic                         ic_debug_tag_array,    output logic [pt.ICACHE_NUM_WAYS-1:0]ic_debug_way,       

   output logic [pt.ICACHE_NUM_WAYS-1:0]                ic_tag_valid,       
   input wire [pt.ICACHE_NUM_WAYS-1:0]                ic_rd_hit,             input wire ic_tag_perr,        

      output logic [pt.ICCM_BITS-1:1]   iccm_rw_addr,                           output logic [pt.NUM_THREADS-1:0] iccm_buf_correct_ecc_thr,               output logic                      iccm_stop_fetch,                        output logic                      iccm_correction_state,                  output logic                      iccm_corr_scnd_fetch,                
   output logic                      ifc_select_tid_f1,     output logic                      iccm_wren,             output logic                      iccm_rden,             output logic [77:0]               iccm_wr_data,          output logic [2:0]                iccm_wr_size,       
   input wire [63:0]               iccm_rd_data,          input wire [116:0]              iccm_rd_data_ecc,   
   output logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_miss,                  output logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_hit,                   output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_error,                output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_busy,                 output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_trxn,              
   output logic  [pt.NUM_THREADS-1:0] ifu_i0_valid,           output logic  [pt.NUM_THREADS-1:0] ifu_i1_valid,           output logic  [pt.NUM_THREADS-1:0] ifu_i0_icaf,         
   output logic  [pt.NUM_THREADS-1:0] [1:0]  ifu_i0_icaf_type, 
   output logic  [pt.NUM_THREADS-1:0] ifu_i0_icaf_f1,         output logic  [pt.NUM_THREADS-1:0] ifu_i0_dbecc,           output logic                     iccm_dma_sb_error,      output logic  [pt.NUM_THREADS-1:0] [31:0] ifu_i0_instr,      output logic  [pt.NUM_THREADS-1:0] [31:0] ifu_i1_instr,      output logic  [pt.NUM_THREADS-1:0] [31:1] ifu_i0_pc,         output logic  [pt.NUM_THREADS-1:0] [31:1] ifu_i1_pc,         output logic  [pt.NUM_THREADS-1:0] ifu_i0_pc4,              output logic  [pt.NUM_THREADS-1:0] ifu_i1_pc4,              output eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i0_predecode,
   output eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i1_predecode,


   output eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_brp,              output eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_brp,              output logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i0_bp_index,    output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           ifu_i0_bp_fghr,    output logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          ifu_i0_bp_btag,    output logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i1_bp_index,    output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           ifu_i1_bp_fghr,    output logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          ifu_i1_bp_btag, 
   input eh2_predict_pkt_t [pt.NUM_THREADS-1:0]                    exu_mp_pkt,    input wire [pt.NUM_THREADS-1:0][pt.BHT_GHR_SIZE-1:0]            exu_mp_eghr,    input wire [pt.NUM_THREADS-1:0][pt.BHT_GHR_SIZE-1:0]            exu_mp_fghr,                       input wire [pt.NUM_THREADS-1:0][pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  exu_mp_index,            input wire [pt.NUM_THREADS-1:0][pt.BTB_BTAG_SIZE-1:0]           exu_mp_btag,                   
   input eh2_br_tlu_pkt_t                     dec_tlu_br0_wb_pkt,    input eh2_br_tlu_pkt_t                     dec_tlu_br1_wb_pkt,    input wire [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br0_fghr_wb,    input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br0_index_wb,    input wire [pt.BHT_GHR_SIZE-1:0]           dec_tlu_br1_fghr_wb,    input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br1_index_wb, 
   input [pt.NUM_THREADS-1:0] dec_tlu_i0_commit_cmt,


   output logic [pt.NUM_THREADS-1:0] [15:0] ifu_i0_cinst,
   output logic [pt.NUM_THREADS-1:0] [15:0] ifu_i1_cinst,


   input  eh2_cache_debug_pkt_t        dec_tlu_ic_diag_pkt ,
   output logic                    ifu_ic_debug_rd_data_valid,


   output logic [pt.NUM_THREADS-1:0]  ifu_miss_state_idle,             output logic [pt.NUM_THREADS-1:0]  ifu_ic_error_start,              output logic [pt.NUM_THREADS-1:0]  ifu_iccm_rd_ecc_single_err,   
   input wire scan_mode
   );

   localparam TAGWIDTH = 2 ;
   localparam IDWIDTH  = 2 ;

   wire                   ifc_fetch_uncacheable_f1;

   wire [3:0]   ifu_fetch_val;     wire [31:1]  ifu_fetch_pc;   
wire [31:1] ifc_fetch_addr_f1;
reg [31:1] ifc_fetch_addr_f2;

   reg [pt.NUM_THREADS-1:0]   ic_write_stall_thr;
   reg        ic_dma_active;
   wire        ifc_dma_access_ok;
   wire        ifc_iccm_access_f1;
   wire        ifc_region_acc_fault_f1;
   reg        ic_access_fault_f2;
   reg  [1:0] ic_access_fault_type_f2;   reg [pt.NUM_THREADS-1:0]                                             ifu_ic_mb_empty_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_crit_wd_rdy_thr;
   reg [3:0]   ic_fetch_val_f2;
   reg [63:0]  ic_data_f2;
   wire [63:0]  ifu_fetch_data;
wire ifc_fetch_req_f1_raw;
wire ifc_fetch_req_f1;
wire ifc_fetch_req_f2;
   reg         iccm_rd_ecc_single_err;     reg         iccm_rd_ecc_double_err;     reg [pt.NUM_THREADS-1:0]         ifu_async_error_start;

   reg ifu_fetch_tid;
   reg ic_hit_f2;


reg [pt.NUM_THREADS-1:0] [31:1] fetch_addr_f1 [pt.NUM_THREADS-1:0];
reg [pt.NUM_THREADS-1:0] [31:1] fetch_uncacheable_f1 [pt.NUM_THREADS-1:0];
reg [pt.NUM_THREADS-1:0] [31:1] fetch_req_f1 [pt.NUM_THREADS-1:0];
reg [pt.NUM_THREADS-1:0] [31:1] fetch_req_f1_raw [pt.NUM_THREADS-1:0];
reg [pt.NUM_THREADS-1:0] [31:1] fetch_req_f2 [pt.NUM_THREADS-1:0],
                              iccm_access_f1, region_acc_fault_f1, dma_access_ok,
                              ifc_ready;

   reg [pt.NUM_THREADS-1:0] fb_consume1;                                      reg [pt.NUM_THREADS-1:0] fb_consume2;                                   
wire [pt.NUM_THREADS-1:0] dec_tlu_i0_commit_cmt_thr;
wire  fetch_tid_f1 ;
   wire [pt.NUM_THREADS-1:0] i0_valid;                                         wire [pt.NUM_THREADS-1:0] i1_valid;                                         wire [pt.NUM_THREADS-1:0] i0_icaf;                                          wire [pt.NUM_THREADS-1:0] [1:0]  i0_icaf_type;                              wire [pt.NUM_THREADS-1:0] i0_icaf_f1;                                       wire [pt.NUM_THREADS-1:0] i0_dbecc;                                         wire [pt.NUM_THREADS-1:0] [31:0] i0_instr;                                  wire [pt.NUM_THREADS-1:0] [31:0] i1_instr;                                  wire [pt.NUM_THREADS-1:0] [31:1] i0_pc;                                     wire [pt.NUM_THREADS-1:0] [31:1] i1_pc;                                     wire [pt.NUM_THREADS-1:0] i0_pc4;
   wire [pt.NUM_THREADS-1:0] i1_pc4;
   eh2_predecode_pkt_t [pt.NUM_THREADS-1:0] i0_predecode;
   eh2_predecode_pkt_t [pt.NUM_THREADS-1:0] i1_predecode;
   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_br_p;                                       eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_br_p;                                       logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  i0_bp_index;     logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]            i0_bp_fghr;      logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]           i0_bp_btag;      logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  i1_bp_index;     logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]            i1_bp_fghr;      logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]           i1_bp_btag;      logic [pt.NUM_THREADS-1:0] [1:0] pmu_instr_aligned;                          logic [pt.NUM_THREADS-1:0]       pmu_align_stall;                            logic [pt.NUM_THREADS-1:0] [15:0] i0_cinst;                                  logic [pt.NUM_THREADS-1:0] [15:0] i1_cinst;                                  logic [3:0]  ifu_bp_way_f2;    logic  ifu_bp_kill_next_f2;    logic [31:1] ifu_bp_btb_target_f2;    logic [3:1]  ifu_bp_inst_mask_f2; 
   reg [3:0]  ifu_bp_hist1_f2;    reg [3:0]  ifu_bp_hist0_f2;    reg [11:0] ifu_bp_poffset_f2;    reg [3:0]  ifu_bp_ret_f2;    reg [3:0]  ifu_bp_pc4_f2;    reg [3:0]  ifu_bp_valid_f2;    reg [pt.BHT_GHR_SIZE-1:0] ifu_bp_fghr_f2;

     for (genvar i=0; i<pt.NUM_THREADS; i++) begin : ifc

        eh2_ifu_ifc_ctl #(.pt(pt)) ifc (.tid               (1'(i)),
                                         .ic_write_stall(ic_write_stall_thr[i]),
                                         .ifu_ic_mb_empty(ifu_ic_mb_empty_thr[i]),
                                         .ic_crit_wd_rdy(ic_crit_wd_rdy_thr[i]),
                                         .ifu_fb_consume1(fb_consume1[i]),
                                         .ifu_fb_consume2(fb_consume2[i]),
                                         .dec_tlu_flush_noredir_wb(dec_tlu_flush_noredir_wb[i]),
                                         .exu_flush_final(exu_flush_final[i]),
                                         .exu_flush_path_final(exu_flush_path_final[i]),

                                         .fetch_uncacheable_f1(fetch_uncacheable_f1[i]),
                                         .fetch_addr_f1(fetch_addr_f1[i]),
                                         .fetch_req_f1(fetch_req_f1[i]),
                                         .fetch_req_f1_raw(fetch_req_f1_raw[i]),
                                         .fetch_req_f2(fetch_req_f2[i]),
                                         .pmu_fetch_stall(ifu_pmu_fetch_stall[i]),
                                         .iccm_access_f1(iccm_access_f1[i]),
                                         .region_acc_fault_f1(region_acc_fault_f1[i]),
                                         .dma_access_ok(dma_access_ok[i]),
                                         .ready(ifc_ready[i]),
                                            .*
                                         );

     end 
   if (pt.NUM_THREADS == 2) begin: genmtifc

      rvarbiter2 ifc_arbiter (
                             .ready(ifc_ready[1:0]),
                             .tid  (ifc_select_tid_f1),
                             .shift(ifc_fetch_req_f1),
                                .*
                             );
   end
   else begin
      assign ifc_select_tid_f1 = 1'b0;
   end


   assign ifc_fetch_uncacheable_f1 = fetch_uncacheable_f1[ifc_select_tid_f1];
   assign ifc_fetch_addr_f1[31:1]  = fetch_addr_f1[ifc_select_tid_f1];
   assign ifc_fetch_req_f1 = fetch_req_f1[ifc_select_tid_f1];
   assign ifc_fetch_req_f1_raw = fetch_req_f1_raw[ifc_select_tid_f1];
   assign ifc_iccm_access_f1 = iccm_access_f1[ifc_select_tid_f1];
   assign ifc_region_acc_fault_f1 = region_acc_fault_f1[ifc_select_tid_f1];

   assign ifc_fetch_req_f2 = fetch_req_f2[ifu_fetch_tid];

   assign ifc_dma_access_ok = &dma_access_ok[pt.NUM_THREADS-1:0];

 eh2_ifu_bp_ctl #(.pt(pt)) bp (.*);


   


   assign ifu_fetch_data[63:0]  = ic_data_f2[63:0];
   assign ifu_fetch_val[3:0]    = ic_fetch_val_f2[3:0];
   assign ifu_fetch_pc[31:1]    = ifc_fetch_addr_f2[31:1];

   
   


  for (genvar i=0; i<pt.NUM_THREADS; i++) begin : aln

     eh2_ifu_aln_ctl #(.pt(pt)) aln (.tid               (1'(i)),
                                      .dec_i1_cancel_e1  (dec_i1_cancel_e1[i]),
                                      .dec_ib3_valid_d   (dec_ib3_valid_d[i]),
                                      .dec_ib2_valid_d   (dec_ib2_valid_d[i]),
                                      .exu_flush_final   (exu_flush_final[i]),
                                      .ifu_async_error_start (ifu_async_error_start[i]),
                                      .i0_valid          (i0_valid[i]),
                                      .i1_valid          (i1_valid[i]),
                                      .i0_icaf           (i0_icaf[i]),
                                      .i0_icaf_type      (i0_icaf_type[i]),
                                      .i0_icaf_f1        (i0_icaf_f1[i]),
                                      .i0_dbecc          (i0_dbecc[i]),
                                      .i0_instr          (i0_instr[i]),
                                      .i1_instr          (i1_instr[i]),
                                      .i0_pc             (i0_pc[i]),
                                      .i1_pc             (i1_pc[i]),
                                      .i0_pc4            (i0_pc4[i]),
                                      .i1_pc4            (i1_pc4[i]),
                                      .i0_predecode      (i0_predecode[i]),
                                      .i1_predecode      (i1_predecode[i]),
                                      .fb_consume1       (fb_consume1[i]),
                                      .fb_consume2       (fb_consume2[i]),
                                      .i0_br_p           (i0_br_p[i]),
                                      .i1_br_p           (i1_br_p[i]),
                                      .i0_bp_index       (i0_bp_index[i]),
                                      .i0_bp_fghr        (i0_bp_fghr[i]),
                                      .i0_bp_btag        (i0_bp_btag[i]),
                                      .i1_bp_index       (i1_bp_index[i]),
                                      .i1_bp_fghr        (i1_bp_fghr[i]),
                                      .i1_bp_btag        (i1_bp_btag[i]),
                                      .pmu_instr_aligned (pmu_instr_aligned[i]),
                                      .pmu_align_stall   (pmu_align_stall[i]),
                                      .i0_cinst          (i0_cinst[i]),
                                      .i1_cinst          (i1_cinst[i]),
                                      .*);
  end






      assign dec_tlu_i0_commit_cmt_thr[pt.NUM_THREADS-1:0] =   dec_tlu_i0_commit_cmt[pt.NUM_THREADS-1:0] ;

      assign ifu_i0_valid [pt.NUM_THREADS-1:0] =     i0_valid[pt.NUM_THREADS-1:0];
      assign ifu_i1_valid [pt.NUM_THREADS-1:0] =     i1_valid[pt.NUM_THREADS-1:0];
      assign ifu_i0_icaf  [pt.NUM_THREADS-1:0] =     i0_icaf[pt.NUM_THREADS-1:0];
      assign ifu_i0_icaf_type [pt.NUM_THREADS-1:0] = i0_icaf_type[pt.NUM_THREADS-1:0];
      assign ifu_i0_icaf_f1   [pt.NUM_THREADS-1:0] = i0_icaf_f1[pt.NUM_THREADS-1:0];
      assign ifu_i0_dbecc [pt.NUM_THREADS-1:0] =     i0_dbecc[pt.NUM_THREADS-1:0];
      assign ifu_i0_instr [pt.NUM_THREADS-1:0] =     i0_instr[pt.NUM_THREADS-1:0];
      assign ifu_i1_instr [pt.NUM_THREADS-1:0] =     i1_instr[pt.NUM_THREADS-1:0];
      assign ifu_i0_pc    [pt.NUM_THREADS-1:0] =     i0_pc[pt.NUM_THREADS-1:0];
      assign ifu_i1_pc    [pt.NUM_THREADS-1:0] =     i1_pc[pt.NUM_THREADS-1:0];
      assign ifu_i0_pc4   [pt.NUM_THREADS-1:0] =     i0_pc4[pt.NUM_THREADS-1:0];
      assign ifu_i1_pc4   [pt.NUM_THREADS-1:0] =     i1_pc4[pt.NUM_THREADS-1:0];
      assign ifu_i0_predecode [pt.NUM_THREADS-1:0] = i0_predecode[pt.NUM_THREADS-1:0];
      assign ifu_i1_predecode [pt.NUM_THREADS-1:0] = i1_predecode[pt.NUM_THREADS-1:0];
      assign i0_brp [pt.NUM_THREADS-1:0] =           i0_br_p[pt.NUM_THREADS-1:0];
      assign i1_brp [pt.NUM_THREADS-1:0] =           i1_br_p[pt.NUM_THREADS-1:0];
      assign ifu_i0_bp_index [pt.NUM_THREADS-1:0] =  i0_bp_index[pt.NUM_THREADS-1:0];
      assign ifu_i0_bp_fghr  [pt.NUM_THREADS-1:0] =  i0_bp_fghr[pt.NUM_THREADS-1:0];
      assign ifu_i0_bp_btag  [pt.NUM_THREADS-1:0] =  i0_bp_btag[pt.NUM_THREADS-1:0];
      assign ifu_i1_bp_index [pt.NUM_THREADS-1:0] =  i1_bp_index[pt.NUM_THREADS-1:0];
      assign ifu_i1_bp_fghr  [pt.NUM_THREADS-1:0] =  i1_bp_fghr[pt.NUM_THREADS-1:0];
      assign ifu_i1_bp_btag  [pt.NUM_THREADS-1:0] =  i1_bp_btag[pt.NUM_THREADS-1:0];
      assign ifu_i0_cinst [pt.NUM_THREADS-1:0] =     i0_cinst[pt.NUM_THREADS-1:0];
      assign ifu_i1_cinst [pt.NUM_THREADS-1:0] =     i1_cinst[pt.NUM_THREADS-1:0];



   assign ifu_pmu_instr_aligned[pt.NUM_THREADS-1:0] = pmu_instr_aligned[pt.NUM_THREADS-1:0];

   assign ifu_pmu_align_stall[pt.NUM_THREADS-1:0] = pmu_align_stall[pt.NUM_THREADS-1:0];

   assign fetch_tid_f1 = ifc_select_tid_f1;


      eh2_ifu_mem_ctl #(.pt(pt)) mem_ctl
     (.*,
      .fetch_addr_f1         (ifc_fetch_addr_f1),
      .fetch_tid_f2          (ifu_fetch_tid),
      .dec_tlu_i0_commit_cmt (dec_tlu_i0_commit_cmt_thr)
      );



         `ifdef DUMP_BTB_ON

 `define DEC `CPU_TOP.dec
 `define EXU `CPU_TOP.exu

   reg exu_mp_valid;    reg exu_mp_way;    reg exu_mp_ataken;    reg exu_mp_boffset;    reg exu_mp_pc4;    reg exu_mp_call;    reg exu_mp_ret;    reg exu_mp_ja;    reg exu_mp_bank;    reg [1:0] exu_mp_hist;    reg [11:0] exu_mp_tgt;    reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_mp_addr;    reg [3:0] ic_rd_hit_f2;
   wire [1:0] tmp_bnk;
wire [31:0] mppc_ns0;
reg [31:0] mppc0;
wire [31:0] mppc_ns1;
reg [31:0] mppc1;
reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] btb_rd_addr_f2;
reg [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] btb_rd_addr_p1_f2;
reg [pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] bht_rd_addr_f2;
reg [pt.BHT_ADDR_HI:pt.BHT_ADDR_LO] bht_rd_addr_p1_f2;
   wire                                 i;

   eh2_btb_addr_hash #(.pt(pt)) f2hash(.pc(ifc_fetch_addr_f2[pt.BTB_INDEX3_HI:pt.BTB_INDEX1_LO]), .hash(btb_rd_addr_f2[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]));
   wire use_p1;
   assign use_p1 = (bp.fetch_start_f2[1] & bp.vwayhit_f2[3]) | (bp.fetch_start_f2[2] & |bp.vwayhit_f2[3:2]) | (bp.fetch_start_f2[3] & |bp.vwayhit_f2[3:1]) ;

   assign mppc_ns0[0] = 1'b0;
   assign mppc_ns1[0] = 1'b0;
  rvdff #(36)  mdseal_ff (.*, .din({mppc_ns0[31:0], mem_ctl.ic_rd_hit[3:0]}), .dout({mppc0[31:0],ic_rd_hit_f2[3:0]}));
   rvdff #(32)  mdseal1_ff (.*, .din({mppc_ns1[31:0]}), .dout({mppc1[31:0]}));

wire [31:0] i0_pc_wb;
wire [31:0] i1_pc_wb;
   assign i0_pc_wb[0] = 1'b0;
   assign i1_pc_wb[0] = 1'b0;

 rvdff #(62)  e4pc (.*, .din({`DEC.dec_tlu_i0_pc_e4[31:1],`DEC.dec_tlu_i1_pc_e4[31:1]}), .dout({i0_pc_wb[31:1], i1_pc_wb[31:1]}));
   rvdff #(2*(pt.BHT_ADDR_HI-pt.BHT_ADDR_LO+1))  bhtff (.*, .din({bp.bht_rd_addr_f1, bp.bht_rd_addr_p1_f1}), .dout({bht_rd_addr_f2, bht_rd_addr_p1_f2}));

   assign tmp_bnk[1:0] = encode4_2(bp.btb_sel_f2[3:0]);
wire [31:1] flush_path_i0_wb;
wire [31:1] flush_path_i1_wb;
   assign flush_path_i0_wb[31:1] = exu_flush_path_final[`DEC.tlu.i0tid_wb][31:1];
   assign flush_path_i1_wb[31:1] = exu_flush_path_final[`DEC.tlu.i1tid_wb][31:1];

   always @(negedge clk) begin
      if(`DEC.tlu.tlumt[0].tlu.mcyclel[31:0] == 32'h0000_0010) begin
         $display("BTB_CONFIG: %d",pt.BTB_ARRAY_DEPTH*4);
         `ifndef BP_NOGSHARE
         $display("BHT_CONFIG: %d gshare: 1",pt.BHT_ARRAY_DEPTH*4);
         `else
         $display("BHT_CONFIG: %d gshare: 0",pt.BHT_ARRAY_DEPTH*4);
         `endif
         $display("RS_CONFIG: %d", pt.RET_STACK_SIZE);
      end


      mppc_ns0[31:1] = `EXU.i0_flush_upper_e1[0] ? `DEC.decode.i0_pc_e1[31:1] :
                      (`EXU.i1_flush_upper_e1[0] ? `DEC.decode.i1_pc_e1[31:1] :
                       (`EXU.exu_i0_flush_lower_e4[0] ?  `DEC.decode.i0_pc_e4[31:1] :  `DEC.decode.i1_pc_e4[31:1]));


      if(exu_flush_final[0] & ~(dec_tlu_br0_wb_pkt.br_error | dec_tlu_br0_wb_pkt.br_start_error | dec_tlu_br1_wb_pkt.br_error | dec_tlu_br1_wb_pkt.br_start_error) & (exu_mp_pkt[0].misp | exu_mp_pkt[0].ataken))
        $display("%7d BTB_MP[T0]  : index: %0h bank: %0h call: %b ret: %b ataken: %b hist: %h valid: %b tag: %h targ: %h eghr: %b pred: %b ghr_index: %h brpc: %h way: %h",
                 `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha, exu_mp_index[0][pt.BTB_ADDR_HI:pt.BTB_ADDR_LO], exu_mp_pkt[0].bank, exu_mp_pkt[0].pcall, exu_mp_pkt[0].pret,
                 exu_mp_pkt[0].ataken, exu_mp_pkt[0].hist[1:0],
                 exu_mp_pkt[0].misp, exu_mp_btag[0][pt.BTB_BTAG_SIZE-1:0], {exu_flush_path_final[0][31:1], 1'b0}, exu_mp_eghr[0][pt.BHT_GHR_SIZE-1:0], exu_mp_pkt[0].misp,
                 bp.mp_hashed[0], mppc0[31:0], exu_mp_pkt[0].way);
      for(int i = 0; i < 4; i++) begin
         if(ifu_bp_valid_f2[i] & ifc_fetch_req_f2)
           $display("%7d BTB_HIT[T%b] : index: %0h bank: %0h call: %b ret: %b taken: %b strength: %b tag: %h targ: %0h ghr: %4b ghr_index: %h way: %h",
                    `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha, bp.ifc_select_tid_f2, btb_rd_addr_f2[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO],encode4_2(bp.btb_sel_f2[3:0]), bp.btb_rd_call_f2, bp.btb_rd_ret_f2,
                    ifu_bp_hist1_f2[tmp_bnk], ifu_bp_hist0_f2[tmp_bnk], bp.fetch_rd_tag_f2[pt.BTB_BTAG_SIZE-1:0], {ifu_bp_btb_target_f2[31:1], 1'b0},
                    bp.fghr[0][pt.BHT_GHR_SIZE-1:0], use_p1 ? bht_rd_addr_p1_f2 : bht_rd_addr_f2, ifu_bp_way_f2[tmp_bnk]);
      end


         mppc_ns1[31:1] = `EXU.i0_flush_upper_e1[1] ? `DEC.decode.i0_pc_e1[31:1] :
                         (`EXU.i1_flush_upper_e1[1] ? `DEC.decode.i1_pc_e1[31:1] :
                          (`EXU.exu_i0_flush_lower_e4[1] ?  `DEC.decode.i0_pc_e4[31:1] :  `DEC.decode.i1_pc_e4[31:1]));


         if(exu_flush_final[1] & ~(dec_tlu_br0_wb_pkt.br_error | dec_tlu_br0_wb_pkt.br_start_error | dec_tlu_br1_wb_pkt.br_error | dec_tlu_br1_wb_pkt.br_start_error) & (exu_mp_pkt[1].misp | exu_mp_pkt[1].ataken))
           $display("%7d BTB_MP[T1]  : index: %0h bank: %0h call: %b ret: %b ataken: %b hist: %h valid: %b tag: %h targ: %h eghr: %b pred: %b ghr_index: %h brpc: %h way: %h",
                    `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha, exu_mp_index[1][pt.BTB_ADDR_HI:pt.BTB_ADDR_LO], exu_mp_pkt[1].bank, exu_mp_pkt[1].pcall, exu_mp_pkt[1].pret,
                    exu_mp_pkt[1].ataken, exu_mp_pkt[1].hist[1:0],
                    exu_mp_pkt[1].misp, exu_mp_btag[1][pt.BTB_BTAG_SIZE-1:0], {exu_flush_path_final[1][31:1], 1'b0}, exu_mp_eghr[1][pt.BHT_GHR_SIZE-1:0], exu_mp_pkt[1].misp,
                    bp.mp_hashed[1], mppc1[31:0], exu_mp_pkt[1].way);

      if(dec_tlu_br0_wb_pkt.valid & ~(dec_tlu_br0_wb_pkt.br_error | dec_tlu_br0_wb_pkt.br_start_error))
        $display("%7d BTB_UPD0[T%b]: ghr_index: %0h bank: %0h hist: %h  way: %h brpc: %h",
                 `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha,`DEC.tlu.i0tid_wb, bp.br0_hashed_wb[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO],{dec_tlu_br0_wb_pkt.bank,dec_tlu_br0_wb_pkt.middle},
                 dec_tlu_br0_wb_pkt.hist, dec_tlu_br0_wb_pkt.way, i0_pc_wb);
      if(dec_tlu_br1_wb_pkt.valid & ~(dec_tlu_br1_wb_pkt.br_error | dec_tlu_br1_wb_pkt.br_start_error))
        $display("%7d BTB_UPD1[T%b]: ghr_index: %0h bank: %0h hist: %h  way: %h brpc: %h",
                 `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha,`DEC.tlu.i1tid_wb,bp.br1_hashed_wb[pt.BHT_ADDR_HI:pt.BHT_ADDR_LO],{dec_tlu_br1_wb_pkt.bank,dec_tlu_br1_wb_pkt.middle},
                 dec_tlu_br1_wb_pkt.hist, dec_tlu_br1_wb_pkt.way, i1_pc_wb);
      if(dec_tlu_br0_wb_pkt.br_error | dec_tlu_br0_wb_pkt.br_start_error)
        $display("%7d BTB_ERR0[T%b]: index: %0h bank: %0h start: %b rfpc: %h way: %h",
                 `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha,`DEC.tlu.i0tid_wb,dec_tlu_br0_index_wb[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO],dec_tlu_br0_wb_pkt.bank, dec_tlu_br0_wb_pkt.br_start_error,
                 {flush_path_i0_wb, 1'b0}, dec_tlu_br0_wb_pkt.way);
      if(dec_tlu_br1_wb_pkt.br_error | dec_tlu_br1_wb_pkt.br_start_error)
        $display("%7d BTB_ERR1[T%b]: index: %0h bank: %0h start: %b rfpc: %h way: %h",
                 `DEC.tlu.tlumt[0].tlu.mcyclel[31:0]+32'ha,`DEC.tlu.i1tid_wb,dec_tlu_br1_index_wb[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO],dec_tlu_br1_wb_pkt.bank, dec_tlu_br1_wb_pkt.br_start_error,
                 {flush_path_i1_wb, 1'b0}, dec_tlu_br1_wb_pkt.way);
   end       function [1:0] encode4_2;
      input [3:0] in;

      encode4_2[1] = in[3] | in[2];
      encode4_2[0] = in[3] | in[1];

   endfunction
`endif
endmodule 