--------------------------------------------------------
--  DDL for Package Body OE_PORTAL_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PORTAL_UTIL_W" as
  /* $Header: OERUPORB.pls 120.0 2005/06/01 01:17:44 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

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
  )

  as
    ddp_header_rec oe_order_pub.header_rec_type;
    ddp_old_header_rec oe_order_pub.header_rec_type;
    ddx_header_val_rec_type oe_order_pub.header_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_header_rec.agreement_id := rosetta_g_miss_num_map(p0_a1);
    ddp_header_rec.attribute1 := p0_a2;
    ddp_header_rec.attribute10 := p0_a3;
    ddp_header_rec.attribute11 := p0_a4;
    ddp_header_rec.attribute12 := p0_a5;
    ddp_header_rec.attribute13 := p0_a6;
    ddp_header_rec.attribute14 := p0_a7;
    ddp_header_rec.attribute15 := p0_a8;
    ddp_header_rec.attribute16 := p0_a9;
    ddp_header_rec.attribute17 := p0_a10;
    ddp_header_rec.attribute18 := p0_a11;
    ddp_header_rec.attribute19 := p0_a12;
    ddp_header_rec.attribute2 := p0_a13;
    ddp_header_rec.attribute20 := p0_a14;
    ddp_header_rec.attribute3 := p0_a15;
    ddp_header_rec.attribute4 := p0_a16;
    ddp_header_rec.attribute5 := p0_a17;
    ddp_header_rec.attribute6 := p0_a18;
    ddp_header_rec.attribute7 := p0_a19;
    ddp_header_rec.attribute8 := p0_a20;
    ddp_header_rec.attribute9 := p0_a21;
    ddp_header_rec.booked_flag := p0_a22;
    ddp_header_rec.cancelled_flag := p0_a23;
    ddp_header_rec.context := p0_a24;
    ddp_header_rec.conversion_rate := rosetta_g_miss_num_map(p0_a25);
    ddp_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_header_rec.conversion_type_code := p0_a27;
    ddp_header_rec.customer_preference_set_code := p0_a28;
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p0_a29);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_header_rec.cust_po_number := p0_a31;
    ddp_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p0_a32);
    ddp_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p0_a33);
    ddp_header_rec.demand_class_code := p0_a34;
    ddp_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p0_a35);
    ddp_header_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a36);
    ddp_header_rec.fob_point_code := p0_a37;
    ddp_header_rec.freight_carrier_code := p0_a38;
    ddp_header_rec.freight_terms_code := p0_a39;
    ddp_header_rec.global_attribute1 := p0_a40;
    ddp_header_rec.global_attribute10 := p0_a41;
    ddp_header_rec.global_attribute11 := p0_a42;
    ddp_header_rec.global_attribute12 := p0_a43;
    ddp_header_rec.global_attribute13 := p0_a44;
    ddp_header_rec.global_attribute14 := p0_a45;
    ddp_header_rec.global_attribute15 := p0_a46;
    ddp_header_rec.global_attribute16 := p0_a47;
    ddp_header_rec.global_attribute17 := p0_a48;
    ddp_header_rec.global_attribute18 := p0_a49;
    ddp_header_rec.global_attribute19 := p0_a50;
    ddp_header_rec.global_attribute2 := p0_a51;
    ddp_header_rec.global_attribute20 := p0_a52;
    ddp_header_rec.global_attribute3 := p0_a53;
    ddp_header_rec.global_attribute4 := p0_a54;
    ddp_header_rec.global_attribute5 := p0_a55;
    ddp_header_rec.global_attribute6 := p0_a56;
    ddp_header_rec.global_attribute7 := p0_a57;
    ddp_header_rec.global_attribute8 := p0_a58;
    ddp_header_rec.global_attribute9 := p0_a59;
    ddp_header_rec.global_attribute_category := p0_a60;
    ddp_header_rec.tp_context := p0_a61;
    ddp_header_rec.tp_attribute1 := p0_a62;
    ddp_header_rec.tp_attribute2 := p0_a63;
    ddp_header_rec.tp_attribute3 := p0_a64;
    ddp_header_rec.tp_attribute4 := p0_a65;
    ddp_header_rec.tp_attribute5 := p0_a66;
    ddp_header_rec.tp_attribute6 := p0_a67;
    ddp_header_rec.tp_attribute7 := p0_a68;
    ddp_header_rec.tp_attribute8 := p0_a69;
    ddp_header_rec.tp_attribute9 := p0_a70;
    ddp_header_rec.tp_attribute10 := p0_a71;
    ddp_header_rec.tp_attribute11 := p0_a72;
    ddp_header_rec.tp_attribute12 := p0_a73;
    ddp_header_rec.tp_attribute13 := p0_a74;
    ddp_header_rec.tp_attribute14 := p0_a75;
    ddp_header_rec.tp_attribute15 := p0_a76;
    ddp_header_rec.header_id := rosetta_g_miss_num_map(p0_a77);
    ddp_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p0_a78);
    ddp_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p0_a79);
    ddp_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p0_a80);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p0_a81);
    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p0_a83);
    ddp_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p0_a84);
    ddp_header_rec.open_flag := p0_a85;
    ddp_header_rec.order_category_code := p0_a86;
    ddp_header_rec.ordered_date := rosetta_g_miss_date_in_map(p0_a87);
    ddp_header_rec.order_date_type_code := p0_a88;
    ddp_header_rec.order_number := rosetta_g_miss_num_map(p0_a89);
    ddp_header_rec.order_source_id := rosetta_g_miss_num_map(p0_a90);
    ddp_header_rec.order_type_id := rosetta_g_miss_num_map(p0_a91);
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p0_a92);
    ddp_header_rec.orig_sys_document_ref := p0_a93;
    ddp_header_rec.partial_shipments_allowed := p0_a94;
    ddp_header_rec.payment_term_id := rosetta_g_miss_num_map(p0_a95);
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p0_a96);
    ddp_header_rec.price_request_code := p0_a97;
    ddp_header_rec.pricing_date := rosetta_g_miss_date_in_map(p0_a98);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p0_a99);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p0_a100);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a101);
    ddp_header_rec.request_date := rosetta_g_miss_date_in_map(p0_a102);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p0_a103);
    ddp_header_rec.return_reason_code := p0_a104;
    ddp_header_rec.salesrep_id := rosetta_g_miss_num_map(p0_a105);
    ddp_header_rec.sales_channel_code := p0_a106;
    ddp_header_rec.shipment_priority_code := p0_a107;
    ddp_header_rec.shipping_method_code := p0_a108;
    ddp_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p0_a109);
    ddp_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p0_a110);
    ddp_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p0_a111);
    ddp_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p0_a112);
    ddp_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p0_a113);
    ddp_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p0_a114);
    ddp_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p0_a115);
    ddp_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p0_a116);
    ddp_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p0_a117);
    ddp_header_rec.source_document_id := rosetta_g_miss_num_map(p0_a118);
    ddp_header_rec.source_document_type_id := rosetta_g_miss_num_map(p0_a119);
    ddp_header_rec.tax_exempt_flag := p0_a120;
    ddp_header_rec.tax_exempt_number := p0_a121;
    ddp_header_rec.tax_exempt_reason_code := p0_a122;
    ddp_header_rec.tax_point_code := p0_a123;
    ddp_header_rec.transactional_curr_code := p0_a124;
    ddp_header_rec.version_number := rosetta_g_miss_num_map(p0_a125);
    ddp_header_rec.return_status := p0_a126;
    ddp_header_rec.db_flag := p0_a127;
    ddp_header_rec.operation := p0_a128;
    ddp_header_rec.first_ack_code := p0_a129;
    ddp_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p0_a130);
    ddp_header_rec.last_ack_code := p0_a131;
    ddp_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p0_a132);
    ddp_header_rec.change_reason := p0_a133;
    ddp_header_rec.change_comments := p0_a134;
    ddp_header_rec.change_sequence := p0_a135;
    ddp_header_rec.change_request_code := p0_a136;
    ddp_header_rec.ready_flag := p0_a137;
    ddp_header_rec.status_flag := p0_a138;
    ddp_header_rec.force_apply_flag := p0_a139;
    ddp_header_rec.drop_ship_flag := p0_a140;
    ddp_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p0_a141);
    ddp_header_rec.payment_type_code := p0_a142;
    ddp_header_rec.payment_amount := rosetta_g_miss_num_map(p0_a143);
    ddp_header_rec.check_number := p0_a144;
    ddp_header_rec.credit_card_code := p0_a145;
    ddp_header_rec.credit_card_holder_name := p0_a146;
    ddp_header_rec.credit_card_number := p0_a147;
    ddp_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p0_a148);
    ddp_header_rec.credit_card_approval_code := p0_a149;
    ddp_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p0_a150);
    ddp_header_rec.shipping_instructions := p0_a151;
    ddp_header_rec.packing_instructions := p0_a152;
    ddp_header_rec.flow_status_code := p0_a153;
    ddp_header_rec.booked_date := rosetta_g_miss_date_in_map(p0_a154);
    ddp_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p0_a155);
    ddp_header_rec.upgraded_flag := p0_a156;
    ddp_header_rec.lock_control := rosetta_g_miss_num_map(p0_a157);
    ddp_header_rec.ship_to_edi_location_code := p0_a158;
    ddp_header_rec.sold_to_edi_location_code := p0_a159;
    ddp_header_rec.bill_to_edi_location_code := p0_a160;
    ddp_header_rec.ship_from_edi_location_code := p0_a161;
    ddp_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p0_a162);
    ddp_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p0_a163);
    ddp_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p0_a164);
    ddp_header_rec.invoice_address_id := rosetta_g_miss_num_map(p0_a165);
    ddp_header_rec.ship_to_address_code := p0_a166;
    ddp_header_rec.xml_message_id := rosetta_g_miss_num_map(p0_a167);
    ddp_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p0_a168);
    ddp_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p0_a169);
    ddp_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p0_a170);
    ddp_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p0_a171);
    ddp_header_rec.xml_transaction_type_code := p0_a172;
    ddp_header_rec.blanket_number := rosetta_g_miss_num_map(p0_a173);
    ddp_header_rec.line_set_name := p0_a174;
    ddp_header_rec.fulfillment_set_name := p0_a175;
    ddp_header_rec.default_fulfillment_set := p0_a176;
    ddp_header_rec.quote_date := rosetta_g_miss_date_in_map(p0_a177);
    ddp_header_rec.quote_number := rosetta_g_miss_num_map(p0_a178);
    ddp_header_rec.sales_document_name := p0_a179;
    ddp_header_rec.transaction_phase_code := p0_a180;
    ddp_header_rec.user_status_code := p0_a181;
    ddp_header_rec.draft_submitted_flag := p0_a182;
    ddp_header_rec.source_document_version_number := rosetta_g_miss_num_map(p0_a183);
    ddp_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p0_a184);
    ddp_header_rec.minisite_id := rosetta_g_miss_num_map(p0_a185);
    ddp_header_rec.ib_owner := p0_a186;
    ddp_header_rec.ib_installed_at_location := p0_a187;
    ddp_header_rec.ib_current_location := p0_a188;
    ddp_header_rec.end_customer_id := rosetta_g_miss_num_map(p0_a189);
    ddp_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p0_a190);
    ddp_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p0_a191);
    ddp_header_rec.supplier_signature := p0_a192;
    ddp_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p0_a193);
    ddp_header_rec.customer_signature := p0_a194;
    ddp_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p0_a195);
    ddp_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p0_a196);
    ddp_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p0_a197);
    ddp_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p0_a198);
    ddp_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p0_a199);
    ddp_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p0_a200);
    ddp_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p0_a201);
    ddp_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p0_a202);
    ddp_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p0_a203);
    ddp_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p0_a204);
    ddp_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p0_a205);
    ddp_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p0_a206);
    ddp_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p0_a207);
    ddp_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p0_a208);
    ddp_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p0_a209);
    ddp_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p0_a210);
    ddp_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p0_a211);
    ddp_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p0_a212);
    ddp_header_rec.contract_template_id := rosetta_g_miss_num_map(p0_a213);
    ddp_header_rec.contract_source_doc_type_code := p0_a214;
    ddp_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p0_a215);

    ddp_old_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p1_a0);
    ddp_old_header_rec.agreement_id := rosetta_g_miss_num_map(p1_a1);
    ddp_old_header_rec.attribute1 := p1_a2;
    ddp_old_header_rec.attribute10 := p1_a3;
    ddp_old_header_rec.attribute11 := p1_a4;
    ddp_old_header_rec.attribute12 := p1_a5;
    ddp_old_header_rec.attribute13 := p1_a6;
    ddp_old_header_rec.attribute14 := p1_a7;
    ddp_old_header_rec.attribute15 := p1_a8;
    ddp_old_header_rec.attribute16 := p1_a9;
    ddp_old_header_rec.attribute17 := p1_a10;
    ddp_old_header_rec.attribute18 := p1_a11;
    ddp_old_header_rec.attribute19 := p1_a12;
    ddp_old_header_rec.attribute2 := p1_a13;
    ddp_old_header_rec.attribute20 := p1_a14;
    ddp_old_header_rec.attribute3 := p1_a15;
    ddp_old_header_rec.attribute4 := p1_a16;
    ddp_old_header_rec.attribute5 := p1_a17;
    ddp_old_header_rec.attribute6 := p1_a18;
    ddp_old_header_rec.attribute7 := p1_a19;
    ddp_old_header_rec.attribute8 := p1_a20;
    ddp_old_header_rec.attribute9 := p1_a21;
    ddp_old_header_rec.booked_flag := p1_a22;
    ddp_old_header_rec.cancelled_flag := p1_a23;
    ddp_old_header_rec.context := p1_a24;
    ddp_old_header_rec.conversion_rate := rosetta_g_miss_num_map(p1_a25);
    ddp_old_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p1_a26);
    ddp_old_header_rec.conversion_type_code := p1_a27;
    ddp_old_header_rec.customer_preference_set_code := p1_a28;
    ddp_old_header_rec.created_by := rosetta_g_miss_num_map(p1_a29);
    ddp_old_header_rec.creation_date := rosetta_g_miss_date_in_map(p1_a30);
    ddp_old_header_rec.cust_po_number := p1_a31;
    ddp_old_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p1_a32);
    ddp_old_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p1_a33);
    ddp_old_header_rec.demand_class_code := p1_a34;
    ddp_old_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p1_a35);
    ddp_old_header_rec.expiration_date := rosetta_g_miss_date_in_map(p1_a36);
    ddp_old_header_rec.fob_point_code := p1_a37;
    ddp_old_header_rec.freight_carrier_code := p1_a38;
    ddp_old_header_rec.freight_terms_code := p1_a39;
    ddp_old_header_rec.global_attribute1 := p1_a40;
    ddp_old_header_rec.global_attribute10 := p1_a41;
    ddp_old_header_rec.global_attribute11 := p1_a42;
    ddp_old_header_rec.global_attribute12 := p1_a43;
    ddp_old_header_rec.global_attribute13 := p1_a44;
    ddp_old_header_rec.global_attribute14 := p1_a45;
    ddp_old_header_rec.global_attribute15 := p1_a46;
    ddp_old_header_rec.global_attribute16 := p1_a47;
    ddp_old_header_rec.global_attribute17 := p1_a48;
    ddp_old_header_rec.global_attribute18 := p1_a49;
    ddp_old_header_rec.global_attribute19 := p1_a50;
    ddp_old_header_rec.global_attribute2 := p1_a51;
    ddp_old_header_rec.global_attribute20 := p1_a52;
    ddp_old_header_rec.global_attribute3 := p1_a53;
    ddp_old_header_rec.global_attribute4 := p1_a54;
    ddp_old_header_rec.global_attribute5 := p1_a55;
    ddp_old_header_rec.global_attribute6 := p1_a56;
    ddp_old_header_rec.global_attribute7 := p1_a57;
    ddp_old_header_rec.global_attribute8 := p1_a58;
    ddp_old_header_rec.global_attribute9 := p1_a59;
    ddp_old_header_rec.global_attribute_category := p1_a60;
    ddp_old_header_rec.tp_context := p1_a61;
    ddp_old_header_rec.tp_attribute1 := p1_a62;
    ddp_old_header_rec.tp_attribute2 := p1_a63;
    ddp_old_header_rec.tp_attribute3 := p1_a64;
    ddp_old_header_rec.tp_attribute4 := p1_a65;
    ddp_old_header_rec.tp_attribute5 := p1_a66;
    ddp_old_header_rec.tp_attribute6 := p1_a67;
    ddp_old_header_rec.tp_attribute7 := p1_a68;
    ddp_old_header_rec.tp_attribute8 := p1_a69;
    ddp_old_header_rec.tp_attribute9 := p1_a70;
    ddp_old_header_rec.tp_attribute10 := p1_a71;
    ddp_old_header_rec.tp_attribute11 := p1_a72;
    ddp_old_header_rec.tp_attribute12 := p1_a73;
    ddp_old_header_rec.tp_attribute13 := p1_a74;
    ddp_old_header_rec.tp_attribute14 := p1_a75;
    ddp_old_header_rec.tp_attribute15 := p1_a76;
    ddp_old_header_rec.header_id := rosetta_g_miss_num_map(p1_a77);
    ddp_old_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p1_a78);
    ddp_old_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p1_a79);
    ddp_old_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p1_a80);
    ddp_old_header_rec.last_updated_by := rosetta_g_miss_num_map(p1_a81);
    ddp_old_header_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a82);
    ddp_old_header_rec.last_update_login := rosetta_g_miss_num_map(p1_a83);
    ddp_old_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p1_a84);
    ddp_old_header_rec.open_flag := p1_a85;
    ddp_old_header_rec.order_category_code := p1_a86;
    ddp_old_header_rec.ordered_date := rosetta_g_miss_date_in_map(p1_a87);
    ddp_old_header_rec.order_date_type_code := p1_a88;
    ddp_old_header_rec.order_number := rosetta_g_miss_num_map(p1_a89);
    ddp_old_header_rec.order_source_id := rosetta_g_miss_num_map(p1_a90);
    ddp_old_header_rec.order_type_id := rosetta_g_miss_num_map(p1_a91);
    ddp_old_header_rec.org_id := rosetta_g_miss_num_map(p1_a92);
    ddp_old_header_rec.orig_sys_document_ref := p1_a93;
    ddp_old_header_rec.partial_shipments_allowed := p1_a94;
    ddp_old_header_rec.payment_term_id := rosetta_g_miss_num_map(p1_a95);
    ddp_old_header_rec.price_list_id := rosetta_g_miss_num_map(p1_a96);
    ddp_old_header_rec.price_request_code := p1_a97;
    ddp_old_header_rec.pricing_date := rosetta_g_miss_date_in_map(p1_a98);
    ddp_old_header_rec.program_application_id := rosetta_g_miss_num_map(p1_a99);
    ddp_old_header_rec.program_id := rosetta_g_miss_num_map(p1_a100);
    ddp_old_header_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a101);
    ddp_old_header_rec.request_date := rosetta_g_miss_date_in_map(p1_a102);
    ddp_old_header_rec.request_id := rosetta_g_miss_num_map(p1_a103);
    ddp_old_header_rec.return_reason_code := p1_a104;
    ddp_old_header_rec.salesrep_id := rosetta_g_miss_num_map(p1_a105);
    ddp_old_header_rec.sales_channel_code := p1_a106;
    ddp_old_header_rec.shipment_priority_code := p1_a107;
    ddp_old_header_rec.shipping_method_code := p1_a108;
    ddp_old_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p1_a109);
    ddp_old_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p1_a110);
    ddp_old_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p1_a111);
    ddp_old_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p1_a112);
    ddp_old_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p1_a113);
    ddp_old_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p1_a114);
    ddp_old_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p1_a115);
    ddp_old_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p1_a116);
    ddp_old_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p1_a117);
    ddp_old_header_rec.source_document_id := rosetta_g_miss_num_map(p1_a118);
    ddp_old_header_rec.source_document_type_id := rosetta_g_miss_num_map(p1_a119);
    ddp_old_header_rec.tax_exempt_flag := p1_a120;
    ddp_old_header_rec.tax_exempt_number := p1_a121;
    ddp_old_header_rec.tax_exempt_reason_code := p1_a122;
    ddp_old_header_rec.tax_point_code := p1_a123;
    ddp_old_header_rec.transactional_curr_code := p1_a124;
    ddp_old_header_rec.version_number := rosetta_g_miss_num_map(p1_a125);
    ddp_old_header_rec.return_status := p1_a126;
    ddp_old_header_rec.db_flag := p1_a127;
    ddp_old_header_rec.operation := p1_a128;
    ddp_old_header_rec.first_ack_code := p1_a129;
    ddp_old_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p1_a130);
    ddp_old_header_rec.last_ack_code := p1_a131;
    ddp_old_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p1_a132);
    ddp_old_header_rec.change_reason := p1_a133;
    ddp_old_header_rec.change_comments := p1_a134;
    ddp_old_header_rec.change_sequence := p1_a135;
    ddp_old_header_rec.change_request_code := p1_a136;
    ddp_old_header_rec.ready_flag := p1_a137;
    ddp_old_header_rec.status_flag := p1_a138;
    ddp_old_header_rec.force_apply_flag := p1_a139;
    ddp_old_header_rec.drop_ship_flag := p1_a140;
    ddp_old_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p1_a141);
    ddp_old_header_rec.payment_type_code := p1_a142;
    ddp_old_header_rec.payment_amount := rosetta_g_miss_num_map(p1_a143);
    ddp_old_header_rec.check_number := p1_a144;
    ddp_old_header_rec.credit_card_code := p1_a145;
    ddp_old_header_rec.credit_card_holder_name := p1_a146;
    ddp_old_header_rec.credit_card_number := p1_a147;
    ddp_old_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p1_a148);
    ddp_old_header_rec.credit_card_approval_code := p1_a149;
    ddp_old_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p1_a150);
    ddp_old_header_rec.shipping_instructions := p1_a151;
    ddp_old_header_rec.packing_instructions := p1_a152;
    ddp_old_header_rec.flow_status_code := p1_a153;
    ddp_old_header_rec.booked_date := rosetta_g_miss_date_in_map(p1_a154);
    ddp_old_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p1_a155);
    ddp_old_header_rec.upgraded_flag := p1_a156;
    ddp_old_header_rec.lock_control := rosetta_g_miss_num_map(p1_a157);
    ddp_old_header_rec.ship_to_edi_location_code := p1_a158;
    ddp_old_header_rec.sold_to_edi_location_code := p1_a159;
    ddp_old_header_rec.bill_to_edi_location_code := p1_a160;
    ddp_old_header_rec.ship_from_edi_location_code := p1_a161;
    ddp_old_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p1_a162);
    ddp_old_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p1_a163);
    ddp_old_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p1_a164);
    ddp_old_header_rec.invoice_address_id := rosetta_g_miss_num_map(p1_a165);
    ddp_old_header_rec.ship_to_address_code := p1_a166;
    ddp_old_header_rec.xml_message_id := rosetta_g_miss_num_map(p1_a167);
    ddp_old_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p1_a168);
    ddp_old_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p1_a169);
    ddp_old_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p1_a170);
    ddp_old_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p1_a171);
    ddp_old_header_rec.xml_transaction_type_code := p1_a172;
    ddp_old_header_rec.blanket_number := rosetta_g_miss_num_map(p1_a173);
    ddp_old_header_rec.line_set_name := p1_a174;
    ddp_old_header_rec.fulfillment_set_name := p1_a175;
    ddp_old_header_rec.default_fulfillment_set := p1_a176;
    ddp_old_header_rec.quote_date := rosetta_g_miss_date_in_map(p1_a177);
    ddp_old_header_rec.quote_number := rosetta_g_miss_num_map(p1_a178);
    ddp_old_header_rec.sales_document_name := p1_a179;
    ddp_old_header_rec.transaction_phase_code := p1_a180;
    ddp_old_header_rec.user_status_code := p1_a181;
    ddp_old_header_rec.draft_submitted_flag := p1_a182;
    ddp_old_header_rec.source_document_version_number := rosetta_g_miss_num_map(p1_a183);
    ddp_old_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p1_a184);
    ddp_old_header_rec.minisite_id := rosetta_g_miss_num_map(p1_a185);
    ddp_old_header_rec.ib_owner := p1_a186;
    ddp_old_header_rec.ib_installed_at_location := p1_a187;
    ddp_old_header_rec.ib_current_location := p1_a188;
    ddp_old_header_rec.end_customer_id := rosetta_g_miss_num_map(p1_a189);
    ddp_old_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p1_a190);
    ddp_old_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p1_a191);
    ddp_old_header_rec.supplier_signature := p1_a192;
    ddp_old_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p1_a193);
    ddp_old_header_rec.customer_signature := p1_a194;
    ddp_old_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p1_a195);
    ddp_old_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p1_a196);
    ddp_old_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p1_a197);
    ddp_old_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p1_a198);
    ddp_old_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p1_a199);
    ddp_old_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p1_a200);
    ddp_old_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p1_a201);
    ddp_old_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p1_a202);
    ddp_old_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p1_a203);
    ddp_old_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p1_a204);
    ddp_old_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p1_a205);
    ddp_old_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p1_a206);
    ddp_old_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p1_a207);
    ddp_old_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p1_a208);
    ddp_old_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p1_a209);
    ddp_old_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p1_a210);
    ddp_old_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p1_a211);
    ddp_old_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p1_a212);
    ddp_old_header_rec.contract_template_id := rosetta_g_miss_num_map(p1_a213);
    ddp_old_header_rec.contract_source_doc_type_code := p1_a214;
    ddp_old_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p1_a215);


    -- here's the delegated call to the old PL/SQL routine
    oe_portal_util.get_values(ddp_header_rec,
      ddp_old_header_rec,
      ddx_header_val_rec_type);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any


    p2_a0 := ddx_header_val_rec_type.accounting_rule;
    p2_a1 := ddx_header_val_rec_type.agreement;
    p2_a2 := ddx_header_val_rec_type.conversion_type;
    p2_a3 := ddx_header_val_rec_type.deliver_to_address1;
    p2_a4 := ddx_header_val_rec_type.deliver_to_address2;
    p2_a5 := ddx_header_val_rec_type.deliver_to_address3;
    p2_a6 := ddx_header_val_rec_type.deliver_to_address4;
    p2_a7 := ddx_header_val_rec_type.deliver_to_contact;
    p2_a8 := ddx_header_val_rec_type.deliver_to_location;
    p2_a9 := ddx_header_val_rec_type.deliver_to_org;
    p2_a10 := ddx_header_val_rec_type.deliver_to_state;
    p2_a11 := ddx_header_val_rec_type.deliver_to_city;
    p2_a12 := ddx_header_val_rec_type.deliver_to_zip;
    p2_a13 := ddx_header_val_rec_type.deliver_to_country;
    p2_a14 := ddx_header_val_rec_type.deliver_to_county;
    p2_a15 := ddx_header_val_rec_type.deliver_to_province;
    p2_a16 := ddx_header_val_rec_type.demand_class;
    p2_a17 := ddx_header_val_rec_type.fob_point;
    p2_a18 := ddx_header_val_rec_type.freight_terms;
    p2_a19 := ddx_header_val_rec_type.invoice_to_address1;
    p2_a20 := ddx_header_val_rec_type.invoice_to_address2;
    p2_a21 := ddx_header_val_rec_type.invoice_to_address3;
    p2_a22 := ddx_header_val_rec_type.invoice_to_address4;
    p2_a23 := ddx_header_val_rec_type.invoice_to_state;
    p2_a24 := ddx_header_val_rec_type.invoice_to_city;
    p2_a25 := ddx_header_val_rec_type.invoice_to_zip;
    p2_a26 := ddx_header_val_rec_type.invoice_to_country;
    p2_a27 := ddx_header_val_rec_type.invoice_to_county;
    p2_a28 := ddx_header_val_rec_type.invoice_to_province;
    p2_a29 := ddx_header_val_rec_type.invoice_to_contact;
    p2_a30 := ddx_header_val_rec_type.invoice_to_contact_first_name;
    p2_a31 := ddx_header_val_rec_type.invoice_to_contact_last_name;
    p2_a32 := ddx_header_val_rec_type.invoice_to_location;
    p2_a33 := ddx_header_val_rec_type.invoice_to_org;
    p2_a34 := ddx_header_val_rec_type.invoicing_rule;
    p2_a35 := ddx_header_val_rec_type.order_source;
    p2_a36 := ddx_header_val_rec_type.order_type;
    p2_a37 := ddx_header_val_rec_type.payment_term;
    p2_a38 := ddx_header_val_rec_type.price_list;
    p2_a39 := ddx_header_val_rec_type.return_reason;
    p2_a40 := ddx_header_val_rec_type.salesrep;
    p2_a41 := ddx_header_val_rec_type.shipment_priority;
    p2_a42 := ddx_header_val_rec_type.ship_from_address1;
    p2_a43 := ddx_header_val_rec_type.ship_from_address2;
    p2_a44 := ddx_header_val_rec_type.ship_from_address3;
    p2_a45 := ddx_header_val_rec_type.ship_from_address4;
    p2_a46 := ddx_header_val_rec_type.ship_from_location;
    p2_a47 := ddx_header_val_rec_type.ship_from_city;
    p2_a48 := ddx_header_val_rec_type.ship_from_postal_code;
    p2_a49 := ddx_header_val_rec_type.ship_from_country;
    p2_a50 := ddx_header_val_rec_type.ship_from_region1;
    p2_a51 := ddx_header_val_rec_type.ship_from_region2;
    p2_a52 := ddx_header_val_rec_type.ship_from_region3;
    p2_a53 := ddx_header_val_rec_type.ship_from_org;
    p2_a54 := ddx_header_val_rec_type.sold_to_address1;
    p2_a55 := ddx_header_val_rec_type.sold_to_address2;
    p2_a56 := ddx_header_val_rec_type.sold_to_address3;
    p2_a57 := ddx_header_val_rec_type.sold_to_address4;
    p2_a58 := ddx_header_val_rec_type.sold_to_state;
    p2_a59 := ddx_header_val_rec_type.sold_to_country;
    p2_a60 := ddx_header_val_rec_type.sold_to_zip;
    p2_a61 := ddx_header_val_rec_type.sold_to_county;
    p2_a62 := ddx_header_val_rec_type.sold_to_province;
    p2_a63 := ddx_header_val_rec_type.sold_to_city;
    p2_a64 := ddx_header_val_rec_type.sold_to_contact_last_name;
    p2_a65 := ddx_header_val_rec_type.sold_to_contact_first_name;
    p2_a66 := ddx_header_val_rec_type.ship_to_address1;
    p2_a67 := ddx_header_val_rec_type.ship_to_address2;
    p2_a68 := ddx_header_val_rec_type.ship_to_address3;
    p2_a69 := ddx_header_val_rec_type.ship_to_address4;
    p2_a70 := ddx_header_val_rec_type.ship_to_state;
    p2_a71 := ddx_header_val_rec_type.ship_to_country;
    p2_a72 := ddx_header_val_rec_type.ship_to_zip;
    p2_a73 := ddx_header_val_rec_type.ship_to_county;
    p2_a74 := ddx_header_val_rec_type.ship_to_province;
    p2_a75 := ddx_header_val_rec_type.ship_to_city;
    p2_a76 := ddx_header_val_rec_type.ship_to_contact;
    p2_a77 := ddx_header_val_rec_type.ship_to_contact_last_name;
    p2_a78 := ddx_header_val_rec_type.ship_to_contact_first_name;
    p2_a79 := ddx_header_val_rec_type.ship_to_location;
    p2_a80 := ddx_header_val_rec_type.ship_to_org;
    p2_a81 := ddx_header_val_rec_type.sold_to_contact;
    p2_a82 := ddx_header_val_rec_type.sold_to_org;
    p2_a83 := ddx_header_val_rec_type.sold_from_org;
    p2_a84 := ddx_header_val_rec_type.tax_exempt;
    p2_a85 := ddx_header_val_rec_type.tax_exempt_reason;
    p2_a86 := ddx_header_val_rec_type.tax_point;
    p2_a87 := ddx_header_val_rec_type.customer_payment_term;
    p2_a88 := ddx_header_val_rec_type.payment_type;
    p2_a89 := ddx_header_val_rec_type.credit_card;
    p2_a90 := ddx_header_val_rec_type.status;
    p2_a91 := ddx_header_val_rec_type.freight_carrier;
    p2_a92 := ddx_header_val_rec_type.shipping_method;
    p2_a93 := ddx_header_val_rec_type.order_date_type;
    p2_a94 := ddx_header_val_rec_type.customer_number;
    p2_a95 := ddx_header_val_rec_type.ship_to_customer_name;
    p2_a96 := ddx_header_val_rec_type.invoice_to_customer_name;
    p2_a97 := ddx_header_val_rec_type.sales_channel;
    p2_a98 := ddx_header_val_rec_type.ship_to_customer_number;
    p2_a99 := ddx_header_val_rec_type.invoice_to_customer_number;
    p2_a100 := rosetta_g_miss_num_map(ddx_header_val_rec_type.ship_to_customer_id);
    p2_a101 := rosetta_g_miss_num_map(ddx_header_val_rec_type.invoice_to_customer_id);
    p2_a102 := rosetta_g_miss_num_map(ddx_header_val_rec_type.deliver_to_customer_id);
    p2_a103 := ddx_header_val_rec_type.deliver_to_customer_number;
    p2_a104 := ddx_header_val_rec_type.deliver_to_customer_name;
    p2_a105 := ddx_header_val_rec_type.deliver_to_customer_number_oi;
    p2_a106 := ddx_header_val_rec_type.deliver_to_customer_name_oi;
    p2_a107 := ddx_header_val_rec_type.ship_to_customer_number_oi;
    p2_a108 := ddx_header_val_rec_type.ship_to_customer_name_oi;
    p2_a109 := ddx_header_val_rec_type.invoice_to_customer_number_oi;
    p2_a110 := ddx_header_val_rec_type.invoice_to_customer_name_oi;
    p2_a111 := ddx_header_val_rec_type.user_status;
    p2_a112 := ddx_header_val_rec_type.transaction_phase;
    p2_a113 := ddx_header_val_rec_type.sold_to_location_address1;
    p2_a114 := ddx_header_val_rec_type.sold_to_location_address2;
    p2_a115 := ddx_header_val_rec_type.sold_to_location_address3;
    p2_a116 := ddx_header_val_rec_type.sold_to_location_address4;
    p2_a117 := ddx_header_val_rec_type.sold_to_location;
    p2_a118 := ddx_header_val_rec_type.sold_to_location_city;
    p2_a119 := ddx_header_val_rec_type.sold_to_location_state;
    p2_a120 := ddx_header_val_rec_type.sold_to_location_postal;
    p2_a121 := ddx_header_val_rec_type.sold_to_location_country;
    p2_a122 := ddx_header_val_rec_type.sold_to_location_county;
    p2_a123 := ddx_header_val_rec_type.sold_to_location_province;
    p2_a124 := ddx_header_val_rec_type.end_customer_name;
    p2_a125 := ddx_header_val_rec_type.end_customer_number;
    p2_a126 := ddx_header_val_rec_type.end_customer_contact;
    p2_a127 := ddx_header_val_rec_type.end_cust_contact_last_name;
    p2_a128 := ddx_header_val_rec_type.end_cust_contact_first_name;
    p2_a129 := ddx_header_val_rec_type.end_customer_site_address1;
    p2_a130 := ddx_header_val_rec_type.end_customer_site_address2;
    p2_a131 := ddx_header_val_rec_type.end_customer_site_address3;
    p2_a132 := ddx_header_val_rec_type.end_customer_site_address4;
    p2_a133 := ddx_header_val_rec_type.end_customer_site_state;
    p2_a134 := ddx_header_val_rec_type.end_customer_site_country;
    p2_a135 := ddx_header_val_rec_type.end_customer_site_location;
    p2_a136 := ddx_header_val_rec_type.end_customer_site_zip;
    p2_a137 := ddx_header_val_rec_type.end_customer_site_county;
    p2_a138 := ddx_header_val_rec_type.end_customer_site_province;
    p2_a139 := ddx_header_val_rec_type.end_customer_site_city;
    p2_a140 := ddx_header_val_rec_type.end_customer_site_postal_code;
    p2_a141 := ddx_header_val_rec_type.blanket_agreement_name;
  end;

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
  )

  as
    ddp_control_rec oe_globals.control_rec_type;
    ddp_x_line_tbl oe_order_pub.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    if p2_a0 is null
      then ddp_control_rec.controlled_operation := null;
    elsif p2_a0 = 0
      then ddp_control_rec.controlled_operation := false;
    else ddp_control_rec.controlled_operation := true;
    end if;
    if p2_a1 is null
      then ddp_control_rec.private_call := null;
    elsif p2_a1 = 0
      then ddp_control_rec.private_call := false;
    else ddp_control_rec.private_call := true;
    end if;
    if p2_a2 is null
      then ddp_control_rec.check_security := null;
    elsif p2_a2 = 0
      then ddp_control_rec.check_security := false;
    else ddp_control_rec.check_security := true;
    end if;
    if p2_a3 is null
      then ddp_control_rec.clear_dependents := null;
    elsif p2_a3 = 0
      then ddp_control_rec.clear_dependents := false;
    else ddp_control_rec.clear_dependents := true;
    end if;
    if p2_a4 is null
      then ddp_control_rec.default_attributes := null;
    elsif p2_a4 = 0
      then ddp_control_rec.default_attributes := false;
    else ddp_control_rec.default_attributes := true;
    end if;
    if p2_a5 is null
      then ddp_control_rec.change_attributes := null;
    elsif p2_a5 = 0
      then ddp_control_rec.change_attributes := false;
    else ddp_control_rec.change_attributes := true;
    end if;
    if p2_a6 is null
      then ddp_control_rec.validate_entity := null;
    elsif p2_a6 = 0
      then ddp_control_rec.validate_entity := false;
    else ddp_control_rec.validate_entity := true;
    end if;
    if p2_a7 is null
      then ddp_control_rec.write_to_db := null;
    elsif p2_a7 = 0
      then ddp_control_rec.write_to_db := false;
    else ddp_control_rec.write_to_db := true;
    end if;
    if p2_a8 is null
      then ddp_control_rec.process_partial := null;
    elsif p2_a8 = 0
      then ddp_control_rec.process_partial := false;
    else ddp_control_rec.process_partial := true;
    end if;
    if p2_a9 is null
      then ddp_control_rec.process := null;
    elsif p2_a9 = 0
      then ddp_control_rec.process := false;
    else ddp_control_rec.process := true;
    end if;
    ddp_control_rec.process_entity := p2_a10;
    if p2_a11 is null
      then ddp_control_rec.clear_api_cache := null;
    elsif p2_a11 = 0
      then ddp_control_rec.clear_api_cache := false;
    else ddp_control_rec.clear_api_cache := true;
    end if;
    if p2_a12 is null
      then ddp_control_rec.clear_api_requests := null;
    elsif p2_a12 = 0
      then ddp_control_rec.clear_api_requests := false;
    else ddp_control_rec.clear_api_requests := true;
    end if;
    ddp_control_rec.request_category := p2_a13;
    ddp_control_rec.request_name := p2_a14;
    ddp_control_rec.org_id := rosetta_g_miss_num_map(p2_a15);

    oe_order_pub_w.rosetta_table_copy_in_p19(ddp_x_line_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      , p3_a40
      , p3_a41
      , p3_a42
      , p3_a43
      , p3_a44
      , p3_a45
      , p3_a46
      , p3_a47
      , p3_a48
      , p3_a49
      , p3_a50
      , p3_a51
      , p3_a52
      , p3_a53
      , p3_a54
      , p3_a55
      , p3_a56
      , p3_a57
      , p3_a58
      , p3_a59
      , p3_a60
      , p3_a61
      , p3_a62
      , p3_a63
      , p3_a64
      , p3_a65
      , p3_a66
      , p3_a67
      , p3_a68
      , p3_a69
      , p3_a70
      , p3_a71
      , p3_a72
      , p3_a73
      , p3_a74
      , p3_a75
      , p3_a76
      , p3_a77
      , p3_a78
      , p3_a79
      , p3_a80
      , p3_a81
      , p3_a82
      , p3_a83
      , p3_a84
      , p3_a85
      , p3_a86
      , p3_a87
      , p3_a88
      , p3_a89
      , p3_a90
      , p3_a91
      , p3_a92
      , p3_a93
      , p3_a94
      , p3_a95
      , p3_a96
      , p3_a97
      , p3_a98
      , p3_a99
      , p3_a100
      , p3_a101
      , p3_a102
      , p3_a103
      , p3_a104
      , p3_a105
      , p3_a106
      , p3_a107
      , p3_a108
      , p3_a109
      , p3_a110
      , p3_a111
      , p3_a112
      , p3_a113
      , p3_a114
      , p3_a115
      , p3_a116
      , p3_a117
      , p3_a118
      , p3_a119
      , p3_a120
      , p3_a121
      , p3_a122
      , p3_a123
      , p3_a124
      , p3_a125
      , p3_a126
      , p3_a127
      , p3_a128
      , p3_a129
      , p3_a130
      , p3_a131
      , p3_a132
      , p3_a133
      , p3_a134
      , p3_a135
      , p3_a136
      , p3_a137
      , p3_a138
      , p3_a139
      , p3_a140
      , p3_a141
      , p3_a142
      , p3_a143
      , p3_a144
      , p3_a145
      , p3_a146
      , p3_a147
      , p3_a148
      , p3_a149
      , p3_a150
      , p3_a151
      , p3_a152
      , p3_a153
      , p3_a154
      , p3_a155
      , p3_a156
      , p3_a157
      , p3_a158
      , p3_a159
      , p3_a160
      , p3_a161
      , p3_a162
      , p3_a163
      , p3_a164
      , p3_a165
      , p3_a166
      , p3_a167
      , p3_a168
      , p3_a169
      , p3_a170
      , p3_a171
      , p3_a172
      , p3_a173
      , p3_a174
      , p3_a175
      , p3_a176
      , p3_a177
      , p3_a178
      , p3_a179
      , p3_a180
      , p3_a181
      , p3_a182
      , p3_a183
      , p3_a184
      , p3_a185
      , p3_a186
      , p3_a187
      , p3_a188
      , p3_a189
      , p3_a190
      , p3_a191
      , p3_a192
      , p3_a193
      , p3_a194
      , p3_a195
      , p3_a196
      , p3_a197
      , p3_a198
      , p3_a199
      , p3_a200
      , p3_a201
      , p3_a202
      , p3_a203
      , p3_a204
      , p3_a205
      , p3_a206
      , p3_a207
      , p3_a208
      , p3_a209
      , p3_a210
      , p3_a211
      , p3_a212
      , p3_a213
      , p3_a214
      , p3_a215
      , p3_a216
      , p3_a217
      , p3_a218
      , p3_a219
      , p3_a220
      , p3_a221
      , p3_a222
      , p3_a223
      , p3_a224
      , p3_a225
      , p3_a226
      , p3_a227
      , p3_a228
      , p3_a229
      , p3_a230
      , p3_a231
      , p3_a232
      , p3_a233
      , p3_a234
      , p3_a235
      , p3_a236
      , p3_a237
      , p3_a238
      , p3_a239
      , p3_a240
      , p3_a241
      , p3_a242
      , p3_a243
      , p3_a244
      , p3_a245
      , p3_a246
      , p3_a247
      , p3_a248
      , p3_a249
      , p3_a250
      , p3_a251
      , p3_a252
      , p3_a253
      , p3_a254
      , p3_a255
      , p3_a256
      , p3_a257
      , p3_a258
      , p3_a259
      , p3_a260
      , p3_a261
      , p3_a262
      , p3_a263
      , p3_a264
      , p3_a265
      , p3_a266
      , p3_a267
      , p3_a268
      , p3_a269
      , p3_a270
      , p3_a271
      , p3_a272
      , p3_a273
      , p3_a274
      , p3_a275
      , p3_a276
      , p3_a277
      , p3_a278
      , p3_a279
      , p3_a280
      );


    -- here's the delegated call to the old PL/SQL routine
    oe_portal_util.lines(p_init_msg_list,
      p_validation_level,
      ddp_control_rec,
      ddp_x_line_tbl,
      p_return_status);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any



    oe_order_pub_w.rosetta_table_copy_out_p19(ddp_x_line_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      , p3_a40
      , p3_a41
      , p3_a42
      , p3_a43
      , p3_a44
      , p3_a45
      , p3_a46
      , p3_a47
      , p3_a48
      , p3_a49
      , p3_a50
      , p3_a51
      , p3_a52
      , p3_a53
      , p3_a54
      , p3_a55
      , p3_a56
      , p3_a57
      , p3_a58
      , p3_a59
      , p3_a60
      , p3_a61
      , p3_a62
      , p3_a63
      , p3_a64
      , p3_a65
      , p3_a66
      , p3_a67
      , p3_a68
      , p3_a69
      , p3_a70
      , p3_a71
      , p3_a72
      , p3_a73
      , p3_a74
      , p3_a75
      , p3_a76
      , p3_a77
      , p3_a78
      , p3_a79
      , p3_a80
      , p3_a81
      , p3_a82
      , p3_a83
      , p3_a84
      , p3_a85
      , p3_a86
      , p3_a87
      , p3_a88
      , p3_a89
      , p3_a90
      , p3_a91
      , p3_a92
      , p3_a93
      , p3_a94
      , p3_a95
      , p3_a96
      , p3_a97
      , p3_a98
      , p3_a99
      , p3_a100
      , p3_a101
      , p3_a102
      , p3_a103
      , p3_a104
      , p3_a105
      , p3_a106
      , p3_a107
      , p3_a108
      , p3_a109
      , p3_a110
      , p3_a111
      , p3_a112
      , p3_a113
      , p3_a114
      , p3_a115
      , p3_a116
      , p3_a117
      , p3_a118
      , p3_a119
      , p3_a120
      , p3_a121
      , p3_a122
      , p3_a123
      , p3_a124
      , p3_a125
      , p3_a126
      , p3_a127
      , p3_a128
      , p3_a129
      , p3_a130
      , p3_a131
      , p3_a132
      , p3_a133
      , p3_a134
      , p3_a135
      , p3_a136
      , p3_a137
      , p3_a138
      , p3_a139
      , p3_a140
      , p3_a141
      , p3_a142
      , p3_a143
      , p3_a144
      , p3_a145
      , p3_a146
      , p3_a147
      , p3_a148
      , p3_a149
      , p3_a150
      , p3_a151
      , p3_a152
      , p3_a153
      , p3_a154
      , p3_a155
      , p3_a156
      , p3_a157
      , p3_a158
      , p3_a159
      , p3_a160
      , p3_a161
      , p3_a162
      , p3_a163
      , p3_a164
      , p3_a165
      , p3_a166
      , p3_a167
      , p3_a168
      , p3_a169
      , p3_a170
      , p3_a171
      , p3_a172
      , p3_a173
      , p3_a174
      , p3_a175
      , p3_a176
      , p3_a177
      , p3_a178
      , p3_a179
      , p3_a180
      , p3_a181
      , p3_a182
      , p3_a183
      , p3_a184
      , p3_a185
      , p3_a186
      , p3_a187
      , p3_a188
      , p3_a189
      , p3_a190
      , p3_a191
      , p3_a192
      , p3_a193
      , p3_a194
      , p3_a195
      , p3_a196
      , p3_a197
      , p3_a198
      , p3_a199
      , p3_a200
      , p3_a201
      , p3_a202
      , p3_a203
      , p3_a204
      , p3_a205
      , p3_a206
      , p3_a207
      , p3_a208
      , p3_a209
      , p3_a210
      , p3_a211
      , p3_a212
      , p3_a213
      , p3_a214
      , p3_a215
      , p3_a216
      , p3_a217
      , p3_a218
      , p3_a219
      , p3_a220
      , p3_a221
      , p3_a222
      , p3_a223
      , p3_a224
      , p3_a225
      , p3_a226
      , p3_a227
      , p3_a228
      , p3_a229
      , p3_a230
      , p3_a231
      , p3_a232
      , p3_a233
      , p3_a234
      , p3_a235
      , p3_a236
      , p3_a237
      , p3_a238
      , p3_a239
      , p3_a240
      , p3_a241
      , p3_a242
      , p3_a243
      , p3_a244
      , p3_a245
      , p3_a246
      , p3_a247
      , p3_a248
      , p3_a249
      , p3_a250
      , p3_a251
      , p3_a252
      , p3_a253
      , p3_a254
      , p3_a255
      , p3_a256
      , p3_a257
      , p3_a258
      , p3_a259
      , p3_a260
      , p3_a261
      , p3_a262
      , p3_a263
      , p3_a264
      , p3_a265
      , p3_a266
      , p3_a267
      , p3_a268
      , p3_a269
      , p3_a270
      , p3_a271
      , p3_a272
      , p3_a273
      , p3_a274
      , p3_a275
      , p3_a276
      , p3_a277
      , p3_a278
      , p3_a279
      , p3_a280
      );

  end;

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
  )

  as
    ddp_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_header_rec.agreement_id := rosetta_g_miss_num_map(p0_a1);
    ddp_header_rec.attribute1 := p0_a2;
    ddp_header_rec.attribute10 := p0_a3;
    ddp_header_rec.attribute11 := p0_a4;
    ddp_header_rec.attribute12 := p0_a5;
    ddp_header_rec.attribute13 := p0_a6;
    ddp_header_rec.attribute14 := p0_a7;
    ddp_header_rec.attribute15 := p0_a8;
    ddp_header_rec.attribute16 := p0_a9;
    ddp_header_rec.attribute17 := p0_a10;
    ddp_header_rec.attribute18 := p0_a11;
    ddp_header_rec.attribute19 := p0_a12;
    ddp_header_rec.attribute2 := p0_a13;
    ddp_header_rec.attribute20 := p0_a14;
    ddp_header_rec.attribute3 := p0_a15;
    ddp_header_rec.attribute4 := p0_a16;
    ddp_header_rec.attribute5 := p0_a17;
    ddp_header_rec.attribute6 := p0_a18;
    ddp_header_rec.attribute7 := p0_a19;
    ddp_header_rec.attribute8 := p0_a20;
    ddp_header_rec.attribute9 := p0_a21;
    ddp_header_rec.booked_flag := p0_a22;
    ddp_header_rec.cancelled_flag := p0_a23;
    ddp_header_rec.context := p0_a24;
    ddp_header_rec.conversion_rate := rosetta_g_miss_num_map(p0_a25);
    ddp_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_header_rec.conversion_type_code := p0_a27;
    ddp_header_rec.customer_preference_set_code := p0_a28;
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p0_a29);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_header_rec.cust_po_number := p0_a31;
    ddp_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p0_a32);
    ddp_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p0_a33);
    ddp_header_rec.demand_class_code := p0_a34;
    ddp_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p0_a35);
    ddp_header_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a36);
    ddp_header_rec.fob_point_code := p0_a37;
    ddp_header_rec.freight_carrier_code := p0_a38;
    ddp_header_rec.freight_terms_code := p0_a39;
    ddp_header_rec.global_attribute1 := p0_a40;
    ddp_header_rec.global_attribute10 := p0_a41;
    ddp_header_rec.global_attribute11 := p0_a42;
    ddp_header_rec.global_attribute12 := p0_a43;
    ddp_header_rec.global_attribute13 := p0_a44;
    ddp_header_rec.global_attribute14 := p0_a45;
    ddp_header_rec.global_attribute15 := p0_a46;
    ddp_header_rec.global_attribute16 := p0_a47;
    ddp_header_rec.global_attribute17 := p0_a48;
    ddp_header_rec.global_attribute18 := p0_a49;
    ddp_header_rec.global_attribute19 := p0_a50;
    ddp_header_rec.global_attribute2 := p0_a51;
    ddp_header_rec.global_attribute20 := p0_a52;
    ddp_header_rec.global_attribute3 := p0_a53;
    ddp_header_rec.global_attribute4 := p0_a54;
    ddp_header_rec.global_attribute5 := p0_a55;
    ddp_header_rec.global_attribute6 := p0_a56;
    ddp_header_rec.global_attribute7 := p0_a57;
    ddp_header_rec.global_attribute8 := p0_a58;
    ddp_header_rec.global_attribute9 := p0_a59;
    ddp_header_rec.global_attribute_category := p0_a60;
    ddp_header_rec.tp_context := p0_a61;
    ddp_header_rec.tp_attribute1 := p0_a62;
    ddp_header_rec.tp_attribute2 := p0_a63;
    ddp_header_rec.tp_attribute3 := p0_a64;
    ddp_header_rec.tp_attribute4 := p0_a65;
    ddp_header_rec.tp_attribute5 := p0_a66;
    ddp_header_rec.tp_attribute6 := p0_a67;
    ddp_header_rec.tp_attribute7 := p0_a68;
    ddp_header_rec.tp_attribute8 := p0_a69;
    ddp_header_rec.tp_attribute9 := p0_a70;
    ddp_header_rec.tp_attribute10 := p0_a71;
    ddp_header_rec.tp_attribute11 := p0_a72;
    ddp_header_rec.tp_attribute12 := p0_a73;
    ddp_header_rec.tp_attribute13 := p0_a74;
    ddp_header_rec.tp_attribute14 := p0_a75;
    ddp_header_rec.tp_attribute15 := p0_a76;
    ddp_header_rec.header_id := rosetta_g_miss_num_map(p0_a77);
    ddp_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p0_a78);
    ddp_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p0_a79);
    ddp_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p0_a80);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p0_a81);
    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p0_a83);
    ddp_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p0_a84);
    ddp_header_rec.open_flag := p0_a85;
    ddp_header_rec.order_category_code := p0_a86;
    ddp_header_rec.ordered_date := rosetta_g_miss_date_in_map(p0_a87);
    ddp_header_rec.order_date_type_code := p0_a88;
    ddp_header_rec.order_number := rosetta_g_miss_num_map(p0_a89);
    ddp_header_rec.order_source_id := rosetta_g_miss_num_map(p0_a90);
    ddp_header_rec.order_type_id := rosetta_g_miss_num_map(p0_a91);
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p0_a92);
    ddp_header_rec.orig_sys_document_ref := p0_a93;
    ddp_header_rec.partial_shipments_allowed := p0_a94;
    ddp_header_rec.payment_term_id := rosetta_g_miss_num_map(p0_a95);
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p0_a96);
    ddp_header_rec.price_request_code := p0_a97;
    ddp_header_rec.pricing_date := rosetta_g_miss_date_in_map(p0_a98);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p0_a99);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p0_a100);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a101);
    ddp_header_rec.request_date := rosetta_g_miss_date_in_map(p0_a102);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p0_a103);
    ddp_header_rec.return_reason_code := p0_a104;
    ddp_header_rec.salesrep_id := rosetta_g_miss_num_map(p0_a105);
    ddp_header_rec.sales_channel_code := p0_a106;
    ddp_header_rec.shipment_priority_code := p0_a107;
    ddp_header_rec.shipping_method_code := p0_a108;
    ddp_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p0_a109);
    ddp_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p0_a110);
    ddp_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p0_a111);
    ddp_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p0_a112);
    ddp_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p0_a113);
    ddp_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p0_a114);
    ddp_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p0_a115);
    ddp_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p0_a116);
    ddp_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p0_a117);
    ddp_header_rec.source_document_id := rosetta_g_miss_num_map(p0_a118);
    ddp_header_rec.source_document_type_id := rosetta_g_miss_num_map(p0_a119);
    ddp_header_rec.tax_exempt_flag := p0_a120;
    ddp_header_rec.tax_exempt_number := p0_a121;
    ddp_header_rec.tax_exempt_reason_code := p0_a122;
    ddp_header_rec.tax_point_code := p0_a123;
    ddp_header_rec.transactional_curr_code := p0_a124;
    ddp_header_rec.version_number := rosetta_g_miss_num_map(p0_a125);
    ddp_header_rec.return_status := p0_a126;
    ddp_header_rec.db_flag := p0_a127;
    ddp_header_rec.operation := p0_a128;
    ddp_header_rec.first_ack_code := p0_a129;
    ddp_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p0_a130);
    ddp_header_rec.last_ack_code := p0_a131;
    ddp_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p0_a132);
    ddp_header_rec.change_reason := p0_a133;
    ddp_header_rec.change_comments := p0_a134;
    ddp_header_rec.change_sequence := p0_a135;
    ddp_header_rec.change_request_code := p0_a136;
    ddp_header_rec.ready_flag := p0_a137;
    ddp_header_rec.status_flag := p0_a138;
    ddp_header_rec.force_apply_flag := p0_a139;
    ddp_header_rec.drop_ship_flag := p0_a140;
    ddp_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p0_a141);
    ddp_header_rec.payment_type_code := p0_a142;
    ddp_header_rec.payment_amount := rosetta_g_miss_num_map(p0_a143);
    ddp_header_rec.check_number := p0_a144;
    ddp_header_rec.credit_card_code := p0_a145;
    ddp_header_rec.credit_card_holder_name := p0_a146;
    ddp_header_rec.credit_card_number := p0_a147;
    ddp_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p0_a148);
    ddp_header_rec.credit_card_approval_code := p0_a149;
    ddp_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p0_a150);
    ddp_header_rec.shipping_instructions := p0_a151;
    ddp_header_rec.packing_instructions := p0_a152;
    ddp_header_rec.flow_status_code := p0_a153;
    ddp_header_rec.booked_date := rosetta_g_miss_date_in_map(p0_a154);
    ddp_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p0_a155);
    ddp_header_rec.upgraded_flag := p0_a156;
    ddp_header_rec.lock_control := rosetta_g_miss_num_map(p0_a157);
    ddp_header_rec.ship_to_edi_location_code := p0_a158;
    ddp_header_rec.sold_to_edi_location_code := p0_a159;
    ddp_header_rec.bill_to_edi_location_code := p0_a160;
    ddp_header_rec.ship_from_edi_location_code := p0_a161;
    ddp_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p0_a162);
    ddp_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p0_a163);
    ddp_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p0_a164);
    ddp_header_rec.invoice_address_id := rosetta_g_miss_num_map(p0_a165);
    ddp_header_rec.ship_to_address_code := p0_a166;
    ddp_header_rec.xml_message_id := rosetta_g_miss_num_map(p0_a167);
    ddp_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p0_a168);
    ddp_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p0_a169);
    ddp_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p0_a170);
    ddp_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p0_a171);
    ddp_header_rec.xml_transaction_type_code := p0_a172;
    ddp_header_rec.blanket_number := rosetta_g_miss_num_map(p0_a173);
    ddp_header_rec.line_set_name := p0_a174;
    ddp_header_rec.fulfillment_set_name := p0_a175;
    ddp_header_rec.default_fulfillment_set := p0_a176;
    ddp_header_rec.quote_date := rosetta_g_miss_date_in_map(p0_a177);
    ddp_header_rec.quote_number := rosetta_g_miss_num_map(p0_a178);
    ddp_header_rec.sales_document_name := p0_a179;
    ddp_header_rec.transaction_phase_code := p0_a180;
    ddp_header_rec.user_status_code := p0_a181;
    ddp_header_rec.draft_submitted_flag := p0_a182;
    ddp_header_rec.source_document_version_number := rosetta_g_miss_num_map(p0_a183);
    ddp_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p0_a184);
    ddp_header_rec.minisite_id := rosetta_g_miss_num_map(p0_a185);
    ddp_header_rec.ib_owner := p0_a186;
    ddp_header_rec.ib_installed_at_location := p0_a187;
    ddp_header_rec.ib_current_location := p0_a188;
    ddp_header_rec.end_customer_id := rosetta_g_miss_num_map(p0_a189);
    ddp_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p0_a190);
    ddp_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p0_a191);
    ddp_header_rec.supplier_signature := p0_a192;
    ddp_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p0_a193);
    ddp_header_rec.customer_signature := p0_a194;
    ddp_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p0_a195);
    ddp_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p0_a196);
    ddp_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p0_a197);
    ddp_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p0_a198);
    ddp_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p0_a199);
    ddp_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p0_a200);
    ddp_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p0_a201);
    ddp_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p0_a202);
    ddp_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p0_a203);
    ddp_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p0_a204);
    ddp_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p0_a205);
    ddp_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p0_a206);
    ddp_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p0_a207);
    ddp_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p0_a208);
    ddp_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p0_a209);
    ddp_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p0_a210);
    ddp_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p0_a211);
    ddp_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p0_a212);
    ddp_header_rec.contract_template_id := rosetta_g_miss_num_map(p0_a213);
    ddp_header_rec.contract_source_doc_type_code := p0_a214;
    ddp_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p0_a215);

    -- here's the delegated call to the old PL/SQL routine
    oe_portal_util.set_header_cache(ddp_header_rec);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any
  end;

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
  )

  as
    ddx_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    oe_portal_util.get_header(p_header_id,
      ddx_header_rec);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_id);
    p1_a1 := rosetta_g_miss_num_map(ddx_header_rec.agreement_id);
    p1_a2 := ddx_header_rec.attribute1;
    p1_a3 := ddx_header_rec.attribute10;
    p1_a4 := ddx_header_rec.attribute11;
    p1_a5 := ddx_header_rec.attribute12;
    p1_a6 := ddx_header_rec.attribute13;
    p1_a7 := ddx_header_rec.attribute14;
    p1_a8 := ddx_header_rec.attribute15;
    p1_a9 := ddx_header_rec.attribute16;
    p1_a10 := ddx_header_rec.attribute17;
    p1_a11 := ddx_header_rec.attribute18;
    p1_a12 := ddx_header_rec.attribute19;
    p1_a13 := ddx_header_rec.attribute2;
    p1_a14 := ddx_header_rec.attribute20;
    p1_a15 := ddx_header_rec.attribute3;
    p1_a16 := ddx_header_rec.attribute4;
    p1_a17 := ddx_header_rec.attribute5;
    p1_a18 := ddx_header_rec.attribute6;
    p1_a19 := ddx_header_rec.attribute7;
    p1_a20 := ddx_header_rec.attribute8;
    p1_a21 := ddx_header_rec.attribute9;
    p1_a22 := ddx_header_rec.booked_flag;
    p1_a23 := ddx_header_rec.cancelled_flag;
    p1_a24 := ddx_header_rec.context;
    p1_a25 := rosetta_g_miss_num_map(ddx_header_rec.conversion_rate);
    p1_a26 := ddx_header_rec.conversion_rate_date;
    p1_a27 := ddx_header_rec.conversion_type_code;
    p1_a28 := ddx_header_rec.customer_preference_set_code;
    p1_a29 := rosetta_g_miss_num_map(ddx_header_rec.created_by);
    p1_a30 := ddx_header_rec.creation_date;
    p1_a31 := ddx_header_rec.cust_po_number;
    p1_a32 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_contact_id);
    p1_a33 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_id);
    p1_a34 := ddx_header_rec.demand_class_code;
    p1_a35 := rosetta_g_miss_num_map(ddx_header_rec.earliest_schedule_limit);
    p1_a36 := ddx_header_rec.expiration_date;
    p1_a37 := ddx_header_rec.fob_point_code;
    p1_a38 := ddx_header_rec.freight_carrier_code;
    p1_a39 := ddx_header_rec.freight_terms_code;
    p1_a40 := ddx_header_rec.global_attribute1;
    p1_a41 := ddx_header_rec.global_attribute10;
    p1_a42 := ddx_header_rec.global_attribute11;
    p1_a43 := ddx_header_rec.global_attribute12;
    p1_a44 := ddx_header_rec.global_attribute13;
    p1_a45 := ddx_header_rec.global_attribute14;
    p1_a46 := ddx_header_rec.global_attribute15;
    p1_a47 := ddx_header_rec.global_attribute16;
    p1_a48 := ddx_header_rec.global_attribute17;
    p1_a49 := ddx_header_rec.global_attribute18;
    p1_a50 := ddx_header_rec.global_attribute19;
    p1_a51 := ddx_header_rec.global_attribute2;
    p1_a52 := ddx_header_rec.global_attribute20;
    p1_a53 := ddx_header_rec.global_attribute3;
    p1_a54 := ddx_header_rec.global_attribute4;
    p1_a55 := ddx_header_rec.global_attribute5;
    p1_a56 := ddx_header_rec.global_attribute6;
    p1_a57 := ddx_header_rec.global_attribute7;
    p1_a58 := ddx_header_rec.global_attribute8;
    p1_a59 := ddx_header_rec.global_attribute9;
    p1_a60 := ddx_header_rec.global_attribute_category;
    p1_a61 := ddx_header_rec.tp_context;
    p1_a62 := ddx_header_rec.tp_attribute1;
    p1_a63 := ddx_header_rec.tp_attribute2;
    p1_a64 := ddx_header_rec.tp_attribute3;
    p1_a65 := ddx_header_rec.tp_attribute4;
    p1_a66 := ddx_header_rec.tp_attribute5;
    p1_a67 := ddx_header_rec.tp_attribute6;
    p1_a68 := ddx_header_rec.tp_attribute7;
    p1_a69 := ddx_header_rec.tp_attribute8;
    p1_a70 := ddx_header_rec.tp_attribute9;
    p1_a71 := ddx_header_rec.tp_attribute10;
    p1_a72 := ddx_header_rec.tp_attribute11;
    p1_a73 := ddx_header_rec.tp_attribute12;
    p1_a74 := ddx_header_rec.tp_attribute13;
    p1_a75 := ddx_header_rec.tp_attribute14;
    p1_a76 := ddx_header_rec.tp_attribute15;
    p1_a77 := rosetta_g_miss_num_map(ddx_header_rec.header_id);
    p1_a78 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_contact_id);
    p1_a79 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_id);
    p1_a80 := rosetta_g_miss_num_map(ddx_header_rec.invoicing_rule_id);
    p1_a81 := rosetta_g_miss_num_map(ddx_header_rec.last_updated_by);
    p1_a82 := ddx_header_rec.last_update_date;
    p1_a83 := rosetta_g_miss_num_map(ddx_header_rec.last_update_login);
    p1_a84 := rosetta_g_miss_num_map(ddx_header_rec.latest_schedule_limit);
    p1_a85 := ddx_header_rec.open_flag;
    p1_a86 := ddx_header_rec.order_category_code;
    p1_a87 := ddx_header_rec.ordered_date;
    p1_a88 := ddx_header_rec.order_date_type_code;
    p1_a89 := rosetta_g_miss_num_map(ddx_header_rec.order_number);
    p1_a90 := rosetta_g_miss_num_map(ddx_header_rec.order_source_id);
    p1_a91 := rosetta_g_miss_num_map(ddx_header_rec.order_type_id);
    p1_a92 := rosetta_g_miss_num_map(ddx_header_rec.org_id);
    p1_a93 := ddx_header_rec.orig_sys_document_ref;
    p1_a94 := ddx_header_rec.partial_shipments_allowed;
    p1_a95 := rosetta_g_miss_num_map(ddx_header_rec.payment_term_id);
    p1_a96 := rosetta_g_miss_num_map(ddx_header_rec.price_list_id);
    p1_a97 := ddx_header_rec.price_request_code;
    p1_a98 := ddx_header_rec.pricing_date;
    p1_a99 := rosetta_g_miss_num_map(ddx_header_rec.program_application_id);
    p1_a100 := rosetta_g_miss_num_map(ddx_header_rec.program_id);
    p1_a101 := ddx_header_rec.program_update_date;
    p1_a102 := ddx_header_rec.request_date;
    p1_a103 := rosetta_g_miss_num_map(ddx_header_rec.request_id);
    p1_a104 := ddx_header_rec.return_reason_code;
    p1_a105 := rosetta_g_miss_num_map(ddx_header_rec.salesrep_id);
    p1_a106 := ddx_header_rec.sales_channel_code;
    p1_a107 := ddx_header_rec.shipment_priority_code;
    p1_a108 := ddx_header_rec.shipping_method_code;
    p1_a109 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_org_id);
    p1_a110 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_above);
    p1_a111 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_below);
    p1_a112 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_contact_id);
    p1_a113 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_id);
    p1_a114 := rosetta_g_miss_num_map(ddx_header_rec.sold_from_org_id);
    p1_a115 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_contact_id);
    p1_a116 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_id);
    p1_a117 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_phone_id);
    p1_a118 := rosetta_g_miss_num_map(ddx_header_rec.source_document_id);
    p1_a119 := rosetta_g_miss_num_map(ddx_header_rec.source_document_type_id);
    p1_a120 := ddx_header_rec.tax_exempt_flag;
    p1_a121 := ddx_header_rec.tax_exempt_number;
    p1_a122 := ddx_header_rec.tax_exempt_reason_code;
    p1_a123 := ddx_header_rec.tax_point_code;
    p1_a124 := ddx_header_rec.transactional_curr_code;
    p1_a125 := rosetta_g_miss_num_map(ddx_header_rec.version_number);
    p1_a126 := ddx_header_rec.return_status;
    p1_a127 := ddx_header_rec.db_flag;
    p1_a128 := ddx_header_rec.operation;
    p1_a129 := ddx_header_rec.first_ack_code;
    p1_a130 := ddx_header_rec.first_ack_date;
    p1_a131 := ddx_header_rec.last_ack_code;
    p1_a132 := ddx_header_rec.last_ack_date;
    p1_a133 := ddx_header_rec.change_reason;
    p1_a134 := ddx_header_rec.change_comments;
    p1_a135 := ddx_header_rec.change_sequence;
    p1_a136 := ddx_header_rec.change_request_code;
    p1_a137 := ddx_header_rec.ready_flag;
    p1_a138 := ddx_header_rec.status_flag;
    p1_a139 := ddx_header_rec.force_apply_flag;
    p1_a140 := ddx_header_rec.drop_ship_flag;
    p1_a141 := rosetta_g_miss_num_map(ddx_header_rec.customer_payment_term_id);
    p1_a142 := ddx_header_rec.payment_type_code;
    p1_a143 := rosetta_g_miss_num_map(ddx_header_rec.payment_amount);
    p1_a144 := ddx_header_rec.check_number;
    p1_a145 := ddx_header_rec.credit_card_code;
    p1_a146 := ddx_header_rec.credit_card_holder_name;
    p1_a147 := ddx_header_rec.credit_card_number;
    p1_a148 := ddx_header_rec.credit_card_expiration_date;
    p1_a149 := ddx_header_rec.credit_card_approval_code;
    p1_a150 := ddx_header_rec.credit_card_approval_date;
    p1_a151 := ddx_header_rec.shipping_instructions;
    p1_a152 := ddx_header_rec.packing_instructions;
    p1_a153 := ddx_header_rec.flow_status_code;
    p1_a154 := ddx_header_rec.booked_date;
    p1_a155 := rosetta_g_miss_num_map(ddx_header_rec.marketing_source_code_id);
    p1_a156 := ddx_header_rec.upgraded_flag;
    p1_a157 := rosetta_g_miss_num_map(ddx_header_rec.lock_control);
    p1_a158 := ddx_header_rec.ship_to_edi_location_code;
    p1_a159 := ddx_header_rec.sold_to_edi_location_code;
    p1_a160 := ddx_header_rec.bill_to_edi_location_code;
    p1_a161 := ddx_header_rec.ship_from_edi_location_code;
    p1_a162 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_address_id);
    p1_a163 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_address_id);
    p1_a164 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_address_id);
    p1_a165 := rosetta_g_miss_num_map(ddx_header_rec.invoice_address_id);
    p1_a166 := ddx_header_rec.ship_to_address_code;
    p1_a167 := rosetta_g_miss_num_map(ddx_header_rec.xml_message_id);
    p1_a168 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_id);
    p1_a169 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_id);
    p1_a170 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_id);
    p1_a171 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_duration);
    p1_a172 := ddx_header_rec.xml_transaction_type_code;
    p1_a173 := rosetta_g_miss_num_map(ddx_header_rec.blanket_number);
    p1_a174 := ddx_header_rec.line_set_name;
    p1_a175 := ddx_header_rec.fulfillment_set_name;
    p1_a176 := ddx_header_rec.default_fulfillment_set;
    p1_a177 := ddx_header_rec.quote_date;
    p1_a178 := rosetta_g_miss_num_map(ddx_header_rec.quote_number);
    p1_a179 := ddx_header_rec.sales_document_name;
    p1_a180 := ddx_header_rec.transaction_phase_code;
    p1_a181 := ddx_header_rec.user_status_code;
    p1_a182 := ddx_header_rec.draft_submitted_flag;
    p1_a183 := rosetta_g_miss_num_map(ddx_header_rec.source_document_version_number);
    p1_a184 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_site_use_id);
    p1_a185 := rosetta_g_miss_num_map(ddx_header_rec.minisite_id);
    p1_a186 := ddx_header_rec.ib_owner;
    p1_a187 := ddx_header_rec.ib_installed_at_location;
    p1_a188 := ddx_header_rec.ib_current_location;
    p1_a189 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_id);
    p1_a190 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_contact_id);
    p1_a191 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_site_use_id);
    p1_a192 := ddx_header_rec.supplier_signature;
    p1_a193 := ddx_header_rec.supplier_signature_date;
    p1_a194 := ddx_header_rec.customer_signature;
    p1_a195 := ddx_header_rec.customer_signature_date;
    p1_a196 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_party_id);
    p1_a197 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_contact_id);
    p1_a198 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_id);
    p1_a199 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_id);
    p1_a200 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_use_id);
    p1_a201 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_id);
    p1_a202 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_id);
    p1_a203 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_use_id);
    p1_a204 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_id);
    p1_a205 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_id);
    p1_a206 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_use_id);
    p1_a207 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_party_id);
    p1_a208 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_party_id);
    p1_a209 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_party_id);
    p1_a210 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_contact_id);
    p1_a211 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_contact_id);
    p1_a212 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_contact_id);
    p1_a213 := rosetta_g_miss_num_map(ddx_header_rec.contract_template_id);
    p1_a214 := ddx_header_rec.contract_source_doc_type_code;
    p1_a215 := rosetta_g_miss_num_map(ddx_header_rec.contract_source_document_id);
  end;

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
  )

  as
    ddx_line_rec oe_order_pub.line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    oe_portal_util.get_line(p_line_id,
      ddx_line_rec);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_id);
    p1_a1 := ddx_line_rec.actual_arrival_date;
    p1_a2 := ddx_line_rec.actual_shipment_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_line_rec.agreement_id);
    p1_a4 := rosetta_g_miss_num_map(ddx_line_rec.arrival_set_id);
    p1_a5 := rosetta_g_miss_num_map(ddx_line_rec.ato_line_id);
    p1_a6 := ddx_line_rec.authorized_to_ship_flag;
    p1_a7 := rosetta_g_miss_num_map(ddx_line_rec.auto_selected_quantity);
    p1_a8 := ddx_line_rec.booked_flag;
    p1_a9 := ddx_line_rec.cancelled_flag;
    p1_a10 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity);
    p1_a11 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity2);
    p1_a12 := rosetta_g_miss_num_map(ddx_line_rec.commitment_id);
    p1_a13 := ddx_line_rec.component_code;
    p1_a14 := rosetta_g_miss_num_map(ddx_line_rec.component_number);
    p1_a15 := rosetta_g_miss_num_map(ddx_line_rec.component_sequence_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_line_rec.config_header_id);
    p1_a17 := rosetta_g_miss_num_map(ddx_line_rec.config_rev_nbr);
    p1_a18 := rosetta_g_miss_num_map(ddx_line_rec.config_display_sequence);
    p1_a19 := rosetta_g_miss_num_map(ddx_line_rec.configuration_id);
    p1_a20 := ddx_line_rec.context;
    p1_a21 := rosetta_g_miss_num_map(ddx_line_rec.created_by);
    p1_a22 := ddx_line_rec.creation_date;
    p1_a23 := rosetta_g_miss_num_map(ddx_line_rec.credit_invoice_line_id);
    p1_a24 := ddx_line_rec.customer_dock_code;
    p1_a25 := ddx_line_rec.customer_job;
    p1_a26 := ddx_line_rec.customer_production_line;
    p1_a27 := rosetta_g_miss_num_map(ddx_line_rec.customer_trx_line_id);
    p1_a28 := ddx_line_rec.cust_model_serial_number;
    p1_a29 := ddx_line_rec.cust_po_number;
    p1_a30 := ddx_line_rec.cust_production_seq_num;
    p1_a31 := rosetta_g_miss_num_map(ddx_line_rec.delivery_lead_time);
    p1_a32 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_contact_id);
    p1_a33 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_id);
    p1_a34 := ddx_line_rec.demand_bucket_type_code;
    p1_a35 := ddx_line_rec.demand_class_code;
    p1_a36 := ddx_line_rec.dep_plan_required_flag;
    p1_a37 := ddx_line_rec.earliest_acceptable_date;
    p1_a38 := ddx_line_rec.end_item_unit_number;
    p1_a39 := ddx_line_rec.explosion_date;
    p1_a40 := ddx_line_rec.fob_point_code;
    p1_a41 := ddx_line_rec.freight_carrier_code;
    p1_a42 := ddx_line_rec.freight_terms_code;
    p1_a43 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity);
    p1_a44 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity2);
    p1_a45 := rosetta_g_miss_num_map(ddx_line_rec.header_id);
    p1_a46 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_org_id);
    p1_a47 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_contact_id);
    p1_a48 := rosetta_g_miss_num_map(ddx_line_rec.inventory_item_id);
    p1_a49 := ddx_line_rec.invoice_interface_status_code;
    p1_a50 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_contact_id);
    p1_a51 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_id);
    p1_a52 := rosetta_g_miss_num_map(ddx_line_rec.invoicing_rule_id);
    p1_a53 := ddx_line_rec.ordered_item;
    p1_a54 := ddx_line_rec.item_revision;
    p1_a55 := ddx_line_rec.item_type_code;
    p1_a56 := rosetta_g_miss_num_map(ddx_line_rec.last_updated_by);
    p1_a57 := ddx_line_rec.last_update_date;
    p1_a58 := rosetta_g_miss_num_map(ddx_line_rec.last_update_login);
    p1_a59 := ddx_line_rec.latest_acceptable_date;
    p1_a60 := ddx_line_rec.line_category_code;
    p1_a61 := rosetta_g_miss_num_map(ddx_line_rec.line_id);
    p1_a62 := rosetta_g_miss_num_map(ddx_line_rec.line_number);
    p1_a63 := rosetta_g_miss_num_map(ddx_line_rec.line_type_id);
    p1_a64 := ddx_line_rec.link_to_line_ref;
    p1_a65 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_id);
    p1_a66 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_index);
    p1_a67 := rosetta_g_miss_num_map(ddx_line_rec.model_group_number);
    p1_a68 := rosetta_g_miss_num_map(ddx_line_rec.mfg_component_sequence_id);
    p1_a69 := rosetta_g_miss_num_map(ddx_line_rec.mfg_lead_time);
    p1_a70 := ddx_line_rec.open_flag;
    p1_a71 := ddx_line_rec.option_flag;
    p1_a72 := rosetta_g_miss_num_map(ddx_line_rec.option_number);
    p1_a73 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity);
    p1_a74 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity2);
    p1_a75 := ddx_line_rec.order_quantity_uom;
    p1_a76 := ddx_line_rec.ordered_quantity_uom2;
    p1_a77 := rosetta_g_miss_num_map(ddx_line_rec.org_id);
    p1_a78 := ddx_line_rec.orig_sys_document_ref;
    p1_a79 := ddx_line_rec.orig_sys_line_ref;
    p1_a80 := ddx_line_rec.over_ship_reason_code;
    p1_a81 := ddx_line_rec.over_ship_resolved_flag;
    p1_a82 := rosetta_g_miss_num_map(ddx_line_rec.payment_term_id);
    p1_a83 := rosetta_g_miss_num_map(ddx_line_rec.planning_priority);
    p1_a84 := ddx_line_rec.preferred_grade;
    p1_a85 := rosetta_g_miss_num_map(ddx_line_rec.price_list_id);
    p1_a86 := ddx_line_rec.price_request_code;
    p1_a87 := ddx_line_rec.pricing_date;
    p1_a88 := rosetta_g_miss_num_map(ddx_line_rec.pricing_quantity);
    p1_a89 := ddx_line_rec.pricing_quantity_uom;
    p1_a90 := rosetta_g_miss_num_map(ddx_line_rec.program_application_id);
    p1_a91 := rosetta_g_miss_num_map(ddx_line_rec.program_id);
    p1_a92 := ddx_line_rec.program_update_date;
    p1_a93 := rosetta_g_miss_num_map(ddx_line_rec.project_id);
    p1_a94 := ddx_line_rec.promise_date;
    p1_a95 := ddx_line_rec.re_source_flag;
    p1_a96 := rosetta_g_miss_num_map(ddx_line_rec.reference_customer_trx_line_id);
    p1_a97 := rosetta_g_miss_num_map(ddx_line_rec.reference_header_id);
    p1_a98 := rosetta_g_miss_num_map(ddx_line_rec.reference_line_id);
    p1_a99 := ddx_line_rec.reference_type;
    p1_a100 := ddx_line_rec.request_date;
    p1_a101 := rosetta_g_miss_num_map(ddx_line_rec.request_id);
    p1_a102 := rosetta_g_miss_num_map(ddx_line_rec.reserved_quantity);
    p1_a103 := ddx_line_rec.return_reason_code;
    p1_a104 := ddx_line_rec.rla_schedule_type_code;
    p1_a105 := rosetta_g_miss_num_map(ddx_line_rec.salesrep_id);
    p1_a106 := ddx_line_rec.schedule_arrival_date;
    p1_a107 := ddx_line_rec.schedule_ship_date;
    p1_a108 := ddx_line_rec.schedule_action_code;
    p1_a109 := ddx_line_rec.schedule_status_code;
    p1_a110 := rosetta_g_miss_num_map(ddx_line_rec.shipment_number);
    p1_a111 := ddx_line_rec.shipment_priority_code;
    p1_a112 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity);
    p1_a113 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity2);
    p1_a114 := ddx_line_rec.shipping_interfaced_flag;
    p1_a115 := ddx_line_rec.shipping_method_code;
    p1_a116 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity);
    p1_a117 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity2);
    p1_a118 := ddx_line_rec.shipping_quantity_uom;
    p1_a119 := ddx_line_rec.shipping_quantity_uom2;
    p1_a120 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_org_id);
    p1_a121 := ddx_line_rec.ship_model_complete_flag;
    p1_a122 := rosetta_g_miss_num_map(ddx_line_rec.ship_set_id);
    p1_a123 := rosetta_g_miss_num_map(ddx_line_rec.fulfillment_set_id);
    p1_a124 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_above);
    p1_a125 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_below);
    p1_a126 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_contact_id);
    p1_a127 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_id);
    p1_a128 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_org_id);
    p1_a129 := rosetta_g_miss_num_map(ddx_line_rec.sold_from_org_id);
    p1_a130 := ddx_line_rec.sort_order;
    p1_a131 := rosetta_g_miss_num_map(ddx_line_rec.source_document_id);
    p1_a132 := rosetta_g_miss_num_map(ddx_line_rec.source_document_line_id);
    p1_a133 := rosetta_g_miss_num_map(ddx_line_rec.source_document_type_id);
    p1_a134 := ddx_line_rec.source_type_code;
    p1_a135 := rosetta_g_miss_num_map(ddx_line_rec.split_from_line_id);
    p1_a136 := rosetta_g_miss_num_map(ddx_line_rec.task_id);
    p1_a137 := ddx_line_rec.tax_code;
    p1_a138 := ddx_line_rec.tax_date;
    p1_a139 := ddx_line_rec.tax_exempt_flag;
    p1_a140 := ddx_line_rec.tax_exempt_number;
    p1_a141 := ddx_line_rec.tax_exempt_reason_code;
    p1_a142 := ddx_line_rec.tax_point_code;
    p1_a143 := rosetta_g_miss_num_map(ddx_line_rec.tax_rate);
    p1_a144 := rosetta_g_miss_num_map(ddx_line_rec.tax_value);
    p1_a145 := ddx_line_rec.top_model_line_ref;
    p1_a146 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_id);
    p1_a147 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_index);
    p1_a148 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price);
    p1_a149 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price_per_pqty);
    p1_a150 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price);
    p1_a151 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price_per_pqty);
    p1_a152 := rosetta_g_miss_num_map(ddx_line_rec.veh_cus_item_cum_key_id);
    p1_a153 := ddx_line_rec.visible_demand_flag;
    p1_a154 := ddx_line_rec.return_status;
    p1_a155 := ddx_line_rec.db_flag;
    p1_a156 := ddx_line_rec.operation;
    p1_a157 := ddx_line_rec.first_ack_code;
    p1_a158 := ddx_line_rec.first_ack_date;
    p1_a159 := ddx_line_rec.last_ack_code;
    p1_a160 := ddx_line_rec.last_ack_date;
    p1_a161 := ddx_line_rec.change_reason;
    p1_a162 := ddx_line_rec.change_comments;
    p1_a163 := ddx_line_rec.arrival_set;
    p1_a164 := ddx_line_rec.ship_set;
    p1_a165 := ddx_line_rec.fulfillment_set;
    p1_a166 := rosetta_g_miss_num_map(ddx_line_rec.order_source_id);
    p1_a167 := ddx_line_rec.orig_sys_shipment_ref;
    p1_a168 := ddx_line_rec.change_sequence;
    p1_a169 := ddx_line_rec.change_request_code;
    p1_a170 := ddx_line_rec.status_flag;
    p1_a171 := ddx_line_rec.drop_ship_flag;
    p1_a172 := ddx_line_rec.customer_line_number;
    p1_a173 := ddx_line_rec.customer_shipment_number;
    p1_a174 := rosetta_g_miss_num_map(ddx_line_rec.customer_item_net_price);
    p1_a175 := rosetta_g_miss_num_map(ddx_line_rec.customer_payment_term_id);
    p1_a176 := rosetta_g_miss_num_map(ddx_line_rec.ordered_item_id);
    p1_a177 := ddx_line_rec.item_identifier_type;
    p1_a178 := ddx_line_rec.shipping_instructions;
    p1_a179 := ddx_line_rec.packing_instructions;
    p1_a180 := ddx_line_rec.calculate_price_flag;
    p1_a181 := rosetta_g_miss_num_map(ddx_line_rec.invoiced_quantity);
    p1_a182 := ddx_line_rec.service_txn_reason_code;
    p1_a183 := ddx_line_rec.service_txn_comments;
    p1_a184 := rosetta_g_miss_num_map(ddx_line_rec.service_duration);
    p1_a185 := ddx_line_rec.service_period;
    p1_a186 := ddx_line_rec.service_start_date;
    p1_a187 := ddx_line_rec.service_end_date;
    p1_a188 := ddx_line_rec.service_coterminate_flag;
    p1_a189 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_percent);
    p1_a190 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_percent);
    p1_a191 := rosetta_g_miss_num_map(ddx_line_rec.unit_percent_base_price);
    p1_a192 := rosetta_g_miss_num_map(ddx_line_rec.service_number);
    p1_a193 := ddx_line_rec.service_reference_type_code;
    p1_a194 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_line_id);
    p1_a195 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_system_id);
    p1_a196 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_order_number);
    p1_a197 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_line_number);
    p1_a198 := ddx_line_rec.service_reference_order;
    p1_a199 := ddx_line_rec.service_reference_line;
    p1_a200 := ddx_line_rec.service_reference_system;
    p1_a201 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_shipment_number);
    p1_a202 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_option_number);
    p1_a203 := rosetta_g_miss_num_map(ddx_line_rec.service_line_index);
    p1_a204 := rosetta_g_miss_num_map(ddx_line_rec.line_set_id);
    p1_a205 := ddx_line_rec.split_by;
    p1_a206 := ddx_line_rec.split_action_code;
    p1_a207 := ddx_line_rec.shippable_flag;
    p1_a208 := ddx_line_rec.model_remnant_flag;
    p1_a209 := ddx_line_rec.flow_status_code;
    p1_a210 := ddx_line_rec.fulfilled_flag;
    p1_a211 := ddx_line_rec.fulfillment_method_code;
    p1_a212 := rosetta_g_miss_num_map(ddx_line_rec.revenue_amount);
    p1_a213 := rosetta_g_miss_num_map(ddx_line_rec.marketing_source_code_id);
    p1_a214 := ddx_line_rec.fulfillment_date;
    if ddx_line_rec.semi_processed_flag is null
      then p1_a215 := null;
    elsif ddx_line_rec.semi_processed_flag
      then p1_a215 := 1;
    else p1_a215 := 0;
    end if;
    p1_a216 := ddx_line_rec.upgraded_flag;
    p1_a217 := rosetta_g_miss_num_map(ddx_line_rec.lock_control);
    p1_a218 := ddx_line_rec.subinventory;
    p1_a219 := ddx_line_rec.split_from_line_ref;
    p1_a220 := ddx_line_rec.split_from_shipment_ref;
    p1_a221 := ddx_line_rec.ship_to_edi_location_code;
    p1_a222 := ddx_line_rec.bill_to_edi_location_code;
    p1_a223 := ddx_line_rec.ship_from_edi_location_code;
    p1_a224 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_address_id);
    p1_a225 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_address_id);
    p1_a226 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_address_id);
    p1_a227 := rosetta_g_miss_num_map(ddx_line_rec.invoice_address_id);
    p1_a228 := ddx_line_rec.ship_to_address_code;
    p1_a229 := rosetta_g_miss_num_map(ddx_line_rec.original_inventory_item_id);
    p1_a230 := ddx_line_rec.original_item_identifier_type;
    p1_a231 := rosetta_g_miss_num_map(ddx_line_rec.original_ordered_item_id);
    p1_a232 := ddx_line_rec.original_ordered_item;
    p1_a233 := ddx_line_rec.item_substitution_type_code;
    p1_a234 := rosetta_g_miss_num_map(ddx_line_rec.late_demand_penalty_factor);
    p1_a235 := ddx_line_rec.override_atp_date_code;
    p1_a236 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_id);
    p1_a237 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_id);
    p1_a238 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_id);
    p1_a239 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_duration);
    p1_a240 := rosetta_g_miss_num_map(ddx_line_rec.unit_cost);
    p1_a241 := ddx_line_rec.user_item_description;
    p1_a242 := ddx_line_rec.xml_transaction_type_code;
    p1_a243 := rosetta_g_miss_num_map(ddx_line_rec.item_relationship_type);
    p1_a244 := rosetta_g_miss_num_map(ddx_line_rec.blanket_number);
    p1_a245 := rosetta_g_miss_num_map(ddx_line_rec.blanket_line_number);
    p1_a246 := rosetta_g_miss_num_map(ddx_line_rec.blanket_version_number);
    p1_a247 := ddx_line_rec.cso_response_flag;
    p1_a248 := ddx_line_rec.firm_demand_flag;
    p1_a249 := ddx_line_rec.earliest_ship_date;
    p1_a250 := ddx_line_rec.transaction_phase_code;
    p1_a251 := rosetta_g_miss_num_map(ddx_line_rec.source_document_version_number);
    p1_a252 := rosetta_g_miss_num_map(ddx_line_rec.minisite_id);
    p1_a253 := ddx_line_rec.ib_owner;
    p1_a254 := ddx_line_rec.ib_installed_at_location;
    p1_a255 := ddx_line_rec.ib_current_location;
    p1_a256 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_id);
    p1_a257 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_contact_id);
    p1_a258 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_site_use_id);
    p1_a259 := ddx_line_rec.supplier_signature;
    p1_a260 := ddx_line_rec.supplier_signature_date;
    p1_a261 := ddx_line_rec.customer_signature;
    p1_a262 := ddx_line_rec.customer_signature_date;
    p1_a263 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_id);
    p1_a264 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_id);
    p1_a265 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_use_id);
    p1_a266 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_id);
    p1_a267 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_id);
    p1_a268 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_use_id);
    p1_a269 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_id);
    p1_a270 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_id);
    p1_a271 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_use_id);
    p1_a272 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_party_id);
    p1_a273 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_party_id);
    p1_a274 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_party_id);
    p1_a275 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_contact_id);
    p1_a276 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_contact_id);
    p1_a277 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_contact_id);
    p1_a278 := rosetta_g_miss_num_map(ddx_line_rec.retrobill_request_id);
    p1_a279 := rosetta_g_miss_num_map(ddx_line_rec.original_list_price);
    p1_a280 := rosetta_g_miss_num_map(ddx_line_rec.commitment_applied_amount);
  end;

end oe_portal_util_w;

/
