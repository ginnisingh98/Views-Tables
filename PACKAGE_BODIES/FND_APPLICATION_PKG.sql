--------------------------------------------------------
--  DDL for Package Body FND_APPLICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APPLICATION_PKG" as
/* $Header: AFSCAPPB.pls 120.3 2005/10/05 13:24:10 pdeluna ship $ */

/* INSERT_ROW */
procedure INSERT_ROW (
  X_ROWID                  in out nocopy VARCHAR2,
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in NUMBER,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_PRODUCT_CODE           in VARCHAR2
) is
  cursor C is select ROWID from FND_APPLICATION
    where APPLICATION_ID = X_APPLICATION_ID;

begin

  insert into FND_APPLICATION (
    APPLICATION_ID,
    APPLICATION_SHORT_NAME,
    BASEPATH,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PRODUCT_CODE
  ) values (
    X_APPLICATION_ID,
    X_APPLICATION_SHORT_NAME,
    X_BASEPATH,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    nvl(X_PRODUCT_CODE,X_APPLICATION_SHORT_NAME)
  );

  insert into FND_APPLICATION_TL (
    APPLICATION_ID,
    APPLICATION_NAME,
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
    X_APPLICATION_NAME,
    decode(X_DESCRIPTION,
           fnd_load_util.null_value,
           null,
           decode(instr(X_DESCRIPTION,fnd_load_util.null_value),                                              0,X_DESCRIPTION,
                  null)
          ),
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
    from FND_APPLICATION_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

/* LOCK_ROW */
procedure LOCK_ROW (
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2
) is
  cursor c is select
      APPLICATION_SHORT_NAME,
      BASEPATH
    from FND_APPLICATION
    where APPLICATION_ID = X_APPLICATION_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      APPLICATION_NAME,
      DESCRIPTION
    from FND_APPLICATION_TL
    where APPLICATION_ID = X_APPLICATION_ID
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
  if (    (recinfo.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME)
      AND ((recinfo.BASEPATH = X_BASEPATH)
           OR ((recinfo.BASEPATH is null) AND (X_BASEPATH is null)))
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

  if (    (tlinfo.APPLICATION_NAME = X_APPLICATION_NAME)
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

/* UPDATE_ROW */
procedure UPDATE_ROW(
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_PRODUCT_CODE           in VARCHAR2
) is

  L_PRODUCT_CODE varchar2(50);

begin

	/* If X_PRODUCT_CODE is null, do not overwrite existing PRODUCT_CODE with
	   null.  PRODUCT_CODE is a nullable and non-unique column but it should
	   have a value which is normally equivalent to APPLICATION_SHORT_NAME.
	   See bug 2417010.
	 */
	if X_PRODUCT_CODE is null then
		update FND_APPLICATION set
			APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME,
			BASEPATH = X_BASEPATH,
			LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY = X_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
		where APPLICATION_ID = X_APPLICATION_ID;
	else
		/* Ensure that the code does not allow the exception applications to be
		   overwritten with invalid product codes.  This is consistent with
		   afprodcd.sql.
		 */
		if (X_APPLICATION_SHORT_NAME in ('DT','FF','PAY','BEN','GHR','HR')) and
			(X_PRODUCT_CODE <> 'PER') then
			L_PRODUCT_CODE := 'PER';
		elsif (X_APPLICATION_SHORT_NAME in ('SQLGL','RG')) and
			   (X_PRODUCT_CODE <> 'GL') then
			L_PRODUCT_CODE := 'GL';
		elsif (X_APPLICATION_SHORT_NAME = 'SQLAP') and
			   (X_PRODUCT_CODE <> 'AP') then
			L_PRODUCT_CODE := 'AP';
		elsif (X_APPLICATION_SHORT_NAME = 'OFA') and
			   (X_PRODUCT_CODE <> 'FA') then
			L_PRODUCT_CODE := 'FA';
		elsif (X_APPLICATION_SHORT_NAME = 'CST') and
			   (X_PRODUCT_CODE <> 'BOM') then
			L_PRODUCT_CODE := 'BOM';
		else
			L_PRODUCT_CODE := X_PRODUCT_CODE;
		end if;

		update FND_APPLICATION set
			APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME,
			BASEPATH = X_BASEPATH,
			LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
			LAST_UPDATED_BY = X_LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
			PRODUCT_CODE = L_PRODUCT_CODE
		where APPLICATION_ID = X_APPLICATION_ID;
	end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_APPLICATION_TL set
    APPLICATION_NAME = X_APPLICATION_NAME,
    DESCRIPTION = decode(X_DESCRIPTION,
                         fnd_load_util.null_value,
                         null,
                         null,
                         description,
                         decode(instr(X_DESCRIPTION,fnd_load_util.null_value),
                                 0,
                                 X_DESCRIPTION,
                                 null)
                               ),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

/* LOAD_ROW*/
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_PRODUCT_CODE           in VARCHAR2
) is
begin
  fnd_application_pkg.load_row(
	X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
	X_OWNER => X_OWNER,
  	X_BASEPATH => X_BASEPATH,
	X_APPLICATION_NAME => X_APPLICATION_NAME,
	X_DESCRIPTION => X_DESCRIPTION,
	X_CUSTOM_MODE => '',
	X_LAST_UPDATE_DATE => '',
	X_PRODUCT_CODE => X_PRODUCT_CODE
	);

end LOAD_ROW;

/* Overloaded version #1 of LOAD_ROW. */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_CUSTOM_MODE            in VARCHAR2,
  X_LAST_UPDATE_DATE       in VARCHAR2,
  X_PRODUCT_CODE           in VARCHAR2
) is
  app_id  number;
begin
  select application_id into app_id
  from   fnd_application
  where  application_short_name = X_APPLICATION_SHORT_NAME;

  fnd_application_pkg.load_row(
      X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
      X_APPLICATION_ID => app_id,
      X_OWNER => X_OWNER,
      X_BASEPATH => X_BASEPATH,
      X_APPLICATION_NAME => X_APPLICATION_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_CUSTOM_MODE => X_CUSTOM_MODE,
      X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
      X_PRODUCT_CODE => X_PRODUCT_CODE
  );
exception
 when NO_DATA_FOUND then

 select fnd_application_s.nextval into app_id from dual;

 fnd_application_pkg.load_row(
      X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
      X_APPLICATION_ID => app_id,
      X_OWNER => X_OWNER,
      X_BASEPATH => X_BASEPATH,
      X_APPLICATION_NAME => X_APPLICATION_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_CUSTOM_MODE => X_CUSTOM_MODE,
      X_LAST_UPDATE_DATE => X_LAST_UPDATE_DATE,
      X_PRODUCT_CODE => X_PRODUCT_CODE
  );
end LOAD_ROW;

/* Overloaded version #2 of LOAD_ROW. */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME   in VARCHAR2,
  X_APPLICATION_ID           in NUMBER,
  X_OWNER                    in VARCHAR2,
  X_BASEPATH                 in VARCHAR2,
  X_APPLICATION_NAME         in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_CUSTOM_MODE              in VARCHAR2,
  X_LAST_UPDATE_DATE         in VARCHAR2,
  X_PRODUCT_CODE             in VARCHAR2
) is

  user_id   number := 0;
  app_id    number;
  row_id    varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- This select stmnt also checks if
    -- there is a row for this app_id and this app_short_name
    -- Exception is thrown otherwise.
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
      into db_luby, db_ludate
      FROM FND_APPLICATION
     where application_short_name = X_APPLICATION_SHORT_NAME
       and application_id = X_APPLICATION_ID;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
       fnd_application_pkg.UPDATE_ROW (
       X_APPLICATION_ID         => X_APPLICATION_ID,
       X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
       X_BASEPATH               => X_BASEPATH,
       X_APPLICATION_NAME       => X_APPLICATION_NAME,
       X_DESCRIPTION            => X_DESCRIPTION,
       X_LAST_UPDATE_DATE       => f_ludate,
       X_LAST_UPDATED_BY        => f_luby,
       X_LAST_UPDATE_LOGIN      => 0,
       X_PRODUCT_CODE           => X_PRODUCT_CODE);
    end if;
   exception
     when NO_DATA_FOUND then

         declare
              l_count number;
         begin
              -- This select stmnt checks the condition
              -- that if a row exists for this apps_short_name
              -- but with a different apps_id, or
              -- a record exist for this app_id with a different
              -- apps_short_name. Exception is thrown otherwise.
              select count(*)  into l_count
              from   fnd_application
              where  application_short_name = X_APPLICATION_SHORT_NAME
                or   application_id = X_APPLICATION_ID;

              if (l_count > 0) then
                    -- FND message come here
                    fnd_message.set_name('FND', 'FND_INVALID_APPLICATION');
                    fnd_message.set_token('NAME', X_APPLICATION_SHORT_NAME);
                    fnd_message.set_token('ID', X_APPLICATION_ID);
                    app_exception.raise_exception;
              end if;

             --select fnd_application_s.nextval into app_id from dual;
              fnd_application_pkg.INSERT_ROW(
                 X_ROWID                  => row_id,
                 X_APPLICATION_ID         => X_APPLICATION_ID,
                 X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
                 X_BASEPATH               => X_BASEPATH,
                 X_APPLICATION_NAME       => X_APPLICATION_NAME,
                 X_DESCRIPTION            => X_DESCRIPTION,
                 X_CREATION_DATE          => f_ludate,
                 X_CREATED_BY             => f_luby,
                 X_LAST_UPDATE_DATE       => f_ludate,
                 X_LAST_UPDATED_BY        => f_luby,
                 X_LAST_UPDATE_LOGIN      => 0 ,
                 X_PRODUCT_CODE           => X_PRODUCT_CODE);
          end;
end LOAD_ROW;

/* TRANSLATE_ROW */
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2
) is
begin
  fnd_application_pkg.translate_row(
	X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
	X_OWNER => X_OWNER,
 	X_APPLICATION_NAME => X_APPLICATION_NAME,
	X_DESCRIPTION => X_DESCRIPTION,
	x_custom_mode => null,
	x_last_update_date => null);
end TRANSLATE_ROW;

/* Overloaded version of TRANSLATE_ROW */
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  x_custom_mode            in VARCHAR2,
  x_last_update_date       in VARCHAR2
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
    from fnd_application_tl
    where application_id =
       (select application_id
        from fnd_application
        where  application_short_name = X_APPLICATION_SHORT_NAME)
        and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      update fnd_application_tl set
        application_name = nvl(X_APPLICATION_NAME, application_name),
        description = decode(X_DESCRIPTION,
                             fnd_load_util.null_value,
                             null,
                             null,
                             description,
                             decode(instr(X_DESCRIPTION,fnd_load_util.null_value),
                                    0,
                                    X_DESCRIPTION,
                                    null)
                                    ),
        source_lang = userenv('LANG'),
        last_update_date = f_ludate,
        last_updated_by  = f_luby,
        last_update_login = 0
             where application_id =
             (select application_id
              from   fnd_application
              where  application_short_name = X_APPLICATION_SHORT_NAME)
              and userenv('LANG') in (language, source_lang);
     end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

/* DELETE_ROW */
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from FND_APPLICATION
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_APPLICATION_TL
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

/* ADD_LANGUAGE */
procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
  delete from FND_APPLICATION_TL T
  where not exists
    (select NULL
    from FND_APPLICATION B
    where B.APPLICATION_ID = T.APPLICATION_ID
    );

  update FND_APPLICATION_TL T set (
      APPLICATION_NAME,
      DESCRIPTION
    ) = (select
      B.APPLICATION_NAME,
      B.DESCRIPTION
    from FND_APPLICATION_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE
    from FND_APPLICATION_TL SUBB, FND_APPLICATION_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.APPLICATION_NAME <> SUBT.APPLICATION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ))
  -- ***** BEGIN NEW CLAUSE FOR UPDATE *****
  and not exists
    (select null
    from FND_APPLICATION_TL DUP
    where DUP.LANGUAGE = T.LANGUAGE
    and (DUP.APPLICATION_NAME) =
      (select
         B.APPLICATION_NAME
       from FND_APPLICATION_TL B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.LANGUAGE = T.SOURCE_LANG));
  -- ***** END NEW CLAUSE FOR UPDATE *****

  -- ***** NEW CODE FOR INSERT HERE *****
  loop
    update FND_APPLICATION_TL set
      APPLICATION_NAME = '@'||APPLICATION_NAME
    where (APPLICATION_NAME, LANGUAGE) in
      (select
         B.APPLICATION_NAME,
         L.LANGUAGE_CODE
       from FND_APPLICATION_TL B, FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and B.LANGUAGE = userenv('LANG')
       and not exists
         (select NULL
          from FND_APPLICATION_TL T
          where T.APPLICATION_ID = B.APPLICATION_ID
          and T.LANGUAGE = L.LANGUAGE_CODE));

     exit when SQL%ROWCOUNT = 0;
   end loop;
  -- ***** END CODE FOR INSERT HERE *****

*/
  insert into FND_APPLICATION_TL (
    APPLICATION_ID,
    APPLICATION_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.APPLICATION_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_APPLICATION_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_APPLICATION_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_APPLICATION_PKG;

/
