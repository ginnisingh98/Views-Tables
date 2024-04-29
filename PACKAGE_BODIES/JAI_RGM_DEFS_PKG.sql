--------------------------------------------------------
--  DDL for Package Body JAI_RGM_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RGM_DEFS_PKG" AS
/* $Header: jai_rgm_defs_th.plb 120.3 2006/01/20 16:17:43 avallabh ship $ */

PROCEDURE Load_Row(  x_regime_code                VARCHAR2,
                     x_description                VARCHAR2,
                     x_owner                      VARCHAR2,
                     x_last_update_date           VARCHAR2,
                     x_force_edits                VARCHAR2 )   IS
    v_creation_date date;
    v_rowid rowid := null;
    v_user_id     NUMBER := fnd_load_util.owner_id(x_owner);
    vf_ludate   DATE := to_date(x_last_update_date, 'DD-MM-YYYY HH:MI:SS');
    vd_ludate   DATE;

  BEGIN

    -- validate input parameters
     IF(x_regime_code is NULL) then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Load_Row: Required data is not provided.');
      app_exception.raise_exception;
      end if;

 /* Commented the below since we got the user_id from fnd_load_util
    if (X_OWNER = 'SEED') then
      v_user_id := 1;
    end if; */

   DECLARE

    CURSOR cur_creation_date IS
    select creation_date, last_update_date
    from   JAI_RGM_DEFINITIONS
    where regime_code = x_regime_code ;

   BEGIN
      /* Check if the row exists in the database. If it does, retrieves the creation date for update_row. */
       OPEN cur_creation_date ;
       FETCH cur_creation_date into v_creation_date, vd_ludate ;
       IF cur_creation_date%NOTFOUND THEN
           raise NO_DATA_FOUND ;
       END IF;
       CLOSE cur_creation_date ;

     /* Removed the check for userid and added check using last_update_date
	for bug 4967445 */

       /* Update only if force_edits is 'Y' or if vf_ludate > vd_ludate */
   if ( vf_ludate > vd_ludate or X_Force_Edits = 'Y' ) then
         -- update row if present
       jai_rgm_defs_pkg.Update_Row(
          X_Rowid                => v_rowid,
          X_regime_code          => X_regime_code ,
          x_description          => x_description        ,
          x_creation_date        => v_creation_date,
          X_last_update_date     => vf_ludate,
          X_last_updated_by      => v_user_id,
          X_last_update_login    => 0);
   end if;
      exception
        when NO_DATA_FOUND then
         jai_rgm_defs_pkg.Insert_Row(
          X_Rowid                => v_rowid,
          X_regime_code          => X_regime_code ,
          x_description          => x_description         ,
          X_last_update_date     => vf_ludate,
          X_last_updated_by      => v_user_id,
          X_creation_date        => sysdate,
          X_created_by           => v_user_id,
          X_last_update_login    => 0) ;
    END;
   EXCEPTION
      WHEN OTHERS then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Error in Load_Row: jai_rgm_defs_pkg');
      app_exception.raise_exception;
  END Load_Row;

 PROCEDURE Insert_Row(
                     X_Rowid              IN OUT NOCOPY ROWID,
                     X_regime_code            VARCHAR2,
                     x_description            VARCHAR2,
                     X_last_update_date       DATE,
                     X_last_updated_by        NUMBER,
                     X_creation_date          DATE ,
                     X_created_by             NUMBER,
                     X_last_update_login      NUMBER) IS
     CURSOR C_REGIME_ID IS SELECT JAI_RGM_DEFINITIONS_S.nextval FROM dual;
     X_regime_id NUMBER ;
  BEGIN
     OPEN C_REGIME_ID;
     FETCH C_REGIME_ID INTO X_regime_id;
     CLOSE C_REGIME_ID;

    INSERT INTO JAI_RGM_DEFINITIONS(
                  regime_id            ,
                  regime_code          ,
                  description          ,
                  creation_date        ,
                  created_by           ,
                  last_update_date     ,
                  last_updated_by      ,
                  last_update_login
                )
    SELECT
             x_regime_id           ,
             X_regime_code         ,
             x_description         ,
             X_creation_date       ,
             X_created_by          ,
             X_last_update_date    ,
             X_last_updated_by     ,
             X_last_update_login
    FROM  DUAL ;

  END Insert_Row;

PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY ROWID,
                     X_regime_code             VARCHAR2,
                     x_description             VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER)
 IS
  BEGIN
    UPDATE JAI_RGM_DEFINITIONS
    SET
        regime_code           = x_regime_code         ,
        description           = x_description         ,
        creation_date         = x_creation_date       ,
        last_update_date      = x_last_update_date    ,
        last_updated_by       = x_last_updated_by     ,
        last_update_login     = x_last_update_login
    WHERE
    regime_code = x_regime_code;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;

END  jai_rgm_defs_pkg  ;

/
