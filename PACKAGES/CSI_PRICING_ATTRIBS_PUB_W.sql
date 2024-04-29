--------------------------------------------------------
--  DDL for Package CSI_PRICING_ATTRIBS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_PRICING_ATTRIBS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csippaws.pls 120.11 2008/01/15 03:34:10 devijay ship $ */
  procedure get_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_DATE_TABLE
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a78 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a79 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a80 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a83 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a84 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a93 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a94 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a95 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a96 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a97 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a99 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a100 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a101 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a102 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a103 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a104 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a106 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a107 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a108 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a109 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a110 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a111 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a112 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a113 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a114 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a115 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a116 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a117 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a118 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a119 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a120 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a121 out nocopy JTF_NUMBER_TABLE
    , p6_a122 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
  );
  procedure create_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_DATE_TABLE
    , p4_a3 in out nocopy JTF_DATE_TABLE
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a121 in out nocopy JTF_NUMBER_TABLE
    , p4_a122 in out nocopy JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_VARCHAR2_TABLE_200
    , p4_a72 JTF_VARCHAR2_TABLE_200
    , p4_a73 JTF_VARCHAR2_TABLE_200
    , p4_a74 JTF_VARCHAR2_TABLE_200
    , p4_a75 JTF_VARCHAR2_TABLE_200
    , p4_a76 JTF_VARCHAR2_TABLE_200
    , p4_a77 JTF_VARCHAR2_TABLE_200
    , p4_a78 JTF_VARCHAR2_TABLE_200
    , p4_a79 JTF_VARCHAR2_TABLE_200
    , p4_a80 JTF_VARCHAR2_TABLE_200
    , p4_a81 JTF_VARCHAR2_TABLE_200
    , p4_a82 JTF_VARCHAR2_TABLE_200
    , p4_a83 JTF_VARCHAR2_TABLE_200
    , p4_a84 JTF_VARCHAR2_TABLE_200
    , p4_a85 JTF_VARCHAR2_TABLE_200
    , p4_a86 JTF_VARCHAR2_TABLE_200
    , p4_a87 JTF_VARCHAR2_TABLE_200
    , p4_a88 JTF_VARCHAR2_TABLE_200
    , p4_a89 JTF_VARCHAR2_TABLE_200
    , p4_a90 JTF_VARCHAR2_TABLE_200
    , p4_a91 JTF_VARCHAR2_TABLE_200
    , p4_a92 JTF_VARCHAR2_TABLE_200
    , p4_a93 JTF_VARCHAR2_TABLE_200
    , p4_a94 JTF_VARCHAR2_TABLE_200
    , p4_a95 JTF_VARCHAR2_TABLE_200
    , p4_a96 JTF_VARCHAR2_TABLE_200
    , p4_a97 JTF_VARCHAR2_TABLE_200
    , p4_a98 JTF_VARCHAR2_TABLE_200
    , p4_a99 JTF_VARCHAR2_TABLE_200
    , p4_a100 JTF_VARCHAR2_TABLE_200
    , p4_a101 JTF_VARCHAR2_TABLE_200
    , p4_a102 JTF_VARCHAR2_TABLE_200
    , p4_a103 JTF_VARCHAR2_TABLE_200
    , p4_a104 JTF_VARCHAR2_TABLE_200
    , p4_a105 JTF_VARCHAR2_TABLE_100
    , p4_a106 JTF_VARCHAR2_TABLE_200
    , p4_a107 JTF_VARCHAR2_TABLE_200
    , p4_a108 JTF_VARCHAR2_TABLE_200
    , p4_a109 JTF_VARCHAR2_TABLE_200
    , p4_a110 JTF_VARCHAR2_TABLE_200
    , p4_a111 JTF_VARCHAR2_TABLE_200
    , p4_a112 JTF_VARCHAR2_TABLE_200
    , p4_a113 JTF_VARCHAR2_TABLE_200
    , p4_a114 JTF_VARCHAR2_TABLE_200
    , p4_a115 JTF_VARCHAR2_TABLE_200
    , p4_a116 JTF_VARCHAR2_TABLE_200
    , p4_a117 JTF_VARCHAR2_TABLE_200
    , p4_a118 JTF_VARCHAR2_TABLE_200
    , p4_a119 JTF_VARCHAR2_TABLE_200
    , p4_a120 JTF_VARCHAR2_TABLE_200
    , p4_a121 JTF_NUMBER_TABLE
    , p4_a122 JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure expire_pricing_attribs(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_DATE_TABLE
    , p4_a3 JTF_DATE_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_200
    , p4_a8 JTF_VARCHAR2_TABLE_200
    , p4_a9 JTF_VARCHAR2_TABLE_200
    , p4_a10 JTF_VARCHAR2_TABLE_200
    , p4_a11 JTF_VARCHAR2_TABLE_200
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_200
    , p4_a14 JTF_VARCHAR2_TABLE_200
    , p4_a15 JTF_VARCHAR2_TABLE_200
    , p4_a16 JTF_VARCHAR2_TABLE_200
    , p4_a17 JTF_VARCHAR2_TABLE_200
    , p4_a18 JTF_VARCHAR2_TABLE_200
    , p4_a19 JTF_VARCHAR2_TABLE_200
    , p4_a20 JTF_VARCHAR2_TABLE_200
    , p4_a21 JTF_VARCHAR2_TABLE_200
    , p4_a22 JTF_VARCHAR2_TABLE_200
    , p4_a23 JTF_VARCHAR2_TABLE_200
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_200
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_200
    , p4_a46 JTF_VARCHAR2_TABLE_200
    , p4_a47 JTF_VARCHAR2_TABLE_200
    , p4_a48 JTF_VARCHAR2_TABLE_200
    , p4_a49 JTF_VARCHAR2_TABLE_200
    , p4_a50 JTF_VARCHAR2_TABLE_200
    , p4_a51 JTF_VARCHAR2_TABLE_200
    , p4_a52 JTF_VARCHAR2_TABLE_200
    , p4_a53 JTF_VARCHAR2_TABLE_200
    , p4_a54 JTF_VARCHAR2_TABLE_200
    , p4_a55 JTF_VARCHAR2_TABLE_200
    , p4_a56 JTF_VARCHAR2_TABLE_200
    , p4_a57 JTF_VARCHAR2_TABLE_200
    , p4_a58 JTF_VARCHAR2_TABLE_200
    , p4_a59 JTF_VARCHAR2_TABLE_200
    , p4_a60 JTF_VARCHAR2_TABLE_200
    , p4_a61 JTF_VARCHAR2_TABLE_200
    , p4_a62 JTF_VARCHAR2_TABLE_200
    , p4_a63 JTF_VARCHAR2_TABLE_200
    , p4_a64 JTF_VARCHAR2_TABLE_200
    , p4_a65 JTF_VARCHAR2_TABLE_200
    , p4_a66 JTF_VARCHAR2_TABLE_200
    , p4_a67 JTF_VARCHAR2_TABLE_200
    , p4_a68 JTF_VARCHAR2_TABLE_200
    , p4_a69 JTF_VARCHAR2_TABLE_200
    , p4_a70 JTF_VARCHAR2_TABLE_200
    , p4_a71 JTF_VARCHAR2_TABLE_200
    , p4_a72 JTF_VARCHAR2_TABLE_200
    , p4_a73 JTF_VARCHAR2_TABLE_200
    , p4_a74 JTF_VARCHAR2_TABLE_200
    , p4_a75 JTF_VARCHAR2_TABLE_200
    , p4_a76 JTF_VARCHAR2_TABLE_200
    , p4_a77 JTF_VARCHAR2_TABLE_200
    , p4_a78 JTF_VARCHAR2_TABLE_200
    , p4_a79 JTF_VARCHAR2_TABLE_200
    , p4_a80 JTF_VARCHAR2_TABLE_200
    , p4_a81 JTF_VARCHAR2_TABLE_200
    , p4_a82 JTF_VARCHAR2_TABLE_200
    , p4_a83 JTF_VARCHAR2_TABLE_200
    , p4_a84 JTF_VARCHAR2_TABLE_200
    , p4_a85 JTF_VARCHAR2_TABLE_200
    , p4_a86 JTF_VARCHAR2_TABLE_200
    , p4_a87 JTF_VARCHAR2_TABLE_200
    , p4_a88 JTF_VARCHAR2_TABLE_200
    , p4_a89 JTF_VARCHAR2_TABLE_200
    , p4_a90 JTF_VARCHAR2_TABLE_200
    , p4_a91 JTF_VARCHAR2_TABLE_200
    , p4_a92 JTF_VARCHAR2_TABLE_200
    , p4_a93 JTF_VARCHAR2_TABLE_200
    , p4_a94 JTF_VARCHAR2_TABLE_200
    , p4_a95 JTF_VARCHAR2_TABLE_200
    , p4_a96 JTF_VARCHAR2_TABLE_200
    , p4_a97 JTF_VARCHAR2_TABLE_200
    , p4_a98 JTF_VARCHAR2_TABLE_200
    , p4_a99 JTF_VARCHAR2_TABLE_200
    , p4_a100 JTF_VARCHAR2_TABLE_200
    , p4_a101 JTF_VARCHAR2_TABLE_200
    , p4_a102 JTF_VARCHAR2_TABLE_200
    , p4_a103 JTF_VARCHAR2_TABLE_200
    , p4_a104 JTF_VARCHAR2_TABLE_200
    , p4_a105 JTF_VARCHAR2_TABLE_100
    , p4_a106 JTF_VARCHAR2_TABLE_200
    , p4_a107 JTF_VARCHAR2_TABLE_200
    , p4_a108 JTF_VARCHAR2_TABLE_200
    , p4_a109 JTF_VARCHAR2_TABLE_200
    , p4_a110 JTF_VARCHAR2_TABLE_200
    , p4_a111 JTF_VARCHAR2_TABLE_200
    , p4_a112 JTF_VARCHAR2_TABLE_200
    , p4_a113 JTF_VARCHAR2_TABLE_200
    , p4_a114 JTF_VARCHAR2_TABLE_200
    , p4_a115 JTF_VARCHAR2_TABLE_200
    , p4_a116 JTF_VARCHAR2_TABLE_200
    , p4_a117 JTF_VARCHAR2_TABLE_200
    , p4_a118 JTF_VARCHAR2_TABLE_200
    , p4_a119 JTF_VARCHAR2_TABLE_200
    , p4_a120 JTF_VARCHAR2_TABLE_200
    , p4_a121 JTF_NUMBER_TABLE
    , p4_a122 JTF_NUMBER_TABLE
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  DATE
    , p5_a2 in out nocopy  DATE
    , p5_a3 in out nocopy  NUMBER
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  VARCHAR2
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  NUMBER
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  DATE
    , p5_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end csi_pricing_attribs_pub_w;

/
