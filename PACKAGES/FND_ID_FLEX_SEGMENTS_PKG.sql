--------------------------------------------------------
--  DDL for Package FND_ID_FLEX_SEGMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ID_FLEX_SEGMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFSEGS.pls 120.1.12010000.2 2016/12/13 22:08:35 hgeorgi ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_SEGMENT_NAME in VARCHAR2,
  X_SEGMENT_NUM in NUMBER,
  X_APPLICATION_COLUMN_INDEX_FLA in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_SEGMENT_NAME in VARCHAR2,
  X_SEGMENT_NUM in NUMBER,
  X_APPLICATION_COLUMN_INDEX_FLA in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_ADDITIONAL_WHERE_CLAUSE in VARCHAR2,
  X_SEGMENT_NAME in VARCHAR2,
  X_SEGMENT_NUM in NUMBER,
  X_APPLICATION_COLUMN_INDEX_FLA in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_APPLICATION_COLUMN_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_segment_name                 IN VARCHAR2,
   x_segment_num                  IN NUMBER,
   x_application_column_index_fla IN VARCHAR2,
   x_enabled_flag                 IN VARCHAR2,
   x_required_flag                IN VARCHAR2,
   x_display_flag                 IN VARCHAR2,
   x_display_size                 IN NUMBER,
   x_security_enabled_flag        IN VARCHAR2,
   x_maximum_description_len      IN NUMBER,
   x_concatenation_description_le IN NUMBER,
   x_flex_value_set_name          IN VARCHAR2,
   x_range_code                   IN VARCHAR2,
   x_default_type                 IN VARCHAR2,
   x_default_value                IN VARCHAR2,
   x_runtime_property_function    IN VARCHAR2,
   x_additional_where_clause      IN VARCHAR2,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2 /*,
   x_segment_insert_flag          IN VARCHAR2,
   x_segment_update_flag          IN VARCHAR2 */
);

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_ID_FLEX_SEGMENTS_PKG;

/
