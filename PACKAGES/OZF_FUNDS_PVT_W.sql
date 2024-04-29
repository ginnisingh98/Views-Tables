--------------------------------------------------------
--  DDL for Package OZF_FUNDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUNDS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwfuns.pls 120.3 2008/06/11 06:06:52 kdass ship $ */
  procedure create_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , x_fund_id out nocopy  NUMBER
  );
  procedure update_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , p_mode  VARCHAR2
  );
  procedure validate_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  VARCHAR2
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  DATE
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  DATE
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  DATE
    , p6_a21  DATE
    , p6_a22  VARCHAR2
    , p6_a23  NUMBER
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  VARCHAR2
    , p6_a52  NUMBER
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  NUMBER
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  VARCHAR2
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  VARCHAR2
    , p6_a76  VARCHAR2
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
    , p6_a80  VARCHAR2
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  NUMBER
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  VARCHAR2
    , p6_a87  VARCHAR2
    , p6_a88  NUMBER
    , p6_a89  NUMBER
    , p6_a90  NUMBER
    , p6_a91  NUMBER
    , p6_a92  NUMBER
    , p6_a93  NUMBER
    , p6_a94  NUMBER
    , p6_a95  VARCHAR2
    , p6_a96  VARCHAR2
    , p6_a97  DATE
    , p6_a98  NUMBER
    , p6_a99  NUMBER
    , p6_a100  NUMBER
    , p6_a101  NUMBER
    , p6_a102  NUMBER
    , p6_a103  NUMBER
    , p6_a104  NUMBER
    , p6_a105  NUMBER
    , p6_a106  NUMBER
    , p6_a107  NUMBER
    , p6_a108  NUMBER
    , p6_a109  NUMBER
    , p6_a110  VARCHAR2
    , p6_a111  NUMBER
    , p6_a112  NUMBER
    , p6_a113  VARCHAR2
    , p6_a114  NUMBER
    , p6_a115  NUMBER
    , p6_a116  NUMBER
    , p6_a117  DATE
    , p6_a118  NUMBER
  );
  procedure check_fund_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  VARCHAR2
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  DATE
    , p2_a11  VARCHAR2
    , p2_a12  NUMBER
    , p2_a13  NUMBER
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  DATE
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  DATE
    , p2_a21  DATE
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  NUMBER
    , p2_a27  NUMBER
    , p2_a28  NUMBER
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  VARCHAR2
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  NUMBER
    , p2_a35  NUMBER
    , p2_a36  NUMBER
    , p2_a37  NUMBER
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  NUMBER
    , p2_a50  NUMBER
    , p2_a51  VARCHAR2
    , p2_a52  NUMBER
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  NUMBER
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  NUMBER
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  NUMBER
    , p2_a65  VARCHAR2
    , p2_a66  VARCHAR2
    , p2_a67  VARCHAR2
    , p2_a68  VARCHAR2
    , p2_a69  VARCHAR2
    , p2_a70  VARCHAR2
    , p2_a71  VARCHAR2
    , p2_a72  VARCHAR2
    , p2_a73  VARCHAR2
    , p2_a74  VARCHAR2
    , p2_a75  VARCHAR2
    , p2_a76  VARCHAR2
    , p2_a77  VARCHAR2
    , p2_a78  VARCHAR2
    , p2_a79  VARCHAR2
    , p2_a80  VARCHAR2
    , p2_a81  VARCHAR2
    , p2_a82  VARCHAR2
    , p2_a83  NUMBER
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  NUMBER
    , p2_a89  NUMBER
    , p2_a90  NUMBER
    , p2_a91  NUMBER
    , p2_a92  NUMBER
    , p2_a93  NUMBER
    , p2_a94  NUMBER
    , p2_a95  VARCHAR2
    , p2_a96  VARCHAR2
    , p2_a97  DATE
    , p2_a98  NUMBER
    , p2_a99  NUMBER
    , p2_a100  NUMBER
    , p2_a101  NUMBER
    , p2_a102  NUMBER
    , p2_a103  NUMBER
    , p2_a104  NUMBER
    , p2_a105  NUMBER
    , p2_a106  NUMBER
    , p2_a107  NUMBER
    , p2_a108  NUMBER
    , p2_a109  NUMBER
    , p2_a110  VARCHAR2
    , p2_a111  NUMBER
    , p2_a112  NUMBER
    , p2_a113  VARCHAR2
    , p2_a114  NUMBER
    , p2_a115  NUMBER
    , p2_a116  NUMBER
    , p2_a117  DATE
    , p2_a118  NUMBER
  );
  procedure check_fund_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  VARCHAR2
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  DATE
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , p1_a105  NUMBER
    , p1_a106  NUMBER
    , p1_a107  NUMBER
    , p1_a108  NUMBER
    , p1_a109  NUMBER
    , p1_a110  VARCHAR2
    , p1_a111  NUMBER
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  NUMBER
    , p1_a116  NUMBER
    , p1_a117  DATE
    , p1_a118  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_fund_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  VARCHAR2
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  DATE
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  DATE
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  DATE
    , p0_a21 out nocopy  DATE
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  NUMBER
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  VARCHAR2
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  VARCHAR2
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
    , p0_a82 out nocopy  VARCHAR2
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  NUMBER
    , p0_a89 out nocopy  NUMBER
    , p0_a90 out nocopy  NUMBER
    , p0_a91 out nocopy  NUMBER
    , p0_a92 out nocopy  NUMBER
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
    , p0_a95 out nocopy  VARCHAR2
    , p0_a96 out nocopy  VARCHAR2
    , p0_a97 out nocopy  DATE
    , p0_a98 out nocopy  NUMBER
    , p0_a99 out nocopy  NUMBER
    , p0_a100 out nocopy  NUMBER
    , p0_a101 out nocopy  NUMBER
    , p0_a102 out nocopy  NUMBER
    , p0_a103 out nocopy  NUMBER
    , p0_a104 out nocopy  NUMBER
    , p0_a105 out nocopy  NUMBER
    , p0_a106 out nocopy  NUMBER
    , p0_a107 out nocopy  NUMBER
    , p0_a108 out nocopy  NUMBER
    , p0_a109 out nocopy  NUMBER
    , p0_a110 out nocopy  VARCHAR2
    , p0_a111 out nocopy  NUMBER
    , p0_a112 out nocopy  NUMBER
    , p0_a113 out nocopy  VARCHAR2
    , p0_a114 out nocopy  NUMBER
    , p0_a115 out nocopy  NUMBER
    , p0_a116 out nocopy  NUMBER
    , p0_a117 out nocopy  DATE
    , p0_a118 out nocopy  NUMBER
  );
  procedure complete_fund_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  VARCHAR2
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  DATE
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  DATE
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  DATE
    , p1_a21 out nocopy  DATE
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  VARCHAR2
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  VARCHAR2
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  NUMBER
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  NUMBER
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  NUMBER
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
    , p1_a95 out nocopy  VARCHAR2
    , p1_a96 out nocopy  VARCHAR2
    , p1_a97 out nocopy  DATE
    , p1_a98 out nocopy  NUMBER
    , p1_a99 out nocopy  NUMBER
    , p1_a100 out nocopy  NUMBER
    , p1_a101 out nocopy  NUMBER
    , p1_a102 out nocopy  NUMBER
    , p1_a103 out nocopy  NUMBER
    , p1_a104 out nocopy  NUMBER
    , p1_a105 out nocopy  NUMBER
    , p1_a106 out nocopy  NUMBER
    , p1_a107 out nocopy  NUMBER
    , p1_a108 out nocopy  NUMBER
    , p1_a109 out nocopy  NUMBER
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  NUMBER
    , p1_a112 out nocopy  NUMBER
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  NUMBER
    , p1_a115 out nocopy  NUMBER
    , p1_a116 out nocopy  NUMBER
    , p1_a117 out nocopy  DATE
    , p1_a118 out nocopy  NUMBER
  );
  procedure check_fund_inter_entity(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  VARCHAR2
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  DATE
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  DATE
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  DATE
    , p0_a21  DATE
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  NUMBER
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  DATE
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  NUMBER
    , p0_a106  NUMBER
    , p0_a107  NUMBER
    , p0_a108  NUMBER
    , p0_a109  NUMBER
    , p0_a110  VARCHAR2
    , p0_a111  NUMBER
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  NUMBER
    , p0_a116  NUMBER
    , p0_a117  DATE
    , p0_a118  NUMBER
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  VARCHAR2
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  DATE
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  DATE
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  DATE
    , p1_a21  DATE
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  VARCHAR2
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  VARCHAR2
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  VARCHAR2
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  NUMBER
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  NUMBER
    , p1_a89  NUMBER
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  VARCHAR2
    , p1_a96  VARCHAR2
    , p1_a97  DATE
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , p1_a105  NUMBER
    , p1_a106  NUMBER
    , p1_a107  NUMBER
    , p1_a108  NUMBER
    , p1_a109  NUMBER
    , p1_a110  VARCHAR2
    , p1_a111  NUMBER
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  NUMBER
    , p1_a116  NUMBER
    , p1_a117  DATE
    , p1_a118  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure copy_fund(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_source_object_id  NUMBER
    , p_attributes_table JTF_VARCHAR2_TABLE_100
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_4000
    , x_new_object_id out nocopy  NUMBER
    , x_custom_setup_id out nocopy  NUMBER
  );
  procedure update_rollup_amount(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
  );
  procedure update_funds_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  DATE
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  DATE
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  DATE
    , p7_a21  DATE
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  NUMBER
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
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
    , p7_a83  NUMBER
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  NUMBER
    , p7_a89  NUMBER
    , p7_a90  NUMBER
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  DATE
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  NUMBER
    , p7_a106  NUMBER
    , p7_a107  NUMBER
    , p7_a108  NUMBER
    , p7_a109  NUMBER
    , p7_a110  VARCHAR2
    , p7_a111  NUMBER
    , p7_a112  NUMBER
    , p7_a113  VARCHAR2
    , p7_a114  NUMBER
    , p7_a115  NUMBER
    , p7_a116  NUMBER
    , p7_a117  DATE
    , p7_a118  NUMBER
    , p_mode  VARCHAR2
  );
end ozf_funds_pvt_w;

/
