--------------------------------------------------------
--  DDL for Package AMS_LISTGENERATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTGENERATION_PUB_W" AUTHID CURRENT_USER as
  /* $Header: amszlgns.pls 120.1 2005/06/27 05:43:57 appldev ship $ */
  procedure create_list_from_query(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_list_name  VARCHAR2
    , p_list_type  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_list_header_id  NUMBER
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , p_primary_key  VARCHAR2
    , p_source_object_name  VARCHAR2
    , p_master_type  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  );
  procedure create_list_from_query(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_list_name  VARCHAR2
    , p_list_type  VARCHAR2
    , p_owner_user_id  NUMBER
    , p_list_header_id  NUMBER
    , p_sql_string_tbl JTF_VARCHAR2_TABLE_4000
    , p_primary_key  VARCHAR2
    , p_source_object_name  VARCHAR2
    , p_master_type  VARCHAR2
    , p_query_param JTF_VARCHAR2_TABLE_4000
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  );
end ams_listgeneration_pub_w;

 

/
