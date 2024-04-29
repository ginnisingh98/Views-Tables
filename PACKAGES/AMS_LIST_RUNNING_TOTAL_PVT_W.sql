--------------------------------------------------------
--  DDL for Package AMS_LIST_RUNNING_TOTAL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_RUNNING_TOTAL_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswlruts.pls 115.0 2003/11/19 19:11:04 huili noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ams_list_running_total_pvt.sql_string_4k, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p0(t ams_list_running_total_pvt.sql_string_4k, a0 out nocopy JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p1(t out nocopy ams_list_running_total_pvt.t_number, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t ams_list_running_total_pvt.t_number, a0 out nocopy JTF_NUMBER_TABLE);

  procedure process_query(p_sql_string JTF_VARCHAR2_TABLE_4000
    , p_total_parameters JTF_NUMBER_TABLE
    , p_string_parameters JTF_VARCHAR2_TABLE_4000
    , p_template_id  NUMBER
    , p_parameters JTF_VARCHAR2_TABLE_4000
    , p_parameters_value JTF_NUMBER_TABLE
    , p_sql_results out nocopy JTF_NUMBER_TABLE
  );
end ams_list_running_total_pvt_w;

 

/
