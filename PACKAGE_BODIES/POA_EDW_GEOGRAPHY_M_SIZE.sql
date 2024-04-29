--------------------------------------------------------
--  DDL for Package Body POA_EDW_GEOGRAPHY_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_GEOGRAPHY_M_SIZE" AS
/*$Header: poaszgyb.pls 120.0 2005/06/01 18:48:46 appldev noship $ */

PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                        p_to_date   IN  DATE,
                        p_num_rows  OUT NOCOPY NUMBER) IS

BEGIN

--    dbms_output.enable(100000);

    select sum(cnt) into p_num_rows
      from (
        select count(*) cnt
          from
               po_vendors vnd,
               po_vendor_sites_all vns
         WHERE vns.vendor_id    = vnd.vendor_id
           and greatest(vns.last_update_date, vnd.last_update_date)
                 between p_from_date and p_to_date
        union all
        select count(*) cnt
          from hr_locations_all
         where last_update_date between p_from_date and p_to_date
        union all
        select count(*) cnt
          from
               HZ_LOCATIONS               hzl,
               HZ_PARTIES                 hzp,
               HZ_PARTY_SITES             hzps
         WHERE hzps.location_id    = hzl.location_id
           AND hzps.party_id       = hzp.party_id
           AND greatest(hzl.last_update_date, hzp.last_update_date,
                        hzps.last_update_date)
                 between p_from_date and p_to_date);

--    dbms_output.put_line('The number of rows for geography is: '
--                         || to_char(p_num_rows));

EXCEPTION
    WHEN OTHERS THEN p_num_rows := 0;
END;

-------------------------------------------------------

PROCEDURE  est_row_len (p_from_date    IN  DATE,
                        p_to_date      IN  DATE,
                        p_avg_row_len  OUT NOCOPY NUMBER) IS

 x_areas                 number :=15;
 x_total_country         number := 0;
 x_total_region          number := 0;
 x_total_state           number := 0;
 x_total_state_region    number := 0;
 x_total_city            number := 0;
 x_total_postcode        number := 0;
 x_total_postcode_city   number := 0;
 x_total_location        number := 0;
 x_total                 number := 0;
 x_date                  number := 7;

 x_org_id                NUMBER := 0;
 x_vendor_site_code      NUMBER := 0;
 x_province              NUMBER := 0;
 x_county                NUMBER := 0;
 x_state                 NUMBER := 0;
 x_country               NUMBER := 0;
 x_postcode              NUMBER := 0;
 x_city                  NUMBER := 0;
 x_vendor_name           NUMBER := 0;
 x_last_update_date      NUMBER := x_date;
 x_creation_date         NUMBER := x_date;
 x_town_or_city          NUMBER := 0;
 x_location_id           NUMBER := 0;
 x_postal_code           NUMBER := 0;
 x_region_2              NUMBER := 0;
 x_location_code         NUMBER := 0;
 x_address1              NUMBER := 0;
 x_address2              NUMBER := 0;
 x_address3              NUMBER := 0;
 x_address4              NUMBER := 0;
 x_party_site_id         NUMBER := 0;
 x_party_site_name       NUMBER := 0;
 x_DESCRIPTION           NUMBER := 0;
 x_TERRITORY_SHORT_NAME  NUMBER := 0;


 x_ADDRESS_LINE_1        NUMBER := 0;
 x_ADDRESS_LINE_2        NUMBER := 0;
 x_ADDRESS_LINE_3        NUMBER := 0;
 x_ADDRESS_LINE_4        NUMBER := 0;
 x_LOCATION_DP           NUMBER := 0;
 x_LOCATION_PK           NUMBER := 0;
 x_POSTCODE_CITY_FK      NUMBER := 0;
 x_NAME                  NUMBER := 0;
 x_INSTANCE              NUMBER := 0;

 x_POSTCODE_CITY_PK      NUMBER := 0;
 x_POSTCODE_CITY_DP      NUMBER := 0;
 x_CITY_FK               NUMBER := 0;
 x_POSTCODE_FK           NUMBER := 0;

 x_CITY_PK               NUMBER := 0;
 x_CITY_DP               NUMBER := 0;

 x_POSTCODE_PK           NUMBER := 0;
 x_POSTCODE_DP           NUMBER := 0;
 x_STATE_REGION_FK       NUMBER := 0;

 x_STATE_REGION_PK       NUMBER := 0;
 x_STATE_REGION_DP       NUMBER := 0;
 x_STATE_FK              NUMBER := 0;

 x_STATE_PK              NUMBER := 0;
 x_STATE_DP              NUMBER := 0;
 x_REGION_FK             NUMBER := 0;

 x_REGION_PK             NUMBER := 0;
 x_REGION_DP             NUMBER := 0;
 x_COUNTRY_FK            NUMBER := 0;

 x_COUNTRY_PK            NUMBER := 0;
 x_COUNTRY_DP            NUMBER := 0;
 x_AREA2_FK              NUMBER := 0;
------------------------------------------


cursor c0 is
   select avg(nvl(vsize(instance_code),0))
   from edw_local_instance;

cursor c1 is
   select avg(nvl(vsize(vendor_site_id), 0)),
   avg(nvl(vsize(org_id),0)),
   avg(nvl(vsize(address_line1),0)),
   avg(nvl(vsize(address_line2),0)),
   avg(nvl(vsize(address_line3),0)),
   avg(nvl(vsize(city),0)),
   avg(nvl(vsize(county),0)),
   avg(nvl(vsize(state),0)),
   avg(nvl(vsize(zip),0)),
   avg(nvl(vsize(province),0)),
   avg(nvl(vsize(country),0)),
   avg(nvl(vsize(vendor_site_code),0))
   from po_vendor_sites_all where last_update_date
   between p_from_date and p_to_date;

cursor c2 is
   select avg(nvl(vsize(location_id),0)),
     avg(nvl(vsize(town_or_city),0)),
     avg(nvl(vsize(postal_code),0)),
     avg(nvl(vsize(region_2),0)),
     avg(nvl(vsize(country),0)),
     avg(nvl(vsize(address_line_1),0)),
     avg(nvl(vsize(address_line_2),0)),
     avg(nvl(vsize(address_line_3),0)),
     avg(nvl(vsize(location_code),0))
   from HR_LOCATIONS_ALL where last_update_date
   between p_from_date and p_to_date;

cursor c3 is
   select avg(nvl(vsize(city),0)),
    avg(nvl(vsize(postal_code),0)),
    avg(nvl(vsize(state),0)),
    avg(nvl(vsize(province),0)),
    avg(nvl(vsize(country),0)),
    avg(nvl(vsize(address1),0)),
    avg(nvl(vsize(address2),0)),
    avg(nvl(vsize(address3),0)),
    avg(nvl(vsize(address4),0))
   from HZ_LOCATIONS where last_update_date
   between p_from_date and p_to_date;

cursor c4 is
   select avg(nvl(vsize(party_site_id),0)),
    avg(nvl(vsize(party_site_name),0))
   from HZ_PARTY_SITES where last_update_date
   between p_from_date and p_to_date;

cursor c5 is
   select avg(nvl(vsize(DESCRIPTION),0)),
    avg(nvl(vsize(TERRITORY_SHORT_NAME),0))
   from fnd_territories_tl where last_update_date
   between p_from_date and p_to_date;

cursor c6 is
   select avg(nvl(vsize(vendor_name), 0))
   from po_vendors where last_update_date
   between p_from_date and p_to_date;


BEGIN
--   dbms_output.enable(100000);

--   dbms_output.put_line('     ');
--   dbms_output.put_line('input_m from source tables for the following staging tables are: ');
--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_AREA1_LSTG : ' || to_char(x_areas));
--   dbms_output.put_line('for EDW_GEOG_AREA2_LSTG : ' || to_char(x_areas));

---------------------------------------------------------------

   open c0;
   fetch c0 into x_INSTANCE;
   close c0;

   open c5;
   fetch c5 into x_DESCRIPTION, x_TERRITORY_SHORT_NAME;
   close c5;

----------------- From PO_VENDOR_SITES ------------------

   OPEN c1;
   FETCH c1 into x_LOCATION_PK, x_org_id, x_ADDRESS_LINE_1,
      x_ADDRESS_LINE_2, x_ADDRESS_LINE_3, x_city, x_county,
      x_state, x_POSTCODE, x_province, x_country,
      x_vendor_site_code;
   CLOSE c1;

   x_state := greatest (x_state, x_province);

   open c6;
   FETCH c6 into x_vendor_name;
   close c6;

   x_LOCATION_PK        := x_LOCATION_PK + x_org_id;
   x_LOCATION_DP        := x_vendor_site_code + x_vendor_name;
   x_POSTCODE_CITY_FK   := x_city +  x_state + x_POSTCODE + x_country;
   x_NAME               := x_LOCATION_DP;

   x_total_location := x_total_location
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_LOCATION_PK + 1), 0)
           + NVL (ceil(x_LOCATION_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_1 + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_2 + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_3 + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_FK + 1), 0);


   x_POSTCODE_CITY_PK := x_POSTCODE_CITY_FK;
   x_POSTCODE_CITY_DP := x_city +  x_state + x_POSTCODE;
   x_CITY_FK          := x_city +  x_state + x_country;
   x_POSTCODE_FK      := x_state + x_POSTCODE + x_country;
   x_NAME             := x_POSTCODE_CITY_DP;

   x_total_postcode_city := x_total_postcode_city
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_PK + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_CITY_FK  + 1), 0)
           + NVL (ceil(x_POSTCODE_FK  + 1), 0);


   x_CITY_PK := x_CITY_FK;
   x_CITY_DP := x_city +  x_state;
   x_NAME    := x_CITY_DP;
   x_STATE_REGION_FK := x_state + x_country;

   x_total_city := x_total_city
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_CITY_PK  + 1), 0)
           + NVL (ceil(x_CITY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0);


   x_POSTCODE_PK := x_POSTCODE_FK;
   x_POSTCODE_DP := x_state + x_POSTCODE;
   x_NAME        := x_POSTCODE_DP;

   x_total_postcode := x_total_postcode
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_POSTCODE_PK  + 1), 0)
           + NVL (ceil(x_POSTCODE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0);


   x_STATE_REGION_PK := x_STATE_REGION_FK;
   x_STATE_REGION_DP := x_state + x_country;
   x_NAME            := x_STATE_REGION_DP;
   x_STATE_FK        := x_state + x_country;

   x_total_state_region := x_total_state_region
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_STATE_REGION_PK  + 1), 0)
           + NVL (ceil(x_STATE_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_FK  + 1), 0);


   x_STATE_PK    := x_STATE_FK;
   x_STATE_DP    := x_state + x_country;
   x_NAME        := x_STATE_DP;
   x_REGION_FK   := x_country;

   x_total_state := x_total_state
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_STATE_PK  + 1), 0)
           + NVL (ceil(x_STATE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_REGION_FK + 1), 0);


   x_REGION_PK  := x_REGION_FK;
   x_REGION_DP  := x_country;
   x_NAME       := x_REGION_DP;
   x_COUNTRY_FK := x_country;

   x_total_region := x_total_region
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_REGION_PK  + 1), 0)
           + NVL (ceil(x_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_COUNTRY_FK + 1), 0);


   x_COUNTRY_PK := x_COUNTRY_FK;
   x_COUNTRY_DP := x_DESCRIPTION;
   x_NAME       := x_TERRITORY_SHORT_NAME;
   x_AREA2_FK   := 3;

   x_total_country := x_total_country
      + NVL (ceil(x_INSTANCE + 1), 0) + NVL (ceil(x_last_update_date + 1), 0)
      + NVL (ceil(x_creation_date + 1), 0)
           + NVL (ceil(x_COUNTRY_PK  + 1), 0)
           + NVL (ceil(x_COUNTRY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_AREA2_FK + 1), 0);


---------------- From HR_LOCATIONS -----------------

   OPEN c2;
   FETCH c2 into x_LOCATION_ID, x_town_or_city, x_postal_code,
      x_region_2, x_country, x_ADDRESS_LINE_1,
      x_ADDRESS_LINE_2, x_ADDRESS_LINE_3, x_location_code;
   CLOSE c2;

   x_LOCATION_PK        := x_LOCATION_ID;
   x_LOCATION_DP        := x_location_code;
   x_NAME               := x_LOCATION_DP;
   x_POSTCODE_CITY_FK   := x_town_or_city + x_postal_code +
                           x_region_2 + x_country;

   x_total_location := greatest(x_total_location
           , NVL (ceil(x_LOCATION_PK + 1), 0)
           + NVL (ceil(x_LOCATION_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_1 + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_2 + 1), 0)
           + NVL (ceil(x_ADDRESS_LINE_3 + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_FK + 1), 0));


   x_POSTCODE_CITY_PK := x_POSTCODE_CITY_FK;
   x_POSTCODE_CITY_DP := x_town_or_city + x_postal_code + x_region_2;
   x_CITY_FK          := x_town_or_city + x_region_2 + x_country;
   x_POSTCODE_FK      := x_postal_code  + x_region_2 + x_country;
   x_NAME             := x_POSTCODE_CITY_DP;

   x_total_postcode_city := greatest(x_total_postcode_city
           , NVL (ceil(x_POSTCODE_CITY_PK + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_CITY_FK  + 1), 0)
           + NVL (ceil(x_POSTCODE_FK  + 1), 0));


   x_CITY_PK := x_CITY_FK;
   x_CITY_DP := x_town_or_city + x_region_2;
   x_NAME    := x_CITY_DP;
   x_STATE_REGION_FK := x_region_2 + x_country;

   x_total_city := greatest(x_total_city
           , NVL (ceil(x_CITY_PK  + 1), 0)
           + NVL (ceil(x_CITY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0));


   x_POSTCODE_PK := x_POSTCODE_FK;
   x_POSTCODE_DP := x_postal_code + x_region_2;
   x_NAME        := x_POSTCODE_DP;

   x_total_postcode := greatest(x_total_postcode
           , NVL (ceil(x_POSTCODE_PK  + 1), 0)
           + NVL (ceil(x_POSTCODE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0));


   x_STATE_REGION_PK := x_STATE_REGION_FK;
   x_STATE_REGION_DP := x_region_2 + x_country;
   x_NAME            := x_STATE_REGION_DP;
   x_STATE_FK        := x_region_2 + x_country;

   x_total_state_region := greatest(x_total_state_region
           , NVL (ceil(x_STATE_REGION_PK  + 1), 0)
           + NVL (ceil(x_STATE_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_FK  + 1), 0));


   x_STATE_PK    := x_STATE_FK;
   x_STATE_DP    := x_region_2 + x_country;
   x_NAME        := x_STATE_DP;
   x_REGION_FK   := x_country;

   x_total_state := greatest(x_total_state
           , NVL (ceil(x_STATE_PK  + 1), 0)
           + NVL (ceil(x_STATE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_REGION_FK + 1), 0));


   x_REGION_PK  := x_REGION_FK;
   x_REGION_DP  := x_country;
   x_NAME       := x_REGION_DP;
   x_COUNTRY_FK := x_country;

   x_total_region := greatest(x_total_region
           , NVL (ceil(x_REGION_PK  + 1), 0)
           + NVL (ceil(x_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_COUNTRY_FK + 1), 0));


   x_COUNTRY_PK := x_COUNTRY_FK;
   x_COUNTRY_DP := x_DESCRIPTION;
   x_NAME       := x_TERRITORY_SHORT_NAME;
   x_AREA2_FK   := 3;

   x_total_country := greatest(x_total_country
           , NVL (ceil(x_COUNTRY_PK  + 1), 0)
           + NVL (ceil(x_COUNTRY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_AREA2_FK + 1), 0));


----------------- From HZ_LOCATIONS and Party_Sites ------------------

   OPEN c3;
   FETCH c3 into x_city, x_postal_code, x_state, x_province,
      x_country, x_ADDRESS1, x_ADDRESS2, x_ADDRESS3,  x_ADDRESS4;
   CLOSE c3;

   x_state := greatest (x_state, x_province);

   OPEN c4;
   FETCH c4 into x_party_site_id, x_party_site_name;
   CLOSE c4;


   x_LOCATION_PK        := x_party_site_id;
   x_LOCATION_DP        := x_party_site_name;
   x_NAME               := x_LOCATION_DP;
   x_POSTCODE_CITY_FK   := x_city + x_postal_code +
                           x_state + x_country;

   x_total_location := greatest(x_total_location
           , NVL (ceil(x_LOCATION_PK + 1), 0)
           + NVL (ceil(x_LOCATION_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_ADDRESS1 + 1), 0)
           + NVL (ceil(x_ADDRESS2 + 1), 0)
           + NVL (ceil(x_ADDRESS3 + 1), 0)
           + NVL (ceil(x_ADDRESS4 + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_FK + 1), 0));


   x_POSTCODE_CITY_PK := x_POSTCODE_CITY_FK;
   x_POSTCODE_CITY_DP := x_city + x_postal_code + x_state;
   x_CITY_FK          := x_city + x_state + x_country;
   x_POSTCODE_FK      := x_postal_code  + x_state + x_country;
   x_NAME             := x_POSTCODE_CITY_DP;

   x_total_postcode_city := greatest(x_total_postcode_city
           , NVL (ceil(x_POSTCODE_CITY_PK + 1), 0)
           + NVL (ceil(x_POSTCODE_CITY_DP + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_CITY_FK  + 1), 0)
           + NVL (ceil(x_POSTCODE_FK  + 1), 0));


   x_CITY_PK := x_CITY_FK;
   x_CITY_DP := x_city + x_state;
   x_NAME    := x_CITY_DP;
   x_STATE_REGION_FK := x_state + x_country;

   x_total_city := greatest(x_total_city
           , NVL (ceil(x_CITY_PK  + 1), 0)
           + NVL (ceil(x_CITY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0));


   x_POSTCODE_PK := x_POSTCODE_FK;
   x_POSTCODE_DP := x_postal_code + x_state;
   x_NAME        := x_POSTCODE_DP;

   x_total_postcode := greatest(x_total_postcode
           , NVL (ceil(x_POSTCODE_PK  + 1), 0)
           + NVL (ceil(x_POSTCODE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_REGION_FK  + 1), 0));


   x_STATE_REGION_PK := x_STATE_REGION_FK;
   x_STATE_REGION_DP := x_state + x_country;
   x_NAME            := x_STATE_REGION_DP;
   x_STATE_FK        := x_state + x_country;

   x_total_state_region := greatest(x_total_state_region
           , NVL (ceil(x_STATE_REGION_PK  + 1), 0)
           + NVL (ceil(x_STATE_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_STATE_FK  + 1), 0));


   x_STATE_PK    := x_STATE_FK;
   x_STATE_DP    := x_state + x_country;
   x_NAME        := x_STATE_DP;
   x_REGION_FK   := x_country;

   x_total_state := greatest(x_total_state
           , NVL (ceil(x_STATE_PK  + 1), 0)
           + NVL (ceil(x_STATE_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_REGION_FK + 1), 0));


   x_REGION_PK  := x_REGION_FK;
   x_REGION_DP  := x_country;
   x_NAME       := x_REGION_DP;
   x_COUNTRY_FK := x_country;

   x_total_region := greatest(x_total_region
           , NVL (ceil(x_REGION_PK  + 1), 0)
           + NVL (ceil(x_REGION_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_COUNTRY_FK + 1), 0));


   x_COUNTRY_PK := x_COUNTRY_FK;
   x_COUNTRY_DP := x_DESCRIPTION;
   x_NAME       := x_TERRITORY_SHORT_NAME;
   x_AREA2_FK   := 3;

   x_total_country := greatest(x_total_country
           , NVL (ceil(x_COUNTRY_PK  + 1), 0)
           + NVL (ceil(x_COUNTRY_DP  + 1), 0)
           + NVL (ceil(x_NAME + 1), 0)
           + NVL (ceil(x_AREA2_FK + 1), 0));

---------------------------------------------
 x_total_country        := 3 + x_total_country;
 x_total_region         := 3 + x_total_region;
 x_total_state          := 3 + x_total_state;
 x_total_state_region   := 3 + x_total_state_region;
 x_total_city           := 3 + x_total_city;
 x_total_postcode       := 3 + x_total_postcode;
 x_total_postcode_city  := 3 + x_total_postcode_city;
 x_total_location       := 3 + x_total_location;
---------------------------------------------

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_COUNTRY_LSTG   : ' || to_char(x_total_country));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_REGION_LSTG   : ' || to_char(x_total_region));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_STATE_LSTG   : ' || to_char(x_total_state));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_STATE_REGION_LSTG   : ' || to_char(x_total_state_region));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_CITY_LSTG   : ' || to_char(x_total_city));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_POSTCODE_LSTG   : ' || to_char(x_total_postcode));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_POSTCODE_CITY_LSTG   : ' || to_char(x_total_postcode_city));

--   dbms_output.put_line('     ');
--   dbms_output.put_line('for EDW_GEOG_LOCATION_LSTG   : ' || to_char(x_total_location));


---------------------------------------------------------------

   x_total := 2*x_areas + x_total_country + x_total_region +
              x_total_state + x_total_state_region + x_total_city +
              x_total_postcode + x_total_postcode_city +
              x_total_location;

--   dbms_output.put_line('-------------------------------------');
--   dbms_output.put_line('input_m for geography dimension is: '
--                        || to_char(x_total));

    p_avg_row_len := x_total;

EXCEPTION
    WHEN OTHERS THEN p_avg_row_len := 0;
END;  -- procedure est_row_len.

END;

/
