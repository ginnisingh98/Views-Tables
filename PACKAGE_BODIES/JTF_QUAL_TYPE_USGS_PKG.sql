--------------------------------------------------------
--  DDL for Package Body JTF_QUAL_TYPE_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_QUAL_TYPE_USGS_PKG" AS
/* $Header: jtfvqtub.pls 120.0 2005/06/02 18:22:15 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
--                  x_PACKAGE_FILENAME               IN     VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_QUAL_TYPE_USGS
            WHERE QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID;
   CURSOR C2 IS SELECT JTF_QUAL_TYPE_USGS_s.nextval FROM sys.dual;
BEGIN
   If (x_QUAL_TYPE_USG_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_QUAL_TYPE_USG_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_QUAL_TYPE_USGS(
           QUAL_TYPE_USG_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           QUAL_TYPE_ID,
           SOURCE_ID,
--           PACKAGE_FILENAME,
           PACKAGE_NAME,
           PACKAGE_SPOOL_FILENAME,
           ORG_ID
          ) VALUES (
          x_QUAL_TYPE_USG_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_QUAL_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_TYPE_ID),
           decode( x_SOURCE_ID, FND_API.G_MISS_NUM, NULL,x_SOURCE_ID),
--           decode( x_PACKAGE_FILENAME, FND_API.G_MISS_CHAR, NULL,x_PACKAGE_FILENAME),
           decode( x_PACKAGE_NAME, FND_API.G_MISS_CHAR, NULL,x_PACKAGE_NAME),
           decode( x_PACKAGE_SPOOL_FILENAME, FND_API.G_MISS_CHAR, NULL,x_PACKAGE_SPOOL_FILENAME),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_QUAL_TYPE_USG_ID               IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_QUAL_TYPE_USGS
    WHERE QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
--                  x_PACKAGE_FILENAME                IN      VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_QUAL_TYPE_USGS
    SET
             QUAL_TYPE_USG_ID = decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM,QUAL_TYPE_USG_ID,x_QUAL_TYPE_USG_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             QUAL_TYPE_ID = decode( x_QUAL_TYPE_ID, FND_API.G_MISS_NUM,QUAL_TYPE_ID,x_QUAL_TYPE_ID),
             SOURCE_ID = decode( x_SOURCE_ID, FND_API.G_MISS_NUM,SOURCE_ID,x_SOURCE_ID),
--             PACKAGE_FILENAME = decode( x_PACKAGE_FILENAME, FND_API.G_MISS_CHAR,PACKAGE_FILENAME,x_PACKAGE_FILENAME),
             PACKAGE_NAME = decode( x_PACKAGE_NAME, FND_API.G_MISS_CHAR,PACKAGE_NAME,x_PACKAGE_NAME),
             PACKAGE_SPOOL_FILENAME = decode( x_PACKAGE_SPOOL_FILENAME, FND_API.G_MISS_CHAR,PACKAGE_SPOOL_FILENAME,x_PACKAGE_SPOOL_FILENAME),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where QUAL_TYPE_USG_ID = X_QUAL_TYPE_USG_ID and
          ( ORG_ID = x_ORG_ID OR ( ORG_ID IS NULL AND X_ORG_ID IS NULL)) ;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_SOURCE_ID                      IN     NUMBER,
--                  x_PACKAGE_FILENAME               IN     VARCHAR2,
                  x_PACKAGE_NAME                   IN     VARCHAR2,
                  x_PACKAGE_SPOOL_FILENAME         IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_QUAL_TYPE_USGS
         WHERE rowid = x_Rowid
         FOR UPDATE of QUAL_TYPE_USG_ID NOWAIT;
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
           (    ( Recinfo.QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID)
            OR (    ( Recinfo.QUAL_TYPE_USG_ID is NULL )
                AND (  x_QUAL_TYPE_USG_ID is NULL )))
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
       AND (    ( Recinfo.QUAL_TYPE_ID = x_QUAL_TYPE_ID)
            OR (    ( Recinfo.QUAL_TYPE_ID is NULL )
                AND (  x_QUAL_TYPE_ID is NULL )))
       AND (    ( Recinfo.SOURCE_ID = x_SOURCE_ID)
            OR (    ( Recinfo.SOURCE_ID is NULL )
                AND (  x_SOURCE_ID is NULL )))
--       AND (    ( Recinfo.PACKAGE_FILENAME = x_PACKAGE_FILENAME)
--           OR (    ( Recinfo.PACKAGE_FILENAME is NULL )
--                AND (  x_PACKAGE_FILENAME is NULL )))
       AND (    ( Recinfo.PACKAGE_NAME = x_PACKAGE_NAME)
            OR (    ( Recinfo.PACKAGE_NAME is NULL )
                AND (  x_PACKAGE_NAME is NULL )))
       AND (    ( Recinfo.PACKAGE_SPOOL_FILENAME = x_PACKAGE_SPOOL_FILENAME)
            OR (    ( Recinfo.PACKAGE_SPOOL_FILENAME is NULL )
                AND (  x_PACKAGE_SPOOL_FILENAME is NULL )))
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

END JTF_QUAL_TYPE_USGS_PKG;

/
