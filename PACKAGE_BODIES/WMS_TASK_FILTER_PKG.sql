--------------------------------------------------------
--  DDL for Package Body WMS_TASK_FILTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_FILTER_PKG" as
/* $Header: WMSTFTHB.pls 115.0 2003/10/29 21:05:56 sthamman noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TASK_FILTER_ID in NUMBER,
  X_TASK_FILTER_NAME in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_USER_TASK_FILTER_NAME in VARCHAR2,
  X_TASK_FILTER_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from WMS_TASK_FILTER_B
    where TASK_FILTER_ID = X_TASK_FILTER_ID
    ;
begin
  insert into WMS_TASK_FILTER_B (
    TASK_FILTER_ID,
    TASK_FILTER_NAME,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TASK_FILTER_ID,
    X_TASK_FILTER_NAME,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into WMS_TASK_FILTER_TL (
    TASK_FILTER_ID,
    USER_TASK_FILTER_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TASK_FILTER_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TASK_FILTER_ID,
    X_USER_TASK_FILTER_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TASK_FILTER_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_TASK_FILTER_TL T
    where T.TASK_FILTER_ID = X_TASK_FILTER_ID
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
  X_TASK_FILTER_ID in NUMBER,
  X_TASK_FILTER_NAME in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_USER_TASK_FILTER_NAME in VARCHAR2,
  X_TASK_FILTER_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      TASK_FILTER_NAME,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from WMS_TASK_FILTER_B
    where TASK_FILTER_ID = X_TASK_FILTER_ID
    for update of TASK_FILTER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_TASK_FILTER_NAME,
      TASK_FILTER_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_TASK_FILTER_TL
    where TASK_FILTER_ID = X_TASK_FILTER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TASK_FILTER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TASK_FILTER_NAME = X_TASK_FILTER_NAME)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_TASK_FILTER_NAME = X_USER_TASK_FILTER_NAME)
          AND ((tlinfo.TASK_FILTER_DESCRIPTION = X_TASK_FILTER_DESCRIPTION)
               OR ((tlinfo.TASK_FILTER_DESCRIPTION is null) AND (X_TASK_FILTER_DESCRIPTION is null)))
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
  X_TASK_FILTER_ID in NUMBER,
  X_TASK_FILTER_NAME in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_USER_TASK_FILTER_NAME in VARCHAR2,
  X_TASK_FILTER_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_TASK_FILTER_B set
    TASK_FILTER_NAME = X_TASK_FILTER_NAME,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TASK_FILTER_ID = X_TASK_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_TASK_FILTER_TL set
    USER_TASK_FILTER_NAME = X_USER_TASK_FILTER_NAME,
    TASK_FILTER_DESCRIPTION = X_TASK_FILTER_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TASK_FILTER_ID = X_TASK_FILTER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TASK_FILTER_ID in NUMBER
) is
begin
  delete from WMS_TASK_FILTER_TL
  where TASK_FILTER_ID = X_TASK_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_TASK_FILTER_B
  where TASK_FILTER_ID = X_TASK_FILTER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_TASK_FILTER_TL T
  where not exists
    (select NULL
    from WMS_TASK_FILTER_B B
    where B.TASK_FILTER_ID = T.TASK_FILTER_ID
    );

  update WMS_TASK_FILTER_TL T set (
      USER_TASK_FILTER_NAME,
      TASK_FILTER_DESCRIPTION
    ) = (select
      B.USER_TASK_FILTER_NAME,
      B.TASK_FILTER_DESCRIPTION
    from WMS_TASK_FILTER_TL B
    where B.TASK_FILTER_ID = T.TASK_FILTER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_FILTER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_FILTER_ID,
      SUBT.LANGUAGE
    from WMS_TASK_FILTER_TL SUBB, WMS_TASK_FILTER_TL SUBT
    where SUBB.TASK_FILTER_ID = SUBT.TASK_FILTER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_TASK_FILTER_NAME <> SUBT.USER_TASK_FILTER_NAME
      or SUBB.TASK_FILTER_DESCRIPTION <> SUBT.TASK_FILTER_DESCRIPTION
      or (SUBB.TASK_FILTER_DESCRIPTION is null and SUBT.TASK_FILTER_DESCRIPTION is not null)
      or (SUBB.TASK_FILTER_DESCRIPTION is not null and SUBT.TASK_FILTER_DESCRIPTION is null)
  ));

  insert into WMS_TASK_FILTER_TL (
    TASK_FILTER_ID,
    USER_TASK_FILTER_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TASK_FILTER_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TASK_FILTER_ID,
    B.USER_TASK_FILTER_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.TASK_FILTER_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_TASK_FILTER_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_TASK_FILTER_TL T
    where T.TASK_FILTER_ID = B.TASK_FILTER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE LOAD_ROW(
  X_TASK_FILTER_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_USER_TASK_FILTER_NAME in VARCHAR2,
  X_TASK_FILTER_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  x_custom_mode in varchar2) is

  l_TASK_FILTER_ID number;
  L_TASK_FILTER_DESCRIPTION WMS_TASK_FILTER_TL.TASK_FILTER_DESCRIPTION%TYPE;
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate a true null value to fnd_api.g_miss_char
  -- Note table handler apis should be coded to treat
  -- fnd_api.g_miss_* as true nulls, and not as no-change.
  if (X_TASK_FILTER_DESCRIPTION = fnd_load_util.null_value) then
    L_TASK_FILTER_DESCRIPTION := fnd_api.g_miss_char;
  else
    L_TASK_FILTER_DESCRIPTION := X_TASK_FILTER_DESCRIPTION;
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  begin
    -- translate values to IDs
    select TASK_FILTER_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_TASK_FILTER_ID, db_luby, db_ludate
    from WMS_TASK_FILTER_B
    where TASK_FILTER_NAME = X_TASK_FILTER_NAME;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      -- Update existing row
      WMS_TASK_FILTER_PKG.UPDATE_ROW(
        X_TASK_FILTER_ID => l_TASK_FILTER_ID,
        X_TASK_FILTER_NAME => X_TASK_FILTER_NAME,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15,
        X_USER_TASK_FILTER_NAME => X_USER_TASK_FILTER_NAME,
        X_TASK_FILTER_DESCRIPTION => L_TASK_FILTER_DESCRIPTION,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0);
    end if;

  exception
    when no_data_found then

      -- Record doesn't exist - insert in all cases
      select WMS_PAGE_TEMPLATES_S.nextval into l_TASK_FILTER_ID
      from dual;

      WMS_TASK_FILTER_PKG.INSERT_ROW(
        X_ROWID => row_id,
        X_TASK_FILTER_ID => l_TASK_FILTER_ID,
        X_TASK_FILTER_NAME => X_TASK_FILTER_NAME,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15,
        X_USER_TASK_FILTER_NAME => X_USER_TASK_FILTER_NAME,
        X_TASK_FILTER_DESCRIPTION => L_TASK_FILTER_DESCRIPTION,
        X_CREATION_DATE => f_ludate,
        X_CREATED_BY => f_luby,
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0);
  end;

end LOAD_ROW;

PROCEDURE TRANSLATE_ROW(
  X_TASK_FILTER_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_TASK_FILTER_NAME in VARCHAR2,
  X_TASK_FILTER_DESCRIPTION in VARCHAR2,
  x_last_update_date in varchar2,
  x_custom_mode in varchar2) is

  l_TASK_FILTER_ID number;
  owner_id number;
  ludate date;
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin

    -- translate values to IDs
    select TASK_FILTER_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_TASK_FILTER_ID, db_luby, db_ludate
    from WMS_TASK_FILTER_B
    where TASK_FILTER_NAME = X_TASK_FILTER_NAME;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, x_custom_mode)) then

      -- Update translations for this language
      update WMS_TASK_FILTER_TL set
        USER_TASK_FILTER_NAME = X_USER_TASK_FILTER_NAME,
        TASK_FILTER_DESCRIPTION = nvl(X_TASK_FILTER_DESCRIPTION, TASK_FILTER_DESCRIPTION),
        LAST_UPDATE_DATE = f_ludate,
        LAST_UPDATED_BY = f_luby,
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG')
      where TASK_FILTER_ID = l_TASK_FILTER_ID
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    end if;

  exception
    when no_data_found then

      -- Do not insert missing translations, skip this row
      null;

  end;

end TRANSLATE_ROW;

end WMS_TASK_FILTER_PKG;

/
