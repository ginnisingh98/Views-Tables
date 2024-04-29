--------------------------------------------------------
--  DDL for Package Body AS_MC_REPORTING_CURR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_MC_REPORTING_CURR_PKG" as
/* $Header: asxtmrcb.pls 115.3 2002/11/06 00:54:45 appldev ship $ */
-- Start of Comments
-- Package name     : AS_MC_REPORTING_CURR_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_MC_REPORTING_CURR_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtmrcb.pls';

PROCEDURE Insert_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          px_SETUP_CURRENCY_ID   IN OUT NUMBER,
          p_SECURITY_GROUP_ID    NUMBER)

 IS
   CURSOR C2 IS SELECT AS_MC_REPORTING_CURR_S.nextval FROM sys.dual;
BEGIN
   If (px_SETUP_CURRENCY_ID IS NULL) OR (px_SETUP_CURRENCY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_SETUP_CURRENCY_ID;
       CLOSE C2;
   End If;
   INSERT INTO AS_MC_REPORTING_CURR(
           SETUP_CURRENCY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           FROM_CURRENCY,
           END_DATE_ACTIVE,
           REPORTING_CURRENCY,
           START_DATE_ACTIVE
--           SECURITY_GROUP_ID
          ) VALUES (
		 px_SETUP_CURRENCY_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_FROM_CURRENCY, FND_API.G_MISS_CHAR, NULL, p_FROM_CURRENCY),
           decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE),
           decode( p_REPORTING_CURRENCY, FND_API.G_MISS_CHAR, NULL, p_REPORTING_CURRENCY),
           decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE));
--           decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, NULL, p_SECURITY_GROUP_ID));
End Insert_Row;

PROCEDURE Update_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_SETUP_CURRENCY_ID    NUMBER,
          p_SECURITY_GROUP_ID    NUMBER)

 IS
 BEGIN
    Update AS_MC_REPORTING_CURR
    SET
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              FROM_CURRENCY = decode( p_FROM_CURRENCY, FND_API.G_MISS_CHAR, FROM_CURRENCY, p_FROM_CURRENCY),
              END_DATE_ACTIVE = decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, END_DATE_ACTIVE, p_END_DATE_ACTIVE),
              REPORTING_CURRENCY = decode( p_REPORTING_CURRENCY, FND_API.G_MISS_CHAR, REPORTING_CURRENCY, p_REPORTING_CURRENCY),
              START_DATE_ACTIVE = decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, START_DATE_ACTIVE, p_START_DATE_ACTIVE),
              SETUP_CURRENCY_ID = decode( p_SETUP_CURRENCY_ID, FND_API.G_MISS_NUM, SETUP_CURRENCY_ID, p_SETUP_CURRENCY_ID)
--              SECURITY_GROUP_ID = decode( p_SECURITY_GROUP_ID, FND_API.G_MISS_NUM, SECURITY_GROUP_ID, p_SECURITY_GROUP_ID)
    where SETUP_CURRENCY_ID = p_SETUP_CURRENCY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
END Update_Row;

PROCEDURE Delete_Row(
    p_SETUP_CURRENCY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_MC_REPORTING_CURR
    WHERE SETUP_CURRENCY_ID = p_SETUP_CURRENCY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_SETUP_CURRENCY_ID    NUMBER,
          p_SECURITY_GROUP_ID    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_MC_REPORTING_CURR
        WHERE SETUP_CURRENCY_ID =  p_SETUP_CURRENCY_ID
        FOR UPDATE of SETUP_CURRENCY_ID NOWAIT;
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
           (      Recinfo.CREATED_BY = p_CREATED_BY)
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
       AND (    ( Recinfo.FROM_CURRENCY = p_FROM_CURRENCY)
            OR (    ( Recinfo.FROM_CURRENCY IS NULL )
                AND (  p_FROM_CURRENCY IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  p_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.REPORTING_CURRENCY = p_REPORTING_CURRENCY)
            OR (    ( Recinfo.REPORTING_CURRENCY IS NULL )
                AND (  p_REPORTING_CURRENCY IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  p_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.SETUP_CURRENCY_ID = p_SETUP_CURRENCY_ID)
            OR (    ( Recinfo.SETUP_CURRENCY_ID IS NULL )
                AND (  p_SETUP_CURRENCY_ID IS NULL )))
--       AND (    ( Recinfo.SECURITY_GROUP_ID = p_SECURITY_GROUP_ID)
--            OR (    ( Recinfo.SECURITY_GROUP_ID IS NULL )
--                AND (  p_SECURITY_GROUP_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

End AS_MC_REPORTING_CURR_PKG;

/
