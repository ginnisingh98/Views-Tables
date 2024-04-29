--------------------------------------------------------
--  DDL for Package CSI_FA_INSTANCE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_FA_INSTANCE_GRP_W" AUTHID CURRENT_USER as
  /* $Header: csigfaws.pls 120.11 2008/01/15 03:33:29 devijay ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy csi_fa_instance_grp.instance_serial_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t csi_fa_instance_grp.instance_serial_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_item_instance(p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_VARCHAR2_TABLE_300
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_VARCHAR2_TABLE_100
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_VARCHAR2_TABLE_100
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_VARCHAR2_TABLE_100
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
    , p4_a24 JTF_VARCHAR2_TABLE_200
    , p4_a25 JTF_NUMBER_TABLE
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_NUMBER_TABLE
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_NUMBER_TABLE
    , p4_a31 JTF_NUMBER_TABLE
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_DATE_TABLE
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_200
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_200
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_100
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_NUMBER_TABLE
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_DATE_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_VARCHAR2_TABLE_100
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
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a18 out nocopy JTF_NUMBER_TABLE
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_DATE_TABLE
    , p7_a21 out nocopy JTF_DATE_TABLE
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_NUMBER_TABLE
    , p7_a24 out nocopy JTF_NUMBER_TABLE
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a26 out nocopy JTF_NUMBER_TABLE
    , p7_a27 out nocopy JTF_NUMBER_TABLE
    , p7_a28 out nocopy JTF_NUMBER_TABLE
    , p7_a29 out nocopy JTF_NUMBER_TABLE
    , p7_a30 out nocopy JTF_NUMBER_TABLE
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_NUMBER_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_NUMBER_TABLE
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_NUMBER_TABLE
    , p7_a40 out nocopy JTF_DATE_TABLE
    , p7_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a42 out nocopy JTF_DATE_TABLE
    , p7_a43 out nocopy JTF_DATE_TABLE
    , p7_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a64 out nocopy JTF_NUMBER_TABLE
    , p7_a65 out nocopy JTF_NUMBER_TABLE
    , p7_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a67 out nocopy JTF_NUMBER_TABLE
    , p7_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a72 out nocopy JTF_NUMBER_TABLE
    , p7_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a74 out nocopy JTF_NUMBER_TABLE
    , p7_a75 out nocopy JTF_NUMBER_TABLE
    , p7_a76 out nocopy JTF_NUMBER_TABLE
    , p7_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a80 out nocopy JTF_NUMBER_TABLE
    , p7_a81 out nocopy JTF_NUMBER_TABLE
    , p7_a82 out nocopy JTF_NUMBER_TABLE
    , p7_a83 out nocopy JTF_DATE_TABLE
    , p7_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a87 out nocopy JTF_NUMBER_TABLE
    , p7_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a89 out nocopy JTF_NUMBER_TABLE
    , p7_a90 out nocopy JTF_NUMBER_TABLE
    , p7_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a92 out nocopy JTF_NUMBER_TABLE
    , p7_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a94 out nocopy JTF_NUMBER_TABLE
    , p7_a95 out nocopy JTF_DATE_TABLE
    , p7_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a111 out nocopy JTF_NUMBER_TABLE
    , p7_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a113 out nocopy JTF_NUMBER_TABLE
    , p7_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a115 out nocopy JTF_NUMBER_TABLE
    , p7_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a118 out nocopy JTF_NUMBER_TABLE
    , p7_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a120 out nocopy JTF_NUMBER_TABLE
    , p7_a121 out nocopy JTF_NUMBER_TABLE
    , p7_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_DATE_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  VARCHAR2 := fnd_api.g_miss_char
    , p2_a2  VARCHAR2 := fnd_api.g_miss_char
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  NUMBER := 0-1962.0724
    , p2_a5  VARCHAR2 := fnd_api.g_miss_char
    , p2_a6  NUMBER := 0-1962.0724
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  NUMBER := 0-1962.0724
    , p2_a15  VARCHAR2 := fnd_api.g_miss_char
    , p2_a16  VARCHAR2 := fnd_api.g_miss_char
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  NUMBER := 0-1962.0724
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  DATE := fnd_api.g_miss_date
    , p2_a21  DATE := fnd_api.g_miss_date
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  NUMBER := 0-1962.0724
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  NUMBER := 0-1962.0724
    , p2_a27  NUMBER := 0-1962.0724
    , p2_a28  NUMBER := 0-1962.0724
    , p2_a29  NUMBER := 0-1962.0724
    , p2_a30  NUMBER := 0-1962.0724
    , p2_a31  NUMBER := 0-1962.0724
    , p2_a32  NUMBER := 0-1962.0724
    , p2_a33  NUMBER := 0-1962.0724
    , p2_a34  NUMBER := 0-1962.0724
    , p2_a35  VARCHAR2 := fnd_api.g_miss_char
    , p2_a36  NUMBER := 0-1962.0724
    , p2_a37  NUMBER := 0-1962.0724
    , p2_a38  NUMBER := 0-1962.0724
    , p2_a39  NUMBER := 0-1962.0724
    , p2_a40  DATE := fnd_api.g_miss_date
    , p2_a41  VARCHAR2 := fnd_api.g_miss_char
    , p2_a42  DATE := fnd_api.g_miss_date
    , p2_a43  DATE := fnd_api.g_miss_date
    , p2_a44  VARCHAR2 := fnd_api.g_miss_char
    , p2_a45  VARCHAR2 := fnd_api.g_miss_char
    , p2_a46  VARCHAR2 := fnd_api.g_miss_char
    , p2_a47  VARCHAR2 := fnd_api.g_miss_char
    , p2_a48  VARCHAR2 := fnd_api.g_miss_char
    , p2_a49  VARCHAR2 := fnd_api.g_miss_char
    , p2_a50  VARCHAR2 := fnd_api.g_miss_char
    , p2_a51  VARCHAR2 := fnd_api.g_miss_char
    , p2_a52  VARCHAR2 := fnd_api.g_miss_char
    , p2_a53  VARCHAR2 := fnd_api.g_miss_char
    , p2_a54  VARCHAR2 := fnd_api.g_miss_char
    , p2_a55  VARCHAR2 := fnd_api.g_miss_char
    , p2_a56  VARCHAR2 := fnd_api.g_miss_char
    , p2_a57  VARCHAR2 := fnd_api.g_miss_char
    , p2_a58  VARCHAR2 := fnd_api.g_miss_char
    , p2_a59  VARCHAR2 := fnd_api.g_miss_char
    , p2_a60  VARCHAR2 := fnd_api.g_miss_char
    , p2_a61  VARCHAR2 := fnd_api.g_miss_char
    , p2_a62  VARCHAR2 := fnd_api.g_miss_char
    , p2_a63  VARCHAR2 := fnd_api.g_miss_char
    , p2_a64  NUMBER := 0-1962.0724
    , p2_a65  NUMBER := 0-1962.0724
    , p2_a66  VARCHAR2 := fnd_api.g_miss_char
    , p2_a67  NUMBER := 0-1962.0724
    , p2_a68  VARCHAR2 := fnd_api.g_miss_char
    , p2_a69  VARCHAR2 := fnd_api.g_miss_char
    , p2_a70  VARCHAR2 := fnd_api.g_miss_char
    , p2_a71  VARCHAR2 := fnd_api.g_miss_char
    , p2_a72  NUMBER := 0-1962.0724
    , p2_a73  VARCHAR2 := fnd_api.g_miss_char
    , p2_a74  NUMBER := 0-1962.0724
    , p2_a75  NUMBER := 0-1962.0724
    , p2_a76  NUMBER := 0-1962.0724
    , p2_a77  VARCHAR2 := fnd_api.g_miss_char
    , p2_a78  VARCHAR2 := fnd_api.g_miss_char
    , p2_a79  VARCHAR2 := fnd_api.g_miss_char
    , p2_a80  NUMBER := 0-1962.0724
    , p2_a81  NUMBER := 0-1962.0724
    , p2_a82  NUMBER := 0-1962.0724
    , p2_a83  DATE := fnd_api.g_miss_date
    , p2_a84  VARCHAR2 := fnd_api.g_miss_char
    , p2_a85  VARCHAR2 := fnd_api.g_miss_char
    , p2_a86  VARCHAR2 := fnd_api.g_miss_char
    , p2_a87  NUMBER := 0-1962.0724
    , p2_a88  VARCHAR2 := fnd_api.g_miss_char
    , p2_a89  NUMBER := 0-1962.0724
    , p2_a90  NUMBER := 0-1962.0724
    , p2_a91  VARCHAR2 := fnd_api.g_miss_char
    , p2_a92  NUMBER := 0-1962.0724
    , p2_a93  VARCHAR2 := fnd_api.g_miss_char
    , p2_a94  NUMBER := 0-1962.0724
    , p2_a95  DATE := fnd_api.g_miss_date
    , p2_a96  VARCHAR2 := fnd_api.g_miss_char
    , p2_a97  VARCHAR2 := fnd_api.g_miss_char
    , p2_a98  VARCHAR2 := fnd_api.g_miss_char
    , p2_a99  VARCHAR2 := fnd_api.g_miss_char
    , p2_a100  VARCHAR2 := fnd_api.g_miss_char
    , p2_a101  VARCHAR2 := fnd_api.g_miss_char
    , p2_a102  VARCHAR2 := fnd_api.g_miss_char
    , p2_a103  VARCHAR2 := fnd_api.g_miss_char
    , p2_a104  VARCHAR2 := fnd_api.g_miss_char
    , p2_a105  VARCHAR2 := fnd_api.g_miss_char
    , p2_a106  VARCHAR2 := fnd_api.g_miss_char
    , p2_a107  VARCHAR2 := fnd_api.g_miss_char
    , p2_a108  VARCHAR2 := fnd_api.g_miss_char
    , p2_a109  VARCHAR2 := fnd_api.g_miss_char
    , p2_a110  VARCHAR2 := fnd_api.g_miss_char
    , p2_a111  NUMBER := 0-1962.0724
    , p2_a112  VARCHAR2 := fnd_api.g_miss_char
    , p2_a113  NUMBER := 0-1962.0724
    , p2_a114  VARCHAR2 := fnd_api.g_miss_char
    , p2_a115  NUMBER := 0-1962.0724
    , p2_a116  VARCHAR2 := fnd_api.g_miss_char
    , p2_a117  VARCHAR2 := fnd_api.g_miss_char
    , p2_a118  NUMBER := 0-1962.0724
    , p2_a119  VARCHAR2 := fnd_api.g_miss_char
    , p2_a120  NUMBER := 0-1962.0724
    , p2_a121  NUMBER := 0-1962.0724
    , p2_a122  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure copy_item_instance(p2_a0 JTF_VARCHAR2_TABLE_100
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_VARCHAR2_TABLE_300
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , p_copy_parties  VARCHAR2
    , p_copy_accounts  VARCHAR2
    , p_copy_contacts  VARCHAR2
    , p_copy_org_assignments  VARCHAR2
    , p_copy_asset_assignments  VARCHAR2
    , p_copy_pricing_attribs  VARCHAR2
    , p_copy_ext_attribs  VARCHAR2
    , p_copy_inst_children  VARCHAR2
    , p12_a0 in out nocopy  NUMBER
    , p12_a1 in out nocopy  DATE
    , p12_a2 in out nocopy  DATE
    , p12_a3 in out nocopy  NUMBER
    , p12_a4 in out nocopy  NUMBER
    , p12_a5 in out nocopy  NUMBER
    , p12_a6 in out nocopy  VARCHAR2
    , p12_a7 in out nocopy  NUMBER
    , p12_a8 in out nocopy  VARCHAR2
    , p12_a9 in out nocopy  NUMBER
    , p12_a10 in out nocopy  VARCHAR2
    , p12_a11 in out nocopy  NUMBER
    , p12_a12 in out nocopy  NUMBER
    , p12_a13 in out nocopy  NUMBER
    , p12_a14 in out nocopy  NUMBER
    , p12_a15 in out nocopy  VARCHAR2
    , p12_a16 in out nocopy  NUMBER
    , p12_a17 in out nocopy  VARCHAR2
    , p12_a18 in out nocopy  VARCHAR2
    , p12_a19 in out nocopy  NUMBER
    , p12_a20 in out nocopy  VARCHAR2
    , p12_a21 in out nocopy  VARCHAR2
    , p12_a22 in out nocopy  VARCHAR2
    , p12_a23 in out nocopy  VARCHAR2
    , p12_a24 in out nocopy  VARCHAR2
    , p12_a25 in out nocopy  VARCHAR2
    , p12_a26 in out nocopy  VARCHAR2
    , p12_a27 in out nocopy  VARCHAR2
    , p12_a28 in out nocopy  VARCHAR2
    , p12_a29 in out nocopy  VARCHAR2
    , p12_a30 in out nocopy  VARCHAR2
    , p12_a31 in out nocopy  VARCHAR2
    , p12_a32 in out nocopy  VARCHAR2
    , p12_a33 in out nocopy  VARCHAR2
    , p12_a34 in out nocopy  VARCHAR2
    , p12_a35 in out nocopy  VARCHAR2
    , p12_a36 in out nocopy  NUMBER
    , p12_a37 in out nocopy  VARCHAR2
    , p12_a38 in out nocopy  DATE
    , p12_a39 in out nocopy  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a3 out nocopy JTF_NUMBER_TABLE
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a6 out nocopy JTF_NUMBER_TABLE
    , p13_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a10 out nocopy JTF_NUMBER_TABLE
    , p13_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a13 out nocopy JTF_NUMBER_TABLE
    , p13_a14 out nocopy JTF_NUMBER_TABLE
    , p13_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a18 out nocopy JTF_NUMBER_TABLE
    , p13_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a20 out nocopy JTF_DATE_TABLE
    , p13_a21 out nocopy JTF_DATE_TABLE
    , p13_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a23 out nocopy JTF_NUMBER_TABLE
    , p13_a24 out nocopy JTF_NUMBER_TABLE
    , p13_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a26 out nocopy JTF_NUMBER_TABLE
    , p13_a27 out nocopy JTF_NUMBER_TABLE
    , p13_a28 out nocopy JTF_NUMBER_TABLE
    , p13_a29 out nocopy JTF_NUMBER_TABLE
    , p13_a30 out nocopy JTF_NUMBER_TABLE
    , p13_a31 out nocopy JTF_NUMBER_TABLE
    , p13_a32 out nocopy JTF_NUMBER_TABLE
    , p13_a33 out nocopy JTF_NUMBER_TABLE
    , p13_a34 out nocopy JTF_NUMBER_TABLE
    , p13_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a36 out nocopy JTF_NUMBER_TABLE
    , p13_a37 out nocopy JTF_NUMBER_TABLE
    , p13_a38 out nocopy JTF_NUMBER_TABLE
    , p13_a39 out nocopy JTF_NUMBER_TABLE
    , p13_a40 out nocopy JTF_DATE_TABLE
    , p13_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a42 out nocopy JTF_DATE_TABLE
    , p13_a43 out nocopy JTF_DATE_TABLE
    , p13_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a48 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a64 out nocopy JTF_NUMBER_TABLE
    , p13_a65 out nocopy JTF_NUMBER_TABLE
    , p13_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a67 out nocopy JTF_NUMBER_TABLE
    , p13_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a72 out nocopy JTF_NUMBER_TABLE
    , p13_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a74 out nocopy JTF_NUMBER_TABLE
    , p13_a75 out nocopy JTF_NUMBER_TABLE
    , p13_a76 out nocopy JTF_NUMBER_TABLE
    , p13_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a80 out nocopy JTF_NUMBER_TABLE
    , p13_a81 out nocopy JTF_NUMBER_TABLE
    , p13_a82 out nocopy JTF_NUMBER_TABLE
    , p13_a83 out nocopy JTF_DATE_TABLE
    , p13_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a86 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a87 out nocopy JTF_NUMBER_TABLE
    , p13_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a89 out nocopy JTF_NUMBER_TABLE
    , p13_a90 out nocopy JTF_NUMBER_TABLE
    , p13_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a92 out nocopy JTF_NUMBER_TABLE
    , p13_a93 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a94 out nocopy JTF_NUMBER_TABLE
    , p13_a95 out nocopy JTF_DATE_TABLE
    , p13_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p13_a111 out nocopy JTF_NUMBER_TABLE
    , p13_a112 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a113 out nocopy JTF_NUMBER_TABLE
    , p13_a114 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a115 out nocopy JTF_NUMBER_TABLE
    , p13_a116 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a117 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a118 out nocopy JTF_NUMBER_TABLE
    , p13_a119 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a120 out nocopy JTF_NUMBER_TABLE
    , p13_a121 out nocopy JTF_NUMBER_TABLE
    , p13_a122 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p14_a8 out nocopy JTF_DATE_TABLE
    , p14_a9 out nocopy JTF_NUMBER_TABLE
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_NUMBER_TABLE
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 out nocopy JTF_NUMBER_TABLE
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  NUMBER := 0-1962.0724
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  DATE := fnd_api.g_miss_date
    , p1_a21  DATE := fnd_api.g_miss_date
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  NUMBER := 0-1962.0724
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  NUMBER := 0-1962.0724
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  NUMBER := 0-1962.0724
    , p1_a31  NUMBER := 0-1962.0724
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  NUMBER := 0-1962.0724
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  NUMBER := 0-1962.0724
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  DATE := fnd_api.g_miss_date
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  DATE := fnd_api.g_miss_date
    , p1_a43  DATE := fnd_api.g_miss_date
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  VARCHAR2 := fnd_api.g_miss_char
    , p1_a46  VARCHAR2 := fnd_api.g_miss_char
    , p1_a47  VARCHAR2 := fnd_api.g_miss_char
    , p1_a48  VARCHAR2 := fnd_api.g_miss_char
    , p1_a49  VARCHAR2 := fnd_api.g_miss_char
    , p1_a50  VARCHAR2 := fnd_api.g_miss_char
    , p1_a51  VARCHAR2 := fnd_api.g_miss_char
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  VARCHAR2 := fnd_api.g_miss_char
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  NUMBER := 0-1962.0724
    , p1_a65  NUMBER := 0-1962.0724
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  NUMBER := 0-1962.0724
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  NUMBER := 0-1962.0724
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  NUMBER := 0-1962.0724
    , p1_a75  NUMBER := 0-1962.0724
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  VARCHAR2 := fnd_api.g_miss_char
    , p1_a79  VARCHAR2 := fnd_api.g_miss_char
    , p1_a80  NUMBER := 0-1962.0724
    , p1_a81  NUMBER := 0-1962.0724
    , p1_a82  NUMBER := 0-1962.0724
    , p1_a83  DATE := fnd_api.g_miss_date
    , p1_a84  VARCHAR2 := fnd_api.g_miss_char
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  NUMBER := 0-1962.0724
    , p1_a88  VARCHAR2 := fnd_api.g_miss_char
    , p1_a89  NUMBER := 0-1962.0724
    , p1_a90  NUMBER := 0-1962.0724
    , p1_a91  VARCHAR2 := fnd_api.g_miss_char
    , p1_a92  NUMBER := 0-1962.0724
    , p1_a93  VARCHAR2 := fnd_api.g_miss_char
    , p1_a94  NUMBER := 0-1962.0724
    , p1_a95  DATE := fnd_api.g_miss_date
    , p1_a96  VARCHAR2 := fnd_api.g_miss_char
    , p1_a97  VARCHAR2 := fnd_api.g_miss_char
    , p1_a98  VARCHAR2 := fnd_api.g_miss_char
    , p1_a99  VARCHAR2 := fnd_api.g_miss_char
    , p1_a100  VARCHAR2 := fnd_api.g_miss_char
    , p1_a101  VARCHAR2 := fnd_api.g_miss_char
    , p1_a102  VARCHAR2 := fnd_api.g_miss_char
    , p1_a103  VARCHAR2 := fnd_api.g_miss_char
    , p1_a104  VARCHAR2 := fnd_api.g_miss_char
    , p1_a105  VARCHAR2 := fnd_api.g_miss_char
    , p1_a106  VARCHAR2 := fnd_api.g_miss_char
    , p1_a107  VARCHAR2 := fnd_api.g_miss_char
    , p1_a108  VARCHAR2 := fnd_api.g_miss_char
    , p1_a109  VARCHAR2 := fnd_api.g_miss_char
    , p1_a110  VARCHAR2 := fnd_api.g_miss_char
    , p1_a111  NUMBER := 0-1962.0724
    , p1_a112  VARCHAR2 := fnd_api.g_miss_char
    , p1_a113  NUMBER := 0-1962.0724
    , p1_a114  VARCHAR2 := fnd_api.g_miss_char
    , p1_a115  NUMBER := 0-1962.0724
    , p1_a116  VARCHAR2 := fnd_api.g_miss_char
    , p1_a117  VARCHAR2 := fnd_api.g_miss_char
    , p1_a118  NUMBER := 0-1962.0724
    , p1_a119  VARCHAR2 := fnd_api.g_miss_char
    , p1_a120  NUMBER := 0-1962.0724
    , p1_a121  NUMBER := 0-1962.0724
    , p1_a122  VARCHAR2 := fnd_api.g_miss_char
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
  );
  procedure associate_item_instance(p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_VARCHAR2_TABLE_100
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p1_a10 JTF_NUMBER_TABLE
    , p1_a11 JTF_VARCHAR2_TABLE_100
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_VARCHAR2_TABLE_100
    , p1_a16 JTF_VARCHAR2_TABLE_100
    , p1_a17 JTF_VARCHAR2_TABLE_100
    , p1_a18 JTF_NUMBER_TABLE
    , p1_a19 JTF_VARCHAR2_TABLE_100
    , p1_a20 JTF_DATE_TABLE
    , p1_a21 JTF_DATE_TABLE
    , p1_a22 JTF_VARCHAR2_TABLE_100
    , p1_a23 JTF_NUMBER_TABLE
    , p1_a24 JTF_NUMBER_TABLE
    , p1_a25 JTF_VARCHAR2_TABLE_100
    , p1_a26 JTF_NUMBER_TABLE
    , p1_a27 JTF_NUMBER_TABLE
    , p1_a28 JTF_NUMBER_TABLE
    , p1_a29 JTF_NUMBER_TABLE
    , p1_a30 JTF_NUMBER_TABLE
    , p1_a31 JTF_NUMBER_TABLE
    , p1_a32 JTF_NUMBER_TABLE
    , p1_a33 JTF_NUMBER_TABLE
    , p1_a34 JTF_NUMBER_TABLE
    , p1_a35 JTF_VARCHAR2_TABLE_100
    , p1_a36 JTF_NUMBER_TABLE
    , p1_a37 JTF_NUMBER_TABLE
    , p1_a38 JTF_NUMBER_TABLE
    , p1_a39 JTF_NUMBER_TABLE
    , p1_a40 JTF_DATE_TABLE
    , p1_a41 JTF_VARCHAR2_TABLE_100
    , p1_a42 JTF_DATE_TABLE
    , p1_a43 JTF_DATE_TABLE
    , p1_a44 JTF_VARCHAR2_TABLE_100
    , p1_a45 JTF_VARCHAR2_TABLE_100
    , p1_a46 JTF_VARCHAR2_TABLE_300
    , p1_a47 JTF_VARCHAR2_TABLE_300
    , p1_a48 JTF_VARCHAR2_TABLE_100
    , p1_a49 JTF_VARCHAR2_TABLE_300
    , p1_a50 JTF_VARCHAR2_TABLE_300
    , p1_a51 JTF_VARCHAR2_TABLE_300
    , p1_a52 JTF_VARCHAR2_TABLE_300
    , p1_a53 JTF_VARCHAR2_TABLE_300
    , p1_a54 JTF_VARCHAR2_TABLE_300
    , p1_a55 JTF_VARCHAR2_TABLE_300
    , p1_a56 JTF_VARCHAR2_TABLE_300
    , p1_a57 JTF_VARCHAR2_TABLE_300
    , p1_a58 JTF_VARCHAR2_TABLE_300
    , p1_a59 JTF_VARCHAR2_TABLE_300
    , p1_a60 JTF_VARCHAR2_TABLE_300
    , p1_a61 JTF_VARCHAR2_TABLE_300
    , p1_a62 JTF_VARCHAR2_TABLE_300
    , p1_a63 JTF_VARCHAR2_TABLE_300
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_VARCHAR2_TABLE_100
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_VARCHAR2_TABLE_100
    , p1_a69 JTF_VARCHAR2_TABLE_100
    , p1_a70 JTF_VARCHAR2_TABLE_100
    , p1_a71 JTF_VARCHAR2_TABLE_100
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_VARCHAR2_TABLE_100
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_NUMBER_TABLE
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_VARCHAR2_TABLE_100
    , p1_a78 JTF_VARCHAR2_TABLE_300
    , p1_a79 JTF_VARCHAR2_TABLE_100
    , p1_a80 JTF_NUMBER_TABLE
    , p1_a81 JTF_NUMBER_TABLE
    , p1_a82 JTF_NUMBER_TABLE
    , p1_a83 JTF_DATE_TABLE
    , p1_a84 JTF_VARCHAR2_TABLE_100
    , p1_a85 JTF_VARCHAR2_TABLE_100
    , p1_a86 JTF_VARCHAR2_TABLE_100
    , p1_a87 JTF_NUMBER_TABLE
    , p1_a88 JTF_VARCHAR2_TABLE_100
    , p1_a89 JTF_NUMBER_TABLE
    , p1_a90 JTF_NUMBER_TABLE
    , p1_a91 JTF_VARCHAR2_TABLE_100
    , p1_a92 JTF_NUMBER_TABLE
    , p1_a93 JTF_VARCHAR2_TABLE_100
    , p1_a94 JTF_NUMBER_TABLE
    , p1_a95 JTF_DATE_TABLE
    , p1_a96 JTF_VARCHAR2_TABLE_300
    , p1_a97 JTF_VARCHAR2_TABLE_300
    , p1_a98 JTF_VARCHAR2_TABLE_300
    , p1_a99 JTF_VARCHAR2_TABLE_300
    , p1_a100 JTF_VARCHAR2_TABLE_300
    , p1_a101 JTF_VARCHAR2_TABLE_300
    , p1_a102 JTF_VARCHAR2_TABLE_300
    , p1_a103 JTF_VARCHAR2_TABLE_300
    , p1_a104 JTF_VARCHAR2_TABLE_300
    , p1_a105 JTF_VARCHAR2_TABLE_300
    , p1_a106 JTF_VARCHAR2_TABLE_300
    , p1_a107 JTF_VARCHAR2_TABLE_300
    , p1_a108 JTF_VARCHAR2_TABLE_300
    , p1_a109 JTF_VARCHAR2_TABLE_300
    , p1_a110 JTF_VARCHAR2_TABLE_300
    , p1_a111 JTF_NUMBER_TABLE
    , p1_a112 JTF_VARCHAR2_TABLE_100
    , p1_a113 JTF_NUMBER_TABLE
    , p1_a114 JTF_VARCHAR2_TABLE_100
    , p1_a115 JTF_NUMBER_TABLE
    , p1_a116 JTF_VARCHAR2_TABLE_100
    , p1_a117 JTF_VARCHAR2_TABLE_100
    , p1_a118 JTF_NUMBER_TABLE
    , p1_a119 JTF_VARCHAR2_TABLE_100
    , p1_a120 JTF_NUMBER_TABLE
    , p1_a121 JTF_NUMBER_TABLE
    , p1_a122 JTF_VARCHAR2_TABLE_100
    , p2_a0 in out nocopy  NUMBER
    , p2_a1 in out nocopy  DATE
    , p2_a2 in out nocopy  DATE
    , p2_a3 in out nocopy  NUMBER
    , p2_a4 in out nocopy  NUMBER
    , p2_a5 in out nocopy  NUMBER
    , p2_a6 in out nocopy  VARCHAR2
    , p2_a7 in out nocopy  NUMBER
    , p2_a8 in out nocopy  VARCHAR2
    , p2_a9 in out nocopy  NUMBER
    , p2_a10 in out nocopy  VARCHAR2
    , p2_a11 in out nocopy  NUMBER
    , p2_a12 in out nocopy  NUMBER
    , p2_a13 in out nocopy  NUMBER
    , p2_a14 in out nocopy  NUMBER
    , p2_a15 in out nocopy  VARCHAR2
    , p2_a16 in out nocopy  NUMBER
    , p2_a17 in out nocopy  VARCHAR2
    , p2_a18 in out nocopy  VARCHAR2
    , p2_a19 in out nocopy  NUMBER
    , p2_a20 in out nocopy  VARCHAR2
    , p2_a21 in out nocopy  VARCHAR2
    , p2_a22 in out nocopy  VARCHAR2
    , p2_a23 in out nocopy  VARCHAR2
    , p2_a24 in out nocopy  VARCHAR2
    , p2_a25 in out nocopy  VARCHAR2
    , p2_a26 in out nocopy  VARCHAR2
    , p2_a27 in out nocopy  VARCHAR2
    , p2_a28 in out nocopy  VARCHAR2
    , p2_a29 in out nocopy  VARCHAR2
    , p2_a30 in out nocopy  VARCHAR2
    , p2_a31 in out nocopy  VARCHAR2
    , p2_a32 in out nocopy  VARCHAR2
    , p2_a33 in out nocopy  VARCHAR2
    , p2_a34 in out nocopy  VARCHAR2
    , p2_a35 in out nocopy  VARCHAR2
    , p2_a36 in out nocopy  NUMBER
    , p2_a37 in out nocopy  VARCHAR2
    , p2_a38 in out nocopy  DATE
    , p2_a39 in out nocopy  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_NUMBER_TABLE
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a7 out nocopy JTF_DATE_TABLE
    , p3_a8 out nocopy JTF_DATE_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_asset_association(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_VARCHAR2_TABLE_100
    , p0_a7 JTF_DATE_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_VARCHAR2_TABLE_100
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_VARCHAR2_TABLE_100
    , p0_a15 JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  DATE
    , p1_a3 in out nocopy  NUMBER
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  VARCHAR2
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  VARCHAR2
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  NUMBER
    , p1_a15 in out nocopy  VARCHAR2
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  VARCHAR2
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  VARCHAR2
    , p1_a22 in out nocopy  VARCHAR2
    , p1_a23 in out nocopy  VARCHAR2
    , p1_a24 in out nocopy  VARCHAR2
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  VARCHAR2
    , p1_a29 in out nocopy  VARCHAR2
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  DATE
    , p1_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
  );
  procedure create_instance_assets(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_NUMBER_TABLE
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_DATE_TABLE
    , p0_a8 in out nocopy JTF_DATE_TABLE
    , p0_a9 in out nocopy JTF_NUMBER_TABLE
    , p0_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a11 in out nocopy JTF_NUMBER_TABLE
    , p0_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a13 in out nocopy JTF_NUMBER_TABLE
    , p0_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a15 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  DATE
    , p1_a3 in out nocopy  NUMBER
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  VARCHAR2
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  NUMBER
    , p1_a10 in out nocopy  VARCHAR2
    , p1_a11 in out nocopy  NUMBER
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  NUMBER
    , p1_a15 in out nocopy  VARCHAR2
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  VARCHAR2
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  VARCHAR2
    , p1_a22 in out nocopy  VARCHAR2
    , p1_a23 in out nocopy  VARCHAR2
    , p1_a24 in out nocopy  VARCHAR2
    , p1_a25 in out nocopy  VARCHAR2
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  VARCHAR2
    , p1_a28 in out nocopy  VARCHAR2
    , p1_a29 in out nocopy  VARCHAR2
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  VARCHAR2
    , p1_a32 in out nocopy  VARCHAR2
    , p1_a33 in out nocopy  VARCHAR2
    , p1_a34 in out nocopy  VARCHAR2
    , p1_a35 in out nocopy  VARCHAR2
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  VARCHAR2
    , p1_a38 in out nocopy  DATE
    , p1_a39 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_error_message out nocopy  VARCHAR2
  );
end csi_fa_instance_grp_w;

/
