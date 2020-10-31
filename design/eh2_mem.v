
module eh2_mem
#(
`include "eh2_param.vh"
)
(
   input wire clk,
   input wire rst_l,
   input wire dccm_clk_override,
   input wire icm_clk_override,
   input wire dec_tlu_core_ecc_disable,

      input wire dccm_wren,
   input wire dccm_rden,
   input wire [pt.DCCM_BITS-1:0]  dccm_wr_addr_lo,
   input wire [pt.DCCM_BITS-1:0]  dccm_wr_addr_hi,
   input wire [pt.DCCM_BITS-1:0]  dccm_rd_addr_lo,
   input wire [pt.DCCM_BITS-1:0]  dccm_rd_addr_hi,
   input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo,
   input wire [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi,

   output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo,
   output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi,


   
   input wire [pt.ICCM_BITS-1:1]  iccm_rw_addr,
   input wire [pt.NUM_THREADS-1:0]iccm_buf_correct_ecc_thr,               input wire iccm_correction_state,                  input wire iccm_stop_fetch,                        input wire iccm_corr_scnd_fetch,                

   input wire ifc_select_tid_f1,
   input wire iccm_wren,
   input wire iccm_rden,
   input wire [2:0]   iccm_wr_size,
   input wire [77:0]  iccm_wr_data,

   output logic [63:0]  iccm_rd_data,
   output logic [116:0] iccm_rd_data_ecc,
      input wire [31:1]  ic_rw_addr,
   input wire [pt.ICACHE_NUM_WAYS-1:0]   ic_tag_valid,
   input wire [pt.ICACHE_NUM_WAYS-1:0]          ic_wr_en  ,            input wire ic_rd_en,
   input wire [63:0]  ic_premux_data,        input wire ic_sel_premux_data, 

   input wire [pt.ICACHE_BANKS_WAY-1:0] [70:0]               ic_wr_data,              output logic [63:0]               ic_rd_data ,             output logic [70:0]               ic_debug_rd_data ,       output logic [25:0]               ictag_debug_rd_data,     input wire [70:0]               ic_debug_wr_data,     

   input wire [pt.ICACHE_INDEX_HI:3]           ic_debug_addr,         input wire ic_debug_rd_en,        input wire ic_debug_wr_en,        input wire ic_debug_tag_array,    input wire [pt.ICACHE_NUM_WAYS-1:0]        ic_debug_way,       

   output  logic [pt.ICACHE_BANKS_WAY-1:0]       ic_eccerr,
   output  logic [pt.ICACHE_BANKS_WAY-1:0]       ic_parerr,


   output logic [pt.ICACHE_NUM_WAYS-1:0]   ic_rd_hit,
   output logic         ic_tag_perr,        

   input wire scan_mode

);


      if (pt.DCCM_ENABLE == 1) begin: Gen_dccm_enable
      eh2_lsu_dccm_mem #(.pt(pt)) dccm (
         .clk_override(dccm_clk_override),

      );
   end else begin: Gen_dccm_disable
      assign dccm_rd_data_lo = '0;
      assign dccm_rd_data_hi = '0;
   end

if (pt.ICACHE_ENABLE == 1) begin : icache
   eh2_ifu_ic_mem #(.pt(pt)) icm  (
      .clk_override(icm_clk_override),

   );
end
else begin
   assign   ic_rd_hit[3:0] = '0;
   assign   ic_tag_perr    = 'd0 ;
   assign   ic_rd_data  = 'd0 ;
   assign   ictag_debug_rd_data  = 'd0 ;
end

if (pt.ICCM_ENABLE == 1) begin : iccm
   eh2_ifu_iccm_mem  #(.pt(pt)) iccm (.*,
                  .clk_override(icm_clk_override),
                  .iccm_rw_addr(iccm_rw_addr[pt.ICCM_BITS-1:1]),
                  .iccm_rd_data(iccm_rd_data[63:0])
                   );
end
else  begin
   assign iccm_rd_data     = 'd0 ;
   assign iccm_rd_data_ecc = 'd0 ;
end



endmodule
