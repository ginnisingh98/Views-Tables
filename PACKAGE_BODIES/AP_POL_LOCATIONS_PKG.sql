--------------------------------------------------------
--  DDL for Package Body AP_POL_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_POL_LOCATIONS_PKG" as
/* $Header: apwplocb.pls 120.4 2005/11/16 04:24:34 rlangi noship $ */

/*=======================================================================+
 | Standard handlers
 *=======================================================================*/
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOCATION_ID in NUMBER,
  X_TERRITORY_CODE in VARCHAR2,
  X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_LOCATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_COUNTRY in VARCHAR2,
  X_STATE_PROVINCE_ID in NUMBER,
  X_COUNTY_ID in NUMBER,
  X_CITY_LOCALITY_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is

begin
  INSERT_ROW (X_ROWID,
              X_LOCATION_ID,
              X_TERRITORY_CODE,
              X_UNDEFINED_LOCATION_FLAG,
              X_END_DATE,
              X_LOCATION,
              X_DESCRIPTION,
              X_STATUS,
              X_LOCATION_TYPE,
              X_COUNTRY,
              X_STATE_PROVINCE_ID,
              X_COUNTY_ID,
              X_CITY_LOCALITY_ID,
              X_CREATION_DATE,
              X_CREATED_BY,
              X_LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY,
              X_LAST_UPDATE_LOGIN,
              NULL,
              userenv('LANG'));
end INSERT_ROW;

procedure LOCK_ROW (
  X_LOCATION_ID in NUMBER,
  X_TERRITORY_CODE in VARCHAR2,
  X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_LOCATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_COUNTRY in VARCHAR2,
  X_STATE_PROVINCE_ID in NUMBER,
  X_COUNTY_ID in NUMBER,
  X_CITY_LOCALITY_ID in NUMBER) is

begin
  LOCK_ROW (X_LOCATION_ID,
            X_TERRITORY_CODE,
            X_UNDEFINED_LOCATION_FLAG,
            X_END_DATE,
            X_LOCATION,
            X_DESCRIPTION,
            X_STATUS,
            X_LOCATION_TYPE,
            X_COUNTRY,
            X_STATE_PROVINCE_ID,
            X_COUNTY_ID,
            X_CITY_LOCALITY_ID,
            NULL,
            userenv('LANG'));

end LOCK_ROW;

procedure UPDATE_ROW (X_LOCATION_ID in NUMBER,
                      X_TERRITORY_CODE in VARCHAR2,
                      X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
                      X_END_DATE in DATE,
                      X_LOCATION in VARCHAR2,
                      X_DESCRIPTION in VARCHAR2,
                      X_STATUS in VARCHAR2,
                      X_LOCATION_TYPE in VARCHAR2,
                      X_COUNTRY in VARCHAR2,
                      X_STATE_PROVINCE_ID in NUMBER,
                      X_COUNTY_ID in NUMBER,
                      X_CITY_LOCALITY_ID in NUMBER,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER) is
begin
  UPDATE_ROW (X_LOCATION_ID,
              X_TERRITORY_CODE,
              X_UNDEFINED_LOCATION_FLAG,
              X_END_DATE,
              X_LOCATION,
              X_DESCRIPTION,
              X_STATUS,
              X_LOCATION_TYPE,
              X_COUNTRY,
              X_STATE_PROVINCE_ID,
              X_COUNTY_ID,
              X_CITY_LOCALITY_ID,
              X_LAST_UPDATE_DATE,
              X_LAST_UPDATED_BY,
              X_LAST_UPDATE_LOGIN,
              NULL,
              userenv('LANG'));

end UPDATE_ROW;

procedure ADD_LANGUAGE is
begin
 ADD_LANGUAGE(NULL,userenv('LANG'));
end ADD_LANGUAGE;

procedure DELETE_ROW (
  X_LOCATION_ID in NUMBER,
  X_LANGUAGE in VARCHAR2  --bug 2650513
) is
begin
  delete from AP_POL_LOCATIONS_TL
  where LOCATION_ID = X_LOCATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AP_POL_LOCATIONS_B
  where LOCATION_ID = X_LOCATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

/*=======================================================================+
 | Handlers with language
 *=======================================================================*/
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOCATION_ID in NUMBER,
  X_TERRITORY_CODE in VARCHAR2,
  X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_LOCATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_COUNTRY in VARCHAR2,
  X_STATE_PROVINCE_ID in NUMBER,
  X_COUNTY_ID in NUMBER,
  X_CITY_LOCALITY_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANG in VARCHAR2) is

  cursor C is select ROWID from AP_POL_LOCATIONS_B
    where LOCATION_ID = X_LOCATION_ID;

begin

  insert into AP_POL_LOCATIONS_B (
    LOCATION_ID,
    TERRITORY_CODE,
    UNDEFINED_LOCATION_FLAG,
    END_DATE,
    STATUS,
    LOCATION_TYPE,
    COUNTRY,
    STATE_PROVINCE_ID,
    COUNTY_ID,
    CITY_LOCALITY_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOCATION_ID,
    X_TERRITORY_CODE,
    X_UNDEFINED_LOCATION_FLAG,
    X_END_DATE,
    X_STATUS,
    X_LOCATION_TYPE,
    X_COUNTRY,
    X_STATE_PROVINCE_ID,
    X_COUNTY_ID,
    X_CITY_LOCALITY_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AP_POL_LOCATIONS_TL (
    LOCATION_ID,
    LOCATION,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOCATION_ID,
    X_LOCATION,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    NVL(X_SOURCE_LANG,BASE.LANGUAGE_CODE)
  from FND_LANGUAGES L,
       FND_LANGUAGES BASE
  where L.INSTALLED_FLAG in ('I', 'B')
  AND BASE.INSTALLED_FLAG = 'B'
  and not exists
    (select NULL
    from AP_POL_LOCATIONS_TL T
    where T.LOCATION_ID = X_LOCATION_ID
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
  X_LOCATION_ID in NUMBER,
  X_TERRITORY_CODE in VARCHAR2,
  X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_LOCATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_COUNTRY in VARCHAR2,
  X_STATE_PROVINCE_ID in NUMBER,
  X_COUNTY_ID in NUMBER,
  X_CITY_LOCALITY_ID in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANG in VARCHAR2
) is
  cursor c is select
      TERRITORY_CODE,
      UNDEFINED_LOCATION_FLAG,
      END_DATE,
      STATUS,
      LOCATION_TYPE,
      COUNTRY,
      STATE_PROVINCE_ID,
      COUNTY_ID,
      CITY_LOCALITY_ID
    from AP_POL_LOCATIONS_B
    where LOCATION_ID = X_LOCATION_ID
    for update of LOCATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOCATION,
      DESCRIPTION,
      decode(LANGUAGE, NVL(X_SOURCE_LANG,userenv('LANG')), 'Y', 'N') BASELANG
    from AP_POL_LOCATIONS_TL
    where LOCATION_ID = X_LOCATION_ID
    and NVL(X_SOURCE_LANG,userenv('LANG')) in (LANGUAGE, SOURCE_LANG)
    for update of LOCATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.TERRITORY_CODE = X_TERRITORY_CODE)
           OR ((recinfo.TERRITORY_CODE is null) AND (X_TERRITORY_CODE is null)))
      AND ((recinfo.UNDEFINED_LOCATION_FLAG = X_UNDEFINED_LOCATION_FLAG)
           OR ((recinfo.UNDEFINED_LOCATION_FLAG is null) AND (X_UNDEFINED_LOCATION_FLAG is null)))
      AND ((recinfo.STATUS = X_STATUS)
           OR ((recinfo.STATUS is null) AND (X_STATUS is null)))
      AND ((recinfo.LOCATION_TYPE = X_LOCATION_TYPE)
           OR ((recinfo.LOCATION_TYPE is null) AND (X_LOCATION_TYPE is null)))
      AND ((recinfo.COUNTRY = X_COUNTRY)
           OR ((recinfo.COUNTRY is null) AND (X_COUNTRY is null)))
      AND ((recinfo.STATE_PROVINCE_ID = X_STATE_PROVINCE_ID)
           OR ((recinfo.STATE_PROVINCE_ID is null) AND (X_STATE_PROVINCE_ID is null)))
      AND ((recinfo.COUNTY_ID = X_COUNTY_ID)
           OR ((recinfo.COUNTY_ID is null) AND (X_COUNTY_ID is null)))
      AND ((recinfo.CITY_LOCALITY_ID = X_CITY_LOCALITY_ID)
           OR ((recinfo.CITY_LOCALITY_ID is null) AND (X_CITY_LOCALITY_ID is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LOCATION = X_LOCATION)
               OR ((tlinfo.LOCATION is null) AND (X_LOCATION is null)))
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
  X_LOCATION_ID in NUMBER,
  X_TERRITORY_CODE in VARCHAR2,
  X_UNDEFINED_LOCATION_FLAG in VARCHAR2,
  X_END_DATE in DATE,
  X_LOCATION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_LOCATION_TYPE in VARCHAR2,
  X_COUNTRY in VARCHAR2,
  X_STATE_PROVINCE_ID in NUMBER,
  X_COUNTY_ID in NUMBER,
  X_CITY_LOCALITY_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LANGUAGE in VARCHAR2,
  X_SOURCE_LANG in VARCHAR2) is
begin
  update AP_POL_LOCATIONS_B set
    TERRITORY_CODE = X_TERRITORY_CODE,
    UNDEFINED_LOCATION_FLAG = X_UNDEFINED_LOCATION_FLAG,
    END_DATE = X_END_DATE,
    STATUS = X_STATUS,
    LOCATION_TYPE = X_LOCATION_TYPE,
    COUNTRY = X_COUNTRY,
    STATE_PROVINCE_ID = X_STATE_PROVINCE_ID,
    COUNTY_ID = X_COUNTY_ID,
    CITY_LOCALITY_ID = X_CITY_LOCALITY_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOCATION_ID = X_LOCATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AP_POL_LOCATIONS_TL set
    LOCATION = X_LOCATION,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = NVL(X_SOURCE_LANG,userenv('LANG'))
  where LOCATION_ID = X_LOCATION_ID
  and NVL(X_SOURCE_LANG,userenv('LANG')) in (LANGUAGE, SOURCE_LANG);


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_LANGUAGE (X_LANGUAGE in VARCHAR2,
                        X_SOURCE_LANG in VARCHAR2) is
begin
  delete from AP_POL_LOCATIONS_TL T
  where not exists
    (select NULL
    from AP_POL_LOCATIONS_B B
    where B.LOCATION_ID = T.LOCATION_ID
    );

  update AP_POL_LOCATIONS_TL T set (
      LOCATION,
      DESCRIPTION
    ) = (select
      B.LOCATION,
      B.DESCRIPTION
    from AP_POL_LOCATIONS_TL B
    where B.LOCATION_ID = T.LOCATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOCATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOCATION_ID,
      SUBT.LANGUAGE
    from AP_POL_LOCATIONS_TL SUBB, AP_POL_LOCATIONS_TL SUBT
    where SUBB.LOCATION_ID = SUBT.LOCATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOCATION <> SUBT.LOCATION
      or (SUBB.LOCATION is null and SUBT.LOCATION is not null)
      or (SUBB.LOCATION is not null and SUBT.LOCATION is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AP_POL_LOCATIONS_TL (
    LOCATION_ID,
    LOCATION,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOCATION_ID,
    B.LOCATION,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AP_POL_LOCATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = NVL(X_SOURCE_LANG,userenv('LANG'))
  and not exists
    (select NULL
    from AP_POL_LOCATIONS_TL T
    where T.LOCATION_ID = B.LOCATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AP_POL_LOCATIONS_PKG;

/
