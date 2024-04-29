--------------------------------------------------------
--  DDL for Package Body JTF_TERR_RSC_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_RSC_ACCESS_PKG" AS
/* $Header: jtfvrsab.pls 120.2 2005/09/08 17:55:09 applrt ship $ */

-- 01/20/00  VNEDUNGA  Changing Update/Lock_Row procedure to use
--                     TERR_RSC_ACCESS_ID instead of rowid
-- 01/20/00  VNEDUNGA  Changing = NULL -> IS NULL
-- 02/22/00  JDOCHERT  Passing in ORG_ID to Insert/Update/Lock


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_RSC_ACCESS_ALL
            WHERE TERR_RSC_ACCESS_ID = x_TERR_RSC_ACCESS_ID;
   CURSOR C2 IS SELECT JTF_TERR_RSC_ACCESS_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_RSC_ACCESS_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_RSC_ACCESS_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_RSC_ACCESS_ALL(
           TERR_RSC_ACCESS_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_RSC_ID,
           ACCESS_TYPE,
	   TRANS_ACCESS_CODE,
           ORG_ID
          ) VALUES (
          x_TERR_RSC_ACCESS_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_RSC_ID, FND_API.G_MISS_NUM, NULL,x_TERR_RSC_ID),
           decode( x_ACCESS_TYPE, FND_API.G_MISS_CHAR, NULL,x_ACCESS_TYPE),
           decode( x_TRANS_ACCESS_CODE, FND_API.G_MISS_CHAR, NULL,x_TRANS_ACCESS_CODE),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID)
           );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_TERR_RSC_ACCESS_ID             IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_RSC_ACCESS_ALL
    WHERE TERR_RSC_ACCESS_ID = x_TERR_RSC_ACCESS_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_RSC_ACCESS_ALL
    SET
             TERR_RSC_ACCESS_ID = decode( x_TERR_RSC_ACCESS_ID, FND_API.G_MISS_NUM,TERR_RSC_ACCESS_ID,x_TERR_RSC_ACCESS_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_RSC_ID = decode( x_TERR_RSC_ID, FND_API.G_MISS_NUM,TERR_RSC_ID,x_TERR_RSC_ID),
             ACCESS_TYPE = decode( x_ORG_ID, FND_API.G_MISS_CHAR,ACCESS_TYPE,x_ACCESS_TYPE),
             TRANS_ACCESS_CODE = decode( x_ORG_ID, FND_API.G_MISS_CHAR,TRANS_ACCESS_CODE,x_TRANS_ACCESS_CODE),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where TERR_RSC_ACCESS_ID = X_TERR_RSC_ACCESS_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ACCESS_ID             IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_ACCESS_TYPE                    IN     VARCHAR2,
		  x_TRANS_ACCESS_CODE		   IN	  VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_RSC_ACCESS_ALL
         WHERE TERR_RSC_ACCESS_ID = x_TERR_RSC_ACCESS_ID
         FOR UPDATE of TERR_RSC_ACCESS_ID NOWAIT;
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
           (    ( Recinfo.TERR_RSC_ACCESS_ID = x_TERR_RSC_ACCESS_ID)
            OR (    ( Recinfo.TERR_RSC_ACCESS_ID IS NULL )
                AND (  x_TERR_RSC_ACCESS_ID IS NULL )))
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
       AND (    ( Recinfo.TERR_RSC_ID = x_TERR_RSC_ID)
            OR (    ( Recinfo.TERR_RSC_ID IS NULL )
                AND (  x_TERR_RSC_ID IS NULL )))
       AND (    ( Recinfo.ACCESS_TYPE = x_ACCESS_TYPE)
            OR (    ( Recinfo.ACCESS_TYPE IS NULL )
                AND (  x_ACCESS_TYPE IS NULL )))
       AND (    ( Recinfo.TRANS_ACCESS_CODE = x_TRANS_ACCESS_CODE)
            OR (    ( Recinfo.TRANS_ACCESS_CODE IS NULL )
                AND (  x_TRANS_ACCESS_CODE IS NULL )))
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

END JTF_TERR_RSC_ACCESS_PKG;

/
