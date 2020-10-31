
`define EH2_LOCAL_RAM_TEST_IO          \
input reg WE,       \
input reg ME,       \
input reg CLK



`define EH2_RAM(depth, width)              \
module ram_``depth``x``width(               \
   input wire [$clog2(depth)-1:0] ADR,     \
   input wire [(width-1):0] D,             \
   output logic [(width-1):0] Q,            \
    `EH2_LOCAL_RAM_TEST_IO                 \
);                                          \
reg [(width-1):0] ram_core [(depth-1):0];   \
                                            \
always @(posedge CLK) begin              \
   if (ME && WE) ram_core[ADR] = D;        \
   if (ME && ~WE) Q <= ram_core[ADR];       \
end                                         \
                                            \
                                            \
endmodule

`define EH2_RAM_BE(depth, width)           \
module ram_be_``depth``x``width(            \
   input wire [$clog2(depth)-1:0] ADR,     \
   input wire [(width-1):0] D, WEM,        \
   output logic [(width-1):0] Q,            \
    `EH2_LOCAL_RAM_TEST_IO                 \
);                                          \
reg [(width-1):0] ram_core [(depth-1):0];   \
                                            \
always @(posedge CLK) begin              \
   if (ME && WE) ram_core[ADR] = D & WEM | ~WEM & ram_core[ADR];\
   if (ME && ~WE) Q <= ram_core[ADR];       \
end                                         \
                                            \
                                            \
endmodule


module eh2_ram #(depth=4096, width=39) (
input wire [$clog2(depth)-1:0] ADR,
input wire [(width-1):0] D,
output logic [(width-1):0] Q,
 `EH2_LOCAL_RAM_TEST_IO
);
reg [(width-1):0] ram_core [(depth-1):0];

always @(posedge CLK) begin
   if (ME && WE) ram_core[ADR] = D;
   if (ME && ~WE) Q <= ram_core[ADR];
end
endmodule

`EH2_RAM(32768, 39)
`EH2_RAM(16384, 39)
`EH2_RAM(8192, 39)
`EH2_RAM(4096, 39)
`EH2_RAM(3072, 39)
`EH2_RAM(2048, 39)
`EH2_RAM(1536, 39)`EH2_RAM(1024, 39)
`EH2_RAM(768, 39)
`EH2_RAM(512, 39)
`EH2_RAM(256, 39)
`EH2_RAM(128, 39)
`EH2_RAM(1024, 20)
`EH2_RAM(512, 20)
`EH2_RAM(256, 20)
`EH2_RAM(128, 20)
`EH2_RAM(64, 20)
`EH2_RAM(4096, 34)
`EH2_RAM(2048, 34)
`EH2_RAM(1024, 34)
`EH2_RAM(512, 34)
`EH2_RAM(256, 34)
`EH2_RAM(128, 34)
`EH2_RAM(64, 34)
`EH2_RAM(8192, 68)
`EH2_RAM(4096, 68)
`EH2_RAM(2048, 68)
`EH2_RAM(1024, 68)
`EH2_RAM(512, 68)
`EH2_RAM(256, 68)
`EH2_RAM(128, 68)
`EH2_RAM(64, 68)
`EH2_RAM(8192, 71)
`EH2_RAM(4096, 71)
`EH2_RAM(2048, 71)
`EH2_RAM(1024, 71)
`EH2_RAM(512, 71)
`EH2_RAM(256, 71)
`EH2_RAM(128, 71)
`EH2_RAM(64, 71)
`EH2_RAM(4096, 42)
`EH2_RAM(2048, 42)
`EH2_RAM(1024, 42)
`EH2_RAM(512, 42)
`EH2_RAM(256, 42)
`EH2_RAM(128, 42)
`EH2_RAM(64, 42)
`EH2_RAM(4096, 22)
`EH2_RAM(2048, 22)
`EH2_RAM(1024, 22)
`EH2_RAM(512, 22)
`EH2_RAM(256, 22)
`EH2_RAM(128, 22)
`EH2_RAM(64, 22)
`EH2_RAM(1024, 26)
`EH2_RAM(4096, 26)
`EH2_RAM(2048, 26)
`EH2_RAM(512, 26)
`EH2_RAM(256, 26)
`EH2_RAM(128, 26)
`EH2_RAM(64, 26)
`EH2_RAM(32, 26)
`EH2_RAM(32, 22)
`EH2_RAM_BE(8192, 142)
`EH2_RAM_BE(4096, 142)
`EH2_RAM_BE(2048, 142)
`EH2_RAM_BE(1024, 142)
`EH2_RAM_BE(512, 142)
`EH2_RAM_BE(256, 142)
`EH2_RAM_BE(128, 142)
`EH2_RAM_BE(64, 142)
`EH2_RAM_BE(8192, 284)
`EH2_RAM_BE(4096, 284)
`EH2_RAM_BE(2048, 284)
`EH2_RAM_BE(1024, 284)
`EH2_RAM_BE(512, 284)
`EH2_RAM_BE(256, 284)
`EH2_RAM_BE(128, 284)
`EH2_RAM_BE(64, 284)
`EH2_RAM_BE(8192, 136)
`EH2_RAM_BE(4096, 136)
`EH2_RAM_BE(2048, 136)
`EH2_RAM_BE(1024, 136)
`EH2_RAM_BE(512, 136)
`EH2_RAM_BE(256, 136)
`EH2_RAM_BE(128, 136)
`EH2_RAM_BE(64, 136)
`EH2_RAM_BE(8192, 272)
`EH2_RAM_BE(4096, 272)
`EH2_RAM_BE(2048, 272)
`EH2_RAM_BE(1024, 272)
`EH2_RAM_BE(512, 272)
`EH2_RAM_BE(256, 272)
`EH2_RAM_BE(128, 272)
`EH2_RAM_BE(64, 272)
`EH2_RAM_BE(4096, 52)
`EH2_RAM_BE(2048, 52)
`EH2_RAM_BE(1024, 52)
`EH2_RAM_BE(512, 52)
`EH2_RAM_BE(256, 52)
`EH2_RAM_BE(128, 52)
`EH2_RAM_BE(64, 52)
`EH2_RAM_BE(4096, 104)
`EH2_RAM_BE(2048, 104)
`EH2_RAM_BE(1024, 104)
`EH2_RAM_BE(512, 104)
`EH2_RAM_BE(256, 104)
`EH2_RAM_BE(128, 104)
`EH2_RAM_BE(64, 104)
`EH2_RAM_BE(4096, 88)
`EH2_RAM_BE(2048, 88)
`EH2_RAM_BE(1024, 88)
`EH2_RAM_BE(512, 88)
`EH2_RAM_BE(256, 88)
`EH2_RAM_BE(128, 88)
`EH2_RAM_BE(64, 88)
`EH2_RAM_BE(4096, 44)
`EH2_RAM_BE(2048, 44)
`EH2_RAM_BE(1024, 44)
`EH2_RAM_BE(512, 44)
`EH2_RAM_BE(256, 44)
`EH2_RAM_BE(128, 44)
`EH2_RAM_BE(64, 44)

`undef EH2_RAM
`undef EH2_RAM_BE
`undef EH2_LOCAL_RAM_TEST_IO


