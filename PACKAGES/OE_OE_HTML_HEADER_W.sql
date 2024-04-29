--------------------------------------------------------
--  DDL for Package OE_OE_HTML_HEADER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_HTML_HEADER_W" AUTHID CURRENT_USER as
  /* $Header: ONTRHDRS.pls 120.0 2005/05/31 23:51:25 appldev noship $ */
  procedure rosetta_table_copy_in_p0(t out NOCOPY /* file.sql.39 change */ oe_oe_html_header.number_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t oe_oe_html_header.number_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_oe_html_header.varchar2_tbl_type, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p1(t oe_oe_html_header.varchar2_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000);

  procedure default_attributes(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_transaction_phase_code  VARCHAR2
  );
  procedure change_attribute(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_header_id  NUMBER
    , p_attr_id  NUMBER
    , p_attr_value  VARCHAR2
    , p_attr_id_tbl JTF_NUMBER_TABLE
    , p_attr_value_tbl JTF_VARCHAR2_TABLE_2000
    , p8_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
  );
  procedure save_header(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_header_id  NUMBER
    , p_process  number
    , p5_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
  );
  procedure process_object(p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_cascade_flag out NOCOPY /* file.sql.39 change */  number
  );
  procedure populate_transient_attributes(p1_a0 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a1 out NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p1_a25 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a26 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a27 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a29 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a30 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a31 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a32 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a33 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a35 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a36 out NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p1_a47 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a48 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a49 out NOCOPY /* file.sql.39 change */  VARCHAR
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
    , p1_a77 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a78 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a79 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a80 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a81 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a82 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a83 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a84 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a85 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a87 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a88 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a89 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a90 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a91 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a92 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a93 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a94 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a95 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a96 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a97 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a98 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a99 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a100 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a101 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a102 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a103 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a105 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a106 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a107 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a109 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a110 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a111 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a112 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a113 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a114 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a115 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a116 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a117 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a118 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a119 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a120 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a122 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a123 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a124 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a125 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a126 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a127 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a128 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a129 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a130 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a131 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a132 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a133 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a135 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a136 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a138 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a141 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
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
  );
end oe_oe_html_header_w;

 

/
