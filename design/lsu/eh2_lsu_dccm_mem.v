





module eh2_lsu_dccm_mem
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )(
   input wire clk,                                                input wire rst_l,
   input wire clk_override,                                    
   input wire dccm_wren,                                          input wire dccm_rden,                                          input wire [pt.DCCM_BITS-1:0]  dccm_wr_addr_lo,                        input wire [pt.DCCM_BITS-1:0]  dccm_wr_addr_hi,                        input wire [pt.DCCM_BITS-1:0]  dccm_rd_addr_lo,                        input wire [pt.DCCM_BITS-1:0]  dccm_rd_addr_hi,                        input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo,                 input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi,              
   output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_rd_data_lo,                 output logic [pt.DCCM_FDATA_WIDTH-1:0] dccm_rd_data_hi,              
   input wire scan_mode
);


   localparam DCCM_WIDTH_BITS = $clog2(pt.DCCM_BYTE_WIDTH);
   localparam DCCM_INDEX_BITS = (pt.DCCM_BITS - pt.DCCM_BANK_BITS - pt.DCCM_WIDTH_BITS);
   localparam DCCM_INDEX_DEPTH = (((pt.DCCM_SIZE)*1024)>>($clog2(pt.DCCM_BYTE_WIDTH)))>>$clog2((pt.DCCM_NUM_BANKS));  

   wire [pt.DCCM_NUM_BANKS-1:0]                                        wren_bank;
   wire [pt.DCCM_NUM_BANKS-1:0]                                        rden_bank;
   reg [pt.DCCM_NUM_BANKS-1:0] [pt.DCCM_BITS-1:(pt.DCCM_BANK_BITS+2)] addr_bank;
reg [pt.DCCM_BITS-1:(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)] rd_addr_even;
reg [pt.DCCM_BITS-1:(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)] rd_addr_odd;
wire rd_unaligned;
wire wr_unaligned;
   wire [pt.DCCM_NUM_BANKS-1:0] [pt.DCCM_FDATA_WIDTH-1:0]              dccm_bank_dout;
   reg [pt.DCCM_FDATA_WIDTH-1:0]                                      wrdata;

   wire [pt.DCCM_NUM_BANKS-1:0][pt.DCCM_FDATA_WIDTH-1:0]               wr_data_bank;

reg [pt.DCCM_NUM_BANKS-1:0] dccm_rd_data_bank_hi;
reg [pt.DCCM_NUM_BANKS-1:0] dccm_rd_data_bank_lo;

   wire [(DCCM_WIDTH_BITS+pt.DCCM_BANK_BITS-1):DCCM_WIDTH_BITS]        dccm_rd_addr_lo_q;
   wire [(DCCM_WIDTH_BITS+pt.DCCM_BANK_BITS-1):DCCM_WIDTH_BITS]        dccm_rd_addr_hi_q;

   wire [pt.DCCM_NUM_BANKS-1:0]                                        dccm_clken;

   wire                                                                dccm_rd_addr_lo_q2;
   wire                                                                dccm_rd_addr_hi_q2;


   assign rd_unaligned = (dccm_rd_addr_lo[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS] != dccm_rd_addr_hi[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]);
   assign wr_unaligned = (dccm_wr_addr_lo[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS] != dccm_wr_addr_hi[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]);

      for (genvar i=0; i<pt.DCCM_NUM_BANKS; i++) begin: mem_bank
      assign  wren_bank[i]        = dccm_wren & ((dccm_wr_addr_hi[2+:pt.DCCM_BANK_BITS] == i) | (dccm_wr_addr_lo[2+:pt.DCCM_BANK_BITS] == i));
      assign  rden_bank[i]        = dccm_rden & ((dccm_rd_addr_hi[2+:pt.DCCM_BANK_BITS] == i) | (dccm_rd_addr_lo[2+:pt.DCCM_BANK_BITS] == i));
      assign  addr_bank[i][(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)+:DCCM_INDEX_BITS] = rden_bank[i] ? (((dccm_rd_addr_hi[2+:pt.DCCM_BANK_BITS] == i) & rd_unaligned) ?
                                                                                                        dccm_rd_addr_hi[(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)+:DCCM_INDEX_BITS] :
                                                                                                        dccm_rd_addr_lo[(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)+:DCCM_INDEX_BITS]) :
                                                                                                  (((dccm_wr_addr_hi[2+:pt.DCCM_BANK_BITS] == i) & wr_unaligned) ?
                                                                                                        dccm_wr_addr_hi[(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)+:DCCM_INDEX_BITS] :
                                                                                                        dccm_wr_addr_lo[(pt.DCCM_BANK_BITS+DCCM_WIDTH_BITS)+:DCCM_INDEX_BITS]);


      assign wr_data_bank[i]     = ((dccm_wr_addr_hi[2+:pt.DCCM_BANK_BITS] == i) & wr_unaligned) ? dccm_wr_data_hi[pt.DCCM_FDATA_WIDTH-1:0] : dccm_wr_data_lo[pt.DCCM_FDATA_WIDTH-1:0];

            assign  dccm_clken[i] = (wren_bank[i] | rden_bank[i] | clk_override) ;
      
`ifdef VERILATOR
         eh2_ram #(DCCM_INDEX_DEPTH,39)  ram (
                                                                    .ME(dccm_clken[i]),
                                  .CLK(clk),
                                  .WE(wren_bank[i]),
                                  .ADR(addr_bank[i]),
                                  .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                  .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                  );

`else
      if (DCCM_INDEX_DEPTH == 32768) begin : dccm
         ram_32768x39  dccm_bank (
                                                                    .ME(dccm_clken[i]),
                                  .CLK(clk),
                                  .WE(wren_bank[i]),
                                  .ADR(addr_bank[i]),
                                  .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                  .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                  );
      end
      else if (DCCM_INDEX_DEPTH == 16384) begin : dccm
         ram_16384x39  dccm_bank (
                                                                    .ME(dccm_clken[i]),
                                  .CLK(clk),
                                  .WE(wren_bank[i]),
                                  .ADR(addr_bank[i]),
                                  .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                  .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                  );
      end
      else if (DCCM_INDEX_DEPTH == 8192) begin : dccm
         ram_8192x39  dccm_bank (
                                                                  .ME(dccm_clken[i]),
                                 .CLK(clk),
                                 .WE(wren_bank[i]),
                                 .ADR(addr_bank[i]),
                                 .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                 .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                 );
      end
      else if (DCCM_INDEX_DEPTH == 4096) begin : dccm
         ram_4096x39  dccm_bank (
                                                                  .ME(dccm_clken[i]),
                                 .CLK(clk),
                                 .WE(wren_bank[i]),
                                 .ADR(addr_bank[i]),
                                 .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                 .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                 );
      end
      else if (DCCM_INDEX_DEPTH == 3072) begin : dccm
         ram_3072x39  dccm_bank (
                                                                  .ME(dccm_clken[i]),
                                 .CLK(clk),
                                 .WE(wren_bank[i]),
                                 .ADR(addr_bank[i]),
                                 .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                 .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                 );
      end
      else if (DCCM_INDEX_DEPTH == 2048) begin : dccm
         ram_2048x39  dccm_bank (
                                                                  .ME(dccm_clken[i]),
                                 .CLK(clk),
                                 .WE(wren_bank[i]),
                                 .ADR(addr_bank[i]),
                                 .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                 .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                 );
      end
      else if (DCCM_INDEX_DEPTH == 1024) begin : dccm
         ram_1024x39  dccm_bank (
                                                                  .ME(dccm_clken[i]),
                                 .CLK(clk),
                                 .WE(wren_bank[i]),
                                 .ADR(addr_bank[i]),
                                 .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                 .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                 );
      end
      else if (DCCM_INDEX_DEPTH == 512) begin : dccm
         ram_512x39  dccm_bank (
                                                                .ME(dccm_clken[i]),
                                .CLK(clk),
                                .WE(wren_bank[i]),
                                .ADR(addr_bank[i]),
                                .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                );
      end
      else if (DCCM_INDEX_DEPTH == 256) begin : dccm
         ram_256x39  dccm_bank (
                                                                .ME(dccm_clken[i]),
                                .CLK(clk),
                                .WE(wren_bank[i]),
                                .ADR(addr_bank[i]),
                                .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                );
      end
      else if (DCCM_INDEX_DEPTH == 128) begin : dccm
         ram_128x39  dccm_bank (
                                                                .ME(dccm_clken[i]),
                                .CLK(clk),
                                .WE(wren_bank[i]),
                                .ADR(addr_bank[i]),
                                .D(wr_data_bank[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                .Q(dccm_bank_dout[i][pt.DCCM_FDATA_WIDTH-1:0]),
                                    .*
                                );
      end

 `endif 
   end : mem_bank
 rvdffs  #(pt.DCCM_BANK_BITS) rd_addr_lo_ff (.*, .din(dccm_rd_addr_lo[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .dout(dccm_rd_addr_lo_q[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .en(1'b1));
   rvdffs  #(pt.DCCM_BANK_BITS) rd_addr_hi_ff (.*, .din(dccm_rd_addr_hi[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .dout(dccm_rd_addr_hi_q[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .en(1'b1));

   
      if (pt.LOAD_TO_USE_PLUS1 == 1) begin: GenL2U_1
      reg                                                          dccm_rden_q;
      wire [pt.DCCM_NUM_BANKS-1:0] [pt.DCCM_FDATA_WIDTH-1:0]        dccm_bank_dout_q;
      wire [(DCCM_WIDTH_BITS+pt.DCCM_BANK_BITS-1):DCCM_WIDTH_BITS]  dccm_rd_addr_lo_q2;
      wire [(DCCM_WIDTH_BITS+pt.DCCM_BANK_BITS-1):DCCM_WIDTH_BITS]  dccm_rd_addr_hi_q2;

            assign dccm_rd_data_lo[pt.DCCM_FDATA_WIDTH-1:0]  = dccm_bank_dout_q[dccm_rd_addr_lo_q2[pt.DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]][pt.DCCM_FDATA_WIDTH-1:0];
      assign dccm_rd_data_hi[pt.DCCM_FDATA_WIDTH-1:0]  = dccm_bank_dout_q[dccm_rd_addr_hi_q2[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]][pt.DCCM_FDATA_WIDTH-1:0];

      for (genvar i=0; i<pt.DCCM_NUM_BANKS; i++) begin: GenBanks
                 rvdffe #(pt.DCCM_FDATA_WIDTH) dccm_bank_dout_ff(.*, .din(dccm_bank_dout[i]), .dout(dccm_bank_dout_q[i]), .en(dccm_rden_q));

      end
      rvdff  #(1)                  dccm_rden_ff  (.*, .din(dccm_rden), .dout(dccm_rden_q));
      rvdffs  #(pt.DCCM_BANK_BITS) rd_addr_lo_ff (.*, .din(dccm_rd_addr_lo_q[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .dout(dccm_rd_addr_lo_q2[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .en(1'b1));
      rvdffs  #(pt.DCCM_BANK_BITS) rd_addr_hi_ff (.*, .din(dccm_rd_addr_hi_q[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .dout(dccm_rd_addr_hi_q2[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]), .en(1'b1));

   end else begin
            assign dccm_rd_data_lo[pt.DCCM_FDATA_WIDTH-1:0]  = dccm_bank_dout[dccm_rd_addr_lo_q[pt.DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]][pt.DCCM_FDATA_WIDTH-1:0];
      assign dccm_rd_data_hi[pt.DCCM_FDATA_WIDTH-1:0]  = dccm_bank_dout[dccm_rd_addr_hi_q[DCCM_WIDTH_BITS+:pt.DCCM_BANK_BITS]][pt.DCCM_FDATA_WIDTH-1:0];

      assign dccm_rd_addr_lo_q2 = '0;
      assign dccm_rd_addr_hi_q2 = '0;
   end
`undef ELX2_LOCAL_DCCM_RAM_TEST_PORTS

endmodule 

