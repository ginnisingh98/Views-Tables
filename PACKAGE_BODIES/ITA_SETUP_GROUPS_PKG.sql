--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_GROUPS_PKG" as
/* $Header: itastgrb.pls 120.3 2006/01/17 12:12:30 adixit noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_TABLE_ID in NUMBER,
  X_TABLE_APP_ID in NUMBER,
  X_CONTEXT_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE2 in VARCHAR2,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_AUDIT_START_DATE in DATE,
  X_AUDIT_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_GROUP_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ITA_SETUP_GROUPS_B
    where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
    ;
begin
  insert into ITA_SETUP_GROUPS_B (
    TABLE_ID,
    TABLE_APP_ID,
    CONTEXT_PARAMETER_CODE,
    CONTEXT_PARAMETER_CODE2,
    HIERARCHY_LEVEL,
    SETUP_GROUP_CODE,
    AUDIT_START_DATE,
    AUDIT_END_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TABLE_ID,
    X_TABLE_APP_ID,
    X_CONTEXT_PARAMETER_CODE,
    X_CONTEXT_PARAMETER_CODE2,
    X_HIERARCHY_LEVEL,
    X_SETUP_GROUP_CODE,
    X_AUDIT_START_DATE,
    X_AUDIT_END_DATE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ITA_SETUP_GROUPS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    SETUP_GROUP_CODE,
    SETUP_GROUP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_SETUP_GROUP_CODE,
    X_SETUP_GROUP_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ITA_SETUP_GROUPS_TL T
    where T.SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
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
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_TABLE_ID in NUMBER,
  X_TABLE_APP_ID in NUMBER,
  X_CONTEXT_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE2 in VARCHAR2,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_AUDIT_START_DATE in DATE,
  X_AUDIT_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_GROUP_NAME in VARCHAR2
) is
  cursor c is select
      TABLE_ID,
      TABLE_APP_ID,
      CONTEXT_PARAMETER_CODE,
      CONTEXT_PARAMETER_CODE2,
      HIERARCHY_LEVEL,
      AUDIT_START_DATE,
      AUDIT_END_DATE,
      OBJECT_VERSION_NUMBER
    from ITA_SETUP_GROUPS_B
    where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
    for update of SETUP_GROUP_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SETUP_GROUP_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ITA_SETUP_GROUPS_TL
    where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SETUP_GROUP_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.TABLE_ID = X_TABLE_ID)
           OR ((recinfo.TABLE_ID is null) AND (X_TABLE_ID is null)))
      AND ((recinfo.TABLE_APP_ID = X_TABLE_APP_ID)
           OR ((recinfo.TABLE_APP_ID is null) AND (X_TABLE_APP_ID is null)))
      AND ((recinfo.CONTEXT_PARAMETER_CODE = X_CONTEXT_PARAMETER_CODE)
           OR ((recinfo.CONTEXT_PARAMETER_CODE is null) AND (X_CONTEXT_PARAMETER_CODE is null)))
      AND ((recinfo.CONTEXT_PARAMETER_CODE2 = X_CONTEXT_PARAMETER_CODE2)
           OR ((recinfo.CONTEXT_PARAMETER_CODE2 is null) AND (X_CONTEXT_PARAMETER_CODE2 is null)))
      AND ((recinfo.HIERARCHY_LEVEL = X_HIERARCHY_LEVEL)
           OR ((recinfo.HIERARCHY_LEVEL is null) AND (X_HIERARCHY_LEVEL is null)))
      AND ((recinfo.AUDIT_START_DATE = X_AUDIT_START_DATE)
           OR ((recinfo.AUDIT_START_DATE is null) AND (X_AUDIT_START_DATE is null)))
      AND ((recinfo.AUDIT_END_DATE = X_AUDIT_END_DATE)
           OR ((recinfo.AUDIT_END_DATE is null) AND (X_AUDIT_END_DATE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.SETUP_GROUP_NAME = X_SETUP_GROUP_NAME)
               OR ((tlinfo.SETUP_GROUP_NAME is null) AND (X_SETUP_GROUP_NAME is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_TABLE_ID in NUMBER,
  X_TABLE_APP_ID in NUMBER,
  X_CONTEXT_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE2 in VARCHAR2,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_AUDIT_START_DATE in DATE,
  X_AUDIT_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_GROUP_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  fnd_file.put_line(fnd_file.log,'SG_PKG.UR: ' || X_AUDIT_END_DATE);
  update ITA_SETUP_GROUPS_B set
    TABLE_ID = X_TABLE_ID,
    TABLE_APP_ID = X_TABLE_APP_ID,
    CONTEXT_PARAMETER_CODE = X_CONTEXT_PARAMETER_CODE,
    CONTEXT_PARAMETER_CODE2 = X_CONTEXT_PARAMETER_CODE2,
    HIERARCHY_LEVEL = X_HIERARCHY_LEVEL,
    AUDIT_START_DATE = X_AUDIT_START_DATE,
    AUDIT_END_DATE = X_AUDIT_END_DATE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
 where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ITA_SETUP_GROUPS_TL set
    SETUP_GROUP_NAME = X_SETUP_GROUP_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SETUP_GROUP_CODE in VARCHAR2
) is
begin
  delete from ITA_SETUP_GROUPS_TL
  where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ITA_SETUP_GROUPS_B
  where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ITA_SETUP_GROUPS_TL T
  where not exists
    (select NULL
    from ITA_SETUP_GROUPS_B B
    where B.SETUP_GROUP_CODE = T.SETUP_GROUP_CODE
    );

  update ITA_SETUP_GROUPS_TL T set (
      SETUP_GROUP_NAME
    ) = (select
      B.SETUP_GROUP_NAME
    from ITA_SETUP_GROUPS_TL B
    where B.SETUP_GROUP_CODE = T.SETUP_GROUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SETUP_GROUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.SETUP_GROUP_CODE,
      SUBT.LANGUAGE
    from ITA_SETUP_GROUPS_TL SUBB, ITA_SETUP_GROUPS_TL SUBT
    where SUBB.SETUP_GROUP_CODE = SUBT.SETUP_GROUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SETUP_GROUP_NAME <> SUBT.SETUP_GROUP_NAME
      or (SUBB.SETUP_GROUP_NAME is null and SUBT.SETUP_GROUP_NAME is not null)
      or (SUBB.SETUP_GROUP_NAME is not null and SUBT.SETUP_GROUP_NAME is null)
  ));

  insert into ITA_SETUP_GROUPS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    SETUP_GROUP_CODE,
    SETUP_GROUP_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.SETUP_GROUP_CODE,
    B.SETUP_GROUP_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ITA_SETUP_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ITA_SETUP_GROUPS_TL T
    where T.SETUP_GROUP_CODE = B.SETUP_GROUP_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_APP_SHORT_NAME in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE2 in VARCHAR2,
  X_AUDIT_END_DATE in DATE,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_GROUP_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2) is

      view_appid number;
      view_table_id number;
      row_id varchar2(64);
      l_audit_start_date date;
      l_audit_end_date date;
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
  begin

      fnd_file.put_line(fnd_file.log,'Setup Group: ' || X_SETUP_GROUP_CODE);
      fnd_file.put_line(fnd_file.log,'Custom mode: ' || X_CUSTOM_MODE);

      -- translate values to IDs
      select APPLICATION_ID
      into view_appid
      from FND_APPLICATION
      where APPLICATION_SHORT_NAME = X_TABLE_APP_SHORT_NAME;

      -- special handling for gl_sets_of_books and ce_system_parameters_all for R12 - bug 4958045
      if (X_TABLE_NAME in ('GL_SETS_OF_BOOKS','CE_SYSTEM_PARAMETERS_ALL')) then
        select table_id
        into view_table_id
        from ita_setup_groups_b
        where setup_group_code = X_SETUP_GROUP_CODE
        and table_app_id = view_appid;
      else
        select table_id
        into view_table_id
        from fnd_tables
        where APPLICATION_id = view_appid and
         table_name = X_TABLE_NAME;
      end if;

      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(X_OWNER);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
      begin
	select LAST_UPDATED_BY, LAST_UPDATE_DATE,
	       audit_start_date, audit_end_date  -- should not be updated
	into db_luby, db_ludate,
	     l_audit_start_date, l_audit_end_date
	from ITA_SETUP_GROUPS_B
	where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE;

	-- Test for customization and version
	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
				      db_ludate, x_CUSTOM_MODE)) then
	  -- Update existing row
          -- Changes made for R12, to set audit end date for obsolete tables
          fnd_file.put_line(fnd_file.log,'Update Row: ' || l_audit_end_date || ': ' || X_AUDIT_END_DATE);
	  ITA_SETUP_GROUPS_PKG.UPDATE_ROW(
	    X_SETUP_GROUP_CODE => X_SETUP_GROUP_CODE,
	    X_TABLE_ID => view_table_id,
	    X_TABLE_APP_ID => view_appid,
	    X_CONTEXT_PARAMETER_CODE => X_CONTEXT_PARAMETER_CODE,
	    X_CONTEXT_PARAMETER_CODE2 => X_CONTEXT_PARAMETER_CODE2,
	    X_HIERARCHY_LEVEL => X_HIERARCHY_LEVEL,
	    X_AUDIT_START_DATE => l_audit_start_date,
	    X_AUDIT_END_DATE  => nvl(l_audit_end_date,X_AUDIT_END_DATE),
	    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
	    X_SETUP_GROUP_NAME => X_SETUP_GROUP_NAME,
	    X_LAST_UPDATE_DATE => f_ludate,
	    X_LAST_UPDATED_BY => f_luby,
	    X_LAST_UPDATE_LOGIN => 0);
	end if;

      exception
	when no_data_found then
	  -- Record doesn't exist - insert in all cases
        fnd_file.put_line(fnd_file.log,'Insert');
	  ITA_SETUP_GROUPS_PKG.INSERT_ROW(
	    x_rowid => row_id,
	    X_SETUP_GROUP_CODE => X_SETUP_GROUP_CODE,
	    X_TABLE_ID => view_table_id,
	    X_TABLE_APP_ID => view_appid,
	    X_CONTEXT_PARAMETER_CODE => X_CONTEXT_PARAMETER_CODE,
	    X_CONTEXT_PARAMETER_CODE2 => X_CONTEXT_PARAMETER_CODE2,
	    X_HIERARCHY_LEVEL => X_HIERARCHY_LEVEL,
	    X_AUDIT_START_DATE => null,
	    X_AUDIT_END_DATE  => X_AUDIT_END_DATE,
	    X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
	    X_SETUP_GROUP_NAME => X_SETUP_GROUP_NAME,
	    x_creation_date => f_ludate,
	    x_created_by => f_luby,
	    X_LAST_UPDATE_DATE => f_ludate,
	    X_LAST_UPDATED_BY => f_luby,
	    X_LAST_UPDATE_LOGIN => 0);
      end;
   end LOAD_ROW;


procedure TRANSLATE_ROW (
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_APP_SHORT_NAME in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE in VARCHAR2,
  X_CONTEXT_PARAMETER_CODE2 in VARCHAR2,
  X_AUDIT_END_DATE in DATE,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SETUP_GROUP_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2) is

      view_appid number;
      view_table_id number;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
  begin

      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(X_OWNER);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

      begin
	select LAST_UPDATED_BY, LAST_UPDATE_DATE
	into db_luby, db_ludate
	from ITA_SETUP_GROUPS_TL
	where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
          and LANGUAGE = userenv('LANG');

        -- Test for customization and version
	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
				      db_ludate, x_CUSTOM_MODE)) then
	   -- Update translations for this language
	   update ITA_SETUP_GROUPS_TL set
	     SETUP_GROUP_NAME = decode(x_SETUP_GROUP_NAME,
			      fnd_load_util.null_value, null, -- Real null
			      null, x_SETUP_GROUP_NAME,       -- No change
			      x_SETUP_GROUP_NAME),
	     LAST_UPDATE_DATE = f_ludate,
	     LAST_UPDATED_BY = f_luby,
	     LAST_UPDATE_LOGIN = 0,
	     SOURCE_LANG = userenv('LANG')
	   where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE
	     and LANGUAGE = userenv('LANG');
	 end if;
      exception
	when no_data_found then
	  -- Do not insert missing translations, skip this row
	  null;
      end;


  end TRANSLATE_ROW ;


end ITA_SETUP_GROUPS_PKG;

/
