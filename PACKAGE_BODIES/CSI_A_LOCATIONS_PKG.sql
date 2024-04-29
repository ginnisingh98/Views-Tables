--------------------------------------------------------
--  DDL for Package Body CSI_A_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_A_LOCATIONS_PKG" as
/* $Header: csitlocb.pls 115.7 2002/11/12 00:22:56 rmamidip noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_A_LOCATIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csitlocb.pls';

PROCEDURE Insert_Row(
          px_ASSET_LOCATION_ID   IN OUT NOCOPY NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER)
 IS
   CURSOR C2 IS SELECT CSI_A_LOCATIONS_S.nextval FROM sys.dual;
BEGIN
   If (px_ASSET_LOCATION_ID IS NULL) OR (px_ASSET_LOCATION_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_ASSET_LOCATION_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSI_A_LOCATIONS(
           ASSET_LOCATION_ID,
           FA_LOCATION_ID,
           LOCATION_TABLE,
           LOCATION_ID,
           ACTIVE_START_DATE,
           ACTIVE_END_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           px_ASSET_LOCATION_ID,
           decode( p_FA_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_FA_LOCATION_ID),
           decode( p_LOCATION_TABLE, FND_API.G_MISS_CHAR, NULL, p_LOCATION_TABLE),
           decode( p_LOCATION_ID, FND_API.G_MISS_NUM, NULL, p_LOCATION_ID),
           decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_START_DATE),
           decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_ACTIVE_END_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER));
End Insert_Row;

PROCEDURE Update_Row(
          p_ASSET_LOCATION_ID    NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER)
 IS
 BEGIN
    Update CSI_A_LOCATIONS
    SET
              FA_LOCATION_ID = decode( p_FA_LOCATION_ID, FND_API.G_MISS_NUM, FA_LOCATION_ID, p_FA_LOCATION_ID),
              LOCATION_TABLE = decode( p_LOCATION_TABLE, FND_API.G_MISS_CHAR, LOCATION_TABLE, p_LOCATION_TABLE),
              LOCATION_ID = decode( p_LOCATION_ID, FND_API.G_MISS_NUM, LOCATION_ID, p_LOCATION_ID),
              ACTIVE_START_DATE = decode( p_ACTIVE_START_DATE, FND_API.G_MISS_DATE, ACTIVE_START_DATE, p_ACTIVE_START_DATE),
              ACTIVE_END_DATE = decode( p_ACTIVE_END_DATE, FND_API.G_MISS_DATE, ACTIVE_END_DATE, p_ACTIVE_END_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
    where ASSET_LOCATION_ID = p_ASSET_LOCATION_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_ASSET_LOCATION_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSI_A_LOCATIONS
    WHERE ASSET_LOCATION_ID = p_ASSET_LOCATION_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_ASSET_LOCATION_ID    NUMBER,
          p_FA_LOCATION_ID    NUMBER,
          p_LOCATION_TABLE    VARCHAR2,
          p_LOCATION_ID    NUMBER,
          p_ACTIVE_START_DATE    DATE,
          p_ACTIVE_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM CSI_A_LOCATIONS
        WHERE ASSET_LOCATION_ID =  p_ASSET_LOCATION_ID
        FOR UPDATE of ASSET_LOCATION_ID NOWAIT;
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
           (      Recinfo.ASSET_LOCATION_ID = p_ASSET_LOCATION_ID)
       AND (    ( Recinfo.FA_LOCATION_ID = p_FA_LOCATION_ID)
            OR (    ( Recinfo.FA_LOCATION_ID IS NULL )
                AND (  p_FA_LOCATION_ID IS NULL )))
       AND (    ( Recinfo.LOCATION_TABLE = p_LOCATION_TABLE)
            OR (    ( Recinfo.LOCATION_TABLE IS NULL )
                AND (  p_LOCATION_TABLE IS NULL )))
       AND (    ( Recinfo.LOCATION_ID = p_LOCATION_ID)
            OR (    ( Recinfo.LOCATION_ID IS NULL )
                AND (  p_LOCATION_ID IS NULL )))
       AND (    ( Recinfo.ACTIVE_START_DATE = p_ACTIVE_START_DATE)
            OR (    ( Recinfo.ACTIVE_START_DATE IS NULL )
                AND (  p_ACTIVE_START_DATE IS NULL )))
       AND (    ( Recinfo.ACTIVE_END_DATE = p_ACTIVE_END_DATE)
            OR (    ( Recinfo.ACTIVE_END_DATE IS NULL )
                AND (  p_ACTIVE_END_DATE IS NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSI_A_LOCATIONS_PKG;


/
