--------------------------------------------------------
--  DDL for Package Body FEM_ACCRBMACROS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_ACCRBMACROS_PKG" as
/* $Header: fem_abusgmcr_pkb.plb 120.0 2005/06/06 19:35:54 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_AB_USAGE_MACRO_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_AB_USAGE_MACRO_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_ACCRBMACROS_B
    where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE
    ;
begin
  insert into FEM_ACCRBMACROS_B (
    AB_USAGE_MACRO_CODE,
    ENABLED_FLAG,
    PERSONAL_FLAG,
    READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_AB_USAGE_MACRO_CODE,
    X_ENABLED_FLAG,
    X_PERSONAL_FLAG,
    X_READ_ONLY_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_ACCRBMACROS_TL (
    AB_USAGE_MACRO_CODE,
    AB_USAGE_MACRO_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_AB_USAGE_MACRO_CODE,
    X_AB_USAGE_MACRO_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_ACCRBMACROS_TL T
    where T.AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE
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
  X_AB_USAGE_MACRO_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_AB_USAGE_MACRO_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      PERSONAL_FLAG,
      READ_ONLY_FLAG,
      OBJECT_VERSION_NUMBER
    from FEM_ACCRBMACROS_B
    where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE
    for update of AB_USAGE_MACRO_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      AB_USAGE_MACRO_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_ACCRBMACROS_TL
    where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of AB_USAGE_MACRO_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.AB_USAGE_MACRO_NAME = X_AB_USAGE_MACRO_NAME)
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
  X_AB_USAGE_MACRO_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_AB_USAGE_MACRO_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_ACCRBMACROS_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_ACCRBMACROS_TL set
    AB_USAGE_MACRO_NAME = X_AB_USAGE_MACRO_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_AB_USAGE_MACRO_CODE in VARCHAR2
) is
begin
  delete from FEM_ACCRBMACROS_TL
  where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_ACCRBMACROS_B
  where AB_USAGE_MACRO_CODE = X_AB_USAGE_MACRO_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_ACCRBMACROS_TL T
  where not exists
    (select NULL
    from FEM_ACCRBMACROS_B B
    where B.AB_USAGE_MACRO_CODE = T.AB_USAGE_MACRO_CODE
    );

  update FEM_ACCRBMACROS_TL T set (
      AB_USAGE_MACRO_NAME,
      DESCRIPTION
    ) = (select
      B.AB_USAGE_MACRO_NAME,
      B.DESCRIPTION
    from FEM_ACCRBMACROS_TL B
    where B.AB_USAGE_MACRO_CODE = T.AB_USAGE_MACRO_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AB_USAGE_MACRO_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.AB_USAGE_MACRO_CODE,
      SUBT.LANGUAGE
    from FEM_ACCRBMACROS_TL SUBB, FEM_ACCRBMACROS_TL SUBT
    where SUBB.AB_USAGE_MACRO_CODE = SUBT.AB_USAGE_MACRO_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.AB_USAGE_MACRO_NAME <> SUBT.AB_USAGE_MACRO_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_ACCRBMACROS_TL (
    AB_USAGE_MACRO_CODE,
    AB_USAGE_MACRO_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.AB_USAGE_MACRO_CODE,
    B.AB_USAGE_MACRO_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_ACCRBMACROS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_ACCRBMACROS_TL T
    where T.AB_USAGE_MACRO_CODE = B.AB_USAGE_MACRO_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_AB_USAGE_MACRO_CODE in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_AB_USAGE_MACRO_NAME in varchar2,
        x_description in varchar2,
        x_custom_mode in varchar2) is

        owner_id number;
        ludate date;
        row_id varchar2(64);
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
          from FEM_ACCRBMACROS_TL
          where AB_USAGE_MACRO_CODE = x_AB_USAGE_MACRO_CODE
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_ACCRBMACROS_TL set
              AB_USAGE_MACRO_NAME = decode(x_AB_USAGE_MACRO_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_AB_USAGE_MACRO_NAME,                  -- No change
			       x_AB_USAGE_MACRO_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and AB_USAGE_MACRO_CODE = x_AB_USAGE_MACRO_CODE;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_ACCRBMACROS_PKG;

/
