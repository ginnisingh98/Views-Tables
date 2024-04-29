--------------------------------------------------------
--  DDL for Package Body PER_US_ETHNIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_ETHNIC" AS
/* $Header: peusethnic.pkb 120.0.12000000.1 2007/02/06 14:47:41 appldev noship $ */
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

    Name        : per_us_ethnic

    Description : Package that updates ethnic code 9 to ethnic
                  code 3 for 2007.

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     29-OCT-06   ssouresr  115.0             Created
*/

procedure ethnic_code_upd (errbuf     out nocopy varchar2,
                           retcode    out nocopy number)
is
  ln_business_group_id       NUMBER;
  lv_business_group_name     VARCHAR2(400);
  lv_exists                  VARCHAR2(1);

  v_errortext        varchar2(512);
  v_errorcode        number;

  cursor get_all_bgs is
  select hoi.organization_id, hou.name
  from   hr_organization_units hou,
         hr_organization_information hoi,
         hr_organization_information hoi1
  where hoi.org_information_context = 'Business Group Information'
  and hoi.org_information9 = 'US'
  and hou.organization_id = hoi.organization_id
  and hou.organization_id = hoi1.organization_id
  and hoi1.org_information_context = 'CLASS'
  and hoi1.org_information1 = 'HR_BG'
  and hoi1.org_information2 = 'Y';

begin

   open get_all_bgs;
   loop
      fetch get_all_bgs into ln_business_group_id, lv_business_group_name;
      if get_all_bgs%notfound then
         exit;
      end if;

      UPDATE per_all_people_f
      SET per_information1 = '3'
      WHERE per_information1 = '9'
      AND   business_group_id = ln_business_group_id;

   end loop;
   close get_all_bgs;

   exception
   when others then
       v_errorcode := SQLCODE;
       v_errortext := SQLERRM;
       hr_utility.trace('Error during update process: ' || v_errortext || ' ' || v_errorcode);
       errbuf      := v_errortext;
       retcode     := v_errorcode;
       rollback;

end; -- end of ethnic_code_upd

END per_us_ethnic; -- end of package

/
