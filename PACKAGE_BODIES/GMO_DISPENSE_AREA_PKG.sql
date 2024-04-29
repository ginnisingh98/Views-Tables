--------------------------------------------------------
--  DDL for Package Body GMO_DISPENSE_AREA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISPENSE_AREA_PKG" as
/* $Header: GMODAREB.pls 120.1 2007/06/21 06:08:01 rvsingh noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DISPENSE_AREA_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DISPENSE_AREA_NAME in VARCHAR2,
  X_DEFAULT_AREA_IND in VARCHAR2,
  X_SUBINVENTORY_CODE in VARCHAR2,
  X_NUMBER_OF_TASKS_PER_DAY in NUMBER,
  X_DISPENSE_AREA_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMO_DISPENSE_AREA_B
    where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID
    ;
begin
  insert into GMO_DISPENSE_AREA_B (
    DISPENSE_AREA_ID,
    ORGANIZATION_ID,
    DISPENSE_AREA_NAME,
    DEFAULT_AREA_IND,
    SUBINVENTORY_CODE,
    NUMBER_OF_TASKS_PER_DAY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DISPENSE_AREA_ID,
    X_ORGANIZATION_ID,
    X_DISPENSE_AREA_NAME,
    X_DEFAULT_AREA_IND,
    X_SUBINVENTORY_CODE,
    X_NUMBER_OF_TASKS_PER_DAY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMO_DISPENSE_AREA_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DISPENSE_AREA_ID,
    DISPENSE_AREA_DESC,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_DISPENSE_AREA_ID,
    X_DISPENSE_AREA_DESC,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMO_DISPENSE_AREA_TL T
    where T.DISPENSE_AREA_ID = X_DISPENSE_AREA_ID
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
  X_DISPENSE_AREA_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DISPENSE_AREA_NAME in VARCHAR2,
  X_DEFAULT_AREA_IND in VARCHAR2,
  X_SUBINVENTORY_CODE in VARCHAR2,
  X_NUMBER_OF_TASKS_PER_DAY in NUMBER,
  X_DISPENSE_AREA_DESC in VARCHAR2
) is
  cursor c is select
      ORGANIZATION_ID,
      DISPENSE_AREA_NAME,
      DEFAULT_AREA_IND,
      SUBINVENTORY_CODE,
      NUMBER_OF_TASKS_PER_DAY
    from GMO_DISPENSE_AREA_B
    where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID
    for update of DISPENSE_AREA_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPENSE_AREA_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMO_DISPENSE_AREA_TL
    where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DISPENSE_AREA_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
      AND ((recinfo.DISPENSE_AREA_NAME = X_DISPENSE_AREA_NAME)
           OR ((recinfo.DISPENSE_AREA_NAME is null) AND (X_DISPENSE_AREA_NAME is null)))
      AND ((recinfo.DEFAULT_AREA_IND = X_DEFAULT_AREA_IND)
           OR ((recinfo.DEFAULT_AREA_IND is null) AND (X_DEFAULT_AREA_IND is null)))
      AND ((recinfo.SUBINVENTORY_CODE = X_SUBINVENTORY_CODE)
           OR ((recinfo.SUBINVENTORY_CODE is null) AND (X_SUBINVENTORY_CODE is null)))
      AND ((recinfo.NUMBER_OF_TASKS_PER_DAY = X_NUMBER_OF_TASKS_PER_DAY)
           OR ((recinfo.NUMBER_OF_TASKS_PER_DAY is null) AND (X_NUMBER_OF_TASKS_PER_DAY is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPENSE_AREA_DESC = X_DISPENSE_AREA_DESC)
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
  X_DISPENSE_AREA_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DISPENSE_AREA_NAME in VARCHAR2,
  X_DEFAULT_AREA_IND in VARCHAR2,
  X_SUBINVENTORY_CODE in VARCHAR2,
  X_NUMBER_OF_TASKS_PER_DAY in NUMBER,
  X_DISPENSE_AREA_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMO_DISPENSE_AREA_B set
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    DISPENSE_AREA_NAME = X_DISPENSE_AREA_NAME,
    DEFAULT_AREA_IND = X_DEFAULT_AREA_IND,
    SUBINVENTORY_CODE = X_SUBINVENTORY_CODE,
    NUMBER_OF_TASKS_PER_DAY = X_NUMBER_OF_TASKS_PER_DAY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMO_DISPENSE_AREA_TL set
    DISPENSE_AREA_DESC = X_DISPENSE_AREA_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DISPENSE_AREA_ID in NUMBER
) is
begin
  delete from GMO_DISPENSE_AREA_TL
  where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMO_DISPENSE_AREA_B
  where DISPENSE_AREA_ID = X_DISPENSE_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMO_DISPENSE_AREA_TL T
  where not exists
    (select NULL
    from GMO_DISPENSE_AREA_B B
    where B.DISPENSE_AREA_ID = T.DISPENSE_AREA_ID
    );

  update GMO_DISPENSE_AREA_TL T set (
      DISPENSE_AREA_DESC
    ) = (select
      B.DISPENSE_AREA_DESC
    from GMO_DISPENSE_AREA_TL B
    where B.DISPENSE_AREA_ID = T.DISPENSE_AREA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DISPENSE_AREA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DISPENSE_AREA_ID,
      SUBT.LANGUAGE
    from GMO_DISPENSE_AREA_TL SUBB, GMO_DISPENSE_AREA_TL SUBT
    where SUBB.DISPENSE_AREA_ID = SUBT.DISPENSE_AREA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPENSE_AREA_DESC <> SUBT.DISPENSE_AREA_DESC
  ));

  insert into GMO_DISPENSE_AREA_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DISPENSE_AREA_ID,
    DISPENSE_AREA_DESC,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DISPENSE_AREA_ID,
    B.DISPENSE_AREA_DESC,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMO_DISPENSE_AREA_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMO_DISPENSE_AREA_TL T
    where T.DISPENSE_AREA_ID = B.DISPENSE_AREA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GMO_DISPENSE_AREA_PKG;

/
