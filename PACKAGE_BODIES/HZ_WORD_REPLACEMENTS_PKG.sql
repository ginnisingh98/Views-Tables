--------------------------------------------------------
--  DDL for Package Body HZ_WORD_REPLACEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_REPLACEMENTS_PKG" as
/*$Header: ARHWRSTB.pls 120.4 2005/10/30 04:23:21 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_WORD_REPLACEMENTS
            WHERE TYPE = x_TYPE
            AND   ORIGINAL_WORD =  x_ORIGINAL_WORD;
BEGIN
   INSERT INTO HZ_WORD_REPLACEMENTS(
           ORIGINAL_WORD,
           REPLACEMENT_WORD,
           TYPE,
           COUNTRY_CODE,
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
          )
          VALUES (
           decode( x_ORIGINAL_WORD, FND_API.G_MISS_CHAR, NULL, x_ORIGINAL_WORD),
           decode( x_REPLACEMENT_WORD, FND_API.G_MISS_CHAR, NULL, x_REPLACEMENT_WORD),
           decode( x_TYPE, FND_API.G_MISS_CHAR, NULL, x_TYPE),
           decode( x_COUNTRY_CODE, FND_API.G_MISS_CHAR, NULL, x_COUNTRY_CODE),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15)
          );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(
             x_TYPE                   VARCHAR2,
             x_ORIGINAL_WORD          VARCHAR2
 ) IS
 BEGIN
   DELETE FROM HZ_WORD_REPLACEMENTS
    WHERE type = x_TYPE
    AND   original_word = x_ORIGINAL_WORD;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2
 ) IS

 BEGIN
    Update HZ_WORD_REPLACEMENTS
    SET
             ORIGINAL_WORD = decode( x_ORIGINAL_WORD, FND_API.G_MISS_CHAR, NULL, x_ORIGINAL_WORD),
             REPLACEMENT_WORD = decode( x_REPLACEMENT_WORD, FND_API.G_MISS_CHAR, NULL, x_REPLACEMENT_WORD),
             TYPE = decode( x_TYPE, FND_API.G_MISS_CHAR, NULL, x_TYPE),
             COUNTRY_CODE = decode( x_COUNTRY_CODE, FND_API.G_MISS_CHAR, NULL, x_COUNTRY_CODE),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             -- Bug 3032780
             /*
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             */
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,ATTRIBUTE_CATEGORY,x_ATTRIBUTE_CATEGORY),
             ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE1,x_ATTRIBUTE1),
             ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR,ATTRIBUTE2,x_ATTRIBUTE2),
             ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR,ATTRIBUTE3,x_ATTRIBUTE3),
             ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR,ATTRIBUTE4,x_ATTRIBUTE4),
             ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR,ATTRIBUTE5,x_ATTRIBUTE5),
             ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR,ATTRIBUTE6,x_ATTRIBUTE6),
             ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR,ATTRIBUTE7,x_ATTRIBUTE7),
             ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR,ATTRIBUTE8,x_ATTRIBUTE8),
             ATTRIBUTE9 = decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR,ATTRIBUTE9,x_ATTRIBUTE9),
             ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,ATTRIBUTE10,x_ATTRIBUTE10),
             ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR,ATTRIBUTE11,x_ATTRIBUTE11),
             ATTRIBUTE12 = decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR,ATTRIBUTE12,x_ATTRIBUTE12),
             ATTRIBUTE13 = decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR,ATTRIBUTE13,x_ATTRIBUTE13),
             ATTRIBUTE14 = decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR,ATTRIBUTE14,x_ATTRIBUTE14),
             ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR,ATTRIBUTE15,x_ATTRIBUTE15)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_ORIGINAL_WORD                 VARCHAR2,
                  x_REPLACEMENT_WORD              VARCHAR2,
                  x_TYPE                          VARCHAR2,
                  x_COUNTRY_CODE                  VARCHAR2,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_ATTRIBUTE_CATEGORY            VARCHAR2,
                  x_ATTRIBUTE1                    VARCHAR2,
                  x_ATTRIBUTE2                    VARCHAR2,
                  x_ATTRIBUTE3                    VARCHAR2,
                  x_ATTRIBUTE4                    VARCHAR2,
                  x_ATTRIBUTE5                    VARCHAR2,
                  x_ATTRIBUTE6                    VARCHAR2,
                  x_ATTRIBUTE7                    VARCHAR2,
                  x_ATTRIBUTE8                    VARCHAR2,
                  x_ATTRIBUTE9                    VARCHAR2,
                  x_ATTRIBUTE10                   VARCHAR2,
                  x_ATTRIBUTE11                   VARCHAR2,
                  x_ATTRIBUTE12                   VARCHAR2,
                  x_ATTRIBUTE13                   VARCHAR2,
                  x_ATTRIBUTE14                   VARCHAR2,
                  x_ATTRIBUTE15                   VARCHAR2
 ) IS

   CURSOR C IS
        SELECT *
          FROM HZ_WORD_REPLACEMENTS
         WHERE rowid = x_Rowid
         FOR UPDATE of ORIGINAL_WORD NOWAIT;
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
           (    ( Recinfo.ORIGINAL_WORD = x_ORIGINAL_WORD)
            OR (    ( Recinfo.ORIGINAL_WORD = NULL )
                AND (  x_ORIGINAL_WORD = NULL )))
       AND (    ( Recinfo.REPLACEMENT_WORD = x_REPLACEMENT_WORD)
            OR (    ( Recinfo.REPLACEMENT_WORD = NULL )
                AND (  x_REPLACEMENT_WORD = NULL )))
       AND (    ( Recinfo.TYPE = x_TYPE)
            OR (    ( Recinfo.TYPE = NULL )
                AND (  x_TYPE = NULL )))
       AND (    ( Recinfo.COUNTRY_CODE = x_COUNTRY_CODE)
            OR (    ( Recinfo.COUNTRY_CODE = NULL )
                AND (  x_COUNTRY_CODE = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = x_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY = NULL )
                AND (  x_ATTRIBUTE_CATEGORY = NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = x_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 = NULL )
                AND (  x_ATTRIBUTE1 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = x_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 = NULL )
                AND (  x_ATTRIBUTE2 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = x_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 = NULL )
                AND (  x_ATTRIBUTE3 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = x_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 = NULL )
                AND (  x_ATTRIBUTE4 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = x_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 = NULL )
                AND (  x_ATTRIBUTE5 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = x_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 = NULL )
                AND (  x_ATTRIBUTE6 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = x_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 = NULL )
                AND (  x_ATTRIBUTE7 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = x_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 = NULL )
                AND (  x_ATTRIBUTE8 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = x_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 = NULL )
                AND (  x_ATTRIBUTE9 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = x_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 = NULL )
                AND (  x_ATTRIBUTE10 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = x_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 = NULL )
                AND (  x_ATTRIBUTE11 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = x_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 = NULL )
                AND (  x_ATTRIBUTE12 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = x_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 = NULL )
                AND (  x_ATTRIBUTE13 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = x_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 = NULL )
                AND (  x_ATTRIBUTE14 = NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = x_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 = NULL )
                AND (  x_ATTRIBUTE15 = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_WORD_REPLACEMENTS_PKG;

/
