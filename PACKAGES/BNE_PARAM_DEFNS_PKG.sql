--------------------------------------------------------
--  DDL for Package BNE_PARAM_DEFNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_PARAM_DEFNS_PKG" AUTHID CURRENT_USER as
/* $Header: bnepards.pls 120.3.12010000.2 2014/06/13 15:45:30 amgonzal ship $ */

/* ============================================================*/
/* WARNING WARNING WARNING WARNING WARNING WARNING WARNING     */
/* This is not the default package body generated by tltblgen. */
/* X_DEFAULT_STRING_TRANS_FLAG has been added.                 */
/* ============================================================*/

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_CATEGORY in NUMBER,
  X_DATATYPE in NUMBER,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_PARAM_RESOLVER in VARCHAR2,
  X_DEFAULT_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_VISIBLE_FLAG in VARCHAR2,
  X_DEFAULT_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_VALUE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_DISPLAY_TYPE in NUMBER,
  X_DISPLAY_STYLE in NUMBER,
  X_DISPLAY_SIZE in NUMBER,
  X_HELP_URL in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2,
  X_DEFAULT_STRING_TRANS_FLAG in VARCHAR2,
  X_DEFAULT_DESC in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_ACCESS_KEY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OA_FLEX_APPLICATION_ID in NUMBER DEFAULT NULL,
  X_OA_FLEX_CODE in VARCHAR2 DEFAULT NULL,
  X_OA_FLEX_NUM in VARCHAR2 DEFAULT NULL
);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_CATEGORY in NUMBER,
  X_DATATYPE in NUMBER,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_PARAM_RESOLVER in VARCHAR2,
  X_DEFAULT_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_VISIBLE_FLAG in VARCHAR2,
  X_DEFAULT_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_VALUE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_DISPLAY_TYPE in NUMBER,
  X_DISPLAY_STYLE in NUMBER,
  X_DISPLAY_SIZE in NUMBER,
  X_HELP_URL in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2,
  X_DEFAULT_STRING_TRANS_FLAG in VARCHAR2,
  X_DEFAULT_DESC in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_ACCESS_KEY in VARCHAR2,
  X_OA_FLEX_APPLICATION_ID in NUMBER DEFAULT NULL,
  X_OA_FLEX_CODE in VARCHAR2 DEFAULT NULL,
  X_OA_FLEX_NUM in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_SOURCE in VARCHAR2,
  X_PARAM_CATEGORY in NUMBER,
  X_DATATYPE in NUMBER,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_PARAM_RESOLVER in VARCHAR2,
  X_DEFAULT_REQUIRED_FLAG in VARCHAR2,
  X_DEFAULT_VISIBLE_FLAG in VARCHAR2,
  X_DEFAULT_USER_MODIFYABLE_FLAG in VARCHAR2,
  X_DEFAULT_DATE in DATE,
  X_DEFAULT_NUMBER in NUMBER,
  X_DEFAULT_BOOLEAN_FLAG in VARCHAR2,
  X_DEFAULT_FORMULA in VARCHAR2,
  X_VAL_TYPE in VARCHAR2,
  X_VAL_VALUE in VARCHAR2,
  X_MAX_SIZE in NUMBER,
  X_DISPLAY_TYPE in NUMBER,
  X_DISPLAY_STYLE in NUMBER,
  X_DISPLAY_SIZE in NUMBER,
  X_HELP_URL in VARCHAR2,
  X_FORMAT_MASK in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_DEFAULT_STRING in VARCHAR2,
  X_DEFAULT_STRING_TRANS_FLAG in VARCHAR2,
  X_DEFAULT_DESC in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_ACCESS_KEY in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OA_FLEX_APPLICATION_ID in NUMBER DEFAULT NULL,
  X_OA_FLEX_CODE in VARCHAR2 DEFAULT NULL,
  X_OA_FLEX_NUM in VARCHAR2 DEFAULT NULL
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_DEFN_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  x_param_defn_asn               in VARCHAR2,
  x_param_defn_code              in VARCHAR2,
  x_default_string_trans         in VARCHAR2,
  x_user_name                    in VARCHAR2,
  x_default_desc                 in VARCHAR2,
  x_prompt_left                  in VARCHAR2,
  x_prompt_above                 in VARCHAR2,
  x_user_tip                     in VARCHAR2,
  x_access_key                   in VARCHAR2,
  x_owner                        in VARCHAR2,
  x_last_update_date             in VARCHAR2,
  x_custom_mode                  in VARCHAR2
);
procedure LOAD_ROW(
  x_param_defn_asn               in VARCHAR2,
  x_param_defn_code              in VARCHAR2,
  x_object_version_number        in VARCHAR2,
  x_param_name                   in VARCHAR2,
  x_param_source                 in VARCHAR2,
  x_param_category               in VARCHAR2,
  x_datatype                     in VARCHAR2,
  x_attribute_asn                in VARCHAR2,
  x_attribute_code               in VARCHAR2,
  x_param_resolver               in VARCHAR2,
  x_default_required_flag        in VARCHAR2,
  x_default_visible_flag         in VARCHAR2,
  x_default_user_modifyable_flag in VARCHAR2,
  x_default_string               in VARCHAR2,
  x_default_string_trans_flag    in VARCHAR2,
  x_default_date                 in VARCHAR2,
  x_default_number               in VARCHAR2,
  x_default_boolean_flag         in VARCHAR2,
  x_default_formula              in VARCHAR2,
  x_val_type                     in VARCHAR2,
  x_val_value                    in VARCHAR2,
  x_max_size                     in VARCHAR2,
  x_display_type                 in VARCHAR2,
  x_display_style                in VARCHAR2,
  x_display_size                 in VARCHAR2,
  x_help_url                     in VARCHAR2,
  x_format_mask                  in VARCHAR2,
  x_user_name                    in VARCHAR2,
  x_default_desc                 in VARCHAR2,
  x_prompt_left                  in VARCHAR2,
  x_prompt_above                 in VARCHAR2,
  x_user_tip                     in VARCHAR2,
  x_access_key                   in VARCHAR2,
  x_owner                        in VARCHAR2,
  x_last_update_date             in VARCHAR2,
  x_custom_mode                  in VARCHAR2,
  x_oa_flex_asn                  in VARCHAR2 default null,
  x_oa_flex_code                 in VARCHAR2 default null,
  x_oa_flex_num                  in VARCHAR2 default null
);

end BNE_PARAM_DEFNS_PKG;

/
