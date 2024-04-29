--------------------------------------------------------
--  DDL for Package OZF_CLAIM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwclas.pls 120.4.12010000.2 2009/07/23 17:12:52 kpatro ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ozf_claim_pvt.claim_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_DATE_TABLE
    , a17 JTF_DATE_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_DATE_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_DATE_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_VARCHAR2_TABLE_100
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_NUMBER_TABLE
    , a67 JTF_DATE_TABLE
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_NUMBER_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_DATE_TABLE
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_VARCHAR2_TABLE_100
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_DATE_TABLE
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_VARCHAR2_TABLE_100
    , a83 JTF_DATE_TABLE
    , a84 JTF_NUMBER_TABLE
    , a85 JTF_DATE_TABLE
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_DATE_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_NUMBER_TABLE
    , a90 JTF_NUMBER_TABLE
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_VARCHAR2_TABLE_2000
    , a93 JTF_VARCHAR2_TABLE_100
    , a94 JTF_VARCHAR2_TABLE_200
    , a95 JTF_VARCHAR2_TABLE_200
    , a96 JTF_VARCHAR2_TABLE_200
    , a97 JTF_VARCHAR2_TABLE_200
    , a98 JTF_VARCHAR2_TABLE_200
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
    , a109 JTF_VARCHAR2_TABLE_100
    , a110 JTF_VARCHAR2_TABLE_200
    , a111 JTF_VARCHAR2_TABLE_200
    , a112 JTF_VARCHAR2_TABLE_200
    , a113 JTF_VARCHAR2_TABLE_200
    , a114 JTF_VARCHAR2_TABLE_200
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
    , a125 JTF_NUMBER_TABLE
    , a126 JTF_NUMBER_TABLE
    , a127 JTF_VARCHAR2_TABLE_100
    , a128 JTF_NUMBER_TABLE
    , a129 JTF_VARCHAR2_TABLE_100
    , a130 JTF_VARCHAR2_TABLE_100
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_NUMBER_TABLE
    , a134 JTF_VARCHAR2_TABLE_100
    , a135 JTF_NUMBER_TABLE
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_VARCHAR2_TABLE_300
    , a138 JTF_VARCHAR2_TABLE_300
    , a139 JTF_VARCHAR2_TABLE_100
    , a140 JTF_VARCHAR2_TABLE_100
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_NUMBER_TABLE
    , a143 JTF_VARCHAR2_TABLE_100
    , a144 JTF_VARCHAR2_TABLE_100
    , a145 JTF_NUMBER_TABLE
    , a146 JTF_VARCHAR2_TABLE_100
    , a147 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ozf_claim_pvt.claim_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_DATE_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_DATE_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_VARCHAR2_TABLE_100
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_NUMBER_TABLE
    , a67 out nocopy JTF_DATE_TABLE
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_NUMBER_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_DATE_TABLE
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_VARCHAR2_TABLE_100
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_DATE_TABLE
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_VARCHAR2_TABLE_100
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_NUMBER_TABLE
    , a85 out nocopy JTF_DATE_TABLE
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_DATE_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_NUMBER_TABLE
    , a90 out nocopy JTF_NUMBER_TABLE
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_VARCHAR2_TABLE_2000
    , a93 out nocopy JTF_VARCHAR2_TABLE_100
    , a94 out nocopy JTF_VARCHAR2_TABLE_200
    , a95 out nocopy JTF_VARCHAR2_TABLE_200
    , a96 out nocopy JTF_VARCHAR2_TABLE_200
    , a97 out nocopy JTF_VARCHAR2_TABLE_200
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a109 out nocopy JTF_VARCHAR2_TABLE_100
    , a110 out nocopy JTF_VARCHAR2_TABLE_200
    , a111 out nocopy JTF_VARCHAR2_TABLE_200
    , a112 out nocopy JTF_VARCHAR2_TABLE_200
    , a113 out nocopy JTF_VARCHAR2_TABLE_200
    , a114 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a125 out nocopy JTF_NUMBER_TABLE
    , a126 out nocopy JTF_NUMBER_TABLE
    , a127 out nocopy JTF_VARCHAR2_TABLE_100
    , a128 out nocopy JTF_NUMBER_TABLE
    , a129 out nocopy JTF_VARCHAR2_TABLE_100
    , a130 out nocopy JTF_VARCHAR2_TABLE_100
    , a131 out nocopy JTF_NUMBER_TABLE
    , a132 out nocopy JTF_NUMBER_TABLE
    , a133 out nocopy JTF_NUMBER_TABLE
    , a134 out nocopy JTF_VARCHAR2_TABLE_100
    , a135 out nocopy JTF_NUMBER_TABLE
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_VARCHAR2_TABLE_300
    , a138 out nocopy JTF_VARCHAR2_TABLE_300
    , a139 out nocopy JTF_VARCHAR2_TABLE_100
    , a140 out nocopy JTF_VARCHAR2_TABLE_100
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_NUMBER_TABLE
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
    , a144 out nocopy JTF_VARCHAR2_TABLE_100
    , a145 out nocopy JTF_NUMBER_TABLE
    , a146 out nocopy JTF_VARCHAR2_TABLE_100
    , a147 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
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
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
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
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , x_claim_id out nocopy  NUMBER
  );
  procedure update_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
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
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
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
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p_event  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  );
  procedure validate_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  DATE
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  DATE
    , p6_a43  NUMBER
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  VARCHAR2
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  VARCHAR2
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  DATE
    , p6_a68  VARCHAR2
    , p6_a69  NUMBER
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  DATE
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  NUMBER
    , p6_a79  VARCHAR2
    , p6_a80  DATE
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  DATE
    , p6_a84  NUMBER
    , p6_a85  DATE
    , p6_a86  NUMBER
    , p6_a87  DATE
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  VARCHAR2
    , p6_a93  VARCHAR2
    , p6_a94  VARCHAR2
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  VARCHAR2
    , p6_a98  VARCHAR2
    , p6_a99  VARCHAR2
    , p6_a100  VARCHAR2
    , p6_a101  VARCHAR2
    , p6_a102  VARCHAR2
    , p6_a103  VARCHAR2
    , p6_a104  VARCHAR2
    , p6_a105  VARCHAR2
    , p6_a106  VARCHAR2
    , p6_a107  VARCHAR2
    , p6_a108  VARCHAR2
    , p6_a109  VARCHAR2
    , p6_a110  VARCHAR2
    , p6_a111  VARCHAR2
    , p6_a112  VARCHAR2
    , p6_a113  VARCHAR2
    , p6_a114  VARCHAR2
    , p6_a115  VARCHAR2
    , p6_a116  VARCHAR2
    , p6_a117  VARCHAR2
    , p6_a118  VARCHAR2
    , p6_a119  VARCHAR2
    , p6_a120  VARCHAR2
    , p6_a121  VARCHAR2
    , p6_a122  VARCHAR2
    , p6_a123  VARCHAR2
    , p6_a124  VARCHAR2
    , p6_a125  NUMBER
    , p6_a126  NUMBER
    , p6_a127  VARCHAR2
    , p6_a128  NUMBER
    , p6_a129  VARCHAR2
    , p6_a130  VARCHAR2
    , p6_a131  NUMBER
    , p6_a132  NUMBER
    , p6_a133  NUMBER
    , p6_a134  VARCHAR2
    , p6_a135  NUMBER
    , p6_a136  NUMBER
    , p6_a137  VARCHAR2
    , p6_a138  VARCHAR2
    , p6_a139  VARCHAR2
    , p6_a140  VARCHAR2
    , p6_a141  NUMBER
    , p6_a142  NUMBER
    , p6_a143  VARCHAR2
    , p6_a144  VARCHAR2
    , p6_a145  NUMBER
    , p6_a146  VARCHAR2
    , p6_a147  VARCHAR2
  );
  procedure check_claim_common_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  DATE
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  VARCHAR2
    , p6_a20  DATE
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  DATE
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  DATE
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  DATE
    , p6_a43  NUMBER
    , p6_a44  VARCHAR2
    , p6_a45  NUMBER
    , p6_a46  VARCHAR2
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  NUMBER
    , p6_a54  VARCHAR2
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  VARCHAR2
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  DATE
    , p6_a68  VARCHAR2
    , p6_a69  NUMBER
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  DATE
    , p6_a75  VARCHAR2
    , p6_a76  NUMBER
    , p6_a77  VARCHAR2
    , p6_a78  NUMBER
    , p6_a79  VARCHAR2
    , p6_a80  DATE
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  DATE
    , p6_a84  NUMBER
    , p6_a85  DATE
    , p6_a86  NUMBER
    , p6_a87  DATE
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  VARCHAR2
    , p6_a93  VARCHAR2
    , p6_a94  VARCHAR2
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  VARCHAR2
    , p6_a98  VARCHAR2
    , p6_a99  VARCHAR2
    , p6_a100  VARCHAR2
    , p6_a101  VARCHAR2
    , p6_a102  VARCHAR2
    , p6_a103  VARCHAR2
    , p6_a104  VARCHAR2
    , p6_a105  VARCHAR2
    , p6_a106  VARCHAR2
    , p6_a107  VARCHAR2
    , p6_a108  VARCHAR2
    , p6_a109  VARCHAR2
    , p6_a110  VARCHAR2
    , p6_a111  VARCHAR2
    , p6_a112  VARCHAR2
    , p6_a113  VARCHAR2
    , p6_a114  VARCHAR2
    , p6_a115  VARCHAR2
    , p6_a116  VARCHAR2
    , p6_a117  VARCHAR2
    , p6_a118  VARCHAR2
    , p6_a119  VARCHAR2
    , p6_a120  VARCHAR2
    , p6_a121  VARCHAR2
    , p6_a122  VARCHAR2
    , p6_a123  VARCHAR2
    , p6_a124  VARCHAR2
    , p6_a125  NUMBER
    , p6_a126  NUMBER
    , p6_a127  VARCHAR2
    , p6_a128  NUMBER
    , p6_a129  VARCHAR2
    , p6_a130  VARCHAR2
    , p6_a131  NUMBER
    , p6_a132  NUMBER
    , p6_a133  NUMBER
    , p6_a134  VARCHAR2
    , p6_a135  NUMBER
    , p6_a136  NUMBER
    , p6_a137  VARCHAR2
    , p6_a138  VARCHAR2
    , p6_a139  VARCHAR2
    , p6_a140  VARCHAR2
    , p6_a141  NUMBER
    , p6_a142  NUMBER
    , p6_a143  VARCHAR2
    , p6_a144  VARCHAR2
    , p6_a145  NUMBER
    , p6_a146  VARCHAR2
    , p6_a147  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  DATE
    , p7_a3 out nocopy  NUMBER
    , p7_a4 out nocopy  DATE
    , p7_a5 out nocopy  NUMBER
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  DATE
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  VARCHAR2
    , p7_a12 out nocopy  NUMBER
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  NUMBER
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  DATE
    , p7_a17 out nocopy  DATE
    , p7_a18 out nocopy  NUMBER
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  DATE
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  NUMBER
    , p7_a23 out nocopy  NUMBER
    , p7_a24 out nocopy  DATE
    , p7_a25 out nocopy  NUMBER
    , p7_a26 out nocopy  NUMBER
    , p7_a27 out nocopy  NUMBER
    , p7_a28 out nocopy  NUMBER
    , p7_a29 out nocopy  NUMBER
    , p7_a30 out nocopy  NUMBER
    , p7_a31 out nocopy  NUMBER
    , p7_a32 out nocopy  NUMBER
    , p7_a33 out nocopy  NUMBER
    , p7_a34 out nocopy  NUMBER
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  VARCHAR2
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  DATE
    , p7_a40 out nocopy  NUMBER
    , p7_a41 out nocopy  NUMBER
    , p7_a42 out nocopy  DATE
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  VARCHAR2
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  VARCHAR2
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  NUMBER
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  NUMBER
    , p7_a51 out nocopy  VARCHAR2
    , p7_a52 out nocopy  NUMBER
    , p7_a53 out nocopy  NUMBER
    , p7_a54 out nocopy  VARCHAR2
    , p7_a55 out nocopy  NUMBER
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  NUMBER
    , p7_a59 out nocopy  NUMBER
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  NUMBER
    , p7_a62 out nocopy  NUMBER
    , p7_a63 out nocopy  NUMBER
    , p7_a64 out nocopy  NUMBER
    , p7_a65 out nocopy  NUMBER
    , p7_a66 out nocopy  NUMBER
    , p7_a67 out nocopy  DATE
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  NUMBER
    , p7_a70 out nocopy  NUMBER
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  NUMBER
    , p7_a73 out nocopy  NUMBER
    , p7_a74 out nocopy  DATE
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  NUMBER
    , p7_a77 out nocopy  VARCHAR2
    , p7_a78 out nocopy  NUMBER
    , p7_a79 out nocopy  VARCHAR2
    , p7_a80 out nocopy  DATE
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  VARCHAR2
    , p7_a83 out nocopy  DATE
    , p7_a84 out nocopy  NUMBER
    , p7_a85 out nocopy  DATE
    , p7_a86 out nocopy  NUMBER
    , p7_a87 out nocopy  DATE
    , p7_a88 out nocopy  NUMBER
    , p7_a89 out nocopy  NUMBER
    , p7_a90 out nocopy  NUMBER
    , p7_a91 out nocopy  NUMBER
    , p7_a92 out nocopy  VARCHAR2
    , p7_a93 out nocopy  VARCHAR2
    , p7_a94 out nocopy  VARCHAR2
    , p7_a95 out nocopy  VARCHAR2
    , p7_a96 out nocopy  VARCHAR2
    , p7_a97 out nocopy  VARCHAR2
    , p7_a98 out nocopy  VARCHAR2
    , p7_a99 out nocopy  VARCHAR2
    , p7_a100 out nocopy  VARCHAR2
    , p7_a101 out nocopy  VARCHAR2
    , p7_a102 out nocopy  VARCHAR2
    , p7_a103 out nocopy  VARCHAR2
    , p7_a104 out nocopy  VARCHAR2
    , p7_a105 out nocopy  VARCHAR2
    , p7_a106 out nocopy  VARCHAR2
    , p7_a107 out nocopy  VARCHAR2
    , p7_a108 out nocopy  VARCHAR2
    , p7_a109 out nocopy  VARCHAR2
    , p7_a110 out nocopy  VARCHAR2
    , p7_a111 out nocopy  VARCHAR2
    , p7_a112 out nocopy  VARCHAR2
    , p7_a113 out nocopy  VARCHAR2
    , p7_a114 out nocopy  VARCHAR2
    , p7_a115 out nocopy  VARCHAR2
    , p7_a116 out nocopy  VARCHAR2
    , p7_a117 out nocopy  VARCHAR2
    , p7_a118 out nocopy  VARCHAR2
    , p7_a119 out nocopy  VARCHAR2
    , p7_a120 out nocopy  VARCHAR2
    , p7_a121 out nocopy  VARCHAR2
    , p7_a122 out nocopy  VARCHAR2
    , p7_a123 out nocopy  VARCHAR2
    , p7_a124 out nocopy  VARCHAR2
    , p7_a125 out nocopy  NUMBER
    , p7_a126 out nocopy  NUMBER
    , p7_a127 out nocopy  VARCHAR2
    , p7_a128 out nocopy  NUMBER
    , p7_a129 out nocopy  VARCHAR2
    , p7_a130 out nocopy  VARCHAR2
    , p7_a131 out nocopy  NUMBER
    , p7_a132 out nocopy  NUMBER
    , p7_a133 out nocopy  NUMBER
    , p7_a134 out nocopy  VARCHAR2
    , p7_a135 out nocopy  NUMBER
    , p7_a136 out nocopy  NUMBER
    , p7_a137 out nocopy  VARCHAR2
    , p7_a138 out nocopy  VARCHAR2
    , p7_a139 out nocopy  VARCHAR2
    , p7_a140 out nocopy  VARCHAR2
    , p7_a141 out nocopy  NUMBER
    , p7_a142 out nocopy  NUMBER
    , p7_a143 out nocopy  VARCHAR2
    , p7_a144 out nocopy  VARCHAR2
    , p7_a145 out nocopy  NUMBER
    , p7_a146 out nocopy  VARCHAR2
    , p7_a147 out nocopy  VARCHAR2
    , p_mode  VARCHAR2
  );
  procedure check_claim_items(p_validation_mode  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  DATE
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  VARCHAR2
    , p1_a20  DATE
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  DATE
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  DATE
    , p1_a43  NUMBER
    , p1_a44  VARCHAR2
    , p1_a45  NUMBER
    , p1_a46  VARCHAR2
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  NUMBER
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  NUMBER
    , p1_a59  NUMBER
    , p1_a60  VARCHAR2
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  DATE
    , p1_a68  VARCHAR2
    , p1_a69  NUMBER
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  DATE
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  DATE
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  DATE
    , p1_a84  NUMBER
    , p1_a85  DATE
    , p1_a86  NUMBER
    , p1_a87  DATE
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  VARCHAR2
    , p1_a98  VARCHAR2
    , p1_a99  VARCHAR2
    , p1_a100  VARCHAR2
    , p1_a101  VARCHAR2
    , p1_a102  VARCHAR2
    , p1_a103  VARCHAR2
    , p1_a104  VARCHAR2
    , p1_a105  VARCHAR2
    , p1_a106  VARCHAR2
    , p1_a107  VARCHAR2
    , p1_a108  VARCHAR2
    , p1_a109  VARCHAR2
    , p1_a110  VARCHAR2
    , p1_a111  VARCHAR2
    , p1_a112  VARCHAR2
    , p1_a113  VARCHAR2
    , p1_a114  VARCHAR2
    , p1_a115  VARCHAR2
    , p1_a116  VARCHAR2
    , p1_a117  VARCHAR2
    , p1_a118  VARCHAR2
    , p1_a119  VARCHAR2
    , p1_a120  VARCHAR2
    , p1_a121  VARCHAR2
    , p1_a122  VARCHAR2
    , p1_a123  VARCHAR2
    , p1_a124  VARCHAR2
    , p1_a125  NUMBER
    , p1_a126  NUMBER
    , p1_a127  VARCHAR2
    , p1_a128  NUMBER
    , p1_a129  VARCHAR2
    , p1_a130  VARCHAR2
    , p1_a131  NUMBER
    , p1_a132  NUMBER
    , p1_a133  NUMBER
    , p1_a134  VARCHAR2
    , p1_a135  NUMBER
    , p1_a136  NUMBER
    , p1_a137  VARCHAR2
    , p1_a138  VARCHAR2
    , p1_a139  VARCHAR2
    , p1_a140  VARCHAR2
    , p1_a141  NUMBER
    , p1_a142  NUMBER
    , p1_a143  VARCHAR2
    , p1_a144  VARCHAR2
    , p1_a145  NUMBER
    , p1_a146  VARCHAR2
    , p1_a147  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_claim_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  DATE
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  DATE
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  DATE
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  DATE
    , p0_a43  NUMBER
    , p0_a44  VARCHAR2
    , p0_a45  NUMBER
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  DATE
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  VARCHAR2
    , p0_a78  NUMBER
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  DATE
    , p0_a84  NUMBER
    , p0_a85  DATE
    , p0_a86  NUMBER
    , p0_a87  DATE
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  VARCHAR2
    , p0_a106  VARCHAR2
    , p0_a107  VARCHAR2
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  VARCHAR2
    , p0_a113  VARCHAR2
    , p0_a114  VARCHAR2
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  VARCHAR2
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  NUMBER
    , p0_a126  NUMBER
    , p0_a127  VARCHAR2
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  NUMBER
    , p0_a132  NUMBER
    , p0_a133  NUMBER
    , p0_a134  VARCHAR2
    , p0_a135  NUMBER
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p0_a138  VARCHAR2
    , p0_a139  VARCHAR2
    , p0_a140  VARCHAR2
    , p0_a141  NUMBER
    , p0_a142  NUMBER
    , p0_a143  VARCHAR2
    , p0_a144  VARCHAR2
    , p0_a145  NUMBER
    , p0_a146  VARCHAR2
    , p0_a147  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  DATE
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  DATE
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  DATE
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  NUMBER
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  DATE
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  NUMBER
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  DATE
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  NUMBER
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  DATE
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  DATE
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  DATE
    , p1_a86 out nocopy  NUMBER
    , p1_a87 out nocopy  DATE
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  NUMBER
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  VARCHAR2
    , p1_a93 out nocopy  VARCHAR2
    , p1_a94 out nocopy  VARCHAR2
    , p1_a95 out nocopy  VARCHAR2
    , p1_a96 out nocopy  VARCHAR2
    , p1_a97 out nocopy  VARCHAR2
    , p1_a98 out nocopy  VARCHAR2
    , p1_a99 out nocopy  VARCHAR2
    , p1_a100 out nocopy  VARCHAR2
    , p1_a101 out nocopy  VARCHAR2
    , p1_a102 out nocopy  VARCHAR2
    , p1_a103 out nocopy  VARCHAR2
    , p1_a104 out nocopy  VARCHAR2
    , p1_a105 out nocopy  VARCHAR2
    , p1_a106 out nocopy  VARCHAR2
    , p1_a107 out nocopy  VARCHAR2
    , p1_a108 out nocopy  VARCHAR2
    , p1_a109 out nocopy  VARCHAR2
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  VARCHAR2
    , p1_a112 out nocopy  VARCHAR2
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  VARCHAR2
    , p1_a115 out nocopy  VARCHAR2
    , p1_a116 out nocopy  VARCHAR2
    , p1_a117 out nocopy  VARCHAR2
    , p1_a118 out nocopy  VARCHAR2
    , p1_a119 out nocopy  VARCHAR2
    , p1_a120 out nocopy  VARCHAR2
    , p1_a121 out nocopy  VARCHAR2
    , p1_a122 out nocopy  VARCHAR2
    , p1_a123 out nocopy  VARCHAR2
    , p1_a124 out nocopy  VARCHAR2
    , p1_a125 out nocopy  NUMBER
    , p1_a126 out nocopy  NUMBER
    , p1_a127 out nocopy  VARCHAR2
    , p1_a128 out nocopy  NUMBER
    , p1_a129 out nocopy  VARCHAR2
    , p1_a130 out nocopy  VARCHAR2
    , p1_a131 out nocopy  NUMBER
    , p1_a132 out nocopy  NUMBER
    , p1_a133 out nocopy  NUMBER
    , p1_a134 out nocopy  VARCHAR2
    , p1_a135 out nocopy  NUMBER
    , p1_a136 out nocopy  NUMBER
    , p1_a137 out nocopy  VARCHAR2
    , p1_a138 out nocopy  VARCHAR2
    , p1_a139 out nocopy  VARCHAR2
    , p1_a140 out nocopy  VARCHAR2
    , p1_a141 out nocopy  NUMBER
    , p1_a142 out nocopy  NUMBER
    , p1_a143 out nocopy  VARCHAR2
    , p1_a144 out nocopy  VARCHAR2
    , p1_a145 out nocopy  NUMBER
    , p1_a146 out nocopy  VARCHAR2
    , p1_a147 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure create_claim_history(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
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
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  DATE
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  DATE
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  DATE
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  DATE
    , p7_a43  NUMBER
    , p7_a44  VARCHAR2
    , p7_a45  NUMBER
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  NUMBER
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  DATE
    , p7_a68  VARCHAR2
    , p7_a69  NUMBER
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  DATE
    , p7_a75  VARCHAR2
    , p7_a76  NUMBER
    , p7_a77  VARCHAR2
    , p7_a78  NUMBER
    , p7_a79  VARCHAR2
    , p7_a80  DATE
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  DATE
    , p7_a84  NUMBER
    , p7_a85  DATE
    , p7_a86  NUMBER
    , p7_a87  DATE
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
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
    , p7_a125  NUMBER
    , p7_a126  NUMBER
    , p7_a127  VARCHAR2
    , p7_a128  NUMBER
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  NUMBER
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  VARCHAR2
    , p7_a135  NUMBER
    , p7_a136  NUMBER
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  NUMBER
    , p7_a142  NUMBER
    , p7_a143  VARCHAR2
    , p7_a144  VARCHAR2
    , p7_a145  NUMBER
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p_event  VARCHAR2
    , x_need_to_create out nocopy  VARCHAR2
    , x_claim_history_id out nocopy  NUMBER
  );
  procedure validate_delete_claim(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_id  NUMBER
    , p_object_version_number  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_DATE_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_2000
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_VARCHAR2_TABLE_100
    , p7_a58 JTF_NUMBER_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_NUMBER_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p7_a66 JTF_NUMBER_TABLE
    , p7_a67 JTF_DATE_TABLE
    , p7_a68 JTF_VARCHAR2_TABLE_100
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_NUMBER_TABLE
    , p7_a71 JTF_VARCHAR2_TABLE_100
    , p7_a72 JTF_NUMBER_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_DATE_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_DATE_TABLE
    , p7_a81 JTF_VARCHAR2_TABLE_100
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_DATE_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_NUMBER_TABLE
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_2000
    , p7_a93 JTF_VARCHAR2_TABLE_100
    , p7_a94 JTF_VARCHAR2_TABLE_200
    , p7_a95 JTF_VARCHAR2_TABLE_200
    , p7_a96 JTF_VARCHAR2_TABLE_200
    , p7_a97 JTF_VARCHAR2_TABLE_200
    , p7_a98 JTF_VARCHAR2_TABLE_200
    , p7_a99 JTF_VARCHAR2_TABLE_200
    , p7_a100 JTF_VARCHAR2_TABLE_200
    , p7_a101 JTF_VARCHAR2_TABLE_200
    , p7_a102 JTF_VARCHAR2_TABLE_200
    , p7_a103 JTF_VARCHAR2_TABLE_200
    , p7_a104 JTF_VARCHAR2_TABLE_200
    , p7_a105 JTF_VARCHAR2_TABLE_200
    , p7_a106 JTF_VARCHAR2_TABLE_200
    , p7_a107 JTF_VARCHAR2_TABLE_200
    , p7_a108 JTF_VARCHAR2_TABLE_200
    , p7_a109 JTF_VARCHAR2_TABLE_100
    , p7_a110 JTF_VARCHAR2_TABLE_200
    , p7_a111 JTF_VARCHAR2_TABLE_200
    , p7_a112 JTF_VARCHAR2_TABLE_200
    , p7_a113 JTF_VARCHAR2_TABLE_200
    , p7_a114 JTF_VARCHAR2_TABLE_200
    , p7_a115 JTF_VARCHAR2_TABLE_200
    , p7_a116 JTF_VARCHAR2_TABLE_200
    , p7_a117 JTF_VARCHAR2_TABLE_200
    , p7_a118 JTF_VARCHAR2_TABLE_200
    , p7_a119 JTF_VARCHAR2_TABLE_200
    , p7_a120 JTF_VARCHAR2_TABLE_200
    , p7_a121 JTF_VARCHAR2_TABLE_200
    , p7_a122 JTF_VARCHAR2_TABLE_200
    , p7_a123 JTF_VARCHAR2_TABLE_200
    , p7_a124 JTF_VARCHAR2_TABLE_200
    , p7_a125 JTF_NUMBER_TABLE
    , p7_a126 JTF_NUMBER_TABLE
    , p7_a127 JTF_VARCHAR2_TABLE_100
    , p7_a128 JTF_NUMBER_TABLE
    , p7_a129 JTF_VARCHAR2_TABLE_100
    , p7_a130 JTF_VARCHAR2_TABLE_100
    , p7_a131 JTF_NUMBER_TABLE
    , p7_a132 JTF_NUMBER_TABLE
    , p7_a133 JTF_NUMBER_TABLE
    , p7_a134 JTF_VARCHAR2_TABLE_100
    , p7_a135 JTF_NUMBER_TABLE
    , p7_a136 JTF_NUMBER_TABLE
    , p7_a137 JTF_VARCHAR2_TABLE_300
    , p7_a138 JTF_VARCHAR2_TABLE_300
    , p7_a139 JTF_VARCHAR2_TABLE_100
    , p7_a140 JTF_VARCHAR2_TABLE_100
    , p7_a141 JTF_NUMBER_TABLE
    , p7_a142 JTF_NUMBER_TABLE
    , p7_a143 JTF_VARCHAR2_TABLE_100
    , p7_a144 JTF_VARCHAR2_TABLE_100
    , p7_a145 JTF_NUMBER_TABLE
    , p7_a146 JTF_VARCHAR2_TABLE_100
    , p7_a147 JTF_VARCHAR2_TABLE_100
    , x_error_index out nocopy  NUMBER
  );
  procedure update_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_VARCHAR2_TABLE_100
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_DATE_TABLE
    , p7_a17 JTF_DATE_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_2000
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_NUMBER_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_VARCHAR2_TABLE_100
    , p7_a37 JTF_VARCHAR2_TABLE_100
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_DATE_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_VARCHAR2_TABLE_100
    , p7_a45 JTF_NUMBER_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_NUMBER_TABLE
    , p7_a49 JTF_NUMBER_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_VARCHAR2_TABLE_100
    , p7_a52 JTF_NUMBER_TABLE
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_VARCHAR2_TABLE_100
    , p7_a55 JTF_NUMBER_TABLE
    , p7_a56 JTF_NUMBER_TABLE
    , p7_a57 JTF_VARCHAR2_TABLE_100
    , p7_a58 JTF_NUMBER_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_NUMBER_TABLE
    , p7_a62 JTF_NUMBER_TABLE
    , p7_a63 JTF_NUMBER_TABLE
    , p7_a64 JTF_NUMBER_TABLE
    , p7_a65 JTF_NUMBER_TABLE
    , p7_a66 JTF_NUMBER_TABLE
    , p7_a67 JTF_DATE_TABLE
    , p7_a68 JTF_VARCHAR2_TABLE_100
    , p7_a69 JTF_NUMBER_TABLE
    , p7_a70 JTF_NUMBER_TABLE
    , p7_a71 JTF_VARCHAR2_TABLE_100
    , p7_a72 JTF_NUMBER_TABLE
    , p7_a73 JTF_NUMBER_TABLE
    , p7_a74 JTF_DATE_TABLE
    , p7_a75 JTF_VARCHAR2_TABLE_100
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_VARCHAR2_TABLE_100
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_VARCHAR2_TABLE_100
    , p7_a80 JTF_DATE_TABLE
    , p7_a81 JTF_VARCHAR2_TABLE_100
    , p7_a82 JTF_VARCHAR2_TABLE_100
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_NUMBER_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_NUMBER_TABLE
    , p7_a87 JTF_DATE_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_NUMBER_TABLE
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_2000
    , p7_a93 JTF_VARCHAR2_TABLE_100
    , p7_a94 JTF_VARCHAR2_TABLE_200
    , p7_a95 JTF_VARCHAR2_TABLE_200
    , p7_a96 JTF_VARCHAR2_TABLE_200
    , p7_a97 JTF_VARCHAR2_TABLE_200
    , p7_a98 JTF_VARCHAR2_TABLE_200
    , p7_a99 JTF_VARCHAR2_TABLE_200
    , p7_a100 JTF_VARCHAR2_TABLE_200
    , p7_a101 JTF_VARCHAR2_TABLE_200
    , p7_a102 JTF_VARCHAR2_TABLE_200
    , p7_a103 JTF_VARCHAR2_TABLE_200
    , p7_a104 JTF_VARCHAR2_TABLE_200
    , p7_a105 JTF_VARCHAR2_TABLE_200
    , p7_a106 JTF_VARCHAR2_TABLE_200
    , p7_a107 JTF_VARCHAR2_TABLE_200
    , p7_a108 JTF_VARCHAR2_TABLE_200
    , p7_a109 JTF_VARCHAR2_TABLE_100
    , p7_a110 JTF_VARCHAR2_TABLE_200
    , p7_a111 JTF_VARCHAR2_TABLE_200
    , p7_a112 JTF_VARCHAR2_TABLE_200
    , p7_a113 JTF_VARCHAR2_TABLE_200
    , p7_a114 JTF_VARCHAR2_TABLE_200
    , p7_a115 JTF_VARCHAR2_TABLE_200
    , p7_a116 JTF_VARCHAR2_TABLE_200
    , p7_a117 JTF_VARCHAR2_TABLE_200
    , p7_a118 JTF_VARCHAR2_TABLE_200
    , p7_a119 JTF_VARCHAR2_TABLE_200
    , p7_a120 JTF_VARCHAR2_TABLE_200
    , p7_a121 JTF_VARCHAR2_TABLE_200
    , p7_a122 JTF_VARCHAR2_TABLE_200
    , p7_a123 JTF_VARCHAR2_TABLE_200
    , p7_a124 JTF_VARCHAR2_TABLE_200
    , p7_a125 JTF_NUMBER_TABLE
    , p7_a126 JTF_NUMBER_TABLE
    , p7_a127 JTF_VARCHAR2_TABLE_100
    , p7_a128 JTF_NUMBER_TABLE
    , p7_a129 JTF_VARCHAR2_TABLE_100
    , p7_a130 JTF_VARCHAR2_TABLE_100
    , p7_a131 JTF_NUMBER_TABLE
    , p7_a132 JTF_NUMBER_TABLE
    , p7_a133 JTF_NUMBER_TABLE
    , p7_a134 JTF_VARCHAR2_TABLE_100
    , p7_a135 JTF_NUMBER_TABLE
    , p7_a136 JTF_NUMBER_TABLE
    , p7_a137 JTF_VARCHAR2_TABLE_300
    , p7_a138 JTF_VARCHAR2_TABLE_300
    , p7_a139 JTF_VARCHAR2_TABLE_100
    , p7_a140 JTF_VARCHAR2_TABLE_100
    , p7_a141 JTF_NUMBER_TABLE
    , p7_a142 JTF_NUMBER_TABLE
    , p7_a143 JTF_VARCHAR2_TABLE_100
    , p7_a144 JTF_VARCHAR2_TABLE_100
    , p7_a145 JTF_NUMBER_TABLE
    , p7_a146 JTF_VARCHAR2_TABLE_100
    , p7_a147 JTF_VARCHAR2_TABLE_100
  );
end ozf_claim_pvt_w;

/
