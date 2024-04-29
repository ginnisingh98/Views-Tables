--------------------------------------------------------
--  DDL for Package OZF_OFFER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ozfwofps.pls 120.3 2005/08/10 17:36 appldev ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ozf_offer_pub.act_product_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ozf_offer_pub.act_product_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ozf_offer_pub.discount_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p4(t ozf_offer_pub.discount_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ozf_offer_pub.prod_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t ozf_offer_pub.prod_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p8(t out nocopy ozf_offer_pub.excl_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p8(t ozf_offer_pub.excl_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p10(t out nocopy ozf_offer_pub.offer_tier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p10(t ozf_offer_pub.offer_tier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p12(t out nocopy ozf_offer_pub.na_qualifier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
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
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p12(t ozf_offer_pub.na_qualifier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_NUMBER_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p14(t out nocopy ozf_offer_pub.budget_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p14(t ozf_offer_pub.budget_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p17(t out nocopy ozf_offer_pub.modifier_line_tbl_type, a0 JTF_VARCHAR2_TABLE_100
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
  procedure rosetta_table_copy_out_p17(t ozf_offer_pub.modifier_line_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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

  procedure rosetta_table_copy_in_p19(t out nocopy ozf_offer_pub.qualifiers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
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
  procedure rosetta_table_copy_out_p19(t ozf_offer_pub.qualifiers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
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

  procedure rosetta_table_copy_in_p21(t out nocopy ozf_offer_pub.vo_disc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p21(t ozf_offer_pub.vo_disc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p23(t out nocopy ozf_offer_pub.vo_prod_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p23(t ozf_offer_pub.vo_prod_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p25(t out nocopy ozf_offer_pub.vo_mo_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p25(t ozf_offer_pub.vo_mo_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure process_modifiers(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_offer_type  VARCHAR2
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
    , p9_a0 JTF_VARCHAR2_TABLE_100
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_VARCHAR2_TABLE_300
    , p9_a3 JTF_VARCHAR2_TABLE_300
    , p9_a4 JTF_VARCHAR2_TABLE_100
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_NUMBER_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_VARCHAR2_TABLE_300
    , p9_a15 JTF_VARCHAR2_TABLE_300
    , p9_a16 JTF_VARCHAR2_TABLE_300
    , p9_a17 JTF_VARCHAR2_TABLE_300
    , p9_a18 JTF_VARCHAR2_TABLE_300
    , p9_a19 JTF_VARCHAR2_TABLE_300
    , p9_a20 JTF_VARCHAR2_TABLE_300
    , p9_a21 JTF_VARCHAR2_TABLE_300
    , p9_a22 JTF_VARCHAR2_TABLE_300
    , p9_a23 JTF_VARCHAR2_TABLE_300
    , p9_a24 JTF_VARCHAR2_TABLE_300
    , p9_a25 JTF_VARCHAR2_TABLE_300
    , p9_a26 JTF_VARCHAR2_TABLE_300
    , p9_a27 JTF_VARCHAR2_TABLE_300
    , p9_a28 JTF_VARCHAR2_TABLE_300
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_100
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_VARCHAR2_TABLE_100
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_VARCHAR2_TABLE_100
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_100
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_100
    , p11_a18 JTF_VARCHAR2_TABLE_100
    , p11_a19 JTF_NUMBER_TABLE
    , p11_a20 JTF_NUMBER_TABLE
    , p11_a21 JTF_NUMBER_TABLE
    , p11_a22 JTF_VARCHAR2_TABLE_100
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_VARCHAR2_TABLE_100
    , p12_a5 JTF_VARCHAR2_TABLE_100
    , p12_a6 JTF_VARCHAR2_TABLE_100
    , p12_a7 JTF_NUMBER_TABLE
    , p12_a8 JTF_VARCHAR2_TABLE_100
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_VARCHAR2_TABLE_100
    , p12_a11 JTF_VARCHAR2_TABLE_100
    , p12_a12 JTF_NUMBER_TABLE
    , p12_a13 JTF_VARCHAR2_TABLE_100
    , p12_a14 JTF_NUMBER_TABLE
    , p12_a15 JTF_NUMBER_TABLE
    , p12_a16 JTF_NUMBER_TABLE
    , p12_a17 JTF_NUMBER_TABLE
    , p12_a18 JTF_VARCHAR2_TABLE_100
    , p12_a19 JTF_DATE_TABLE
    , p12_a20 JTF_DATE_TABLE
    , p12_a21 JTF_VARCHAR2_TABLE_100
    , p12_a22 JTF_DATE_TABLE
    , p12_a23 JTF_NUMBER_TABLE
    , p12_a24 JTF_DATE_TABLE
    , p12_a25 JTF_NUMBER_TABLE
    , p12_a26 JTF_NUMBER_TABLE
    , p12_a27 JTF_NUMBER_TABLE
    , p12_a28 JTF_NUMBER_TABLE
    , p12_a29 JTF_NUMBER_TABLE
    , p12_a30 JTF_NUMBER_TABLE
    , p12_a31 JTF_VARCHAR2_TABLE_100
    , p12_a32 JTF_NUMBER_TABLE
    , p12_a33 JTF_VARCHAR2_TABLE_100
    , p12_a34 JTF_VARCHAR2_TABLE_100
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_VARCHAR2_TABLE_100
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_DATE_TABLE
    , p13_a6 JTF_DATE_TABLE
    , p13_a7 JTF_VARCHAR2_TABLE_100
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_NUMBER_TABLE
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_VARCHAR2_TABLE_100
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p14_a9 JTF_VARCHAR2_TABLE_100
    , p14_a10 JTF_DATE_TABLE
    , p14_a11 JTF_DATE_TABLE
    , p14_a12 JTF_VARCHAR2_TABLE_100
    , p14_a13 JTF_NUMBER_TABLE
    , p14_a14 JTF_VARCHAR2_TABLE_100
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_VARCHAR2_TABLE_100
    , p15_a3 JTF_NUMBER_TABLE
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , p15_a6 JTF_DATE_TABLE
    , p15_a7 JTF_DATE_TABLE
    , p15_a8 JTF_NUMBER_TABLE
    , p15_a9 JTF_NUMBER_TABLE
    , p15_a10 JTF_DATE_TABLE
    , p15_a11 JTF_NUMBER_TABLE
    , p15_a12 JTF_DATE_TABLE
    , p15_a13 JTF_NUMBER_TABLE
    , p15_a14 JTF_NUMBER_TABLE
    , p15_a15 JTF_NUMBER_TABLE
    , p15_a16 JTF_VARCHAR2_TABLE_100
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_DATE_TABLE
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_DATE_TABLE
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_NUMBER_TABLE
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_VARCHAR2_TABLE_100
    , p16_a9 JTF_VARCHAR2_TABLE_300
    , p16_a10 JTF_DATE_TABLE
    , p16_a11 JTF_DATE_TABLE
    , p16_a12 JTF_NUMBER_TABLE
    , p16_a13 JTF_NUMBER_TABLE
    , p16_a14 JTF_VARCHAR2_TABLE_100
    , p16_a15 JTF_VARCHAR2_TABLE_300
    , p16_a16 JTF_VARCHAR2_TABLE_300
    , p16_a17 JTF_VARCHAR2_TABLE_300
    , p16_a18 JTF_VARCHAR2_TABLE_300
    , p16_a19 JTF_VARCHAR2_TABLE_300
    , p16_a20 JTF_VARCHAR2_TABLE_300
    , p16_a21 JTF_VARCHAR2_TABLE_300
    , p16_a22 JTF_VARCHAR2_TABLE_300
    , p16_a23 JTF_VARCHAR2_TABLE_300
    , p16_a24 JTF_VARCHAR2_TABLE_300
    , p16_a25 JTF_VARCHAR2_TABLE_300
    , p16_a26 JTF_VARCHAR2_TABLE_300
    , p16_a27 JTF_VARCHAR2_TABLE_300
    , p16_a28 JTF_VARCHAR2_TABLE_300
    , p16_a29 JTF_VARCHAR2_TABLE_300
    , p16_a30 JTF_VARCHAR2_TABLE_100
    , p16_a31 JTF_NUMBER_TABLE
    , p16_a32 JTF_VARCHAR2_TABLE_100
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  DATE := fnd_api.g_miss_date
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  DATE := fnd_api.g_miss_date
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  DATE := fnd_api.g_miss_date
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  DATE := fnd_api.g_miss_date
    , p7_a52  DATE := fnd_api.g_miss_date
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  DATE := fnd_api.g_miss_date
    , p7_a55  DATE := fnd_api.g_miss_date
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  NUMBER := 0-1962.0724
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  NUMBER := 0-1962.0724
  );
  procedure process_vo(p_init_msg_list  VARCHAR2
    , p_api_version  NUMBER
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_100
    , p7_a9 JTF_VARCHAR2_TABLE_100
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_VARCHAR2_TABLE_100
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_VARCHAR2_TABLE_300
    , p7_a18 JTF_VARCHAR2_TABLE_2000
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_100
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_VARCHAR2_TABLE_100
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p8_a10 JTF_VARCHAR2_TABLE_100
    , p8_a11 JTF_VARCHAR2_TABLE_100
    , p8_a12 JTF_NUMBER_TABLE
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_NUMBER_TABLE
    , p8_a17 JTF_VARCHAR2_TABLE_300
    , p8_a18 JTF_VARCHAR2_TABLE_2000
    , p8_a19 JTF_VARCHAR2_TABLE_100
    , p8_a20 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_VARCHAR2_TABLE_300
    , p9_a8 JTF_VARCHAR2_TABLE_100
    , p9_a9 JTF_VARCHAR2_TABLE_100
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_NUMBER_TABLE
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_VARCHAR2_TABLE_300
    , p10_a3 JTF_VARCHAR2_TABLE_300
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_NUMBER_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p10_a13 JTF_VARCHAR2_TABLE_100
    , p10_a14 JTF_VARCHAR2_TABLE_300
    , p10_a15 JTF_VARCHAR2_TABLE_300
    , p10_a16 JTF_VARCHAR2_TABLE_300
    , p10_a17 JTF_VARCHAR2_TABLE_300
    , p10_a18 JTF_VARCHAR2_TABLE_300
    , p10_a19 JTF_VARCHAR2_TABLE_300
    , p10_a20 JTF_VARCHAR2_TABLE_300
    , p10_a21 JTF_VARCHAR2_TABLE_300
    , p10_a22 JTF_VARCHAR2_TABLE_300
    , p10_a23 JTF_VARCHAR2_TABLE_300
    , p10_a24 JTF_VARCHAR2_TABLE_300
    , p10_a25 JTF_VARCHAR2_TABLE_300
    , p10_a26 JTF_VARCHAR2_TABLE_300
    , p10_a27 JTF_VARCHAR2_TABLE_300
    , p10_a28 JTF_VARCHAR2_TABLE_300
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_VARCHAR2_TABLE_100
    , p11_a7 JTF_VARCHAR2_TABLE_100
    , p11_a8 JTF_VARCHAR2_TABLE_100
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_NUMBER_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_VARCHAR2_TABLE_100
    , x_qp_list_header_id out nocopy  NUMBER
    , x_error_location out nocopy  NUMBER
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  DATE := fnd_api.g_miss_date
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  DATE := fnd_api.g_miss_date
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  DATE := fnd_api.g_miss_date
    , p6_a44  DATE := fnd_api.g_miss_date
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  DATE := fnd_api.g_miss_date
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  DATE := fnd_api.g_miss_date
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  VARCHAR2 := fnd_api.g_miss_char
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  NUMBER := 0-1962.0724
    , p6_a59  NUMBER := 0-1962.0724
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  NUMBER := 0-1962.0724
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  NUMBER := 0-1962.0724
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  VARCHAR2 := fnd_api.g_miss_char
    , p6_a78  VARCHAR2 := fnd_api.g_miss_char
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  NUMBER := 0-1962.0724
  );
end ozf_offer_pub_w;

 

/
