--------------------------------------------------------
--  DDL for Package CN_CALC_SQL_EXPS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SQL_EXPS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwcexps.pls 120.6 2007/03/14 12:57:03 kjayapau ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy cn_calc_sql_exps_pvt.parent_expression_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t cn_calc_sql_exps_pvt.parent_expression_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy cn_calc_sql_exps_pvt.calc_expression_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t cn_calc_sql_exps_pvt.calc_expression_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy cn_calc_sql_exps_pvt.expr_type_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p4(t cn_calc_sql_exps_pvt.expr_type_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p5(t out nocopy cn_calc_sql_exps_pvt.num_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t cn_calc_sql_exps_pvt.num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure parse_plan_elements(p_sql_select  VARCHAR2
    , x_plan_elt_tbl out nocopy JTF_NUMBER_TABLE
    , x_parsed_sql_select out nocopy  VARCHAR2
  );
  procedure get_dependent_plan_elts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_node_type  VARCHAR2
    , p_node_id  NUMBER
    , x_plan_elt_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_parent_plan_elts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_node_type  VARCHAR2
    , p_node_id  NUMBER
    , x_plan_elt_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_calc_sql_exps_pvt_w;

/
