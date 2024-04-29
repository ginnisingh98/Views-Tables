--------------------------------------------------------
--  DDL for Package CSI_ITEM_INSTANCE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ITEM_INSTANCE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: csipiiws.pls 120.18.12010000.2 2009/05/22 20:06:47 hyonlee ship $ */
  procedure rosetta_table_copy_in_p14(t out nocopy csi_item_instance_pub.txn_oks_type_tbl, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p14(t csi_item_instance_pub.txn_oks_type_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure create_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  VARCHAR2
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  NUMBER
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  DATE
    , p4_a21 in out nocopy  DATE
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  NUMBER
    , p4_a24 in out nocopy  NUMBER
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  NUMBER
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  NUMBER
    , p4_a31 in out nocopy  NUMBER
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  NUMBER
    , p4_a37 in out nocopy  NUMBER
    , p4_a38 in out nocopy  NUMBER
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  DATE
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  DATE
    , p4_a43 in out nocopy  DATE
    , p4_a44 in out nocopy  VARCHAR2
    , p4_a45 in out nocopy  VARCHAR2
    , p4_a46 in out nocopy  VARCHAR2
    , p4_a47 in out nocopy  VARCHAR2
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  VARCHAR2
    , p4_a50 in out nocopy  VARCHAR2
    , p4_a51 in out nocopy  VARCHAR2
    , p4_a52 in out nocopy  VARCHAR2
    , p4_a53 in out nocopy  VARCHAR2
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  VARCHAR2
    , p4_a56 in out nocopy  VARCHAR2
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  NUMBER
    , p4_a65 in out nocopy  NUMBER
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  NUMBER
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  NUMBER
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  NUMBER
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  VARCHAR2
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  NUMBER
    , p4_a81 in out nocopy  NUMBER
    , p4_a82 in out nocopy  NUMBER
    , p4_a83 in out nocopy  DATE
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  NUMBER
    , p4_a88 in out nocopy  VARCHAR2
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  NUMBER
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  NUMBER
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  NUMBER
    , p4_a95 in out nocopy  DATE
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  VARCHAR2
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  VARCHAR2
    , p4_a109 in out nocopy  VARCHAR2
    , p4_a110 in out nocopy  VARCHAR2
    , p4_a111 in out nocopy  NUMBER
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  NUMBER
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  NUMBER
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  NUMBER
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  NUMBER
    , p4_a121 in out nocopy  NUMBER
    , p4_a122 in out nocopy  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_DATE_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 in out nocopy JTF_NUMBER_TABLE
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_NUMBER_TABLE
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_DATE_TABLE
    , p8_a3 in out nocopy JTF_DATE_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a121 in out nocopy JTF_NUMBER_TABLE
    , p8_a122 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_DATE_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  DATE
    , p11_a2 in out nocopy  DATE
    , p11_a3 in out nocopy  NUMBER
    , p11_a4 in out nocopy  NUMBER
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  NUMBER
    , p11_a8 in out nocopy  VARCHAR2
    , p11_a9 in out nocopy  NUMBER
    , p11_a10 in out nocopy  VARCHAR2
    , p11_a11 in out nocopy  NUMBER
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  NUMBER
    , p11_a14 in out nocopy  NUMBER
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  NUMBER
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  NUMBER
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , p11_a29 in out nocopy  VARCHAR2
    , p11_a30 in out nocopy  VARCHAR2
    , p11_a31 in out nocopy  VARCHAR2
    , p11_a32 in out nocopy  VARCHAR2
    , p11_a33 in out nocopy  VARCHAR2
    , p11_a34 in out nocopy  VARCHAR2
    , p11_a35 in out nocopy  VARCHAR2
    , p11_a36 in out nocopy  NUMBER
    , p11_a37 in out nocopy  VARCHAR2
    , p11_a38 in out nocopy  DATE
    , p11_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a5 in out nocopy JTF_DATE_TABLE
    , p5_a6 in out nocopy JTF_DATE_TABLE
    , p5_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 in out nocopy JTF_NUMBER_TABLE
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 in out nocopy JTF_NUMBER_TABLE
    , p6_a7 in out nocopy JTF_DATE_TABLE
    , p6_a8 in out nocopy JTF_DATE_TABLE
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 in out nocopy JTF_NUMBER_TABLE
    , p6_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 in out nocopy JTF_NUMBER_TABLE
    , p6_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a30 in out nocopy JTF_NUMBER_TABLE
    , p6_a31 in out nocopy JTF_NUMBER_TABLE
    , p6_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_NUMBER_TABLE
    , p7_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 in out nocopy JTF_NUMBER_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_DATE_TABLE
    , p7_a8 in out nocopy JTF_DATE_TABLE
    , p7_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_NUMBER_TABLE
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 in out nocopy JTF_NUMBER_TABLE
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a30 in out nocopy JTF_NUMBER_TABLE
    , p7_a31 in out nocopy JTF_NUMBER_TABLE
    , p7_a32 in out nocopy JTF_NUMBER_TABLE
    , p7_a33 in out nocopy JTF_DATE_TABLE
    , p7_a34 in out nocopy JTF_NUMBER_TABLE
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 in out nocopy JTF_NUMBER_TABLE
    , p8_a1 in out nocopy JTF_NUMBER_TABLE
    , p8_a2 in out nocopy JTF_DATE_TABLE
    , p8_a3 in out nocopy JTF_DATE_TABLE
    , p8_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a6 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 in out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a37 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a38 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a39 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a55 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a56 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a57 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a58 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a59 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a60 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a61 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a62 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a63 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a64 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a65 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a66 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a67 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a68 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a69 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a70 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a71 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a72 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a73 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a74 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a75 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a76 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a77 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a78 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a79 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a80 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a81 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a82 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a83 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a84 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a85 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a86 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a87 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a88 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a89 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a90 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a91 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a92 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a93 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a94 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a95 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a96 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a97 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a98 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a99 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a100 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a101 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a102 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a103 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a104 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a105 in out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a106 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a107 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a108 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a109 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a110 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a111 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a112 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a113 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a114 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a115 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a116 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a117 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a118 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a119 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a120 in out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a121 in out nocopy JTF_NUMBER_TABLE
    , p8_a122 in out nocopy JTF_NUMBER_TABLE
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_NUMBER_TABLE
    , p9_a23 in out nocopy JTF_NUMBER_TABLE
    , p10_a0 in out nocopy JTF_NUMBER_TABLE
    , p10_a1 in out nocopy JTF_NUMBER_TABLE
    , p10_a2 in out nocopy JTF_NUMBER_TABLE
    , p10_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 in out nocopy JTF_NUMBER_TABLE
    , p10_a5 in out nocopy JTF_NUMBER_TABLE
    , p10_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 in out nocopy JTF_DATE_TABLE
    , p10_a8 in out nocopy JTF_DATE_TABLE
    , p10_a9 in out nocopy JTF_NUMBER_TABLE
    , p10_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 in out nocopy JTF_NUMBER_TABLE
    , p10_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 in out nocopy JTF_NUMBER_TABLE
    , p10_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a0 in out nocopy  NUMBER
    , p11_a1 in out nocopy  DATE
    , p11_a2 in out nocopy  DATE
    , p11_a3 in out nocopy  NUMBER
    , p11_a4 in out nocopy  NUMBER
    , p11_a5 in out nocopy  NUMBER
    , p11_a6 in out nocopy  VARCHAR2
    , p11_a7 in out nocopy  NUMBER
    , p11_a8 in out nocopy  VARCHAR2
    , p11_a9 in out nocopy  NUMBER
    , p11_a10 in out nocopy  VARCHAR2
    , p11_a11 in out nocopy  NUMBER
    , p11_a12 in out nocopy  NUMBER
    , p11_a13 in out nocopy  NUMBER
    , p11_a14 in out nocopy  NUMBER
    , p11_a15 in out nocopy  VARCHAR2
    , p11_a16 in out nocopy  NUMBER
    , p11_a17 in out nocopy  VARCHAR2
    , p11_a18 in out nocopy  VARCHAR2
    , p11_a19 in out nocopy  NUMBER
    , p11_a20 in out nocopy  VARCHAR2
    , p11_a21 in out nocopy  VARCHAR2
    , p11_a22 in out nocopy  VARCHAR2
    , p11_a23 in out nocopy  VARCHAR2
    , p11_a24 in out nocopy  VARCHAR2
    , p11_a25 in out nocopy  VARCHAR2
    , p11_a26 in out nocopy  VARCHAR2
    , p11_a27 in out nocopy  VARCHAR2
    , p11_a28 in out nocopy  VARCHAR2
    , p11_a29 in out nocopy  VARCHAR2
    , p11_a30 in out nocopy  VARCHAR2
    , p11_a31 in out nocopy  VARCHAR2
    , p11_a32 in out nocopy  VARCHAR2
    , p11_a33 in out nocopy  VARCHAR2
    , p11_a34 in out nocopy  VARCHAR2
    , p11_a35 in out nocopy  VARCHAR2
    , p11_a36 in out nocopy  NUMBER
    , p11_a37 in out nocopy  VARCHAR2
    , p11_a38 in out nocopy  DATE
    , p11_a39 in out nocopy  NUMBER
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  NUMBER := 0-1962.0724
    , p4_a40  DATE := fnd_api.g_miss_date
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  DATE := fnd_api.g_miss_date
    , p4_a43  DATE := fnd_api.g_miss_date
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  NUMBER := 0-1962.0724
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  NUMBER := 0-1962.0724
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  NUMBER := 0-1962.0724
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  NUMBER := 0-1962.0724
    , p4_a75  NUMBER := 0-1962.0724
    , p4_a76  NUMBER := 0-1962.0724
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  NUMBER := 0-1962.0724
    , p4_a82  NUMBER := 0-1962.0724
    , p4_a83  DATE := fnd_api.g_miss_date
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  NUMBER := 0-1962.0724
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  NUMBER := 0-1962.0724
    , p4_a90  NUMBER := 0-1962.0724
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  NUMBER := 0-1962.0724
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  NUMBER := 0-1962.0724
    , p4_a95  DATE := fnd_api.g_miss_date
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  NUMBER := 0-1962.0724
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  NUMBER := 0-1962.0724
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  NUMBER := 0-1962.0724
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  NUMBER := 0-1962.0724
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  NUMBER := 0-1962.0724
    , p4_a121  NUMBER := 0-1962.0724
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure expire_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_expire_children  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  DATE
    , p6_a2 in out nocopy  DATE
    , p6_a3 in out nocopy  NUMBER
    , p6_a4 in out nocopy  NUMBER
    , p6_a5 in out nocopy  NUMBER
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  NUMBER
    , p6_a10 in out nocopy  VARCHAR2
    , p6_a11 in out nocopy  NUMBER
    , p6_a12 in out nocopy  NUMBER
    , p6_a13 in out nocopy  NUMBER
    , p6_a14 in out nocopy  NUMBER
    , p6_a15 in out nocopy  VARCHAR2
    , p6_a16 in out nocopy  NUMBER
    , p6_a17 in out nocopy  VARCHAR2
    , p6_a18 in out nocopy  VARCHAR2
    , p6_a19 in out nocopy  NUMBER
    , p6_a20 in out nocopy  VARCHAR2
    , p6_a21 in out nocopy  VARCHAR2
    , p6_a22 in out nocopy  VARCHAR2
    , p6_a23 in out nocopy  VARCHAR2
    , p6_a24 in out nocopy  VARCHAR2
    , p6_a25 in out nocopy  VARCHAR2
    , p6_a26 in out nocopy  VARCHAR2
    , p6_a27 in out nocopy  VARCHAR2
    , p6_a28 in out nocopy  VARCHAR2
    , p6_a29 in out nocopy  VARCHAR2
    , p6_a30 in out nocopy  VARCHAR2
    , p6_a31 in out nocopy  VARCHAR2
    , p6_a32 in out nocopy  VARCHAR2
    , p6_a33 in out nocopy  VARCHAR2
    , p6_a34 in out nocopy  VARCHAR2
    , p6_a35 in out nocopy  VARCHAR2
    , p6_a36 in out nocopy  NUMBER
    , p6_a37 in out nocopy  VARCHAR2
    , p6_a38 in out nocopy  DATE
    , p6_a39 in out nocopy  NUMBER
    , x_instance_id_lst out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  NUMBER := 0-1962.0724
    , p4_a40  DATE := fnd_api.g_miss_date
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  DATE := fnd_api.g_miss_date
    , p4_a43  DATE := fnd_api.g_miss_date
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  NUMBER := 0-1962.0724
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  NUMBER := 0-1962.0724
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  NUMBER := 0-1962.0724
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  NUMBER := 0-1962.0724
    , p4_a75  NUMBER := 0-1962.0724
    , p4_a76  NUMBER := 0-1962.0724
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  NUMBER := 0-1962.0724
    , p4_a82  NUMBER := 0-1962.0724
    , p4_a83  DATE := fnd_api.g_miss_date
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  NUMBER := 0-1962.0724
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  NUMBER := 0-1962.0724
    , p4_a90  NUMBER := 0-1962.0724
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  NUMBER := 0-1962.0724
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  NUMBER := 0-1962.0724
    , p4_a95  DATE := fnd_api.g_miss_date
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  NUMBER := 0-1962.0724
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  NUMBER := 0-1962.0724
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  NUMBER := 0-1962.0724
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  NUMBER := 0-1962.0724
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  NUMBER := 0-1962.0724
    , p4_a121  NUMBER := 0-1962.0724
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_item_instances(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_transaction_id  NUMBER
    , p_resolve_id_columns  VARCHAR2
    , p_active_instance_only  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_NUMBER_TABLE
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a9 out nocopy JTF_NUMBER_TABLE
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a15 out nocopy JTF_NUMBER_TABLE
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a17 out nocopy JTF_NUMBER_TABLE
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a21 out nocopy JTF_NUMBER_TABLE
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a25 out nocopy JTF_DATE_TABLE
    , p10_a26 out nocopy JTF_DATE_TABLE
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a28 out nocopy JTF_NUMBER_TABLE
    , p10_a29 out nocopy JTF_NUMBER_TABLE
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a32 out nocopy JTF_NUMBER_TABLE
    , p10_a33 out nocopy JTF_NUMBER_TABLE
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a39 out nocopy JTF_NUMBER_TABLE
    , p10_a40 out nocopy JTF_NUMBER_TABLE
    , p10_a41 out nocopy JTF_NUMBER_TABLE
    , p10_a42 out nocopy JTF_NUMBER_TABLE
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a44 out nocopy JTF_NUMBER_TABLE
    , p10_a45 out nocopy JTF_NUMBER_TABLE
    , p10_a46 out nocopy JTF_NUMBER_TABLE
    , p10_a47 out nocopy JTF_NUMBER_TABLE
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a49 out nocopy JTF_NUMBER_TABLE
    , p10_a50 out nocopy JTF_NUMBER_TABLE
    , p10_a51 out nocopy JTF_NUMBER_TABLE
    , p10_a52 out nocopy JTF_NUMBER_TABLE
    , p10_a53 out nocopy JTF_DATE_TABLE
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a55 out nocopy JTF_DATE_TABLE
    , p10_a56 out nocopy JTF_DATE_TABLE
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a75 out nocopy JTF_NUMBER_TABLE
    , p10_a76 out nocopy JTF_NUMBER_TABLE
    , p10_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a78 out nocopy JTF_NUMBER_TABLE
    , p10_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a88 out nocopy JTF_NUMBER_TABLE
    , p10_a89 out nocopy JTF_NUMBER_TABLE
    , p10_a90 out nocopy JTF_DATE_TABLE
    , p10_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a99 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a100 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a101 out nocopy JTF_NUMBER_TABLE
    , p10_a102 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a103 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a104 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a106 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a107 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a108 out nocopy JTF_NUMBER_TABLE
    , p10_a109 out nocopy JTF_NUMBER_TABLE
    , p10_a110 out nocopy JTF_NUMBER_TABLE
    , p10_a111 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a118 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a120 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a125 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a126 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a127 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a128 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a129 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a130 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a131 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a134 out nocopy JTF_NUMBER_TABLE
    , p10_a135 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a136 out nocopy JTF_NUMBER_TABLE
    , p10_a137 out nocopy JTF_NUMBER_TABLE
    , p10_a138 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a139 out nocopy JTF_NUMBER_TABLE
    , p10_a140 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a141 out nocopy JTF_NUMBER_TABLE
    , p10_a142 out nocopy JTF_DATE_TABLE
    , p10_a143 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a144 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a145 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a146 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a147 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a148 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a149 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a150 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a151 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a152 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a153 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a154 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a155 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a156 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a157 out nocopy JTF_VARCHAR2_TABLE_300
    , p10_a158 out nocopy JTF_NUMBER_TABLE
    , p10_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a160 out nocopy JTF_NUMBER_TABLE
    , p10_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a162 out nocopy JTF_NUMBER_TABLE
    , p10_a163 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a167 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a170 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a171 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a172 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a174 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a175 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a177 out nocopy JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  NUMBER := 0-1962.0724
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  NUMBER := 0-1962.0724
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  DATE := fnd_api.g_miss_date
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  DATE := fnd_api.g_miss_date
    , p4_a32  DATE := fnd_api.g_miss_date
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_item_instance_details(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  NUMBER
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  VARCHAR2
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR2
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  NUMBER
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  NUMBER
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  NUMBER
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  DATE
    , p4_a26 in out nocopy  DATE
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  NUMBER
    , p4_a29 in out nocopy  NUMBER
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  NUMBER
    , p4_a33 in out nocopy  NUMBER
    , p4_a34 in out nocopy  NUMBER
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  NUMBER
    , p4_a42 in out nocopy  NUMBER
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  NUMBER
    , p4_a45 in out nocopy  NUMBER
    , p4_a46 in out nocopy  NUMBER
    , p4_a47 in out nocopy  NUMBER
    , p4_a48 in out nocopy  VARCHAR2
    , p4_a49 in out nocopy  NUMBER
    , p4_a50 in out nocopy  NUMBER
    , p4_a51 in out nocopy  NUMBER
    , p4_a52 in out nocopy  NUMBER
    , p4_a53 in out nocopy  DATE
    , p4_a54 in out nocopy  VARCHAR2
    , p4_a55 in out nocopy  DATE
    , p4_a56 in out nocopy  DATE
    , p4_a57 in out nocopy  VARCHAR2
    , p4_a58 in out nocopy  VARCHAR2
    , p4_a59 in out nocopy  VARCHAR2
    , p4_a60 in out nocopy  VARCHAR2
    , p4_a61 in out nocopy  VARCHAR2
    , p4_a62 in out nocopy  VARCHAR2
    , p4_a63 in out nocopy  VARCHAR2
    , p4_a64 in out nocopy  VARCHAR2
    , p4_a65 in out nocopy  VARCHAR2
    , p4_a66 in out nocopy  VARCHAR2
    , p4_a67 in out nocopy  VARCHAR2
    , p4_a68 in out nocopy  VARCHAR2
    , p4_a69 in out nocopy  VARCHAR2
    , p4_a70 in out nocopy  VARCHAR2
    , p4_a71 in out nocopy  VARCHAR2
    , p4_a72 in out nocopy  VARCHAR2
    , p4_a73 in out nocopy  VARCHAR2
    , p4_a74 in out nocopy  VARCHAR2
    , p4_a75 in out nocopy  NUMBER
    , p4_a76 in out nocopy  NUMBER
    , p4_a77 in out nocopy  VARCHAR2
    , p4_a78 in out nocopy  NUMBER
    , p4_a79 in out nocopy  VARCHAR2
    , p4_a80 in out nocopy  VARCHAR2
    , p4_a81 in out nocopy  VARCHAR2
    , p4_a82 in out nocopy  VARCHAR2
    , p4_a83 in out nocopy  VARCHAR2
    , p4_a84 in out nocopy  VARCHAR2
    , p4_a85 in out nocopy  VARCHAR2
    , p4_a86 in out nocopy  VARCHAR2
    , p4_a87 in out nocopy  VARCHAR2
    , p4_a88 in out nocopy  NUMBER
    , p4_a89 in out nocopy  NUMBER
    , p4_a90 in out nocopy  DATE
    , p4_a91 in out nocopy  VARCHAR2
    , p4_a92 in out nocopy  VARCHAR2
    , p4_a93 in out nocopy  VARCHAR2
    , p4_a94 in out nocopy  VARCHAR2
    , p4_a95 in out nocopy  VARCHAR2
    , p4_a96 in out nocopy  VARCHAR2
    , p4_a97 in out nocopy  VARCHAR2
    , p4_a98 in out nocopy  VARCHAR2
    , p4_a99 in out nocopy  VARCHAR2
    , p4_a100 in out nocopy  VARCHAR2
    , p4_a101 in out nocopy  NUMBER
    , p4_a102 in out nocopy  VARCHAR2
    , p4_a103 in out nocopy  VARCHAR2
    , p4_a104 in out nocopy  VARCHAR2
    , p4_a105 in out nocopy  VARCHAR2
    , p4_a106 in out nocopy  VARCHAR2
    , p4_a107 in out nocopy  VARCHAR2
    , p4_a108 in out nocopy  NUMBER
    , p4_a109 in out nocopy  NUMBER
    , p4_a110 in out nocopy  NUMBER
    , p4_a111 in out nocopy  VARCHAR2
    , p4_a112 in out nocopy  VARCHAR2
    , p4_a113 in out nocopy  VARCHAR2
    , p4_a114 in out nocopy  VARCHAR2
    , p4_a115 in out nocopy  VARCHAR2
    , p4_a116 in out nocopy  VARCHAR2
    , p4_a117 in out nocopy  VARCHAR2
    , p4_a118 in out nocopy  VARCHAR2
    , p4_a119 in out nocopy  VARCHAR2
    , p4_a120 in out nocopy  VARCHAR2
    , p4_a121 in out nocopy  VARCHAR2
    , p4_a122 in out nocopy  VARCHAR2
    , p4_a123 in out nocopy  VARCHAR2
    , p4_a124 in out nocopy  VARCHAR2
    , p4_a125 in out nocopy  VARCHAR2
    , p4_a126 in out nocopy  VARCHAR2
    , p4_a127 in out nocopy  VARCHAR2
    , p4_a128 in out nocopy  VARCHAR2
    , p4_a129 in out nocopy  VARCHAR2
    , p4_a130 in out nocopy  VARCHAR2
    , p4_a131 in out nocopy  VARCHAR2
    , p4_a132 in out nocopy  VARCHAR2
    , p4_a133 in out nocopy  VARCHAR2
    , p4_a134 in out nocopy  NUMBER
    , p4_a135 in out nocopy  VARCHAR2
    , p4_a136 in out nocopy  NUMBER
    , p4_a137 in out nocopy  NUMBER
    , p4_a138 in out nocopy  VARCHAR2
    , p4_a139 in out nocopy  NUMBER
    , p4_a140 in out nocopy  VARCHAR2
    , p4_a141 in out nocopy  NUMBER
    , p4_a142 in out nocopy  DATE
    , p4_a143 in out nocopy  VARCHAR2
    , p4_a144 in out nocopy  VARCHAR2
    , p4_a145 in out nocopy  VARCHAR2
    , p4_a146 in out nocopy  VARCHAR2
    , p4_a147 in out nocopy  VARCHAR2
    , p4_a148 in out nocopy  VARCHAR2
    , p4_a149 in out nocopy  VARCHAR2
    , p4_a150 in out nocopy  VARCHAR2
    , p4_a151 in out nocopy  VARCHAR2
    , p4_a152 in out nocopy  VARCHAR2
    , p4_a153 in out nocopy  VARCHAR2
    , p4_a154 in out nocopy  VARCHAR2
    , p4_a155 in out nocopy  VARCHAR2
    , p4_a156 in out nocopy  VARCHAR2
    , p4_a157 in out nocopy  VARCHAR2
    , p4_a158 in out nocopy  NUMBER
    , p4_a159 in out nocopy  VARCHAR2
    , p4_a160 in out nocopy  NUMBER
    , p4_a161 in out nocopy  VARCHAR2
    , p4_a162 in out nocopy  NUMBER
    , p4_a163 in out nocopy  VARCHAR2
    , p4_a164 in out nocopy  VARCHAR2
    , p4_a165 in out nocopy  VARCHAR2
    , p4_a166 in out nocopy  VARCHAR2
    , p4_a167 in out nocopy  VARCHAR2
    , p4_a168 in out nocopy  VARCHAR2
    , p4_a169 in out nocopy  VARCHAR2
    , p4_a170 in out nocopy  VARCHAR2
    , p4_a171 in out nocopy  VARCHAR2
    , p4_a172 in out nocopy  VARCHAR2
    , p4_a173 in out nocopy  VARCHAR2
    , p4_a174 in out nocopy  VARCHAR2
    , p4_a175 in out nocopy  VARCHAR2
    , p4_a176 in out nocopy  VARCHAR2
    , p4_a177 in out nocopy  VARCHAR2
    , p_get_parties  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_accounts  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a10 out nocopy JTF_DATE_TABLE
    , p8_a11 out nocopy JTF_DATE_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_org_assignments  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_NUMBER_TABLE
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_DATE_TABLE
    , p10_a6 out nocopy JTF_DATE_TABLE
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a23 out nocopy JTF_NUMBER_TABLE
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p_get_pricing_attribs  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_DATE_TABLE
    , p12_a3 out nocopy JTF_DATE_TABLE
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a37 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a38 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a62 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a63 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a64 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a65 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a66 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a67 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a68 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a69 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a70 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a71 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a72 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a73 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a74 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a75 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a76 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a77 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a78 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a79 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a80 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a81 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a82 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a83 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a84 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a85 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a87 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a89 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a90 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a91 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a92 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a93 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a94 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a95 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a96 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a97 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a98 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a99 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a100 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a101 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a102 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a103 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a104 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a105 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a106 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a107 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a108 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a109 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a110 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a111 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a112 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a113 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a114 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a115 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a116 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a117 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a118 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a119 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a120 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a121 out nocopy JTF_NUMBER_TABLE
    , p12_a122 out nocopy JTF_NUMBER_TABLE
    , p_get_ext_attribs  VARCHAR2
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a5 out nocopy JTF_DATE_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a2 out nocopy JTF_NUMBER_TABLE
    , p15_a3 out nocopy JTF_NUMBER_TABLE
    , p15_a4 out nocopy JTF_NUMBER_TABLE
    , p15_a5 out nocopy JTF_NUMBER_TABLE
    , p15_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a10 out nocopy JTF_DATE_TABLE
    , p15_a11 out nocopy JTF_DATE_TABLE
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a28 out nocopy JTF_NUMBER_TABLE
    , p_get_asset_assignments  VARCHAR2
    , p17_a0 out nocopy JTF_NUMBER_TABLE
    , p17_a1 out nocopy JTF_NUMBER_TABLE
    , p17_a2 out nocopy JTF_NUMBER_TABLE
    , p17_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a4 out nocopy JTF_NUMBER_TABLE
    , p17_a5 out nocopy JTF_NUMBER_TABLE
    , p17_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a7 out nocopy JTF_DATE_TABLE
    , p17_a8 out nocopy JTF_DATE_TABLE
    , p17_a9 out nocopy JTF_NUMBER_TABLE
    , p17_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a21 out nocopy JTF_DATE_TABLE
    , p17_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p17_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p17_a25 out nocopy JTF_NUMBER_TABLE
    , p17_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p_resolve_id_columns  VARCHAR2
    , p_time_stamp  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_version_labels(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  DATE := fnd_api.g_miss_date
  );
  procedure create_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a4 in out nocopy JTF_DATE_TABLE
    , p4_a5 in out nocopy JTF_DATE_TABLE
    , p4_a6 in out nocopy JTF_DATE_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p4_a23 in out nocopy JTF_NUMBER_TABLE
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
  procedure update_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_300
    , p4_a3 JTF_VARCHAR2_TABLE_300
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
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
    , p4_a23 JTF_NUMBER_TABLE
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
  procedure expire_version_label(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_300
    , p4_a3 JTF_VARCHAR2_TABLE_300
    , p4_a4 JTF_DATE_TABLE
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
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
    , p4_a23 JTF_NUMBER_TABLE
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
  procedure get_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_time_stamp  date
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
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
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a10 out nocopy JTF_DATE_TABLE
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
  );
  procedure create_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy JTF_NUMBER_TABLE
    , p4_a1 in out nocopy JTF_NUMBER_TABLE
    , p4_a2 in out nocopy JTF_NUMBER_TABLE
    , p4_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 in out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 in out nocopy JTF_DATE_TABLE
    , p4_a6 in out nocopy JTF_DATE_TABLE
    , p4_a7 in out nocopy JTF_VARCHAR2_TABLE_100
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
    , p4_a23 in out nocopy JTF_NUMBER_TABLE
    , p4_a24 in out nocopy JTF_NUMBER_TABLE
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
  procedure update_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_300
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
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
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
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
  procedure expire_extended_attrib_values(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_VARCHAR2_TABLE_100
    , p4_a4 JTF_VARCHAR2_TABLE_300
    , p4_a5 JTF_DATE_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_VARCHAR2_TABLE_100
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
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
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
  procedure copy_item_instance(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_parties  VARCHAR2
    , p_copy_party_contacts  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p_copy_inst_children  VARCHAR2
    , p13_a0 in out nocopy  NUMBER
    , p13_a1 in out nocopy  DATE
    , p13_a2 in out nocopy  DATE
    , p13_a3 in out nocopy  NUMBER
    , p13_a4 in out nocopy  NUMBER
    , p13_a5 in out nocopy  NUMBER
    , p13_a6 in out nocopy  VARCHAR2
    , p13_a7 in out nocopy  NUMBER
    , p13_a8 in out nocopy  VARCHAR2
    , p13_a9 in out nocopy  NUMBER
    , p13_a10 in out nocopy  VARCHAR2
    , p13_a11 in out nocopy  NUMBER
    , p13_a12 in out nocopy  NUMBER
    , p13_a13 in out nocopy  NUMBER
    , p13_a14 in out nocopy  NUMBER
    , p13_a15 in out nocopy  VARCHAR2
    , p13_a16 in out nocopy  NUMBER
    , p13_a17 in out nocopy  VARCHAR2
    , p13_a18 in out nocopy  VARCHAR2
    , p13_a19 in out nocopy  NUMBER
    , p13_a20 in out nocopy  VARCHAR2
    , p13_a21 in out nocopy  VARCHAR2
    , p13_a22 in out nocopy  VARCHAR2
    , p13_a23 in out nocopy  VARCHAR2
    , p13_a24 in out nocopy  VARCHAR2
    , p13_a25 in out nocopy  VARCHAR2
    , p13_a26 in out nocopy  VARCHAR2
    , p13_a27 in out nocopy  VARCHAR2
    , p13_a28 in out nocopy  VARCHAR2
    , p13_a29 in out nocopy  VARCHAR2
    , p13_a30 in out nocopy  VARCHAR2
    , p13_a31 in out nocopy  VARCHAR2
    , p13_a32 in out nocopy  VARCHAR2
    , p13_a33 in out nocopy  VARCHAR2
    , p13_a34 in out nocopy  VARCHAR2
    , p13_a35 in out nocopy  VARCHAR2
    , p13_a36 in out nocopy  NUMBER
    , p13_a37 in out nocopy  VARCHAR2
    , p13_a38 in out nocopy  DATE
    , p13_a39 in out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a6 out nocopy JTF_NUMBER_TABLE
    , p14_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_NUMBER_TABLE
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_NUMBER_TABLE
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a18 out nocopy JTF_NUMBER_TABLE
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a20 out nocopy JTF_DATE_TABLE
    , p14_a21 out nocopy JTF_DATE_TABLE
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a23 out nocopy JTF_NUMBER_TABLE
    , p14_a24 out nocopy JTF_NUMBER_TABLE
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 out nocopy JTF_NUMBER_TABLE
    , p14_a27 out nocopy JTF_NUMBER_TABLE
    , p14_a28 out nocopy JTF_NUMBER_TABLE
    , p14_a29 out nocopy JTF_NUMBER_TABLE
    , p14_a30 out nocopy JTF_NUMBER_TABLE
    , p14_a31 out nocopy JTF_NUMBER_TABLE
    , p14_a32 out nocopy JTF_NUMBER_TABLE
    , p14_a33 out nocopy JTF_NUMBER_TABLE
    , p14_a34 out nocopy JTF_NUMBER_TABLE
    , p14_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a36 out nocopy JTF_NUMBER_TABLE
    , p14_a37 out nocopy JTF_NUMBER_TABLE
    , p14_a38 out nocopy JTF_NUMBER_TABLE
    , p14_a39 out nocopy JTF_NUMBER_TABLE
    , p14_a40 out nocopy JTF_DATE_TABLE
    , p14_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a42 out nocopy JTF_DATE_TABLE
    , p14_a43 out nocopy JTF_DATE_TABLE
    , p14_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a64 out nocopy JTF_NUMBER_TABLE
    , p14_a65 out nocopy JTF_NUMBER_TABLE
    , p14_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a67 out nocopy JTF_NUMBER_TABLE
    , p14_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a72 out nocopy JTF_NUMBER_TABLE
    , p14_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a74 out nocopy JTF_NUMBER_TABLE
    , p14_a75 out nocopy JTF_NUMBER_TABLE
    , p14_a76 out nocopy JTF_NUMBER_TABLE
    , p14_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a80 out nocopy JTF_NUMBER_TABLE
    , p14_a81 out nocopy JTF_NUMBER_TABLE
    , p14_a82 out nocopy JTF_NUMBER_TABLE
    , p14_a83 out nocopy JTF_DATE_TABLE
    , p14_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a87 out nocopy JTF_NUMBER_TABLE
    , p14_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a89 out nocopy JTF_NUMBER_TABLE
    , p14_a90 out nocopy JTF_NUMBER_TABLE
    , p14_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a92 out nocopy JTF_NUMBER_TABLE
    , p14_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a94 out nocopy JTF_NUMBER_TABLE
    , p14_a95 out nocopy JTF_DATE_TABLE
    , p14_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a111 out nocopy JTF_NUMBER_TABLE
    , p14_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a113 out nocopy JTF_NUMBER_TABLE
    , p14_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a115 out nocopy JTF_NUMBER_TABLE
    , p14_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a118 out nocopy JTF_NUMBER_TABLE
    , p14_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a120 out nocopy JTF_NUMBER_TABLE
    , p14_a121 out nocopy JTF_NUMBER_TABLE
    , p14_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  VARCHAR2 := fnd_api.g_miss_char
    , p4_a2  VARCHAR2 := fnd_api.g_miss_char
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  NUMBER := 0-1962.0724
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  NUMBER := 0-1962.0724
    , p4_a37  NUMBER := 0-1962.0724
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  NUMBER := 0-1962.0724
    , p4_a40  DATE := fnd_api.g_miss_date
    , p4_a41  VARCHAR2 := fnd_api.g_miss_char
    , p4_a42  DATE := fnd_api.g_miss_date
    , p4_a43  DATE := fnd_api.g_miss_date
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  NUMBER := 0-1962.0724
    , p4_a65  NUMBER := 0-1962.0724
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  NUMBER := 0-1962.0724
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  NUMBER := 0-1962.0724
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  NUMBER := 0-1962.0724
    , p4_a75  NUMBER := 0-1962.0724
    , p4_a76  NUMBER := 0-1962.0724
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  NUMBER := 0-1962.0724
    , p4_a81  NUMBER := 0-1962.0724
    , p4_a82  NUMBER := 0-1962.0724
    , p4_a83  DATE := fnd_api.g_miss_date
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  NUMBER := 0-1962.0724
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  NUMBER := 0-1962.0724
    , p4_a90  NUMBER := 0-1962.0724
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  NUMBER := 0-1962.0724
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  NUMBER := 0-1962.0724
    , p4_a95  DATE := fnd_api.g_miss_date
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  NUMBER := 0-1962.0724
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  NUMBER := 0-1962.0724
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  NUMBER := 0-1962.0724
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  NUMBER := 0-1962.0724
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  NUMBER := 0-1962.0724
    , p4_a121  NUMBER := 0-1962.0724
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_oks_txn_types(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_check_contracts_yn  VARCHAR2
    , p_txn_type  VARCHAR2
    , x_txn_type_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_configflag out nocopy  VARCHAR2
    , px_txn_date in out nocopy  date
    , x_imp_contracts_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  NUMBER := 0-1962.0724
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  NUMBER := 0-1962.0724
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  DATE := fnd_api.g_miss_date
    , p3_a21  DATE := fnd_api.g_miss_date
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  NUMBER := 0-1962.0724
    , p3_a24  NUMBER := 0-1962.0724
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  NUMBER := 0-1962.0724
    , p3_a27  NUMBER := 0-1962.0724
    , p3_a28  NUMBER := 0-1962.0724
    , p3_a29  NUMBER := 0-1962.0724
    , p3_a30  NUMBER := 0-1962.0724
    , p3_a31  NUMBER := 0-1962.0724
    , p3_a32  NUMBER := 0-1962.0724
    , p3_a33  NUMBER := 0-1962.0724
    , p3_a34  NUMBER := 0-1962.0724
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  NUMBER := 0-1962.0724
    , p3_a37  NUMBER := 0-1962.0724
    , p3_a38  NUMBER := 0-1962.0724
    , p3_a39  NUMBER := 0-1962.0724
    , p3_a40  DATE := fnd_api.g_miss_date
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
    , p3_a42  DATE := fnd_api.g_miss_date
    , p3_a43  DATE := fnd_api.g_miss_date
    , p3_a44  VARCHAR2 := fnd_api.g_miss_char
    , p3_a45  VARCHAR2 := fnd_api.g_miss_char
    , p3_a46  VARCHAR2 := fnd_api.g_miss_char
    , p3_a47  VARCHAR2 := fnd_api.g_miss_char
    , p3_a48  VARCHAR2 := fnd_api.g_miss_char
    , p3_a49  VARCHAR2 := fnd_api.g_miss_char
    , p3_a50  VARCHAR2 := fnd_api.g_miss_char
    , p3_a51  VARCHAR2 := fnd_api.g_miss_char
    , p3_a52  VARCHAR2 := fnd_api.g_miss_char
    , p3_a53  VARCHAR2 := fnd_api.g_miss_char
    , p3_a54  VARCHAR2 := fnd_api.g_miss_char
    , p3_a55  VARCHAR2 := fnd_api.g_miss_char
    , p3_a56  VARCHAR2 := fnd_api.g_miss_char
    , p3_a57  VARCHAR2 := fnd_api.g_miss_char
    , p3_a58  VARCHAR2 := fnd_api.g_miss_char
    , p3_a59  VARCHAR2 := fnd_api.g_miss_char
    , p3_a60  VARCHAR2 := fnd_api.g_miss_char
    , p3_a61  VARCHAR2 := fnd_api.g_miss_char
    , p3_a62  VARCHAR2 := fnd_api.g_miss_char
    , p3_a63  VARCHAR2 := fnd_api.g_miss_char
    , p3_a64  NUMBER := 0-1962.0724
    , p3_a65  NUMBER := 0-1962.0724
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  NUMBER := 0-1962.0724
    , p3_a68  VARCHAR2 := fnd_api.g_miss_char
    , p3_a69  VARCHAR2 := fnd_api.g_miss_char
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
    , p3_a71  VARCHAR2 := fnd_api.g_miss_char
    , p3_a72  NUMBER := 0-1962.0724
    , p3_a73  VARCHAR2 := fnd_api.g_miss_char
    , p3_a74  NUMBER := 0-1962.0724
    , p3_a75  NUMBER := 0-1962.0724
    , p3_a76  NUMBER := 0-1962.0724
    , p3_a77  VARCHAR2 := fnd_api.g_miss_char
    , p3_a78  VARCHAR2 := fnd_api.g_miss_char
    , p3_a79  VARCHAR2 := fnd_api.g_miss_char
    , p3_a80  NUMBER := 0-1962.0724
    , p3_a81  NUMBER := 0-1962.0724
    , p3_a82  NUMBER := 0-1962.0724
    , p3_a83  DATE := fnd_api.g_miss_date
    , p3_a84  VARCHAR2 := fnd_api.g_miss_char
    , p3_a85  VARCHAR2 := fnd_api.g_miss_char
    , p3_a86  VARCHAR2 := fnd_api.g_miss_char
    , p3_a87  NUMBER := 0-1962.0724
    , p3_a88  VARCHAR2 := fnd_api.g_miss_char
    , p3_a89  NUMBER := 0-1962.0724
    , p3_a90  NUMBER := 0-1962.0724
    , p3_a91  VARCHAR2 := fnd_api.g_miss_char
    , p3_a92  NUMBER := 0-1962.0724
    , p3_a93  VARCHAR2 := fnd_api.g_miss_char
    , p3_a94  NUMBER := 0-1962.0724
    , p3_a95  DATE := fnd_api.g_miss_date
    , p3_a96  VARCHAR2 := fnd_api.g_miss_char
    , p3_a97  VARCHAR2 := fnd_api.g_miss_char
    , p3_a98  VARCHAR2 := fnd_api.g_miss_char
    , p3_a99  VARCHAR2 := fnd_api.g_miss_char
    , p3_a100  VARCHAR2 := fnd_api.g_miss_char
    , p3_a101  VARCHAR2 := fnd_api.g_miss_char
    , p3_a102  VARCHAR2 := fnd_api.g_miss_char
    , p3_a103  VARCHAR2 := fnd_api.g_miss_char
    , p3_a104  VARCHAR2 := fnd_api.g_miss_char
    , p3_a105  VARCHAR2 := fnd_api.g_miss_char
    , p3_a106  VARCHAR2 := fnd_api.g_miss_char
    , p3_a107  VARCHAR2 := fnd_api.g_miss_char
    , p3_a108  VARCHAR2 := fnd_api.g_miss_char
    , p3_a109  VARCHAR2 := fnd_api.g_miss_char
    , p3_a110  VARCHAR2 := fnd_api.g_miss_char
    , p3_a111  NUMBER := 0-1962.0724
    , p3_a112  VARCHAR2 := fnd_api.g_miss_char
    , p3_a113  NUMBER := 0-1962.0724
    , p3_a114  VARCHAR2 := fnd_api.g_miss_char
    , p3_a115  NUMBER := 0-1962.0724
    , p3_a116  VARCHAR2 := fnd_api.g_miss_char
    , p3_a117  VARCHAR2 := fnd_api.g_miss_char
    , p3_a118  NUMBER := 0-1962.0724
    , p3_a119  VARCHAR2 := fnd_api.g_miss_char
    , p3_a120  NUMBER := 0-1962.0724
    , p3_a121  NUMBER := 0-1962.0724
    , p3_a122  VARCHAR2 := fnd_api.g_miss_char
  );
end csi_item_instance_pub_w;

/
