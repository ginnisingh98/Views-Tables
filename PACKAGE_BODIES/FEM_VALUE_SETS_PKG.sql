--------------------------------------------------------
--  DDL for Package Body FEM_VALUE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_VALUE_SETS_PKG" as
/* $Header: fem_valueset_pkb.plb 120.0 2005/06/06 19:44:19 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VALUE_SET_ID in NUMBER,
  X_DEFAULT_LOAD_MEMBER_ID in NUMBER,
  X_DEFAULT_MEMBER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DEFAULT_HIERARCHY_OBJ_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_VALUE_SET_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_VALUE_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_VALUE_SETS_B
    where VALUE_SET_ID = X_VALUE_SET_ID
    ;
begin
  insert into FEM_VALUE_SETS_B (
    DEFAULT_LOAD_MEMBER_ID,
    VALUE_SET_ID,
    DEFAULT_MEMBER_ID,
    OBJECT_VERSION_NUMBER,
    DEFAULT_HIERARCHY_OBJ_ID,
    READ_ONLY_FLAG,
    VALUE_SET_DISPLAY_CODE,
    DIMENSION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DEFAULT_LOAD_MEMBER_ID,
    X_VALUE_SET_ID,
    X_DEFAULT_MEMBER_ID,
    X_OBJECT_VERSION_NUMBER,
    X_DEFAULT_HIERARCHY_OBJ_ID,
    X_READ_ONLY_FLAG,
    X_VALUE_SET_DISPLAY_CODE,
    X_DIMENSION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_VALUE_SETS_TL (
    VALUE_SET_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    VALUE_SET_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_VALUE_SET_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_VALUE_SET_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_VALUE_SETS_TL T
    where T.VALUE_SET_ID = X_VALUE_SET_ID
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
  X_VALUE_SET_ID in NUMBER,
  X_DEFAULT_LOAD_MEMBER_ID in NUMBER,
  X_DEFAULT_MEMBER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DEFAULT_HIERARCHY_OBJ_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_VALUE_SET_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_VALUE_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DEFAULT_LOAD_MEMBER_ID,
      DEFAULT_MEMBER_ID,
      OBJECT_VERSION_NUMBER,
      DEFAULT_HIERARCHY_OBJ_ID,
      READ_ONLY_FLAG,
      VALUE_SET_DISPLAY_CODE,
      DIMENSION_ID
    from FEM_VALUE_SETS_B
    where VALUE_SET_ID = X_VALUE_SET_ID
    for update of VALUE_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALUE_SET_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_VALUE_SETS_TL
    where VALUE_SET_ID = X_VALUE_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of VALUE_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DEFAULT_LOAD_MEMBER_ID = X_DEFAULT_LOAD_MEMBER_ID)
           OR ((recinfo.DEFAULT_LOAD_MEMBER_ID is null) AND (X_DEFAULT_LOAD_MEMBER_ID is null)))
      AND ((recinfo.DEFAULT_MEMBER_ID = X_DEFAULT_MEMBER_ID)
           OR ((recinfo.DEFAULT_MEMBER_ID is null) AND (X_DEFAULT_MEMBER_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.DEFAULT_HIERARCHY_OBJ_ID = X_DEFAULT_HIERARCHY_OBJ_ID)
           OR ((recinfo.DEFAULT_HIERARCHY_OBJ_ID is null) AND (X_DEFAULT_HIERARCHY_OBJ_ID is null)))
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.VALUE_SET_DISPLAY_CODE = X_VALUE_SET_DISPLAY_CODE)
      AND (recinfo.DIMENSION_ID = X_DIMENSION_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VALUE_SET_NAME = X_VALUE_SET_NAME)
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
  X_VALUE_SET_ID in NUMBER,
  X_DEFAULT_LOAD_MEMBER_ID in NUMBER,
  X_DEFAULT_MEMBER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DEFAULT_HIERARCHY_OBJ_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_VALUE_SET_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_ID in NUMBER,
  X_VALUE_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_VALUE_SETS_B set
    DEFAULT_LOAD_MEMBER_ID = X_DEFAULT_LOAD_MEMBER_ID,
    DEFAULT_MEMBER_ID = X_DEFAULT_MEMBER_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DEFAULT_HIERARCHY_OBJ_ID = X_DEFAULT_HIERARCHY_OBJ_ID,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    VALUE_SET_DISPLAY_CODE = X_VALUE_SET_DISPLAY_CODE,
    DIMENSION_ID = X_DIMENSION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_VALUE_SETS_TL set
    VALUE_SET_NAME = X_VALUE_SET_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where VALUE_SET_ID = X_VALUE_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_VALUE_SET_ID in NUMBER
) is
begin
  delete from FEM_VALUE_SETS_TL
  where VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_VALUE_SETS_B
  where VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_VALUE_SETS_TL T
  where not exists
    (select NULL
    from FEM_VALUE_SETS_B B
    where B.VALUE_SET_ID = T.VALUE_SET_ID
    );

  update FEM_VALUE_SETS_TL T set (
      VALUE_SET_NAME,
      DESCRIPTION
    ) = (select
      B.VALUE_SET_NAME,
      B.DESCRIPTION
    from FEM_VALUE_SETS_TL B
    where B.VALUE_SET_ID = T.VALUE_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.VALUE_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.VALUE_SET_ID,
      SUBT.LANGUAGE
    from FEM_VALUE_SETS_TL SUBB, FEM_VALUE_SETS_TL SUBT
    where SUBB.VALUE_SET_ID = SUBT.VALUE_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALUE_SET_NAME <> SUBT.VALUE_SET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_VALUE_SETS_TL (
    VALUE_SET_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    VALUE_SET_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.VALUE_SET_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.VALUE_SET_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_VALUE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_VALUE_SETS_TL T
    where T.VALUE_SET_ID = B.VALUE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_VALUE_SET_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_VALUE_SET_NAME in varchar2,
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
          from FEM_VALUE_SETS_TL
          where VALUE_SET_ID = x_VALUE_SET_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_VALUE_SETS_TL set
              VALUE_SET_NAME = decode(x_VALUE_SET_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_VALUE_SET_NAME,                  -- No change
			       x_VALUE_SET_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and VALUE_SET_ID = x_VALUE_SET_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_VALUE_SETS_PKG;

/
