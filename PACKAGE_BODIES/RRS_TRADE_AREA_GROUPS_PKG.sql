--------------------------------------------------------
--  DDL for Package Body RRS_TRADE_AREA_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_TRADE_AREA_GROUPS_PKG" as
/* $Header: RRSTAGPB.pls 120.1 2005/09/30 00:41 swbhatna noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_TYPE_CODE in VARCHAR2,
  X_NUM_OF_TRADE_AREAS in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_UNIT_OF_MEASURE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  L_GROUP_ID NUMBER;

  cursor C is select ROWID from RRS_TRADE_AREA_GROUPS_B
  where GROUP_ID = L_GROUP_ID;

  begin

  select nvl(X_GROUP_ID ,RRS_TRADE_AREA_GROUPS_S.nextval)
  into   L_GROUP_ID
  from   dual;

  insert into RRS_TRADE_AREA_GROUPS_B (
    GROUP_ID,
    GROUP_TYPE_CODE,
    NUM_OF_TRADE_AREAS,
    STATUS_CODE,
    UNIT_OF_MEASURE_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    L_GROUP_ID,
    X_GROUP_TYPE_CODE,
    X_NUM_OF_TRADE_AREAS,
    X_STATUS_CODE,
    X_UNIT_OF_MEASURE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into RRS_TRADE_AREA_GROUPS_TL (
    GROUP_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    L_GROUP_ID,
    X_NAME,
    X_DESCRIPTION,
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
    from RRS_TRADE_AREA_GROUPS_TL T
    where T.GROUP_ID = L_GROUP_ID
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
  X_GROUP_ID in NUMBER,
  X_GROUP_TYPE_CODE in VARCHAR2,
  X_NUM_OF_TRADE_AREAS in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_UNIT_OF_MEASURE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      GROUP_TYPE_CODE,
      NUM_OF_TRADE_AREAS,
      STATUS_CODE,
      UNIT_OF_MEASURE_CODE,
      OBJECT_VERSION_NUMBER
    from RRS_TRADE_AREA_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    for update of GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from RRS_TRADE_AREA_GROUPS_TL
    where GROUP_ID = X_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.GROUP_TYPE_CODE = X_GROUP_TYPE_CODE)
      AND (recinfo.NUM_OF_TRADE_AREAS = X_NUM_OF_TRADE_AREAS)
      AND (recinfo.STATUS_CODE = X_STATUS_CODE)
      AND (recinfo.UNIT_OF_MEASURE_CODE = X_UNIT_OF_MEASURE_CODE)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_GROUP_ID in NUMBER,
  X_GROUP_TYPE_CODE in VARCHAR2,
  X_NUM_OF_TRADE_AREAS in NUMBER,
  X_STATUS_CODE in VARCHAR2,
  X_UNIT_OF_MEASURE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update RRS_TRADE_AREA_GROUPS_B set
    GROUP_TYPE_CODE = X_GROUP_TYPE_CODE,
    NUM_OF_TRADE_AREAS = X_NUM_OF_TRADE_AREAS,
    STATUS_CODE = X_STATUS_CODE,
    UNIT_OF_MEASURE_CODE = X_UNIT_OF_MEASURE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update RRS_TRADE_AREA_GROUPS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GROUP_ID = X_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_ID in NUMBER
) is
begin
  delete from RRS_TRADE_AREA_GROUPS_TL
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from RRS_TRADE_AREA_GROUPS_B
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from RRS_TRADE_AREA_GROUPS_TL T
  where not exists
    (select NULL
    from RRS_TRADE_AREA_GROUPS_B B
    where B.GROUP_ID = T.GROUP_ID
    );

  update RRS_TRADE_AREA_GROUPS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from RRS_TRADE_AREA_GROUPS_TL B
    where B.GROUP_ID = T.GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_ID,
      SUBT.LANGUAGE
    from RRS_TRADE_AREA_GROUPS_TL SUBB, RRS_TRADE_AREA_GROUPS_TL SUBT
    where SUBB.GROUP_ID = SUBT.GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into RRS_TRADE_AREA_GROUPS_TL (
    GROUP_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.GROUP_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from RRS_TRADE_AREA_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from RRS_TRADE_AREA_GROUPS_TL T
    where T.GROUP_ID = B.GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end RRS_TRADE_AREA_GROUPS_PKG;

/
