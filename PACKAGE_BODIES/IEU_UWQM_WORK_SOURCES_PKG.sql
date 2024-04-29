--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_WORK_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_WORK_SOURCES_PKG" as
/* $Header: IEUWRWSB.pls 120.1 2005/06/15 22:16:43 appldev  $ */

procedure insert_row(
x_rowid in out NOCOPY Varchar2,
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL

) is
  cursor C is select ROWID from IEU_UWQM_WORK_SOURCES_B
    where WS_ID = p_ws_id;

--  l_ws_id  number;

  begin

--    select IEU_UWQM_WORK_SOURCES_B_S1.NEXTVAL into l_ws_id from sys.dual;

    insert into IEU_UWQM_WORK_SOURCES_B(
    ws_id,
    ws_type,
    distribute_to,
    distribute_from,
    distribution_function,
    not_valid_flag,
    object_code,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ws_code,
    ws_enable_profile_option,
    application_id,
    active_flag
    )
    VALUES(
    p_ws_id,
    p_ws_type,
    p_distribute_to,
    p_distribute_from,
    p_distribution_function,
    p_not_valid_flag,
    p_object_code,
    1,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id,
    p_ws_code,
    p_ws_enable_profile_option,
    p_application_id,
    p_active_flag
    );

    insert into IEU_UWQM_WORK_SOURCES_TL (
    ws_id,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ws_name,
    ws_description,
    LANGUAGE,
    SOURCE_LANG
    ) select
    p_ws_id,
    1,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id,
    p_ws_name,
    p_ws_description,
    l.language_code,
    userenv('LANG')
    from fnd_languages l
    where l.installed_flag in ('I', 'B')
    and not exists
    (select null from ieu_uwqm_work_sources_tl t
    where t.ws_id = p_ws_id
    and t.language = l.language_code);

    open c;
    fetch c into x_rowid;
      if (c%notfound) then
         close c;
        raise no_data_found;
      end if;
    close c;

END INSERT_ROW;


procedure lock_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_object_version_number in number
) is
  cursor c is
     select object_version_number, ws_type, distribute_to, distribute_from,
     distribution_function, not_valid_flag, object_code, ws_enable_profile_option, application_id
     from ieu_uwqm_work_sources_b
     where ws_id = p_ws_id
     for update of ws_id nowait;
     recinfo c%rowtype;

  cursor c1 is
     select ws_name, ws_description,
     decode(language, userenv('LANG'), 'Y', 'N') BASELANG
     from ieu_uwqm_work_sources_tl
     where ws_id = p_ws_id
     and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
     for update of ws_id nowait;

  begin
    open c;
    fetch c into recinfo;

    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;

    close c;

    if ((recinfo.object_version_number = p_object_version_number)
       AND (recinfo.ws_type = p_ws_type)
       AND (recinfo.distribute_to = p_distribute_to)
       AND (recinfo.distribute_from = p_distribute_from)
       AND (recinfo.distribution_function = p_distribution_function)
       AND (recinfo.not_valid_flag = p_not_valid_flag)
       AND (recinfo.object_code = p_object_code)
       AND (recinfo.ws_enable_profile_option = p_ws_enable_profile_option)
       AND (recinfo.application_id = p_application_id))
    then
      null;
    else
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    end if;

    for tlinfo in c1 loop
      if (tlinfo.BASELANG = 'Y') then
        if ((tlinfo.ws_name = p_ws_name)
           and (tlinfo.ws_description = p_ws_description))
        then
           null;
        else
           fnd_message.set_name('FND','FORM_RECORD_CHANGED');
           app_exception.raise_exception;
        end if;
      end if;
    end loop;
    return;

END LOCK_ROW;

procedure update_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
) is

l_active_flag varchar2(1);
begin
   begin
      select active_flag
      into l_active_flag
      from ieu_uwqm_work_sources_b
      where ws_id = p_ws_id;
   exception
      when others then
        l_active_flag := null;
   end;

   if l_active_flag is null
   then
      l_active_flag := p_active_flag;
   end if;

   /****** Old code ******
   if p_active_flag is null then
      begin
        select active_flag
        into l_active_flag
        from ieu_uwqm_work_sources_b
        where ws_id = p_ws_id;
        exception when others then null;
      end;
   elsif p_active_flag is not null then
      l_active_flag := p_active_flag;
   end if;
   *********************/

   update IEU_UWQM_WORK_SOURCES_B set
   object_version_number = object_version_number+1,
   ws_type = p_ws_type,
   distribute_to = p_distribute_to,
   distribute_from = p_distribute_from,
   distribution_function = p_distribution_function,
   not_valid_flag = p_not_valid_flag,
   object_code = p_object_code,
   last_update_date = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.login_id,
   ws_enable_profile_option = p_ws_enable_profile_option,
   application_id = p_application_id,
   active_flag = l_active_flag
   where ws_id = p_ws_id;


   if (sql%notfound) then
      raise no_data_found;
   end if;

   update IEU_UWQM_WORK_SOURCES_TL set
   ws_name = p_ws_name,
   ws_description = p_ws_description,
   last_update_date = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.login_id,
   object_version_number = object_version_number+1,
   source_lang = userenv('LANG')
   where ws_id = p_ws_id
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;

procedure delete_row(
p_ws_id in number
) is
begin
  delete from IEU_UWQM_WORK_SOURCES_TL
  where ws_id = p_ws_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

  delete from ieu_uwqm_work_sources_b
  where ws_id = p_ws_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

END DELETE_ROW;


procedure add_language is

begin
  delete from IEU_UWQM_WORK_SOURCES_TL t
  where not exists
     (select null
      from ieu_uwqm_work_sources_b b
       where b.ws_id = t.ws_id);

  update ieu_uwqm_work_sources_tl t
  set (ws_name, ws_description)
      = (select b.ws_name,
         b.ws_description
         from ieu_uwqm_work_sources_tl b
         where b.ws_id = t.ws_id
         and b.language= t.source_lang)
   where ( t.ws_id, t.language )
   in (select subt.ws_id, subt.language
       from ieu_uwqm_work_sources_tl subb, ieu_uwqm_work_sources_tl subt
       where subb.ws_id = subt.ws_id
        and subb.language = subt.source_lang
        and (subb.ws_name <> subt.ws_name
            or subb.ws_description <> subt.ws_description));

   insert into ieu_uwqm_work_sources_tl(
    ws_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ws_name,
    ws_DESCription,
    LANGUAGE,
    SOURCE_LANG
    ) select
    b.ws_id,
    b.object_version_number,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.login_id,
    b.ws_name,
    b.ws_description,
    l.language_code,
    b.source_lang
    from ieu_uwqm_work_sources_tl b, fnd_languages l
    where l.installed_flag in ('I', 'B')
    and b.language= userenv('LANG')
    and not exists
        (select null from ieu_uwqm_work_sources_tl t
         where t.ws_id = b.ws_id
        and t.language = l.language_code);

END ADD_LANGUAGE;


procedure load_row(
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
) is

  l_user_id number := 0;
  l_rowid varchar2(50);

begin
  if (p_owner = 'SEED') then
     l_user_id := 1;
  end if;
  begin
    update_row(
    p_ws_id => p_ws_id,
    p_ws_type => p_ws_type,
    p_distribute_to => p_distribute_to,
    p_distribute_from => p_distribute_from,
    p_distribution_function => p_distribution_function,
    p_not_valid_flag => p_not_valid_flag,
    p_object_code => p_object_code,
    p_ws_name => p_ws_name,
    p_ws_description => p_ws_description,
    p_ws_enable_profile_option => p_ws_enable_profile_option,
    p_application_id => p_application_id,
    p_active_flag => p_active_flag);

     if (sql%notfound) then
        raise no_data_found;
     end if;

     exception when no_data_found then
     insert_row(
      x_rowid => l_rowid,
      p_ws_id => p_ws_id,
      p_ws_type => p_ws_type,
      p_distribute_to => p_distribute_to,
      p_distribute_from => p_distribute_from,
      p_distribution_function => p_distribution_function,
      p_not_valid_flag => p_not_valid_flag,
      p_object_code => p_object_code,
      p_ws_name => p_ws_name,
      p_ws_description => p_ws_description,
      p_ws_code => p_ws_code,
      p_ws_enable_profile_option => p_ws_enable_profile_option,
      p_application_id => p_application_id,
      p_active_flag => p_active_flag);

  end;

END LOAD_ROW;

procedure translate_row(
p_ws_id in number,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2
) is
begin
  update IEU_UWQM_WORK_SOURCES_TL
  set source_lang = userenv('LANG'),
  ws_name = p_ws_name,
  ws_description = p_ws_description,
  last_update_date = sysdate,
  --last_updated_by = decode(p_owner, 'SEED', 1, 0),
  last_updated_by = fnd_load_util.owner_id(p_owner),
  last_update_login = 0
  where (ws_id = p_ws_id)
  and (userenv('LANG') IN (LANGUAGE, SOURCE_LANG));

  if (sql%notfound) then
     raise no_data_found;
  end if;

END TRANSLATE_ROW;

procedure load_seed_row(
p_upload_mode in varchar2,
p_ws_id in number,
p_ws_type in varchar2,
p_distribute_to in varchar2,
p_distribute_from in varchar2,
p_distribution_function in varchar2,
p_not_valid_flag in varchar2,
p_object_code in varchar2,
p_ws_name in varchar2,
p_ws_description in varchar2,
p_owner in varchar2,
p_ws_code in varchar2,
p_ws_enable_profile_option varchar2,
p_application_id  number,
p_active_flag varchar2 DEFAULT NULL
) is
begin

if (p_upload_mode = 'NLS') then
  translate_row(
    p_ws_id,
    p_ws_name,
    p_ws_description,
    p_owner);
else
  load_row(
    p_ws_id,
    p_ws_type,
    p_distribute_to,
    p_distribute_from,
    p_distribution_function,
    p_not_valid_flag,
    p_object_code,
    p_ws_name,
    p_ws_description,
    p_owner,
    p_ws_code,
    p_ws_enable_profile_option,
    p_application_id,
    p_active_flag);
end if;

end load_seed_row;

END IEU_UWQM_WORK_SOURCES_PKG;

/
