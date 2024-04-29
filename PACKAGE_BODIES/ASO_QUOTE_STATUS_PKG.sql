--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_STATUS_PKG" as
/* $Header: asotstab.pls 120.3 2006/05/22 23:00:57 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_STATUS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_QUOTE_STATUSE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asotstab.pls';

PROCEDURE Insert_Row(
          px_QUOTE_STATUS_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_STATUS_CODE    VARCHAR2,
          p_UPDATE_ALLOWED_FLAG    VARCHAR2,
          p_AUTO_VERSION_FLAG    VARCHAR2,
          p_USER_MAINTAINABLE_FLAG    VARCHAR2,
          p_EFFECTIVE_START_DATE    DATE,
          p_EFFECTIVE_END_DATE    DATE,
          p_ALLOW_LOV_TO_FLAG     VARCHAR2,
          p_ALLOW_LOV_FROM_FLAG   VARCHAR2,
          p_ALLOW_NEW_TO_FLAG     VARCHAR2,
          p_ALLOW_NEW_FROM_FLAG   VARCHAR2,
          p_SEED_TAG              VARCHAR2,
          p_ENABLED_FLAG          VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
           p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
	  p_MEANING		VARCHAR2,
	  p_DESCRIPTION		VARCHAR2)

IS
   CURSOR C IS SELECT ASO_QUOTE_STATUSES_B_S.nextval FROM sys.dual;
BEGIN
   If (px_QUOTE_STATUS_ID IS NULL) OR (px_QUOTE_STATUS_ID = FND_API.G_MISS_NUM) then
       OPEN C;
       FETCH C INTO px_QUOTE_STATUS_ID;
       CLOSE C;
   End If;
   INSERT INTO ASO_QUOTE_STATUSES_B(
           QUOTE_STATUS_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           STATUS_CODE,
           UPDATE_ALLOWED_FLAG,
           AUTO_VERSION_FLAG,
           USER_MAINTAINABLE_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           ALLOW_LOV_TO_FLAG,
           ALLOW_LOV_FROM_FLAG,
           ALLOW_NEW_TO_FLAG,
           ALLOW_NEW_FROM_FLAG,
           SEED_TAG,
           ENABLED_FLAG,
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
           ATTRIBUTE15,
           ATTRIBUTE16,
           ATTRIBUTE17,
           ATTRIBUTE18,
           ATTRIBUTE19,
           ATTRIBUTE20
          ) VALUES (
           px_QUOTE_STATUS_ID,
           ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, NULL, p_STATUS_CODE),
           decode( p_UPDATE_ALLOWED_FLAG, FND_API.G_MISS_CHAR, NULL, p_UPDATE_ALLOWED_FLAG),
           decode( p_AUTO_VERSION_FLAG, FND_API.G_MISS_CHAR, NULL, p_AUTO_VERSION_FLAG),
           decode( p_USER_MAINTAINABLE_FLAG, FND_API.G_MISS_CHAR, NULL, p_USER_MAINTAINABLE_FLAG),
           ASO_UTILITY_PVT.decode( trunc(p_EFFECTIVE_START_DATE), FND_API.G_MISS_DATE, NULL, trunc(p_EFFECTIVE_START_DATE)),
           ASO_UTILITY_PVT.decode( trunc(p_EFFECTIVE_END_DATE), FND_API.G_MISS_DATE, NULL, trunc(p_EFFECTIVE_END_DATE)),
           decode( p_ALLOW_LOV_TO_FLAG, FND_API.G_MISS_CHAR, NULL, p_ALLOW_LOV_TO_FLAG),
           decode( p_ALLOW_LOV_FROM_FLAG, FND_API.G_MISS_CHAR, NULL, p_ALLOW_LOV_FROM_FLAG),
           decode( p_ALLOW_NEW_TO_FLAG, FND_API.G_MISS_CHAR, NULL, p_ALLOW_NEW_TO_FLAG),
           decode( p_ALLOW_NEW_FROM_FLAG, FND_API.G_MISS_CHAR, NULL, p_ALLOW_NEW_FROM_FLAG),
           decode( p_SEED_TAG, FND_API.G_MISS_CHAR, NULL, p_SEED_TAG),
           decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, NULL, p_ENABLED_FLAG),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15),
           decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE16),
           decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE17),
           decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE18),
           decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE19),
           decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE20)
            );

    insert into ASO_QUOTE_STATUSES_TL (
           QUOTE_STATUS_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
	   MEANING,
	   DESCRIPTION,
	   LANGUAGE,
	   SOURCE_LANG
	   ) select
           px_QUOTE_STATUS_ID,
           ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, p_CREATION_DATE),
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_REQUEST_ID, FND_API.G_MISS_NUM, NULL, p_REQUEST_ID),
           decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_APPLICATION_ID),
           decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, NULL, p_PROGRAM_ID),
           ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, p_PROGRAM_UPDATE_DATE),
           decode( p_meaning, FND_API.G_MISS_CHAR, NULL, p_meaning),
	   decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description),
	   L.LANGUAGE_CODE,
	   userenv('LANG')
	   from FND_LANGUAGES L
	   where L.INSTALLED_FLAG in ('I', 'B')
	   and not exists
		(select NULL from ASO_QUOTE_STATUSES_TL T
		where T.QUOTE_STATUS_ID = px_QUOTE_STATUS_ID
		and T.LANGUAGE = L.LANGUAGE_CODE);
End Insert_Row;

PROCEDURE Update_Row(
          p_QUOTE_STATUS_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_STATUS_CODE    VARCHAR2,
          p_UPDATE_ALLOWED_FLAG    VARCHAR2,
          p_AUTO_VERSION_FLAG    VARCHAR2,
          p_USER_MAINTAINABLE_FLAG    VARCHAR2,
          p_EFFECTIVE_START_DATE    DATE,
          p_EFFECTIVE_END_DATE    DATE,
          p_ALLOW_LOV_TO_FLAG     VARCHAR2,
          p_ALLOW_LOV_FROM_FLAG   VARCHAR2,
          p_ALLOW_NEW_TO_FLAG     VARCHAR2,
          p_ALLOW_NEW_FROM_FLAG   VARCHAR2,
          p_SEED_TAG              VARCHAR2,
          p_ENABLED_FLAG          VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE16    VARCHAR2,
          p_ATTRIBUTE17    VARCHAR2,
          p_ATTRIBUTE18    VARCHAR2,
          p_ATTRIBUTE19    VARCHAR2,
          p_ATTRIBUTE20    VARCHAR2,
	     p_MEANING	   VARCHAR2,
	     p_DESCRIPTION    VARCHAR2)
IS
BEGIN
    Update ASO_QUOTE_STATUSES_B
    SET
              CREATION_DATE = ASO_UTILITY_PVT.decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
              PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
              PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
              PROGRAM_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
              STATUS_CODE = decode( p_STATUS_CODE, FND_API.G_MISS_CHAR, STATUS_CODE, p_STATUS_CODE),
              UPDATE_ALLOWED_FLAG = decode( p_UPDATE_ALLOWED_FLAG, FND_API.G_MISS_CHAR, UPDATE_ALLOWED_FLAG, p_UPDATE_ALLOWED_FLAG),
              AUTO_VERSION_FLAG = decode( p_AUTO_VERSION_FLAG, FND_API.G_MISS_CHAR, AUTO_VERSION_FLAG, p_AUTO_VERSION_FLAG),
              USER_MAINTAINABLE_FLAG = decode( p_USER_MAINTAINABLE_FLAG, FND_API.G_MISS_CHAR, USER_MAINTAINABLE_FLAG, p_USER_MAINTAINABLE_FLAG),
              EFFECTIVE_START_DATE = ASO_UTILITY_PVT.decode( trunc(p_EFFECTIVE_START_DATE), FND_API.G_MISS_DATE, EFFECTIVE_START_DATE, trunc(p_EFFECTIVE_START_DATE)),

              EFFECTIVE_END_DATE = ASO_UTILITY_PVT.decode( trunc(p_EFFECTIVE_END_DATE), FND_API.G_MISS_DATE, EFFECTIVE_END_DATE,trunc(p_EFFECTIVE_END_DATE)),
              ALLOW_LOV_TO_FLAG = decode( p_ALLOW_LOV_TO_FLAG, FND_API.G_MISS_CHAR, ALLOW_LOV_TO_FLAG, p_ALLOW_LOV_TO_FLAG),
              ALLOW_LOV_FROM_FLAG = decode( p_ALLOW_LOV_FROM_FLAG, FND_API.G_MISS_CHAR, ALLOW_LOV_FROM_FLAG, p_ALLOW_LOV_FROM_FLAG),
              ALLOW_NEW_TO_FLAG = decode( p_ALLOW_NEW_TO_FLAG, FND_API.G_MISS_CHAR, ALLOW_NEW_TO_FLAG, p_ALLOW_NEW_TO_FLAG),
              ALLOW_NEW_FROM_FLAG = decode( p_ALLOW_NEW_FROM_FLAG, FND_API.G_MISS_CHAR, ALLOW_NEW_FROM_FLAG, p_ALLOW_NEW_FROM_FLAG),
              SEED_TAG = decode( p_SEED_TAG, FND_API.G_MISS_CHAR, SEED_TAG, p_SEED_TAG),
              ENABLED_FLAG = decode( p_ENABLED_FLAG, FND_API.G_MISS_CHAR, ENABLED_FLAG, p_ENABLED_FLAG),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15),
              ATTRIBUTE16 = decode( p_ATTRIBUTE16, FND_API.G_MISS_CHAR, ATTRIBUTE16, p_ATTRIBUTE16),
              ATTRIBUTE17 = decode( p_ATTRIBUTE17, FND_API.G_MISS_CHAR, ATTRIBUTE17, p_ATTRIBUTE17),
              ATTRIBUTE18 = decode( p_ATTRIBUTE18, FND_API.G_MISS_CHAR, ATTRIBUTE18, p_ATTRIBUTE18),
              ATTRIBUTE19 = decode( p_ATTRIBUTE19, FND_API.G_MISS_CHAR, ATTRIBUTE19, p_ATTRIBUTE19),
              ATTRIBUTE20 = decode( p_ATTRIBUTE20, FND_API.G_MISS_CHAR, ATTRIBUTE20, p_ATTRIBUTE20)
    where QUOTE_STATUS_ID = p_QUOTE_STATUS_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

  update ASO_QUOTE_STATUSES_TL set
	MEANING = decode( p_MEANING, FND_API.G_MISS_CHAR, meaning, p_MEANING),
	DESCRIPTION = decode( p_DESCRIPTION, FND_API.G_MISS_CHAR, meaning, p_DESCRIPTION),
        LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
        LAST_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
        LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
        REQUEST_ID = decode( p_REQUEST_ID, FND_API.G_MISS_NUM, REQUEST_ID, p_REQUEST_ID),
        PROGRAM_APPLICATION_ID = decode( p_PROGRAM_APPLICATION_ID, FND_API.G_MISS_NUM, PROGRAM_APPLICATION_ID, p_PROGRAM_APPLICATION_ID),
        PROGRAM_ID = decode( p_PROGRAM_ID, FND_API.G_MISS_NUM, PROGRAM_ID, p_PROGRAM_ID),
        PROGRAM_UPDATE_DATE = ASO_UTILITY_PVT.decode( p_PROGRAM_UPDATE_DATE, FND_API.G_MISS_DATE, PROGRAM_UPDATE_DATE, p_PROGRAM_UPDATE_DATE),
	SOURCE_LANG = userenv('LANG')
  where QUOTE_STATUS_ID = P_QUOTE_STATUS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
END Update_Row;

PROCEDURE Delete_Row(
    p_QUOTE_STATUS_ID  NUMBER)
IS
BEGIN
   DELETE FROM ASO_QUOTE_STATUSES_B
    WHERE QUOTE_STATUS_ID = p_QUOTE_STATUS_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   delete from ASO_QUOTE_STATUSES_TL
   where QUOTE_STATUS_ID = p_QUOTE_STATUS_ID;
   if (sql%notfound) then
     raise no_data_found;
   end if;
END Delete_Row;

PROCEDURE Lock_Row(
          p_QUOTE_STATUS_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_STATUS_CODE    VARCHAR2,
          p_UPDATE_ALLOWED_FLAG    VARCHAR2,
          p_AUTO_VERSION_FLAG    VARCHAR2,
          p_USER_MAINTAINABLE_FLAG    VARCHAR2,
          p_EFFECTIVE_START_DATE    DATE,
          p_EFFECTIVE_END_DATE    DATE,
          p_ALLOW_LOV_TO_FLAG     VARCHAR2,
          p_ALLOW_LOV_FROM_FLAG   VARCHAR2,
          p_ALLOW_NEW_TO_FLAG     VARCHAR2,
          p_ALLOW_NEW_FROM_FLAG   VARCHAR2,
          p_SEED_TAG              VARCHAR2,
          p_ENABLED_FLAG          VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
	  p_MEANING	   VARCHAR2,
	  p_DESCRIPTION    VARCHAR2)

IS
   CURSOR C IS
        SELECT *
         FROM ASO_QUOTE_STATUSES_B
        WHERE QUOTE_STATUS_ID =  p_QUOTE_STATUS_ID
        FOR UPDATE of QUOTE_STATUS_ID NOWAIT;
   Recinfo C%ROWTYPE;

   CURSOR C_TL IS
	SELECT MEANING, DESCRIPTION,
		 decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
	FROM ASO_QUOTE_STATUSES_TL
	WHERE QUOTE_STATUS_ID =  p_QUOTE_STATUS_ID
	  AND userenv('LANG') in (LANGUAGE, SOURCE_LANG)
        FOR UPDATE of QUOTE_STATUS_ID NOWAIT;

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
/*
           (      Recinfo.QUOTE_STATUS_ID = p_QUOTE_STATUS_ID)
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND
*/
	  (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
/*
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.REQUEST_ID = p_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID IS NULL )
                AND (  p_REQUEST_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
                AND (  p_PROGRAM_APPLICATION_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_ID = p_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID IS NULL )
                AND (  p_PROGRAM_ID IS NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = p_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
                AND (  p_PROGRAM_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.STATUS_CODE = p_STATUS_CODE)
            OR (    ( Recinfo.STATUS_CODE IS NULL )
                AND (  p_STATUS_CODE IS NULL )))
       AND (    ( Recinfo.UPDATE_ALLOWED_FLAG = p_UPDATE_ALLOWED_FLAG)
            OR (    ( Recinfo.UPDATE_ALLOWED_FLAG IS NULL )
                AND (  p_UPDATE_ALLOWED_FLAG IS NULL )))
       AND (    ( Recinfo.AUTO_VERSION_FLAG = p_AUTO_VERSION_FLAG)
            OR (    ( Recinfo.AUTO_VERSION_FLAG IS NULL )
                AND (  p_AUTO_VERSION_FLAG IS NULL )))
       AND (    ( Recinfo.USER_MAINTAINABLE_FLAG = p_USER_MAINTAINABLE_FLAG)
            OR (    ( Recinfo.USER_MAINTAINABLE_FLAG IS NULL )
                AND (  p_USER_MAINTAINABLE_FLAG IS NULL )))
       AND (    ( Recinfo.EFFECTIVE_START_DATE = p_EFFECTIVE_START_DATE)
            OR (    ( Recinfo.EFFECTIVE_START_DATE IS NULL )
                AND (  p_EFFECTIVE_START_DATE IS NULL )))
       AND (    ( Recinfo.EFFECTIVE_END_DATE = p_EFFECTIVE_END_DATE)
            OR (    ( Recinfo.EFFECTIVE_END_DATE IS NULL )
                AND (  p_EFFECTIVE_END_DATE IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
*/
       ) then
       null;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
   for tlinfo in c_tl loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.MEANING = p_MEANING)
               OR ((tlinfo.MEANING is null) AND (p_MEANING is null)))
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from ASO_QUOTE_STATUSES_TL T
  where not exists
    (select NULL
    from ASO_QUOTE_STATUSES_B B
    where B.QUOTE_STATUS_ID = T.QUOTE_STATUS_ID
    );

  update ASO_QUOTE_STATUSES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from ASO_QUOTE_STATUSES_TL B
    where B.QUOTE_STATUS_ID = T.QUOTE_STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUOTE_STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUOTE_STATUS_ID,
      SUBT.LANGUAGE
    from ASO_QUOTE_STATUSES_TL SUBB, ASO_QUOTE_STATUSES_TL SUBT
    where SUBB.QUOTE_STATUS_ID = SUBT.QUOTE_STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or (SUBB.MEANING is null and SUBT.MEANING is not null)
      or (SUBB.MEANING is not null and SUBT.MEANING is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ASO_QUOTE_STATUSES_TL (
    QUOTE_STATUS_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    MEANING,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUOTE_STATUS_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    B.MEANING,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ASO_QUOTE_STATUSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ASO_QUOTE_STATUSES_TL T
    where T.QUOTE_STATUS_ID = B.QUOTE_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_STATUS_CODE   in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_UPDATE_ALLOWED_FLAG  in VARCHAR2,
  X_AUTO_VERSION_FLAG  in VARCHAR2,
  X_USER_MAINTAINABLE_FLAG in  VARCHAR2,
  X_EFFECTIVE_START_DATE IN date,
  X_EFFECTIVE_END_DATE IN DATE,
  X_ALLOW_LOV_TO_FLAG     VARCHAR2,
  X_ALLOW_LOV_FROM_FLAG   VARCHAR2,
  X_ALLOW_NEW_TO_FLAG     VARCHAR2,
  X_ALLOW_NEW_FROM_FLAG   VARCHAR2,
  X_SEED_TAG              VARCHAR2,
  X_ENABLED_FLAG          VARCHAR2,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5  in VARCHAR2,
  X_ATTRIBUTE6  in VARCHAR2,
  X_ATTRIBUTE7  in VARCHAR2,
  X_ATTRIBUTE8  in VARCHAR2,
  X_ATTRIBUTE9  in VARCHAR2,
  X_ATTRIBUTE10  in VARCHAR2,
  X_ATTRIBUTE11  in VARCHAR2,
  X_ATTRIBUTE12  in VARCHAR2,
  X_ATTRIBUTE13  in VARCHAR2,
  X_ATTRIBUTE14  in VARCHAR2,
  X_ATTRIBUTE15  in VARCHAR2,
  X_ATTRIBUTE16  in VARCHAR2,
  X_ATTRIBUTE17  in VARCHAR2,
  X_ATTRIBUTE18  in VARCHAR2,
  X_ATTRIBUTE19  in VARCHAR2,
  X_ATTRIBUTE20  in VARCHAR2,
  X_OWNER   in VARCHAR2
) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);
     lx_quote_id        number;
     l_quote_status_id number;
     CURSOR C IS SELECT ASO_QUOTE_STATUSES_B_S.nextval FROM dual;
     CURSOR C2 IS SELECT QUOTE_STATUS_ID FROM ASO_QUOTE_STATUSES_VL
     WHERE STATUS_CODE= X_STATUS_CODE;

  begin
     -- get the user id
     user_id := fnd_load_util.owner_id(X_OWNER);

     begin
     for i in C2 loop
        l_quote_status_id := i.QUOTE_STATUS_ID;
        exit;
     end loop;
     IF (l_quote_status_id is not null) or (l_quote_status_id <> FND_API.G_MISS_NUM) THEN
    UPDATE_ROW (
          p_QUOTE_STATUS_ID => l_quote_status_id  ,
          p_STATUS_CODE   =>  X_STATUS_CODE  ,
          p_MEANING =>     X_MEANING,
          p_DESCRIPTION => X_DESCRIPTION ,
          p_UPDATE_ALLOWED_FLAG => X_UPDATE_ALLOWED_FLAG ,
          p_AUTO_VERSION_FLAG =>   X_AUTO_VERSION_FLAG ,
          p_USER_MAINTAINABLE_FLAG => X_USER_MAINTAINABLE_FLAG ,
          p_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE ,
          p_EFFECTIVE_END_DATE => X_EFFECTIVE_END_DATE ,
          p_ALLOW_LOV_TO_FLAG     => X_ALLOW_LOV_TO_FLAG,
          p_ALLOW_LOV_FROM_FLAG   => X_ALLOW_LOV_FROM_FLAG,
          p_ALLOW_NEW_TO_FLAG     => X_ALLOW_NEW_TO_FLAG,
          p_ALLOW_NEW_FROM_FLAG   => X_ALLOW_NEW_FROM_FLAG,
          p_SEED_TAG              => X_SEED_TAG,
          p_ENABLED_FLAG          => X_ENABLED_FLAG,
          p_ATTRIBUTE_CATEGORY   => X_ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => X_ATTRIBUTE1  ,
          p_ATTRIBUTE2  => X_ATTRIBUTE2  ,
          p_ATTRIBUTE3  => X_ATTRIBUTE3  ,
          p_ATTRIBUTE4  => X_ATTRIBUTE4  ,
          p_ATTRIBUTE5 =>  X_ATTRIBUTE5 ,
          p_ATTRIBUTE6  => X_ATTRIBUTE6  ,
          p_ATTRIBUTE7  => X_ATTRIBUTE7  ,
          p_ATTRIBUTE8  => X_ATTRIBUTE8  ,
          p_ATTRIBUTE9  => X_ATTRIBUTE9  ,
          p_ATTRIBUTE10 => X_ATTRIBUTE10  ,
          p_ATTRIBUTE11 => X_ATTRIBUTE11  ,
          p_ATTRIBUTE12 => X_ATTRIBUTE12  ,
          p_ATTRIBUTE13 => X_ATTRIBUTE13  ,
          p_ATTRIBUTE14 => X_ATTRIBUTE14  ,
          p_ATTRIBUTE15 => X_ATTRIBUTE15  ,
          p_ATTRIBUTE16 => X_ATTRIBUTE16  ,
          p_ATTRIBUTE17 => X_ATTRIBUTE17  ,
          p_ATTRIBUTE18 => X_ATTRIBUTE18  ,
          p_ATTRIBUTE19 => X_ATTRIBUTE19  ,
          p_ATTRIBUTE20 => X_ATTRIBUTE20  ,
          p_CREATION_DATE    => sysdate,
          p_CREATED_BY    => user_id,
          p_LAST_UPDATED_BY  =>  user_id,
          p_LAST_UPDATE_DATE  =>  sysdate,
          p_LAST_UPDATE_LOGIN  =>  user_id,
          p_REQUEST_ID    => fnd_global.conc_request_id,
          p_PROGRAM_APPLICATION_ID =>   fnd_global.prog_appl_id,
          p_PROGRAM_ID    => fnd_global.conc_program_id,
          p_PROGRAM_UPDATE_DATE => sysdate
        );
     --END IF;
	 /*
      exception
       when NO_DATA_FOUND then
	  */
	  Else
       OPEN C;
       FETCH C INTO lx_quote_id;
       CLOSE C;
            INSERT_ROW (
          px_QUOTE_STATUS_ID => lx_quote_id  ,
          p_STATUS_CODE   =>  X_STATUS_CODE  ,
          p_MEANING =>     X_MEANING,
          p_DESCRIPTION => X_DESCRIPTION ,
          p_UPDATE_ALLOWED_FLAG => X_UPDATE_ALLOWED_FLAG ,
          p_AUTO_VERSION_FLAG =>   X_AUTO_VERSION_FLAG ,
          p_USER_MAINTAINABLE_FLAG => X_USER_MAINTAINABLE_FLAG ,
          p_EFFECTIVE_START_DATE  => X_EFFECTIVE_START_DATE ,
          p_EFFECTIVE_END_DATE => X_EFFECTIVE_END_DATE ,
          p_ALLOW_LOV_TO_FLAG     => X_ALLOW_LOV_TO_FLAG,
          p_ALLOW_LOV_FROM_FLAG   => X_ALLOW_LOV_FROM_FLAG,
          p_ALLOW_NEW_TO_FLAG     => X_ALLOW_NEW_TO_FLAG,
          p_ALLOW_NEW_FROM_FLAG   => X_ALLOW_NEW_FROM_FLAG,
          p_SEED_TAG              => X_SEED_TAG,
          p_ENABLED_FLAG          => X_ENABLED_FLAG,
          p_ATTRIBUTE_CATEGORY   => X_ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => X_ATTRIBUTE1  ,
          p_ATTRIBUTE2  => X_ATTRIBUTE2  ,
          p_ATTRIBUTE3  => X_ATTRIBUTE3  ,
          p_ATTRIBUTE4  => X_ATTRIBUTE4  ,
          p_ATTRIBUTE5 =>  X_ATTRIBUTE5 ,
          p_ATTRIBUTE6  => X_ATTRIBUTE6  ,
          p_ATTRIBUTE7  => X_ATTRIBUTE7  ,
          p_ATTRIBUTE8  => X_ATTRIBUTE8  ,
          p_ATTRIBUTE9  => X_ATTRIBUTE9  ,
          p_ATTRIBUTE10 => X_ATTRIBUTE10  ,
          p_ATTRIBUTE11 => X_ATTRIBUTE11  ,
          p_ATTRIBUTE12 => X_ATTRIBUTE12  ,
          p_ATTRIBUTE13 => X_ATTRIBUTE13  ,
          p_ATTRIBUTE14 => X_ATTRIBUTE14  ,
          p_ATTRIBUTE15 => X_ATTRIBUTE15  ,
           p_ATTRIBUTE16 => X_ATTRIBUTE16  ,
          p_ATTRIBUTE17 => X_ATTRIBUTE17  ,
          p_ATTRIBUTE18 => X_ATTRIBUTE18  ,
          p_ATTRIBUTE19 => X_ATTRIBUTE19  ,
          p_ATTRIBUTE20 => X_ATTRIBUTE20  ,
          p_CREATION_DATE    => sysdate,
          p_CREATED_BY    => user_id,
          p_LAST_UPDATED_BY  =>  user_id,
          p_LAST_UPDATE_DATE  =>  sysdate,
          p_LAST_UPDATE_LOGIN  =>  user_id,
          p_REQUEST_ID    => fnd_global.conc_request_id,
          p_PROGRAM_APPLICATION_ID =>   fnd_global.prog_appl_id,
          p_PROGRAM_ID    => fnd_global.conc_program_id,
          p_PROGRAM_UPDATE_DATE => sysdate
           );
    end if;
    commit;
     end;
   end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_QUOTE_STATUS_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2)
IS
begin

    -- only update rows that have not been altered by user

    update ASO_QUOTE_STATUSES_TL
      set description = X_DESCRIPTION,
          meaning    = X_MEANING,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = fnd_load_util.owner_id(X_OWNER),
          last_update_login = 0
    where QUOTE_STATUS_ID = X_QUOTE_STATUS_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

PROCEDURE LOAD_SEED_ROW (
  X_UPLOAD_MODE             IN VARCHAR2,
  X_STATUS_CODE             IN VARCHAR2,
  X_MEANING                 IN VARCHAR2,
  X_DESCRIPTION             IN VARCHAR2,
  X_UPDATE_ALLOWED_FLAG     IN VARCHAR2,
  X_AUTO_VERSION_FLAG       IN VARCHAR2,
  X_USER_MAINTAINABLE_FLAG  IN VARCHAR2,
  X_EFFECTIVE_START_DATE    IN DATE,
  X_EFFECTIVE_END_DATE      IN DATE,
  X_ALLOW_LOV_TO_FLAG       IN VARCHAR2,
  X_ALLOW_LOV_FROM_FLAG     IN VARCHAR2,
  X_ALLOW_NEW_TO_FLAG       IN VARCHAR2,
  X_ALLOW_NEW_FROM_FLAG     IN VARCHAR2,
  X_SEED_TAG                IN VARCHAR2,
  X_ENABLED_FLAG            IN VARCHAR2,
  X_ATTRIBUTE_CATEGORY      IN VARCHAR2,
  X_ATTRIBUTE1              IN VARCHAR2,
  X_ATTRIBUTE2              IN VARCHAR2,
  X_ATTRIBUTE3              IN VARCHAR2,
  X_ATTRIBUTE4              IN VARCHAR2,
  X_ATTRIBUTE5              IN VARCHAR2,
  X_ATTRIBUTE6              IN VARCHAR2,
  X_ATTRIBUTE7              IN VARCHAR2,
  X_ATTRIBUTE8              IN VARCHAR2,
  X_ATTRIBUTE9              IN VARCHAR2,
  X_ATTRIBUTE10             IN VARCHAR2,
  X_ATTRIBUTE11             IN VARCHAR2,
  X_ATTRIBUTE12             IN VARCHAR2,
  X_ATTRIBUTE13             IN VARCHAR2,
  X_ATTRIBUTE14             IN VARCHAR2,
  X_ATTRIBUTE15             IN VARCHAR2,
  X_ATTRIBUTE16             IN VARCHAR2,
  X_ATTRIBUTE17             IN VARCHAR2,
  X_ATTRIBUTE18             IN VARCHAR2,
  X_ATTRIBUTE19             IN VARCHAR2,
  X_ATTRIBUTE20             IN VARCHAR2,
  X_OWNER                   IN VARCHAR2
) IS

  L_QUOTE_STATUS_ID         NUMBER(22);

  CURSOR c2 is select QUOTE_STATUS_ID
  FROM ASO_QUOTE_STATUSES_VL
  WHERE STATUS_CODE = X_STATUS_CODE ;

BEGIN

  FOR i IN c2 LOOP
    L_QUOTE_STATUS_ID := i.QUOTE_STATUS_ID;
    exit;
  END LOOP;

  IF (X_UPLOAD_MODE = 'NLS') then
    ASO_QUOTE_STATUS_PKG.TRANSLATE_ROW (
      X_QUOTE_STATUS_ID =>   L_QUOTE_STATUS_ID,
      X_MEANING =>	X_MEANING,
    	X_DESCRIPTION => X_DESCRIPTION,
  		X_OWNER => X_OWNER);

  ELSE
    ASO_QUOTE_STATUS_PKG.LOAD_ROW (
      X_MEANING =>             X_MEANING,
      X_DESCRIPTION =>             X_DESCRIPTION,
      X_STATUS_CODE =>             X_STATUS_CODE,
      X_UPDATE_ALLOWED_FLAG =>             X_UPDATE_ALLOWED_FLAG,
      X_AUTO_VERSION_FLAG =>             X_AUTO_VERSION_FLAG,
      X_USER_MAINTAINABLE_FLAG =>             X_USER_MAINTAINABLE_FLAG,
      X_EFFECTIVE_START_DATE =>             X_EFFECTIVE_START_DATE,
      X_EFFECTIVE_END_DATE =>             X_EFFECTIVE_END_DATE,
      X_ALLOW_LOV_TO_FLAG  =>	X_ALLOW_LOV_TO_FLAG,
      X_ALLOW_LOV_FROM_FLAG  =>	X_ALLOW_LOV_FROM_FLAG,
      X_ALLOW_NEW_TO_FLAG =>    	X_ALLOW_NEW_TO_FLAG,
      X_ALLOW_NEW_FROM_FLAG =>  	X_ALLOW_NEW_FROM_FLAG,
      X_SEED_TAG =>			X_SEED_TAG,
      X_ENABLED_FLAG =>  		X_ENABLED_FLAG,
      X_ATTRIBUTE_CATEGORY =>     X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1 =>             X_ATTRIBUTE1,
      X_ATTRIBUTE2 =>             X_ATTRIBUTE2,
      X_ATTRIBUTE3 =>             X_ATTRIBUTE3,
      X_ATTRIBUTE4 =>             X_ATTRIBUTE4,
      X_ATTRIBUTE5 =>             X_ATTRIBUTE5,
      X_ATTRIBUTE6 =>             X_ATTRIBUTE6,
      X_ATTRIBUTE7 =>             X_ATTRIBUTE7,
      X_ATTRIBUTE8 =>             X_ATTRIBUTE8,
      X_ATTRIBUTE9 =>             X_ATTRIBUTE9,
      X_ATTRIBUTE10 =>            X_ATTRIBUTE10,
      X_ATTRIBUTE11 =>            X_ATTRIBUTE11,
      X_ATTRIBUTE12 =>            X_ATTRIBUTE12,
      X_ATTRIBUTE13 =>            X_ATTRIBUTE13,
      X_ATTRIBUTE14 =>            X_ATTRIBUTE14,
      X_ATTRIBUTE15 =>            X_ATTRIBUTE15,
      X_ATTRIBUTE16 =>            X_ATTRIBUTE16,
      X_ATTRIBUTE17 =>            X_ATTRIBUTE17,
      X_ATTRIBUTE18 =>            X_ATTRIBUTE18,
      X_ATTRIBUTE19 =>            X_ATTRIBUTE19,
      X_ATTRIBUTE20 =>            X_ATTRIBUTE20,
      X_OWNER =>              X_OWNER);
  END IF;

END LOAD_SEED_ROW;

END ASO_QUOTE_STATUS_PKG;


/
