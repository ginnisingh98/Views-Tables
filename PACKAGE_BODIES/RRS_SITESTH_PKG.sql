--------------------------------------------------------
--  DDL for Package Body RRS_SITESTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITESTH_PKG" as
/* $Header: RRSSTHPB.pls 120.2 2005/12/29 06:31 pfarkade noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SITE_ID in NUMBER,
  X_SITE_IDENTIFICATION_NUMBER in VARCHAR2,
  X_SITE_TYPE_CODE in VARCHAR2,
  X_SITE_STATUS_CODE in VARCHAR2,
  X_BRANDNAME_CODE in VARCHAR2,
  X_CALENDAR_CODE in VARCHAR2,
  X_LOCATION_ID in NUMBER,
  X_SITE_PARTY_ID in NUMBER,
  X_PARTY_SITE_ID in NUMBER,
  X_LE_PARTY_ID in NUMBER,
  X_PROPERTY_LOCATION_ID in NUMBER,
  X_TEMPLATE_COUNTRY in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_IS_TEMPLATE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  l_site_id NUMBER;

  cursor C is select ROWID from RRS_SITES_B
    where SITE_ID = l_site_id
    ;

begin

    select nvl(X_SITE_ID ,RRS_SITES_S.nextval)
    into   l_site_id
    from   dual;

    insert into RRS_SITES_B (
    SITE_ID,
    SITE_IDENTIFICATION_NUMBER,
    SITE_TYPE_CODE,
    SITE_STATUS_CODE,
    BRANDNAME_CODE,
    CALENDAR_CODE,
    LOCATION_ID,
    SITE_PARTY_ID,
    PARTY_SITE_ID,
    LE_PARTY_ID,
    PROPERTY_LOCATION_ID,
    TEMPLATE_COUNTRY,
    START_DATE,
    END_DATE,
    IS_TEMPLATE_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORGANIZATION_ID
  ) values (
    l_site_id,
    X_SITE_IDENTIFICATION_NUMBER,
    X_SITE_TYPE_CODE,
    X_SITE_STATUS_CODE,
    X_BRANDNAME_CODE,
    X_CALENDAR_CODE,
    X_LOCATION_ID,
    X_SITE_PARTY_ID,
    X_PARTY_SITE_ID,
    X_LE_PARTY_ID,
    X_PROPERTY_LOCATION_ID,
    X_TEMPLATE_COUNTRY,
    X_START_DATE,
    X_END_DATE,
    X_IS_TEMPLATE_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORGANIZATION_ID
  );

  insert into RRS_SITES_TL (
    SITE_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION
  ) select
    l_site_id,
    X_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_DESCRIPTION
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from RRS_SITES_TL T
    where T.SITE_ID = l_site_id
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
  X_SITE_ID in NUMBER,
  X_SITE_IDENTIFICATION_NUMBER in VARCHAR2,
  X_SITE_TYPE_CODE in VARCHAR2,
  X_SITE_STATUS_CODE in VARCHAR2,
  X_BRANDNAME_CODE in VARCHAR2,
  X_CALENDAR_CODE in VARCHAR2,
  X_LOCATION_ID in NUMBER,
  X_SITE_PARTY_ID in NUMBER,
  X_PARTY_SITE_ID in NUMBER,
  X_LE_PARTY_ID in NUMBER,
  X_PROPERTY_LOCATION_ID in NUMBER,
  X_TEMPLATE_COUNTRY in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_IS_TEMPLATE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SITE_IDENTIFICATION_NUMBER,
      SITE_TYPE_CODE,
      SITE_STATUS_CODE,
      BRANDNAME_CODE,
      CALENDAR_CODE,
      LOCATION_ID,
      SITE_PARTY_ID,
      PARTY_SITE_ID,
      LE_PARTY_ID,
      PROPERTY_LOCATION_ID,
      TEMPLATE_COUNTRY,
      START_DATE,
      END_DATE,
      IS_TEMPLATE_FLAG,
      OBJECT_VERSION_NUMBER,
      ORGANIZATION_ID
    from RRS_SITES_B
    where SITE_ID = X_SITE_ID
    for update of SITE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG,
      DESCRIPTION
    from RRS_SITES_TL
    where SITE_ID = X_SITE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SITE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SITE_IDENTIFICATION_NUMBER = X_SITE_IDENTIFICATION_NUMBER)
      AND (recinfo.SITE_TYPE_CODE = X_SITE_TYPE_CODE)
      AND (recinfo.SITE_STATUS_CODE = X_SITE_STATUS_CODE)
      AND ((recinfo.BRANDNAME_CODE = X_BRANDNAME_CODE)
           OR ((recinfo.BRANDNAME_CODE is null) AND (X_BRANDNAME_CODE is null)))
      AND ((recinfo.CALENDAR_CODE = X_CALENDAR_CODE)
           OR ((recinfo.CALENDAR_CODE is null) AND (X_CALENDAR_CODE is null)))
      AND ((recinfo.LOCATION_ID = X_LOCATION_ID)
           OR ((recinfo.LOCATION_ID is null) AND (X_LOCATION_ID is null)))
      AND ((recinfo.SITE_PARTY_ID = X_SITE_PARTY_ID)
           OR ((recinfo.SITE_PARTY_ID is null) AND (X_SITE_PARTY_ID is null)))
      AND ((recinfo.PARTY_SITE_ID = X_PARTY_SITE_ID)
           OR ((recinfo.PARTY_SITE_ID is null) AND (X_PARTY_SITE_ID is null)))
      AND ((recinfo.LE_PARTY_ID = X_LE_PARTY_ID)
           OR ((recinfo.LE_PARTY_ID is null) AND (X_LE_PARTY_ID is null)))
      AND ((recinfo.PROPERTY_LOCATION_ID = X_PROPERTY_LOCATION_ID)
           OR ((recinfo.PROPERTY_LOCATION_ID is null) AND (X_PROPERTY_LOCATION_ID is null)))
      AND ((recinfo.TEMPLATE_COUNTRY = X_TEMPLATE_COUNTRY)
           OR ((recinfo.TEMPLATE_COUNTRY is null) AND (X_TEMPLATE_COUNTRY is null)))
      AND ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.IS_TEMPLATE_FLAG = X_IS_TEMPLATE_FLAG)
           OR ((recinfo.IS_TEMPLATE_FLAG is null) AND (X_IS_TEMPLATE_FLAG is null)))
      AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
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
  X_SITE_ID in NUMBER,
  X_SITE_IDENTIFICATION_NUMBER in VARCHAR2,
  X_SITE_TYPE_CODE in VARCHAR2,
  X_SITE_STATUS_CODE in VARCHAR2,
  X_BRANDNAME_CODE in VARCHAR2,
  X_CALENDAR_CODE in VARCHAR2,
  X_LOCATION_ID in NUMBER,
  X_SITE_PARTY_ID in NUMBER,
  X_PARTY_SITE_ID in NUMBER,
  X_LE_PARTY_ID in NUMBER,
  X_PROPERTY_LOCATION_ID in NUMBER,
  X_TEMPLATE_COUNTRY in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_IS_TEMPLATE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
) is
begin
  update RRS_SITES_B set
    SITE_IDENTIFICATION_NUMBER = X_SITE_IDENTIFICATION_NUMBER,
    SITE_TYPE_CODE = X_SITE_TYPE_CODE,
    SITE_STATUS_CODE = X_SITE_STATUS_CODE,
    BRANDNAME_CODE = X_BRANDNAME_CODE,
    CALENDAR_CODE = X_CALENDAR_CODE,
    LOCATION_ID = X_LOCATION_ID,
    SITE_PARTY_ID = X_SITE_PARTY_ID,
    PARTY_SITE_ID = X_PARTY_SITE_ID,
    LE_PARTY_ID = X_LE_PARTY_ID,
    PROPERTY_LOCATION_ID = X_PROPERTY_LOCATION_ID,
    TEMPLATE_COUNTRY = X_TEMPLATE_COUNTRY,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    IS_TEMPLATE_FLAG = X_IS_TEMPLATE_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ORGANIZATION_ID = X_ORGANIZATION_ID
  where SITE_ID = X_SITE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update RRS_SITES_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG'),
    DESCRIPTION = X_DESCRIPTION
  where SITE_ID = X_SITE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SITE_ID in NUMBER
) is
begin
  delete from RRS_SITES_TL
  where SITE_ID = X_SITE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from RRS_SITES_B
  where SITE_ID = X_SITE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from RRS_SITES_TL T
  where not exists
    (select NULL
    from RRS_SITES_B B
    where B.SITE_ID = T.SITE_ID
    );

  update RRS_SITES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from RRS_SITES_TL B
    where B.SITE_ID = T.SITE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SITE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SITE_ID,
      SUBT.LANGUAGE
    from RRS_SITES_TL SUBB, RRS_SITES_TL SUBT
    where SUBB.SITE_ID = SUBT.SITE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into RRS_SITES_TL (
    SITE_ID,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION
  ) select /*+ ORDERED */
    B.SITE_ID,
    B.NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.DESCRIPTION
  from RRS_SITES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from RRS_SITES_TL T
    where T.SITE_ID = B.SITE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end RRS_SITESTH_PKG;

/
