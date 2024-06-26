--------------------------------------------------------
--  DDL for Package FND_DESCR_FLEX_COL_USAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DESCR_FLEX_COL_USAGE_PKG" AUTHID CURRENT_USER as
/* $Header: AFFFDFSS.pls 120.2.12010000.3 2017/01/13 16:28:21 hgeorgi ship $ */


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
  X_FORM_LEFT_PROMPT in VARCHAR2,
  X_FORM_ABOVE_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 /*,
  X_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_SEGMENT_UPDATE_FLAG in VARCHAR2 */
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_END_USER_COLUMN_NAME in VARCHAR2,
  X_COLUMN_SEQ_NUM in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_SECURITY_ENABLED_FLAG in VARCHAR2,
  X_DISPLAY_FLAG in VARCHAR2,
  X_DISPLAY_SIZE in NUMBER,
  X_MAXIMUM_DESCRIPTION_LEN in NUMBER,
  X_CONCATENATION_DESCRIPTION_LE in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_RANGE_CODE in VARCHAR2,
  X_DEFAULT_TYPE in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_RUNTIME_PROPERTY_FUNCTION in VARCHAR2,
  X_SRW_PARAM in VARCHAR2,
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
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_end_user_column_name         IN VARCHAR2,
   x_column_seq_num               IN NUMBER,
   x_enabled_flag                 IN VARCHAR2,
   x_required_flag                IN VARCHAR2,
   x_security_enabled_flag        IN VARCHAR2,
   x_display_flag                 IN VARCHAR2,
   x_display_size                 IN NUMBER,
   x_maximum_description_len      IN NUMBER,
   x_concatenation_description_le IN NUMBER,
   x_flex_value_set_name          IN VARCHAR2,
   x_range_code                   IN VARCHAR2,
   x_default_type                 IN VARCHAR2,
   x_default_value                IN VARCHAR2,
   x_runtime_property_function    IN VARCHAR2,
   x_srw_param                    IN VARCHAR2,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2 /*,
   x_segment_insert_flag          IN VARCHAR2,
   x_segment_update_flag          IN VARCHAR2 */);

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_form_left_prompt             IN VARCHAR2,
   x_form_above_prompt            IN VARCHAR2,
   x_description                  IN VARCHAR2);

end FND_DESCR_FLEX_COL_USAGE_PKG;

/
