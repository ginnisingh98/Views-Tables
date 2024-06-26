--------------------------------------------------------
--  DDL for Package XTR_SYS_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_SYS_LANGUAGES_PKG" AUTHID CURRENT_USER as
/* $Header: xtrlangs.pls 120.2 2005/06/29 10:10:24 badiredd ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOAD_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2);
procedure LOCK_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2,
  X_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2 default null,
  X_TEXT in VARCHAR2,
  X_LANG in VARCHAR2 default null,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure TRANSLATE_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2,
  X_ORIGINAL_TEXT in VARCHAR2 default null,
  X_TEXT in VARCHAR2,
  X_OWNER in VARCHAR2);

procedure DELETE_ROW (
  X_MODULE_NAME in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_ITEM_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
end XTR_SYS_LANGUAGES_PKG;

 

/
