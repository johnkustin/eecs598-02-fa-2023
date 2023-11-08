module test(
	  input logic clk
	, input logic rst
	, input logic [63:0] a
	, input logic [63:0] b
	, output logic [63:0] c
	, output logic [15:0] mo
);
	logic [63:0] n_c;
	assign n_c = a+b;
	always_ff @(posedge clk) begin
		if(rst)
			c <= '0;
		else
			c <= n_c;
	end

	SRAM_myname m0(
		  .A(a[6:0])
		, .CE(a[7])
		, .WEB(a[8])
		, .OEB(b[0])
		, .CSB(b[63])
		, .I(b[31:16])
		, .O(mo)
	);

endmodule
