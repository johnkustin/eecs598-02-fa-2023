// up(n0) INPUT
`define UP_W 32
`define R_UP 28

// u0(n0) INTER
`define U0_W 3
`define R_U0 0

// u(n) INTER
`define U_W
`define R_U

// yq(n0) INTER
`define YQ_W
`define R_YQ

// yp(n0) INTER
`define YP_W 32
`define R_YP 29

// y0(n0) OUTPUT
`define Y0_W 4
`define R_Y0 0

// u1(n) INTER
`define U1_W
`define R_U1

// y(n) INTER
`define Y_W
`define R_Y

// eh(n) INTER
`define EH_W // NOTE: SHOULD BE THE SAME AS DH
`define R_EH

// ep(n0) INPUT
`define EP_W
`define R_EP

// e(n) INTER
`define E_N
`define R_E

`define E0_W
`define R_E0 // this is the qns4 output

// dh(n) INTER
`define DH_N
`define R_DH

// W
`define W_COEFF_W 32
`define R_W_COEFF 31
`define W_N 32


// QNS
`define QNS_LEVEL_1 2*(2**`R_UP)
`define QNS_LEVEL_2 2**(`R_W_COEFF-5) // (1/32 * 2^(R_W_COEFF))
`define QNS_LEVEL_3 4
`define QNS_LEVEL_4
`define QNS_OUT_W 3

// QNS4 TO FINAL OUT
`define QNS4_FINAL_OUT_neg_3
`define QNS4_FINAL_OUT_neg_1
`define QNS4_FINAL_OUT_1 
`define QNS4_FINAL_OUT_3

// LMS
`define LMS_LUT_OUT_W
`define R_LMS_LUT_OUT
`define LMS_LUT_IN_W
`define R_LMS_LUT_IN
`define MU
`define OFFSET

// LPD1
`define AAF_W
`define R_AAF

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
`define SH_W
`define R_SH
`define SH_N

