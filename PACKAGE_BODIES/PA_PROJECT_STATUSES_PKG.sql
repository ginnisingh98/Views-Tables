--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STATUSES_PKG" as
/* $Header: PASTAPTB.pls 120.1 2005/06/30 12:33:14 appldev noship $ */
-- Start of Comments
-- Package name     : PA_PROJECT_STATUSES_PKG
-- Purpose          : Table handler for PA_PROJECT_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :  The procedure in these packages need to be
--					:  called through the PA_PROJECT_STATUSES_PVT
--                  :  procedures only
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_PROJECT_STATUSES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PASTATTB.pls';

PROCEDURE Insert_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2)
 IS
   CURSOR C2 IS SELECT PA_PROJECT_STATUSES_S.nextval FROM sys.dual;
   v_project_status_code  VARCHAR2(30);
BEGIN
   If (v_project_status_code IS NULL) OR (v_project_status_code = FND_API.G_MISS_CHAR) then
       OPEN C2;
       FETCH C2 INTO v_project_status_code;
       CLOSE C2;
   End If;
   INSERT INTO PA_PROJECT_STATUSES(
          PROJECT_STATUS_CODE,
          PROJECT_STATUS_NAME,
          PROJECT_SYSTEM_STATUS_CODE,
          DESCRIPTION,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          PREDEFINED_FLAG,
          STARTING_STATUS_FLAG,
          ENABLE_WF_FLAG,
          WORKFLOW_ITEM_TYPE,
          WORKFLOW_PROCESS,
          WF_SUCCESS_STATUS_CODE,
          WF_FAILURE_STATUS_CODE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          ATTRIBUTE_CATEGORY,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          STATUS_TYPE,
          NEXT_ALLOWABLE_STATUS_FLAG
          ) VALUES (
           v_project_status_code,
           decode( p_PROJECT_STATUS_NAME, FND_API.G_MISS_CHAR, NULL, p_PROJECT_STATUS_NAME),
           decode( p_PROJECT_SYSTEM_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_PROJECT_SYSTEM_STATUS_CODE),
           decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
           decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE),
           decode( p_PREDEFINED_FLAG, FND_API.G_MISS_CHAR, NULL, p_PREDEFINED_FLAG),
           decode( p_STARTING_STATUS_FLAG, FND_API.G_MISS_CHAR, NULL, p_STARTING_STATUS_FLAG),
           decode( p_ENABLE_WF_FLAG, FND_API.G_MISS_CHAR, NULL, p_ENABLE_WF_FLAG),
           decode( p_WORKFLOW_ITEM_TYPE, FND_API.G_MISS_CHAR, NULL, p_WORKFLOW_ITEM_TYPE),
           decode( p_WORKFLOW_PROCESS, FND_API.G_MISS_CHAR, NULL, p_WORKFLOW_PROCESS),
           decode( p_WF_SUCCESS_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_WF_SUCCESS_STATUS_CODE),
           decode( p_WF_FAILURE_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_WF_FAILURE_STATUS_CODE),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_STATUS_TYPE, FND_API.G_MISS_CHAR, NULL, p_STATUS_TYPE),
           decode( p_NEXT_ALLOWABLE_STATUS_FLAG, FND_API.G_MISS_CHAR, NULL, p_NEXT_ALLOWABLE_STATUS_FLAG)
		   );
End Insert_Row;

PROCEDURE Update_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2)
 IS
 BEGIN
    Update PA_PROJECT_STATUSES
    SET
           PROJECT_STATUS_NAME = decode( p_PROJECT_STATUS_NAME, FND_API.G_MISS_CHAR, PROJECT_STATUS_NAME, p_PROJECT_STATUS_NAME),
           PROJECT_SYSTEM_STATUS_CODE = decode( p_PROJECT_SYSTEM_STATUS_CODE, FND_API.G_MISS_CHAR, PROJECT_SYSTEM_STATUS_CODE, p_PROJECT_SYSTEM_STATUS_CODE),
           DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, DESCRIPTION, p_DESCRIPTION),
           START_DATE_ACTIVE = decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, START_DATE_ACTIVE, p_START_DATE_ACTIVE),
           END_DATE_ACTIVE = decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, END_DATE_ACTIVE, p_END_DATE_ACTIVE),
           PREDEFINED_FLAG = decode( p_PREDEFINED_FLAG, FND_API.G_MISS_CHAR, PREDEFINED_FLAG, p_PREDEFINED_FLAG),
           STARTING_STATUS_FLAG = decode( p_STARTING_STATUS_FLAG, FND_API.G_MISS_CHAR, STARTING_STATUS_FLAG, p_STARTING_STATUS_FLAG),
           ENABLE_WF_FLAG = decode( p_ENABLE_WF_FLAG, FND_API.G_MISS_CHAR, ENABLE_WF_FLAG, p_ENABLE_WF_FLAG),
           WORKFLOW_ITEM_TYPE = decode( p_WORKFLOW_ITEM_TYPE, FND_API.G_MISS_CHAR, WORKFLOW_ITEM_TYPE, p_WORKFLOW_ITEM_TYPE),
           WORKFLOW_PROCESS = decode( p_WORKFLOW_PROCESS, FND_API.G_MISS_CHAR, WORKFLOW_PROCESS, p_WORKFLOW_PROCESS),
           WF_SUCCESS_STATUS_CODE = decode( p_WF_SUCCESS_STATUS_CODE, FND_API.G_MISS_CHAR, WF_SUCCESS_STATUS_CODE, p_WF_SUCCESS_STATUS_CODE),
           WF_FAILURE_STATUS_CODE = decode( p_WF_FAILURE_STATUS_CODE, FND_API.G_MISS_CHAR, WF_FAILURE_STATUS_CODE, p_WF_FAILURE_STATUS_CODE),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_CHAR, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
              STATUS_TYPE = decode( p_STATUS_TYPE, FND_API.G_MISS_CHAR, STATUS_TYPE, p_STATUS_TYPE),
              NEXT_ALLOWABLE_STATUS_FLAG = decode( p_NEXT_ALLOWABLE_STATUS_FLAG, FND_API.G_MISS_CHAR, NEXT_ALLOWABLE_STATUS_FLAG, p_NEXT_ALLOWABLE_STATUS_FLAG)
    where PROJECT_STATUS_CODE = p_PROJECT_STATUS_CODE;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Lock_Row(
          p_PROJECT_STATUS_CODE           VARCHAR2,
          p_PROJECT_STATUS_NAME           VARCHAR2,
          p_PROJECT_SYSTEM_STATUS_CODE    VARCHAR2,
          p_DESCRIPTION                   VARCHAR2,
          p_START_DATE_ACTIVE             DATE,
          p_END_DATE_ACTIVE               DATE,
          p_PREDEFINED_FLAG               VARCHAR2,
          p_STARTING_STATUS_FLAG          VARCHAR2,
          p_ENABLE_WF_FLAG                VARCHAR2,
          p_WORKFLOW_ITEM_TYPE            VARCHAR2,
          p_WORKFLOW_PROCESS              VARCHAR2,
          p_WF_SUCCESS_STATUS_CODE        VARCHAR2,
          p_WF_FAILURE_STATUS_CODE        VARCHAR2,
          p_LAST_UPDATE_DATE              DATE,
          p_LAST_UPDATED_BY               NUMBER,
          p_CREATION_DATE                 DATE,
          p_CREATED_BY                    NUMBER,
          p_LAST_UPDATE_LOGIN             NUMBER,
          p_ATTRIBUTE_CATEGORY            VARCHAR2,
          p_ATTRIBUTE1                    VARCHAR2,
          p_ATTRIBUTE2                    VARCHAR2,
          p_ATTRIBUTE3                    VARCHAR2,
          p_ATTRIBUTE4                    VARCHAR2,
          p_ATTRIBUTE5                    VARCHAR2,
          p_ATTRIBUTE6                    VARCHAR2,
          p_ATTRIBUTE7                    VARCHAR2,
          p_ATTRIBUTE8                    VARCHAR2,
          p_ATTRIBUTE9                    VARCHAR2,
          p_ATTRIBUTE10                   VARCHAR2,
          p_ATTRIBUTE11                   VARCHAR2,
          p_ATTRIBUTE12                   VARCHAR2,
          p_ATTRIBUTE13                   VARCHAR2,
          p_ATTRIBUTE14                   VARCHAR2,
          p_ATTRIBUTE15                   VARCHAR2,
          p_STATUS_TYPE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_FLAG    VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM PA_PROJECT_STATUSES
        WHERE PROJECT_STATUS_CODE =  p_PROJECT_STATUS_CODE
        FOR UPDATE of PROJECT_STATUS_CODE NOWAIT;
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
       (    ( Recinfo.PROJECT_STATUS_NAME = p_PROJECT_STATUS_NAME)
            OR (    ( Recinfo.PROJECT_STATUS_NAME IS NULL )
                AND (  p_PROJECT_STATUS_NAME IS NULL )))
       AND (    ( Recinfo.PROJECT_SYSTEM_STATUS_CODE = p_PROJECT_SYSTEM_STATUS_CODE)
            OR (    ( Recinfo.PROJECT_SYSTEM_STATUS_CODE IS NULL )
                AND (  p_PROJECT_SYSTEM_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.DESCRIPTION = p_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION IS NULL )
                AND (  p_DESCRIPTION IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  p_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  p_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.PREDEFINED_FLAG = p_PREDEFINED_FLAG)
            OR (    ( Recinfo.PREDEFINED_FLAG IS NULL )
                AND (  p_PREDEFINED_FLAG IS NULL )))
       AND (    ( Recinfo.STARTING_STATUS_FLAG = p_STARTING_STATUS_FLAG)
            OR (    ( Recinfo.STARTING_STATUS_FLAG IS NULL )
                AND (  p_STARTING_STATUS_FLAG IS NULL )))
       AND (    ( Recinfo.ENABLE_WF_FLAG = p_ENABLE_WF_FLAG)
            OR (    ( Recinfo.ENABLE_WF_FLAG IS NULL )
                AND (  p_ENABLE_WF_FLAG IS NULL )))
       AND (    ( Recinfo.WORKFLOW_ITEM_TYPE = p_WORKFLOW_ITEM_TYPE)
            OR (    ( Recinfo.WORKFLOW_ITEM_TYPE IS NULL )
                AND (  p_WORKFLOW_ITEM_TYPE IS NULL )))
       AND (    ( Recinfo.WORKFLOW_PROCESS = p_WORKFLOW_PROCESS)
            OR (    ( Recinfo.WORKFLOW_PROCESS IS NULL )
                AND (  p_WORKFLOW_PROCESS IS NULL )))
       AND (    ( Recinfo.WF_SUCCESS_STATUS_CODE = p_WF_SUCCESS_STATUS_CODE)
            OR (    ( Recinfo.WF_SUCCESS_STATUS_CODE IS NULL )
                AND (  p_WF_SUCCESS_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.WF_FAILURE_STATUS_CODE = p_WF_FAILURE_STATUS_CODE)
            OR (    ( Recinfo.WF_FAILURE_STATUS_CODE IS NULL )
                AND (  p_WF_FAILURE_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (      Recinfo.CREATION_DATE = p_CREATION_DATE)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
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
       AND (    ( Recinfo.STATUS_TYPE = p_STATUS_TYPE)
            OR (    ( Recinfo.STATUS_TYPE IS NULL )
                AND (  p_STATUS_TYPE IS NULL )))
       AND (    ( Recinfo.NEXT_ALLOWABLE_STATUS_FLAG = p_NEXT_ALLOWABLE_STATUS_FLAG)
            OR (    ( Recinfo.NEXT_ALLOWABLE_STATUS_FLAG IS NULL )
                AND (  p_NEXT_ALLOWABLE_STATUS_FLAG IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Delete_Row(
    p_PROJECT_STATUS_CODE  VARCHAR2)
 IS
 BEGIN
   DELETE FROM PA_PROJECT_STATUSES
    WHERE PROJECT_STATUS_CODE = p_PROJECT_STATUS_CODE;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

End PA_PROJECT_STATUSES_PKG;

/
