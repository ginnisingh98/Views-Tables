--------------------------------------------------------
--  DDL for Package OZF_CLAIM_ACCRUAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CLAIM_ACCRUAL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwcacs.pls 120.5.12010000.3 2010/02/18 09:05:20 nepanda ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_claim_accrual_pvt.line_util_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_DATE_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ozf_claim_accrual_pvt.line_util_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ozf_claim_accrual_pvt.offer_performance_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ozf_claim_accrual_pvt.offer_performance_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p7(t out nocopy ozf_claim_accrual_pvt.offer_earning_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t ozf_claim_accrual_pvt.offer_earning_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_utiz_sql_stmt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_summary_view  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p9_a0 in out nocopy  VARCHAR2
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  VARCHAR2
    , p9_a3 in out nocopy  VARCHAR2
    , p9_a4 in out nocopy  VARCHAR2
    , p9_a5 in out nocopy  VARCHAR2
    , p_cust_account_id  NUMBER
    , x_utiz_sql_stmt out nocopy  VARCHAR2
  );
  procedure create_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure create_line_util(p_api_version  NUMBER
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
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p_mode  VARCHAR2
    , x_line_util_id out nocopy  NUMBER
  );
  procedure update_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure update_line_util(p_api_version  NUMBER
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
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  DATE
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version out nocopy  NUMBER
  );
  procedure delete_line_util_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_DATE_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_DATE_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_VARCHAR2_TABLE_100
    , p7_a11 JTF_VARCHAR2_TABLE_100
    , p7_a12 JTF_DATE_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_VARCHAR2_TABLE_100
    , p_mode  VARCHAR2
    , x_error_index out nocopy  NUMBER
  );
  procedure init_line_util_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  NUMBER
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  NUMBER
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  VARCHAR2
  );
  procedure complete_line_util_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  NUMBER
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  VARCHAR2
  );
  procedure update_group_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_summary_view  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
    , p_mode  VARCHAR2
  );
  procedure delete_group_line_util(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  NUMBER
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  DATE
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  NUMBER
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p_mode  VARCHAR2
  );
  procedure asso_accruals_to_claim(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_claim_id  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  VARCHAR2
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  NUMBER
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  NUMBER
    , p8_a9  VARCHAR2
    , p8_a10  NUMBER
    , p8_a11  VARCHAR2
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  VARCHAR2
    , p8_a21  NUMBER
    , p8_a22  VARCHAR2
    , p8_a23  NUMBER
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  DATE
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  VARCHAR2
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  NUMBER
    , p8_a37  NUMBER
    , p8_a38  VARCHAR2
  );
  procedure check_offer_performance(p_cust_account_id  NUMBER
    , p_offer_id  NUMBER
    , p_resale_flag  VARCHAR2
    , p_check_all_flag  VARCHAR2
    , x_performance_flag out nocopy  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a4 out nocopy JTF_DATE_TABLE
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure check_offer_performance_tbl(p_claim_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_DATE_TABLE
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 out nocopy JTF_NUMBER_TABLE
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure check_offer_earning_tbl(p_claim_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
  );
  function calculate_fxgl_amount(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  DATE
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  VARCHAR2
    , p1_a0  VARCHAR2
    , p1_a1  VARCHAR2
    , p1_a2  VARCHAR2
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  VARCHAR2
  ) return number;
end ozf_claim_accrual_pvt_w;

/
