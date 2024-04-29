--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cssrrsws.pls 120.3.12010000.4 2010/04/04 04:03:02 rgandhi ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cs_servicerequest_pub.notes_table, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_32767
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cs_servicerequest_pub.notes_table, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_32767
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy cs_servicerequest_pub.contacts_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p3(t cs_servicerequest_pub.contacts_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy cs_servicerequest_pub.ext_attr_grp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t cs_servicerequest_pub.ext_attr_grp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p10(t out nocopy cs_servicerequest_pub.ext_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_4000
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_4000
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p10(t cs_servicerequest_pub.ext_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_4000
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_4000
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p11(t out nocopy cs_servicerequest_pub.resource_validate_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p11(t cs_servicerequest_pub.resource_validate_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p13(t out nocopy cs_servicerequest_pub.vc2_table, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p13(t cs_servicerequest_pub.vc2_table, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure initialize_rec(p0_a0 in out nocopy  DATE
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  DATE
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  NUMBER
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  VARCHAR2
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  VARCHAR2
    , p0_a36 in out nocopy  VARCHAR2
    , p0_a37 in out nocopy  VARCHAR2
    , p0_a38 in out nocopy  VARCHAR2
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  VARCHAR2
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  NUMBER
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  NUMBER
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  DATE
    , p0_a61 in out nocopy  NUMBER
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  VARCHAR2
    , p0_a69 in out nocopy  VARCHAR2
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  VARCHAR2
    , p0_a78 in out nocopy  VARCHAR2
    , p0_a79 in out nocopy  VARCHAR2
    , p0_a80 in out nocopy  VARCHAR2
    , p0_a81 in out nocopy  VARCHAR2
    , p0_a82 in out nocopy  VARCHAR2
    , p0_a83 in out nocopy  VARCHAR2
    , p0_a84 in out nocopy  VARCHAR2
    , p0_a85 in out nocopy  VARCHAR2
    , p0_a86 in out nocopy  VARCHAR2
    , p0_a87 in out nocopy  VARCHAR2
    , p0_a88 in out nocopy  VARCHAR2
    , p0_a89 in out nocopy  VARCHAR2
    , p0_a90 in out nocopy  VARCHAR2
    , p0_a91 in out nocopy  VARCHAR2
    , p0_a92 in out nocopy  VARCHAR2
    , p0_a93 in out nocopy  VARCHAR2
    , p0_a94 in out nocopy  NUMBER
    , p0_a95 in out nocopy  NUMBER
    , p0_a96 in out nocopy  NUMBER
    , p0_a97 in out nocopy  NUMBER
    , p0_a98 in out nocopy  VARCHAR2
    , p0_a99 in out nocopy  DATE
    , p0_a100 in out nocopy  VARCHAR2
    , p0_a101 in out nocopy  NUMBER
    , p0_a102 in out nocopy  NUMBER
    , p0_a103 in out nocopy  VARCHAR2
    , p0_a104 in out nocopy  NUMBER
    , p0_a105 in out nocopy  VARCHAR2
    , p0_a106 in out nocopy  NUMBER
    , p0_a107 in out nocopy  NUMBER
    , p0_a108 in out nocopy  VARCHAR2
    , p0_a109 in out nocopy  NUMBER
    , p0_a110 in out nocopy  VARCHAR2
    , p0_a111 in out nocopy  VARCHAR2
    , p0_a112 in out nocopy  VARCHAR2
    , p0_a113 in out nocopy  DATE
    , p0_a114 in out nocopy  NUMBER
    , p0_a115 in out nocopy  NUMBER
    , p0_a116 in out nocopy  NUMBER
    , p0_a117 in out nocopy  NUMBER
    , p0_a118 in out nocopy  NUMBER
    , p0_a119 in out nocopy  VARCHAR2
    , p0_a120 in out nocopy  NUMBER
    , p0_a121 in out nocopy  VARCHAR2
    , p0_a122 in out nocopy  NUMBER
    , p0_a123 in out nocopy  VARCHAR2
    , p0_a124 in out nocopy  NUMBER
    , p0_a125 in out nocopy  VARCHAR2
    , p0_a126 in out nocopy  VARCHAR2
    , p0_a127 in out nocopy  VARCHAR2
    , p0_a128 in out nocopy  VARCHAR2
    , p0_a129 in out nocopy  VARCHAR2
    , p0_a130 in out nocopy  VARCHAR2
    , p0_a131 in out nocopy  NUMBER
    , p0_a132 in out nocopy  NUMBER
    , p0_a133 in out nocopy  VARCHAR2
    , p0_a134 in out nocopy  NUMBER
    , p0_a135 in out nocopy  NUMBER
    , p0_a136 in out nocopy  VARCHAR2
    , p0_a137 in out nocopy  VARCHAR2
    , p0_a138 in out nocopy  VARCHAR2
    , p0_a139 in out nocopy  VARCHAR2
    , p0_a140 in out nocopy  VARCHAR2
    , p0_a141 in out nocopy  VARCHAR2
    , p0_a142 in out nocopy  NUMBER
    , p0_a143 in out nocopy  VARCHAR2
    , p0_a144 in out nocopy  NUMBER
    , p0_a145 in out nocopy  VARCHAR2
    , p0_a146 in out nocopy  DATE
    , p0_a147 in out nocopy  DATE
    , p0_a148 in out nocopy  DATE
    , p0_a149 in out nocopy  VARCHAR2
    , p0_a150 in out nocopy  NUMBER
    , p0_a151 in out nocopy  VARCHAR2
    , p0_a152 in out nocopy  VARCHAR2
    , p0_a153 in out nocopy  VARCHAR2
    , p0_a154 in out nocopy  VARCHAR2
    , p0_a155 in out nocopy  VARCHAR2
    , p0_a156 in out nocopy  VARCHAR2
    , p0_a157 in out nocopy  VARCHAR2
    , p0_a158 in out nocopy  VARCHAR2
    , p0_a159 in out nocopy  VARCHAR2
    , p0_a160 in out nocopy  VARCHAR2
    , p0_a161 in out nocopy  VARCHAR2
    , p0_a162 in out nocopy  VARCHAR2
    , p0_a163 in out nocopy  VARCHAR2
    , p0_a164 in out nocopy  DATE
    , p0_a165 in out nocopy  VARCHAR
    , p0_a166 in out nocopy  VARCHAR
    , p0_a167 in out nocopy  VARCHAR
    , p0_a168 in out nocopy  VARCHAR
    , p0_a169 in out nocopy  NUMBER
    , p0_a170 in out nocopy  NUMBER
    , p0_a171 in out nocopy  NUMBER
    , p0_a172 in out nocopy  NUMBER
    , p0_a173 in out nocopy  NUMBER
    , p0_a174 in out nocopy  VARCHAR2
    , p0_a175 in out nocopy  VARCHAR2
    , p0_a176 in out nocopy  NUMBER
    , p0_a177 in out nocopy  NUMBER
    , p0_a178 in out nocopy  NUMBER
    , p0_a179 in out nocopy  NUMBER
    , p0_a180 in out nocopy  NUMBER
    , p0_a181 in out nocopy  NUMBER
    , p0_a182 in out nocopy  NUMBER
    , p0_a183 in out nocopy  NUMBER
    , p0_a184 in out nocopy  VARCHAR2
    , p0_a185 in out nocopy  VARCHAR2
    , p0_a186 in out nocopy  VARCHAR2
    , p0_a187 in out nocopy  VARCHAR2
    , p0_a188 in out nocopy  VARCHAR2
    , p0_a189 in out nocopy  VARCHAR2
    , p0_a190 in out nocopy  VARCHAR2
    , p0_a191 in out nocopy  VARCHAR2
    , p0_a192 in out nocopy  VARCHAR2
    , p0_a193 in out nocopy  VARCHAR2
    , p0_a194 in out nocopy  VARCHAR2
    , p0_a195 in out nocopy  VARCHAR2
    , p0_a196 in out nocopy  VARCHAR2
    , p0_a197 in out nocopy  VARCHAR2
    , p0_a198 in out nocopy  VARCHAR2
    , p0_a199 in out nocopy  VARCHAR2
    , p0_a200 in out nocopy  VARCHAR2
    , p0_a201 in out nocopy  VARCHAR2
    , p0_a202 in out nocopy  VARCHAR2
    , p0_a203 in out nocopy  VARCHAR2
    , p0_a204 in out nocopy  VARCHAR2
    , p0_a205 in out nocopy  NUMBER
    , p0_a206 in out nocopy  VARCHAR2
    , p0_a207 in out nocopy  NUMBER
    , p0_a208 in out nocopy  VARCHAR2
    , p0_a209 in out nocopy  VARCHAR2
    , p0_a210 in out nocopy  NUMBER
    , p0_a211 in out nocopy  DATE
    , p0_a212 in out nocopy  NUMBER
    , p0_a213 in out nocopy  NUMBER
  );
  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_auto_assign  VARCHAR2
    , p_auto_generate_tasks  VARCHAR2
    , p18_a0 out nocopy  NUMBER
    , p18_a1 out nocopy  VARCHAR2
    , p18_a2 out nocopy  NUMBER
    , p18_a3 out nocopy  NUMBER
    , p18_a4 out nocopy  NUMBER
    , p18_a5 out nocopy  NUMBER
    , p18_a6 out nocopy  VARCHAR2
    , p18_a7 out nocopy  VARCHAR2
    , p18_a8 out nocopy  NUMBER
    , p18_a9 out nocopy  NUMBER
    , p18_a10 out nocopy  NUMBER
    , p18_a11 out nocopy  DATE
    , p18_a12 out nocopy  DATE
    , p18_a13 out nocopy  DATE
    , p18_a14 out nocopy  DATE
    , p18_a15 out nocopy  NUMBER
    , p_default_contract_sla_ind  VARCHAR2
    , p_default_coverage_template_id  NUMBER
  );
  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_auto_assign  VARCHAR2
    , p_default_contract_sla_ind  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
    , x_individual_owner out nocopy  NUMBER
    , x_group_owner out nocopy  NUMBER
    , x_individual_type out nocopy  VARCHAR2
  );
  procedure update_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  VARCHAR2
    , p15_a79  VARCHAR2
    , p15_a80  VARCHAR2
    , p15_a81  VARCHAR2
    , p15_a82  VARCHAR2
    , p15_a83  VARCHAR2
    , p15_a84  VARCHAR2
    , p15_a85  VARCHAR2
    , p15_a86  VARCHAR2
    , p15_a87  VARCHAR2
    , p15_a88  VARCHAR2
    , p15_a89  VARCHAR2
    , p15_a90  VARCHAR2
    , p15_a91  VARCHAR2
    , p15_a92  VARCHAR2
    , p15_a93  VARCHAR2
    , p15_a94  NUMBER
    , p15_a95  NUMBER
    , p15_a96  NUMBER
    , p15_a97  NUMBER
    , p15_a98  VARCHAR2
    , p15_a99  DATE
    , p15_a100  VARCHAR2
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  NUMBER
    , p15_a108  VARCHAR2
    , p15_a109  NUMBER
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  DATE
    , p15_a114  NUMBER
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  NUMBER
    , p15_a118  NUMBER
    , p15_a119  VARCHAR2
    , p15_a120  NUMBER
    , p15_a121  VARCHAR2
    , p15_a122  NUMBER
    , p15_a123  VARCHAR2
    , p15_a124  NUMBER
    , p15_a125  VARCHAR2
    , p15_a126  VARCHAR2
    , p15_a127  VARCHAR2
    , p15_a128  VARCHAR2
    , p15_a129  VARCHAR2
    , p15_a130  VARCHAR2
    , p15_a131  NUMBER
    , p15_a132  NUMBER
    , p15_a133  VARCHAR2
    , p15_a134  NUMBER
    , p15_a135  NUMBER
    , p15_a136  VARCHAR2
    , p15_a137  VARCHAR2
    , p15_a138  VARCHAR2
    , p15_a139  VARCHAR2
    , p15_a140  VARCHAR2
    , p15_a141  VARCHAR2
    , p15_a142  NUMBER
    , p15_a143  VARCHAR2
    , p15_a144  NUMBER
    , p15_a145  VARCHAR2
    , p15_a146  DATE
    , p15_a147  DATE
    , p15_a148  DATE
    , p15_a149  VARCHAR2
    , p15_a150  NUMBER
    , p15_a151  VARCHAR2
    , p15_a152  VARCHAR2
    , p15_a153  VARCHAR2
    , p15_a154  VARCHAR2
    , p15_a155  VARCHAR2
    , p15_a156  VARCHAR2
    , p15_a157  VARCHAR2
    , p15_a158  VARCHAR2
    , p15_a159  VARCHAR2
    , p15_a160  VARCHAR2
    , p15_a161  VARCHAR2
    , p15_a162  VARCHAR2
    , p15_a163  VARCHAR2
    , p15_a164  DATE
    , p15_a165  VARCHAR
    , p15_a166  VARCHAR
    , p15_a167  VARCHAR
    , p15_a168  VARCHAR
    , p15_a169  NUMBER
    , p15_a170  NUMBER
    , p15_a171  NUMBER
    , p15_a172  NUMBER
    , p15_a173  NUMBER
    , p15_a174  VARCHAR2
    , p15_a175  VARCHAR2
    , p15_a176  NUMBER
    , p15_a177  NUMBER
    , p15_a178  NUMBER
    , p15_a179  NUMBER
    , p15_a180  NUMBER
    , p15_a181  NUMBER
    , p15_a182  NUMBER
    , p15_a183  NUMBER
    , p15_a184  VARCHAR2
    , p15_a185  VARCHAR2
    , p15_a186  VARCHAR2
    , p15_a187  VARCHAR2
    , p15_a188  VARCHAR2
    , p15_a189  VARCHAR2
    , p15_a190  VARCHAR2
    , p15_a191  VARCHAR2
    , p15_a192  VARCHAR2
    , p15_a193  VARCHAR2
    , p15_a194  VARCHAR2
    , p15_a195  VARCHAR2
    , p15_a196  VARCHAR2
    , p15_a197  VARCHAR2
    , p15_a198  VARCHAR2
    , p15_a199  VARCHAR2
    , p15_a200  VARCHAR2
    , p15_a201  VARCHAR2
    , p15_a202  VARCHAR2
    , p15_a203  VARCHAR2
    , p15_a204  VARCHAR2
    , p15_a205  NUMBER
    , p15_a206  VARCHAR2
    , p15_a207  NUMBER
    , p15_a208  VARCHAR2
    , p15_a209  VARCHAR2
    , p15_a210  NUMBER
    , p15_a211  DATE
    , p15_a212  NUMBER
    , p15_a213  NUMBER
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p17_a6 JTF_VARCHAR2_TABLE_100
    , p17_a7 JTF_DATE_TABLE
    , p17_a8 JTF_DATE_TABLE
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_auto_assign  VARCHAR2
    , p_validate_sr_closure  VARCHAR2
    , p_auto_close_child_entities  VARCHAR2
    , p_default_contract_sla_ind  VARCHAR2
    , p24_a0 out nocopy  NUMBER
    , p24_a1 out nocopy  NUMBER
    , p24_a2 out nocopy  NUMBER
    , p24_a3 out nocopy  NUMBER
    , p24_a4 out nocopy  VARCHAR2
    , p24_a5 out nocopy  DATE
    , p24_a6 out nocopy  DATE
    , p24_a7 out nocopy  NUMBER
    , p24_a8 out nocopy  DATE
    , p24_a9 out nocopy  NUMBER
  );
  procedure update_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  VARCHAR2
    , p15_a79  VARCHAR2
    , p15_a80  VARCHAR2
    , p15_a81  VARCHAR2
    , p15_a82  VARCHAR2
    , p15_a83  VARCHAR2
    , p15_a84  VARCHAR2
    , p15_a85  VARCHAR2
    , p15_a86  VARCHAR2
    , p15_a87  VARCHAR2
    , p15_a88  VARCHAR2
    , p15_a89  VARCHAR2
    , p15_a90  VARCHAR2
    , p15_a91  VARCHAR2
    , p15_a92  VARCHAR2
    , p15_a93  VARCHAR2
    , p15_a94  NUMBER
    , p15_a95  NUMBER
    , p15_a96  NUMBER
    , p15_a97  NUMBER
    , p15_a98  VARCHAR2
    , p15_a99  DATE
    , p15_a100  VARCHAR2
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  NUMBER
    , p15_a108  VARCHAR2
    , p15_a109  NUMBER
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  DATE
    , p15_a114  NUMBER
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  NUMBER
    , p15_a118  NUMBER
    , p15_a119  VARCHAR2
    , p15_a120  NUMBER
    , p15_a121  VARCHAR2
    , p15_a122  NUMBER
    , p15_a123  VARCHAR2
    , p15_a124  NUMBER
    , p15_a125  VARCHAR2
    , p15_a126  VARCHAR2
    , p15_a127  VARCHAR2
    , p15_a128  VARCHAR2
    , p15_a129  VARCHAR2
    , p15_a130  VARCHAR2
    , p15_a131  NUMBER
    , p15_a132  NUMBER
    , p15_a133  VARCHAR2
    , p15_a134  NUMBER
    , p15_a135  NUMBER
    , p15_a136  VARCHAR2
    , p15_a137  VARCHAR2
    , p15_a138  VARCHAR2
    , p15_a139  VARCHAR2
    , p15_a140  VARCHAR2
    , p15_a141  VARCHAR2
    , p15_a142  NUMBER
    , p15_a143  VARCHAR2
    , p15_a144  NUMBER
    , p15_a145  VARCHAR2
    , p15_a146  DATE
    , p15_a147  DATE
    , p15_a148  DATE
    , p15_a149  VARCHAR2
    , p15_a150  NUMBER
    , p15_a151  VARCHAR2
    , p15_a152  VARCHAR2
    , p15_a153  VARCHAR2
    , p15_a154  VARCHAR2
    , p15_a155  VARCHAR2
    , p15_a156  VARCHAR2
    , p15_a157  VARCHAR2
    , p15_a158  VARCHAR2
    , p15_a159  VARCHAR2
    , p15_a160  VARCHAR2
    , p15_a161  VARCHAR2
    , p15_a162  VARCHAR2
    , p15_a163  VARCHAR2
    , p15_a164  DATE
    , p15_a165  VARCHAR
    , p15_a166  VARCHAR
    , p15_a167  VARCHAR
    , p15_a168  VARCHAR
    , p15_a169  NUMBER
    , p15_a170  NUMBER
    , p15_a171  NUMBER
    , p15_a172  NUMBER
    , p15_a173  NUMBER
    , p15_a174  VARCHAR2
    , p15_a175  VARCHAR2
    , p15_a176  NUMBER
    , p15_a177  NUMBER
    , p15_a178  NUMBER
    , p15_a179  NUMBER
    , p15_a180  NUMBER
    , p15_a181  NUMBER
    , p15_a182  NUMBER
    , p15_a183  NUMBER
    , p15_a184  VARCHAR2
    , p15_a185  VARCHAR2
    , p15_a186  VARCHAR2
    , p15_a187  VARCHAR2
    , p15_a188  VARCHAR2
    , p15_a189  VARCHAR2
    , p15_a190  VARCHAR2
    , p15_a191  VARCHAR2
    , p15_a192  VARCHAR2
    , p15_a193  VARCHAR2
    , p15_a194  VARCHAR2
    , p15_a195  VARCHAR2
    , p15_a196  VARCHAR2
    , p15_a197  VARCHAR2
    , p15_a198  VARCHAR2
    , p15_a199  VARCHAR2
    , p15_a200  VARCHAR2
    , p15_a201  VARCHAR2
    , p15_a202  VARCHAR2
    , p15_a203  VARCHAR2
    , p15_a204  VARCHAR2
    , p15_a205  NUMBER
    , p15_a206  VARCHAR2
    , p15_a207  NUMBER
    , p15_a208  VARCHAR2
    , p15_a209  VARCHAR2
    , p15_a210  NUMBER
    , p15_a211  DATE
    , p15_a212  NUMBER
    , p15_a213  NUMBER
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p17_a6 JTF_VARCHAR2_TABLE_100
    , p17_a7 JTF_DATE_TABLE
    , p17_a8 JTF_DATE_TABLE
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_default_contract_sla_ind  VARCHAR2
    , x_workflow_process_id out nocopy  NUMBER
    , x_interaction_id out nocopy  NUMBER
  );
  procedure update_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_object_version_number  NUMBER
    , p_status_id  NUMBER
    , p_status  VARCHAR2
    , p_closed_date  date
    , p_audit_comments  VARCHAR2
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , p_comments  VARCHAR2
    , p_public_comment_flag  VARCHAR2
    , p_validate_sr_closure  VARCHAR2
    , p_auto_close_child_entities  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
  );
  procedure create_servicerequest(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  VARCHAR2
    , p13_a79  VARCHAR2
    , p13_a80  VARCHAR2
    , p13_a81  VARCHAR2
    , p13_a82  VARCHAR2
    , p13_a83  VARCHAR2
    , p13_a84  VARCHAR2
    , p13_a85  VARCHAR2
    , p13_a86  VARCHAR2
    , p13_a87  VARCHAR2
    , p13_a88  VARCHAR2
    , p13_a89  VARCHAR2
    , p13_a90  VARCHAR2
    , p13_a91  VARCHAR2
    , p13_a92  VARCHAR2
    , p13_a93  VARCHAR2
    , p13_a94  NUMBER
    , p13_a95  NUMBER
    , p13_a96  NUMBER
    , p13_a97  NUMBER
    , p13_a98  VARCHAR2
    , p13_a99  DATE
    , p13_a100  VARCHAR2
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  NUMBER
    , p13_a108  VARCHAR2
    , p13_a109  NUMBER
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  DATE
    , p13_a114  NUMBER
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  NUMBER
    , p13_a118  NUMBER
    , p13_a119  VARCHAR2
    , p13_a120  NUMBER
    , p13_a121  VARCHAR2
    , p13_a122  NUMBER
    , p13_a123  VARCHAR2
    , p13_a124  NUMBER
    , p13_a125  VARCHAR2
    , p13_a126  VARCHAR2
    , p13_a127  VARCHAR2
    , p13_a128  VARCHAR2
    , p13_a129  VARCHAR2
    , p13_a130  VARCHAR2
    , p13_a131  NUMBER
    , p13_a132  NUMBER
    , p13_a133  VARCHAR2
    , p13_a134  NUMBER
    , p13_a135  NUMBER
    , p13_a136  VARCHAR2
    , p13_a137  VARCHAR2
    , p13_a138  VARCHAR2
    , p13_a139  VARCHAR2
    , p13_a140  VARCHAR2
    , p13_a141  VARCHAR2
    , p13_a142  NUMBER
    , p13_a143  VARCHAR2
    , p13_a144  NUMBER
    , p13_a145  VARCHAR2
    , p13_a146  DATE
    , p13_a147  DATE
    , p13_a148  DATE
    , p13_a149  VARCHAR2
    , p13_a150  NUMBER
    , p13_a151  VARCHAR2
    , p13_a152  VARCHAR2
    , p13_a153  VARCHAR2
    , p13_a154  VARCHAR2
    , p13_a155  VARCHAR2
    , p13_a156  VARCHAR2
    , p13_a157  VARCHAR2
    , p13_a158  VARCHAR2
    , p13_a159  VARCHAR2
    , p13_a160  VARCHAR2
    , p13_a161  VARCHAR2
    , p13_a162  VARCHAR2
    , p13_a163  VARCHAR2
    , p13_a164  DATE
    , p13_a165  VARCHAR
    , p13_a166  VARCHAR
    , p13_a167  VARCHAR
    , p13_a168  VARCHAR
    , p13_a169  NUMBER
    , p13_a170  NUMBER
    , p13_a171  NUMBER
    , p13_a172  NUMBER
    , p13_a173  NUMBER
    , p13_a174  VARCHAR2
    , p13_a175  VARCHAR2
    , p13_a176  NUMBER
    , p13_a177  NUMBER
    , p13_a178  NUMBER
    , p13_a179  NUMBER
    , p13_a180  NUMBER
    , p13_a181  NUMBER
    , p13_a182  NUMBER
    , p13_a183  NUMBER
    , p13_a184  VARCHAR2
    , p13_a185  VARCHAR2
    , p13_a186  VARCHAR2
    , p13_a187  VARCHAR2
    , p13_a188  VARCHAR2
    , p13_a189  VARCHAR2
    , p13_a190  VARCHAR2
    , p13_a191  VARCHAR2
    , p13_a192  VARCHAR2
    , p13_a193  VARCHAR2
    , p13_a194  VARCHAR2
    , p13_a195  VARCHAR2
    , p13_a196  VARCHAR2
    , p13_a197  VARCHAR2
    , p13_a198  VARCHAR2
    , p13_a199  VARCHAR2
    , p13_a200  VARCHAR2
    , p13_a201  VARCHAR2
    , p13_a202  VARCHAR2
    , p13_a203  VARCHAR2
    , p13_a204  VARCHAR2
    , p13_a205  NUMBER
    , p13_a206  VARCHAR2
    , p13_a207  NUMBER
    , p13_a208  VARCHAR2
    , p13_a209  VARCHAR2
    , p13_a210  NUMBER
    , p13_a211  DATE
    , p13_a212  NUMBER
    , p13_a213  NUMBER
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_VARCHAR2_TABLE_100
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_DATE_TABLE
    , p_default_contract_sla_ind  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
  );
  procedure process_sr_ext_attrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_incident_id  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_200
    , p4_a2 JTF_VARCHAR2_TABLE_200
    , p4_a3 JTF_VARCHAR2_TABLE_200
    , p4_a4 JTF_VARCHAR2_TABLE_200
    , p4_a5 JTF_VARCHAR2_TABLE_200
    , p4_a6 JTF_VARCHAR2_TABLE_200
    , p4_a7 JTF_VARCHAR2_TABLE_100
    , p4_a8 JTF_NUMBER_TABLE
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_VARCHAR2_TABLE_100
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_VARCHAR2_TABLE_200
    , p4_a13 JTF_VARCHAR2_TABLE_100
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_4000
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_4000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p_modified_by  NUMBER
    , p_modified_on  date
    , x_failed_row_id_list out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_errorcode out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cs_servicerequest_pub_w;

/
