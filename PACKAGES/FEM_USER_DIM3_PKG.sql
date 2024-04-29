--------------------------------------------------------
--  DDL for Package FEM_USER_DIM3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_USER_DIM3_PKG" AUTHID CURRENT_USER as
/* $Header: fem_usrdim3_pkh.pls 120.1 2005/06/27 13:25:58 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_USER_DIM3_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM3_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM3_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_USER_DIM3_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM3_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM3_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_USER_DIM3_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM3_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM3_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_USER_DIM3_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_USER_DIM3_ID in number,
        x_VALUE_SET_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_USER_DIM3_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2);


end FEM_USER_DIM3_PKG;

 

/
