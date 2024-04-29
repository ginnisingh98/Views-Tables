--------------------------------------------------------
--  DDL for Package OKL_LEASE_QUOTE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_QUOTE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLELSQS.pls 120.7 2007/08/08 21:08:52 rravikir noship $ */
  procedure create_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
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
    , p3_a21  NUMBER
    , p3_a22  DATE
    , p3_a23  DATE
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  VARCHAR2
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  NUMBER
    , p3_a38  VARCHAR2
    , p3_a39  NUMBER
    , p3_a40  NUMBER
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  NUMBER
    , p3_a44  NUMBER
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  VARCHAR2
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
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
    , p3_a21  NUMBER
    , p3_a22  DATE
    , p3_a23  DATE
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  DATE
    , p3_a27  DATE
    , p3_a28  DATE
    , p3_a29  VARCHAR2
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  NUMBER
    , p3_a37  NUMBER
    , p3_a38  VARCHAR2
    , p3_a39  NUMBER
    , p3_a40  NUMBER
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  NUMBER
    , p3_a44  NUMBER
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  NUMBER
    , p3_a56  NUMBER
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  NUMBER
    , p3_a61  VARCHAR2
    , p3_a62  NUMBER
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  NUMBER
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  VARCHAR2
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure duplicate_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_quote_id  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
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
    , p4_a21  NUMBER
    , p4_a22  DATE
    , p4_a23  DATE
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  DATE
    , p4_a27  DATE
    , p4_a28  DATE
    , p4_a29  VARCHAR2
    , p4_a30  NUMBER
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  NUMBER
    , p4_a36  NUMBER
    , p4_a37  NUMBER
    , p4_a38  VARCHAR2
    , p4_a39  NUMBER
    , p4_a40  NUMBER
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  NUMBER
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  NUMBER
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  NUMBER
    , p4_a56  NUMBER
    , p4_a57  VARCHAR2
    , p4_a58  VARCHAR2
    , p4_a59  VARCHAR2
    , p4_a60  NUMBER
    , p4_a61  VARCHAR2
    , p4_a62  NUMBER
    , p4_a63  VARCHAR2
    , p4_a64  VARCHAR2
    , p4_a65  VARCHAR2
    , p4_a66  VARCHAR2
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  VARCHAR2
    , p4_a71  VARCHAR2
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  NUMBER
    , p5_a22 out nocopy  DATE
    , p5_a23 out nocopy  DATE
    , p5_a24 out nocopy  VARCHAR2
    , p5_a25 out nocopy  VARCHAR2
    , p5_a26 out nocopy  DATE
    , p5_a27 out nocopy  DATE
    , p5_a28 out nocopy  DATE
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  NUMBER
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , p5_a34 out nocopy  VARCHAR2
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  NUMBER
    , p5_a37 out nocopy  NUMBER
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  NUMBER
    , p5_a40 out nocopy  NUMBER
    , p5_a41 out nocopy  VARCHAR2
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  NUMBER
    , p5_a44 out nocopy  NUMBER
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  NUMBER
    , p5_a50 out nocopy  NUMBER
    , p5_a51 out nocopy  NUMBER
    , p5_a52 out nocopy  VARCHAR2
    , p5_a53 out nocopy  VARCHAR2
    , p5_a54 out nocopy  VARCHAR2
    , p5_a55 out nocopy  NUMBER
    , p5_a56 out nocopy  NUMBER
    , p5_a57 out nocopy  VARCHAR2
    , p5_a58 out nocopy  VARCHAR2
    , p5_a59 out nocopy  VARCHAR2
    , p5_a60 out nocopy  NUMBER
    , p5_a61 out nocopy  VARCHAR2
    , p5_a62 out nocopy  NUMBER
    , p5_a63 out nocopy  VARCHAR2
    , p5_a64 out nocopy  VARCHAR2
    , p5_a65 out nocopy  VARCHAR2
    , p5_a66 out nocopy  VARCHAR2
    , p5_a67 out nocopy  NUMBER
    , p5_a68 out nocopy  VARCHAR2
    , p5_a69 out nocopy  VARCHAR2
    , p5_a70 out nocopy  VARCHAR2
    , p5_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure duplicate_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_quote_id  NUMBER
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  VARCHAR2
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  VARCHAR2
    , p4_a21 out nocopy  NUMBER
    , p4_a22 out nocopy  DATE
    , p4_a23 out nocopy  DATE
    , p4_a24 out nocopy  VARCHAR2
    , p4_a25 out nocopy  VARCHAR2
    , p4_a26 out nocopy  DATE
    , p4_a27 out nocopy  DATE
    , p4_a28 out nocopy  DATE
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  NUMBER
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , p4_a34 out nocopy  VARCHAR2
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  NUMBER
    , p4_a37 out nocopy  NUMBER
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  NUMBER
    , p4_a40 out nocopy  NUMBER
    , p4_a41 out nocopy  VARCHAR2
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  NUMBER
    , p4_a44 out nocopy  NUMBER
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  NUMBER
    , p4_a50 out nocopy  NUMBER
    , p4_a51 out nocopy  NUMBER
    , p4_a52 out nocopy  VARCHAR2
    , p4_a53 out nocopy  VARCHAR2
    , p4_a54 out nocopy  VARCHAR2
    , p4_a55 out nocopy  NUMBER
    , p4_a56 out nocopy  NUMBER
    , p4_a57 out nocopy  VARCHAR2
    , p4_a58 out nocopy  VARCHAR2
    , p4_a59 out nocopy  VARCHAR2
    , p4_a60 out nocopy  NUMBER
    , p4_a61 out nocopy  VARCHAR2
    , p4_a62 out nocopy  NUMBER
    , p4_a63 out nocopy  VARCHAR2
    , p4_a64 out nocopy  VARCHAR2
    , p4_a65 out nocopy  VARCHAR2
    , p4_a66 out nocopy  VARCHAR2
    , p4_a67 out nocopy  NUMBER
    , p4_a68 out nocopy  VARCHAR2
    , p4_a69 out nocopy  VARCHAR2
    , p4_a70 out nocopy  VARCHAR2
    , p4_a71 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure cancel_lease_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_500
    , p3_a4 JTF_VARCHAR2_TABLE_500
    , p3_a5 JTF_VARCHAR2_TABLE_500
    , p3_a6 JTF_VARCHAR2_TABLE_500
    , p3_a7 JTF_VARCHAR2_TABLE_500
    , p3_a8 JTF_VARCHAR2_TABLE_500
    , p3_a9 JTF_VARCHAR2_TABLE_500
    , p3_a10 JTF_VARCHAR2_TABLE_500
    , p3_a11 JTF_VARCHAR2_TABLE_500
    , p3_a12 JTF_VARCHAR2_TABLE_500
    , p3_a13 JTF_VARCHAR2_TABLE_500
    , p3_a14 JTF_VARCHAR2_TABLE_500
    , p3_a15 JTF_VARCHAR2_TABLE_500
    , p3_a16 JTF_VARCHAR2_TABLE_500
    , p3_a17 JTF_VARCHAR2_TABLE_500
    , p3_a18 JTF_VARCHAR2_TABLE_200
    , p3_a19 JTF_VARCHAR2_TABLE_100
    , p3_a20 JTF_VARCHAR2_TABLE_100
    , p3_a21 JTF_NUMBER_TABLE
    , p3_a22 JTF_DATE_TABLE
    , p3_a23 JTF_DATE_TABLE
    , p3_a24 JTF_VARCHAR2_TABLE_100
    , p3_a25 JTF_VARCHAR2_TABLE_100
    , p3_a26 JTF_DATE_TABLE
    , p3_a27 JTF_DATE_TABLE
    , p3_a28 JTF_DATE_TABLE
    , p3_a29 JTF_VARCHAR2_TABLE_100
    , p3_a30 JTF_NUMBER_TABLE
    , p3_a31 JTF_NUMBER_TABLE
    , p3_a32 JTF_NUMBER_TABLE
    , p3_a33 JTF_VARCHAR2_TABLE_100
    , p3_a34 JTF_VARCHAR2_TABLE_100
    , p3_a35 JTF_NUMBER_TABLE
    , p3_a36 JTF_NUMBER_TABLE
    , p3_a37 JTF_NUMBER_TABLE
    , p3_a38 JTF_VARCHAR2_TABLE_100
    , p3_a39 JTF_NUMBER_TABLE
    , p3_a40 JTF_NUMBER_TABLE
    , p3_a41 JTF_VARCHAR2_TABLE_100
    , p3_a42 JTF_VARCHAR2_TABLE_100
    , p3_a43 JTF_NUMBER_TABLE
    , p3_a44 JTF_NUMBER_TABLE
    , p3_a45 JTF_NUMBER_TABLE
    , p3_a46 JTF_NUMBER_TABLE
    , p3_a47 JTF_NUMBER_TABLE
    , p3_a48 JTF_NUMBER_TABLE
    , p3_a49 JTF_NUMBER_TABLE
    , p3_a50 JTF_NUMBER_TABLE
    , p3_a51 JTF_NUMBER_TABLE
    , p3_a52 JTF_VARCHAR2_TABLE_100
    , p3_a53 JTF_VARCHAR2_TABLE_100
    , p3_a54 JTF_VARCHAR2_TABLE_100
    , p3_a55 JTF_NUMBER_TABLE
    , p3_a56 JTF_NUMBER_TABLE
    , p3_a57 JTF_VARCHAR2_TABLE_100
    , p3_a58 JTF_VARCHAR2_TABLE_100
    , p3_a59 JTF_VARCHAR2_TABLE_100
    , p3_a60 JTF_NUMBER_TABLE
    , p3_a61 JTF_VARCHAR2_TABLE_100
    , p3_a62 JTF_NUMBER_TABLE
    , p3_a63 JTF_VARCHAR2_TABLE_100
    , p3_a64 JTF_VARCHAR2_TABLE_100
    , p3_a65 JTF_VARCHAR2_TABLE_100
    , p3_a66 JTF_VARCHAR2_TABLE_100
    , p3_a67 JTF_NUMBER_TABLE
    , p3_a68 JTF_VARCHAR2_TABLE_300
    , p3_a69 JTF_VARCHAR2_TABLE_300
    , p3_a70 JTF_VARCHAR2_TABLE_2000
    , p3_a71 JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_lease_qte(p0_a0  NUMBER
    , p0_a1  NUMBER
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
    , p0_a21  NUMBER
    , p0_a22  DATE
    , p0_a23  DATE
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  DATE
    , p0_a27  DATE
    , p0_a28  DATE
    , p0_a29  VARCHAR2
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  NUMBER
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  NUMBER
    , p0_a61  VARCHAR2
    , p0_a62  NUMBER
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  NUMBER
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
end okl_lease_quote_pvt_w;

/
