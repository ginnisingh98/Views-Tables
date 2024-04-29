--------------------------------------------------------
--  DDL for Package Body FEM_OBJECT_CATALOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_OBJECT_CATALOG_PKG" as
/* $Header: fem_objcat_pkb.plb 120.0 2005/06/06 19:26:18 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_OBJECT_CATALOG_B
    where OBJECT_ID = X_OBJECT_ID
    ;
begin
  insert into FEM_OBJECT_CATALOG_B (
    OBJECT_ID,
    OBJECT_TYPE_CODE,
    FOLDER_ID,
    LOCAL_VS_COMBO_ID,
    OBJECT_ACCESS_CODE,
    OBJECT_ORIGIN_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_ID,
    X_OBJECT_TYPE_CODE,
    X_FOLDER_ID,
    X_LOCAL_VS_COMBO_ID,
    X_OBJECT_ACCESS_CODE,
    X_OBJECT_ORIGIN_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_OBJECT_CATALOG_TL (
    OBJECT_ID,
    OBJECT_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_ID,
    X_OBJECT_NAME,
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
    from FEM_OBJECT_CATALOG_TL T
    where T.OBJECT_ID = X_OBJECT_ID
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
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_TYPE_CODE,
      FOLDER_ID,
      LOCAL_VS_COMBO_ID,
      OBJECT_ACCESS_CODE,
      OBJECT_ORIGIN_CODE,
      OBJECT_VERSION_NUMBER
    from FEM_OBJECT_CATALOG_B
    where OBJECT_ID = X_OBJECT_ID
    for update of OBJECT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OBJECT_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_OBJECT_CATALOG_TL
    where OBJECT_ID = X_OBJECT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OBJECT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE)
      AND (recinfo.FOLDER_ID = X_FOLDER_ID)
      AND ((recinfo.LOCAL_VS_COMBO_ID = X_LOCAL_VS_COMBO_ID)
           OR ((recinfo.LOCAL_VS_COMBO_ID is null) AND (X_LOCAL_VS_COMBO_ID is null)))
      AND (recinfo.OBJECT_ACCESS_CODE = X_OBJECT_ACCESS_CODE)
      AND (recinfo.OBJECT_ORIGIN_CODE = X_OBJECT_ORIGIN_CODE)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.OBJECT_NAME = X_OBJECT_NAME)
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
  X_OBJECT_ID in NUMBER,
  X_OBJECT_TYPE_CODE in VARCHAR2,
  X_FOLDER_ID in NUMBER,
  X_LOCAL_VS_COMBO_ID in NUMBER,
  X_OBJECT_ACCESS_CODE in VARCHAR2,
  X_OBJECT_ORIGIN_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_OBJECT_CATALOG_B set
    OBJECT_TYPE_CODE = X_OBJECT_TYPE_CODE,
    FOLDER_ID = X_FOLDER_ID,
    LOCAL_VS_COMBO_ID = X_LOCAL_VS_COMBO_ID,
    OBJECT_ACCESS_CODE = X_OBJECT_ACCESS_CODE,
    OBJECT_ORIGIN_CODE = X_OBJECT_ORIGIN_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_OBJECT_CATALOG_TL set
    OBJECT_NAME = X_OBJECT_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_ID = X_OBJECT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_ID in NUMBER
) is
begin
  delete from FEM_OBJECT_CATALOG_TL
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_OBJECT_CATALOG_B
  where OBJECT_ID = X_OBJECT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_OBJECT_CATALOG_TL T
  where not exists
    (select NULL
    from FEM_OBJECT_CATALOG_B B
    where B.OBJECT_ID = T.OBJECT_ID
    );

  update FEM_OBJECT_CATALOG_TL T set (
      OBJECT_NAME,
      DESCRIPTION
    ) = (select
      B.OBJECT_NAME,
      B.DESCRIPTION
    from FEM_OBJECT_CATALOG_TL B
    where B.OBJECT_ID = T.OBJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_ID,
      SUBT.LANGUAGE
    from FEM_OBJECT_CATALOG_TL SUBB, FEM_OBJECT_CATALOG_TL SUBT
    where SUBB.OBJECT_ID = SUBT.OBJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OBJECT_NAME <> SUBT.OBJECT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_OBJECT_CATALOG_TL (
    OBJECT_ID,
    OBJECT_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OBJECT_ID,
    B.OBJECT_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_OBJECT_CATALOG_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_OBJECT_CATALOG_TL T
    where T.OBJECT_ID = B.OBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_OBJECT_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_OBJECT_NAME in varchar2,
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
          from FEM_OBJECT_CATALOG_TL
          where OBJECT_ID = x_OBJECT_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_OBJECT_CATALOG_TL set
              OBJECT_NAME = decode(x_OBJECT_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_OBJECT_NAME,                  -- No change
			       x_OBJECT_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and OBJECT_ID = x_OBJECT_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_OBJECT_CATALOG_PKG;

/
