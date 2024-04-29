--------------------------------------------------------
--  DDL for Package Body FWK_TBX_LOOKUP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FWK_TBX_LOOKUP_TYPES_PKG" as
/* $Header: fwktbxlookuptypestlb.pls 120.2.12000000.4 2007/07/19 12:04:00 pbhamidi ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FWK_TBX_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into FWK_TBX_LOOKUP_TYPES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOOKUP_TYPE,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LOOKUP_TYPE,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FWK_TBX_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FWK_TBX_LOOKUP_TYPES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOOKUP_TYPE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_LOOKUP_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FWK_TBX_LOOKUP_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2
) is
begin
  delete from FWK_TBX_LOOKUP_TYPES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update FWK_TBX_LOOKUP_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FWK_TBX_LOOKUP_TYPES_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LANGUAGE
    from FWK_TBX_LOOKUP_TYPES_TL SUBB, FWK_TBX_LOOKUP_TYPES_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FWK_TBX_LOOKUP_TYPES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOOKUP_TYPE,
    DISPLAY_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LOOKUP_TYPE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FWK_TBX_LOOKUP_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FWK_TBX_LOOKUP_TYPES_TL T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_OWNER               in VARCHAR2,
  X_DISPLAY_NAME        in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  f_luby := fnd_load_util.owner_id(x_owner);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FWK_TBX_LOOKUP_TYPES_TL
  where lookup_type       = X_LOOKUP_TYPE
  and language            = userenv('LANG');

  -- We want the values from file to be populated, if db has null value
  db_ludate := nvl(db_ludate, to_date('1990/01/01', 'YYYY/MM/DD'));
  -- Default last updated by to SEED, if db has null value
  db_luby := nvl(db_luby, fnd_load_util.owner_id('SEED'));

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FWK_TBX_LOOKUP_TYPES_TL set
        display_name           = nvl(X_DISPLAY_NAME, display_name),
        description       = nvl(X_DESCRIPTION, description),
        last_update_date  = f_ludate,
        last_updated_by   = f_luby,
        last_update_login = 0,
        source_lang       = userenv('LANG')
      where lookup_type       = X_LOOKUP_TYPE
      and userenv('LANG') in (language, source_lang);
  end if;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2)
  is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FWK_TBX_LOOKUP_TYPES_TL
  where lookup_type       = X_LOOKUP_TYPE
  and language            = userenv('LANG');

  -- We want the values from file to be populated, if db has null value
  db_ludate := nvl(db_ludate, to_date('1990/01/01', 'YYYY/MM/DD'));
  -- Default last updated by to SEED, if db has null value
  db_luby := nvl(db_luby, fnd_load_util.owner_id('SEED'));

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then
     FWK_TBX_LOOKUP_TYPES_PKG.UPDATE_ROW (
           X_LOOKUP_TYPE  => X_LOOKUP_TYPE,
           X_DISPLAY_NAME => X_DISPLAY_NAME,
           X_DESCRIPTION  => X_DESCRIPTION,
           X_LAST_UPDATE_DATE  => X_LAST_UPDATE_DATE,
           X_LAST_UPDATED_BY   => X_LAST_UPDATED_BY,
           X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN );
  end if;
 exception
 when no_data_found then
 -- Record doesn't exist - insert in all cases

  FWK_TBX_LOOKUP_TYPES_PKG.INSERT_ROW(
          X_ROWID               => X_ROWID,
          X_LOOKUP_TYPE         => X_LOOKUP_TYPE,
          X_DISPLAY_NAME        => X_DISPLAY_NAME,
          X_DESCRIPTION         => X_DESCRIPTION,
          X_CREATION_DATE       => X_CREATION_DATE,
          X_CREATED_BY          => X_CREATED_BY,
          X_LAST_UPDATE_DATE    => X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY     => X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN   => X_LAST_UPDATE_LOGIN );

end LOAD_ROW;

end FWK_TBX_LOOKUP_TYPES_PKG;

/
