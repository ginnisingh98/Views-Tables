--------------------------------------------------------
--  DDL for Package CSD_SC_DOMAINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_SC_DOMAINS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtscds.pls 115.1 2003/11/05 00:17:50 gilam noship $ */
-- Start of Comments
-- Package name     : CSD_SC_DOMAINS_PKG
-- Purpose          : To insert, update, delete and lock sc domain
-- History          : 19-Aug-2003    Gilam          created
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_SC_DOMAIN_ID   IN OUT NOCOPY NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
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
          p_SC_DOMAIN_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
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
          p_SC_DOMAIN_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER

         --commented out the rest of the record
         /*
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
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
         ,p_ATTRIBUTE15    VARCHAR2
         */
         --
         );

PROCEDURE Delete_Row(
    p_SC_DOMAIN_ID  NUMBER);
End CSD_SC_DOMAINS_PKG;

 

/
