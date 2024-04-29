--------------------------------------------------------
--  DDL for Package CSP_SEC_INVENTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SEC_INVENTORIES_PKG" AUTHID CURRENT_USER as
/* $Header: csptpses.pls 120.0 2005/05/25 11:37:24 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_SEC_INVENTORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_SECONDARY_INVENTORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Update_Row(
          p_SECONDARY_INVENTORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Lock_Row(
          p_SECONDARY_INVENTORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Delete_Row(
    p_SECONDARY_INVENTORY_ID  NUMBER);
End CSP_SEC_INVENTORIES_PKG;

 

/
