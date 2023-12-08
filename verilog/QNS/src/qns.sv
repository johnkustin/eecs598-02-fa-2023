module qns #(parameter IN_W, R_IN, OUT_W, R_OUT, LEVEL)
(
    input clock,
    input reset,
    input logic valid_in,
    input logic signed [IN_W-1:0] x_in,
    output logic signed [OUT_W-1:0] y_out,
    output logic valid_out
);

    localparam logic signed [IN_W-1:0] LEVEL_2      = 2*(2**R_IN);
    localparam logic signed [IN_W-1:0] LEVEL_HALF   = 2**(R_IN-1);
    localparam logic signed [IN_W-1:0] LEVEL_3      = 3*(2**R_IN);
    localparam logic signed [IN_W-1:0] LEVEL_1      = 2**R_IN;

    logic signed [IN_W-1:0] mem_r [2];
    logic signed [IN_W-1:0] mem_n [2];
    logic signed [IN_W-1:0] yd;
    logic signed [IN_W:0] y;
    logic signed [IN_W:0] level_i;
    // logic signed [IN_W:0] level_i_sq;
    logic signed [IN_W-1:0] x_reg;
    logic                   valid_internal;


    always_comb
    begin
        mem_n = mem_r;
        mem_n[0] = mem_n[0] + x_reg - yd;
        mem_n[1] = mem_n[1] + mem_n[0] - yd;
        level_i = ((mem_n[1] / LEVEL) <<< R_OUT) + LEVEL_2 - LEVEL_HALF;
        // level_i_sq = level_i;
        if (level_i[R_IN-1:0] > LEVEL_HALF)
        begin
            if (level_i > 0)
            begin
                level_i[R_IN-1:0] = '0;
                level_i = level_i + LEVEL_1;
            end
            else
            begin
                level_i[R_IN-1:0] = '0;
                level_i = level_i - LEVEL_1;
            end
        end
        else
        begin
            level_i[R_IN-1:0] = '0;
        end


        if (level_i > LEVEL_3)
        begin
            level_i = LEVEL_3;
        end
        else if (level_i < 0)
        begin
            level_i = '0;
        end

        y = LEVEL*(level_i + LEVEL_HALF - LEVEL_2); 

    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            mem_r[0]  <= '0;
            mem_r[1]  <= '0;
            x_reg   <= '0;
            y_out   <= '0;
            yd      <= '0;
            valid_out   <= '0;
        end
        else
        begin
            if (valid_in)
            begin
                valid_internal <= valid_in;
                x_reg <= x_in;
            end
            if (valid_internal)
            begin
                valid_out <= 1'b1;
                y_out <= (y >>> (R_IN - R_OUT));
                mem_r <= mem_n;
                yd <= y;
            end
            else
            begin
                valid_out <= 1'b0;
            end
        end
    end


endmodule