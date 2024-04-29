--------------------------------------------------------
--  DDL for Package Body FWK_TBX_LOOKUP_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FWK_TBX_LOOKUP_CODES_PKG" as
/* $Header: fwktbxlookupcodesb.pls 120.2.12000000.4 2007/07/19 12:05:40 pbhamidi ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FWK_TBX_LOOKUP_CODES_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    ;
begin
  insert into FWK_TBX_LOOKUP_CODES_B (
    LOOKUP_TYPE,
    LOOKUP_CODE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOOKUP_TYPE,
    X_LOOKUP_CODE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FWK_TBX_LOOKUP_CODES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
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
    X_LOOKUP_CODE,
    X_MEANING,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FWK_TBX_LOOKUP_CODES_TL T
    where T.LOOKUP_TYPE = X_LOOKUP_TYPE
    and T.LOOKUP_CODE = X_LOOKUP_CODE
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
  X_LOOKUP_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from FWK_TBX_LOOKUP_CODES_B
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    for update of LOOKUP_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FWK_TBX_LOOKUP_CODES_TL
    where LOOKUP_TYPE = X_LOOKUP_TYPE
    and LOOKUP_CODE = X_LOOKUP_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LOOKUP_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_LOOKUP_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FWK_TBX_LOOKUP_CODES_B set
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FWK_TBX_LOOKUP_CODES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2
) is
begin
  delete from FWK_TBX_LOOKUP_CODES_TL
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FWK_TBX_LOOKUP_CODES_B
  where LOOKUP_TYPE = X_LOOKUP_TYPE
  and LOOKUP_CODE = X_LOOKUP_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FWK_TBX_LOOKUP_CODES_TL T
  where not exists
    (select NULL
    from FWK_TBX_LOOKUP_CODES_B B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    );

  update FWK_TBX_LOOKUP_CODES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from FWK_TBX_LOOKUP_CODES_TL B
    where B.LOOKUP_TYPE = T.LOOKUP_TYPE
    and B.LOOKUP_CODE = T.LOOKUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOOKUP_TYPE,
      T.LOOKUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.LOOKUP_TYPE,
      SUBT.LOOKUP_CODE,
      SUBT.LANGUAGE
    from FWK_TBX_LOOKUP_CODES_TL SUBB, FWK_TBX_LOOKUP_CODES_TL SUBT
    where SUBB.LOOKUP_TYPE = SUBT.LOOKUP_TYPE
    and SUBB.LOOKUP_CODE = SUBT.LOOKUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FWK_TBX_LOOKUP_CODES_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOOKUP_TYPE,
    LOOKUP_CODE,
    MEANING,
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
    B.LOOKUP_CODE,
    B.MEANING,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FWK_TBX_LOOKUP_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FWK_TBX_LOOKUP_CODES_TL T
    where T.LOOKUP_TYPE = B.LOOKUP_TYPE
    and T.LOOKUP_CODE = B.LOOKUP_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_LOOKUP_TYPE         in VARCHAR2,
  X_LOOKUP_CODE         in VARCHAR2,
  X_OWNER               in VARCHAR2,
  X_MEANING             in VARCHAR2,
  X_DESCRIPTION         in VARCHAR2,
  X_LAST_UPDATE_DATE    in VARCHAR2,
  X_CUSTOM_MODE         in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

  f_luby := fnd_load_util.owner_id(x_owner);

  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FWK_TBX_LOOKUP_CODES_TL
  where LOOKUP_TYPE       = X_LOOKUP_TYPE
  and LOOKUP_CODE         = X_LOOKUP_CODE
  and LANGUAGE            = userenv('LANG');

  -- We want the values from file to be populated, if db has null value
  db_ludate := nvl(db_ludate, to_date('1990/01/01', 'YYYY/MM/DD'));
  -- Default last updated by to SEED, if db has null value
  db_luby := nvl(db_luby, fnd_load_util.owner_id('SEED'));

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
    update FWK_TBX_LOOKUP_CODES_TL set
      MEANING           = nvl(X_MEANING, meaning),
      DESCRIPTION       = nvl(X_DESCRIPTION, description),
      LAST_UPDATE_DATE  = f_ludate,
      LAST_UPDATED_BY   = f_luby,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG       = userenv('LANG')
    where LOOKUP_TYPE       = X_LOOKUP_TYPE
    and LOOKUP_CODE         = X_LOOKUP_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  end if;

end TRANSLATE_ROW;


procedure LOAD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_LOOKUP_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin
  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into db_luby, db_ludate
  from FWK_TBX_LOOKUP_CODES_TL
  where LOOKUP_TYPE       = X_LOOKUP_TYPE
  and LOOKUP_CODE         = X_LOOKUP_CODE
  and LANGUAGE            = userenv('LANG');

  -- We want the values from file to be populated, if db has null value
  db_ludate := nvl(db_ludate, to_date('1990/01/01', 'YYYY/MM/DD'));
  -- Default last updated by to SEED, if db has null value
  db_luby := nvl(db_luby, fnd_load_util.owner_id('SEED'));

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, X_CUSTOM_MODE)) then

    FWK_TBX_LOOKUP_CODES_PKG.UPDATE_ROW(
       X_LOOKUP_TYPE       => X_LOOKUP_TYPE,
       X_LOOKUP_CODE       => X_LOOKUP_CODE,
       X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
       X_END_DATE_ACTIVE   => X_END_DATE_ACTIVE,
       X_MEANING           => X_MEANING,
       X_DESCRIPTION       => X_DESCRIPTION,
       X_LAST_UPDATE_DATE  => X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY   => X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN);
  end if;
 exception
 when no_data_found then
 -- Record doesn't exist - insert in all cases
   FWK_TBX_LOOKUP_CODES_PKG.INSERT_ROW(
        X_ROWID           => X_ROWID,
        X_LOOKUP_TYPE     => X_LOOKUP_TYPE,
        X_LOOKUP_CODE     => X_LOOKUP_CODE,
        X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
        X_END_DATE_ACTIVE   => X_END_DATE_ACTIVE,
        X_MEANING           => X_MEANING,
        X_DESCRIPTION       => X_DESCRIPTION,
        X_CREATION_DATE     => X_CREATION_DATE,
        X_CREATED_BY        => X_CREATED_BY,
        X_LAST_UPDATE_DATE  => X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY   => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN );

end LOAD_ROW;

end FWK_TBX_LOOKUP_CODES_PKG;

/
