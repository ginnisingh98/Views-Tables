--------------------------------------------------------
--  DDL for Package CSP_SUPERSEDE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SUPERSEDE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: csptsups.pls 115.3 2002/11/26 07:05:14 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_SUPERSEDE_ITEMS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_SUPERSEDE_ID   IN OUT NOCOPY NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_ORGANIZATION_ID    NUMBER
         ,p_SUB_INVENTORY_CODE    VARCHAR2
         ,p_ITEM_SUPPLIED    NUMBER
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Update_Row(
          p_SUPERSEDE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_ORGANIZATION_ID    NUMBER
         ,p_SUB_INVENTORY_CODE    VARCHAR2
         ,p_ITEM_SUPPLIED    NUMBER
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Lock_Row(
          p_SUPERSEDE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_ORGANIZATION_ID    NUMBER
         ,p_SUB_INVENTORY_CODE    VARCHAR2
         ,p_ITEM_SUPPLIED    NUMBER
         ,p_ATTRIBUTE_CATEGORY    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2);

PROCEDURE Delete_Row(
    p_SUPERSEDE_ID  NUMBER);
End CSP_SUPERSEDE_ITEMS_PKG;

 

/
