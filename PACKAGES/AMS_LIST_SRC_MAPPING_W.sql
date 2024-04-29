--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_MAPPING_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_MAPPING_W" AUTHID CURRENT_USER as
  /* $Header: amswlsrs.pls 120.1 2006/01/12 22:07 rmbhanda noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ams_list_src_mapping.l_tbl_type, a0 JTF_VARCHAR2_TABLE_1000);
  procedure rosetta_table_copy_out_p1(t ams_list_src_mapping.l_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000);

  procedure create_mapping(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_imp_list_header_id  NUMBER
    , p_source_name  VARCHAR2
    , p_table_name  VARCHAR2
    , p_list_src_fields JTF_VARCHAR2_TABLE_1000
    , p_list_target_fields JTF_VARCHAR2_TABLE_1000
    , px_src_type_id in out nocopy  NUMBER
  );
end ams_list_src_mapping_w;

 

/
