--------------------------------------------------------
--  DDL for Package Body JAI_RGM_LKPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RGM_LKPS_PKG" AS
/* $Header: jai_rgm_lkps_th.plb 120.3 2006/01/20 16:14:03 avallabh ship $ */

PROCEDURE Load_Row(  x_regime_code                 VARCHAR2,
                     x_attribute_type_code         VARCHAR2,
                     x_attribute_code              VARCHAR2,
                     x_attribute_value             VARCHAR2,
                     x_display_value               VARCHAR2,
                     x_default_record              VARCHAR2,
                     x_owner                       VARCHAR2,
		     x_last_update_date            VARCHAR2, /* 4967445 */
                     x_force_edits                 VARCHAR2 ) IS
    v_creation_date date;
    v_rowid rowid := null;
    v_user_id     NUMBER := fnd_load_util.owner_id(x_owner);
    vf_ludate   DATE := to_date(x_last_update_date, 'DD-MM-YYYY HH:MI:SS');
    vd_ludate   DATE;

  BEGIN

    -- validate input parameters
     IF(X_REGIME_CODE is NULL)
     then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Load_Row: Required data is not provided.');
      app_exception.raise_exception;
     end if;

/* Commented the below since we got the user_id from fnd_load_util
    if (X_OWNER = 'SEED') then
      v_user_id := 1;
    end if; */

    DECLARE

    CURSOR cur_creation_date
    IS
    select creation_date, last_update_date
    from   jai_rgm_lookups
    where  regime_code = x_regime_code
    and    attribute_type_code = x_attribute_type_code
    and    attribute_code      = x_attribute_code
    and    nvl(attribute_value, 0)  = nvl(ltrim(rtrim(x_attribute_value)), 0) ;

    BEGIN
      /* Check if the row exists in the database. If it does, retrieves the creation date for update_row. */
      OPEN cur_creation_date ;
      FETCH cur_creation_date    into   v_creation_date, vd_ludate ;
      IF cur_creation_date%NOTFOUND THEN
        raise NO_DATA_FOUND ;
      END IF ;
      CLOSE cur_creation_date;

	/* Removed the check for userid and added check using last_update_date
       for bug 4967445 */
      /* Update only if force_edits is 'Y' or if vf_ludate > vd_ludate */

     if ( vf_ludate > vd_ludate or X_Force_Edits = 'Y' ) then
         -- update row if present
       jai_rgm_lkps_pkg.Update_Row(
          X_Rowid                => v_rowid,
          X_regime_code          => X_regime_code ,
          x_attribute_type_code  => x_attribute_type_code ,
          x_attribute_code       => x_attribute_code      ,
          x_attribute_value      => x_attribute_value     ,
          x_display_value        => x_display_value       ,
          x_default_record       => x_default_record      ,
          x_creation_date         => v_creation_date,
          X_last_update_date      => vf_ludate,
          X_last_updated_by       => v_user_id,
          X_last_update_login     => 0);
     end if;
       EXCEPTION
        when NO_DATA_FOUND then
          jai_rgm_lkps_pkg.Insert_Row(
          X_Rowid                => v_rowid,
          X_regime_code          => X_regime_code ,
          x_attribute_type_code  => x_attribute_type_code ,
          x_attribute_code       => x_attribute_code      ,
          x_attribute_value      => x_attribute_value     ,
          x_display_value        => x_display_value       ,
          x_default_record       => x_default_record      ,
          X_last_update_date     => vf_ludate,
          X_last_updated_by      => v_user_id,
          X_creation_date        => sysdate,
          X_created_by           => v_user_id,
          X_last_update_login    => 0) ;
    END;
    EXCEPTION
     WHEN OTHERS then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Error in Load_Row: jai_rgm_lkps_pkg');
      app_exception.raise_exception;
  END Load_Row;

 PROCEDURE Insert_Row(
                     X_Rowid            IN OUT NOCOPY rowid,
                     X_regime_code          VARCHAR2,
                     x_attribute_type_code  VARCHAR2,
                     x_attribute_code       VARCHAR2,
                     x_attribute_value      VARCHAR2,
                     x_display_value        VARCHAR2,
                     x_default_record       VARCHAR2,
                     x_creation_date        DATE ,
                     X_Last_Update_Date     DATE,
                     X_Last_Updated_By      NUMBER,
                     X_Created_by           NUMBER,
                     X_Last_Update_Login    NUMBER) IS
     CURSOR C_LOOKUP_ID IS SELECT JAI_RGM_LOOKUPS_S.nextval FROM dual;
     X_lookup_id NUMBER ;
  BEGIN

   OPEN C_LOOKUP_ID;
   FETCH C_LOOKUP_ID INTO X_lookup_id;
   CLOSE C_LOOKUP_ID;

  INSERT INTO JAI_RGM_LOOKUPS(
                lookup_id           ,
                regime_code         ,
                attribute_type_code ,
                attribute_code      ,
                attribute_value     ,
                display_value       ,
                default_record      ,
                creation_date       ,
                created_by          ,
                last_update_date    ,
                last_update_login   ,
                last_updated_by     )
    SELECT
             X_lookup_id           ,
             X_regime_code         ,
             X_attribute_type_code ,
             X_attribute_code      ,
             X_attribute_value     ,
             X_display_value       ,
             X_default_record      ,
             X_Creation_Date       ,
             X_Created_by          ,
             X_Last_Update_Date    ,
             X_Last_Update_Login   ,
             X_Last_Updated_By
    FROM  DUAL ;

     if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Insert_Row;

PROCEDURE Update_Row(X_Rowid                   IN OUT NOCOPY rowid,
                     X_regime_code             VARCHAR2,
                     x_attribute_type_code     VARCHAR2,
                     x_attribute_code          VARCHAR2,
                     x_attribute_value         VARCHAR2,
                     x_display_value           VARCHAR2,
                     x_default_record          VARCHAR2,
                     x_creation_date           DATE,
                     X_last_update_date        DATE,
                     X_last_updated_by         NUMBER,
                     X_last_update_login       NUMBER)
 IS
  BEGIN
    UPDATE JAI_RGM_LOOKUPS
    SET
        regime_code           = x_regime_code          ,
        attribute_type_code   = x_attribute_type_code  ,
        attribute_code        = x_attribute_code       ,
        attribute_value       = x_attribute_value      ,
        display_value         = x_display_value        ,
        default_record        = x_default_record       ,
        creation_date         = x_creation_date        ,
        last_update_date      = x_last_update_date     ,
        last_update_login     = x_last_update_login    ,
        last_updated_by       = x_last_updated_by
    WHERE
           regime_code = x_regime_code
    and    attribute_type_code = x_attribute_type_code
    and    attribute_code      = x_attribute_code
    and    nvl(attribute_value, 0)     = nvl(ltrim(rtrim(x_attribute_value)), 0) ; --4477004


    if (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
    end if;

  END Update_Row;

END  jai_rgm_lkps_pkg ;

/
