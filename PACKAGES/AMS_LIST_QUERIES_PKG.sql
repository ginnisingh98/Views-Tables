--------------------------------------------------------
--  DDL for Package AMS_LIST_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_QUERIES_PKG" AUTHID CURRENT_USER AS
/* $Header: amstliqs.pls 120.3 2006/06/27 06:20:52 bmuthukr noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_QUERIES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_list_query_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number);

PROCEDURE Update_Row(
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number);

PROCEDURE Delete_Row(
    p_LIST_QUERY_ID  NUMBER);
PROCEDURE Lock_Row(
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
          p_parent_list_query_id number,
          p_sequence_order  in  number);

PROCEDURE load_row(
          p_owner            varchar2,
          p_list_query_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name    VARCHAR2,
          p_type    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_primary_key    VARCHAR2,
          p_source_object_name  VARCHAR2,
          p_public_flag    VARCHAR2,
          p_org_id    NUMBER,
          p_comments    VARCHAR2,
          p_act_list_query_used_by_id    NUMBER,
          p_arc_act_list_query_used_by    VARCHAR2,
          p_sql_string    VARCHAR2,
	  p_custom_mode    VARCHAR2
          );

PROCEDURE ADD_LANGUAGE;

PROCEDURE translate_row(
  p_list_query_id in number,
  p_name	  in varchar2,
  p_owner         in varchar2,
  p_custom_mode   in varchar2
 ) ;

END AMS_LIST_QUERIES_PKG;

 

/
