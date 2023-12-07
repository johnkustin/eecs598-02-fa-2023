`include "src/sys_defs.svh"

module testbench;

    localparam NUM_UP = 96000;
    localparam NUM_DP = 96000;
    localparam NUM_SP = 1024;
    localparam LMS_LUT_SIZE = 128;

    // dut I/O
    logic                       clock;
    logic                       reset;
    logic                       up_valid_in;
    logic signed [`UP_W-1:0]    up_data_in;
    logic                       ep_valid_in;
    logic signed [`EP_W-1:0]    ep_data_in;
    logic                       write_lms_lut_valid_in;
    logic [`LMS_LUT_OUT_W-2:0]  write_lms_lut_data_in;
    logic [`LMS_LUT_IN_W-2:0]   write_lms_lut_idx_in;
    logic                       y0_valid_out;
    logic signed [`Y0_W-1:0]    y0_data_out;

    // internal testbench
    logic signed [`UP_W-1:0] up_data_MEM [NUM_UP];
    logic signed [`DP_W-1:0] dp_data_MEM [NUM_DP];
    logic signed [`SP_W-1:0] sp_data_MEM [NUM_SP];
    logic signed [`Y0_W-1:0] y0_data_MEM [NUM_UP];

    logic [`LMS_LUT_OUT_W-2:0] lms_LUT [LMS_LUT_SIZE];
    integer up_num;
    integer lms_num;
    logic done_bootup;
    integer y0_out_file;

    top t0
    (
        .clock                  (clock),
        .reset                  (reset),
        .up_valid_in            (up_valid_in),
        .up_data_in             (up_data_in),
        .ep_valid_in            (ep_valid_in),
        .ep_data_in             (ep_data_in),
        .write_lms_lut_valid_in (write_lms_lut_valid_in),
        .write_lms_lut_data_in  (write_lms_lut_data_in),
        .write_lms_lut_idx_in   (write_lms_lut_idx_in),
        .y0_valid_out           (y0_valid_out),
        .y0_data_out            (y0_data_out)
    );

    // EP calculation

    logic signed [32:0] ep [NUM_DP];

    always_comb begin : ep_calculate
        // yp(n0) = wop'*up(n0:-1:n0-NW*K+1);
        if (done_bootup)
        begin

            // ep(n0) = dp(n0) + sp'*y0(n0:-1:n0-NW*K+1);
            y0_data_MEM[up_num] = y0_data_out; // qualify on valid
            for (int i = 0; i < NUM_SP; i = i + 1)
            begin
                ep_data_in = dp_data_MEM[up_num - 5] + sp_data_MEM[i] * y0_data_MEM[out_num - 1 - i];
                ep_valid_in = 1;
            end
        end else
        begin
            ep_valid_in = 0;
        end
    end

if (output_valid)
begin
    y0_data_MEM[out_num] <= data_out;
    out_num <= out_num + 1;
end
always @(posedge clock) begin
        if (done_bootup)
                ep[up_num] <= ep_data_in;
end

    always
    begin
        #5
        clock = ~clock;
    end

    initial
    begin
        // initialize up_data_MEM
        // initialize lms_LUT
        $readmemh("data/up.mem", up_data_MEM);
        $readmemh("data/dp.mem", dp_data_MEM);
        $readmemh("data/sp.mem", sp_data_MEM);
        $readmemh("../LMS/data/adjRecipLutVals.mem", lms_LUT);
        $dumpfile("testbench.vcd");
        $dumpvars(0);   
        // $sdf_annotate("results/TOP.mapped.sdf", sh0); // this line will cause some warnings when you run the *NON SYNTHESIZED* version of the hardware

    end

    // // just for compile check
    // assign ep_valid_in = 1'b0;
    // assign ep_data_in = '0;
    // input
    always @(negedge clock)
    begin
        if (reset)
        begin
            up_valid_in <= 1'b0;
            up_data_in <= '0;
            done_bootup <= '0;
            write_lms_lut_idx_in <= '0;
            write_lms_lut_valid_in <= 1'b0;
            write_lms_lut_data_in <= '0;
            lms_num <= '0;
            up_num <= 12799;
        end
        else
        begin
            if (done_bootup)
            begin
                write_lms_lut_valid_in <= 1'b0;
                if (up_num == NUM_UP)
                begin
                    $fclose(y0_out_file);
                    $finish;
                end
                else
                begin
                    up_valid_in <= 1'b1;
                    up_data_in  <= up_data_MEM[up_num];
                    up_num <= up_num + 1;
                end
            end
            else
            begin
                up_valid_in <= 1'b0;
                write_lms_lut_valid_in <= 1'b1;
                if (lms_num == LMS_LUT_SIZE-1)
                begin
                    done_bootup <= 1'b1;
                end
                write_lms_lut_idx_in <=  lms_num;
                write_lms_lut_data_in <= lms_LUT[lms_num];
                lms_num <= lms_num + 1;
            end
        end
    end

    // outputs
    always @(negedge clock)
    begin
        if (y0_valid_out)
        begin
            $fdisplay(y0_out_file, "%d", y0_data_out);
        end
    end

    initial
    begin
        y0_out_file = $fopen("../../python/TOP/data/y0_results.txt");
        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end



endmodule
