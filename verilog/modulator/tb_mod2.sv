`timescale 1ns/1fs

module test_mod2;

parameter WIDTH = 16;

parameter OS_DATALEN = 1048576; // oversampled data length
parameter OSR = 64; // for use in decimation filter

reg clk, rstn, en;
reg [WIDTH - 1 : 0] inArr[OS_DATALEN - 1 : 0];
wire signed out;
wire signed [25:0] cic_out;
wire ce_out;

reg signed [WIDTH - 1 : 0] in;
integer i;
integer f;

initial begin
    $dumpfile("test_mod2.vcd");
    $dumpvars(0);
    $readmemh("./WAVEFRONT_DSM_2nd_DT_QuantizedHexStimulus_Ampl_FS_32767_OSR_64_FS_6144000_NFFT_1048576_FIN_5935.546875.txt", inArr);     
end

mod2 #(
    .INPUT_WIDTH(WIDTH)
    ) 
    mod(
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .in(in + 16'd32768), // give the data a dc offset
    .out(out)
);

cic_decimate_64 cic(
    .clk(clk),
    .clk_enable(1'b1),
    .rstn(rstn),
    .filter_in({1'b0, out}),
    .filter_out(cic_out),
    .ce_out(ce_out)
);

always begin
    #81.380208 clk <= 1'b1; // full period for 6.144MHz is approx 162.760417ns
    #81.380208 clk <= 1'b0;
end

initial begin
    f = $fopen("test_dsm2_WAVEFRONT_DSM_2nd_DT_QuantizedHexStimulus_Ampl_FS_32767_OSR_64_FS_6144000_NFFT_1048576_FIN_5935.546875.txt", "w");
    $fwrite(f,"u\t del1out del2out sig1    sig2 out\n");    
    
    clk <= 0; rstn <= 1; en <= 0;
    in <= 0;
    repeat (5) @(posedge clk) rstn <= 0;

    @(posedge clk) begin
        en <= 1;
        rstn <= 1;
    end
    // $fmonitor(f, "%d %d %d %d %d %d", mod.in, mod.delta_adder1_out, mod.delta_adder2_out, mod.sigma1_out, mod.sigma2_out, mod.out);
    for(i = 0; i < OS_DATALEN - 1; i = i + 1) begin
        @(posedge clk) in <= inArr[i];
        @(negedge clk) $fwrite(f, "%d\t%d\t%d\t%d\t%d\t%d\n", mod.in, mod.delta_adder1_out, mod.delta_adder2_out, mod.sigma1_out, mod.sigma2_out, mod.out);
    end
    in <= 0;

    
    
    repeat (10) @(posedge clk);
    $display("done");
    // $fclose(f); 
    $finish;
end



endmodule