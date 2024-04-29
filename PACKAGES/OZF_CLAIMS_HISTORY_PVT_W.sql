--------------------------------------------------------
--  DDL for Package OZF_CLAIMS_HISTORY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIMS_HISTORY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwchis.pls 115.3 2003/12/02 23:54:07 yizhang noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ozf_claims_history_pvt.claims_history_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_DATE_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_DATE_TABLE
    , a22 JTF_VARCHAR2_TABLE_2000
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_DATE_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_DATE_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_DATE_TABLE
    , a69 JTF_VARCHAR2_TABLE_100
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_NUMBER_TABLE
    , a75 JTF_DATE_TABLE
    , a76 JTF_VARCHAR2_TABLE_100
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_NUMBER_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_DATE_TABLE
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_VARCHAR2_TABLE_100
    , a84 JTF_DATE_TABLE
    , a85 JTF_NUMBER_TABLE
    , a86 JTF_DATE_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_DATE_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    , a93 JTF_VARCHAR2_TABLE_2000
    , a94 JTF_NUMBER_TABLE
    , a95 JTF_DATE_TABLE
    , a96 JTF_NUMBER_TABLE
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_VARCHAR2_TABLE_100
    , a99 JTF_VARCHAR2_TABLE_200
    , a100 JTF_VARCHAR2_TABLE_200
    , a101 JTF_VARCHAR2_TABLE_200
    , a102 JTF_VARCHAR2_TABLE_200
    , a103 JTF_VARCHAR2_TABLE_200
    , a104 JTF_VARCHAR2_TABLE_200
    , a105 JTF_VARCHAR2_TABLE_200
    , a106 JTF_VARCHAR2_TABLE_200
    , a107 JTF_VARCHAR2_TABLE_200
    , a108 JTF_VARCHAR2_TABLE_200
    , a109 JTF_VARCHAR2_TABLE_200
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_100
    , a115 JTF_VARCHAR2_TABLE_200
    , a116 JTF_VARCHAR2_TABLE_200
    , a117 JTF_VARCHAR2_TABLE_200
    , a118 JTF_VARCHAR2_TABLE_200
    , a119 JTF_VARCHAR2_TABLE_200
    , a120 JTF_VARCHAR2_TABLE_200
    , a121 JTF_VARCHAR2_TABLE_200
    , a122 JTF_VARCHAR2_TABLE_200
    , a123 JTF_VARCHAR2_TABLE_200
    , a124 JTF_VARCHAR2_TABLE_200
    , a125 JTF_VARCHAR2_TABLE_200
    , a126 JTF_VARCHAR2_TABLE_200
    , a127 JTF_VARCHAR2_TABLE_200
    , a128 JTF_VARCHAR2_TABLE_200
    , a129 JTF_VARCHAR2_TABLE_200
    , a130 JTF_NUMBER_TABLE
    , a131 JTF_VARCHAR2_TABLE_100
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_VARCHAR2_TABLE_100
    , a139 JTF_NUMBER_TABLE
    , a140 JTF_NUMBER_TABLE
    , a141 JTF_VARCHAR2_TABLE_300
    , a142 JTF_VARCHAR2_TABLE_300
    , a143 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ozf_claims_history_pvt.claims_history_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_DATE_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_DATE_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_DATE_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_DATE_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_NUMBER_TABLE
    , a75 out nocopy JTF_DATE_TABLE
    , a76 out nocopy JTF_VARCHAR2_TABLE_100
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_NUMBER_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_DATE_TABLE
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_VARCHAR2_TABLE_100
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_NUMBER_TABLE
    , a86 out nocopy JTF_DATE_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_DATE_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_NUMBER_TABLE
    , a93 out nocopy JTF_VARCHAR2_TABLE_2000
    , a94 out nocopy JTF_NUMBER_TABLE
    , a95 out nocopy JTF_DATE_TABLE
    , a96 out nocopy JTF_NUMBER_TABLE
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_VARCHAR2_TABLE_100
    , a99 out nocopy JTF_VARCHAR2_TABLE_200
    , a100 out nocopy JTF_VARCHAR2_TABLE_200
    , a101 out nocopy JTF_VARCHAR2_TABLE_200
    , a102 out nocopy JTF_VARCHAR2_TABLE_200
    , a103 out nocopy JTF_VARCHAR2_TABLE_200
    , a104 out nocopy JTF_VARCHAR2_TABLE_200
    , a105 out nocopy JTF_VARCHAR2_TABLE_200
    , a106 out nocopy JTF_VARCHAR2_TABLE_200
    , a107 out nocopy JTF_VARCHAR2_TABLE_200
    , a108 out nocopy JTF_VARCHAR2_TABLE_200
    , a109 out nocopy JTF_VARCHAR2_TABLE_200
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_100
    , a115 out nocopy JTF_VARCHAR2_TABLE_200
    , a116 out nocopy JTF_VARCHAR2_TABLE_200
    , a117 out nocopy JTF_VARCHAR2_TABLE_200
    , a118 out nocopy JTF_VARCHAR2_TABLE_200
    , a119 out nocopy JTF_VARCHAR2_TABLE_200
    , a120 out nocopy JTF_VARCHAR2_TABLE_200
    , a121 out nocopy JTF_VARCHAR2_TABLE_200
    , a122 out nocopy JTF_VARCHAR2_TABLE_200
    , a123 out nocopy JTF_VARCHAR2_TABLE_200
    , a124 out nocopy JTF_VARCHAR2_TABLE_200
    , a125 out nocopy JTF_VARCHAR2_TABLE_200
    , a126 out nocopy JTF_VARCHAR2_TABLE_200
    , a127 out nocopy JTF_VARCHAR2_TABLE_200
    , a128 out nocopy JTF_VARCHAR2_TABLE_200
    , a129 out nocopy JTF_VARCHAR2_TABLE_200
    , a130 out nocopy JTF_NUMBER_TABLE
    , a131 out nocopy JTF_VARCHAR2_TABLE_100
    , a132 out nocopy JTF_NUMBER_TABLE
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_VARCHAR2_TABLE_100
    , a139 out nocopy JTF_NUMBER_TABLE
    , a140 out nocopy JTF_NUMBER_TABLE
    , a141 out nocopy JTF_VARCHAR2_TABLE_300
    , a142 out nocopy JTF_VARCHAR2_TABLE_300
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  DATE
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  DATE
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  DATE
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  DATE
    , p7_a85  NUMBER
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  DATE
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  DATE
    , p7_a96  NUMBER
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  NUMBER
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  NUMBER
    , p7_a138  VARCHAR2
    , p7_a139  NUMBER
    , p7_a140  NUMBER
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , x_claim_history_id out nocopy  NUMBER
  );
  procedure update_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  DATE
    , p7_a18  DATE
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  NUMBER
    , p7_a54  NUMBER
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  DATE
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  DATE
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  DATE
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  DATE
    , p7_a85  NUMBER
    , p7_a86  DATE
    , p7_a87  NUMBER
    , p7_a88  DATE
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  VARCHAR2
    , p7_a94  NUMBER
    , p7_a95  DATE
    , p7_a96  NUMBER
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  VARCHAR2
    , p7_a101  VARCHAR2
    , p7_a102  VARCHAR2
    , p7_a103  VARCHAR2
    , p7_a104  VARCHAR2
    , p7_a105  VARCHAR2
    , p7_a106  VARCHAR2
    , p7_a107  VARCHAR2
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  VARCHAR2
    , p7_a112  VARCHAR2
    , p7_a113  VARCHAR2
    , p7_a114  VARCHAR2
    , p7_a115  VARCHAR2
    , p7_a116  VARCHAR2
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  NUMBER
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  NUMBER
    , p7_a138  VARCHAR2
    , p7_a139  NUMBER
    , p7_a140  NUMBER
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  );
  procedure validate_claims_history(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  NUMBER
    , p3_a11  VARCHAR2
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p3_a15  NUMBER
    , p3_a16  VARCHAR2
    , p3_a17  DATE
    , p3_a18  DATE
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  DATE
    , p3_a22  VARCHAR2
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  DATE
    , p3_a26  NUMBER
    , p3_a27  NUMBER
    , p3_a28  NUMBER
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  DATE
    , p3_a41  NUMBER
    , p3_a42  NUMBER
    , p3_a43  DATE
    , p3_a44  NUMBER
    , p3_a45  VARCHAR2
    , p3_a46  NUMBER
    , p3_a47  VARCHAR2
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  NUMBER
    , p3_a54  NUMBER
    , p3_a55  VARCHAR2
    , p3_a56  NUMBER
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  NUMBER
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  NUMBER
    , p3_a67  NUMBER
    , p3_a68  DATE
    , p3_a69  VARCHAR2
    , p3_a70  NUMBER
    , p3_a71  NUMBER
    , p3_a72  VARCHAR2
    , p3_a73  NUMBER
    , p3_a74  NUMBER
    , p3_a75  DATE
    , p3_a76  VARCHAR2
    , p3_a77  NUMBER
    , p3_a78  VARCHAR2
    , p3_a79  NUMBER
    , p3_a80  VARCHAR2
    , p3_a81  DATE
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  DATE
    , p3_a85  NUMBER
    , p3_a86  DATE
    , p3_a87  NUMBER
    , p3_a88  DATE
    , p3_a89  NUMBER
    , p3_a90  NUMBER
    , p3_a91  NUMBER
    , p3_a92  NUMBER
    , p3_a93  VARCHAR2
    , p3_a94  NUMBER
    , p3_a95  DATE
    , p3_a96  NUMBER
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
    , p3_a129  VARCHAR2
    , p3_a130  NUMBER
    , p3_a131  VARCHAR2
    , p3_a132  NUMBER
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  NUMBER
    , p3_a137  NUMBER
    , p3_a138  VARCHAR2
    , p3_a139  NUMBER
    , p3_a140  NUMBER
    , p3_a141  VARCHAR2
    , p3_a142  VARCHAR2
    , p3_a143  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ozf_claims_history_pvt_w;

 

/
