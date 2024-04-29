--------------------------------------------------------
--  DDL for Package Body HZ_BILLING_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BILLING_PREFERENCES_PKG" as
/* $Header: ARHABFTB.pls 120.3 2005/10/30 03:50:18 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid           IN OUT NOCOPY        VARCHAR2,
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
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
   CURSOR C IS SELECT rowid FROM HZ_BILLING_PREFERENCES
            WHERE BILLING_PREFERENCES_ID = x_BILLING_PREFERENCES_ID;
BEGIN
   INSERT INTO HZ_BILLING_PREFERENCES(
           BILLING_PREFERENCES_ID,
           BILL_LANGUAGE,
           BILL_ROUND_NUMBER,
           BILL_TYPE,
           MEDIA_FORMAT,
           SITE_USE_ID,
           MEDIA_TYPE,
           CUST_ACCOUNT_ID,
           NUMBER_OF_COPIES,
           CURRENCY_CODE,
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
          x_BILLING_PREFERENCES_ID,
           decode( x_BILL_LANGUAGE, FND_API.G_MISS_CHAR, NULL,x_BILL_LANGUAGE),
           decode( x_BILL_ROUND_NUMBER, FND_API.G_MISS_CHAR, NULL,x_BILL_ROUND_NUMBER),
           decode( x_BILL_TYPE, FND_API.G_MISS_CHAR, NULL,x_BILL_TYPE),
           decode( x_MEDIA_FORMAT, FND_API.G_MISS_CHAR, NULL,x_MEDIA_FORMAT),
           decode( x_SITE_USE_ID, FND_API.G_MISS_NUM, NULL,x_SITE_USE_ID),
           decode( x_MEDIA_TYPE, FND_API.G_MISS_CHAR, NULL,x_MEDIA_TYPE),
           decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL,x_CUST_ACCOUNT_ID),
           decode( x_NUMBER_OF_COPIES, FND_API.G_MISS_NUM, NULL,x_NUMBER_OF_COPIES),
           decode( x_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL,x_CURRENCY_CODE),
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



PROCEDURE Delete_Row(                  x_BILLING_PREFERENCES_ID        NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_BILLING_PREFERENCES
    WHERE BILLING_PREFERENCES_ID = x_BILLING_PREFERENCES_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid            IN OUT NOCOPY       VARCHAR2,
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
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
    Update HZ_BILLING_PREFERENCES
    SET
             BILLING_PREFERENCES_ID = decode( x_BILLING_PREFERENCES_ID, FND_API.G_MISS_NUM,BILLING_PREFERENCES_ID,x_BILLING_PREFERENCES_ID),
             BILL_LANGUAGE = decode( x_BILL_LANGUAGE, FND_API.G_MISS_CHAR,BILL_LANGUAGE,x_BILL_LANGUAGE),
             BILL_ROUND_NUMBER = decode( x_BILL_ROUND_NUMBER, FND_API.G_MISS_CHAR,BILL_ROUND_NUMBER,x_BILL_ROUND_NUMBER),
             BILL_TYPE = decode( x_BILL_TYPE, FND_API.G_MISS_CHAR,BILL_TYPE,x_BILL_TYPE),
             MEDIA_FORMAT = decode( x_MEDIA_FORMAT, FND_API.G_MISS_CHAR,MEDIA_FORMAT,x_MEDIA_FORMAT),
             SITE_USE_ID = decode( x_SITE_USE_ID, FND_API.G_MISS_NUM,SITE_USE_ID,x_SITE_USE_ID),
             MEDIA_TYPE = decode( x_MEDIA_TYPE, FND_API.G_MISS_CHAR,MEDIA_TYPE,x_MEDIA_TYPE),
             CUST_ACCOUNT_ID = decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM,CUST_ACCOUNT_ID,x_CUST_ACCOUNT_ID),
             NUMBER_OF_COPIES = decode( x_NUMBER_OF_COPIES, FND_API.G_MISS_NUM,NUMBER_OF_COPIES,x_NUMBER_OF_COPIES),
             CURRENCY_CODE = decode( x_CURRENCY_CODE, FND_API.G_MISS_CHAR,CURRENCY_CODE,x_CURRENCY_CODE),
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
                  x_BILLING_PREFERENCES_ID        NUMBER,
                  x_BILL_LANGUAGE                 VARCHAR2,
                  x_BILL_ROUND_NUMBER             VARCHAR2,
                  x_BILL_TYPE                     VARCHAR2,
                  x_MEDIA_FORMAT                  VARCHAR2,
                  x_SITE_USE_ID                   NUMBER,
                  x_MEDIA_TYPE                    VARCHAR2,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_NUMBER_OF_COPIES              NUMBER,
                  x_CURRENCY_CODE                 VARCHAR2,
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
          FROM HZ_BILLING_PREFERENCES
         WHERE rowid = x_Rowid
         FOR UPDATE of BILLING_PREFERENCES_ID NOWAIT;
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
           (    ( Recinfo.BILLING_PREFERENCES_ID = x_BILLING_PREFERENCES_ID)
            OR (    ( Recinfo.BILLING_PREFERENCES_ID IS NULL )
                AND (  x_BILLING_PREFERENCES_ID IS NULL )))
       AND (    ( Recinfo.BILL_LANGUAGE = x_BILL_LANGUAGE)
            OR (    ( Recinfo.BILL_LANGUAGE IS NULL )
                AND (  x_BILL_LANGUAGE IS NULL )))
       AND (    ( Recinfo.BILL_ROUND_NUMBER = x_BILL_ROUND_NUMBER)
            OR (    ( Recinfo.BILL_ROUND_NUMBER IS NULL )
                AND (  x_BILL_ROUND_NUMBER IS NULL )))
       AND (    ( Recinfo.BILL_TYPE = x_BILL_TYPE)
            OR (    ( Recinfo.BILL_TYPE IS NULL )
                AND (  x_BILL_TYPE IS NULL )))
       AND (    ( Recinfo.MEDIA_FORMAT = x_MEDIA_FORMAT)
            OR (    ( Recinfo.MEDIA_FORMAT IS NULL )
                AND (  x_MEDIA_FORMAT IS NULL )))
       AND (    ( Recinfo.SITE_USE_ID = x_SITE_USE_ID)
            OR (    ( Recinfo.SITE_USE_ID IS NULL )
                AND (  x_SITE_USE_ID IS NULL )))
       AND (    ( Recinfo.MEDIA_TYPE = x_MEDIA_TYPE)
            OR (    ( Recinfo.MEDIA_TYPE IS NULL )
                AND (  x_MEDIA_TYPE IS NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ID = x_CUST_ACCOUNT_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ID IS NULL )
                AND (  x_CUST_ACCOUNT_ID IS NULL )))
       AND (    ( Recinfo.NUMBER_OF_COPIES = x_NUMBER_OF_COPIES)
            OR (    ( Recinfo.NUMBER_OF_COPIES IS NULL )
                AND (  x_NUMBER_OF_COPIES IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = x_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  x_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  x_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  x_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  x_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  x_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  x_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  x_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  x_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  x_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  x_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.WH_UPDATE_DATE = x_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE IS NULL )
                AND (  x_WH_UPDATE_DATE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_BILLING_PREFERENCES_PKG;

/
