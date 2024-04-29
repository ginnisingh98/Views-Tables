--------------------------------------------------------
--  DDL for Package Body FEM_CCTR_ORG_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_CCTR_ORG_TYPES_PKG" as
/* $Header: fem_cctrorgt_pkb.plb 120.0 2005/06/06 19:53:45 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CCTR_ORG_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_CCTR_ORG_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_CCTR_ORG_TYPES_B
    where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE
    ;
begin
  insert into FEM_CCTR_ORG_TYPES_B (
    OBJECT_VERSION_NUMBER,
    CCTR_ORG_TYPE_CODE,
    ENABLED_FLAG,
    READ_ONLY_FLAG,
    PERSONAL_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_CCTR_ORG_TYPE_CODE,
    X_ENABLED_FLAG,
    X_READ_ONLY_FLAG,
    X_PERSONAL_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_CCTR_ORG_TYPES_TL (
    CCTR_ORG_TYPE_CODE,
    CCTR_ORG_TYPE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CCTR_ORG_TYPE_CODE,
    X_CCTR_ORG_TYPE_NAME,
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
    from FEM_CCTR_ORG_TYPES_TL T
    where T.CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE
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
  X_CCTR_ORG_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_CCTR_ORG_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ENABLED_FLAG,
      READ_ONLY_FLAG,
      PERSONAL_FLAG
    from FEM_CCTR_ORG_TYPES_B
    where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE
    for update of CCTR_ORG_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CCTR_ORG_TYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_CCTR_ORG_TYPES_TL
    where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CCTR_ORG_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CCTR_ORG_TYPE_NAME = X_CCTR_ORG_TYPE_NAME)
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
  X_CCTR_ORG_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_CCTR_ORG_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_CCTR_ORG_TYPES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ENABLED_FLAG = X_ENABLED_FLAG,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_CCTR_ORG_TYPES_TL set
    CCTR_ORG_TYPE_NAME = X_CCTR_ORG_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CCTR_ORG_TYPE_CODE in VARCHAR2
) is
begin
  delete from FEM_CCTR_ORG_TYPES_TL
  where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_CCTR_ORG_TYPES_B
  where CCTR_ORG_TYPE_CODE = X_CCTR_ORG_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_CCTR_ORG_TYPES_TL T
  where not exists
    (select NULL
    from FEM_CCTR_ORG_TYPES_B B
    where B.CCTR_ORG_TYPE_CODE = T.CCTR_ORG_TYPE_CODE
    );

  update FEM_CCTR_ORG_TYPES_TL T set (
      CCTR_ORG_TYPE_NAME,
      DESCRIPTION
    ) = (select
      B.CCTR_ORG_TYPE_NAME,
      B.DESCRIPTION
    from FEM_CCTR_ORG_TYPES_TL B
    where B.CCTR_ORG_TYPE_CODE = T.CCTR_ORG_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CCTR_ORG_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.CCTR_ORG_TYPE_CODE,
      SUBT.LANGUAGE
    from FEM_CCTR_ORG_TYPES_TL SUBB, FEM_CCTR_ORG_TYPES_TL SUBT
    where SUBB.CCTR_ORG_TYPE_CODE = SUBT.CCTR_ORG_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CCTR_ORG_TYPE_NAME <> SUBT.CCTR_ORG_TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_CCTR_ORG_TYPES_TL (
    CCTR_ORG_TYPE_CODE,
    CCTR_ORG_TYPE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CCTR_ORG_TYPE_CODE,
    B.CCTR_ORG_TYPE_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_CCTR_ORG_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_CCTR_ORG_TYPES_TL T
    where T.CCTR_ORG_TYPE_CODE = B.CCTR_ORG_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_CCTR_ORG_TYPE_CODE in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_CCTR_ORG_TYPE_NAME in varchar2,
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
          from FEM_CCTR_ORG_TYPES_TL
          where CCTR_ORG_TYPE_CODE = x_CCTR_ORG_TYPE_CODE
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_CCTR_ORG_TYPES_TL set
              CCTR_ORG_TYPE_NAME = decode(x_CCTR_ORG_TYPE_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_CCTR_ORG_TYPE_NAME,                  -- No change
			       x_CCTR_ORG_TYPE_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and CCTR_ORG_TYPE_CODE = x_CCTR_ORG_TYPE_CODE;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_CCTR_ORG_TYPES_PKG;

/
