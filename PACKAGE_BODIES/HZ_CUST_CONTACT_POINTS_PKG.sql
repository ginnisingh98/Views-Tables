--------------------------------------------------------
--  DDL for Package Body HZ_CUST_CONTACT_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_CONTACT_POINTS_PKG" as
/*$Header: ARHCCPTB.pls 120.3 2005/10/30 04:17:38 appldev ship $ */



PROCEDURE Insert_Row(
                  x_Rowid       IN OUT NOCOPY            VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_CUST_CONTACT_POINTS
            WHERE CUST_CONTACT_POINT_ID = x_CUST_CONTACT_POINT_ID;
BEGIN
   INSERT INTO HZ_CUST_CONTACT_POINTS(
           CUST_CONTACT_POINT_ID,
           CUST_ACCOUNT_ID,
           CUST_ACCOUNT_SITE_ID,
           CUST_ACCOUNT_ROLE_ID,
           CONTACT_POINT_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           STATUS,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE
          ) VALUES (
          x_CUST_CONTACT_POINT_ID,
           decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL,x_CUST_ACCOUNT_ID),
           decode( x_CUST_ACCOUNT_SITE_ID, FND_API.G_MISS_NUM, NULL,x_CUST_ACCOUNT_SITE_ID),
           decode( x_CUST_ACCOUNT_ROLE_ID, FND_API.G_MISS_NUM, NULL,x_CUST_ACCOUNT_ROLE_ID),
           decode( x_CONTACT_POINT_ID, FND_API.G_MISS_NUM, NULL,x_CONTACT_POINT_ID),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', x_STATUS),
           decode( x_REQUEST_ID, FND_API.G_MISS_NUM, NULL,x_REQUEST_ID),
           decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_APPLICATION_ID),
           decode( x_PROGRAM_ID, FND_API.G_MISS_NUM, NULL,x_PROGRAM_ID),
           decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_PROGRAM_UPDATE_DATE));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_CUST_CONTACT_POINT_ID         NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_CUST_CONTACT_POINTS
    WHERE CUST_CONTACT_POINT_ID = x_CUST_CONTACT_POINT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE
 ) IS
 BEGIN
    Update HZ_CUST_CONTACT_POINTS
    SET
             CUST_CONTACT_POINT_ID = decode( x_CUST_CONTACT_POINT_ID, FND_API.G_MISS_NUM,CUST_CONTACT_POINT_ID,x_CUST_CONTACT_POINT_ID),
             CUST_ACCOUNT_ID = decode( x_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM,CUST_ACCOUNT_ID,x_CUST_ACCOUNT_ID),
             CUST_ACCOUNT_SITE_ID = decode( x_CUST_ACCOUNT_SITE_ID, FND_API.G_MISS_NUM,CUST_ACCOUNT_SITE_ID,x_CUST_ACCOUNT_SITE_ID),
             CUST_ACCOUNT_ROLE_ID = decode( x_CUST_ACCOUNT_ROLE_ID, FND_API.G_MISS_NUM,CUST_ACCOUNT_ROLE_ID,x_CUST_ACCOUNT_ROLE_ID),
             CONTACT_POINT_ID = decode( x_CONTACT_POINT_ID, FND_API.G_MISS_NUM,CONTACT_POINT_ID,x_CONTACT_POINT_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             -- Bug 3032780
             /*
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             */
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             STATUS = decode( x_STATUS, FND_API.G_MISS_CHAR,STATUS,x_STATUS),
             REQUEST_ID = decode( x_REQUEST_ID, FND_API.G_MISS_NUM,REQUEST_ID,x_REQUEST_ID),
             PROGRAM_APPLICATION_ID = decode( x_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,x_PROGRAM_APPLICATION_ID),
             PROGRAM_ID = decode( x_PROGRAM_ID, FND_API.G_MISS_NUM,PROGRAM_ID,x_PROGRAM_ID),
             PROGRAM_UPDATE_DATE = decode( x_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,x_PROGRAM_UPDATE_DATE)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_CUST_CONTACT_POINTS
         WHERE rowid = x_Rowid
         FOR UPDATE of CUST_CONTACT_POINT_ID NOWAIT;
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
           (    ( Recinfo.CUST_CONTACT_POINT_ID = x_CUST_CONTACT_POINT_ID)
            OR (    ( Recinfo.CUST_CONTACT_POINT_ID = NULL )
                AND (  x_CUST_CONTACT_POINT_ID = NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ID = x_CUST_ACCOUNT_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ID = NULL )
                AND (  x_CUST_ACCOUNT_ID = NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_SITE_ID = x_CUST_ACCOUNT_SITE_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_SITE_ID = NULL )
                AND (  x_CUST_ACCOUNT_SITE_ID = NULL )))
       AND (    ( Recinfo.CUST_ACCOUNT_ROLE_ID = x_CUST_ACCOUNT_ROLE_ID)
            OR (    ( Recinfo.CUST_ACCOUNT_ROLE_ID = NULL )
                AND (  x_CUST_ACCOUNT_ROLE_ID = NULL )))
       AND (    ( Recinfo.CONTACT_POINT_ID = x_CONTACT_POINT_ID)
            OR (    ( Recinfo.CONTACT_POINT_ID = NULL )
                AND (  x_CONTACT_POINT_ID = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.STATUS = x_STATUS)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS = NULL )))
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
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_CUST_CONTACT_POINTS_PKG;

/
