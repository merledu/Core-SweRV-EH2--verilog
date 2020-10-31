
module eh2_swerv_wrapper
 (
   input wire clk,
   input wire rst_l,
   input wire dbg_rst_l,
   input wire [31:1]                rst_vec,
   input wire nmi_int,
   input wire [31:1]                nmi_vec,
   input wire [31:1]                jtag_id,


   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_insn_ip,
   output logic [pt.NUM_THREADS-1:0] [63:0] trace_rv_i_address_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_valid_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_exception_ip,
   output logic [pt.NUM_THREADS-1:0] [4:0]  trace_rv_i_ecause_ip,
   output logic [pt.NUM_THREADS-1:0] [2:0]  trace_rv_i_interrupt_ip,
   output logic [pt.NUM_THREADS-1:0] [31:0] trace_rv_i_tval_ip,

   
`ifdef RV_BUILD_AXI4
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

         output logic                            ifu_axi_awvalid,
   input wire ifu_axi_awready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_awid,
   output logic [31:0]                     ifu_axi_awaddr,
   output logic [3:0]                      ifu_axi_awregion,
   output logic [7:0]                      ifu_axi_awlen,
   output logic [2:0]                      ifu_axi_awsize,
   output logic [1:0]                      ifu_axi_awburst,
   output logic                            ifu_axi_awlock,
   output logic [3:0]                      ifu_axi_awcache,
   output logic [2:0]                      ifu_axi_awprot,
   output logic [3:0]                      ifu_axi_awqos,

   output logic                            ifu_axi_wvalid,
   input wire ifu_axi_wready,
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   input wire ifu_axi_bvalid,
   output logic                            ifu_axi_bready,
   input wire [1:0]                      ifu_axi_bresp,
   input wire [pt.IFU_BUS_TAG-1:0]       ifu_axi_bid,

      output logic                            ifu_axi_arvalid,
   input wire ifu_axi_arready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_arid,
   output logic [31:0]                     ifu_axi_araddr,
   output logic [3:0]                      ifu_axi_arregion,
   output logic [7:0]                      ifu_axi_arlen,
   output logic [2:0]                      ifu_axi_arsize,
   output logic [1:0]                      ifu_axi_arburst,
   output logic                            ifu_axi_arlock,
   output logic [3:0]                      ifu_axi_arcache,
   output logic [2:0]                      ifu_axi_arprot,
   output logic [3:0]                      ifu_axi_arqos,

   input wire ifu_axi_rvalid,
   output logic                            ifu_axi_rready,
   input wire [pt.IFU_BUS_TAG-1:0]       ifu_axi_rid,
   input wire [63:0]                     ifu_axi_rdata,
   input wire [1:0]                      ifu_axi_rresp,
   input wire ifu_axi_rlast,

         output logic                            sb_axi_awvalid,
   input wire sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_awid,
   output logic [31:0]                     sb_axi_awaddr,
   output logic [3:0]                      sb_axi_awregion,
   output logic [7:0]                      sb_axi_awlen,
   output logic [2:0]                      sb_axi_awsize,
   output logic [1:0]                      sb_axi_awburst,
   output logic                            sb_axi_awlock,
   output logic [3:0]                      sb_axi_awcache,
   output logic [2:0]                      sb_axi_awprot,
   output logic [3:0]                      sb_axi_awqos,

   output logic                            sb_axi_wvalid,
   input wire sb_axi_wready,
   output logic [63:0]                     sb_axi_wdata,
   output logic [7:0]                      sb_axi_wstrb,
   output logic                            sb_axi_wlast,

   input wire sb_axi_bvalid,
   output logic                            sb_axi_bready,
   input wire [1:0]                      sb_axi_bresp,
   input wire [pt.SB_BUS_TAG-1:0]        sb_axi_bid,

      output logic                            sb_axi_arvalid,
   input wire sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_arid,
   output logic [31:0]                     sb_axi_araddr,
   output logic [3:0]                      sb_axi_arregion,
   output logic [7:0]                      sb_axi_arlen,
   output logic [2:0]                      sb_axi_arsize,
   output logic [1:0]                      sb_axi_arburst,
   output logic                            sb_axi_arlock,
   output logic [3:0]                      sb_axi_arcache,
   output logic [2:0]                      sb_axi_arprot,
   output logic [3:0]                      sb_axi_arqos,

   input wire sb_axi_rvalid,
   output logic                            sb_axi_rready,
   input wire [pt.SB_BUS_TAG-1:0]        sb_axi_rid,
   input wire [63:0]                     sb_axi_rdata,
   input wire [1:0]                      sb_axi_rresp,
   input wire sb_axi_rlast,

         input wire dma_axi_awvalid,
   output logic                         dma_axi_awready,
   input wire [pt.DMA_BUS_TAG-1:0]    dma_axi_awid,
   input wire [31:0]                  dma_axi_awaddr,
   input wire [2:0]                   dma_axi_awsize,
   input wire [2:0]                   dma_axi_awprot,
   input wire [7:0]                   dma_axi_awlen,
   input wire [1:0]                   dma_axi_awburst,


   input wire dma_axi_wvalid,
   output logic                         dma_axi_wready,
   input wire [63:0]                  dma_axi_wdata,
   input wire [7:0]                   dma_axi_wstrb,
   input wire dma_axi_wlast,

   output logic                         dma_axi_bvalid,
   input wire dma_axi_bready,
   output logic [1:0]                   dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_bid,

      input wire dma_axi_arvalid,
   output logic                         dma_axi_arready,
   input wire [pt.DMA_BUS_TAG-1:0]    dma_axi_arid,
   input wire [31:0]                  dma_axi_araddr,
   input wire [2:0]                   dma_axi_arsize,
   input wire [2:0]                   dma_axi_arprot,
   input wire [7:0]                   dma_axi_arlen,
   input wire [1:0]                   dma_axi_arburst,

   output logic                         dma_axi_rvalid,
   input wire dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_rid,
   output logic [63:0]                  dma_axi_rdata,
   output logic [1:0]                   dma_axi_rresp,
   output logic                         dma_axi_rlast,

`endif

`ifdef RV_BUILD_AHB_LITE
    output logic [31:0]               haddr,
   output logic [2:0]                hburst,
   output logic                      hmastlock,
   output logic [3:0]                hprot,
   output logic [2:0]                hsize,
   output logic [1:0]                htrans,
   output logic                      hwrite,

   input wire [63:0]                hrdata,
   input wire hready,
   input wire hresp,

      output logic [31:0]               lsu_haddr,
   output logic [2:0]                lsu_hburst,
   output logic                      lsu_hmastlock,
   output logic [3:0]                lsu_hprot,
   output logic [2:0]                lsu_hsize,
   output logic [1:0]                lsu_htrans,
   output logic                      lsu_hwrite,
   output logic [63:0]               lsu_hwdata,

   input wire [63:0]                lsu_hrdata,
   input wire lsu_hready,
   input wire lsu_hresp,
      output logic [31:0]               sb_haddr,
   output logic [2:0]                sb_hburst,
   output logic                      sb_hmastlock,
   output logic [3:0]                sb_hprot,
   output logic [2:0]                sb_hsize,
   output logic [1:0]                sb_htrans,
   output logic                      sb_hwrite,
   output logic [63:0]               sb_hwdata,

   input wire [63:0]               sb_hrdata,
   input wire sb_hready,
   input wire sb_hresp,

      input wire dma_hsel,
   input wire [31:0]                dma_haddr,
   input wire [2:0]                 dma_hburst,
   input wire dma_hmastlock,
   input wire [3:0]                 dma_hprot,
   input wire [2:0]                 dma_hsize,
   input wire [1:0]                 dma_htrans,
   input wire dma_hwrite,
   input wire [63:0]                dma_hwdata,
   input wire dma_hreadyin,

   output logic [63:0]               dma_hrdata,
   output logic                      dma_hreadyout,
   output logic                      dma_hresp,

`endif


      input wire lsu_bus_clk_en,    input wire ifu_bus_clk_en,    input wire dbg_bus_clk_en,    input wire dma_bus_clk_en, 

   input wire [pt.NUM_THREADS-1:0]  timer_int,
   input wire [pt.NUM_THREADS-1:0]  soft_int,
   input wire [pt.PIC_TOTAL_INT:1] extintsrc_req,

   output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt0,                     output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt1,                     output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt2,                     output logic [pt.NUM_THREADS-1:0] [1:0] dec_tlu_perfcnt3,                  
   input wire jtag_tck,    input wire jtag_tms,    input wire jtag_tdi,    input wire jtag_trst_n,    output logic                      jtag_tdo, 
   input wire [31:4]     core_id, 

      input wire [pt.NUM_THREADS-1:0] mpc_debug_halt_req,    input wire [pt.NUM_THREADS-1:0] mpc_debug_run_req,    input wire [pt.NUM_THREADS-1:0] mpc_reset_run_req,    output logic [pt.NUM_THREADS-1:0] mpc_debug_halt_ack,    output logic [pt.NUM_THREADS-1:0] mpc_debug_run_ack,    output logic [pt.NUM_THREADS-1:0] debug_brkpt_status, 
   output logic [pt.NUM_THREADS-1:0] dec_tlu_mhartstart, 
   input wire [pt.NUM_THREADS-1:0]         i_cpu_halt_req,    output logic         [pt.NUM_THREADS-1:0]         o_cpu_halt_ack,    output logic         [pt.NUM_THREADS-1:0]         o_cpu_halt_status,    output logic         [pt.NUM_THREADS-1:0]              o_debug_mode_status,    input wire [pt.NUM_THREADS-1:0]         i_cpu_run_req,    output logic         [pt.NUM_THREADS-1:0]         o_cpu_run_ack,    input wire scan_mode,    input wire mbist_mode );

      reg         dccm_wren;
   reg         dccm_rden;
   reg [pt.DCCM_BITS-1:0]  dccm_wr_addr_lo;
   reg [pt.DCCM_BITS-1:0]  dccm_wr_addr_hi;
   reg [pt.DCCM_BITS-1:0]  dccm_rd_addr_lo;
   reg [pt.DCCM_BITS-1:0]  dccm_rd_addr_hi;
   reg [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo;
   reg [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi;

   reg [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo;
   reg [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi;

   
      reg [31:1]  ic_rw_addr;
   reg [pt.ICACHE_NUM_WAYS-1:0]   ic_wr_en  ;        reg         ic_rd_en ;


   reg [pt.ICACHE_NUM_WAYS-1:0]   ic_tag_valid;   
   reg [pt.ICACHE_NUM_WAYS-1:0]   ic_rd_hit;         reg         ic_tag_perr;    
   reg [pt.ICACHE_INDEX_HI:3]  ic_debug_addr;         reg         ic_debug_rd_en;        reg         ic_debug_wr_en;        reg         ic_debug_tag_array;    reg [pt.ICACHE_NUM_WAYS-1:0]   ic_debug_way;       
   reg [pt.ICACHE_BANKS_WAY-1:0] [70:0] ic_wr_data;              reg [63:0]                           ic_rd_data;             reg [70:0]                           ic_debug_rd_data;       reg [25:0]                           ictag_debug_rd_data;     reg [70:0]                           ic_debug_wr_data;        reg [pt.ICACHE_BANKS_WAY-1:0]        ic_eccerr;
       reg [pt.ICACHE_BANKS_WAY-1:0]        ic_parerr;


   reg [63:0]  ic_premux_data;
   reg         ic_sel_premux_data;

      reg [pt.ICCM_BITS-1:1]  iccm_rw_addr;
reg reg [pt.NUM_THREADS-1:0] iccm_buf_correct_ecc_thr;
reg reg [pt.NUM_THREADS-1:0] iccm_correction_state;
reg reg [pt.NUM_THREADS-1:0] iccm_corr_scnd_fetch;
   reg                     iccm_stop_fetch;                     
   reg           ifc_select_tid_f1;
   reg           iccm_wren;
   reg           iccm_rden;
   reg [2:0]     iccm_wr_size;
   reg [77:0]    iccm_wr_data;
   reg [63:0]    iccm_rd_data;
   reg [116:0]   iccm_rd_data_ecc;


   reg        core_rst_l;        reg        jtag_tdoEn;

   reg        dmi_reg_en;
   reg [6:0]  dmi_reg_addr;
   reg        dmi_reg_wr_en;
   reg [31:0] dmi_reg_wdata;
   reg [31:0] dmi_reg_rdata;
   reg        dmi_hard_reset;

   reg        dccm_clk_override;
   reg        icm_clk_override;
   reg        dec_tlu_core_ecc_disable;

   `ifdef RV_BUILD_AXI4

    wire [31:0]                 haddr;
   wire [2:0]                  hburst;
   wire                        hmastlock;
   wire [3:0]                  hprot;
   wire [2:0]                  hsize;
   wire [1:0]                  htrans;
   wire                        hwrite;

   wire [63:0]                 hrdata;
   wire                        hready;
   wire                        hresp;

      reg [31:0]                 lsu_haddr;
   reg [2:0]                  lsu_hburst;
   reg                        lsu_hmastlock;
   reg [3:0]                  lsu_hprot;
   reg [2:0]                  lsu_hsize;
   reg [1:0]                  lsu_htrans;
   reg                        lsu_hwrite;
   reg [63:0]                 lsu_hwdata;

   wire [63:0]                 lsu_hrdata;
   wire                        lsu_hready;
   wire                        lsu_hresp;

      reg [31:0]                sb_haddr;
   reg [2:0]                 sb_hburst;
   reg                       sb_hmastlock;
   reg [3:0]                 sb_hprot;
   reg [2:0]                 sb_hsize;
   reg [1:0]                 sb_htrans;
   reg                       sb_hwrite;
   reg [63:0]                sb_hwdata;

    wire [63:0]               sb_hrdata;
    wire                      sb_hready;
    wire                      sb_hresp;

      wire                       dma_hsel;
   wire [31:0]                dma_haddr;
   wire [2:0]                 dma_hburst;
   wire                       dma_hmastlock;
   wire [3:0]                 dma_hprot;
   wire [2:0]                 dma_hsize;
   wire [1:0]                 dma_htrans;
   wire                       dma_hwrite;
   wire [63:0]                dma_hwdata;
   wire                       dma_hreadyin;

   reg [63:0]                dma_hrdata;
   reg                       dma_hreadyout;
   reg                       dma_hresp;

      assign  hrdata[63:0]                           = '0;
   assign  hready                                 = '0;
   assign  hresp                                  = '0;
      assign  lsu_hrdata[63:0]                       = '0;
   assign  lsu_hready                             = '0;
   assign  lsu_hresp                              = '0;
      assign  sb_hrdata[63:0]                        = '0;
   assign  sb_hready                              = '0;
   assign  sb_hresp                               = '0;

      assign  dma_hsel                               = '0;
   assign  dma_haddr[31:0]                        = '0;
   assign  dma_hburst[2:0]                        = '0;
   assign  dma_hmastlock                          = '0;
   assign  dma_hprot[3:0]                         = '0;
   assign  dma_hsize[2:0]                         = '0;
   assign  dma_htrans[1:0]                        = '0;
   assign  dma_hwrite                             = '0;
   assign  dma_hwdata[63:0]                       = '0;
   assign  dma_hreadyin                           = '0;

`endif 
`ifdef RV_BUILD_AHB_LITE
   reg                           lsu_axi_awvalid;
   wire                           lsu_axi_awready;
   reg [pt.LSU_BUS_TAG-1:0]      lsu_axi_awid;
   reg [31:0]                    lsu_axi_awaddr;
   reg [3:0]                     lsu_axi_awregion;
   reg [7:0]                     lsu_axi_awlen;
   reg [2:0]                     lsu_axi_awsize;
   reg [1:0]                     lsu_axi_awburst;
   reg                           lsu_axi_awlock;
   reg [3:0]                     lsu_axi_awcache;
   reg [2:0]                     lsu_axi_awprot;
   reg [3:0]                     lsu_axi_awqos;

   reg                           lsu_axi_wvalid;
   wire                           lsu_axi_wready;
   reg [63:0]                    lsu_axi_wdata;
   reg [7:0]                     lsu_axi_wstrb;
   reg                           lsu_axi_wlast;

   wire                           lsu_axi_bvalid;
   reg                           lsu_axi_bready;
   wire [1:0]                     lsu_axi_bresp;
   wire [pt.LSU_BUS_TAG-1:0]      lsu_axi_bid;

      reg                           lsu_axi_arvalid;
   wire                           lsu_axi_arready;
   reg [pt.LSU_BUS_TAG-1:0]      lsu_axi_arid;
   reg [31:0]                    lsu_axi_araddr;
   reg [3:0]                     lsu_axi_arregion;
   reg [7:0]                     lsu_axi_arlen;
   reg [2:0]                     lsu_axi_arsize;
   reg [1:0]                     lsu_axi_arburst;
   reg                           lsu_axi_arlock;
   reg [3:0]                     lsu_axi_arcache;
   reg [2:0]                     lsu_axi_arprot;
   reg [3:0]                     lsu_axi_arqos;

   wire                           lsu_axi_rvalid;
   reg                           lsu_axi_rready;
   wire [pt.LSU_BUS_TAG-1:0]      lsu_axi_rid;
   wire [63:0]                    lsu_axi_rdata;
   wire [1:0]                     lsu_axi_rresp;
   wire                           lsu_axi_rlast;

         reg                           ifu_axi_awvalid;
   wire                           ifu_axi_awready;
   reg [pt.IFU_BUS_TAG-1:0]      ifu_axi_awid;
   reg [31:0]                    ifu_axi_awaddr;
   reg [3:0]                     ifu_axi_awregion;
   reg [7:0]                     ifu_axi_awlen;
   reg [2:0]                     ifu_axi_awsize;
   reg [1:0]                     ifu_axi_awburst;
   reg                           ifu_axi_awlock;
   reg [3:0]                     ifu_axi_awcache;
   reg [2:0]                     ifu_axi_awprot;
   reg [3:0]                     ifu_axi_awqos;

   reg                           ifu_axi_wvalid;
   wire                           ifu_axi_wready;
   reg [63:0]                    ifu_axi_wdata;
   reg [7:0]                     ifu_axi_wstrb;
   reg                           ifu_axi_wlast;

   wire                           ifu_axi_bvalid;
   reg                           ifu_axi_bready;
   wire [1:0]                     ifu_axi_bresp;
   wire [pt.IFU_BUS_TAG-1:0]      ifu_axi_bid;

      reg                           ifu_axi_arvalid;
   wire                           ifu_axi_arready;
   reg [pt.IFU_BUS_TAG-1:0]      ifu_axi_arid;
   reg [31:0]                    ifu_axi_araddr;
   reg [3:0]                     ifu_axi_arregion;
   reg [7:0]                     ifu_axi_arlen;
   reg [2:0]                     ifu_axi_arsize;
   reg [1:0]                     ifu_axi_arburst;
   reg                           ifu_axi_arlock;
   reg [3:0]                     ifu_axi_arcache;
   reg [2:0]                     ifu_axi_arprot;
   reg [3:0]                     ifu_axi_arqos;

   wire                           ifu_axi_rvalid;
   reg                           ifu_axi_rready;
   wire [pt.IFU_BUS_TAG-1:0]      ifu_axi_rid;
   wire [63:0]                    ifu_axi_rdata;
   wire [1:0]                     ifu_axi_rresp;
   wire                           ifu_axi_rlast;

         reg                           sb_axi_awvalid;
   wire                           sb_axi_awready;
   reg [pt.SB_BUS_TAG-1:0]       sb_axi_awid;
   reg [31:0]                    sb_axi_awaddr;
   reg [3:0]                     sb_axi_awregion;
   reg [7:0]                     sb_axi_awlen;
   reg [2:0]                     sb_axi_awsize;
   reg [1:0]                     sb_axi_awburst;
   reg                           sb_axi_awlock;
   reg [3:0]                     sb_axi_awcache;
   reg [2:0]                     sb_axi_awprot;
   reg [3:0]                     sb_axi_awqos;

   reg                           sb_axi_wvalid;
   wire                           sb_axi_wready;
   reg [63:0]                    sb_axi_wdata;
   reg [7:0]                     sb_axi_wstrb;
   reg                           sb_axi_wlast;

   wire                           sb_axi_bvalid;
   reg                           sb_axi_bready;
   wire [1:0]                     sb_axi_bresp;
   wire [pt.SB_BUS_TAG-1:0]       sb_axi_bid;

      reg                           sb_axi_arvalid;
   wire                           sb_axi_arready;
   reg [pt.SB_BUS_TAG-1:0]       sb_axi_arid;
   reg [31:0]                    sb_axi_araddr;
   reg [3:0]                     sb_axi_arregion;
   reg [7:0]                     sb_axi_arlen;
   reg [2:0]                     sb_axi_arsize;
   reg [1:0]                     sb_axi_arburst;
   reg                           sb_axi_arlock;
   reg [3:0]                     sb_axi_arcache;
   reg [2:0]                     sb_axi_arprot;
   reg [3:0]                     sb_axi_arqos;

   wire                           sb_axi_rvalid;
   reg                           sb_axi_rready;
   wire [pt.SB_BUS_TAG-1:0]       sb_axi_rid;
   wire [63:0]                    sb_axi_rdata;
   wire [1:0]                     sb_axi_rresp;
   wire                           sb_axi_rlast;

         wire                           dma_axi_awvalid;
   reg                           dma_axi_awready;
   wire [pt.DMA_BUS_TAG-1:0]      dma_axi_awid;
   wire [31:0]                    dma_axi_awaddr;
   wire [2:0]                     dma_axi_awsize;
   wire [2:0]                     dma_axi_awprot;
   wire [7:0]                     dma_axi_awlen;
   wire [1:0]                     dma_axi_awburst;


   wire                           dma_axi_wvalid;
   reg                           dma_axi_wready;
   wire [63:0]                    dma_axi_wdata;
   wire [7:0]                     dma_axi_wstrb;
   wire                           dma_axi_wlast;

   reg                           dma_axi_bvalid;
   wire                           dma_axi_bready;
   reg [1:0]                     dma_axi_bresp;
   reg [pt.DMA_BUS_TAG-1:0]      dma_axi_bid;

      wire                           dma_axi_arvalid;
   reg                           dma_axi_arready;
   wire [pt.DMA_BUS_TAG-1:0]      dma_axi_arid;
   wire [31:0]                    dma_axi_araddr;
   wire [2:0]                     dma_axi_arsize;
   wire [2:0]                     dma_axi_arprot;
   wire [7:0]                     dma_axi_arlen;
   wire [1:0]                     dma_axi_arburst;

   reg                           dma_axi_rvalid;
   wire                           dma_axi_rready;
   reg [pt.DMA_BUS_TAG-1:0]      dma_axi_rid;
   reg [63:0]                    dma_axi_rdata;
   reg [1:0]                     dma_axi_rresp;
   reg                           dma_axi_rlast;

      assign lsu_axi_awready = '0;
   assign lsu_axi_wready = '0;
   assign lsu_axi_bvalid = '0;
   assign lsu_axi_bresp[1:0] = '0;
   assign lsu_axi_bid[pt.LSU_BUS_TAG-1:0] = '0;

   assign lsu_axi_arready = '0;
   assign lsu_axi_rvalid = '0;
   assign lsu_axi_rid[pt.LSU_BUS_TAG-1:0] = '0;
   assign lsu_axi_rdata[63:0] = '0;
   assign lsu_axi_rresp[1:0] = '0;
   assign lsu_axi_rlast = '0;

      assign ifu_axi_awready = '0;
   assign ifu_axi_wready = '0;
   assign ifu_axi_bvalid = '0;
   assign ifu_axi_bresp[1:0] = '0;
   assign ifu_axi_bid[pt.IFU_BUS_TAG-1:0] = '0;

   assign ifu_axi_arready = '0;
   assign ifu_axi_rvalid = '0;
   assign ifu_axi_rid[pt.IFU_BUS_TAG-1:0] = '0;
   assign ifu_axi_rdata[63:0] = '0;
   assign ifu_axi_rresp[1:0] = '0;
   assign ifu_axi_rlast = '0;

      assign sb_axi_awready = '0;
   assign sb_axi_wready = '0;
   assign sb_axi_bvalid = '0;
   assign sb_axi_bresp[1:0] = '0;
   assign sb_axi_bid[pt.SB_BUS_TAG-1:0] = '0;

   assign sb_axi_arready = '0;
   assign sb_axi_rvalid = '0;
   assign sb_axi_rid[pt.SB_BUS_TAG-1:0] = '0;
   assign sb_axi_rdata[63:0] = '0;
   assign sb_axi_rresp[1:0] = '0;
   assign sb_axi_rlast = '0;

      assign  dma_axi_awvalid = '0;
   assign  dma_axi_awid[pt.DMA_BUS_TAG-1:0] = '0;
   assign  dma_axi_awaddr[31:0] = '0;
   assign  dma_axi_awsize[2:0] = '0;
   assign  dma_axi_awprot[2:0] = '0;
   assign  dma_axi_awlen[7:0] = '0;
   assign  dma_axi_awburst[1:0] = '0;

   assign  dma_axi_wvalid = '0;
   assign  dma_axi_wdata[63:0] = '0;
   assign  dma_axi_wstrb[7:0] = '0;
   assign  dma_axi_wlast = '0;

   assign  dma_axi_bready = '0;

   assign  dma_axi_arvalid = '0;
   assign  dma_axi_arid[pt.DMA_BUS_TAG-1:0] = '0;
   assign  dma_axi_araddr[31:0] = '0;
   assign  dma_axi_arsize[2:0] = '0;
   assign  dma_axi_arprot[2:0] = '0;
   assign  dma_axi_arlen[7:0] = '0;
   assign  dma_axi_arburst[1:0] = '0;

   assign  dma_axi_rready = '0;

`endif 

      eh2_swerv #(.pt(pt)) swerv (

                               );

      eh2_mem #(.pt(pt)) mem (
        .rst_l(core_rst_l),

        );

     dmi_wrapper  dmi_wrapper (
                      .trst_n(jtag_trst_n),                      .tck   (jtag_tck),                         .tms   (jtag_tms),                         .tdi   (jtag_tdi),                         .tdo   (jtag_tdo),                         .tdoEnable (),                  
                      .core_rst_n  (dbg_rst_l),                .core_clk    (clk),                       .jtag_id     (jtag_id),                   .rd_data     (dmi_reg_rdata),             .reg_wr_data (dmi_reg_wdata),             .reg_wr_addr (dmi_reg_addr),              .reg_en      (dmi_reg_en),                .reg_wr_en   (dmi_reg_wr_en),              .dmi_hard_reset   (dmi_hard_reset)   );


endmodule

