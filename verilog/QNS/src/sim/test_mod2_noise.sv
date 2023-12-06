`timescale 1ns/1ps
`define CLK_HALFPERIOD_ns_1411200HZ 354.308


module test_mod2_noise;

// string dataPath = "./";
string fileName = "rand_7283723_n19r15_OSR_32_fs_44p1k_96000_pts.txt";


parameter IN_W = 19;
parameter OUT_W = 3;
parameter OS_DATALEN = 96000; // oversampled data length    


parameter OSR = 32; // for use in decimation filter

reg clk, rstn, en;
reg [IN_W - 1 : 0] inArr[OS_DATALEN - 1 : 0]; 
wire signed [OUT_W-1:0] out;
wire signed [IN_W-1:0] out_scaled;
wire signed [50:0] cic_out;
wire ce_out;

reg signed [IN_W - 1 : 0] in;
integer i;
integer f;

initial begin
    $dumpfile("test_mod2_noise.vcd");
    $dumpvars(0);
    $readmemh(fileName, inArr);     
    $sdf_annotate("../results/mod2.mapped.sdf", mod);

end

mod2 #(
    .IN_W(IN_W),
    .OUT_W(OUT_W),
    .YY_FS(16384)
    ) 
    mod(
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .in(in), 
    .out(out),
    .out_scaled(out_scaled)
);

H_cic_dec_64_N3R0_signed cic( // i need to change this to match the 64 tap fir filter used in matlab
    .clk(clk),
    .clk_enable(1'b1),
    .rstn(rstn),
    .filter_in(out),
    .filter_out(cic_out),
    .ce_out(ce_out)
);

always begin
    #(`CLK_HALFPERIOD_ns_1411200HZ) clk <= 1'b1; 
    #(`CLK_HALFPERIOD_ns_1411200HZ) clk <= 1'b0;
end

initial begin
    
    f = $fopen({"test_mod2_",fileName}, "w");
    clk <= 0; rstn <= 1; en <= 0;
    in <= 0;
    repeat (5) @(posedge clk) rstn <= 0;

    @(posedge clk) begin
        en <= 1;
        rstn <= 1;
        $fmonitor(f, "%d %d %d", in, out, cic_out);
    end
    
    
    for(i = 0; i < OS_DATALEN - 1; i = i + 1) begin
        @(negedge clk) in <= inArr[i];
    end
    @(negedge clk) in <= 0;

    
    $display("done");
    $fclose(f); 
    $finish;
end



endmodule
