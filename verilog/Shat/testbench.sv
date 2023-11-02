module testbench;
    localparam N        = 32;
    localparam IN_W     = 16;
    localparam OUT_W    = 16;
    localparam SH_W     = 16;
    localparam R_IN     = 12;
    localparam R_OUT    = 12;
    localparam R_SH     = 12;

    logic                       clock;
    logic                       reset;
    logic                       valid_in;
    logic signed [IN_W-1:0]     data_in;
    logic signed [OUT_W-1:0]    data_out;
    logic                       valid_out;

    logic signed [SH_W-1:0]     input_data [N-1:0]; 
    integer                     cnt;

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
        $readmemh("inputVals.mem", input_data);
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            cnt         <= 0;
            valid_in    <= 1'b0;
            data_in     <= '0;
        end
        else
        begin
            if (cnt == N)
            begin
                valid_in    <= 1'b0;
                data_in     <= '0;
            end
            else
            begin
                valid_in    <= 1'b1;
                data_in     <= input_data[cnt];
                cnt         <= cnt + 1;
            end
        end
    end

    always @(negedge clock)
    begin
        if (valid_out)
        begin
            $display("%d", data_out);
            $finish;
        end
    end

    initial
    begin
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end

endmodule