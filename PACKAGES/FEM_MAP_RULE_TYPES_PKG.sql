--------------------------------------------------------
--  DDL for Package FEM_MAP_RULE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_MAP_RULE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: fem_maprltyp_pkh.pls 120.2 2008/02/20 07:01:31 jcliving ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_MAP_RULE_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAP_RULE_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_MAP_RULE_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAP_RULE_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_MAP_RULE_TYPE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MAP_RULE_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_MAP_RULE_TYPE_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_MAP_RULE_TYPE_CODE in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_MAP_RULE_TYPE_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2);


end FEM_MAP_RULE_TYPES_PKG;

/
