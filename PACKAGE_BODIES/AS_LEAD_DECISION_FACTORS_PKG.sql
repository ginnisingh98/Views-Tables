--------------------------------------------------------
--  DDL for Package Body AS_LEAD_DECISION_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEAD_DECISION_FACTORS_PKG" as
/* $Header: asxtdfcb.pls 115.6 2004/01/13 10:08:33 gbatra ship $ */
-- Start of Comments
-- Package name     : AS_LEAD_DECISION_FACTORS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_LEAD_DECISION_FACTORS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtdfcb.pls';

PROCEDURE Insert_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          px_LEAD_DECISION_FACTOR_ID   IN OUT NOCOPY NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE)

 IS
   CURSOR C2 IS SELECT AS_LEAD_DECISION_FACTORS_S.nextval FROM sys.dual;
BEGIN
   If (px_LEAD_DECISION_FACTOR_ID IS NULL) OR (px_LEAD_DECISION_FACTOR_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_LEAD_DECISION_FACTOR_ID;
       CLOSE C2;
   End If;
   INSERT INTO AS_LEAD_DECISION_FACTORS(
           --SECURITY_GROUP_ID,
           ATTRIBUTE15,
           ATTRIBUTE14,
           ATTRIBUTE13,
           ATTRIBUTE12,
           ATTRIBUTE11,
           ATTRIBUTE10,
           ATTRIBUTE9,
           ATTRIBUTE8,
           ATTRIBUTE7,
           ATTRIBUTE6,
           ATTRIBUTE5,
           ATTRIBUTE4,
           ATTRIBUTE3,
           ATTRIBUTE2,
           ATTRIBUTE1,
           ATTRIBUTE_CATEGORY,
           PROGRAM_UPDATE_DATE,
           PROGRAM_ID,
           PROGRAM_APPLICATION_ID,
           REQUEST_ID,
           DECISION_RANK,
           DECISION_PRIORITY_CODE,
           DECISION_FACTOR_CODE,
           LEAD_DECISION_FACTOR_ID,
           LEAD_LINE_ID,
           CREATE_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CREATION_DATE
          ) VALUES (
           --decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_DECISION_RANK, FND_API.G_MISS_NUM, NULL, p_DECISION_RANK),
           decode( p_DECISION_PRIORITY_CODE, FND_API.G_MISS_CHAR, NULL, p_DECISION_PRIORITY_CODE),
           decode( p_DECISION_FACTOR_CODE, FND_API.G_MISS_CHAR, NULL, p_DECISION_FACTOR_CODE),
           px_LEAD_DECISION_FACTOR_ID,
           decode( p_LEAD_LINE_ID, FND_API.G_MISS_NUM, NULL, p_LEAD_LINE_ID),
           decode( p_CREATE_BY, FND_API.G_MISS_NUM, NULL, p_CREATE_BY),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE));
End Insert_Row;

PROCEDURE Update_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          p_LEAD_DECISION_FACTOR_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE)

 IS
 BEGIN
    Update AS_LEAD_DECISION_FACTORS
    SET object_version_number =  nvl(object_version_number,0) + 1,
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              DECISION_RANK = decode( p_DECISION_RANK, FND_API.G_MISS_NUM, DECISION_RANK, p_DECISION_RANK),
              DECISION_PRIORITY_CODE = decode( p_DECISION_PRIORITY_CODE, FND_API.G_MISS_CHAR, DECISION_PRIORITY_CODE, p_DECISION_PRIORITY_CODE),
              DECISION_FACTOR_CODE = decode( p_DECISION_FACTOR_CODE, FND_API.G_MISS_CHAR, DECISION_FACTOR_CODE, p_DECISION_FACTOR_CODE),
              LEAD_DECISION_FACTOR_ID = decode( p_LEAD_DECISION_FACTOR_ID, FND_API.G_MISS_NUM, LEAD_DECISION_FACTOR_ID, p_LEAD_DECISION_FACTOR_ID),
              LEAD_LINE_ID = decode( p_LEAD_LINE_ID, FND_API.G_MISS_NUM, LEAD_LINE_ID, p_LEAD_LINE_ID),
              CREATE_BY = decode( p_CREATE_BY, FND_API.G_MISS_NUM, CREATE_BY, p_CREATE_BY),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE)
    where LEAD_DECISION_FACTOR_ID = p_LEAD_DECISION_FACTOR_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_LEAD_DECISION_FACTOR_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_LEAD_DECISION_FACTORS
    WHERE LEAD_DECISION_FACTOR_ID = p_LEAD_DECISION_FACTOR_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_DECISION_RANK    NUMBER,
          p_DECISION_PRIORITY_CODE    VARCHAR2,
          p_DECISION_FACTOR_CODE    VARCHAR2,
          p_LEAD_DECISION_FACTOR_ID    NUMBER,
          p_LEAD_LINE_ID    NUMBER,
          p_CREATE_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATION_DATE    DATE)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_LEAD_DECISION_FACTORS
        WHERE LEAD_DECISION_FACTOR_ID =  p_LEAD_DECISION_FACTOR_ID
        FOR UPDATE of LEAD_DECISION_FACTOR_ID NOWAIT;
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
         --  (Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
       --AND (
          (Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
          OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
          AND (p_ATTRIBUTE15 IS NULL ))
       --)
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.DECISION_RANK = p_DECISION_RANK)
            OR (    ( Recinfo.DECISION_RANK IS NULL )
                AND (  p_DECISION_RANK IS NULL )))
       AND (    ( Recinfo.DECISION_PRIORITY_CODE = p_DECISION_PRIORITY_CODE)
            OR (    ( Recinfo.DECISION_PRIORITY_CODE IS NULL )
                AND (  p_DECISION_PRIORITY_CODE IS NULL )))
       AND (    ( Recinfo.DECISION_FACTOR_CODE = p_DECISION_FACTOR_CODE)
            OR (    ( Recinfo.DECISION_FACTOR_CODE IS NULL )
                AND (  p_DECISION_FACTOR_CODE IS NULL )))
       AND (    ( Recinfo.LEAD_DECISION_FACTOR_ID = p_LEAD_DECISION_FACTOR_ID)
            OR (    ( Recinfo.LEAD_DECISION_FACTOR_ID IS NULL )
                AND (  p_LEAD_DECISION_FACTOR_ID IS NULL )))
       AND (    ( Recinfo.LEAD_LINE_ID = p_LEAD_LINE_ID)
            OR (    ( Recinfo.LEAD_LINE_ID IS NULL )
                AND (  p_LEAD_LINE_ID IS NULL )))
       AND (    ( Recinfo.CREATE_BY = p_CREATE_BY)
            OR (    ( Recinfo.CREATE_BY IS NULL )
                AND (  p_CREATE_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AS_LEAD_DECISION_FACTORS_PKG;

/
