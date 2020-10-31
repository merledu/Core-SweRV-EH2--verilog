


module eh2_ifu_mem_ctl
 import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
 (
   input wire clk,
   input wire free_clk,                                               input wire active_clk,                                             input wire rst_l,

   input wire [pt.NUM_THREADS-1:0] exu_flush_final,                  input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_lower_wb,           input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_err_wb,             input wire [pt.NUM_THREADS-1:0] dec_tlu_force_halt,            
   input wire [31:1]                fetch_addr_f1,                    input wire fetch_tid_f1,
   input wire ifc_fetch_uncacheable_f1,         input wire ifc_fetch_req_f1,                 input wire ifc_fetch_req_f1_raw,             input wire ifc_iccm_access_f1,               input wire ifc_region_acc_fault_f1,          input wire ifc_dma_access_ok,                input wire [pt.NUM_THREADS-1:0] dec_tlu_fence_i_wb,               input wire ifu_bp_kill_next_f2,              input wire [3:0]               ifu_fetch_val,                    input wire [3:1]               ifu_bp_inst_mask_f2,            
   output logic [pt.NUM_THREADS-1:0] ifu_ic_mb_empty_thr,              output logic                      ic_dma_active  ,                  output logic [pt.NUM_THREADS-1:0] ic_write_stall_thr,            

   output logic [pt.NUM_THREADS-1:0]  ifu_miss_state_idle,             output logic [pt.NUM_THREADS-1:0]  ifu_ic_error_start,              output logic [pt.NUM_THREADS-1:0]  ifu_iccm_rd_ecc_single_err,   
   output logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_miss,                  output logic [pt.NUM_THREADS-1:0] ifu_pmu_ic_hit,                   output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_error,                output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_busy,                 output logic [pt.NUM_THREADS-1:0] ifu_pmu_bus_trxn,              
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


   input wire dma_iccm_req,         input wire [31:0]               dma_mem_addr,         input wire [2:0]                dma_mem_sz,           input wire dma_mem_write,        input wire [63:0]               dma_mem_wdata,        input wire [2:0]                dma_mem_tag,       
   output logic                      iccm_dma_ecc_error,   output logic                      iccm_dma_rvalid,      output logic [63:0]               iccm_dma_rdata,       output logic [2:0]                iccm_dma_rtag,        output logic                      iccm_ready,        

   output logic [31:1]               ic_rw_addr,            output logic [pt.ICACHE_NUM_WAYS-1:0]                ic_wr_en,              output logic                      ic_rd_en,           
   output logic [pt.ICACHE_BANKS_WAY-1:0] [70:0]               ic_wr_data,              input wire [63:0]               ic_rd_data ,             input wire [70:0]               ic_debug_rd_data ,       input wire [25:0]               ictag_debug_rd_data,     output logic [70:0]               ic_debug_wr_data,        output logic [70:0]               ifu_ic_debug_rd_data, 

   input wire [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr,       input wire [pt.ICACHE_BANKS_WAY-1:0] ic_parerr,

   output logic [pt.ICACHE_INDEX_HI:3]               ic_debug_addr,         output logic                      ic_debug_rd_en,        output logic                      ic_debug_wr_en,        output logic                      ic_debug_tag_array,    output logic [pt.ICACHE_NUM_WAYS-1:0]                ic_debug_way,       

   output logic [pt.ICACHE_NUM_WAYS-1:0]                ic_tag_valid,       
   input wire [pt.ICACHE_NUM_WAYS-1:0]                ic_rd_hit,             input wire ic_tag_perr,        
      output logic [pt.ICCM_BITS-1:1]   iccm_rw_addr,          output logic                      iccm_wren,             output logic                      iccm_rden,             output logic [77:0]               iccm_wr_data,          output logic [2:0]                iccm_wr_size,       
   input wire [63:0]               iccm_rd_data,          input wire [116:0]              iccm_rd_data_ecc,   
      output logic                      ic_hit_f2,                 output logic [pt.NUM_THREADS-1:0] ic_crit_wd_rdy_thr,        output logic                      ic_access_fault_f2,        output logic  [1:0]               ic_access_fault_type_f2,   output logic                      iccm_rd_ecc_single_err,    output logic                      iccm_rd_ecc_double_err,    output logic [pt.NUM_THREADS-1:0] ifu_async_error_start,     output logic                      iccm_dma_sb_error,      
   output logic [3:0]                ic_fetch_val_f2,           output logic [63:0]               ic_data_f2,                output logic                      fetch_tid_f2,

   output logic [63:0]               ic_premux_data,            output logic                      ic_sel_premux_data,     
   input  eh2_cache_debug_pkt_t     dec_tlu_ic_diag_pkt ,          input wire [pt.NUM_THREADS-1:0] dec_tlu_i0_commit_cmt,
   input wire dec_tlu_core_ecc_disable,      output logic                      ifu_ic_debug_rd_data_valid,    output logic [pt.NUM_THREADS-1:0] iccm_buf_correct_ecc_thr,
   output logic                      iccm_correction_state,
   output logic                      iccm_stop_fetch,
   output logic                      iccm_corr_scnd_fetch,
   input wire scan_mode
   );


 localparam   NUM_OF_BEATS = 8 ;



   wire [31:3]    ifu_ic_req_addr_f2;
   wire           bus_ifu_wr_en_ff_q  ;
   wire           bus_ifu_wr_en_ff_wo_err  ;

   wire [pt.ICACHE_NUM_WAYS-1:0]     bus_ic_wr_en ;

   wire           reset_tag_valid_for_miss  ;



   wire [pt.ICACHE_STATUS_BITS-1:0]             way_status_hit_new;
   wire [pt.ICACHE_STATUS_BITS-1:0]             way_status_wr_w_debug;
   wire                                         ifc_dma_access_q_ok;
   reg                                         ifc_iccm_access_f2 ;
   wire                                         ifc_bus_acc_fault_f2;
   wire                                         fetch_req_f2_qual   ;
   wire                                         ic_valid ;
   reg                                         ic_valid_ff;
   wire                                         ic_valid_w_debug;
wire [pt.ICACHE_NUM_WAYS-1:0] ifu_tag_wren;
reg [pt.ICACHE_NUM_WAYS-1:0] ifu_tag_wren_ff;
reg [pt.ICACHE_NUM_WAYS-1:0] ifu_tag_miss_wren;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 ic_debug_tag_wr_en;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 ifu_tag_wren_w_debug;
   wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]              ifu_ic_rw_int_addr_w_debug ;
   wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]              ifu_status_wr_addr_w_debug ;
   reg [pt.ICACHE_NUM_WAYS-1:0]                                 ic_debug_way_ff;
   reg                                                          ic_debug_rd_en_ff   ;
   wire                                                          debug_c1_clken;
   wire                                                          debug_c1_clk;
   wire [pt.ICACHE_BEAT_ADDR_HI:1]                               vaddr_f2 ;
   wire [127:0]                                                  ic_final_data;
   reg [pt.ICACHE_STATUS_BITS-1:0]                              way_status_wr_ff ;
   reg [pt.ICACHE_STATUS_BITS-1:0]                              way_status_up_ff ;
   reg                                                          way_status_wr_en_ff ;
   reg [pt.ICACHE_TAG_DEPTH-1:0][pt.ICACHE_STATUS_BITS-1:0]     way_status_out ;
   wire [1:0]                                                    ic_debug_way_enc;
   wire [63:0]                                                   ic_rd_data_only;
   wire                                                          way_status_up_en;
   wire                                                          way_status_wr_en;
   wire                                                          sel_byp_data;
   wire                                                          sel_ic_data;
   reg                                                          sel_ic_data_ff;
   wire                                                          sel_iccm_data;
   wire                                                          ic_rd_parity_final_err;
   wire                                                          way_status_wr_en_w_debug;
   wire                                                          ic_debug_tag_val_rd_out;
   wire                                                          ic_debug_ict_array_sel_in;
   reg                                                          ic_debug_ict_array_sel_ff;
   wire                                                          debug_data_clk;
   wire                                                          debug_data_clken;
   reg                                                          ifu_bus_rvalid_unq_ff    ;
   reg                                                          ifu_bus_arready_unq_ff    ;
   wire                                                          ifu_bus_arready_unq       ;
   reg [63:0]                                                   ifu_bus_rdata_ff        ;
   wire [pt.ICCM_BITS-1:2]                                       iccm_ecc_corr_index_ff;
   wire [pt.ICCM_BITS-1:2]                                       iccm_ecc_corr_index_in;
   wire [38:0]                                                   iccm_ecc_corr_data_ff;
   wire                                                          dma_sb_err_state;
   reg                                                          dma_sb_err_state_ff;
   wire                                                          iccm_rd_ecc_single_err_ff   ;
   reg                                                          busclk;
   reg                                                          bus_ifu_bus_clk_en_ff;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 bus_wren            ;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 bus_wren_last       ;
   reg [pt.ICACHE_NUM_WAYS-1:0]                                 wren_reset_miss      ;
   wire                                                          ifc_dma_access_ok_d;
   reg                                                          ifc_dma_access_ok_prev;
   wire                                                          ifc_region_acc_fault_memory;
   wire                                                          ifc_region_acc_okay;
   reg                                                          ifc_region_acc_fault_memory_f2;
   reg  [pt.NUM_THREADS-1:0]                                    flush_final_f2;


   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status;
   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status_rep_new;
   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status_wr;
   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status_up;
   reg                                                          ifc_region_acc_fault_f2;
   reg                                                          ifc_region_acc_fault_only_f2;
   reg  [31:1]                                                  ifu_fetch_addr_int_f2 ;
   wire                                                          reset_all_tags;
   reg                                                          reset_all_tags_ff;
   reg [pt.IFU_BUS_TAG-1:0]                                     ifu_bus_rid_ff;
   wire                                                          fetch_req_icache_f2;
   wire                                                          fetch_req_iccm_f2;
   reg                                                          fetch_uncacheable_ff;
   wire                                                          ifu_bus_rvalid           ;
   wire                                                          ifu_bus_rvalid_ff        ;
   reg                                                          ifu_bus_arvalid_ff        ;
   wire                                                          ifu_bus_arvalid           ;
   reg                                                          ifu_bus_miss_thr_ff ;
   wire                                                          ifu_bus_arready_ff        ;
   wire                                                          ifu_bus_arready           ;
   reg [1:0]                                                    ifu_bus_rresp_ff          ;
   wire                                                          ifu_bus_rsp_valid ;
   wire                                                          ifu_bus_rsp_ready ;
   wire [pt.IFU_BUS_TAG-1:0]                                     ifu_bus_rsp_tag;
   wire [63:0]                                                   ifu_bus_rsp_rdata;
   wire [1:0]                                                    ifu_bus_rsp_opc;
   wire                                                          ifu_bus_rsp_tid;
   wire                                                          iccm_error_start;        wire                                                          bus_ifu_bus_clk_en ;
   wire                                                          ifu_bus_cmd_valid ;
   wire                                                          ifu_bus_cmd_ready ;
   wire                                                          ifc_region_acc_fault_final_f1;
   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status_mb_wr_ff;
   wire  [pt.ICACHE_STATUS_BITS-1:0]                             way_status_mb_ms_ff;
   wire  [pt.ICACHE_NUM_WAYS-1:0]                                tagv_mb_wr_ff;
   wire  [pt.ICACHE_NUM_WAYS-1:0]                                tagv_mb_ms_ff;
   wire                                                          ifu_byp_data_err_new;
   wire                                                          ifu_wr_cumulative_err_data;
   wire                                                          ic_act_miss_f2;
   wire                                                          ic_act_hit_f2;
   wire                                                          ic_act_hit_f2_ff;
   wire                                                          ifc_fetch_req_f2;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 replace_way_mb_wr_any;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                 replace_way_mb_ms_any;
   wire                                                          last_beat;
   wire [31:1]                                                   ifu_ic_rw_int_addr ;
   wire [79:0]                                                   ic_byp_data_only_new;
   wire                                                          ic_byp_hit_f2 ;
   reg [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]              ifu_ic_rw_int_addr_ff ;
   reg [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]              ifu_status_wr_addr_ff ;
   reg [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]              ifu_status_up_addr_ff ;
   wire                                                          reset_ic_in ;
   wire                                                          reset_ic_ff ;
   wire [31:1]                                                   ifu_status_up_addr;
   wire [31:1]                                                   ifu_status_wr_addr;
   wire                                                          iccm_correct_ecc     ;
   wire                                                          bus_cmd_sent           ;
   wire                                                          bus_last_data_beat     ;
   wire                                                          miss_pending     ;
   wire [31:0]                                                   iccm_corrected_data_f2_mux;
   wire [06:0]                                                   iccm_corrected_ecc_f2_mux;


   wire  [63:0]                                                  ic_miss_buff_half;

   reg [pt.NUM_THREADS-1:0]                                     scnd_miss_req_ff2_thr;
   reg [pt.NUM_THREADS-1:0]                                     scnd_miss_req_thr;
   reg [pt.NUM_THREADS-1:0]                                     perr_state_wff_thr;
   wire [1:0]                                                    scnd_miss_req_other_thr;
   wire                                                          ic_write_stall;

   wire selected_miss_thr ;
   reg selected_miss_thr_tmp ;
   wire bus_thread_en;
   reg rsp_tid_ff ;
   wire flush_ic_err_tid ;
   reg fetch_tid_f2_p1;        reg fetch_tid_f2_p2;     
   wire [2:0]                    iccm_ecc_word_enable;
   wire                          reset_all_tags_in ;
   wire [pt.ICACHE_NUM_WAYS-1:0] ic_tag_valid_unq;
   reg [pt.NUM_THREADS-1:0]     ic_act_miss_f2_thr;
   reg [pt.NUM_THREADS-1:0]     ic_act_hit_f2_thr;
   wire [pt.NUM_THREADS-1:0]     ifc_bus_acc_fault_f2_thr;
   reg [pt.NUM_THREADS-1:0]     bus_cmd_sent_thr;
   reg [pt.NUM_THREADS-1:0]     miss_pending_thr;
   wire [pt.NUM_THREADS-1:0]     ifu_pmu_ic_miss_in;                  wire [pt.NUM_THREADS-1:0]     ifu_pmu_ic_hit_in;                   wire [pt.NUM_THREADS-1:0]     ifu_pmu_bus_error_in;                wire [pt.NUM_THREADS-1:0]     ifu_pmu_bus_busy_in;                 wire [pt.NUM_THREADS-1:0]     ifu_pmu_bus_trxn_in;              
   wire [pt.NUM_THREADS-1:0] fetch_tid_dec_f1 ;
   wire [pt.NUM_THREADS-1:0] fetch_tid_dec_f2 ;

   reg [pt.NUM_THREADS-1:0]                                             ic_dma_active_thr;
   reg [pt.NUM_THREADS-1:0]                                             iccm_stop_fetch_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_write_stall_self_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_write_stall_other_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_rd_en_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_real_rd_wp_thr;
   reg [pt.NUM_THREADS-1:0]                                             ifu_miss_state_idle_thr;
   reg [pt.NUM_THREADS-1:0]                                             ifu_miss_state_pre_crit_ff_thr;
   wire [pt.NUM_THREADS-1:0] [pt.ICACHE_NUM_WAYS-1:0]                    ic_wr_en_thr;
   wire [pt.NUM_THREADS-1:0] [31:3]                                      ifu_ic_req_addr_f2_thr;
   reg [pt.NUM_THREADS-1:0]                                             reset_tag_valid_for_miss_thr;
   wire [pt.NUM_THREADS-1:0]  [63:0]                                     ic_miss_buff_half_thr;
   reg [pt.NUM_THREADS-1:0]                                             sel_byp_data_thr;
   reg [pt.NUM_THREADS-1:0]                                             sel_ic_data_thr;
   wire [pt.NUM_THREADS-1:0] [pt.ICACHE_BEAT_BITS-1:0]                   bus_new_rd_addr_count_thr;
   wire [pt.NUM_THREADS-1:0] [pt.ICACHE_BEAT_BITS-1:0]                   bus_rd_addr_count_thr;
   wire [pt.NUM_THREADS-1:0] [pt.ICACHE_NUM_WAYS-1:0]                    perr_err_inv_way_thr;
   wire [pt.NUM_THREADS-1:0] [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] perr_ic_index_ff_thr;
   reg [pt.NUM_THREADS-1:0]                                             perr_sel_invalidate_thr;
   reg [pt.NUM_THREADS-1:0]                                             bus_ifu_wr_en_ff_q_thr;
   reg [pt.NUM_THREADS-1:0]                                             bus_ifu_wr_en_ff_wo_err_thr;
   reg [pt.NUM_THREADS-1:0]                                             iccm_correction_state_thr;
   reg [pt.NUM_THREADS-1:0]                                             iccm_corr_scnd_fetch_thr;

   eh2_perr_state_t     [pt.NUM_THREADS-1:0]                             perr_state_thr;
   eh2_err_stop_state_t [pt.NUM_THREADS-1:0]                              err_stop_state_thr;
   eh2_err_stop_state_t [pt.NUM_THREADS-1:0]                              err_stop_state_thr_ff;
   reg [pt.NUM_THREADS-1:0]                                             perr_state_idle_thr;


   wire [pt.NUM_THREADS-1:0]  [pt.ICACHE_STATUS_BITS-1:0]                way_status_mb_ff_thr;
   wire [pt.NUM_THREADS-1:0]  [pt.ICACHE_NUM_WAYS-1:0]                   tagv_mb_ff_thr;
   reg [pt.NUM_THREADS-1:0]                                             ifu_byp_data_err_new_thr;
   reg [pt.NUM_THREADS-1:0]                                             ifu_wr_cumulative_err_data_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_act_hit_f2_ff_thr;
   reg [pt.NUM_THREADS-1:0]                                             fetch_f1_f2_c1_clk_thr;
   reg [pt.NUM_THREADS-1:0]                                             ifc_fetch_req_f2_thr;
   reg [pt.NUM_THREADS-1:0]                                             last_beat_thr;
   wire [pt.NUM_THREADS-1:0] [31:1]                                      ifu_ic_rw_int_addr_thr;
   wire [pt.NUM_THREADS-1:0] [79:0]                                      ic_byp_data_only_new_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_byp_hit_f2_thr;
   reg [pt.NUM_THREADS-1:0]                                             reset_ic_in_thr;
   reg [pt.NUM_THREADS-1:0]                                             reset_ic_ff_thr;
   wire [pt.NUM_THREADS-1:0] [31:1]                                      ifu_status_up_addr_thr;
   wire [pt.NUM_THREADS-1:0] [31:1]                                      ifu_status_wr_addr_thr;
   reg [pt.NUM_THREADS-1:0]                                             iccm_correct_ecc_thr;
   reg [pt.NUM_THREADS-1:0]                                             bus_last_data_beat_thr;
   reg [pt.NUM_THREADS-1:0]                                             ic_hit_f2_thr;
   wire [pt.NUM_THREADS-1:0]                                             ifu_bus_cmd_valid_thr;
   reg [pt.NUM_THREADS-1:0]                                             miss_done_thr;
   reg [pt.NUM_THREADS-1:0]                                             address_match_thr;
   wire [pt.NUM_THREADS-1:0] [31:1]                                      miss_address_thr;

   wire [1:0]                miss_done_other;
   wire [1:0]                address_match_other;
   wire [1:0] [31:1]         miss_address_other;

   wire [1:0]                ifu_bus_cmd_valid_thr_in ;
   reg [pt.NUM_THREADS-1:0] selected_miss_thr_ff;
wire [1:0] selected_miss_thr_in;
wire [1:0] rsp_miss_thr;
   wire                       arbitter_toggle_en;
   wire                      ic_wr_tid_ff;
   wire                       ic_reset_tid;

   wire [pt.NUM_THREADS-1:0] [pt.ICCM_BITS-1:2]                          iccm_ecc_corr_index_ff_thr;
   wire [pt.NUM_THREADS-1:0] [38:0]                                      iccm_ecc_corr_data_ff_thr;
   reg [pt.NUM_THREADS-1:0]                                             dma_sb_err_state_thr;
   wire                      flush_err_tid0_wb;
   reg                      flush_err_tid0_wb1;
   reg                      flush_err_tid0_wb2;
   wire                      select_t0_iccm_corr_index;

   wire        perr_state_idle;

      eh2_err_stop_state_t err_stop_state;
   wire [pt.ICACHE_BEAT_BITS-1:0]                     bus_rd_addr_count ;
   wire [pt.ICACHE_NUM_WAYS-1:0]                      perr_err_inv_way;
   wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   perr_ic_index_ff;
   wire                                               perr_sel_invalidate;
   wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   ifu_tag_miss_addr_f2_p1;            wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   ifu_tag_miss_addr_f2_p2;         
   wire [2:0]    iccm_single_ecc_error;
   reg          dma_iccm_req_f2 ;

   reg ic_rd_en_ff ;
   wire tag_err_qual_in ;
   wire tag_err_qual ;

   wire two_byte_instr_f2;
   reg iccm_dma_active;
   reg way_status_up_en_ff;



rvdff #(1) fetch_tid_f2_ff0 (.*,.clk(free_clk),
                               .din ( fetch_tid_f1 ),
                               .dout( fetch_tid_f2 ));

rvdff #(1) fetch_tid_f2_ff1 (.*,.clk(free_clk),
                               .din ( fetch_tid_f2 ),
                               .dout( fetch_tid_f2_p1 ));


rvdff #(1) fetch_tid_f2_ff2 (.*,.clk(free_clk),
                               .din ( fetch_tid_f2_p1 ),
                               .dout( fetch_tid_f2_p2 ));


rvdff #(1) rsp_tid__flop (.*,.clk(free_clk),
                               .din ( ifu_bus_rsp_tid ),
                    //           .din ( fetch_tid_f1 ),
                               .dout( rsp_tid_ff ));


   eh2_perr_state_t perr_state;


   assign debug_c1_clken        = ic_debug_rd_en | ic_debug_wr_en ;


   assign iccm_dma_sb_error  = (|iccm_single_ecc_error[2:0] )  & dma_iccm_req_f2 ;
  if (pt.NUM_THREADS > 1) begin: more_than_1
   assign ifu_async_error_start[0]                 =  (iccm_rd_ecc_single_err & ~fetch_tid_f2) | ((|ifu_ic_error_start) & ~fetch_tid_f2_p1) ;
   assign ifu_async_error_start[pt.NUM_THREADS-1]  =  (iccm_rd_ecc_single_err &  fetch_tid_f2) | ((|ifu_ic_error_start) &  fetch_tid_f2_p1) ;
  end
  else begin: one_th
   assign ifu_async_error_start[pt.NUM_THREADS-1]  =  (iccm_rd_ecc_single_err &  ~fetch_tid_f2) | ((|ifu_ic_error_start) &  ~fetch_tid_f2_p1) ;
 end



         

   assign fetch_req_icache_f2   = ifc_fetch_req_f2 & ~ifc_iccm_access_f2 & ~ifc_region_acc_fault_f2;
   assign fetch_req_iccm_f2     = ifc_fetch_req_f2 &  ifc_iccm_access_f2;




   rvdff #(1)  uncache_ff (.*, .clk(active_clk), .din (ifc_fetch_uncacheable_f1), .dout(fetch_uncacheable_ff));
   rvdff #(31) ifu_fetch_addr_f2_ff (.*,
                    .clk (active_clk),
                    .din ({fetch_addr_f1[31:1]}),
                    .dout({ifu_fetch_addr_int_f2[31:1]}));

   assign vaddr_f2[pt.ICACHE_BEAT_ADDR_HI:1] = ifu_fetch_addr_int_f2[pt.ICACHE_BEAT_ADDR_HI:1] ;


   rvdff #(1) ifu_iccm_acc_ff     (.*, .clk(active_clk), .din(ifc_iccm_access_f1),      .dout(ifc_iccm_access_f2));

   rvdff #(1) ifu_iccm_reg_acc_ff (.*, .clk(active_clk), .din(ifc_region_acc_fault_final_f1), .dout(ifc_region_acc_fault_f2));

   rvdff #(1) ifu_iccm_reg_acc_only_ff (.*, .clk(active_clk), .din(ifc_region_acc_fault_f1), .dout(ifc_region_acc_fault_only_f2));






  assign ic_rw_addr[31:1]      = ifu_ic_rw_int_addr[31:1] ;


if (pt.ICACHE_ECC == 1) begin: icache_ecc_1
   reg [6:0]       ic_wr_ecc;
   reg [6:0]       ic_miss_buff_ecc;
   wire [141:0]     ic_wr_16bytes_data ;
   wire [70:0]      ifu_ic_debug_rd_data_in   ;

                rvecc_encode_64  ic_ecc_encode_64_bus (
                           .din    (ifu_bus_rdata_ff[63:0]),
                           .ecc_out(ic_wr_ecc[6:0]));
                rvecc_encode_64  ic_ecc_encode_64_buff (
                           .din    (ic_miss_buff_half[63:0]),
                           .ecc_out(ic_miss_buff_ecc[6:0]));

   assign ic_rd_data_only[63:0]= {ic_rd_data[63:0]} ;
   for (genvar i=0; i < pt.ICACHE_BANKS_WAY ; i++) begin : ic_wr_data_loop
      assign ic_wr_data[i][70:0]  =  ic_wr_16bytes_data[((71*i)+70): (71*i)];
   end


   assign ic_debug_wr_data[70:0]   = {dec_tlu_ic_diag_pkt.icache_wrdata[70:0]} ;
  rvdff #(($bits(eh2_err_stop_state_t))*(pt.NUM_THREADS)) err_stop_stateff (.*, .clk (free_clk),
                    .din ( err_stop_state_thr ),
                    .dout( err_stop_state_thr_ff ));



  if (pt.NUM_THREADS > 1) begin: more_than_1_th
    assign ifu_ic_error_start[pt.NUM_THREADS-1:0]           = {((((|ic_eccerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff )  | ic_rd_parity_final_err) & ~exu_flush_final[1] & fetch_tid_f2_p1 &  ~perr_state_wff_thr[1] & ~(err_stop_state_thr_ff[1] == 2'b11)) ,
                                                               ((((|ic_eccerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff)  | ic_rd_parity_final_err) & ~exu_flush_final[0] & ~fetch_tid_f2_p1 &  ~perr_state_wff_thr[0] & ~(err_stop_state_thr_ff[0] == 2'b11))};
  end  else begin: one_thr
assign ifu_ic_error_start[pt.NUM_THREADS-1:0]           = {((((|ic_eccerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff)  | ic_rd_parity_final_err) ) & ~exu_flush_final[0] & ~perr_state_wff_thr[pt.NUM_THREADS-1:0] & ~(err_stop_state_thr_ff[pt.NUM_THREADS-1] == 2'b11)}   ;
  end


  assign ifu_ic_debug_rd_data_in[70:0] = ic_debug_ict_array_sel_ff ? {2'b0,ictag_debug_rd_data[25:21],32'b0,ictag_debug_rd_data[20:0],{7-pt.ICACHE_STATUS_BITS{1'b0}}, way_status[pt.ICACHE_STATUS_BITS-1:0],3'b0,ic_debug_tag_val_rd_out} :
                                                                     ic_debug_rd_data[70:0];

  rvdff #(71) ifu_debug_data_ff (.*, .clk (debug_data_clk),
                    .din ({
                           ifu_ic_debug_rd_data_in[70:0]
                          }),
                    .dout({
                           ifu_ic_debug_rd_data[70:0]
                           }));

  assign ic_wr_16bytes_data[141:0] =  ifu_bus_rid_ff[0] ? {ic_wr_ecc[6:0] , ifu_bus_rdata_ff[63:0] ,  ic_miss_buff_ecc[6:0] , ic_miss_buff_half[63:0] } :
                                                        {ic_miss_buff_ecc[6:0] ,  ic_miss_buff_half[63:0] , ic_wr_ecc[6:0] , ifu_bus_rdata_ff[63:0] } ;


end
else begin : icache_parity_1
  reg [3:0]   ic_wr_parity;
   reg [3:0]   ic_miss_buff_parity;
   wire [135:0] ic_wr_16bytes_data ;
   wire [70:0]  ifu_ic_debug_rd_data_in   ;
    for (genvar i=0 ; i < 4 ; i++) begin : DATA_PGEN
       rveven_paritygen #(16) par_bus  (.data_in   (ifu_bus_rdata_ff[((16*i)+15):(16*i)]),
                                      .parity_out(ic_wr_parity[i]));
       rveven_paritygen #(16) par_buff  (.data_in   (ic_miss_buff_half[((16*i)+15):(16*i)]),
                                      .parity_out(ic_miss_buff_parity[i]));
    end

   assign ic_rd_data_only[63:0]  = {ic_rd_data[63:0]} ;

   for (genvar i=0; i < pt.ICACHE_BANKS_WAY ; i++) begin : ic_wr_data_loop
      assign ic_wr_data[i][67:0]  =  ic_wr_16bytes_data[((68*i)+67): (68*i)];
   end





   assign ic_debug_wr_data[70:0]   = {dec_tlu_ic_diag_pkt.icache_wrdata[70:0]} ;

    if (pt.NUM_THREADS > 1) begin: more_than_1_th
      assign ifu_ic_error_start[pt.NUM_THREADS-1:0]           = {((((|ic_parerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff)  | ic_rd_parity_final_err) &  fetch_tid_f2_p1) ,
                                                                 ((((|ic_parerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff)  | ic_rd_parity_final_err) & ~fetch_tid_f2_p1)};
    end  else begin: one_thr
      assign ifu_ic_error_start[pt.NUM_THREADS-1:0]           = {((((|ic_parerr[pt.ICACHE_BANKS_WAY-1:0]) & ic_act_hit_f2_ff)  | ic_rd_parity_final_err) ) }   ;
    end

   assign ifu_ic_debug_rd_data_in[70:0] = ic_debug_ict_array_sel_ff ? {6'b0,ictag_debug_rd_data[21],32'b0,ictag_debug_rd_data[20:0],{7-pt.ICACHE_STATUS_BITS{1'b0}},way_status[pt.ICACHE_STATUS_BITS-1:0],3'b0,ic_debug_tag_val_rd_out} :
                                                                      ic_debug_rd_data[70:0] ;
   rvdff #(71) ifu_debug_data_ff (.*, .clk (debug_data_clk),
                    .din ({
                           ifu_ic_debug_rd_data_in[70:0]
                          }),
                    .dout({
                           ifu_ic_debug_rd_data[70:0]
                           }));


   assign ic_wr_16bytes_data[135:0] =  ifu_bus_rid_ff[0] ? {ic_wr_parity[3:0] , ifu_bus_rdata_ff[63:0] ,  ic_miss_buff_parity[3:0] , ic_miss_buff_half[63:0] } :
                                                        {ic_miss_buff_parity[3:0] ,  ic_miss_buff_half[63:0] , ic_wr_parity[3:0] , ifu_bus_rdata_ff[63:0] } ;

end

  rvdff #(1) sel_ic_ff (.*, .clk(free_clk), .din({sel_ic_data}), .dout({sel_ic_data_ff}));



 if (pt.ICCM_ICACHE==1) begin: iccm_icache
  assign sel_iccm_data    =  fetch_req_iccm_f2  ;

  assign ic_final_data[63:0]  = ({64{sel_byp_data | sel_iccm_data | sel_ic_data}} & {ic_rd_data_only[63:0]} ) ;

  assign ic_premux_data[63:0] = ({64{sel_byp_data }} & ic_byp_data_only_new[63:0]) |
                                ({64{sel_iccm_data}} & iccm_rd_data[63:0]);

  assign ic_sel_premux_data = sel_iccm_data | sel_byp_data ;
 end

if (pt.ICCM_ONLY == 1 ) begin: iccm_only
  assign sel_iccm_data    =  fetch_req_iccm_f2  ;
  assign ic_final_data[63:0]  = ({64{sel_byp_data }} & {ic_byp_data_only_new[63:0]} ) |
                                ({64{sel_iccm_data}} & {7'b0,iccm_rd_data[63:39],iccm_rd_data[31:0]});
  assign ic_premux_data = 'd0 ;
  assign ic_sel_premux_data = 'd0 ;
end

if (pt.ICACHE_ONLY == 1 ) begin: icache_only
  assign ic_final_data[63:0]  = ({64{sel_byp_data | sel_ic_data}} & {ic_rd_data_only[63:0]} ) ;
  assign ic_premux_data[63:0] = ({64{sel_byp_data }} & {ic_byp_data_only_new[63:0]} ) ;
  assign ic_sel_premux_data =  sel_byp_data ;
end


if (pt.NO_ICCM_NO_ICACHE == 1 ) begin: no_iccm_no_icache
  assign ic_final_data[63:0]  = ({64{sel_byp_data }} & {ic_byp_data_only_new[63:0]} ) ;
  assign ic_premux_data = 0 ;
  assign ic_sel_premux_data = 'd0 ;
end

  assign ifc_bus_acc_fault_f2   =  ic_byp_hit_f2 & ifu_byp_data_err_new ;
  assign ic_data_f2[63:0]       = ic_final_data[63:0];

rvdff #(pt.NUM_THREADS) flush_final_ff (.*, .clk(free_clk), .din({exu_flush_final}), .dout({flush_final_f2}));

assign fetch_req_f2_qual       = ic_hit_f2 & ~exu_flush_final[fetch_tid_f2];
assign ic_access_fault_f2  = (ifc_region_acc_fault_f2 | ifc_bus_acc_fault_f2)  & ~exu_flush_final[fetch_tid_f2];
assign ic_access_fault_type_f2[1:0] = iccm_rd_ecc_double_err         ? 2'b01 :
                                      ifc_region_acc_fault_only_f2   ? 2'b10 :
                                      ifc_region_acc_fault_memory_f2 ? 2'b11 :  2'b00 ;


assign ic_fetch_val_f2[3] = fetch_req_f2_qual & ifu_bp_inst_mask_f2[3] & ~((vaddr_f2[pt.ICACHE_BEAT_ADDR_HI:3] == {pt.ICACHE_BEAT_ADDR_HI-2{1'b1}}) & (vaddr_f2[2:1] != 2'b00)) & (err_stop_state == ERR_STOP_IDLE);
assign ic_fetch_val_f2[2] = fetch_req_f2_qual & ifu_bp_inst_mask_f2[2] & ~(vaddr_f2[pt.ICACHE_BEAT_ADDR_HI:2]  == {pt.ICACHE_BEAT_ADDR_HI-1{1'b1}}) & (err_stop_state == ERR_STOP_IDLE);
assign ic_fetch_val_f2[1] = fetch_req_f2_qual & ifu_bp_inst_mask_f2[1] & ~(vaddr_f2[pt.ICACHE_BEAT_ADDR_HI:1]  == {pt.ICACHE_BEAT_ADDR_HI{1'b1}})   & ((err_stop_state == ERR_STOP_IDLE) | (err_stop_state == ERR_FETCH1)) ;
assign ic_fetch_val_f2[0] = fetch_req_f2_qual & (err_stop_state != ERR_STOP_FETCH);

assign two_byte_instr_f2    =  (ic_data_f2[1:0] != 2'b11 )  ;

assign ic_rd_parity_final_err = ic_tag_perr & sel_ic_data_ff  & tag_err_qual  ;

assign tag_err_qual_in = ic_rd_en_ff & ifc_fetch_req_f2  & ~(ifc_region_acc_fault_memory_f2 | ifc_region_acc_fault_only_f2) ;
assign bus_ifu_bus_clk_en =  ifu_bus_clk_en ;
   rvclkhdr bus_clk(.en(bus_ifu_bus_clk_en),
                   .l1clk(busclk), .*);

   rvdff #(1)           bus_clken_ff     (.*, .clk(free_clk), .din(bus_ifu_bus_clk_en), .dout(bus_ifu_bus_clk_en_ff));
   rvdff #(1)           ic_rd_enff       (.*, .clk(free_clk), .din(ic_rd_en), .dout(ic_rd_en_ff));
   rvdff #(1)           tag_errq         (.*, .clk(free_clk), .din(tag_err_qual_in), .dout(tag_err_qual));




            assign ifu_axi_arvalid               =  ifu_bus_cmd_valid ;
    assign ifu_axi_arid[pt.IFU_BUS_TAG-1:0] = (pt.ICACHE_BEAT_BITS == 2) ?  ((pt.IFU_BUS_TAG)'({selected_miss_thr,1'b0, bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0]})) & ({pt.IFU_BUS_TAG{ifu_bus_cmd_valid}}):
                                                                            ((pt.IFU_BUS_TAG)'({selected_miss_thr,bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0]})) & ({pt.IFU_BUS_TAG{ifu_bus_cmd_valid}});
    assign ifu_axi_araddr[31:0]          =   {ifu_ic_req_addr_f2[31:3],3'b0} & {32{ifu_bus_cmd_valid}} ;
    assign ifu_axi_arsize[2:0]           =  3'b011;
    assign ifu_axi_arprot[2:0]           = 0;
    assign ifu_axi_arcache[3:0]          = 15;
    assign ifu_axi_arregion[3:0]         = ifu_ic_req_addr_f2[31:28];
    assign ifu_axi_arlen[7:0]            = '0;
    assign ifu_axi_arburst[1:0]          = 2'b01;
    assign ifu_axi_arqos[3:0]            = '0;
    assign ifu_axi_arlock                = '0;
    assign ifu_axi_rready                = 1'b1;

        assign ifu_axi_awvalid                  = 'd0 ;
    assign ifu_axi_awid[pt.IFU_BUS_TAG-1:0] = 'd0 ;
    assign ifu_axi_awaddr[31:0]             = 'd0 ;
    assign ifu_axi_awsize[2:0]              = 'd0 ;
    assign ifu_axi_awprot[2:0]              = '0;
    assign ifu_axi_awcache[3:0]             = 'd0 ;
    assign ifu_axi_awregion[3:0]            = 'd0 ;
    assign ifu_axi_awlen[7:0]               = '0;
    assign ifu_axi_awburst[1:0]             = 'd0 ;
    assign ifu_axi_awqos[3:0]               = '0;
    assign ifu_axi_awlock                   = '0;

    assign ifu_axi_wvalid                =  '0;
    assign ifu_axi_wstrb[7:0]            =  '0;
    assign ifu_axi_wdata[63:0]           =  '0;
    assign ifu_axi_wlast                 =  '0;
    assign ifu_axi_bready                =  '0;



   assign ifu_bus_arready_unq       =   ifu_axi_arready ;
   assign ifu_bus_arvalid           =   ifu_axi_arvalid ;
   rvdff #(1)               bus_rdy_ff      (.*, .clk(busclk), .din(ifu_bus_arready_unq),            .dout(ifu_bus_arready_unq_ff));
   rvdff #(1)               bus_rsp_vld_ff  (.*, .clk(busclk), .din(ifu_axi_rvalid),                 .dout(ifu_bus_rvalid_unq_ff));
   rvdff #(1)               bus_cmd_ff      (.*, .clk(busclk), .din(ifu_bus_arvalid),                .dout(ifu_bus_arvalid_ff));
   rvdff #(2)               bus_rsp_cmd_ff  (.*, .clk(busclk), .din(ifu_axi_rresp[1:0]),             .dout(ifu_bus_rresp_ff[1:0]));
   rvdff #(64)              bus_data_ff     (.*, .clk(busclk), .din(ifu_axi_rdata[63:0]),            .dout(ifu_bus_rdata_ff[63:0]));
   rvdff #(pt.IFU_BUS_TAG)  bus_rsp_tag_ff  (.*, .clk(busclk), .din(ifu_axi_rid[pt.IFU_BUS_TAG-1:0]),.dout(ifu_bus_rid_ff[pt.IFU_BUS_TAG-1:0]));


   assign ifu_bus_cmd_ready = ifu_axi_arready ;
   assign ifu_bus_rsp_valid = ifu_axi_rvalid ;
   assign ifu_bus_rsp_ready = ifu_axi_rready ;
   assign ifu_bus_rsp_tag[pt.IFU_BUS_TAG-1:0] = ifu_axi_rid[pt.IFU_BUS_TAG-1:0] ;
   assign ifu_bus_rsp_rdata[63:0] = ifu_axi_rdata[63:0] ;
   assign ifu_bus_rsp_opc[1:0] = {ifu_axi_rresp[1:0]} ;
   assign ifu_bus_rsp_tid  = ifu_bus_rsp_tag[pt.IFU_BUS_TAG-1] & ifu_bus_rsp_valid;



   assign ifu_bus_rvalid            =  ifu_bus_rsp_valid       & bus_ifu_bus_clk_en ;

   assign ifu_bus_arready_ff         =  ifu_bus_arready_unq_ff & bus_ifu_bus_clk_en_ff ;
   assign ifu_bus_arready            =  ifu_bus_arready_unq    & bus_ifu_bus_clk_en    ;

   assign ifu_bus_rvalid_ff          =  ifu_bus_rvalid_unq_ff  & bus_ifu_bus_clk_en_ff ;

      assign ifc_dma_access_ok_d  = ifc_dma_access_ok &  ~iccm_correct_ecc & ~iccm_dma_sb_error;
   assign ifc_dma_access_q_ok  = ifc_dma_access_ok &  ~iccm_correct_ecc & ifc_dma_access_ok_prev &  perr_state_idle  & ~iccm_dma_sb_error;
   assign iccm_ready           = ifc_dma_access_q_ok ;
   rvdff #(1)  dma_req_ff      (.*, .clk(free_clk), .din (dma_iccm_req),       .dout(dma_iccm_req_f2));
   rvdff #(1)  dma_ok_prev_ff  (.*, .clk(free_clk), .din(ifc_dma_access_ok_d), .dout(ifc_dma_access_ok_prev));

    if (pt.ICCM_ENABLE == 1 ) begin: iccm_enabled
         reg  [31:0] dma_mem_addr_ff  ;
         wire  iccm_dma_rden    ;

         wire  ic_dma_active_in;
         wire  iccm_dma_ecc_error_in;
         reg  [13:0] dma_mem_ecc;
         wire  [63:0] iccm_dma_rdata_in;
         wire  [31:0] iccm_dma_rdata_1_muxed;
         wire [2:0] [31:0] iccm_corrected_data;
         reg [2:0] [06:0] iccm_corrected_ecc;
         reg [2:0]   dma_mem_tag_ff;

         reg [3:0]        iccm_double_ecc_error;


         reg [pt.ICCM_BITS-1:2]       iccm_rw_addr_f2;

         reg              iccm_dma_rvalid_in;
         wire [116:0]      iccm_rdmux_data;
         reg [1:0]        dma_mem_sz_ff;


        wire [5:0] ic_fetch_val_int_f2;
        wire [5:0] ic_fetch_val_shift_right;
        wire [2:0] iccm_dma_rd_en;



         assign ic_dma_active_in   =  ifc_dma_access_q_ok  & dma_iccm_req ;
         assign iccm_wren          =  (ifc_dma_access_q_ok & dma_iccm_req &  dma_mem_write) | iccm_correct_ecc;
         assign iccm_rden          =  (ifc_dma_access_q_ok & dma_iccm_req & ~dma_mem_write) | (ifc_iccm_access_f1 & ifc_fetch_req_f1);
         assign iccm_dma_rden      =  (ifc_dma_access_q_ok & dma_iccm_req & ~dma_mem_write)                     ;
         assign iccm_wr_size[2:0]  =  {3{dma_iccm_req}}    & dma_mem_sz[2:0] ;

         rvecc_encode  iccm_ecc_encode0 (
                           .din(dma_mem_wdata[31:0]),
                           .ecc_out(dma_mem_ecc[6:0]));

         rvecc_encode  iccm_ecc_encode1 (
                           .din(dma_mem_wdata[63:32]),
                           .ecc_out(dma_mem_ecc[13:7]));

        assign iccm_wr_data[77:0]   =  (iccm_correct_ecc & ~(ifc_dma_access_q_ok & dma_iccm_req)) ?  {iccm_ecc_corr_data_ff[38:0], iccm_ecc_corr_data_ff[38:0]} :
                                       {dma_mem_ecc[13:7],dma_mem_wdata[63:32], dma_mem_ecc[6:0],dma_mem_wdata[31:0]};

         assign iccm_dma_rdata_1_muxed[31:0] = dma_mem_addr_ff[2] ?  iccm_corrected_data[0][31:0] : iccm_corrected_data[1][31:0] ;
         assign iccm_dma_rdata_in[63:0]      = iccm_dma_ecc_error_in ? {2{dma_mem_addr_ff[31:0]}} : {iccm_dma_rdata_1_muxed[31:0], iccm_corrected_data[0]};
         assign iccm_dma_ecc_error_in   =   |(iccm_double_ecc_error[1:0]);
         rvdff #(3)           dma_tag_ff1      (.*, .clk(free_clk), .din(dma_mem_tag[2:0]),        .dout(dma_mem_tag_ff[2:0]));
         rvdff #(3)           dma_tag_ff2      (.*, .clk(free_clk), .din(dma_mem_tag_ff[2:0]),     .dout(iccm_dma_rtag[2:0]));
         rvdff #(32)          dma_addr_ff      (.*, .clk(free_clk), .din(dma_mem_addr[31:0]),      .dout(dma_mem_addr_ff[31:0]));
         rvdff #(1)           ccm_rdy_in_ff    (.*, .clk(free_clk), .din(iccm_dma_rden),           .dout(iccm_dma_rvalid_in));
         rvdff #(2)           ccm_sz_ff        (.*, .clk(free_clk), .din(dma_mem_sz[1:0]),         .dout(dma_mem_sz_ff[1:0]));
         rvdff #(1)           ccm_rdy_ff       (.*, .clk(free_clk), .din(iccm_dma_rvalid_in),      .dout(iccm_dma_rvalid));
         rvdff #(1)           ccm_err_ff       (.*, .clk(free_clk), .din(iccm_dma_ecc_error_in),   .dout(iccm_dma_ecc_error));
         rvdff #(1)           dma_active_ff    (.*, .clk(free_clk), .din(ic_dma_active_in),        .dout(iccm_dma_active));
         rvdff #(64)          dma_data_ff      (.*, .clk(free_clk), .din(iccm_dma_rdata_in[63:0]), .dout(iccm_dma_rdata[63:0]));



         assign iccm_rw_addr[pt.ICCM_BITS-1:1]    = (  ifc_dma_access_q_ok & dma_iccm_req  & ~iccm_correct_ecc) ? dma_mem_addr[pt.ICCM_BITS-1:1] :
                                                 (~(ifc_dma_access_q_ok & dma_iccm_req) &  iccm_correct_ecc) ? {iccm_ecc_corr_index_ff[pt.ICCM_BITS-1:2],1'b0} : fetch_addr_f1[pt.ICCM_BITS-1:1] ;





  assign ic_fetch_val_int_f2[5:0]      = {2'b00, ic_fetch_val_f2[3:0]};
  assign ic_fetch_val_shift_right[5:0] = {ic_fetch_val_int_f2 << ifu_fetch_addr_int_f2[1] } ;
  assign iccm_dma_rd_en[2:0]           = ({1'b0 , (dma_mem_sz_ff[1:0] == 2'b11) , 1'b1 } & {3{iccm_dma_rvalid_in}}) ;

   assign iccm_rdmux_data[116:0] = iccm_rd_data_ecc[116:0];
   for (genvar i=0; i < 3 ; i++) begin : ICCM_ECC_CHECK
      assign iccm_ecc_word_enable[i] = ((|ic_fetch_val_shift_right[(2*i+1):(2*i)] & ~exu_flush_final[fetch_tid_f2] & sel_iccm_data) | iccm_dma_rd_en[i]) & ~dec_tlu_core_ecc_disable;
   rvecc_decode  ecc_decode (
                           .en(iccm_ecc_word_enable[i]),
                           .sed_ded ( 1'b0 ),                               .din(iccm_rdmux_data[(39*i+31):(39*i)]),
                           .ecc_in(iccm_rdmux_data[(39*i+38):(39*i+32)]),
                           .dout(iccm_corrected_data[i][31:0]),
                           .ecc_out(iccm_corrected_ecc[i][6:0]),
                           .single_ecc_error(iccm_single_ecc_error[i]),
                           .double_ecc_error(iccm_double_ecc_error[i]));
  end
    assign iccm_rd_ecc_single_err  = (|iccm_single_ecc_error[2:0]) & ifc_iccm_access_f2 & ifc_fetch_req_f2;
  if (pt.NUM_THREADS > 1) begin: more_than_1_th
    assign ifu_iccm_rd_ecc_single_err[pt.NUM_THREADS-1:0]  = {((|iccm_single_ecc_error[2:0]) & ifc_iccm_access_f2 & ifc_fetch_req_f2 &  fetch_tid_f2),
                                                              ((|iccm_single_ecc_error[2:0]) & ifc_iccm_access_f2 & ifc_fetch_req_f2 & ~fetch_tid_f2)};
  end  else begin: one_thr
    assign ifu_iccm_rd_ecc_single_err[pt.NUM_THREADS-1:0]  = ((|iccm_single_ecc_error[2:0]) & ifc_iccm_access_f2 & ifc_fetch_req_f2 );
  end

  assign iccm_rd_ecc_double_err  = (|iccm_double_ecc_error[2:0] )  & ifc_iccm_access_f2;

  assign iccm_corrected_data_f2_mux[31:0] = iccm_single_ecc_error[0] ? iccm_corrected_data[0] : iccm_single_ecc_error[1] ? iccm_corrected_data[1] : iccm_corrected_data[2];
  assign iccm_corrected_ecc_f2_mux[6:0]   = iccm_single_ecc_error[0] ? iccm_corrected_ecc[0]  : iccm_single_ecc_error[1] ? iccm_corrected_ecc[1]  : iccm_corrected_ecc[2];

  assign iccm_error_start                =  iccm_rd_ecc_single_err;
  assign iccm_ecc_corr_index_in[pt.ICCM_BITS-1:2] = iccm_single_ecc_error[0] ? iccm_rw_addr_f2[pt.ICCM_BITS-1:2] : iccm_single_ecc_error[1] ? (iccm_rw_addr_f2[pt.ICCM_BITS-1:2] + 1'b1) : (iccm_rw_addr_f2[pt.ICCM_BITS-1:2] + 2'b10);

   rvdff #(pt.ICCM_BITS-2)   iccm_index_f2 (.*, .clk(free_clk), .din(iccm_rw_addr[pt.ICCM_BITS-1:2]),           .dout(iccm_rw_addr_f2[pt.ICCM_BITS-1:2]));


     end else begin : iccm_disabled
         assign iccm_dma_rvalid = 1'b0 ;
         assign iccm_dma_ecc_error = 1'b0 ;
         assign iccm_dma_rdata[63:0] = 'd0 ;
         assign iccm_single_ecc_error = 'd0 ;
         assign iccm_dma_rtag[2:0] = '0;

         assign iccm_rd_ecc_single_err                   = 1'b0 ;
         assign ifu_iccm_rd_ecc_single_err               =  '0;
         assign iccm_rd_ecc_double_err                   = 1'b0 ;
         assign iccm_rd_ecc_single_err_ff                = 1'b0 ;
         assign iccm_error_start                         = 1'b0;
         assign iccm_ecc_corr_index_in[pt.ICCM_BITS-1:2] = '0;
         assign iccm_corrected_data_f2_mux[31:0]         = '0;
         assign iccm_corrected_ecc_f2_mux[6:0]           = '0;

    end

   assign reset_all_tags_in =  |dec_tlu_fence_i_wb[pt.NUM_THREADS-1:0] ;
   rvdff #(1) reset_all_tag_ff  (.*, .clk(active_clk),  .din(reset_all_tags_in), .dout(reset_all_tags));
   rvdff #(1) reset_all_tag_ff2 (.*, .clk(active_clk),  .din(reset_all_tags),    .dout(reset_all_tags_ff));

if (pt.ICACHE_ENABLE == 1 ) begin: icache_enabled
   wire [(pt.ICACHE_TAG_DEPTH/8)-1 : 0] way_status_clken;
   wire [(pt.ICACHE_TAG_DEPTH/8)-1 : 0] way_status_clk;
   reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_TAG_DEPTH-1:0]      ic_tag_valid_out ;
   wire [(pt.ICACHE_TAG_DEPTH/32)-1:0] [pt.ICACHE_NUM_WAYS-1:0] tag_valid_clken ;
   wire [(pt.ICACHE_TAG_DEPTH/32)-1:0] [pt.ICACHE_NUM_WAYS-1:0] tag_valid_clk   ;
   assign  ic_valid  = ~ifu_wr_cumulative_err_data & ~(reset_ic_in | reset_ic_ff | reset_all_tags | reset_all_tags_ff) ;

   assign ifu_status_wr_addr_w_debug[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] = ((ic_debug_rd_en | ic_debug_wr_en ) & ic_debug_tag_array) ?
                                                                           ic_debug_addr[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] :
                                                                           ifu_status_wr_addr[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO];


    rvdff #(pt.ICACHE_INDEX_HI - pt.ICACHE_TAG_INDEX_LO + 1) ifu_tag_miss_addr_f2_p2_ff (.*,
                                                                              .clk (free_clk),
                                                                              .din (ifu_tag_miss_addr_f2_p1[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                                                              .dout(ifu_tag_miss_addr_f2_p2[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]));


   // status
         rvdff #(pt.ICACHE_TAG_LO-pt.ICACHE_TAG_INDEX_LO) status_wr_addr_ff (.*,  .clk(free_clk), .din(ifu_status_wr_addr_w_debug[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                   .dout(ifu_status_wr_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]));

         rvdff #(pt.ICACHE_TAG_LO-pt.ICACHE_TAG_INDEX_LO) status_up_addr_ff (.*,  .clk(free_clk), .din(ifu_status_up_addr[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                   .dout(ifu_status_up_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]));

         assign way_status_wr_en_w_debug = way_status_wr_en | (ic_debug_wr_en  & ic_debug_tag_array);
         rvdff #(1) status_wren_ff (.*, .clk(free_clk),  .din(way_status_wr_en_w_debug), .dout(way_status_wr_en_ff));
         rvdff #(1) status_upen_ff (.*, .clk(free_clk),  .din(way_status_up_en), .dout(way_status_up_en_ff));

         assign way_status_wr_w_debug[pt.ICACHE_STATUS_BITS-1:0]  = (ic_debug_wr_en  & ic_debug_tag_array) ? (pt.ICACHE_STATUS_BITS == 1) ? ic_debug_wr_data[4] : ic_debug_wr_data[6:4] :
                                                way_status_wr[pt.ICACHE_STATUS_BITS-1:0] ;
         rvdff #(pt.ICACHE_STATUS_BITS) status_wr_data_ff (.*,  .clk(free_clk), .din(way_status_wr_w_debug[pt.ICACHE_STATUS_BITS-1:0]), .dout(way_status_wr_ff[pt.ICACHE_STATUS_BITS-1:0]));
         rvdff #(pt.ICACHE_STATUS_BITS) status_up_data_ff (.*,  .clk(free_clk), .din(way_status_up[pt.ICACHE_STATUS_BITS-1:0]), .dout(way_status_up_ff[pt.ICACHE_STATUS_BITS-1:0]));


   for (genvar i=0 ; i<pt.ICACHE_TAG_DEPTH/8 ; i++) begin : CLK_GRP_WAY_STATUS
      assign way_status_clken[i] = ( (ifu_status_wr_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO+3] == i && way_status_wr_en_ff) |
                                     (ifu_status_up_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO+3] == i && way_status_up_en_ff) ) ;
      rvclkhdr way_status_cgc ( .en(way_status_clken[i]),   .l1clk(way_status_clk[i]), .* );

      for (genvar j=0 ; j<8 ; j++) begin : WAY_STATUS
                   rvdffs #(pt.ICACHE_STATUS_BITS) ic_way_status (.*,
                   .clk(way_status_clk[i]),
                   .en( ((ifu_status_wr_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (j | i<<3)) & way_status_wr_en_ff) |
                        ((ifu_status_up_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (j | i<<3)) & way_status_up_en_ff)),
                   .din(((ifu_status_wr_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (j | i<<3)) & way_status_wr_en_ff) ?
                                     way_status_wr_ff[pt.ICACHE_STATUS_BITS-1:0] :
                                     way_status_up_ff[pt.ICACHE_STATUS_BITS-1:0]),
                   .dout(way_status_out[8*i+j]));

      end     end  
  always @* begin : way_status_out_mux
      way_status[pt.ICACHE_STATUS_BITS-1:0] = 'd0 ;
      for (int j=0; j< pt.ICACHE_TAG_DEPTH; j++) begin : status_mux_loop
        if (ifu_ic_rw_int_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (pt.ICACHE_TAG_LO-pt.ICACHE_TAG_INDEX_LO)'(j)) begin : mux_out
         way_status[pt.ICACHE_STATUS_BITS-1:0] =  way_status_out[j];
        end
      end
  end

   assign ifu_ic_rw_int_addr_w_debug[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] = ((ic_debug_rd_en | ic_debug_wr_en ) & ic_debug_tag_array) ?
                                                                        ic_debug_addr[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] :
                                                                        ifu_ic_rw_int_addr[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO];


         rvdff #(pt.ICACHE_NUM_WAYS) miss_way_ff (.*,
                                                  .clk (free_clk),
                                                  .din (wren_reset_miss  [pt.ICACHE_NUM_WAYS-1:0]),
                                                  .dout(ifu_tag_miss_wren[pt.ICACHE_NUM_WAYS-1:0]));


         rvdff #(pt.ICACHE_TAG_LO-pt.ICACHE_TAG_INDEX_LO) tag_addr_ff (.*, .clk(free_clk),
                   .din(ifu_ic_rw_int_addr_w_debug[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                   .dout(ifu_ic_rw_int_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]));

         assign ifu_tag_wren_w_debug[pt.ICACHE_NUM_WAYS-1:0] = ifu_tag_wren[pt.ICACHE_NUM_WAYS-1:0] | ic_debug_tag_wr_en[pt.ICACHE_NUM_WAYS-1:0] ;

         rvdff #(pt.ICACHE_NUM_WAYS) tag_v_we_ff (.*, .clk(free_clk),
                   .din (ifu_tag_wren_w_debug[pt.ICACHE_NUM_WAYS-1:0]),
                   .dout(ifu_tag_wren_ff[pt.ICACHE_NUM_WAYS-1:0]));

         assign ic_valid_w_debug = (ic_debug_wr_en & ic_debug_tag_array) ? ic_debug_wr_data[0] : ic_valid;

         rvdff #(1) tag_v_ff (.*, .clk(free_clk),
                   .din(ic_valid_w_debug),
                   .dout(ic_valid_ff));


   for (genvar i=0 ; i<pt.ICACHE_TAG_DEPTH/32 ; i++) begin : CLK_GRP_TAG_VALID
      for (genvar j=0; j<pt.ICACHE_NUM_WAYS; j++) begin : way_clken
      if (pt.ICACHE_TAG_DEPTH == 32 ) begin
        assign tag_valid_clken[i][j] =  ifu_tag_wren_ff[j] | perr_err_inv_way[j] | ifu_tag_miss_wren[j] | reset_all_tags;
      end else begin
         assign tag_valid_clken[i][j] = (((ifu_ic_rw_int_addr_ff [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO+5] == i ) &  ifu_tag_wren_ff[j] )     |                                                          ((perr_ic_index_ff       [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO+5] == i ) &  perr_err_inv_way[j])     |                                                          ((ifu_tag_miss_addr_f2_p2[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO+5] == i ) &  ifu_tag_miss_wren[j])    | reset_all_tags);       end

      rvclkhdr way_status_cgc ( .en(tag_valid_clken[i][j]),   .l1clk(tag_valid_clk[i][j]), .* );

      for (genvar k=0 ; k<32 ; k++) begin : TAG_VALID
                   rvdffsc #(1) ic_way_tagvalid_dup (.*,
                   .clk  (tag_valid_clk[i][j]),
                   .en   (((ifu_ic_rw_int_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   == (k + 32*i)) & ifu_tag_wren_ff[j] )),            // only when we are filling
                   .clear(((perr_ic_index_ff     [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   == (k + 32*i)) & perr_err_inv_way[j])    |         // parity errors need to clear the tag valid
                          ((ifu_tag_miss_addr_f2_p2[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (k + 32*i)) & ifu_tag_miss_wren[j])   |         // tag miss needs to clear the tag valid
                          reset_all_tags),                                                                                                          // reset_all tags
                   .din  (ic_valid_ff ),
                   .dout (ic_tag_valid_out[j][32*i+k]));

      end
      end
   end


  always @* begin : tag_valid_out_mux
      ic_tag_valid_unq[pt.ICACHE_NUM_WAYS-1:0] = '0;
      for (int j=0; j< pt.ICACHE_TAG_DEPTH; j++) begin : tag_valid_loop
        if (ifu_ic_rw_int_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == (pt.ICACHE_TAG_LO-pt.ICACHE_TAG_INDEX_LO)'(j)) begin : valid_out
           for ( integer k=0; k<pt.ICACHE_NUM_WAYS; k++) begin
             ic_tag_valid_unq[k] |= ic_tag_valid_out[k][j];
        end
      end
      end
  end

   if (pt.ICACHE_NUM_WAYS == 4) begin: four_way_plru
   assign replace_way_mb_wr_any[3] = ( way_status_mb_wr_ff[2]  & way_status_mb_wr_ff[0] & (&tagv_mb_wr_ff[3:0])) |
                                  (~tagv_mb_wr_ff[3]& tagv_mb_wr_ff[2] &  tagv_mb_wr_ff[1] &  tagv_mb_wr_ff[0]) ;
   assign replace_way_mb_wr_any[2] = (~way_status_mb_wr_ff[2]  & way_status_mb_wr_ff[0] & (&tagv_mb_wr_ff[3:0])) |
                                  (~tagv_mb_wr_ff[2]& tagv_mb_wr_ff[1] &  tagv_mb_wr_ff[0]) ;
   assign replace_way_mb_wr_any[1] = ( way_status_mb_wr_ff[1] & ~way_status_mb_wr_ff[0] & (&tagv_mb_wr_ff[3:0])) |
                                  (~tagv_mb_wr_ff[1]& tagv_mb_wr_ff[0] ) ;
   assign replace_way_mb_wr_any[0] = (~way_status_mb_wr_ff[1] & ~way_status_mb_wr_ff[0] & (&tagv_mb_wr_ff[3:0])) |
                                  (~tagv_mb_wr_ff[0] ) ;

   assign replace_way_mb_ms_any[3] = ( way_status_mb_ms_ff[2]  & way_status_mb_ms_ff[0] & (&tagv_mb_ms_ff[3:0])) |
                                  (~tagv_mb_ms_ff[3]& tagv_mb_ms_ff[2] &  tagv_mb_ms_ff[1] &  tagv_mb_ms_ff[0]) ;
   assign replace_way_mb_ms_any[2] = (~way_status_mb_ms_ff[2]  & way_status_mb_ms_ff[0] & (&tagv_mb_ms_ff[3:0])) |
                                  (~tagv_mb_ms_ff[2]& tagv_mb_ms_ff[1] &  tagv_mb_ms_ff[0]) ;
   assign replace_way_mb_ms_any[1] = ( way_status_mb_ms_ff[1] & ~way_status_mb_ms_ff[0] & (&tagv_mb_ms_ff[3:0])) |
                                  (~tagv_mb_ms_ff[1]& tagv_mb_ms_ff[0] ) ;
   assign replace_way_mb_ms_any[0] = (~way_status_mb_ms_ff[1] & ~way_status_mb_ms_ff[0] & (&tagv_mb_ms_ff[3:0])) |
                                  (~tagv_mb_ms_ff[0] ) ;

   assign way_status_hit_new[pt.ICACHE_STATUS_BITS-1:0] = ({3{ic_rd_hit[0]}} & {way_status[2] , 1'b1 , 1'b1}) |
                                   ({3{ic_rd_hit[1]}} & {way_status[2] , 1'b0 , 1'b1}) |
                                   ({3{ic_rd_hit[2]}} & {1'b1 ,way_status[1]  , 1'b0}) |
                                   ({3{ic_rd_hit[3]}} & {1'b0 ,way_status[1]  , 1'b0}) ;

  assign way_status_rep_new[pt.ICACHE_STATUS_BITS-1:0] = ({3{replace_way_mb_wr_any[0]}} & {way_status_mb_wr_ff[2] , 1'b1 , 1'b1}) |
                                   ({3{replace_way_mb_wr_any[1]}} & {way_status_mb_wr_ff[2] , 1'b0 , 1'b1}) |
                                   ({3{replace_way_mb_wr_any[2]}} & {1'b1 ,way_status_mb_wr_ff[1]  , 1'b0}) |
                                   ({3{replace_way_mb_wr_any[3]}} & {1'b0 ,way_status_mb_wr_ff[1]  , 1'b0}) ;
  end
   else begin : two_ways_plru
      assign replace_way_mb_wr_any[0]                      = (~way_status_mb_wr_ff  & tagv_mb_wr_ff[0] & tagv_mb_wr_ff[1]) | ~tagv_mb_wr_ff[0];
      assign replace_way_mb_wr_any[1]                      = ( way_status_mb_wr_ff  & tagv_mb_wr_ff[0] & tagv_mb_wr_ff[1]) | ~tagv_mb_wr_ff[1] & tagv_mb_wr_ff[0];

      assign replace_way_mb_ms_any[0]                      = (~way_status_mb_ms_ff  & tagv_mb_ms_ff[0] & tagv_mb_ms_ff[1]) | ~tagv_mb_ms_ff[0];
      assign replace_way_mb_ms_any[1]                      = ( way_status_mb_ms_ff  & tagv_mb_ms_ff[0] & tagv_mb_ms_ff[1]) | ~tagv_mb_ms_ff[1] & tagv_mb_ms_ff[0];

      assign way_status_hit_new[pt.ICACHE_STATUS_BITS-1:0] = ic_rd_hit[0];
      assign way_status_rep_new[pt.ICACHE_STATUS_BITS-1:0] = replace_way_mb_wr_any[0];

   end

    assign way_status_wr[pt.ICACHE_STATUS_BITS-1:0]     = (bus_ifu_wr_en_ff_q  & last_beat)  ? way_status_rep_new[pt.ICACHE_STATUS_BITS-1:0] :
                                                          way_status_hit_new[pt.ICACHE_STATUS_BITS-1:0] ;

  assign way_status_up[pt.ICACHE_STATUS_BITS-1:0]     = way_status_hit_new[pt.ICACHE_STATUS_BITS-1:0] ;


  assign way_status_wr_en  = (bus_ifu_wr_en_ff_q  & last_beat)  ;
  assign way_status_up_en  =  ic_act_hit_f2;

   for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin  : bus_wren_loop
      assign bus_wren[i]           = bus_ifu_wr_en_ff_q & replace_way_mb_wr_any[i] & miss_pending ;
      assign bus_wren_last[i]      = bus_ifu_wr_en_ff_wo_err & replace_way_mb_wr_any[i] & miss_pending & bus_last_data_beat;
      assign ifu_tag_wren[i]       = bus_wren_last[i];                                                                                 assign wren_reset_miss[i]    = replace_way_mb_ms_any[i] & reset_tag_valid_for_miss ;

   end
   assign bus_ic_wr_en[pt.ICACHE_NUM_WAYS-1:0] = bus_wren[pt.ICACHE_NUM_WAYS-1:0];


end else begin: icache_disabled
   assign ic_tag_valid_unq[pt.ICACHE_NUM_WAYS-1:0]         = '0;
   assign way_status[pt.ICACHE_STATUS_BITS-1:0]            = '0;
   assign replace_way_mb_wr_any[pt.ICACHE_NUM_WAYS-1:0]    = '0;
   assign replace_way_mb_ms_any[pt.ICACHE_NUM_WAYS-1:0]    = '0;
   assign way_status_hit_new[pt.ICACHE_STATUS_BITS-1:0]    = '0;
   assign way_status_rep_new[pt.ICACHE_STATUS_BITS-1:0]    = '0;
   assign way_status_wr[pt.ICACHE_STATUS_BITS-1:0]         = '0;
   assign way_status_up[pt.ICACHE_STATUS_BITS-1:0]         = '0;
   assign way_status_up_en                                 = '0;
   assign way_status_wr_en                                 = '0;
   assign bus_wren[pt.ICACHE_NUM_WAYS-1:0]                 = '0;
end


   assign ic_tag_valid[pt.ICACHE_NUM_WAYS-1:0] = ic_tag_valid_unq[pt.ICACHE_NUM_WAYS-1:0]   & {pt.ICACHE_NUM_WAYS{(~fetch_uncacheable_ff & ifc_fetch_req_f2) }} ;
   assign ic_debug_tag_val_rd_out           = |(ic_tag_valid_unq[pt.ICACHE_NUM_WAYS-1:0] &  ic_debug_way_ff[pt.ICACHE_NUM_WAYS-1:0]   & {pt.ICACHE_NUM_WAYS{ic_debug_rd_en_ff}}) ;

 assign ifu_pmu_ic_miss_in   = ic_act_miss_f2_thr[pt.NUM_THREADS-1:0] ;
 assign ifu_pmu_ic_hit_in    = ic_act_hit_f2_thr[pt.NUM_THREADS-1:0]  ;
 assign ifu_pmu_bus_error_in = ifc_bus_acc_fault_f2_thr[pt.NUM_THREADS-1:0];
 assign ifu_pmu_bus_trxn_in  = bus_cmd_sent_thr[pt.NUM_THREADS-1:0] ;
 assign ifu_pmu_bus_busy_in  = {pt.NUM_THREADS{ifu_bus_arvalid_ff & ~ifu_bus_arready_ff}} & miss_pending_thr[pt.NUM_THREADS-1:0] ;

   rvdff #(5*pt.NUM_THREADS) ifu_pmu_sigs_ff (.*,
                    .clk (active_clk),
                    .din ({ifu_pmu_ic_miss_in[pt.NUM_THREADS-1:0],
                           ifu_pmu_ic_hit_in[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_error_in[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_busy_in[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_trxn_in[pt.NUM_THREADS-1:0]
                          }),
                    .dout({ifu_pmu_ic_miss[pt.NUM_THREADS-1:0],
                           ifu_pmu_ic_hit[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_error[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_busy[pt.NUM_THREADS-1:0],
                           ifu_pmu_bus_trxn[pt.NUM_THREADS-1:0]
                           }));


assign ic_debug_addr[pt.ICACHE_INDEX_HI:3] = dec_tlu_ic_diag_pkt.icache_dicawics[pt.ICACHE_INDEX_HI-3:0] ;
assign ic_debug_way_enc[01:00]             = dec_tlu_ic_diag_pkt.icache_dicawics[15:14] ;


assign ic_debug_tag_array       = dec_tlu_ic_diag_pkt.icache_dicawics[16] ;
assign ic_debug_rd_en           = dec_tlu_ic_diag_pkt.icache_rd_valid ;
assign ic_debug_wr_en           = dec_tlu_ic_diag_pkt.icache_wr_valid ;


assign ic_debug_way[pt.ICACHE_NUM_WAYS-1:0]        = {(ic_debug_way_enc[1:0] == 2'b11),
                                                      (ic_debug_way_enc[1:0] == 2'b10),
                                                      (ic_debug_way_enc[1:0] == 2'b01),
                                                      (ic_debug_way_enc[1:0] == 2'b00) };

assign ic_debug_tag_wr_en[pt.ICACHE_NUM_WAYS-1:0] = {pt.ICACHE_NUM_WAYS{ic_debug_wr_en & ic_debug_tag_array}} & ic_debug_way[pt.ICACHE_NUM_WAYS-1:0] ;

assign ic_debug_ict_array_sel_in      =  ic_debug_rd_en & ic_debug_tag_array ;



rvdff #(01+pt.ICACHE_NUM_WAYS) ifu_debug_sel_ff (.*, .clk (debug_c1_clk),
                    .din ({ic_debug_ict_array_sel_in,
                           ic_debug_way[pt.ICACHE_NUM_WAYS-1:0]
                          }),
                    .dout({ic_debug_ict_array_sel_ff,
                           ic_debug_way_ff[pt.ICACHE_NUM_WAYS-1:0]
                           }));


rvdff #(1) ifu_debug_rd_en_ff (.*,.clk(free_clk),
                    .din ({
                           ic_debug_rd_en
                          }),
                    .dout({
                           ic_debug_rd_en_ff
                           }));


assign debug_data_clken  =  ic_debug_rd_en_ff;
rvclkhdr debug_data_c1_cgc ( .en(debug_data_clken),   .l1clk(debug_data_clk), .* );

rvdff #(1) ifu_debug_valid_ff (.*, .clk(free_clk),
                    .din ({
                           ic_debug_rd_en_ff
                          }),
                    .dout({
                           ifu_ic_debug_rd_data_valid
                           }));




   assign ifc_region_acc_okay = (~(|{pt.INST_ACCESS_ENABLE0,pt.INST_ACCESS_ENABLE1,pt.INST_ACCESS_ENABLE2,pt.INST_ACCESS_ENABLE3,pt.INST_ACCESS_ENABLE4,pt.INST_ACCESS_ENABLE5,pt.INST_ACCESS_ENABLE6,pt.INST_ACCESS_ENABLE7})) |
                               (pt.INST_ACCESS_ENABLE0 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK0)) == (pt.INST_ACCESS_ADDR0 | pt.INST_ACCESS_MASK0)) |
                               (pt.INST_ACCESS_ENABLE1 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK1)) == (pt.INST_ACCESS_ADDR1 | pt.INST_ACCESS_MASK1)) |
                               (pt.INST_ACCESS_ENABLE2 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK2)) == (pt.INST_ACCESS_ADDR2 | pt.INST_ACCESS_MASK2)) |
                               (pt.INST_ACCESS_ENABLE3 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK3)) == (pt.INST_ACCESS_ADDR3 | pt.INST_ACCESS_MASK3)) |
                               (pt.INST_ACCESS_ENABLE4 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK4)) == (pt.INST_ACCESS_ADDR4 | pt.INST_ACCESS_MASK4)) |
                               (pt.INST_ACCESS_ENABLE5 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK5)) == (pt.INST_ACCESS_ADDR5 | pt.INST_ACCESS_MASK5)) |
                               (pt.INST_ACCESS_ENABLE6 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK6)) == (pt.INST_ACCESS_ADDR6 | pt.INST_ACCESS_MASK6)) |
                               (pt.INST_ACCESS_ENABLE7 & (({fetch_addr_f1[31:1],1'b0} | pt.INST_ACCESS_MASK7)) == (pt.INST_ACCESS_ADDR7 | pt.INST_ACCESS_MASK7));

   assign ifc_region_acc_fault_memory   =  ~ifc_iccm_access_f1 & ~ifc_region_acc_okay & ifc_fetch_req_f1;

   assign ifc_region_acc_fault_final_f1 = ifc_region_acc_fault_f1 | ifc_region_acc_fault_memory;


   rvdff #(1) region_acc_mem_ff (.*,.clk(free_clk),
                    .din ({
                           ifc_region_acc_fault_memory
                          }),
                    .dout({
                           ifc_region_acc_fault_memory_f2
                           }));




assign  fetch_tid_dec_f1[pt.NUM_THREADS-1:0] = {fetch_tid_f1,~fetch_tid_f1};
assign  fetch_tid_dec_f2[pt.NUM_THREADS-1:0] = {fetch_tid_f2,~fetch_tid_f2};



  if (pt.NUM_THREADS > 1) begin: mt1t
   assign ic_reset_tid   =  ((fetch_tid_f2_p1 & ~scnd_miss_req_ff2_thr[0] & ~ifu_miss_state_pre_crit_ff_thr[0]) |
                             (scnd_miss_req_ff2_thr[pt.NUM_THREADS-1]     & ~ifu_miss_state_pre_crit_ff_thr[0]) |
                              ifu_miss_state_pre_crit_ff_thr[pt.NUM_THREADS-1]);
    assign  ic_write_stall_thr[pt.NUM_THREADS-1:0]   =   { (ic_write_stall_self_thr[1] | ic_write_stall_other_thr[0]) , (ic_write_stall_self_thr[0] | ic_write_stall_other_thr[1] ) } ;
  end else begin : onet
   assign ic_reset_tid   = 1'b0 ;
    assign  ic_write_stall_thr[pt.NUM_THREADS-1:0]   =   ic_write_stall_self_thr[pt.NUM_THREADS-1:0]   ;
  end

   assign ifu_bus_cmd_valid_thr_in[1:0] = (pt.NUM_THREADS==1) ? {1'b0 , ifu_bus_cmd_valid_thr[0]} : ifu_bus_cmd_valid_thr[pt.NUM_THREADS-1:0];
   assign miss_done_other[1:0]          = (pt.NUM_THREADS==1) ? 2'b11                             : {miss_done_thr[0],     miss_done_thr[pt.NUM_THREADS-1]};
   assign address_match_other[1:0]      = (pt.NUM_THREADS==1) ? 2'b0                              : {address_match_thr[0], address_match_thr[pt.NUM_THREADS-1]};
   assign miss_address_other[1:0]       = (pt.NUM_THREADS==1) ? 'd0                                : {miss_address_thr[0],  miss_address_thr[pt.NUM_THREADS-1]};
   assign selected_miss_thr_in[1:0]     = (pt.NUM_THREADS==1) ? 2'b11                             : {selected_miss_thr, ~selected_miss_thr};
   assign rsp_miss_thr[1:0]             = (pt.NUM_THREADS==1) ? 2'b11                             : {ifu_bus_rid_ff[pt.IFU_BUS_TAG-1], ~ifu_bus_rid_ff[pt.IFU_BUS_TAG-1]};
   assign flush_err_tid0_wb             = dec_tlu_flush_err_wb[0]  ;
   assign scnd_miss_req_other_thr[1:0]  = (pt.NUM_THREADS==1) ? 2'b00                             : {scnd_miss_req_thr[0], scnd_miss_req_thr[pt.NUM_THREADS-1]};

       rvdff #(1) err_tid_wb1 (.*,.clk(free_clk),
                               .din ( flush_err_tid0_wb      ),
                               .dout( flush_err_tid0_wb1      ));

   rvdff #(1) err_tid_wb2 (.*,.clk(free_clk),
                               .din ( flush_err_tid0_wb1      ),
                               .dout( flush_err_tid0_wb2      ));

   assign arbitter_toggle_en            = ifu_bus_arready_unq & bus_ifu_bus_clk_en;
   assign ic_wr_tid_ff                  = ic_write_stall ? rsp_tid_ff : fetch_tid_f1;

   rvarbiter2 miss_thr_arb (.*,
                         .ready (ifu_bus_cmd_valid_thr_in[1:0]),
                         .shift (arbitter_toggle_en),
                         .clk   (busclk),
                         .tid   (selected_miss_thr_tmp));     // This needs to be updated only based on the thread being accepted

   assign bus_thread_en = arbitter_toggle_en |  (ifu_bus_cmd_valid_thr_in[1] ^ ifu_bus_cmd_valid_thr_in[0]);

   rvdffs #(1) miss_thread_bus (.clk(busclk),       .din(selected_miss_thr_tmp), .dout(selected_miss_thr), .en(bus_thread_en),   .*);


  assign ifu_miss_state_idle                                        =     ifu_miss_state_idle_thr;

    assign  ic_dma_active                                                 =     |ic_dma_active_thr;
    assign  iccm_stop_fetch                                               =     |iccm_stop_fetch_thr;

    assign  ic_write_stall                                                =     |ic_write_stall_other_thr;

    assign  ic_rd_en                                                      =     ic_rd_en_thr[fetch_tid_f1];
    assign  reset_tag_valid_for_miss                                      =     reset_tag_valid_for_miss_thr[ic_reset_tid];

    assign  ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]                              =     ic_wr_en_thr[rsp_tid_ff][pt.ICACHE_NUM_WAYS-1:0];
    assign  ifu_bus_cmd_valid                                             =     ifu_bus_cmd_valid_thr[selected_miss_thr]  ;
    assign  bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0]                    =     bus_rd_addr_count_thr[selected_miss_thr];

    assign  ifu_ic_req_addr_f2[31:3]                                      =     ifu_ic_req_addr_f2_thr[selected_miss_thr];
    assign  ic_miss_buff_half[63:0]                                       =     ic_miss_buff_half_thr[rsp_tid_ff];
    assign  sel_byp_data                                                  =     sel_byp_data_thr[fetch_tid_f2];
    assign  sel_ic_data                                                   =     sel_ic_data_thr[fetch_tid_f2];
    assign  miss_pending                                                  =     miss_pending_thr[rsp_tid_ff];

    assign  perr_err_inv_way[pt.ICACHE_NUM_WAYS-1:0]                      =     perr_err_inv_way_thr[flush_ic_err_tid][pt.ICACHE_NUM_WAYS-1:0];
    assign  perr_ic_index_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   =     perr_ic_index_ff_thr[flush_ic_err_tid][pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO];
    assign  ifu_tag_miss_addr_f2_p1[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]  =    ifu_ic_rw_int_addr_thr[ic_reset_tid][pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO];
    assign  perr_sel_invalidate                                           =     perr_sel_invalidate_thr[flush_ic_err_tid];
    assign  bus_ifu_wr_en_ff_q                                            =     bus_ifu_wr_en_ff_q_thr[rsp_tid_ff];
    assign  bus_ifu_wr_en_ff_wo_err                                       =     bus_ifu_wr_en_ff_wo_err_thr[rsp_tid_ff];
    assign  iccm_correction_state                                         =     iccm_correction_state_thr[fetch_tid_f1];
    assign  iccm_corr_scnd_fetch                                          =     iccm_corr_scnd_fetch_thr[fetch_tid_f1];
    assign  perr_state                                                    =     perr_state_thr[fetch_tid_f1] ;
    assign  perr_state_idle                                               =     &perr_state_idle_thr ;
    assign  err_stop_state                                                =     err_stop_state_thr[fetch_tid_f2]     ;


    assign  way_status_mb_wr_ff[pt.ICACHE_STATUS_BITS-1:0]                =     way_status_mb_ff_thr[rsp_tid_ff][pt.ICACHE_STATUS_BITS-1:0];
    assign  way_status_mb_ms_ff[pt.ICACHE_STATUS_BITS-1:0]                =     way_status_mb_ff_thr[ic_reset_tid][pt.ICACHE_STATUS_BITS-1:0];
    assign  tagv_mb_wr_ff[pt.ICACHE_NUM_WAYS-1:0]                         =     tagv_mb_ff_thr[rsp_tid_ff][pt.ICACHE_NUM_WAYS-1:0];
    assign  tagv_mb_ms_ff[pt.ICACHE_NUM_WAYS-1:0]                         =     tagv_mb_ff_thr[ic_reset_tid][pt.ICACHE_NUM_WAYS-1:0];

    assign  ifu_byp_data_err_new                                          =     ifu_byp_data_err_new_thr[fetch_tid_f2];
    assign  ifu_wr_cumulative_err_data                                    =     ifu_wr_cumulative_err_data_thr[rsp_tid_ff];
    assign  ic_act_hit_f2                                                 =     ic_act_hit_f2_thr[fetch_tid_f2];
    assign  ic_act_hit_f2_ff                                              =     ic_act_hit_f2_ff_thr[fetch_tid_f2_p1];
    assign  ifc_fetch_req_f2                                              =     ifc_fetch_req_f2_thr[fetch_tid_f2];
    assign  last_beat                                                     =     last_beat_thr[rsp_tid_ff];
    assign  ifu_ic_rw_int_addr [31:1]                                     =     ifu_ic_rw_int_addr_thr[ic_wr_tid_ff][31:1];
    assign  ic_byp_data_only_new[79:0]                                    =     ic_byp_data_only_new_thr[fetch_tid_f2][79:0];
    assign  ic_byp_hit_f2                                                 =     ic_byp_hit_f2_thr[fetch_tid_f2];
    assign  reset_ic_in                                                   =     reset_ic_in_thr[rsp_tid_ff];
    assign  reset_ic_ff                                                   =     reset_ic_ff_thr[rsp_tid_ff];

    assign  bus_cmd_sent                                                  =     bus_cmd_sent_thr[selected_miss_thr];
    assign  bus_last_data_beat                                            =     bus_last_data_beat_thr[rsp_tid_ff];
    assign  ic_hit_f2                                                     =     ic_hit_f2_thr[fetch_tid_f2];
    assign  ic_act_miss_f2                                                =     ic_act_miss_f2_thr[fetch_tid_f2];

  assign ifc_bus_acc_fault_f2_thr[pt.NUM_THREADS-1:0]   =  ic_byp_hit_f2_thr[pt.NUM_THREADS-1:0] & ifu_byp_data_err_new_thr[pt.NUM_THREADS-1:0] ;

    assign  ifu_status_up_addr[31:1]                                      =     ifu_status_up_addr_thr[fetch_tid_f2][31:1];
    assign  ifu_status_wr_addr[31:1]                                      =     ifu_status_wr_addr_thr[rsp_tid_ff][31:1];
    assign  iccm_correct_ecc                                              =     |iccm_correct_ecc_thr[pt.NUM_THREADS-1:0];
    assign flush_ic_err_tid =  (pt.NUM_THREADS > 1) &  dec_tlu_flush_err_wb[pt.NUM_THREADS-1] &  perr_state_wff_thr[pt.NUM_THREADS-1]  ;

    assign  select_t0_iccm_corr_index                                     =     flush_err_tid0_wb1 & iccm_correct_ecc_thr[0] ;
    assign  iccm_ecc_corr_index_ff[pt.ICCM_BITS-1:2]                      =     dma_sb_err_state_ff ?  iccm_ecc_corr_index_ff_thr[fetch_tid_f2_p2] : select_t0_iccm_corr_index ? iccm_ecc_corr_index_ff_thr[0] :
                                                                                                                                                                                 iccm_ecc_corr_index_ff_thr[pt.NUM_THREADS-1];
    assign  iccm_ecc_corr_data_ff[38:0]                                   =     dma_sb_err_state_ff ?  iccm_ecc_corr_data_ff_thr [fetch_tid_f2_p2] : select_t0_iccm_corr_index ? iccm_ecc_corr_data_ff_thr[0]:
                                                                                                                                                                       iccm_ecc_corr_data_ff_thr[pt.NUM_THREADS-1];
    assign  dma_sb_err_state                                              =     dma_sb_err_state_thr[fetch_tid_f2_p1];
   rvdff #(1)  sb_err_ff    (.*, .clk(active_clk), .din (dma_sb_err_state), .dout(dma_sb_err_state_ff));


   rvdff #(pt.NUM_THREADS)  select_miss_thr_ff    (.*, .clk(active_clk), .din (selected_miss_thr_in[pt.NUM_THREADS-1:0]), .dout(selected_miss_thr_ff[pt.NUM_THREADS-1:0]));

 for (genvar i=0 ;  i < pt.NUM_THREADS ; i++) begin : THREADS
   eh2_ifu_mem_ctl_thr #(.pt(pt))  ifu_mem_ctl_thr_inst(.*,
   .tid                                         (1'(i)),
   .scan_mode                                   ( scan_mode ) ,
   .clk                                         ( clk ) ,
   .free_clk                                    ( free_clk ) ,
   .active_clk                                  ( active_clk ) ,
   .rst_l                                       ( rst_l ) ,
   .ifu_bus_clk_en                              ( ifu_bus_clk_en ) ,

   .fetch_tid_f1                                ( fetch_tid_dec_f1[i]),
   .fetch_tid_f2                                ( fetch_tid_dec_f2[i]),
   .dec_tlu_flush_err_wb                        ( dec_tlu_flush_err_wb[i] ) ,
   .dec_tlu_force_halt                          ( dec_tlu_force_halt[i] ) ,
   .dec_tlu_flush_lower_wb                      ( dec_tlu_flush_lower_wb[i] ) ,
   .exu_flush_final                             ( exu_flush_final[i] ) ,
   .flush_final_f2                              ( flush_final_f2[i]) ,
   .two_byte_instr_f2                           ( two_byte_instr_f2) ,

   .ifu_bp_kill_next_f2                         ( ifu_bp_kill_next_f2 ) ,
   .ifc_fetch_req_f1                            ( ifc_fetch_req_f1 ) ,
   .ifc_fetch_req_f1_raw                        ( ifc_fetch_req_f1_raw ) ,
   .ifc_fetch_uncacheable_f1                    ( ifc_fetch_uncacheable_f1 ) ,
   .ic_rd_hit                                   ( ic_rd_hit ) ,
   .fetch_addr_f1                               ( fetch_addr_f1 ) ,
   .iccm_dma_sb_error                           ( iccm_dma_sb_error ) ,
   .ic_error_start                              ( ifu_ic_error_start[i] ) ,
   .dec_tlu_i0_commit_cmt                       ( dec_tlu_i0_commit_cmt[i] ) ,
   .ifu_fetch_val                               ( ifu_fetch_val[1:0] ) ,
   .ifc_iccm_access_f1                          ( ifc_iccm_access_f1 ) ,
   .dec_tlu_fence_i_wb                          ( dec_tlu_fence_i_wb[i] ) ,
   .bus_ic_wr_en                                ( bus_ic_wr_en ) ,

   .scnd_miss_req_other                         ( scnd_miss_req_other_thr[i] ),       .address_match_other                         ( address_match_other[i]),            .miss_address_other                          ( miss_address_other[i]),             .miss_done_other                             ( miss_done_other[i]),                .way_status                                  ( way_status ) ,
   .way_status_rep_new                          ( way_status_rep_new ) ,
   .ifc_region_acc_fault_f2                     ( ifc_region_acc_fault_f2 ) ,
   .ifu_fetch_addr_int_f2                       ( ifu_fetch_addr_int_f2 ) ,
   .reset_all_tags                              ( reset_all_tags ) ,
   .ifu_bus_rid_ff                              ( ifu_bus_rid_ff ) ,
   .fetch_req_icache_f2                         ( fetch_req_icache_f2 ) ,
   .fetch_req_iccm_f2                           ( fetch_req_iccm_f2 ) ,
   .ifu_bus_rvalid                              ( ifu_bus_rvalid ) ,
   .ifu_bus_rvalid_ff                           ( ifu_bus_rvalid_ff ) ,
   .ifu_bus_arvalid_ff                          ( ifu_bus_arvalid_ff ) ,
   .ifu_bus_arvalid                             ( ifu_bus_arvalid    ) ,
   .ifu_bus_arready                             ( ifu_bus_arready    ) ,
   .ifu_bus_rresp_ff                            ( ifu_bus_rresp_ff ) ,
   .ifu_selected_miss_thr                       ( selected_miss_thr_in[i] ),
   .rsp_miss_thr_ff                             ( rsp_miss_thr[i] ),
   .ifu_bus_rsp_valid                           ( ifu_bus_rsp_valid ) ,
   .ifu_bus_rsp_ready                           ( ifu_bus_rsp_ready ) ,
   .ifu_bus_rsp_tag                             ( ifu_bus_rsp_tag ) ,
   .ifu_bus_rsp_rdata                           ( ifu_bus_rsp_rdata ) ,
   .ifu_bus_rsp_opc                             ( ifu_bus_rsp_opc ) ,
   .iccm_error_start                            ( iccm_error_start ) ,
   .bus_ifu_bus_clk_en                          ( bus_ifu_bus_clk_en ) ,
   .ifu_bus_cmd_ready                           ( ifu_bus_cmd_ready ) ,
   .ifc_region_acc_fault_final_f1               ( ifc_region_acc_fault_final_f1 ) ,
   .ic_tag_valid                                ( ic_tag_valid ) ,
   .replace_way_mb_any                          ( replace_way_mb_wr_any ) ,
   .ifu_ic_rw_int_addr_ff                       ( ifu_ic_rw_int_addr_ff ) ,
   .iccm_ecc_corr_index_in                      ( iccm_ecc_corr_index_in ) ,
   .iccm_corrected_data_f2_mux                  (iccm_corrected_data_f2_mux),
   .iccm_corrected_ecc_f2_mux                   (iccm_corrected_ecc_f2_mux),

   .iccm_ecc_corr_index_ff                      (iccm_ecc_corr_index_ff_thr[i]),
   .iccm_ecc_corr_data_ff                       (iccm_ecc_corr_data_ff_thr[i]),
   .dma_sb_err_state                            (dma_sb_err_state_thr[i]),

   .miss_done                                   ( miss_done_thr[i] ) ,
   .address_match                               ( address_match_thr[i] ) ,
   .miss_address                                ( miss_address_thr[i]),             .ifu_bus_cmd_valid                           ( ifu_bus_cmd_valid_thr[i] ) ,
   .iccm_buf_correct_ecc                        ( iccm_buf_correct_ecc_thr[i] ) ,
   .ifu_ic_mb_empty                             ( ifu_ic_mb_empty_thr[i] ) ,
   .ic_dma_active                               ( ic_dma_active_thr[i] ) ,
   .iccm_stop_fetch                             ( iccm_stop_fetch_thr[i] ) ,
   .ic_write_stall_self                         ( ic_write_stall_self_thr[i] ) ,
   .ic_write_stall_other                        ( ic_write_stall_other_thr[i] ) ,
   .ic_rd_en                                    ( ic_rd_en_thr[i] ) ,
   .ic_real_rd_wp                               ( ic_real_rd_wp_thr[i] ) ,
   .ifu_miss_state_idle                         ( ifu_miss_state_idle_thr[i] ) ,
   .ifu_miss_state_pre_crit_ff                  ( ifu_miss_state_pre_crit_ff_thr[i] ) ,
   .ic_crit_wd_rdy                              ( ic_crit_wd_rdy_thr[i]   ) ,
   .ic_wr_en                                    ( ic_wr_en_thr[i] ) ,
   .ifu_ic_req_addr_f2                          ( ifu_ic_req_addr_f2_thr[i] ) ,
   .reset_tag_valid_for_miss                    ( reset_tag_valid_for_miss_thr[i] ) ,
   .ic_miss_buff_half                           ( ic_miss_buff_half_thr[i] ) ,
   .sel_byp_data                                ( sel_byp_data_thr[i] ) ,
   .sel_ic_data                                 ( sel_ic_data_thr[i] ) ,
   .miss_pending                                ( miss_pending_thr[i] ) ,
   .bus_rd_addr_count                           ( bus_rd_addr_count_thr[i] ) ,
   .perr_err_inv_way                            ( perr_err_inv_way_thr[i] ) ,
   .perr_ic_index_ff                            ( perr_ic_index_ff_thr[i] ) ,
   .perr_sel_invalidate                         ( perr_sel_invalidate_thr[i] ) ,
   .bus_ifu_wr_en_ff_q                          ( bus_ifu_wr_en_ff_q_thr[i] ) ,
   .bus_ifu_wr_en_ff_wo_err                     ( bus_ifu_wr_en_ff_wo_err_thr[i] ) ,
   .iccm_correction_state                       ( iccm_correction_state_thr[i] ) ,
   .iccm_corr_scnd_fetch                        ( iccm_corr_scnd_fetch_thr[i] ) ,

   .perr_state                                  ( perr_state_thr[i] ) ,
   .perr_state_idle                             ( perr_state_idle_thr[i] ) ,
   .perr_state_wff                              ( perr_state_wff_thr[i] ) ,
   .err_stop_state                              ( err_stop_state_thr[i] ) ,

   .scnd_miss_req_ff2                           ( scnd_miss_req_ff2_thr[i] ),
   .scnd_miss_req                               ( scnd_miss_req_thr[i] ),            .way_status_mb_ff                            ( way_status_mb_ff_thr[i] ) ,
   .tagv_mb_ff                                  ( tagv_mb_ff_thr[i] ) ,
   .ifu_byp_data_err_new                        ( ifu_byp_data_err_new_thr[i] ) ,
   .ifu_wr_cumulative_err_data                  ( ifu_wr_cumulative_err_data_thr[i] ) ,
   .ic_act_hit_f2                               ( ic_act_hit_f2_thr[i] ) ,
   .ic_act_hit_f2_ff                            ( ic_act_hit_f2_ff_thr[i] ) ,
   .ifc_fetch_req_f2                            ( ifc_fetch_req_f2_thr[i] ) ,
   .last_beat                                   ( last_beat_thr[i] ) ,
   .ifu_ic_rw_int_addr                          ( ifu_ic_rw_int_addr_thr[i]  ) ,
   .ic_byp_data_only_new                        ( ic_byp_data_only_new_thr[i] ) ,
   .ic_byp_hit_f2                               ( ic_byp_hit_f2_thr[i]  ) ,
   .reset_ic_in                                 ( reset_ic_in_thr[i]  ) ,
   .reset_ic_ff                                 ( reset_ic_ff_thr[i]  ) ,
   .ifu_status_up_addr                          ( ifu_status_up_addr_thr[i] ) ,
   .ifu_status_wr_addr                          ( ifu_status_wr_addr_thr[i] ) ,
   .iccm_correct_ecc                            ( iccm_correct_ecc_thr[i] ) ,
   .bus_cmd_sent                                ( bus_cmd_sent_thr[i] ) ,
   .bus_last_data_beat                          ( bus_last_data_beat_thr[i] ) ,
   .ic_hit_f2                                   ( ic_hit_f2_thr[i] ) ,
   .ic_act_miss_f2                              ( ic_act_miss_f2_thr[i])


);

end 

endmodule : eh2_ifu_mem_ctl



module eh2_ifu_mem_ctl_thr
 import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
 (
   input wire tid,
   input wire scan_mode ,
   input wire clk,
   input wire free_clk,                                               input wire active_clk,                                             input wire rst_l,
   input wire busclk,
   input wire ifu_bus_clk_en,

   input wire fetch_tid_f1,                     input wire fetch_tid_f2,                     input wire ifu_bp_kill_next_f2,              input wire ifc_fetch_req_f1,                 input wire ifc_fetch_req_f1_raw,             input wire exu_flush_final    ,              input wire flush_final_f2,            input wire two_byte_instr_f2,            input wire ifc_fetch_uncacheable_f1,         input wire [pt.ICACHE_NUM_WAYS-1:0]          ic_rd_hit,             input wire [31:1]                            fetch_addr_f1,                    input wire iccm_dma_sb_error,         input wire ic_error_start,            input wire dec_tlu_flush_lower_wb,           input wire dec_tlu_i0_commit_cmt,           input wire [1:0]                           ifu_fetch_val,                    input wire ifc_iccm_access_f1,           input wire dec_tlu_fence_i_wb,           input wire dec_tlu_flush_err_wb,             input wire dec_tlu_force_halt ,
   input wire [pt.ICACHE_NUM_WAYS-1:0]          bus_ic_wr_en ,

   input wire selected_miss_thr,          input wire [31:1]                           miss_address_other,             input wire miss_done_other ,            input wire scnd_miss_req_other,         input wire address_match_other ,           input wire [pt.ICACHE_STATUS_BITS-1:0]     way_status,
   input wire [pt.ICACHE_STATUS_BITS-1:0]     way_status_rep_new,
   input wire ifc_region_acc_fault_f2,
   input wire [31:1]                          ifu_fetch_addr_int_f2 ,
   input wire reset_all_tags,
   input wire [pt.IFU_BUS_TAG-1:0]             ifu_bus_rid_ff,
   input wire fetch_req_icache_f2,
   input wire fetch_req_iccm_f2,
   input wire ifu_bus_rvalid           ,
   input wire ifu_bus_rvalid_ff        ,
   input wire ifu_bus_arvalid_ff        ,
   input wire ifu_bus_arvalid           ,
   input wire ifu_bus_arready           ,
   input wire [1:0]                            ifu_bus_rresp_ff          ,
   input wire ifu_bus_rsp_valid ,
   input wire ifu_bus_rsp_ready ,
   input wire ifu_selected_miss_thr   ,
   input wire rsp_miss_thr_ff,
   input wire [pt.IFU_BUS_TAG-1:0]             ifu_bus_rsp_tag,
   input wire [63:0]                           ifu_bus_rsp_rdata,
   input wire [1:0]                            ifu_bus_rsp_opc,
   input wire iccm_error_start,        input wire bus_ifu_bus_clk_en ,
   input wire ifu_bus_cmd_ready ,
   input wire ifc_region_acc_fault_final_f1,
   input wire [pt.ICACHE_NUM_WAYS-1:0]         ic_tag_valid,          input wire [pt.ICACHE_NUM_WAYS-1:0]         replace_way_mb_any,
   input wire [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] ifu_ic_rw_int_addr_ff ,
   input wire iccm_rd_ecc_single_err,
      input wire [31:0]                                      iccm_corrected_data_f2_mux,
   input wire [06:0]                                      iccm_corrected_ecc_f2_mux ,
   input wire [pt.ICCM_BITS-1:2]                          iccm_ecc_corr_index_in,

   output logic [pt.ICCM_BITS-1:2]                          iccm_ecc_corr_index_ff,
   output logic [38:0]                                      iccm_ecc_corr_data_ff,
   output logic                                             dma_sb_err_state,


   output logic                                             ifu_bus_cmd_valid ,

   output logic [31:1]                                      miss_address,                     output logic                                             miss_done,                        output logic                                             address_match,                    output logic                                             iccm_buf_correct_ecc,             output logic                                             ifu_ic_mb_empty,                  output logic                                             ic_dma_active  ,                  output logic                                             ic_write_stall_self,              output logic                                             ic_write_stall_other,             output logic                                             ic_rd_en,                         output logic                                             ic_real_rd_wp,                    output logic                                             ifu_miss_state_idle,              output logic                                             ifu_miss_state_pre_crit_ff,       output logic                                             ic_crit_wd_rdy  ,
   output logic [pt.ICACHE_NUM_WAYS-1:0]                    ic_wr_en,              output logic [31:3]                                      ifu_ic_req_addr_f2,
   output logic                                             reset_tag_valid_for_miss  ,
   output logic  [63:0]                                     ic_miss_buff_half,
   output logic                                             sel_byp_data  ,
   output logic                                             sel_ic_data,
   output logic                                             miss_pending,
   output logic [pt.ICACHE_BEAT_BITS-1:0]                   bus_rd_addr_count,
   output logic [pt.ICACHE_NUM_WAYS-1:0]                    perr_err_inv_way,
   output logic [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] perr_ic_index_ff,
   output logic                                             perr_sel_invalidate,
   output logic                                             bus_ifu_wr_en_ff_q  ,
   output logic                                             bus_ifu_wr_en_ff_wo_err  ,
   output logic                                             iccm_correction_state,
   output logic                                             iccm_stop_fetch,
   output logic                                             iccm_corr_scnd_fetch,

   output                                                   perr_state_idle,
   output                                                   perr_state_wff,
   output eh2_perr_state_t                                 perr_state,
   output eh2_err_stop_state_t                             err_stop_state,

   output logic                                             scnd_miss_req_ff2,
   output logic                                             scnd_miss_req,
   output logic  [pt.ICACHE_STATUS_BITS-1:0]                way_status_mb_ff,
   output logic  [pt.ICACHE_NUM_WAYS-1:0]                   tagv_mb_ff,
   output logic                                             ifu_byp_data_err_new,
   output logic                                             ifu_wr_cumulative_err_data,
   output logic                                             ic_act_hit_f2,
   output logic                                             ic_act_hit_f2_ff,
   output logic                                             ifc_fetch_req_f2,
   output logic                                             last_beat,
   output logic [31:1]                                      ifu_ic_rw_int_addr ,
   output logic [79:0]                                      ic_byp_data_only_new,
   output logic                                             ic_byp_hit_f2 ,
   output logic                                             reset_ic_in ,
   output logic                                             reset_ic_ff ,
   output logic [31:1]                                      ifu_status_up_addr,
   output logic [31:1]                                      ifu_status_wr_addr,
   output logic                                             iccm_correct_ecc     ,
   output logic                                             bus_cmd_sent           ,
   output logic                                             bus_last_data_beat  ,
   output logic                                             ic_hit_f2,                 output logic                                             ic_act_miss_f2
) ;


localparam IDLE = 'd 0 ;localparam CRIT_BYP_OK = 'd 1 ;localparam HIT_U_MISS = 'd 2 ;localparam MISS_WAIT = 'd 3 ;localparam CRIT_WRD_RDY = 'd 4 ;localparam SCND_MISS = 'd 5 ;localparam STREAM = 'd 6 ;localparam STALL_SCND_MISS = 'd 7 ;localparam DUPL_MISS_WAIT = 'd 8 ;localparam PRE_CRIT_BYP = 'd 9 ;    miss_state_t miss_state, miss_nxtstate;

    eh2_perr_state_t  perr_nxtstate;

   eh2_err_stop_state_t  err_stop_nxtstate;
   reg   err_stop_state_en ;
   reg   err_stop_fetch ;
   wire   ifu_bp_hit_taken_q_f2 ;
   wire   fetch_req_icache_tid_f2 ;
   wire   fetch_req_iccm_tid_f2 ;

   wire [pt.ICACHE_STATUS_BITS-1:0]             way_status_mb_in;
   wire [pt.ICACHE_NUM_WAYS-1:0]                tagv_mb_in;
   wire           ifu_wr_cumulative_err;
   wire           ifu_wr_data_comb_err ;
   reg           ifu_wr_data_comb_err_ff;
   wire           scnd_miss_index_match ;
   wire           ic_miss_under_miss_f2;
   wire           ic_ignore_2nd_miss_f2;
wire [31:1] imb_in;
reg [31:1] imb_ff;
wire [31:pt.ICACHE_BEAT_ADDR_HI+1] miss_addr_in;
wire [31:pt.ICACHE_BEAT_ADDR_HI+1] miss_addr;
   wire           miss_wrap_f2 ;
   reg           ifc_fetch_req_f2_raw;
   wire           ifc_fetch_req_qual_f1 ;
   wire           reset_beat_cnt  ;
   wire [pt.ICACHE_BEAT_BITS-1:0]      req_addr_count ;
   wire [pt.ICACHE_BEAT_ADDR_HI:3]     ic_req_addr_bits_hi_3 ;
   wire [pt.ICACHE_BEAT_ADDR_HI:3]     ic_wr_addr_bits_hi_3 ;
   wire           crit_wd_byp_ok_ff ;
   wire   [79:0]  ic_byp_data_only_pre_new;
   wire           fetch_f1_f2_c1_clken ;
   wire           sel_mb_addr ;
   wire           sel_mb_status_addr ;
   reg           sel_mb_addr_ff ;
   wire           ic_iccm_hit_f2;
   reg           ic_act_miss_f2_delayed;
   wire           ic_act_miss_f2_raw;
   wire           bus_ifu_wr_data_error;
   wire         bus_ifu_wr_data_error_ff;
   wire         last_data_recieved_in ;
   reg         last_data_recieved_ff ;
   wire [pt.ICACHE_NUM_BEATS-1:0]    write_fill_data;
   reg [pt.ICACHE_NUM_BEATS-1:0]    wr_data_c1_clk;
   wire [pt.ICACHE_NUM_BEATS-1:0]    ic_miss_buff_data_valid_in;
   wire [pt.ICACHE_NUM_BEATS-1:0]    ic_miss_buff_data_valid;
   wire [pt.ICACHE_NUM_BEATS-1:0]    ic_miss_buff_data_error_in;
   wire [pt.ICACHE_NUM_BEATS-1:0]    ic_miss_buff_data_error;
   wire [pt.ICACHE_BEAT_ADDR_HI:1]   byp_fetch_index;
   wire [pt.ICACHE_BEAT_ADDR_HI:2]   byp_fetch_index_0;
   wire [pt.ICACHE_BEAT_ADDR_HI:2]   byp_fetch_index_1;
   wire [pt.ICACHE_BEAT_ADDR_HI:3]   byp_fetch_index_inc;
   wire [pt.ICACHE_BEAT_ADDR_HI:2]   byp_fetch_index_inc_0;
   wire [pt.ICACHE_BEAT_ADDR_HI:2]   byp_fetch_index_inc_1;
   wire          miss_buff_hit_unq_f2 ;
   wire          stream_hit_f2 ;
   wire          stream_miss_f2 ;
   wire          stream_eol_f2 ;
   wire          crit_byp_hit_f2 ;

   wire [pt.IFU_BUS_TAG-2:0] other_tag ;
   reg [(2*pt.ICACHE_NUM_BEATS)-1:0] [31:0] ic_miss_buff_data;
   reg        scnd_miss_req_q;
   wire        scnd_miss_req_in;
   reg                                dma_sb_err_state_ff;
   reg                                perr_state_en;
   reg                                miss_state_en;
   reg        busclk_reset;
   wire        bus_inc_data_beat_cnt     ;
   wire        bus_reset_data_beat_cnt   ;
   wire        bus_hold_data_beat_cnt    ;

   wire        bus_inc_cmd_beat_cnt     ;
   wire        bus_reset_cmd_beat_cnt_0   ;
   wire        bus_reset_cmd_beat_cnt_secondlast   ;
   wire        bus_hold_cmd_beat_cnt    ;
   wire        bus_cmd_beat_en;

   wire [pt.ICACHE_BEAT_BITS-1:0]  bus_new_data_beat_count  ;
   reg [pt.ICACHE_BEAT_BITS-1:0]  bus_data_beat_count      ;

   wire [pt.ICACHE_BEAT_BITS-1:0]  bus_new_cmd_beat_count  ;

   wire        bus_inc_rd_addr_cnt  ;
   wire        bus_set_rd_addr_cnt  ;
   reg        bus_reset_rd_addr_cnt;
   wire        bus_hold_rd_addr_cnt ;

   wire [pt.ICACHE_BEAT_BITS-1:0]  bus_new_rd_addr_count;
   wire   second_half_available ;
   wire   write_ic_16_bytes ;
   wire   ic_miss_under_miss_killf1_f2;
   wire           bus_ifu_wr_en     ;
   wire           bus_ifu_wr_en_ff  ;
   reg           uncacheable_miss_ff;
   reg           ic_crit_wd_rdy_new_ff;
   reg [pt.ICACHE_BEAT_BITS-1:0]                   bus_cmd_beat_count ;
   reg           miss_done_other_ff;
   wire           uncacheable_miss_in ;
   wire           bus_cmd_req_in ;
   wire    sel_hold_imb     ;

   wire         sel_hold_imb_scnd;
   wire  [31:1] imb_scnd_in;
   reg  [31:1] imb_scnd_ff;
   wire         uncacheable_miss_scnd_in ;
   reg         uncacheable_miss_scnd_ff ;

   wire  [pt.ICACHE_NUM_WAYS-1:0] tagv_mb_scnd_in;
   reg  [pt.ICACHE_NUM_WAYS-1:0] tagv_mb_scnd_ff;

   wire  [pt.ICACHE_STATUS_BITS-1:0] way_status_mb_scnd_in;
   reg  [pt.ICACHE_STATUS_BITS-1:0] way_status_mb_scnd_ff;

   wire [63:0]       ic_miss_buff_data_in;
   wire   [pt.ICACHE_BEAT_ADDR_HI:1]  bypass_index;
   wire   [pt.ICACHE_BEAT_ADDR_HI:3]  bypass_index_5_3_inc;
   wire   bypass_data_ready_in;
   wire   ic_crit_wd_rdy_new_in;
   reg                                               perr_sb_write_status   ;
   reg [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]   perr_ic_index_ff0;
   wire                                               ifc_bus_ic_req_ff_in;
   reg                                               bus_cmd_req_hold ;
   wire                                               mb_ff_en;
   wire [1:0]                                         ifu_fetch_val_q_f2;
   reg                                               busclk_force ;
   wire                                               ifc_fetch_req_tid_q_f1;
   wire                                               ifc_fetch_req_tid_q_f1_raw;


   assign ifc_fetch_req_tid_q_f1      =   ifc_fetch_req_f1     & fetch_tid_f1 ;
   assign ifc_fetch_req_tid_q_f1_raw  =   ifc_fetch_req_f1_raw & fetch_tid_f1 ;

   assign fetch_f1_f2_c1_clken  = ifc_fetch_req_tid_q_f1_raw | ifc_fetch_req_f2 | miss_pending | exu_flush_final | scnd_miss_req | reset_all_tags;
      reg                                             fetch_f1_f2_c1_clk;
   rvclkhdr fetch_f1_f2_c1_cgc   ( .en(fetch_f1_f2_c1_clken),     .l1clk(fetch_f1_f2_c1_clk), .* );
   assign ifu_bp_hit_taken_q_f2 = ifu_bp_kill_next_f2 & ic_hit_f2 ;


   assign miss_done      = ( bus_ifu_wr_en_ff  & last_beat) |   (miss_state ==  DUPL_MISS_WAIT);      assign address_match  = (miss_address_other[pt.ICACHE_INDEX_HI : pt.ICACHE_TAG_INDEX_LO] == imb_ff[pt.ICACHE_INDEX_HI : pt.ICACHE_TAG_INDEX_LO] ) & ((miss_state != IDLE) | ic_act_miss_f2_raw)  &  ~uncacheable_miss_ff ;

                     always @* begin : MISS_SM
      miss_nxtstate   = IDLE;
      miss_state_en   = 1'b0;
      case (miss_state)
         IDLE: begin : idle
                  miss_nxtstate = ( exu_flush_final                                  ) ? HIT_U_MISS :
                                  ( address_match_other & ~uncacheable_miss_ff) ? DUPL_MISS_WAIT : (scnd_miss_req_other) ? PRE_CRIT_BYP : CRIT_BYP_OK ;
                  miss_state_en = ic_act_miss_f2_raw  & ~dec_tlu_force_halt;
         end
         PRE_CRIT_BYP : begin : pre_crit_byp
                  miss_nxtstate =  dec_tlu_force_halt ? IDLE : exu_flush_final ? HIT_U_MISS : CRIT_BYP_OK ;
                  miss_state_en =  1'b1;
         end
         DUPL_MISS_WAIT: begin : dupl_miss_wait
                  miss_nxtstate =  IDLE ;
                  miss_state_en =  exu_flush_final | miss_done_other | miss_done_other_ff | dec_tlu_force_halt;
         end
         CRIT_BYP_OK: begin : crit_byp_ok
                  miss_nxtstate = (dec_tlu_force_halt ) ?                                                                               IDLE :
                                  ( ic_byp_hit_f2 &  (last_data_recieved_ff | (bus_ifu_wr_en_ff & last_beat)) &  uncacheable_miss_ff) ? IDLE :
                                  ( ic_byp_hit_f2 &  ~last_data_recieved_ff                                   &  uncacheable_miss_ff) ? MISS_WAIT :
                                  (~ic_byp_hit_f2 &  ~exu_flush_final &  (bus_ifu_wr_en_ff & last_beat)       &  uncacheable_miss_ff) ? CRIT_WRD_RDY :
                                  (                                      (bus_ifu_wr_en_ff & last_beat)       & ~uncacheable_miss_ff) ? IDLE :
                                  ( ic_byp_hit_f2  &  ~exu_flush_final & ~(bus_ifu_wr_en_ff & last_beat)      & ~ifu_bp_hit_taken_q_f2   & ~uncacheable_miss_ff) ? STREAM :
                                  ( bus_ifu_wr_en_ff &  ~exu_flush_final & ~(bus_ifu_wr_en_ff & last_beat)    & ~ifu_bp_hit_taken_q_f2   & ~uncacheable_miss_ff) ? STREAM :
                                  (~ic_byp_hit_f2  &  ~exu_flush_final &  (bus_ifu_wr_en_ff & last_beat)      & ~uncacheable_miss_ff) ? IDLE :
                                  ( (exu_flush_final | ifu_bp_hit_taken_q_f2)  & ~(bus_ifu_wr_en_ff & last_beat)                      ) ? HIT_U_MISS : IDLE;
                  miss_state_en =  dec_tlu_force_halt | exu_flush_final | ic_byp_hit_f2 | ifu_bp_hit_taken_q_f2 | (bus_ifu_wr_en_ff & last_beat) | (bus_ifu_wr_en_ff & ~uncacheable_miss_ff)  ;
         end
         CRIT_WRD_RDY: begin : crit_wrd_rdy
                  miss_nxtstate =  IDLE ;
                  miss_state_en =  exu_flush_final | flush_final_f2 | ic_byp_hit_f2 | dec_tlu_force_halt   ;
         end
         STREAM: begin : stream
                  miss_nxtstate =  ((exu_flush_final | ifu_bp_hit_taken_q_f2  | stream_eol_f2 ) & ~(bus_ifu_wr_en_ff & last_beat) & ~dec_tlu_force_halt) ? HIT_U_MISS  : IDLE ;
                  miss_state_en =    exu_flush_final | ifu_bp_hit_taken_q_f2  | stream_eol_f2   |  (bus_ifu_wr_en_ff & last_beat) | dec_tlu_force_halt ;
         end
         MISS_WAIT: begin : miss_wait
                  miss_nxtstate =  (exu_flush_final & ~(bus_ifu_wr_en_ff & last_beat) & ~dec_tlu_force_halt) ? HIT_U_MISS  : IDLE ;
                  miss_state_en =   exu_flush_final | (bus_ifu_wr_en_ff & last_beat) | dec_tlu_force_halt ;
         end
         HIT_U_MISS: begin : hit_u_miss
                  miss_nxtstate =  ic_miss_under_miss_f2 & ~(bus_ifu_wr_en_ff & last_beat) & ~dec_tlu_force_halt & ~address_match_other ? SCND_MISS :
                                   ic_miss_under_miss_f2 & ~(bus_ifu_wr_en_ff & last_beat) & ~dec_tlu_force_halt &  address_match_other ? STALL_SCND_MISS :
                                   ic_ignore_2nd_miss_f2 & ~(bus_ifu_wr_en_ff & last_beat) & ~dec_tlu_force_halt ? STALL_SCND_MISS : IDLE  ;
                  miss_state_en = (bus_ifu_wr_en_ff & last_beat) | ic_miss_under_miss_f2 | ic_ignore_2nd_miss_f2 | dec_tlu_force_halt;
         end
         SCND_MISS: begin : scnd_miss              miss_nxtstate   =  dec_tlu_force_halt ? IDLE  :
                               exu_flush_final ?  ((bus_ifu_wr_en_ff & last_beat) ? IDLE : HIT_U_MISS) : address_match_other ? DUPL_MISS_WAIT : CRIT_BYP_OK;
                  miss_state_en   = (bus_ifu_wr_en_ff & last_beat) | exu_flush_final | dec_tlu_force_halt;
         end
         STALL_SCND_MISS: begin : stall_scnd_miss
                  miss_nxtstate   = dec_tlu_force_halt ? IDLE :
                                    exu_flush_final ?  ((bus_ifu_wr_en_ff & last_beat) ? IDLE : HIT_U_MISS) : IDLE;
                  miss_state_en   = (bus_ifu_wr_en_ff & last_beat) | exu_flush_final | dec_tlu_force_halt;
         end
default: begin : def_case
                  miss_nxtstate   = IDLE;

                  miss_state_en   = 1'b0;
         end
      endcase
   end

   rvdffs #(($bits(miss_state_t))) miss_state_ff (.clk(free_clk), .din(miss_nxtstate), .dout({miss_state}), .en(miss_state_en),   .*);


   assign miss_pending       =  (miss_state != IDLE) ;
   assign crit_wd_byp_ok_ff  =  (miss_state == CRIT_BYP_OK) | ((miss_state == CRIT_WRD_RDY) & ~flush_final_f2);
   assign sel_hold_imb       =  (miss_pending & ~(bus_ifu_wr_en_ff & last_beat) & ~((miss_state == CRIT_WRD_RDY) & exu_flush_final) &
                              ~((miss_state == CRIT_WRD_RDY) & crit_byp_hit_f2) )| ic_act_miss_f2_raw |
                                (miss_pending & (miss_nxtstate == CRIT_WRD_RDY)) ;



   assign sel_hold_imb_scnd                                =((miss_state == SCND_MISS) | ic_miss_under_miss_f2) & ~(exu_flush_final & ~(bus_ifu_wr_en_ff & last_beat)) ;
   assign way_status_mb_scnd_in[pt.ICACHE_STATUS_BITS-1:0] = (miss_state == SCND_MISS) ? way_status_mb_scnd_ff[pt.ICACHE_STATUS_BITS-1:0] : {way_status[pt.ICACHE_STATUS_BITS-1:0]} ;
   assign tagv_mb_scnd_in[pt.ICACHE_NUM_WAYS-1:0]          = (miss_state == SCND_MISS) ? (tagv_mb_scnd_ff[pt.ICACHE_NUM_WAYS-1:0] &  {pt.ICACHE_NUM_WAYS{~reset_all_tags}})        : ({ic_tag_valid[pt.ICACHE_NUM_WAYS-1:0]} & {pt.ICACHE_NUM_WAYS{~reset_all_tags}});
   assign uncacheable_miss_scnd_in   = sel_hold_imb_scnd ? uncacheable_miss_scnd_ff : ifc_fetch_uncacheable_f1 ;

   rvdff #(1)  unc_miss_scnd_ff    (.*, .clk(fetch_f1_f2_c1_clk), .din (uncacheable_miss_scnd_in), .dout(uncacheable_miss_scnd_ff));
   rvdff #(31) imb_f2_scnd_ff       (.*, .clk(fetch_f1_f2_c1_clk), .din ({imb_scnd_in[31:1]}), .dout({imb_scnd_ff[31:1]}));
   rvdff #(pt.ICACHE_STATUS_BITS)  mb_rep_wayf2_scnd_ff (.*, .clk(fetch_f1_f2_c1_clk), .din ({way_status_mb_scnd_in[pt.ICACHE_STATUS_BITS-1:0]}), .dout({way_status_mb_scnd_ff[pt.ICACHE_STATUS_BITS-1:0]}));
   rvdff #(pt.ICACHE_NUM_WAYS)     mb_tagv_scnd_ff      (.*, .clk(fetch_f1_f2_c1_clk), .din ({tagv_mb_scnd_in[pt.ICACHE_NUM_WAYS-1:0]}), .dout({tagv_mb_scnd_ff[pt.ICACHE_NUM_WAYS-1:0]}));


   assign  fetch_req_icache_tid_f2  = fetch_req_icache_f2 & fetch_tid_f2 ;
   assign  fetch_req_iccm_tid_f2    = fetch_req_iccm_f2   & fetch_tid_f2 ;
   assign ifu_fetch_val_q_f2[1:0]   = ifu_fetch_val[1:0] & {2{fetch_tid_f2}} ;

   assign ic_req_addr_bits_hi_3[pt.ICACHE_BEAT_ADDR_HI:3] = req_addr_count[pt.ICACHE_BEAT_BITS-1:0] ;
   assign ic_wr_addr_bits_hi_3[pt.ICACHE_BEAT_ADDR_HI:3]  = ifu_bus_rid_ff[pt.ICACHE_BEAT_BITS-1:0] & {pt.ICACHE_BEAT_BITS{bus_ifu_wr_en_ff}};

   assign ic_iccm_hit_f2        = fetch_req_iccm_tid_f2  &  (~miss_pending | (miss_state==HIT_U_MISS) | (miss_state==STREAM)) ;
   assign ic_byp_hit_f2         = (crit_byp_hit_f2 | stream_hit_f2)  & fetch_req_icache_tid_f2 &  miss_pending  ;
   assign ic_act_hit_f2         = (|ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0]) & fetch_req_icache_tid_f2 & ~reset_all_tags & (~miss_pending | (miss_state==HIT_U_MISS)) & ~sel_mb_addr_ff ;
   assign ic_act_miss_f2_raw    = (((~(|ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0]) | reset_all_tags) & fetch_req_icache_tid_f2 & ~miss_pending & ~ifc_region_acc_fault_f2) | scnd_miss_req)  ;
   assign ic_act_miss_f2        = ic_act_miss_f2_raw & (miss_nxtstate != DUPL_MISS_WAIT);
   assign ic_miss_under_miss_f2 = (~(|ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0]) | reset_all_tags) & fetch_req_icache_tid_f2 & (miss_state == HIT_U_MISS) &
                                   (imb_ff[31:pt.ICACHE_TAG_INDEX_LO] != ifu_fetch_addr_int_f2[31:pt.ICACHE_TAG_INDEX_LO]) & ~uncacheable_miss_ff & ~sel_mb_addr_ff & ~ifc_region_acc_fault_f2 ;

  assign ic_ignore_2nd_miss_f2  = (~(|ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0]) | reset_all_tags) & fetch_req_icache_tid_f2 & (miss_state == HIT_U_MISS) &
                                   ((imb_ff[31:pt.ICACHE_TAG_INDEX_LO] == ifu_fetch_addr_int_f2[31:pt.ICACHE_TAG_INDEX_LO])  |   uncacheable_miss_ff) ;


   assign ic_miss_under_miss_killf1_f2 = (~(|ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0]) | reset_all_tags | sel_mb_addr_ff ) & fetch_req_icache_tid_f2 & (miss_state == HIT_U_MISS) ;

   assign scnd_miss_index_match  =  (imb_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO] == imb_scnd_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]) & scnd_miss_req & ~ifu_wr_cumulative_err_data;
   assign way_status_mb_in[pt.ICACHE_STATUS_BITS-1:0] = (scnd_miss_req & ~scnd_miss_index_match) ? way_status_mb_scnd_ff[pt.ICACHE_STATUS_BITS-1:0] :
                                                        (scnd_miss_req &  scnd_miss_index_match) ? way_status_rep_new[pt.ICACHE_STATUS_BITS-1:0] :
                                                         miss_pending                            ? way_status_mb_ff[pt.ICACHE_STATUS_BITS-1:0] :
                                                                                                  {way_status[pt.ICACHE_STATUS_BITS-1:0]} ;
   assign tagv_mb_in[pt.ICACHE_NUM_WAYS-1:0]          = scnd_miss_req ? ((tagv_mb_scnd_ff[pt.ICACHE_NUM_WAYS-1:0] & {pt.ICACHE_NUM_WAYS{~reset_all_tags}}) | ({pt.ICACHE_NUM_WAYS {scnd_miss_index_match}} & replace_way_mb_any[pt.ICACHE_NUM_WAYS-1:0] &  {pt.ICACHE_NUM_WAYS{~reset_all_tags}})) :
                                                         miss_pending ? tagv_mb_ff[pt.ICACHE_NUM_WAYS-1:0]  : ({ic_tag_valid[pt.ICACHE_NUM_WAYS-1:0]} & {pt.ICACHE_NUM_WAYS{~reset_all_tags}}) ;

   assign uncacheable_miss_in   = scnd_miss_req ? uncacheable_miss_scnd_ff : sel_hold_imb ? uncacheable_miss_ff : ifc_fetch_uncacheable_f1 ;
   assign imb_in[31:1]          = scnd_miss_req ? imb_scnd_ff[31:1]        : sel_hold_imb ? imb_ff[31:1] : {fetch_addr_f1[31:1]} ;
   assign imb_scnd_in[31:1]     = sel_hold_imb_scnd ? imb_scnd_ff[31:1] : {fetch_addr_f1[31:1]} ;
   assign mb_ff_en              = fetch_tid_f1 | scnd_miss_req;

   assign reset_ic_in           = miss_pending  &  ~scnd_miss_req_q & (reset_all_tags |  reset_ic_ff) ;

   rvdff #(1)  act_hit_ff (.*, .clk(free_clk), .din (ic_act_hit_f2), .dout(ic_act_hit_f2_ff));
   rvdff #(1)  reset_ic_f2 (.*, .clk(free_clk), .din (reset_ic_in), .dout(reset_ic_ff));
   rvdff #(1)  miss_dn_ff (.*, .clk(free_clk), .din (miss_done_other), .dout(miss_done_other_ff));


   rvdff #(1)  unc_miss_ff      (.*, .clk(fetch_f1_f2_c1_clk), .din (uncacheable_miss_in), .dout(uncacheable_miss_ff));
   rvdffs #(31) imb_f2_ff       (.*, .clk(fetch_f1_f2_c1_clk), .en(mb_ff_en), .din ({imb_in[31:1]}), .dout({imb_ff[31:1]}));   // update the miss buffer only when my thread misses


   assign miss_addr_in[31:pt.ICACHE_BEAT_ADDR_HI+1]      = (~miss_pending                    ) ? imb_ff[31:pt.ICACHE_BEAT_ADDR_HI+1] :
                                                           (                scnd_miss_req_q  ) ? imb_scnd_ff[31:pt.ICACHE_BEAT_ADDR_HI+1] : miss_addr[31:pt.ICACHE_BEAT_ADDR_HI+1] ;

   rvdff #(31-pt.ICACHE_BEAT_ADDR_HI) miss_f_ff       (.*, .clk(busclk_reset), .din ({miss_addr_in[31:pt.ICACHE_BEAT_ADDR_HI+1]}), .dout({miss_addr[31:pt.ICACHE_BEAT_ADDR_HI+1]}));





   rvdff #(pt.ICACHE_STATUS_BITS)  mb_rep_wayf2_ff (.*, .clk(fetch_f1_f2_c1_clk), .din ({way_status_mb_in[pt.ICACHE_STATUS_BITS-1:0]}), .dout({way_status_mb_ff[pt.ICACHE_STATUS_BITS-1:0]}));

   rvdff #(pt.ICACHE_NUM_WAYS)  mb_tagv_ff      (.*, .clk(fetch_f1_f2_c1_clk), .din ({tagv_mb_in[pt.ICACHE_NUM_WAYS-1:0]}), .dout({tagv_mb_ff[pt.ICACHE_NUM_WAYS-1:0]}));


   assign ifc_fetch_req_qual_f1  = ifc_fetch_req_tid_q_f1  & ~((miss_state == CRIT_WRD_RDY) & flush_final_f2) & ~stream_miss_f2 & ~ic_miss_under_miss_killf1_f2 ;
   rvdff #(1) fetch_req_f2_ff  (.*, .clk(active_clk),  .din(ifc_fetch_req_qual_f1), .dout(ifc_fetch_req_f2_raw));

   assign ifc_fetch_req_f2       = ifc_fetch_req_f2_raw & ~exu_flush_final ;

   wire ifu_miss_state_pre_crit;
   assign ifu_ic_mb_empty          = (((miss_state == HIT_U_MISS) | (miss_state == STREAM)) & ~(bus_ifu_wr_en_ff & last_beat)) |  ~miss_pending ;
   assign ifu_miss_state_idle      = (miss_state == IDLE) ;
   assign ifu_miss_state_pre_crit  = (miss_state == PRE_CRIT_BYP) ;
   rvdff #(1) precrit_byp_ff         (.*, .clk(free_clk),  .din (ifu_miss_state_pre_crit), .dout(ifu_miss_state_pre_crit_ff));

   assign sel_mb_addr  = ((miss_pending & write_ic_16_bytes & ~uncacheable_miss_ff) | reset_tag_valid_for_miss) ;
   assign ifu_ic_rw_int_addr[31:1] = ({31{ sel_mb_addr}}  &  {imb_ff[31:pt.ICACHE_BEAT_ADDR_HI+1] , ic_wr_addr_bits_hi_3[pt.ICACHE_BEAT_ADDR_HI:3] , imb_ff[2:1]})  |
                                     ({31{~sel_mb_addr}}  &  fetch_addr_f1[31:1] )   ;

   assign sel_mb_status_addr  = ((miss_pending & write_ic_16_bytes & ~uncacheable_miss_ff & last_beat & bus_ifu_wr_en_ff_q) | reset_tag_valid_for_miss) ;
   assign ifu_status_wr_addr[31:1] = {imb_ff[31:pt.ICACHE_BEAT_ADDR_HI+1], ic_wr_addr_bits_hi_3[pt.ICACHE_BEAT_ADDR_HI:3], imb_ff[2:1]};
   assign ifu_status_up_addr[31:1] = ifu_fetch_addr_int_f2[31:1];




   assign ifu_ic_req_addr_f2[31:3]  = {miss_addr[31:pt.ICACHE_BEAT_ADDR_HI+1] , ic_req_addr_bits_hi_3[pt.ICACHE_BEAT_ADDR_HI:3] };
  assign  miss_address[31:1]  = (((miss_state==HIT_U_MISS)  & ~(bus_ifu_wr_en_ff & last_beat))) | (miss_state == SCND_MISS) ? imb_scnd_ff[31:1] : imb_ff[31:1] ;

  rvdff #(1) sel_mb_ff (.*, .clk(free_clk),  .din (sel_mb_addr), .dout(sel_mb_addr_ff));

     assign ic_miss_buff_data_in[63:0] = ifu_bus_rsp_rdata[63:0];

     for (genvar i=0; i<pt.ICACHE_NUM_BEATS; i++) begin :  wr_flop
       assign write_fill_data[i]        =   bus_ifu_wr_en & (  (pt.IFU_BUS_TAG-1)'(i)  == ifu_bus_rsp_tag[pt.IFU_BUS_TAG-2:0]);

       rvclkhdr data_c1_cgc  ( .en(write_fill_data[i]),    .l1clk(wr_data_c1_clk[i]), .* );
       rvdff #(32) byp_data_0_ff (.*,
                 .clk (wr_data_c1_clk[i]),
                 .din (ic_miss_buff_data_in[31:0]),
                 .dout(ic_miss_buff_data[i*2][31:0]));

       rvdff #(32) byp_data_1_ff (.*,
                 .clk (wr_data_c1_clk[i]),
                 .din (ic_miss_buff_data_in[63:32]),
                 .dout(ic_miss_buff_data[i*2+1][31:0]));

        assign ic_miss_buff_data_valid_in[i]  = write_fill_data[i] ? 1'b1  : (ic_miss_buff_data_valid[i]  & ~ic_act_miss_f2) ;
        rvdff #(1) byp_data_valid_ff (.*,
                  .clk (free_clk),
                  .din (ic_miss_buff_data_valid_in[i]),
                  .dout(ic_miss_buff_data_valid[i]));

        assign ic_miss_buff_data_error_in[i]  = write_fill_data[i] ? bus_ifu_wr_data_error  : (ic_miss_buff_data_error[i]  & ~ic_act_miss_f2) ;
        rvdff #(1) byp_data_error_ff (.*,
                  .clk (free_clk),
                  .din (ic_miss_buff_data_error_in[i] ),
                  .dout(ic_miss_buff_data_error[i]));
     end


   assign bypass_index[pt.ICACHE_BEAT_ADDR_HI:1]         = imb_ff[pt.ICACHE_BEAT_ADDR_HI:1] ;
   assign bypass_index_5_3_inc[pt.ICACHE_BEAT_ADDR_HI:3] = bypass_index[pt.ICACHE_BEAT_ADDR_HI:3] + 1 ;

   assign bypass_data_ready_in = ((ic_miss_buff_data_valid_in[bypass_index[pt.ICACHE_BEAT_ADDR_HI:3]]                                                    & (bypass_index[2:1] == 2'b00)))   |
                                 ((ic_miss_buff_data_valid_in[bypass_index[pt.ICACHE_BEAT_ADDR_HI:3]] & ic_miss_buff_data_valid_in[bypass_index_5_3_inc[pt.ICACHE_BEAT_ADDR_HI:3]] & (bypass_index[2:1] != 2'b00))) |
                                 ((ic_miss_buff_data_valid_in[bypass_index[pt.ICACHE_BEAT_ADDR_HI:3]] & (bypass_index[pt.ICACHE_BEAT_ADDR_HI:3] == {pt.ICACHE_BEAT_ADDR_HI{1'b1}})))   ;



   assign    ic_crit_wd_rdy_new_in = ( bypass_data_ready_in & crit_wd_byp_ok_ff   &  uncacheable_miss_ff &  ~exu_flush_final ) |
                                     ( (miss_state==STREAM) & crit_wd_byp_ok_ff   & ~uncacheable_miss_ff &  ~exu_flush_final & ~ifu_bp_hit_taken_q_f2) |
                                     (ic_crit_wd_rdy_new_ff & ~fetch_req_icache_tid_f2 & crit_wd_byp_ok_ff    &  ~exu_flush_final) ;

   rvdff #(1)           crit_wd_new_ff      (.*, .clk(free_clk),  .din(ic_crit_wd_rdy_new_in),   .dout(ic_crit_wd_rdy_new_ff));

  assign byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:1]          =    ifu_fetch_addr_int_f2[pt.ICACHE_BEAT_ADDR_HI:1]       ;
  assign byp_fetch_index_0[pt.ICACHE_BEAT_ADDR_HI:2]        =   {ifu_fetch_addr_int_f2[pt.ICACHE_BEAT_ADDR_HI:3],1'b0} ;
  assign byp_fetch_index_1[pt.ICACHE_BEAT_ADDR_HI:2]        =   {ifu_fetch_addr_int_f2[pt.ICACHE_BEAT_ADDR_HI:3],1'b1} ;
  assign byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3]      =    ifu_fetch_addr_int_f2[pt.ICACHE_BEAT_ADDR_HI:3]+1'b1 ;
  assign byp_fetch_index_inc_0[pt.ICACHE_BEAT_ADDR_HI:2]    =   {byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3], 1'b0} ;
  assign byp_fetch_index_inc_1[pt.ICACHE_BEAT_ADDR_HI:2]    =   {byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3], 1'b1} ;

  assign  ifu_byp_data_err_new = (~ifu_fetch_addr_int_f2[2] &   (ic_miss_buff_data_error[byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3]] | ic_miss_buff_data_error[byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3]] )) |
                                 ( ifu_fetch_addr_int_f2[2] &   (ic_miss_buff_data_error[byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3]] | ic_miss_buff_data_error[byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3]] )) ;

  assign ic_byp_data_only_pre_new[79:0] =  ({80{~ifu_fetch_addr_int_f2[2]}} &   {ic_miss_buff_data[byp_fetch_index_inc_0][15:0],ic_miss_buff_data[byp_fetch_index_1][31:0]     , ic_miss_buff_data[byp_fetch_index_0][31:0]}) |
                                           ({80{ ifu_fetch_addr_int_f2[2]}} &   {ic_miss_buff_data[byp_fetch_index_inc_1][15:0],ic_miss_buff_data[byp_fetch_index_inc_0][31:0] , ic_miss_buff_data[byp_fetch_index_1][31:0]}) ;

  assign ic_byp_data_only_new[79:0]      = ~ifu_fetch_addr_int_f2[1] ? {ic_byp_data_only_pre_new[79:0]} :
                                                                      {16'b0,ic_byp_data_only_pre_new[79:16]} ;

  assign miss_wrap_f2      =  (imb_ff[pt.ICACHE_TAG_INDEX_LO] != ifu_fetch_addr_int_f2[pt.ICACHE_TAG_INDEX_LO] ) ;

  assign miss_buff_hit_unq_f2  = ((ic_miss_buff_data_valid[byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3]]                                                     & (byp_fetch_index[2:1] == 2'b00)) |
                                 ((ic_miss_buff_data_valid[byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3]] & ic_miss_buff_data_valid[byp_fetch_index_inc[pt.ICACHE_BEAT_ADDR_HI:3]] & (byp_fetch_index[2:1]!= 2'b00))) |
                                 ((ic_miss_buff_data_valid[byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3]] & (byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:3] == {pt.ICACHE_BEAT_BITS{1'b1}})))) & fetch_tid_f2   ;

  reg  previous_state_is_stream;
  rvdff  #((1))  prev_st_strm_ff  (.clk(active_clk), .din((miss_state==STREAM)),   .dout(previous_state_is_stream),   .*);
  assign stream_hit_f2     =  (miss_buff_hit_unq_f2 & ~miss_wrap_f2 ) & ((miss_state==STREAM) | ((miss_state==IDLE) & previous_state_is_stream)) ;
  assign stream_miss_f2    = ~(miss_buff_hit_unq_f2 & ~miss_wrap_f2 ) & ((miss_state==STREAM) | ((miss_state==IDLE) & previous_state_is_stream)) & ifc_fetch_req_f2 ;
  assign stream_eol_f2     =  (byp_fetch_index[pt.ICACHE_BEAT_ADDR_HI:2] == {pt.ICACHE_BEAT_BITS+1{1'b1}}) & ifc_fetch_req_f2 & stream_hit_f2;

  assign crit_byp_hit_f2   =  (miss_buff_hit_unq_f2 ) & ((miss_state == CRIT_WRD_RDY) | (miss_state==CRIT_BYP_OK)) ;


assign other_tag[pt.IFU_BUS_TAG-2:0] = {ifu_bus_rid_ff[pt.IFU_BUS_TAG-2:1] , ~ifu_bus_rid_ff[0] } ;
assign second_half_available      = ic_miss_buff_data_valid[other_tag] ;
assign write_ic_16_bytes          = second_half_available & bus_ifu_wr_en_ff ;
assign ic_miss_buff_half[63:0]    = {ic_miss_buff_data[{other_tag,1'b1}],ic_miss_buff_data[{other_tag,1'b0}] } ;


   rvdff  #(pt.ICACHE_INDEX_HI-pt.ICACHE_TAG_INDEX_LO+1) perr_dat_ff0    (.clk(active_clk), .din(ifu_ic_rw_int_addr_ff[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]), .dout(perr_ic_index_ff0[pt.ICACHE_INDEX_HI : pt.ICACHE_TAG_INDEX_LO]),  .*);
   rvdffs #(pt.ICACHE_INDEX_HI-pt.ICACHE_TAG_INDEX_LO+1) perr_dat_ff1    (.clk(active_clk), .din(perr_ic_index_ff0    [pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]), .dout(perr_ic_index_ff[pt.ICACHE_INDEX_HI : pt.ICACHE_TAG_INDEX_LO]), .en(perr_sb_write_status),  .*);





   assign perr_err_inv_way[pt.ICACHE_NUM_WAYS-1:0]   =  {pt.ICACHE_NUM_WAYS{perr_sel_invalidate}} ;
   assign iccm_correct_ecc     = (perr_state == ECC_CORR);
   assign dma_sb_err_state     = (perr_state == DMA_SB_ERR);
   assign perr_state_idle      = (perr_state == ERR_IDLE);
   assign perr_state_wff       = (perr_state == IC_WFF);
   assign iccm_buf_correct_ecc = iccm_correct_ecc & ~dma_sb_err_state_ff;
    rvdff  #((1))  dma_sb_err_ff  (.clk(active_clk), .din(dma_sb_err_state),   .dout(dma_sb_err_state_ff),   .*);

                     always @* begin  : ERROR_SM
      perr_nxtstate            = ERR_IDLE;
      perr_state_en            = 1'b0;
      perr_sb_write_status     = 1'b0;
      perr_sel_invalidate      = 1'b0;

      case (perr_state)
         ERR_IDLE: begin : err_idle
                  perr_nxtstate         =  iccm_dma_sb_error ? DMA_SB_ERR : (ic_error_start & ~exu_flush_final) ? IC_WFF : ECC_WFF;
                  perr_state_en         =  ((((iccm_error_start  & ~exu_flush_final) | iccm_dma_sb_error) & fetch_tid_f2)  | (ic_error_start & ~exu_flush_final))& ~dec_tlu_force_halt;
                  perr_sb_write_status  =  perr_state_en;
         end
         IC_WFF: begin : icache_wff                      perr_nxtstate       =  ERR_IDLE ;
                  perr_state_en       =  dec_tlu_flush_lower_wb | dec_tlu_force_halt;
                  perr_sel_invalidate =  (dec_tlu_flush_err_wb &  dec_tlu_flush_lower_wb);
         end
         ECC_WFF: begin : ecc_wff
                  perr_nxtstate       =  ((~dec_tlu_flush_err_wb &  dec_tlu_flush_lower_wb ) | dec_tlu_force_halt ) ? ERR_IDLE : ECC_CORR ;
                  perr_state_en       =  dec_tlu_flush_lower_wb | dec_tlu_force_halt;
         end
         DMA_SB_ERR : begin : dma_sb_ecc
                 perr_nxtstate       = dec_tlu_force_halt ? ERR_IDLE : ECC_CORR;
                 perr_state_en       = 1'b1;
         end
         ECC_CORR: begin : ecc_corr
                  perr_nxtstate       =  ERR_IDLE  ;
                  perr_state_en       =   1'b1   ;
         end : ecc_corr
          default: begin : def_case
                  perr_nxtstate            = ERR_IDLE;

                  perr_state_en            = 1'b0;
                  perr_sb_write_status     = 1'b0;
                  perr_sel_invalidate      = 1'b0;
         end
      endcase
   end
   rvdffs #(($bits(eh2_perr_state_t))) perr_state_ff (.clk(free_clk), .din(perr_nxtstate), .dout({perr_state}), .en(perr_state_en),   .*);

                  always @* begin  : ERROR_STOP_FETCH
      err_stop_nxtstate            = ERR_STOP_IDLE;
      err_stop_state_en            = 1'b0;
      err_stop_fetch               = 1'b0;
      iccm_correction_state        = 1'b0;
      iccm_corr_scnd_fetch         = 1'b0;

      case (err_stop_state)
         ERR_STOP_IDLE: begin : err_stop_idle
                  err_stop_nxtstate         =  ERR_FETCH1;
                  err_stop_state_en         =  dec_tlu_flush_err_wb & (perr_state == ECC_WFF) & ~dec_tlu_force_halt;
         end
         ERR_FETCH1: begin : err_fetch1                      err_stop_nxtstate       =  (dec_tlu_flush_lower_wb  | dec_tlu_i0_commit_cmt | iccm_rd_ecc_single_err | dec_tlu_force_halt) ? ERR_STOP_IDLE :
                                                                                                                ((ifu_fetch_val_q_f2[1:0] == 2'b11) | (ifu_fetch_val_q_f2[0] & two_byte_instr_f2))  ?  ERR_STOP_FETCH : ifu_fetch_val_q_f2[0] ? ERR_FETCH2 :  ERR_FETCH1;
                  err_stop_state_en       =   dec_tlu_flush_lower_wb  | dec_tlu_i0_commit_cmt | ifu_fetch_val_q_f2[0] | ifu_bp_hit_taken_q_f2 | dec_tlu_force_halt;
                  err_stop_fetch          =   ((ifu_fetch_val_q_f2[1:0] == 2'b11) | (ifu_fetch_val_q_f2[0] & two_byte_instr_f2)) & ~((exu_flush_final & ~dec_tlu_flush_err_wb) | dec_tlu_i0_commit_cmt);
                  iccm_correction_state   = 1'b1;
                  iccm_corr_scnd_fetch    = err_stop_state_en  & (err_stop_nxtstate  ==  ERR_FETCH2);
        end
         ERR_FETCH2: begin : err_fetch2                      err_stop_nxtstate       = (dec_tlu_flush_lower_wb | dec_tlu_i0_commit_cmt | iccm_rd_ecc_single_err | dec_tlu_force_halt) ? ERR_STOP_IDLE : ifu_fetch_val_q_f2[0] ?  ERR_STOP_FETCH : ERR_FETCH2;
                  err_stop_state_en       =  dec_tlu_flush_lower_wb | dec_tlu_i0_commit_cmt | ifu_fetch_val_q_f2[0]  | dec_tlu_force_halt;
                  err_stop_fetch          =  ifu_fetch_val_q_f2[0] & ~exu_flush_final & ~dec_tlu_i0_commit_cmt & ~dec_tlu_flush_lower_wb;
                  iccm_correction_state   = 1'b1;
                  iccm_corr_scnd_fetch    = 1'b1;
         end
         ERR_STOP_FETCH: begin : ecc_wff
                  err_stop_nxtstate       = ((dec_tlu_flush_lower_wb & ~dec_tlu_flush_err_wb) | dec_tlu_i0_commit_cmt | dec_tlu_force_halt | (dec_tlu_flush_err_wb & (perr_state == IC_WFF))) ? ERR_STOP_IDLE : dec_tlu_flush_err_wb ? ERR_FETCH1 : ERR_STOP_FETCH ;
                  err_stop_state_en       =  dec_tlu_flush_lower_wb  |  dec_tlu_i0_commit_cmt | dec_tlu_force_halt  ;
                  err_stop_fetch          = 1'b1;
                  iccm_correction_state   = 1'b1;

         end : ecc_wff
          default: begin : def_case
                  err_stop_nxtstate       = ERR_STOP_IDLE;

                  err_stop_state_en       = 1'b0;
                  err_stop_fetch          = 1'b0 ;
                  iccm_correction_state   = 1'b0;

         end
      endcase
   end
   rvdffs #(($bits(eh2_err_stop_state_t))) err_stop_state_ff (.clk(free_clk), .din(err_stop_nxtstate), .dout({err_stop_state}), .en(err_stop_state_en),   .*);

         assign bus_cmd_sent               = ifu_bus_arvalid     & ifu_bus_arready   & miss_pending & ifu_selected_miss_thr & ~dec_tlu_force_halt;
   assign bus_inc_data_beat_cnt      = bus_ifu_wr_en_ff       & ~bus_last_data_beat & ~dec_tlu_force_halt;
   assign bus_reset_data_beat_cnt    = ic_act_miss_f2         | (bus_ifu_wr_en_ff &  bus_last_data_beat) | dec_tlu_force_halt;
   assign bus_hold_data_beat_cnt     = ~bus_inc_data_beat_cnt & ~bus_reset_data_beat_cnt ;

   assign bus_new_data_beat_count[pt.ICACHE_BEAT_BITS-1:0] = ({pt.ICACHE_BEAT_BITS{bus_reset_data_beat_cnt}} & (pt.ICACHE_BEAT_BITS)'(0)) |
                                                             ({pt.ICACHE_BEAT_BITS{bus_inc_data_beat_cnt}}   & (bus_data_beat_count[pt.ICACHE_BEAT_BITS-1:0] + {{pt.ICACHE_BEAT_BITS-1{1'b0}},1'b1})) |
                                                             ({pt.ICACHE_BEAT_BITS{bus_hold_data_beat_cnt}}  &  bus_data_beat_count[pt.ICACHE_BEAT_BITS-1:0]);


   rvdff #(pt.ICACHE_BEAT_BITS)  bus_mb_beat_count_ff (.*, .clk(free_clk), .din ({bus_new_data_beat_count[pt.ICACHE_BEAT_BITS-1:0]}), .dout({bus_data_beat_count[pt.ICACHE_BEAT_BITS-1:0]}));

   assign last_data_recieved_in =  (bus_ifu_wr_en_ff &  bus_last_data_beat & ~scnd_miss_req) | (last_data_recieved_ff & ~ic_act_miss_f2) ;
   rvdff #(1)  last_beat_ff (.*, .clk(free_clk), .din (last_data_recieved_in), .dout(last_data_recieved_ff));



   assign bus_inc_rd_addr_cnt     = bus_cmd_sent  ;
   assign bus_set_rd_addr_cnt     = ic_act_miss_f2 | scnd_miss_req_ff2;
   assign bus_hold_rd_addr_cnt    = ~bus_inc_rd_addr_cnt &  ~bus_set_rd_addr_cnt;


   assign bus_new_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0] = (~miss_pending                    ) ? imb_ff[pt.ICACHE_BEAT_ADDR_HI:3] :
                                                           (                scnd_miss_req_q  ) ? imb_scnd_ff[pt.ICACHE_BEAT_ADDR_HI:3] :
                                                           ( bus_cmd_sent                    ) ? (bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0] + 3'b001) :
                                                                                                  bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0];


   rvdff #(pt.ICACHE_BEAT_BITS)  bus_rd_addr_ff (.*,  .clk(busclk_reset), .din ({bus_new_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0]}), .dout({bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0]}));


   assign bus_inc_cmd_beat_cnt              =  ifu_bus_cmd_valid    &  ifu_bus_cmd_ready & miss_pending & (selected_miss_thr == tid) & ~dec_tlu_force_halt;
   assign bus_reset_cmd_beat_cnt_0          =  (ic_act_miss_f2       & ~uncacheable_miss_in) | dec_tlu_force_halt ;
   assign bus_reset_cmd_beat_cnt_secondlast =  (ic_act_miss_f2       &  uncacheable_miss_in)                      ;
   assign bus_hold_cmd_beat_cnt             = ~bus_inc_cmd_beat_cnt & ~(ic_act_miss_f2 | scnd_miss_req | dec_tlu_force_halt) ;
   assign bus_cmd_beat_en                   = bus_inc_cmd_beat_cnt | ic_act_miss_f2 | dec_tlu_force_halt;

   assign bus_new_cmd_beat_count[pt.ICACHE_BEAT_BITS-1:0] =  ({pt.ICACHE_BEAT_BITS{bus_reset_cmd_beat_cnt_0}}       & (pt.ICACHE_BEAT_BITS)'(0) ) |
                                                          ({pt.ICACHE_BEAT_BITS{bus_reset_cmd_beat_cnt_secondlast}} & (pt.ICACHE_BEAT_BITS)'(pt.ICACHE_SCND_LAST)) |
                                                          ({pt.ICACHE_BEAT_BITS{bus_inc_cmd_beat_cnt}}              & (bus_cmd_beat_count[pt.ICACHE_BEAT_BITS-1:0] + {{pt.ICACHE_BEAT_BITS-1{1'b0}}, 1'b1})) |
                                                          ({pt.ICACHE_BEAT_BITS{bus_hold_cmd_beat_cnt}}             &  bus_cmd_beat_count[pt.ICACHE_BEAT_BITS-1:0]) ;


   assign    req_addr_count[pt.ICACHE_BEAT_BITS-1:0]    = bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0] ;

   rvclkhdr bus_clk_reset(.en(bus_ifu_bus_clk_en | ic_act_miss_f2 | dec_tlu_force_halt),
                   .l1clk(busclk_reset), .*);


   rvdffs #(pt.ICACHE_BEAT_BITS)  bus_cmd_beat_ff (.*, .clk(busclk_reset), .en (bus_cmd_beat_en), .din ({bus_new_cmd_beat_count[pt.ICACHE_BEAT_BITS-1:0]}),
                    .dout({bus_cmd_beat_count[pt.ICACHE_BEAT_BITS-1:0]}));

   assign    req_addr_count[pt.ICACHE_BEAT_BITS-1:0]    = bus_rd_addr_count[pt.ICACHE_BEAT_BITS-1:0] ;



    assign bus_last_data_beat     =  uncacheable_miss_ff ? (bus_data_beat_count[pt.ICACHE_BEAT_BITS-1:0] == {{pt.ICACHE_BEAT_BITS-1{1'b0}},1'b1}) : (&bus_data_beat_count[pt.ICACHE_BEAT_BITS-1:0]);

   assign  bus_ifu_wr_en            =  ifu_bus_rvalid     & miss_pending & (ifu_bus_rsp_tag[pt.IFU_BUS_TAG-1] == tid);
   assign  bus_ifu_wr_en_ff         =  ifu_bus_rvalid_ff  & miss_pending & rsp_miss_thr_ff;
   assign  bus_ifu_wr_en_ff_q       =  ifu_bus_rvalid_ff  & miss_pending & rsp_miss_thr_ff & ~uncacheable_miss_ff & ~(|ifu_bus_rresp_ff[1:0]) & write_ic_16_bytes;    assign  bus_ifu_wr_en_ff_wo_err  =  ifu_bus_rvalid_ff  & miss_pending & rsp_miss_thr_ff & ~uncacheable_miss_ff;
   assign  bus_ifu_wr_en_ff_wo_err  =  ifu_bus_rvalid_ff  & miss_pending & rsp_miss_thr_ff & ~uncacheable_miss_ff;


   rvdff #(1)  act_miss_ff (.*, .clk(free_clk), .din (ic_act_miss_f2), .dout(ic_act_miss_f2_delayed));


   assign    reset_tag_valid_for_miss = ((ic_act_miss_f2_delayed & (miss_state == CRIT_BYP_OK)) | ifu_miss_state_pre_crit_ff) & ~uncacheable_miss_ff  ;
   assign    bus_ifu_wr_data_error    = |ifu_bus_rsp_opc[1:0]  &  ifu_bus_rvalid     & miss_pending & (ifu_bus_rsp_tag[pt.IFU_BUS_TAG-1] == tid);
   assign    bus_ifu_wr_data_error_ff = |ifu_bus_rresp_ff[1:0] &  ifu_bus_rvalid_ff  & miss_pending & rsp_miss_thr_ff;


   assign ic_crit_wd_rdy   =  ic_crit_wd_rdy_new_in | ic_crit_wd_rdy_new_ff;
   assign last_beat        =  bus_last_data_beat & bus_ifu_wr_en_ff;
   assign reset_beat_cnt    = bus_reset_data_beat_cnt ;

   assign ic_hit_f2             =  ic_act_hit_f2 |
                                   ic_byp_hit_f2 |
                                   ic_iccm_hit_f2 |
                                   (ifc_region_acc_fault_f2 & ifc_fetch_req_f2 & ~((miss_state == CRIT_BYP_OK) | (miss_state == DUPL_MISS_WAIT) | (miss_state == PRE_CRIT_BYP)));


  assign ifu_wr_data_comb_err       =  bus_ifu_wr_data_error_ff ;
  assign ifu_wr_cumulative_err      = (ifu_wr_data_comb_err | ifu_wr_data_comb_err_ff) & ~reset_beat_cnt;
  assign ifu_wr_cumulative_err_data =  ifu_wr_data_comb_err | ifu_wr_data_comb_err_ff ;

  rvdff #(1) cumul_err_ff (.*, .clk(free_clk),  .din (ifu_wr_cumulative_err), .dout(ifu_wr_data_comb_err_ff));


   assign   ic_rd_en    =  (ifc_fetch_req_tid_q_f1_raw & ~ifc_fetch_uncacheable_f1 & ~ifc_iccm_access_f1 ) |
                           (exu_flush_final  & ~ifc_fetch_uncacheable_f1 & ~ifc_iccm_access_f1 )     ;

   assign  ic_real_rd_wp  =  (ifc_fetch_req_tid_q_f1 &  ~ifc_iccm_access_f1  &  ~ifc_region_acc_fault_final_f1 & ~dec_tlu_fence_i_wb & ~stream_miss_f2 & ~ic_act_miss_f2 &
                               ~ic_miss_under_miss_killf1_f2 &
                               ~(((miss_state == STREAM) & ~miss_state_en) |
                              ((miss_state == CRIT_BYP_OK) & ~miss_state_en & ~(miss_nxtstate == MISS_WAIT)) |
                              ((miss_state == MISS_WAIT) & ~miss_state_en) |
                              ((miss_state == STALL_SCND_MISS) & ~miss_state_en)  |
                              ((miss_state == CRIT_WRD_RDY) & ~miss_state_en)  |
                              ((miss_nxtstate == STREAM) &  miss_state_en)  |
                              ((miss_nxtstate == DUPL_MISS_WAIT) &  miss_state_en)  |
                              ((miss_state == SCND_MISS) & ~miss_state_en))) |
                          (ifc_fetch_req_tid_q_f1 &  ~ifc_iccm_access_f1  &  ~ifc_region_acc_fault_final_f1 & ~dec_tlu_fence_i_wb & ~stream_miss_f2 & exu_flush_final);





    assign ic_wr_en[pt.ICACHE_NUM_WAYS-1:0] = bus_ic_wr_en[pt.ICACHE_NUM_WAYS-1:0] & {pt.ICACHE_NUM_WAYS{write_ic_16_bytes}};
   assign ic_write_stall_self              =  write_ic_16_bytes &  ~(((miss_state== CRIT_BYP_OK) & ~(bus_ifu_wr_en_ff & last_beat & ~uncacheable_miss_ff))) &
                                                                   ~(((miss_state==STREAM)       & ~(bus_ifu_wr_en_ff & last_beat & ~uncacheable_miss_ff) & ~(exu_flush_final | ifu_bp_hit_taken_q_f2 | stream_eol_f2)));
   assign ic_write_stall_other             =  write_ic_16_bytes & ~uncacheable_miss_ff;

    assign iccm_stop_fetch = (err_stop_state == ERR_STOP_FETCH) | err_stop_fetch;
    assign ic_dma_active   = iccm_correct_ecc | (perr_state == DMA_SB_ERR) |
                             dec_tlu_flush_err_wb;
    assign scnd_miss_req_in     = ifu_bus_rsp_valid & bus_ifu_bus_clk_en & ifu_bus_rsp_ready & (ifu_bus_rsp_tag[pt.IFU_BUS_TAG-1] == tid) &
                                 (&bus_new_data_beat_count[pt.ICACHE_BEAT_BITS-1:0]) &
                                 ~uncacheable_miss_ff &  ((miss_state == SCND_MISS) | (miss_nxtstate == SCND_MISS)) & ~exu_flush_final;
   rvdff #(1)           scnd_mss_req_ff  (.*, .clk(free_clk), .din(scnd_miss_req_in),   .dout(scnd_miss_req_q));
   rvdff #(1)           scnd_mss_req_ff2 (.*, .clk(free_clk), .din(scnd_miss_req),      .dout(scnd_miss_req_ff2));

   assign  scnd_miss_req = scnd_miss_req_q & ~exu_flush_final;

  assign sel_byp_data     =  (ic_crit_wd_rdy_new_ff | (miss_state == STREAM) | (miss_state == CRIT_BYP_OK)) & ~ifu_byp_data_err_new;
  assign sel_ic_data      = ~(ic_crit_wd_rdy_new_ff | (miss_state == STREAM) | (miss_state == CRIT_BYP_OK)) & ~fetch_req_iccm_tid_f2 ;


   rvclkhdr bus_clk(.en(bus_ifu_bus_clk_en | dec_tlu_force_halt) ,
                   .l1clk(busclk_force), .*);

   assign  ifc_bus_ic_req_ff_in  = (ic_act_miss_f2 | bus_cmd_req_hold | ifu_bus_cmd_valid) & ~dec_tlu_force_halt & ~((bus_cmd_beat_count== {pt.ICACHE_BEAT_BITS{1'b1}}) & ifu_bus_cmd_valid & ifu_bus_cmd_ready & miss_pending & (selected_miss_thr == tid));
   rvdff #(1) bus_ic_req_ff2(.*, .clk(busclk_force), .din(ifc_bus_ic_req_ff_in), .dout(ifu_bus_cmd_valid));

   assign    bus_cmd_req_in  = (ic_act_miss_f2 | bus_cmd_req_hold) & ~bus_cmd_sent & ~dec_tlu_force_halt  ;

   wire              iccm_ecc_write_status     ;
   wire              iccm_rd_ecc_single_err_hold_in ;
   reg              iccm_rd_ecc_single_err_ff;

   assign iccm_ecc_write_status           = (((iccm_rd_ecc_single_err & ~iccm_rd_ecc_single_err_ff)  & ~exu_flush_final & fetch_tid_f2) | (iccm_dma_sb_error & fetch_tid_f2));
   assign iccm_rd_ecc_single_err_hold_in  =   ((iccm_rd_ecc_single_err & fetch_tid_f2) | iccm_rd_ecc_single_err_ff) & ~exu_flush_final ;



   rvdff  #((1))             ecc_rr_ff     (.clk(free_clk),     .din(iccm_rd_ecc_single_err_hold_in),           .dout(iccm_rd_ecc_single_err_ff),               .*);
   rvdffs #((32))            ecc_dat0_ff   (.clk(free_clk),     .din(iccm_corrected_data_f2_mux[31:0]),         .dout(iccm_ecc_corr_data_ff[31:0]),             .en(iccm_ecc_write_status),  .*);
   rvdffs #((7))             ecc_dat1_ff   (.clk(free_clk),     .din(iccm_corrected_ecc_f2_mux[6:0]),           .dout(iccm_ecc_corr_data_ff[38:32]),            .en(iccm_ecc_write_status),  .*);
   rvdffs #((pt.ICCM_BITS-2))ecc_ind0_ff   (.clk(free_clk),     .din(iccm_ecc_corr_index_in[pt.ICCM_BITS-1:2]), .dout(iccm_ecc_corr_index_ff[pt.ICCM_BITS-1:2]),.en(iccm_ecc_write_status),  .*);











endmodule

