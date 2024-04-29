--------------------------------------------------------
--  DDL for Package OZF_SYS_PARAMETERS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SYS_PARAMETERS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwsyss.pls 120.4.12010000.5 2009/07/27 09:35:47 nirprasa ship $ */
  procedure create_sys_parameters(p_api_version  NUMBER
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
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
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
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
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
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , x_set_of_books_id out nocopy  NUMBER
  );
  procedure update_sys_parameters(p_api_version  NUMBER
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
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  NUMBER
    , p7_a28  NUMBER
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  VARCHAR2
    , p7_a33  NUMBER
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
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
    , p7_a54  NUMBER
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  NUMBER
    , p7_a61  VARCHAR2
    , p7_a62  NUMBER
    , p7_a63  NUMBER
    , p7_a64  NUMBER
    , p7_a65  NUMBER
    , p7_a66  NUMBER
    , p7_a67  NUMBER
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  NUMBER
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  NUMBER
    , p7_a74  VARCHAR2
    , p7_a75  NUMBER
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
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  NUMBER
    , p7_a92  NUMBER
    , p7_a93  NUMBER
    , p7_a94  NUMBER
    , p_mode  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  );
  procedure validate_sys_parameters(p_api_version  NUMBER
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
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  NUMBER
    , p6_a15  VARCHAR2
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  VARCHAR2
    , p6_a27  NUMBER
    , p6_a28  NUMBER
    , p6_a29  NUMBER
    , p6_a30  NUMBER
    , p6_a31  NUMBER
    , p6_a32  VARCHAR2
    , p6_a33  NUMBER
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  NUMBER
    , p6_a37  NUMBER
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
    , p6_a55  NUMBER
    , p6_a56  VARCHAR2
    , p6_a57  NUMBER
    , p6_a58  VARCHAR2
    , p6_a59  VARCHAR2
    , p6_a60  NUMBER
    , p6_a61  VARCHAR2
    , p6_a62  NUMBER
    , p6_a63  NUMBER
    , p6_a64  NUMBER
    , p6_a65  NUMBER
    , p6_a66  NUMBER
    , p6_a67  NUMBER
    , p6_a68  VARCHAR2
    , p6_a69  VARCHAR2
    , p6_a70  NUMBER
    , p6_a71  VARCHAR2
    , p6_a72  VARCHAR2
    , p6_a73  NUMBER
    , p6_a74  VARCHAR2
    , p6_a75  NUMBER
    , p6_a76  VARCHAR2
    , p6_a77  VARCHAR2
    , p6_a78  VARCHAR2
    , p6_a79  VARCHAR2
    , p6_a80  VARCHAR2
    , p6_a81  VARCHAR2
    , p6_a82  VARCHAR2
    , p6_a83  VARCHAR2
    , p6_a84  VARCHAR2
    , p6_a85  VARCHAR2
    , p6_a86  VARCHAR2
    , p6_a87  VARCHAR2
    , p6_a88  VARCHAR2
    , p6_a89  VARCHAR2
    , p6_a90  VARCHAR2
    , p6_a91  NUMBER
    , p6_a92  NUMBER
    , p6_a93  NUMBER
    , p6_a94  NUMBER
  );
  procedure check_sys_parameters_items(p0_a0  NUMBER
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
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
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
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
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
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure check_sys_parameters_record(p0_a0  NUMBER
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
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
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
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
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
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
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
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  NUMBER
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  NUMBER
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  VARCHAR2
    , p1_a33  NUMBER
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  NUMBER
    , p1_a37  NUMBER
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  VARCHAR2
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  VARCHAR2
    , p1_a54  NUMBER
    , p1_a55  NUMBER
    , p1_a56  VARCHAR2
    , p1_a57  NUMBER
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  NUMBER
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  NUMBER
    , p1_a64  NUMBER
    , p1_a65  NUMBER
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  NUMBER
    , p1_a71  VARCHAR2
    , p1_a72  VARCHAR2
    , p1_a73  NUMBER
    , p1_a74  VARCHAR2
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  VARCHAR2
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  VARCHAR2
    , p1_a83  VARCHAR2
    , p1_a84  VARCHAR2
    , p1_a85  VARCHAR2
    , p1_a86  VARCHAR2
    , p1_a87  VARCHAR2
    , p1_a88  VARCHAR2
    , p1_a89  VARCHAR2
    , p1_a90  VARCHAR2
    , p1_a91  NUMBER
    , p1_a92  NUMBER
    , p1_a93  NUMBER
    , p1_a94  NUMBER
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_sys_parameters_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  DATE
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  NUMBER
    , p0_a29 out nocopy  NUMBER
    , p0_a30 out nocopy  NUMBER
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  NUMBER
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  VARCHAR2
    , p0_a51 out nocopy  VARCHAR2
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  VARCHAR2
    , p0_a54 out nocopy  NUMBER
    , p0_a55 out nocopy  NUMBER
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  NUMBER
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  NUMBER
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  NUMBER
    , p0_a63 out nocopy  NUMBER
    , p0_a64 out nocopy  NUMBER
    , p0_a65 out nocopy  NUMBER
    , p0_a66 out nocopy  NUMBER
    , p0_a67 out nocopy  NUMBER
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  NUMBER
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  NUMBER
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  VARCHAR2
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  VARCHAR2
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
    , p0_a82 out nocopy  VARCHAR2
    , p0_a83 out nocopy  VARCHAR2
    , p0_a84 out nocopy  VARCHAR2
    , p0_a85 out nocopy  VARCHAR2
    , p0_a86 out nocopy  VARCHAR2
    , p0_a87 out nocopy  VARCHAR2
    , p0_a88 out nocopy  VARCHAR2
    , p0_a89 out nocopy  VARCHAR2
    , p0_a90 out nocopy  VARCHAR2
    , p0_a91 out nocopy  NUMBER
    , p0_a92 out nocopy  NUMBER
    , p0_a93 out nocopy  NUMBER
    , p0_a94 out nocopy  NUMBER
  );
  procedure complete_sys_parameters_rec(p0_a0  NUMBER
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
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  NUMBER
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  VARCHAR2
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  NUMBER
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  NUMBER
    , p0_a37  NUMBER
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
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  NUMBER
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  NUMBER
    , p0_a74  VARCHAR2
    , p0_a75  NUMBER
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
    , p0_a91  NUMBER
    , p0_a92  NUMBER
    , p0_a93  NUMBER
    , p0_a94  NUMBER
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
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  NUMBER
    , p1_a30 out nocopy  NUMBER
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  NUMBER
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  VARCHAR2
    , p1_a51 out nocopy  VARCHAR2
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  NUMBER
    , p1_a55 out nocopy  NUMBER
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  NUMBER
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  NUMBER
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  NUMBER
    , p1_a63 out nocopy  NUMBER
    , p1_a64 out nocopy  NUMBER
    , p1_a65 out nocopy  NUMBER
    , p1_a66 out nocopy  NUMBER
    , p1_a67 out nocopy  NUMBER
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  NUMBER
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  NUMBER
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  VARCHAR2
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  VARCHAR2
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p1_a82 out nocopy  VARCHAR2
    , p1_a83 out nocopy  VARCHAR2
    , p1_a84 out nocopy  VARCHAR2
    , p1_a85 out nocopy  VARCHAR2
    , p1_a86 out nocopy  VARCHAR2
    , p1_a87 out nocopy  VARCHAR2
    , p1_a88 out nocopy  VARCHAR2
    , p1_a89 out nocopy  VARCHAR2
    , p1_a90 out nocopy  VARCHAR2
    , p1_a91 out nocopy  NUMBER
    , p1_a92 out nocopy  NUMBER
    , p1_a93 out nocopy  NUMBER
    , p1_a94 out nocopy  NUMBER
  );
end ozf_sys_parameters_pvt_w;

/
