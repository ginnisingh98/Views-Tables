--------------------------------------------------------
--  DDL for Package AML_MONITOR_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_MONITOR_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: amltlmls.pls 115.3 2003/01/20 18:24:27 swkhanna ship $ */
-- Start of Comments
-- Package name     : aml_MONITOR_LOG_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MONITOR_LOG_ID   IN OUT NOCOPY NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_MONITOR_CONDITION_ID    NUMBER
         ,p_RECIPIENT_ROLE    VARCHAR2
         ,P_MONITOR_ACTION    VARCHAR2
         ,p_RECIPIENT_RESOURCE_ID    NUMBER
         ,p_SALES_LEAD_ID    NUMBER
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
);
PROCEDURE Update_Row(
          p_MONITOR_LOG_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_MONITOR_CONDITION_ID    NUMBER
         ,p_RECIPIENT_ROLE    VARCHAR2
         ,P_MONITOR_ACTION    VARCHAR2
         ,p_RECIPIENT_RESOURCE_ID    NUMBER
         ,p_SALES_LEAD_ID    NUMBER
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
);
PROCEDURE Lock_Row(
          p_MONITOR_LOG_ID    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REQUEST_ID    NUMBER
         ,p_PROGRAM_APPLICATION_ID    NUMBER
         ,p_PROGRAM_ID    NUMBER
         ,p_PROGRAM_UPDATE_DATE    DATE
         ,p_MONITOR_CONDITION_ID    NUMBER
         ,p_RECIPIENT_ROLE    VARCHAR2
         ,P_MONITOR_ACTION    VARCHAR2
         ,p_RECIPIENT_RESOURCE_ID    NUMBER
         ,p_SALES_LEAD_ID    NUMBER
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
);
PROCEDURE Delete_Row(
    p_MONITOR_LOG_ID  NUMBER);
End aml_MONITOR_LOG_PKG;

 

/
