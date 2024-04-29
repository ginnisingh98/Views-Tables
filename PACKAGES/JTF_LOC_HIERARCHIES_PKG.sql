--------------------------------------------------------
--  DDL for Package JTF_LOC_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_LOC_HIERARCHIES_PKG" AUTHID CURRENT_USER as
/* $Header: jtfllohs.pls 120.2 2005/11/07 14:04:13 cmehta ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOCATION_HIERARCHY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATED_BY_APPLICATION_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AREA1_ID in NUMBER,
  X_AREA1_CODE in VARCHAR2,
  X_AREA2_ID in NUMBER,
  X_AREA2_CODE in VARCHAR2,
  X_COUNTRY_ID in NUMBER,
  X_COUNTRY_CODE in VARCHAR2,
  X_COUNTRY_REGION_ID in NUMBER,
  X_COUNTRY_REGION_CODE in VARCHAR2,
  X_STATE_ID in NUMBER,
  X_STATE_CODE in VARCHAR2,
  X_STATE_REGION_ID in NUMBER,
  X_STATE_REGION_CODE in VARCHAR2,
  X_CITY_ID in NUMBER,
  X_CITY_CODE in VARCHAR2,
  X_POSTAL_CODE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure UPDATE_ROW (
  X_LOCATION_HIERARCHY_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATED_BY_APPLICATION_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AREA1_ID in NUMBER,
  X_AREA1_CODE in VARCHAR2,
  X_AREA2_ID in NUMBER,
  X_AREA2_CODE in VARCHAR2,
  X_COUNTRY_ID in NUMBER,
  X_COUNTRY_CODE in VARCHAR2,
  X_COUNTRY_REGION_ID in NUMBER,
  X_COUNTRY_REGION_CODE in VARCHAR2,
  X_STATE_ID in NUMBER,
  X_STATE_CODE in VARCHAR2,
  X_STATE_REGION_ID in NUMBER,
  X_STATE_REGION_CODE in VARCHAR2,
  X_CITY_ID in NUMBER,
  X_CITY_CODE in VARCHAR2,
  X_POSTAL_CODE_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_LOCATION_HIERARCHY_ID in NUMBER
);

procedure  LOAD_ROW(
  X_LOCATION_HIERARCHY_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATED_BY_APPLICATION_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AREA1_ID in NUMBER,
  X_AREA1_CODE in VARCHAR2,
  X_AREA2_ID in NUMBER,
  X_AREA2_CODE in VARCHAR2,
  X_COUNTRY_ID in NUMBER,
  X_COUNTRY_CODE in VARCHAR2,
  X_COUNTRY_REGION_ID in NUMBER,
  X_COUNTRY_REGION_CODE in VARCHAR2,
  X_STATE_ID in NUMBER,
  X_STATE_CODE in VARCHAR2,
  X_STATE_REGION_ID in NUMBER,
  X_STATE_REGION_CODE in VARCHAR2,
  X_CITY_ID in NUMBER,
  X_CITY_CODE in VARCHAR2,
  X_POSTAL_CODE_ID in NUMBER,
  X_OWNER in VARCHAR2
);

end JTF_LOC_HIERARCHIES_PKG;

 

/