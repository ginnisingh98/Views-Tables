--------------------------------------------------------
--  DDL for Package OE_ORDER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ONTRORDS.pls 120.0 2005/06/01 02:28:44 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_DATE_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_DATE_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_DATE_TABLE
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_NUMBER_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_DATE_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_DATE_TABLE
    , a102 JTF_DATE_TABLE
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_NUMBER_TABLE
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_NUMBER_TABLE
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_NUMBER_TABLE
    , a116 JTF_NUMBER_TABLE
    , a117 JTF_NUMBER_TABLE
    , a118 JTF_NUMBER_TABLE
    , a119 JTF_NUMBER_TABLE
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_100
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_100
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_VARCHAR2_TABLE_100
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_DATE_TABLE
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_DATE_TABLE
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_2000
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_VARCHAR2_TABLE_100
    , a137 JTF_VARCHAR2_TABLE_100
    , a138 JTF_VARCHAR2_TABLE_100
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_VARCHAR2_TABLE_100
    , a145 JTF_VARCHAR2_TABLE_100
    , a146 JTF_VARCHAR2_TABLE_100
    , a147 JTF_VARCHAR2_TABLE_100
    , a148 JTF_DATE_TABLE
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_DATE_TABLE
    , a151 JTF_VARCHAR2_TABLE_2000
    , a152 JTF_VARCHAR2_TABLE_2000
    , a153 JTF_VARCHAR2_TABLE_100
    , a154 JTF_DATE_TABLE
    , a155 JTF_NUMBER_TABLE
    , a156 JTF_VARCHAR2_TABLE_100
    , a157 JTF_NUMBER_TABLE
    , a158 JTF_VARCHAR2_TABLE_100
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_VARCHAR2_TABLE_100
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_NUMBER_TABLE
    , a163 JTF_NUMBER_TABLE
    , a164 JTF_NUMBER_TABLE
    , a165 JTF_NUMBER_TABLE
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_NUMBER_TABLE
    , a168 JTF_NUMBER_TABLE
    , a169 JTF_NUMBER_TABLE
    , a170 JTF_NUMBER_TABLE
    , a171 JTF_NUMBER_TABLE
    , a172 JTF_VARCHAR2_TABLE_100
    , a173 JTF_NUMBER_TABLE
    , a174 JTF_VARCHAR2_TABLE_100
    , a175 JTF_VARCHAR2_TABLE_100
    , a176 JTF_VARCHAR2_TABLE_100
    , a177 JTF_DATE_TABLE
    , a178 JTF_NUMBER_TABLE
    , a179 JTF_VARCHAR2_TABLE_300
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_VARCHAR2_TABLE_100
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_NUMBER_TABLE
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_NUMBER_TABLE
    , a186 JTF_VARCHAR2_TABLE_100
    , a187 JTF_VARCHAR2_TABLE_100
    , a188 JTF_VARCHAR2_TABLE_100
    , a189 JTF_NUMBER_TABLE
    , a190 JTF_NUMBER_TABLE
    , a191 JTF_NUMBER_TABLE
    , a192 JTF_VARCHAR2_TABLE_300
    , a193 JTF_DATE_TABLE
    , a194 JTF_VARCHAR2_TABLE_300
    , a195 JTF_DATE_TABLE
    , a196 JTF_NUMBER_TABLE
    , a197 JTF_NUMBER_TABLE
    , a198 JTF_NUMBER_TABLE
    , a199 JTF_NUMBER_TABLE
    , a200 JTF_NUMBER_TABLE
    , a201 JTF_NUMBER_TABLE
    , a202 JTF_NUMBER_TABLE
    , a203 JTF_NUMBER_TABLE
    , a204 JTF_NUMBER_TABLE
    , a205 JTF_NUMBER_TABLE
    , a206 JTF_NUMBER_TABLE
    , a207 JTF_NUMBER_TABLE
    , a208 JTF_NUMBER_TABLE
    , a209 JTF_NUMBER_TABLE
    , a210 JTF_NUMBER_TABLE
    , a211 JTF_NUMBER_TABLE
    , a212 JTF_NUMBER_TABLE
    , a213 JTF_NUMBER_TABLE
    , a214 JTF_VARCHAR2_TABLE_100
    , a215 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t oe_order_pub.header_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a79 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a84 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a89 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a90 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a91 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a92 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a95 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a100 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a109 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a110 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a111 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a115 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a116 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a117 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a118 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a119 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a125 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a130 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a141 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a143 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a144 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a146 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a147 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a148 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a149 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a150 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a151 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a152 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a153 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a154 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a155 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a156 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a157 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a158 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a159 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a160 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a161 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a162 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a163 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a164 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a165 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a166 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a167 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a168 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a169 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a170 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a171 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a172 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a173 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a174 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a175 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a176 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a177 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a178 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a179 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a180 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a181 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a182 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a183 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a184 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a185 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a186 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a187 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a188 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a189 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a190 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a191 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a192 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a193 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a194 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a195 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a196 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a197 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a198 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a199 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a200 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a201 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a202 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a203 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a204 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a205 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a206 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a207 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a208 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a209 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a210 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a211 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a212 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a213 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a214 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a215 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_400
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_400
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_400
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_400
    , a82 JTF_VARCHAR2_TABLE_400
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_100
    , a92 JTF_VARCHAR2_TABLE_100
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_100
    , a95 JTF_VARCHAR2_TABLE_400
    , a96 JTF_VARCHAR2_TABLE_400
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_400
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_400
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_VARCHAR2_TABLE_400
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_300
    , a115 JTF_VARCHAR2_TABLE_300
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_400
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_400
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p3(t oe_order_pub.header_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a100 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p5(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_2000
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_DATE_TABLE
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_DATE_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_NUMBER_TABLE
    , a105 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t oe_order_pub.header_adj_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a49 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a57 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a69 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a104 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t oe_order_pub.header_adj_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p9(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_price_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_300
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_300
    , a126 JTF_VARCHAR2_TABLE_300
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_NUMBER_TABLE
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t oe_order_pub.header_price_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p11(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t oe_order_pub.header_adj_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p13(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_adj_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t oe_order_pub.header_adj_assoc_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p15(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_scredit_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_2000
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p15(t oe_order_pub.header_scredit_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p17(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_scredit_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p17(t oe_order_pub.header_scredit_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p19(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_1000
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_DATE_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_2000
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_DATE_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_DATE_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_NUMBER_TABLE
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_DATE_TABLE
    , a93 JTF_NUMBER_TABLE
    , a94 JTF_DATE_TABLE
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_DATE_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_NUMBER_TABLE
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_DATE_TABLE
    , a107 JTF_DATE_TABLE
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_NUMBER_TABLE
    , a117 JTF_NUMBER_TABLE
    , a118 JTF_VARCHAR2_TABLE_100
    , a119 JTF_VARCHAR2_TABLE_100
    , a120 JTF_NUMBER_TABLE
    , a121 JTF_VARCHAR2_TABLE_100
    , a122 JTF_NUMBER_TABLE
    , a123 JTF_NUMBER_TABLE
    , a124 JTF_NUMBER_TABLE
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_NUMBER_TABLE
    , a127 JTF_NUMBER_TABLE
    , a128 JTF_NUMBER_TABLE
    , a129 JTF_NUMBER_TABLE
    , a130 JTF_VARCHAR2_TABLE_2000
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_NUMBER_TABLE
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_VARCHAR2_TABLE_100
    , a138 JTF_DATE_TABLE
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_VARCHAR2_TABLE_100
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_NUMBER_TABLE
    , a145 JTF_VARCHAR2_TABLE_100
    , a146 JTF_NUMBER_TABLE
    , a147 JTF_NUMBER_TABLE
    , a148 JTF_NUMBER_TABLE
    , a149 JTF_NUMBER_TABLE
    , a150 JTF_NUMBER_TABLE
    , a151 JTF_NUMBER_TABLE
    , a152 JTF_NUMBER_TABLE
    , a153 JTF_VARCHAR2_TABLE_100
    , a154 JTF_VARCHAR2_TABLE_100
    , a155 JTF_VARCHAR2_TABLE_100
    , a156 JTF_VARCHAR2_TABLE_100
    , a157 JTF_VARCHAR2_TABLE_100
    , a158 JTF_DATE_TABLE
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_DATE_TABLE
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_VARCHAR2_TABLE_2000
    , a163 JTF_VARCHAR2_TABLE_100
    , a164 JTF_VARCHAR2_TABLE_100
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_NUMBER_TABLE
    , a167 JTF_VARCHAR2_TABLE_100
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_VARCHAR2_TABLE_100
    , a171 JTF_VARCHAR2_TABLE_100
    , a172 JTF_VARCHAR2_TABLE_100
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_NUMBER_TABLE
    , a175 JTF_NUMBER_TABLE
    , a176 JTF_NUMBER_TABLE
    , a177 JTF_VARCHAR2_TABLE_100
    , a178 JTF_VARCHAR2_TABLE_2000
    , a179 JTF_VARCHAR2_TABLE_2000
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_NUMBER_TABLE
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_VARCHAR2_TABLE_2000
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_VARCHAR2_TABLE_100
    , a186 JTF_DATE_TABLE
    , a187 JTF_DATE_TABLE
    , a188 JTF_VARCHAR2_TABLE_100
    , a189 JTF_NUMBER_TABLE
    , a190 JTF_NUMBER_TABLE
    , a191 JTF_NUMBER_TABLE
    , a192 JTF_NUMBER_TABLE
    , a193 JTF_VARCHAR2_TABLE_100
    , a194 JTF_NUMBER_TABLE
    , a195 JTF_NUMBER_TABLE
    , a196 JTF_NUMBER_TABLE
    , a197 JTF_NUMBER_TABLE
    , a198 JTF_VARCHAR2_TABLE_100
    , a199 JTF_VARCHAR2_TABLE_100
    , a200 JTF_VARCHAR2_TABLE_100
    , a201 JTF_NUMBER_TABLE
    , a202 JTF_NUMBER_TABLE
    , a203 JTF_NUMBER_TABLE
    , a204 JTF_NUMBER_TABLE
    , a205 JTF_VARCHAR2_TABLE_300
    , a206 JTF_VARCHAR2_TABLE_100
    , a207 JTF_VARCHAR2_TABLE_100
    , a208 JTF_VARCHAR2_TABLE_100
    , a209 JTF_VARCHAR2_TABLE_100
    , a210 JTF_VARCHAR2_TABLE_100
    , a211 JTF_VARCHAR2_TABLE_100
    , a212 JTF_NUMBER_TABLE
    , a213 JTF_NUMBER_TABLE
    , a214 JTF_DATE_TABLE
    , a215 JTF_NUMBER_TABLE
    , a216 JTF_VARCHAR2_TABLE_100
    , a217 JTF_NUMBER_TABLE
    , a218 JTF_VARCHAR2_TABLE_100
    , a219 JTF_VARCHAR2_TABLE_100
    , a220 JTF_VARCHAR2_TABLE_100
    , a221 JTF_VARCHAR2_TABLE_100
    , a222 JTF_VARCHAR2_TABLE_100
    , a223 JTF_VARCHAR2_TABLE_100
    , a224 JTF_NUMBER_TABLE
    , a225 JTF_NUMBER_TABLE
    , a226 JTF_NUMBER_TABLE
    , a227 JTF_NUMBER_TABLE
    , a228 JTF_VARCHAR2_TABLE_100
    , a229 JTF_NUMBER_TABLE
    , a230 JTF_VARCHAR2_TABLE_100
    , a231 JTF_NUMBER_TABLE
    , a232 JTF_VARCHAR2_TABLE_2000
    , a233 JTF_VARCHAR2_TABLE_100
    , a234 JTF_NUMBER_TABLE
    , a235 JTF_VARCHAR2_TABLE_100
    , a236 JTF_NUMBER_TABLE
    , a237 JTF_NUMBER_TABLE
    , a238 JTF_NUMBER_TABLE
    , a239 JTF_NUMBER_TABLE
    , a240 JTF_NUMBER_TABLE
    , a241 JTF_VARCHAR2_TABLE_1000
    , a242 JTF_VARCHAR2_TABLE_100
    , a243 JTF_NUMBER_TABLE
    , a244 JTF_NUMBER_TABLE
    , a245 JTF_NUMBER_TABLE
    , a246 JTF_NUMBER_TABLE
    , a247 JTF_VARCHAR2_TABLE_100
    , a248 JTF_VARCHAR2_TABLE_100
    , a249 JTF_DATE_TABLE
    , a250 JTF_VARCHAR2_TABLE_100
    , a251 JTF_NUMBER_TABLE
    , a252 JTF_NUMBER_TABLE
    , a253 JTF_VARCHAR2_TABLE_100
    , a254 JTF_VARCHAR2_TABLE_100
    , a255 JTF_VARCHAR2_TABLE_100
    , a256 JTF_NUMBER_TABLE
    , a257 JTF_NUMBER_TABLE
    , a258 JTF_NUMBER_TABLE
    , a259 JTF_VARCHAR2_TABLE_300
    , a260 JTF_DATE_TABLE
    , a261 JTF_VARCHAR2_TABLE_300
    , a262 JTF_DATE_TABLE
    , a263 JTF_NUMBER_TABLE
    , a264 JTF_NUMBER_TABLE
    , a265 JTF_NUMBER_TABLE
    , a266 JTF_NUMBER_TABLE
    , a267 JTF_NUMBER_TABLE
    , a268 JTF_NUMBER_TABLE
    , a269 JTF_NUMBER_TABLE
    , a270 JTF_NUMBER_TABLE
    , a271 JTF_NUMBER_TABLE
    , a272 JTF_NUMBER_TABLE
    , a273 JTF_NUMBER_TABLE
    , a274 JTF_NUMBER_TABLE
    , a275 JTF_NUMBER_TABLE
    , a276 JTF_NUMBER_TABLE
    , a277 JTF_NUMBER_TABLE
    , a278 JTF_NUMBER_TABLE
    , a279 JTF_NUMBER_TABLE
    , a280 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p19(t oe_order_pub.line_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a46 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a47 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a48 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a57 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a58 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a59 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a62 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a65 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a66 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a67 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a68 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a69 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a73 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a74 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a77 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a82 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a88 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a90 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a91 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a92 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a93 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a94 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a98 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a100 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a107 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a110 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a117 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a120 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a122 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a123 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a124 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a125 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a126 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a127 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a128 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a129 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a131 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a132 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a133 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a135 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a136 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a138 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a143 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a144 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a146 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a147 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a148 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a149 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a150 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a151 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a152 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a153 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a154 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a155 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a156 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a157 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a158 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a159 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a160 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a161 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a162 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a163 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a164 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a165 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a166 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a167 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a168 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a169 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a170 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a171 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a172 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a173 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a174 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a175 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a176 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a177 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a178 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a179 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a180 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a181 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a182 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a183 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a184 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a185 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a186 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a187 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a188 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a189 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a190 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a191 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a192 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a193 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a194 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a195 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a196 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a197 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a198 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a199 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a200 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a201 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a202 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a203 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a204 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a205 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a206 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a207 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a208 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a209 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a210 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a211 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a212 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a213 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a214 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a215 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a216 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a217 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a218 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a219 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a220 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a221 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a222 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a223 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a224 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a225 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a226 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a227 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a228 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a229 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a230 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a231 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a232 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a233 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a234 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a235 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a236 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a237 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a238 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a239 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a240 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a241 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , a242 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a243 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a244 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a245 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a246 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a247 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a248 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a249 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a250 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a251 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a252 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a253 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a254 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a255 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a256 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a257 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a258 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a259 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a260 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a261 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a262 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a263 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a264 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a265 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a266 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a267 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a268 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a269 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a270 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a271 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a272 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a273 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a274 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a275 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a276 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a277 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a278 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a279 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a280 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p21(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_400
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_400
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_400
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_400
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_NUMBER_TABLE
    , a98 JTF_NUMBER_TABLE
    , a99 JTF_NUMBER_TABLE
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_400
    , a109 JTF_VARCHAR2_TABLE_400
    , a110 JTF_VARCHAR2_TABLE_100
    , a111 JTF_VARCHAR2_TABLE_100
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_400
    , a117 JTF_VARCHAR2_TABLE_2000
    , a118 JTF_VARCHAR2_TABLE_2000
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_100
    , a121 JTF_VARCHAR2_TABLE_400
    , a122 JTF_VARCHAR2_TABLE_100
    , a123 JTF_VARCHAR2_TABLE_400
    , a124 JTF_VARCHAR2_TABLE_100
    , a125 JTF_VARCHAR2_TABLE_400
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_400
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_400
    , a131 JTF_VARCHAR2_TABLE_300
    , a132 JTF_VARCHAR2_TABLE_300
    , a133 JTF_VARCHAR2_TABLE_300
    , a134 JTF_VARCHAR2_TABLE_300
    , a135 JTF_VARCHAR2_TABLE_300
    , a136 JTF_VARCHAR2_TABLE_300
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_300
    , a140 JTF_VARCHAR2_TABLE_300
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_300
    , a144 JTF_VARCHAR2_TABLE_300
    , a145 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p21(t oe_order_pub.line_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a97 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a98 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a99 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a101 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a112 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a113 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a114 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a135 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a138 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a139 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a140 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a141 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a142 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a143 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a144 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a145 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p23(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_VARCHAR2_TABLE_100
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_DATE_TABLE
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_DATE_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_NUMBER_TABLE
    , a81 JTF_NUMBER_TABLE
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_VARCHAR2_TABLE_100
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_VARCHAR2_TABLE_100
    , a87 JTF_VARCHAR2_TABLE_100
    , a88 JTF_VARCHAR2_TABLE_100
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_NUMBER_TABLE
    , a106 JTF_NUMBER_TABLE
    , a107 JTF_NUMBER_TABLE
    , a108 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p23(t oe_order_pub.line_adj_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a50 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a58 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a63 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a64 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a65 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a70 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a73 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a77 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a80 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a81 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a82 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a105 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a106 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a107 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a108 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p25(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p25(t oe_order_pub.line_adj_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p27(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_price_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    , a114 JTF_VARCHAR2_TABLE_300
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_VARCHAR2_TABLE_300
    , a118 JTF_VARCHAR2_TABLE_300
    , a119 JTF_VARCHAR2_TABLE_300
    , a120 JTF_VARCHAR2_TABLE_300
    , a121 JTF_VARCHAR2_TABLE_300
    , a122 JTF_VARCHAR2_TABLE_300
    , a123 JTF_VARCHAR2_TABLE_300
    , a124 JTF_VARCHAR2_TABLE_300
    , a125 JTF_VARCHAR2_TABLE_300
    , a126 JTF_VARCHAR2_TABLE_300
    , a127 JTF_VARCHAR2_TABLE_300
    , a128 JTF_VARCHAR2_TABLE_300
    , a129 JTF_VARCHAR2_TABLE_300
    , a130 JTF_VARCHAR2_TABLE_300
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_VARCHAR2_TABLE_100
    , a137 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p27(t oe_order_pub.line_price_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a36 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a39 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a41 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a42 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a43 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a53 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a54 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a55 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a56 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a57 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a58 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a59 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a60 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a61 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a62 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a63 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a64 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a65 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a66 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a67 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a68 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a69 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a70 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a71 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a72 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a73 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a74 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a75 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a76 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a77 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a78 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a79 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a80 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a81 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a82 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a83 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a84 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a85 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a86 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a87 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a88 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a89 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a90 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a91 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a92 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a93 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a94 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a95 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a96 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a97 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a98 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a99 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a100 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a101 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a102 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a103 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a104 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a105 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a106 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a107 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a108 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a109 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a110 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a111 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a112 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a113 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a114 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a115 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a116 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a117 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a118 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a119 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a120 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a121 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a122 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a123 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a124 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a125 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a126 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a127 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a128 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a129 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a130 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a131 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a132 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a133 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a134 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a135 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a136 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a137 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p29(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p29(t oe_order_pub.line_adj_att_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p31(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_adj_assoc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p31(t oe_order_pub.line_adj_assoc_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p33(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_scredit_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_DATE_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_2000
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p33(t oe_order_pub.line_scredit_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p35(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_scredit_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p35(t oe_order_pub.line_scredit_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p37(t out NOCOPY /* file.sql.39 change */ oe_order_pub.lot_serial_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p37(t oe_order_pub.lot_serial_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a21 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p39(t out NOCOPY /* file.sql.39 change */ oe_order_pub.lot_serial_val_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p39(t oe_order_pub.lot_serial_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p41(t out NOCOPY /* file.sql.39 change */ oe_order_pub.reservation_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p41(t oe_order_pub.reservation_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p43(t out NOCOPY /* file.sql.39 change */ oe_order_pub.reservation_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p43(t oe_order_pub.reservation_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p47(t out NOCOPY /* file.sql.39 change */ oe_order_pub.request_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_2000
    , a36 JTF_DATE_TABLE
    , a37 JTF_DATE_TABLE
    , a38 JTF_DATE_TABLE
    , a39 JTF_DATE_TABLE
    , a40 JTF_DATE_TABLE
    , a41 JTF_DATE_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p47(t oe_order_pub.request_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a36 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a38 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p49(t out NOCOPY /* file.sql.39 change */ oe_order_pub.requesting_entity_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p49(t oe_order_pub.requesting_entity_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p51(t out NOCOPY /* file.sql.39 change */ oe_order_pub.cancel_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p51(t oe_order_pub.cancel_line_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a15 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p53(t out NOCOPY /* file.sql.39 change */ oe_order_pub.payment_types_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p53(t oe_order_pub.payment_types_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a5 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a7 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a9 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a10 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a11 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a12 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a14 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a17 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a19 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a21 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a24 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a25 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a27 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a28 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a29 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a30 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a31 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a32 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a33 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p55(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_payment_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p55(t oe_order_pub.header_payment_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a51 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a52 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p57(t out NOCOPY /* file.sql.39 change */ oe_order_pub.header_payment_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p57(t oe_order_pub.header_payment_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p59(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_payment_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_DATE_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_NUMBER_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p59(t oe_order_pub.line_payment_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a4 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a7 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a8 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a10 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a11 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a12 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a13 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a14 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a15 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a16 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a17 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a18 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a19 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a20 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a21 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a22 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a23 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a24 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a25 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a26 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a27 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a28 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a29 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a30 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a31 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a32 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a33 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a34 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a35 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a36 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a37 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a38 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a39 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a40 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a41 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a42 out NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a43 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a44 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a45 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a46 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a47 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a48 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a49 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a50 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a51 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a52 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a53 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p61(t out NOCOPY /* file.sql.39 change */ oe_order_pub.line_payment_val_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p61(t oe_order_pub.line_payment_val_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

end oe_order_pub_w;

 

/
