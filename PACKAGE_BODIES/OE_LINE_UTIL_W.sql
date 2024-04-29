--------------------------------------------------------
--  DDL for Package Body OE_LINE_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_UTIL_W" as
  /* $Header: OERULINB.pls 120.0 2005/05/31 23:07:06 appldev noship $ */
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

  procedure post_line_process(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p1_a0 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a1 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a2 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a3 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a4 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a5 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a6 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a7 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a8 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a9 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a10 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a11 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a12 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a13 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p1_a14 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a15 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a16 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a17 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a18 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a19 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a20 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a21 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a22 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a23 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a24 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a25 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a26 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a27 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a28 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a29 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a30 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a31 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a32 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a33 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a34 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a35 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a36 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a37 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a38 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a39 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a40 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a41 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a42 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a43 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a44 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a45 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a46 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a47 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a48 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a49 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a50 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a51 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a52 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a53 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a54 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a55 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a56 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a57 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a58 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a59 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a60 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a61 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a62 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a63 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a64 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a65 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a66 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a67 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a68 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a69 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a70 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a71 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a72 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a73 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a74 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a75 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a76 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a77 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a78 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a79 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a80 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a81 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a82 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a83 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a84 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a85 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a86 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a87 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a88 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a89 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a90 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a91 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a92 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a93 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a94 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a95 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a96 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a97 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a98 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a99 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a100 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a101 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a102 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a103 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a104 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a105 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a106 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a107 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a108 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a109 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a110 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a111 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a112 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a113 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a114 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a115 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a116 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a117 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a118 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a119 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a120 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a121 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a122 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a123 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a124 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a125 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a126 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a127 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a128 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a129 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a130 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a131 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a132 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a133 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a134 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a135 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a136 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a137 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a138 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a139 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a140 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a141 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a142 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a143 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a144 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a145 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a146 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a147 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a148 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a149 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a150 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a151 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a152 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a153 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a154 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a155 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a156 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a157 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a158 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a159 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a160 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a161 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a162 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a163 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a164 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a165 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a166 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a167 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a168 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a169 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a170 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a171 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a172 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a173 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a174 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a175 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a176 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a177 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a178 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a179 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a180 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a181 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a182 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a183 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a184 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a185 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a186 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a187 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a188 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a189 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a190 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a191 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a192 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a193 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a194 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a195 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a196 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a197 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a198 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a199 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a200 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a201 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a202 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a203 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a204 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a205 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a206 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a207 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a208 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a209 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a210 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a211 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a212 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a213 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a214 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a215 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a216 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a217 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a218 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a219 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a220 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a221 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a222 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a223 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a224 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a225 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a226 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a227 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a228 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a229 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a230 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a231 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a232 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a233 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a234 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a235 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a236 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a237 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a238 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a239 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a240 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a241 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a242 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a243 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p1_a244 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a245 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a246 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a247 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a248 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a249 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a250 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a251 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a252 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p1_a253 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a254 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a255 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a256 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a257 in out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a258 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a259 in out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a260 in out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
  )

  as
    ddp_control_rec oe_globals.control_rec_type;
    ddp_x_line_tbl oe_order_pub.line_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    if p0_a0 is null
      then ddp_control_rec.controlled_operation := null;
    elsif p0_a0 = 0
      then ddp_control_rec.controlled_operation := false;
    else ddp_control_rec.controlled_operation := true;
    end if;
    if p0_a1 is null
      then ddp_control_rec.private_call := null;
    elsif p0_a1 = 0
      then ddp_control_rec.private_call := false;
    else ddp_control_rec.private_call := true;
    end if;
    if p0_a2 is null
      then ddp_control_rec.check_security := null;
    elsif p0_a2 = 0
      then ddp_control_rec.check_security := false;
    else ddp_control_rec.check_security := true;
    end if;
    if p0_a3 is null
      then ddp_control_rec.clear_dependents := null;
    elsif p0_a3 = 0
      then ddp_control_rec.clear_dependents := false;
    else ddp_control_rec.clear_dependents := true;
    end if;
    if p0_a4 is null
      then ddp_control_rec.default_attributes := null;
    elsif p0_a4 = 0
      then ddp_control_rec.default_attributes := false;
    else ddp_control_rec.default_attributes := true;
    end if;
    if p0_a5 is null
      then ddp_control_rec.change_attributes := null;
    elsif p0_a5 = 0
      then ddp_control_rec.change_attributes := false;
    else ddp_control_rec.change_attributes := true;
    end if;
    if p0_a6 is null
      then ddp_control_rec.validate_entity := null;
    elsif p0_a6 = 0
      then ddp_control_rec.validate_entity := false;
    else ddp_control_rec.validate_entity := true;
    end if;
    if p0_a7 is null
      then ddp_control_rec.write_to_db := null;
    elsif p0_a7 = 0
      then ddp_control_rec.write_to_db := false;
    else ddp_control_rec.write_to_db := true;
    end if;
    if p0_a8 is null
      then ddp_control_rec.process_partial := null;
    elsif p0_a8 = 0
      then ddp_control_rec.process_partial := false;
    else ddp_control_rec.process_partial := true;
    end if;
    if p0_a9 is null
      then ddp_control_rec.process := null;
    elsif p0_a9 = 0
      then ddp_control_rec.process := false;
    else ddp_control_rec.process := true;
    end if;
    ddp_control_rec.process_entity := p0_a10;
    if p0_a11 is null
      then ddp_control_rec.clear_api_cache := null;
    elsif p0_a11 = 0
      then ddp_control_rec.clear_api_cache := false;
    else ddp_control_rec.clear_api_cache := true;
    end if;
    if p0_a12 is null
      then ddp_control_rec.clear_api_requests := null;
    elsif p0_a12 = 0
      then ddp_control_rec.clear_api_requests := false;
    else ddp_control_rec.clear_api_requests := true;
    end if;
    ddp_control_rec.request_category := p0_a13;
    ddp_control_rec.request_name := p0_a14;
    ddp_control_rec.org_id := rosetta_g_miss_num_map(p0_a15);

   /* oe_order_pub_w_obsolete.rosetta_table_copy_in_p15(ddp_x_line_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      , p1_a110
      , p1_a111
      , p1_a112
      , p1_a113
      , p1_a114
      , p1_a115
      , p1_a116
      , p1_a117
      , p1_a118
      , p1_a119
      , p1_a120
      , p1_a121
      , p1_a122
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      , p1_a134
      , p1_a135
      , p1_a136
      , p1_a137
      , p1_a138
      , p1_a139
      , p1_a140
      , p1_a141
      , p1_a142
      , p1_a143
      , p1_a144
      , p1_a145
      , p1_a146
      , p1_a147
      , p1_a148
      , p1_a149
      , p1_a150
      , p1_a151
      , p1_a152
      , p1_a153
      , p1_a154
      , p1_a155
      , p1_a156
      , p1_a157
      , p1_a158
      , p1_a159
      , p1_a160
      , p1_a161
      , p1_a162
      , p1_a163
      , p1_a164
      , p1_a165
      , p1_a166
      , p1_a167
      , p1_a168
      , p1_a169
      , p1_a170
      , p1_a171
      , p1_a172
      , p1_a173
      , p1_a174
      , p1_a175
      , p1_a176
      , p1_a177
      , p1_a178
      , p1_a179
      , p1_a180
      , p1_a181
      , p1_a182
      , p1_a183
      , p1_a184
      , p1_a185
      , p1_a186
      , p1_a187
      , p1_a188
      , p1_a189
      , p1_a190
      , p1_a191
      , p1_a192
      , p1_a193
      , p1_a194
      , p1_a195
      , p1_a196
      , p1_a197
      , p1_a198
      , p1_a199
      , p1_a200
      , p1_a201
      , p1_a202
      , p1_a203
      , p1_a204
      , p1_a205
      , p1_a206
      , p1_a207
      , p1_a208
      , p1_a209
      , p1_a210
      , p1_a211
      , p1_a212
      , p1_a213
      , p1_a214
      , p1_a215
      , p1_a216
      , p1_a217
      , p1_a218
      , p1_a219
      , p1_a220
      , p1_a221
      , p1_a222
      , p1_a223
      , p1_a224
      , p1_a225
      , p1_a226
      , p1_a227
      , p1_a228
      , p1_a229
      , p1_a230
      , p1_a231
      , p1_a232
      , p1_a233
      , p1_a234
      , p1_a235
      , p1_a236
      , p1_a237
      , p1_a238
      , p1_a239
      , p1_a240
      , p1_a241
      , p1_a242
      , p1_a243
      , p1_a244
      , p1_a245
      , p1_a246
      , p1_a247
      , p1_a248
      , p1_a249
      , p1_a250
      , p1_a251
      , p1_a252
      , p1_a253
      , p1_a254
      , p1_a255
      , p1_a256
      , p1_a257
      , p1_a258
      , p1_a259
      , p1_a260
      );
   */
    -- here's the delegated call to the old PL/SQL routine
    oe_line_util.post_line_process(ddp_control_rec,
      ddp_x_line_tbl);

    -- copy data back from the local variables to OUT NOCOPY /* file.sql.39 change */ or IN-OUT args, if any
/*
    oe_order_pub_w_obsolete.rosetta_table_copy_out_p15(ddp_x_line_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      , p1_a110
      , p1_a111
      , p1_a112
      , p1_a113
      , p1_a114
      , p1_a115
      , p1_a116
      , p1_a117
      , p1_a118
      , p1_a119
      , p1_a120
      , p1_a121
      , p1_a122
      , p1_a123
      , p1_a124
      , p1_a125
      , p1_a126
      , p1_a127
      , p1_a128
      , p1_a129
      , p1_a130
      , p1_a131
      , p1_a132
      , p1_a133
      , p1_a134
      , p1_a135
      , p1_a136
      , p1_a137
      , p1_a138
      , p1_a139
      , p1_a140
      , p1_a141
      , p1_a142
      , p1_a143
      , p1_a144
      , p1_a145
      , p1_a146
      , p1_a147
      , p1_a148
      , p1_a149
      , p1_a150
      , p1_a151
      , p1_a152
      , p1_a153
      , p1_a154
      , p1_a155
      , p1_a156
      , p1_a157
      , p1_a158
      , p1_a159
      , p1_a160
      , p1_a161
      , p1_a162
      , p1_a163
      , p1_a164
      , p1_a165
      , p1_a166
      , p1_a167
      , p1_a168
      , p1_a169
      , p1_a170
      , p1_a171
      , p1_a172
      , p1_a173
      , p1_a174
      , p1_a175
      , p1_a176
      , p1_a177
      , p1_a178
      , p1_a179
      , p1_a180
      , p1_a181
      , p1_a182
      , p1_a183
      , p1_a184
      , p1_a185
      , p1_a186
      , p1_a187
      , p1_a188
      , p1_a189
      , p1_a190
      , p1_a191
      , p1_a192
      , p1_a193
      , p1_a194
      , p1_a195
      , p1_a196
      , p1_a197
      , p1_a198
      , p1_a199
      , p1_a200
      , p1_a201
      , p1_a202
      , p1_a203
      , p1_a204
      , p1_a205
      , p1_a206
      , p1_a207
      , p1_a208
      , p1_a209
      , p1_a210
      , p1_a211
      , p1_a212
      , p1_a213
      , p1_a214
      , p1_a215
      , p1_a216
      , p1_a217
      , p1_a218
      , p1_a219
      , p1_a220
      , p1_a221
      , p1_a222
      , p1_a223
      , p1_a224
      , p1_a225
      , p1_a226
      , p1_a227
      , p1_a228
      , p1_a229
      , p1_a230
      , p1_a231
      , p1_a232
      , p1_a233
      , p1_a234
      , p1_a235
      , p1_a236
      , p1_a237
      , p1_a238
      , p1_a239
      , p1_a240
      , p1_a241
      , p1_a242
      , p1_a243
      , p1_a244
      , p1_a245
      , p1_a246
      , p1_a247
      , p1_a248
      , p1_a249
      , p1_a250
      , p1_a251
      , p1_a252
      , p1_a253
      , p1_a254
      , p1_a255
      , p1_a256
      , p1_a257
      , p1_a258
      , p1_a259
      , p1_a260
      );
*/
  end;

end oe_line_util_w;

/
