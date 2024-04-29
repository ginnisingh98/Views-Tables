--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_TYPE_ASSOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_TYPE_ASSOCS_PKG" AUTHID CURRENT_USER AS
/* $Header: amststas.pls 120.0 2005/05/31 17:53:25 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SRC_TYPE_ASSOCS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_list_source_type_assoc_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column varchar2);

PROCEDURE Update_Row(
          p_list_source_type_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column varchar2);

PROCEDURE Delete_Row(
    p_LIST_SOURCE_TYPE_ASSOC_ID  NUMBER);
PROCEDURE Lock_Row(
          p_list_source_type_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column varchar2);

PROCEDURE load_row (
  x_list_source_type_assoc_id IN NUMBER,
  x_enabled_flag IN VARCHAR2,
  x_master_source_type_id IN NUMBER,
  x_sub_source_type_id IN NUMBER,
  x_sub_source_type_pk_column IN VARCHAR2,
  x_description IN VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2,
  x_master_source_type_pk_column in varchar2);


END AMS_LIST_SRC_TYPE_ASSOCS_PKG;

 

/
