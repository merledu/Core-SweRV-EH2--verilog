
module eh2_dec_trigger
import eh2_pkg::*;
#(
`include "eh2_param.vh"
) (

   input eh2_trigger_pkt_t [pt.NUM_THREADS-1:0] [3:0] trigger_pkt_any,              input wire [31:1]                                   dec_i0_pc_d,                       input wire [31:1]                                   dec_i1_pc_d,                       input eh2_alu_pkt_t                                 i0_ap,                             input eh2_alu_pkt_t                                 i1_ap,                          
   output [3:0] dec_i0_trigger_match_d,
   output [3:0] dec_i1_trigger_match_d
);

   wire [3:0][31:0]  dec_i0_match_data;
   reg [3:0]        dec_i0_trigger_data_match;
   wire [3:0][31:0]  dec_i1_match_data;
   reg [3:0]        dec_i1_trigger_data_match;

   for (genvar i=0; i<4; i++) begin
      assign dec_i0_match_data[i][31:0] = ({32{~trigger_pkt_any[i0_ap.tid][i].select & trigger_pkt_any[i0_ap.tid][i].execute}} & {dec_i0_pc_d[31:1], trigger_pkt_any[i0_ap.tid][i].tdata2[0]}); 
      assign dec_i1_match_data[i][31:0] = ({32{~trigger_pkt_any[i1_ap.tid][i].select & trigger_pkt_any[i1_ap.tid][i].execute}} & {dec_i1_pc_d[31:1], trigger_pkt_any[i1_ap.tid][i].tdata2[0]} );
     rvmaskandmatch trigger_i0_match (.mask(trigger_pkt_any[i0_ap.tid][i].tdata2[31:0]), .data(dec_i0_match_data[i][31:0]), .masken(trigger_pkt_any[i0_ap.tid][i].match), .match(dec_i0_trigger_data_match[i]));
      rvmaskandmatch trigger_i1_match (.mask(trigger_pkt_any[i1_ap.tid][i].tdata2[31:0]), .data(dec_i1_match_data[i][31:0]), .masken(trigger_pkt_any[i1_ap.tid][i].match), .match(dec_i1_trigger_data_match[i]));

      assign dec_i0_trigger_match_d[i] = trigger_pkt_any[i0_ap.tid][i].execute & trigger_pkt_any[i0_ap.tid][i].m & dec_i0_trigger_data_match[i];
      assign dec_i1_trigger_match_d[i] = trigger_pkt_any[i1_ap.tid][i].execute & trigger_pkt_any[i1_ap.tid][i].m & dec_i1_trigger_data_match[i];
   end

endmodule 
