--------------------------------------------------------
--  DDL for Package OKL_CREDIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCRDS.pls 115.7 2003/08/29 22:45:55 cklee noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okl_credit_pub.clev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_credit_pub.clev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    );

  procedure create_credit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_description  VARCHAR2
    , p_customer_id1  VARCHAR2
    , p_customer_id2  VARCHAR2
    , p_customer_code  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_effective_from  date
    , p_effective_to  date
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_rate  NUMBER
    , p_currency_conv_date  date
    , p_revolving_credit_yn  VARCHAR2
    , p_sts_code  VARCHAR2
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_acct_number  VARCHAR2
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
    , p_source_chr_id  NUMBER
    , x_chr_id out nocopy  NUMBER
  );
  procedure create_credit_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  DATE
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
    , p9_a32 out nocopy  VARCHAR2
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  DATE
    , p9_a39 out nocopy  DATE
    , p9_a40 out nocopy  DATE
    , p9_a41 out nocopy  DATE
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  VARCHAR2
    , p9_a44 out nocopy  DATE
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  VARCHAR2
    , p9_a48 out nocopy  VARCHAR2
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  DATE
    , p9_a63 out nocopy  DATE
    , p9_a64 out nocopy  DATE
    , p9_a65 out nocopy  NUMBER
    , p9_a66 out nocopy  NUMBER
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  VARCHAR2
    , p9_a78 out nocopy  VARCHAR2
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  VARCHAR2
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  VARCHAR2
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  DATE
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  VARCHAR2
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  VARCHAR2
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  VARCHAR2
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  NUMBER
    , p9_a97 out nocopy  NUMBER
    , p9_a98 out nocopy  NUMBER
    , p9_a99 out nocopy  NUMBER
    , p9_a100 out nocopy  VARCHAR2
    , p9_a101 out nocopy  NUMBER
    , p9_a102 out nocopy  DATE
    , p9_a103 out nocopy  NUMBER
    , p9_a104 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  DATE
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  DATE
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  DATE
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  DATE
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  NUMBER
    , p10_a37 out nocopy  DATE
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  DATE
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  NUMBER
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  NUMBER
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  NUMBER
    , p10_a48 out nocopy  NUMBER
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  NUMBER
    , p10_a53 out nocopy  DATE
    , p10_a54 out nocopy  DATE
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  NUMBER
    , p10_a59 out nocopy  DATE
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  DATE := fnd_api.g_miss_date
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  DATE := fnd_api.g_miss_date
    , p7_a65  NUMBER := 0-1962.0724
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
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  DATE := fnd_api.g_miss_date
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  DATE := fnd_api.g_miss_date
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  DATE := fnd_api.g_miss_date
    , p7_a96  NUMBER := 0-1962.0724
    , p7_a97  NUMBER := 0-1962.0724
    , p7_a98  NUMBER := 0-1962.0724
    , p7_a99  NUMBER := 0-1962.0724
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  NUMBER := 0-1962.0724
    , p7_a102  DATE := fnd_api.g_miss_date
    , p7_a103  NUMBER := 0-1962.0724
    , p7_a104  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  DATE := fnd_api.g_miss_date
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  DATE := fnd_api.g_miss_date
    , p8_a17  DATE := fnd_api.g_miss_date
    , p8_a18  DATE := fnd_api.g_miss_date
    , p8_a19  DATE := fnd_api.g_miss_date
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  DATE := fnd_api.g_miss_date
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  DATE := fnd_api.g_miss_date
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  NUMBER := 0-1962.0724
    , p8_a42  NUMBER := 0-1962.0724
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  NUMBER := 0-1962.0724
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  NUMBER := 0-1962.0724
    , p8_a48  NUMBER := 0-1962.0724
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  VARCHAR2 := fnd_api.g_miss_char
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  NUMBER := 0-1962.0724
    , p8_a53  DATE := fnd_api.g_miss_date
    , p8_a54  DATE := fnd_api.g_miss_date
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  VARCHAR2 := fnd_api.g_miss_char
    , p8_a58  NUMBER := 0-1962.0724
    , p8_a59  DATE := fnd_api.g_miss_date
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_credit_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p_chklst_tpl_rgp_id  NUMBER
    , p_chklst_tpl_rule_id  NUMBER
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  VARCHAR2
    , p12_a8 out nocopy  NUMBER
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  VARCHAR2
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  DATE
    , p12_a26 out nocopy  DATE
    , p12_a27 out nocopy  NUMBER
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  DATE
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  VARCHAR2
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  NUMBER
    , p12_a38 out nocopy  DATE
    , p12_a39 out nocopy  DATE
    , p12_a40 out nocopy  DATE
    , p12_a41 out nocopy  DATE
    , p12_a42 out nocopy  DATE
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  DATE
    , p12_a45 out nocopy  DATE
    , p12_a46 out nocopy  NUMBER
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  NUMBER
    , p12_a50 out nocopy  NUMBER
    , p12_a51 out nocopy  NUMBER
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  NUMBER
    , p12_a56 out nocopy  VARCHAR2
    , p12_a57 out nocopy  NUMBER
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  NUMBER
    , p12_a60 out nocopy  NUMBER
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  DATE
    , p12_a63 out nocopy  DATE
    , p12_a64 out nocopy  DATE
    , p12_a65 out nocopy  NUMBER
    , p12_a66 out nocopy  NUMBER
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  VARCHAR2
    , p12_a69 out nocopy  VARCHAR2
    , p12_a70 out nocopy  VARCHAR2
    , p12_a71 out nocopy  VARCHAR2
    , p12_a72 out nocopy  VARCHAR2
    , p12_a73 out nocopy  VARCHAR2
    , p12_a74 out nocopy  VARCHAR2
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  VARCHAR2
    , p12_a78 out nocopy  VARCHAR2
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  VARCHAR2
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  VARCHAR2
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  DATE
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  DATE
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  VARCHAR2
    , p12_a90 out nocopy  VARCHAR2
    , p12_a91 out nocopy  VARCHAR2
    , p12_a92 out nocopy  VARCHAR2
    , p12_a93 out nocopy  VARCHAR2
    , p12_a94 out nocopy  NUMBER
    , p12_a95 out nocopy  DATE
    , p12_a96 out nocopy  NUMBER
    , p12_a97 out nocopy  NUMBER
    , p12_a98 out nocopy  NUMBER
    , p12_a99 out nocopy  NUMBER
    , p12_a100 out nocopy  VARCHAR2
    , p12_a101 out nocopy  NUMBER
    , p12_a102 out nocopy  DATE
    , p12_a103 out nocopy  NUMBER
    , p12_a104 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  DATE
    , p13_a7 out nocopy  VARCHAR2
    , p13_a8 out nocopy  VARCHAR2
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  VARCHAR2
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  VARCHAR2
    , p13_a13 out nocopy  DATE
    , p13_a14 out nocopy  VARCHAR2
    , p13_a15 out nocopy  VARCHAR2
    , p13_a16 out nocopy  DATE
    , p13_a17 out nocopy  DATE
    , p13_a18 out nocopy  DATE
    , p13_a19 out nocopy  DATE
    , p13_a20 out nocopy  VARCHAR2
    , p13_a21 out nocopy  VARCHAR2
    , p13_a22 out nocopy  VARCHAR2
    , p13_a23 out nocopy  VARCHAR2
    , p13_a24 out nocopy  VARCHAR2
    , p13_a25 out nocopy  VARCHAR2
    , p13_a26 out nocopy  VARCHAR2
    , p13_a27 out nocopy  VARCHAR2
    , p13_a28 out nocopy  VARCHAR2
    , p13_a29 out nocopy  VARCHAR2
    , p13_a30 out nocopy  VARCHAR2
    , p13_a31 out nocopy  VARCHAR2
    , p13_a32 out nocopy  VARCHAR2
    , p13_a33 out nocopy  VARCHAR2
    , p13_a34 out nocopy  VARCHAR2
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  NUMBER
    , p13_a37 out nocopy  DATE
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  DATE
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  NUMBER
    , p13_a42 out nocopy  NUMBER
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  NUMBER
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  NUMBER
    , p13_a48 out nocopy  NUMBER
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  VARCHAR2
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  NUMBER
    , p13_a53 out nocopy  DATE
    , p13_a54 out nocopy  DATE
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  VARCHAR2
    , p13_a58 out nocopy  NUMBER
    , p13_a59 out nocopy  DATE
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  DATE := fnd_api.g_miss_date
    , p10_a26  DATE := fnd_api.g_miss_date
    , p10_a27  NUMBER := 0-1962.0724
    , p10_a28  DATE := fnd_api.g_miss_date
    , p10_a29  DATE := fnd_api.g_miss_date
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  NUMBER := 0-1962.0724
    , p10_a37  NUMBER := 0-1962.0724
    , p10_a38  DATE := fnd_api.g_miss_date
    , p10_a39  DATE := fnd_api.g_miss_date
    , p10_a40  DATE := fnd_api.g_miss_date
    , p10_a41  DATE := fnd_api.g_miss_date
    , p10_a42  DATE := fnd_api.g_miss_date
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  DATE := fnd_api.g_miss_date
    , p10_a45  DATE := fnd_api.g_miss_date
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  VARCHAR2 := fnd_api.g_miss_char
    , p10_a48  VARCHAR2 := fnd_api.g_miss_char
    , p10_a49  NUMBER := 0-1962.0724
    , p10_a50  NUMBER := 0-1962.0724
    , p10_a51  NUMBER := 0-1962.0724
    , p10_a52  VARCHAR2 := fnd_api.g_miss_char
    , p10_a53  VARCHAR2 := fnd_api.g_miss_char
    , p10_a54  NUMBER := 0-1962.0724
    , p10_a55  NUMBER := 0-1962.0724
    , p10_a56  VARCHAR2 := fnd_api.g_miss_char
    , p10_a57  NUMBER := 0-1962.0724
    , p10_a58  VARCHAR2 := fnd_api.g_miss_char
    , p10_a59  NUMBER := 0-1962.0724
    , p10_a60  NUMBER := 0-1962.0724
    , p10_a61  NUMBER := 0-1962.0724
    , p10_a62  DATE := fnd_api.g_miss_date
    , p10_a63  DATE := fnd_api.g_miss_date
    , p10_a64  DATE := fnd_api.g_miss_date
    , p10_a65  NUMBER := 0-1962.0724
    , p10_a66  NUMBER := 0-1962.0724
    , p10_a67  NUMBER := 0-1962.0724
    , p10_a68  VARCHAR2 := fnd_api.g_miss_char
    , p10_a69  VARCHAR2 := fnd_api.g_miss_char
    , p10_a70  VARCHAR2 := fnd_api.g_miss_char
    , p10_a71  VARCHAR2 := fnd_api.g_miss_char
    , p10_a72  VARCHAR2 := fnd_api.g_miss_char
    , p10_a73  VARCHAR2 := fnd_api.g_miss_char
    , p10_a74  VARCHAR2 := fnd_api.g_miss_char
    , p10_a75  VARCHAR2 := fnd_api.g_miss_char
    , p10_a76  VARCHAR2 := fnd_api.g_miss_char
    , p10_a77  VARCHAR2 := fnd_api.g_miss_char
    , p10_a78  VARCHAR2 := fnd_api.g_miss_char
    , p10_a79  VARCHAR2 := fnd_api.g_miss_char
    , p10_a80  VARCHAR2 := fnd_api.g_miss_char
    , p10_a81  VARCHAR2 := fnd_api.g_miss_char
    , p10_a82  VARCHAR2 := fnd_api.g_miss_char
    , p10_a83  VARCHAR2 := fnd_api.g_miss_char
    , p10_a84  NUMBER := 0-1962.0724
    , p10_a85  DATE := fnd_api.g_miss_date
    , p10_a86  NUMBER := 0-1962.0724
    , p10_a87  DATE := fnd_api.g_miss_date
    , p10_a88  NUMBER := 0-1962.0724
    , p10_a89  VARCHAR2 := fnd_api.g_miss_char
    , p10_a90  VARCHAR2 := fnd_api.g_miss_char
    , p10_a91  VARCHAR2 := fnd_api.g_miss_char
    , p10_a92  VARCHAR2 := fnd_api.g_miss_char
    , p10_a93  VARCHAR2 := fnd_api.g_miss_char
    , p10_a94  NUMBER := 0-1962.0724
    , p10_a95  DATE := fnd_api.g_miss_date
    , p10_a96  NUMBER := 0-1962.0724
    , p10_a97  NUMBER := 0-1962.0724
    , p10_a98  NUMBER := 0-1962.0724
    , p10_a99  NUMBER := 0-1962.0724
    , p10_a100  VARCHAR2 := fnd_api.g_miss_char
    , p10_a101  NUMBER := 0-1962.0724
    , p10_a102  DATE := fnd_api.g_miss_date
    , p10_a103  NUMBER := 0-1962.0724
    , p10_a104  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  VARCHAR2 := fnd_api.g_miss_char
    , p11_a6  DATE := fnd_api.g_miss_date
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  DATE := fnd_api.g_miss_date
    , p11_a10  VARCHAR2 := fnd_api.g_miss_char
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  VARCHAR2 := fnd_api.g_miss_char
    , p11_a13  DATE := fnd_api.g_miss_date
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  VARCHAR2 := fnd_api.g_miss_char
    , p11_a16  DATE := fnd_api.g_miss_date
    , p11_a17  DATE := fnd_api.g_miss_date
    , p11_a18  DATE := fnd_api.g_miss_date
    , p11_a19  DATE := fnd_api.g_miss_date
    , p11_a20  VARCHAR2 := fnd_api.g_miss_char
    , p11_a21  VARCHAR2 := fnd_api.g_miss_char
    , p11_a22  VARCHAR2 := fnd_api.g_miss_char
    , p11_a23  VARCHAR2 := fnd_api.g_miss_char
    , p11_a24  VARCHAR2 := fnd_api.g_miss_char
    , p11_a25  VARCHAR2 := fnd_api.g_miss_char
    , p11_a26  VARCHAR2 := fnd_api.g_miss_char
    , p11_a27  VARCHAR2 := fnd_api.g_miss_char
    , p11_a28  VARCHAR2 := fnd_api.g_miss_char
    , p11_a29  VARCHAR2 := fnd_api.g_miss_char
    , p11_a30  VARCHAR2 := fnd_api.g_miss_char
    , p11_a31  VARCHAR2 := fnd_api.g_miss_char
    , p11_a32  VARCHAR2 := fnd_api.g_miss_char
    , p11_a33  VARCHAR2 := fnd_api.g_miss_char
    , p11_a34  VARCHAR2 := fnd_api.g_miss_char
    , p11_a35  VARCHAR2 := fnd_api.g_miss_char
    , p11_a36  NUMBER := 0-1962.0724
    , p11_a37  DATE := fnd_api.g_miss_date
    , p11_a38  NUMBER := 0-1962.0724
    , p11_a39  DATE := fnd_api.g_miss_date
    , p11_a40  NUMBER := 0-1962.0724
    , p11_a41  NUMBER := 0-1962.0724
    , p11_a42  NUMBER := 0-1962.0724
    , p11_a43  NUMBER := 0-1962.0724
    , p11_a44  NUMBER := 0-1962.0724
    , p11_a45  NUMBER := 0-1962.0724
    , p11_a46  NUMBER := 0-1962.0724
    , p11_a47  NUMBER := 0-1962.0724
    , p11_a48  NUMBER := 0-1962.0724
    , p11_a49  DATE := fnd_api.g_miss_date
    , p11_a50  VARCHAR2 := fnd_api.g_miss_char
    , p11_a51  NUMBER := 0-1962.0724
    , p11_a52  NUMBER := 0-1962.0724
    , p11_a53  DATE := fnd_api.g_miss_date
    , p11_a54  DATE := fnd_api.g_miss_date
    , p11_a55  VARCHAR2 := fnd_api.g_miss_char
    , p11_a56  VARCHAR2 := fnd_api.g_miss_char
    , p11_a57  VARCHAR2 := fnd_api.g_miss_char
    , p11_a58  NUMBER := 0-1962.0724
    , p11_a59  DATE := fnd_api.g_miss_date
    , p11_a60  VARCHAR2 := fnd_api.g_miss_char
    , p11_a61  VARCHAR2 := fnd_api.g_miss_char
    , p11_a62  VARCHAR2 := fnd_api.g_miss_char
    , p11_a63  VARCHAR2 := fnd_api.g_miss_char
    , p11_a64  VARCHAR2 := fnd_api.g_miss_char
    , p11_a65  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure validate_credit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_description  VARCHAR2
    , p_customer_id1  VARCHAR2
    , p_customer_id2  VARCHAR2
    , p_customer_code  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_effective_from  date
    , p_effective_to  date
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_rate  NUMBER
    , p_currency_conv_date  date
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_acct_number  VARCHAR2
    , p_sts_code  VARCHAR2
  );
  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_cle_start_date  date
    , p_description  VARCHAR2
    , p_credit_nature  VARCHAR2
    , p_amount  NUMBER
  );
  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  DATE := fnd_api.g_miss_date
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  DATE := fnd_api.g_miss_date
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  DATE := fnd_api.g_miss_date
    , p6_a73  NUMBER := 0-1962.0724
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  NUMBER := 0-1962.0724
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  NUMBER := 0-1962.0724
    , p6_a86  NUMBER := 0-1962.0724
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  DATE := fnd_api.g_miss_date
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  DATE := fnd_api.g_miss_date
    , p7_a48  DATE := fnd_api.g_miss_date
    , p7_a49  DATE := fnd_api.g_miss_date
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  NUMBER := 0-1962.0724
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  DATE := fnd_api.g_miss_date
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
    , p7_a80  NUMBER := 0-1962.0724
    , p7_a81  DATE := fnd_api.g_miss_date
    , p7_a82  NUMBER := 0-1962.0724
    , p7_a83  DATE := fnd_api.g_miss_date
    , p7_a84  DATE := fnd_api.g_miss_date
    , p7_a85  DATE := fnd_api.g_miss_date
    , p7_a86  DATE := fnd_api.g_miss_date
    , p7_a87  NUMBER := 0-1962.0724
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  NUMBER := 0-1962.0724
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  NUMBER := 0-1962.0724
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  DATE := fnd_api.g_miss_date
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  NUMBER := 0-1962.0724
  );
  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_VARCHAR2_TABLE_2000
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_VARCHAR2_TABLE_2000
    , p6_a26 JTF_VARCHAR2_TABLE_100
    , p6_a27 JTF_VARCHAR2_TABLE_200
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_VARCHAR2_TABLE_200
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_DATE_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_NUMBER_TABLE
    , p6_a70 JTF_DATE_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_DATE_TABLE
    , p6_a73 JTF_NUMBER_TABLE
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_VARCHAR2_TABLE_100
    , p6_a80 JTF_VARCHAR2_TABLE_100
    , p6_a81 JTF_NUMBER_TABLE
    , p6_a82 JTF_VARCHAR2_TABLE_100
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_NUMBER_TABLE
    , p6_a85 JTF_NUMBER_TABLE
    , p6_a86 JTF_NUMBER_TABLE
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_DATE_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_DATE_TABLE
    , p7_a26 JTF_DATE_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_DATE_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_300
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_VARCHAR2_TABLE_100
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_DATE_TABLE
    , p7_a49 JTF_DATE_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_NUMBER_TABLE
    , p7_a52 JTF_VARCHAR2_TABLE_100
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_NUMBER_TABLE
    , p7_a58 JTF_DATE_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_500
    , p7_a62 JTF_VARCHAR2_TABLE_500
    , p7_a63 JTF_VARCHAR2_TABLE_500
    , p7_a64 JTF_VARCHAR2_TABLE_500
    , p7_a65 JTF_VARCHAR2_TABLE_500
    , p7_a66 JTF_VARCHAR2_TABLE_500
    , p7_a67 JTF_VARCHAR2_TABLE_500
    , p7_a68 JTF_VARCHAR2_TABLE_500
    , p7_a69 JTF_VARCHAR2_TABLE_500
    , p7_a70 JTF_VARCHAR2_TABLE_500
    , p7_a71 JTF_VARCHAR2_TABLE_500
    , p7_a72 JTF_VARCHAR2_TABLE_500
    , p7_a73 JTF_VARCHAR2_TABLE_500
    , p7_a74 JTF_VARCHAR2_TABLE_500
    , p7_a75 JTF_VARCHAR2_TABLE_500
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_NUMBER_TABLE
    , p7_a81 JTF_DATE_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_DATE_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_VARCHAR2_TABLE_100
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_100
    , p7_a93 JTF_NUMBER_TABLE
    , p7_a94 JTF_NUMBER_TABLE
    , p7_a95 JTF_DATE_TABLE
    , p7_a96 JTF_VARCHAR2_TABLE_100
    , p7_a97 JTF_VARCHAR2_TABLE_100
    , p7_a98 JTF_NUMBER_TABLE
  );
  procedure create_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE






    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_DATE_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_DATE_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_DATE_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_DATE_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_DATE_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_DATE_TABLE
    , p8_a48 out nocopy JTF_DATE_TABLE
    , p8_a49 out nocopy JTF_DATE_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a76 out nocopy JTF_NUMBER_TABLE
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_DATE_TABLE
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_DATE_TABLE
    , p8_a82 out nocopy JTF_NUMBER_TABLE
    , p8_a83 out nocopy JTF_DATE_TABLE
    , p8_a84 out nocopy JTF_DATE_TABLE
    , p8_a85 out nocopy JTF_DATE_TABLE
    , p8_a86 out nocopy JTF_DATE_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a93 out nocopy JTF_NUMBER_TABLE
    , p8_a94 out nocopy JTF_NUMBER_TABLE
    , p8_a95 out nocopy JTF_DATE_TABLE
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a98 out nocopy JTF_NUMBER_TABLE
  );
  procedure update_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_DATE_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_DATE_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_DATE_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_DATE_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_DATE_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_DATE_TABLE
    , p8_a48 out nocopy JTF_DATE_TABLE
    , p8_a49 out nocopy JTF_DATE_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a76 out nocopy JTF_NUMBER_TABLE
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_DATE_TABLE
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_DATE_TABLE
    , p8_a82 out nocopy JTF_NUMBER_TABLE
    , p8_a83 out nocopy JTF_DATE_TABLE
    , p8_a84 out nocopy JTF_DATE_TABLE
    , p8_a85 out nocopy JTF_DATE_TABLE
    , p8_a86 out nocopy JTF_DATE_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a93 out nocopy JTF_NUMBER_TABLE
    , p8_a94 out nocopy JTF_NUMBER_TABLE
    , p8_a95 out nocopy JTF_DATE_TABLE
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a98 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
  );
end okl_credit_pub_w;

 

/
