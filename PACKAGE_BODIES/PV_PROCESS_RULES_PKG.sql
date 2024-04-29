--------------------------------------------------------
--  DDL for Package Body PV_PROCESS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PROCESS_RULES_PKG" as
/* $Header: pvrtprub.pls 120.2 2006/06/01 21:42:11 solin noship $ */
-- Start of Comments
-- Package name     : PV_PROCESS_RULES_PKG
-- Purpose          :
-- History          :
--      01/08/2002  SOLIN    Created.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PROCESS_RULES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvrtprub.pls';

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_PROCESS_RULE_ID   IN OUT NOCOPY NUMBER
         ,p_PARENT_RULE_ID   IN NUMBER
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
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
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
   CURSOR C2 IS SELECT PV_PROCESS_RULES_B_S.nextval FROM sys.dual;
BEGIN
   If (px_PROCESS_RULE_ID IS NULL) OR (px_PROCESS_RULE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PROCESS_RULE_ID;
       CLOSE C2;
   End If;
   INSERT INTO PV_PROCESS_RULES_B(
           PROCESS_RULE_ID
          ,PARENT_RULE_ID
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
          ,PROCESS_TYPE
          ,RANK
          ,STATUS_CODE
          ,START_DATE
          ,END_DATE
          ,ACTION
          ,ACTION_VALUE
          ,OWNER_RESOURCE_ID
          ,CURRENCY_CODE
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
           px_PROCESS_RULE_ID
          ,decode( p_PARENT_RULE_ID, FND_API.G_MISS_NUM, NULL, p_PARENT_RULE_ID)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,1
          ,decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID)
          ,decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID)
          ,decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID)
          ,decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE)
          ,decode( p_PROCESS_TYPE, FND_API.G_MISS_CHAR, NULL, p_PROCESS_TYPE)
          ,decode( p_RANK, FND_API.G_MISS_NUM, NULL, p_RANK)
          ,decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE)
          ,decode( p_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE)
          ,decode( p_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE)
          ,decode( p_ACTION, FND_API.G_MISS_CHAR, NULL, p_ACTION)
          ,decode( p_ACTION_VALUE, FND_API.G_MISS_CHAR, NULL, p_ACTION_VALUE)
          ,decode( p_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_RESOURCE_ID)
          ,decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL, p_CURRENCY_CODE)
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

   INSERT INTO PV_PROCESS_RULES_TL (
          PROCESS_RULE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          PROCESS_RULE_NAME,
          DESCRIPTION,
          LANGUAGE,
          SOURCE_LANG
        ) SELECT
          px_PROCESS_RULE_ID
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,decode( p_PROCESS_RULE_NAME, FND_API.G_MISS_CHAR, NULL, p_PROCESS_RULE_NAME)
          ,decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION)
          ,l.LANGUAGE_CODE
          ,USERENV('LANG')
        FROM FND_LANGUAGES L
        WHERE L.INSTALLED_FLAG IN ('I', 'B')
        AND NOT EXISTS
          (SELECT NULL
          FROM PV_PROCESS_RULES_TL T
          WHERE T.PROCESS_RULE_ID = PX_PROCESS_RULE_ID
          AND T.LANGUAGE = L.LANGUAGE_CODE);
End Insert_Row;

PROCEDURE Update_Row(
          p_PROCESS_RULE_ID    NUMBER
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
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
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
    Update PV_PROCESS_RULES_B
    SET
        LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER+1)
       ,REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID)
       ,PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID)
       ,PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID)
       ,PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE)
       ,PROCESS_TYPE = decode( p_PROCESS_TYPE, FND_API.G_MISS_CHAR, PROCESS_TYPE, p_PROCESS_TYPE)
       ,RANK = decode( p_RANK, FND_API.G_MISS_NUM, RANK, p_RANK)
       ,STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE)
       ,START_DATE = decode( p_START_DATE, FND_API.G_MISS_DATE, START_DATE, p_START_DATE)
       ,END_DATE = decode( p_END_DATE, FND_API.G_MISS_DATE, END_DATE, p_END_DATE)
       ,ACTION = decode( p_ACTION, FND_API.G_MISS_CHAR, ACTION, p_ACTION)
       ,ACTION_VALUE = decode( p_ACTION_VALUE, FND_API.G_MISS_CHAR, ACTION_VALUE, p_ACTION_VALUE)
       ,OWNER_RESOURCE_ID = decode( p_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, OWNER_RESOURCE_ID, p_OWNER_RESOURCE_ID)
       ,CURRENCY_CODE = decode( p_CURRENCY_CODE, FND_API.G_MISS_CHAR, CURRENCY_CODE, p_CURRENCY_CODE)
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
    where PROCESS_RULE_ID = p_PROCESS_RULE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    Update PV_PROCESS_RULES_TL
    SET
        PROCESS_RULE_NAME = decode( p_PROCESS_RULE_NAME, FND_API.G_MISS_CHAR, PROCESS_RULE_NAME, p_PROCESS_RULE_NAME)
       ,DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION)
       ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
    WHERE PROCESS_RULE_ID = P_PROCESS_RULE_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE Delete_Row(
    p_PROCESS_RULE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM PV_PROCESS_RULES_B
   WHERE PROCESS_RULE_ID = p_PROCESS_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM PV_PROCESS_RULES_TL
   WHERE PROCESS_RULE_ID = p_PROCESS_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
END Delete_Row;

PROCEDURE Lock_Row(
          p_PROCESS_RULE_ID    NUMBER
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
         ,p_PROCESS_TYPE    VARCHAR2
         ,p_RANK    NUMBER
         ,p_STATUS_CODE    VARCHAR2
         ,p_START_DATE    DATE
         ,p_END_DATE    DATE
         ,p_ACTION    VARCHAR2
         ,p_ACTION_VALUE    VARCHAR2
         ,p_OWNER_RESOURCE_ID    NUMBER
         ,p_CURRENCY_CODE    VARCHAR2
         ,p_PROCESS_RULE_NAME    VARCHAR2
         ,p_DESCRIPTION    VARCHAR2
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
       FROM PV_PROCESS_RULES_B
       WHERE PROCESS_RULE_ID =  p_PROCESS_RULE_ID
       FOR UPDATE of PROCESS_RULE_ID NOWAIT;
   Recinfo C%ROWTYPE;

   CURSOR c1 IS
       SELECT PROCESS_RULE_NAME,
              DESCRIPTION,
              DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
       FROM PV_PROCESS_RULES_TL
       WHERE PROCESS_RULE_ID = P_PROCESS_RULE_ID
       AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
       FOR UPDATE OF PROCESS_RULE_ID NOWAIT;
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
           (      Recinfo.PROCESS_RULE_ID = p_PROCESS_RULE_ID)
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
       AND (    ( Recinfo.PROCESS_TYPE = p_PROCESS_TYPE)
            OR (    ( Recinfo.PROCESS_TYPE IS NULL )
                AND (  p_PROCESS_TYPE IS NULL )))
       AND (    ( Recinfo.RANK = p_RANK)
            OR (    ( Recinfo.RANK IS NULL )
                AND (  p_RANK IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.START_DATE = p_START_DATE)
            OR (    ( Recinfo.START_DATE IS NULL )
                AND (  p_START_DATE IS NULL )))
       AND (    ( Recinfo.END_DATE = p_END_DATE)
            OR (    ( Recinfo.END_DATE IS NULL )
                AND (  p_END_DATE IS NULL )))
       AND (    ( Recinfo.ACTION = p_ACTION)
            OR (    ( Recinfo.ACTION IS NULL )
                AND (  p_ACTION IS NULL )))
       AND (    ( Recinfo.ACTION_VALUE = p_ACTION_VALUE)
            OR (    ( Recinfo.ACTION_VALUE IS NULL )
                AND (  p_ACTION_VALUE IS NULL )))
       AND (    ( Recinfo.OWNER_RESOURCE_ID = p_OWNER_RESOURCE_ID)
            OR (    ( Recinfo.OWNER_RESOURCE_ID IS NULL )
                AND (  p_OWNER_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = p_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  p_CURRENCY_CODE IS NULL )))
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

   FOR tlinfo IN c1 LOOP
       IF (tlinfo.BASELANG = 'Y') THEN
           IF (   (tlinfo.PROCESS_RULE_NAME = P_PROCESS_RULE_NAME)
              AND (tlinfo.DESCRIPTION = P_DESCRIPTION) )
           THEN
               NULL;
           ELSE
               fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
               app_exception.raise_exception;
           END IF;
       END IF;
  END LOOP;
END Lock_Row;


PROCEDURE Add_Language
IS
BEGIN
  DELETE FROM PV_PROCESS_RULES_TL T
  WHERE NOT EXISTS
    (SELECT NULL
     FROM PV_PROCESS_RULES_B B
     WHERE B.PROCESS_RULE_ID = T.PROCESS_RULE_ID
    );

  UPDATE PV_PROCESS_RULES_TL T SET (
       PROCESS_RULE_NAME,
       DESCRIPTION
       ) = (SELECT
              B.PROCESS_RULE_NAME
             ,B.DESCRIPTION
           FROM PV_PROCESS_RULES_TL B
           WHERE B.PROCESS_RULE_ID = T.PROCESS_RULE_ID
             AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
       T.PROCESS_RULE_ID
      ,T.LANGUAGE
  ) IN (SELECT
           SUBT.PROCESS_RULE_ID
          ,SUBT.LANGUAGE
        FROM PV_PROCESS_RULES_TL SUBB, PV_PROCESS_RULES_TL SUBT
        WHERE SUBB.PROCESS_RULE_ID = SUBT.PROCESS_RULE_ID
          AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
          AND (SUBB.PROCESS_RULE_NAME <> SUBT.PROCESS_RULE_NAME
                OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                OR (SUBB.PROCESS_RULE_NAME IS NULL AND SUBT.PROCESS_RULE_NAME IS NOT NULL)
                OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
               )
  );

  INSERT INTO PV_PROCESS_RULES_TL (
            PROCESS_RULE_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_LOGIN
           ,LANGUAGE
           ,SOURCE_LANG
           ,PROCESS_RULE_NAME
           ,DESCRIPTION
  ) SELECT
            B.PROCESS_RULE_ID
           ,B.LAST_UPDATE_DATE
           ,B.LAST_UPDATED_BY
           ,B.CREATION_DATE
           ,B.CREATED_BY
           ,B.LAST_UPDATE_LOGIN
           ,L.LANGUAGE_CODE
           ,B.SOURCE_LANG
           ,B.PROCESS_RULE_NAME
           ,B.DESCRIPTION
  FROM PV_PROCESS_RULES_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM PV_PROCESS_RULES_TL T
    WHERE T.PROCESS_RULE_ID = B.PROCESS_RULE_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

END Add_Language;


PROCEDURE Load_Row (
  px_PROCESS_RULE_ID        IN OUT NOCOPY NUMBER,
  p_PARENT_RULE_ID          IN NUMBER,
  p_PROCESS_TYPE            IN VARCHAR2,
  p_RANK                    IN NUMBER,
  p_STATUS_CODE             IN VARCHAR2,
  p_START_DATE              IN DATE,
  p_END_DATE                IN DATE,
  p_ACTION                  IN VARCHAR2,
  p_ACTION_VALUE            IN VARCHAR2,
  p_OWNER_RESOURCE_ID       IN NUMBER,
  p_CURRENCY_CODE           IN VARCHAR2,
  p_PROCESS_RULE_NAME       IN VARCHAR2,
  p_DESCRIPTION             IN VARCHAR2,
  p_OWNER                   IN VARCHAR2)
IS
    l_user_id               NUMBER := 0;
    l_row_id                VARCHAR2(100);

    CURSOR c_get_last_updated (c_PROCESS_RULE_ID NUMBER) IS
        SELECT last_updated_by, OBJECT_VERSION_NUMBER
        FROM PV_PROCESS_RULES_B
        WHERE PROCESS_RULE_ID = c_PROCESS_RULE_ID;
    l_last_updated_by       NUMBER;
    l_object_version_number NUMBER;

BEGIN
    OPEN c_get_last_updated (px_PROCESS_RULE_ID);
    FETCH c_get_last_updated INTO l_last_updated_by, l_object_version_number;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN

        Update_Row(
          p_PROCESS_RULE_ID        => px_PROCESS_RULE_ID
         ,p_LAST_UPDATE_DATE       => SYSDATE
         ,p_LAST_UPDATED_BY        => fnd_load_util.owner_id(P_OWNER)
         ,p_CREATION_DATE          => FND_API.G_MISS_DATE
         ,p_CREATED_BY             => FND_API.G_MISS_NUM
         ,p_LAST_UPDATE_LOGIN      => fnd_load_util.owner_id(P_OWNER)
         ,p_OBJECT_VERSION_NUMBER  => l_object_version_number
         ,p_REQUEST_ID             => FND_API.G_MISS_NUM
         ,p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM
         ,p_PROGRAM_ID             => FND_API.G_MISS_NUM
         ,p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE
         ,p_PROCESS_TYPE           => p_PROCESS_TYPE
         ,p_RANK                   => p_RANK
         ,p_STATUS_CODE            => p_STATUS_CODE
         ,p_START_DATE             => p_START_DATE
         ,p_END_DATE               => p_END_DATE
         ,p_ACTION                 => p_ACTION
         ,p_ACTION_VALUE           => p_ACTION_VALUE
         ,p_OWNER_RESOURCE_ID      => p_OWNER_RESOURCE_ID
         ,p_CURRENCY_CODE          => p_CURRENCY_CODE
         ,p_PROCESS_RULE_NAME      => p_PROCESS_RULE_NAME
         ,p_DESCRIPTION            => p_DESCRIPTION
         ,p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE1             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE2             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE3             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE4             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE5             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE6             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE7             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE8             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE9             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE10            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE11            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE12            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE13            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE14            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE15            => FND_API.G_MISS_CHAR);

    END IF;

    EXCEPTION
        when no_data_found then

            Insert_Row(
          px_PROCESS_RULE_ID       => px_PROCESS_RULE_ID
         ,p_PARENT_RULE_ID         => p_PARENT_RULE_ID
         ,p_LAST_UPDATE_DATE       => SYSDATE
         ,p_LAST_UPDATED_BY        => fnd_load_util.owner_id(P_OWNER)
         ,p_CREATION_DATE          => SYSDATE
         ,p_CREATED_BY             => fnd_load_util.owner_id(P_OWNER)
         ,p_LAST_UPDATE_LOGIN      => fnd_load_util.owner_id(P_OWNER)
         ,p_OBJECT_VERSION_NUMBER  => l_object_version_number
         ,p_REQUEST_ID             => FND_API.G_MISS_NUM
         ,p_PROGRAM_APPLICATION_ID => FND_API.G_MISS_NUM
         ,p_PROGRAM_ID             => FND_API.G_MISS_NUM
         ,p_PROGRAM_UPDATE_DATE    => FND_API.G_MISS_DATE
         ,p_PROCESS_TYPE           => p_PROCESS_TYPE
         ,p_RANK                   => p_RANK
         ,p_STATUS_CODE            => p_STATUS_CODE
         ,p_START_DATE             => p_START_DATE
         ,p_END_DATE               => p_END_DATE
         ,p_ACTION                 => p_ACTION
         ,p_ACTION_VALUE           => p_ACTION_VALUE
         ,p_OWNER_RESOURCE_ID      => p_OWNER_RESOURCE_ID
         ,p_CURRENCY_CODE          => p_CURRENCY_CODE
         ,p_PROCESS_RULE_NAME      => p_PROCESS_RULE_NAME
         ,p_DESCRIPTION            => p_DESCRIPTION
         ,p_ATTRIBUTE_CATEGORY     => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE1             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE2             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE3             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE4             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE5             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE6             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE7             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE8             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE9             => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE10            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE11            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE12            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE13            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE14            => FND_API.G_MISS_CHAR
         ,p_ATTRIBUTE15            => FND_API.G_MISS_CHAR);

END LOAD_ROW;


PROCEDURE Translate_Row(
       px_PROCESS_RULE_ID	      	 IN  NUMBER
      ,p_PROCESS_RULE_NAME               IN  VARCHAR2
      ,p_DESCRIPTION			 IN  VARCHAR2
      ,p_OWNER_RESOURCE_ID		 IN  VARCHAR2
      )

IS

 BEGIN
    UPDATE PV_PROCESS_RULES_TL SET
       PROCESS_RULE_NAME               = NVL(p_PROCESS_RULE_NAME, PROCESS_RULE_NAME)
      ,DESCRIPTION		       = NVL(p_DESCRIPTION, DESCRIPTION)
      ,SOURCE_LANG                     = USERENV('LANG')
      ,LAST_UPDATE_DATE                = SYSDATE
      ,LAST_UPDATED_BY                 = DECODE(p_OWNER_RESOURCE_ID, 'SEED', 1, 0)
      ,LAST_UPDATE_LOGIN               = 0
    WHERE  PROCESS_RULE_ID = px_PROCESS_RULE_ID
    AND      USERENV('LANG') IN (language, source_lang);

END TRANSLATE_ROW;


End PV_PROCESS_RULES_PKG;

/
