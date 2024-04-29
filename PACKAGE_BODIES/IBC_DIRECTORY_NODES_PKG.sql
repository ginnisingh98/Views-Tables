--------------------------------------------------------
--  DDL for Package Body IBC_DIRECTORY_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_DIRECTORY_NODES_PKG" AS
/* $Header: ibctdndb.pls 120.4 2006/06/22 09:30:08 sharma ship $*/

-- Purpose: Table Handler for Ibc_Directory_Nodes table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho	     11/04/2002      Remove G_MISS defaulting on UPDATE_ROW
-- Edward Nunez                  New columns NODE_STATUS and DIRECTORY_PATH,
--                               overloaded methods for BC4J compliance.
-- Edward Nunez                  New columns AVAILABLE_DATE, EXPIRATION_DATE
--                               and HIDDEN_FLAG
-- Kiran             09/02/2003  Added new procedure(INSERT_ROW_CP) to call from Java CP
-- Edward Nunez      12/08/2003  No use of OVN locking for update_row
-- Sri Rangarajan    06/22/2004  Removed the logic of NULL from Update.Bug#3657744
-- Edward Nunez      06/23/2004  Added check for uniqueness during update_row
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  px_DIRECTORY_NODE_ID IN OUT NOCOPY NUMBER,
  p_DIRECTORY_NODE_CODE IN VARCHAR2,
  p_NODE_STATUS IN VARCHAR2,
  p_DIRECTORY_PATH IN VARCHAR2,
  p_AVAILABLE_DATE IN DATE,
  p_EXPIRATION_DATE IN DATE,
  p_HIDDEN_FLAG IN VARCHAR2,
  p_NODE_TYPE IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_DIRECTORY_NODE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_DIRECTORY_NODES_B
    WHERE DIRECTORY_NODE_ID = px_DIRECTORY_NODE_ID
    ;
  CURSOR c2 IS SELECT ibc_directory_nodes_b_s1.NEXTVAL FROM dual;

BEGIN

  -- Primary key validation check

  IF ((px_DIRECTORY_NODE_ID IS NULL) OR
      (px_DIRECTORY_NODE_ID = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_DIRECTORY_NODE_ID;
    CLOSE c2;
  END IF;

 INSERT INTO IBC_DIRECTORY_NODES_B (
    DIRECTORY_NODE_ID,
    DIRECTORY_NODE_CODE,
    NODE_STATUS,
    DIRECTORY_PATH,
    AVAILABLE_DATE,
    EXPIRATION_DATE,
    HIDDEN_FLAG,
    NODE_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    px_DIRECTORY_NODE_ID,
    p_DIRECTORY_NODE_CODE,
    DECODE(p_NODE_STATUS,FND_API.G_MISS_CHAR,NULL,p_NODE_STATUS),
    DECODE(p_DIRECTORY_PATH,FND_API.G_MISS_CHAR,NULL,p_DIRECTORY_PATH),
    DECODE(p_AVAILABLE_DATE,FND_API.G_MISS_DATE,NULL,p_AVAILABLE_DATE),
    DECODE(p_EXPIRATION_DATE,FND_API.G_MISS_DATE,NULL,p_EXPIRATION_DATE),
    DECODE(p_HIDDEN_FLAG,FND_API.G_MISS_CHAR,NULL,p_HIDDEN_FLAG),
    DECODE(p_NODE_TYPE,FND_API.G_MISS_CHAR,NULL,p_NODE_TYPE),
    DECODE(p_OBJECT_VERSION_NUMBER,FND_API.G_MISS_NUM,1,p_object_version_number),
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

  INSERT INTO IBC_DIRECTORY_NODES_TL (
    DIRECTORY_NODE_ID,
    DIRECTORY_NODE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    px_DIRECTORY_NODE_ID,
    p_DIRECTORY_NODE_NAME,
    DECODE(p_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,p_DESCRIPTION),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
	DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date) ,
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
	DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login),
    L.LANGUAGE_CODE,
    USERENV('LANG')
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_DIRECTORY_NODES_TL T
    WHERE T.DIRECTORY_NODE_ID = px_DIRECTORY_NODE_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  x_DIRECTORY_NODE_ID IN OUT NOCOPY NUMBER,
  x_DIRECTORY_NODE_CODE IN VARCHAR2,
  x_NODE_STATUS IN VARCHAR2,
  x_DIRECTORY_PATH IN VARCHAR2,
  x_AVAILABLE_DATE IN DATE,
  x_EXPIRATION_DATE IN DATE,
  x_HIDDEN_FLAG IN VARCHAR2,
  x_NODE_TYPE IN VARCHAR2,
  x_OBJECT_VERSION_NUMBER IN NUMBER,
  x_DIRECTORY_NODE_NAME IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_CREATION_DATE IN DATE,
  x_CREATED_BY IN NUMBER,
  x_LAST_UPDATE_DATE IN DATE,
  x_LAST_UPDATED_BY IN NUMBER,
  x_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN

  INSERT_ROW (
    x_ROWID => x_rowid,
    px_DIRECTORY_NODE_ID => x_directory_node_id,
    p_DIRECTORY_NODE_CODE => x_directory_node_code,
    p_NODE_STATUS => x_node_status,
    p_DIRECTORY_PATH => x_directory_path,
    p_AVAILABLE_DATE => x_available_date,
    p_EXPIRATION_DATE => x_expiration_date,
    p_HIDDEN_FLAG => x_HIDDEN_FLAG,
    p_NODE_TYPE => x_node_type,
    p_OBJECT_VERSION_NUMBER => x_object_version_number,
    p_DIRECTORY_NODE_NAME => x_directory_node_name,
    p_DESCRIPTION => x_description,
    p_CREATION_DATE => x_creation_date,
    p_CREATED_BY => x_created_by,
    p_LAST_UPDATE_DATE => x_last_update_date,
    p_LAST_UPDATED_BY => x_last_updated_by,
    p_LAST_UPDATE_LOGIN => x_last_update_login
  );

END INSERT_ROW;

PROCEDURE INSERT_ROW_CP (
  x_ROWID OUT NOCOPY VARCHAR2,
  x_DIRECTORY_NODE_ID IN OUT NOCOPY NUMBER,
  x_DIRECTORY_NODE_CODE IN VARCHAR2,
  x_NODE_STATUS IN VARCHAR2,
  x_DIRECTORY_PATH IN VARCHAR2,
  x_AVAILABLE_DATE IN DATE,
  x_EXPIRATION_DATE IN DATE,
  x_HIDDEN_FLAG IN VARCHAR2,
  x_NODE_TYPE IN VARCHAR2,
  x_OBJECT_VERSION_NUMBER IN NUMBER,
  x_DIRECTORY_NODE_NAME IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_CREATION_DATE IN DATE,
  x_CREATED_BY IN NUMBER,
  x_LAST_UPDATE_DATE IN DATE,
  x_LAST_UPDATED_BY IN NUMBER,
  x_LAST_UPDATE_LOGIN IN NUMBER
) IS
BEGIN

  INSERT_ROW (
    x_ROWID => x_rowid,
    px_DIRECTORY_NODE_ID => x_directory_node_id,
    p_DIRECTORY_NODE_CODE => x_directory_node_code,
    p_NODE_STATUS => x_node_status,
    p_DIRECTORY_PATH => x_directory_path,
    p_AVAILABLE_DATE => x_available_date,
    p_EXPIRATION_DATE => x_expiration_date,
    p_HIDDEN_FLAG => x_HIDDEN_FLAG,
    p_NODE_TYPE => x_node_type,
    p_OBJECT_VERSION_NUMBER => x_object_version_number,
    p_DIRECTORY_NODE_NAME => x_directory_node_name,
    p_DESCRIPTION => x_description,
    p_CREATION_DATE => x_creation_date,
    p_CREATED_BY => x_created_by,
    p_LAST_UPDATE_DATE => x_last_update_date,
    p_LAST_UPDATED_BY => x_last_updated_by,
    p_LAST_UPDATE_LOGIN => x_last_update_login
  );

END INSERT_ROW_CP;


PROCEDURE LOCK_ROW (
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_DIRECTORY_NODE_CODE IN VARCHAR2,
  p_NODE_TYPE IN VARCHAR2,
  p_NODE_STATUS IN VARCHAR2,
  p_DIRECTORY_PATH IN VARCHAR2,
  p_AVAILABLE_DATE IN DATE,
  p_EXPIRATION_DATE IN DATE,
  p_HIDDEN_FLAG IN VARCHAR2,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_DIRECTORY_NODE_NAME IN VARCHAR2,
  p_DESCRIPTION IN VARCHAR2
) IS
  CURSOR c IS SELECT
      DIRECTORY_NODE_CODE,
      NODE_TYPE,
      NODE_STATUS,
      DIRECTORY_PATH,
      AVAILABLE_DATE,
      EXPIRATION_DATE,
      HIDDEN_FLAG,
      OBJECT_VERSION_NUMBER
    FROM IBC_DIRECTORY_NODES_B
    WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID
    FOR UPDATE OF DIRECTORY_NODE_ID NOWAIT;
  recinfo c%ROWTYPE;

  CURSOR c1 IS SELECT
      DIRECTORY_NODE_NAME,
      DESCRIPTION,
      DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
    FROM IBC_DIRECTORY_NODES_TL
    WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
    FOR UPDATE OF DIRECTORY_NODE_ID NOWAIT;
BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (  ((recinfo.NODE_TYPE = p_NODE_TYPE)
         OR ((recinfo.NODE_TYPE IS NULL) AND (p_NODE_TYPE IS NULL)))
      AND ((recinfo.DIRECTORY_NODE_CODE = p_DIRECTORY_NODE_CODE)
          OR ((recinfo.DIRECTORY_NODE_CODE IS NULL) AND (p_DIRECTORY_NODE_CODE IS NULL)))
      AND ((recinfo.NODE_STATUS = p_NODE_STATUS)
          OR ((recinfo.NODE_STATUS IS NULL) AND (p_NODE_STATUS IS NULL)))
      AND ((recinfo.DIRECTORY_PATH = p_DIRECTORY_PATH)
          OR ((recinfo.DIRECTORY_PATH IS NULL) AND (p_DIRECTORY_PATH IS NULL)))
      AND ((recinfo.AVAILABLE_DATE = p_AVAILABLE_DATE)
          OR ((recinfo.AVAILABLE_DATE IS NULL) AND (p_AVAILABLE_DATE IS NULL)))
      AND ((recinfo.EXPIRATION_DATE = p_EXPIRATION_DATE)
          OR ((recinfo.EXPIRATION_DATE IS NULL) AND (p_EXPIRATION_DATE IS NULL)))
      AND ((recinfo.HIDDEN_FLAG = p_HIDDEN_FLAG)
          OR ((recinfo.HIDDEN_FLAG IS NULL) AND (p_HIDDEN_FLAG IS NULL)))
      AND (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  FOR tlinfo IN c1 LOOP
    IF (tlinfo.BASELANG = 'Y') THEN
      IF (    (tlinfo.DIRECTORY_NODE_NAME = p_DIRECTORY_NODE_NAME)
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

PROCEDURE LOCK_ROW (
  x_DIRECTORY_NODE_ID IN NUMBER,
  x_DIRECTORY_NODE_CODE IN VARCHAR2,
  x_NODE_TYPE IN VARCHAR2,
  x_NODE_STATUS IN VARCHAR2,
  x_DIRECTORY_PATH IN VARCHAR2,
  x_AVAILABLE_DATE IN DATE,
  x_EXPIRATION_DATE IN DATE,
  x_HIDDEN_FLAG IN VARCHAR2,
  x_OBJECT_VERSION_NUMBER IN NUMBER,
  x_DIRECTORY_NODE_NAME IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2
) IS
BEGIN
  LOCK_ROW (
    p_DIRECTORY_NODE_ID => x_directory_node_id,
    p_DIRECTORY_NODE_CODE => x_directory_node_code,
    p_NODE_TYPE => x_node_type,
    p_NODE_STATUS => x_node_status,
    p_DIRECTORY_PATH => x_directory_path,
    p_AVAILABLE_DATE => x_available_date,
    p_EXPIRATION_DATE => x_expiration_date,
    p_HIDDEN_FLAG => x_hidden_flag,
    p_OBJECT_VERSION_NUMBER => x_object_version_number,
    p_DIRECTORY_NODE_NAME => x_directory_node_name,
    p_DESCRIPTION => x_description
  );
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
   p_DIRECTORY_NODE_ID		IN  NUMBER,
   p_DIRECTORY_NODE_CODE	IN  VARCHAR2,
   p_DESCRIPTION		IN  VARCHAR2,
   p_DIRECTORY_NODE_NAME	IN  VARCHAR2,
   p_LAST_UPDATED_BY		IN  NUMBER,
   p_LAST_UPDATE_DATE		IN  DATE,
   p_LAST_UPDATE_LOGIN		IN  NUMBER,
   p_NODE_STATUS IN VARCHAR2,
   p_DIRECTORY_PATH IN VARCHAR2,
   p_AVAILABLE_DATE IN DATE,
   p_EXPIRATION_DATE IN DATE,
   p_HIDDEN_FLAG IN VARCHAR2,
   p_NODE_TYPE			IN  VARCHAR2,
   p_OBJECT_VERSION_NUMBER	IN  NUMBER
) IS

  CURSOR c_parent_dirnode(p_dir_node_id NUMBER) IS
    SELECT parent_dir_node_id
      FROM ibc_directory_node_rels
     WHERE child_dir_node_id = p_dir_node_id;

  l_object_type VARCHAR2(30);
  l_object_id   NUMBER;

BEGIN

  -- Validating Uniqueness for Name in a particular directory
  FOR r_parent_dirnode IN c_parent_dirnode(p_directory_node_id) LOOP
    IF IBC_UTILITIES_PVT.is_name_already_used(
          p_dir_node_id          => r_parent_dirnode.parent_dir_node_id,
          p_name                 => p_directory_node_code,
          p_language             => USERENV('lang'),
          p_chk_dir_node_id      => p_directory_node_id,
		  x_object_type          => l_object_type,
		  x_object_id            => l_object_id)
    THEN
      Fnd_Message.Set_Name('IBC', 'IBC_INVALID_FOLDER_NAME');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;
  END LOOP;

  UPDATE IBC_DIRECTORY_NODES_B SET
   DIRECTORY_NODE_CODE = DECODE(p_DIRECTORY_NODE_CODE,FND_API.G_MISS_CHAR,NULL,NULL,DIRECTORY_NODE_CODE,p_DIRECTORY_NODE_CODE),
   NODE_STATUS = DECODE(p_NODE_STATUS,FND_API.G_MISS_CHAR,NULL,NULL,NODE_STATUS,p_NODE_STATUS),
   DIRECTORY_PATH = DECODE(p_DIRECTORY_PATH,FND_API.G_MISS_CHAR,NULL,NULL,DIRECTORY_PATH,p_DIRECTORY_PATH),
   AVAILABLE_DATE = DECODE(p_AVAILABLE_DATE,FND_API.G_MISS_DATE,NULL,p_AVAILABLE_DATE),
   EXPIRATION_DATE = DECODE(p_EXPIRATION_DATE,FND_API.G_MISS_DATE,NULL,p_EXPIRATION_DATE),
   HIDDEN_FLAG = DECODE(p_HIDDEN_FLAG,FND_API.G_MISS_CHAR,NULL,NULL,HIDDEN_FLAG,p_HIDDEN_FLAG),
   NODE_TYPE = DECODE(p_NODE_TYPE,FND_API.G_MISS_CHAR,NULL,NULL,NODE_TYPE,p_NODE_TYPE),
   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID;

--  AND object_version_number = DECODE(p_object_version_number,
--                                     FND_API.G_MISS_NUM, object_version_number,
--                                     NULL, object_version_number,
--                                     p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE IBC_DIRECTORY_NODES_TL SET
    DIRECTORY_NODE_NAME = DECODE(p_DIRECTORY_NODE_NAME,FND_API.G_MISS_CHAR,NULL,NULL,DIRECTORY_NODE_NAME,p_DIRECTORY_NODE_NAME),
    DESCRIPTION = DECODE(p_DESCRIPTION,FND_API.G_MISS_CHAR,NULL,p_DESCRIPTION),
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login),
    SOURCE_LANG = USERENV('LANG')
  WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID
  AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE UPDATE_ROW (
   x_DIRECTORY_NODE_ID		IN  NUMBER,
   x_DIRECTORY_NODE_CODE	IN  VARCHAR2,
   x_DESCRIPTION		IN  VARCHAR2,
   x_DIRECTORY_NODE_NAME	IN  VARCHAR2,
   x_LAST_UPDATED_BY		IN  NUMBER,
   x_LAST_UPDATE_DATE		IN  DATE,
   x_LAST_UPDATE_LOGIN		IN  NUMBER,
   x_NODE_STATUS IN VARCHAR2,
   x_DIRECTORY_PATH IN VARCHAR2,
   x_AVAILABLE_DATE IN DATE,
   x_EXPIRATION_DATE IN DATE,
   x_HIDDEN_FLAG IN VARCHAR2,
   x_NODE_TYPE			IN  VARCHAR2,
   x_OBJECT_VERSION_NUMBER	IN  NUMBER
) IS
BEGIN
  UPDATE_ROW (
    p_DIRECTORY_NODE_ID		=> x_directory_node_id,
    p_DIRECTORY_NODE_CODE	=> x_directory_node_code,
    p_DESCRIPTION		=> x_description,
    p_DIRECTORY_NODE_NAME	=> x_directory_node_name,
    p_LAST_UPDATED_BY		=> x_last_updated_by,
    p_LAST_UPDATE_DATE	=>	x_last_update_date,
    p_LAST_UPDATE_LOGIN	=>	x_last_update_login,
    p_NODE_STATUS => x_node_status,
    p_DIRECTORY_PATH => x_directory_path,
    p_AVAILABLE_DATE => x_available_date,
    p_EXPIRATION_DATE => x_expiration_date,
    p_HIDDEN_FLAG => x_hidden_flag,
    p_NODE_TYPE			=> x_node_type,
    p_OBJECT_VERSION_NUMBER	=> x_object_version_number
  );
END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_DIRECTORY_NODE_ID IN NUMBER
) IS
BEGIN
  DELETE FROM IBC_DIRECTORY_NODES_TL
  WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM IBC_DIRECTORY_NODES_B
  WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE DELETE_ROW (
  x_DIRECTORY_NODE_ID IN NUMBER
) IS
BEGIN
  DELETE_ROW (
    p_DIRECTORY_NODE_ID => x_directory_node_id
  );
END DELETE_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM IBC_DIRECTORY_NODES_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM IBC_DIRECTORY_NODES_B B
    WHERE B.DIRECTORY_NODE_ID = T.DIRECTORY_NODE_ID
    );

  UPDATE IBC_DIRECTORY_NODES_TL T SET (
      DIRECTORY_NODE_NAME,
      DESCRIPTION
    ) = (SELECT
      B.DIRECTORY_NODE_NAME,
      B.DESCRIPTION
    FROM IBC_DIRECTORY_NODES_TL B
    WHERE B.DIRECTORY_NODE_ID = T.DIRECTORY_NODE_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.DIRECTORY_NODE_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.DIRECTORY_NODE_ID,
      SUBT.LANGUAGE
    FROM IBC_DIRECTORY_NODES_TL SUBB, IBC_DIRECTORY_NODES_TL SUBT
    WHERE SUBB.DIRECTORY_NODE_ID = SUBT.DIRECTORY_NODE_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.DIRECTORY_NODE_NAME <> SUBT.DIRECTORY_NODE_NAME
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

  INSERT INTO IBC_DIRECTORY_NODES_TL (
    DIRECTORY_NODE_ID,
    DIRECTORY_NODE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT /*+ ORDERED */
    B.DIRECTORY_NODE_ID,
    B.DIRECTORY_NODE_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM IBC_DIRECTORY_NODES_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND B.LANGUAGE = USERENV('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM IBC_DIRECTORY_NODES_TL T
    WHERE T.DIRECTORY_NODE_ID = B.DIRECTORY_NODE_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_DIRECTORY_NODE_ID	IN	NUMBER,
  p_NODE_TYPE	IN	VARCHAR2,
  p_NODE_STATUS IN VARCHAR2,
  p_DIRECTORY_PATH IN VARCHAR2,
  p_AVAILABLE_DATE IN DATE,
  p_EXPIRATION_DATE IN DATE,
  p_HIDDEN_FLAG IN VARCHAR2,
  p_DIRECTORY_NODE_CODE	IN	VARCHAR2,
  p_DIRECTORY_NODE_NAME	IN	VARCHAR2,
  p_DESCRIPTION	IN	VARCHAR2,
  p_OWNER 	IN VARCHAR2,
  p_last_update_date IN VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_last_update_date DATE;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

    l_row_id     VARCHAR2(64);

   BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_DIRECTORY_NODES_B
	WHERE DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Directory_Nodes_Pkg.UPDATE_ROW (
		  p_DIRECTORY_NODE_ID => p_DIRECTORY_NODE_ID,
		  p_NODE_TYPE	=>	nvl(p_NODE_TYPE,FND_API.G_MISS_CHAR),
		  p_NODE_STATUS	=>	nvl(p_NODE_STATUS,FND_API.G_MISS_CHAR),
		  p_DIRECTORY_PATH =>	nvl(p_DIRECTORY_PATH,FND_API.G_MISS_CHAR),
		  p_AVAILABLE_DATE => nvl(p_AVAILABLE_DATE, FND_API.G_MISS_DATE),
		  p_EXPIRATION_DATE => nvl(p_EXPIRATION_DATE, FND_API.G_MISS_DATE),
		  p_HIDDEN_FLAG     => nvl(p_HIDDEN_FLAG, FND_API.g_MISS_CHAR),
		  p_DIRECTORY_NODE_CODE	=>	p_DIRECTORY_NODE_CODE,
		  p_DIRECTORY_NODE_NAME	=>	nvl(p_DIRECTORY_NODE_NAME,FND_API.G_MISS_CHAR),
		  p_DESCRIPTION	=>	nvl(p_DESCRIPTION,FND_API.G_MISS_CHAR),
		  p_LAST_UPDATED_BY =>	l_user_id,
		  p_LAST_UPDATE_DATE =>	l_last_update_date,
		  p_LAST_UPDATE_LOGIN =>	0,
		  p_OBJECT_VERSION_NUMBER =>	NULL
		);
	END IF;


	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		 DECLARE
			lx_rowid VARCHAR2(240);
			l_DIRECTORY_NODE_ID NUMBER := p_DIRECTORY_NODE_ID;

		 BEGIN
		       Ibc_Directory_Nodes_Pkg.INSERT_ROW (
			      x_rowid => lx_rowid,
			  px_DIRECTORY_NODE_ID	=>	l_DIRECTORY_NODE_ID,
			  p_NODE_TYPE	=>	p_NODE_TYPE,
			  p_NODE_STATUS	=>	p_NODE_STATUS,
			  p_DIRECTORY_PATH =>	p_DIRECTORY_PATH,
			  p_AVAILABLE_DATE => p_AVAILABLE_DATE,
			  p_EXPIRATION_DATE => p_EXPIRATION_DATE,
			  p_HIDDEN_FLAG     => p_HIDDEN_FLAG,
			  p_DIRECTORY_NODE_CODE	=>	p_DIRECTORY_NODE_CODE,
			  p_DIRECTORY_NODE_NAME	=>	p_DIRECTORY_NODE_NAME,
			  p_DESCRIPTION	=>	p_DESCRIPTION,
			  p_CREATION_DATE => l_last_update_date,
			  p_CREATED_BY 	=> l_user_id,
			  p_LAST_UPDATE_DATE => l_last_update_date,
			  p_LAST_UPDATED_BY => l_user_id,
			  p_LAST_UPDATE_LOGIN => 0,
		          p_OBJECT_VERSION_NUMBER => 1);
		 END;

   END;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_DIRECTORY_NODE_ID	IN	NUMBER,
  p_DIRECTORY_NODE_NAME	IN	VARCHAR2,
  p_DESCRIPTION			IN	VARCHAR2,
  p_OWNER 	IN VARCHAR2,
  p_last_update_date IN VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
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
	FROM ibc_directory_nodes_tl
	WHERE DIRECTORY_NODE_ID  = p_DIRECTORY_NODE_ID
	AND USERENV('LANG') IN (LANGUAGE, source_lang);

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

	  -- Only update rows which have not been altered by user
	  UPDATE ibc_directory_nodes_tl t SET
	    DIRECTORY_NODE_NAME   = p_DIRECTORY_NODE_NAME,
	    description 		  = p_description,
	    source_lang 		  = USERENV('LANG'),
	    last_update_date 	  = l_last_update_date,
	    last_updated_by 	  = l_user_id,
	    last_update_login 	  = 0
	  WHERE DIRECTORY_NODE_ID 	  = p_DIRECTORY_NODE_ID
	  AND USERENV('LANG') IN (LANGUAGE, source_lang);

	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
   END;
END TRANSLATE_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_DIRECTORY_NODE_ID	IN	NUMBER,
  p_NODE_TYPE	IN	VARCHAR2,
  p_NODE_STATUS IN VARCHAR2,
  p_DIRECTORY_PATH IN VARCHAR2,
  p_AVAILABLE_DATE IN DATE,
  p_EXPIRATION_DATE IN DATE,
  p_HIDDEN_FLAG IN VARCHAR2,
  p_DIRECTORY_NODE_CODE	IN	VARCHAR2,
  p_DIRECTORY_NODE_NAME	IN	VARCHAR2,
  p_DESCRIPTION	IN	VARCHAR2,
  p_OWNER  IN VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		Ibc_Directory_Nodes_Pkg.TRANSLATE_ROW (
		p_UPLOAD_MODE	=>	p_UPLOAD_MODE,
		p_DIRECTORY_NODE_ID	=>	p_DIRECTORY_NODE_ID,
		p_DIRECTORY_NODE_NAME	=>	p_DIRECTORY_NODE_NAME,
		p_DESCRIPTION		=> p_DESCRIPTION,
		p_OWNER => p_OWNER,
		p_last_update_date => p_LAST_UPDATE_DATE);
	ELSE
		Ibc_Directory_Nodes_Pkg.LOAD_ROW(
		  p_UPLOAD_MODE	=>	p_UPLOAD_MODE,
		  p_DIRECTORY_NODE_ID	=>	p_DIRECTORY_NODE_ID,
		  p_NODE_TYPE	=> p_NODE_TYPE,
		  p_NODE_STATUS => p_NODE_STATUS,
		  p_DIRECTORY_PATH => p_DIRECTORY_PATH,
		  p_AVAILABLE_DATE => p_AVAILABLE_DATE,
		  p_EXPIRATION_DATE => p_EXPIRATION_DATE,
		  p_HIDDEN_FLAG => p_HIDDEN_FLAG,
		  p_DIRECTORY_NODE_CODE	=> p_DIRECTORY_NODE_CODE,
		  p_DIRECTORY_NODE_NAME	=>	p_DIRECTORY_NODE_NAME,
		  p_DESCRIPTION		=>p_DESCRIPTION,
		  p_OWNER => p_OWNER,
		  p_last_update_date => p_LAST_UPDATE_DATE);
	END IF;
END LOAD_SEED_ROW;

END Ibc_Directory_Nodes_Pkg;

/
