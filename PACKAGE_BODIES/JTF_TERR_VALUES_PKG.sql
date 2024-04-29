--------------------------------------------------------
--  DDL for Package Body JTF_TERR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_VALUES_PKG" AS
/* $Header: jtfvtvlb.pls 120.0.12010000.2 2009/09/07 06:35:04 vpalle ship $ */
--  01/20/00   VNEDUNGA  Changing Update/Lock_Row procedures to use
--                       TERR_VALUE_ID instead of row_id
--  01/20/00  VNEDUNGA  Changing = NULL to IS NULL
-- 02/22/00  JDOCHERT  Passing in ORG_ID to Insert/Update/Lock
-- 12/03/04  ACHANDA   Added value4_id : bug # 3726007

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_VALUE_ID                  IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_TERR_VALUES_ALL
            WHERE TERR_VALUE_ID = x_TERR_VALUE_ID;
   CURSOR C2 IS SELECT JTF_TERR_VALUES_s.nextval FROM sys.dual;
BEGIN
   If (x_TERR_VALUE_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_TERR_VALUE_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_TERR_VALUES_ALL(
           TERR_VALUE_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           TERR_QUAL_ID,
           INCLUDE_FLAG,
           COMPARISON_OPERATOR,
           LOW_VALUE_CHAR,
           HIGH_VALUE_CHAR,
           LOW_VALUE_NUMBER,
           HIGH_VALUE_NUMBER,
           VALUE_SET,
           INTEREST_TYPE_ID,
           PRIMARY_INTEREST_CODE_ID,
           SECONDARY_INTEREST_CODE_ID,
           CURRENCY_CODE,
           ID_USED_FLAG,
           LOW_VALUE_CHAR_ID,
           ORG_ID,
           CNR_GROUP_ID,
           VALUE1_ID,
           VALUE2_ID,
           VALUE3_ID,
           VALUE4_ID
          ) VALUES (
          x_TERR_VALUE_ID,
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_TERR_QUAL_ID, FND_API.G_MISS_NUM, NULL,x_TERR_QUAL_ID),
           decode( x_INCLUDE_FLAG, FND_API.G_MISS_CHAR, NULL,x_INCLUDE_FLAG),
           decode( x_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR, NULL,x_COMPARISON_OPERATOR),
           decode( x_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL,x_LOW_VALUE_CHAR),
           decode( x_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR, NULL,x_HIGH_VALUE_CHAR),
           decode( x_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL,x_LOW_VALUE_NUMBER),
           decode( x_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM, NULL,x_HIGH_VALUE_NUMBER),
           decode( x_VALUE_SET, FND_API.G_MISS_NUM, NULL,x_VALUE_SET),
           decode( x_INTEREST_TYPE_ID, FND_API.G_MISS_NUM, NULL,x_INTEREST_TYPE_ID),
           decode( x_PRIMARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL,x_PRIMARY_INTEREST_CODE_ID),
           decode( x_SECONDARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM, NULL,x_SECONDARY_INTEREST_CODE_ID),
           decode( x_CURRENCY_CODE, FND_API.G_MISS_CHAR, NULL,x_CURRENCY_CODE),
           decode( x_ID_USED_FLAG, FND_API.G_MISS_CHAR, NULL,x_ID_USED_FLAG),
           decode( x_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM, NULL,x_LOW_VALUE_CHAR_ID),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL,x_ORG_ID),
           decode( x_CNR_GROUP_ID, FND_API.G_MISS_NUM, NULL,x_CNR_GROUP_ID),
           decode( x_VALUE1_ID, FND_API.G_MISS_NUM, NULL,x_VALUE1_ID),
           decode( x_VALUE2_ID, FND_API.G_MISS_NUM, NULL,x_VALUE2_ID),
           decode( x_VALUE3_ID, FND_API.G_MISS_NUM, NULL,x_VALUE3_ID),
           decode( x_VALUE4_ID, FND_API.G_MISS_NUM, NULL,x_VALUE4_ID)
           );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_TERR_VALUE_ID                  IN     NUMBER
 ) IS
 BEGIN
   DELETE FROM JTF_TERR_VALUES_ALL
    WHERE TERR_VALUE_ID = x_TERR_VALUE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_VALUE_ID                  IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER
 ) IS
 BEGIN
    Update JTF_TERR_VALUES_ALL
    SET
             TERR_VALUE_ID = decode( x_TERR_VALUE_ID, FND_API.G_MISS_NUM,TERR_VALUE_ID,x_TERR_VALUE_ID),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
             TERR_QUAL_ID = decode( x_TERR_QUAL_ID, FND_API.G_MISS_NUM,TERR_QUAL_ID,x_TERR_QUAL_ID),
             INCLUDE_FLAG = decode( x_INCLUDE_FLAG, FND_API.G_MISS_CHAR,INCLUDE_FLAG,x_INCLUDE_FLAG),
             COMPARISON_OPERATOR = decode( x_COMPARISON_OPERATOR, FND_API.G_MISS_CHAR,COMPARISON_OPERATOR,x_COMPARISON_OPERATOR),
             LOW_VALUE_CHAR = decode( x_LOW_VALUE_CHAR, FND_API.G_MISS_CHAR,LOW_VALUE_CHAR,x_LOW_VALUE_CHAR),
             HIGH_VALUE_CHAR = decode( x_HIGH_VALUE_CHAR, FND_API.G_MISS_CHAR,HIGH_VALUE_CHAR,x_HIGH_VALUE_CHAR),
             LOW_VALUE_NUMBER = decode( x_LOW_VALUE_NUMBER, FND_API.G_MISS_NUM,LOW_VALUE_NUMBER,x_LOW_VALUE_NUMBER),
             HIGH_VALUE_NUMBER = decode( x_HIGH_VALUE_NUMBER, FND_API.G_MISS_NUM,HIGH_VALUE_NUMBER,x_HIGH_VALUE_NUMBER),
             VALUE_SET = decode( x_VALUE_SET, FND_API.G_MISS_NUM,VALUE_SET,x_VALUE_SET),
             INTEREST_TYPE_ID = decode( x_INTEREST_TYPE_ID, FND_API.G_MISS_NUM,INTEREST_TYPE_ID,x_INTEREST_TYPE_ID),
             PRIMARY_INTEREST_CODE_ID = decode( x_PRIMARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM,PRIMARY_INTEREST_CODE_ID,x_PRIMARY_INTEREST_CODE_ID),
             SECONDARY_INTEREST_CODE_ID = decode( x_SECONDARY_INTEREST_CODE_ID, FND_API.G_MISS_NUM,SECONDARY_INTEREST_CODE_ID,x_SECONDARY_INTEREST_CODE_ID),
             CURRENCY_CODE = decode( x_CURRENCY_CODE, FND_API.G_MISS_CHAR,CURRENCY_CODE,x_CURRENCY_CODE),
             ID_USED_FLAG = decode( x_ID_USED_FLAG, FND_API.G_MISS_CHAR,ID_USED_FLAG,x_ID_USED_FLAG),
             LOW_VALUE_CHAR_ID = decode( x_LOW_VALUE_CHAR_ID, FND_API.G_MISS_NUM,LOW_VALUE_CHAR_ID,x_LOW_VALUE_CHAR_ID),
             ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM,ORG_ID,x_ORG_ID),
             CNR_GROUP_ID = decode( x_CNR_GROUP_ID, FND_API.G_MISS_NUM,CNR_GROUP_ID,x_CNR_GROUP_ID),
             VALUE1_ID = decode( x_VALUE1_ID, FND_API.G_MISS_NUM,VALUE1_ID,x_VALUE1_ID),
             VALUE2_ID = decode( x_VALUE2_ID, FND_API.G_MISS_NUM,VALUE2_ID,x_VALUE2_ID),
             VALUE3_ID = decode( x_VALUE3_ID, FND_API.G_MISS_NUM,VALUE3_ID,x_VALUE3_ID),
             VALUE4_ID = decode( x_VALUE4_ID, FND_API.G_MISS_NUM,VALUE4_ID,x_VALUE4_ID)
    where TERR_VALUE_ID = X_TERR_VALUE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_VALUE_ID                  IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_TERR_VALUES_ALL
         WHERE TERR_VALUE_ID = x_TERR_VALUE_ID
         FOR UPDATE of TERR_VALUE_ID NOWAIT;
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
           (    ( Recinfo.TERR_VALUE_ID = x_TERR_VALUE_ID)
            OR (    ( Recinfo.TERR_VALUE_ID IS NULL )
                AND (  x_TERR_VALUE_ID IS NULL )))
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
       AND (    ( Recinfo.TERR_QUAL_ID = x_TERR_QUAL_ID)
            OR (    ( Recinfo.TERR_QUAL_ID IS NULL )
                AND (  x_TERR_QUAL_ID IS NULL )))
       AND (    ( Recinfo.INCLUDE_FLAG = x_INCLUDE_FLAG)
            OR (    ( Recinfo.INCLUDE_FLAG IS NULL )
                AND (  x_INCLUDE_FLAG IS NULL )))
       AND (    ( Recinfo.COMPARISON_OPERATOR = x_COMPARISON_OPERATOR)
            OR (    ( Recinfo.COMPARISON_OPERATOR IS NULL )
                AND (  x_COMPARISON_OPERATOR IS NULL )))
       AND (    ( Recinfo.LOW_VALUE_CHAR = x_LOW_VALUE_CHAR)
            OR (    ( Recinfo.LOW_VALUE_CHAR IS NULL )
                AND (  x_LOW_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.HIGH_VALUE_CHAR = x_HIGH_VALUE_CHAR)
            OR (    ( Recinfo.HIGH_VALUE_CHAR IS NULL )
                AND (  x_HIGH_VALUE_CHAR IS NULL )))
       AND (    ( Recinfo.LOW_VALUE_NUMBER = x_LOW_VALUE_NUMBER)
            OR (    ( Recinfo.LOW_VALUE_NUMBER IS NULL )
                AND (  x_LOW_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.HIGH_VALUE_NUMBER = x_HIGH_VALUE_NUMBER)
            OR (    ( Recinfo.HIGH_VALUE_NUMBER IS NULL )
                AND (  x_HIGH_VALUE_NUMBER IS NULL )))
       AND (    ( Recinfo.VALUE_SET = x_VALUE_SET)
            OR (    ( Recinfo.VALUE_SET IS NULL )
                AND (  x_VALUE_SET IS NULL )))
       AND (    ( Recinfo.INTEREST_TYPE_ID = x_INTEREST_TYPE_ID)
            OR (    ( Recinfo.INTEREST_TYPE_ID IS NULL )
                AND (  x_INTEREST_TYPE_ID IS NULL )))
       AND (    ( Recinfo.PRIMARY_INTEREST_CODE_ID = x_PRIMARY_INTEREST_CODE_ID)
            OR (    ( Recinfo.PRIMARY_INTEREST_CODE_ID IS NULL )
                AND (  x_PRIMARY_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.SECONDARY_INTEREST_CODE_ID = x_SECONDARY_INTEREST_CODE_ID)
            OR (    ( Recinfo.SECONDARY_INTEREST_CODE_ID IS NULL )
                AND (  x_SECONDARY_INTEREST_CODE_ID IS NULL )))
       AND (    ( Recinfo.CURRENCY_CODE = x_CURRENCY_CODE)
            OR (    ( Recinfo.CURRENCY_CODE IS NULL )
                AND (  x_CURRENCY_CODE IS NULL )))
       AND (    ( Recinfo.ID_USED_FLAG = x_ID_USED_FLAG)
            OR (    ( Recinfo.ID_USED_FLAG IS NULL )
                AND (  x_ID_USED_FLAG IS NULL )))
        AND (    ( Recinfo.LOW_VALUE_CHAR_ID = x_LOW_VALUE_CHAR_ID)
            OR (    ( Recinfo.LOW_VALUE_CHAR_ID IS NULL )
                AND (  x_LOW_VALUE_CHAR_ID IS NULL )))
        AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID IS NULL )
                AND (  x_ORG_ID IS NULL )))
        AND (    ( Recinfo.CNR_GROUP_ID = x_CNR_GROUP_ID)
            OR (    ( Recinfo.CNR_GROUP_ID IS NULL )
                AND (  x_CNR_GROUP_ID IS NULL )))
         AND (    ( Recinfo.VALUE1_ID = x_VALUE1_ID)
            OR (    ( Recinfo.VALUE1_ID IS NULL )
                AND (  x_VALUE1_ID IS NULL )))
         AND (    ( Recinfo.VALUE2_ID = x_VALUE2_ID)
            OR (    ( Recinfo.VALUE2_ID IS NULL )
                AND (  x_VALUE2_ID IS NULL )))
         AND (    ( Recinfo.VALUE3_ID = x_VALUE3_ID)
            OR (    ( Recinfo.VALUE3_ID IS NULL )
                AND (  x_VALUE3_ID IS NULL )))
         AND (    ( Recinfo.VALUE4_ID = x_VALUE4_ID)
            OR (    ( Recinfo.VALUE4_ID IS NULL )
                AND (  x_VALUE4_ID IS NULL )))

                ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


END JTF_TERR_VALUES_PKG;


/
