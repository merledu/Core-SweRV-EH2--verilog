
module eh2_lsu_addrcheck
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(
   input wire lsu_c2_dc2_clk,          input wire lsu_c2_dc3_clk,
   input wire clk,
   input wire rst_l,                       
   input wire [31:0]       start_addr_dc1,                 input wire [31:0]       end_addr_dc1,                   input wire [31:0]       start_addr_dc2,                 input wire [31:0]       end_addr_dc2,                   input wire [31:0]       rs1_dc1,
   input eh2_lsu_pkt_t     lsu_pkt_dc1,                    input eh2_lsu_pkt_t     lsu_pkt_dc2,                 
   input wire [31:0]  dec_tlu_mrac_ff,           
   output logic        is_sideeffects_dc2,             output logic        is_sideeffects_dc3,
   output logic        addr_in_dccm_region_dc1,        output logic        addr_in_dccm_dc1,               output logic        addr_in_pic_dc1,                output logic        addr_external_dc1,              output logic        addr_external_dc2,           
   output logic        access_fault_dc2,               output logic        misaligned_fault_dc2,           output logic [3:0]  exc_mscause_dc2,             
   output logic        fir_dccm_access_error_dc2,      output logic        fir_nondccm_access_error_dc2,
   input wire scan_mode
);


reg is_sideeffects_dc1;
reg is_aligned_dc2;
wire start_addr_in_dccm_dc1;
wire end_addr_in_dccm_dc1;
wire start_addr_in_dccm_region_dc1;
wire end_addr_in_dccm_region_dc1;
reg start_addr_in_pic_dc1;
reg end_addr_in_pic_dc1;
reg start_addr_in_pic_region_dc1;
reg end_addr_in_pic_region_dc1;
   reg        addr_in_pic_region_dc1;
reg start_addr_in_dccm_dc2;
reg end_addr_in_dccm_dc2;
reg start_addr_in_pic_dc2;
reg end_addr_in_pic_dc2;
reg start_addr_in_dccm_region_dc2;
reg end_addr_in_dccm_region_dc2;
reg start_addr_in_pic_region_dc2;
reg end_addr_in_pic_region_dc2;
wire addr_in_dccm_dc2;
wire addr_in_pic_dc2;
reg [3:0] rs1_region_dc1 [4:0];
reg [3:0] rs1_region_dc2 [4:0];
reg [3:0] csr_idx [4:0];
   wire        addr_in_iccm;
   wire        start_addr_dccm_or_pic;
   wire        base_reg_dccm_or_pic;
   reg [31:0] rs1_dc2;
wire unmapped_access_fault_dc2;
reg mpu_access_fault_dc2;
reg picm_access_fault_dc2;
wire regpred_access_fault_dc2;
reg amo_access_fault_dc2;
wire regcross_misaligned_fault_dc2;
wire sideeffect_misaligned_fault_dc2;
   wire [3:0]  access_fault_mscause_dc2;
   wire [3:0]  misaligned_fault_mscause_dc2;
   wire        non_dccm_access_ok;

   if (pt.DCCM_ENABLE == 1) begin: Gen_dccm_enable
            rvrangecheck #(.CCM_SADR(pt.DCCM_SADR),
                     .CCM_SIZE(pt.DCCM_SIZE)) start_addr_dccm_rangecheck (
         .addr(start_addr_dc1[31:0]),
         .in_range(start_addr_in_dccm_dc1),
         .in_region(start_addr_in_dccm_region_dc1)
      );

            rvrangecheck #(.CCM_SADR(pt.DCCM_SADR),
                     .CCM_SIZE(pt.DCCM_SIZE)) end_addr_dccm_rangecheck (
         .addr(end_addr_dc1[31:0]),
         .in_range(end_addr_in_dccm_dc1),
         .in_region(end_addr_in_dccm_region_dc1)
      );
   end else begin: Gen_dccm_disable       assign start_addr_in_dccm_dc1 = '0;
      assign start_addr_in_dccm_region_dc1 = '0;
      assign end_addr_in_dccm_dc1 = '0;
      assign end_addr_in_dccm_region_dc1 = '0;
   end

      if (pt.ICCM_ENABLE == 1) begin : check_iccm
     assign addr_in_iccm =  (start_addr_dc2[31:28] == pt.ICCM_REGION);
   end
   else begin
     assign addr_in_iccm = 1'b0;
   end

         rvrangecheck #(.CCM_SADR(pt.PIC_BASE_ADDR),
                  .CCM_SIZE(pt.PIC_SIZE)) start_addr_pic_rangecheck (
      .addr(start_addr_dc1[31:0]),
      .in_range(start_addr_in_pic_dc1),
      .in_region(start_addr_in_pic_region_dc1)
   );

      rvrangecheck #(.CCM_SADR(pt.PIC_BASE_ADDR),
                  .CCM_SIZE(pt.PIC_SIZE)) end_addr_pic_rangecheck (
      .addr(end_addr_dc1[31:0]),
      .in_range(end_addr_in_pic_dc1),
      .in_region(end_addr_in_pic_region_dc1)
   );

   assign rs1_region_dc1[3:0] = rs1_dc1[31:28];
   assign rs1_region_dc2[3:0] = rs1_dc2[31:28];
   assign start_addr_dccm_or_pic  = start_addr_in_dccm_region_dc2 | start_addr_in_pic_region_dc2;
   assign base_reg_dccm_or_pic    = ((rs1_region_dc2[3:0] == pt.DCCM_REGION) & pt.DCCM_ENABLE) | (rs1_region_dc2[3:0] == pt.PIC_REGION);

   assign addr_in_dccm_region_dc1 = (rs1_region_dc1[3:0] == pt.DCCM_REGION) & pt.DCCM_ENABLE;     assign addr_in_pic_region_dc1  = (rs1_region_dc1[3:0] == pt.PIC_REGION);      assign addr_in_dccm_dc1        = (start_addr_in_dccm_dc1 & end_addr_in_dccm_dc1);
   assign addr_in_pic_dc1         = (start_addr_in_pic_dc1 & end_addr_in_pic_dc1);

   assign addr_in_dccm_dc2        = (start_addr_in_dccm_dc2 & end_addr_in_dccm_dc2);
   assign addr_in_pic_dc2         = (start_addr_in_pic_dc2 & end_addr_in_pic_dc2);

   assign addr_external_dc1  = ~(addr_in_dccm_region_dc1 | addr_in_pic_region_dc1);     assign addr_external_dc2  = ~(start_addr_in_dccm_region_dc2 | start_addr_in_pic_region_dc2);     assign csr_idx[4:0]       = {start_addr_dc2[31:28], 1'b1};
   assign is_sideeffects_dc2 = dec_tlu_mrac_ff[csr_idx] & ~(start_addr_in_dccm_region_dc2 | start_addr_in_pic_region_dc2 | addr_in_iccm);     assign is_aligned_dc2    = (lsu_pkt_dc2.word & (start_addr_dc2[1:0] == 2'b0)) |
                              (lsu_pkt_dc2.half & (start_addr_dc2[0] == 1'b0)) |
                              lsu_pkt_dc2.by;

   assign non_dccm_access_ok = (~(|{pt.DATA_ACCESS_ENABLE0,pt.DATA_ACCESS_ENABLE1,pt.DATA_ACCESS_ENABLE2,pt.DATA_ACCESS_ENABLE3,pt.DATA_ACCESS_ENABLE4,pt.DATA_ACCESS_ENABLE5,pt.DATA_ACCESS_ENABLE6,pt.DATA_ACCESS_ENABLE7})) |
                               (((pt.DATA_ACCESS_ENABLE0 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK0)) == (pt.DATA_ACCESS_ADDR0 | pt.DATA_ACCESS_MASK0)) |
                                 (pt.DATA_ACCESS_ENABLE1 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK1)) == (pt.DATA_ACCESS_ADDR1 | pt.DATA_ACCESS_MASK1)) |
                                 (pt.DATA_ACCESS_ENABLE2 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK2)) == (pt.DATA_ACCESS_ADDR2 | pt.DATA_ACCESS_MASK2)) |
                                 (pt.DATA_ACCESS_ENABLE3 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK3)) == (pt.DATA_ACCESS_ADDR3 | pt.DATA_ACCESS_MASK3)) |
                                 (pt.DATA_ACCESS_ENABLE4 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK4)) == (pt.DATA_ACCESS_ADDR4 | pt.DATA_ACCESS_MASK4)) |
                                 (pt.DATA_ACCESS_ENABLE5 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK5)) == (pt.DATA_ACCESS_ADDR5 | pt.DATA_ACCESS_MASK5)) |
                                 (pt.DATA_ACCESS_ENABLE6 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK6)) == (pt.DATA_ACCESS_ADDR6 | pt.DATA_ACCESS_MASK6)) |
                                 (pt.DATA_ACCESS_ENABLE7 & ((start_addr_dc2[31:0] | pt.DATA_ACCESS_MASK7)) == (pt.DATA_ACCESS_ADDR7 | pt.DATA_ACCESS_MASK7)))   &
                                ((pt.DATA_ACCESS_ENABLE0 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK0)) == (pt.DATA_ACCESS_ADDR0 | pt.DATA_ACCESS_MASK0)) |
                                 (pt.DATA_ACCESS_ENABLE1 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK1)) == (pt.DATA_ACCESS_ADDR1 | pt.DATA_ACCESS_MASK1)) |
                                 (pt.DATA_ACCESS_ENABLE2 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK2)) == (pt.DATA_ACCESS_ADDR2 | pt.DATA_ACCESS_MASK2)) |
                                 (pt.DATA_ACCESS_ENABLE3 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK3)) == (pt.DATA_ACCESS_ADDR3 | pt.DATA_ACCESS_MASK3)) |
                                 (pt.DATA_ACCESS_ENABLE4 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK4)) == (pt.DATA_ACCESS_ADDR4 | pt.DATA_ACCESS_MASK4)) |
                                 (pt.DATA_ACCESS_ENABLE5 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK5)) == (pt.DATA_ACCESS_ADDR5 | pt.DATA_ACCESS_MASK5)) |
                                 (pt.DATA_ACCESS_ENABLE6 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK6)) == (pt.DATA_ACCESS_ADDR6 | pt.DATA_ACCESS_MASK6)) |
                                 (pt.DATA_ACCESS_ENABLE7 & ((end_addr_dc2[31:0]   | pt.DATA_ACCESS_MASK7)) == (pt.DATA_ACCESS_ADDR7 | pt.DATA_ACCESS_MASK7))));

                  
   assign regpred_access_fault_dc2  = (start_addr_dccm_or_pic ^ base_reg_dccm_or_pic);                               assign picm_access_fault_dc2     = (addr_in_pic_dc2 & ((start_addr_dc2[1:0] != 2'b0) | ~lsu_pkt_dc2.word));       assign amo_access_fault_dc2      =  (lsu_pkt_dc2.atomic & (start_addr_dc2[1:0] != 2'b0))                     |                                        (lsu_pkt_dc2.valid & lsu_pkt_dc2.atomic & ~addr_in_dccm_dc2);

   if (pt.DCCM_ENABLE & (pt.DCCM_REGION == pt.PIC_REGION)) begin
      assign unmapped_access_fault_dc2 = ((start_addr_in_dccm_region_dc2 & ~(start_addr_in_dccm_dc2 | start_addr_in_pic_dc2)) |                                           (end_addr_in_dccm_region_dc2 & ~(end_addr_in_dccm_dc2 | end_addr_in_pic_dc2))         |                                           (start_addr_in_dccm_dc2 & end_addr_in_pic_dc2)                                        |                                           (start_addr_in_pic_dc2  & end_addr_in_dccm_dc2));                                               assign mpu_access_fault_dc2      = (~start_addr_in_dccm_region_dc2 & ~non_dccm_access_ok);                                     end else begin
      assign unmapped_access_fault_dc2 = ((start_addr_in_dccm_region_dc2 & ~start_addr_in_dccm_dc2)                            |                                           (end_addr_in_dccm_region_dc2 & ~end_addr_in_dccm_dc2)                                  |                                           (start_addr_in_pic_region_dc2 & ~start_addr_in_pic_dc2)                                |                                           (end_addr_in_pic_region_dc2 & ~end_addr_in_pic_dc2));                                            assign mpu_access_fault_dc2      = (~start_addr_in_pic_region_dc2 & ~start_addr_in_dccm_region_dc2 & ~non_dccm_access_ok);      end

   assign access_fault_dc2 = (unmapped_access_fault_dc2 | mpu_access_fault_dc2 | picm_access_fault_dc2 |
                              regpred_access_fault_dc2 | amo_access_fault_dc2) & lsu_pkt_dc2.valid & ~lsu_pkt_dc2.dma;
   assign access_fault_mscause_dc2[3:0] = unmapped_access_fault_dc2 ? 4'h2 : mpu_access_fault_dc2 ? 4'h3 : regpred_access_fault_dc2 ? 4'h5 : picm_access_fault_dc2 ? 4'h6 : amo_access_fault_dc2 ? 4'h7 : 4'h0;

            assign regcross_misaligned_fault_dc2 = (start_addr_dc2[31:28] != end_addr_dc2[31:28]);
   assign sideeffect_misaligned_fault_dc2 = (is_sideeffects_dc2 & ~is_aligned_dc2);
   assign misaligned_fault_dc2 = (regcross_misaligned_fault_dc2 | (sideeffect_misaligned_fault_dc2 & addr_external_dc2)) & lsu_pkt_dc2.valid & ~lsu_pkt_dc2.dma & ~lsu_pkt_dc2.atomic;
   assign misaligned_fault_mscause_dc2[3:0] = regcross_misaligned_fault_dc2 ? 4'h2 : sideeffect_misaligned_fault_dc2 ? 4'h1 : 4'h0;
   assign exc_mscause_dc2[3:0] = misaligned_fault_dc2 ? misaligned_fault_mscause_dc2[3:0] : access_fault_mscause_dc2[3:0];

      assign fir_dccm_access_error_dc2    = ((start_addr_in_dccm_region_dc2 & ~start_addr_in_dccm_dc2) |
                                          (end_addr_in_dccm_region_dc2   & ~end_addr_in_dccm_dc2)) & lsu_pkt_dc2.valid & lsu_pkt_dc2.fast_int;
   assign fir_nondccm_access_error_dc2 = ~(start_addr_in_dccm_region_dc2 & end_addr_in_dccm_region_dc2) & lsu_pkt_dc2.valid & lsu_pkt_dc2.fast_int;

rvdff #(.WIDTH(1)) start_addr_in_dccm_dc2ff       (.din(start_addr_in_dccm_dc1),        .dout(start_addr_in_dccm_dc2),        .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) end_addr_in_dccm_dc2ff         (.din(end_addr_in_dccm_dc1),          .dout(end_addr_in_dccm_dc2),          .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) start_addr_in_pic_dc2ff        (.din(start_addr_in_pic_dc1),         .dout(start_addr_in_pic_dc2),         .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) end_addr_in_pic_dc2ff          (.din(end_addr_in_pic_dc1),           .dout(end_addr_in_pic_dc2),           .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) start_addr_in_dccm_region_dc2ff(.din(start_addr_in_dccm_region_dc1), .dout(start_addr_in_dccm_region_dc2), .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) start_addr_in_pic_region_dc2ff (.din(start_addr_in_pic_region_dc1),  .dout(start_addr_in_pic_region_dc2),  .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) end_addr_in_dccm_region_dc2ff  (.din(end_addr_in_dccm_region_dc1),   .dout(end_addr_in_dccm_region_dc2),   .clk(lsu_c2_dc2_clk), .*);
   rvdff #(.WIDTH(1)) end_addr_in_pic_region_dc2ff   (.din(end_addr_in_pic_region_dc1),    .dout(end_addr_in_pic_region_dc2),    .clk(lsu_c2_dc2_clk), .*);
   rvdffe #(.WIDTH(32)) rs1_dc2ff                    (.din(rs1_dc1[31:0]),                 .dout(rs1_dc2[31:0]),                 .en(lsu_pkt_dc1.valid), .*);
   rvdff #(.WIDTH(1)) is_sideeffects_dc3ff           (.din(is_sideeffects_dc2),            .dout(is_sideeffects_dc3),            .clk(lsu_c2_dc3_clk), .*);


endmodule 