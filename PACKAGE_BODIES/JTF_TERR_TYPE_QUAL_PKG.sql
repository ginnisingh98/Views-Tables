--------------------------------------------------------
--  DDL for Package Body JTF_TERR_TYPE_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_TYPE_QUAL_PKG" as
/* $Header: jtfvttqb.pls 120.1 2005/06/24 00:26:24 jradhakr ship $ */

-----------------------------------------------------------------------
--    HISTORY
--      11/20/99    VNEDUNGA         Changing qualifer Mode form
--                                   number to varchar2
--      01/20/00    VNEDUNGA	     Changing Update/Lock row procedures
--                                   to use terr_type_qual_id instead of
--                                   row_id
--      01/20/00  VNEDUNGA           Changing = NULL to IS NULL
--      02/17/00  VNEDUNGA           Adding ORG_ID to the table handler
--                                   procedures
--      02/24/00  vnedunga           fixing decode for date fields
--
--    End of Comments
------------------------------------------------------------------------

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_TYPE_QUAL
            WHERE TERR_TYPE_QUAL_ID = x_TERR_TYPE_QUAL_ID;
   CURSOR C2 IS SELECT JTF_TERR_TYPE_QUAL_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_TYPE_QUAL_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_TYPE_QUAL_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_TYPE_QUAL(
           TERR_TYPE_QUAL_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           QUAL_USG_ID,
           TERR_TYPE_ID,
           EXCLUSIVE_USE_FLAG,
           OVERLAP_ALLOWED_FLAG,
           IN_USE_FLAG,
           QUALIFIER_MODE,
           ORG_ID
          ) VALUES (
          x_TERR_TYPE_QUAL_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_QUAL_USG_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_USG_ID),
           decode( x_TERR_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_TERR_TYPE_ID),
           decode( x_EXCLUSIVE_USE_FLAG, FND_API.G_MISS_CHAR, NULL,x_EXCLUSIVE_USE_FLAG),
           decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR, NULL,x_OVERLAP_ALLOWED_FLAG),
           decode( x_IN_USE_FLAG, FND_API.G_MISS_CHAR, NULL,x_IN_USE_FLAG),
           decode( x_QUALIFIER_MODE, FND_API.G_MISS_CHAR, NULL,x_QUALIFIER_MODE),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL, x_ORG_ID) );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_TERR_TYPE_QUAL_ID              IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_TYPE_QUAL
    WHERE TERR_TYPE_QUAL_ID = x_TERR_TYPE_QUAL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_TYPE_QUAL
    SET
             TERR_TYPE_QUAL_ID = decode( x_TERR_TYPE_QUAL_ID, FND_API.G_MISS_NUM,TERR_TYPE_QUAL_ID,x_TERR_TYPE_QUAL_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             QUAL_USG_ID = decode( x_QUAL_USG_ID, FND_API.G_MISS_NUM,QUAL_USG_ID,x_QUAL_USG_ID),
             TERR_TYPE_ID = decode( x_TERR_TYPE_ID, FND_API.G_MISS_NUM,TERR_TYPE_ID,x_TERR_TYPE_ID),
             EXCLUSIVE_USE_FLAG = decode( x_EXCLUSIVE_USE_FLAG, FND_API.G_MISS_CHAR,EXCLUSIVE_USE_FLAG,x_EXCLUSIVE_USE_FLAG),
             OVERLAP_ALLOWED_FLAG = decode( x_OVERLAP_ALLOWED_FLAG, FND_API.G_MISS_CHAR,OVERLAP_ALLOWED_FLAG,x_OVERLAP_ALLOWED_FLAG),
             IN_USE_FLAG = decode( x_IN_USE_FLAG, FND_API.G_MISS_CHAR,IN_USE_FLAG,x_IN_USE_FLAG),
             QUALIFIER_MODE = decode( x_QUALIFIER_MODE, FND_API.G_MISS_CHAR,QUALIFIER_MODE,x_QUALIFIER_MODE),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID)
    where TERR_TYPE_QUAL_ID = X_TERR_TYPE_QUAL_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_TYPE_QUAL_ID              IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_TERR_TYPE_ID                   IN     NUMBER,
                  x_EXCLUSIVE_USE_FLAG             IN     VARCHAR2,
                  x_OVERLAP_ALLOWED_FLAG           IN     VARCHAR2,
                  x_IN_USE_FLAG                    IN     VARCHAR2,
                  x_QUALIFIER_MODE                 IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_TYPE_QUAL
         WHERE TERR_TYPE_QUAL_ID = x_TERR_TYPE_QUAL_ID
         FOR UPDATE of TERR_TYPE_QUAL_ID NOWAIT;
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
           (    ( Recinfo.TERR_TYPE_QUAL_ID = x_TERR_TYPE_QUAL_ID)
            OR (    ( Recinfo.TERR_TYPE_QUAL_ID IS NULL )
                AND (  x_TERR_TYPE_QUAL_ID IS NULL )))
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
       AND (    ( Recinfo.QUAL_USG_ID = x_QUAL_USG_ID)
            OR (    ( Recinfo.QUAL_USG_ID IS NULL )
                AND (  x_QUAL_USG_ID IS NULL )))
       AND (    ( Recinfo.TERR_TYPE_ID = x_TERR_TYPE_ID)
            OR (    ( Recinfo.TERR_TYPE_ID IS NULL )
                AND (  x_TERR_TYPE_ID IS NULL )))
       AND (    ( Recinfo.EXCLUSIVE_USE_FLAG = x_EXCLUSIVE_USE_FLAG)
            OR (    ( Recinfo.EXCLUSIVE_USE_FLAG IS NULL )
                AND (  x_EXCLUSIVE_USE_FLAG IS NULL )))
       AND (    ( Recinfo.OVERLAP_ALLOWED_FLAG = x_OVERLAP_ALLOWED_FLAG)
            OR (    ( Recinfo.OVERLAP_ALLOWED_FLAG IS NULL )
                AND (  x_OVERLAP_ALLOWED_FLAG IS NULL )))
       AND (    ( Recinfo.IN_USE_FLAG = x_IN_USE_FLAG)
            OR (    ( Recinfo.IN_USE_FLAG IS NULL )
                AND (  x_IN_USE_FLAG IS NULL )))
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

END JTF_TERR_TYPE_QUAL_PKG;

/
