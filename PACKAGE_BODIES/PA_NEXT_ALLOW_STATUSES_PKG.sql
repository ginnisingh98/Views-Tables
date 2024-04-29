--------------------------------------------------------
--  DDL for Package Body PA_NEXT_ALLOW_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_NEXT_ALLOW_STATUSES_PKG" as
/* $Header: PASTANTB.pls 120.1 2005/06/30 12:33:09 appldev noship $ */
-- Start of Comments
-- Package name     : PA_NEXT_ALLOW_STATUSES_PKG
-- Purpose          : Table handler for PA_NEXT_ALLOW_STATUSES
-- History          : 07-JUL-2000 Mohnish       Created
-- NOTE             :  The procedure in these packages need to be
--					:  called through the PA_NEXT_ALLOW_STATUSES_PVT
--                  :  procedures only
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_NEXT_ALLOW_STATUSES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PASTATNB.pls';

PROCEDURE Insert_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2)
 IS
BEGIN
   INSERT INTO PA_NEXT_ALLOW_STATUSES(
          STATUS_CODE,
          NEXT_ALLOWABLE_STATUS_CODE,
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
          ATTRIBUTE15
          ) VALUES (
           decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
           decode( p_NEXT_ALLOWABLE_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_NEXT_ALLOWABLE_STATUS_CODE),
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
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15)
		   );
End Insert_Row;

PROCEDURE Update_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2)
 IS
 BEGIN
    Update PA_NEXT_ALLOW_STATUSES
    SET
           STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
           NEXT_ALLOWABLE_STATUS_CODE = decode( p_NEXT_ALLOWABLE_STATUS_CODE, FND_API.G_MISS_CHAR, NEXT_ALLOWABLE_STATUS_CODE, p_NEXT_ALLOWABLE_STATUS_CODE),
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
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
    where STATUS_CODE = p_STATUS_CODE;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Lock_Row(
          p_STATUS_CODE                   VARCHAR2,
          p_NEXT_ALLOWABLE_STATUS_CODE    VARCHAR2,
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
          p_ATTRIBUTE15                   VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM PA_NEXT_ALLOW_STATUSES
        WHERE STATUS_CODE =  p_STATUS_CODE
        FOR UPDATE of STATUS_CODE NOWAIT;
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
       (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.NEXT_ALLOWABLE_STATUS_CODE = p_NEXT_ALLOWABLE_STATUS_CODE)
            OR (    ( Recinfo.NEXT_ALLOWABLE_STATUS_CODE IS NULL )
                AND (  p_NEXT_ALLOWABLE_STATUS_CODE IS NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Delete_Row(
    p_STATUS_CODE  VARCHAR2)
 IS
 BEGIN
   DELETE FROM PA_NEXT_ALLOW_STATUSES
    WHERE STATUS_CODE = p_STATUS_CODE;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 EXCEPTION
   When NO_DATA_FOUND then
   null;
 END Delete_Row;

End PA_NEXT_ALLOW_STATUSES_PKG;

/
