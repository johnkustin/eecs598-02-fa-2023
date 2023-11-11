
module LMS # (parameter N = 32, EH_IN_W = 32, U1_IN_W = 32, OUT_W = 32, A_IN_W = 8, R_A_IN = 4, A_OUT_W = 13, R_A_OUT = 5, R_EH_IN = 32, R_U1_IN = 31, R_OUT = 31, MU = 102, OFFSET = 2621)
(
    input                                   clock,
    input                                   reset,
    input logic                             valid_u_in,
    input logic signed [U1_IN_W-1:0]        data_u_in,
    input logic                             valid_e_in,
    input logic signed [EH_IN_W-1:0]        data_e_in,
    input logic                             write_lut_in,
    input logic [A_OUT_W-2:0]               write_lut_data,
    input logic [A_IN_W-2:0]                write_lut_idx,
    output logic signed [OUT_W-1:0]         data_out [N-1:0],
    output logic                            valid_out
);
    // NOTE: R_U1_IN > R_A_IN;
    // NOTE: can't have valid_e_in valid for back to back cycles

    localparam DIV_SHIFT    = (R_EH_IN + R_A_OUT) - R_U1_IN; 
    localparam OUT_SHIFT    = R_U1_IN + (R_U1_IN - R_OUT);
    localparam A_IN_SHIFT   = (R_U1_IN - R_A_IN); 

    localparam OUT_MAX                  = 2**(OUT_W-1)-1;
    localparam OUT_MIN                  = -2**(OUT_W-1);


    typedef enum {IDLE, LUT, DIV, OUT} state_t;

    typedef struct {
        logic valid;
        logic signed [EH_IN_W-1:0] data;
    } eh_t;

    typedef struct {
        logic valid;
        logic signed [U1_IN_W-1:0] data;
    } u1_t;

    eh_t e_in_r;
    eh_t e_in_n;

    u1_t u_in_r;
    u1_t u_in_n;

    state_t state_r;
    state_t state_n;

    logic signed [U1_IN_W-1:0] shift_reg_n [N-1:0];
    logic signed [U1_IN_W-1:0] shift_reg_r [N-1:0];

    logic signed [U1_IN_W*2 + 1:0] denom;

    logic signed [U1_IN_W*2 + 1:0] numer;

    logic signed [U1_IN_W*2 + 1:0] adj;

    logic signed [(U1_IN_W*2 + 1)*2:0] inter_res_n [N-1:0];
    logic signed [OUT_W-1:0] final_res_n [N-1:0];

    logic [1:0] valid_out_shift_n;
    logic [1:0] valid_out_shift_r;

    logic WEB;
    logic lut_en;
    logic [A_OUT_W-2:0]  recip_unsigned;
    logic signed [A_OUT_W-1:0] recip_signed;;
    logic [A_IN_W-2:0]          lut_address;
    


    // memory module
    
    SRAM_128_12 lut0 (  .A(lut_address),
                        .CE(clock),
                        .WEB(WEB),
                        .OEB(1'b0),
                        .CSB(~lut_en),
                        .I(write_lut_data),
                        .O(recip_unsigned)
                    );
    
    assign lut_en       = write_lut_in || (e_in_r.valid && u_in_r.valid);
    assign WEB          = ~write_lut_in;
    assign lut_address  = write_lut_in ? write_lut_idx : denom[A_IN_W-2:0];
    assign recip_signed = $signed({1'b0, recip_unsigned});


    always_comb
    begin
        numer = (MU * e_in_r.data) >>> R_EH_IN; // R_EH_IN
        adj = (numer * recip_signed) >>> DIV_SHIFT;// R_U1_IN
        for (int i = 0; i < N; i = i + 1)
        begin
            inter_res_n[i] = (shift_reg_r[i] * adj) >>> OUT_SHIFT;
            if (inter_res_n[i] > OUT_W'(OUT_MAX))
            begin
                final_res_n[i] = OUT_MAX;
            end
            else if (inter_res_n[i] < OUT_W'(OUT_MIN))
            begin
                final_res_n[i] = OUT_MIN;
            end
            else
            begin
                final_res_n[i] = inter_res_n[i];
            end
        end
    end

    always_comb
    begin
        denom = OFFSET + ((u_in_r.data * u_in_r.data) >> R_U1_IN);
        for (int i = 1; i < N; i = i + 1)
        begin
            denom = denom + ((shift_reg_r[i] * shift_reg_r[i]) >> R_U1_IN);
        end
        denom = denom >>> A_IN_SHIFT;
    end

    always_comb
    begin
        e_in_n = e_in_r;
        u_in_n = u_in_r;
        shift_reg_n = shift_reg_r;
        valid_out_shift_n[1] = valid_out_shift_r[0];

        if (e_in_r.valid && u_in_r.valid)
        begin
            u_in_n.valid = 1'b0;
            e_in_n.valid = 1'b0;

            valid_out_shift_n[0] = 1'b1;

            shift_reg_n[0] = u_in_r.data;
            for (int i = 1; i < N; i = i + 1)
            begin
                shift_reg_n[i] = shift_reg_r[i-1];
            end
        end
        else
        begin
            valid_out_shift_n[0] = 1'b0;
            if (valid_u_in)
            begin
                u_in_n.valid = 1'b1;
                u_in_n.data = data_u_in;
            end
            if (valid_e_in)
            begin
                e_in_n.valid = 1'b1;
                e_in_n.data = data_e_in;
            end
        end
    end

    always @(posedge clock)
    begin
        if (reset)
        begin
            e_in_r.valid <= '0;
            u_in_r.valid <= '0;
            e_in_r.data <= '0;
            u_in_r.data <= '0;
            valid_out_shift_r <= '0;
            for (int i = 0; i < N; i = i + 1)
            begin
                shift_reg_r[i] <= '0;
                data_out[i] <= '0;
            end
        end
        else
        begin
            valid_out_shift_r <= valid_out_shift_n;
            e_in_r <= e_in_n;
            u_in_r <= u_in_n;
            state_r <= state_n;
            shift_reg_r <= shift_reg_n;
            data_out <= final_res_n;
            valid_out <= valid_out_shift_n[1];
        end
    end
endmodule