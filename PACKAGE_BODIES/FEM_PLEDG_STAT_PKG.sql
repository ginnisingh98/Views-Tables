--------------------------------------------------------
--  DDL for Package Body FEM_PLEDG_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PLEDG_STAT_PKG" as
/* $Header: fem_pldgstat_pkb.plb 120.0 2005/06/06 21:46:15 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PLEDGED_STATUS_ID in NUMBER,
  X_PLEDGED_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PLEDGED_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_PLEDG_STAT_B
    where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID
    ;
begin
  insert into FEM_PLEDG_STAT_B (
    PLEDGED_STATUS_ID,
    PLEDGED_STATUS_DISPLAY_CODE,
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
    X_PLEDGED_STATUS_ID,
    X_PLEDGED_STATUS_DISPLAY_CODE,
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

  insert into FEM_PLEDG_STAT_TL (
    PLEDGED_STATUS_ID,
    PLEDGED_STATUS_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PLEDGED_STATUS_ID,
    X_PLEDGED_STATUS_NAME,
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
    from FEM_PLEDG_STAT_TL T
    where T.PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID
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
  X_PLEDGED_STATUS_ID in NUMBER,
  X_PLEDGED_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PLEDGED_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PLEDGED_STATUS_DISPLAY_CODE,
      ENABLED_FLAG,
      PERSONAL_FLAG,
      READ_ONLY_FLAG,
      OBJECT_VERSION_NUMBER
    from FEM_PLEDG_STAT_B
    where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID
    for update of PLEDGED_STATUS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PLEDGED_STATUS_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_PLEDG_STAT_TL
    where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PLEDGED_STATUS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PLEDGED_STATUS_DISPLAY_CODE = X_PLEDGED_STATUS_DISPLAY_CODE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
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
      if (    (tlinfo.PLEDGED_STATUS_NAME = X_PLEDGED_STATUS_NAME)
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
  X_PLEDGED_STATUS_ID in NUMBER,
  X_PLEDGED_STATUS_DISPLAY_CODE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PLEDGED_STATUS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_PLEDG_STAT_B set
    PLEDGED_STATUS_DISPLAY_CODE = X_PLEDGED_STATUS_DISPLAY_CODE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_PLEDG_STAT_TL set
    PLEDGED_STATUS_NAME = X_PLEDGED_STATUS_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PLEDGED_STATUS_ID in NUMBER
) is
begin
  delete from FEM_PLEDG_STAT_TL
  where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_PLEDG_STAT_B
  where PLEDGED_STATUS_ID = X_PLEDGED_STATUS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_PLEDG_STAT_TL T
  where not exists
    (select NULL
    from FEM_PLEDG_STAT_B B
    where B.PLEDGED_STATUS_ID = T.PLEDGED_STATUS_ID
    );

  update FEM_PLEDG_STAT_TL T set (
      PLEDGED_STATUS_NAME,
      DESCRIPTION
    ) = (select
      B.PLEDGED_STATUS_NAME,
      B.DESCRIPTION
    from FEM_PLEDG_STAT_TL B
    where B.PLEDGED_STATUS_ID = T.PLEDGED_STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PLEDGED_STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PLEDGED_STATUS_ID,
      SUBT.LANGUAGE
    from FEM_PLEDG_STAT_TL SUBB, FEM_PLEDG_STAT_TL SUBT
    where SUBB.PLEDGED_STATUS_ID = SUBT.PLEDGED_STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PLEDGED_STATUS_NAME <> SUBT.PLEDGED_STATUS_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into FEM_PLEDG_STAT_TL (
    PLEDGED_STATUS_ID,
    PLEDGED_STATUS_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PLEDGED_STATUS_ID,
    B.PLEDGED_STATUS_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_PLEDG_STAT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_PLEDG_STAT_TL T
    where T.PLEDGED_STATUS_ID = B.PLEDGED_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_PLEDGED_STATUS_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_PLEDGED_STATUS_NAME in varchar2,
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
          from FEM_PLEDG_STAT_TL
          where PLEDGED_STATUS_ID = x_PLEDGED_STATUS_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_PLEDG_STAT_TL set
              PLEDGED_STATUS_NAME = decode(x_PLEDGED_STATUS_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_PLEDGED_STATUS_NAME,                  -- No change
			       x_PLEDGED_STATUS_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and PLEDGED_STATUS_ID = x_PLEDGED_STATUS_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_PLEDG_STAT_PKG;

/
