--------------------------------------------------------
--  DDL for Package Body AML_MONITOR_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_MONITOR_CONDITIONS_PKG" as
/* $Header: amltlmcb.pls 115.2 2002/12/13 22:44:06 swkhanna noship $ */
-- Start of Comments
-- Package name     : aml_MONITOR_CONDITIONS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'aml_MONITOR_CONDITIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amltlmcb.pls';

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
)
 IS
   CURSOR C2 IS SELECT aml_MONITOR_CONDITIONS_S.nextval FROM sys.dual;
BEGIN
   If (px_MONITOR_CONDITION_ID IS NULL) OR (px_MONITOR_CONDITION_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_MONITOR_CONDITION_ID;
       CLOSE C2;
   End If;
   INSERT INTO aml_MONITOR_CONDITIONS(
           MONITOR_CONDITION_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE
          ,PROCESS_RULE_ID
          ,MONITOR_TYPE_CODE
          ,TIME_LAG_NUM
          ,TIME_LAG_UOM_CODE
          ,TIME_LAG_FROM_STAGE
          ,TIME_LAG_TO_STAGE
         ,Expiration_Relative
         ,Reminder_Defined
	 ,Total_Reminders
         ,Reminder_Frequency
         ,Reminder_Freq_uom_code
         ,Timeout_Defined
         ,Timeout_Duration
         ,Timeout_uom_code
         ,notify_owner
         ,notify_owner_manager
          ,ATTRIBUTE_CATEGORY
          ,ATTRIBUTE1
          ,ATTRIBUTE2
          ,ATTRIBUTE3
          ,ATTRIBUTE4
          ,ATTRIBUTE5
          ,ATTRIBUTE6
          ,ATTRIBUTE7
          ,ATTRIBUTE8
          ,ATTRIBUTE9
          ,ATTRIBUTE10
          ,ATTRIBUTE11
          ,ATTRIBUTE12
          ,ATTRIBUTE13
          ,ATTRIBUTE14
          ,ATTRIBUTE15
          ) VALUES (
           px_MONITOR_CONDITION_ID
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,1 --decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
          ,decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID)
          ,decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID)
          ,decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID)
          ,decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE)
          ,decode( p_PROCESS_RULE_ID, FND_API.G_MISS_NUM, NULL, p_PROCESS_RULE_ID)
          ,decode( p_MONITOR_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_MONITOR_TYPE_CODE)
          ,decode( p_TIME_LAG_NUM, FND_API.G_MISS_NUM, NULL, p_TIME_LAG_NUM)
          ,decode( p_TIME_LAG_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_TIME_LAG_UOM_CODE)
          ,decode( p_TIME_LAG_FROM_STAGE, FND_API.G_MISS_CHAR, NULL, p_TIME_LAG_FROM_STAGE)
          ,decode( p_TIME_LAG_TO_STAGE, FND_API.G_MISS_CHAR, NULL, p_TIME_LAG_TO_STAGE)
         ,decode(p_Expiration_Relative, FND_API.G_MISS_CHAR, NULL, p_Expiration_Relative)
         ,decode(p_Reminder_Defined , FND_API.G_MISS_CHAR, NULL, p_Reminder_Defined)
	 ,decode(p_Total_Reminders , FND_API.G_MISS_NUM, NULL, p_Total_Reminders)
         ,decode(p_Reminder_Frequency , FND_API.G_MISS_NUM, NULL, p_Reminder_Frequency)
         ,decode(p_Reminder_Freq_uom_code, FND_API.G_MISS_CHAR, NULL, p_Reminder_Freq_uom_code)
         ,decode(p_Timeout_Defined , FND_API.G_MISS_CHAR, NULL, p_Timeout_Defined)
         ,decode(p_Timeout_Duration , FND_API.G_MISS_NUM, NULL, p_Timeout_Duration)
         ,decode(p_Timeout_uom_code, FND_API.G_MISS_CHAR, NULL, p_Timeout_uom_code)
         ,decode(p_notify_owner , FND_API.G_MISS_CHAR, NULL, p_notify_owner)
         ,decode(p_notify_owner_manager , FND_API.G_MISS_CHAR, NULL, p_notify_owner_manager)
          ,decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY)
          ,decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1)
          ,decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2)
          ,decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3)
          ,decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4)
          ,decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5)
          ,decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6)
          ,decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7)
          ,decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8)
          ,decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9)
          ,decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10)
          ,decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11)
          ,decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12)
          ,decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13)
          ,decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14)
          ,decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
);
End Insert_Row;

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
         ,p_notify_owner   varchar2
         ,p_notify_owner_manager varchar2
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
)
IS
BEGIN
    Update aml_MONITOR_CONDITIONS
    SET
        LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
       ,REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID)
       ,PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID)
       ,PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID)
       ,PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE)
       ,PROCESS_RULE_ID = decode( p_PROCESS_RULE_ID, FND_API.G_MISS_NUM, PROCESS_RULE_ID, p_PROCESS_RULE_ID)
       ,MONITOR_TYPE_CODE = decode( p_MONITOR_TYPE_CODE, FND_API.G_MISS_CHAR, MONITOR_TYPE_CODE, p_MONITOR_TYPE_CODE)
       ,TIME_LAG_NUM = decode( p_TIME_LAG_NUM, FND_API.G_MISS_NUM, TIME_LAG_NUM, p_TIME_LAG_NUM)
       ,TIME_LAG_UOM_CODE = decode( p_TIME_LAG_UOM_CODE, FND_API.G_MISS_CHAR, TIME_LAG_UOM_CODE, p_TIME_LAG_UOM_CODE)
       ,TIME_LAG_FROM_STAGE = decode( p_TIME_LAG_FROM_STAGE, FND_API.G_MISS_CHAR, TIME_LAG_FROM_STAGE, p_TIME_LAG_FROM_STAGE)
       ,TIME_LAG_TO_STAGE = decode( p_TIME_LAG_TO_STAGE, FND_API.G_MISS_CHAR, TIME_LAG_TO_STAGE, p_TIME_LAG_TO_STAGE)
         , Expiration_Relative = decode(p_Expiration_Relative, FND_API.G_MISS_CHAR, NULL, p_Expiration_Relative)
         ,Reminder_Defined = decode(p_Reminder_Defined , FND_API.G_MISS_CHAR, NULL, p_Reminder_Defined)
	 ,Total_Reminders = decode(p_Total_Reminders , FND_API.G_MISS_NUM, NULL, p_Total_Reminders)
         ,Reminder_Frequency = decode(p_Reminder_Frequency , FND_API.G_MISS_NUM, NULL, p_Reminder_Frequency)
         ,Reminder_Freq_uom_code = decode(p_Reminder_Freq_uom_code, FND_API.G_MISS_CHAR, NULL, p_Reminder_Freq_uom_code)
         ,Timeout_Defined = decode(p_Timeout_Defined , FND_API.G_MISS_CHAR, NULL, p_Timeout_Defined)
         ,Timeout_Duration = decode(p_Timeout_Duration , FND_API.G_MISS_NUM, NULL, p_Timeout_Duration)
         ,Timeout_uom_code = decode(p_Timeout_uom_code, FND_API.G_MISS_CHAR, NULL, p_Timeout_uom_code)
         ,notify_owner = decode(p_notify_owner, FND_API.G_MISS_CHAR, NULL, p_notify_owner)
         ,notify_owner_manager = decode(p_notify_owner_manager, FND_API.G_MISS_CHAR, NULL, p_notify_owner_manager)
	,ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY)
       ,ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1)
       ,ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2)
       ,ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3)
       ,ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4)
       ,ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5)
       ,ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6)
       ,ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7)
       ,ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8)
       ,ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9)
       ,ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10)
       ,ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11)
       ,ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12)
       ,ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13)
       ,ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14)
       ,ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
    where MONITOR_CONDITION_ID = p_MONITOR_CONDITION_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_process_rule_id  NUMBER)
IS
BEGIN
    DELETE FROM amL_MONITOR_CONDITIONS
    WHERE PROCESS_RULE_ID = p_process_rule_id;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

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
         ,p_notify_owner varchar2
         ,p_notify_owner_manager varchar2
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
)
 IS
   CURSOR C IS
       SELECT *
       FROM amL_MONITOR_CONDITIONS
       WHERE MONITOR_CONDITION_ID =  p_MONITOR_CONDITION_ID
       FOR UPDATE of MONITOR_CONDITION_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (      Recinfo.MONITOR_CONDITION_ID = p_MONITOR_CONDITION_ID)
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.PROCESS_RULE_ID = p_PROCESS_RULE_ID)
            OR (    ( Recinfo.PROCESS_RULE_ID IS NULL )
                AND (  p_PROCESS_RULE_ID IS NULL )))
       AND (    ( Recinfo.MONITOR_TYPE_CODE = p_MONITOR_TYPE_CODE)
            OR (    ( Recinfo.MONITOR_TYPE_CODE IS NULL )
                AND (  p_MONITOR_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.TIME_LAG_NUM = p_TIME_LAG_NUM)
            OR (    ( Recinfo.TIME_LAG_NUM IS NULL )
                AND (  p_TIME_LAG_NUM IS NULL )))
       AND (    ( Recinfo.TIME_LAG_UOM_CODE = p_TIME_LAG_UOM_CODE)
            OR (    ( Recinfo.TIME_LAG_UOM_CODE IS NULL )
                AND (  p_TIME_LAG_UOM_CODE IS NULL )))
       AND (    ( Recinfo.TIME_LAG_FROM_STAGE = p_TIME_LAG_FROM_STAGE)
            OR (    ( Recinfo.TIME_LAG_FROM_STAGE IS NULL )
                AND (  p_TIME_LAG_FROM_STAGE IS NULL )))
       AND (    ( Recinfo.TIME_LAG_TO_STAGE = p_TIME_LAG_TO_STAGE)
            OR (    ( Recinfo.TIME_LAG_TO_STAGE IS NULL )
                AND (  p_TIME_LAG_TO_STAGE IS NULL )))
       AND (    ( Recinfo.Expiration_Relative = p_Expiration_Relative)
            OR (    ( Recinfo.Expiration_Relative IS NULL )
                AND (  p_Expiration_Relative IS NULL )))
       AND (    ( Recinfo.Reminder_Defined = p_Reminder_Defined)
            OR (    ( Recinfo.Reminder_Defined IS NULL )
                AND (  p_Reminder_Defined IS NULL )))
       AND (    ( Recinfo.Total_Reminders = p_Total_Reminders)
            OR (    ( Recinfo.Total_Reminders IS NULL )
                AND (  p_Total_Reminders IS NULL )))
       AND (    ( Recinfo.Reminder_Frequency = p_Reminder_Frequency)
            OR (    ( Recinfo.Reminder_Frequency IS NULL )
                AND (  p_Reminder_Frequency IS NULL )))
       AND (    ( Recinfo.Reminder_Freq_uom_code = p_Reminder_Freq_uom_code)
            OR (    ( Recinfo.Reminder_Freq_uom_code IS NULL )
                AND (  p_Reminder_Freq_uom_code IS NULL )))
       AND (    ( Recinfo.Timeout_Defined = p_Timeout_Defined)
            OR (    ( Recinfo.Timeout_Defined IS NULL )
                AND (  p_Timeout_Defined IS NULL )))
       AND (    ( Recinfo.Timeout_Duration = p_Timeout_Duration)
            OR (    ( Recinfo.Timeout_Duration IS NULL )
                AND (  p_Timeout_Duration IS NULL )))
       AND (    ( Recinfo.Timeout_uom_code = p_Timeout_uom_code)
            OR (    ( Recinfo.Timeout_uom_code IS NULL )
                AND (  p_Timeout_uom_code IS NULL )))
       AND (    ( Recinfo.notify_owner = p_notify_owner)
            OR (    ( Recinfo.notify_owner IS NULL )
                AND (  p_notify_owner IS NULL )))
       AND (    ( Recinfo.notify_owner_manager = p_notify_owner_manager)
            OR (    ( Recinfo.notify_owner_manager IS NULL )
                AND (  p_notify_owner_manager IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;

End aml_MONITOR_CONDITIONS_PKG;

/
