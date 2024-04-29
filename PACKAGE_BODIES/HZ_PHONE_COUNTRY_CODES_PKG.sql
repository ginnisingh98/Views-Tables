--------------------------------------------------------
--  DDL for Package Body HZ_PHONE_COUNTRY_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PHONE_COUNTRY_CODES_PKG" AS
/*$Header: ARHPHCCB.pls 120.5 2005/10/30 03:54:02 appldev noship $ */
PROCEDURE Update_Row(
                    p_TERRITORY_CODE                    VARCHAR2,
                    p_PHONE_COUNTRY_CODE                VARCHAR2,
                    p_PHONE_LENGTH                      NUMBER,
                    p_AREA_CODE_LENGTH                  NUMBER,
                    p_TRUNK_PREFIX                      VARCHAR2,
                    p_INTL_PREFIX                       VARCHAR2,
                    p_VALIDATION_PROC                   VARCHAR2,
                    p_CREATED_BY                        NUMBER,
                    p_CREATION_DATE                     DATE,
                    p_LAST_UPDATE_LOGIN                 NUMBER,
                    p_LAST_UPDATE_DATE                  DATE,
                    p_LAST_UPDATED_BY                   NUMBER,
                    p_OBJECT_VERSION_NUMBER  IN OUT NOCOPY     NUMBER,
	            p_TIMEZONE_ID			NUMBER DEFAULT NULL) IS

l_object_version_number number;

   BEGIN

    l_object_version_number := NVL(p_object_version_number, 1) + 1;

  UPDATE HZ_PHONE_COUNTRY_CODES
  SET
 phone_country_code = decode(p_phone_country_code,FND_API.G_MISS_CHAR,
                                phone_country_code, p_phone_country_code),
 PHONE_LENGTH      =decode(p_PHONE_LENGTH,FND_API.G_MISS_NUM,
                                PHONE_LENGTH, p_PHONE_LENGTH),
 AREA_CODE_LENGTH   =decode(p_AREA_CODE_LENGTH,FND_API.G_MISS_NUM,
                                AREA_CODE_LENGTH, p_AREA_CODE_LENGTH),
 TRUNK_PREFIX      =decode(p_TRUNK_PREFIX,FND_API.G_MISS_CHAR,
                                TRUNK_PREFIX, p_TRUNK_PREFIX),
 INTL_PREFIX       =decode(p_INTL_PREFIX,FND_API.G_MISS_CHAR,
                                INTL_PREFIX, p_INTL_PREFIX),
 VALIDATION_PROC  =decode(p_VALIDATION_PROC,FND_API.G_MISS_CHAR,
                                VALIDATION_PROC, p_VALIDATION_PROC),
 TIMEZONE_ID       = decode(p_TIMEZONE_ID,FND_API.G_MISS_NUM,
                             TIMEZONE_ID, p_TIMEZONE_ID),
 -- Bug 3032780
 /*
 CREATED_BY       = decode(p_created_by,FND_API.G_MISS_NUM,
                             CREATED_BY, p_created_by),
 CREATION_DATE    = decode(p_CREATION_DATE, FND_API.G_MISS_DATE,
                             CREATION_DATE,p_CREATION_DATE),
 */
 LAST_UPDATE_LOGIN     = decode(p_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,
                                  LAST_UPDATE_LOGIN,p_LAST_UPDATE_LOGIN),
 LAST_UPDATE_DATE      = decode(p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,
                                  LAST_UPDATE_DATE,p_LAST_UPDATE_DATE),
 LAST_UPDATED_BY       = decode(p_LAST_UPDATED_BY,  FND_API.G_MISS_NUM,
                                  LAST_UPDATED_BY,p_LAST_UPDATED_BY),
 OBJECT_VERSION_NUMBER = decode(l_OBJECT_VERSION_NUMBER,  FND_API.G_MISS_NUM,
                                  OBJECT_VERSION_NUMBER,l_object_version_number)
WHERE TERRITORY_CODE = P_TERRITORY_CODE;

    p_OBJECT_VERSION_NUMBER := l_OBJECT_VERSION_NUMBER;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;

PROCEDURE Lock_Row(
                   p_TERRITORY_CODE        IN OUT NOCOPY     VARCHAR2,
                   p_OBJECT_VERSION_NUMBER IN          NUMBER)
 IS
 CURSOR C IS

 SELECT OBJECT_VERSION_NUMBER
 FROM HZ_PHONE_COUNTRY_CODES
 WHERE TERRITORY_CODE  = p_TERRITORY_CODE
 FOR UPDATE OF TERRITORY_CODE NOWAIT;
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

END;

/
