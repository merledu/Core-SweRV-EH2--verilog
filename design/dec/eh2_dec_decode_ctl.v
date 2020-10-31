

module eh2_dec_decode_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input dec_i1_debug_valid_d,

   input wire dec_i0_csr_global_d,

   input eh2_predecode_pkt_t dec_i0_predecode,
   input eh2_predecode_pkt_t dec_i1_predecode,

   input wire [pt.NUM_THREADS-1:0] dec_tlu_force_halt, 
   input wire [pt.NUM_THREADS-1:0] dec_tlu_debug_stall, 
   input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_extint,

   input wire dec_i0_tid_d,
   input wire dec_i1_tid_d,

   output logic dec_div_cancel,       
   output logic dec_extint_stall,


   input wire [15:0] dec_i0_cinst_d,            input wire [15:0] dec_i1_cinst_d,

   output logic [31:0] dec_i0_inst_wb1,          output logic [31:0] dec_i1_inst_wb1,

   output logic [31:1] dec_i0_pc_wb1,            output logic [31:1] dec_i1_pc_wb1,


   output logic [pt.NUM_THREADS-1:0] dec_i1_cancel_e1,

   input wire [31:0] lsu_rs1_dc1,

   input wire lsu_nonblock_load_valid_dc1,        input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_tag_dc1,          input wire lsu_nonblock_load_inv_dc2,          input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc2,      input wire lsu_nonblock_load_inv_dc5,          input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc5,      input wire lsu_nonblock_load_data_valid,       input wire lsu_nonblock_load_data_error,       input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_data_tag,         input wire lsu_nonblock_load_data_tid,


   input wire [31:0]                         lsu_nonblock_load_data,          
   input wire [3:0] dec_i0_trigger_match_d,             input wire [3:0] dec_i1_trigger_match_d,          
   input wire [pt.NUM_THREADS-1:0]           dec_tlu_wr_pause_wb,                   
   input wire dec_tlu_pipelining_disable,               input wire dec_tlu_dual_issue_disable,            
   input wire [3:0]  lsu_trigger_match_dc4,          
   input logic[pt.NUM_THREADS-1:0] lsu_pmu_misaligned_dc3,                
   input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_leak_one_wb,             
   input wire dec_debug_fence_d,                     
   input wire [1:0] dbg_cmd_wrdata,                  
   input wire dec_i0_icaf_d,                            input wire dec_i1_icaf_d,
   input wire dec_i0_icaf_f1_d,                         input wire dec_i1_icaf_f1_d,
   input wire [1:0] dec_i0_icaf_type_d,                 input wire [1:0] dec_i1_icaf_type_d,

   input wire dec_i0_dbecc_d,                           input wire dec_i1_dbecc_d,

   input eh2_br_pkt_t dec_i0_brp,                            input eh2_br_pkt_t dec_i1_brp,
   input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_i0_bp_index,               input wire [pt.BHT_GHR_SIZE-1:0] dec_i0_bp_fghr,    input wire [pt.BTB_BTAG_SIZE-1:0] dec_i0_bp_btag,    input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] dec_i1_bp_index,               input wire [pt.BHT_GHR_SIZE-1:0] dec_i1_bp_fghr,    input wire [pt.BTB_BTAG_SIZE-1:0] dec_i1_bp_btag, 
   input wire [pt.NUM_THREADS-1:0]  lsu_idle_any,                             input wire [pt.NUM_THREADS-1:0]  lsu_load_stall_any,                       input wire [pt.NUM_THREADS-1:0]  lsu_store_stall_any,                      input wire [pt.NUM_THREADS-1:0]  lsu_amo_stall_any,         
   input wire dma_dccm_stall_any,                    
   input wire exu_div_wren,                          
   input wire dec_tlu_i0_kill_writeb_wb,       input wire dec_tlu_i1_kill_writeb_wb,    
   input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_lower_wb,          
   input wire [pt.NUM_THREADS-1:0] dec_tlu_flush_pause_wb,          
   input wire [pt.NUM_THREADS-1:0] dec_tlu_presync_d,                  input wire [pt.NUM_THREADS-1:0] dec_tlu_postsync_d,              
   input wire [31:0] exu_mul_result_e3,        
   input wire dec_i0_pc4_d,                  input wire dec_i1_pc4_d,



   input wire [31:0] lsu_result_dc3,         input wire [31:0] lsu_result_corr_dc4, 
   input wire lsu_sc_success_dc5,   
   input wire [pt.NUM_THREADS-1:0] exu_i0_flush_final,            input wire [pt.NUM_THREADS-1:0] exu_i1_flush_final,         

   input wire [31:1] exu_i0_pc_e1,           input wire [31:1] exu_i1_pc_e1,

   input wire [31:0] dec_i0_instr_d,         input wire [31:0] dec_i1_instr_d,

   input wire dec_ib0_valid_d,             input wire dec_ib1_valid_d,

   input wire [31:0] exu_i0_result_e1,       input wire [31:0] exu_i1_result_e1,

   input wire [31:0] exu_i0_result_e4,       input wire [31:0] exu_i1_result_e4,

   input wire clk,                          input wire active_clk,                   input wire free_clk,                  
   input wire clk_override,                 input wire rst_l,


   output logic         dec_i0_rs1_en_d,      output logic         dec_i0_rs2_en_d,

   output logic [4:0] dec_i0_rs1_d,           output logic [4:0] dec_i0_rs2_d,

   output logic dec_i0_tid_e4,    output logic dec_i1_tid_e4,

   output logic [31:0] dec_i0_immed_d,     
   output logic          dec_i1_rs1_en_d,
   output logic          dec_i1_rs2_en_d,

   output logic [4:0]  dec_i1_rs1_d,
   output logic [4:0]  dec_i1_rs2_d,



   output logic [31:0] dec_i1_immed_d,

   output logic [12:1] dec_i0_br_immed_d,       output logic [12:1] dec_i1_br_immed_d,

   output eh2_alu_pkt_t i0_ap,                      output eh2_alu_pkt_t i1_ap,

   output logic          dec_i0_decode_d,       output logic          dec_i1_decode_d,

   output logic          dec_i0_alu_decode_d,      output logic          dec_i1_alu_decode_d,


   output logic [31:0] i0_rs1_bypass_data_d,       output logic [31:0] i0_rs2_bypass_data_d,       output logic [31:0] i1_rs1_bypass_data_d,
   output logic [31:0] i1_rs2_bypass_data_d,


   output logic [4:0]  dec_i0_waddr_wb,            output logic          dec_i0_wen_wb,            output logic          dec_i0_tid_wb,            output logic [31:0] dec_i0_wdata_wb,         
   output logic [4:0]  dec_i1_waddr_wb,
   output logic          dec_i1_wen_wb,
   output logic          dec_i1_tid_wb,
   output logic [31:0] dec_i1_wdata_wb,

   output logic          dec_i0_select_pc_d,       output logic          dec_i1_select_pc_d,

   output logic dec_i0_rs1_bypass_en_d,            output logic dec_i0_rs2_bypass_en_d,            output logic dec_i1_rs1_bypass_en_d,
   output logic dec_i1_rs2_bypass_en_d,

   output eh2_lsu_pkt_t    lsu_p,                   
   output eh2_mul_pkt_t    mul_p,                   
   output eh2_div_pkt_t    div_p,                      output logic             div_tid_wb,                 output logic [4:0]       div_waddr_wb,            
   output logic [11:0] dec_lsu_offset_d,
   output logic        dec_i0_lsu_d,           output logic        dec_i1_lsu_d,
   output logic        dec_i0_mul_d,           output logic        dec_i1_mul_d,

   output logic        dec_i0_div_d,        
   output logic [pt.NUM_THREADS-1:0]       flush_final_e3,         output logic [pt.NUM_THREADS-1:0]       i0_flush_final_e3,   
   input wire [31:0]  dec_i0_csr_rddata_d,       input wire dec_i0_csr_legal_d,               input wire [31:0]  exu_i0_csr_rs1_e1,      

   output logic        dec_i0_csr_ren_d,          output logic        dec_i0_csr_wen_unq_d,          output logic        dec_i0_csr_any_unq_d,          output logic        dec_i0_csr_wen_wb,         output logic [11:0] dec_i0_csr_rdaddr_d,         output logic [11:0] dec_i0_csr_wraddr_wb,        output logic [31:0] dec_i0_csr_wrdata_wb,      output logic        dec_i0_csr_is_mcpc_e4,     
   output logic [pt.NUM_THREADS-1:0] dec_csr_stall_int_ff, 
   output logic dec_csr_nmideleg_e4, 

   output              dec_tlu_i0_valid_e4,     output              dec_tlu_i1_valid_e4,

   output              eh2_trap_pkt_t dec_tlu_packet_e4,   
   output logic [31:1] dec_tlu_i0_pc_e4,     output logic [31:1] dec_tlu_i1_pc_e4,


   output logic [pt.NUM_THREADS-1:0][31:0] dec_illegal_inst,

   output logic        dec_i1_valid_e1,         
   output logic [pt.NUM_THREADS-1:0][31:1] pred_correct_npc_e2, 
   output logic        dec_i0_rs1_bypass_en_e3,    output logic        dec_i0_rs2_bypass_en_e3,    output logic        dec_i1_rs1_bypass_en_e3,
   output logic        dec_i1_rs2_bypass_en_e3,
   output logic [31:0] i0_rs1_bypass_data_e3,      output logic [31:0] i0_rs2_bypass_data_e3,      output logic [31:0] i1_rs1_bypass_data_e3,
   output logic [31:0] i1_rs2_bypass_data_e3,
   output logic        dec_i0_sec_decode_e3,       output logic        dec_i1_sec_decode_e3,       output logic [31:1] dec_i0_pc_e3,               output logic [31:1] dec_i1_pc_e3,            
   output logic        dec_i0_rs1_bypass_en_e2,    output logic        dec_i0_rs2_bypass_en_e2,    output logic        dec_i1_rs1_bypass_en_e2,
   output logic        dec_i1_rs2_bypass_en_e2,
   output logic [31:0] i0_rs1_bypass_data_e2,      output logic [31:0] i0_rs2_bypass_data_e2,      output logic [31:0] i1_rs1_bypass_data_e2,
   output logic [31:0] i1_rs2_bypass_data_e2,

   output eh2_predict_pkt_t  i0_predict_p_d,           output eh2_predict_pkt_t  i1_predict_p_d,
   output logic [pt.BHT_GHR_SIZE-1:0] i0_predict_fghr_d,    output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i0_predict_index_d,    output logic [pt.BTB_BTAG_SIZE-1:0] i0_predict_btag_d, 
   output logic [pt.BHT_GHR_SIZE-1:0] i1_predict_fghr_d,    output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i1_predict_index_d,    output logic [pt.BTB_BTAG_SIZE-1:0] i1_predict_btag_d, 
   output logic [31:0] i0_result_e4_eff,           output logic [31:0] i1_result_e4_eff,
   output logic [31:0] i0_result_e2,            
   output logic [4:2] dec_i0_data_en,              output logic [4:1] dec_i0_ctl_en,
   output logic [4:2] dec_i1_data_en,
   output logic [4:1] dec_i1_ctl_en,

   output logic [pt.NUM_THREADS-1:0][1:0] dec_pmu_instr_decoded,    
   output logic [pt.NUM_THREADS-1:0]   dec_pmu_decode_stall,     
   output logic [pt.NUM_THREADS-1:0]      dec_pmu_presync_stall,       output logic [pt.NUM_THREADS-1:0]      dec_pmu_postsync_stall,   
   output logic [pt.NUM_THREADS-1:0]      dec_nonblock_load_wen,           output logic [pt.NUM_THREADS-1:0][4:0] dec_nonblock_load_waddr,      

   output logic [pt.NUM_THREADS-1:0]      dec_pause_state,                 output logic       dec_pause_state_cg,           
   output logic [pt.NUM_THREADS-1:0]      dec_thread_stall_in,       
   output logic        dec_div_active,        output logic        dec_div_tid,           input wire scan_mode
   );

   eh2_dec_pkt_t i0_dp_raw, i0_dp;
   eh2_dec_pkt_t i1_dp_raw, i1_dp;



wire [31:0] i0;
wire [31:0] i1;
wire i0_valid_d;
wire i1_valid_d;

wire [31:0] i0_result_e1;
wire [31:0] i1_result_e1;
   reg [31:0]                      i1_result_e2;
wire [31:0] i0_result_e3;
wire [31:0] i1_result_e3;
wire [31:0] i0_result_e4;
wire [31:0] i1_result_e4;
wire [31:0] i0_result_wb;
wire [31:0] i1_result_wb;

wire [31:1] i0_pc_e1;
wire [31:1] i1_pc_e1;
reg [31:1] i0_pc_e2;
reg [31:1] i1_pc_e2;
wire [31:1] i0_pc_e3;
wire [31:1] i1_pc_e3;
wire [31:1] i0_pc_e4;
wire [31:1] i1_pc_e4;

wire [9:0] i0_rs1bypass;
wire [9:0] i0_rs2bypass;
wire [9:0] i1_rs1bypass;
wire [9:0] i1_rs2bypass;

wire i0_jalimm20;
reg i1_jalimm20;
wire i0_uiimm20;
wire i1_uiimm20;

   wire               lsu_decode_d;
   wire [31:0]        i0_immed_d;
   wire [31:0]        i1_immed_d;
   wire               i0_presync;
   wire               i0_postsync;

   wire [pt.NUM_THREADS-1:0]    presync_stall;
wire [pt.NUM_THREADS-1:0] postsync_stall_in;
wire [pt.NUM_THREADS-1:0] postsync_stall;
wire [pt.NUM_THREADS-1:0] base_postsync_stall_in;
wire [pt.NUM_THREADS-1:0] base_postsync_stall;
wire [pt.NUM_THREADS-1:0] jal_postsync_stall_in;
wire [pt.NUM_THREADS-1:0] jal_postsync_stall;
wire [pt.NUM_THREADS-1:0] prior_inflight;
wire [pt.NUM_THREADS-1:0] prior_inflight_e1e3;
wire [pt.NUM_THREADS-1:0] prior_inflight_e1e4;
wire [pt.NUM_THREADS-1:0] prior_inflight_wb;
wire [pt.NUM_THREADS-1:0] prior_csr_write;
wire [pt.NUM_THREADS-1:0] prior_csr_write_e1e4;
wire prior_any_csr_write_any_thread;
wire prior_any_csr_write_any_thread_e1e4;

wire i0_csr_clr_d;
wire i0_csr_set_d;
wire i0_csr_write_d;

reg i0_csr_clr_e1;
reg i0_csr_set_e1;
reg i0_csr_write_e1;
reg i0_csr_imm_e1;

   wire [31:0] i0_csr_mask_e1;
   wire [31:0] i0_write_csr_data_e1;

   wire [pt.NUM_THREADS-1:0][31:0] write_csr_data_in;
   wire [pt.NUM_THREADS-1:0][31:0] write_csr_data;
   wire [pt.NUM_THREADS-1:0]       csr_data_wen;

   reg [4:0]         i0_csrimm_e1;
   reg [31:0]        i0_csr_rddata_e1;

   wire               i1_load_block_d;
wire i1_mul_block_d;
wire i1_mul_block_thread_1cycle_d;
   wire               i1_load2_block_d;
   wire               i1_mul2_block_d;
   wire               mul_decode_d;

wire i0_legal;
wire i1_legal;

   wire [pt.NUM_THREADS-1:0]         shift_illegal;
   wire [pt.NUM_THREADS-1:0]         illegal_inst_en;
wire [pt.NUM_THREADS-1:0] illegal_lockout_in;
wire [pt.NUM_THREADS-1:0] illegal_lockout;

wire i0_legal_decode_d;
wire i1_legal_decode_d;

wire [31:0] i0_result_e3_final;
wire [31:0] i1_result_e3_final;
reg [31:0] i0_result_wb_raw;
reg [31:0] i1_result_wb_raw;

wire [pt.NUM_THREADS-1:0] [12:1] last_br_immed_d;
wire [pt.NUM_THREADS-1:0] [12:1] last_br_immed_e1;
wire [pt.NUM_THREADS-1:0] [12:1] last_br_immed_e2;
   wire [pt.NUM_THREADS-1:0][31:1]        last_pc_e2;

   wire        i1_depend_i0_d;
wire i0_rs1_depend_i0_e1;
wire i0_rs1_depend_i0_e2;
wire i0_rs1_depend_i0_e3;
wire i0_rs1_depend_i0_e4;
wire i0_rs1_depend_i0_wb;
wire i0_rs1_depend_i1_e1;
wire i0_rs1_depend_i1_e2;
wire i0_rs1_depend_i1_e3;
wire i0_rs1_depend_i1_e4;
wire i0_rs1_depend_i1_wb;
wire i0_rs2_depend_i0_e1;
wire i0_rs2_depend_i0_e2;
wire i0_rs2_depend_i0_e3;
wire i0_rs2_depend_i0_e4;
wire i0_rs2_depend_i0_wb;
wire i0_rs2_depend_i1_e1;
wire i0_rs2_depend_i1_e2;
wire i0_rs2_depend_i1_e3;
wire i0_rs2_depend_i1_e4;
wire i0_rs2_depend_i1_wb;
wire i1_rs1_depend_i0_e1;
wire i1_rs1_depend_i0_e2;
wire i1_rs1_depend_i0_e3;
wire i1_rs1_depend_i0_e4;
wire i1_rs1_depend_i0_wb;
wire i1_rs1_depend_i1_e1;
wire i1_rs1_depend_i1_e2;
wire i1_rs1_depend_i1_e3;
wire i1_rs1_depend_i1_e4;
wire i1_rs1_depend_i1_wb;
wire i1_rs2_depend_i0_e1;
wire i1_rs2_depend_i0_e2;
wire i1_rs2_depend_i0_e3;
wire i1_rs2_depend_i0_e4;
wire i1_rs2_depend_i0_wb;
wire i1_rs2_depend_i1_e1;
wire i1_rs2_depend_i1_e2;
wire i1_rs2_depend_i1_e3;
wire i1_rs2_depend_i1_e4;
wire i1_rs2_depend_i1_wb;
wire i1_rs1_depend_i0_d;
wire i1_rs2_depend_i0_d;

wire i0_secondary_d;
wire i1_secondary_d;
wire i0_secondary_block_d;
wire i1_secondary_block_d;
   wire        non_block_case_d;
   wire        i0_div_decode_d;
wire [31:0] i0_result_e4_final;
wire [31:0] i1_result_e4_final;
   wire        i0_load_block_d;
wire i0_mul_block_d;
wire i0_mul_block_thread_1cycle_d;
wire [3:0] i0_rs1_depth_d;
wire [3:0] i0_rs2_depth_d;
wire [3:0] i1_rs1_depth_d;
wire [3:0] i1_rs2_depth_d;

wire i0_rs1_match_e1_e2;
wire i0_rs1_match_e1_e3;
wire i0_rs2_match_e1_e2;
wire i0_rs2_match_e1_e3;
wire i1_rs1_match_e1_e2;
wire i1_rs1_match_e1_e3;
wire i1_rs2_match_e1_e2;
wire i1_rs2_match_e1_e3;

   wire        i0_amo_stall_d;
wire i0_load_stall_d;
wire i1_load_stall_d;
wire i0_store_stall_d;
wire i1_store_stall_d;

wire i0_predict_nt;
wire i0_predict_t;
wire i1_predict_nt;
wire i1_predict_t;

wire i0_notbr_error;
wire i0_br_toffset_error;
wire i1_notbr_error;
wire i1_br_toffset_error;
wire i0_ret_error;
wire i1_ret_error;
wire i0_br_error;
wire i1_br_error;
wire i0_br_error_all;
wire i1_br_error_all;
wire [11:0] i0_br_offset;
wire [11:0] i1_br_offset;

reg [20:1] i0_pcall_imm;
reg [20:1] i1_pcall_imm;
reg [20:1] i0_pcall_12b_offset;
reg [20:1] i1_pcall_12b_offset;
wire i0_pcall_raw;
wire i1_pcall_raw;
wire i0_pcall_case;
wire i1_pcall_case;
wire i0_pcall;
wire i1_pcall;

wire i0_pja_raw;
wire i1_pja_raw;
wire i0_pja_case;
wire i1_pja_case;
wire i0_pja;
wire i1_pja;

wire i0_pret_case;
reg i1_pret_case;
wire i0_pret_raw;
wire i0_pret;
wire i1_pret_raw;
wire i1_pret;

wire i0_jal;
wire i1_jal;

wire i0_predict_br;
wire i1_predict_br;

wire [31:0] i1_result_wb_eff;
wire [31:0] i0_result_wb_eff;
wire [2:0] i1rs1_intra;
wire [2:0] i1rs2_intra;
wire i1_rs1_intra_bypass;
wire i1_rs2_intra_bypass;
wire store_data_bypass_c1;
wire store_data_bypass_c2;
wire [1:0] store_data_bypass_e4_c1;
wire [1:0] store_data_bypass_e4_c2;
wire [1:0] store_data_bypass_e4_c3;
   wire        store_data_bypass_i0_e2_c2;

   eh2_class_pkt_t i0_rs1_class_d, i0_rs2_class_d;
   eh2_class_pkt_t i1_rs1_class_d, i1_rs2_class_d;

   eh2_class_pkt_t i0_dc, i0_e1c, i0_e2c, i0_e3c, i0_e4c, i0_wbc;
   eh2_class_pkt_t i1_dc, i1_e1c, i1_e2c, i1_e3c, i1_e4c, i1_wbc;


wire i0_rs1_match_e1;
wire i0_rs1_match_e2;
wire i0_rs1_match_e3;
wire i1_rs1_match_e1;
wire i1_rs1_match_e2;
wire i1_rs1_match_e3;
wire i0_rs2_match_e1;
wire i0_rs2_match_e2;
wire i0_rs2_match_e3;
wire i1_rs2_match_e1;
wire i1_rs2_match_e2;
wire i1_rs2_match_e3;

   wire       i0_secondary_stall_d;

wire i0_ap_pc2;
wire i0_ap_pc4;
wire i1_ap_pc2;
wire i1_ap_pc4;

   wire        i0_rd_en_d;
   wire        i1_rd_en_d;

   wire        load_ldst_bypass_c1;
   wire        load_mul_rs1_bypass_e1;
   wire        load_mul_rs2_bypass_e1;

wire [pt.NUM_THREADS-1:0] leak1_i0_stall_in;
wire [pt.NUM_THREADS-1:0] leak1_i0_stall;
wire [pt.NUM_THREADS-1:0] leak1_i1_stall_in;
wire [pt.NUM_THREADS-1:0] leak1_i1_stall;
   wire [pt.NUM_THREADS-1:0] leak1_mode;

   wire        i0_csr_write_only_d;

   wire        i0_any_csr_d;


   wire [5:0] i0_pipe_en;
wire i0_e1_ctl_en;
wire i0_e2_ctl_en;
wire i0_e3_ctl_en;
wire i0_e4_ctl_en;
wire i0_wb_ctl_en;
wire i0_e1_data_en;
wire i0_e2_data_en;
wire i0_e3_data_en;
wire i0_e4_data_en;
wire i0_wb_data_en;
wire i0_wb1_data_en;

   wire [5:0] i1_pipe_en;
wire i1_e1_ctl_en;
wire i1_e2_ctl_en;
wire i1_e3_ctl_en;
wire i1_e4_ctl_en;
wire i1_wb_ctl_en;
wire i1_e1_data_en;
wire i1_e2_data_en;
wire i1_e3_data_en;
wire i1_e4_data_en;
wire i1_wb_data_en;
wire i1_wb1_data_en;

   wire debug_fence_i;
   wire debug_fence;

   wire i0_csr_write;

   wire i0_instr_error;
   wire i0_icaf_d;
   wire i1_icaf_d;

wire i0_not_alu_eff;
wire i1_not_alu_eff;

   wire [pt.NUM_THREADS-1:0]   clear_pause;
wire [pt.NUM_THREADS-1:0] pause_state_in;
wire [pt.NUM_THREADS-1:0] pause_state;
   wire [pt.NUM_THREADS-1:0]   pause_stall;

   wire [31:1] i1_pc_wb;

   wire        i0_brp_valid;

   reg [pt.NUM_THREADS-1:0]   lsu_idle;
   reg        i0_csr_read_e1;
   wire        i0_block_d;
   wire        i1_block_d;


   eh2_inst_pkt_t                  i0_itype, i1_itype;

wire i0_br_unpred;
wire i1_br_unpred;

wire [pt.NUM_THREADS-1:0] flush_final_lower;
wire [pt.NUM_THREADS-1:0] flush_final_upper_e2;

   eh2_reg_pkt_t                   i0r, i1r;
wire i1_cancel_d;
reg i1_cancel_e1;

   wire [4:0]                      nonblock_load_rd;
   reg                            nonblock_load_tid_dc1;
wire i1_wen_wb;
wire i0_wen_wb;

   wire [pt.NUM_THREADS-1:0] [4:0] cam_nonblock_load_waddr;
   reg [pt.NUM_THREADS-1:0]       cam_nonblock_load_wen;
   reg [pt.NUM_THREADS-1:0]       cam_i0_nonblock_load_stall;
   reg [pt.NUM_THREADS-1:0]       cam_i1_nonblock_load_stall;
   reg [pt.NUM_THREADS-1:0]       cam_i0_load_kill_wen;
   reg [pt.NUM_THREADS-1:0]       cam_i1_load_kill_wen;

   reg [0:0]                      tlu_wr_pause_wb1;     reg [0:0]                      tlu_wr_pause_wb2;  
   wire                            debug_fence_raw;
   eh2_trap_pkt_t                  dt, e1t_in, e1t, e2t_in, e2t, e3t_in, e3t, e4t_ff, e4t;


wire [31:0] i0_inst_d;
wire [31:0] i1_inst_d;
reg [31:0] i0_inst_e1;
reg [31:0] i1_inst_e1;
reg [31:0] i0_inst_e2;
reg [31:0] i1_inst_e2;
reg [31:0] i0_inst_e3;
reg [31:0] i1_inst_e3;
reg [31:0] i0_inst_e4;
reg [31:0] i1_inst_e4;
wire [31:0] i0_inst_wb;
wire [31:0] i1_inst_wb;
wire [31:0] i0_inst_wb1;
wire [31:0] i1_inst_wb1;

   eh2_dest_pkt_t     dd, e1d, e2d, e3d, e4d, wbd;
   eh2_class_pkt_t    i0_e4c_in, i1_e4c_in;
   eh2_dest_pkt_t     e1d_in, e2d_in, e3d_in, e4d_in;

wire [31:1] i0_pc_wb;
wire [31:1] i0_pc_wb1;
   wire [31:1]           i1_pc_wb1;

   wire [pt.NUM_THREADS-1:0][31:0] illegal_inst;

      reg [pt.NUM_THREADS-1:0] i1_flush_final_e3;
   reg [pt.NUM_THREADS-1:0] i0_flush_final_e4;

   wire i1_block_same_thread_d;

   wire [pt.NUM_THREADS-1:0] flush_lower_wb;

   reg [pt.NUM_THREADS-1:0] flush_extint;

   wire i0_csr_update_e1;

   wire [pt.NUM_THREADS-1:0]       csr_update_e1;
   wire [pt.NUM_THREADS-1:0][31:0] write_csr_data_e1;
   wire [pt.NUM_THREADS-1:0][31:0] write_csr_data_wb;

   wire i0_csr_legal_d;

   wire lsu_tid_e3;

   wire div_stall;
   wire div_tid;
wire div_active;
wire div_active_in;
   wire div_valid;
   reg [4:0] div_rd;
wire i0_nonblock_div_stall;
wire i1_nonblock_div_stall;
   wire div_e1_to_wb;
   wire div_flush;
   wire nonblock_div_cancel;

   wire i0_div_prior_div_stall;

wire i1_secondary_block_thread_1cycle_d;
wire i0_secondary_block_thread_1cycle_d;
wire i1_secondary_block_thread_2cycle_d;
wire i0_secondary_block_thread_2cycle_d;
wire i0_secondary_stall_1cycle_d;
wire i0_secondary_stall_2cycle_d;
wire i0_secondary_stall_thread_1cycle_d;
wire i0_secondary_stall_thread_2cycle_d;

wire i1_br_error_fast;
wire i0_br_error_fast;


   wire i0_legal_except_csr;

   wire [pt.NUM_THREADS-1:0] flush_all;
wire [pt.NUM_THREADS-1:0] smt_secondary_stall_in;
wire [pt.NUM_THREADS-1:0] smt_secondary_stall;
reg [pt.NUM_THREADS-1:0] smt_secondary_stall_raw;
   wire [pt.NUM_THREADS-1:0] set_smt_presync_stall;
wire [pt.NUM_THREADS-1:0] smt_presync_stall_in;
wire [pt.NUM_THREADS-1:0] smt_presync_stall;
reg [pt.NUM_THREADS-1:0] smt_presync_stall_raw;
   wire [pt.NUM_THREADS-1:0] set_smt_csr_write_stall;
wire [pt.NUM_THREADS-1:0] smt_csr_write_stall_in;
wire [pt.NUM_THREADS-1:0] smt_csr_write_stall;
reg [pt.NUM_THREADS-1:0] smt_csr_write_stall_raw;

   wire [pt.NUM_THREADS-1:0] set_smt_atomic_stall;
wire [pt.NUM_THREADS-1:0] smt_atomic_stall_in;
wire [pt.NUM_THREADS-1:0] smt_atomic_stall;
reg [pt.NUM_THREADS-1:0] smt_atomic_stall_raw;

   wire [pt.NUM_THREADS-1:0] set_smt_div_stall;
wire [pt.NUM_THREADS-1:0] smt_div_stall_in;
wire [pt.NUM_THREADS-1:0] smt_div_stall;
reg [pt.NUM_THREADS-1:0] smt_div_stall_raw;

   wire [pt.NUM_THREADS-1:0] set_smt_nonblock_load_stall;
wire [pt.NUM_THREADS-1:0] smt_nonblock_load_stall_in;
wire [pt.NUM_THREADS-1:0] smt_nonblock_load_stall;
reg [pt.NUM_THREADS-1:0] smt_nonblock_load_stall_raw;
   reg [pt.NUM_THREADS-1:0] cam_nonblock_load_stall;

wire nonblock_load_tid_dc2;
wire nonblock_load_tid_dc5;
wire i0_rs1_nonblock_load_bypass_en_d;
wire i0_rs2_nonblock_load_bypass_en_d;
wire i1_rs1_nonblock_load_bypass_en_d;
wire i1_rs2_nonblock_load_bypass_en_d;

   typedef struct packed {
                          reg csr_read_stall;
                          reg extint_stall;
                          reg i1_cancel_e1_stall;
                          reg pause_stall;
                          reg leak1_stall;
                          reg debug_stall;
                          reg postsync_stall;
                          reg presync_stall;
                          reg wait_lsu_idle_stall;
                          reg nonblock_load_stall;
                          reg nonblock_div_stall;
                          reg prior_div_stall;
                          reg load_stall;
                          reg store_stall;
                          reg amo_stall;
                          reg load_block;
                          reg mul_block;
                          reg secondary_block;
                          reg secondary_stall;
                          } i0_block_pkt_t;

    typedef struct packed {
                           reg debug_valid_stall;
                           reg nonblock_load_stall;
                           reg wait_lsu_idle_stall;
                           reg extint_stall;
                           reg i1_cancel_e1_stall;
                           reg pause_stall;
                           reg debug_stall;
                           reg postsync_stall;
                           reg presync_stall;
                           reg nonblock_div_stall;
                           reg load_stall;
                           reg store_stall;
                           reg load_block;
                           reg mul_block;
                           reg load2_block;
                           reg mul2_block;
                           reg secondary_block;
                           reg leak1_stall;
                           reg i0_only_block;
                           reg icaf_block;
                           reg barrier_block;
                           reg block_same_thread;
                           } i1_block_pkt_t;


   i0_block_pkt_t i0blockp;
   i1_block_pkt_t i1blockp;

   wire i1_depend_i0_case_d;



         assign i0_brp_valid = dec_i0_brp.valid & ~leak1_mode[dd.i0tid];

   assign      i0_predict_p_d.misp    =  '0;
   assign      i0_predict_p_d.ataken  =  '0;
   assign      i0_predict_p_d.boffset =  '0;

   assign      i0_predict_p_d.pcall  =  i0_pcall;     assign      i0_predict_p_d.pja    =  i0_pja;
   assign      i0_predict_p_d.pret   =  i0_pret;
   assign      i0_predict_p_d.prett[31:1] = dec_i0_brp.prett[31:1];
   assign      i0_predict_p_d.pc4 = dec_i0_pc4_d;
   assign      i0_predict_p_d.hist[1:0] = dec_i0_brp.hist[1:0];
   assign      i0_predict_p_d.valid = i0_brp_valid & i0_legal_decode_d;
   assign      i0_notbr_error = i0_brp_valid & ~(i0_dp_raw.condbr | i0_pcall_raw | i0_pja_raw | i0_pret_raw);

      assign      i0_br_toffset_error = i0_brp_valid & dec_i0_brp.hist[1] & (dec_i0_brp.toffset[11:0] != i0_br_offset[11:0]) & !i0_pret_raw;
   assign      i0_ret_error = i0_brp_valid & dec_i0_brp.ret & ~i0_pret_raw;
   assign      i0_br_error =  dec_i0_brp.br_error | i0_notbr_error | i0_br_toffset_error | i0_ret_error;
   assign      i0_predict_p_d.br_error = i0_br_error & i0_legal_decode_d & ~leak1_mode[dd.i0tid];
   assign      i0_predict_p_d.br_start_error = dec_i0_brp.br_start_error & i0_legal_decode_d & ~leak1_mode[dd.i0tid];

   assign      i0_predict_p_d.bank = dec_i0_brp.bank;

   assign      i0_br_error_all = (i0_br_error | dec_i0_brp.br_start_error) & ~leak1_mode[dd.i0tid];

      assign      i0_br_error_fast = (dec_i0_brp.br_error | dec_i0_brp.br_start_error) & ~leak1_mode[dd.i0tid];

   assign      i0_predict_p_d.toffset[11:0] = i0_br_offset[11:0];

   assign      i0_predict_p_d.way = dec_i0_brp.way;
   assign      i0_predict_index_d[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] =  dec_i0_bp_index;
   assign      i0_predict_btag_d[pt.BTB_BTAG_SIZE-1:0]            =  dec_i0_bp_btag[pt.BTB_BTAG_SIZE-1:0];
   assign      i0_predict_fghr_d[pt.BHT_GHR_SIZE-1:0]                =  dec_i0_bp_fghr[pt.BHT_GHR_SIZE-1:0];


   assign      i1_predict_p_d.misp    =  '0;
   assign      i1_predict_p_d.ataken  =  '0;
   assign      i1_predict_p_d.boffset =  '0;

   assign      i1_predict_p_d.pcall  =  i1_pcall;
   assign      i1_predict_p_d.pja    =  i1_pja;
   assign      i1_predict_p_d.pret   =  i1_pret;
   assign      i1_predict_p_d.prett[31:1] = dec_i1_brp.prett[31:1];
   assign      i1_predict_p_d.pc4 = dec_i1_pc4_d;
   assign      i1_predict_p_d.hist[1:0] = dec_i1_brp.hist[1:0];
   assign      i1_predict_p_d.valid = dec_i1_brp.valid & i1_legal_decode_d;
   assign      i1_notbr_error = dec_i1_brp.valid & ~(i1_dp_raw.condbr | i1_pcall_raw | i1_pja_raw | i1_pret_raw);


   assign      i1_br_toffset_error = dec_i1_brp.valid & dec_i1_brp.hist[1] & (dec_i1_brp.toffset[11:0] != i1_br_offset[11:0]) & !i1_pret_raw;
   assign      i1_ret_error = dec_i1_brp.valid & dec_i1_brp.ret & ~i1_pret_raw;
   assign      i1_br_error = dec_i1_brp.br_error | i1_notbr_error | i1_br_toffset_error | i1_ret_error;
   assign      i1_predict_p_d.br_error = i1_br_error & i1_legal_decode_d;
   assign      i1_predict_p_d.br_start_error = dec_i1_brp.br_start_error & i1_legal_decode_d;
   assign      i1_predict_p_d.bank = dec_i1_brp.bank;

   assign      i1_br_error_all = (i1_br_error | dec_i1_brp.br_start_error);

   assign      i1_br_error_fast = (dec_i1_brp.br_error | dec_i1_brp.br_start_error);


   assign      i1_predict_p_d.toffset[11:0] = i1_br_offset[11:0];
   assign      i1_predict_p_d.way = dec_i1_brp.way;
   assign      i1_predict_index_d[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] =  dec_i1_bp_index;
   assign      i1_predict_btag_d[pt.BTB_BTAG_SIZE-1:0]           =  dec_i1_bp_btag[pt.BTB_BTAG_SIZE-1:0];
   assign      i1_predict_fghr_d[pt.BHT_GHR_SIZE-1:0]            =  dec_i1_bp_fghr[pt.BHT_GHR_SIZE-1:0];

   
         
   assign i0_icaf_d = dec_i0_icaf_d | dec_i0_dbecc_d;
   assign i1_icaf_d = dec_i1_icaf_d | dec_i1_dbecc_d;


   assign i0_instr_error = i0_icaf_d;

   always @* begin
      i0_dp = i0_dp_raw;

      if (i0_br_error_fast | i0_instr_error) begin
      i0_dp = '0;
      i0_dp.alu = 1'b1;
      i0_dp.rs1 = 1'b1;
      i0_dp.rs2 = 1'b1;
      i0_dp.lor = 1'b1;
      i0_dp.legal = 1'b1;
      i0_dp.postsync = 1'b1;
      i0_dp.i0_only = 1'b1;
      end

      i1_dp = i1_dp_raw;

      if (i1_br_error_fast) begin
         i1_dp = '0;
         i1_dp.alu = 1'b1;
         i1_dp.rs1 = 1'b1;
         i1_dp.rs2 = 1'b1;
         i1_dp.lor = 1'b1;
         i1_dp.legal = 1'b1;
         i1_dp.postsync = 1'b1;
         i1_dp.i0_only = 1'b1;
      end

   end


   assign flush_lower_wb[pt.NUM_THREADS-1:0] = dec_tlu_flush_lower_wb[pt.NUM_THREADS-1:0];


   assign i0[31:0] = dec_i0_instr_d[31:0];

   assign i1[31:0] = dec_i1_instr_d[31:0];

   assign dec_i0_select_pc_d = i0_dp.pc;
   assign dec_i1_select_pc_d = i1_dp.pc;

   
   assign i0_predict_br =  i0_dp.condbr | i0_pcall | i0_pja | i0_pret;
   assign i1_predict_br =  i1_dp.condbr | i1_pcall | i1_pja | i1_pret;

   assign i0_predict_nt = ~(dec_i0_brp.hist[1] & i0_brp_valid) & i0_predict_br;
   assign i0_predict_t  =  (dec_i0_brp.hist[1] & i0_brp_valid) & i0_predict_br;

   assign i0_ap.add =    i0_dp.add;
   assign i0_ap.sub =    i0_dp.sub;
   assign i0_ap.land =   i0_dp.land;
   assign i0_ap.lor =    i0_dp.lor;
   assign i0_ap.lxor =   i0_dp.lxor;
   assign i0_ap.sll =    i0_dp.sll;
   assign i0_ap.srl =    i0_dp.srl;
   assign i0_ap.sra =    i0_dp.sra;
   assign i0_ap.slt =    i0_dp.slt;
   assign i0_ap.unsign = i0_dp.unsign;
   assign i0_ap.beq =    i0_dp.beq;
   assign i0_ap.bne =    i0_dp.bne;
   assign i0_ap.blt =    i0_dp.blt;
   assign i0_ap.bge =    i0_dp.bge;


   assign i0_ap.csr_write = i0_csr_write_only_d;
   assign i0_ap.csr_imm = i0_dp.csr_imm;


   assign i0_ap.jal    =  i0_jal;


   assign i0_ap_pc2 = ~dec_i0_pc4_d;
   assign i0_ap_pc4 =  dec_i0_pc4_d;

   assign i0_ap.predict_nt = i0_predict_nt;
   assign i0_ap.predict_t  = i0_predict_t;

   assign i0_ap.tid = dd.i0tid;

   assign i1_predict_nt = ~(dec_i1_brp.hist[1] & dec_i1_brp.valid) & i1_predict_br;
   assign i1_predict_t  =  (dec_i1_brp.hist[1] & dec_i1_brp.valid) & i1_predict_br;

   assign i1_ap.add =    i1_dp.add;
   assign i1_ap.sub =    i1_dp.sub;
   assign i1_ap.land =   i1_dp.land;
   assign i1_ap.lor =    i1_dp.lor;
   assign i1_ap.lxor =   i1_dp.lxor;
   assign i1_ap.sll =    i1_dp.sll;
   assign i1_ap.srl =    i1_dp.srl;
   assign i1_ap.sra =    i1_dp.sra;
   assign i1_ap.slt =    i1_dp.slt;
   assign i1_ap.unsign = i1_dp.unsign;
   assign i1_ap.beq =    i1_dp.beq;
   assign i1_ap.bne =    i1_dp.bne;
   assign i1_ap.blt =    i1_dp.blt;
   assign i1_ap.bge =    i1_dp.bge;


   assign i1_ap.csr_write = 1'b0;
   assign i1_ap.csr_imm   = 1'b0;

   assign i1_ap.jal    =    i1_jal;

   assign i1_ap_pc2 = ~dec_i1_pc4_d;
   assign i1_ap_pc4 =  dec_i1_pc4_d;

   assign i1_ap.predict_nt = i1_predict_nt;
   assign i1_ap.predict_t  = i1_predict_t;
   assign i1_cancel_d = i0_dp.load & i1_depend_i0_d & i1_legal_decode_d & ~i1_br_error_all;  
   assign i1_ap.tid = dd.i1tid;


    rvdff #(1) cancel_ff (.*, .clk(active_clk), .din(i1_cancel_d),  .dout(i1_cancel_e1) );



   

   
   always @* begin

      dec_i1_cancel_e1 = '0;

      dec_i1_cancel_e1[e1d.i1tid] = ~(lsu_rs1_dc1[31:28]==pt.DCCM_REGION | lsu_rs1_dc1[31:28]==pt.PIC_REGION) & i1_cancel_e1 &
                                    ~flush_final_e3[e1d.i1tid] &
                                    ~flush_lower_wb[e1d.i1tid];
   end


   assign nonblock_load_rd[4:0] = (e1d.i0load) ? e1d.i0rd[4:0] : e1d.i1rd[4:0];        assign nonblock_load_tid_dc1 = e1d.lsu_tid;
   assign nonblock_load_tid_dc2 = e2d.lsu_tid;
   assign nonblock_load_tid_dc5 = wbd.lsu_tid;


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin : cam

      eh2_dec_cam #(.pt(pt)) cam (
                        .tid                     (1'(i)),
                        .flush                   (flush_all[i]),
                        .dec_tlu_force_halt      (dec_tlu_force_halt[i]),
                        .nonblock_load_waddr     (cam_nonblock_load_waddr[i]   ),
                        .nonblock_load_wen       (cam_nonblock_load_wen[i]     ),
                        .i0_nonblock_load_stall  (cam_i0_nonblock_load_stall[i]),
                        .i1_nonblock_load_stall  (cam_i1_nonblock_load_stall[i]),
                        .i0_load_kill_wen        (cam_i0_load_kill_wen[i]      ),
                        .i1_load_kill_wen        (cam_i1_load_kill_wen[i]      ),
                        .nonblock_load_stall     (cam_nonblock_load_stall[i]   )
                        );

   end


   assign dec_nonblock_load_waddr[pt.NUM_THREADS-1:0]  = cam_nonblock_load_waddr[pt.NUM_THREADS-1:0];
   assign dec_nonblock_load_wen[pt.NUM_THREADS-1:0]    = cam_nonblock_load_wen[pt.NUM_THREADS-1:0];



   assign i0_br_unpred = (i0_dp.condbr | i0_dp.jal) & ~i0_predict_br;
   assign i1_br_unpred = (i1_dp.condbr | i1_dp.jal) & ~i1_predict_br;

   
   always @* begin
      i0_itype = NULL;
      i1_itype = NULL;

      if (i0_legal_decode_d & ~i0_br_error_all) begin
         if (i0_dp.mul)                  i0_itype = MUL;
         if (i0_dp.load)                 i0_itype = LOAD;
         if (i0_dp.store)                i0_itype = STORE;
         if (i0_dp.pm_alu)               i0_itype = ALU;
         if (i0_dp.atomic & ~(i0_dp.lr | i0_dp.sc))
                                         i0_itype = ATOMIC;
         if (i0_dp.lr)                   i0_itype = LR;
         if (i0_dp.sc)                   i0_itype = SC;
         if ( dec_i0_csr_ren_d & ~dec_i0_csr_wen_unq_d)     i0_itype = CSRREAD;
         if (~dec_i0_csr_ren_d &  dec_i0_csr_wen_unq_d)     i0_itype = CSRWRITE;
         if ( dec_i0_csr_ren_d &  dec_i0_csr_wen_unq_d)     i0_itype = CSRRW;
         if (i0_dp.ebreak)               i0_itype = EBREAK;
         if (i0_dp.ecall)                i0_itype = ECALL;
         if (i0_dp.fence)                i0_itype = FENCE;
         if (i0_dp.fence_i)              i0_itype = FENCEI;           if (i0_dp.mret)                 i0_itype = MRET;
         if (i0_dp.condbr)               i0_itype = CONDBR;
         if (i0_dp.jal)                  i0_itype = JAL;
      end

      if (i1_legal_decode_d & ~i1_br_error_all) begin
         if (i1_dp.ebreak)               i1_itype = EBREAK;            if (i1_dp.ecall)                i1_itype = ECALL;
         if (i1_dp.mret)                 i1_itype = MRET;


         if (i1_dp.mul)                  i1_itype = MUL;
         if (i1_dp.load)                 i1_itype = LOAD;
         if (i1_dp.store)                i1_itype = STORE;
         if (i1_dp.pm_alu)               i1_itype = ALU;
         if (i1_dp.condbr)               i1_itype = CONDBR;
         if (i1_dp.jal)                  i1_itype = JAL;
         if (i1_dp.atomic & ~(i1_dp.lr | i1_dp.sc))
                                         i1_itype = ATOMIC;
         if (i1_dp.lr)                   i1_itype = LR;
         if (i1_dp.sc)                   i1_itype = SC;
      end
   end


   eh2_dec_dec_ctl i0_dec (.inst(i0[31:0]),.predecode(dec_i0_predecode),.out(i0_dp_raw));

   eh2_dec_dec_ctl i1_dec (.inst(i1[31:0]),.predecode(dec_i1_predecode),.out(i1_dp_raw));

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
     rvdff #(1) lsu_idle_ff (.*, .clk(free_clk), .din(lsu_idle_any[i]), .dout(lsu_idle[i]));

      
   end


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign leak1_i1_stall_in[i] = (dec_tlu_flush_leak_one_wb[i] | (leak1_i1_stall[i] & ~flush_lower_wb[i]));
         rvdff #(1) leak1_i1_stall_ff (.*, .clk(free_clk), .din(leak1_i1_stall_in[i]), .dout(leak1_i1_stall[i]));


      assign leak1_mode[i] = leak1_i1_stall[i];

      assign leak1_i0_stall_in[i] = ((dec_i0_decode_d & (dd.i0tid == i) & leak1_i1_stall[i]) | (leak1_i0_stall[i] & ~flush_lower_wb[i]));

         rvdff #(1) leak1_i0_stall_ff (.*, .clk(free_clk), .din(leak1_i0_stall_in[i]), .dout(leak1_i0_stall[i]));

   end


   
   assign i0_pcall_imm[20:1] = {i0[31],i0[19:12],i0[20],i0[30:21]};

   assign i0_pcall_12b_offset = (i0_pcall_imm[12]) ? (i0_pcall_imm[20:13] == 8'hff) : (i0_pcall_imm[20:13] == 8'h0);

   assign i0_pcall_case  = i0_pcall_12b_offset & i0_dp_raw.imm20 &  (i0r.rd[4:0] == 5'd1 | i0r.rd[4:0] == 5'd5);
   assign i0_pja_case    = i0_pcall_12b_offset & i0_dp_raw.imm20 & ~(i0r.rd[4:0] == 5'd1 | i0r.rd[4:0] == 5'd5);

   assign i1_pcall_imm[20:1] = {i1[31],i1[19:12],i1[20],i1[30:21]};

   assign i1_pcall_12b_offset = (i1_pcall_imm[12]) ? (i1_pcall_imm[20:13] == 8'hff) : (i1_pcall_imm[20:13] == 8'h0);

   assign i1_pcall_case  = i1_pcall_12b_offset & i1_dp_raw.imm20 &  (i1r.rd[4:0] == 5'd1 | i1r.rd[4:0] == 5'd5);
   assign i1_pja_case    = i1_pcall_12b_offset & i1_dp_raw.imm20 & ~(i1r.rd[4:0] == 5'd1 | i1r.rd[4:0] == 5'd5);


   assign i0_pcall_raw = i0_dp_raw.jal &   i0_pcall_case;      assign i0_pcall     = i0_dp.jal     &   i0_pcall_case;

   assign i1_pcall_raw = i1_dp_raw.jal &   i1_pcall_case;
   assign i1_pcall     = i1_dp.jal     &   i1_pcall_case;

   assign i0_pja_raw = i0_dp_raw.jal &   i0_pja_case;
   assign i0_pja     = i0_dp.jal     &   i0_pja_case;

   assign i1_pja_raw = i1_dp_raw.jal &   i1_pja_case;
   assign i1_pja     = i1_dp.jal     &   i1_pja_case;



   assign i0_br_offset[11:0] = (i0_pcall_raw | i0_pja_raw) ? i0_pcall_imm[12:1] : {i0[31],i0[7],i0[30:25],i0[11:8]};

   assign i1_br_offset[11:0] = (i1_pcall_raw | i1_pja_raw) ? i1_pcall_imm[12:1] : {i1[31],i1[7],i1[30:25],i1[11:8]};


   assign i0_pret_case = (i0_dp_raw.jal & i0_dp_raw.imm12 & (i0r.rd[4:0] == 5'b0) & (i0r.rs1[4:0] == 5'd1 | i0r.rs1[4:0] == 5'd5));     assign i1_pret_case = (i1_dp_raw.jal & i1_dp_raw.imm12 & (i1r.rd[4:0] == 5'b0) & (i1r.rs1[4:0] == 5'd1 | i1r.rs1[4:0] == 5'd5));  
   assign i0_pret_raw = i0_dp_raw.jal &   i0_pret_case;
   assign i0_pret    = i0_dp.jal     &   i0_pret_case;

   assign i1_pret_raw = i1_dp_raw.jal &   i1_pret_case;
   assign i1_pret     = i1_dp.jal     &   i1_pret_case;

   assign i0_jal    = i0_dp.jal  &  ~i0_pcall_case & ~i0_pja_case & ~i0_pret_case;
   assign i1_jal    = i1_dp.jal  &  ~i1_pcall_case & ~i1_pja_case & ~i1_pret_case;

         assign dec_lsu_offset_d[11:0] =
                                   ({12{~dec_extint_stall &  i0_dp.lsu & i0_dp.load}} &               i0[31:20]) |
                                   ({12{~dec_extint_stall & ~i0_dp.lsu & i1_dp.lsu & i1_dp.load}} &   i1[31:20]) |
                                   ({12{~dec_extint_stall &  i0_dp.lsu & i0_dp.store}} &             {i0[31:25],i0[11:7]}) |
                                   ({12{~dec_extint_stall & ~i0_dp.lsu & i1_dp.lsu & i1_dp.store}} & {i1[31:25],i1[11:7]});



   assign dec_i0_lsu_d = i0_dp.lsu;
   assign dec_i1_lsu_d = i1_dp.lsu;

   assign dec_i0_mul_d = i0_dp.mul;
   assign dec_i1_mul_d = i1_dp.mul;

   assign dec_i0_div_d = i0_dp.div;


   assign div_p.valid  =  i0_div_decode_d;
   assign div_p.unsign =  i0_dp.unsign;
   assign div_p.rem    =  i0_dp.rem;
   assign div_p.tid    =  dd.i0tid;


   assign mul_p.valid = mul_decode_d;

   assign mul_p.rs1_sign =   (i0_dp.mul) ? i0_dp.rs1_sign :   i1_dp.rs1_sign;
   assign mul_p.rs2_sign =   (i0_dp.mul) ? i0_dp.rs2_sign :   i1_dp.rs2_sign;
   assign mul_p.low      =   (i0_dp.mul) ? i0_dp.low      :   i1_dp.low;

   assign mul_p.load_mul_rs1_bypass_e1 = load_mul_rs1_bypass_e1;
   assign mul_p.load_mul_rs2_bypass_e1 = load_mul_rs2_bypass_e1;

   
   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign flush_final_lower[i] = flush_lower_wb[i];

      assign flush_final_upper_e2[i] = (exu_i0_flush_final[i] | exu_i1_flush_final[i]) & ~flush_lower_wb[i];  
   end
    rvdff #(pt.NUM_THREADS) extint_stall_ff (.*, .clk(free_clk), .din(dec_tlu_flush_extint[pt.NUM_THREADS-1:0]), .dout(flush_extint[pt.NUM_THREADS-1:0]));

   
   assign dec_extint_stall = |flush_extint[pt.NUM_THREADS-1:0];

`ifdef ASSERT_ON
`endif

   always @*  begin
      lsu_p = '0;

      if (dec_extint_stall) begin
         lsu_p.load = 1'b1;
         lsu_p.word = 1'b1;
         lsu_p.fast_int = 1'b1;
         lsu_p.valid = 1'b1;
         lsu_p.tid = ~flush_extint[0];
      end
      else begin

         lsu_p.atomic             = (i0_dp.lsu) ? i0_dp.atomic  :   i1_dp.atomic;
         lsu_p.atomic_instr[4:0]  = (i0_dp.lsu) ? i0[31:27]     :   i1[31:27];
         lsu_p.lr                 = (i0_dp.lsu) ? i0_dp.lr      :   i1_dp.lr;
         lsu_p.sc                 = (i0_dp.lsu) ? i0_dp.sc      :   i1_dp.sc;

         lsu_p.tid = (i0_dp.lsu) ?  dd.i0tid : dd.i1tid;

         lsu_p.pipe = ~i0_dp.lsu;

         lsu_p.load =    (i0_dp.lsu) ? i0_dp.load :   i1_dp.load;

         lsu_p.store =   (i0_dp.lsu) ? i0_dp.store :  i1_dp.store;
         lsu_p.by =      (i0_dp.lsu) ? i0_dp.by :     i1_dp.by;
         lsu_p.half =    (i0_dp.lsu) ? i0_dp.half :   i1_dp.half;

         lsu_p.word =    (i0_dp.lsu) ? i0_dp.word :   i1_dp.word;

         lsu_p.store_data_bypass_i0_e2_c2   = store_data_bypass_i0_e2_c2;           lsu_p.load_ldst_bypass_c1          = load_ldst_bypass_c1       ;
         lsu_p.store_data_bypass_c1         = store_data_bypass_c1 & ~store_data_bypass_i0_e2_c2;
         lsu_p.store_data_bypass_c2         = store_data_bypass_c2 & ~store_data_bypass_i0_e2_c2;
         lsu_p.store_data_bypass_e4_c1[1:0] = store_data_bypass_e4_c1[1:0] & ~{2{store_data_bypass_i0_e2_c2}};
         lsu_p.store_data_bypass_e4_c2[1:0] = store_data_bypass_e4_c2[1:0] & ~{2{store_data_bypass_i0_e2_c2}};
         lsu_p.store_data_bypass_e4_c3[1:0] = store_data_bypass_e4_c3[1:0] & ~{2{store_data_bypass_i0_e2_c2}};

         lsu_p.unsign = (i0_dp.lsu) ? i0_dp.unsign : i1_dp.unsign;

         lsu_p.valid = lsu_decode_d;
      end

   end




   
   assign i0r.rs1[4:0] = i0[19:15];
   assign i0r.rs2[4:0] = i0[24:20];
   assign i0r.rd[4:0] = i0[11:7];

   assign i1r.rs1[4:0] = i1[19:15];
   assign i1r.rs2[4:0] = i1[24:20];
   assign i1r.rd[4:0] = i1[11:7];


   assign dec_i0_rs1_en_d = i0_dp.rs1 & (i0r.rs1[4:0] != 5'd0) & i0_valid_d;     assign dec_i0_rs2_en_d = i0_dp.rs2 & (i0r.rs2[4:0] != 5'd0) & i0_valid_d;
   assign i0_rd_en_d      =  i0_dp.rd & (i0r.rd[4:0] != 5'd0)  & i0_valid_d;

   assign dec_i0_rs1_d[4:0] = i0r.rs1[4:0];
   assign dec_i0_rs2_d[4:0] = i0r.rs2[4:0];


   assign i0_jalimm20 = i0_dp.jal & i0_dp.imm20;      assign i1_jalimm20 = i1_dp.jal & i1_dp.imm20;


   assign i0_uiimm20 = ~i0_dp.jal & i0_dp.imm20;
   assign i1_uiimm20 = ~i1_dp.jal & i1_dp.imm20;


   
   assign dec_i0_csr_ren_d = i0_dp.csr_read & i0_legal_decode_d & ~i0_br_error_all;

   assign i0_csr_clr_d =   i0_dp.csr_clr   & i0_legal_decode_d & ~i0_br_error_all;
   assign i0_csr_set_d   = i0_dp.csr_set   & i0_legal_decode_d & ~i0_br_error_all;
   assign i0_csr_write_d = i0_csr_write    & i0_legal_decode_d & ~i0_br_error_all;

   assign i0_csr_write_only_d = i0_csr_write & ~i0_dp.csr_read;

   assign dec_i0_csr_wen_unq_d = (i0_dp.csr_clr | i0_dp.csr_set | i0_csr_write);   
   assign dec_i0_csr_any_unq_d = i0_any_csr_d;


   assign dec_i0_csr_rdaddr_d[11:0] = i0[31:20];
   assign dec_i0_csr_wraddr_wb[11:0] = wbd.i0csrwaddr[11:0];

   assign dec_i0_csr_is_mcpc_e4 = (e4d.i0csrwaddr[11:0] == 12'h7c2);

         assign dec_i0_csr_wen_wb = wbd.i0csrwen & wbd.i0valid & ~dec_tlu_i0_kill_writeb_wb;

            for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign dec_csr_stall_int_ff[i] = (i==e4d.i0tid) & ((e4d.i0csrwaddr[11:0] == 12'h300) | (e4d.i0csrwaddr[11:0] == 12'h304)) & e4d.i0csrwen & e4d.i0valid & (~dec_tlu_i0_kill_writeb_wb | (e4d.i0tid != wbd.i0tid));

   end

      assign dec_csr_nmideleg_e4 = (e4d.i0csrwaddr[11:0] == 12'h7fe) & e4d.i0csrwen & e4d.i0valid & ~dec_tlu_i0_kill_writeb_wb & ~flush_lower_wb[e4d.i0tid];

   rvdff #(5) i0_csrmiscff (.*,
                        .clk(active_clk),
                        .din({ dec_i0_csr_ren_d,  i0_csr_clr_d,  i0_csr_set_d,  i0_csr_write_d,  i0_dp.csr_imm}),
                        .dout({i0_csr_read_e1,    i0_csr_clr_e1, i0_csr_set_e1, i0_csr_write_e1, i0_csr_imm_e1})
                       );

   rvdffe #(37) i0_csr_data_e1ff (.*, .en(i0_e1_data_en), .din( {i0[19:15],dec_i0_csr_rddata_d[31:0]}), .dout({i0_csrimm_e1[4:0],i0_csr_rddata_e1[31:0]}));



   assign i0_csr_mask_e1[31:0] = ({32{ i0_csr_imm_e1}} & {27'b0,i0_csrimm_e1[4:0]}) |
                              ({32{~i0_csr_imm_e1}} &  exu_i0_csr_rs1_e1[31:0]);


   assign i0_write_csr_data_e1[31:0] = ({32{i0_csr_clr_e1}}   & (i0_csr_rddata_e1[31:0] & ~i0_csr_mask_e1[31:0])) |
                                       ({32{i0_csr_set_e1}}   & (i0_csr_rddata_e1[31:0] |  i0_csr_mask_e1[31:0])) |
                                       ({32{i0_csr_write_e1}} & (                          i0_csr_mask_e1[31:0]));


      if (pt.NUM_THREADS==1) begin

      rvdff #(2) pause_state_r_ff (.*, .clk(free_clk), .din({dec_tlu_wr_pause_wb[0],tlu_wr_pause_wb1[0]}), .dout({tlu_wr_pause_wb1[0],tlu_wr_pause_wb2[0]}));

      assign dec_pause_state_cg = pause_state[0] & ~tlu_wr_pause_wb1[0] & ~tlu_wr_pause_wb2[0];

   end
   else begin  
      assign dec_pause_state_cg = 1'b0;

   end


   assign dec_pause_state[pt.NUM_THREADS-1:0] = pause_state[pt.NUM_THREADS-1:0];





   assign i0_csr_update_e1 = (i0_csr_clr_e1  | i0_csr_set_e1 | i0_csr_write_e1) & i0_csr_read_e1;


      for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign csr_update_e1[i] = (e1d.i0tid==i) & i0_csr_update_e1;


      assign write_csr_data_e1[i] = i0_write_csr_data_e1[31:0];


      
      assign write_csr_data_wb[i] = dec_i0_csr_wrdata_wb[31:0];

      assign clear_pause[i] = (flush_lower_wb[i] & ~dec_tlu_flush_pause_wb[i]) |
                              (pause_state[i] & (write_csr_data[i][31:1] == 31'b0));        
      assign pause_state_in[i] = (dec_tlu_wr_pause_wb[i] | pause_state[i]) & ~clear_pause[i];

          rvdff #(1) pause_state_f (.*, .clk(free_clk), .din(pause_state_in[i]), .dout(pause_state[i]));

     
      assign csr_data_wen[i] = csr_update_e1[i] | dec_tlu_wr_pause_wb[i] | pause_state[i];

      assign write_csr_data_in[i][31:0] = (pause_state[i])               ? (write_csr_data[i][31:0] - 32'b1) :
                                          (dec_tlu_wr_pause_wb[i]) ?  write_csr_data_wb[i][31:0] : write_csr_data_e1[i][31:0];
rvdffe #(32) write_csr_ff (.*, .en(csr_data_wen[i]), .din(write_csr_data_in[i][31:0]), .dout(write_csr_data[i][31:0]));

           
      assign pause_stall[i] = pause_state[i];

   end


      assign dec_i0_csr_wrdata_wb[31:0] = (wbd.i0csrwonly) ? i0_result_wb[31:0] : write_csr_data[wbd.i0tid][31:0];


   assign dec_i0_immed_d[31:0] = ({32{ i0_dp.csr_read}} & dec_i0_csr_rddata_d[31:0]) |
                                 ({32{~i0_dp.csr_read}} & i0_immed_d[31:0]);


   assign     i0_immed_d[31:0] = ({32{i0_dp.imm12}} &   { {20{i0[31]}},i0[31:20] }) |                                   ({32{i0_dp.shimm5}} &    {27'b0, i0[24:20]}) |
                                 ({32{i0_jalimm20}} &   { {12{i0[31]}},i0[19:12],i0[20],i0[30:21],1'b0}) |
                                 ({32{i0_uiimm20}}  &     {i0[31:12],12'b0 }) |
                                 ({32{i0_csr_write_only_d & i0_dp.csr_imm}} & {27'b0,i0[19:15]});  

         assign dec_i0_br_immed_d[12:1] = (i0_ap.predict_nt & ~i0_dp.jal) ? i0_br_offset[11:0] : {10'b0,i0_ap_pc4,i0_ap_pc2};


   assign dec_i1_rs1_en_d = i1_dp.rs1 & (i1r.rs1[4:0] != 5'd0) & i1_valid_d;
   assign dec_i1_rs2_en_d = i1_dp.rs2 & (i1r.rs2[4:0] != 5'd0) & i1_valid_d;
   assign i1_rd_en_d      = i1_dp.rd  & (i1r.rd[4:0] != 5'd0)  & i1_valid_d;

   assign dec_i1_rs1_d[4:0] = i1r.rs1[4:0];
   assign dec_i1_rs2_d[4:0] = i1r.rs2[4:0];


   assign i1_immed_d[31:0] = ({32{i1_dp.imm12}} &   { {20{i1[31]}},i1[31:20] }) |
                             ({32{i1_dp.shimm5}} &    {27'b0, i1[24:20]}) |
                             ({32{i1_jalimm20}} &   { {12{i1[31]}},i1[19:12],i1[20],i1[30:21],1'b0}) |
                             ({32{i1_uiimm20}}  &     {i1[31:12],12'b0 });


   assign dec_i1_immed_d[31:0] = i1_immed_d[31:0];


      assign dec_i1_br_immed_d[12:1] = (i1_ap.predict_nt & ~i1_dp.jal) ? i1_br_offset[11:0] : {10'b0,i1_ap_pc4,i1_ap_pc2};




   assign i0_valid_d = dec_ib0_valid_d;
   assign i1_valid_d = dec_ib1_valid_d;

   
   assign i0_amo_stall_d =   i0_dp.atomic & lsu_amo_stall_any[dd.i0tid];

   assign i0_load_stall_d = i0_dp.load & (lsu_load_stall_any[dd.i0tid] | dma_dccm_stall_any);

   assign i1_load_stall_d = i1_dp.load & (lsu_load_stall_any[dd.i1tid] | dma_dccm_stall_any);

   assign i0_store_stall_d =  i0_dp.store & (lsu_store_stall_any[dd.i0tid] | dma_dccm_stall_any);
   assign i1_store_stall_d =  i1_dp.store & (lsu_store_stall_any[dd.i1tid] | dma_dccm_stall_any);

   assign i1_depend_i0_d = ((dec_i1_rs1_en_d & i0_dp.rd & (i1r.rs1[4:0] == i0r.rd[4:0])) |
                            (dec_i1_rs2_en_d & i0_dp.rd & (i1r.rs2[4:0] == i0r.rd[4:0])))  & (dd.i0tid == dd.i1tid);



   assign i1_load2_block_d = i1_dp.lsu & i0_dp.lsu;



   assign i0_presync = i0_dp.presync | dec_tlu_presync_d[dd.i0tid] | debug_fence_i | debug_fence_raw | dec_tlu_pipelining_disable;  
   assign i0_postsync = i0_dp.postsync | dec_tlu_postsync_d[dd.i0tid] | debug_fence_i |                         (i0_csr_write_only_d & (i0[31:20] == 12'h7c2));   
   assign i1_mul2_block_d  = i1_dp.mul & i0_dp.mul;



   assign debug_fence_i     = dec_debug_fence_d & dbg_cmd_wrdata[0];
   assign debug_fence_raw   = dec_debug_fence_d & dbg_cmd_wrdata[1];

   assign debug_fence = debug_fence_raw | debug_fence_i;    

   assign i0_csr_write = i0_dp.csr_write & ~dec_debug_fence_d;






always @* begin
   i0blockp.csr_read_stall      = (i0_dp.csr_read & (dec_i0_csr_global_d ? prior_any_csr_write_any_thread : prior_csr_write[dd.i0tid]));    i0blockp.extint_stall        = dec_extint_stall & i0_dp.lsu;                               i0blockp.i1_cancel_e1_stall  = dec_i1_cancel_e1[dd.i0tid];                                 i0blockp.pause_stall         = pause_stall[dd.i0tid];
   i0blockp.leak1_stall         = leak1_i0_stall[dd.i0tid];                                   i0blockp.debug_stall         = dec_tlu_debug_stall[dd.i0tid];                              i0blockp.postsync_stall      = postsync_stall[dd.i0tid];
   i0blockp.presync_stall       = presync_stall[dd.i0tid];
   i0blockp.wait_lsu_idle_stall = ((i0_dp.fence | debug_fence | i0_dp.atomic) & ~lsu_idle[dd.i0tid]);      i0blockp.nonblock_load_stall = cam_i0_nonblock_load_stall[dd.i0tid];
   i0blockp.nonblock_div_stall  = i0_nonblock_div_stall;
   i0blockp.prior_div_stall     = i0_div_prior_div_stall;
   i0blockp.load_stall          = i0_load_stall_d ;
   i0blockp.store_stall         = i0_store_stall_d;
   i0blockp.amo_stall           = i0_amo_stall_d  ;
   i0blockp.load_block          = i0_load_block_d ;
   i0blockp.mul_block           = i0_mul_block_d      ;
   i0blockp.secondary_block     = i0_secondary_block_d;
   i0blockp.secondary_stall     = i0_secondary_stall_d;

   i1blockp.debug_valid_stall    = dec_i1_debug_valid_d;                        i1blockp.nonblock_load_stall  = cam_i1_nonblock_load_stall[dd.i1tid];
   i1blockp.wait_lsu_idle_stall  = i1_dp.atomic & ~lsu_idle[dd.i1tid];          i1blockp.extint_stall         = dec_extint_stall & i1_dp.lsu;                i1blockp.i1_cancel_e1_stall   = dec_i1_cancel_e1[dd.i1tid];                  i1blockp.pause_stall          = pause_stall[dd.i1tid];
   i1blockp.debug_stall          = dec_tlu_debug_stall[dd.i1tid];
   i1blockp.postsync_stall       = postsync_stall[dd.i1tid];
   i1blockp.presync_stall        = presync_stall[dd.i1tid];
   i1blockp.nonblock_div_stall   = i1_nonblock_div_stall;
   i1blockp.load_stall           = i1_load_stall_d;
   i1blockp.store_stall          = i1_store_stall_d;
   i1blockp.load_block           = i1_load_block_d;
   i1blockp.mul_block            = i1_mul_block_d;
   i1blockp.load2_block          = i1_load2_block_d;                            i1blockp.mul2_block           = i1_mul2_block_d;                             i1blockp.secondary_block      = i1_secondary_block_d;                        i1blockp.leak1_stall          = leak1_i1_stall[dd.i1tid];
   i1blockp.i0_only_block        = i1_dp.i0_only;
   i1blockp.icaf_block           = i1_icaf_d;
   i1blockp.barrier_block        = 1'b0;
   i1blockp.block_same_thread    = i1_block_same_thread_d & (dd.i0tid == dd.i1tid);


end

   assign i0_div_prior_div_stall = i0_dp.div & div_stall;

   assign i0_block_d = |i0blockp;

   assign i1_block_d = |i1blockp;

   assign i1_depend_i0_case_d = (i1_depend_i0_d & ~non_block_case_d & ~store_data_bypass_i0_e2_c2);


   assign i1_block_same_thread_d =  i0_jal |               
                                    i0_presync |
                                    i0_postsync |

                                    i0_dp.csr_read  |                                          i0_dp.csr_write |

                                    dec_tlu_dual_issue_disable |

                                    i1_depend_i0_case_d;





   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
      assign dec_thread_stall_in[i] =
                                                                           (i0_valid_d & i0_mul_block_thread_1cycle_d & (dd.i0tid==i)) |
                                      (i1_valid_d & i1_mul_block_thread_1cycle_d & (dd.i1tid==i) & (dd.i0tid!=dd.i1tid)) |

                                                                           (i0_valid_d & i0_secondary_stall_thread_1cycle_d & (dd.i0tid==i)) |
                                      (i0_valid_d & i0_secondary_block_thread_1cycle_d & (dd.i0tid==i)) |
                                      (i1_valid_d & i1_secondary_block_thread_1cycle_d & (dd.i1tid==i) & (dd.i0tid!=dd.i1tid)) |

                                                                           smt_secondary_stall[i]           |

                                      smt_csr_write_stall_in[i]        |

                                      smt_atomic_stall_in[i]           |

                                      smt_div_stall_in[i]              |

                                      pause_state_in[i]                |
                                      postsync_stall_in[i]             |
                                      smt_presync_stall_in[i]          |

                                      smt_nonblock_load_stall[i];  

   end


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign flush_all[i] = flush_lower_wb[i] | flush_final_e3[i];

            assign smt_secondary_stall_in[i] = ((i0_valid_d & i0_secondary_stall_thread_2cycle_d & (dd.i0tid==i)) |
                                          (i0_valid_d & i0_secondary_block_thread_2cycle_d & (dd.i0tid==i)) |
                                          (i1_valid_d & i1_secondary_block_thread_2cycle_d & (dd.i1tid==i) & (dd.i0tid!=dd.i1tid))) & ~flush_all[i];

      
            assign smt_secondary_stall[i] = (smt_secondary_stall_in[i] | smt_secondary_stall_raw[i]) & ~flush_all[i];
            rvdff #(1) secondary_stallff (.*, .clk(free_clk), .din(smt_secondary_stall_in[i]), .dout(smt_secondary_stall_raw[i]));

            assign set_smt_presync_stall[i] = i0_valid_d & i0_presync & prior_inflight_e1e4[i] & (dd.i0tid==i) & ~flush_all[i];

      assign smt_presync_stall_in[i] =  set_smt_presync_stall[i] | smt_presync_stall[i];


      
      assign smt_presync_stall[i] = smt_presync_stall_raw[i] & prior_inflight_e1e4[i] & ~flush_all[i];
          rvdff #(1) presync_stallff (.*, .clk(free_clk), .din(smt_presync_stall_in[i]), .dout(smt_presync_stall_raw[i]));

            assign set_smt_csr_write_stall[i] = i0_valid_d & i0_dp.csr_read & ~dec_i0_csr_global_d & prior_csr_write_e1e4[i] & (dd.i0tid==i) & ~flush_all[i];

      assign smt_csr_write_stall_in[i] =  set_smt_csr_write_stall[i] | smt_csr_write_stall[i];

      
      assign smt_csr_write_stall[i] = smt_csr_write_stall_raw[i] & prior_csr_write_e1e4[i] & ~flush_all[i];
rvdff #(1) csr_write_stallff (.*, .clk(free_clk), .din(smt_csr_write_stall_in[i]), .dout(smt_csr_write_stall_raw[i]));

            assign set_smt_atomic_stall[i] = i0_valid_d & (i0_dp.fence | i0_dp.atomic) & ~lsu_idle[i] & (dd.i0tid==i) & ~flush_all[i];

      assign smt_atomic_stall_in[i] =  set_smt_atomic_stall[i] | smt_atomic_stall[i];

    rvdff #(1) atomic_stallff (.*, .clk(free_clk), .din(smt_atomic_stall_in[i]), .dout(smt_atomic_stall_raw[i]));

      assign smt_atomic_stall[i] = smt_atomic_stall_raw[i] & ~lsu_idle[i] & ~flush_all[i];

            assign set_smt_div_stall[i] =
                                    ((i0_valid_d & i0_dp.div & div_valid   & (dd.i0tid==i) & (dd.i0tid==div_tid)) |
                                     (i1_valid_d & i1_dp.div & div_valid   & (dd.i1tid==i) & (dd.i1tid==div_tid) & (dd.i0tid!=dd.i1tid)) |
                                     (i0_valid_d  & i0_nonblock_div_stall  & (dd.i0tid==i))  |
                                     (i1_valid_d  & i1_nonblock_div_stall  & (dd.i1tid==i) & (dd.i0tid!=dd.i1tid))) & ~flush_all[i];

      assign smt_div_stall_in[i] =  set_smt_div_stall[i] | smt_div_stall[i];
rvdff #(1) div_stallff (.*, .clk(free_clk), .din(smt_div_stall_in[i]), .dout(smt_div_stall_raw[i]));

      
      assign smt_div_stall[i] = smt_div_stall_raw[i] & div_valid & ~flush_all[i];


            assign set_smt_nonblock_load_stall[i] = i0_valid_d & cam_i0_nonblock_load_stall[i] & (dd.i0tid==i) & ~flush_all[i];

      assign smt_nonblock_load_stall_in[i] =  set_smt_nonblock_load_stall[i] | smt_nonblock_load_stall[i];
rvdff #(1) nonblock_load_stallff (.*, .clk(free_clk), .din(smt_nonblock_load_stall_in[i]), .dout(smt_nonblock_load_stall_raw[i]));

      
      assign smt_nonblock_load_stall[i] = smt_nonblock_load_stall_raw[i] & cam_nonblock_load_stall[i] & ~flush_all[i];

   end



   

   assign i0_any_csr_d = i0_dp.csr_read | i0_csr_write;

   assign i0_csr_legal_d = dec_i0_csr_legal_d;


   assign i0_legal = i0_dp.legal & (~i0_any_csr_d | i0_csr_legal_d);

   assign i0_legal_except_csr = i0_dp.legal;

   assign i1_legal = i1_dp.legal;

   
   assign i0_inst_d[31:0] = (dec_i0_pc4_d) ? i0[31:0] : {16'b0, dec_i0_cinst_d[15:0] };

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin : illegal

      assign shift_illegal[i] = dec_i0_decode_d & ~i0_legal & (i == dd.i0tid);

      assign illegal_inst_en[i] = shift_illegal[i] & ~illegal_lockout[i];

      assign illegal_lockout_in[i] = (shift_illegal[i] | illegal_lockout[i]) & ~flush_final_e3[i];
rvdffe #(32) illegal_any_ff  (.*,
                                    .en(illegal_inst_en[i]),
                                    .din(i0_inst_d[31:0]),
                                    .dout(illegal_inst[i][31:0]));

      rvdff #(1) illegal_lockout_any_ff (.*, .clk(active_clk), .din(illegal_lockout_in[i]), .dout(illegal_lockout[i]));



   end

   assign dec_illegal_inst[pt.NUM_THREADS-1:0] = illegal_inst[pt.NUM_THREADS-1:0];





      assign dec_i0_decode_d = i0_valid_d & ~i0_block_d & ~flush_lower_wb[dd.i0tid] & ~flush_final_e3[dd.i0tid];

      assign i0_legal_decode_d = dec_i0_decode_d & i0_legal;

   
   assign dec_i1_decode_d = (dd.i0tid==dd.i1tid) ? (dec_i0_decode_d & i0_legal_except_csr & i1_valid_d & i1_legal & ~i1_block_d & ~flush_lower_wb[dd.i1tid] & ~flush_final_e3[dd.i1tid]) :
                                                   (                  i0_legal_except_csr & i1_valid_d & i1_legal & ~i1_block_d & ~flush_lower_wb[dd.i1tid] & ~flush_final_e3[dd.i1tid]);


   assign i1_legal_decode_d = dec_i1_decode_d & i1_legal;


      for (genvar i=0; i<pt.NUM_THREADS; i++) begin
      assign dec_pmu_instr_decoded[i][1:0] = { dec_i1_decode_d & (dd.i1tid==i), dec_i0_decode_d & (dd.i0tid==i) };
   end

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
      assign dec_pmu_decode_stall[i] = ((i == dd.i0tid) & i0_valid_d & ~dec_i0_decode_d) |
                                       ((i == dd.i1tid) & i1_valid_d & ~dec_i1_decode_d & (dd.i0tid!=dd.i1tid));
   end


   assign dec_pmu_postsync_stall[pt.NUM_THREADS-1:0] = postsync_stall[pt.NUM_THREADS-1:0];

   assign dec_pmu_presync_stall[pt.NUM_THREADS-1:0]  = presync_stall[pt.NUM_THREADS-1:0];

   
   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
      
      assign presync_stall[i] = i0_valid_d & i0_presync & (dd.i0tid==i) & prior_inflight[i];

            assign base_postsync_stall_in[i] =  (dec_i0_decode_d & (dd.i0tid == i) & (i0_postsync | ~i0_legal))  |
                                          (base_postsync_stall[i] & prior_inflight_e1e4[i]);

rvdff #(1) base_postsync_stallff (.*, .clk(free_clk), .din(base_postsync_stall_in[i]), .dout(base_postsync_stall[i]));

     
                  assign jal_postsync_stall_in[i] = (dec_i0_decode_d & (dd.i0tid == i) & i0_jal)  |
                                        (dec_i1_decode_d & (dd.i1tid == i) & i1_jal ) |
                                        (jal_postsync_stall[i] & prior_inflight_e1e3[i]);

rvdff #(1) jal_postsync_stallff (.*, .clk(free_clk), .din(jal_postsync_stall_in[i]), .dout(jal_postsync_stall[i]));

     
      assign postsync_stall_in[i] = base_postsync_stall_in[i] | jal_postsync_stall_in[i];

      assign postsync_stall[i] = base_postsync_stall[i] | jal_postsync_stall[i];


      assign prior_inflight_e1e3[i] =    |{ e1d.i0valid & (e1d.i0tid == i),
                                            e2d.i0valid & (e2d.i0tid == i),
                                            e3d.i0valid & (e3d.i0tid == i),
                                            e1d.i1valid & (e1d.i1tid == i),
                                            e2d.i1valid & (e2d.i1tid == i),
                                            e3d.i1valid & (e3d.i1tid == i)
                                            };

      assign prior_inflight_e1e4[i] =    |{ prior_inflight_e1e3[i],
                                            e4d.i0valid & (e4d.i0tid == i),
                                            e4d.i1valid & (e4d.i1tid == i)
                                            };


      assign prior_inflight_wb[i] =            |{
                                                 wbd.i0valid & (wbd.i0tid == i),
                                                 wbd.i1valid & (wbd.i1tid == i)
                                                 };


      assign prior_inflight[i] = prior_inflight_e1e4[i] | prior_inflight_wb[i];


      
      assign prior_csr_write_e1e4[i] = (e1d.i0csrwonly & (e1d.i0tid==i)) |
                                       (e2d.i0csrwonly & (e2d.i0tid==i)) |
                                       (e3d.i0csrwonly & (e3d.i0tid==i)) |
                                       (e4d.i0csrwonly & (e4d.i0tid==i));

      assign prior_csr_write[i] = prior_csr_write_e1e4[i] |
                                  (wbd.i0csrwonly & (wbd.i0tid==i));



   end

   assign prior_any_csr_write_any_thread_e1e4 = (e1d.i0csrwen) |
                                                (e2d.i0csrwen) |
                                                (e3d.i0csrwen) |
                                                (e4d.i0csrwen);

   assign prior_any_csr_write_any_thread = prior_any_csr_write_any_thread_e1e4 |
                                           (wbd.i0csrwen);


   assign dec_i0_alu_decode_d = i0_legal_decode_d & i0_dp.alu & ~i0_secondary_d & ~i0_br_error_all;
   assign dec_i1_alu_decode_d = i1_legal_decode_d & i1_dp.alu & ~i1_secondary_d & ~i1_br_error_all;

   assign lsu_decode_d = (i0_legal_decode_d & i0_dp.lsu & ~i0_br_error_all) |
                         (i1_legal_decode_d & i1_dp.lsu & ~i1_br_error_all);

   assign mul_decode_d = (i0_legal_decode_d & i0_dp.mul & ~i0_br_error_all) |
                         (i1_legal_decode_d & i1_dp.mul & ~i1_br_error_all);


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      
       rvdff #(1) flushff  (.*, .clk(free_clk), .din(exu_i0_flush_final[i]), .dout(i0_flush_final_e3[i]));

      rvdff #(1) flushff1 (.*, .clk(free_clk), .din(exu_i1_flush_final[i]), .dout(i1_flush_final_e3[i]));

      rvdff #(1) flushff2 (.*, .clk(free_clk), .din( i0_flush_final_e3[i]),   .dout( i0_flush_final_e4[i]));

      
      assign flush_final_e3[i] = i0_flush_final_e3[i] | i1_flush_final_e3[i];

   end



   assign i0_rs1_depend_i0_e1 = dec_i0_rs1_en_d & e1d.i0v & (e1d.i0rd[4:0] == i0r.rs1[4:0]) & (e1d.i0tid == dd.i0tid);
   assign i0_rs1_depend_i0_e2 = dec_i0_rs1_en_d & e2d.i0v & (e2d.i0rd[4:0] == i0r.rs1[4:0]) & (e2d.i0tid == dd.i0tid);
   assign i0_rs1_depend_i0_e3 = dec_i0_rs1_en_d & e3d.i0v & (e3d.i0rd[4:0] == i0r.rs1[4:0]) & (e3d.i0tid == dd.i0tid);
   assign i0_rs1_depend_i0_e4 = dec_i0_rs1_en_d & e4d.i0v & (e4d.i0rd[4:0] == i0r.rs1[4:0]) & (e4d.i0tid == dd.i0tid);
   assign i0_rs1_depend_i0_wb = dec_i0_rs1_en_d & wbd.i0v & (wbd.i0rd[4:0] == i0r.rs1[4:0]) & (wbd.i0tid == dd.i0tid);

   assign i0_rs1_depend_i1_e1 = dec_i0_rs1_en_d & e1d.i1v & (e1d.i1rd[4:0] == i0r.rs1[4:0]) & (e1d.i1tid == dd.i0tid);
   assign i0_rs1_depend_i1_e2 = dec_i0_rs1_en_d & e2d.i1v & (e2d.i1rd[4:0] == i0r.rs1[4:0]) & (e2d.i1tid == dd.i0tid);
   assign i0_rs1_depend_i1_e3 = dec_i0_rs1_en_d & e3d.i1v & (e3d.i1rd[4:0] == i0r.rs1[4:0]) & (e3d.i1tid == dd.i0tid);
   assign i0_rs1_depend_i1_e4 = dec_i0_rs1_en_d & e4d.i1v & (e4d.i1rd[4:0] == i0r.rs1[4:0]) & (e4d.i1tid == dd.i0tid);
   assign i0_rs1_depend_i1_wb = dec_i0_rs1_en_d & wbd.i1v & (wbd.i1rd[4:0] == i0r.rs1[4:0]) & (wbd.i1tid == dd.i0tid);

   assign i0_rs2_depend_i0_e1 = dec_i0_rs2_en_d & e1d.i0v & (e1d.i0rd[4:0] == i0r.rs2[4:0]) & (e1d.i0tid == dd.i0tid);
   assign i0_rs2_depend_i0_e2 = dec_i0_rs2_en_d & e2d.i0v & (e2d.i0rd[4:0] == i0r.rs2[4:0]) & (e2d.i0tid == dd.i0tid);
   assign i0_rs2_depend_i0_e3 = dec_i0_rs2_en_d & e3d.i0v & (e3d.i0rd[4:0] == i0r.rs2[4:0]) & (e3d.i0tid == dd.i0tid);
   assign i0_rs2_depend_i0_e4 = dec_i0_rs2_en_d & e4d.i0v & (e4d.i0rd[4:0] == i0r.rs2[4:0]) & (e4d.i0tid == dd.i0tid);
   assign i0_rs2_depend_i0_wb = dec_i0_rs2_en_d & wbd.i0v & (wbd.i0rd[4:0] == i0r.rs2[4:0]) & (wbd.i0tid == dd.i0tid);

   assign i0_rs2_depend_i1_e1 = dec_i0_rs2_en_d & e1d.i1v & (e1d.i1rd[4:0] == i0r.rs2[4:0]) & (e1d.i1tid == dd.i0tid);
   assign i0_rs2_depend_i1_e2 = dec_i0_rs2_en_d & e2d.i1v & (e2d.i1rd[4:0] == i0r.rs2[4:0]) & (e2d.i1tid == dd.i0tid);
   assign i0_rs2_depend_i1_e3 = dec_i0_rs2_en_d & e3d.i1v & (e3d.i1rd[4:0] == i0r.rs2[4:0]) & (e3d.i1tid == dd.i0tid);
   assign i0_rs2_depend_i1_e4 = dec_i0_rs2_en_d & e4d.i1v & (e4d.i1rd[4:0] == i0r.rs2[4:0]) & (e4d.i1tid == dd.i0tid);
   assign i0_rs2_depend_i1_wb = dec_i0_rs2_en_d & wbd.i1v & (wbd.i1rd[4:0] == i0r.rs2[4:0]) & (wbd.i1tid == dd.i0tid);


   assign i1_rs1_depend_i0_e1 = dec_i1_rs1_en_d & e1d.i0v & (e1d.i0rd[4:0] == i1r.rs1[4:0]) & (e1d.i0tid == dd.i1tid);
   assign i1_rs1_depend_i0_e2 = dec_i1_rs1_en_d & e2d.i0v & (e2d.i0rd[4:0] == i1r.rs1[4:0]) & (e2d.i0tid == dd.i1tid);
   assign i1_rs1_depend_i0_e3 = dec_i1_rs1_en_d & e3d.i0v & (e3d.i0rd[4:0] == i1r.rs1[4:0]) & (e3d.i0tid == dd.i1tid);
   assign i1_rs1_depend_i0_e4 = dec_i1_rs1_en_d & e4d.i0v & (e4d.i0rd[4:0] == i1r.rs1[4:0]) & (e4d.i0tid == dd.i1tid);
   assign i1_rs1_depend_i0_wb = dec_i1_rs1_en_d & wbd.i0v & (wbd.i0rd[4:0] == i1r.rs1[4:0]) & (wbd.i0tid == dd.i1tid);

   assign i1_rs1_depend_i1_e1 = dec_i1_rs1_en_d & e1d.i1v & (e1d.i1rd[4:0] == i1r.rs1[4:0]) & (e1d.i1tid == dd.i1tid);
   assign i1_rs1_depend_i1_e2 = dec_i1_rs1_en_d & e2d.i1v & (e2d.i1rd[4:0] == i1r.rs1[4:0]) & (e2d.i1tid == dd.i1tid);
   assign i1_rs1_depend_i1_e3 = dec_i1_rs1_en_d & e3d.i1v & (e3d.i1rd[4:0] == i1r.rs1[4:0]) & (e3d.i1tid == dd.i1tid);
   assign i1_rs1_depend_i1_e4 = dec_i1_rs1_en_d & e4d.i1v & (e4d.i1rd[4:0] == i1r.rs1[4:0]) & (e4d.i1tid == dd.i1tid);
   assign i1_rs1_depend_i1_wb = dec_i1_rs1_en_d & wbd.i1v & (wbd.i1rd[4:0] == i1r.rs1[4:0]) & (wbd.i1tid == dd.i1tid);

   assign i1_rs2_depend_i0_e1 = dec_i1_rs2_en_d & e1d.i0v & (e1d.i0rd[4:0] == i1r.rs2[4:0]) & (e1d.i0tid == dd.i1tid);
   assign i1_rs2_depend_i0_e2 = dec_i1_rs2_en_d & e2d.i0v & (e2d.i0rd[4:0] == i1r.rs2[4:0]) & (e2d.i0tid == dd.i1tid);
   assign i1_rs2_depend_i0_e3 = dec_i1_rs2_en_d & e3d.i0v & (e3d.i0rd[4:0] == i1r.rs2[4:0]) & (e3d.i0tid == dd.i1tid);
   assign i1_rs2_depend_i0_e4 = dec_i1_rs2_en_d & e4d.i0v & (e4d.i0rd[4:0] == i1r.rs2[4:0]) & (e4d.i0tid == dd.i1tid);
   assign i1_rs2_depend_i0_wb = dec_i1_rs2_en_d & wbd.i0v & (wbd.i0rd[4:0] == i1r.rs2[4:0]) & (wbd.i0tid == dd.i1tid);

   assign i1_rs2_depend_i1_e1 = dec_i1_rs2_en_d & e1d.i1v & (e1d.i1rd[4:0] == i1r.rs2[4:0]) & (e1d.i1tid == dd.i1tid);
   assign i1_rs2_depend_i1_e2 = dec_i1_rs2_en_d & e2d.i1v & (e2d.i1rd[4:0] == i1r.rs2[4:0]) & (e2d.i1tid == dd.i1tid);
   assign i1_rs2_depend_i1_e3 = dec_i1_rs2_en_d & e3d.i1v & (e3d.i1rd[4:0] == i1r.rs2[4:0]) & (e3d.i1tid == dd.i1tid);
   assign i1_rs2_depend_i1_e4 = dec_i1_rs2_en_d & e4d.i1v & (e4d.i1rd[4:0] == i1r.rs2[4:0]) & (e4d.i1tid == dd.i1tid);
   assign i1_rs2_depend_i1_wb = dec_i1_rs2_en_d & wbd.i1v & (wbd.i1rd[4:0] == i1r.rs2[4:0]) & (wbd.i1tid == dd.i1tid);


   assign dd.i0rs1bype2[1:0] = {  i0_dp.alu & i0_rs1_depth_d[3:0] == 4'd5 & i0_rs1_class_d.sec,
                                  i0_dp.alu & i0_rs1_depth_d[3:0] == 4'd6 & i0_rs1_class_d.sec };

   assign dd.i0rs2bype2[1:0] = {  i0_dp.alu & i0_rs2_depth_d[3:0] == 4'd5 & i0_rs2_class_d.sec,
                                  i0_dp.alu & i0_rs2_depth_d[3:0] == 4'd6 & i0_rs2_class_d.sec };

   assign dd.i1rs1bype2[1:0] = {  i1_dp.alu & i1_rs1_depth_d[3:0] == 4'd5 & i1_rs1_class_d.sec,
                                  i1_dp.alu & i1_rs1_depth_d[3:0] == 4'd6 & i1_rs1_class_d.sec };

   assign dd.i1rs2bype2[1:0] = {  i1_dp.alu & i1_rs2_depth_d[3:0] == 4'd5 & i1_rs2_class_d.sec,
                                  i1_dp.alu & i1_rs2_depth_d[3:0] == 4'd6 & i1_rs2_class_d.sec };


   assign i1_result_wb_eff[31:0] = i1_result_wb[31:0];

   assign i0_result_wb_eff[31:0] = i0_result_wb[31:0];


   assign i0_rs1_bypass_data_e2[31:0] = ({32{e2d.i0rs1bype2[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e2d.i0rs1bype2[0]}} & i0_result_wb_eff[31:0]);

   assign i0_rs2_bypass_data_e2[31:0] = ({32{e2d.i0rs2bype2[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e2d.i0rs2bype2[0]}} & i0_result_wb_eff[31:0]);

   assign i1_rs1_bypass_data_e2[31:0] = ({32{e2d.i1rs1bype2[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e2d.i1rs1bype2[0]}} & i0_result_wb_eff[31:0]);

   assign i1_rs2_bypass_data_e2[31:0] = ({32{e2d.i1rs2bype2[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e2d.i1rs2bype2[0]}} & i0_result_wb_eff[31:0]);


   assign dec_i0_rs1_bypass_en_e2 = |e2d.i0rs1bype2[1:0];
   assign dec_i0_rs2_bypass_en_e2 = |e2d.i0rs2bype2[1:0];
   assign dec_i1_rs1_bypass_en_e2 = |e2d.i1rs1bype2[1:0];
   assign dec_i1_rs2_bypass_en_e2 = |e2d.i1rs2bype2[1:0];




   assign i1_rs1_depend_i0_d = dec_i1_rs1_en_d & i0_dp.rd & (i1r.rs1[4:0] == i0r.rd[4:0]) & (dd.i1tid == dd.i0tid);
   assign i1_rs2_depend_i0_d = dec_i1_rs2_en_d & i0_dp.rd & (i1r.rs2[4:0] == i0r.rd[4:0]) & (dd.i1tid == dd.i0tid);


   assign dd.i0rs1bype3[3:0] = { i0_dp.alu & i0_rs1_depth_d[3:0]==4'd1 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd2 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd3 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                 i0_dp.alu & i0_rs1_depth_d[3:0]==4'd4 & (i0_rs1_class_d.sec | i0_rs1_class_d.load | i0_rs1_class_d.mul) };

   assign dd.i0rs2bype3[3:0] = { i0_dp.alu & i0_rs2_depth_d[3:0]==4'd1 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd2 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd3 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                 i0_dp.alu & i0_rs2_depth_d[3:0]==4'd4 & (i0_rs2_class_d.sec | i0_rs2_class_d.load | i0_rs2_class_d.mul) };


   assign i1rs1_intra[2:0] = {   i1_dp.alu & i0_dp.alu  & i1_rs1_depend_i0_d,
                                 i1_dp.alu & i0_dp.mul  & i1_rs1_depend_i0_d,
                                 i1_dp.alu & i0_dp.load & i1_rs1_depend_i0_d
                                 };

   assign i1rs2_intra[2:0] = {   i1_dp.alu & i0_dp.alu  & i1_rs2_depend_i0_d,
                                 i1_dp.alu & i0_dp.mul  & i1_rs2_depend_i0_d,
                                 i1_dp.alu & i0_dp.load & i1_rs2_depend_i0_d
                                 };

   assign i1_rs1_intra_bypass = |i1rs1_intra[2:0];

   assign i1_rs2_intra_bypass = |i1rs2_intra[2:0];


   assign dd.i1rs1bype3[6:0] = { i1rs1_intra[2:0],
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd1 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd2 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd3 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass,
                                 i1_dp.alu & i1_rs1_depth_d[3:0]==4'd4 & (i1_rs1_class_d.sec | i1_rs1_class_d.load | i1_rs1_class_d.mul) & ~i1_rs1_intra_bypass };

   assign dd.i1rs2bype3[6:0] = { i1rs2_intra[2:0],
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd1 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd2 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd3 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass,
                                 i1_dp.alu & i1_rs2_depth_d[3:0]==4'd4 & (i1_rs2_class_d.sec | i1_rs2_class_d.load | i1_rs2_class_d.mul) & ~i1_rs2_intra_bypass };




   assign dec_i0_rs1_bypass_en_e3 = |e3d.i0rs1bype3[3:0];
   assign dec_i0_rs2_bypass_en_e3 = |e3d.i0rs2bype3[3:0];
   assign dec_i1_rs1_bypass_en_e3 = |e3d.i1rs1bype3[6:0];
   assign dec_i1_rs2_bypass_en_e3 = |e3d.i1rs2bype3[6:0];



   assign i1_result_e4_eff[31:0] = i1_result_e4_final[31:0];

   assign i0_result_e4_eff[31:0] = i0_result_e4_final[31:0];


   assign i0_rs1_bypass_data_e3[31:0] = ({32{e3d.i0rs1bype3[3]}} & i1_result_e4_eff[31:0]) |
                                        ({32{e3d.i0rs1bype3[2]}} & i0_result_e4_eff[31:0]) |
                                        ({32{e3d.i0rs1bype3[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e3d.i0rs1bype3[0]}} & i0_result_wb_eff[31:0]);

   assign i0_rs2_bypass_data_e3[31:0] = ({32{e3d.i0rs2bype3[3]}} & i1_result_e4_eff[31:0]) |
                                        ({32{e3d.i0rs2bype3[2]}} & i0_result_e4_eff[31:0]) |
                                        ({32{e3d.i0rs2bype3[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e3d.i0rs2bype3[0]}} & i0_result_wb_eff[31:0]);

   assign i1_rs1_bypass_data_e3[31:0] = ({32{e3d.i1rs1bype3[6]}} & i0_result_e3[31:0]) |
                                        ({32{e3d.i1rs1bype3[5]}} & exu_mul_result_e3[31:0]) |
                                        ({32{e3d.i1rs1bype3[4]}} & lsu_result_dc3[31:0]) |
                                        ({32{e3d.i1rs1bype3[3]}} & i1_result_e4_eff[31:0]) |
                                        ({32{e3d.i1rs1bype3[2]}} & i0_result_e4_eff[31:0]) |
                                        ({32{e3d.i1rs1bype3[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e3d.i1rs1bype3[0]}} & i0_result_wb_eff[31:0]);


   assign i1_rs2_bypass_data_e3[31:0] = ({32{e3d.i1rs2bype3[6]}} & i0_result_e3[31:0]) |
                                        ({32{e3d.i1rs2bype3[5]}} & exu_mul_result_e3[31:0]) |
                                        ({32{e3d.i1rs2bype3[4]}} & lsu_result_dc3[31:0]) |
                                        ({32{e3d.i1rs2bype3[3]}} & i1_result_e4_eff[31:0]) |
                                        ({32{e3d.i1rs2bype3[2]}} & i0_result_e4_eff[31:0]) |
                                        ({32{e3d.i1rs2bype3[1]}} & i1_result_wb_eff[31:0]) |
                                        ({32{e3d.i1rs2bype3[0]}} & i0_result_wb_eff[31:0]);





   assign {i0_rs1_class_d, i0_rs1_depth_d[3:0]} =
                                                  (i0_rs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_rs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_rs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_rs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_rs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_rs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_rs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_rs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_rs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_rs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i0_rs2_class_d, i0_rs2_depth_d[3:0]} =
                                                  (i0_rs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i0_rs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i0_rs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i0_rs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i0_rs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i0_rs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i0_rs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i0_rs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i0_rs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i0_rs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i1_rs1_class_d, i1_rs1_depth_d[3:0]} =
                                                  (i1_rs1_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_rs1_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_rs1_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_rs1_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_rs1_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_rs1_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_rs1_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_rs1_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_rs1_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_rs1_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;

   assign {i1_rs2_class_d, i1_rs2_depth_d[3:0]} =
                                                  (i1_rs2_depend_i1_e1) ? { i1_e1c, 4'd1 } :
                                                  (i1_rs2_depend_i0_e1) ? { i0_e1c, 4'd2 } :
                                                  (i1_rs2_depend_i1_e2) ? { i1_e2c, 4'd3 } :
                                                  (i1_rs2_depend_i0_e2) ? { i0_e2c, 4'd4 } :
                                                  (i1_rs2_depend_i1_e3) ? { i1_e3c, 4'd5 } :
                                                  (i1_rs2_depend_i0_e3) ? { i0_e3c, 4'd6 } :
                                                  (i1_rs2_depend_i1_e4) ? { i1_e4c, 4'd7 } :
                                                  (i1_rs2_depend_i0_e4) ? { i0_e4c, 4'd8 } :
                                                  (i1_rs2_depend_i1_wb) ? { i1_wbc, 4'd9 } :
                                                  (i1_rs2_depend_i0_wb) ? { i0_wbc, 4'd10 } : '0;


   assign i0_rs1_match_e1 = (i0_rs1_depth_d[3:0] == 4'd1 |
                             i0_rs1_depth_d[3:0] == 4'd2);

   assign i0_rs1_match_e2 = (i0_rs1_depth_d[3:0] == 4'd3 |
                             i0_rs1_depth_d[3:0] == 4'd4);

   assign i0_rs1_match_e3 = (i0_rs1_depth_d[3:0] == 4'd5 |
                             i0_rs1_depth_d[3:0] == 4'd6);

   assign i0_rs2_match_e1 = (i0_rs2_depth_d[3:0] == 4'd1 |
                             i0_rs2_depth_d[3:0] == 4'd2);

   assign i0_rs2_match_e2 = (i0_rs2_depth_d[3:0] == 4'd3 |
                             i0_rs2_depth_d[3:0] == 4'd4);

   assign i0_rs2_match_e3 = (i0_rs2_depth_d[3:0] == 4'd5 |
                             i0_rs2_depth_d[3:0] == 4'd6);

   assign i0_rs1_match_e1_e2 = i0_rs1_match_e1 | i0_rs1_match_e2;
   assign i0_rs1_match_e1_e3 = i0_rs1_match_e1 | i0_rs1_match_e2 | i0_rs1_match_e3;

   assign i0_rs2_match_e1_e2 = i0_rs2_match_e1 | i0_rs2_match_e2;
   assign i0_rs2_match_e1_e3 = i0_rs2_match_e1 | i0_rs2_match_e2 | i0_rs2_match_e3;


   
   assign i0_secondary_block_thread_1cycle_d = (~i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e2) |
                                               (~i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e2 & ~i0_dp.store);

   assign i1_secondary_block_thread_1cycle_d = (~i1_dp.alu & i1_rs1_class_d.sec & i1_rs1_match_e2) |
                                               (~i1_dp.alu & i1_rs2_class_d.sec & i1_rs2_match_e2 & ~i1_dp.store);

   assign i0_secondary_block_thread_2cycle_d = (~i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1) |
                                               (~i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1 & ~i0_dp.store);

   assign i1_secondary_block_thread_2cycle_d = (~i1_dp.alu & i1_rs1_class_d.sec & i1_rs1_match_e1) |
                                               (~i1_dp.alu & i1_rs2_class_d.sec & i1_rs2_match_e1 & ~i1_dp.store);

   assign i0_secondary_stall_1cycle_d = (i0_dp.alu & (i0_rs1_class_d.load | i0_rs1_class_d.mul) & i0_rs1_match_e1) |
                                        (i0_dp.alu & (i0_rs2_class_d.load | i0_rs2_class_d.mul) & i0_rs2_match_e1) |
                                        (i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e2) |
                                        (i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e2);

   assign i0_secondary_stall_2cycle_d = (i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1) |
                                        (i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1);

   assign i0_secondary_stall_thread_1cycle_d = (i0_dp.alu & i1_rs1_depend_i0_d & ~i1_dp.alu & i0_secondary_stall_1cycle_d) |
                                               (i0_dp.alu & i1_rs2_depend_i0_d & ~i1_dp.alu & ~i1_dp.store & i0_secondary_stall_1cycle_d);

   assign i0_secondary_stall_thread_2cycle_d = (i0_dp.alu & i1_rs1_depend_i0_d & ~i1_dp.alu & i0_secondary_stall_2cycle_d) |
                                               (i0_dp.alu & i1_rs2_depend_i0_d & ~i1_dp.alu & ~i1_dp.store & i0_secondary_stall_2cycle_d);
   
   assign i0_secondary_d = (i0_dp.alu & (i0_rs1_class_d.load | i0_rs1_class_d.mul) & i0_rs1_match_e1_e2) |
                           (i0_dp.alu & (i0_rs2_class_d.load | i0_rs2_class_d.mul) & i0_rs2_match_e1_e2) |
                           (i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1_e3) |
                           (i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1_e3);

     assign i0_secondary_stall_d = (i0_dp.alu & i1_rs1_depend_i0_d & ~i1_dp.alu & i0_secondary_d) |
                                 (i0_dp.alu & i1_rs2_depend_i0_d & ~i1_dp.alu & ~i1_dp.store & i0_secondary_d);

   assign i1_rs1_match_e1 = (i1_rs1_depth_d[3:0] == 4'd1 |
                             i1_rs1_depth_d[3:0] == 4'd2);

   assign i1_rs1_match_e2 = (i1_rs1_depth_d[3:0] == 4'd3 |
                             i1_rs1_depth_d[3:0] == 4'd4);

   assign i1_rs1_match_e3 = (i1_rs1_depth_d[3:0] == 4'd5 |
                             i1_rs1_depth_d[3:0] == 4'd6);

   assign i1_rs2_match_e1 = (i1_rs2_depth_d[3:0] == 4'd1 |
                             i1_rs2_depth_d[3:0] == 4'd2);

   assign i1_rs2_match_e2 = (i1_rs2_depth_d[3:0] == 4'd3 |
                             i1_rs2_depth_d[3:0] == 4'd4);

   assign i1_rs2_match_e3 = (i1_rs2_depth_d[3:0] == 4'd5 |
                             i1_rs2_depth_d[3:0] == 4'd6);

   assign i1_rs1_match_e1_e2 = i1_rs1_match_e1 | i1_rs1_match_e2;
   assign i1_rs1_match_e1_e3 = i1_rs1_match_e1 | i1_rs1_match_e2 | i1_rs1_match_e3;

   assign i1_rs2_match_e1_e2 = i1_rs2_match_e1 | i1_rs2_match_e2;
   assign i1_rs2_match_e1_e3 = i1_rs2_match_e1 | i1_rs2_match_e2 | i1_rs2_match_e3;




   assign i1_secondary_d = (i1_dp.alu & (i1_rs1_class_d.load | i1_rs1_class_d.mul) & i1_rs1_match_e1_e2) |
                           (i1_dp.alu & (i1_rs2_class_d.load | i1_rs2_class_d.mul) & i1_rs2_match_e1_e2) |
                           (i1_dp.alu & (i1_rs1_class_d.sec) & i1_rs1_match_e1_e3) |
                           (i1_dp.alu & (i1_rs2_class_d.sec) & i1_rs2_match_e1_e3) |
                           (non_block_case_d & i1_depend_i0_d);



   assign store_data_bypass_i0_e2_c2 = i0_dp.alu & ~i0_secondary_d & i1_rs2_depend_i0_d & ~i1_rs1_depend_i0_d & i1_dp.store;

   assign non_block_case_d = (i1_dp.alu & i0_dp.load) |
                             (i1_dp.alu & i0_dp.mul);

   assign store_data_bypass_c2        =  (             i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd1) & i0_rs2_class_d.load) |
                                         (             i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd2) & i0_rs2_class_d.load) |
                                         (~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd1) & i1_rs2_class_d.load) |
                                         (~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd2) & i1_rs2_class_d.load);

   assign store_data_bypass_c1        =  (             i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd3) & i0_rs2_class_d.load) |
                                         (             i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd4) & i0_rs2_class_d.load) |
                                         (~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd3) & i1_rs2_class_d.load) |
                                         (~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd4) & i1_rs2_class_d.load);

if (pt.LOAD_TO_USE_PLUS1 == 1)
 begin
   assign load_ldst_bypass_c1        =  (             (i0_dp.load | i0_dp.store) & (i0_rs1_depth_d[3:0] == 4'd5) & i0_rs1_class_d.load) |
                                        (             (i0_dp.load | i0_dp.store) & (i0_rs1_depth_d[3:0] == 4'd6) & i0_rs1_class_d.load) |
                                        (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & (i1_rs1_depth_d[3:0] == 4'd5) & i1_rs1_class_d.load) |
                                        (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & (i1_rs1_depth_d[3:0] == 4'd6) & i1_rs1_class_d.load);
 end
else
 begin
   assign load_ldst_bypass_c1        =  (             (i0_dp.load | i0_dp.store) & (i0_rs1_depth_d[3:0] == 4'd3) & i0_rs1_class_d.load) |
                                        (             (i0_dp.load | i0_dp.store) & (i0_rs1_depth_d[3:0] == 4'd4) & i0_rs1_class_d.load) |
                                        (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & (i1_rs1_depth_d[3:0] == 4'd3) & i1_rs1_class_d.load) |
                                        (~i0_dp.lsu & (i1_dp.load | i1_dp.store) & (i1_rs1_depth_d[3:0] == 4'd4) & i1_rs1_class_d.load);
 end

   assign load_mul_rs1_bypass_e1     =  (             (i0_dp.mul) & (i0_rs1_depth_d[3:0] == 4'd3) & i0_rs1_class_d.load) |
                                        (             (i0_dp.mul) & (i0_rs1_depth_d[3:0] == 4'd4) & i0_rs1_class_d.load) |
                                        (~i0_dp.mul & (i1_dp.mul) & (i1_rs1_depth_d[3:0] == 4'd3) & i1_rs1_class_d.load) |
                                        (~i0_dp.mul & (i1_dp.mul) & (i1_rs1_depth_d[3:0] == 4'd4) & i1_rs1_class_d.load);

   assign load_mul_rs2_bypass_e1     =  (             (i0_dp.mul) & (i0_rs2_depth_d[3:0] == 4'd3) & i0_rs2_class_d.load) |
                                        (             (i0_dp.mul) & (i0_rs2_depth_d[3:0] == 4'd4) & i0_rs2_class_d.load) |
                                        (~i0_dp.mul & (i1_dp.mul) & (i1_rs2_depth_d[3:0] == 4'd3) & i1_rs2_class_d.load) |
                                        (~i0_dp.mul & (i1_dp.mul) & (i1_rs2_depth_d[3:0] == 4'd4) & i1_rs2_class_d.load);


   assign store_data_bypass_e4_c3[1] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd1) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd1) & i0_rs2_class_d.sec );

   assign store_data_bypass_e4_c3[0] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd2) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd2) & i0_rs2_class_d.sec );

   assign store_data_bypass_e4_c2[1] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd3) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd3) & i0_rs2_class_d.sec );

   assign store_data_bypass_e4_c2[0] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd4) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd4) & i0_rs2_class_d.sec );


   assign store_data_bypass_e4_c1[1] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd5) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd5) & i0_rs2_class_d.sec );

   assign store_data_bypass_e4_c1[0] = ( ~i0_dp.lsu & i1_dp.store & (i1_rs2_depth_d[3:0] == 4'd6) & i1_rs2_class_d.sec ) |
                                       (              i0_dp.store & (i0_rs2_depth_d[3:0] == 4'd6) & i0_rs2_class_d.sec );



   assign i0_not_alu_eff = ~i0_dp.alu;
   assign i1_not_alu_eff = ~i1_dp.alu;

if (pt.LOAD_TO_USE_PLUS1 == 1)
 begin
   assign i0_load_block_d = (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e1                            ) |
                            (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e2 & ~i0_dp.mul               ) |                             (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e1 & ~i0_dp.store             ) |
                            (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e2 & ~i0_dp.store & ~i0_dp.mul);

   assign i1_load_block_d = (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e1                            ) |
                            (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e2 & ~i1_dp.mul               ) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e1 & ~i1_dp.store             ) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e2 & ~i1_dp.store & ~i1_dp.mul);
 end
else
 begin
   assign i0_load_block_d = (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e1                                          ) |
                            (i0_not_alu_eff & i0_rs1_class_d.load & i0_rs1_match_e2 & ~i0_dp.load & ~i0_dp.store & ~i0_dp.mul) |                             (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e1 &               ~i0_dp.store             ) |
                            (i0_not_alu_eff & i0_rs2_class_d.load & i0_rs2_match_e2 &               ~i0_dp.store & ~i0_dp.mul);

   assign i1_load_block_d = (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e1                                          ) |
                            (i1_not_alu_eff & i1_rs1_class_d.load & i1_rs1_match_e2 & ~i1_dp.load & ~i1_dp.store & ~i1_dp.mul) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e1 &               ~i1_dp.store             ) |
                            (i1_not_alu_eff & i1_rs2_class_d.load & i1_rs2_match_e2 &               ~i1_dp.store & ~i1_dp.mul);
 end

   assign i0_mul_block_thread_1cycle_d        = (i0_not_alu_eff & i0_rs1_class_d.mul & i0_rs1_match_e1) |
                                                (i0_not_alu_eff & i0_rs2_class_d.mul & i0_rs2_match_e1);

   assign i0_mul_block_d        = (i0_not_alu_eff & i0_rs1_class_d.mul & i0_rs1_match_e1_e2) |
                                  (i0_not_alu_eff & i0_rs2_class_d.mul & i0_rs2_match_e1_e2);

   assign i1_mul_block_thread_1cycle_d        = (i1_not_alu_eff & i1_rs1_class_d.mul & i1_rs1_match_e1) |
                                                (i1_not_alu_eff & i1_rs2_class_d.mul & i1_rs2_match_e1);

   assign i1_mul_block_d       = (i1_not_alu_eff & i1_rs1_class_d.mul & i1_rs1_match_e1_e2) |
                                 (i1_not_alu_eff & i1_rs2_class_d.mul & i1_rs2_match_e1_e2);


   assign i0_secondary_block_d = (~i0_dp.alu & i0_rs1_class_d.sec & i0_rs1_match_e1_e3) |
                                 (~i0_dp.alu & i0_rs2_class_d.sec & i0_rs2_match_e1_e3 & ~i0_dp.store);

   assign i1_secondary_block_d = (~i1_dp.alu & i1_rs1_class_d.sec & i1_rs1_match_e1_e3) |
                                 (~i1_dp.alu & i1_rs2_class_d.sec & i1_rs2_match_e1_e3 & ~i1_dp.store);

   assign dec_tlu_i0_valid_e4 =  e4d.i0valid & ~flush_lower_wb[e4d.i0tid];
   assign dec_tlu_i1_valid_e4 =  e4d.i1valid & ~flush_lower_wb[e4d.i1tid];



   assign dt.i0legal               =  i0_legal_decode_d;
   assign dt.i0icaf                =  i0_icaf_d & i0_legal_decode_d;               assign dt.i0icaf_type[1:0]      =  dec_i0_icaf_type_d[1:0];
   assign dt.i0icaf_f1             =  dec_i0_icaf_f1_d & i0_legal_decode_d;        assign dt.i0fence_i             = (i0_dp.fence_i | debug_fence_i) & i0_legal_decode_d & ~i0_br_error_all;


   assign dt.i0tid = dd.i0tid;
   assign dt.i1tid = dd.i1tid;

   assign dt.pmu_i0_itype = i0_itype;
   assign dt.pmu_i1_itype = i1_itype;
   assign dt.pmu_i0_br_unpred = i0_br_unpred;
   assign dt.pmu_i1_br_unpred = i1_br_unpred;

   assign dt.lsu_pipe0 = i0_legal_decode_d & ~lsu_p.pipe & ~i0_br_error_all;

   assign dt.pmu_divide = i0_dp.div;

      assign dt.pmu_lsu_misaligned = 1'b0;

   assign dt.i0trigger[3:0] = dec_i0_trigger_match_d[3:0] & {4{dec_i0_decode_d}};
   assign dt.i1trigger[3:0] = dec_i1_trigger_match_d[3:0] & {4{i1_legal_decode_d}};

rvdffe #( $bits(eh2_trap_pkt_t) ) trap_e1ff (.*, .en(i0_e1_ctl_en | i1_e1_ctl_en), .din( dt),  .dout(e1t));

  always @* begin
      e1t_in = e1t;
      e1t_in.i0trigger[3:0] = e1t.i0trigger & ~{4{flush_final_e3[e1t.i0tid]}};
      e1t_in.i1trigger[3:0] = e1t.i1trigger & ~{4{flush_final_e3[e1t.i1tid] | dec_i1_cancel_e1[e1t.i1tid]}};
   end
   rvdffe #( $bits(eh2_trap_pkt_t) ) trap_e2ff (.*, .en(i0_e2_ctl_en | i1_e2_ctl_en), .din(e1t_in),  .dout(e2t));


   always @* begin
      e2t_in = e2t;
      e2t_in.i0trigger[3:0] = e2t.i0trigger & ~{4{flush_final_e3[e2t.i0tid] | flush_lower_wb[e2t.i0tid]}};
      e2t_in.i1trigger[3:0] = e2t.i1trigger & ~{4{flush_final_e3[e2t.i1tid] | flush_lower_wb[e2t.i1tid]}};
   end

   rvdffe  #($bits(eh2_trap_pkt_t) ) trap_e3ff (.*, .en(i0_e3_ctl_en | i1_e3_ctl_en), .din(e2t_in),  .dout(e3t));

   assign lsu_tid_e3 = e3t.lsu_pipe0 ? e3t.i0tid : e3t.i1tid;

    always @* begin
      e3t_in = e3t;

       e3t_in.pmu_lsu_misaligned = lsu_pmu_misaligned_dc3[lsu_tid_e3];   
       if (flush_lower_wb[e3t.i0tid]) begin
          e3t_in.i0legal = '0;
          e3t_in.i0icaf = '0;
          e3t_in.i0icaf_type = '0;
          e3t_in.i0icaf_f1 = '0;
          e3t_in.i0fence_i = '0;
          e3t_in.i0trigger = '0;
          e3t_in.pmu_i0_br_unpred = '0;
          e3t_in.pmu_i0_itype = eh2_inst_pkt_t'(0);
       end

       if (flush_lower_wb[e3t.i1tid]) begin
          e3t_in.i1trigger = '0;
          e3t_in.pmu_i1_br_unpred = '0;
          e3t_in.pmu_i1_itype = eh2_inst_pkt_t'(0);
       end


   end

   rvdffe #( $bits(eh2_trap_pkt_t) ) trap_e4ff (.*, .en(i0_e4_ctl_en | i1_e4_ctl_en), .din(e3t_in),  .dout(e4t_ff));


    always @* begin
       e4t = e4t_ff;

       e4t.i0trigger[3:0] = ({4{ (e4d.i0load | e4d.i0store)}} & lsu_trigger_match_dc4[3:0]) | e4t.i0trigger[3:0];

       e4t.i1trigger[3:0] = ~{4{(e4t.i0tid==e4t.i1tid) & i0_flush_final_e4[e4t.i0tid]}} & (({4{~(e4d.i0load | e4d.i0store)}} & lsu_trigger_match_dc4[3:0]) | e4t.i1trigger[3:0]);


       if (flush_lower_wb[e4t.i0tid]) begin
          e4t.i0legal = '0;
          e4t.i0icaf = '0;
          e4t.i0icaf_type = '0;
          e4t.i0icaf_f1 = '0;
          e4t.i0fence_i = '0;
          e4t.i0trigger = '0;
          e4t.pmu_i0_br_unpred = '0;
          e4t.pmu_i0_itype = eh2_inst_pkt_t'(0);
       end

       if (flush_lower_wb[e4t.i1tid]) begin
          e4t.i1trigger = '0;
          e4t.pmu_i1_br_unpred = '0;
          e4t.pmu_i1_itype = eh2_inst_pkt_t'(0);
       end


    end


   always @* begin

      dec_tlu_packet_e4 = e4t;

   end
   assign dec_i0_tid_e4 = e4t.i0tid;
   assign dec_i1_tid_e4 = e4t.i1tid;



   assign i0_dc.mul   = i0_dp.mul  & i0_legal_decode_d & ~i0_br_error_all;
   assign i0_dc.load  = i0_dp.load & i0_legal_decode_d & ~i0_br_error_all;
   assign i0_dc.sec   = i0_dp.alu  &  i0_secondary_d   & i0_legal_decode_d & ~i0_br_error_all;
   assign i0_dc.alu   = i0_dp.alu  & ~i0_secondary_d   & i0_legal_decode_d & ~i0_br_error_all;


rvdffs #( $bits(eh2_class_pkt_t) ) i0_e1c_ff (.*, .en(i0_e1_ctl_en), .clk(active_clk), .din(i0_dc),   .dout(i0_e1c));
   rvdffs #( $bits(eh2_class_pkt_t) ) i0_e2c_ff (.*, .en(i0_e2_ctl_en), .clk(active_clk), .din(i0_e1c),  .dout(i0_e2c));
   rvdffs #( $bits(eh2_class_pkt_t) ) i0_e3c_ff (.*, .en(i0_e3_ctl_en), .clk(active_clk), .din(i0_e2c),  .dout(i0_e3c));

   assign i0_e4c_in = i0_e3c;

   rvdffs  #( $bits(eh2_class_pkt_t) ) i0_e4c_ff (.*, .en(i0_e4_ctl_en),              .clk(active_clk), .din(i0_e4c_in), .dout(i0_e4c));

   rvdffs  #( $bits(eh2_class_pkt_t) ) i0_wbc_ff (.*, .en(i0_wb_ctl_en),              .clk(active_clk), .din(i0_e4c),    .dout(i0_wbc));


   assign i1_dc.mul   = i1_dp.mul  & i1_legal_decode_d & ~i1_br_error_all;
   assign i1_dc.load  = i1_dp.load & i1_legal_decode_d & ~i1_br_error_all;
   assign i1_dc.sec   = i1_dp.alu  &  i1_secondary_d   & i1_legal_decode_d & ~i1_br_error_all;
   assign i1_dc.alu   = i1_dp.alu  & ~i1_secondary_d   & i1_legal_decode_d & ~i1_br_error_all;

   rvdffs #( $bits(eh2_class_pkt_t) ) i1_e1c_ff (.*, .en(i1_e1_ctl_en), .clk(active_clk), .din(i1_dc),   .dout(i1_e1c));
   rvdffs #( $bits(eh2_class_pkt_t) ) i1_e2c_ff (.*, .en(i1_e2_ctl_en), .clk(active_clk), .din(i1_e1c),  .dout(i1_e2c));
   rvdffs #( $bits(eh2_class_pkt_t) ) i1_e3c_ff (.*, .en(i1_e3_ctl_en), .clk(active_clk), .din(i1_e2c),  .dout(i1_e3c));

   assign i1_e4c_in = i1_e3c;

   rvdffs #( $bits(eh2_class_pkt_t) ) i1_e4c_ff (.*, .en(i1_e4_ctl_en), .clk(active_clk), .din(i1_e4c_in), .dout(i1_e4c));

   rvdffs #( $bits(eh2_class_pkt_t) ) i1_wbc_ff (.*, .en(i1_wb_ctl_en), .clk(active_clk), .din(i1_e4c),    .dout(i1_wbc));



   assign dd.i0rd[4:0] = i0r.rd[4:0];
   assign dd.i0v = i0_rd_en_d & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0valid =  dec_i0_decode_d;     assign dd.i0tid   =  dec_i0_tid_d;

   assign dd.i0mul  = i0_dp.mul    & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0load  = i0_dp.load  & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0store = i0_dp.store & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0sc    = i0_dp.sc    & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0div = i0_div_decode_d;
   assign dd.i0secondary = i0_secondary_d & i0_legal_decode_d & ~i0_br_error_all;

   assign dd.lsu_tid = (i0_dp.lsu) ? dd.i0tid : dd.i1tid;


   assign dd.i1rd[4:0]   = i1r.rd[4:0];
   assign dd.i1v         = i1_rd_en_d & i1_legal_decode_d & ~i1_br_error_all;
   assign dd.i1valid     = i1_legal_decode_d;
   assign dd.i1tid       = dec_i1_tid_d;

   assign dd.i1mul       = i1_dp.mul;
   assign dd.i1load      = i1_dp.load;
   assign dd.i1store     = i1_dp.store;
   assign dd.i1sc        = i1_dp.sc;
   assign dd.i1secondary = i1_secondary_d & i1_legal_decode_d & ~i1_br_error_all;

   assign dd.i0csrwen = dec_i0_csr_wen_unq_d & i0_legal_decode_d & ~i0_br_error_all;

   assign dd.i0csrwonly = i0_csr_write_only_d & i0_legal_decode_d & ~i0_br_error_all;
   assign dd.i0csrwaddr[11:0] = i0[31:20];    
   assign i0_pipe_en[5] = dec_i0_decode_d;

rvdff  #(3) i0cg0ff (.*, .clk(active_clk), .din(i0_pipe_en[5:3]), .dout(i0_pipe_en[4:2]));
   rvdff  #(2) i0cg1ff (.*, .clk(active_clk), .din(i0_pipe_en[2:1]), .dout(i0_pipe_en[1:0]));


   assign i0_e1_ctl_en = (|i0_pipe_en[5:4] | clk_override);
   assign i0_e2_ctl_en = (|i0_pipe_en[4:3] | clk_override);
   assign i0_e3_ctl_en = (|i0_pipe_en[3:2] | clk_override);
   assign i0_e4_ctl_en = (|i0_pipe_en[2:1] | clk_override);
   assign i0_wb_ctl_en = (|i0_pipe_en[1:0] | clk_override);

   assign i0_e1_data_en = (i0_pipe_en[5] | clk_override);
   assign i0_e2_data_en = (i0_pipe_en[4] | clk_override);
   assign i0_e3_data_en = (i0_pipe_en[3] | clk_override);
   assign i0_e4_data_en = (i0_pipe_en[2] | clk_override);
   assign i0_wb_data_en = (i0_pipe_en[1] | clk_override);
   assign i0_wb1_data_en = (i0_pipe_en[0] | clk_override);

   assign dec_i0_data_en[4:2] = {i0_e1_data_en, i0_e2_data_en, i0_e3_data_en};
   assign dec_i0_ctl_en[4:1]  = {i0_e1_ctl_en, i0_e2_ctl_en, i0_e3_ctl_en, i0_e4_ctl_en};

   assign i1_pipe_en[5] = dec_i1_decode_d;

rvdff  #(3) i1cg0ff (.*, .clk(free_clk), .din(i1_pipe_en[5:3]), .dout(i1_pipe_en[4:2]));
   rvdff  #(2) i1cg1ff (.*, .clk(free_clk), .din(i1_pipe_en[2:1]), .dout(i1_pipe_en[1:0]));


   assign i1_e1_ctl_en = (|i1_pipe_en[5:4] | clk_override);
   assign i1_e2_ctl_en = (|i1_pipe_en[4:3] | clk_override);
   assign i1_e3_ctl_en = (|i1_pipe_en[3:2] | clk_override);
   assign i1_e4_ctl_en = (|i1_pipe_en[2:1] | clk_override);
   assign i1_wb_ctl_en = (|i1_pipe_en[1:0] | clk_override);

   assign i1_e1_data_en = (i1_pipe_en[5] | clk_override);
   assign i1_e2_data_en = (i1_pipe_en[4] | clk_override);
   assign i1_e3_data_en = (i1_pipe_en[3] | clk_override);
   assign i1_e4_data_en = (i1_pipe_en[2] | clk_override);
   assign i1_wb_data_en = (i1_pipe_en[1] | clk_override);
   assign i1_wb1_data_en = (i1_pipe_en[0] | clk_override);

   assign dec_i1_data_en[4:2] = {i1_e1_data_en, i1_e2_data_en, i1_e3_data_en};
   assign dec_i1_ctl_en[4:1]  = {i1_e1_ctl_en, i1_e2_ctl_en, i1_e3_ctl_en, i1_e4_ctl_en};

rvdffe #( $bits(eh2_dest_pkt_t) ) e1ff (.*, .en(i0_e1_ctl_en | i1_e1_ctl_en), .din(dd),  .dout(e1d));

   always @* begin
      e1d_in = e1d;

      e1d_in.i0div =        e1d.i0div       & ~div_flush;

      e1d_in.i0v =          e1d.i0v         & ~flush_final_e3[e1d.i0tid];
      e1d_in.i1v =          e1d.i1v         & ~flush_final_e3[e1d.i1tid] & ~dec_i1_cancel_e1[e1d.i1tid];
      e1d_in.i0valid =      e1d.i0valid     & ~flush_final_e3[e1d.i0tid];
      e1d_in.i1valid =      e1d.i1valid     & ~flush_final_e3[e1d.i1tid] & ~dec_i1_cancel_e1[e1d.i1tid];
      e1d_in.i0secondary =  e1d.i0secondary & ~flush_final_e3[e1d.i0tid];
      e1d_in.i1secondary =  e1d.i1secondary & ~flush_final_e3[e1d.i1tid] & ~dec_i1_cancel_e1[e1d.i1tid];
   end

   assign dec_i1_valid_e1 = e1d.i1valid & ~dec_i1_cancel_e1[e1d.i1tid];


rvdffe #( $bits(eh2_dest_pkt_t) ) e2ff (.*, .en(i0_e2_ctl_en | i1_e2_ctl_en), .din(e1d_in), .dout(e2d));

   always @* begin
      e2d_in = e2d;

      e2d_in.i0div =       e2d.i0div       & ~div_flush;

      e2d_in.i0v =         e2d.i0v         & ~flush_final_e3[e2d.i0tid] & ~flush_lower_wb[e2d.i0tid];
      e2d_in.i1v =         e2d.i1v         & ~flush_final_e3[e2d.i1tid] & ~flush_lower_wb[e2d.i1tid];
      e2d_in.i0valid =     e2d.i0valid     & ~flush_final_e3[e2d.i0tid] & ~flush_lower_wb[e2d.i0tid];
      e2d_in.i1valid =     e2d.i1valid     & ~flush_final_e3[e2d.i1tid] & ~flush_lower_wb[e2d.i1tid];
      e2d_in.i0secondary = e2d.i0secondary & ~flush_final_e3[e2d.i0tid] & ~flush_lower_wb[e2d.i0tid];
      e2d_in.i1secondary = e2d.i1secondary & ~flush_final_e3[e2d.i1tid] & ~flush_lower_wb[e2d.i1tid];

   end

rvdffe #( $bits(eh2_dest_pkt_t) ) e3ff (.*, .en(i0_e3_ctl_en | i1_e3_ctl_en), .din(e2d_in), .dout(e3d));


   always @* begin
      e3d_in = e3d;

      e3d_in.i0div =       e3d.i0div       & ~div_flush;

      e3d_in.i0v = e3d.i0v                              & ~flush_lower_wb[e3d.i0tid];
      e3d_in.i0valid = e3d.i0valid                      & ~flush_lower_wb[e3d.i0tid];

      e3d_in.i0secondary = e3d.i0secondary              & ~flush_lower_wb[e3d.i0tid];

      e3d_in.i1v = e3d.i1v         & ~((e3d.i0tid==e3d.i1tid) & i0_flush_final_e3[e3d.i1tid]) & ~flush_lower_wb[e3d.i1tid];
      e3d_in.i1valid = e3d.i1valid & ~((e3d.i0tid==e3d.i1tid) & i0_flush_final_e3[e3d.i1tid]) & ~flush_lower_wb[e3d.i1tid];

      e3d_in.i1secondary = e3d.i1secondary & ~((e3d.i0tid==e3d.i1tid) & i0_flush_final_e3[e3d.i1tid]) & ~flush_lower_wb[e3d.i1tid];
   end


   assign dec_i0_sec_decode_e3 = e3d.i0secondary & ~flush_lower_wb[e3d.i0tid];
   assign dec_i1_sec_decode_e3 = e3d.i1secondary & ~((e3d.i0tid==e3d.i1tid) & i0_flush_final_e3[e3d.i1tid]) & ~flush_lower_wb[e3d.i1tid];

rvdffe #( $bits(eh2_dest_pkt_t) ) e4ff (.*, .en(i0_e4_ctl_en | i1_e4_ctl_en), .din(e3d_in), .dout(e4d));

   always @* begin
      e4d_in = e4d;


      e4d_in.i0div =       e4d.i0div       & ~div_flush;

      e4d_in.i0v =     (e4d.i0v                  & ~flush_lower_wb[e4d.i0tid]);

      e4d_in.i0valid = (e4d.i0valid              & ~flush_lower_wb[e4d.i0tid]);

      e4d_in.i0secondary = e4d.i0secondary & ~flush_lower_wb[e4d.i0tid];

      e4d_in.i1v = e4d.i1v                 & ~flush_lower_wb[e4d.i1tid];
      e4d_in.i1valid = e4d.i1valid         & ~flush_lower_wb[e4d.i1tid];
      e4d_in.i1secondary = e3d.i1secondary & ~flush_lower_wb[e4d.i1tid];
   end

rvdffe #( $bits(eh2_dest_pkt_t) ) wbff (.*, .en(i0_wb_ctl_en | i1_wb_ctl_en), .din(e4d_in), .dout(wbd));

   assign dec_i0_waddr_wb[4:0] = wbd.i0rd[4:0];

         assign     i0_wen_wb = wbd.i0v & ~(~dec_tlu_i1_kill_writeb_wb & ~cam_i1_load_kill_wen[wbd.i1tid] & wbd.i0v & wbd.i1v & (wbd.i0rd[4:0] == wbd.i1rd[4:0]) & (wbd.i0tid == wbd.i1tid)) & ~dec_tlu_i0_kill_writeb_wb;

   assign dec_i0_wen_wb = i0_wen_wb & ~wbd.i0div & ~cam_i0_load_kill_wen[wbd.i0tid];  
   assign dec_i0_wdata_wb[31:0] = i0_result_wb[31:0];

   assign dec_i0_tid_wb = wbd.i0tid;

   assign dec_i1_waddr_wb[4:0] = wbd.i1rd[4:0];

   assign     i1_wen_wb = wbd.i1v & ~dec_tlu_i1_kill_writeb_wb;
   assign dec_i1_wen_wb = i1_wen_wb & ~cam_i1_load_kill_wen[wbd.i1tid];

   assign dec_i1_wdata_wb[31:0] = i1_result_wb[31:0];

   assign dec_i1_tid_wb = wbd.i1tid;



   assign div_flush = (e1d.i0div & e1d.i0valid & e1d.i0rd[4:0]==5'b0) |
                      (e1d.i0div & e1d.i0valid & (flush_lower_wb[e1d.i0tid] | flush_final_e3[e1d.i0tid])) |
                      (e2d.i0div & e2d.i0valid & (flush_lower_wb[e2d.i0tid] | flush_final_e3[e2d.i0tid])) |
                      (e3d.i0div & e3d.i0valid &  flush_lower_wb[e3d.i0tid]) |
                      (e4d.i0div & e4d.i0valid &  flush_lower_wb[e4d.i0tid]) |
                      (wbd.i0div & wbd.i0valid & dec_tlu_i0_kill_writeb_wb);

   assign div_e1_to_wb = (e1d.i0div & e1d.i0valid) |
                         (e2d.i0div & e2d.i0valid) |
                         (e3d.i0div & e3d.i0valid) |
                         (e4d.i0div & e4d.i0valid) |
                         (wbd.i0div & wbd.i0valid);

   assign div_active_in = i0_div_decode_d | (div_active & ~exu_div_wren & ~nonblock_div_cancel);
rvdff  #(1) divactiveff   (.*, .clk(free_clk), .din(div_active_in), .dout(div_active));


   assign dec_div_active = div_active;
   assign dec_div_tid = div_tid;

   assign div_stall = div_active;
   assign div_valid = div_active;




   assign i0_nonblock_div_stall  = (dec_i0_rs1_en_d & (dd.i0tid == div_tid) & div_valid & (div_rd[4:0] == i0r.rs1[4:0])) |
                                   (dec_i0_rs2_en_d & (dd.i0tid == div_tid) & div_valid & (div_rd[4:0] == i0r.rs2[4:0]));

   assign i1_nonblock_div_stall  = (dec_i1_rs1_en_d & (dd.i1tid == div_tid) & div_valid & (div_rd[4:0] == i1r.rs1[4:0])) |
                                   (dec_i1_rs2_en_d & (dd.i1tid == div_tid) & div_valid & (div_rd[4:0] == i1r.rs2[4:0]));

   assign nonblock_div_cancel = (div_valid & div_flush) |
                                (div_valid & ~div_e1_to_wb & (wbd.i0rd[4:0] == div_rd[4:0]) & (wbd.i0tid == div_tid) & i0_wen_wb) |
                                (div_valid & ~div_e1_to_wb & (wbd.i1rd[4:0] == div_rd[4:0]) & (wbd.i1tid == div_tid) & i1_wen_wb) |
                                (div_valid & wbd.i0div & wbd.i0valid & (wbd.i0rd[4:0] == wbd.i1rd[4:0]) & (wbd.i0tid == wbd.i1tid) & i1_wen_wb);


   assign dec_div_cancel = nonblock_div_cancel;

   assign i0_div_decode_d = i0_legal_decode_d & i0_dp.div & ~i0_br_error_all;


rvdffs #(5) divwbaddrff (.*, .en(i0_div_decode_d), .clk(active_clk), .din(i0r.rd[4:0]), .dout(div_rd[4:0]));
   rvdffs #(1) divtidff (.*, .en(i0_div_decode_d), .clk(active_clk), .din(dd.i0tid), .dout(div_tid));

   assign div_waddr_wb[4:0] = div_rd[4:0];
   assign div_tid_wb        = div_tid;

   assign i0_result_e1[31:0] = exu_i0_result_e1[31:0];
   assign i1_result_e1[31:0] = exu_i1_result_e1[31:0];

   // pipe the results down the pipe
   rvdffe #(32) i0e2resultff (.*, .en(i0_e2_data_en), .din(i0_result_e1[31:0]), .dout(i0_result_e2[31:0]));
   rvdffe #(32) i1e2resultff (.*, .en(i1_e2_data_en), .din(i1_result_e1[31:0]), .dout(i1_result_e2[31:0]));

   rvdffe #(32) i0e3resultff (.*, .en(i0_e3_data_en), .din(i0_result_e2[31:0]), .dout(i0_result_e3[31:0]));
   rvdffe #(32) i1e3resultff (.*, .en(i1_e3_data_en), .din(i1_result_e2[31:0]), .dout(i1_result_e3[31:0]));

   assign i0_result_e3_final[31:0] = (e3d.i0v & e3d.i0load) ? lsu_result_dc3[31:0] : (e3d.i0v & e3d.i0mul) ? exu_mul_result_e3[31:0] : i0_result_e3[31:0];

   assign i1_result_e3_final[31:0] = (e3d.i1v & e3d.i1load) ? lsu_result_dc3[31:0] : (e3d.i1v & e3d.i1mul) ? exu_mul_result_e3[31:0] : i1_result_e3[31:0];

   rvdffe #(32) i0e4resultff (.*, .en(i0_e4_data_en), .din(i0_result_e3_final[31:0]), .dout(i0_result_e4[31:0]));
   rvdffe #(32) i1e4resultff (.*, .en(i1_e4_data_en), .din(i1_result_e3_final[31:0]), .dout(i1_result_e4[31:0]));

   assign i0_result_e4_final[31:0] =
                                     (          e4d.i0secondary) ? exu_i0_result_e4[31:0] : (e4d.i0v & e4d.i0load) ? lsu_result_corr_dc4[31:0] : i0_result_e4[31:0];

   assign i1_result_e4_final[31:0] =
                                     (e4d.i1v & e4d.i1secondary) ? exu_i1_result_e4[31:0] : (e4d.i1v & e4d.i1load) ? lsu_result_corr_dc4[31:0] : i1_result_e4[31:0];

   rvdffe #(32) i0wbresultff (.*, .en(i0_wb_data_en), .din(i0_result_e4_final[31:0]), .dout(i0_result_wb_raw[31:0]));
   rvdffe #(32) i1wbresultff (.*, .en(i1_wb_data_en), .din(i1_result_e4_final[31:0]), .dout(i1_result_wb_raw[31:0]));

   assign i0_result_wb[31:0] = (wbd.i0sc) ? {31'b0, ~lsu_sc_success_dc5} : i0_result_wb_raw[31:0];

   assign i1_result_wb[31:0] = (wbd.i1sc) ? {31'b0, ~lsu_sc_success_dc5} : i1_result_wb_raw[31:0];

   rvdffe #(32) i0e1instff  (.*, .en(i0_e1_data_en),  .din(i0_inst_d[31:0] ), .dout(i0_inst_e1[31:0]));
   rvdffe #(32) i0e2instff  (.*, .en(i0_e2_data_en),  .din(i0_inst_e1[31:0]), .dout(i0_inst_e2[31:0]));
   rvdffe #(32) i0e3instff  (.*, .en(i0_e3_data_en),  .din(i0_inst_e2[31:0]), .dout(i0_inst_e3[31:0]));
   rvdffe #(32) i0e4instff  (.*, .en(i0_e4_data_en),  .din(i0_inst_e3[31:0]), .dout(i0_inst_e4[31:0]));
   rvdffe #(32) i0wbinstff  (.*, .en(i0_wb_data_en),  .din(i0_inst_e4[31:0]), .dout(i0_inst_wb[31:0] ));
   rvdffe #(32) i0wb1instff (.*, .en(i0_wb1_data_en), .din(i0_inst_wb[31:0]), .dout(i0_inst_wb1[31:0]));

   assign i1_inst_d[31:0] = (dec_i1_pc4_d) ? i1[31:0] : {16'b0, dec_i1_cinst_d[15:0] };

   rvdffe #(32) i1e1instff  (.*, .en(i1_e1_data_en), .din(i1_inst_d[31:0]),  .dout(i1_inst_e1[31:0]));
   rvdffe #(32) i1e2instff  (.*, .en(i1_e2_data_en), .din(i1_inst_e1[31:0]), .dout(i1_inst_e2[31:0]));
   rvdffe #(32) i1e3instff  (.*, .en(i1_e3_data_en), .din(i1_inst_e2[31:0]), .dout(i1_inst_e3[31:0]));
   rvdffe #(32) i1e4instff  (.*, .en(i1_e4_data_en), .din(i1_inst_e3[31:0]), .dout(i1_inst_e4[31:0]));
   rvdffe #(32) i1wbinstff  (.*, .en(i1_wb_data_en), .din(i1_inst_e4[31:0]), .dout(i1_inst_wb[31:0]));
   rvdffe #(32) i1wb1instff (.*, .en(i1_wb1_data_en),.din(i1_inst_wb[31:0]), .dout(i1_inst_wb1[31:0]));

   assign dec_i0_inst_wb1[31:0] = i0_inst_wb1[31:0];
   assign dec_i1_inst_wb1[31:0] = i1_inst_wb1[31:0];

   rvdffe #(31) i0wbpcff  (.*, .en(i0_wb_data_en ), .din(dec_tlu_i0_pc_e4[31:1]), .dout(i0_pc_wb[31:1]));
   rvdffe #(31) i0wb1pcff (.*, .en(i0_wb1_data_en), .din(i0_pc_wb[31:1]),         .dout(i0_pc_wb1[31:1]));

   rvdffe #(31) i1wb1pcff (.*, .en(i1_wb1_data_en),.din(i1_pc_wb[31:1]),         .dout(i1_pc_wb1[31:1]));

   assign dec_i0_pc_wb1[31:1] = i0_pc_wb1[31:1];
   assign dec_i1_pc_wb1[31:1] = i1_pc_wb1[31:1];

   // pipe the pc's down the pipe
   assign i0_pc_e1[31:1] = exu_i0_pc_e1[31:1];
   assign i1_pc_e1[31:1] = exu_i1_pc_e1[31:1];

   rvdffe #(31) i0e2pcff (.*, .en(i0_e2_data_en), .din(i0_pc_e1[31:1]), .dout(i0_pc_e2[31:1]));
   rvdffe #(31) i0e3pcff (.*, .en(i0_e3_data_en), .din(i0_pc_e2[31:1]), .dout(i0_pc_e3[31:1]));
   rvdffe #(31) i0e4pcff (.*, .en(i0_e4_data_en), .din(i0_pc_e3[31:1]), .dout(i0_pc_e4[31:1]));
   rvdffe #(31) i1e2pcff (.*, .en(i1_e2_data_en), .din(i1_pc_e1[31:1]), .dout(i1_pc_e2[31:1]));
   rvdffe #(31) i1e3pcff (.*, .en(i1_e3_data_en), .din(i1_pc_e2[31:1]), .dout(i1_pc_e3[31:1]));
   rvdffe #(31) i1e4pcff (.*, .en(i1_e4_data_en), .din(i1_pc_e3[31:1]), .dout(i1_pc_e4[31:1]));

   assign dec_i0_pc_e3[31:1] = i0_pc_e3[31:1];
   assign dec_i1_pc_e3[31:1] = i1_pc_e3[31:1];


   assign dec_tlu_i0_pc_e4[31:1] = i0_pc_e4[31:1];
   assign dec_tlu_i1_pc_e4[31:1] = i1_pc_e4[31:1];

   
   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign last_br_immed_d[i][12:1] = (i1_legal_decode_d & (dd.i1tid==i)) ?
                                        ((i1_ap.predict_nt & (dd.i1tid==i)) ? {10'b0,i1_ap_pc4,i1_ap_pc2} : i1_br_offset[11:0] ) :
                                        ((i0_ap.predict_nt & (dd.i0tid==i)) ? {10'b0,i0_ap_pc4,i0_ap_pc2} : i0_br_offset[11:0] );

   rvdffe #(12) e1brpcff (.*, .en(i0_e1_data_en | i1_e1_data_en), .din(last_br_immed_d[i][12:1] ), .dout(last_br_immed_e1[i][12:1]));
      rvdffe #(12) e2brpcff (.*, .en(i0_e2_data_en | i1_e2_data_en), .din(last_br_immed_e1[i][12:1]), .dout(last_br_immed_e2[i][12:1]));


      assign last_pc_e2[i][31:1] = (e2d.i1valid & (e2d.i1tid==i)) ? i1_pc_e2[31:1] : i0_pc_e2[31:1];

      rvbradder ibradder_correct (
                                  .pc(last_pc_e2[i][31:1]),
                                  .offset(last_br_immed_e2[i][12:1]),
                                  .dout(pred_correct_npc_e2[i][31:1])
                                  );


   end

rvdffe #(31) i1wbpcff (.*, .en(i1_wb_data_en), .din(dec_tlu_i1_pc_e4[31:1]), .dout(i1_pc_wb[31:1]));

   
   assign i0_rs1_nonblock_load_bypass_en_d  = dec_i0_rs1_en_d & dec_nonblock_load_wen[dd.i0tid] & (dec_nonblock_load_waddr[dd.i0tid][4:0] == i0r.rs1[4:0]);
   assign i0_rs2_nonblock_load_bypass_en_d  = dec_i0_rs2_en_d & dec_nonblock_load_wen[dd.i0tid] & (dec_nonblock_load_waddr[dd.i0tid][4:0] == i0r.rs2[4:0]);
   assign i1_rs1_nonblock_load_bypass_en_d  = dec_i1_rs1_en_d & dec_nonblock_load_wen[dd.i1tid] & (dec_nonblock_load_waddr[dd.i1tid][4:0] == i1r.rs1[4:0]);
   assign i1_rs2_nonblock_load_bypass_en_d  = dec_i1_rs2_en_d & dec_nonblock_load_wen[dd.i1tid] & (dec_nonblock_load_waddr[dd.i1tid][4:0] == i1r.rs2[4:0]);

   
   assign i0_rs1bypass[9:0] = {   i0_rs1_depth_d[3:0] == 4'd1  &  i0_rs1_class_d.alu,
                                  i0_rs1_depth_d[3:0] == 4'd2  &  i0_rs1_class_d.alu,
                                  i0_rs1_depth_d[3:0] == 4'd3  &  i0_rs1_class_d.alu,
                                  i0_rs1_depth_d[3:0] == 4'd4  &  i0_rs1_class_d.alu,
                                  i0_rs1_depth_d[3:0] == 4'd5  & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                  i0_rs1_depth_d[3:0] == 4'd6  & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul),
                                  i0_rs1_depth_d[3:0] == 4'd7  & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd8  & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd9  & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec),
                                  i0_rs1_depth_d[3:0] == 4'd10 & (i0_rs1_class_d.alu | i0_rs1_class_d.load | i0_rs1_class_d.mul | i0_rs1_class_d.sec) };


   assign i0_rs2bypass[9:0] = {   i0_rs2_depth_d[3:0] == 4'd1  &  i0_rs2_class_d.alu,
                                  i0_rs2_depth_d[3:0] == 4'd2  &  i0_rs2_class_d.alu,
                                  i0_rs2_depth_d[3:0] == 4'd3  &  i0_rs2_class_d.alu,
                                  i0_rs2_depth_d[3:0] == 4'd4  &  i0_rs2_class_d.alu,
                                  i0_rs2_depth_d[3:0] == 4'd5  & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                  i0_rs2_depth_d[3:0] == 4'd6  & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul),
                                  i0_rs2_depth_d[3:0] == 4'd7  & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd8  & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd9  & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec),
                                  i0_rs2_depth_d[3:0] == 4'd10 & (i0_rs2_class_d.alu | i0_rs2_class_d.load | i0_rs2_class_d.mul | i0_rs2_class_d.sec) };


   assign i1_rs1bypass[9:0] = {   i1_rs1_depth_d[3:0] == 4'd1  &  i1_rs1_class_d.alu,
                                  i1_rs1_depth_d[3:0] == 4'd2  &  i1_rs1_class_d.alu,
                                  i1_rs1_depth_d[3:0] == 4'd3  &  i1_rs1_class_d.alu,
                                  i1_rs1_depth_d[3:0] == 4'd4  &  i1_rs1_class_d.alu,
                                  i1_rs1_depth_d[3:0] == 4'd5  & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul),
                                  i1_rs1_depth_d[3:0] == 4'd6  & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul),
                                  i1_rs1_depth_d[3:0] == 4'd7  & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd8  & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd9  & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec),
                                  i1_rs1_depth_d[3:0] == 4'd10 & (i1_rs1_class_d.alu | i1_rs1_class_d.load | i1_rs1_class_d.mul | i1_rs1_class_d.sec) };


   assign i1_rs2bypass[9:0] = {   i1_rs2_depth_d[3:0] == 4'd1  &  i1_rs2_class_d.alu,
                                  i1_rs2_depth_d[3:0] == 4'd2  &  i1_rs2_class_d.alu,
                                  i1_rs2_depth_d[3:0] == 4'd3  &  i1_rs2_class_d.alu,
                                  i1_rs2_depth_d[3:0] == 4'd4  &  i1_rs2_class_d.alu,
                                  i1_rs2_depth_d[3:0] == 4'd5  & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul),
                                  i1_rs2_depth_d[3:0] == 4'd6  & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul),
                                  i1_rs2_depth_d[3:0] == 4'd7  & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd8  & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd9  & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec),
                                  i1_rs2_depth_d[3:0] == 4'd10 & (i1_rs2_class_d.alu | i1_rs2_class_d.load | i1_rs2_class_d.mul | i1_rs2_class_d.sec) };

   assign dec_i0_rs1_bypass_en_d = (|i0_rs1bypass[9:0]) | i0_rs1_nonblock_load_bypass_en_d;
   assign dec_i0_rs2_bypass_en_d = (|i0_rs2bypass[9:0]) | i0_rs2_nonblock_load_bypass_en_d;
   assign dec_i1_rs1_bypass_en_d = (|i1_rs1bypass[9:0]) | i1_rs1_nonblock_load_bypass_en_d;
   assign dec_i1_rs2_bypass_en_d = (|i1_rs2bypass[9:0]) | i1_rs2_nonblock_load_bypass_en_d;

   assign i0_rs1_bypass_data_d[31:0] = ({32{i0_rs1bypass[9]}} & i1_result_e1[31:0]) |
                                       ({32{i0_rs1bypass[8]}} & i0_result_e1[31:0]) |
                                       ({32{i0_rs1bypass[7]}} & i1_result_e2[31:0]) |
                                       ({32{i0_rs1bypass[6]}} & i0_result_e2[31:0]) |
                                       ({32{i0_rs1bypass[5]}} & i1_result_e3_final[31:0]) |
                                       ({32{i0_rs1bypass[4]}} & i0_result_e3_final[31:0]) |
                                       ({32{i0_rs1bypass[3]}} & i1_result_e4_final[31:0]) |
                                       ({32{i0_rs1bypass[2]}} & i0_result_e4_final[31:0]) |
                                       ({32{i0_rs1bypass[1]}} & i1_result_wb[31:0]) |
                                       ({32{i0_rs1bypass[0]}} & i0_result_wb[31:0]) |
                                       ({32{~(|i0_rs1bypass[9:0])}} & lsu_nonblock_load_data[31:0]);


   assign i0_rs2_bypass_data_d[31:0] = ({32{i0_rs2bypass[9]}} & i1_result_e1[31:0]) |
                                       ({32{i0_rs2bypass[8]}} & i0_result_e1[31:0]) |
                                       ({32{i0_rs2bypass[7]}} & i1_result_e2[31:0]) |
                                       ({32{i0_rs2bypass[6]}} & i0_result_e2[31:0]) |
                                       ({32{i0_rs2bypass[5]}} & i1_result_e3_final[31:0]) |
                                       ({32{i0_rs2bypass[4]}} & i0_result_e3_final[31:0]) |
                                       ({32{i0_rs2bypass[3]}} & i1_result_e4_final[31:0]) |
                                       ({32{i0_rs2bypass[2]}} & i0_result_e4_final[31:0]) |
                                       ({32{i0_rs2bypass[1]}} & i1_result_wb[31:0]) |
                                       ({32{i0_rs2bypass[0]}} & i0_result_wb[31:0]) |
                                       ({32{~(|i0_rs2bypass[9:0])}} & lsu_nonblock_load_data[31:0]);

   assign i1_rs1_bypass_data_d[31:0] = ({32{i1_rs1bypass[9]}} & i1_result_e1[31:0]) |
                                       ({32{i1_rs1bypass[8]}} & i0_result_e1[31:0]) |
                                       ({32{i1_rs1bypass[7]}} & i1_result_e2[31:0]) |
                                       ({32{i1_rs1bypass[6]}} & i0_result_e2[31:0]) |
                                       ({32{i1_rs1bypass[5]}} & i1_result_e3_final[31:0]) |
                                       ({32{i1_rs1bypass[4]}} & i0_result_e3_final[31:0]) |
                                       ({32{i1_rs1bypass[3]}} & i1_result_e4_final[31:0]) |
                                       ({32{i1_rs1bypass[2]}} & i0_result_e4_final[31:0]) |
                                       ({32{i1_rs1bypass[1]}} & i1_result_wb[31:0]) |
                                       ({32{i1_rs1bypass[0]}} & i0_result_wb[31:0]) |
                                       ({32{~(|i1_rs1bypass[9:0])}} & lsu_nonblock_load_data[31:0]);


   assign i1_rs2_bypass_data_d[31:0] = ({32{i1_rs2bypass[9]}} & i1_result_e1[31:0]) |
                                       ({32{i1_rs2bypass[8]}} & i0_result_e1[31:0]) |
                                       ({32{i1_rs2bypass[7]}} & i1_result_e2[31:0]) |
                                       ({32{i1_rs2bypass[6]}} & i0_result_e2[31:0]) |
                                       ({32{i1_rs2bypass[5]}} & i1_result_e3_final[31:0]) |
                                       ({32{i1_rs2bypass[4]}} & i0_result_e3_final[31:0]) |
                                       ({32{i1_rs2bypass[3]}} & i1_result_e4_final[31:0]) |
                                       ({32{i1_rs2bypass[2]}} & i0_result_e4_final[31:0]) |
                                       ({32{i1_rs2bypass[1]}} & i1_result_wb[31:0]) |
                                       ({32{i1_rs2bypass[0]}} & i0_result_wb[31:0]) |
                                       ({32{~(|i1_rs2bypass[9:0])}} & lsu_nonblock_load_data[31:0]);


endmodule : eh2_dec_decode_ctl

module eh2_dec_cam
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)  (
   input wire clk,
   input wire scan_mode,
   input wire rst_l,

   input wire free_clk,
   input wire active_clk,

   input wire flush,
   input wire tid,

   input wire dec_tlu_i0_kill_writeb_wb,
   input wire dec_tlu_i1_kill_writeb_wb,

   input wire dec_tlu_force_halt,

   input wire lsu_nonblock_load_data_tid,

   input eh2_dest_pkt_t dd,
   input eh2_dest_pkt_t wbd,
   input eh2_reg_pkt_t i0r,
   input eh2_reg_pkt_t i1r,

   input wire lsu_nonblock_load_valid_dc1,        input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_tag_dc1,       
   input wire lsu_nonblock_load_inv_dc2,          input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc2,   
   input wire lsu_nonblock_load_inv_dc5,          input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc5,   
   input wire lsu_nonblock_load_data_valid,       input wire lsu_nonblock_load_data_error,       input wire [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_data_tag,      

   input wire [4:0] nonblock_load_rd,
   input wire nonblock_load_tid_dc1,
   input wire nonblock_load_tid_dc2,
   input wire nonblock_load_tid_dc5,

   input wire dec_i0_rs1_en_d,
   input wire dec_i0_rs2_en_d,
   input wire dec_i1_rs1_en_d,
   input wire dec_i1_rs2_en_d,

   input wire i1_wen_wb,
   input wire i0_wen_wb,

   output logic [4:0] nonblock_load_waddr,
   output logic       nonblock_load_wen,

   output logic       i0_nonblock_load_stall,
   output logic       i1_nonblock_load_stall,
   output logic       i0_load_kill_wen,
   output logic       i1_load_kill_wen,
   output logic      nonblock_load_stall
   );

   localparam NBLOAD_SIZE     = pt.LSU_NUM_NBLOAD;
   localparam NBLOAD_SIZE_MSB = int'(pt.LSU_NUM_NBLOAD)-1;
   localparam NBLOAD_TAG_MSB  = pt.LSU_NUM_NBLOAD_WIDTH-1;

wire cam_write;
wire cam_inv_dc2_reset;
wire cam_inv_dc5_reset;
wire cam_data_reset;
wire [NBLOAD_TAG_MSB:0] cam_write_tag;
wire [NBLOAD_TAG_MSB:0] cam_inv_dc2_reset_tag;
wire [NBLOAD_TAG_MSB:0] cam_inv_dc5_reset_tag;
wire [NBLOAD_TAG_MSB:0] cam_data_reset_tag;
   reg [NBLOAD_SIZE_MSB:0] cam_wen;

   wire [NBLOAD_TAG_MSB:0]  load_data_tag;
   wire [NBLOAD_SIZE_MSB:0] nonblock_load_write;
wire i1_nonblock_boundary_stall;
wire i0_nonblock_boundary_stall;

reg nonblock_load_valid_dc2_raw;
wire nonblock_load_valid_dc2;
reg nonblock_load_valid_dc3;
reg nonblock_load_valid_dc4;

   reg found;
   wire cam_reset_same_dest_wb;
   reg nonblock_load_valid_wb;
   reg i0_nonblock_load_match;
wire [NBLOAD_SIZE_MSB:0] cam_inv_dc2_reset_val;
wire [NBLOAD_SIZE_MSB:0] cam_inv_dc5_reset_val;
wire [NBLOAD_SIZE_MSB:0] cam_data_reset_val;
   wire                     nonblock_load_cancel;

   eh2_load_cam_pkt_t [NBLOAD_SIZE_MSB:0] cam;
   eh2_load_cam_pkt_t [NBLOAD_SIZE_MSB:0] cam_in;
   eh2_load_cam_pkt_t [NBLOAD_SIZE_MSB:0] cam_raw;


   always @* begin
      found = 0;
      cam_wen[NBLOAD_SIZE_MSB:0] = '0;
      for (int i=0; i<NBLOAD_SIZE; i++) begin
         if (~found) begin
            if (~cam[i].valid) begin
               cam_wen[i] = cam_write;                 found = 1'b1;
            end
         end
      end
   end


      assign cam_reset_same_dest_wb = wbd.i0v & wbd.i1v & (wbd.i0rd[4:0] == wbd.i1rd[4:0]) & (wbd.i0tid == tid) & (wbd.i1tid == tid) &
                                   wbd.i0load & nonblock_load_valid_wb & ~dec_tlu_i0_kill_writeb_wb & ~dec_tlu_i1_kill_writeb_wb;

      assign cam_write          = lsu_nonblock_load_valid_dc1 & (nonblock_load_tid_dc1 == tid);

   assign cam_write_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_tag_dc1[NBLOAD_TAG_MSB:0];

      assign cam_inv_dc2_reset                       = lsu_nonblock_load_inv_dc2 & (nonblock_load_tid_dc2 == tid);

   assign cam_inv_dc2_reset_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_inv_tag_dc2[NBLOAD_TAG_MSB:0];

      assign cam_inv_dc5_reset                       = (lsu_nonblock_load_inv_dc5 & (nonblock_load_tid_dc5 == tid)) |
                                                     cam_reset_same_dest_wb;

   assign cam_inv_dc5_reset_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_inv_tag_dc5[NBLOAD_TAG_MSB:0];

      assign cam_data_reset          = (lsu_nonblock_load_data_valid | lsu_nonblock_load_data_error) & (lsu_nonblock_load_data_tid == tid);

   assign cam_data_reset_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_data_tag[NBLOAD_TAG_MSB:0];

   
`ifdef ASSERT_ON
`endif

   
    
   for (genvar i=0; i<NBLOAD_SIZE; i++) begin : cam_array

      assign cam_inv_dc2_reset_val[i] = cam_inv_dc2_reset   & (cam_inv_dc2_reset_tag[NBLOAD_TAG_MSB:0]  == cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid;

      assign cam_inv_dc5_reset_val[i] = cam_inv_dc5_reset   & (cam_inv_dc5_reset_tag[NBLOAD_TAG_MSB:0]  == cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid;

      assign cam_data_reset_val[i] = cam_data_reset & (cam_data_reset_tag[NBLOAD_TAG_MSB:0] == cam_raw[i].tag[NBLOAD_TAG_MSB:0]) & cam_raw[i].valid;

      always @* begin

         cam[i] = cam_raw[i];

         if (pt.LOAD_TO_USE_BUS_PLUS1==0 & cam_data_reset_val[i])
           cam[i].valid = 1'b0;

         cam_in[i] = cam[i];

         if (cam_wen[i]) begin
            cam_in[i].valid    = 1'b1;
            cam_in[i].stall    = 1'b0;
            cam_in[i].wb       = 1'b0;
            cam_in[i].tag[NBLOAD_TAG_MSB:0] = cam_write_tag[NBLOAD_TAG_MSB:0];
            cam_in[i].rd[4:0]  = nonblock_load_rd[4:0];
         end
         else if ( (cam_inv_dc2_reset_val[i]) |
                   (cam_inv_dc5_reset_val[i]) |
                   (pt.LOAD_TO_USE_BUS_PLUS1==1 & cam_data_reset_val[i]) |
                   (i0_wen_wb & (wbd.i0rd[4:0] == cam[i].rd[4:0]) & (wbd.i0tid == tid) & cam[i].wb) |
                   (i1_wen_wb & (wbd.i1rd[4:0] == cam[i].rd[4:0]) & (wbd.i1tid == tid) & cam[i].wb) )
           cam_in[i].valid = 1'b0;

                  if (nonblock_load_valid_wb & (lsu_nonblock_load_inv_tag_dc5[NBLOAD_TAG_MSB:0]==cam[i].tag[NBLOAD_TAG_MSB:0]) & cam[i].valid)
           cam_in[i].wb = 1'b1;

                  if (dec_tlu_force_halt)
           cam_in[i].valid = 1'b0;

                  if (flush)
           cam_in[i].stall = 1'b0;
         else if ((dec_i0_rs1_en_d & (dd.i0tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i0r.rs1[4:0])) |
                  (dec_i0_rs2_en_d & (dd.i0tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i0r.rs2[4:0])))
           cam_in[i].stall = 1'b1;

      end 
rvdff #( $bits(eh2_load_cam_pkt_t) ) cam_ff (.*, .clk(free_clk), .din(cam_in[i]), .dout(cam_raw[i]));

            assign nonblock_load_write[i] = (load_data_tag[NBLOAD_TAG_MSB:0] == cam_raw[i].tag[NBLOAD_TAG_MSB:0]) & cam_raw[i].valid;

   end : cam_array

   assign load_data_tag[NBLOAD_TAG_MSB:0] = lsu_nonblock_load_data_tag[NBLOAD_TAG_MSB:0];


   assign nonblock_load_cancel = ((wbd.i0rd[4:0] == nonblock_load_waddr[4:0]) & (wbd.i0tid == tid) & (wbd.i0tid == lsu_nonblock_load_data_tid) & i0_wen_wb) |                                     ((wbd.i1rd[4:0] == nonblock_load_waddr[4:0]) & (wbd.i1tid == tid) & (wbd.i1tid == lsu_nonblock_load_data_tid) & i1_wen_wb);

      assign nonblock_load_wen = lsu_nonblock_load_data_valid & (lsu_nonblock_load_data_tid == tid) & |nonblock_load_write[NBLOAD_SIZE_MSB:0] & ~nonblock_load_cancel;

   always @* begin
      nonblock_load_waddr[4:0] = '0;

      nonblock_load_stall = '0;

      i0_nonblock_load_stall = i0_nonblock_boundary_stall;
      i1_nonblock_load_stall = i1_nonblock_boundary_stall;

      for (int i=0; i<NBLOAD_SIZE; i++) begin
         nonblock_load_waddr[4:0] |= ({5{nonblock_load_write[i] & (lsu_nonblock_load_data_tid == tid)}} & cam[i].rd[4:0]);

                  i0_nonblock_load_stall |= dec_i0_rs1_en_d & (dd.i0tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i0r.rs1[4:0]);
         i0_nonblock_load_stall |= dec_i0_rs2_en_d & (dd.i0tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i0r.rs2[4:0]);

         i1_nonblock_load_stall |= dec_i1_rs1_en_d & (dd.i1tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i1r.rs1[4:0]);
         i1_nonblock_load_stall |= dec_i1_rs2_en_d & (dd.i1tid == tid) & cam[i].valid & (cam[i].rd[4:0] == i1r.rs2[4:0]);

         nonblock_load_stall |= (cam_in[i].valid & cam[i].stall);
      end
   end

      assign i0_nonblock_boundary_stall = ((nonblock_load_rd[4:0]==i0r.rs1[4:0]) & (dd.i0tid == tid) & cam_write & dec_i0_rs1_en_d) |
                                       ((nonblock_load_rd[4:0]==i0r.rs2[4:0]) & (dd.i0tid == tid) & cam_write & dec_i0_rs2_en_d);

   assign i1_nonblock_boundary_stall = ((nonblock_load_rd[4:0]==i1r.rs1[4:0]) & (dd.i1tid == tid) & cam_write & dec_i1_rs1_en_d) |
                                       ((nonblock_load_rd[4:0]==i1r.rs2[4:0]) & (dd.i1tid == tid) & cam_write & dec_i1_rs2_en_d);


   
      rvdff #(1) e2nbloadff (.*, .clk(active_clk), .din(cam_write),  .dout(nonblock_load_valid_dc2_raw) );

   // cam_inv_dc2_reset is threaded
   assign nonblock_load_valid_dc2 = nonblock_load_valid_dc2_raw & ~cam_inv_dc2_reset;

   rvdff #(1) e3nbloadff (.*, .clk(active_clk), .din(    nonblock_load_valid_dc2),  .dout(nonblock_load_valid_dc3) );
   rvdff #(1) e4nbloadff (.*, .clk(active_clk), .din(    nonblock_load_valid_dc3),  .dout(nonblock_load_valid_dc4) );
   rvdff #(1) wbnbloadff (.*, .clk(active_clk), .din(    nonblock_load_valid_dc4),  .dout(nonblock_load_valid_wb) );


      assign i0_load_kill_wen = nonblock_load_valid_wb &  wbd.i0load;
   assign i1_load_kill_wen = nonblock_load_valid_wb &  wbd.i1load;

endmodule

module eh2_dec_dec_ctl
import eh2_pkg::*;
  (
   input wire [31:0] inst,
   input eh2_predecode_pkt_t predecode,

   output eh2_dec_pkt_t out
   );

   wire [31:0] i;


assign i[31:0] = inst[31:0];


assign out.alu = (!i[5]&i[2]) | (!i[3]&i[2]) | (i[6]) | (!i[25]&i[4]) | (!i[5]&i[4]);

assign out.rs1 = (!i[6]&i[5]&i[3]) | (!i[14]&!i[13]&!i[2]) | (!i[13]&i[11]&!i[2]) | (
    i[19]&i[13]&!i[2]) | (!i[13]&i[10]&!i[2]) | (i[18]&i[13]&!i[2]) | (
    !i[13]&i[9]&!i[2]) | (i[17]&i[13]&!i[2]) | (!i[13]&i[8]&!i[2]) | (
    i[16]&i[13]&!i[2]) | (!i[13]&i[7]&!i[2]) | (i[15]&i[13]&!i[2]) | (
    !i[4]&!i[3]) | (!i[6]&!i[2]);

assign out.rs2 = (i[27]&!i[6]&i[5]&i[3]) | (!i[28]&!i[6]&i[5]&i[3]) | (i[5]&!i[4]
    &!i[2]) | (!i[6]&i[5]&!i[2]);

assign out.imm12 = (!i[4]&!i[3]&i[2]) | (i[13]&!i[5]&i[4]&!i[2]) | (!i[13]&!i[12]
    &i[6]&i[4]) | (!i[12]&!i[5]&i[4]&!i[2]);

assign out.rd = (!i[5]&!i[2]) | (i[5]&i[2]) | (i[4]);

assign out.shimm5 = (!i[13]&i[12]&!i[5]&i[4]&!i[2]);

assign out.imm20 = (i[6]&i[3]) | (i[4]&i[2]);

assign out.pc = (!i[5]&!i[3]&i[2]) | (i[6]&i[3]);

assign out.load = (!i[28]&!i[6]&i[5]&i[3]) | (!i[27]&!i[6]&i[5]&i[3]) | (!i[5]&!i[4]
    &!i[2]);

assign out.store = (i[27]&!i[6]&i[5]&i[3]) | (!i[28]&!i[6]&i[5]&i[3]) | (!i[6]&i[5]
    &!i[4]&!i[2]);

assign out.lsu = (!i[6]&!i[4]&!i[2]) | (!i[6]&i[5]&!i[4]);

assign out.add = (!i[14]&!i[13]&!i[12]&!i[5]&i[4]) | (!i[5]&!i[3]&i[2]) | (!i[30]
    &!i[25]&!i[14]&!i[13]&!i[12]&!i[6]&i[4]&!i[2]);

assign out.sub = (i[30]&!i[12]&!i[6]&i[5]&i[4]&!i[2]) | (!i[25]&!i[14]&i[13]&!i[6]
    &i[4]&!i[2]) | (!i[14]&i[13]&!i[5]&i[4]&!i[2]) | (i[6]&!i[4]&!i[2]);

assign out.land = (i[14]&i[13]&i[12]&!i[5]&!i[2]) | (!i[25]&i[14]&i[13]&i[12]&!i[6]
    &!i[2]);

assign out.lor = (!i[5]&i[3]) | (!i[25]&i[14]&i[13]&!i[12]&i[4]&!i[2]) | (i[5]&i[4]
    &i[2]) | (!i[12]&i[6]&i[4]) | (i[13]&i[6]&i[4]) | (i[14]&i[13]&!i[12]
    &!i[5]&!i[2]) | (i[7]&i[6]&i[4]) | (i[8]&i[6]&i[4]) | (i[9]&i[6]&i[4]) | (
    i[10]&i[6]&i[4]) | (i[11]&i[6]&i[4]);

assign out.lxor = (!i[25]&i[14]&!i[13]&!i[12]&i[4]&!i[2]) | (i[14]&!i[13]&!i[12]
    &!i[5]&i[4]&!i[2]);

assign out.sll = (!i[25]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

assign out.sra = (i[30]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

assign out.srl = (!i[30]&!i[25]&i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

assign out.slt = (!i[25]&!i[14]&i[13]&!i[6]&i[4]&!i[2]) | (!i[14]&i[13]&!i[5]&i[4]
    &!i[2]);

assign out.unsign = (i[31]&i[30]&!i[6]&i[3]) | (!i[14]&i[13]&i[12]&!i[5]&!i[2]) | (
    i[14]&!i[5]&!i[4]) | (i[13]&i[6]&!i[4]&!i[2]) | (i[25]&i[14]&i[12]
    &!i[6]&i[5]&!i[2]) | (!i[25]&!i[14]&i[13]&i[12]&!i[6]&!i[2]);

assign out.condbr = (i[6]&!i[4]&!i[2]);

assign out.beq = (!i[14]&!i[12]&i[6]&!i[4]&!i[2]);

assign out.bne = (!i[14]&i[12]&i[6]&!i[4]&!i[2]);

assign out.bge = (i[14]&i[12]&i[5]&!i[4]&!i[2]);

assign out.blt = (i[14]&!i[12]&i[5]&!i[4]&!i[2]);

assign out.jal = (i[6]&i[2]);

assign out.by = (!i[13]&!i[12]&!i[6]&!i[4]&!i[2]);

assign out.half = (i[12]&!i[6]&!i[4]&!i[2]);

assign out.word = (i[13]&!i[6]&!i[4]);

assign out.csr_read = (i[13]&i[6]&i[4]) | (i[7]&i[6]&i[4]) | (i[8]&i[6]&i[4]) | (
    i[9]&i[6]&i[4]) | (i[10]&i[6]&i[4]) | (i[11]&i[6]&i[4]);

assign out.csr_clr = (i[15]&i[13]&i[12]&i[6]&i[4]) | (i[16]&i[13]&i[12]&i[6]&i[4]) | (
    i[17]&i[13]&i[12]&i[6]&i[4]) | (i[18]&i[13]&i[12]&i[6]&i[4]) | (
    i[19]&i[13]&i[12]&i[6]&i[4]);

assign out.csr_set = (i[15]&!i[12]&i[6]&i[4]) | (i[16]&!i[12]&i[6]&i[4]) | (i[17]
    &!i[12]&i[6]&i[4]) | (i[18]&!i[12]&i[6]&i[4]) | (i[19]&!i[12]&i[6]
    &i[4]);

assign out.csr_write = (!i[13]&i[12]&i[6]&i[4]);

assign out.csr_imm = (i[14]&!i[13]&i[6]&i[4]) | (i[15]&i[14]&i[6]&i[4]) | (i[16]
    &i[14]&i[6]&i[4]) | (i[17]&i[14]&i[6]&i[4]) | (i[18]&i[14]&i[6]&i[4]) | (
    i[19]&i[14]&i[6]&i[4]);

assign out.presync = (!i[6]&i[3]) | (!i[13]&i[7]&i[6]&i[4]) | (!i[13]&i[8]&i[6]&i[4]) | (
    !i[13]&i[9]&i[6]&i[4]) | (!i[13]&i[10]&i[6]&i[4]) | (!i[13]&i[11]
    &i[6]&i[4]) | (i[15]&i[13]&i[6]&i[4]) | (i[16]&i[13]&i[6]&i[4]) | (
    i[17]&i[13]&i[6]&i[4]) | (i[18]&i[13]&i[6]&i[4]) | (i[19]&i[13]&i[6]
    &i[4]);

assign out.postsync = (i[12]&!i[5]&i[3]) | (!i[22]&!i[13]&!i[12]&i[6]&i[4]) | (
    i[28]&i[27]&!i[6]&i[3]) | (!i[13]&i[7]&i[6]&i[4]) | (!i[13]&i[8]&i[6]
    &i[4]) | (!i[13]&i[9]&i[6]&i[4]) | (!i[13]&i[10]&i[6]&i[4]) | (!i[13]
    &i[11]&i[6]&i[4]) | (i[15]&i[13]&i[6]&i[4]) | (i[16]&i[13]&i[6]&i[4]) | (
    i[17]&i[13]&i[6]&i[4]) | (i[18]&i[13]&i[6]&i[4]) | (i[19]&i[13]&i[6]
    &i[4]);

assign out.ebreak = (!i[22]&i[20]&!i[13]&!i[12]&i[6]&i[4]);

assign out.ecall = (!i[21]&!i[20]&!i[13]&!i[12]&i[6]&i[4]);

assign out.mret = (i[29]&!i[13]&!i[12]&i[6]&i[4]);

assign out.mul = (i[25]&!i[14]&!i[6]&i[5]&i[4]&!i[2]);

assign out.rs1_sign = (i[25]&!i[14]&i[13]&!i[12]&!i[6]&i[5]&i[4]&!i[2]) | (i[25]
    &!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

assign out.rs2_sign = (i[25]&!i[14]&!i[13]&i[12]&!i[6]&i[4]&!i[2]);

assign out.low = (i[25]&!i[14]&!i[13]&!i[12]&i[5]&i[4]&!i[2]);

assign out.div = (i[25]&i[14]&!i[6]&i[5]&!i[2]);

assign out.rem = (i[25]&i[14]&i[13]&!i[6]&i[5]&!i[2]);

assign out.fence = (!i[5]&i[3]);

assign out.fence_i = (i[12]&!i[5]&i[3]);

assign out.pm_alu = (i[28]&i[22]&!i[13]&!i[12]&i[4]) | (i[4]&i[2]) | (!i[25]&!i[6]
    &i[4]) | (!i[5]&i[4]);

assign out.atomic = (!i[6]&i[5]&i[3]);

assign out.lr = (i[28]&!i[27]&!i[6]&i[3]);

assign out.sc = (i[28]&i[27]&!i[6]&i[3]);



assign out.i0_only = predecode.i0_only;

assign out.legal = predecode.legal1 | predecode.legal2 | predecode.legal3 | predecode.legal4;


endmodule

