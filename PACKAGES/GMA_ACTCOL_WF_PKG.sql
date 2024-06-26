--------------------------------------------------------
--  DDL for Package GMA_ACTCOL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_ACTCOL_WF_PKG" AUTHID CURRENT_USER as
/* $Header: GMAACTS.pls 115.4 2002/10/31 16:21:06 appldev ship $*/
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_OWNER         in VARCHAR2
);

procedure LOAD_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_OWNER         in VARCHAR2
);
END GMA_ACTCOL_WF_PKG;

 

/
