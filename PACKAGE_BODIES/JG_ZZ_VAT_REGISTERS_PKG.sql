--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_REGISTERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_REGISTERS_PKG" as
/*$Header: jgzzvrgb.pls 120.1 2006/06/23 12:26:17 brathod ship $*/
/* CHANGE HISTORY ------------------------------------------------------------------------------------------
DATE            AUTHOR       VERSION       BUG NO.         DESCRIPTION
(DD/MM/YYYY)    (UID)
------------------------------------------------------------------------------------------------------------
23/6/2006       BRATHOD      120.1         5166688         Modified the signature of INSERT_ROW procedure in
                                                           to return rowid to caller of API by adding out
                                                           parameter in the call. Refer bug# 5166688 for details
-----------------------------------------------------------------------------------------------------------*/

  procedure insert_row
              ( x_record                            jg_zz_vat_registers_vl%rowtype
              , x_vat_register_id in  out nocopy    jg_zz_vat_registers_b.vat_register_id%type
              , x_row_id          out     nocopy    rowid
              )
  is


  cursor c_gen_vat_register_id
  is
  select jg_zz_vat_registers_b_s.nextval
  from   dual;

  begin

    if x_record.vat_register_id is null then
      open  c_gen_vat_register_id;
      fetch c_gen_vat_register_id into x_vat_register_id;
      close c_gen_vat_register_id;
    else
      x_vat_register_id := x_record.vat_register_id;
    end if;

    insert into jg_zz_vat_registers_b
              (  vat_register_id
              ,  vat_reporting_entity_id
              ,  register_type
              ,  effective_from_date
              ,  effective_to_date
              ,  created_by
              ,  creation_date
              ,  last_updated_by
              ,  last_update_date
              ,  last_update_login
              )
    values    (  x_vat_register_id
              ,  x_record.vat_reporting_entity_id
              ,  x_record.register_type
              ,  x_record.effective_from_date
              ,  x_record.effective_to_date
              ,  x_record.created_by
              ,  x_record.creation_date
              ,  x_record.last_updated_by
              ,  x_record.last_update_date
              ,  x_record.last_update_login
              ) returning rowid into x_row_id;

    insert into jg_zz_vat_registers_tl
              (  vat_register_id
              ,  register_name
              ,  language
              ,  source_lang
              ,  created_by
              ,  creation_date
              ,  last_updated_by
              ,  last_update_date
              ,  last_update_login
              )
              (
              select
                 x_vat_register_id
              ,  x_record.register_name
              ,  fndlang.language_code
              ,  userenv('LANG')
              ,  x_record.created_by
              ,  x_record.creation_date
              ,  x_record.last_updated_by
              ,  x_record.last_update_date
              ,  x_record.last_update_login
              from  fnd_languages fndlang
              where fndlang.installed_flag in ('I','B')
              and   not exists (select 1
                                from   jg_zz_vat_registers_tl jzvrgtl
                                where  jzvrgtl.vat_register_id = x_vat_register_id
                                and    jzvrgtl.language = fndlang.language_code
                                )
              );
  exception
    when others then
    x_vat_register_id := null;
    x_row_id := null;
    raise;
  end insert_row ;

  /*------------------------------------------------------------------------------------------------------------*/

  procedure lock_row (  x_record   jg_zz_vat_registers_vl%rowtype )
  is

    lr_locked_b_row   jg_zz_vat_registers_b%rowtype;
    lr_locked_tl_row  jg_zz_vat_registers_tl%rowtype;
    lv_usr_env_lang     fnd_languages.language_code%type;

    cursor c_locked_b_row
    is
    select  *
    from    jg_zz_vat_registers_b
    where   vat_register_id = x_record.vat_register_id
    for update nowait;

    cursor c_locked_tl_row
    is
    select  *
    from    jg_zz_vat_registers_tl
    where   vat_register_id = x_record.vat_register_id
    and     ( language    = lv_usr_env_lang
           or source_lang = lv_usr_env_lang
            )
    for update nowait;

  begin

    lv_usr_env_lang := userenv('LANG');

    open c_locked_b_row;
    fetch c_locked_b_row into lr_locked_b_row;

    if (c_locked_b_row%notfound) then
      close c_locked_b_row;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;

    close c_locked_b_row;

    if (    nvl(lr_locked_b_row.register_type,'X$') = nvl( x_record.register_type,'X$')
       and  nvl(lr_locked_b_row.effective_from_date, sysdate) = nvl(x_record.effective_from_date, sysdate)
       and  nvl(lr_locked_b_row.effective_to_date , sysdate) = nvl(x_record.effective_to_date, sysdate)
    )
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    open  c_locked_tl_row;
    fetch c_locked_tl_row into lr_locked_tl_row;
    close c_locked_tl_row;

      if lr_locked_tl_row.language = lr_locked_tl_row.source_lang then
        if  nvl(lr_locked_tl_row.register_name, 'X$') = nvl(x_record.register_name, 'X$') then
          null;
        else
          fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
          app_exception.raise_exception;
        end if;
      end if;

    return;
  end lock_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure update_row (x_record  jg_zz_vat_registers_vl%rowtype)
  is

  lv_usr_env_lang     fnd_languages.language_code%type;

  begin

    lv_usr_env_lang := userenv('LANG');

    update  jg_zz_vat_registers_b
    set     vat_reporting_entity_id=     x_record.vat_reporting_entity_id
          , register_type          =     x_record.register_type
          , effective_from_date    =     x_record.effective_from_date
          , effective_to_date      =     x_record.effective_to_date
          , last_updated_by        =     x_record.last_updated_by
          , last_update_date       =     x_record.last_update_date
          , last_update_login      =     x_record.last_update_login
    where vat_register_id          =     x_record.vat_register_id;

    update   jg_zz_vat_registers_tl
    set      register_name         =    x_record.register_name
           , source_lang           =    lv_usr_env_lang
           , last_updated_by       =    x_record.last_updated_by
           , last_update_date      =    x_record.last_update_date
           , last_update_login     =    x_record.last_update_login
    where  vat_register_id         =    x_record.vat_register_id
    and   ( language               =    lv_usr_env_lang
         or source_lang            =    lv_usr_env_lang
          ) ;

  end update_row;

/*------------------------------------------------------------------------------------------------------------*/

  procedure delete_row (x_vat_register_id jg_zz_vat_registers_b.vat_register_id%type)
  is
  begin
    delete from jg_zz_vat_registers_b
    where vat_register_id = x_vat_register_id;

    delete from jg_zz_vat_registers_tl
    where vat_register_id = x_vat_register_id;

  end delete_row;

/*------------------------------------------------------------------------------------------------------------*/


procedure add_language is

begin

  delete from jg_zz_vat_registers_tl T
  where not exists (
    select NULL
    from jg_zz_vat_registers_b B
    where B.VAT_REGISTER_ID = T.VAT_REGISTER_ID
  );

  update jg_zz_vat_registers_tl T
  set REGISTER_NAME = (select
                             B.REGISTER_NAME
                      from jg_zz_vat_registers_tl B
                      where B.vAT_REGISTER_ID = T.VAT_REGISTER_ID
                      and B.LANGUAGE = T.SOURCE_LANG)
  where (T.VAT_REGISTER_ID, T.LANGUAGE )  in
       (select subt.vat_register_id, subt.language
        from jg_zz_vat_registers_tl SUBB, jg_zz_vat_registers_tl SUBT
        where SUBB.VAT_REGISTER_ID = SUBT.VAT_REGISTER_ID
        and SUBB.LANGUAGE = SUBT.SOURCE_LANG
        and (SUBB.REGISTER_NAME <> SUBT.REGISTER_NAME
            or (SUBB.REGISTER_NAME is null and SUBT.REGISTER_NAME is not null)
            or (SUBB.REGISTER_NAME is not null and SUBT.REGISTER_NAME is null)
            )
       );

  insert into jg_zz_vat_registers_tl (
    VAT_REGISTER_ID,
    REGISTER_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.VAT_REGISTER_ID,
    B.REGISTER_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from jg_zz_vat_registers_tl b, fnd_languages l
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from jg_zz_vat_registers_tl T
    where T.VAT_REGISTER_ID = B.VAT_REGISTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end add_language;

procedure LOAD_ROW (
  x_VAT_REGISTER_ID              in  NUMBER,
  x_VAT_REPORTING_ENTITY_ID      in  NUMBER,
  x_REGISTER_TYPE                in  VARCHAR2,
  x_REGISTER_NAME                in  VARCHAR2,
  x_EFFECTIVE_FROM_DATE          in  DATE,
  x_EFFECTIVE_TO_DATE            in  DATE,
  x_OWNER                        in  VARCHAR2
) is

  l_user_id       number;
  l_row_id        rowid;
  l_table_rec     jg_zz_vat_registers_vl%rowtype;
  ln_vat_register_id  number;

begin
  l_user_id := 0;

  if (x_OWNER = 'SEED') then
    l_user_id := 1;
  end if;

  l_table_rec.vat_register_id          := x_vat_register_id;
  l_table_rec.vat_reporting_entity_id  := x_vat_reporting_entity_id      ;
  l_table_rec.register_type            := x_register_type      ;
  l_table_rec.register_name            := x_register_name      ;
  l_table_rec.effective_from_date      := x_effective_from_date;
  l_table_rec.effective_to_date        := x_effective_to_date  ;
  l_table_rec.last_update_date         := sysdate   ;
  l_table_rec.last_updated_by          := l_user_id    ;
  l_table_rec.creation_date            := sysdate      ;
  l_table_rec.created_by               := l_user_id;
  l_table_rec.last_update_login        := 0  ;


  jg_zz_vat_registers_pkg.UPDATE_ROW (
    x_record =>   l_table_rec
  );

exception
  when NO_DATA_FOUND then
    jg_zz_vat_registers_pkg.INSERT_ROW (
       x_record          => l_table_rec
      ,x_vat_register_id => ln_vat_register_id
      ,x_row_id          => l_row_id
    );

end LOAD_ROW;


procedure TRANSLATE_ROW (
  X_VAT_REGISTER_ID   in NUMBER,
  X_REGISTER_NAME     in VARCHAR2,
  X_OWNER             in VARCHAR2
) is
begin
  update jg_zz_vat_registers_tl set
    REGISTER_NAME = X_REGISTER_NAME,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where VAT_REGISTER_ID = X_VAT_REGISTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

end jg_zz_vat_registers_pkg;

/
