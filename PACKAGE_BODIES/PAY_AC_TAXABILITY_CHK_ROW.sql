--------------------------------------------------------
--  DDL for Package Body PAY_AC_TAXABILITY_CHK_ROW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AC_TAXABILITY_CHK_ROW" as
/* $Header: paytaxrulchkrow.pkb 120.0 2005/09/10 03:50 psnellin noship $ */

/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Package Body Name : pay_ac_taxability_chk_row
    Package File Name : paytaxrulchkrow.pkb
    Description : This package declares functions and procedures
                  which supports US and CA taxability rules upload
                  via spread sheet loader.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    21-JUN-04   fusman      115.0             Created
 *******************************************************************/


 -- Package Variables
 g_package varchar2(100);
 TYPE character_data_table IS TABLE OF VARCHAR2(280)
                               INDEX BY BINARY_INTEGER;

  ltt_state_code       character_data_table;
  ltt_state_abbrev     character_data_table;
  ltt_county_code      character_data_table;
  ltt_county_name      character_data_table;
  ltt_city_code        character_data_table;
  ltt_city_name        character_data_table;


FUNCTION get_state_name
           (p_jurisdiction_code IN  VARCHAR2)
  RETURN VARCHAR2
  IS

  cursor get_state_names
  is
  select state_abbrev,state_code
  from pay_us_states
  where state_code  <= '51';


  l_state_abbrev varchar2(2) := '';

  Begin
        hr_utility.trace('Before ltt_state_abbrev Loop');
       for i in 1..ltt_state_abbrev.COUNT
       Loop
            if substr(p_jurisdiction_code,1,2) = ltt_state_code(i) then
               hr_utility.trace('state_abbrev = '||ltt_state_abbrev(i));
               return ltt_state_abbrev(i);

            end if;

       end loop;
        hr_utility.trace('After ltt_state_abbrev Loop');

       for strec in get_state_names
       Loop
          ltt_state_abbrev(strec.state_code) := strec.state_abbrev;
          ltt_state_code(strec.state_code) := strec.state_code;
          hr_utility.trace('state_abbrev = '||ltt_state_abbrev(strec.state_code));
           if substr(p_jurisdiction_code,1,2) = strec.state_code then
              hr_utility.trace('In strec Loop');
              l_state_abbrev := strec.state_abbrev;
           end if;

       end loop;

     return l_state_abbrev;
  End;



FUNCTION get_county_city_name
             (p_jurisdiction_code IN  VARCHAR2,
              p_county_or_city    IN  VARCHAR2)
  RETURN VARCHAR2
  IS

  cursor get_state_names(cp_jurisdiction_code VARCHAR2)
  is
  select state_abbrev
  from pay_us_states
  where state_code <= '51';

  cursor get_city_names(cp_state_code VARCHAR2,
                        cp_city_code  VARCHAR2)
  is
  select city_name
  from pay_us_city_names
  where state_code = cp_state_code
  and city_code = cp_city_code
  and primary_flag = 'Y';

  cursor get_county_names(cp_state_code VARCHAR2,
                          cp_county_code  VARCHAR2)
  is
  select county_name
  from pay_us_counties
  where state_code = cp_state_code
  and county_code = cp_county_code;

  l_county_name varchar2(100);
  l_city_name varchar2(100);

  Begin

     if substr(p_jurisdiction_code,8,4)='0000' then

        open get_county_names(substr(p_jurisdiction_code,1,2),
                              substr(p_jurisdiction_code,4,3));
        fetch get_county_names into l_county_name;
        close get_county_names;

        if p_county_or_city = 'COUNTY' then

           return l_county_name;

        else

           return '';

        end if;


     elsif substr(p_jurisdiction_code,4,3) = '000' then

        open get_city_names(substr(p_jurisdiction_code,1,2),
                            substr(p_jurisdiction_code,8,4));
        fetch get_city_names into l_city_name;
        close get_city_names;

        if p_county_or_city = 'CITY' then

           return l_city_name;

        else

          return '';

        end if;

     end if;




  End;

  /************************************************************
  ** Function called for US Federal Context is passed
  ************************************************************/
  FUNCTION get_taxability_rule_row
                 (p_legislation_code  IN  VARCHAR2,
                  p_tax_type          IN  VARCHAR2,
                  p_tax_category    IN  VARCHAR2,
                  p_classification_id IN NUMBER,
                  p_jurisdiction_code IN  VARCHAR2)
  RETURN VARCHAR2

  IS

  cursor check_taxability_rule_row(cp_legislation_code  VARCHAR2,
                                   cp_tax_type VARCHAR2,
                                   cp_tax_category VARCHAR2,
                                   cp_classification_id NUMBER ,
                                   cp_jurisdiction_code VARCHAR2)
  is
  SELECT nvl(status,'Y')
  FROM pay_taxability_rules
  where  tax_type = cp_tax_type
  and tax_category =  cp_tax_category
  and classification_id = cp_classification_id
  and jurisdiction_code = cp_jurisdiction_code
  and legislation_code = cp_legislation_code;

  l_status varchar2(10);

  BEGIN

    open check_taxability_rule_row(p_legislation_code,
                                   p_tax_type,
                                   p_tax_category,
                                   p_classification_id,
                                   p_jurisdiction_code);

    fetch check_taxability_rule_row into l_status;

       if check_taxability_rule_row%NOTFOUND then

          close check_taxability_rule_row;
          return null;

       end if;

       If l_status = 'D' then

          return 'N';

       elsif l_status = 'Y' then

          return l_status;

       end if;

    close check_taxability_rule_row;


  END;


BEGIN
  g_package := 'pay_ac_taxability_chk_row.';
--  hr_utility.trace_on(null,'tax_api');
end pay_ac_taxability_chk_row;

/
