--------------------------------------------------------
--  DDL for Package Body JTF_TYPE_QTYPE_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TYPE_QTYPE_USGS_PKG" as
/* $Header: jtfvtqub.pls 115.3 2000/02/29 18:25:50 pkm ship      $ */

-- 01/20/00  VNEDUNGA  Changing update/lock-row procedurs to
--                     use TYPE_QTYPE_USG_ID instead of row_id
-- 01/20/00  VNEDUNGA  Changing = NULL to IS NULL
-- 02/17/00  VNEDUNGA  Adding ORG_ID to the table handler procedures

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN OUT NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TYPE_QTYPE_USGS
            WHERE TYPE_QTYPE_USG_ID = x_TYPE_QTYPE_USG_ID;
   CURSOR C2 IS SELECT JTF_TYPE_QTYPE_USGS_s.nextval FROM sys.dual;
BEGIN
   If (x_TYPE_QTYPE_USG_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TYPE_QTYPE_USG_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TYPE_QTYPE_USGS(
           TYPE_QTYPE_USG_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_TYPE_ID,
           QUAL_TYPE_USG_ID,
           ORG_ID
          ) VALUES (
          x_TYPE_QTYPE_USG_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, NULL,x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_TERR_TYPE_ID),
           decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_TYPE_USG_ID),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL, x_ORG_ID) );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_TYPE_QTYPE_USG_ID              IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TYPE_QTYPE_USGS
    WHERE TYPE_QTYPE_USG_ID = x_TYPE_QTYPE_USG_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TYPE_QTYPE_USGS
    SET
             TYPE_QTYPE_USG_ID = decode( x_TYPE_QTYPE_USG_ID, FND_API.G_MISS_NUM,TYPE_QTYPE_USG_ID,x_TYPE_QTYPE_USG_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_TYPE_ID = decode( x_TERR_TYPE_ID, FND_API.G_MISS_NUM,TERR_TYPE_ID,x_TERR_TYPE_ID),
             QUAL_TYPE_USG_ID = decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM,QUAL_TYPE_USG_ID,x_QUAL_TYPE_USG_ID),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID)
    where TYPE_QTYPE_USG_ID = X_TYPE_QTYPE_USG_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TYPE_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TYPE_QTYPE_USGS
         WHERE TYPE_QTYPE_USG_ID = x_TYPE_QTYPE_USG_ID
         FOR UPDATE of TYPE_QTYPE_USG_ID NOWAIT;
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
           (    ( Recinfo.TYPE_QTYPE_USG_ID = x_TYPE_QTYPE_USG_ID)
            OR (    ( Recinfo.TYPE_QTYPE_USG_ID IS NULL )
                AND (  x_TYPE_QTYPE_USG_ID IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  x_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  x_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  x_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  x_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  x_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.TERR_TYPE_ID = x_TERR_TYPE_ID)
            OR (    ( Recinfo.TERR_TYPE_ID IS NULL )
                AND (  x_TERR_TYPE_ID IS NULL )))
       AND (    ( Recinfo.QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID)
            OR (    ( Recinfo.QUAL_TYPE_USG_ID IS NULL )
                AND (  x_QUAL_TYPE_USG_ID IS NULL )))
       AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID IS NULL )
                AND (  x_ORG_ID IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END JTF_TYPE_QTYPE_USGS_PKG;

/
