module Shat # (parameter N = 32, IN_W = 16, OUT_W = 16, SH_W = 16, R_IN = 12, R_OUT = 12, R_SH = 12, ADD_STEP = 2)
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
    
    typedef enum {IDLE, MULT, ADD} state_t;

    state_t state_r; // current state
    state_t state_n; // next state

    logic signed [SH_W-1:0] sh [N-1:0];

    logic signed [IN_W-1:0] shift_reg_n [N-2:0]; // need N-1 saved values
    logic signed [IN_W-1:0] shift_reg_r [N-2:0];

    logic signed [IN_W*2-1:0] prod_n [N-1:0]; // sized to N for easier loops
    logic signed [IN_W*2-1:0] prod_r [N-1:0];

    logic signed [IN_W*2:0] sum_n;
    logic signed [IN_W*2:0] sum_r;

    logic signed [OUT_W-1:0] final_sum_r;
    logic signed [OUT_W-1:0] final_sum_n;
    
    logic out_valid_r;
    logic out_valid_n;

    logic [$clog2(N):0] add_idx_n; // so can reach the Value "N"
    logic [$clog2(N):0] add_idx_r;


    initial 
    begin
        $readmemh("shVals.mem", sh);
    end

    assign data_out     = final_sum_r;
    assign valid_out    = out_valid_r;
    
    always_comb
    begin
        state_n     = state_r;
        shift_reg_n = shift_reg_r;
        prod_n      = prod_r;
        sum_n       = sum_r;
        add_idx_n   = add_idx_r;
        final_sum_n = '0;
        out_valid_n = 1'b0;

        unique case (state_r)
            IDLE:
            begin
                if (valid_in)
                begin
                    //OUTPUT
                    sum_n = sum_r + ((data_in * sh[0]) >>> SHIFT_VAL);
                    // INPUT
                    shift_reg_n[0] = data_in;
                    for (int i = 1; i < N-1; i = i + 1)
                    begin
                        shift_reg_n[i] = shift_reg_r[i-1];
                    end
                    state_n = MULT;
                end
            end
            MULT:
            begin
                // OUTPUT
                out_valid_n = 1'b1;
                if (sum_r > OUT_W'(OUT_MAX))
                begin
                    final_sum_n = OUT_W'(OUT_MAX);
                end
                else if (sum_r < OUT_W'(OUT_MIN))
                begin
                    final_sum_n = OUT_W'(OUT_MIN);
                end
                else
                begin
                    final_sum_n = sum_r;
                end
                // INPUT
                for (int i = 0; i < N-1; i = i + 1)
                begin
                    prod_n[i] = (shift_reg_r[i] * sh[i+1]) >>> SHIFT_VAL;
                end
                prod_n[N-1] = '0;
                sum_n       = '0;
                add_idx_n   = '0;
                state_n     = ADD;
            end
            ADD:
            begin
                for (int i = 0; i < ADD_STEP; i = i + 1)
                begin
                    sum_n = sum_n + prod_r[add_idx_r + i];
                end
                add_idx_n = add_idx_r + ADD_STEP;
                if (add_idx_r + ADD_STEP == N)
                begin
                    state_n = IDLE;
                end
            end
        endcase
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            state_r     <= IDLE;
            for (int i = 0; i < N; i = i + 1)
            begin
                shift_reg_r[i]  <= '0;
                prod_r[i]       <= '0;
            end
            sum_r       <= '0;
            add_idx_r   <= '0;
            final_sum_r <= '0;
            out_valid_r <= '0;
        end
        else
        begin
            state_r     <= state_n;
            shift_reg_r <= shift_reg_n;
            prod_r      <= prod_n;
            sum_r       <= sum_n;
            add_idx_r   <= add_idx_n;
            final_sum_r <= final_sum_n;
            out_valid_r <= out_valid_n;
        end
    end
   
endmodule