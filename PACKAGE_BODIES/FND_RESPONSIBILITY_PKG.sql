--------------------------------------------------------
--  DDL for Package Body FND_RESPONSIBILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RESPONSIBILITY_PKG" as
/* $Header: AFSCRSPB.pls 120.4.12010000.4 2010/03/23 18:42:34 jvalenti ship $ */


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_GROUP_APPLICATION_ID in NUMBER,
  X_REQUEST_GROUP_ID in NUMBER,
  X_VERSION in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_RESPONSIBILITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_RESPONSIBILITY
    where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and APPLICATION_ID = X_APPLICATION_ID
    ;
begin
  insert into FND_RESPONSIBILITY (
    WEB_HOST_NAME,
    WEB_AGENT_NAME,
    APPLICATION_ID,
    RESPONSIBILITY_ID,
    DATA_GROUP_APPLICATION_ID,
    DATA_GROUP_ID,
    MENU_ID,
    START_DATE,
    END_DATE,
    GROUP_APPLICATION_ID,
    REQUEST_GROUP_ID,
    VERSION,
    RESPONSIBILITY_KEY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_WEB_HOST_NAME,
    X_WEB_AGENT_NAME,
    X_APPLICATION_ID,
    X_RESPONSIBILITY_ID,
    X_DATA_GROUP_APPLICATION_ID,
    X_DATA_GROUP_ID,
    X_MENU_ID,
    X_START_DATE,
    X_END_DATE,
    X_GROUP_APPLICATION_ID,
    X_REQUEST_GROUP_ID,
    X_VERSION,
    X_RESPONSIBILITY_KEY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  -- Added for Function Security Cache Invalidation Project
  fnd_function_security_cache.insert_resp(X_RESPONSIBILITY_ID, X_APPLICATION_ID);

  insert into FND_RESPONSIBILITY_TL (
    APPLICATION_ID,
    RESPONSIBILITY_ID,
    RESPONSIBILITY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_RESPONSIBILITY_ID,
    X_RESPONSIBILITY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_RESPONSIBILITY_TL T
    where T.RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and T.APPLICATION_ID = X_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);


  -- Added to maintain "ANY/ALL" diamonds of roles for user/resps.
  fnd_user_resp_groups_api.sync_roles_all_secgrps(
                   X_RESPONSIBILITY_ID,
                   X_APPLICATION_ID,
                   X_RESPONSIBILITY_KEY,
                   X_START_DATE,
                   X_END_DATE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


end INSERT_ROW;

--Overloaded!

procedure TRANSLATE_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_DESCRIPTION   		in 	VARCHAR2,
  X_OWNER                       in	VARCHAR2) is
  appl_id number;
  resp_id number;
begin

 fnd_responsibility_pkg.translate_row(
	X_APP_SHORT_NAME => X_APP_SHORT_NAME,
	X_RESP_KEY => X_RESP_KEY,
	X_RESPONSIBILITY_NAME => X_RESPONSIBILITY_NAME,
	X_DESCRIPTION => X_DESCRIPTION,
        X_OWNER => X_OWNER,
        x_custom_mode => null,
        x_last_update_date => null);

end TRANSLATE_ROW;

-- ### OVERLOADED!
procedure TRANSLATE_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_DESCRIPTION   		in 	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_CUSTOM_MODE			in	VARCHAR2,
  X_LAST_UPDATE_DATE		in	VARCHAR2) is

  appl_id number;
  resp_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from fnd_responsibility_tl
    where (RESPONSIBILITY_ID, APPLICATION_ID)
       = (select r.responsibility_id, r.application_id
          from   fnd_responsibility r, fnd_application a
          where  r.responsibility_key = X_RESP_KEY
          and    r.application_id = a.application_id
          and    a.application_short_name = X_APP_SHORT_NAME)
          and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
     update fnd_responsibility_tl set
      responsibility_name = nvl(X_RESPONSIBILITY_NAME, responsibility_name),
      DESCRIPTION         = nvl(X_DESCRIPTION, description),
      LAST_UPDATE_DATE    = f_ludate,
      LAST_UPDATED_BY     = f_luby,
      LAST_UPDATE_LOGIN   = 0,
      SOURCE_LANG         = userenv('LANG')
      where (RESPONSIBILITY_ID, APPLICATION_ID)
       = (select r.responsibility_id, r.application_id
          from   fnd_responsibility r, fnd_application a
          where  r.responsibility_key = X_RESP_KEY
          and    r.application_id = a.application_id
          and    a.application_short_name = X_APP_SHORT_NAME)
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

      -- Sync with WF --
      select application_id into appl_id
      from   fnd_application
      where  application_short_name = X_APP_SHORT_NAME;

      select responsibility_id into resp_id
      from   fnd_responsibility
      where  responsibility_key = X_RESP_KEY
      and    application_id = appl_id;

      fnd_responsibility_pkg.resp_synch(appl_id, resp_id);
   end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;


--Overloaded!!

procedure LOAD_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_ID		in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_DATA_GROUP_NAME		in	VARCHAR2,
  X_MENU_NAME			in	VARCHAR2,
  X_START_DATE			in	VARCHAR2,
  X_END_DATE			in	VARCHAR2,
  X_DESCRIPTION			in	VARCHAR2,
  X_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_REQUEST_GROUP_NAME		in	VARCHAR2,
  X_VERSION			in	VARCHAR2,
  X_WEB_HOST_NAME		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2 )
is
 begin
   fnd_responsibility_pkg.load_row(
	X_APP_SHORT_NAME => X_APP_SHORT_NAME,
	X_RESP_KEY => upper(X_RESP_KEY),
	X_RESPONSIBILITY_ID => X_RESPONSIBILITY_ID,
	X_RESPONSIBILITY_NAME => X_RESPONSIBILITY_NAME,
	X_OWNER => X_OWNER,
	X_DATA_GROUP_APP_SHORT_NAME => X_DATA_GROUP_APP_SHORT_NAME,
	X_DATA_GROUP_NAME => X_DATA_GROUP_NAME,
	X_MENU_NAME => X_MENU_NAME,
	X_START_DATE => X_START_DATE,
	X_END_DATE => X_END_DATE,
	X_DESCRIPTION => X_DESCRIPTION,
	X_GROUP_APP_SHORT_NAME => X_GROUP_APP_SHORT_NAME,
	X_REQUEST_GROUP_NAME => X_REQUEST_GROUP_NAME,
	X_VERSION => X_VERSION,
	X_WEB_HOST_NAME => X_WEB_HOST_NAME,
	X_WEB_AGENT_NAME => X_WEB_AGENT_NAME,
	x_custom_mode => '',
	x_last_update_date => '');

end LOAD_ROW;

--Overloaded!!

procedure LOAD_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_ID		in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_DATA_GROUP_NAME		in	VARCHAR2,
  X_MENU_NAME			in	VARCHAR2,
  X_START_DATE			in	VARCHAR2,
  X_END_DATE			in	VARCHAR2,
  X_DESCRIPTION			in	VARCHAR2,
  X_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_REQUEST_GROUP_NAME		in	VARCHAR2,
  X_VERSION			in	VARCHAR2,
  X_WEB_HOST_NAME		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2,
  X_CUSTOM_MODE			in	VARCHAR2,
  X_LAST_UPDATE_DATE		in	VARCHAR2 )
is
 begin
   fnd_responsibility_pkg.load_row(
        X_APP_SHORT_NAME => X_APP_SHORT_NAME,
        X_RESP_KEY => upper(X_RESP_KEY),
        X_RESPONSIBILITY_NAME => X_RESPONSIBILITY_NAME,
        X_OWNER => X_OWNER,
        X_DATA_GROUP_APP_SHORT_NAME => X_DATA_GROUP_APP_SHORT_NAME,
        X_DATA_GROUP_NAME => X_DATA_GROUP_NAME,
        X_MENU_NAME => X_MENU_NAME,
        X_START_DATE => X_START_DATE,
        X_END_DATE => X_END_DATE,
        X_DESCRIPTION => X_DESCRIPTION,
        X_GROUP_APP_SHORT_NAME => X_GROUP_APP_SHORT_NAME,
        X_REQUEST_GROUP_NAME => X_REQUEST_GROUP_NAME,
        X_VERSION => X_VERSION,
        X_WEB_HOST_NAME => X_WEB_HOST_NAME,
        X_WEB_AGENT_NAME => X_WEB_AGENT_NAME,
        x_custom_mode => X_CUSTOM_MODE, -- bug 5425214
        x_last_update_date => X_LAST_UPDATE_DATE); -- bug 5425214

end LOAD_ROW;


procedure LOCK_ROW (
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_GROUP_APPLICATION_ID in NUMBER,
  X_REQUEST_GROUP_ID in NUMBER,
  X_VERSION in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_RESPONSIBILITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      WEB_HOST_NAME,
      WEB_AGENT_NAME,
      DATA_GROUP_APPLICATION_ID,
      DATA_GROUP_ID,
      MENU_ID,
      START_DATE,
      END_DATE,
      GROUP_APPLICATION_ID,
      REQUEST_GROUP_ID,
      VERSION,
      RESPONSIBILITY_KEY
    from FND_RESPONSIBILITY
    where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and APPLICATION_ID = X_APPLICATION_ID
    for update of RESPONSIBILITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RESPONSIBILITY_NAME,
      DESCRIPTION
    from FND_RESPONSIBILITY_TL
    where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and APPLICATION_ID = X_APPLICATION_ID
    and LANGUAGE = userenv('LANG')
    for update of RESPONSIBILITY_ID nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.WEB_HOST_NAME = X_WEB_HOST_NAME)
           OR ((recinfo.WEB_HOST_NAME is null) AND (X_WEB_HOST_NAME is null)))
      AND ((recinfo.WEB_AGENT_NAME = X_WEB_AGENT_NAME)
           OR ((recinfo.WEB_AGENT_NAME is null) AND (X_WEB_AGENT_NAME is null)))
      AND (recinfo.DATA_GROUP_APPLICATION_ID = X_DATA_GROUP_APPLICATION_ID)
      AND (recinfo.DATA_GROUP_ID = X_DATA_GROUP_ID)
      AND (recinfo.MENU_ID = X_MENU_ID)
      AND (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.GROUP_APPLICATION_ID = X_GROUP_APPLICATION_ID)
           OR ((recinfo.GROUP_APPLICATION_ID is null) AND (X_GROUP_APPLICATION_ID is null)))
      AND ((recinfo.REQUEST_GROUP_ID = X_REQUEST_GROUP_ID)
           OR ((recinfo.REQUEST_GROUP_ID is null) AND (X_REQUEST_GROUP_ID is null)))
      AND ((recinfo.VERSION = X_VERSION)
           OR ((recinfo.VERSION is null) AND (X_VERSION is null)))
      AND (recinfo.RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.RESPONSIBILITY_NAME = X_RESPONSIBILITY_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_WEB_HOST_NAME in VARCHAR2,
  X_WEB_AGENT_NAME in VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID in NUMBER,
  X_DATA_GROUP_ID in NUMBER,
  X_MENU_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_GROUP_APPLICATION_ID in NUMBER,
  X_REQUEST_GROUP_ID in NUMBER,
  X_VERSION in VARCHAR2,
  X_RESPONSIBILITY_KEY in VARCHAR2,
  X_RESPONSIBILITY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_RESPONSIBILITY set
    WEB_HOST_NAME = X_WEB_HOST_NAME,
    WEB_AGENT_NAME = X_WEB_AGENT_NAME,
    DATA_GROUP_APPLICATION_ID = X_DATA_GROUP_APPLICATION_ID,
    DATA_GROUP_ID = X_DATA_GROUP_ID,
    MENU_ID = X_MENU_ID,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    GROUP_APPLICATION_ID = X_GROUP_APPLICATION_ID,
    REQUEST_GROUP_ID = X_REQUEST_GROUP_ID,
    VERSION = X_VERSION,
    RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  else
    -- Added for Function Security Cache Invalidation Project
	fnd_function_security_cache.update_resp(X_RESPONSIBILITY_ID,
                                                X_APPLICATION_ID);

  end if;

  update FND_RESPONSIBILITY_TL set
    RESPONSIBILITY_NAME = X_RESPONSIBILITY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

 -- Added to maintain "ANY/ALL" diamonds of roles for user/resps.
 --
 -- Bug9306729 - Moved call to sync roles to after the TL table is
 -- updated to ensure that the responsibility_name is correctly
 -- updated in the WF tables when a responsibility is uploaded with
 -- FNDLOAD.
 --
  fnd_user_resp_groups_api.sync_roles_all_secgrps(
                   X_RESPONSIBILITY_ID,
                   X_APPLICATION_ID,
                   X_RESPONSIBILITY_KEY,
                   X_START_DATE,
                   X_END_DATE);
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RESPONSIBILITY_ID in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
  myList  wf_parameter_list_t;
begin
  delete from FND_RESPONSIBILITY
  where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  else
    -- Added for Function Security Cache Invalidation Project
  	fnd_function_security_cache.delete_resp(X_RESPONSIBILITY_ID, X_APPLICATION_ID);

  end if;

  delete from FND_RESPONSIBILITY_TL
  where RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_RESPONSIBILITY_TL T
  where not exists
    (select NULL
    from FND_RESPONSIBILITY B
    where B.RESPONSIBILITY_ID = T.RESPONSIBILITY_ID
    and B.APPLICATION_ID = T.APPLICATION_ID
    );

  update FND_RESPONSIBILITY_TL T set (
      RESPONSIBILITY_NAME,
      DESCRIPTION
    ) = (select
      B.RESPONSIBILITY_NAME,
      B.DESCRIPTION
    from FND_RESPONSIBILITY_TL B
    where B.RESPONSIBILITY_ID = T.RESPONSIBILITY_ID
    and B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RESPONSIBILITY_ID,
      T.APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RESPONSIBILITY_ID,
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE
    from FND_RESPONSIBILITY_TL SUBB, FND_RESPONSIBILITY_TL SUBT
    where SUBB.RESPONSIBILITY_ID = SUBT.RESPONSIBILITY_ID
    and SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RESPONSIBILITY_NAME <> SUBT.RESPONSIBILITY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert /*+ append parallel(TT) */ into
  FND_RESPONSIBILITY_TL TT(
    APPLICATION_ID,
    RESPONSIBILITY_ID,
    RESPONSIBILITY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ parallel(V) parallel(T) use_nl(T)  */ V.* from
    (  select /*+ no_merge ordered parallel(B) */
             B.APPLICATION_ID,
             B.RESPONSIBILITY_ID,
             B.RESPONSIBILITY_NAME,
             B.DESCRIPTION,
             B.CREATED_BY,
             B.CREATION_DATE,
             B.LAST_UPDATED_BY,
             B.LAST_UPDATE_DATE,
             B.LAST_UPDATE_LOGIN,
             L.LANGUAGE_CODE,
             B.SOURCE_LANG
        from FND_RESPONSIBILITY_TL B, FND_LANGUAGES L
        where L.INSTALLED_FLAG in ('I', 'B')
        and B.LANGUAGE = userenv('LANG')
    )V,  FND_RESPONSIBILITY_TL T
    where T.RESPONSIBILITY_ID(+) = V.RESPONSIBILITY_ID
    and T.APPLICATION_ID(+) = V.APPLICATION_ID
    and T.LANGUAGE(+) = V.LANGUAGE_CODE
    and T.APPLICATION_ID is NULL
    and T.RESPONSIBILITY_ID is NULL;
end ADD_LANGUAGE;

--------------------------------------------------------------------------
/*
** resp_synch - <described in AFSCRSPS.pls>
*/
PROCEDURE resp_synch(p_application_id    in number,
                     p_responsibility_id in number)
is
  my_start    date;
  my_end      date;
  my_dispname varchar2(100);
  my_desc     varchar2(240);
  my_respkey  varchar2(30);
begin
  -- 12/03- TMORROW recoded this routine to create diamonds of resps rather
  -- than just calling wf_local_synch.propagate_role.

  -- fetch info for synch --

  select start_date, end_date, responsibility_key
  into   my_start, my_end, my_respkey
  from   fnd_responsibility
  where  responsibility_id = p_responsibility_id
  and    application_id = p_application_id;

  -- Added to maintain "ANY/ALL" diamonds of roles for user/resps.
  fnd_user_resp_groups_api.sync_roles_all_secgrps(
                   p_responsibility_id,
                   p_application_id,
                   my_respkey,
                   my_start,
                   my_end);

end;
--------------------------------------------------------------------------

-- OVERLOADED
-- This overloaded version omits X_RESPONSIBILITY_ID because we no longer
-- rely on hardcoded responsibility_ids.  We now always derive the
-- responsibility_id.

procedure LOAD_ROW (
  X_APP_SHORT_NAME              in      VARCHAR2,
  X_RESP_KEY                    in      VARCHAR2,
  X_RESPONSIBILITY_NAME         in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME   in      VARCHAR2,
  X_DATA_GROUP_NAME             in      VARCHAR2,
  X_MENU_NAME                   in      VARCHAR2,
  X_START_DATE                  in      VARCHAR2,
  X_END_DATE                    in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_GROUP_APP_SHORT_NAME        in      VARCHAR2,
  X_REQUEST_GROUP_NAME          in      VARCHAR2,
  X_VERSION                     in      VARCHAR2,
  X_WEB_HOST_NAME               in      VARCHAR2,
  X_WEB_AGENT_NAME              in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2 )
is
  user_id number := 0;
  resp_id number;
  app_id  number;
  dataGroupApp_id number;
  dataGroup_id number;
  requestGroupApp_id number;
  requestGroup_id number;
  menu_id number;
  row_id  varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  l_end_date varchar2(11);
  l_web_host_name varchar2(80);
  l_web_agent_name varchar2(80);

begin

  begin
    select application_id into app_id
    from   fnd_application
    where  application_short_name = X_APP_SHORT_NAME;
  exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_APPLICATION');
      fnd_message.set_token('COLUMN', 'APPLICATION_SHORT_NAME');
      fnd_message.set_token('VALUE', x_app_short_name);
      app_exception.raise_exception;
  end;

  begin
     select dgu.data_group_id, dgu.application_id
     into dataGroup_Id, dataGroupApp_id
     from fnd_data_group_units dgu, fnd_data_groups dg, fnd_application a
     where dgu.data_group_id = dg.data_group_id
     and dg.data_group_name = X_DATA_GROUP_NAME
     and dgu.application_id = a.application_id
     and a.application_short_name = X_DATA_GROUP_APP_SHORT_NAME;
   exception
     when no_data_found then
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_DATA_GROUP_UNITS');
       fnd_message.set_token('COLUMN',
  '(DATA_GROUP_NAME, DATA_GROUP_APP_SHORT_NAME)');
       fnd_message.set_token('VALUE', '('||X_DATA_GROUP_NAME||', '||
           X_DATA_GROUP_APP_SHORT_NAME||')');
       fnd_message.set_token('NOTE',
          'This warning can be ignored while MRC '||
          '(Multiple Reporting Currency) responsibilities '||
          'are being uploaded.  It simply means that the MRC '||
          'responsibility is not being uploaded because it '||
          'won''t be used.  In later releases the MRC responsibilities '||
          'will be moved out into ldt files that can be patched '||
          'seperately, so this warning will not occur.');
       /* Do not raise an exception because that would halt the upload */
       /* of other resps.  Instead, just fail for this resp and go on. */
       /* app_exception.raise_exception;*/
       return;
   end;
  begin
    select menu_id into menu_id
    from   fnd_menus_vl
    where  menu_name = X_MENU_NAME;
   exception
    when no_data_found then
      fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
      fnd_message.set_token('TABLE', 'FND_MENUS_VL');
      fnd_message.set_token('COLUMN', 'MENU_NAME');
      fnd_message.set_token('VALUE', x_menu_name);
      app_exception.raise_exception;
  end;

  if ((X_GROUP_APP_SHORT_NAME is not null) or
      (X_REQUEST_GROUP_NAME is not null)) then
    begin
      select application_id
      into   requestGroupApp_id
      from   fnd_application
      where  application_short_name = X_GROUP_APP_SHORT_NAME;

    exception
      when no_data_found then
        fnd_message.set_name('FND',     'SQL_NO_DATA_FOUND');
        fnd_message.set_token('TABLE',  'FND_APPLICATION');
        fnd_message.set_token('COLUMN', 'GROUP_APP_SHORT_NAME');
        fnd_message.set_token('VALUE',   X_GROUP_APP_SHORT_NAME);
        app_exception.raise_exception;
    end;

    begin
      select request_group_id
      into   requestGroup_id
      from   fnd_request_groups
      where  request_group_name = X_REQUEST_GROUP_NAME
      and    application_id     = requestGroupApp_id;

    exception
      when no_data_found then
        --
        -- create an empty request group to tide us over until
        -- the request groups are uploaded anon.  Using "create
        -- request group" code taken from afcpreqg.lct.
        --
        select FND_REQUEST_GROUPS_S.nextval
        into   requestGroup_id
        from   dual;

        insert into fnd_request_groups
         (request_group_name,
          request_group_id,
          application_id,
          description,
          request_group_code,
          last_updated_by,
          last_update_date,
          last_update_login,
          creation_date,
          created_by)
        values
         (X_REQUEST_GROUP_NAME,
          requestGroup_id,
          requestGroupApp_id,
          'Empty request group',
          null,
          0,sysdate,0,sysdate,0);
    end;
  end if;

  begin

     -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    select decode(X_END_DATE, fnd_load_util.null_value, null,
                  null, X_END_DATE,
                  X_END_DATE),
           decode(X_WEB_HOST_NAME, fnd_load_util.null_value, null,
                  null, X_WEB_HOST_NAME,
                  X_WEB_HOST_NAME),
           decode(X_WEB_AGENT_NAME, fnd_load_util.null_value, null,
                  null, X_WEB_AGENT_NAME,
                  X_WEB_AGENT_NAME)
      into l_end_date, l_web_host_name, l_web_agent_name
      from dual;

      select LAST_UPDATED_BY, LAST_UPDATE_DATE, responsibility_id
       into db_luby, db_ludate, resp_id
       from fnd_responsibility
      where RESPONSIBILITY_KEY = upper(X_RESP_KEY)
       and APPLICATION_ID = app_id;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
     fnd_responsibility_pkg.UPDATE_ROW (
       X_RESPONSIBILITY_ID => resp_id,
       X_APPLICATION_ID => app_id,
       X_WEB_HOST_NAME => L_WEB_HOST_NAME,
       X_WEB_AGENT_NAME => L_WEB_AGENT_NAME,
       X_DATA_GROUP_APPLICATION_ID => dataGroupApp_id,
       X_DATA_GROUP_ID => dataGroup_id,
       X_MENU_ID => menu_id,
       X_START_DATE => to_date(X_START_DATE, 'YYYY/MM/DD'),
       X_END_DATE => to_date(L_END_DATE, 'YYYY/MM/DD'),
       X_GROUP_APPLICATION_ID => requestGroupApp_id,
       X_REQUEST_GROUP_ID => requestGroup_id,
       X_VERSION => X_VERSION,
       X_RESPONSIBILITY_KEY => upper(X_RESP_KEY),
       X_RESPONSIBILITY_NAME => X_RESPONSIBILITY_NAME,
       X_DESCRIPTION => X_DESCRIPTION,
       X_LAST_UPDATE_DATE => f_ludate,
       X_LAST_UPDATED_BY => f_luby,
       X_LAST_UPDATE_LOGIN => 0 );
    end if;

  exception
    when NO_DATA_FOUND then
      -- Get a new resp_id if I don't have one yet
      if (resp_id is null) then
        select fnd_responsibility_s.nextval
        into resp_id
        from sys.dual;
      end if;

      fnd_responsibility_pkg.INSERT_ROW(
        X_ROWID => row_id,
        X_RESPONSIBILITY_ID => resp_id,
        X_APPLICATION_ID => app_id,
        X_WEB_HOST_NAME => L_WEB_HOST_NAME,
        X_WEB_AGENT_NAME => L_WEB_AGENT_NAME,
        X_DATA_GROUP_APPLICATION_ID => dataGroupApp_id,
        X_DATA_GROUP_ID => dataGroup_id,
        X_MENU_ID => menu_id,
        X_START_DATE => to_date(X_START_DATE, 'YYYY/MM/DD'),
        X_END_DATE => to_date(L_END_DATE, 'YYYY/MM/DD'),
        X_GROUP_APPLICATION_ID => requestGroupApp_id,
        X_REQUEST_GROUP_ID => requestGroup_id,
        X_VERSION => X_VERSION,
        X_RESPONSIBILITY_KEY => upper(X_RESP_KEY),
        X_RESPONSIBILITY_NAME => X_RESPONSIBILITY_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_CREATION_DATE => f_ludate,
        X_CREATED_BY => f_luby,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0 );
  end;
end LOAD_ROW;

end FND_RESPONSIBILITY_PKG;

/
