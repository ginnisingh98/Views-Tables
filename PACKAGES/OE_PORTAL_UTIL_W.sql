--------------------------------------------------------
--  DDL for Package OE_PORTAL_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PORTAL_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: OERUPORS.pls 120.0 2005/06/01 02:00:42 appldev noship $ */
  procedure get_values(p2_a0 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a1 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a2 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a3 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a4 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a5 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a6 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a7 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a8 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a9 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a10 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a11 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a12 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a13 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a14 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a15 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a16 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a17 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a18 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a19 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a20 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a21 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a22 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a23 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a24 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a25 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a26 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a27 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a29 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a30 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a31 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a32 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a33 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a35 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a36 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a37 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a38 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a39 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a40 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a41 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a42 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a43 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a44 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a45 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a46 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a47 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p2_a48 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p2_a49 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p2_a50 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a51 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a52 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a53 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a54 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a55 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a56 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a57 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a58 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a59 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a60 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a61 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a62 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a63 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a64 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a65 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a66 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a67 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a68 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a69 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a70 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a71 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a72 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a73 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a74 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a75 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a76 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a77 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a78 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a79 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a80 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a81 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a82 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a83 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a84 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a85 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a87 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a88 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a89 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a90 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a91 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a92 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a93 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a94 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a95 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a96 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a97 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a98 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a99 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a100 out NOCOPY /* file.sql.39 change */  NUMBER
    , p2_a101 out NOCOPY /* file.sql.39 change */  NUMBER
    , p2_a102 out NOCOPY /* file.sql.39 change */  NUMBER
    , p2_a103 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a105 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a106 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a107 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a109 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a110 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a111 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a112 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a113 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a114 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a115 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a116 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a117 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a118 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a119 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a120 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a122 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a123 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a124 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a125 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a126 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a127 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a128 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a129 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a130 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a131 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a132 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a133 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a135 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a136 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a138 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p2_a141 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  DATE := fnd_api.g_miss_date
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  NUMBER := 0-1962.0724
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  NUMBER := 0-1962.0724
    , p0_a81  NUMBER := 0-1962.0724
    , p0_a82  DATE := fnd_api.g_miss_date
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  DATE := fnd_api.g_miss_date
    , p0_a88  VARCHAR2 := fnd_api.g_miss_char
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  NUMBER := 0-1962.0724
    , p0_a93  VARCHAR2 := fnd_api.g_miss_char
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  DATE := fnd_api.g_miss_date
    , p0_a99  NUMBER := 0-1962.0724
    , p0_a100  NUMBER := 0-1962.0724
    , p0_a101  DATE := fnd_api.g_miss_date
    , p0_a102  DATE := fnd_api.g_miss_date
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  VARCHAR2 := fnd_api.g_miss_char
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  VARCHAR2 := fnd_api.g_miss_char
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p0_a109  NUMBER := 0-1962.0724
    , p0_a110  NUMBER := 0-1962.0724
    , p0_a111  NUMBER := 0-1962.0724
    , p0_a112  NUMBER := 0-1962.0724
    , p0_a113  NUMBER := 0-1962.0724
    , p0_a114  NUMBER := 0-1962.0724
    , p0_a115  NUMBER := 0-1962.0724
    , p0_a116  NUMBER := 0-1962.0724
    , p0_a117  NUMBER := 0-1962.0724
    , p0_a118  NUMBER := 0-1962.0724
    , p0_a119  NUMBER := 0-1962.0724
    , p0_a120  VARCHAR2 := fnd_api.g_miss_char
    , p0_a121  VARCHAR2 := fnd_api.g_miss_char
    , p0_a122  VARCHAR2 := fnd_api.g_miss_char
    , p0_a123  VARCHAR2 := fnd_api.g_miss_char
    , p0_a124  VARCHAR2 := fnd_api.g_miss_char
    , p0_a125  NUMBER := 0-1962.0724
    , p0_a126  VARCHAR2 := fnd_api.g_miss_char
    , p0_a127  VARCHAR2 := fnd_api.g_miss_char
    , p0_a128  VARCHAR2 := fnd_api.g_miss_char
    , p0_a129  VARCHAR2 := fnd_api.g_miss_char
    , p0_a130  DATE := fnd_api.g_miss_date
    , p0_a131  VARCHAR2 := fnd_api.g_miss_char
    , p0_a132  DATE := fnd_api.g_miss_date
    , p0_a133  VARCHAR2 := fnd_api.g_miss_char
    , p0_a134  VARCHAR2 := fnd_api.g_miss_char
    , p0_a135  VARCHAR2 := fnd_api.g_miss_char
    , p0_a136  VARCHAR2 := fnd_api.g_miss_char
    , p0_a137  VARCHAR2 := fnd_api.g_miss_char
    , p0_a138  VARCHAR2 := fnd_api.g_miss_char
    , p0_a139  VARCHAR2 := fnd_api.g_miss_char
    , p0_a140  VARCHAR2 := fnd_api.g_miss_char
    , p0_a141  NUMBER := 0-1962.0724
    , p0_a142  VARCHAR2 := fnd_api.g_miss_char
    , p0_a143  NUMBER := 0-1962.0724
    , p0_a144  VARCHAR2 := fnd_api.g_miss_char
    , p0_a145  VARCHAR2 := fnd_api.g_miss_char
    , p0_a146  VARCHAR2 := fnd_api.g_miss_char
    , p0_a147  VARCHAR2 := fnd_api.g_miss_char
    , p0_a148  DATE := fnd_api.g_miss_date
    , p0_a149  VARCHAR2 := fnd_api.g_miss_char
    , p0_a150  DATE := fnd_api.g_miss_date
    , p0_a151  VARCHAR2 := fnd_api.g_miss_char
    , p0_a152  VARCHAR2 := fnd_api.g_miss_char
    , p0_a153  VARCHAR2 := fnd_api.g_miss_char
    , p0_a154  DATE := fnd_api.g_miss_date
    , p0_a155  NUMBER := 0-1962.0724
    , p0_a156  VARCHAR2 := fnd_api.g_miss_char
    , p0_a157  NUMBER := 0-1962.0724
    , p0_a158  VARCHAR2 := fnd_api.g_miss_char
    , p0_a159  VARCHAR2 := fnd_api.g_miss_char
    , p0_a160  VARCHAR2 := fnd_api.g_miss_char
    , p0_a161  VARCHAR2 := fnd_api.g_miss_char
    , p0_a162  NUMBER := 0-1962.0724
    , p0_a163  NUMBER := 0-1962.0724
    , p0_a164  NUMBER := 0-1962.0724
    , p0_a165  NUMBER := 0-1962.0724
    , p0_a166  VARCHAR2 := fnd_api.g_miss_char
    , p0_a167  NUMBER := 0-1962.0724
    , p0_a168  NUMBER := 0-1962.0724
    , p0_a169  NUMBER := 0-1962.0724
    , p0_a170  NUMBER := 0-1962.0724
    , p0_a171  NUMBER := 0-1962.0724
    , p0_a172  VARCHAR2 := fnd_api.g_miss_char
    , p0_a173  NUMBER := 0-1962.0724
    , p0_a174  VARCHAR2 := fnd_api.g_miss_char
    , p0_a175  VARCHAR2 := fnd_api.g_miss_char
    , p0_a176  VARCHAR2 := fnd_api.g_miss_char
    , p0_a177  DATE := fnd_api.g_miss_date
    , p0_a178  NUMBER := 0-1962.0724
    , p0_a179  VARCHAR2 := fnd_api.g_miss_char
    , p0_a180  VARCHAR2 := fnd_api.g_miss_char
    , p0_a181  VARCHAR2 := fnd_api.g_miss_char
    , p0_a182  VARCHAR2 := fnd_api.g_miss_char
    , p0_a183  NUMBER := 0-1962.0724
    , p0_a184  NUMBER := 0-1962.0724
    , p0_a185  NUMBER := 0-1962.0724
    , p0_a186  VARCHAR2 := fnd_api.g_miss_char
    , p0_a187  VARCHAR2 := fnd_api.g_miss_char
    , p0_a188  VARCHAR2 := fnd_api.g_miss_char
    , p0_a189  NUMBER := 0-1962.0724
    , p0_a190  NUMBER := 0-1962.0724
    , p0_a191  NUMBER := 0-1962.0724
    , p0_a192  VARCHAR2 := fnd_api.g_miss_char
    , p0_a193  DATE := fnd_api.g_miss_date
    , p0_a194  VARCHAR2 := fnd_api.g_miss_char
    , p0_a195  DATE := fnd_api.g_miss_date
    , p0_a196  NUMBER := 0-1962.0724
    , p0_a197  NUMBER := 0-1962.0724
    , p0_a198  NUMBER := 0-1962.0724
    , p0_a199  NUMBER := 0-1962.0724
    , p0_a200  NUMBER := 0-1962.0724
    , p0_a201  NUMBER := 0-1962.0724
    , p0_a202  NUMBER := 0-1962.0724
    , p0_a203  NUMBER := 0-1962.0724
    , p0_a204  NUMBER := 0-1962.0724
    , p0_a205  NUMBER := 0-1962.0724
    , p0_a206  NUMBER := 0-1962.0724
    , p0_a207  NUMBER := 0-1962.0724
    , p0_a208  NUMBER := 0-1962.0724
    , p0_a209  NUMBER := 0-1962.0724
    , p0_a210  NUMBER := 0-1962.0724
    , p0_a211  NUMBER := 0-1962.0724
    , p0_a212  NUMBER := 0-1962.0724
    , p0_a213  NUMBER := 0-1962.0724
    , p0_a214  VARCHAR2 := fnd_api.g_miss_char
    , p0_a215  NUMBER := 0-1962.0724
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  NUMBER := 0-1962.0724
    , p1_a26  DATE := fnd_api.g_miss_date
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  DATE := fnd_api.g_miss_date
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  NUMBER := 0-1962.0724
    , p1_a36  DATE := fnd_api.g_miss_date
    , p1_a37  VARCHAR2 := fnd_api.g_miss_char
    , p1_a38  VARCHAR2 := fnd_api.g_miss_char
    , p1_a39  VARCHAR2 := fnd_api.g_miss_char
    , p1_a40  VARCHAR2 := fnd_api.g_miss_char
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  VARCHAR2 := fnd_api.g_miss_char
    , p1_a43  VARCHAR2 := fnd_api.g_miss_char
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
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  VARCHAR2 := fnd_api.g_miss_char
    , p1_a77  NUMBER := 0-1962.0724
    , p1_a78  NUMBER := 0-1962.0724
    , p1_a79  NUMBER := 0-1962.0724
    , p1_a80  NUMBER := 0-1962.0724
    , p1_a81  NUMBER := 0-1962.0724
    , p1_a82  DATE := fnd_api.g_miss_date
    , p1_a83  NUMBER := 0-1962.0724
    , p1_a84  NUMBER := 0-1962.0724
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  DATE := fnd_api.g_miss_date
    , p1_a88  VARCHAR2 := fnd_api.g_miss_char
    , p1_a89  NUMBER := 0-1962.0724
    , p1_a90  NUMBER := 0-1962.0724
    , p1_a91  NUMBER := 0-1962.0724
    , p1_a92  NUMBER := 0-1962.0724
    , p1_a93  VARCHAR2 := fnd_api.g_miss_char
    , p1_a94  VARCHAR2 := fnd_api.g_miss_char
    , p1_a95  NUMBER := 0-1962.0724
    , p1_a96  NUMBER := 0-1962.0724
    , p1_a97  VARCHAR2 := fnd_api.g_miss_char
    , p1_a98  DATE := fnd_api.g_miss_date
    , p1_a99  NUMBER := 0-1962.0724
    , p1_a100  NUMBER := 0-1962.0724
    , p1_a101  DATE := fnd_api.g_miss_date
    , p1_a102  DATE := fnd_api.g_miss_date
    , p1_a103  NUMBER := 0-1962.0724
    , p1_a104  VARCHAR2 := fnd_api.g_miss_char
    , p1_a105  NUMBER := 0-1962.0724
    , p1_a106  VARCHAR2 := fnd_api.g_miss_char
    , p1_a107  VARCHAR2 := fnd_api.g_miss_char
    , p1_a108  VARCHAR2 := fnd_api.g_miss_char
    , p1_a109  NUMBER := 0-1962.0724
    , p1_a110  NUMBER := 0-1962.0724
    , p1_a111  NUMBER := 0-1962.0724
    , p1_a112  NUMBER := 0-1962.0724
    , p1_a113  NUMBER := 0-1962.0724
    , p1_a114  NUMBER := 0-1962.0724
    , p1_a115  NUMBER := 0-1962.0724
    , p1_a116  NUMBER := 0-1962.0724
    , p1_a117  NUMBER := 0-1962.0724
    , p1_a118  NUMBER := 0-1962.0724
    , p1_a119  NUMBER := 0-1962.0724
    , p1_a120  VARCHAR2 := fnd_api.g_miss_char
    , p1_a121  VARCHAR2 := fnd_api.g_miss_char
    , p1_a122  VARCHAR2 := fnd_api.g_miss_char
    , p1_a123  VARCHAR2 := fnd_api.g_miss_char
    , p1_a124  VARCHAR2 := fnd_api.g_miss_char
    , p1_a125  NUMBER := 0-1962.0724
    , p1_a126  VARCHAR2 := fnd_api.g_miss_char
    , p1_a127  VARCHAR2 := fnd_api.g_miss_char
    , p1_a128  VARCHAR2 := fnd_api.g_miss_char
    , p1_a129  VARCHAR2 := fnd_api.g_miss_char
    , p1_a130  DATE := fnd_api.g_miss_date
    , p1_a131  VARCHAR2 := fnd_api.g_miss_char
    , p1_a132  DATE := fnd_api.g_miss_date
    , p1_a133  VARCHAR2 := fnd_api.g_miss_char
    , p1_a134  VARCHAR2 := fnd_api.g_miss_char
    , p1_a135  VARCHAR2 := fnd_api.g_miss_char
    , p1_a136  VARCHAR2 := fnd_api.g_miss_char
    , p1_a137  VARCHAR2 := fnd_api.g_miss_char
    , p1_a138  VARCHAR2 := fnd_api.g_miss_char
    , p1_a139  VARCHAR2 := fnd_api.g_miss_char
    , p1_a140  VARCHAR2 := fnd_api.g_miss_char
    , p1_a141  NUMBER := 0-1962.0724
    , p1_a142  VARCHAR2 := fnd_api.g_miss_char
    , p1_a143  NUMBER := 0-1962.0724
    , p1_a144  VARCHAR2 := fnd_api.g_miss_char
    , p1_a145  VARCHAR2 := fnd_api.g_miss_char
    , p1_a146  VARCHAR2 := fnd_api.g_miss_char
    , p1_a147  VARCHAR2 := fnd_api.g_miss_char
    , p1_a148  DATE := fnd_api.g_miss_date
    , p1_a149  VARCHAR2 := fnd_api.g_miss_char
    , p1_a150  DATE := fnd_api.g_miss_date
    , p1_a151  VARCHAR2 := fnd_api.g_miss_char
    , p1_a152  VARCHAR2 := fnd_api.g_miss_char
    , p1_a153  VARCHAR2 := fnd_api.g_miss_char
    , p1_a154  DATE := fnd_api.g_miss_date
    , p1_a155  NUMBER := 0-1962.0724
    , p1_a156  VARCHAR2 := fnd_api.g_miss_char
    , p1_a157  NUMBER := 0-1962.0724
    , p1_a158  VARCHAR2 := fnd_api.g_miss_char
    , p1_a159  VARCHAR2 := fnd_api.g_miss_char
    , p1_a160  VARCHAR2 := fnd_api.g_miss_char
    , p1_a161  VARCHAR2 := fnd_api.g_miss_char
    , p1_a162  NUMBER := 0-1962.0724
    , p1_a163  NUMBER := 0-1962.0724
    , p1_a164  NUMBER := 0-1962.0724
    , p1_a165  NUMBER := 0-1962.0724
    , p1_a166  VARCHAR2 := fnd_api.g_miss_char
    , p1_a167  NUMBER := 0-1962.0724
    , p1_a168  NUMBER := 0-1962.0724
    , p1_a169  NUMBER := 0-1962.0724
    , p1_a170  NUMBER := 0-1962.0724
    , p1_a171  NUMBER := 0-1962.0724
    , p1_a172  VARCHAR2 := fnd_api.g_miss_char
    , p1_a173  NUMBER := 0-1962.0724
    , p1_a174  VARCHAR2 := fnd_api.g_miss_char
    , p1_a175  VARCHAR2 := fnd_api.g_miss_char
    , p1_a176  VARCHAR2 := fnd_api.g_miss_char
    , p1_a177  DATE := fnd_api.g_miss_date
    , p1_a178  NUMBER := 0-1962.0724
    , p1_a179  VARCHAR2 := fnd_api.g_miss_char
    , p1_a180  VARCHAR2 := fnd_api.g_miss_char
    , p1_a181  VARCHAR2 := fnd_api.g_miss_char
    , p1_a182  VARCHAR2 := fnd_api.g_miss_char
    , p1_a183  NUMBER := 0-1962.0724
    , p1_a184  NUMBER := 0-1962.0724
    , p1_a185  NUMBER := 0-1962.0724
    , p1_a186  VARCHAR2 := fnd_api.g_miss_char
    , p1_a187  VARCHAR2 := fnd_api.g_miss_char
    , p1_a188  VARCHAR2 := fnd_api.g_miss_char
    , p1_a189  NUMBER := 0-1962.0724
    , p1_a190  NUMBER := 0-1962.0724
    , p1_a191  NUMBER := 0-1962.0724
    , p1_a192  VARCHAR2 := fnd_api.g_miss_char
    , p1_a193  DATE := fnd_api.g_miss_date
    , p1_a194  VARCHAR2 := fnd_api.g_miss_char
    , p1_a195  DATE := fnd_api.g_miss_date
    , p1_a196  NUMBER := 0-1962.0724
    , p1_a197  NUMBER := 0-1962.0724
    , p1_a198  NUMBER := 0-1962.0724
    , p1_a199  NUMBER := 0-1962.0724
    , p1_a200  NUMBER := 0-1962.0724
    , p1_a201  NUMBER := 0-1962.0724
    , p1_a202  NUMBER := 0-1962.0724
    , p1_a203  NUMBER := 0-1962.0724
    , p1_a204  NUMBER := 0-1962.0724
    , p1_a205  NUMBER := 0-1962.0724
    , p1_a206  NUMBER := 0-1962.0724
    , p1_a207  NUMBER := 0-1962.0724
    , p1_a208  NUMBER := 0-1962.0724
    , p1_a209  NUMBER := 0-1962.0724
    , p1_a210  NUMBER := 0-1962.0724
    , p1_a211  NUMBER := 0-1962.0724
    , p1_a212  NUMBER := 0-1962.0724
    , p1_a213  NUMBER := 0-1962.0724
    , p1_a214  VARCHAR2 := fnd_api.g_miss_char
    , p1_a215  NUMBER := 0-1962.0724
  );
  procedure lines(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  NUMBER
    , p2_a12  NUMBER
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  NUMBER
    , p3_a0 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a2 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a3 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a4 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a5 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a6 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a7 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a8 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a9 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a10 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a11 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a12 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a13 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p3_a14 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a15 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a16 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a17 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a18 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a19 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a20 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a21 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a22 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a23 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a24 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a25 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a26 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a27 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a28 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a29 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a30 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a31 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a32 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a33 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a34 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a35 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a36 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a37 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a38 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a39 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a40 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a41 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a42 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a43 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a44 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a45 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a46 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a47 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a48 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a49 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a50 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a51 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a52 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a53 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a54 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a55 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a56 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a57 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a58 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a59 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a60 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a61 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a62 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a63 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a64 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a65 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a66 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a67 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a68 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a69 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a70 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a71 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a72 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a73 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a74 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a75 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a76 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a77 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a78 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a79 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a80 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a81 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a82 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a83 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a84 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a85 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a86 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p3_a87 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a88 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a89 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a90 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a91 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a92 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a93 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a94 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a95 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a96 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a97 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a98 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a99 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a100 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a101 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a102 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a103 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a104 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a105 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a106 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a107 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a108 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a109 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a110 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a111 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a112 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a113 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a114 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a115 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a116 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a117 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a118 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a119 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a120 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a121 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a122 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a123 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a124 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a125 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a126 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a127 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a128 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a129 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a130 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a131 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a132 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a133 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a134 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a135 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a136 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a137 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a138 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a139 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a140 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a141 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a142 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a143 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a144 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a145 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a146 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a147 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a148 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a149 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a150 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a151 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a152 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a153 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a154 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a155 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a156 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a157 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a158 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a159 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a160 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a161 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a162 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a163 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a164 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a165 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a166 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a167 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a168 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a169 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a170 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a171 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a172 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a173 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a174 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a175 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a176 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a177 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a178 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a179 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a180 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a181 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a182 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a183 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a184 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a185 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a186 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a187 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a188 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a189 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a190 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a191 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a192 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a193 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a194 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a195 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a196 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a197 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a198 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a199 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a200 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a201 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a202 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a203 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a204 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a205 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p3_a206 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a207 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a208 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a209 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a210 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a211 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a212 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a213 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a214 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a215 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a216 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a217 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a218 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a219 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a220 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a221 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a222 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a223 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a224 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a225 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a226 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a227 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a228 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a229 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a230 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a231 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a232 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p3_a233 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a234 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a235 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a236 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a237 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a238 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a239 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a240 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a241 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p3_a242 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a243 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a244 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a245 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a246 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a247 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a248 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a249 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a250 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a251 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a252 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a253 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a254 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a255 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a256 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a257 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a258 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a259 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p3_a260 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a261 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p3_a262 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p3_a263 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a264 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a265 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a266 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a267 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a268 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a269 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a270 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a271 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a272 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a273 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a274 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a275 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a276 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a277 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a278 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a279 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a280 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
  );
  procedure set_header_cache(p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  DATE := fnd_api.g_miss_date
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  NUMBER := 0-1962.0724
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  NUMBER := 0-1962.0724
    , p0_a81  NUMBER := 0-1962.0724
    , p0_a82  DATE := fnd_api.g_miss_date
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  DATE := fnd_api.g_miss_date
    , p0_a88  VARCHAR2 := fnd_api.g_miss_char
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  NUMBER := 0-1962.0724
    , p0_a93  VARCHAR2 := fnd_api.g_miss_char
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  DATE := fnd_api.g_miss_date
    , p0_a99  NUMBER := 0-1962.0724
    , p0_a100  NUMBER := 0-1962.0724
    , p0_a101  DATE := fnd_api.g_miss_date
    , p0_a102  DATE := fnd_api.g_miss_date
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  VARCHAR2 := fnd_api.g_miss_char
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  VARCHAR2 := fnd_api.g_miss_char
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p0_a109  NUMBER := 0-1962.0724
    , p0_a110  NUMBER := 0-1962.0724
    , p0_a111  NUMBER := 0-1962.0724
    , p0_a112  NUMBER := 0-1962.0724
    , p0_a113  NUMBER := 0-1962.0724
    , p0_a114  NUMBER := 0-1962.0724
    , p0_a115  NUMBER := 0-1962.0724
    , p0_a116  NUMBER := 0-1962.0724
    , p0_a117  NUMBER := 0-1962.0724
    , p0_a118  NUMBER := 0-1962.0724
    , p0_a119  NUMBER := 0-1962.0724
    , p0_a120  VARCHAR2 := fnd_api.g_miss_char
    , p0_a121  VARCHAR2 := fnd_api.g_miss_char
    , p0_a122  VARCHAR2 := fnd_api.g_miss_char
    , p0_a123  VARCHAR2 := fnd_api.g_miss_char
    , p0_a124  VARCHAR2 := fnd_api.g_miss_char
    , p0_a125  NUMBER := 0-1962.0724
    , p0_a126  VARCHAR2 := fnd_api.g_miss_char
    , p0_a127  VARCHAR2 := fnd_api.g_miss_char
    , p0_a128  VARCHAR2 := fnd_api.g_miss_char
    , p0_a129  VARCHAR2 := fnd_api.g_miss_char
    , p0_a130  DATE := fnd_api.g_miss_date
    , p0_a131  VARCHAR2 := fnd_api.g_miss_char
    , p0_a132  DATE := fnd_api.g_miss_date
    , p0_a133  VARCHAR2 := fnd_api.g_miss_char
    , p0_a134  VARCHAR2 := fnd_api.g_miss_char
    , p0_a135  VARCHAR2 := fnd_api.g_miss_char
    , p0_a136  VARCHAR2 := fnd_api.g_miss_char
    , p0_a137  VARCHAR2 := fnd_api.g_miss_char
    , p0_a138  VARCHAR2 := fnd_api.g_miss_char
    , p0_a139  VARCHAR2 := fnd_api.g_miss_char
    , p0_a140  VARCHAR2 := fnd_api.g_miss_char
    , p0_a141  NUMBER := 0-1962.0724
    , p0_a142  VARCHAR2 := fnd_api.g_miss_char
    , p0_a143  NUMBER := 0-1962.0724
    , p0_a144  VARCHAR2 := fnd_api.g_miss_char
    , p0_a145  VARCHAR2 := fnd_api.g_miss_char
    , p0_a146  VARCHAR2 := fnd_api.g_miss_char
    , p0_a147  VARCHAR2 := fnd_api.g_miss_char
    , p0_a148  DATE := fnd_api.g_miss_date
    , p0_a149  VARCHAR2 := fnd_api.g_miss_char
    , p0_a150  DATE := fnd_api.g_miss_date
    , p0_a151  VARCHAR2 := fnd_api.g_miss_char
    , p0_a152  VARCHAR2 := fnd_api.g_miss_char
    , p0_a153  VARCHAR2 := fnd_api.g_miss_char
    , p0_a154  DATE := fnd_api.g_miss_date
    , p0_a155  NUMBER := 0-1962.0724
    , p0_a156  VARCHAR2 := fnd_api.g_miss_char
    , p0_a157  NUMBER := 0-1962.0724
    , p0_a158  VARCHAR2 := fnd_api.g_miss_char
    , p0_a159  VARCHAR2 := fnd_api.g_miss_char
    , p0_a160  VARCHAR2 := fnd_api.g_miss_char
    , p0_a161  VARCHAR2 := fnd_api.g_miss_char
    , p0_a162  NUMBER := 0-1962.0724
    , p0_a163  NUMBER := 0-1962.0724
    , p0_a164  NUMBER := 0-1962.0724
    , p0_a165  NUMBER := 0-1962.0724
    , p0_a166  VARCHAR2 := fnd_api.g_miss_char
    , p0_a167  NUMBER := 0-1962.0724
    , p0_a168  NUMBER := 0-1962.0724
    , p0_a169  NUMBER := 0-1962.0724
    , p0_a170  NUMBER := 0-1962.0724
    , p0_a171  NUMBER := 0-1962.0724
    , p0_a172  VARCHAR2 := fnd_api.g_miss_char
    , p0_a173  NUMBER := 0-1962.0724
    , p0_a174  VARCHAR2 := fnd_api.g_miss_char
    , p0_a175  VARCHAR2 := fnd_api.g_miss_char
    , p0_a176  VARCHAR2 := fnd_api.g_miss_char
    , p0_a177  DATE := fnd_api.g_miss_date
    , p0_a178  NUMBER := 0-1962.0724
    , p0_a179  VARCHAR2 := fnd_api.g_miss_char
    , p0_a180  VARCHAR2 := fnd_api.g_miss_char
    , p0_a181  VARCHAR2 := fnd_api.g_miss_char
    , p0_a182  VARCHAR2 := fnd_api.g_miss_char
    , p0_a183  NUMBER := 0-1962.0724
    , p0_a184  NUMBER := 0-1962.0724
    , p0_a185  NUMBER := 0-1962.0724
    , p0_a186  VARCHAR2 := fnd_api.g_miss_char
    , p0_a187  VARCHAR2 := fnd_api.g_miss_char
    , p0_a188  VARCHAR2 := fnd_api.g_miss_char
    , p0_a189  NUMBER := 0-1962.0724
    , p0_a190  NUMBER := 0-1962.0724
    , p0_a191  NUMBER := 0-1962.0724
    , p0_a192  VARCHAR2 := fnd_api.g_miss_char
    , p0_a193  DATE := fnd_api.g_miss_date
    , p0_a194  VARCHAR2 := fnd_api.g_miss_char
    , p0_a195  DATE := fnd_api.g_miss_date
    , p0_a196  NUMBER := 0-1962.0724
    , p0_a197  NUMBER := 0-1962.0724
    , p0_a198  NUMBER := 0-1962.0724
    , p0_a199  NUMBER := 0-1962.0724
    , p0_a200  NUMBER := 0-1962.0724
    , p0_a201  NUMBER := 0-1962.0724
    , p0_a202  NUMBER := 0-1962.0724
    , p0_a203  NUMBER := 0-1962.0724
    , p0_a204  NUMBER := 0-1962.0724
    , p0_a205  NUMBER := 0-1962.0724
    , p0_a206  NUMBER := 0-1962.0724
    , p0_a207  NUMBER := 0-1962.0724
    , p0_a208  NUMBER := 0-1962.0724
    , p0_a209  NUMBER := 0-1962.0724
    , p0_a210  NUMBER := 0-1962.0724
    , p0_a211  NUMBER := 0-1962.0724
    , p0_a212  NUMBER := 0-1962.0724
    , p0_a213  NUMBER := 0-1962.0724
    , p0_a214  VARCHAR2 := fnd_api.g_miss_char
    , p0_a215  NUMBER := 0-1962.0724
  );
  procedure get_header(p_header_id  NUMBER
    , p1_a0 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a1 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a2 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a3 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a4 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a5 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a6 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a7 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a8 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a9 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a10 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a11 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a12 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a13 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a14 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a15 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a16 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a17 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a18 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a19 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a20 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a21 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a22 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a23 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a24 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a25 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a26 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a27 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a29 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a30 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a31 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a32 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a33 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a35 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a36 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a37 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a38 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a39 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a40 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a41 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a42 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a43 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a44 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a45 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a46 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a47 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a48 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a49 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a50 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a51 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a52 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a53 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a54 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a55 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a56 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a57 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a58 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a59 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a60 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a61 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a62 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a63 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a64 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a65 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a66 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a67 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a68 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a69 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a70 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a71 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a72 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a73 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a74 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a75 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a76 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a77 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a78 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a79 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a80 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a81 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a82 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a83 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a84 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a85 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a87 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a88 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a89 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a90 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a91 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a92 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a93 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a94 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a95 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a96 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a97 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a98 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a99 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a100 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a101 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a102 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a103 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a105 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a106 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a107 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a109 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a110 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a111 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a112 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a113 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a114 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a115 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a116 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a117 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a118 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a119 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a120 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a122 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a123 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a124 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a125 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a126 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a127 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a128 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a129 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a130 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a131 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a132 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a133 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a135 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a136 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a138 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a141 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a142 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a143 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a144 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a145 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a146 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a147 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a148 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a149 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a150 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a151 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a152 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a153 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a154 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a155 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a156 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a157 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a158 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a159 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a160 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a161 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a162 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a163 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a164 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a165 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a166 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a167 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a168 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a169 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a170 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a171 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a172 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a173 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a174 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a175 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a176 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a177 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a178 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a179 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a180 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a181 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a182 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a183 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a184 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a185 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a186 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a187 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a188 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a189 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a190 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a191 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a192 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a193 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a194 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a195 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a196 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a197 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a198 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a199 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a200 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a201 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a202 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a203 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a204 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a205 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a206 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a207 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a208 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a209 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a210 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a211 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a212 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a213 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a214 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a215 out NOCOPY /* file.sql.39 change */  NUMBER
  );
  procedure get_line(p_line_id  NUMBER
    , p1_a0 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a1 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a2 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a3 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a4 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a5 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a6 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a7 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a8 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a9 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a10 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a11 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a12 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a13 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a14 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a15 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a16 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a17 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a18 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a19 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a20 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a21 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a22 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a23 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a24 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a25 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a26 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a27 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a29 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a30 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a31 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a32 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a33 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a35 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a36 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a37 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a38 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a39 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a40 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a41 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a42 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a43 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a44 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a45 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a46 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a47 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a48 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a49 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a50 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a51 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a52 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a53 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a54 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a55 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a56 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a57 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a58 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a59 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a60 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a61 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a62 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a63 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a64 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a65 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a66 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a67 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a68 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a69 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a70 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a71 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a72 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a73 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a74 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a75 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a76 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a77 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a78 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a79 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a80 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a81 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a82 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a83 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a84 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a85 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a87 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a88 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a89 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a90 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a91 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a92 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a93 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a94 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a95 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a96 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a97 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a98 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a99 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a100 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a101 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a102 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a103 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a105 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a106 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a107 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a109 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a110 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a111 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a112 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a113 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a114 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a115 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a116 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a117 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a118 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a119 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a120 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a122 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a123 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a124 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a125 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a126 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a127 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a128 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a129 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a130 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a131 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a132 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a133 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a135 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a136 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a138 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a141 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a142 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a143 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a144 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a145 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a146 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a147 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a148 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a149 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a150 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a151 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a152 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a153 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a154 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a155 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a156 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a157 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a158 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a159 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a160 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a161 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a162 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a163 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a164 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a165 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a166 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a167 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a168 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a169 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a170 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a171 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a172 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a173 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a174 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a175 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a176 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a177 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a178 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a179 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a180 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a181 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a182 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a183 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a184 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a185 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a186 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a187 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a188 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a189 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a190 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a191 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a192 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a193 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a194 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a195 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a196 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a197 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a198 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a199 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a200 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a201 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a202 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a203 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a204 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a205 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a206 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a207 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a208 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a209 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a210 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a211 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a212 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a213 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a214 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a215 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a216 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a217 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a218 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a219 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a220 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a221 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a222 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a223 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a224 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a225 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a226 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a227 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a228 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a229 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a230 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a231 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a232 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a233 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a234 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a235 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a236 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a237 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a238 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a239 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a240 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a241 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a242 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a243 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a244 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a245 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a246 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a247 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a248 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a249 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a250 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a251 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a252 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a253 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a254 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a255 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a256 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a257 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a258 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a259 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a260 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a261 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a262 out NOCOPY /* file.sql.39 change */  DATE
    , p1_a263 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a264 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a265 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a266 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a267 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a268 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a269 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a270 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a271 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a272 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a273 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a274 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a275 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a276 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a277 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a278 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a279 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a280 out NOCOPY /* file.sql.39 change */  NUMBER
  );
end oe_portal_util_w;

 

/
