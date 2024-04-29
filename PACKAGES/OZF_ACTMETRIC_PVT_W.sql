--------------------------------------------------------
--  DDL for Package OZF_ACTMETRIC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTMETRIC_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwamts.pls 115.1 2003/10/10 11:15:46 kdass noship $ */
  procedure init_actmetric_rec(p0_a0 in out nocopy  NUMBER
    , p0_a1 in out nocopy  DATE
    , p0_a2 in out nocopy  NUMBER
    , p0_a3 in out nocopy  DATE
    , p0_a4 in out nocopy  NUMBER
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  NUMBER
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  VARCHAR2
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  VARCHAR2
    , p0_a12 in out nocopy  NUMBER
    , p0_a13 in out nocopy  NUMBER
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  NUMBER
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  NUMBER
    , p0_a20 in out nocopy  VARCHAR2
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  NUMBER
    , p0_a23 in out nocopy  DATE
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  VARCHAR2
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  NUMBER
    , p0_a34 in out nocopy  NUMBER
    , p0_a35 in out nocopy  NUMBER
    , p0_a36 in out nocopy  NUMBER
    , p0_a37 in out nocopy  NUMBER
    , p0_a38 in out nocopy  NUMBER
    , p0_a39 in out nocopy  DATE
    , p0_a40 in out nocopy  DATE
    , p0_a41 in out nocopy  NUMBER
    , p0_a42 in out nocopy  NUMBER
    , p0_a43 in out nocopy  NUMBER
    , p0_a44 in out nocopy  NUMBER
    , p0_a45 in out nocopy  NUMBER
    , p0_a46 in out nocopy  NUMBER
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  VARCHAR2
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  VARCHAR2
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  VARCHAR2
    , p0_a61 in out nocopy  VARCHAR2
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  DATE
    , p0_a68 in out nocopy  NUMBER
    , p0_a69 in out nocopy  NUMBER
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  NUMBER
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  NUMBER
    , p0_a78 in out nocopy  VARCHAR2
    , p0_a79 in out nocopy  VARCHAR2
  );
  procedure create_actmetric(p_api_version  NUMBER
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
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  DATE
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
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
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  DATE
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , x_activity_metric_id out nocopy  NUMBER
  );
  procedure update_actmetric(p_api_version  NUMBER
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
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  DATE
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  DATE
    , p7_a40  DATE
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
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
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  DATE
    , p7_a68  NUMBER
    , p7_a69  NUMBER
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
    , p7_a76  VARCHAR2
    , p7_a77  NUMBER
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
  );
  procedure validate_actmetric(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  VARCHAR2
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  VARCHAR2
    , p6_a19  NUMBER
    , p6_a20  VARCHAR2
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  DATE
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  DATE
    , p6_a40  DATE
    , p6_a41  NUMBER
    , p6_a42  NUMBER
    , p6_a43  NUMBER
    , p6_a44  NUMBER
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  VARCHAR2
    , p6_a55  VARCHAR2
    , p6_a56  VARCHAR2
    , p6_a57  VARCHAR2
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  VARCHAR2
    , p6_a61  VARCHAR2
    , p6_a62  VARCHAR2
    , p6_a63  VARCHAR2
    , p6_a64  VARCHAR2
    , p6_a65  VARCHAR2
    , p6_a66  VARCHAR2
    , p6_a67  DATE
    , p6_a68  NUMBER
    , p6_a69  NUMBER
    , p6_a70  VARCHAR2
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  VARCHAR2
    , p6_a74  VARCHAR2
    , p6_a75  NUMBER
    , p6_a76  VARCHAR2
    , p6_a77  NUMBER
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
  );
  procedure validate_actmetric_items(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
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
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_actmetric_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
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
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  NUMBER
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  VARCHAR2
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  DATE
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  VARCHAR2
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  DATE
    , p1_a40  DATE
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  NUMBER
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  VARCHAR2
    , p1_a55  VARCHAR2
    , p1_a56  VARCHAR2
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  VARCHAR2
    , p1_a63  VARCHAR2
    , p1_a64  VARCHAR2
    , p1_a65  VARCHAR2
    , p1_a66  VARCHAR2
    , p1_a67  DATE
    , p1_a68  NUMBER
    , p1_a69  NUMBER
    , p1_a70  VARCHAR2
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  VARCHAR2
    , p1_a74  VARCHAR2
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  NUMBER
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_actmetric_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  DATE
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  DATE
    , p0_a40  DATE
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
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
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  DATE
    , p0_a68  NUMBER
    , p0_a69  NUMBER
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
    , p0_a76  VARCHAR2
    , p0_a77  NUMBER
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p1_a0 in out nocopy  NUMBER
    , p1_a1 in out nocopy  DATE
    , p1_a2 in out nocopy  NUMBER
    , p1_a3 in out nocopy  DATE
    , p1_a4 in out nocopy  NUMBER
    , p1_a5 in out nocopy  NUMBER
    , p1_a6 in out nocopy  NUMBER
    , p1_a7 in out nocopy  NUMBER
    , p1_a8 in out nocopy  VARCHAR2
    , p1_a9 in out nocopy  VARCHAR2
    , p1_a10 in out nocopy  NUMBER
    , p1_a11 in out nocopy  VARCHAR2
    , p1_a12 in out nocopy  NUMBER
    , p1_a13 in out nocopy  NUMBER
    , p1_a14 in out nocopy  VARCHAR2
    , p1_a15 in out nocopy  NUMBER
    , p1_a16 in out nocopy  NUMBER
    , p1_a17 in out nocopy  NUMBER
    , p1_a18 in out nocopy  VARCHAR2
    , p1_a19 in out nocopy  NUMBER
    , p1_a20 in out nocopy  VARCHAR2
    , p1_a21 in out nocopy  NUMBER
    , p1_a22 in out nocopy  NUMBER
    , p1_a23 in out nocopy  DATE
    , p1_a24 in out nocopy  NUMBER
    , p1_a25 in out nocopy  NUMBER
    , p1_a26 in out nocopy  VARCHAR2
    , p1_a27 in out nocopy  NUMBER
    , p1_a28 in out nocopy  NUMBER
    , p1_a29 in out nocopy  NUMBER
    , p1_a30 in out nocopy  VARCHAR2
    , p1_a31 in out nocopy  NUMBER
    , p1_a32 in out nocopy  NUMBER
    , p1_a33 in out nocopy  NUMBER
    , p1_a34 in out nocopy  NUMBER
    , p1_a35 in out nocopy  NUMBER
    , p1_a36 in out nocopy  NUMBER
    , p1_a37 in out nocopy  NUMBER
    , p1_a38 in out nocopy  NUMBER
    , p1_a39 in out nocopy  DATE
    , p1_a40 in out nocopy  DATE
    , p1_a41 in out nocopy  NUMBER
    , p1_a42 in out nocopy  NUMBER
    , p1_a43 in out nocopy  NUMBER
    , p1_a44 in out nocopy  NUMBER
    , p1_a45 in out nocopy  NUMBER
    , p1_a46 in out nocopy  NUMBER
    , p1_a47 in out nocopy  VARCHAR2
    , p1_a48 in out nocopy  VARCHAR2
    , p1_a49 in out nocopy  VARCHAR2
    , p1_a50 in out nocopy  VARCHAR2
    , p1_a51 in out nocopy  VARCHAR2
    , p1_a52 in out nocopy  VARCHAR2
    , p1_a53 in out nocopy  VARCHAR2
    , p1_a54 in out nocopy  VARCHAR2
    , p1_a55 in out nocopy  VARCHAR2
    , p1_a56 in out nocopy  VARCHAR2
    , p1_a57 in out nocopy  VARCHAR2
    , p1_a58 in out nocopy  VARCHAR2
    , p1_a59 in out nocopy  VARCHAR2
    , p1_a60 in out nocopy  VARCHAR2
    , p1_a61 in out nocopy  VARCHAR2
    , p1_a62 in out nocopy  VARCHAR2
    , p1_a63 in out nocopy  VARCHAR2
    , p1_a64 in out nocopy  VARCHAR2
    , p1_a65 in out nocopy  VARCHAR2
    , p1_a66 in out nocopy  VARCHAR2
    , p1_a67 in out nocopy  DATE
    , p1_a68 in out nocopy  NUMBER
    , p1_a69 in out nocopy  NUMBER
    , p1_a70 in out nocopy  VARCHAR2
    , p1_a71 in out nocopy  VARCHAR2
    , p1_a72 in out nocopy  VARCHAR2
    , p1_a73 in out nocopy  VARCHAR2
    , p1_a74 in out nocopy  VARCHAR2
    , p1_a75 in out nocopy  NUMBER
    , p1_a76 in out nocopy  VARCHAR2
    , p1_a77 in out nocopy  NUMBER
    , p1_a78 in out nocopy  VARCHAR2
    , p1_a79 in out nocopy  VARCHAR2
  );
end ozf_actmetric_pvt_w;

 

/
