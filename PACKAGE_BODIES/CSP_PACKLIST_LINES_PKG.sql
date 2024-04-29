--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_LINES_PKG" AS
/* $Header: cspttalb.pls 115.7 2002/11/26 07:38:51 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_LINES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PACKLIST_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspttalb.pls';
G_USER_ID   NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID  NUMBER := FND_GLOBAL.LOGIN_ID;

PROCEDURE Insert_Row(
          px_PACKLIST_LINE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER)

 IS
   CURSOR C2 IS SELECT CSP_PACKLIST_LINES_S1.nextval FROM sys.dual;
BEGIN
   If (px_PACKLIST_LINE_ID IS NULL) OR (px_PACKLIST_LINE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PACKLIST_LINE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_PACKLIST_LINES(
           PACKLIST_LINE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PACKLIST_LINE_NUMBER,
           PACKLIST_HEADER_ID,
           BOX_ID,
           PICKLIST_LINE_ID,
           PACKLIST_LINE_STATUS,
           INVENTORY_ITEM_ID,
           QUANTITY_PACKED,
           QUANTITY_SHIPPED,
           QUANTITY_RECEIVED,
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
           UOM_CODE,
           LINE_ID
          ) VALUES (
           px_PACKLIST_LINE_ID,
           G_USER_ID,  --decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE,fnd_api.g_miss_date,to_date(null),p_creation_date),
           G_USER_ID, -- decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),p_last_update_date),
           G_LOGIN_ID, -- decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_PACKLIST_LINE_NUMBER, FND_API.G_MISS_NUM, NULL, p_PACKLIST_LINE_NUMBER),
           decode( p_PACKLIST_HEADER_ID, FND_API.G_MISS_NUM, NULL, p_PACKLIST_HEADER_ID),
           decode( p_BOX_ID, FND_API.G_MISS_NUM, NULL, p_BOX_ID),
           decode( p_PICKLIST_LINE_ID, FND_API.G_MISS_NUM, NULL, p_PICKLIST_LINE_ID),
           decode( p_PACKLIST_LINE_STATUS, FND_API.G_MISS_CHAR, NULL, p_PACKLIST_LINE_STATUS),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_QUANTITY_PACKED, FND_API.G_MISS_NUM, NULL, p_QUANTITY_PACKED),
           decode( p_QUANTITY_SHIPPED, FND_API.G_MISS_NUM, NULL, p_QUANTITY_SHIPPED),
           decode( p_QUANTITY_RECEIVED, FND_API.G_MISS_NUM, NULL, p_QUANTITY_RECEIVED),
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
           decode( p_UOM_CODE, FND_API.G_MISS_CHAR, NULL, p_UOM_CODE),
           decode( p_LINE_ID, FND_API.G_MISS_NUM, NULL, p_LINE_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_PACKLIST_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER)

 IS
 BEGIN
    Update CSP_PACKLIST_LINES
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              PACKLIST_LINE_NUMBER = decode( p_PACKLIST_LINE_NUMBER, FND_API.G_MISS_NUM, PACKLIST_LINE_NUMBER, p_PACKLIST_LINE_NUMBER),
              PACKLIST_HEADER_ID = decode( p_PACKLIST_HEADER_ID, FND_API.G_MISS_NUM, PACKLIST_HEADER_ID, p_PACKLIST_HEADER_ID),
              BOX_ID = decode( p_BOX_ID, FND_API.G_MISS_NUM, BOX_ID, p_BOX_ID),
              PICKLIST_LINE_ID = decode( p_PICKLIST_LINE_ID, FND_API.G_MISS_NUM, PICKLIST_LINE_ID, p_PICKLIST_LINE_ID),
              PACKLIST_LINE_STATUS = decode( p_PACKLIST_LINE_STATUS, FND_API.G_MISS_CHAR, PACKLIST_LINE_STATUS, p_PACKLIST_LINE_STATUS),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              QUANTITY_PACKED = decode( p_QUANTITY_PACKED, FND_API.G_MISS_NUM, QUANTITY_PACKED, p_QUANTITY_PACKED),
              QUANTITY_SHIPPED = decode( p_QUANTITY_SHIPPED, FND_API.G_MISS_NUM, QUANTITY_SHIPPED, p_QUANTITY_SHIPPED),
              QUANTITY_RECEIVED = decode( p_QUANTITY_RECEIVED, FND_API.G_MISS_NUM, QUANTITY_RECEIVED, p_QUANTITY_RECEIVED),
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
              UOM_CODE = decode( p_UOM_CODE, FND_API.G_MISS_CHAR, UOM_CODE, p_UOM_CODE),
              LINE_ID = decode( p_LINE_ID, FND_API.G_MISS_NUM, LINE_ID, p_LINE_ID)
    where PACKLIST_LINE_ID = p_PACKLIST_LINE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PACKLIST_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_PACKLIST_LINES
    WHERE PACKLIST_LINE_ID = p_PACKLIST_LINE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PACKLIST_LINE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PACKLIST_LINE_NUMBER    NUMBER,
          p_PACKLIST_HEADER_ID    NUMBER,
          p_BOX_ID    NUMBER,
          p_PICKLIST_LINE_ID    NUMBER,
          p_PACKLIST_LINE_STATUS    VARCHAR2,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY_PACKED    NUMBER,
          p_QUANTITY_SHIPPED    NUMBER,
          p_QUANTITY_RECEIVED    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_UOM_CODE    VARCHAR2,
          p_LINE_ID    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_PACKLIST_LINES
        WHERE PACKLIST_LINE_ID =  p_PACKLIST_LINE_ID
        FOR UPDATE of PACKLIST_LINE_ID NOWAIT;
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
           (      Recinfo.PACKLIST_LINE_ID = p_PACKLIST_LINE_ID)
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
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.PACKLIST_LINE_NUMBER = p_PACKLIST_LINE_NUMBER)
            OR (    ( Recinfo.PACKLIST_LINE_NUMBER IS NULL )
                AND (  p_PACKLIST_LINE_NUMBER IS NULL )))
       AND (    ( Recinfo.PACKLIST_HEADER_ID = p_PACKLIST_HEADER_ID)
            OR (    ( Recinfo.PACKLIST_HEADER_ID IS NULL )
                AND (  p_PACKLIST_HEADER_ID IS NULL )))
       AND (    ( Recinfo.BOX_ID = p_BOX_ID)
            OR (    ( Recinfo.BOX_ID IS NULL )
                AND (  p_BOX_ID IS NULL )))
       AND (    ( Recinfo.PICKLIST_LINE_ID = p_PICKLIST_LINE_ID)
            OR (    ( Recinfo.PICKLIST_LINE_ID IS NULL )
                AND (  p_PICKLIST_LINE_ID IS NULL )))
       AND (    ( Recinfo.PACKLIST_LINE_STATUS = p_PACKLIST_LINE_STATUS)
            OR (    ( Recinfo.PACKLIST_LINE_STATUS IS NULL )
                AND (  p_PACKLIST_LINE_STATUS IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.QUANTITY_PACKED = p_QUANTITY_PACKED)
            OR (    ( Recinfo.QUANTITY_PACKED IS NULL )
                AND (  p_QUANTITY_PACKED IS NULL )))
       AND (    ( Recinfo.QUANTITY_SHIPPED = p_QUANTITY_SHIPPED)
            OR (    ( Recinfo.QUANTITY_SHIPPED IS NULL )
                AND (  p_QUANTITY_SHIPPED IS NULL )))
       AND (    ( Recinfo.QUANTITY_RECEIVED = p_QUANTITY_RECEIVED)
            OR (    ( Recinfo.QUANTITY_RECEIVED IS NULL )
                AND (  p_QUANTITY_RECEIVED IS NULL )))
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
       AND (    ( Recinfo.UOM_CODE = p_UOM_CODE)
            OR (    ( Recinfo.UOM_CODE IS NULL )
                AND (  p_UOM_CODE IS NULL )))
       AND (    ( Recinfo.LINE_ID = p_LINE_ID)
            OR (    ( Recinfo.LINE_ID IS NULL )
                AND (  p_LINE_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_PACKLIST_LINES_PKG;

/
