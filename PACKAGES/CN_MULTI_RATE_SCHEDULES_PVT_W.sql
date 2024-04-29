--------------------------------------------------------
--  DDL for Package CN_MULTI_RATE_SCHEDULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MULTI_RATE_SCHEDULES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwrschs.pls 120.4 2006/01/18 16:13 jxsingh ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy cn_multi_rate_schedules_pvt.rate_table_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t cn_multi_rate_schedules_pvt.rate_table_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy cn_multi_rate_schedules_pvt.dims_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t cn_multi_rate_schedules_pvt.dims_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy cn_multi_rate_schedules_pvt.parents_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p7(t cn_multi_rate_schedules_pvt.parents_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p8(t out nocopy cn_multi_rate_schedules_pvt.num_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p8(t cn_multi_rate_schedules_pvt.num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p9(t out nocopy cn_multi_rate_schedules_pvt.plan_elt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p9(t cn_multi_rate_schedules_pvt.plan_elt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy cn_multi_rate_schedules_pvt.formula_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p10(t cn_multi_rate_schedules_pvt.formula_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out nocopy cn_multi_rate_schedules_pvt.comm_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t cn_multi_rate_schedules_pvt.comm_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_name  VARCHAR2
    , p_commission_unit_code  VARCHAR2
    , p_number_dim  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , x_rate_schedule_id in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_rate_schedule_id  NUMBER
    , p_name  VARCHAR2
    , p_commission_unit_code  VARCHAR2
    , p_number_dim  NUMBER
    , p_org_id  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_VARCHAR2_TABLE_100
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p10_a7 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_rate_tier_info(p_rate_schedule_id  NUMBER
    , p_rate_dim_tier_id_tbl JTF_NUMBER_TABLE
    , x_rate_tier_id out nocopy  NUMBER
    , x_rate_sequence out nocopy  NUMBER
    , x_commission_amount out nocopy  NUMBER
    , x_object_version_number out nocopy  NUMBER
  );
  procedure update_comm_rate(p_rate_schedule_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
  );
end cn_multi_rate_schedules_pvt_w;

 

/
