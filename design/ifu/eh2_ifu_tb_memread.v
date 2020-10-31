
module eh2_ifu_tb_memread;

   reg [15:0] compressed [0:128000];    reg [31:0] expected [0:128000];   

   reg        rst_l;
   reg        clk;

   integer          clk_count;



   reg [31:0] expected_val;
   reg [15:0] compressed_din;

   reg [31:0] actual;

   wire        error;

   integer      i;
   initial begin

      clk=0;
      rst_l=0;

            $readmemh ("left64k", compressed );
      $readmemh ("right64k", expected );

                                    

      $dumpfile ("top.vcd");
      $dumpvars;
      $dumpon;

   end

   always #50 clk =~clk;

   always @(posedge clk) begin
      clk_count = clk_count +1;
      if (clk_count>=1 & clk_count<=3) rst_l <= 1'b0;
      else rst_l <= 1'b1;

      if (clk_count > 3) begin

         compressed_din[15:0] <= compressed[clk_count-3];          expected_val[31:0] <= expected[clk_count-3];

      end

      if (clk_count == 65000) begin
         $dumpoff;
         $finish;
      end
   end 
   always @(negedge clk) begin
      if (clk_count > 3 & error) begin
         $display("clock: %d compressed %h error actual %h expected %h",clk_count,compressed_din,actual,expected_val);
      end
   end


   eh2_ifu_compress_ctl align (.*,.din(compressed_din[15:0]),.dout(actual[31:0]));

   assign error = actual[31:0] != expected_val[31:0];


endmodule 