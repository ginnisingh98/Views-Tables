--------------------------------------------------------
--  DDL for Package Body AMS_ITEM_OWNERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ITEM_OWNERS_PKG" as
/* $Header: amstinvb.pls 115.8 2002/11/11 22:05:09 abhola ship $ */
-- Start of Comments
-- Package name     : AMS_ITEM_OWNERS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ITEM_OWNERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstinvb.pls';

PROCEDURE Insert_Row(
          px_ITEM_OWNER_ID   IN OUT NOCOPY NUMBER,
          px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
                p_IS_MASTER_ITEM  VARCHAR2,
                p_ITEM_SETUP_TYPE VARCHAR2,
           p_custom_setup_id NUMBER)

 IS
X_ROWID    VARCHAR2(30);

   CURSOR C IS SELECT rowid FROM AMS_ITEM_ATTRIBUTES
            WHERE ITEM_OWNER_ID = px_ITEM_OWNER_ID;
   CURSOR C2 IS SELECT AMS_ITEM_ATTRIBUTES_S.nextval FROM sys.dual;

BEGIN

   IF (px_ITEM_OWNER_ID IS NULL) THEN
       OPEN C2;
        FETCH C2 INTO px_ITEM_OWNER_ID;
       CLOSE C2;
   END IF;

   IF (px_OBJECT_VERSION_NUMBER IS NULL OR
       px_OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM) THEN
       px_OBJECT_VERSION_NUMBER := 1;
   END IF;

   INSERT INTO AMS_ITEM_ATTRIBUTES(
           ITEM_OWNER_ID,
           OBJECT_VERSION_NUMBER,
           INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           ITEM_NUMBER,
           OWNER_ID,
           STATUS_CODE,
           EFFECTIVE_DATE,
                 IS_MASTER_ITEM,
                 ITEM_SETUP_TYPE,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
         custom_setup_id
          ) VALUES (
           decode( px_ITEM_OWNER_ID, FND_API.G_MISS_NUM, NULL, px_ITEM_OWNER_ID),
           decode( px_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, px_OBJECT_VERSION_NUMBER),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_ITEM_NUMBER, FND_API.G_MISS_CHAR, NULL, p_ITEM_NUMBER),
           decode( p_OWNER_ID, FND_API.G_MISS_NUM, NULL, p_OWNER_ID),
           decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
           decode( p_EFFECTIVE_DATE, FND_API.G_MISS_DATE, NULL, p_EFFECTIVE_DATE),
                 p_IS_MASTER_ITEM,
                 p_ITEM_SETUP_TYPE,
                 SYSDATE,
                 FND_GLOBAL.user_id,
                 SYSDATE,
                 FND_GLOBAL.user_id,
                 FND_GLOBAL.conc_login_id,
           decode(p_custom_setup_id,FND_API.G_MISS_NUM,1200,NULL,1200,p_custom_setup_id));
   OPEN C;
   FETCH C INTO x_rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;

PROCEDURE Update_Row(
          p_ITEM_OWNER_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
                p_IS_MASTER_ITEM  VARCHAR2,
                p_ITEM_SETUP_TYPE VARCHAR2)

 IS
 BEGIN
    Update AMS_ITEM_ATTRIBUTES
    SET
         ITEM_OWNER_ID = decode( p_ITEM_OWNER_ID, FND_API.G_MISS_NUM, ITEM_OWNER_ID, p_ITEM_OWNER_ID),
         OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
         INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
         ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
        ITEM_NUMBER = decode( p_ITEM_NUMBER, FND_API.G_MISS_CHAR, ITEM_NUMBER, p_ITEM_NUMBER),
        OWNER_ID = decode( p_OWNER_ID, FND_API.G_MISS_NUM, OWNER_ID, p_OWNER_ID),
        STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
        EFFECTIVE_DATE = decode( p_EFFECTIVE_DATE, FND_API.G_MISS_DATE, EFFECTIVE_DATE, p_EFFECTIVE_DATE),
           IS_MASTER_ITEM = p_IS_MASTER_ITEM,
           ITEM_SETUP_TYPE = p_ITEM_SETUP_TYPE,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.conc_login_id
    where ITEM_OWNER_ID = p_ITEM_OWNER_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_ITEM_OWNER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_ITEM_ATTRIBUTES
    WHERE ITEM_OWNER_ID = p_ITEM_OWNER_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_ITEM_OWNER_ID    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_ITEM_NUMBER    VARCHAR2,
          p_OWNER_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_EFFECTIVE_DATE    DATE,
                p_IS_MASTER_ITEM VARCHAR2,
                p_ITEM_SETUP_TYPE VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_ITEM_ATTRIBUTES
        WHERE ITEM_OWNER_ID =  p_ITEM_OWNER_ID
        FOR UPDATE of ITEM_OWNER_ID NOWAIT;
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
           (      Recinfo.ITEM_OWNER_ID = p_ITEM_OWNER_ID)
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.ITEM_NUMBER = p_ITEM_NUMBER)
            OR (    ( Recinfo.ITEM_NUMBER IS NULL )
                AND (  p_ITEM_NUMBER IS NULL )))
       AND (    ( Recinfo.OWNER_ID = p_OWNER_ID)
            OR (    ( Recinfo.OWNER_ID IS NULL )
                AND (  p_OWNER_ID IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.EFFECTIVE_DATE = p_EFFECTIVE_DATE)
            OR (    ( Recinfo.EFFECTIVE_DATE IS NULL )
                AND (  p_EFFECTIVE_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AMS_ITEM_OWNERS_PKG;

/
