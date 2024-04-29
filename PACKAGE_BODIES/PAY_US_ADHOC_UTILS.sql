--------------------------------------------------------
--  DDL for Package Body PAY_US_ADHOC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ADHOC_UTILS" AS
/* $Header: pyusdisc.pkb 120.2 2005/06/03 06:50:06 sdhole noship $ */
/* ******************************************************************
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

    Name        : PAY_US_ADHOC_UTILS

    Description : This package is created for the discoverer W2
		  (Year End) Reporting purpose for getting the
		  details about common pay agent, locality name
		  In future we can use the same package by adding
		  more functions for other reporting purpose also.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -----------------------------------
    09-NOV-2004 sdhole     115.0            Created.
    09-NOV-2004 sdhole	   115.1	    added function
					    get_secprofile_bg_id.
    26-APR-2005            115.3   4226022  Removed the code added in 115.2
                                            version and it has been moved
					    to PAY_ADHOC_UTILS_PKG.
    26-APR-2005 sdhole     115.4   4226022  Added function
                                            get_balance_valid_load_date.
    30-MAY-2005 sdhole     115.5   4400526  Modified get_balance_valid_load_date
                                            function.
    03-JUN-2005 sdhole     115.6   4400526  Code for the function
                                            get_balance_valid_load_date moved to
                                            PAY_ADHOC_UTILS_PKG. No longer needed
                                            in US utils package.
    ---------------------------------------------------------------------------
*/
function get_locality_name(p_tax_type        VARCHAR2,
                           p_state_abbrev    VARCHAR2,
                           p_assig_action_id NUMBER,
                           p_locality_name   VARCHAR2,
                           p_jurisdiction    VARCHAR2) return varchar2 IS

V_nr_flag        VARCHAR2(100);
V_nr_jd          VARCHAR2(100);
v_locality_name  varchar2(100);

BEGIN
      v_locality_name := p_locality_name;

       if ( p_tax_type = 'CITY SCHOOL' or p_tax_type = 'COUNTY SCHOOL') then
           if p_state_abbrev = 'OH' then
              v_locality_name := substr(p_jurisdiction,5,4)||' '
                                     ||substr(p_locality_name,1,8);
           elsif p_state_abbrev = 'KY' then
               v_locality_name := substr(p_jurisdiction,7,2)||' '
                                     ||substr(p_locality_name,1,10);
           else
               v_locality_name := substr(p_jurisdiction,4,5)||' '
                                     ||substr(p_locality_name,1,7);
           end if;
       end if;

       if (p_state_abbrev = 'IN' and p_tax_type = 'COUNTY') then
         begin
	      select nvl(value,'N') into v_nr_flag
	      from   ff_database_items fdi,
	             ff_archive_items fai
              where user_name = 'A_IN_NR_FLAG'
              and fdi.user_entity_id = fai.user_entity_id
              and fai.context1 = p_assig_action_id;

          if v_nr_flag = 'N' then
              begin
                   select nvl(value,'00-000-0000') into v_nr_jd
                   from   ff_database_items fdi,
                          ff_archive_items fai
                   where  fdi.user_name = 'A_IN_RES_JD'
                          and fdi.user_entity_id = fai.user_entity_id
                          and context1 = p_assig_action_id;

                 if substr(p_jurisdiction,1,2) = '15' then
                     if v_nr_jd <> p_jurisdiction then
                        v_locality_name := 'NR '||substr(p_locality_name,1,10);
                     end if;
                 end if;
              exception
		   when others then
                        null;
             end;
          end if;
        exception
	      when others then
                   null;
        end;
      end if;

  RETURN(v_locality_name);
End get_locality_name;
--
--
function get_common_pay_agent_id(p_year varchar2) return number is
v_agent_tax_unit_id  number;
v_error_msg          varchar2(2000);
begin
   hr_us_w2_rep.get_agent_tax_unit_id(hr_security.get_sec_profile_bg_id
                                     ,p_year
                                     ,v_agent_tax_unit_id
                                     ,v_error_msg);
   return(v_agent_tax_unit_id);
--
exception
	when others then
	     return(null);
end get_common_pay_agent_id;
--
--
function get_commonpay_agent_details(p_year varchar2,
                                     p_commonpay_agent_id number,
                                     p_type varchar2) return varchar2 is
v_name  varchar2(1000);

begin
  -- Pass the p_type = 'EIN'  to get the Employer Identification
  -- Pass the p_type = 'NAME' to get the 2678 name.

  if   p_type = 'EIN' then
       SELECT FEDERAL_EIN into v_name
       from pay_us_w2_tax_unit_v
       where TAX_UNIT_ID = p_commonpay_agent_id
       and   year        = p_year;

  elsif p_type = 'NAME' then

      SELECT tax_unit_name into v_name
      from pay_us_w2_tax_unit_v
      where TAX_UNIT_ID = p_commonpay_agent_id
      and   year        = p_year;
  end if;
return(v_name);
exception
   when others then
        return(null);
end get_commonpay_agent_details;
--
--
  FUNCTION get_secprofile_bg_id
      RETURN   per_security_profiles.business_group_id%TYPE IS

  BEGIN

    RETURN hr_security.get_sec_profile_bg_id;

  END get_secprofile_bg_id;
--
--
END PAY_US_ADHOC_UTILS;

/
