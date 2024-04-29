--------------------------------------------------------
--  DDL for Package Body GMO_DISPENSE_BOOTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISPENSE_BOOTH_PKG" as
/* $Header: GMODBTHB.pls 120.1 2007/06/21 06:09:19 rvsingh noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DISPENSE_BOOTH_ID in NUMBER,
  X_DISPENSE_BOOTH_NAME in VARCHAR2,
  X_DISPENSE_AREA_ID in NUMBER,
  X_LOCATOR_ID in NUMBER,
  X_DISPENSE_BOOTH_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_DISPENSE_BOOTH_B
    where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID
    ;
begin
  insert into GMO_DISPENSE_BOOTH_B (
    DISPENSE_BOOTH_ID,
    DISPENSE_BOOTH_NAME,
    DISPENSE_AREA_ID,
    LOCATOR_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DISPENSE_BOOTH_ID,
    X_DISPENSE_BOOTH_NAME,
    X_DISPENSE_AREA_ID,
    X_LOCATOR_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMO_DISPENSE_BOOTH_TL (
    DISPENSE_BOOTH_ID,
    DISPENSE_BOOTH_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DISPENSE_BOOTH_ID,
    X_DISPENSE_BOOTH_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMO_DISPENSE_BOOTH_TL T
    where T.DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID
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
  X_DISPENSE_BOOTH_ID in NUMBER,
  X_DISPENSE_BOOTH_NAME in VARCHAR2,
  X_DISPENSE_AREA_ID in NUMBER,
  X_LOCATOR_ID in NUMBER,
  X_DISPENSE_BOOTH_DESC in VARCHAR2
) is
  cursor c is select
      DISPENSE_BOOTH_NAME,
      DISPENSE_AREA_ID,
      LOCATOR_ID
    from GMO_DISPENSE_BOOTH_B
    where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID
    for update of DISPENSE_BOOTH_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPENSE_BOOTH_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_DISPENSE_BOOTH_TL
    where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DISPENSE_BOOTH_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DISPENSE_BOOTH_NAME = X_DISPENSE_BOOTH_NAME)
      AND (recinfo.DISPENSE_AREA_ID = X_DISPENSE_AREA_ID)
      AND (recinfo.LOCATOR_ID = X_LOCATOR_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPENSE_BOOTH_DESC = X_DISPENSE_BOOTH_DESC)
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
  X_DISPENSE_BOOTH_ID in NUMBER,
  X_DISPENSE_BOOTH_NAME in VARCHAR2,
  X_DISPENSE_AREA_ID in NUMBER,
  X_LOCATOR_ID in NUMBER,
  X_DISPENSE_BOOTH_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_DISPENSE_BOOTH_B set
    DISPENSE_BOOTH_NAME = X_DISPENSE_BOOTH_NAME,
    DISPENSE_AREA_ID = X_DISPENSE_AREA_ID,
    LOCATOR_ID = X_LOCATOR_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_DISPENSE_BOOTH_TL set
    DISPENSE_BOOTH_DESC = X_DISPENSE_BOOTH_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DISPENSE_BOOTH_ID in NUMBER
) is
begin
  delete from GMO_DISPENSE_BOOTH_TL
  where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_DISPENSE_BOOTH_B
  where DISPENSE_BOOTH_ID = X_DISPENSE_BOOTH_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_DISPENSE_BOOTH_TL T
  where not exists
    (select NULL
    from GMO_DISPENSE_BOOTH_B B
    where B.DISPENSE_BOOTH_ID = T.DISPENSE_BOOTH_ID
    );

  update GMO_DISPENSE_BOOTH_TL T set (
      DISPENSE_BOOTH_DESC
    ) = (select
      B.DISPENSE_BOOTH_DESC
    from GMO_DISPENSE_BOOTH_TL B
    where B.DISPENSE_BOOTH_ID = T.DISPENSE_BOOTH_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DISPENSE_BOOTH_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DISPENSE_BOOTH_ID,
      SUBT.LANGUAGE
    from GMO_DISPENSE_BOOTH_TL SUBB, GMO_DISPENSE_BOOTH_TL SUBT
    where SUBB.DISPENSE_BOOTH_ID = SUBT.DISPENSE_BOOTH_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPENSE_BOOTH_DESC <> SUBT.DISPENSE_BOOTH_DESC
  ));

  insert into GMO_DISPENSE_BOOTH_TL (
    DISPENSE_BOOTH_ID,
    DISPENSE_BOOTH_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DISPENSE_BOOTH_ID,
    B.DISPENSE_BOOTH_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_DISPENSE_BOOTH_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_DISPENSE_BOOTH_TL T
    where T.DISPENSE_BOOTH_ID = B.DISPENSE_BOOTH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMO_DISPENSE_BOOTH_PKG;

/
