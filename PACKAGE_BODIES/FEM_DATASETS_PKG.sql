--------------------------------------------------------
--  DDL for Package Body FEM_DATASETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DATASETS_PKG" as
/* $Header: fem_dataset_pkb.plb 120.0 2005/06/06 18:58:26 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATASET_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_DATASET_DISPLAY_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATASET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_DATASETS_B
    where DATASET_CODE = X_DATASET_CODE
    ;
begin
  insert into FEM_DATASETS_B (
    DATASET_CODE,
    ENABLED_FLAG,
    DATASET_DISPLAY_CODE,
    READ_ONLY_FLAG,
    PERSONAL_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DATASET_CODE,
    X_ENABLED_FLAG,
    X_DATASET_DISPLAY_CODE,
    X_READ_ONLY_FLAG,
    X_PERSONAL_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_DATASETS_TL (
    DATASET_CODE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    DATASET_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATASET_CODE,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_DATASET_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_DATASETS_TL T
    where T.DATASET_CODE = X_DATASET_CODE
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
  X_DATASET_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_DATASET_DISPLAY_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATASET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      DATASET_DISPLAY_CODE,
      READ_ONLY_FLAG,
      PERSONAL_FLAG,
      OBJECT_VERSION_NUMBER
    from FEM_DATASETS_B
    where DATASET_CODE = X_DATASET_CODE
    for update of DATASET_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DATASET_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_DATASETS_TL
    where DATASET_CODE = X_DATASET_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DATASET_CODE nowait;
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
      AND (recinfo.DATASET_DISPLAY_CODE = X_DATASET_DISPLAY_CODE)
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND ((recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
           OR ((recinfo.PERSONAL_FLAG is null) AND (X_PERSONAL_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DATASET_NAME = X_DATASET_NAME)
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
  X_DATASET_CODE in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_DATASET_DISPLAY_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DATASET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_DATASETS_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    DATASET_DISPLAY_CODE = X_DATASET_DISPLAY_CODE,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATASET_CODE = X_DATASET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_DATASETS_TL set
    DATASET_NAME = X_DATASET_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATASET_CODE = X_DATASET_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATASET_CODE in NUMBER
) is
begin
  delete from FEM_DATASETS_TL
  where DATASET_CODE = X_DATASET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_DATASETS_B
  where DATASET_CODE = X_DATASET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_DATASETS_TL T
  where not exists
    (select NULL
    from FEM_DATASETS_B B
    where B.DATASET_CODE = T.DATASET_CODE
    );

  update FEM_DATASETS_TL T set (
      DATASET_NAME,
      DESCRIPTION
    ) = (select
      B.DATASET_NAME,
      B.DESCRIPTION
    from FEM_DATASETS_TL B
    where B.DATASET_CODE = T.DATASET_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATASET_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.DATASET_CODE,
      SUBT.LANGUAGE
    from FEM_DATASETS_TL SUBB, FEM_DATASETS_TL SUBT
    where SUBB.DATASET_CODE = SUBT.DATASET_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATASET_NAME <> SUBT.DATASET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_DATASETS_TL (
    DATASET_CODE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    DATASET_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DATASET_CODE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.DATASET_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_DATASETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_DATASETS_TL T
    where T.DATASET_CODE = B.DATASET_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_DATASET_CODE in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_DATASET_NAME in varchar2,
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
          from FEM_DATASETS_TL
          where DATASET_CODE = x_DATASET_CODE
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_DATASETS_TL set
              DATASET_NAME = decode(x_DATASET_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_DATASET_NAME,                  -- No change
			       x_DATASET_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and DATASET_CODE = x_DATASET_CODE;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_DATASETS_PKG;

/
