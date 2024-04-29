--------------------------------------------------------
--  DDL for Package OKL_GENERATE_ACCRUALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_GENERATE_ACCRUALS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEACRS.pls 120.13.12010000.7 2009/12/16 09:31:11 rpillay ship $ */
  procedure rosetta_table_copy_in_p4(t out nocopy okl_generate_accruals_pvt.stream_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t okl_generate_accruals_pvt.stream_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy okl_generate_accruals_pvt.acceleration_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okl_generate_accruals_pvt.acceleration_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    );

  function submit_accruals(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_accrual_date  date
    , p_batch_name  VARCHAR2
  ) return number;
  procedure get_accrual_streams(x_return_status out nocopy  VARCHAR2
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , p1_a3 out nocopy JTF_NUMBER_TABLE
    , p1_a4 out nocopy JTF_NUMBER_TABLE
    , p1_a5 out nocopy JTF_NUMBER_TABLE
    , p_khr_id  NUMBER
    , p_product_id  NUMBER
    , p_ctr_start_date  date
    , p_period_end_date  date
    , p_accrual_rule_yn  VARCHAR2
  );
  function check_date_accrued_till(p_khr_id  NUMBER
    , p_date  date
  ) return varchar2;
  procedure catchup_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_DATE_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_NUMBER_TABLE
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 out nocopy JTF_NUMBER_TABLE
    , p7_a52 out nocopy JTF_DATE_TABLE
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  DATE := fnd_api.g_miss_date
  );
  procedure reverse_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_DATE_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_NUMBER_TABLE
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 out nocopy JTF_NUMBER_TABLE
    , p7_a52 out nocopy JTF_DATE_TABLE
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  DATE := fnd_api.g_miss_date
  );
  procedure reverse_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_reversal_date  date
    , p_accounting_date  date
    , p_reverse_from  date
    , p_reverse_to  date
    , p_tcn_type  VARCHAR2
  );
  procedure reverse_all_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_khr_id  NUMBER
    , p_reverse_date  date
    , p_description  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure reverse_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a37 out nocopy JTF_NUMBER_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_NUMBER_TABLE
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a42 out nocopy JTF_NUMBER_TABLE
    , p6_a43 out nocopy JTF_NUMBER_TABLE
    , p6_a44 out nocopy JTF_NUMBER_TABLE
    , p6_a45 out nocopy JTF_NUMBER_TABLE
    , p6_a46 out nocopy JTF_NUMBER_TABLE
    , p6_a47 out nocopy JTF_NUMBER_TABLE
    , p6_a48 out nocopy JTF_DATE_TABLE
    , p6_a49 out nocopy JTF_NUMBER_TABLE
    , p6_a50 out nocopy JTF_DATE_TABLE
    , p6_a51 out nocopy JTF_NUMBER_TABLE
    , p6_a52 out nocopy JTF_DATE_TABLE
    , p6_a53 out nocopy JTF_NUMBER_TABLE
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a58 out nocopy JTF_DATE_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a77 out nocopy JTF_NUMBER_TABLE
    , p6_a78 out nocopy JTF_DATE_TABLE
    , p6_a79 out nocopy JTF_NUMBER_TABLE
    , p6_a80 out nocopy JTF_NUMBER_TABLE
    , p6_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a82 out nocopy JTF_DATE_TABLE
    , p6_a83 out nocopy JTF_NUMBER_TABLE
    , p6_a84 out nocopy JTF_DATE_TABLE
    , p6_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a93 out nocopy JTF_DATE_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a31 out nocopy JTF_NUMBER_TABLE
    , p7_a32 out nocopy JTF_DATE_TABLE
    , p7_a33 out nocopy JTF_NUMBER_TABLE
    , p7_a34 out nocopy JTF_DATE_TABLE
    , p7_a35 out nocopy JTF_NUMBER_TABLE
    , p7_a36 out nocopy JTF_NUMBER_TABLE
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_DATE_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a47 out nocopy JTF_NUMBER_TABLE
    , p7_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a49 out nocopy JTF_NUMBER_TABLE
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a51 out nocopy JTF_NUMBER_TABLE
    , p7_a52 out nocopy JTF_DATE_TABLE
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_NUMBER_TABLE
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_NUMBER_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a14 out nocopy JTF_DATE_TABLE
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a37 out nocopy JTF_NUMBER_TABLE
    , p8_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_NUMBER_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_NUMBER_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_NUMBER_TABLE
    , p8_a48 out nocopy JTF_DATE_TABLE
    , p8_a49 out nocopy JTF_NUMBER_TABLE
    , p8_a50 out nocopy JTF_DATE_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_DATE_TABLE
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_NUMBER_TABLE
    , p8_a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a76 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_DATE_TABLE
    , p8_a79 out nocopy JTF_NUMBER_TABLE
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a82 out nocopy JTF_DATE_TABLE
    , p8_a83 out nocopy JTF_NUMBER_TABLE
    , p8_a84 out nocopy JTF_DATE_TABLE
    , p8_a85 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a86 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a87 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a88 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a89 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a91 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a93 out nocopy JTF_DATE_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_NUMBER_TABLE
    , p9_a4 out nocopy JTF_NUMBER_TABLE
    , p9_a5 out nocopy JTF_NUMBER_TABLE
    , p9_a6 out nocopy JTF_NUMBER_TABLE
    , p9_a7 out nocopy JTF_NUMBER_TABLE
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_NUMBER_TABLE
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a11 out nocopy JTF_NUMBER_TABLE
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p9_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a31 out nocopy JTF_NUMBER_TABLE
    , p9_a32 out nocopy JTF_DATE_TABLE
    , p9_a33 out nocopy JTF_NUMBER_TABLE
    , p9_a34 out nocopy JTF_DATE_TABLE
    , p9_a35 out nocopy JTF_NUMBER_TABLE
    , p9_a36 out nocopy JTF_NUMBER_TABLE
    , p9_a37 out nocopy JTF_NUMBER_TABLE
    , p9_a38 out nocopy JTF_NUMBER_TABLE
    , p9_a39 out nocopy JTF_DATE_TABLE
    , p9_a40 out nocopy JTF_NUMBER_TABLE
    , p9_a41 out nocopy JTF_NUMBER_TABLE
    , p9_a42 out nocopy JTF_NUMBER_TABLE
    , p9_a43 out nocopy JTF_NUMBER_TABLE
    , p9_a44 out nocopy JTF_NUMBER_TABLE
    , p9_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a47 out nocopy JTF_NUMBER_TABLE
    , p9_a48 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a49 out nocopy JTF_NUMBER_TABLE
    , p9_a50 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a51 out nocopy JTF_NUMBER_TABLE
    , p9_a52 out nocopy JTF_DATE_TABLE
    , p9_a53 out nocopy JTF_NUMBER_TABLE
    , p9_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  DATE := fnd_api.g_miss_date
    , p2_a4  DATE := fnd_api.g_miss_date
    , p2_a5  DATE := fnd_api.g_miss_date
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  VARCHAR2 := fnd_api.g_miss_char
    , p2_a8  VARCHAR2 := fnd_api.g_miss_char
    , p2_a9  VARCHAR2 := fnd_api.g_miss_char
    , p2_a10  NUMBER := 0-1962.0724
    , p2_a11  VARCHAR2 := fnd_api.g_miss_char
    , p2_a12  VARCHAR2 := fnd_api.g_miss_char
    , p2_a13  NUMBER := 0-1962.0724
    , p2_a14  DATE := fnd_api.g_miss_date
    , p2_a15  NUMBER := 0-1962.0724
    , p2_a16  NUMBER := 0-1962.0724
    , p2_a17  VARCHAR2 := fnd_api.g_miss_char
    , p2_a18  VARCHAR2 := fnd_api.g_miss_char
    , p2_a19  VARCHAR2 := fnd_api.g_miss_char
    , p2_a20  VARCHAR2 := fnd_api.g_miss_char
    , p2_a21  VARCHAR2 := fnd_api.g_miss_char
    , p2_a22  VARCHAR2 := fnd_api.g_miss_char
    , p2_a23  VARCHAR2 := fnd_api.g_miss_char
    , p2_a24  NUMBER := 0-1962.0724
    , p2_a25  VARCHAR2 := fnd_api.g_miss_char
    , p2_a26  DATE := fnd_api.g_miss_date
  );
  procedure accelerate_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2
    , p_representation_type  VARCHAR2
    , x_trx_number out nocopy  VARCHAR2
  );
--Bug# 9191475
/*
  procedure adjust_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_trx_number out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_VARCHAR2_TABLE_200
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
  );
*/
  procedure generate_accruals(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_generate_accruals_pvt_w;

/
