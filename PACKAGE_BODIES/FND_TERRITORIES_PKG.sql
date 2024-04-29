--------------------------------------------------------
--  DDL for Package Body FND_TERRITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TERRITORIES_PKG" as
/* $Header: AFNLDTIB.pls 120.4.12010000.4 2010/12/17 15:44:54 jvalenti ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
    FND_TERRITORIES_PKG.INSERT_ROW(
    X_ROWID,
    X_TERRITORY_CODE,
    X_EU_CODE,
    X_ISO_NUMERIC_CODE,
    X_ALTERNATE_TERRITORY_CODE,
    X_NLS_TERRITORY,
    X_ADDRESS_STYLE,
    X_ADDRESS_VALIDATION,
    X_BANK_INFO_STYLE,
    X_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NULL);
end INSERT_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBSOLETE_FLAG in VARCHAR2
) is
begin
    FND_TERRITORIES_PKG.INSERT_ROW(
    X_ROWID,
    X_TERRITORY_CODE,
    X_EU_CODE,
    X_ISO_NUMERIC_CODE,
    X_ALTERNATE_TERRITORY_CODE,
    X_NLS_TERRITORY,
    X_ADDRESS_STYLE,
    X_ADDRESS_VALIDATION,
    X_BANK_INFO_STYLE,
    X_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBSOLETE_FLAG,
    null);
end INSERT_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBSOLETE_FLAG in VARCHAR2,
  X_ISO_TERRITORY_CODE in VARCHAR2
) is
  cursor C is select ROWID from FND_TERRITORIES
    where TERRITORY_CODE = X_TERRITORY_CODE
    ;
  obsolete_flag varchar2(1);
begin

  obsolete_flag := nvl(X_OBSOLETE_FLAG, 'N');

  insert into FND_TERRITORIES (
    EU_CODE,
    TERRITORY_CODE,
    ISO_NUMERIC_CODE,
    ALTERNATE_TERRITORY_CODE,
    NLS_TERRITORY,
    ADDRESS_STYLE,
    ADDRESS_VALIDATION,
    BANK_INFO_STYLE,
    BANK_INFO_VALIDATION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBSOLETE_FLAG,
    ISO_TERRITORY_CODE
  ) values (
    X_EU_CODE,
    X_TERRITORY_CODE,
    X_ISO_NUMERIC_CODE,
    X_ALTERNATE_TERRITORY_CODE,
    X_NLS_TERRITORY,
    X_ADDRESS_STYLE,
    X_ADDRESS_VALIDATION,
    X_BANK_INFO_STYLE,
    X_BANK_INFO_VALIDATION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    obsolete_flag,
    X_ISO_TERRITORY_CODE
  );

  insert into FND_TERRITORIES_TL (
    TERRITORY_CODE,
    TERRITORY_SHORT_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TERRITORY_CODE,
    X_TERRITORY_SHORT_NAME,
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
    from FND_TERRITORIES_TL T
    where T.TERRITORY_CODE = X_TERRITORY_CODE
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
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      EU_CODE,
      ISO_NUMERIC_CODE,
      ALTERNATE_TERRITORY_CODE,
      NLS_TERRITORY,
      ADDRESS_STYLE,
      ADDRESS_VALIDATION,
      BANK_INFO_STYLE,
      BANK_INFO_VALIDATION
    from FND_TERRITORIES
    where TERRITORY_CODE = X_TERRITORY_CODE
    for update of TERRITORY_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TERRITORY_SHORT_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_TERRITORIES_TL
    where TERRITORY_CODE = X_TERRITORY_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TERRITORY_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.EU_CODE = X_EU_CODE)
           OR ((recinfo.EU_CODE is null) AND (X_EU_CODE is null)))
      AND ((recinfo.ISO_NUMERIC_CODE = X_ISO_NUMERIC_CODE)
           OR ((recinfo.ISO_NUMERIC_CODE is null) AND (X_ISO_NUMERIC_CODE is null)))
      AND ((recinfo.ALTERNATE_TERRITORY_CODE = X_ALTERNATE_TERRITORY_CODE)
           OR ((recinfo.ALTERNATE_TERRITORY_CODE is null) AND (X_ALTERNATE_TERRITORY_CODE is null)))
      AND ((recinfo.NLS_TERRITORY = X_NLS_TERRITORY)
           OR ((recinfo.NLS_TERRITORY is null) AND (X_NLS_TERRITORY is null)))
      AND ((recinfo.ADDRESS_STYLE = X_ADDRESS_STYLE)
           OR ((recinfo.ADDRESS_STYLE is null) AND (X_ADDRESS_STYLE is null)))
      AND ((recinfo.ADDRESS_VALIDATION = X_ADDRESS_VALIDATION)
           OR ((recinfo.ADDRESS_VALIDATION is null) AND (X_ADDRESS_VALIDATION is null)))
      AND ((recinfo.BANK_INFO_STYLE = X_BANK_INFO_STYLE)
           OR ((recinfo.BANK_INFO_STYLE is null) AND (X_BANK_INFO_STYLE is null)))
      AND ((recinfo.BANK_INFO_VALIDATION = X_BANK_INFO_VALIDATION)
           OR ((recinfo.BANK_INFO_VALIDATION is null) AND (X_BANK_INFO_VALIDATION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TERRITORY_SHORT_NAME = X_TERRITORY_SHORT_NAME)
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
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  FND_TERRITORIES_PKG.UPDATE_ROW(
    X_TERRITORY_CODE,
    X_EU_CODE,
    X_ISO_NUMERIC_CODE,
    X_ALTERNATE_TERRITORY_CODE,
    X_NLS_TERRITORY,
    X_ADDRESS_STYLE,
    X_ADDRESS_VALIDATION,
    X_BANK_INFO_STYLE,
    X_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NULL);
end UPDATE_ROW;

procedure UPDATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBSOLETE_FLAG in VARCHAR2
) is
begin
  FND_TERRITORIES_PKG.UPDATE_ROW(
    X_TERRITORY_CODE,
    X_EU_CODE,
    X_ISO_NUMERIC_CODE,
    X_ALTERNATE_TERRITORY_CODE,
    X_NLS_TERRITORY,
    X_ADDRESS_STYLE,
    X_ADDRESS_VALIDATION,
    X_BANK_INFO_STYLE,
    X_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBSOLETE_FLAG,
    NULL);
end UPDATE_ROW;


procedure UPDATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2,
  X_NLS_TERRITORY in VARCHAR2,
  X_ADDRESS_STYLE in VARCHAR2,
  X_ADDRESS_VALIDATION in VARCHAR2,
  X_BANK_INFO_STYLE in VARCHAR2,
  X_BANK_INFO_VALIDATION in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBSOLETE_FLAG in VARCHAR2,
  X_ISO_TERRITORY_CODE in VARCHAR2
) is

l_iso_territory_code varchar2(3);
l_eu_code varchar2(3);

begin

select
decode(x_iso_territory_code,fnd_territories_pkg.null_char,null,
null,u.iso_territory_code,x_iso_territory_code),
decode(x_eu_code,fnd_territories_pkg.null_char,null,
null,u.eu_code,x_eu_code)
into l_iso_territory_code,l_eu_code
from fnd_territories u
where territory_code = x_territory_code;

  if (X_OBSOLETE_FLAG is NULL) then
    update FND_TERRITORIES set
      EU_CODE = L_EU_CODE,
      ISO_NUMERIC_CODE = X_ISO_NUMERIC_CODE,
      ALTERNATE_TERRITORY_CODE = X_ALTERNATE_TERRITORY_CODE,
      NLS_TERRITORY = X_NLS_TERRITORY,
      ADDRESS_STYLE = X_ADDRESS_STYLE,
      ADDRESS_VALIDATION = X_ADDRESS_VALIDATION,
      BANK_INFO_STYLE = X_BANK_INFO_STYLE,
      BANK_INFO_VALIDATION = X_BANK_INFO_VALIDATION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      ISO_TERRITORY_CODE = L_ISO_TERRITORY_CODE
    where TERRITORY_CODE = X_TERRITORY_CODE;
  else
    update FND_TERRITORIES set
      EU_CODE = L_EU_CODE,
      ISO_NUMERIC_CODE = X_ISO_NUMERIC_CODE,
      ALTERNATE_TERRITORY_CODE = X_ALTERNATE_TERRITORY_CODE,
      NLS_TERRITORY = X_NLS_TERRITORY,
      ADDRESS_STYLE = X_ADDRESS_STYLE,
      ADDRESS_VALIDATION = X_ADDRESS_VALIDATION,
      BANK_INFO_STYLE = X_BANK_INFO_STYLE,
      BANK_INFO_VALIDATION = X_BANK_INFO_VALIDATION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      OBSOLETE_FLAG = X_OBSOLETE_FLAG,
      ISO_TERRITORY_CODE = L_ISO_TERRITORY_CODE
    where TERRITORY_CODE = X_TERRITORY_CODE;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_TERRITORIES_TL set
    TERRITORY_SHORT_NAME = X_TERRITORY_SHORT_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TERRITORY_CODE = X_TERRITORY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TERRITORY_CODE in VARCHAR2
) is
begin
  delete from FND_TERRITORIES_TL
  where TERRITORY_CODE = X_TERRITORY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_TERRITORIES
  where TERRITORY_CODE = X_TERRITORY_CODE;

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

  delete from FND_TERRITORIES_TL T
  where not exists
    (select NULL
    from FND_TERRITORIES B
    where B.TERRITORY_CODE = T.TERRITORY_CODE
    );

  update FND_TERRITORIES_TL T set (
      TERRITORY_SHORT_NAME,
      DESCRIPTION
    ) = (select
      B.TERRITORY_SHORT_NAME,
      B.DESCRIPTION
    from FND_TERRITORIES_TL B
    where B.TERRITORY_CODE = T.TERRITORY_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TERRITORY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.TERRITORY_CODE,
      SUBT.LANGUAGE
    from FND_TERRITORIES_TL SUBB, FND_TERRITORIES_TL SUBT
    where SUBB.TERRITORY_CODE = SUBT.TERRITORY_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TERRITORY_SHORT_NAME <> SUBT.TERRITORY_SHORT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_TERRITORIES_TL (
    TERRITORY_CODE,
    TERRITORY_SHORT_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TERRITORY_CODE,
    B.TERRITORY_SHORT_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_TERRITORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_TERRITORIES_TL T
    where T.TERRITORY_CODE = B.TERRITORY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  TRANSLATE_ROW (
    X_TERRITORY_CODE  => X_TERRITORY_CODE ,
    X_TERRITORY_SHORT_NAME  => X_TERRITORY_SHORT_NAME ,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_OWNER               => X_OWNER,
    X_LAST_UPDATE_DATE    => null,
    X_CUSTOM_MODE         => null);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2 default NULL,
  X_NLS_TERRITORY in VARCHAR2 default NULL,
  X_ADDRESS_STYLE in VARCHAR2 default NULL,
  X_ADDRESS_VALIDATION in VARCHAR2 default NULL,
  X_BANK_INFO_STYLE in VARCHAR2 default NULL,
  X_BANK_INFO_VALIDATION in VARCHAR2 default NULL,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  LOAD_ROW (
    X_TERRITORY_CODE => X_TERRITORY_CODE ,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_EU_CODE =>	X_EU_CODE ,
    X_ISO_NUMERIC_CODE =>   X_ISO_NUMERIC_CODE ,
    X_NLS_TERRITORY =>   X_NLS_TERRITORY,
    X_ALTERNATE_TERRITORY_CODE =>   X_ALTERNATE_TERRITORY_CODE ,
    X_ADDRESS_STYLE =>   X_ADDRESS_STYLE ,
    X_ADDRESS_VALIDATION => X_ADDRESS_VALIDATION ,
    X_BANK_INFO_STYLE =>   X_BANK_INFO_STYLE ,
    X_OWNER               => X_OWNER,
    X_BANK_INFO_VALIDATION => X_BANK_INFO_VALIDATION ,
    X_TERRITORY_SHORT_NAME => X_TERRITORY_SHORT_NAME ,
    X_LAST_UPDATE_DATE    => null,
    X_CUSTOM_MODE         => null);

end LOAD_ROW;


procedure TRANSLATE_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
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

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FND_TERRITORIES_TL
  where TERRITORY_CODE = X_TERRITORY_CODE
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  update FND_TERRITORIES_TL set
    DESCRIPTION = X_DESCRIPTION,
    TERRITORY_SHORT_NAME = X_TERRITORY_SHORT_NAME,
    LAST_UPDATE_DATE = f_ludate,
    LAST_UPDATED_BY = f_luby,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where TERRITORY_CODE = X_TERRITORY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end if;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2 default NULL,
  X_NLS_TERRITORY in VARCHAR2 default NULL,
  X_ADDRESS_STYLE in VARCHAR2 default NULL,
  X_ADDRESS_VALIDATION in VARCHAR2 default NULL,
  X_BANK_INFO_STYLE in VARCHAR2 default NULL,
  X_BANK_INFO_VALIDATION in VARCHAR2 default NULL,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
begin
  LOAD_ROW (
    X_TERRITORY_CODE => X_TERRITORY_CODE ,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_EU_CODE =>        X_EU_CODE ,
    X_ISO_NUMERIC_CODE =>   X_ISO_NUMERIC_CODE ,
    X_NLS_TERRITORY =>   X_NLS_TERRITORY,
    X_ALTERNATE_TERRITORY_CODE =>   X_ALTERNATE_TERRITORY_CODE ,
    X_ADDRESS_STYLE =>   X_ADDRESS_STYLE ,
    X_ADDRESS_VALIDATION => X_ADDRESS_VALIDATION ,
    X_BANK_INFO_STYLE =>   X_BANK_INFO_STYLE ,
    X_OWNER               => X_OWNER,
    X_BANK_INFO_VALIDATION => X_BANK_INFO_VALIDATION ,
    X_TERRITORY_SHORT_NAME => X_TERRITORY_SHORT_NAME ,
    X_LAST_UPDATE_DATE    => X_LAST_UPDATE_DATE ,
    X_CUSTOM_MODE         => X_CUSTOM_MODE ,
    X_OBSOLETE_FLAG         => NULL);
end LOAD_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2 default NULL,
  X_NLS_TERRITORY in VARCHAR2 default NULL,
  X_ADDRESS_STYLE in VARCHAR2 default NULL,
  X_ADDRESS_VALIDATION in VARCHAR2 default NULL,
  X_BANK_INFO_STYLE in VARCHAR2 default NULL,
  X_BANK_INFO_VALIDATION in VARCHAR2 default NULL,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_OBSOLETE_FLAG in VARCHAR2
) is
begin
  LOAD_ROW (
    X_TERRITORY_CODE => X_TERRITORY_CODE ,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_EU_CODE =>        X_EU_CODE ,
    X_ISO_NUMERIC_CODE =>   X_ISO_NUMERIC_CODE ,
    X_NLS_TERRITORY =>   X_NLS_TERRITORY,
    X_ALTERNATE_TERRITORY_CODE =>   X_ALTERNATE_TERRITORY_CODE ,
    X_ADDRESS_STYLE =>   X_ADDRESS_STYLE ,
    X_ADDRESS_VALIDATION => X_ADDRESS_VALIDATION ,
    X_BANK_INFO_STYLE =>   X_BANK_INFO_STYLE ,
    X_OWNER               => X_OWNER,
    X_BANK_INFO_VALIDATION => X_BANK_INFO_VALIDATION ,
    X_TERRITORY_SHORT_NAME => X_TERRITORY_SHORT_NAME ,
    X_LAST_UPDATE_DATE    => X_LAST_UPDATE_DATE ,
    X_CUSTOM_MODE         => X_CUSTOM_MODE ,
    X_OBSOLETE_FLAG         => X_OBSOLETE_FLAG ,
    X_ISO_TERRITORY_CODE  => NULL );
end LOAD_ROW;

procedure LOAD_ROW (
  X_TERRITORY_CODE in VARCHAR2,
  X_EU_CODE in VARCHAR2 default NULL,
  X_ISO_NUMERIC_CODE in VARCHAR2,
  X_ALTERNATE_TERRITORY_CODE in VARCHAR2 default NULL,
  X_NLS_TERRITORY in VARCHAR2 default NULL,
  X_ADDRESS_STYLE in VARCHAR2 default NULL,
  X_ADDRESS_VALIDATION in VARCHAR2 default NULL,
  X_BANK_INFO_STYLE in VARCHAR2 default NULL,
  X_BANK_INFO_VALIDATION in VARCHAR2 default NULL,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_OBSOLETE_FLAG in VARCHAR2,
  X_ISO_TERRITORY_CODE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  X_ROWID varchar2(64);
  user_id number;

  -- Bug4493112 - Local variables moved from UPDATE_ROW to LOAD_ROW.

  L_ISO_NUMERIC_CODE VARCHAR2(3);
  L_ALTERNATE_TERRITORY_CODE VARCHAR2(30);
  L_NLS_TERRITORY VARCHAR2(30);
  L_ADDRESS_STYLE VARCHAR2(30);
  L_ADDRESS_VALIDATION VARCHAR2(30);
  L_BANK_INFO_STYLE VARCHAR2(30);
  L_BANK_INFO_VALIDATION VARCHAR2(30);
  L_EU_CODE VARCHAR2(3);
  L_ISO_TERRITORY_CODE VARCHAR2(3);

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

 begin
  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FND_TERRITORIES
  where TERRITORY_CODE = X_TERRITORY_CODE;

   -- Bug4493112 Moved decode select statement from UPDATE_ROW to LOAD_ROW.
   -- Bug4648984 Moved sql to inside exception block to handle the
   --            no data found.

   select
         decode(x_iso_numeric_code, fnd_territories_pkg.null_char, null,
                null, u.iso_numeric_code,
                x_iso_numeric_code),
          decode(x_alternate_territory_code,fnd_territories_pkg.null_char, null,
                  null, u.alternate_territory_code,
                  x_alternate_territory_code),
          decode(x_nls_territory, fnd_territories_pkg.null_char, null,
                  null, u.nls_territory,
                  x_nls_territory),
          decode(x_address_style, fnd_territories_pkg.null_char, null,
                  null, u.address_style,
                  x_address_style),
          decode(x_address_validation, fnd_territories_pkg.null_char, null,
                  null, u.address_validation,
                  x_address_validation),
          decode(x_bank_info_style, fnd_territories_pkg.null_char, null,
                  null, u.bank_info_style,
                  x_bank_info_style),
          decode(x_bank_info_validation, fnd_territories_pkg.null_char, null,
                  null, u.bank_info_validation,
                  x_bank_info_validation),
          decode(x_eu_code, fnd_territories_pkg.null_char, null,
                  null, u.eu_code,
                  x_eu_code),
          decode(x_iso_territory_code, fnd_territories_pkg.null_char, null,
                  null, u.iso_territory_code,
                  x_iso_territory_code)
   into l_iso_numeric_code, l_alternate_territory_code, l_nls_territory,
        l_address_style, l_address_validation, l_bank_info_style,
        l_bank_info_validation, l_eu_code, l_iso_territory_code
    from fnd_territories u
     where territory_code = x_territory_code;

  -- Bug4493112 Modified code to use local variables in UPDATE_ROW and
  --            INSERT_ROW procedure calls.

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  FND_TERRITORIES_PKG.UPDATE_ROW(
    X_TERRITORY_CODE,
    L_EU_CODE,
    L_ISO_NUMERIC_CODE,
    L_ALTERNATE_TERRITORY_CODE,
    L_NLS_TERRITORY,
    L_ADDRESS_STYLE,
    L_ADDRESS_VALIDATION,
    L_BANK_INFO_STYLE,
    L_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    0,
    X_OBSOLETE_FLAG,
    L_ISO_TERRITORY_CODE);
  end if;
  exception
    when no_data_found then

    -- bug7270106 - Need to correctly translate the provided NULL value
    --              for inserting.

    select
          decode(x_iso_numeric_code, fnd_territories_pkg.null_char, null,
                 null, null,x_iso_numeric_code),
          decode(x_alternate_territory_code,fnd_territories_pkg.null_char, null,
                   null, null, x_alternate_territory_code),
          decode(x_nls_territory, fnd_territories_pkg.null_char, null,
                   null, null, x_nls_territory),
          decode(x_address_style, fnd_territories_pkg.null_char, null,
                   null, null, x_address_style),
          decode(x_address_validation, fnd_territories_pkg.null_char, null,
                   null, null, x_address_validation),
          decode(x_bank_info_style, fnd_territories_pkg.null_char, null,
                   null, null, x_bank_info_style),
          decode(x_bank_info_validation, fnd_territories_pkg.null_char, null,
                   null, null, x_bank_info_validation),
          decode(x_eu_code, fnd_territories_pkg.null_char, null,
                   null, null, x_eu_code),
          decode(x_iso_territory_code, fnd_territories_pkg.null_char, null,
                   null, null, x_iso_territory_code)
    into l_iso_numeric_code, l_alternate_territory_code, l_nls_territory,
         l_address_style, l_address_validation, l_bank_info_style,
         l_bank_info_validation, l_eu_code, l_iso_territory_code
     from dual;

    FND_TERRITORIES_PKG.INSERT_ROW(
    X_ROWID,
    X_TERRITORY_CODE,
    L_EU_CODE,
    L_ISO_NUMERIC_CODE,
    L_ALTERNATE_TERRITORY_CODE,
    L_NLS_TERRITORY,
    L_ADDRESS_STYLE,
    L_ADDRESS_VALIDATION,
    L_BANK_INFO_STYLE,
    L_BANK_INFO_VALIDATION,
    X_TERRITORY_SHORT_NAME,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    f_ludate,
    f_luby,
    0,
    X_OBSOLETE_FLAG,
    L_ISO_TERRITORY_CODE);
 end;
end LOAD_ROW;

end FND_TERRITORIES_PKG;

/
