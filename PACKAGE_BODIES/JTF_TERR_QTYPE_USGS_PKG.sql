--------------------------------------------------------
--  DDL for Package Body JTF_TERR_QTYPE_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_QTYPE_USGS_PKG" as
/* $Header: jtfvqutb.pls 120.0 2005/06/02 18:22:18 appldev ship $ */

-- 01/20/99  vnedunga  changing the delete/Update/lock_row to use
--                     terr_qtype_usg_id instead of row_id
-- 02/24/00  vnedunga fixing decode for date fields

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_QTYPE_USG_ID              IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_QTYPE_USGS_all
            WHERE TERR_QTYPE_USG_ID = x_TERR_QTYPE_USG_ID;
   CURSOR C2 IS SELECT JTF_TERR_QTYPE_USGS_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_QTYPE_USG_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_QTYPE_USG_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_QTYPE_USGS_ALL(
           TERR_QTYPE_USG_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           QUAL_TYPE_USG_ID,
           ORG_ID
          ) VALUES (
           x_TERR_QTYPE_USG_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_ID, FND_API.G_MISS_NUM, NULL,x_TERR_ID),
           decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_TYPE_USG_ID),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row( x_TERR_QTYPE_USG_ID          IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_QTYPE_USGS_ALL
    WHERE TERR_QTYPE_USG_ID = x_TERR_QTYPE_USG_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_QTYPE_USGS_all
    SET
             TERR_QTYPE_USG_ID = decode( x_TERR_QTYPE_USG_ID, FND_API.G_MISS_NUM,TERR_QTYPE_USG_ID,x_TERR_QTYPE_USG_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_ID = decode( x_TERR_ID, FND_API.G_MISS_NUM,TERR_ID,x_TERR_ID),
             QUAL_TYPE_USG_ID = decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM,QUAL_TYPE_USG_ID,x_QUAL_TYPE_USG_ID),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID)
    where TERR_QTYPE_USG_ID = x_TERR_QTYPE_USG_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_QTYPE_USG_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_QTYPE_USGS_ALL
         WHERE TERR_QTYPE_USG_ID = x_TERR_QTYPE_USG_ID
         FOR UPDATE of TERR_QTYPE_USG_ID NOWAIT;
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
           (    ( Recinfo.TERR_QTYPE_USG_ID = x_TERR_QTYPE_USG_ID)
            OR (    ( Recinfo.TERR_QTYPE_USG_ID is NULL )
                AND (  x_TERR_QTYPE_USG_ID is NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY is NULL )
                AND (  x_LAST_UPDATED_BY is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE is NULL )
                AND (  x_LAST_UPDATE_DATE is NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY is NULL )
                AND (  x_CREATED_BY is NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE is NULL )
                AND (  x_CREATION_DATE is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN is NULL )
                AND (  x_LAST_UPDATE_LOGIN is NULL )))
       AND (    ( Recinfo.TERR_ID = x_TERR_ID)
            OR (    ( Recinfo.TERR_ID is NULL )
                AND (  x_TERR_ID is NULL )))
       AND (    ( Recinfo.QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID)
            OR (    ( Recinfo.QUAL_TYPE_USG_ID is NULL )
                AND (  x_QUAL_TYPE_USG_ID is NULL )))
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

END JTF_TERR_QTYPE_USGS_PKG;

/
