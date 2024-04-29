--------------------------------------------------------
--  DDL for Package Body JTF_QUAL_USGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_QUAL_USGS_PKG" AS
/* $Header: jtfvqlub.pls 120.0 2005/06/02 18:22:14 appldev ship $ */

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_QUAL_USG_ID                    IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_QUAL_COL1                      IN     VARCHAR2,
                  x_QUAL_COL1_ALIAS                IN     VARCHAR2,
                  x_QUAL_COL1_DATATYPE             IN     VARCHAR2,
                  x_QUAL_COL1_TABLE                IN     VARCHAR2,
                  x_QUAL_COL1_TABLE_ALIAS          IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL               IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_DATATYPE      IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_ALIAS         IN     VARCHAR2,
                  x_SEC_INT_CDE_COL                IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_ALIAS          IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_DATATYPE       IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE              IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE_ALIAS        IN     VARCHAR2,
                  x_SEEDED_FLAG                    IN     VARCHAR2,
                  x_DISPLAY_TYPE                   IN     VARCHAR2,
                  x_LOV_SQL                        IN     VARCHAR2,
                  x_CONVERT_TO_ID_FLAG             IN     VARCHAR2,
                  x_COLUMN_COUNT                   IN     NUMBER,
                  x_FORMATTING_FUNCTION_FLAG       IN     VARCHAR2,
                  x_FORMATTING_FUNCTION_NAME       IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_FLAG          IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_NAME          IN     VARCHAR2,
                  x_ENABLE_LOV_VALIDATION          IN     VARCHAR2,
                  x_DISPLAY_SQL1                   IN     VARCHAR2,
                  x_LOV_SQL2                       IN     VARCHAR2,
                  x_DISPLAY_SQL2                   IN     VARCHAR2,
                  x_LOV_SQL3                       IN     VARCHAR2,
                  x_DISPLAY_SQL3                   IN     VARCHAR2,
	          x_Org_Id                         IN     NUMBER,
	          x_RULE1                          IN     VARCHAR2,
	          x_RULE2                          IN     VARCHAR2,
	          x_DISPLAY_SEQUENCE               IN     NUMBER,
	          x_DISPLAY_LENGTH                 IN     NUMBER,
	          x_JSP_LOV_SQL                    IN     VARCHAR2,
	          x_use_in_lookup_flag             IN     VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_QUAL_USGS
            WHERE QUAL_USG_ID = x_QUAL_USG_ID;
   CURSOR C2 IS SELECT JTF_QUAL_USGS_s.nextval FROM sys.dual;
BEGIN
   If (x_QUAL_USG_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_QUAL_USG_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_QUAL_USGS(
           QUAL_USG_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           APPLICATION_SHORT_NAME,
           SEEDED_QUAL_ID,
           QUAL_TYPE_USG_ID,
           ENABLED_FLAG,
           QUAL_COL1,
           QUAL_COL1_ALIAS,
           QUAL_COL1_DATATYPE,
           QUAL_COL1_TABLE,
           QUAL_COL1_TABLE_ALIAS,
           PRIM_INT_CDE_COL,
           PRIM_INT_CDE_COL_DATATYPE,
           PRIM_INT_CDE_COL_ALIAS,
           SEC_INT_CDE_COL,
           SEC_INT_CDE_COL_ALIAS,
           SEC_INT_CDE_COL_DATATYPE,
           INT_CDE_COL_TABLE,
           INT_CDE_COL_TABLE_ALIAS,
           SEEDED_FLAG,
           DISPLAY_TYPE,
           LOV_SQL,
           CONVERT_TO_ID_FLAG,
           COLUMN_COUNT,
           FORMATTING_FUNCTION_FLAG,
           FORMATTING_FUNCTION_NAME,
           SPECIAL_FUNCTION_FLAG,
           SPECIAL_FUNCTION_NAME,
           ENABLE_LOV_VALIDATION,
           DISPLAY_SQL1,
           LOV_SQL2,
           DISPLAY_SQL2,
           LOV_SQL3,
           DISPLAY_SQL3,
           ORG_ID,
	   RULE1,
	   RULE2,
	   DISPLAY_SEQUENCE,
	   DISPLAY_LENGTH,
	   JSP_LOV_SQL,
	   use_in_lookup_flag
          ) VALUES (
          x_QUAL_USG_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_APPLICATION_SHORT_NAME, FND_API.G_MISS_CHAR, NULL,x_APPLICATION_SHORT_NAME),
           decode( x_SEEDED_QUAL_ID, FND_API.G_MISS_NUM, NULL,x_SEEDED_QUAL_ID),
           decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM, NULL,x_QUAL_TYPE_USG_ID),
           decode( x_ENABLED_FLAG, FND_API.G_MISS_CHAR, NULL,x_ENABLED_FLAG),
           decode( x_QUAL_COL1, FND_API.G_MISS_CHAR, NULL,x_QUAL_COL1),
           decode( x_QUAL_COL1_ALIAS, FND_API.G_MISS_CHAR, NULL,x_QUAL_COL1_ALIAS),
           decode( x_QUAL_COL1_DATATYPE, FND_API.G_MISS_CHAR, NULL,x_QUAL_COL1_DATATYPE),
           decode( x_QUAL_COL1_TABLE, FND_API.G_MISS_CHAR, NULL,x_QUAL_COL1_TABLE),
           decode( x_QUAL_COL1_TABLE_ALIAS, FND_API.G_MISS_CHAR, NULL,x_QUAL_COL1_TABLE_ALIAS),
           decode( x_PRIM_INT_CDE_COL, FND_API.G_MISS_CHAR, NULL,x_PRIM_INT_CDE_COL),
           decode( x_PRIM_INT_CDE_COL_DATATYPE, FND_API.G_MISS_CHAR, NULL,x_PRIM_INT_CDE_COL_DATATYPE),
           decode( x_PRIM_INT_CDE_COL_ALIAS, FND_API.G_MISS_CHAR, NULL,x_PRIM_INT_CDE_COL_ALIAS),
           decode( x_SEC_INT_CDE_COL, FND_API.G_MISS_CHAR, NULL,x_SEC_INT_CDE_COL),
           decode( x_SEC_INT_CDE_COL_ALIAS, FND_API.G_MISS_CHAR, NULL,x_SEC_INT_CDE_COL_ALIAS),
           decode( x_SEC_INT_CDE_COL_DATATYPE, FND_API.G_MISS_CHAR, NULL,x_SEC_INT_CDE_COL_DATATYPE),
           decode( x_INT_CDE_COL_TABLE, FND_API.G_MISS_CHAR, NULL,x_INT_CDE_COL_TABLE),
           decode( x_INT_CDE_COL_TABLE_ALIAS, FND_API.G_MISS_CHAR, NULL,x_INT_CDE_COL_TABLE_ALIAS),
           decode( x_SEEDED_FLAG, FND_API.G_MISS_CHAR, NULL,x_SEEDED_FLAG),
           decode( x_DISPLAY_TYPE, FND_API.G_MISS_CHAR, NULL,x_DISPLAY_TYPE),
           decode( x_LOV_SQL, FND_API.G_MISS_CHAR, NULL,x_LOV_SQL ),
           decode( x_CONVERT_TO_ID_FLAG, FND_API.G_MISS_CHAR, NULL,x_CONVERT_TO_ID_FLAG ),
           decode( x_COLUMN_COUNT, FND_API.G_MISS_NUM, NULL, X_COLUMN_COUNT ),
           decode( x_FORMATTING_FUNCTION_FLAG, FND_API.G_MISS_CHAR, NULL, X_FORMATTING_FUNCTION_FLAG ),
           decode( x_FORMATTING_FUNCTION_NAME, FND_API.G_MISS_CHAR, NULL, X_FORMATTING_FUNCTION_NAME ),
           decode( x_SPECIAL_FUNCTION_FLAG, FND_API.G_MISS_CHAR, NULL, X_SPECIAL_FUNCTION_FLAG ),
           decode( x_SPECIAL_FUNCTION_NAME, FND_API.G_MISS_CHAR, NULL, X_SPECIAL_FUNCTION_NAME ),
           decode( x_ENABLE_LOV_VALIDATION, FND_API.G_MISS_CHAR, NULL, X_ENABLE_LOV_VALIDATION ),
           decode( x_DISPLAY_SQL1, FND_API.G_MISS_CHAR, NULL, X_DISPLAY_SQL1 ),
           decode( x_LOV_SQL2, FND_API.G_MISS_CHAR, NULL, X_LOV_SQL2 ),
           decode( x_DISPLAY_SQL2, FND_API.G_MISS_CHAR, NULL, X_DISPLAY_SQL2 ),
           decode( x_LOV_SQL3, FND_API.G_MISS_CHAR, NULL, X_LOV_SQL3 ),
           decode( x_DISPLAY_SQL3, FND_API.G_MISS_CHAR, NULL, X_DISPLAY_SQL3 ),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL, X_ORG_ID),
	   decode( x_RULE1, FND_API.G_MISS_CHAR, NULL, X_RULE1),
	   decode( x_RULE2, FND_API.G_MISS_CHAR, NULL, X_RULE2),
	   decode( x_DISPLAY_SEQUENCE, FND_API.G_MISS_NUM, NULL, X_DISPLAY_SEQUENCE),
	   decode( x_DISPLAY_LENGTH, FND_API.G_MISS_NUM, NULL, X_DISPLAY_LENGTH),
	   decode( x_JSP_LOV_SQL, FND_API.G_MISS_CHAR, NULL, X_JSP_LOV_SQL),
	   decode( x_use_in_lookup_flag, FND_API.G_MISS_CHAR, NULL, X_use_in_lookup_flag)
	   );
   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_QUAL_USG_ID                    IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_QUAL_USGS
    WHERE QUAL_USG_ID = x_QUAL_USG_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_QUAL_COL1                      IN     VARCHAR2,
                  x_QUAL_COL1_ALIAS                IN     VARCHAR2,
                  x_QUAL_COL1_DATATYPE             IN     VARCHAR2,
                  x_QUAL_COL1_TABLE                IN     VARCHAR2,
                  x_QUAL_COL1_TABLE_ALIAS          IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL               IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_DATATYPE      IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_ALIAS         IN     VARCHAR2,
                  x_SEC_INT_CDE_COL                IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_ALIAS          IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_DATATYPE       IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE              IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE_ALIAS        IN     VARCHAR2,
                  x_SEEDED_FLAG                    IN     VARCHAR2,
                  x_DISPLAY_TYPE                   IN     VARCHAR2,
                  x_LOV_SQL                        IN     VARCHAR2,
                  x_CONVERT_TO_ID_FLAG             IN     VARCHAR2,
                  x_COLUMN_COUNT                   IN     NUMBER,
                  x_FORMATTING_FUNCTION_FLAG       IN     VARCHAR2,
                  x_FORMATTING_FUNCTION_NAME       IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_FLAG          IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_NAME          IN     VARCHAR2,
                  x_ENABLE_LOV_VALIDATION          IN     VARCHAR2,
                  x_DISPLAY_SQL1                   IN     VARCHAR2,
                  x_LOV_SQL2                       IN     VARCHAR2,
                  x_DISPLAY_SQL2                   IN     VARCHAR2,
                  x_LOV_SQL3                       IN     VARCHAR2,
                  x_DISPLAY_SQL3                   IN     VARCHAR2,
	          x_Org_Id                         IN     NUMBER,
	          x_RULE1                          IN     VARCHAR2,
	          x_RULE2                          IN     VARCHAR2,
	          x_DISPLAY_SEQUENCE               IN     NUMBER,
	          x_DISPLAY_LENGTH                 IN     NUMBER,
	          x_JSP_LOV_SQL                    IN     VARCHAR2,
	          x_use_in_lookup_flag             IN     VARCHAR2
 ) IS
 BEGIN
    Update JTF_QUAL_USGS
    SET
             QUAL_USG_ID = decode( x_QUAL_USG_ID, FND_API.G_MISS_NUM,QUAL_USG_ID,x_QUAL_USG_ID),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             APPLICATION_SHORT_NAME = decode( x_APPLICATION_SHORT_NAME, FND_API.G_MISS_CHAR,APPLICATION_SHORT_NAME,x_APPLICATION_SHORT_NAME),
             SEEDED_QUAL_ID = decode( x_SEEDED_QUAL_ID, FND_API.G_MISS_NUM,SEEDED_QUAL_ID,x_SEEDED_QUAL_ID),
             QUAL_TYPE_USG_ID = decode( x_QUAL_TYPE_USG_ID, FND_API.G_MISS_NUM,QUAL_TYPE_USG_ID,x_QUAL_TYPE_USG_ID),
             ENABLED_FLAG = decode( x_ENABLED_FLAG, FND_API.G_MISS_CHAR,ENABLED_FLAG,x_ENABLED_FLAG),
             QUAL_COL1 = decode( x_QUAL_COL1, FND_API.G_MISS_CHAR,QUAL_COL1,x_QUAL_COL1),
             QUAL_COL1_ALIAS = decode( x_QUAL_COL1_ALIAS, FND_API.G_MISS_CHAR,QUAL_COL1_ALIAS,x_QUAL_COL1_ALIAS),
             QUAL_COL1_DATATYPE = decode( x_QUAL_COL1_DATATYPE, FND_API.G_MISS_CHAR,QUAL_COL1_DATATYPE,x_QUAL_COL1_DATATYPE),
             QUAL_COL1_TABLE = decode( x_QUAL_COL1_TABLE, FND_API.G_MISS_CHAR,QUAL_COL1_TABLE,x_QUAL_COL1_TABLE),
             QUAL_COL1_TABLE_ALIAS = decode( x_QUAL_COL1_TABLE_ALIAS, FND_API.G_MISS_CHAR,QUAL_COL1_TABLE_ALIAS,x_QUAL_COL1_TABLE_ALIAS),
             PRIM_INT_CDE_COL = decode( x_PRIM_INT_CDE_COL, FND_API.G_MISS_CHAR,PRIM_INT_CDE_COL,x_PRIM_INT_CDE_COL),
             PRIM_INT_CDE_COL_DATATYPE = decode( x_PRIM_INT_CDE_COL_DATATYPE, FND_API.G_MISS_CHAR,PRIM_INT_CDE_COL_DATATYPE,x_PRIM_INT_CDE_COL_DATATYPE),
             PRIM_INT_CDE_COL_ALIAS = decode( x_PRIM_INT_CDE_COL_ALIAS, FND_API.G_MISS_CHAR,PRIM_INT_CDE_COL_ALIAS,x_PRIM_INT_CDE_COL_ALIAS),
             SEC_INT_CDE_COL = decode( x_SEC_INT_CDE_COL, FND_API.G_MISS_CHAR,SEC_INT_CDE_COL,x_SEC_INT_CDE_COL),
             SEC_INT_CDE_COL_ALIAS = decode( x_SEC_INT_CDE_COL_ALIAS, FND_API.G_MISS_CHAR,SEC_INT_CDE_COL_ALIAS,x_SEC_INT_CDE_COL_ALIAS),
             SEC_INT_CDE_COL_DATATYPE = decode( x_SEC_INT_CDE_COL_DATATYPE, FND_API.G_MISS_CHAR,SEC_INT_CDE_COL_DATATYPE,x_SEC_INT_CDE_COL_DATATYPE),
             INT_CDE_COL_TABLE = decode( x_INT_CDE_COL_TABLE, FND_API.G_MISS_CHAR,INT_CDE_COL_TABLE,x_INT_CDE_COL_TABLE),
             INT_CDE_COL_TABLE_ALIAS = decode( x_INT_CDE_COL_TABLE_ALIAS, FND_API.G_MISS_CHAR,INT_CDE_COL_TABLE_ALIAS,x_INT_CDE_COL_TABLE_ALIAS),
             SEEDED_FLAG = decode( x_SEEDED_FLAG, FND_API.G_MISS_CHAR,SEEDED_FLAG,x_SEEDED_FLAG),
             DISPLAY_TYPE = decode( x_DISPLAY_TYPE, FND_API.G_MISS_CHAR,DISPLAY_TYPE,x_DISPLAY_TYPE),
             LOV_SQL = decode( x_LOV_SQL, FND_API.G_MISS_CHAR,LOV_SQL,x_LOV_SQL),
             CONVERT_TO_ID_FLAG = decode( x_CONVERT_TO_ID_FLAG, FND_API.G_MISS_CHAR,CONVERT_TO_ID_FLAG, x_CONVERT_TO_ID_FLAG),
	     COLUMN_COUNT = decode(x_COLUMN_COUNT, FND_API.G_MISS_NUM, COLUMN_COUNT, X_COLUMN_COUNT),
             FORMATTING_FUNCTION_FLAG = decode(x_FORMATTING_FUNCTION_FLAG, FND_API.G_MISS_CHAR, FORMATTING_FUNCTION_FLAG, X_FORMATTING_FUNCTION_FLAG),
             FORMATTING_FUNCTION_NAME = decode(x_FORMATTING_FUNCTION_NAME, FND_API.G_MISS_CHAR, FORMATTING_FUNCTION_NAME, X_FORMATTING_FUNCTION_NAME),
             SPECIAL_FUNCTION_FLAG = decode(x_SPECIAL_FUNCTION_FLAG, FND_API.G_MISS_CHAR, SPECIAL_FUNCTION_FLAG, X_SPECIAL_FUNCTION_FLAG),
             SPECIAL_FUNCTION_NAME = decode(x_SPECIAL_FUNCTION_NAME, FND_API.G_MISS_CHAR, SPECIAL_FUNCTION_NAME, X_SPECIAL_FUNCTION_NAME),
             ENABLE_LOV_VALIDATION = decode(x_ENABLE_LOV_VALIDATION, FND_API.G_MISS_CHAR, ENABLE_LOV_VALIDATION, X_ENABLE_LOV_VALIDATION),
             DISPLAY_SQL1 = decode(x_DISPLAY_SQL1, FND_API.G_MISS_CHAR, DISPLAY_SQL1, X_DISPLAY_SQL1),
             LOV_SQL2 = decode(x_LOV_SQL2, FND_API.G_MISS_CHAR, LOV_SQL2, X_LOV_SQL2),
             DISPLAY_SQL2 = decode(x_DISPLAY_SQL2, FND_API.G_MISS_CHAR, DISPLAY_SQL2, X_DISPLAY_SQL2),
             LOV_SQL3 = decode(x_LOV_SQL3, FND_API.G_MISS_CHAR, LOV_SQL3, X_LOV_SQL3),
             DISPLAY_SQL3 = decode(x_DISPLAY_SQL3, FND_API.G_MISS_CHAR, DISPLAY_SQL3, X_DISPLAY_SQL3),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, x_ORG_ID),
	     RULE1 = decode( x_RULE1, FND_API.G_MISS_CHAR, NULL, X_RULE1),
	     RULE2 = decode( x_RULE2, FND_API.G_MISS_CHAR, NULL, X_RULE2),
	     DISPLAY_SEQUENCE = decode( x_DISPLAY_SEQUENCE, FND_API.G_MISS_NUM, NULL, X_DISPLAY_SEQUENCE),
	     DISPLAY_LENGTH = decode( x_DISPLAY_LENGTH, FND_API.G_MISS_NUM, NULL, X_DISPLAY_LENGTH),
	     JSP_LOV_SQL = decode( x_JSP_LOV_SQL, FND_API.G_MISS_CHAR, NULL, X_JSP_LOV_SQL),
	     use_in_lookup_flag = decode( x_use_in_lookup_flag, FND_API.G_MISS_CHAR, NULL, X_use_in_lookup_flag)
    where QUAL_USG_ID = x_QUAL_USG_ID and
          ( ORG_ID = x_ORG_ID OR ( ORG_ID IS NULL AND X_ORG_ID IS NULL)) ;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_QUAL_USG_ID                    IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_APPLICATION_SHORT_NAME         IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_QUAL_TYPE_USG_ID               IN     NUMBER,
                  x_ENABLED_FLAG                   IN     VARCHAR2,
                  x_QUAL_COL1                      IN     VARCHAR2,
                  x_QUAL_COL1_ALIAS                IN     VARCHAR2,
                  x_QUAL_COL1_DATATYPE             IN     VARCHAR2,
                  x_QUAL_COL1_TABLE                IN     VARCHAR2,
                  x_QUAL_COL1_TABLE_ALIAS          IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL               IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_DATATYPE      IN     VARCHAR2,
                  x_PRIM_INT_CDE_COL_ALIAS         IN     VARCHAR2,
                  x_SEC_INT_CDE_COL                IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_ALIAS          IN     VARCHAR2,
                  x_SEC_INT_CDE_COL_DATATYPE       IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE              IN     VARCHAR2,
                  x_INT_CDE_COL_TABLE_ALIAS        IN     VARCHAR2,
                  x_SEEDED_FLAG                    IN     VARCHAR2,
                  x_DISPLAY_TYPE                   IN     VARCHAR2,
                  x_LOV_SQL                        IN     VARCHAR2,
                  x_CONVERT_TO_ID_FLAG             IN     VARCHAR2,
                  x_COLUMN_COUNT                   IN     NUMBER,
                  x_FORMATTING_FUNCTION_FLAG       IN     VARCHAR2,
                  x_FORMATTING_FUNCTION_NAME       IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_FLAG          IN     VARCHAR2,
                  x_SPECIAL_FUNCTION_NAME          IN     VARCHAR2,
                  x_ENABLE_LOV_VALIDATION          IN     VARCHAR2,
                  x_DISPLAY_SQL1                   IN     VARCHAR2,
                  x_LOV_SQL2                       IN     VARCHAR2,
                  x_DISPLAY_SQL2                   IN     VARCHAR2,
                  x_LOV_SQL3                       IN     VARCHAR2,
                  x_DISPLAY_SQL3                   IN     VARCHAR2,
	          x_Org_Id                         IN     NUMBER,
	          x_RULE1                          IN     VARCHAR2,
	          x_RULE2                          IN     VARCHAR2,
	          x_DISPLAY_SEQUENCE               IN     NUMBER,
	          x_DISPLAY_LENGTH                 IN     NUMBER,
	          x_JSP_LOV_SQL                    IN     VARCHAR2,
	          x_use_in_lookup_flag             IN     VARCHAR2
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_QUAL_USGS
         WHERE QUAL_USG_ID = x_QUAL_USG_ID
         FOR UPDATE of QUAL_USG_ID NOWAIT;
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
           (    ( Recinfo.QUAL_USG_ID = x_QUAL_USG_ID)
            OR (    ( Recinfo.QUAL_USG_ID is NULL )
                AND (  x_QUAL_USG_ID is NULL )))
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
       AND (    ( Recinfo.APPLICATION_SHORT_NAME = x_APPLICATION_SHORT_NAME)
            OR (    ( Recinfo.APPLICATION_SHORT_NAME is NULL )
                AND (  x_APPLICATION_SHORT_NAME is NULL )))
       AND (    ( Recinfo.SEEDED_QUAL_ID = x_SEEDED_QUAL_ID)
            OR (    ( Recinfo.SEEDED_QUAL_ID is NULL )
                AND (  x_SEEDED_QUAL_ID is NULL )))
       AND (    ( Recinfo.QUAL_TYPE_USG_ID = x_QUAL_TYPE_USG_ID)
            OR (    ( Recinfo.QUAL_TYPE_USG_ID is NULL )
                AND (  x_QUAL_TYPE_USG_ID is NULL )))
       AND (    ( Recinfo.ENABLED_FLAG = x_ENABLED_FLAG)
            OR (    ( Recinfo.ENABLED_FLAG is NULL )
                AND (  x_ENABLED_FLAG is NULL )))
       AND (    ( Recinfo.QUAL_COL1 = x_QUAL_COL1)
            OR (    ( Recinfo.QUAL_COL1 is NULL )
                AND (  x_QUAL_COL1 is NULL )))
       AND (    ( Recinfo.QUAL_COL1_ALIAS = x_QUAL_COL1_ALIAS)
            OR (    ( Recinfo.QUAL_COL1_ALIAS is NULL )
                AND (  x_QUAL_COL1_ALIAS is NULL )))
       AND (    ( Recinfo.QUAL_COL1_DATATYPE = x_QUAL_COL1_DATATYPE)
            OR (    ( Recinfo.QUAL_COL1_DATATYPE is NULL )
                AND (  x_QUAL_COL1_DATATYPE is NULL )))
       AND (    ( Recinfo.QUAL_COL1_TABLE = x_QUAL_COL1_TABLE)
            OR (    ( Recinfo.QUAL_COL1_TABLE is NULL )
                AND (  x_QUAL_COL1_TABLE is NULL )))
       AND (    ( Recinfo.QUAL_COL1_TABLE_ALIAS = x_QUAL_COL1_TABLE_ALIAS)
            OR (    ( Recinfo.QUAL_COL1_TABLE_ALIAS is NULL )
                AND (  x_QUAL_COL1_TABLE_ALIAS is NULL )))
       AND (    ( Recinfo.PRIM_INT_CDE_COL = x_PRIM_INT_CDE_COL)
            OR (    ( Recinfo.PRIM_INT_CDE_COL is NULL )
                AND (  x_PRIM_INT_CDE_COL is NULL )))
       AND (    ( Recinfo.PRIM_INT_CDE_COL_DATATYPE = x_PRIM_INT_CDE_COL_DATATYPE)
            OR (    ( Recinfo.PRIM_INT_CDE_COL_DATATYPE is NULL )
                AND (  x_PRIM_INT_CDE_COL_DATATYPE is NULL )))
       AND (    ( Recinfo.PRIM_INT_CDE_COL_ALIAS = x_PRIM_INT_CDE_COL_ALIAS)
            OR (    ( Recinfo.PRIM_INT_CDE_COL_ALIAS is NULL )
                AND (  x_PRIM_INT_CDE_COL_ALIAS is NULL )))
       AND (    ( Recinfo.SEC_INT_CDE_COL = x_SEC_INT_CDE_COL)
            OR (    ( Recinfo.SEC_INT_CDE_COL is NULL )
                AND (  x_SEC_INT_CDE_COL is NULL )))
       AND (    ( Recinfo.SEC_INT_CDE_COL_ALIAS = x_SEC_INT_CDE_COL_ALIAS)
            OR (    ( Recinfo.SEC_INT_CDE_COL_ALIAS is NULL )
                AND (  x_SEC_INT_CDE_COL_ALIAS is NULL )))
       AND (    ( Recinfo.SEC_INT_CDE_COL_DATATYPE = x_SEC_INT_CDE_COL_DATATYPE)
            OR (    ( Recinfo.SEC_INT_CDE_COL_DATATYPE is NULL )
                AND (  x_SEC_INT_CDE_COL_DATATYPE is NULL )))
       AND (    ( Recinfo.INT_CDE_COL_TABLE = x_INT_CDE_COL_TABLE)
            OR (    ( Recinfo.INT_CDE_COL_TABLE is NULL )
                AND (  x_INT_CDE_COL_TABLE is NULL )))
       AND (    ( Recinfo.INT_CDE_COL_TABLE_ALIAS = x_INT_CDE_COL_TABLE_ALIAS)
            OR (    ( Recinfo.INT_CDE_COL_TABLE_ALIAS is NULL )
                AND (  x_INT_CDE_COL_TABLE_ALIAS is NULL )))
       AND (    ( Recinfo.SEEDED_FLAG = x_SEEDED_FLAG)
            OR (    ( Recinfo.SEEDED_FLAG is NULL )
                AND (  x_SEEDED_FLAG is NULL )))
       AND (    ( Recinfo.DISPLAY_TYPE = x_DISPLAY_TYPE)
            OR (    ( Recinfo.DISPLAY_TYPE is NULL )
                AND (  x_DISPLAY_TYPE is NULL )))
       AND (    ( Recinfo.LOV_SQL = x_LOV_SQL)
            OR (    ( Recinfo.LOV_SQL is NULL )
                AND (  x_LOV_SQL is NULL )))
       AND (    ( Recinfo.CONVERT_TO_ID_FLAG = x_CONVERT_TO_ID_FLAG)
            OR (    ( Recinfo.CONVERT_TO_ID_FLAG is NULL )
                AND (  x_CONVERT_TO_ID_FLAG is NULL )))
       AND (     ( Recinfo.COLUMN_COUNT = x_COLUMN_COUNT)
            OR (    ( Recinfo.COLUMN_COUNT IS NULL )
                AND ( X_COLUMN_COUNT IS NULL )))
       AND (     ( Recinfo.FORMATTING_FUNCTION_FLAG  = x_FORMATTING_FUNCTION_FLAG )
            OR (    ( Recinfo.FORMATTING_FUNCTION_FLAG  IS NULL )
                AND ( X_FORMATTING_FUNCTION_FLAG  IS NULL )))
       AND (     ( Recinfo.FORMATTING_FUNCTION_NAME  = x_FORMATTING_FUNCTION_NAME )
            OR (    ( Recinfo.FORMATTING_FUNCTION_NAME  IS NULL )
                AND ( X_FORMATTING_FUNCTION_NAME  IS NULL )))
       AND (      ( Recinfo.SPECIAL_FUNCTION_FLAG = x_SPECIAL_FUNCTION_FLAG )
            OR  (    ( Recinfo.SPECIAL_FUNCTION_FLAG     IS NULL )
                AND ( X_SPECIAL_FUNCTION_FLAG IS NULL )))
       AND (      ( Recinfo.SPECIAL_FUNCTION_NAME = x_SPECIAL_FUNCTION_NAME )
            OR  (    ( Recinfo.SPECIAL_FUNCTION_NAME     IS NULL )
                 AND ( X_SPECIAL_FUNCTION_NAME     IS NULL )))
       AND (      ( Recinfo.ENABLE_LOV_VALIDATION = x_ENABLE_LOV_VALIDATION )
            OR  (    ( Recinfo.ENABLE_LOV_VALIDATION IS NULL )
                 AND ( X_ENABLE_LOV_VALIDATION     IS NULL )))
       AND (      ( Recinfo.DISPLAY_SQL1  = x_DISPLAY_SQL1  )
            OR  (    ( Recinfo.DISPLAY_SQL1 IS NULL )
                AND ( X_DISPLAY_SQL1  IS NULL )))
       AND (     ( Recinfo.LOV_SQL2  = x_LOV_SQL2 )
            OR  (    ( Recinfo.LOV_SQL2 IS NULL )
                AND ( X_LOV_SQL2  IS NULL )))
       AND (     ( Recinfo.DISPLAY_SQL2 = x_DISPLAY_SQL2)
            OR  (    ( Recinfo.DISPLAY_SQL2 IS NULL )
                AND ( X_DISPLAY_SQL2 IS NULL )))
       AND (     ( Recinfo.LOV_SQL3 = x_LOV_SQL3)
            OR  (    ( Recinfo.LOV_SQL3 IS NULL )
                AND ( X_LOV_SQL3 IS NULL )))
       AND (     ( Recinfo.DISPLAY_SQL3 = x_DISPLAY_SQL3)
            OR  (    ( Recinfo.DISPLAY_SQL3 IS NULL )
                AND ( X_DISPLAY_SQL3 IS NULL )))
       AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID is NULL )
                AND (  x_ORG_ID is NULL )))
       AND (     ( Recinfo.RULE1 = x_RULE1 )
            OR  (    ( Recinfo.RULE1 IS NULL )
                AND ( X_RULE1 IS NULL )))
       AND (     ( Recinfo.RULE2 = X_RULE2 )
            OR  (    ( Recinfo.RULE2 IS NULL )
                AND ( X_RULE2 IS NULL )))
       AND (     ( Recinfo.DISPLAY_SEQUENCE = x_DISPLAY_SEQUENCE)
            OR  (    ( Recinfo.DISPLAY_SEQUENCE IS NULL )
                AND ( X_DISPLAY_SEQUENCE IS NULL )))
       AND (     ( Recinfo.DISPLAY_LENGTH = x_DISPLAY_LENGTH)
            OR  (    ( Recinfo.DISPLAY_LENGTH IS NULL )
                AND ( X_DISPLAY_LENGTH IS NULL )))
       AND (    ( Recinfo.JSP_LOV_SQL = x_JSP_LOV_SQL)
            OR (    ( Recinfo.JSP_LOV_SQL is NULL )
                AND (  x_JSP_LOV_SQL is NULL )))
       AND (    ( Recinfo.use_in_lookup_flag = x_use_in_lookup_flag)
            OR (    ( Recinfo.use_in_lookup_flag is NULL )
                AND (  x_use_in_lookup_flag is NULL )))       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END JTF_QUAL_USGS_PKG;

/
