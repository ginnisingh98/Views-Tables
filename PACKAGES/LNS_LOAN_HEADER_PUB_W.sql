--------------------------------------------------------
--  DDL for Package LNS_LOAN_HEADER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_HEADER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_LNHDR_PUBJ_S.pls 120.6.12010000.4 2010/03/19 08:39:19 gparuchu ship $ */
  procedure create_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
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
    , p1_a46  VARCHAR2
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
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , x_loan_id out nocopy  NUMBER
    , x_loan_number out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
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
    , p1_a46  VARCHAR2
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
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_loan(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  DATE
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  DATE
    , p1_a23  DATE
    , p1_a24  DATE
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  NUMBER
    , p1_a29  VARCHAR2
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  DATE
    , p1_a35  NUMBER
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
    , p1_a46  VARCHAR2
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
    , p1_a57  DATE
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p1_a60  VARCHAR2
    , p1_a61  VARCHAR2
    , p1_a62  NUMBER
    , p1_a63  VARCHAR2
    , p1_a64  DATE
    , p1_a65  VARCHAR2
    , p1_a66  NUMBER
    , p1_a67  NUMBER
    , p1_a68  VARCHAR2
    , p1_a69  VARCHAR2
    , p1_a70  DATE
    , p1_a71  NUMBER
    , p1_a72  NUMBER
    , p1_a73  NUMBER
    , p1_a74  NUMBER
    , p1_a75  NUMBER
    , p1_a76  VARCHAR2
    , p1_a77  VARCHAR2
    , p1_a78  NUMBER
    , p1_a79  VARCHAR2
    , p1_a80  VARCHAR2
    , p1_a81  VARCHAR2
    , p1_a82  NUMBER
    , p1_a83  VARCHAR2
    , p1_a84  DATE
    , p1_a85  NUMBER
    , p1_a86  VARCHAR2
    , p1_a87  DATE
    , p1_a88  VARCHAR2
    , p1_a89  DATE
    , p1_a90  NUMBER
    , p1_a91  NUMBER
    , p1_a92  VARCHAR2
    , p1_a93  VARCHAR2
    , p1_a94  VARCHAR2
    , p1_a95  NUMBER
    , p1_a96  VARCHAR2
    , p1_a97  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_loan_header_rec(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  DATE
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  NUMBER
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , p2_a21 out nocopy  NUMBER
    , p2_a22 out nocopy  DATE
    , p2_a23 out nocopy  DATE
    , p2_a24 out nocopy  DATE
    , p2_a25 out nocopy  NUMBER
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  NUMBER
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  NUMBER
    , p2_a31 out nocopy  NUMBER
    , p2_a32 out nocopy  NUMBER
    , p2_a33 out nocopy  NUMBER
    , p2_a34 out nocopy  DATE
    , p2_a35 out nocopy  NUMBER
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  VARCHAR2
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  VARCHAR2
    , p2_a48 out nocopy  VARCHAR2
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  DATE
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  NUMBER
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  DATE
    , p2_a65 out nocopy  VARCHAR2
    , p2_a66 out nocopy  NUMBER
    , p2_a67 out nocopy  NUMBER
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  DATE
    , p2_a71 out nocopy  NUMBER
    , p2_a72 out nocopy  NUMBER
    , p2_a73 out nocopy  NUMBER
    , p2_a74 out nocopy  NUMBER
    , p2_a75 out nocopy  NUMBER
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  VARCHAR2
    , p2_a78 out nocopy  NUMBER
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  VARCHAR2
    , p2_a82 out nocopy  NUMBER
    , p2_a83 out nocopy  VARCHAR2
    , p2_a84 out nocopy  DATE
    , p2_a85 out nocopy  NUMBER
    , p2_a86 out nocopy  VARCHAR2
    , p2_a87 out nocopy  DATE
    , p2_a88 out nocopy  VARCHAR2
    , p2_a89 out nocopy  DATE
    , p2_a90 out nocopy  NUMBER
    , p2_a91 out nocopy  NUMBER
    , p2_a92 out nocopy  VARCHAR2
    , p2_a93 out nocopy  VARCHAR2
    , p2_a94 out nocopy  VARCHAR2
    , p2_a95 out nocopy  NUMBER
    , p2_a96 out nocopy  VARCHAR2
    , p2_a97 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_loan_header_pub_w;

/
