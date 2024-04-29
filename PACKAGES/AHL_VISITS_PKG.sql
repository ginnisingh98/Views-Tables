--------------------------------------------------------
--  DDL for Package AHL_VISITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VISITS_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLVSTS.pls 120.1 2007/12/18 09:58:13 sowsubra ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_VISIT_ID in NUMBER,
  X_ESTIMATED_PRICE in NUMBER,
  X_PRIORITY_CODE in VARCHAR2,
  X_PROJECT_TEMPLATE_ID in NUMBER,
  X_UNIT_SCHEDULE_ID in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_OUTSIDE_PARTY_FLAG in VARCHAR2,
  X_ANY_TASK_CHG_FLAG in VARCHAR2,
  X_PRICE_LIST_ID in NUMBER,
  X_CLOSE_DATE_TIME in DATE,
  X_SCHEDULE_DESIGNATOR in VARCHAR2,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_SPACE_CATEGORY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_START_DATE_TIME in DATE,
  X_VISIT_TYPE_CODE in VARCHAR2,
  X_SIMULATION_PLAN_ID in NUMBER,
  X_ITEM_INSTANCE_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ASSO_PRIMARY_VISIT_ID in NUMBER,
  X_SIMULATION_DELETE_FLAG in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_OUT_OF_SYNC_FLAG in VARCHAR2,
  X_PROJECT_FLAG in VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_VISIT_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
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
  X_VISIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INV_LOCATOR_ID in NUMBER,  --Added by sowsubra
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_VISIT_ID in NUMBER,
  X_ESTIMATED_PRICE in NUMBER,
  X_PRIORITY_CODE in VARCHAR2,
  X_PROJECT_TEMPLATE_ID in NUMBER,
  X_UNIT_SCHEDULE_ID in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_OUTSIDE_PARTY_FLAG in VARCHAR2,
  X_ANY_TASK_CHG_FLAG in VARCHAR2,
  X_PRICE_LIST_ID in NUMBER,
  X_CLOSE_DATE_TIME in DATE,
  X_SCHEDULE_DESIGNATOR in VARCHAR2,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_SPACE_CATEGORY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_START_DATE_TIME in DATE,
  X_VISIT_TYPE_CODE in VARCHAR2,
  X_SIMULATION_PLAN_ID in NUMBER,
  X_ITEM_INSTANCE_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ASSO_PRIMARY_VISIT_ID in NUMBER,
  X_SIMULATION_DELETE_FLAG in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_OUT_OF_SYNC_FLAG in VARCHAR2,
  X_PROJECT_FLAG in VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_VISIT_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
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
  X_VISIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INV_LOCATOR_ID in NUMBER --Added by sowsubra
);
procedure UPDATE_ROW (
  X_VISIT_ID in NUMBER,
  X_ESTIMATED_PRICE in NUMBER,
  X_PRIORITY_CODE in VARCHAR2,
  X_PROJECT_TEMPLATE_ID in NUMBER,
  X_UNIT_SCHEDULE_ID in NUMBER,
  X_ACTUAL_PRICE in NUMBER,
  X_OUTSIDE_PARTY_FLAG in VARCHAR2,
  X_ANY_TASK_CHG_FLAG in VARCHAR2,
  X_PRICE_LIST_ID in NUMBER,
  X_CLOSE_DATE_TIME in DATE,
  X_SCHEDULE_DESIGNATOR in VARCHAR2,
  X_SERVICE_REQUEST_ID in NUMBER,
  X_SPACE_CATEGORY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DEPARTMENT_ID in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_START_DATE_TIME in DATE,
  X_VISIT_TYPE_CODE in VARCHAR2,
  X_SIMULATION_PLAN_ID in NUMBER,
  X_ITEM_INSTANCE_ID in NUMBER,
  X_INVENTORY_ITEM_ID in NUMBER,
  X_ASSO_PRIMARY_VISIT_ID in NUMBER,
  X_SIMULATION_DELETE_FLAG in VARCHAR2,
  X_TEMPLATE_FLAG in VARCHAR2,
  X_OUT_OF_SYNC_FLAG in VARCHAR2,
  X_PROJECT_FLAG in VARCHAR2,
  X_PROJECT_ID in NUMBER,
  X_VISIT_NUMBER in NUMBER,
  X_ITEM_ORGANIZATION_ID in NUMBER,
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
  X_VISIT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INV_LOCATOR_ID in NUMBER, --Added by sowsubra
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_VISIT_ID in NUMBER
);
procedure ADD_LANGUAGE;
end AHL_VISITS_PKG;

/