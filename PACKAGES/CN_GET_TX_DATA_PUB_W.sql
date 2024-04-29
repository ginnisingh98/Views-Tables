--------------------------------------------------------
--  DDL for Package CN_GET_TX_DATA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_TX_DATA_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwxadjs.pls 120.4.12000000.2 2007/08/08 05:57:56 apink ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_get_tx_data_pub.adj_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_1800
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a129 JTF_NUMBER_TABLE
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_VARCHAR2_TABLE_100
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_NUMBER_TABLE
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_NUMBER_TABLE
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_NUMBER_TABLE
    , a144 JTF_NUMBER_TABLE
    , a145 JTF_NUMBER_TABLE
    , a146 JTF_NUMBER_TABLE
    , a147 JTF_DATE_TABLE
    , a148 JTF_NUMBER_TABLE
    , a149 JTF_VARCHAR2_TABLE_100
    , a150 JTF_DATE_TABLE
    , a151 JTF_NUMBER_TABLE
    , a152 JTF_DATE_TABLE
    , a153 JTF_NUMBER_TABLE
    , a154 JTF_NUMBER_TABLE
    , a155 JTF_NUMBER_TABLE
    , a156 JTF_NUMBER_TABLE
    , a157 JTF_NUMBER_TABLE
    , a158 JTF_NUMBER_TABLE
    , a159 JTF_VARCHAR2_TABLE_100
    , a160 JTF_VARCHAR2_TABLE_100
    , a161 JTF_VARCHAR2_TABLE_100
    , a162 JTF_VARCHAR2_TABLE_100
    , a163 JTF_DATE_TABLE
    , a164 JTF_VARCHAR2_TABLE_100
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_VARCHAR2_TABLE_100
    , a167 JTF_VARCHAR2_TABLE_2000
    , a168 JTF_VARCHAR2_TABLE_100
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_NUMBER_TABLE
    , a171 JTF_NUMBER_TABLE
    , a172 JTF_NUMBER_TABLE
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_NUMBER_TABLE
    , a175 JTF_NUMBER_TABLE
    , a176 JTF_VARCHAR2_TABLE_100
    , a177 JTF_NUMBER_TABLE
    , a178 JTF_VARCHAR2_TABLE_100
    , a179 JTF_VARCHAR2_TABLE_100
    , a180 JTF_VARCHAR2_TABLE_100
    , a181 JTF_VARCHAR2_TABLE_100
    , a182 JTF_VARCHAR2_TABLE_100
    , a183 JTF_NUMBER_TABLE
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_NUMBER_TABLE
    , a186 JTF_NUMBER_TABLE
    , a187 JTF_NUMBER_TABLE
    , a188 JTF_NUMBER_TABLE
    , a189 JTF_VARCHAR2_TABLE_100
    , a190 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t cn_get_tx_data_pub.adj_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_DATE_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_VARCHAR2_TABLE_300
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_300
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_300
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_VARCHAR2_TABLE_300
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_300
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_300
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_300
    , a104 out nocopy JTF_VARCHAR2_TABLE_300
    , a105 out nocopy JTF_VARCHAR2_TABLE_300
    , a106 out nocopy JTF_VARCHAR2_TABLE_300
    , a107 out nocopy JTF_VARCHAR2_TABLE_300
    , a108 out nocopy JTF_VARCHAR2_TABLE_300
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_VARCHAR2_TABLE_300
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_300
    , a114 out nocopy JTF_VARCHAR2_TABLE_300
    , a115 out nocopy JTF_VARCHAR2_TABLE_300
    , a116 out nocopy JTF_VARCHAR2_TABLE_300
    , a117 out nocopy JTF_VARCHAR2_TABLE_300
    , a118 out nocopy JTF_VARCHAR2_TABLE_300
    , a119 out nocopy JTF_VARCHAR2_TABLE_300
    , a120 out nocopy JTF_VARCHAR2_TABLE_300
    , a121 out nocopy JTF_VARCHAR2_TABLE_300
    , a122 out nocopy JTF_VARCHAR2_TABLE_300
    , a123 out nocopy JTF_VARCHAR2_TABLE_300
    , a124 out nocopy JTF_VARCHAR2_TABLE_300
    , a125 out nocopy JTF_VARCHAR2_TABLE_300
    , a126 out nocopy JTF_VARCHAR2_TABLE_300
    , a127 out nocopy JTF_VARCHAR2_TABLE_300
    , a128 out nocopy JTF_VARCHAR2_TABLE_300
    , a129 out nocopy JTF_NUMBER_TABLE
    , a130 out nocopy JTF_VARCHAR2_TABLE_100
    , a131 out nocopy JTF_NUMBER_TABLE
    , a132 out nocopy JTF_VARCHAR2_TABLE_100
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_NUMBER_TABLE
    , a139 out nocopy JTF_VARCHAR2_TABLE_100
    , a140 out nocopy JTF_NUMBER_TABLE
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_VARCHAR2_TABLE_100
    , a143 out nocopy JTF_NUMBER_TABLE
    , a144 out nocopy JTF_NUMBER_TABLE
    , a145 out nocopy JTF_NUMBER_TABLE
    , a146 out nocopy JTF_NUMBER_TABLE
    , a147 out nocopy JTF_DATE_TABLE
    , a148 out nocopy JTF_NUMBER_TABLE
    , a149 out nocopy JTF_VARCHAR2_TABLE_100
    , a150 out nocopy JTF_DATE_TABLE
    , a151 out nocopy JTF_NUMBER_TABLE
    , a152 out nocopy JTF_DATE_TABLE
    , a153 out nocopy JTF_NUMBER_TABLE
    , a154 out nocopy JTF_NUMBER_TABLE
    , a155 out nocopy JTF_NUMBER_TABLE
    , a156 out nocopy JTF_NUMBER_TABLE
    , a157 out nocopy JTF_NUMBER_TABLE
    , a158 out nocopy JTF_NUMBER_TABLE
    , a159 out nocopy JTF_VARCHAR2_TABLE_100
    , a160 out nocopy JTF_VARCHAR2_TABLE_100
    , a161 out nocopy JTF_VARCHAR2_TABLE_100
    , a162 out nocopy JTF_VARCHAR2_TABLE_100
    , a163 out nocopy JTF_DATE_TABLE
    , a164 out nocopy JTF_VARCHAR2_TABLE_100
    , a165 out nocopy JTF_VARCHAR2_TABLE_100
    , a166 out nocopy JTF_VARCHAR2_TABLE_100
    , a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , a168 out nocopy JTF_VARCHAR2_TABLE_100
    , a169 out nocopy JTF_VARCHAR2_TABLE_100
    , a170 out nocopy JTF_NUMBER_TABLE
    , a171 out nocopy JTF_NUMBER_TABLE
    , a172 out nocopy JTF_NUMBER_TABLE
    , a173 out nocopy JTF_VARCHAR2_TABLE_100
    , a174 out nocopy JTF_NUMBER_TABLE
    , a175 out nocopy JTF_NUMBER_TABLE
    , a176 out nocopy JTF_VARCHAR2_TABLE_100
    , a177 out nocopy JTF_NUMBER_TABLE
    , a178 out nocopy JTF_VARCHAR2_TABLE_100
    , a179 out nocopy JTF_VARCHAR2_TABLE_100
    , a180 out nocopy JTF_VARCHAR2_TABLE_100
    , a181 out nocopy JTF_VARCHAR2_TABLE_100
    , a182 out nocopy JTF_VARCHAR2_TABLE_100
    , a183 out nocopy JTF_NUMBER_TABLE
    , a184 out nocopy JTF_NUMBER_TABLE
    , a185 out nocopy JTF_NUMBER_TABLE
    , a186 out nocopy JTF_NUMBER_TABLE
    , a187 out nocopy JTF_NUMBER_TABLE
    , a188 out nocopy JTF_NUMBER_TABLE
    , a189 out nocopy JTF_VARCHAR2_TABLE_100
    , a190 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cn_get_tx_data_pub.tx_adj_data_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t cn_get_tx_data_pub.tx_adj_data_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy cn_get_tx_data_pub.split_data_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cn_get_tx_data_pub.split_data_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cn_get_tx_data_pub.trx_line_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_400
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p7(t cn_get_tx_data_pub.trx_line_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_400
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p9(t out nocopy cn_get_tx_data_pub.cust_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p9(t cn_get_tx_data_pub.cust_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_400
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p11(t out nocopy cn_get_tx_data_pub.attribute_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p11(t cn_get_tx_data_pub.attribute_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_api_data(p_comm_lines_api_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a3 out nocopy JTF_NUMBER_TABLE
    , p1_a4 out nocopy JTF_NUMBER_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_DATE_TABLE
    , p1_a7 out nocopy JTF_DATE_TABLE
    , p1_a8 out nocopy JTF_NUMBER_TABLE
    , p1_a9 out nocopy JTF_NUMBER_TABLE
    , p1_a10 out nocopy JTF_NUMBER_TABLE
    , p1_a11 out nocopy JTF_NUMBER_TABLE
    , p1_a12 out nocopy JTF_NUMBER_TABLE
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a14 out nocopy JTF_NUMBER_TABLE
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p1_a22 out nocopy JTF_NUMBER_TABLE
    , p1_a23 out nocopy JTF_NUMBER_TABLE
    , p1_a24 out nocopy JTF_DATE_TABLE
    , p1_a25 out nocopy JTF_NUMBER_TABLE
    , p1_a26 out nocopy JTF_NUMBER_TABLE
    , p1_a27 out nocopy JTF_DATE_TABLE
    , p1_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a129 out nocopy JTF_NUMBER_TABLE
    , p1_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a131 out nocopy JTF_NUMBER_TABLE
    , p1_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a135 out nocopy JTF_NUMBER_TABLE
    , p1_a136 out nocopy JTF_NUMBER_TABLE
    , p1_a137 out nocopy JTF_NUMBER_TABLE
    , p1_a138 out nocopy JTF_NUMBER_TABLE
    , p1_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a140 out nocopy JTF_NUMBER_TABLE
    , p1_a141 out nocopy JTF_NUMBER_TABLE
    , p1_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a143 out nocopy JTF_NUMBER_TABLE
    , p1_a144 out nocopy JTF_NUMBER_TABLE
    , p1_a145 out nocopy JTF_NUMBER_TABLE
    , p1_a146 out nocopy JTF_NUMBER_TABLE
    , p1_a147 out nocopy JTF_DATE_TABLE
    , p1_a148 out nocopy JTF_NUMBER_TABLE
    , p1_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a150 out nocopy JTF_DATE_TABLE
    , p1_a151 out nocopy JTF_NUMBER_TABLE
    , p1_a152 out nocopy JTF_DATE_TABLE
    , p1_a153 out nocopy JTF_NUMBER_TABLE
    , p1_a154 out nocopy JTF_NUMBER_TABLE
    , p1_a155 out nocopy JTF_NUMBER_TABLE
    , p1_a156 out nocopy JTF_NUMBER_TABLE
    , p1_a157 out nocopy JTF_NUMBER_TABLE
    , p1_a158 out nocopy JTF_NUMBER_TABLE
    , p1_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a163 out nocopy JTF_DATE_TABLE
    , p1_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a170 out nocopy JTF_NUMBER_TABLE
    , p1_a171 out nocopy JTF_NUMBER_TABLE
    , p1_a172 out nocopy JTF_NUMBER_TABLE
    , p1_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a174 out nocopy JTF_NUMBER_TABLE
    , p1_a175 out nocopy JTF_NUMBER_TABLE
    , p1_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a177 out nocopy JTF_NUMBER_TABLE
    , p1_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a183 out nocopy JTF_NUMBER_TABLE
    , p1_a184 out nocopy JTF_NUMBER_TABLE
    , p1_a185 out nocopy JTF_NUMBER_TABLE
    , p1_a186 out nocopy JTF_NUMBER_TABLE
    , p1_a187 out nocopy JTF_NUMBER_TABLE
    , p1_a188 out nocopy JTF_NUMBER_TABLE
    , p1_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a190 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure get_adj(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_org_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_pr_date_to  DATE
    , p_pr_date_from  DATE
    , p_calc_status  VARCHAR2
    , p_adj_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p12_a0  NUMBER
    , p12_a1  VARCHAR2
    , p12_a2  VARCHAR2
    , p12_a3  NUMBER
    , p12_a4  NUMBER
    , p12_a5  VARCHAR2
    , p12_a6  DATE
    , p12_a7  DATE
    , p12_a8  NUMBER
    , p12_a9  NUMBER
    , p12_a10  NUMBER
    , p12_a11  NUMBER
    , p12_a12  NUMBER
    , p12_a13  VARCHAR2
    , p12_a14  NUMBER
    , p12_a15  VARCHAR2
    , p12_a16  VARCHAR2
    , p12_a17  VARCHAR2
    , p12_a18  VARCHAR2
    , p12_a19  VARCHAR2
    , p12_a20  VARCHAR2
    , p12_a21  VARCHAR2
    , p12_a22  NUMBER
    , p12_a23  NUMBER
    , p12_a24  DATE
    , p12_a25  NUMBER
    , p12_a26  NUMBER
    , p12_a27  DATE
    , p12_a28  VARCHAR2
    , p12_a29  VARCHAR2
    , p12_a30  VARCHAR2
    , p12_a31  VARCHAR2
    , p12_a32  VARCHAR2
    , p12_a33  VARCHAR2
    , p12_a34  VARCHAR2
    , p12_a35  VARCHAR2
    , p12_a36  VARCHAR2
    , p12_a37  VARCHAR2
    , p12_a38  VARCHAR2
    , p12_a39  VARCHAR2
    , p12_a40  VARCHAR2
    , p12_a41  VARCHAR2
    , p12_a42  VARCHAR2
    , p12_a43  VARCHAR2
    , p12_a44  VARCHAR2
    , p12_a45  VARCHAR2
    , p12_a46  VARCHAR2
    , p12_a47  VARCHAR2
    , p12_a48  VARCHAR2
    , p12_a49  VARCHAR2
    , p12_a50  VARCHAR2
    , p12_a51  VARCHAR2
    , p12_a52  VARCHAR2
    , p12_a53  VARCHAR2
    , p12_a54  VARCHAR2
    , p12_a55  VARCHAR2
    , p12_a56  VARCHAR2
    , p12_a57  VARCHAR2
    , p12_a58  VARCHAR2
    , p12_a59  VARCHAR2
    , p12_a60  VARCHAR2
    , p12_a61  VARCHAR2
    , p12_a62  VARCHAR2
    , p12_a63  VARCHAR2
    , p12_a64  VARCHAR2
    , p12_a65  VARCHAR2
    , p12_a66  VARCHAR2
    , p12_a67  VARCHAR2
    , p12_a68  VARCHAR2
    , p12_a69  VARCHAR2
    , p12_a70  VARCHAR2
    , p12_a71  VARCHAR2
    , p12_a72  VARCHAR2
    , p12_a73  VARCHAR2
    , p12_a74  VARCHAR2
    , p12_a75  VARCHAR2
    , p12_a76  VARCHAR2
    , p12_a77  VARCHAR2
    , p12_a78  VARCHAR2
    , p12_a79  VARCHAR2
    , p12_a80  VARCHAR2
    , p12_a81  VARCHAR2
    , p12_a82  VARCHAR2
    , p12_a83  VARCHAR2
    , p12_a84  VARCHAR2
    , p12_a85  VARCHAR2
    , p12_a86  VARCHAR2
    , p12_a87  VARCHAR2
    , p12_a88  VARCHAR2
    , p12_a89  VARCHAR2
    , p12_a90  VARCHAR2
    , p12_a91  VARCHAR2
    , p12_a92  VARCHAR2
    , p12_a93  VARCHAR2
    , p12_a94  VARCHAR2
    , p12_a95  VARCHAR2
    , p12_a96  VARCHAR2
    , p12_a97  VARCHAR2
    , p12_a98  VARCHAR2
    , p12_a99  VARCHAR2
    , p12_a100  VARCHAR2
    , p12_a101  VARCHAR2
    , p12_a102  VARCHAR2
    , p12_a103  VARCHAR2
    , p12_a104  VARCHAR2
    , p12_a105  VARCHAR2
    , p12_a106  VARCHAR2
    , p12_a107  VARCHAR2
    , p12_a108  VARCHAR2
    , p12_a109  VARCHAR2
    , p12_a110  VARCHAR2
    , p12_a111  VARCHAR2
    , p12_a112  VARCHAR2
    , p12_a113  VARCHAR2
    , p12_a114  VARCHAR2
    , p12_a115  VARCHAR2
    , p12_a116  VARCHAR2
    , p12_a117  VARCHAR2
    , p12_a118  VARCHAR2
    , p12_a119  VARCHAR2
    , p12_a120  VARCHAR2
    , p12_a121  VARCHAR2
    , p12_a122  VARCHAR2
    , p12_a123  VARCHAR2
    , p12_a124  VARCHAR2
    , p12_a125  VARCHAR2
    , p12_a126  VARCHAR2
    , p12_a127  VARCHAR2
    , p12_a128  VARCHAR2
    , p12_a129  NUMBER
    , p12_a130  VARCHAR2
    , p12_a131  NUMBER
    , p12_a132  VARCHAR2
    , p12_a133  VARCHAR2
    , p12_a134  VARCHAR2
    , p12_a135  NUMBER
    , p12_a136  NUMBER
    , p12_a137  NUMBER
    , p12_a138  NUMBER
    , p12_a139  VARCHAR2
    , p12_a140  NUMBER
    , p12_a141  NUMBER
    , p12_a142  VARCHAR2
    , p12_a143  NUMBER
    , p12_a144  NUMBER
    , p12_a145  NUMBER
    , p12_a146  NUMBER
    , p12_a147  DATE
    , p12_a148  NUMBER
    , p12_a149  VARCHAR2
    , p12_a150  DATE
    , p12_a151  NUMBER
    , p12_a152  DATE
    , p12_a153  NUMBER
    , p12_a154  NUMBER
    , p12_a155  NUMBER
    , p12_a156  NUMBER
    , p12_a157  NUMBER
    , p12_a158  NUMBER
    , p12_a159  VARCHAR2
    , p12_a160  VARCHAR2
    , p12_a161  VARCHAR2
    , p12_a162  VARCHAR2
    , p12_a163  DATE
    , p12_a164  VARCHAR2
    , p12_a165  VARCHAR2
    , p12_a166  VARCHAR2
    , p12_a167  VARCHAR2
    , p12_a168  VARCHAR2
    , p12_a169  VARCHAR2
    , p12_a170  NUMBER
    , p12_a171  NUMBER
    , p12_a172  NUMBER
    , p12_a173  VARCHAR2
    , p12_a174  NUMBER
    , p12_a175  NUMBER
    , p12_a176  VARCHAR2
    , p12_a177  NUMBER
    , p12_a178  VARCHAR2
    , p12_a179  VARCHAR2
    , p12_a180  VARCHAR2
    , p12_a181  VARCHAR2
    , p12_a182  VARCHAR2
    , p12_a183  NUMBER
    , p12_a184  NUMBER
    , p12_a185  NUMBER
    , p12_a186  NUMBER
    , p12_a187  NUMBER
    , p12_a188  NUMBER
    , p12_a189  VARCHAR2
    , p12_a190  VARCHAR2
    , p_first  NUMBER
    , p_last  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p19_a0 out nocopy JTF_NUMBER_TABLE
    , p19_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p19_a3 out nocopy JTF_NUMBER_TABLE
    , p19_a4 out nocopy JTF_NUMBER_TABLE
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a6 out nocopy JTF_DATE_TABLE
    , p19_a7 out nocopy JTF_DATE_TABLE
    , p19_a8 out nocopy JTF_NUMBER_TABLE
    , p19_a9 out nocopy JTF_NUMBER_TABLE
    , p19_a10 out nocopy JTF_NUMBER_TABLE
    , p19_a11 out nocopy JTF_NUMBER_TABLE
    , p19_a12 out nocopy JTF_NUMBER_TABLE
    , p19_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a14 out nocopy JTF_NUMBER_TABLE
    , p19_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p19_a22 out nocopy JTF_NUMBER_TABLE
    , p19_a23 out nocopy JTF_NUMBER_TABLE
    , p19_a24 out nocopy JTF_DATE_TABLE
    , p19_a25 out nocopy JTF_NUMBER_TABLE
    , p19_a26 out nocopy JTF_NUMBER_TABLE
    , p19_a27 out nocopy JTF_DATE_TABLE
    , p19_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p19_a129 out nocopy JTF_NUMBER_TABLE
    , p19_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a131 out nocopy JTF_NUMBER_TABLE
    , p19_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a135 out nocopy JTF_NUMBER_TABLE
    , p19_a136 out nocopy JTF_NUMBER_TABLE
    , p19_a137 out nocopy JTF_NUMBER_TABLE
    , p19_a138 out nocopy JTF_NUMBER_TABLE
    , p19_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a140 out nocopy JTF_NUMBER_TABLE
    , p19_a141 out nocopy JTF_NUMBER_TABLE
    , p19_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a143 out nocopy JTF_NUMBER_TABLE
    , p19_a144 out nocopy JTF_NUMBER_TABLE
    , p19_a145 out nocopy JTF_NUMBER_TABLE
    , p19_a146 out nocopy JTF_NUMBER_TABLE
    , p19_a147 out nocopy JTF_DATE_TABLE
    , p19_a148 out nocopy JTF_NUMBER_TABLE
    , p19_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a150 out nocopy JTF_DATE_TABLE
    , p19_a151 out nocopy JTF_NUMBER_TABLE
    , p19_a152 out nocopy JTF_DATE_TABLE
    , p19_a153 out nocopy JTF_NUMBER_TABLE
    , p19_a154 out nocopy JTF_NUMBER_TABLE
    , p19_a155 out nocopy JTF_NUMBER_TABLE
    , p19_a156 out nocopy JTF_NUMBER_TABLE
    , p19_a157 out nocopy JTF_NUMBER_TABLE
    , p19_a158 out nocopy JTF_NUMBER_TABLE
    , p19_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a163 out nocopy JTF_DATE_TABLE
    , p19_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a170 out nocopy JTF_NUMBER_TABLE
    , p19_a171 out nocopy JTF_NUMBER_TABLE
    , p19_a172 out nocopy JTF_NUMBER_TABLE
    , p19_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a174 out nocopy JTF_NUMBER_TABLE
    , p19_a175 out nocopy JTF_NUMBER_TABLE
    , p19_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a177 out nocopy JTF_NUMBER_TABLE
    , p19_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a183 out nocopy JTF_NUMBER_TABLE
    , p19_a184 out nocopy JTF_NUMBER_TABLE
    , p19_a185 out nocopy JTF_NUMBER_TABLE
    , p19_a186 out nocopy JTF_NUMBER_TABLE
    , p19_a187 out nocopy JTF_NUMBER_TABLE
    , p19_a188 out nocopy JTF_NUMBER_TABLE
    , p19_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p19_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
    , x_valid_trx_count out nocopy  NUMBER
  );
  procedure get_split_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_comm_lines_api_id  NUMBER
    , p_load_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_DATE_TABLE
    , p9_a8 out nocopy JTF_NUMBER_TABLE
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_NUMBER_TABLE
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_NUMBER_TABLE
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_NUMBER_TABLE
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p9_a22 out nocopy JTF_NUMBER_TABLE
    , p9_a23 out nocopy JTF_NUMBER_TABLE
    , p9_a24 out nocopy JTF_DATE_TABLE
    , p9_a25 out nocopy JTF_NUMBER_TABLE
    , p9_a26 out nocopy JTF_NUMBER_TABLE
    , p9_a27 out nocopy JTF_DATE_TABLE
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a129 out nocopy JTF_NUMBER_TABLE
    , p9_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a131 out nocopy JTF_NUMBER_TABLE
    , p9_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a135 out nocopy JTF_NUMBER_TABLE
    , p9_a136 out nocopy JTF_NUMBER_TABLE
    , p9_a137 out nocopy JTF_NUMBER_TABLE
    , p9_a138 out nocopy JTF_NUMBER_TABLE
    , p9_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a140 out nocopy JTF_NUMBER_TABLE
    , p9_a141 out nocopy JTF_NUMBER_TABLE
    , p9_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a143 out nocopy JTF_NUMBER_TABLE
    , p9_a144 out nocopy JTF_NUMBER_TABLE
    , p9_a145 out nocopy JTF_NUMBER_TABLE
    , p9_a146 out nocopy JTF_NUMBER_TABLE
    , p9_a147 out nocopy JTF_DATE_TABLE
    , p9_a148 out nocopy JTF_NUMBER_TABLE
    , p9_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a150 out nocopy JTF_DATE_TABLE
    , p9_a151 out nocopy JTF_NUMBER_TABLE
    , p9_a152 out nocopy JTF_DATE_TABLE
    , p9_a153 out nocopy JTF_NUMBER_TABLE
    , p9_a154 out nocopy JTF_NUMBER_TABLE
    , p9_a155 out nocopy JTF_NUMBER_TABLE
    , p9_a156 out nocopy JTF_NUMBER_TABLE
    , p9_a157 out nocopy JTF_NUMBER_TABLE
    , p9_a158 out nocopy JTF_NUMBER_TABLE
    , p9_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a163 out nocopy JTF_DATE_TABLE
    , p9_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a170 out nocopy JTF_NUMBER_TABLE
    , p9_a171 out nocopy JTF_NUMBER_TABLE
    , p9_a172 out nocopy JTF_NUMBER_TABLE
    , p9_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a174 out nocopy JTF_NUMBER_TABLE
    , p9_a175 out nocopy JTF_NUMBER_TABLE
    , p9_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a177 out nocopy JTF_NUMBER_TABLE
    , p9_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a183 out nocopy JTF_NUMBER_TABLE
    , p9_a184 out nocopy JTF_NUMBER_TABLE
    , p9_a185 out nocopy JTF_NUMBER_TABLE
    , p9_a186 out nocopy JTF_NUMBER_TABLE
    , p9_a187 out nocopy JTF_NUMBER_TABLE
    , p9_a188 out nocopy JTF_NUMBER_TABLE
    , p9_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
  );
  procedure insert_api_record(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_action  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  DATE
    , p4_a7  DATE
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  VARCHAR2
    , p4_a14  NUMBER
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , p4_a23  NUMBER
    , p4_a24  DATE
    , p4_a25  NUMBER
    , p4_a26  NUMBER
    , p4_a27  DATE
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  VARCHAR2
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  VARCHAR2
    , p4_a61  VARCHAR2
    , p4_a62  VARCHAR2
    , p4_a63  VARCHAR2
    , p4_a64  VARCHAR2
    , p4_a65  VARCHAR2
    , p4_a66  VARCHAR2
    , p4_a67  VARCHAR2
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  VARCHAR2
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  VARCHAR2
    , p4_a77  VARCHAR2
    , p4_a78  VARCHAR2
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  VARCHAR2
    , p4_a82  VARCHAR2
    , p4_a83  VARCHAR2
    , p4_a84  VARCHAR2
    , p4_a85  VARCHAR2
    , p4_a86  VARCHAR2
    , p4_a87  VARCHAR2
    , p4_a88  VARCHAR2
    , p4_a89  VARCHAR2
    , p4_a90  VARCHAR2
    , p4_a91  VARCHAR2
    , p4_a92  VARCHAR2
    , p4_a93  VARCHAR2
    , p4_a94  VARCHAR2
    , p4_a95  VARCHAR2
    , p4_a96  VARCHAR2
    , p4_a97  VARCHAR2
    , p4_a98  VARCHAR2
    , p4_a99  VARCHAR2
    , p4_a100  VARCHAR2
    , p4_a101  VARCHAR2
    , p4_a102  VARCHAR2
    , p4_a103  VARCHAR2
    , p4_a104  VARCHAR2
    , p4_a105  VARCHAR2
    , p4_a106  VARCHAR2
    , p4_a107  VARCHAR2
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  VARCHAR2
    , p4_a113  VARCHAR2
    , p4_a114  VARCHAR2
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  VARCHAR2
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  VARCHAR2
    , p4_a126  VARCHAR2
    , p4_a127  VARCHAR2
    , p4_a128  VARCHAR2
    , p4_a129  NUMBER
    , p4_a130  VARCHAR2
    , p4_a131  NUMBER
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  NUMBER
    , p4_a136  NUMBER
    , p4_a137  NUMBER
    , p4_a138  NUMBER
    , p4_a139  VARCHAR2
    , p4_a140  NUMBER
    , p4_a141  NUMBER
    , p4_a142  VARCHAR2
    , p4_a143  NUMBER
    , p4_a144  NUMBER
    , p4_a145  NUMBER
    , p4_a146  NUMBER
    , p4_a147  DATE
    , p4_a148  NUMBER
    , p4_a149  VARCHAR2
    , p4_a150  DATE
    , p4_a151  NUMBER
    , p4_a152  DATE
    , p4_a153  NUMBER
    , p4_a154  NUMBER
    , p4_a155  NUMBER
    , p4_a156  NUMBER
    , p4_a157  NUMBER
    , p4_a158  NUMBER
    , p4_a159  VARCHAR2
    , p4_a160  VARCHAR2
    , p4_a161  VARCHAR2
    , p4_a162  VARCHAR2
    , p4_a163  DATE
    , p4_a164  VARCHAR2
    , p4_a165  VARCHAR2
    , p4_a166  VARCHAR2
    , p4_a167  VARCHAR2
    , p4_a168  VARCHAR2
    , p4_a169  VARCHAR2
    , p4_a170  NUMBER
    , p4_a171  NUMBER
    , p4_a172  NUMBER
    , p4_a173  VARCHAR2
    , p4_a174  NUMBER
    , p4_a175  NUMBER
    , p4_a176  VARCHAR2
    , p4_a177  NUMBER
    , p4_a178  VARCHAR2
    , p4_a179  VARCHAR2
    , p4_a180  VARCHAR2
    , p4_a181  VARCHAR2
    , p4_a182  VARCHAR2
    , p4_a183  NUMBER
    , p4_a184  NUMBER
    , p4_a185  NUMBER
    , p4_a186  NUMBER
    , p4_a187  NUMBER
    , p4_a188  NUMBER
    , p4_a189  VARCHAR2
    , p4_a190  VARCHAR2
    , x_api_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure call_mass_update(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_org_id  NUMBER
    , p_salesrep_id  NUMBER
    , p_pr_date_to  DATE
    , p_pr_date_from  DATE
    , p_calc_status  VARCHAR2
    , p_adj_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p12_a0  NUMBER
    , p12_a1  VARCHAR2
    , p12_a2  VARCHAR2
    , p12_a3  NUMBER
    , p12_a4  NUMBER
    , p12_a5  VARCHAR2
    , p12_a6  DATE
    , p12_a7  DATE
    , p12_a8  NUMBER
    , p12_a9  NUMBER
    , p12_a10  NUMBER
    , p12_a11  NUMBER
    , p12_a12  NUMBER
    , p12_a13  VARCHAR2
    , p12_a14  NUMBER
    , p12_a15  VARCHAR2
    , p12_a16  VARCHAR2
    , p12_a17  VARCHAR2
    , p12_a18  VARCHAR2
    , p12_a19  VARCHAR2
    , p12_a20  VARCHAR2
    , p12_a21  VARCHAR2
    , p12_a22  NUMBER
    , p12_a23  NUMBER
    , p12_a24  DATE
    , p12_a25  NUMBER
    , p12_a26  NUMBER
    , p12_a27  DATE
    , p12_a28  VARCHAR2
    , p12_a29  VARCHAR2
    , p12_a30  VARCHAR2
    , p12_a31  VARCHAR2
    , p12_a32  VARCHAR2
    , p12_a33  VARCHAR2
    , p12_a34  VARCHAR2
    , p12_a35  VARCHAR2
    , p12_a36  VARCHAR2
    , p12_a37  VARCHAR2
    , p12_a38  VARCHAR2
    , p12_a39  VARCHAR2
    , p12_a40  VARCHAR2
    , p12_a41  VARCHAR2
    , p12_a42  VARCHAR2
    , p12_a43  VARCHAR2
    , p12_a44  VARCHAR2
    , p12_a45  VARCHAR2
    , p12_a46  VARCHAR2
    , p12_a47  VARCHAR2
    , p12_a48  VARCHAR2
    , p12_a49  VARCHAR2
    , p12_a50  VARCHAR2
    , p12_a51  VARCHAR2
    , p12_a52  VARCHAR2
    , p12_a53  VARCHAR2
    , p12_a54  VARCHAR2
    , p12_a55  VARCHAR2
    , p12_a56  VARCHAR2
    , p12_a57  VARCHAR2
    , p12_a58  VARCHAR2
    , p12_a59  VARCHAR2
    , p12_a60  VARCHAR2
    , p12_a61  VARCHAR2
    , p12_a62  VARCHAR2
    , p12_a63  VARCHAR2
    , p12_a64  VARCHAR2
    , p12_a65  VARCHAR2
    , p12_a66  VARCHAR2
    , p12_a67  VARCHAR2
    , p12_a68  VARCHAR2
    , p12_a69  VARCHAR2
    , p12_a70  VARCHAR2
    , p12_a71  VARCHAR2
    , p12_a72  VARCHAR2
    , p12_a73  VARCHAR2
    , p12_a74  VARCHAR2
    , p12_a75  VARCHAR2
    , p12_a76  VARCHAR2
    , p12_a77  VARCHAR2
    , p12_a78  VARCHAR2
    , p12_a79  VARCHAR2
    , p12_a80  VARCHAR2
    , p12_a81  VARCHAR2
    , p12_a82  VARCHAR2
    , p12_a83  VARCHAR2
    , p12_a84  VARCHAR2
    , p12_a85  VARCHAR2
    , p12_a86  VARCHAR2
    , p12_a87  VARCHAR2
    , p12_a88  VARCHAR2
    , p12_a89  VARCHAR2
    , p12_a90  VARCHAR2
    , p12_a91  VARCHAR2
    , p12_a92  VARCHAR2
    , p12_a93  VARCHAR2
    , p12_a94  VARCHAR2
    , p12_a95  VARCHAR2
    , p12_a96  VARCHAR2
    , p12_a97  VARCHAR2
    , p12_a98  VARCHAR2
    , p12_a99  VARCHAR2
    , p12_a100  VARCHAR2
    , p12_a101  VARCHAR2
    , p12_a102  VARCHAR2
    , p12_a103  VARCHAR2
    , p12_a104  VARCHAR2
    , p12_a105  VARCHAR2
    , p12_a106  VARCHAR2
    , p12_a107  VARCHAR2
    , p12_a108  VARCHAR2
    , p12_a109  VARCHAR2
    , p12_a110  VARCHAR2
    , p12_a111  VARCHAR2
    , p12_a112  VARCHAR2
    , p12_a113  VARCHAR2
    , p12_a114  VARCHAR2
    , p12_a115  VARCHAR2
    , p12_a116  VARCHAR2
    , p12_a117  VARCHAR2
    , p12_a118  VARCHAR2
    , p12_a119  VARCHAR2
    , p12_a120  VARCHAR2
    , p12_a121  VARCHAR2
    , p12_a122  VARCHAR2
    , p12_a123  VARCHAR2
    , p12_a124  VARCHAR2
    , p12_a125  VARCHAR2
    , p12_a126  VARCHAR2
    , p12_a127  VARCHAR2
    , p12_a128  VARCHAR2
    , p12_a129  NUMBER
    , p12_a130  VARCHAR2
    , p12_a131  NUMBER
    , p12_a132  VARCHAR2
    , p12_a133  VARCHAR2
    , p12_a134  VARCHAR2
    , p12_a135  NUMBER
    , p12_a136  NUMBER
    , p12_a137  NUMBER
    , p12_a138  NUMBER
    , p12_a139  VARCHAR2
    , p12_a140  NUMBER
    , p12_a141  NUMBER
    , p12_a142  VARCHAR2
    , p12_a143  NUMBER
    , p12_a144  NUMBER
    , p12_a145  NUMBER
    , p12_a146  NUMBER
    , p12_a147  DATE
    , p12_a148  NUMBER
    , p12_a149  VARCHAR2
    , p12_a150  DATE
    , p12_a151  NUMBER
    , p12_a152  DATE
    , p12_a153  NUMBER
    , p12_a154  NUMBER
    , p12_a155  NUMBER
    , p12_a156  NUMBER
    , p12_a157  NUMBER
    , p12_a158  NUMBER
    , p12_a159  VARCHAR2
    , p12_a160  VARCHAR2
    , p12_a161  VARCHAR2
    , p12_a162  VARCHAR2
    , p12_a163  DATE
    , p12_a164  VARCHAR2
    , p12_a165  VARCHAR2
    , p12_a166  VARCHAR2
    , p12_a167  VARCHAR2
    , p12_a168  VARCHAR2
    , p12_a169  VARCHAR2
    , p12_a170  NUMBER
    , p12_a171  NUMBER
    , p12_a172  NUMBER
    , p12_a173  VARCHAR2
    , p12_a174  NUMBER
    , p12_a175  NUMBER
    , p12_a176  VARCHAR2
    , p12_a177  NUMBER
    , p12_a178  VARCHAR2
    , p12_a179  VARCHAR2
    , p12_a180  VARCHAR2
    , p12_a181  VARCHAR2
    , p12_a182  VARCHAR2
    , p12_a183  NUMBER
    , p12_a184  NUMBER
    , p12_a185  NUMBER
    , p12_a186  NUMBER
    , p12_a187  NUMBER
    , p12_a188  NUMBER
    , p12_a189  VARCHAR2
    , p12_a190  VARCHAR2
    , p_mass_adj_type  VARCHAR2
    , p14_a0  NUMBER
    , p14_a1  VARCHAR2
    , p14_a2  VARCHAR2
    , p14_a3  NUMBER
    , p14_a4  NUMBER
    , p14_a5  VARCHAR2
    , p14_a6  DATE
    , p14_a7  DATE
    , p14_a8  NUMBER
    , p14_a9  NUMBER
    , p14_a10  NUMBER
    , p14_a11  NUMBER
    , p14_a12  NUMBER
    , p14_a13  VARCHAR2
    , p14_a14  NUMBER
    , p14_a15  VARCHAR2
    , p14_a16  VARCHAR2
    , p14_a17  VARCHAR2
    , p14_a18  VARCHAR2
    , p14_a19  VARCHAR2
    , p14_a20  VARCHAR2
    , p14_a21  VARCHAR2
    , p14_a22  NUMBER
    , p14_a23  NUMBER
    , p14_a24  DATE
    , p14_a25  NUMBER
    , p14_a26  NUMBER
    , p14_a27  DATE
    , p14_a28  VARCHAR2
    , p14_a29  VARCHAR2
    , p14_a30  VARCHAR2
    , p14_a31  VARCHAR2
    , p14_a32  VARCHAR2
    , p14_a33  VARCHAR2
    , p14_a34  VARCHAR2
    , p14_a35  VARCHAR2
    , p14_a36  VARCHAR2
    , p14_a37  VARCHAR2
    , p14_a38  VARCHAR2
    , p14_a39  VARCHAR2
    , p14_a40  VARCHAR2
    , p14_a41  VARCHAR2
    , p14_a42  VARCHAR2
    , p14_a43  VARCHAR2
    , p14_a44  VARCHAR2
    , p14_a45  VARCHAR2
    , p14_a46  VARCHAR2
    , p14_a47  VARCHAR2
    , p14_a48  VARCHAR2
    , p14_a49  VARCHAR2
    , p14_a50  VARCHAR2
    , p14_a51  VARCHAR2
    , p14_a52  VARCHAR2
    , p14_a53  VARCHAR2
    , p14_a54  VARCHAR2
    , p14_a55  VARCHAR2
    , p14_a56  VARCHAR2
    , p14_a57  VARCHAR2
    , p14_a58  VARCHAR2
    , p14_a59  VARCHAR2
    , p14_a60  VARCHAR2
    , p14_a61  VARCHAR2
    , p14_a62  VARCHAR2
    , p14_a63  VARCHAR2
    , p14_a64  VARCHAR2
    , p14_a65  VARCHAR2
    , p14_a66  VARCHAR2
    , p14_a67  VARCHAR2
    , p14_a68  VARCHAR2
    , p14_a69  VARCHAR2
    , p14_a70  VARCHAR2
    , p14_a71  VARCHAR2
    , p14_a72  VARCHAR2
    , p14_a73  VARCHAR2
    , p14_a74  VARCHAR2
    , p14_a75  VARCHAR2
    , p14_a76  VARCHAR2
    , p14_a77  VARCHAR2
    , p14_a78  VARCHAR2
    , p14_a79  VARCHAR2
    , p14_a80  VARCHAR2
    , p14_a81  VARCHAR2
    , p14_a82  VARCHAR2
    , p14_a83  VARCHAR2
    , p14_a84  VARCHAR2
    , p14_a85  VARCHAR2
    , p14_a86  VARCHAR2
    , p14_a87  VARCHAR2
    , p14_a88  VARCHAR2
    , p14_a89  VARCHAR2
    , p14_a90  VARCHAR2
    , p14_a91  VARCHAR2
    , p14_a92  VARCHAR2
    , p14_a93  VARCHAR2
    , p14_a94  VARCHAR2
    , p14_a95  VARCHAR2
    , p14_a96  VARCHAR2
    , p14_a97  VARCHAR2
    , p14_a98  VARCHAR2
    , p14_a99  VARCHAR2
    , p14_a100  VARCHAR2
    , p14_a101  VARCHAR2
    , p14_a102  VARCHAR2
    , p14_a103  VARCHAR2
    , p14_a104  VARCHAR2
    , p14_a105  VARCHAR2
    , p14_a106  VARCHAR2
    , p14_a107  VARCHAR2
    , p14_a108  VARCHAR2
    , p14_a109  VARCHAR2
    , p14_a110  VARCHAR2
    , p14_a111  VARCHAR2
    , p14_a112  VARCHAR2
    , p14_a113  VARCHAR2
    , p14_a114  VARCHAR2
    , p14_a115  VARCHAR2
    , p14_a116  VARCHAR2
    , p14_a117  VARCHAR2
    , p14_a118  VARCHAR2
    , p14_a119  VARCHAR2
    , p14_a120  VARCHAR2
    , p14_a121  VARCHAR2
    , p14_a122  VARCHAR2
    , p14_a123  VARCHAR2
    , p14_a124  VARCHAR2
    , p14_a125  VARCHAR2
    , p14_a126  VARCHAR2
    , p14_a127  VARCHAR2
    , p14_a128  VARCHAR2
    , p14_a129  NUMBER
    , p14_a130  VARCHAR2
    , p14_a131  NUMBER
    , p14_a132  VARCHAR2
    , p14_a133  VARCHAR2
    , p14_a134  VARCHAR2
    , p14_a135  NUMBER
    , p14_a136  NUMBER
    , p14_a137  NUMBER
    , p14_a138  NUMBER
    , p14_a139  VARCHAR2
    , p14_a140  NUMBER
    , p14_a141  NUMBER
    , p14_a142  VARCHAR2
    , p14_a143  NUMBER
    , p14_a144  NUMBER
    , p14_a145  NUMBER
    , p14_a146  NUMBER
    , p14_a147  DATE
    , p14_a148  NUMBER
    , p14_a149  VARCHAR2
    , p14_a150  DATE
    , p14_a151  NUMBER
    , p14_a152  DATE
    , p14_a153  NUMBER
    , p14_a154  NUMBER
    , p14_a155  NUMBER
    , p14_a156  NUMBER
    , p14_a157  NUMBER
    , p14_a158  NUMBER
    , p14_a159  VARCHAR2
    , p14_a160  VARCHAR2
    , p14_a161  VARCHAR2
    , p14_a162  VARCHAR2
    , p14_a163  DATE
    , p14_a164  VARCHAR2
    , p14_a165  VARCHAR2
    , p14_a166  VARCHAR2
    , p14_a167  VARCHAR2
    , p14_a168  VARCHAR2
    , p14_a169  VARCHAR2
    , p14_a170  NUMBER
    , p14_a171  NUMBER
    , p14_a172  NUMBER
    , p14_a173  VARCHAR2
    , p14_a174  NUMBER
    , p14_a175  NUMBER
    , p14_a176  VARCHAR2
    , p14_a177  NUMBER
    , p14_a178  VARCHAR2
    , p14_a179  VARCHAR2
    , p14_a180  VARCHAR2
    , p14_a181  VARCHAR2
    , p14_a182  VARCHAR2
    , p14_a183  NUMBER
    , p14_a184  NUMBER
    , p14_a185  NUMBER
    , p14_a186  NUMBER
    , p14_a187  NUMBER
    , p14_a188  NUMBER
    , p14_a189  VARCHAR2
    , p14_a190  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure call_split(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_split_type  VARCHAR2
    , p_from_salesrep_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p_comm_lines_api_id  NUMBER
    , p_invoice_number  VARCHAR2
    , p_order_number  NUMBER
    , p_transaction_amount  NUMBER
    , p_adjusted_by  VARCHAR2
    , p_adjust_comments  VARCHAR2
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure get_trx_lines(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_header_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_NUMBER_TABLE
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , x_tbl_count out nocopy  NUMBER
  );
  procedure get_trx_history(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_adj_comm_lines_api_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_DATE_TABLE
    , p8_a7 out nocopy JTF_DATE_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_1800
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a114 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a115 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a116 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a117 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a118 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a119 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a120 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a121 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a122 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a123 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a124 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a125 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a126 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a127 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a128 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a129 out nocopy JTF_NUMBER_TABLE
    , p8_a130 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a131 out nocopy JTF_NUMBER_TABLE
    , p8_a132 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a133 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a134 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a135 out nocopy JTF_NUMBER_TABLE
    , p8_a136 out nocopy JTF_NUMBER_TABLE
    , p8_a137 out nocopy JTF_NUMBER_TABLE
    , p8_a138 out nocopy JTF_NUMBER_TABLE
    , p8_a139 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a140 out nocopy JTF_NUMBER_TABLE
    , p8_a141 out nocopy JTF_NUMBER_TABLE
    , p8_a142 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a143 out nocopy JTF_NUMBER_TABLE
    , p8_a144 out nocopy JTF_NUMBER_TABLE
    , p8_a145 out nocopy JTF_NUMBER_TABLE
    , p8_a146 out nocopy JTF_NUMBER_TABLE
    , p8_a147 out nocopy JTF_DATE_TABLE
    , p8_a148 out nocopy JTF_NUMBER_TABLE
    , p8_a149 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a150 out nocopy JTF_DATE_TABLE
    , p8_a151 out nocopy JTF_NUMBER_TABLE
    , p8_a152 out nocopy JTF_DATE_TABLE
    , p8_a153 out nocopy JTF_NUMBER_TABLE
    , p8_a154 out nocopy JTF_NUMBER_TABLE
    , p8_a155 out nocopy JTF_NUMBER_TABLE
    , p8_a156 out nocopy JTF_NUMBER_TABLE
    , p8_a157 out nocopy JTF_NUMBER_TABLE
    , p8_a158 out nocopy JTF_NUMBER_TABLE
    , p8_a159 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a160 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a161 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a162 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a163 out nocopy JTF_DATE_TABLE
    , p8_a164 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a165 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a166 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a168 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a169 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a170 out nocopy JTF_NUMBER_TABLE
    , p8_a171 out nocopy JTF_NUMBER_TABLE
    , p8_a172 out nocopy JTF_NUMBER_TABLE
    , p8_a173 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a174 out nocopy JTF_NUMBER_TABLE
    , p8_a175 out nocopy JTF_NUMBER_TABLE
    , p8_a176 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a177 out nocopy JTF_NUMBER_TABLE
    , p8_a178 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a179 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a180 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a181 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a182 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a183 out nocopy JTF_NUMBER_TABLE
    , p8_a184 out nocopy JTF_NUMBER_TABLE
    , p8_a185 out nocopy JTF_NUMBER_TABLE
    , p8_a186 out nocopy JTF_NUMBER_TABLE
    , p8_a187 out nocopy JTF_NUMBER_TABLE
    , p8_a188 out nocopy JTF_NUMBER_TABLE
    , p8_a189 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , x_adj_count out nocopy  NUMBER
  );
  procedure get_cust_info(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p_comm_lines_api_id  NUMBER
    , p_load_status  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  VARCHAR2
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  VARCHAR2
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  VARCHAR2
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  NUMBER
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  NUMBER
    , p9_a22 out nocopy  VARCHAR2
  );
  procedure update_api_record(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  NUMBER
    , p3_a5  VARCHAR2
    , p3_a6  DATE
    , p3_a7  DATE
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  NUMBER
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  DATE
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  DATE
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  VARCHAR2
    , p3_a81  VARCHAR2
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  VARCHAR2
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  VARCHAR2
    , p3_a106  VARCHAR2
    , p3_a107  VARCHAR2
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  VARCHAR2
    , p3_a113  VARCHAR2
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  VARCHAR2
    , p3_a118  VARCHAR2
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  VARCHAR2
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  VARCHAR2
    , p3_a129  NUMBER
    , p3_a130  VARCHAR2
    , p3_a131  NUMBER
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  NUMBER
    , p3_a137  NUMBER
    , p3_a138  NUMBER
    , p3_a139  VARCHAR2
    , p3_a140  NUMBER
    , p3_a141  NUMBER
    , p3_a142  VARCHAR2
    , p3_a143  NUMBER
    , p3_a144  NUMBER
    , p3_a145  NUMBER
    , p3_a146  NUMBER
    , p3_a147  DATE
    , p3_a148  NUMBER
    , p3_a149  VARCHAR2
    , p3_a150  DATE
    , p3_a151  NUMBER
    , p3_a152  DATE
    , p3_a153  NUMBER
    , p3_a154  NUMBER
    , p3_a155  NUMBER
    , p3_a156  NUMBER
    , p3_a157  NUMBER
    , p3_a158  NUMBER
    , p3_a159  VARCHAR2
    , p3_a160  VARCHAR2
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  DATE
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p3_a170  NUMBER
    , p3_a171  NUMBER
    , p3_a172  NUMBER
    , p3_a173  VARCHAR2
    , p3_a174  NUMBER
    , p3_a175  NUMBER
    , p3_a176  VARCHAR2
    , p3_a177  NUMBER
    , p3_a178  VARCHAR2
    , p3_a179  VARCHAR2
    , p3_a180  VARCHAR2
    , p3_a181  VARCHAR2
    , p3_a182  VARCHAR2
    , p3_a183  NUMBER
    , p3_a184  NUMBER
    , p3_a185  NUMBER
    , p3_a186  NUMBER
    , p3_a187  NUMBER
    , p3_a188  NUMBER
    , p3_a189  VARCHAR2
    , p3_a190  VARCHAR2
    , x_api_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
end cn_get_tx_data_pub_w;

 

/
