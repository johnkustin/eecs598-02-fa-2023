module Shat # (parameter N = 32, IN_W = 32, OUT_W = 32, SH_W = 32, R_IN = 31, R_OUT = 31, R_SH = 30)
(
    input                           clock,
    input                           reset,
    input logic                     valid_in,
    input logic signed [IN_W-1:0]   data_in,
    output logic signed [OUT_W-1:0] data_out,
    output logic                    valid_out
);
    
    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);
    localparam SHIFT_VAL    = R_SH + (R_IN - R_OUT);

    logic signed [SH_W-1:0]     sh [N-1:0];

    logic signed [IN_W-1:0]     shift_reg_n [N-2:0]; // need N-1 saved values
    logic signed [IN_W-1:0]     shift_reg_r [N-2:0];

    logic signed [IN_W*2:0]     sum_n;

    logic signed [OUT_W-1:0]    final_sum_n;

    initial 
    begin
        $readmemh("data/shVals.mem", sh);
    end

    always_comb
    begin
        shift_reg_n = shift_reg_r;

        // OUTPUT
        sum_n       = ((data_in * sh[0]) >>> SHIFT_VAL);
        for (int i = 0; i < N-1; i = i + 1)
        begin
            sum_n = sum_n + ((shift_reg_r[i] * sh[i+1]) >>> SHIFT_VAL);
        end

        if (sum_n > OUT_W'(OUT_MAX))
        begin
            final_sum_n = OUT_W'(OUT_MAX);
        end
        else if (sum_n < OUT_W'(OUT_MIN))
        begin
            final_sum_n = OUT_W'(OUT_MIN);
        end
        else
        begin
            final_sum_n = sum_n;
        end

        //INPUT
        if (valid_in)
        begin
            shift_reg_n[0] = data_in;
            for (int i = 1; i < N-1; i = i + 1)
            begin
                shift_reg_n[i] = shift_reg_r[i-1];
            end
        end
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            for (int i = 0; i < N; i = i + 1)
            begin
                shift_reg_r[i]  <= '0;
            end
            data_out    <= '0;
            valid_out   <= 1'b0;
        end
        else
        begin
            shift_reg_r <= shift_reg_n;
            data_out    <= final_sum_n;
            valid_out   <= valid_in;
        end
    end
endmodule