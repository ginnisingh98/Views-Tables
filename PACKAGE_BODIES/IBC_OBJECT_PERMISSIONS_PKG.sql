--------------------------------------------------------
--  DDL for Package Body IBC_OBJECT_PERMISSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_OBJECT_PERMISSIONS_PKG" AS
/* $Header: ibctopeb.pls 115.1 2002/11/13 23:47:10 vicho ship $ */

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW

PROCEDURE INSERT_ROW (
  X_ROWID OUT NOCOPY VARCHAR2,
  P_OBJECT_ID IN NUMBER,
  P_PERMISSIONS_LOOKUP_TYPE IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_OBJECT_PERMISSIONS
    WHERE OBJECT_ID = P_OBJECT_ID;
BEGIN
  INSERT INTO IBC_OBJECT_PERMISSIONS (
    OBJECT_ID,
    PERMISSIONS_LOOKUP_TYPE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    P_OBJECT_ID,
    P_PERMISSIONS_LOOKUP_TYPE,
    P_OBJECT_VERSION_NUMBER,
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,p_creation_date),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,NULL, FND_GLOBAL.login_id, p_last_update_login)
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  P_OBJECT_ID IN NUMBER,
  P_PERMISSIONS_LOOKUP_TYPE IN VARCHAR2,
  P_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      PERMISSIONS_LOOKUP_TYPE,
      OBJECT_VERSION_NUMBER
    FROM IBC_OBJECT_PERMISSIONS
    WHERE OBJECT_ID = P_OBJECT_ID
    FOR UPDATE OF OBJECT_ID NOWAIT;
  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.PERMISSIONS_LOOKUP_TYPE = P_PERMISSIONS_LOOKUP_TYPE)
      AND (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  P_OBJECT_ID IN NUMBER,
  P_PERMISSIONS_LOOKUP_TYPE IN VARCHAR2,
  p_LAST_UPDATED_BY    IN  NUMBER,
  p_LAST_UPDATE_DATE    IN  DATE,
  p_LAST_UPDATE_LOGIN    IN  NUMBER,
  p_OBJECT_VERSION_NUMBER    IN  NUMBER
) IS
BEGIN
  UPDATE IBC_OBJECT_PERMISSIONS SET
    PERMISSIONS_LOOKUP_TYPE = P_PERMISSIONS_LOOKUP_TYPE,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE OBJECT_ID = P_OBJECT_ID
  AND object_version_number = DECODE(p_object_version_number,
                                       FND_API.G_MISS_NUM,object_version_number,
                                       NULL,object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  P_OBJECT_ID IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_OBJECT_PERMISSIONS
  WHERE OBJECT_ID = P_OBJECT_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;


PROCEDURE LOAD_ROW (
  p_object_id		  NUMBER,
  p_PERMISSIONS_LOOKUP_TYPE	  VARCHAR2,
  p_OWNER 			IN VARCHAR2) IS
  l_user_id    NUMBER := 0;
  lx_row_id     VARCHAR2(240);

BEGIN
    IF (p_OWNER = 'SEED') THEN
      l_user_id := 1;
    END IF;


	UPDATE_ROW (
          p_object_id	  =>	p_object_id,
          p_PERMISSIONS_LOOKUP_TYPE		=>	p_PERMISSIONS_LOOKUP_TYPE,
  		  p_LAST_UPDATED_BY    	 	=>l_user_id,
  		  p_LAST_UPDATE_DATE     	=>SYSDATE,
  		  p_LAST_UPDATE_LOGIN    	=>0,
  		  p_OBJECT_VERSION_NUMBER	=>NULL);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       INSERT_ROW (
          X_ROWID => lx_row_id,
          p_object_id	  =>	p_object_id,
          p_PERMISSIONS_LOOKUP_TYPE		=>	p_PERMISSIONS_LOOKUP_TYPE,
          p_OBJECT_VERSION_NUMBER	=>	1,
          p_CREATION_DATE 		  => SYSDATE,
          p_CREATED_BY 			  => l_user_id,
          p_LAST_UPDATE_DATE 	  => SYSDATE,
          p_LAST_UPDATED_BY 	  => l_user_id,
          p_LAST_UPDATE_LOGIN 	  => 0);

END LOAD_ROW;


END Ibc_Object_Permissions_Pkg;

/
