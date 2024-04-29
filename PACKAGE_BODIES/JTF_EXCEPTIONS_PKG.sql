--------------------------------------------------------
--  DDL for Package Body JTF_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EXCEPTIONS_PKG" AS
/* $Header: jtfvtveb.pls 115.3 2000/02/29 18:26:26 pkm ship      $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT VARCHAR2,
                  x_EXCEPTIONS_ID                  IN OUT NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_EXCEPTIONS
            WHERE EXCEPTIONS_ID = x_EXCEPTIONS_ID;
   CURSOR C2 IS SELECT JTF_EXCEPTIONS_s.nextval FROM sys.dual;
BEGIN
   If (x_EXCEPTIONS_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_EXCEPTIONS_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_EXCEPTIONS(
           EXCEPTIONS_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           RESOURCE_ID,
           CUSTOMER_ID,
           ADDRESS_ID,
           LEAD_ID,
           OPPORTUNITY_ID,
           ORG_ID
          ) VALUES (
          x_EXCEPTIONS_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_ID, FND_API.G_MISS_NUM, NULL,x_TERR_ID),
           decode( x_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,x_RESOURCE_ID),
           decode( x_CUSTOMER_ID, FND_API.G_MISS_NUM, NULL,x_CUSTOMER_ID),
           decode( x_ADDRESS_ID, FND_API.G_MISS_NUM, NULL,x_ADDRESS_ID),
           decode( x_LEAD_ID, FND_API.G_MISS_NUM, NULL,x_LEAD_ID),
           decode( x_OPPORTUNITY_ID, FND_API.G_MISS_NUM, NULL,x_OPPORTUNITY_ID),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_EXCEPTIONS_ID                  IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_EXCEPTIONS
    WHERE EXCEPTIONS_ID = x_EXCEPTIONS_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_EXCEPTIONS_ID                  IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_EXCEPTIONS
    SET
             EXCEPTIONS_ID = decode( x_EXCEPTIONS_ID, FND_API.G_MISS_NUM,EXCEPTIONS_ID,x_EXCEPTIONS_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_ID = decode( x_TERR_ID, FND_API.G_MISS_NUM,TERR_ID,x_TERR_ID),
             RESOURCE_ID = decode( x_RESOURCE_ID, FND_API.G_MISS_NUM,RESOURCE_ID,x_RESOURCE_ID),
             CUSTOMER_ID = decode( x_CUSTOMER_ID, FND_API.G_MISS_NUM,CUSTOMER_ID,x_CUSTOMER_ID),
             ADDRESS_ID = decode( x_ADDRESS_ID, FND_API.G_MISS_NUM,ADDRESS_ID,x_ADDRESS_ID),
             LEAD_ID = decode( x_LEAD_ID, FND_API.G_MISS_NUM,LEAD_ID,x_LEAD_ID),
             OPPORTUNITY_ID = decode( x_OPPORTUNITY_ID, FND_API.G_MISS_NUM,OPPORTUNITY_ID,x_OPPORTUNITY_ID),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_EXCEPTIONS_ID                  IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_EXCEPTIONS
         WHERE rowid = x_Rowid
         FOR UPDATE of EXCEPTIONS_ID NOWAIT;
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
           (    ( Recinfo.EXCEPTIONS_ID = x_EXCEPTIONS_ID)
            OR (    ( Recinfo.EXCEPTIONS_ID is NULL )
                AND (  x_EXCEPTIONS_ID is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE is NULL )
                AND (  x_LAST_UPDATE_DATE is NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY is NULL )
                AND (  x_LAST_UPDATED_BY is NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE is NULL )
                AND (  x_CREATION_DATE is NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY is NULL )
                AND (  x_CREATED_BY is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN is NULL )
                AND (  x_LAST_UPDATE_LOGIN is NULL )))
       AND (    ( Recinfo.TERR_ID = x_TERR_ID)
            OR (    ( Recinfo.TERR_ID is NULL )
                AND (  x_TERR_ID is NULL )))
       AND (    ( Recinfo.RESOURCE_ID = x_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID is NULL )
                AND (  x_RESOURCE_ID is NULL )))
       AND (    ( Recinfo.CUSTOMER_ID = x_CUSTOMER_ID)
            OR (    ( Recinfo.CUSTOMER_ID is NULL )
                AND (  x_CUSTOMER_ID is NULL )))
       AND (    ( Recinfo.ADDRESS_ID = x_ADDRESS_ID)
            OR (    ( Recinfo.ADDRESS_ID is NULL )
                AND (  x_ADDRESS_ID is NULL )))
       AND (    ( Recinfo.LEAD_ID = x_LEAD_ID)
            OR (    ( Recinfo.LEAD_ID is NULL )
                AND (  x_LEAD_ID is NULL )))
       AND (    ( Recinfo.OPPORTUNITY_ID = x_OPPORTUNITY_ID)
            OR (    ( Recinfo.OPPORTUNITY_ID is NULL )
                AND (  x_OPPORTUNITY_ID is NULL )))
       AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID is NULL )
                AND (  x_ORG_ID is NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END JTF_EXCEPTIONS_PKG;

/
