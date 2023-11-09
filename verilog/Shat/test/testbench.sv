module testbench;
    localparam N        = 32;
    localparam K        = 32;
    localparam INPUT_N  = 3000;
    localparam IN_W     = 32;
    localparam OUT_W    = 32;
    localparam SH_W     = 32;
    localparam R_IN     = 31;
    localparam R_OUT    = 31;
    localparam R_SH     = 30;

    logic                       clock;
    logic                       reset;
    logic                       valid_in;
    logic signed [IN_W-1:0]     data_in;
    logic signed [OUT_W-1:0]    data_out;
    logic                       valid_out;

    logic signed [IN_W-1:0]     input_data [INPUT_N-1:0]; 
    integer                     clock_cnt;
    integer                     data_cnt;
    integer                     out_cnt;
    integer                     out_file;

    Shat #(.N(N), .IN_W(IN_W), .OUT_W(OUT_W), .SH_W(SH_W), .R_IN(R_IN), .R_OUT(R_OUT), .R_SH(R_SH)) sh0
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (valid_in),
        .data_in    (data_in),
        .data_out   (data_out),
        .valid_out  (valid_out)    
    );

    always
    begin
        #5
        clock = ~clock;
    end

    initial
    begin
        $readmemh("data/inputVals.mem", input_data);
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
                valid_in    <= 1'b0;
                data_in     <= '0;
            end
            else
            begin
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
            $fdisplay(out_file, "%d", data_out);
        end
        if (out_cnt == INPUT_N)
        begin
            $fclose(out_file);
            $finish;
        end
    end

    initial
    begin
        out_file = $fopen("../../python/Shat/data/hw_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end

endmodule