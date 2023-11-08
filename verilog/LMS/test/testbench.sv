module testbench;
    localparam N        = 32;
    localparam K        = 32;
    localparam MU       = 102;
    localparam OFFSET   = 2621;
    localparam IN_W     = 20;
    localparam OUT_W    = 20;
    localparam MU_W     = 8;
    localparam R_IN     = 18;
    localparam R_OUT    = 18;
    localparam R_MU     = 9;
    localparam ADD_STEP = 4;
    localparam ADJ_LUT_IN_W = 10;
    localparam ADJ_LUT_OUT_W = 12;
    localparam R_ADJ_LUT_IN = 10;
    localparam R_ADJ_LUT_OUT = 0;


    logic                       clock;
    logic                       reset;
    logic                       valid_u_in;
    logic signed [IN_W-1:0]     data_u_in;
    logic                       valid_e_in;
    logic signed [IN_W-1:0]     data_e_in;
    logic [N-1:0] [OUT_W-1:0]   data_out; // Weird error with packed signed 2D arrays, easier to cast after-the-fact
    logic                       valid_out;

    logic signed [IN_W-1:0]     u_in [N-1:0];
    logic signed [IN_W-1:0]     e_in [N-1:0];

    integer clock_cnt;
    integer data_cnt;
    integer out_file;
    integer out_cnt;

    LMS # (.N(N), .IN_W(IN_W), .OUT_W(OUT_W), .MU_W(MU_W), .ADJ_LUT_IN_W(ADJ_LUT_IN_W), .ADJ_LUT_OUT_W(ADJ_LUT_OUT_W), .R_IN(R_IN), .R_OUT(R_OUT), .R_MU(R_MU), 
            .R_ADJ_LUT_IN(R_ADJ_LUT_IN), .R_ADJ_LUT_OUT(R_ADJ_LUT_OUT), .MU(MU), .OFFSET(OFFSET), .ADD_STEP(ADD_STEP)) lms0
    (
        .clock      (clock),
        .reset      (reset),
        .valid_u_in (valid_u_in),
        .data_u_in  (data_u_in),
        .valid_e_in (valid_e_in),
        .data_e_in  (data_e_in),
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
        $readmemh("data/uVals.mem", u_in);
        $readmemh("data/eVals.mem", e_in);
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            clock_cnt   <= 0;
            data_cnt    <= 0;
            valid_e_in  <= 1'b0;
            valid_u_in  <= 1'b0;
            data_e_in   <= '0;
            data_u_in   <= '0;
        end
        else
        begin
            clock_cnt <= clock_cnt + 1;
            if (data_cnt == N)
            begin
                valid_e_in  <= 1'b0;
                valid_u_in  <= 1'b0;
                data_u_in   <= '0;
                data_e_in   <= '0;
            end
            else
            begin
                if (clock_cnt % K == 0)
                begin
                    data_cnt    <= data_cnt + 1;
                    valid_e_in  <= 1'b1;
                    data_e_in   <= e_in[data_cnt];

                    valid_u_in  <= 1'b1;
                    data_u_in   <= u_in[data_cnt];
                end
                else
                begin
                    valid_e_in  <= 1'b0;
                    valid_u_in  <= 1'b0;
                    
                    data_e_in   <= '0;
                    data_u_in   <= '0;
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
        else
        begin
            if (valid_out)
            begin
                out_cnt <= out_cnt + 1;
                $fdisplay(out_file, "\n\nITER NUM %d", out_cnt);
                for (int i = 0; i < N; i = i + 1)
                begin
                    $fdisplay(out_file, "%d", $signed(data_out[i]));
                end
            end
            if (out_cnt == N)
            begin
                $fclose(out_file);
                $finish;
            end
        end
    end

    initial
    begin
        out_file = $fopen("../../python/LMS/data/hw_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end
endmodule