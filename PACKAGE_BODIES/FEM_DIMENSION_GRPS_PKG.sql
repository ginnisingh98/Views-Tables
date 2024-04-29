--------------------------------------------------------
--  DDL for Package Body FEM_DIMENSION_GRPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIMENSION_GRPS_PKG" as
/* $Header: fem_dimgrp_pkb.plb 120.0 2005/06/06 19:58:16 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DIMENSION_GROUP_ID in NUMBER,
  X_TIME_DIMENSION_GROUP_KEY in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_DIMENSION_GROUP_SEQ in NUMBER,
  X_TIME_GROUP_TYPE_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DIMENSION_GROUP_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_DIMENSION_GRPS_B
    where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID
    ;
begin
  insert into FEM_DIMENSION_GRPS_B (
    TIME_DIMENSION_GROUP_KEY,
    DIMENSION_GROUP_ID,
    DIMENSION_ID,
    DIMENSION_GROUP_SEQ,
    TIME_GROUP_TYPE_CODE,
    READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER,
    PERSONAL_FLAG,
    ENABLED_FLAG,
    DIMENSION_GROUP_DISPLAY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TIME_DIMENSION_GROUP_KEY,
    X_DIMENSION_GROUP_ID,
    X_DIMENSION_ID,
    X_DIMENSION_GROUP_SEQ,
    X_TIME_GROUP_TYPE_CODE,
    X_READ_ONLY_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_PERSONAL_FLAG,
    X_ENABLED_FLAG,
    X_DIMENSION_GROUP_DISPLAY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_DIMENSION_GRPS_TL (
    DIMENSION_GROUP_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DIMENSION_ID,
    DIMENSION_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DIMENSION_GROUP_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DIMENSION_ID,
    X_DIMENSION_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FEM_DIMENSION_GRPS_TL T
    where T.DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID
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
  X_DIMENSION_GROUP_ID in NUMBER,
  X_TIME_DIMENSION_GROUP_KEY in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_DIMENSION_GROUP_SEQ in NUMBER,
  X_TIME_GROUP_TYPE_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DIMENSION_GROUP_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TIME_DIMENSION_GROUP_KEY,
      DIMENSION_ID,
      DIMENSION_GROUP_SEQ,
      TIME_GROUP_TYPE_CODE,
      READ_ONLY_FLAG,
      OBJECT_VERSION_NUMBER,
      PERSONAL_FLAG,
      ENABLED_FLAG,
      DIMENSION_GROUP_DISPLAY_CODE
    from FEM_DIMENSION_GRPS_B
    where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID
    for update of DIMENSION_GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DIMENSION_GROUP_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_DIMENSION_GRPS_TL
    where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DIMENSION_GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.TIME_DIMENSION_GROUP_KEY = X_TIME_DIMENSION_GROUP_KEY)
           OR ((recinfo.TIME_DIMENSION_GROUP_KEY is null) AND (X_TIME_DIMENSION_GROUP_KEY is null)))
      AND (recinfo.DIMENSION_ID = X_DIMENSION_ID)
      AND (recinfo.DIMENSION_GROUP_SEQ = X_DIMENSION_GROUP_SEQ)
      AND ((recinfo.TIME_GROUP_TYPE_CODE = X_TIME_GROUP_TYPE_CODE)
           OR ((recinfo.TIME_GROUP_TYPE_CODE is null) AND (X_TIME_GROUP_TYPE_CODE is null)))
      AND (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.DIMENSION_GROUP_DISPLAY_CODE = X_DIMENSION_GROUP_DISPLAY_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DIMENSION_GROUP_NAME = X_DIMENSION_GROUP_NAME)
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
  X_DIMENSION_GROUP_ID in NUMBER,
  X_TIME_DIMENSION_GROUP_KEY in NUMBER,
  X_DIMENSION_ID in NUMBER,
  X_DIMENSION_GROUP_SEQ in NUMBER,
  X_TIME_GROUP_TYPE_CODE in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DIMENSION_GROUP_DISPLAY_CODE in VARCHAR2,
  X_DIMENSION_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_DIMENSION_GRPS_B set
    TIME_DIMENSION_GROUP_KEY = X_TIME_DIMENSION_GROUP_KEY,
    DIMENSION_ID = X_DIMENSION_ID,
    DIMENSION_GROUP_SEQ = X_DIMENSION_GROUP_SEQ,
    TIME_GROUP_TYPE_CODE = X_TIME_GROUP_TYPE_CODE,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    DIMENSION_GROUP_DISPLAY_CODE = X_DIMENSION_GROUP_DISPLAY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_DIMENSION_GRPS_TL set
    DIMENSION_GROUP_NAME = X_DIMENSION_GROUP_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DIMENSION_GROUP_ID in NUMBER
) is
begin
  delete from FEM_DIMENSION_GRPS_TL
  where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_DIMENSION_GRPS_B
  where DIMENSION_GROUP_ID = X_DIMENSION_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_DIMENSION_GRPS_TL T
  where not exists
    (select NULL
    from FEM_DIMENSION_GRPS_B B
    where B.DIMENSION_GROUP_ID = T.DIMENSION_GROUP_ID
    );

  update FEM_DIMENSION_GRPS_TL T set (
      DIMENSION_GROUP_NAME,
      DESCRIPTION
    ) = (select
      B.DIMENSION_GROUP_NAME,
      B.DESCRIPTION
    from FEM_DIMENSION_GRPS_TL B
    where B.DIMENSION_GROUP_ID = T.DIMENSION_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DIMENSION_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DIMENSION_GROUP_ID,
      SUBT.LANGUAGE
    from FEM_DIMENSION_GRPS_TL SUBB, FEM_DIMENSION_GRPS_TL SUBT
    where SUBB.DIMENSION_GROUP_ID = SUBT.DIMENSION_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DIMENSION_GROUP_NAME <> SUBT.DIMENSION_GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_DIMENSION_GRPS_TL (
    DIMENSION_GROUP_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DIMENSION_ID,
    DIMENSION_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DIMENSION_GROUP_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DIMENSION_ID,
    B.DIMENSION_GROUP_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_DIMENSION_GRPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_DIMENSION_GRPS_TL T
    where T.DIMENSION_GROUP_ID = B.DIMENSION_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_DIMENSION_GROUP_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_DIMENSION_GROUP_NAME in varchar2,
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
          from FEM_DIMENSION_GRPS_TL
          where DIMENSION_GROUP_ID = x_DIMENSION_GROUP_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_DIMENSION_GRPS_TL set
              DIMENSION_GROUP_NAME = decode(x_DIMENSION_GROUP_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_DIMENSION_GROUP_NAME,                  -- No change
			       x_DIMENSION_GROUP_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and DIMENSION_GROUP_ID = x_DIMENSION_GROUP_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_DIMENSION_GRPS_PKG;

/
