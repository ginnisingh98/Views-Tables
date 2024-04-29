--------------------------------------------------------
--  DDL for Package Body JAI_PA_SETUP_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_SETUP_CTX_PKG" AS
/* $Header: jai_pa_setup_ctx.plb 120.0.12000000.1 2007/10/24 18:20:39 rallamse noship $ */
/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */



PROCEDURE Load_Row(   x_context_id    NUMBER      ,
              x_context   VARCHAR2    ,
        x_attribute1_usage  VARCHAR2    ,
        x_attribute2_usage  VARCHAR2    ,
        x_attribute3_usage  VARCHAR2    ,
        x_attribute4_usage  VARCHAR2    ,
        x_attribute5_usage  VARCHAR2    ,
        x_setup_value1_usage  VARCHAR2    ,
        x_setup_value2_usage  VARCHAR2    ,
        x_setup_value3_usage  VARCHAR2    ,
        x_setup_value4_usage  VARCHAR2    ,
        x_setup_value5_usage  VARCHAR2    ,
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
     IF(x_context_id is NULL) then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Load_Row: Required data is not provided.');
      app_exception.raise_exception;
      end if;



   DECLARE

    CURSOR cur_creation_date IS
    select creation_date, last_update_date
    from   JAI_PA_SETUP_CONTEXTS
    where context_id = x_context_id ;

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
       jai_pa_setup_ctx_pkg.Update_Row(
          X_Rowid                => v_rowid       ,
    x_context_id     => x_context_id              ,
    x_context    => x_context           ,
    x_attribute1_usage   => x_attribute1_usage          ,
    x_attribute2_usage   => x_attribute2_usage          ,
    x_attribute3_usage   => x_attribute3_usage          ,
    x_attribute4_usage   => x_attribute4_usage          ,
    x_attribute5_usage   => x_attribute5_usage          ,
    x_setup_value1_usage   => x_setup_value1_usage        ,
    x_setup_value2_usage   => x_setup_value2_usage        ,
    x_setup_value3_usage   => x_setup_value3_usage        ,
    x_setup_value4_usage   => x_setup_value4_usage        ,
    x_setup_value5_usage   => x_setup_value5_usage        ,
          x_creation_date        => v_creation_date     ,
          X_last_update_date     => vf_ludate       ,
          X_last_updated_by      => v_user_id       ,
          X_last_update_login    => 0);
   end if;
      exception
        when NO_DATA_FOUND then
         jai_pa_setup_ctx_pkg.Insert_Row(
        X_Rowid                => v_rowid,
  X_context_id     => x_context_id       ,
  X_context    => x_context     ,
  X_attribute1_usage   => x_attribute1_usage    ,
  X_attribute2_usage   => x_attribute2_usage    ,
  X_attribute3_usage   => x_attribute3_usage    ,
  X_attribute4_usage   => x_attribute4_usage    ,
  X_attribute5_usage   => x_attribute5_usage    ,
  X_setup_value1_usage   => x_setup_value1_usage    ,
  X_setup_value2_usage   => x_setup_value2_usage    ,
  X_setup_value3_usage   => x_setup_value3_usage    ,
  X_setup_value4_usage   => x_setup_value4_usage    ,
  X_setup_value5_usage   => x_setup_value5_usage    ,
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
         x_context_id   NUMBER       ,
         x_context      VARCHAR2,
               x_attribute1_usage   VARCHAR2,
         x_attribute2_usage   VARCHAR2,
         x_attribute3_usage   VARCHAR2,
         x_attribute4_usage   VARCHAR2,
         x_attribute5_usage   VARCHAR2,
         x_setup_value1_usage VARCHAR2,
         x_setup_value2_usage VARCHAR2,
         x_setup_value3_usage VARCHAR2,
         x_setup_value4_usage VARCHAR2,
         x_setup_value5_usage VARCHAR2,
                     X_last_update_date   DATE,
                     X_last_updated_by    NUMBER,
                     X_creation_date    DATE ,
                     X_created_by   NUMBER,
                     X_last_update_login  NUMBER) IS

  BEGIN

    INSERT INTO JAI_PA_SETUP_CONTEXTS(
      context_id    ,
      context     ,
            attribute1_usage    ,
      attribute2_usage    ,
      attribute3_usage    ,
      attribute4_usage    ,
      attribute5_usage    ,
      setup_value1_usage  ,
      setup_value2_usage  ,
      setup_value3_usage  ,
      setup_value4_usage  ,
      setup_value5_usage  ,
                  creation_date        ,
                  created_by           ,
                  last_update_date     ,
                  last_updated_by      ,
                  last_update_login
                )
    SELECT
      X_CONTEXT_ID    ,
      x_context   ,
      x_attribute1_usage  ,
      x_attribute2_usage  ,
      x_attribute3_usage  ,
      x_attribute4_usage  ,
      x_attribute5_usage  ,
      x_setup_value1_usage  ,
      x_setup_value2_usage  ,
      x_setup_value3_usage  ,
      x_setup_value4_usage  ,
      x_setup_value5_usage  ,
                  X_creation_date       ,
                        X_created_by          ,
             X_last_update_date    ,
             X_last_updated_by     ,
             X_last_update_login
    FROM  DUAL ;

  END Insert_Row;

PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY ROWID,
                    x_context_id    NUMBER       ,
      x_context   VARCHAR2,
      x_attribute1_usage  VARCHAR2,
      x_attribute2_usage  VARCHAR2,
      x_attribute3_usage  VARCHAR2,
      x_attribute4_usage  VARCHAR2,
      x_attribute5_usage  VARCHAR2,
      x_setup_value1_usage  VARCHAR2,
      x_setup_value2_usage  VARCHAR2,
      x_setup_value3_usage  VARCHAR2,
      x_setup_value4_usage  VARCHAR2,
      x_setup_value5_usage  VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER)
 IS
  BEGIN
    UPDATE JAI_PA_SETUP_CONTEXTS
    SET
        CONTEXT           = x_context           ,
        ATTRIBUTE1_USAGE  = x_attribute1_usage          ,
  ATTRIBUTE2_USAGE  = x_attribute2_usage  ,
  ATTRIBUTE3_USAGE  = x_attribute3_usage  ,
  ATTRIBUTE4_USAGE  = x_attribute4_usage  ,
  ATTRIBUTE5_USAGE  = x_attribute5_usage  ,
  SETUP_VALUE1_USAGE  = x_setup_value1_usage,
  SETUP_VALUE2_USAGE  = x_setup_value2_usage,
  SETUP_VALUE3_USAGE  = x_setup_value3_usage,
  SETUP_VALUE4_USAGE  = x_setup_value4_usage,
  SETUP_VALUE5_USAGE  = x_setup_value5_usage,
        creation_date         = x_creation_date       ,
        last_update_date      = x_last_update_date    ,
        last_updated_by       = x_last_updated_by     ,
        last_update_login     = x_last_update_login
    WHERE
    context_id = x_context_id;

    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;

END  jai_pa_setup_ctx_pkg  ;

/
