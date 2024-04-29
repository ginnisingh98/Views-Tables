--------------------------------------------------------
--  DDL for Package Body HZ_STOCK_MARKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STOCK_MARKETS_PKG" as
/* $Header: ARHOSMTB.pls 120.3 2005/10/30 04:21:14 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid           IN OUT NOCOPY        VARCHAR2,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_STOCK_MARKETS
            WHERE STOCK_EXCHANGE_ID = x_STOCK_EXCHANGE_ID;
BEGIN
   INSERT INTO HZ_STOCK_MARKETS(
           STOCK_EXCHANGE_ID,
           COUNTRY_OF_RESIDENCE,
           STOCK_EXCHANGE_CODE,
           STOCK_EXCHANGE_NAME,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           WH_UPDATE_DATE
          ) VALUES (
          x_STOCK_EXCHANGE_ID,
           decode( x_COUNTRY_OF_RESIDENCE, FND_API.G_MISS_CHAR, NULL,x_COUNTRY_OF_RESIDENCE),
           decode( x_STOCK_EXCHANGE_CODE, FND_API.G_MISS_CHAR, NULL,x_STOCK_EXCHANGE_CODE),
           decode( x_STOCK_EXCHANGE_NAME, FND_API.G_MISS_CHAR, NULL,x_STOCK_EXCHANGE_NAME),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE),
           decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_WH_UPDATE_DATE));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_STOCK_EXCHANGE_ID             NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_STOCK_MARKETS
    WHERE STOCK_EXCHANGE_ID = x_STOCK_EXCHANGE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid          IN OUT NOCOPY         VARCHAR2,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
 BEGIN
    Update HZ_STOCK_MARKETS
    SET
             STOCK_EXCHANGE_ID = decode( x_STOCK_EXCHANGE_ID, FND_API.G_MISS_NUM,STOCK_EXCHANGE_ID,x_STOCK_EXCHANGE_ID),
             COUNTRY_OF_RESIDENCE = decode( x_COUNTRY_OF_RESIDENCE, FND_API.G_MISS_CHAR,COUNTRY_OF_RESIDENCE,x_COUNTRY_OF_RESIDENCE),
             STOCK_EXCHANGE_CODE = decode( x_STOCK_EXCHANGE_CODE, FND_API.G_MISS_CHAR,STOCK_EXCHANGE_CODE,x_STOCK_EXCHANGE_CODE),
             STOCK_EXCHANGE_NAME = decode( x_STOCK_EXCHANGE_NAME, FND_API.G_MISS_CHAR,STOCK_EXCHANGE_NAME,x_STOCK_EXCHANGE_NAME),
             -- Bug 3032780
             /*
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             */
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,REQUEST_ID,x_REQUEST_ID),
             PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,x_PROGRAM_APPLICATION_ID),
             PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,PROGRAM_ID,x_PROGRAM_ID),
             PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,x_PROGRAM_UPDATE_DATE),
             WH_UPDATE_DATE = decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE,WH_UPDATE_DATE,x_WH_UPDATE_DATE)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_COUNTRY_OF_RESIDENCE          VARCHAR2,
                  x_STOCK_EXCHANGE_CODE           VARCHAR2,
                  x_STOCK_EXCHANGE_NAME           VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_STOCK_MARKETS
         WHERE rowid = x_Rowid
         FOR UPDATE of STOCK_EXCHANGE_ID NOWAIT;
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
           (    ( Recinfo.STOCK_EXCHANGE_ID = x_STOCK_EXCHANGE_ID)
            OR (    ( Recinfo.STOCK_EXCHANGE_ID = NULL )
                AND (  x_STOCK_EXCHANGE_ID = NULL )))
       AND (    ( Recinfo.COUNTRY_OF_RESIDENCE = x_COUNTRY_OF_RESIDENCE)
            OR (    ( Recinfo.COUNTRY_OF_RESIDENCE = NULL )
                AND (  x_COUNTRY_OF_RESIDENCE = NULL )))
       AND (    ( Recinfo.STOCK_EXCHANGE_CODE = x_STOCK_EXCHANGE_CODE)
            OR (    ( Recinfo.STOCK_EXCHANGE_CODE = NULL )
                AND (  x_STOCK_EXCHANGE_CODE = NULL )))
       AND (    ( Recinfo.STOCK_EXCHANGE_NAME = x_STOCK_EXCHANGE_NAME)
            OR (    ( Recinfo.STOCK_EXCHANGE_NAME = NULL )
                AND (  x_STOCK_EXCHANGE_NAME = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID = NULL )
                AND (  x_REQUEST_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID = NULL )
                AND (  x_PROGRAM_APPLICATION_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID = NULL )
                AND (  x_PROGRAM_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE = NULL )
                AND (  x_PROGRAM_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.WH_UPDATE_DATE = x_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE = NULL )
                AND (  x_WH_UPDATE_DATE = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_STOCK_MARKETS_PKG;

/
