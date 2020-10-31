
module eh2_lsu_amo
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(

   input eh2_lsu_pkt_t     lsu_pkt_dc3,                    input wire [31:0]  i0_result_e4_eff,
   input wire [31:0]  i1_result_e4_eff,
   input wire addr_in_pic_dc3,
   input wire [31:0]  picm_mask_data_dc3,
   input wire [31:0]  store_data_pre_dc3,
   input wire [31:0]  lsu_dccm_data_corr_dc3,              
   output logic [31:0]  store_data_dc3,                 output logic [31:0]  amo_data_dc3                 
);


   wire               amo_sc_dc3;


   wire         amo_add_dc3;
   wire         amo_max_dc3;
   wire         amo_maxu_dc3;
   wire         amo_min_dc3;
   wire         amo_minu_dc3;
   wire         amo_minmax_sel_dc3;
   wire [31:0]  amo_minmax_dc3;
   wire         amo_xor_dc3;
   wire         amo_or_dc3;
   wire         amo_and_dc3;
   wire         amo_swap_dc3;

   wire         wire_sel;
   wire [31:0]  wireal_out;
   wire [31:0]  sum_out;

   wire [31:0]  store_datafn_dc3;

         
      assign amo_sc_dc3     = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd3);

   assign amo_add_dc3    = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd0);
   assign amo_max_dc3    = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd20);
   assign amo_maxu_dc3   = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd28);
   assign amo_min_dc3    = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd16);
   assign amo_minu_dc3   = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd24);
   assign amo_xor_dc3    = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd4);
   assign amo_or_dc3     = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd8);
   assign amo_and_dc3    = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd12);
   assign amo_swap_dc3   = lsu_pkt_dc3.valid & lsu_pkt_dc3.atomic & (lsu_pkt_dc3.atomic_instr[4:0] == 5'd1);

   assign amo_minmax_sel_dc3 =  amo_max_dc3 | amo_maxu_dc3 | amo_min_dc3 | amo_minu_dc3;
   assign logic_sel          =  amo_and_dc3 | amo_or_dc3   | amo_xor_dc3;

   assign store_data_dc3[31:0] = (picm_mask_data_dc3[31:0] | {32{~addr_in_pic_dc3}}) &
                                 ((lsu_pkt_dc3.store_data_bypass_e4_c3[1]) ? i1_result_e4_eff[31:0] :
                                  (lsu_pkt_dc3.store_data_bypass_e4_c3[0]) ? i0_result_e4_eff[31:0] : store_data_pre_dc3[31:0]);


      assign logical_out[31:0] =  ( {32{amo_and_dc3}} & (lsu_dccm_data_corr_dc3[31:0] & store_data_dc3[31:0]) ) |
                               ( {32{amo_or_dc3}}  & (lsu_dccm_data_corr_dc3[31:0] | store_data_dc3[31:0]) ) |
                               ( {32{amo_xor_dc3}} & (lsu_dccm_data_corr_dc3[31:0] ^ store_data_dc3[31:0]) );
   
   wire         lsu_result_lt_storedata;
   wire         cout;


      assign store_datafn_dc3[31:0]  =  amo_add_dc3 ? store_data_dc3[31:0] : ~store_data_dc3[31:0];
   assign {cout, sum_out[31:0]}   = {1'b0, lsu_dccm_data_corr_dc3[31:0]} + {1'b0, store_datafn_dc3[31:0]} + {32'b0, ~amo_add_dc3};


      assign lsu_result_lt_storedata = (~cout & (lsu_pkt_dc3.unsign | ~(lsu_dccm_data_corr_dc3[31] ^ store_data_dc3[31]))) |                                        (lsu_dccm_data_corr_dc3[31] & ~store_data_dc3[31] & ~lsu_pkt_dc3.unsign);

   assign amo_minmax_dc3[31:0]    = ({32{(amo_max_dc3 | amo_maxu_dc3) &  lsu_result_lt_storedata}}  & store_data_dc3[31:0]        ) |                                      ({32{(amo_max_dc3 | amo_maxu_dc3) & ~lsu_result_lt_storedata}}  & lsu_dccm_data_corr_dc3[31:0]) |                                      ({32{(amo_min_dc3 | amo_minu_dc3) & ~lsu_result_lt_storedata}}  & store_data_dc3[31:0]        ) |                                      ({32{(amo_min_dc3 | amo_minu_dc3) &  lsu_result_lt_storedata}}  & lsu_dccm_data_corr_dc3[31:0]);   

     assign amo_data_dc3[31:0]      = ({32{logic_sel}}                 & logical_out[31:0])    |                                      ({32{amo_add_dc3}}               & sum_out[31:0])        |                                      ({32{amo_minmax_sel_dc3}}        & amo_minmax_dc3[31:0]) |                                      ({32{amo_swap_dc3 | amo_sc_dc3}} & store_data_dc3[31:0]);   
endmodule 