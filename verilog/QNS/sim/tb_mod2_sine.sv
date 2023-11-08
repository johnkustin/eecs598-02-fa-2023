`timescale 1ns/1fs

module test_mod2;

// string dataPath = "./";
string fileName = "sine_n19r15_fin_1k_0p5VFS_OSR_64_fs_44p1k.txt";


parameter IN_W = 19;
parameter OUT_W = 3;
// CHANGE OS_DATALEN_RAND TO OS_DATALEN_SIN ON LINE 20 & 78 IF YOU WANT SINEWAVE DATA
parameter OS_DATALEN_SIN = 192000; // oversampled data length    


parameter OSR = 64; // for use in decimation filter

reg clk, rstn, en;
reg [IN_W - 1 : 0] inArr[OS_DATALEN_SIN - 1 : 0]; 
wire signed [OUT_W-1:0] out;
wire signed [IN_W-1:0] out_scaled;
wire signed [50:0] cic_out;
wire ce_out;

reg signed [IN_W - 1 : 0] in;
integer i;
integer f;

initial begin
    $dumpfile("test_mod2.vcd");
    $dumpvars(0);
    $readmemh(fileName, inArr);     
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
    #81.380208 clk <= 1'b1; // full period for 6.144MHz is approx 162.760417ns
    #81.380208 clk <= 1'b0;
end

initial begin
    // f = $fopen("outputs/test_dsm2_WAVEFRONT_DSM_2nd_DT_QuantizedHexStimulus_Ampl_FS_32767_OSR_64_FS_6144000_NFFT_1048576_FIN_5935.546875.txt", "w");
    // $fwrite(f,"\t u\t\t y\t e\t k1\t k2\t e_delay_1\t e_delay_2\t v\n");    
    
    f = $fopen({"test_mod2_",fileName}, "w");
    clk <= 0; rstn <= 1; en <= 0;
    in <= 0;
    repeat (5) @(posedge clk) rstn <= 0;

    @(posedge clk) begin
        en <= 1;
        rstn <= 1;
    end
    // $fmonitor(f, "%d %d %d %d %d %d %d %d", mod.u, mod.y, mod.e, mod.k1, mod.k2, mod.e_delay_1, mod.e_delay_2, mod.v);
    $fmonitor(f, "%d %d %d", in, out, cic_out);
    for(i = 0; i < OS_DATALEN_SIN - 1; i = i + 1) begin
        @(posedge clk) in <= inArr[i];
    end
    in <= 0;

    repeat (10) @(posedge clk);
    $display("done");
    // $fclose(f); 
    $finish;
end



endmodule
