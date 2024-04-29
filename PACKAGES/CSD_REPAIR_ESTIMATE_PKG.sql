--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ESTIMATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ESTIMATE_PKG" AUTHID CURRENT_USER as
/* $Header: csdtests.pls 120.1 2006/06/15 18:16:41 mshirkol noship $ */
-- Start of Comments
-- Package name     : CSD_REPAIR_ESTIMATE_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_REPAIR_ESTIMATE_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_ESTIMATE_STATUS    VARCHAR2
         ,p_ESTIMATE_DATE    DATE
         ,p_WORK_SUMMARY    VARCHAR2
         ,p_PO_NUMBER    VARCHAR2
         ,p_LEAD_TIME    NUMBER
         ,p_LEAD_TIME_UOM    VARCHAR2
         ,p_NOT_TO_EXCEED    NUMBER  -- R12 Bug#5334454
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
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
         ,p_ESTIMATE_FREEZE_FLAG    VARCHAR2
         ,p_ESTIMATE_REASON_CODE    VARCHAR2);

PROCEDURE Update_Row(
          p_REPAIR_ESTIMATE_ID    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
         ,p_ESTIMATE_STATUS    VARCHAR2
         ,p_ESTIMATE_DATE    DATE
         ,p_WORK_SUMMARY    VARCHAR2
         ,p_PO_NUMBER    VARCHAR2
         ,p_LEAD_TIME    NUMBER
         ,p_LEAD_TIME_UOM    VARCHAR2
         ,p_NOT_TO_EXCEED    NUMBER  -- R12 Bug#5334454
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
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
         ,p_ESTIMATE_FREEZE_FLAG    VARCHAR2
         ,p_ESTIMATE_REASON_CODE    VARCHAR2);

PROCEDURE Lock_Row(
          p_REPAIR_ESTIMATE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_REPAIR_ESTIMATE_ID  NUMBER);
End CSD_REPAIR_ESTIMATE_PKG;
 

/
