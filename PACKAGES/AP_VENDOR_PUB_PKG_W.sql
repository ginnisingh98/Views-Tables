--------------------------------------------------------
--  DDL for Package AP_VENDOR_PUB_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_VENDOR_PUB_PKG_W" AUTHID CURRENT_USER as
  /* $Header: appvndws.pls 120.0.12000000.1 2007/04/24 19:12:41 xili noship $ */
  procedure create_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  DATE
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  NUMBER
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
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
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  VARCHAR2
    , p7_a113  NUMBER
    , p7_a114  NUMBER
    , p7_a115  VARCHAR2
    , p7_a116  NUMBER
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  NUMBER
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  DATE
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , x_vendor_id out nocopy  NUMBER
    , x_party_id out nocopy  NUMBER
  );
  procedure update_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  NUMBER
    , p7_a40  DATE
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  NUMBER
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
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
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  VARCHAR2
    , p7_a109  VARCHAR2
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  VARCHAR2
    , p7_a113  NUMBER
    , p7_a114  NUMBER
    , p7_a115  VARCHAR2
    , p7_a116  NUMBER
    , p7_a117  VARCHAR2
    , p7_a118  VARCHAR2
    , p7_a119  NUMBER
    , p7_a120  NUMBER
    , p7_a121  NUMBER
    , p7_a122  VARCHAR2
    , p7_a123  VARCHAR2
    , p7_a124  VARCHAR2
    , p7_a125  VARCHAR2
    , p7_a126  VARCHAR2
    , p7_a127  VARCHAR2
    , p7_a128  VARCHAR2
    , p7_a129  VARCHAR2
    , p7_a130  VARCHAR2
    , p7_a131  DATE
    , p7_a132  VARCHAR2
    , p7_a133  VARCHAR2
    , p7_a134  VARCHAR2
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p_vendor_id  NUMBER
  );
  procedure validate_vendor(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  VARCHAR2
    , p7_a4 in out nocopy  VARCHAR2
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  VARCHAR2
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  NUMBER
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  NUMBER
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  NUMBER
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  DATE
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  DATE
    , p7_a33 in out nocopy  DATE
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  NUMBER
    , p7_a40 in out nocopy  DATE
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  VARCHAR2
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  NUMBER
    , p7_a48 in out nocopy  NUMBER
    , p7_a49 in out nocopy  VARCHAR2
    , p7_a50 in out nocopy  NUMBER
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  DATE
    , p7_a55 in out nocopy  VARCHAR2
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  VARCHAR2
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  VARCHAR2
    , p7_a62 in out nocopy  VARCHAR2
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  VARCHAR2
    , p7_a68 in out nocopy  VARCHAR2
    , p7_a69 in out nocopy  VARCHAR2
    , p7_a70 in out nocopy  VARCHAR2
    , p7_a71 in out nocopy  VARCHAR2
    , p7_a72 in out nocopy  VARCHAR2
    , p7_a73 in out nocopy  VARCHAR2
    , p7_a74 in out nocopy  VARCHAR2
    , p7_a75 in out nocopy  NUMBER
    , p7_a76 in out nocopy  VARCHAR2
    , p7_a77 in out nocopy  VARCHAR2
    , p7_a78 in out nocopy  VARCHAR2
    , p7_a79 in out nocopy  VARCHAR2
    , p7_a80 in out nocopy  NUMBER
    , p7_a81 in out nocopy  VARCHAR2
    , p7_a82 in out nocopy  VARCHAR2
    , p7_a83 in out nocopy  VARCHAR2
    , p7_a84 in out nocopy  VARCHAR2
    , p7_a85 in out nocopy  VARCHAR2
    , p7_a86 in out nocopy  VARCHAR2
    , p7_a87 in out nocopy  VARCHAR2
    , p7_a88 in out nocopy  VARCHAR2
    , p7_a89 in out nocopy  VARCHAR2
    , p7_a90 in out nocopy  VARCHAR2
    , p7_a91 in out nocopy  VARCHAR2
    , p7_a92 in out nocopy  VARCHAR2
    , p7_a93 in out nocopy  VARCHAR2
    , p7_a94 in out nocopy  VARCHAR2
    , p7_a95 in out nocopy  VARCHAR2
    , p7_a96 in out nocopy  VARCHAR2
    , p7_a97 in out nocopy  VARCHAR2
    , p7_a98 in out nocopy  VARCHAR2
    , p7_a99 in out nocopy  VARCHAR2
    , p7_a100 in out nocopy  VARCHAR2
    , p7_a101 in out nocopy  VARCHAR2
    , p7_a102 in out nocopy  VARCHAR2
    , p7_a103 in out nocopy  VARCHAR2
    , p7_a104 in out nocopy  VARCHAR2
    , p7_a105 in out nocopy  VARCHAR2
    , p7_a106 in out nocopy  NUMBER
    , p7_a107 in out nocopy  NUMBER
    , p7_a108 in out nocopy  VARCHAR2
    , p7_a109 in out nocopy  VARCHAR2
    , p7_a110 in out nocopy  VARCHAR2
    , p7_a111 in out nocopy  NUMBER
    , p7_a112 in out nocopy  VARCHAR2
    , p7_a113 in out nocopy  NUMBER
    , p7_a114 in out nocopy  NUMBER
    , p7_a115 in out nocopy  VARCHAR2
    , p7_a116 in out nocopy  NUMBER
    , p7_a117 in out nocopy  VARCHAR2
    , p7_a118 in out nocopy  VARCHAR2
    , p7_a119 in out nocopy  NUMBER
    , p7_a120 in out nocopy  NUMBER
    , p7_a121 in out nocopy  NUMBER
    , p7_a122 in out nocopy  VARCHAR2
    , p7_a123 in out nocopy  VARCHAR2
    , p7_a124 in out nocopy  VARCHAR2
    , p7_a125 in out nocopy  VARCHAR2
    , p7_a126 in out nocopy  VARCHAR2
    , p7_a127 in out nocopy  VARCHAR2
    , p7_a128 in out nocopy  VARCHAR2
    , p7_a129 in out nocopy  VARCHAR2
    , p7_a130 in out nocopy  VARCHAR2
    , p7_a131 in out nocopy  DATE
    , p7_a132 in out nocopy  VARCHAR2
    , p7_a133 in out nocopy  VARCHAR2
    , p7_a134 in out nocopy  VARCHAR2
    , p7_a135 in out nocopy  VARCHAR2
    , p7_a136 in out nocopy  VARCHAR2
    , p7_a137 in out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_calling_prog  VARCHAR2
    , x_party_valid out nocopy  VARCHAR2
    , x_payee_valid out nocopy  VARCHAR2
    , p_vendor_id  NUMBER
  );
  procedure create_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  NUMBER
    , p7_a100  NUMBER
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
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  NUMBER
    , p7_a123  NUMBER
    , p7_a124  NUMBER
    , p7_a125  NUMBER
    , p7_a126  VARCHAR2
    , p7_a127  NUMBER
    , p7_a128  NUMBER
    , p7_a129  NUMBER
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  NUMBER
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  DATE
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  NUMBER
    , p7_a152  NUMBER
    , p7_a153  VARCHAR2
    , p7_a154  NUMBER
    , x_vendor_site_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
    , x_location_id out nocopy  NUMBER
  );
  procedure update_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  DATE
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  NUMBER
    , p7_a100  NUMBER
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
    , p7_a117  NUMBER
    , p7_a118  VARCHAR2
    , p7_a119  VARCHAR2
    , p7_a120  VARCHAR2
    , p7_a121  VARCHAR2
    , p7_a122  NUMBER
    , p7_a123  NUMBER
    , p7_a124  NUMBER
    , p7_a125  NUMBER
    , p7_a126  VARCHAR2
    , p7_a127  NUMBER
    , p7_a128  NUMBER
    , p7_a129  NUMBER
    , p7_a130  VARCHAR2
    , p7_a131  VARCHAR2
    , p7_a132  NUMBER
    , p7_a133  NUMBER
    , p7_a134  NUMBER
    , p7_a135  VARCHAR2
    , p7_a136  VARCHAR2
    , p7_a137  VARCHAR2
    , p7_a138  VARCHAR2
    , p7_a139  VARCHAR2
    , p7_a140  VARCHAR2
    , p7_a141  VARCHAR2
    , p7_a142  VARCHAR2
    , p7_a143  VARCHAR2
    , p7_a144  DATE
    , p7_a145  VARCHAR2
    , p7_a146  VARCHAR2
    , p7_a147  VARCHAR2
    , p7_a148  VARCHAR2
    , p7_a149  VARCHAR2
    , p7_a150  VARCHAR2
    , p7_a151  NUMBER
    , p7_a152  NUMBER
    , p7_a153  VARCHAR2
    , p7_a154  NUMBER
    , p_vendor_site_id  NUMBER
  );
  procedure validate_vendor_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  VARCHAR2
    , p7_a1 in out nocopy  VARCHAR2
    , p7_a2 in out nocopy  VARCHAR2
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  VARCHAR2
    , p7_a6 in out nocopy  VARCHAR2
    , p7_a7 in out nocopy  VARCHAR2
    , p7_a8 in out nocopy  DATE
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  NUMBER
    , p7_a14 in out nocopy  NUMBER
    , p7_a15 in out nocopy  NUMBER
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  NUMBER
    , p7_a18 in out nocopy  NUMBER
    , p7_a19 in out nocopy  NUMBER
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  NUMBER
    , p7_a25 in out nocopy  DATE
    , p7_a26 in out nocopy  NUMBER
    , p7_a27 in out nocopy  NUMBER
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  VARCHAR2
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  VARCHAR2
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  VARCHAR2
    , p7_a44 in out nocopy  VARCHAR2
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  VARCHAR2
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  VARCHAR2
    , p7_a50 in out nocopy  VARCHAR2
    , p7_a51 in out nocopy  VARCHAR2
    , p7_a52 in out nocopy  VARCHAR2
    , p7_a53 in out nocopy  VARCHAR2
    , p7_a54 in out nocopy  VARCHAR2
    , p7_a55 in out nocopy  NUMBER
    , p7_a56 in out nocopy  VARCHAR2
    , p7_a57 in out nocopy  VARCHAR2
    , p7_a58 in out nocopy  NUMBER
    , p7_a59 in out nocopy  VARCHAR2
    , p7_a60 in out nocopy  VARCHAR2
    , p7_a61 in out nocopy  NUMBER
    , p7_a62 in out nocopy  NUMBER
    , p7_a63 in out nocopy  VARCHAR2
    , p7_a64 in out nocopy  VARCHAR2
    , p7_a65 in out nocopy  VARCHAR2
    , p7_a66 in out nocopy  VARCHAR2
    , p7_a67 in out nocopy  VARCHAR2
    , p7_a68 in out nocopy  VARCHAR2
    , p7_a69 in out nocopy  VARCHAR2
    , p7_a70 in out nocopy  VARCHAR2
    , p7_a71 in out nocopy  VARCHAR2
    , p7_a72 in out nocopy  VARCHAR2
    , p7_a73 in out nocopy  VARCHAR2
    , p7_a74 in out nocopy  VARCHAR2
    , p7_a75 in out nocopy  VARCHAR2
    , p7_a76 in out nocopy  VARCHAR2
    , p7_a77 in out nocopy  VARCHAR2
    , p7_a78 in out nocopy  VARCHAR2
    , p7_a79 in out nocopy  VARCHAR2
    , p7_a80 in out nocopy  VARCHAR2
    , p7_a81 in out nocopy  VARCHAR2
    , p7_a82 in out nocopy  VARCHAR2
    , p7_a83 in out nocopy  VARCHAR2
    , p7_a84 in out nocopy  VARCHAR2
    , p7_a85 in out nocopy  VARCHAR2
    , p7_a86 in out nocopy  NUMBER
    , p7_a87 in out nocopy  VARCHAR2
    , p7_a88 in out nocopy  VARCHAR2
    , p7_a89 in out nocopy  VARCHAR2
    , p7_a90 in out nocopy  VARCHAR2
    , p7_a91 in out nocopy  NUMBER
    , p7_a92 in out nocopy  VARCHAR2
    , p7_a93 in out nocopy  VARCHAR2
    , p7_a94 in out nocopy  VARCHAR2
    , p7_a95 in out nocopy  VARCHAR2
    , p7_a96 in out nocopy  VARCHAR2
    , p7_a97 in out nocopy  VARCHAR2
    , p7_a98 in out nocopy  VARCHAR2
    , p7_a99 in out nocopy  NUMBER
    , p7_a100 in out nocopy  NUMBER
    , p7_a101 in out nocopy  VARCHAR2
    , p7_a102 in out nocopy  VARCHAR2
    , p7_a103 in out nocopy  VARCHAR2
    , p7_a104 in out nocopy  VARCHAR2
    , p7_a105 in out nocopy  VARCHAR2
    , p7_a106 in out nocopy  VARCHAR2
    , p7_a107 in out nocopy  VARCHAR2
    , p7_a108 in out nocopy  VARCHAR2
    , p7_a109 in out nocopy  VARCHAR2
    , p7_a110 in out nocopy  VARCHAR2
    , p7_a111 in out nocopy  VARCHAR2
    , p7_a112 in out nocopy  VARCHAR2
    , p7_a113 in out nocopy  VARCHAR2
    , p7_a114 in out nocopy  VARCHAR2
    , p7_a115 in out nocopy  VARCHAR2
    , p7_a116 in out nocopy  VARCHAR2
    , p7_a117 in out nocopy  NUMBER
    , p7_a118 in out nocopy  VARCHAR2
    , p7_a119 in out nocopy  VARCHAR2
    , p7_a120 in out nocopy  VARCHAR2
    , p7_a121 in out nocopy  VARCHAR2
    , p7_a122 in out nocopy  NUMBER
    , p7_a123 in out nocopy  NUMBER
    , p7_a124 in out nocopy  NUMBER
    , p7_a125 in out nocopy  NUMBER
    , p7_a126 in out nocopy  VARCHAR2
    , p7_a127 in out nocopy  NUMBER
    , p7_a128 in out nocopy  NUMBER
    , p7_a129 in out nocopy  NUMBER
    , p7_a130 in out nocopy  VARCHAR2
    , p7_a131 in out nocopy  VARCHAR2
    , p7_a132 in out nocopy  NUMBER
    , p7_a133 in out nocopy  NUMBER
    , p7_a134 in out nocopy  NUMBER
    , p7_a135 in out nocopy  VARCHAR2
    , p7_a136 in out nocopy  VARCHAR2
    , p7_a137 in out nocopy  VARCHAR2
    , p7_a138 in out nocopy  VARCHAR2
    , p7_a139 in out nocopy  VARCHAR2
    , p7_a140 in out nocopy  VARCHAR2
    , p7_a141 in out nocopy  VARCHAR2
    , p7_a142 in out nocopy  VARCHAR2
    , p7_a143 in out nocopy  VARCHAR2
    , p7_a144 in out nocopy  DATE
    , p7_a145 in out nocopy  VARCHAR2
    , p7_a146 in out nocopy  VARCHAR2
    , p7_a147 in out nocopy  VARCHAR2
    , p7_a148 in out nocopy  VARCHAR2
    , p7_a149 in out nocopy  VARCHAR2
    , p7_a150 in out nocopy  VARCHAR2
    , p7_a151 in out nocopy  NUMBER
    , p7_a152 in out nocopy  NUMBER
    , p7_a153 in out nocopy  VARCHAR2
    , p7_a154 in out nocopy  NUMBER
    , p_mode  VARCHAR2
    , p_calling_prog  VARCHAR2
    , x_party_site_valid out nocopy  VARCHAR2
    , x_location_valid out nocopy  VARCHAR2
    , x_payee_valid out nocopy  VARCHAR2
    , p_vendor_site_id  NUMBER
  );
  procedure create_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  DATE
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , x_vendor_contact_id out nocopy  NUMBER
    , x_per_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_rel_id out nocopy  NUMBER
    , x_org_contact_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
  );
  procedure update_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  DATE
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
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  VARCHAR2
    , p4_a46  NUMBER
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_vendor_contact(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 in out nocopy  NUMBER
    , p7_a1 in out nocopy  NUMBER
    , p7_a2 in out nocopy  NUMBER
    , p7_a3 in out nocopy  NUMBER
    , p7_a4 in out nocopy  NUMBER
    , p7_a5 in out nocopy  NUMBER
    , p7_a6 in out nocopy  NUMBER
    , p7_a7 in out nocopy  NUMBER
    , p7_a8 in out nocopy  NUMBER
    , p7_a9 in out nocopy  VARCHAR2
    , p7_a10 in out nocopy  VARCHAR2
    , p7_a11 in out nocopy  VARCHAR2
    , p7_a12 in out nocopy  VARCHAR2
    , p7_a13 in out nocopy  VARCHAR2
    , p7_a14 in out nocopy  VARCHAR2
    , p7_a15 in out nocopy  VARCHAR2
    , p7_a16 in out nocopy  VARCHAR2
    , p7_a17 in out nocopy  VARCHAR2
    , p7_a18 in out nocopy  VARCHAR2
    , p7_a19 in out nocopy  VARCHAR2
    , p7_a20 in out nocopy  VARCHAR2
    , p7_a21 in out nocopy  VARCHAR2
    , p7_a22 in out nocopy  VARCHAR2
    , p7_a23 in out nocopy  VARCHAR2
    , p7_a24 in out nocopy  VARCHAR2
    , p7_a25 in out nocopy  VARCHAR2
    , p7_a26 in out nocopy  VARCHAR2
    , p7_a27 in out nocopy  VARCHAR2
    , p7_a28 in out nocopy  VARCHAR2
    , p7_a29 in out nocopy  VARCHAR2
    , p7_a30 in out nocopy  VARCHAR2
    , p7_a31 in out nocopy  DATE
    , p7_a32 in out nocopy  VARCHAR2
    , p7_a33 in out nocopy  VARCHAR2
    , p7_a34 in out nocopy  VARCHAR2
    , p7_a35 in out nocopy  VARCHAR2
    , p7_a36 in out nocopy  VARCHAR2
    , p7_a37 in out nocopy  VARCHAR2
    , p7_a38 in out nocopy  VARCHAR2
    , p7_a39 in out nocopy  VARCHAR2
    , p7_a40 in out nocopy  VARCHAR2
    , p7_a41 in out nocopy  VARCHAR2
    , p7_a42 in out nocopy  VARCHAR2
    , p7_a43 in out nocopy  NUMBER
    , p7_a44 in out nocopy  NUMBER
    , p7_a45 in out nocopy  VARCHAR2
    , p7_a46 in out nocopy  NUMBER
    , p7_a47 in out nocopy  VARCHAR2
    , p7_a48 in out nocopy  VARCHAR2
    , p7_a49 in out nocopy  VARCHAR2
    , x_rel_party_valid out nocopy  VARCHAR2
    , x_per_party_valid out nocopy  VARCHAR2
    , x_rel_valid out nocopy  VARCHAR2
    , x_org_party_id out nocopy  NUMBER
    , x_org_contact_valid out nocopy  VARCHAR2
    , x_location_id out nocopy  NUMBER
    , x_party_site_valid out nocopy  VARCHAR2
  );
end ap_vendor_pub_pkg_w;

 

/
