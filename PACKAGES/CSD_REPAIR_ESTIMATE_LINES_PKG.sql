--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ESTIMATE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ESTIMATE_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: csdtetls.pls 115.6 2003/08/29 21:58:10 swai noship $ */

-- travi forward port Bug # 2789754 fix added override_charge_flag
PROCEDURE Insert_Row(
          px_REPAIR_ESTIMATE_LINE_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_ESTIMATE_ID    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_ITEM_COST    NUMBER
         ,p_JUSTIFICATION_NOTES    VARCHAR2
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
         ,p_ESTIMATE_DETAIL_ID    NUMBER
         ,p_RESOURCE_ID    NUMBER
	     ,p_OVERRIDE_CHARGE_FLAG VARCHAR2
         ,p_EST_LINE_SOURCE_TYPE_CODE VARCHAR2
         ,p_EST_LINE_SOURCE_ID1 NUMBER
         ,p_EST_LINE_SOURCE_ID2 NUMBER
         ,p_RO_SERVICE_CODE_ID NUMBER
         );

-- travi forward port Bug # 2789754 fix added override_charge_flag
PROCEDURE Update_Row(
          p_REPAIR_ESTIMATE_LINE_ID    NUMBER
         ,p_REPAIR_ESTIMATE_ID    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_ITEM_COST    NUMBER
         ,p_JUSTIFICATION_NOTES    VARCHAR2
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
         ,p_ESTIMATE_DETAIL_ID    NUMBER
         ,p_RESOURCE_ID    NUMBER
	     ,p_OVERRIDE_CHARGE_FLAG VARCHAR2
         ,p_EST_LINE_SOURCE_TYPE_CODE VARCHAR2
         ,p_EST_LINE_SOURCE_ID1 NUMBER
         ,p_EST_LINE_SOURCE_ID2 NUMBER
         ,p_RO_SERVICE_CODE_ID NUMBER
        );

PROCEDURE Lock_Row(
          p_REPAIR_ESTIMATE_LINE_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_REPAIR_ESTIMATE_LINE_ID  NUMBER);
End CSD_REPAIR_ESTIMATE_LINES_PKG;

 

/
