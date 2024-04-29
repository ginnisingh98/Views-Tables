--------------------------------------------------------
--  DDL for Package Body HR_US_PYZIPCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_PYZIPCHK" AS
/* $Header: pyzipchk.pkb 120.0.12010000.2 2009/10/08 05:08:16 emunisek ship $ */
--
--
-- This procedure is used to flag out and shows the details
-- of the addresses which have invalid zip codes in both
-- HR_LOCATIONS_ALL and PER_ADDRESSES tables.
-- This script holds procedures and functions that are
-- used to display all the invalid existing addresses in the hr_location_all
-- and per_addresses. It produces a report of all the addresses which
-- contain invlid zip code. This is done by calling the inval_addr
-- function.
--
PROCEDURE  inval_per_addr (     p_address_id    in number,
                                p_state_abbrev in varchar2 default null,
                                p_county_name  in varchar2 default null,
                                p_city_name    in varchar2 default null,
                                p_zip_code     in varchar2 default null)

is

l_per_addr              varchar2(11);
l_add_valid		number;
--
cursor ca_address(p_city_name varchar2
                 ,p_county_name varchar2
                 ,p_zip_code varchar2 ) is

/* rmonge bug 4000003 */

  select count(*)
  from   pay_us_counties co,
         pay_ca_cities_v ct,
         pay_us_zip_codes pc
  where  co.state_code = '70'
  and    co.county_code = ct.province_code
  and    co.county_code = pc.county_code
  and    pc.state_code = '70'
  and    ct.city_code  = pc.city_code
  and    ct.city_name  = p_city_name
  and    co.county_abbrev = p_county_name
  and substr(p_zip_code,1,3) between substr(pc.zip_start,1,3) and substr(pc.zip_end,1,3)
  and substr(p_zip_code,5,3) between '0A0' and '9Z9';

/* Commenting out this script as it has some performance problems.
  select count(*)
  from   pay_ca_provinces_v pr
  ,      pay_ca_cities_v ct
  ,      pay_ca_postal_codes_v pc
  where  pr.province_code = ct.province_code
  and    pr.province_code = pc.province_code
  and    ct.city_code = pc.city_code
  and    ct.city_name = p_city_name
  and    pr.province_abbrev = p_county_name
  and    substr(p_zip_code,1,3) between substr(pc.code_start,1,3)
                                    and substr(pc.code_end,1,3)
  and    substr(p_zip_code,5,3) between '0A0' and '9Z9';
*/

--
begin
--hr_utility.trace('p_address_id: '||p_address_id);
--hr_utility.trace('p_state_abbrev: '||p_state_abbrev);
--hr_utility.trace('p_county_name: '||p_county_name);
--hr_utility.trace('p_city_name: '||p_city_name);
--hr_utility.trace('p_zip_code: '||p_zip_code);

     IF length(p_zip_code) <> 7  THEN  -- US addresses
        l_per_addr := hr_us_ff_udfs.addr_val (p_state_abbrev
                                             ,p_county_name
                                             ,p_city_name
                                             ,p_zip_code
                                             ,'Y');
        if (l_per_addr = '00-000-0000') then
            insert into per_us_inval_addresses (address_id)
            values (p_address_id);
            commit;
        end if;
     ELSIF length(p_zip_code) = 7 THEN  -- Canadian addresses
        /* For Canada p_city_name = City Name,
                      p_county_name = Province Abbreviation,
                      p_zip_code = Postal Code */
        OPEN ca_address(p_city_name, p_county_name, p_zip_code);
        FETCH ca_address INTO l_add_valid;
        IF l_add_valid = 0  THEN
             insert into per_us_inval_addresses (address_id)
             values (p_address_id);
            commit;
        END IF;
        CLOSE ca_address;
     END IF;

end inval_per_addr;


--
--
-- This procedure gets the invalid locations  from hr_location_all
--

PROCEDURE  inval_hr_addr (p_location_id  in number,
                          p_state_abbrev in varchar2 default null,
                          p_county_name  in varchar2 default null,
                          p_city_name    in varchar2 default null,
                          p_zip_code     in varchar2 default null)

is

l_hr_addr       varchar2(11);
l_loc_valid     number;
--
cursor ca_locations (p_city_name varchar2
                    ,p_county_name varchar2
                    ,p_zip_code varchar2) is

/* rmonge 4000003  */

  select count(*)
  from   pay_us_counties co,
         pay_ca_cities_v ct,
         pay_us_zip_codes pc
  where  co.state_code = '70'
  and    co.county_code = ct.province_code
  and    co.county_code = pc.county_code
  and    pc.state_code = '70'
  and    ct.city_code  = pc.city_code
  and    ct.city_name  = p_city_name
  and    co.county_abbrev = p_county_name
  and substr(p_zip_code,1,3) between substr(pc.zip_start,1,3) and substr(pc.zip_end,1,3)
  and substr(p_zip_code,5,3) between '0A0' and '9Z9';
--
/*
  select count(*)
  from   pay_ca_provinces_v pr
  ,      pay_ca_cities_v ct
  ,      pay_ca_postal_codes_v pc
  where  pr.province_code = ct.province_code
  and    pr.province_code = pc.province_code
  and    ct.city_code = pc.city_code
  and    ct.city_name = p_city_name
  and    pr.province_abbrev = p_county_name
  and    substr(p_zip_code,1,3) between substr(pc.code_start,1,3)
                                    and substr(pc.code_end,1,3)
  and    substr(p_zip_code,5,3) between '0A0' and '9Z9';
*/

begin
    IF length(p_zip_code) <> 7 THEN
       l_hr_addr := hr_us_ff_udfs.addr_val (p_state_abbrev
                                           ,p_county_name
                                           ,p_city_name
                                           ,p_zip_code
                                           ,'Y');
        if (l_hr_addr = '00-000-0000') then
            --
            insert into per_us_inval_locations (location_id)
            values (p_location_id);
            commit;
        end if;
    ELSIF length(p_zip_code) = 7 THEN
        /* For Canada p_city_name = City Name,
                      p_county_name = Province Abbreviation,
                      p_zip_code = Postal Code */
        OPEN ca_locations(p_city_name, p_county_name, p_zip_code);
        FETCH ca_locations INTO l_loc_valid;
        IF l_loc_valid = 0  THEN
             insert into per_us_inval_locations (location_id)
             values (p_location_id);
            commit;
        END IF;
        CLOSE ca_locations;
     END IF;

end inval_hr_addr;


PROCEDURE  chkzipcode is
      cursor perzipcur is
 select per.address_id,
        per.region_1,
        per.region_2,
        per.town_or_city,
        per.postal_code
 from   per_addresses per
 where  per.style in ('US','CA') or per.country in ('US','CA') ;--Added for Bug#8982883

--
     cursor hrzipcur is
 select hr.location_id,
        hr.region_1,
        hr.region_2,
        hr.town_or_city,
        hr.postal_code
 from   hr_locations_all hr
 where  hr.style in ('US','CA') or hr.country in ('US','CA') ;--Added for Bug#8982883

 type  hrlocrow is record
  (
    location_id         hr_locations_all.location_id%TYPE,
    region_1            hr_locations_all.region_1%TYPE,
    region_2            hr_locations_all.region_2%TYPE,
    town_or_city        hr_locations_all.town_or_city%TYPE,
    postal_code         hr_locations_all.postal_code%TYPE

    /* commented to change the type
    location_id  	number(15),
    region_1      	varchar2(70),
    region_2    	varchar2(70),
    town_or_city	varchar2(60),
    postal_code		varchar2(60)*/
  );



 type  peraddrow is record
  (
    address_id          per_addresses.address_id%TYPE,
    region_1            per_addresses.region_1%TYPE,
    region_2            per_addresses.region_2%TYPE,
    town_or_city        per_addresses.town_or_city%TYPE,
    postal_code         per_addresses.postal_code%TYPE

    /* Commented to change the type of the variables
    address_id  	number(15),
    region_1		varchar2(70),
    region_2		varchar2(70),
    town_or_city	varchar2(30),
    postal_code		varchar2(30)*/

  );

l_hrlocs  		hrlocrow;
l_peraddr		peraddrow;

begin

    open hrzipcur;
    loop
	fetch hrzipcur into l_hrlocs;
	exit when  hrzipcur%notfound;
        --
        --
    begin
	-- call the inval_hr_addr  procedure.
        inval_hr_addr (l_hrlocs.location_id
                      ,l_hrlocs.region_2
		      ,l_hrlocs.region_1
                      ,l_hrlocs.town_or_city
		      ,l_hrlocs.postal_code);
        --
     exception
	when others then
	hr_utility.oracle_error(sqlcode);
        --
    end;
    end loop;
    close hrzipcur;

--
--
-- Now get all the invalid per_ addresses
--

    open perzipcur;
    loop
	fetch perzipcur into l_peraddr;
	exit when  perzipcur%notfound;
--
--
-- Call the inval_per_addr procedure

    begin
        inval_per_addr (l_peraddr.address_id
                       ,l_peraddr.region_2
                       ,l_peraddr.region_1
                       ,l_peraddr.town_or_city
		       ,l_peraddr.postal_code);

    exception
	when others then
	hr_utility.oracle_error(sqlcode);

    end;
    end loop;
    close perzipcur;

end chkzipcode;


end HR_US_PYZIPCHK;

/
