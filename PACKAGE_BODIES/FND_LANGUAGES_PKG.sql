--------------------------------------------------------
--  DDL for Package Body FND_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LANGUAGES_PKG" as
/* $Header: AFNLDLGB.pls 120.4.12010000.2 2009/07/27 21:45:23 jvalenti ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LANGUAGE_CODE in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LOCAL_DATE_LANGUAGE in VARCHAR2,
  X_UTF8_DATE_LANGUAGE in VARCHAR2,
  X_ISO_LANGUAGE_3 in VARCHAR2
) is
  cursor C is select ROWID from FND_LANGUAGES
    where LANGUAGE_CODE = X_LANGUAGE_CODE
    ;
begin
  insert into FND_LANGUAGES (
    LANGUAGE_CODE,
    LANGUAGE_ID,
    NLS_LANGUAGE,
    NLS_TERRITORY,
    ISO_LANGUAGE,
    ISO_TERRITORY,
    NLS_CODESET,
    INSTALLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LOCAL_DATE_LANGUAGE,
    UTF8_DATE_LANGUAGE,
    ISO_LANGUAGE_3
  ) values (
    X_LANGUAGE_CODE,
    X_LANGUAGE_ID,
    X_NLS_LANGUAGE,
    X_NLS_TERRITORY,
    X_ISO_LANGUAGE,
    X_ISO_TERRITORY,
    X_NLS_CODESET,
    X_INSTALLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LOCAL_DATE_LANGUAGE,
    X_UTF8_DATE_LANGUAGE,
    X_ISO_LANGUAGE_3
  );

  insert into FND_LANGUAGES_TL (
    LANGUAGE_CODE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LANGUAGE_CODE,
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
    from FND_LANGUAGES_TL T
    where T.LANGUAGE_CODE = X_LANGUAGE_CODE
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
  X_LANGUAGE_CODE in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      LANGUAGE_ID,
      NLS_LANGUAGE,
      NLS_TERRITORY,
      ISO_LANGUAGE,
      ISO_TERRITORY,
      NLS_CODESET,
      INSTALLED_FLAG
    from FND_LANGUAGES
    where LANGUAGE_CODE = X_LANGUAGE_CODE
    for update of LANGUAGE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION
    from FND_LANGUAGES_TL
    where LANGUAGE_CODE = X_LANGUAGE_CODE
    and LANGUAGE = userenv('LANG')
    for update of LANGUAGE_CODE nowait;
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
  if (    ((recinfo.LANGUAGE_ID = X_LANGUAGE_ID)
           OR ((recinfo.LANGUAGE_ID is null) AND (X_LANGUAGE_ID is null)))
      AND (recinfo.NLS_LANGUAGE = X_NLS_LANGUAGE)
      AND (recinfo.NLS_TERRITORY = X_NLS_TERRITORY)
      AND ((recinfo.ISO_LANGUAGE = X_ISO_LANGUAGE)
           OR ((recinfo.ISO_LANGUAGE is null) AND (X_ISO_LANGUAGE is null)))
      AND ((recinfo.ISO_TERRITORY = X_ISO_TERRITORY)
           OR ((recinfo.ISO_TERRITORY is null) AND (X_ISO_TERRITORY is null)))
      AND ((recinfo.NLS_CODESET = X_NLS_CODESET)
           OR ((recinfo.NLS_CODESET is null) AND (X_NLS_CODESET is null)))
      AND (recinfo.INSTALLED_FLAG = X_INSTALLED_FLAG)
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

  if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LOCAL_DATE_LANGUAGE in VARCHAR2,
  X_UTF8_DATE_LANGUAGE in VARCHAR2,
  X_ISO_LANGUAGE_3 in VARCHAR2
) is

begin

  update FND_LANGUAGES set
    LANGUAGE_ID = X_LANGUAGE_ID,
    NLS_LANGUAGE = X_NLS_LANGUAGE,
    NLS_TERRITORY = X_NLS_TERRITORY,
    ISO_LANGUAGE = X_ISO_LANGUAGE,
    ISO_TERRITORY = X_ISO_TERRITORY,
    NLS_CODESET = X_NLS_CODESET,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LOCAL_DATE_LANGUAGE = X_LOCAL_DATE_LANGUAGE,
    UTF8_DATE_LANGUAGE = X_UTF8_DATE_LANGUAGE,
    ISO_LANGUAGE_3 = X_ISO_LANGUAGE_3
  where LANGUAGE_CODE = X_LANGUAGE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_LANGUAGES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LANGUAGE_CODE = X_LANGUAGE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LANGUAGE_CODE in VARCHAR2
) is
begin
  delete from FND_LANGUAGES
  where LANGUAGE_CODE = X_LANGUAGE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_LANGUAGES_TL
  where LANGUAGE_CODE = X_LANGUAGE_CODE;

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

  delete from FND_LANGUAGES_TL T
  where not exists
    (select NULL
    from FND_LANGUAGES B
    where B.LANGUAGE_CODE = T.LANGUAGE_CODE
    );

  update FND_LANGUAGES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FND_LANGUAGES_TL B
    where B.LANGUAGE_CODE = T.LANGUAGE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LANGUAGE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.LANGUAGE_CODE,
      SUBT.LANGUAGE
    from FND_LANGUAGES_TL SUBB, FND_LANGUAGES_TL SUBT
    where SUBB.LANGUAGE_CODE = SUBT.LANGUAGE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));
*/

  insert into FND_LANGUAGES_TL (
    LANGUAGE_CODE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LANGUAGE_CODE,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_LANGUAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_LANGUAGES_TL T
    where T.LANGUAGE_CODE = B.LANGUAGE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  TRANSLATE_ROW (
    X_LANGUAGE_CODE => X_LANGUAGE_CODE,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_OWNER               => X_OWNER,
    X_LAST_UPDATE_DATE         => null,
    X_CUSTOM_MODE          => null);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_LOCAL_DATE_LANGUAGE in VARCHAR2,
  X_UTF8_DATE_LANGUAGE in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  LOAD_ROW (
    X_LANGUAGE_CODE => X_LANGUAGE_CODE,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_LANGUAGE_ID =>	X_LANGUAGE_ID,
    X_NLS_LANGUAGE =>   X_NLS_LANGUAGE,
    X_NLS_TERRITORY =>   X_NLS_TERRITORY,
    X_ISO_LANGUAGE => X_ISO_LANGUAGE,
    X_ISO_TERRITORY => X_ISO_TERRITORY,
    X_NLS_CODESET =>   X_NLS_CODESET,
    X_INSTALLED_FLAG =>   X_INSTALLED_FLAG,
    X_LOCAL_DATE_LANGUAGE => X_LOCAL_DATE_LANGUAGE,
    X_UTF8_DATE_LANGUAGE =>   X_UTF8_DATE_LANGUAGE,
    X_OWNER               => X_OWNER,
    X_LAST_UPDATE_DATE   => null,
    X_CUSTOM_MODE        => null);
end LOAD_ROW;

procedure LOAD_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_LOCAL_DATE_LANGUAGE in VARCHAR2,
  X_UTF8_DATE_LANGUAGE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  LOAD_ROW (
    X_LANGUAGE_CODE => X_LANGUAGE_CODE,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_LANGUAGE_ID =>	X_LANGUAGE_ID,
    X_NLS_LANGUAGE =>   X_NLS_LANGUAGE,
    X_NLS_TERRITORY =>   X_NLS_TERRITORY,
    X_ISO_LANGUAGE => X_ISO_LANGUAGE,
    X_ISO_TERRITORY => X_ISO_TERRITORY,
    X_NLS_CODESET =>   X_NLS_CODESET,
    X_INSTALLED_FLAG =>   X_INSTALLED_FLAG,
    X_LOCAL_DATE_LANGUAGE => X_LOCAL_DATE_LANGUAGE,
    X_UTF8_DATE_LANGUAGE =>   X_UTF8_DATE_LANGUAGE,
    X_ISO_LANGUAGE_3 => null,
    X_OWNER               => X_OWNER,
    X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE,
    X_CUSTOM_MODE        => X_CUSTOM_MODE);
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
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
  from fnd_languages_tl
  where language_code = X_LANGUAGE_CODE
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  update FND_LANGUAGES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = f_ludate,
    LAST_UPDATED_BY = f_luby,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where LANGUAGE_CODE = X_LANGUAGE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  end if;
 exception
   when no_data_found then
    null;
 end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_LANGUAGE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LANGUAGE_ID in NUMBER,
  X_NLS_LANGUAGE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ISO_LANGUAGE in VARCHAR2,
  X_ISO_TERRITORY in VARCHAR2,
  X_NLS_CODESET in VARCHAR2,
  X_INSTALLED_FLAG in VARCHAR2,
  X_LOCAL_DATE_LANGUAGE in VARCHAR2,
  X_UTF8_DATE_LANGUAGE in VARCHAR2,
  X_ISO_LANGUAGE_3 in VARCHAR2,
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

  -- Bug4493112 Moved local variables from UPDATE_ROW to LOAD_ROW.

  L_LANGUAGE_ID NUMBER;
  L_ISO_LANGUAGE VARCHAR2(2);
  L_ISO_TERRITORY VARCHAR2(2);
  L_NLS_CODESET VARCHAR2(30);
  L_LOCAL_DATE_LANGUAGE VARCHAR2(30);
  L_UTF8_DATE_LANGUAGE VARCHAR2(30);
  L_ISO_LANGUAGE_3 VARCHAR2(3);

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

 begin

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into db_luby, db_ludate
  from fnd_languages
  where language_code = X_LANGUAGE_CODE;

  -- Bug4493112 Moved decode select from UPDATE_ROW to LOAD_ROW.
  -- Bug4648984 Moved sql to inside exception block to handle the
  --            no data found.

  select
          decode(x_language_id, fnd_languages_pkg.null_number, null,
                  null, u.language_id,
                  x_language_id),
          decode(x_iso_language, fnd_languages_pkg.null_char, null,
                  null, u.iso_language,
                  x_iso_language),
          decode(x_iso_territory, fnd_languages_pkg.null_char, null,
                  null, u.iso_territory,
                  x_iso_territory),
          decode(x_nls_codeset, fnd_languages_pkg.null_char, null,
                  null, u.nls_codeset,
                  x_nls_codeset),
          decode(x_local_date_language, fnd_languages_pkg.null_char, null,
                  null, u.local_date_language,
                  x_local_date_language),
          decode(x_utf8_date_language, fnd_languages_pkg.null_char, null,
                  null, u.utf8_date_language,
                  x_utf8_date_language),
          decode(x_iso_language_3, fnd_languages_pkg.null_char, null,
                  null, u.iso_language_3,
                  x_iso_language_3)
    into l_language_id,l_iso_language,l_iso_territory,l_nls_codeset,
         l_local_date_language, l_utf8_date_language, l_iso_language_3
    from fnd_languages U
    where language_code = X_language_code;

 -- Bug4493112 Modify code to use local variables for UPDATE_ROW and
 --            INSERT_ROW.

 if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, X_CUSTOM_MODE)) then
  FND_LANGUAGES_PKG.UPDATE_ROW(
    X_LANGUAGE_CODE,
    L_LANGUAGE_ID,
    X_NLS_LANGUAGE,
    X_NLS_TERRITORY,
    L_ISO_LANGUAGE,
    L_ISO_TERRITORY,
    L_NLS_CODESET,
    X_INSTALLED_FLAG,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    0,
    L_LOCAL_DATE_LANGUAGE,
    L_UTF8_DATE_LANGUAGE,
    L_ISO_LANGUAGE_3);
  end if;

  exception
   when no_data_found then

   -- bug8727004 - Need to correctly translate the provided NULL value
   --       for inserting.

   select
          decode(x_language_id, fnd_languages_pkg.null_number, null,
                  null, null,x_language_id),
          decode(x_iso_language, fnd_languages_pkg.null_char, null,
                  null, null,x_iso_language),
          decode(x_iso_territory, fnd_languages_pkg.null_char, null,
                  null, null, x_iso_territory),
          decode(x_nls_codeset, fnd_languages_pkg.null_char, null,
                  null, null, x_nls_codeset),
          decode(x_local_date_language, fnd_languages_pkg.null_char, null,
                  null, null, x_local_date_language),
          decode(x_utf8_date_language, fnd_languages_pkg.null_char, null,
                  null, null, x_utf8_date_language),
          decode(x_iso_language_3, fnd_languages_pkg.null_char, null,
                  null, null, x_iso_language_3)
    into l_language_id,l_iso_language,l_iso_territory,l_nls_codeset,
         l_local_date_language, l_utf8_date_language, l_iso_language_3
    from dual;

    FND_LANGUAGES_PKG.INSERT_ROW(
	X_ROWID,
    	X_LANGUAGE_CODE,
    	L_LANGUAGE_ID,
    	X_NLS_LANGUAGE,
    	X_NLS_TERRITORY,
    	L_ISO_LANGUAGE,
    	L_ISO_TERRITORY,
    	L_NLS_CODESET,
    	X_INSTALLED_FLAG,
        X_DESCRIPTION,
    	f_ludate,
	f_luby,
    	f_ludate,
	f_luby,
    	0,
        L_LOCAL_DATE_LANGUAGE,
        L_UTF8_DATE_LANGUAGE,
        L_ISO_LANGUAGE_3);
end;
end LOAD_ROW;
end FND_LANGUAGES_PKG;

/
