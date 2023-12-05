`timescale 1ns/1ps
`define CLK_TON 354.308

module testbench;
    
    localparam BW_P = 32;
    localparam INPUT_N  = 1024;
    localparam N        = 32;
    localparam K        = 32; // K is oversampling ratio
    localparam IN_W     = 32;
    localparam OUT_W    = 32;
    localparam COEFF_W  = 32;
    localparam R_IN     = 31;
    localparam R_OUT    = 31;
    localparam R_COEFF  = 31;
    localparam QNS_BW   = 3;


    logic clk, rst_n;
    logic valid_out, valid_in;

    // inputs
    logic [BW_P-1:0] upg [0:INPUT_N-1]; // up golden
    logic [BW_P-1:0] upg_in;


    // outputs
    logic signed [OUT_W-1:0] u_out, e_out, d_out, u1_out, eh_out, dh_out, y_out;
    logic signed [QNS_BW-1:0] u0_out, y0_out, e0_out, w0_out;

    integer out_cnt, data_cnt, clk_cnt;
    integer out_file;


    initial 
    begin
        $dumpfile("testbench.vcd");
        $dumpvars(0);	
        $sdf_annotate("results/Shat.mapped.sdf", sh0); // this line will cause some warnings when you run the *NON SYNTHESIZED* version of the hardware 
        
        $readmemh("data/upg.txt",upg);
        $readmemh("data/epg.txt",epg);
        out_file = $fopen("top_out.txt");
    	
    end

////////////
// Module here
////////////

top xtop;


always begin
    #`CLK_TON clk <= ~clk;
end

always @(negedge clk)
    begin
        if (rst_n == 0)
        begin
            clk_cnt     <= '0;
            data_cnt    <= '0;
            valid_in    <= 1'b0;
            upg_in      <= '0;
        end
        else
        begin
            clk_cnt <= clk_cnt + 1;

            if (data_cnt == INPUT_N)
            begin
                valid_in    <= 1'b0;
                upg_in     <= '0;
            end
            else
            begin
                if (clk_cnt % K == 0) 
                begin
                    valid_in    <= 1'b1;
                    upg_in     <= upg[data_cnt];
                    data_cnt    <= data_cnt + 1;
                end
                else
                begin
                    valid_in    <= 1'b0;
                    upg_in     <= '0;
                end
            end
        end
    end

    initial 
    begin
        clk <= 0; rst_n <= 1;
        @(negedge clk)
            rst_n <= 0;
        @(negedge clk);
        @(negedge clk)
            rst_n <= 1;

        $finish;
        $fclose(out_file);
    end

always @(negedge clk)
    begin
        if (rst_n==0)
        begin
            out_cnt <= 0;
        end
        if (valid_out)
        begin
            out_cnt <= out_cnt + 1;
            $fdisplay(out_file, "%d", u_out, e_out, d_out);
        end
        if (out_cnt == INPUT_N)
        begin
            $fclose(out_file);
            $finish;
        end
    end

endmodule