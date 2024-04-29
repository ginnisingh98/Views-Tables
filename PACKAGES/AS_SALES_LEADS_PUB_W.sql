--------------------------------------------------------
--  DDL for Package AS_SALES_LEADS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_LEADS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: asxwslms.pls 115.14 2003/09/18 22:43:56 ckapoor ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy as_sales_leads_pub.sales_lead_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_NUMBER_TABLE
    , a46 JTF_DATE_TABLE
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_100
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_NUMBER_TABLE
    , a59 JTF_NUMBER_TABLE
    , a60 JTF_VARCHAR2_TABLE_100
    , a61 JTF_VARCHAR2_TABLE_100
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_NUMBER_TABLE
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_NUMBER_TABLE
    , a71 JTF_NUMBER_TABLE
    , a72 JTF_VARCHAR2_TABLE_100
    , a73 JTF_VARCHAR2_TABLE_100
    , a74 JTF_VARCHAR2_TABLE_100
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_NUMBER_TABLE
    , a79 JTF_DATE_TABLE
    , a80 JTF_VARCHAR2_TABLE_100
    , a81 JTF_VARCHAR2_TABLE_100
    , a82 JTF_NUMBER_TABLE
    , a83 JTF_DATE_TABLE
    , a84 JTF_DATE_TABLE
    , a85 JTF_VARCHAR2_TABLE_100
    , a86 JTF_NUMBER_TABLE
    , a87 JTF_NUMBER_TABLE
    , a88 JTF_NUMBER_TABLE
    , a89 JTF_VARCHAR2_TABLE_100
    , a90 JTF_VARCHAR2_TABLE_100
    , a91 JTF_NUMBER_TABLE
    , a92 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t as_sales_leads_pub.sales_lead_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_NUMBER_TABLE
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_100
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_NUMBER_TABLE
    , a59 out nocopy JTF_NUMBER_TABLE
    , a60 out nocopy JTF_VARCHAR2_TABLE_100
    , a61 out nocopy JTF_VARCHAR2_TABLE_100
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_NUMBER_TABLE
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_NUMBER_TABLE
    , a71 out nocopy JTF_NUMBER_TABLE
    , a72 out nocopy JTF_VARCHAR2_TABLE_100
    , a73 out nocopy JTF_VARCHAR2_TABLE_100
    , a74 out nocopy JTF_VARCHAR2_TABLE_100
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_NUMBER_TABLE
    , a79 out nocopy JTF_DATE_TABLE
    , a80 out nocopy JTF_VARCHAR2_TABLE_100
    , a81 out nocopy JTF_VARCHAR2_TABLE_100
    , a82 out nocopy JTF_NUMBER_TABLE
    , a83 out nocopy JTF_DATE_TABLE
    , a84 out nocopy JTF_DATE_TABLE
    , a85 out nocopy JTF_VARCHAR2_TABLE_100
    , a86 out nocopy JTF_NUMBER_TABLE
    , a87 out nocopy JTF_NUMBER_TABLE
    , a88 out nocopy JTF_NUMBER_TABLE
    , a89 out nocopy JTF_VARCHAR2_TABLE_100
    , a90 out nocopy JTF_VARCHAR2_TABLE_100
    , a91 out nocopy JTF_NUMBER_TABLE
    , a92 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy as_sales_leads_pub.sales_lead_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t as_sales_leads_pub.sales_lead_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy as_sales_leads_pub.sales_lead_line_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p10(t as_sales_leads_pub.sales_lead_line_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p13(t out nocopy as_sales_leads_pub.sales_lead_contact_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t as_sales_leads_pub.sales_lead_contact_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p16(t out nocopy as_sales_leads_pub.sales_lead_cnt_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p16(t as_sales_leads_pub.sales_lead_cnt_out_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p19(t out nocopy as_sales_leads_pub.assign_id_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p19(t as_sales_leads_pub.assign_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_sales_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_DATE_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_DATE_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_NUMBER_TABLE
    , p10_a11 JTF_VARCHAR2_TABLE_100
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_NUMBER_TABLE
    , p10_a14 JTF_NUMBER_TABLE
    , p10_a15 JTF_NUMBER_TABLE
    , p10_a16 JTF_VARCHAR2_TABLE_100
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_NUMBER_TABLE
    , p10_a20 JTF_VARCHAR2_TABLE_100
    , p10_a21 JTF_VARCHAR2_TABLE_200
    , p10_a22 JTF_VARCHAR2_TABLE_200
    , p10_a23 JTF_VARCHAR2_TABLE_200
    , p10_a24 JTF_VARCHAR2_TABLE_200
    , p10_a25 JTF_VARCHAR2_TABLE_200
    , p10_a26 JTF_VARCHAR2_TABLE_200
    , p10_a27 JTF_VARCHAR2_TABLE_200
    , p10_a28 JTF_VARCHAR2_TABLE_200
    , p10_a29 JTF_VARCHAR2_TABLE_200
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_200
    , p10_a36 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_DATE_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_DATE_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_NUMBER_TABLE
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_100
    , p11_a14 JTF_NUMBER_TABLE
    , p11_a15 JTF_NUMBER_TABLE
    , p11_a16 JTF_NUMBER_TABLE
    , p11_a17 JTF_VARCHAR2_TABLE_100
    , p11_a18 JTF_VARCHAR2_TABLE_100
    , p11_a19 JTF_VARCHAR2_TABLE_100
    , p11_a20 JTF_VARCHAR2_TABLE_200
    , p11_a21 JTF_VARCHAR2_TABLE_200
    , p11_a22 JTF_VARCHAR2_TABLE_200
    , p11_a23 JTF_VARCHAR2_TABLE_200
    , p11_a24 JTF_VARCHAR2_TABLE_200
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_NUMBER_TABLE
    , x_sales_lead_id out nocopy  NUMBER
    , p13_a0 out nocopy JTF_NUMBER_TABLE
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  DATE := fnd_api.g_miss_date
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  NUMBER := 0-1962.0724
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  NUMBER := 0-1962.0724
    , p9_a58  NUMBER := 0-1962.0724
    , p9_a59  NUMBER := 0-1962.0724
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  VARCHAR2 := fnd_api.g_miss_char
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  NUMBER := 0-1962.0724
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  VARCHAR2 := fnd_api.g_miss_char
    , p9_a73  VARCHAR2 := fnd_api.g_miss_char
    , p9_a74  VARCHAR2 := fnd_api.g_miss_char
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  NUMBER := 0-1962.0724
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  DATE := fnd_api.g_miss_date
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  VARCHAR2 := fnd_api.g_miss_char
    , p9_a82  NUMBER := 0-1962.0724
    , p9_a83  DATE := fnd_api.g_miss_date
    , p9_a84  DATE := fnd_api.g_miss_date
    , p9_a85  VARCHAR2 := fnd_api.g_miss_char
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  NUMBER := 0-1962.0724
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  VARCHAR2 := fnd_api.g_miss_char
    , p9_a90  VARCHAR2 := fnd_api.g_miss_char
    , p9_a91  NUMBER := 0-1962.0724
    , p9_a92  NUMBER := 0-1962.0724
  );
  procedure update_sales_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  DATE := fnd_api.g_miss_date
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  DATE := fnd_api.g_miss_date
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  NUMBER := 0-1962.0724
    , p9_a6  NUMBER := 0-1962.0724
    , p9_a7  NUMBER := 0-1962.0724
    , p9_a8  NUMBER := 0-1962.0724
    , p9_a9  DATE := fnd_api.g_miss_date
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  VARCHAR2 := fnd_api.g_miss_char
    , p9_a17  VARCHAR2 := fnd_api.g_miss_char
    , p9_a18  VARCHAR2 := fnd_api.g_miss_char
    , p9_a19  NUMBER := 0-1962.0724
    , p9_a20  VARCHAR2 := fnd_api.g_miss_char
    , p9_a21  VARCHAR2 := fnd_api.g_miss_char
    , p9_a22  VARCHAR2 := fnd_api.g_miss_char
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  VARCHAR2 := fnd_api.g_miss_char
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  VARCHAR2 := fnd_api.g_miss_char
    , p9_a42  VARCHAR2 := fnd_api.g_miss_char
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  DATE := fnd_api.g_miss_date
    , p9_a47  VARCHAR2 := fnd_api.g_miss_char
    , p9_a48  VARCHAR2 := fnd_api.g_miss_char
    , p9_a49  VARCHAR2 := fnd_api.g_miss_char
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  NUMBER := 0-1962.0724
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
    , p9_a56  VARCHAR2 := fnd_api.g_miss_char
    , p9_a57  NUMBER := 0-1962.0724
    , p9_a58  NUMBER := 0-1962.0724
    , p9_a59  NUMBER := 0-1962.0724
    , p9_a60  VARCHAR2 := fnd_api.g_miss_char
    , p9_a61  VARCHAR2 := fnd_api.g_miss_char
    , p9_a62  VARCHAR2 := fnd_api.g_miss_char
    , p9_a63  VARCHAR2 := fnd_api.g_miss_char
    , p9_a64  VARCHAR2 := fnd_api.g_miss_char
    , p9_a65  VARCHAR2 := fnd_api.g_miss_char
    , p9_a66  VARCHAR2 := fnd_api.g_miss_char
    , p9_a67  VARCHAR2 := fnd_api.g_miss_char
    , p9_a68  NUMBER := 0-1962.0724
    , p9_a69  NUMBER := 0-1962.0724
    , p9_a70  NUMBER := 0-1962.0724
    , p9_a71  NUMBER := 0-1962.0724
    , p9_a72  VARCHAR2 := fnd_api.g_miss_char
    , p9_a73  VARCHAR2 := fnd_api.g_miss_char
    , p9_a74  VARCHAR2 := fnd_api.g_miss_char
    , p9_a75  VARCHAR2 := fnd_api.g_miss_char
    , p9_a76  NUMBER := 0-1962.0724
    , p9_a77  NUMBER := 0-1962.0724
    , p9_a78  NUMBER := 0-1962.0724
    , p9_a79  DATE := fnd_api.g_miss_date
    , p9_a80  VARCHAR2 := fnd_api.g_miss_char
    , p9_a81  VARCHAR2 := fnd_api.g_miss_char
    , p9_a82  NUMBER := 0-1962.0724
    , p9_a83  DATE := fnd_api.g_miss_date
    , p9_a84  DATE := fnd_api.g_miss_date
    , p9_a85  VARCHAR2 := fnd_api.g_miss_char
    , p9_a86  NUMBER := 0-1962.0724
    , p9_a87  NUMBER := 0-1962.0724
    , p9_a88  NUMBER := 0-1962.0724
    , p9_a89  VARCHAR2 := fnd_api.g_miss_char
    , p9_a90  VARCHAR2 := fnd_api.g_miss_char
    , p9_a91  NUMBER := 0-1962.0724
    , p9_a92  NUMBER := 0-1962.0724
  );
  procedure create_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p_sales_lead_id  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_sales_lead_lines(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_DATE_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_VARCHAR2_TABLE_100
    , p9_a12 JTF_NUMBER_TABLE
    , p9_a13 JTF_NUMBER_TABLE
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_VARCHAR2_TABLE_100
    , p9_a17 JTF_NUMBER_TABLE
    , p9_a18 JTF_NUMBER_TABLE
    , p9_a19 JTF_NUMBER_TABLE
    , p9_a20 JTF_VARCHAR2_TABLE_100
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_VARCHAR2_TABLE_200
    , p9_a36 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p_sales_lead_id  NUMBER
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_sales_lead_contacts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_DATE_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p9_a13 JTF_VARCHAR2_TABLE_100
    , p9_a14 JTF_NUMBER_TABLE
    , p9_a15 JTF_NUMBER_TABLE
    , p9_a16 JTF_NUMBER_TABLE
    , p9_a17 JTF_VARCHAR2_TABLE_100
    , p9_a18 JTF_VARCHAR2_TABLE_100
    , p9_a19 JTF_VARCHAR2_TABLE_100
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_VARCHAR2_TABLE_200
    , p9_a27 JTF_VARCHAR2_TABLE_200
    , p9_a28 JTF_VARCHAR2_TABLE_200
    , p9_a29 JTF_VARCHAR2_TABLE_200
    , p9_a30 JTF_VARCHAR2_TABLE_200
    , p9_a31 JTF_VARCHAR2_TABLE_200
    , p9_a32 JTF_VARCHAR2_TABLE_200
    , p9_a33 JTF_VARCHAR2_TABLE_200
    , p9_a34 JTF_VARCHAR2_TABLE_200
    , p9_a35 JTF_NUMBER_TABLE
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end as_sales_leads_pub_w;

 

/
