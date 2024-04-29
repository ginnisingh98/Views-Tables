--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_PARAMETERS_PKG" as
/* $Header: itastprb.pls 120.4 2005/09/22 17:02:54 cpetriuc noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PARAMETER_CODE in VARCHAR2,
  X_SELECT_CLAUSE in VARCHAR2,
  X_FROM_CLAUSE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_END_DATE in DATE,
  X_MIGRATED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FK_COLUMN_ID in NUMBER,
  X_CONTEXT_SEQUENCE_NUM in NUMBER,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_FK_TABLE_ID in NUMBER,
  X_FK_TABLE_APP_ID in NUMBER,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_COLUMN_ID in NUMBER,
  X_CONTEXT_PREDICATE_FLAG in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_COLUMN_REFERENCE1  in VARCHAR2,
  X_COLUMN_REFERENCE2  in VARCHAR2
) is
  cursor C is select ROWID from ITA_SETUP_PARAMETERS_B
    where PARAMETER_CODE = X_PARAMETER_CODE
    ;
begin
  insert into ITA_SETUP_PARAMETERS_B (
    SELECT_CLAUSE,
    FROM_CLAUSE,
    WHERE_CLAUSE,
    END_DATE,
    MIGRATED_FLAG,
    OBJECT_VERSION_NUMBER,
    FK_COLUMN_ID,
    CONTEXT_SEQUENCE_NUM,
    AUDIT_ENABLED_FLAG,
    FK_TABLE_ID,
    FK_TABLE_APP_ID,
    SETUP_GROUP_CODE,
    COLUMN_ID,
    CONTEXT_PREDICATE_FLAG,
    PARAMETER_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    COLUMN_REFERENCE1,
    COLUMN_REFERENCE2
  ) values (
    X_SELECT_CLAUSE,
    X_FROM_CLAUSE,
    X_WHERE_CLAUSE,
    X_END_DATE,
    X_MIGRATED_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_FK_COLUMN_ID,
    X_CONTEXT_SEQUENCE_NUM,
    X_AUDIT_ENABLED_FLAG,
    X_FK_TABLE_ID,
    X_FK_TABLE_APP_ID,
    X_SETUP_GROUP_CODE,
    X_COLUMN_ID,
    X_CONTEXT_PREDICATE_FLAG,
    X_PARAMETER_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_COLUMN_REFERENCE1,
    X_COLUMN_REFERENCE2
  );

  insert into ITA_SETUP_PARAMETERS_TL (
    PARAMETER_CODE,
    PARAMETER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PARAMETER_CODE,
    X_PARAMETER_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ITA_SETUP_PARAMETERS_TL T
    where T.PARAMETER_CODE = X_PARAMETER_CODE
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
  X_PARAMETER_CODE in VARCHAR2,
  X_SELECT_CLAUSE in VARCHAR2,
  X_FROM_CLAUSE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_END_DATE in DATE,
  X_MIGRATED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FK_COLUMN_ID in NUMBER,
  X_CONTEXT_SEQUENCE_NUM in NUMBER,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_FK_TABLE_ID in NUMBER,
  X_FK_TABLE_APP_ID in NUMBER,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_COLUMN_ID in NUMBER,
  X_CONTEXT_PREDICATE_FLAG in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_COLUMN_REFERENCE1  in VARCHAR2,
  X_COLUMN_REFERENCE2  in VARCHAR2
) is
  cursor c is select
      SELECT_CLAUSE,
      FROM_CLAUSE,
      WHERE_CLAUSE,
	END_DATE,
	MIGRATED_FLAG,
      OBJECT_VERSION_NUMBER,
      FK_COLUMN_ID,
      CONTEXT_SEQUENCE_NUM,
      AUDIT_ENABLED_FLAG,
      FK_TABLE_ID,
      FK_TABLE_APP_ID,
      SETUP_GROUP_CODE,
      COLUMN_ID,
      CONTEXT_PREDICATE_FLAG,
      COLUMN_REFERENCE1,
      COLUMN_REFERENCE2
    from ITA_SETUP_PARAMETERS_B
    where PARAMETER_CODE = X_PARAMETER_CODE
    for update of PARAMETER_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PARAMETER_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ITA_SETUP_PARAMETERS_TL
    where PARAMETER_CODE = X_PARAMETER_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARAMETER_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SELECT_CLAUSE = X_SELECT_CLAUSE)
           OR ((recinfo.SELECT_CLAUSE is null) AND (X_SELECT_CLAUSE is null)))
      AND ((recinfo.FROM_CLAUSE = X_FROM_CLAUSE)
           OR ((recinfo.FROM_CLAUSE is null) AND (X_FROM_CLAUSE is null)))
      AND ((recinfo.WHERE_CLAUSE = X_WHERE_CLAUSE)
           OR ((recinfo.WHERE_CLAUSE is null) AND (X_WHERE_CLAUSE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.MIGRATED_FLAG = X_MIGRATED_FLAG)
           OR ((recinfo.MIGRATED_FLAG is null) AND (X_MIGRATED_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.FK_COLUMN_ID = X_FK_COLUMN_ID)
           OR ((recinfo.FK_COLUMN_ID is null) AND (X_FK_COLUMN_ID is null)))
      AND ((recinfo.CONTEXT_SEQUENCE_NUM = X_CONTEXT_SEQUENCE_NUM)
           OR ((recinfo.CONTEXT_SEQUENCE_NUM is null) AND (X_CONTEXT_SEQUENCE_NUM is null)))
      AND ((recinfo.AUDIT_ENABLED_FLAG = X_AUDIT_ENABLED_FLAG)
           OR ((recinfo.AUDIT_ENABLED_FLAG is null) AND (X_AUDIT_ENABLED_FLAG is null)))
      AND ((recinfo.FK_TABLE_ID = X_FK_TABLE_ID)
           OR ((recinfo.FK_TABLE_ID is null) AND (X_FK_TABLE_ID is null)))
      AND ((recinfo.FK_TABLE_APP_ID = X_FK_TABLE_APP_ID)
           OR ((recinfo.FK_TABLE_APP_ID is null) AND (X_FK_TABLE_APP_ID is null)))
      AND ((recinfo.SETUP_GROUP_CODE = X_SETUP_GROUP_CODE)
           OR ((recinfo.SETUP_GROUP_CODE is null) AND (X_SETUP_GROUP_CODE is null)))
      AND ((recinfo.COLUMN_ID = X_COLUMN_ID)
           OR ((recinfo.COLUMN_ID is null) AND (X_COLUMN_ID is null)))
      AND ((recinfo.CONTEXT_PREDICATE_FLAG = X_CONTEXT_PREDICATE_FLAG)
           OR ((recinfo.CONTEXT_PREDICATE_FLAG is null) AND (X_CONTEXT_PREDICATE_FLAG is null)))
      AND ((recinfo.COLUMN_REFERENCE1 = X_COLUMN_REFERENCE1)
           OR ((recinfo.COLUMN_REFERENCE1 is null) AND (X_COLUMN_REFERENCE1 is null)))
      AND ((recinfo.COLUMN_REFERENCE2 = X_COLUMN_REFERENCE2)
           OR ((recinfo.COLUMN_REFERENCE2 is null) AND (X_COLUMN_REFERENCE2 is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PARAMETER_NAME = X_PARAMETER_NAME)
               OR ((tlinfo.PARAMETER_NAME is null) AND (X_PARAMETER_NAME is null)))
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
  X_PARAMETER_CODE in VARCHAR2,
  X_SELECT_CLAUSE in VARCHAR2,
  X_FROM_CLAUSE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_END_DATE in DATE,
  X_MIGRATED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FK_COLUMN_ID in NUMBER,
  X_CONTEXT_SEQUENCE_NUM in NUMBER,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_FK_TABLE_ID in NUMBER,
  X_FK_TABLE_APP_ID in NUMBER,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_COLUMN_ID in NUMBER,
  X_CONTEXT_PREDICATE_FLAG in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_COLUMN_REFERENCE1  in VARCHAR2,
  X_COLUMN_REFERENCE2  in VARCHAR2
) is
begin
  update ITA_SETUP_PARAMETERS_B set
    SELECT_CLAUSE = X_SELECT_CLAUSE,
    FROM_CLAUSE = X_FROM_CLAUSE,
    WHERE_CLAUSE = X_WHERE_CLAUSE,
    END_DATE = nvl(END_DATE, X_END_DATE),
    MIGRATED_FLAG = X_MIGRATED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    FK_COLUMN_ID = X_FK_COLUMN_ID,
    CONTEXT_SEQUENCE_NUM = X_CONTEXT_SEQUENCE_NUM,
    AUDIT_ENABLED_FLAG = X_AUDIT_ENABLED_FLAG,
    FK_TABLE_ID = X_FK_TABLE_ID,
    FK_TABLE_APP_ID = X_FK_TABLE_APP_ID,
    SETUP_GROUP_CODE = X_SETUP_GROUP_CODE,
    COLUMN_ID = X_COLUMN_ID,
    CONTEXT_PREDICATE_FLAG = X_CONTEXT_PREDICATE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    COLUMN_REFERENCE1 = X_COLUMN_REFERENCE1,
    COLUMN_REFERENCE2 = X_COLUMN_REFERENCE2
  where PARAMETER_CODE = X_PARAMETER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ITA_SETUP_PARAMETERS_TL set
    PARAMETER_NAME = X_PARAMETER_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARAMETER_CODE = X_PARAMETER_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PARAMETER_CODE in VARCHAR2
) is
begin
  delete from ITA_SETUP_PARAMETERS_TL
  where PARAMETER_CODE = X_PARAMETER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ITA_SETUP_PARAMETERS_B
  where PARAMETER_CODE = X_PARAMETER_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ITA_SETUP_PARAMETERS_TL T
  where not exists
    (select NULL
    from ITA_SETUP_PARAMETERS_B B
    where B.PARAMETER_CODE = T.PARAMETER_CODE
    );

  update ITA_SETUP_PARAMETERS_TL T set (
      PARAMETER_NAME
    ) = (select
      B.PARAMETER_NAME
    from ITA_SETUP_PARAMETERS_TL B
    where B.PARAMETER_CODE = T.PARAMETER_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_CODE,
      SUBT.LANGUAGE
    from ITA_SETUP_PARAMETERS_TL SUBB, ITA_SETUP_PARAMETERS_TL SUBT
    where SUBB.PARAMETER_CODE = SUBT.PARAMETER_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAMETER_NAME <> SUBT.PARAMETER_NAME
      or (SUBB.PARAMETER_NAME is null and SUBT.PARAMETER_NAME is not null)
      or (SUBB.PARAMETER_NAME is not null and SUBT.PARAMETER_NAME is null)
  ));

  insert into ITA_SETUP_PARAMETERS_TL (
    PARAMETER_CODE,
    PARAMETER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PARAMETER_CODE,
    B.PARAMETER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ITA_SETUP_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ITA_SETUP_PARAMETERS_TL T
    where T.PARAMETER_CODE = B.PARAMETER_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (
  X_PARAMETER_CODE in VARCHAR2,
  X_SELECT_CLAUSE in VARCHAR2,
  X_FROM_CLAUSE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_END_DATE in DATE,
  X_MIGRATED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTEXT_SEQUENCE_NUM in NUMBER,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CONTEXT_PREDICATE_FLAG in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2,
  X_COLUMN_REFERENCE1  in VARCHAR2,
  X_COLUMN_REFERENCE2  in VARCHAR2) is

      view_appid number;
      view_table_id number;
      view_column_id number;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
			flag varchar2(1);		 -- flag will determine if the column is part of schema or not
  begin
		flag := 'Y';
      -- translate values to IDs
		select table_app_id, table_id
		into view_appid, view_table_id
		from ITA_SETUP_GROUPS_B
		where SETUP_GROUP_CODE = X_SETUP_GROUP_CODE;

		--insert into dummy_log values (391,'flag val bfr select column_id ' || flag || ' :: column name :: ' || X_column_NAME);

		begin
			select column_id
			into view_column_id
			from fnd_columns
			where APPLICATION_id = view_appid and
			table_id = view_table_id and
			column_name = X_column_NAME;
			flag := 'Y' ;
		exception
		when no_data_found then
			flag := 'N' ; -- flag='N' means its not part of schema so the entry for this parameter should not be created
		end;


		-- Translate owner to file_last_updated_by
		f_luby := fnd_load_util.owner_id(X_OWNER);
		-- Translate char last_update_date to date
		f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

		begin


			select LAST_UPDATED_BY, LAST_UPDATE_DATE
			into db_luby, db_ludate
			from ITA_SETUP_PARAMETERS_B
			where parameter_code = X_parameter_code;




		-- Test for customization and version
			if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
									db_ludate, x_CUSTOM_MODE)) then

				-- Update existing row
				ITA_SETUP_PARAMETERS_PKG.UPDATE_ROW(
					X_PARAMETER_CODE => x_PARAMETER_CODE,
					X_SELECT_CLAUSE => x_SELECT_CLAUSE,
					X_FROM_CLAUSE => x_FROM_CLAUSE,
					X_WHERE_CLAUSE => x_WHERE_CLAUSE,
					X_END_DATE => x_END_DATE,
					X_MIGRATED_FLAG => x_MIGRATED_FLAG,
					X_OBJECT_VERSION_NUMBER => x_OBJECT_VERSION_NUMBER,
					X_FK_COLUMN_ID => null,
					X_CONTEXT_SEQUENCE_NUM => x_CONTEXT_SEQUENCE_NUM,
					X_AUDIT_ENABLED_FLAG => x_AUDIT_ENABLED_FLAG,
					X_FK_TABLE_ID => null,
					X_FK_TABLE_APP_ID => null,
					X_SETUP_GROUP_CODE => x_SETUP_GROUP_CODE,
					X_COLUMN_ID => view_COLUMN_ID,
					X_CONTEXT_PREDICATE_FLAG => x_CONTEXT_PREDICATE_FLAG,
					X_PARAMETER_NAME => x_PARAMETER_NAME,
					X_LAST_UPDATE_DATE => f_ludate,
					X_LAST_UPDATED_BY => f_luby,
					X_LAST_UPDATE_LOGIN => 0,
 				        X_COLUMN_REFERENCE1  => X_COLUMN_REFERENCE1,
					X_COLUMN_REFERENCE2  => X_COLUMN_REFERENCE2  );
			end if;
					exception
			when no_data_found then
				-- Record doesn't exist - insert in all cases
 			  -- Inserting records into the ITA_SETUP_PARAMETERS_B and ITA_SETUP_PARAMETERS_TL
				-- in and only if the parameter is part of the schema.
					if flag = 'Y' then
						ITA_SETUP_PARAMETERS_PKG.INSERT_ROW(
							X_ROWID => ROW_ID,
							X_PARAMETER_CODE => x_PARAMETER_CODE,
							X_SELECT_CLAUSE => x_SELECT_CLAUSE,
							X_FROM_CLAUSE => x_FROM_CLAUSE,
							X_WHERE_CLAUSE => x_WHERE_CLAUSE,
							X_END_DATE => x_END_DATE,
							X_MIGRATED_FLAG => x_MIGRATED_FLAG,
							X_OBJECT_VERSION_NUMBER => x_OBJECT_VERSION_NUMBER,
							X_FK_COLUMN_ID => null,
							X_CONTEXT_SEQUENCE_NUM => x_CONTEXT_SEQUENCE_NUM,
							X_AUDIT_ENABLED_FLAG => x_AUDIT_ENABLED_FLAG,
							X_FK_TABLE_ID => null,
							X_FK_TABLE_APP_ID => null,
							X_SETUP_GROUP_CODE => x_SETUP_GROUP_CODE,
							X_COLUMN_ID => view_COLUMN_ID,
							X_CONTEXT_PREDICATE_FLAG => x_CONTEXT_PREDICATE_FLAG,
							X_PARAMETER_NAME => x_PARAMETER_NAME,
							x_creation_date => f_ludate,
							x_created_by => f_luby,
							X_LAST_UPDATE_DATE => f_ludate,
							X_LAST_UPDATED_BY => f_luby,
							X_LAST_UPDATE_LOGIN => 0,
							X_COLUMN_REFERENCE1  => X_COLUMN_REFERENCE1,
							X_COLUMN_REFERENCE2  => X_COLUMN_REFERENCE2
							);
					end if;

		end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_PARAMETER_CODE in VARCHAR2,
  X_SELECT_CLAUSE in VARCHAR2,
  X_FROM_CLAUSE in VARCHAR2,
  X_WHERE_CLAUSE in VARCHAR2,
  X_END_DATE in DATE,
  X_MIGRATED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CONTEXT_SEQUENCE_NUM in NUMBER,
  X_AUDIT_ENABLED_FLAG in VARCHAR2,
  X_SETUP_GROUP_CODE in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_CONTEXT_PREDICATE_FLAG in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2,
  X_COLUMN_REFERENCE1  in VARCHAR2,
  X_COLUMN_REFERENCE2  in VARCHAR2
  ) is


      view_appid number;
      view_table_id number;
      view_column_id number;
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
	from ITA_SETUP_PARAMETERS_TL
	where PARAMETER_CODE = X_PARAMETER_CODE
          and LANGUAGE = userenv('LANG');

        -- Test for customization and version
	if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
				      db_ludate, x_CUSTOM_MODE)) then
	   -- Update translations for this language
	   update ITA_SETUP_PARAMETERS_TL set
	     PARAMETER_NAME = decode(x_PARAMETER_NAME,
			      fnd_load_util.null_value, null, -- Real null
			      null, x_PARAMETER_NAME,       -- No change
			      x_PARAMETER_NAME),
	     LAST_UPDATE_DATE = f_ludate,
	     LAST_UPDATED_BY = f_luby,
	     LAST_UPDATE_LOGIN = 0,
	     SOURCE_LANG = userenv('LANG')
	   where PARAMETER_CODE = X_PARAMETER_CODE
	     and LANGUAGE = userenv('LANG');
	 end if;
      exception
	when no_data_found then
	  -- Do not insert missing translations, skip this row
	  null;
      end;

end TRANSLATE_ROW;

end ITA_SETUP_PARAMETERS_PKG;

/
