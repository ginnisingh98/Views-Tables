--------------------------------------------------------
--  DDL for Package GMA_PS_TEXT_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_PS_TEXT_TBL_PKG" AUTHID CURRENT_USER AS
/* $Header: GMAPSTXS.pls 115.4 2002/10/31 19:10:22 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROW_ID in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
-- Bug #1712111 (JKB)
procedure DELETE_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_ROW_ID in VARCHAR2
-- Bug #1775354 (JKB)
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_OWNER         in VARCHAR2
);

procedure LOAD_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_OWNER         in VARCHAR2
);

end GMA_PS_TEXT_TBL_PKG;

 

/
