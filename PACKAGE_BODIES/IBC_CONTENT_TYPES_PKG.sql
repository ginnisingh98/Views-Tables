--------------------------------------------------------
--  DDL for Package Body IBC_CONTENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CONTENT_TYPES_PKG" AS
/* $Header: ibctctyb.pls 120.3 2006/06/22 09:13:00 sharma ship $*/

-- Purpose: Table Handler for Ibc_Content_Types table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX
-- vicho             11/13/2002      Added Overloaded procedures for OA UI
-- shitij.vatsa      02/11/2003      Added parameter p_subitem_version_id
--                                   to the APIs
-- vicho             07/24/03        Fixed p_encrypt_flag to type, VARCHAR2
-- Subir Anshumali   06/03/2005      Declared OUT and IN OUT arguments as references using the NOCOPY hint.

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,p_content_type_code               IN VARCHAR2
,p_content_type_status             IN VARCHAR2
,p_application_id                  IN NUMBER
,p_request_id                      IN NUMBER
,p_object_version_number           IN NUMBER
,p_content_type_name               IN VARCHAR2
,p_description                     IN VARCHAR2
,p_creation_date                   IN DATE          --DEFAULT NULL
,p_created_by                      IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2        --DEFAULT NULL
,p_OWNER_FND_USER_ID               IN  NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CONTENT_TYPES_B
    WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    ;
BEGIN
  INSERT INTO IBC_CONTENT_TYPES_B (
    CONTENT_TYPE_CODE,
    CONTENT_TYPE_STATUS,
    APPLICATION_ID,
    REQUEST_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENCRYPT_FLAG,
    OWNER_FND_USER_ID
  ) VALUES (
     p_content_type_code
    ,p_content_type_status
    ,DECODE(p_application_id,FND_API.G_MISS_NUM,NULL,p_application_id)
    ,DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,p_request_id)
    ,DECODE(p_object_version_number,FND_API.G_MISS_NUM,1,NULL,1,p_object_version_number)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,DECODE(p_encrypt_flag,FND_API.G_MISS_CHAR,NULL,'Y','T','N',NULL,p_encrypt_flag)
    ,DECODE(p_OWNER_FND_USER_ID,FND_API.G_MISS_NUM,NULL,p_OWNER_FND_USER_ID)
     );


  INSERT INTO IBC_CONTENT_TYPES_TL (
    CONTENT_TYPE_CODE,
    CONTENT_TYPE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
  LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
     p_content_type_code
    ,p_content_type_name
    ,DECODE(p_description,FND_API.G_MISS_CHAR,NULL,p_description)
    ,DECODE(p_creation_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_creation_date)
    ,DECODE(p_created_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_created_by)
    ,DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,L.LANGUAGE_CODE
    ,USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CONTENT_TYPES_TL T
    WHERE T.CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_TYPE_STATUS IN VARCHAR2,
  p_APPLICATION_ID IN NUMBER,
  p_REQUEST_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CONTENT_TYPE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2
) IS
  CURSOR c IS SELECT
      CONTENT_TYPE_STATUS,
      APPLICATION_ID,
      REQUEST_ID,
      OBJECT_VERSION_NUMBER
    FROM IBC_CONTENT_TYPES_B
    WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    FOR UPDATE OF CONTENT_TYPE_CODE NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      CONTENT_TYPE_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM IBC_CONTENT_TYPES_TL
    WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF CONTENT_TYPE_CODE NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.CONTENT_TYPE_STATUS = p_CONTENT_TYPE_STATUS)
      AND ((recinfo.APPLICATION_ID = p_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID IS NULL) AND (p_APPLICATION_ID IS NULL)))
      AND ((recinfo.REQUEST_ID = p_REQUEST_ID)
           OR ((recinfo.REQUEST_ID IS NULL) AND (p_REQUEST_ID IS NULL)))
      AND (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.CONTENT_TYPE_NAME = p_CONTENT_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION IS NULL) AND (p_DESCRIPTION IS NULL)))
      ) THEN
        NULL;
      ELSE
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      END IF;
    END IF;
  END LOOP;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
 p_content_type_code               IN VARCHAR2
,p_application_id                  IN NUMBER        --DEFAULT NULL
,p_content_type_name               IN VARCHAR2      --DEFAULT NULL
,p_content_type_status             IN VARCHAR2      --DEFAULT NULL
,p_description                     IN VARCHAR2      --DEFAULT NULL
,p_last_updated_by                 IN NUMBER        --DEFAULT NULL
,p_last_update_date                IN DATE          --DEFAULT NULL
,p_last_update_login               IN NUMBER        --DEFAULT NULL
,p_object_version_number           IN NUMBER        --DEFAULT NULL
,p_request_id                      IN NUMBER        --DEFAULT NULL
,p_encrypt_flag                    IN VARCHAR2      --DEFAULT NULL
,p_OWNER_FND_USER_ID               IN  NUMBER

) IS
BEGIN
  UPDATE IBC_CONTENT_TYPES_B SET
      content_type_status            = DECODE(p_content_type_status,FND_API.G_MISS_CHAR,NULL,NULL,content_type_status,p_content_type_status)
     ,application_id                 = DECODE(p_application_id,FND_API.G_MISS_NUM,NULL,NULL,application_id,p_application_id)
     ,request_id                     = DECODE(p_request_id,FND_API.G_MISS_NUM,NULL,NULL,request_id,p_request_id)
     ,object_version_number          = NVL(object_version_number,0) + 1
     ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
     ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
     ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
     ,encrypt_flag                   = DECODE(p_encrypt_flag,FND_API.G_MISS_CHAR,NULL,NULL,encrypt_flag,'Y','T','N',NULL,p_encrypt_flag)
     ,OWNER_FND_USER_ID              = DECODE(p_OWNER_FND_USER_ID,FND_API.G_MISS_NUM,NULL,NULL,OWNER_FND_USER_ID,p_OWNER_FND_USER_ID)
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       NULL,
                                       object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE IBC_CONTENT_TYPES_TL SET
     content_type_name              = p_content_type_name
    ,description                    = p_description
    ,last_update_date               = DECODE(p_last_update_date,FND_API.G_MISS_DATE,SYSDATE,NULL,SYSDATE,p_last_update_date)
    ,last_updated_by                = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,FND_GLOBAL.user_id,NULL,FND_GLOBAL.user_id,p_last_updated_by)
    ,last_update_login              = DECODE(p_last_update_login,FND_API.G_MISS_NUM,FND_GLOBAL.login_id,NULL,FND_GLOBAL.user_id,p_last_update_login)
    ,source_lang                    = USERENV('LANG')
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2
) IS
BEGIN
  DELETE FROM IBC_CONTENT_TYPES_TL
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_CONTENT_TYPES_B
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM IBC_CONTENT_TYPES_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM IBC_CONTENT_TYPES_B B
    WHERE B.CONTENT_TYPE_CODE = T.CONTENT_TYPE_CODE
    );

  UPDATE IBC_CONTENT_TYPES_TL T SET (
      CONTENT_TYPE_NAME,
      DESCRIPTION
    ) = (SELECT
      B.CONTENT_TYPE_NAME,
      B.DESCRIPTION
    FROM IBC_CONTENT_TYPES_TL B
    WHERE B.CONTENT_TYPE_CODE = T.CONTENT_TYPE_CODE
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.CONTENT_TYPE_CODE,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.CONTENT_TYPE_CODE,
      SUBT.LANGUAGE
    FROM IBC_CONTENT_TYPES_TL SUBB, IBC_CONTENT_TYPES_TL SUBT
    WHERE SUBB.CONTENT_TYPE_CODE = SUBT.CONTENT_TYPE_CODE
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.CONTENT_TYPE_NAME <> SUBT.CONTENT_TYPE_NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

  INSERT INTO IBC_CONTENT_TYPES_TL (
    CONTENT_TYPE_CODE,
    CONTENT_TYPE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT /*+ ORDERED */
    B.CONTENT_TYPE_CODE,
    B.CONTENT_TYPE_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM IBC_CONTENT_TYPES_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CONTENT_TYPES_TL T
    WHERE T.CONTENT_TYPE_CODE = B.CONTENT_TYPE_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_APPLICATION_ID       IN  NUMBER,
  p_CONTENT_TYPE_NAME    IN  VARCHAR2,
  p_CONTENT_TYPE_STATUS  IN  VARCHAR2,
  p_DESCRIPTION          IN  VARCHAR2,
  p_OWNER                IN  VARCHAR2,
  p_OWNER_FND_USER_ID    IN  NUMBER DEFAULT NULL,
  p_encrypt_flag         IN  VARCHAR2 DEFAULT NULL,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
 BEGIN
 	IF (p_UPLOAD_MODE = 'NLS') THEN
		IBC_CONTENT_TYPES_PKG.TRANSLATE_ROW (
		  p_UPLOAD_MODE	=> p_UPLOAD_MODE,
		  p_CONTENT_TYPE_CODE => p_CONTENT_TYPE_CODE,
		  p_CONTENT_TYPE_NAME => p_CONTENT_TYPE_NAME,
		  p_DESCRIPTION => p_DESCRIPTION,
		  p_OWNER => p_OWNER,
		  p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE);
	ELSE
		IBC_CONTENT_TYPES_PKG.LOAD_ROW (
		  p_UPLOAD_MODE	=> p_UPLOAD_MODE,
		  p_CONTENT_TYPE_CODE => p_CONTENT_TYPE_CODE,
		  p_APPLICATION_ID => p_APPLICATION_ID,
		  p_CONTENT_TYPE_NAME => p_CONTENT_TYPE_NAME,
		  p_CONTENT_TYPE_STATUS => p_CONTENT_TYPE_STATUS,
		  p_DESCRIPTION => p_DESCRIPTION,
		  p_OWNER => p_OWNER,
		  p_OWNER_FND_USER_ID => p_OWNER_FND_USER_ID,
		  p_encrypt_flag => p_encrypt_flag,
		  p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE);
	END IF;

 END LOAD_SEED_ROW;


PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE    IN VARCHAR2,
  p_APPLICATION_ID       IN NUMBER,
  p_CONTENT_TYPE_NAME    IN VARCHAR2,
  p_CONTENT_TYPE_STATUS  IN VARCHAR2,
  p_DESCRIPTION          IN VARCHAR2,
  p_OWNER                IN VARCHAR2,
  p_OWNER_FND_USER_ID    IN  NUMBER,
  p_encrypt_flag         IN VARCHAR2,       --DEFAULT NULL
  p_LAST_UPDATE_DATE IN VARCHAR2 ) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_CONTENT_TYPES_B
	WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Content_Types_Pkg.UPDATE_ROW (
                p_content_type_code            => NVL(p_content_type_code,FND_API.G_MISS_CHAR)
               ,p_application_id               => NVL(p_application_id,FND_API.G_MISS_NUM)
               ,p_content_type_name            => NVL(p_content_type_name,FND_API.G_MISS_CHAR)
               ,p_content_type_status          => NVL(p_content_type_status,FND_API.G_MISS_CHAR)
               ,p_description                  => NVL(p_description,FND_API.G_MISS_CHAR)
               ,p_last_updated_by              => l_user_id
               ,p_last_update_date             => l_last_update_date
               ,p_last_update_login            => 0
               ,p_object_version_number        => NULL
               ,p_encrypt_flag                 => NVL(p_encrypt_flag,'N')
               ,p_OWNER_FND_USER_ID            => NVL(p_OWNER_FND_USER_ID,FND_API.G_MISS_NUM)
               );
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

       Ibc_Content_Types_Pkg.INSERT_ROW (
          X_ROWID               =>      l_row_id,
          p_CONTENT_TYPE_CODE   =>      p_CONTENT_TYPE_CODE,
          p_CONTENT_TYPE_STATUS =>      p_CONTENT_TYPE_STATUS,
          p_APPLICATION_ID      =>      p_APPLICATION_ID,
          p_REQUEST_ID          =>      NULL,
          p_OBJECT_VERSION_NUMBER =>    1,
          p_CONTENT_TYPE_NAME     =>    p_CONTENT_TYPE_NAME,
          p_DESCRIPTION         =>      p_DESCRIPTION,
          p_CREATION_DATE       =>      l_last_update_date,
          p_CREATED_BY          =>      l_user_id,
          p_LAST_UPDATE_DATE    =>      l_last_update_date,
          p_LAST_UPDATED_BY     =>      l_user_id,
          p_LAST_UPDATE_LOGIN   =>      0,
          p_encrypt_flag                 => NVL(p_encrypt_flag,'N'),
          p_OWNER_FND_USER_ID          => NVL(p_OWNER_FND_USER_ID,FND_API.G_MISS_NUM)
          );
   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_TYPE_CODE  IN VARCHAR2,
  p_CONTENT_TYPE_NAME  IN VARCHAR2,
  p_DESCRIPTION     IN VARCHAR2,
  p_OWNER         IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2  ) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     VARCHAR2(64);
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_CONTENT_TYPES_TL
	WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
	AND USERENV('LANG') IN (LANGUAGE, source_lang);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN
		  -- Only update rows which have not been altered by user
		  UPDATE IBC_CONTENT_TYPES_TL
		  SET description = p_DESCRIPTION,
		      CONTENT_TYPE_NAME = p_CONTENT_TYPE_NAME,
		      source_lang = USERENV('LANG'),
		      last_update_date = l_last_update_date,
		      last_updated_by = l_user_id,
		      last_update_login = 0
		  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
		  AND USERENV('LANG') IN (LANGUAGE, source_lang);
	END IF;
   END;

END TRANSLATE_ROW;


--
-- Overloaded Procedures for OA Content Type UI
--
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_APPLICATION_ID IN NUMBER,
  X_OWNER_FND_USER_ID IN NUMBER,
  X_CONTENT_TYPE_STATUS IN VARCHAR2,
  X_REQUEST_ID IN NUMBER,
--   x_program_update_date IN DATE,
--   x_program_application_id IN NUMBER,
--   x_program_id IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CONTENT_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_CREATION_DATE IN DATE,
  X_CREATED_BY IN NUMBER,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ENCRYPT_FLAG IN VARCHAR2 --DEFAULT NULL
) IS
  CURSOR C IS SELECT ROWID FROM IBC_CONTENT_TYPES_B
    WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    ;
BEGIN
  INSERT INTO IBC_CONTENT_TYPES_B (
    APPLICATION_ID,
    OWNER_FND_USER_ID,
    CONTENT_TYPE_CODE,
    CONTENT_TYPE_STATUS,
    REQUEST_ID,
    OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENCRYPT_FLAG
  ) VALUES (
    X_APPLICATION_ID,
    X_OWNER_FND_USER_ID,
    X_CONTENT_TYPE_CODE,
    X_CONTENT_TYPE_STATUS,
    X_REQUEST_ID,
    X_OBJECT_VERSION_NUMBER,
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    decode(X_ENCRYPT_FLAG,'Y','T','N',NULL)
  );

  INSERT INTO IBC_CONTENT_TYPES_TL (
    CONTENT_TYPE_CODE,
    CONTENT_TYPE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    X_CONTENT_TYPE_CODE,
    X_CONTENT_TYPE_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_CONTENT_TYPES_TL T
    WHERE T.CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;


procedure LOCK_ROW (
  X_CONTENT_TYPE_CODE in VARCHAR2,
  X_CONTENT_TYPE_STATUS in VARCHAR2,
  X_ENCRYPT_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_OWNER_FND_USER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CONTENT_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      CONTENT_TYPE_STATUS,
      ENCRYPT_FLAG,
      APPLICATION_ID,
      REQUEST_ID,
      OWNER_FND_USER_ID,
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID
    from IBC_CONTENT_TYPES_B
    where CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    for update of CONTENT_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CONTENT_TYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IBC_CONTENT_TYPES_TL
    where CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CONTENT_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.CONTENT_TYPE_STATUS = X_CONTENT_TYPE_STATUS)
      AND ((recinfo.ENCRYPT_FLAG = X_ENCRYPT_FLAG)
           OR ((recinfo.ENCRYPT_FLAG is null) AND (X_ENCRYPT_FLAG is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.OWNER_FND_USER_ID = X_OWNER_FND_USER_ID)
           OR ((recinfo.OWNER_FND_USER_ID is null) AND (X_OWNER_FND_USER_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID IS NULL) AND (X_SECURITY_GROUP_ID IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CONTENT_TYPE_NAME = X_CONTENT_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;


PROCEDURE UPDATE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2,
  X_APPLICATION_ID IN NUMBER,
  X_OWNER_FND_USER_ID IN NUMBER,
--  x_program_update_date IN DATE,
--  x_program_application_id IN NUMBER,
--  x_program_id IN NUMBER,
  X_CONTENT_TYPE_STATUS IN VARCHAR2,
  X_REQUEST_ID IN NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_SECURITY_GROUP_ID IN NUMBER,
  X_CONTENT_TYPE_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ENCRYPT_FLAG IN VARCHAR2 --DEFAULT NULL
) IS
BEGIN
  UPDATE IBC_CONTENT_TYPES_B SET
    APPLICATION_ID = X_APPLICATION_ID,
    OWNER_FND_USER_ID = X_OWNER_FND_USER_ID,
    CONTENT_TYPE_STATUS = X_CONTENT_TYPE_STATUS,
    REQUEST_ID = X_REQUEST_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ENCRYPT_FLAG = decode(X_ENCRYPT_FLAG,'Y','T','N',NULL)
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE IBC_CONTENT_TYPES_TL SET
    CONTENT_TYPE_NAME = X_CONTENT_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = USERENV('LANG')
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  X_CONTENT_TYPE_CODE IN VARCHAR2
) IS
BEGIN
  DELETE FROM IBC_CONTENT_TYPES_TL
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_CONTENT_TYPES_B
  WHERE CONTENT_TYPE_CODE = X_CONTENT_TYPE_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


PROCEDURE COPY_ROW(P_content_type_code IN VARCHAR2)
IS
CURSOR cur_content_types IS
SELECT CONTENT_TYPE_CODE,
           CONTENT_TYPE_STATUS,
           APPLICATION_ID,
           CONTENT_TYPE_NAME,
           OWNER_FND_USER_ID,
           DESCRIPTION,
           DECODE(LAST_UPDATED_BY, 1, 'SEED', 'CUSTOM') OWNER
FROM   IBC_CONTENT_TYPES_VL
WHERE  CONTENT_TYPE_CODE  = p_CONTENT_TYPE_CODE;

CURSOR CUR_ATTRIBUTE_TYPES IS
SELECT  ATTRIBUTE_TYPE_CODE,
        UPDATEABLE_FLAG,
        DATA_TYPE_CODE,
        DATA_LENGTH,
        MIN_INSTANCES,
        MAX_INSTANCES,
                FLEX_VALUE_SET_ID,
                DISPLAY_ORDER,
        REFERENCE_CODE,
        DEFAULT_VALUE,
        ATTRIBUTE_TYPE_NAME,
        DESCRIPTION,
        DECODE(LAST_UPDATED_BY, 1, 'SEED', 'CUSTOM') OWNER
FROM IBC_ATTRIBUTE_TYPES_VL
WHERE  CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE;

CURSOR CUR_STYLESHEET IS
SELECT  content_item_id,
        default_stylesheet_flag,
        DECODE(LAST_UPDATED_BY, 1, 'SEED', 'CUSTOM') OWNER
        FROM IBC_STYLESHEETS
        WHERE  CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE;

l_content_type_Code VARCHAR2(100) := 'Copy Of ' || p_content_type_code;
l_row_id     VARCHAR2(64);

BEGIN

--dbms_output.Put_Line(l_content_type_Code);


FOR i_rec IN CUR_content_types
LOOP

       Ibc_Content_Types_Pkg.Insert_Row (
          X_ROWID                       =>      l_row_id,
          X_CONTENT_TYPE_CODE           =>      l_CONTENT_TYPE_CODE,
          X_CONTENT_TYPE_STATUS         =>      i_rec.CONTENT_TYPE_STATUS,
          X_APPLICATION_ID              =>      i_rec.APPLICATION_ID,
          X_OWNER_FND_USER_ID           =>      Fnd_Global.user_id,
          X_REQUEST_ID                  =>      NULL,
          X_OBJECT_VERSION_NUMBER       =>      1,
          X_CONTENT_TYPE_NAME           =>      'Copy Of ' || i_rec.CONTENT_TYPE_NAME,
          X_DESCRIPTION                 =>      i_rec.DESCRIPTION,
          X_CREATION_DATE               =>      SYSDATE,
          X_CREATED_BY                  =>      Fnd_Global.user_id,
          X_LAST_UPDATE_DATE            =>      SYSDATE,
          X_LAST_UPDATED_BY             =>      Fnd_Global.user_id,
          X_LAST_UPDATE_LOGIN           =>      Fnd_Global.login_id,
--                x_program_update_date   => NULL,
--                x_program_application_id =>NULL,
--                x_program_id                     => NULL,
          X_SECURITY_GROUP_ID           =>      NULL);

END LOOP;


FOR i_rec IN CUR_ATTRIBUTE_TYPES
LOOP
Ibc_Attribute_Types_Pkg.Insert_Row (
  X_ROWID                       => l_ROW_ID
  ,X_CONTENT_TYPE_CODE          => L_CONTENT_TYPE_CODE
  ,X_ATTRIBUTE_TYPE_CODE        => i_rec.ATTRIBUTE_TYPE_CODE
  ,X_UPDATEABLE_FLAG            => i_rec.UPDATEABLE_FLAG
  ,X_REFERENCE_CODE             => i_rec.REFERENCE_CODE
  ,X_FLEX_VALUE_SET_ID          => i_rec.FLEX_VALUE_SET_ID
  ,X_DISPLAY_ORDER              => i_rec.DISPLAY_ORDER
  ,X_MIN_INSTANCES              => i_rec.MIN_INSTANCES
  ,X_MAX_INSTANCES              => i_rec.MAX_INSTANCES
  ,X_DEFAULT_VALUE              => i_rec.DEFAULT_VALUE
  ,X_DATA_LENGTH                => i_rec.DATA_LENGTH
  ,X_DATA_TYPE_CODE             => i_rec.DATA_TYPE_CODE
  ,X_OBJECT_VERSION_NUMBER      => 1
  ,X_SECURITY_GROUP_ID          => NULL
  ,X_ATTRIBUTE_TYPE_NAME        => i_rec.ATTRIBUTE_TYPE_NAME
  ,X_DESCRIPTION                => i_rec.DESCRIPTION
  ,X_CREATION_DATE              => SYSDATE
  ,X_CREATED_BY                 => Fnd_Global.user_id
  ,X_LAST_UPDATE_DATE           => SYSDATE
  ,X_LAST_UPDATED_BY            => Fnd_Global.user_id
  ,X_LAST_UPDATE_LOGIN          => Fnd_Global.login_id);
END LOOP;


END;

PROCEDURE Sync_Content_types(p_new_content_type_code IN VARCHAR2
                                                        ,p_old_content_type_code IN VARCHAR2)
IS
BEGIN

UPDATE ibc_content_types_b
SET content_type_code=p_new_content_type_code
WHERE content_type_code = p_old_content_type_code;

UPDATE ibc_content_types_tl
SET content_type_code=p_new_content_type_code
WHERE content_type_code = p_old_content_type_code;

UPDATE ibc_attribute_types_b
SET content_type_code=p_new_content_type_code
WHERE content_type_code = p_old_content_type_code;

UPDATE ibc_attribute_types_tl
SET content_type_code=p_new_content_type_code
WHERE content_type_code = p_old_content_type_code;


COMMIT;

END;


END Ibc_Content_Types_Pkg;

/
