--------------------------------------------------------
--  DDL for Package Body JTF_QUAL_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_QUAL_TYPES_PKG" as
/* $Header: jtfvqtyb.pls 120.0 2005/06/02 18:22:17 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_QUAL_TYPE_ID                   IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_QUAL_TYPES_ALL
            WHERE QUAL_TYPE_ID = x_QUAL_TYPE_ID;
   CURSOR C2 IS SELECT JTF_QUAL_TYPES_s.nextval FROM sys.dual;
BEGIN
   If (x_QUAL_TYPE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_QUAL_TYPE_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_QUAL_TYPES_ALL(
           QUAL_TYPE_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           NAME,
           DESCRIPTION,
           SELECT_CLAUSE,
           WHERE_CLAUSE,
           VIEW_NAME,
           VIEW_DDL_FILENAME,
           RELATED_ID1,
           RELATED_ID2,
           RELATED_ID3,
           RELATED_ID4,
           RELATED_ID5,
           ORG_ID
          ) VALUES (
          x_QUAL_TYPE_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_NAME, FND_API.G_MISS_CHAR, NULL,x_NAME),
           decode( x_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_DESCRIPTION),
           decode( x_SELECT_CLAUSE, FND_API.G_MISS_CHAR, NULL,x_SELECT_CLAUSE),
           decode( x_WHERE_CLAUSE, FND_API.G_MISS_CHAR, NULL,x_WHERE_CLAUSE),
           decode( x_VIEW_NAME, FND_API.G_MISS_CHAR, NULL,x_VIEW_NAME),
           decode( x_VIEW_DDL_FILENAME, FND_API.G_MISS_CHAR, NULL,x_VIEW_DDL_FILENAME),
           decode( x_RELATED_ID1, FND_API.G_MISS_NUM, NULL,x_RELATED_ID1),
           decode( x_RELATED_ID2, FND_API.G_MISS_NUM, NULL,x_RELATED_ID2),
           decode( x_RELATED_ID3, FND_API.G_MISS_NUM, NULL,x_RELATED_ID3),
           decode( x_RELATED_ID4, FND_API.G_MISS_NUM, NULL,x_RELATED_ID4),
           decode( x_RELATED_ID5, FND_API.G_MISS_NUM, NULL,x_RELATED_ID5),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID));
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_QUAL_TYPE_ID                   IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_QUAL_TYPES_ALL
    WHERE QUAL_TYPE_ID = x_QUAL_TYPE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_QUAL_TYPES_ALL
    SET
             QUAL_TYPE_ID = decode( x_QUAL_TYPE_ID, FND_API.G_MISS_NUM,QUAL_TYPE_ID,x_QUAL_TYPE_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             NAME = decode( x_NAME, FND_API.G_MISS_CHAR,NAME,x_NAME),
             DESCRIPTION = decode( x_DESCRIPTION, FND_API.G_MISS_CHAR,DESCRIPTION,x_DESCRIPTION),
             SELECT_CLAUSE = decode( x_SELECT_CLAUSE, FND_API.G_MISS_CHAR,SELECT_CLAUSE,x_SELECT_CLAUSE),
             WHERE_CLAUSE = decode( x_WHERE_CLAUSE, FND_API.G_MISS_CHAR,WHERE_CLAUSE,x_WHERE_CLAUSE),
             VIEW_NAME = decode( x_VIEW_NAME, FND_API.G_MISS_CHAR,VIEW_NAME,x_VIEW_NAME),
             VIEW_DDL_FILENAME = decode( x_VIEW_DDL_FILENAME, FND_API.G_MISS_CHAR,VIEW_DDL_FILENAME,x_VIEW_DDL_FILENAME),
             RELATED_ID1 = decode( x_RELATED_ID1, FND_API.G_MISS_NUM,RELATED_ID1,x_RELATED_ID1),
             RELATED_ID2 = decode( x_RELATED_ID2, FND_API.G_MISS_NUM,RELATED_ID2,x_RELATED_ID2),
             RELATED_ID3 = decode( x_RELATED_ID3, FND_API.G_MISS_NUM,RELATED_ID3,x_RELATED_ID3),
             RELATED_ID4 = decode( x_RELATED_ID4, FND_API.G_MISS_NUM,RELATED_ID4,x_RELATED_ID4),
             RELATED_ID5 = decode( x_RELATED_ID5, FND_API.G_MISS_NUM,RELATED_ID5,x_RELATED_ID5),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where QUAL_TYPE_ID = X_QUAL_TYPE_ID and
          ( ORG_ID = x_ORG_ID OR ( ORG_ID IS NULL AND X_ORG_ID IS NULL)) ;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_TYPE_ID                   IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_SELECT_CLAUSE                  IN     VARCHAR2,
                  x_WHERE_CLAUSE                   IN     VARCHAR2,
                  x_VIEW_NAME                      IN     VARCHAR2,
                  x_VIEW_DDL_FILENAME              IN     VARCHAR2,
                  x_RELATED_ID1                    IN     NUMBER,
                  x_RELATED_ID2                    IN     NUMBER,
                  x_RELATED_ID3                    IN     NUMBER,
                  x_RELATED_ID4                    IN     NUMBER,
                  x_RELATED_ID5                    IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_QUAL_TYPES_ALL
         WHERE rowid = x_Rowid
         FOR UPDATE of QUAL_TYPE_ID NOWAIT;
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
           (    ( Recinfo.QUAL_TYPE_ID = x_QUAL_TYPE_ID)
            OR (    ( Recinfo.QUAL_TYPE_ID is NULL )
                AND (  x_QUAL_TYPE_ID is NULL )))
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
       AND (    ( Recinfo.SELECT_CLAUSE = x_SELECT_CLAUSE)
            OR (    ( Recinfo.SELECT_CLAUSE is NULL )
                AND (  x_SELECT_CLAUSE is NULL )))
       AND (    ( Recinfo.WHERE_CLAUSE = x_WHERE_CLAUSE)
            OR (    ( Recinfo.WHERE_CLAUSE is NULL )
                AND (  x_WHERE_CLAUSE is NULL )))
       AND (    ( Recinfo.VIEW_NAME = x_VIEW_NAME)
            OR (    ( Recinfo.VIEW_NAME is NULL )
                AND (  x_VIEW_NAME is NULL )))
       AND (    ( Recinfo.VIEW_DDL_FILENAME = x_VIEW_DDL_FILENAME)
            OR (    ( Recinfo.VIEW_DDL_FILENAME is NULL )
                AND (  x_VIEW_DDL_FILENAME is NULL )))
       AND (    ( Recinfo.RELATED_ID1 = x_RELATED_ID1)
            OR (    ( Recinfo.RELATED_ID1 is NULL )
                AND (  x_RELATED_ID1 is NULL )))
       AND (    ( Recinfo.RELATED_ID2 = x_RELATED_ID2)
            OR (    ( Recinfo.RELATED_ID2 is NULL )
                AND (  x_RELATED_ID2 is NULL )))
       AND (    ( Recinfo.RELATED_ID3 = x_RELATED_ID3)
            OR (    ( Recinfo.RELATED_ID3 is NULL )
                AND (  x_RELATED_ID3 is NULL )))
       AND (    ( Recinfo.RELATED_ID4 = x_RELATED_ID4)
            OR (    ( Recinfo.RELATED_ID4 is NULL )
                AND (  x_RELATED_ID4 is NULL )))
       AND (    ( Recinfo.RELATED_ID5 = x_RELATED_ID5)
            OR (    ( Recinfo.RELATED_ID5 is NULL )
                AND (  x_RELATED_ID5 is NULL )))
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

END JTF_QUAL_TYPES_PKG;

/
