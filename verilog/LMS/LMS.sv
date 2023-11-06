module LMS # (parameter N = 32, IN_W = 16, OUT_W = 16, MU_W = 16, R_IN = 12, R_OUT = 12, R_MU = 12, MU = 2000, OFFSET = 2000, ADD_STEP = 16)
(
    input                           clock,
    input                           reset,
    input logic                     valid_u_in,
    input logic signed [IN_W-1:0]   data_u_in,
    input logic                     valid_e_in,
    input logic signed [IN_W-1:0]   data_e_in,
    output logic signed [OUT_W-1:0] data_out [N-1:0],
    output logic                    valid_out
);
    // NOTE: OFFSET and must be provided on R_IN
    localparam ADJ_W        = IN_W*2 + 2;
    localparam SHIFT_VAL    = R_MU + (R_IN - R_OUT);
    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);

    typedef enum {IDLE, DIV, ADJ, OUTPUT, SETUP} state_t;
    
    typedef struct {
        logic valid;
        logic signed [IN_W-1:0] data;
    } in_t;

    state_t state_r;
    state_t state_n;

    in_t u_r;
    in_t u_n;

    in_t e_r;
    in_t e_n;

    logic signed [ADJ_W-1:0] adj_n; // R_IN (or R_MU)
    logic signed [ADJ_W-1:0] adj_r;

    logic signed [ADJ_W-1:0] num_n; // R_MU + R_IN
    logic signed [ADJ_W-1:0] num_r;

    logic signed [ADJ_W-1:0] inter_res_n [N-1:0];
    logic signed [ADJ_W-1:0] inter_res_r [N-1:0];

    logic signed [IN_W-1:0] shift_reg_n [N-1:0];
    logic signed [IN_W-1:0] shift_reg_r [N-1:0];

    logic signed [OUT_W-1:0] final_res_n [N-1:0];
    logic signed [OUT_W-1:0] final_res_r [N-1:0];

    logic signed [IN_W*2-1:0] prod_n [N-1:0];
    logic signed [IN_W*2-1:0] prod_r [N-1:0]; // R_IN

    logic final_res_valid_n;
    logic final_res_valid_r;

    logic [$clog2(N):0] add_idx_n; // so can reach the Value "N"
    logic [$clog2(N):0] add_idx_r;


    assign data_out     = final_res_r;
    assign valid_out    = final_res_valid_r;

    always_comb
    begin
        state_n             = state_r;
        u_n                 = u_r;
        e_n                 = e_r;
        adj_n               = adj_r;
        num_n               = num_r;
        inter_res_n         = inter_res_r;
        shift_reg_n         = shift_reg_r;
        final_res_n         = final_res_r;
        prod_n              = prod_r;
        final_res_valid_n   = 1'b0;
        add_idx_n           = add_idx_r;

        unique case (state_r)
            IDLE:
            begin
                if (u_r.valid && e_r.valid)
                begin
                    state_n     = DIV;
                    // reset the input registers
                    u_n.valid   = 1'b0;
                    u_n.data    = '0;
                    e_n.valid   = 1'b0;
                    e_n.data    = '0;
                    // add the final incoming value to the adjuster
                    adj_n       = adj_r + ((u_r.data * u_r.data) >>> R_IN); // R_IN
                    num_n       = MU * e_r.data; // R_IN + R_MU

                    // add the data to the shift register
                    shift_reg_n[0] = u_r.data;
                    for (int i = 1; i < N; i = i + 1)
                    begin
                        shift_reg_n[i] = shift_reg_r[i-1];
                    end
                end
                else
                begin // update input registers if one of the inputs comes in
                    if (valid_u_in)
                    begin
                        u_n.valid   = 1'b1;
                        u_n.data    = data_u_in;
                    end
                    if (valid_e_in)
                    begin
                        e_n.valid   = 1'b1;
                        e_n.data    = data_e_in;
                    end
                end
            end
            DIV:
            begin
                state_n = ADJ;
                adj_n   = (num_r / adj_r); // R_MU = (R_MU +  R_IN) - R_IN
            end
            ADJ:
            begin
                state_n = OUTPUT;
                for (int i = 0; i < N; i = i + 1)
                begin
                    inter_res_n[i] = (shift_reg_r[i] * adj_r) >>> SHIFT_VAL; // R_OUT
                end
            end
            OUTPUT:
            begin
                state_n             = SETUP;
                // find the final output vector, keeping N bounds when necessary
                final_res_valid_n   = 1'b1;
                for (int i = 0; i < N; i = i + 1)
                begin
                    if (inter_res_r[i] > OUT_W'(OUT_MAX))
                    begin
                        final_res_n[i] = OUT_W'(OUT_MAX);
                    end
                    else if (inter_res_r[i] < OUT_W'(OUT_MIN))
                    begin
                        final_res_n[i] = OUT_W'(OUT_MIN);
                    end
                    else
                    begin
                        final_res_n[i] = inter_res_r[i];
                    end
                end

                // find all the squares and store them in prod
                for (int i = 0; i < N-1; i = i + 1)
                begin
                    prod_n[i] = (shift_reg_r[i] * shift_reg_r[i]) >>> R_IN;
                end
                prod_n[N-1] = '0; // avoid double counting

                // initialize values for next state
                adj_n       = (OFFSET);
                add_idx_n   = '0;
            end
            SETUP:
            begin
                // recalculate the next adj_n as much as possible
                for (int i = 0; i < ADD_STEP; i = i + 1)
                begin
                    adj_n = adj_n + prod_r[add_idx_r + i];
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
            state_r             <= IDLE;
            u_r.valid           <= 1'b0;
            u_r.data            <= '0;
            e_r.valid           <= 1'b0;
            e_r.data            <= '0;

            adj_r               <= OFFSET;
            num_r               <= '0;
            final_res_valid_r   <= 1'b0;
            add_idx_r           <= '0;

            for (int i = 0; i < N; i = i + 1)
            begin
                shift_reg_r[i]  <= '0;
                inter_res_r[i]  <= '0;
                final_res_r[i]  <= '0;
                prod_r[i]       <= '0;
            end
        end
        else
        begin
            state_r             <= state_n;
            u_r                 <= u_n;
            e_r                 <= e_n;
            adj_r               <= adj_n;
            num_r               <= num_n;
            final_res_valid_r   <= final_res_valid_n;
            add_idx_r           <= add_idx_n;
            shift_reg_r         <= shift_reg_n;
            inter_res_r         <= inter_res_n;
            final_res_r         <= final_res_n;
            prod_r              <= prod_n;
        end
    end

endmodule