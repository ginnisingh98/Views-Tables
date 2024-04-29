--------------------------------------------------------
--  DDL for Package Body WMS_PAGE_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PAGE_TEMPLATES_PKG" as
/* $Header: WMSPTTHB.pls 115.2 2003/10/31 05:14:58 sthamman noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
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
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_CREATING_ORGANIZATION_ID in NUMBER,
  X_CREATING_ORGANIZATION_CODE in VARCHAR2,
  X_COMMON_TO_ALL_ORGS in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from WMS_PAGE_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID;

begin

  insert into WMS_PAGE_TEMPLATES_B (
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
    PAGE_ID,
    TEMPLATE_ID,
    TEMPLATE_NAME,
    CREATING_ORGANIZATION_ID,
    CREATING_ORGANIZATION_CODE,
    COMMON_TO_ALL_ORGS,
    ENABLED,
    DEFAULT_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
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
    X_PAGE_ID,
    X_TEMPLATE_ID,
    X_TEMPLATE_NAME,
    X_CREATING_ORGANIZATION_ID,
    X_CREATING_ORGANIZATION_CODE,
    X_COMMON_TO_ALL_ORGS,
    X_ENABLED,
    X_DEFAULT_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into WMS_PAGE_TEMPLATES_TL (
    PAGE_ID,
    TEMPLATE_ID,
    USER_TEMPLATE_NAME,
    TEMPLATE_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PAGE_ID,
    X_TEMPLATE_ID,
    X_USER_TEMPLATE_NAME,
    X_TEMPLATE_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from WMS_PAGE_TEMPLATES_TL T
    where T.TEMPLATE_ID = X_TEMPLATE_ID
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
  X_TEMPLATE_ID in NUMBER,
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
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_CREATING_ORGANIZATION_ID in NUMBER,
  X_CREATING_ORGANIZATION_CODE in VARCHAR2,
  X_COMMON_TO_ALL_ORGS in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2
) is
  cursor c is select
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
      PAGE_ID,
      TEMPLATE_NAME,
      CREATING_ORGANIZATION_ID,
      CREATING_ORGANIZATION_CODE,
      COMMON_TO_ALL_ORGS,
      ENABLED,
      DEFAULT_FLAG
    from WMS_PAGE_TEMPLATES_B
    where TEMPLATE_ID = X_TEMPLATE_ID
    for update of TEMPLATE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_TEMPLATE_NAME,
      TEMPLATE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from WMS_PAGE_TEMPLATES_TL
    where TEMPLATE_ID = X_TEMPLATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEMPLATE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
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
      AND (recinfo.PAGE_ID = X_PAGE_ID)
      AND (recinfo.TEMPLATE_NAME = X_TEMPLATE_NAME)
      AND (recinfo.CREATING_ORGANIZATION_ID = X_CREATING_ORGANIZATION_ID)
      AND ((recinfo.CREATING_ORGANIZATION_CODE = X_CREATING_ORGANIZATION_CODE)
           OR ((recinfo.CREATING_ORGANIZATION_CODE is null) AND (X_CREATING_ORGANIZATION_CODE is null)))
      AND ((recinfo.COMMON_TO_ALL_ORGS = X_COMMON_TO_ALL_ORGS)
           OR ((recinfo.COMMON_TO_ALL_ORGS is null) AND (X_COMMON_TO_ALL_ORGS is null)))
      AND ((recinfo.ENABLED = X_ENABLED)
           OR ((recinfo.ENABLED is null) AND (X_ENABLED is null)))
      AND ((recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
           OR ((recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_TEMPLATE_NAME = X_USER_TEMPLATE_NAME)
          AND ((tlinfo.TEMPLATE_DESCRIPTION = X_TEMPLATE_DESCRIPTION)
               OR ((tlinfo.TEMPLATE_DESCRIPTION is null) AND (X_TEMPLATE_DESCRIPTION is null)))
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
  X_TEMPLATE_ID in NUMBER,
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
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_CREATING_ORGANIZATION_ID in NUMBER,
  X_CREATING_ORGANIZATION_CODE in VARCHAR2,
  X_COMMON_TO_ALL_ORGS in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update WMS_PAGE_TEMPLATES_B set
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
    PAGE_ID = X_PAGE_ID,
    TEMPLATE_NAME = X_TEMPLATE_NAME,
    CREATING_ORGANIZATION_ID = X_CREATING_ORGANIZATION_ID,
    CREATING_ORGANIZATION_CODE = X_CREATING_ORGANIZATION_CODE,
    COMMON_TO_ALL_ORGS = X_COMMON_TO_ALL_ORGS,
    ENABLED = X_ENABLED,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update WMS_PAGE_TEMPLATES_TL set
    USER_TEMPLATE_NAME = X_USER_TEMPLATE_NAME,
    TEMPLATE_DESCRIPTION = X_TEMPLATE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEMPLATE_ID = X_TEMPLATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE TRANSLATE_ROW(
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
  x_last_update_date in varchar2,
  x_custom_mode in varchar2) is

  l_template_id number;
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
    select TEMPLATE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_template_id, db_luby, db_ludate
    from WMS_PAGE_TEMPLATES_B
    where PAGE_ID = X_PAGE_ID
    and TEMPLATE_NAME = X_TEMPLATE_NAME;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                    db_ludate, x_custom_mode)) then
      -- Update translations for this language
      update WMS_PAGE_TEMPLATES_TL set
        USER_TEMPLATE_NAME = X_USER_TEMPLATE_NAME,
        TEMPLATE_DESCRIPTION = nvl(X_TEMPLATE_DESCRIPTION, TEMPLATE_DESCRIPTION),
        LAST_UPDATE_DATE = f_ludate,
        LAST_UPDATED_BY = f_luby,
        LAST_UPDATE_LOGIN = 0,
        SOURCE_LANG = userenv('LANG')
      where TEMPLATE_ID = l_template_id
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      -- Do not insert missing translations, skip this row
      null;
  end;
end TRANSLATE_ROW;

PROCEDURE LOAD_ROW(
  X_PAGE_ID in NUMBER,
  X_TEMPLATE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CREATING_ORGANIZATION_ID in NUMBER,
  X_CREATING_ORGANIZATION_CODE in VARCHAR2,
  X_COMMON_TO_ALL_ORGS in VARCHAR2,
  X_ENABLED in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_USER_TEMPLATE_NAME in VARCHAR2,
  X_TEMPLATE_DESCRIPTION in VARCHAR2,
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
  x_last_update_date in varchar2,
  x_custom_mode in varchar2) is

  l_template_id number;
  l_TEMPLATE_DESCRIPTION WMS_PAGE_TEMPLATES_TL.TEMPLATE_DESCRIPTION%TYPE;
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin

  -- Translate a true null value to fnd_api.g_miss_char
  -- Note table handler apis should be coded to treat
  -- fnd_api.g_miss_* as true nulls, and not as no-change.
  if (X_TEMPLATE_DESCRIPTION = fnd_load_util.null_value) then
    l_TEMPLATE_DESCRIPTION := fnd_api.g_miss_char;
  else
    l_TEMPLATE_DESCRIPTION := X_TEMPLATE_DESCRIPTION;
  end if;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  begin
    -- translate values to IDs
    select TEMPLATE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_template_id, db_luby, db_ludate
    from WMS_PAGE_TEMPLATES_B
    where PAGE_ID = X_PAGE_ID
    and TEMPLATE_NAME = X_TEMPLATE_NAME;

    -- Test for customization and version
    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      -- Update existing row
      WMS_PAGE_TEMPLATES_PKG.UPDATE_ROW(
        X_PAGE_ID => X_PAGE_ID,
        X_TEMPLATE_NAME => X_TEMPLATE_NAME,
        X_TEMPLATE_ID => l_TEMPLATE_ID,
        X_CREATING_ORGANIZATION_ID => X_CREATING_ORGANIZATION_ID,
        X_CREATING_ORGANIZATION_CODE => X_CREATING_ORGANIZATION_CODE,
        X_COMMON_TO_ALL_ORGS => X_COMMON_TO_ALL_ORGS,
        X_ENABLED => X_ENABLED,
        X_DEFAULT_FLAG => X_DEFAULT_FLAG,
        X_USER_TEMPLATE_NAME => X_USER_TEMPLATE_NAME,
        X_TEMPLATE_DESCRIPTION => l_TEMPLATE_DESCRIPTION,
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
        X_LAST_UPDATE_DATE => f_ludate,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0);

    end if;

  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases

      select WMS_PAGE_TEMPLATES_S.nextval into l_TEMPLATE_ID
      from dual;

      WMS_PAGE_TEMPLATES_PKG.INSERT_ROW(
	X_ROWID => row_id,
	X_PAGE_ID => X_PAGE_ID,
	X_TEMPLATE_NAME => X_TEMPLATE_NAME,
	X_TEMPLATE_ID => l_TEMPLATE_ID,
	X_CREATING_ORGANIZATION_ID => X_CREATING_ORGANIZATION_ID,
	X_CREATING_ORGANIZATION_CODE => X_CREATING_ORGANIZATION_CODE,
	X_COMMON_TO_ALL_ORGS => X_COMMON_TO_ALL_ORGS,
	X_ENABLED => X_ENABLED,
	X_DEFAULT_FLAG => X_DEFAULT_FLAG,
	X_USER_TEMPLATE_NAME => X_USER_TEMPLATE_NAME,
	X_TEMPLATE_DESCRIPTION => l_TEMPLATE_DESCRIPTION,
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
	X_CREATION_DATE => f_ludate,
	X_CREATED_BY => f_luby,
	X_LAST_UPDATE_DATE => f_ludate,
	X_LAST_UPDATED_BY => f_luby,
	X_LAST_UPDATE_LOGIN => 0);
  end;
end LOAD_ROW;

procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
) is
begin

  delete from WMS_PAGE_TEMPLATE_FIELDS
  where TEMPLATE_ID = X_TEMPLATE_ID;

  delete from WMS_PAGE_TEMPLATES_TL
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from WMS_PAGE_TEMPLATES_B
  where TEMPLATE_ID = X_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from WMS_PAGE_TEMPLATES_TL T
  where not exists
    (select NULL
    from WMS_PAGE_TEMPLATES_B B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    );

  update WMS_PAGE_TEMPLATES_TL T set (
      USER_TEMPLATE_NAME,
      TEMPLATE_DESCRIPTION
    ) = (select
      B.USER_TEMPLATE_NAME,
      B.TEMPLATE_DESCRIPTION
    from WMS_PAGE_TEMPLATES_TL B
    where B.TEMPLATE_ID = T.TEMPLATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEMPLATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEMPLATE_ID,
      SUBT.LANGUAGE
    from WMS_PAGE_TEMPLATES_TL SUBB, WMS_PAGE_TEMPLATES_TL SUBT
    where SUBB.TEMPLATE_ID = SUBT.TEMPLATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_TEMPLATE_NAME <> SUBT.USER_TEMPLATE_NAME
      or SUBB.TEMPLATE_DESCRIPTION <> SUBT.TEMPLATE_DESCRIPTION
      or (SUBB.TEMPLATE_DESCRIPTION is null and SUBT.TEMPLATE_DESCRIPTION is not null)
      or (SUBB.TEMPLATE_DESCRIPTION is not null and SUBT.TEMPLATE_DESCRIPTION is null)
  ));

  insert into WMS_PAGE_TEMPLATES_TL (
    PAGE_ID,
    TEMPLATE_ID,
    USER_TEMPLATE_NAME,
    TEMPLATE_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PAGE_ID,
    B.TEMPLATE_ID,
    B.USER_TEMPLATE_NAME,
    B.TEMPLATE_DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WMS_PAGE_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WMS_PAGE_TEMPLATES_TL T
    where T.TEMPLATE_ID = B.TEMPLATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end WMS_PAGE_TEMPLATES_PKG;

/