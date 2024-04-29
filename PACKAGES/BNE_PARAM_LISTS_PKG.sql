--------------------------------------------------------
--  DDL for Package BNE_PARAM_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_PARAM_LISTS_PKG" AUTHID CURRENT_USER as
/* $Header: bneparls.pls 120.2 2005/06/29 03:40:41 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSISTENT_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LIST_RESOLVER in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSISTENT_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LIST_RESOLVER in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSISTENT_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ATTRIBUTE_APP_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_LIST_RESOLVER in VARCHAR2,
  X_USER_TIP in VARCHAR2,
  X_PROMPT_LEFT in VARCHAR2,
  X_PROMPT_ABOVE in VARCHAR2,
  X_USER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_PARAM_LIST_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_user_tip              IN VARCHAR2,
  x_prompt_left           IN VARCHAR2,
  x_prompt_above          IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);
procedure LOAD_ROW(
  x_param_list_asn        IN VARCHAR2,
  x_param_list_code       IN VARCHAR2,
  x_object_version_number IN VARCHAR2,
  x_persistent_flag       IN VARCHAR2,
  x_comments              IN VARCHAR2,
  x_attribute_asn         IN VARCHAR2,
  x_attribute_code        IN VARCHAR2,
  x_list_resolver         IN VARCHAR2,
  x_user_tip              IN VARCHAR2,
  x_prompt_left           IN VARCHAR2,
  x_prompt_above          IN VARCHAR2,
  x_user_name             IN VARCHAR2,
  x_owner                 IN VARCHAR2,
  x_last_update_date      IN VARCHAR2,
  x_custom_mode           IN VARCHAR2
);

end BNE_PARAM_LISTS_PKG;

 

/
