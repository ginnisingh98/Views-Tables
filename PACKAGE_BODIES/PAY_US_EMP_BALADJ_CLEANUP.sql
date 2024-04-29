--------------------------------------------------------
--  DDL for Package Body PAY_US_EMP_BALADJ_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMP_BALADJ_CLEANUP" AS
/* $Header: payusbaladjclean.pkb 120.0 2005/05/29 11:52 appldev noship $ */
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

    Name        :

    Description :


    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    10-JUL-2004 ahanda     115.0            Created.
    13-JUL-2004 ahanda     115.1            Changed SIT*_RS to SIT*_WK
    14-JUL-2004 jgoswami   115.3            Added code for MA
    15-JUL-2004 jgoswami   115.4            Added code for Courtsey
                                            Withholding
    14-MAR-2005 sackumar  115.7  4222032 Change in the Range Cursor removing redundant
							   use of bind Variable (:payroll_action_id)
  ********************************************************************/

  /********************************************************************
  ** Package Local Variables
  *********************************************************************/
   gv_package        VARCHAR2(100);

  /********************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
   Input     : p_payroll_action_id - Payroll_Action_id
   Returns   : p_start_date        - Start date
               p_end_date          - End date
               p_business_group_id - Business Group ID
               p_cons_set_id       - Consolidation Set
               p_payroll_id        - Payroll ID
  ********************************************************************/
  PROCEDURE get_payroll_action_info(
                       p_payroll_action_id     in        number
                      ,p_end_date             out nocopy date
                      ,p_start_date           out nocopy date
                      ,p_business_group_id    out nocopy number
                      ,p_state_abbrev         out nocopy varchar2
                      ,p_cons_set_id          out nocopy number
                      ,p_payroll_id           out nocopy number
                      )
  IS
    cursor c_payroll_Action_info
              (cp_payroll_action_id in number) is
      select effective_date,
             start_date,
             business_group_id,
             pay_us_payroll_utils.get_parameter(
                     'TRANSFER_STATE',
                     legislative_parameters) state_abbrev,
             to_number(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=')
                + length('TRANSFER_CONSOLIDATION_SET_ID='))),
             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
                + length('TRANSFER_PAYROLL_ID='),
                (instr(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=') - 1 )
              - (instr(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
              + length('TRANSFER_PAYROLL_ID='))))))
        from pay_payroll_actions
       where payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;
    lv_state_abbrev      VARCHAR2(10);
    lv_procedure_name    VARCHAR2(100);

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

   BEGIN
       lv_procedure_name := '.get_payroll_action_info';
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        lv_state_abbrev,
                                        ln_cons_set_id,
                                        ln_payroll_id;
       close c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_cons_set_id       := ln_cons_set_id;
       p_state_abbrev      := lv_state_abbrev;
       p_payroll_id        := ln_payroll_id;
       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 2;

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_payroll_action_info;


  FUNCTION get_input_value_id(p_element_type_id  in number
                             ,p_input_value_name in varchar2
                             ,p_effective_date   in date)
  RETURN NUMBER
  IS
    ln_input_value_id NUMBER;

    cursor c_get_input_id (cp_element_type_id  in number
                          ,cp_input_value_name in varchar2
                          ,cp_effective_date   in date) is
      select input_value_id
        from pay_input_values_f piv
       where piv.element_type_id = cp_element_type_id
         and piv.legislation_code = 'US'
         and piv.name = cp_input_value_name
         and cp_effective_date between piv.effective_start_date
                                   and piv.effective_end_date;

  BEGIN
    open c_get_input_id(p_element_type_id,
                        p_input_value_name,
                        p_effective_date);
    fetch c_get_input_id into ln_input_value_id;
    close c_get_input_id;

    return(ln_input_value_id);

  END get_input_value_id;


  /******************************************************************
   Name      : get_balance_value
   Purpose   : This procedure calls the get_value function for
               balance calls.
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_balance_value(
                           p_defined_balance_id in number
                          ,p_balcall_aaid       in number)
  RETURN NUMBER
  IS
    lv_error_message VARCHAR2(200);
    ln_bal_value     NUMBER;

  BEGIN

      if p_defined_balance_id is not null then
         ln_bal_value := nvl(pay_balance_pkg.get_value(
                                        p_defined_balance_id,
                                        p_balcall_aaid),0);
      end if;

      return (ln_bal_value);

  EXCEPTION
   when others then
      return (null);

  END get_balance_value;

  PROCEDURE initialize_plsql_table
                   (p_effective_date    in date
                   ,p_business_group_id in number)
  IS
    i NUMBER;
    j NUMBER;

    FUNCTION get_element_category(p_business_group_id in number
                                 ,p_element_category in varchar2)
    RETURN BOOLEAN
    IS
      lv_exists VARCHAR2(1);

      cursor c_element_category(cp_business_group_id in number
                               ,cp_element_category in varchar2) is
        select 'Y' from dual
         where exists (select 1 from pay_element_types_f pet,
                                     pay_element_classifications pec
                        where pet.classification_id = pec.classification_id
                          and pet.business_group_id = cp_business_group_id
                          and pet.element_information1 = cp_element_category
                          and pec.classification_name = 'Pre-Tax Deductions'
                          and pec.legislation_code = 'US');
    BEGIN
       lv_exists := 'N';

       open c_element_category(p_business_group_id, p_element_category);
       fetch c_element_category into lv_exists;
       if c_element_category%notfound then
          lv_exists := 'N';
       end if;
       close c_element_category;

       if lv_exists = 'Y' then
          return(TRUE);
       else
          return(FALSE);
       end if;

    END get_element_category;

    FUNCTION get_element_type_id(p_elment_name in varchar2)
    RETURN NUMBER
    IS
      ln_element_type_id NUMBER;

      cursor get_element_type_id (cp_elment_name in varchar2) is
        select element_type_id from pay_element_types_f
         where element_name = cp_elment_name
           and legislation_code = 'US';

    BEGIN
      open get_element_type_id(p_elment_name);
      fetch get_element_type_id into ln_element_type_id;
      close get_element_type_id;

      return(ln_element_type_id);

    END get_element_type_id;

    FUNCTION get_defined_id(p_user_entity_name in varchar2)
    RETURN NUMBER
    IS
      ln_defined_id NUMBER;

      cursor c_get_defined_id (cp_user_entity_name in varchar2) is
        select creator_id from ff_user_entities
         where user_entity_name = cp_user_entity_name;

    BEGIN
      open c_get_defined_id(p_user_entity_name);
      fetch c_get_defined_id into ln_defined_id;
      close c_get_defined_id;

      return(ln_defined_id);

    END get_defined_id;

  BEGIN

    /************************************************************
    ** Initialize SIT Balances
    *************************************************************/
    i := 0;
    --SIT and SDI ER Gross
    ltr_sit_tax_bal(i).balance_name
                 := 'SIT_GROSS_ASG_JD_GRE_YTD';
    ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
    ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
    ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
    ltr_sit_tax_bal(i).input_name := 'Gross';
    ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_GROSS_ASG_JD_GRE_YTD';
    ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
    ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT_ER';
    ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
    ltr_sdi_er_tax_bal(i).input_name := 'Gross';
    ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    --SIT and SDI ER Whable
    i := i + 1;
    ltr_sit_tax_bal(i).balance_name
                 := 'SIT_SUBJ_WHABLE_ASG_JD_GRE_YTD';
    ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
    ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
    ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
    ltr_sit_tax_bal(i).input_name := 'Subj Whable';
    ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_SUBJ_WHABLE_ASG_JD_GRE_YTD';
    ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
    ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT_ER';
    ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
    ltr_sdi_er_tax_bal(i).input_name := 'Subj Whable';
    ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);


    --SIT and SDI ER Other Pre Tax
    i := i + 1;
    ltr_sit_tax_bal(i).balance_name
                 := 'SIT_OTHER_PRETAX_REDNS_ASG_JD_GRE_YTD';
    ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
    ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT2_WK';
    ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
    ltr_sit_tax_bal(i).input_name := 'Other Pretax Redns';
    ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_OTHER_PRETAX_REDNS_ASG_JD_GRE_YTD';
    ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
    ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT2_ER';
    ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
    ltr_sdi_er_tax_bal(i).input_name := 'Other Pretax Redns';
    ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);


    if get_element_category(p_business_group_id, 'D') then
       i := i + 1;
       ltr_sit_tax_bal(i).balance_name
                    := 'SIT_401_REDNS_ASG_JD_GRE_YTD';
       ltr_sit_tax_bal(i).ytd_def_bal_id
                    := get_defined_id(ltr_sit_tax_bal(i).balance_name);
       ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
       ltr_sit_tax_bal(i).element_type_id
                    := get_element_type_id(ltr_sit_tax_bal(i).element_name);
       ltr_sit_tax_bal(i).input_name := 'DC 401 Redns';
       ltr_sit_tax_bal(i).input_value_id
                    := get_input_value_id(
                         p_element_type_id =>ltr_sit_tax_bal(i).element_type_id
                        ,p_input_value_name=>ltr_sit_tax_bal(i).input_name
                        ,p_effective_date  =>p_effective_date);

       ltr_sdi_er_tax_bal(i).balance_name
                := 'SDI_ER_401_REDNS_ASG_JD_GRE_YTD';
       ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
       ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT_ER';
       ltr_sdi_er_tax_bal(i).element_type_id
                := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
       ltr_sdi_er_tax_bal(i).input_name := 'DC 401 Redns';
       ltr_sdi_er_tax_bal(i).input_value_id
                := get_input_value_id(
                     p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);
    end if;

    if get_element_category(p_business_group_id, 'H') then
       i := i + 1;
       ltr_sit_tax_bal(i).balance_name
                 := 'SIT_125_REDNS_ASG_JD_GRE_YTD';
       ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
       ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
       ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
       ltr_sit_tax_bal(i).input_name := 'S 125 Redns';
       ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

       ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_125_REDNS_ASG_JD_GRE_YTD';
       ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
       ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT_ER';
       ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
       ltr_sdi_er_tax_bal(i).input_name := 'S 125 Redns';
       ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);
    end if;

    if get_element_category(p_business_group_id, 'S') then
       i := i + 1;
       ltr_sit_tax_bal(i).balance_name
                 := 'SIT_DEP_CARE_REDNS_ASG_JD_GRE_YTD';
       ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
       ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
       ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
       ltr_sit_tax_bal(i).input_name := 'Dep Care Redns';
       ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

       ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_DEP_CARE_REDNS_ASG_JD_GRE_YTD';
       ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
       ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT_ER';
       ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
       ltr_sdi_er_tax_bal(i).input_name := 'Dep Care Redns';
       ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);
    end if;


    if get_element_category(p_business_group_id, 'E') then
       i := i + 1;
       ltr_sit_tax_bal(i).balance_name
                 := 'SIT_403_REDNS_ASG_JD_GRE_YTD';
       ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
       ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT2_WK';
       ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
       ltr_sit_tax_bal(i).input_name := 'DC 403 Redns';
       ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

       ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_403_REDNS_ASG_JD_GRE_YTD';
       ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
       ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT2_ER';
       ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
       ltr_sdi_er_tax_bal(i).input_name := 'DC 403 Redns';
       ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);
    end if;

    if get_element_category(p_business_group_id, 'G') then
       i := i + 1;
       ltr_sit_tax_bal(i).balance_name
                 := 'SIT_457_REDNS_ASG_JD_GRE_YTD';
       ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
       ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT2_WK';
       ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
       ltr_sit_tax_bal(i).input_name := 'DC 457 Redns';
       ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

       ltr_sdi_er_tax_bal(i).balance_name
                 := 'SDI_ER_457_REDNS_ASG_JD_GRE_YTD';
       ltr_sdi_er_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sdi_er_tax_bal(i).balance_name);
       ltr_sdi_er_tax_bal(i).element_name := 'SDI_SUBJECT2_ER';
       ltr_sdi_er_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sdi_er_tax_bal(i).element_name);
       ltr_sdi_er_tax_bal(i).input_name := 'DC 457 Redns';
       ltr_sdi_er_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sdi_er_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sdi_er_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    end if;


    --SIT NWhable
    i := i + 1;
    ltr_sit_tax_bal(i).balance_name
                 := 'SIT_SUBJ_NWHABLE_ASG_JD_GRE_YTD';
    ltr_sit_tax_bal(i).ytd_def_bal_id
                 := get_defined_id(ltr_sit_tax_bal(i).balance_name);
    ltr_sit_tax_bal(i).element_name := 'SIT_SUBJECT_WK';
    ltr_sit_tax_bal(i).element_type_id
                 := get_element_type_id(ltr_sit_tax_bal(i).element_name);
    ltr_sit_tax_bal(i).input_name := 'Subj NWhable';
    ltr_sit_tax_bal(i).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_sit_tax_bal(i).element_type_id
                     ,p_input_value_name => ltr_sit_tax_bal(i).input_name
                     ,p_effective_date   => p_effective_date);

    if ltr_sit_tax_bal.count > 0 then
       for i in ltr_sit_tax_bal.first .. ltr_sit_tax_bal.last loop
           hr_utility.trace('balance name='||ltr_sit_tax_bal(i).balance_name);
           hr_utility.trace('input name='||ltr_sit_tax_bal(i).input_value_id);
           hr_utility.trace('YTD Def Bal ='||ltr_sit_tax_bal(i).ytd_def_bal_id);
           if ltr_sit_tax_bal(i).ytd_def_bal_id is null then
              hr_utility.raise_error;
           end if;
       end loop;
    end if;
    if ltr_sdi_er_tax_bal.count > 0 then
       for i in ltr_sdi_er_tax_bal.first .. ltr_sdi_er_tax_bal.last loop
           hr_utility.trace('balance name='||ltr_sdi_er_tax_bal(i).balance_name);
           hr_utility.trace('input name='||ltr_sdi_er_tax_bal(i).input_value_id);
           hr_utility.trace('YTD Def Bal ='||ltr_sdi_er_tax_bal(i).ytd_def_bal_id);
           if ltr_sit_tax_bal(i).ytd_def_bal_id is null then
              hr_utility.raise_error;
           end if;
       end loop;
    end if;


    j := 0;
    ltr_misc_er_tax_bal(j).balance_name
                 := 'SDI_ER_SUBJ_WHABLE_PER_JD_GRE_YTD';
    ltr_misc_er_tax_bal(j).ytd_def_bal_id
                 := get_defined_id(ltr_misc_er_tax_bal(j).balance_name);
    ltr_misc_er_tax_bal(j).element_name := 'SDI_SUBJECT_ER';
    ltr_misc_er_tax_bal(j).element_type_id
                 := get_element_type_id(ltr_misc_er_tax_bal(j).element_name);
    ltr_misc_er_tax_bal(j).input_name := 'Subj Whable';
    ltr_misc_er_tax_bal(j).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_misc_er_tax_bal(j).element_type_id
                     ,p_input_value_name => ltr_misc_er_tax_bal(j).input_name
                     ,p_effective_date   => p_effective_date);

    j := j + 1;
    ltr_misc_er_tax_bal(j).balance_name
                 := 'SDI_ER_PRE_TAX_REDNS_PER_JD_GRE_YTD';
    ltr_misc_er_tax_bal(j).ytd_def_bal_id
                 := get_defined_id(ltr_misc_er_tax_bal(j).balance_name);
    ltr_misc_er_tax_bal(j).element_name := 'SDI_SUBJECT_ER';
    ltr_misc_er_tax_bal(j).element_type_id
                 := get_element_type_id(ltr_misc_er_tax_bal(j).element_name);
    ltr_misc_er_tax_bal(j).input_name := 'Pre Tax Redns';
    ltr_misc_er_tax_bal(j).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_misc_er_tax_bal(j).element_type_id
                     ,p_input_value_name => ltr_misc_er_tax_bal(j).input_name
                     ,p_effective_date   => p_effective_date);

    j := j + 1;
    ltr_misc_er_tax_bal(j).balance_name
                 := 'SDI_ER_TAXABLE_PER_JD_GRE_YTD';
    ltr_misc_er_tax_bal(j).ytd_def_bal_id
                 := get_defined_id(ltr_misc_er_tax_bal(j).balance_name);
    ltr_misc_er_tax_bal(j).element_name := 'MISC1_STATE_TAX_ER';
    ltr_misc_er_tax_bal(j).element_type_id
                 := get_element_type_id(ltr_misc_er_tax_bal(j).element_name);
    ltr_misc_er_tax_bal(j).input_name := 'Taxable';
    ltr_misc_er_tax_bal(j).input_value_id
                 := get_input_value_id(
                      p_element_type_id  => ltr_misc_er_tax_bal(j).element_type_id
                     ,p_input_value_name => ltr_misc_er_tax_bal(j).input_name
                     ,p_effective_date   => p_effective_date);

  END initialize_plsql_table;


  /********************************************************************
   Name      : range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ********************************************************************/
  PROCEDURE range_cursor(
                    p_payroll_action_id in        number
                   ,p_sqlstr           out nocopy varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    lv_cons_set_id       VARCHAR2(50);
    lv_payroll_id        VARCHAR2(50);
    lv_state_abbrev      VARCHAR2(10);
    lv_date              VARCHAR2(50);

    lv_sql_string        VARCHAR2(32000);
    lv_procedure_name    VARCHAR2(100);

  BEGIN
     lv_procedure_name := '.range_cursor';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_state_Abbrev      => lv_state_abbrev
                            ,p_cons_set_id       => lv_cons_set_id
                            ,p_payroll_id        => lv_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     if lv_cons_set_id is null then
        lv_cons_set_id := '%';
     end if;

     if lv_payroll_id is null then
        lv_payroll_id := '%';
     end if;

     lv_date := fnd_date.date_to_canonical(
                   greatest(ld_start_date,
                            fnd_date.canonical_to_date('2004/01/01 00:00:00')));


     insert into pay_action_information
             (ACTION_INFORMATION_ID,
              ACTION_CONTEXT_ID,
              ACTION_CONTEXT_TYPE,
              ACTION_INFORMATION_CATEGORY,
              ACTION_INFORMATION1
             )
     select pay_action_information_s.nextval,
            p_payroll_action_id,
            'PPA',
            'GAGA_STATUS',
            'U'
       from dual;

     lv_sql_string :=
         'select distinct paf.person_id
            from per_assignments_f paf,
                 pay_assignment_actions paa,
                 pay_payroll_actions ppa
           where ppa.business_group_id  = ''' || ln_business_group_id || '''
             and paf.assignment_id = paa.assignment_id
             and ppa.effective_date between paf.effective_start_date
                                        and paf.effective_end_date
             and ppa.effective_date
                    between fnd_date.canonical_to_date(''' ||
                              fnd_date.date_to_canonical(ld_start_date-10) || ''')
                        and fnd_date.canonical_to_date(''' ||
                              fnd_date.date_to_canonical(ld_end_date+30) || ''')
             and ppa.action_type in (''R'',''Q'')
             and ppa.last_update_date >= fnd_date.canonical_to_date(''' ||
                        lv_date || ''')
             and ppa.consolidation_set_id like ''' || lv_cons_set_id || '''
             and ppa.payroll_id  like ''' || lv_payroll_id || '''
             and ppa.payroll_action_id = paa.payroll_action_id
             and paa.action_status = ''C''
             and paa.source_action_id is null
             and :payroll_action_id  is not null
          order by paf.person_id';

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

  END range_cursor;


  /*******************************************************************
   Name      : action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  *******************************************************************/
  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id in number
                ,p_end_person_id   in number
                ,p_chunk               in number)
  IS

   cursor c_get_emp(cp_start_person_id   in number
                   ,cp_end_person_id     in number
                   ,cp_cons_set_id       in varchar2
                   ,cp_payroll_id        in varchar2
                   ,cp_business_group_id in number
                   ,cp_start_date        in date
                   ,cp_end_date          in date
                   ) is
     select distinct
            paa.tax_unit_id,
            paa.assignment_id,
            ppa.effective_date
       from per_assignments_f paf,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where paf.person_id between cp_start_person_id
                              and cp_end_person_id
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and paa.assignment_id = paf.assignment_id
        and ppa.business_group_id  = cp_business_group_id
        and ppa.effective_date between cp_start_date - 10
                                   and cp_end_date + 30
        and ppa.action_type in ('R','Q')
        and ppa.last_update_date >=
                      greatest(cp_start_date,
                              fnd_date.canonical_to_date('2004/07/01 00:00:00'))
        and ppa.consolidation_set_id like cp_cons_set_id
        and ppa.payroll_id like cp_payroll_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.source_action_id is not null
        and paa.action_status = 'C'
        and not exists
             (select 1
                from pay_action_interlocks   pai,
                     pay_assignment_actions  paa1,
                     pay_payroll_actions     ppa1
               where pai.locked_action_id = paa.assignment_action_id
                 and paa1.assignment_action_id = pai.locking_action_id
                 and ppa1.payroll_action_id = paa1.payroll_action_id
                 and ppa1.action_type = 'V'
             )
      order by 1, 2;

   cursor c_get_emp_state(cp_start_person_id   in number
                         ,cp_end_person_id     in number
                         ,cp_cons_set_id       in varchar2
                         ,cp_payroll_id        in varchar2
                         ,cp_business_group_id in number
                         ,cp_start_date        in date
                         ,cp_end_date          in date
                         ,cp_state_code        in varchar2
                         ) is
     select distinct
            paa.tax_unit_id,
            paa.assignment_id,
            ppa.effective_date
       from per_assignments_f paf,
            pay_us_emp_state_tax_rules_f pest,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where paf.person_id between cp_start_person_id
                              and cp_end_person_id
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and pest.assignment_id = paf.assignment_id
        and ppa.effective_date between pest.effective_start_date
                                   and pest.effective_end_date
        and pest.state_code = cp_state_code
        and paa.assignment_id = paf.assignment_id
        and ppa.business_group_id  = cp_business_group_id
        and ppa.effective_date between cp_start_date - 10
                                   and cp_end_date + 30
        and ppa.action_type in ('R','Q')
        and ppa.last_update_date >=
                      greatest(cp_start_date,
                              fnd_date.canonical_to_date('2004/07/01 00:00:00'))
        and ppa.consolidation_set_id like cp_cons_set_id
        and ppa.payroll_id like cp_payroll_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and paa.source_action_id is not null
        and paa.action_status = 'C'
        and not exists
             (select 1
                from pay_action_interlocks   pai,
                     pay_assignment_actions  paa1,
                     pay_payroll_actions     ppa1
               where pai.locked_action_id = paa.assignment_action_id
                 and paa1.assignment_action_id = pai.locking_action_id
                 and ppa1.payroll_action_id = paa1.payroll_action_id
                 and ppa1.action_type = 'V'
             )
      order by 1, 2;

   cursor c_get_jurisduction_code(cp_assignment_id  in number
                                 ,cp_effective_date in date) is
     select distinct state_code
       from pay_us_emp_state_tax_rules_f pest
      where pest.assignment_id = cp_assignment_id
        and cp_effective_date between pest.effective_Start_date
                                  and pest.effective_end_Date;

   cursor c_get_latest_action(cp_assignment_id      number
                             ,cp_tax_unit_id        number) is
     select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
            paa.assignment_action_id, ppa.effective_date,
            ppa.payroll_id, ppa.consolidation_set_id
       from pay_assignment_actions paa,
            pay_payroll_actions    ppa
      where paa.assignment_id = cp_assignment_id
        and paa.tax_unit_id   = cp_tax_unit_id
        and paa.payroll_action_id = ppa.payroll_action_id
        and ppa.action_type in ('R', 'Q', 'B', 'I', 'V')
        and ppa.effective_date between to_date('2004/01/01', 'yyyy/mm/dd')
                                   and to_date('2004/12/31', 'yyyy/mm/dd')
     order by paa.action_sequence desc;

   cursor c_get_state_code(cp_state_abbrev varchar2) is
     select state_code from pay_us_states
      where state_Abbrev = cp_state_abbrev;


    ld_adj_end_date             DATE;
    ld_adj_start_date           DATE;
    ln_adj_business_group_id    NUMBER;
    lv_adj_cons_set_id          VARCHAR2(50);
    lv_adj_payroll_id           VARCHAR2(50);
    lv_state_abbrev             VARCHAR2(10);
    ln_adj_action_id            NUMBER;

    ln_run_assignment_id        NUMBER;
    ln_run_tax_unit_id          NUMBER;
    ld_run_effective_date       DATE;
    ln_run_payroll_id           NUMBER;
    ln_run_consolidation_id     NUMBER;
    ln_run_action_id            NUMBER;

    ln_run_prv_assignment_id    NUMBER;
    ln_run_prv_tax_unit_id      NUMBER;

    lv_state_code               VARCHAR2(10);
    lv_adj_flag                 VARCHAR2(1);

    ln_max_run_action_id        NUMBER;

    lv_serial_number            VARCHAR2(30);
    lv_procedure_name           VARCHAR2(100);
    lv_error_message            VARCHAR2(200);
    ln_step                     NUMBER;

  BEGIN
     lv_procedure_name := '.action_creation';
     ln_run_prv_assignment_id    := -1;
     ln_run_prv_tax_unit_id      := -1;
     lv_adj_flag := 'N';

     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_adj_start_date
                            ,p_end_date          => ld_adj_end_date
                            ,p_business_group_id => ln_adj_business_group_id
                            ,p_state_abbrev      => lv_state_abbrev
                            ,p_cons_set_id       => lv_adj_cons_set_id
                            ,p_payroll_id        => lv_adj_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     if lv_adj_cons_set_id is null then
        lv_adj_cons_set_id := '%';
     end if;

     if lv_adj_payroll_id is null then
        lv_adj_payroll_id := '%';
     end if;


     pay_us_payroll_utils.populate_jit_information(
                p_effective_date => ld_adj_start_date
               ,p_get_state      => 'Y');

     ln_step := 2;
     if lv_state_abbrev is null then
        open c_get_emp( p_start_person_id
                       ,p_end_person_id
                       ,lv_adj_cons_set_id
                       ,lv_adj_payroll_id
                       ,ln_adj_business_group_id
                       ,ld_adj_start_date
                       ,ld_adj_end_date);
     else
        open c_get_state_code(lv_state_abbrev);
        fetch c_get_state_code into lv_state_code;
        close c_get_state_code;

        open c_get_emp_state(p_start_person_id
                            ,p_end_person_id
                            ,lv_adj_cons_set_id
                            ,lv_adj_payroll_id
                            ,ln_adj_business_group_id
                            ,ld_adj_start_date
                            ,ld_adj_end_date
                            ,lv_state_code);
     end if;


     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     loop
        if lv_state_abbrev is null then
           fetch c_get_emp into ln_run_tax_unit_id,
                                ln_run_assignment_id,
                                ld_run_effective_date;

           exit when c_get_emp%notfound;
        else
           fetch c_get_emp_state into ln_run_tax_unit_id,
                                      ln_run_assignment_id,
                                      ld_run_effective_date;

           exit when c_get_emp_state%notfound;
        end if;

        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        hr_utility.trace('Adj Flag = ' || lv_adj_flag);
        hr_utility.trace('AsgID = ' ||
                          ln_run_assignment_id||'/'||ln_run_prv_assignment_id);
        hr_utility.trace('Tax Unit ID = ' ||
                          ln_run_tax_unit_id||'/'||ln_run_prv_tax_unit_id);
        hr_utility.trace('Payroll ID = ' || ln_run_payroll_id);

        if (ln_run_assignment_id = ln_run_prv_assignment_id and
            ln_run_tax_unit_id = ln_run_prv_tax_unit_id) then

            hr_utility.set_location(gv_package || lv_procedure_name, 41);

        else

           hr_utility.set_location(gv_package || lv_procedure_name, 45);
           lv_adj_flag := 'N';
           ln_run_prv_assignment_id    := ln_run_assignment_id;
           ln_run_prv_tax_unit_id      := ln_run_tax_unit_id;

           if lv_state_abbrev is null then
              open c_get_jurisduction_code(ln_run_assignment_id
                                          ,ld_run_effective_date);
              loop
                 fetch c_get_jurisduction_code into lv_state_code;
                 if c_get_jurisduction_code%notfound then
                    exit;
                 end if;

                 hr_utility.trace('SIT Exists = ' ||
                     pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sit_exists);
                 hr_utility.trace('SDI ER Exists = ' ||
                     pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit);
                 /* Create an action if the employee is in a state which does not
                    have SIT or SDI Er taxes or if the employee is in MA */
                    if pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sit_exists
                           = 'N' or
                       pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit
                           is null or
                       lv_state_code = '22' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 50);
                       lv_adj_flag := 'Y';
                       exit;
                    end if;
              end loop;
              close c_get_jurisduction_code;
           else
              lv_adj_flag := 'Y';
           end if;

           hr_utility.trace('Adj Flag = '||lv_adj_flag );
           if lv_adj_flag = 'Y' then
              hr_utility.set_location(gv_package || lv_procedure_name, 60);

              select pay_assignment_actions_s.nextval
                into ln_adj_action_id
                from dual;

              -- insert into pay_assignment_actions.
              hr_nonrun_asact.insact(ln_adj_action_id,
                                     ln_run_assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                     ln_run_tax_unit_id,
                                     null,
                                     'U',
                                     null);
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
              hr_utility.trace('ln_run_action_id = ' || ln_run_action_id);
              hr_utility.trace('ln_adj_action_id = ' || ln_adj_action_id);
              hr_utility.trace('p_payroll_action_id = ' || p_payroll_action_id);
              hr_utility.trace('ln_run_tax_unit_id = '   || ln_run_tax_unit_id);
              hr_utility.set_location(gv_package || lv_procedure_name, 80);

              open c_get_latest_action(ln_run_assignment_id
                                      ,ln_run_tax_unit_id);
              fetch c_get_latest_action into ln_max_run_action_id
                                            ,ld_run_effective_date
                                            ,ln_run_payroll_id
                                            ,ln_run_consolidation_id;
              close c_get_latest_action;

              lv_serial_number := to_char(ld_run_effective_Date,'ddmmyyyy') ||
                                  ln_max_run_action_id;

              hr_utility.trace('Update Serail Number = '  || lv_serial_number);
              update pay_assignment_actions
                 set serial_number = lv_serial_number
               where assignment_action_id = ln_adj_action_id;

              hr_utility.trace('Insert into temp table ');
              insert into pay_us_rpt_totals
              (location_id, organization_id, tax_unit_id,
               value1, value3)
              select
                 p_payroll_action_id,
                 to_char(ld_run_effective_date, 'ddmmyyyy'),
                 ln_run_payroll_id,
                 ln_run_consolidation_id,
                 ln_adj_business_group_id
               from dual
              where not exists
                     (select 1 from pay_us_rpt_totals
                       where location_id = p_payroll_action_id
                         and tax_unit_id = ln_run_payroll_id
                         and value1 = ln_run_consolidation_id
                         and organization_id
                              = to_char(ld_run_effective_date, 'ddmmyyyy'));

           end if;

        end if;

     end loop;
     if lv_state_abbrev is null then
        close c_get_emp;
     else
        close c_get_emp_state;
     end if;

     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 300);

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END action_creation;


  PROCEDURE process_min_chunk(p_payroll_action_id in number
                             ,p_chunk_number      in number
                             )
  IS
  --
    lr_rowid                    ROWID;

    ld_run_effective_date       DATE;
    ln_run_payroll_id           NUMBER;
    ln_run_consolidation_id     NUMBER;

    ld_run_prv_effective_date   DATE;
    ln_run_prv_payroll_id       NUMBER;
    ln_run_prv_consolidation_id NUMBER;

    ln_payroll_action_id        NUMBER;

    ln_exists                   NUMBER;
    lv_error_message            VARCHAR2(500);
    lv_procedure_name           VARCHAR2(100);
    ln_step                     NUMBER;
  --
    cursor c_get_adj_dates (cp_payroll_action_id in number) is
      select prt.rowid,
             to_date(lpad(to_char(prt.organization_id),8,'0'),'ddmmyyyy'),
             tax_unit_id,
             value1
        from pay_us_rpt_totals prt
       where prt.location_id = cp_payroll_action_id
         and prt.value2 is null
      order by to_date(lpad(to_char(prt.organization_id),8,'0'),'ddmmyyyy'),
               tax_unit_id, value1;

    cursor c_get_action_info (cp_payroll_action_id in number) is
      select 1
        from pay_action_information
       where action_information1 = 'C'
         and action_context_id = cp_payroll_action_id
         and action_context_type = 'PPA';
  --
  BEGIN
  --
    hr_utility.set_location(gv_package || lv_procedure_name, 1);
    lv_procedure_name := '.process_min_chunk';
    ld_run_prv_effective_date   := to_date('1800/01/01', 'yyyy/mm/dd');
    ln_run_prv_payroll_id       := -1;
    ln_run_prv_consolidation_id := -1;

    /* Check the pay_action_infor table to see if the pay_us_rpt_totals
    ** has been cleaned up and payroll actions for them started.
    ** If the status is not 'C' then it could mean -
    ** 1) this is the first time it has been called
    ** 2) the first assignment action for the chunk has errored
    **    so everything is rolled back.
    ** Need to do the cleanup and opening of balance adjustment payroll
    ** action if we hit the latter case. */
    open c_get_action_info(p_payroll_action_id);
    fetch c_get_action_info into ln_exists;
    if c_get_action_info%notfound then
       g_proc_init := FALSE;
    end if;
    close c_get_action_info;

    if (g_proc_init = FALSE) then

     if p_chunk_number = g_min_chunk then
        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        open c_get_adj_dates(p_payroll_action_id);
        loop
           fetch c_get_adj_dates into lr_rowid,
                                      ld_run_effective_date,
                                      ln_run_payroll_id,
                                      ln_run_consolidation_id;
           if c_get_adj_dates%notfound then
              exit;
           end if;

           hr_utility.trace('Effective Date = ' ||
                     ld_run_effective_date||'/'||ld_run_prv_effective_date);
           hr_utility.trace('Payroll ID = ' ||
                     ln_run_payroll_id||'/'||ln_run_prv_payroll_id);
           hr_utility.trace('Consolidation Set ID = ' ||
                     ln_run_consolidation_id||'/'||ln_run_prv_consolidation_id);
           if (ld_run_effective_date <> ld_run_prv_effective_date or
               ln_run_prv_payroll_id <> ln_run_payroll_id or
               ln_run_prv_consolidation_id <> ln_run_consolidation_id) then

              hr_utility.set_location(gv_package || lv_procedure_name, 40);
              ld_run_prv_effective_date   := ld_run_effective_date;
              ln_run_prv_payroll_id       := ln_run_payroll_id;
              ln_run_prv_consolidation_id := ln_run_consolidation_id;

              ln_payroll_action_id
                  := pay_bal_adjust.init_batch(
                            p_payroll_id => ln_run_payroll_id,
                            p_batch_mode => 'STANDARD',
                            p_effective_date => ld_run_effective_date,
                            p_consolidation_set_id => ln_run_consolidation_id,
                            p_prepay_flag => 'N');
              update pay_us_rpt_totals
                 set value2 = ln_payroll_action_id
               where rowid = lr_rowid;
           else
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
              delete from pay_us_rpt_totals
               where rowid = lr_rowid;
           end if;
        end loop;
        close c_get_adj_dates;

        update pay_action_information
           set ACTION_INFORMATION1 = 'C'
         where ACTION_CONTEXT_ID = p_payroll_action_id
           and ACTION_CONTEXT_TYPE = 'PPA';

  --
     else
  --
        -- OK, we're not chunk 1 we need to wait.
  --
      declare
        complete_status boolean;
        status pay_action_information.action_information1%type;
      begin
  --
        complete_status := FALSE;
        while (complete_status = FALSE) loop
  --
          select ACTION_INFORMATION1
            into status
            from pay_action_information
           where ACTION_CONTEXT_ID = p_payroll_action_id
             and ACTION_CONTEXT_TYPE = 'PPA';
  --
          if (status = 'C') then
             complete_status := TRUE;
          else
            dbms_lock.sleep(5);
          end if;
  --
        end loop;
  --
      end;
  --
     end if;
  --
     g_proc_init := TRUE;
  --
    end if;
  --
  END process_min_chunk;

  /******************************************************************
   Name      : initialize
   Purpose   : This performs the context initialization.
   Arguments :
   Notes     :
  *******************************************************************/
  PROCEDURE initialize(
                p_payroll_action_id in number) is

    ld_adj_start_date           DATE;
    ld_adj_end_date             DATE;
    ln_adj_business_group_id    NUMBER;
    lv_adj_cons_set_id          NUMBER;
    lv_adj_payroll_id           NUMBER;
    lv_adj_State_abbrev         VARCHAR2(10);

    lv_error_message            VARCHAR2(500);
    lv_procedure_name           VARCHAR2(100);
    ln_step                     NUMBER;

   cursor c_get_state_code(cp_state_abbrev varchar2) is
     select state_code from pay_us_states
      where state_Abbrev = cp_state_abbrev;

    cursor c_get_chunk_date(cp_payroll_action_id in number) is
      select min(paa.chunk_number)
        from pay_assignment_actions paa,
             pay_payroll_actions ppa
       where ppa.payroll_action_id = paa.payroll_Action_id
         and ppa.payroll_action_id = cp_payroll_action_id;

  BEGIN
    hr_utility.set_location(gv_package || lv_procedure_name, 1);
    lv_procedure_name := '.initialize';
    ln_step := 1;

    get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                           ,p_start_date        => ld_adj_start_date
                           ,p_end_date          => ld_adj_end_date
                           ,p_business_group_id => ln_adj_business_group_id
                           ,p_state_abbrev      => lv_adj_State_abbrev
                           ,p_cons_set_id       => lv_adj_cons_set_id
                           ,p_payroll_id        => lv_adj_payroll_id);

    open c_get_state_code(lv_adj_State_abbrev);
    fetch c_get_state_code into g_adj_state_code;
    close c_get_state_code;

    open c_get_chunk_date(p_payroll_action_id);
    fetch c_get_chunk_date into g_min_chunk;
    ln_step := 2;
    if c_get_chunk_date%notfound then
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       lv_error_message := 'No Assignment Actions were picked by ' ||
                           'the Process.';

       hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
       hr_utility.set_message_token('FORMULA_TEXT',lv_error_message);
    end if;
    close c_get_chunk_date;

    -- initialize pl/sql table
    initialize_plsql_table(ld_adj_start_date,
                           ln_adj_business_group_id);

     /* Populate JIT information which is used when doing
        balance adjustment */
     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 15);
     pay_us_payroll_utils.populate_jit_information(
                p_effective_date => ld_adj_start_date
               ,p_get_state      => 'Y');

     ln_step := 8;

  exception
   when others then
     hr_utility.set_location(gv_package || lv_procedure_name, 500);
     lv_error_message := 'Error at step ' || ln_step ||
                         ' in ' || gv_package || lv_procedure_name;
     hr_utility.trace(lv_error_message || '-' || sqlerrm);

     hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
     hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
     hr_utility.raise_error;

  END initialize;


  /******************************************************************
   Name      : deinitialize
   Purpose   : This is the last procedure to be called by PYUGEN.
   Arguments :
   Notes     :
  *******************************************************************/
  PROCEDURE deinitialize(
                p_payroll_action_id in number)
  IS

    ln_count_incomplete_actions NUMBER;
    ln_badj_payroll_Action_id   NUMBER;

    cursor c_get_badj_payroll_action (cp_payroll_action_id in number) is
      select prt.value2
        from pay_us_rpt_totals prt
       where prt.location_id = cp_payroll_action_id;

  BEGIN

     select count(*)
       into ln_count_incomplete_actions
       from pay_assignment_actions
      where payroll_action_id = p_payroll_action_id
        and action_status <> 'C';

     if ln_count_incomplete_actions = 0 then

        open c_get_badj_payroll_action(p_payroll_action_id);
        loop
           fetch c_get_badj_payroll_action into ln_badj_payroll_Action_id;
           if c_get_badj_payroll_action%notfound then
              exit;
           end if;

           if ln_badj_payroll_Action_id is not null then
              pay_bal_adjust.process_batch(ln_badj_payroll_Action_id);
           end if;

        end loop;
        close c_get_badj_payroll_action;


        delete from pay_us_rpt_totals
         where location_id = p_payroll_action_id;

        delete from pay_action_information
         where ACTION_CONTEXT_ID = p_payroll_action_id
           and ACTION_CONTEXT_TYPE = 'PPA';

        pay_archive.remove_report_actions(p_payroll_action_id);

     end if;

  END deinitialize;


  PROCEDURE run_preprocess(
                p_assignment_action_id number
               ,p_effective_date in date)
  IS
    l_payroll_action_id pay_assignment_actions.payroll_action_id%type;
    l_chunk_number      pay_assignment_actions.chunk_number%type;

    cursor cur_assignment_action_info
              (cp_assignment_action_id in number) is
     select
            to_date(substr(paa.serial_number,1,8),'ddmmyyyy') sort_date,
            paa.assignment_id,
            paa.tax_unit_id,
            paa.payroll_action_id,
            to_number(substr(paa.serial_number,9)) bal_asg_action_id
       from pay_assignment_actions paa
      where paa.assignment_action_id = cp_assignment_action_id;

    cursor get_asg_run_info(cp_run_action_id in number) is
      select payroll_id, consolidation_set_id
        from pay_payroll_actions ppa
            ,pay_assignment_actions paa
       where ppa.payroll_Action_id = paa.payroll_action_id
         and paa.assignment_action_id = cp_run_action_id;

    cursor csr_chk_state(cp_assignment_id    in number
                        ,cp_effective_date   in date
                        ,cp_where_state_code in varchar2) IS
      select st.state_code, st.jurisdiction_code
        from pay_us_emp_state_tax_rules_f st
       where st.assignment_id = cp_assignment_id
         and st.state_code like cp_where_state_code
         and cp_effective_date between st.effective_start_date
                                   and st.effective_end_date;

    cursor csr_get_badj_action(cp_payroll_action_id   in number
                              ,cp_badj_effective_Date in date
                              ,cp_run_payroll_id      in number
                              ,cp_consolidation_id    in number) IS
      select value2 badj_payroll_Action,
             value3 business_group_id
        from pay_us_rpt_totals prt
       where prt.location_id = cp_payroll_action_id
         and to_date(lpad(to_char(prt.organization_id),8,'0'),'ddmmyyyy')
                       = cp_badj_effective_date
         and tax_unit_id = cp_run_payroll_id
         and value1 = cp_consolidation_id;

   cursor c_get_per_latest_action(cp_assignment_id      number
                                 ,cp_tax_unit_id        number) is
      select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N51)
                 INDEX(ppa PAY_PAYROLL_ACTIONS_PK) */
             paa.assignment_action_id
        from pay_assignment_actions     paa,
             per_all_assignments_f      paf,
             per_all_assignments_f      paf1,
             pay_payroll_actions        ppa
       where paf1.assignment_id = cp_assignment_id
         and paf.person_id     = paf1.person_id
         and paa.assignment_id = paf.assignment_id
         and paa.tax_unit_id   = cp_tax_unit_id
         and paa.payroll_action_id = ppa.payroll_action_id
         and ppa.action_type in ('R', 'Q', 'B', 'V', 'I')
         and ppa.effective_date  between paf.effective_start_date
                                     and paf.effective_end_date
         and ppa.effective_date between to_date('2004/01/01', 'yyyy/mm/dd')
                                    and to_date('2004/12/31', 'yyyy/mm/dd')
        order by paa.action_sequence desc;

    ld_run_effective_date     DATE;
    ln_assignment_id          NUMBER;
    ln_tax_unit_id            NUMBER;
    ln_bal_asg_action_id      NUMBER;
    ln_adj_payroll_action_id  NUMBER;
    lv_adj_state_abbrev       VARCHAR2(2);

    ln_run_payroll_id         NUMBER;
    ln_run_consolidation_id   NUMBER;


    ln_business_group_id      NUMBER;
    ln_badj_payroll_action_id NUMBER;

    ln_per_max_run_action_id  NUMBER;


    lv_where_state_code       VARCHAR2(2);
    lv_state_code             VARCHAR2(2);
    lv_jurisdiction           VARCHAR2(11);
    lv_sit_exists             VARCHAR2(2);

    lv_balance_name           VARCHAR2(80);
    lv_element_name           VARCHAR2(80);
    ln_element_type_id        NUMBER;
    lv_input_name             VARCHAR2(80);
    ln_ytd_def_bal_id         NUMBER;
    ln_input_value_id         NUMBER;


    lv_procedure_name         VARCHAR2(100);
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;

    ln_bal_value              NUMBER;
    ln_badj_bal_value         NUMBER;
    ln_taxable_bal_value      NUMBER;
    ln_redu_subj_bal_value    NUMBER;
    ln_subj_bal_value         NUMBER;
    ln_pre_tax_bal_value      NUMBER;
    ln_sdi_er_wage_limit        NUMBER;
    lv_sit_adj_flag           VARCHAR2(1);
    lv_sdi_adj_flag           VARCHAR2(1);

    ln_sub_ele_link_id NUMBER;
    ln_sub2_ele_link_id NUMBER;
    ln_misc_ele_link_id  NUMBER;

    --type inp_val_table IS TABLE of pay_input_values.input_value_id%type
    --index by binary_integer;

    --type entry_val_table is table of varchar2(80)
    -- index by binary_integer;

    sub_input_value_table  hr_entry.number_table;
    sub2_input_value_table  hr_entry.number_table;
    misc_input_value_table  hr_entry.number_table;

    sub_entry_value_table  hr_entry.varchar2_table;
    sub2_entry_value_table  hr_entry.varchar2_table;
    misc_entry_value_table  hr_entry.varchar2_table;

    ln_count1       NUMBER;
    ln_count2       NUMBER;
    ln_count3       NUMBER;
    lv_sub2_jd_flag VARCHAR2(1) ;
    lv_sub_jd_flag  VARCHAR2(1) ;
    lv_misc_jd_flag VARCHAR2(1) ;
  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 5);
     lv_procedure_name        := '.preprocess_run';
     ln_bal_value             := 0;
     ln_badj_bal_value        := 0;

     ln_assignment_id         := -1;
     ln_tax_unit_id           := -1;
     ln_adj_payroll_action_id := -1;
     ln_bal_asg_action_id     := -1;

     ln_ytd_def_bal_id        := -1;
     ln_input_value_id        := -1;

     select payroll_action_id,
            chunk_number
       into l_payroll_action_id,
            l_chunk_number
       from pay_assignment_actions
      where assignment_action_id = p_assignment_action_id;
     --
     process_min_chunk(p_payroll_action_id => l_payroll_action_id,
                       p_chunk_number      => l_chunk_number);
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     --
     -- The data in pay_us_rpt_totals has been cleanup, so start
     -- the balance adjustment process
     lv_sit_adj_flag     := 'N';
     lv_sdi_adj_flag     := 'N';
     ln_step := 1;

     open cur_assignment_action_info(p_assignment_action_id);
     fetch cur_assignment_action_info into
                                 ld_run_effective_date,
                                 ln_assignment_id,
                                 ln_tax_unit_id,
                                 ln_adj_payroll_action_id,
                                 ln_bal_asg_action_id;
     close cur_assignment_action_info;

     open get_asg_run_info(ln_bal_asg_action_id);
     fetch get_asg_run_info into ln_run_payroll_id, ln_run_consolidation_id;
     if get_asg_run_info%notfound then
        hr_utility.trace('Payroll and Consolidation Set Not Found for Run');
        hr_utility.raise_error;
     end if;
     close get_asg_run_info;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);
     hr_utility.trace('ln_assignment_id = ' || ln_assignment_id);
     hr_utility.trace('ln_run_payroll_id = '|| ln_run_payroll_id);
     hr_utility.trace('ln_run_consolidation_id = '
                                            || ln_run_consolidation_id);

     -- get New Payroll Action ID and Business Group ID
     -- for the given sort_date, Payroll and Consolidation Set
     open csr_get_badj_action(ln_adj_payroll_action_id
                             ,ld_run_effective_date
                             ,ln_run_payroll_id
                             ,ln_run_consolidation_id);
     fetch csr_get_badj_action into ln_badj_payroll_action_id,
                                    ln_business_group_id;
     if csr_get_badj_action%notfound then
        hr_utility.trace('ERROR:No Payrol_action_ID found for Sort_Date');
        hr_utility.raise_error;
     end if;
     close csr_get_badj_action;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     hr_utility.trace('ln_badj_payroll_action_id = ' ||
                       ln_badj_payroll_action_id);
     hr_utility.trace('ln_business_group_id = ' ||
                       ln_business_group_id);

     -- get assignment derived jurisdiction  for state
     if g_adj_state_code is null then
        lv_where_state_code := '%';
     else
        lv_where_state_code := g_adj_state_code;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 51);
     open csr_chk_state(ln_assignment_id,
                        ld_run_effective_date,
                        lv_where_state_code);
     loop
        hr_utility.set_location(gv_package || lv_procedure_name, 52);
        fetch csr_chk_state into lv_state_code,
                                 lv_jurisdiction;

        exit when csr_chk_state%NOTFOUND;

        ln_bal_value             := 0;
        ln_badj_bal_value        := 0;
        lv_misc_jd_flag := 'N';
        lv_sub2_jd_flag := 'N';
        lv_sub_jd_flag := 'N';

        hr_utility.set_location(gv_package || lv_procedure_name, 60);
        hr_utility.trace('lv_state_code = ' || lv_state_code);
        hr_utility.trace('Jurisdiction = ' || lv_jurisdiction);

        -- Set Context : TAX_UNIT_ID
        pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
        -- Set Context : JURISDICTION_CODE
        pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction);


        if g_adj_state_code is null then
           lv_sit_exists
               := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sit_exists;
        else
           lv_sit_exists
               := pay_get_tax_exists_pkg.get_tax_exists (
                        p_juri_code   => lv_state_code
                       ,p_date_earned => ld_run_effective_date
                       ,p_tax_unit_id => ln_tax_unit_id
                       ,p_assign_id   => ln_assignment_id
                       ,p_type        => 'SIT_RS');
        end if;
        hr_utility.trace('SIT_Exists = ' || lv_sit_exists);

        if lv_sit_exists = 'N' then
           if pay_us_emp_baladj_cleanup.ltr_sit_tax_bal.count > 0 then
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
              lv_balance_name
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).balance_name;
              ln_ytd_def_bal_id
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).ytd_def_bal_id;
              lv_element_name
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).element_name;
              ln_element_type_id
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).element_type_id;
              lv_input_name
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).input_name;
              ln_input_value_id
                     := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(0).input_value_id;
              hr_utility.trace('lv_balance_name   =' || lv_balance_name);
              hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
              hr_utility.trace('lv_element_name=' || lv_element_name);
              hr_utility.trace('lv_input_name=' || lv_input_name);
              hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

              ln_bal_value := 0;
              ln_bal_value := get_balance_value(
                                   p_defined_balance_id => ln_ytd_def_bal_id
                                  ,p_balcall_aaid       => ln_bal_asg_action_id);

              IF ln_bal_value <> 0 THEN
                 for j in pay_us_emp_baladj_cleanup.ltr_sit_tax_bal.first..
                          pay_us_emp_baladj_cleanup.ltr_sit_tax_bal.last loop

                     if j > 0 then
                        lv_balance_name
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).balance_name;
                        ln_ytd_def_bal_id
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).ytd_def_bal_id;
                        lv_element_name
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).element_name;
                        ln_element_type_id
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).element_type_id;
                        lv_input_name
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).input_name;
                        ln_input_value_id
                           := pay_us_emp_baladj_cleanup.ltr_sit_tax_bal(j).input_value_id;

                        hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                        hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                        hr_utility.trace('lv_element_name=' || lv_element_name);
                        hr_utility.trace('lv_input_name=' || lv_input_name);
                        hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                        ln_bal_value     := 0;
                        ln_bal_value := get_balance_value(
                                          p_defined_balance_id => ln_ytd_def_bal_id
                                         ,p_balcall_aaid       => ln_bal_asg_action_id);
                     end if;
                     --****************************************************
                     -- Keeping this outside the above if statement as the
                     -- call for
                     -- Gross is done outside the pl/sql table loop but process
                     -- elements needs to be called for Gross as well as other
                     -- balances
                     --****************************************************
                     ln_badj_bal_value := ln_bal_value * (-1);

                     if substr(lv_element_name,1,12) = 'SIT_SUBJECT2' then
                        if lv_sub2_jd_flag = 'N' then
                           ln_count2 := sub2_input_value_table.count+1;
                           --Set Input Value of Jurisdiction
                           sub2_input_value_table(ln_count2)
                               :=  pay_us_emp_baladj_cleanup.get_input_value_id(
                                            p_element_type_id  => ln_element_type_id
                                           ,p_input_value_name => 'Jurisdiction'
                                           ,p_effective_date   => ld_run_effective_date);
                           sub2_entry_value_table(ln_count2) :=  lv_jurisdiction;
                           lv_sub2_jd_flag  := 'Y';
                        end if;

                        ln_count2 := sub2_input_value_table.count+1;
                        sub2_input_value_table(ln_count2) :=  ln_input_value_id;
                        sub2_entry_value_table(ln_count2) :=  ln_badj_bal_value;

                        hr_utility.set_location(gv_package || lv_procedure_name, 90);
                        ln_sub2_ele_link_id := hr_entry_api.get_link(
                                                  p_assignment_id   => ln_assignment_id,
                                                  p_element_type_id => ln_element_type_id,
                                                  p_session_date    => ld_run_effective_date);
                        hr_utility.trace('Link SIT SUBJ 2 ='||ln_sub2_ele_link_id);

                        IF (ln_sub2_ele_link_id IS NULL) THEN
                           hr_utility.set_location(gv_package||lv_procedure_name, 110);
                           hr_utility.set_message(801, 'PY_51132_TXADJ_LINK_MISSING');
                           hr_utility.set_message_token ('ELEMENT', lv_element_name);
                           hr_utility.raise_error;
                        END IF;


                     else -- SIT_SUBJECT
                        hr_utility.set_location(gv_package || lv_procedure_name, 120);
                        if lv_sub_jd_flag = 'N' then
                           ln_count1 := sub_input_value_table.count+1;
                           --Set Input Value of Jurisdiction
                           sub_input_value_table(ln_count1)
                                 :=  pay_us_emp_baladj_cleanup.get_input_value_id(
                                             p_element_type_id  => ln_element_type_id
                                            ,p_input_value_name => 'Jurisdiction'
                                            ,p_effective_date   => ld_run_effective_date);
                           sub_entry_value_table(ln_count1) :=  lv_jurisdiction;
                           lv_sub_jd_flag := 'Y';
                        end if;
                        ln_count1 := sub_input_value_table.count+1;
                        sub_input_value_table(ln_count1) :=   ln_input_value_id;
                        sub_entry_value_table(ln_count1) := ln_badj_bal_value;

                        hr_utility.set_location(gv_package ||
                                                     lv_procedure_name, 130);
                        ln_sub_ele_link_id
                                 := hr_entry_api.get_link(
                                       p_assignment_id   => ln_assignment_id,
                                       p_element_type_id => ln_element_type_id,
                                       p_session_date    => ld_run_effective_date);
                        hr_utility.trace('Link SIT SUBJ ='||
                                              ln_sub_ele_link_id);
                        IF ln_sub_ele_link_id IS NULL THEN
                           hr_utility.set_location(gv_package||
                                                        lv_procedure_name,140);
                           hr_utility.set_message(
                                           801, 'PY_51132_TXADJ_LINK_MISSING');
                           hr_utility.set_message_token('ELEMENT',
                                                             lv_element_name);
                           hr_utility.raise_error;
                        END IF;

                     end if;

                 end loop; -- of ltr_sit_tax_bal)
              END IF;  -- (ln_gross <> 0)
           end if;


           hr_utility.set_location(gv_package||lv_procedure_name, 150);
           if sub2_entry_value_table.count > 0 then
              for i in sub2_entry_value_table.first ..
                       sub2_entry_value_table.last loop
                  hr_utility.trace('SIT2 entry' ||i||' = '||
                                   sub2_entry_value_table(i));
              end loop;
              for i in sub2_input_value_table.first ..
                       sub2_input_value_table.last loop
                  hr_utility.trace('SIT2 input'||i||' = '||
                                         sub2_input_value_table(i));
              end loop;

              hr_utility.set_location(gv_package ||
                                           lv_procedure_name, 160);
              pay_bal_adjust.adjust_balance(
                            p_batch_id         => ln_badj_payroll_action_id,
                            p_assignment_id    => ln_assignment_id,
                            p_element_link_id  => ln_sub2_ele_link_id,
                            p_num_entry_values => sub2_entry_value_table.count,
                            p_entry_value_tbl  => sub2_entry_value_table,
                            p_input_value_id_tbl    => sub2_input_value_table,
                            p_balance_adj_cost_flag => 'N');
           end if;
           if sub_input_value_table.count > 0 then
              for i in sub_entry_value_table.first ..
                       sub_entry_value_table.last loop
                  hr_utility.trace('SIT entry' ||i||' = '||
                                   sub_entry_value_table(i));
              end loop;
              for i in sub_input_value_table.first ..
                       sub_input_value_table.last loop
                  hr_utility.trace('SIT input'||i||' = '||
                                   sub_input_value_table(i));
              end loop;
              hr_utility.set_location(gv_package ||
                                           lv_procedure_name, 170);
              pay_bal_adjust.adjust_balance(
                            p_batch_id         => ln_badj_payroll_action_id,
                            p_assignment_id    => ln_assignment_id,
                            p_element_link_id  => ln_sub_ele_link_id,
                            p_num_entry_values => sub_entry_value_table.count,
                            p_entry_value_tbl  => sub_entry_value_table,
                            p_input_value_id_tbl    => sub_input_value_table,
                            p_balance_adj_cost_flag => 'N');
           end if;

           hr_utility.set_location(gv_package || lv_procedure_name, 200);

           -- initialize tables
           sub_input_value_table.delete;
           sub2_input_value_table.delete;
           sub_entry_value_table.delete;
           sub2_entry_value_table.delete;

        end if; -- sit exists

        --------------------------------------------------------------
        --State is Not  'MA'
        --
        if lv_state_code <> '22' then
           --
              -- SDI ER
              --
              ln_bal_value             := 0;
              ln_badj_bal_value        := 0;
              lv_sub_jd_flag  := 'N';
              lv_sub2_jd_flag := 'N';
              if pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit
                      is null then
                 hr_utility.set_location(gv_package || lv_procedure_name, 210);
                 hr_utility.trace('Jurisdiction = ' || lv_jurisdiction);
                 if pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal.count > 0 then
                    lv_balance_name
                          := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).balance_name;
                    ln_ytd_def_bal_id
                          := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).ytd_def_bal_id;
                    lv_element_name
                          := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).element_name;
                    ln_element_type_id
                              := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).element_type_id;
                    lv_input_name
                          := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).input_name;
                    ln_input_value_id
                          := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(0).input_value_id;

                    hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                    hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                    hr_utility.trace('lv_element_name=' || lv_element_name);
                    hr_utility.trace('lv_input_name=' || lv_input_name);
                    hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                    ln_bal_value := 0;
                    ln_bal_value := get_balance_value(
                                  p_defined_balance_id => ln_ytd_def_bal_id
                                 ,p_balcall_aaid       => ln_bal_asg_action_id);

                    IF ln_bal_value <> 0 THEN
                       for k in pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal.first..
                                pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal.last loop
                           if k > 0 then
                              lv_balance_name
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).balance_name;
                              ln_ytd_def_bal_id
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).ytd_def_bal_id;
                              lv_element_name
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).element_name;
                              ln_element_type_id
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).element_type_id;
                              lv_input_name
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).input_name;
                              ln_input_value_id
                               := pay_us_emp_baladj_cleanup.ltr_sdi_er_tax_bal(k).input_value_id;

                              hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                              hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                              hr_utility.trace('lv_element_name=' || lv_element_name);
                              hr_utility.trace('lv_input_name=' || lv_input_name);
                              hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                              ln_bal_value     := 0;
                              ln_bal_value := get_balance_value(
                                                 p_defined_balance_id => ln_ytd_def_bal_id
                                                ,p_balcall_aaid       => ln_bal_asg_action_id);
                           end if;
                           ln_badj_bal_value := -1 * ln_bal_value;

                           if substr(lv_element_name,1,12) = 'SDI_SUBJECT2' then

                              if lv_sub2_jd_flag = 'N' then
                                 ln_count2 := sub2_input_value_table.count+1;
                                 --Set Input Value of Jurisdiction
                                 sub2_input_value_table(ln_count2)
                                        :=  pay_us_emp_baladj_cleanup.get_input_value_id(
                                               p_element_type_id  => ln_element_type_id
                                              ,p_input_value_name => 'Jurisdiction'
                                              ,p_effective_date   => ld_run_effective_date);
                                 sub2_entry_value_table(ln_count2) :=  lv_jurisdiction;
                                 lv_sub2_jd_flag  := 'Y';
                              end if;

                              ln_count2 := sub2_input_value_table.count+1;
                              sub2_input_value_table(ln_count2) :=  ln_input_value_id;
                              sub2_entry_value_table(ln_count2) :=  ln_badj_bal_value;

                              hr_utility.set_location(gv_package || lv_procedure_name, 30);

                              ln_sub2_ele_link_id := hr_entry_api.get_link(
                                                       p_assignment_id   => ln_assignment_id,
                                                       p_element_type_id => ln_element_type_id,
                                                       p_session_date    => ld_run_effective_date);
                                hr_utility.trace('Link SDI ER SUBJ 2 ='||ln_sub2_ele_link_id);

                                IF (ln_sub2_ele_link_id IS NULL) THEN
                                   hr_utility.set_location(gv_package || lv_procedure_name, 40);
                                   hr_utility.set_message(801, 'PY_51132_TXADJ_LINK_MISSING');
                                   hr_utility.set_message_token ('ELEMENT', lv_element_name);
                                   hr_utility.raise_error;
                                END IF;


                           else
                              if lv_sub_jd_flag = 'N' then
                                 ln_count1 := sub_input_value_table.count+1;
                                 --Set Input Value of Jurisdiction
                                 sub_input_value_table(ln_count1)
                                        :=  pay_us_emp_baladj_cleanup.get_input_value_id(
                                               p_element_type_id  => ln_element_type_id
                                              ,p_input_value_name => 'Jurisdiction'
                                              ,p_effective_date   => ld_run_effective_date);
                                 sub_entry_value_table(ln_count1) :=  lv_jurisdiction;
                                 lv_sub_jd_flag := 'Y';
                              end if;
                              ln_count1 := sub_input_value_table.count+1;
                              sub_input_value_table(ln_count1) :=   ln_input_value_id;
                              sub_entry_value_table(ln_count1) :=   ln_badj_bal_value;

                              hr_utility.set_location(gv_package || lv_procedure_name, 250);
                              ln_sub_ele_link_id := hr_entry_api.get_link(
                                                       p_assignment_id   => ln_assignment_id,
                                                       p_element_type_id => ln_element_type_id,
                                                       p_session_date    => ld_run_effective_date);
                                hr_utility.trace('Link SDI ER SUBJ ='||ln_sub_ele_link_id);
                                IF (ln_sub_ele_link_id IS NULL) THEN
                                   hr_utility.set_location(gv_package || lv_procedure_name, 40);
                                   hr_utility.set_message(801, 'PY_51132_TXADJ_LINK_MISSING');
                                   hr_utility.set_message_token ('ELEMENT', lv_element_name);
                                   hr_utility.raise_error;
                                END IF;

                           end if;

                       end loop; -- of ltr_sdi_er_tax_bal)
                    END IF;  -- (ln_gross <> 0)
                 end if;

                 hr_utility.set_location(gv_package||lv_procedure_name, 240);
                 if sub2_entry_value_table.count > 0 then
                    for i in sub2_entry_value_table.first ..
                             sub2_entry_value_table.last loop
                        hr_utility.trace('SDI2 entry' ||i||'='||
                                          sub2_entry_value_table(i));
                    end loop;
                    for i in sub2_input_value_table.first ..
                             sub2_input_value_table.last loop
                        hr_utility.trace('SDI2 input'||i||'='||
                                          sub2_input_value_table(i));
                    end loop;
                    hr_utility.set_location(gv_package||lv_procedure_name,250);

                    pay_bal_adjust.adjust_balance(
                             p_batch_id         => ln_badj_payroll_action_id,
                             p_assignment_id    => ln_assignment_id,
                             p_element_link_id  => ln_sub2_ele_link_id,
                             p_num_entry_values => sub2_entry_value_table.count,
                             p_entry_value_tbl  => sub2_entry_value_table,
                             p_input_value_id_tbl    => sub2_input_value_table,
                             p_balance_adj_cost_flag => 'N');
                 end if;

                 if sub_input_value_table.count > 0 then
                    for i in sub_entry_value_table.first ..
                             sub_entry_value_table.last loop
                        hr_utility.trace('SDI entry'||i||'='||
                                          sub_entry_value_table(i));
                    end loop;
                    for i in sub_input_value_table.first ..
                             sub_input_value_table.last loop
                        hr_utility.trace('SDI input'||i||'='||
                                          sub_input_value_table(i));
                    end loop;
                    hr_utility.set_location(gv_package||lv_procedure_name,260);
                    pay_bal_adjust.adjust_balance(
                             p_batch_id         => ln_badj_payroll_action_id,
                             p_assignment_id    => ln_assignment_id,
                             p_element_link_id  => ln_sub_ele_link_id,
                             p_num_entry_values => sub_entry_value_table.count,
                             p_entry_value_tbl  => sub_entry_value_table,
                             p_input_value_id_tbl    => sub_input_value_table,
                             p_balance_adj_cost_flag => 'N');
                 end if;


                 hr_utility.set_location(gv_package || lv_procedure_name, 270);


                 -- initialize tables
                 sub_input_value_table.delete;
                 sub2_input_value_table.delete;

                 sub_entry_value_table.delete;
                 sub2_entry_value_table.delete;
              end if; -- sdi er exists
              hr_utility.set_location(gv_package || lv_procedure_name, 300);

           else
                hr_utility.trace('Jurisdiction = ' || lv_jurisdiction);
              -- For 'MA'
              -- Compare Work Location Jurisdiction to SUI Jurisdiction
              -- IF equal then do balance call and adjust the balance as follow
              -- If not then push message into message lines.
              -- Balance : SDI ER Taxable
              -- Element : MISC1_STATE_TAX_ER
              -- Input Value : Taxable
              -- Input Value : Jurisdiction
              -- Get least of Reduced Subh WH , SDI ER LIMIT
              -- Difference of SDI ER Taxable and  least of Reduced Subh WH or SDI ER LIMIT

              lv_sub_jd_flag  := 'N';
              ln_badj_bal_value := 0;
              ln_redu_subj_bal_value := 0;
              ln_sdi_er_wage_limit := pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit;
              hr_utility.trace('SDI ER Wage Limit = ' || ln_sdi_er_wage_limit);

              open c_get_per_latest_action(ln_assignment_id
                                      ,ln_tax_unit_id);
              fetch c_get_per_latest_action into ln_per_max_run_action_id;
              close c_get_per_latest_action;
              hr_utility.trace('ln_per_max_run_action_id = ' || ln_per_max_run_action_id);

              if pay_us_payroll_utils.ltr_state_tax_info(lv_state_code).sdi_er_limit
                      is not null then
                 hr_utility.set_location(gv_package || lv_procedure_name, 170);
                 hr_utility.trace('Jurisdiction = ' || lv_jurisdiction);
                 if pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal.count > 0 then
                    lv_balance_name
                          := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).balance_name;
                    ln_ytd_def_bal_id
                          := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).ytd_def_bal_id;
                    lv_element_name
                          := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).element_name;
                    ln_element_type_id
                              := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).element_type_id;
                    lv_input_name
                          := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).input_name;
                    ln_input_value_id
                          := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(0).input_value_id;

                    hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                    hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                    hr_utility.trace('lv_element_name=' || lv_element_name);
                    hr_utility.trace('lv_input_name=' || lv_input_name);
                    hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                    ln_subj_bal_value := 0;
                    ln_subj_bal_value := get_balance_value(
                                  p_defined_balance_id => ln_ytd_def_bal_id
                                 ,p_balcall_aaid       => ln_per_max_run_action_id);
                    hr_utility.trace('ln_subj_bal_value =' || ln_subj_bal_value);

                    IF ln_subj_bal_value <> 0 THEN
                       lv_balance_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).balance_name;
                       ln_ytd_def_bal_id
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).ytd_def_bal_id;
                       lv_element_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).element_name;
                       ln_element_type_id
                         :=pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).element_type_id;
                       lv_input_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).input_name;
                       ln_input_value_id
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(1).input_value_id;

                       hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                       hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                       hr_utility.trace('lv_element_name=' || lv_element_name);
                       hr_utility.trace('lv_input_name=' || lv_input_name);
                       hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                       ln_pre_tax_bal_value := 0;
                       ln_pre_tax_bal_value := get_balance_value(
                                  p_defined_balance_id => ln_ytd_def_bal_id
                                 ,p_balcall_aaid       => ln_per_max_run_action_id);
                       hr_utility.trace('ln_pre_tax_bal_value =' || ln_pre_tax_bal_value);

                       -- Reduced Subject
                       ln_redu_subj_bal_value := ln_subj_bal_value - ln_pre_tax_bal_value;
                       hr_utility.trace('ln_redu_subj_bal_value ='||ln_redu_subj_bal_value);
                       lv_balance_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).balance_name;
                       ln_ytd_def_bal_id
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).ytd_def_bal_id;
                       lv_element_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).element_name;
                       ln_element_type_id
                         :=pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).element_type_id;
                       lv_input_name
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).input_name;
                       ln_input_value_id
                         := pay_us_emp_baladj_cleanup.ltr_misc_er_tax_bal(2).input_value_id;

                       hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                       hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                       hr_utility.trace('lv_element_name=' || lv_element_name);
                       hr_utility.trace('lv_input_name=' || lv_input_name);
                       hr_utility.trace('ln_input_value_id =' || ln_input_value_id);

                       ln_taxable_bal_value     := 0;
                       ln_taxable_bal_value := get_balance_value(
                                               p_defined_balance_id => ln_ytd_def_bal_id
                                              ,p_balcall_aaid  => ln_per_max_run_action_id);
                       hr_utility.trace('ln_taxable_bal_value =' || ln_taxable_bal_value);
                    END IF;  -- (ln_sub whable <> 0)
                 end if; --count > 0


                 hr_utility.trace('TAXXABLE   = ' || ln_taxable_bal_value);
                 hr_utility.trace('WAGE LIMIT = ' || ln_sdi_er_wage_limit);
                 hr_utility.trace('RED SUBJ   = ' || ln_redu_subj_bal_value);
                 if ln_taxable_bal_value < ln_sdi_er_wage_limit then
                    ln_badj_bal_value := (least(ln_sdi_er_wage_limit,
                                                ln_redu_subj_bal_value)
                                           - ln_taxable_bal_value);

                    hr_utility.trace('taxable<SDI ER ln_badj_bal_value =' ||
                                      ln_badj_bal_value);

                    if substr(lv_element_name,1,18) = 'MISC1_STATE_TAX_ER' then
                       if lv_misc_jd_flag = 'N' then
                          ln_count3 := misc_input_value_table.count+1;
                          --Set Input Value of Jurisdiction
                          misc_input_value_table(ln_count3)
                                   :=  pay_us_emp_baladj_cleanup.get_input_value_id(
                                               p_element_type_id  => ln_element_type_id
                                           ,p_input_value_name => 'Jurisdiction'
                                           ,p_effective_date   => ld_run_effective_date);
                          misc_entry_value_table(ln_count3) :=  lv_jurisdiction;
                          lv_misc_jd_flag  := 'Y';
                       end if;

                       ln_count3 := misc_input_value_table.count+1;
                       misc_input_value_table(ln_count3) :=  ln_input_value_id;
                       misc_entry_value_table(ln_count3) :=  ln_badj_bal_value;

                       hr_utility.set_location(gv_package||lv_procedure_name,180);

                       ln_misc_ele_link_id := hr_entry_api.get_link(
                                                 p_assignment_id   => ln_assignment_id,
                                                 p_element_type_id => ln_element_type_id,
                                                 p_session_date    => ld_run_effective_date);
                       hr_utility.trace('Link MISC1 ER ='||ln_misc_ele_link_id);

                       IF (ln_misc_ele_link_id IS NULL) THEN
                          hr_utility.set_location(gv_package ||
                                                  lv_procedure_name, 40);
                          hr_utility.set_message(801,
                                                 'PY_51132_TXADJ_LINK_MISSING');
                          hr_utility.set_message_token ('ELEMENT',
                                                        lv_element_name);
                          hr_utility.raise_error;
                       END IF;

                    end if;

                    hr_utility.set_location(gv_package||lv_procedure_name, 150);
                    if misc_entry_value_table.count > 0 then
                       for i in misc_entry_value_table.first ..
                                misc_entry_value_table.last loop
                           hr_utility.trace('SDI entry' ||i||'='||
                                               misc_entry_value_table(i));
                       end loop;
                    end if;
                    if misc_input_value_table.count > 0 then
                       for i in misc_input_value_table.first ..
                                misc_input_value_table.last loop
                           hr_utility.trace('SDI input'||i||'='|| misc_input_value_table(i));
                       end loop;
                    end if;

                    if ln_badj_bal_value <> 0 then
                       pay_bal_adjust.adjust_balance(
                             p_batch_id              => ln_badj_payroll_action_id,
                             p_assignment_id         => ln_assignment_id,
                             p_element_link_id       => ln_misc_ele_link_id,
                             p_num_entry_values      => misc_entry_value_table.count,
                             p_entry_value_tbl       => misc_entry_value_table,
                             p_input_value_id_tbl    => misc_input_value_table,
                             p_balance_adj_cost_flag => 'N');

                       hr_utility.set_location(gv_package || lv_procedure_name, 200);
                    end if;
                 end if;
              end if; --misc1 tax er
           end if; -- end of State if


         end loop; --) state jurisdiction loop
       close csr_chk_state;
       hr_utility.set_location(gv_package || lv_procedure_name, 300);

     ln_step := 5;

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END run_preprocess;

begin
--hr_utility.trace_on (null, 'BAL');

  gv_package  := 'pay_us_emp_baladj_cleanup';
  g_proc_init := FALSE;
  g_min_chunk := -1;
end pay_us_emp_baladj_cleanup;

/
