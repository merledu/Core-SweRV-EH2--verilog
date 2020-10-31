

module eh2_dma_ctrl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )(
   input wire clk,
   input wire free_clk,
   input wire rst_l,
   input wire dma_bus_clk_en,    input wire clk_override,
   input wire scan_mode,

      input wire [31:0]  dbg_cmd_addr,
   input wire [31:0]  dbg_cmd_wrdata,
   input wire dbg_cmd_valid,
   input wire dbg_cmd_write,    input wire [1:0]   dbg_cmd_type,    input wire [1:0]   dbg_cmd_size, 
   input wire dbg_dma_bubble,      output logic        dma_dbg_ready,    
   output logic        dma_dbg_cmd_done,
   output logic        dma_dbg_cmd_fail,
   output logic [31:0] dma_dbg_rddata,

      output logic        dma_dccm_req,     output logic        dma_dccm_spec_req,     output logic        dma_iccm_req,     output logic        dma_mem_addr_in_dccm,     output logic [2:0]  dma_mem_tag,      output logic [31:0] dma_mem_addr,     output logic [2:0]  dma_mem_sz,       output logic        dma_mem_write,    output logic [63:0] dma_mem_wdata, 
   input wire dccm_dma_rvalid,       input wire dccm_dma_ecc_error,    input wire [2:0]   dccm_dma_rtag,         input wire [63:0]  dccm_dma_rdata,        input wire iccm_dma_rvalid,       input wire iccm_dma_ecc_error,    input wire [2:0]   iccm_dma_rtag,         input wire [63:0]  iccm_dma_rdata,     
   output logic        dma_dccm_stall_any,    output logic        dma_iccm_stall_any,    input wire dccm_ready,    input wire iccm_ready,    input wire [2:0]   dec_tlu_dma_qos_prty,    
      output logic        dma_pmu_dccm_read,
   output logic        dma_pmu_dccm_write,
   output logic        dma_pmu_any_read,
   output logic        dma_pmu_any_write,

      input wire dma_axi_awvalid,
   output logic                        dma_axi_awready,
   input wire [pt.DMA_BUS_TAG-1:0]   dma_axi_awid,
   input wire [31:0]                 dma_axi_awaddr,
   input wire [2:0]                  dma_axi_awsize,


   input wire dma_axi_wvalid,
   output logic                        dma_axi_wready,
   input wire [63:0]                 dma_axi_wdata,
   input wire [7:0]                  dma_axi_wstrb,

   output logic                        dma_axi_bvalid,
   input wire dma_axi_bready,
   output logic [1:0]                  dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]   dma_axi_bid,

      input wire dma_axi_arvalid,
   output logic                        dma_axi_arready,
   input wire [pt.DMA_BUS_TAG-1:0]   dma_axi_arid,
   input wire [31:0]                 dma_axi_araddr,
   input wire [2:0]                  dma_axi_arsize,

   output logic                        dma_axi_rvalid,
   input wire dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]   dma_axi_rid,
   output logic [63:0]                 dma_axi_rdata,
   output logic [1:0]                  dma_axi_rresp,
   output logic                        dma_axi_rlast
);


   localparam DEPTH = pt.DMA_BUF_DEPTH;
   localparam DEPTH_PTR = $clog2(DEPTH);
   localparam NACK_COUNT = 7;

   reg [DEPTH-1:0]        fifo_valid;
   wire [DEPTH-1:0][1:0]   fifo_error;
   reg [DEPTH-1:0]        fifo_dccm_valid;
   reg [DEPTH-1:0]        fifo_iccm_valid;
   wire [DEPTH-1:0]        fifo_error_bus;
   reg [DEPTH-1:0]        fifo_rpend;
   wire [DEPTH-1:0]        fifo_done;         wire [DEPTH-1:0]        fifo_done_bus;     wire [DEPTH-1:0][31:0]  fifo_addr;
   wire [DEPTH-1:0][2:0]   fifo_sz;
   wire [DEPTH-1:0][7:0]   fifo_byteen;
   wire [DEPTH-1:0]        fifo_write;
   wire [DEPTH-1:0]        fifo_posted_write;
   wire [DEPTH-1:0]        fifo_dbg;
   wire [DEPTH-1:0][63:0]  fifo_data;
   reg [DEPTH-1:0][pt.DMA_BUS_TAG-1:0]  fifo_tag;
   reg [DEPTH-1:0][pt.DMA_BUS_ID-1:0]   fifo_mid;
   reg [DEPTH-1:0][pt.DMA_BUS_PRTY-1:0] fifo_prty;

   wire [DEPTH-1:0]        fifo_cmd_en;
   wire [DEPTH-1:0]        fifo_data_en;
   reg [DEPTH-1:0]        fifo_data_bus_en;
   wire [DEPTH-1:0]        fifo_pend_en;
   wire [DEPTH-1:0]        fifo_done_en;
   wire [DEPTH-1:0]        fifo_done_bus_en;
   wire [DEPTH-1:0]        fifo_error_en;
   wire [DEPTH-1:0]        fifo_error_bus_en;
   wire [DEPTH-1:0]        fifo_reset;
   wire [DEPTH-1:0][1:0]   fifo_error_in;
   wire [DEPTH-1:0][63:0]  fifo_data_in;

   wire                    fifo_write_in;
   wire                    fifo_posted_write_in;
   wire                    fifo_dbg_in;
   wire [31:0]             fifo_addr_in;
   wire [2:0]              fifo_sz_in;
   wire [7:0]              fifo_byteen_in;

wire [DEPTH_PTR-1:0] RspPtr;
wire [DEPTH_PTR-1:0] NxtRspPtr;
wire [DEPTH_PTR-1:0] WrPtr;
wire [DEPTH_PTR-1:0] NxtWrPtr;
wire [DEPTH_PTR-1:0] RdPtr;
wire [DEPTH_PTR-1:0] NxtRdPtr;
wire WrPtrEn;
wire RdPtrEn;
wire RspPtrEn;

   wire                    dma_dbg_cmd_error;
   reg                    dma_dbg_cmd_done_q;

wire fifo_full;
wire fifo_full_spec;
wire fifo_empty;
wire dma_address_error;
reg dma_alignment_error;
   reg [3:0]              num_fifo_vld;
wire dma_mem_req_spec;
wire dma_mem_req;
   wire [7:0]              dma_mem_byteen;
   wire [31:0]             dma_mem_addr_int;
   wire [2:0]              dma_mem_sz_int;
   wire                    dma_mem_addr_in_iccm;
   reg                    dma_mem_addr_in_pic;
   reg                    dma_mem_addr_in_pic_region_nc;
   reg                    dma_mem_addr_in_dccm_region_nc;
   wire                    dma_mem_addr_in_iccm_region_nc;

wire [2:0] dma_nack_count;
wire [2:0] dma_nack_count_d;
wire [2:0] dma_nack_count_csr;

   wire                    dma_buffer_c1_clken;
   wire                    dma_free_clken;
   wire                    dma_buffer_c1_clk;
   wire                    dma_free_clk;
   reg                    dma_bus_clk;

wire bus_rsp_valid;
wire bus_rsp_sent;
wire bus_cmd_valid;
wire bus_cmd_sent;
reg bus_cmd_read;
wire bus_cmd_write;
wire bus_cmd_posted_write;
   wire [7:0]              bus_cmd_byteen;
   wire [2:0]              bus_cmd_sz;
   wire [31:0]             bus_cmd_addr;
   wire [63:0]             bus_cmd_wdata;
   wire [pt.DMA_BUS_TAG-1:0]  bus_cmd_tag;
   wire [pt.DMA_BUS_ID-1:0]   bus_cmd_mid;
   wire [pt.DMA_BUS_PRTY-1:0] bus_cmd_prty;
   wire                    bus_posted_write_done;

   reg                    fifo_full_spec_bus;
   reg                    dbg_dma_bubble_bus;
   reg                    dec_tlu_stall_dma_bus;
   wire                    dma_fifo_ready;

   
      assign fifo_addr_in[31:0]    = dbg_cmd_valid ? dbg_cmd_addr[31:0] : bus_cmd_addr[31:0];
   assign fifo_byteen_in[7:0]   = dbg_cmd_valid ? (8'h0f << 4*dbg_cmd_addr[2]) : bus_cmd_byteen[7:0];
   assign fifo_sz_in[2:0]       = dbg_cmd_valid ? {1'b0,dbg_cmd_size[1:0]} : bus_cmd_sz[2:0];
   assign fifo_write_in         = dbg_cmd_valid ? dbg_cmd_write : bus_cmd_write;
   assign fifo_posted_write_in  = ~dbg_cmd_valid & bus_cmd_posted_write;
   assign fifo_dbg_in           = dbg_cmd_valid;

   for (genvar i=0 ;i<DEPTH; i++) begin: GenFifo
      assign fifo_cmd_en[i]   = ((bus_cmd_sent & dma_bus_clk_en) | (dbg_cmd_valid & dbg_cmd_type[1])) & (i == WrPtr[DEPTH_PTR-1:0]);
      assign fifo_data_en[i] = (((bus_cmd_sent & fifo_write_in & dma_bus_clk_en) | (dbg_cmd_valid & dbg_cmd_type[1] & dbg_cmd_write))  & (i == WrPtr[DEPTH_PTR-1:0])) |
                               ((dma_address_error | dma_alignment_error) & (i == RdPtr[DEPTH_PTR-1:0])) |
                               (dccm_dma_rvalid & (i == DEPTH_PTR'(dccm_dma_rtag[2:0]))) |
                               (iccm_dma_rvalid & (i == DEPTH_PTR'(iccm_dma_rtag[2:0])));
      assign fifo_pend_en[i] = (dma_dccm_req | dma_iccm_req) & ~dma_mem_write & (i == RdPtr[DEPTH_PTR-1:0]);
      assign fifo_error_en[i] = ((dma_address_error | dma_alignment_error | dma_dbg_cmd_error) & (i == RdPtr[DEPTH_PTR-1:0])) |
                                ((dccm_dma_rvalid & dccm_dma_ecc_error) & (i == DEPTH_PTR'(dccm_dma_rtag[2:0]))) |
                                ((iccm_dma_rvalid & iccm_dma_ecc_error) & (i == DEPTH_PTR'(iccm_dma_rtag[2:0])));
      assign fifo_error_bus_en[i] = (((|fifo_error_in[i][1:0]) & fifo_error_en[i]) | (|fifo_error[i])) & dma_bus_clk_en;
      assign fifo_done_en[i] = ((|fifo_error[i] | fifo_error_en[i] | ((dma_dccm_req | dma_iccm_req) & dma_mem_write)) & (i == RdPtr[DEPTH_PTR-1:0])) |
                               (dccm_dma_rvalid & (i == DEPTH_PTR'(dccm_dma_rtag[2:0]))) |
                               (iccm_dma_rvalid & (i == DEPTH_PTR'(iccm_dma_rtag[2:0])));
      assign fifo_done_bus_en[i] = (fifo_done_en[i] | fifo_done[i]) & dma_bus_clk_en;
      assign fifo_reset[i] = (((bus_rsp_sent | bus_posted_write_done) & dma_bus_clk_en) | dma_dbg_cmd_done) & (i == RspPtr[DEPTH_PTR-1:0]);
      assign fifo_error_in[i]   = (dccm_dma_rvalid & (i == DEPTH_PTR'(dccm_dma_rtag[2:0]))) ? {1'b0,dccm_dma_ecc_error} : (iccm_dma_rvalid & (i == DEPTH_PTR'(iccm_dma_rtag[2:0]))) ? {1'b0,iccm_dma_ecc_error}  :
                                                                                                                {(dma_address_error | dma_alignment_error | dma_dbg_cmd_error), dma_alignment_error};
      assign fifo_data_in[i]   = (fifo_error_en[i] & (|fifo_error_in[i])) ? {32'b0,fifo_addr[i]} :
                                                        ((dccm_dma_rvalid & (i == DEPTH_PTR'(dccm_dma_rtag[2:0])))  ? dccm_dma_rdata[63:0] : (iccm_dma_rvalid & (i == DEPTH_PTR'(iccm_dma_rtag[2:0]))) ? iccm_dma_rdata[63:0] :
                                                                                                                                                       (dbg_cmd_valid ? {2{dbg_cmd_wrdata[31:0]}} : bus_cmd_wdata[63:0]));
      rvdffsc #(1) fifo_valid_dff (.din(1'b1), .dout(fifo_valid[i]), .en(fifo_cmd_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffsc #(2) fifo_error_dff (.din(fifo_error_in[i]), .dout(fifo_error[i]), .en(fifo_error_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffsc #(1) fifo_error_bus_dff (.din(1'b1), .dout(fifo_error_bus[i]), .en(fifo_error_bus_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffsc #(1) fifo_rpend_dff (.din(1'b1), .dout(fifo_rpend[i]), .en(fifo_pend_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffsc #(1) fifo_done_dff (.din(1'b1), .dout(fifo_done[i]), .en(fifo_done_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffsc #(1) fifo_done_bus_dff (.din(1'b1), .dout(fifo_done_bus[i]), .en(fifo_done_bus_en[i]), .clear(fifo_reset[i]), .clk(dma_free_clk), .*);
      rvdffe  #(32) fifo_addr_dff (.din(fifo_addr_in[31:0]), .dout(fifo_addr[i]), .en(fifo_cmd_en[i]), .*);
      rvdffs  #(3) fifo_sz_dff (.din(fifo_sz_in[2:0]), .dout(fifo_sz[i]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(8) fifo_byteen_dff (.din(fifo_byteen_in[7:0]), .dout(fifo_byteen[i]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(1) fifo_write_dff (.din(fifo_write_in), .dout(fifo_write[i]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(1) fifo_posted_write_dff (.din(fifo_posted_write_in), .dout(fifo_posted_write[i]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(1) fifo_dbg_dff (.din(fifo_dbg_in), .dout(fifo_dbg[i]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffe  #(64) fifo_data_dff (.din(fifo_data_in[i]), .dout(fifo_data[i]), .en(fifo_data_en[i]), .*);
      rvdffs  #(pt.DMA_BUS_TAG) fifo_tag_dff(.din(bus_cmd_tag[pt.DMA_BUS_TAG-1:0]), .dout(fifo_tag[i][pt.DMA_BUS_TAG-1:0]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(pt.DMA_BUS_ID) fifo_mid_dff(.din(bus_cmd_mid[pt.DMA_BUS_ID-1:0]), .dout(fifo_mid[i][pt.DMA_BUS_ID-1:0]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);
      rvdffs  #(pt.DMA_BUS_PRTY) fifo_prty_dff(.din(bus_cmd_prty[pt.DMA_BUS_PRTY-1:0]), .dout(fifo_prty[i][pt.DMA_BUS_PRTY-1:0]), .en(fifo_cmd_en[i]), .clk(dma_buffer_c1_clk), .*);

   end

      assign NxtWrPtr[DEPTH_PTR-1:0] = (WrPtr[DEPTH_PTR-1:0] == (DEPTH-1)) ? 'd0 : WrPtr[DEPTH_PTR-1:0] + 1'b1;
   assign NxtRdPtr[DEPTH_PTR-1:0] = (RdPtr[DEPTH_PTR-1:0] == (DEPTH-1)) ? 'd0 : RdPtr[DEPTH_PTR-1:0] + 1'b1;
   assign NxtRspPtr[DEPTH_PTR-1:0] = (RspPtr[DEPTH_PTR-1:0] == (DEPTH-1)) ? 'd0 : RspPtr[DEPTH_PTR-1:0] + 1'b1;

   assign WrPtrEn = |fifo_cmd_en[DEPTH-1:0];
   assign RdPtrEn = dma_dccm_req | dma_iccm_req | (dma_address_error | dma_alignment_error | dma_dbg_cmd_error);
   assign RspPtrEn = (dma_dbg_cmd_done | (bus_rsp_sent | bus_posted_write_done) & dma_bus_clk_en);

     rvdffs #(DEPTH_PTR) WrPtr_dff(.din(NxtWrPtr[DEPTH_PTR-1:0]), .dout(WrPtr[DEPTH_PTR-1:0]), .en(WrPtrEn), .clk(dma_free_clk), .*);
   rvdffs #(DEPTH_PTR) RdPtr_dff(.din(NxtRdPtr[DEPTH_PTR-1:0]), .dout(RdPtr[DEPTH_PTR-1:0]), .en(RdPtrEn), .clk(dma_free_clk), .*);
   rvdffs #(DEPTH_PTR) RspPtr_dff(.din(NxtRspPtr[DEPTH_PTR-1:0]), .dout(RspPtr[DEPTH_PTR-1:0]), .en(RspPtrEn), .clk(dma_free_clk), .*);


      assign fifo_full = fifo_full_spec_bus;

   always @* begin
      num_fifo_vld[3:0] = {3'b0,bus_cmd_sent} - {3'b0,bus_rsp_sent};
      for (int i=0; i<DEPTH; i++) begin
         num_fifo_vld[3:0] += {3'b0,fifo_valid[i]};
      end
   end
   assign fifo_full_spec          = (num_fifo_vld[3:0] >= DEPTH);

   assign dma_fifo_ready = ~(fifo_full | dbg_dma_bubble_bus | dec_tlu_stall_dma_bus);

      assign dma_address_error = fifo_valid[RdPtr] & ~fifo_done[RdPtr] & ~fifo_dbg[RdPtr] & (~(dma_mem_addr_in_dccm | dma_mem_addr_in_iccm));       assign dma_alignment_error = fifo_valid[RdPtr] & ~fifo_done[RdPtr] & ~dma_address_error &
                                (((dma_mem_sz_int[2:0] == 3'h1) & dma_mem_addr_int[0])                                                       |                                     ((dma_mem_sz_int[2:0] == 3'h2) & (|dma_mem_addr_int[1:0]))                                                  |                                     ((dma_mem_sz_int[2:0] == 3'h3) & (|dma_mem_addr_int[2:0]))                                                  |                                     (dma_mem_addr_in_iccm & ~((dma_mem_sz_int[1:0] == 2'b10) | (dma_mem_sz_int[1:0] == 2'b11)))                 |                                     (dma_mem_addr_in_dccm & dma_mem_write & ~((dma_mem_sz_int[1:0] == 2'b10) | (dma_mem_sz_int[1:0] == 2'b11))) |                                     (dma_mem_write & (dma_mem_sz_int[2:0] == 3'h2) & (dma_mem_byteen[dma_mem_addr_int[2:0]+:4] != 4'hf))        |                                     (dma_mem_write & (dma_mem_sz_int[2:0] == 3'h3) & ~((dma_mem_byteen[7:0] == 8'h0f) | (dma_mem_byteen[7:0] == 8'hf0) | (dma_mem_byteen[7:0] == 8'hff)))); 
      assign dma_dbg_ready    = fifo_empty & dbg_dma_bubble_bus;
   assign dma_dbg_cmd_done = (fifo_valid[RspPtr] & fifo_dbg[RspPtr] & fifo_done[RspPtr]);
   assign dma_dbg_rddata[31:0] = fifo_addr[RspPtr][2] ? fifo_data[RspPtr][63:32] : fifo_data[RspPtr][31:0];
   assign dma_dbg_cmd_fail     = |fifo_error[RspPtr];

   assign dma_dbg_cmd_error = fifo_valid[RdPtr] & ~fifo_done[RdPtr] & fifo_dbg[RdPtr] &
                                 ((~(dma_mem_addr_in_dccm | dma_mem_addr_in_iccm | dma_mem_addr_in_pic)) | (dma_mem_sz_int[1:0] != 2'b10));  
      assign dma_dccm_stall_any = dma_mem_req_spec & (dma_mem_addr_in_dccm | dma_mem_addr_in_pic) & (dma_nack_count >= dma_nack_count_csr) & ~dccm_ready;
   assign dma_iccm_stall_any = dma_mem_req_spec & dma_mem_addr_in_iccm & (dma_nack_count >= dma_nack_count_csr);

      assign fifo_empty     = ~(|(fifo_valid[DEPTH-1:0]));

      assign dma_nack_count_csr[2:0] = dec_tlu_dma_qos_prty[2:0];
   assign dma_nack_count_d[2:0] = (dma_nack_count[2:0] >= dma_nack_count_csr[2:0]) ? ({3{~(dma_dccm_req | dma_iccm_req)}} & dma_nack_count[2:0]) :
                                                                                    (dma_mem_req & ~(dma_dccm_req | dma_iccm_req)) ? (dma_nack_count[2:0] + 1'b1) : 3'b0;


  rvdffs #(3) nack_count_dff(.din(dma_nack_count_d[2:0]), .dout(dma_nack_count[2:0]), .en(dma_mem_req), .clk(dma_free_clk), .*);



      assign dma_mem_req_spec     = fifo_valid[RdPtr] & ~fifo_rpend[RdPtr] & ~fifo_done[RdPtr];
   assign dma_mem_req         = dma_mem_req_spec & ~(dma_address_error | dma_alignment_error | dma_dbg_cmd_error);
   assign dma_dccm_req        = dma_mem_req & (dma_mem_addr_in_dccm | dma_mem_addr_in_pic) & dccm_ready;
   assign dma_dccm_spec_req   = dma_mem_req_spec & ~dma_mem_addr_in_iccm & dccm_ready;      assign dma_iccm_req        = dma_mem_req & dma_mem_addr_in_iccm & iccm_ready;
   assign dma_mem_tag[2:0]    = 3'(RdPtr);
   assign dma_mem_addr_int[31:0] = fifo_addr[RdPtr];
   assign dma_mem_sz_int[2:0] = fifo_sz[RdPtr];
   assign dma_mem_addr[31:0]  = (dma_mem_write & (dma_mem_byteen[7:0] == 8'hf0)) ? {dma_mem_addr_int[31:3],1'b1,dma_mem_addr_int[1:0]} : dma_mem_addr_int[31:0];
   assign dma_mem_sz[2:0]     = (dma_mem_write & ((dma_mem_byteen[7:0] == 8'h0f) | (dma_mem_byteen[7:0] == 8'hf0))) ? 3'h2 : dma_mem_sz_int[2:0];
   assign dma_mem_byteen[7:0] = fifo_byteen[RdPtr];
   assign dma_mem_write       = fifo_write[RdPtr];
   assign dma_mem_wdata[63:0] = fifo_data[RdPtr];

      assign dma_pmu_dccm_read   = dma_dccm_req & ~dma_mem_write;
   assign dma_pmu_dccm_write  = dma_dccm_req & dma_mem_write;
   assign dma_pmu_any_read    = (dma_dccm_req | dma_iccm_req) & ~dma_mem_write;
   assign dma_pmu_any_write   = (dma_dccm_req | dma_iccm_req) & dma_mem_write;

      rvrangecheck #(.CCM_SADR(pt.DCCM_SADR),
                  .CCM_SIZE(pt.DCCM_SIZE)) addr_dccm_rangecheck (
      .addr(dma_mem_addr[31:0]),
      .in_range(dma_mem_addr_in_dccm),
      .in_region(dma_mem_addr_in_dccm_region_nc)
   );

      if (pt.ICCM_ENABLE) begin
      rvrangecheck #(.CCM_SADR(pt.ICCM_SADR),
                     .CCM_SIZE(pt.ICCM_SIZE)) addr_iccm_rangecheck (
         .addr(dma_mem_addr[31:0]),
         .in_range(dma_mem_addr_in_iccm),
         .in_region(dma_mem_addr_in_iccm_region_nc)
      );
   end
   else  begin
      assign dma_mem_addr_in_iccm = '0;
      assign dma_mem_addr_in_iccm_region_nc = '0;
   end 

      rvrangecheck #(.CCM_SADR(pt.PIC_BASE_ADDR),
                  .CCM_SIZE(pt.PIC_SIZE)) addr_pic_rangecheck (
      .addr(dma_mem_addr[31:0]),
      .in_range(dma_mem_addr_in_pic),
      .in_region(dma_mem_addr_in_pic_region_nc)
    );


   wire dec_tlu_stall_dma;
   assign dec_tlu_stall_dma = 1'b0;

   
  rvdff #(1)  fifo_full_bus_ff (.din(fifo_full_spec), .dout(fifo_full_spec_bus), .clk(dma_bus_clk), .*);
   rvdff #(1)  dbg_dma_bubble_ff (.din(dbg_dma_bubble), .dout(dbg_dma_bubble_bus), .clk(dma_bus_clk), .*);
   rvdff #(1)  dec_tlu_stall_dma_ff (.din(dec_tlu_stall_dma), .dout(dec_tlu_stall_dma_bus), .clk(dma_bus_clk), .*);
   rvdff #(1) dma_dbg_cmd_doneff (.din(dma_dbg_cmd_done), .dout(dma_dbg_cmd_done_q), .clk(free_clk), .*);





      assign dma_buffer_c1_clken = (bus_cmd_valid & dma_bus_clk_en) | dbg_cmd_valid | dec_tlu_stall_dma | clk_override;
   assign dma_free_clken = (bus_cmd_valid | bus_rsp_valid | dbg_cmd_valid | dma_dbg_cmd_done | dma_dbg_cmd_done_q | (|fifo_valid[DEPTH-1:0]) | dec_tlu_stall_dma | clk_override);



  rvoclkhdr dma_buffer_c1cgc ( .en(dma_buffer_c1_clken), .l1clk(dma_buffer_c1_clk), .* );
   rvoclkhdr dma_free_cgc (.en(dma_free_clken), .l1clk(dma_free_clk), .*);
   rvclkhdr dma_bus_cgc (.en(dma_bus_clk_en), .l1clk(dma_bus_clk), .*);









wire wrbuf_en;
wire wrbuf_data_en;
wire wrbuf_cmd_sent;
wire wrbuf_rst;
wire wrbuf_data_rst;
reg wrbuf_vld;
reg wrbuf_data_vld;
   reg [pt.DMA_BUS_TAG-1:0]  wrbuf_tag;
   reg [2:0]                 wrbuf_sz;
   reg [31:0]                wrbuf_addr;
   wire [63:0]                wrbuf_data;
   reg [7:0]                 wrbuf_byteen;

   wire                       rdbuf_en;
wire rdbuf_cmd_sent;
wire rdbuf_rst;
   reg                       rdbuf_vld;
   reg [pt.DMA_BUS_TAG-1:0]  rdbuf_tag;
   reg [2:0]                 rdbuf_sz;
   reg [31:0]                rdbuf_addr;

wire axi_mstr_prty_in;
wire axi_mstr_prty_en;
   reg                       axi_mstr_priority;
   wire                       axi_mstr_sel;

wire axi_rsp_valid;
reg axi_rsp_sent;
   wire                       axi_rsp_write;
   wire [pt.DMA_BUS_TAG-1:0]  axi_rsp_tag;
   wire [1:0]                 axi_rsp_error;
   wire [63:0]                axi_rsp_rdata;

   wire                       axi_rsp_posted_write;


      assign wrbuf_en       = dma_axi_awvalid & dma_axi_awready;
   assign wrbuf_data_en  = dma_axi_wvalid & dma_axi_wready;
   assign wrbuf_cmd_sent = bus_cmd_sent & bus_cmd_write;
   assign wrbuf_rst      = wrbuf_cmd_sent & ~wrbuf_en;
   assign wrbuf_data_rst = wrbuf_cmd_sent & ~wrbuf_data_en;



  rvdffsc  #(.WIDTH(1))  wrbuf_vldff(.din(1'b1), .dout(wrbuf_vld), .en(wrbuf_en), .clear(wrbuf_rst), .clk(dma_bus_clk), .*);
   rvdffsc  #(.WIDTH(1))  wrbuf_data_vldff(.din(1'b1), .dout(wrbuf_data_vld), .en(wrbuf_data_en), .clear(wrbuf_data_rst), .clk(dma_bus_clk), .*);
   rvdffs   #(.WIDTH(pt.DMA_BUS_TAG)) wrbuf_tagff(.din(dma_axi_awid[pt.DMA_BUS_TAG-1:0]), .dout(wrbuf_tag[pt.DMA_BUS_TAG-1:0]), .en(wrbuf_en), .clk(dma_bus_clk), .*);
   rvdffs   #(.WIDTH(3)) wrbuf_szff(.din(dma_axi_awsize[2:0]), .dout(wrbuf_sz[2:0]), .en(wrbuf_en), .clk(dma_bus_clk), .*);
   rvdffe   #(.WIDTH(32)) wrbuf_addrff(.din(dma_axi_awaddr[31:0]), .dout(wrbuf_addr[31:0]), .en(wrbuf_en & dma_bus_clk_en), .*);
   rvdffe   #(.WIDTH(64)) wrbuf_dataff(.din(dma_axi_wdata[63:0]), .dout(wrbuf_data[63:0]), .en(wrbuf_data_en & dma_bus_clk_en), .*);
   rvdffs   #(.WIDTH(8)) wrbuf_byteenff(.din(dma_axi_wstrb[7:0]), .dout(wrbuf_byteen[7:0]), .en(wrbuf_data_en), .clk(dma_bus_clk), .*);










      assign rdbuf_en    = dma_axi_arvalid & dma_axi_arready;
   assign rdbuf_cmd_sent = bus_cmd_sent & ~bus_cmd_write;
   assign rdbuf_rst   = rdbuf_cmd_sent & ~rdbuf_en;



  rvdffsc  #(.WIDTH(1))  rdbuf_vldff(.din(1'b1), .dout(rdbuf_vld), .en(rdbuf_en), .clear(rdbuf_rst), .clk(dma_bus_clk), .*);
   rvdffs   #(.WIDTH(pt.DMA_BUS_TAG)) rdbuf_tagff(.din(dma_axi_arid[pt.DMA_BUS_TAG-1:0]), .dout(rdbuf_tag[pt.DMA_BUS_TAG-1:0]), .en(rdbuf_en), .clk(dma_bus_clk), .*);
   rvdffs   #(.WIDTH(3)) rdbuf_szff(.din(dma_axi_arsize[2:0]), .dout(rdbuf_sz[2:0]), .en(rdbuf_en), .clk(dma_bus_clk), .*);
   rvdffe   #(.WIDTH(32)) rdbuf_addrff(.din(dma_axi_araddr[31:0]), .dout(rdbuf_addr[31:0]), .en(rdbuf_en & dma_bus_clk_en), .*);



   assign dma_axi_awready = ~(wrbuf_vld & ~wrbuf_cmd_sent);
   assign dma_axi_wready  = ~(wrbuf_data_vld & ~wrbuf_cmd_sent);
   assign dma_axi_arready = ~(rdbuf_vld & ~rdbuf_cmd_sent);

      assign bus_cmd_valid                     = (wrbuf_vld & wrbuf_data_vld) | rdbuf_vld;
   assign bus_cmd_sent                      = bus_cmd_valid & dma_fifo_ready;
   assign bus_cmd_write                     = axi_mstr_sel;
   assign bus_cmd_posted_write              = '0;
   assign bus_cmd_addr[31:0]                = axi_mstr_sel ? wrbuf_addr[31:0] : rdbuf_addr[31:0];
   assign bus_cmd_sz[2:0]                   = axi_mstr_sel ? wrbuf_sz[2:0] : rdbuf_sz[2:0];
   assign bus_cmd_wdata[63:0]               = wrbuf_data[63:0];
   assign bus_cmd_byteen[7:0]               = wrbuf_byteen[7:0];
   assign bus_cmd_tag[pt.DMA_BUS_TAG-1:0]   = axi_mstr_sel ? wrbuf_tag[pt.DMA_BUS_TAG-1:0] : rdbuf_tag[pt.DMA_BUS_TAG-1:0];
   assign bus_cmd_mid[pt.DMA_BUS_ID-1:0]    = '0;
   assign bus_cmd_prty[pt.DMA_BUS_PRTY-1:0] = '0;

      assign axi_mstr_sel     = (wrbuf_vld & wrbuf_data_vld & rdbuf_vld) ? axi_mstr_priority : (wrbuf_vld & wrbuf_data_vld);
   assign axi_mstr_prty_in = ~axi_mstr_priority;
   assign axi_mstr_prty_en = bus_cmd_sent;

  rvdffs #(.WIDTH(1)) mstr_prtyff(.din(axi_mstr_prty_in), .dout(axi_mstr_priority), .en(axi_mstr_prty_en), .clk(dma_bus_clk), .*);



   assign axi_rsp_valid                   = fifo_valid[RspPtr] & ~fifo_dbg[RspPtr] & fifo_done_bus[RspPtr];
   assign axi_rsp_rdata[63:0]             = fifo_data[RspPtr];
   assign axi_rsp_write                   = fifo_write[RspPtr];
   assign axi_rsp_posted_write            = axi_rsp_write & fifo_posted_write[RspPtr];
   assign axi_rsp_error[1:0]              = fifo_error[RspPtr][0] ? 2'b10 : (fifo_error[RspPtr][1] ? 2'b11 : 2'b0);
   assign axi_rsp_tag[pt.DMA_BUS_TAG-1:0] = fifo_tag[RspPtr];

      assign dma_axi_bvalid                  = axi_rsp_valid & axi_rsp_write;
   assign dma_axi_bresp[1:0]              = axi_rsp_error[1:0];
   assign dma_axi_bid[pt.DMA_BUS_TAG-1:0] = axi_rsp_tag[pt.DMA_BUS_TAG-1:0];

   assign dma_axi_rvalid                  = axi_rsp_valid & ~axi_rsp_write;
   assign dma_axi_rresp[1:0]              = axi_rsp_error;
   assign dma_axi_rdata[63:0]             = axi_rsp_rdata[63:0];
   assign dma_axi_rlast                   = 1'b1;
   assign dma_axi_rid[pt.DMA_BUS_TAG-1:0] = axi_rsp_tag[pt.DMA_BUS_TAG-1:0];

   assign bus_posted_write_done = 1'b0;
   assign bus_rsp_valid      = (dma_axi_bvalid | dma_axi_rvalid);
   assign bus_rsp_sent       = (dma_axi_bvalid & dma_axi_bready) | (dma_axi_rvalid & dma_axi_rready);

`ifdef ASSERT_ON

   for (genvar i=0; i<DEPTH; i++) begin
   end











`endif

endmodule : eh2_dma_ctrl 