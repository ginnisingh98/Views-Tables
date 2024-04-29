--------------------------------------------------------
--  DDL for Package Body HZ_PHONE_AREA_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PHONE_AREA_CODES_PKG" AS
/*$Header: ARHPHARB.pls 120.5 2005/10/30 03:54:00 appldev noship $ */

PROCEDURE Insert_Row(
                    p_rowid                IN OUT NOCOPY          VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_AREA_CODE                            VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER                NUMBER,
                    p_TIMEZONE_ID			   NUMBER DEFAULT NULL) IS

CURSOR C IS SELECT rowid FROM HZ_PHONE_AREA_CODES
            WHERE TERRITORY_CODE     = p_TERRITORY_CODE
            AND   AREA_CODE  =  p_AREA_CODE ;


 begin

   insert into HZ_PHONE_AREA_CODES(
   TERRITORY_CODE,
   AREA_CODE,
   PHONE_COUNTRY_CODE,
   DESCRIPTION ,
   TIMEZONE_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATE_LOGIN,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   OBJECT_VERSION_NUMBER ) VALUES(
   p_TERRITORY_CODE,
   decode(p_AREA_CODE,    FND_API.G_MISS_CHAR, NULL, p_AREA_CODE),
   decode(p_PHONE_COUNTRY_CODE,    FND_API.G_MISS_CHAR, NULL,
          p_PHONE_COUNTRY_CODE),
   decode(p_DESCRIPTION,    FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
    decode(p_TIMEZONE_ID,    FND_API.G_MISS_NUM, NULL, p_TIMEZONE_ID),
   decode(p_created_by,       FND_API.G_MISS_NUM,  NULL, p_created_by),
   decode(p_creation_date,    FND_API.G_MISS_DATE, to_date(NULL), p_creation_date),
   decode(p_last_update_login,FND_API.G_MISS_NUM,  NULL, p_last_update_login),
   decode(p_last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
   decode(p_last_updated_by,  FND_API.G_MISS_NUM,  NULL, p_last_updated_by),
   1
     );

 OPEN C;
   FETCH C INTO p_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;

end;

PROCEDURE Update_Row(
                    p_rowid                                VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_AREA_CODE                            VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER IN OUT NOCOPY         NUMBER,
		    p_TIMEZONE_ID			   NUMBER DEFAULT NULL) IS
l_object_version_number number;

   BEGIN

 l_object_version_number := NVL(p_object_version_number, 1) + 1;

 UPDATE HZ_PHONE_AREA_CODES
  SET
   TERRITORY_CODE     = decode(p_TERRITORY_CODE,    FND_API.G_MISS_CHAR,
                                 TERRITORY_CODE, p_TERRITORY_CODE),
   AREA_CODE          = decode(p_AREA_CODE,    FND_API.G_MISS_CHAR,
                                 AREA_CODE, p_AREA_CODE),
   PHONE_COUNTRY_CODE = decode(p_PHONE_COUNTRY_CODE,    FND_API.G_MISS_CHAR,
                                 PHONE_COUNTRY_CODE, p_PHONE_COUNTRY_CODE),
   DESCRIPTION    = decode(p_DESCRIPTION,    FND_API.G_MISS_CHAR,
                             DESCRIPTION, p_DESCRIPTION),
   TIMEZONE_ID     = decode(p_TIMEZONE_ID,FND_API.G_MISS_NUM,
                             TIMEZONE_ID, p_TIMEZONE_ID),
   -- Bug 3032780
   /*
   CREATED_BY     = decode(p_created_by,FND_API.G_MISS_NUM,
                             CREATED_BY, p_created_by),
 CREATION_DATE    = decode(p_CREATION_DATE, FND_API.G_MISS_DATE,
                             CREATION_DATE,p_CREATION_DATE),
 */
  LAST_UPDATE_LOGIN = decode(p_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,
                              LAST_UPDATE_LOGIN,p_LAST_UPDATE_LOGIN),
 LAST_UPDATE_DATE  = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                              LAST_UPDATE_DATE,p_LAST_UPDATE_DATE),
 LAST_UPDATED_BY   = decode(p_LAST_UPDATED_BY,  FND_API.G_MISS_NUM,
                              LAST_UPDATED_BY,p_LAST_UPDATED_BY),
 OBJECT_VERSION_NUMBER = decode(l_OBJECT_VERSION_NUMBER,  FND_API.G_MISS_NUM,
                                  OBJECT_VERSION_NUMBER,l_object_version_number)
WHERE ROWID   = P_ROWID;

  p_OBJECT_VERSION_NUMBER := l_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Lock_Row(
                   p_TERRITORY_CODE        IN OUT NOCOPY     VARCHAR2,
                   p_AREA_CODE             IN OUT NOCOPY     VARCHAR2,
                   p_OBJECT_VERSION_NUMBER IN          NUMBER)
 IS
 CURSOR C IS

 SELECT OBJECT_VERSION_NUMBER
 FROM HZ_PHONE_AREA_CODES
 WHERE TERRITORY_CODE  = p_TERRITORY_CODE
 AND AREA_CODE = p_AREA_CODE
 FOR UPDATE OF TERRITORY_CODE , AREA_CODE NOWAIT;
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
         ( Recinfo.OBJECT_VERSION_NUMBER IS NOT NULL AND p_OBJECT_VERSION_NUMBER IS NOT NULL
            AND  Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER )
         OR ((Recinfo.OBJECT_VERSION_NUMBER   IS NULL)AND (p_OBJECT_VERSION_NUMBER  IS NULL ))

      ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;

PROCEDURE Delete_Row(p_TERRITORY_CODE VARCHAR2, P_AREA_CODE VARCHAR2 ) IS
BEGIN
   DELETE FROM HZ_PHONE_AREA_CODES
   WHERE TERRITORY_CODE  = p_TERRITORY_CODE
   AND AREA_CODE = p_AREA_CODE;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


END;

/
