--------------------------------------------------------
--  DDL for Package Body CSD_DC_DOMAINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DC_DOMAINS_PKG" as
/* $Header: csdtdcdb.pls 115.4 2003/11/05 00:14:16 gilam noship $ */
-- Start of Comments
-- Package name     : CSD_DC_DOMAINS_PKG
-- Purpose          : To insert, update, delete and lock dc domains
-- History          : 25-Aug-2003    Gilam          created
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_DC_DOMAINS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdtdcdb.pls';

PROCEDURE Insert_Row(
          px_DC_DOMAIN_ID   IN OUT NOCOPY NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_DIAGNOSTIC_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
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
         ,p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSD_DC_DOMAINS_S1.nextval FROM sys.dual;
BEGIN
   If (px_DC_DOMAIN_ID IS NULL) OR (px_DC_DOMAIN_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_DC_DOMAIN_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSD_DC_DOMAINS(
           DC_DOMAIN_ID
          ,OBJECT_VERSION_NUMBER
          ,DIAGNOSTIC_CODE_ID
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,DOMAIN_TYPE_CODE
          ,INVENTORY_ITEM_ID
          ,CATEGORY_ID
          ,CATEGORY_SET_ID
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
           px_DC_DOMAIN_ID
          ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
          ,decode( p_DIAGNOSTIC_CODE_ID, FND_API.G_MISS_NUM, NULL, p_DIAGNOSTIC_CODE_ID)
          ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
          ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
          ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
          ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
          ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
          ,decode( p_DOMAIN_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_DOMAIN_TYPE_CODE)
          ,decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID)
          ,decode( p_CATEGORY_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_ID)
          ,decode( p_CATEGORY_SET_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_SET_ID)
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
          ,decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15));
End Insert_Row;

PROCEDURE Update_Row(
          p_DC_DOMAIN_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_DIAGNOSTIC_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
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
         ,p_ATTRIBUTE15    VARCHAR2)

IS
BEGIN
    Update CSD_DC_DOMAINS
    SET
        OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
       ,DIAGNOSTIC_CODE_ID = decode( p_DIAGNOSTIC_CODE_ID, FND_API.G_MISS_NUM, NULL, NULL, DIAGNOSTIC_CODE_ID, p_DIAGNOSTIC_CODE_ID)
       ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, p_CREATED_BY)
       ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, p_CREATION_DATE)
       ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
       ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
       ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
       ,DOMAIN_TYPE_CODE = decode( p_DOMAIN_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, NULL, DOMAIN_TYPE_CODE, p_DOMAIN_TYPE_CODE)
       ,INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, NULL, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID)
       ,CATEGORY_ID = decode( p_CATEGORY_ID, FND_API.G_MISS_NUM, NULL, NULL, CATEGORY_ID, p_CATEGORY_ID)
       ,CATEGORY_SET_ID = decode( p_CATEGORY_SET_ID, FND_API.G_MISS_NUM, NULL, NULL, CATEGORY_SET_ID, p_CATEGORY_SET_ID)
       ,ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY)
       ,ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_ATTRIBUTE1)
       ,ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_ATTRIBUTE2)
       ,ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_ATTRIBUTE3)
       ,ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_ATTRIBUTE4)
       ,ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_ATTRIBUTE5)
       ,ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_ATTRIBUTE6)
       ,ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_ATTRIBUTE7)
       ,ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_ATTRIBUTE8)
       ,ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_ATTRIBUTE9)
       ,ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_ATTRIBUTE10)
       ,ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_ATTRIBUTE11)
       ,ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_ATTRIBUTE12)
       ,ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_ATTRIBUTE13)
       ,ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_ATTRIBUTE14)
       ,ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_ATTRIBUTE15)
    where DC_DOMAIN_ID = p_DC_DOMAIN_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_DC_DOMAIN_ID  NUMBER)
IS
BEGIN
    DELETE FROM CSD_DC_DOMAINS
    WHERE DC_DOMAIN_ID = p_DC_DOMAIN_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Delete_Row;

PROCEDURE Lock_Row(
          p_DC_DOMAIN_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER

         --commented out the rest of the record
         /*
         ,p_DIAGNOSTIC_CODE_ID    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_DOMAIN_TYPE_CODE    VARCHAR2
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_CATEGORY_ID    NUMBER
         ,p_CATEGORY_SET_ID    NUMBER
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
         */
         --
         )

 IS
   CURSOR C IS
       SELECT *
       FROM CSD_DC_DOMAINS
       WHERE DC_DOMAIN_ID =  p_DC_DOMAIN_ID
       FOR UPDATE of DC_DOMAIN_ID NOWAIT;
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
           (      Recinfo.DC_DOMAIN_ID = p_DC_DOMAIN_ID)
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))

       --commented out the rest of the record
       /*
       AND (    ( Recinfo.DIAGNOSTIC_CODE_ID = p_DIAGNOSTIC_CODE_ID)
            OR (    ( Recinfo.DIAGNOSTIC_CODE_ID IS NULL )
                AND (  p_DIAGNOSTIC_CODE_ID IS NULL )))
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
       AND (    ( Recinfo.DOMAIN_TYPE_CODE = p_DOMAIN_TYPE_CODE)
            OR (    ( Recinfo.DOMAIN_TYPE_CODE IS NULL )
                AND (  p_DOMAIN_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_ID = p_CATEGORY_ID)
            OR (    ( Recinfo.CATEGORY_ID IS NULL )
                AND (  p_CATEGORY_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_SET_ID = p_CATEGORY_SET_ID)
            OR (    ( Recinfo.CATEGORY_SET_ID IS NULL )
                AND (  p_CATEGORY_SET_ID IS NULL )))
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
       */
       --
        ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;

End CSD_DC_DOMAINS_PKG;

/
