

module eh2_ifu_ifc_ctl
import eh2_pkg::*;
#(
`include "eh2_param.vh"
)
  (
   input wire clk,
   input wire free_clk,
   input wire active_clk,

   input wire clk_override,    input wire rst_l,    input wire scan_mode, 
   input wire ic_hit_f2,         input wire ic_crit_wd_rdy,    input wire ifu_ic_mb_empty, 
   input wire ifu_fb_consume1,     input wire ifu_fb_consume2,  
   input wire dec_tlu_flush_noredir_wb,    input wire exu_flush_final,    input wire [31:1] exu_flush_path_final, 
   input wire ifu_bp_kill_next_f2,    input wire [31:1] ifu_bp_btb_target_f2, 
   input wire ic_dma_active,    input wire ic_write_stall,    input wire dma_iccm_stall_any, 
   input wire [31:0]  dec_tlu_mrac_ff ,   
   input wire tid,
   input wire ifc_select_tid_f1,

   output logic  fetch_uncacheable_f1, 
   output logic [31:1] fetch_addr_f1, 
   output logic  fetch_req_f1,     output logic  fetch_req_f1_raw,    output logic  fetch_req_f2,  
   output logic  pmu_fetch_stall, 
   output logic  iccm_access_f1,    output logic  region_acc_fault_f1,    output logic  dma_access_ok,    output logic  ready    );


wire [31:1] fetch_addr_bf;
wire [31:1] miss_addr;
reg [31:1] ifc_fetch_addr_f1_raw;
reg [31:1] ifc_fetch_addr_f2;
   wire [31:3]  fetch_addr_next;
   wire [31:1]  miss_addr_ns;
   wire [4:0]   cacheable_select;
reg [4:0] fb_write_f1;
wire [4:0] fb_write_ns;

   wire         ifc_fetch_req_bf;
wire fb_full_f1_ns;
wire fb_full_f1;
wire fb_right;
wire fb_right2;
wire fb_right3;
wire fb_left;
wire wfm;
wire fetch_ns;
wire idle;
   wire         fetch_req_f2_ns;
   wire         missff_en;
wire fetch_crit_word;
reg ic_crit_wd_rdy_d1;
reg fetch_crit_word_d1;
reg fetch_crit_word_d2;
wire my_bp_kill_next_f2;
wire sel_last_addr_bf;
wire sel_miss_addr_bf;
wire sel_btb_addr_bf;
wire sel_next_addr_bf;
wire miss_f2;
wire miss_a;
wire flush_fb;
reg dma_iccm_stall_any_f;
wire mb_empty_mod;
wire goto_idle;
wire leave_idle;
   wire         ic_crit_wd_rdy_mod;
   wire         miss_sel_flush;
   wire         miss_sel_f2;
   wire         miss_sel_f1;
   wire         miss_sel_bf;
   wire         fetch_bf_en;
   reg         ifc_fetch_req_f2_raw;
wire line_wrap;
wire lost_arb;
   wire [2:1]   fetch_addr_next_2_1;

   reg         ifc_f2_clk;

   wire         fetch_req_f1_won;
   wire         reset_delayed;
   reg         iccm_acc_in_range_f1;
   reg         iccm_acc_in_region_f1;



   if (pt.ICCM_ENABLE == 1)
     begin
        reg iccm_acc_in_region_f1;
        reg iccm_acc_in_range_f1;
     end
   wire dma_stall;

   rvoclkhdr ifu_fa2_cgc ( .en(fetch_req_f1_won | clk_override), .l1clk(ifc_f2_clk), .* );

localparam IDLE = 'd 0 ;localparam FETCH = 'd 1 ;localparam STALL = 'd 2 ;localparam WFM = 'd 3 ;   state_t state      ;
   state_t next_state ;

   assign dma_stall = ic_dma_active | dma_iccm_stall_any_f;

   assign reset_delayed = 1'b0;

   rvdff #(2) ran_ff (.*, .clk(free_clk), .din({dma_iccm_stall_any, miss_f2}), .dout({dma_iccm_stall_any_f, miss_a}));

      assign ic_crit_wd_rdy_mod = ic_crit_wd_rdy & ~((fetch_crit_word_d2 | ic_write_stall) & ~fetch_req_f2);

      assign fetch_crit_word = ic_crit_wd_rdy_mod & ~ic_crit_wd_rdy_d1 & ~exu_flush_final & ~ic_write_stall;
   assign my_bp_kill_next_f2 = ifu_bp_kill_next_f2 & ifc_fetch_req_f2_raw;
   assign missff_en = exu_flush_final | (~ic_hit_f2 & fetch_req_f2) | fetch_crit_word_d1 | my_bp_kill_next_f2 | (fetch_req_f2 & ~fetch_req_f1_won & ~fetch_crit_word_d2);
   assign miss_sel_flush = exu_flush_final & (((wfm | idle) & ~fetch_crit_word_d1)  | dma_stall | ic_write_stall | lost_arb);
   assign miss_sel_f2 = ~exu_flush_final & ~ic_hit_f2 & fetch_req_f2;
   assign miss_sel_f1 = ~exu_flush_final & ~miss_sel_f2 & ~fetch_req_f1_won & fetch_req_f2 & ~fetch_crit_word_d2 & ~my_bp_kill_next_f2;
   assign miss_sel_bf = ~miss_sel_f2 & ~miss_sel_f1 & ~miss_sel_flush;

   assign miss_addr_ns[31:1] = ( ({31{miss_sel_flush}} & exu_flush_path_final[31:1]) |
                                 ({31{miss_sel_f2}} & ifc_fetch_addr_f2[31:1]) |
                                 ({31{miss_sel_f1}} & fetch_addr_f1[31:1]) |
                                 ({31{miss_sel_bf}} & fetch_addr_bf[31:1]));

   rvdffe #(31) faddmiss_ff (.*, .en(missff_en), .din(miss_addr_ns[31:1]), .dout(miss_addr[31:1]));




            
   assign sel_last_addr_bf = ~miss_sel_flush & ~fetch_req_f1_won & fetch_req_f2 & ~my_bp_kill_next_f2;
   assign sel_miss_addr_bf = ~miss_sel_flush & ~my_bp_kill_next_f2 & ~fetch_req_f1_won & ~fetch_req_f2;
   assign sel_btb_addr_bf  = ~miss_sel_flush & my_bp_kill_next_f2;
   assign sel_next_addr_bf = ~miss_sel_flush & fetch_req_f1_won;


   assign fetch_addr_bf[31:1] = ( ({31{miss_sel_flush}} &  exu_flush_path_final[31:1]) |                                    ({31{sel_miss_addr_bf}} & miss_addr[31:1]) |                                    ({31{sel_btb_addr_bf}} & {ifu_bp_btb_target_f2[31:1]})|                                    ({31{sel_last_addr_bf}} & {fetch_addr_f1[31:1]})|                                    ({31{sel_next_addr_bf}} & {fetch_addr_next[31:3],fetch_addr_next_2_1[2:1]})); 
   assign fetch_addr_next[31:3] = fetch_addr_f1[31:3] + 29'b1;

   assign line_wrap = (fetch_addr_next[pt.ICACHE_TAG_INDEX_LO] ^ fetch_addr_f1[pt.ICACHE_TAG_INDEX_LO]);

   assign fetch_addr_next_2_1[2:1] = line_wrap ? 0 : fetch_addr_f1[2:1];

   assign ifc_fetch_req_bf = (fetch_ns | fetch_crit_word) ;
   assign fetch_bf_en = (fetch_ns | fetch_crit_word);

   assign miss_f2 = fetch_req_f2 & ~ic_hit_f2;

   assign mb_empty_mod = (ifu_ic_mb_empty | exu_flush_final) & ~dma_stall & ~miss_f2 & ~miss_a;

      assign goto_idle = exu_flush_final & dec_tlu_flush_noredir_wb;
      assign leave_idle = exu_flush_final & ~dec_tlu_flush_noredir_wb & idle;


   assign next_state[1] = (~state[1] & state[0] & ~reset_delayed & miss_f2 & ~goto_idle) |
                          (state[1] & ~reset_delayed & ~mb_empty_mod & ~goto_idle);

   assign next_state[0] = (~goto_idle & leave_idle) | (state[0] & ~goto_idle) |
                          (reset_delayed);

   assign flush_fb = exu_flush_final;

      assign fb_right = (~ifu_fb_consume1 & ~ifu_fb_consume2 & miss_f2) |                       ( ifu_fb_consume1 & ~ifu_fb_consume2 & ~fetch_req_f1_won & ~miss_f2) |                       (ifu_fb_consume2 &  fetch_req_f1_won & ~miss_f2); 

   assign fb_right2 = (ifu_fb_consume1 & ~ifu_fb_consume2 & miss_f2) |                       (ifu_fb_consume2 & ~fetch_req_f1_won); 
   assign fb_right3 = (ifu_fb_consume2 & miss_f2); 
   assign fb_left = fetch_req_f1_won & ~(ifu_fb_consume1 | ifu_fb_consume2) & ~miss_f2;

   assign fb_write_ns[4:0] = ( ({5{(flush_fb & ~fetch_req_f1_won)}} & 5'b00001) |
                               ({5{(flush_fb & fetch_req_f1_won)}} & 5'b00010) |
                               ({5{~flush_fb & fb_right }} & {1'b0, fb_write_f1[4:1]}) |
                               ({5{~flush_fb & fb_right2}} & {0, fb_write_f1[4:2]}) |
                               ({5{~flush_fb & fb_right3}} & {0, fb_write_f1[4:3]}  ) |
                               ({5{~flush_fb & fb_left  }} & {fb_write_f1[3:0], 1'b0}) |
                               ({5{~flush_fb & ~fb_right & ~fb_right2 & ~fb_left & ~fb_right3}}  & fb_write_f1[4:0]));


   assign fb_full_f1_ns = fb_write_ns[4];

   assign idle     = state      == IDLE  ;
   assign wfm      = state      == WFM   ;
   assign fetch_ns = next_state == FETCH ;

   rvdff #(2) fsm_ff (.*, .clk(active_clk), .din({next_state[1:0]}), .dout({state[1:0]}));
   rvdff #(6) fbwrite_ff (.*, .clk(active_clk), .din({fb_full_f1_ns, fb_write_ns[4:0]}), .dout({fb_full_f1, fb_write_f1[4:0]}));

if(pt.NUM_THREADS > 1) begin : ignoreconsume
   assign pmu_fetch_stall = wfm |
                                (fetch_req_f1_raw &
                                ( (fb_full_f1 & ~(exu_flush_final)) |
                                  dma_stall));
      assign fetch_req_f1 = ( fetch_req_f1_raw &
                               ~my_bp_kill_next_f2 &
                               ~(fb_full_f1 & ~(exu_flush_final)) &
                               ~dma_stall &
                               ~ic_write_stall &
                               ~dec_tlu_flush_noredir_wb );

end else begin
   assign pmu_fetch_stall = wfm |
                                (fetch_req_f1_raw &
                                ( (fb_full_f1 & ~(ifu_fb_consume2 | ifu_fb_consume1 | exu_flush_final)) |
                                  dma_stall));
      assign fetch_req_f1 = ( fetch_req_f1_raw &
                               ~my_bp_kill_next_f2 &
                               ~(fb_full_f1 & ~(ifu_fb_consume2 | ifu_fb_consume1 | exu_flush_final)) &
                               ~dma_stall &
                               ~ic_write_stall &
                               ~dec_tlu_flush_noredir_wb );
end
   assign ready = fetch_req_f1;
   assign fetch_req_f1_won = fetch_req_f1 & ~(tid ^ ifc_select_tid_f1);
   assign lost_arb = tid ^ ifc_select_tid_f1;
      assign fetch_req_f2_ns = fetch_req_f1_won & ~miss_f2;


   rvdff #(2) req_ff (.*, .clk(active_clk), .din({ifc_fetch_req_bf, fetch_req_f2_ns}), .dout({fetch_req_f1_raw, ifc_fetch_req_f2_raw}));

   assign fetch_req_f2 = ifc_fetch_req_f2_raw & ~exu_flush_final;

   rvdffe #(31) faddrf1_ff  (.*, .en(fetch_bf_en), .din(fetch_addr_bf[31:1]), .dout(ifc_fetch_addr_f1_raw[31:1]));
   rvdff #(31) faddrf2_ff (.*,  .clk(ifc_f2_clk), .din(fetch_addr_f1[31:1]), .dout(ifc_fetch_addr_f2[31:1]));

   assign fetch_addr_f1[31:1] = ( ({31{exu_flush_final}} & exu_flush_path_final[31:1]) |
                                      ({31{~exu_flush_final}} & ifc_fetch_addr_f1_raw[31:1]));

   rvdff #(3) iccrit_ff (.*, .clk(active_clk), .din({ic_crit_wd_rdy_mod, fetch_crit_word,    fetch_crit_word_d1}),
                                              .dout({ic_crit_wd_rdy_d1,  fetch_crit_word_d1, fetch_crit_word_d2}));


if (pt.ICCM_ENABLE == 1)
 begin
   rvrangecheck #( .CCM_SADR    (pt.ICCM_SADR),
                   .CCM_SIZE    (pt.ICCM_SIZE) ) iccm_rangecheck (
                                                                     .addr     ({fetch_addr_f1[31:1],1'b0}) ,
                                                                     .in_range (iccm_acc_in_range_f1) ,
                                                                     .in_region(iccm_acc_in_region_f1)
                                                                     );

   assign iccm_access_f1 = iccm_acc_in_range_f1 ;


   assign region_acc_fault_f1 = ~iccm_acc_in_range_f1 & iccm_acc_in_region_f1 ;

    if(pt.NUM_THREADS > 1) begin
   assign dma_access_ok = ( (~iccm_access_f1 |
                                 (fb_full_f1) |
                                 wfm |
                                 idle ) & ~exu_flush_final) |
                              dma_iccm_stall_any_f;
    end
    else begin
   assign dma_access_ok = ( (~iccm_access_f1 |
                                 (fb_full_f1 & ~(ifu_fb_consume2 | ifu_fb_consume1)) |
                                 wfm |
                                 idle ) & ~exu_flush_final) |
                              dma_iccm_stall_any_f;
       end

 end
else
 begin
   assign iccm_access_f1 = 1'b0 ;
   assign dma_access_ok  = 1'b0 ;
   assign region_acc_fault_f1  = 1'b0 ;
 end


   assign cacheable_select[4:0]    =  {fetch_addr_f1[31:28] , 1'b0 } ;
   assign fetch_uncacheable_f1 =  ~dec_tlu_mrac_ff[cacheable_select]  ; 
endmodule 
