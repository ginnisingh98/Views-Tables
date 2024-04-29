--------------------------------------------------------
--  DDL for Package IBE_PARTY_V2PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PARTY_V2PVT_W" AUTHID CURRENT_USER as
  /* $Header: IBEWPARS.pls 120.1 2005/06/20 09:27:34 appldev ship $ */
  procedure create_individual_user(p_username  VARCHAR2
    , p_password  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  DATE
    , p2_a23  VARCHAR2
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  VARCHAR2
    , p2_a61  NUMBER
    , p2_a62  VARCHAR2
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
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
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  VARCHAR2
    , p2_a91  VARCHAR2
    , p2_a92  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p_contact_preference  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_user_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_business_user(p_username  VARCHAR2
    , p_password  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  VARCHAR2
    , p2_a2  VARCHAR2
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  DATE
    , p2_a23  VARCHAR2
    , p2_a24  DATE
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  VARCHAR2
    , p2_a56  VARCHAR2
    , p2_a57  VARCHAR2
    , p2_a58  VARCHAR2
    , p2_a59  NUMBER
    , p2_a60  VARCHAR2
    , p2_a61  NUMBER
    , p2_a62  VARCHAR2
    , p2_a63  VARCHAR2
    , p2_a64  VARCHAR2
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
    , p2_a83  VARCHAR2
    , p2_a84  VARCHAR2
    , p2_a85  VARCHAR2
    , p2_a86  VARCHAR2
    , p2_a87  VARCHAR2
    , p2_a88  VARCHAR2
    , p2_a89  VARCHAR2
    , p2_a90  VARCHAR2
    , p2_a91  VARCHAR2
    , p2_a92  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  NUMBER
    , p3_a27  DATE
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  DATE
    , p3_a40  DATE
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
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
    , p3_a68  NUMBER
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  NUMBER
    , p3_a79  NUMBER
    , p3_a80  NUMBER
    , p3_a81  NUMBER
    , p3_a82  NUMBER
    , p3_a83  NUMBER
    , p3_a84  NUMBER
    , p3_a85  DATE
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  NUMBER
    , p3_a96  NUMBER
    , p3_a97  NUMBER
    , p3_a98  DATE
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  VARCHAR2
    , p3_a102  VARCHAR2
    , p3_a103  VARCHAR2
    , p3_a104  VARCHAR2
    , p3_a105  VARCHAR2
    , p3_a106  VARCHAR2
    , p3_a107  VARCHAR2
    , p3_a108  NUMBER
    , p3_a109  VARCHAR2
    , p3_a110  NUMBER
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
    , p3_a130  VARCHAR2
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  NUMBER
    , p3_a136  VARCHAR2
    , p3_a137  VARCHAR2
    , p3_a138  NUMBER
    , p3_a139  VARCHAR2
    , p3_a140  VARCHAR2
    , p3_a141  VARCHAR2
    , p3_a142  VARCHAR2
    , p3_a143  VARCHAR2
    , p3_a144  VARCHAR2
    , p3_a145  VARCHAR2
    , p3_a146  VARCHAR2
    , p3_a147  VARCHAR2
    , p3_a148  VARCHAR2
    , p3_a149  VARCHAR2
    , p3_a150  VARCHAR2
    , p3_a151  VARCHAR2
    , p3_a152  VARCHAR2
    , p3_a153  VARCHAR2
    , p3_a154  VARCHAR2
    , p3_a155  VARCHAR2
    , p3_a156  VARCHAR2
    , p3_a157  VARCHAR2
    , p3_a158  VARCHAR2
    , p3_a159  VARCHAR2
    , p3_a160  VARCHAR2
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  VARCHAR2
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
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
    , p4_a26  DATE
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  NUMBER
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  NUMBER
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
    , p4_a57  NUMBER
    , p4_a58  VARCHAR2
    , p4_a59  NUMBER
    , p4_a60  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  VARCHAR2
    , p6_a8  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p9_a0  VARCHAR2
    , p9_a1  DATE
    , p9_a2  NUMBER
    , p9_a3  VARCHAR2
    , p9_a4  VARCHAR2
    , p9_a5  VARCHAR2
    , p9_a6  VARCHAR2
    , p9_a7  VARCHAR2
    , p9_a8  VARCHAR2
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p_rel_contact_preference  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_org_party_id out nocopy  NUMBER
    , x_user_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_org_contact(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  DATE
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
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
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p_relationship_type  VARCHAR2
    , p_org_party_id  NUMBER
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  DATE
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p6_a0  VARCHAR2
    , p6_a1  VARCHAR2
    , p_created_by_module  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_person(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  DATE
    , p0_a23  VARCHAR2
    , p0_a24  DATE
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  DATE
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  VARCHAR2
    , p0_a61  NUMBER
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
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
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  DATE
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p_created_by_module  VARCHAR2
    , p_account  VARCHAR2
    , x_person_party_id out nocopy  NUMBER
    , x_account_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_organization(p0_a0  VARCHAR2
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  VARCHAR2
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  NUMBER
    , p0_a27  DATE
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  NUMBER
    , p0_a79  NUMBER
    , p0_a80  NUMBER
    , p0_a81  NUMBER
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  DATE
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  DATE
    , p0_a99  VARCHAR2
    , p0_a100  VARCHAR2
    , p0_a101  VARCHAR2
    , p0_a102  VARCHAR2
    , p0_a103  VARCHAR2
    , p0_a104  VARCHAR2
    , p0_a105  VARCHAR2
    , p0_a106  VARCHAR2
    , p0_a107  VARCHAR2
    , p0_a108  NUMBER
    , p0_a109  VARCHAR2
    , p0_a110  NUMBER
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
    , p0_a125  VARCHAR2
    , p0_a126  VARCHAR2
    , p0_a127  VARCHAR2
    , p0_a128  VARCHAR2
    , p0_a129  VARCHAR2
    , p0_a130  VARCHAR2
    , p0_a131  VARCHAR2
    , p0_a132  VARCHAR2
    , p0_a133  VARCHAR2
    , p0_a134  VARCHAR2
    , p0_a135  NUMBER
    , p0_a136  VARCHAR2
    , p0_a137  VARCHAR2
    , p0_a138  NUMBER
    , p0_a139  VARCHAR2
    , p0_a140  VARCHAR2
    , p0_a141  VARCHAR2
    , p0_a142  VARCHAR2
    , p0_a143  VARCHAR2
    , p0_a144  VARCHAR2
    , p0_a145  VARCHAR2
    , p0_a146  VARCHAR2
    , p0_a147  VARCHAR2
    , p0_a148  VARCHAR2
    , p0_a149  VARCHAR2
    , p0_a150  VARCHAR2
    , p0_a151  VARCHAR2
    , p0_a152  VARCHAR2
    , p0_a153  VARCHAR2
    , p0_a154  VARCHAR2
    , p0_a155  VARCHAR2
    , p0_a156  VARCHAR2
    , p0_a157  VARCHAR2
    , p0_a158  VARCHAR2
    , p0_a159  VARCHAR2
    , p0_a160  VARCHAR2
    , p0_a161  VARCHAR2
    , p0_a162  VARCHAR2
    , p0_a163  VARCHAR2
    , p0_a164  VARCHAR2
    , p0_a165  VARCHAR2
    , p0_a166  VARCHAR2
    , p0_a167  VARCHAR2
    , p0_a168  VARCHAR2
    , p0_a169  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  NUMBER
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  NUMBER
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
    , p3_a57  NUMBER
    , p3_a58  VARCHAR2
    , p3_a59  NUMBER
    , p3_a60  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
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
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  NUMBER
    , p_primary_billto  VARCHAR2
    , p_primary_shipto  VARCHAR2
    , p_billto  VARCHAR2
    , p_shipto  VARCHAR2
    , p_default_primary  VARCHAR2
    , p_created_by_module  VARCHAR2
    , p_account  VARCHAR2
    , x_org_party_id out nocopy  NUMBER
    , x_account_id out nocopy  NUMBER
    , x_party_site_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_contact_points(p_owner_table_id  NUMBER
    , p1_a0  VARCHAR2
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  VARCHAR2
    , p2_a4  VARCHAR2
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p3_a0  VARCHAR2
    , p3_a1  DATE
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p4_a0  VARCHAR2
    , p4_a1  VARCHAR2
    , p_contact_point_purpose  number
    , p_created_by_module  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure find_organization(x_org_id in out nocopy  NUMBER
    , x_org_num in out nocopy  VARCHAR2
    , x_org_name in out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );


procedure Save_Tca_Entities(p1_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a9  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a22  DATE := FND_API.G_MISS_DATE
    , p1_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a24  DATE := FND_API.G_MISS_DATE
    , p1_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a26  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a27  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a28  DATE := FND_API.G_MISS_DATE
    , p1_a29  NUMBER := FND_API.G_MISS_NUM
    , p1_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a31  NUMBER := FND_API.G_MISS_NUM
    , p1_a32  NUMBER := FND_API.G_MISS_NUM
    , p1_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a34  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a39  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a40  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a47  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a48  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a49  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a57  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a59  NUMBER := FND_API.G_MISS_NUM
    , p1_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a61  NUMBER := FND_API.G_MISS_NUM
    , p1_a62  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a63  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a64  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a65  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a66  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a67  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a68  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a69  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a70  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a71  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a72  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a73  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a74  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a75  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a76  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a77  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a78  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a79  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a80  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a81  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a82  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a83  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a84  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a85  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a86  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a87  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a88  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a89  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a90  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a91  VARCHAR2 := FND_API.G_MISS_CHAR
    , p1_a92  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_person_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_email_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p2_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p2_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_email_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_workph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p3_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a1  DATE := FND_API.G_MISS_DATE
    , p3_a2  NUMBER := FND_API.G_MISS_NUM
    , p3_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p3_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_workph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_homeph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p4_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a1  DATE := FND_API.G_MISS_DATE
    , p4_a2  NUMBER := FND_API.G_MISS_NUM
    , p4_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p4_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_homeph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_fax_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p5_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a1  DATE := FND_API.G_MISS_DATE
    , p5_a2  NUMBER := FND_API.G_MISS_NUM
    , p5_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p5_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_fax_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_contact_preference_id     NUMBER := FND_API.G_MISS_NUM
    , p_contact_preference        VARCHAR2 := FND_API.G_MISS_CHAR
    , p_cntct_pref_object_ver_num NUMBER := FND_API.G_MISS_NUM
    , p_cntct_level_table_id      NUMBER := FND_API.G_MISS_NUM
    , p_cntct_level_table_name    VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a8  NUMBER := FND_API.G_MISS_NUM
    , p6_a9  NUMBER := FND_API.G_MISS_NUM
    , p6_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a22  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a24  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a26  NUMBER := FND_API.G_MISS_NUM
    , p6_a27  DATE := FND_API.G_MISS_DATE
    , p6_a28  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a29  NUMBER := FND_API.G_MISS_NUM
    , p6_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a31  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a32  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a34  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a39  DATE := FND_API.G_MISS_DATE
    , p6_a40  DATE := FND_API.G_MISS_DATE
    , p6_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a47  NUMBER := FND_API.G_MISS_NUM
    , p6_a48  NUMBER := FND_API.G_MISS_NUM
    , p6_a49  NUMBER := FND_API.G_MISS_NUM
    , p6_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a57  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a59  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a61  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a62  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a63  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a64  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a65  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a66  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a67  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a68  NUMBER := FND_API.G_MISS_NUM
    , p6_a69  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a70  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a71  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a72  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a73  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a74  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a75  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a76  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a77  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a78  NUMBER := FND_API.G_MISS_NUM
    , p6_a79  NUMBER := FND_API.G_MISS_NUM
    , p6_a80  NUMBER := FND_API.G_MISS_NUM
    , p6_a81  NUMBER := FND_API.G_MISS_NUM
    , p6_a82  NUMBER := FND_API.G_MISS_NUM
    , p6_a83  NUMBER := FND_API.G_MISS_NUM
    , p6_a84  NUMBER := FND_API.G_MISS_NUM
    , p6_a85  DATE := FND_API.G_MISS_DATE
    , p6_a86  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a87  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a88  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a89  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a90  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a91  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a92  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a93  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a94  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a95  NUMBER := FND_API.G_MISS_NUM
    , p6_a96  NUMBER := FND_API.G_MISS_NUM
    , p6_a97  NUMBER := FND_API.G_MISS_NUM
    , p6_a98  DATE := FND_API.G_MISS_DATE
    , p6_a99  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a100  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a101  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a102  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a103  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a104  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a105  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a106  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a107  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a108  NUMBER := FND_API.G_MISS_NUM
    , p6_a109  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a110  NUMBER := FND_API.G_MISS_NUM
    , p6_a111  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a112  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a113  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a114  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a115  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a116  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a117  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a118  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a119  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a120  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a121  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a122  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a123  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a124  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a125  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a126  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a127  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a128  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a129  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a130  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a131  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a132  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a133  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a134  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a135  NUMBER := FND_API.G_MISS_NUM
    , p6_a136  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a137  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a138  NUMBER := FND_API.G_MISS_NUM
    , p6_a139  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a140  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a141  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a142  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a143  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a144  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a145  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a146  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a147  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a148  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a149  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a150  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a151  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a152  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a153  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a154  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a155  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a156  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a157  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a158  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a159  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a160  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a161  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a162  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a163  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a164  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a165  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a166  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a167  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a168  VARCHAR2 := FND_API.G_MISS_CHAR
    , p6_a169  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_org_object_version_number   NUMBER := FND_API.G_MISS_NUM
    , p7_a0  NUMBER := FND_API.G_MISS_NUM
    , p7_a1  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a2  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a9  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a10  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a11  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a12  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a13  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a14  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a15  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a16  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a17  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a18  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a19  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a20  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a21  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a22  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a23  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a24  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a25  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a26  DATE := FND_API.G_MISS_DATE
    , p7_a27  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a28  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a29  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a30  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a31  NUMBER := FND_API.G_MISS_NUM
    , p7_a32  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a33  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a34  NUMBER := FND_API.G_MISS_NUM
    , p7_a35  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a36  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a37  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a38  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a39  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a40  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a41  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a42  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a43  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a44  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a45  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a46  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a47  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a48  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a49  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a50  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a51  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a52  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a53  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a54  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a55  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a56  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a57  NUMBER := FND_API.G_MISS_NUM
    , p7_a58  VARCHAR2 := FND_API.G_MISS_CHAR
    , p7_a59  NUMBER := FND_API.G_MISS_NUM
    , p7_a60  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_loc_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_orgph_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p8_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a1  DATE := FND_API.G_MISS_DATE
    , p8_a2  NUMBER := FND_API.G_MISS_NUM
    , p8_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p8_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_orgph_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_orgfax_contact_point_id NUMBER := FND_API.G_MISS_NUM
    , p9_a0  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a1  DATE := FND_API.G_MISS_DATE
    , p9_a2  NUMBER := FND_API.G_MISS_NUM
    , p9_a3  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a4  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a5  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a6  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a7  VARCHAR2 := FND_API.G_MISS_CHAR
    , p9_a8  VARCHAR2 := FND_API.G_MISS_CHAR
    , p_orgfax_object_version_number NUMBER := FND_API.G_MISS_NUM
    , p_create_party_rel VARCHAR2 := FND_API.G_MISS_CHAR
    , p_created_by_module VARCHAR2 := FND_API.G_MISS_CHAR
    , x_person_party_id out nocopy  NUMBER
    , x_rel_party_id out nocopy  NUMBER
    , x_org_party_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );

end ibe_party_v2pvt_w;

 

/
