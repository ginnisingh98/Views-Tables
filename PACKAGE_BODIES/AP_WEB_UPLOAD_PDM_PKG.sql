--------------------------------------------------------
--  DDL for Package Body AP_WEB_UPLOAD_PDM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_UPLOAD_PDM_PKG" AS
/* $Header: apwupdmb.pls 120.13.12010000.3 2009/06/02 05:23:10 rveliche ship $ */


PROCEDURE put_line(p_buff IN VARCHAR2) IS
BEGIN
  fnd_file.put_line(fnd_file.log, p_buff);
END put_line;


------------------------------------------------------------------------
FUNCTION Concat(p_str1 IN VARCHAR2,
                p_str2 IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------
BEGIN
  if (p_str1 is null) then
    return p_str2;
  elsif (p_str2 is null) then
    return p_str1;
  else
    return p_str1||', '||p_str2;
  end if;
  return null;
END Concat;


PROCEDURE CleanRatesInterface(p_ratetype IN VARCHAR2) IS
BEGIN
  --
  put_line('Clean up oie_pol_rates_interface');
  --
  delete
  from oie_pol_rates_interface
  where
  (
   (p_ratetype = 'CONUS' and country = 'UNITED STATES' and state_province not in ('HAWAII', 'ALASKA'))
  or
   (p_ratetype = 'OCONUS' and (country <> 'UNITED STATES' or state_province in ('HAWAII', 'ALASKA')))
  );

  EXCEPTION
    when no_data_found then
        return;
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END CleanRatesInterface;


------------------------------------------------------------------------
PROCEDURE AddToZeroRates(p_city_locality  IN VARCHAR2,
                         p_county         IN VARCHAR2,
                         p_state_province IN VARCHAR2,
                         p_country        IN VARCHAR2) IS
------------------------------------------------------------------------

  i             number;
  already_added boolean := false;
  location      varchar2(240);

BEGIN
    location := Concat(Concat(Concat(p_city_locality, p_county), p_state_province), p_country);
    for i in 1..g_num_locs_zero_rates
    loop
      if (g_zero_rates(i) = location) then
        already_added := true;
        exit;
      end if;
    end loop;

    if (not already_added) then
      g_num_locs_zero_rates := g_num_locs_zero_rates + 1;
      g_zero_rates.extend(1);
      g_zero_rates(g_num_locs_zero_rates) := location;
    end if;
END AddToZeroRates;


------------------------------------------------------------------------
PROCEDURE AddToInvalidLocs(p_city_locality  IN VARCHAR2,
                           p_county         IN VARCHAR2,
                           p_state_province IN VARCHAR2,
                           p_country        IN VARCHAR2) IS
------------------------------------------------------------------------
  i             number;
  already_added boolean := false;
  location      varchar2(240);

BEGIN
    location := Concat(Concat(Concat(p_city_locality, p_county), p_state_province), p_country);
    for i in 1..g_num_locs_invalid
    loop
      if (g_invalid_locs(i) = location) then
        already_added := true;
        exit;
      end if;
    end loop;

    if (not already_added) then
      g_num_locs_invalid := g_num_locs_invalid + 1;
      g_invalid_locs.extend(1);
      g_invalid_locs(g_num_locs_invalid) := location;
    end if;
END AddToInvalidLocs;


------------------------------------------------------------------------
FUNCTION MyReplace(p_string           IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------
BEGIN
  if (p_string is not null) then
    return replace(replace(replace(replace(replace(replace(replace(p_string,', THE','%'),' REPUBLIC OF','%'),' ISLANDS','%'),' ISLAND','%'),', ','%'),'-','%'),'.','%');
  end if;
  return null;
END MyReplace;

------------------------------------------------------------------------
FUNCTION MySoundex(p_string           IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------
BEGIN
  if (p_string is not null) then
    return soundex(myreplace(p_string));
  end if;
  return null;
END MySoundex;


------------------------------------------------------------------------
FUNCTION GetTerritory(p_country           IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  -------------------
  -- exact match cursor
  -------------------
  CURSOR exact_cur IS
    select territory_code
    from   fnd_territories_vl
    where  upper(territory_short_name) = upper(p_country)
    and    rownum = 1;

  exact_rec exact_cur%ROWTYPE;

  -------------------
  -- fuzzy match cursor
  -------------------
  CURSOR fuzzy_count_cur IS
    select count(1) fuzzy_count
    from   fnd_territories_vl
    where
    (
           upper(territory_short_name) like '%'||upper(p_country)||'%'
      or
           upper(description) like '%'||upper(p_country)||'%'
    );

  fuzzy_count_rec fuzzy_count_cur%ROWTYPE;
  l_fuzzy_count			NUMBER := 0;

  CURSOR fuzzy_cur IS
    select territory_code
    from   fnd_territories_vl
    where
    (
           upper(territory_short_name) like '%'||upper(p_country)||'%'
      or
           upper(description) like '%'||upper(p_country)||'%'
    )
    and    rownum = 1;

  fuzzy_rec fuzzy_cur%ROWTYPE;

  -------------------
  -- extreme fuzzy match cursor
  -------------------
  CURSOR extreme_fuzzy_count_cur IS
    select count(1) extreme_fuzzy_count
    from   fnd_territories_vl
    where
    (
           upper(territory_short_name) like '%'||ap_web_upload_pdm_pkg.myreplace(upper(p_country))||'%'
      or
           upper(description) like '%'||ap_web_upload_pdm_pkg.myreplace(upper(p_country))||'%'
    );

  extreme_fuzzy_count_rec extreme_fuzzy_count_cur%ROWTYPE;
  l_extreme_fuzzy_count                 NUMBER := 0;

  CURSOR extreme_fuzzy_cur IS
    select territory_code
    from   fnd_territories_vl
    where
    (
           upper(territory_short_name) like '%'||ap_web_upload_pdm_pkg.myreplace(upper(p_country))||'%'
      or
           upper(description) like '%'||ap_web_upload_pdm_pkg.myreplace(upper(p_country))||'%'
    )
    and    rownum = 1;

  extreme_fuzzy_rec extreme_fuzzy_cur%ROWTYPE;

  -------------------
  -- soundex match cursor
  -------------------
  CURSOR soundex_count_cur IS
    select count(1) soundex_count
    from   fnd_territories_vl
    where
    (
           ap_web_upload_pdm_pkg.mysoundex(upper(territory_short_name)) = ap_web_upload_pdm_pkg.mysoundex(upper(p_country))
      or
           ap_web_upload_pdm_pkg.mysoundex(upper(description)) = ap_web_upload_pdm_pkg.mysoundex(upper(p_country))
    );

  soundex_count_rec soundex_count_cur%ROWTYPE;
  l_soundex_count                 NUMBER := 0;

  CURSOR soundex_cur IS
    select territory_code
    from   fnd_territories_vl
    where
    (
           ap_web_upload_pdm_pkg.mysoundex(territory_short_name) = ap_web_upload_pdm_pkg.mysoundex(p_country)
      or
           ap_web_upload_pdm_pkg.mysoundex(description) = ap_web_upload_pdm_pkg.mysoundex(p_country)
    )
    and    rownum = 1;

  soundex_rec soundex_cur%ROWTYPE;


BEGIN

  OPEN  exact_cur;
  FETCH exact_cur INTO exact_rec;
  CLOSE exact_cur;

  if (exact_rec.territory_code is not null) then

    -- exact match
    return exact_rec.territory_code;

  else

    OPEN  fuzzy_count_cur;
    FETCH fuzzy_count_cur INTO fuzzy_count_rec;
    CLOSE fuzzy_count_cur;

    if (fuzzy_count_rec.fuzzy_count = 1) then

      -- fuzzy match found 1
      OPEN  fuzzy_cur;
      FETCH fuzzy_cur INTO fuzzy_rec;
      CLOSE fuzzy_cur;

      return fuzzy_rec.territory_code;

    else

      OPEN  extreme_fuzzy_count_cur;
      FETCH extreme_fuzzy_count_cur INTO extreme_fuzzy_count_rec;
      CLOSE extreme_fuzzy_count_cur;

      if (extreme_fuzzy_count_rec.extreme_fuzzy_count = 1) then

        -- extreme fuzzy match found 1
        OPEN  extreme_fuzzy_cur;
        FETCH extreme_fuzzy_cur INTO extreme_fuzzy_rec;
        CLOSE extreme_fuzzy_cur;

        return extreme_fuzzy_rec.territory_code;

      else

        OPEN  soundex_count_cur;
        FETCH soundex_count_cur INTO soundex_count_rec;
        CLOSE soundex_count_cur;

        if (soundex_count_rec.soundex_count = 1) then

          -- soundex match found 1
          OPEN  soundex_cur;
          FETCH soundex_cur INTO soundex_rec;
          CLOSE soundex_cur;

          return soundex_rec.territory_code;

        end if; /* soundex_count_rec.soundex_count = 1 */

      end if; /* extreme_fuzzy_count_rec.extreme_fuzzy_count = 1 */

    end if; /* fuzzy_count_rec.fuzzy_count = 1 */

  end if; /* exact_rec.territory_code is not null */

  return null;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetTerritory;


------------------------------------------------------------------------
FUNCTION CreateLocation(p_location           IN VARCHAR2,
                        p_location_type      IN VARCHAR2,
                        p_city_locality_id   IN NUMBER,
                        p_county_id          IN NUMBER,
                        p_state_province_id  IN NUMBER,
                        p_country            IN VARCHAR2,
                        p_territory_code     IN VARCHAR2,
                        p_undefined_location IN VARCHAR2) RETURN NUMBER IS
------------------------------------------------------------------------

  l_location_id		NUMBER;
  l_description		VARCHAR2(240);

BEGIN

  if (p_location_type = 'CITY') then
    if (p_territory_code = 'US') then
      /* CONUS - City/Locality||', '||County||', '||State/Province */
      l_description := Concat(p_location, AP_WEB_POLICY_UTILS.get_location(p_county_id));
      l_description := Concat(l_description, AP_WEB_POLICY_UTILS.get_location(p_state_province_id));
    elsif (p_undefined_location = 'N') then
      /* OCONUS - City/Locality||', '||Country */
      l_description := Concat(p_location, p_country);
    else
      l_description := p_location;
    end if;
  else
    l_description := p_location;
  end if;

/*
  put_line('CreateLocation : ');
  put_line('=> Location : '||initcap(p_location));
  put_line('=> Location Type : '||p_location_type);
  put_line('=> Description : '||l_description);
  put_line('=> City Locality Id : '||p_city_locality_id);
  put_line('=> County Id : '||p_county_id);
  put_line('=> State Province Id : '||p_state_province_id);
  put_line('=> Country : '||p_country);
  put_line('=> Territory Code : '||p_territory_code);
  put_line('=> Undefined Location : '||p_undefined_location);
*/

  select ap_pol_locations_s.nextval
  into   l_location_id
  from   dual;

  insert into AP_POL_LOCATIONS_B (
    LOCATION_ID,
    TERRITORY_CODE,
    UNDEFINED_LOCATION_FLAG,
    END_DATE,
    STATUS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LOCATION_TYPE,
    CITY_LOCALITY_ID,
    COUNTY_ID,
    STATE_PROVINCE_ID,
    COUNTRY
  ) values (
    --LOCATION_ID,
    l_location_id,
    --TERRITORY_CODE,
    p_territory_code,
    --UNDEFINED_LOCATION_FLAG,
    nvl(p_undefined_location, 'N'),
    --END_DATE,
    null,
    --STATUS,
    decode(p_territory_code, null, decode(p_undefined_location, 'Y', 'ACTIVE', 'INVALID'), 'ACTIVE'),
    --CREATION_DATE,
    sysdate,
    --CREATED_BY,
    fnd_global.user_id,
    --LAST_UPDATE_DATE,
    sysdate,
    --LAST_UPDATED_BY,
    fnd_global.user_id,
    --LAST_UPDATE_LOGIN,
    fnd_global.login_id,
    --LOCATION_TYPE,
    p_location_type,
    --CITY_LOCALITY_ID,
    p_city_locality_id,
    --COUNTY_ID,
    p_county_id,
    --STATE_PROVINCE_ID,
    p_state_province_id,
    --COUNTRY
    initcap(p_country)
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
    --LOCATION_ID,
    l_location_id,
    --LOCATION,
    initcap(p_location),
    --DESCRIPTION,
    initcap(l_description),
    --CREATION_DATE,
    sysdate,
    --CREATED_BY,
    fnd_global.user_id,
    --LAST_UPDATE_LOGIN,
    fnd_global.login_id,
    --LAST_UPDATE_DATE,
    sysdate,
    --LAST_UPDATED_BY,
    fnd_global.user_id,
    --LANGUAGE,
    L.LANGUAGE_CODE,
    --SOURCE_LANG
    NVL(userenv('LANG'),BASE.LANGUAGE_CODE)
  from  FND_LANGUAGES L,
        FND_LANGUAGES BASE
  where L.INSTALLED_FLAG in ('I', 'B')
  AND   BASE.INSTALLED_FLAG = 'B'
  and   not exists
    (select NULL
     from   AP_POL_LOCATIONS_TL T
     where  T.LOCATION_ID = l_location_id
     and    T.LANGUAGE = L.LANGUAGE_CODE);

  if (p_location_type = 'CITY') then
    put_line('Created Location Id: '||l_location_id);
    g_num_locs_created := g_num_locs_created + 1;
  end if;

  return l_location_id;

  EXCEPTION
    when others then
        fnd_message.set_name('SQLAP', 'OIE_CREATE_LOCATION_ERROR');
        fnd_message.set_token('LOCATION', p_location);
        fnd_message.set_token('TYPE', p_location_type);
        APP_EXCEPTION.RAISE_EXCEPTION;

END CreateLocation;


------------------------------------------------------------------------
FUNCTION GetLocation(p_location           IN VARCHAR2,
                     p_location_type      IN VARCHAR2,
                     p_city_locality_id   IN NUMBER,
                     p_county_id          IN NUMBER,
                     p_state_province_id  IN NUMBER,
                     p_country            IN VARCHAR2,
                     p_territory_code     IN VARCHAR2) RETURN NUMBER IS
------------------------------------------------------------------------

  CURSOR loc_cur IS
    select location_id
    from   ap_pol_locations_vl
    where  upper(location) = upper(decode(p_location_type, 'CITY', location, p_location))
    and    location_type = p_location_type
    and    nvl(city_locality_id, -1) = nvl(p_city_locality_id, -1)
    and    nvl(county_id, -1) = nvl(p_county_id, -1)
    and    nvl(state_province_id, -1) = nvl(p_state_province_id, -1)
    and    nvl(upper(country), -1) = nvl(upper(p_country), -1)
    and    nvl(territory_code, -1) = nvl(p_territory_code, -1)
    and    rownum = 1;

  loc_rec loc_cur%ROWTYPE;

BEGIN

  OPEN  loc_cur;
  FETCH loc_cur INTO loc_rec;
  CLOSE loc_cur;

  if (loc_rec.location_id is not null) then
    return loc_rec.location_id;
  else
    return CreateLocation(p_location => p_location,
                          p_location_type => p_location_type,
                          p_city_locality_id => p_city_locality_id,
                          p_county_id => p_county_id,
                          p_state_province_id => p_state_province_id,
                          p_country => p_country,
                          p_territory_code => p_territory_code,
                          p_undefined_location => 'N');
  end if;

  return null;

  EXCEPTION
    when others then
      fnd_message.set_name('SQLAP', 'OIE_LOCATION_NOT_FOUND');
      fnd_message.set_token('LOCATION', p_location);
      fnd_message.set_token('TYPE', p_location_type);
      APP_EXCEPTION.RAISE_EXCEPTION;

END GetLocation;


------------------------------------------------------------------------
FUNCTION GetUndefinedCONUS RETURN NUMBER IS
------------------------------------------------------------------------

  l_city_locality_id		NUMBER;

  CURSOR undefined_conus_cur IS
    select location_id
    from   ap_pol_locations_vl
    where  city_locality_id = l_city_locality_id
    and    territory_code = 'US'
    and    rownum = 1;

  undefined_conus_rec undefined_conus_cur%ROWTYPE;

BEGIN

  l_city_locality_id := GetLocation(p_location => 'All Other United States',
                                    p_location_type => 'CITY_LOCALITY',
                                    p_city_locality_id => null,
                                    p_county_id => null,
                                    p_state_province_id => null,
                                    p_country => 'UNITED STATES',
                                    p_territory_code => 'US');

  OPEN  undefined_conus_cur;
  FETCH undefined_conus_cur INTO undefined_conus_rec;
  CLOSE undefined_conus_cur;

  if (undefined_conus_rec.location_id is not null) then
    return undefined_conus_rec.location_id;
  else
    --FND_MESSAGE.SET_NAME('SQLAP', 'OIE_ALL_OTHER_US');
    --return CreateLocation(p_location => FND_MESSAGE.GET,
    return CreateLocation(p_location => 'All Other United States',
                          p_location_type => 'CITY',
                          p_city_locality_id => l_city_locality_id,
                          p_county_id => null,
                          p_state_province_id => null,
                          p_country => 'UNITED STATES',
                          p_territory_code => 'US',
                          p_undefined_location => 'N');
  end if;

  return null;

  EXCEPTION
    when others then
      fnd_message.set_name('SQLAP', 'OIE_UNDEFINED_CONUS_NOT_FOUND');
      APP_EXCEPTION.RAISE_EXCEPTION;

END GetUndefinedCONUS;


------------------------------------------------------------------------
FUNCTION GetUndefinedLocation RETURN NUMBER IS
------------------------------------------------------------------------

  CURSOR undefined_cur IS
    select location_id
    from   ap_pol_locations_vl
    where  undefined_location_flag = 'Y'
    and    territory_code is null
    and    rownum = 1;

  undefined_rec undefined_cur%ROWTYPE;

BEGIN

  OPEN  undefined_cur;
  FETCH undefined_cur INTO undefined_rec;
  CLOSE undefined_cur;

  if (undefined_rec.location_id is not null) then
    return undefined_rec.location_id;
  else
    FND_MESSAGE.SET_NAME('SQLAP', 'OIE_ALL_OTHER');
    return CreateLocation(p_location => FND_MESSAGE.GET,
                          p_location_type => 'CITY',
                          p_city_locality_id => null,
                          p_county_id => null,
                          p_state_province_id => null,
                          p_country => null,
                          p_territory_code => null,
                          p_undefined_location => 'Y');
  end if;

  return null;

  EXCEPTION
    when others then
      fnd_message.set_name('SQLAP', 'OIE_UNDEFINED_LOCATION_NOT_FOUND');
      APP_EXCEPTION.RAISE_EXCEPTION;

END GetUndefinedLocation;


------------------------------------------------------------------------
FUNCTION get_location_status(p_location_id IN NUMBER) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  CURSOR loc_status_cur IS
    select status
    from   ap_pol_locations_vl
    where  location_id = p_location_id;

  loc_status_rec loc_status_cur%ROWTYPE;

BEGIN
  IF p_location_id is null THEN
    return null;
  END IF;

  OPEN loc_status_cur;
  FETCH loc_status_cur INTO loc_status_rec;
  CLOSE loc_status_cur;

  return loc_status_rec.status;

END get_location_status;


------------------------------------------------------------------------
FUNCTION GetCityLocation(p_city_locality   IN VARCHAR2,
                         p_county          IN VARCHAR2,
                         p_state_province  IN VARCHAR2,
                         p_country         IN VARCHAR2) RETURN NUMBER IS
------------------------------------------------------------------------

  l_territory_code		VARCHAR2(30);
  --l_country_id			NUMBER;
  l_state_province_id		NUMBER;
  l_county_id			NUMBER;
  l_city_locality_id		NUMBER;

BEGIN

/*
  put_line('GetCityLocation : ');
  put_line('=> City Locality : '||p_city_locality);
  put_line('=> County : '||p_county);
  put_line('=> State Province : '||p_state_province);
  put_line('=> Country : '||p_country);
  put_line('=> Territory Code : '||l_territory_code);
*/

  if (p_city_locality = 'ALL PLACES NOT LISTED') then
    if (p_state_province like '%CONUS%') then
      return GetUndefinedCONUS;
    else
      return GetUndefinedLocation;
    end if;
  end if;

  l_territory_code := GetTerritory(p_country => p_country);
/*
  if (l_territory_code is null) then
    -- cannot create a location without an associated fnd_territory!
    return null;
  end if;
*/

/* No need to create Country Locations
  if (p_country is not null) then
    l_country_id := GetLocation(p_location => p_country,
                                      p_location_type => 'COUNTRY',
                                      p_city_locality_id => l_city_locality_id,
                                      p_county_id => l_county_id,
                                      p_state_province_id => l_state_province_id,
                                      p_country => p_country,
                                      p_territory_code => l_territory_code);
  end if;
*/

  if (p_state_province is not null) then
    l_state_province_id := GetLocation(p_location => p_state_province,
                                      p_location_type => 'STATE_PROVINCE',
                                      p_city_locality_id => l_city_locality_id,
                                      p_county_id => l_county_id,
                                      p_state_province_id => l_state_province_id,
                                      p_country => p_country,
                                      p_territory_code => l_territory_code);
  end if;

  if (p_county is not null) then
    l_county_id := GetLocation(p_location => p_county,
                                      p_location_type => 'COUNTY',
                                      p_city_locality_id => l_city_locality_id,
                                      p_county_id => l_county_id,
                                      p_state_province_id => l_state_province_id,
                                      p_country => p_country,
                                      p_territory_code => l_territory_code);
  end if;

  if (p_city_locality is not null) then
    l_city_locality_id := GetLocation(p_location => p_city_locality,
                                      p_location_type => 'CITY_LOCALITY',
                                      p_city_locality_id => l_city_locality_id,
                                      p_county_id => l_county_id,
                                      p_state_province_id => l_state_province_id,
                                      p_country => p_country,
                                      p_territory_code => l_territory_code);
  end if;


  return GetLocation(p_location => p_city_locality,
                     p_location_type => 'CITY',
                     p_city_locality_id => l_city_locality_id,
                     p_county_id => l_county_id,
                     p_state_province_id => l_state_province_id,
                     p_country => p_country,
                     p_territory_code => l_territory_code);


  EXCEPTION
    when others then
      raise;

END GetCityLocation;



------------------------------------------------------------------------
FUNCTION CreatePolicy(p_expense_category     IN VARCHAR2,
                      p_policy_name          IN VARCHAR2 DEFAULT NULL,
                      p_policy_start_date    IN DATE DEFAULT NULL,
                      p_per_diem_type_code   IN VARCHAR2 DEFAULT NULL,
                      p_meals_rate           IN VARCHAR2 DEFAULT NULL,
                      p_free_meals_ded       IN VARCHAR2 DEFAULT NULL,
                      p_use_free_acc_add     IN VARCHAR2 DEFAULT NULL,
                      p_use_free_acc_ded     IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
------------------------------------------------------------------------

  l_policy_id		NUMBER(15);

BEGIN

  select AP_POL_HEADERS_S.NEXTVAL
  into   l_policy_id
  from   dual;

  insert into AP_POL_HEADERS
          (
           POLICY_ID,
           CATEGORY_CODE,
           SCHEDULE_TYPE_CODE,
           SOURCE,
           POLICY_NAME,
           DESCRIPTION,
           CURRENCY_CODE,
           CURRENCY_PREFERENCE,
           ALLOW_RATE_CONVERSION_CODE,
           START_DATE,
           LOCATION_FLAG,
           PER_DIEM_TYPE_CODE,
           MEALS_TYPE_CODE,
           FREE_MEALS_FLAG,
           FREE_MEALS_CODE,
           FREE_ACCOMMODATIONS_FLAG,
           FREE_ACCOMMODATIONS_CODE,
           NIGHT_RATES_CODE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
  values
          (
           --POLICY_ID,
           l_policy_id,
           --CATEGORY_CODE,
           p_expense_category,
           --SCHEDULE_TYPE_CODE,
           p_expense_category,
           --SOURCE,
           'CONUS',
           --POLICY_NAME,
           p_policy_name,
           --DESCRIPTION,
           p_policy_name,
           --CURRENCY_CODE,
           'USD',
           --CURRENCY_PREFERENCE,
           'SRC',
           --ALLOW_RATE_CONVERSION_CODE,
           'ALLOW_CONVERSION',
           --START_DATE,
           p_policy_start_date,
           --LOCATION_FLAG,
           'Y',
           --PER_DIEM_TYPE_CODE,
           p_per_diem_type_code,
           --MEALS_TYPE_CODE,
           p_meals_rate,
           --FREE_MEALS_FLAG,
           decode(p_free_meals_ded, 'SINGLE', 'Y', 'SPECIFIC', 'Y', null),
           --FREE_MEALS_CODE,
           p_free_meals_ded,
           --FREE_ACCOMMODATIONS_FLAG,
           decode(p_use_free_acc_add, 'Y', 'Y', decode(p_use_free_acc_ded, 'Y', 'Y', null)),
           --FREE_ACCOMMODATIONS_CODE,
           decode(p_use_free_acc_add, 'Y', 'ADD', decode(p_use_free_acc_ded, 'Y', 'DEDUCT', null)),
           --NIGHT_RATES_CODE,
           decode(p_use_free_acc_add, 'Y', 'SINGLE', null),
           --CREATION_DATE,
           SYSDATE,
           --CREATED_BY,
           fnd_global.user_id,
           --LAST_UPDATE_LOGIN,
           fnd_global.login_id,
           --LAST_UPDATE_DATE,
           SYSDATE,
           --LAST_UPDATED_BY
           fnd_global.user_id
          );

  return l_policy_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END CreatePolicy;


------------------------------------------------------------------------
FUNCTION CreateScheduleOption(p_policy_id   IN NUMBER,
                              p_location_id IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------

  l_schedule_option_id           NUMBER(15);

BEGIN

  select AP_POL_SCHEDULE_OPTIONS_S.NEXTVAL
  into   l_schedule_option_id
  from   dual;

  insert into AP_POL_SCHEDULE_OPTIONS
          (
           SCHEDULE_OPTION_ID,
           POLICY_ID,
           OPTION_TYPE,
           LOCATION_ID,
           STATUS,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
  values
          (
           --SCHEDULE_OPTION_ID,
           l_schedule_option_id,
           --POLICY_ID,
           p_policy_id,
           --OPTION_TYPE,
           'LOCATION',
           --LOCATION_ID,
           p_location_id,
           --STATUS,
           'SAVED',
           --CREATION_DATE,
           SYSDATE,
           --CREATED_BY,
           fnd_global.user_id,
           --LAST_UPDATE_LOGIN,
           fnd_global.login_id,
           --LAST_UPDATE_DATE,
           SYSDATE,
           --LAST_UPDATED_BY
           fnd_global.user_id
          );

  return l_schedule_option_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END CreateScheduleOption;


------------------------------------------------------------------------
FUNCTION CreateSchedulePeriod(p_policy_id         IN NUMBER,
                              p_period_name       IN VARCHAR2,
                              p_period_start_date IN DATE) RETURN NUMBER IS
------------------------------------------------------------------------

  l_schedule_period_id           NUMBER(15);

BEGIN

  select AP_POL_SCHEDULE_PERIODS_S.NEXTVAL
  into   l_schedule_period_id
  from   dual;

  insert into AP_POL_SCHEDULE_PERIODS
          (
           SCHEDULE_PERIOD_ID,
           SCHEDULE_PERIOD_NAME,
           POLICY_ID,
           START_DATE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
  values
          (
           --SCHEDULE_PERIOD_ID,
           l_schedule_period_id,
           --SCHEDULE_PERIOD_NAME,
           p_period_name,
           --POLICY_ID,
           p_policy_id,
           --START_DATE,
           p_period_start_date,
           --CREATION_DATE,
           SYSDATE,
           --CREATED_BY,
           fnd_global.user_id,
           --LAST_UPDATE_LOGIN,
           fnd_global.login_id,
           --LAST_UPDATE_DATE,
           SYSDATE,
           --LAST_UPDATED_BY
           fnd_global.user_id
          );

  return l_schedule_period_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END CreateSchedulePeriod;


------------------------------------------------------------------------
FUNCTION CreatePolicyLine(p_policy_id			IN NUMBER,
                          p_schedule_period_id		IN NUMBER,
                          p_role_id			IN NUMBER,
                          p_location_id			IN NUMBER,
                          p_rate			IN NUMBER,
                          p_calc_method			IN VARCHAR2,
                          p_single_deduction		IN NUMBER,
                          p_breakfast_deduction		IN NUMBER,
                          p_lunch_deduction		IN NUMBER,
                          p_dinner_deduction		IN NUMBER,
                          p_start_of_season		IN VARCHAR2,
                          p_end_of_season		IN VARCHAR2,
                          p_max_lodging_amt		IN NUMBER,
                          p_no_govt_meals_amt		IN NUMBER,
                          p_prop_meals_amt		IN NUMBER,
                          p_off_base_inc_amt		IN NUMBER,
                          p_footnote_amt		IN NUMBER,
                          p_footnote_rate_amt		IN NUMBER,
                          p_max_per_diem_amt		IN NUMBER,
                          p_effective_start_date	IN DATE,
                          p_effective_end_date		IN DATE,
                          p_use_free_acc_add            IN VARCHAR2 DEFAULT NULL,
                          p_use_free_acc_ded            IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
------------------------------------------------------------------------

  l_policy_line_id           NUMBER(15);

BEGIN

  select AP_POL_LINES_S.NEXTVAL
  into   l_policy_line_id
  from   dual;


  insert into AP_POL_LINES
          (
           POLICY_LINE_ID,
           POLICY_ID,
           SCHEDULE_PERIOD_ID,
           ROLE_ID,
           LOCATION_ID,
           CURRENCY_CODE,
           RATE,
           RATE_TYPE_CODE,
           CALCULATION_METHOD,
           ACCOMMODATION_CALC_METHOD,
           ACCOMMODATION_ADJUSTMENT,
           MEALS_DEDUCTION,
           BREAKFAST_DEDUCTION,
           LUNCH_DEDUCTION,
           DINNER_DEDUCTION,
           STATUS,
           START_OF_SEASON,
           END_OF_SEASON,
           MAX_LODGING_AMT,
           NO_GOVT_MEALS_AMT,
           PROP_MEALS_AMT,
           OFF_BASE_INC_AMT,
           FOOTNOTE_AMT,
           FOOTNOTE_RATE_AMT,
           MAX_PER_DIEM_AMT,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
  values
          (
           --POLICY_LINE_ID,
           l_policy_line_id,
           --POLICY_ID,
           p_policy_id,
           --SCHEDULE_PERIOD_ID,
           p_schedule_period_id,
           --ROLE_ID,
           p_role_id,
           --LOCATION_ID,
           p_location_id,
           --CURRENCY_CODE,
           'USD',
           --RATE,
           p_rate,
           --RATE_TYPE_CODE,
           'STANDARD',
           --CALCULATION_METHOD,
           p_calc_method,
	   -- Accommodataion Calc Method and Accomodation Adjustment is set only to Night Rate Lines if Free Accomodation is Enabled.- bug 6430013
           --ACCOMMODATION_CALC_METHOD,
           decode(p_use_free_acc_add, 'Y', null, decode(p_use_free_acc_ded, 'Y', 'AMOUNT', null)),
           --ACCOMMODATION_ADJUSTMENT,
           decode(p_use_free_acc_add, 'Y', null, decode(p_use_free_acc_ded, 'Y', p_max_lodging_amt, null)),
           --MEALS_DEDUCTION,
           p_single_deduction,
           --BREAKFAST_DEDUCTION,
           p_breakfast_deduction,
           --LUNCH_DEDUCTION,
           p_lunch_deduction,
           --DINNER_DEDUCTION,
           p_dinner_deduction,
           --STATUS,
           'NEW',
           --START_OF_SEASON,
           p_start_of_season,
           --END_OF_SEASON,
           p_end_of_season,
           --MAX_LODGING_AMT,
           p_max_lodging_amt,
           --NO_GOVT_MEALS_AMT,
           p_no_govt_meals_amt,
           --PROP_MEALS_AMT,
           p_prop_meals_amt,
           --OFF_BASE_INC_AMT,
           p_off_base_inc_amt,
           --FOOTNOTE_AMT,
           p_footnote_amt,
           --FOOTNOTE_RATE_AMT,
           p_footnote_rate_amt,
           --MAX_PER_DIEM_AMT,
           p_max_per_diem_amt,
           --EFFECTIVE_START_DATE,
           p_effective_start_date,
           --EFFECTIVE_END_DATE,
           p_effective_end_date,
           --CREATION_DATE,
           SYSDATE,
           --CREATED_BY,
           fnd_global.user_id,
           --LAST_UPDATE_LOGIN,
           fnd_global.login_id,
           --LAST_UPDATE_DATE,
           SYSDATE,
           --LAST_UPDATED_BY
           fnd_global.user_id
          );

  return l_policy_line_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END CreatePolicyLine;


------------------------------------------------------------------------
FUNCTION CreateNightRateLine(p_policy_id		IN NUMBER,
                             p_schedule_period_id	IN NUMBER,
                             p_role_id			IN NUMBER,
                             p_location_id		IN NUMBER,
                             p_rate			IN NUMBER,
                             p_single_deduction		IN NUMBER,
                             p_breakfast_deduction	IN NUMBER,
                             p_lunch_deduction		IN NUMBER,
                             p_dinner_deduction		IN NUMBER,
                             p_start_of_season		IN VARCHAR2,
                             p_end_of_season		IN VARCHAR2,
                             p_max_lodging_amt		IN NUMBER,
                             p_no_govt_meals_amt	IN NUMBER,
                             p_prop_meals_amt		IN NUMBER,
                             p_off_base_inc_amt		IN NUMBER,
                             p_footnote_amt		IN NUMBER,
                             p_footnote_rate_amt	IN NUMBER,
                             p_max_per_diem_amt		IN NUMBER,
                             p_effective_start_date	IN DATE,
                             p_effective_end_date	IN DATE) RETURN NUMBER IS
------------------------------------------------------------------------

  l_night_rate_line_id           NUMBER(15);

BEGIN

  select AP_POL_LINES_S.NEXTVAL
  into   l_night_rate_line_id
  from   dual;


  insert into AP_POL_LINES
          (
           POLICY_LINE_ID,
           POLICY_ID,
           SCHEDULE_PERIOD_ID,
           ROLE_ID,
           LOCATION_ID,
           CURRENCY_CODE,
           RATE,
           RATE_TYPE_CODE,
           CALCULATION_METHOD,
           ACCOMMODATION_CALC_METHOD,
           ACCOMMODATION_ADJUSTMENT,
           MEALS_DEDUCTION,
           BREAKFAST_DEDUCTION,
           LUNCH_DEDUCTION,
           DINNER_DEDUCTION,
           STATUS,
           START_OF_SEASON,
           END_OF_SEASON,
           MAX_LODGING_AMT,
           NO_GOVT_MEALS_AMT,
           PROP_MEALS_AMT,
           OFF_BASE_INC_AMT,
           FOOTNOTE_AMT,
           FOOTNOTE_RATE_AMT,
           MAX_PER_DIEM_AMT,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
          )
  values
          (
           --POLICY_LINE_ID,
           l_night_rate_line_id,
           --POLICY_ID,
           p_policy_id,
           --SCHEDULE_PERIOD_ID,
           p_schedule_period_id,
           --ROLE_ID,
           p_role_id,
           --LOCATION_ID,
           p_location_id,
           --CURRENCY_CODE,
           'USD',
           --RATE,
           p_rate,
           --RATE_TYPE_CODE,
           'NIGHT_RATE',
           --CALCULATION_METHOD,
           'AMOUNT',
           --ACCOMMODATION_CALC_METHOD,
           'AMOUNT',
           --ACCOMMODATION_ADJUSTMENT,
           p_max_lodging_amt,
           --MEALS_DEDUCTION,
           p_single_deduction,
           --BREAKFAST_DEDUCTION,
           p_breakfast_deduction,
           --LUNCH_DEDUCTION,
           p_lunch_deduction,
           --DINNER_DEDUCTION,
           p_dinner_deduction,
           --STATUS,
           'NEW',
           --START_OF_SEASON,
           p_start_of_season,
           --END_OF_SEASON,
           p_end_of_season,
           --MAX_LODGING_AMT,
           p_max_lodging_amt,
           --NO_GOVT_MEALS_AMT,
           p_no_govt_meals_amt,
           --PROP_MEALS_AMT,
           p_prop_meals_amt,
           --OFF_BASE_INC_AMT,
           p_off_base_inc_amt,
           --FOOTNOTE_AMT,
           p_footnote_amt,
           --FOOTNOTE_RATE_AMT,
           p_footnote_rate_amt,
           --MAX_PER_DIEM_AMT,
           p_max_per_diem_amt,
           --EFFECTIVE_START_DATE,
           p_effective_start_date,
           --EFFECTIVE_END_DATE,
           p_effective_end_date,
           --CREATION_DATE,
           SYSDATE,
           --CREATED_BY,
           fnd_global.user_id,
           --LAST_UPDATE_LOGIN,
           fnd_global.login_id,
           --LAST_UPDATE_DATE,
           SYSDATE,
           --LAST_UPDATED_BY
           fnd_global.user_id
          );

  return l_night_rate_line_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END CreateNightRateLine;


------------------------------------------------------------------------
FUNCTION GetPolicy(p_policy_id IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------

cursor policy_cur is
  select policy_id
  from   ap_pol_headers
  where  policy_id = p_policy_id
  and    rownum = 1;

  policy_rec policy_cur%ROWTYPE;

BEGIN

  OPEN  policy_cur;
  FETCH policy_cur INTO policy_rec;
  CLOSE policy_cur;
  return policy_rec.policy_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END GetPolicy;


------------------------------------------------------------------------
FUNCTION GetScheduleOption(p_policy_id IN NUMBER,
                           p_location_id IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------

cursor schedule_option_cur is
  select schedule_option_id
  from   ap_pol_schedule_options
  where  policy_id = p_policy_id
  and    option_type = 'LOCATION'
  and    location_id = p_location_id
  and    rownum = 1;

  schedule_option_rec schedule_option_cur%ROWTYPE;

BEGIN

  OPEN  schedule_option_cur;
  FETCH schedule_option_cur INTO schedule_option_rec;
  CLOSE schedule_option_cur;
  return schedule_option_rec.schedule_option_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END GetScheduleOption;


------------------------------------------------------------------------
FUNCTION GetSchedulePeriod(p_policy_id IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------

cursor schedule_period_cur is
  select schedule_period_id
  from   ap_pol_schedule_periods
  where  policy_id = p_policy_id
  and    rownum = 1;

  schedule_period_rec schedule_period_cur%ROWTYPE;

BEGIN

  OPEN  schedule_period_cur;
  FETCH schedule_period_cur INTO schedule_period_rec;
  CLOSE schedule_period_cur;
  return schedule_period_rec.schedule_period_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END GetSchedulePeriod;


------------------------------------------------------------------------
FUNCTION GetPolicyLine(p_policy_id IN NUMBER,
                       p_schedule_period_id IN NUMBER,
                       p_role_id IN NUMBER,
                       p_location_id IN NUMBER,
                       p_start_of_season IN VARCHAR2,
                       p_end_of_season IN VARCHAR2,
                       p_effective_start_date IN DATE) RETURN NUMBER IS
------------------------------------------------------------------------

cursor policy_line_cur is
  select policy_line_id
  from   ap_pol_lines
  where  policy_id = p_policy_id
  and    schedule_period_id = p_schedule_period_id
  and    nvl(role_id, -1) = nvl(p_role_id, -1)
  and    location_id = p_location_id
  and    nvl(start_of_season, -1) = nvl(p_start_of_season, -1)
  and    nvl(end_of_season, -1) = nvl(p_end_of_season, -1)
  and    effective_start_date = p_effective_start_date
  and    rownum = 1;

  policy_line_rec policy_line_cur%ROWTYPE;

BEGIN

  OPEN  policy_line_cur;
  FETCH policy_line_cur INTO policy_line_rec;
  CLOSE policy_line_cur;
  return policy_line_rec.policy_line_id;

EXCEPTION
 WHEN OTHERS THEN
  raise;

END GetPolicyLine;


------------------------------------------------------------------------
FUNCTION CheckPolicyExists(p_expense_category       IN VARCHAR2,
                           p_policy_name            IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  CURSOR policy_cur IS
    select policy_id
    from   ap_pol_headers
    where  category_code = p_expense_category
    and    upper(policy_name) = upper(p_policy_name)
    and    rownum = 1;

  policy_rec policy_cur%ROWTYPE;

BEGIN

  OPEN  policy_cur;
  FETCH policy_cur INTO policy_rec;
  CLOSE policy_cur;

  if (policy_rec.policy_id is not null) then

    -- policy already exists
    return 'Y';

  end if;

  return 'N';

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END CheckPolicyExists;


------------------------------------------------------------------------
FUNCTION CheckPeriodExists(p_policy_id            IN VARCHAR2,
                           p_period_name          IN VARCHAR2,
                           p_period_start_date    IN DATE) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  CURSOR period_cur IS
    select schedule_period_id
    from   ap_pol_schedule_periods
    where  policy_id = p_policy_id
    and    upper(schedule_period_name) = upper(p_period_name)
    and    start_date = p_period_start_date
    and    rownum = 1;

  period_rec period_cur%ROWTYPE;

BEGIN

  OPEN  period_cur;
  FETCH period_cur INTO period_rec;
  CLOSE period_cur;

  if (period_rec.schedule_period_id is not null) then

    -- period already exists
    return 'Y';

  end if;

  return 'N';

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END CheckPeriodExists;


------------------------------------------------------------------------
FUNCTION GetLatestPeriodStartDate(p_policy_id            IN VARCHAR2) RETURN DATE IS
------------------------------------------------------------------------

  CURSOR latest_period_cur IS
    select max(start_date) as start_date
    from   ap_pol_schedule_periods
    where  policy_id = p_policy_id
    and    rownum = 1;

  latest_period_rec latest_period_cur%ROWTYPE;

BEGIN

  OPEN  latest_period_cur;
  FETCH latest_period_cur INTO latest_period_rec;
  CLOSE latest_period_cur;

  return latest_period_rec.start_date;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetLatestPeriodStartDate;


------------------------------------------------------------------------
FUNCTION GetPerDiemTypeCode(p_policy_id            IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  CURSOR per_diem_type_code_cur IS
    select per_diem_type_code
    from   ap_pol_headers
    where  policy_id = p_policy_id
    and    rownum = 1;

  per_diem_type_code_rec per_diem_type_code_cur%ROWTYPE;

BEGIN

  OPEN  per_diem_type_code_cur;
  FETCH per_diem_type_code_cur INTO per_diem_type_code_rec;
  CLOSE per_diem_type_code_cur;

  return per_diem_type_code_rec.per_diem_type_code;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetPerDiemTypeCode;


------------------------------------------------------------------------
FUNCTION GetMealsTypeCode(p_policy_id            IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  CURSOR meals_type_code_cur IS
    select meals_type_code
    from   ap_pol_headers
    where  policy_id = p_policy_id
    and    rownum = 1;

  meals_type_code_rec meals_type_code_cur%ROWTYPE;

BEGIN

  OPEN  meals_type_code_cur;
  FETCH meals_type_code_cur INTO meals_type_code_rec;
  CLOSE meals_type_code_cur;

  return meals_type_code_rec.meals_type_code;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetMealsTypeCode;


------------------------------------------------------------------------
FUNCTION GetPerDiemTypeCode(p_rate_incl_meals	IN VARCHAR2,
                            p_rate_incl_inc	IN VARCHAR2,
                            p_rate_incl_acc	IN VARCHAR2,
                            p_meals_rate	IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

  l_per_diem_type_code		VARCHAR2(15) := '';

BEGIN

  if ('Y' = p_rate_incl_meals) then
    if ('LOCAL' = p_meals_rate) then
      l_per_diem_type_code := 'M';
    elsif ('PROPORTIONAL' = p_meals_rate) then
      l_per_diem_type_code := 'P';
    end if;
  end if;

  if ('Y' = p_rate_incl_acc) then
    l_per_diem_type_code := l_per_diem_type_code || 'A';
  end if;

  if ('Y' = p_rate_incl_inc) then
    l_per_diem_type_code := l_per_diem_type_code || 'I';
  end if;

  return l_per_diem_type_code;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetPerDiemTypeCode;


------------------------------------------------------------------------
FUNCTION GetRateIncludesMeals(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

BEGIN

  if (instrb(p_per_diem_type_code, 'M', 1) > 0) then
    return 'Y';
  end if;

  if (instrb(p_per_diem_type_code, 'P', 1) > 0) then
    return 'Y';
  end if;

  return 'N';

  EXCEPTION
    when no_data_found then
        return 'N';
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetRateIncludesMeals;


------------------------------------------------------------------------
FUNCTION GetRateIncludesIncidentals(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

BEGIN

  if (instrb(p_per_diem_type_code, 'I', 1) > 0) then
    return 'Y';
  end if;

  return 'N';

  EXCEPTION
    when no_data_found then
        return 'N';
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetRateIncludesIncidentals;


------------------------------------------------------------------------
FUNCTION GetRateIncludesAccommodations(p_per_diem_type_code   IN VARCHAR2) RETURN VARCHAR2 IS
------------------------------------------------------------------------

BEGIN

  if (instrb(p_per_diem_type_code, 'A', 1) > 0) then
    return 'Y';
  end if;

  return 'N';

  EXCEPTION
    when no_data_found then
        return 'N';
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END GetRateIncludesAccommodations;


------------------------------------------------------------------------
FUNCTION CalculateRate(p_expense_category   IN VARCHAR2,
                       p_rate_incl_meals    IN VARCHAR2,
                       p_rate_incl_inc      IN VARCHAR2,
                       p_rate_incl_acc      IN VARCHAR2,
                       p_meals_rate         IN VARCHAR2,
                       p_no_govt_meals_amt  IN NUMBER,
                       p_prop_meals_amt     IN NUMBER,
                       p_max_lodging_amt    IN NUMBER,
                       p_max_per_diem_amt   IN NUMBER) RETURN NUMBER IS
------------------------------------------------------------------------

  l_rate          NUMBER := 0;

BEGIN

  if ('PER_DIEM' = p_expense_category) then

    if ('Y' = p_rate_incl_meals) then
      if ('LOCAL' = p_meals_rate) then
        l_rate := p_no_govt_meals_amt;
      elsif ('PROPORTIONAL' = p_meals_rate) then
        l_rate := p_prop_meals_amt;
      end if;
    end if;

    if ('Y' = p_rate_incl_acc) then
      l_rate := l_rate + p_max_lodging_amt;
    end if;

    if ('Y' = p_rate_incl_inc) then
      l_rate := l_rate + p_max_per_diem_amt - p_no_govt_meals_amt - p_max_lodging_amt;
    end if;

  elsif ('MEALS' = p_expense_category) then

    if ('LOCAL' = p_meals_rate) then
      l_rate := p_no_govt_meals_amt;
    elsif ('PROPORTIONAL' = p_meals_rate) then
      l_rate := p_prop_meals_amt;
    end if;

  elsif ('ACCOMMODATIONS' = p_expense_category) then

    l_rate := p_max_lodging_amt;

  end if;

  return l_rate;

  EXCEPTION
    when others then
        APP_EXCEPTION.RAISE_EXCEPTION;

END CalculateRate;


------------------------------------------------------------------------
PROCEDURE CreateSchedule(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_ratetype             IN VARCHAR2,
                         p_expense_category     IN VARCHAR2,
                         p_policy_name          IN VARCHAR2,
                         p_policy_start_date    IN DATE,
                         p_period_name          IN VARCHAR2,
                         p_period_start_date    IN DATE,
                         p_rate_incl_meals      IN VARCHAR2,
                         p_rate_incl_inc        IN VARCHAR2,
                         p_rate_incl_acc        IN VARCHAR2,
                         p_meals_rate           IN VARCHAR2,
                         p_free_meals_ded       IN VARCHAR2,
                         p_use_free_acc_add     IN VARCHAR2,
                         p_use_free_acc_ded     IN VARCHAR2,
                         p_calc_method          IN VARCHAR2,
                         p_single_deduction     IN NUMBER,
                         p_breakfast_deduction  IN NUMBER,
                         p_lunch_deduction      IN NUMBER,
                         p_dinner_deduction     IN NUMBER) IS
------------------------------------------------------------------------

    l_debug_info              VARCHAR2(200);

    l_location_id		NUMBER(15);
    l_location_status		VARCHAR2(30);
    l_policy_id			NUMBER(15);
    l_schedule_option_id	NUMBER(15);
    l_schedule_period_id	NUMBER(15);
    l_policy_line_id		NUMBER(15);
    l_night_rate_line_id	NUMBER(15);
    l_night_start_of_season	VARCHAR2(5);
    l_night_end_of_season	VARCHAR2(5);

    l_per_diem_type_code	VARCHAR2(30);
    l_rate			NUMBER;

-------------------------------
-- cursor to check if rates exist
-------------------------------
cursor rates_exist_cur is
  select 'Y' rates_exist
  from   oie_pol_rates_interface
  where
  (
   (p_ratetype = 'CONUS' and country = 'UNITED STATES' and state_province not in ('HAWAII', 'ALASKA'))
  or
   (p_ratetype = 'OCONUS' and (country <> 'UNITED STATES' or state_province in ('HAWAII', 'ALASKA')))
  )
  and    rownum = 1;

  rates_exist_rec rates_exist_cur%ROWTYPE;

-------------------------------
-- cursor for rates
-------------------------------
cursor rates_cur is
  select city_locality,
         county,
         state_province,
         country,
         start_of_season,
         end_of_season,
         max_lodging_amt,
         no_govt_meals_amt,
         prop_meals_amt,
         off_base_inc_amt,
         footnote_amt,
         footnote_rate_amt,
         max_per_diem_amt,
         effective_date,
         '' as effective_end_date
  from   oie_pol_rates_interface
  where
  (
   (p_ratetype = 'CONUS' and country = 'UNITED STATES' and state_province not in ('HAWAII', 'ALASKA'))
  or
   (p_ratetype = 'OCONUS' and (country <> 'UNITED STATES' or state_province in ('HAWAII', 'ALASKA')))
  )
  order by country, state_province, county, city_locality, to_date(effective_date, 'MM/DD/RRRR') desc, start_of_season desc;

  rates_rec rates_cur%ROWTYPE;

  last_location_id NUMBER(15);
  last_rates_rec rates_cur%ROWTYPE;

-------------------------------
-- cursor for gap rates
-------------------------------
cursor rates_gap_cur is
  select l1.location_id, min(l1.effective_start_date) as effective_start_date,
         '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines l1
  where  l1.policy_id = l_policy_id
  and    not exists
  (select 'Y'
   from   ap_pol_lines l2
   where  l2.policy_id = l1.policy_id
   and    l2.location_id = l1.location_id
   and    l2.effective_start_date = p_period_start_date
   and    rownum = 1
  ) group by l1.location_id;

  rates_gap_rec rates_gap_cur%ROWTYPE;

  l_eliminate_seasonality boolean := false;

  l_undefined_conus_location_id NUMBER := GetUndefinedCONUS;
  l_undefined_location_id NUMBER := GetUndefinedLocation;

-------------------------------
-- cursor for undefined conus rate
-------------------------------
cursor undefined_conus_rate_cur is
  select rate, '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines
  where  policy_id = l_policy_id
  and    location_id = l_undefined_conus_location_id;

  undefined_conus_rate_rec undefined_conus_rate_cur%ROWTYPE;

-------------------------------
-- cursor for undefined location rate
-------------------------------
cursor undefined_loc_rate_cur is
  select rate, '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines
  where  policy_id = l_policy_id
  and    location_id = l_undefined_location_id;

  undefined_loc_rate_rec undefined_loc_rate_cur%ROWTYPE;

BEGIN

  OPEN  rates_exist_cur;
  FETCH rates_exist_cur INTO rates_exist_rec;
  CLOSE rates_exist_cur;

  if (rates_exist_rec.rates_exist is null) then
    --
    put_line('No rates to process!');
    --
    return;
  end if;

  --
  put_line('------------------------------------------------------------');
  --
  if ('PER_DIEM' = p_expense_category) then
    --
    put_line('GetPerDiemTypeCode');
    --
    l_per_diem_type_code := GetPerDiemTypeCode(p_rate_incl_meals,
                                               p_rate_incl_inc,
                                               p_rate_incl_acc,
                                               p_meals_rate);
    --
    put_line('Per Diem Type Code: '||l_per_diem_type_code);
    --
  end if;

  --
  put_line('Create Policy');
  --
  l_policy_id := CreatePolicy(p_expense_category => p_expense_category,
                              p_policy_name => p_policy_name,
                              p_policy_start_date => p_policy_start_date,
                              p_per_diem_type_code => l_per_diem_type_code,
                              p_meals_rate => p_meals_rate,
                              p_free_meals_ded => p_free_meals_ded,
                              p_use_free_acc_add => p_use_free_acc_add,
                              p_use_free_acc_ded => p_use_free_acc_ded);
  --
  put_line('Created Policy Id: '||l_policy_id);
  --

  --
  put_line('Create Schedule Period');
  --
  l_schedule_period_id := CreateSchedulePeriod(p_policy_id => l_policy_id,
                                               p_period_name => p_period_name,
                                               p_period_start_date => p_period_start_date);
  --
  put_line('Created Schedule Period Id: '||l_schedule_period_id);
  --

  /* Eliminate seasonality when schedule
     -  contains only meals or meals and incidental rates
     -  doesn't contain Accommodations
  */
  if ('MEALS' = p_expense_category or
      ('PER_DIEM' = p_expense_category and not (instrb(l_per_diem_type_code,'A') > 0))
     ) then

    --
    put_line('Eliminating seasonality');
    --
    l_eliminate_seasonality := true;

  end if; /* Schedule contains only meals or meals and incidental rates */

  -- Bug: 6997580, Seasonality for OCONUS meals.
  if('PER_DIEM' = p_expense_category and (p_ratetype = 'OCONUS' and instrb(l_per_diem_type_code,'M') > 0)
     and l_eliminate_seasonality = true) THEN
     l_eliminate_seasonality := false;
     put_line('Reset Eliminate seasonality for OCONUS PerDiem Meals');
  end if;


  OPEN  rates_cur;
  loop

  FETCH rates_cur INTO rates_rec;
  EXIT WHEN rates_cur%NOTFOUND;

    g_num_recs_processed := g_num_recs_processed + 1;

    --
    put_line('------------------------------------------------------------');
    --
    l_location_id := GetCityLocation(p_city_locality => rates_rec.city_locality,
                                     p_county => rates_rec.county,
                                     p_state_province => rates_rec.state_province,
                                     p_country => rates_rec.country);

    l_location_status := get_location_status(p_location_id => l_location_id);

        --
        put_line('Location Id : '||l_location_id);
        put_line('Location Status : '||l_location_status);

        put_line('City Locality : '||rates_rec.city_locality);
        put_line('County : '||rates_rec.county);
        put_line('State Province : '||rates_rec.state_province);
        put_line('Country : '||rates_rec.country);
        put_line('Start of Season : '||rates_rec.start_of_season);
        put_line('End of Season : '||rates_rec.end_of_season);
        put_line('Max Lodging Amt : '||rates_rec.max_lodging_amt);
        put_line('No Govt Meals Amt : '||rates_rec.no_govt_meals_amt);
        put_line('Prop Meals Amt : '||rates_rec.prop_meals_amt);
        put_line('Off Base Inc Amt : '||rates_rec.off_base_inc_amt);
        put_line('Footnote Amt : '||rates_rec.footnote_amt);
        put_line('Footnote Rate Amt : '||rates_rec.footnote_rate_amt);
        put_line('Max Per Diem Amt : '||rates_rec.max_per_diem_amt);
        put_line('Effective Date : '||rates_rec.effective_date);
        --


    if (nvl(rates_rec.max_lodging_amt, 0) = 0 and
        nvl(rates_rec.no_govt_meals_amt, 0) = 0 and
        nvl(rates_rec.prop_meals_amt, 0) = 0 and
        nvl(rates_rec.max_per_diem_amt, 0) = 0) then

      put_line('Note: this is a zero rate location');
      AddToZeroRates(rates_rec.city_locality, rates_rec.county, rates_rec.state_province, rates_rec.country);

    end if;

    if (l_location_id is not null and l_location_status <> 'INVALID') then

        if (p_period_start_date <= to_date(rates_rec.effective_date, 'MM/DD/RRRR')) then

          --
          put_line('Leaving Effective Start Date as is');
          --
          null;

        elsif (p_period_start_date > to_date(rates_rec.effective_date, 'MM/DD/RRRR')) then

          --
          put_line('Setting Effective Start Date to Period Start Date');
          --
          rates_rec.effective_date := to_char(p_period_start_date, 'MM/DD/RRRR');

        end if; /* */

        if (last_location_id = l_location_id) then

          if (last_rates_rec.effective_date <> rates_rec.effective_date) then

            --
            put_line('Setting Effective End Date to Last Effective Start Date - 1');
            --
            rates_rec.effective_end_date := to_char(to_date(last_rates_rec.effective_date, 'MM/DD/RRRR') - 1, 'MM/DD/RRRR');

          else

            --
            put_line('Setting Effective End Date to Last Effective End Date');
            --
            rates_rec.effective_end_date := last_rates_rec.effective_end_date;

          end if;

        end if; /* (last_location_id = l_location_id) */


        l_schedule_option_id := GetScheduleOption(p_policy_id => l_policy_id,
                                                  p_location_id => l_location_id);

        if (l_schedule_option_id is null) then

          --
          put_line('Create Schedule Option');
          --
          l_schedule_option_id := CreateScheduleOption(p_policy_id => l_policy_id,
                                                       p_location_id => l_location_id);

        else

          --
          put_line('Schedule Option exists');
          --
          null;

        end if; /* l_schedule_option_id is null */

        --
        put_line('Schedule Option: '||l_schedule_option_id);
        --

        l_night_start_of_season := rates_rec.start_of_season;
        l_night_end_of_season := rates_rec.end_of_season;
        if (l_eliminate_seasonality) then
          rates_rec.start_of_season := null;
          rates_rec.end_of_season := null;
        end if;

        l_rate := CalculateRate(p_expense_category => p_expense_category,
                                p_rate_incl_meals => p_rate_incl_meals,
                                p_rate_incl_inc => p_rate_incl_inc,
                                p_rate_incl_acc => p_rate_incl_acc,
                                p_meals_rate => p_meals_rate,
                                p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                p_prop_meals_amt => rates_rec.prop_meals_amt,
                                p_max_lodging_amt => rates_rec.max_lodging_amt,
                                p_max_per_diem_amt => rates_rec.max_per_diem_amt);


        l_policy_line_id := GetPolicyLine(p_policy_id => l_policy_id,
                                          p_schedule_period_id => l_schedule_period_id,
                                          p_role_id => null,
                                          p_location_id => l_location_id,
                                          p_start_of_season => rates_rec.start_of_season,
                                          p_end_of_season => rates_rec.end_of_season,
                                          p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'));


        if (l_policy_line_id is null) then

          --
          put_line('Create Standard Rate');
          --

          l_policy_line_id := CreatePolicyLine(p_policy_id => l_policy_id,
                                               p_schedule_period_id => l_schedule_period_id,
                                               p_role_id => null,
                                               p_location_id => l_location_id,
                                               p_rate => l_rate,
                                               p_calc_method => p_calc_method,
                                               p_single_deduction => p_single_deduction,
                                               p_breakfast_deduction => p_breakfast_deduction,
                                               p_lunch_deduction => p_lunch_deduction,
                                               p_dinner_deduction => p_dinner_deduction,
                                               p_start_of_season => rates_rec.start_of_season,
                                               p_end_of_season => rates_rec.end_of_season,
                                               p_max_lodging_amt => rates_rec.max_lodging_amt,
                                               p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                               p_prop_meals_amt => rates_rec.prop_meals_amt,
                                               p_off_base_inc_amt => rates_rec.off_base_inc_amt,
                                               p_footnote_amt => rates_rec.footnote_amt,
                                               p_footnote_rate_amt => rates_rec.footnote_rate_amt,
                                               p_max_per_diem_amt => rates_rec.max_per_diem_amt,
                                               p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'),
                                               p_effective_end_date => to_date(rates_rec.effective_end_date, 'MM/DD/RRRR'),
                                               p_use_free_acc_add => p_use_free_acc_add,
                                               p_use_free_acc_ded => p_use_free_acc_ded);

          --
          put_line('Created Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
          --
          g_num_std_rates_created := g_num_std_rates_created + 1;

          if (nvl(p_use_free_acc_add, 'N') = 'Y') then

            l_night_rate_line_id := CreateNightRateLine(p_policy_id => l_policy_id,
                                                        p_schedule_period_id => l_schedule_period_id,
                                                        p_role_id => null,
                                                        p_location_id => l_location_id,
                                                        p_rate => rates_rec.max_lodging_amt,
                                                        p_single_deduction => p_single_deduction,
                                                        p_breakfast_deduction => p_breakfast_deduction,
                                                        p_lunch_deduction => p_lunch_deduction,
                                                        p_dinner_deduction => p_dinner_deduction,
                                                        p_start_of_season => l_night_start_of_season,
                                                        p_end_of_season => l_night_end_of_season,
                                                        p_max_lodging_amt => rates_rec.max_lodging_amt,
                                                        p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                                        p_prop_meals_amt => rates_rec.prop_meals_amt,
                                                        p_off_base_inc_amt => rates_rec.off_base_inc_amt,
                                                        p_footnote_amt => rates_rec.footnote_amt,
                                                        p_footnote_rate_amt => rates_rec.footnote_rate_amt,
                                                        p_max_per_diem_amt => rates_rec.max_per_diem_amt,
                                                        p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'),
                                                        p_effective_end_date => to_date(rates_rec.effective_end_date, 'MM/DD/RRRR'));

            --
            put_line('Created Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
            --
            g_num_night_rates_created := g_num_night_rates_created + 1;

          end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

        else

          --
          put_line('Standard Rate Id exists: '||l_policy_line_id);
          --

        end if; /* l_policy_line_id is null */


        last_location_id := l_location_id;
        last_rates_rec.no_govt_meals_amt := rates_rec.no_govt_meals_amt;
        last_rates_rec.prop_meals_amt := rates_rec.prop_meals_amt;
        last_rates_rec.off_base_inc_amt := rates_rec.off_base_inc_amt;
        last_rates_rec.max_per_diem_amt := rates_rec.max_per_diem_amt;
        last_rates_rec.effective_date := rates_rec.effective_date;
        last_rates_rec.effective_end_date := rates_rec.effective_end_date;


    else

      --
      put_line('Cannot create Standard Rate for Invalid Location Id: '||l_location_id);
      --
      AddToInvalidLocs(rates_rec.city_locality, rates_rec.county, rates_rec.state_province, rates_rec.country);


    end if; /* l_location_id is not null and l_location_status <> 'INVALID' */

  end loop;
  CLOSE rates_cur;


  if (p_ratetype = 'CONUS') then

    --
    put_line('------------------------------------------------------------');
    --
    --
    put_line('Checking for Undefined CONUS Standard Rate');
    --

    open undefined_conus_rate_cur;

    fetch undefined_conus_rate_cur into undefined_conus_rate_rec;

    if (undefined_conus_rate_cur%notfound) then

      undefined_conus_rate_rec.rate := null;
      if (l_eliminate_seasonality) then
        undefined_conus_rate_rec.start_of_season := null;
        undefined_conus_rate_rec.end_of_season := null;
      end if;

      l_rate := undefined_conus_rate_rec.rate;

      l_schedule_option_id := GetScheduleOption(p_policy_id => l_policy_id,
                                                p_location_id => l_undefined_conus_location_id);

      if (l_schedule_option_id is null) then

        --
        put_line('Create Undefined CONUS Schedule Option');
        --
        l_schedule_option_id := CreateScheduleOption(p_policy_id => l_policy_id,
                                                     p_location_id => l_undefined_conus_location_id);

      else

        --
        put_line('Undefined CONUS Schedule Option exists');
        --
        null;

      end if; /* l_schedule_option_id is null */

      --
      put_line('Create Undefined CONUS Standard Rate');
      --

      l_policy_line_id := CreatePolicyLine(p_policy_id => l_policy_id,
                                           p_schedule_period_id => l_schedule_period_id,
                                           p_role_id => null,
                                           p_location_id => l_undefined_conus_location_id,
                                           p_rate => l_rate,
                                           p_calc_method => null,
                                           p_single_deduction => null,
                                           p_breakfast_deduction => null,
                                           p_lunch_deduction => null,
                                           p_dinner_deduction => null,
                                           p_start_of_season => undefined_conus_rate_rec.start_of_season,
                                           p_end_of_season => undefined_conus_rate_rec.end_of_season,
                                           p_max_lodging_amt => null,
                                           p_no_govt_meals_amt => null,
                                           p_prop_meals_amt => null,
                                           p_off_base_inc_amt => null,
                                           p_footnote_amt => null,
                                           p_footnote_rate_amt => null,
                                           p_max_per_diem_amt => null,
                                           p_effective_start_date => p_period_start_date,
                                           p_effective_end_date => null,
                                           p_use_free_acc_add => p_use_free_acc_add,
                                           p_use_free_acc_ded => p_use_free_acc_ded);

      --
      put_line('Created Undefined CONUS Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
      --
      g_num_std_rates_created := g_num_std_rates_created + 1;

      if (nvl(p_use_free_acc_add, 'N') = 'Y') then

        l_night_rate_line_id := CreateNightRateLine(p_policy_id => l_policy_id,
                                                    p_schedule_period_id => l_schedule_period_id,
                                                    p_role_id => null,
                                                    p_location_id => l_undefined_conus_location_id,
                                                    p_rate => null,
                                                    p_single_deduction => null,
                                                    p_breakfast_deduction => null,
                                                    p_lunch_deduction => null,
                                                    p_dinner_deduction => null,
                                                    p_start_of_season => '01/01',
                                                    p_end_of_season => '12/31',
                                                    p_max_lodging_amt => null,
                                                    p_no_govt_meals_amt => null,
                                                    p_prop_meals_amt => null,
                                                    p_off_base_inc_amt => null,
                                                    p_footnote_amt => null,
                                                    p_footnote_rate_amt => null,
                                                    p_max_per_diem_amt => null,
                                                    p_effective_start_date => p_period_start_date,
                                                    p_effective_end_date => null);

        --
        put_line('Created Undefined CONUS Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
        --
        g_num_night_rates_created := g_num_night_rates_created + 1;

      end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

    else
      l_rate := undefined_conus_rate_rec.rate;
      --
      put_line('Got Undefined CONUS Standard Rate with rate: '||l_rate);
      --
    end if;

    close undefined_conus_rate_cur;

  end if;

    --
    put_line('------------------------------------------------------------');
    --
    --
    put_line('Always check for Undefined Location Standard Rate');
    --

    open undefined_loc_rate_cur;

    fetch undefined_loc_rate_cur into undefined_loc_rate_rec;

    if (undefined_loc_rate_cur%notfound) then

      undefined_loc_rate_rec.rate := null;
      if (l_eliminate_seasonality) then
        undefined_loc_rate_rec.start_of_season := null;
        undefined_loc_rate_rec.end_of_season := null;
      end if;

      l_rate := undefined_loc_rate_rec.rate;

      l_schedule_option_id := GetScheduleOption(p_policy_id => l_policy_id,
                                                p_location_id => l_undefined_location_id);

      if (l_schedule_option_id is null) then

        --
        put_line('Create Undefined Location Schedule Option');
        --
        l_schedule_option_id := CreateScheduleOption(p_policy_id => l_policy_id,
                                                     p_location_id => l_undefined_location_id);

      else

        --
        put_line('Undefined Location Schedule Option exists');
        --
        null;

      end if; /* l_schedule_option_id is null */

      --
      put_line('Create Undefined Location Standard Rate');
      --

      l_policy_line_id := CreatePolicyLine(p_policy_id => l_policy_id,
                                           p_schedule_period_id => l_schedule_period_id,
                                           p_role_id => null,
                                           p_location_id => l_undefined_location_id,
                                           p_rate => l_rate,
                                           p_calc_method => null,
                                           p_single_deduction => null,
                                           p_breakfast_deduction => null,
                                           p_lunch_deduction => null,
                                           p_dinner_deduction => null,
                                           p_start_of_season => undefined_loc_rate_rec.start_of_season,
                                           p_end_of_season => undefined_loc_rate_rec.end_of_season,
                                           p_max_lodging_amt => null,
                                           p_no_govt_meals_amt => null,
                                           p_prop_meals_amt => null,
                                           p_off_base_inc_amt => null,
                                           p_footnote_amt => null,
                                           p_footnote_rate_amt => null,
                                           p_max_per_diem_amt => null,
                                           p_effective_start_date => p_period_start_date,
                                           p_effective_end_date => null,
                                           p_use_free_acc_add => p_use_free_acc_add,
                                           p_use_free_acc_ded => p_use_free_acc_ded);

      --
      put_line('Created Undefined Location Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
      --
      g_num_std_rates_created := g_num_std_rates_created + 1;

      if (nvl(p_use_free_acc_add, 'N') = 'Y') then

        l_night_rate_line_id := CreateNightRateLine(p_policy_id => l_policy_id,
                                                    p_schedule_period_id => l_schedule_period_id,
                                                    p_role_id => null,
                                                    p_location_id => l_undefined_location_id,
                                                    p_rate => null,
                                                    p_single_deduction => null,
                                                    p_breakfast_deduction => null,
                                                    p_lunch_deduction => null,
                                                    p_dinner_deduction => null,
                                                    p_start_of_season => '01/01',
                                                    p_end_of_season => '12/31',
                                                    p_max_lodging_amt => null,
                                                    p_no_govt_meals_amt => null,
                                                    p_prop_meals_amt => null,
                                                    p_off_base_inc_amt => null,
                                                    p_footnote_amt => null,
                                                    p_footnote_rate_amt => null,
                                                    p_max_per_diem_amt => null,
                                                    p_effective_start_date => p_period_start_date,
                                                    p_effective_end_date => null);

        --
        put_line('Created Undefined Location Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
        --
        g_num_night_rates_created := g_num_night_rates_created + 1;

      end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

    else
      l_rate := undefined_loc_rate_rec.rate;
      --
      put_line('Got Undefined Location Standard Rate with rate: '||l_rate);
      --
    end if;

    close undefined_loc_rate_cur;


  --
  put_line('------------------------------------------------------------');
  --
  --
  put_line('Always check for Gap Standard Rate');
  --
  OPEN  rates_gap_cur;
  loop

  FETCH rates_gap_cur INTO rates_gap_rec;
  EXIT WHEN rates_gap_cur%NOTFOUND;

    if (l_eliminate_seasonality) then
      rates_gap_rec.start_of_season := null;
      rates_gap_rec.end_of_season := null;
    end if;

    --
    put_line('Create Gap Standard Rate');
    --

    l_policy_line_id := CreatePolicyLine(p_policy_id => l_policy_id,
                                         p_schedule_period_id => l_schedule_period_id,
                                         p_role_id => null,
                                         p_location_id => rates_gap_rec.location_id,
                                         p_rate => l_rate,
                                         p_calc_method => null,
                                         p_single_deduction => null,
                                         p_breakfast_deduction => null,
                                         p_lunch_deduction => null,
                                         p_dinner_deduction => null,
                                         p_start_of_season => rates_gap_rec.start_of_season,
                                         p_end_of_season => rates_gap_rec.end_of_season,
                                         p_max_lodging_amt => null,
                                         p_no_govt_meals_amt => null,
                                         p_prop_meals_amt => null,
                                         p_off_base_inc_amt => null,
                                         p_footnote_amt => null,
                                         p_footnote_rate_amt => null,
                                         p_max_per_diem_amt => null,
                                         p_effective_start_date => p_period_start_date,
                                         p_effective_end_date => rates_gap_rec.effective_start_date - 1,
                                         p_use_free_acc_add => p_use_free_acc_add,
                                         p_use_free_acc_ded => p_use_free_acc_ded);

    --
    put_line('Created Gap Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
    --
    g_num_std_rates_created := g_num_std_rates_created + 1;

    if (nvl(p_use_free_acc_add, 'N') = 'Y') then

      l_night_rate_line_id := CreateNightRateLine(p_policy_id => l_policy_id,
                                                  p_schedule_period_id => l_schedule_period_id,
                                                  p_role_id => null,
                                                  p_location_id => rates_gap_rec.location_id,
                                                  p_rate => null,
                                                  p_single_deduction => null,
                                                  p_breakfast_deduction => null,
                                                  p_lunch_deduction => null,
                                                  p_dinner_deduction => null,
                                                  p_start_of_season => '01/01',
                                                  p_end_of_season => '12/31',
                                                  p_max_lodging_amt => null,
                                                  p_no_govt_meals_amt => null,
                                                  p_prop_meals_amt => null,
                                                  p_off_base_inc_amt => null,
                                                  p_footnote_amt => null,
                                                  p_footnote_rate_amt => null,
                                                  p_max_per_diem_amt => null,
                                                  p_effective_start_date => p_period_start_date,
                                                  p_effective_end_date => rates_gap_rec.effective_start_date - 1);

      --
      put_line('Created Gap Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
      --
      g_num_night_rates_created := g_num_night_rates_created + 1;

    end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

  end loop;
  CLOSE rates_gap_cur;


  EXCEPTION
    when others then
        raise;


END CreateSchedule;


PROCEDURE UpdateEndDates(
                         p_policy_id            IN NUMBER,
                         p_schedule_period_id   IN NUMBER) IS

BEGIN

  update ap_pol_lines apl1
  set    apl1.effective_end_date =
  (
    select min(apl2.effective_start_date)-1
    from   ap_pol_lines apl2
    where  apl2.policy_id = apl1.policy_id
    and    apl2.schedule_period_id = apl1.schedule_period_id
    and    apl2.policy_line_id <> apl1.policy_line_id
    and    apl2.location_id = apl1.location_id
    and    apl2.effective_start_date > apl1.effective_start_date
  )
  where  policy_id = p_policy_id
  and    schedule_period_id = p_schedule_period_id
  and    apl1.effective_end_date is null
  and
  exists
  (select 'Y'
   from   ap_pol_lines apl3
   where  apl3.policy_id = apl1.policy_id
   and    apl3.schedule_period_id = apl1.schedule_period_id
   and    apl3.policy_line_id <> apl1.policy_line_id
   and    apl3.location_id = apl1.location_id
   and    apl3.effective_start_date > apl1.effective_start_date);


  g_num_std_rates_updated := sql%rowcount;


  EXCEPTION
    when others then
        raise;

END UpdateEndDates;


------------------------------------------------------------------------
PROCEDURE UpdateSchedule(errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_ratetype             IN VARCHAR2,
                         p_expense_category     IN VARCHAR2,
                         p_policy_id            IN NUMBER,
                         p_period_type          IN VARCHAR2,
                         p_period_id            IN VARCHAR2,
                         p_period_name          IN VARCHAR2,
                         p_period_start_date    IN DATE,
                         p_rate_incl_meals      IN VARCHAR2,
                         p_rate_incl_inc        IN VARCHAR2,
                         p_rate_incl_acc        IN VARCHAR2,
                         p_meals_rate           IN VARCHAR2,
                         p_free_meals_ded       IN VARCHAR2,
                         p_use_free_acc_add     IN VARCHAR2,
                         p_use_free_acc_ded     IN VARCHAR2,
                         p_calc_method          IN VARCHAR2,
                         p_single_deduction     IN NUMBER,
                         p_breakfast_deduction  IN NUMBER,
                         p_lunch_deduction      IN NUMBER,
                         p_dinner_deduction     IN NUMBER) IS
------------------------------------------------------------------------

    l_debug_info              VARCHAR2(200);

    l_role_id			NUMBER(15);
    l_location_id		NUMBER(15);
    l_location_status		VARCHAR2(30);
    l_schedule_option_id	NUMBER(15);
    l_schedule_period_id	NUMBER(15);
    l_policy_line_id		NUMBER(15);
    l_night_rate_line_id	NUMBER(15);
    l_night_start_of_season	VARCHAR2(5);
    l_night_end_of_season	VARCHAR2(5);

    l_per_diem_type_code	VARCHAR2(30);
    l_rate			NUMBER;

-------------------------------
-- cursor roles
-------------------------------
cursor roles_cur is
  select role_id
  from   ap_pol_schedule_options
  where  policy_id = p_policy_id
  and    option_type = AP_WEB_POLICY_UTILS.c_EMPLOYEE_ROLE
  and    role_id is not null;

  roles_rec roles_cur%ROWTYPE;
  one_role_processed boolean;

-------------------------------
-- cursor to check if rates exist
-------------------------------
cursor rates_exist_cur is
  select 'Y' rates_exist
  from   oie_pol_rates_interface
  where
  (
   (p_ratetype = 'CONUS' and country = 'UNITED STATES' and state_province not in ('HAWAII', 'ALASKA'))
  or
   (p_ratetype = 'OCONUS' and (country <> 'UNITED STATES' or state_province in ('HAWAII', 'ALASKA')))
  )
  and    rownum = 1;

  rates_exist_rec rates_exist_cur%ROWTYPE;

-------------------------------
-- cursor for rates
-------------------------------
cursor rates_cur is
  select city_locality,
         county,
         state_province,
         country,
         start_of_season,
         end_of_season,
         max_lodging_amt,
         no_govt_meals_amt,
         prop_meals_amt,
         off_base_inc_amt,
         footnote_amt,
         footnote_rate_amt,
         max_per_diem_amt,
         effective_date,
         '' as effective_end_date
  from   oie_pol_rates_interface
  where
  (
   (p_ratetype = 'CONUS' and country = 'UNITED STATES' and state_province not in ('HAWAII', 'ALASKA'))
  or
   (p_ratetype = 'OCONUS' and (country <> 'UNITED STATES' or state_province in ('HAWAII', 'ALASKA')))
  )
  order by country, state_province, county, city_locality, to_date(effective_date, 'MM/DD/RRRR') desc, start_of_season desc;

  rates_rec rates_cur%ROWTYPE;

  last_location_id NUMBER(15);
  last_rates_rec rates_cur%ROWTYPE;

-------------------------------
-- cursor for gap rates
-------------------------------
cursor rates_gap_cur is
  select l1.role_id, l1.location_id, min(l1.effective_start_date) as effective_start_date,
         '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines l1
  where  l1.policy_id = p_policy_id
  and    not exists
  (select 'Y'
   from   ap_pol_lines l2
   where  l2.policy_id = l1.policy_id
   and    nvl(l2.role_id, -1) = nvl(l1.role_id, -1)
   and    l2.location_id = l1.location_id
   and    l2.effective_start_date = p_period_start_date
   and    rownum = 1
  ) group by l1.role_id, l1.location_id;

  rates_gap_rec rates_gap_cur%ROWTYPE;

  l_eliminate_seasonality boolean := false;

  l_undefined_conus_location_id NUMBER := GetUndefinedCONUS;
  l_undefined_location_id NUMBER := GetUndefinedLocation;

-------------------------------
-- cursor for undefined conus rate
-------------------------------
cursor undefined_conus_rate_cur is
  select rate, '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines
  where  policy_id = p_policy_id
  and    nvl(role_id, -1) = nvl(l_role_id, -1)
  and    location_id = l_undefined_conus_location_id;

  undefined_conus_rate_rec undefined_conus_rate_cur%ROWTYPE;

-------------------------------
-- cursor for undefined location rate
-------------------------------
cursor undefined_loc_rate_cur is
  select rate, '01/01' as start_of_season, '12/31' as end_of_season
  from   ap_pol_lines
  where  policy_id = p_policy_id
  and    nvl(role_id, -1) = nvl(l_role_id, -1)
  and    location_id = l_undefined_location_id;

  undefined_loc_rate_rec undefined_loc_rate_cur%ROWTYPE;


BEGIN

  OPEN  rates_exist_cur;
  FETCH rates_exist_cur INTO rates_exist_rec;
  CLOSE rates_exist_cur;

  if (rates_exist_rec.rates_exist is null) then
    --
    put_line('No rates to process!');
    --
    return;
  end if;

  --
  put_line('------------------------------------------------------------');
  --
  if ('PER_DIEM' = p_expense_category) then
    --
    put_line('GetPerDiemTypeCode');
    --
    l_per_diem_type_code := GetPerDiemTypeCode(p_policy_id);
    --
    put_line('Per Diem Type Code: '||l_per_diem_type_code);
    --
  end if;

  if ('NEW' = p_period_type) then

    --
    put_line('End date current open Schedule Period');
    --
    update ap_pol_schedule_periods
    set    end_date = p_period_start_date - 1
    where  policy_id = p_policy_id
    and    end_date is null;

    --
    put_line('Create Schedule Period');
    --
    l_schedule_period_id := CreateSchedulePeriod(p_policy_id => p_policy_id,
                                                 p_period_name => p_period_name,
                                                 p_period_start_date => p_period_start_date);
    --
    put_line('Created Schedule Period Id: '||l_schedule_period_id);
    --

  else

    l_schedule_period_id := p_period_id;
    --
    put_line('Update Schedule Period: '||l_schedule_period_id);
    --

  end if; /* 'NEW' = p_period_type */


  /* Eliminate seasonality when schedule
     -  contains only meals or meals and incidental rates
     -  doesn't contain Accommodations
  */
  if ('MEALS' = p_expense_category or
      ('PER_DIEM' = p_expense_category and not (instrb(l_per_diem_type_code,'A') > 0))
     ) then

    --
    put_line('Eliminating seasonality');
    --
    l_eliminate_seasonality := true;

  end if; /* Schedule contains only meals or meals and incidental rates */


  -- Bug: 6997580, Seasonality for OCONUS meals.
  if('PER_DIEM' = p_expense_category and (p_ratetype = 'OCONUS' and instrb(l_per_diem_type_code,'M') > 0)
      and l_eliminate_seasonality = true) THEN
      l_eliminate_seasonality := false;
      put_line('Reset Eliminate seasonality for OCONUS PerDiem Meals');
  end if;


  OPEN  rates_cur;
  loop

  FETCH rates_cur INTO rates_rec;
  EXIT WHEN rates_cur%NOTFOUND;

    g_num_recs_processed := g_num_recs_processed + 1;

    --
    put_line('------------------------------------------------------------');
    --
    l_location_id := GetCityLocation(p_city_locality => rates_rec.city_locality,
                                     p_county => rates_rec.county,
                                     p_state_province => rates_rec.state_province,
                                     p_country => rates_rec.country);

    l_location_status := get_location_status(p_location_id => l_location_id);

        --
        put_line('Location Id : '||l_location_id);
        put_line('Location Status : '||l_location_status);

        put_line('City Locality : '||rates_rec.city_locality);
        put_line('County : '||rates_rec.county);
        put_line('State Province : '||rates_rec.state_province);
        put_line('Country : '||rates_rec.country);
        put_line('Start of Season : '||rates_rec.start_of_season);
        put_line('End of Season : '||rates_rec.end_of_season);
        put_line('Max Lodging Amt : '||rates_rec.max_lodging_amt);
        put_line('No Govt Meals Amt : '||rates_rec.no_govt_meals_amt);
        put_line('Prop Meals Amt : '||rates_rec.prop_meals_amt);
        put_line('Off Base Inc Amt : '||rates_rec.off_base_inc_amt);
        put_line('Footnote Amt : '||rates_rec.footnote_amt);
        put_line('Footnote Rate Amt : '||rates_rec.footnote_rate_amt);
        put_line('Max Per Diem Amt : '||rates_rec.max_per_diem_amt);
        put_line('Effective Date : '||rates_rec.effective_date);
        --


    if (nvl(rates_rec.max_lodging_amt, 0) = 0 and
        nvl(rates_rec.no_govt_meals_amt, 0) = 0 and
        nvl(rates_rec.prop_meals_amt, 0) = 0 and
        nvl(rates_rec.max_per_diem_amt, 0) = 0) then

      put_line('Note: this is a zero rate location');
      AddToZeroRates(rates_rec.city_locality, rates_rec.county, rates_rec.state_province, rates_rec.country);

    end if;

    if (l_location_id is not null and l_location_status <> 'INVALID') then

        if (p_period_start_date <= to_date(rates_rec.effective_date, 'MM/DD/RRRR')) then

          --
          put_line('Leaving Effective Start Date as is');
          --
          null;

        elsif (p_period_start_date > to_date(rates_rec.effective_date, 'MM/DD/RRRR')) then

          --
          put_line('Setting Effective Start Date to Period Start Date');
          --
          rates_rec.effective_date := to_char(p_period_start_date, 'MM/DD/RRRR');

        end if; /* */

        if (last_location_id = l_location_id) then

          if (last_rates_rec.effective_date <> rates_rec.effective_date) then

            --
            put_line('Setting Effective End Date to Last Effective Start Date - 1');
            --
            rates_rec.effective_end_date := to_char(to_date(last_rates_rec.effective_date, 'MM/DD/RRRR') - 1, 'MM/DD/RRRR');

          else

            --
            put_line('Setting Effective End Date to Last Effective End Date');
            --
            rates_rec.effective_end_date := last_rates_rec.effective_end_date;

          end if;

        end if; /* (last_location_id = l_location_id) */

        l_schedule_option_id := GetScheduleOption(p_policy_id => p_policy_id,
                                                  p_location_id => l_location_id);

        if (l_schedule_option_id is null) then

          --
          put_line('Create Schedule Option');
          --
          l_schedule_option_id := CreateScheduleOption(p_policy_id => p_policy_id,
                                                       p_location_id => l_location_id);

        else

          --
          put_line('Schedule Option exists');
          --
          null;

        end if; /* l_schedule_option_id is null */

        --
        put_line('Schedule Option: '||l_schedule_option_id);
        --

        l_night_start_of_season := rates_rec.start_of_season;
        l_night_end_of_season := rates_rec.end_of_season;
        if (l_eliminate_seasonality) then
          rates_rec.start_of_season := null;
          rates_rec.end_of_season := null;
        end if;

        l_rate := CalculateRate(p_expense_category => p_expense_category,
                                p_rate_incl_meals => p_rate_incl_meals,
                                p_rate_incl_inc => p_rate_incl_inc,
                                p_rate_incl_acc => p_rate_incl_acc,
                                p_meals_rate => p_meals_rate,
                                p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                p_prop_meals_amt => rates_rec.prop_meals_amt,
                                p_max_lodging_amt => rates_rec.max_lodging_amt,
                                p_max_per_diem_amt => rates_rec.max_per_diem_amt);


        --
        put_line('Process Roles');
        --
        one_role_processed := false;
        OPEN  roles_cur;
        loop

        FETCH roles_cur INTO roles_rec;
        if (roles_cur%NOTFOUND) then
          if (one_role_processed) then
            exit;
          else
            l_role_id := null;
          end if;
        else
          l_role_id := roles_rec.role_id;
        end if;
        one_role_processed := true;
        --
        put_line('Role Id: '||l_role_id);
        --


        l_policy_line_id := GetPolicyLine(p_policy_id => p_policy_id,
                                          p_schedule_period_id => l_schedule_period_id,
                                          p_role_id => l_role_id,
                                          p_location_id => l_location_id,
                                          p_start_of_season => rates_rec.start_of_season,
                                          p_end_of_season => rates_rec.end_of_season,
                                          p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'));


        if (l_policy_line_id is null) then

          --
          put_line('Create Standard Rate');
          --

          l_policy_line_id := CreatePolicyLine(p_policy_id => p_policy_id,
                                               p_schedule_period_id => l_schedule_period_id,
                                               p_role_id => l_role_id,
                                               p_location_id => l_location_id,
                                               p_rate => l_rate,
                                               p_calc_method => p_calc_method,
                                               p_single_deduction => p_single_deduction,
                                               p_breakfast_deduction => p_breakfast_deduction,
                                               p_lunch_deduction => p_lunch_deduction,
                                               p_dinner_deduction => p_dinner_deduction,
                                               p_start_of_season => rates_rec.start_of_season,
                                               p_end_of_season => rates_rec.end_of_season,
                                               p_max_lodging_amt => rates_rec.max_lodging_amt,
                                               p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                               p_prop_meals_amt => rates_rec.prop_meals_amt,
                                               p_off_base_inc_amt => rates_rec.off_base_inc_amt,
                                               p_footnote_amt => rates_rec.footnote_amt,
                                               p_footnote_rate_amt => rates_rec.footnote_rate_amt,
                                               p_max_per_diem_amt => rates_rec.max_per_diem_amt,
                                               p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'),
                                               p_effective_end_date => to_date(rates_rec.effective_end_date, 'MM/DD/RRRR'),
                                               p_use_free_acc_add => p_use_free_acc_add,
                                               p_use_free_acc_ded => p_use_free_acc_ded);

          --
          put_line('Created Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
          --
          g_num_std_rates_created := g_num_std_rates_created + 1;

          if (nvl(p_use_free_acc_add, 'N') = 'Y') then

            l_night_rate_line_id := CreateNightRateLine(p_policy_id => p_policy_id,
                                                        p_schedule_period_id => l_schedule_period_id,
                                                        p_role_id => l_role_id,
                                                        p_location_id => l_location_id,
                                                        p_rate => rates_rec.max_lodging_amt,
                                                        p_single_deduction => p_single_deduction,
                                                        p_breakfast_deduction => p_breakfast_deduction,
                                                        p_lunch_deduction => p_lunch_deduction,
                                                        p_dinner_deduction => p_dinner_deduction,
                                                        p_start_of_season => l_night_start_of_season,
                                                        p_end_of_season => l_night_end_of_season,
                                                        p_max_lodging_amt => rates_rec.max_lodging_amt,
                                                        p_no_govt_meals_amt => rates_rec.no_govt_meals_amt,
                                                        p_prop_meals_amt => rates_rec.prop_meals_amt,
                                                        p_off_base_inc_amt => rates_rec.off_base_inc_amt,
                                                        p_footnote_amt => rates_rec.footnote_amt,
                                                        p_footnote_rate_amt => rates_rec.footnote_rate_amt,
                                                        p_max_per_diem_amt => rates_rec.max_per_diem_amt,
                                                        p_effective_start_date => to_date(rates_rec.effective_date, 'MM/DD/RRRR'),
                                                        p_effective_end_date => to_date(rates_rec.effective_end_date, 'MM/DD/RRRR'));

            --
            put_line('Created Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
            --
            g_num_night_rates_created := g_num_night_rates_created + 1;

          end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

        else

          --
          put_line('Standard Rate Id exists: '||l_policy_line_id);
          --

        end if; /* l_policy_line_id is null */

        end loop;
        CLOSE roles_cur;

        last_location_id := l_location_id;
        last_rates_rec.no_govt_meals_amt := rates_rec.no_govt_meals_amt;
        last_rates_rec.prop_meals_amt := rates_rec.prop_meals_amt;
        last_rates_rec.off_base_inc_amt := rates_rec.off_base_inc_amt;
        last_rates_rec.max_per_diem_amt := rates_rec.max_per_diem_amt;
        last_rates_rec.effective_date := rates_rec.effective_date;
        last_rates_rec.effective_end_date := rates_rec.effective_end_date;


    else

      --
      put_line('Cannot create Standard Rate for Invalid Location Id: '||l_location_id);
      --
      AddToInvalidLocs(rates_rec.city_locality, rates_rec.county, rates_rec.state_province, rates_rec.country);

    end if; /* l_location_id is not null and l_location_status <> 'INVALID' */

  end loop;
  CLOSE rates_cur;




  if (p_ratetype = 'CONUS') then

    --
    put_line('------------------------------------------------------------');
    --
    --
    put_line('Checking for Undefined CONUS Standard Rate');
    --

    --
    put_line('Process Roles');
    --
    one_role_processed := false;
    OPEN  roles_cur;
    loop

    FETCH roles_cur INTO roles_rec;
    if (roles_cur%NOTFOUND) then
      if (one_role_processed) then
        exit;
      else
        l_role_id := null;
      end if;
    else
      l_role_id := roles_rec.role_id;
    end if;
    one_role_processed := true;
    --
    put_line('Role Id: '||l_role_id);
    --

    open undefined_conus_rate_cur;

    fetch undefined_conus_rate_cur into undefined_conus_rate_rec;

    if (undefined_conus_rate_cur%notfound) then

      undefined_conus_rate_rec.rate := null;
      if (l_eliminate_seasonality) then
        undefined_conus_rate_rec.start_of_season := null;
        undefined_conus_rate_rec.end_of_season := null;
      end if;

      l_rate := undefined_conus_rate_rec.rate;

      l_schedule_option_id := GetScheduleOption(p_policy_id => p_policy_id,
                                                p_location_id => l_undefined_conus_location_id);

      if (l_schedule_option_id is null) then

        --
        put_line('Create Undefined CONUS Schedule Option');
        --
        l_schedule_option_id := CreateScheduleOption(p_policy_id => p_policy_id,
                                                     p_location_id => l_undefined_conus_location_id);

      else

        --
        put_line('Undefined CONUS Schedule Option exists');
        --
        null;

      end if; /* l_schedule_option_id is null */

      --
      put_line('Create Undefined CONUS Standard Rate');
      --

      l_policy_line_id := CreatePolicyLine(p_policy_id => p_policy_id,
                                           p_schedule_period_id => l_schedule_period_id,
                                           p_role_id => l_role_id,
                                           p_location_id => l_undefined_conus_location_id,
                                           p_rate => l_rate,
                                           p_calc_method => null,
                                           p_single_deduction => null,
                                           p_breakfast_deduction => null,
                                           p_lunch_deduction => null,
                                           p_dinner_deduction => null,
                                           p_start_of_season => undefined_conus_rate_rec.start_of_season,
                                           p_end_of_season => undefined_conus_rate_rec.end_of_season,
                                           p_max_lodging_amt => null,
                                           p_no_govt_meals_amt => null,
                                           p_prop_meals_amt => null,
                                           p_off_base_inc_amt => null,
                                           p_footnote_amt => null,
                                           p_footnote_rate_amt => null,
                                           p_max_per_diem_amt => null,
                                           p_effective_start_date => p_period_start_date,
                                           p_effective_end_date => null,
                                           p_use_free_acc_add => p_use_free_acc_add,
                                           p_use_free_acc_ded => p_use_free_acc_ded);

      --
      put_line('Created Undefined CONUS Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
      --
      g_num_std_rates_created := g_num_std_rates_created + 1;

      if (nvl(p_use_free_acc_add, 'N') = 'Y') then

        l_night_rate_line_id := CreateNightRateLine(p_policy_id => p_policy_id,
                                                    p_schedule_period_id => l_schedule_period_id,
                                                    p_role_id => l_role_id,
                                                    p_location_id => l_undefined_conus_location_id,
                                                    p_rate => null,
                                                    p_single_deduction => null,
                                                    p_breakfast_deduction => null,
                                                    p_lunch_deduction => null,
                                                    p_dinner_deduction => null,
                                                    p_start_of_season => '01/01',
                                                    p_end_of_season => '12/31',
                                                    p_max_lodging_amt => null,
                                                    p_no_govt_meals_amt => null,
                                                    p_prop_meals_amt => null,
                                                    p_off_base_inc_amt => null,
                                                    p_footnote_amt => null,
                                                    p_footnote_rate_amt => null,
                                                    p_max_per_diem_amt => null,
                                                    p_effective_start_date => p_period_start_date,
                                                    p_effective_end_date => null);

        --
        put_line('Created Undefined CONUS Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
        --
        g_num_night_rates_created := g_num_night_rates_created + 1;

      end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

    else
      l_rate := undefined_conus_rate_rec.rate;
      --
      put_line('Got Undefined CONUS Standard Rate with rate: '||l_rate);
      --
    end if; /* undefined_conus_rate_cur%notfound */

    close undefined_conus_rate_cur;


    end loop;
    CLOSE roles_cur;

  end if; /* p_ratetype = 'CONUS' */


    --
    put_line('------------------------------------------------------------');
    --
    --
    put_line('Always check for Undefined Location Standard Rate');
    --

    --
    put_line('Process Roles');
    --
    one_role_processed := false;
    OPEN  roles_cur;
    loop

    FETCH roles_cur INTO roles_rec;
    if (roles_cur%NOTFOUND) then
      if (one_role_processed) then
        exit;
      else
        l_role_id := null;
      end if;
    else
      l_role_id := roles_rec.role_id;
    end if;
    one_role_processed := true;
    --
    put_line('Role Id: '||l_role_id);
    --

    open undefined_loc_rate_cur;

    fetch undefined_loc_rate_cur into undefined_loc_rate_rec;

    if (undefined_loc_rate_cur%notfound) then

      undefined_loc_rate_rec.rate := null;
      if (l_eliminate_seasonality) then
        undefined_loc_rate_rec.start_of_season := null;
        undefined_loc_rate_rec.end_of_season := null;
      end if;

      l_rate := undefined_loc_rate_rec.rate;

      l_schedule_option_id := GetScheduleOption(p_policy_id => p_policy_id,
                                                p_location_id => l_undefined_location_id);

      if (l_schedule_option_id is null) then

        --
        put_line('Create Undefined Location Schedule Option');
        --
        l_schedule_option_id := CreateScheduleOption(p_policy_id => p_policy_id,
                                                     p_location_id => l_undefined_location_id);

      else

        --
        put_line('Undefined Location Schedule Option exists');
        --
        null;

      end if; /* l_schedule_option_id is null */

      --
      put_line('Create Undefined Location Standard Rate');
      --

      l_policy_line_id := CreatePolicyLine(p_policy_id => p_policy_id,
                                           p_schedule_period_id => l_schedule_period_id,
                                           p_role_id => l_role_id,
                                           p_location_id => l_undefined_location_id,
                                           p_rate => l_rate,
                                           p_calc_method => null,
                                           p_single_deduction => null,
                                           p_breakfast_deduction => null,
                                           p_lunch_deduction => null,
                                           p_dinner_deduction => null,
                                           p_start_of_season => undefined_loc_rate_rec.start_of_season,
                                           p_end_of_season => undefined_loc_rate_rec.end_of_season,
                                           p_max_lodging_amt => null,
                                           p_no_govt_meals_amt => null,
                                           p_prop_meals_amt => null,
                                           p_off_base_inc_amt => null,
                                           p_footnote_amt => null,
                                           p_footnote_rate_amt => null,
                                           p_max_per_diem_amt => null,
                                           p_effective_start_date => p_period_start_date,
                                           p_effective_end_date => null,
                                           p_use_free_acc_add => p_use_free_acc_add,
                                           p_use_free_acc_ded => p_use_free_acc_ded);

      --
      put_line('Created Undefined Location Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
      --
      g_num_std_rates_created := g_num_std_rates_created + 1;

      if (nvl(p_use_free_acc_add, 'N') = 'Y') then

        l_night_rate_line_id := CreateNightRateLine(p_policy_id => p_policy_id,
                                                    p_schedule_period_id => l_schedule_period_id,
                                                    p_role_id => l_role_id,
                                                    p_location_id => l_undefined_location_id,
                                                    p_rate => null,
                                                    p_single_deduction => null,
                                                    p_breakfast_deduction => null,
                                                    p_lunch_deduction => null,
                                                    p_dinner_deduction => null,
                                                    p_start_of_season => '01/01',
                                                    p_end_of_season => '12/31',
                                                    p_max_lodging_amt => null,
                                                    p_no_govt_meals_amt => null,
                                                    p_prop_meals_amt => null,
                                                    p_off_base_inc_amt => null,
                                                    p_footnote_amt => null,
                                                    p_footnote_rate_amt => null,
                                                    p_max_per_diem_amt => null,
                                                    p_effective_start_date => p_period_start_date,
                                                    p_effective_end_date => null);

        --
        put_line('Created Undefined Location Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
        --
        g_num_night_rates_created := g_num_night_rates_created + 1;

      end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

    else
      l_rate := undefined_loc_rate_rec.rate;
      --
      put_line('Got Undefined Location Standard Rate with rate: '||l_rate);
      --
    end if; /* undefined_loc_rate_cur%notfound */

    close undefined_loc_rate_cur;


    end loop;
    CLOSE roles_cur;


  --
  put_line('------------------------------------------------------------');
  --
  --
  put_line('Always check for Gap Standard Rate');
  --
  --
  put_line('Process Roles');
  --
  one_role_processed := false;
  OPEN  roles_cur;
  loop

  FETCH roles_cur INTO roles_rec;
  if (roles_cur%NOTFOUND) then
    if (one_role_processed) then
      exit;
    else
      l_role_id := null;
    end if;
  else
    l_role_id := roles_rec.role_id;
  end if;
  one_role_processed := true;
  --
  put_line('Role Id: '||l_role_id);
  --

  OPEN  rates_gap_cur;
  loop

  FETCH rates_gap_cur INTO rates_gap_rec;
  EXIT WHEN rates_gap_cur%NOTFOUND;

    if (l_eliminate_seasonality) then
      rates_gap_rec.start_of_season := null;
      rates_gap_rec.end_of_season := null;
    end if;

    --
    put_line('Create Gap Standard Rate');
    --

    l_policy_line_id := CreatePolicyLine(p_policy_id => p_policy_id,
                                         p_schedule_period_id => l_schedule_period_id,
                                         p_role_id => rates_gap_rec.role_id,
                                         p_location_id => rates_gap_rec.location_id,
                                         p_rate => l_rate,
                                         p_calc_method => null,
                                         p_single_deduction => null,
                                         p_breakfast_deduction => null,
                                         p_lunch_deduction => null,
                                         p_dinner_deduction => null,
                                         p_start_of_season => rates_gap_rec.start_of_season,
                                         p_end_of_season => rates_gap_rec.end_of_season,
                                         p_max_lodging_amt => null,
                                         p_no_govt_meals_amt => null,
                                         p_prop_meals_amt => null,
                                         p_off_base_inc_amt => null,
                                         p_footnote_amt => null,
                                         p_footnote_rate_amt => null,
                                         p_max_per_diem_amt => null,
                                         p_effective_start_date => p_period_start_date,
                                         p_effective_end_date => rates_gap_rec.effective_start_date - 1,
                                         p_use_free_acc_add => p_use_free_acc_add,
                                         p_use_free_acc_ded => p_use_free_acc_ded);

    --
    put_line('Created Gap Standard Rate Id: '||l_policy_line_id||' with rate: '||l_rate);
    --
    g_num_std_rates_created := g_num_std_rates_created + 1;

    if (nvl(p_use_free_acc_add, 'N') = 'Y') then

      l_night_rate_line_id := CreateNightRateLine(p_policy_id => p_policy_id,
                                                  p_schedule_period_id => l_schedule_period_id,
                                                  p_role_id => rates_gap_rec.role_id,
                                                  p_location_id => rates_gap_rec.location_id,
                                                  p_rate => null,
                                                  p_single_deduction => null,
                                                  p_breakfast_deduction => null,
                                                  p_lunch_deduction => null,
                                                  p_dinner_deduction => null,
                                                  p_start_of_season => '01/01',
                                                  p_end_of_season => '12/31',
                                                  p_max_lodging_amt => null,
                                                  p_no_govt_meals_amt => null,
                                                  p_prop_meals_amt => null,
                                                  p_off_base_inc_amt => null,
                                                  p_footnote_amt => null,
                                                  p_footnote_rate_amt => null,
                                                  p_max_per_diem_amt => null,
                                                  p_effective_start_date => p_period_start_date,
                                                  p_effective_end_date => rates_gap_rec.effective_start_date - 1);

      --
      put_line('Created Gap Night Rate Id: '||l_night_rate_line_id||' with rate: '||l_rate);
      --
      g_num_night_rates_created := g_num_night_rates_created + 1;

    end if; /* nvl(p_use_free_acc_add, 'N') = 'Y' */

  end loop;
  CLOSE rates_gap_cur;


  end loop;
  CLOSE roles_cur;

  --
  put_line('------------------------------------------------------------');
  --
  --
  put_line('Update End Dates');
  --
  UpdateEndDates(p_policy_id => p_policy_id,
                 p_schedule_period_id => l_schedule_period_id);


  EXCEPTION
    when others then
        raise;


END UpdateSchedule;


------------------------------------------------------------------------
PROCEDURE UploadRates(errbuf                 OUT NOCOPY VARCHAR2,
                      retcode                OUT NOCOPY NUMBER,
                      p_ratetype             IN VARCHAR2,
                      p_action               IN VARCHAR2,
                      p_source               IN VARCHAR2,
                      p_datafile             IN VARCHAR2,
                      p_expense_category     IN VARCHAR2,
                      p_policy_id            IN NUMBER,
                      p_policy_name          IN VARCHAR2,
                      p_policy_start_date    IN VARCHAR2,
                      p_period_type          IN VARCHAR2,
                      p_period_id            IN NUMBER,
                      p_period_name          IN VARCHAR2,
                      p_period_start_date    IN VARCHAR2,
                      p_rate_incl_meals      IN VARCHAR2,
                      p_rate_incl_inc        IN VARCHAR2,
                      p_rate_incl_acc        IN VARCHAR2,
                      p_meals_rate           IN VARCHAR2,
                      p_free_meals_ded       IN VARCHAR2,
                      p_use_free_acc_add     IN VARCHAR2,
                      p_use_free_acc_ded     IN VARCHAR2,
                      p_calc_method          IN VARCHAR2,
                      p_single_deduction     IN NUMBER,
                      p_breakfast_deduction  IN NUMBER,
                      p_lunch_deduction      IN NUMBER,
                      p_dinner_deduction     IN NUMBER) IS
------------------------------------------------------------------------

    l_debug_info              VARCHAR2(200);
    l_request_id              NUMBER;
    l_request_status          VARCHAR2(30);
    l_policy_start_date       DATE;
    l_period_start_date       DATE;
    i                         NUMBER;

BEGIN

  --g_debug_switch      := p_debug_switch;
  g_debug_switch      := 'Y';
  g_last_updated_by   := to_number(FND_GLOBAL.USER_ID);
  g_last_update_login := to_number(FND_GLOBAL.LOGIN_ID);
  g_invalid_locs      := Invalid_Locs('');
  g_zero_rates        := Zero_Rates('');


  l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

  IF g_debug_switch = 'Y' THEN
    --
    put_line('------------------------------------------------------------');
    put_line('--           P  A  R  A  M  E  T  E  R  S                 --');
    put_line('------------------------------------------------------------');
    --
    put_line('Debug = ' || g_debug_switch);
    put_line('Last Updated By = ' || g_last_updated_by);
    put_line('Last Update Login = ' || g_last_update_login);
    put_line('Request Id = ' || l_request_id);
    --
    put_line('Rate Type = ' || p_ratetype);
    put_line('Action = ' || p_action);
    put_line('Source = ' || p_source);
    put_line('Data File = ' || p_datafile);
    --
    put_line('Expense Category = ' || p_expense_category);
    put_line('Policy Id = ' || p_policy_id);
    put_line('Policy Name = ' || p_policy_name);
    l_policy_start_date := fnd_date.canonical_to_date(p_policy_start_date);
    put_line('Policy Start Date = ' || l_policy_start_date);
    put_line('Period Type = ' || p_period_type);
    put_line('Period Id = ' || p_period_id);
    put_line('Period Name = ' || p_period_name);
    if ('CREATE' = p_action) then
      l_period_start_date := l_policy_start_date;
    else
      l_period_start_date := fnd_date.canonical_to_date(p_period_start_date);
    end if;
    put_line('Period Start Date = ' || l_period_start_date);
    --
    put_line('Rate Includes Meals = ' || p_rate_incl_meals);
    put_line('Rate Includes Incidentals = ' || p_rate_incl_inc);
    put_line('Rate Includes Accommodations = ' || p_rate_incl_acc);
    put_line('Meals Rate = ' || p_meals_rate);
    put_line('Free Meals Deduction = ' || p_free_meals_ded);
    put_line('Use Free Accommodations Addition = ' || p_use_free_acc_add);
    put_line('Use Free Accommodations Deduction = ' || p_use_free_acc_ded);
    put_line('Calculation Method = ' || p_calc_method);
    put_line('Single Deduction = ' || p_single_deduction);
    put_line('Breakfast Deduction = ' || p_breakfast_deduction);
    put_line('Lunch Deduction = ' || p_lunch_deduction);
    put_line('Dinner Deduction = ' || p_dinner_deduction);
    --
  END IF;

  put_line('------------------------------------------------------------');
  put_line('--                     B E G I N                          --');
  put_line('------------------------------------------------------------');
  CleanRatesInterface(p_ratetype => p_ratetype);

  if ('CONUS' = p_ratetype and
      'FILE' = p_source and p_datafile is not null) then
    UploadCONUS(errbuf, retcode, p_datafile, l_request_status);
  elsif ('OCONUS' = p_ratetype and
      'FILE' = p_source and p_datafile is not null) then
    UploadOCONUS(errbuf, retcode, p_datafile, l_request_status);
  end if;

  if ('UPLOAD' = p_action) then

    null;

  elsif ('CREATE' = p_action) then

    if (nvl(retcode, 0) <> 2 and nvl(l_request_status, 'SUCCESS') = 'SUCCESS') then
      CreateSchedule(errbuf,
                     retcode,
                     p_ratetype,
                     p_expense_category,
                     p_policy_name,
                     l_policy_start_date,
                     p_period_name,
                     l_period_start_date,
                     p_rate_incl_meals,
                     p_rate_incl_inc,
                     p_rate_incl_acc,
                     p_meals_rate,
                     p_free_meals_ded,
                     p_use_free_acc_add,
                     p_use_free_acc_ded,
                     p_calc_method,
                     p_single_deduction,
                     p_breakfast_deduction,
                     p_lunch_deduction,
                     p_dinner_deduction);
    end if;

  elsif ('UPDATE' = p_action) then

    if (nvl(retcode, 0) <> 2 and nvl(l_request_status, 'SUCCESS') = 'SUCCESS') then
      UpdateSchedule(errbuf,
                     retcode,
                     p_ratetype,
                     p_expense_category,
                     p_policy_id,
                     p_period_type,
                     p_period_id,
                     p_period_name,
                     l_period_start_date,
                     p_rate_incl_meals,
                     p_rate_incl_inc,
                     p_rate_incl_acc,
                     p_meals_rate,
                     p_free_meals_ded,
                     p_use_free_acc_add,
                     p_use_free_acc_ded,
                     p_calc_method,
                     p_single_deduction,
                     p_breakfast_deduction,
                     p_lunch_deduction,
                     p_dinner_deduction);

    end if;

  end if;

  CleanRatesInterface(p_ratetype => p_ratetype);
  --
  put_line('------------------------------------------------------------');
  put_line('--                      E N D                             --');
  put_line('------------------------------------------------------------');
  put_line('------------------------------------------------------------');
  put_line('--            U P L O A D   S U M M A R Y                 --');
  put_line('------------------------------------------------------------');
  put_line('Total number of records in the file = ' || g_num_recs_processed);
  put_line('Total number of Locations created  = ' || g_num_locs_created );
  put_line('Total number of Standard Rates created = ' || g_num_std_rates_created);
  put_line('Total number of Standard Rates updated = ' || g_num_std_rates_updated);
  put_line('Total number of Night Rates created = ' || g_num_night_rates_created);
  --
  if (g_num_locs_invalid > 0) then
    put_line('------------------------------------------------------------');
    put_line('--        I N V A L I D   L O C A T I O N S              --');
    put_line('------------------------------------------------------------');
    put_line('Total number of Invalid Locations = ' || g_num_locs_invalid);
    for i in 1..g_num_locs_invalid
    loop
      put_line(g_invalid_locs(i));
    end loop;
  end if;
  --
  if (g_num_locs_zero_rates > 0) then
    put_line('------------------------------------------------------------');
    put_line('--       Z E R O   R A T E   L O C A T I O N S            --');
    put_line('------------------------------------------------------------');
    put_line('Total number of Zero Rate Locations = ' || g_num_locs_zero_rates);
    for i in 1..g_num_locs_zero_rates
    loop
      put_line(g_zero_rates(i));
    end loop;
  end if;


  EXCEPTION
    WHEN OTHERS THEN
      put_line(sqlerrm);
      rollback;
      raise;

END UploadRates;


PROCEDURE UploadCONUS(errbuf out nocopy varchar2,
                      retcode out nocopy number,
                      p_datafile in varchar2,
                      p_request_status out nocopy varchar2) IS


  l_request_id		number;
  l_result		boolean;
  l_phase		varchar2(240);
  l_status		varchar2(240);
  l_dev_phase		varchar2(240);
  l_dev_status		varchar2(240);
  l_message		varchar2(240);

BEGIN

  --
  put_line('Validating CONUS format');
  --
  ValidateCONUS(errbuf, retcode, p_datafile);
  --
  put_line('errbuf = '||errbuf);
  put_line('retcode = '||retcode);
  --

  if (nvl(retcode, 0) <> 2) then
    --
    put_line('Submitting request to load CONUS');
    --
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                'SQLAP',
                                'APXCONUS',
                                '',
                                '',
                                false,
                                p_datafile);
    commit;

    --
    put_line('Request Id to load CONUS: '||l_request_id);
    --

    if (l_request_id = 0) then
        errbuf := fnd_message.get;
        retcode := 2;

    else

      loop

        --
        put_line('Going to sleep for 30 sec... : '||to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        --
        dbms_lock.sleep(30.01);
        --
        put_line('Awake... : '||to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        --

        l_result := fnd_concurrent.get_request_status(
                                REQUEST_ID => l_request_id,
                                PHASE      => l_phase,
                                STATUS     => l_status,
                                DEV_PHASE  => l_dev_phase,
                                DEV_STATUS => l_dev_status,
                                MESSAGE    => l_message);

        if (l_result) then

           if (l_dev_phase = 'COMPLETE') then

             if (l_dev_status in ('NORMAL','WARNING')) then

               p_request_status := 'SUCCESS';

             else

               p_request_status := 'FAILED';

             end if; /* l_dev_status = 'NORMAL' or l_dev_status = 'WARNING' */

             --
             put_line('Load request status: '||p_request_status);
             --
             exit;

           end if; /* l_dev_phase = 'COMPLETE' */

        end if; /* result */

      end loop;

  /*
    else
      put_line('Wait for Request to load CONUS: '||l_request_id);
      if (FND_CONCURRENT.WAIT_FOR_REQUEST(
                         request_id => l_request_id,
                         interval   => 30,
                         max_wait   => 144000,
                         phase      => l_phase,
                         status     => l_status,
                         dev_phase  => l_dev_phase,
                         dev_status => l_dev_status,
                         message    => l_message)) then
        null;
      end if;

      put_line('l_phase: '||l_phase);
      put_line('l_status: '||l_status);
      put_line('l_dev_phase: '||l_dev_phase);
      put_line('l_dev_status: '||l_dev_status);
      put_line('l_message: '||l_message);
  */

    end if; /* l_request_id = 0 */

  end if; /* nvl(retcode, 0) <> 2 */

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := fnd_message.get;
      retcode := 2;
END UploadCONUS;


PROCEDURE UploadOCONUS(errbuf out nocopy varchar2,
                       retcode out nocopy number,
                       p_datafile in varchar2,
                       p_request_status out nocopy varchar2) IS


  l_request_id		number;
  l_result		boolean;
  l_phase		varchar2(240);
  l_status		varchar2(240);
  l_dev_phase		varchar2(240);
  l_dev_status		varchar2(240);
  l_message		varchar2(240);

BEGIN

  --
  put_line('Validating OCONUS format');
  --
  ValidateOCONUS(errbuf, retcode, p_datafile);
  --
  put_line('errbuf = '||errbuf);
  put_line('retcode = '||retcode);

  if (nvl(retcode, 0) <> 2) then
    --
    put_line('Submitting request to load OCONUS');
    --
    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                'SQLAP',
                                'APXOCONUS',
                                '',
                                '',
                                false,
                                p_datafile);
    commit;

    --
    put_line('Request Id to load OCONUS: '||l_request_id);
    --

    if (l_request_id = 0) then
        errbuf := fnd_message.get;
        retcode := 2;

    else

      loop

        --
        put_line('Going to sleep for 30 sec... : '||to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        --
        dbms_lock.sleep(30.01);
        --
        put_line('Awake... : '||to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        --

        l_result := fnd_concurrent.get_request_status(
                                REQUEST_ID => l_request_id,
                                PHASE      => l_phase,
                                STATUS     => l_status,
                                DEV_PHASE  => l_dev_phase,
                                DEV_STATUS => l_dev_status,
                                MESSAGE    => l_message);

        if (l_result) then

           if (l_dev_phase = 'COMPLETE') then

             if (l_dev_status in ('NORMAL','WARNING')) then

               p_request_status := 'SUCCESS';

             else

               p_request_status := 'FAILED';

             end if; /* l_dev_status = 'NORMAL' or l_dev_status = 'WARNING' */

             --
             put_line('Load request status: '||p_request_status);
             --
             exit;

           end if; /* l_dev_phase = 'COMPLETE' */

        end if; /* result */

      end loop;

  /*
    else
      put_line('Wait for Request to load OCONUS: '||l_request_id);
      if (FND_CONCURRENT.WAIT_FOR_REQUEST(
                         request_id => l_request_id,
                         interval   => 30,
                         max_wait   => 144000,
                         phase      => l_phase,
                         status     => l_status,
                         dev_phase  => l_dev_phase,
                         dev_status => l_dev_status,
                         message    => l_message)) then
        null;
      end if;

      put_line('l_phase: '||l_phase);
      put_line('l_status: '||l_status);
      put_line('l_dev_phase: '||l_dev_phase);
      put_line('l_dev_status: '||l_dev_status);
      put_line('l_message: '||l_message);
  */

    end if; /* l_request_id = 0 */

  end if; /* nvl(retcode, 0) <> 2 */

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := fnd_message.get;
      retcode := 2;
END UploadOCONUS;


PROCEDURE ValidateCONUS(errbuf out nocopy varchar2,
                        retcode out nocopy number,
                        p_datafile in varchar2) IS



BEGIN

  ValidateFileFormat(errbuf, retcode, 'CONUS', p_datafile);

END ValidateCONUS;


PROCEDURE ValidateOCONUS(errbuf out nocopy varchar2,
                        retcode out nocopy number,
                        p_datafile in varchar2) IS



BEGIN

  ValidateFileFormat(errbuf, retcode, 'OCONUS', p_datafile);

END ValidateOCONUS;



PROCEDURE ValidateFileFormat(errbuf out nocopy varchar2,
                             retcode out nocopy number,
                             p_ratetype in varchar2,
                             p_datafile in varchar2) IS
/*
PROCEDURE ValidateFileFormat(p_ratetype in varchar2,
                             p_datafile in varchar2) IS
*/


l_datafilepath		varchar2(240);
l_datafile		varchar2(240);
l_datafileptr		utl_file.file_type;

l_ntdir			number;
l_unixdir		number;

l_line			varchar2(1000);
l_numrecs		number;

l_end_delim		number;
l_after_delim		number;

l_invalid_format	exception;
l_invalid_rate_type	exception;

BEGIN

  --
  -- Parse the datafile for the path and filename
  --
  put_line('Parsing Data File: '|| p_datafile);
  --
  l_ntdir := instrb(p_datafile, '\', -1);
  l_unixdir := instrb(p_datafile, '/', -1);
  if (l_ntdir > 0) then
    l_datafilepath := substrb(p_datafile, 0, l_ntdir-1);
    l_datafile := substrb(p_datafile, l_ntdir+1);
  elsif (l_unixdir > 0) then
    l_datafilepath := substrb(p_datafile, 0, l_unixdir-1);
    l_datafile := substrb(p_datafile, l_unixdir+1);
  else
    l_datafilepath := '';
    l_datafile := p_datafile;
  end if;
  --
  put_line('NT Directory position: '|| to_char(l_ntdir));
  put_line('Unix Directory position: '|| to_char(l_unixdir));
  put_line('Data File Path: '|| l_datafilepath);
  put_line('Data File Name: '|| l_datafile);
  put_line('Rate Type: '|| p_ratetype);
  --

  --
  -- Open the datafile for read
  --
  put_line('Opening Data File: '|| p_datafile);
  --
  l_datafileptr := utl_file.fopen(l_datafilepath, l_datafile, 'r');

  l_numrecs := 0;

  if (p_ratetype = 'CONUS') then
  --
  -- Check CONUS file format has 10 fields
  --
    loop
      begin
        utl_file.get_line(l_datafileptr, l_line);
        l_numrecs := l_numrecs + 1;
        l_end_delim := instrb(l_line, ';', 1, 10);
        l_after_delim := instrb(l_line, ';', 1, 11);
        if (l_end_delim <> 0 and
            l_after_delim = 0) then
          null;
        else
          raise l_invalid_format;
        end if;
      exception
        when no_data_found then
          exit;
        when others then
          raise l_invalid_format;
      end;
    end loop;
  elsif (p_ratetype = 'OCONUS') then
  --
  -- Check OCONUS file format has 12 fields
  --
    loop
      begin
        utl_file.get_line(l_datafileptr, l_line);
        l_numrecs := l_numrecs + 1;
        l_end_delim := instrb(l_line, ';', 1, 12);
        l_after_delim := instrb(l_line, ';', 1, 13);
        if (l_end_delim <> 0 and
            l_after_delim = 0) then
          null;
        else
          raise l_invalid_format;
        end if;
      exception
        when no_data_found then
          exit;
        when others then
          raise l_invalid_format;
      end;
    end loop;
  else
  --
  -- Invalid rate type
  --
    raise l_invalid_rate_type;
  end if;
  --
  put_line('Total number of valid '||p_ratetype||' records: '|| to_char(l_numrecs));
  --

  --
  -- Close the datafile
  --
  put_line('Closing Data File: '|| p_datafile);
  --
  utl_file.fclose(l_datafileptr);

  EXCEPTION
    WHEN l_invalid_format THEN
      --utl_file.fclose_all;
      utl_file.fclose(l_datafileptr);
      fnd_message.set_name('SQLAP', 'OIE_APWUPDM_INVALID_FORMAT');
      errbuf := fnd_message.get;
      retcode := 2;
    WHEN l_invalid_rate_type THEN
      --utl_file.fclose_all;
      utl_file.fclose(l_datafileptr);
      fnd_message.set_name('SQLAP', 'OIE_APWUPDM_INVALID_RATE_TYPE');
      errbuf := fnd_message.get;
      retcode := 2;
    WHEN OTHERS THEN
      --utl_file.fclose_all;
      utl_file.fclose(l_datafileptr);
      fnd_message.set_name('AK', 'AK_INVALID_FILE_OPERATION');
      fnd_message.set_token('PATH', l_datafilepath);
      fnd_message.set_token('FILE', l_datafile);
      errbuf := fnd_message.get;
      retcode := 2;

END ValidateFileFormat;


END AP_WEB_UPLOAD_PDM_PKG;

/
