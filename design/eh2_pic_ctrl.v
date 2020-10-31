

module eh2_pic_ctrl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
                  (

                     input wire clk,                                       input wire free_clk,                                  input wire active_clk,                                input wire rst_l,                                     input wire clk_override,                              input wire [pt.PIC_TOTAL_INT_PLUS1-1:0]   extintsrc_req,                       input wire [31:0]            picm_rdaddr,                               input wire [31:0]            picm_wraddr,                               input wire [31:0]            picm_wr_data,                              input wire picm_wren,                                 input wire picm_rden,                                 input wire picm_rd_thr,                               input wire picm_mken,            
                     input wire [pt.NUM_THREADS-1:0] [3:0]             dec_tlu_meicurpl,                                input wire [pt.NUM_THREADS-1:0] [3:0]             dec_tlu_meipt,              
                     output logic [pt.NUM_THREADS-1:0]                   mexintpend_out,                                output logic [pt.NUM_THREADS-1:0] [7:0]             claimid_out,                                   output logic [pt.NUM_THREADS-1:0] [3:0]             pl_out,                                        output logic [pt.NUM_THREADS-1:0]                   mhwakeup_out,             
                     output logic [31:0]            picm_rd_data,                              input wire scan_mode             
);

localparam NUM_LEVELS            = $clog2(pt.PIC_TOTAL_INT_PLUS1);
localparam INTPRIORITY_BASE_ADDR = pt.PIC_BASE_ADDR ;
localparam INTPEND_BASE_ADDR     = pt.PIC_BASE_ADDR + 32'h00001000 ;
localparam INTPEND_THR_BASE_ADDR = pt.PIC_BASE_ADDR + 32'h00001800 ;
localparam INTENABLE_BASE_ADDR   = pt.PIC_BASE_ADDR + 32'h00002000 ;
localparam EXT_INTR_PIC_CONFIG   = pt.PIC_BASE_ADDR + 32'h00003000 ;
localparam EXT_INTR_GW_CONFIG    = pt.PIC_BASE_ADDR + 32'h00004000 ;
localparam EXT_INTR_GW_CLEAR     = pt.PIC_BASE_ADDR + 32'h00005000 ;
localparam EXT_INTR_DELG_REG     = pt.PIC_BASE_ADDR + 32'h00006000 ;


localparam INTPEND_SIZE          = (pt.PIC_TOTAL_INT_PLUS1 < 32)  ? 32  :
                                   (pt.PIC_TOTAL_INT_PLUS1 < 64)  ? 64  :
                                   (pt.PIC_TOTAL_INT_PLUS1 < 128) ? 128 :
                                   (pt.PIC_TOTAL_INT_PLUS1 < 256) ? 256 :
                                   (pt.PIC_TOTAL_INT_PLUS1 < 512) ? 512 :  1024 ;

localparam INT_GRPS              =   INTPEND_SIZE / 32 ;
localparam INTPRIORITY_BITS      =  4 ;
localparam ID_BITS               =  8 ;

reg                   mexintpend_ff;           reg [7:0]             claimid_ff;              reg [3:0]             pl_ff;                   reg                   mhwakeup_ff;             
wire  addr_intpend_base_match;
wire  addr_intpend_thr_base_match;

wire  raddr_config_pic_match ;
wire  raddr_intenable_base_match;
wire  raddr_delg_base_match;
wire  raddr_intpriority_base_match;
wire  raddr_config_gw_base_match ;

wire  waddr_config_pic_match ;
wire  waddr_intpriority_base_match;
wire  waddr_intenable_base_match;
wire  waddr_delg_base_match;
wire  waddr_config_gw_base_match ;
wire  addr_clear_gw_base_match ;

wire  mexintpend_in;
wire  mhwakeup_in ;
wire  intpend_reg_read ;
wire  intpend_thr_reg_read ;

wire [31:0] picm_rd_data_in;
reg [31:0] intpend_rd_out;
reg [31:0] intpend_thr_rd_out;
reg                                        intenable_rd_out ;
reg                                        delg_rd_out ;
reg [INTPRIORITY_BITS-1:0]                 intpriority_rd_out;
reg [1:0]                                  gw_config_rd_out;

wire [INTPRIORITY_BITS-1:0] meipt_inv;
wire [INTPRIORITY_BITS-1:0] meicurpl_inv;
wire [INTPRIORITY_BITS-1:0] meicurpl;
wire [INTPRIORITY_BITS-1:0] meipt;

wire [pt.PIC_TOTAL_INT_PLUS1-1:0] [INTPRIORITY_BITS-1:0] intpriority_reg;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0] [INTPRIORITY_BITS-1:0] intpriority_reg_inv;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        intpriority_reg_we;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        intpriority_reg_re;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        delg_thr_match;
reg [pt.PIC_TOTAL_INT_PLUS1-1:0] [1:0]                  gw_config_reg;

wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        intenable_reg;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        intenable_reg_we;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        intenable_reg_re;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        delg_reg;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        delg_reg_we;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        delg_reg_re;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        gw_config_reg_we;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        gw_config_reg_re;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]                        gw_clear_reg_we;

wire [INTPEND_SIZE-1:0]                     intpend_reg_extended;
wire [INTPEND_SIZE-1:0]                     thr_mx_intpend_reg_extended;

wire [pt.PIC_TOTAL_INT_PLUS1-1:0] [INTPRIORITY_BITS-1:0] intpend_w_prior_en;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0] [ID_BITS-1:0]          intpend_id;
wire [INTPRIORITY_BITS-1:0]                 maxint;
reg [INTPRIORITY_BITS-1:0]                 selected_int_priority;
wire [INT_GRPS-1:0] [31:0]                  intpend_rd_part_out ;
wire [INT_GRPS-1:0] [31:0]                  intpend_thr_rd_part_out ;

wire                                        curr_int_thr;
reg                                        curr_int_thr_ff;
wire                                        curr_int_thr_final;
wire                                        curr_int_thr_final_in;
wire                                        config_reg;
wire                                        intpriord;
wire                                        config_reg_we ;
wire                                        config_reg_re ;
wire                                        config_reg_in ;
reg prithresh_reg_write;
reg prithresh_reg_read;
wire                                        intpriority_reg_read ;
wire                                        intenable_reg_read   ;
wire                                        gw_config_reg_read   ;
reg picm_wren_ff;
reg picm_rden_ff;
reg                                        picm_rd_thr_ff;
reg [31:0]                                 picm_raddr_ff;
reg [31:0]                                 picm_waddr_ff;
reg [31:0]                                 picm_wr_data_ff;
reg [3:0]                                  mask;
reg                                        picm_mken_ff;
wire [ID_BITS-1:0]                          claimid_in ;
wire [INTPRIORITY_BITS-1:0]                 pl_in ;
wire [INTPRIORITY_BITS-1:0]                 pl_in_q ;

wire [pt.PIC_TOTAL_INT_PLUS1-1:0]           extintsrc_req_sync;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]           extintsrc_req_gw;
wire [pt.PIC_TOTAL_INT_PLUS1-1:0]           thr_mx_intpend_reg;
wire                                        picm_bypass_ff;
wire                                        delg_reg_read;

wire [(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2)):0] [INTPRIORITY_BITS-1:0] l2_intpend_w_prior_en_ff;
wire [(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2)):0] [ID_BITS-1:0]          l2_intpend_id_ff;
wire [NUM_LEVELS:NUM_LEVELS/2] [(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2))+1:0] [INTPRIORITY_BITS-1:0] levelx_intpend_w_prior_en;
wire [NUM_LEVELS:NUM_LEVELS/2] [(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2))+1:0] [ID_BITS-1:0]          levelx_intpend_id;

   wire                                     pic_raddr_c1_clken;
   reg                                     pic_waddr_c1_clken;
   wire                                     pic_data_c1_clken;
   wire                                     pic_pri_c1_clken;
   wire                                     pic_int_c1_clken;
   wire                                     pic_del_c1_clken;
   wire                                     gw_config_c1_clken;

   wire                                     pic_raddr_c1_clk;
   wire                                     pic_data_c1_clk;
   wire                                     pic_pri_c1_clk;
   wire                                     pic_int_c1_clk;
   wire                                     pic_del_c1_clk;
   wire                                     gw_config_c1_clk;
   wire                                     nxt_thr;

   wire                                     mexintpend;
   wire [7:0]                               claimid;
   wire [3:0]                               pl;
   wire                                     mhwakeup;




   assign pic_raddr_c1_clken  = picm_mken | picm_rden | clk_override;
   assign pic_data_c1_clken   = picm_wren | clk_override;
   assign pic_pri_c1_clken    = (waddr_intpriority_base_match & picm_wren_ff)  | (raddr_intpriority_base_match & picm_rden_ff) | clk_override;
   assign pic_int_c1_clken    = (waddr_intenable_base_match   & picm_wren_ff)  | (raddr_intenable_base_match   & picm_rden_ff) | clk_override;
   assign gw_config_c1_clken  = (waddr_config_gw_base_match   & picm_wren_ff)  | (raddr_config_gw_base_match   & picm_rden_ff) | clk_override;

      rvoclkhdr pic_addr_c1_cgc   ( .en(pic_raddr_c1_clken),  .l1clk(pic_raddr_c1_clk), .* );
   rvoclkhdr pic_data_c1_cgc   ( .en(pic_data_c1_clken),   .l1clk(pic_data_c1_clk), .* );
   rvoclkhdr pic_pri_c1_cgc    ( .en(pic_pri_c1_clken),    .l1clk(pic_pri_c1_clk),  .* );
   rvoclkhdr pic_int_c1_cgc    ( .en(pic_int_c1_clken),    .l1clk(pic_int_c1_clk),  .* );
   rvoclkhdr gw_config_c1_cgc  ( .en(gw_config_c1_clken),  .l1clk(gw_config_c1_clk),  .* );


assign raddr_intenable_base_match   = (picm_raddr_ff[31:NUM_LEVELS+2] == INTENABLE_BASE_ADDR[31:NUM_LEVELS+2]) ;
assign raddr_intpriority_base_match = (picm_raddr_ff[31:NUM_LEVELS+2] == INTPRIORITY_BASE_ADDR[31:NUM_LEVELS+2]) ;
assign raddr_config_gw_base_match   = (picm_raddr_ff[31:NUM_LEVELS+2] == EXT_INTR_GW_CONFIG[31:NUM_LEVELS+2]) ;
assign raddr_config_pic_match       = (picm_raddr_ff[31:0]            == EXT_INTR_PIC_CONFIG[31:0]) ;

assign addr_intpend_base_match      = (picm_raddr_ff[31:6]            == INTPEND_BASE_ADDR[31:6]) ;

assign waddr_config_pic_match       = (picm_waddr_ff[31:0]            == EXT_INTR_PIC_CONFIG[31:0]) ;
assign addr_clear_gw_base_match     = (picm_waddr_ff[31:NUM_LEVELS+2] == EXT_INTR_GW_CLEAR[31:NUM_LEVELS+2]) ;
assign waddr_intpriority_base_match = (picm_waddr_ff[31:NUM_LEVELS+2] == INTPRIORITY_BASE_ADDR[31:NUM_LEVELS+2]) ;
assign waddr_intenable_base_match   = (picm_waddr_ff[31:NUM_LEVELS+2] == INTENABLE_BASE_ADDR[31:NUM_LEVELS+2]) ;
assign waddr_config_gw_base_match   = (picm_waddr_ff[31:NUM_LEVELS+2] == EXT_INTR_GW_CONFIG[31:NUM_LEVELS+2]) ;

if (pt.NUM_THREADS > 1 ) begin:  gt_1_thr
   assign pic_del_c1_clken    = (waddr_delg_base_match        & picm_wren_ff)  | (raddr_delg_base_match        & picm_rden_ff) | clk_override;
   rvoclkhdr pic_del_c1_cgc    ( .en(pic_del_c1_clken),    .l1clk(pic_del_c1_clk),  .* );
   assign raddr_delg_base_match        = (picm_raddr_ff[31:NUM_LEVELS+2] == EXT_INTR_DELG_REG[31:NUM_LEVELS+2]) ;
   assign waddr_delg_base_match        = (picm_waddr_ff[31:NUM_LEVELS+2] == EXT_INTR_DELG_REG[31:NUM_LEVELS+2]) ;
   assign addr_intpend_thr_base_match  = (picm_raddr_ff[31:6]            == INTPEND_THR_BASE_ADDR[31:6]) ;
end else begin: one_t
   assign raddr_delg_base_match = 1'b0 ;
   assign waddr_delg_base_match = 1'b0 ;
   assign pic_del_c1_clk = 1'b0  ;
   assign addr_intpend_thr_base_match  = 1'b0;
end

   assign picm_bypass_ff = picm_rden_ff & picm_wren_ff & ( picm_raddr_ff[31:0] == picm_waddr_ff[31:0] );    

rvdff #(32) picm_radd_flop  (.*, .din (picm_rdaddr),        .dout(picm_raddr_ff),         .clk(pic_raddr_c1_clk));
rvdff #(32) picm_wadd_flop  (.*, .din (picm_wraddr),        .dout(picm_waddr_ff),         .clk(pic_data_c1_clk));
rvdff  #(1) picm_wre_flop   (.*, .din (picm_wren),          .dout(picm_wren_ff),          .clk(active_clk));
rvdff  #(1) picm_rde_flop   (.*, .din (picm_rden),          .dout(picm_rden_ff),          .clk(active_clk));
rvdff  #(1) picm_rdt_flop   (.*, .din (picm_rd_thr),        .dout(picm_rd_thr_ff),        .clk(active_clk));
rvdff  #(1) picm_mke_flop   (.*, .din (picm_mken),          .dout(picm_mken_ff),          .clk(active_clk));
rvdff #(32) picm_dat_flop   (.*, .din (picm_wr_data[31:0]), .dout(picm_wr_data_ff[31:0]), .clk(pic_data_c1_clk));



   assign nxt_thr = (pt.NUM_THREADS == 2) & ~curr_int_thr;

   rvdff  #(1) curr_thr      (.*, .din (nxt_thr),          .dout(curr_int_thr),          .clk(free_clk));
   rvdff  #(1) curr_thr_ff   (.*, .din (curr_int_thr),     .dout(curr_int_thr_ff),          .clk(free_clk));

if (pt.PIC_2CYCLE == 1) begin : pic2cyle
   assign curr_int_thr_final_in = curr_int_thr_ff ;
   rvdff  #(1) curr_thr_ff2  (.*, .din (curr_int_thr_ff),  .dout(curr_int_thr_final),          .clk(free_clk));
end else begin: not_pic2cycle
   assign curr_int_thr_final_in = curr_int_thr ;
   assign curr_int_thr_final = curr_int_thr_ff ;
end



rvsyncss  #(pt.PIC_TOTAL_INT_PLUS1-1) sync_inst
(
 .clk (free_clk),
 .dout(extintsrc_req_sync[pt.PIC_TOTAL_INT_PLUS1-1:1]),
 .din (extintsrc_req[pt.PIC_TOTAL_INT_PLUS1-1:1]),
 .*) ;

assign extintsrc_req_sync[0] = extintsrc_req[0];

genvar i ;
for (i=0; i<pt.PIC_TOTAL_INT_PLUS1 ; i++) begin  : SETREG

 if (i > 0 ) begin : NON_ZERO_INT
     assign intpriority_reg_we[i] =  waddr_intpriority_base_match & (picm_waddr_ff[NUM_LEVELS+1:2] == i) & picm_wren_ff;
     assign intpriority_reg_re[i] =  raddr_intpriority_base_match & (picm_raddr_ff[NUM_LEVELS+1:2] == i) & picm_rden_ff;

     assign intenable_reg_we[i]   =  waddr_intenable_base_match   & (picm_waddr_ff[NUM_LEVELS+1:2] == i) & picm_wren_ff;
     assign intenable_reg_re[i]   =  raddr_intenable_base_match   & (picm_raddr_ff[NUM_LEVELS+1:2] == i) & picm_rden_ff;

     if (pt.NUM_THREADS > 1 ) begin:   gt_1_thr
          assign delg_reg_we[i]   =  waddr_delg_base_match   & (picm_waddr_ff[NUM_LEVELS+1:2] == i) & picm_wren_ff;
          assign delg_reg_re[i]   =  raddr_delg_base_match   & (picm_raddr_ff[NUM_LEVELS+1:2] == i) & picm_rden_ff;
          rvdffs #(1)                 delg_ff        (.*, .en( delg_reg_we[i]),        .din (picm_wr_data_ff[0]),                    .dout(delg_reg[i]),        .clk(pic_del_c1_clk));
     end else begin: one_t
          assign delg_reg_re[i] = 1'b0 ;
          assign delg_reg_we[i] = 1'b0 ;
          assign delg_reg[i]    = 1'b0;
     end


     assign gw_config_reg_we[i]   =  waddr_config_gw_base_match   & (picm_waddr_ff[NUM_LEVELS+1:2] == i) & picm_wren_ff;
     assign gw_config_reg_re[i]   =  raddr_config_gw_base_match   & (picm_raddr_ff[NUM_LEVELS+1:2] == i) & picm_rden_ff;

     assign gw_clear_reg_we[i]    =  addr_clear_gw_base_match     & (picm_waddr_ff[NUM_LEVELS+1:2] == i) & picm_wren_ff ;

     rvdffs #(INTPRIORITY_BITS) intpriority_ff  (.*, .en( intpriority_reg_we[i]), .din (picm_wr_data_ff[INTPRIORITY_BITS-1:0]), .dout(intpriority_reg[i]), .clk(pic_pri_c1_clk));
     rvdffs #(1)                 intenable_ff   (.*, .en( intenable_reg_we[i]),   .din (picm_wr_data_ff[0]),                    .dout(intenable_reg[i]),   .clk(pic_int_c1_clk));


        rvdffs #(2)                 gw_config_ff   (.*, .en( gw_config_reg_we[i]),   .din (picm_wr_data_ff[1:0]),                  .dout(gw_config_reg[i]),   .clk(gw_config_c1_clk));
        eh2_configurable_gw config_gw_inst(.*, .clk(free_clk),
                         .extintsrc_req_sync(extintsrc_req_sync[i]) ,
                         .meigwctrl_polarity(gw_config_reg[i][0]) ,
                         .meigwctrl_type(gw_config_reg[i][1]) ,
                         .meigwclr(gw_clear_reg_we[i]) ,
                         .extintsrc_req_config(extintsrc_req_gw[i])
                            );


 end else begin : INT_ZERO
     assign intpriority_reg_we[i] =  1'b0 ;
     assign intpriority_reg_re[i] =  1'b0 ;
     assign intenable_reg_we[i]   =  1'b0 ;
     assign intenable_reg_re[i]   =  1'b0 ;
     assign delg_reg_re[i]        =  1'b0 ;
     assign delg_reg_we[i]        =  1'b0 ;
     assign gw_config_reg_we[i]   =  1'b0 ;
     assign gw_config_reg_re[i]   =  1'b0 ;
     assign gw_clear_reg_we[i]    =  1'b0 ;

     assign gw_config_reg[i]    = 'd0 ;

     assign intpriority_reg[i] = {INTPRIORITY_BITS{1'b0}} ;
     assign intenable_reg[i]   = 1'b0 ;
     assign delg_reg[i]        = 1'b0 ;
     assign extintsrc_req_gw[i] = 1'b0 ;
 end


    assign intpriority_reg_inv[i] =  intpriord ? ~intpriority_reg[i] : intpriority_reg[i] ;
    assign delg_thr_match[i]      =  (delg_reg[i] &  curr_int_thr) |   (~delg_reg[i] & ~curr_int_thr) ;

    assign intpend_w_prior_en[i]  =  {INTPRIORITY_BITS{(extintsrc_req_gw[i] & intenable_reg[i] & delg_thr_match[i])}} & intpriority_reg_inv[i] ;
    assign intpend_id[i]          =  i ;
end


        assign pl_in[INTPRIORITY_BITS-1:0]                  =      selected_int_priority[INTPRIORITY_BITS-1:0] ;


 genvar l, m , j, k;

if (pt.PIC_2CYCLE == 1) begin : genblock

        wire [NUM_LEVELS/2:0] [pt.PIC_TOTAL_INT_PLUS1+2:0] [INTPRIORITY_BITS-1:0] level_intpend_w_prior_en;
        wire [NUM_LEVELS/2:0] [pt.PIC_TOTAL_INT_PLUS1+2:0] [ID_BITS-1:0]          level_intpend_id;

        assign level_intpend_w_prior_en[0][pt.PIC_TOTAL_INT_PLUS1+2:0] = {4'b0,4'b0,4'b0,intpend_w_prior_en[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;
        assign level_intpend_id[0][pt.PIC_TOTAL_INT_PLUS1+2:0]         = {8'b0,8'b0,8'b0,intpend_id[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;

        assign levelx_intpend_w_prior_en[NUM_LEVELS/2][(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2))+1:0] = {{1*INTPRIORITY_BITS{1'b0}},l2_intpend_w_prior_en_ff[(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2)):0]} ;
        assign levelx_intpend_id[NUM_LEVELS/2][(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2))+1:0]         = {{1*ID_BITS{1'b1}},l2_intpend_id_ff[(pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2)):0]} ;
 for (l=0; l<NUM_LEVELS/2 ; l++) begin : TOP_LEVEL
    for (m=0; m<=(pt.PIC_TOTAL_INT_PLUS1)/(2**(l+1)) ; m++) begin : COMPARE
       if ( m == (pt.PIC_TOTAL_INT_PLUS1)/(2**(l+1))) begin
            assign level_intpend_w_prior_en[l+1][m+1] = 'd0 ;
            assign level_intpend_id[l+1][m+1]         = 'd0 ;
       end
       eh2_cmp_and_mux  #(.ID_BITS(ID_BITS),
                      .INTPRIORITY_BITS(INTPRIORITY_BITS)) cmp_l1 (
                      .a_id(level_intpend_id[l][2*m]),
                      .a_priority(level_intpend_w_prior_en[l][2*m]),
                      .b_id(level_intpend_id[l][2*m+1]),
                      .b_priority(level_intpend_w_prior_en[l][2*m+1]),
                      .out_id(level_intpend_id[l+1][m]),
                      .out_priority(level_intpend_w_prior_en[l+1][m])) ;

    end
 end

        for (i=0; i<=pt.PIC_TOTAL_INT_PLUS1/2**(NUM_LEVELS/2) ; i++) begin : MIDDLE_FLOPS
          rvdff #(INTPRIORITY_BITS) level2_intpend_prior_reg  (.*, .din (level_intpend_w_prior_en[NUM_LEVELS/2][i]), .dout(l2_intpend_w_prior_en_ff[i]),  .clk(free_clk));
          rvdff #(ID_BITS)          level2_intpend_id_reg     (.*, .din (level_intpend_id[NUM_LEVELS/2][i]),         .dout(l2_intpend_id_ff[i]),          .clk(free_clk));
        end

 for (j=NUM_LEVELS/2; j<NUM_LEVELS ; j++) begin : BOT_LEVELS
    for (k=0; k<=(pt.PIC_TOTAL_INT_PLUS1)/(2**(j+1)) ; k++) begin : COMPARE
       if ( k == (pt.PIC_TOTAL_INT_PLUS1)/(2**(j+1))) begin
            assign levelx_intpend_w_prior_en[j+1][k+1] = 'd0 ;
            assign levelx_intpend_id[j+1][k+1]         = 'd0 ;
       end
            eh2_cmp_and_mux  #(.ID_BITS(ID_BITS),
                        .INTPRIORITY_BITS(INTPRIORITY_BITS))
                 cmp_l1 (
                        .a_id(levelx_intpend_id[j][2*k]),
                        .a_priority(levelx_intpend_w_prior_en[j][2*k]),
                        .b_id(levelx_intpend_id[j][2*k+1]),
                        .b_priority(levelx_intpend_w_prior_en[j][2*k+1]),
                        .out_id(levelx_intpend_id[j+1][k]),
                        .out_priority(levelx_intpend_w_prior_en[j+1][k])) ;
    end
  end
        assign claimid_in[ID_BITS-1:0]                      =      levelx_intpend_id[NUM_LEVELS][0] ;           assign selected_int_priority[INTPRIORITY_BITS-1:0]  =      levelx_intpend_w_prior_en[NUM_LEVELS][0] ;
end
else begin : genblock

        wire [NUM_LEVELS:0] [pt.PIC_TOTAL_INT_PLUS1+1:0] [INTPRIORITY_BITS-1:0] level_intpend_w_prior_en;
        wire [NUM_LEVELS:0] [pt.PIC_TOTAL_INT_PLUS1+1:0] [ID_BITS-1:0]          level_intpend_id;

        assign level_intpend_w_prior_en[0][pt.PIC_TOTAL_INT_PLUS1+1:0] = {{2*INTPRIORITY_BITS{1'b0}},intpend_w_prior_en[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;
        assign level_intpend_id[0][pt.PIC_TOTAL_INT_PLUS1+1:0] = {{2*ID_BITS{1'b1}},intpend_id[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;

 for (l=0; l<NUM_LEVELS ; l++) begin : LEVEL
    for (m=0; m<=(pt.PIC_TOTAL_INT_PLUS1)/(2**(l+1)) ; m++) begin : COMPARE
       if ( m == (pt.PIC_TOTAL_INT_PLUS1)/(2**(l+1))) begin
            assign level_intpend_w_prior_en[l+1][m+1] = 'd0 ;
            assign level_intpend_id[l+1][m+1]         = 'd0 ;
       end
       eh2_cmp_and_mux  #(.ID_BITS(ID_BITS),
                      .INTPRIORITY_BITS(INTPRIORITY_BITS)) cmp_l1 (
                      .a_id(level_intpend_id[l][2*m]),
                      .a_priority(level_intpend_w_prior_en[l][2*m]),
                      .b_id(level_intpend_id[l][2*m+1]),
                      .b_priority(level_intpend_w_prior_en[l][2*m+1]),
                      .out_id(level_intpend_id[l+1][m]),
                      .out_priority(level_intpend_w_prior_en[l+1][m])) ;

    end
 end
        assign claimid_in[ID_BITS-1:0]                      =      level_intpend_id[NUM_LEVELS][0] ;           assign selected_int_priority[INTPRIORITY_BITS-1:0]  =      level_intpend_w_prior_en[NUM_LEVELS][0] ;

end

assign config_reg_we               =  waddr_config_pic_match & picm_wren_ff;
assign config_reg_re               =  raddr_config_pic_match & picm_rden_ff;

assign config_reg_in  =  picm_wr_data_ff[0] ;   rvdffs #(1) config_reg_ff  (.*, .clk(free_clk), .en(config_reg_we), .din (config_reg_in), .dout(config_reg));

assign intpriord  = config_reg ;


assign pl_in_q[INTPRIORITY_BITS-1:0] = intpriord ? ~pl_in : pl_in ;
rvdff #(ID_BITS)          claimid_fl  (.*,  .din (claimid_in[ID_BITS-1:00]),     .dout(claimid[ID_BITS-1:00]),    .clk(free_clk));
rvdff  #(INTPRIORITY_BITS) pl_fl      (.*, .din (pl_in_q[INTPRIORITY_BITS-1:0]), .dout(pl[INTPRIORITY_BITS-1:0]), .clk(free_clk));

if (pt.NUM_THREADS > 1 ) begin:   more_than_1_thr
  rvdff #(ID_BITS)          claimid_ff_f2  (.*,  .din (claimid[ID_BITS-1:00]),     .dout(claimid_ff[ID_BITS-1:00]),    .clk(free_clk));
  rvdff  #(INTPRIORITY_BITS) pl_ff_f2      (.*, .din (pl[INTPRIORITY_BITS-1:0]), .dout(pl_ff[INTPRIORITY_BITS-1:0]), .clk(free_clk));
  rvdff #(1) mexintpend_ff_f2  (.*, .clk(free_clk), .din (mexintpend), .dout(mexintpend_ff));
  rvdff #(1) wake_up_ff_f2     (.*, .clk(free_clk), .din (mhwakeup), .dout(mhwakeup_ff));
  assign claimid_out[0]  =  curr_int_thr_final ?  claimid_ff : claimid ;
  assign claimid_out[1]  = ~curr_int_thr_final ?  claimid_ff : claimid ;

  assign  pl_out[0]      =  curr_int_thr_final ?  pl_ff : pl ;
  assign  pl_out[1]      = ~curr_int_thr_final ?  pl_ff : pl ;

  assign  mexintpend_out[0]      =  curr_int_thr_final ?  mexintpend_ff : mexintpend ;
  assign  mexintpend_out[1]      = ~curr_int_thr_final ?  mexintpend_ff : mexintpend ;

  assign mhwakeup_out[0] =    curr_int_thr_final ?   mhwakeup_ff : mhwakeup ;
  assign mhwakeup_out[1] =   ~curr_int_thr_final ?   mhwakeup_ff : mhwakeup ;

  assign meipt    =  curr_int_thr_final_in ? dec_tlu_meipt[1]    : dec_tlu_meipt[0] ;
  assign meicurpl =  curr_int_thr_final_in ? dec_tlu_meicurpl[1] : dec_tlu_meicurpl[0] ;
end else begin : one_thread
  assign claimid_out[pt.NUM_THREADS-1:0] = {pt.NUM_THREADS{claimid}} ;
  assign pl_out[pt.NUM_THREADS-1:0]      = {pt.NUM_THREADS{pl}} ;
  assign mexintpend_out[pt.NUM_THREADS-1:0] = {pt.NUM_THREADS{mexintpend}} ;
  assign mhwakeup_out[pt.NUM_THREADS-1:0] = {pt.NUM_THREADS{mhwakeup}} ;

  assign meipt    =  dec_tlu_meipt[0] ;
  assign meicurpl =  dec_tlu_meicurpl[0] ;
end

assign meipt_inv[INTPRIORITY_BITS-1:0]    = intpriord ? ~meipt[INTPRIORITY_BITS-1:0]    : meipt[INTPRIORITY_BITS-1:0] ;
assign meicurpl_inv[INTPRIORITY_BITS-1:0] = intpriord ? ~meicurpl[INTPRIORITY_BITS-1:0] : meicurpl[INTPRIORITY_BITS-1:0] ;
assign mexintpend_in = (( selected_int_priority[INTPRIORITY_BITS-1:0] > meipt_inv[INTPRIORITY_BITS-1:0]) &
                        ( selected_int_priority[INTPRIORITY_BITS-1:0] > meicurpl_inv[INTPRIORITY_BITS-1:0]) );
rvdff #(1) mexintpend_fl  (.*, .clk(free_clk), .din (mexintpend_in), .dout(mexintpend));

assign maxint[INTPRIORITY_BITS-1:0]      =  intpriord ? 0 : 15 ;
assign mhwakeup_in = ( pl_in_q[INTPRIORITY_BITS-1:0] == maxint) ;
rvdff #(1) wake_up_ff  (.*, .clk(free_clk), .din (mhwakeup_in), .dout(mhwakeup));




assign intpend_reg_read     =  addr_intpend_base_match      & picm_rden_ff ;
assign intpend_thr_reg_read =  addr_intpend_thr_base_match  & picm_rden_ff ;
assign intpriority_reg_read =  raddr_intpriority_base_match & picm_rden_ff;
assign intenable_reg_read   =  raddr_intenable_base_match   & picm_rden_ff;
assign delg_reg_read        =  raddr_delg_base_match        & picm_rden_ff;
assign gw_config_reg_read   =  raddr_config_gw_base_match   & picm_rden_ff;

assign thr_mx_intpend_reg[pt.PIC_TOTAL_INT_PLUS1-1:0]   = picm_rd_thr_ff ? {(extintsrc_req_gw[pt.PIC_TOTAL_INT_PLUS1-1:0] &  delg_reg[pt.PIC_TOTAL_INT_PLUS1-1:0]) } :
                                                                           {(extintsrc_req_gw[pt.PIC_TOTAL_INT_PLUS1-1:0] & ~delg_reg[pt.PIC_TOTAL_INT_PLUS1-1:0]) } ;

assign intpend_reg_extended[INTPEND_SIZE-1:0]       = {{INTPEND_SIZE-pt.PIC_TOTAL_INT_PLUS1{1'b0}},extintsrc_req_gw[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;
assign thr_mx_intpend_reg_extended[INTPEND_SIZE-1:0]= {{INTPEND_SIZE-pt.PIC_TOTAL_INT_PLUS1{1'b0}},thr_mx_intpend_reg[pt.PIC_TOTAL_INT_PLUS1-1:0]} ;

   for (i=0; i<(INT_GRPS); i++) begin
            assign intpend_rd_part_out[i]     =  (({32{intpend_reg_read     &  (picm_raddr_ff[5:2] == i)}}) & intpend_reg_extended[((32*i)+31):(32*i)]) ;
            assign intpend_thr_rd_part_out[i] =  (({32{intpend_thr_reg_read &  (picm_raddr_ff[5:2] == i)}}) & thr_mx_intpend_reg_extended[((32*i)+31):(32*i)]) ;
   end

   always @* begin : INTPEND_RD
         intpend_rd_out =  'd0 ;
         intpend_thr_rd_out =  'd0 ;
         for (int i=0; i<INT_GRPS; i++) begin
               intpend_rd_out     |=  intpend_rd_part_out[i] ;
               intpend_thr_rd_out |=  intpend_thr_rd_part_out[i] ;
         end
   end

   always @* begin : INTEN_RD
         intenable_rd_out =  'd0 ;
         delg_rd_out =  'd0 ;
         intpriority_rd_out =  'd0 ;
         gw_config_rd_out =  'd0 ;
         for (int i=0; i<pt.PIC_TOTAL_INT_PLUS1; i++) begin
              if (intenable_reg_re[i]) begin
               intenable_rd_out    =  intenable_reg[i]  ;
              end
              if (delg_reg_re[i]) begin
               delg_rd_out    =  delg_reg[i]  ;
              end
              if (intpriority_reg_re[i]) begin
               intpriority_rd_out  =  intpriority_reg[i] ;
              end
              if (gw_config_reg_re[i]) begin
               gw_config_rd_out  =  gw_config_reg[i] ;
              end
         end
   end


 assign picm_rd_data_in[31:0] = ({32{intpend_reg_read      }} &   intpend_rd_out                                                    ) |
                                ({32{intpend_thr_reg_read  }} &   intpend_thr_rd_out                                                ) |
                                ({32{intpriority_reg_read  }} &  {{32-INTPRIORITY_BITS{1'b0}}, intpriority_rd_out                 } ) |
                                ({32{intenable_reg_read    }} &  {31'b0 , intenable_rd_out                                        } ) |
                                ({32{delg_reg_read         }} &  {31'b0 , delg_rd_out                                             } ) |
                                ({32{gw_config_reg_read    }} &  {30'b0 , gw_config_rd_out                                        } ) |
                                ({32{config_reg_re         }} &  {31'b0 , config_reg                                              } ) |
                                ({32{picm_mken_ff & mask[3]}} &  {30'b0 , 2'b11                                                   } ) |
                                ({32{picm_mken_ff & mask[2]}} &  {31'b0 , 1'b1                                                    } ) |
                                ({32{picm_mken_ff & mask[1]}} &  {28'b0 , 4'b1111                                                 } ) |
                                ({32{picm_mken_ff & mask[0]}} &   32'b0                                                             ) ;


assign picm_rd_data[31:0] = picm_bypass_ff ? picm_wr_data_ff[31:0] : picm_rd_data_in[31:0] ;

wire [14:0] address;

assign address[14:0] = picm_raddr_ff[14:0];

`include "pic_map_auto.h"

endmodule


module eh2_cmp_and_mux #(parameter ID_BITS=8,
                               INTPRIORITY_BITS = 4)
                    (
                        input wire [ID_BITS-1:0]       a_id,
                        input wire [INTPRIORITY_BITS-1:0] a_priority,

                        input wire [ID_BITS-1:0]       b_id,
                        input wire [INTPRIORITY_BITS-1:0] b_priority,

                        output logic [ID_BITS-1:0]       out_id,
                        output logic [INTPRIORITY_BITS-1:0] out_priority

                    );

wire   a_is_lt_b ;

assign  a_is_lt_b  = ( a_priority[INTPRIORITY_BITS-1:0] < b_priority[INTPRIORITY_BITS-1:0] ) ;

assign  out_id[ID_BITS-1:0]                = a_is_lt_b ? b_id[ID_BITS-1:0] :
                                                         a_id[ID_BITS-1:0] ;
assign  out_priority[INTPRIORITY_BITS-1:0] = a_is_lt_b ? b_priority[INTPRIORITY_BITS-1:0] :
                                                         a_priority[INTPRIORITY_BITS-1:0] ;
endmodule 

module eh2_configurable_gw (
                             input wire clk,
                             input wire rst_l,

                             input wire extintsrc_req_sync ,
                             input wire meigwctrl_polarity ,
                             input wire meigwctrl_type ,
                             input wire meigwclr ,

                             output logic extintsrc_req_config
                            );


wire gw_int_pending_in;
wire gw_int_pending;

  assign gw_int_pending_in =  (extintsrc_req_sync ^ meigwctrl_polarity) | (gw_int_pending & ~meigwclr) ;
  rvdff #(1) int_pend_ff        (.*, .clk(clk), .din (gw_int_pending_in),     .dout(gw_int_pending));

  assign extintsrc_req_config =  meigwctrl_type ? ((extintsrc_req_sync ^  meigwctrl_polarity) | gw_int_pending) : (extintsrc_req_sync ^  meigwctrl_polarity) ;

endmodule 








