`timescale 1ns/1ps


module mod2 #(
    parameter IN_W = 19, // s(19, 15) signed
    parameter OUT_W = 3, // 1 for sign (bipolar quantizer), 2 for a 4 level (bipolar) quantizer
    parameter YY_FS = 16384 // fp_quantizer(QNS_level_matlab, IN_N, IN_R) this FS value is the Levels var for the QNS in matlab. It must be quantized to match 
    ) ( 
    input clk,
    input rstn,
    input en,
    input signed [IN_W-1:0] in, // (N,R) = s(19,15) signed
    output logic signed [OUT_W-1:0] out, // output  signed,
    output logic signed [IN_W-1:0] out_scaled

);
initial $sdf_annotate("../results/mod2.mapped.sdf");
logic signed [IN_W-1:0] inp, v_scaled; // x
logic signed [IN_W:0] yy; // yy
logic signed [IN_W:0] e, reg1, reg2; // e
logic signed [OUT_W-1:0] v; // yy

localparam V_SCALING = (IN_W - OUT_W - 1 - 1); // see comments below
always @(*) begin // 2 bit, bipolar quantizer
    if (en) begin
        yy = inp - (reg1 <<< 1) + reg2; 
        if (yy >= 0) begin
            if (yy >= YY_FS) v = 3'd3; 
            else v = 3'd1; // 3'd1
        end  // yy >= 0
        else begin // yy < 0
            if (-yy >= YY_FS) v = -3'd3;
            else v = -3'd1;
        end // yy < 0
        v_scaled = v <<< V_SCALING; // IN_W - OUT_W to scale "v" to max amplitude. -1 is so we dont count the sign bit in the shift
        e = yy - v_scaled;
    end
end

assign out = v;
assign out_scaled = v_scaled;

// floating pt lvl -> quantizer integer level
// 1.5 -> 3  
// 0.5 -> 1 
// multiplication by 2 seen above. that is bitshift left by 1.
// converting float pt level to quantizer integer level 
// this is referred to as the quantizer having a step of size 2 

// 19 - 3 = 16 for magnitude scaling.
// 16 - 1 = 15 because sign bit doesnt count for magnitude
// 15 - 1 = 14 because the floating pt quantizer level to integer quantizer level conversion
// already applied a left bit shift of 1

// fp_quantizer(1.5, 19, 15) == 3 * 2^14 = 49152 
// fp_quantizer(0.5, 19, 15) == 1 * 2^14 = 16384 

always @(posedge clk or negedge rstn) begin
    if (rstn == 0) begin
        reg2 <= 0; reg1<= 0; inp <= 0;
    end
    else begin
        inp <= in;
        reg2 <= reg1; 
        reg1 <= -e;
    end
end



endmodule
