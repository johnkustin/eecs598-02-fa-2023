/*********************************************************************
*  saed_mc : SRAM_128_12 Verilog description                       *
*  ---------------------------------------------------------------   *
*  Filename      : /home/rsomvan/VSLI_598/eecs598-02-fa-2023/verilog/LMS/memory/mc_work/SRAM_128_12.v                         *
*  SRAM name     : SRAM_128_12                                       *
*  Word width    : 12    bits                                        *
*  Word number   : 128                                               *
*  Adress width  : 7     bits                                        *
*  ---------------------------------------------------------------   *
*  Creation date : Wed December 06 2023                              *
*********************************************************************/

`define numAddr 7
`define numWords 128
`define wordLength 12


module SRAM_128_12 (A,CE,WEB,OEB,CSB,I,O);

input 				CE;
input 				WEB;
input 				OEB;
input 				CSB;

input 	[6:0] 		A;
input 	[11:0] 	I;
output 	[11:0] 	O;

reg    	[11:0]   	memory[127:0];
reg  	[11:0]	data_out1;
reg 	[11:0] 	O;

wire 				RE;
wire 				WE;


and u1 (RE, ~CSB,  WEB);
and u2 (WE, ~CSB, ~WEB);


always @ (posedge CE) 
	if (RE)
		data_out1 = memory[A];
	else 
	   if (WE)
		memory[A] = I;
		

always @ (data_out1 or OEB)
	if (!OEB) 
		O = data_out1;
	else
		O =  12'bz;

endmodule