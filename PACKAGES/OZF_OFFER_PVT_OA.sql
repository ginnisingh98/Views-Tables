--------------------------------------------------------
--  DDL for Package OZF_OFFER_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_PVT_OA" AUTHID CURRENT_USER as
  /* $Header: ozfaofus.pls 120.2 2006/07/20 12:01:09 mgudivak ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ozf_offer_pvt.modifier_line_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_2000
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_NUMBER_TABLE
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_NUMBER_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_NUMBER_TABLE
    , a63 JTF_NUMBER_TABLE
    , a64 JTF_NUMBER_TABLE
    , a65 JTF_NUMBER_TABLE
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_NUMBER_TABLE
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p2(t ozf_offer_pvt.modifier_line_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_2000
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_NUMBER_TABLE
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_NUMBER_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_NUMBER_TABLE
    , a63 out nocopy JTF_NUMBER_TABLE
    , a64 out nocopy JTF_NUMBER_TABLE
    , a65 out nocopy JTF_NUMBER_TABLE
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_NUMBER_TABLE
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_offer_pvt.pricing_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ozf_offer_pvt.pricing_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_offer_pvt.qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p6(t ozf_offer_pvt.qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure process_modifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
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
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  DATE
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  NUMBER
    , p7_a65  VARCHAR2
    , p7_a66  NUMBER
    , p7_a67  NUMBER
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
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p8_a7 JTF_DATE_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_NUMBER_TABLE
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_NUMBER_TABLE
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_NUMBER_TABLE
    , p8_a20 JTF_NUMBER_TABLE
    , p8_a21 JTF_VARCHAR2_TABLE_100
    , p8_a22 JTF_VARCHAR2_TABLE_100
    , p8_a23 JTF_VARCHAR2_TABLE_100
    , p8_a24 JTF_VARCHAR2_TABLE_300
    , p8_a25 JTF_VARCHAR2_TABLE_100
    , p8_a26 JTF_NUMBER_TABLE
    , p8_a27 JTF_VARCHAR2_TABLE_100
    , p8_a28 JTF_VARCHAR2_TABLE_100
    , p8_a29 JTF_VARCHAR2_TABLE_300
    , p8_a30 JTF_VARCHAR2_TABLE_100
    , p8_a31 JTF_VARCHAR2_TABLE_100
    , p8_a32 JTF_VARCHAR2_TABLE_100
    , p8_a33 JTF_VARCHAR2_TABLE_300
    , p8_a34 JTF_VARCHAR2_TABLE_300
    , p8_a35 JTF_VARCHAR2_TABLE_100
    , p8_a36 JTF_VARCHAR2_TABLE_300
    , p8_a37 JTF_VARCHAR2_TABLE_300
    , p8_a38 JTF_NUMBER_TABLE
    , p8_a39 JTF_VARCHAR2_TABLE_2000
    , p8_a40 JTF_VARCHAR2_TABLE_100
    , p8_a41 JTF_VARCHAR2_TABLE_300
    , p8_a42 JTF_VARCHAR2_TABLE_300
    , p8_a43 JTF_VARCHAR2_TABLE_300
    , p8_a44 JTF_VARCHAR2_TABLE_300
    , p8_a45 JTF_VARCHAR2_TABLE_300
    , p8_a46 JTF_VARCHAR2_TABLE_300
    , p8_a47 JTF_VARCHAR2_TABLE_300
    , p8_a48 JTF_VARCHAR2_TABLE_300
    , p8_a49 JTF_VARCHAR2_TABLE_300
    , p8_a50 JTF_VARCHAR2_TABLE_300
    , p8_a51 JTF_VARCHAR2_TABLE_300
    , p8_a52 JTF_VARCHAR2_TABLE_300
    , p8_a53 JTF_VARCHAR2_TABLE_300
    , p8_a54 JTF_VARCHAR2_TABLE_300
    , p8_a55 JTF_VARCHAR2_TABLE_300
    , p8_a56 JTF_NUMBER_TABLE
    , p8_a57 JTF_NUMBER_TABLE
    , p8_a58 JTF_NUMBER_TABLE
    , p8_a59 JTF_NUMBER_TABLE
    , p8_a60 JTF_NUMBER_TABLE
    , p8_a61 JTF_NUMBER_TABLE
    , p8_a62 JTF_NUMBER_TABLE
    , p8_a63 JTF_NUMBER_TABLE
    , p8_a64 JTF_NUMBER_TABLE
    , p8_a65 JTF_NUMBER_TABLE
    , p8_a66 JTF_VARCHAR2_TABLE_100
    , p8_a67 JTF_NUMBER_TABLE
    , p8_a68 JTF_NUMBER_TABLE
    , p8_a69 JTF_VARCHAR2_TABLE_300
    , p8_a70 JTF_VARCHAR2_TABLE_300
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
  );
/*
  procedure create_offer_tiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_VARCHAR2_TABLE_100
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_300
    , p6_a25 JTF_VARCHAR2_TABLE_100
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_100
    , p6_a29 JTF_VARCHAR2_TABLE_300
    , p6_a30 JTF_VARCHAR2_TABLE_100
    , p6_a31 JTF_VARCHAR2_TABLE_100
    , p6_a32 JTF_VARCHAR2_TABLE_100
    , p6_a33 JTF_VARCHAR2_TABLE_300
    , p6_a34 JTF_VARCHAR2_TABLE_300
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_300
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_VARCHAR2_TABLE_2000
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_300
    , p6_a42 JTF_VARCHAR2_TABLE_300
    , p6_a43 JTF_VARCHAR2_TABLE_300
    , p6_a44 JTF_VARCHAR2_TABLE_300
    , p6_a45 JTF_VARCHAR2_TABLE_300
    , p6_a46 JTF_VARCHAR2_TABLE_300
    , p6_a47 JTF_VARCHAR2_TABLE_300
    , p6_a48 JTF_VARCHAR2_TABLE_300
    , p6_a49 JTF_VARCHAR2_TABLE_300
    , p6_a50 JTF_VARCHAR2_TABLE_300
    , p6_a51 JTF_VARCHAR2_TABLE_300
    , p6_a52 JTF_VARCHAR2_TABLE_300
    , p6_a53 JTF_VARCHAR2_TABLE_300
    , p6_a54 JTF_VARCHAR2_TABLE_300
    , p6_a55 JTF_VARCHAR2_TABLE_300
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_NUMBER_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_NUMBER_TABLE
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_NUMBER_TABLE
    , p6_a63 JTF_NUMBER_TABLE
    , p6_a64 JTF_NUMBER_TABLE
    , p6_a65 JTF_NUMBER_TABLE
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_VARCHAR2_TABLE_300
    , p6_a70 JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_DATE_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_DATE_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_NUMBER_TABLE
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a54 out nocopy JTF_DATE_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a62 out nocopy JTF_NUMBER_TABLE
    , p8_a63 out nocopy JTF_NUMBER_TABLE
    , p8_a64 out nocopy JTF_NUMBER_TABLE
    , p8_a65 out nocopy JTF_NUMBER_TABLE
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_NUMBER_TABLE
    , p8_a68 out nocopy JTF_NUMBER_TABLE
    , p8_a69 out nocopy JTF_DATE_TABLE
    , p8_a70 out nocopy JTF_NUMBER_TABLE
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a72 out nocopy JTF_DATE_TABLE
    , p8_a73 out nocopy JTF_NUMBER_TABLE
    , p8_a74 out nocopy JTF_NUMBER_TABLE
    , p8_a75 out nocopy JTF_NUMBER_TABLE
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a86 out nocopy JTF_NUMBER_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_100
  );
*/
  procedure process_market_qualifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_300
    , p6_a3 JTF_VARCHAR2_TABLE_300
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_300
    , p6_a15 JTF_VARCHAR2_TABLE_300
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_300
    , p6_a18 JTF_VARCHAR2_TABLE_300
    , p6_a19 JTF_VARCHAR2_TABLE_300
    , p6_a20 JTF_VARCHAR2_TABLE_300
    , p6_a21 JTF_VARCHAR2_TABLE_300
    , p6_a22 JTF_VARCHAR2_TABLE_300
    , p6_a23 JTF_VARCHAR2_TABLE_300
    , p6_a24 JTF_VARCHAR2_TABLE_300
    , p6_a25 JTF_VARCHAR2_TABLE_300
    , p6_a26 JTF_VARCHAR2_TABLE_300
    , p6_a27 JTF_VARCHAR2_TABLE_300
    , p6_a28 JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_DATE_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_DATE_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_DATE_TABLE
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a35 out nocopy JTF_NUMBER_TABLE
    , p8_a36 out nocopy JTF_NUMBER_TABLE
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_DATE_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a48 out nocopy JTF_NUMBER_TABLE
    , p8_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a50 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a51 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure process_exclusions(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_300
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_VARCHAR2_TABLE_100
    , p6_a8 JTF_VARCHAR2_TABLE_100
    , p6_a9 JTF_VARCHAR2_TABLE_300
    , p6_a10 JTF_VARCHAR2_TABLE_300
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , x_error_location out nocopy  NUMBER
  );
  procedure process_adv_options(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p6_a5  VARCHAR2
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  VARCHAR2
    , p6_a9  VARCHAR2
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
  );
  procedure activate_offer_over(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_called_from  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  DATE
    , p7_a13  DATE
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
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
    , p7_a43  DATE
    , p7_a44  DATE
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  DATE
    , p7_a52  DATE
    , p7_a53  VARCHAR2
    , p7_a54  DATE
    , p7_a55  DATE
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
    , p7_a59  NUMBER
    , p7_a60  VARCHAR2
    , p7_a61  NUMBER
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  NUMBER
    , p7_a65  VARCHAR2
    , p7_a66  NUMBER
    , p7_a67  NUMBER
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
    , p7_a79  NUMBER
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  NUMBER
    , x_amount_error out nocopy  VARCHAR2
  );
  procedure update_offer_status(p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  DATE
    , p4_a13  DATE
    , p4_a14  VARCHAR2
    , p4_a15  DATE
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  NUMBER
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , p4_a21  NUMBER
    , p4_a22  NUMBER
    , p4_a23  NUMBER
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
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  DATE
    , p4_a44  DATE
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  DATE
    , p4_a52  DATE
    , p4_a53  VARCHAR2
    , p4_a54  DATE
    , p4_a55  DATE
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  NUMBER
    , p4_a59  NUMBER
    , p4_a60  VARCHAR2
    , p4_a61  NUMBER
    , p4_a62  VARCHAR2
    , p4_a63  VARCHAR2
    , p4_a64  NUMBER
    , p4_a65  VARCHAR2
    , p4_a66  NUMBER
    , p4_a67  NUMBER
    , p4_a68  VARCHAR2
    , p4_a69  VARCHAR2
    , p4_a70  VARCHAR2
    , p4_a71  VARCHAR2
    , p4_a72  VARCHAR2
    , p4_a73  VARCHAR2
    , p4_a74  VARCHAR2
    , p4_a75  VARCHAR2
    , p4_a76  VARCHAR2
    , p4_a77  VARCHAR2
    , p4_a78  VARCHAR2
    , p4_a79  NUMBER
    , p4_a80  VARCHAR2
    , p4_a81  VARCHAR2
    , p4_a82  NUMBER
  );
  procedure process_qp_list_lines(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
    , p4_a0 JTF_VARCHAR2_TABLE_100
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_VARCHAR2_TABLE_100
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_DATE_TABLE
    , p4_a7 JTF_DATE_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_VARCHAR2_TABLE_100
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_VARCHAR2_TABLE_100
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_VARCHAR2_TABLE_100
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_NUMBER_TABLE
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_300
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_NUMBER_TABLE
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_VARCHAR2_TABLE_300
    , p4_a30 JTF_VARCHAR2_TABLE_100
    , p4_a31 JTF_VARCHAR2_TABLE_100
    , p4_a32 JTF_VARCHAR2_TABLE_100
    , p4_a33 JTF_VARCHAR2_TABLE_300
    , p4_a34 JTF_VARCHAR2_TABLE_300
    , p4_a35 JTF_VARCHAR2_TABLE_100
    , p4_a36 JTF_VARCHAR2_TABLE_300
    , p4_a37 JTF_VARCHAR2_TABLE_300
    , p4_a38 JTF_NUMBER_TABLE
    , p4_a39 JTF_VARCHAR2_TABLE_2000
    , p4_a40 JTF_VARCHAR2_TABLE_100
    , p4_a41 JTF_VARCHAR2_TABLE_300
    , p4_a42 JTF_VARCHAR2_TABLE_300
    , p4_a43 JTF_VARCHAR2_TABLE_300
    , p4_a44 JTF_VARCHAR2_TABLE_300
    , p4_a45 JTF_VARCHAR2_TABLE_300
    , p4_a46 JTF_VARCHAR2_TABLE_300
    , p4_a47 JTF_VARCHAR2_TABLE_300
    , p4_a48 JTF_VARCHAR2_TABLE_300
    , p4_a49 JTF_VARCHAR2_TABLE_300
    , p4_a50 JTF_VARCHAR2_TABLE_300
    , p4_a51 JTF_VARCHAR2_TABLE_300
    , p4_a52 JTF_VARCHAR2_TABLE_300
    , p4_a53 JTF_VARCHAR2_TABLE_300
    , p4_a54 JTF_VARCHAR2_TABLE_300
    , p4_a55 JTF_VARCHAR2_TABLE_300
    , p4_a56 JTF_NUMBER_TABLE
    , p4_a57 JTF_NUMBER_TABLE
    , p4_a58 JTF_NUMBER_TABLE
    , p4_a59 JTF_NUMBER_TABLE
    , p4_a60 JTF_NUMBER_TABLE
    , p4_a61 JTF_NUMBER_TABLE
    , p4_a62 JTF_NUMBER_TABLE
    , p4_a63 JTF_NUMBER_TABLE
    , p4_a64 JTF_NUMBER_TABLE
    , p4_a65 JTF_NUMBER_TABLE
    , p4_a66 JTF_VARCHAR2_TABLE_100
    , p4_a67 JTF_NUMBER_TABLE
    , p4_a68 JTF_NUMBER_TABLE
    , p4_a69 JTF_VARCHAR2_TABLE_300
    , p4_a70 JTF_VARCHAR2_TABLE_300
    , p_list_header_id  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_DATE_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_DATE_TABLE
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a38 out nocopy JTF_NUMBER_TABLE
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a40 out nocopy JTF_NUMBER_TABLE
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_DATE_TABLE
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_NUMBER_TABLE
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a50 out nocopy JTF_NUMBER_TABLE
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a54 out nocopy JTF_DATE_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a59 out nocopy JTF_NUMBER_TABLE
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_NUMBER_TABLE
    , p6_a63 out nocopy JTF_NUMBER_TABLE
    , p6_a64 out nocopy JTF_NUMBER_TABLE
    , p6_a65 out nocopy JTF_NUMBER_TABLE
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_NUMBER_TABLE
    , p6_a68 out nocopy JTF_NUMBER_TABLE
    , p6_a69 out nocopy JTF_DATE_TABLE
    , p6_a70 out nocopy JTF_NUMBER_TABLE
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_DATE_TABLE
    , p6_a73 out nocopy JTF_NUMBER_TABLE
    , p6_a74 out nocopy JTF_NUMBER_TABLE
    , p6_a75 out nocopy JTF_NUMBER_TABLE
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a78 out nocopy JTF_NUMBER_TABLE
    , p6_a79 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a83 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a84 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_NUMBER_TABLE
    , p6_a87 out nocopy JTF_NUMBER_TABLE
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , x_error_location out nocopy  NUMBER
  );
end ozf_offer_pvt_oa;

 

/
