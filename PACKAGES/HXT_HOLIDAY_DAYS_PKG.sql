--------------------------------------------------------
--  DDL for Package HXT_HOLIDAY_DAYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HOLIDAY_DAYS_PKG" AUTHID CURRENT_USER as
/* $Header: hxthddml.pkh 120.1 2005/10/07 02:30:01 nissharm noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
--
procedure LOCK_ROW (
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2);
--
procedure UPDATE_ROW (
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
--
procedure DELETE_ROW (
  X_ID in NUMBER);
--
procedure ADD_LANGUAGE;

end HXT_HOLIDAY_DAYS_PKG;

 

/
