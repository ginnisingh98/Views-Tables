--------------------------------------------------------
--  DDL for Package AHL_PRD_DISPOSITIONS_B_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_DISPOSITIONS_B_H_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLDSHS.pls 120.0 2005/05/26 00:19:27 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DISPOSITION_H_ID in NUMBER,
  X_DISPOSITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKORDER_ID in NUMBER,
  X_PART_CHANGE_ID in NUMBER,
  X_PATH_POSITION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ITEM_GROUP_ID in NUMBER,
  X_CONDITION_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SERIAL_NUMBER in VARCHAR2,
  X_LOT_NUMBER in VARCHAR2,
  X_IMMEDIATE_DISPOSITION_CODE in VARCHAR2,
  X_SECONDARY_DISPOSITION_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UOM in VARCHAR2,
  X_COLLECTION_ID in NUMBER,
  X_PRIMARY_SERVICE_REQUEST_ID in NUMBER,
  X_NON_ROUTINE_WORKORDER_ID in NUMBER,
  X_WO_OPERATION_ID in NUMBER,
  X_ITEM_REVISION in VARCHAR2,
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
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_DISPOSITION_H_ID in NUMBER,
  X_DISPOSITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKORDER_ID in NUMBER,
  X_PART_CHANGE_ID in NUMBER,
  X_PATH_POSITION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ITEM_GROUP_ID in NUMBER,
  X_CONDITION_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SERIAL_NUMBER in VARCHAR2,
  X_LOT_NUMBER in VARCHAR2,
  X_IMMEDIATE_DISPOSITION_CODE in VARCHAR2,
  X_SECONDARY_DISPOSITION_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UOM in VARCHAR2,
  X_COLLECTION_ID in NUMBER,
  X_PRIMARY_SERVICE_REQUEST_ID in NUMBER,
  X_NON_ROUTINE_WORKORDER_ID in NUMBER,
  X_WO_OPERATION_ID in NUMBER,
  X_ITEM_REVISION in VARCHAR2,
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
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_DISPOSITION_H_ID in NUMBER,
  X_DISPOSITION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_WORKORDER_ID in NUMBER,
  X_PART_CHANGE_ID in NUMBER,
  X_PATH_POSITION_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ITEM_GROUP_ID in NUMBER,
  X_CONDITION_ID in NUMBER,
  X_INSTANCE_ID in NUMBER,
  X_SERIAL_NUMBER in VARCHAR2,
  X_LOT_NUMBER in VARCHAR2,
  X_IMMEDIATE_DISPOSITION_CODE in VARCHAR2,
  X_SECONDARY_DISPOSITION_CODE in VARCHAR2,
  X_STATUS_CODE in VARCHAR2,
  X_QUANTITY in NUMBER,
  X_UOM in VARCHAR2,
  X_COLLECTION_ID in NUMBER,
  X_PRIMARY_SERVICE_REQUEST_ID in NUMBER,
  X_NON_ROUTINE_WORKORDER_ID in NUMBER,
  X_WO_OPERATION_ID in NUMBER,
  X_ITEM_REVISION in VARCHAR2,
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
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_DISPOSITION_H_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AHL_PRD_DISPOSITIONS_B_H_PKG;

 

/
