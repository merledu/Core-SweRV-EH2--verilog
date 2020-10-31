module ahb_to_axi4
import eh2_pkg::*;
#(
   TAG = 1,
   `include "eh2_param.vh"
)
(
   input                   clk,
   input                   rst_l,
   input                   scan_mode,
   input                   bus_clk_en,
   input                   clk_override,

         output logic            axi_awvalid,
   input wire axi_awready,
   output logic [TAG-1:0]  axi_awid,
   output logic [31:0]     axi_awaddr,
   output logic [2:0]      axi_awsize,
   output logic [2:0]      axi_awprot,
   output logic [7:0]      axi_awlen,
   output logic [1:0]      axi_awburst,

   output logic            axi_wvalid,
   input wire axi_wready,
   output logic [63:0]     axi_wdata,
   output logic [7:0]      axi_wstrb,
   output logic            axi_wlast,

   input wire axi_bvalid,
   output logic            axi_bready,
   input wire [1:0]      axi_bresp,
   input wire [TAG-1:0]  axi_bid,

      output logic            axi_arvalid,
   input wire axi_arready,
   output logic [TAG-1:0]  axi_arid,
   output logic [31:0]     axi_araddr,
   output logic [2:0]      axi_arsize,
   output logic [2:0]      axi_arprot,
   output logic [7:0]      axi_arlen,
   output logic [1:0]      axi_arburst,

   input wire axi_rvalid,
   output logic            axi_rready,
   input wire [TAG-1:0]  axi_rid,
   input wire [63:0]     axi_rdata,
   input wire [1:0]      axi_rresp,

      input wire [31:0]      ahb_haddr,        input wire [2:0]       ahb_hburst,       input wire ahb_hmastlock,    input wire [3:0]       ahb_hprot,        input wire [2:0]       ahb_hsize,        input wire [1:0]       ahb_htrans,       input wire ahb_hwrite,       input wire [63:0]      ahb_hwdata,       input wire ahb_hsel,         input wire ahb_hreadyin,  
   output logic [63:0]      ahb_hrdata,         output logic             ahb_hreadyout,      output logic             ahb_hresp        
);

   wire [7:0]       master_wstrb;

localparam IDLE = 'd 0 ;localparam WR = 'd 1 ;localparam RD = 'd 2 ;localparam PEND = 'd 3 ;   state_t      buf_state, buf_nxtstate;
   reg        buf_state_en;

reg buf_read_error_in;
reg buf_read_error;
   wire [63:0]             buf_rdata;

   wire                    ahb_hready;
   reg                    ahb_hready_q;
wire [1:0] ahb_htrans_in;
reg [1:0] ahb_htrans_q;
   reg [2:0]              ahb_hsize_q;
   reg                    ahb_hwrite_q;
   reg [31:0]             ahb_haddr_q;
   reg [63:0]             ahb_hwdata_q;
   reg                    ahb_hresp_q;

reg ahb_addr_in_dccm;
wire ahb_addr_in_iccm;
reg ahb_addr_in_pic;
reg ahb_addr_in_dccm_region_nc;
wire ahb_addr_in_iccm_region_nc;
reg ahb_addr_in_pic_region_nc;
      reg                    buf_rdata_en;

wire ahb_bus_addr_clk_en;
wire buf_rdata_clk_en;
reg ahb_clk;
reg ahb_addr_clk;
wire buf_rdata_clk;
reg cmdbuf_wr_en;
wire cmdbuf_rst;
   wire                    cmdbuf_full;
reg cmdbuf_vld;
reg cmdbuf_write;
   reg [1:0]              cmdbuf_size;
   reg [7:0]              cmdbuf_wstrb;
   reg [31:0]             cmdbuf_addr;
   reg [63:0]             cmdbuf_wdata;

   reg                    bus_clk;

   always @* begin
      buf_nxtstate      = IDLE;
      buf_state_en      = 1'b0;
      buf_rdata_en      = 1'b0;                    buf_read_error_in = 1'b0;                    cmdbuf_wr_en      = 1'b0;                    case (buf_state)
         IDLE: begin                    buf_nxtstate      = ahb_hwrite ? WR : RD;
                  buf_state_en      = ahb_hready & ahb_htrans[1] & ahb_hsel;                           end
         WR: begin                   buf_nxtstate      = (ahb_hresp | (ahb_htrans[1:0] == 2'b0) | ~ahb_hsel) ? IDLE : ahb_hwrite  ? WR : RD;
                  buf_state_en      = (~cmdbuf_full | ahb_hresp) ;
                  cmdbuf_wr_en      = ~cmdbuf_full & ~(ahb_hresp | ((ahb_htrans[1:0] == 2'b01) & ahb_hsel));            end
         RD: begin                  buf_nxtstate      = ahb_hresp ? IDLE :PEND;                                                        buf_state_en      = (~cmdbuf_full | ahb_hresp);                                                    cmdbuf_wr_en      = ~ahb_hresp & ~cmdbuf_full;                                             end
         PEND: begin                  buf_nxtstate      = IDLE;                                                                           buf_state_en      = axi_rvalid & ~cmdbuf_write;                                                     buf_rdata_en      = buf_state_en;                                                                   buf_read_error_in = buf_state_en & |axi_rresp[1:0];                                         end
     endcase
   end 
    rvdffs #($bits(state_t)) state_reg (.*, .din(buf_nxtstate), .dout({buf_state}), .en(buf_state_en), .clk(ahb_clk));

   assign master_wstrb[7:0]   = ({8{ahb_hsize_q[2:0] == 3'b0}}  & (8'b1    << ahb_haddr_q[2:0])) |
                                ({8{ahb_hsize_q[2:0] == 3'b1}}  & (8'b11   << ahb_haddr_q[2:0])) |
                                ({8{ahb_hsize_q[2:0] == 3'b10}} & (8'b1111 << ahb_haddr_q[2:0])) |
                                ({8{ahb_hsize_q[2:0] == 3'b11}} & 8'b1111_1111);

      assign ahb_hreadyout       = ahb_hresp ? (ahb_hresp_q & ~ahb_hready_q) :
                                         ((~cmdbuf_full | (buf_state == IDLE)) & ~(buf_state == RD | buf_state == PEND)  & ~buf_read_error);

   assign ahb_hready          = ahb_hreadyout & ahb_hreadyin;
   assign ahb_htrans_in[1:0]  = {2{ahb_hsel}} & ahb_htrans[1:0];
   assign ahb_hrdata[63:0]    = buf_rdata[63:0];
   assign ahb_hresp        = ((ahb_htrans_q[1:0] != 2'b0) & (buf_state != IDLE)  &

                             ((~(ahb_addr_in_dccm | ahb_addr_in_iccm)) |                                                                                                                ((ahb_addr_in_iccm | (ahb_addr_in_dccm &  ahb_hwrite_q)) & ~((ahb_hsize_q[1:0] == 2'b10) | (ahb_hsize_q[1:0] == 2'b11))) |                                 ((ahb_hsize_q[2:0] == 3'h1) & ahb_haddr_q[0])   |                                                                                                          ((ahb_hsize_q[2:0] == 3'h2) & (|ahb_haddr_q[1:0])) |                                                                                                       ((ahb_hsize_q[2:0] == 3'h3) & (|ahb_haddr_q[2:0])))) |                                                                                                     buf_read_error |                                                                                                                                           (ahb_hresp_q & ~ahb_hready_q);

   
   rvdff  #(.WIDTH(64)) buf_rdata_ff     (.din(axi_rdata[63:0]),  .dout(buf_rdata[63:0]), .clk(buf_rdata_clk), .*);
   rvdff  #(.WIDTH(1))  buf_read_error_ff(.din(buf_read_error_in),  .dout(buf_read_error),  .clk(ahb_clk),       .*);          // buf_read_error will be high only one cycle

   // All the Master signals are captured before presenting it to the command buffer. We check for Hresp before sending it to the cmd buffer.
   rvdff  #(.WIDTH(1))    hresp_ff  (.din(ahb_hresp),          .dout(ahb_hresp_q),       .clk(ahb_clk),      .*);
   rvdff  #(.WIDTH(1))    hready_ff (.din(ahb_hready),         .dout(ahb_hready_q),      .clk(ahb_clk),      .*);
   rvdff  #(.WIDTH(2))    htrans_ff (.din(ahb_htrans_in[1:0]), .dout(ahb_htrans_q[1:0]), .clk(ahb_clk),      .*);
   rvdff  #(.WIDTH(3))    hsize_ff  (.din(ahb_hsize[2:0]),     .dout(ahb_hsize_q[2:0]),  .clk(ahb_addr_clk), .*);
   rvdff  #(.WIDTH(1))    hwrite_ff (.din(ahb_hwrite),         .dout(ahb_hwrite_q),      .clk(ahb_addr_clk), .*);
   rvdff  #(.WIDTH(32))   haddr_ff  (.din(ahb_haddr[31:0]),    .dout(ahb_haddr_q[31:0]), .clk(ahb_addr_clk), .*);

   // Clock header logic
   assign ahb_bus_addr_clk_en = bus_clk_en & (ahb_hready & ahb_htrans[1]);
   assign buf_rdata_clk_en    = bus_clk_en & buf_rdata_en;

   rvclkhdr ahb_cgc       (.en(bus_clk_en),          .l1clk(ahb_clk),       .*);
   rvclkhdr ahb_addr_cgc  (.en(ahb_bus_addr_clk_en), .l1clk(ahb_addr_clk),  .*);
   rvclkhdr buf_rdata_cgc (.en(buf_rdata_clk_en),    .l1clk(buf_rdata_clk), .*);

   // Address check  dccm
   rvrangecheck #(.CCM_SADR(pt.DCCM_SADR),
                  .CCM_SIZE(pt.DCCM_SIZE)) addr_dccm_rangecheck (
      .addr(ahb_haddr_q[31:0]),
      .in_range(ahb_addr_in_dccm),
      .in_region(ahb_addr_in_dccm_region_nc)
   );



      if (pt.ICCM_ENABLE == 1) begin: GenICCM
               rvrangecheck #(.CCM_SADR(pt.ICCM_SADR),
                     .CCM_SIZE(pt.ICCM_SIZE)) addr_iccm_rangecheck (
         .addr(ahb_haddr_q[31:0]),
         .in_range(ahb_addr_in_iccm),
         .in_region(ahb_addr_in_iccm_region_nc)
      );

   end else begin: GenNoICCM
      assign ahb_addr_in_iccm = '0;
      assign ahb_addr_in_iccm_region_nc = '0;
   end

   rvrangecheck #(.CCM_SADR(pt.PIC_BASE_ADDR),
                  .CCM_SIZE(pt.PIC_SIZE)) addr_pic_rangecheck (
      .addr(ahb_haddr_q[31:0]),
      .in_range(ahb_addr_in_pic),
      .in_region(ahb_addr_in_pic_region_nc)
   );

      assign cmdbuf_rst         = (((axi_awvalid & axi_awready) | (axi_arvalid & axi_arready)) & ~cmdbuf_wr_en) | (ahb_hresp & ~cmdbuf_write);
   assign cmdbuf_full        = (cmdbuf_vld & ~((axi_awvalid & axi_awready) | (axi_arvalid & axi_arready)));

   rvdffsc #(.WIDTH(1))   cmdbuf_vldff      (.din(1'b1),                .dout(cmdbuf_vld),          .en(cmdbuf_wr_en),   .clear(cmdbuf_rst),      .clk(bus_clk), .*);
   rvdffs  #(.WIDTH(1))   cmdbuf_writeff    (.din(ahb_hwrite_q),        .dout(cmdbuf_write),        .en(cmdbuf_wr_en),   .clk(bus_clk), .*);
   rvdffs  #(.WIDTH(2))   cmdbuf_sizeff     (.din(ahb_hsize_q[1:0]),    .dout(cmdbuf_size[1:0]),    .en(cmdbuf_wr_en),   .clk(bus_clk), .*);
   rvdffs  #(.WIDTH(8))   cmdbuf_wstrbff    (.din(master_wstrb[7:0]),   .dout(cmdbuf_wstrb[7:0]),   .en(cmdbuf_wr_en),   .clk(bus_clk), .*);
   rvdffe  #(.WIDTH(32))  cmdbuf_addrff     (.din(ahb_haddr_q[31:0]),   .dout(cmdbuf_addr[31:0]),   .en(cmdbuf_wr_en),   .clk(bus_clk), .*);
   rvdffe  #(.WIDTH(64))  cmdbuf_wdataff    (.din(ahb_hwdata[63:0]),    .dout(cmdbuf_wdata[63:0]),  .en(cmdbuf_wr_en),   .clk(bus_clk), .*);


      assign axi_awvalid           = cmdbuf_vld & cmdbuf_write;
   assign axi_awid[TAG-1:0]     = '0;
   assign axi_awaddr[31:0]      = cmdbuf_addr[31:0];
   assign axi_awsize[2:0]       = {1'b0, cmdbuf_size[1:0]};
   assign axi_awprot[2:0]       = 3'b0;
   assign axi_awlen[7:0]        = '0;
   assign axi_awburst[1:0]      = 2'b01;
      assign axi_wvalid            = cmdbuf_vld & cmdbuf_write;
   assign axi_wdata[63:0]       = cmdbuf_wdata[63:0];
   assign axi_wstrb[7:0]        = cmdbuf_wstrb[7:0];
   assign axi_wlast             = 1'b1;
     assign axi_bready            = 1'b1;
      assign axi_arvalid           = cmdbuf_vld & ~cmdbuf_write;
   assign axi_arid[TAG-1:0]     = '0;
   assign axi_araddr[31:0]      = cmdbuf_addr[31:0];
   assign axi_arsize[2:0]       = {1'b0, cmdbuf_size[1:0]};
   assign axi_arprot            = 3'b0;
   assign axi_arlen[7:0]        = '0;
   assign axi_arburst[1:0]      = 2'b01;
      assign axi_rready            = 1'b1;

   rvclkhdr bus_cgc        (.en(bus_clk_en),       .l1clk(bus_clk),       .*);

`ifdef ASSERT_ON

`endif

endmodule 