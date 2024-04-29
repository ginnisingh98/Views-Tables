--------------------------------------------------------
--  DDL for Package AHL_SCHEDULE_MATERIALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_SCHEDULE_MATERIALS_PKG" AUTHID CURRENT_USER as
/* $Header: AHLLSMTS.pls 115.0 2003/12/18 00:10:49 ssurapan noship $ */
PROCEDURE INSERT_ROW (
 X_SCHEDULED_MATERIAL_ID  IN  NUMBER,
 X_OBJECT_VERSION_NUMBER  IN NUMBER,
 X_LAST_UPDATE_DATE       IN DATE,
 X_LAST_UPDATED_BY        IN NUMBER,
 X_CREATION_DATE          IN DATE,
 X_CREATED_BY             IN NUMBER,
 X_LAST_UPDATE_LOGIN      IN NUMBER,
 X_INVENTORY_ITEM_ID      IN NUMBER,
 X_SCHEDULE_DESIGNATOR    IN VARCHAR2,
 X_VISIT_ID               IN NUMBER,
 X_VISIT_START_DATE       IN DATE,
 X_VISIT_TASK_ID          IN NUMBER,
 X_ORGANIZATION_ID        IN NUMBER,
 X_SCHEDULED_DATE         IN DATE,
 X_REQUEST_ID             IN NUMBER,
 X_REQUESTED_DATE         IN DATE,
 X_SCHEDULED_QUANTITY     IN NUMBER,
 X_PROCESS_STATUS         IN NUMBER,
 X_ERROR_MESSAGE          IN VARCHAR2,
 X_TRANSACTION_ID         IN NUMBER,
 X_UOM                    IN VARCHAR2,
 X_RT_OPER_MATERIAL_ID    IN NUMBER,
 X_OPERATION_CODE         IN VARCHAR2,
 X_OPERATION_SEQUENCE     IN NUMBER,
 X_ITEM_GROUP_ID          IN NUMBER,
 X_REQUESTED_QUANTITY     IN NUMBER,
 X_PROGRAM_ID             IN NUMBER,
 X_PROGRAM_UPDATE_DATE    IN DATE,
 X_LAST_UPDATED_DATE      IN DATE,
 X_WORKORDER_OPERATION_ID IN NUMBER,
 X_POSITION_PATH_ID       IN NUMBER,
 X_RELATIONSHIP_ID        IN NUMBER,
 X_UNIT_EFFECTIVITY_ID    IN NUMBER,
 X_MR_ROUTE_ID            IN NUMBER,
 X_MATERIAL_REQUEST_TYPE  IN VARCHAR2,
 X_ATTRIBUTE_CATEGORY     IN VARCHAR2,
 X_ATTRIBUTE1             IN VARCHAR2,
 X_ATTRIBUTE2             IN VARCHAR2,
 X_ATTRIBUTE3             IN VARCHAR2,
 X_ATTRIBUTE4             IN VARCHAR2,
 X_ATTRIBUTE5             IN VARCHAR2,
 X_ATTRIBUTE6             IN VARCHAR2,
 X_ATTRIBUTE7             IN VARCHAR2,
 X_ATTRIBUTE8             IN VARCHAR2,
 X_ATTRIBUTE9             IN VARCHAR2,
 X_ATTRIBUTE10            IN VARCHAR2,
 X_ATTRIBUTE11            IN VARCHAR2,
 X_ATTRIBUTE12            IN VARCHAR2,
 X_ATTRIBUTE13            IN VARCHAR2,
 X_ATTRIBUTE14            IN VARCHAR2,
 X_ATTRIBUTE15            IN VARCHAR2
 );

PROCEDURE UPDATE_ROW (
 X_SCHEDULED_MATERIAL_ID  IN  NUMBER,
 X_OBJECT_VERSION_NUMBER  IN NUMBER,
 X_LAST_UPDATE_DATE       IN DATE,
 X_LAST_UPDATED_BY        IN NUMBER,
 --X_CREATION_DATE          IN DATE,
 --X_CREATED_BY             IN NUMBER,
 X_LAST_UPDATE_LOGIN      IN NUMBER,
 X_INVENTORY_ITEM_ID      IN NUMBER,
 X_SCHEDULE_DESIGNATOR    IN VARCHAR2,
 X_VISIT_ID               IN NUMBER,
 X_VISIT_START_DATE       IN DATE,
 X_VISIT_TASK_ID          IN NUMBER,
 X_ORGANIZATION_ID        IN NUMBER,
 X_SCHEDULED_DATE         IN DATE,
 X_REQUEST_ID             IN NUMBER,
 X_REQUESTED_DATE         IN DATE,
 X_SCHEDULED_QUANTITY     IN NUMBER,
 X_PROCESS_STATUS         IN NUMBER,
 X_ERROR_MESSAGE          IN VARCHAR2,
 X_TRANSACTION_ID         IN NUMBER,
 X_UOM                    IN VARCHAR2,
 X_RT_OPER_MATERIAL_ID    IN NUMBER,
 X_OPERATION_CODE         IN VARCHAR2,
 X_OPERATION_SEQUENCE     IN NUMBER,
 X_ITEM_GROUP_ID          IN NUMBER,
 X_REQUESTED_QUANTITY     IN NUMBER,
 X_PROGRAM_ID             IN NUMBER,
 X_PROGRAM_UPDATE_DATE    IN DATE,
 X_LAST_UPDATED_DATE      IN DATE,
 X_WORKORDER_OPERATION_ID IN NUMBER,
 X_POSITION_PATH_ID       IN NUMBER,
 X_RELATIONSHIP_ID        IN NUMBER,
 X_UNIT_EFFECTIVITY_ID    IN NUMBER,
 X_MR_ROUTE_ID            IN NUMBER,
 X_MATERIAL_REQUEST_TYPE  IN VARCHAR2,
 X_ATTRIBUTE_CATEGORY     IN VARCHAR2,
 X_ATTRIBUTE1             IN VARCHAR2,
 X_ATTRIBUTE2             IN VARCHAR2,
 X_ATTRIBUTE3             IN VARCHAR2,
 X_ATTRIBUTE4             IN VARCHAR2,
 X_ATTRIBUTE5             IN VARCHAR2,
 X_ATTRIBUTE6             IN VARCHAR2,
 X_ATTRIBUTE7             IN VARCHAR2,
 X_ATTRIBUTE8             IN VARCHAR2,
 X_ATTRIBUTE9             IN VARCHAR2,
 X_ATTRIBUTE10            IN VARCHAR2,
 X_ATTRIBUTE11            IN VARCHAR2,
 X_ATTRIBUTE12            IN VARCHAR2,
 X_ATTRIBUTE13            IN VARCHAR2,
 X_ATTRIBUTE14            IN VARCHAR2,
 X_ATTRIBUTE15            IN VARCHAR2

 );

 PROCEDURE DELETE_ROW (
  X_SCHEDULED_MATERIAL_ID in NUMBER
);

END AHL_SCHEDULE_MATERIALS_PKG;

 

/