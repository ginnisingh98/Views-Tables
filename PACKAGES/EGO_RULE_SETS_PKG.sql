--------------------------------------------------------
--  DDL for Package EGO_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_RULE_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: EGOVRSTS.pls 120.1 2007/07/31 10:54:04 rgadiyar noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure TRANSLATE_ROW (
  X_RULESET_ID in NUMBER,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
 );
 procedure LOAD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULESET_ID in NUMBER,
  X_RULESET_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
 );
procedure DELETE_ROW (
  X_RULESET_ID in NUMBER
);
procedure ADD_LANGUAGE;
end EGO_RULE_SETS_PKG;

/