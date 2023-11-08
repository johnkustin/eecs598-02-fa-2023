module LMS # (parameter N = 32, IN_W = 20, OUT_W = 20, MU_W = 8, ADJ_LUT_IN_W = 10, ADJ_LUT_OUT_W = 12, R_IN = 18, R_OUT = 18, R_MU = 9,  R_ADJ_LUT_IN = 10, R_ADJ_LUT_OUT = 0, MU = 102, OFFSET = 2621, ADD_STEP = 4)
(
    input                                   clock,
    input                                   reset,
    input logic                             valid_u_in,
    input logic signed [IN_W-1:0]           data_u_in,
    input logic                             valid_e_in,
    input logic signed [IN_W-1:0]           data_e_in,
    output logic signed [N-1:0] [OUT_W-1:0] data_out,
    output logic                            valid_out
);
    // NOTE: OFFSET and must be provided on R_IN
    // NOTE: R_MU >= 0 (this should always be true)
    // NOTE: R_OUT >= 0

    localparam ADJ_LUT_IN_SHIFT_VAL     = (R_IN - R_ADJ_LUT_IN);
    localparam OUT_SHIFT_VAL            = R_IN + (R_IN - R_OUT); // Go from R_IN to R_OUT

    localparam PROD_W                   = IN_W*2;
    localparam R_PROD                   = R_IN;

    localparam ADJ_LUT_IN_INTERNAL_W    = (ADJ_LUT_IN_SHIFT_VAL >= 0) ? PROD_W + 2 : (IN_W+ADJ_LUT_IN_W)+2;
    localparam R_ADJ_LUT_IN_INTERNAL    = R_IN;

    localparam NUM_W                    = IN_W + MU_W;
    localparam R_NUM                    = R_IN;

    localparam FINAL_ADJ_W              = IN_W + ADJ_LUT_OUT_W;
    localparam R_FINAL_ADJ              = R_IN;

    localparam INTER_PROD_W             = IN_W*2;
    localparam R_INTER_PROD_W           = R_IN;

    localparam ADJ_LUT_ENTRIES          = 2**(ADJ_LUT_IN_W-1);

    localparam OUT_MAX                  = 2**(OUT_W-1)-1;
    localparam OUT_MIN                  = -2**(OUT_W-1);
    localparam ADJ_IN_MAX               = 2**(ADJ_LUT_IN_W-1)-1;

    typedef enum {IDLE, BOUNDS, LUT, DIV, ADJ, OUTPUT, SETUP} state_t;
    
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

    logic signed [ADJ_LUT_IN_INTERNAL_W-1:0]    adj_lut_in_n;
    logic signed [ADJ_LUT_IN_INTERNAL_W-1:0]    adj_lut_in_r;

    logic signed [ADJ_LUT_OUT_W-1:0]            adj_lut_out_n;
    logic signed [ADJ_LUT_OUT_W-1:0]            adj_lut_out_r;

    logic signed [NUM_W-1:0]                    num_n;
    logic signed [NUM_W-1:0]                    num_r;

    logic signed [FINAL_ADJ_W-1:0]              final_adj_n;
    logic signed [FINAL_ADJ_W-1:0]              final_adj_r;


    logic signed [INTER_PROD_W-1:0]             inter_res_n [N-1:0];
    logic signed [INTER_PROD_W-1:0]             inter_res_r [N-1:0];

    logic signed [IN_W-1:0]                     shift_reg_n [N-1:0];
    logic signed [IN_W-1:0]                     shift_reg_r [N-1:0];

    logic signed [N-1:0] [OUT_W-1:0]            final_res_n;
    logic signed [N-1:0] [OUT_W-1:0]            final_res_r;

    logic signed [PROD_W-1:0]                   prod_n [N-1:0];
    logic signed [PROD_W-1:0]                   prod_r [N-1:0];

    logic [ADJ_LUT_OUT_W-2:0]                   ADJ_RECIP_LUT [ADJ_LUT_ENTRIES]; // width is '-2' because not signed

    logic final_res_valid_n;
    logic final_res_valid_r;

    logic [$clog2(N):0] add_idx_n; // so can reach the Value "N"
    logic [$clog2(N):0] add_idx_r;

    initial
    begin
        $readmemh("adjRecipLutVals.mem", ADJ_RECIP_LUT);
    end

    assign data_out     = final_res_r;
    assign valid_out    = final_res_valid_r;

    always_comb
    begin
        state_n             = state_r;
        u_n                 = u_r;
        e_n                 = e_r;
        adj_lut_in_n        = adj_lut_in_r;
        adj_lut_out_n       = adj_lut_out_r;
        final_adj_n         = final_adj_r;
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
                    state_n         = BOUNDS;
                    // reset the input registers
                    u_n.valid       = 1'b0;
                    u_n.data        = '0;
                    e_n.valid       = 1'b0;
                    e_n.data        = '0;

                    // add the final incoming value to the adjuster
                    adj_lut_in_n    = (adj_lut_in_r + ((u_r.data * u_r.data) >>> R_IN)); // R_IN
                    num_n           = (MU * e_r.data) >>> R_MU; // R_MU

                    // transform adjuster to R_ADJ_LUT_IN
                    if (ADJ_LUT_IN_SHIFT_VAL >= 0)
                    begin
                        adj_lut_in_n = adj_lut_in_n >>> ADJ_LUT_IN_SHIFT_VAL;
                    end
                    else
                    begin
                        adj_lut_in_n = adj_lut_in_n <<< (-ADJ_LUT_IN_SHIFT_VAL);
                    end

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
            BOUNDS: // Potentially get rid of this state if can fit into previous clock period
            begin
                state_n = LUT;
                if (adj_lut_in_r > ADJ_IN_MAX)
                begin
                    adj_lut_in_n = ADJ_IN_MAX;
                end
                else
                begin
                    adj_lut_in_n = adj_lut_in_r;
                end
            end
            LUT:
            begin
                state_n         = DIV;
                adj_lut_out_n   = ADJ_RECIP_LUT[adj_lut_in_r[ADJ_LUT_IN_W-2:0]];
            end
            DIV:
            begin
                state_n     = ADJ;
                final_adj_n = (num_r * adj_lut_out_r);
                if (R_ADJ_LUT_OUT >= 0)
                begin
                    final_adj_n = final_adj_n >>> R_ADJ_LUT_OUT; // R_IN
                end
                else
                begin
                    final_adj_n = final_adj_n <<< (-R_ADJ_LUT_OUT); // R_IN
                end
            end
            ADJ:
            begin
                state_n = OUTPUT;
                for (int i = 0; i < N; i = i + 1)
                begin
                    inter_res_n[i] = (shift_reg_r[i] * final_adj_r) >>> OUT_SHIFT_VAL; // R_IN -> R_OUT
                    // $display("%d = %d * %d, where num_r = %d, adj_lut_out_r = %d, adj_lut_in_r", inter_res_n[i], shift_reg_r[i], final_adj_r, num_r, adj_lut_out_r, adj_lut_in_r);
                end
            end
            OUTPUT:
            begin
                state_n             = SETUP;
                // find the final output vector, keeping N bounds when necessary
                final_res_valid_n   = 1'b1;
                // potentially delete
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
                adj_lut_in_n = OFFSET;
                add_idx_n   = '0;
            end
            SETUP:
            begin
                // recalculate the next adj_n as much as possible
                for (int i = 0; i < ADD_STEP; i = i + 1)
                begin
                    adj_lut_in_n = adj_lut_in_n + prod_r[add_idx_r + i];
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

            adj_lut_in_r        <= OFFSET;
            adj_lut_out_r       <= '0;
            final_adj_r         <= '0;
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
            adj_lut_in_r        <= adj_lut_in_n;
            adj_lut_out_r       <= adj_lut_out_n;
            final_adj_r         <= final_adj_n;
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