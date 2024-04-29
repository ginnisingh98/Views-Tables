--------------------------------------------------------
--  DDL for Package Body FND_EXECUTABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EXECUTABLES_PKG" as
/* $Header: AFCPMPEB.pls 120.2 2005/08/19 20:05:53 tkamiya ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_EXECUTABLES
    where APPLICATION_ID = X_APPLICATION_ID
    and EXECUTABLE_ID = X_EXECUTABLE_ID
    ;
begin
  insert into FND_EXECUTABLES (
    APPLICATION_ID,
    EXECUTABLE_ID,
    EXECUTABLE_NAME,
    EXECUTION_METHOD_CODE,
    EXECUTION_FILE_NAME,
    SUBROUTINE_NAME,
    EXECUTION_FILE_PATH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_EXECUTABLE_ID,
    X_EXECUTABLE_NAME,
    X_EXECUTION_METHOD_CODE,
    X_EXECUTION_FILE_NAME,
    X_SUBROUTINE_NAME,
    X_EXECUTION_FILE_PATH,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_EXECUTABLES_TL (
    APPLICATION_ID,
    EXECUTABLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_EXECUTABLE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_EXECUTABLE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USER_EXECUTABLE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_EXECUTABLES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.EXECUTABLE_ID = X_EXECUTABLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

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
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      EXECUTABLE_NAME,
      EXECUTION_METHOD_CODE,
      EXECUTION_FILE_NAME,
      SUBROUTINE_NAME,
      EXECUTION_FILE_PATH
    from FND_EXECUTABLES
    where APPLICATION_ID = X_APPLICATION_ID
    and EXECUTABLE_ID = X_EXECUTABLE_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_EXECUTABLE_NAME,
      DESCRIPTION
    from FND_EXECUTABLES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and EXECUTABLE_ID = X_EXECUTABLE_ID
    and LANGUAGE = userenv('LANG')
    for update of APPLICATION_ID nowait;
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
  if (    (recinfo.EXECUTABLE_NAME = X_EXECUTABLE_NAME)
      AND (recinfo.EXECUTION_METHOD_CODE = X_EXECUTION_METHOD_CODE)
      AND ((recinfo.EXECUTION_FILE_NAME = X_EXECUTION_FILE_NAME)
           OR ((recinfo.EXECUTION_FILE_NAME is null) AND (X_EXECUTION_FILE_NAME is null)))
      AND ((recinfo.SUBROUTINE_NAME = X_SUBROUTINE_NAME)
           OR ((recinfo.SUBROUTINE_NAME is null) AND (X_SUBROUTINE_NAME is null)))
      AND ((recinfo.EXECUTION_FILE_PATH = X_EXECUTION_FILE_PATH)
           OR ((recinfo.EXECUTION_FILE_PATH is null) AND (X_EXECUTION_FILE_PATH is null)))
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

  if (    (tlinfo.USER_EXECUTABLE_NAME = X_USER_EXECUTABLE_NAME)
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
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER,
  X_EXECUTABLE_NAME in VARCHAR2,
  X_EXECUTION_METHOD_CODE in VARCHAR2,
  X_EXECUTION_FILE_NAME in VARCHAR2,
  X_SUBROUTINE_NAME in VARCHAR2,
  X_EXECUTION_FILE_PATH in VARCHAR2,
  X_USER_EXECUTABLE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_EXECUTABLES set
    EXECUTABLE_NAME = X_EXECUTABLE_NAME,
    EXECUTION_METHOD_CODE = X_EXECUTION_METHOD_CODE,
    EXECUTION_FILE_NAME = X_EXECUTION_FILE_NAME,
    SUBROUTINE_NAME = X_SUBROUTINE_NAME,
    EXECUTION_FILE_PATH = X_EXECUTION_FILE_PATH,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and EXECUTABLE_ID = X_EXECUTABLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_EXECUTABLES_TL set
    USER_EXECUTABLE_NAME = nvl(X_USER_EXECUTABLE_NAME, USER_EXECUTABLE_NAME),
    DESCRIPTION = nvl(X_DESCRIPTION, DESCRIPTION),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and EXECUTABLE_ID = X_EXECUTABLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


-- Overloaded in case x_custom_mode and x_last_update_date not used
procedure TRANSLATE_ROW (
  x_executable_name		in varchar2,
  x_application_short_name	in varchar2,
  x_owner			in varchar2,
  x_user_executable_name	in varchar2,
  x_description			in varchar2)
is
begin
  fnd_executables_pkg.translate_row(
    x_executable_name => x_executable_name,
    x_application_short_name =>  x_application_short_name,
    x_owner => x_owner,
    x_user_executable_name => x_user_executable_name,
    x_description => x_description,
    x_custom_mode => null,
    x_last_update_date => null);
end TRANSLATE_ROW;


-- Overloaded
procedure TRANSLATE_ROW (
  x_executable_name		in varchar2,
  x_application_short_name	in varchar2,
  x_owner			in varchar2,
  x_user_executable_name	in varchar2,
  x_description			in varchar2,
  x_custom_mode 		in varchar2,
  x_last_update_date		in varchar2)
is
  app_id   	number := 0;
  key_id   	number := 0;
  f_luby	number;	-- entity owner in file
  f_ludate	date;   -- entity update date in file
  db_luby	number;	-- entity owner in db
  db_ludate	date;   -- entity update in db
begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.OWNER_ID(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select APPLICATION_ID into app_id
    from   fnd_application
    where  APPLICATION_SHORT_NAME = x_application_short_name;

    select EXECUTABLE_ID into key_id
    from   fnd_executables
    where  EXECUTABLE_NAME = x_executable_name
    and    APPLICATION_ID = app_id;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into   db_luby, db_ludate
    from   FND_EXECUTABLES_TL
    where  APPLICATION_ID = app_id
    and    EXECUTABLE_ID = key_id
    and    LANGUAGE = userenv('LANG');
    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is USER, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud     => f_ludate,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then
      update FND_EXECUTABLES_TL set
	USER_EXECUTABLE_NAME = nvl(x_user_executable_name,
				   USER_EXECUTABLE_NAME),
	DESCRIPTION          = nvl(x_description, DESCRIPTION),
	SOURCE_LANG	     = userenv('LANG'),
	LAST_UPDATE_DATE     = f_ludate,
	LAST_UPDATED_BY      = f_luby,
	LAST_UPDATE_LOGIN   = 0
      where  APPLICATION_ID = app_id
      and    EXECUTABLE_ID = key_id
      and    LANGUAGE = userenv('LANG');
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

-- Overloaded in case x_custom_mode and x_last_update_date not used
procedure LOAD_ROW (
  x_executable_name	    in varchar2,
  x_application_short_name  in varchar2,
  x_owner		    in varchar2,
  x_execution_method_code   in varchar2,
  x_execution_file_name     in varchar2,
  x_subroutine_name         in varchar2,
  x_execution_file_path     in varchar2,
  x_user_executable_name    in varchar2,
  x_description 	    in varchar2)
is
begin
  fnd_executables_pkg.load_row(
    x_executable_name =>	x_executable_name,
    x_application_short_name =>	x_application_short_name,
    x_owner =>			x_owner,
    x_execution_method_code =>	x_execution_method_code,
    x_execution_file_name  =>	x_execution_file_name,
    x_subroutine_name  =>	x_subroutine_name,
    x_execution_file_path => 	x_execution_file_path,
    x_user_executable_name  =>	x_user_executable_name,
    x_description =>		x_description,
    x_custom_mode =>		null,
    x_last_update_date =>	null);
end LOAD_ROW;


-- Overloaded
procedure LOAD_ROW (
  x_executable_name	    in varchar2,
  x_application_short_name  in varchar2,
  x_owner		    in varchar2,
  x_execution_method_code   in varchar2,
  x_execution_file_name     in varchar2,
  x_subroutine_name         in varchar2,
  x_execution_file_path     in varchar2,
  x_user_executable_name    in varchar2,
  x_description 	    in varchar2,
  x_custom_mode		    in varchar2,
  x_last_update_date	    in varchar2)
is
  app_id   	number := 0;
  key_id   	number := 0;
  exec_method   varchar2(255) := NULL;
  f_luby	number;	-- entity owner in file
  f_ludate	date;   -- entity update date in file
  db_luby	number;	-- entity owner in db
  db_ludate	date;   -- entity update in db
begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.OWNER_ID(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select APPLICATION_ID into app_id
    from   fnd_application
    where  APPLICATION_SHORT_NAME = x_application_short_name;

    select EXECUTABLE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into key_id, db_luby, db_ludate
    from   fnd_executables
    where  EXECUTABLE_NAME = x_executable_name
    and    APPLICATION_ID = app_id;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud     => f_ludate,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then
      fnd_executables_pkg.update_row(
  	x_application_id => 	   app_id,
  	x_executable_id => 	   key_id,
  	x_executable_name =>  	   x_executable_name,
  	x_execution_method_code => x_execution_method_code,
  	x_execution_file_name =>   x_execution_file_name,
  	x_subroutine_name => 	   x_subroutine_name,
  	x_execution_file_path =>   x_execution_file_path,
  	x_user_executable_name =>  x_user_executable_name,
  	x_description => 	   x_description,
  	x_last_update_date => 	   f_ludate,
  	X_last_updated_by => 	   f_luby,
  	x_last_update_login => 	   0);
    end if;
  exception when no_data_found then
    select meaning
    into exec_method
    from fnd_lookup_values
    where lookup_code = x_execution_method_code
    and lookup_type = 'CP_EXECUTION_METHOD_CODE'
    and enabled_flag = 'Y'
    and rownum = 1;

    if (f_luby = 1) then fnd_program.set_session_mode('seed_data');
    else fnd_program.set_session_mode('customer_data');
    end if;

    begin
      fnd_program.executable(
	executable => x_user_executable_name,
        application => x_application_short_name,
        short_name => x_executable_name,
        description  => x_description,
        execution_method  => exec_method,
        execution_file_name => x_execution_file_name,
        subroutine_name  => x_subroutine_name,
        icon_name => null,
        language_code => userenv('LANG'),
        execution_file_path  => x_execution_file_path);
    exception
      when DUP_VAL_ON_INDEX then
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'FND_EXECUTABLES_PKG.LOAD_ROW');
        fnd_message.set_token('ERRNO', SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.message(FND_LOG.LEVEL_EVENT,
                'fnd.plsql.fnd_executables_pkg.load_row.exception', FALSE);
        end if;
      when others then
	fnd_message.set_name('FND','GENERIC-INTERNAL ERROR');
        fnd_message.set_token('REASON',fnd_program.message);
        app_exception.raise_exception;
    end;
  end;
end LOAD_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_EXECUTABLE_ID in NUMBER
) is
begin
  delete from FND_EXECUTABLES
  where APPLICATION_ID = X_APPLICATION_ID
  and EXECUTABLE_ID = X_EXECUTABLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_EXECUTABLES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and EXECUTABLE_ID = X_EXECUTABLE_ID;

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

  delete from FND_EXECUTABLES_TL T
  where not exists
    (select NULL
    from FND_EXECUTABLES B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.EXECUTABLE_ID = T.EXECUTABLE_ID
    );

  update FND_EXECUTABLES_TL T set (
      USER_EXECUTABLE_NAME,
      DESCRIPTION
    ) = (select
      B.USER_EXECUTABLE_NAME,
      B.DESCRIPTION
    from FND_EXECUTABLES_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.EXECUTABLE_ID = T.EXECUTABLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.EXECUTABLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.EXECUTABLE_ID,
      SUBT.LANGUAGE
    from FND_EXECUTABLES_TL SUBB, FND_EXECUTABLES_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.EXECUTABLE_ID = SUBT.EXECUTABLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_EXECUTABLE_NAME <> SUBT.USER_EXECUTABLE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_EXECUTABLES_TL (
    APPLICATION_ID,
    EXECUTABLE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_EXECUTABLE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.EXECUTABLE_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USER_EXECUTABLE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_EXECUTABLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_EXECUTABLES_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.EXECUTABLE_ID = B.EXECUTABLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_EXECUTABLES_PKG;

/
