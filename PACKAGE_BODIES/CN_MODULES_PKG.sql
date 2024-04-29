--------------------------------------------------------
--  DDL for Package Body CN_MODULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MODULES_PKG" AS
-- $Header: cnsymodb.pls 120.6.12010000.2 2008/10/10 07:19:37 rajukum ship $

-- Procedure Name
--   sync_module
-- Purpose
--   Generate a module for a Commissions function.
-- History
--   06-05-95	Amy Erickson	Created
--

-- This Procedure Is Not Used Now,
-- We Can Remove This Procedure

-- Local Variable

	l_org_id NUMBER;

  PROCEDURE sync_module (
	    x_module_id 	    NUMBER,
	    x_module_status IN OUT NOCOPY  VARCHAR2) IS


    x_module_type	cn_modules.module_type%TYPE;
    x_rc		BOOLEAN;
    x_temp_id		cn_modules.module_id%TYPE;

  BEGIN

   SELECT module_type, module_status
     INTO x_module_type, x_module_status
     FROM cn_modules
    WHERE module_id = x_module_id ;

  END sync_module;


-- Procedure Name
--   unsync_module
-- Purpose
--   Mark a module status as UNSYNC.
-- History
--

-- This Procedure Is Not Used Now,
-- We Can Remove This Procedure

  PROCEDURE unsync_module (
	    x_module_id 	    NUMBER,
	    x_module_status IN OUT NOCOPY  VARCHAR2,
	    x_org_id IN NUMBER) IS


  BEGIN

  l_org_id := x_org_id;

  x_module_status := 'UNSYNC' ;

     update_row(x_module_id     => x_module_id,
				x_module_status => x_module_status,
				x_org_id => l_org_id);

  END unsync_module;

  PROCEDURE INSERT_ROW (
			X_ROWID IN OUT nocopy VARCHAR2,
			X_MODULE_ID IN NUMBER,
			X_MODULE_TYPE IN VARCHAR2,
			X_REPOSITORY_ID IN NUMBER,
			X_DESCRIPTION IN VARCHAR2,
			X_PARENT_MODULE_ID IN NUMBER,
			X_SOURCE_REPOSITORY_ID IN NUMBER,
			X_MODULE_STATUS IN VARCHAR2,
			X_EVENT_ID IN NUMBER,
			X_LAST_MODIFICATION IN DATE,
			X_LAST_SYNCHRONIZATION IN DATE,
			X_OUTPUT_FILENAME IN VARCHAR2,
			X_COLLECT_FLAG IN VARCHAR2,
			X_NAME IN VARCHAR2,
			X_CREATION_DATE IN DATE,
			X_CREATED_BY IN NUMBER,
			X_LAST_UPDATE_DATE IN DATE,
			X_LAST_UPDATED_BY IN NUMBER,
			X_LAST_UPDATE_LOGIN IN NUMBER,
            X_ORG_ID IN NUMBER) IS  -- Modified For R12 MOAC

  CURSOR C IS SELECT ROWID FROM CN_MODULES_ALL_B
  WHERE MODULE_ID = x_module_id;

  BEGIN
     INSERT INTO CN_MODULES_ALL_B(
	MODULE_ID,
        MODULE_TYPE,
        REPOSITORY_ID,
        DESCRIPTION,
        PARENT_MODULE_ID,
        SOURCE_REPOSITORY_ID,
        MODULE_STATUS,
        EVENT_ID,
        LAST_MODIFICATION,
        LAST_SYNCHRONIZATION,
        OUTPUT_FILENAME,
        COLLECT_FLAG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        ORG_ID  -- Modified For R12 MOAC
        ) VALUES (
	X_MODULE_ID,
	X_MODULE_TYPE,
	X_REPOSITORY_ID,
	X_DESCRIPTION,
	X_PARENT_MODULE_ID,
	X_SOURCE_REPOSITORY_ID,
	X_MODULE_STATUS,
	X_EVENT_ID,
	X_LAST_MODIFICATION,
	X_LAST_SYNCHRONIZATION,
	X_OUTPUT_FILENAME,
	X_COLLECT_FLAG,
	X_CREATION_DATE,
	X_CREATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_LOGIN,
    X_ORG_ID    -- Modified For R12 MOAC
	);

  INSERT INTO CN_MODULES_ALL_TL (
    MODULE_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) SELECT
    X_MODULE_ID,
    X_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_ORG_ID
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM CN_MODULES_ALL_TL T
    WHERE T.MODULE_ID = X_MODULE_ID
     AND T.LANGUAGE = L.language_code
     AND T.ORG_ID = X_ORG_ID
    );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

-- This Procedure Is Not Used Now,
-- We Can Remove This Procedure

PROCEDURE LOCK_ROW (
  X_MODULE_ID IN NUMBER,
  X_MODULE_TYPE IN VARCHAR2,
  X_REPOSITORY_ID IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_PARENT_MODULE_ID IN NUMBER,
  X_SOURCE_REPOSITORY_ID IN NUMBER,
  X_MODULE_STATUS IN VARCHAR2,
  X_EVENT_ID IN NUMBER,
  X_LAST_MODIFICATION IN DATE,
  X_LAST_SYNCHRONIZATION IN DATE,
  X_OUTPUT_FILENAME IN VARCHAR2,
  X_COLLECT_FLAG IN VARCHAR2,
  X_NAME IN VARCHAR2,
  X_ORG_ID IN NUMBER
) IS
  CURSOR c IS SELECT
      MODULE_TYPE,
      REPOSITORY_ID,
      DESCRIPTION,
      PARENT_MODULE_ID,
      SOURCE_REPOSITORY_ID,
      MODULE_STATUS,
      EVENT_ID,
      LAST_MODIFICATION,
      LAST_SYNCHRONIZATION,
      OUTPUT_FILENAME,
      COLLECT_FLAG
    FROM CN_MODULES_ALL_B
    WHERE MODULE_ID = x_module_id AND
    ORG_ID = X_ORG_ID
    FOR UPDATE OF MODULE_ID NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    FROM CN_MODULES_ALL_TL
    WHERE MODULE_ID = x_module_id AND
    ORG_ID = X_ORG_ID
    AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF MODULE_ID NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.MODULE_TYPE = X_MODULE_TYPE)
      AND (recinfo.REPOSITORY_ID = X_REPOSITORY_ID)
      AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL)))
      AND ((recinfo.PARENT_MODULE_ID = X_PARENT_MODULE_ID)
           OR ((recinfo.PARENT_MODULE_ID IS NULL) AND (X_PARENT_MODULE_ID IS NULL)))
      AND ((recinfo.SOURCE_REPOSITORY_ID = X_SOURCE_REPOSITORY_ID)
           OR ((recinfo.SOURCE_REPOSITORY_ID IS NULL) AND (X_SOURCE_REPOSITORY_ID IS NULL)))
      AND (recinfo.MODULE_STATUS = X_MODULE_STATUS)
      AND ((recinfo.EVENT_ID = X_EVENT_ID)
           OR ((recinfo.EVENT_ID IS NULL) AND (X_EVENT_ID IS NULL)))
      AND ((recinfo.LAST_MODIFICATION = X_LAST_MODIFICATION)
           OR ((recinfo.LAST_MODIFICATION IS NULL) AND (X_LAST_MODIFICATION IS NULL)))
      AND ((recinfo.LAST_SYNCHRONIZATION = X_LAST_SYNCHRONIZATION)
           OR ((recinfo.LAST_SYNCHRONIZATION IS NULL) AND (X_LAST_SYNCHRONIZATION IS NULL)))
      AND ((recinfo.OUTPUT_FILENAME = X_OUTPUT_FILENAME)
           OR ((recinfo.OUTPUT_FILENAME IS NULL) AND (X_OUTPUT_FILENAME IS NULL)))
      AND ((recinfo.COLLECT_FLAG = X_COLLECT_FLAG)
           OR ((recinfo.COLLECT_FLAG IS NULL) AND (X_COLLECT_FLAG IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.NAME = X_NAME)
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
  X_MODULE_ID IN NUMBER,
  X_MODULE_TYPE IN VARCHAR2,
  X_REPOSITORY_ID IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_PARENT_MODULE_ID IN NUMBER,
  X_SOURCE_REPOSITORY_ID IN NUMBER,
  X_MODULE_STATUS IN VARCHAR2,
  X_EVENT_ID IN NUMBER,
  X_LAST_MODIFICATION IN DATE,
  X_LAST_SYNCHRONIZATION IN DATE,
  X_OUTPUT_FILENAME IN VARCHAR2,
  X_COLLECT_FLAG IN VARCHAR2,
  X_NAME IN VARCHAR2,
  X_LAST_UPDATE_DATE IN DATE,
  X_LAST_UPDATED_BY IN NUMBER,
  X_LAST_UPDATE_LOGIN IN NUMBER,
  X_ORG_ID  IN NUMBER
) IS

   CURSOR cur_b IS
      SELECT *
	FROM cn_modules_all_b
	WHERE module_id = x_module_id AND
    org_id = X_ORG_ID;

   CURSOR cur_tl IS
      SELECT NAME, last_update_date, last_updated_by,last_update_login
	FROM cn_modules_all_tl
	WHERE module_id = x_module_id AND
	userenv('LANG') IN (LANGUAGE, SOURCE_LANG) AND
    org_id = X_ORG_ID;

   rec_b  cur_b%ROWTYPE;
   rec_tl cur_tl%ROWTYPE;

BEGIN

   OPEN cur_b;

   FETCH cur_b INTO rec_b;

   IF (cur_b%NOTFOUND) THEN
      CLOSE cur_b;
      RAISE no_data_found;

    ELSE

      SELECT Decode(X_MODULE_ID, FND_API.G_MISS_NUM, rec_b.module_id,
		    Ltrim(Rtrim(X_MODULE_ID)))
	INTO rec_b.module_id FROM sys.dual;

      SELECT Decode(X_MODULE_TYPE, FND_API.G_MISS_CHAR, rec_b.MODULE_TYPE,
		    Ltrim(Rtrim(X_MODULE_TYPE)))
	INTO rec_b.MODULE_TYPE FROM sys.dual;

      SELECT Decode(X_REPOSITORY_ID, FND_API.G_MISS_NUM, rec_b.REPOSITORY_ID,
		    Ltrim(Rtrim(X_REPOSITORY_ID)))
	INTO rec_b.REPOSITORY_ID FROM sys.dual;

      SELECT Decode(X_DESCRIPTION, FND_API.G_MISS_CHAR, rec_b.DESCRIPTION,
		    Ltrim(Rtrim(X_DESCRIPTION)))
	INTO rec_b.DESCRIPTION FROM sys.dual;

      SELECT Decode(X_PARENT_MODULE_ID, FND_API.G_MISS_NUM, rec_b.PARENT_MODULE_ID,
		    Ltrim(Rtrim(X_PARENT_MODULE_ID)))
	INTO rec_b.PARENT_MODULE_ID FROM sys.dual;

      SELECT Decode(X_SOURCE_REPOSITORY_ID, FND_API.G_MISS_NUM, rec_b.SOURCE_REPOSITORY_ID,Ltrim(Rtrim(X_SOURCE_REPOSITORY_ID)))
	INTO rec_b.SOURCE_REPOSITORY_ID FROM sys.dual;

      SELECT Decode(X_MODULE_STATUS, FND_API.G_MISS_CHAR, rec_b.MODULE_STATUS,
		    Ltrim(Rtrim(X_MODULE_STATUS)))
	INTO rec_b.MODULE_STATUS FROM sys.dual;

      SELECT Decode(X_EVENT_ID, FND_API.G_MISS_NUM, rec_b.EVENT_ID,
		    Ltrim(Rtrim(X_EVENT_ID)))
	INTO rec_b.EVENT_ID FROM sys.dual;

      SELECT Decode(X_LAST_MODIFICATION, FND_API.G_MISS_DATE, rec_b.LAST_MODIFICATION,
		    Ltrim(Rtrim(X_LAST_MODIFICATION)))
	INTO rec_b.LAST_MODIFICATION FROM sys.dual;

      SELECT Decode(X_LAST_SYNCHRONIZATION, FND_API.G_MISS_DATE, rec_b.LAST_SYNCHRONIZATION,
		    Ltrim(Rtrim(X_LAST_SYNCHRONIZATION)))
	INTO rec_b.LAST_SYNCHRONIZATION FROM sys.dual;

      SELECT Decode(X_OUTPUT_FILENAME, FND_API.G_MISS_CHAR, rec_b.OUTPUT_FILENAME,
		    Ltrim(Rtrim(X_OUTPUT_FILENAME)))
	INTO rec_b.OUTPUT_FILENAME FROM sys.dual;

      SELECT Decode(X_COLLECT_FLAG, FND_API.G_MISS_CHAR, rec_b.COLLECT_FLAG,
		    Ltrim(Rtrim(X_COLLECT_FLAG)))
	INTO rec_b.COLLECT_FLAG FROM sys.dual;


      SELECT Decode(X_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, rec_b.LAST_UPDATE_DATE,
		    Ltrim(Rtrim(X_LAST_UPDATE_DATE)))
	INTO rec_b.LAST_UPDATE_DATE FROM sys.dual;

      SELECT Decode(X_LAST_UPDATED_BY, FND_API.G_MISS_NUM, rec_b.LAST_UPDATED_BY,
		    Ltrim(Rtrim(X_LAST_UPDATED_BY)))
	INTO rec_b.last_updated_by FROM sys.dual;

      SELECT Decode(X_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, rec_b.LAST_UPDATE_LOGIN,
		    Ltrim(Rtrim(X_LAST_UPDATE_LOGIN)))
	INTO rec_b.last_update_login FROM sys.dual;

      UPDATE CN_MODULES_ALL_B SET
	MODULE_TYPE = rec_b.MODULE_TYPE,
	REPOSITORY_ID = rec_b.REPOSITORY_ID,
	DESCRIPTION = rec_b.DESCRIPTION,
	PARENT_MODULE_ID = rec_b.PARENT_MODULE_ID,
	SOURCE_REPOSITORY_ID = rec_b.SOURCE_REPOSITORY_ID,
	MODULE_STATUS = rec_b.MODULE_STATUS,
	EVENT_ID = rec_b.EVENT_ID,
	LAST_MODIFICATION = rec_b.LAST_MODIFICATION,
	LAST_SYNCHRONIZATION = rec_b.LAST_SYNCHRONIZATION,
	OUTPUT_FILENAME = rec_b.OUTPUT_FILENAME,
	COLLECT_FLAG = rec_b.COLLECT_FLAG,
	LAST_UPDATE_DATE = rec_b.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = rec_b.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = rec_b.LAST_UPDATE_LOGIN
	WHERE MODULE_ID = rec_b.module_id
	AND
    org_id = X_ORG_ID;

      IF (SQL%NOTFOUND) THEN
	 CLOSE cur_b;
	 RAISE no_data_found;
      END IF;

   END IF;
   CLOSE cur_b;

   OPEN cur_tl;

   FETCH cur_tl INTO rec_tl;

   IF (cur_tl%NOTFOUND) THEN
      CLOSE cur_tl;
      RAISE no_data_found;

    ELSE

      SELECT Decode(X_NAME, FND_API.G_MISS_CHAR, rec_tl.NAME,
		    Ltrim(Rtrim(X_NAME)))
	INTO rec_tl.NAME FROM sys.dual;

      SELECT Decode(X_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, rec_tl.LAST_UPDATE_DATE,
		    Ltrim(Rtrim(X_LAST_UPDATE_DATE)))
	INTO rec_tl.LAST_UPDATE_DATE FROM sys.dual;

      SELECT Decode(X_LAST_UPDATED_BY, FND_API.G_MISS_NUM, rec_tl.LAST_UPDATED_BY,
		    Ltrim(Rtrim(X_LAST_UPDATED_BY)))
	INTO rec_tl.last_updated_by FROM sys.dual;

      SELECT Decode(X_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, rec_tl.LAST_UPDATE_LOGIN,
		    Ltrim(Rtrim(X_LAST_UPDATE_LOGIN)))
	INTO rec_tl.last_update_login FROM sys.dual;

      UPDATE CN_MODULES_ALL_TL SET
	NAME = rec_tl.NAME,
	LAST_UPDATE_DATE = rec_tl.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = rec_tl.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = rec_tl.LAST_UPDATE_LOGIN,
	SOURCE_LANG = userenv('LANG')
	WHERE MODULE_ID = x_module_id AND
	userenv('LANG') IN (LANGUAGE, SOURCE_LANG) AND
    org_id = X_ORG_ID;

      IF (SQL%NOTFOUND) THEN
	 CLOSE cur_tl;
	 RAISE no_data_found;
      END IF;

   END IF;
   CLOSE cur_tl;

EXCEPTION
   WHEN no_data_found THEN
      RAISE no_data_found;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
    X_MODULE_ID IN NUMBER,
    X_ORG_ID IN NUMBER
) IS
BEGIN
  DELETE FROM CN_MODULES_ALL_TL
    WHERE MODULE_ID = x_module_id AND
    ORG_ID = X_ORG_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;

  DELETE FROM CN_MODULES_ALL_B
    WHERE MODULE_ID = x_module_id AND
    ORG_ID = X_ORG_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE no_data_found;
  END IF;
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM CN_MODULES_ALL_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM CN_MODULES_ALL_B B
     WHERE B.MODULE_ID = T.module_id
    AND    B.org_id = T.org_id);

  UPDATE CN_MODULES_ALL_TL T SET (
      NAME
    ) = (SELECT
      B.NAME
    FROM CN_MODULES_ALL_TL B
    WHERE B.MODULE_ID = T.MODULE_ID
    AND B.LANGUAGE = T.source_lang
    AND B.org_id = T.org_id)
  WHERE (
      T.MODULE_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.MODULE_ID,
      SUBT.LANGUAGE
    FROM CN_MODULES_ALL_TL SUBB, CN_MODULES_ALL_TL SUBT
    WHERE SUBB.MODULE_ID = SUBT.MODULE_ID
    AND SUBB.LANGUAGE = SUBT.source_lang
    AND SUBB.ORG_ID = SUBT.ORG_ID
    AND (SUBB.NAME <> SUBT.NAME
      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
  ));

  INSERT INTO CN_MODULES_ALL_TL (
    ORG_ID,
    MODULE_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    B.ORG_ID,
    B.MODULE_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM CN_MODULES_ALL_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = userenv('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM CN_MODULES_ALL_TL T
    WHERE T.MODULE_ID = B.MODULE_ID
    AND T.LANGUAGE = L.language_code
    AND T.ORG_ID = B.ORG_ID);
END ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE  LOAD_ROW
    (x_module_id IN NUMBER,
     x_name IN VARCHAR2,
     x_description IN VARCHAR2,
     x_module_type IN VARCHAR2,
     x_module_status IN VARCHAR2,
     x_event_id IN NUMBER,
     x_repository_id IN NUMBER,
     x_parent_module_id IN NUMBER,
     x_source_repository_id IN NUMBER,
     x_last_modification IN DATE,
     x_last_synchronization IN DATE,
     x_output_filename IN VARCHAR2,
     x_collect_flag IN VARCHAR2,
     x_org_id IN NUMBER,
     x_owner IN VARCHAR2) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_module_id IS NULL)
     OR  (x_name IS NULL) OR (x_module_type  IS NULL)
       OR (x_repository_id IS NULL) OR (x_module_status IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE  CN_MODULES_ALL_B SET
     DESCRIPTION = X_DESCRIPTION,
     MODULE_TYPE = X_MODULE_TYPE,
     MODULE_STATUS = X_MODULE_STATUS,
     EVENT_ID = X_EVENT_ID,
     REPOSITORY_ID = X_REPOSITORY_ID,
     PARENT_MODULE_ID = X_PARENT_MODULE_ID,
     SOURCE_REPOSITORY_ID = X_SOURCE_REPOSITORY_ID,
     LAST_MODIFICATION = X_LAST_MODIFICATION,
     LAST_SYNCHRONIZATION = X_LAST_SYNCHRONIZATION,
     OUTPUT_FILENAME = X_OUTPUT_FILENAME,
     COLLECT_FLAG = X_COLLECT_FLAG,
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = user_id,
     LAST_UPDATE_LOGIN = 0
     WHERE MODULE_ID = x_module_id
     AND org_id = x_org_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_modules_all_b
	(MODULE_ID,
	 DESCRIPTION,
	 MODULE_TYPE,
	 MODULE_STATUS,
	 EVENT_ID,
	 REPOSITORY_ID,
	 PARENT_MODULE_ID,
	 SOURCE_REPOSITORY_ID,
	 LAST_MODIFICATION,
	 LAST_SYNCHRONIZATION,
	 OUTPUT_FILENAME,
	 COLLECT_FLAG,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	LAST_UPDATE_login,
	org_id
	 ) VALUES
	(X_MODULE_ID,
	 X_DESCRIPTION,
	 X_MODULE_TYPE,
	 X_MODULE_STATUS,
	 X_EVENT_ID,
	 X_REPOSITORY_ID,
	 X_PARENT_MODULE_ID,
	 X_SOURCE_REPOSITORY_ID,
	 X_LAST_MODIFICATION,
	 X_LAST_SYNCHRONIZATION,
	 X_OUTPUT_FILENAME,
	 X_COLLECT_FLAG,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	0,
	x_org_id
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE  CN_MODULES_ALL_TL SET
     NAME = X_NAME,
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = user_id,
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
     WHERE  MODULE_ID = x_module_id
     AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG)
     AND org_id = x_org_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT  INTO CN_MODULES_ALL_TL
	(MODULE_ID,
	 NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 CREATION_DATE,
	 CREATED_BY,
         org_id,
	 LANGUAGE,
	 SOURCE_LANG
	 ) SELECT
	X_MODULE_ID,
	X_NAME,
	sysdate,
	user_id,
	0,
	sysdate,
	user_id,
        x_org_id,
	L.LANGUAGE_CODE,
	userenv('LANG')
	FROM FND_LANGUAGES L
	WHERE L.INSTALLED_FLAG IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM CN_MODULES_ALL_TL T
	 WHERE T.MODULE_ID = X_MODULE_ID
	 AND T.LANGUAGE = L.LANGUAGE_CODE);
   END IF;
   << end_load_row >>
     NULL;
END  LOAD_ROW ;

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE TRANSLATE_ROW
  ( x_module_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_module_id IS NULL) OR  (x_name IS NULL)  THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_modules_all_tl SET
     NAME = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE module_id = x_module_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END cn_modules_pkg;

/
