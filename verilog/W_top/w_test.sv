`timescale 1us/10ps;

module w_test #(parameter N = 32, LMS_IN_W = 32, U1_IN_W = 32, OUT_W = 32, R_IN = 31, R_OUT = 31, R_SH = 30)
(
    input                               clock,
    input                               reset,
    input logic                         valid_lms_in,
    input logic signed [LMS_IN_W-1:0]   data_lms_in,
    input logic                         valid_u_in,
    input logic signed [U1_IN_W-1:0]    data_u_in,
    output logic signed [OUT_W-1:0]     data_out,
    output logic                        valid_out
);
    
    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);
    localparam SHIFT_VAL    = R_SH + (R_IN - R_OUT);

    logic signed [U1_IN_W-1:0] shift_reg_r [N-2:0];
    logic signed [U1_IN_W-1:0] shift_reg_n [N-2:0];

    logic signed [U1_IN_W-1*2 + 1:0] W [N-1:0];

    logic signed [U1_IN_W-1*2:0] sum;
    logic signed [OUT_W-1:0] final_sum;

    always_comb
    begin

        // OUTPUT
        sum       = ((data_u_in * W[0]) >>> SHIFT_VAL);
        for (int i = 0; i < N-1; i = i + 1)
        begin
            sum = sum + ((shift_reg_r[i] * W[i+1]) >>> SHIFT_VAL);
        end

        if (sum > OUT_W'(OUT_MAX))
        begin
            final_sum = OUT_W'(OUT_MAX);
        end
        else if (sum < OUT_W'(OUT_MIN))
        begin
            final_sum = OUT_W'(OUT_MIN);
        end
        else
        begin
            final_sum = sum;
        end

        if (valid_u_in) // move u into shift register
        begin
            shift_reg_n[0] = data_u_in;
            for (int i = 0; i < N-1; i = i + 1)
            begin
                shift_reg_n[i] = shift_reg_r[i-1];
            end
        end
        else
        begin
            shift_reg_n = shift_reg_r;
        end
    end

    always_comb
    begin // update W with lms inputs
        if (valid_lms_in)
        begin
            for (int i = 0; i < N; i = i + 1) begin
                W[i] = W[i] + data_lms_in[i];
            end
        end
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            for (int i = 0; i < N-1; i = i + 1)
            begin
                shift_reg_r[i]  <= '0;
            end
            data_out    <= '0;
            valid_out   <= 1'b0;
        end
        else
        begin
            shift_reg_r <= shift_reg_n;
            data_out    <= final_sum;
            valid_out   <= valid_u_in;
        end
    end

endmodule