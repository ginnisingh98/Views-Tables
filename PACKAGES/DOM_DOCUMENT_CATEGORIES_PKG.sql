--------------------------------------------------------
--  DDL for Package DOM_DOCUMENT_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_DOCUMENT_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: DOMCATGS.pls 120.0 2006/02/23 02:31 rkhasa noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_PARENT_CATEGORY_ID in NUMBER,
  X_DOC_CREATION_ALLOWED in VARCHAR2,
  X_INACTIVE_ON in DATE,
  X_DEFAULT_FOLDER_OPTION in VARCHAR2,
  X_DEFAULT_REPOSITORY_ID in NUMBER,
  X_DEFAULT_FOLDER_LOCATION in VARCHAR2,
  X_DEF_FOLDER_NAMING_METHOD in VARCHAR2,
  X_DEF_FOLDER_PREFIX in VARCHAR2,
  X_DEF_FOLDER_SUFFIX in VARCHAR2,
  X_DOC_NUM_SCHEME in VARCHAR2,
  X_DOC_NUM_PREFIX in VARCHAR2,
  X_DOC_NUM_START_NUMBER in NUMBER,
  X_DOC_NUM_INCR in NUMBER,
  X_DOC_NUM_SUFFIX in VARCHAR2,
  X_DOC_NUM_FUNC_ACTION_ID in NUMBER,
  X_DOC_REV_SCHEME in VARCHAR2,
  X_DOC_REV_SEEDED_SEQ_CODE in VARCHAR2,
  X_DOC_REV_PREFIX in VARCHAR2,
  X_DOC_REV_START_NUMBER in NUMBER,
  X_DOC_REV_INCR in NUMBER,
  X_DOC_REV_SUFFIX in VARCHAR2,
  X_DOC_REV_FUNC_ACTION_ID in NUMBER,
  X_DOC_NAME_SCHEME in VARCHAR2,
  X_DOC_NAME_FUNC_ACTION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_CATALOG_ID in NUMBER,
  X_CATEGORY_ID in NUMBER
);
procedure ADD_LANGUAGE;
end DOM_DOCUMENT_CATEGORIES_PKG;

 

/