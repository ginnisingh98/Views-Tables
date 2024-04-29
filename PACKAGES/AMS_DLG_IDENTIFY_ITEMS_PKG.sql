--------------------------------------------------------
--  DDL for Package AMS_DLG_IDENTIFY_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DLG_IDENTIFY_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdiis.pls 115.0 2002/04/28 20:28:48 pkm ship        $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DLG_IDENTIFY_ITEMS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_item_id   IN OUT NUMBER,
          p_list_source_type_id    NUMBER,
          p_list_source_field_id    NUMBER,
          p_source_type_code    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NUMBER,
          p_rule_id    NUMBER);

PROCEDURE Update_Row(
          p_item_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_list_source_field_id    NUMBER,
          p_source_type_code    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER);

PROCEDURE Delete_Row(
    p_ITEM_ID  NUMBER);

PROCEDURE load_row (
          p_item_id    NUMBER,
          p_list_source_type_id    NUMBER,
          p_list_source_field_id    NUMBER,
          p_source_type_code    VARCHAR2,
          p_source_column_name    VARCHAR2,
	  p_rule_id               NUMBER,
	  p_owner                 VARCHAR2
  );

END AMS_DLG_IDENTIFY_ITEMS_PKG;

 

/
