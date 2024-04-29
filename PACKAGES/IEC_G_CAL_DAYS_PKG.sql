--------------------------------------------------------
--  DDL for Package IEC_G_CAL_DAYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_G_CAL_DAYS_PKG" AUTHID CURRENT_USER as
/* $Header: IECCDAYS.pls 115.6 2003/08/22 20:41:20 hhuang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2
);

procedure UPDATE_ROW (
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_DAY_ID in NUMBER
);

procedure ADD_LANGUAGE;

procedure LOAD_ROW (
  X_DAY_ID in NUMBER,
  X_CALENDAR_ID in NUMBER,
  X_DAY_CODE in VARCHAR2,
  X_PATTERN_CODE in VARCHAR2,
  X_EXCEPTION_MONTH in VARCHAR2,
  X_EXCEPTION_DAY in VARCHAR2,
  X_EXCEPTION_YEAR in VARCHAR2,
  X_EXCEPTION_WEEKDAY_CODE in VARCHAR2,
  X_DAY_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_DAY_ID in NUMBER,
  X_DAY_NAME in VARCHAR2,
  X_OWNER in VARCHAR2
);

end IEC_G_CAL_DAYS_PKG;

 

/
