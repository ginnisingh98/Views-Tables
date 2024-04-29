--------------------------------------------------------
--  DDL for Package Body JTF_TERR_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_QUAL_PKG" AS
/* $Header: jtfvtqlb.pls 120.0 2005/06/02 18:22:52 appldev ship $ */

-----------------------------------------------------------------------
--    HISTORY
--      11/20/99    VNEDUNGA         Changing qualifer Mode form
--                                   number to varchar2
--      01/20/99    VNEDUNGA         Changing update/delet/lock_row
--                                   to use terr_qual_id instead of rowid
--      01/20/99    VNEDUNGA         Change lock_row = NULL -> IS NULL
--      02/24/00    vnedunga         fixing decode for date fields
--
--    End of Comments
------------------------------------------------------------------------

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_QUAL_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_USE_TO_NAME_FLAG               IN     VARCHAR2,
                  x_GENERATE_FLAG                  IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_QUAL_ALL
            WHERE TERR_QUAL_ID = x_TERR_QUAL_ID;
   CURSOR C2 IS SELECT JTF_TERR_QUAL_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_QUAL_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_QUAL_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_QUAL_ALL(
           TERR_QUAL_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           QUAL_USG_ID,
           USE_TO_NAME_FLAG,
           GENERATE_FLAG,
           OVERLAP_ALLOWED_FLAG,
           QUALIFIER_MODE,
           ORG_ID
          ) VALUES (
          x_TERR_QUAL_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_ID, FND_API.G_MISS_NUM, NULL,x_TERR_ID),
           decode( x_QUAL_USG_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_USG_ID),
           decode( x_USE_TO_NAME_FLAG, FND_API.G_MISS_CHAR, NULL,x_USE_TO_NAME_FLAG),
           decode( x_GENERATE_FLAG, FND_API.G_MISS_CHAR, NULL,x_GENERATE_FLAG),
           decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR, NULL,x_OVERLAP_ALLOWED_FLAG),
           decode( x_QUALIFIER_MODE, FND_API.G_MISS_CHAR, NULL,x_QUALIFIER_MODE),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(x_TERR_QUAL_ID                   IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_QUAL_ALL
    WHERE TERR_QUAL_ID = x_TERR_QUAL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_USE_TO_NAME_FLAG               IN     VARCHAR2,
                  x_GENERATE_FLAG                  IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_QUAL_ALL
    SET
             TERR_QUAL_ID = decode( x_TERR_QUAL_ID, FND_API.G_MISS_NUM,TERR_QUAL_ID,x_TERR_QUAL_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_ID = decode( x_TERR_ID, FND_API.G_MISS_NUM,TERR_ID,x_TERR_ID),
             QUAL_USG_ID = decode( x_QUAL_USG_ID, FND_API.G_MISS_NUM,QUAL_USG_ID,x_QUAL_USG_ID),
             USE_TO_NAME_FLAG = decode( x_USE_TO_NAME_FLAG, FND_API.G_MISS_CHAR,USE_TO_NAME_FLAG,x_USE_TO_NAME_FLAG),
             GENERATE_FLAG = decode( x_GENERATE_FLAG, FND_API.G_MISS_CHAR,GENERATE_FLAG,x_GENERATE_FLAG),
             OVERLAP_ALLOWED_FLAG = decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR,OVERLAP_ALLOWED_FLAG,x_OVERLAP_ALLOWED_FLAG),
             QUALIFIER_MODE = decode( x_QUALIFIER_MODE, FND_API.G_MISS_CHAR,QUALIFIER_MODE,x_QUALIFIER_MODE),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where TERR_QUAL_ID = x_TERR_QUAL_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_USE_TO_NAME_FLAG               IN     VARCHAR2,
                  x_GENERATE_FLAG                  IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_QUAL_ALL
         WHERE TERR_QUAL_ID = x_TERR_QUAL_ID
         FOR UPDATE of TERR_QUAL_ID NOWAIT;
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
           (    ( Recinfo.TERR_QUAL_ID = x_TERR_QUAL_ID)
            OR (    ( Recinfo.TERR_QUAL_ID IS NULL )
                AND (  x_TERR_QUAL_ID IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  x_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  x_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  x_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  x_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  x_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.TERR_ID = x_TERR_ID)
            OR (    ( Recinfo.TERR_ID IS NULL )
                AND (  x_TERR_ID IS NULL )))
       AND (    ( Recinfo.QUAL_USG_ID = x_QUAL_USG_ID)
            OR (    ( Recinfo.QUAL_USG_ID IS NULL )
                AND (  x_QUAL_USG_ID IS NULL )))
       AND (    ( Recinfo.USE_TO_NAME_FLAG = x_USE_TO_NAME_FLAG)
            OR (    ( Recinfo.USE_TO_NAME_FLAG IS NULL )
                AND (  x_USE_TO_NAME_FLAG IS NULL )))
       AND (    ( Recinfo.GENERATE_FLAG = x_GENERATE_FLAG)
            OR (    ( Recinfo.GENERATE_FLAG IS NULL )
                AND (  x_GENERATE_FLAG IS NULL )))
       AND (    ( Recinfo.OVERLAP_ALLOWED_FLAG = x_OVERLAP_ALLOWED_FLAG)
            OR (    ( Recinfo.OVERLAP_ALLOWED_FLAG IS NULL )
                AND (  x_OVERLAP_ALLOWED_FLAG IS NULL )))
       AND (    ( Recinfo.QUALIFIER_MODE = x_QUALIFIER_MODE)
            OR (    ( Recinfo.QUALIFIER_MODE IS NULL )
                AND (  x_QUALIFIER_MODE IS NULL )))
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

END JTF_TERR_QUAL_PKG;

/
