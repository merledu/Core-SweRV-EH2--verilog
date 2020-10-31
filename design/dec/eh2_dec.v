
module eh2_dec
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input wire clk,
   input wire free_clk,
   input wire active_clk,

   output logic dec_div_cancel,       
   output logic [pt.NUM_THREADS-1:0]         dec_i1_cancel_e1,

   output logic dec_extint_stall,
   input wire lsu_fastint_stall_any,

   input wire [31:0] lsu_rs1_dc1,

   output logic dec_pause_state_cg,             
   input wire rst_l,                           input wire [31:1] rst_vec,               
   input wire nmi_int,                  input wire [31:1] nmi_vec,               
   input wire [pt.NUM_THREADS-1:0] i_cpu_halt_req,                 input wire [pt.NUM_THREADS-1:0] i_cpu_run_req,               
   output logic [pt.NUM_THREADS-1:0] dec_tlu_mhartstart,    output logic [pt.NUM_THREADS-1:0] o_cpu_halt_status,    output logic [pt.NUM_THREADS-1:0] o_cpu_halt_ack,                 output logic [pt.NUM_THREADS-1:0] o_cpu_run_ack,                  output logic [pt.NUM_THREADS-1:0] o_debug_mode_status,         
   output logic [pt.NUM_THREADS-1:0] dec_tlu_force_halt,

   input wire [31:4]     core_id, 

      input wire [pt.NUM_THREADS-1:0] mpc_debug_halt_req,    input wire [pt.NUM_THREADS-1:0] mpc_debug_run_req,    input wire [pt.NUM_THREADS-1:0] mpc_reset_run_req,    output logic [pt.NUM_THREADS-1:0] mpc_debug_halt_ack,    output logic [pt.NUM_THREADS-1:0] mpc_debug_run_ack,    output logic [pt.NUM_THREADS-1:0] debug_brkpt_status, 
   input wire exu_pmu_i0_br_misp,        input wire exu_pmu_i0_br_ataken,      input wire exu_pmu_i0_pc4,            input wire exu_pmu_i1_br_misp,        input wire exu_pmu_i1_br_ataken,      input wire exu_pmu_i1_pc4,         

   input wire lsu_nonblock_load_valid_dc1,         input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]   lsu_nonblock_load_tag_dc1,           input wire lsu_nonblock_load_inv_dc2,          input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]   lsu_nonblock_load_inv_tag_dc2,      input wire lsu_nonblock_load_inv_dc5,           input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]   lsu_nonblock_load_inv_tag_dc5,       input wire lsu_nonblock_load_data_valid,        input wire lsu_nonblock_load_data_tid,
   input wire lsu_nonblock_load_data_error,        input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]   lsu_nonblock_load_data_tag,          input wire [31:0]                          lsu_nonblock_load_data,           
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_load_external_dc3,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_store_external_dc3,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_misaligned_dc3,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_bus_trxn,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_bus_busy,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_bus_misaligned,
   input wire [pt.NUM_THREADS-1:0] lsu_pmu_bus_error,


   input wire dma_pmu_dccm_read,             input wire dma_pmu_dccm_write,            input wire dma_pmu_any_read,              input wire dma_pmu_any_write,          
   input wire [pt.NUM_THREADS-1:0][1:0] ifu_pmu_instr_aligned,
   input wire [pt.NUM_THREADS-1:0]      ifu_pmu_align_stall,

   input wire [pt.NUM_THREADS-1:0] ifu_pmu_fetch_stall,

   input wire [pt.NUM_THREADS-1:0] ifu_pmu_ic_miss,
   input wire [pt.NUM_THREADS-1:0] ifu_pmu_ic_hit,
   input wire [pt.NUM_THREADS-1:0] ifu_pmu_bus_error,
   input wire [pt.NUM_THREADS-1:0] ifu_pmu_bus_busy,
   input wire [pt.NUM_THREADS-1:0] ifu_pmu_bus_trxn,

   input wire [3:0]  lsu_trigger_match_dc4,
   input wire dbg_cmd_valid,      input wire dbg_cmd_tid,        input wire dbg_cmd_write,      input wire [1:0] dbg_cmd_type,       input wire [31:0] dbg_cmd_addr,       input wire [1:0] dbg_cmd_wrdata,  

   input wire [pt.NUM_THREADS-1:0] [1:0]  ifu_i0_icaf_type,                              input wire [pt.NUM_THREADS-1:0]      ifu_i0_icaf,             input wire [pt.NUM_THREADS-1:0]        ifu_i0_icaf_f1,          input wire [pt.NUM_THREADS-1:0]      ifu_i0_dbecc,         

   input wire [pt.NUM_THREADS-1:0]  lsu_idle_any,                             input wire [pt.NUM_THREADS-1:0]  lsu_load_stall_any,                       input wire [pt.NUM_THREADS-1:0]  lsu_store_stall_any,                      input wire [pt.NUM_THREADS-1:0]  lsu_amo_stall_any,         
   input eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_brp,                 input eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_brp,
   input wire [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i0_bp_index,    input wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           ifu_i0_bp_fghr,    input wire [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          ifu_i0_bp_btag,    input wire [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i1_bp_index,    input wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           ifu_i1_bp_fghr,    input wire [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          ifu_i1_bp_btag, 
   input    eh2_lsu_error_pkt_t lsu_error_pkt_dc3,    input wire lsu_single_ecc_error_incr,     
   input wire [pt.NUM_THREADS-1:0] lsu_imprecise_error_store_any,
   input wire [pt.NUM_THREADS-1:0] lsu_imprecise_error_load_any,
   input wire [pt.NUM_THREADS-1:0][31:0]  lsu_imprecise_error_addr_any,   

   input wire [pt.NUM_THREADS-1:0]      exu_flush_final,               input wire [pt.NUM_THREADS-1:0]      exu_i0_flush_final,            input wire [pt.NUM_THREADS-1:0]      exu_i1_flush_final,            input wire [pt.NUM_THREADS-1:0]      exu_i0_flush_lower_e4,           input wire [pt.NUM_THREADS-1:0]      exu_i1_flush_lower_e4,        
   input wire [31:1] exu_i0_flush_path_e4,    input wire [31:1] exu_i1_flush_path_e4, 
   input wire exu_div_wren,           input wire [31:0]  exu_div_result,      
   input wire [31:0] exu_mul_result_e3,    
   input wire [31:0] exu_i0_csr_rs1_e1,       
   input wire [31:0] lsu_result_dc3,          input wire [31:0] lsu_result_corr_dc4, 
   input wire lsu_sc_success_dc5,      input wire dma_dccm_stall_any,      input wire dma_iccm_stall_any,   
   input wire [31:1] lsu_fir_addr,    input wire [1:0]  lsu_fir_error, 
   input wire iccm_dma_sb_error,     
   input wire [pt.NUM_THREADS-1:0][31:1] exu_npc_e4,           
   input wire [31:0] exu_i0_result_e1,        input wire [31:0] exu_i1_result_e1,

   input wire [31:0] exu_i0_result_e4,        input wire [31:0] exu_i1_result_e4,


   input wire [pt.NUM_THREADS-1:0]       ifu_i0_valid, ifu_i1_valid,       input wire [pt.NUM_THREADS-1:0] [31:0]  ifu_i0_instr, ifu_i1_instr,       input wire [pt.NUM_THREADS-1:0] [31:1]  ifu_i0_pc, ifu_i1_pc,             input wire [pt.NUM_THREADS-1:0]         ifu_i0_pc4, ifu_i1_pc4,        
   input eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i0_predecode,
   input eh2_predecode_pkt_t  [pt.NUM_THREADS-1:0] ifu_i1_predecode,

   input wire [31:1] exu_i0_pc_e1,                     input wire [31:1] exu_i1_pc_e1,

   input wire [pt.NUM_THREADS-1:0] timer_int,                                input wire [pt.NUM_THREADS-1:0] soft_int,                             
   input wire [pt.NUM_THREADS-1:0]       mexintpend,                         input wire [pt.NUM_THREADS-1:0] [7:0] pic_claimid,                        input wire [pt.NUM_THREADS-1:0] [3:0] pic_pl,                             input wire [pt.NUM_THREADS-1:0]       mhwakeup,                        
   output logic [pt.NUM_THREADS-1:0][3:0] dec_tlu_meicurpl,                  output logic [pt.NUM_THREADS-1:0][3:0] dec_tlu_meipt,                     output logic [31:2] dec_tlu_meihap, 
   input wire [70:0] ifu_ic_debug_rd_data,              input wire ifu_ic_debug_rd_data_valid,               output eh2_cache_debug_pkt_t dec_tlu_ic_diag_pkt,      

   input wire [pt.NUM_THREADS-1:0] dbg_halt_req,                    input wire [pt.NUM_THREADS-1:0] dbg_resume_req,               
   input wire [pt.NUM_THREADS-1:0] ifu_miss_state_idle,
   input wire [pt.NUM_THREADS-1:0] ifu_ic_error_start,
   input wire [pt.NUM_THREADS-1:0] ifu_iccm_rd_ecc_single_err,

   output logic [pt.NUM_THREADS-1:0] dec_tlu_dbg_halted,             output logic [pt.NUM_THREADS-1:0] dec_tlu_debug_mode,             output logic [pt.NUM_THREADS-1:0] dec_tlu_resume_ack,             output logic [pt.NUM_THREADS-1:0] dec_tlu_mpc_halted_only,     
   output logic dec_debug_wdata_rs1_d,       
   output logic [31:0] dec_dbg_rddata,       
   output logic dec_dbg_cmd_done,               output logic dec_dbg_cmd_fail,               output logic dec_dbg_cmd_tid,             
   output eh2_trigger_pkt_t  [pt.NUM_THREADS-1:0][3:0] trigger_pkt_any, 
      input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i0_br_index_e4,      input wire [1:0]  exu_i0_br_hist_e4,                                input wire exu_i0_br_bank_e4,                                input wire exu_i0_br_error_e4,                               input wire exu_i0_br_start_error_e4,                         input wire exu_i0_br_valid_e4,                               input wire exu_i0_br_mp_e4,                                  input wire exu_i0_br_middle_e4,                              input wire [pt.BHT_GHR_SIZE-1:0] exu_i0_br_fghr_e4,              
      input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_i1_br_index_e4,      input wire [1:0]  exu_i1_br_hist_e4,                                input wire exu_i1_br_bank_e4,                                input wire exu_i1_br_error_e4,                               input wire exu_i1_br_start_error_e4,                         input wire exu_i1_br_valid_e4,                               input wire exu_i1_br_mp_e4,                                  input wire exu_i1_br_middle_e4,                              input wire [pt.BHT_GHR_SIZE-1:0] exu_i1_br_fghr_e4,              

   input wire exu_i1_br_way_e4,                input wire exu_i0_br_way_e4,             
   output logic [31:0] gpr_i0_rs1_d,                  output logic [31:0] gpr_i0_rs2_d,                  output logic [31:0] gpr_i1_rs1_d,
   output logic [31:0] gpr_i1_rs2_d,

   output logic [31:0] dec_i0_immed_d,                 output logic [31:0] dec_i1_immed_d,

   output logic [12:1] dec_i0_br_immed_d,              output logic [12:1] dec_i1_br_immed_d,

   output        eh2_alu_pkt_t i0_ap,                      output        eh2_alu_pkt_t i1_ap,

   output logic          dec_i0_alu_decode_d,          output logic          dec_i1_alu_decode_d,

   output logic          dec_i0_select_pc_d,           output logic          dec_i1_select_pc_d,

   output logic [31:1] dec_i0_pc_d, dec_i1_pc_d,       output logic         dec_i0_rs1_bypass_en_d,        output logic         dec_i0_rs2_bypass_en_d,        output logic         dec_i1_rs1_bypass_en_d,
   output logic         dec_i1_rs2_bypass_en_d,

   output logic [31:0] i0_rs1_bypass_data_d,          output logic [31:0] i0_rs2_bypass_data_d,          output logic [31:0] i1_rs1_bypass_data_d,
   output logic [31:0] i1_rs2_bypass_data_d,
   output logic [pt.NUM_THREADS-1:0]        dec_ib3_valid_d,              output logic [pt.NUM_THREADS-1:0]        dec_ib2_valid_d,           
   output eh2_lsu_pkt_t    lsu_p,                         output eh2_mul_pkt_t    mul_p,                         output eh2_div_pkt_t    div_p,                      
   output logic [11:0] dec_lsu_offset_d,              output logic        dec_i0_lsu_d,                  output logic        dec_i1_lsu_d,

   output logic [pt.NUM_THREADS-1:0]       flush_final_e3,                output logic [pt.NUM_THREADS-1:0]       i0_flush_final_e3,          
   output logic        dec_i0_csr_ren_d,              
   output logic        dec_tlu_i0_kill_writeb_wb,     output logic        dec_tlu_i1_kill_writeb_wb,  
   output logic        dec_i0_mul_d,                  output logic        dec_i1_mul_d,
   output logic        dec_i0_div_d,               
   output logic        dec_i1_valid_e1,            
   output logic [pt.NUM_THREADS-1:0][31:1] pred_correct_npc_e2, 
   output logic        dec_i0_rs1_bypass_en_e3,       output logic        dec_i0_rs2_bypass_en_e3,       output logic        dec_i1_rs1_bypass_en_e3,
   output logic        dec_i1_rs2_bypass_en_e3,
   output logic [31:0] i0_rs1_bypass_data_e3,         output logic [31:0] i0_rs2_bypass_data_e3,         output logic [31:0] i1_rs1_bypass_data_e3,
   output logic [31:0] i1_rs2_bypass_data_e3,
   output logic        dec_i0_sec_decode_e3,          output logic        dec_i1_sec_decode_e3,
   output logic [31:1] dec_i0_pc_e3,                  output logic [31:1] dec_i1_pc_e3,

   output logic        dec_i0_rs1_bypass_en_e2,       output logic        dec_i0_rs2_bypass_en_e2,       output logic        dec_i1_rs1_bypass_en_e2,
   output logic        dec_i1_rs2_bypass_en_e2,
   output logic [31:0] i0_rs1_bypass_data_e2,         output logic [31:0] i0_rs2_bypass_data_e2,         output logic [31:0] i1_rs1_bypass_data_e2,
   output logic [31:0] i1_rs2_bypass_data_e2,

   output eh2_br_tlu_pkt_t dec_tlu_br0_wb_pkt,            output eh2_br_tlu_pkt_t dec_tlu_br1_wb_pkt,            output logic [pt.BHT_GHR_SIZE-1:0] dec_tlu_br0_fghr_wb,    output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br0_index_wb,    output logic [pt.BHT_GHR_SIZE-1:0] dec_tlu_br1_fghr_wb,    output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_tlu_br1_index_wb, 
   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt0,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt1,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt2,    output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt3, 
   output eh2_predict_pkt_t  i0_predict_p_d,              output eh2_predict_pkt_t  i1_predict_p_d,
   output logic [pt.BHT_GHR_SIZE-1:0] i0_predict_fghr_d,                   output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i0_predict_index_d,        output logic [pt.BTB_BTAG_SIZE-1:0] i0_predict_btag_d,                  output logic [pt.BHT_GHR_SIZE-1:0] i1_predict_fghr_d,                   output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i1_predict_index_d,        output logic [pt.BTB_BTAG_SIZE-1:0] i1_predict_btag_d,               

   output logic [31:0] i0_result_e4_eff,              output logic [31:0] i1_result_e4_eff,

   output   logic dec_tlu_i0_valid_e4,                output   logic dec_tlu_i1_valid_e4,             
   output logic [31:0] i0_result_e2,                  output logic [31:0] dec_tlu_mrac_ff,            
   output logic [4:2] dec_i0_data_en,                 output logic [4:1] dec_i0_ctl_en,
   output logic [4:2] dec_i1_data_en,
   output logic [4:1] dec_i1_ctl_en,

   output logic [pt.NUM_THREADS-1:0] dec_tlu_lr_reset_wb, 
   input wire [pt.NUM_THREADS-1:0] [15:0] ifu_i0_cinst,                     input wire [pt.NUM_THREADS-1:0] [15:0] ifu_i1_cinst,

   output eh2_trace_pkt_t  [pt.NUM_THREADS-1:0] rv_trace_pkt,             
      output logic  dec_tlu_external_ldfwd_disable,    output logic  dec_tlu_sideeffect_posted_disable,    output logic  dec_tlu_core_ecc_disable,              output logic  dec_tlu_bpred_disable,                 output logic  dec_tlu_wb_coalescing_disable,         output logic [2:0]  dec_tlu_dma_qos_prty,            output logic [pt.NUM_THREADS-1:0]      dec_tlu_i0_commit_cmt,              output logic  dec_tlu_misc_clk_override,             output logic  dec_tlu_exu_clk_override,              output logic  dec_tlu_ifu_clk_override,              output logic  dec_tlu_lsu_clk_override,              output logic  dec_tlu_bus_clk_override,              output logic  dec_tlu_pic_clk_override,              output logic  dec_tlu_dccm_clk_override,             output logic  dec_tlu_icm_clk_override,           
   output logic dec_i0_tid_e4,    output logic dec_i1_tid_e4,

   output logic [pt.NUM_THREADS-1:0] [31:1] dec_tlu_flush_path_wb,     output logic [pt.NUM_THREADS-1:0]        dec_tlu_flush_lower_wb,    output logic [pt.NUM_THREADS-1:0]        dec_tlu_flush_noredir_wb ,    output logic [pt.NUM_THREADS-1:0]        dec_tlu_flush_leak_one_wb,    output logic [pt.NUM_THREADS-1:0]        dec_tlu_flush_err_wb,    output logic [pt.NUM_THREADS-1:0]        dec_tlu_fence_i_wb,           input wire scan_mode

   );

   localparam GPR_BANKS = 1;
   localparam GPR_BANKS_LOG2 = (GPR_BANKS == 1) ? 1 : $clog2(GPR_BANKS);

   reg [pt.NUM_THREADS-1:0] dec_tlu_flush_pause_wb;
   reg [pt.NUM_THREADS-1:0] dec_tlu_wr_pause_wb;


   reg  dec_tlu_dec_clk_override;    reg  clk_override;

   wire               dec_ib1_valid_d;
   wire               dec_ib0_valid_d;


   reg [pt.NUM_THREADS-1:0][1:0] dec_pmu_instr_decoded;
   reg [pt.NUM_THREADS-1:0]      dec_pmu_decode_stall;
   reg [pt.NUM_THREADS-1:0]      dec_pmu_presync_stall;
   reg [pt.NUM_THREADS-1:0]      dec_pmu_postsync_stall;

   reg        dec_i0_rs1_en_d;
   reg        dec_i0_rs2_en_d;

   reg [4:0]  dec_i0_rs1_d;
   reg [4:0]  dec_i0_rs2_d;


   reg        dec_i1_rs1_en_d;
   reg        dec_i1_rs2_en_d;

   reg [4:0]  dec_i1_rs1_d;
   reg [4:0]  dec_i1_rs2_d;


wire [31:0] dec_i0_instr_d;
wire [31:0] dec_i1_instr_d;

   reg  dec_tlu_pipelining_disable;
   reg  dec_tlu_dual_issue_disable;


   reg [4:0]  dec_i0_waddr_wb;
   reg        dec_i0_wen_wb;
   reg        dec_i0_tid_wb;
   reg [31:0] dec_i0_wdata_wb;

   reg [4:0]  dec_i1_waddr_wb;
   reg        dec_i1_wen_wb;
   reg        dec_i1_tid_wb;
   reg [31:0] dec_i1_wdata_wb;

   reg        dec_i0_csr_wen_wb;         reg [11:0] dec_i0_csr_rdaddr_d;         reg [11:0] dec_i0_csr_wraddr_wb;         reg        dec_i0_csr_is_mcpc_e4;

   reg [31:0] dec_i0_csr_wrdata_wb;    
   reg [31:0] dec_i0_csr_rddata_d;       reg        dec_i0_csr_legal_d;               reg        dec_i0_csr_global_d;

   reg        dec_i0_csr_wen_unq_d;          reg        dec_i0_csr_any_unq_d;       

   reg [pt.NUM_THREADS-1:0] dec_csr_stall_int_ff;    reg                      dec_csr_nmideleg_e4;  

   eh2_trap_pkt_t dec_tlu_packet_e4;

   wire                        dec_i1_debug_valid_d;

wire dec_i0_pc4_d;
wire dec_i1_pc4_d;
   reg [pt.NUM_THREADS-1:0]   dec_tlu_presync_d;
   reg [pt.NUM_THREADS-1:0]   dec_tlu_postsync_d;
   reg [pt.NUM_THREADS-1:0]   dec_tlu_debug_stall;
 
   reg [pt.NUM_THREADS-1:0][31:0] dec_illegal_inst;


   wire                      dec_i0_icaf_d;
   wire [1:0]                dec_i0_icaf_type_d;
   wire                      dec_i0_icaf_f1_d;

   wire                      dec_i1_icaf_d;
   wire [1:0]                dec_i1_icaf_type_d;
   wire                      dec_i1_icaf_f1_d;

   wire                      dec_i0_dbecc_d;
   wire                      dec_i1_dbecc_d;

   reg                      dec_i0_decode_d;
   reg                      dec_i1_decode_d;

   reg [3:0]                dec_i0_trigger_match_d;
   reg [3:0]                dec_i1_trigger_match_d;


   wire                      dec_debug_fence_d;

   reg [pt.NUM_THREADS-1:0]                 dec_nonblock_load_wen;
   reg [pt.NUM_THREADS-1:0][4:0]            dec_nonblock_load_waddr;

   eh2_br_pkt_t dec_i0_brp;
   eh2_br_pkt_t dec_i1_brp;

   wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_i0_bp_index;
   wire [pt.BHT_GHR_SIZE-1:0] dec_i0_bp_fghr;
   wire [pt.BTB_BTAG_SIZE-1:0] dec_i0_bp_btag;
   wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_i1_bp_index;
   wire [pt.BHT_GHR_SIZE-1:0] dec_i1_bp_fghr;
   wire [pt.BTB_BTAG_SIZE-1:0] dec_i1_bp_btag;

   reg [pt.NUM_THREADS-1:0] dec_pause_state;          
   wire [15:0] dec_i0_cinst_d;
   wire [15:0] dec_i1_cinst_d;

   eh2_predecode_pkt_t dec_i0_predecode;
   eh2_predecode_pkt_t dec_i1_predecode;

   reg [31:0]               dec_i0_inst_wb1;
   reg [31:0]               dec_i1_inst_wb1;
   reg [31:1]               dec_i0_pc_wb1;
   reg [31:1]               dec_i1_pc_wb1;
reg [pt.NUM_THREADS-1:0] dec_tlu_i1_valid_wb1;
reg [pt.NUM_THREADS-1:0] dec_tlu_i0_valid_wb1;
reg [pt.NUM_THREADS-1:0] dec_tlu_int_valid_wb1;
   reg [pt.NUM_THREADS-1:0] [4:0] dec_tlu_exc_cause_wb1;
   wire [pt.NUM_THREADS-1:0] [31:0] dec_tlu_mtval_wb1;
reg [pt.NUM_THREADS-1:0] dec_tlu_i0_exc_valid_wb1;
reg [pt.NUM_THREADS-1:0] dec_tlu_i1_exc_valid_wb1;

   wire dec_i0_tid_d;
   wire dec_i1_tid_d;


   wire [1:0] [31:0] gpr_i0rs1_d;                  wire [1:0] [31:0] gpr_i0rs2_d;                  wire [1:0] [31:0] gpr_i1rs1_d;
   wire [1:0] [31:0] gpr_i1rs2_d;

   reg [31:1] dec_tlu_i0_pc_e4;                   reg [31:1] dec_tlu_i1_pc_e4;



   assign clk_override = dec_tlu_dec_clk_override;


   assign dec_dbg_rddata[31:0] = dec_i0_wdata_wb[31:0];


   wire [pt.NUM_THREADS-1:0] ib3_valid_d;                  wire [pt.NUM_THREADS-1:0] ib2_valid_d;                  wire [pt.NUM_THREADS-1:0] ib1_valid_d;                  wire [pt.NUM_THREADS-1:0] ib0_valid_d;                  wire [pt.NUM_THREADS-1:0] ib0_valid_in;                 wire [pt.NUM_THREADS-1:0] ib0_lsu_in;                 wire [pt.NUM_THREADS-1:0] ib0_mul_in;                 wire [pt.NUM_THREADS-1:0] ib0_i0_only_in;          
   wire [pt.NUM_THREADS-1:0] [31:0] i0_instr_d;            wire [pt.NUM_THREADS-1:0] [31:0] i1_instr_d;            wire [pt.NUM_THREADS-1:0] [31:1] i0_pc_d;               wire [pt.NUM_THREADS-1:0] [31:1] i1_pc_d;
   wire [pt.NUM_THREADS-1:0] i0_pc4_d;                     wire [pt.NUM_THREADS-1:0] i1_pc4_d;
   reg [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i0_bp_index;               reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           i0_bp_fghr;    reg [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          i0_bp_btag;    reg [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i1_bp_index;               reg [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           i1_bp_fghr;    reg [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          i1_bp_btag;    reg [pt.NUM_THREADS-1:0] i0_icaf_d;                    reg [pt.NUM_THREADS-1:0] i1_icaf_d;
   wire [pt.NUM_THREADS-1:0] i0_icaf_f1_d;                 wire [pt.NUM_THREADS-1:0] i1_icaf_f1_d;                 wire [pt.NUM_THREADS-1:0] i0_dbecc_d;                   wire [pt.NUM_THREADS-1:0] i1_dbecc_d;
   wire [pt.NUM_THREADS-1:0] debug_wdata_rs1_d;            wire [pt.NUM_THREADS-1:0] debug_fence_d;                wire [pt.NUM_THREADS-1:0] i0_debug_valid_d;                wire [pt.NUM_THREADS-1:0] [15:0] i0_cinst_d;            wire [pt.NUM_THREADS-1:0] [15:0] i1_cinst_d;
   wire [pt.NUM_THREADS-1:0] [1:0] i0_icaf_type_d;
   wire [pt.NUM_THREADS-1:0] [1:0] i1_icaf_type_d;

   eh2_br_pkt_t [pt.NUM_THREADS-1:0] i0_br_p;                    eh2_br_pkt_t [pt.NUM_THREADS-1:0] i1_br_p;

   eh2_predecode_pkt_t [pt.NUM_THREADS-1:0] i0_predecode_p;                    eh2_predecode_pkt_t [pt.NUM_THREADS-1:0] i1_predecode_p;

wire [pt.NUM_THREADS-1:0] ready_in;
wire [pt.NUM_THREADS-1:0] ready;
wire [pt.NUM_THREADS-1:0] lsu_in;
wire [pt.NUM_THREADS-1:0] mul_in;
wire [pt.NUM_THREADS-1:0] i0_only_in;
   reg [pt.NUM_THREADS-1:0]         dec_thread_stall_in;
   reg [pt.NUM_THREADS-1:0]         dec_tlu_flush_extint;

   reg [4:0] div_waddr_wb;
   reg       div_tid_wb;

   reg       dec_div_active;       reg       dec_div_tid;       

   
  for (genvar i=0; i<pt.NUM_THREADS; i++) begin : ib


     eh2_dec_ib_ctl #(.pt(pt)) instbuff (.tid               (1'(i)            ),
                                          .ifu_i0_valid      (ifu_i0_valid[i]),
                                          .ifu_i1_valid      (ifu_i1_valid[i]),
                                          .ifu_i0_icaf       (ifu_i0_icaf[i]),
                                          .ifu_i0_icaf_type  (ifu_i0_icaf_type[i]),
                                          .ifu_i0_icaf_f1    (ifu_i0_icaf_f1[i]),
                                          .ifu_i0_dbecc      (ifu_i0_dbecc[i]),
                                          .ifu_i0_instr      (ifu_i0_instr[i]),
                                          .ifu_i1_instr      (ifu_i1_instr[i]),
                                          .ifu_i0_pc         (ifu_i0_pc[i]),
                                          .ifu_i1_pc         (ifu_i1_pc[i]),
                                          .ifu_i0_pc4        (ifu_i0_pc4[i]),
                                          .ifu_i1_pc4        (ifu_i1_pc4[i]),
                                          .ifu_i0_predecode  (ifu_i0_predecode[i]),
                                          .ifu_i1_predecode  (ifu_i1_predecode[i]),
                                          .i0_brp            (i0_brp[i]),
                                          .i1_brp            (i1_brp[i]),
                                          .ifu_i0_bp_index   (ifu_i0_bp_index[i]),
                                          .ifu_i0_bp_fghr    (ifu_i0_bp_fghr[i]),
                                          .ifu_i0_bp_btag    (ifu_i0_bp_btag[i]),
                                          .ifu_i1_bp_index   (ifu_i1_bp_index[i]),
                                          .ifu_i1_bp_fghr    (ifu_i1_bp_fghr[i]),
                                          .ifu_i1_bp_btag    (ifu_i1_bp_btag[i]),
                                          .ifu_i0_cinst      (ifu_i0_cinst[i]),
                                          .ifu_i1_cinst      (ifu_i1_cinst[i]),

                                          .dec_i1_cancel_e1  (dec_i1_cancel_e1[i] ),
                                          .exu_flush_final   (exu_flush_final[i] ),
                                          .ib3_valid_d       (ib3_valid_d[i]   ),
                                          .ib2_valid_d       (ib2_valid_d[i]   ),
                                          .ib1_valid_d       (ib1_valid_d[i]   ),
                                          .ib0_valid_d       (ib0_valid_d[i]   ),
                                          .ib0_valid_in      (ib0_valid_in[i]   ),
                                          .ib0_lsu_in        (ib0_lsu_in[i]   ),
                                          .ib0_mul_in        (ib0_mul_in[i]   ),
                                          .ib0_i0_only_in    (ib0_i0_only_in[i]   ),
                                          .i0_instr_d        (i0_instr_d[i]    ),
                                          .i1_instr_d        (i1_instr_d[i]    ),
                                          .i0_debug_valid_d  (i0_debug_valid_d[i] ),
                                          .i0_pc_d           (i0_pc_d[i]       ),
                                          .i1_pc_d           (i1_pc_d[i]       ),
                                          .i0_pc4_d          (i0_pc4_d[i]      ),
                                          .i1_pc4_d          (i1_pc4_d[i]      ),
                                          .i0_bp_index       (i0_bp_index[i]   ),
                                          .i0_bp_fghr        (i0_bp_fghr[i]    ),
                                          .i0_bp_btag        (i0_bp_btag[i]    ),
                                          .i1_bp_index       (i1_bp_index[i]   ),
                                          .i1_bp_fghr        (i1_bp_fghr[i]    ),
                                          .i1_bp_btag        (i1_bp_btag[i]    ),
                                          .i0_icaf_d         (i0_icaf_d[i]     ),
                                          .i1_icaf_d         (i1_icaf_d[i]     ),
                                          .i0_icaf_f1_d      (i0_icaf_f1_d[i]  ),
                                          .i1_icaf_f1_d      (i1_icaf_f1_d[i]  ),
                                          .i0_dbecc_d        (i0_dbecc_d[i]    ),
                                          .i1_dbecc_d        (i1_dbecc_d[i]    ),
                                          .debug_wdata_rs1_d (debug_wdata_rs1_d[i]),
                                          .debug_fence_d     (debug_fence_d[i] ),
                                          .i0_cinst_d        (i0_cinst_d[i]    ),
                                          .i1_cinst_d        (i1_cinst_d[i]    ),
                                          .i0_icaf_type_d    (i0_icaf_type_d[i]),
                                          .i1_icaf_type_d    (i1_icaf_type_d[i]),
                                          .i0_br_p           (i0_br_p[i]       ),
                                          .i1_br_p           (i1_br_p[i]       ),
                                          .i0_predecode      (i0_predecode_p[i]       ),
                                          .i1_predecode      (i1_predecode_p[i]       ),
                                            .*
                                          );


  end 

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin : arf

      eh2_dec_gpr_ctl #(.pt(pt)) arf (.*,
                                       .tid (1'(i)),

                                       .rtid0(dec_i0_tid_d),
                                       .rtid1(dec_i0_tid_d),
                                       .rtid2(dec_i1_tid_d),
                                       .rtid3(dec_i1_tid_d),

                                                                              .raddr0(dec_i0_rs1_d[4:0]), .rden0(dec_i0_rs1_en_d),
                                       .raddr1(dec_i0_rs2_d[4:0]), .rden1(dec_i0_rs2_en_d),
                                       .raddr2(dec_i1_rs1_d[4:0]), .rden2(dec_i1_rs1_en_d),
                                       .raddr3(dec_i1_rs2_d[4:0]), .rden3(dec_i1_rs2_en_d),

                                       .wtid0(dec_i0_tid_wb),              .waddr0(dec_i0_waddr_wb[4:0]),            .wen0(dec_i0_wen_wb),            .wd0(dec_i0_wdata_wb[31:0]),
                                       .wtid1(dec_i1_tid_wb),              .waddr1(dec_i1_waddr_wb[4:0]),            .wen1(dec_i1_wen_wb),            .wd1(dec_i1_wdata_wb[31:0]),
                                       .wtid2(lsu_nonblock_load_data_tid), .waddr2(dec_nonblock_load_waddr[i][4:0]), .wen2(dec_nonblock_load_wen[i]), .wd2(lsu_nonblock_load_data[31:0]),
                                       .wtid3(div_tid_wb),                 .waddr3(div_waddr_wb[4:0]),               .wen3(exu_div_wren),             .wd3(exu_div_result[31:0]),

                                                                              .rd0(gpr_i0rs1_d[i]), .rd1(gpr_i0rs2_d[i]),
                                       .rd2(gpr_i1rs1_d[i]), .rd3(gpr_i1rs2_d[i])
                                       );


   end 



   assign ready_in[pt.NUM_THREADS-1:0] = ib0_valid_in[pt.NUM_THREADS-1:0];
   assign lsu_in[pt.NUM_THREADS-1:0] = ib0_lsu_in[pt.NUM_THREADS-1:0];
   assign mul_in[pt.NUM_THREADS-1:0] = ib0_mul_in[pt.NUM_THREADS-1:0];
   assign i0_only_in[pt.NUM_THREADS-1:0] = ib0_i0_only_in[pt.NUM_THREADS-1:0];

   wire i0_sel_i0_t1_d;
wire [1:0] i1_sel_i0_d;
wire [1:0] i1_sel_i1_d;


   if (pt.NUM_THREADS == 1) begin: genst
      assign gpr_i0_rs1_d[31:0] = gpr_i0rs1_d[0];
      assign gpr_i0_rs2_d[31:0] = gpr_i0rs2_d[0];
      assign gpr_i1_rs1_d[31:0] = gpr_i1rs1_d[0];
      assign gpr_i1_rs2_d[31:0] = gpr_i1rs2_d[0];

      assign dec_i0_tid_d = 1'b0;
      assign dec_i1_tid_d = 1'b0;

      assign ready[0] = 1'b1;

      assign i0_sel_i0_t1_d = 1'b0;
      assign i1_sel_i0_d[1:0] = 2'b00;
      assign i1_sel_i1_d[1:0] = 2'b01;

   end

   else begin: genmt

      assign gpr_i0_rs1_d[31:0] = gpr_i0rs1_d[1] | gpr_i0rs1_d[0];
      assign gpr_i0_rs2_d[31:0] = gpr_i0rs2_d[1] | gpr_i0rs2_d[0];
      assign gpr_i1_rs1_d[31:0] = gpr_i1rs1_d[1] | gpr_i1rs1_d[0];
      assign gpr_i1_rs2_d[31:0] = gpr_i1rs2_d[1] | gpr_i1rs2_d[0];



      rvarbiter2_smt dec_arbiter (
                                  .flush(exu_flush_final[1:0]),
                                  .shift(dec_i0_decode_d),
                                  .ready_in(ready_in[1:0]),
                                  .lsu_in(lsu_in[1:0]),
                                  .mul_in(mul_in[1:0]),
                                  .i0_only_in(i0_only_in[1:0]),
                                  .thread_stall_in(dec_thread_stall_in[1:0]),
                                  .ready(ready[1:0]),
                                  .i0_sel_i0_t1(i0_sel_i0_t1_d),
                                  .i1_sel_i0(i1_sel_i0_d[1:0]),
                                  .i1_sel_i1(i1_sel_i1_d[1:0]),
                                    .*
                                  );

      assign dec_i0_tid_d = i0_sel_i0_t1_d;

      assign dec_i1_tid_d = i1_sel_i1_d[1] | i1_sel_i0_d[1];
   end



      assign dec_ib3_valid_d[pt.NUM_THREADS-1:0]       = ib3_valid_d[pt.NUM_THREADS-1:0];
   assign dec_ib2_valid_d[pt.NUM_THREADS-1:0]       = ib2_valid_d[pt.NUM_THREADS-1:0];

   assign dec_ib0_valid_d       = ib0_valid_d[dec_i0_tid_d] & ready[dec_i0_tid_d]     ;
   assign dec_i0_instr_d        = i0_instr_d[dec_i0_tid_d]        ;
   assign dec_i0_pc_d           = i0_pc_d[dec_i0_tid_d]           ;
   assign dec_i0_pc4_d          = i0_pc4_d[dec_i0_tid_d]          ;
   assign dec_i0_bp_index       = i0_bp_index[dec_i0_tid_d]       ;
   assign dec_i0_bp_fghr        = i0_bp_fghr[dec_i0_tid_d]        ;
   assign dec_i0_bp_btag        = i0_bp_btag[dec_i0_tid_d]        ;
   assign dec_i0_icaf_d         = i0_icaf_d[dec_i0_tid_d]         ;
   assign dec_i0_icaf_f1_d      = i0_icaf_f1_d[dec_i0_tid_d]      ;
   assign dec_i0_dbecc_d        = i0_dbecc_d[dec_i0_tid_d]        ;
   assign dec_i0_cinst_d        = i0_cinst_d[dec_i0_tid_d]        ;
   assign dec_i0_icaf_type_d    = i0_icaf_type_d[dec_i0_tid_d]    ;
   assign dec_i0_brp            = i0_br_p[dec_i0_tid_d]           ;
   assign dec_i0_predecode      = i0_predecode_p[dec_i0_tid_d]           ;


   assign dec_debug_wdata_rs1_d = debug_wdata_rs1_d[dec_i0_tid_d] ;
   assign dec_debug_fence_d     = debug_fence_d[dec_i0_tid_d]     ;

      if (pt.NUM_THREADS==2 )  begin

            assign dec_i1_debug_valid_d  = (i1_sel_i0_d[0] & i0_debug_valid_d[0]) |
                                     (i1_sel_i0_d[1] & i0_debug_valid_d[1]);

      assign dec_ib1_valid_d       = (i1_sel_i0_d[0] & ib0_valid_d[0] & ready[0]) |
                                     (i1_sel_i1_d[0] & ib1_valid_d[0] & ready[0]) |
                                     (i1_sel_i0_d[1] & ib0_valid_d[1] & ready[1]) |
                                     (i1_sel_i1_d[1] & ib1_valid_d[1] & ready[1]);


      assign dec_i1_instr_d        = ({32{i1_sel_i0_d[0]}} & i0_instr_d[0]) |
                                     ({32{i1_sel_i1_d[0]}} & i1_instr_d[0]) |
                                     ({32{i1_sel_i0_d[1]}} & i0_instr_d[1]) |
                                     ({32{i1_sel_i1_d[1]}} & i1_instr_d[1]);

      assign dec_i1_pc_d           = ({31{i1_sel_i0_d[0]}} & i0_pc_d[0]) |
                                     ({31{i1_sel_i1_d[0]}} & i1_pc_d[0]) |
                                     ({31{i1_sel_i0_d[1]}} & i0_pc_d[1]) |
                                     ({31{i1_sel_i1_d[1]}} & i1_pc_d[1]);

      assign dec_i1_pc4_d          = (i1_sel_i0_d[0] & i0_pc4_d[0]) |
                                     (i1_sel_i1_d[0] & i1_pc4_d[0]) |
                                     (i1_sel_i0_d[1] & i0_pc4_d[1]) |
                                     (i1_sel_i1_d[1] & i1_pc4_d[1]);


      assign dec_i1_bp_index           = ({pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1{i1_sel_i0_d[0]}} & i0_bp_index[0]) |
                                         ({pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1{i1_sel_i1_d[0]}} & i1_bp_index[0]) |
                                         ({pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1{i1_sel_i0_d[1]}} & i0_bp_index[1]) |
                                         ({pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1{i1_sel_i1_d[1]}} & i1_bp_index[1]);

      assign dec_i1_bp_fghr            = ({pt.BHT_GHR_SIZE{i1_sel_i0_d[0]}} & i0_bp_fghr[0]) |
                                         ({pt.BHT_GHR_SIZE{i1_sel_i1_d[0]}} & i1_bp_fghr[0]) |
                                         ({pt.BHT_GHR_SIZE{i1_sel_i0_d[1]}} & i0_bp_fghr[1]) |
                                         ({pt.BHT_GHR_SIZE{i1_sel_i1_d[1]}} & i1_bp_fghr[1]);

      assign dec_i1_bp_btag            = ({pt.BTB_BTAG_SIZE{i1_sel_i0_d[0]}} & i0_bp_btag[0]) |
                                         ({pt.BTB_BTAG_SIZE{i1_sel_i1_d[0]}} & i1_bp_btag[0]) |
                                         ({pt.BTB_BTAG_SIZE{i1_sel_i0_d[1]}} & i0_bp_btag[1]) |
                                         ({pt.BTB_BTAG_SIZE{i1_sel_i1_d[1]}} & i1_bp_btag[1]);

      assign dec_i1_icaf_d          = (i1_sel_i0_d[0] & i0_icaf_d[0]) |
                                      (i1_sel_i1_d[0] & i1_icaf_d[0]) |
                                      (i1_sel_i0_d[1] & i0_icaf_d[1]) |
                                      (i1_sel_i1_d[1] & i1_icaf_d[1]);

      assign dec_i1_icaf_f1_d          = (i1_sel_i0_d[0] & i0_icaf_f1_d[0]) |
                                         (i1_sel_i1_d[0] & i1_icaf_f1_d[0]) |
                                         (i1_sel_i0_d[1] & i0_icaf_f1_d[1]) |
                                         (i1_sel_i1_d[1] & i1_icaf_f1_d[1]);

      assign dec_i1_dbecc_d          = (i1_sel_i0_d[0] & i0_dbecc_d[0]) |
                                       (i1_sel_i1_d[0] & i1_dbecc_d[0]) |
                                       (i1_sel_i0_d[1] & i0_dbecc_d[1]) |
                                       (i1_sel_i1_d[1] & i1_dbecc_d[1]);

      assign dec_i1_cinst_d         = ({16{i1_sel_i0_d[0]}} & i0_cinst_d[0]) |
                                      ({16{i1_sel_i1_d[0]}} & i1_cinst_d[0]) |
                                      ({16{i1_sel_i0_d[1]}} & i0_cinst_d[1]) |
                                      ({16{i1_sel_i1_d[1]}} & i1_cinst_d[1]);

      assign dec_i1_icaf_type_d         = ({2{i1_sel_i0_d[0]}} & i0_icaf_type_d[0]) |
                                          ({2{i1_sel_i1_d[0]}} & i1_icaf_type_d[0]) |
                                          ({2{i1_sel_i0_d[1]}} & i0_icaf_type_d[1]) |
                                          ({2{i1_sel_i1_d[1]}} & i1_icaf_type_d[1]);


      assign dec_i1_brp                 = ({$bits(eh2_br_pkt_t){i1_sel_i0_d[0]}} & i0_br_p[0]) |
                                          ({$bits(eh2_br_pkt_t){i1_sel_i1_d[0]}} & i1_br_p[0]) |
                                          ({$bits(eh2_br_pkt_t){i1_sel_i0_d[1]}} & i0_br_p[1]) |
                                          ({$bits(eh2_br_pkt_t){i1_sel_i1_d[1]}} & i1_br_p[1]);

      assign dec_i1_predecode                 = ({$bits(eh2_predecode_pkt_t){i1_sel_i0_d[0]}} & i0_predecode_p[0]) |
                                                ({$bits(eh2_predecode_pkt_t){i1_sel_i1_d[0]}} & i1_predecode_p[0]) |
                                                ({$bits(eh2_predecode_pkt_t){i1_sel_i0_d[1]}} & i0_predecode_p[1]) |
                                                ({$bits(eh2_predecode_pkt_t){i1_sel_i1_d[1]}} & i1_predecode_p[1]);

   end
   else begin
      assign dec_i1_debug_valid_d  = '0;   
      assign dec_ib1_valid_d       = ib1_valid_d[dec_i1_tid_d] & ready[dec_i1_tid_d]      ;
      assign dec_i1_instr_d        = i1_instr_d[dec_i1_tid_d]        ;
      assign dec_i1_pc_d           = i1_pc_d[dec_i1_tid_d]           ;
      assign dec_i1_pc4_d          = i1_pc4_d[dec_i1_tid_d]          ;
      assign dec_i1_bp_index       = i1_bp_index[dec_i1_tid_d]       ;
      assign dec_i1_bp_fghr        = i1_bp_fghr[dec_i1_tid_d]        ;
      assign dec_i1_bp_btag        = i1_bp_btag[dec_i1_tid_d]        ;
      assign dec_i1_icaf_d         = i1_icaf_d[dec_i1_tid_d]         ;
      assign dec_i1_icaf_f1_d      = i1_icaf_f1_d[dec_i1_tid_d]      ;
      assign dec_i1_dbecc_d        = i1_dbecc_d[dec_i1_tid_d]        ;
      assign dec_i1_cinst_d        = i1_cinst_d[dec_i1_tid_d]        ;
      assign dec_i1_icaf_type_d    = i1_icaf_type_d[dec_i1_tid_d]    ;
      assign dec_i1_brp            = i1_br_p[dec_i1_tid_d]           ;
      assign dec_i1_predecode      = i1_predecode_p[dec_i1_tid_d]           ;


   end


 eh2_dec_decode_ctl #(.pt(pt)) decode (.*);

   eh2_dec_tlu_top #(.pt(pt)) tlu (.*);


// Trigger

   eh2_dec_trigger #(.pt(pt)) dec_trigger (.*);




        for (genvar i=0; i<pt.NUM_THREADS; i++) begin : tracep

        assign rv_trace_pkt[i].rv_i_insn_ip    = { dec_i1_inst_wb1[31:0],     dec_i0_inst_wb1[31:0] };
        assign rv_trace_pkt[i].rv_i_address_ip = { dec_i1_pc_wb1[31:1], 1'b0, dec_i0_pc_wb1[31:1], 1'b0 };

        assign rv_trace_pkt[i].rv_i_valid_ip =     {dec_tlu_int_valid_wb1[i],                                                            dec_tlu_i1_valid_wb1[i] | dec_tlu_i1_exc_valid_wb1[i],                                                           dec_tlu_i0_valid_wb1[i] | dec_tlu_i0_exc_valid_wb1[i]
                                                         };
        assign rv_trace_pkt[i].rv_i_exception_ip = {dec_tlu_int_valid_wb1[i], dec_tlu_i1_exc_valid_wb1[i], dec_tlu_i0_exc_valid_wb1[i]};
        assign rv_trace_pkt[i].rv_i_ecause_ip =     dec_tlu_exc_cause_wb1[i][4:0];          assign rv_trace_pkt[i].rv_i_interrupt_ip = {dec_tlu_int_valid_wb1[i],2'b0};
        assign rv_trace_pkt[i].rv_i_tval_ip =    dec_tlu_mtval_wb1[i][31:0];             end



endmodule 
