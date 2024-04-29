--------------------------------------------------------
--  DDL for Package Body FND_RESP_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RESP_FUNCTIONS_PKG" as
 /* $Header: AFSCRFNB.pls 120.1 2005/07/02 03:09:15 appldev ship $ */


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
    cursor C is select ROWID from FND_RESP_FUNCTIONS
      where APPLICATION_ID = X_APPLICATION_ID
      and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
      and RULE_TYPE = X_RULE_TYPE
      and ACTION_ID = X_ACTION_ID;
begin
  insert into FND_RESP_FUNCTIONS (
    APPLICATION_ID,
    RESPONSIBILITY_ID,
    ACTION_ID,
    RULE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_RESPONSIBILITY_ID,
    X_ACTION_ID,
    X_RULE_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  -- Added for Function Security Cache Invalidation Project.
  fnd_function_security_cache.update_resp(X_RESPONSIBILITY_ID, X_APPLICATION_ID);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2
) is
  cursor c1 is select
      RULE_TYPE
    from FND_RESP_FUNCTIONS
    where APPLICATION_ID = X_APPLICATION_ID
    and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
    and RULE_TYPE = X_RULE_TYPE
    and ACTION_ID = X_ACTION_ID
    for update of APPLICATION_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER)
is
begin
  -- Kind of dull, but included for completeness.
  update FND_RESP_FUNCTIONS set
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and RULE_TYPE = X_RULE_TYPE
  and ACTION_ID = X_ACTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  else
    -- Added for Function Security Cache Invalidation Project.
    fnd_function_security_cache.update_resp(X_RESPONSIBILITY_ID, X_APPLICATION_ID);
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_RESPONSIBILITY_ID in NUMBER,
  X_RULE_TYPE in VARCHAR2,
  X_ACTION_ID in NUMBER
) is
begin
  delete from FND_RESP_FUNCTIONS
  where APPLICATION_ID = X_APPLICATION_ID
  and RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
  and RULE_TYPE = X_RULE_TYPE
  and ACTION_ID = X_ACTION_ID;
  if (sql%notfound) then
    raise no_data_found;
  else
    -- Added for Function Security Cache Invalidation Project.
    fnd_function_security_cache.update_resp(X_RESPONSIBILITY_ID, X_APPLICATION_ID);
  end if;
end DELETE_ROW;

--Overloaded!!

procedure LOAD_ROW (
  X_APP_SHORT_NAME      in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_RULE_TYPE		in	VARCHAR2,
  X_ACTION		in	VARCHAR2,
  X_OWNER               in      VARCHAR2 )
is
begin
 fnd_resp_functions_pkg.load_row(
	X_APP_SHORT_NAME => X_APP_SHORT_NAME,
	X_RESP_KEY => X_RESP_KEY,
	X_RULE_TYPE => X_RULE_TYPE,
        X_ACTION => X_ACTION,
	X_OWNER => X_OWNER,
	X_CUSTOM_MODE => '',
	X_LAST_UPDATE_DATE => '');
end LOAD_ROW;

-- ### Overloaded!

procedure LOAD_ROW (
  X_APP_SHORT_NAME      in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_RULE_TYPE		in	VARCHAR2,
  X_ACTION		in	VARCHAR2,
  X_OWNER               in      VARCHAR2,
  X_CUSTOM_MODE		in	VARCHAR2,
  X_LAST_UPDATE_DATE	in	VARCHAR2 )
is
  row_id varchar2(64);
  user_id number := 0;
  app_id number;
  resp_id number;
  act_id number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APP_SHORT_NAME;

  select responsibility_id into resp_id
  from   fnd_responsibility
  where  responsibility_key = X_RESP_KEY
  and application_id = app_id;

  if X_RULE_TYPE in ('F', 'W') then
    select function_id into act_id
    from   fnd_form_functions_vl
    where  function_name = X_ACTION;
  elsif X_RULE_TYPE = 'M' then
    select menu_id into act_id
    from   fnd_menus_vl
    where  menu_name = X_ACTION;
  else
    return;
  end if;

    -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from fnd_resp_functions
    where ACTION_ID = act_id
     and APPLICATION_ID = app_id
     and RESPONSIBILITY_ID = resp_id
     and RULE_TYPE = X_RULE_TYPE;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
     fnd_resp_functions_pkg.update_row(
       X_APPLICATION_ID => app_id,
       X_RESPONSIBILITY_ID => resp_id,
       X_ACTION_ID => act_id,
       X_RULE_TYPE => X_RULE_TYPE,
       X_LAST_UPDATED_BY => f_luby,
       X_LAST_UPDATE_DATE => f_ludate,
       X_LAST_UPDATE_LOGIN => 0);
    end if;
  exception
    when no_data_found then
      fnd_resp_functions_pkg.insert_row (
        X_ROWID => row_id ,
        X_APPLICATION_ID => app_id,
        X_RESPONSIBILITY_ID => resp_id,
        X_ACTION_ID => act_id,
        X_RULE_TYPE => X_RULE_TYPE,
        X_CREATED_BY => f_luby,
        X_CREATION_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

end FND_RESP_FUNCTIONS_PKG;

/
