--------------------------------------------------------
--  DDL for Package Body JTF_TERR_CNR_GROUP_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_CNR_GROUP_VALUES_PKG" AS
/* $Header: jtfvtcvb.pls 120.0 2005/06/02 18:22:40 appldev ship $ */

--  05/15/01   ARPATEL  Created table handlers
--  05/16/01   ARPATEL  Added start_date_active and end_date_active
--  04/25/02   ARPATEL  Removed SECURITY_GROUP_ID references for bug#2269867

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_CNR_GROUP_VALUES
            WHERE CNR_GROUP_VALUE_ID = x_CNR_GROUP_VALUE_ID;
   CURSOR C2 IS SELECT JTF_TERR_CNR_GROUP_VALUES_s.nextval FROM sys.dual;
BEGIN
   If (x_CNR_GROUP_VALUE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_CNR_GROUP_VALUE_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_CNR_GROUP_VALUES(
           CNR_GROUP_VALUE_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           CNR_GROUP_ID,
           COMPARISON_OPERATOR,
           LOW_VALUE_CHAR,
           HIGH_VALUE_CHAR,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           ORG_ID
          ) VALUES (
          x_CNR_GROUP_VALUE_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_CNR_GROUP_ID, FND_API.G_MISS_NUM, NULL,x_CNR_GROUP_ID),
           decode( x_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL,x_COMPARISON_OPERATOR),
           decode( x_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL,x_LOW_VALUE_CHAR),
           decode( x_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL,x_HIGH_VALUE_CHAR),
           decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_START_DATE_ACTIVE),
           decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE_ACTIVE),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID)
           );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_CNR_GROUP_VALUE_ID                  IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_CNR_GROUP_VALUES
    WHERE CNR_GROUP_VALUE_ID = x_CNR_GROUP_VALUE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_CNR_GROUP_VALUES
    SET
             CNR_GROUP_VALUE_ID = decode( x_CNR_GROUP_VALUE_ID, FND_API.G_MISS_NUM,CNR_GROUP_VALUE_ID,x_CNR_GROUP_VALUE_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             CNR_GROUP_ID = decode( x_CNR_GROUP_ID, FND_API.G_MISS_NUM,CNR_GROUP_ID,x_CNR_GROUP_ID),
             COMPARISON_OPERATOR = decode( x_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR,COMPARISON_OPERATOR,x_COMPARISON_OPERATOR),
             LOW_VALUE_CHAR = decode( x_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR,LOW_VALUE_CHAR,x_LOW_VALUE_CHAR),
             HIGH_VALUE_CHAR = decode( x_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR,HIGH_VALUE_CHAR,x_HIGH_VALUE_CHAR),
             START_DATE_ACTIVE = decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE,START_DATE_ACTIVE,x_START_DATE_ACTIVE),
             END_DATE_ACTIVE = decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE,END_DATE_ACTIVE,x_END_DATE_ACTIVE),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where CNR_GROUP_VALUE_ID = X_CNR_GROUP_VALUE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_CNR_GROUP_VALUES
         WHERE CNR_GROUP_VALUE_ID = x_CNR_GROUP_VALUE_ID
         FOR UPDATE of CNR_GROUP_VALUE_ID NOWAIT;
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
           (    ( Recinfo.CNR_GROUP_VALUE_ID = x_CNR_GROUP_VALUE_ID)
            OR (    ( Recinfo.CNR_GROUP_VALUE_ID IS NULL )
                AND (  x_CNR_GROUP_VALUE_ID IS NULL )))
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
       AND (    ( Recinfo.CNR_GROUP_ID = x_CNR_GROUP_ID)
            OR (    ( Recinfo.CNR_GROUP_ID IS NULL )
                AND (  x_CNR_GROUP_ID IS NULL )))
       AND (    ( Recinfo.COMPARISON_OPERATOR = x_COMPARISON_OPERATOR)
            OR (    ( Recinfo.COMPARISON_OPERATOR IS NULL )
                AND (  x_COMPARISON_OPERATOR IS NULL )))
       AND (    ( Recinfo.LOW_VALUE_CHAR = x_LOW_VALUE_CHAR)
            OR (    ( Recinfo.LOW_VALUE_CHAR IS NULL )
                AND (  x_LOW_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.HIGH_VALUE_CHAR = x_HIGH_VALUE_CHAR)
            OR (    ( Recinfo.HIGH_VALUE_CHAR IS NULL )
                AND (  x_HIGH_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = x_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  x_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = x_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  x_END_DATE_ACTIVE IS NULL )))
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


END JTF_TERR_CNR_GROUP_VALUES_PKG;

/
