module Shat # (parameter N = 32, IN_W = 32, OUT_W = 32, SH_W = 32, R_IN = 31, R_OUT = 31, R_SH = 30)
(
    input                           clock,
    input                           reset,
    input logic                     valid_in,
    input logic signed [IN_W-1:0]   data_in,
    output logic signed [OUT_W-1:0] data_out,
    output logic                    valid_out
);  

    parameter logic signed [SH_W-1:0] sh [0:N-1] = {32'hffec56d6, 32'hff645a1d, 32'h226809d, 32'hef295e9e,
                                                    32'he52a3055, 32'hbb439581, 32'hfeb851ec, 32'h351eb852,
                                                    32'hd35a86, 32'h10b0f28, 32'hff089a02, 32'hbac711, 
                                                    32'hff80346e, 32'h4816f0, 32'hffe76c8b, 32'hfff14120,
                                                    32'h2f837b, 32'hffb7e910, 32'h5a1cac, 32'hff98c7e3,
                                                    32'h6dc5d6, 32'hff923a2a, 32'h6c2268, 32'hff9a6b51,
                                                    32'h5bc01a, 32'hffafb7e9, 32'h432ca5, 32'hffc9eecc,
                                                    32'h28f5c3, 32'hffe28241, 32'h1205bc, 32'hffeab368};

    
    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);
    localparam SHIFT_VAL    = R_SH + (R_IN - R_OUT);

    logic signed [IN_W-1:0]     shift_reg_r [N-2:0];
    logic signed [IN_W-1:0]     shift_reg_n [N-2:0];

    logic signed [IN_W*2:0]     sum_n;

    logic signed [OUT_W-1:0]    final_sum_n;

    always_comb
    begin
        shift_reg_n = shift_reg_r;
        sum_n = '0;
        final_sum_n = '0;
        // OUTPUT
        if (valid_in)
        begin
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
        end

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
            data_out    <= final_sum_n;
            valid_out   <= valid_in;
        end
    end
endmodule