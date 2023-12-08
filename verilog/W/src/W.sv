module W # (parameter N = 32, IN_W = 32, OUT_W = 32, COEFF_W = 32, R_IN = 31, R_OUT = 31, R_COEFF = 30)
(
    input                               clock,
    input                               reset,
    input logic                         valid_in,
    input wire                          weight_load_en,
    input logic signed  [IN_W-1:0]      data_in,
    input logic signed  [COEFF_W-1:0]   weight_in [N],
    input logic [$clog2(N)-1:0]         output_idx,
    output logic signed [COEFF_W-1:0]   output_coeff,
    output logic signed [OUT_W-1:0]     data_out,
    output logic                        valid_out
);  

    // parameter logic signed [COEFF_W-1:0] sh [0:N-1] = {32'hffec56d6, 32'hff645a1d, 32'h226809d, 32'hef295e9e,
    //                                                 32'he52a3055, 32'hbb439581, 32'hfeb851ec, 32'h351eb852,
    //                                                 32'hd35a86, 32'h10b0f28, 32'hff089a02, 32'hbac711, 
    //                                                 32'hff80346e, 32'h4816f0, 32'hffe76c8b, 32'hfff14120,
    //                                                 32'h2f837b, 32'hffb7e910, 32'h5a1cac, 32'hff98c7e3,
    //                                                 32'h6dc5d6, 32'hff923a2a, 32'h6c2268, 32'hff9a6b51,
    //                                                 32'h5bc01a, 32'hffafb7e9, 32'h432ca5, 32'hffc9eecc,
    //                                                 32'h28f5c3, 32'hffe28241, 32'h1205bc, 32'hffeab368};


    logic signed [COEFF_W-1:0] w [N];
    
    localparam OUT_MAX      = 2**(OUT_W-1)-1;
    localparam OUT_MIN      = -2**(OUT_W-1);
    localparam SHIFT_VAL    = R_COEFF + (R_IN - R_OUT);

    logic signed [IN_W-1:0]     shift_reg [N-1:0];

    logic [1:0] internal_valids;

    logic signed [IN_W*2:0]     prod [N];

    logic signed [IN_W*2:0]     sum_n;

    logic signed [OUT_W-1:0]    final_sum_n;
    
    assign output_coeff = w[output_idx];

    always_comb
    begin
        // OUTPUT
        sum_n     = '0;
        for (int i = 0; i < N-1; i = i + 1)
            sum_n = sum_n + prod[i];
        
        if (sum_n > OUT_W'(OUT_MAX))
          final_sum_n = OUT_W'(OUT_MAX);
        else if (sum_n < OUT_W'(OUT_MIN))
          final_sum_n = OUT_W'(OUT_MIN);
        else 
          final_sum_n = sum_n;
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            for (int i = 0; i < N; i = i + 1)
            begin
                shift_reg[i]  <= '0;
                prod[i]       <= '0;
            end
                
            for (int i = 0; i < N; i = i + 1)
                w[i] <= '0;
            data_out    <= '0;
            valid_out   <= 1'b0;
            internal_valids <= '0;
        end
        else
        begin
            if (valid_in)
            begin
                shift_reg[0] <= data_in;
                for (int i = 1; i < N; i = i + 1)
                begin
                    shift_reg[i] <= shift_reg[i-1];
                end
            end

            internal_valids[0] <= valid_in;
            internal_valids[1] <= internal_valids[0];
            for (int i = 0; i < N; i = i + 1)
            begin
                prod[i] <= ((shift_reg[i] * w[i]) >>> SHIFT_VAL);
            end
            data_out    <= final_sum_n;
            valid_out   <= internal_valids[1];

            if (weight_load_en) 
            begin
              for (int i = 0; i < N; i = i + 1)
                w[i] <= w[i] + weight_in[i];
            end
        end
    end
endmodule