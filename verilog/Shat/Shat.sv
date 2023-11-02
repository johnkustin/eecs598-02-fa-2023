module Shat # (parameter N = 32, IN_W = 16, OUT_W = 16, SH_W = 16, R_IN = 12, R_OUT = 12, R_SH = 12)
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

    // need to have a valid_out every N cycles
    logic [$clog2(N):0]         curr_idx; // so can reach the Value "N"
    logic signed [SH_W-1:0]     sh [N-1:0];
    logic signed [IN_W*2-1:0]   curr_prod;
    logic                       prev_valid;

    initial 
    begin
        $readmemh("shVals.mem", sh);
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            curr_idx    <= '0;
            curr_prod   <= '0;
            data_out    <= '0;
            valid_out   <= '0;
            prev_valid  <= 1'b0;
        end
        else
        begin
            prev_valid <= valid_in;
            // can always calculate a data_out (it just might not be valid)
            if (curr_prod > OUT_W'(OUT_MAX))
            begin
                data_out <= OUT_W'(OUT_MAX);
            end
            else if (curr_prod < OUT_W'(OUT_MIN))
            begin
                data_out <= OUT_W'(OUT_MIN);
            end
            else
            begin
                data_out <= curr_prod;
            end
            
            if (curr_idx == N)
            begin
                // valid only once per N
                if (prev_valid)
                begin
                    valid_out <= 1'b1;
                end
                else
                begin
                    valid_out <= 1'b0;
                end
                // start new measurement process
                if (valid_in)
                begin
                    curr_prod   <= (data_in * sh[0]) >>> SHIFT_VAL;
                    curr_idx    <= 1;
                end
            end
            else if (valid_in)
            begin
                begin
                    curr_prod   <= curr_prod + ((data_in*sh[curr_idx]) >>> SHIFT_VAL); // move the multiplication back to R_OUT
                    curr_idx    <= curr_idx + 1;
                    valid_out   <= 1'b0;
                    data_out    <= '0;
                end
            end
        end
    end
endmodule