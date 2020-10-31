

module eh2_exu
 import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
 (

   input wire clk,                             input wire active_clk,                      input wire clk_override,                    input wire rst_l,                           input wire scan_mode,                    
   input wire dec_extint_stall,                input wire [31:2]       dec_tlu_meihap,               
   input wire [4:2]                             dec_i0_data_en,                  input wire [4:1]                             dec_i0_ctl_en,                   input wire [4:2]                             dec_i1_data_en,                  input wire [4:1]                             dec_i1_ctl_en,                
   input wire dec_debug_wdata_rs1_d,        
   input wire [31:0]                            dbg_cmd_wrdata,               
   input wire [31:0]                            lsu_result_dc3,               
   input eh2_predict_pkt_t                      i0_predict_p_d,                  input eh2_predict_pkt_t                      i1_predict_p_d,                  input wire [pt.BHT_GHR_SIZE-1:0]             i0_predict_fghr_d,               input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]   i0_predict_index_d,              input wire [pt.BTB_BTAG_SIZE-1:0]            i0_predict_btag_d,               input wire [pt.BHT_GHR_SIZE-1:0]             i1_predict_fghr_d,               input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]   i1_predict_index_d,              input wire [pt.BTB_BTAG_SIZE-1:0]            i1_predict_btag_d,            
   input wire dec_i0_rs1_bypass_en_e2,         input wire dec_i0_rs2_bypass_en_e2,         input wire dec_i1_rs1_bypass_en_e2,         input wire dec_i1_rs2_bypass_en_e2,         input wire [31:0]                            i0_rs1_bypass_data_e2,           input wire [31:0]                            i0_rs2_bypass_data_e2,           input wire [31:0]                            i1_rs1_bypass_data_e2,           input wire [31:0]                            i1_rs2_bypass_data_e2,        
   input wire dec_i0_rs1_bypass_en_e3,         input wire dec_i0_rs2_bypass_en_e3,         input wire dec_i1_rs1_bypass_en_e3,         input wire dec_i1_rs2_bypass_en_e3,         input wire [31:0]                            i0_rs1_bypass_data_e3,           input wire [31:0]                            i0_rs2_bypass_data_e3,           input wire [31:0]                            i1_rs1_bypass_data_e3,           input wire [31:0]                            i1_rs2_bypass_data_e3,        
   input wire dec_i0_sec_decode_e3,            input wire dec_i1_sec_decode_e3,            input wire [31:1]                            dec_i0_pc_e3,                    input wire [31:1]                            dec_i1_pc_e3,                 
   input wire [pt.NUM_THREADS-1:0][31:1]        pred_correct_npc_e2,          
   input wire dec_i1_valid_e1,              
   input wire dec_i0_mul_d,                    input wire dec_i1_mul_d,                 
   input wire dec_i0_div_d,                    input wire dec_div_cancel,               
   input wire [31:0]                            gpr_i0_rs1_d,                    input wire [31:0]                            gpr_i0_rs2_d,                    input wire [31:0]                            dec_i0_immed_d,               
   input wire [31:0]                            gpr_i1_rs1_d,                    input wire [31:0]                            gpr_i1_rs2_d,                    input wire [31:0]                            dec_i1_immed_d,               
   input wire [31:0]                            i0_rs1_bypass_data_d,            input wire [31:0]                            i0_rs2_bypass_data_d,            input wire [31:0]                            i1_rs1_bypass_data_d,            input wire [31:0]                            i1_rs2_bypass_data_d,         
   input wire [12:1]                            dec_i0_br_immed_d,               input wire [12:1]                            dec_i1_br_immed_d,            
   input wire dec_i0_lsu_d,                    input wire dec_i1_lsu_d,                 
   input wire dec_i0_csr_ren_d,             
   input eh2_alu_pkt_t                          i0_ap,                           input eh2_alu_pkt_t                          i1_ap,                        
   input eh2_mul_pkt_t                          mul_p,                           input eh2_div_pkt_t                          div_p,                        
   input wire dec_i0_alu_decode_d,             input wire dec_i1_alu_decode_d,          
   input wire dec_i0_select_pc_d,              input wire dec_i1_select_pc_d,           
   input wire [31:1]                            dec_i0_pc_d,
   input wire [31:1]                            dec_i1_pc_d,                  
   input wire dec_i0_rs1_bypass_en_d,          input wire dec_i0_rs2_bypass_en_d,          input wire dec_i1_rs1_bypass_en_d,          input wire dec_i1_rs2_bypass_en_d,       
   input wire [pt.NUM_THREADS-1:0]              dec_tlu_flush_lower_wb,          input wire [pt.NUM_THREADS-1:0] [31:1]       dec_tlu_flush_path_wb,        
   input wire dec_tlu_i0_valid_e4,             input wire dec_tlu_i1_valid_e4,          


   output logic [31:0]                           exu_i0_result_e1,                output logic [31:0]                           exu_i1_result_e1,                output logic [31:1]                           exu_i0_pc_e1,                    output logic [31:1]                           exu_i1_pc_e1,                 
   output logic [31:0]                           exu_i0_result_e4,                output logic [31:0]                           exu_i1_result_e4,             
   output logic [31:0]                           exu_lsu_rs1_d,                   output logic [31:0]                           exu_lsu_rs2_d,                
   output logic [31:0]                           exu_i0_csr_rs1_e1,            
   output logic [pt.NUM_THREADS-1:0]             exu_flush_final,                 output logic [pt.NUM_THREADS-1:0]             exu_i0_flush_final,              output logic [pt.NUM_THREADS-1:0]             exu_i1_flush_final,           

   output logic [pt.NUM_THREADS-1:0][31:1]       exu_flush_path_final,         
   output logic [31:0]                           exu_mul_result_e3,            
   output logic [31:0]                           exu_div_result,                  output logic                                  exu_div_wren,                    output logic [pt.NUM_THREADS-1:0] [31:1]      exu_npc_e4,                   
   output logic [pt.NUM_THREADS-1:0]             exu_i0_flush_lower_e4,           output logic [pt.NUM_THREADS-1:0]             exu_i1_flush_lower_e4,        
   output logic [31:1]                           exu_i0_flush_path_e4,            output logic [31:1]                           exu_i1_flush_path_e4,         


   output eh2_predict_pkt_t [pt.NUM_THREADS-1:0]                    exu_mp_pkt,      output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_eghr,     output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_fghr,     output logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_mp_index,    output logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          exu_mp_btag,  


   output logic [1:0]                            exu_i0_br_hist_e4,               output logic                                  exu_i0_br_bank_e4,               output logic                                  exu_i0_br_error_e4,              output logic                                  exu_i0_br_start_error_e4,        output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  exu_i0_br_index_e4,              output logic                                  exu_i0_br_valid_e4,              output logic                                  exu_i0_br_mp_e4,                 output logic                                  exu_i0_br_way_e4,                output logic                                  exu_i0_br_middle_e4,             output logic [pt.BHT_GHR_SIZE-1:0]            exu_i0_br_fghr_e4,               output logic                                  exu_i0_br_ret_e4,                output logic                                  exu_i0_br_call_e4,            
   output logic [1:0]                            exu_i1_br_hist_e4,               output logic                                  exu_i1_br_bank_e4,               output logic                                  exu_i1_br_error_e4,              output logic                                  exu_i1_br_start_error_e4,        output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  exu_i1_br_index_e4,              output logic                                  exu_i1_br_valid_e4,              output logic                                  exu_i1_br_mp_e4,                 output logic                                  exu_i1_br_way_e4,                output logic                                  exu_i1_br_middle_e4,             output logic [pt.BHT_GHR_SIZE-1:0]            exu_i1_br_fghr_e4,               output logic                                  exu_i1_br_ret_e4,                output logic                                  exu_i1_br_call_e4,            
   output logic                                  exu_pmu_i0_br_misp,              output logic                                  exu_pmu_i0_br_ataken,            output logic                                  exu_pmu_i0_pc4,                  output logic                                  exu_pmu_i1_br_misp,              output logic                                  exu_pmu_i1_br_ataken,            output logic                                  exu_pmu_i1_pc4                
   );


wire [31:0] i0_rs1_d;
wire [31:0] i0_rs2_d;
wire [31:0] i1_rs1_d;
wire [31:0] i1_rs2_d;

reg [pt.NUM_THREADS-1:0] i0_flush_upper_e1;
reg [pt.NUM_THREADS-1:0] i1_flush_upper_e1;

   reg [31:1]                      i0_flush_path_e1;
   reg [31:1]                      i1_flush_path_e1;

   wire [31:0]                      i0_rs1_final_d;

wire [31:0] mul_rs1_d;
wire [31:0] mul_rs2_d;

wire [31:0] div_rs1_d;
wire [31:0] div_rs2_d;

   reg                             i1_valid_e2;

reg [31:0] i0_rs1_e1;
reg [31:0] i0_rs2_e1;
wire [31:0] i0_rs1_e2;
wire [31:0] i0_rs2_e2;
wire [31:0] i0_rs1_e3;
wire [31:0] i0_rs2_e3;
reg [12:1] i0_br_immed_e1;
reg [12:1] i0_br_immed_e2;
reg [12:1] i0_br_immed_e3;

reg [31:0] i1_rs1_e1;
reg [31:0] i1_rs2_e1;
wire [31:0] i1_rs1_e2;
wire [31:0] i1_rs2_e2;
wire [31:0] i1_rs1_e3;
wire [31:0] i1_rs2_e3;

reg [12:1] i1_br_immed_e1;
reg [12:1] i1_br_immed_e2;
reg [12:1] i1_br_immed_e3;

wire [31:0] i0_rs1_e2_final;
wire [31:0] i0_rs2_e2_final;
wire [31:0] i1_rs1_e2_final;
wire [31:0] i1_rs2_e2_final;
wire [31:0] i0_rs1_e3_final;
wire [31:0] i0_rs2_e3_final;
wire [31:0] i1_rs1_e3_final;
wire [31:0] i1_rs2_e3_final;
reg [31:1] i0_alu_pc_unused;
reg [31:1] i1_alu_pc_unused;
reg [pt.NUM_THREADS-1:0] i0_flush_upper_e2;
reg [pt.NUM_THREADS-1:0] i1_flush_upper_e2;
reg i1_valid_e3;
wire i1_valid_e4;
wire [pt.NUM_THREADS-1:0] [31:1] pred_correct_npc_e3;
wire [pt.NUM_THREADS-1:0] [31:1] pred_correct_npc_e4;
   reg [pt.NUM_THREADS-1:0]        i0_flush_upper_e3;
   reg [pt.NUM_THREADS-1:0]        i0_flush_upper_e4;
reg i1_pred_correct_upper_e1;
reg i0_pred_correct_upper_e1;
reg i1_pred_correct_upper_e2;
reg i0_pred_correct_upper_e2;
reg i1_pred_correct_upper_e3;
reg i0_pred_correct_upper_e3;
reg i1_pred_correct_upper_e4;
reg i0_pred_correct_upper_e4;
reg i1_pred_correct_lower_e4;
reg i0_pred_correct_lower_e4;

   wire [pt.NUM_THREADS-1:0]        i1_valid_e4_eff;
reg i1_sec_decode_e4;
reg i0_sec_decode_e4;
wire i1_pred_correct_e4_eff;
wire i0_pred_correct_e4_eff;
wire [31:1] i1_flush_path_e4_eff;
wire [31:1] i0_flush_path_e4_eff;
   wire [31:0]                      i0_csr_rs1_in_d;
reg [31:1] i1_flush_path_upper_e2;
reg [31:1] i0_flush_path_upper_e2;
reg [31:1] i1_flush_path_upper_e3;
reg [31:1] i0_flush_path_upper_e3;
reg [31:1] i1_flush_path_upper_e4;
reg [31:1] i0_flush_path_upper_e4;

   eh2_alu_pkt_t                    i0_ap_e1, i0_ap_e2, i0_ap_e3, i0_ap_e4;
   eh2_alu_pkt_t                    i1_ap_e1, i1_ap_e2, i1_ap_e3, i1_ap_e4;

wire i0_e1_data_en;
wire i0_e2_data_en;
wire i0_e3_data_en;
wire i0_e1_ctl_en;
wire i0_e2_ctl_en;
wire i0_e3_ctl_en;
wire i0_e4_ctl_en;

wire i1_e1_data_en;
wire i1_e2_data_en;
wire i1_e3_data_en;
wire i1_e1_ctl_en;
wire i1_e2_ctl_en;
wire i1_e3_ctl_en;
wire i1_e4_ctl_en;

   localparam PREDPIPESIZE = pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1+pt.BHT_GHR_SIZE+pt.BTB_BTAG_SIZE;
wire [PREDPIPESIZE-1:0] i0_predpipe_d;
reg [PREDPIPESIZE-1:0] i0_predpipe_e1;
reg [PREDPIPESIZE-1:0] i0_predpipe_e2;
reg [PREDPIPESIZE-1:0] i0_predpipe_e3;
reg [PREDPIPESIZE-1:0] i0_predpipe_e4;
wire [PREDPIPESIZE-1:0] i1_predpipe_d;
reg [PREDPIPESIZE-1:0] i1_predpipe_e1;
reg [PREDPIPESIZE-1:0] i1_predpipe_e2;
reg [PREDPIPESIZE-1:0] i1_predpipe_e3;
reg [PREDPIPESIZE-1:0] i1_predpipe_e4;

wire i0_taken_e1;
wire i1_taken_e1;
reg dec_i0_alu_decode_e1;
reg dec_i1_alu_decode_e1;
   reg [pt.NUM_THREADS-1:0]        flush_final_f;

   eh2_predict_pkt_t                i0_predict_p_e1, i0_predict_p_e4;
   eh2_predict_pkt_t                i1_predict_p_e1, i1_predict_p_e4;

   eh2_predict_pkt_t                i0_pp_e2, i0_pp_e3, i0_pp_e4_in;
   eh2_predict_pkt_t                i1_pp_e2, i1_pp_e3, i1_pp_e4_in;
   eh2_predict_pkt_t                i0_predict_newp_d, i1_predict_newp_d;


wire [pt.NUM_THREADS-1:0] i0_valid_e1;
wire [pt.NUM_THREADS-1:0] i1_valid_e1;
wire [pt.NUM_THREADS-1:0] i0_valid_e4;
wire [pt.NUM_THREADS-1:0] i1_pred_valid_e4;
wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ghr_e1_ns;
wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ghr_e1;
wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ghr_e4_ns;
wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0] ghr_e4;
wire [pt.NUM_THREADS-1:0] fp_enable;
reg [pt.NUM_THREADS-1:0] fp_enable_ff;
   wire [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]  after_flush_eghr;
wire [pt.NUM_THREADS-1:0] [PREDPIPESIZE-1:0] final_predpipe_mp;
wire [pt.NUM_THREADS-1:0] [PREDPIPESIZE-1:0] final_predpipe_mp_ff;
   eh2_predict_pkt_t [pt.NUM_THREADS-1:0]           final_predict_mp;
   wire [pt.NUM_THREADS-1:0] [31:1]                 flush_path_e2;




   assign i0_rs1_d[31:0]       = ({32{~dec_i0_rs1_bypass_en_d}} & ((dec_debug_wdata_rs1_d) ? dbg_cmd_wrdata[31:0] : gpr_i0_rs1_d[31:0])) |
                                 ({32{~dec_i0_rs1_bypass_en_d   & dec_i0_select_pc_d}} & { dec_i0_pc_d[31:1], 1'b0}) |                                     ({32{ dec_i0_rs1_bypass_en_d}} & i0_rs1_bypass_data_d[31:0]);


   assign i0_rs1_final_d[31:0] =  {32{~dec_i0_csr_ren_d}}       & i0_rs1_d[31:0];

   assign i0_rs2_d[31:0]       = ({32{~dec_i0_rs2_bypass_en_d}} & gpr_i0_rs2_d[31:0]        ) |
                                 ({32{~dec_i0_rs2_bypass_en_d}} & dec_i0_immed_d[31:0]      ) |
                                 ({32{ dec_i0_rs2_bypass_en_d}} & i0_rs2_bypass_data_d[31:0]);

   assign i1_rs1_d[31:0]       = ({32{~dec_i1_rs1_bypass_en_d}} & gpr_i1_rs1_d[31:0]) |
                                 ({32{~dec_i1_rs1_bypass_en_d   & dec_i1_select_pc_d}} & { dec_i1_pc_d[31:1], 1'b0}) |                                   ({32{ dec_i1_rs1_bypass_en_d}} & i1_rs1_bypass_data_d[31:0]);


   assign i1_rs2_d[31:0]       = ({32{~dec_i1_rs2_bypass_en_d}} & gpr_i1_rs2_d[31:0]        ) |
                                 ({32{~dec_i1_rs2_bypass_en_d}} & dec_i1_immed_d[31:0]      ) |
                                 ({32{ dec_i1_rs2_bypass_en_d}} & i1_rs2_bypass_data_d[31:0]);


   assign exu_lsu_rs1_d[31:0]  = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & gpr_i0_rs1_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs1_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & gpr_i1_rs1_d[31:0]        ) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & i0_rs1_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs1_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & i1_rs1_bypass_data_d[31:0]) |
                                 ({32{                                            dec_extint_stall               }} & {dec_tlu_meihap[31:2],2'b0});

   assign exu_lsu_rs2_d[31:0]  = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & gpr_i0_rs2_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs2_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & gpr_i1_rs2_d[31:0]        ) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & i0_rs2_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs2_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & i1_rs2_bypass_data_d[31:0]);


   assign mul_rs1_d[31:0]      = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_mul_d               }} & gpr_i0_rs1_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs1_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & gpr_i1_rs1_d[31:0]        ) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_mul_d               }} & i0_rs1_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs1_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & i1_rs1_bypass_data_d[31:0]);

   assign mul_rs2_d[31:0]      = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_mul_d               }} & gpr_i0_rs2_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs2_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & gpr_i1_rs2_d[31:0]        ) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_mul_d               }} & i0_rs2_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs2_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & i1_rs2_bypass_data_d[31:0]);



   assign div_rs1_d[31:0]      = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_div_d               }} & gpr_i0_rs1_d[31:0]) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_div_d               }} & i0_rs1_bypass_data_d[31:0]);

   assign div_rs2_d[31:0]      = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_div_d               }} & gpr_i0_rs2_d[31:0]) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_div_d               }} & i0_rs2_bypass_data_d[31:0]);



   assign i0_csr_rs1_in_d[31:0] = (dec_i0_csr_ren_d) ? i0_rs1_d[31:0] : exu_i0_csr_rs1_e1[31:0];

   assign {i0_e1_data_en, i0_e2_data_en, i0_e3_data_en }                = dec_i0_data_en[4:2];
   assign {i0_e1_ctl_en,  i0_e2_ctl_en,  i0_e3_ctl_en,  i0_e4_ctl_en }  = dec_i0_ctl_en[4:1];

   assign {i1_e1_data_en, i1_e2_data_en, i1_e3_data_en}                = dec_i1_data_en[4:2];
   assign {i1_e1_ctl_en,  i1_e2_ctl_en,  i1_e3_ctl_en,  i1_e4_ctl_en}  = dec_i1_ctl_en[4:1];


   rvdffe #(32) i0_csr_rs1_ff (.*, .en(i0_e1_data_en), .din(i0_csr_rs1_in_d[31:0]), .dout(exu_i0_csr_rs1_e1[31:0]));


   eh2_exu_mul_ctl #(.pt(pt)) mul_e1    (.*,
                          .clk_override  ( clk_override                ),   // I
                          .mp            ( mul_p                       ),   // I
                          .a             ( mul_rs1_d[31:0]             ),   // I
                          .b             ( mul_rs2_d[31:0]             ),   // I
                          .out           ( exu_mul_result_e3[31:0]     ));  // O


   eh2_exu_div_ctl #(.pt(pt)) div_e1    (.*,
                          .cancel        ( dec_div_cancel              ),   // I
                          .dp            ( div_p                       ),   // I
                          .dividend      ( div_rs1_d[31:0]             ),   // I
                          .divisor       ( div_rs2_d[31:0]             ),   // I
                          .finish_dly    ( exu_div_wren                ),   // O
                          .out           ( exu_div_result[31:0]        ));  // O




   always @* begin
      i0_predict_newp_d         = i0_predict_p_d;
      i0_predict_newp_d.boffset = dec_i0_pc_d[1];        i0_predict_newp_d.bank    = i0_predict_p_d.bank;

      i1_predict_newp_d         = i1_predict_p_d;
      i1_predict_newp_d.boffset = dec_i1_pc_d[1];
      i1_predict_newp_d.bank    = i1_predict_p_d.bank;

   end


eh2_exu_alu_ctl #(.pt(pt)) i0_alu_e1 (.*,
                          .enable        ( i0_e1_ctl_en                ),   // I
                          .predict_p     ( i0_predict_newp_d           ),   // I
                          .valid         ( dec_i0_alu_decode_d         ),   // I
                          .flush         ( exu_flush_final             ),   // I
                          .a             ( i0_rs1_final_d[31:0]        ),   // I
                          .b             ( i0_rs2_d[31:0]              ),   // I
                          .pc            ( dec_i0_pc_d[31:1]           ),   // I
                          .brimm         ( dec_i0_br_immed_d[12:1]     ),   // I
                          .ap_in_tid     ( i0_ap.tid                   ),   // I
                          .ap            ( i0_ap_e1                    ),   // I
                          .out           ( exu_i0_result_e1[31:0]      ),   // O
                          .flush_upper   ( i0_flush_upper_e1           ),   // O
                          .flush_path    ( i0_flush_path_e1[31:1]      ),   // O
                          .predict_p_ff  ( i0_predict_p_e1             ),   // O
                          .pc_ff         ( exu_i0_pc_e1[31:1]          ),   // O
                          .pred_correct  ( i0_pred_correct_upper_e1    )    // O
                          );


   eh2_exu_alu_ctl #(.pt(pt)) i1_alu_e1 (.*,
                          .enable        ( i1_e1_ctl_en                ),   // I
                          .predict_p     ( i1_predict_newp_d           ),   // I
                          .valid         ( dec_i1_alu_decode_d         ),   // I
                          .flush         ( exu_flush_final             ),   // I
                          .a             ( i1_rs1_d[31:0]              ),   // I
                          .b             ( i1_rs2_d[31:0]              ),   // I
                          .pc            ( dec_i1_pc_d[31:1]           ),   // I
                          .brimm         ( dec_i1_br_immed_d[12:1]     ),   // I
                          .ap_in_tid     ( i1_ap.tid                   ),   // I
                          .ap            ( i1_ap_e1                    ),   // I
                          .out           ( exu_i1_result_e1[31:0]      ),   // O
                          .flush_upper   ( i1_flush_upper_e1           ),   // O
                          .flush_path    ( i1_flush_path_e1[31:1]      ),   // O
                          .predict_p_ff  ( i1_predict_p_e1             ),   // O
                          .pc_ff         ( exu_i1_pc_e1[31:1]          ),   // O
                          .pred_correct  ( i1_pred_correct_upper_e1    )    // O
                          );





   assign i0_predpipe_d[PREDPIPESIZE-1:0] = {i0_predict_fghr_d, i0_predict_index_d, i0_predict_btag_d};
   assign i1_predpipe_d[PREDPIPESIZE-1:0] = {i1_predict_fghr_d, i1_predict_index_d, i1_predict_btag_d};

 rvdffe #($bits(eh2_predict_pkt_t))  i0_pp_e2_ff            (.*, .en ( i0_e2_ctl_en      ),  .din ( i0_predict_p_e1                  ),  .dout ( i0_pp_e2                      ) );
   rvdffe #($bits(eh2_predict_pkt_t))  i0_pp_e3_ff            (.*, .en ( i0_e3_ctl_en      ),  .din ( i0_pp_e2                         ),  .dout ( i0_pp_e3                      ) );

   rvdffe #($bits(eh2_predict_pkt_t))  i1_pp_e2_ff            (.*, .en ( i1_e2_ctl_en      ),  .din( i1_predict_p_e1                   ),  .dout( i1_pp_e2                       ) );
   rvdffe #($bits(eh2_predict_pkt_t))  i1_pp_e3_ff            (.*, .en ( i1_e3_ctl_en      ),  .din( i1_pp_e2                          ),  .dout( i1_pp_e3                       ) );


   rvdffe #(PREDPIPESIZE)               i0_predpipe_e1_ff      (.*, .en ( i0_e1_data_en     ),  .din( i0_predpipe_d                     ),  .dout( i0_predpipe_e1                 ) );
   rvdffe #(PREDPIPESIZE)               i0_predpipe_e2_ff      (.*, .en ( i0_e2_data_en     ),  .din( i0_predpipe_e1                    ),  .dout( i0_predpipe_e2                 ) );
   rvdffe #(PREDPIPESIZE)               i0_predpipe_e3_ff      (.*, .en ( i0_e3_data_en     ),  .din( i0_predpipe_e2                    ),  .dout( i0_predpipe_e3                 ) );
   rvdffe #(PREDPIPESIZE)               i0_predpipe_e4_ff      (.*, .en ( i0_e4_ctl_en      ),  .din( i0_predpipe_e3                    ),  .dout( i0_predpipe_e4                 ) );

   rvdffe #(PREDPIPESIZE)               i1_predpipe_e1_ff      (.*, .en ( i1_e1_data_en     ),  .din( i1_predpipe_d                     ),  .dout( i1_predpipe_e1                 ) );
   rvdffe #(PREDPIPESIZE)               i1_predpipe_e2_ff      (.*, .en ( i1_e2_data_en     ),  .din( i1_predpipe_e1                    ),  .dout( i1_predpipe_e2                 ) );
   rvdffe #(PREDPIPESIZE)               i1_predpipe_e3_ff      (.*, .en ( i1_e3_data_en     ),  .din( i1_predpipe_e2                    ),  .dout( i1_predpipe_e3                 ) );
   rvdffe #(PREDPIPESIZE)               i1_predpipe_e4_ff      (.*, .en ( i1_e4_ctl_en      ),  .din( i1_predpipe_e3                    ),  .dout( i1_predpipe_e4                 ) );



   assign exu_pmu_i0_br_misp   = i0_predict_p_e4.misp;
   assign exu_pmu_i0_br_ataken = i0_predict_p_e4.ataken;
   assign exu_pmu_i0_pc4       = i0_predict_p_e4.pc4;
   assign exu_pmu_i1_br_misp   = i1_predict_p_e4.misp;
   assign exu_pmu_i1_br_ataken = i1_predict_p_e4.ataken;
   assign exu_pmu_i1_pc4       = i1_predict_p_e4.pc4;



   assign i0_pp_e4_in = i0_pp_e3;
   assign i1_pp_e4_in = i1_pp_e3;

   rvdffe #($bits(eh2_alu_pkt_t)) i0_ap_e1_ff (.*,  .en(i0_e1_ctl_en), .din(i0_ap),   .dout(i0_ap_e1) );
   rvdffe #($bits(eh2_alu_pkt_t)) i0_ap_e2_ff (.*,  .en(i0_e2_ctl_en), .din(i0_ap_e1),.dout(i0_ap_e2) );
   rvdffe #($bits(eh2_alu_pkt_t)) i0_ap_e3_ff (.*,  .en(i0_e3_ctl_en), .din(i0_ap_e2),.dout(i0_ap_e3) );
   rvdffe #($bits(eh2_alu_pkt_t)) i0_ap_e4_ff (.*,  .en(i0_e4_ctl_en), .din(i0_ap_e3),.dout(i0_ap_e4) );


   rvdffe #($bits(eh2_alu_pkt_t)) i1_ap_e1_ff (.*,  .en(i1_e1_ctl_en), .din(i1_ap),   .dout(i1_ap_e1) );
   rvdffe #($bits(eh2_alu_pkt_t)) i1_ap_e2_ff (.*,  .en(i1_e2_ctl_en), .din(i1_ap_e1),.dout(i1_ap_e2) );
   rvdffe #($bits(eh2_alu_pkt_t)) i1_ap_e3_ff (.*,  .en(i1_e3_ctl_en), .din(i1_ap_e2),.dout(i1_ap_e3) );
   rvdffe #($bits(eh2_alu_pkt_t)) i1_ap_e4_ff (.*,  .en(i1_e4_ctl_en), .din(i1_ap_e3),.dout(i1_ap_e4) );



   rvdffe #(76) i0_src_e1_ff (.*,
                            .en  (i0_e1_data_en),
                            .din ({i0_rs1_d [31:0], i0_rs2_d [31:0], dec_i0_br_immed_d [12:1]}),
                            .dout({i0_rs1_e1[31:0], i0_rs2_e1[31:0],     i0_br_immed_e1[12:1]}));

   rvdffe #(76) i0_src_e2_ff (.*,
                            .en  (i0_e2_data_en),
                            .din( {i0_rs1_e1[31:0], i0_rs2_e1[31:0], i0_br_immed_e1[12:1]}),
                            .dout({i0_rs1_e2[31:0], i0_rs2_e2[31:0], i0_br_immed_e2[12:1]}));

   rvdffe #(76) i0_src_e3_ff (.*,
                            .en  (i0_e3_data_en),
                            .din( {i0_rs1_e2_final[31:0], i0_rs2_e2_final[31:0], i0_br_immed_e2[12:1]}),
                            .dout({i0_rs1_e3[31:0],       i0_rs2_e3[31:0],       i0_br_immed_e3[12:1]}));



   rvdffe #(76) i1_src_e1_ff (.*,
                            .en  (i1_e1_data_en),
                            .din ({i1_rs1_d [31:0], i1_rs2_d [31:0], dec_i1_br_immed_d [12:1]}),
                            .dout({i1_rs1_e1[31:0], i1_rs2_e1[31:0],     i1_br_immed_e1[12:1]}));

   rvdffe #(76) i1_src_e2_ff (.*,
                            .en  (i1_e2_data_en),
                            .din ({i1_rs1_e1[31:0], i1_rs2_e1[31:0], i1_br_immed_e1[12:1]}),
                            .dout({i1_rs1_e2[31:0], i1_rs2_e2[31:0], i1_br_immed_e2[12:1]}));

   rvdffe #(76) i1_src_e3_ff (.*,
                            .en  (i1_e3_data_en),
                            .din ({i1_rs1_e2_final[31:0], i1_rs2_e2_final[31:0], i1_br_immed_e2[12:1]}),
                            .dout({i1_rs1_e3[31:0],       i1_rs2_e3[31:0],       i1_br_immed_e3[12:1]}));




   assign i0_rs1_e2_final[31:0] = (dec_i0_rs1_bypass_en_e2) ? i0_rs1_bypass_data_e2[31:0] : i0_rs1_e2[31:0];
   assign i0_rs2_e2_final[31:0] = (dec_i0_rs2_bypass_en_e2) ? i0_rs2_bypass_data_e2[31:0] : i0_rs2_e2[31:0];
   assign i1_rs1_e2_final[31:0] = (dec_i1_rs1_bypass_en_e2) ? i1_rs1_bypass_data_e2[31:0] : i1_rs1_e2[31:0];
   assign i1_rs2_e2_final[31:0] = (dec_i1_rs2_bypass_en_e2) ? i1_rs2_bypass_data_e2[31:0] : i1_rs2_e2[31:0];


   assign i0_rs1_e3_final[31:0] = (dec_i0_rs1_bypass_en_e3) ? i0_rs1_bypass_data_e3[31:0] : i0_rs1_e3[31:0];
   assign i0_rs2_e3_final[31:0] = (dec_i0_rs2_bypass_en_e3) ? i0_rs2_bypass_data_e3[31:0] : i0_rs2_e3[31:0];
   assign i1_rs1_e3_final[31:0] = (dec_i1_rs1_bypass_en_e3) ? i1_rs1_bypass_data_e3[31:0] : i1_rs1_e3[31:0];
   assign i1_rs2_e3_final[31:0] = (dec_i1_rs2_bypass_en_e3) ? i1_rs2_bypass_data_e3[31:0] : i1_rs2_e3[31:0];



   assign i0_taken_e1  = (i0_predict_p_e1.ataken & dec_i0_alu_decode_e1) | (i0_predict_p_e1.hist[1] & ~dec_i0_alu_decode_e1);
   assign i1_taken_e1  = (i1_predict_p_e1.ataken & dec_i1_alu_decode_e1) | (i1_predict_p_e1.hist[1] & ~dec_i1_alu_decode_e1);

rvdff #(2) e1ghrdecff                  (.*, .clk(active_clk), .din({dec_i0_alu_decode_d, dec_i1_alu_decode_d}), .dout({dec_i0_alu_decode_e1, dec_i1_alu_decode_e1}));




   eh2_exu_alu_ctl #(.pt(pt)) i0_alu_e4 (.*,
                          .enable        ( i0_e4_ctl_en                ),   // I
                          .predict_p     ( i0_pp_e4_in                 ),   // I
                          .valid         ( dec_i0_sec_decode_e3        ),   // I
                          .flush         ( dec_tlu_flush_lower_wb      ),   // I
                          .a             ( i0_rs1_e3_final[31:0]       ),   // I
                          .b             ( i0_rs2_e3_final[31:0]       ),   // I
                          .pc            ( dec_i0_pc_e3[31:1]          ),   // I
                          .brimm         ( i0_br_immed_e3[12:1]        ),   // I
                          .ap_in_tid     ( i0_ap_e3.tid                ),   // I
                          .ap            ( i0_ap_e4                    ),   // I
                          .out           ( exu_i0_result_e4[31:0]      ),   // O
                          .flush_upper   ( exu_i0_flush_lower_e4       ),   // O
                          .flush_path    ( exu_i0_flush_path_e4[31:1]  ),   // O
                          .predict_p_ff  ( i0_predict_p_e4             ),   // O
                          .pc_ff         ( i0_alu_pc_unused[31:1]      ),   // O
                          .pred_correct  ( i0_pred_correct_lower_e4    )    // O
                          );


   eh2_exu_alu_ctl #(.pt(pt)) i1_alu_e4 (.*,
                          .enable        ( i1_e4_ctl_en                ),   // I
                          .predict_p     ( i1_pp_e4_in                 ),   // I
                          .valid         ( dec_i1_sec_decode_e3        ),   // I
                          .flush         ( dec_tlu_flush_lower_wb      ),   // I
                          .a             ( i1_rs1_e3_final[31:0]       ),   // I
                          .b             ( i1_rs2_e3_final[31:0]       ),   // I
                          .pc            ( dec_i1_pc_e3[31:1]          ),   // I
                          .brimm         ( i1_br_immed_e3[12:1]        ),   // I
                          .ap_in_tid     ( i1_ap_e3.tid                ),   // I
                          .ap            ( i1_ap_e4                    ),   // I
                          .out           ( exu_i1_result_e4[31:0]      ),   // O
                          .flush_upper   ( exu_i1_flush_lower_e4       ),   // O
                          .flush_path    ( exu_i1_flush_path_e4[31:1]  ),   // O
                          .predict_p_ff  ( i1_predict_p_e4             ),   // O
                          .pc_ff         ( i1_alu_pc_unused[31:1]      ),   // O
                          .pred_correct  ( i1_pred_correct_lower_e4    )    // O
                          );


   assign exu_i0_br_hist_e4[1:0]               =  i0_predict_p_e4.hist[1:0];
   assign exu_i0_br_bank_e4                    =  i0_predict_p_e4.bank;
   assign exu_i0_br_error_e4                   =  i0_predict_p_e4.br_error;
   assign exu_i0_br_middle_e4                  =  i0_predict_p_e4.pc4 ^ i0_predict_p_e4.boffset;
   assign exu_i0_br_start_error_e4             =  i0_predict_p_e4.br_start_error;

   assign exu_i0_br_valid_e4                   =  i0_predict_p_e4.valid;
   assign exu_i0_br_mp_e4                      =  i0_predict_p_e4.misp;    assign exu_i0_br_ret_e4                     =  i0_predict_p_e4.pret;
   assign exu_i0_br_call_e4                    =  i0_predict_p_e4.pcall;
   assign exu_i0_br_way_e4                     =  i0_predict_p_e4.way;

   assign {exu_i0_br_fghr_e4[pt.BHT_GHR_SIZE-1:0],
           exu_i0_br_index_e4[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]} =  i0_predpipe_e4[PREDPIPESIZE-1:pt.BTB_BTAG_SIZE];

   assign exu_i1_br_hist_e4[1:0]               =  i1_predict_p_e4.hist[1:0];
   assign exu_i1_br_bank_e4                    =  i1_predict_p_e4.bank;
   assign exu_i1_br_middle_e4                  =  i1_predict_p_e4.pc4 ^ i1_predict_p_e4.boffset;
   assign exu_i1_br_error_e4                   =  i1_predict_p_e4.br_error;

   assign exu_i1_br_start_error_e4             =  i1_predict_p_e4.br_start_error;
   assign exu_i1_br_valid_e4                   =  i1_predict_p_e4.valid;
   assign exu_i1_br_mp_e4                      =  i1_predict_p_e4.misp;
   assign exu_i1_br_way_e4                     =  i1_predict_p_e4.way;
   assign exu_i1_br_ret_e4                     =  i1_predict_p_e4.pret;
   assign exu_i1_br_call_e4                    =  i1_predict_p_e4.pcall;

   assign {exu_i1_br_fghr_e4[pt.BHT_GHR_SIZE-1:0],
           exu_i1_br_index_e4[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]} =  i1_predpipe_e4[PREDPIPESIZE-1:pt.BTB_BTAG_SIZE];



   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign fp_enable[i]                             = (exu_i0_flush_lower_e4[i]) | (exu_i1_flush_lower_e4[i]) |
                                                        (i0_flush_upper_e1[i])     | (i1_flush_upper_e1[i]);

      assign final_predict_mp[i]                      = (exu_i0_flush_lower_e4[i])  ?  i0_predict_p_e4 :
                                                        (exu_i1_flush_lower_e4[i])  ?  i1_predict_p_e4 :
                                                        (i0_flush_upper_e1[i])      ?  i0_predict_p_e1 :
                                                        (i1_flush_upper_e1[i])      ?  i1_predict_p_e1 : '0;

      assign final_predpipe_mp[i][PREDPIPESIZE-1:0]   = (exu_i0_flush_lower_e4[i])  ?  i0_predpipe_e4  :
                                                        (exu_i1_flush_lower_e4[i])  ?  i1_predpipe_e4  :
                                                        (i0_flush_upper_e1[i])      ?  i0_predpipe_e1  :
                                                        (i1_flush_upper_e1[i])      ?  i1_predpipe_e1  : '0;


      assign after_flush_eghr[i][pt.BHT_GHR_SIZE-1:0] = (i0_flush_upper_e2[i] | i1_flush_upper_e2[i] & ~dec_tlu_flush_lower_wb[i]) ? ghr_e1[i][pt.BHT_GHR_SIZE-1:0] : ghr_e4[i][pt.BHT_GHR_SIZE-1:0];

      assign exu_mp_fghr[i][pt.BHT_GHR_SIZE-1:0]      =  after_flush_eghr[i][pt.BHT_GHR_SIZE-1:0];     
      assign {exu_mp_index[i][pt.BTB_ADDR_HI:pt.BTB_ADDR_LO],
              exu_mp_btag[i][pt.BTB_BTAG_SIZE-1:0]}   =  final_predpipe_mp_ff[i][PREDPIPESIZE-pt.BHT_GHR_SIZE-1:0];
      assign  exu_mp_eghr[i][pt.BHT_GHR_SIZE-1:0]     =  final_predpipe_mp_ff[i][PREDPIPESIZE-1:pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+pt.BTB_BTAG_SIZE+1]; 

            assign i0_valid_e1[i]  = ~exu_flush_final[i] & ~flush_final_f[i] & (i0_predict_p_e1.valid | i0_predict_p_e1.misp);
      assign i1_valid_e1[i]  = ~exu_flush_final[i] & ~flush_final_f[i] & (i1_predict_p_e1.valid | i1_predict_p_e1.misp) & ~(i0_flush_upper_e1[i]);

      assign ghr_e1_ns[i][pt.BHT_GHR_SIZE-1:0]  = ({pt.BHT_GHR_SIZE{ dec_tlu_flush_lower_wb[i]}}                                                                  &  ghr_e4[i][pt.BHT_GHR_SIZE-1:0]) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] & ~i0_valid_e1[i] &  ~i1_valid_e1[i]}}                             &  ghr_e1[i][pt.BHT_GHR_SIZE-1:0]) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] & ~i0_valid_e1[i] &   i1_valid_e1[i] & ~i0_predict_p_e1.br_error}} & {ghr_e1[i][pt.BHT_GHR_SIZE-2:0], i1_taken_e1}) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] &  i0_valid_e1[i] & (~i1_valid_e1[i] |  i0_predict_p_e1.misp   )}} & {ghr_e1[i][pt.BHT_GHR_SIZE-2:0], i0_taken_e1}) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] &  i0_valid_e1[i] &   i1_valid_e1[i] & ~i0_predict_p_e1.misp    }} & {ghr_e1[i][pt.BHT_GHR_SIZE-3:0], i0_taken_e1, i1_taken_e1});


            assign i0_valid_e4[i]                     =  dec_tlu_i0_valid_e4 & (i0_ap_e4.tid==i) & ((i0_predict_p_e4.valid) | i0_predict_p_e4.misp);
      assign i1_pred_valid_e4[i]                =  dec_tlu_i1_valid_e4 & (i1_ap_e4.tid==i) & ((i1_predict_p_e4.valid) | i1_predict_p_e4.misp) & ~i0_flush_upper_e4[i];
      assign ghr_e4_ns[i][pt.BHT_GHR_SIZE-1:0]  = ({pt.BHT_GHR_SIZE{ i0_valid_e4[i] & (i0_predict_p_e4.misp |     ~i1_pred_valid_e4[i])}} & {ghr_e4[i][pt.BHT_GHR_SIZE-2:0], i0_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{ i0_valid_e4[i] & ~i0_predict_p_e4.misp &      i1_pred_valid_e4[i]}}  & {ghr_e4[i][pt.BHT_GHR_SIZE-3:0], i0_predict_p_e4.ataken, i1_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{~i0_valid_e4[i] & ~i0_predict_p_e4.br_error &  i1_pred_valid_e4[i]}}  & {ghr_e4[i][pt.BHT_GHR_SIZE-2:0], i1_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{~i0_valid_e4[i] &                             ~i1_pred_valid_e4[i]}}  &  ghr_e4[i][pt.BHT_GHR_SIZE-1:0]);

     rvdff  #(1)                         e4ghrflushff      (.*, .clk(active_clk),                    .din (exu_flush_final[i]),                 .dout(flush_final_f[i]));
      rvdff  #(1)                         final_predict_ff  (.*, .clk(active_clk),                    .din(fp_enable[i]),                        .dout(fp_enable_ff[i]));
      rvdffe #($bits(eh2_predict_pkt_t)) predict_mp_ff     (.*, .en(fp_enable[i] | fp_enable_ff[i]), .din(final_predict_mp [i]),                .dout(exu_mp_pkt[i]));
      rvdffe #(PREDPIPESIZE)              predictpipe_mp_ff (.*, .en(fp_enable[i] | fp_enable_ff[i]), .din(final_predpipe_mp[i]),                .dout(final_predpipe_mp_ff[i]));
      rvdff #(pt.BHT_GHR_SIZE)            e1ghrff           (.*, .clk(active_clk),                    .din (ghr_e1_ns[i][pt.BHT_GHR_SIZE-1:0]),  .dout(ghr_e1[i][pt.BHT_GHR_SIZE-1:0]));
      rvdff #(pt.BHT_GHR_SIZE)            e4ghrff           (.*, .clk(active_clk),                    .din (ghr_e4_ns[i][pt.BHT_GHR_SIZE-1:0]),  .dout(ghr_e4[i][pt.BHT_GHR_SIZE-1:0]));


   end

rvdffe #(31+pt.NUM_THREADS) i0_upper_flush_e2_ff (.*,
                                    .en  ( i0_e2_ctl_en),
                                    .din ({i0_flush_path_e1[31:1],
                                           i0_flush_upper_e1[pt.NUM_THREADS-1:0]}),
                                    .dout({i0_flush_path_upper_e2[31:1],
                                           i0_flush_upper_e2[pt.NUM_THREADS-1:0]}));

   rvdffe #(32+pt.NUM_THREADS) i1_upper_flush_e2_ff (.*,
                                    .en  ( i1_e2_ctl_en),
                                    .din ({dec_i1_valid_e1,
                                           i1_flush_path_e1[31:1],
                                           i1_flush_upper_e1[pt.NUM_THREADS-1:0]}),
                                    .dout({i1_valid_e2,
                                           i1_flush_path_upper_e2[31:1],
                                           i1_flush_upper_e2[pt.NUM_THREADS-1:0]}));







   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign flush_path_e2[i][31:1]           = (i0_flush_upper_e2[i])       ?  i0_flush_path_upper_e2[31:1]    :  i1_flush_path_upper_e2[31:1];
      assign exu_flush_path_final[i][31:1]    = (dec_tlu_flush_lower_wb[i])  ?  dec_tlu_flush_path_wb[i][31:1]  :  flush_path_e2[i][31:1];



      assign exu_i0_flush_final[i]         =    dec_tlu_flush_lower_wb[i] | i0_flush_upper_e2[i];
      assign exu_i1_flush_final[i]         =    dec_tlu_flush_lower_wb[i] | i1_flush_upper_e2[i];
      assign exu_flush_final[i]            =    dec_tlu_flush_lower_wb[i] | i0_flush_upper_e2[i]  | i1_flush_upper_e2[i];

   end

rvdffe #(31+pt.NUM_THREADS*32) i0_upper_flush_e3_ff (.*,
                                    .en  ( i0_e3_ctl_en | i1_e3_ctl_en),
                                    .din ({i0_flush_path_upper_e2[31:1],
                                           pred_correct_npc_e2,
                                           i0_flush_upper_e2}),
                                    .dout({i0_flush_path_upper_e3[31:1],
                                           pred_correct_npc_e3,
                                           i0_flush_upper_e3}));

   rvdffe #(32) i1_upper_flush_e3_ff (.*,
                                    .en  ( i1_e3_ctl_en),
                                    .din ({i1_valid_e2,
                                           i1_flush_path_upper_e2[31:1]}),
                                    .dout({i1_valid_e3,
                                           i1_flush_path_upper_e3[31:1]}));

   rvdffe #(31+pt.NUM_THREADS*32) i0_upper_flush_e4_ff (.*,
                                    .en  ( i0_e4_ctl_en | i1_e4_ctl_en),
                                    .din ({i0_flush_path_upper_e3[31:1],
                                           pred_correct_npc_e3,
                                           i0_flush_upper_e3}),
                                    .dout({i0_flush_path_upper_e4[31:1],
                                           pred_correct_npc_e4,
                                           i0_flush_upper_e4}));

   rvdffe #(32) i1_upper_flush_e4_ff (.*,
                                    .en  ( i1_e4_ctl_en),
                                    .din ({i1_valid_e3,
                                           i1_flush_path_upper_e3[31:1]}),
                                    .dout({i1_valid_e4,
                                           i1_flush_path_upper_e4[31:1]}));


   // npc for commit

   rvdff #(2) pred_correct_upper_e2_ff  (.*,
                                         .clk ( active_clk),
                                         .din ({i1_pred_correct_upper_e1,i0_pred_correct_upper_e1}),
                                         .dout({i1_pred_correct_upper_e2,i0_pred_correct_upper_e2}));

   rvdff #(2) pred_correct_upper_e3_ff  (.*,
                                         .clk ( active_clk),
                                         .din ({i1_pred_correct_upper_e2,i0_pred_correct_upper_e2}),
                                         .dout({i1_pred_correct_upper_e3,i0_pred_correct_upper_e3}));

   rvdff #(2) pred_correct_upper_e4_ff  (.*,
                                         .clk ( active_clk),
                                         .din ({i1_pred_correct_upper_e3,i0_pred_correct_upper_e3}),
                                         .dout({i1_pred_correct_upper_e4,i0_pred_correct_upper_e4}));

   rvdff #(2) sec_decode_e4_ff          (.*,
                                         .clk ( active_clk),
                                         .din ({dec_i0_sec_decode_e3,dec_i1_sec_decode_e3}),
                                         .dout({i0_sec_decode_e4,i1_sec_decode_e4}));






   assign i1_pred_correct_e4_eff     = (i1_sec_decode_e4) ? i1_pred_correct_lower_e4 : i1_pred_correct_upper_e4;
   assign i0_pred_correct_e4_eff     = (i0_sec_decode_e4) ? i0_pred_correct_lower_e4 : i0_pred_correct_upper_e4;

   assign i1_flush_path_e4_eff[31:1] = (i1_sec_decode_e4) ? exu_i1_flush_path_e4[31:1] : i1_flush_path_upper_e4[31:1];
   assign i0_flush_path_e4_eff[31:1] = (i0_sec_decode_e4) ? exu_i0_flush_path_e4[31:1] : i0_flush_path_upper_e4[31:1];


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
     assign i1_valid_e4_eff[i]  =  i1_valid_e4 & (i1_ap_e4.tid==i) & ~((i0_sec_decode_e4 & (i0_ap_e4.tid==i)) ?  exu_i0_flush_lower_e4[i]  :  i0_flush_upper_e4[i]);

     assign exu_npc_e4[i][31:1] = (i1_valid_e4_eff[i]) ? ((i1_pred_correct_e4_eff & (i1_ap_e4.tid==i)) ? pred_correct_npc_e4[i][31:1] : i1_flush_path_e4_eff[31:1]) :
                                                         ((i0_pred_correct_e4_eff & (i0_ap_e4.tid==i)) ? pred_correct_npc_e4[i][31:1] : i0_flush_path_e4_eff[31:1]);
   end


endmodule 