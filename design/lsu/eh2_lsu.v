

module eh2_lsu
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)(

   input wire [31:0]                      i0_result_e4_eff,    input wire [31:0]                      i1_result_e4_eff,    input wire [31:0]                      i0_result_e2,     
   input wire [pt.NUM_THREADS-1:0]        flush_final_e3,               input wire [pt.NUM_THREADS-1:0]        i0_flush_final_e3,            input wire [pt.NUM_THREADS-1:0]        dec_tlu_flush_lower_wb,       input wire dec_tlu_i0_kill_writeb_wb,    input wire dec_tlu_i1_kill_writeb_wb,    input wire [pt.NUM_THREADS-1:0]        dec_tlu_lr_reset_wb,
   input wire [pt.NUM_THREADS-1:0]        dec_tlu_force_halt,

      input wire dec_tlu_external_ldfwd_disable,        input wire dec_tlu_wb_coalescing_disable,         input wire dec_tlu_sideeffect_posted_disable,     input wire dec_tlu_core_ecc_disable,           
   input wire [31:0]                      exu_lsu_rs1_d,         input wire [31:0]                      exu_lsu_rs2_d,         input wire [11:0]                      dec_lsu_offset_d,   
   input                                   eh2_lsu_pkt_t lsu_p,        input wire [31:0]                      dec_tlu_mrac_ff,     
   output logic [31:0]                     lsu_result_dc3,         output logic [31:0]                     lsu_result_corr_dc4,    output logic                            lsu_fastint_stall_any,    output logic                            lsu_sc_success_dc5,  
   output logic [pt.NUM_THREADS-1:0]       lsu_store_stall_any,    output logic [pt.NUM_THREADS-1:0]       lsu_load_stall_any,     output logic [pt.NUM_THREADS-1:0]       lsu_amo_stall_any,      output logic [pt.NUM_THREADS-1:0]       lsu_idle_any,        
   output logic [31:1]                     lsu_fir_addr,           output logic [1:0]                      lsu_fir_error,       
   output eh2_lsu_error_pkt_t             lsu_error_pkt_dc3,                output logic                            lsu_single_ecc_error_incr,        output logic [pt.NUM_THREADS-1:0]       lsu_imprecise_error_load_any,     output logic [pt.NUM_THREADS-1:0]       lsu_imprecise_error_store_any,    output logic [pt.NUM_THREADS-1:0][31:0] lsu_imprecise_error_addr_any,  
      output logic                                lsu_nonblock_load_valid_dc1,       output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_tag_dc1,         output logic                                lsu_nonblock_load_inv_dc2,         output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc2,
   output logic                                lsu_nonblock_load_inv_dc5,         output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_inv_tag_dc5,     output logic                                lsu_nonblock_load_data_valid,      output logic                                lsu_nonblock_load_data_error,      output logic                               lsu_nonblock_load_data_tid,         output logic [pt.LSU_NUM_NBLOAD_WIDTH-1:0]  lsu_nonblock_load_data_tag,        output logic [31:0]                         lsu_nonblock_load_data,         
   output logic [pt.NUM_THREADS-1:0]       lsu_pmu_load_external_dc3,         output logic [pt.NUM_THREADS-1:0]       lsu_pmu_store_external_dc3,        output logic [pt.NUM_THREADS-1:0]       lsu_pmu_misaligned_dc3,            output logic [pt.NUM_THREADS-1:0]       lsu_pmu_bus_trxn,                  output logic [pt.NUM_THREADS-1:0]       lsu_pmu_bus_misaligned,            output logic [pt.NUM_THREADS-1:0]       lsu_pmu_bus_error,                 output logic [pt.NUM_THREADS-1:0]       lsu_pmu_bus_busy,               
   output logic [31:0]                     lsu_rs1_dc1,

      input eh2_trigger_pkt_t [pt.NUM_THREADS-1:0][3:0] trigger_pkt_any,    output logic [3:0]                      lsu_trigger_match_dc4,                    
      output logic                            dccm_wren,          output logic                            dccm_rden,          output logic [pt.DCCM_BITS-1:0]         dccm_wr_addr_lo,    output logic [pt.DCCM_BITS-1:0]         dccm_wr_addr_hi,    output logic [pt.DCCM_BITS-1:0]         dccm_rd_addr_lo,    output logic [pt.DCCM_BITS-1:0]         dccm_rd_addr_hi,    output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo,    output logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi, 
   input wire [pt.DCCM_FDATA_WIDTH-1:0]   dccm_rd_data_lo,    input wire [pt.DCCM_FDATA_WIDTH-1:0]   dccm_rd_data_hi, 
      output logic                            picm_wren,           output logic                            picm_rden,           output logic                            picm_mken,           output logic                            picm_rd_thr,         output logic [31:0]                     picm_rdaddr,         output logic [31:0]                     picm_wraddr,         output logic [31:0]                     picm_wr_data,        input wire [31:0]                      picm_rd_data,     
         output logic                            lsu_axi_awvalid,
   input wire lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_awid,
   output logic [31:0]                     lsu_axi_awaddr,
   output logic [3:0]                      lsu_axi_awregion,
   output logic [7:0]                      lsu_axi_awlen,
   output logic [2:0]                      lsu_axi_awsize,
   output logic [1:0]                      lsu_axi_awburst,
   output logic                            lsu_axi_awlock,
   output logic [3:0]                      lsu_axi_awcache,
   output logic [2:0]                      lsu_axi_awprot,
   output logic [3:0]                      lsu_axi_awqos,

   output logic                            lsu_axi_wvalid,
   input wire lsu_axi_wready,
   output logic [63:0]                     lsu_axi_wdata,
   output logic [7:0]                      lsu_axi_wstrb,
   output logic                            lsu_axi_wlast,

   input wire lsu_axi_bvalid,
   output logic                            lsu_axi_bready,
   input wire [1:0]                      lsu_axi_bresp,
   input wire [pt.LSU_BUS_TAG-1:0]       lsu_axi_bid,

      output logic                            lsu_axi_arvalid,
   input wire lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_arid,
   output logic [31:0]                     lsu_axi_araddr,
   output logic [3:0]                      lsu_axi_arregion,
   output logic [7:0]                      lsu_axi_arlen,
   output logic [2:0]                      lsu_axi_arsize,
   output logic [1:0]                      lsu_axi_arburst,
   output logic                            lsu_axi_arlock,
   output logic [3:0]                      lsu_axi_arcache,
   output logic [2:0]                      lsu_axi_arprot,
   output logic [3:0]                      lsu_axi_arqos,

   input wire lsu_axi_rvalid,
   output logic                            lsu_axi_rready,
   input wire [pt.LSU_BUS_TAG-1:0]       lsu_axi_rid,
   input wire [63:0]                     lsu_axi_rdata,
   input wire [1:0]                      lsu_axi_rresp,
   input wire lsu_axi_rlast,

   input wire lsu_bus_clk_en,    
      input wire dma_dccm_req,          input wire dma_dccm_spec_req,     input wire dma_mem_addr_in_dccm,      input wire [2:0]                       dma_mem_tag,           input wire [31:0]                      dma_mem_addr,          input wire [2:0]                       dma_mem_sz,            input wire dma_mem_write,         input wire [63:0]                      dma_mem_wdata,      
   output logic                            dccm_dma_rvalid,        output logic                            dccm_dma_ecc_error,     output logic [2:0]                      dccm_dma_rtag,          output logic [63:0]                     dccm_dma_rdata,         output logic                            dccm_ready,          
   input wire clk_override,           input wire scan_mode,              input wire clk,
   input wire free_clk,
   input wire rst_l

   );

   reg [31:0] lsu_addr_dc1;
   reg        lsu_dccm_rden_dc3;
   reg [31:0] store_data_dc3;
   reg [31:0] store_data_pre_dc3;
   reg [31:0] store_ecc_data_hi_dc3;             reg [31:0] store_ecc_data_lo_dc3;
   reg [pt.DCCM_DATA_WIDTH-1:0] sec_data_hi_dc3;
   reg [pt.DCCM_DATA_WIDTH-1:0] sec_data_lo_dc3;
   reg        disable_ecc_check_lo_dc3;
   reg        disable_ecc_check_hi_dc3;

reg [pt.DCCM_DATA_WIDTH-1:0] sec_data_hi_dc5;
reg [pt.DCCM_DATA_WIDTH-1:0] sec_data_lo_dc5;

reg ld_single_ecc_error_dc3;
reg ld_single_ecc_error_dc5;
reg ld_single_ecc_error_dc5_ff;
reg ld_single_ecc_error_lo_dc5_ff;
reg ld_single_ecc_error_hi_dc5_ff;
reg single_ecc_error_hi_dc3;
reg single_ecc_error_lo_dc3;
reg single_ecc_error_hi_dc4;
reg single_ecc_error_lo_dc4;
reg single_ecc_error_hi_dc5;
reg single_ecc_error_lo_dc5;
reg lsu_single_ecc_error_dc3;
reg lsu_single_ecc_error_dc5;
reg lsu_double_ecc_error_dc3;
reg lsu_double_ecc_error_dc5;
   reg        access_fault_dc3;
   reg        misaligned_fault_dc3;

   reg [31:0] dccm_data_hi_dc3;
   reg [31:0] dccm_data_lo_dc3;
   reg [31:0] dccm_datafn_hi_dc5;
   reg [31:0] dccm_datafn_lo_dc5;
   reg [6:0]  dccm_data_ecc_hi_dc3;
   reg [6:0]  dccm_data_ecc_lo_dc3;
reg [63:0] store_data_ext_dc3;
reg [63:0] store_data_ext_dc4;
reg [63:0] store_data_ext_dc5;

   reg [31:0] lsu_dccm_data_dc3;
   reg [31:0] lsu_dccm_data_corr_dc3;
   reg [31:0] picm_mask_data_dc3;
   reg [31:0] picm_rd_data_dc3;

reg [31:0] lsu_addr_dc2;
reg [31:0] lsu_addr_dc3;
reg [31:0] lsu_addr_dc4;
reg [31:0] lsu_addr_dc5;
wire [31:0] end_addr_dc1;
reg [31:0] end_addr_dc2;
reg [31:0] end_addr_dc3;
reg [31:0] end_addr_dc4;
reg [31:0] end_addr_dc5;
   reg        core_ldst_dual_dc1;


   eh2_lsu_pkt_t  lsu_pkt_dc1_pre, lsu_pkt_dc1, lsu_pkt_dc2, lsu_pkt_dc3, lsu_pkt_dc4, lsu_pkt_dc5;

      wire        store_stbuf_reqvld_dc5;
   reg        lsu_commit_dc5;

reg addr_in_dccm_region_dc1;
reg addr_in_dccm_dc1;
reg addr_in_dccm_dc2;
reg addr_in_dccm_dc3;
reg addr_in_dccm_dc4;
reg addr_in_dccm_dc5;
reg addr_in_pic_dc1;
reg addr_in_pic_dc2;
reg addr_in_pic_dc3;
reg addr_in_pic_dc4;
reg addr_in_pic_dc5;
reg addr_external_dc1;
reg addr_external_dc3;

   reg                          stbuf_reqvld_any;
   reg                          stbuf_reqvld_flushed_any;
   reg [pt.LSU_SB_BITS-1:0]     stbuf_addr_any;
   reg [pt.DCCM_DATA_WIDTH-1:0] stbuf_data_any;

   wire                          lsu_cmpen_dc2;
   reg [pt.DCCM_DATA_WIDTH-1:0] stbuf_fwddata_hi_dc3;
   reg [pt.DCCM_DATA_WIDTH-1:0] stbuf_fwddata_lo_dc3;
   reg [pt.DCCM_BYTE_WIDTH-1:0] stbuf_fwdbyteen_hi_dc3;
   reg [pt.DCCM_BYTE_WIDTH-1:0] stbuf_fwdbyteen_lo_dc3;

   reg                          picm_fwd_en_dc2;
   reg [31:0]                   picm_fwd_data_dc2;

   reg                       lsu_stbuf_commit_any;
   reg [pt.NUM_THREADS-1:0]  lsu_stbuf_empty_any;      reg [pt.NUM_THREADS-1:0]  lsu_stbuf_full_any;

       reg        lsu_busreq_dc5;
   wire        lsu_busreq_dc1;
   reg [pt.NUM_THREADS-1:0]  lsu_bus_idle_any;
   reg [pt.NUM_THREADS-1:0]  lsu_bus_buffer_pend_any;
   reg [pt.NUM_THREADS-1:0]  lsu_bus_buffer_empty_any;
   reg [pt.NUM_THREADS-1:0]  lsu_bus_buffer_full_any;
   reg [31:0] bus_read_data_dc3;

reg [pt.NUM_THREADS-1:0] flush_dc2_up;
reg [pt.NUM_THREADS-1:0] flush_dc3;
reg [pt.NUM_THREADS-1:0] flush_dc4;
reg [pt.NUM_THREADS-1:0] flush_dc5;
reg [pt.NUM_THREADS-1:0] is_sideeffects_dc2;
reg [pt.NUM_THREADS-1:0] is_sideeffects_dc3;
   wire        ldst_nodma_dc2todc5;
wire dma_dccm_wen;
wire dma_dccm_spec_wen;
wire dma_pic_wen;
wire [2:0] dma_mem_tag_dc1;
reg [2:0] dma_mem_tag_dc2;
reg [2:0] dma_mem_tag_dc3;
wire [31:0] dma_start_addr_dc1;
wire [31:0] dma_end_addr_dc1;
wire [31:0] dma_dccm_wdata_hi;
wire [31:0] dma_dccm_wdata_lo;

reg lsu_c1_dc1_clk;
reg lsu_c1_dc2_clk;
reg lsu_c1_dc3_clk;
reg lsu_c1_dc4_clk;
reg lsu_c1_dc5_clk;
reg lsu_c2_dc1_clk;
reg lsu_c2_dc2_clk;
reg lsu_c2_dc3_clk;
reg lsu_c2_dc4_clk;
reg lsu_c2_dc5_clk;

reg lsu_store_c1_dc1_clk;
reg lsu_store_c1_dc2_clk;
reg lsu_store_c1_dc3_clk;
reg lsu_dccm_c1_dc3_clk;
reg lsu_pic_c1_dc3_clk;
   reg        lsu_stbuf_c1_clk;
   reg        lsu_free_c2_clk;

reg [pt.NUM_THREADS-1:0] lsu_bus_ibuf_c1_clk;
reg [pt.NUM_THREADS-1:0] lsu_bus_obuf_c1_clk;
reg [pt.NUM_THREADS-1:0] lsu_bus_buf_c1_clk;
   reg                      lsu_busm_clk;

   reg [31:0]                 amo_data_dc3;
   reg [pt.NUM_THREADS-1:0]   lr_vld;            
wire lsu_raw_fwd_lo_dc3;
wire lsu_raw_fwd_hi_dc3;
reg lsu_raw_fwd_lo_dc4;
reg lsu_raw_fwd_hi_dc4;
reg lsu_raw_fwd_lo_dc5;
reg lsu_raw_fwd_hi_dc5;

   eh2_lsu_lsc_ctl #(.pt(pt)) lsu_lsc_ctl(.*);

         assign ldst_nodma_dc2todc5 = (lsu_pkt_dc2.valid & ~lsu_pkt_dc2.dma & (addr_in_dccm_dc2 | addr_in_pic_dc2) & lsu_pkt_dc2.store) |
                                (lsu_pkt_dc3.valid & ~lsu_pkt_dc3.dma & (addr_in_dccm_dc3 | addr_in_pic_dc3) & lsu_pkt_dc3.store) |
                                (lsu_pkt_dc4.valid & ~lsu_pkt_dc4.dma & (addr_in_dccm_dc4 | addr_in_pic_dc4) & lsu_pkt_dc4.store);
   assign dccm_ready = ~(lsu_pkt_dc1_pre.valid | ldst_nodma_dc2todc5 | ld_single_ecc_error_dc5_ff);
   assign dma_mem_tag_dc1[2:0] = dma_mem_tag[2:0];

   assign dma_pic_wen  = dma_dccm_req & dma_mem_write & ~dma_mem_addr_in_dccm;
   assign dma_dccm_wen = dma_dccm_req & dma_mem_write & dma_mem_addr_in_dccm;
   assign dma_dccm_spec_wen = dma_dccm_spec_req & dma_mem_write;
   assign dma_start_addr_dc1[31:0] = dma_mem_addr[31:0];
   assign dma_end_addr_dc1[31:3]   = dma_mem_addr[31:3];
   assign dma_end_addr_dc1[2:0]    = (dma_mem_sz[2:0] == 3'b11) ? 3'b100 : dma_mem_addr[2:0];
    assign {dma_dccm_wdata_hi[31:0], dma_dccm_wdata_lo[31:0]} = dma_mem_wdata[63:0] >> {dma_mem_addr[2:0], 3'b000};   
      for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenFlushLoop
      assign flush_dc2_up[i] = flush_final_e3[i] | dec_tlu_flush_lower_wb[i];
      assign flush_dc3[i]    = (flush_final_e3[i] & i0_flush_final_e3[i]) | dec_tlu_flush_lower_wb[i];
      assign flush_dc4[i]    = dec_tlu_flush_lower_wb[i];
      assign flush_dc5[i]    = ((dec_tlu_i0_kill_writeb_wb & ~lsu_pkt_dc5.pipe) | (dec_tlu_i1_kill_writeb_wb & lsu_pkt_dc5.pipe)) & (lsu_pkt_dc5.tid == i);
   end

   assign lsu_fastint_stall_any = ld_single_ecc_error_dc3;

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenThreadLoop
                  assign lsu_store_stall_any[i] = (lsu_pkt_dc1.valid & (lsu_pkt_dc1.sc | (lsu_pkt_dc1.atomic & lsu_pkt_dc1.store))) |
                                      (lsu_pkt_dc2.valid & (lsu_pkt_dc2.sc | (lsu_pkt_dc2.atomic & lsu_pkt_dc2.store))) |
                                      (lsu_pkt_dc3.valid & (lsu_pkt_dc3.sc | (lsu_pkt_dc3.atomic & lsu_pkt_dc3.store))) |
                                      lsu_stbuf_full_any[i] | lsu_bus_buffer_full_any[i] | ld_single_ecc_error_dc5;
            assign lsu_amo_stall_any[i]   = (lsu_pkt_dc1.valid & lsu_pkt_dc1.store & (lsu_pkt_dc1.tid != i)) |
                                      (lsu_pkt_dc2.valid & lsu_pkt_dc2.store & (lsu_pkt_dc2.tid != i)) |
                                      (lsu_pkt_dc3.valid & lsu_pkt_dc3.store & (lsu_pkt_dc3.tid != i));
      assign lsu_load_stall_any[i]  = (lsu_pkt_dc1.valid & (lsu_pkt_dc1.sc | (lsu_pkt_dc1.atomic & lsu_pkt_dc1.store))) |
                                      (lsu_pkt_dc2.valid & (lsu_pkt_dc2.sc | (lsu_pkt_dc2.atomic & lsu_pkt_dc2.store))) |
                                      (lsu_pkt_dc3.valid & (lsu_pkt_dc3.sc | (lsu_pkt_dc3.atomic & lsu_pkt_dc3.store))) |
                                      lsu_bus_buffer_full_any[i] | ld_single_ecc_error_dc5;

                        assign lsu_idle_any[i] = ~((lsu_pkt_dc1.valid & ~lsu_pkt_dc1.dma & (lsu_pkt_dc1.tid == 1'(i))) |
                                 (lsu_pkt_dc2.valid & ~lsu_pkt_dc2.dma & (lsu_pkt_dc2.tid == 1'(i))) |
                                 (lsu_pkt_dc3.valid & ~lsu_pkt_dc3.dma & (lsu_pkt_dc3.tid == 1'(i))) |
                                 (lsu_pkt_dc4.valid & ~lsu_pkt_dc4.dma & (lsu_pkt_dc4.tid == 1'(i))) |
                                 (lsu_pkt_dc5.valid & ~lsu_pkt_dc5.dma & (lsu_pkt_dc5.tid == 1'(i)))) &
                                 lsu_bus_idle_any[i] & lsu_bus_buffer_empty_any[i];
   end

   assign       lsu_raw_fwd_lo_dc3 = (|stbuf_fwdbyteen_lo_dc3[pt.DCCM_BYTE_WIDTH-1:0]);
   assign       lsu_raw_fwd_hi_dc3 = (|stbuf_fwdbyteen_hi_dc3[pt.DCCM_BYTE_WIDTH-1:0]);

      assign store_stbuf_reqvld_dc5 = lsu_pkt_dc5.valid & (lsu_pkt_dc5.store | (lsu_pkt_dc5.atomic & ~lsu_pkt_dc5.lr)) &
                                   (~lsu_pkt_dc5.sc | lsu_sc_success_dc5 | (lsu_single_ecc_error_dc5 & ~lsu_raw_fwd_lo_dc5)) & addr_in_dccm_dc5 & lsu_commit_dc5;

      assign lsu_cmpen_dc2 = lsu_pkt_dc2.valid & (lsu_pkt_dc2.load | lsu_pkt_dc2.store | lsu_pkt_dc1.atomic) & (addr_in_dccm_dc2 | addr_in_pic_dc2);

      assign lsu_busreq_dc1 = lsu_pkt_dc1_pre.valid & ((lsu_pkt_dc1_pre.load | lsu_pkt_dc1_pre.store) & addr_external_dc1) & ~flush_dc2_up[lsu_pkt_dc1_pre.tid] & ~lsu_pkt_dc1_pre.fast_int;

      for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenPMU
      assign lsu_pmu_misaligned_dc3[i]     = lsu_pkt_dc3.valid & ~lsu_pkt_dc3.dma & ((lsu_pkt_dc3.half & lsu_addr_dc3[0]) | (lsu_pkt_dc3.word & (|lsu_addr_dc3[1:0]))) & (i == lsu_pkt_dc3.tid);
      assign lsu_pmu_load_external_dc3[i]  = lsu_pkt_dc3.valid & ~lsu_pkt_dc3.dma & lsu_pkt_dc3.load & addr_external_dc3 & (i == lsu_pkt_dc3.tid);
      assign lsu_pmu_store_external_dc3[i] = lsu_pkt_dc3.valid & ~lsu_pkt_dc3.dma & lsu_pkt_dc3.store & addr_external_dc3 & (i == lsu_pkt_dc3.tid);
   end

 eh2_lsu_amo #(.pt(pt))  lsu_amo (.*);

   eh2_lsu_dccm_ctl #(.pt(pt)) dccm_ctl (
      .lsu_addr_dc1(lsu_addr_dc1[31:0]),
      .end_addr_dc1(end_addr_dc1[31:0]),
      .lsu_addr_dc3(lsu_addr_dc3[31:0]),
      .lsu_addr_dc4(lsu_addr_dc4[31:0]),
      .lsu_addr_dc5(lsu_addr_dc5[31:0]),

      .end_addr_dc2(end_addr_dc2[31:0]),
      .end_addr_dc3(end_addr_dc3[31:0]),
      .end_addr_dc4(end_addr_dc4[31:0]),
      .end_addr_dc5(end_addr_dc5[31:0]),
      .*
   );

   eh2_lsu_stbuf #(.pt(pt)) stbuf(
      .lsu_addr_dc1(lsu_addr_dc1[pt.LSU_SB_BITS-1:0]),
      .end_addr_dc1(end_addr_dc1[pt.LSU_SB_BITS-1:0]),

      .*

   );

   eh2_lsu_ecc #(.pt(pt)) ecc (
      .lsu_addr_dc3(lsu_addr_dc3[pt.DCCM_BITS-1:0]),
      .end_addr_dc3(end_addr_dc3[pt.DCCM_BITS-1:0]),
      .*
   );

   eh2_lsu_trigger #(.pt(pt)) trigger (
      .store_data_dc3(store_data_dc3[31:0]),
      .*
   );

   // Clk domain
   eh2_lsu_clkdomain #(.pt(pt)) clkdomain (.*);

   // Bus interface
   eh2_lsu_bus_intf #(.pt(pt)) bus_intf (.*);

   //Flops
   rvdff #(1) single_ecc_err_hidc4  (.*, .din(single_ecc_error_hi_dc3),     .dout(single_ecc_error_hi_dc4), .clk(lsu_c2_dc4_clk));
   rvdff #(1) single_ecc_err_hidc5  (.*, .din(single_ecc_error_hi_dc4),     .dout(single_ecc_error_hi_dc5), .clk(lsu_c2_dc5_clk));
   rvdff #(1) single_ecc_err_lodc4  (.*, .din(single_ecc_error_lo_dc3),     .dout(single_ecc_error_lo_dc4), .clk(lsu_c2_dc4_clk));
   rvdff #(1) single_ecc_err_lodc5  (.*, .din(single_ecc_error_lo_dc4),     .dout(single_ecc_error_lo_dc5), .clk(lsu_c2_dc5_clk));

   rvdff #(3) dma_mem_tag_dc2ff    (.*, .din(dma_mem_tag_dc1[2:0]),         .dout(dma_mem_tag_dc2[2:0]),     .clk(lsu_c2_dc2_clk));
   rvdff #(3) dma_mem_tag_dc3ff    (.*, .din(dma_mem_tag_dc2[2:0]),         .dout(dma_mem_tag_dc3[2:0]),     .clk(lsu_c2_dc3_clk));

   rvdff #(2) lsu_raw_fwd_dc4_ff    (.*, .din({lsu_raw_fwd_hi_dc3, lsu_raw_fwd_lo_dc3}),     .dout({lsu_raw_fwd_hi_dc4, lsu_raw_fwd_lo_dc4}),     .clk(lsu_c2_dc4_clk));
   rvdff #(2) lsu_raw_fwd_dc5_ff    (.*, .din({lsu_raw_fwd_hi_dc4, lsu_raw_fwd_lo_dc4}),     .dout({lsu_raw_fwd_hi_dc5, lsu_raw_fwd_lo_dc5}),     .clk(lsu_c2_dc5_clk));

`ifdef ASSERT_ON
   wire [8:0] store_data_bypass_sel;
   assign store_data_bypass_sel[8:0] =  {lsu_p.store_data_bypass_c1,
                                         lsu_p.store_data_bypass_c2,
                                         lsu_p.store_data_bypass_i0_e2_c2,
                                         lsu_p.store_data_bypass_e4_c1[1:0],
                                         lsu_p.store_data_bypass_e4_c2[1:0],
                                         lsu_p.store_data_bypass_e4_c3[1:0]} & {9{lsu_p.valid}};





`endif

endmodule : eh2_lsu
