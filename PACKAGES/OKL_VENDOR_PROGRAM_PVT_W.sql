--------------------------------------------------------
--  DDL for Package OKL_VENDOR_PROGRAM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_PROGRAM_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEPRMS.pls 120.7 2006/11/03 11:06:22 sosharma noship $ */
  procedure create_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  DATE
    , p5_a3  DATE
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  NUMBER
    , p_parent_agreement_number  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  NUMBER
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  VARCHAR2
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  VARCHAR2
    , p7_a10 out nocopy  VARCHAR2
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  VARCHAR2
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  VARCHAR2
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  DATE
    , p7_a26 out nocopy  DATE
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  DATE
    , p7_a29 out nocopy  DATE
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  NUMBER
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  DATE
    , p7_a39 out nocopy  DATE
    , p7_a40 out nocopy  DATE
    , p7_a41 out nocopy  DATE
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  VARCHAR2
    , p7_a44 out nocopy  DATE
    , p7_a45 out nocopy  DATE
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  VARCHAR2
    , p7_a48 out nocopy  VARCHAR2
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  VARCHAR2
    , p7_a53 out nocopy  VARCHAR2
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  VARCHAR2
    , p7_a57 out nocopy  NUMBER
    , p7_a58 out nocopy  VARCHAR2
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  NUMBER
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  DATE
    , p7_a63 out nocopy  DATE
    , p7_a64 out nocopy  DATE
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  NUMBER
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  VARCHAR2
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  VARCHAR2
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  VARCHAR2
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  DATE
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  DATE
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  VARCHAR2
    , p7_a90 out nocopy  VARCHAR2
    , p7_a91 out nocopy  VARCHAR2
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  VARCHAR2
    , p7_a94 out nocopy  NUMBER
    , p7_a95 out nocopy  DATE
    , p7_a96 out nocopy  NUMBER
    , p7_a97 out nocopy  NUMBER
    , p7_a98 out nocopy  NUMBER
    , p7_a99 out nocopy  NUMBER
    , p7_a100 out nocopy  VARCHAR2
    , p7_a101 out nocopy  NUMBER
    , p7_a102 out nocopy  DATE
    , p7_a103 out nocopy  NUMBER
    , p7_a104 out nocopy  NUMBER
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  DATE
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  VARCHAR2
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  VARCHAR2
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  DATE
    , p8_a38 out nocopy  NUMBER
    , p8_a39 out nocopy  DATE
    , p8_a40 out nocopy  NUMBER
    , p8_a41 out nocopy  NUMBER
    , p8_a42 out nocopy  NUMBER
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  NUMBER
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  NUMBER
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  NUMBER
    , p8_a49 out nocopy  DATE
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  NUMBER
    , p8_a52 out nocopy  NUMBER
    , p8_a53 out nocopy  DATE
    , p8_a54 out nocopy  DATE
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  VARCHAR2
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  DATE
    , p8_a60 out nocopy  VARCHAR2
    , p8_a61 out nocopy  VARCHAR2
    , p8_a62 out nocopy  VARCHAR2
    , p8_a63 out nocopy  VARCHAR2
    , p8_a64 out nocopy  VARCHAR2
    , p8_a65 out nocopy  VARCHAR2
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  NUMBER
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  NUMBER
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  NUMBER
    , p8_a76 out nocopy  NUMBER
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  DATE
    , p8_a79 out nocopy  DATE
    , p8_a80 out nocopy  NUMBER
    , p8_a81 out nocopy  VARCHAR2
    , p8_a82 out nocopy  VARCHAR
  );
  procedure update_program(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  DATE
    , p5_a3  DATE
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  NUMBER
    , p5_a11  NUMBER
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  NUMBER
    , p_program_id  NUMBER
    , p_parent_agreement_id  NUMBER
  );
end okl_vendor_program_pvt_w;

/
