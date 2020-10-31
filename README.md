# EH2 SweRV RISC-V Core in verilog

This repository contains the SweRV EH2 Core converted in verilog using SV2V Parser available here: https://github.com/merledu/Pyverilog-sv2v

The original SweRV core is available here: https://github.com/chipsalliance/Cores-SweRV-EH2

SV2V parser has successfully converted complete SweRV-eh2 core from systemverilog to verilog using verilog parser. Although syntax of each file is checked through xilinx, and there is no syntax problem but I request moderator to please assign someone from verification team to verify this core.

Also I passed these converted files through Pyverilog parser to get state machine diagrams and RTL schematic, but I couldn't get desired results because the sizes of IOs in few modules are declared via macros. Pyverilog is unable to decode it. It only works with those IOs which are hard coded with fixed decimal sizes.

Some input is needed in that regard as well.
