--------------------------------------------------------
--  DDL for Package PA_ACCUM_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACCUM_COLUMNS_PKG" AUTHID CURRENT_USER as
/* $Header: PAREPACS.pls 115.4 99/08/19 17:43:45 porting shi $ */
procedure INSERT_ROW (
  X_PROJECT_TYPE_CLASS_CODE  in VARCHAR2,
  X_COLUMN_ID                in NUMBER,
  X_ACCUM_CATEGORY_CODE      in VARCHAR2,
  X_ACCUM_COLUMN_CODE        in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_ACCUM_FLAG               in VARCHAR2,
  X_CREATION_DATE            in DATE,
  X_CREATED_BY               in NUMBER,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER);
procedure TRANSLATE_ROW (
  X_COLUMN_ID                IN NUMBER,
  X_OWNER                    IN VARCHAR2,
  X_DESCRIPTION              IN VARCHAR2);
procedure UPDATE_ROW (
  X_PROJECT_TYPE_CLASS_CODE  in VARCHAR2,
  X_COLUMN_ID                in NUMBER,
  X_ACCUM_COLUMN_CODE        in VARCHAR2,
  X_ACCUM_CATEGORY_CODE      in VARCHAR2,
  X_ACCUM_FLAG               in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_LAST_UPDATE_DATE         in DATE,
  X_LAST_UPDATED_BY          in NUMBER,
  X_LAST_UPDATE_LOGIN        in NUMBER
);
end PA_ACCUM_COLUMNS_PKG;

 

/
