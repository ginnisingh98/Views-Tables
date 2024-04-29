--------------------------------------------------------
--  DDL for Package GMA_SY_PARA_CDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_SY_PARA_CDS_PKG" AUTHID CURRENT_USER AS
/* $Header: GMAPARAS.pls 115.5 2002/10/31 19:29:54 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2
);
procedure UPDATE_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_PARA_DESC in VARCHAR2
);

procedure LOAD_ROW (
  X_TABLE_NAME in VARCHAR2,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_NONPRINTABLE_IND in NUMBER,
  X_PARA_DESC in VARCHAR2
);


end GMA_SY_PARA_CDS_PKG;

 

/
