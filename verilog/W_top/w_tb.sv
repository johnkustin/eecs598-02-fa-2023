`timescale 1ns/1ps

module testbench;
    localparam N        = 32;
    localparam K        = 32;
    localparam LMS_IN_W = 32;
    localparam U1_IN_W  = 32;
    localparam INPUT_N  = 3000;
    localparam OUT_W    = 32;
    localparam IN_W     = 32;
    localparam R_IN     = 31;
    localparam R_OUT    = 31;
    localparam R_SH     = 30;

    logic                       clock;
    logic                       reset;
    logic                       valid_lms_in;
    logic signed [LMS_IN_W-1:0] data_lms_in;
    logic                       valid_u_in;
    logic signed [U1_IN_W-1:0]  data_u_in;
    logic signed [OUT_W-1:0]    data_out;
    logic                       valid_out;

    logic signed [IN_W-1:0]     input_data_u [INPUT_N-1:0];
    logic signed [IN_W-1:0]     input_data_lms [INPUT_N-1:0];  
    integer                     clock_cnt;
    integer                     data_cnt;
    integer                     out_cnt;
    integer                     out_file;

    initial
    begin
    	$dumpfile("testbench.vcd");
        $dumpvars(0);	
        $sdf_annotate("results/Shat.mapped.sdf", w_1); // this line will cause some warnings when you run the *NON SYNTHESIZED* version of the hardware 
    end
    
    w_test #(.N(N), .LMS_IN_W(LMS_IN_W), .U1_IN_W(U1_IN_W), .OUT_W(OUT_W), .R_IN(R_IN), .R_OUT(R_OUT), .R_SH(R_SH)) w_1
    (
        .clock      (clock),
        .reset      (reset),
        .valid_lms_in   (valid_lms_in),
        .data_lms_in    (data_lms_in),
        .valid_u_in   (valid_u_in),
        .data_u_in  (data_u_in),
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
        $readmemh("inputVals.mem", input_data_u);
        $readmemh("shVals.mem", input_data_lms);
    end

    always @(negedge clock)
    begin
        if (reset)
        begin
            clock_cnt   <= 0;
            data_cnt    <= 0;
            valid_lms_in    <= 1'b0;
            valid_u_in  <= 1'b0;
            data_lms_in     <= '0;
            data_u_in   <= '0;
        end
        else
        begin
            clock_cnt <= clock_cnt + 1;

            if (data_cnt == INPUT_N)
            begin
                valid_lms_in    <= 1'b0;
                valid_u_in  <= 1'b0;
                data_lms_in     <= '0;
                data_u_in   <= '0;
            end
            else
            begin
                if (clock_cnt % K == 0)
                begin
                    valid_lms_in    <= 1'b1;
                    valid_u_in  <= 1'b1;
                    data_u_in     <= input_data_u[data_cnt];
                    data_lms_in   <= input_data_lms[data_cnt];
                    data_cnt    <= data_cnt + 1;
                end
                else
                begin
                    valid_lms_in    <= 1'b0;
                    valid_u_in      <= 1'b0;
                    data_lms_in     <= '0;
                    data_u_in   <= '0;
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
        if (valid_out)
        begin
            out_cnt <= out_cnt + 1;
            $fdisplay(out_file, "%d", data_out);
        end
        if (out_cnt == INPUT_N)
        begin
            $fclose(out_file);
            $finish;
        end
    end

    initial
    begin
        out_file = $fopen("/afs/umich.edu/user/j/i/jiangtia/course_files_export/final_pj/results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end

endmodule