--------------------------------------------------------
--  DDL for Package Body FND_PROFILE_CATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE_CATS_PKG" as
/* $Header: FNDPRCAB.pls 120.4 2005/08/16 05:25:36 stadepal noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_PROFILE_CATS
    where NAME = upper(X_NAME)
    and   APPLICATION_ID = X_APPLICATION_ID
    ;
begin
  insert into FND_PROFILE_CATS (
    ENABLED,
    NAME,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ENABLED,
    upper(X_NAME),
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_PROFILE_CATS_TL (
    DISPLAY_NAME,
    NAME,
    APPLICATION_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DISPLAY_NAME,
    upper(X_NAME),
    X_APPLICATION_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_PROFILE_CATS_TL T
    where T.NAME = upper(X_NAME)
    and T.APPLICATION_ID = X_APPLICATION_ID
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
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED
    from FND_PROFILE_CATS
    where NAME = X_NAME
    and   APPLICATION_ID = X_APPLICATION_ID
    for update of NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_PROFILE_CATS_TL
    where NAME = X_NAME
    and APPLICATION_ID = X_APPLICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ENABLED = X_ENABLED)
           OR ((recinfo.ENABLED is null) AND (X_ENABLED is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
               OR ((tlinfo.DISPLAY_NAME is null) AND (X_DISPLAY_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_NAME in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_PROFILE_CATS set
    ENABLED = X_ENABLED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where NAME = upper(X_NAME)
  and   APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_PROFILE_CATS_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where NAME = upper(X_NAME)
  and APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER
) is
begin
  delete from FND_PROFILE_CATS_TL
  where NAME = upper(X_NAME)
  and APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_PROFILE_CATS
  where NAME = upper(X_NAME)
  and   APPLICATION_ID = X_APPLICATION_ID;


  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_PROFILE_CAT_OPTIONS
  where CATEGORY_NAME = upper(X_NAME)
  and   APPLICATION_ID = X_APPLICATION_ID;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FND_PROFILE_CATS_TL T
  where not exists
    (select NULL
    from FND_PROFILE_CATS B
    where B.NAME = T.NAME
    and   B.APPLICATION_ID = T.APPLICATION_ID
    );

  update FND_PROFILE_CATS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_PROFILE_CATS_TL B
    where B.NAME = T.NAME
    and B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NAME,
      T.APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NAME,
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE
    from FND_PROFILE_CATS_TL SUBB, FND_PROFILE_CATS_TL SUBT
    where SUBB.NAME = SUBT.NAME
    and SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or (SUBB.DISPLAY_NAME is null and SUBT.DISPLAY_NAME is not null)
      or (SUBB.DISPLAY_NAME is not null and SUBT.DISPLAY_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_PROFILE_CATS_TL (
    DISPLAY_NAME,
    NAME,
    APPLICATION_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DISPLAY_NAME,
    B.NAME,
    B.APPLICATION_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_PROFILE_CATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_PROFILE_CATS_TL T
    where T.NAME = B.NAME
    and T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_NAME                        in      VARCHAR2,
  X_APPLICATION_SHORT_NAME      in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_DISPLAY_NAME                 in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  x_appl_id number;
begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  select APPLICATION_ID
  into x_appl_id
  from FND_APPLICATION
  where APPLICATION_SHORT_NAME = upper(x_application_short_name);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PROFILE_CATS_TL
    where NAME = upper(x_name)
    and APPLICATION_ID = x_appl_id
    and LANGUAGE = userenv('LANG');

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

        update FND_PROFILE_CATS_TL set
               DESCRIPTION = X_DESCRIPTION,
               DISPLAY_NAME = X_DISPLAY_NAME,
               LAST_UPDATE_DATE = f_ludate,
               LAST_UPDATED_BY = f_luby,
               LAST_UPDATE_LOGIN = f_luby,
               SOURCE_LANG = userenv('LANG')
               where NAME = upper(X_NAME)
               and APPLICATION_ID = x_appl_id
               and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_NAME                        in      VARCHAR2,
  X_DESCRIPTION			in 	VARCHAR2,
  X_DISPLAY_NAME		in 	VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_APPLICATION_SHORT_NAME      in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2)
is
  row_id    varchar2(64);
  app_id    number;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

 begin

  select application_id into app_id
	from fnd_application
        where application_short_name = upper(X_APPLICATION_SHORT_NAME);

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luby, db_ludate
    from FND_PROFILE_CATS
    where NAME = upper(x_name)
    and   APPLICATION_ID = app_id;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

	FND_PROFILE_CATS_PKG.UPDATE_ROW (
  		X_NAME => X_NAME,
  		X_DESCRIPTION => X_DESCRIPTION,
  		X_DISPLAY_NAME => X_DISPLAY_NAME,
      X_ENABLED => X_ENABLED,
      X_APPLICATION_ID => app_id,
  		X_LAST_UPDATE_DATE => f_ludate,
                X_LAST_UPDATED_BY => f_luby,
  		X_LAST_UPDATE_LOGIN => f_luby);
   end if;
  exception
     when no_data_found then

	 FND_PROFILE_CATS_PKG.INSERT_ROW (
                X_ROWID => row_id,
                X_NAME => X_NAME,
                X_DESCRIPTION => X_DESCRIPTION,
                X_DISPLAY_NAME => X_DISPLAY_NAME,
                X_ENABLED => X_ENABLED,
                X_APPLICATION_ID => app_id,
  		X_CREATION_DATE => f_ludate,
  		X_CREATED_BY => f_luby,
                X_LAST_UPDATE_DATE => f_ludate,
                X_LAST_UPDATED_BY => f_luby,
                X_LAST_UPDATE_LOGIN => f_luby);
  end;
end LOAD_ROW;

end FND_PROFILE_CATS_PKG;

/
