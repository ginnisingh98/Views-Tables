--------------------------------------------------------
--  DDL for Package QP_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_UTIL_W" AUTHID CURRENT_USER as
  /* $Header: amswqpus.pls 115.1 2002/07/31 20:32:46 julou noship $ */
  procedure rosetta_table_copy_in_p1(t out qp_util.v_segs_upg_tab, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t qp_util.v_segs_upg_tab, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p41(t out qp_util.create_context_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p41(t qp_util.create_context_out_tbl, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p43(t out qp_util.create_attribute_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p43(t qp_util.create_attribute_out_tbl, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    );

  procedure validate_qp_flexfield(flexfield_name  VARCHAR2
    , context  VARCHAR2
    , attribute  VARCHAR2
    , value  VARCHAR2
    , application_short_name  VARCHAR2
    , context_flag out  VARCHAR2
    , attribute_flag out  VARCHAR2
    , value_flag out  VARCHAR2
    , datatype out  VARCHAR2
    , precedence out  VARCHAR2
    , error_code out  NUMBER
    , check_enabled  number
  );
  procedure get_segs_for_flex(flexfield_name  VARCHAR2
    , application_short_name  VARCHAR2
    , p2_a0 out JTF_VARCHAR2_TABLE_100
    , p2_a1 out JTF_VARCHAR2_TABLE_100
    , p2_a2 out JTF_NUMBER_TABLE
    , p2_a3 out JTF_VARCHAR2_TABLE_100
    , error_code out  NUMBER
  );
  procedure get_segs_flex_precedence(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p_context  VARCHAR2
    , p_attribute  VARCHAR2
    , x_precedence out  NUMBER
    , x_datatype out  VARCHAR2
  );
  procedure correct_active_dates(p_active_date_first_type in out  VARCHAR2
    , p_start_date_active_first in out  date
    , p_end_date_active_first in out  date
    , p_active_date_second_type in out  VARCHAR2
    , p_start_date_active_second in out  date
    , p_end_date_active_second in out  date
  );
  procedure web_create_context_lov(p_field_context  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , x_return_status out  VARCHAR2
    , p6_a0 out JTF_VARCHAR2_TABLE_100
    , p6_a1 out JTF_VARCHAR2_TABLE_300
  );
  procedure web_create_attribute_lov(p_context_code  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , p_segment_level  NUMBER
    , p_field_context  VARCHAR2
    , x_return_status out  VARCHAR2
    , p8_a0 out JTF_VARCHAR2_TABLE_100
    , p8_a1 out JTF_VARCHAR2_TABLE_300
    , p8_a2 out JTF_VARCHAR2_TABLE_100
    , p8_a3 out JTF_NUMBER_TABLE
    , p8_a4 out JTF_NUMBER_TABLE
  );
end qp_util_w;

 

/
