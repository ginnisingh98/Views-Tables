--------------------------------------------------------
--  DDL for Package Body FEM_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_CALENDARS_PKG" as
/* $Header: fem_calendar_pkb.plb 120.0 2005/06/06 21:12:53 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALENDAR_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CALENDAR_DISPLAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FEM_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    ;
begin
  insert into FEM_CALENDARS_B (
    READ_ONLY_FLAG,
    PERSONAL_FLAG,
    ENABLED_FLAG,
    CALENDAR_DISPLAY_CODE,
    CALENDAR_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_READ_ONLY_FLAG,
    X_PERSONAL_FLAG,
    X_ENABLED_FLAG,
    X_CALENDAR_DISPLAY_CODE,
    X_CALENDAR_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FEM_CALENDARS_TL (
    CALENDAR_ID,
    CALENDAR_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CALENDAR_ID,
    X_CALENDAR_NAME,
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
    from FEM_CALENDARS_TL T
    where T.CALENDAR_ID = X_CALENDAR_ID
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
  X_CALENDAR_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CALENDAR_DISPLAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      READ_ONLY_FLAG,
      PERSONAL_FLAG,
      ENABLED_FLAG,
      CALENDAR_DISPLAY_CODE,
      OBJECT_VERSION_NUMBER
    from FEM_CALENDARS_B
    where CALENDAR_ID = X_CALENDAR_ID
    for update of CALENDAR_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      CALENDAR_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FEM_CALENDARS_TL
    where CALENDAR_ID = X_CALENDAR_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CALENDAR_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.READ_ONLY_FLAG = X_READ_ONLY_FLAG)
      AND (recinfo.PERSONAL_FLAG = X_PERSONAL_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.CALENDAR_DISPLAY_CODE = X_CALENDAR_DISPLAY_CODE)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CALENDAR_NAME = X_CALENDAR_NAME)
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
  X_CALENDAR_ID in NUMBER,
  X_READ_ONLY_FLAG in VARCHAR2,
  X_PERSONAL_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_CALENDAR_DISPLAY_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CALENDAR_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FEM_CALENDARS_B set
    READ_ONLY_FLAG = X_READ_ONLY_FLAG,
    PERSONAL_FLAG = X_PERSONAL_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    CALENDAR_DISPLAY_CODE = X_CALENDAR_DISPLAY_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FEM_CALENDARS_TL set
    CALENDAR_NAME = X_CALENDAR_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CALENDAR_ID = X_CALENDAR_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CALENDAR_ID in NUMBER
) is
begin
  delete from FEM_CALENDARS_TL
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FEM_CALENDARS_B
  where CALENDAR_ID = X_CALENDAR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FEM_CALENDARS_TL T
  where not exists
    (select NULL
    from FEM_CALENDARS_B B
    where B.CALENDAR_ID = T.CALENDAR_ID
    );

  update FEM_CALENDARS_TL T set (
      CALENDAR_NAME,
      DESCRIPTION
    ) = (select
      B.CALENDAR_NAME,
      B.DESCRIPTION
    from FEM_CALENDARS_TL B
    where B.CALENDAR_ID = T.CALENDAR_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CALENDAR_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CALENDAR_ID,
      SUBT.LANGUAGE
    from FEM_CALENDARS_TL SUBB, FEM_CALENDARS_TL SUBT
    where SUBB.CALENDAR_ID = SUBT.CALENDAR_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CALENDAR_NAME <> SUBT.CALENDAR_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FEM_CALENDARS_TL (
    CALENDAR_ID,
    CALENDAR_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CALENDAR_ID,
    B.CALENDAR_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FEM_CALENDARS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FEM_CALENDARS_TL T
    where T.CALENDAR_ID = B.CALENDAR_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
PROCEDURE TRANSLATE_ROW(
        x_CALENDAR_ID in number,
        x_owner in varchar2,
        x_last_update_date in varchar2,
        x_CALENDAR_NAME in varchar2,
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
          from FEM_CALENDARS_TL
          where CALENDAR_ID = x_CALENDAR_ID
          and LANGUAGE = userenv('LANG');

	  -- Test for customization and version
          if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                        db_ludate, x_custom_mode)) then
            -- Update translations for this language
            update FEM_CALENDARS_TL set
              CALENDAR_NAME = decode(x_CALENDAR_NAME,
			       fnd_load_util.null_value, null, -- Real null
			       null, x_CALENDAR_NAME,                  -- No change
			       x_CALENDAR_NAME),
              DESCRIPTION = nvl(x_description, DESCRIPTION),
              LAST_UPDATE_DATE = f_ludate,
              LAST_UPDATED_BY = f_luby,
              LAST_UPDATE_LOGIN = 0,
              SOURCE_LANG = userenv('LANG')
            where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
            and CALENDAR_ID = x_CALENDAR_ID;
         end if;
        exception
          when no_data_found then
            -- Do not insert missing translations, skip this row
            null;
        end;
     end TRANSLATE_ROW;


end FEM_CALENDARS_PKG;

/
