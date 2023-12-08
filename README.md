# eecs598-02-fa-2023

Low-Delay Low-Cost Sigma-Delta Adaptive Controller for Active Noise Control RTL

To run a simulation of the entire design, cd into verilog/TOP and run "make"

Each design file is located under verilog/"DESIGN NAME"/src

All necessary files are the following:

verilog/LMS/src/LMS.sv
verilog/LPD/src/LPD.sv
verilog/QNS/src/qns.sv
verilog/Shat/src/Shat.sv
verilog/TOP/src/sys_defs.svh
verilog/TOP/src/top.sv
verilog/W/src/W.sv
verilog/W_top/W_top.sv

Unit testing for individual modules can be run by cd into that directory, and running "make"

Testbenches are all located in the corresponding verilog folders, under "test" subdirectory

Analysis of results, as well as input generation was done in the "python" folder, which is has the same substructure as the verilog/ folder

One example flow would be:

cd verilog/TOP
make
cd ../../python/TOP
python3 graphEp.py

Then, the graphs for the error will be located in e.png under the data/ subdirectory
The design is currently in 32-bit mode
