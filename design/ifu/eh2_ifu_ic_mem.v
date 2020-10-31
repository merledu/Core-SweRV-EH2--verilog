module eh2_ifu_ic_mem
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
  (

      input wire clk,
      input wire rst_l,
      input wire clk_override,
      input wire dec_tlu_core_ecc_disable,

      input wire [31:1]                            ic_rw_addr,
      input wire [pt.ICACHE_NUM_WAYS-1:0]          ic_wr_en  ,               input wire ic_rd_en  ,                input wire [pt.ICACHE_INDEX_HI:3]           ic_debug_addr,            input wire ic_debug_rd_en,           input wire ic_debug_wr_en,           input wire ic_debug_tag_array,       input wire [pt.ICACHE_NUM_WAYS-1:0]          ic_debug_way,             input wire [63:0]                            ic_premux_data,           input wire ic_sel_premux_data, 
      input wire [pt.ICACHE_BANKS_WAY-1:0][70:0]  ic_wr_data,               output logic [63:0]                           ic_rd_data ,              output logic [70:0]                           ic_debug_rd_data ,        output logic [25:0]                           ictag_debug_rd_data,      input wire [70:0]                           ic_debug_wr_data,   
      output logic [pt.ICACHE_BANKS_WAY-1:0]        ic_eccerr,                       output logic [pt.ICACHE_BANKS_WAY-1:0]        ic_parerr,                       input wire [pt.ICACHE_NUM_WAYS-1:0]          ic_tag_valid,              

      output logic [pt.ICACHE_NUM_WAYS-1:0]         ic_rd_hit,         output logic                                  ic_tag_perr,       input wire scan_mode
      ) ;
 EH2_IC_TAG #(.pt(pt)) ic_tag_inst
          (
           .*,
           .ic_wr_en     (ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]),
           .ic_debug_addr(ic_debug_addr[pt.ICACHE_INDEX_HI:3]),
           .ic_rw_addr   (ic_rw_addr[31:3])
           ) ;

   EH2_IC_DATA #(.pt(pt)) ic_data_inst
          (
           .*,
           .ic_wr_en     (ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]),
           .ic_debug_addr(ic_debug_addr[pt.ICACHE_INDEX_HI:3]),
           .ic_rw_addr   (ic_rw_addr[pt.ICACHE_INDEX_HI:1])
           ) ;



 endmodule


module EH2_IC_DATA
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
     (
      input wire clk,
      input wire rst_l,
      input wire clk_override,


      input wire [pt.ICACHE_INDEX_HI:1]  ic_rw_addr,
      input wire [pt.ICACHE_NUM_WAYS-1:0]ic_wr_en,
      input wire ic_rd_en,           
      input wire [pt.ICACHE_BANKS_WAY-1:0][70:0]    ic_wr_data,               output logic [63:0]                             ic_rd_data ,                                       input wire [70:0]                             ic_debug_wr_data,         output logic [70:0]                             ic_debug_rd_data ,        output logic [pt.ICACHE_BANKS_WAY-1:0] ic_parerr,
      output logic [pt.ICACHE_BANKS_WAY-1:0] ic_eccerr,          input wire [pt.ICACHE_INDEX_HI:3]     ic_debug_addr,           input wire ic_debug_rd_en,            input wire ic_debug_wr_en,            input wire ic_debug_tag_array,        input wire [pt.ICACHE_NUM_WAYS-1:0]   ic_debug_way,              input wire [63:0]                     ic_premux_data,            input wire ic_sel_premux_data,  
      input wire [pt.ICACHE_NUM_WAYS-1:0]ic_rd_hit,
      input wire scan_mode

      ) ;





   reg [pt.ICACHE_TAG_INDEX_LO-1:1]                                             ic_rw_addr_ff;
   reg [pt.ICACHE_BANKS_WAY-1:0][pt.ICACHE_NUM_WAYS-1:0]                        ic_b_sb_wren;       reg [pt.ICACHE_BANKS_WAY-1:0][pt.ICACHE_NUM_WAYS-1:0]                        ic_b_sb_rden;       reg [pt.ICACHE_BANKS_WAY-1:0]                                                ic_b_rden;          reg [pt.ICACHE_BANKS_WAY-1:0]                                                ic_b_rden_ff;       reg [pt.ICACHE_BANKS_WAY-1:0]                                                ic_debug_sel_sb;


reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_BANKS_WAY-1:0] [70:0] wb_dout [pt.ICACHE_BANKS_WAY-1:0] [70:0];
reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_BANKS_WAY-1:0] [70:0] ic_sb_wr_data [pt.ICACHE_BANKS_WAY-1:0] [70:0];
reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_BANKS_WAY-1:0] [70:0] ic_bank_wr_data [pt.ICACHE_BANKS_WAY-1:0] [70:0];
reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_BANKS_WAY-1:0] [70:0] wb_dout_ecc_bank [pt.ICACHE_BANKS_WAY-1:0] [70:0];
reg [pt.ICACHE_NUM_WAYS-1:0] [pt.ICACHE_BANKS_WAY-1:0] [70:0] wb_dout_ecc_bank_ff [pt.ICACHE_BANKS_WAY-1:0] [70:0];
reg [pt.ICACHE_NUM_WAYS-1:0] [141:0] wb_dout_way;
reg [pt.ICACHE_NUM_WAYS-1:0] [141:0] wb_dout_way_pre;
reg [pt.ICACHE_NUM_WAYS-1:0] [141:0] wb_dout_way_with_premux;
   wire [141:0]                                                                  wb_dout_ecc;

   wire [pt.ICACHE_BANKS_WAY-1:0]                                                bank_check_en;
   reg [pt.ICACHE_BANKS_WAY-1:0]                                                bank_check_en_ff;


   reg [pt.ICACHE_BANKS_WAY-1:0][pt.ICACHE_NUM_WAYS-1:0]                        ic_bank_way_clken;        reg [pt.ICACHE_NUM_WAYS-1:0]                                                 ic_debug_rd_way_en;       reg [pt.ICACHE_NUM_WAYS-1:0]                                                 ic_debug_rd_way_en_ff;    reg [pt.ICACHE_NUM_WAYS-1:0]                                                 ic_debug_wr_way_en;       reg [pt.ICACHE_INDEX_HI:1]                                                   ic_rw_addr_q;
   wire [pt.ICACHE_BANKS_WAY-1:0] [pt.ICACHE_INDEX_HI : pt.ICACHE_DATA_INDEX_LO] ic_rw_addr_bank_q;
   wire [pt.ICACHE_TAG_LO-1 : pt.ICACHE_DATA_INDEX_LO]                           ic_rw_addr_q_inc;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                                 ic_rd_hit_q;

   wire                                                                          ic_rd_en_with_debug;
wire ic_rw_addr_wrap;
wire ic_cacheline_wrap_ff;
   reg                                                                          ic_debug_rd_en_ff;


   assign  ic_debug_rd_way_en[pt.ICACHE_NUM_WAYS-1:0] =  {pt.ICACHE_NUM_WAYS{ic_debug_rd_en & ~ic_debug_tag_array}} & ic_debug_way[pt.ICACHE_NUM_WAYS-1:0] ;
   assign  ic_debug_wr_way_en[pt.ICACHE_NUM_WAYS-1:0] =  {pt.ICACHE_NUM_WAYS{ic_debug_wr_en & ~ic_debug_tag_array}} & ic_debug_way[pt.ICACHE_NUM_WAYS-1:0] ;

   always @* begin : clkens
      ic_bank_way_clken   = '0;

      for ( integer i=0; i<pt.ICACHE_BANKS_WAY; i++) begin: wr_ens
       ic_b_sb_wren[i]        =  ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]  |
                                       (ic_debug_wr_way_en[pt.ICACHE_NUM_WAYS-1:0] & {pt.ICACHE_NUM_WAYS{ic_debug_addr[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == i}}) ;
       ic_debug_sel_sb[i]     = (ic_debug_addr[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == i );
       ic_sb_wr_data[i]       = (ic_debug_sel_sb[i] & ic_debug_wr_en) ? ic_debug_wr_data : ic_bank_wr_data[i] ;
       ic_b_rden[i]           =  ic_rd_en_with_debug & ( ( ~ic_rw_addr_q[pt.ICACHE_BANK_HI] & (i==0)) |
                                                         (( ic_rw_addr_q[pt.ICACHE_BANK_HI] & ic_rw_addr_q[2:1] != 2'b00) & (i==0)) |
                                                         (  ic_rw_addr_q[pt.ICACHE_BANK_HI] & (i==1)) |
                                                         ((~ic_rw_addr_q[pt.ICACHE_BANK_HI] & ic_rw_addr_q[2:1] != 2'b00) & (i==1)) ) ;



       ic_b_sb_rden[i]        =  {pt.ICACHE_NUM_WAYS{ic_b_rden[i]}}   ;


       for ( integer j=0; j<pt.ICACHE_NUM_WAYS; j++) begin: way_clkens
         ic_bank_way_clken[i][j] |= ic_b_sb_rden[i][j] | clk_override | ic_b_sb_wren[i][j];
       end
     end    end 
  assign ic_rd_en_with_debug                          = ((ic_rd_en   | ic_debug_rd_en ) & ~(|ic_wr_en));
  assign ic_rw_addr_q[pt.ICACHE_INDEX_HI:1] = (ic_debug_rd_en | ic_debug_wr_en) ?
                                              {ic_debug_addr[pt.ICACHE_INDEX_HI:3],2'b0} :
                                              ic_rw_addr[pt.ICACHE_INDEX_HI:1] ;

   assign ic_rw_addr_q_inc[pt.ICACHE_TAG_LO-1:pt.ICACHE_DATA_INDEX_LO] = ic_rw_addr_q[pt.ICACHE_TAG_LO-1 : pt.ICACHE_DATA_INDEX_LO] + 1 ;
   assign ic_rw_addr_wrap                                        = ic_rw_addr_q[pt.ICACHE_BANK_HI] & ic_rd_en_with_debug & ~(|ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]);
   assign ic_cacheline_wrap_ff                                   = ic_rw_addr_ff[pt.ICACHE_TAG_INDEX_LO-1:pt.ICACHE_BANK_LO] == {(pt.ICACHE_TAG_INDEX_LO - pt.ICACHE_BANK_LO){1'b1}};


   assign ic_rw_addr_bank_q[0] = ~ic_rw_addr_wrap ? ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO] : {ic_rw_addr_q[pt.ICACHE_INDEX_HI: pt.ICACHE_TAG_INDEX_LO] , ic_rw_addr_q_inc[pt.ICACHE_TAG_INDEX_LO-1: pt.ICACHE_DATA_INDEX_LO] } ;
   assign ic_rw_addr_bank_q[1] = ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO];



 if (pt.ICACHE_WAYPACK == 0 ) begin : PACKED_0
   for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: WAYS
      for (genvar k=0; k<pt.ICACHE_BANKS_WAY; k++) begin: BANKS_WAY         if (pt.ICACHE_ECC) begin : ECC1
        if ($clog2(pt.ICACHE_DATA_DEPTH) == 13 )   begin : size_8192
           ram_8192x71 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
        end

        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 12 )   begin : size_4096
           ram_4096x71 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
        end

        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 11 ) begin : size_2048
           ram_2048x71 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
        end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 10 ) begin : size_1024
           ram_1024x71 ic_bank_sb_way_data (.ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
        end 
         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 9 ) begin : size_512
           ram_512x71 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
         end 
         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 8 ) begin : size_256
           ram_256x71 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
         end 
         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 7 ) begin : size_128
           ram_128x71 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
         end 
         else  begin : size_64
           ram_64x71 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][70:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k]),
                                     .CLK (clk)
                                    );
         end       end 

     else  begin : ECC0
        if ($clog2(pt.ICACHE_DATA_DEPTH) == 13 ) begin : size_8192
           ram_8192x68 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0] ),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
        end 
        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 12 ) begin : size_4096
           ram_4096x68 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
        end 
        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 11 ) begin : size_2048
           ram_2048x68 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
        end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 10 ) begin : size_1024
           ram_1024x68 ic_bank_sb_way_data (.ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
        end 

         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 9 ) begin : size_512
           ram_512x68 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
         end
         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 8 ) begin : size_256
           ram_256x68 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
         end
         else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 7 ) begin : size_128
           ram_128x68 ic_bank_sb_way_data ( .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
         end 
         else  begin : size_64
           ram_64x68 ic_bank_sb_way_data (
                                     .ME(ic_bank_way_clken[k][i]),
                                     .WE (ic_b_sb_wren[k][i]),
                                     .D  (ic_sb_wr_data[k][67:0]),
                                     .ADR(ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q  (wb_dout[i][k][67:0]),
                                     .CLK (clk)
                                    );
         end       end       end    end  end 

   else begin : PACKED_1
  for (genvar k=0; k<pt.ICACHE_BANKS_WAY; k++) begin: BANKS_WAY             if (pt.ICACHE_ECC) begin : ECC1
        wire [pt.ICACHE_BANKS_WAY-1:0] [(71*pt.ICACHE_NUM_WAYS)-1 :0]   wb_packeddout, ic_b_sb_bit_en_vec;           // data and its bit enables
        for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: BITEN
           assign ic_b_sb_bit_en_vec[k][(71*i)+70:71*i] = {71{ic_b_sb_wren[k][i]}};
        end
        if ($clog2(pt.ICACHE_DATA_DEPTH) == 13 )   begin : size_8192
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_8192x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                    // OR of all the ways in the bank
                                     .WEM   (ic_b_sb_bit_en_vec[k]),                                               // 284 bits of bit enables
                                     .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end // block: WAYS

           else   begin : WAYS
                             ram_be_8192x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                    // OR of all the ways in the bank
                                     .WEM   (ic_b_sb_bit_en_vec[k]),                                               // 284 bits of bit enables
                                     .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end // block: WAYS
        end // block: size_8192




        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 12 )   begin : size_4096
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_4096x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_4096x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 

        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 11 ) begin : size_2048
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_2048x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_2048x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 10 ) begin : size_1024
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_1024x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_1024x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 9 ) begin : size_512
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_512x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_512x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 8 ) begin : size_256
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_256x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_256x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 7 ) begin : size_128
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_128x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_128x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else  begin : size_64
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_64x284 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_64x142 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][70:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 

       for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: WAYS
          assign wb_dout[i][k][70:0]  = wb_packeddout[k][(71*i)+70:71*i];
       end : WAYS

       end 

else  begin  : ECC0
        wire [pt.ICACHE_BANKS_WAY-1:0] [(68*pt.ICACHE_NUM_WAYS)-1 :0]   wb_packeddout, ic_b_sb_bit_en_vec;           // data and its bit enables
        for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: BITEN
           assign ic_b_sb_bit_en_vec[k][(68*i)+67:68*i] = {68{ic_b_sb_wren[k][i]}};
        end
        if ($clog2(pt.ICACHE_DATA_DEPTH) == 13 )   begin : size_8192
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_8192x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                    // OR of all the ways in the bank
                                     .WEM   (ic_b_sb_bit_en_vec[k]),                                               // 272 bits of bit enables
                                     .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end // block: WAYS
           else   begin : WAYS
                             ram_be_8192x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                    // OR of all the ways in the bank
                                     .WEM   (ic_b_sb_bit_en_vec[k]),                                               // 272 bits of bit enables
                                     .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end // block: WAYS
        end // block: size_8192

        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 12 )   begin : size_4096
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_4096x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_4096x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 

        else if ($clog2(pt.ICACHE_DATA_DEPTH) == 11 ) begin : size_2048
           if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_2048x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_2048x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 10 ) begin : size_1024
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_1024x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_1024x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 9 ) begin : size_512
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_512x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_512x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 8 ) begin : size_256
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_256x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_256x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else if ( $clog2(pt.ICACHE_DATA_DEPTH) == 7 ) begin : size_128
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_128x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_128x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
        else  begin : size_64
                   if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
                     ram_be_64x272 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end            else   begin : WAYS
                     ram_be_64x136 ic_bank_sb_way_data (
                                     .CLK   (clk),
                                     .WE    (|ic_b_sb_wren[k]),                                                                                         .WEM   (ic_b_sb_bit_en_vec[k]),                                                                                    .D     ({pt.ICACHE_NUM_WAYS{ic_sb_wr_data[k][67:0]}}),
                                     .ADR   (ic_rw_addr_bank_q[k][pt.ICACHE_INDEX_HI:pt.ICACHE_DATA_INDEX_LO]),
                                     .Q     (wb_packeddout[k]),
                                     .ME    (|ic_bank_way_clken[k])
                                    );
           end         end 
       for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: WAYS
          assign wb_dout[i][k][67:0]  = wb_packeddout[k][(68*i)+67:68*i];
       end
     end      end  end 

   assign ic_rd_hit_q[pt.ICACHE_NUM_WAYS-1:0] = ic_debug_rd_en_ff ? ic_debug_rd_way_en_ff[pt.ICACHE_NUM_WAYS-1:0] : ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0] ;


 if ( pt.ICACHE_ECC == 1) begin : ECC1_MUX
   assign ic_bank_wr_data[1][70:0] = ic_wr_data[1][70:0];
   assign ic_bank_wr_data[0][70:0] = ic_wr_data[0][70:0];

    always @* begin : rd_mux
      wb_dout_way_pre[pt.ICACHE_NUM_WAYS-1:0] = '0;

      for ( integer i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways
        for ( integer j=0; j<pt.ICACHE_BANKS_WAY; j++) begin : banks
         wb_dout_way_pre[i][70:0]      |=  ({71{(ic_rw_addr_ff[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == (pt.ICACHE_BANK_BITS)'(j))}}   &  wb_dout[i][j]);
         wb_dout_way_pre[i][141 : 71]  |=  ({71{(ic_rw_addr_ff[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == (pt.ICACHE_BANK_BITS)'(j-1))}} &  wb_dout[i][j]);
        end
      end
    end

    for ( genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways_mux1
      assign wb_dout_way[i][63:0] = (ic_rw_addr_ff[2:1] == 2'b00) ? wb_dout_way_pre[i][63:0]   :
                                    (ic_rw_addr_ff[2:1] == 2'b01) ?{wb_dout_way_pre[i][86:71], wb_dout_way_pre[i][63:16]} :
                                    (ic_rw_addr_ff[2:1] == 2'b10) ?{wb_dout_way_pre[i][102:71],wb_dout_way_pre[i][63:32]} :
                                                                   {wb_dout_way_pre[i][119:71],wb_dout_way_pre[i][63:48]};

      assign wb_dout_way_with_premux[i][63:0]  =  ic_sel_premux_data ? ic_premux_data[63:0] : wb_dout_way[i][63:0] ;
   end

   always @* begin : rd_out
      ic_debug_rd_data[70:0]     = '0;
      ic_rd_data[63:0]           = '0;
      wb_dout_ecc[141:0]         = '0;
      for ( integer i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways_mux2
         ic_rd_data[63:0]       |= ({64{ic_rd_hit_q[i] | ic_sel_premux_data}}) &  wb_dout_way_with_premux[i][63:0];
         ic_debug_rd_data[70:0] |= ({71{ic_rd_hit_q[i]}}) & wb_dout_way_pre[i][70:0];
         wb_dout_ecc[141:0]     |= {142{ic_rd_hit_q[i]}}  & wb_dout_way_pre[i];
      end
   end


 for (genvar i=0; i < pt.ICACHE_BANKS_WAY ; i++) begin : ic_ecc_error
    assign bank_check_en[i]    = |ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0] & ((i==0) | (~ic_cacheline_wrap_ff & (ic_b_rden_ff[pt.ICACHE_BANKS_WAY-1:0] == {pt.ICACHE_BANKS_WAY{1'b1}})));      assign wb_dout_ecc_bank[i] = wb_dout_ecc[(71*i)+70:(71*i)];

rvdff #(1) encod_en_ff (.*,
                    .din (bank_check_en[i]),
                    .dout(bank_check_en_ff[i]));

   rvdff #(71) bank_data_ff (.*,
                    .din (wb_dout_ecc_bank[i][70:0]),
                    .dout(wb_dout_ecc_bank_ff[i][70:0]));

   rvecc_decode_64  ecc_decode_64 (
                           .en               (bank_check_en_ff[i]),
                           .din              (wb_dout_ecc_bank_ff[i][63 : 0]),                  // [134:71],  [63:0]
                           .ecc_in           (wb_dout_ecc_bank_ff[i][70 : 64]),               // [141:135] [70:64]
                           .ecc_error        (ic_eccerr[i]));
     end 
  assign  ic_parerr[pt.ICACHE_BANKS_WAY-1:0]  = 'd0 ;
end 
else  begin : ECC0_MUX
   assign ic_bank_wr_data[1][67:0] = ic_wr_data[1][67:0];
   assign ic_bank_wr_data[0][67:0] = ic_wr_data[0][67:0];

   assign ic_bank_wr_data[1][70:68] = 3'b0;
   assign ic_bank_wr_data[0][70:68] = 3'b0;

   always @* begin : rd_mux
      wb_dout_way_pre[pt.ICACHE_NUM_WAYS-1:0] = '0;

   for ( integer i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways
     for ( integer j=0; j<pt.ICACHE_BANKS_WAY; j++) begin : banks
         wb_dout_way_pre[i][67:0]         |=  ({68{(ic_rw_addr_ff[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == (pt.ICACHE_BANK_BITS)'(j))}}   &  wb_dout[i][j]);
         wb_dout_way_pre[i][135 : 68]     |=  ({68{(ic_rw_addr_ff[pt.ICACHE_BANK_HI : pt.ICACHE_BANK_LO] == (pt.ICACHE_BANK_BITS)'(j-1))}} &  wb_dout[i][j]);
      end
     end
   end

   for ( genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways_mux1
      assign wb_dout_way[i][63:0] = (ic_rw_addr_ff[2:1] == 2'b00) ? wb_dout_way_pre[i][63:0]   :
                                    (ic_rw_addr_ff[2:1] == 2'b01) ?{wb_dout_way_pre[i][83:68],  wb_dout_way_pre[i][63:16]} :
                                    (ic_rw_addr_ff[2:1] == 2'b10) ?{wb_dout_way_pre[i][99:68],  wb_dout_way_pre[i][63:32]} :
                                                                   {wb_dout_way_pre[i][115:68], wb_dout_way_pre[i][63:48]};

      assign wb_dout_way_with_premux[i][63:0]      =  ic_sel_premux_data ? ic_premux_data[63:0]  : wb_dout_way[i][63:0] ;
   end

   always @* begin : rd_out
      ic_rd_data[63:0]   = '0;
      ic_debug_rd_data[70:0]   = '0;
      wb_dout_ecc[135:0] = '0;

      for ( integer i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : num_ways_mux2
         ic_rd_data[63:0]   |= ({64{ic_rd_hit_q[i] | ic_sel_premux_data}} &  wb_dout_way_with_premux[i][63:0]);
         ic_debug_rd_data[70:0] |= ({71{ic_rd_hit_q[i]}}) & {4'b0,wb_dout_way_pre[i][67:0]};
         wb_dout_ecc[135:0] |= {136{ic_rd_hit_q[i]}}  & wb_dout_way_pre[i];
      end
   end

   assign wb_dout_ecc_bank[0] =  wb_dout_ecc[67:0];
   assign wb_dout_ecc_bank[1] =  wb_dout_ecc[135:68];

   reg [pt.ICACHE_BANKS_WAY-1:0][3:0] ic_parerr_bank;

  for (genvar i=0; i < pt.ICACHE_BANKS_WAY ; i++) begin : ic_par_error
      assign bank_check_en[i]    = |ic_rd_hit[pt.ICACHE_NUM_WAYS-1:0] & ((i==0) | (~ic_cacheline_wrap_ff & (ic_b_rden_ff[pt.ICACHE_BANKS_WAY-1:0] == {pt.ICACHE_BANKS_WAY{1'b1}})));  
    rvdff #(1) encod_en_ff (.*,
                    .din (bank_check_en[i]),
                    .dout(bank_check_en_ff[i]));

      rvdff #(68) bank_data_ff (.*,
                    .din (wb_dout_ecc_bank[i][67:0]),
                    .dout(wb_dout_ecc_bank_ff[i][67:0]));

     for (genvar j=0; j<4; j++)  begin : parity
      rveven_paritycheck pchk (
                           .data_in   (wb_dout_ecc_bank_ff[i][16*(j+1)-1: 16*j]),
                           .parity_in (wb_dout_ecc_bank_ff[i][64+j]),
                           .parity_err(ic_parerr_bank[i][j])
                           );
        end
  end

     assign ic_parerr[1] = |ic_parerr_bank[1][3:0] & bank_check_en_ff[1];
     assign ic_parerr[0] = |ic_parerr_bank[0][3:0] & bank_check_en_ff[0];
     assign ic_eccerr [pt.ICACHE_BANKS_WAY-1:0] = 'd0 ;

end 

endmodule 

module EH2_IC_TAG
import eh2_pkg::*;
#(
`include "eh2_param.vh"
 )
     (
      input wire clk,
      input wire rst_l,
      input wire clk_override,
      input wire dec_tlu_core_ecc_disable,


      input wire [31:3]                                        ic_rw_addr,


      input wire [pt.ICACHE_NUM_WAYS-1:0]                     ic_wr_en,        input wire [pt.ICACHE_NUM_WAYS-1:0]                     ic_tag_valid,
      input wire ic_rd_en,

      input wire [pt.ICACHE_INDEX_HI:3]                       ic_debug_addr,            input wire ic_debug_rd_en,           input wire ic_debug_wr_en,           input wire ic_debug_tag_array,       input wire [pt.ICACHE_NUM_WAYS-1:0]                     ic_debug_way,       
      output logic [25:0]                                       ictag_debug_rd_data,
      input wire [70:0]                                       ic_debug_wr_data,   
      output logic [pt.ICACHE_NUM_WAYS-1:0]                    ic_rd_hit,
      output logic                                              ic_tag_perr,
      input wire scan_mode
   ) ;


   wire [pt.ICACHE_NUM_WAYS-1:0] [25:0]                           ic_tag_data_raw;
   wire [pt.ICACHE_NUM_WAYS-1:0] [25:0]                           ic_tag_data_raw_ff;
   reg [pt.ICACHE_NUM_WAYS-1:0] [37:pt.ICACHE_TAG_LO]            w_tout;
   reg [pt.ICACHE_NUM_WAYS-1:0] [37:pt.ICACHE_TAG_LO]            w_tout_ff;
   wire [25:0]                                 ic_tag_wr_data ;
   reg [pt.ICACHE_NUM_WAYS-1:0] [31:0]                           ic_tag_corrected_data_unc;
   reg [pt.ICACHE_NUM_WAYS-1:0] [06:0]                           ic_tag_corrected_ecc_unc;
   reg [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_single_ecc_error;
   reg [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_double_ecc_error;
   reg [6:0]                                  ic_tag_ecc;

   wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_way_perr ;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_debug_rd_way_en ;
   reg [pt.ICACHE_NUM_WAYS-1:0]                                  ic_debug_rd_way_en_ff ;

   wire [pt.ICACHE_INDEX_HI: pt.ICACHE_TAG_INDEX_LO] ic_rw_addr_q;
   reg [31:pt.ICACHE_DATA_INDEX_LO]              ic_rw_addr_ff;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_wren;             wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_wren_q;           wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_clken;
   wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_debug_wr_way_en;      wire [pt.ICACHE_NUM_WAYS-1:0]                                  ic_tag_valid_ff;
   reg                                                           ic_rd_en_ff;
   reg                                                           ic_rd_en_ff2;
   reg                                                           ic_wr_en_ff;     
   reg                                                           ic_tag_parity;


   assign  ic_tag_wren [pt.ICACHE_NUM_WAYS-1:0]  = ic_wr_en[pt.ICACHE_NUM_WAYS-1:0] & {pt.ICACHE_NUM_WAYS{(ic_rw_addr[pt.ICACHE_BEAT_ADDR_HI:4] == {pt.ICACHE_BEAT_BITS-1{1'b1}})}} ;
   assign  ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]  = {pt.ICACHE_NUM_WAYS{ic_rd_en | clk_override}} | ic_wr_en[pt.ICACHE_NUM_WAYS-1:0] | ic_debug_wr_way_en[pt.ICACHE_NUM_WAYS-1:0] | ic_debug_rd_way_en[pt.ICACHE_NUM_WAYS-1:0];
   rvdff #(32-pt.ICACHE_TAG_LO) adr_ff (.*,
                    .din ({ic_rw_addr[31:pt.ICACHE_TAG_LO]}),
                    .dout({ic_rw_addr_ff[31:pt.ICACHE_TAG_LO]}));

   rvdff #(pt.ICACHE_NUM_WAYS) tg_val_ff (.*,
                 .din ((ic_tag_valid[pt.ICACHE_NUM_WAYS-1:0] & {pt.ICACHE_NUM_WAYS{~ic_wr_en_ff}})),
                 .dout(ic_tag_valid_ff[pt.ICACHE_NUM_WAYS-1:0]));


   localparam PAD_BITS = 21 - (32 - pt.ICACHE_TAG_LO);  
      assign  ic_debug_rd_way_en[pt.ICACHE_NUM_WAYS-1:0] =  {pt.ICACHE_NUM_WAYS{ic_debug_rd_en & ic_debug_tag_array}} & ic_debug_way[pt.ICACHE_NUM_WAYS-1:0] ;
   assign  ic_debug_wr_way_en[pt.ICACHE_NUM_WAYS-1:0] =  {pt.ICACHE_NUM_WAYS{ic_debug_wr_en & ic_debug_tag_array}} & ic_debug_way[pt.ICACHE_NUM_WAYS-1:0] ;

   assign  ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]  =  ic_tag_wren[pt.ICACHE_NUM_WAYS-1:0]          |
                                  ic_debug_wr_way_en[pt.ICACHE_NUM_WAYS-1:0]   ;

if (pt.ICACHE_TAG_LO == 11) begin: SMALLEST
 if (pt.ICACHE_ECC) begin : ECC1_W
           rvecc_encode  tag_ecc_encode (
                                  .din    ({{pt.ICACHE_TAG_LO{1'b0}}, ic_rw_addr[31:pt.ICACHE_TAG_LO]}),
                                  .ecc_out({ ic_tag_ecc[6:0]}));

   assign  ic_tag_wr_data[25:0] = (ic_debug_wr_en & ic_debug_tag_array) ?
                                  {ic_debug_wr_data[68:64], ic_debug_wr_data[31:11]} :
                                  {ic_tag_ecc[4:0], ic_rw_addr[31:pt.ICACHE_TAG_LO]} ;
 end

 else begin : ECC0_W
           rveven_paritygen #(32-pt.ICACHE_TAG_LO) pargen  (.data_in   (ic_rw_addr[31:pt.ICACHE_TAG_LO]),
                                                 .parity_out(ic_tag_parity));

   assign  ic_tag_wr_data[21:0] = (ic_debug_wr_en & ic_debug_tag_array) ?
                                  {ic_debug_wr_data[64], ic_debug_wr_data[31:11]} :
                                  {ic_tag_parity, ic_rw_addr[31:pt.ICACHE_TAG_LO]} ;
 end 
end 

else begin: OTHERS
  if(pt.ICACHE_ECC) begin : ECC1_W
           rvecc_encode  tag_ecc_encode (
                                  .din    ({{pt.ICACHE_TAG_LO{1'b0}}, ic_rw_addr[31:pt.ICACHE_TAG_LO]}),
                                  .ecc_out({ ic_tag_ecc[6:0]}));

   assign  ic_tag_wr_data[25:0] = (ic_debug_wr_en & ic_debug_tag_array) ?
                                  {ic_debug_wr_data[68:64],ic_debug_wr_data[31:11]} :
                                  {ic_tag_ecc[4:0], {PAD_BITS{1'b0}},ic_rw_addr[31:pt.ICACHE_TAG_LO]} ;

  end
  else  begin : ECC0_W
   reg   ic_tag_parity ;
           rveven_paritygen #(32-pt.ICACHE_TAG_LO) pargen  (.data_in   (ic_rw_addr[31:pt.ICACHE_TAG_LO]),
                                                 .parity_out(ic_tag_parity));
   assign  ic_tag_wr_data[21:0] = (ic_debug_wr_en & ic_debug_tag_array) ?
                                  {ic_debug_wr_data[64], ic_debug_wr_data[31:11]} :
                                  {ic_tag_parity, {PAD_BITS{1'b0}},ic_rw_addr[31:pt.ICACHE_TAG_LO]} ;
  end 
end 

    assign ic_rw_addr_q[pt.ICACHE_INDEX_HI: pt.ICACHE_TAG_INDEX_LO] = (ic_debug_rd_en | ic_debug_wr_en) ?
                                                ic_debug_addr[pt.ICACHE_INDEX_HI: pt.ICACHE_TAG_INDEX_LO] :
                                                ic_rw_addr[pt.ICACHE_INDEX_HI: pt.ICACHE_TAG_INDEX_LO] ;
  rvdff #(pt.ICACHE_NUM_WAYS) tag_rd_wy_ff (.*,
                    .din ({ic_debug_rd_way_en[pt.ICACHE_NUM_WAYS-1:0]}),
                    .dout({ic_debug_rd_way_en_ff[pt.ICACHE_NUM_WAYS-1:0]}));

   rvdff #(1) rden_ff (.*,
                    .din (ic_rd_en),
                    .dout(ic_rd_en_ff));

   rvdff #(1) rden_ff2 (.*,
                    .din (ic_rd_en_ff),
                    .dout(ic_rd_en_ff2));

   rvdff #(1) ic_we_ff (.*,
                    .din (|ic_wr_en[pt.ICACHE_NUM_WAYS-1:0]),
                    .dout(ic_wr_en_ff));


if (pt.ICACHE_WAYPACK == 0 ) begin : PACKED_0
   for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: WAYS

   if (pt.ICACHE_ECC) begin : ECC1
      if (pt.ICACHE_TAG_DEPTH == 32)   begin : size_32
         ram_32x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
      end       if (pt.ICACHE_TAG_DEPTH == 64)   begin : size_64
         ram_64x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
      end       if (pt.ICACHE_TAG_DEPTH == 128)   begin : size_128
         ram_128x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
      end        if (pt.ICACHE_TAG_DEPTH == 256)   begin : size_256
         ram_256x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
       end        if (pt.ICACHE_TAG_DEPTH == 512)   begin : size_512
         ram_512x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
       end        if (pt.ICACHE_TAG_DEPTH == 1024)   begin : size_1024
         ram_1024x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
       end 

       if (pt.ICACHE_TAG_DEPTH == 2048)   begin : size_2048
         ram_2048x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
       end 
       if (pt.ICACHE_TAG_DEPTH == 4096)   begin : size_4096
         ram_4096x26  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[25:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][25:0]),
                                .CLK (clk)

                               );
       end 


         assign w_tout[i][31:pt.ICACHE_TAG_LO] = ic_tag_data_raw[i][31-pt.ICACHE_TAG_LO:0] ;
         assign w_tout[i][36:32]              = ic_tag_data_raw[i][25:21] ;

rvdff #(26) tg_data_raw_ff (.*,
                    .din ({ic_tag_data_raw[i][25:0]}),
                    .dout({ic_tag_data_raw_ff[i][25:0]}));

         rvecc_decode  ecc_decode (
                           .en(~dec_tlu_core_ecc_disable & ic_rd_en_ff2),
                           .sed_ded ( 1'b1 ),                               .din({11'b0,ic_tag_data_raw_ff[i][20:0]}),
                           .ecc_in({2'b0, ic_tag_data_raw_ff[i][25:21]}),
                           .dout(ic_tag_corrected_data_unc[i][31:0]),
                           .ecc_out(ic_tag_corrected_ecc_unc[i][6:0]),
                           .single_ecc_error(ic_tag_single_ecc_error[i]),
                           .double_ecc_error(ic_tag_double_ecc_error[i]));

          assign ic_tag_way_perr[i]= ic_tag_single_ecc_error[i] | ic_tag_double_ecc_error[i]  ;
      end
      else  begin : ECC0
          if (pt.ICACHE_TAG_DEPTH == 32)   begin : size_32
                   ram_32x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
          end           if (pt.ICACHE_TAG_DEPTH == 64)   begin : size_64
                   ram_64x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
          end            if (pt.ICACHE_TAG_DEPTH == 128)   begin : size_128
                   ram_128x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
           end            if (pt.ICACHE_TAG_DEPTH == 256)   begin : size_256
                   ram_256x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
           end            if (pt.ICACHE_TAG_DEPTH == 512)   begin : size_512
                   ram_512x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
           end            if (pt.ICACHE_TAG_DEPTH == 1024)   begin : size_1024
                   ram_1024x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
           end 
       if (pt.ICACHE_TAG_DEPTH == 2048)   begin : size_2048
         ram_2048x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
       end 
       if (pt.ICACHE_TAG_DEPTH == 4096)   begin : size_4096
         ram_4096x22  ic_way_tag (
                                .ME(ic_tag_clken[i]),
                                .WE (ic_tag_wren_q[i]),
                                .D  (ic_tag_wr_data[21:0]),
                                .ADR(ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q  (ic_tag_data_raw[i][21:0]),
                                .CLK (clk)

                               );
       end 
         assign w_tout[i][31:pt.ICACHE_TAG_LO] = ic_tag_data_raw[i][31-pt.ICACHE_TAG_LO:0] ;
         assign w_tout[i][32]                 = ic_tag_data_raw[i][21] ;


         rveven_paritycheck #(32-pt.ICACHE_TAG_LO) parcheck(.data_in   (w_tout_ff[i][31:pt.ICACHE_TAG_LO]),
                                                   .parity_in (w_tout_ff[i][32]),
                                                   .parity_err(ic_tag_way_perr[i]));
      end 
   end end 
else begin : PACKED_1

    wire [(26*pt.ICACHE_NUM_WAYS)-1 :0]  ic_tag_data_raw_packed, ic_tag_wren_biten_vec;           // data and its bit enables
    for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin: BITEN
        assign ic_tag_wren_biten_vec[(26*i)+25:26*i] = {26{ic_tag_wren_q[i]}};
     end


   if (pt.ICACHE_ECC) begin  : ECC1
      if (pt.ICACHE_TAG_DEPTH == 32)   begin : size_32
        if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_32x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               // all bits of bit enables

                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end // block: WAYS
      else begin : WAYS
                  ram_be_32x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               // all bits of bit enables

                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end // block: WAYS
      end // if (pt.ICACHE_TAG_DEPTH == 32
      if (pt.ICACHE_TAG_DEPTH == 64)   begin : size_64
        if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_64x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_64x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 128)   begin : size_128
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_128x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_128x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 256)   begin : size_256
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_256x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_256x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 512)   begin : size_512
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_512x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_512x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 1024)   begin : size_1024
         if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_1024x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_1024x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 2048)   begin : size_2048
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_2048x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_2048x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 4096)   begin  : size_4096
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_4096x104  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_4096x52  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(26*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[25:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(26*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
        for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin
          assign ic_tag_data_raw[i]  = ic_tag_data_raw_packed[(26*i)+25:26*i];
          assign w_tout[i][31:pt.ICACHE_TAG_LO] = ic_tag_data_raw[i][31-pt.ICACHE_TAG_LO:0] ;
          assign w_tout[i][36:32]              = ic_tag_data_raw[i][25:21] ;

 rvdff #(26) tg_data_raw_ff (.*,
                    .din ({ic_tag_data_raw[i][25:0]}),
                    .dout({ic_tag_data_raw_ff[i][25:0]}));

          rvecc_decode  ecc_decode (
                           .en(~dec_tlu_core_ecc_disable & ic_rd_en_ff2),
                           .sed_ded ( 1'b1 ),                               .din({11'b0,ic_tag_data_raw_ff[i][20:0]}),
                           .ecc_in({2'b0, ic_tag_data_raw_ff[i][25:21]}),
                           .dout(ic_tag_corrected_data_unc[i][31:0]),
                           .ecc_out(ic_tag_corrected_ecc_unc[i][6:0]),
                           .single_ecc_error(ic_tag_single_ecc_error[i]),
                           .double_ecc_error(ic_tag_double_ecc_error[i]));

          assign ic_tag_way_perr[i]= ic_tag_single_ecc_error[i] | ic_tag_double_ecc_error[i]  ;
     end 
   end 

   else  begin : ECC0
      if (pt.ICACHE_TAG_DEPTH == 32)   begin : size_32
        if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_32x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_32x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 64)   begin : size_64
        if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_64x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_64x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 128)   begin : size_128
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_128x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_128x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 256)   begin : size_256
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_256x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_256x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 512)   begin : size_512
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_512x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_512x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 1024)   begin : size_1024
         if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_1024x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_1024x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 2048)   begin : size_2048
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_2048x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_2048x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      if (pt.ICACHE_TAG_DEPTH == 4096)   begin  : size_4096
       if (pt.ICACHE_NUM_WAYS == 4) begin : WAYS
         ram_be_4096x88  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       else begin : WAYS
                  ram_be_4096x44  ic_way_tag (
                                .ME  (|ic_tag_clken[pt.ICACHE_NUM_WAYS-1:0]),
                                .WE  (|ic_tag_wren_q[pt.ICACHE_NUM_WAYS-1:0]),
                                .WEM (ic_tag_wren_biten_vec[(22*pt.ICACHE_NUM_WAYS)-1 :0]),                                               
                                .D   ({pt.ICACHE_NUM_WAYS{ic_tag_wr_data[21:0]}}),
                                .ADR (ic_rw_addr_q[pt.ICACHE_INDEX_HI:pt.ICACHE_TAG_INDEX_LO]),
                                .Q   (ic_tag_data_raw_packed[(22*pt.ICACHE_NUM_WAYS)-1 :0]),
                                .CLK (clk)

                               );
        end       end 
      for (genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : WAYS
          assign ic_tag_data_raw[i]  = ic_tag_data_raw_packed[(22*i)+21:22*i];
          assign w_tout[i][31:pt.ICACHE_TAG_LO] = ic_tag_data_raw[i][31-pt.ICACHE_TAG_LO:0] ;
          assign w_tout[i][32]                 = ic_tag_data_raw[i][21] ;

rvdff #(33-pt.ICACHE_TAG_LO) tg_data_raw_ff (.*,
                    .din (w_tout[i][32:pt.ICACHE_TAG_LO]),
                    .dout(w_tout_ff[i][32:pt.ICACHE_TAG_LO]));

          rveven_paritycheck #(32-pt.ICACHE_TAG_LO) parcheck(.data_in   (w_tout_ff[i][31:pt.ICACHE_TAG_LO]),
                                                   .parity_in (w_tout_ff[i][32]),
                                                   .parity_err(ic_tag_way_perr[i]));
      end 


   end end 

   always @* begin : tag_rd_out
      ictag_debug_rd_data[25:0] = '0;
      for ( integer j=0; j<pt.ICACHE_NUM_WAYS; j++) begin: debug_rd_out
         ictag_debug_rd_data[25:0] |=  pt.ICACHE_ECC ? ({26{ic_debug_rd_way_en_ff[j]}} & ic_tag_data_raw[j] ) : {4'b0, ({22{ic_debug_rd_way_en_ff[j]}} & ic_tag_data_raw[j][21:0])};
      end
   end


   for ( genvar i=0; i<pt.ICACHE_NUM_WAYS; i++) begin : ic_rd_hit_loop
      assign ic_rd_hit[i] = (w_tout[i][31:pt.ICACHE_TAG_LO] == ic_rw_addr_ff[31:pt.ICACHE_TAG_LO]) & ic_tag_valid[i] & ~ic_wr_en_ff;
   end

   assign  ic_tag_perr  = | (ic_tag_way_perr[pt.ICACHE_NUM_WAYS-1:0] & ic_tag_valid_ff[pt.ICACHE_NUM_WAYS-1:0] ) ;
endmodule 