`timescale 1ns/1ps

module testbench;
    localparam N        = 32;
    localparam K        = 32;
    localparam INPUT_N  = 2097152;
    localparam IN_W     = 32;
    localparam OUT_W    = 32;
    localparam COEFF_W  = 32;
    localparam R_IN     = 31;
    localparam R_OUT    = 31;
    localparam R_COEFF     = 31;

    logic                       clock;
    logic                       reset;
    logic                       valid_in;
    logic signed [IN_W-1:0]     data_in;
    logic signed [OUT_W-1:0]    data_out;
    logic                       valid_out;
    logic                       weight_en;

    logic signed [IN_W-1:0]     input_data [INPUT_N-1:0]; 
    integer                     clock_cnt;
    integer                     data_cnt;
    integer                     out_cnt;
    integer                     out_file;

    logic signed [COEFF_W-1:0] sh [0:N-1];

    initial
    begin
    	$dumpfile("testbench.vcd");
        $dumpvars(0);	
        $sdf_annotate("results/Shat.mapped.sdf", f0); // this line will cause some warnings when you run the *NON SYNTHESIZED* version of the hardware 
    end
    
    fir_filter #(.N(N), .IN_W(IN_W), .OUT_W(OUT_W), .COEFF_W(COEFF_W), .R_IN(R_IN), .R_OUT(R_OUT), .R_COEFF(R_COEFF)) f0
    (
        .clock              (clock),
        .reset              (reset),
        .valid_in           (valid_in),
        .weight_load_en     (weight_en),
        .data_in            (data_in),
        .weight_in          (sh),
        .data_out           (data_out),
        .valid_out          (valid_out)    
    );

    always
    begin
        #5
        clock = ~clock;
    end

    initial
    begin
        $readmemh("data/xnoise.txt", input_data);
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            clock_cnt   <= 0;
            data_cnt    <= 0;
            valid_in    <= 1'b0;
            data_in     <= '0;
        end
        else
        begin
            clock_cnt <= clock_cnt + 1;

            if (data_cnt == INPUT_N)
            begin
                valid_in    <= 1'b1;
                data_in     <= input_data[0];
                data_cnt    <= 0;
                weight_en   <= '1;
                // b = firpm(31, [0 18e3/(44.1e3/2) 20e3/(44.1e3/2)  1], [1 1 0 0])
                sh          <= {32'hFE521EDD,    32'h02146B21,    32'hFEEDA628,    32'h01ACB451,
                                32'hFF9F6C98,    32'hFFC57CE0,    32'h01F9EEC5,    32'hFCCF7C26,
                                32'h04AA0387,    32'hFACECD4D,    32'h04FEF1DC,    32'hFCDA696D,
                                32'hFF735FB3,    32'h07804274,    32'hEA8DFBDD,    32'h4F89F36F,
                                32'h4F89F36F,    32'hEA8DFBDD,    32'h07804274,    32'hFF735FB3,
                                32'hFCDA696D,    32'h04FEF1DC,    32'hFACECD4D,    32'h04AA0387,
                                32'hFCCF7C26,    32'h01F9EEC5,    32'hFFC57CE0,    32'hFF9F6C98,
                                32'h01ACB451,    32'hFEEDA628,    32'h02146B21,    32'hFE521EDD};
            end
            else if (data_cnt == 2*INPUT_N)
            begin
                valid_in    <= 1'b0;
                data_in     <= '0;
            end
            else
            begin
                weight_en   <= '0;
                if (clock_cnt % K == 0)
                begin
                    valid_in    <= 1'b1;
                    data_in     <= input_data[data_cnt];
                    data_cnt    <= data_cnt + 1;
                end
                else
                begin
                    valid_in    <= 1'b0;
                    data_in     <= '0;
                end
            end
        end
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            out_cnt <= 0;
        end
        if (valid_out)
        begin
            out_cnt <= out_cnt + 1;
            $fdisplay(out_file, "%h", data_out);
        end
        if (out_cnt == 2*INPUT_N)
        begin
            $fclose(out_file);
            $finish;
        end
    end

    initial
    begin
        out_file = $fopen("./hw_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        weight_en <= '1;
        sh = {
32'h1792F427,32'h01ABCEF5,32'h01BD683E,32'h01A3A813,
32'h016F3058,32'h01AEAFF7,32'h01CEFF1B,32'h019F5E01,
32'h017D28C2,32'h01B68311,32'h01C021FB,32'h019673FE,
32'h01865B4F,32'h01B7EEFE,32'h01C0AB74,32'h01909025,
32'h01909025,32'h01C0AB74,32'h01B7EEFE,32'h01865B4F,
32'h019673FE,32'h01C021FB,32'h01B68311,32'h017D28C2,
32'h019F5E01,32'h01CEFF1B,32'h01AEAFF7,32'h016F3058,
32'h01A3A813,32'h01BD683E,32'h01ABCEF5,32'h1792F427
};
        @(negedge clock);
        weight_en <= '0;
    end

endmodule
