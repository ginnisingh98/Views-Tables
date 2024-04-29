--------------------------------------------------------
--  DDL for Package OZF_FUND_UTILIZED_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_UTILIZED_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwfuts.pls 120.7.12010000.2 2008/08/14 15:42:33 nirprasa ship $ */
  procedure create_utilization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_create_gl_entry  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  DATE
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  DATE
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  VARCHAR2
    , p8_a16  NUMBER
    , p8_a17  VARCHAR2
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  DATE
    , p8_a26  NUMBER
    , p8_a27  VARCHAR2
    , p8_a28  DATE
    , p8_a29  NUMBER
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , p8_a45  VARCHAR2
    , p8_a46  NUMBER
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  NUMBER
    , p8_a51  NUMBER
    , p8_a52  DATE
    , p8_a53  VARCHAR2
    , p8_a54  NUMBER
    , p8_a55  NUMBER
    , p8_a56  NUMBER
    , p8_a57  NUMBER
    , p8_a58  NUMBER
    , p8_a59  NUMBER
    , p8_a60  NUMBER
    , p8_a61  NUMBER
    , p8_a62  NUMBER
    , p8_a63  NUMBER
    , p8_a64  NUMBER
    , p8_a65  NUMBER
    , p8_a66  NUMBER
    , p8_a67  VARCHAR2
    , p8_a68  NUMBER
    , p8_a69  VARCHAR2
    , p8_a70  NUMBER
    , p8_a71  NUMBER
    , p8_a72  NUMBER
    , p8_a73  NUMBER
    , p8_a74  NUMBER
    , p8_a75  NUMBER
    , p8_a76  NUMBER
    , p8_a77  NUMBER
    , p8_a78  NUMBER
    , p8_a79  NUMBER
    , x_utilization_id out nocopy  NUMBER
  );
  procedure update_utilization(p_api_version  NUMBER
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
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  DATE
    , p7_a26  NUMBER
    , p7_a27  VARCHAR2
    , p7_a28  DATE
    , p7_a29  NUMBER
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
    , p7_a46  NUMBER
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  NUMBER
    , p7_a57  NUMBER
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  NUMBER
    , p7_a61  NUMBER
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  VARCHAR2
    , p7_a68  NUMBER
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  NUMBER
    , p7_a72  NUMBER
    , p7_a73  NUMBER
    , p7_a74  NUMBER
    , p7_a75  NUMBER
    , p7_a76  NUMBER
    , p7_a77  NUMBER
    , p7_a78  NUMBER
    , p7_a79  NUMBER
    , p_mode  VARCHAR2
  );
  procedure validate_utilization(p_api_version  NUMBER
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
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  DATE
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  DATE
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  DATE
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
    , p6_a55  NUMBER
    , p6_a56  NUMBER
    , p6_a57  NUMBER
    , p6_a58  NUMBER
    , p6_a59  NUMBER
    , p6_a60  NUMBER
    , p6_a61  NUMBER
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  VARCHAR2
    , p6_a68  NUMBER
    , p6_a69  VARCHAR2
    , p6_a70  NUMBER
    , p6_a71  NUMBER
    , p6_a72  NUMBER
    , p6_a73  NUMBER
    , p6_a74  NUMBER
    , p6_a75  NUMBER
    , p6_a76  NUMBER
    , p6_a77  NUMBER
    , p6_a78  NUMBER
    , p6_a79  NUMBER
  );
  procedure check_utilization_items(p_validation_mode  VARCHAR2
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
    , p2_a13  VARCHAR2
    , p2_a14  NUMBER
    , p2_a15  VARCHAR2
    , p2_a16  NUMBER
    , p2_a17  VARCHAR2
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p2_a21  NUMBER
    , p2_a22  NUMBER
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  DATE
    , p2_a26  NUMBER
    , p2_a27  VARCHAR2
    , p2_a28  DATE
    , p2_a29  NUMBER
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
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
    , p2_a46  NUMBER
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  NUMBER
    , p2_a51  NUMBER
    , p2_a52  DATE
    , p2_a53  VARCHAR2
    , p2_a54  NUMBER
    , p2_a55  NUMBER
    , p2_a56  NUMBER
    , p2_a57  NUMBER
    , p2_a58  NUMBER
    , p2_a59  NUMBER
    , p2_a60  NUMBER
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  NUMBER
    , p2_a65  NUMBER
    , p2_a66  NUMBER
    , p2_a67  VARCHAR2
    , p2_a68  NUMBER
    , p2_a69  VARCHAR2
    , p2_a70  NUMBER
    , p2_a71  NUMBER
    , p2_a72  NUMBER
    , p2_a73  NUMBER
    , p2_a74  NUMBER
    , p2_a75  NUMBER
    , p2_a76  NUMBER
    , p2_a77  NUMBER
    , p2_a78  NUMBER
    , p2_a79  NUMBER
  );
  procedure check_utilization_record(p0_a0  NUMBER
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
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  DATE
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  DATE
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
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
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
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  DATE
    , p1_a26  NUMBER
    , p1_a27  VARCHAR2
    , p1_a28  DATE
    , p1_a29  NUMBER
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  NUMBER
    , p1_a51  NUMBER
    , p1_a52  DATE
    , p1_a53  VARCHAR2
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  NUMBER
    , p1_a58  NUMBER
    , p1_a59  NUMBER
    , p1_a60  NUMBER
    , p1_a61  NUMBER
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  VARCHAR2
    , p1_a68  NUMBER
    , p1_a69  VARCHAR2
    , p1_a70  NUMBER
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  NUMBER
    , p1_a77  NUMBER
    , p1_a78  NUMBER
    , p1_a79  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_utilization_rec(p0_a0 out nocopy  NUMBER
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
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  DATE
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  DATE
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  DATE
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  NUMBER
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  NUMBER
    , p0_a59 out nocopy  NUMBER
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  NUMBER
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  NUMBER
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  NUMBER
    , p0_a72 out nocopy  NUMBER
    , p0_a73 out nocopy  NUMBER
    , p0_a74 out nocopy  NUMBER
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  NUMBER
    , p0_a78 out nocopy  NUMBER
    , p0_a79 out nocopy  NUMBER
  );
  procedure complete_utilization_rec(p0_a0  NUMBER
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
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  DATE
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  DATE
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
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  NUMBER
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  VARCHAR2
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  NUMBER
    , p0_a59  NUMBER
    , p0_a60  NUMBER
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  VARCHAR2
    , p0_a68  NUMBER
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  NUMBER
    , p0_a75  NUMBER
    , p0_a76  NUMBER
    , p0_a77  NUMBER
    , p0_a78  NUMBER
    , p0_a79  NUMBER
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
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  DATE
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  DATE
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  DATE
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  NUMBER
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  NUMBER
    , p1_a59 out nocopy  NUMBER
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  NUMBER
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  NUMBER
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  NUMBER
    , p1_a72 out nocopy  NUMBER
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  NUMBER
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  NUMBER
    , p1_a78 out nocopy  NUMBER
    , p1_a79 out nocopy  NUMBER
  );
  procedure create_act_utilization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  DATE
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  DATE
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  DATE
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR
    , p7_a29  VARCHAR
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  NUMBER
    , p7_a35  DATE
    , p7_a36  NUMBER
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  VARCHAR2
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
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
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p8_a0  VARCHAR2
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  DATE
    , p8_a11  DATE
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  VARCHAR2
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  VARCHAR2
    , p8_a44  VARCHAR2
    , x_act_budget_id out nocopy  NUMBER
  );
end ozf_fund_utilized_pvt_w;

/
