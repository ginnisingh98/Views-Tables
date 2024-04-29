--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_FIELDS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstlsfs.pls 120.2 2005/09/06 14:13:40 vbhandar noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SRC_FIELDS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_list_source_field_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
);

PROCEDURE Update_Row(
          p_list_source_field_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
 	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
);


PROCEDURE Delete_Row(
    p_LIST_SOURCE_FIELD_ID  NUMBER);
PROCEDURE Lock_Row(
          p_list_source_field_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_de_list_source_type_code    VARCHAR2,
          p_list_source_type_id    NUMBER,
          p_field_table_name    VARCHAR2,
          p_field_column_name    VARCHAR2,
          p_source_column_name    VARCHAR2,
          p_source_column_meaning    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_start_position    NUMBER,
          p_end_position    NUMBER,
          p_FIELD_DATA_TYPE               VARCHAR2,
          p_FIELD_DATA_SIZE               NUMBER ,
          p_DEFAULT_UI_CONTROL            VARCHAR2,
          p_FIELD_LOOKUP_TYPE             VARCHAR2,
          p_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
          p_ALLOW_LABEL_OVERRIDE          VARCHAR2,
          p_FIELD_USAGE_TYPE              VARCHAR2,
          p_dialog_enabled                VARCHAR2,
 	  p_analytics_flag                VARCHAR2,
	  p_auto_binning_flag             VARCHAR2,
	  p_no_of_buckets                 NUMBER,
          p_attb_lov_id                   number,
          p_lov_defined_flag              varchar2,
	  p_column_type                   varchar2
);


PROCEDURE load_row (
  x_list_source_field_id IN NUMBER,
  x_de_list_source_type_code IN VARCHAR2,
  x_list_source_type_id IN NUMBER,
  x_field_table_name IN VARCHAR2,
  x_field_column_name IN VARCHAR2,
  x_source_column_name IN VARCHAR2,
  x_enabled_flag IN VARCHAR2,
  x_start_position IN NUMBER,
  x_end_position IN NUMBER,
  x_FIELD_DATA_TYPE               VARCHAR2,
  x_FIELD_DATA_SIZE               NUMBER ,
  x_DEFAULT_UI_CONTROL            VARCHAR2,
  x_FIELD_LOOKUP_TYPE             VARCHAR2,
  x_FIELD_LOOKUP_TYPE_VIEW_NAME   VARCHAR2,
  x_ALLOW_LABEL_OVERRIDE          VARCHAR2,
  x_FIELD_USAGE_TYPE              VARCHAR2,
  x_dialog_enabled                VARCHAR2,
  x_source_column_meaning IN VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2,
  x_analytics_flag                VARCHAR2,
  x_auto_binning_flag             VARCHAR2,
  x_no_of_buckets                 NUMBER,
  x_attb_lov_id                   number,
  x_lov_defined_flag              varchar2,
  x_USED_IN_LIST_ENTRIES          VARCHAR2,
  x_CHART_ENABLED_FLAG            VARCHAR2,
  x_DEFAULT_CHART_TYPE            VARCHAR2,
  x_USE_FOR_SPLITTING_FLAG        VARCHAR2,
  x_column_type                   varchar2
);


procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  x_list_source_field_id IN NUMBER,
  x_source_column_meaning IN VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode IN VARCHAR2
 ) ;

END AMS_LIST_SRC_FIELDS_PKG;

 

/
