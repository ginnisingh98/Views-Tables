--------------------------------------------------------
--  DDL for Package Body JTF_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_SOURCES_PKG" AS
/* $Header: jtfvsrcb.pls 120.5 2006/03/28 18:21:01 achanda ship $ */
--
-- arpatel   06/25/01 - Added related_id columns (1-5) to insert/update/lock procedures
--
-- sp        07/12/02 - Modified the access from JTF_SOURCES to JTF_SOURCES_ALL
--                      as the view definition of JTF_SOURCES has changeds
--

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_SOURCE_ID                      IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  X_RSC_COL_NAME                   IN     VARCHAR2,
                  X_ROLE_COL_NAME                  IN     VARCHAR2,
                  X_GROUP_COL_NAME                 IN     VARCHAR2,
                  X_RSC_LOV_SQL                    IN     VARCHAR2,
                  X_RSC_ACCESS_LKUP                IN     VARCHAR2,
                  X_DENORM_VALUE_TABLE_NAME        IN     VARCHAR2,
                  X_DENORM_DEA_VALUE_TABLE_NAME    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_SOURCES_ALL
            WHERE SOURCE_ID = x_SOURCE_ID;
   CURSOR C2 IS SELECT JTF_SOURCES_s.nextval FROM sys.dual;
BEGIN
   If (x_SOURCE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_SOURCE_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_SOURCES_ALL(
           SOURCE_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LOOKUP_CODE,
           LOOKUP_TYPE,
           MEANING,
           ENABLED_FLAG,
           DESCRIPTION,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           RELATED_ID1,
           RELATED_ID2,
           RELATED_ID3,
           RELATED_ID4,
           RELATED_ID5,
           RSC_COL_NAME,
           ROLE_COL_NAME,
           GROUP_COL_NAME,
           RSC_LOV_SQL,
           RSC_ACCESS_LKUP,
           DENORM_VALUE_TABLE_NAME,
           DENORM_DEA_VALUE_TABLE_NAME,
           ORG_ID
          ) VALUES (
          x_SOURCE_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_LOOKUP_CODE, FND_API.G_MISS_CHAR, NULL,x_LOOKUP_CODE),
           decode( x_LOOKUP_TYPE, FND_API.G_MISS_CHAR, NULL,x_LOOKUP_TYPE),
           decode( x_MEANING, FND_API.G_MISS_CHAR, NULL,x_MEANING),
           decode( x_ENABLED_FLAG, FND_API.G_MISS_CHAR, NULL,x_ENABLED_FLAG),
           decode( x_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_DESCRIPTION),
           decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,x_START_DATE_ACTIVE),
           decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE, NULL,x_END_DATE_ACTIVE),
           decode( x_RELATED_ID1, FND_API.G_MISS_NUM, NULL,x_RELATED_ID1),
           decode( x_RELATED_ID2, FND_API.G_MISS_NUM, NULL,x_RELATED_ID2),
           decode( x_RELATED_ID3, FND_API.G_MISS_NUM, NULL,x_RELATED_ID3),
           decode( x_RELATED_ID4, FND_API.G_MISS_NUM, NULL,x_RELATED_ID4),
           decode( x_RELATED_ID5, FND_API.G_MISS_NUM, NULL,x_RELATED_ID5),
           decode( X_RSC_COL_NAME, FND_API.G_MISS_CHAR, NULL,X_RSC_COL_NAME),
           decode( X_ROLE_COL_NAME, FND_API.G_MISS_CHAR, NULL,X_ROLE_COL_NAME),
           decode( X_GROUP_COL_NAME, FND_API.G_MISS_CHAR, NULL,X_GROUP_COL_NAME),
           decode( X_RSC_LOV_SQL, FND_API.G_MISS_CHAR, NULL,X_RSC_LOV_SQL),
           decode( X_RSC_ACCESS_LKUP, FND_API.G_MISS_CHAR, NULL,X_RSC_ACCESS_LKUP),
           decode( X_DENORM_VALUE_TABLE_NAME, FND_API.G_MISS_CHAR, NULL,X_DENORM_VALUE_TABLE_NAME),
           decode( X_DENORM_DEA_VALUE_TABLE_NAME, FND_API.G_MISS_CHAR, NULL,X_DENORM_DEA_VALUE_TABLE_NAME),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID) );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_SOURCE_ID                      IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_SOURCES_ALL
    WHERE SOURCE_ID = x_SOURCE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_SOURCES_ALL
    SET
             SOURCE_ID = decode( x_SOURCE_ID, FND_API.G_MISS_NUM,SOURCE_ID,x_SOURCE_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             LOOKUP_CODE = decode( x_LOOKUP_CODE, FND_API.G_MISS_CHAR,LOOKUP_CODE,x_LOOKUP_CODE),
             LOOKUP_TYPE = decode( x_LOOKUP_TYPE, FND_API.G_MISS_CHAR,LOOKUP_TYPE,x_LOOKUP_TYPE),
             MEANING = decode( x_MEANING, FND_API.G_MISS_CHAR,MEANING,x_MEANING),
             ENABLED_FLAG = decode( x_ENABLED_FLAG, FND_API.G_MISS_CHAR,ENABLED_FLAG,x_ENABLED_FLAG),
             DESCRIPTION = decode( x_DESCRIPTION, FND_API.G_MISS_CHAR,DESCRIPTION,x_DESCRIPTION),
             START_DATE_ACTIVE = decode( x_START_DATE_ACTIVE, FND_API.G_MISS_DATE,START_DATE_ACTIVE,x_START_DATE_ACTIVE),
             END_DATE_ACTIVE = decode( x_END_DATE_ACTIVE, FND_API.G_MISS_DATE,END_DATE_ACTIVE,x_END_DATE_ACTIVE),
             RELATED_ID1 = decode( x_RELATED_ID1, FND_API.G_MISS_NUM, RELATED_ID1,x_RELATED_ID1),
             RELATED_ID2 = decode( x_RELATED_ID2, FND_API.G_MISS_NUM, RELATED_ID2,x_RELATED_ID2),
             RELATED_ID3 = decode( x_RELATED_ID3, FND_API.G_MISS_NUM, RELATED_ID3,x_RELATED_ID3),
             RELATED_ID4 = decode( x_RELATED_ID4, FND_API.G_MISS_NUM, RELATED_ID4,x_RELATED_ID4),
             RELATED_ID5 = decode( x_RELATED_ID5, FND_API.G_MISS_NUM, RELATED_ID5,x_RELATED_ID5),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID)
    where SOURCE_ID = X_SOURCE_ID and
          ( ORG_ID = x_ORG_ID OR ( ORG_ID IS NULL AND X_ORG_ID IS NULL)) ;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SOURCE_ID                      IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_LOOKUP_CODE                    IN     VARCHAR2,
                  x_LOOKUP_TYPE                    IN     VARCHAR2,
                  x_MEANING                        IN     VARCHAR2,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_RELATED_ID1                    IN	  NUMBER,
                  x_RELATED_ID2                    IN	  NUMBER,
                  x_RELATED_ID3                    IN	  NUMBER,
                  x_RELATED_ID4                    IN	  NUMBER,
                  x_RELATED_ID5                    IN	  NUMBER,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_SOURCES_ALL
         WHERE rowid = x_Rowid
         FOR UPDATE of SOURCE_ID NOWAIT;
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
           (    ( Recinfo.SOURCE_ID = x_SOURCE_ID)
            OR (    ( Recinfo.SOURCE_ID is NULL )
                AND (  x_SOURCE_ID is NULL )))
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
       AND (    ( Recinfo.LOOKUP_CODE = x_LOOKUP_CODE)
            OR (    ( Recinfo.LOOKUP_CODE is NULL )
                AND (  x_LOOKUP_CODE is NULL )))
       AND (    ( Recinfo.LOOKUP_TYPE = x_LOOKUP_TYPE)
            OR (    ( Recinfo.LOOKUP_TYPE is NULL )
                AND (  x_LOOKUP_TYPE is NULL )))
       AND (    ( Recinfo.MEANING = x_MEANING)
            OR (    ( Recinfo.MEANING is NULL )
                AND (  x_MEANING is NULL )))
       AND (    ( Recinfo.ENABLED_FLAG = x_ENABLED_FLAG)
            OR (    ( Recinfo.ENABLED_FLAG is NULL )
                AND (  x_ENABLED_FLAG is NULL )))
       AND (    ( Recinfo.DESCRIPTION = x_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION is NULL )
                AND (  x_DESCRIPTION is NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = x_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE is NULL )
                AND (  x_START_DATE_ACTIVE is NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = x_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE is NULL )
                AND (  x_END_DATE_ACTIVE is NULL )))
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

END JTF_SOURCES_PKG;

/
