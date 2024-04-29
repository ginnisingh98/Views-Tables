--------------------------------------------------------
--  DDL for Package Body JTF_TERR_CNR_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_CNR_GROUPS_PKG" AS
/* $Header: jtfvtcgb.pls 120.0 2005/06/02 18:22:38 appldev ship $ */

-- 01/23/01  Amit Patel - Created package body for JTF_TERR_CNR_GROUPS_PKG

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2
 )IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_CNR_GROUPS
            WHERE CNR_GROUP_ID = x_CNR_GROUP_ID;
   CURSOR C2 IS SELECT JTF_TERR_CNR_GROUPS_s.nextval FROM sys.dual;
BEGIN
   If (x_CNR_GROUP_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_CNR_GROUP_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_CNR_GROUPS(
           CNR_GROUP_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           NAME,
           DESCRIPTION,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
          ) VALUES (
          x_CNR_GROUP_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_NAME, FND_API.G_MISS_CHAR, NULL,x_NAME),
           decode( x_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_DESCRIPTION),
           decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE_CATEGORY),
           decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE1),
           decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE2),
           decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE3),
           decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE4),
           decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE5),
           decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE6),
           decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE7),
           decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE8),
           decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE9),
           decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE10),
           decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE11),
           decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE12),
           decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE13),
           decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE14),
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15)          );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_CNR_GROUP_ID                        IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_CNR_GROUPS
    WHERE CNR_GROUP_ID = x_CNR_GROUP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2
 ) IS
 BEGIN
    Update JTF_TERR_CNR_GROUPS
    SET
             CNR_GROUP_ID = decode( x_CNR_GROUP_ID, FND_API.G_MISS_NUM,CNR_GROUP_ID,x_CNR_GROUP_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             NAME = decode( x_NAME, FND_API.G_MISS_CHAR,NAME,x_NAME),
             DESCRIPTION = decode( x_DESCRIPTION, FND_API.G_MISS_CHAR,DESCRIPTION,x_DESCRIPTION),
             ATTRIBUTE_CATEGORY = decode( x_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR,ATTRIBUTE_CATEGORY,x_ATTRIBUTE_CATEGORY),
             ATTRIBUTE1 = decode( x_ATTRIBUTE1, FND_API.G_MISS_CHAR,ATTRIBUTE1,x_ATTRIBUTE1),
             ATTRIBUTE2 = decode( x_ATTRIBUTE2, FND_API.G_MISS_CHAR,ATTRIBUTE2,x_ATTRIBUTE2),
             ATTRIBUTE3 = decode( x_ATTRIBUTE3, FND_API.G_MISS_CHAR,ATTRIBUTE3,x_ATTRIBUTE3),
             ATTRIBUTE4 = decode( x_ATTRIBUTE4, FND_API.G_MISS_CHAR,ATTRIBUTE4,x_ATTRIBUTE4),
             ATTRIBUTE5 = decode( x_ATTRIBUTE5, FND_API.G_MISS_CHAR,ATTRIBUTE5,x_ATTRIBUTE5),
             ATTRIBUTE6 = decode( x_ATTRIBUTE6, FND_API.G_MISS_CHAR,ATTRIBUTE6,x_ATTRIBUTE6),
             ATTRIBUTE7 = decode( x_ATTRIBUTE7, FND_API.G_MISS_CHAR,ATTRIBUTE7,x_ATTRIBUTE7),
             ATTRIBUTE8 = decode( x_ATTRIBUTE8, FND_API.G_MISS_CHAR,ATTRIBUTE8,x_ATTRIBUTE8),
             ATTRIBUTE9 = decode( x_ATTRIBUTE9, FND_API.G_MISS_CHAR,ATTRIBUTE9,x_ATTRIBUTE9),
             ATTRIBUTE10 = decode( x_ATTRIBUTE10, FND_API.G_MISS_CHAR,ATTRIBUTE10,x_ATTRIBUTE10),
             ATTRIBUTE11 = decode( x_ATTRIBUTE11, FND_API.G_MISS_CHAR,ATTRIBUTE11,x_ATTRIBUTE11),
             ATTRIBUTE12 = decode( x_ATTRIBUTE12, FND_API.G_MISS_CHAR,ATTRIBUTE12,x_ATTRIBUTE12),
             ATTRIBUTE13 = decode( x_ATTRIBUTE13, FND_API.G_MISS_CHAR,ATTRIBUTE13,x_ATTRIBUTE13),
             ATTRIBUTE14 = decode( x_ATTRIBUTE14, FND_API.G_MISS_CHAR,ATTRIBUTE14,x_ATTRIBUTE14),
             ATTRIBUTE15 = decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR,ATTRIBUTE15,x_ATTRIBUTE15)
     where cnr_group_id = X_cnr_group_id;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
                  x_ATTRIBUTE1                     IN     VARCHAR2,
                  x_ATTRIBUTE2                     IN     VARCHAR2,
                  x_ATTRIBUTE3                     IN     VARCHAR2,
                  x_ATTRIBUTE4                     IN     VARCHAR2,
                  x_ATTRIBUTE5                     IN     VARCHAR2,
                  x_ATTRIBUTE6                     IN     VARCHAR2,
                  x_ATTRIBUTE7                     IN     VARCHAR2,
                  x_ATTRIBUTE8                     IN     VARCHAR2,
                  x_ATTRIBUTE9                     IN     VARCHAR2,
                  x_ATTRIBUTE10                    IN     VARCHAR2,
                  x_ATTRIBUTE11                    IN     VARCHAR2,
                  x_ATTRIBUTE12                    IN     VARCHAR2,
                  x_ATTRIBUTE13                    IN     VARCHAR2,
                  x_ATTRIBUTE14                    IN     VARCHAR2,
                  x_ATTRIBUTE15                    IN     VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_CNR_GROUPS
         WHERE CNR_GROUP_ID = x_CNR_GROUP_ID
         FOR UPDATE of CNR_GROUP_ID NOWAIT;
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
           (    ( Recinfo.CNR_GROUP_ID = x_CNR_GROUP_ID)
            OR (    ( Recinfo.CNR_GROUP_ID is NULL )
                AND (  x_CNR_GROUP_ID is NULL )))
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
       AND (    ( Recinfo.NAME = x_NAME)
            OR (    ( Recinfo.NAME is NULL )
                AND (  x_NAME is NULL )))
       AND (    ( Recinfo.DESCRIPTION = x_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION is NULL )
                AND (  x_DESCRIPTION is NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = x_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY is NULL )
                AND (  x_ATTRIBUTE_CATEGORY is NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = x_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 is NULL )
                AND (  x_ATTRIBUTE1 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = x_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 is NULL )
                AND (  x_ATTRIBUTE2 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = x_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 is NULL )
                AND (  x_ATTRIBUTE3 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = x_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 is NULL )
                AND (  x_ATTRIBUTE4 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = x_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 is NULL )
                AND (  x_ATTRIBUTE5 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = x_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 is NULL )
                AND (  x_ATTRIBUTE6 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = x_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 is NULL )
                AND (  x_ATTRIBUTE7 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = x_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 is NULL )
                AND (  x_ATTRIBUTE8 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = x_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 is NULL )
                AND (  x_ATTRIBUTE9 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = x_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 is NULL )
                AND (  x_ATTRIBUTE10 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = x_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 is NULL )
                AND (  x_ATTRIBUTE11 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = x_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 is NULL )
                AND (  x_ATTRIBUTE12 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = x_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 is NULL )
                AND (  x_ATTRIBUTE13 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = x_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 is NULL )
                AND (  x_ATTRIBUTE14 is NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = x_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 is NULL )
                AND (  x_ATTRIBUTE15 is NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END JTF_TERR_CNR_GROUPS_PKG;

/
