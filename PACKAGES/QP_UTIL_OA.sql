--------------------------------------------------------
--  DDL for Package QP_UTIL_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UTIL_OA" AUTHID CURRENT_USER as
  /* $Header: ozfaqpus.pls 115.0 2003/11/07 18:45:30 gramanat noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy qp_util.v_segs_upg_tab, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t qp_util.v_segs_upg_tab, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p39(t out nocopy qp_util.create_context_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p39(t qp_util.create_context_out_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p41(t out nocopy qp_util.create_attribute_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p41(t qp_util.create_attribute_out_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure validate_qp_flexfield(flexfield_name  VARCHAR2
    , context  VARCHAR2
    , attribute  VARCHAR2
    , value  VARCHAR2
    , application_short_name  VARCHAR2
    , context_flag out nocopy  VARCHAR2
    , attribute_flag out nocopy  VARCHAR2
    , value_flag out nocopy  VARCHAR2
    , datatype out nocopy  VARCHAR2
    , precedence out nocopy  VARCHAR2
    , error_code out nocopy  NUMBER
    , check_enabled  number
  );
  procedure get_segs_for_flex(flexfield_name  VARCHAR2
    , application_short_name  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , error_code out nocopy  NUMBER
  );
  procedure get_segs_flex_precedence(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p_context  VARCHAR2
    , p_attribute  VARCHAR2
    , x_precedence out nocopy  NUMBER
    , x_datatype out nocopy  VARCHAR2
  );
  procedure web_create_context_lov(p_field_context  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure web_create_attribute_lov(p_context_code  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , p_segment_level  NUMBER
    , p_field_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
  );
end qp_util_oa;

 

/
