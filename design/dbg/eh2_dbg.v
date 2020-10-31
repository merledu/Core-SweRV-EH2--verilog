module eh2_dbg #(
`include "eh2_param.vh"
 )(
      output logic [31:0]                 dbg_cmd_addr,
   output logic [31:0]                 dbg_cmd_wrdata,
   output logic                        dbg_cmd_valid,
   output logic                        dbg_cmd_tid,        output logic                        dbg_cmd_write,      output logic [1:0]                  dbg_cmd_type,       output logic [1:0]                  dbg_cmd_size,       output logic                        dbg_core_rst_l,  
      input wire [31:0]                  core_dbg_rddata,
   input wire core_dbg_cmd_done,    input wire core_dbg_cmd_fail, 
      output logic                        dbg_dma_bubble,      input wire dma_dbg_ready,    
      output logic [pt.NUM_THREADS-1:0]   dbg_halt_req,    output logic [pt.NUM_THREADS-1:0]   dbg_resume_req,    input wire [pt.NUM_THREADS-1:0]   dec_tlu_debug_mode,           input wire [pt.NUM_THREADS-1:0]   dec_tlu_dbg_halted,    input wire [pt.NUM_THREADS-1:0]   dec_tlu_mpc_halted_only,      input wire [pt.NUM_THREADS-1:0]   dec_tlu_resume_ack,    input wire [pt.NUM_THREADS-1:0]   dec_tlu_mhartstart, 
      input wire dmi_reg_en,    input wire [6:0]                   dmi_reg_addr,    input wire dmi_reg_wr_en,    input wire [31:0]                  dmi_reg_wdata,       output logic [31:0]                 dmi_reg_rdata, 
      output logic                        sb_axi_awvalid,
   input wire sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]    sb_axi_awid,
   output logic [31:0]                 sb_axi_awaddr,
   output logic [3:0]                  sb_axi_awregion,
   output logic [7:0]                  sb_axi_awlen,
   output logic [2:0]                  sb_axi_awsize,
   output logic [1:0]                  sb_axi_awburst,
   output logic                        sb_axi_awlock,
   output logic [3:0]                  sb_axi_awcache,
   output logic [2:0]                  sb_axi_awprot,
   output logic [3:0]                  sb_axi_awqos,

   output logic                        sb_axi_wvalid,
   input wire sb_axi_wready,
   output logic [63:0]                 sb_axi_wdata,
   output logic [7:0]                  sb_axi_wstrb,
   output logic                        sb_axi_wlast,

   input wire sb_axi_bvalid,
   output logic                        sb_axi_bready,
   input wire [1:0]                  sb_axi_bresp,

      output logic                        sb_axi_arvalid,
   input wire sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]    sb_axi_arid,
   output logic [31:0]                 sb_axi_araddr,
   output logic [3:0]                  sb_axi_arregion,
   output logic [7:0]                  sb_axi_arlen,
   output logic [2:0]                  sb_axi_arsize,
   output logic [1:0]                  sb_axi_arburst,
   output logic                        sb_axi_arlock,
   output logic [3:0]                  sb_axi_arcache,
   output logic [2:0]                  sb_axi_arprot,
   output logic [3:0]                  sb_axi_arqos,

   input wire sb_axi_rvalid,
   output logic                        sb_axi_rready,
   input wire [63:0]                 sb_axi_rdata,
   input wire [1:0]                  sb_axi_rresp,

   input wire dbg_bus_clk_en,

      input wire clk,
   input wire free_clk,
   input wire rst_l,
   input wire dbg_rst_l,
   input wire clk_override,
   input wire scan_mode
);


localparam IDLE = 'd 0 ;localparam HALTING = 'd 1 ;localparam HALTED = 'd 2 ;localparam CMD_START = 'd 3 ;localparam CMD_WAIT = 'd 4 ;localparam CMD_DONE = 'd 5 ;localparam RESUMING = 'd 6 ;localparam SBIDLE = 'd 0 ;localparam WAIT_RD = 'd 1 ;localparam WAIT_WR = 'd 2 ;localparam CMD_RD = 'd 3 ;localparam CMD_WR = 'd 4 ;localparam CMD_WR_ADDR = 'd 5 ;localparam CMD_WR_DATA = 'd 6 ;localparam RSP_RD = 'd 7 ;localparam RSP_WR = 'd 8 ;localparam DONE = 'd 9 ;
   state_t [pt.NUM_THREADS-1:0]  dbg_state;
   state_t [pt.NUM_THREADS-1:0]  dbg_nxtstate;
   reg   [pt.NUM_THREADS-1:0]  dbg_state_en;
      wire [31:0]  dmstatus_reg;           wire [31:0]  dmcontrol_reg;          wire [31:0]  command_reg;
   wire [31:0]  abstractcs_reg;         wire [31:0]  hawindow_reg;
   wire [31:0]  haltsum0_reg;
   wire [31:0]  data0_reg;
   wire [31:0]  data1_reg;

      wire [31:0]  data0_din;
wire data0_reg_wren;
wire data0_reg_wren0;
reg data0_reg_wren1;
      wire [31:0]  data1_din;
wire data1_reg_wren;
wire data1_reg_wren0;
wire data1_reg_wren1;
      reg [pt.NUM_THREADS-1:0] abstractcs_busy;
   wire [2:0]   abstractcs_error_din;
reg abstractcs_error_sel0;
wire abstractcs_error_sel1;
wire abstractcs_error_sel2;
wire abstractcs_error_sel3;
reg abstractcs_error_sel4;
wire abstractcs_error_sel5;
   wire         abstractcs_error_selor;

wire dmcontrol_wren;
reg dmcontrol_wren_Q;
wire dmcontrol_hasel_in;
reg dmcontrol_hartsel_in;
      reg         command_wren;
   wire [31:0]  command_din;

      wire         hawindow_wren;

      wire [31:0]  dmi_reg_rdata_din;
   reg [pt.NUM_THREADS-1:0] dec_tlu_mhartstart_Q;
   wire [pt.NUM_THREADS-1:0] hart_sel;
   wire [pt.NUM_THREADS-1:0] command_sel;
   reg [pt.NUM_THREADS-1:0] dbg_halted;
   wire [pt.NUM_THREADS-1:0] dbg_running;
   wire [pt.NUM_THREADS-1:0] dbg_resumeack;
   wire [pt.NUM_THREADS-1:0] dbg_havereset;
   wire [pt.NUM_THREADS-1:0] dbg_unavailable;

   sb_state_t    sb_state;
   sb_state_t    sb_nxtstate;
   reg         sb_state_en;

      wire              sbcs_wren;
   reg              sbcs_sbbusy_wren;
   reg              sbcs_sbbusy_din;
   wire              sbcs_sbbusyerror_wren;
   wire              sbcs_sbbusyerror_din;

   reg              sbcs_sberror_wren;
   reg [2:0]        sbcs_sberror_din;
   wire              sbcs_unaligned;
   wire              sbcs_illegal_size;

      wire              sbdata0_reg_wren0;
   reg              sbdata0_reg_wren1;
   wire              sbdata0_reg_wren;
   wire [31:0]       sbdata0_din;

   wire              sbdata1_reg_wren0;
   reg              sbdata1_reg_wren1;
   wire              sbdata1_reg_wren;
   wire [31:0]       sbdata1_din;

   wire              sbaddress0_reg_wren0;
   reg              sbaddress0_reg_wren1;
   wire              sbaddress0_reg_wren;
   wire [31:0]       sbaddress0_reg_din;
   wire [3:0]        sbaddress0_incr;
   wire              sbreadonaddr_access;
   reg              sbreadondata_access;
   reg              sbdata0wr_access;

wire sb_bus_cmd_read;
wire sb_bus_cmd_write_addr;
wire sb_bus_cmd_write_data;
wire sb_bus_rsp_read;
wire sb_bus_rsp_write;
   wire              sb_bus_rsp_error;
   wire [63:0]       sb_bus_rdata;

      wire [31:0]       sbcs_reg;
   wire [31:0]       sbaddress0_reg;
   wire [31:0]       sbdata0_reg;
   wire [31:0]       sbdata1_reg;

   wire              dbg_dm_rst_l;

      reg              dbg_free_clken;
   reg              dbg_free_clk;

   reg              sb_free_clken;
   reg              sb_free_clk;

   reg              bus_clk;

         always @* begin
      dbg_free_clken  = dmi_reg_en | clk_override;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         dbg_free_clken |= dec_tlu_dbg_halted[i] | dbg_state_en[i] | (dbg_state[i] != IDLE);
      end
   end

   
   
      assign dbg_dm_rst_l = dbg_rst_l & (dmcontrol_reg[0] | scan_mode);
   assign dbg_core_rst_l = ~dmcontrol_reg[1];

    // Use flopped version of mhartstart
   rvdff #(pt.NUM_THREADS) dbg_mhartstart_ff (.din(dec_tlu_mhartstart[pt.NUM_THREADS-1:0]), .dout(dec_tlu_mhartstart_Q[pt.NUM_THREADS-1:0]), .rst_l(rst_l), .clk(free_clk));

   
      assign        sbcs_reg[31:29] = 3'b1;
   assign        sbcs_reg[28:23] = '0;
   assign        sbcs_reg[11:5]  = 7'h20;
   assign        sbcs_reg[4:0]   = 5'b01111;
   assign        sbcs_wren = (dmi_reg_addr ==  7'h38) & dmi_reg_en & dmi_reg_wr_en & (sb_state == SBIDLE);
   assign        sbcs_sbbusyerror_wren = (sbcs_wren & dmi_reg_wdata[22]) |
                                         ((sb_state != SBIDLE) & dmi_reg_en & ((dmi_reg_addr == 7'h39) | (dmi_reg_addr == 7'h3c) | (dmi_reg_addr == 7'h3d)));
   assign        sbcs_sbbusyerror_din = ~(sbcs_wren & dmi_reg_wdata[22]);   

    rvdffs #(1) sbcs_sbbusyerror_reg  (.din(sbcs_sbbusyerror_din),  .dout(sbcs_reg[22]),    .en(sbcs_sbbusyerror_wren), .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));
   rvdffs #(1) sbcs_sbbusy_reg       (.din(sbcs_sbbusy_din),       .dout(sbcs_reg[21]),    .en(sbcs_sbbusy_wren),      .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));
   rvdffs #(1) sbcs_sbreadonaddr_reg (.din(dmi_reg_wdata[20]),     .dout(sbcs_reg[20]),    .en(sbcs_wren),             .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));
   rvdffs #(5) sbcs_misc_reg         (.din(dmi_reg_wdata[19:15]),  .dout(sbcs_reg[19:15]), .en(sbcs_wren),             .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));
   rvdffs #(3) sbcs_error_reg        (.din(sbcs_sberror_din[2:0]), .dout(sbcs_reg[14:12]), .en(sbcs_sberror_wren),     .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));

   assign sbcs_unaligned =    ((sbcs_reg[19:17] == 3'b001) &  sbaddress0_reg[0]) |
                              ((sbcs_reg[19:17] == 3'b010) &  (|sbaddress0_reg[1:0])) |
                              ((sbcs_reg[19:17] == 3'b011) &  (|sbaddress0_reg[2:0]));

   assign sbcs_illegal_size = sbcs_reg[19];    
   assign sbaddress0_incr[3:0] = ({4{(sbcs_reg[19:17] == 3'h0)}} &  4'b0001) |
                                 ({4{(sbcs_reg[19:17] == 3'h1)}} &  4'b0010) |
                                 ({4{(sbcs_reg[19:17] == 3'h2)}} &  4'b0100) |
                                 ({4{(sbcs_reg[19:17] == 3'h3)}} &  4'b1000);

      assign        sbdata0_reg_wren0   = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h3c);      assign        sbdata0_reg_wren1   = (sb_state == RSP_RD) & sb_state_en & ~sbcs_sberror_wren;
   assign        sbdata0_reg_wren    = sbdata0_reg_wren0 | sbdata0_reg_wren1;

   assign        sbdata1_reg_wren0   = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h3d);      assign        sbdata1_reg_wren1   = (sb_state == RSP_RD) & sb_state_en & ~sbcs_sberror_wren;
   assign        sbdata1_reg_wren    = sbdata1_reg_wren0 | sbdata1_reg_wren1;

   assign        sbdata0_din[31:0]   = ({32{sbdata0_reg_wren0}} & dmi_reg_wdata[31:0]) |
                                       ({32{sbdata0_reg_wren1}} & sb_bus_rdata[31:0]);
   assign        sbdata1_din[31:0]   = ({32{sbdata1_reg_wren0}} & dmi_reg_wdata[31:0]) |
                                       ({32{sbdata1_reg_wren1}} & sb_bus_rdata[63:32]);

    rvdffe #(32)    dbg_sbdata0_reg    (.*, .din(sbdata0_din[31:0]), .dout(sbdata0_reg[31:0]), .en(sbdata0_reg_wren), .rst_l(dbg_dm_rst_l));
    rvdffe #(32)    dbg_sbdata1_reg    (.*, .din(sbdata1_din[31:0]), .dout(sbdata1_reg[31:0]), .en(sbdata1_reg_wren), .rst_l(dbg_dm_rst_l));

    assign        sbaddress0_reg_wren0   = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h39);
   assign        sbaddress0_reg_wren    = sbaddress0_reg_wren0 | sbaddress0_reg_wren1;
   assign        sbaddress0_reg_din[31:0]= ({32{sbaddress0_reg_wren0}} & dmi_reg_wdata[31:0]) |
                                           ({32{sbaddress0_reg_wren1}} & (sbaddress0_reg[31:0] + {28'b0,sbaddress0_incr[3:0]}));
    rvdffe #(32)    dbg_sbaddress0_reg    (.*, .din(sbaddress0_reg_din[31:0]), .dout(sbaddress0_reg[31:0]), .en(sbaddress0_reg_wren), .rst_l(dbg_dm_rst_l));

   assign sbreadonaddr_access = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h39) & sbcs_reg[20];      assign sbreadondata_access = dmi_reg_en & ~dmi_reg_wr_en & (dmi_reg_addr == 7'h3c) & sbcs_reg[15];     assign sbdata0wr_access  = dmi_reg_en &  dmi_reg_wr_en & (dmi_reg_addr == 7'h3c);                   
               assign dmcontrol_wren      = (dmi_reg_addr ==  7'h10) & dmi_reg_en & dmi_reg_wr_en;
   assign dmcontrol_reg[29]   = '0;
   assign dmcontrol_reg[27]   = '0;
   assign dmcontrol_reg[25:17] = '0;
   assign dmcontrol_reg[15:2]  = '0;
   assign dmcontrol_hasel_in  = (pt.NUM_THREADS > 1) & dmi_reg_wdata[26];      assign dmcontrol_hartsel_in = (pt.NUM_THREADS > 1) & dmi_reg_wdata[16];   
    rvdffs #(6) dmcontrolff (.din({dmi_reg_wdata[31:30],dmi_reg_wdata[28],dmcontrol_hasel_in,dmcontrol_hartsel_in,dmi_reg_wdata[1]}),
                            .dout({dmcontrol_reg[31:30],dmcontrol_reg[28],dmcontrol_reg[26],dmcontrol_reg[16],dmcontrol_reg[1]}), .en(dmcontrol_wren), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));
   rvdffs #(1) dmcontrol_dmactive_ff (.din(dmi_reg_wdata[0]), .dout(dmcontrol_reg[0]), .en(dmcontrol_wren), .rst_l(dbg_rst_l), .clk(dbg_free_clk));
   rvdff  #(1) dmcontrol_wrenff(.din(dmcontrol_wren), .dout(dmcontrol_wren_Q), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));


            assign dmstatus_reg[31:20] = 0;
   assign dmstatus_reg[19]    = &(dbg_havereset[pt.NUM_THREADS-1:0] | ~hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[18]    = |(dbg_havereset[pt.NUM_THREADS-1:0] & hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[17]    = &(dbg_resumeack[pt.NUM_THREADS-1:0] | ~hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[16]    = |(dbg_resumeack[pt.NUM_THREADS-1:0] & hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[15:14] = 0;
   assign dmstatus_reg[13]    = &(dbg_unavailable[pt.NUM_THREADS-1:0] | ~hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[12]    = |(dbg_unavailable[pt.NUM_THREADS-1:0] & hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[11]    = &(dbg_running[pt.NUM_THREADS-1:0] | ~hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[10]    = |(dbg_running[pt.NUM_THREADS-1:0] & hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[9]     = &(dbg_halted[pt.NUM_THREADS-1:0] | ~hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[8]     = |(dbg_halted[pt.NUM_THREADS-1:0] & hart_sel[pt.NUM_THREADS-1:0]);
   assign dmstatus_reg[7]     = 1;
   assign dmstatus_reg[6:4]   = 0;
   assign dmstatus_reg[3:0]   = 4'h2;

      assign haltsum0_reg[31:pt.NUM_THREADS] = 0;
   for (genvar i=0; i<pt.NUM_THREADS; i++) begin: Gen_haltsum
      assign haltsum0_reg[i]  = dbg_halted[i];
   end

         assign        abstractcs_reg[31:13] = '0;
   assign        abstractcs_reg[11]    = '0;
   assign        abstractcs_reg[7:4]   = '0;
   assign        abstractcs_reg[3:0]   = 4'h2;       assign        abstractcs_error_sel0 = abstractcs_reg[12] & dmi_reg_en & ((dmi_reg_wr_en & ( (dmi_reg_addr == 7'h16) | (dmi_reg_addr == 7'h17))) | (dmi_reg_addr == 7'h4) | (dmi_reg_addr == 7'h5));
   assign        abstractcs_error_sel1 = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h17) & ~((dmi_reg_wdata[31:24] == 8'b0) | (dmi_reg_wdata[31:24] == 8'h2));
   assign        abstractcs_error_sel2 = core_dbg_cmd_done & core_dbg_cmd_fail;
   assign        abstractcs_error_sel3 = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h17) & ~(|(command_sel[pt.NUM_THREADS-1:0] & dbg_halted[pt.NUM_THREADS-1:0]));     assign        abstractcs_error_sel4 = (dmi_reg_addr ==  7'h17) & dmi_reg_en & dmi_reg_wr_en &
                                         ((dmi_reg_wdata[22:20] != 3'b010) | ((dmi_reg_wdata[31:24] == 8'h2) && (|data1_reg[1:0])));  
   assign        abstractcs_error_sel5 = (dmi_reg_addr ==  7'h16) & dmi_reg_en & dmi_reg_wr_en;

   assign        abstractcs_error_selor = abstractcs_error_sel0 | abstractcs_error_sel1 | abstractcs_error_sel2 | abstractcs_error_sel3 | abstractcs_error_sel4 | abstractcs_error_sel5;

   assign        abstractcs_error_din[2:0]  = ({3{abstractcs_error_sel0}} & 3'b001) |                                                     ({3{abstractcs_error_sel1}} & 3'b010) |                                                     ({3{abstractcs_error_sel2}} & 3'b011) |                                                     ({3{abstractcs_error_sel3}} & 3'b100) |                                                     ({3{abstractcs_error_sel4}} & 3'b111) |                                                     ({3{abstractcs_error_sel5}} & ~dmi_reg_wdata[10:8] & abstractcs_reg[10:8]) |                                                      ({3{~abstractcs_error_selor}} & abstractcs_reg[10:8]);                              
   assign abstractcs_reg[12] = |abstractcs_busy[pt.NUM_THREADS-1:0];
    rvdff  #(3) dmabstractcs_error_reg (.din(abstractcs_error_din[2:0]), .dout(abstractcs_reg[10:8]), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));


            always @* begin
      command_wren = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         command_wren |= ((dmi_reg_addr == 7'h17) & dmi_reg_en & dmi_reg_wr_en & command_sel[i] & (dbg_state[i] == HALTED));
      end
   end
   assign     command_din[31:0] = {dmi_reg_wdata[31:24],1'b0,dmi_reg_wdata[22:20],3'b0,dmi_reg_wdata[16:0]};
    rvdffe #(32) dmcommand_reg (.*, .din(command_din[31:0]), .dout(command_reg[31:0]), .en(command_wren), .rst_l(dbg_dm_rst_l));

      assign hawindow_wren = dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h15);
   assign hawindow_reg[31:pt.NUM_THREADS] = '0;

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin: GenHAWindow
          rvdffs #(1) dbg_hawindow_reg (.*, .din(dmi_reg_wdata[i]), .dout(hawindow_reg[i]), .en(hawindow_wren), .rst_l(dbg_dm_rst_l));

   end

      always @* begin
      data0_reg_wren0 = 1'b0;
      data0_reg_wren1 = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         data0_reg_wren0   |= (dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h4) & command_sel[i] & (dbg_state[i] == HALTED));
         data0_reg_wren1   |= core_dbg_cmd_done & (dbg_state[i] == CMD_WAIT) & ~command_reg[16];
      end
   end
   assign data0_reg_wren    = data0_reg_wren0 | data0_reg_wren1;

   assign data0_din[31:0]   = ({32{data0_reg_wren0}} & dmi_reg_wdata[31:0]) |
                                     ({32{data0_reg_wren1}} & core_dbg_rddata[31:0]);
    rvdffe #(32)    dbg_data1_reg    (.*, .din(data1_din[31:0]), .dout(data1_reg[31:0]), .en(data1_reg_wren), .rst_l(dbg_dm_rst_l));


      always @* begin
      data1_reg_wren0 = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         data1_reg_wren0   |= (dmi_reg_en & dmi_reg_wr_en & (dmi_reg_addr == 7'h5) & command_sel[i] & (dbg_state[i] == HALTED));
      end
   end
   assign data1_reg_wren1   = 1'b0;
   assign data1_reg_wren    = data1_reg_wren0 | data1_reg_wren1;

   assign data1_din[31:0]   = ({32{data1_reg_wren0}} & dmi_reg_wdata[31:0]);


      for (genvar i=0; i<pt.NUM_THREADS; i++) begin

wire [pt.NUM_THREADS-1:0] dbg_resumeack_wren;
wire [pt.NUM_THREADS-1:0] dbg_resumeack_din;
wire [pt.NUM_THREADS-1:0] dbg_havereset_wren;
wire [pt.NUM_THREADS-1:0] dbg_havereset_rst;
reg [pt.NUM_THREADS-1:0] abstractcs_busy_wren;
reg [pt.NUM_THREADS-1:0] abstractcs_busy_din;

      assign hart_sel[i] = (dmcontrol_reg[16] == 1'(i)) | (dmcontrol_reg[26] & hawindow_reg[i]);
      assign command_sel[i] = (dmcontrol_reg[16] == 1'(i));

            assign dbg_resumeack_wren[i] = ((dbg_state[i] == RESUMING) & dec_tlu_resume_ack[i]) | (dbg_resumeack[i] & ~dmcontrol_reg[30] & hart_sel[i]);
      assign dbg_resumeack_din[i]  = (dbg_state[i] == RESUMING) & dec_tlu_resume_ack[i];

      assign dbg_havereset_wren[i] = (dmi_reg_addr == 7'h10) & dmi_reg_wdata[1] & dmi_reg_en & dmi_reg_wr_en;
      assign dbg_havereset_rst[i]  = (dmi_reg_addr == 7'h10) & dmi_reg_wdata[28] & dmi_reg_en & dmi_reg_wr_en & ((dmi_reg_wdata[16] == 1'(i)) | (dmi_reg_wdata[26] & hawindow_reg[i]));

      assign dbg_unavailable[i] = (hart_sel[i] & ~dec_tlu_mhartstart[i]) | ~rst_l | dmcontrol_reg[1];
      assign dbg_running[i]     = ~(dbg_unavailable[i] | dbg_halted[i]);
           rvdff  #(1) dbg_halted_reg     (.din(dec_tlu_dbg_halted[i] & ~dec_tlu_mpc_halted_only[i]), .dout(dbg_halted[i]), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));
      rvdffs #(1) dbg_resumeack_reg  (.din(dbg_resumeack_din[i]), .dout(dbg_resumeack[i]), .en(dbg_resumeack_wren[i]), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));
      rvdffsc #(1) dbg_havereset_reg (.din(1'b1), .dout(dbg_havereset[i]), .en(dbg_havereset_wren[i]), .clear(dbg_havereset_rst[i]), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));
      rvdffs #(1) abstractcs_busy_reg  (.din(abstractcs_busy_din[i]), .dout(abstractcs_busy[i]), .en(abstractcs_busy_wren[i]), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));
      rvdffs #($bits(state_t)) dbg_state_reg    (.din(dbg_nxtstate[i]), .dout({dbg_state[i]}), .en(dbg_state_en[i]), .rst_l(dbg_dm_rst_l & rst_l), .clk(dbg_free_clk));


            always @* begin
         dbg_nxtstate[i]         = IDLE;
         dbg_state_en[i]         = 1'b0;
         abstractcs_busy_wren    = 1'b0;
         abstractcs_busy_din     = 1'b0;
         dbg_halt_req[i]   = dmcontrol_wren_Q & dmcontrol_reg[31] & hart_sel[i] & ~dmcontrol_reg[1];
                dbg_resume_req[i] = 1'b0;
         case (dbg_state[i])
            IDLE: begin
                     dbg_nxtstate[i]      = (dbg_halted[i] | dec_tlu_mpc_halted_only[i]) ? HALTED : HALTING;
                dbg_state_en[i]      = ((dmcontrol_reg[31] & hart_sel[i] & ~dec_tlu_debug_mode[i]) | dbg_halted[i] | dec_tlu_mpc_halted_only[i]) & ~dmcontrol_reg[1] & dec_tlu_mhartstart_Q[i];
                dbg_halt_req[i] = dmcontrol_reg[31] & hart_sel[i] & dec_tlu_mhartstart_Q[i] & ~dmcontrol_reg[1];
            end
            HALTING : begin
                     dbg_nxtstate[i]      = dmcontrol_reg[1] ? IDLE : HALTED;
                dbg_state_en[i]      = dbg_halted[i] | dmcontrol_reg[1];
            end
            HALTED: begin
                dbg_nxtstate[i]      = (dbg_halted[i] & ~dmcontrol_reg[1]) ? ((dmcontrol_reg[30] & ~dmcontrol_reg[31] & hart_sel[i]) ? RESUMING : CMD_START) :
                                                                                   ((dmcontrol_reg[31] & hart_sel[i]) ? HALTING : IDLE);
                dbg_state_en[i]      = (dbg_halted[i] & dmcontrol_reg[30] & ~dmcontrol_reg[31] & dmcontrol_wren_Q & hart_sel[i]) | (command_wren & command_sel[i]) | dmcontrol_reg[1] | ~(dbg_halted[i] | dec_tlu_mpc_halted_only[i]);
                abstractcs_busy_wren[i] = dbg_state_en[i] & (dbg_nxtstate[i] == CMD_START);
                abstractcs_busy_din[i]  = 1'b1;

                dbg_resume_req[i] = dbg_state_en[i] & (dbg_nxtstate[i] == RESUMING);
            end
            CMD_START: begin
                     dbg_nxtstate[i]      = dmcontrol_reg[1] ? IDLE : (|abstractcs_reg[10:8]) ? CMD_DONE : CMD_WAIT;
                dbg_state_en[i]      = dbg_cmd_valid | (|abstractcs_reg[10:8]) | dmcontrol_reg[1];
            end
            CMD_WAIT: begin
                     dbg_nxtstate[i]      = dmcontrol_reg[1] ? IDLE : CMD_DONE;
                     dbg_state_en[i]      = core_dbg_cmd_done | dmcontrol_reg[1];
            end
            CMD_DONE: begin
                     dbg_nxtstate[i]      = dmcontrol_reg[1] ? IDLE : HALTED;
                     dbg_state_en[i]      = 1'b1;
                     abstractcs_busy_wren[i] = dbg_state_en[i];
                abstractcs_busy_din[i]  = 1'b0;

            end
            RESUMING : begin
                     dbg_nxtstate[i]      = IDLE;
                     dbg_state_en[i]      = dbg_resumeack[i] | dmcontrol_reg[1];
            end
             default : begin
                     dbg_state_en[i]         = 1'b0;
                     abstractcs_busy_wren[i] = 1'b0;
                     abstractcs_busy_din[i]  = 1'b0;
                     dbg_halt_req[i]   = 1'b0;                              dbg_resume_req[i] = 1'b0;
             end
         endcase
      end    end 
   assign dmi_reg_rdata_din[31:0] = ({32{dmi_reg_addr == 7'h4}}  & data0_reg[31:0])      |
                                    ({32{dmi_reg_addr == 7'h5}}  & data1_reg[31:0])      |
                                    ({32{dmi_reg_addr == 7'h10}} & dmcontrol_reg[31:0])  |
                                    ({32{dmi_reg_addr == 7'h11}} & dmstatus_reg[31:0])   |
                                    ({32{dmi_reg_addr == 7'h16}} & abstractcs_reg[31:0]) |
                                    ({32{dmi_reg_addr == 7'h17}} & command_reg[31:0])    |
                                    ({32{dmi_reg_addr == 7'h40}} & haltsum0_reg[31:0])   |
                                    ({32{dmi_reg_addr == 7'h38}} & sbcs_reg[31:0])       |
                                    ({32{dmi_reg_addr == 7'h39}} & sbaddress0_reg[31:0]) |
                                    ({32{dmi_reg_addr == 7'h3c}} & sbdata0_reg[31:0])    |
                                    ({32{dmi_reg_addr == 7'h3d}} & sbdata1_reg[31:0]);


   rvdffs #(32)             dmi_rddata_reg   (.din(dmi_reg_rdata_din[31:0]), .dout(dmi_reg_rdata[31:0]), .en(dmi_reg_en), .rst_l(dbg_dm_rst_l), .clk(dbg_free_clk));

      assign        dbg_cmd_addr[31:0]    = (command_reg[31:24] == 8'h2) ? {data1_reg[31:2],2'b0}  : {20'b0, command_reg[11:0]};
    assign        dbg_cmd_wrdata[31:0]  = data0_reg[31:0];
   always @* begin
      dbg_cmd_valid = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         dbg_cmd_valid  |= (dbg_state[i] == CMD_START) & ~(|abstractcs_reg[10:8]) & dma_dbg_ready;
      end
   end
   assign        dbg_cmd_tid           = dmcontrol_reg[16];
   assign        dbg_cmd_write         = command_reg[16];
   assign        dbg_cmd_type[1:0]     = (command_reg[31:24] == 8'h2) ? 2'b10 : {1'b0, (command_reg[15:12] == 4'b0)};
   assign        dbg_cmd_size[1:0]     = command_reg[21:20];

      always @* begin
      dbg_dma_bubble = 1'b0;
      for (int i=0; i<pt.NUM_THREADS; i++) begin
         dbg_dma_bubble     |= ((dbg_state[i] == CMD_START) & ~(|abstractcs_reg[10:8])) | (dbg_state[i] == CMD_WAIT);
      end
   end

    always @* begin
      sb_nxtstate            = SBIDLE;
      sb_state_en            = 1'b0;
      sbcs_sbbusy_wren       = 1'b0;
      sbcs_sbbusy_din        = 1'b0;
      sbcs_sberror_wren      = 1'b0;
      sbcs_sberror_din[2:0]  = 3'b0;
      sbaddress0_reg_wren1   = 1'b0;
      case (sb_state)
            SBIDLE: begin
                     sb_nxtstate            = sbdata0wr_access ? WAIT_WR : WAIT_RD;
                     sb_state_en            = sbdata0wr_access | sbreadondata_access | sbreadonaddr_access;
                     sbcs_sbbusy_wren       = sb_state_en;                                                                      sbcs_sbbusy_din        = 1'b1;
                     sbcs_sberror_wren      = sbcs_wren & (|dmi_reg_wdata[14:12]);                                                                 sbcs_sberror_din[2:0]  = ~dmi_reg_wdata[14:12] & sbcs_reg[14:12];
            end
            WAIT_RD: begin
                     sb_nxtstate           = (sbcs_unaligned | sbcs_illegal_size) ? DONE : CMD_RD;
                     sb_state_en           = dbg_bus_clk_en | sbcs_unaligned | sbcs_illegal_size;
                     sbcs_sberror_wren     = sbcs_unaligned | sbcs_illegal_size;
                     sbcs_sberror_din[2:0] = sbcs_unaligned ? 3'b011 : 3'b100;
            end
            WAIT_WR: begin
                     sb_nxtstate           = (sbcs_unaligned | sbcs_illegal_size) ? DONE : CMD_WR;
                     sb_state_en           = dbg_bus_clk_en | sbcs_unaligned | sbcs_illegal_size;
                     sbcs_sberror_wren     = sbcs_unaligned | sbcs_illegal_size;
                     sbcs_sberror_din[2:0] = sbcs_unaligned ? 3'b011 : 3'b100;
            end
            CMD_RD : begin
                     sb_nxtstate           = RSP_RD;
                     sb_state_en           = sb_bus_cmd_read & dbg_bus_clk_en;
            end
            CMD_WR : begin
                     sb_nxtstate           = (sb_bus_cmd_write_addr & sb_bus_cmd_write_data) ? RSP_WR : (sb_bus_cmd_write_data ? CMD_WR_ADDR : CMD_WR_DATA);
                     sb_state_en           = (sb_bus_cmd_write_addr | sb_bus_cmd_write_data) & dbg_bus_clk_en;
            end
            CMD_WR_ADDR : begin
                     sb_nxtstate           = RSP_WR;
                     sb_state_en           = sb_bus_cmd_write_addr & dbg_bus_clk_en;
            end
            CMD_WR_DATA : begin
                     sb_nxtstate           = RSP_WR;
                     sb_state_en           = sb_bus_cmd_write_data & dbg_bus_clk_en;
            end
            RSP_RD: begin
                     sb_nxtstate           = DONE;
                     sb_state_en           = sb_bus_rsp_read & dbg_bus_clk_en;
                     sbcs_sberror_wren     = sb_state_en & sb_bus_rsp_error;
                     sbcs_sberror_din[2:0] = 3'b010;
            end
            RSP_WR: begin
                     sb_nxtstate           = DONE;
                     sb_state_en           = sb_bus_rsp_write & dbg_bus_clk_en;
                     sbcs_sberror_wren     = sb_state_en & sb_bus_rsp_error;
                     sbcs_sberror_din[2:0] = 3'b010;
            end
            DONE: begin
                     sb_nxtstate            = SBIDLE;
                     sb_state_en            = 1'b1;
                     sbcs_sbbusy_wren       = 1'b1;                                                sbcs_sbbusy_din        = 1'b0;
                     sbaddress0_reg_wren1   = sbcs_reg[16];
            end
          default : begin
                     sb_state_en            = 1'b0;
                     sbcs_sbbusy_wren       = 1'b0;
                     sbcs_sbbusy_din        = 1'b0;
                     sbcs_sberror_wren      = 1'b0;
                     sbcs_sberror_din[2:0]  = 3'b0;
                     sbaddress0_reg_wren1   = 1'b0;
           end
         endcase
   end 
   rvdffs #($bits(sb_state_t)) sb_state_reg (.din(sb_nxtstate), .dout({sb_state}), .en(sb_state_en), .rst_l(dbg_dm_rst_l), .clk(sb_free_clk));

      assign sb_bus_cmd_read       = sb_axi_arvalid & sb_axi_arready;
   assign sb_bus_cmd_write_addr = sb_axi_awvalid & sb_axi_awready;
   assign sb_bus_cmd_write_data = sb_axi_wvalid  & sb_axi_wready;

   assign sb_bus_rsp_read  = sb_axi_rvalid & sb_axi_rready;
   assign sb_bus_rsp_write = sb_axi_bvalid & sb_axi_bready;
   assign sb_bus_rsp_error = (sb_bus_rsp_read & (|(sb_axi_rresp[1:0]))) | (sb_bus_rsp_write & (|(sb_axi_bresp[1:0])));

      assign sb_axi_awvalid              = (sb_state == CMD_WR) | (sb_state == CMD_WR_ADDR);
   assign sb_axi_awaddr[31:0]         = sbaddress0_reg[31:0];
   assign sb_axi_awid[pt.SB_BUS_TAG-1:0] = '0;
   assign sb_axi_awsize[2:0]          = sbcs_reg[19:17];
   assign sb_axi_awprot[2:0]          = '0;
   assign sb_axi_awcache[3:0]         = 4'b1111;
   assign sb_axi_awregion[3:0]        = sbaddress0_reg[31:28];
   assign sb_axi_awlen[7:0]           = '0;
   assign sb_axi_awburst[1:0]         = 2'b01;
   assign sb_axi_awqos[3:0]           = '0;
   assign sb_axi_awlock               = '0;

   assign sb_axi_wvalid       = (sb_state == CMD_WR) | (sb_state == CMD_WR_DATA);
   assign sb_axi_wdata[63:0]  = ({64{(sbcs_reg[19:17] == 3'h0)}} & {8{sbdata0_reg[7:0]}}) |
                                ({64{(sbcs_reg[19:17] == 3'h1)}} & {4{sbdata0_reg[15:0]}}) |
                                ({64{(sbcs_reg[19:17] == 3'h2)}} & {2{sbdata0_reg[31:0]}}) |
                                ({64{(sbcs_reg[19:17] == 3'h3)}} & {sbdata1_reg[31:0],sbdata0_reg[31:0]});
   assign sb_axi_wstrb[7:0]   = ({8{(sbcs_reg[19:17] == 3'h0)}} & (8'h1 << sbaddress0_reg[2:0])) |
                                ({8{(sbcs_reg[19:17] == 3'h1)}} & (8'h3 << {sbaddress0_reg[2:1],1'b0})) |
                                ({8{(sbcs_reg[19:17] == 3'h2)}} & (8'hf << {sbaddress0_reg[2],2'b0})) |
                                ({8{(sbcs_reg[19:17] == 3'h3)}} & 8'hff);
   assign sb_axi_wlast        = '1;

   assign sb_axi_arvalid              = (sb_state == CMD_RD);
   assign sb_axi_araddr[31:0]         = sbaddress0_reg[31:0];
   assign sb_axi_arid[pt.SB_BUS_TAG-1:0] = '0;
   assign sb_axi_arsize[2:0]          = sbcs_reg[19:17];
   assign sb_axi_arprot[2:0]          = '0;
   assign sb_axi_arcache[3:0]         = 4'b0;
   assign sb_axi_arregion[3:0]        = sbaddress0_reg[31:28];
   assign sb_axi_arlen[7:0]           = '0;
   assign sb_axi_arburst[1:0]         = 2'b01;
   assign sb_axi_arqos[3:0]           = '0;
   assign sb_axi_arlock               = '0;

      assign sb_axi_bready = 1'b1;

   assign sb_axi_rready = 1'b1;
   assign sb_bus_rdata[63:0] = ({64{sbcs_reg[19:17] == 3'h0}} & ((sb_axi_rdata[63:0] >> 8*sbaddress0_reg[2:0]) & 64'hff))       |
                               ({64{sbcs_reg[19:17] == 3'h1}} & ((sb_axi_rdata[63:0] >> 16*sbaddress0_reg[2:1]) & 64'hffff))    |
                               ({64{sbcs_reg[19:17] == 3'h2}} & ((sb_axi_rdata[63:0] >> 32*sbaddress0_reg[2]) & 64'hffff_ffff)) |
                               ({64{sbcs_reg[19:17] == 3'h3}} & sb_axi_rdata[63:0]);

`ifdef ASSERT_ON
`endif
endmodule : eh2_dbg
