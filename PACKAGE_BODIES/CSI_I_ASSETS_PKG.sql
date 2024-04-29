--------------------------------------------------------
--  DDL for Package Body CSI_I_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_I_ASSETS_PKG" as
/* $Header: csitinab.pls 120.2 2005/06/08 13:52:25 appldev  $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_I_ASSETS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitinab.pls';

PROCEDURE Insert_Row(
          px_INSTANCE_ASSET_ID   IN OUT NOCOPY NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG   VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE)

 IS
   CURSOR C2 IS SELECT CSI_I_ASSETS_S.nextval FROM sys.dual;
BEGIN
   If (px_INSTANCE_ASSET_ID IS NULL) OR (px_INSTANCE_ASSET_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_INSTANCE_ASSET_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSI_I_ASSETS(
           INSTANCE_ASSET_ID,
           INSTANCE_ID,
           FA_ASSET_ID,
           FA_BOOK_TYPE_CODE,
           FA_LOCATION_ID,
           ASSET_QUANTITY,
           UPDATE_STATUS,
           FA_SYNC_FLAG,
           FA_MASS_ADDITION_ID,
           CREATION_COMPLETE_FLAG,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER,
           ACTIVE_START_DATE,
           ACTIVE_END_DATE
          ) VALUES (
           px_INSTANCE_ASSET_ID,
           decode( p_INSTANCE_ID, FND_API.G_MISS_NUM, NULL, p_INSTANCE_ID),
           decode( p_FA_ASSET_ID, FND_API.G_MISS_NUM, NULL, p_FA_ASSET_ID),
           decode( p_FA_BOOK_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, p_FA_BOOK_TYPE_CODE),
           decode( p_FA_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_FA_LOCATION_ID),
           decode( p_ASSET_QUANTITY, FND_API.G_MISS_NUM, NULL, p_ASSET_QUANTITY),
           decode( p_UPDATE_STATUS, FND_API.G_MISS_CHAR, NULL, p_UPDATE_STATUS),
           decode( p_fa_sync_flag, FND_API.G_MISS_CHAR, NULL, p_fa_sync_flag),
           decode( p_fa_mass_addition_id, FND_API.G_MISS_NUM, NULL, p_fa_mass_addition_id),
           decode( p_creation_complete_flag, FND_API.G_MISS_CHAR, NULL, p_creation_complete_flag),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER),
           decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_START_DATE),
           decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_END_DATE));
End Insert_Row;

PROCEDURE Update_Row(
          p_INSTANCE_ASSET_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG   VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE)

 IS
 BEGIN
    Update CSI_I_ASSETS
    SET
              INSTANCE_ID = decode( p_INSTANCE_ID, FND_API.G_MISS_NUM, INSTANCE_ID, p_INSTANCE_ID),
              FA_ASSET_ID = decode( p_FA_ASSET_ID, FND_API.G_MISS_NUM, FA_ASSET_ID, p_FA_ASSET_ID),
              FA_BOOK_TYPE_CODE = decode( p_FA_BOOK_TYPE_CODE, FND_API.G_MISS_CHAR, FA_BOOK_TYPE_CODE, p_FA_BOOK_TYPE_CODE),
              FA_LOCATION_ID = decode( p_FA_LOCATION_ID, FND_API.G_MISS_NUM, FA_LOCATION_ID, p_FA_LOCATION_ID),
              ASSET_QUANTITY = decode( p_ASSET_QUANTITY, FND_API.G_MISS_NUM, ASSET_QUANTITY, p_ASSET_QUANTITY),
              UPDATE_STATUS = decode( p_UPDATE_STATUS, FND_API.G_MISS_CHAR, UPDATE_STATUS, p_UPDATE_STATUS),
              fa_sync_flag = decode( p_fa_sync_flag, FND_API.G_MISS_CHAR, fa_sync_flag, p_fa_sync_flag),
              fa_mass_addition_id = decode( p_fa_mass_addition_id, FND_API.G_MISS_NUM, fa_mass_addition_id, p_fa_mass_addition_id),
              creation_complete_flag = decode( p_creation_complete_flag, FND_API.G_MISS_CHAR, creation_complete_flag, p_creation_complete_flag),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              ACTIVE_START_DATE = decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, ACTIVE_START_DATE, p_ACTIVE_START_DATE),
              ACTIVE_END_DATE = decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, ACTIVE_END_DATE, p_ACTIVE_END_DATE)
    where INSTANCE_ASSET_ID = p_INSTANCE_ASSET_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_INSTANCE_ASSET_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSI_I_ASSETS
    WHERE INSTANCE_ASSET_ID = p_INSTANCE_ASSET_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_INSTANCE_ASSET_ID    NUMBER,
          p_INSTANCE_ID    NUMBER,
          p_FA_ASSET_ID    NUMBER,
          p_FA_BOOK_TYPE_CODE    VARCHAR2,
          p_FA_LOCATION_ID    NUMBER,
          p_ASSET_QUANTITY    NUMBER,
          p_UPDATE_STATUS    VARCHAR2,
          P_FA_SYNC_FLAG   VARCHAR2,
          P_FA_MASS_ADDITION_ID    NUMBER,
          P_CREATION_COMPLETE_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE)

 IS
   CURSOR C IS
        SELECT *
         FROM CSI_I_ASSETS
        WHERE INSTANCE_ASSET_ID =  p_INSTANCE_ASSET_ID
        FOR UPDATE of INSTANCE_ASSET_ID NOWAIT;
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
           (      Recinfo.INSTANCE_ASSET_ID = p_INSTANCE_ASSET_ID)
       AND (    ( Recinfo.INSTANCE_ID = p_INSTANCE_ID)
            OR (    ( Recinfo.INSTANCE_ID IS NULL )
                AND (  p_INSTANCE_ID IS NULL )))
       AND (    ( Recinfo.FA_ASSET_ID = p_FA_ASSET_ID)
            OR (    ( Recinfo.FA_ASSET_ID IS NULL )
                AND (  p_FA_ASSET_ID IS NULL )))
       AND (    ( Recinfo.FA_BOOK_TYPE_CODE = p_FA_BOOK_TYPE_CODE)
            OR (    ( Recinfo.FA_BOOK_TYPE_CODE IS NULL )
                AND (  p_FA_BOOK_TYPE_CODE IS NULL )))
       AND (    ( Recinfo.FA_LOCATION_ID = p_FA_LOCATION_ID)
            OR (    ( Recinfo.FA_LOCATION_ID IS NULL )
                AND (  p_FA_LOCATION_ID IS NULL )))
       AND (    ( Recinfo.ASSET_QUANTITY = p_ASSET_QUANTITY)
            OR (    ( Recinfo.ASSET_QUANTITY IS NULL )
                AND (  p_ASSET_QUANTITY IS NULL )))
       AND (    ( Recinfo.UPDATE_STATUS = p_UPDATE_STATUS)
            OR (    ( Recinfo.UPDATE_STATUS IS NULL )
                AND (  p_UPDATE_STATUS IS NULL )))
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
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.ACTIVE_START_DATE = p_ACTIVE_START_DATE)
            OR (    ( Recinfo.ACTIVE_START_DATE IS NULL )
                AND (  p_ACTIVE_START_DATE IS NULL )))
       AND (    ( Recinfo.ACTIVE_END_DATE = p_ACTIVE_END_DATE)
            OR (    ( Recinfo.ACTIVE_END_DATE IS NULL )
                AND (  p_ACTIVE_END_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSI_I_ASSETS_PKG;


/
