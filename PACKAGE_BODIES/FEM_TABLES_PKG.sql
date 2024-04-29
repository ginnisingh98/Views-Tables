--------------------------------------------------------
--  DDL for Package Body FEM_TABLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_TABLES_PKG" as
/* $Header: fem_tables_pkb.plb 120.5 2007/05/15 22:58:17 rflippo ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_OWNER in VARCHAR2,
  X_DI_VIEW_NAME in VARCHAR2,
  X_REGISTRATION_STATUS_CODE in VARCHAR2,
  X_INTERFACE_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_NAME in VARCHAR2,
  X_TABLE_OWNER_APPLICATION_ID in NUMBER,
  X_TABLE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_TABLES_B
    where TABLE_NAME = X_TABLE_NAME
    ;
begin
  insert into FEM_TABLES_B (
    PROC_KEY_INDEX_OWNER,
    DI_VIEW_NAME,
    REGISTRATION_STATUS_CODE,
    INTERFACE_TABLE_NAME,
    PROC_KEY_INDEX_NAME,
    TABLE_NAME,
    TABLE_OWNER_APPLICATION_ID,
    TABLE_ID,
    ENABLED_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROC_KEY_INDEX_OWNER,
    X_DI_VIEW_NAME,
    X_REGISTRATION_STATUS_CODE,
    X_INTERFACE_TABLE_NAME,
    X_PROC_KEY_INDEX_NAME,
    X_TABLE_NAME,
    X_TABLE_OWNER_APPLICATION_ID,
    X_TABLE_ID,
    X_ENABLED_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_TABLES_TL (
    TABLE_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TABLE_NAME,
    X_DISPLAY_NAME,
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
    from FEM_TABLES_TL T
    where T.TABLE_NAME = X_TABLE_NAME
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
  X_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_OWNER in VARCHAR2,
  X_DI_VIEW_NAME in VARCHAR2,
  X_REGISTRATION_STATUS_CODE in VARCHAR2,
  X_INTERFACE_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_NAME in VARCHAR2,
  X_TABLE_OWNER_APPLICATION_ID in NUMBER,
  X_TABLE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PROC_KEY_INDEX_OWNER,
      DI_VIEW_NAME,
      REGISTRATION_STATUS_CODE,
      INTERFACE_TABLE_NAME,
      PROC_KEY_INDEX_NAME,
      TABLE_OWNER_APPLICATION_ID,
      TABLE_ID,
      ENABLED_FLAG,
      OBJECT_VERSION_NUMBER
    from FEM_TABLES_B
    where TABLE_NAME = X_TABLE_NAME
    for update of TABLE_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_TABLES_TL
    where TABLE_NAME = X_TABLE_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TABLE_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PROC_KEY_INDEX_OWNER = X_PROC_KEY_INDEX_OWNER)
           OR ((recinfo.PROC_KEY_INDEX_OWNER is null) AND (X_PROC_KEY_INDEX_OWNER is null)))
      AND ((recinfo.DI_VIEW_NAME = X_DI_VIEW_NAME)
           OR ((recinfo.DI_VIEW_NAME is null) AND (X_DI_VIEW_NAME is null)))
      AND ((recinfo.REGISTRATION_STATUS_CODE = X_REGISTRATION_STATUS_CODE)
           OR ((recinfo.REGISTRATION_STATUS_CODE is null) AND (X_REGISTRATION_STATUS_CODE is null)))
      AND ((recinfo.INTERFACE_TABLE_NAME = X_INTERFACE_TABLE_NAME)
           OR ((recinfo.INTERFACE_TABLE_NAME is null) AND (X_INTERFACE_TABLE_NAME is null)))
      AND ((recinfo.PROC_KEY_INDEX_NAME = X_PROC_KEY_INDEX_NAME)
           OR ((recinfo.PROC_KEY_INDEX_NAME is null) AND (X_PROC_KEY_INDEX_NAME is null)))
      AND ((recinfo.TABLE_OWNER_APPLICATION_ID = X_TABLE_OWNER_APPLICATION_ID)
           OR ((recinfo.TABLE_OWNER_APPLICATION_ID is null) AND (X_TABLE_OWNER_APPLICATION_ID is null)))
      AND (recinfo.TABLE_ID = X_TABLE_ID)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_OWNER in VARCHAR2,
  X_DI_VIEW_NAME in VARCHAR2,
  X_REGISTRATION_STATUS_CODE in VARCHAR2,
  X_INTERFACE_TABLE_NAME in VARCHAR2,
  X_PROC_KEY_INDEX_NAME in VARCHAR2,
  X_TABLE_OWNER_APPLICATION_ID in NUMBER,
  X_TABLE_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_TABLES_B set
    PROC_KEY_INDEX_OWNER = X_PROC_KEY_INDEX_OWNER,
    DI_VIEW_NAME = X_DI_VIEW_NAME,
    REGISTRATION_STATUS_CODE = X_REGISTRATION_STATUS_CODE,
    INTERFACE_TABLE_NAME = X_INTERFACE_TABLE_NAME,
    PROC_KEY_INDEX_NAME = X_PROC_KEY_INDEX_NAME,
    TABLE_OWNER_APPLICATION_ID = X_TABLE_OWNER_APPLICATION_ID,
    TABLE_ID = X_TABLE_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TABLE_NAME = X_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_TABLES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TABLE_NAME = X_TABLE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TABLE_NAME in VARCHAR2
) is
begin
  delete from FEM_TABLES_TL
  where TABLE_NAME = X_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_TABLES_B
  where TABLE_NAME = X_TABLE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_TABLES_TL T
  where not exists
    (select NULL
    from FEM_TABLES_B B
    where B.TABLE_NAME = T.TABLE_NAME
    );

  update FEM_TABLES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FEM_TABLES_TL B
    where B.TABLE_NAME = T.TABLE_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TABLE_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.TABLE_NAME,
      SUBT.LANGUAGE
    from FEM_TABLES_TL SUBB, FEM_TABLES_TL SUBT
    where SUBB.TABLE_NAME = SUBT.TABLE_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FEM_TABLES_TL (
    TABLE_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TABLE_NAME,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_TABLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_TABLES_TL T
    where T.TABLE_NAME = B.TABLE_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_TABLE_NAME in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_DISPLAY_NAME in varchar2,
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
          from FEM_TABLES_TL
          where TABLE_NAME = x_TABLE_NAME
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_TABLES_TL set
              DISPLAY_NAME = decode(x_DISPLAY_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_DISPLAY_NAME,                  -- No change
			       x_DISPLAY_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and TABLE_NAME = x_TABLE_NAME;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_TABLES_PKG;

/
