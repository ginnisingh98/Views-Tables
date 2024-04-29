--------------------------------------------------------
--  DDL for Package CSD_RO_SERVICE_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RO_SERVICE_CODES_PKG" AUTHID CURRENT_USER as
/* $Header: csdtrscs.pls 120.1 2006/09/19 23:09:55 rfieldma noship $ */
-- Start of Comments
-- Package name     : CSD_RO_SERVICE_CODES_PKG
-- Purpose          : To insert, update, delete and lock ro service code
-- History          : 21-Aug-2003    Gilam          created
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_RO_SERVICE_CODE_ID   IN OUT NOCOPY NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_SOURCE_TYPE_CODE    VARCHAR2
         ,p_SOURCE_SOLUTION_ID    NUMBER
         ,p_APPLICABLE_FLAG    VARCHAR2
         ,p_APPLIED_TO_EST_FLAG    VARCHAR2
         ,p_APPLIED_TO_WORK_FLAG    VARCHAR2
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
	    ,p_SERVICE_ITEM_ID	NUMBER -- rfieldma, 4666403
	    );

PROCEDURE Update_Row(
          p_RO_SERVICE_CODE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_SOURCE_TYPE_CODE    VARCHAR2
         ,p_SOURCE_SOLUTION_ID    NUMBER
         ,p_APPLICABLE_FLAG    VARCHAR2
         ,p_APPLIED_TO_EST_FLAG    VARCHAR2
         ,p_APPLIED_TO_WORK_FLAG    VARCHAR2
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
	    ,p_SERVICE_ITEM_ID	NUMBER -- rfieldma, 4666403
	    );

PROCEDURE Lock_Row(
          p_RO_SERVICE_CODE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER

         --commented out the rest of the record
         /*
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_SERVICE_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_SOURCE_TYPE_CODE    VARCHAR2
         ,p_SOURCE_SOLUTION_ID    NUMBER
         ,p_APPLICABLE_FLAG    VARCHAR2
         ,p_APPLIED_TO_EST_FLAG    VARCHAR2
         ,p_APPLIED_TO_WORK_FLAG    VARCHAR2
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
    p_RO_SERVICE_CODE_ID  NUMBER);
End CSD_RO_SERVICE_CODES_PKG;
 

/
