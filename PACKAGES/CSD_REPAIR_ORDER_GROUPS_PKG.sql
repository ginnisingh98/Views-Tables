--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ORDER_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ORDER_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtgrgs.pls 115.6 2002/12/02 23:41:34 takwong noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_ORDER_GROUPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPAIR_GROUP_ID   IN OUT NOCOPY NUMBER
         ,p_INCIDENT_ID    NUMBER
         ,p_REPAIR_GROUP_NUMBER    VARCHAR2
         ,p_REPAIR_TYPE_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_UNIT_OF_MEASURE    VARCHAR2
         ,p_GROUP_QUANTITY    NUMBER
         ,p_REPAIR_ORDER_QUANTITY    NUMBER
         ,p_RMA_QUANTITY    NUMBER
         ,p_RECEIVED_QUANTITY    NUMBER
         ,p_APPROVED_QUANTITY    NUMBER
         ,p_SUBMITTED_QUANTITY    NUMBER
         ,p_COMPLETED_QUANTITY    NUMBER
         ,p_RELEASED_QUANTITY    NUMBER
         ,p_SHIPPED_QUANTITY    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CONTEXT    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_GROUP_TXN_STATUS    VARCHAR2
         ,p_WIP_ENTITY_ID    NUMBER
        ,p_GROUP_APPROVAL_STATUS  VARCHAR2
        ,p_REPAIR_MODE  VARCHAR2);

PROCEDURE Update_Row(
          p_REPAIR_GROUP_ID    NUMBER
         ,p_INCIDENT_ID    NUMBER
         ,p_REPAIR_GROUP_NUMBER    VARCHAR2
         ,p_REPAIR_TYPE_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_UNIT_OF_MEASURE    VARCHAR2
         ,p_GROUP_QUANTITY    NUMBER
         ,p_REPAIR_ORDER_QUANTITY    NUMBER
         ,p_RMA_QUANTITY    NUMBER
         ,p_RECEIVED_QUANTITY    NUMBER
         ,p_APPROVED_QUANTITY    NUMBER
         ,p_SUBMITTED_QUANTITY    NUMBER
         ,p_COMPLETED_QUANTITY    NUMBER
         ,p_RELEASED_QUANTITY    NUMBER
         ,p_SHIPPED_QUANTITY    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_CONTEXT    VARCHAR2
         ,p_ATTRIBUTE1    VARCHAR2
         ,p_ATTRIBUTE2    VARCHAR2
         ,p_ATTRIBUTE3    VARCHAR2
         ,p_ATTRIBUTE4    VARCHAR2
         ,p_ATTRIBUTE5    VARCHAR2
         ,p_ATTRIBUTE6    VARCHAR2
         ,p_ATTRIBUTE7    VARCHAR2
         ,p_ATTRIBUTE8    VARCHAR2
         ,p_ATTRIBUTE9    VARCHAR2
         ,p_ATTRIBUTE10    VARCHAR2
         ,p_ATTRIBUTE11    VARCHAR2
         ,p_ATTRIBUTE12    VARCHAR2
         ,p_ATTRIBUTE13    VARCHAR2
         ,p_ATTRIBUTE14    VARCHAR2
         ,p_ATTRIBUTE15    VARCHAR2
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_GROUP_TXN_STATUS    VARCHAR2
         ,p_WIP_ENTITY_ID    NUMBER
        ,p_GROUP_APPROVAL_STATUS  VARCHAR2
        ,p_REPAIR_MODE  VARCHAR2);

PROCEDURE Lock_Row(
          p_REPAIR_GROUP_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_REPAIR_GROUP_ID  NUMBER);
End CSD_REPAIR_ORDER_GROUPS_PKG;

 

/
