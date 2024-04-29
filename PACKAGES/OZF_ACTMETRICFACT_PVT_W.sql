--------------------------------------------------------
--  DDL for Package OZF_ACTMETRICFACT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTMETRICFACT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwamfs.pls 120.2 2006/06/02 09:34:54 inanaiah ship $ */
  procedure init_actmetricfact_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  VARCHAR2
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  NUMBER
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  NUMBER
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  NUMBER
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  NUMBER
    , p0_a44 out nocopy  NUMBER
    , p0_a45 out nocopy  NUMBER
    , p0_a46 out nocopy  NUMBER
    , p0_a47 out nocopy  NUMBER
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  NUMBER
    , p0_a53 out nocopy  NUMBER
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
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  NUMBER
    , p0_a69 out nocopy  NUMBER
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
    , p0_a80 out nocopy  NUMBER
    , p0_a81 out nocopy  DATE
    , p0_a82 out nocopy  DATE
    , p0_a83 out nocopy  NUMBER
    , p0_a84 out nocopy  NUMBER
    , p0_a85 out nocopy  NUMBER
    , p0_a86 out nocopy  NUMBER
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  NUMBER
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  VARCHAR2
    , p0_a92 out nocopy  DATE
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
    , p0_a95 out nocopy  NUMBER
    , p0_a96 out nocopy  NUMBER
    , p0_a97 out nocopy  NUMBER
    , p0_a98 out nocopy  NUMBER
    , p0_a99 out nocopy  NUMBER
    , p0_a100 out nocopy  NUMBER
    , p0_a101 out nocopy  NUMBER
    , p0_a102 out nocopy  NUMBER
    , p0_a103 out nocopy  NUMBER
    , p0_a104 out nocopy  NUMBER
  );
  procedure create_actmetricfact(p_api_version  NUMBER
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
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
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
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  NUMBER
    , p7_a53  NUMBER
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
    , p7_a67  NUMBER
    , p7_a68  NUMBER
    , p7_a69  NUMBER
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
    , p7_a80  NUMBER
    , p7_a81  DATE
    , p7_a82  DATE
    , p7_a83  NUMBER
    , p7_a84  NUMBER
    , p7_a85  NUMBER
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  DATE
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  NUMBER
    , p7_a96  NUMBER
    , p7_a97  NUMBER
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , x_activity_metric_fact_id out nocopy  NUMBER
  );
  procedure update_actmetricfact(p_api_version  NUMBER
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
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
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
    , p7_a35  NUMBER
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  NUMBER
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  NUMBER
    , p7_a53  NUMBER
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
    , p7_a67  NUMBER
    , p7_a68  NUMBER
    , p7_a69  NUMBER
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
    , p7_a80  NUMBER
    , p7_a81  DATE
    , p7_a82  DATE
    , p7_a83  NUMBER
    , p7_a84  NUMBER
    , p7_a85  NUMBER
    , p7_a86  NUMBER
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  NUMBER
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  DATE
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p7_a95  NUMBER
    , p7_a96  NUMBER
    , p7_a97  NUMBER
    , p7_a98  NUMBER
    , p7_a99  NUMBER
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  NUMBER
    , p7_a103  NUMBER
    , p7_a104  NUMBER
  );
  procedure validate_actmetfact(p_api_version  NUMBER
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
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  VARCHAR2
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
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
    , p6_a35  NUMBER
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  NUMBER
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  NUMBER
    , p6_a42  NUMBER
    , p6_a43  NUMBER
    , p6_a44  NUMBER
    , p6_a45  NUMBER
    , p6_a46  NUMBER
    , p6_a47  NUMBER
    , p6_a48  NUMBER
    , p6_a49  NUMBER
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  NUMBER
    , p6_a53  NUMBER
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
    , p6_a67  NUMBER
    , p6_a68  NUMBER
    , p6_a69  NUMBER
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
    , p6_a80  NUMBER
    , p6_a81  DATE
    , p6_a82  DATE
    , p6_a83  NUMBER
    , p6_a84  NUMBER
    , p6_a85  NUMBER
    , p6_a86  NUMBER
    , p6_a87  VARCHAR2
    , p6_a88  VARCHAR2
    , p6_a89  NUMBER
    , p6_a90  VARCHAR2
    , p6_a91  VARCHAR2
    , p6_a92  DATE
    , p6_a93  NUMBER
    , p6_a94  NUMBER
    , p6_a95  NUMBER
    , p6_a96  NUMBER
    , p6_a97  NUMBER
    , p6_a98  NUMBER
    , p6_a99  NUMBER
    , p6_a100  NUMBER
    , p6_a101  NUMBER
    , p6_a102  NUMBER
    , p6_a103  NUMBER
    , p6_a104  NUMBER
  );
  procedure validate_actmetfact_items(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
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
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
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
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
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
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_actmetfact_rec(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
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
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
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
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
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
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
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
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  NUMBER
    , p1_a16  VARCHAR2
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  NUMBER
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
    , p1_a35  NUMBER
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  NUMBER
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  NUMBER
    , p1_a51  NUMBER
    , p1_a52  NUMBER
    , p1_a53  NUMBER
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
    , p1_a67  NUMBER
    , p1_a68  NUMBER
    , p1_a69  NUMBER
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
    , p1_a80  NUMBER
    , p1_a81  DATE
    , p1_a82  DATE
    , p1_a83  NUMBER
    , p1_a84  NUMBER
    , p1_a85  NUMBER
    , p1_a86  NUMBER
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  NUMBER
    , p1_a90  VARCHAR2
    , p1_a91  VARCHAR2
    , p1_a92  DATE
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p1_a95  NUMBER
    , p1_a96  NUMBER
    , p1_a97  NUMBER
    , p1_a98  NUMBER
    , p1_a99  NUMBER
    , p1_a100  NUMBER
    , p1_a101  NUMBER
    , p1_a102  NUMBER
    , p1_a103  NUMBER
    , p1_a104  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
  procedure complete_actmetfact_rec(p0_a0  NUMBER
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
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
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
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  NUMBER
    , p0_a53  NUMBER
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
    , p0_a67  NUMBER
    , p0_a68  NUMBER
    , p0_a69  NUMBER
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
    , p0_a80  NUMBER
    , p0_a81  DATE
    , p0_a82  DATE
    , p0_a83  NUMBER
    , p0_a84  NUMBER
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  DATE
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p0_a95  NUMBER
    , p0_a96  NUMBER
    , p0_a97  NUMBER
    , p0_a98  NUMBER
    , p0_a99  NUMBER
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  NUMBER
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  VARCHAR2
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
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
    , p1_a35 out nocopy  NUMBER
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  NUMBER
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  NUMBER
    , p1_a44 out nocopy  NUMBER
    , p1_a45 out nocopy  NUMBER
    , p1_a46 out nocopy  NUMBER
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  NUMBER
    , p1_a53 out nocopy  NUMBER
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
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  NUMBER
    , p1_a69 out nocopy  NUMBER
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
    , p1_a80 out nocopy  NUMBER
    , p1_a81 out nocopy  DATE
    , p1_a82 out nocopy  DATE
    , p1_a83 out nocopy  NUMBER
    , p1_a84 out nocopy  NUMBER
    , p1_a85 out nocopy  NUMBER
    , p1_a86 out nocopy  NUMBER
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  NUMBER
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  VARCHAR2
    , p1_a92 out nocopy  DATE
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
    , p1_a95 out nocopy  NUMBER
    , p1_a96 out nocopy  NUMBER
    , p1_a97 out nocopy  NUMBER
    , p1_a98 out nocopy  NUMBER
    , p1_a99 out nocopy  NUMBER
    , p1_a100 out nocopy  NUMBER
    , p1_a101 out nocopy  NUMBER
    , p1_a102 out nocopy  NUMBER
    , p1_a103 out nocopy  NUMBER
    , p1_a104 out nocopy  NUMBER
  );
  procedure create_formula(p_api_version  NUMBER
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
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , x_formula_id out nocopy  NUMBER
  );
  procedure validate_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
  );
  procedure validate_formula_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_formula_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  DATE
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure create_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  DATE
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , x_formula_entry_id out nocopy  NUMBER
  );
  procedure validate_formula_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  NUMBER
    , p6_a3  VARCHAR2
    , p6_a4  VARCHAR2
    , p6_a5  VARCHAR2
    , p6_a6  VARCHAR2
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
  );
  procedure validate_form_ent_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure validate_form_ent_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
    , p1_a6  VARCHAR2
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , x_return_status out nocopy  VARCHAR2
  );
end ozf_actmetricfact_pvt_w;

 

/
