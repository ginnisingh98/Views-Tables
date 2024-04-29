--------------------------------------------------------
--  DDL for Package Body FEM_OUTINFO_SRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_OUTINFO_SRC_PKG" as
/* $Header: fem_outinfsr_pkb.plb 120.0 2005/06/06 20:29:41 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OUTSIDE_INFO_SOURCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OUTSIDE_INFO_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_OUTINFO_SRC_B
    where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE
    ;
begin
  insert into FEM_OUTINFO_SRC_B (
    OUTSIDE_INFO_SOURCE_CODE,
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
    X_OUTSIDE_INFO_SOURCE_CODE,
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

  insert into FEM_OUTINFO_SRC_TL (
    OUTSIDE_INFO_SOURCE_CODE,
    OUTSIDE_INFO_SOURCE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OUTSIDE_INFO_SOURCE_CODE,
    X_OUTSIDE_INFO_SOURCE_NAME,
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
    from FEM_OUTINFO_SRC_TL T
    where T.OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE
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
  X_OUTSIDE_INFO_SOURCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OUTSIDE_INFO_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      PERSONAL_FLAG,
      READ_ONLY_FLAG,
      OBJECT_VERSION_NUMBER
    from FEM_OUTINFO_SRC_B
    where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE
    for update of OUTSIDE_INFO_SOURCE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OUTSIDE_INFO_SOURCE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_OUTINFO_SRC_TL
    where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OUTSIDE_INFO_SOURCE_CODE nowait;
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
      if (    (tlinfo.OUTSIDE_INFO_SOURCE_NAME = X_OUTSIDE_INFO_SOURCE_NAME)
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
  X_OUTSIDE_INFO_SOURCE_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OUTSIDE_INFO_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_OUTINFO_SRC_B set
    ENABLED_FLAG = X_ENABLED_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_OUTINFO_SRC_TL set
    OUTSIDE_INFO_SOURCE_NAME = X_OUTSIDE_INFO_SOURCE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OUTSIDE_INFO_SOURCE_CODE in VARCHAR2
) is
begin
  delete from FEM_OUTINFO_SRC_TL
  where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_OUTINFO_SRC_B
  where OUTSIDE_INFO_SOURCE_CODE = X_OUTSIDE_INFO_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_OUTINFO_SRC_TL T
  where not exists
    (select NULL
    from FEM_OUTINFO_SRC_B B
    where B.OUTSIDE_INFO_SOURCE_CODE = T.OUTSIDE_INFO_SOURCE_CODE
    );

  update FEM_OUTINFO_SRC_TL T set (
      OUTSIDE_INFO_SOURCE_NAME,
      DESCRIPTION
    ) = (select
      B.OUTSIDE_INFO_SOURCE_NAME,
      B.DESCRIPTION
    from FEM_OUTINFO_SRC_TL B
    where B.OUTSIDE_INFO_SOURCE_CODE = T.OUTSIDE_INFO_SOURCE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OUTSIDE_INFO_SOURCE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.OUTSIDE_INFO_SOURCE_CODE,
      SUBT.LANGUAGE
    from FEM_OUTINFO_SRC_TL SUBB, FEM_OUTINFO_SRC_TL SUBT
    where SUBB.OUTSIDE_INFO_SOURCE_CODE = SUBT.OUTSIDE_INFO_SOURCE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OUTSIDE_INFO_SOURCE_NAME <> SUBT.OUTSIDE_INFO_SOURCE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FEM_OUTINFO_SRC_TL (
    OUTSIDE_INFO_SOURCE_CODE,
    OUTSIDE_INFO_SOURCE_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.OUTSIDE_INFO_SOURCE_CODE,
    B.OUTSIDE_INFO_SOURCE_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_OUTINFO_SRC_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_OUTINFO_SRC_TL T
    where T.OUTSIDE_INFO_SOURCE_CODE = B.OUTSIDE_INFO_SOURCE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_OUTSIDE_INFO_SOURCE_CODE in varchar2,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_OUTSIDE_INFO_SOURCE_NAME in varchar2,
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
          from FEM_OUTINFO_SRC_TL
          where OUTSIDE_INFO_SOURCE_CODE = x_OUTSIDE_INFO_SOURCE_CODE
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_OUTINFO_SRC_TL set
              OUTSIDE_INFO_SOURCE_NAME = decode(x_OUTSIDE_INFO_SOURCE_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_OUTSIDE_INFO_SOURCE_NAME,                  -- No change
			       x_OUTSIDE_INFO_SOURCE_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and OUTSIDE_INFO_SOURCE_CODE = x_OUTSIDE_INFO_SOURCE_CODE;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_OUTINFO_SRC_PKG;

/
