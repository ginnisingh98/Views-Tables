--------------------------------------------------------
--  DDL for Package BNE_USER_SETTINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_USER_SETTINGS_PKG" AUTHID CURRENT_USER as
/* $Header: bneusersets.pls 120.2 2005/06/29 03:41:13 dvayro noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2
);
procedure UPDATE_ROW (
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2,
  X_SETTING_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_USER_ID in NUMBER,
  X_SETTING_GROUP in VARCHAR2,
  X_SETTING_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
procedure LOAD_ROW(
  x_user_name                   in VARCHAR2,
  x_setting_group               in VARCHAR2,
  x_setting_name                in VARCHAR2,
  x_setting_value               in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);

end BNE_USER_SETTINGS_PKG;

 

/
