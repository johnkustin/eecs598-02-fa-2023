module top
(
    input                               clock,
    input                               reset,
    input logic                         up_valid_in,
    input logic signed [`UP_W-1:0]      up_data_in,
    input logic                         ep_valid_in,
    input logic signed [`EP_W-1:0]      ep_data_in,
    input logic                         write_lms_lut_valid_in,
    input logic [`LMS_LUT_OUT_W-2:0]    write_lms_lut_data_in,
    input logic [`LMS_LUT_IN_W-2:0]     write_lms_lut_idx_in,
    output logic                        y0_valid_out,
    output logic signed [`Y0_W-1:0]     y0_data_out
);

    // DECLARATIONS
    
    // BOOTUP SIGNAL
    logic bootup_done;

    // PRIMARY PATH

    // QNS1 -> LPD
    logic signed [`QNS_OUT_W-1:0]   qns1_to_lpd1_data;
    logic                           qns1_to_lpd1_valid;

    // QNS1 -> W0
    logic [1:0] qns1_to_w0_data;
    logic       qns1_to_w0_valid;

    // W0 -> QNS3
    logic                       w0_to_qns3_valid;
    logic signed [`YP_W-1:0]    w0_to_qns3_data;

    // QNS -> OUT
    logic signed [`QNS_OUT_W-1:0] qns3_data_out;
    
    // SECONDARY PATH

    //LPD1 -> Shat1
    logic                   lpd1_to_shat1_valid;
    logic signed [`U_W-1:0] lpd1_to_shat1_data;

    //LPD1 -> W1
    logic                   lpd1_to_w1_valid;
    logic signed [`U_W-1:0] lpd1_to_w1_data;

    //Shat1 -> W2
    logic signed [`U1_W-1:0]    shat1_to_w2_data;
    logic                       shat1_to_w2_valid;

    //Shat1 -> LMS
    logic signed [`U1_W-1:0]    shat1_to_lms_data;
    logic                       shat1_to_lms_valid;

    // W1 -> Shat2
    logic                   w1_to_shat2_valid;
    logic signed [`Y_W-1:0] w1_to_shat2_data;

    // W2 -> LMS
    logic signed [`EH_W-1:0] w2_data_out;
    logic                    w2_valid_out;

    // Shat2 -> LMS
    logic signed [`DH_W-1:0]    shat2_data_out;
    logic                       shat2_valid_out;

    // QNS4 -> LPD2
    logic qns4_valid_out;
    logic signed [`QNS_OUT_W-1:0] qns4_data_out;
    logic qns4_to_lpd2_valid;
    logic signed [`E0_W-1:0] qns4_to_lpd2_data;

    // LPD2 -> LMS
    logic signed [`DH_W-1:0] lpd2_data_out;
    logic                    lpd2_valid_out;


    // EHat(n) -> LMS
    logic signed [`EH_W-1:0]    ehat_data;
    logic                       ehat_valid;

    // LMS -> W1 && W2
    logic signed [`W_COEFF_W-1:0]   lms_to_w_data [`W_N];
    logic                           lms_to_w_valid;

    // W1 -> QNS2 -> W0
    logic signed [`QNS_OUT_W-1:0]   qns2_out_data;
    logic [1:0]                     qns2_to_w0_data;
    logic                           qns2_to_w0_valid;
    logic [$clog2(`W0_N)-1:0]       qns2_to_w0_idx;
    logic [$clog2(`W_N)-1:0]        w1_output_idx;
    logic signed [`W_COEFF_W-1:0]   w1_output_coeff;


    // INSTANTIATIONS
    always @(posedge clock)
    begin
        if (reset)
        begin
            bootup_done <= 1'b0;
        end
        else
        begin
            if (up_valid_in)
            begin
                bootup_done <= 1'b1;
            end
        end
    end

    // PRIMARY PATH
    mod2 #( 
            .IN_W   (`UP_W), 
            .OUT_W  (`QNS_OUT_W),
            .YY_FS  (`QNS_LEVEL_1)
    ) qns1
    (   
        .clock      (clock),
        .reset      (reset),
        .valid_in   (up_valid_in),
        .in         (up_data_in),
        .out        (qns1_to_lpd1_data),
        .out_scaled (),
        .valid_out  (qns1_to_lpd1_valid)
    );

    // QNS1 -> W0
    assign qns1_to_w0_valid = qns1_to_lpd1_valid;
    always_comb
    begin
        if (qns1_to_lpd1_data == -3)
        begin
            qns1_to_w0_data = 2'b00;
        end
        else if (qns1_to_lpd1_data == 3)
        begin
            qns1_to_w0_data = 2'b01;
        end
        else if (qns1_to_lpd1_data == -1)
        begin
            qns1_to_w0_data = 2'b10;
        end
        else
        begin
            qns1_to_w0_data = 2'b11;
        end
    end

    W_top #(
            .W_W    (`W0_COEFF_W),
            .R_W    (`R_W0_COEFF),
            .N      (`W0_N),
            .OUT_W  (`YP_W),
            .R_OUT  (`R_YP),
            .LV0    (`W0_LUT_0_VAL),
            .LV1    (`W0_LUT_1_VAL),
            .LV2    (`W0_LUT_2_VAL),
            .LV3    (`W0_LUT_3_VAL),
            .LV4    (`W0_LUT_4_VAL),
            .LV5    (`W0_LUT_5_VAL),
            .LV6    (`W0_LUT_6_VAL),
            .LV7    (`W0_LUT_7_VAL)
    ) w0
    (
        .clock              (clock),
        .reset              (reset),
        .valid_data_in      (qns1_to_w0_valid),
        .data_in            (qns1_to_w0_data),
        .valid_update_in    (qns2_to_w0_valid),
        .update_idx         (qns2_to_w0_idx),
        .update_data        (qns2_to_w0_data), 
        .valid_out          (w0_to_qns3_valid),
        .data_out           (w0_to_qns3_data)
    );

    mod2 #( 
            .IN_W   (`YP_W), 
            .OUT_W  (`QNS_OUT_W),
            .YY_FS  (`QNS_LEVEL_3)
    ) qns3
    (   
        .clock      (clock),
        .reset      (reset),
        .valid_in   (w0_to_qns3_valid),
        .in         (-w0_to_qns3_data),
        .out        (qns3_data_out),
        .out_scaled (),
        .valid_out  (y0_valid_out)
    );

    assign y0_data_out = qns3_data_out <<< 1; // multiply by 2

    // SECONDARY PATH
    LPD #(
        .IN_W   (`QNS_OUT_W),
        .R_IN   (0),
        .AAF_W  (`AAF_W),
        .R_AAF  (`R_AAF),
        .OUT_W  (`U_W),
        .R_OUT  (`R_U)
    ) lpd1
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (qns1_to_lpd1_valid),
        .data_in    (qns1_to_lpd1_data),
        .valid_out  (lpd1_to_shat1_valid),
        .data_out   (lpd1_to_shat1_data)
    );

    assign lpd1_to_w1_valid = lpd1_to_shat1_valid;
    assign lpd1_to_w1_data  = lpd1_to_shat1_data;

    Shat #(
        .N      (`SH_N),
        .IN_W   (`U_W),
        .OUT_W  (`U1_W),
        .SH_W   (`SH_W),
        .R_IN   (`R_U),
        .R_OUT  (`R_U1),
        .R_SH   (`R_SH)
    ) sh1
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (lpd1_to_shat1_valid),
        .data_in    (lpd1_to_shat1_data),
        .data_out   (shat1_to_w2_data),
        .valid_out  (shat1_to_w2_valid)
    );

    assign shat1_to_lms_data    = shat1_to_w2_data;
    assign shat1_to_lms_valid   = shat1_to_w2_valid;

    // NOTE: W may be the critical path. Potentially add a buffer for the products
    W #(
        .N          (`W_N),
        .IN_W       (`U_W),
        .OUT_W      (`Y_W),
        .COEFF_W    (`W_COEFF_W),
        .R_IN       (`R_U),
        .R_OUT      (`R_Y),
        .R_COEFF    (`R_W_COEFF)
    ) w1
    (
        .clock          (clock),
        .reset          (reset),
        .valid_in       (lpd1_to_w1_valid),
        .weight_load_en (lms_to_w_valid), 
        .data_in        (lpd1_to_w1_data),
        .weight_in      (lms_to_w_data),
        .output_idx     (w1_output_idx),
        .output_coeff   (w1_output_coeff),
        .data_out       (w1_to_shat2_data),
        .valid_out      (w1_to_shat2_valid)
    );

    W #(
        .N          (`W_N),
        .IN_W       (`U1_W),
        .OUT_W      (`EH_W),
        .COEFF_W    (`W_COEFF_W),
        .R_IN       (`R_U1),
        .R_OUT      (`R_EH),
        .R_COEFF    (`R_W_COEFF)
    ) w2
    (
        .clock          (clock),
        .reset          (reset),
        .valid_in       (shat1_to_w2_valid),
        .weight_load_en (lms_to_w_valid),
        .data_in        (shat1_to_w2_data),
        .weight_in      (lms_to_w_data),
        .output_idx     (w1_output_idx),
        .output_coeff   (),
        .data_out       (w2_data_out),
        .valid_out      (w2_valid_out)
    );

    Shat #(
        .N      (`SH_N),
        .IN_W   (`Y_W),
        .OUT_W  (`DH_W),
        .SH_W   (`SH_W),
        .R_IN   (`R_Y),
        .R_OUT  (`R_DH),
        .R_SH   (`R_SH)
    ) sh2
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (w1_to_shat2_valid),
        .data_in    (w1_to_shat2_data),
        .data_out   (shat2_data_out),
        .valid_out  (shat2_valid_out)
    );

    mod2 #( 
            .IN_W   (`EP_W), 
            .OUT_W  (`QNS_OUT_W),
            .YY_FS  (`QNS_LEVEL_4)
    ) qns4
    (   
        .clock      (clock),
        .reset      (reset),
        .valid_in   (ep_valid_in),
        .in         (ep_data_in),
        .out        (qns4_data_out),
        .out_scaled (),
        .valid_out  (qns4_valid_out)
    );
    
    // qns4 -> LPD2 passthrough
    always @(posedge clock)
    begin
        if (reset)
        begin
            qns4_to_lpd2_data <= '0;
            qns4_to_lpd2_valid <= 1'b0;
        end
        else
        begin
            qns4_to_lpd2_valid <= qns4_valid_out;
            if (qns4_data_out == -3)
            begin
                qns4_to_lpd2_data <= -(`QNS4_FINAL_OUT_3);
            end
            else if (qns4_data_out == -1)
            begin
                qns4_to_lpd2_data <= -(`QNS4_FINAL_OUT_1);
            end
            else if (qns4_data_out == 1)
            begin
                qns4_to_lpd2_data <= `QNS4_FINAL_OUT_1;
            end
            else
            begin
                qns4_to_lpd2_data <= `QNS4_FINAL_OUT_3;
            end
        end
    end

    LPD #(
        .IN_W   (`E0_W),
        .R_IN   (`R_E0), // TODO -> Double check this module works for non-zero R
        .AAF_W  (`AAF_W),
        .R_AAF  (`R_AAF),
        .OUT_W  (`DH_W),
        .R_OUT  (`R_DH)
    ) lpd2
    (
        .clock      (clock),
        .reset      (reset),
        .valid_in   (qns4_to_lpd2_valid),
        .data_in    (qns4_to_lpd2_data),
        .valid_out  (lpd2_valid_out),
        .data_out   (lpd2_data_out)
    );

    always @(posedge clock)
    begin
        if (reset)
        begin
            ehat_valid <=   1'b0;
            ehat_data   <= '0;
        end
        else
        begin
            ehat_valid  <= shat2_valid_out && w2_valid_out && lpd2_valid_out;
            ehat_data   <= (lpd2_data_out + shat2_data_out) - w2_data_out;
        end
    end


    LMS #(
        .N          (`W_N),
        .EH_IN_W    (`EH_W),
        .U1_IN_W    (`U1_W),
        .OUT_W      (`W_COEFF_W),
        .A_IN_W     (`LMS_LUT_IN_W),
        .A_OUT_W    (`LMS_LUT_OUT_W),
        .R_A_OUT    (`R_LMS_LUT_OUT),
        .R_A_IN     (`R_LMS_LUT_IN),
        .R_EH_IN    (`R_EH),
        .R_U1_IN    (`R_U1),
        .R_OUT      (`R_W_COEFF),
        .MU         (`MU),
        .OFFSET     (`OFFSET)
    ) lms0
    (
        .clock          (clock),
        .reset          (reset),
        .valid_u_in     (shat1_to_lms_valid),
        .data_u_in      (shat1_to_lms_data),
        .valid_e_in     (ehat_valid),
        .data_e_in      (ehat_data),
        .write_lut_in   (write_lms_lut_valid_in),
        .write_lut_data (write_lms_lut_data_in),
        .write_lut_idx  (write_lms_lut_idx_in),
        .data_out       (lms_to_w_data),
        .valid_out      (lms_to_w_valid)
    );
    
    // BRIDGE FROM PRIMARY PATH TO SECONDARY PATH
    always @(posedge clock)
    begin
        if (reset)
        begin
            qns2_to_w0_idx <= '0;
        end
        else
        begin
            if (bootup_done)
            begin
                if (qns2_to_w0_idx == `W0_N-1)
                begin
                    qns2_to_w0_idx <= '0;
                end
                else
                begin
                    qns2_to_w0_idx <= qns2_to_w0_idx + 1;
                end
            end
        end
    end

    assign w1_output_idx = (qns2_to_w0_idx + 16) >> 5;

    mod2 #( 
            .IN_W   (`W_COEFF_W), 
            .OUT_W  (`QNS_OUT_W),
            .YY_FS  (`QNS_LEVEL_2)
    ) qns2
    (   
        .clock      (clock),
        .reset      (reset),
        .valid_in   (bootup_done), // TODO: think more about this, possibly extrapolate to more places
        .in         (w1_output_coeff),
        .out        (qns2_out_data),
        .out_scaled (),
        .valid_out  (qns2_to_w0_valid)
    );

    always_comb
    begin
        if (qns2_out_data == -3)
        begin
            qns2_to_w0_data = 2'b00;
        end
        else if (qns2_out_data == 3)
        begin
            qns2_to_w0_data = 2'b01;
        end
        else if (qns2_out_data == -1)
        begin
            qns2_to_w0_data = 2'b10;
        end
        else
        begin
            qns2_to_w0_data = 2'b11;
        end
    end

    

endmodule