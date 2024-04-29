--------------------------------------------------------
--  DDL for Package Body AP_WEB_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_LOCATIONS_PKG" as
/* $Header: apwelocb.pls 120.2 2006/04/06 02:22:01 krmenon noship $ */

  TYPE t_string_array IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  g_country_cache t_string_array;

------------------------------------------------------------
-- Package private procedures
------------------------------------------------------------
  procedure get_location(p_location in out nocopy location_rec,
                          x_return_status in OUT nocopy varchar2,
                          x_msg_count in out NOCOPY number,
                          x_msg_data in out nocopy varchar2);
  procedure get_location(p_loc_array in out nocopy loc_array,
                        x_return_status in out nocopy varchar2,
                        x_msg_count in out nocopy number,
                        x_msg_data in out nocopy varchar2);
  procedure default_org_id(p_location in out nocopy location_rec,
                         p_card_program_id in number);
  procedure set_address_key(p_loc_rec in out nocopy location_rec);
  procedure get_geometry(p_loc_array in out nocopy loc_array);
  procedure get_geometry(p_location in out nocopy location_rec);
  function default_country_pvt(p_card_program_id in number) return varchar2;

  --
  -- get_location procedure checks to see if an identical address exists
  -- in the AP_EXP_LOCATIONS table. If it exists, it does nothing.
  -- If it doesn't exist, it will populate AP_EXP_LOCATIONS. It will
  -- also call out to eLocations to populate the spatial coordinates
  -- NOTE: AP_EXP_LOCATIONS will only be populated if
  --       MERCHANT_COUNTRY_CODE is non-null.

------------------------------------------------------------
-- get_location using location_rec
------------------------------------------------------------
procedure get_location(p_location in out nocopy location_rec,
                        x_return_status in out nocopy varchar2,
                        x_msg_count in out nocopy number,
                        x_msg_data in out nocopy varchar2)
is
  l_loc_array loc_array := loc_array(p_location);
begin
  get_location(l_loc_array, x_return_status, x_msg_count, x_msg_data);

  p_location.location_id := l_loc_array(1).location_id;
  p_location.geometry_status_code := l_loc_array(1).geometry_status_code;
  p_location.geometry := l_loc_array(1).geometry;
end;


------------------------------------------------------------
-- get_location using loc_array
------------------------------------------------------------
procedure get_location(p_loc_array in out nocopy loc_array,
                        x_return_status in out nocopy varchar2,
                        x_msg_count in out nocopy number,
                        x_msg_data in out nocopy varchar2)
is
  l_count number;

  l_ins_count number := 0;
  l_ins_array loc_array := loc_array();

  user_id number(15);
  login_id number(15);
  todays_date date;
begin
  l_count := p_loc_array.count;
  if l_count = 0 then
    return;
  end if;

  user_id := fnd_global.user_id;
  login_id := fnd_global.login_id;
  todays_date := sysdate;

  for i in 1..l_count loop
    p_loc_array(i).address1 := upper(p_loc_array(i).address1);
    p_loc_array(i).address2 := upper(p_loc_array(i).address2);
    p_loc_array(i).address3 := upper(p_loc_array(i).address3);
    p_loc_array(i).address4 := upper(p_loc_array(i).address4);
    p_loc_array(i).city := upper(p_loc_array(i).city);
    p_loc_array(i).province_state := upper(p_loc_array(i).province_state);
    p_loc_array(i).postal_code := upper(p_loc_array(i).postal_code);
    p_loc_array(i).country := upper(p_loc_array(i).country);

    if p_loc_array(i).country = 'UNITED STATES' then
      p_loc_array(i).country := 'US';
    end if;

   set_address_key(p_loc_array(i));

    begin
     select location_id, geometry, geometry_status_code
      into p_loc_array(i).location_id, p_loc_array(i).geometry, p_loc_array(i).geometry_status_code
      from ap_exp_locations
      where address_key = p_loc_array(i).address_key;

    exception
    when no_data_found then
      select ap_exp_locations_s.nextval
      into p_loc_array(i).location_id
      from dual;

      get_geometry(p_loc_array(i));

      insert into ap_exp_locations
        ( location_id,
          address_key,
          address1,
          address2,
          address3,
          address4,
          city,
          province_state,
          postal_code,
          country,
          geometry,
          geometry_status_code,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          org_id )
       values
        ( p_loc_array(i).location_id,
          p_loc_array(i).address_key,
          p_loc_array(i).address1,
          p_loc_array(i).address2,
          p_loc_array(i).address3,
          p_loc_array(i).address4,
          p_loc_array(i).city,
          p_loc_array(i).province_state,
          p_loc_array(i).postal_code,
          p_loc_array(i).country,
          p_loc_array(i).geometry,
          p_loc_array(i).geometry_status_code,
          user_id,
          todays_date,
          user_id,
          todays_date,
          login_id,
          mo_global.get_current_org_id() );
    end;
  end loop;

end get_location;


------------------------------------------------------------
-- get_location using ap_credit_card_trxns_all
------------------------------------------------------------
procedure get_location(p_cc_trx in out nocopy ap_credit_card_trxns_all%rowtype,
                       x_return_status in out nocopy varchar2,
                       x_msg_count in out nocopy number,
                       x_msg_data in out nocopy varchar2)
is
  l_cc_trx_arr cc_trx_array := cc_trx_array(p_cc_trx);
begin
  get_location(l_cc_trx_arr, x_return_status, x_msg_count, x_msg_data);
  p_cc_trx.location_id := l_cc_trx_arr(1).location_id;
end get_location;

------------------------------------------------------------
-- get_location using cc_trx_array
------------------------------------------------------------
procedure get_location(p_cc_trx in out nocopy cc_trx_array,
                       x_return_status in out nocopy varchar2,
                       x_msg_count in out nocopy number,
                       x_msg_data in out nocopy varchar2)
is
  l_loc_array loc_array := loc_array();
  l_count number;
begin
  l_count := p_cc_trx.COUNT;
  for i in 1..l_count loop
    if p_cc_trx(i).merchant_country_code is not null then
      l_loc_array.extend;

      l_loc_array(i).address1 := p_cc_trx(i).merchant_address1;
      l_loc_array(i).address2 := p_cc_trx(i).merchant_address2;
      l_loc_array(i).address3 := p_cc_trx(i).merchant_address3;
      l_loc_array(i).address4 := p_cc_trx(i).merchant_address4;
      l_loc_array(i).city     := p_cc_trx(i).merchant_city;
      l_loc_array(i).province_state := p_cc_trx(i).merchant_province_state;
      l_loc_array(i).postal_code := p_cc_trx(i).merchant_postal_code;
      l_loc_array(i).country  := p_cc_trx(i).merchant_country_code;
      l_loc_array(i).org_id   := p_cc_trx(i).org_id;
    end if;
  end loop;

  get_location(l_loc_array, x_return_status, x_msg_count, x_msg_data);

  for i in 1..l_count loop
    p_cc_trx(i).location_id := l_loc_array(i).location_id;
  end loop;
end get_location;


------------------------------------------------------------
  --
  -- Uses various information about the card program to default a country.
  -- This includes....
  --    o Supplier Site
  --    o Currency territories
  --    o Organization
------------------------------------------------------------
function default_country(p_card_program_id in number)
  return varchar2 is
begin
  return g_country_cache(p_card_program_id);
exception
  when no_data_found then
    g_country_cache(p_card_program_id) := default_country_pvt(p_card_program_id);
    return g_country_cache(p_card_program_id);
end default_country;

function default_country_pvt(p_card_program_id in number)
  return varchar2 is
    l_country varchar2(80);
begin
  if p_card_program_id is null then
    --
    -- Default country from supplier site
    --
    begin
      select site.country
      into l_country
      from ap_card_programs_all card,
           ap_supplier_sites_all site
      where card.vendor_site_id = site.vendor_site_id
      and card.card_program_id = p_card_program_id;

      return l_country;
    exception
    when no_data_found then
      l_country := null;
    end;

    --
    -- Default country from currency
    --
    begin
      select curr.issuing_territory_code
      into l_country
      from ap_card_programs_all card,
           fnd_currencies curr
      where card.card_program_id = p_card_program_id
      and card.card_program_currency_code = curr.currency_code;

      return l_country;
    exception
    when no_data_found then
      l_country := null;
    end;

  end if;

  --
  -- Default country from ORG_ID
  --
  begin
    select loc.country
    into l_country
    from hr_all_organization_units org,
         hr_locations loc,
         ap_card_programs_all p
    where org.location_id = loc.location_id
    and org.organization_id = p.org_id
    and p.card_program_id = p_card_program_id;

    return l_country;
  exception
  when no_data_found then
    l_country := null;
  end;

  return null;
end default_country_pvt;


------------------------------------ PRIVATE -----------------------------------

------------------------------------------------------------
-- Default ORG_ID based on the card program
------------------------------------------------------------
procedure default_org_id(p_location in out nocopy location_rec,
                         p_card_program_id in number)
is
begin
  if p_location.org_id is not null then
    return;
  end if;

  if p_card_program_id is not null then
    select org_id into p_location.org_id
    from ap_card_programs_all
    where card_program_id = p_card_program_id;
  end if;
end default_org_id;

------------------------------------------------------------
-- Set the address key for the location
------------------------------------------------------------
procedure set_address_key(p_loc_rec in out nocopy location_rec)
is
begin
  p_loc_rec.address_key :=
            to_char(p_loc_rec.org_id)|| fnd_global.newline ||
            upper(p_loc_rec.country)        ||fnd_global.newline||
            upper(p_loc_rec.postal_code)    ||fnd_global.newline||
            upper(p_loc_rec.province_state) ||fnd_global.newline||
            upper(p_loc_rec.city)           ||fnd_global.newline||
            upper(p_loc_rec.address1)       ||fnd_global.newline||
            upper(p_loc_rec.address2)       ||fnd_global.newline||
            upper(p_loc_rec.address3)       ||fnd_global.newline||
            upper(p_loc_rec.address4);

end set_address_key;

------------------------------------------------------------
-- Call out to HZ APIs to integrate with eLocation
------------------------------------------------------------
procedure get_geometry(p_loc_array in out nocopy loc_array)
is
/*
  l_array hz_geocode_pkg.loc_array := hz_geocode_pkg.loc_array();

  l_http_ad varchar2(2000);
  l_bypass_domains varchar2(2000);
  l_proxy varchar2(100);
  l_proxy_port varchar2(10);

  l_count number;

  l_return_status   VARCHAR2(10);
  l_msg_count number;
  l_msg_data varchar2(2000);
*/
begin
NULL;
/*
   This procedure has been completely commented out because
     HZ_GEOCODE_PKG causes a dependency on HZ.H which is higher than
     the required 11.5.4 base. This should be uncommented in 11i.X or later
     whenever eLocation integration needs to be reintroduced.
     eLocation integration is currently not documented nor supported in 11.5.10.

  fnd_profile.get('HZ_GEOCODE_WEBSITE', l_http_ad);
  fnd_profile.get('WEB_PROXY_BYPASS_DOMAINS', l_bypass_domains);

  IF hz_geocode_pkg.in_bypass_list(
       l_http_ad,
       l_bypass_domains
  ) THEN
    -- site is in the bypass list.
    l_proxy      := NULL;
    l_proxy_port := NULL;
  ELSE
    -- site is not in the bypass list.
    -- First, attempt to get proxy value from FND.  If the proxy name is not
    -- found, try the TCA values regardless of whether the port is found.
    fnd_profile.get('WEB_PROXY_HOST', l_proxy);
    fnd_profile.get('WEB_PROXY_PORT', l_proxy_port);

    IF l_proxy IS NULL THEN
      fnd_profile.get('HZ_WEBPROXY_NAME', l_proxy);
      fnd_profile.get('HZ_WEBPROXY_PORT', l_proxy_port);
    END IF;
  END IF;

  l_count := p_loc_array.count;
  l_array.extend(l_count);
  for i in 1..l_count loop
    l_array(i).location_id := p_loc_array(i).location_id;
    l_array(i).address1 := p_loc_array(i).address1;
    l_array(i).address2 := p_loc_array(i).address2;
    l_array(i).address2 := p_loc_array(i).address2;
    l_array(i).address2 := p_loc_array(i).address2;
    l_array(i).city := p_loc_array(i).city;
    l_array(i).state := p_loc_array(i).province_state;
    l_array(i).province := p_loc_array(i).province_state;
    l_array(i).postal_code := p_loc_array(i).postal_code;
    l_array(i).country := p_loc_array(i).country;
  end loop;

  hz_geocode_pkg.get_spatial_coords(
            p_loc_array            => l_array,
            p_name                 => NULL,
            p_http_ad              => l_http_ad,
            p_proxy                => l_proxy,
            p_port                 => l_proxy_port,
            p_retry                => 3,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data
          );

  if l_return_status = fnd_api.g_ret_sts_unexp_error then
    for i in 1..l_msg_count loop
      fnd_log.string(fnd_log.level_unexpected,
                     'OIE_LOCATIONS_PKG.get_geometry',
                     fnd_msg_pub.get(i, 'F'));
    end loop;
  elsif l_return_status = fnd_api.g_ret_sts_error then
    for i in 1..l_msg_count loop
      fnd_log.string(fnd_log.level_error,
                     'OIE_LOCATIONS_PKG.get_geometry',
                     fnd_msg_pub.get(i, 'F'));
    end loop;
  end if;

  for i in 1..l_count loop
    p_loc_array(i).geometry_status_code := l_array(i).geometry_status_code;
    p_loc_array(i).geometry := l_array(i).geometry;
  end loop;
*/
end get_geometry;

procedure get_geometry(p_location in out nocopy location_rec)
is
  l_loc_array loc_array :=
        loc_array(p_location);
begin
  get_geometry(l_loc_array);
  p_location.geometry_status_code := l_loc_array(1).geometry_status_code;
  p_location.geometry := l_loc_array(1).geometry;
end;



end;

/
