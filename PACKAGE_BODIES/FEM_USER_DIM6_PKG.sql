--------------------------------------------------------
--  DDL for Package Body FEM_USER_DIM6_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_USER_DIM6_PKG" as
/* $Header: fem_usrdim6_pkb.plb 120.1 2005/06/27 13:29:43 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_USER_DIM6_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM6_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM6_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_USER_DIM6_B
    where USER_DIM6_ID = X_USER_DIM6_ID
    and VALUE_SET_ID = X_VALUE_SET_ID
    ;
begin
  insert into FEM_USER_DIM6_B (
    USER_DIM6_ID,
    VALUE_SET_ID,
    DIMENSION_GROUP_ID,
    USER_DIM6_DISPLAY_CODE,
    ENABLED_FLAG,
    PERSONAL_FLAG,
    OBJECT_VERSION_NUMBER,
    READ_ONLY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_USER_DIM6_ID,
    X_VALUE_SET_ID,
    X_DIMENSION_GROUP_ID,
    X_USER_DIM6_DISPLAY_CODE,
    X_ENABLED_FLAG,
    X_PERSONAL_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_READ_ONLY_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_USER_DIM6_TL (
    USER_DIM6_ID,
    VALUE_SET_ID,
    USER_DIM6_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_USER_DIM6_ID,
    X_VALUE_SET_ID,
    X_USER_DIM6_NAME,
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
    from FEM_USER_DIM6_TL T
    where T.USER_DIM6_ID = X_USER_DIM6_ID
    and T.VALUE_SET_ID = X_VALUE_SET_ID
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
  X_USER_DIM6_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM6_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM6_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DIMENSION_GROUP_ID,
      USER_DIM6_DISPLAY_CODE,
      ENABLED_FLAG,
      PERSONAL_FLAG,
      OBJECT_VERSION_NUMBER,
      READ_ONLY_FLAG
    from FEM_USER_DIM6_B
    where USER_DIM6_ID = X_USER_DIM6_ID
    and VALUE_SET_ID = X_VALUE_SET_ID
    for update of USER_DIM6_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_DIM6_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_USER_DIM6_TL
    where USER_DIM6_ID = X_USER_DIM6_ID
    and VALUE_SET_ID = X_VALUE_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of USER_DIM6_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID)
           OR ((recinfo.DIMENSION_GROUP_ID is null) AND (X_DIMENSION_GROUP_ID is null)))
      AND (recinfo.USER_DIM6_DISPLAY_CODE = X_USER_DIM6_DISPLAY_CODE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_DIM6_NAME = X_USER_DIM6_NAME)
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
  X_USER_DIM6_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_USER_DIM6_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_USER_DIM6_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_USER_DIM6_B set
    DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID,
    USER_DIM6_DISPLAY_CODE = X_USER_DIM6_DISPLAY_CODE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where USER_DIM6_ID = X_USER_DIM6_ID
  and VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_USER_DIM6_TL set
    USER_DIM6_NAME = X_USER_DIM6_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where USER_DIM6_ID = X_USER_DIM6_ID
  and VALUE_SET_ID = X_VALUE_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_USER_DIM6_ID in NUMBER,
  X_VALUE_SET_ID in NUMBER
) is
begin
  delete from FEM_USER_DIM6_TL
  where USER_DIM6_ID = X_USER_DIM6_ID
  and VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_USER_DIM6_B
  where USER_DIM6_ID = X_USER_DIM6_ID
  and VALUE_SET_ID = X_VALUE_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_USER_DIM6_TL T
  where not exists
    (select NULL
    from FEM_USER_DIM6_B B
    where B.USER_DIM6_ID = T.USER_DIM6_ID
    and B.VALUE_SET_ID = T.VALUE_SET_ID
    );

  update FEM_USER_DIM6_TL T set (
      USER_DIM6_NAME,
      DESCRIPTION
    ) = (select
      B.USER_DIM6_NAME,
      B.DESCRIPTION
    from FEM_USER_DIM6_TL B
    where B.USER_DIM6_ID = T.USER_DIM6_ID
    and B.VALUE_SET_ID = T.VALUE_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.USER_DIM6_ID,
      T.VALUE_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.USER_DIM6_ID,
      SUBT.VALUE_SET_ID,
      SUBT.LANGUAGE
    from FEM_USER_DIM6_TL SUBB, FEM_USER_DIM6_TL SUBT
    where SUBB.USER_DIM6_ID = SUBT.USER_DIM6_ID
    and SUBB.VALUE_SET_ID = SUBT.VALUE_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_DIM6_NAME <> SUBT.USER_DIM6_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_USER_DIM6_TL (
    USER_DIM6_ID,
    VALUE_SET_ID,
    USER_DIM6_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.USER_DIM6_ID,
    B.VALUE_SET_ID,
    B.USER_DIM6_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_USER_DIM6_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_USER_DIM6_TL T
    where T.USER_DIM6_ID = B.USER_DIM6_ID
    and T.VALUE_SET_ID = B.VALUE_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_USER_DIM6_ID in number,
        x_VALUE_SET_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_USER_DIM6_NAME in varchar2,
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
          from FEM_USER_DIM6_TL
          where USER_DIM6_ID = x_USER_DIM6_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_USER_DIM6_TL set
              USER_DIM6_NAME = decode(x_USER_DIM6_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_USER_DIM6_NAME,                  -- No change
			       x_USER_DIM6_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and USER_DIM6_ID = x_USER_DIM6_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_USER_DIM6_PKG;

/
