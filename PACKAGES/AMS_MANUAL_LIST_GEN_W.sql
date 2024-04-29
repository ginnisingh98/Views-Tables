--------------------------------------------------------
--  DDL for Package AMS_MANUAL_LIST_GEN_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MANUAL_LIST_GEN_W" AUTHID CURRENT_USER as
  /* $Header: amswlmls.pls 120.0 2005/05/31 21:30:21 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ams_manual_list_gen.primary_key_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t ams_manual_list_gen.primary_key_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy ams_manual_list_gen.varchar2_tbl_type, a0 JTF_VARCHAR2_TABLE_400);
  procedure rosetta_table_copy_out_p2(t ams_manual_list_gen.varchar2_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400);

  procedure rosetta_table_copy_in_p3(t out nocopy ams_manual_list_gen.child_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p3(t ams_manual_list_gen.child_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure process_manual_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_master_type  VARCHAR2
    , x_added_entry_count out nocopy  NUMBER
  );
  procedure process_manual_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_master_type  VARCHAR2
  );
  procedure process_employee_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_list_header_id  NUMBER
    , p_primary_key_tbl JTF_NUMBER_TABLE
    , p_last_name_tbl JTF_VARCHAR2_TABLE_400
    , p_first_name_tbl JTF_VARCHAR2_TABLE_400
    , p_email_tbl JTF_VARCHAR2_TABLE_400
    , p_master_type  VARCHAR2
  );
end ams_manual_list_gen_w;

 

/
