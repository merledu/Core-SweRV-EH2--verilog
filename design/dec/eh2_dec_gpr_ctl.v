
module eh2_dec_gpr_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )  (
    input wire tid,

    input wire [4:0] raddr0,      input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] raddr3,

    input wire rtid0,       input wire rtid1,
    input wire rtid2,
    input wire rtid3,

    input wire rden0,       input wire rden1,
    input wire rden2,
    input wire rden3,

    input wire [4:0] waddr0,      input wire [4:0] waddr1,
    input wire [4:0] waddr2,
    input wire [4:0] waddr3,

    input wire wtid0,              input wire wtid1,
    input wire wtid2,
    input wire wtid3,

    input wire wen0,              input wire wen1,
    input wire wen2,
    input wire wen3,

    input wire [31:0] wd0,        input wire [31:0] wd1,
    input wire [31:0] wd2,
    input wire [31:0] wd3,

    input wire clk,
    input wire rst_l,

    output logic [31:0] rd0,      output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] rd3,

    input wire scan_mode
);

   reg [31:1] [31:0] gpr_out;        reg [31:1] [31:0] gpr_in;
reg [31:1] w0v;
reg [31:1] w1v;
reg [31:1] w2v;
reg [31:1] w3v;
   wire [31:1] gpr_wr_en;

      assign gpr_wr_en[31:1] = (w0v[31:1] | w1v[31:1] | w2v[31:1] | w3v[31:1]);
   for ( genvar j=1; j<32; j++ )  begin : gpr
            rvdffe #(32) gprff (.*, .en(gpr_wr_en[j]), .din(gpr_in[j][31:0]), .dout(gpr_out[j][31:0]));
 
   end : gpr

   always @* begin
      rd0[31:0] = 32'b0;
      rd1[31:0] = 32'b0;
      rd2[31:0] = 32'b0;
      rd3[31:0] = 32'b0;
      w0v[31:1] = 31'b0;
      w1v[31:1] = 31'b0;
      w2v[31:1] = 31'b0;
      w3v[31:1] = 31'b0;
      gpr_in[31:1] = '0;

            for (int j=1; j<32; j++ )  begin
         rd0[31:0] |= ({32{rden0 & (rtid0 == tid) & (raddr0[4:0]== 5'(j))}} & gpr_out[j][31:0]);
         rd1[31:0] |= ({32{rden1 & (rtid1 == tid) & (raddr1[4:0]== 5'(j))}} & gpr_out[j][31:0]);
         rd2[31:0] |= ({32{rden2 & (rtid2 == tid) & (raddr2[4:0]== 5'(j))}} & gpr_out[j][31:0]);
         rd3[31:0] |= ({32{rden3 & (rtid3 == tid) & (raddr3[4:0]== 5'(j))}} & gpr_out[j][31:0]);
     end

          for (int j=1; j<32; j++ )  begin
         w0v[j]     = wen0  & (wtid0 == tid) & (waddr0[4:0]== 5'(j) );
         w1v[j]     = wen1  & (wtid1 == tid) & (waddr1[4:0]== 5'(j) );
         w2v[j]     = wen2  & (wtid2 == tid) & (waddr2[4:0]== 5'(j) );
         w3v[j]     = wen3  & (wtid3 == tid) & (waddr3[4:0]== 5'(j) );
         gpr_in[j]  = ({32{w0v[j]}} & wd0[31:0]) |
                      ({32{w1v[j]}} & wd1[31:0]) |
                      ({32{w2v[j]}} & wd2[31:0]) |
                      ({32{w3v[j]}} & wd3[31:0]);
     end
   end 
`ifdef ASSERT_ON

   wire write_collision_unused;

   assign write_collision_unused = ( (w0v[31:1] == w1v[31:1]) & wen0 & wen1 & (wtid0==tid) & (wtid1==tid) ) |
                                   ( (w0v[31:1] == w2v[31:1]) & wen0 & wen2 & (wtid0==tid) & (wtid2==tid) ) |
                                   ( (w0v[31:1] == w3v[31:1]) & wen0 & wen3 & (wtid0==tid) & (wtid3==tid) ) |
                                   ( (w1v[31:1] == w2v[31:1]) & wen1 & wen2 & (wtid1==tid) & (wtid2==tid) ) |
                                   ( (w1v[31:1] == w3v[31:1]) & wen1 & wen3 & (wtid1==tid) & (wtid3==tid) ) |
                                   ( (w2v[31:1] == w3v[31:1]) & wen2 & wen3 & (wtid2==tid) & (wtid3==tid ));


`endif

endmodule
