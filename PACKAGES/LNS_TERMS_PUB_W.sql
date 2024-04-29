--------------------------------------------------------
--  DDL for Package LNS_TERMS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_TERMS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_TERMS_PUBJ_S.pls 120.4.12010000.8 2010/03/19 08:35:55 gparuchu ship $ */
  procedure create_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , x_term_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_term(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  DATE
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  DATE
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  NUMBER
    , p1_a26  VARCHAR2
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  DATE
    , p1_a30  DATE
    , p1_a31  DATE
    , p1_a32  VARCHAR2
    , p1_a33  DATE
    , p1_a34  DATE
    , p1_a35  DATE
    , p1_a36  VARCHAR2
    , p1_a37  NUMBER
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  DATE
    , p1_a47  DATE
    , p1_a48  NUMBER
    , p1_a49  NUMBER
    , p1_a50  VARCHAR2
    , p1_a51  VARCHAR2
    , p1_a52  VARCHAR2
    , p1_a53  DATE
    , p1_a54  VARCHAR2
    , p1_a55  NUMBER
    , p1_a56  NUMBER
    , p1_a57  VARCHAR2
    , p1_a58  VARCHAR2
    , p1_a59  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_loan_term_rec(p_init_msg_list  VARCHAR2
    , p_term_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  DATE
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  DATE
    , p2_a11 out nocopy  NUMBER
    , p2_a12 out nocopy  NUMBER
    , p2_a13 out nocopy  NUMBER
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  NUMBER
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  NUMBER
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  DATE
    , p2_a30 out nocopy  DATE
    , p2_a31 out nocopy  DATE
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  DATE
    , p2_a34 out nocopy  DATE
    , p2_a35 out nocopy  DATE
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  NUMBER
    , p2_a38 out nocopy  NUMBER
    , p2_a39 out nocopy  NUMBER
    , p2_a40 out nocopy  NUMBER
    , p2_a41 out nocopy  NUMBER
    , p2_a42 out nocopy  NUMBER
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  NUMBER
    , p2_a45 out nocopy  NUMBER
    , p2_a46 out nocopy  DATE
    , p2_a47 out nocopy  DATE
    , p2_a48 out nocopy  NUMBER
    , p2_a49 out nocopy  NUMBER
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  DATE
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  NUMBER
    , p2_a56 out nocopy  NUMBER
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_terms_pub_w;

/
