`timescale 1ns/1ps

module testbench;
    localparam N        = 32;
    localparam K        = 32;
    localparam MU       = 858993459;
    localparam OFFSET   = 21474836;
    localparam EH_IN_W  = 32;
    localparam U1_IN_W  = 32;
    localparam OUT_W    = 20;
    localparam R_EH_IN  = 32;
    localparam R_OUT    = 31;
    localparam R_U1_IN  = 31;
    localparam R_A_IN   = 4;
    localparam A_IN_W   = 8;
    localparam R_A_OUT  = 5;
    localparam A_OUT_W  = 13;
    localparam LUT_SIZE = 128;

    localparam OUT_NUM = 2601;


    logic                       clock;
    logic                       reset;
    logic                       valid_u_in;
    logic signed [U1_IN_W-1:0]  data_u_in;
    logic                       valid_e_in;
    logic signed [EH_IN_W-1:0]  data_e_in;
    logic signed [OUT_W-1:0]    data_out [N-1:0]; // Weird error with packed signed 2D arrays, easier to cast after-the-fact
    logic                       valid_out;
    logic [A_OUT_W-2:0]         write_lut_data;
    logic [A_IN_W-2:0]          write_lut_idx;
    logic                       write_lut_in;

    logic signed [U1_IN_W-1:0]  u_in [OUT_NUM-1:0];
    logic signed [EH_IN_W-1:0]  e_in [OUT_NUM-1:0];
    logic [A_OUT_W-2:0]         recip_vals [LUT_SIZE-1:0];

    integer clock_cnt;
    integer data_cnt;
    integer out_file;
    integer out_cnt;
    integer lut_cnt;

    logic is_first;

    initial
    begin
    	$dumpfile("testbench.vcd");
        $dumpvars(0);	
        $sdf_annotate("results/LMS.mapped.sdf", lms0); // this line will cause some warnings when you run the *NON SYNTHESIZED* version of the hardware 
    end

    LMS # (.N(N), .EH_IN_W(EH_IN_W), .U1_IN_W(U1_IN_W), .OUT_W(OUT_W), .A_IN_W(A_IN_W), .R_A_IN(R_A_IN), .R_A_OUT(R_A_OUT), .A_OUT_W(A_OUT_W), .R_EH_IN(R_EH_IN), .R_U1_IN(R_U1_IN), .R_OUT(R_OUT), 
           .MU(MU), .OFFSET(OFFSET)) lms0
    (
        .clock      (clock),
        .reset      (reset),
        .valid_u_in (valid_u_in),
        .data_u_in  (data_u_in),
        .valid_e_in (valid_e_in),
        .data_e_in  (data_e_in),
        .write_lut_in(write_lut_in),
        .write_lut_data(write_lut_data),
        .write_lut_idx(write_lut_idx),
        .data_out   (data_out),
        .valid_out  (valid_out)
    );

    always
    begin
        #5
        clock = ~clock;
    end

    initial
    begin
        $readmemh("data/uVals.mem", u_in);
        $readmemh("data/eVals.mem", e_in);
        $readmemh("data/adjRecipLutVals.mem", recip_vals);
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            clock_cnt       <= 0;
            data_cnt        <= 0;
            valid_e_in      <= 1'b0;
            valid_u_in      <= 1'b0;
            data_e_in       <= '0;
            data_u_in       <= '0;
            lut_cnt         <= '0;
            write_lut_idx   <= '0;
            is_first        <= 1'b1;
        end
        else
        begin
            if (lut_cnt < LUT_SIZE)
            begin
                if (is_first)
                begin
                    write_lut_idx <= '0;
                    is_first      <= 1'b0;
                end
                else
                begin
                    write_lut_idx <= write_lut_idx + 1;
                end
                lut_cnt <= lut_cnt + 1;
                write_lut_in <= 1'b1;
                write_lut_data <= recip_vals[lut_cnt];
            end
            else
            begin
                write_lut_in <= 1'b0;
                clock_cnt <= clock_cnt + 1;
                if (data_cnt == OUT_NUM)
                begin
                    valid_e_in  <= 1'b0;
                    valid_u_in  <= 1'b0;
                    data_u_in   <= '0;
                    data_e_in   <= '0;
                end
                else
                begin
                    if (clock_cnt % K == 0)
                    begin
                        data_cnt    <= data_cnt + 1;
                        valid_e_in  <= 1'b1;
                        data_e_in   <= e_in[data_cnt];

                        valid_u_in  <= 1'b1;
                        data_u_in   <= u_in[data_cnt];
                    end
                    else
                    begin
                        valid_e_in  <= 1'b0;
                        valid_u_in  <= 1'b0;
                        
                        data_e_in   <= '0;
                        data_u_in   <= '0;
                    end
                end
            end
        end
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            out_cnt <= 0;
        end
        else
        begin
            if (valid_out)
            begin
                out_cnt <= out_cnt + 1;
                $display("%d", out_cnt);
                for (int i = 0; i < N; i = i + 1)
                begin
                    $fdisplay(out_file, "%d", data_out[i]);
                end
            end
            if (out_cnt == OUT_NUM)
            begin
                $fclose(out_file);
                $finish;
            end
        end
    end

    initial
    begin
        out_file = $fopen("../../python/LMS/data/hw_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end
endmodule
