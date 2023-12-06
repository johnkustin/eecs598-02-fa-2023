module W_top #(parameter W_W = 8, R_W = 6, N = 1008, OUT_W = 32, R_OUT = 28, LV0 = 0, LV1 = 1, LV2 = 2, LV3 = 3, LV4 = 4, LV5 = 5, LV6 = 6, LV7 = 7)
(
    input                           clock,
    input                           reset,
    input logic                     valid_data_in,
    input logic [1:0]               data_in,
    input logic                     valid_update_in,
    input logic [$clog2(N)-1:0]     update_idx,
    input logic [1:0]               update_data,
    output logic                    valid_out,
    output logic signed [OUT_W-1:0] data_out
);

    localparam SHIFT_VAL    = R_OUT - R_W; // TODO: Adjust this
    localparam LUT_SIZE     = 8;

    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);

    localparam logic signed [W_W-1:0] LUT [LUT_SIZE] = {LV0, LV1, LV2, LV3, LV4, LV5, LV6, LV7};

    logic [1:0] w0 [N];
    logic [1:0] shift_reg [N];
    logic signed [OUT_W + ($clog2(N))-1:0] data_out_int;
    logic signed [OUT_W-1:0] prod [N];
    logic [1:0] internal_valids;

    always_comb
    begin
        data_out_int = '0;
        for (int i = 0; i < N; i = i + 1)
        begin
            data_out_int = data_out_int + prod[i];
        end
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            for (int i = 0; i < N; i = i + 1)
            begin
                w0[i]           <= '0;
                prod[i]         <= '0;
                shift_reg[i]    <= '0;
            end
            internal_valids <= '0;
            data_out <= '0;
            valid_out <= 1'b0;
        end
        else
        begin
            if (valid_update_in)
            begin
                w0[update_idx] <= update_data;
            end

            if (valid_data_in)
            begin
                internal_valids[0] <= 1'b1;
                shift_reg[0] <= data_in;
                for (int i = 1; i < N; i = i + 1)
                begin
                    shift_reg[i] <= shift_reg[i-1];
                end
            end
            else
            begin
                internal_valids[0] <= 1'b0;
            end

            for (int i = 0; i < N; i = i + 1)
            begin
                prod[i] <= (LUT[{(shift_reg[i][0] ^ w0[i][0]), shift_reg[i][1], w0[i][1]}]) <<< SHIFT_VAL;
            end

            if (data_out_int > OUT_MAX)
            begin
                data_out <= OUT_MAX;
            end
            else if (data_out_int < OUT_MIN)
            begin
                data_out <= OUT_MIN;
            end
            else
            begin
                data_out <= data_out_int;
            end

            internal_valids[1]  <= internal_valids[0];
            valid_out           <= internal_valids[1];
        end
    end
endmodule