


module eh2_lsu_clkdomain
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(
   input wire clk,                                  input wire free_clk,                             input wire rst_l,                             
      input wire clk_override,                         input wire addr_in_dccm_dc2,                     input wire addr_in_pic_dc2,                      input wire dma_dccm_req,                         input wire dma_mem_write,                        input wire store_stbuf_reqvld_dc5,               input wire [pt.NUM_THREADS-1:0]lr_vld,                            

   input wire stbuf_reqvld_any,                     input wire stbuf_reqvld_flushed_any,             input wire lsu_busreq_dc5,                       input wire [pt.NUM_THREADS-1:0] lsu_bus_buffer_pend_any,              input wire [pt.NUM_THREADS-1:0] lsu_bus_buffer_empty_any,             input wire [pt.NUM_THREADS-1:0] lsu_stbuf_empty_any,               
   input wire lsu_bus_clk_en,               
   input eh2_lsu_pkt_t  lsu_p,                                input eh2_lsu_pkt_t  lsu_pkt_dc1,                          input eh2_lsu_pkt_t  lsu_pkt_dc2,                          input eh2_lsu_pkt_t  lsu_pkt_dc3,                          input eh2_lsu_pkt_t  lsu_pkt_dc4,                          input eh2_lsu_pkt_t  lsu_pkt_dc5,                       
      output logic     lsu_c1_dc1_clk,                       output logic     lsu_c1_dc2_clk,                       output logic     lsu_c1_dc3_clk,                       output logic     lsu_c1_dc4_clk,                       output logic     lsu_c1_dc5_clk,                    
   output logic     lsu_c2_dc1_clk,                       output logic     lsu_c2_dc2_clk,                       output logic     lsu_c2_dc3_clk,                       output logic     lsu_c2_dc4_clk,                       output logic     lsu_c2_dc5_clk,                    
   output logic     lsu_store_c1_dc1_clk,                 output logic     lsu_store_c1_dc2_clk,                 output logic     lsu_store_c1_dc3_clk,              

   output logic     lsu_dccm_c1_dc3_clk,                  output logic     lsu_pic_c1_dc3_clk,                
   output logic     lsu_stbuf_c1_clk,
   output logic [pt.NUM_THREADS-1:0]  lsu_bus_obuf_c1_clk,                  output logic [pt.NUM_THREADS-1:0]  lsu_bus_ibuf_c1_clk,                  output logic [pt.NUM_THREADS-1:0]  lsu_bus_buf_c1_clk,                   output logic     lsu_busm_clk,                      
   output logic     lsu_free_c2_clk,

   input wire scan_mode
);

wire lsu_c1_dc1_clken;
wire lsu_c1_dc2_clken;
wire lsu_c1_dc3_clken;
wire lsu_c1_dc4_clken;
wire lsu_c1_dc5_clken;
wire lsu_c2_dc1_clken;
wire lsu_c2_dc2_clken;
wire lsu_c2_dc3_clken;
wire lsu_c2_dc4_clken;
wire lsu_c2_dc5_clken;
reg lsu_c1_dc1_clken_q;
reg lsu_c1_dc2_clken_q;
reg lsu_c1_dc3_clken_q;
reg lsu_c1_dc4_clken_q;
reg lsu_c1_dc5_clken_q;
wire lsu_store_c1_dc1_clken;
wire lsu_store_c1_dc2_clken;
wire lsu_store_c1_dc3_clken;

   wire lsu_stbuf_c1_clken;
wire [pt.NUM_THREADS-1:0] lsu_bus_ibuf_c1_clken;
wire [pt.NUM_THREADS-1:0] lsu_bus_obuf_c1_clken;
wire [pt.NUM_THREADS-1:0] lsu_bus_buf_c1_clken;

wire lsu_dccm_c1_dc3_clken;
wire lsu_pic_c1_dc3_clken;

wire lsu_free_c1_clken;
reg lsu_free_c1_clken_q;
wire lsu_free_c2_clken;

         
      assign lsu_c1_dc1_clken = lsu_p.valid | clk_override;
   assign lsu_c1_dc2_clken = lsu_pkt_dc1.valid | dma_dccm_req | lsu_c1_dc1_clken_q | clk_override;
   assign lsu_c1_dc3_clken = lsu_pkt_dc2.valid | lsu_c1_dc2_clken_q | clk_override;
   assign lsu_c1_dc4_clken = lsu_pkt_dc3.valid | lsu_c1_dc3_clken_q | clk_override;
   assign lsu_c1_dc5_clken = lsu_pkt_dc4.valid | lsu_c1_dc4_clken_q | clk_override;

   assign lsu_c2_dc1_clken = lsu_c1_dc1_clken | lsu_c1_dc1_clken_q | clk_override;
   assign lsu_c2_dc2_clken = lsu_c1_dc2_clken | lsu_c1_dc2_clken_q | clk_override;
   assign lsu_c2_dc3_clken = lsu_c1_dc3_clken | lsu_c1_dc3_clken_q | clk_override;
   assign lsu_c2_dc4_clken = lsu_c1_dc4_clken | lsu_c1_dc4_clken_q | clk_override;
   assign lsu_c2_dc5_clken = lsu_c1_dc5_clken | lsu_c1_dc5_clken_q | clk_override;

   assign lsu_store_c1_dc1_clken = ((lsu_c1_dc1_clken & (lsu_p.store | lsu_p.atomic )) | clk_override);
   assign lsu_store_c1_dc2_clken = ((lsu_c1_dc2_clken & (lsu_pkt_dc1.store | dma_mem_write | lsu_pkt_dc1.atomic)) | clk_override);
   assign lsu_store_c1_dc3_clken = ((lsu_c1_dc3_clken & (lsu_pkt_dc2.store | lsu_pkt_dc2.atomic)) | clk_override);


   assign lsu_stbuf_c1_clken = store_stbuf_reqvld_dc5 | stbuf_reqvld_any | stbuf_reqvld_flushed_any | clk_override;

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenBufClkEn
      assign lsu_bus_ibuf_c1_clken[i] = (lsu_busreq_dc5 & (lsu_pkt_dc5.tid == i)) | clk_override;
      assign lsu_bus_obuf_c1_clken[i] = (lsu_bus_buffer_pend_any[i] | (lsu_busreq_dc5 & (lsu_pkt_dc5.tid == i)) | clk_override) & lsu_bus_clk_en;
      assign lsu_bus_buf_c1_clken[i]  = ~lsu_bus_buffer_empty_any[i] | (lsu_busreq_dc5 & (lsu_pkt_dc5.tid == i)) | clk_override;
     rvoclkhdr lsu_bus_ibuf_c1_cgc ( .en(lsu_bus_ibuf_c1_clken[i]), .l1clk(lsu_bus_ibuf_c1_clk[i]), .* );
      rvclkhdr  lsu_bus_obuf_c1_cgc ( .en(lsu_bus_obuf_c1_clken[i]), .l1clk(lsu_bus_obuf_c1_clk[i]), .* );
      rvoclkhdr lsu_bus_buf_c1_cgc  ( .en(lsu_bus_buf_c1_clken[i]),  .l1clk(lsu_bus_buf_c1_clk[i]), .* );

   end

   assign lsu_dccm_c1_dc3_clken = ((lsu_c1_dc3_clken & addr_in_dccm_dc2) | clk_override);
   assign lsu_pic_c1_dc3_clken  = ((lsu_c1_dc3_clken & addr_in_pic_dc2) | clk_override);

   assign lsu_free_c1_clken =  lsu_p.valid | lsu_pkt_dc1.valid | lsu_pkt_dc2.valid | lsu_pkt_dc3.valid | lsu_pkt_dc4.valid | lsu_pkt_dc5.valid | (|lr_vld[pt.NUM_THREADS-1:0]) |
                              ~(&lsu_bus_buffer_empty_any[pt.NUM_THREADS-1:0]) | ~(&lsu_stbuf_empty_any[pt.NUM_THREADS-1:0]) | clk_override;
   assign lsu_free_c2_clken = lsu_free_c1_clken | lsu_free_c1_clken_q | clk_override;

   rvdff #(1) lsu_free_c1_clkenff (.din(lsu_free_c1_clken), .dout(lsu_free_c1_clken_q), .clk(free_clk), .*);

   rvdff #(1) lsu_c1_dc1_clkenff (.din(lsu_c1_dc1_clken), .dout(lsu_c1_dc1_clken_q), .clk(free_clk), .*);
   rvdff #(1) lsu_c1_dc2_clkenff (.din(lsu_c1_dc2_clken), .dout(lsu_c1_dc2_clken_q), .clk(free_clk), .*);
   rvdff #(1) lsu_c1_dc3_clkenff (.din(lsu_c1_dc3_clken), .dout(lsu_c1_dc3_clken_q), .clk(free_clk), .*);
   rvdff #(1) lsu_c1_dc4_clkenff (.din(lsu_c1_dc4_clken), .dout(lsu_c1_dc4_clken_q), .clk(free_clk), .*);
   rvdff #(1) lsu_c1_dc5_clkenff (.din(lsu_c1_dc5_clken), .dout(lsu_c1_dc5_clken_q), .clk(free_clk), .*);

   // Clock Headers
   rvoclkhdr lsu_c1dc1_cgc ( .en(lsu_c1_dc1_clken), .l1clk(lsu_c1_dc1_clk), .* );
   rvoclkhdr lsu_c1dc2_cgc ( .en(lsu_c1_dc2_clken), .l1clk(lsu_c1_dc2_clk), .* );
   rvoclkhdr lsu_c1dc3_cgc ( .en(lsu_c1_dc3_clken), .l1clk(lsu_c1_dc3_clk), .* );
   rvoclkhdr lsu_c1dc4_cgc ( .en(lsu_c1_dc4_clken), .l1clk(lsu_c1_dc4_clk), .* );
   rvoclkhdr lsu_c1dc5_cgc ( .en(lsu_c1_dc5_clken), .l1clk(lsu_c1_dc5_clk), .* );

   rvoclkhdr lsu_c2dc1_cgc ( .en(lsu_c2_dc1_clken), .l1clk(lsu_c2_dc1_clk), .* );
   rvoclkhdr lsu_c2dc2_cgc ( .en(lsu_c2_dc2_clken), .l1clk(lsu_c2_dc2_clk), .* );
   rvoclkhdr lsu_c2dc3_cgc ( .en(lsu_c2_dc3_clken), .l1clk(lsu_c2_dc3_clk), .* );
   rvoclkhdr lsu_c2dc4_cgc ( .en(lsu_c2_dc4_clken), .l1clk(lsu_c2_dc4_clk), .* );
   rvoclkhdr lsu_c2dc5_cgc ( .en(lsu_c2_dc5_clken), .l1clk(lsu_c2_dc5_clk), .* );

   rvoclkhdr lsu_store_c1dc1_cgc (.en(lsu_store_c1_dc1_clken), .l1clk(lsu_store_c1_dc1_clk), .*);
   rvoclkhdr lsu_store_c1dc2_cgc (.en(lsu_store_c1_dc2_clken), .l1clk(lsu_store_c1_dc2_clk), .*);
   rvoclkhdr lsu_store_c1dc3_cgc (.en(lsu_store_c1_dc3_clken), .l1clk(lsu_store_c1_dc3_clk), .*);

   rvoclkhdr lsu_stbuf_c1_cgc ( .en(lsu_stbuf_c1_clken), .l1clk(lsu_stbuf_c1_clk), .* );

   rvclkhdr lsu_busm_cgc (.en(lsu_bus_clk_en), .l1clk(lsu_busm_clk), .*);

   rvoclkhdr lsu_dccm_c1dc3_cgc (.en(lsu_dccm_c1_dc3_clken), .l1clk(lsu_dccm_c1_dc3_clk), .*);
   rvoclkhdr lsu_pic_c1dc3_cgc (.en(lsu_pic_c1_dc3_clken), .l1clk(lsu_pic_c1_dc3_clk), .*);

   rvoclkhdr lsu_free_cgc (.en(lsu_free_c2_clken), .l1clk(lsu_free_c2_clk), .*);

endmodule

