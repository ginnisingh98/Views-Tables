--------------------------------------------------------
--  DDL for Package CS_SR_RES_CODE_MAP_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_RES_CODE_MAP_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: csrcmpds.pls 120.0 2006/03/01 17:40:51 aseethep noship $ */

procedure INSERT_ROW (
  PX_RESOLUTION_MAP_DETAIL_ID IN OUT NOCOPY  NUMBER,
  P_RESOLUTION_MAP_ID in NUMBER,
  P_INCIDENT_TYPE_ID in NUMBER,
  P_INVENTORY_ITEM_ID in NUMBER,
  P_ORGANIZATION_ID in NUMBER,
  P_CATEGORY_ID in NUMBER,
  P_PROBLEM_CODE in VARCHAR2,
  P_MAP_START_DATE_ACTIVE in DATE,
  P_MAP_END_DATE_ACTIVE in DATE,
  P_RESOLUTION_CODE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
  X_MSG_COUNT		OUT NOCOPY   NUMBER,
  X_MSG_DATA		OUT NOCOPY   VARCHAR2
  );

procedure LOCK_ROW (
  P_RESOLUTION_MAP_DETAIL_ID in NUMBER,
  P_RESOLUTION_MAP_ID in NUMBER,
  P_INCIDENT_TYPE_ID in NUMBER,
  P_INVENTORY_ITEM_ID in NUMBER,
  P_ORGANIZATION_ID in NUMBER,
  P_CATEGORY_ID in NUMBER,
  P_PROBLEM_CODE in VARCHAR2,
  P_MAP_START_DATE_ACTIVE in DATE,
  P_MAP_END_DATE_ACTIVE in DATE,
  P_RESOLUTION_CODE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE_CATEGORY in VARCHAR2
);

procedure UPDATE_ROW (
  P_RESOLUTION_MAP_DETAIL_ID in NUMBER,
  P_RESOLUTION_MAP_ID in NUMBER,
  P_INCIDENT_TYPE_ID in NUMBER,
  P_INVENTORY_ITEM_ID in NUMBER,
  P_ORGANIZATION_ID in NUMBER,
  P_CATEGORY_ID in NUMBER,
  P_PROBLEM_CODE in VARCHAR2,
  P_MAP_START_DATE_ACTIVE in DATE,
  P_MAP_END_DATE_ACTIVE in DATE,
  P_RESOLUTION_CODE in VARCHAR2,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
  X_MSG_COUNT		OUT NOCOPY   NUMBER,
  X_MSG_DATA		OUT NOCOPY   VARCHAR2
);

procedure DELETE_ROW (
  P_RESOLUTION_MAP_DETAIL_ID in NUMBER
);

end CS_SR_RES_CODE_MAP_DETAIL_PKG;

 

/
