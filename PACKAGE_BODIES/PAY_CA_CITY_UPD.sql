--------------------------------------------------------
--  DDL for Package Body PAY_CA_CITY_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_CITY_UPD" AS
/* $Header: pycactup.pkb 115.3 2003/03/12 19:42:09 ssouresr noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1999 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_ca_city_upd

    Description : Package that is used to update Canadian city names
                  to their correct French Canadian spelling.

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     23-DEC-02   ssouresr  115.0   2428688   Created.
     15-JAN-03   ssouresr  115.1             Modified to make compatible
                                             with Oracle 8i
     17-JAN-03   ssouresr  115.2             truncated translated names to 30
                                             characters
     07-MAR-03   ssouresr  115.3             Remove duplicate cities on
                                             pay_us_city_names. Also committing
                                             updates in batches.
*/

FUNCTION prov_abbrev (p_county_code  in varchar2)
RETURN varchar2 IS
  v_prov_abbrev  varchar2(5);
BEGIN

    SELECT county_abbrev
    INTO  v_prov_abbrev
    FROM  pay_us_counties
    WHERE county_code = p_county_code
    AND   state_code = '70';

    RETURN v_prov_abbrev;

END;

FUNCTION get_derived_locale (p_town_or_city  in varchar2,
                             p_country       in varchar2)
RETURN varchar2  IS
  v_derived_locale    varchar2(240);
  v_separator         varchar2(10);
BEGIN
     IF (ltrim(p_town_or_city) IS NULL) OR
        (ltrim(p_country) IS NULL) THEN
           v_separator := '';
     ELSE
           v_separator := ', ';
     END IF;

     v_derived_locale := ltrim(p_town_or_city) || v_separator || ltrim(p_country);

     RETURN v_derived_locale;
END;


PROCEDURE cityname_bulk_upd (errbuf     out nocopy varchar2,
                             retcode    out nocopy number)
IS
  CURSOR city_mappings IS
  SELECT city_name,
         county_code,
         city_code,
         display_city_name
  FROM pay_ca_display_cities;

  CURSOR duplicate_cities IS
  SELECT DISTINCT
          pdc1.display_city_name,
          pdc1.city_name,
          pdc1.county_code,
          pdc1.city_code,
          pcn.primary_flag
  FROM  pay_ca_display_cities pdc1,
        pay_ca_display_cities pdc2,
        pay_us_city_names     pcn
  WHERE pdc1.city_code         = pdc2.city_code
  AND   pdc1.county_code       = pdc2.county_code
  AND   pdc1.display_city_name = pdc2.display_city_name
  AND   pdc1.city_name        <> pdc2.city_name
  AND   pdc1.city_code    = pcn.city_code
  AND   pdc1.county_code  = pcn.county_code
  AND   pdc1.city_name    = pcn.city_name
  AND   pcn.state_code    = '70'
  ORDER BY pdc1.display_city_name, pcn.primary_flag DESC;

  CURSOR translation_exists IS
  SELECT  pdc.city_name,
          pdc.county_code,
          pdc.city_code
  FROM  pay_us_city_names     pcn,
        pay_ca_display_cities pdc
  WHERE pcn.state_code  = '70'
  AND   pcn.county_code = pdc.county_code
  AND   pcn.city_code   = pdc.city_code
  AND   pcn.city_name   = pdc.display_city_name;


  v_prov             prov_list;
  v_county_code      county_code_list;
  v_city_code        city_code_list;
  v_old_city         old_city_name_list;
  v_new_city         new_city_name_list;

  v_dup_old_city     old_city_name_list;
  v_dup_new_city     new_city_name_list;
  v_dup_city_code    city_code_list;
  v_dup_county_code  county_code_list;
  v_dup_primary_flag primary_flag_list;

  v_current_city     varchar2(90);

  v_exists_city        old_city_name_list;
  v_exists_city_code   city_code_list;
  v_exists_county_code county_code_list;

  v_old_row_count    number   := 0;
  v_new_row_count    number   := 0;
  v_rows_in_collect  number   := 0;
  v_commit_limit     natural  := 200;

  v_errortext        varchar2(512);
  v_errorcode        number;

BEGIN
--   hr_utility.trace_on(1,'Oracle');

     hr_utility.trace('Starting cityname_bulk_upd ');

     OPEN duplicate_cities;
     FETCH duplicate_cities BULK COLLECT INTO
        v_dup_new_city,
        v_dup_old_city,
        v_dup_county_code,
        v_dup_city_code,
        v_dup_primary_flag;

     CLOSE duplicate_cities;

     hr_utility.trace('Loaded all duplicate city name mappings from pay_ca_display_cities');

     IF v_dup_new_city.COUNT > 0 THEN

         FOR j IN v_dup_new_city.first..v_dup_new_city.last LOOP

           IF v_current_city = v_dup_new_city(j) THEN

              DELETE pay_us_city_names
              WHERE  city_code    = v_dup_city_code(j)
              AND    county_code  = v_dup_county_code(j)
              AND    city_name    = v_dup_old_city(j)
              AND    state_code   = '70'
              AND    primary_flag = 'N';

           ELSE
              v_current_city := v_dup_new_city(j);
           END IF;

         END LOOP;

     END IF;

     hr_utility.trace('Completed deletion of duplicate cities from pay_us_city_names ');

     OPEN translation_exists;
     FETCH translation_exists BULK COLLECT INTO
        v_exists_city,
        v_exists_county_code,
        v_exists_city_code;

     CLOSE translation_exists;

     hr_utility.trace('Loaded all existing city name translations');

     IF v_exists_city.COUNT > 0 THEN

         FORALL j IN v_exists_city.first..v_exists_city.last
         DELETE pay_us_city_names
         WHERE  city_code    = v_exists_city_code(j)
         AND    county_code  = v_exists_county_code(j)
         AND    city_name    = v_exists_city(j)
         AND    state_code   = '70';

     END IF;

     hr_utility.trace('Completed bulk deletion of cities which have existing translations ');

     OPEN city_mappings;
     LOOP
          FETCH city_mappings BULK COLLECT INTO
             v_old_city,
             v_county_code,
             v_city_code,
             v_new_city
          LIMIT v_commit_limit;

          v_old_row_count  := v_new_row_count;
          v_new_row_count  := city_mappings%ROWCOUNT;

          v_rows_in_collect := v_new_row_count - v_old_row_count;

          EXIT WHEN (v_rows_in_collect = 0);

          hr_utility.trace('Loaded batch of city name mappings from pay_ca_display_cities');

          IF v_old_city.COUNT > 0 THEN

               FOR j IN v_old_city.first..v_old_city.last LOOP
                  v_prov(j)        := prov_abbrev(v_county_code(j));
               END LOOP;

               hr_utility.trace('Starting bulk update on per_addresses ');

               FORALL j IN v_old_city.first..v_old_city.last
               UPDATE per_addresses
               SET town_or_city   = substrb(v_new_city(j),1,30),
                   derived_locale = decode(derived_locale, NULL, NULL,
                                           get_derived_locale(v_new_city(j),country))
               WHERE region_1     = v_prov(j)
               AND   town_or_city = v_old_city(j)
               AND   style        = 'CA';

               COMMIT;

               hr_utility.trace('Starting bulk update on hr_locations_all ');

               FORALL j IN v_old_city.first..v_old_city.last
               UPDATE hr_locations_all
               SET town_or_city   = substrb(v_new_city(j),1,30),
                   derived_locale = decode(derived_locale, NULL, NULL,
                                           get_derived_locale(v_new_city(j),country))
               WHERE region_1     = v_prov(j)
               AND   town_or_city = v_old_city(j)
               AND   style        = 'CA';

               COMMIT;

               hr_utility.trace('Starting bulk update on pay_us_city_names ');

               FORALL j IN v_old_city.first..v_old_city.last
               UPDATE pay_us_city_names
               SET  city_name     = substrb(v_new_city(j),1,30)
               WHERE county_code  = v_county_code(j)
               AND   city_name    = v_old_city(j)
               AND   city_code    = v_city_code(j)
               AND   state_code   = '70';

               COMMIT;

          END IF;

     END LOOP;

     hr_utility.trace('Completed update on per_addresses,hr_locations_all and pay_us_city_names');

     CLOSE city_mappings;

     EXCEPTION
     WHEN OTHERS THEN
          v_errorcode := SQLCODE;
          v_errortext := SQLERRM;
          hr_utility.trace('Error during update process: ' || v_errortext || ' ' || v_errorcode);
          errbuf      := v_errortext;
          retcode     := v_errorcode;
          ROLLBACK;

END; -- end of cityname_bulk_upd

END pay_ca_city_upd; -- end of package

/
