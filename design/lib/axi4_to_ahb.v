
module axi4_to_ahb
    import eh2_pkg::*;
#(
`include "eh2_param.vh"
parameter TAG  = 1)
(

   input                   clk,
   input                   rst_l,
   input                   scan_mode,
   input                   bus_clk_en,
   input                   clk_override,

         input wire axi_awvalid,
   output logic            axi_awready,
   input wire [TAG-1:0]  axi_awid,
   input wire [31:0]     axi_awaddr,
   input wire [2:0]      axi_awsize,
   input wire [2:0]      axi_awprot,

   input wire axi_wvalid,
   output logic            axi_wready,
   input wire [63:0]     axi_wdata,
   input wire [7:0]      axi_wstrb,
   input wire axi_wlast,

   output logic            axi_bvalid,
   input wire axi_bready,
   output logic [1:0]      axi_bresp,
   output logic [TAG-1:0]  axi_bid,

      input wire axi_arvalid,
   output logic            axi_arready,
   input wire [TAG-1:0]  axi_arid,
   input wire [31:0]     axi_araddr,
   input wire [2:0]      axi_arsize,
   input wire [2:0]      axi_arprot,

   output logic            axi_rvalid,
   input wire axi_rready,
   output logic [TAG-1:0]  axi_rid,
   output logic [63:0]     axi_rdata,
   output logic [1:0]      axi_rresp,
   output logic            axi_rlast,

      output logic [31:0]     ahb_haddr,          output logic [2:0]      ahb_hburst,         output logic            ahb_hmastlock,      output logic [3:0]      ahb_hprot,          output logic [2:0]      ahb_hsize,          output logic [1:0]      ahb_htrans,         output logic            ahb_hwrite,         output logic [63:0]     ahb_hwdata,      
   input wire [63:0]      ahb_hrdata,         input wire ahb_hready,         input wire ahb_hresp        
);

   localparam ID   = 1;
   localparam PRTY = 1;
localparam IDLE = 'd 0 ;localparam CMD_RD = 'd 1 ;localparam CMD_WR = 'd 2 ;localparam DATA_RD = 'd 3 ;localparam DATA_WR = 'd 4 ;localparam DONE = 'd 5 ;localparam STREAM_RD = 'd 6 ;localparam STREAM_ERR_RD = 'd 7 ;   state_t buf_state, buf_nxtstate;

   wire             slave_valid;
   wire             slave_ready;
   wire [TAG-1:0]   slave_tag;
   wire [63:0]      slave_rdata;
   wire [3:0]       slave_opc;

wire wrbuf_en;
wire wrbuf_data_en;
wire wrbuf_cmd_sent;
wire wrbuf_rst;
   reg             wrbuf_vld;
   reg             wrbuf_data_vld;
   reg [TAG-1:0]   wrbuf_tag;
   reg [2:0]       wrbuf_size;
   reg [31:0]      wrbuf_addr;
   wire [63:0]      wrbuf_data;
   reg [7:0]       wrbuf_byteen;

   wire             bus_write_clk_en;
reg bus_clk;
wire bus_write_clk;

   wire             master_valid;
   reg             master_ready;
   wire [TAG-1:0]   master_tag;
   wire [31:0]      master_addr;
   wire [63:0]      master_wdata;
   wire [2:0]       master_size;
   wire [2:0]       master_opc;
   wire [7:0]       master_byteen;

      wire [31:0]                buf_addr;
   wire [1:0]                 buf_size;
   reg                       buf_write;
   wire [7:0]                 buf_byteen;
   wire                       buf_aligned;
   wire [63:0]                buf_data;
   wire [TAG-1:0]             buf_tag;

      wire                       buf_rst;
   wire [TAG-1:0]             buf_tag_in;
   wire [31:0]                buf_addr_in;
   wire [7:0]                 buf_byteen_in;
   wire [63:0]                buf_data_in;
   reg                       buf_write_in;
   wire                       buf_aligned_in;
   wire [2:0]                 buf_size_in;

   reg                       buf_state_en;
   reg                       buf_wr_en;
   reg                       buf_data_wr_en;
   reg                       slvbuf_error_en;
   wire                       wr_cmd_vld;

wire cmd_done_rst;
wire cmd_done;
reg cmd_doneQ;
   reg                       trxn_done;
reg [2:0] buf_cmd_byte_ptr;
reg [2:0] buf_cmd_byte_ptrQ;
reg [2:0] buf_cmd_nxtbyte_ptr;
   reg                       buf_cmd_byte_ptr_en;
   reg                       found;

   reg                       slave_valid_pre;
   reg                       ahb_hready_q;
   reg                       ahb_hresp_q;
   reg [1:0]                 ahb_htrans_q;
   reg                       ahb_hwrite_q;
   reg [63:0]                ahb_hrdata_q;


   reg                       slvbuf_write;
   reg                       slvbuf_error;
   reg [TAG-1:0]             slvbuf_tag;

   reg                       slvbuf_error_in;
   reg                       slvbuf_wr_en;
   reg                       bypass_en;
   reg                       rd_bypass_idle;

   wire                       last_addr_en;
   reg [31:0]                last_bus_addr;

wire buf_clken;
reg slvbuf_clken;
   wire                       ahbm_addr_clken;
   wire                       ahbm_data_clken;

wire buf_clk;
reg slvbuf_clk;
   reg                       ahbm_clk;
   wire                       ahbm_addr_clk;
   wire                       ahbm_data_clk;
wire [1:0]       size;
      function automatic [1:0] get_write_size;
      input [7:0] byteen;


      size[1:0] = (2'b11 & {2{(byteen[7:0] == 8'hff)}}) |
                  (2'b10 & {2{((byteen[7:0] == 8'hf0) | (byteen[7:0] == 8'h0f))}}) |
                  (2'b01 & {2{((byteen[7:0] == 8'hc0) | (byteen[7:0] == 8'h30) | (byteen[7:0] == 8'h0c) | (byteen[7:0] == 8'h03))}});
      return size[1:0];
   endfunction 
      wire [2:0]       addr;

      function automatic [2:0] get_write_addr;
      input [7:0] byteen;


      addr[2:0] = (3'h0 & {3{((byteen[7:0] == 8'hff) | (byteen[7:0] == 8'h0f) | (byteen[7:0] == 8'h03))}}) |
                  (3'h2 & {3{(byteen[7:0] == 8'h0c)}})                                                     |
                  (3'h4 & {3{((byteen[7:0] == 8'hf0) | (byteen[7:0] == 8'h03))}})                          |
                  (3'h6 & {3{(byteen[7:0] == 8'hc0)}});

      return addr[2:0];
   endfunction 
function automatic [2:0] get_nxtbyte_ptr (reg [2:0] current_byte_ptr, reg [7:0] byteen, reg get_next);
      logic [2:0] start_ptr;
      logic       found;
      found = '0;
      start_ptr[2:0] = get_next ? (current_byte_ptr[2:0] + 3'b1) : current_byte_ptr[2:0];
      for (int j=0; j<8; j++) begin
         if (~found) begin
            get_nxtbyte_ptr[2:0] = 3'(j);
            found |= (byteen[j] & (3'(j) >= start_ptr[2:0])) ;
         end
      end
   endfunction // get_nextbyte_ptr

      assign wrbuf_en       = axi_awvalid & axi_awready & master_ready;
   assign wrbuf_data_en  = axi_wvalid & axi_wready & master_ready;
   assign wrbuf_cmd_sent = master_valid & master_ready & (master_opc[2:1] == 2'b01);
   assign wrbuf_rst      = wrbuf_cmd_sent & ~wrbuf_en;

   assign axi_awready = ~(wrbuf_vld & ~wrbuf_cmd_sent) & master_ready;
   assign axi_wready  = ~(wrbuf_data_vld & ~wrbuf_cmd_sent) & master_ready;
   assign axi_arready = ~(wrbuf_vld & wrbuf_data_vld) & master_ready;
   assign axi_rlast   = 1'b1;

   assign wr_cmd_vld          = (wrbuf_vld & wrbuf_data_vld);
   assign master_valid        = wr_cmd_vld | axi_arvalid;
   assign master_tag[TAG-1:0] = wr_cmd_vld ? wrbuf_tag[TAG-1:0] : axi_arid[TAG-1:0];
   assign master_opc[2:0]     = wr_cmd_vld ? 3'b011 : 3'b0;
   assign master_addr[31:0]   = wr_cmd_vld ? wrbuf_addr[31:0] : axi_araddr[31:0];
   assign master_size[2:0]    = wr_cmd_vld ? wrbuf_size[2:0] : axi_arsize[2:0];
   assign master_byteen[7:0]  = wrbuf_byteen[7:0];
   assign master_wdata[63:0]  = wrbuf_data[63:0];

      assign axi_bvalid       = slave_valid & slave_ready & slave_opc[3];
   assign axi_bresp[1:0]   = slave_opc[0] ? 2'b10 : (slave_opc[1] ? 2'b11 : 2'b0);
   assign axi_bid[TAG-1:0] = slave_tag[TAG-1:0];

   assign axi_rvalid       = slave_valid & slave_ready & (slave_opc[3:2] == 2'b0);
   assign axi_rresp[1:0]   = slave_opc[0] ? 2'b10 : (slave_opc[1] ? 2'b11 : 2'b0);
   assign axi_rid[TAG-1:0] = slave_tag[TAG-1:0];
   assign axi_rdata[63:0]  = slave_rdata[63:0];
   assign slave_ready        = axi_bready & axi_rready;

      assign bus_write_clk_en = bus_clk_en & ((axi_awvalid & axi_awready) | (axi_wvalid & axi_wready));

   rvclkhdr bus_cgc        (.en(bus_clk_en),       .l1clk(bus_clk),       .*);
   rvclkhdr bus_write_cgc  (.en(bus_write_clk_en), .l1clk(bus_write_clk),  .*);


    always @* begin
      buf_nxtstate   = IDLE;
      buf_state_en   = 1'b0;
      buf_wr_en      = 1'b0;
      buf_data_wr_en = 1'b0;
      slvbuf_error_in   = 1'b0;
      slvbuf_error_en   = 1'b0;
      buf_write_in   = 1'b0;
      cmd_done       = 1'b0;
      trxn_done      = 1'b0;
      buf_cmd_byte_ptr_en = 1'b0;
      buf_cmd_byte_ptr[2:0] = '0;
      slave_valid_pre   = 1'b0;
      master_ready   = 1'b0;
      ahb_htrans[1:0]  = 2'b0;
      slvbuf_wr_en     = 1'b0;
      bypass_en        = 1'b0;
      rd_bypass_idle   = 1'b0;

      case (buf_state)
         IDLE: begin
                  master_ready   = 1'b1;
                  buf_write_in = (master_opc[2:1] == 2'b01);
                  buf_nxtstate = buf_write_in ? CMD_WR : CMD_RD;
                  buf_state_en = master_valid & master_ready;
                  buf_wr_en    = buf_state_en;
                  buf_data_wr_en = buf_state_en & (buf_nxtstate == CMD_WR);
                  buf_cmd_byte_ptr_en   = buf_state_en;
                  buf_cmd_byte_ptr[2:0] = buf_write_in ? get_nxtbyte_ptr(3'b0,buf_byteen_in[7:0],1'b0) : master_addr[2:0];
                  bypass_en       = buf_state_en;
                  rd_bypass_idle  = bypass_en & (buf_nxtstate == CMD_RD);
                  ahb_htrans[1:0] = {2{bypass_en}} & 2'b10;
          end
         CMD_RD: begin
                  buf_nxtstate    = (master_valid & (master_opc[2:0] == 3'b000))? STREAM_RD : DATA_RD;
                  buf_state_en    = ahb_hready_q & (ahb_htrans_q[1:0] != 2'b0) & ~ahb_hwrite_q;
                  cmd_done        = buf_state_en & ~master_valid;
                  slvbuf_wr_en    = buf_state_en;
                  master_ready  = buf_state_en & (buf_nxtstate == STREAM_RD);
                  buf_wr_en       = master_ready;
                  bypass_en       = master_ready & master_valid;
                  buf_cmd_byte_ptr[2:0] = bypass_en ? master_addr[2:0] : buf_addr[2:0];
                  ahb_htrans[1:0] = 2'b10 & {2{~buf_state_en | bypass_en}};
         end
         STREAM_RD: begin
                  master_ready  =  (ahb_hready_q & ~ahb_hresp_q) & ~(master_valid & master_opc[2:1] == 2'b01);
                  buf_wr_en       = (master_valid & master_ready & (master_opc[2:0] == 3'b000));                   buf_nxtstate    = ahb_hresp_q ? STREAM_ERR_RD : (buf_wr_en ? STREAM_RD : DATA_RD);                              buf_state_en    = (ahb_hready_q | ahb_hresp_q);
                  buf_data_wr_en  = buf_state_en;
                  slvbuf_error_in = ahb_hresp_q;
                  slvbuf_error_en = buf_state_en;
                  slave_valid_pre  = buf_state_en & ~ahb_hresp_q;                               cmd_done        = buf_state_en & ~master_valid;                                       bypass_en       = master_ready & master_valid & (buf_nxtstate == STREAM_RD) & buf_state_en;
                  buf_cmd_byte_ptr[2:0] = bypass_en ? master_addr[2:0] : buf_addr[2:0];
                  ahb_htrans[1:0] = 2'b10 & {2{~((buf_nxtstate != STREAM_RD) & buf_state_en)}};
                  slvbuf_wr_en    = buf_wr_en;                                                  end          STREAM_ERR_RD: begin
                  buf_nxtstate = DATA_RD;
                  buf_state_en = ahb_hready_q & (ahb_htrans_q[1:0] != 2'b0) & ~ahb_hwrite_q;
                  slave_valid_pre = buf_state_en;
                  slvbuf_wr_en   = buf_state_en;                       buf_cmd_byte_ptr[2:0] = buf_addr[2:0];
                  ahb_htrans[1:0] = 2'b10 & {2{~buf_state_en}};
         end
         DATA_RD: begin
                  buf_nxtstate   = DONE;
                  buf_state_en   = (ahb_hready_q | ahb_hresp_q);
                  buf_data_wr_en = buf_state_en;
                  slvbuf_error_in= ahb_hresp_q;
                  slvbuf_error_en= buf_state_en;
                  slvbuf_wr_en   = buf_state_en;

         end
         CMD_WR: begin
                  buf_nxtstate = DATA_WR;
                  trxn_done    = ahb_hready_q & ahb_hwrite_q & (ahb_htrans_q[1:0] != 2'b0);
                  buf_state_en = trxn_done;
                  buf_cmd_byte_ptr_en = buf_state_en;
                  slvbuf_wr_en    = buf_state_en;
                  buf_cmd_byte_ptr    = trxn_done ? get_nxtbyte_ptr(buf_cmd_byte_ptrQ[2:0],buf_byteen[7:0],1'b1) : buf_cmd_byte_ptrQ;
                  cmd_done            = trxn_done & (buf_aligned | (buf_cmd_byte_ptrQ == 3'b111) |
                                                     (buf_byteen[get_nxtbyte_ptr(buf_cmd_byte_ptrQ[2:0],buf_byteen[7:0],1'b1)] == 1'b0));
                  ahb_htrans[1:0] = {2{~(cmd_done | cmd_doneQ)}} & 2'b10;
         end
         DATA_WR: begin
                  buf_state_en = (cmd_doneQ & ahb_hready_q) | ahb_hresp_q;
                  master_ready = buf_state_en & ~ahb_hresp_q & slave_ready;                     buf_nxtstate = (ahb_hresp_q | ~slave_ready) ? DONE :
                                  ((master_valid & master_ready) ? ((master_opc[2:1] == 2'b01) ? CMD_WR : CMD_RD) : IDLE);
                  slvbuf_error_in = ahb_hresp_q;
                  slvbuf_error_en = buf_state_en;

                  buf_write_in = (master_opc[2:1] == 2'b01);
                  buf_wr_en = buf_state_en & ((buf_nxtstate == CMD_WR) | (buf_nxtstate == CMD_RD));
                  buf_data_wr_en = buf_wr_en;

                  cmd_done     = (ahb_hresp_q | (ahb_hready_q & (ahb_htrans_q[1:0] != 2'b0) &
                                 ((buf_cmd_byte_ptrQ == 3'b111) | (buf_byteen[get_nxtbyte_ptr(buf_cmd_byte_ptrQ[2:0],buf_byteen[7:0],1'b1)] == 1'b0))));
                  bypass_en       = buf_state_en & buf_write_in & (buf_nxtstate == CMD_WR);                     ahb_htrans[1:0] = {2{(~(cmd_done | cmd_doneQ) | bypass_en)}} & 2'b10;
                  slave_valid_pre  = buf_state_en & (buf_nxtstate != DONE);

                  trxn_done = ahb_hready_q & ahb_hwrite_q & (ahb_htrans_q[1:0] != 2'b0);
                  buf_cmd_byte_ptr_en = trxn_done | bypass_en;
                  buf_cmd_byte_ptr = bypass_en ? get_nxtbyte_ptr(3'b0,buf_byteen_in[7:0],1'b0) :
                                                 trxn_done ? get_nxtbyte_ptr(buf_cmd_byte_ptrQ[2:0],buf_byteen[7:0],1'b1) : buf_cmd_byte_ptrQ;
            end
         DONE: begin
                  buf_nxtstate = IDLE;
                  buf_state_en = slave_ready;
                  slvbuf_error_en = 1'b1;
                  slave_valid_pre = 1'b1;
         end
      endcase
   end

   assign buf_rst              = 1'b0;
   assign cmd_done_rst         = slave_valid_pre;
   assign buf_addr_in[31:3]    = master_addr[31:3];
   assign buf_addr_in[2:0]     = (buf_aligned_in & (master_opc[2:1] == 2'b01)) ? get_write_addr(master_byteen[7:0]) : master_addr[2:0];
   assign buf_tag_in[TAG-1:0]  = master_tag[TAG-1:0];
   assign buf_byteen_in[7:0]   = wrbuf_byteen[7:0];
   assign buf_data_in[63:0]    = (buf_state == DATA_RD) ? ahb_hrdata_q[63:0] : master_wdata[63:0];
   assign buf_size_in[1:0]     = (buf_aligned_in & (master_size[1:0] == 2'b11) & (master_opc[2:1] == 2'b01)) ? get_write_size(master_byteen[7:0]) : master_size[1:0];
   assign buf_aligned_in       = (master_opc[2:0] == 3'b0)    |                                    (master_size[1:0] == 2'b0) |  (master_size[1:0] == 2'b01) | (master_size[1:0] == 2'b10) |                                  ((master_size[1:0] == 2'b11) &
                                  ((master_byteen[7:0] == 8'h3)  | (master_byteen[7:0] == 8'hc)   | (master_byteen[7:0] == 8'h30) | (master_byteen[7:0] == 8'hc0) |
                                   (master_byteen[7:0] == 8'hf)  | (master_byteen[7:0] == 8'hf0)  | (master_byteen[7:0] == 8'hff)));

      assign ahb_haddr[31:0] = bypass_en ? {master_addr[31:3],buf_cmd_byte_ptr[2:0]}  : {buf_addr[31:3],buf_cmd_byte_ptr[2:0]};
   assign ahb_hsize[2:0]  = bypass_en ? {1'b0, ({2{buf_aligned_in}} & buf_size_in[1:0])} :
                                        {1'b0, ({2{buf_aligned}} & buf_size[1:0])};      assign ahb_hburst[2:0] = 3'b0;
   assign ahb_hmastlock   = 1'b0;
   assign ahb_hprot[3:0]  = {3'b001,~axi_arprot[2]};
   assign ahb_hwrite      = bypass_en ? (master_opc[2:1] == 2'b01) : buf_write;
   assign ahb_hwdata[63:0] = buf_data[63:0];

   assign slave_valid          = slave_valid_pre;
   assign slave_opc[3:2]       = slvbuf_write ? 2'b11 : 2'b00;
   assign slave_opc[1:0]       = {2{slvbuf_error}} & 2'b10;
   assign slave_rdata[63:0]    = slvbuf_error ? {2{last_bus_addr[31:0]}} : ((buf_state == DONE) ? buf_data[63:0] : ahb_hrdata_q[63:0]);
   assign slave_tag[TAG-1:0]   = slvbuf_tag[TAG-1:0];

   assign last_addr_en = (ahb_htrans[1:0] != 2'b0) & ahb_hready & ahb_hwrite ;

   rvdffsc  #(.WIDTH(1))   wrbuf_vldff     (.din(1'b1), .dout(wrbuf_vld), .en(wrbuf_en), .clear(wrbuf_rst), .clk(bus_clk), .*);
   rvdffsc  #(.WIDTH(1))   wrbuf_data_vldff(.din(1'b1), .dout(wrbuf_data_vld), .en(wrbuf_data_en), .clear(wrbuf_rst), .clk(bus_clk), .*);
   rvdffs   #(.WIDTH(TAG)) wrbuf_tagff     (.din(axi_awid[TAG-1:0]), .dout(wrbuf_tag[TAG-1:0]), .en(wrbuf_en), .clk(bus_clk), .*);
   rvdffs   #(.WIDTH(3))   wrbuf_sizeff    (.din(axi_awsize[2:0]), .dout(wrbuf_size[2:0]), .en(wrbuf_en), .clk(bus_clk), .*);
   rvdffe   #(.WIDTH(32))  wrbuf_addrff    (.din(axi_awaddr[31:0]), .dout(wrbuf_addr[31:0]), .en(wrbuf_en), .clk(bus_clk), .*);
   rvdffe   #(.WIDTH(64))  wrbuf_dataff    (.din(axi_wdata[63:0]), .dout(wrbuf_data[63:0]), .en(wrbuf_data_en), .clk(bus_clk), .*);
   rvdffs   #(.WIDTH(8))   wrbuf_byteenff  (.din(axi_wstrb[7:0]), .dout(wrbuf_byteen[7:0]), .en(wrbuf_data_en), .clk(bus_clk), .*);

   rvdffs #(.WIDTH(32))   last_bus_addrff (.din(ahb_haddr[31:0]), .dout(last_bus_addr[31:0]), .en(last_addr_en), .clk(ahbm_clk), .*);

   rvdffsc #(.WIDTH($bits(state_t))) buf_state_ff  (.din(buf_nxtstate), .dout({buf_state}), .en(buf_state_en), .clear(buf_rst), .clk(ahbm_clk), .*);
   rvdffs #(.WIDTH(1))               buf_writeff   (.din(buf_write_in), .dout(buf_write), .en(buf_wr_en), .clk(buf_clk), .*);
   rvdffs #(.WIDTH(TAG))             buf_tagff     (.din(buf_tag_in[TAG-1:0]), .dout(buf_tag[TAG-1:0]), .en(buf_wr_en), .clk(buf_clk), .*);
   rvdffe #(.WIDTH(32))              buf_addrff    (.din(buf_addr_in[31:0]), .dout(buf_addr[31:0]), .en(buf_wr_en & bus_clk_en), .*);
   rvdffs #(.WIDTH(2))               buf_sizeff    (.din(buf_size_in[1:0]), .dout(buf_size[1:0]), .en(buf_wr_en), .clk(buf_clk), .*);
   rvdffs #(.WIDTH(1))               buf_alignedff (.din(buf_aligned_in), .dout(buf_aligned), .en(buf_wr_en), .clk(buf_clk), .*);
   rvdffs #(.WIDTH(8))               buf_byteenff  (.din(buf_byteen_in[7:0]), .dout(buf_byteen[7:0]), .en(buf_wr_en), .clk(buf_clk), .*);
   rvdffe #(.WIDTH(64))              buf_dataff    (.din(buf_data_in[63:0]), .dout(buf_data[63:0]), .en(buf_data_wr_en & bus_clk_en), .*);


   rvdffs #(.WIDTH(1))   slvbuf_writeff        (.din(buf_write), .dout(slvbuf_write), .en(slvbuf_wr_en), .clk(buf_clk), .*);
   rvdffs #(.WIDTH(TAG)) slvbuf_tagff          (.din(buf_tag[TAG-1:0]), .dout(slvbuf_tag[TAG-1:0]), .en(slvbuf_wr_en), .clk(buf_clk), .*);
   rvdffs #(.WIDTH(1))   slvbuf_errorff        (.din(slvbuf_error_in), .dout(slvbuf_error), .en(slvbuf_error_en), .clk(ahbm_clk), .*);

   rvdffsc #(.WIDTH(1)) buf_cmd_doneff     (.din(1'b1), .en(cmd_done), .dout(cmd_doneQ), .clear(cmd_done_rst), .clk(ahbm_clk), .*);
   rvdffs #(.WIDTH(3))  buf_cmd_byte_ptrff (.din(buf_cmd_byte_ptr[2:0]), .dout(buf_cmd_byte_ptrQ[2:0]), .en(buf_cmd_byte_ptr_en), .clk(ahbm_clk), .*);

   rvdff #(.WIDTH(1))  hready_ff (.din(ahb_hready), .dout(ahb_hready_q), .clk(ahbm_clk), .*);
   rvdff #(.WIDTH(2))  htrans_ff (.din(ahb_htrans[1:0]), .dout(ahb_htrans_q[1:0]), .clk(ahbm_clk), .*);
   rvdff #(.WIDTH(1))  hwrite_ff (.din(ahb_hwrite), .dout(ahb_hwrite_q), .clk(ahbm_addr_clk), .*);
   rvdff #(.WIDTH(1))  hresp_ff  (.din(ahb_hresp), .dout(ahb_hresp_q), .clk(ahbm_clk), .*);
   rvdff #(.WIDTH(64)) hrdata_ff (.din(ahb_hrdata[63:0]), .dout(ahb_hrdata_q[63:0]),  .clk(ahbm_data_clk), .*);


         assign buf_clken       = bus_clk_en & (buf_wr_en | slvbuf_wr_en | clk_override);
   assign ahbm_addr_clken = bus_clk_en & ((ahb_hready & ahb_htrans[1]) | clk_override);
   assign ahbm_data_clken = bus_clk_en & ((buf_state != IDLE) | clk_override);

   rvclkhdr buf_cgc       (.en(buf_clken), .l1clk(buf_clk), .*);
   rvclkhdr ahbm_cgc      (.en(bus_clk_en), .l1clk(ahbm_clk), .*);
   rvclkhdr ahbm_addr_cgc (.en(ahbm_addr_clken), .l1clk(ahbm_addr_clk), .*);
   rvclkhdr ahbm_data_cgc (.en(ahbm_data_clken), .l1clk(ahbm_data_clk), .*);

`ifdef ASSERT_ON

`endif

endmodule 