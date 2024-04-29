--------------------------------------------------------
--  DDL for Package FEM_OBJECT_CATALOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_OBJECT_CATALOG_PKG" AUTHID CURRENT_USER as
/* $Header: fem_objcat_pkh.pls 120.0 2005/06/06 19:55:42 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_OBJECT_ID in NUMBER
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_OBJECT_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_OBJECT_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2);


end FEM_OBJECT_CATALOG_PKG;

 

/
