--------------------------------------------------------
--  DDL for Package Body PAY_PAYSLIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSLIP_UTIL" as
/* $Header: paypaysliputil.pkb 120.1.12010000.2 2009/03/31 10:25:30 sudedas ship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used for all functions and procedures
                for Online Payslip for all legislations.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   02-FEB-2004  vpandya     115.0            Created.
   04-FEB-2004  vpandya     115.1            Changed get_id_for_employer_address
   26-JUN-2006  sodhingr    115.2 5033776    added new function, get_leg_rule_state
   31-MAR-2009  sudedas     115.3 3816988    Changed get_id_for_employer_address.
                                             Introduced separate code for US.
*/
--

  /*********************************************************************
   Name      : get_legislation_code
   Purpose   : This function returns the legislation code for a given
               Business Group ID.
   Arguments : IN
               p_business_group_id   number
   Notes     :
  *********************************************************************/

  FUNCTION get_legislation_code( p_business_group_id   in number )
  RETURN VARCHAR2
  IS

    cursor get_legi_cd(cp_business_group_id number) is
      select org_information9
       from  hr_organization_information
      where  organization_id         = cp_business_group_id
        and  org_information_context = 'Business Group Information';

    lv_legislation_code varchar2(30) := NULL;

  BEGIN

     open  get_legi_cd(p_business_group_id);
     fetch get_legi_cd into lv_legislation_code;
     close get_legi_cd;

     return(lv_legislation_code);

  END get_legislation_code;

  /************************************************************************
   Name      : get_employer_addr
   Purpose   : This functtion is being called by PAY_EMPLOYEE_ACTION_INFO_V
               view using argument mentioned below.

               This function returns Organization ID or Tax Unit ID (GRE ID)
               based on entry in pay_legislative_field_info table.

   Arguments : IN
               p_business_group_id   number
               p_tax_unit_id         number
               p_action_info2        varchar2
               p_effective_date      date default '01-JAN-1990'

   Notes     : This would be defaulted to Organization ID.
  ************************************************************************/

  FUNCTION get_id_for_employer_address( p_business_group_id in number
                                       ,p_tax_unit_id       in number
                                       ,p_organization_id   in number
                                       ,p_effective_date    in date default fnd_date.canonical_to_date('1990/01/01'))
  RETURN NUMBER IS

  cursor get_legi_rule(cp_legislation_code varchar2) is
    select rule_mode
      from pay_legislative_field_info
     where legislation_code = cp_legislation_code
       and field_name       = 'CHOOSE_PAYSLIP'
       and validation_name  = 'ITEM_PROPERTY'
       and validation_type  = 'DISPLAY'
       and target_location  = 'PAY_PAYSLIP'
       and rule_type        = 'PAYSLIP_EMPLYR_ADDR';

   cursor c_get_payslip_date_from(cp_business_group_id number) is
     select hoi.org_information10
           ,fnd_date.canonical_to_date(hoi.org_information11)
       from hr_organization_information hoi
      where hoi.organization_id = cp_business_group_id
        and hoi.org_information_context like 'HR_SELF_SERVICE_BG_PREFERENCE'
        and hoi.org_information1 = 'PAYSLIP';

    lv_employer_type        varchar2(100);
    ld_payslip_eff_dt       date;

  BEGIN

  hr_utility.trace('Entered into get_id_for_employer_address.');
  hr_utility.trace('Parameter p_business_group_id := ' || p_business_group_id);
  hr_utility.trace('Parameter p_tax_unit_id := ' || p_tax_unit_id);
  hr_utility.trace('Parameter p_organization_id := ' || p_organization_id);
  hr_utility.trace('Parameter p_effective_date := ' || TO_CHAR(p_effective_date));

  /* Following section of code has been introduced for US legislation
     to enable display of GRE Address on payslip. In addition to leg
     rule US has introduced 2 DFF segments under BG > Self Service Prefernces.
     Depending on the "Display Payslip GRE Addr From" field value,
     system decides which Employer Address to use : HR Org or GRE Address.
     Keeping this code separate for US since other localizations need
     these additional DFF configuration in case they have rule_type set as
     GRE already. Later would be discussed to have a generic code if needed.
  */


  /* Following code is common and will be fired for ALL legislations
  */

  IF gv_employer_addr_cd IS NULL THEN

     IF gv_legislation_code IS NULL THEN
        gv_legislation_code := get_legislation_code(p_business_group_id);
     END IF;

     gv_employer_addr_cd := 'ORG';

     OPEN  get_legi_rule(gv_legislation_code);
     FETCH get_legi_rule into gv_employer_addr_cd;
     CLOSE get_legi_rule;

  END IF;

  hr_utility.trace('gv_employer_addr_cd := ' || gv_employer_addr_cd);
  hr_utility.trace('gv_legislation_code := ' || gv_legislation_code);

  IF gv_legislation_code = 'US' THEN

    hr_utility.trace('Code specific to US legislation.');

    IF p_tax_unit_id IS NULL and p_organization_id IS NOT NULL THEN
       return (p_organization_id);
    ELSIF p_tax_unit_id IS NOT NULL and p_organization_id IS NULL THEN
        return(p_tax_unit_id);
    END IF;

    IF gv_employer_addr_cd = 'GRE' THEN

       OPEN c_get_payslip_date_from(p_business_group_id);
       FETCH c_get_payslip_date_from INTO lv_employer_type, ld_payslip_eff_dt;
       CLOSE c_get_payslip_date_from;

       hr_utility.trace('lv_employer_type := ' || lv_employer_type);
       hr_utility.trace('ld_payslip_eff_dt := ' || TO_CHAR(ld_payslip_eff_dt));

       IF lv_employer_type = 'G' AND p_effective_date >= ld_payslip_eff_dt THEN
          return(p_tax_unit_id);
       ELSE
          return(p_organization_id);
       END IF; -- lv_employer_type <> 'G' OR p_effective_date < ld_payslip_eff_dt
    ELSE
        return(p_organization_id);
    END IF; -- gv_employer_addr_cd = 'ORG'

  /* Keeping the code intact for other legislations
  */

  ELSE

    IF p_tax_unit_id IS NULL and p_organization_id IS NOT NULL THEN
       return (p_organization_id);
    ELSIF p_tax_unit_id IS NOT NULL and p_organization_id IS NULL THEN
       return(p_tax_unit_id);
    END IF;

    IF gv_employer_addr_cd IS NULL THEN

       IF gv_legislation_code IS NULL THEN
          gv_legislation_code := get_legislation_code(p_business_group_id);
       END IF;

       gv_employer_addr_cd := 'ORG';

       OPEN  get_legi_rule(gv_legislation_code);
       FETCH get_legi_rule into gv_employer_addr_cd;
       CLOSE get_legi_rule;

    END IF;

    IF gv_employer_addr_cd = 'GRE' THEN
       return(p_tax_unit_id);
    ELSE
       return(p_organization_id);
    END IF;
  END IF;

  END get_id_for_employer_address;


  FUNCTION get_leg_rule_state(p_business_group_id in number)
  RETURN VARCHAR2 IS

  cursor get_legislative_rule(cp_legislation_code varchar2) is
    select rule_mode
      from pay_legislative_field_info
     where legislation_code = gv_legislation_code
       and field_name       = 'ACTION_INFO_STATE'
       and validation_name  = 'ITEM_PROPERTY'
       and validation_type  = 'DISPLAY'
       and target_location  = 'PAY_PAYSLIP'
       and rule_type        = 'ACTION_INFO_STATE';

    l_rule_mode          VARCHAR2(50);
    lv_legislation_code   varchar2(3);

  BEGIN
      --hr_utility.trace_on(null,'payslip_util');
       hr_utility.trace(gv_legislation_code);

       lv_legislation_code := get_legislation_code(p_business_group_id);

       hr_utility.trace('lv_legislation_code ' ||lv_legislation_code);

       OPEN  get_legislative_rule(lv_legislation_code);
       FETCH get_legislative_rule into l_rule_mode;
       CLOSE get_legislative_rule;


       hr_utility.trace('l_rule_mode '||l_rule_mode);
        return l_rule_mode;

  END get_leg_rule_state;

END pay_payslip_util;

/
