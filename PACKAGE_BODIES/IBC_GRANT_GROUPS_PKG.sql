--------------------------------------------------------
--  DDL for Package Body IBC_GRANT_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_GRANT_GROUPS_PKG" AS
/* $Header: ibctggrb.pls 115.1 2002/11/13 23:46:28 vicho ship $ */

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW


PROCEDURE INSERT_ROW (
  PX_ROWID IN OUT NOCOPY VARCHAR2,
  P_GRANT_GROUP_ID IN NUMBER,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_GRANT_GROUPS
    WHERE GRANT_GROUP_ID = P_GRANT_GROUP_ID
    ;
BEGIN
  INSERT INTO IBC_GRANT_GROUPS (
    OBJECT_VERSION_NUMBER,
    GRANT_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    P_OBJECT_VERSION_NUMBER,
    P_GRANT_GROUP_ID,
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,p_creation_date),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,NULL, FND_GLOBAL.login_id, p_last_update_login)
  );

  OPEN c;
  FETCH c INTO PX_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  P_GRANT_GROUP_ID IN NUMBER,
  P_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_GRANT_GROUPS
    WHERE GRANT_GROUP_ID = P_GRANT_GROUP_ID
    FOR UPDATE OF GRANT_GROUP_ID NOWAIT;
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
  IF (    (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  P_GRANT_GROUP_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER    IN  NUMBER,
  p_LAST_UPDATED_BY	IN  NUMBER,
  p_LAST_UPDATE_DATE    IN  DATE,
  p_LAST_UPDATE_LOGIN    IN  NUMBER
) IS
BEGIN
  UPDATE IBC_GRANT_GROUPS SET
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
    last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE GRANT_GROUP_ID = P_GRANT_GROUP_ID
  AND object_version_number = DECODE(p_object_version_number,
                                     FND_API.G_MISS_NUM,object_version_number,
                                     NULL,object_version_number,
                                     p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  P_GRANT_GROUP_ID IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_GRANT_GROUPS
  WHERE GRANT_GROUP_ID = P_GRANT_GROUP_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

END Ibc_Grant_Groups_Pkg;

/
