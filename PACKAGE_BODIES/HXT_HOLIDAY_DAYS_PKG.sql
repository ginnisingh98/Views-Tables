--------------------------------------------------------
--  DDL for Package Body HXT_HOLIDAY_DAYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HOLIDAY_DAYS_PKG" as
/* $Header: hxthddml.pkb 120.1 2005/10/07 02:29:49 nissharm noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HXT_HOLIDAY_DAYS
    where ID = X_ID
    ;
begin
  insert into HXT_HOLIDAY_DAYS (
    ID,
    HCL_ID,
    HOLIDAY_DATE,
    HOURS,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ID,
    X_HCL_ID,
    X_HOLIDAY_DATE,
    X_HOURS,
    X_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into HXT_HOLIDAY_DAYS_TL (
    ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ID,
    X_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HXT_HOLIDAY_DAYS_TL T
    where T.ID = X_ID
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
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c is select
      HCL_ID,
      HOLIDAY_DATE,
      HOURS
    from HXT_HOLIDAY_DAYS
    where ID = X_ID
    for update of ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HXT_HOLIDAY_DAYS_TL
    where ID = X_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.HCL_ID = X_HCL_ID)
      AND (recinfo.HOLIDAY_DATE = X_HOLIDAY_DATE)
      AND ((recinfo.HOURS = X_HOURS)
           OR ((recinfo.HOURS is null) AND (X_HOURS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_ID in NUMBER,
  X_HCL_ID in NUMBER,
  X_HOLIDAY_DATE in DATE,
  X_HOURS in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HXT_HOLIDAY_DAYS set
    HCL_ID = X_HCL_ID,
    HOLIDAY_DATE = X_HOLIDAY_DATE,
    HOURS = X_HOURS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HXT_HOLIDAY_DAYS_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ID = X_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ID in NUMBER
) is
begin
  delete from HXT_HOLIDAY_DAYS_TL
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HXT_HOLIDAY_DAYS
  where ID = X_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HXT_HOLIDAY_DAYS_TL T
  where not exists
    (select NULL
    from HXT_HOLIDAY_DAYS B
    where B.ID = T.ID
    );

  update HXT_HOLIDAY_DAYS_TL T set (
      NAME
    ) = (select
      B.NAME
    from HXT_HOLIDAY_DAYS_TL B
    where B.ID = T.ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ID,
      T.LANGUAGE
  ) in (select
      SUBT.ID,
      SUBT.LANGUAGE
    from HXT_HOLIDAY_DAYS_TL SUBB, HXT_HOLIDAY_DAYS_TL SUBT
    where SUBB.ID = SUBT.ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into HXT_HOLIDAY_DAYS_TL (
    ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HXT_HOLIDAY_DAYS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HXT_HOLIDAY_DAYS_TL T
    where T.ID = B.ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end HXT_HOLIDAY_DAYS_PKG;

/
