--------------------------------------------------------
--  DDL for Package AS_FORECAST_PROB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FORECAST_PROB_PKG" AUTHID CURRENT_USER as
/* #$Header: asxtfpbs.pls 120.1 2005/06/05 22:53:06 appldev  $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
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
  X_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
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
  X_MEANING in VARCHAR2
);
procedure UPDATE_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
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
  X_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_PROBABILITY_VALUE in NUMBER
);

procedure LOAD_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_USAGE_INDICATOR in VARCHAR2,
  X_INTERNAL_UPGRADE_PROB_VALUE in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LEAD_STATUS_CHANGE_CODE in VARCHAR2,
  X_END_DATE_ACTIVE in DATE,
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
  X_MEANING in VARCHAR2,
  X_OWNER   in VARCHAR2
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_PROBABILITY_VALUE in NUMBER,
  X_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2);

end AS_FORECAST_PROB_PKG;

 

/