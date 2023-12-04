`include "src/AAF.svh"

module LPD #(parameter IN_W = 3, R_IN = 0, AAF_W = 32, R_AAF = 36, OUT_W = 32, R_OUT = 31)
(
    input                           clock,
    input                           reset,
    input logic                     valid_in,
    input logic signed [IN_W-1:0]   data_in,
    output logic                    valid_out,
    output logic signed [OUT_W-1:0] data_out
);

    localparam NUM_CHAINS   = 56;
    localparam NUM_ACC      = 112;
    localparam ACC_W        = AAF_W + $clog2(CHAIN_W); // could potentially go more (or less)
    localparam CHAIN_W      = 32;
    localparam SHIFT_VAL    = (R_AAF + R_IN) - R_OUT;

    typedef struct {
        logic signed [ACC_W-1:0]    data;
        logic                       valid;
    } acc_t;

    acc_t acc [NUM_ACC-1:0];
    logic signed [ACC_W-1:0] prod [NUM_ACC];
    logic [$clog2(CHAIN_W)-1:0] chain_cnt;


    always_comb
    begin
        for (int i = 0; i < NUM_CHAINS; i = i+1)
        begin
            prod[i] = (data_in * AAF[i][chain_cnt]) >>> SHIFT_VAL;
        end
        for (int i = NUM_CHAINS; i < NUM_ACC; i = i + 1)
        begin
            if (i == NUM_ACC-1 && chain_cnt == CHAIN_W-1)
            begin
                prod[i] = '0;
            end
            else
            begin
                if (chain_cnt == CHAIN_W-1)
                begin
                    prod[i] = (data_in * AAF[NUM_ACC-2-i][CHAIN_W-1]) >>> SHIFT_VAL;
                end
                else
                begin
                    prod[i] = (data_in * AAF[NUM_ACC-1-i][CHAIN_W-2-chain_cnt]) >>> SHIFT_VAL;
                end
            end
        end
    end

    always_ff @(posedge clock)
    begin
        if (reset)
        begin
            chain_cnt   <= '0;
            valid_out   <= 1'b0;
            data_out    <= '0;
            for (int i = 0; i < NUM_ACC; i = i + 1)
            begin
                acc[i].data     <= '0;
                acc[i].valid    <= 1'b0;
            end
        end
        else
        begin
            if (valid_in)
            begin
                if (chain_cnt == CHAIN_W-1)
                begin
                    chain_cnt   <= '0;
                    // output is the current last accumulator
                    valid_out   <= acc[NUM_ACC-1].valid;
                    data_out    <= acc[NUM_ACC-1].data + prod[NUM_ACC-1]; // assuming this won't clip for now
                    // shift the accumulators
                    for (int i = 1; i < NUM_ACC; i = i + 1)
                    begin
                        acc[i].data             <= acc[i-1].data + prod[i-1];
                        acc[i].valid            <= acc[i-1].valid;
                    end
                    acc[0].data             <= '0;
                    acc[0].valid            <= 1'b0;
                end
                else
                begin
                    acc[0].valid    <= 1'b1;
                    valid_out       <= 1'b0;
                    chain_cnt       <= chain_cnt + 1;
                    for (int i = 0; i < NUM_ACC; i = i + 1)
                    begin
                        acc[i].data <= acc[i].data + prod[i];
                    end
                end
            end
        end
    end
endmodule