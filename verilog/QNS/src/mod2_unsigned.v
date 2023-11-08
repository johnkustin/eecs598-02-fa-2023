`timescale 1ns/1ps


module mod2 #(
    parameter INPUT_WIDTH = 16
) (
    input clk,
    input rstn,
    input en,
    input [INPUT_WIDTH-1:0] in, // (N,R) = (16,15)
    output wire out // output 


);


reg delta_reg;
reg [INPUT_WIDTH+2-1:0] sigma1_reg;
wire signed [INPUT_WIDTH+2-1:0] delta_adder1_out, sigma1_out, delta;
wire signed [INPUT_WIDTH+2+2-1:0] delta_adder2_out, sigma2_out, delta2;
reg signed [INPUT_WIDTH+2+2-1:0] sigma2_reg;


always @(posedge clk or negedge rstn) begin
    if (rstn==0) begin 
        delta_reg <= 0;
        sigma1_reg <= 1'b1 << (INPUT_WIDTH+2-1-1);
        sigma2_reg <= 1'b1 << (INPUT_WIDTH+2+2-1-1);
    end
    else begin 
        delta_reg <= out;
        sigma1_reg <= sigma1_out;
        sigma2_reg <= sigma2_out;
    end
end

assign out = sigma2_out[INPUT_WIDTH+3]; // MSB is output of DSM
assign delta = (delta_reg==1'b1) ? {2'b11, {INPUT_WIDTH{1'b0}}} : {2'b00, {INPUT_WIDTH{1'b0}}}; // when delta_reg==1, delta is a negative number which is 1 more in magnitude than the FS of any input


assign sigma1_out = delta_adder1_out + sigma1_reg;
assign delta_adder1_out = delta + {2'b00, in};

assign delta2 = (delta << 2); // gain here so that delta2 can cancel the FS of sigma1_out
assign delta_adder2_out = delta2 + {2'b00, sigma1_out};//{2'b00, in};
assign sigma2_out = delta_adder2_out + sigma2_reg;


endmodule

