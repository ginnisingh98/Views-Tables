--------------------------------------------------------
--  DDL for Package Body HZ_PHONE_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PHONE_FORMATS_PKG" AS
/*$Header: ARHPHFPB.pls 120.2 2005/06/16 21:14:11 jhuang noship $ */
PROCEDURE Insert_Row(
                    p_rowid                      IN OUT    NOCOPY VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_PHONE_FORMAT_STYLE                   VARCHAR2,
                    p_COUNTRY_CODE_DISPLAY_FLAG            VARCHAR2,
                    p_AREA_CODE_SIZE                       NUMBER,
                    p_FORMAT_NAME                          VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER                NUMBER) IS

 CURSOR C IS SELECT rowid FROM HZ_PHONE_FORMATS
            WHERE TERRITORY_CODE     = p_TERRITORY_CODE
            AND   PHONE_FORMAT_STYLE =  p_PHONE_FORMAT_STYLE;

 begin

   insert into HZ_PHONE_FORMATS(
   TERRITORY_CODE,
   PHONE_FORMAT_STYLE,
   COUNTRY_CODE_DISPLAY_FLAG,
   AREA_CODE_SIZE,
   FORMAT_NAME,
   DESCRIPTION ,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATE_LOGIN,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   OBJECT_VERSION_NUMBER ) VALUES(
   p_TERRITORY_CODE,
   decode(p_PHONE_FORMAT_STYLE,    FND_API.G_MISS_CHAR, NULL, p_PHONE_FORMAT_STYLE),
   decode(p_COUNTRY_CODE_DISPLAY_FLAG,    FND_API.G_MISS_CHAR, NULL,
          p_COUNTRY_CODE_DISPLAY_FLAG),
   decode(p_AREA_CODE_SIZE,    FND_API.G_MISS_NUM, NULL, p_AREA_CODE_SIZE),
   decode(p_FORMAT_NAME,    FND_API.G_MISS_CHAR, NULL, p_FORMAT_NAME),
   decode(p_DESCRIPTION,    FND_API.G_MISS_CHAR, NULL, p_DESCRIPTION),
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
                    p_PHONE_FORMAT_STYLE                   VARCHAR2,
                    p_COUNTRY_CODE_DISPLAY_FLAG            VARCHAR2,
                    p_AREA_CODE_SIZE                       NUMBER,
                    p_FORMAT_NAME                          VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER IN OUT         NOCOPY NUMBER) IS
l_object_version_number number;

   BEGIN

    l_object_version_number := NVL(p_object_version_number, 1) + 1;
 UPDATE HZ_PHONE_FORMATS
  SET
  TERRITORY_CODE = decode(p_TERRITORY_CODE,  FND_API.G_MISS_CHAR,
                             TERRITORY_CODE, p_TERRITORY_CODE),
  PHONE_FORMAT_STYLE = decode(p_PHONE_FORMAT_STYLE,  FND_API.G_MISS_CHAR,
                             PHONE_FORMAT_STYLE, p_PHONE_FORMAT_STYLE),
  COUNTRY_CODE_DISPLAY_FLAG = decode(p_COUNTRY_CODE_DISPLAY_FLAG,
                               FND_API.G_MISS_CHAR, COUNTRY_CODE_DISPLAY_FLAG,                                p_COUNTRY_CODE_DISPLAY_FLAG),
  AREA_CODE_SIZE = decode(p_AREA_CODE_SIZE,    FND_API.G_MISS_NUM,
                            AREA_CODE_SIZE,     p_AREA_CODE_SIZE),
  FORMAT_NAME    = decode(p_FORMAT_NAME,    FND_API.G_MISS_CHAR,
                             FORMAT_NAME, p_FORMAT_NAME),
  DESCRIPTION    = decode(p_DESCRIPTION,    FND_API.G_MISS_CHAR,
                             DESCRIPTION, p_DESCRIPTION),
  -- bug 3032780
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
WHERE rowid = p_RowId;

  p_OBJECT_VERSION_NUMBER := l_OBJECT_VERSION_NUMBER;


    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;

    End If;
 END Update_Row;

PROCEDURE Lock_Row(
                   p_TERRITORY_CODE        IN OUT     NOCOPY VARCHAR2,
                   p_PHONE_FORMAT_STYLE    IN OUT     NOCOPY VARCHAR2,
                   p_OBJECT_VERSION_NUMBER IN          NUMBER)
 IS
 CURSOR C IS

 SELECT OBJECT_VERSION_NUMBER
 FROM HZ_PHONE_FORMATS
 WHERE TERRITORY_CODE  = p_TERRITORY_CODE
 AND PHONE_FORMAT_STYLE = p_PHONE_FORMAT_STYLE
 FOR UPDATE OF TERRITORY_CODE , PHONE_FORMAT_STYLE NOWAIT;
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

PROCEDURE Delete_Row(p_TERRITORY_CODE VARCHAR2, P_PHONE_FORMAT_STYLE VARCHAR2 ) IS
BEGIN
   DELETE FROM HZ_PHONE_FORMATS
   WHERE TERRITORY_CODE  = p_TERRITORY_CODE
   AND PHONE_FORMAT_STYLE = p_PHONE_FORMAT_STYLE;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;


END;

/
