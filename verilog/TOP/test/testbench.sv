`include "src/sys_defs.svh"

module testbench;

    localparam NUM_UP = 96000;
    localparam NUM_DP = 96000;
    localparam NUM_SP = 1024;
    localparam NUM_Y0 = 96000;
    localparam LATENCY = 6;
    localparam LMS_LUT_SIZE = 128;
    localparam UP_RESET_IDX = 12799;
    localparam Y0_RESET_IDX = 12799;

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


    localparam DP_TO_EP_SHIFT = `R_DP - `R_EP; // should be 2
    localparam SP_TO_EP_SHIFT = `R_SP - `R_EP; // should be 5

    // internal testbench
    logic signed [`EP_W-1:0] ep_data_c;
    logic signed [`UP_W-1:0] up_data_MEM [NUM_UP];
    logic signed [`DP_W-1:0] dp_data_MEM [NUM_DP];
    logic signed [`SP_W-1:0] sp_data_MEM [NUM_SP];
    logic signed [`Y0_W] y0_data_VEC [NUM_Y0];

    logic [`LMS_LUT_OUT_W-2:0] lms_LUT [LMS_LUT_SIZE];
    integer up_num;
    integer lms_num;
    integer y0_num;
    logic done_bootup;
    integer y0_out_file;
    integer ep_out_file;
    integer qns1_out_file;
    integer qns2_out_file;
    integer qns3_out_file;
    integer qns4_out_file;

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
    end

    // calculate the current ep to add
    always_comb
    begin
        ep_data_c = dp_data_MEM[up_num - LATENCY] >>> DP_TO_EP_SHIFT;
        ep_data_c = ep_data_c + ((sp_data_MEM[0] * y0_data_out) >>> SP_TO_EP_SHIFT);
        for (int i = 1; i < NUM_SP; i = i + 1)
        begin
            ep_data_c = ep_data_c + ((sp_data_MEM[i] * y0_data_VEC[y0_num - i]) >>> SP_TO_EP_SHIFT);
        end
    end

    // input
    always @(negedge clock)
    begin
        if (reset)
        begin
            up_valid_in             <= 1'b0;
            up_data_in              <= '0;
            done_bootup             <= '0;
            write_lms_lut_idx_in    <= '0;
            write_lms_lut_valid_in  <= 1'b0;
            write_lms_lut_data_in   <= '0;
            lms_num                 <= '0;
            up_num                  <= UP_RESET_IDX;
        end
        else
        begin
            if (done_bootup)
            begin
                write_lms_lut_valid_in <= 1'b0;
                if (up_num == NUM_UP)
                begin
                    up_valid_in <= 1'b0;
                end
                else
                begin
                    up_valid_in <= 1'b1;
                    up_data_in  <= up_data_MEM[up_num];
                    up_num      <= up_num + 1;
                end
            end
            else
            begin
                up_valid_in             <= 1'b0;
                write_lms_lut_valid_in  <= 1'b1;
                if (lms_num == LMS_LUT_SIZE-1)
                begin
                    done_bootup <= 1'b1;
                end
                write_lms_lut_idx_in    <= lms_num;
                write_lms_lut_data_in   <= lms_LUT[lms_num];
                lms_num                 <= lms_num + 1;
            end
        end
    end

    // outputs
    always @(negedge clock)
    begin
        if (reset)
        begin
            ep_data_in <= '0;
            ep_valid_in <= 1'b0;
            for (int i = 0; i < NUM_Y0; i = i + 1)
            begin
                y0_data_VEC[i] <= '0;
            end
            y0_num <= Y0_RESET_IDX;
        end
        else
        begin
            if (y0_valid_out)
            begin
                $display(y0_num);
                $fdisplay(y0_out_file, "%d", y0_data_out);
                $fdisplay(ep_out_file, "%d", ep_data_c);
                y0_data_VEC[y0_num] <= y0_data_out;
                y0_num              <= y0_num + 1;
                ep_data_in          <= ep_data_c;
                ep_valid_in         <= 1'b1;
                if (y0_num == NUM_Y0-10) // todo change this to max val and make sense of it
                begin
                    $fclose(y0_out_file);
                    $fclose(ep_out_file);
                    $fclose(qns1_out_file);
                    $fclose(qns2_out_file);
                    $fclose(qns3_out_file);
                    $fclose(qns4_out_file);
                    $finish;
                end
            end
            else
            begin
                ep_data_in  <= '0;
                ep_valid_in <= done_bootup; // throw some 0 error valids in there
            end
        end
    end

    always @(posedge clock)
    begin
        if (t0.qns1.valid_out)
            $fdisplay(qns1_out_file, "%d %d", t0.qns1_to_lpd1_data, t0.qns1.e);
        if (t0.qns2.valid_out)
            $fdisplay(qns2_out_file, "%d %d", t0.qns2_out_data, t0.qns2.e);
        if (t0.qns3.valid_out)
            $fdisplay(qns3_out_file, "%d %d", t0.qns3_data_out, t0.qns3.e);
        if (t0.qns4.valid_out)
            $fdisplay(qns4_out_file, "%d %d", t0.qns4_data_out, t0.qns4.e);
    end        
        

    initial
    begin
        y0_out_file = $fopen("../../python/TOP/data/y0_hw_raw.txt");
        ep_out_file = $fopen("../../python/TOP/data/ep_hw_raw.txt");
        
        qns1_out_file = $fopen("data/qns1.txt", "w");
        qns2_out_file = $fopen("data/qns2.txt", "w");
        qns3_out_file = $fopen("data/qns3.txt", "w");
        qns4_out_file = $fopen("data/qns4.txt", "w");

        clock = 0;
        reset = 1;
        @(negedge clock);
        @(negedge clock);
        reset = 0;
        @(negedge clock);
    end



endmodule