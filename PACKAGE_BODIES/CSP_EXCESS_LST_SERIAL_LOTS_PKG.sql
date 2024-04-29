--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_LST_SERIAL_LOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_LST_SERIAL_LOTS_PKG" as
/* $Header: cspteslb.pls 115.6 2003/02/27 23:44:20 ajosephg ship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_LST_SERIAL_LOTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_EXCESS_LST_SERIAL_LOTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspteslb.pls';
G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
PROCEDURE Insert_Row(
          px_EXCESS_LIST_SERIAL_LOT_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER)
 IS
   CURSOR C2 IS SELECT CSP_EXCESS_LIST_SERIAL_LOTS_S1.nextval FROM sys.dual;
BEGIN
   If (px_EXCESS_LIST_SERIAL_LOT_ID IS NULL) OR (px_EXCESS_LIST_SERIAL_LOT_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_EXCESS_LIST_SERIAL_LOT_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_EXCESS_LIST_SERIAL_LOTS(
           EXCESS_LIST_SERIAL_LOT_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           EXCESS_LINE_ID,
           QUANTITY,
           LOT_NUMBER,
           SERIAL_NUMBER,
           REVISION,
           LOCATOR_ID
          ) VALUES (
           px_EXCESS_LIST_SERIAL_LOT_ID,
           G_USER_ID,
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           G_USER_ID,
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           G_LOGIN_ID,
           decode( p_EXCESS_LINE_ID, FND_API.G_MISS_NUM, NULL, p_EXCESS_LINE_ID),
           decode( p_QUANTITY, FND_API.G_MISS_NUM, NULL, p_QUANTITY),
           decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, NULL, p_LOT_NUMBER),
           decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, NULL, p_SERIAL_NUMBER),
           decode( p_REVISION, FND_API.G_MISS_CHAR, NULL, p_REVISION),
           decode( p_LOCATOR_ID, FND_API.G_MISS_NUM, NULL, p_LOCATOR_ID));

End Insert_Row;
PROCEDURE Update_Row(
          p_EXCESS_LIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER)

 IS
 BEGIN
    Update CSP_EXCESS_LIST_SERIAL_LOTS
    SET       CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = G_USER_ID,
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = G_LOGIN_ID,
              EXCESS_LINE_ID = decode( p_EXCESS_LINE_ID, FND_API.G_MISS_NUM, EXCESS_LINE_ID, p_EXCESS_LINE_ID),
              QUANTITY = decode( p_QUANTITY, FND_API.G_MISS_NUM, QUANTITY, p_QUANTITY),
              LOT_NUMBER = decode( p_LOT_NUMBER, FND_API.G_MISS_CHAR, LOT_NUMBER, p_LOT_NUMBER),
              SERIAL_NUMBER = decode( p_SERIAL_NUMBER, FND_API.G_MISS_CHAR, SERIAL_NUMBER, p_SERIAL_NUMBER),
              REVISION = decode( p_REVISION, FND_API.G_MISS_CHAR, REVISION, p_REVISION),
              LOCATOR_ID = decode( p_LOCATOR_ID, FND_API.G_MISS_NUM, LOCATOR_ID, p_LOCATOR_ID)
    where EXCESS_LIST_SERIAL_LOT_ID = p_EXCESS_LIST_SERIAL_LOT_ID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;
PROCEDURE Delete_Row(
    p_EXCESS_LIST_SERIAL_LOT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_EXCESS_LIST_SERIAL_LOTS
    WHERE EXCESS_LIST_SERIAL_LOT_ID = p_EXCESS_LIST_SERIAL_LOT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;
PROCEDURE Lock_Row(
          p_EXCESS_LIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_EXCESS_LIST_SERIAL_LOTS
        WHERE EXCESS_LIST_SERIAL_LOT_ID =  p_EXCESS_LIST_SERIAL_LOT_ID
        FOR UPDATE of EXCESS_LIST_SERIAL_LOT_ID NOWAIT;
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
           (      Recinfo.EXCESS_LIST_SERIAL_LOT_ID = p_EXCESS_LIST_SERIAL_LOT_ID)
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
       AND (    ( Recinfo.EXCESS_LINE_ID = p_EXCESS_LINE_ID)
            OR (    ( Recinfo.EXCESS_LINE_ID IS NULL )
                AND (  p_EXCESS_LINE_ID IS NULL )))
       AND (    ( Recinfo.QUANTITY = p_QUANTITY)
            OR (    ( Recinfo.QUANTITY IS NULL )
                AND (  p_QUANTITY IS NULL )))
       AND (    ( Recinfo.LOT_NUMBER = p_LOT_NUMBER)
            OR (    ( Recinfo.LOT_NUMBER IS NULL )
                AND (  p_LOT_NUMBER IS NULL )))
       AND (    ( Recinfo.SERIAL_NUMBER = p_SERIAL_NUMBER)
            OR (    ( Recinfo.SERIAL_NUMBER IS NULL )
                AND (  p_SERIAL_NUMBER IS NULL )))
       AND (    ( Recinfo.REVISION = p_REVISION)
            OR (    ( Recinfo.REVISION IS NULL )
                AND (  p_REVISION IS NULL )))
       AND (    ( Recinfo.LOCATOR_ID = p_LOCATOR_ID)
            OR (    ( Recinfo.LOCATOR_ID IS NULL )
                AND (  p_LOCATOR_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;
End CSP_EXCESS_LST_SERIAL_LOTS_PKG;

/
