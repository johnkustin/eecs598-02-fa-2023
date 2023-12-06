// up(n0) INPUT
`define UP_W 32
`define R_UP 28

// u0(n0) INTER
`define U0_W 3
`define R_U0 0

// u(n) INTER
`define U_W 32
`define R_U 31

// yp(n0) INTER
`define YP_W 32
`define R_YP 29

// y0(n0) OUTPUT
`define Y0_W 4
`define R_Y0 0

// u1(n) INTER
`define U1_W 32
`define R_U1 31

// y(n) INTER
`define Y_W 32
`define R_Y 31

// eh(n) INTER
`define EH_W 32 // NOTE: SHOULD BE THE SAME AS DH, E
`define R_EH 31

// ep(n0) INPUT
`define EP_W 32
`define R_EP 26


`define E0_W 8
`define R_E0 0// this is the qns4 output

// dh(n) INTER
`define DH_W 32
`define R_DH 31

// W
`define W_COEFF_W 32
`define R_W_COEFF 31
`define W_N 32


// QNS
`define QNS_LEVEL_1 2*(2**`R_UP)
`define QNS_LEVEL_2 2**(`R_W_COEFF-5) // (1/32 * 2^(R_W_COEFF))
`define QNS_LEVEL_3 4
`define QNS_LEVEL_4 10*(2**`R_EP)
`define QNS_OUT_W 3

// QNS4 TO FINAL OUT
`define QNS4_FINAL_OUT_1 5
`define QNS4_FINAL_OUT_3 15

// LMS
`define LMS_LUT_OUT_W 13
`define R_LMS_LUT_OUT 5
`define LMS_LUT_IN_W 8
`define R_LMS_LUT_IN 4
`define MU 858993459
`define OFFSET 21474836

// LPD1
`define AAF_W 32
`define R_AAF 36

// W_top
`define W0_COEFF_W 8
`define R_W0_COEFF 6
`define W0_N 1008
`define W0_LUT_0_VAL 9  // values determined offline, directly have to do with the R_W0_COEFF value
`define W0_LUT_1_VAL 3
`define W0_LUT_2_VAL 3
`define W0_LUT_3_VAL 1
`define W0_LUT_4_VAL -9
`define W0_LUT_5_VAL -3
`define W0_LUT_6_VAL -3
`define W0_LUT_7_VAL -1

//Shat
`define SH_W 32
`define R_SH 30
`define SH_N 32

// testbench
`define DP_W 32
`define R_DP 28

`define SP_W 32
`define R_SP 31