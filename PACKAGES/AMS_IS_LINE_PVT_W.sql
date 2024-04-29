--------------------------------------------------------
--  DDL for Package AMS_IS_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IS_LINE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswisls.pls 120.2 2005/10/18 03:01 rmbhanda ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ams_is_line_pvt.is_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_4000
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_2000
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_VARCHAR2_TABLE_2000
    , a23 JTF_VARCHAR2_TABLE_2000
    , a24 JTF_VARCHAR2_TABLE_2000
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_VARCHAR2_TABLE_2000
    , a32 JTF_VARCHAR2_TABLE_2000
    , a33 JTF_VARCHAR2_TABLE_2000
    , a34 JTF_VARCHAR2_TABLE_2000
    , a35 JTF_VARCHAR2_TABLE_2000
    , a36 JTF_VARCHAR2_TABLE_2000
    , a37 JTF_VARCHAR2_TABLE_2000
    , a38 JTF_VARCHAR2_TABLE_2000
    , a39 JTF_VARCHAR2_TABLE_2000
    , a40 JTF_VARCHAR2_TABLE_2000
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_VARCHAR2_TABLE_2000
    , a43 JTF_VARCHAR2_TABLE_2000
    , a44 JTF_VARCHAR2_TABLE_2000
    , a45 JTF_VARCHAR2_TABLE_2000
    , a46 JTF_VARCHAR2_TABLE_2000
    , a47 JTF_VARCHAR2_TABLE_2000
    , a48 JTF_VARCHAR2_TABLE_2000
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_VARCHAR2_TABLE_2000
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_VARCHAR2_TABLE_2000
    , a54 JTF_VARCHAR2_TABLE_2000
    , a55 JTF_VARCHAR2_TABLE_2000
    , a56 JTF_VARCHAR2_TABLE_2000
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_VARCHAR2_TABLE_2000
    , a59 JTF_VARCHAR2_TABLE_2000
    , a60 JTF_VARCHAR2_TABLE_2000
    , a61 JTF_VARCHAR2_TABLE_2000
    , a62 JTF_VARCHAR2_TABLE_2000
    , a63 JTF_VARCHAR2_TABLE_2000
    , a64 JTF_VARCHAR2_TABLE_2000
    , a65 JTF_VARCHAR2_TABLE_2000
    , a66 JTF_VARCHAR2_TABLE_2000
    , a67 JTF_VARCHAR2_TABLE_2000
    , a68 JTF_VARCHAR2_TABLE_2000
    , a69 JTF_VARCHAR2_TABLE_2000
    , a70 JTF_VARCHAR2_TABLE_2000
    , a71 JTF_VARCHAR2_TABLE_2000
    , a72 JTF_VARCHAR2_TABLE_2000
    , a73 JTF_VARCHAR2_TABLE_2000
    , a74 JTF_VARCHAR2_TABLE_2000
    , a75 JTF_VARCHAR2_TABLE_2000
    , a76 JTF_VARCHAR2_TABLE_2000
    , a77 JTF_VARCHAR2_TABLE_2000
    , a78 JTF_VARCHAR2_TABLE_2000
    , a79 JTF_VARCHAR2_TABLE_2000
    , a80 JTF_VARCHAR2_TABLE_2000
    , a81 JTF_VARCHAR2_TABLE_2000
    , a82 JTF_VARCHAR2_TABLE_2000
    , a83 JTF_VARCHAR2_TABLE_2000
    , a84 JTF_VARCHAR2_TABLE_2000
    , a85 JTF_VARCHAR2_TABLE_2000
    , a86 JTF_VARCHAR2_TABLE_2000
    , a87 JTF_VARCHAR2_TABLE_2000
    , a88 JTF_VARCHAR2_TABLE_2000
    , a89 JTF_VARCHAR2_TABLE_2000
    , a90 JTF_VARCHAR2_TABLE_2000
    , a91 JTF_VARCHAR2_TABLE_2000
    , a92 JTF_VARCHAR2_TABLE_2000
    , a93 JTF_VARCHAR2_TABLE_2000
    , a94 JTF_VARCHAR2_TABLE_2000
    , a95 JTF_VARCHAR2_TABLE_2000
    , a96 JTF_VARCHAR2_TABLE_2000
    , a97 JTF_VARCHAR2_TABLE_2000
    , a98 JTF_VARCHAR2_TABLE_2000
    , a99 JTF_VARCHAR2_TABLE_2000
    , a100 JTF_VARCHAR2_TABLE_2000
    , a101 JTF_VARCHAR2_TABLE_2000
    , a102 JTF_VARCHAR2_TABLE_2000
    , a103 JTF_VARCHAR2_TABLE_2000
    , a104 JTF_VARCHAR2_TABLE_2000
    , a105 JTF_VARCHAR2_TABLE_2000
    , a106 JTF_VARCHAR2_TABLE_2000
    , a107 JTF_VARCHAR2_TABLE_2000
    , a108 JTF_VARCHAR2_TABLE_2000
    , a109 JTF_VARCHAR2_TABLE_2000
    , a110 JTF_VARCHAR2_TABLE_2000
    , a111 JTF_VARCHAR2_TABLE_2000
    , a112 JTF_VARCHAR2_TABLE_2000
    , a113 JTF_VARCHAR2_TABLE_2000
    , a114 JTF_VARCHAR2_TABLE_2000
    , a115 JTF_VARCHAR2_TABLE_2000
    , a116 JTF_VARCHAR2_TABLE_2000
    , a117 JTF_VARCHAR2_TABLE_2000
    , a118 JTF_VARCHAR2_TABLE_2000
    , a119 JTF_VARCHAR2_TABLE_2000
    , a120 JTF_VARCHAR2_TABLE_2000
    , a121 JTF_VARCHAR2_TABLE_2000
    , a122 JTF_VARCHAR2_TABLE_2000
    , a123 JTF_VARCHAR2_TABLE_2000
    , a124 JTF_VARCHAR2_TABLE_2000
    , a125 JTF_VARCHAR2_TABLE_2000
    , a126 JTF_VARCHAR2_TABLE_2000
    , a127 JTF_VARCHAR2_TABLE_2000
    , a128 JTF_VARCHAR2_TABLE_2000
    , a129 JTF_VARCHAR2_TABLE_2000
    , a130 JTF_VARCHAR2_TABLE_2000
    , a131 JTF_VARCHAR2_TABLE_2000
    , a132 JTF_VARCHAR2_TABLE_2000
    , a133 JTF_VARCHAR2_TABLE_2000
    , a134 JTF_VARCHAR2_TABLE_2000
    , a135 JTF_VARCHAR2_TABLE_2000
    , a136 JTF_VARCHAR2_TABLE_2000
    , a137 JTF_VARCHAR2_TABLE_2000
    , a138 JTF_VARCHAR2_TABLE_2000
    , a139 JTF_VARCHAR2_TABLE_2000
    , a140 JTF_VARCHAR2_TABLE_2000
    , a141 JTF_VARCHAR2_TABLE_2000
    , a142 JTF_VARCHAR2_TABLE_2000
    , a143 JTF_VARCHAR2_TABLE_2000
    , a144 JTF_VARCHAR2_TABLE_2000
    , a145 JTF_VARCHAR2_TABLE_2000
    , a146 JTF_VARCHAR2_TABLE_2000
    , a147 JTF_VARCHAR2_TABLE_2000
    , a148 JTF_VARCHAR2_TABLE_2000
    , a149 JTF_VARCHAR2_TABLE_2000
    , a150 JTF_VARCHAR2_TABLE_2000
    , a151 JTF_VARCHAR2_TABLE_2000
    , a152 JTF_VARCHAR2_TABLE_2000
    , a153 JTF_VARCHAR2_TABLE_2000
    , a154 JTF_VARCHAR2_TABLE_2000
    , a155 JTF_VARCHAR2_TABLE_2000
    , a156 JTF_VARCHAR2_TABLE_2000
    , a157 JTF_VARCHAR2_TABLE_2000
    , a158 JTF_VARCHAR2_TABLE_2000
    , a159 JTF_VARCHAR2_TABLE_2000
    , a160 JTF_VARCHAR2_TABLE_2000
    , a161 JTF_VARCHAR2_TABLE_2000
    , a162 JTF_VARCHAR2_TABLE_2000
    , a163 JTF_VARCHAR2_TABLE_2000
    , a164 JTF_VARCHAR2_TABLE_2000
    , a165 JTF_VARCHAR2_TABLE_2000
    , a166 JTF_VARCHAR2_TABLE_2000
    , a167 JTF_VARCHAR2_TABLE_2000
    , a168 JTF_VARCHAR2_TABLE_2000
    , a169 JTF_VARCHAR2_TABLE_2000
    , a170 JTF_VARCHAR2_TABLE_2000
    , a171 JTF_VARCHAR2_TABLE_2000
    , a172 JTF_VARCHAR2_TABLE_2000
    , a173 JTF_VARCHAR2_TABLE_2000
    , a174 JTF_VARCHAR2_TABLE_2000
    , a175 JTF_VARCHAR2_TABLE_2000
    , a176 JTF_VARCHAR2_TABLE_2000
    , a177 JTF_VARCHAR2_TABLE_2000
    , a178 JTF_VARCHAR2_TABLE_2000
    , a179 JTF_VARCHAR2_TABLE_2000
    , a180 JTF_VARCHAR2_TABLE_2000
    , a181 JTF_VARCHAR2_TABLE_2000
    , a182 JTF_VARCHAR2_TABLE_2000
    , a183 JTF_VARCHAR2_TABLE_2000
    , a184 JTF_VARCHAR2_TABLE_2000
    , a185 JTF_VARCHAR2_TABLE_2000
    , a186 JTF_VARCHAR2_TABLE_2000
    , a187 JTF_VARCHAR2_TABLE_2000
    , a188 JTF_VARCHAR2_TABLE_2000
    , a189 JTF_VARCHAR2_TABLE_2000
    , a190 JTF_VARCHAR2_TABLE_2000
    , a191 JTF_VARCHAR2_TABLE_2000
    , a192 JTF_VARCHAR2_TABLE_2000
    , a193 JTF_VARCHAR2_TABLE_2000
    , a194 JTF_VARCHAR2_TABLE_2000
    , a195 JTF_VARCHAR2_TABLE_2000
    , a196 JTF_VARCHAR2_TABLE_2000
    , a197 JTF_VARCHAR2_TABLE_2000
    , a198 JTF_VARCHAR2_TABLE_2000
    , a199 JTF_VARCHAR2_TABLE_2000
    , a200 JTF_VARCHAR2_TABLE_2000
    , a201 JTF_VARCHAR2_TABLE_2000
    , a202 JTF_VARCHAR2_TABLE_2000
    , a203 JTF_VARCHAR2_TABLE_2000
    , a204 JTF_VARCHAR2_TABLE_2000
    , a205 JTF_VARCHAR2_TABLE_2000
    , a206 JTF_VARCHAR2_TABLE_2000
    , a207 JTF_VARCHAR2_TABLE_2000
    , a208 JTF_VARCHAR2_TABLE_2000
    , a209 JTF_VARCHAR2_TABLE_2000
    , a210 JTF_VARCHAR2_TABLE_2000
    , a211 JTF_VARCHAR2_TABLE_2000
    , a212 JTF_VARCHAR2_TABLE_2000
    , a213 JTF_VARCHAR2_TABLE_2000
    , a214 JTF_VARCHAR2_TABLE_2000
    , a215 JTF_VARCHAR2_TABLE_2000
    , a216 JTF_VARCHAR2_TABLE_2000
    , a217 JTF_VARCHAR2_TABLE_2000
    , a218 JTF_VARCHAR2_TABLE_2000
    , a219 JTF_VARCHAR2_TABLE_2000
    , a220 JTF_VARCHAR2_TABLE_2000
    , a221 JTF_VARCHAR2_TABLE_2000
    , a222 JTF_VARCHAR2_TABLE_2000
    , a223 JTF_VARCHAR2_TABLE_2000
    , a224 JTF_VARCHAR2_TABLE_2000
    , a225 JTF_VARCHAR2_TABLE_2000
    , a226 JTF_VARCHAR2_TABLE_2000
    , a227 JTF_VARCHAR2_TABLE_2000
    , a228 JTF_VARCHAR2_TABLE_2000
    , a229 JTF_VARCHAR2_TABLE_2000
    , a230 JTF_VARCHAR2_TABLE_2000
    , a231 JTF_VARCHAR2_TABLE_2000
    , a232 JTF_VARCHAR2_TABLE_2000
    , a233 JTF_VARCHAR2_TABLE_2000
    , a234 JTF_VARCHAR2_TABLE_2000
    , a235 JTF_VARCHAR2_TABLE_2000
    , a236 JTF_VARCHAR2_TABLE_2000
    , a237 JTF_VARCHAR2_TABLE_2000
    , a238 JTF_VARCHAR2_TABLE_2000
    , a239 JTF_VARCHAR2_TABLE_2000
    , a240 JTF_VARCHAR2_TABLE_2000
    , a241 JTF_VARCHAR2_TABLE_2000
    , a242 JTF_VARCHAR2_TABLE_2000
    , a243 JTF_VARCHAR2_TABLE_2000
    , a244 JTF_VARCHAR2_TABLE_2000
    , a245 JTF_VARCHAR2_TABLE_2000
    , a246 JTF_VARCHAR2_TABLE_2000
    , a247 JTF_VARCHAR2_TABLE_2000
    , a248 JTF_VARCHAR2_TABLE_2000
    , a249 JTF_VARCHAR2_TABLE_2000
    , a250 JTF_VARCHAR2_TABLE_2000
    , a251 JTF_VARCHAR2_TABLE_2000
    , a252 JTF_VARCHAR2_TABLE_2000
    , a253 JTF_VARCHAR2_TABLE_2000
    , a254 JTF_VARCHAR2_TABLE_4000
    , a255 JTF_VARCHAR2_TABLE_4000
    , a256 JTF_VARCHAR2_TABLE_4000
    , a257 JTF_VARCHAR2_TABLE_4000
    , a258 JTF_VARCHAR2_TABLE_4000
    , a259 JTF_VARCHAR2_TABLE_4000
    , a260 JTF_VARCHAR2_TABLE_4000
    , a261 JTF_VARCHAR2_TABLE_4000
    , a262 JTF_VARCHAR2_TABLE_4000
    , a263 JTF_VARCHAR2_TABLE_4000
    , a264 JTF_VARCHAR2_TABLE_100
    , a265 JTF_NUMBER_TABLE
    , a266 JTF_VARCHAR2_TABLE_100
    , a267 JTF_VARCHAR2_TABLE_4000
    , a268 JTF_VARCHAR2_TABLE_2000
    , a269 JTF_VARCHAR2_TABLE_100
    , a270 JTF_VARCHAR2_TABLE_2000
    , a271 JTF_VARCHAR2_TABLE_2000
    , a272 JTF_VARCHAR2_TABLE_2000
    , a273 JTF_VARCHAR2_TABLE_2000
    , a274 JTF_VARCHAR2_TABLE_2000
    , a275 JTF_VARCHAR2_TABLE_2000
    , a276 JTF_VARCHAR2_TABLE_2000
    , a277 JTF_VARCHAR2_TABLE_2000
    , a278 JTF_VARCHAR2_TABLE_2000
    , a279 JTF_VARCHAR2_TABLE_2000
    , a280 JTF_VARCHAR2_TABLE_2000
    , a281 JTF_VARCHAR2_TABLE_2000
    , a282 JTF_VARCHAR2_TABLE_2000
    , a283 JTF_VARCHAR2_TABLE_2000
    , a284 JTF_VARCHAR2_TABLE_2000
    , a285 JTF_VARCHAR2_TABLE_2000
    , a286 JTF_VARCHAR2_TABLE_2000
    , a287 JTF_VARCHAR2_TABLE_2000
    , a288 JTF_VARCHAR2_TABLE_2000
    , a289 JTF_VARCHAR2_TABLE_2000
    , a290 JTF_VARCHAR2_TABLE_2000
    , a291 JTF_VARCHAR2_TABLE_2000
    , a292 JTF_VARCHAR2_TABLE_2000
    , a293 JTF_VARCHAR2_TABLE_2000
    , a294 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p3(t ams_is_line_pvt.is_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , a34 out nocopy JTF_VARCHAR2_TABLE_2000
    , a35 out nocopy JTF_VARCHAR2_TABLE_2000
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , a38 out nocopy JTF_VARCHAR2_TABLE_2000
    , a39 out nocopy JTF_VARCHAR2_TABLE_2000
    , a40 out nocopy JTF_VARCHAR2_TABLE_2000
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_VARCHAR2_TABLE_2000
    , a43 out nocopy JTF_VARCHAR2_TABLE_2000
    , a44 out nocopy JTF_VARCHAR2_TABLE_2000
    , a45 out nocopy JTF_VARCHAR2_TABLE_2000
    , a46 out nocopy JTF_VARCHAR2_TABLE_2000
    , a47 out nocopy JTF_VARCHAR2_TABLE_2000
    , a48 out nocopy JTF_VARCHAR2_TABLE_2000
    , a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_VARCHAR2_TABLE_2000
    , a54 out nocopy JTF_VARCHAR2_TABLE_2000
    , a55 out nocopy JTF_VARCHAR2_TABLE_2000
    , a56 out nocopy JTF_VARCHAR2_TABLE_2000
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_VARCHAR2_TABLE_2000
    , a59 out nocopy JTF_VARCHAR2_TABLE_2000
    , a60 out nocopy JTF_VARCHAR2_TABLE_2000
    , a61 out nocopy JTF_VARCHAR2_TABLE_2000
    , a62 out nocopy JTF_VARCHAR2_TABLE_2000
    , a63 out nocopy JTF_VARCHAR2_TABLE_2000
    , a64 out nocopy JTF_VARCHAR2_TABLE_2000
    , a65 out nocopy JTF_VARCHAR2_TABLE_2000
    , a66 out nocopy JTF_VARCHAR2_TABLE_2000
    , a67 out nocopy JTF_VARCHAR2_TABLE_2000
    , a68 out nocopy JTF_VARCHAR2_TABLE_2000
    , a69 out nocopy JTF_VARCHAR2_TABLE_2000
    , a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , a71 out nocopy JTF_VARCHAR2_TABLE_2000
    , a72 out nocopy JTF_VARCHAR2_TABLE_2000
    , a73 out nocopy JTF_VARCHAR2_TABLE_2000
    , a74 out nocopy JTF_VARCHAR2_TABLE_2000
    , a75 out nocopy JTF_VARCHAR2_TABLE_2000
    , a76 out nocopy JTF_VARCHAR2_TABLE_2000
    , a77 out nocopy JTF_VARCHAR2_TABLE_2000
    , a78 out nocopy JTF_VARCHAR2_TABLE_2000
    , a79 out nocopy JTF_VARCHAR2_TABLE_2000
    , a80 out nocopy JTF_VARCHAR2_TABLE_2000
    , a81 out nocopy JTF_VARCHAR2_TABLE_2000
    , a82 out nocopy JTF_VARCHAR2_TABLE_2000
    , a83 out nocopy JTF_VARCHAR2_TABLE_2000
    , a84 out nocopy JTF_VARCHAR2_TABLE_2000
    , a85 out nocopy JTF_VARCHAR2_TABLE_2000
    , a86 out nocopy JTF_VARCHAR2_TABLE_2000
    , a87 out nocopy JTF_VARCHAR2_TABLE_2000
    , a88 out nocopy JTF_VARCHAR2_TABLE_2000
    , a89 out nocopy JTF_VARCHAR2_TABLE_2000
    , a90 out nocopy JTF_VARCHAR2_TABLE_2000
    , a91 out nocopy JTF_VARCHAR2_TABLE_2000
    , a92 out nocopy JTF_VARCHAR2_TABLE_2000
    , a93 out nocopy JTF_VARCHAR2_TABLE_2000
    , a94 out nocopy JTF_VARCHAR2_TABLE_2000
    , a95 out nocopy JTF_VARCHAR2_TABLE_2000
    , a96 out nocopy JTF_VARCHAR2_TABLE_2000
    , a97 out nocopy JTF_VARCHAR2_TABLE_2000
    , a98 out nocopy JTF_VARCHAR2_TABLE_2000
    , a99 out nocopy JTF_VARCHAR2_TABLE_2000
    , a100 out nocopy JTF_VARCHAR2_TABLE_2000
    , a101 out nocopy JTF_VARCHAR2_TABLE_2000
    , a102 out nocopy JTF_VARCHAR2_TABLE_2000
    , a103 out nocopy JTF_VARCHAR2_TABLE_2000
    , a104 out nocopy JTF_VARCHAR2_TABLE_2000
    , a105 out nocopy JTF_VARCHAR2_TABLE_2000
    , a106 out nocopy JTF_VARCHAR2_TABLE_2000
    , a107 out nocopy JTF_VARCHAR2_TABLE_2000
    , a108 out nocopy JTF_VARCHAR2_TABLE_2000
    , a109 out nocopy JTF_VARCHAR2_TABLE_2000
    , a110 out nocopy JTF_VARCHAR2_TABLE_2000
    , a111 out nocopy JTF_VARCHAR2_TABLE_2000
    , a112 out nocopy JTF_VARCHAR2_TABLE_2000
    , a113 out nocopy JTF_VARCHAR2_TABLE_2000
    , a114 out nocopy JTF_VARCHAR2_TABLE_2000
    , a115 out nocopy JTF_VARCHAR2_TABLE_2000
    , a116 out nocopy JTF_VARCHAR2_TABLE_2000
    , a117 out nocopy JTF_VARCHAR2_TABLE_2000
    , a118 out nocopy JTF_VARCHAR2_TABLE_2000
    , a119 out nocopy JTF_VARCHAR2_TABLE_2000
    , a120 out nocopy JTF_VARCHAR2_TABLE_2000
    , a121 out nocopy JTF_VARCHAR2_TABLE_2000
    , a122 out nocopy JTF_VARCHAR2_TABLE_2000
    , a123 out nocopy JTF_VARCHAR2_TABLE_2000
    , a124 out nocopy JTF_VARCHAR2_TABLE_2000
    , a125 out nocopy JTF_VARCHAR2_TABLE_2000
    , a126 out nocopy JTF_VARCHAR2_TABLE_2000
    , a127 out nocopy JTF_VARCHAR2_TABLE_2000
    , a128 out nocopy JTF_VARCHAR2_TABLE_2000
    , a129 out nocopy JTF_VARCHAR2_TABLE_2000
    , a130 out nocopy JTF_VARCHAR2_TABLE_2000
    , a131 out nocopy JTF_VARCHAR2_TABLE_2000
    , a132 out nocopy JTF_VARCHAR2_TABLE_2000
    , a133 out nocopy JTF_VARCHAR2_TABLE_2000
    , a134 out nocopy JTF_VARCHAR2_TABLE_2000
    , a135 out nocopy JTF_VARCHAR2_TABLE_2000
    , a136 out nocopy JTF_VARCHAR2_TABLE_2000
    , a137 out nocopy JTF_VARCHAR2_TABLE_2000
    , a138 out nocopy JTF_VARCHAR2_TABLE_2000
    , a139 out nocopy JTF_VARCHAR2_TABLE_2000
    , a140 out nocopy JTF_VARCHAR2_TABLE_2000
    , a141 out nocopy JTF_VARCHAR2_TABLE_2000
    , a142 out nocopy JTF_VARCHAR2_TABLE_2000
    , a143 out nocopy JTF_VARCHAR2_TABLE_2000
    , a144 out nocopy JTF_VARCHAR2_TABLE_2000
    , a145 out nocopy JTF_VARCHAR2_TABLE_2000
    , a146 out nocopy JTF_VARCHAR2_TABLE_2000
    , a147 out nocopy JTF_VARCHAR2_TABLE_2000
    , a148 out nocopy JTF_VARCHAR2_TABLE_2000
    , a149 out nocopy JTF_VARCHAR2_TABLE_2000
    , a150 out nocopy JTF_VARCHAR2_TABLE_2000
    , a151 out nocopy JTF_VARCHAR2_TABLE_2000
    , a152 out nocopy JTF_VARCHAR2_TABLE_2000
    , a153 out nocopy JTF_VARCHAR2_TABLE_2000
    , a154 out nocopy JTF_VARCHAR2_TABLE_2000
    , a155 out nocopy JTF_VARCHAR2_TABLE_2000
    , a156 out nocopy JTF_VARCHAR2_TABLE_2000
    , a157 out nocopy JTF_VARCHAR2_TABLE_2000
    , a158 out nocopy JTF_VARCHAR2_TABLE_2000
    , a159 out nocopy JTF_VARCHAR2_TABLE_2000
    , a160 out nocopy JTF_VARCHAR2_TABLE_2000
    , a161 out nocopy JTF_VARCHAR2_TABLE_2000
    , a162 out nocopy JTF_VARCHAR2_TABLE_2000
    , a163 out nocopy JTF_VARCHAR2_TABLE_2000
    , a164 out nocopy JTF_VARCHAR2_TABLE_2000
    , a165 out nocopy JTF_VARCHAR2_TABLE_2000
    , a166 out nocopy JTF_VARCHAR2_TABLE_2000
    , a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , a168 out nocopy JTF_VARCHAR2_TABLE_2000
    , a169 out nocopy JTF_VARCHAR2_TABLE_2000
    , a170 out nocopy JTF_VARCHAR2_TABLE_2000
    , a171 out nocopy JTF_VARCHAR2_TABLE_2000
    , a172 out nocopy JTF_VARCHAR2_TABLE_2000
    , a173 out nocopy JTF_VARCHAR2_TABLE_2000
    , a174 out nocopy JTF_VARCHAR2_TABLE_2000
    , a175 out nocopy JTF_VARCHAR2_TABLE_2000
    , a176 out nocopy JTF_VARCHAR2_TABLE_2000
    , a177 out nocopy JTF_VARCHAR2_TABLE_2000
    , a178 out nocopy JTF_VARCHAR2_TABLE_2000
    , a179 out nocopy JTF_VARCHAR2_TABLE_2000
    , a180 out nocopy JTF_VARCHAR2_TABLE_2000
    , a181 out nocopy JTF_VARCHAR2_TABLE_2000
    , a182 out nocopy JTF_VARCHAR2_TABLE_2000
    , a183 out nocopy JTF_VARCHAR2_TABLE_2000
    , a184 out nocopy JTF_VARCHAR2_TABLE_2000
    , a185 out nocopy JTF_VARCHAR2_TABLE_2000
    , a186 out nocopy JTF_VARCHAR2_TABLE_2000
    , a187 out nocopy JTF_VARCHAR2_TABLE_2000
    , a188 out nocopy JTF_VARCHAR2_TABLE_2000
    , a189 out nocopy JTF_VARCHAR2_TABLE_2000
    , a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , a191 out nocopy JTF_VARCHAR2_TABLE_2000
    , a192 out nocopy JTF_VARCHAR2_TABLE_2000
    , a193 out nocopy JTF_VARCHAR2_TABLE_2000
    , a194 out nocopy JTF_VARCHAR2_TABLE_2000
    , a195 out nocopy JTF_VARCHAR2_TABLE_2000
    , a196 out nocopy JTF_VARCHAR2_TABLE_2000
    , a197 out nocopy JTF_VARCHAR2_TABLE_2000
    , a198 out nocopy JTF_VARCHAR2_TABLE_2000
    , a199 out nocopy JTF_VARCHAR2_TABLE_2000
    , a200 out nocopy JTF_VARCHAR2_TABLE_2000
    , a201 out nocopy JTF_VARCHAR2_TABLE_2000
    , a202 out nocopy JTF_VARCHAR2_TABLE_2000
    , a203 out nocopy JTF_VARCHAR2_TABLE_2000
    , a204 out nocopy JTF_VARCHAR2_TABLE_2000
    , a205 out nocopy JTF_VARCHAR2_TABLE_2000
    , a206 out nocopy JTF_VARCHAR2_TABLE_2000
    , a207 out nocopy JTF_VARCHAR2_TABLE_2000
    , a208 out nocopy JTF_VARCHAR2_TABLE_2000
    , a209 out nocopy JTF_VARCHAR2_TABLE_2000
    , a210 out nocopy JTF_VARCHAR2_TABLE_2000
    , a211 out nocopy JTF_VARCHAR2_TABLE_2000
    , a212 out nocopy JTF_VARCHAR2_TABLE_2000
    , a213 out nocopy JTF_VARCHAR2_TABLE_2000
    , a214 out nocopy JTF_VARCHAR2_TABLE_2000
    , a215 out nocopy JTF_VARCHAR2_TABLE_2000
    , a216 out nocopy JTF_VARCHAR2_TABLE_2000
    , a217 out nocopy JTF_VARCHAR2_TABLE_2000
    , a218 out nocopy JTF_VARCHAR2_TABLE_2000
    , a219 out nocopy JTF_VARCHAR2_TABLE_2000
    , a220 out nocopy JTF_VARCHAR2_TABLE_2000
    , a221 out nocopy JTF_VARCHAR2_TABLE_2000
    , a222 out nocopy JTF_VARCHAR2_TABLE_2000
    , a223 out nocopy JTF_VARCHAR2_TABLE_2000
    , a224 out nocopy JTF_VARCHAR2_TABLE_2000
    , a225 out nocopy JTF_VARCHAR2_TABLE_2000
    , a226 out nocopy JTF_VARCHAR2_TABLE_2000
    , a227 out nocopy JTF_VARCHAR2_TABLE_2000
    , a228 out nocopy JTF_VARCHAR2_TABLE_2000
    , a229 out nocopy JTF_VARCHAR2_TABLE_2000
    , a230 out nocopy JTF_VARCHAR2_TABLE_2000
    , a231 out nocopy JTF_VARCHAR2_TABLE_2000
    , a232 out nocopy JTF_VARCHAR2_TABLE_2000
    , a233 out nocopy JTF_VARCHAR2_TABLE_2000
    , a234 out nocopy JTF_VARCHAR2_TABLE_2000
    , a235 out nocopy JTF_VARCHAR2_TABLE_2000
    , a236 out nocopy JTF_VARCHAR2_TABLE_2000
    , a237 out nocopy JTF_VARCHAR2_TABLE_2000
    , a238 out nocopy JTF_VARCHAR2_TABLE_2000
    , a239 out nocopy JTF_VARCHAR2_TABLE_2000
    , a240 out nocopy JTF_VARCHAR2_TABLE_2000
    , a241 out nocopy JTF_VARCHAR2_TABLE_2000
    , a242 out nocopy JTF_VARCHAR2_TABLE_2000
    , a243 out nocopy JTF_VARCHAR2_TABLE_2000
    , a244 out nocopy JTF_VARCHAR2_TABLE_2000
    , a245 out nocopy JTF_VARCHAR2_TABLE_2000
    , a246 out nocopy JTF_VARCHAR2_TABLE_2000
    , a247 out nocopy JTF_VARCHAR2_TABLE_2000
    , a248 out nocopy JTF_VARCHAR2_TABLE_2000
    , a249 out nocopy JTF_VARCHAR2_TABLE_2000
    , a250 out nocopy JTF_VARCHAR2_TABLE_2000
    , a251 out nocopy JTF_VARCHAR2_TABLE_2000
    , a252 out nocopy JTF_VARCHAR2_TABLE_2000
    , a253 out nocopy JTF_VARCHAR2_TABLE_2000
    , a254 out nocopy JTF_VARCHAR2_TABLE_4000
    , a255 out nocopy JTF_VARCHAR2_TABLE_4000
    , a256 out nocopy JTF_VARCHAR2_TABLE_4000
    , a257 out nocopy JTF_VARCHAR2_TABLE_4000
    , a258 out nocopy JTF_VARCHAR2_TABLE_4000
    , a259 out nocopy JTF_VARCHAR2_TABLE_4000
    , a260 out nocopy JTF_VARCHAR2_TABLE_4000
    , a261 out nocopy JTF_VARCHAR2_TABLE_4000
    , a262 out nocopy JTF_VARCHAR2_TABLE_4000
    , a263 out nocopy JTF_VARCHAR2_TABLE_4000
    , a264 out nocopy JTF_VARCHAR2_TABLE_100
    , a265 out nocopy JTF_NUMBER_TABLE
    , a266 out nocopy JTF_VARCHAR2_TABLE_100
    , a267 out nocopy JTF_VARCHAR2_TABLE_4000
    , a268 out nocopy JTF_VARCHAR2_TABLE_2000
    , a269 out nocopy JTF_VARCHAR2_TABLE_100
    , a270 out nocopy JTF_VARCHAR2_TABLE_2000
    , a271 out nocopy JTF_VARCHAR2_TABLE_2000
    , a272 out nocopy JTF_VARCHAR2_TABLE_2000
    , a273 out nocopy JTF_VARCHAR2_TABLE_2000
    , a274 out nocopy JTF_VARCHAR2_TABLE_2000
    , a275 out nocopy JTF_VARCHAR2_TABLE_2000
    , a276 out nocopy JTF_VARCHAR2_TABLE_2000
    , a277 out nocopy JTF_VARCHAR2_TABLE_2000
    , a278 out nocopy JTF_VARCHAR2_TABLE_2000
    , a279 out nocopy JTF_VARCHAR2_TABLE_2000
    , a280 out nocopy JTF_VARCHAR2_TABLE_2000
    , a281 out nocopy JTF_VARCHAR2_TABLE_2000
    , a282 out nocopy JTF_VARCHAR2_TABLE_2000
    , a283 out nocopy JTF_VARCHAR2_TABLE_2000
    , a284 out nocopy JTF_VARCHAR2_TABLE_2000
    , a285 out nocopy JTF_VARCHAR2_TABLE_2000
    , a286 out nocopy JTF_VARCHAR2_TABLE_2000
    , a287 out nocopy JTF_VARCHAR2_TABLE_2000
    , a288 out nocopy JTF_VARCHAR2_TABLE_2000
    , a289 out nocopy JTF_VARCHAR2_TABLE_2000
    , a290 out nocopy JTF_VARCHAR2_TABLE_2000
    , a291 out nocopy JTF_VARCHAR2_TABLE_2000
    , a292 out nocopy JTF_VARCHAR2_TABLE_2000
    , a293 out nocopy JTF_VARCHAR2_TABLE_2000
    , a294 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure create_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_import_source_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  NUMBER := 0-1962.0724
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  NUMBER := 0-1962.0724
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  VARCHAR2 := fnd_api.g_miss_char
    , p3_a34  VARCHAR2 := fnd_api.g_miss_char
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  VARCHAR2 := fnd_api.g_miss_char
    , p3_a37  VARCHAR2 := fnd_api.g_miss_char
    , p3_a38  VARCHAR2 := fnd_api.g_miss_char
    , p3_a39  VARCHAR2 := fnd_api.g_miss_char
    , p3_a40  VARCHAR2 := fnd_api.g_miss_char
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
    , p3_a42  VARCHAR2 := fnd_api.g_miss_char
    , p3_a43  VARCHAR2 := fnd_api.g_miss_char
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
    , p3_a64  VARCHAR2 := fnd_api.g_miss_char
    , p3_a65  VARCHAR2 := fnd_api.g_miss_char
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  VARCHAR2 := fnd_api.g_miss_char
    , p3_a68  VARCHAR2 := fnd_api.g_miss_char
    , p3_a69  VARCHAR2 := fnd_api.g_miss_char
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
    , p3_a71  VARCHAR2 := fnd_api.g_miss_char
    , p3_a72  VARCHAR2 := fnd_api.g_miss_char
    , p3_a73  VARCHAR2 := fnd_api.g_miss_char
    , p3_a74  VARCHAR2 := fnd_api.g_miss_char
    , p3_a75  VARCHAR2 := fnd_api.g_miss_char
    , p3_a76  VARCHAR2 := fnd_api.g_miss_char
    , p3_a77  VARCHAR2 := fnd_api.g_miss_char
    , p3_a78  VARCHAR2 := fnd_api.g_miss_char
    , p3_a79  VARCHAR2 := fnd_api.g_miss_char
    , p3_a80  VARCHAR2 := fnd_api.g_miss_char
    , p3_a81  VARCHAR2 := fnd_api.g_miss_char
    , p3_a82  VARCHAR2 := fnd_api.g_miss_char
    , p3_a83  VARCHAR2 := fnd_api.g_miss_char
    , p3_a84  VARCHAR2 := fnd_api.g_miss_char
    , p3_a85  VARCHAR2 := fnd_api.g_miss_char
    , p3_a86  VARCHAR2 := fnd_api.g_miss_char
    , p3_a87  VARCHAR2 := fnd_api.g_miss_char
    , p3_a88  VARCHAR2 := fnd_api.g_miss_char
    , p3_a89  VARCHAR2 := fnd_api.g_miss_char
    , p3_a90  VARCHAR2 := fnd_api.g_miss_char
    , p3_a91  VARCHAR2 := fnd_api.g_miss_char
    , p3_a92  VARCHAR2 := fnd_api.g_miss_char
    , p3_a93  VARCHAR2 := fnd_api.g_miss_char
    , p3_a94  VARCHAR2 := fnd_api.g_miss_char
    , p3_a95  VARCHAR2 := fnd_api.g_miss_char
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
    , p3_a111  VARCHAR2 := fnd_api.g_miss_char
    , p3_a112  VARCHAR2 := fnd_api.g_miss_char
    , p3_a113  VARCHAR2 := fnd_api.g_miss_char
    , p3_a114  VARCHAR2 := fnd_api.g_miss_char
    , p3_a115  VARCHAR2 := fnd_api.g_miss_char
    , p3_a116  VARCHAR2 := fnd_api.g_miss_char
    , p3_a117  VARCHAR2 := fnd_api.g_miss_char
    , p3_a118  VARCHAR2 := fnd_api.g_miss_char
    , p3_a119  VARCHAR2 := fnd_api.g_miss_char
    , p3_a120  VARCHAR2 := fnd_api.g_miss_char
    , p3_a121  VARCHAR2 := fnd_api.g_miss_char
    , p3_a122  VARCHAR2 := fnd_api.g_miss_char
    , p3_a123  VARCHAR2 := fnd_api.g_miss_char
    , p3_a124  VARCHAR2 := fnd_api.g_miss_char
    , p3_a125  VARCHAR2 := fnd_api.g_miss_char
    , p3_a126  VARCHAR2 := fnd_api.g_miss_char
    , p3_a127  VARCHAR2 := fnd_api.g_miss_char
    , p3_a128  VARCHAR2 := fnd_api.g_miss_char
    , p3_a129  VARCHAR2 := fnd_api.g_miss_char
    , p3_a130  VARCHAR2 := fnd_api.g_miss_char
    , p3_a131  VARCHAR2 := fnd_api.g_miss_char
    , p3_a132  VARCHAR2 := fnd_api.g_miss_char
    , p3_a133  VARCHAR2 := fnd_api.g_miss_char
    , p3_a134  VARCHAR2 := fnd_api.g_miss_char
    , p3_a135  VARCHAR2 := fnd_api.g_miss_char
    , p3_a136  VARCHAR2 := fnd_api.g_miss_char
    , p3_a137  VARCHAR2 := fnd_api.g_miss_char
    , p3_a138  VARCHAR2 := fnd_api.g_miss_char
    , p3_a139  VARCHAR2 := fnd_api.g_miss_char
    , p3_a140  VARCHAR2 := fnd_api.g_miss_char
    , p3_a141  VARCHAR2 := fnd_api.g_miss_char
    , p3_a142  VARCHAR2 := fnd_api.g_miss_char
    , p3_a143  VARCHAR2 := fnd_api.g_miss_char
    , p3_a144  VARCHAR2 := fnd_api.g_miss_char
    , p3_a145  VARCHAR2 := fnd_api.g_miss_char
    , p3_a146  VARCHAR2 := fnd_api.g_miss_char
    , p3_a147  VARCHAR2 := fnd_api.g_miss_char
    , p3_a148  VARCHAR2 := fnd_api.g_miss_char
    , p3_a149  VARCHAR2 := fnd_api.g_miss_char
    , p3_a150  VARCHAR2 := fnd_api.g_miss_char
    , p3_a151  VARCHAR2 := fnd_api.g_miss_char
    , p3_a152  VARCHAR2 := fnd_api.g_miss_char
    , p3_a153  VARCHAR2 := fnd_api.g_miss_char
    , p3_a154  VARCHAR2 := fnd_api.g_miss_char
    , p3_a155  VARCHAR2 := fnd_api.g_miss_char
    , p3_a156  VARCHAR2 := fnd_api.g_miss_char
    , p3_a157  VARCHAR2 := fnd_api.g_miss_char
    , p3_a158  VARCHAR2 := fnd_api.g_miss_char
    , p3_a159  VARCHAR2 := fnd_api.g_miss_char
    , p3_a160  VARCHAR2 := fnd_api.g_miss_char
    , p3_a161  VARCHAR2 := fnd_api.g_miss_char
    , p3_a162  VARCHAR2 := fnd_api.g_miss_char
    , p3_a163  VARCHAR2 := fnd_api.g_miss_char
    , p3_a164  VARCHAR2 := fnd_api.g_miss_char
    , p3_a165  VARCHAR2 := fnd_api.g_miss_char
    , p3_a166  VARCHAR2 := fnd_api.g_miss_char
    , p3_a167  VARCHAR2 := fnd_api.g_miss_char
    , p3_a168  VARCHAR2 := fnd_api.g_miss_char
    , p3_a169  VARCHAR2 := fnd_api.g_miss_char
    , p3_a170  VARCHAR2 := fnd_api.g_miss_char
    , p3_a171  VARCHAR2 := fnd_api.g_miss_char
    , p3_a172  VARCHAR2 := fnd_api.g_miss_char
    , p3_a173  VARCHAR2 := fnd_api.g_miss_char
    , p3_a174  VARCHAR2 := fnd_api.g_miss_char
    , p3_a175  VARCHAR2 := fnd_api.g_miss_char
    , p3_a176  VARCHAR2 := fnd_api.g_miss_char
    , p3_a177  VARCHAR2 := fnd_api.g_miss_char
    , p3_a178  VARCHAR2 := fnd_api.g_miss_char
    , p3_a179  VARCHAR2 := fnd_api.g_miss_char
    , p3_a180  VARCHAR2 := fnd_api.g_miss_char
    , p3_a181  VARCHAR2 := fnd_api.g_miss_char
    , p3_a182  VARCHAR2 := fnd_api.g_miss_char
    , p3_a183  VARCHAR2 := fnd_api.g_miss_char
    , p3_a184  VARCHAR2 := fnd_api.g_miss_char
    , p3_a185  VARCHAR2 := fnd_api.g_miss_char
    , p3_a186  VARCHAR2 := fnd_api.g_miss_char
    , p3_a187  VARCHAR2 := fnd_api.g_miss_char
    , p3_a188  VARCHAR2 := fnd_api.g_miss_char
    , p3_a189  VARCHAR2 := fnd_api.g_miss_char
    , p3_a190  VARCHAR2 := fnd_api.g_miss_char
    , p3_a191  VARCHAR2 := fnd_api.g_miss_char
    , p3_a192  VARCHAR2 := fnd_api.g_miss_char
    , p3_a193  VARCHAR2 := fnd_api.g_miss_char
    , p3_a194  VARCHAR2 := fnd_api.g_miss_char
    , p3_a195  VARCHAR2 := fnd_api.g_miss_char
    , p3_a196  VARCHAR2 := fnd_api.g_miss_char
    , p3_a197  VARCHAR2 := fnd_api.g_miss_char
    , p3_a198  VARCHAR2 := fnd_api.g_miss_char
    , p3_a199  VARCHAR2 := fnd_api.g_miss_char
    , p3_a200  VARCHAR2 := fnd_api.g_miss_char
    , p3_a201  VARCHAR2 := fnd_api.g_miss_char
    , p3_a202  VARCHAR2 := fnd_api.g_miss_char
    , p3_a203  VARCHAR2 := fnd_api.g_miss_char
    , p3_a204  VARCHAR2 := fnd_api.g_miss_char
    , p3_a205  VARCHAR2 := fnd_api.g_miss_char
    , p3_a206  VARCHAR2 := fnd_api.g_miss_char
    , p3_a207  VARCHAR2 := fnd_api.g_miss_char
    , p3_a208  VARCHAR2 := fnd_api.g_miss_char
    , p3_a209  VARCHAR2 := fnd_api.g_miss_char
    , p3_a210  VARCHAR2 := fnd_api.g_miss_char
    , p3_a211  VARCHAR2 := fnd_api.g_miss_char
    , p3_a212  VARCHAR2 := fnd_api.g_miss_char
    , p3_a213  VARCHAR2 := fnd_api.g_miss_char
    , p3_a214  VARCHAR2 := fnd_api.g_miss_char
    , p3_a215  VARCHAR2 := fnd_api.g_miss_char
    , p3_a216  VARCHAR2 := fnd_api.g_miss_char
    , p3_a217  VARCHAR2 := fnd_api.g_miss_char
    , p3_a218  VARCHAR2 := fnd_api.g_miss_char
    , p3_a219  VARCHAR2 := fnd_api.g_miss_char
    , p3_a220  VARCHAR2 := fnd_api.g_miss_char
    , p3_a221  VARCHAR2 := fnd_api.g_miss_char
    , p3_a222  VARCHAR2 := fnd_api.g_miss_char
    , p3_a223  VARCHAR2 := fnd_api.g_miss_char
    , p3_a224  VARCHAR2 := fnd_api.g_miss_char
    , p3_a225  VARCHAR2 := fnd_api.g_miss_char
    , p3_a226  VARCHAR2 := fnd_api.g_miss_char
    , p3_a227  VARCHAR2 := fnd_api.g_miss_char
    , p3_a228  VARCHAR2 := fnd_api.g_miss_char
    , p3_a229  VARCHAR2 := fnd_api.g_miss_char
    , p3_a230  VARCHAR2 := fnd_api.g_miss_char
    , p3_a231  VARCHAR2 := fnd_api.g_miss_char
    , p3_a232  VARCHAR2 := fnd_api.g_miss_char
    , p3_a233  VARCHAR2 := fnd_api.g_miss_char
    , p3_a234  VARCHAR2 := fnd_api.g_miss_char
    , p3_a235  VARCHAR2 := fnd_api.g_miss_char
    , p3_a236  VARCHAR2 := fnd_api.g_miss_char
    , p3_a237  VARCHAR2 := fnd_api.g_miss_char
    , p3_a238  VARCHAR2 := fnd_api.g_miss_char
    , p3_a239  VARCHAR2 := fnd_api.g_miss_char
    , p3_a240  VARCHAR2 := fnd_api.g_miss_char
    , p3_a241  VARCHAR2 := fnd_api.g_miss_char
    , p3_a242  VARCHAR2 := fnd_api.g_miss_char
    , p3_a243  VARCHAR2 := fnd_api.g_miss_char
    , p3_a244  VARCHAR2 := fnd_api.g_miss_char
    , p3_a245  VARCHAR2 := fnd_api.g_miss_char
    , p3_a246  VARCHAR2 := fnd_api.g_miss_char
    , p3_a247  VARCHAR2 := fnd_api.g_miss_char
    , p3_a248  VARCHAR2 := fnd_api.g_miss_char
    , p3_a249  VARCHAR2 := fnd_api.g_miss_char
    , p3_a250  VARCHAR2 := fnd_api.g_miss_char
    , p3_a251  VARCHAR2 := fnd_api.g_miss_char
    , p3_a252  VARCHAR2 := fnd_api.g_miss_char
    , p3_a253  VARCHAR2 := fnd_api.g_miss_char
    , p3_a254  VARCHAR2 := fnd_api.g_miss_char
    , p3_a255  VARCHAR2 := fnd_api.g_miss_char
    , p3_a256  VARCHAR2 := fnd_api.g_miss_char
    , p3_a257  VARCHAR2 := fnd_api.g_miss_char
    , p3_a258  VARCHAR2 := fnd_api.g_miss_char
    , p3_a259  VARCHAR2 := fnd_api.g_miss_char
    , p3_a260  VARCHAR2 := fnd_api.g_miss_char
    , p3_a261  VARCHAR2 := fnd_api.g_miss_char
    , p3_a262  VARCHAR2 := fnd_api.g_miss_char
    , p3_a263  VARCHAR2 := fnd_api.g_miss_char
    , p3_a264  VARCHAR2 := fnd_api.g_miss_char
    , p3_a265  NUMBER := 0-1962.0724
    , p3_a266  VARCHAR2 := fnd_api.g_miss_char
    , p3_a267  VARCHAR2 := fnd_api.g_miss_char
    , p3_a268  VARCHAR2 := fnd_api.g_miss_char
    , p3_a269  VARCHAR2 := fnd_api.g_miss_char
    , p3_a270  VARCHAR2 := fnd_api.g_miss_char
    , p3_a271  VARCHAR2 := fnd_api.g_miss_char
    , p3_a272  VARCHAR2 := fnd_api.g_miss_char
    , p3_a273  VARCHAR2 := fnd_api.g_miss_char
    , p3_a274  VARCHAR2 := fnd_api.g_miss_char
    , p3_a275  VARCHAR2 := fnd_api.g_miss_char
    , p3_a276  VARCHAR2 := fnd_api.g_miss_char
    , p3_a277  VARCHAR2 := fnd_api.g_miss_char
    , p3_a278  VARCHAR2 := fnd_api.g_miss_char
    , p3_a279  VARCHAR2 := fnd_api.g_miss_char
    , p3_a280  VARCHAR2 := fnd_api.g_miss_char
    , p3_a281  VARCHAR2 := fnd_api.g_miss_char
    , p3_a282  VARCHAR2 := fnd_api.g_miss_char
    , p3_a283  VARCHAR2 := fnd_api.g_miss_char
    , p3_a284  VARCHAR2 := fnd_api.g_miss_char
    , p3_a285  VARCHAR2 := fnd_api.g_miss_char
    , p3_a286  VARCHAR2 := fnd_api.g_miss_char
    , p3_a287  VARCHAR2 := fnd_api.g_miss_char
    , p3_a288  VARCHAR2 := fnd_api.g_miss_char
    , p3_a289  VARCHAR2 := fnd_api.g_miss_char
    , p3_a290  VARCHAR2 := fnd_api.g_miss_char
    , p3_a291  VARCHAR2 := fnd_api.g_miss_char
    , p3_a292  VARCHAR2 := fnd_api.g_miss_char
    , p3_a293  VARCHAR2 := fnd_api.g_miss_char
    , p3_a294  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure check_is_line_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
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
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  VARCHAR2 := fnd_api.g_miss_char
    , p0_a84  VARCHAR2 := fnd_api.g_miss_char
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
    , p0_a88  VARCHAR2 := fnd_api.g_miss_char
    , p0_a89  VARCHAR2 := fnd_api.g_miss_char
    , p0_a90  VARCHAR2 := fnd_api.g_miss_char
    , p0_a91  VARCHAR2 := fnd_api.g_miss_char
    , p0_a92  VARCHAR2 := fnd_api.g_miss_char
    , p0_a93  VARCHAR2 := fnd_api.g_miss_char
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  VARCHAR2 := fnd_api.g_miss_char
    , p0_a96  VARCHAR2 := fnd_api.g_miss_char
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  VARCHAR2 := fnd_api.g_miss_char
    , p0_a99  VARCHAR2 := fnd_api.g_miss_char
    , p0_a100  VARCHAR2 := fnd_api.g_miss_char
    , p0_a101  VARCHAR2 := fnd_api.g_miss_char
    , p0_a102  VARCHAR2 := fnd_api.g_miss_char
    , p0_a103  VARCHAR2 := fnd_api.g_miss_char
    , p0_a104  VARCHAR2 := fnd_api.g_miss_char
    , p0_a105  VARCHAR2 := fnd_api.g_miss_char
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  VARCHAR2 := fnd_api.g_miss_char
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p0_a109  VARCHAR2 := fnd_api.g_miss_char
    , p0_a110  VARCHAR2 := fnd_api.g_miss_char
    , p0_a111  VARCHAR2 := fnd_api.g_miss_char
    , p0_a112  VARCHAR2 := fnd_api.g_miss_char
    , p0_a113  VARCHAR2 := fnd_api.g_miss_char
    , p0_a114  VARCHAR2 := fnd_api.g_miss_char
    , p0_a115  VARCHAR2 := fnd_api.g_miss_char
    , p0_a116  VARCHAR2 := fnd_api.g_miss_char
    , p0_a117  VARCHAR2 := fnd_api.g_miss_char
    , p0_a118  VARCHAR2 := fnd_api.g_miss_char
    , p0_a119  VARCHAR2 := fnd_api.g_miss_char
    , p0_a120  VARCHAR2 := fnd_api.g_miss_char
    , p0_a121  VARCHAR2 := fnd_api.g_miss_char
    , p0_a122  VARCHAR2 := fnd_api.g_miss_char
    , p0_a123  VARCHAR2 := fnd_api.g_miss_char
    , p0_a124  VARCHAR2 := fnd_api.g_miss_char
    , p0_a125  VARCHAR2 := fnd_api.g_miss_char
    , p0_a126  VARCHAR2 := fnd_api.g_miss_char
    , p0_a127  VARCHAR2 := fnd_api.g_miss_char
    , p0_a128  VARCHAR2 := fnd_api.g_miss_char
    , p0_a129  VARCHAR2 := fnd_api.g_miss_char
    , p0_a130  VARCHAR2 := fnd_api.g_miss_char
    , p0_a131  VARCHAR2 := fnd_api.g_miss_char
    , p0_a132  VARCHAR2 := fnd_api.g_miss_char
    , p0_a133  VARCHAR2 := fnd_api.g_miss_char
    , p0_a134  VARCHAR2 := fnd_api.g_miss_char
    , p0_a135  VARCHAR2 := fnd_api.g_miss_char
    , p0_a136  VARCHAR2 := fnd_api.g_miss_char
    , p0_a137  VARCHAR2 := fnd_api.g_miss_char
    , p0_a138  VARCHAR2 := fnd_api.g_miss_char
    , p0_a139  VARCHAR2 := fnd_api.g_miss_char
    , p0_a140  VARCHAR2 := fnd_api.g_miss_char
    , p0_a141  VARCHAR2 := fnd_api.g_miss_char
    , p0_a142  VARCHAR2 := fnd_api.g_miss_char
    , p0_a143  VARCHAR2 := fnd_api.g_miss_char
    , p0_a144  VARCHAR2 := fnd_api.g_miss_char
    , p0_a145  VARCHAR2 := fnd_api.g_miss_char
    , p0_a146  VARCHAR2 := fnd_api.g_miss_char
    , p0_a147  VARCHAR2 := fnd_api.g_miss_char
    , p0_a148  VARCHAR2 := fnd_api.g_miss_char
    , p0_a149  VARCHAR2 := fnd_api.g_miss_char
    , p0_a150  VARCHAR2 := fnd_api.g_miss_char
    , p0_a151  VARCHAR2 := fnd_api.g_miss_char
    , p0_a152  VARCHAR2 := fnd_api.g_miss_char
    , p0_a153  VARCHAR2 := fnd_api.g_miss_char
    , p0_a154  VARCHAR2 := fnd_api.g_miss_char
    , p0_a155  VARCHAR2 := fnd_api.g_miss_char
    , p0_a156  VARCHAR2 := fnd_api.g_miss_char
    , p0_a157  VARCHAR2 := fnd_api.g_miss_char
    , p0_a158  VARCHAR2 := fnd_api.g_miss_char
    , p0_a159  VARCHAR2 := fnd_api.g_miss_char
    , p0_a160  VARCHAR2 := fnd_api.g_miss_char
    , p0_a161  VARCHAR2 := fnd_api.g_miss_char
    , p0_a162  VARCHAR2 := fnd_api.g_miss_char
    , p0_a163  VARCHAR2 := fnd_api.g_miss_char
    , p0_a164  VARCHAR2 := fnd_api.g_miss_char
    , p0_a165  VARCHAR2 := fnd_api.g_miss_char
    , p0_a166  VARCHAR2 := fnd_api.g_miss_char
    , p0_a167  VARCHAR2 := fnd_api.g_miss_char
    , p0_a168  VARCHAR2 := fnd_api.g_miss_char
    , p0_a169  VARCHAR2 := fnd_api.g_miss_char
    , p0_a170  VARCHAR2 := fnd_api.g_miss_char
    , p0_a171  VARCHAR2 := fnd_api.g_miss_char
    , p0_a172  VARCHAR2 := fnd_api.g_miss_char
    , p0_a173  VARCHAR2 := fnd_api.g_miss_char
    , p0_a174  VARCHAR2 := fnd_api.g_miss_char
    , p0_a175  VARCHAR2 := fnd_api.g_miss_char
    , p0_a176  VARCHAR2 := fnd_api.g_miss_char
    , p0_a177  VARCHAR2 := fnd_api.g_miss_char
    , p0_a178  VARCHAR2 := fnd_api.g_miss_char
    , p0_a179  VARCHAR2 := fnd_api.g_miss_char
    , p0_a180  VARCHAR2 := fnd_api.g_miss_char
    , p0_a181  VARCHAR2 := fnd_api.g_miss_char
    , p0_a182  VARCHAR2 := fnd_api.g_miss_char
    , p0_a183  VARCHAR2 := fnd_api.g_miss_char
    , p0_a184  VARCHAR2 := fnd_api.g_miss_char
    , p0_a185  VARCHAR2 := fnd_api.g_miss_char
    , p0_a186  VARCHAR2 := fnd_api.g_miss_char
    , p0_a187  VARCHAR2 := fnd_api.g_miss_char
    , p0_a188  VARCHAR2 := fnd_api.g_miss_char
    , p0_a189  VARCHAR2 := fnd_api.g_miss_char
    , p0_a190  VARCHAR2 := fnd_api.g_miss_char
    , p0_a191  VARCHAR2 := fnd_api.g_miss_char
    , p0_a192  VARCHAR2 := fnd_api.g_miss_char
    , p0_a193  VARCHAR2 := fnd_api.g_miss_char
    , p0_a194  VARCHAR2 := fnd_api.g_miss_char
    , p0_a195  VARCHAR2 := fnd_api.g_miss_char
    , p0_a196  VARCHAR2 := fnd_api.g_miss_char
    , p0_a197  VARCHAR2 := fnd_api.g_miss_char
    , p0_a198  VARCHAR2 := fnd_api.g_miss_char
    , p0_a199  VARCHAR2 := fnd_api.g_miss_char
    , p0_a200  VARCHAR2 := fnd_api.g_miss_char
    , p0_a201  VARCHAR2 := fnd_api.g_miss_char
    , p0_a202  VARCHAR2 := fnd_api.g_miss_char
    , p0_a203  VARCHAR2 := fnd_api.g_miss_char
    , p0_a204  VARCHAR2 := fnd_api.g_miss_char
    , p0_a205  VARCHAR2 := fnd_api.g_miss_char
    , p0_a206  VARCHAR2 := fnd_api.g_miss_char
    , p0_a207  VARCHAR2 := fnd_api.g_miss_char
    , p0_a208  VARCHAR2 := fnd_api.g_miss_char
    , p0_a209  VARCHAR2 := fnd_api.g_miss_char
    , p0_a210  VARCHAR2 := fnd_api.g_miss_char
    , p0_a211  VARCHAR2 := fnd_api.g_miss_char
    , p0_a212  VARCHAR2 := fnd_api.g_miss_char
    , p0_a213  VARCHAR2 := fnd_api.g_miss_char
    , p0_a214  VARCHAR2 := fnd_api.g_miss_char
    , p0_a215  VARCHAR2 := fnd_api.g_miss_char
    , p0_a216  VARCHAR2 := fnd_api.g_miss_char
    , p0_a217  VARCHAR2 := fnd_api.g_miss_char
    , p0_a218  VARCHAR2 := fnd_api.g_miss_char
    , p0_a219  VARCHAR2 := fnd_api.g_miss_char
    , p0_a220  VARCHAR2 := fnd_api.g_miss_char
    , p0_a221  VARCHAR2 := fnd_api.g_miss_char
    , p0_a222  VARCHAR2 := fnd_api.g_miss_char
    , p0_a223  VARCHAR2 := fnd_api.g_miss_char
    , p0_a224  VARCHAR2 := fnd_api.g_miss_char
    , p0_a225  VARCHAR2 := fnd_api.g_miss_char
    , p0_a226  VARCHAR2 := fnd_api.g_miss_char
    , p0_a227  VARCHAR2 := fnd_api.g_miss_char
    , p0_a228  VARCHAR2 := fnd_api.g_miss_char
    , p0_a229  VARCHAR2 := fnd_api.g_miss_char
    , p0_a230  VARCHAR2 := fnd_api.g_miss_char
    , p0_a231  VARCHAR2 := fnd_api.g_miss_char
    , p0_a232  VARCHAR2 := fnd_api.g_miss_char
    , p0_a233  VARCHAR2 := fnd_api.g_miss_char
    , p0_a234  VARCHAR2 := fnd_api.g_miss_char
    , p0_a235  VARCHAR2 := fnd_api.g_miss_char
    , p0_a236  VARCHAR2 := fnd_api.g_miss_char
    , p0_a237  VARCHAR2 := fnd_api.g_miss_char
    , p0_a238  VARCHAR2 := fnd_api.g_miss_char
    , p0_a239  VARCHAR2 := fnd_api.g_miss_char
    , p0_a240  VARCHAR2 := fnd_api.g_miss_char
    , p0_a241  VARCHAR2 := fnd_api.g_miss_char
    , p0_a242  VARCHAR2 := fnd_api.g_miss_char
    , p0_a243  VARCHAR2 := fnd_api.g_miss_char
    , p0_a244  VARCHAR2 := fnd_api.g_miss_char
    , p0_a245  VARCHAR2 := fnd_api.g_miss_char
    , p0_a246  VARCHAR2 := fnd_api.g_miss_char
    , p0_a247  VARCHAR2 := fnd_api.g_miss_char
    , p0_a248  VARCHAR2 := fnd_api.g_miss_char
    , p0_a249  VARCHAR2 := fnd_api.g_miss_char
    , p0_a250  VARCHAR2 := fnd_api.g_miss_char
    , p0_a251  VARCHAR2 := fnd_api.g_miss_char
    , p0_a252  VARCHAR2 := fnd_api.g_miss_char
    , p0_a253  VARCHAR2 := fnd_api.g_miss_char
    , p0_a254  VARCHAR2 := fnd_api.g_miss_char
    , p0_a255  VARCHAR2 := fnd_api.g_miss_char
    , p0_a256  VARCHAR2 := fnd_api.g_miss_char
    , p0_a257  VARCHAR2 := fnd_api.g_miss_char
    , p0_a258  VARCHAR2 := fnd_api.g_miss_char
    , p0_a259  VARCHAR2 := fnd_api.g_miss_char
    , p0_a260  VARCHAR2 := fnd_api.g_miss_char
    , p0_a261  VARCHAR2 := fnd_api.g_miss_char
    , p0_a262  VARCHAR2 := fnd_api.g_miss_char
    , p0_a263  VARCHAR2 := fnd_api.g_miss_char
    , p0_a264  VARCHAR2 := fnd_api.g_miss_char
    , p0_a265  NUMBER := 0-1962.0724
    , p0_a266  VARCHAR2 := fnd_api.g_miss_char
    , p0_a267  VARCHAR2 := fnd_api.g_miss_char
    , p0_a268  VARCHAR2 := fnd_api.g_miss_char
    , p0_a269  VARCHAR2 := fnd_api.g_miss_char
    , p0_a270  VARCHAR2 := fnd_api.g_miss_char
    , p0_a271  VARCHAR2 := fnd_api.g_miss_char
    , p0_a272  VARCHAR2 := fnd_api.g_miss_char
    , p0_a273  VARCHAR2 := fnd_api.g_miss_char
    , p0_a274  VARCHAR2 := fnd_api.g_miss_char
    , p0_a275  VARCHAR2 := fnd_api.g_miss_char
    , p0_a276  VARCHAR2 := fnd_api.g_miss_char
    , p0_a277  VARCHAR2 := fnd_api.g_miss_char
    , p0_a278  VARCHAR2 := fnd_api.g_miss_char
    , p0_a279  VARCHAR2 := fnd_api.g_miss_char
    , p0_a280  VARCHAR2 := fnd_api.g_miss_char
    , p0_a281  VARCHAR2 := fnd_api.g_miss_char
    , p0_a282  VARCHAR2 := fnd_api.g_miss_char
    , p0_a283  VARCHAR2 := fnd_api.g_miss_char
    , p0_a284  VARCHAR2 := fnd_api.g_miss_char
    , p0_a285  VARCHAR2 := fnd_api.g_miss_char
    , p0_a286  VARCHAR2 := fnd_api.g_miss_char
    , p0_a287  VARCHAR2 := fnd_api.g_miss_char
    , p0_a288  VARCHAR2 := fnd_api.g_miss_char
    , p0_a289  VARCHAR2 := fnd_api.g_miss_char
    , p0_a290  VARCHAR2 := fnd_api.g_miss_char
    , p0_a291  VARCHAR2 := fnd_api.g_miss_char
    , p0_a292  VARCHAR2 := fnd_api.g_miss_char
    , p0_a293  VARCHAR2 := fnd_api.g_miss_char
    , p0_a294  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_is_line_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  VARCHAR2 := fnd_api.g_miss_char
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  VARCHAR2 := fnd_api.g_miss_char
    , p5_a95  VARCHAR2 := fnd_api.g_miss_char
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  VARCHAR2 := fnd_api.g_miss_char
    , p5_a99  VARCHAR2 := fnd_api.g_miss_char
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  VARCHAR2 := fnd_api.g_miss_char
    , p5_a102  VARCHAR2 := fnd_api.g_miss_char
    , p5_a103  VARCHAR2 := fnd_api.g_miss_char
    , p5_a104  VARCHAR2 := fnd_api.g_miss_char
    , p5_a105  VARCHAR2 := fnd_api.g_miss_char
    , p5_a106  VARCHAR2 := fnd_api.g_miss_char
    , p5_a107  VARCHAR2 := fnd_api.g_miss_char
    , p5_a108  VARCHAR2 := fnd_api.g_miss_char
    , p5_a109  VARCHAR2 := fnd_api.g_miss_char
    , p5_a110  VARCHAR2 := fnd_api.g_miss_char
    , p5_a111  VARCHAR2 := fnd_api.g_miss_char
    , p5_a112  VARCHAR2 := fnd_api.g_miss_char
    , p5_a113  VARCHAR2 := fnd_api.g_miss_char
    , p5_a114  VARCHAR2 := fnd_api.g_miss_char
    , p5_a115  VARCHAR2 := fnd_api.g_miss_char
    , p5_a116  VARCHAR2 := fnd_api.g_miss_char
    , p5_a117  VARCHAR2 := fnd_api.g_miss_char
    , p5_a118  VARCHAR2 := fnd_api.g_miss_char
    , p5_a119  VARCHAR2 := fnd_api.g_miss_char
    , p5_a120  VARCHAR2 := fnd_api.g_miss_char
    , p5_a121  VARCHAR2 := fnd_api.g_miss_char
    , p5_a122  VARCHAR2 := fnd_api.g_miss_char
    , p5_a123  VARCHAR2 := fnd_api.g_miss_char
    , p5_a124  VARCHAR2 := fnd_api.g_miss_char
    , p5_a125  VARCHAR2 := fnd_api.g_miss_char
    , p5_a126  VARCHAR2 := fnd_api.g_miss_char
    , p5_a127  VARCHAR2 := fnd_api.g_miss_char
    , p5_a128  VARCHAR2 := fnd_api.g_miss_char
    , p5_a129  VARCHAR2 := fnd_api.g_miss_char
    , p5_a130  VARCHAR2 := fnd_api.g_miss_char
    , p5_a131  VARCHAR2 := fnd_api.g_miss_char
    , p5_a132  VARCHAR2 := fnd_api.g_miss_char
    , p5_a133  VARCHAR2 := fnd_api.g_miss_char
    , p5_a134  VARCHAR2 := fnd_api.g_miss_char
    , p5_a135  VARCHAR2 := fnd_api.g_miss_char
    , p5_a136  VARCHAR2 := fnd_api.g_miss_char
    , p5_a137  VARCHAR2 := fnd_api.g_miss_char
    , p5_a138  VARCHAR2 := fnd_api.g_miss_char
    , p5_a139  VARCHAR2 := fnd_api.g_miss_char
    , p5_a140  VARCHAR2 := fnd_api.g_miss_char
    , p5_a141  VARCHAR2 := fnd_api.g_miss_char
    , p5_a142  VARCHAR2 := fnd_api.g_miss_char
    , p5_a143  VARCHAR2 := fnd_api.g_miss_char
    , p5_a144  VARCHAR2 := fnd_api.g_miss_char
    , p5_a145  VARCHAR2 := fnd_api.g_miss_char
    , p5_a146  VARCHAR2 := fnd_api.g_miss_char
    , p5_a147  VARCHAR2 := fnd_api.g_miss_char
    , p5_a148  VARCHAR2 := fnd_api.g_miss_char
    , p5_a149  VARCHAR2 := fnd_api.g_miss_char
    , p5_a150  VARCHAR2 := fnd_api.g_miss_char
    , p5_a151  VARCHAR2 := fnd_api.g_miss_char
    , p5_a152  VARCHAR2 := fnd_api.g_miss_char
    , p5_a153  VARCHAR2 := fnd_api.g_miss_char
    , p5_a154  VARCHAR2 := fnd_api.g_miss_char
    , p5_a155  VARCHAR2 := fnd_api.g_miss_char
    , p5_a156  VARCHAR2 := fnd_api.g_miss_char
    , p5_a157  VARCHAR2 := fnd_api.g_miss_char
    , p5_a158  VARCHAR2 := fnd_api.g_miss_char
    , p5_a159  VARCHAR2 := fnd_api.g_miss_char
    , p5_a160  VARCHAR2 := fnd_api.g_miss_char
    , p5_a161  VARCHAR2 := fnd_api.g_miss_char
    , p5_a162  VARCHAR2 := fnd_api.g_miss_char
    , p5_a163  VARCHAR2 := fnd_api.g_miss_char
    , p5_a164  VARCHAR2 := fnd_api.g_miss_char
    , p5_a165  VARCHAR2 := fnd_api.g_miss_char
    , p5_a166  VARCHAR2 := fnd_api.g_miss_char
    , p5_a167  VARCHAR2 := fnd_api.g_miss_char
    , p5_a168  VARCHAR2 := fnd_api.g_miss_char
    , p5_a169  VARCHAR2 := fnd_api.g_miss_char
    , p5_a170  VARCHAR2 := fnd_api.g_miss_char
    , p5_a171  VARCHAR2 := fnd_api.g_miss_char
    , p5_a172  VARCHAR2 := fnd_api.g_miss_char
    , p5_a173  VARCHAR2 := fnd_api.g_miss_char
    , p5_a174  VARCHAR2 := fnd_api.g_miss_char
    , p5_a175  VARCHAR2 := fnd_api.g_miss_char
    , p5_a176  VARCHAR2 := fnd_api.g_miss_char
    , p5_a177  VARCHAR2 := fnd_api.g_miss_char
    , p5_a178  VARCHAR2 := fnd_api.g_miss_char
    , p5_a179  VARCHAR2 := fnd_api.g_miss_char
    , p5_a180  VARCHAR2 := fnd_api.g_miss_char
    , p5_a181  VARCHAR2 := fnd_api.g_miss_char
    , p5_a182  VARCHAR2 := fnd_api.g_miss_char
    , p5_a183  VARCHAR2 := fnd_api.g_miss_char
    , p5_a184  VARCHAR2 := fnd_api.g_miss_char
    , p5_a185  VARCHAR2 := fnd_api.g_miss_char
    , p5_a186  VARCHAR2 := fnd_api.g_miss_char
    , p5_a187  VARCHAR2 := fnd_api.g_miss_char
    , p5_a188  VARCHAR2 := fnd_api.g_miss_char
    , p5_a189  VARCHAR2 := fnd_api.g_miss_char
    , p5_a190  VARCHAR2 := fnd_api.g_miss_char
    , p5_a191  VARCHAR2 := fnd_api.g_miss_char
    , p5_a192  VARCHAR2 := fnd_api.g_miss_char
    , p5_a193  VARCHAR2 := fnd_api.g_miss_char
    , p5_a194  VARCHAR2 := fnd_api.g_miss_char
    , p5_a195  VARCHAR2 := fnd_api.g_miss_char
    , p5_a196  VARCHAR2 := fnd_api.g_miss_char
    , p5_a197  VARCHAR2 := fnd_api.g_miss_char
    , p5_a198  VARCHAR2 := fnd_api.g_miss_char
    , p5_a199  VARCHAR2 := fnd_api.g_miss_char
    , p5_a200  VARCHAR2 := fnd_api.g_miss_char
    , p5_a201  VARCHAR2 := fnd_api.g_miss_char
    , p5_a202  VARCHAR2 := fnd_api.g_miss_char
    , p5_a203  VARCHAR2 := fnd_api.g_miss_char
    , p5_a204  VARCHAR2 := fnd_api.g_miss_char
    , p5_a205  VARCHAR2 := fnd_api.g_miss_char
    , p5_a206  VARCHAR2 := fnd_api.g_miss_char
    , p5_a207  VARCHAR2 := fnd_api.g_miss_char
    , p5_a208  VARCHAR2 := fnd_api.g_miss_char
    , p5_a209  VARCHAR2 := fnd_api.g_miss_char
    , p5_a210  VARCHAR2 := fnd_api.g_miss_char
    , p5_a211  VARCHAR2 := fnd_api.g_miss_char
    , p5_a212  VARCHAR2 := fnd_api.g_miss_char
    , p5_a213  VARCHAR2 := fnd_api.g_miss_char
    , p5_a214  VARCHAR2 := fnd_api.g_miss_char
    , p5_a215  VARCHAR2 := fnd_api.g_miss_char
    , p5_a216  VARCHAR2 := fnd_api.g_miss_char
    , p5_a217  VARCHAR2 := fnd_api.g_miss_char
    , p5_a218  VARCHAR2 := fnd_api.g_miss_char
    , p5_a219  VARCHAR2 := fnd_api.g_miss_char
    , p5_a220  VARCHAR2 := fnd_api.g_miss_char
    , p5_a221  VARCHAR2 := fnd_api.g_miss_char
    , p5_a222  VARCHAR2 := fnd_api.g_miss_char
    , p5_a223  VARCHAR2 := fnd_api.g_miss_char
    , p5_a224  VARCHAR2 := fnd_api.g_miss_char
    , p5_a225  VARCHAR2 := fnd_api.g_miss_char
    , p5_a226  VARCHAR2 := fnd_api.g_miss_char
    , p5_a227  VARCHAR2 := fnd_api.g_miss_char
    , p5_a228  VARCHAR2 := fnd_api.g_miss_char
    , p5_a229  VARCHAR2 := fnd_api.g_miss_char
    , p5_a230  VARCHAR2 := fnd_api.g_miss_char
    , p5_a231  VARCHAR2 := fnd_api.g_miss_char
    , p5_a232  VARCHAR2 := fnd_api.g_miss_char
    , p5_a233  VARCHAR2 := fnd_api.g_miss_char
    , p5_a234  VARCHAR2 := fnd_api.g_miss_char
    , p5_a235  VARCHAR2 := fnd_api.g_miss_char
    , p5_a236  VARCHAR2 := fnd_api.g_miss_char
    , p5_a237  VARCHAR2 := fnd_api.g_miss_char
    , p5_a238  VARCHAR2 := fnd_api.g_miss_char
    , p5_a239  VARCHAR2 := fnd_api.g_miss_char
    , p5_a240  VARCHAR2 := fnd_api.g_miss_char
    , p5_a241  VARCHAR2 := fnd_api.g_miss_char
    , p5_a242  VARCHAR2 := fnd_api.g_miss_char
    , p5_a243  VARCHAR2 := fnd_api.g_miss_char
    , p5_a244  VARCHAR2 := fnd_api.g_miss_char
    , p5_a245  VARCHAR2 := fnd_api.g_miss_char
    , p5_a246  VARCHAR2 := fnd_api.g_miss_char
    , p5_a247  VARCHAR2 := fnd_api.g_miss_char
    , p5_a248  VARCHAR2 := fnd_api.g_miss_char
    , p5_a249  VARCHAR2 := fnd_api.g_miss_char
    , p5_a250  VARCHAR2 := fnd_api.g_miss_char
    , p5_a251  VARCHAR2 := fnd_api.g_miss_char
    , p5_a252  VARCHAR2 := fnd_api.g_miss_char
    , p5_a253  VARCHAR2 := fnd_api.g_miss_char
    , p5_a254  VARCHAR2 := fnd_api.g_miss_char
    , p5_a255  VARCHAR2 := fnd_api.g_miss_char
    , p5_a256  VARCHAR2 := fnd_api.g_miss_char
    , p5_a257  VARCHAR2 := fnd_api.g_miss_char
    , p5_a258  VARCHAR2 := fnd_api.g_miss_char
    , p5_a259  VARCHAR2 := fnd_api.g_miss_char
    , p5_a260  VARCHAR2 := fnd_api.g_miss_char
    , p5_a261  VARCHAR2 := fnd_api.g_miss_char
    , p5_a262  VARCHAR2 := fnd_api.g_miss_char
    , p5_a263  VARCHAR2 := fnd_api.g_miss_char
    , p5_a264  VARCHAR2 := fnd_api.g_miss_char
    , p5_a265  NUMBER := 0-1962.0724
    , p5_a266  VARCHAR2 := fnd_api.g_miss_char
    , p5_a267  VARCHAR2 := fnd_api.g_miss_char
    , p5_a268  VARCHAR2 := fnd_api.g_miss_char
    , p5_a269  VARCHAR2 := fnd_api.g_miss_char
    , p5_a270  VARCHAR2 := fnd_api.g_miss_char
    , p5_a271  VARCHAR2 := fnd_api.g_miss_char
    , p5_a272  VARCHAR2 := fnd_api.g_miss_char
    , p5_a273  VARCHAR2 := fnd_api.g_miss_char
    , p5_a274  VARCHAR2 := fnd_api.g_miss_char
    , p5_a275  VARCHAR2 := fnd_api.g_miss_char
    , p5_a276  VARCHAR2 := fnd_api.g_miss_char
    , p5_a277  VARCHAR2 := fnd_api.g_miss_char
    , p5_a278  VARCHAR2 := fnd_api.g_miss_char
    , p5_a279  VARCHAR2 := fnd_api.g_miss_char
    , p5_a280  VARCHAR2 := fnd_api.g_miss_char
    , p5_a281  VARCHAR2 := fnd_api.g_miss_char
    , p5_a282  VARCHAR2 := fnd_api.g_miss_char
    , p5_a283  VARCHAR2 := fnd_api.g_miss_char
    , p5_a284  VARCHAR2 := fnd_api.g_miss_char
    , p5_a285  VARCHAR2 := fnd_api.g_miss_char
    , p5_a286  VARCHAR2 := fnd_api.g_miss_char
    , p5_a287  VARCHAR2 := fnd_api.g_miss_char
    , p5_a288  VARCHAR2 := fnd_api.g_miss_char
    , p5_a289  VARCHAR2 := fnd_api.g_miss_char
    , p5_a290  VARCHAR2 := fnd_api.g_miss_char
    , p5_a291  VARCHAR2 := fnd_api.g_miss_char
    , p5_a292  VARCHAR2 := fnd_api.g_miss_char
    , p5_a293  VARCHAR2 := fnd_api.g_miss_char
    , p5_a294  VARCHAR2 := fnd_api.g_miss_char
  );
end ams_is_line_pvt_w;

 

/
