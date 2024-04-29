--------------------------------------------------------
--  DDL for Package Body CSP_SEC_INVENTORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_SEC_INVENTORIES_PKG" as
/* $Header: csptpseb.pls 120.0 2005/05/24 18:35:18 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_SEC_INVENTORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_SEC_INVENTORIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptecib.pls';

PROCEDURE Insert_Row(
          px_SECONDARY_INVENTORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_SEC_INVENTORIES_S1.nextval FROM sys.dual;
BEGIN
   If (px_SECONDARY_INVENTORY_ID IS NULL) OR (px_SECONDARY_INVENTORY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_SECONDARY_INVENTORY_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_SEC_INVENTORIES(
           SECONDARY_INVENTORY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PARTS_LOOP_ID,
           HIERARCHY_NODE_ID,
           SECONDARY_INVENTORY_NAME,
           LOCATION_ID,
           CONDITION_TYPE,
           AUTORECEIPT_FLAG,
           SPARES_LOCATION_FLAG,
           OWNER_RESOURCE_TYPE,
           OWNER_RESOURCE_ID,
           RETURN_ORGANIZATION_ID,
           RETURN_SUBINVENTORY_NAME,
           GROUP_ID,
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
           px_SECONDARY_INVENTORY_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE, fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE, fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, NULL, p_PARTS_LOOP_ID),
           decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, NULL, p_HIERARCHY_NODE_ID),
           decode( p_SECONDARY_INVENTORY_NAME, FND_API.G_MISS_CHAR, NULL, p_SECONDARY_INVENTORY_NAME),
           decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
           decode( p_CONDITION_TYPE, FND_API.G_MISS_CHAR, NULL, p_CONDITION_TYPE),
           decode( p_AUTORECEIPT_FLAG, FND_API.G_MISS_CHAR, NULL, p_AUTORECEIPT_FLAG),
           decode( p_SPARES_LOCATION_FLAG, FND_API.G_MISS_CHAR, NULL, p_SPARES_LOCATION_FLAG),
           decode( p_OWNER_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, p_OWNER_RESOURCE_TYPE),
           decode( p_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_RESOURCE_ID),
           decode( p_RETURN_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_RETURN_ORGANIZATION_ID),
           decode( p_RETURN_SUBINVENTORY_NAME, FND_API.G_MISS_CHAR, NULL, p_RETURN_SUBINVENTORY_NAME),
           decode( p_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_GROUP_ID),
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
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15));
End Insert_Row;

PROCEDURE Update_Row(
          p_SECONDARY_INVENTORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
 BEGIN
    Update CSP_SEC_INVENTORIES
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_creation_date,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE, fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              PARTS_LOOP_ID = decode( p_PARTS_LOOP_ID, FND_API.G_MISS_NUM, PARTS_LOOP_ID, p_PARTS_LOOP_ID),
              HIERARCHY_NODE_ID = decode( p_HIERARCHY_NODE_ID, FND_API.G_MISS_NUM, HIERARCHY_NODE_ID, p_HIERARCHY_NODE_ID),
              SECONDARY_INVENTORY_NAME = decode( p_SECONDARY_INVENTORY_NAME, FND_API.G_MISS_CHAR, SECONDARY_INVENTORY_NAME, p_SECONDARY_INVENTORY_NAME),
              LOCATION_ID = decode( p_LOCATION_ID, FND_API.G_MISS_NUM, LOCATION_ID, p_LOCATION_ID),
              CONDITION_TYPE = decode( p_CONDITION_TYPE, FND_API.G_MISS_CHAR, CONDITION_TYPE, p_CONDITION_TYPE),
              AUTORECEIPT_FLAG = decode( p_AUTORECEIPT_FLAG, FND_API.G_MISS_CHAR, AUTORECEIPT_FLAG, p_AUTORECEIPT_FLAG),
              SPARES_LOCATION_FLAG = decode( p_SPARES_LOCATION_FLAG, FND_API.G_MISS_CHAR, SPARES_LOCATION_FLAG, p_SPARES_LOCATION_FLAG),
              OWNER_RESOURCE_TYPE = decode( p_OWNER_RESOURCE_TYPE, FND_API.G_MISS_CHAR, OWNER_RESOURCE_TYPE, p_OWNER_RESOURCE_TYPE),
              OWNER_RESOURCE_ID = decode( p_OWNER_RESOURCE_ID, FND_API.G_MISS_NUM, OWNER_RESOURCE_ID, p_OWNER_RESOURCE_ID),
              RETURN_ORGANIZATION_ID = decode( p_RETURN_ORGANIZATION_ID, FND_API.G_MISS_NUM, RETURN_ORGANIZATION_ID, p_RETURN_ORGANIZATION_ID),
              RETURN_SUBINVENTORY_NAME = decode( p_RETURN_SUBINVENTORY_NAME, FND_API.G_MISS_CHAR, RETURN_SUBINVENTORY_NAME, p_RETURN_SUBINVENTORY_NAME),
              GROUP_ID = decode( p_GROUP_ID, FND_API.G_MISS_NUM, GROUP_ID, p_GROUP_ID),
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
    where SECONDARY_INVENTORY_ID = p_SECONDARY_INVENTORY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_SECONDARY_INVENTORY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_SEC_INVENTORIES
    WHERE SECONDARY_INVENTORY_ID = p_SECONDARY_INVENTORY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_SECONDARY_INVENTORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PARTS_LOOP_ID    NUMBER,
          p_HIERARCHY_NODE_ID    NUMBER,
          p_SECONDARY_INVENTORY_NAME    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_CONDITION_TYPE    VARCHAR2,
          p_AUTORECEIPT_FLAG    VARCHAR2,
          p_SPARES_LOCATION_FLAG    VARCHAR2,
          p_OWNER_RESOURCE_TYPE        VARCHAR2,
          p_OWNER_RESOURCE_ID          NUMBER,
          p_RETURN_ORGANIZATION_ID     NUMBER,
          p_RETURN_SUBINVENTORY_NAME   VARCHAR2,
          p_GROUP_ID NUMBER,
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
          p_ATTRIBUTE15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_SEC_INVENTORIES
        WHERE SECONDARY_INVENTORY_ID =  p_SECONDARY_INVENTORY_ID
        FOR UPDATE of SECONDARY_INVENTORY_ID NOWAIT;
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
           (      Recinfo.SECONDARY_INVENTORY_ID = p_SECONDARY_INVENTORY_ID)
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
       AND (    ( Recinfo.PARTS_LOOP_ID = p_PARTS_LOOP_ID)
            OR (    ( Recinfo.PARTS_LOOP_ID IS NULL )
                AND (  p_PARTS_LOOP_ID IS NULL )))
       AND (    ( Recinfo.HIERARCHY_NODE_ID = p_HIERARCHY_NODE_ID)
            OR (    ( Recinfo.HIERARCHY_NODE_ID IS NULL )
                AND (  p_HIERARCHY_NODE_ID IS NULL )))
       AND (    ( Recinfo.SECONDARY_INVENTORY_NAME = p_SECONDARY_INVENTORY_NAME)
            OR (    ( Recinfo.SECONDARY_INVENTORY_NAME IS NULL )
                AND (  p_SECONDARY_INVENTORY_NAME IS NULL )))
       /*AND (    ( Recinfo.LOCATION_ID = p_LOCATION_ID)
            OR (    ( Recinfo.LOCATION_ID IS NULL )
                AND (  p_LOCATION_ID IS NULL ))) */
       AND (    ( Recinfo.CONDITION_TYPE = p_CONDITION_TYPE)
            OR (    ( Recinfo.CONDITION_TYPE IS NULL )
                AND (  p_CONDITION_TYPE IS NULL )))
       AND (    ( Recinfo.AUTORECEIPT_FLAG = p_AUTORECEIPT_FLAG)
            OR (    ( Recinfo.AUTORECEIPT_FLAG IS NULL )
                AND (  p_AUTORECEIPT_FLAG IS NULL )))
       AND (    ( Recinfo.SPARES_LOCATION_FLAG = p_SPARES_LOCATION_FLAG)
            OR (    ( Recinfo.SPARES_LOCATION_FLAG IS NULL )
                AND (  p_SPARES_LOCATION_FLAG IS NULL )))
       AND (    ( Recinfo.OWNER_RESOURCE_TYPE = p_OWNER_RESOURCE_TYPE)
            OR (    ( Recinfo.OWNER_RESOURCE_TYPE IS NULL )
                AND (  p_OWNER_RESOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.OWNER_RESOURCE_ID = p_OWNER_RESOURCE_ID)
            OR (    ( Recinfo.OWNER_RESOURCE_ID IS NULL )
                AND (  p_OWNER_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.RETURN_ORGANIZATION_ID = p_RETURN_ORGANIZATION_ID)
            OR (    ( Recinfo.RETURN_ORGANIZATION_ID IS NULL )
                AND (  p_RETURN_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.RETURN_SUBINVENTORY_NAME = p_RETURN_SUBINVENTORY_NAME)
            OR (    ( Recinfo.RETURN_SUBINVENTORY_NAME IS NULL )
                AND (  p_RETURN_SUBINVENTORY_NAME IS NULL )))
       AND (    ( Recinfo.GROUP_ID = p_GROUP_ID)
            OR (    ( Recinfo.GROUP_ID IS NULL )
                AND (  p_GROUP_ID IS NULL )))
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

End CSP_SEC_INVENTORIES_PKG;

/
