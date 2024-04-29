--------------------------------------------------------
--  DDL for Package CN_CALC_FORMULAS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_FORMULAS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwforms.pls 120.3 2006/01/05 18:08 jxsingh ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy cn_calc_formulas_pvt.input_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t cn_calc_formulas_pvt.input_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy cn_calc_formulas_pvt.rt_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t cn_calc_formulas_pvt.rt_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy cn_calc_formulas_pvt.parent_expression_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p5(t cn_calc_formulas_pvt.parent_expression_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p6(t out nocopy cn_calc_formulas_pvt.formula_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t cn_calc_formulas_pvt.formula_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_generate_packages  VARCHAR2
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_formula_type  VARCHAR2
    , p_trx_group_code  VARCHAR2
    , p_number_dim  NUMBER
    , p_cumulative_flag  VARCHAR2
    , p_itd_flag  VARCHAR2
    , p_split_flag  VARCHAR2
    , p_threshold_all_tier_flag  VARCHAR2
    , p_modeling_flag  VARCHAR2
    , p_perf_measure_id  NUMBER
    , p_output_exp_id  NUMBER
    , p_f_output_exp_id  NUMBER
    , p18_a0 JTF_NUMBER_TABLE
    , p18_a1 JTF_NUMBER_TABLE
    , p18_a2 JTF_NUMBER_TABLE
    , p18_a3 JTF_NUMBER_TABLE
    , p18_a4 JTF_VARCHAR2_TABLE_100
    , p18_a5 JTF_VARCHAR2_TABLE_100
    , p18_a6 JTF_VARCHAR2_TABLE_100
    , p18_a7 JTF_VARCHAR2_TABLE_100
    , p18_a8 JTF_NUMBER_TABLE
    , p18_a9 JTF_VARCHAR2_TABLE_100
    , p18_a10 JTF_VARCHAR2_TABLE_100
    , p19_a0 JTF_NUMBER_TABLE
    , p19_a1 JTF_NUMBER_TABLE
    , p19_a2 JTF_DATE_TABLE
    , p19_a3 JTF_DATE_TABLE
    , p19_a4 JTF_VARCHAR2_TABLE_100
    , p19_a5 JTF_VARCHAR2_TABLE_100
    , p19_a6 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , x_calc_formula_id in out nocopy  NUMBER
    , x_formula_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_formula(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_generate_packages  VARCHAR2
    , p_calc_formula_id  NUMBER
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_formula_type  VARCHAR2
    , p_formula_status  VARCHAR2
    , p_trx_group_code  VARCHAR2
    , p_number_dim  NUMBER
    , p_cumulative_flag  VARCHAR2
    , p_itd_flag  VARCHAR2
    , p_split_flag  VARCHAR2
    , p_threshold_all_tier_flag  VARCHAR2
    , p_modeling_flag  VARCHAR2
    , p_perf_measure_id  NUMBER
    , p_output_exp_id  NUMBER
    , p_f_output_exp_id  NUMBER
    , p20_a0 JTF_NUMBER_TABLE
    , p20_a1 JTF_NUMBER_TABLE
    , p20_a2 JTF_NUMBER_TABLE
    , p20_a3 JTF_NUMBER_TABLE
    , p20_a4 JTF_VARCHAR2_TABLE_100
    , p20_a5 JTF_VARCHAR2_TABLE_100
    , p20_a6 JTF_VARCHAR2_TABLE_100
    , p20_a7 JTF_VARCHAR2_TABLE_100
    , p20_a8 JTF_NUMBER_TABLE
    , p20_a9 JTF_VARCHAR2_TABLE_100
    , p20_a10 JTF_VARCHAR2_TABLE_100
    , p21_a0 JTF_NUMBER_TABLE
    , p21_a1 JTF_NUMBER_TABLE
    , p21_a2 JTF_DATE_TABLE
    , p21_a3 JTF_DATE_TABLE
    , p21_a4 JTF_VARCHAR2_TABLE_100
    , p21_a5 JTF_VARCHAR2_TABLE_100
    , p21_a6 JTF_NUMBER_TABLE
    , p_org_id  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_formula_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_calc_formulas_pvt_w;

 

/
