--------------------------------------------------------
--  DDL for Package Body MTL_STATUS_TRX_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_STATUS_TRX_CONTROL_PKG" AS
/* $Header: INVMSTCB.pls 120.1 2005/06/11 11:28:19 appldev  $ */

PROCEDURE INSERT_ROW (
   x_ROWID                      IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  ,p_STATUS_ID              	IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
  ,p_CREATION_DATE              IN      DATE
  ,p_CREATED_BY                 IN      NUMBER
  ,p_LAST_UPDATED_BY            IN      NUMBER
  ,p_LAST_UPDATE_DATE           IN      DATE
  ,p_LAST_UPDATE_LOGIN          IN      NUMBER
  ,p_PROGRAM_APPLICATION_ID     IN      NUMBER
  ,p_PROGRAM_ID                 IN      NUMBER
)IS
    CURSOR C IS SELECT ROWID FROM MTL_STATUS_TRANSACTION_CONTROL
      WHERE status_id = p_STATUS_ID
      AND transaction_type_id = p_TRANSACTION_TYPE_ID;
BEGIN
   INSERT INTO MTL_STATUS_TRANSACTION_CONTROL (
   status_id
   , transaction_type_id
   , is_allowed
   , creation_date
   , created_by
   , last_updated_by
   , last_update_date
   , last_update_login
   , program_application_id
   , program_id
   ) values (
  	 p_STATUS_ID
   	,p_TRANSACTION_TYPE_ID
  	,p_IS_ALLOWED
   	,p_CREATION_DATE
  	,p_CREATED_BY
  	,p_LAST_UPDATED_BY
  	,p_LAST_UPDATE_DATE
  	,p_LAST_UPDATE_LOGIN
  	,p_PROGRAM_APPLICATION_ID
  	,p_PROGRAM_ID
  );

  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
     CLOSE C;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
END INSERT_ROW;

PROCEDURE LOCK_ROW (
   p_STATUS_ID                  IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
)IS
    CURSOR C IS SELECT
   status_id
   , transaction_type_id
   , is_allowed
   , creation_date
   , created_by
   , last_updated_by
   , last_update_date
   , last_update_login
   , program_application_id
   , program_id
   FROM MTL_STATUS_TRANSACTION_CONTROL
   WHERE status_id = p_STATUS_ID
   AND transaction_type_id = p_TRANSACTION_TYPE_ID
   FOR UPDATE OF status_id,transaction_type_id NOWAIT;

  recinfo c%ROWTYPE;
BEGIN
   OPEN c;
   FETCH c INTO recinfo;
   IF (c%notfound) THEN
      CLOSE c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
   END IF;
   CLOSE c;
   IF (    (recinfo.status_id = p_STATUS_ID)
       AND (recinfo.transaction_type_id = p_TRANSACTION_TYPE_ID)
       AND (recinfo.is_allowed = p_IS_ALLOWED)
       )THEN
     NULL;
   ELSE
     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception;
   END IF;
END LOCK_ROW;


PROCEDURE UPDATE_ROW (
   p_STATUS_ID                  IN      NUMBER
  ,p_TRANSACTION_TYPE_ID        IN      NUMBER
  ,p_IS_ALLOWED                 IN      NUMBER
  ,p_LAST_UPDATED_BY            IN      NUMBER
  ,p_LAST_UPDATE_DATE           IN      DATE
  ,p_LAST_UPDATE_LOGIN          IN      NUMBER
  ,p_PROGRAM_APPLICATION_ID     IN      NUMBER
  ,p_PROGRAM_ID                 IN      NUMBER
)IS
    x_ROWID  varchar2(18);
BEGIN
   UPDATE MTL_STATUS_TRANSACTION_CONTROL SET
   status_id = p_STATUS_ID
   , transaction_type_id = p_TRANSACTION_TYPE_ID
   , is_allowed = p_IS_ALLOWED
   , last_updated_by = p_LAST_UPDATED_BY
   , last_update_date = p_LAST_UPDATE_DATE
   , last_update_login = p_LAST_UPDATE_LOGIN
   , program_application_id = p_PROGRAM_APPLICATION_ID
   , program_id = p_PROGRAM_ID
   WHERE status_id = p_STATUS_ID
   AND transaction_type_id = p_TRANSACTION_TYPE_ID;

  IF (SQL%NOTFOUND) THEN
      MTL_STATUS_TRX_CONTROL_PKG.INSERT_ROW(
         x_ROWID
        ,p_STATUS_ID
        ,p_TRANSACTION_TYPE_ID
        ,p_IS_ALLOWED
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,p_LAST_UPDATED_BY
        ,p_LAST_UPDATE_DATE
        ,p_LAST_UPDATE_LOGIN
        ,p_PROGRAM_APPLICATION_ID
        ,p_PROGRAM_ID
     );
  END IF;
  -- commit since form can't detect the changes in list
  commit;
END UPDATE_ROW;

PROCEDURE INSERT_EXTRA_ROWS(P_STATUS_ID IN NUMBER)
IS
    CURSOR c_excluded_trxs IS
        SELECT mmt.transaction_type_id
        From  MTL_TRANSACTION_TYPES mmt
        where mmt.status_control_flag = 1
          and mmt.transaction_type_id not in (
              SELECT transaction_type_id
              FROM MTL_STATUS_TRANSACTION_CONTROL
              WHERE status_id = P_STATUS_ID);
    c_t_type c_excluded_trxs%ROWTYPE;

    x_ROWID  varchar2(18);
BEGIN
    FOR c_t_type IN c_excluded_trxs loop
      MTL_STATUS_TRX_CONTROL_PKG.INSERT_ROW(
        x_ROWID
        ,p_STATUS_ID
        ,c_t_type.TRANSACTION_TYPE_ID
        ,1
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.USER_ID
        ,SYSDATE
        ,FND_GLOBAL.LOGIN_ID
        ,null
        ,null
       );
    end loop;
    commit;
END INSERT_EXTRA_ROWS;

END MTL_STATUS_TRX_CONTROL_PKG;

/
