--------------------------------------------------------
--  DDL for Package Body JAI_PA_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_PREF_PKG" as
/* $Header: jai_pa_pref_pkg.plb 120.0.12000000.1 2007/10/24 18:20:34 rallamse noship $ */
/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */



PROCEDURE Load_Row(
                     x_distribution_rule   varchar2
                   , x_context_id          varchar2
                   , x_owner               varchar2
                   , x_preference          varchar2
                   , x_last_update_date    varchar2
                   , x_force_edits         varchar2
                  )   IS
    lx_rowid rowid := null;
    ln_user_id     NUMBER := fnd_load_util.owner_id(x_owner);
    vf_ludate   DATE := to_date(x_last_update_date, 'DD-MM-YYYY HH:MI:SS');
    lr_setup_preference_rec  jai_pa_setup_preferences%rowtype;

  BEGIN
    -- validate input parameters
     IF(x_distribution_rule is NULL or x_context_id is null or x_last_update_date is null ) then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Load_Row: Required data is not provided.');
      app_exception.raise_exception;
      end if;

      lr_setup_preference_rec.last_update_login  := 0;
    DECLARE

      CURSOR cur_get_rec IS
      select *
      from   jai_pa_setup_preferences
      where  distribution_rule = x_distribution_rule
      and    context_id        = x_context_id;

    BEGIN
      /* Check if the row exists in the database. If it does, retrieves the creation date for update_row. */
       OPEN cur_get_rec;
       FETCH cur_get_rec    into      lr_setup_preference_rec ;
       IF cur_get_rec%NOTFOUND THEN
           raise NO_DATA_FOUND ;
       END IF;
       CLOSE cur_get_rec;

     /* Removed the check for userid and added check using last_update_date
    for bug 4967445 */

       /* Update only if force_edits is 'Y' or if vf_ludate > vd_ludate */
    if ( vf_ludate > lr_setup_preference_rec.last_update_date or x_force_edits = 'Y' ) then
         -- update row if present
      lr_setup_preference_rec.last_update_date   := vf_ludate ;
      lr_setup_preference_rec.last_updated_by    := ln_user_id;
      lr_setup_preference_rec.distribution_rule  := x_distribution_rule;
      lr_setup_preference_rec.context_id         := x_context_id;
      lr_setup_preference_rec.preference         := x_preference;

       jai_pa_pref_pkg.update_row
                      ( lr_setup_preference_rec);

    end if;
      exception
        when NO_DATA_FOUND then

        lr_setup_preference_rec.distribution_rule  := x_distribution_rule;
        lr_setup_preference_rec.context_id         := x_context_id;
        lr_setup_preference_rec.preference         := x_preference;
        lr_setup_preference_rec.created_by         := ln_user_id;
        lr_setup_preference_rec.creation_date      := sysdate;
        lr_setup_preference_rec.last_update_date   := sysdate;
        lr_setup_preference_rec.last_updated_by    := ln_user_id;

         jai_pa_pref_pkg.insert_row
         (lr_setup_preference_rec
         ,lx_rowid
         ,lr_setup_preference_rec.setup_preference_id
         ) ;
    end;
   exception
      WHEN OTHERS then
      fnd_message.set_name('JA', 'JAI_VALUE_MESSAGE');
      fnd_message.set_token('JAI_MESSAGE', 'Error in Load_Row: jai_pa_pref_pkg'||sqlerrm);
      app_exception.raise_exception;
  END load_row;

 procedure insert_row
                  (
                     x_setup_preference_rec  in jai_pa_setup_preferences%rowtype
                   , x_rowid                in out nocopy rowid
                   , x_setup_preference_id  in out nocopy jai_pa_setup_preferences.setup_preference_id%type
                  )
  is
     cursor c_get_setup_prefrence_id
     is
     select jai_pa_setup_preferences_s.nextval
     from dual;

  begin
     if x_setup_preference_id is null then
       OPEN   c_get_setup_prefrence_id;
       FETCH  c_get_setup_prefrence_id INTO x_setup_preference_id;
       CLOSE  c_get_setup_prefrence_id;
     end if;

    insert into jai_pa_setup_preferences
                (
                 setup_preference_id
                ,distribution_rule
                ,context_id
                ,preference
                ,created_by
                ,creation_date
                ,last_update_login
                ,last_update_date
                ,last_updated_by
                )
    values
                (
                  x_setup_preference_id
                , x_setup_preference_rec.distribution_rule
                , x_setup_preference_rec.context_id
                , x_setup_preference_rec.preference
                , x_setup_preference_rec.created_by
                , x_setup_preference_rec.creation_date
                , x_setup_preference_rec.last_update_login
                , x_setup_preference_rec.last_update_date
                , x_setup_preference_rec.last_updated_by
                );

  end insert_row;

  procedure update_row
                    ( x_setup_preference_rec   in    jai_pa_setup_preferences%rowtype
                    )
  is
  begin

    update jai_pa_setup_preferences
    set
         distribution_rule      = x_setup_preference_rec.distribution_rule
        ,context_id             = x_setup_preference_rec.context_id
        ,preference             = x_setup_preference_rec.preference
        ,created_by             = x_setup_preference_rec.created_by
        ,creation_date          = x_setup_preference_rec.creation_date
        ,last_update_login      = x_setup_preference_rec.last_update_login
        ,last_update_date       = x_setup_preference_rec.last_update_date
        ,last_updated_by        = x_setup_preference_rec.last_updated_by
    where
        (
          (   distribution_rule     = x_setup_preference_rec.distribution_rule
          and   context_id            = x_setup_preference_rec.context_id
          )
        );
    if (sql%notfound) then
      raise no_data_found;
    end if;

  end update_row;

  procedure delete_row (x_setup_preference_id   in  jai_pa_setup_preferences.setup_preference_id%type)
  is
  begin
    delete jai_pa_setup_preferences
    where  setup_preference_id = x_setup_preference_id;
  end delete_row;

end  jai_pa_pref_pkg  ;

/
