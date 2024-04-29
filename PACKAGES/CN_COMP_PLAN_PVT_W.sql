--------------------------------------------------------
--  DDL for Package CN_COMP_PLAN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLAN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwcmpns.pls 120.2.12010000.2 2009/08/04 17:21:46 rnagaraj ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_comp_plan_pvt.comp_plan_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_1900
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_comp_plan_pvt.comp_plan_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy cn_comp_plan_pvt.sales_role_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cn_comp_plan_pvt.sales_role_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cn_comp_plan_pvt.srp_plan_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_400
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p7(t cn_comp_plan_pvt.srp_plan_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_400
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    );

  procedure create_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_comp_plan_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  VARCHAR2
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  VARCHAR2
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  DATE
    , p4_a11 in out nocopy  VARCHAR2
    , p4_a12 in out nocopy  VARCHAR2
    , p4_a13 in out nocopy  VARCHAR2
    , p4_a14 in out nocopy  VARCHAR2
    , p4_a15 in out nocopy  VARCHAR2
    , p4_a16 in out nocopy  VARCHAR2
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  NUMBER
    , p4_a28 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_comp_plan_sum(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_start_record  NUMBER
    , p_fetch_size  NUMBER
    , p_search_name  VARCHAR2
    , p_search_date  DATE
    , p_search_status  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 out nocopy JTF_DATE_TABLE
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a9 out nocopy JTF_DATE_TABLE
    , p9_a10 out nocopy JTF_DATE_TABLE
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 out nocopy JTF_NUMBER_TABLE
    , p9_a28 out nocopy JTF_NUMBER_TABLE
    , x_total_record out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_comp_plan_dtl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_1900
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a9 out nocopy JTF_DATE_TABLE
    , p5_a10 out nocopy JTF_DATE_TABLE
    , p5_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_sales_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validate_comp_plan(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  DATE
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  DATE
    , p4_a10  DATE
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
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  NUMBER
    , p4_a28  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_assigned_salesreps(p_comp_plan_id  NUMBER
    , p_range_low  NUMBER
    , p_range_high  NUMBER
    , x_total_rows out nocopy  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_400
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a6 out nocopy JTF_DATE_TABLE
    , p4_a7 out nocopy JTF_DATE_TABLE
  );
end cn_comp_plan_pvt_w;

/
