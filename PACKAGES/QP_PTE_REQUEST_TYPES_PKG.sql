--------------------------------------------------------
--  DDL for Package QP_PTE_REQUEST_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PTE_REQUEST_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: QPXREQUS.pls 120.1 2005/06/09 03:02:37 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_REQUEST_TYPE_CODE in VARCHAR2,
  X_ORDER_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_LINE_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_ORDER_LEVEL_VIEW_NAME in VARCHAR2,
  X_LINE_LEVEL_VIEW_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PTE_CODE in VARCHAR2,
  X_REQUEST_TYPE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_REQUEST_TYPE_CODE in VARCHAR2,
  X_ORDER_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_LINE_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_ORDER_LEVEL_VIEW_NAME in VARCHAR2,
  X_LINE_LEVEL_VIEW_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PTE_CODE in VARCHAR2,
  X_REQUEST_TYPE_DESC in VARCHAR2
);
procedure UPDATE_ROW (
  X_REQUEST_TYPE_CODE in VARCHAR2,
  X_ORDER_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_LINE_LEVEL_GLOBAL_STRUCT in VARCHAR2,
  X_ORDER_LEVEL_VIEW_NAME in VARCHAR2,
  X_LINE_LEVEL_VIEW_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CONTEXT in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_PTE_CODE in VARCHAR2,
  X_REQUEST_TYPE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_REQUEST_TYPE_CODE in VARCHAR2
);
procedure ADD_LANGUAGE;
end QP_PTE_REQUEST_TYPES_PKG;

 

/