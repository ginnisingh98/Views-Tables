--------------------------------------------------------
--  DDL for Package Body HZ_FINANCIAL_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FINANCIAL_PROFILE_PKG" as
/* $Header: ARHPFPTB.pls 120.3 2005/10/30 03:53:56 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid               IN OUT NOCOPY    VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
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
   CURSOR C IS SELECT rowid FROM HZ_FINANCIAL_PROFILE
            WHERE FINANCIAL_PROFILE_ID = x_FINANCIAL_PROFILE_ID;
BEGIN

   INSERT INTO HZ_FINANCIAL_PROFILE(
           FINANCIAL_PROFILE_ID,
           ACCESS_AUTHORITY_DATE,
           ACCESS_AUTHORITY_GRANTED,
           BALANCE_AMOUNT,
           BALANCE_VERIFIED_ON_DATE,
           FINANCIAL_ACCOUNT_NUMBER,
           FINANCIAL_ACCOUNT_TYPE,
           FINANCIAL_ORG_TYPE,
           FINANCIAL_ORGANIZATION_NAME,
           CREATED_BY,
           CREATION_DATE,
           PARTY_ID,
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
          x_FINANCIAL_PROFILE_ID,
           decode( x_ACCESS_AUTHORITY_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_ACCESS_AUTHORITY_DATE),
           decode( x_ACCESS_AUTHORITY_GRANTED, FND_API.G_MISS_CHAR,'N', NULL,'N',x_ACCESS_AUTHORITY_GRANTED),
           decode( x_BALANCE_AMOUNT, FND_API.G_MISS_NUM, NULL,x_BALANCE_AMOUNT),
           decode( x_BALANCE_VERIFIED_ON_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_BALANCE_VERIFIED_ON_DATE),
           decode( x_FINANCIAL_ACCOUNT_NUMBER, FND_API.G_MISS_CHAR, NULL,x_FINANCIAL_ACCOUNT_NUMBER),
           decode( x_FINANCIAL_ACCOUNT_TYPE, FND_API.G_MISS_CHAR, NULL,x_FINANCIAL_ACCOUNT_TYPE),
           decode( x_FINANCIAL_ORG_TYPE, FND_API.G_MISS_CHAR, NULL,x_FINANCIAL_ORG_TYPE),
           decode( x_FINANCIAL_ORGANIZATION_NAME, FND_API.G_MISS_CHAR, NULL,x_FINANCIAL_ORGANIZATION_NAME),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE),
           decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_WH_UPDATE_DATE),

           decode( x_STATUS, FND_API.G_MISS_CHAR, 'A',x_STATUS)
           );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_FINANCIAL_PROFILE_ID          NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_FINANCIAL_PROFILE
    WHERE FINANCIAL_PROFILE_ID  = x_FINANCIAL_PROFILE_ID ;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                IN OUT NOCOPY   VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
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
    Update HZ_FINANCIAL_PROFILE
    SET
             FINANCIAL_PROFILE_ID = decode( x_FINANCIAL_PROFILE_ID, FND_API.G_MISS_NUM,FINANCIAL_PROFILE_ID,x_FINANCIAL_PROFILE_ID),
             ACCESS_AUTHORITY_DATE = decode( x_ACCESS_AUTHORITY_DATE, FND_API.G_MISS_DATE,ACCESS_AUTHORITY_DATE,x_ACCESS_AUTHORITY_DATE),
             ACCESS_AUTHORITY_GRANTED = decode( x_ACCESS_AUTHORITY_GRANTED, FND_API.G_MISS_CHAR,ACCESS_AUTHORITY_GRANTED,x_ACCESS_AUTHORITY_GRANTED),
             BALANCE_AMOUNT = decode( x_BALANCE_AMOUNT, FND_API.G_MISS_NUM,BALANCE_AMOUNT,x_BALANCE_AMOUNT),
             BALANCE_VERIFIED_ON_DATE = decode( x_BALANCE_VERIFIED_ON_DATE, FND_API.G_MISS_DATE,BALANCE_VERIFIED_ON_DATE,x_BALANCE_VERIFIED_ON_DATE),
             FINANCIAL_ACCOUNT_NUMBER = decode( x_FINANCIAL_ACCOUNT_NUMBER, FND_API.G_MISS_CHAR,FINANCIAL_ACCOUNT_NUMBER,x_FINANCIAL_ACCOUNT_NUMBER),
             FINANCIAL_ACCOUNT_TYPE = decode( x_FINANCIAL_ACCOUNT_TYPE, FND_API.G_MISS_CHAR,FINANCIAL_ACCOUNT_TYPE,x_FINANCIAL_ACCOUNT_TYPE),
             FINANCIAL_ORG_TYPE = decode( x_FINANCIAL_ORG_TYPE, FND_API.G_MISS_CHAR,FINANCIAL_ORG_TYPE,x_FINANCIAL_ORG_TYPE),
             FINANCIAL_ORGANIZATION_NAME = decode( x_FINANCIAL_ORGANIZATION_NAME, FND_API.G_MISS_CHAR,FINANCIAL_ORGANIZATION_NAME,x_FINANCIAL_ORGANIZATION_NAME),
             -- Bug 3032780
             /*
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             */
             PARTY_ID = decode( x_PARTY_ID, FND_API.G_MISS_NUM,PARTY_ID,x_PARTY_ID),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,REQUEST_ID,x_REQUEST_ID),
             PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,x_PROGRAM_APPLICATION_ID),
             PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,PROGRAM_ID,x_PROGRAM_ID),
             PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,x_PROGRAM_UPDATE_DATE),
             WH_UPDATE_DATE = decode( x_WH_UPDATE_DATE, FND_API.G_MISS_DATE,WH_UPDATE_DATE,x_WH_UPDATE_DATE),
             STATUS =decode(x_STATUS,FND_API.G_MISS_CHAR,STATUS,x_STATUS)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_FINANCIAL_PROFILE_ID          NUMBER,
                  x_ACCESS_AUTHORITY_DATE         DATE,
                  x_ACCESS_AUTHORITY_GRANTED      VARCHAR2,
                  x_BALANCE_AMOUNT                NUMBER,
                  x_BALANCE_VERIFIED_ON_DATE      DATE,
                  x_FINANCIAL_ACCOUNT_NUMBER      VARCHAR2,
                  x_FINANCIAL_ACCOUNT_TYPE        VARCHAR2,
                  x_FINANCIAL_ORG_TYPE            VARCHAR2,
                  x_FINANCIAL_ORGANIZATION_NAME   VARCHAR2,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_PARTY_ID                      NUMBER,
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
          FROM HZ_FINANCIAL_PROFILE
         WHERE rowid = x_Rowid
         FOR UPDATE of FINANCIAL_PROFILE_ID NOWAIT;
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
           (    ( Recinfo.FINANCIAL_PROFILE_ID = x_FINANCIAL_PROFILE_ID)
            OR (    ( Recinfo.FINANCIAL_PROFILE_ID = NULL )
                AND (  x_FINANCIAL_PROFILE_ID = NULL )))
       AND (    ( Recinfo.ACCESS_AUTHORITY_DATE = x_ACCESS_AUTHORITY_DATE)
            OR (    ( Recinfo.ACCESS_AUTHORITY_DATE = NULL )
                AND (  x_ACCESS_AUTHORITY_DATE = NULL )))
       AND (    ( Recinfo.ACCESS_AUTHORITY_GRANTED = x_ACCESS_AUTHORITY_GRANTED)
            OR (    ( Recinfo.ACCESS_AUTHORITY_GRANTED = NULL )
                AND (  x_ACCESS_AUTHORITY_GRANTED = NULL )))
       AND (    ( Recinfo.BALANCE_AMOUNT = x_BALANCE_AMOUNT)
            OR (    ( Recinfo.BALANCE_AMOUNT = NULL )
                AND (  x_BALANCE_AMOUNT = NULL )))
       AND (    ( Recinfo.BALANCE_VERIFIED_ON_DATE = x_BALANCE_VERIFIED_ON_DATE)
            OR (    ( Recinfo.BALANCE_VERIFIED_ON_DATE = NULL )
                AND (  x_BALANCE_VERIFIED_ON_DATE = NULL )))
       AND (    ( Recinfo.FINANCIAL_ACCOUNT_NUMBER = x_FINANCIAL_ACCOUNT_NUMBER)
            OR (    ( Recinfo.FINANCIAL_ACCOUNT_NUMBER = NULL )
                AND (  x_FINANCIAL_ACCOUNT_NUMBER = NULL )))
       AND (    ( Recinfo.FINANCIAL_ACCOUNT_TYPE = x_FINANCIAL_ACCOUNT_TYPE)
            OR (    ( Recinfo.FINANCIAL_ACCOUNT_TYPE = NULL )
                AND (  x_FINANCIAL_ACCOUNT_TYPE = NULL )))
       AND (    ( Recinfo.FINANCIAL_ORG_TYPE = x_FINANCIAL_ORG_TYPE)
            OR (    ( Recinfo.FINANCIAL_ORG_TYPE = NULL )
                AND (  x_FINANCIAL_ORG_TYPE = NULL )))
       AND (    ( Recinfo.FINANCIAL_ORGANIZATION_NAME = x_FINANCIAL_ORGANIZATION_NAME)
            OR (    ( Recinfo.FINANCIAL_ORGANIZATION_NAME = NULL )
                AND (  x_FINANCIAL_ORGANIZATION_NAME = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
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
      AND (    ( Recinfo.STATUS=x_STATUS)
           OR (     ( Recinfo.STATUS =NULL)
               AND  ( x_STATUS = NULL)))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_FINANCIAL_PROFILE_PKG;

/
