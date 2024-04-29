--------------------------------------------------------
--  DDL for Package Body HZ_SECURITY_ISSUED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_SECURITY_ISSUED_PKG" as
/* $Header: ARHOSITB.pls 120.3 2005/10/30 04:21:12 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid         IN OUT NOCOPY          VARCHAR2,
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                         VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_SECURITY_ISSUED
            WHERE SECURITY_ISSUED_ID = x_SECURITY_ISSUED_ID;
BEGIN
   INSERT INTO HZ_SECURITY_ISSUED(
           SECURITY_ISSUED_ID,
           ESTIMATED_TOTAL_AMOUNT,
           PARTY_ID,
           STOCK_EXCHANGE_ID,
           SECURITY_ISSUED_CLASS,
           SECURITY_ISSUED_NAME,
           TOTAL_AMOUNT_IN_A_CURRENCY,
           STOCK_TICKER_SYMBOL,
           SECURITY_CURRENCY_CODE,
           BEGIN_DATE,
           END_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           WH_UPDATE_DATE,
           STATUS
          ) VALUES (
          x_SECURITY_ISSUED_ID,
           decode( x_ESTIMATED_TOTAL_AMOUNT, FND_API.G_MISS_NUM, NULL,x_ESTIMATED_TOTAL_AMOUNT),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_STOCK_EXCHANGE_ID, FND_API.G_MISS_NUM, NULL,x_STOCK_EXCHANGE_ID),
           decode( x_SECURITY_ISSUED_CLASS, FND_API.G_MISS_CHAR, NULL,x_SECURITY_ISSUED_CLASS),
           decode( x_SECURITY_ISSUED_NAME, FND_API.G_MISS_CHAR, NULL,x_SECURITY_ISSUED_NAME),
           decode( x_TOTAL_AMOUNT_IN_A_CURRENCY, FND_API.G_MISS_CHAR, NULL,x_TOTAL_AMOUNT_IN_A_CURRENCY),
           decode( x_STOCK_TICKER_SYMBOL, FND_API.G_MISS_CHAR, NULL,x_STOCK_TICKER_SYMBOL),
           decode( x_SECURITY_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL,x_SECURITY_CURRENCY_CODE),
           decode( x_BEGIN_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_BEGIN_DATE),
           decode( x_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE),
           decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_WH_UPDATE_DATE),
           decode(x_STATUS,FND_API.G_MISS_CHAR,'A',x_STATUS));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_SECURITY_ISSUED_ID            NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_SECURITY_ISSUED
    WHERE SECURITY_ISSUED_ID = x_SECURITY_ISSUED_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid         IN OUT NOCOPY          VARCHAR2,
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                        VARCHAR2
 ) IS
 BEGIN
    Update HZ_SECURITY_ISSUED
    SET
             SECURITY_ISSUED_ID = decode( x_SECURITY_ISSUED_ID, FND_API.G_MISS_NUM,SECURITY_ISSUED_ID,x_SECURITY_ISSUED_ID),
             ESTIMATED_TOTAL_AMOUNT = decode( x_ESTIMATED_TOTAL_AMOUNT, FND_API.G_MISS_NUM,ESTIMATED_TOTAL_AMOUNT,x_ESTIMATED_TOTAL_AMOUNT),
             PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,PARTY_ID,x_PARTY_ID),
             STOCK_EXCHANGE_ID = decode( x_STOCK_EXCHANGE_ID, FND_API.G_MISS_NUM,STOCK_EXCHANGE_ID,x_STOCK_EXCHANGE_ID),
             SECURITY_ISSUED_CLASS = decode( x_SECURITY_ISSUED_CLASS, FND_API.G_MISS_CHAR,SECURITY_ISSUED_CLASS,x_SECURITY_ISSUED_CLASS),
             SECURITY_ISSUED_NAME = decode( x_SECURITY_ISSUED_NAME, FND_API.G_MISS_CHAR,SECURITY_ISSUED_NAME,x_SECURITY_ISSUED_NAME),
             TOTAL_AMOUNT_IN_A_CURRENCY = decode( x_TOTAL_AMOUNT_IN_A_CURRENCY, FND_API.G_MISS_CHAR,TOTAL_AMOUNT_IN_A_CURRENCY,x_TOTAL_AMOUNT_IN_A_CURRENCY),
             STOCK_TICKER_SYMBOL = decode( x_STOCK_TICKER_SYMBOL, FND_API.G_MISS_CHAR,STOCK_TICKER_SYMBOL,x_STOCK_TICKER_SYMBOL),
             SECURITY_CURRENCY_CODE = decode( x_SECURITY_CURRENCY_CODE, FND_API.G_MISS_CHAR,SECURITY_CURRENCY_CODE,x_SECURITY_CURRENCY_CODE),
             BEGIN_DATE = decode( x_BEGIN_DATE, FND_API.G_MISS_DATE,BEGIN_DATE,x_BEGIN_DATE),
             END_DATE = decode( x_END_DATE, FND_API.G_MISS_DATE,END_DATE,x_END_DATE),
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
             WH_UPDATE_DATE = decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE,WH_UPDATE_DATE,x_WH_UPDATE_DATE),
             STATUS          =decode(x_STATUS,FND_API.G_MISS_CHAR,STATUS,x_STATUS)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_SECURITY_ISSUED_ID            NUMBER,
                  x_ESTIMATED_TOTAL_AMOUNT        NUMBER,
                  x_PARTY_ID                      NUMBER,
                  x_STOCK_EXCHANGE_ID             NUMBER,
                  x_SECURITY_ISSUED_CLASS         VARCHAR2,
                  x_SECURITY_ISSUED_NAME          VARCHAR2,
                  x_TOTAL_AMOUNT_IN_A_CURRENCY    VARCHAR2,
                  x_STOCK_TICKER_SYMBOL           VARCHAR2,
                  x_SECURITY_CURRENCY_CODE        VARCHAR2,
                  x_BEGIN_DATE                    DATE,
                  x_END_DATE                      DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE,
                  x_WH_UPDATE_DATE                DATE,
                  x_STATUS                        VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_SECURITY_ISSUED
         WHERE rowid = x_Rowid
         FOR UPDATE of SECURITY_ISSUED_ID NOWAIT;
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
           (    ( Recinfo.SECURITY_ISSUED_ID = x_SECURITY_ISSUED_ID)
            OR (    ( Recinfo.SECURITY_ISSUED_ID = NULL )
                AND (  x_SECURITY_ISSUED_ID = NULL )))
       AND (    ( Recinfo.ESTIMATED_TOTAL_AMOUNT = x_ESTIMATED_TOTAL_AMOUNT)
            OR (    ( Recinfo.ESTIMATED_TOTAL_AMOUNT = NULL )
                AND (  x_ESTIMATED_TOTAL_AMOUNT = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.STOCK_EXCHANGE_ID = x_STOCK_EXCHANGE_ID)
            OR (    ( Recinfo.STOCK_EXCHANGE_ID = NULL )
                AND (  x_STOCK_EXCHANGE_ID = NULL )))
       AND (    ( Recinfo.SECURITY_ISSUED_CLASS = x_SECURITY_ISSUED_CLASS)
            OR (    ( Recinfo.SECURITY_ISSUED_CLASS = NULL )
                AND (  x_SECURITY_ISSUED_CLASS = NULL )))
       AND (    ( Recinfo.SECURITY_ISSUED_NAME = x_SECURITY_ISSUED_NAME)
            OR (    ( Recinfo.SECURITY_ISSUED_NAME = NULL )
                AND (  x_SECURITY_ISSUED_NAME = NULL )))
       AND (    ( Recinfo.TOTAL_AMOUNT_IN_A_CURRENCY = x_TOTAL_AMOUNT_IN_A_CURRENCY)
            OR (    ( Recinfo.TOTAL_AMOUNT_IN_A_CURRENCY = NULL )
                AND (  x_TOTAL_AMOUNT_IN_A_CURRENCY = NULL )))
       AND (    ( Recinfo.STOCK_TICKER_SYMBOL = x_STOCK_TICKER_SYMBOL)
            OR (    ( Recinfo.STOCK_TICKER_SYMBOL = NULL )
                AND (  x_STOCK_TICKER_SYMBOL = NULL )))
       AND (    ( Recinfo.SECURITY_CURRENCY_CODE = x_SECURITY_CURRENCY_CODE)
            OR (    ( Recinfo.SECURITY_CURRENCY_CODE = NULL )
                AND (  x_SECURITY_CURRENCY_CODE = NULL )))
       AND (    ( Recinfo.BEGIN_DATE = x_BEGIN_DATE)
            OR (    ( Recinfo.BEGIN_DATE = NULL )
                AND (  x_BEGIN_DATE = NULL )))
       AND (    ( Recinfo.END_DATE = x_END_DATE)
            OR (    ( Recinfo.END_DATE = NULL )
                AND (  x_END_DATE = NULL )))
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

       AND (    ( Recinfo.STATUS = x_STATUS)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS= NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_SECURITY_ISSUED_PKG;

/
