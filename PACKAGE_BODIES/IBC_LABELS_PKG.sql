--------------------------------------------------------
--  DDL for Package Body IBC_LABELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_LABELS_PKG" AS
/* $Header: ibctlabb.pls 120.2 2006/05/24 12:21:34 sharma ship $*/

-- Purpose: Table Handler for Ibc_Labels table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW
-- Sharma	     07/04/2005     Modified LOAD_ROW and created
--				    LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  p_LABEL_CODE IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_LABEL_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_LABELS_B
    WHERE LABEL_CODE = p_LABEL_CODE
    ;
BEGIN
  INSERT INTO IBC_LABELS_B (
    LABEL_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    p_LABEL_CODE,
    p_OBJECT_VERSION_NUMBER,
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
 );

  INSERT INTO IBC_LABELS_TL (
    LABEL_CODE,
    LABEL_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
	LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    p_LABEL_CODE,
    p_LABEL_NAME,
    DECODE(p_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,p_DESCRIPTION),
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date) ,
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login),
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_LABELS_TL T
    WHERE T.LABEL_CODE = p_LABEL_CODE
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
  p_LABEL_CODE IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_LABEL_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_LABELS_B
    WHERE LABEL_CODE = p_LABEL_CODE
    FOR UPDATE OF LABEL_CODE NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      LABEL_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM IBC_LABELS_TL
    WHERE LABEL_CODE = p_LABEL_CODE
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF LABEL_CODE NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.LABEL_NAME = p_LABEL_NAME)
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
  p_LABEL_CODE		IN  VARCHAR2,
  p_DESCRIPTION		IN  VARCHAR2,
  p_LABEL_NAME		IN  VARCHAR2,
  p_LAST_UPDATED_BY	IN  NUMBER,
  p_LAST_UPDATE_DATE    IN  DATE,
  p_LAST_UPDATE_LOGIN   IN  NUMBER,
  p_OBJECT_VERSION_NUMBER    IN  NUMBER
) IS
BEGIN
  UPDATE IBC_LABELS_B SET
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE LABEL_CODE = p_LABEL_CODE
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,object_version_number,
                                       NULL,object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE IBC_LABELS_TL SET
    LABEL_NAME = DECODE(p_LABEL_NAME,FND_API.G_MISS_CHAR,NULL,NULL,LABEL_NAME,p_LABEL_NAME),
    DESCRIPTION = DECODE(p_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,NULL,DESCRIPTION,p_DESCRIPTION),
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login),
    SOURCE_LANG = USERENV('LANG')
  WHERE LABEL_CODE = p_LABEL_CODE
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_LABEL_CODE IN VARCHAR2
) IS
BEGIN
  DELETE FROM IBC_LABELS_TL
  WHERE LABEL_CODE = p_LABEL_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_LABELS_B
  WHERE LABEL_CODE = p_LABEL_CODE;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM IBC_LABELS_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM IBC_LABELS_B B
    WHERE B.LABEL_CODE = T.LABEL_CODE
    );

  UPDATE IBC_LABELS_TL T SET (
      LABEL_NAME,
      DESCRIPTION
    ) = (SELECT
      B.LABEL_NAME,
      B.DESCRIPTION
    FROM IBC_LABELS_TL B
    WHERE B.LABEL_CODE = T.LABEL_CODE
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.LABEL_CODE,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.LABEL_CODE,
      SUBT.LANGUAGE
    FROM IBC_LABELS_TL SUBB, IBC_LABELS_TL SUBT
    WHERE SUBB.LABEL_CODE = SUBT.LABEL_CODE
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.LABEL_NAME <> SUBT.LABEL_NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

  INSERT INTO IBC_LABELS_TL (
    LABEL_CODE,
    LABEL_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT /*+ ORDERED */
    B.LABEL_CODE,
    B.LABEL_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM IBC_LABELS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_LABELS_TL T
    WHERE T.LABEL_CODE = B.LABEL_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


PROCEDURE LOAD_ROW (
  p_upload_mode	IN VARCHAR2,
  p_label_CODE    IN  VARCHAR2,
  p_label_NAME    IN  VARCHAR2,
  p_DESCRIPTION    IN  VARCHAR2,
  p_OWNER IN VARCHAR2,
  p_last_update_date IN VARCHAR2) IS
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

	Ibc_Labels_Pkg.Update_row (
	 p_Label_CODE		  =>	p_Label_CODE,
	 p_Label_NAME		  =>	nvl(p_Label_NAME,FND_API.G_MISS_CHAR),
	 p_DESCRIPTION		  =>	nvl(p_DESCRIPTION,FND_API.G_MISS_CHAR),
	 p_LAST_UPDATED_BY	  =>	l_user_id,
	 p_LAST_UPDATE_DATE	  =>	sysdate,
	 p_LAST_UPDATE_LOGIN =>	0,
	 p_OBJECT_VERSION_NUMBER => NULL);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN

	   Ibc_Labels_Pkg.insert_row (
       	   x_rowid			 => l_row_id,
           p_Label_CODE	 	 	 =>	p_Label_CODE,
           p_Label_NAME		 	 =>	p_Label_NAME,
           p_CREATED_BY		 	 =>	l_user_id,
           p_CREATION_DATE	 	 =>	SYSDATE,
           p_DESCRIPTION	 	 =>	p_DESCRIPTION,
           p_LAST_UPDATED_BY	 =>	l_user_id,
           p_LAST_UPDATE_DATE	 =>	SYSDATE,
           p_LAST_UPDATE_LOGIN	 =>	0,
           p_OBJECT_VERSION_NUMBER	=>	1);
   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_upload_mode	IN VARCHAR2,
  p_LABEL_CODE	IN VARCHAR2,
  p_LABEL_NAME	IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_OWNER 	IN VARCHAR2,
  p_last_update_date IN VARCHAR2) IS
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


	  -- Only update rows which have not been altered by user
	  UPDATE IBC_LABELS_TL
	  SET description = p_DESCRIPTION,
	      LABEL_NAME = p_LABEL_NAME,
	      source_lang = USERENV('LANG'),
	      last_update_date = sysdate,
	      last_updated_by = l_user_id,
	      last_update_login = 0
	  WHERE LABEL_CODE = p_LABEL_CODE
	    AND USERENV('LANG') IN (LANGUAGE, source_lang);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
   END;


END TRANSLATE_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_upload_mode	  VARCHAR2,
  p_label_CODE    IN  VARCHAR2,
  p_label_NAME    IN  VARCHAR2,
  p_DESCRIPTION    IN  VARCHAR2,
  p_OWNER IN VARCHAR2,
  p_last_update_date VARCHAR2) IS

BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		IBC_LABELS_PKG.TRANSLATE_ROW (
		p_upload_mode	 => p_upload_mode,
		p_LABEL_CODE	=>	p_LABEL_CODE,
		p_LABEL_NAME	=>	p_LABEL_NAME,
		p_DESCRIPTION	=>	p_DESCRIPTION,
		p_OWNER		=>p_OWNER,
		p_last_update_date => p_LAST_UPDATE_DATE);
	ELSE
		IBC_LABELS_PKG.LOAD_ROW (
		p_upload_mode	 => p_upload_mode,
		p_LABEL_CODE	=>	p_LABEL_CODE,
		p_LABEL_NAME	=>	p_LABEL_NAME,
		p_DESCRIPTION	=>	p_DESCRIPTION,
		p_OWNER		=>p_OWNER,
		p_last_update_date => p_LAST_UPDATE_DATE);
	END IF;
END LOAD_SEED_ROW;


--

END Ibc_Labels_Pkg;

/
