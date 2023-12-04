module testbench;
    localparam IN_W = 3;
    localparam R_IN = 0;
    localparam AAF_W = 32;
    localparam R_AAF = 36;
    localparam OUT_W = 32;
    localparam R_OUT = 31;
    localparam NUM_INPUTS = 83210;
    localparam DONE_DATA = 2488;

    logic clock;
    logic reset;
    logic valid_in;
    logic signed [IN_W-1:0] data_in;
    logic valid_out;
    logic signed [OUT_W-1:0] data_out;

    logic signed [IN_W-1:0] u0 [NUM_INPUTS-1:0];

    integer clock_cnt;
    integer data_cnt;
    integer out_file;

    LPD #(.IN_W(IN_W), .R_IN(R_IN), .AAF_W(AAF_W), .R_AAF(R_AAF), .OUT_W(OUT_W), .R_OUT(R_OUT))
    ldp0
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (valid_in),
        .data_in    (data_in),
        .valid_out  (valid_out),
        .data_out   (data_out)
    );

    initial
    begin
        $readmemh("data/u0.mem", u0);
    end

    always
    begin
        #5
        clock = ~clock;
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            valid_in <= 1'b0;
            clock_cnt <= 0;
            data_in <= '0;
        end
        else
        begin
            if (clock_cnt == NUM_INPUTS)
            begin
                valid_in <= 1'b0;
                data_in <= '0;
            end
            else
            begin
                valid_in <= 1'b1;
                clock_cnt <= clock_cnt + 1;
                data_in <= u0[clock_cnt];
            end
        end
    end


    always @(negedge clock)
    begin
        if (reset)
        begin
            data_cnt <= '0;
        end
        else
        begin
            if (data_cnt == DONE_DATA)
            begin
                $fclose(out_file);
                $finish;
            end
            if (valid_out)
            begin
                $fdisplay(out_file, "%d", data_out);
                data_cnt <= data_cnt + 1;
            end
        end
    end
 
    initial
    begin
        out_file = $fopen("../../python/LPD/data/hw_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end
endmodule