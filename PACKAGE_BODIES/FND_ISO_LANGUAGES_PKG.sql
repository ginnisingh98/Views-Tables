--------------------------------------------------------
--  DDL for Package Body FND_ISO_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ISO_LANGUAGES_PKG" as
/* $Header: AFNLISOB.pls 115.1 2004/04/15 22:15:15 rsuzuki noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ISO_LANGUAGE_3 in VARCHAR2,
  X_ISO_LANGUAGE_2 in VARCHAR2,
  X_PRIVATE_USE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_ISO_LANGUAGES
    where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
    ;
begin
  insert into FND_ISO_LANGUAGES (
    ISO_LANGUAGE_3,
    ISO_LANGUAGE_2,
    PRIVATE_USE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ISO_LANGUAGE_3,
    X_ISO_LANGUAGE_2,
    X_PRIVATE_USE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_ISO_LANGUAGES_TL (
    ISO_LANGUAGE_3,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ISO_LANGUAGE_3,
    X_NAME,
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
    from FND_ISO_LANGUAGES_TL T
    where T.ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
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
  X_ISO_LANGUAGE_3 in VARCHAR2,
  X_ISO_LANGUAGE_2 in VARCHAR2,
  X_PRIVATE_USE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ISO_LANGUAGE_2,
      PRIVATE_USE_FLAG
    from FND_ISO_LANGUAGES
    where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
    for update of ISO_LANGUAGE_3 nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_ISO_LANGUAGES_TL
    where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ISO_LANGUAGE_3 nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ISO_LANGUAGE_2 = X_ISO_LANGUAGE_2)
           OR ((recinfo.ISO_LANGUAGE_2 is null) AND (X_ISO_LANGUAGE_2 is null)))
      AND (recinfo.PRIVATE_USE_FLAG = X_PRIVATE_USE_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_ISO_LANGUAGE_3 in VARCHAR2,
  X_ISO_LANGUAGE_2 in VARCHAR2,
  X_PRIVATE_USE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_ISO_LANGUAGES set
    ISO_LANGUAGE_2 = X_ISO_LANGUAGE_2,
    PRIVATE_USE_FLAG = X_PRIVATE_USE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_ISO_LANGUAGES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ISO_LANGUAGE_3 in VARCHAR2
) is
begin
  delete from FND_ISO_LANGUAGES_TL
  where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_ISO_LANGUAGES
  where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
  delete from FND_ISO_LANGUAGES_TL T
  where not exists
    (select NULL
    from FND_ISO_LANGUAGES B
    where B.ISO_LANGUAGE_3 = T.ISO_LANGUAGE_3
    );

  update FND_ISO_LANGUAGES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from FND_ISO_LANGUAGES_TL B
    where B.ISO_LANGUAGE_3 = T.ISO_LANGUAGE_3
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ISO_LANGUAGE_3,
      T.LANGUAGE
  ) in (select
      SUBT.ISO_LANGUAGE_3,
      SUBT.LANGUAGE
    from FND_ISO_LANGUAGES_TL SUBB, FND_ISO_LANGUAGES_TL SUBT
    where SUBB.ISO_LANGUAGE_3 = SUBT.ISO_LANGUAGE_3
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));
*/

  insert into FND_ISO_LANGUAGES_TL (
    ISO_LANGUAGE_3,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ISO_LANGUAGE_3,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_ISO_LANGUAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_ISO_LANGUAGES_TL T
    where T.ISO_LANGUAGE_3 = B.ISO_LANGUAGE_3
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_ISO_LANGUAGE_3 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
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
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

 begin
  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from fnd_iso_languages_tl
  where iso_language_3 = X_ISO_LANGUAGE_3
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  update FND_ISO_LANGUAGES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = f_ludate,
    LAST_UPDATED_BY = f_luby,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;
 exception
   when no_data_found then
    null;
 end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ISO_LANGUAGE_3 in VARCHAR2,
  X_ISO_LANGUAGE_2 in VARCHAR2,
  X_PRIVATE_USE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
 user_id NUMBER;
 X_ROWID VARCHAR2(64);
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
  from fnd_iso_languages
  where iso_language_3 = X_ISO_LANGUAGE_3;

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then
  FND_ISO_LANGUAGES_PKG.UPDATE_ROW(
    X_ISO_LANGUAGE_3,
    X_ISO_LANGUAGE_2,
    X_PRIVATE_USE_FLAG,
    X_NAME,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    0);
  end if;

  exception
   when no_data_found then
    FND_ISO_LANGUAGES_PKG.INSERT_ROW(
        X_ROWID,
        X_ISO_LANGUAGE_3,
        X_ISO_LANGUAGE_2,
        X_PRIVATE_USE_FLAG,
        X_NAME,
        X_DESCRIPTION,
        f_ludate,
        f_luby,
        f_ludate,
        f_luby,
        0);
end;
end LOAD_ROW;

end FND_ISO_LANGUAGES_PKG;

/
