--------------------------------------------------------
--  DDL for Package ZX_RECOVERY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_RECOVERY_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: zxdrectypess.pls 120.2 2005/10/27 17:01:10 pla ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RECOVERY_TYPE_ID in NUMBER,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_Enabled_Flag in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_RECOVERY_TYPE_NAME in VARCHAR2,
  X_RECOVERY_TYPE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_RECOVERY_TYPE_ID in NUMBER,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_Enabled_Flag in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_RECOVERY_TYPE_NAME in VARCHAR2,
  X_RECOVERY_TYPE_DESC in VARCHAR2
);
procedure UPDATE_ROW (
  X_RECOVERY_TYPE_ID in NUMBER,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_Enabled_Flag in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_RECOVERY_TYPE_NAME in VARCHAR2,
  X_RECOVERY_TYPE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_RECOVERY_TYPE_ID in NUMBER
);
procedure ADD_LANGUAGE;
end ZX_RECOVERY_TYPES_PKG;


 

/