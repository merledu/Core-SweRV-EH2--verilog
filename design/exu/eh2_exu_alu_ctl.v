

module eh2_exu_alu_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input wire clk,                             input wire active_clk,                      input wire rst_l,                           input wire scan_mode,                    
   input wire [pt.NUM_THREADS-1:0] flush,                input wire enable,                          input wire valid,                           input wire ap_in_tid,                       input  eh2_alu_pkt_t  ap,                              input wire [31:0]    a,                               input wire [31:0]    b,                               input wire [31:1]    pc,                              input  eh2_predict_pkt_t predict_p,                    input wire [12:1]    brimm,                        

   output logic [31:0]    out,                             output logic [pt.NUM_THREADS-1:0] flush_upper,          output logic [31:1]    flush_path,                      output logic [31:1]    pc_ff,                           output logic           pred_correct,                    output eh2_predict_pkt_t predict_p_ff                 );


   wire        [31:0]    aout;
wire cout;
wire ov;
wire neg;
   wire        [31:0]    lout;
   wire        [31:0]    sout;
wire sel_wire;
wire sel_shift;
wire sel_adder;
   wire                  slt_one;
   wire                  actual_taken;
   reg signed [31:0]    a_ff;
   reg        [31:0]    b_ff;
   reg        [12:1]    brimm_ff;
   reg        [31:1]    pcout;
   reg                  valid_ff;
   wire                  cond_mispredict;
   wire                  target_mispredict;
wire eq;
wire ne;
wire lt;
wire ge;
   eh2_predict_pkt_t     pp_ff;
   wire                  any_jal;
   wire        [1:0]     newhist;
   wire                  sel_pc;
   wire        [31:0]    csr_write_data;




   rvdff  #(1)  validff (.*, .clk(active_clk),    .din(valid & ~flush[ap_in_tid]), .dout(valid_ff));
   rvdffe #(32) aff     (.*, .en(enable & valid), .din(a[31:0]),                   .dout(a_ff[31:0]));
   rvdffe #(32) bff     (.*, .en(enable & valid), .din(b[31:0]),                   .dout(b_ff[31:0]));
   rvdffe #(31) pcff    (.*, .en(enable),         .din(pc[31:1]),                  .dout(pc_ff[31:1]));   // any PC is run through here - doesn't have to be alu
   rvdffe #(12) brimmff (.*, .en(enable),         .din(brimm[12:1]),               .dout(brimm_ff[12:1]));

   rvdffe #($bits(eh2_predict_pkt_t)) predictpacketff (.*, .en(enable), .din(predict_p), .dout (pp_ff));


   
      
         
         
   
      
            
      

   wire        [31:0]    bm;

   assign bm[31:0]            = ( ap.sub )  ?  ~b_ff[31:0]  :  b_ff[31:0];

   assign {cout, aout[31:0]}  = {1'b0, a_ff[31:0]} + {1'b0, bm[31:0]} + {32'b0, ap.sub};

   assign ov                  = (~a_ff[31] & ~bm[31] &  aout[31]) |
                                ( a_ff[31] &  bm[31] & ~aout[31] );

   assign lt                  = (~ap.unsign & (neg ^ ov)) |
                                ( ap.unsign & ~cout);

   assign eq                  = (a_ff[31:0] == b_ff[31:0]);
   assign ne                  = ~eq;
   assign neg                 =  aout[31];
   assign ge                  = ~lt;



   assign lout[31:0]          =  ( {32{ap.land}} &  a_ff[31:0] &  b_ff[31:0]  ) |
                                 ( {32{ap.lor }} & (a_ff[31:0] |  b_ff[31:0]) ) |
                                 ( {32{ap.lxor}} & (a_ff[31:0] ^  b_ff[31:0]) );



   wire        [5:0]     shift_amount;
   wire        [31:0]    shift_mask;
   wire        [62:0]    shift_extend;
   wire        [62:0]    shift_long;


   assign shift_amount[5:0]            = ( { 6{ap.sll}}   & (6'd32 - {1'b0,b_ff[4:0]}) ) |                                            ( { 6{ap.srl}}   &          {1'b0,b_ff[4:0]}  ) |
                                         ( { 6{ap.sra}}   &          {1'b0,b_ff[4:0]}  );


   assign shift_mask[31:0]             = ( 32'hffffffff << ({5{ap.sll}} & b_ff[4:0]) );


   assign shift_extend[31:0]           =  a_ff[31:0];

   assign shift_extend[62:32]          = ( {31{ap.sra}} & {31{a_ff[31]}} ) |
                                         ( {31{ap.sll}} &     a_ff[30:0] );


   assign shift_long[62:0]    = ( shift_extend[62:0] >> shift_amount[4:0] );   
   assign sout[31:0]          = ( shift_long[31:0] & shift_mask[31:0] );




   assign sel_logic           =  ap.land | ap.lor | ap.lxor;
   assign sel_shift           =  ap.sll  | ap.srl | ap.sra;
   assign sel_adder           = (ap.add  | ap.sub) & ~ap.slt;
   assign sel_pc              =  ap.jal  | pp_ff.pcall | pp_ff.pja | pp_ff.pret;
   assign csr_write_data[31:0]= (ap.csr_imm)  ?  b_ff[31:0]  :  a_ff[31:0];

   assign slt_one             =  ap.slt & lt;



   assign out[31:0]           = ({32{sel_logic}}    &  lout[31:0]           ) |
                                ({32{sel_shift}}    &  sout[31:0]           ) |
                                ({32{sel_adder}}    &  aout[31:0]           ) |
                                ({32{sel_pc}}       & {pcout[31:1],1'b0}    ) |
                                ({32{ap.csr_write}} &  csr_write_data[31:0] ) |
                                                      {31'b0, slt_one}       ;



   
   assign any_jal             =  ap.jal      |
                                 pp_ff.pcall |
                                 pp_ff.pja   |
                                 pp_ff.pret;

   assign actual_taken        = (ap.beq & eq) |
                                (ap.bne & ne) |
                                (ap.blt & lt) |
                                (ap.bge & ge) |
                                 any_jal;

      rvbradder ibradder (
                     .pc     ( pc_ff[31:1]    ),
                     .offset ( brimm_ff[12:1] ),
                     .dout   ( pcout[31:1]    ));



         
   assign pred_correct        = (ap.predict_nt & ~actual_taken & ~any_jal) |
                                (ap.predict_t  &  actual_taken & ~any_jal);


      assign flush_path[31:1]    = (any_jal) ? aout[31:1] : pcout[31:1];


      assign cond_mispredict     = (ap.predict_t  & ~actual_taken) |
                                (ap.predict_nt &  actual_taken);


   
   assign target_mispredict   =  pp_ff.pret & (pp_ff.prett[31:1] != aout[31:1]);

   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
     assign flush_upper[i]    = ( ap.jal | cond_mispredict | target_mispredict) & valid_ff & (i == ap.tid) & ~flush[i];
   end


                                          
   assign newhist[1]          = ( pp_ff.hist[1] &  pp_ff.hist[0]) | (~pp_ff.hist[0] & actual_taken);
   assign newhist[0]          = (~pp_ff.hist[1] & ~actual_taken)  | ( pp_ff.hist[1] & actual_taken);

   always @* begin
      predict_p_ff            =  pp_ff;

      predict_p_ff.misp       = ( valid_ff )  ? ( (cond_mispredict | target_mispredict) & ~flush[ap.tid] )  :  pp_ff.misp;
      predict_p_ff.ataken     = ( valid_ff )  ?  actual_taken  :  pp_ff.ataken;
      predict_p_ff.hist[1]    = ( valid_ff )  ?  newhist[1]    :  pp_ff.hist[1];
      predict_p_ff.hist[0]    = ( valid_ff )  ?  newhist[0]    :  pp_ff.hist[0];

   end



endmodule 