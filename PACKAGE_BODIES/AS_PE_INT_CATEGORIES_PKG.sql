--------------------------------------------------------
--  DDL for Package Body AS_PE_INT_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_PE_INT_CATEGORIES_PKG" as
/* $Header: asxtpeib.pls 120.0 2005/06/02 17:18:19 appldev noship $ */
-- Start of Comments
-- Package name     : AS_PE_INT_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_PE_INT_CATEGORIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtpeib.pls';

PROCEDURE Insert_Row(
          px_PE_INT_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER)
 IS
   CURSOR C2 IS SELECT AS_PE_INT_CATEGORIES_S.nextval FROM sys.dual;
BEGIN
   If (px_PE_INT_CATEGORY_ID IS NULL) OR (px_PE_INT_CATEGORY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PE_INT_CATEGORY_ID;
       CLOSE C2;
   End If;
   INSERT INTO AS_PE_INT_CATEGORIES(
           PE_INT_CATEGORY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           QUOTA_ID,
           MAPPING_TYPE,
           PRODUCT_CATEGORY_ID,
           PRODUCT_CAT_SET_ID
          ) VALUES (
           px_PE_INT_CATEGORY_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_PROGRAM_UPDATE_DATE),
           decode( p_QUOTA_ID, FND_API.G_MISS_NUM, NULL, p_QUOTA_ID),
           'OBSOLETED',
           decode( p_PRODUCT_CATEGORY_ID, FND_API.G_MISS_NUM, NULL, p_PRODUCT_CATEGORY_ID),
           decode( p_PRODUCT_CAT_SET_ID, FND_API.G_MISS_NUM, NULL, p_PRODUCT_CAT_SET_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_PE_INT_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER)
 IS
 BEGIN
    Update AS_PE_INT_CATEGORIES
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              QUOTA_ID = decode( p_QUOTA_ID, FND_API.G_MISS_NUM, QUOTA_ID, p_QUOTA_ID),
              PRODUCT_CATEGORY_ID = decode( p_PRODUCT_CATEGORY_ID, FND_API.G_MISS_NUM, PRODUCT_CATEGORY_ID, p_PRODUCT_CATEGORY_ID),
              PRODUCT_CAT_SET_ID = decode( p_PRODUCT_CAT_SET_ID, FND_API.G_MISS_NUM, PRODUCT_CAT_SET_ID, p_PRODUCT_CAT_SET_ID)
    where PE_INT_CATEGORY_ID = p_PE_INT_CATEGORY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PE_INT_CATEGORY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_PE_INT_CATEGORIES
    WHERE PE_INT_CATEGORY_ID = p_PE_INT_CATEGORY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PE_INT_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTA_ID    NUMBER,
          p_PRODUCT_CATEGORY_ID     NUMBER,
          p_PRODUCT_CAT_SET_ID      NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM AS_PE_INT_CATEGORIES
        WHERE PE_INT_CATEGORY_ID =  p_PE_INT_CATEGORY_ID
        FOR UPDATE of PE_INT_CATEGORY_ID NOWAIT;
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
           (      Recinfo.PE_INT_CATEGORY_ID = p_PE_INT_CATEGORY_ID)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
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
       AND (    ( Recinfo.QUOTA_ID = p_QUOTA_ID)
            OR (    ( Recinfo.QUOTA_ID IS NULL )
                AND (  p_QUOTA_ID IS NULL )))
       AND (    ( Recinfo.PRODUCT_CATEGORY_ID = p_PRODUCT_CATEGORY_ID)
            OR (    ( Recinfo.PRODUCT_CATEGORY_ID IS NULL )
                AND (  p_PRODUCT_CATEGORY_ID IS NULL )))
       AND (    ( Recinfo.PRODUCT_CAT_SET_ID = p_PRODUCT_CAT_SET_ID)
            OR (    ( Recinfo.PRODUCT_CAT_SET_ID IS NULL )
                AND (  p_PRODUCT_CAT_SET_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AS_PE_INT_CATEGORIES_PKG;

/
