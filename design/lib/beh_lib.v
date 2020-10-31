


module rvdff #( parameter WIDTH=1 )
   (
     input wire [WIDTH-1:0] din,
     input wire clk,
     input wire rst_l,

     output logic [WIDTH-1:0] dout
     );

`ifdef CLOCKGATE
   always @(posedge tb_top.clk) begin
      #0 $strobe("CG: %0t %m din %x dout %x clk %b width %d",$time,din,dout,clk,WIDTH);
   end
`endif

   always @(posedge clk or negedge rst_l) begin
      if (rst_l == 0)
        dout[WIDTH-1:0] <= 0;
      else
        dout[WIDTH-1:0] <= din[WIDTH-1:0];
   end


endmodule

module rvdffs #( parameter WIDTH=1 )
   (
     input wire [WIDTH-1:0] din,
     input wire en,
     input wire clk,
     input wire rst_l,
     output logic [WIDTH-1:0] dout
     );

   rvdff #(WIDTH) dffs (.din((en) ? din[WIDTH-1:0] : dout[WIDTH-1:0]), );

endmodule

module rvdffsc #( parameter WIDTH=1 )
   (
     input wire [WIDTH-1:0] din,
     input wire en,
     input wire clear,
     input wire clk,
     input wire rst_l,
     output logic [WIDTH-1:0] dout
     );

   wire [WIDTH-1:0]          din_new;
   assign din_new = {WIDTH{~clear}} & (en ? din[WIDTH-1:0] : dout[WIDTH-1:0]);
   rvdff #(WIDTH) dffsc (.din(din_new[WIDTH-1:0]), );

endmodule


module rvdffe #( parameter WIDTH=1 )
   (
     input wire [WIDTH-1:0] din,
     input wire en,
     input wire clk,
     input wire rst_l,
     input wire scan_mode,
     output logic [WIDTH-1:0] dout
     );

   wire                      l1clk;

`ifndef PHYSICAL
   if (WIDTH >= 8) begin: genblock
`endif

`ifdef RV_FPGA_OPTIMIZE
      rvdffs #(WIDTH) dff (  );
`else
      rvclkhdr clkhdr ( .l1clk(l1clk) );
      rvdff #(WIDTH) dff (.*, .clk(l1clk));
`endif

`ifndef PHYSICAL
   end
   else
      $error("%m: rvdffe width must be >= 8");
`endif

endmodule 
module rvsyncss #(parameter WIDTH = 251)
   (
     input wire clk,
     input wire rst_l,
     input wire [WIDTH-1:0]     din,
     output logic [WIDTH-1:0]     dout
     );

   reg [WIDTH-1:0]              din_ff1;

   rvdff #(WIDTH) sync_ff1  (.*, .din (din[WIDTH-1:0]),     .dout(din_ff1[WIDTH-1:0]));
   rvdff #(WIDTH) sync_ff2  (.*, .din (din_ff1[WIDTH-1:0]), .dout(dout[WIDTH-1:0]));

endmodule 
module rvarbiter2
  (
   input wire [1:0] ready,
   input wire shift,
   input wire clk,
   input wire rst_l,
   input wire scan_mode,
   output logic             tid
   );

wire ready0;
wire ready1;
wire ready2;
wire favor_in;
wire favor;

   assign ready0 = ~(|ready[1:0]);

   assign ready1 = ready[1] ^ ready[0];

   assign ready2 = ready[1] & ready[0];

   assign favor_in = (ready2 & ~favor) |
                     (ready1 & ready[0]) |
                     (ready0 & favor);

      rvdffs #(1) favor_ff (.*, .en(shift & ready2), .clk(clk), .din(favor_in),  .dout(favor) );

      assign tid = (ready2 & favor) |
                (ready[1] & ~ready[0]);

endmodule




module rvarbiter2_smt
  (
   input wire [1:0] flush,
   input wire [1:0] ready_in,
   input wire [1:0] lsu_in,
   input wire [1:0] mul_in,
   input wire [1:0] i0_only_in,
   input wire [1:0] thread_stall_in,
   input wire shift,
   input wire clk,
   input wire rst_l,
   input wire scan_mode,
   output logic [1:0]       ready,
   output logic             i0_sel_i0_t1,
   output logic [1:0]       i1_sel_i1,
   output logic [1:0]       i1_sel_i0
   );

   reg [1:0]              fready;
   wire [1:0]              thread_cancel_in;
wire ready0;
wire ready1;
wire ready2;
wire favor_in;
wire favor;
wire favor_new;
wire favor_final;
   wire                    ready2_in;
   wire                    lsu2_in;
   wire                    mul2_in;
   wire [1:0]              eff_ready_in;
   reg [1:0]              flush_ff;


   rvdff #(2) flushff (.*,
                        .clk(clk),
                        .din(flush[1:0]),
                        .dout(flush_ff[1:0])
                        );

         assign eff_ready_in[1:0] = ready_in[1:0] & ~({2{ready_in[1]&ready_in[0]}} & thread_stall_in[1:0]) & ~flush[1:0] & ~flush_ff[1:0];


   rvdff #(2) ready_ff (.*,
                        .clk(clk),
                        .din(eff_ready_in[1:0]),
                        .dout(ready[1:0])
                        );

   assign ready0 = ~(|ready[1:0]);

   assign ready1 = ready[1] ^ ready[0];

   assign ready2 = ready[1] & ready[0];

   assign favor_new = (ready2 & ~favor) |
                      (ready1 & ready[0]) |
                      (ready0 & favor);

   assign favor_in = (shift & ready2) ? favor_new : favor;

      assign favor_final = (favor_in       & !i0_only_in[0]) |
                        (!i0_only_in[0] &  i0_only_in[1]) |
                        (favor_in       &  i0_only_in[1]);

      rvdff #(1) favor_ff (.*, .clk(clk), .din(favor_final),  .dout(favor) );

      assign ready2_in = eff_ready_in[1] & eff_ready_in[0];
   assign lsu2_in   = lsu_in[1] & lsu_in[0];
   assign mul2_in   = mul_in[1] & mul_in[0];

         assign thread_cancel_in[1:0] = { (lsu2_in | mul2_in) & ready2_in & ~favor_in,
                                    (lsu2_in | mul2_in) & ready2_in &  favor_in  };
   rvdff #(2) fready_ff (.*,
                        .clk(clk),
                        .din(eff_ready_in[1:0] & ~thread_cancel_in[1:0]),
                        .dout(fready[1:0])
                        );

   assign i0_sel_i0_t1 = (fready[1]&favor) | (!fready[0]);

   assign i1_sel_i1[1] = (!fready[0]);

   assign i1_sel_i0[1] = (fready[0]&fready[1]&!favor);

   assign i1_sel_i1[0] = (!fready[1]);

   assign i1_sel_i0[0] = (fready[0]&fready[1]&favor);



endmodule


module rvlsadder
  (
    input wire [31:0] rs1,
    input wire [11:0] offset,

    output logic [31:0] dout
    );

   wire                cout;
   wire                sign;

   wire [31:12]        rs1_inc;
   wire [31:12]        rs1_dec;

   assign {cout,dout[11:0]} = {1'b0,rs1[11:0]} + {1'b0,offset[11:0]};

   assign rs1_inc[31:12] = rs1[31:12] + 1;

   assign rs1_dec[31:12] = rs1[31:12] - 1;

   assign sign = offset[11];

   assign dout[31:12] = ({20{  sign ^  ~cout}}  &     rs1[31:12]) |
                        ({20{ ~sign &   cout}}  & rs1_inc[31:12]) |
                        ({20{  sign &  ~cout}}  & rs1_dec[31:12]);

endmodule 

module rvbradder
  (
    input [31:1] pc,
    input [12:1] offset,

    output [31:1] dout
    );

   wire          cout;
   wire          sign;

   wire [31:13]  pc_inc;
   wire [31:13]  pc_dec;

   assign {cout,dout[12:1]} = {1'b0,pc[12:1]} + {1'b0,offset[12:1]};

   assign pc_inc[31:13] = pc[31:13] + 1;

   assign pc_dec[31:13] = pc[31:13] - 1;

   assign sign = offset[12];


   assign dout[31:13] = ({19{  sign ^  ~cout}} &      pc[31:13]) |
                        ({19{ ~sign &   cout}}  & pc_inc[31:13]) |
                        ({19{  sign &  ~cout}}  & pc_dec[31:13]);


endmodule 

module rvtwoscomp #( parameter WIDTH=32 )
   (
     input wire [WIDTH-1:0] din,

     output logic [WIDTH-1:0] dout
     );

   wire [WIDTH-1:1]          dout_temp;   
   genvar                     i;

   for ( i = 1; i < WIDTH; i++ )  begin : flip_after_first_one
      assign dout_temp[i] = (|din[i-1:0]) ? ~din[i] : din[i];
   end : flip_after_first_one

   assign dout[WIDTH-1:0]  = { dout_temp[WIDTH-1:1], din[0] };

endmodule  
module rvfindfirst1 #( parameter WIDTH=32, SHIFT=$clog2(WIDTH) )
   (
     input wire [WIDTH-1:0] din,

     output logic [SHIFT-1:0] dout
     );
   reg                      done;

   always @* begin
      dout[SHIFT-1:0] = {SHIFT{1'b0}};
      done    = 1'b0;

      for ( integer i = WIDTH-1; i > 0; i-- )  begin : find_first_one
         done |= din[i];
         dout[SHIFT-1:0] += done ? 1'b0 : 1'b1;
      end : find_first_one
   end
endmodule 
module rvfindfirst1hot #( parameter WIDTH=32 )
   (
     input wire [WIDTH-1:0] din,

     output logic [WIDTH-1:0] dout
     );
   reg                      done;

   always @* begin
      dout[WIDTH-1:0] = {WIDTH{1'b0}};
      done    = 1'b0;
      for ( integer i = 0; i < WIDTH; i++ )  begin : find_first_one
         dout[i] = ~done & din[i];
         done   |= din[i];
      end : find_first_one
   end
endmodule 
module rvmaskandmatch #( parameter WIDTH=32 )
   (
     input wire [WIDTH-1:0] mask,          input wire [WIDTH-1:0] data,          input wire masken,        output logic             match
     );

   wire [WIDTH-1:0]          matchvec;
   wire                      masken_or_fullmask;

   assign masken_or_fullmask = masken &  ~(&mask[WIDTH-1:0]);

   assign matchvec[0]        = masken_or_fullmask | (mask[0] == data[0]);
   genvar                     i;

   for ( i = 1; i < WIDTH; i++ )  begin : match_after_first_zero
      assign matchvec[i] = (&mask[i-1:0] & masken_or_fullmask) ? 1'b1 : (mask[i] == data[i]);
   end : match_after_first_zero

   assign match  = &matchvec[WIDTH-1:0];    
endmodule 

module rvrangecheck  #(CCM_SADR = 32'h0,
                       CCM_SIZE  = 128) (
   input wire [31:0]   addr,                                output logic          in_range,                               output logic          in_region
);

   localparam REGION_BITS = 4;
   localparam MASK_BITS = 10 + $clog2(CCM_SIZE);

   wire [31:0]          start_addr;
   wire [3:0]           region;

   assign start_addr[31:0]        = CCM_SADR;
   assign region[REGION_BITS-1:0] = start_addr[31:(32-REGION_BITS)];

   assign in_region = (addr[31:(32-REGION_BITS)] == region[REGION_BITS-1:0]);
   if (CCM_SIZE  == 48)
    assign in_range  = (addr[31:MASK_BITS] == start_addr[31:MASK_BITS]) & ~(&addr[MASK_BITS-1 : MASK_BITS-2]);
   else
    assign in_range  = (addr[31:MASK_BITS] == start_addr[31:MASK_BITS]);

endmodule  
module rveven_paritygen #(WIDTH = 16)  (
                                         input wire [WIDTH-1:0]  data_in,                                                  output logic              parity_out                                                );

   assign  parity_out =  ^(data_in[WIDTH-1:0]) ;

endmodule  
module rveven_paritycheck #(WIDTH = 16)  (
                                           input wire [WIDTH-1:0]  data_in,                                                    input wire parity_in,
                                           output logic              parity_err                                                  );

   assign  parity_err =  ^(data_in[WIDTH-1:0]) ^ parity_in ;

endmodule  
module rvecc_encode  (
                      input [31:0] din,
                      output [6:0] ecc_out
                      );
wire [5:0] ecc_out_temp;

   assign ecc_out_temp[0] = din[0]^din[1]^din[3]^din[4]^din[6]^din[8]^din[10]^din[11]^din[13]^din[15]^din[17]^din[19]^din[21]^din[23]^din[25]^din[26]^din[28]^din[30];
   assign ecc_out_temp[1] = din[0]^din[2]^din[3]^din[5]^din[6]^din[9]^din[10]^din[12]^din[13]^din[16]^din[17]^din[20]^din[21]^din[24]^din[25]^din[27]^din[28]^din[31];
   assign ecc_out_temp[2] = din[1]^din[2]^din[3]^din[7]^din[8]^din[9]^din[10]^din[14]^din[15]^din[16]^din[17]^din[22]^din[23]^din[24]^din[25]^din[29]^din[30]^din[31];
   assign ecc_out_temp[3] = din[4]^din[5]^din[6]^din[7]^din[8]^din[9]^din[10]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25];
   assign ecc_out_temp[4] = din[11]^din[12]^din[13]^din[14]^din[15]^din[16]^din[17]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25];
   assign ecc_out_temp[5] = din[26]^din[27]^din[28]^din[29]^din[30]^din[31];

   assign ecc_out[6:0] = {(^din[31:0])^(^ecc_out_temp[5:0]),ecc_out_temp[5:0]};

endmodule 
module rvecc_decode  (
                      input         en,
                      input [31:0]  din,
                      input [6:0]   ecc_in,
                      input         sed_ded,
                      output [31:0] dout,
                      output [6:0]  ecc_out,
                      output        single_ecc_error,
                      output        double_ecc_error

                      );

   wire [6:0]                      ecc_check;
   wire [38:0]                     error_mask;
wire [38:0] din_plus_parity;
wire [38:0] dout_plus_parity;

      assign ecc_check[0] = ecc_in[0]^din[0]^din[1]^din[3]^din[4]^din[6]^din[8]^din[10]^din[11]^din[13]^din[15]^din[17]^din[19]^din[21]^din[23]^din[25]^din[26]^din[28]^din[30];
   assign ecc_check[1] = ecc_in[1]^din[0]^din[2]^din[3]^din[5]^din[6]^din[9]^din[10]^din[12]^din[13]^din[16]^din[17]^din[20]^din[21]^din[24]^din[25]^din[27]^din[28]^din[31];
   assign ecc_check[2] = ecc_in[2]^din[1]^din[2]^din[3]^din[7]^din[8]^din[9]^din[10]^din[14]^din[15]^din[16]^din[17]^din[22]^din[23]^din[24]^din[25]^din[29]^din[30]^din[31];
   assign ecc_check[3] = ecc_in[3]^din[4]^din[5]^din[6]^din[7]^din[8]^din[9]^din[10]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25];
   assign ecc_check[4] = ecc_in[4]^din[11]^din[12]^din[13]^din[14]^din[15]^din[16]^din[17]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25];
   assign ecc_check[5] = ecc_in[5]^din[26]^din[27]^din[28]^din[29]^din[30]^din[31];

      assign ecc_check[6] = ((^din[31:0])^(^ecc_in[6:0])) & ~sed_ded;

   assign single_ecc_error = en & (ecc_check[6:0] != 0) & ecc_check[6];      assign double_ecc_error = en & (ecc_check[6:0] != 0) & ~ecc_check[6];  
      for (genvar i=1; i<40; i++) begin
      assign error_mask[i-1] = (ecc_check[5:0] == i);
   end

      assign din_plus_parity[38:0] = {ecc_in[6], din[31:26], ecc_in[5], din[25:11], ecc_in[4], din[10:4], ecc_in[3], din[3:1], ecc_in[2], din[0], ecc_in[1:0]};

   assign dout_plus_parity[38:0] = single_ecc_error ? (error_mask[38:0] ^ din_plus_parity[38:0]) : din_plus_parity[38:0];
   assign dout[31:0]             = {dout_plus_parity[37:32], dout_plus_parity[30:16], dout_plus_parity[14:8], dout_plus_parity[6:4], dout_plus_parity[2]};
   assign ecc_out[6:0]           = {(dout_plus_parity[38] ^ (ecc_check[6:0] == 7'b1000000)), dout_plus_parity[31], dout_plus_parity[15], dout_plus_parity[7], dout_plus_parity[3], dout_plus_parity[1:0]};

endmodule 
module rvecc_encode_64  (
                      input [63:0] din,
                      output [6:0] ecc_out
                      );
  assign ecc_out[0] = din[0]^din[1]^din[3]^din[4]^din[6]^din[8]^din[10]^din[11]^din[13]^din[15]^din[17]^din[19]^din[21]^din[23]^din[25]^din[26]^din[28]^din[30]^din[32]^din[34]^din[36]^din[38]^din[40]^din[42]^din[44]^din[46]^din[48]^din[50]^din[52]^din[54]^din[56]^din[57]^din[59]^din[61]^din[63];

   assign ecc_out[1] = din[0]^din[2]^din[3]^din[5]^din[6]^din[9]^din[10]^din[12]^din[13]^din[16]^din[17]^din[20]^din[21]^din[24]^din[25]^din[27]^din[28]^din[31]^din[32]^din[35]^din[36]^din[39]^din[40]^din[43]^din[44]^din[47]^din[48]^din[51]^din[52]^din[55]^din[56]^din[58]^din[59]^din[62]^din[63];

   assign ecc_out[2] = din[1]^din[2]^din[3]^din[7]^din[8]^din[9]^din[10]^din[14]^din[15]^din[16]^din[17]^din[22]^din[23]^din[24]^din[25]^din[29]^din[30]^din[31]^din[32]^din[37]^din[38]^din[39]^din[40]^din[45]^din[46]^din[47]^din[48]^din[53]^din[54]^din[55]^din[56]^din[60]^din[61]^din[62]^din[63];

   assign ecc_out[3] = din[4]^din[5]^din[6]^din[7]^din[8]^din[9]^din[10]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25]^din[33]^din[34]^din[35]^din[36]^din[37]^din[38]^din[39]^din[40]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_out[4] = din[11]^din[12]^din[13]^din[14]^din[15]^din[16]^din[17]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25]^din[41]^din[42]^din[43]^din[44]^din[45]^din[46]^din[47]^din[48]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_out[5] = din[26]^din[27]^din[28]^din[29]^din[30]^din[31]^din[32]^din[33]^din[34]^din[35]^din[36]^din[37]^din[38]^din[39]^din[40]^din[41]^din[42]^din[43]^din[44]^din[45]^din[46]^din[47]^din[48]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_out[6] = din[57]^din[58]^din[59]^din[60]^din[61]^din[62]^din[63];

endmodule 



module TEC_RV_ICG
  (
   input wire SE, EN, CK,
   output Q
   );

   reg  en_ff;
   wire  enable;

   assign      enable = EN | SE;

`ifdef VERILATOR
   always @(negedge CK) begin
      en_ff <= enable;
   end
`else
   always @(CK, enable) begin
      if(!CK)
        en_ff = enable;
   end
`endif
   assign Q = CK & en_ff;

endmodule

module rvclkhdr
  (
   input wire en,
   input wire clk,
   input wire scan_mode,
   output logic l1clk
   );

   wire   SE;
   assign       SE = scan_mode;

   TEC_RV_ICG clkhdr ( .SE(SE), .EN(en), .CK(clk), .Q(l1clk));

endmodule 
module rvoclkhdr
  (
   input wire en,
   input wire clk,
   input wire scan_mode,
   output logic l1clk
   );

   wire   SE;
   assign       SE = scan_mode;

`ifdef RV_FPGA_OPTIMIZE
   assign l1clk = clk;
`else
   TEC_RV_ICG clkhdr ( .SE(SE), .EN(en), .CK(clk), .Q(l1clk));
`endif

endmodule

module rvecc_decode_64  (
                      input         en,
                      input [63:0]  din,
                      input [6:0]   ecc_in,
                      output        ecc_error
                      );

   wire [6:0]                      ecc_check;

   // Generate the ecc bits
   assign ecc_check[0] = ecc_in[0]^din[0]^din[1]^din[3]^din[4]^din[6]^din[8]^din[10]^din[11]^din[13]^din[15]^din[17]^din[19]^din[21]^din[23]^din[25]^din[26]^din[28]^din[30]^din[32]^din[34]^din[36]^din[38]^din[40]^din[42]^din[44]^din[46]^din[48]^din[50]^din[52]^din[54]^din[56]^din[57]^din[59]^din[61]^din[63];

   assign ecc_check[1] = ecc_in[1]^din[0]^din[2]^din[3]^din[5]^din[6]^din[9]^din[10]^din[12]^din[13]^din[16]^din[17]^din[20]^din[21]^din[24]^din[25]^din[27]^din[28]^din[31]^din[32]^din[35]^din[36]^din[39]^din[40]^din[43]^din[44]^din[47]^din[48]^din[51]^din[52]^din[55]^din[56]^din[58]^din[59]^din[62]^din[63];

   assign ecc_check[2] = ecc_in[2]^din[1]^din[2]^din[3]^din[7]^din[8]^din[9]^din[10]^din[14]^din[15]^din[16]^din[17]^din[22]^din[23]^din[24]^din[25]^din[29]^din[30]^din[31]^din[32]^din[37]^din[38]^din[39]^din[40]^din[45]^din[46]^din[47]^din[48]^din[53]^din[54]^din[55]^din[56]^din[60]^din[61]^din[62]^din[63];

   assign ecc_check[3] = ecc_in[3]^din[4]^din[5]^din[6]^din[7]^din[8]^din[9]^din[10]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25]^din[33]^din[34]^din[35]^din[36]^din[37]^din[38]^din[39]^din[40]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_check[4] = ecc_in[4]^din[11]^din[12]^din[13]^din[14]^din[15]^din[16]^din[17]^din[18]^din[19]^din[20]^din[21]^din[22]^din[23]^din[24]^din[25]^din[41]^din[42]^din[43]^din[44]^din[45]^din[46]^din[47]^din[48]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_check[5] = ecc_in[5]^din[26]^din[27]^din[28]^din[29]^din[30]^din[31]^din[32]^din[33]^din[34]^din[35]^din[36]^din[37]^din[38]^din[39]^din[40]^din[41]^din[42]^din[43]^din[44]^din[45]^din[46]^din[47]^din[48]^din[49]^din[50]^din[51]^din[52]^din[53]^din[54]^din[55]^din[56];

   assign ecc_check[6] = ecc_in[6]^din[57]^din[58]^din[59]^din[60]^din[61]^din[62]^din[63];

   assign ecc_error = en & (ecc_check[6:0] != 0);  // all errors in the sed_ded case will be recorded as DE

 endmodule // rvecc_decode_64

