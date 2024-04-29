--------------------------------------------------------
--  DDL for Package AML_MONITOR_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_MONITOR_CONDITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: amltlmcs.pls 115.2 2002/12/13 22:43:44 swkhanna noship $ */
-- Start of Comments
-- Package name     : aml_MONITOR_CONDITIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MONITOR_CONDITION_ID   IN OUT NOCOPY NUMBER
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
         ,p_PROCESS_RULE_ID    NUMBER
         ,p_MONITOR_TYPE_CODE    VARCHAR2
         ,p_TIME_LAG_NUM    NUMBER
         ,p_TIME_LAG_UOM_CODE    VARCHAR2
         ,p_TIME_LAG_FROM_STAGE    VARCHAR2
         ,p_TIME_LAG_TO_STAGE    VARCHAR2
         ,p_Expiration_Relative       varchar2
         ,p_Reminder_Defined          varchar2
	 ,p_Total_Reminders                 number
         ,p_Reminder_Frequency              number
         ,p_Reminder_Freq_uom_code          varchar2
         ,p_Timeout_Defined                 varchar2
         ,p_Timeout_Duration                number
         ,p_Timeout_uom_code                varchar2
         ,p_notify_owner          varchar2
         ,p_notify_owner_manager  varchar2
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
          p_MONITOR_CONDITION_ID    NUMBER
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
         ,p_PROCESS_RULE_ID    NUMBER
         ,p_MONITOR_TYPE_CODE    VARCHAR2
         ,p_TIME_LAG_NUM    NUMBER
         ,p_TIME_LAG_UOM_CODE    VARCHAR2
         ,p_TIME_LAG_FROM_STAGE    VARCHAR2
         ,p_TIME_LAG_TO_STAGE    VARCHAR2
         ,p_Expiration_Relative       varchar2
         ,p_Reminder_Defined          varchar2
	 ,p_Total_Reminders                 number
         ,p_Reminder_Frequency              number
         ,p_Reminder_Freq_uom_code          varchar2
         ,p_Timeout_Defined                 varchar2
         ,p_Timeout_Duration                number
         ,p_Timeout_uom_code                varchar2
         ,p_notify_owner          varchar2
         ,p_notify_owner_manager  varchar2
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
          p_MONITOR_CONDITION_ID    NUMBER
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
         ,p_PROCESS_RULE_ID    NUMBER
         ,p_MONITOR_TYPE_CODE    VARCHAR2
         ,p_TIME_LAG_NUM    NUMBER
         ,p_TIME_LAG_UOM_CODE    VARCHAR2
         ,p_TIME_LAG_FROM_STAGE    VARCHAR2
         ,p_TIME_LAG_TO_STAGE    VARCHAR2
         ,p_Expiration_Relative       varchar2
         ,p_Reminder_Defined          varchar2
	 ,p_Total_Reminders                 number
         ,p_Reminder_Frequency              number
         ,p_Reminder_Freq_uom_code          varchar2
         ,p_Timeout_Defined                 varchar2
         ,p_Timeout_Duration                number
         ,p_Timeout_uom_code                varchar2
         ,p_notify_owner          varchar2
         ,p_notify_owner_manager  varchar2
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
    p_process_rule_id  NUMBER);
End aml_MONITOR_CONDITIONS_PKG;

 

/
