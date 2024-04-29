--------------------------------------------------------
--  DDL for Package Body CSP_PACKLIST_SERIAL_LOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PACKLIST_SERIAL_LOTS_PKG" AS
/* $Header: cspttspb.pls 115.5 2002/11/26 07:14:46 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_SERIAL_LOTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PACKLIST_SERIAL_LOTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspttspb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE Insert_Row(
          px_PACKLIST_SERIAL_LOT_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2)

 IS
   CURSOR C2 IS SELECT CSP_PACKLIST_SERIAL_LOTS_S1.nextval FROM sys.dual;
BEGIN
   If (px_PACKLIST_SERIAL_LOT_ID IS NULL) OR (px_PACKLIST_SERIAL_LOT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PACKLIST_SERIAL_LOT_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_PACKLIST_SERIAL_LOTS(
           PACKLIST_SERIAL_LOT_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           PACKLIST_LINE_ID,
           ORGANIZATION_ID,
           INVENTORY_ITEM_ID,
           QUANTITY,
           LOT_NUMBER,
           SERIAL_NUMBER
          ) VALUES (
           px_PACKLIST_SERIAL_LOT_ID,
           G_USER_ID,
           decode(p_CREATION_DATE,fnd_api.g_miss_date,to_date(null),p_creation_date),
           G_USER_ID,
           decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),p_last_update_date),
           G_LOGIN_ID,
           decode( p_PACKLIST_LINE_ID, FND_API.G_MISS_NUM, NULL, p_PACKLIST_LINE_ID),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, NULL, p_INVENTORY_ITEM_ID),
           decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
           decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, NULL, p_LOT_NUMBER),
           decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, p_SERIAL_NUMBER));
End Insert_Row;

PROCEDURE Update_Row(
          p_PACKLIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2)

 IS
 BEGIN
    Update CSP_PACKLIST_SERIAL_LOTS
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE =  decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = G_USER_ID,
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = G_LOGIN_ID,
              PACKLIST_LINE_ID = decode( p_PACKLIST_LINE_ID, FND_API.G_MISS_NUM, PACKLIST_LINE_ID, p_PACKLIST_LINE_ID),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              INVENTORY_ITEM_ID = decode( p_INVENTORY_ITEM_ID, FND_API.G_MISS_NUM, INVENTORY_ITEM_ID, p_INVENTORY_ITEM_ID),
              QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
              LOT_NUMBER = decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, LOT_NUMBER, p_LOT_NUMBER),
              SERIAL_NUMBER = decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, SERIAL_NUMBER, p_SERIAL_NUMBER)
    where PACKLIST_SERIAL_LOT_ID = p_PACKLIST_SERIAL_LOT_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_PACKLIST_SERIAL_LOT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_PACKLIST_SERIAL_LOTS
    WHERE PACKLIST_SERIAL_LOT_ID = p_PACKLIST_SERIAL_LOT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_PACKLIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_PACKLIST_SERIAL_LOTS
        WHERE PACKLIST_SERIAL_LOT_ID =  p_PACKLIST_SERIAL_LOT_ID
        FOR UPDATE of PACKLIST_SERIAL_LOT_ID NOWAIT;
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
           (      Recinfo.PACKLIST_SERIAL_LOT_ID = p_PACKLIST_SERIAL_LOT_ID)
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
       AND (    ( Recinfo.PACKLIST_LINE_ID = p_PACKLIST_LINE_ID)
            OR (    ( Recinfo.PACKLIST_LINE_ID IS NULL )
                AND (  p_PACKLIST_LINE_ID IS NULL )))
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.INVENTORY_ITEM_ID = p_INVENTORY_ITEM_ID)
            OR (    ( Recinfo.INVENTORY_ITEM_ID IS NULL )
                AND (  p_INVENTORY_ITEM_ID IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.LOT_NUMBER = p_LOT_NUMBER)
            OR (    ( Recinfo.LOT_NUMBER IS NULL )
                AND (  p_LOT_NUMBER IS NULL )))
       AND (    ( Recinfo.SERIAL_NUMBER = p_SERIAL_NUMBER)
            OR (    ( Recinfo.SERIAL_NUMBER IS NULL )
                AND (  p_SERIAL_NUMBER IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End CSP_PACKLIST_SERIAL_LOTS_PKG;

/