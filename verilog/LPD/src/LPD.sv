module LPD #(parameter IN_W = 3, R_IN = 0, AAF_W = 32, R_AAF = 36, OUT_W = 32, R_OUT = 31)
(
    input                           clock,
    input                           reset,
    input logic                     valid_in,
    input logic signed [IN_W-1:0]   data_in,
    output logic                    valid_out,
    output logic signed [OUT_W-1:0] data_out
);

    localparam logic signed [31:0] AAF [56] [32] = '{
                                            '{32'h0,32'h0,32'h0,32'h0,32'h0,32'h0,32'h0,32'h0,32'h0,32'h456a,32'hfffe4830,32'h2308a,32'h17e43,32'hc604,32'h6b4a,32'h467d,32'h38bf,32'h3388,32'h311d,32'h2f53,32'h2d77,32'h2b3e,32'h289f,32'h258d,32'h2214,32'h1e2e,32'h19eb,32'h1548,32'h1058,32'hb1b,32'h5a5,32'hfffffff7},
                                            '{32'hfffffa27,32'hfffff438,32'hffffee41,32'hffffe846,32'hffffe25f,32'hffffdc90,32'hffffd6f2,32'hffffd189,32'hffffcc6f,32'hffffc7a4,32'hffffc343,32'hffffbf4d,32'hffffbbd9,32'hffffb8e8,32'hffffb68e,32'hffffb4cb,32'hffffb3b1,32'hffffb33c,32'hffffb37c,32'hffffb46a,32'hffffb613,32'hffffb86d,32'hffffbb81,32'hffffbf43,32'hffffc3b8,32'hffffc8d0,32'hffffce8d,32'hffffd4db,32'hffffdbb9,32'hffffe311,32'hffffeade,32'hfffff306},
                                            '{32'hfffffb83,32'h439,32'hd1d,32'h1616,32'h1f0d,32'h2806,32'h309b,32'h3981,32'h40fb,32'h49d5,32'h4fe4,32'h5797,32'h5d7d,32'h6241,32'h67ab,32'h6b59,32'h6da3,32'h7006,32'h716f,32'h70f4,32'h6fb0,32'h6e15,32'h6b49,32'h66d0,32'h6162,32'h5b7b,32'h54d0,32'h4cd1,32'h43a5,32'h39c7,32'h2f94,32'h24de},
                                            '{32'h196b,32'hd2a,32'h71,32'hfffff392,32'hffffe6cd,32'hffffda17,32'hffffcd68,32'hffffc0b2,32'hffffb423,32'hffffa7e8,32'hffff9c4a,32'hffff9171,32'hffff8784,32'hffff7e87,32'hffff768f,32'hffff6f9a,32'hffff69c4,32'hffff6514,32'hffff61ab,32'hffff5f94,32'hffff5ee7,32'hffff5fa8,32'hffff61e6,32'hffff659b,32'hffff6acd,32'hffff716e,32'hffff797f,32'hffff82ea,32'hffff8da9,32'hffff99a0,32'hffffa6c5,32'hffffb4f4},
                                            '{32'hffffc41c,32'hffffd417,32'hffffe4c8,32'hfffff612,32'h7b7,32'h19c9,32'h2bb8,32'h3dfe,32'h4f95,32'h614e,32'h721b,32'h8258,32'h91e5,32'ha015,32'had69,32'hb964,32'hc3ba,32'hccbb,32'hd416,32'hd970,32'hdd21,32'hdefb,32'hdeae,32'hdc60,32'hd841,32'hd203,32'hc9a6,32'hbf6a,32'hb367,32'ha56b,32'h95a0,32'h8449},
                                            '{32'h718d,32'h5d56,32'h47d8,32'h315c,32'h1a24,32'h236,32'hffffe9be,32'hffffd0ff,32'hffffb857,32'hffff9fe7,32'hffff87d9,32'hffff7056,32'hffff59b8,32'hffff443e,32'hffff301e,32'hffff1d6f,32'hffff0c64,32'hfffefd31,32'hfffef01e,32'hfffee546,32'hfffedcc9,32'hfffed6ad,32'hfffed318,32'hfffed21f,32'hfffed3e6,32'hfffed86a,32'hfffedfad,32'hfffee996,32'hfffef622,32'hffff053e,32'hffff16e7,32'hffff2afb},
                                            '{32'hffff4159,32'hffff59d0,32'hffff7422,32'hffff902f,32'hffffad9a,32'hffffcc6b,32'hffffec12,32'hcac,32'h2d92,32'h4eb5,32'h6fb5,32'h901f,32'haff1,32'hce97,32'hebf1,32'h107c5,32'h121a1,32'h13961,32'h14ed3,32'h16184,32'h1716c,32'h17e55,32'h187f7,32'h18e3d,32'h19128,32'h19075,32'h18c28,32'h1844e,32'h178df,32'h169cb,32'h1574d,32'h14177},
                                            '{32'h1285f,32'h10c2a,32'hed2e,32'hcb90,32'ha78c,32'h816a,32'h5995,32'h304a,32'h5db,32'hffffdaa9,32'hffffaf2a,32'hffff83ac,32'hffff5890,32'hffff2e37,32'hffff051e,32'hfffedd9a,32'hfffeb807,32'hfffe94b9,32'hfffe7423,32'hfffe5693,32'hfffe3c59,32'hfffe25ae,32'hfffe12e3,32'hfffe0435,32'hfffdf9dd,32'hfffdf3f1,32'hfffdf297,32'hfffdf5e1,32'hfffdfded,32'hfffe0aaf,32'hfffe1c1d,32'hfffe3219},
                                            '{32'hfffe4c89,32'hfffe6b50,32'hfffe8e28,32'hfffeb4e8,32'hfffedf1b,32'hffff0c9d,32'hffff3ced,32'hffff6fcd,32'hffffa4c3,32'hffffdb4b,32'h1310,32'h4b6a,32'h840b,32'hbc61,32'hf3e0,32'h12a16,32'h15e73,32'h1906e,32'h1bfb1,32'h1eba5,32'h213e9,32'h23815,32'h257b7,32'h2726f,32'h2880b,32'h2982a,32'h2a2a0,32'h2a745,32'h2a5f3,32'h29e80,32'h29101,32'h27d71},
                                            '{32'h263e2,32'h2447d,32'h21f86,32'h1f520,32'h1c5a0,32'h19161,32'h158cd,32'h11c40,32'hdc49,32'h996c,32'h543b,32'hd38,32'hffffc514,32'hffff7c67,32'hffff33d4,32'hfffeebf3,32'hfffea57f,32'hfffe6116,32'hfffe1f5f,32'hfffde0ed,32'hfffda670,32'hfffd7074,32'hfffd3f89,32'hfffd1421,32'hfffceec6,32'hfffccfdd,32'hfffcb7ca,32'hfffca6cd,32'hfffc9d34,32'hfffc9b30,32'hfffca0e2,32'hfffcae57},
                                            '{32'hfffcc384,32'hfffce069,32'hfffd04d0,32'hfffd3093,32'hfffd6350,32'hfffd9cbe,32'hfffddc73,32'hfffe21ed,32'hfffe6cb3,32'hfffebc0c,32'hffff0f78,32'hffff6632,32'hffffbf8b,32'h1abf,32'h76fb,32'hd374,32'h12f68,32'h189ec,32'h1e242,32'h23786,32'h288ee,32'h2d5ba,32'h31d2f,32'h35e83,32'h39921,32'h3cc58,32'h3f7a0,32'h41a7e,32'h4348a,32'h44554,32'h44caa,32'h44a4b},
                                            '{32'h43e1f,32'h4281c,32'h40864,32'h3df01,32'h3ac3d,32'h37066,32'h32bec,32'h2df3e,32'h28b03,32'h22fd3,32'h1ce66,32'h1677d,32'hfbff,32'h8cc4,32'h1ac4,32'hffffa6f4,32'hffff3262,32'hfffebe02,32'hfffe4ae6,32'hfffdda17,32'hfffd6ca8,32'hfffd0391,32'hfffc9fda,32'hfffc4275,32'hfffbec53,32'hfffb9e41,32'hfffb5919,32'hfffb1d96,32'hfffaec67,32'hfffac617,32'hfffaab25,32'hfffa9bfd},
                                            '{32'hfffa98e0,32'hfffaa204,32'hfffab774,32'hfffad938,32'hfffb072d,32'hfffb4108,32'hfffb867f,32'hfffbd705,32'hfffc3227,32'hfffc971c,32'hfffd052f,32'hfffd7b7e,32'hfffdf91c,32'hfffe7d05,32'hffff0625,32'hffff9346,32'h234c,32'hb4e7,32'h146da,32'h1d7d2,32'h26683,32'h2f19f,32'h377ed,32'h3f812,32'h470e8,32'h4e13a,32'h547f1,32'h5a3ff,32'h5f479,32'h6386c,32'h66f26,32'h697f4},
                                            '{32'h6b252,32'h6bdc9,32'h6ba1b,32'h6a70b,32'h684a0,32'h652f2,32'h61242,32'h5c2e2,32'h56567,32'h4fa6d,32'h482bf,32'h3ff40,32'h370fd,32'h2d905,32'h2389e,32'h19114,32'he3d6,32'h324d,32'hffff7e0a,32'hfffec898,32'hfffe1394,32'hfffd6091,32'hfffcb140,32'hfffc072e,32'hfffb63f4,32'hfffac914,32'hfffa3815,32'hfff9b25c,32'hfff9393e,32'hfff8cdfb,32'hfff871b2,32'hfff82568},
                                            '{32'hfff7e9f6,32'hfff7c023,32'hfff7a88c,32'hfff7a399,32'hfff7b19a,32'hfff7d29f,32'hfff806b1,32'hfff84d7e,32'hfff8a6b6,32'hfff911bf,32'hfff98de8,32'hfffa1a4a,32'hfffab5d9,32'hfffb5f5f,32'hfffc1598,32'hfffcd6fb,32'hfffda206,32'hfffe74fe,32'hffff4e26,32'h2b9d,32'h10b80,32'h1ebcb,32'h2ca95,32'h3a5d1,32'h47b8a,32'h549c1,32'h60e8f,32'h6c80c,32'h7747f,32'h81222,32'h89f6d,32'h91ae4},
                                            '{32'h9833e,32'h9d744,32'ha1605,32'ha3e9d,32'ha5076,32'ha4b18,32'ha2e4c,32'h9f9fc,32'h9ae63,32'h94bda,32'h8d2fe,32'h84493,32'h7a1a2,32'h6eb4e,32'h62304,32'h54a4c,32'h462e7,32'h36ea5,32'h26f98,32'h167d9,32'h59ab,32'hffff4756,32'hfffe3349,32'hfffd1fe4,32'hfffc0fa3,32'hfffb04f9,32'hfffa0259,32'hfff90a21,32'hfff81ea8,32'hfff7422f,32'hfff676dd,32'hfff5beb0},
                                            '{32'hfff51b8d,32'hfff48f22,32'hfff41afe,32'hfff3c065,32'hfff3808b,32'hfff35c42,32'hfff35442,32'hfff368e6,32'hfff39a64,32'hfff3e8a2,32'hfff4534a,32'hfff4d9bd,32'hfff57b2c,32'hfff6366c,32'hfff70a34,32'hfff7f4e0,32'hfff8f4b1,32'hfffa079b,32'hfffb2b6e,32'hfffc5dbe,32'hfffd9c0d,32'hfffee3a1,32'h31bb,32'h1836d,32'h2d5cc,32'h425d2,32'h57086,32'h6b2d7,32'h7e9e3,32'h912b7,32'ha2a8f,32'hb2eb1},
                                            '{32'hc1c9b,32'hcf1de,32'hdac59,32'he4a06,32'hec92d,32'hf2849,32'hf662c,32'hf81d1,32'hf7a9e,32'hf502c,32'hf0279,32'he91c3,32'hdfea7,32'hd49fa,32'hc74fc,32'hb8127,32'ha704b,32'h9446f,32'h7fff9,32'h6a572,32'h537b1,32'h3b9b2,32'h22eb1,32'h99f9,32'hfffeff0c,32'hfffd617c,32'hfffbc4ec,32'hfffa2d03,32'hfff89d73,32'hfff719de,32'hfff5a5dc,32'hfff444e0},
                                            '{32'hfff2fa53,32'hfff1c958,32'hfff0b501,32'hffefc00b,32'hffeeed13,32'hffee3e4f,32'hffedb5c4,32'hffed5517,32'hffed1da4,32'hffed105e,32'hffed2deb,32'hffed7682,32'hffedea10,32'hffee8800,32'hffef4f7c,32'hfff03f35,32'hfff1558a,32'hfff29070,32'hfff3ed97,32'hfff56a44,32'hfff70384,32'hfff8b5fd,32'hfffa7e2e,32'hfffc5846,32'hfffe4051,32'h3219,32'h22961,32'h421b5,32'h616ab,32'h803bc,32'h9e47c,32'hbb47b},
                                            '{32'hd6f73,32'hf1128,32'h1095a6,32'h11f91c,32'h133805,32'h144f17,32'h153b69,32'h15fa55,32'h1689ad,32'h16e791,32'h17129d,32'h1709cd,32'h16cca6,32'h165b05,32'h15b556,32'h14dc6c,32'h13d1a0,32'h1296af,32'h112ddd,32'hf99c6,32'hddd84,32'hbfc87,32'h9faa9,32'h7dc0d,32'h5a530,32'h35acf,32'h101e3,32'hfffe9f8a,32'hfffc391a,32'hfff9d3ef,32'hfff77587,32'hfff52349},
                                            '{32'hfff2e2b0,32'hfff0b8f9,32'hffeeab62,32'hffecbedb,32'hffeaf833,32'hffe95bd7,32'hffe7edf8,32'hffe6b25c,32'hffe5ac6f,32'hffe4df19,32'hffe44ce6,32'hffe3f7c5,32'hffe3e140,32'hffe40a3c,32'hffe47328,32'hffe51bcf,32'hffe6037a,32'hffe728d2,32'hffe88a08,32'hffea24a2,32'hffebf5b5,32'hffedf9c0,32'hfff02cd6,32'hfff28a7e,32'hfff50de8,32'hfff7b1c4,32'hfffa708b,32'hfffd4443,32'h26cf,32'h311ca,32'h5feb9,32'h8e6f4},
                                            '{32'hbc3e1,32'he8ed5,32'h11414e,32'h13d4da,32'h16434b,32'h1886a4,32'h1a994b,32'h1c75ec,32'h1e17b5,32'h1f7a35,32'h209990,32'h217260,32'h2201f0,32'h22460d,32'h223d41,32'h21e6ad,32'h21422c,32'h205038,32'h1f1218,32'h1d89a9,32'h1bb985,32'h19a4e6,32'h174fb7,32'h14be75,32'h11f63e,32'hefcb1,32'hbd7fc,32'h88eb0,32'h527db,32'h1aaca,32'hfffe1f2d,32'hfffa8cd3},
                                            '{32'hfff6fbd2,32'hfff3742e,32'hffeffe13,32'hffeca186,32'hffe9667d,32'hffe654a9,32'hffe3738a,32'hffe0ca32,32'hffde5f62,32'hffdc394a,32'hffda5dad,32'hffd8d19b,32'hffd79999,32'hffd6b968,32'hffd63421,32'hffd60c02,32'hffd64295,32'hffd6d87b,32'hffd7cd9a,32'hffd920e5,32'hffdad08d,32'hffdcd9dc,32'hffdf3957,32'hffe1eaa1,32'hffe4e8b2,32'hffe82da7,32'hffebb306,32'hffef7195,32'hfff3619a,32'hfff77abd,32'hfffbb441,32'h4f0},
                                            '{32'h4635b,32'h8c5bf,32'hd2244,32'h116eec,32'h15a1d4,32'h19b11c,32'h1d932a,32'h213e99,32'h24aa74,32'h27ce26,32'h2aa1b4,32'h2d1da9,32'h2f3b58,32'h30f4b9,32'h3244a8,32'h3326ce,32'h3397d1,32'h339534,32'h331d8f,32'h323069,32'h30ce5f,32'h2ef90e,32'h2cb329,32'h2a0057,32'h26e557,32'h2367cf,32'h1f8e68,32'h1b6099,32'h16e6ce,32'h122a1a,32'hd3464,32'h81015},
                                            '{32'h2c842,32'hfffd6859,32'hfff7fc3b,32'hfff28ffa,32'hffed2fdf,32'hffe7e830,32'hffe2c53f,32'hffddd318,32'hffd91d9a,32'hffd4b02e,32'hffd095dc,32'hffccd8f7,32'hffc9833f,32'hffc69d99,32'hffc4301e,32'hffc241df,32'hffc0d900,32'hffbffa75,32'hffbfaa23,32'hffbfeaa9,32'hffc0bd7d,32'hffc222bd,32'hffc41953,32'hffc69ec7,32'hffc9af74,32'hffcd4655,32'hffd15d38,32'hffd5eca8,32'hffdaec18,32'hffe051cb,32'hffe61313,32'hffec2439},
                                            '{32'hfff278bd,32'hfff90348,32'hffffb5eb,32'h68219,32'hd58e9,32'h142b0d,32'h1ae922,32'h2183a4,32'h27eb38,32'h2e10a3,32'h33e521,32'h395a51,32'h3e6288,32'h42f0c4,32'h46f8f5,32'h4a6ff8,32'h4d4bd3,32'h4f83a8,32'h510ffb,32'h51ea9f,32'h520ee7,32'h517999,32'h502920,32'h4e1d64,32'h4b5806,32'h47dc32,32'h43aec9,32'h3ed631,32'h395a80,32'h334537,32'h2ca16b,32'h257b81},
                                            '{32'h1de148,32'h15e1ad,32'hd8cd5,32'h4f3ce,32'hfffc2897,32'hfff33dd3,32'hffea46d5,32'hffe15743,32'hffd88324,32'hffcfde7f,32'hffc77d68,32'hffbf73a2,32'hffb7d4a2,32'hffb0b33d,32'hffaa219d,32'hffa430fa,32'hff9ef19e,32'hff9a7289,32'hff96c17d,32'hff93eab8,32'hff91f8fc,32'hff90f541,32'hff90e6d7,32'hff91d314,32'hff93bd7c,32'hff96a783,32'hff9a90a9,32'hff9f7658,32'hffa55401,32'hffac22f7,32'hffb3daa1,32'hffbc7063},
                                            '{32'hffc5d7ca,32'hffd00282,32'hffdae094,32'hffe66058,32'hfff26ebd,32'hfffef743,32'hbe44e,32'h191f23,32'h26903d,32'h341f4d,32'h41b3a1,32'h4f341e,32'h5c879d,32'h699503,32'h76438d,32'h827ae0,32'h8e2368,32'h992660,32'ha36e26,32'hace648,32'hb57bd2,32'hbd1d56,32'hc3bb3c,32'hc947ad,32'hcdb6f3,32'hd0ff5d,32'hd31985,32'hd40034,32'hd3b0a5,32'hd22a5b,32'hcf6f55,32'hcb83e2},
                                            '{32'hc66ec8,32'hc0390c,32'hb8ee15,32'hb09b67,32'ha750b4,32'h9d1f97,32'h921ba2,32'h865a02,32'h79f188,32'h6cfa54,32'h5f8dc8,32'h51c62c,32'h43bea6,32'h3592d5,32'h275ec6,32'h193e8b,32'hb4e33,32'hfffda955,32'hfff06b13,32'hffe3ada9,32'hffd78a66,32'hffcc1941,32'hffc170e4,32'hffb7a63d,32'hffaecc7e,32'hffa6f4d3,32'hffa02e59,32'hff9a85da,32'hff9605d6,32'hff92b63f,32'hff909c95,32'hff8fbbad},
                                            '{32'hff9013c9,32'hff91a277,32'hff9462bc,32'hff984ce9,32'hff9d56df,32'hffa373f0,32'hffaa9529,32'hffb2a93d,32'hffbb9cdb,32'hffc55aa9,32'hffcfcb9a,32'hffdad6f4,32'hffe662ad,32'hfff2537f,32'hfffe8d46,32'haf312,32'h176796,32'h23cd3b,32'h300684,32'h3bf62e,32'h477f99,32'h5286da,32'h5cf128,32'h66a4e9,32'h6f8a1d,32'h778a63,32'h7e915d,32'h848cb1,32'h896c68,32'h8d22d9,32'h8fa502,32'h90ea7a},
                                            '{32'h90edac,32'h8fabbe,32'h8d24c6,32'h895ba5,32'h84562f,32'h7e1cf5,32'h76bb66,32'h6e3f89,32'h64ba10,32'h5a3e0f,32'h4ee0f9,32'h42ba4e,32'h35e394,32'h2877f9,32'h1a9440,32'hc5656,32'hfffddd49,32'hffef48cb,32'hffe0b922,32'hffd24eaf,32'hffc429d6,32'hffb66a8a,32'hffa93030,32'hff9c992e,32'hff90c2c9,32'hff85c8c6,32'hff7bc547,32'hff72d068,32'hff6b0033,32'hff646840,32'hff5f19ac,32'hff5b22c4},
                                            '{32'hff588f10,32'hff576705,32'hff57b019,32'hff596c86,32'hff5c9b69,32'hff613898,32'hff673ccb,32'hff6e9d78,32'hff774d19,32'hff813b13,32'hff8c5402,32'hff9881b1,32'hffa5ab74,32'hffb3b62c,32'hffc284ac,32'hffd1f7c9,32'hffe1eec4,32'hfff2476d,32'h2de89,32'h138ffd,32'h24374b,32'h34afa4,32'h44d477,32'h54818e,32'h63938d,32'h71e812,32'h7f5e34,32'h8bd69a,32'h9733f9,32'ha15b27,32'haa3385,32'hb1a715},
                                            '{32'hb7a2d5,32'hbc16be,32'hbef62a,32'hc037b9,32'hbfd5a0,32'hbdcd8b,32'hba20df,32'hb4d488,32'hadf11d,32'ha582ba,32'h9b9908,32'h9046f8,32'h83a2d0,32'h75c5cd,32'h66cc26,32'h56d49e,32'h46007e,32'h347315,32'h2251a0,32'hfc2da,32'hfffceec3,32'hffe9fe2e,32'hffd71a88,32'hffc46d62,32'hffb2202e,32'hffa05bca,32'hff8f4846,32'hff7f0c61,32'hff6fcd5e,32'hff61ae86,32'hff54d0fa,32'hff495343},
                                            '{32'hff3f5136,32'hff36e380,32'hff301f97,32'hff2b1760,32'hff27d924,32'hff266f44,32'hff26e042,32'hff292e86,32'hff2d5877,32'hff335851,32'hff3b244d,32'hff44ae91,32'hff4fe568,32'hff5cb337,32'hff6afed1,32'hff7aab86,32'hff8b997b,32'hff9da5c4,32'hffb0aad7,32'hffc480a9,32'hffd8fd3a,32'hffedf4b0,32'h339ec,32'h189ec0,32'h2df479,32'h430c16,32'h57b6e7,32'h6bc6b9,32'h7f0e73,32'h91624a,32'ha29854,32'hb288b8},
                                            '{32'hc10e38,32'hce0652,32'hd951cf,32'he2d4d1,32'hea7747,32'hf02504,32'hf3ce13,32'hf566bf,32'hf4e7d7,32'hf24ea5,32'hed9d23,32'he6d9c6,32'hde0fc3,32'hd34eb4,32'hc6aaba,32'hb83c25,32'ha81f7b,32'h96750c,32'h8360e1,32'h6f0a4c,32'h599bba,32'h43423a,32'h2c2d40,32'h148e23,32'hfffc97cb,32'hffe47e30,32'hffcc7608,32'hffb4b426,32'hff9d6d36,32'hff86d525,32'hff711ece,32'hff5c7b60},
                                            '{32'hff491a1f,32'hff3727c5,32'hff26ce4f,32'hff18346e,32'hff0b7d54,32'hff00c837,32'hfef83035,32'hfef1cbe0,32'hfeedad2e,32'hfeebe128,32'hfeec6fe5,32'hfeef5c4e,32'hfef4a432,32'hfefc4016,32'hff062370,32'hff123c89,32'hff2074c1,32'hff30b091,32'hff42cff3,32'hff56ae64,32'hff6c2367,32'hff8302a0,32'hff9b1c65,32'hffb43dea,32'hffce31df,32'hffe8c0ad,32'h3b126,32'h1ec8c6,32'h39cc5e,32'h548074,32'h6ea9e9,32'h880e4b},
                                            '{32'ha07491,32'hb7a55c,32'hcd6bb1,32'he1953a,32'hf3f2e9,32'h1045940,32'h112a0d4,32'h11ea68a,32'h1284c16,32'h12f7815,32'h1341684,32'h13618b5,32'h13575c2,32'h1322a66,32'h12c3941,32'h123aab6,32'h1188d09,32'h10af422,32'hfaf98b,32'he8bc34,32'hd4603c,32'hbe0e9e,32'ha5f4f8,32'h8c4514,32'h71349f,32'h54fc95,32'h37d8f6,32'h1a081b,32'hfffbca57,32'hffdd614c,32'hffbf0f80,32'hffa117a1},
                                            '{32'hff83bc28,32'hff673e95,32'hff4bdefe,32'hff31db68,32'hff196f5c,32'hff02d331,32'hfeee3bbf,32'hfedbd9b5,32'hfecbd950,32'hfebe61cc,32'hfeb3952e,32'hfeab8fbe,32'hfea667f7,32'hfea42e1c,32'hfea4ec2d,32'hfea8a5a1,32'hfeaf5781,32'hfeb8f832,32'hfec577b2,32'hfed4bf7b,32'hfee6b2d8,32'hfefb2ef5,32'hff120b43,32'hff2b1998,32'hff4626c9,32'hff62fad5,32'hff81598a,32'hffa102d3,32'hffc1b36a,32'hffe32543,32'h51045,32'h272ab0},
                                            '{32'h492a00,32'h6ac34e,32'h8bac26,32'hab9b04,32'hca481d,32'he76ddd,32'h102c9a4,32'h11c1c31,32'h1332a75,32'h147bdcf,32'h159a4d3,32'h168b380,32'h174c3e5,32'h17db64c,32'h18371b1,32'h185e3ea,32'h18501f1,32'h180c7ef,32'h1793968,32'h16e6134,32'h160517c,32'h14f238a,32'h13af7c1,32'h123f53e,32'h10a49ad,32'hee28cf,32'hcfcc3c,32'haf72c0,32'h8d6002,32'h69dbda,32'h4531dd,32'h1fb08a},
                                            '{32'hfff9a8de,32'hffd36d76,32'hffad51fd,32'hff87aa59,32'hff62ca16,32'hff3f0382,32'hff1ca729,32'hfefc02f5,32'hfedd619c,32'hfec109d6,32'hfea73dee,32'hfe903aea,32'hfe7c3834,32'hfe6b66e9,32'hfe5df190,32'hfe53fb7d,32'hfe4da0b2,32'hfe4af552,32'hfe4c05a6,32'hfe50d5c9,32'hfe5961ad,32'hfe659cf9,32'hfe75733e,32'hfe88c7df,32'hfe9f7682,32'hfeb95313,32'hfed62a48,32'hfef5c1e8,32'hff17d95c,32'hff3c2a03,32'hff6267fc,32'hff8a4289},
                                            '{32'hffb364f1,32'hffdd7707,32'h81dfb,32'h32fd15,32'h5db68f,32'h87ec36,32'hb14075,32'hd956e4,32'hffd55b,32'h124646c,32'h146b06e,32'h1666a10,32'h1834726,32'h19d0347,32'h1b36072,32'h1c627a9,32'h1d52967,32'h1e03e1a,32'h1e74696,32'h1ea2c56,32'h1e8e1cb,32'h1e36270,32'h1d9b30f,32'h1cbe198,32'h1ba0538,32'h1a43e16,32'h18ab542,32'h16d9c39,32'h14d2cb9,32'h129a82c,32'h1035746,32'hda8944},
                                            '{32'haf9382,32'h82d099,32'h549fc8,32'h256404,32'hfff58355,32'hffc565c1,32'hff9574a2,32'hff66199d,32'hff37bdd5,32'hff0ac8db,32'hfedfa002,32'hfeb6a541,32'hfe903687,32'hfe6cacbf,32'hfe4c5b27,32'hfe2f8e5e,32'hfe168bf5,32'hfe019188,32'hfdf0d454,32'hfde48097,32'hfddcb93e,32'hfdd9975e,32'hfddb2a23,32'hfde1765a,32'hfdec768c,32'hfdfc1ade,32'hfe104930,32'hfe28dd27,32'hfe45a89b,32'hfe6673ab,32'hfe8afd6f,32'hfeb2fc37},
                                            '{32'hfede1e40,32'hff0c0a50,32'hff3c6078,32'hff6ebabe,32'hffa2ae1d,32'hffd7cb28,32'hd9f4d,32'h43b571,32'h799734,32'haecdc3,32'he2e2fc,32'h1156264,32'h145da1e,32'h173dc00,32'h19efe82,32'h1c6ddb0,32'h1eb1c0a,32'h20b635f,32'h22765a4,32'h23edd90,32'h2518f67,32'h25f496e,32'h267e496,32'h26b44aa,32'h26958d3,32'h2621bb1,32'h255939b,32'h243d27b,32'h22cf5ee,32'h21126ed,32'h1f099aa,32'h1cb8d03},
                                            '{32'h1a24a4b,32'h1752487,32'h14477e8,32'h110a8f6,32'hda23eb,32'ha15b9e,32'h66c8c5,32'h2ae8d8,32'hffee3d22,32'hffb14977,32'hff74935e,32'hff38a0b4,32'hfefdf6ac,32'hfec51890,32'hfe8e86bf,32'hfe5abd54,32'hfe2a3353,32'hfdfd596a,32'hfdd49903,32'hfdb0533d,32'hfd90e02d,32'hfd768dca,32'hfd619f85,32'hfd524d5a,32'hfd48c363,32'hfd45214f,32'hfd477a23,32'hfd4fd3c7,32'hfd5e272b,32'hfd725fe4,32'hfd8c5c87,32'hfdabeebc},
                                            '{32'hfdd0db93,32'hfdfadbe0,32'hfe299ce2,32'hfe5cc0a2,32'hfe93df13,32'hfece8671,32'hff0c3c84,32'hff4c7f5d,32'hff8ec689,32'hffd28431,32'h172621,32'h5c1730,32'ha0c05a,32'he48a33,32'h126de0a,32'h1672742,32'h1a4d4a9,32'h1df59ac,32'h2162fa4,32'h248d6e6,32'h276d81f,32'h29fc53c,32'h2c33a8e,32'h2e0df90,32'h2f867ee,32'h3099420,32'h3143223,32'h3181de1,32'h31541d3,32'h30b971b,32'h2fb25c6,32'h2e404c1},
                                            '{32'h2c659f2,32'h2a259c7,32'h2784706,32'h2487249,32'h2133983,32'h1d90716,32'h19a5131,32'h15798cd,32'h11168bb,32'hc8545b,32'h7cf6b2,32'h2ff0e6,32'hffe1e903,32'hff938885,32'hff457b1c,32'hfef86cf0,32'hfead096a,32'hfe63f99e,32'hfe1de2d3,32'hfddb64fd,32'hfd9d1995,32'hfd6391e8,32'hfd2f560d,32'hfd00e38a,32'hfcd8ac27,32'hfcb714d3,32'hfc9c74eb,32'hfc891501,32'hfc7d2e7b,32'hfc78eab7,32'hfc7c629c,32'hfc879e58},
                                            '{32'hfc9a9529,32'hfcb52d23,32'hfcd73b9e,32'hfd0084ef,32'hfd30bd51,32'hfd67890f,32'hfda47d4d,32'hfde720e0,32'hfe2eecfd,32'hfe7b4e9f,32'hfecba760,32'hff1f4ef9,32'hff759468,32'hffcdbf81,32'h271274,32'h80cb56,32'hda25cf,32'h1325c9c,32'h188ab74,32'h1dc5092,32'h22c8e7e,32'h278ad89,32'h2bffd9b,32'h301d7a8,32'h33d9f4f,32'h372c410,32'h3a0c2d9,32'h3c72720,32'h3e58c28,32'h3fb9dc0,32'h4091957,32'h40dce9f},
                                            '{32'h409a032,32'h3fc83c5,32'h3e682a4,32'h3c7b9ab,32'h3a05944,32'h370a4f3,32'h338f337,32'h2f9acc9,32'h2b34bf1,32'h2665b7a,32'h21375f8,32'h1bb444a,32'h15e7c62,32'hfddfd3,32'h9a3a6b,32'h346038,32'hffcd2c17,32'hff657dd3,32'hfefe383b,32'hfe983f19,32'hfe34759c,32'hfdd3bc01,32'hfd76edd5,32'hfd1ee019,32'hfccc5f54,32'hfc802d8d,32'hfc3b00fc,32'hfbfd81e4,32'hfbc84942,32'hfb9bdf72,32'hfb78baae,32'hfb5f3ded},
                                            '{32'hfb4fb81d,32'hfb4a62b5,32'hfb4f61b6,32'hfb5ec29c,32'hfb787c54,32'hfb9c6f39,32'hfbca64a5,32'hfc020fd7,32'hfc430db9,32'hfc8ce625,32'hfcdf0c44,32'hfd38dfdd,32'hfd99ae4c,32'hfe00b3ea,32'hfe6d1da3,32'hfede0a87,32'hff528db9,32'hffc9b019,32'h427276,32'hbbcf82,32'h134be32,32'h1ac33ca,32'h2212637,32'h2928e28,32'h2ff6990,32'h366bdc3,32'h3c799ca,32'h421184a,32'h47261cc,32'h4baaea0,32'h4f948e1,32'h52d8de7},
                                            '{32'h556f005,32'h574f7e5,32'h58745fb,32'h58d9340,32'h587b236,32'h5758f7e,32'h5573284,32'h52cbd5c,32'h4f66ce4,32'h4b49881,32'h467b1e2,32'h41043e8,32'h3aef1eb,32'h34476ad,32'h2d1a30f,32'h2575c25,32'h1d699db,32'h1506505,32'hc5d52f,32'h380e36,32'hffa83e79,32'hff179bf7,32'hfe8761b7,32'hfdf8cd76,32'hfd6d1d00,32'hfce58af2,32'hfc634cbb,32'hfbe78fa0,32'hfb7375ce,32'hfb081447,32'hfaa67036,32'hfa4f7c0f},
                                            '{32'hfa04164d,32'hf9c50647,32'hf992fada,32'hf96e88ce,32'hf9582867,32'hf950355f,32'hf956ec59,32'hf96c6b48,32'hf990afd1,32'hf9c397a2,32'hfa04dff7,32'hfa5425ff,32'hfab0e748,32'hfb1a8266,32'hfb903809,32'hfc112c16,32'hfc9c6752,32'hfd30d905,32'hfdcd592a,32'hfe70aa7c,32'hff197d01,32'hffc67074,32'h76172c,32'h126f8e8,32'h1d79611,32'h2866aba,32'h331f1f3,32'h3d8a8d1,32'h47911d9,32'h511b839,32'h5a13343,32'h626296b},
                                            '{32'h69f5372,32'h70b7f29,32'h769928a,32'h7b88e66,32'h7f79102,32'h825d80d,32'h842c2c7,32'h84dd3d1,32'h846b306,32'h82d2e6a,32'h8013b04,32'h7c2f57c,32'h772a2dc,32'h710b04b,32'h69db27b,32'h61a64ef,32'h587a98a,32'h4e686eb,32'h4382667,32'h37dd234,32'h2b8f3cb,32'h1eb10a6,32'h115c734,32'h3acc6d,32'hff5be8a7,32'hfe7af2ed,32'hfd99ce40,32'hfcba6619,32'hfbdea937,32'hfb088639,32'hfa39e870,32'hf974b1a2},
                                            '{32'hf8bab7c7,32'hf80dc0a5,32'hf76f7c16,32'hf6e1835b,32'hf665518f,32'hf5fc4384,32'hf5a791bc,32'hf5684efc,32'hf53f646b,32'hf52d8f6f,32'hf5335f3f,32'hf55132e4,32'hf58737c4,32'hf5d5683d,32'hf63b8b03,32'hf6b93282,32'hf74dbd0a,32'hf7f8550d,32'hf8b7f220,32'hf98b5a0c,32'hfa7122ac,32'hfb67b3d0,32'hfc6d49ec,32'hfd7ff8c6,32'hfe9daee0,32'hffc438e8,32'hf145cb,32'h2226acc,32'h3552828,32'h486edbb,32'h5b5201a,32'h6dd1d94},
                                            '{32'h7fc439f,32'h90ff40e,32'ha159a9b,32'hb0ab230,32'hbecca82,32'hcb98d5b,32'hd6ec425,32'he0a5cf1,32'he8a6f8f,32'heed41f1,32'hf314c9f,32'hf553eb6,32'hf580228,32'hf38bf4b,32'hef6e00b,32'he9211e9,32'he0a47e9,32'hd5fbc5d,32'hc92f302,32'hba4b9a4,32'ha962762,32'h9689b73,32'h81dbd82,32'h6b77d4d,32'h5380f4e,32'h3a1e836,32'h1f7bc55,32'h3c7dba,32'hfe735425,32'hfc9f9824,32'hfac4d467,32'hf8e6ba43},
                                            '{32'hf7091a5d,32'hf52fe995,32'hf35f2a39,32'hf19af562,32'hefe767f8,32'hee48a313,32'hecc2c0f8,32'heb59cf7b,32'hea11c826,32'he8ee8910,32'he7f3cdc2,32'he7252802,32'he685f91d,32'he6196b15,32'he5e26a69,32'he5e39fe1,32'he61f6b00,32'he697dc9e,32'he74eb231,32'he845515b,32'he97cc43a,32'heaf5b600,32'hecb0706d,32'heeacd995,32'hf0ea729b,32'hf36856b5,32'hf6253b33,32'hf91f6fd7,32'hfc54e02d,32'hffc31536,32'h367380e,32'h73e14e7},
                                            '{32'hb441ef2,32'hf757495,32'h13cde486,32'h1848f322,32'h1ce1e0a2,32'h2193af6b,32'h26592b34,32'h2b2cf035,32'h3009730a,32'h34e9088c,32'h39c5ee47,32'h3e9a52cd,32'h43605e81,32'h48123c2a,32'h4caa21e4,32'h512259b4,32'h55754a61,32'h599d7fd6,32'h5d95b3a5,32'h6158d4fd,32'h64e2109f,32'h682cd832,32'h6b34e979,32'h6df654c9,32'h706d8359,32'h72973caa,32'h7470abc3,32'h75f76371,32'h7729623e,32'h7805156d,32'h78895ba2,32'h78bbeb81}
                                        };

    localparam NUM_CHAINS   = 56;
    localparam NUM_ACC      = 112;
    localparam CHAIN_W      = 32;
    localparam ACC_W        = AAF_W + $clog2(CHAIN_W); // could potentially go more (or less)
    localparam SHIFT_VAL    = (R_AAF + R_IN) - R_OUT;

    typedef struct {
        logic signed [ACC_W-1:0]    data;
        logic                       valid;
    } acc_t;

    acc_t acc [NUM_ACC-1:0];
    logic signed [ACC_W-1:0] prod [NUM_ACC];
    logic [$clog2(CHAIN_W)-1:0] chain_cnt;


    always_comb
    begin
        for (int i = 0; i < NUM_CHAINS; i = i+1)
        begin
            prod[i] = (data_in * AAF[i][chain_cnt]) >>> SHIFT_VAL;
        end
        for (int i = NUM_CHAINS; i < NUM_ACC; i = i + 1)
        begin
            if (i == NUM_ACC-1 && chain_cnt == CHAIN_W-1)
            begin
                prod[i] = '0;
            end
            else
            begin
                if (chain_cnt == CHAIN_W-1)
                begin
                    prod[i] = (data_in * AAF[NUM_ACC-2-i][CHAIN_W-1]) >>> SHIFT_VAL;
                end
                else
                begin
                    prod[i] = (data_in * AAF[NUM_ACC-1-i][CHAIN_W-2-chain_cnt]) >>> SHIFT_VAL;
                end
            end
        end
    end

    always_ff @(posedge clock)
    begin
        if (reset)
        begin
            chain_cnt   <= '0;
            valid_out   <= 1'b0;
            data_out    <= '0;
            for (int i = 0; i < NUM_ACC; i = i + 1)
            begin
                acc[i].data     <= '0;
                acc[i].valid    <= 1'b0;
            end
        end
        else
        begin
            if (valid_in)
            begin
                if (chain_cnt == CHAIN_W-1)
                begin
                    chain_cnt   <= '0;
                    // output is the current last accumulator
                    valid_out   <= acc[NUM_ACC-1].valid;
                    data_out    <= acc[NUM_ACC-1].data + prod[NUM_ACC-1]; // assuming this won't clip for now
                    // shift the accumulators
                    for (int i = 1; i < NUM_ACC; i = i + 1)
                    begin
                        acc[i].data             <= acc[i-1].data + prod[i-1];
                        acc[i].valid            <= acc[i-1].valid;
                    end
                    acc[0].data             <= '0;
                    acc[0].valid            <= 1'b0;
                end
                else
                begin
                    acc[0].valid    <= 1'b1;
                    valid_out       <= 1'b0;
                    chain_cnt       <= chain_cnt + 1;
                    for (int i = 0; i < NUM_ACC; i = i + 1)
                    begin
                        acc[i].data <= acc[i].data + prod[i];
                    end
                end
            end
        end
    end
endmodule