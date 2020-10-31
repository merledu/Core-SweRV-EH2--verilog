
module eh2_dec_ib_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input wire free_clk,                       input wire active_clk,                  
   input wire tid,                         

   input wire dec_i0_tid_d,                     input wire dec_i1_tid_d,                  

   input wire dbg_cmd_valid,     input wire dbg_cmd_tid,    
   input wire dbg_cmd_write,     input wire [1:0]           dbg_cmd_type,      input wire [31:0]          dbg_cmd_addr,   
   input wire exu_flush_final,                
   input wire dec_i1_cancel_e1,


   input eh2_br_pkt_t i0_brp,                         input eh2_br_pkt_t i1_brp,
   input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i0_bp_index,    input wire [pt.BHT_GHR_SIZE-1:0] ifu_i0_bp_fghr,    input wire [pt.BTB_BTAG_SIZE-1:0] ifu_i0_bp_btag,    input wire [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] ifu_i1_bp_index,    input wire [pt.BHT_GHR_SIZE-1:0] ifu_i1_bp_fghr,    input wire [pt.BTB_BTAG_SIZE-1:0] ifu_i1_bp_btag, 
   input wire ifu_i0_pc4,                      input wire ifu_i1_pc4,

   input eh2_predecode_pkt_t  ifu_i0_predecode,
   input eh2_predecode_pkt_t  ifu_i1_predecode,

   input wire ifu_i0_valid,                    input wire ifu_i1_valid,

   input wire [1:0]  ifu_i0_icaf_type,                           
   input wire ifu_i0_icaf,                     input wire ifu_i0_icaf_f1,                  input wire ifu_i0_dbecc,                 
   input wire [31:0]  ifu_i0_instr,              input wire [31:0]  ifu_i1_instr,

   input wire [31:1]  ifu_i0_pc,                 input wire [31:1] ifu_i1_pc,

   input wire dec_i0_decode_d,                 input wire dec_i1_decode_d,


   input wire rst_l,                           input wire clk,

   output logic ib3_valid_d,                  output logic ib2_valid_d,                  output logic ib1_valid_d,                  output logic ib0_valid_d,               
   output logic ib0_valid_in,                 output logic ib0_lsu_in,                   output logic ib0_mul_in,                   output logic ib0_i0_only_in,            
   output logic [31:0] i0_instr_d,            output logic [31:0] i1_instr_d,         
   output logic [31:1] i0_pc_d,               output logic [31:1] i1_pc_d,

   output logic i0_pc4_d,                     output logic i1_pc4_d,

   output eh2_br_pkt_t i0_br_p,                    output eh2_br_pkt_t i1_br_p,
   output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i0_bp_index,               output logic [pt.BHT_GHR_SIZE-1:0]           i0_bp_fghr,    output logic [pt.BTB_BTAG_SIZE-1:0]          i0_bp_btag,    output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] i1_bp_index,               output logic [pt.BHT_GHR_SIZE-1:0]           i1_bp_fghr,    output logic [pt.BTB_BTAG_SIZE-1:0]          i1_bp_btag, 
   output logic i0_icaf_d,                    output logic i1_icaf_d,

   output logic i0_icaf_f1_d,                 output logic i1_icaf_f1_d,

   output logic i0_dbecc_d,                   output logic i1_dbecc_d,
   output logic debug_wdata_rs1_d,         
   output logic debug_fence_d,             
   output logic i0_debug_valid_d,          
   input wire [15:0] ifu_i0_cinst,               input wire [15:0] ifu_i1_cinst,

   output logic [15:0] i0_cinst_d,            output logic [15:0] i1_cinst_d,

   output eh2_predecode_pkt_t i0_predecode,
   output eh2_predecode_pkt_t i1_predecode,

   output logic [1:0] i0_icaf_type_d,
   output logic [1:0] i1_icaf_type_d,

   input wire scan_mode

   );

   reg         flush_final;

wire [3:0] ibval_in;
wire [3:0] ibval;

wire write_i1_ib3;
wire write_i0_ib3;
wire write_i1_ib2;
wire write_i0_ib2;
wire write_i1_ib1;
wire write_i0_ib1;
   wire         write_i0_ib0;

wire shift2;
wire shift1;
wire shift0;

wire shift_ib1_ib0;
wire shift_ib2_ib1;
wire shift_ib3_ib2;
   wire         shift_ib2_ib0;
   wire         shift_ib3_ib1;


wire ifu_i0_val;
wire ifu_i1_val;
   wire         debug_valid;
   wire [4:0]   dreg;
   wire [11:0]  dcsr;
   wire [31:0]  ib0_debug_in;

   wire         debug_read;
   wire         debug_write;
   wire         debug_read_gpr;
   wire         debug_write_gpr;
   wire         debug_read_csr;
   wire         debug_write_csr;
   wire [3:0]   ibvalid;

   wire [3:0]   i0_wen;
   wire [3:1]   i1_wen;
   wire [3:0]   shift_ibval;
   wire [3:0]   ibwrite;

   wire         i1_cancel_e1;

   wire                       debug_fence_in;
   wire [1:0]   align_val;

   localparam BRWIDTH = pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1+pt.BHT_GHR_SIZE+pt.BTB_BTAG_SIZE;

wire [BRWIDTH-1:0] bp3_in;
wire [BRWIDTH-1:0] bp3_final;
wire [BRWIDTH-1:0] bp3,
                        bp2_in, bp2_final, bp2,
                        bp1_in, bp1_final, bp1,
                        bp0_in, bp0_final, bp0, bpsave;


wire [BRWIDTH-1:0] ifu_i0_brdata;
wire [BRWIDTH-1:0] ifu_i1_brdata;

   wire                       i0_decode_d;
   wire                       i1_decode_d;

   eh2_ib_pkt_t ib3_in, ib3_final, ib3;
   eh2_ib_pkt_t ib2_in, ib2_final, ib2;
   eh2_ib_pkt_t ib1_in, ib1_final, ib1_final_in, ib1;
   eh2_ib_pkt_t ib0_in, ib0_final, ib0_final_in, ib0, ib0_raw, ibsave;

   wire                       debug_valid_d;
wire mul_in;
wire lsu_in;
wire i0_only_in;

   eh2_ib_pkt_t ifu_i0_ibp, ifu_i1_ibp;
rvdff #(1) flush_upperff (.*, .clk(free_clk), .din(exu_flush_final), .dout(flush_final));

  

   assign i1_cancel_e1 = dec_i1_cancel_e1;

   assign ibvalid[3:0] = ibval[3:0] | i0_wen[3:0] | {i1_wen[3:1],1'b0};

   assign ibval_in[3:0] = (({4{shift0}} & ((i1_cancel_e1) ? {ibval[2:0],1'b1} : ibvalid[3:0] )) |
                           ({4{shift1}} & {1'b0, ibvalid[3:1]}) |
                           ({4{shift2}} & {2'b0, ibvalid[3:2]})) & ~{4{flush_final}};

 rvdff #(4) ibvalff (.*, .clk(active_clk), .din(ibval_in[3:0]), .dout(ibval[3:0]));


   assign align_val[1:0] = {ifu_i1_valid,ifu_i0_valid};



   assign ifu_i0_val = align_val[0] & ~ibval[3] & ~i1_cancel_e1 & ~flush_final;
   assign ifu_i1_val = align_val[1] & ~ibval[2] & ~i1_cancel_e1 & ~flush_final;


      assign i0_wen[0] = ~ibval[0]             & (ifu_i0_val | debug_valid);
   assign i0_wen[1] =  ibval[0] & ~ibval[1] & ifu_i0_val;
   assign i0_wen[2] =  ibval[1] & ~ibval[2] & ifu_i0_val;
   assign i0_wen[3] =  ibval[2] & ~ibval[3] & ifu_i0_val;

   assign i1_wen[1] = ~ibval[0]             & ifu_i1_val;
   assign i1_wen[2] =  ibval[0] & ~ibval[1] & ifu_i1_val;
   assign i1_wen[3] =  ibval[1] & ~ibval[2] & ifu_i1_val;


   assign ifu_i0_ibp.cinst         = ifu_i0_cinst;
   assign ifu_i0_ibp.predecode     = ifu_i0_predecode;
   assign ifu_i0_ibp.icaf_type     = ifu_i0_icaf_type;
   assign ifu_i0_ibp.icaf_f1       = ifu_i0_icaf_f1;
   assign ifu_i0_ibp.dbecc         = ifu_i0_dbecc;
   assign ifu_i0_ibp.icaf          = ifu_i0_icaf;
   assign ifu_i0_ibp.pc            = ifu_i0_pc;
   assign ifu_i0_ibp.pc4           = ifu_i0_pc4;
   assign ifu_i0_ibp.brp           = i0_brp;
   assign ifu_i0_ibp.inst          = ifu_i0_instr;

   assign ifu_i1_ibp.cinst         = ifu_i1_cinst;
   assign ifu_i1_ibp.predecode     = ifu_i1_predecode;
   assign ifu_i1_ibp.icaf_type     = '0;
   assign ifu_i1_ibp.icaf_f1       = '0;
   assign ifu_i1_ibp.dbecc         = '0;
   assign ifu_i1_ibp.icaf          = '0;
   assign ifu_i1_ibp.pc            = ifu_i1_pc;
   assign ifu_i1_ibp.pc4           = ifu_i1_pc4;
   assign ifu_i1_ibp.brp           = i1_brp;
   assign ifu_i1_ibp.inst          = ifu_i1_instr;









   assign debug_valid = dbg_cmd_valid & (dbg_cmd_type[1:0] != 2'h2) & (dbg_cmd_tid == tid);


   assign debug_read  = debug_valid & ~dbg_cmd_write;
   assign debug_write = debug_valid &  dbg_cmd_write;

   assign debug_read_gpr  = debug_read  & (dbg_cmd_type[1:0]==2'h0);
   assign debug_write_gpr = debug_write & (dbg_cmd_type[1:0]==2'h0);
   assign debug_read_csr  = debug_read  & (dbg_cmd_type[1:0]==2'h1);
   assign debug_write_csr = debug_write & (dbg_cmd_type[1:0]==2'h1);

   assign dreg[4:0]  = dbg_cmd_addr[4:0];
   assign dcsr[11:0] = dbg_cmd_addr[11:0];


   assign ib0_debug_in[31:0] = ({32{debug_read_gpr}}  & {12'b000000000000,dreg[4:0],15'b110000000110011}) |
                               ({32{debug_write_gpr}} & {20'b00000000000000000110,dreg[4:0],7'b0110011}) |
                               ({32{debug_read_csr}}  & {dcsr[11:0],20'b00000010000001110011}) |
                               ({32{debug_write_csr}} & {dcsr[11:0],20'b00000001000001110011});


     

   

 rvdffs #(1) debug_wdata_rs1ff (.*, .clk(free_clk), .en(ibwrite[0]), .din(debug_write_gpr | debug_write_csr), .dout(debug_wdata_rs1_d));


   // special fence csr for use only in debug mode


   assign debug_fence_in = debug_write_csr & (dcsr[11:0] == 12'h7c4);

   rvdffs #(1) debug_fence_ff (.*,  .clk(free_clk), .en(ibwrite[0]), .din(debug_fence_in),  .dout(debug_fence_d));

   rvdffs #(1) debug_valid_ff (.*,  .clk(free_clk), .en(ibwrite[0]), .din(debug_valid),     .dout(debug_valid_d));

 
 
   assign i0_debug_valid_d = debug_valid_d & ibval[0];

   assign ib3_in = ({$bits(eh2_ib_pkt_t){write_i0_ib3}} & ifu_i0_ibp) |
                   ({$bits(eh2_ib_pkt_t){write_i1_ib3}} & ifu_i1_ibp);

   assign ib3_final = (i1_cancel_e1) ? ib2 : ib3_in;
rvdffe #($bits(eh2_ib_pkt_t)) ib3ff (.*, .en(ibwrite[3]), .din(ib3_final), .dout(ib3));

 
   assign ib2_in = ({$bits(eh2_ib_pkt_t){write_i0_ib2}} & ifu_i0_ibp) |
                   ({$bits(eh2_ib_pkt_t){write_i1_ib2}} & ifu_i1_ibp) |
                   ({$bits(eh2_ib_pkt_t){shift_ib3_ib2}} & ib3);

   assign ib2_final = (i1_cancel_e1) ? ib1 : ib2_in;
rvdffe #($bits(eh2_ib_pkt_t)) ib2ff (.*, .en(ibwrite[2]), .din(ib2_final), .dout(ib2));

 
   assign ib1_in = ({$bits(eh2_ib_pkt_t){write_i0_ib1}} & ifu_i0_ibp) |
                   ({$bits(eh2_ib_pkt_t){write_i1_ib1}} & ifu_i1_ibp) |
                   ({$bits(eh2_ib_pkt_t){shift_ib2_ib1}} & ib2) |
                   ({$bits(eh2_ib_pkt_t){shift_ib3_ib1}} & ib3);

   assign ib1_final = (i1_cancel_e1) ? ib0 : ib1_in;

   assign ib1_final_in = (ibwrite[1]) ? ib1_final : ib1;

   rvdffe #($bits(eh2_ib_pkt_t)) ib1ff (.*, .en(ibwrite[1]), .din(ib1_final), .dout(ib1));

   assign ib0_raw = ({$bits(eh2_ib_pkt_t){write_i0_ib0}} & ifu_i0_ibp) |
                    ({$bits(eh2_ib_pkt_t){shift_ib1_ib0}} & ib1) |
                    ({$bits(eh2_ib_pkt_t){shift_ib2_ib0}} & ib2);
   always @* begin
      ib0_in = ib0_raw;

      if (debug_valid) begin
         ib0_in.inst = ib0_debug_in[31:0];
         ib0_in.predecode = '0;
         ib0_in.dbecc = '0;
         ib0_in.icaf = '0;
         ib0_in.icaf_f1 = '0;
         ib0_in.brp.valid = '0;
         ib0_in.brp.br_error = '0;
         ib0_in.brp.br_start_error = '0;

         ib0_in.predecode.legal1=1'b1;
         ib0_in.predecode.i0_only=1'b1;

      end
   end

   
   assign lsu_in = (write_i0_ib0 & ifu_i0_predecode.lsu) |
                   (shift_ib1_ib0 & ib1.predecode.lsu) |
                   (shift_ib2_ib0 & ib2.predecode.lsu) |
                   (~write_i0_ib0 & ~shift_ib1_ib0 & ~shift_ib2_ib0 & ib0.predecode.lsu);

   assign mul_in = (write_i0_ib0 & ifu_i0_predecode.mul) |
                   (shift_ib1_ib0 & ib1.predecode.mul) |
                   (shift_ib2_ib0 & ib2.predecode.mul) |
                   (~write_i0_ib0 & ~shift_ib1_ib0 & ~shift_ib2_ib0 & ib0.predecode.mul);

   assign i0_only_in = (write_i0_ib0 & ifu_i0_predecode.i0_only) |
                       (shift_ib1_ib0 & ib1.predecode.i0_only) |
                       (shift_ib2_ib0 & ib2.predecode.i0_only) |
                       (~write_i0_ib0 & ~shift_ib1_ib0 & ~shift_ib2_ib0 & ib0.predecode.i0_only);

   
   assign ib0_final = (i1_cancel_e1) ? ibsave : ib0_in;

   assign ib0_final_in = (ibwrite[0]) ? ib0_final : ib0;
 rvdffe #($bits(eh2_ib_pkt_t)) ib0ff (.*, .en(ibwrite[0]), .din(ib0_final), .dout(ib0));

 
   assign i0_cinst_d[15:0] = ib0.cinst;

   assign i1_cinst_d[15:0] = ib1.cinst;

   assign i0_predecode = ib0.predecode;
   assign i1_predecode = ib1.predecode;

   assign  ib0_lsu_in = lsu_in;
   assign  ib0_mul_in = mul_in;
   assign  ib0_i0_only_in = i0_only_in;

   assign i1_icaf_type_d[1:0] = ib1.icaf_type;
   assign i0_icaf_type_d[1:0] = ib0.icaf_type;

   assign i1_icaf_f1_d = ib1.icaf_f1;
   assign i0_icaf_f1_d = ib0.icaf_f1;

   assign i1_dbecc_d = ib1.dbecc;
   assign i0_dbecc_d = ib0.dbecc;

   assign i1_icaf_d = ib1.icaf;
   assign i0_icaf_d = ib0.icaf;

   assign i1_pc_d[31:1] = ib1.pc;
   assign i0_pc_d[31:1] = ib0.pc;

   assign i1_pc4_d = ib1.pc4;
   assign i0_pc4_d = ib0.pc4;

   assign i1_instr_d[31:0] = ib1.inst;
   assign i0_instr_d[31:0] = ib0.inst;

   assign i1_br_p = ib1.brp;
   assign i0_br_p = ib0.brp;


   assign ibwrite[3:0] = {  write_i0_ib3 | write_i1_ib3                                 | i1_cancel_e1,
                            write_i0_ib2 | write_i1_ib2 | shift_ib3_ib2                 | i1_cancel_e1,
                            write_i0_ib1 | write_i1_ib1 | shift_ib2_ib1 | shift_ib3_ib1 | i1_cancel_e1,
                            write_i0_ib0 | shift_ib1_ib0 | shift_ib2_ib0                | i1_cancel_e1
                            };


   
   assign ifu_i0_brdata = {ifu_i0_bp_index, ifu_i0_bp_fghr, ifu_i0_bp_btag};
   assign ifu_i1_brdata = {ifu_i1_bp_index, ifu_i1_bp_fghr, ifu_i1_bp_btag};



   assign bp3_in = ({BRWIDTH{write_i0_ib3}} & ifu_i0_brdata) |
                   ({BRWIDTH{write_i1_ib3}} & ifu_i1_brdata);

   assign bp3_final = (i1_cancel_e1) ? bp2 : bp3_in;

   rvdffe #(BRWIDTH) bp3indexff (.*, .en(ibwrite[3]), .din(bp3_final), .dout(bp3));


   assign bp2_in = ({BRWIDTH{write_i0_ib2}} & ifu_i0_brdata) |
                   ({BRWIDTH{write_i1_ib2}} & ifu_i1_brdata) |
                   ({BRWIDTH{shift_ib3_ib2}} & bp3);

   assign bp2_final = (i1_cancel_e1) ? bp1 : bp2_in;

rvdffe #(BRWIDTH) bp2indexff (.*, .en(ibwrite[2]), .din(bp2_final), .dout(bp2));

  
   assign bp1_in = ({BRWIDTH{write_i0_ib1}} & ifu_i0_brdata) |
                   ({BRWIDTH{write_i1_ib1}} & ifu_i1_brdata) |
                   ({BRWIDTH{shift_ib2_ib1}} & bp2) |
                   ({BRWIDTH{shift_ib3_ib1}} & bp3);

   assign bp1_final = (i1_cancel_e1) ? bp0 : bp1_in;
rvdffe #(BRWIDTH) bp1indexff (.*, .en(ibwrite[1]), .din(bp1_final), .dout(bp1));

  
   assign bp0_in = ({BRWIDTH{write_i0_ib0}} & ifu_i0_brdata) |
                   ({BRWIDTH{shift_ib1_ib0}} & bp1) |
                   ({BRWIDTH{shift_ib2_ib0}} & bp2);

   assign bp0_final = (i1_cancel_e1) ? bpsave : bp0_in;
rvdffe #(BRWIDTH) bp0indexff (.*, .en(ibwrite[0]), .din(bp0_final), .dout(bp0));

 

   assign {i1_bp_index, i1_bp_fghr, i1_bp_btag} = bp1;
   assign {i0_bp_index, i0_bp_fghr, i0_bp_btag} = bp0;

         assign ib3_valid_d = ibval[3];
   assign ib2_valid_d = ibval[2];
   assign ib1_valid_d = ibval[1];
   assign ib0_valid_d = ibval[0];

   assign ib0_valid_in = ibval_in[0];

   assign i0_decode_d = dec_i0_decode_d & (tid == dec_i0_tid_d);
   assign i1_decode_d = dec_i1_decode_d & (tid == dec_i1_tid_d);

   assign shift1 = i0_decode_d ^ i1_decode_d;

   assign shift2 = i0_decode_d & i1_decode_d;

   assign shift0 = ~shift1 & ~shift2;

rvdffe #($bits(eh2_ib_pkt_t)) ibsaveff (.*, .en(shift2), .din(ib1),    .dout(ibsave));

   rvdffe #(BRWIDTH)         bpsaveindexff (.*, .en(shift2), .din(bp1),  .dout(bpsave));

 
 

     assign shift_ibval[3:0] = ({4{shift1}} & {1'b0, ibval[3:1] }) |
                             ({4{shift2}} & {2'b0, ibval[3:2]}) |
                             ({4{shift0}} & ibval[3:0]);

   assign write_i0_ib0 = ~shift_ibval[0]                & (ifu_i0_val | debug_valid);
   assign write_i0_ib1 =  shift_ibval[0] & ~shift_ibval[1] & ifu_i0_val;
   assign write_i0_ib2 =  shift_ibval[1] & ~shift_ibval[2] & ifu_i0_val;
   assign write_i0_ib3 =  shift_ibval[2] & ~shift_ibval[3] & ifu_i0_val;

   assign write_i1_ib1 = ~shift_ibval[0]                & ifu_i1_val;
   assign write_i1_ib2 =  shift_ibval[0] & ~shift_ibval[1] & ifu_i1_val;
   assign write_i1_ib3 =  shift_ibval[1] & ~shift_ibval[2] & ifu_i1_val;


   assign shift_ib1_ib0 = shift1 & ibval[1];
   assign shift_ib2_ib1 = shift1 & ibval[2];
   assign shift_ib3_ib2 = shift1 & ibval[3];

   assign shift_ib2_ib0 = shift2 & ibval[2];
   assign shift_ib3_ib1 = shift2 & ibval[3];


endmodule
