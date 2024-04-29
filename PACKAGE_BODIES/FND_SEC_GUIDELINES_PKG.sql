--------------------------------------------------------
--  DDL for Package Body FND_SEC_GUIDELINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEC_GUIDELINES_PKG" as
/* $Header: AFSCGLPB.pls 120.0.12010000.2 2017/04/18 08:31:25 ishrivas noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CODE in VARCHAR2,
  X_AUTOFIXABLE in VARCHAR2,
  X_CHECK_SCRIPT in VARCHAR2,
  X_CHECK_SCRIPT_TYPE in VARCHAR2,
  X_CRITICAL_LEVEL in NUMBER,
  X_FIX_SCRIPT in VARCHAR2,
  X_FIX_SCRIPT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INFO in CLOB,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SEC_GUIDELINES
    where CODE = X_CODE
    ;
begin
  insert into FND_SEC_GUIDELINES (
    AUTOFIXABLE,
    CHECK_SCRIPT,
    CHECK_SCRIPT_TYPE,
    CODE,
    CRITICAL_LEVEL,
    FIX_SCRIPT,
    FIX_SCRIPT_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AUTOFIXABLE,
    X_CHECK_SCRIPT,
    X_CHECK_SCRIPT_TYPE,
    X_CODE,
    X_CRITICAL_LEVEL,
    X_FIX_SCRIPT,
    X_FIX_SCRIPT_TYPE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_SEC_GUIDELINES_TL (
    CODE,
    CREATED_BY,
    CREATION_DATE,
    DESCRIPTION,
	INFO,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TITLE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CODE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_DESCRIPTION,
	X_INFO,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_TITLE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_SEC_GUIDELINES_TL T
    where T.CODE = X_CODE
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
  X_CODE in VARCHAR2,
  X_AUTOFIXABLE in VARCHAR2,
  X_CHECK_SCRIPT in VARCHAR2,
  X_CHECK_SCRIPT_TYPE in VARCHAR2,
  X_CRITICAL_LEVEL in NUMBER,
  X_FIX_SCRIPT in VARCHAR2,
  X_FIX_SCRIPT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INFO in CLOB
) is
  cursor c is select
      AUTOFIXABLE,
      CHECK_SCRIPT,
      CHECK_SCRIPT_TYPE,
      CRITICAL_LEVEL,
      FIX_SCRIPT,
      FIX_SCRIPT_TYPE
    from FND_SEC_GUIDELINES
    where CODE = X_CODE
    for update of CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TITLE,
      DESCRIPTION,
	  INFO,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_SEC_GUIDELINES_TL
    where CODE = X_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.AUTOFIXABLE = X_AUTOFIXABLE)
      AND ((recinfo.CHECK_SCRIPT = X_CHECK_SCRIPT)
           OR ((recinfo.CHECK_SCRIPT is null) AND (X_CHECK_SCRIPT is null)))
      AND ((recinfo.CHECK_SCRIPT_TYPE = X_CHECK_SCRIPT_TYPE)
           OR ((recinfo.CHECK_SCRIPT_TYPE is null) AND (X_CHECK_SCRIPT_TYPE is null)))
      AND ((recinfo.CRITICAL_LEVEL = X_CRITICAL_LEVEL)
           OR ((recinfo.CRITICAL_LEVEL is null) AND (X_CRITICAL_LEVEL is null)))
      AND ((recinfo.FIX_SCRIPT = X_FIX_SCRIPT)
           OR ((recinfo.FIX_SCRIPT is null) AND (X_FIX_SCRIPT is null)))
      AND ((recinfo.FIX_SCRIPT_TYPE = X_FIX_SCRIPT_TYPE)
           OR ((recinfo.FIX_SCRIPT_TYPE is null) AND (X_FIX_SCRIPT_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TITLE = X_TITLE)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
		  AND ((tlinfo.INFO = X_INFO)
               OR ((tlinfo.INFO is null) AND (X_INFO is null)))
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
  X_CODE in VARCHAR2,
  X_AUTOFIXABLE in VARCHAR2,
  X_CHECK_SCRIPT in VARCHAR2,
  X_CHECK_SCRIPT_TYPE in VARCHAR2,
  X_CRITICAL_LEVEL in NUMBER,
  X_FIX_SCRIPT in VARCHAR2,
  X_FIX_SCRIPT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INFO in CLOB,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_SEC_GUIDELINES set
    AUTOFIXABLE = X_AUTOFIXABLE,
    CHECK_SCRIPT = X_CHECK_SCRIPT,
    CHECK_SCRIPT_TYPE = X_CHECK_SCRIPT_TYPE,
    CRITICAL_LEVEL = X_CRITICAL_LEVEL,
    FIX_SCRIPT = X_FIX_SCRIPT,
    FIX_SCRIPT_TYPE = X_FIX_SCRIPT_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CODE = X_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_SEC_GUIDELINES_TL set
    TITLE = X_TITLE,
    DESCRIPTION = X_DESCRIPTION,
	INFO = X_INFO,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CODE = X_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CODE in VARCHAR2
) is
begin
  delete from FND_SEC_GUIDELINES_TL
  where CODE = X_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_SEC_GUIDELINES
  where CODE = X_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete & update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_SEC_GUIDELINES_TL T
  where not exists
    (select NULL
    from FND_SEC_GUIDELINES B
    where B.CODE = T.CODE
    );

  update FND_SEC_GUIDELINES_TL T set (
      TITLE,
      DESCRIPTION,
	  INFO
    ) = (select
      B.TITLE,
      B.DESCRIPTION,
	  B.INFO
    from FND_SEC_GUIDELINES_TL B
    where B.CODE = T.CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CODE,
      T.LANGUAGE
  ) in (select
      SUBT.CODE,
      SUBT.LANGUAGE
    from FND_SEC_GUIDELINES_TL SUBB, FND_SEC_GUIDELINES_TL SUBT
    where SUBB.CODE = SUBT.CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TITLE <> SUBT.TITLE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
	  or SUBB.INFO <> SUBT.INFO
	  or (SUBB.INFO is null and SUBT.INFO is not null)
      or (SUBB.INFO is not null and SUBT.INFO is null)


  ));

*/

  insert into FND_SEC_GUIDELINES_TL (
    CODE,
    CREATED_BY,
    CREATION_DATE,
    DESCRIPTION,
	INFO,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TITLE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CODE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.DESCRIPTION,
	B.INFO,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TITLE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_SEC_GUIDELINES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_SEC_GUIDELINES_TL T
    where T.CODE = B.CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (
  X_OWNER in VARCHAR2,
  X_CODE in VARCHAR2,
  X_AUTOFIXABLE in VARCHAR2,
  X_CHECK_SCRIPT in VARCHAR2,
  X_CHECK_SCRIPT_TYPE in VARCHAR2,
  X_CRITICAL_LEVEL in NUMBER,
  X_FIX_SCRIPT in VARCHAR2,
  X_FIX_SCRIPT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_INFO in CLOB,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
 ) is
	f_luby    number;  -- entity owner in file
	f_ludate  date;    -- entity update date in file
	db_luby   number;  -- entity owner in db
	db_ludate date;    -- entity update date in db
	row_id varchar2(64);

	l_check_script varchar2(200);
	l_check_script_type varchar2(10);
	l_fix_script varchar2(200);
	l_fix_script_type varchar2(10);
	l_critical_level number;

 begin
-- Translate owner to file_last_updated_by
        f_luby := fnd_load_util.owner_id(X_OWNER);

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
        begin
          select LAST_UPDATED_BY, LAST_UPDATE_DATE
          into db_luby, db_ludate
          from FND_SEC_GUIDELINES
          where CODE = X_CODE;

	   -- decode for nulls
	   select
			decode(x_check_script, fnd_sec_guidelines_pkg.null_char, null,
                 null, fsg.check_script,
                 x_check_script),
			decode(x_check_script_type, fnd_sec_guidelines_pkg.null_char, null,
                 null, fsg.check_script_type,
                 x_check_script_type),
			decode(x_fix_script, fnd_sec_guidelines_pkg.null_char, null,
                 null, fsg.fix_script,
                 x_fix_script),
			decode(x_fix_script_type, fnd_sec_guidelines_pkg.null_char, null,
                 null, fsg.fix_script_type,
                 x_fix_script_type),
			decode(x_critical_level, fnd_sec_guidelines_pkg.null_number, null,
                 null, fsg.critical_level,
                 x_critical_level)
		into
			l_check_script,
			l_check_script_type,
			l_fix_script,
			l_fix_script_type,
			l_critical_level
		from fnd_sec_guidelines fsg
		where code = x_code;


	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
	    -- Update existing row
            fnd_sec_guidelines_pkg.UPDATE_ROW (
			  X_CODE => X_CODE,
			  X_AUTOFIXABLE => X_AUTOFIXABLE,
			  X_CHECK_SCRIPT => l_check_script,
			  X_CHECK_SCRIPT_TYPE => l_check_script_type,
			  X_CRITICAL_LEVEL => l_critical_level,
			  X_FIX_SCRIPT => l_fix_script,
			  X_FIX_SCRIPT_TYPE => l_fix_script_type,
			  X_TITLE => X_TITLE,
			  X_DESCRIPTION => X_DESCRIPTION,
			  X_INFO => X_INFO,
			  X_LAST_UPDATE_DATE => f_ludate,
			  X_LAST_UPDATED_BY => f_luby,
			  X_LAST_UPDATE_LOGIN => null
			);
          end if;
        exception
          when no_data_found then
            -- Record doesn't exist - insert in all cases

			-- decode for nulls
			   select
					decode(x_check_script, fnd_sec_guidelines_pkg.null_char, null,
						 null, null,
						 x_check_script),
					decode(x_check_script_type, fnd_sec_guidelines_pkg.null_char, null,
						 null, null,
						 x_check_script_type),
					decode(x_fix_script, fnd_sec_guidelines_pkg.null_char, null,
						 null, null,
						 x_fix_script),
					decode(x_fix_script_type, fnd_sec_guidelines_pkg.null_char, null,
						 null, null,
						 x_fix_script_type),
					decode(x_critical_level, fnd_sec_guidelines_pkg.null_number, null,
						 null, null,
						 x_critical_level)
				into
					l_check_script,
					l_check_script_type,
					l_fix_script,
					l_fix_script_type,
					l_critical_level
				from dual;

            fnd_sec_guidelines_pkg.INSERT_ROW (
				  X_ROWID => row_id,
				  X_CODE => X_CODE,
				  X_AUTOFIXABLE => X_AUTOFIXABLE,
				  X_CHECK_SCRIPT => l_check_script,
				  X_CHECK_SCRIPT_TYPE => l_check_script_type,
				  X_CRITICAL_LEVEL => l_critical_level,
				  X_FIX_SCRIPT => l_fix_script,
				  X_FIX_SCRIPT_TYPE => l_fix_script_type,
				  X_TITLE => X_TITLE,
				  X_DESCRIPTION => X_DESCRIPTION,
				  X_INFO => X_INFO,
				  X_CREATION_DATE => sysdate,
				  X_CREATED_BY => 0,
				  X_LAST_UPDATE_DATE => f_ludate,
				  X_LAST_UPDATED_BY => f_luby,
				  X_LAST_UPDATE_LOGIN => null
			);
   end;
 end LOAD_ROW;

  /* TRANSLATE_ROW */
   procedure TRANSLATE_ROW (
   X_CODE					in VARCHAR2,
   X_OWNER                  in VARCHAR2,
   X_TITLE       			in VARCHAR2,
   X_DESCRIPTION            in VARCHAR2,
   X_INFO		in CLOB,
   X_LAST_UPDATE_DATE		in VARCHAR2,
   X_CUSTOM_MODE in VARCHAR2
 ) is
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
	from FND_SEC_GUIDELINES_TL
	where CODE = X_CODE
	and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      update FND_SEC_GUIDELINES_TL set
        TITLE = nvl(X_TITLE,
                                   TITLE),
        DESCRIPTION              = nvl(X_DESCRIPTION, DESCRIPTION),
        SOURCE_LANG              = userenv('LANG'),
        LAST_UPDATE_DATE         = f_ludate,
        LAST_UPDATED_BY          = f_luby,
		INFO			 		 = nvl(X_INFO, INFO),
        LAST_UPDATE_LOGIN        = 0
      where CODE = X_CODE
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
 end TRANSLATE_ROW;

end FND_SEC_GUIDELINES_PKG;

/
