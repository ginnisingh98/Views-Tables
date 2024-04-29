--------------------------------------------------------
--  DDL for Package Body JTF_TERR_RSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_RSC_PKG" AS
/* $Header: jtfvtrcb.pls 120.2.12010000.2 2009/09/07 06:31:10 vpalle ship $ */

-- 01/20/99  VNEDUNGA  Changing update/lock row procedure to use
-- 01/20/00  VNEDUNGA  Changing = NULL to IS NULL
-- 02/22/00  JDOCHERT  Passing in ORG_ID to Insert/Update/Lock
-- 03/16/00  VNEDUNGA  Adding Full access flag
-- 06/08/00  VNEDUNGA  Adding group_id flag
-- 06/26/02  ARPATEL   Adding person_id column to Insert row
-- 01/09/03  JDOCHERT  BUG#2739970


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_RSC_ALL
            WHERE TERR_RSC_ID = x_TERR_RSC_ID;
   CURSOR C2 IS SELECT JTF_TERR_RSC_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_RSC_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_RSC_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_RSC_ALL(
           TERR_RSC_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           RESOURCE_ID,
           GROUP_ID,
           RESOURCE_TYPE,
           ROLE,
           PRIMARY_CONTACT_FLAG,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           FULL_ACCESS_FLAG,
           ORG_ID
          ) VALUES (
          x_TERR_RSC_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_ID, FND_API.G_MISS_NUM, NULL,x_TERR_ID),
           decode( x_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,x_RESOURCE_ID),
           decode( x_GROUP_ID, FND_API.G_MISS_NUM, NULL,x_GROUP_ID),
           decode( x_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, x_RESOURCE_TYPE),
           decode( x_ROLE, FND_API.G_MISS_CHAR, NULL, x_ROLE),
           decode( x_PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,x_PRIMARY_CONTACT_FLAG),
           decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_START_DATE_ACTIVE),
           decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE_ACTIVE),
           decode( x_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL,x_FULL_ACCESS_FLAG),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID)
           );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_RSC_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
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
   CURSOR C IS SELECT rowid FROM JTF_TERR_RSC_ALL
            WHERE TERR_RSC_ID = x_TERR_RSC_ID;
   CURSOR C2 IS SELECT JTF_TERR_RSC_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_RSC_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_RSC_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_RSC_ALL(
           TERR_RSC_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           TERR_ID,
           RESOURCE_ID,
           GROUP_ID,
           RESOURCE_TYPE,
           ROLE,
           PRIMARY_CONTACT_FLAG,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           FULL_ACCESS_FLAG,
           ORG_ID,
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
          x_TERR_RSC_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_ID, FND_API.G_MISS_NUM, NULL,x_TERR_ID),
           decode( x_RESOURCE_ID, FND_API.G_MISS_NUM, NULL,x_RESOURCE_ID),
           decode( x_GROUP_ID, FND_API.G_MISS_NUM, NULL,x_GROUP_ID),
           decode( x_RESOURCE_TYPE, FND_API.G_MISS_CHAR, NULL, x_RESOURCE_TYPE),
           decode( x_ROLE, FND_API.G_MISS_CHAR, NULL, x_ROLE),
           decode( x_PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR, NULL,x_PRIMARY_CONTACT_FLAG),
           decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_START_DATE_ACTIVE),
           decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE_ACTIVE),
           decode( x_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, NULL,x_FULL_ACCESS_FLAG),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID),
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
           decode( x_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL,x_ATTRIBUTE15)
           );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;


PROCEDURE Delete_Row(                  x_TERR_RSC_ID                    IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_RSC_ALL
    WHERE TERR_RSC_ID = x_TERR_RSC_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER,
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
    Update JTF_TERR_RSC_ALL
    SET
             TERR_RSC_ID = decode( x_TERR_RSC_ID, FND_API.G_MISS_NUM,TERR_RSC_ID,x_TERR_RSC_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_ID = decode( x_TERR_ID, FND_API.G_MISS_NUM,TERR_ID,x_TERR_ID),
             RESOURCE_ID = decode( x_RESOURCE_ID, FND_API.G_MISS_NUM, RESOURCE_ID, x_RESOURCE_ID),
             GROUP_ID = decode( x_GROUP_ID, FND_API.G_MISS_NUM, GROUP_ID, x_GROUP_ID),
             RESOURCE_TYPE = decode( x_RESOURCE_TYPE, FND_API.G_MISS_CHAR, RESOURCE_TYPE, x_RESOURCE_TYPE),
             ROLE = decode( x_ROLE, FND_API.G_MISS_CHAR, ROLE, x_ROLE),
             PRIMARY_CONTACT_FLAG = decode( x_PRIMARY_CONTACT_FLAG, FND_API.G_MISS_CHAR,PRIMARY_CONTACT_FLAG,x_PRIMARY_CONTACT_FLAG),
             START_DATE_ACTIVE = decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE,START_DATE_ACTIVE,x_START_DATE_ACTIVE),
             END_DATE_ACTIVE = decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE,END_DATE_ACTIVE,x_END_DATE_ACTIVE),
             FULL_ACCESS_FLAG = decode( x_FULL_ACCESS_FLAG, FND_API.G_MISS_CHAR, FULL_ACCESS_FLAG,x_FULL_ACCESS_FLAG),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID),
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
    where TERR_RSC_ID = x_TERR_RSC_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_RSC_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_GROUP_ID                       IN     NUMBER,
                  x_RESOURCE_TYPE                  IN     VARCHAR2,
                  x_ROLE                           IN     VARCHAR2,
                  x_PRIMARY_CONTACT_FLAG           IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_FULL_ACCESS_FLAG               IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_RSC_ALL
         WHERE TERR_RSC_ID = x_TERR_RSC_ID
         FOR UPDATE of TERR_RSC_ID NOWAIT;
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
           (    ( Recinfo.TERR_RSC_ID = x_TERR_RSC_ID)
            OR (    ( Recinfo.TERR_RSC_ID IS NULL )
                AND (  x_TERR_RSC_ID IS NULL )))
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
       AND (    ( Recinfo.RESOURCE_ID = x_RESOURCE_ID)
            OR (    ( Recinfo.RESOURCE_ID IS NULL )
                AND (  x_RESOURCE_ID IS NULL )))
       AND (    ( Recinfo.GROUP_ID = x_GROUP_ID)
            OR (    ( Recinfo.GROUP_ID IS NULL )
                AND (  x_GROUP_ID IS NULL )))
       AND (    ( Recinfo.RESOURCE_TYPE = x_RESOURCE_TYPE)
            OR (    ( Recinfo.RESOURCE_TYPE IS NULL )
                AND (  x_RESOURCE_TYPE IS NULL )))
       AND (    ( Recinfo.ROLE = x_ROLE)
            OR (    ( Recinfo.ROLE IS NULL )
                AND (  x_ROLE IS NULL )))
       AND (    ( Recinfo.PRIMARY_CONTACT_FLAG = x_PRIMARY_CONTACT_FLAG)
            OR (    ( Recinfo.PRIMARY_CONTACT_FLAG IS NULL )
                AND (  x_PRIMARY_CONTACT_FLAG IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = x_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  x_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = x_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  x_END_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.FULL_ACCESS_FLAG  = x_FULL_ACCESS_FLAG)
            OR (    ( Recinfo.FULL_ACCESS_FLAG IS NULL )
                AND (  x_FULL_ACCESS_FLAG IS NULL )))
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

END JTF_TERR_RSC_PKG;

/
