

module eh2_exu_mul_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input wire clk,                 input wire active_clk,          input wire clk_override,        input wire rst_l,               input wire scan_mode,        
   input wire [31:0]   a,                   input wire [31:0]   b,                
   input wire [31:0]   lsu_result_dc3,   
   input eh2_mul_pkt_t mp,               

   output logic [31:0]  out               
   );


reg valid_e1;
reg valid_e2;
wire mul_c1_e1_clken;
wire mul_c1_e2_clken;
wire mul_c1_e3_clken;
reg exu_mul_c1_e1_clk;
reg exu_mul_c1_e2_clk;
reg exu_mul_c1_e3_clk;

reg [31:0] a_ff_e1;
wire [31:0] a_e1;
reg [31:0] b_ff_e1;
wire [31:0] b_e1;
reg load_mul_rs1_bypass_e1;
reg load_mul_rs2_bypass_e1;
reg rs1_sign_e1;
wire rs1_neg_e1;
reg rs2_sign_e1;
wire rs2_neg_e1;
reg signed [32:0];
reg a_ff_e2 [32:0];
reg b_ff_e2 [32:0];
   reg        [63:0]  prod_e3;
reg low_e1;
reg low_e2;
reg low_e3;


   
      assign mul_c1_e1_clken        = (mp.valid | clk_override);
   assign mul_c1_e2_clken        = (valid_e1 | clk_override);
   assign mul_c1_e3_clken        = (valid_e2 | clk_override);

   // C1 - 1 clock pulse for data
   rvoclkhdr exu_mul_c1e1_cgc    (.*, .en(mul_c1_e1_clken),   .l1clk(exu_mul_c1_e1_clk));
   rvoclkhdr exu_mul_c1e2_cgc    (.*, .en(mul_c1_e2_clken),   .l1clk(exu_mul_c1_e2_clk));
   rvoclkhdr exu_mul_c1e3_cgc    (.*, .en(mul_c1_e3_clken),   .l1clk(exu_mul_c1_e3_clk));


   // --------------------------- Input flops    ----------------------------------

   rvdff  #(1)  valid_e1_ff      (.*, .din(mp.valid),                  .dout(valid_e1),               .clk(active_clk));
   rvdff  #(1)  rs1_sign_e1_ff   (.*, .din(mp.rs1_sign),               .dout(rs1_sign_e1),            .clk(exu_mul_c1_e1_clk));
   rvdff  #(1)  rs2_sign_e1_ff   (.*, .din(mp.rs2_sign),               .dout(rs2_sign_e1),            .clk(exu_mul_c1_e1_clk));
   rvdff  #(1)  low_e1_ff        (.*, .din(mp.low),                    .dout(low_e1),                 .clk(exu_mul_c1_e1_clk));
   rvdff  #(1)  ld_rs1_byp_e1_ff (.*, .din(mp.load_mul_rs1_bypass_e1), .dout(load_mul_rs1_bypass_e1), .clk(exu_mul_c1_e1_clk));
   rvdff  #(1)  ld_rs2_byp_e1_ff (.*, .din(mp.load_mul_rs2_bypass_e1), .dout(load_mul_rs2_bypass_e1), .clk(exu_mul_c1_e1_clk));

   rvdff  #(32) a_e1_ff          (.*, .din(a[31:0]),                   .dout(a_ff_e1[31:0]),          .clk(exu_mul_c1_e1_clk));
   rvdff  #(32) b_e1_ff          (.*, .din(b[31:0]),                   .dout(b_ff_e1[31:0]),          .clk(exu_mul_c1_e1_clk));



   
   assign a_e1[31:0]             = (load_mul_rs1_bypass_e1)  ?  lsu_result_dc3[31:0]  :  a_ff_e1[31:0];
   assign b_e1[31:0]             = (load_mul_rs2_bypass_e1)  ?  lsu_result_dc3[31:0]  :  b_ff_e1[31:0];

   assign rs1_neg_e1             =  rs1_sign_e1 & a_e1[31];
   assign rs2_neg_e1             =  rs2_sign_e1 & b_e1[31];

   rvdff  #(1)  valid_e2_ff      (.*, .din(valid_e1),                  .dout(valid_e2),               .clk(active_clk));
   rvdff  #(1)  low_e2_ff        (.*, .din(low_e1),                    .dout(low_e2),                 .clk(exu_mul_c1_e2_clk));

   rvdff  #(33) a_e2_ff          (.*, .din({rs1_neg_e1, a_e1[31:0]}),  .dout(a_ff_e2[32:0]),          .clk(exu_mul_c1_e2_clk));
   rvdff  #(33) b_e2_ff          (.*, .din({rs2_neg_e1, b_e1[31:0]}),  .dout(b_ff_e2[32:0]),          .clk(exu_mul_c1_e2_clk));




   
   reg signed [65:0]  prod_e2;

   assign prod_e2[65:0]          =  a_ff_e2  *  b_ff_e2;




   rvdff  #(1)  low_e3_ff        (.*, .din(low_e2),                    .dout(low_e3),                 .clk(exu_mul_c1_e3_clk));
   rvdff  #(64) prod_e3_ff       (.*, .din(prod_e2[63:0]),             .dout(prod_e3[63:0]),          .clk(exu_mul_c1_e3_clk));


   assign out[31:0]            = low_e3  ?  prod_e3[31:0]  :  prod_e3[63:32];


endmodule 