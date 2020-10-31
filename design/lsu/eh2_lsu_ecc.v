
module eh2_lsu_ecc
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(

   input wire clk,
   input wire scan_mode,                input wire rst_l,
   input eh2_lsu_pkt_t                 lsu_pkt_dc3,           input wire lsu_dccm_rden_dc3,     input wire addr_in_dccm_dc3,      input wire [pt.DCCM_BITS-1:0]       lsu_addr_dc3,       input wire [pt.DCCM_BITS-1:0]       end_addr_dc3,       input wire [31:0]                   store_data_dc3,     input wire [pt.DCCM_DATA_WIDTH-1:0] stbuf_data_any,

   input wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_hi_dc3,        input wire [pt.DCCM_DATA_WIDTH-1:0] dccm_data_lo_dc3,        input wire [pt.DCCM_ECC_WIDTH-1:0]  dccm_data_ecc_hi_dc3,    input wire [pt.DCCM_ECC_WIDTH-1:0]  dccm_data_ecc_lo_dc3, 
   input wire [pt.DCCM_DATA_WIDTH-1:0] sec_data_hi_dc5,
   input wire [pt.DCCM_DATA_WIDTH-1:0] sec_data_lo_dc5,

   input wire ld_single_ecc_error_dc5,         input wire ld_single_ecc_error_dc5_ff,      input wire ld_single_ecc_error_lo_dc5_ff,      input wire ld_single_ecc_error_hi_dc5_ff,      input wire dec_tlu_core_ecc_disable,        input wire disable_ecc_check_lo_dc3,
   input wire disable_ecc_check_hi_dc3,
   input wire misaligned_fault_dc3,
   input wire access_fault_dc3,

   input wire dma_dccm_spec_wen,
   input wire [31:0]                   dma_dccm_wdata_lo,
   input wire [31:0]                   dma_dccm_wdata_hi,

   output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi,
   output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo,

   output logic [pt.DCCM_DATA_WIDTH-1:0] sec_data_hi_dc3,
   output logic [pt.DCCM_DATA_WIDTH-1:0] sec_data_lo_dc3,

   output logic [pt.DCCM_DATA_WIDTH-1:0] store_ecc_data_hi_dc3,     output logic [pt.DCCM_DATA_WIDTH-1:0] store_ecc_data_lo_dc3,

   output logic                          single_ecc_error_hi_dc3,                      output logic                          single_ecc_error_lo_dc3,                      output logic                          lsu_single_ecc_error_dc3,                     output logic                          lsu_double_ecc_error_dc3                   
 );

wire double_ecc_error_hi_dc3;
wire double_ecc_error_lo_dc3;
reg [pt.DCCM_ECC_WIDTH-1:0] dccm_wdata_ecc_hi_any;
reg [pt.DCCM_ECC_WIDTH-1:0] dccm_wdata_ecc_lo_any;

   wire        ldst_dual_dc3;
   wire        is_ldst_dc3;
wire is_ldst_hi_dc3;
wire is_ldst_lo_dc3;
   wire [7:0]  ldst_byteen_dc3;
   wire [7:0]  store_byteen_dc3;
   wire [7:0]  store_byteen_ext_dc3;
wire [pt.DCCM_BYTE_WIDTH-1:0] store_byteen_hi_dc3;
wire [pt.DCCM_BYTE_WIDTH-1:0] store_byteen_lo_dc3;

   wire [55:0] store_data_ext_dc3;
wire [pt.DCCM_DATA_WIDTH-1:0] store_data_hi_dc3;
wire [pt.DCCM_DATA_WIDTH-1:0] store_data_lo_dc3;
reg [6:0] ecc_out_hi_nc;
reg [6:0] ecc_out_lo_nc;

reg single_ecc_error_hi_raw_dc3;
reg single_ecc_error_lo_raw_dc3;
wire [pt.DCCM_DATA_WIDTH-1:0] sec_data_hi_dc5_ff;
wire [pt.DCCM_DATA_WIDTH-1:0] sec_data_lo_dc5_ff;

         
   assign ldst_dual_dc3 = (lsu_addr_dc3[2] != end_addr_dc3[2]);
   assign is_ldst_dc3 = lsu_pkt_dc3.valid & (lsu_pkt_dc3.load | lsu_pkt_dc3.store) & addr_in_dccm_dc3 & lsu_dccm_rden_dc3;
   assign is_ldst_lo_dc3 = is_ldst_dc3 & ~(dec_tlu_core_ecc_disable | disable_ecc_check_lo_dc3);
   assign is_ldst_hi_dc3 = is_ldst_dc3 & (ldst_dual_dc3 | lsu_pkt_dc3.dma) & ~(dec_tlu_core_ecc_disable | disable_ecc_check_hi_dc3);

   assign ldst_byteen_dc3[7:0] = ({8{lsu_pkt_dc3.by}}   & 8'b0000_0001) |
                                 ({8{lsu_pkt_dc3.half}} & 8'b0000_0011) |
                                 ({8{lsu_pkt_dc3.word}} & 8'b0000_1111) |
                                 ({8{lsu_pkt_dc3.dword}} & 8'b1111_1111);
   assign store_byteen_dc3[7:0] = ldst_byteen_dc3[7:0] & {8{~lsu_pkt_dc3.load}};

   assign store_byteen_ext_dc3[7:0] = store_byteen_dc3[7:0] << lsu_addr_dc3[1:0];
   assign store_byteen_hi_dc3[pt.DCCM_BYTE_WIDTH-1:0] = store_byteen_ext_dc3[7:4];
   assign store_byteen_lo_dc3[pt.DCCM_BYTE_WIDTH-1:0] = store_byteen_ext_dc3[3:0];

   assign store_data_ext_dc3[55:0] = {24'b0,store_data_dc3[31:0]} << {lsu_addr_dc3[1:0], 3'b000};
   assign store_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0]  = {8'b0,store_data_ext_dc3[55:32]};
   assign store_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]  = store_data_ext_dc3[31:0];


         for (genvar i=0; i<pt.DCCM_BYTE_WIDTH; i++) begin
      assign store_ecc_data_hi_dc3[(8*i)+7:(8*i)] = store_byteen_hi_dc3[i]  ? store_data_hi_dc3[(8*i)+7:(8*i)] : ({8{addr_in_dccm_dc3}} & sec_data_hi_dc3[(8*i)+7:(8*i)]);
      assign store_ecc_data_lo_dc3[(8*i)+7:(8*i)] = store_byteen_lo_dc3[i]  ? store_data_lo_dc3[(8*i)+7:(8*i)] : ({8{addr_in_dccm_dc3}} & sec_data_lo_dc3[(8*i)+7:(8*i)]);
   end

   assign dccm_wr_data_lo[pt.DCCM_DATA_WIDTH-1:0] = dma_dccm_spec_wen ? dma_dccm_wdata_lo[pt.DCCM_DATA_WIDTH-1:0] :
                                                    (ld_single_ecc_error_dc5_ff ? (ld_single_ecc_error_lo_dc5_ff ? sec_data_lo_dc5_ff[pt.DCCM_DATA_WIDTH-1:0] : sec_data_hi_dc5_ff[pt.DCCM_DATA_WIDTH-1:0]) : stbuf_data_any[pt.DCCM_DATA_WIDTH-1:0]);
   assign dccm_wr_data_hi[pt.DCCM_DATA_WIDTH-1:0] = dma_dccm_spec_wen ? dma_dccm_wdata_hi[pt.DCCM_DATA_WIDTH-1:0] :
                                                    (ld_single_ecc_error_dc5_ff ? (ld_single_ecc_error_hi_dc5_ff ? sec_data_hi_dc5_ff[pt.DCCM_DATA_WIDTH-1:0] : sec_data_lo_dc5_ff[pt.DCCM_DATA_WIDTH-1:0]) : stbuf_data_any[pt.DCCM_DATA_WIDTH-1:0]);

   assign dccm_wr_data_lo[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH] = dccm_wdata_ecc_lo_any[pt.DCCM_ECC_WIDTH-1:0];
   assign dccm_wr_data_hi[pt.DCCM_FDATA_WIDTH-1:pt.DCCM_DATA_WIDTH] = dccm_wdata_ecc_hi_any[pt.DCCM_ECC_WIDTH-1:0];

   if (pt.DCCM_ENABLE == 1) begin: Gen_dccm_enable
            rvecc_decode lsu_ecc_decode_hi (
                  .en(is_ldst_hi_dc3),
         .sed_ded (1'b0),             .din(dccm_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0]),
         .ecc_in(dccm_data_ecc_hi_dc3[pt.DCCM_ECC_WIDTH-1:0]),
                  .dout(sec_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0]),
         .ecc_out (ecc_out_hi_nc[6:0]),
         .single_ecc_error(single_ecc_error_hi_raw_dc3),
         .double_ecc_error(double_ecc_error_hi_dc3),
         .*
      );

      rvecc_decode lsu_ecc_decode_lo (
                  .en(is_ldst_lo_dc3),
         .sed_ded (1'b0),             .din(dccm_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0] ),
         .ecc_in(dccm_data_ecc_lo_dc3[pt.DCCM_ECC_WIDTH-1:0]),
                  .dout(sec_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0]),
         .ecc_out (ecc_out_lo_nc[6:0]),
         .single_ecc_error(single_ecc_error_lo_raw_dc3),
         .double_ecc_error(double_ecc_error_lo_dc3),
         .*
      );

      rvecc_encode lsu_ecc_encode_hi (
                  .din(dccm_wr_data_hi[pt.DCCM_DATA_WIDTH-1:0]),
                  .ecc_out(dccm_wdata_ecc_hi_any[pt.DCCM_ECC_WIDTH-1:0]),

      );
      rvecc_encode lsu_ecc_encode_lo (
                  .din(dccm_wr_data_lo[pt.DCCM_DATA_WIDTH-1:0]),
                  .ecc_out(dccm_wdata_ecc_lo_any[pt.DCCM_ECC_WIDTH-1:0]),
         .*
      );

      assign single_ecc_error_hi_dc3  = single_ecc_error_hi_raw_dc3 & ~(misaligned_fault_dc3 | access_fault_dc3);
      assign single_ecc_error_lo_dc3  = single_ecc_error_lo_raw_dc3 & ~(misaligned_fault_dc3 | access_fault_dc3);
      assign lsu_single_ecc_error_dc3 = single_ecc_error_hi_dc3 | single_ecc_error_lo_dc3;
      assign lsu_double_ecc_error_dc3 = double_ecc_error_hi_dc3 | double_ecc_error_lo_dc3;

     rvdffe #(.WIDTH(pt.DCCM_DATA_WIDTH)) sec_data_hi_dc5plus1ff (.din(sec_data_hi_dc5[pt.DCCM_DATA_WIDTH-1:0]), .dout(sec_data_hi_dc5_ff[pt.DCCM_DATA_WIDTH-1:0]), .en(ld_single_ecc_error_dc5), .clk(clk), .*);
      rvdffe #(.WIDTH(pt.DCCM_DATA_WIDTH)) sec_data_lo_dc5plus1ff (.din(sec_data_lo_dc5[pt.DCCM_DATA_WIDTH-1:0]), .dout(sec_data_lo_dc5_ff[pt.DCCM_DATA_WIDTH-1:0]), .en(ld_single_ecc_error_dc5), .clk(clk), .*);

   end else begin: Gen_dccm_disable       assign sec_data_hi_dc3[pt.DCCM_DATA_WIDTH-1:0] = '0;
      assign sec_data_lo_dc3[pt.DCCM_DATA_WIDTH-1:0] = '0;
      assign single_ecc_error_hi_dc3 = '0;
      assign double_ecc_error_hi_dc3 = '0;
      assign single_ecc_error_lo_dc3 = '0;
      assign double_ecc_error_lo_dc3 = '0;
      assign lsu_single_ecc_error_dc3 = '0;
      assign lsu_double_ecc_error_dc3 = '0;
      assign sec_data_lo_dc5_ff[pt.DCCM_DATA_WIDTH-1:0] = '0;
      assign sec_data_hi_dc5_ff[pt.DCCM_DATA_WIDTH-1:0] = '0;

   end

`ifdef ASSERT_ON


`endif

endmodule 