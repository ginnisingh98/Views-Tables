--------------------------------------------------------
--  DDL for Package Body PAY_AC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AC_UTIL" AS
/* $Header: pyacdisc.pkb 115.1 2004/02/16 16:03:59 vpandya noship $ */
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

    Name        : pay_ac_util

    Description : Package contains functions and procedures used
                  by Discoverer

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
   27-OCT-2003  asasthan  115.0           Created
   16-FEB-2004  vpandya   115.1           Gross to Net Adhoc, Added functions
                                          get_def_bal_for_seeded_bal and
                                          get_value.

***********************************************************************/
g_currency_code varchar2(240) := NULL;

FUNCTION get_legis_parameter(p_parameter_name in varchar2,
                             p_parameter_list varchar2) return number
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
  ln_parameter_id number :=0;
begin

     token_val := p_parameter_name||'=';

     start_ptr := instr(p_parameter_list, token_val) + length(token_val);
     end_ptr := instr(p_parameter_list, ' ',start_ptr);


    /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(p_parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(p_parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(p_parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
     ln_parameter_id := to_number(par_value);
     return ln_parameter_id;

end get_legis_parameter;



 /*********************************************************************
   Name      : get_jurisdiction_name
   Purpose   : This function returns the name of the jurisdiction
               If Jurisdiction_code is like 'XX-000-0000' then
                  it returns State Name from py_us_states
               If Jurisdiction_code is like 'XX-XXX-0000' then
                   it returns County Name from paY_us_counties
               If Jurisdiction_code is like 'XX-XXX-XXXX' then
                   it returns City Name from pay_us_city_name
               If Jurisdiction_code is like 'XX-XXXXX' then
                   it returns School Name from pay_us_school_dsts
               In case jurisdiction code could not be found relevent
               table then NULL is returned.
   Arguments : p_jurisdiction_code
   Notes     :
  *********************************************************************/
  FUNCTION get_jurisdiction_name(p_jurisdiction_code in varchar2)

  RETURN VARCHAR2
  IS

    cursor c_get_state(cp_state_code in varchar2) is
       select state_abbrev
         from pay_us_states
        where state_code  = cp_state_code;

    cursor c_get_county( cp_state_code in varchar2
                         ,cp_county_code in varchar2
                       ) is
       select county_name
         from pay_us_counties
        where state_code  = cp_state_code
          and county_code = cp_county_code;

    cursor c_get_city( cp_state_code  in varchar2
                      ,cp_county_code in varchar2
                      ,cp_city_code   in varchar2
                       ) is
       select city_name
         from pay_us_city_names
        where state_code    = cp_state_code
          and county_code   = cp_county_code
          and city_code     = cp_city_code
          and primary_flag  = 'Y';

    lv_state_code        VARCHAR2(2)  := substr(p_jurisdiction_code,1,2);
    lv_county_code       VARCHAR2(3)  := substr(p_jurisdiction_code,4,3);
    lv_city_code         VARCHAR2(4)  := substr(p_jurisdiction_code,8,4);
    lv_jurisdiction_name VARCHAR2(240):= null;

    lv_procedure_name  VARCHAR2(50) := '.get_jurisdiction_name' ;
  BEGIN
      if p_jurisdiction_code like '__-000-0000' then
         open c_get_state(lv_state_code);
         fetch c_get_state into lv_jurisdiction_name;
         close c_get_state;
      elsif p_jurisdiction_code like '__-___-0000' then
         open c_get_county(lv_state_code
                           ,lv_county_code);
         fetch c_get_county into lv_jurisdiction_name;
         close c_get_county;
      elsif p_jurisdiction_code like '__-___-____' then
         open c_get_city( lv_state_code
                         ,lv_county_code
                         ,lv_city_code);
         fetch c_get_city into lv_jurisdiction_name;
         close c_get_city;
      elsif p_jurisdiction_code like '__-_____' then
          -- this is school district make a function call
         lv_jurisdiction_name
                 := pay_us_employee_payslip_web.get_school_dsts_name(p_jurisdiction_code);
      end if;

      return (lv_jurisdiction_name);
  END get_jurisdiction_name;



 /*********************************************************************
   Name      : get_state_abbrev
   Purpose   : This function returns the state abbrev for the jurisdiction
   Arguments : p_jurisdiction_code
   Notes     :
  *********************************************************************/
  FUNCTION get_state_abbrev(p_jurisdiction_code in varchar2)

  RETURN VARCHAR2
  IS

    cursor c_get_state(cp_state_code in varchar2) is
       select state_abbrev
         from pay_us_states
        where state_code  = cp_state_code;

    lv_state_code        VARCHAR2(2)  := substr(p_jurisdiction_code,1,2);
    lv_state_abbrev VARCHAR2(2):= null;

  BEGIN

         open c_get_state(lv_state_code);
         fetch c_get_state into lv_state_abbrev;
         close c_get_state;
      return (lv_state_abbrev);
  END get_state_abbrev;

 /************************************************************
  Name      : get_format_value
  purpuse   : given a value, it formats the value to a given
              currency_code and precision.
  arguments : p_business_group_id, p_value
  notes     :
 *************************************************************/
 FUNCTION get_format_value(p_business_group_id in number,
                           p_value in number)
 RETURN varchar2 IS

  lv_formatted_number varchar2(50);

  CURSOR c_currency_code is
  select hoi.org_information10
  from hr_organization_units hou,
       hr_organization_information hoi
  where hou.business_group_id = p_business_group_id
    and hou.organization_id = hoi.organization_id
    and hoi.org_information_context = 'Business Group Information';

  BEGIN
    IF g_currency_code is null THEN
       OPEN c_currency_code;
       FETCH c_currency_code into g_currency_code;
       CLOSE c_currency_code;
    END IF;
    IF g_currency_code is not null THEN
       lv_formatted_number := to_char(p_value,
                                     fnd_currency.get_format_mask(
                                         g_currency_code,40));
    ELSE
       lv_formatted_number := p_value;
    END IF;

    return lv_formatted_number;

  EXCEPTION
    when others then
      return p_value;
  END get_format_value;

  FUNCTION get_consolidation_set(p_business_group_id  in number
                                 ,p_consolidation_set_id in number)
  return varchar2
  IS
  cursor c_consolidation_set (cp_business_group_id in number,
                              cp_consolidation_set_id in number) is
  select consolidation_set_name
  from pay_consolidation_sets
  where consolidation_set_id = cp_consolidation_set_id
    and business_group_id = p_business_group_id;

  lv_consolidation_set_name varchar2(200);

  BEGIN

  open c_consolidation_set(p_business_group_id,
                           p_consolidation_set_id);
  fetch c_consolidation_set into lv_consolidation_set_name;
  close c_consolidation_set;

  return lv_consolidation_set_name;
  END;


  FUNCTION get_payroll_name(p_business_group_id  in number
                           ,p_payroll_id in number
                           ,p_effective_date in date)
  return varchar2
  IS
  cursor c_payroll_name (cp_business_group_id in number,
                         cp_payroll_id in number,
                         cp_effective_date in date) is
  select payroll_name
  from pay_all_payrolls_f
  where payroll_id = cp_payroll_id
    and business_group_id = p_business_group_id
    and p_effective_date between effective_start_date
                             and effective_end_date;

  lv_payroll_name varchar2(200);

  BEGIN

  open c_payroll_name(p_business_group_id,
                      p_payroll_id,
                      p_effective_date);
  fetch c_payroll_name into lv_payroll_name;
  close c_payroll_name;

  return lv_payroll_name;
  END;


 /************************************************************
  Name      : format_to_date
  Purpuse   : The function formats the value in date format
  Arguments : p_value
  Notes     :
 *************************************************************/
 FUNCTION format_to_date(p_char_date in varchar2)
 RETURN date IS

    ld_return_date DATE;

 BEGIN
    if length(p_char_date) = 19 then
       ld_return_date := fnd_date.canonical_to_date(p_char_date);
    else
      begin
         ld_return_date := fnd_date.chardate_to_date(p_char_date);

      exception
         when others then
           ld_return_date := null;
      end;

    end if;

    return(ld_return_date);

 END format_to_date;

 /********************************************************************
  ** Function : get_def_bal_for_seeded_bal
  ** Arguments: p_balance_name
  **            p_legislation_code
  ** Returns  : Defined Balance Id
  ** Purpose  : This function has 2 parameters as input. The function
  **            returns defined balance id of the seeded balance. This
  **            function also uses PL/SQL table def_bal_tbl to cache
  **            defined balance id for seeded balanced.
  *********************************************************************/
  FUNCTION get_def_bal_for_seeded_bal (p_balance_name      in varchar2
                                      ,p_legislation_code  in varchar2)
  RETURN number
  IS

  cursor c_def_bal(cp_balance_name varchar2
                  ,cp_legislation_code varchar2) is
  select bal.balance_name
       , def.legislation_code
       , def.defined_balance_id
       , bal.balance_type_id
       , dim.balance_dimension_id
  from  pay_balance_types bal,
        pay_balance_dimensions dim,
        pay_defined_balances def
  where bal.legislation_code = cp_legislation_code
  and bal.balance_name in ( cp_balance_name )
  and dim.legislation_code = cp_legislation_code
  and dim.dimension_name = 'Assignment within Government Reporting Entity Run'
  and def.legislation_code = cp_legislation_code
  and def.balance_type_id = bal.balance_type_id
  and def.balance_dimension_id = dim.balance_dimension_id;

  ln_defined_balance_id NUMBER := -1;

  TYPE CHAR_80_TABLE IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  lv_balance_name CHAR_80_TABLE;

  ln_index number;
  ln_step  number;
  BEGIN

--   hr_utility.trace_on(null,'DEFBAL');
     hr_utility.trace('p_balance_name : '||p_balance_name);
     hr_utility.trace('p_legislation_code : '||p_legislation_code);

     ln_index := pay_ac_util.ltr_def_bal.count;

     ln_step := 1;

     if ln_index = 0 then

        ln_step := 2;

        lv_balance_name(1) := 'Gross Earnings';
        lv_balance_name(2) := 'Gross Pay';
        lv_balance_name(3) := 'Regular Earnings';
        lv_balance_name(4) := 'Supplemental Earnings';
        lv_balance_name(5) := 'Imputed Earnings';
        lv_balance_name(6) := 'Taxable Benefits';
        lv_balance_name(7) := 'Non Payroll Payments';
        lv_balance_name(8) := 'Tax Deductions';
        lv_balance_name(9) := 'Pre Tax Deductions';
        lv_balance_name(10) := 'Involuntary Deductions';
        lv_balance_name(11) := 'Voluntary Deductions';
        lv_balance_name(12) := 'Net';
        lv_balance_name(13) := 'Payments';

        for i in 1..13 loop

          hr_utility.trace('lv_balance_name : '||lv_balance_name(i));
          ln_step := 3;

          for defbal in c_def_bal(lv_balance_name(i), p_legislation_code)
          loop
              hr_utility.trace('Balance Name : '||defbal.balance_name);
              ln_step := 4;
              pay_ac_util.ltr_def_bal(ln_index).balance_name
                  := defbal.balance_name;
              pay_ac_util.ltr_def_bal(ln_index).legislation_code
                  := defbal.legislation_code;
              pay_ac_util.ltr_def_bal(ln_index).defined_balance_id
                  := defbal.defined_balance_id;
              pay_ac_util.ltr_def_bal(ln_index).balance_type_id
                  := defbal.balance_type_id;
              pay_ac_util.ltr_def_bal(ln_index).balance_dimension_id
                  := defbal.balance_dimension_id;

              ln_index := ln_index + 1;
          end loop;
        end loop;
     end if;

     ln_step := 5;
     if ln_index > 0 then
        for i in pay_ac_util.ltr_def_bal.first ..
                 pay_ac_util.ltr_def_bal.last
        loop
           ln_step := 6;
           if pay_ac_util.ltr_def_bal(i).balance_name =
              p_balance_name and
              pay_ac_util.ltr_def_bal(i).legislation_code =
              p_legislation_code
           then
              ln_step := 7;
              hr_utility.trace(p_balance_name ||' ' ||
                     pay_ac_util.ltr_def_bal(i).defined_balance_id);
              return pay_ac_util.ltr_def_bal(i).defined_balance_id;
           end if;
        end loop;
     end if;

     ln_step := 8;
     for defbal in c_def_bal(p_balance_name, p_legislation_code)
     loop
         ln_step := 9;
         pay_ac_util.ltr_def_bal(ln_index).balance_name
             := defbal.balance_name;
         pay_ac_util.ltr_def_bal(ln_index).legislation_code
             := defbal.legislation_code;
         pay_ac_util.ltr_def_bal(ln_index).defined_balance_id
             := defbal.defined_balance_id;
         pay_ac_util.ltr_def_bal(ln_index).balance_type_id
             := defbal.balance_type_id;
         pay_ac_util.ltr_def_bal(ln_index).balance_dimension_id
             := defbal.balance_dimension_id;

         ln_defined_balance_id := defbal.defined_balance_id;

         hr_utility.trace('Balance not in PL/SQL table: '||defbal.balance_name);

     end loop;

     RETURN ln_defined_balance_id;

     EXCEPTION
     WHEN OTHERS THEN
       hr_utility.trace('Error at Step : ' || ln_step );
       RETURN -1;
  END;

 /********************************************************************
  ** Function : get_value
  ** Arguments: p_assignment_action_id
  **            p_defined_balance_id
  **            p_tax_unit_id
  ** Returns  : Valueed Balance Id
  ** Purpose  : This function has 3 parameters as input. This function
  **            sets the context for Tax Unit Id and then calling
  **            pay_balance_pkg.get_value to get value for given
  **            assignment_action id and defined balance id.
  *********************************************************************/
  FUNCTION get_value(p_assignment_action_id in number
                    ,p_defined_balance_id   in number
                    ,p_tax_unit_id          in number)
  RETURN number IS
  ln_value number := 0;
  BEGIN

     if gn_tax_unit_id <> p_tax_unit_id then
        hr_utility.trace('p_tax_unit_id : '||p_tax_unit_id);
        hr_utility.trace('gn_tax_unit_id : '||gn_tax_unit_id);
        pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
        gn_tax_unit_id := p_tax_unit_id;
     end if;
--   hr_utility.trace_off;

     ln_value := nvl(pay_balance_pkg.get_value(p_defined_balance_id
                                              ,p_assignment_action_id),0);
     return ln_value;

     EXCEPTION
     WHEN OTHERS THEN
     return 0;
  END;

--Begin
--hr_utility.trace_on(null,'ACDIS');


end pay_ac_util;

/
