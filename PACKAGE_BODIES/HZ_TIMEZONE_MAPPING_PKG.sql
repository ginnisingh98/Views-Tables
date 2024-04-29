--------------------------------------------------------
--  DDL for Package Body HZ_TIMEZONE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TIMEZONE_MAPPING_PKG" as
/*$Header: ARHTZMPB.pls 120.2 2005/10/30 03:55:20 appldev ship $ */


PROCEDURE Insert_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM HZ_TIMEZONE_MAPPING
            WHERE MAPPING_ID = x_MAPPING_ID;
   CURSOR C2 IS SELECT HZ_TIMEZONE_MAP_s.nextval FROM sys.dual;
   v_MAPPING_ID		number;
   v_ROWID		varchar2(30);
BEGIN
   If (x_MAPPING_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO v_MAPPING_ID;
       CLOSE C2;
   End If;
   INSERT INTO HZ_TIMEZONE_MAPPING(
           MAPPING_ID,
           AREA_CODE,
           POSTAL_CODE,
           CITY,
           STATE,
           PROVINCE,
           COUNTRY,
           TIMEZONE_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
          ) VALUES (
          v_MAPPING_ID,
           decode( x_AREA_CODE, FND_API.G_MISS_CHAR, NULL,x_AREA_CODE),
           decode( x_POSTAL_CODE, FND_API.G_MISS_CHAR, NULL,x_POSTAL_CODE),
           decode( x_CITY, FND_API.G_MISS_CHAR, NULL,x_CITY),
           decode( x_STATE, FND_API.G_MISS_CHAR, NULL,x_STATE),
           decode( x_PROVINCE, FND_API.G_MISS_CHAR, NULL,x_PROVINCE),
           decode( x_COUNTRY, FND_API.G_MISS_CHAR, NULL,x_COUNTRY),
           decode( x_TIMEZONE_ID, FND_API.G_MISS_NUM, NULL,x_TIMEZONE_ID),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, NULL,x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN));
   OPEN C;
   FETCH C INTO v_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_MAPPING_ID                    NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_TIMEZONE_MAPPING
    WHERE MAPPING_ID = x_MAPPING_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER
 ) IS
 BEGIN
    Update HZ_TIMEZONE_MAPPING
    SET
             MAPPING_ID = decode( x_MAPPING_ID, FND_API.G_MISS_NUM,MAPPING_ID,x_MAPPING_ID),
             AREA_CODE = decode( x_AREA_CODE, FND_API.G_MISS_CHAR,AREA_CODE,x_AREA_CODE),
             POSTAL_CODE = decode( x_POSTAL_CODE, FND_API.G_MISS_CHAR,POSTAL_CODE,x_POSTAL_CODE),
             CITY = decode( x_CITY, FND_API.G_MISS_CHAR,CITY,x_CITY),
             STATE = decode( x_STATE, FND_API.G_MISS_CHAR,STATE,x_STATE),
             PROVINCE = decode( x_PROVINCE, FND_API.G_MISS_CHAR,PROVINCE,x_PROVINCE),
             COUNTRY = decode( x_COUNTRY, FND_API.G_MISS_CHAR,COUNTRY,x_COUNTRY),
             TIMEZONE_ID = decode( x_TIMEZONE_ID, FND_API.G_MISS_NUM,TIMEZONE_ID,x_TIMEZONE_ID),
             -- Bug 3032780
             /*
             CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
             CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
             */
             LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
             LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
             LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN)
    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_TIMEZONE_MAPPING
         WHERE rowid = x_Rowid
         FOR UPDATE of MAPPING_ID NOWAIT;
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
           (    ( Recinfo.MAPPING_ID = x_MAPPING_ID)
            OR (    ( Recinfo.MAPPING_ID = NULL )
                AND (  x_MAPPING_ID = NULL )))
       AND (    ( Recinfo.AREA_CODE = x_AREA_CODE)
            OR (    ( Recinfo.AREA_CODE = NULL )
                AND (  x_AREA_CODE = NULL )))
       AND (    ( Recinfo.POSTAL_CODE = x_POSTAL_CODE)
            OR (    ( Recinfo.POSTAL_CODE = NULL )
                AND (  x_POSTAL_CODE = NULL )))
       AND (    ( Recinfo.CITY = x_CITY)
            OR (    ( Recinfo.CITY = NULL )
                AND (  x_CITY = NULL )))
       AND (    ( Recinfo.STATE = x_STATE)
            OR (    ( Recinfo.STATE = NULL )
                AND (  x_STATE = NULL )))
       AND (    ( Recinfo.PROVINCE = x_PROVINCE)
            OR (    ( Recinfo.PROVINCE = NULL )
                AND (  x_PROVINCE = NULL )))
       AND (    ( Recinfo.COUNTRY = x_COUNTRY)
            OR (    ( Recinfo.COUNTRY = NULL )
                AND (  x_COUNTRY = NULL )))
       AND (    ( Recinfo.TIMEZONE_ID = x_TIMEZONE_ID)
            OR (    ( Recinfo.TIMEZONE_ID = NULL )
                AND (  x_TIMEZONE_ID = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

END HZ_TIMEZONE_MAPPING_PKG;

/
