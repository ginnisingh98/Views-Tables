--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ACTUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ACTUALS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtacts.pls 120.2 2008/02/09 01:06:13 takwong ship $ csdtacts.pls */

PROCEDURE Insert_Row(
          px_REPAIR_ACTUAL_ID   IN OUT NOCOPY NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
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
         ,p_BILL_TO_ACCOUNT_ID  NUMBER := null
         ,p_BILL_TO_PARTY_ID    NUMBER := null
         ,p_BILL_TO_PARTY_SITE_ID   NUMBER := null
         );

PROCEDURE Update_Row(
          p_REPAIR_ACTUAL_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
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
         ,p_BILL_TO_ACCOUNT_ID  NUMBER := null
         ,p_BILL_TO_PARTY_ID    NUMBER := null
         ,p_BILL_TO_PARTY_SITE_ID   NUMBER := null
         );

PROCEDURE Lock_Row(
          p_REPAIR_ACTUAL_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
          p_REPAIR_ACTUAL_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

End CSD_REPAIR_ACTUALS_PKG;

/
