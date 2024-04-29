--------------------------------------------------------
--  DDL for Package ZX_JURISDICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_JURISDICTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: zxcjurisdictions.pls 120.6 2005/06/24 12:33:42 shmangal ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_JURISDICTION_ID in NUMBER,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_ZONE_GEOGRAPHY_ID in NUMBER,
  X_TAX in VARCHAR2,
  X_Default_Jurisdiction_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID      in NUMBER,
  X_Program_Login_Id in NUMBER,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TAX_JURISDICTION_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_INNER_CITY_JURISDICTION_FLAG in VARCHAR2,
  X_PRECEDENCE_LEVEL in NUMBER,
  X_ALLOW_TAX_REGISTRATIONS_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAX_ACCT_SRC_JURISDICT_ID in NUMBER,
  X_TAX_EXMPT_SRC_JURISDICT_ID in NUMBER
);

procedure LOCK_ROW (
  X_TAX_JURISDICTION_ID in NUMBER,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_ZONE_GEOGRAPHY_ID in NUMBER,
  X_TAX in VARCHAR2,
  X_Default_Jurisdiction_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID      in NUMBER,
  X_Program_Login_Id in NUMBER,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TAX_JURISDICTION_NAME in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_INNER_CITY_JURISDICTION_FLAG in VARCHAR2,
  X_PRECEDENCE_LEVEL in NUMBER,
  X_ALLOW_TAX_REGISTRATIONS_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAX_ACCT_SRC_JURISDICT_ID in NUMBER,
  X_TAX_EXMPT_SRC_JURISDICT_ID in NUMBER
);
procedure UPDATE_ROW (
  X_TAX_JURISDICTION_ID in NUMBER,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_ZONE_GEOGRAPHY_ID in NUMBER,
  X_TAX in VARCHAR2,
  X_Default_Jurisdiction_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID      in NUMBER,
  X_Program_Login_Id in NUMBER,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TAX_JURISDICTION_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_INNER_CITY_JURISDICTION_FLAG in VARCHAR2,
  X_PRECEDENCE_LEVEL in NUMBER,
  X_ALLOW_TAX_REGISTRATIONS_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TAX_ACCT_SRC_JURISDICT_ID in NUMBER,
  X_TAX_EXMPT_SRC_JURISDICT_ID in NUMBER
);

procedure DELETE_ROW (
  X_TAX_JURISDICTION_ID in NUMBER
);

procedure ADD_LANGUAGE;
end ZX_JURISDICTIONS_PKG;

 

/
