--------------------------------------------------------
--  DDL for Package AMS_EVENTOFFER_PVT_W_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_EVENTOFFER_PVT_W_NEW" AUTHID CURRENT_USER as
  /* $Header: amsaevos.pls 120.0 2005/08/24 12:05 sikalyan noship $ */
  procedure create_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  DATE
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  NUMBER
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  VARCHAR2
    , p4_a38  DATE
    , p4_a39  DATE
    , p4_a40  DATE
    , p4_a41  DATE
    , p4_a42  DATE
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  DATE
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  DATE
    , p4_a52  NUMBER
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  NUMBER
    , p4_a64  NUMBER
    , p4_a65  NUMBER
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  NUMBER
    , p4_a70  NUMBER
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  NUMBER
    , p4_a77  NUMBER
    , p4_a78  VARCHAR2
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  NUMBER
    , p4_a82  NUMBER
    , p4_a83  VARCHAR2
    , p4_a84  NUMBER
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
    , p4_a105  NUMBER
    , p4_a106  VARCHAR2
    , p4_a107  NUMBER
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  NUMBER
    , p4_a113  VARCHAR2
    , p4_a114  NUMBER
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  NUMBER
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  DATE
    , p4_a126  DATE
    , p4_a127  NUMBER
    , p4_a128  NUMBER
    , p4_a129  VARCHAR2
    , p4_a130  VARCHAR2
    , p4_a131  VARCHAR2
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  VARCHAR2
    , p4_a136  NUMBER
    , p4_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_evo_id out nocopy  NUMBER
  );
  procedure update_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  DATE
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  NUMBER
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  NUMBER
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  VARCHAR2
    , p4_a38  DATE
    , p4_a39  DATE
    , p4_a40  DATE
    , p4_a41  DATE
    , p4_a42  DATE
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  DATE
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  DATE
    , p4_a52  NUMBER
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  NUMBER
    , p4_a64  NUMBER
    , p4_a65  NUMBER
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  NUMBER
    , p4_a70  NUMBER
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  NUMBER
    , p4_a77  NUMBER
    , p4_a78  VARCHAR2
    , p4_a79  VARCHAR2
    , p4_a80  VARCHAR2
    , p4_a81  NUMBER
    , p4_a82  NUMBER
    , p4_a83  VARCHAR2
    , p4_a84  NUMBER
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
    , p4_a105  NUMBER
    , p4_a106  VARCHAR2
    , p4_a107  NUMBER
    , p4_a108  VARCHAR2
    , p4_a109  VARCHAR2
    , p4_a110  VARCHAR2
    , p4_a111  VARCHAR2
    , p4_a112  NUMBER
    , p4_a113  VARCHAR2
    , p4_a114  NUMBER
    , p4_a115  VARCHAR2
    , p4_a116  VARCHAR2
    , p4_a117  VARCHAR2
    , p4_a118  NUMBER
    , p4_a119  VARCHAR2
    , p4_a120  VARCHAR2
    , p4_a121  VARCHAR2
    , p4_a122  VARCHAR2
    , p4_a123  VARCHAR2
    , p4_a124  VARCHAR2
    , p4_a125  DATE
    , p4_a126  DATE
    , p4_a127  NUMBER
    , p4_a128  NUMBER
    , p4_a129  VARCHAR2
    , p4_a130  VARCHAR2
    , p4_a131  VARCHAR2
    , p4_a132  VARCHAR2
    , p4_a133  VARCHAR2
    , p4_a134  VARCHAR2
    , p4_a135  VARCHAR2
    , p4_a136  NUMBER
    , p4_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_event_offer(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  DATE
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  NUMBER
    , p3_a14  DATE
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  NUMBER
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  VARCHAR2
    , p3_a38  DATE
    , p3_a39  DATE
    , p3_a40  DATE
    , p3_a41  DATE
    , p3_a42  DATE
    , p3_a43  DATE
    , p3_a44  DATE
    , p3_a45  DATE
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  DATE
    , p3_a52  NUMBER
    , p3_a53  VARCHAR2
    , p3_a54  NUMBER
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  NUMBER
    , p3_a70  NUMBER
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  NUMBER
    , p3_a77  NUMBER
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  VARCHAR2
    , p3_a81  NUMBER
    , p3_a82  NUMBER
    , p3_a83  VARCHAR2
    , p3_a84  NUMBER
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
    , p3_a105  NUMBER
    , p3_a106  VARCHAR2
    , p3_a107  NUMBER
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  NUMBER
    , p3_a113  VARCHAR2
    , p3_a114  NUMBER
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  VARCHAR2
    , p3_a118  NUMBER
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  VARCHAR2
    , p3_a125  DATE
    , p3_a126  DATE
    , p3_a127  NUMBER
    , p3_a128  NUMBER
    , p3_a129  VARCHAR2
    , p3_a130  VARCHAR2
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  VARCHAR2
    , p3_a136  NUMBER
    , p3_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure check_evo_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
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
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_evo_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
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
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  DATE
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  NUMBER
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  VARCHAR2
    , p1_a38  DATE
    , p1_a39  DATE
    , p1_a40  DATE
    , p1_a41  DATE
    , p1_a42  DATE
    , p1_a43  DATE
    , p1_a44  DATE
    , p1_a45  DATE
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  DATE
    , p1_a52  NUMBER
    , p1_a53  VARCHAR2
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  NUMBER
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  NUMBER
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  VARCHAR2
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  NUMBER
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  VARCHAR2
    , p1_a76  NUMBER
    , p1_a77  NUMBER
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  NUMBER
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  NUMBER
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  VARCHAR2
    , p1_a90  VARCHAR2
    , p1_a91  VARCHAR2
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
    , p1_a105  NUMBER
    , p1_a106  VARCHAR2
    , p1_a107  NUMBER
    , p1_a108  VARCHAR2
    , p1_a109  VARCHAR2
    , p1_a110  VARCHAR2
    , p1_a111  VARCHAR2
    , p1_a112  NUMBER
    , p1_a113  VARCHAR2
    , p1_a114  NUMBER
    , p1_a115  VARCHAR2
    , p1_a116  VARCHAR2
    , p1_a117  VARCHAR2
    , p1_a118  NUMBER
    , p1_a119  VARCHAR2
    , p1_a120  VARCHAR2
    , p1_a121  VARCHAR2
    , p1_a122  VARCHAR2
    , p1_a123  VARCHAR2
    , p1_a124  VARCHAR2
    , p1_a125  DATE
    , p1_a126  DATE
    , p1_a127  NUMBER
    , p1_a128  NUMBER
    , p1_a129  VARCHAR2
    , p1_a130  VARCHAR2
    , p1_a131  VARCHAR2
    , p1_a132  VARCHAR2
    , p1_a133  VARCHAR2
    , p1_a134  VARCHAR2
    , p1_a135  VARCHAR2
    , p1_a136  NUMBER
    , p1_a137  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_evo_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  DATE
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  DATE
    , p0_a39 out nocopy  DATE
    , p0_a40 out nocopy  DATE
    , p0_a41 out nocopy  DATE
    , p0_a42 out nocopy  DATE
    , p0_a43 out nocopy  DATE
    , p0_a44 out nocopy  DATE
    , p0_a45 out nocopy  DATE
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  DATE
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  NUMBER
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  VARCHAR2
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  NUMBER
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  NUMBER
    , p0_a82 out nocopy  NUMBER
    , p0_a83 out nocopy  VARCHAR2
    , p0_a84 out nocopy  NUMBER
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  VARCHAR2
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  VARCHAR2
    , p0_a92 out nocopy  VARCHAR2
    , p0_a93 out nocopy  VARCHAR2
    , p0_a94 out nocopy  VARCHAR2
    , p0_a95 out nocopy  VARCHAR2
    , p0_a96 out nocopy  VARCHAR2
    , p0_a97 out nocopy  VARCHAR2
    , p0_a98 out nocopy  VARCHAR2
    , p0_a99 out nocopy  VARCHAR2
    , p0_a100 out nocopy  VARCHAR2
    , p0_a101 out nocopy  VARCHAR2
    , p0_a102 out nocopy  VARCHAR2
    , p0_a103 out nocopy  VARCHAR2
    , p0_a104 out nocopy  VARCHAR2
    , p0_a105 out nocopy  NUMBER
    , p0_a106 out nocopy  VARCHAR2
    , p0_a107 out nocopy  NUMBER
    , p0_a108 out nocopy  VARCHAR2
    , p0_a109 out nocopy  VARCHAR2
    , p0_a110 out nocopy  VARCHAR2
    , p0_a111 out nocopy  VARCHAR2
    , p0_a112 out nocopy  NUMBER
    , p0_a113 out nocopy  VARCHAR2
    , p0_a114 out nocopy  NUMBER
    , p0_a115 out nocopy  VARCHAR2
    , p0_a116 out nocopy  VARCHAR2
    , p0_a117 out nocopy  VARCHAR2
    , p0_a118 out nocopy  NUMBER
    , p0_a119 out nocopy  VARCHAR2
    , p0_a120 out nocopy  VARCHAR2
    , p0_a121 out nocopy  VARCHAR2
    , p0_a122 out nocopy  VARCHAR2
    , p0_a123 out nocopy  VARCHAR2
    , p0_a124 out nocopy  VARCHAR2
    , p0_a125 out nocopy  DATE
    , p0_a126 out nocopy  DATE
    , p0_a127 out nocopy  NUMBER
    , p0_a128 out nocopy  NUMBER
    , p0_a129 out nocopy  VARCHAR2
    , p0_a130 out nocopy  VARCHAR2
    , p0_a131 out nocopy  VARCHAR2
    , p0_a132 out nocopy  VARCHAR2
    , p0_a133 out nocopy  VARCHAR2
    , p0_a134 out nocopy  VARCHAR2
    , p0_a135 out nocopy  VARCHAR2
    , p0_a136 out nocopy  NUMBER
    , p0_a137 out nocopy  VARCHAR2
  );
  procedure complete_evo_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  DATE
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  VARCHAR2
    , p0_a38  DATE
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  DATE
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  DATE
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  DATE
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  NUMBER
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  VARCHAR2
    , p0_a84  NUMBER
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
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
    , p0_a105  NUMBER
    , p0_a106  VARCHAR2
    , p0_a107  NUMBER
    , p0_a108  VARCHAR2
    , p0_a109  VARCHAR2
    , p0_a110  VARCHAR2
    , p0_a111  VARCHAR2
    , p0_a112  NUMBER
    , p0_a113  VARCHAR2
    , p0_a114  NUMBER
    , p0_a115  VARCHAR2
    , p0_a116  VARCHAR2
    , p0_a117  VARCHAR2
    , p0_a118  NUMBER
    , p0_a119  VARCHAR2
    , p0_a120  VARCHAR2
    , p0_a121  VARCHAR2
    , p0_a122  VARCHAR2
    , p0_a123  VARCHAR2
    , p0_a124  VARCHAR2
    , p0_a125  DATE
    , p0_a126  DATE
    , p0_a127  NUMBER
    , p0_a128  NUMBER
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  VARCHAR2
    , p0_a136  NUMBER
    , p0_a137  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  DATE
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  DATE
    , p1_a39 out nocopy  DATE
    , p1_a40 out nocopy  DATE
    , p1_a41 out nocopy  DATE
    , p1_a42 out nocopy  DATE
    , p1_a43 out nocopy  DATE
    , p1_a44 out nocopy  DATE
    , p1_a45 out nocopy  DATE
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  DATE
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  NUMBER
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  VARCHAR2
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  NUMBER
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  NUMBER
    , p1_a82 out nocopy  NUMBER
    , p1_a83 out nocopy  VARCHAR2
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  VARCHAR2
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  VARCHAR2
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
    , p1_a105 out nocopy  NUMBER
    , p1_a106 out nocopy  VARCHAR2
    , p1_a107 out nocopy  NUMBER
    , p1_a108 out nocopy  VARCHAR2
    , p1_a109 out nocopy  VARCHAR2
    , p1_a110 out nocopy  VARCHAR2
    , p1_a111 out nocopy  VARCHAR2
    , p1_a112 out nocopy  NUMBER
    , p1_a113 out nocopy  VARCHAR2
    , p1_a114 out nocopy  NUMBER
    , p1_a115 out nocopy  VARCHAR2
    , p1_a116 out nocopy  VARCHAR2
    , p1_a117 out nocopy  VARCHAR2
    , p1_a118 out nocopy  NUMBER
    , p1_a119 out nocopy  VARCHAR2
    , p1_a120 out nocopy  VARCHAR2
    , p1_a121 out nocopy  VARCHAR2
    , p1_a122 out nocopy  VARCHAR2
    , p1_a123 out nocopy  VARCHAR2
    , p1_a124 out nocopy  VARCHAR2
    , p1_a125 out nocopy  DATE
    , p1_a126 out nocopy  DATE
    , p1_a127 out nocopy  NUMBER
    , p1_a128 out nocopy  NUMBER
    , p1_a129 out nocopy  VARCHAR2
    , p1_a130 out nocopy  VARCHAR2
    , p1_a131 out nocopy  VARCHAR2
    , p1_a132 out nocopy  VARCHAR2
    , p1_a133 out nocopy  VARCHAR2
    , p1_a134 out nocopy  VARCHAR2
    , p1_a135 out nocopy  VARCHAR2
    , p1_a136 out nocopy  NUMBER
    , p1_a137 out nocopy  VARCHAR2
  );
end ams_eventoffer_pvt_w_new;

 

/
