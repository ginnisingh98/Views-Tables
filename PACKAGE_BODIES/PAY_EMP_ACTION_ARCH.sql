--------------------------------------------------------
--  DDL for Package Body PAY_EMP_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EMP_ACTION_ARCH" AS
/* $Header: pyempxfr.pkb 120.10.12010000.14 2010/04/15 15:11:31 sjawid ship $ */
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

    Name        : pay_emp_action_arch

    Description : This package populates the global data
                  for payslip in pay_action_information table.
                  The action_information_categories that it
                  populates are:
                     - EMPLOYEE DEATLS
                     - ADDRESS DETAILS
                     - EMPLOYEE NET PAY DISTRIBUTION
                     - EMPLOYEE ACCRUALS.

    Uses        :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    27-JUL-2001 asasthan   115.0            Created.
    19-AUG-2001 ahanda     115.1            Changed package to populate
                                            Employer Address and Message
                                            again the payroll_action_id.
                                            Also, caching values so that
                                            we can save DB calls.
                                            Added debug stmt and formated
    28-AUG-2001 asasthan   115.2            Changed net pay distribution
                                            and employee details.
    29-AUG-2001 asasthan   115.3            Addedc some hr_utility messages.
    17-SEP-2001 asasthan   115.4            Added pre_payment_id in
                                            action_information16 for
                                            EMPLOYEE NET PAY DISTRIBUTION.
    18-SEP-2001 asasthan   115.5            Added pre_payment_assignment_action
                                            to EMPLOYEE NET PAY DISTRIBUTION.
    08-OCT-2001 asasthan   115.6            c_net_pay now gets only rows where
                                            defined_balance_id is not null
                                            Third Party rows are not archived
    15-OCT-2001 asasthan   115.7            c_net_pay now archives
                                            org_payment_method_name
                                            For Employee Other Infoormation
                                            will archive only those balances
                                            that have a value > 0
    29-NOV-2001 asasthan  115.9             Changes for in-house Bug 2120442
                                            #1 Added the parameter p_run_pactid
                                            in get_personal_info
                                            #2 pay_us_emp_payslip_accrual_web.
                                            get_emp_net_accrual now
                                            is being passed the payroll action
                                            id of run('R') and  not of ('P,'U')
    12-DEC-2001 asasthan  115.10            Defaulted p_run_pactid in
                                            get_personal_info
    22-JAN-2002 ahanda    115.11            Changed package to take care
                                            of Multi Assignment Processing.
    22-JAN-2002 ahanda    115.12            Changed dbdrv command.
    28-JAN-2002 ahanda    115.13            Changed Net Pay Dist. to store
                                            Org and Personal Payment Method ID.
    29-JAN-2002 ahanda    115.14            Added dbdrv commands.
    19-FEB-2002 ahanda    115.15            Added functions
                                              - get_multi_legislative_rule
                                              - get_multi_assignment_flag.
    24-APR-2002 ahanda    115.17            Changed cursor c_get_organization in
                                            arch_pay_action_level_data for
                                            performance.Disabled index on column
                                            element_type_id for cursor
                                            c_regular_salary and c_houly salary.
    13-JUN-2002 vpandya   115.18            'Employer Address', now postal_code
                                            archives in act_info12 and region_3
                                            archives in act_ino11.
    17-JUN-2002 ahanda    115.19            Added code to archive Steps for each
                                            assignment.
    16-JUL-2002 ahanda    115.20            Changed insert_rows_thro_api_process
                                            to insert data only if PL/SQL table
                                            is populated.
    15-AUG-2002 ahanda    115.21            Changed get_proposed_emp_salary for
                                            performance.
    27-SEP-2002 sodhingr  115.22            Changed get_personal_information
					    for GSCC compliance (removed default
                                            clause)
    01-NOV-2002 ahanda    115.23            Changed func get_defined_balance_id
                                            to not error out if defbal not found
    09-DEC-2002 joward    115.24            MLS enabled grade name
    23-DEC-2002 joward    115.25            MLS enabled job name
    12-Feb-2003 ekim      115.27            Made performance change to:
                                            c_regular_salary,
                                            c_hourly_salary for bug 2792737.
    13-Mar-2003 ekim      115.28            Modified procedure
                                            insert_rows_thro_api_process to
                                            check for assignment_id of the
                                            passing pl/sql table when inserting
                                            create_action_information.
    14-Mar-2003 ekim      115.29  2750949   Increased the precision of
                                            ln_proposed_salary and
                                            ln_pay_annualization_factor
                                            to (20,5) from (17,2)
    04-Apr-2003 ekim      115.30  2879910   Changed to ln_pay_basis_id from
                                            lv_pay_basis to get pay basis in
                                            if statement.
                                  2879931   Added a cursor to get employer
                                            phone number : lv_er_phone_number
    19-JUL-2003 ahanda    115.31            Changed code to archive dates in
                                            canonical format.
    28-Jul-2003 vpandya   115.32  3053917   Added a parameter p_ytd_balcall_aaid
                                            in to get_personal_information, and
                                            added p_ppp_source_action_id and
                                            p_ytd_balcall_aaid in to
                                            get_employee_other_info. Changed
                                            code in these procedures.
    20-Jan-2004 vpandya   115.33  3379865   Changed get_employee_other_info:
                                            if p_ytd_balcall_aaid is null, then
                                            use p_run_action_id to get balance.
    23-Jan-2004 rsethupa  115.34  3354127   11.5.10 Performance Changes
    28-MAR-2004 ahanda    115.35  3536375   Net Pay distribution code was
                                            assuming that not null source action
                                            is sep check. This has been changed
                                            to check for run type to take care
                                            of Payment Method by Run Type.
    16-APR-2004 rsethupa  115.36  3311866   US SS Payslip currency Format Enh.
                                            Changed code to archive currency
                                            data in canonical format for action
                                            info categories 'EMPLOYEE DETAILS',
                                            'EMPLOYEE NET PAY DISTRIBUTION' and
                                            'EMPLOYEE ACCRUALS'.
    12-AUG-2004 ahanda    115.37  3575803   Changed code to use data earned for
                                            Pay Rate and Annualization factor.
    20-MAY-2005 sodhingr  115.38  4225799   Archiving the value in canonical
                                            format for EMPLOYEE OTHERS
                                            INFORMATION
    24-SEP-2005 rdhingra  115.39  4365487   Changed query in
                                            cursor c_element_details in
                                            procedure get_employee_other_info
    28-SEP-2005 suman     115.40  4520091   Modified the cursor definition c_addr_line
                                            in procedures get_employee_addr and
                                            get_org_address(inside procedure
                                            arch_pay_action_level_data)
    15-OCT-2005 ahanda    115.41  4676875   Changed archiving for EMPLOYEE OTHERS
                                            INFORMATION to be converted to
                                            canonical if UOM is M or N.
                                            Changed cursor c_element_details to
                                            remove join for element links.
                                            Backed out changes for bug 4520091.
    24-APR-2006 pragupta  115.42  5182166   Added a new procedure
                                            get_3rdparty_pay_distribution to
					    archive the Third Party Payments.
    07-MAY-2006 ahanda    115.43  5209228   Added a new overloaded procedure -
                                             - arch_pay_action_level_data
                                            to be called from de-init code
    11-MAY-2006 ahanda    115.44  4685928   Modifed get_3rdparty_pay_distribution
                                            to store the correct action ID
    02-OCT-2006 ahanda    115.45            Archiving accrual_code in action_info7
    08-DEC-2006 ahanda    115.46  5692161   Changed get_employee_other_info to
                                            archive values if <> 0
    14-FEB-2006 kvsankar  115.47  5707497   Modified get_employee_other_info
                                            to archive Unit Of Measure
    05-JUL-2007 sausingh  115.48  5635335   Modified a condition in the cursor
                                            c_net_pay in the procedure
                                            get_net_pay_distribution to archive the bank details
                                            of employer if the payment type is check .
    31-MAR-2008 asgugupt  115.49  5585331   Replaced parameter p_curr_eff_date
 					    with p_date_earned while opening c_employee_details
					    cursor in get_personal_information procedure
    18-JUL-2008 mikarthi  115.51  7115367   While Archiving "EMPLOYEE OTHER INFORMATION" details
 					    context at which the information was defined is
					    archived in to Action Info 13
    03-DEC-2008 sudedas   115.52  7604041   Changed cursor c_salary_proposal
                                            'Proposed Salary' displays correct
                                            Figure in case NO proposals exist.
    28-Mar-2009 skpatil  115.56  8305579   Modified cursor c_employee_details
                                           to obtain assignment when orgnaization
							                             is changed.
    23-Oct-2009 sapalani 115.57  8827140   In function get_employee_other_info
                                           added reporting_name column to the
                                           cursors c_element_details and
                                           c_defined_balance_id. Joined tl
                                           tables to return values for reporting
                                           _name based on correspondance langauge.
                                           Added code to archive this extra value
                                           in to ACTION_INFORMATION14.
    26-Mar-2010 sapalani 115.58  9525602   In cusrors c_element_details and
                                           c_defined_balance_id, Used nvl function
                                           in where clause when comparing for
                                           language.
    14-Apr-2010 sjawid   115.59  9549403   Modified function get_shift to archive
                                           Shift info for US localization.
    14-Apr-2010 sjawid   115.60  9549403   Added new cursor get_shift_desc at get_shift
                                           function to get description of shift code.
    15-Apr-2010 sjawid   115.61  9549403   Modified cursor get_shift_desc such that
                                           it will execute when get_shift_code cursor found.
  *******************************************************************/

  /******************************************************************
  ** Package Local Variables
  ******************************************************************/
  gv_package        VARCHAR2(100);

  /*********************************************************************
   Name      : set_error_message
   Purpose   : This function sets error message only if it has not been
               set before and returns it back.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION set_error_message( p_error_message in varchar2 ) RETURN varchar2 is
  BEGIN
    if gv_error_message is null then
       gv_error_message := p_error_message;
    end if;
    return gv_error_message;
  END;


  /*********************************************************************
   Name      : get_defined_balance_id
   Purpose   : This function returns the defined_balance_id for a given
               Balance ID and Dimension.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_defined_balance_id (
               p_balance_id        in number
              ,p_balance_dimension in varchar2
              ,p_legislation_code  in varchar2)
  RETURN NUMBER
  IS
    cursor c_get_defined_balance_id(cp_balance_id       in number
                                   ,cp_bal_dim          in varchar2
                                   ,cp_legislation_code in varchar2 ) is
      select pdb.defined_balance_id
        from pay_defined_balances pdb,
             pay_balance_dimensions pbd
       where pdb.balance_type_id = cp_balance_id
         and pbd.database_item_suffix = cp_bal_dim
         and pbd.balance_dimension_id = pdb.balance_dimension_id
          and ((pbd.legislation_code = cp_legislation_code and
                pbd.business_group_id is null)
            or (pbd.legislation_code is null and
                pbd.business_group_id is not null));

    ln_defined_balance_id    NUMBER;
    lv_error_message         VARCHAR2(200);

  BEGIN
     hr_utility.trace('opened c_get_defined_balance');
     open c_get_defined_balance_id(p_balance_id,
                                   p_balance_dimension,
                                   p_legislation_code);

     fetch c_get_defined_balance_id into ln_defined_balance_id;
     if c_get_defined_balance_id%notfound then
        /*********************************************************
        ** If defined_balance_id not found then return null.
        ** This will happen for the Hours YTD balance
        *********************************************************/
        hr_utility.trace('Defined balance id not found for... ' );
        hr_utility.trace('   p_balance_id        = ' || p_balance_id);
        hr_utility.trace('   p_balance_dimension = ' || p_balance_dimension);
        hr_utility.trace('   p_legislation_code  = ' || p_legislation_code);
     end if;
     close c_get_defined_balance_id;
     hr_utility.trace('ln_defined_balance_id = ' || ln_defined_balance_id);
     return ln_defined_balance_id ;

  END get_defined_balance_id;


  /*********************************************************************
   Name      : get_multi_legislative_rule
   Purpose   : This function returns the if the legislative rule is
               enabled for multiple assignment.
   Arguments :
   Notes     : This would be defaulted to 'N'
  *********************************************************************/
  FUNCTION get_multi_legislative_rule(p_legislation_code in varchar2)

  RETURN VARCHAR2
  IS

    cursor c_leg_rule (cp_legislation_code in varchar2) is
      select 'x'
        from pay_legislative_field_info
       where field_name = 'MULTI_ASSIGNMENTS_FLAG'
         and legislation_code = cp_legislation_code
         and rule_mode = 'Y';

    lv_multi_leg_rule  VARCHAR2(1);
    lv_procedure_name  VARCHAR2(50);
  BEGIN
    lv_multi_leg_rule := 'N';
    lv_procedure_name := '.get_multi_legislative_rule' ;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    open c_leg_rule(p_legislation_code);
    fetch c_leg_rule into lv_multi_leg_rule;
    if c_leg_rule%found then
       lv_multi_leg_rule := 'Y';
    else
       lv_multi_leg_rule := 'N';
    end if;
    close c_leg_rule;

    hr_utility.trace('lv_multi_leg_rule = ' || lv_multi_leg_rule);
    hr_utility.set_location(gv_package || lv_procedure_name, 100);
    return(lv_multi_leg_rule);

  END get_multi_legislative_rule;

  /*********************************************************************
   Name      : get_multi_assignment_flag
   Purpose   : This function returns the flag for multiple assignment
               payment is enabled or not.
   Arguments :
   Notes     : This would be defaulted to 'N'
  *********************************************************************/
  FUNCTION get_multi_assignment_flag(p_payroll_id       in number
                                    ,p_effective_date   in date)

  RETURN VARCHAR2
  IS

    cursor c_get_payroll_info(cp_payroll_id     in number
                             ,cp_effective_date in date) is
       select multi_assignments_flag
         from pay_payrolls_f
        where payroll_id = cp_payroll_id
          and cp_effective_date between effective_start_Date
                                    and effective_end_date
          and multi_assignments_flag = 'Y';

    lv_multi_asg_flag  VARCHAR2(1);
    lv_procedure_name  VARCHAR2(50);

  BEGIN
    lv_multi_asg_flag := 'N';
    lv_procedure_name := '.get_multi_assignment_flag' ;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    open c_get_payroll_info(p_payroll_id, p_effective_date);
    fetch c_get_payroll_info into lv_multi_asg_flag;
    if c_get_payroll_info%found then
       lv_multi_asg_flag := 'Y';
    else
       lv_multi_asg_flag := 'N';
    end if;
    close c_get_payroll_info;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    hr_utility.trace('lv_multi_asg_flag = ' || lv_multi_asg_flag);
    return lv_multi_asg_flag;

  END get_multi_assignment_flag;


  /******************************************************************
   Name      : initialization_process
   Purpose   : The procedure initializes the PL/SQL table -
               pay_emp_action_arch.lrr_act_tab,
               pay_emp_action_arch.ltr_ppa_arch and
               pay_us_emp_payslip_accrual_web.ltr_assignment_accruals.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE initialization_process
  IS
    lv_procedure_name VARCHAR2(100);

  BEGIN
    lv_procedure_name := '.initialization_process';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    if pay_emp_action_arch.lrr_act_tab.count > 0 then
       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       for i in pay_emp_action_arch.lrr_act_tab.first ..
                pay_emp_action_arch.lrr_act_tab.last loop
           pay_emp_action_arch.lrr_act_tab(i).action_context_id := null;
           pay_emp_action_arch.lrr_act_tab(i).action_context_type := null;
           pay_emp_action_arch.lrr_act_tab(i).action_info_category := null;
           pay_emp_action_arch.lrr_act_tab(i).jurisdiction_code := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info1 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info2 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info3 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info4 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info5 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info6 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info7 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info8 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info9 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info10 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info11 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info12 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info13 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info14 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info15 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info16 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info17 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info18 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info19 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info20 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info21 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info22 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info23 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info24 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info25 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info26 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info27 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info28 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info29 := null;
           pay_emp_action_arch.lrr_act_tab(i).act_info30 := null;
       end loop;
    end if;
    pay_emp_action_arch.lrr_act_tab.delete;
    pay_us_emp_payslip_accrual_web.ltr_assignment_accruals.delete;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);

    if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
       hr_utility.set_location(gv_package || lv_procedure_name, 40);
       for i in pay_emp_action_arch.ltr_ppa_arch.first ..
                pay_emp_action_arch.ltr_ppa_arch.last loop
           pay_emp_action_arch.ltr_ppa_arch(i).action_context_id := null;
           pay_emp_action_arch.ltr_ppa_arch(i).action_context_type := null;
           pay_emp_action_arch.ltr_ppa_arch(i).action_info_category := null;
           pay_emp_action_arch.ltr_ppa_arch(i).jurisdiction_code := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info1 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info2 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info3 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info4 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info5 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info6 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info7 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info8 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info9 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info10 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info11 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info12 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info13 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info14 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info15 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info16 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info17 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info18 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info19 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info20 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info21 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info22 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info23 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info24 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info25 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info26 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info27 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info28 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info29 := null;
           pay_emp_action_arch.ltr_ppa_arch(i).act_info30 := null;
       end loop;
    end if;
    pay_emp_action_arch.ltr_ppa_arch.delete;

    hr_utility.set_location(gv_package || lv_procedure_name, 50);
  END initialization_process;



  /******************************************************************
   Name      : insert_rows_thro_api_process
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE insert_rows_thro_api_process(
                p_action_context_id   in number
               ,p_action_context_type in varchar2
               ,p_assignment_id       in number
               ,p_tax_unit_id         in number
               ,p_curr_pymt_eff_date  in date
               ,p_tab_rec_data        in pay_emp_action_arch.action_info_table
               )

  IS
     l_action_information_id_1 NUMBER ;
     l_object_version_number_1 NUMBER ;
     lv_procedure_name         VARCHAR2(100);

  BEGIN
     lv_procedure_name := '.insert_rows_thro_api_process';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop
            hr_utility.trace('Defining category '||
                          p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_action_context_id);
            hr_utility.trace('jurisdiction_code '||
                           p_tab_rec_data(i).jurisdiction_code);
            hr_utility.trace('act_info1 is'|| p_tab_rec_data(i).act_info1);
            hr_utility.trace('act_info2 is'|| p_tab_rec_data(i).act_info2);
            hr_utility.trace('act_info3 is'|| p_tab_rec_data(i).act_info3);
            hr_utility.trace('act_info4 is'|| p_tab_rec_data(i).act_info4);
            hr_utility.trace('act_info5 is'|| p_tab_rec_data(i).act_info5);
            hr_utility.trace('act_info6 is'|| p_tab_rec_data(i).act_info6);
            hr_utility.trace('act_info30 is'|| p_tab_rec_data(i).act_info30);

            hr_utility.set_location(gv_package || '.' || lv_procedure_name, 30);
            pay_action_information_api.create_action_information(
                p_action_information_id => l_action_information_id_1,
                p_object_version_number => l_object_version_number_1,
                p_action_information_category
                     => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_action_context_id,
                p_action_context_type  => p_action_context_type,
                p_jurisdiction_code    => p_tab_rec_data(i).jurisdiction_code,
                p_assignment_id        => nvl(p_tab_rec_data(i).assignment_id,
                                              p_assignment_id),
                p_tax_unit_id          => p_tax_unit_id,
                p_effective_date       => p_curr_pymt_eff_date,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );

        end loop;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);
  END insert_rows_thro_api_process;



  /************************************************************
  ** Function gets the proposed employee salary from
  ** per_pay_proposals. If the Salary Proposal is not specified
  ** then it checks the Salary Basis for the employee, find out
  ** the element associated with the Salary Basis and get the
  ** value from the run results for the given period.
  ** If the element associated with the Salary Basis is Regular
  ** wages, then we get the value for input value of 'Rate'
  ************************************************************/
  FUNCTION get_proposed_emp_salary (
                           p_assignment_id     in number
                          ,p_pay_basis_id      in number
                          ,p_pay_bases_name    in varchar2
                          ,p_date_earned       in date
                          )
  RETURN VARCHAR2 IS

    cursor c_salary_proposal (cp_assignment_id in number,
                              cp_date_earned   in date) is
      select ppp.proposed_salary_n
        from per_pay_proposals ppp
       where ppp.assignment_id = cp_assignment_id
         and ppp.change_date =
                (select max(change_date)
                  from per_pay_proposals ppp1
                 where ppp1.assignment_id = cp_assignment_id
                   and ppp1.approved = 'Y'
                   /* Following modified for Bug# 7604041 */
                   /* and ppp1.change_date <= cp_date_earned */
                   and cp_date_earned between ppp1.change_date and NVL(ppp1.date_to, hr_general.END_OF_TIME())
                );


    cursor c_bases_element (cp_pay_basis_id  in number,
                            cp_date_earned   in date) is
      select piv.element_type_id, piv.input_value_id
        from pay_input_values_f piv,
             per_pay_bases ppb
       where ppb.pay_basis_id = cp_pay_basis_id
         and ppb.input_value_id = piv.input_value_id
         and cp_date_earned between piv.effective_start_date
                                and piv.effective_end_date;

    cursor c_regular_salary (cp_input_value_id  in number,
                             cp_assignment_id   in number,
                             cp_date_earned     in date ) is
      select prrv.result_value
        from pay_run_results prr,
             pay_run_result_values prrv,
             pay_input_values_f piv,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where prr.element_type_id + 0 = piv.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.source_type = 'E'
         and piv.input_value_id = prrv.input_value_id
         and piv.input_value_id = cp_input_value_id
         and ppa.effective_date between piv.effective_start_date
                                    and piv.effective_end_date
         and paa.assignment_action_id = prr.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.effective_date = cp_date_earned;

    cursor c_hourly_salary (cp_element_type_id  in number,
                            cp_input_value_name in varchar2,
                            cp_assignment_id    in number,
                            cp_date_earned      in date ) is
      select prrv.result_value
        from pay_run_results prr,
             pay_run_result_values prrv,
             pay_input_values_f piv,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where prr.element_type_id + 0 = piv.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.source_type = 'E'
         and piv.input_value_id = prrv.input_value_id
         and piv.element_type_id = cp_element_type_id
         and piv.name = cp_input_value_name
         and ppa.effective_date between piv.effective_start_date
                                    and piv.effective_end_date
         and paa.assignment_action_id = prr.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.effective_date = cp_date_earned;

    ln_element_type_id NUMBER;
    ln_input_value_id  NUMBER;
    ln_proposed_salary NUMBER;
    lv_procedure_name  VARCHAR2(100);

  BEGIN
    lv_procedure_name := 'get_proposed_emp_salary';

    open c_salary_proposal(p_assignment_id,
                           p_date_earned);
    fetch c_salary_proposal into ln_proposed_salary;
    if c_salary_proposal%notfound then
       open c_bases_element(p_pay_basis_id,
                            p_date_earned);
       fetch c_bases_element into ln_element_type_id, ln_input_value_id;
       if c_bases_element%found then
          if p_pay_bases_name <> 'HOURLY' then
             open c_regular_salary(ln_input_value_id,
                                   p_assignment_id,
                                   p_date_earned);
             fetch c_regular_salary into ln_proposed_salary;
             if c_regular_salary%notfound then
                ln_proposed_salary := 0;
             end if;
             close c_regular_salary;
          else
             open c_hourly_salary(ln_element_type_id,
                                  'Rate',
                                  p_assignment_id,
                                  p_date_earned);
             fetch c_hourly_salary into ln_proposed_salary;
             if c_hourly_salary%notfound then
                ln_proposed_salary := 0;
             end if;
             close c_hourly_salary;
          end if;
       end if;
       close c_bases_element;

    end if;
    close c_salary_proposal;

    return (ln_proposed_salary);

  END get_proposed_emp_salary;


  /************************************************************
  ** Gets the Annualized factor for the Payroll
  **   i.e. frequency of the Payroll
  **   e.g.  Week = 52
  **         Semi-Month = 24
  **         Month      = 12
  **         Hourly     = No of working hours/day   * 365
  **                      No of working hours/week  * 52
  **                      No of working hours/month * 12
  **                      No of working hours/year  * 1
  ************************************************************/
  FUNCTION get_emp_annualization_factor (
                                p_pay_basis_id    in number
                               ,p_period_type     in varchar2
                               ,p_pay_bases_name  in varchar2
                               ,p_assignment_id   in number
                               ,p_date_earned     in date
                               )
  return number is

    cursor c_salary_details (cp_pay_basis_id  in number) is
      select ppb.pay_annualization_factor
        from per_pay_bases ppb
       where ppb.pay_basis_id = cp_pay_basis_id;

    cursor c_payroll (cp_period_type in varchar2) is
      select ptpt.number_per_fiscal_year
        from per_time_period_types ptpt
       where ptpt.period_type = cp_period_type;

    ln_pay_annualization_factor NUMBER;
    lv_procedure_name           VARCHAR2(100);

  BEGIN
    lv_procedure_name := 'get_emp_annualization_factor';

    open c_salary_details(p_pay_basis_id);
    fetch c_salary_details into ln_pay_annualization_factor;
    if c_salary_details%found then

       if p_pay_bases_name ='PERIOD' and
          ln_pay_annualization_factor is null then

          open c_payroll(p_period_type);
          fetch c_payroll into ln_pay_annualization_factor;
          close c_payroll;

       elsif p_pay_bases_name = 'HOURLY' and
          (p_assignment_id is not null and p_date_earned is not null) then

          ln_pay_annualization_factor
              := pay_us_employee_payslip_web.get_asgn_annual_hours
                                            (p_assignment_id,
                                             p_date_earned);
       end if;
    end if;
    close c_salary_details;

    return (ln_pay_annualization_factor);

  END get_emp_annualization_factor;


  /******************************************************************
   Name      : get_employee_other_info
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_employee_other_info (p_run_action_id        in number
                                    ,p_assignment_id        in number
                                    ,p_organization_id      in number
                                    ,p_business_group_id    in number
                                    ,p_curr_pymt_eff_date   in date
                                    ,p_tax_unit_id          in number
                                    ,p_ppp_source_action_id in number
                                                               default null
                                    ,p_ytd_balcall_aaid     in number
                                                               default null
                                    )
  IS
    cursor c_organization_info(cp_organization_id    in number
                              ,cp_org_info_context  in varchar2
                             ) is
      select org_information1, org_information2,
             org_information3, org_information4,
             org_information5, org_information6,
             org_information7
        from hr_organization_information
       where org_information_context = cp_org_info_context
         and organization_id = cp_organization_id;

    cursor c_element_details(cp_element_type_id number
                            ,cp_input_value_id  number
                            ,cp_assignment_id   number
                            ,cp_language in varchar2
                            ) is
      select pet.element_name, peev.screen_entry_value,
             piv.name, piv.uom,
             nvl(petl.reporting_name,petl.element_name)
        from pay_element_types_f pet,
             pay_element_types_f_tl petl,
             pay_element_entries_f pee,
             pay_element_entry_values_f peev,
             pay_input_values_f piv
       where pet.element_type_id = cp_element_type_id
         and pet.element_type_id = pee.element_type_id
         and pee.assignment_id = cp_assignment_id
         and pee.element_entry_id = peev.element_entry_id
         and peev.input_value_id = cp_input_value_id
         and piv.input_value_id = peev.input_value_id
         and pet.element_type_id = petl.element_type_id
         and petl.language = nvl(cp_language,userenv('LANG')) --Lang. cond. added for 8827140
         and p_curr_pymt_eff_date between pet.effective_start_date
                                      and pet.effective_end_date
         and p_curr_pymt_eff_date between pee.effective_start_date
                                      and pee.effective_end_date
         and p_curr_pymt_eff_date between peev.effective_start_date
                                      and peev.effective_end_date
         and p_curr_pymt_eff_date between piv.effective_start_date
                                      and piv.effective_end_date;

    cursor c_defined_balance_id(cp_balance_type_id      number
                               ,cp_balance_dimension_id number
                               ,cp_language in varchar2
                               ) is
     select pdb.defined_balance_id,
            pbt.balance_name,
            substr(pbd.database_item_suffix,2),
            pbt.balance_uom,
            nvl(pbtl.reporting_name,pbtl.balance_name)
       from pay_defined_balances pdb,
            pay_balance_dimensions pbd,
            pay_balance_types pbt,
            pay_balance_types_tl pbtl
      where pbt.balance_type_id = cp_balance_type_id
        and pbd.balance_dimension_id = cp_balance_dimension_id
        and pbt.balance_type_id = pdb.balance_type_id
        and pbd.balance_dimension_id = pdb.balance_dimension_id
        and pbt.balance_type_id = pbtl.balance_type_id
        and pbtl.language = nvl(cp_language,userenv('LANG')); --Lang. cond. added for 8827140

    ln_index                number;
    lv_info_type            VARCHAR2(150);
    lv_name                 VARCHAR2(150);
    lv_reporting_name       VARCHAR2(150);
    lv_display_name         VARCHAR2(150);
    lv_value_type           VARCHAR2(150);
    lv_value                VARCHAR2(150);
    lv_uom                  VARCHAR2(150);
    ln_element_type_id      number;
    ln_defined_balance_id   number;
    ln_input_value_id       number;
    ln_balance_type_id      number;
    ln_balance_dimension_id number;
    lv_message              VARCHAR2(150);
    lv_organization_fetch   VARCHAR2(1);
    lv_exists               VARCHAR2(1);

    ln_run_action_id        number;
    lv_procedure_name       VARCHAR2(100);

  BEGIN
     lv_procedure_name     := '.get_employee_other_info';
     lv_name               := null;
     lv_display_name       := null;
     lv_value_type         := null;
     lv_value              := null;
     lv_organization_fetch := 'N';
     lv_exists             := 'N';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_run_action_id = '     || p_run_action_id);
     hr_utility.trace('p_assignment_id = '     || p_assignment_id);
     hr_utility.trace('p_organization_id = '   || p_organization_id);
     hr_utility.trace('p_business_group_id = ' || p_business_group_id);
     hr_utility.trace('p_curr_pymt_eff_date = '|| p_curr_pymt_eff_date);
     hr_utility.trace('p_tax_unit_id = '       || p_tax_unit_id);

     open  c_organization_info(p_organization_id,
                              'Organization:Payslip Info');
     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     loop
        fetch c_organization_info into lv_info_type
                                      ,ln_element_type_id
                                      ,ln_input_value_id
                                      ,ln_balance_type_id
                                      ,ln_balance_dimension_id
                                      ,lv_message
                                      ,lv_display_name;

        if c_organization_info%notfound then
           exit;
        end if;

        hr_utility.set_location(gv_package || lv_procedure_name, 30);
        hr_utility.trace('lv_info_type '            || lv_info_type);
        hr_utility.trace('ln_element_type_id '      || ln_element_type_id);
        hr_utility.trace('ln_input_value_id '       || ln_input_value_id);
        hr_utility.trace('ln_balance_type_id '      || ln_balance_type_id);
        hr_utility.trace('ln_balance_dimension_id ' || ln_balance_dimension_id);
        hr_utility.trace('lv_message '              || lv_message);
        hr_utility.trace('lv_display_name '         ||lv_display_name);

        lv_organization_fetch := 'Y' ;

        if lv_info_type ='ELEMENT' then
           hr_utility.set_location(gv_package || lv_procedure_name, 40);
           open c_element_details(ln_element_type_id
                                 ,ln_input_value_id
                                 ,p_assignment_id
                                 ,gv_correspondence_language
                                 );
           fetch c_element_details into lv_name,
                                        lv_value,
                                        lv_value_type,
                                        lv_uom,
                                        lv_reporting_name;
           if c_element_details%found then
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
              hr_utility.trace('lv_uom '         || lv_uom);

              if lv_uom in ('M', 'N', 'I') then
                 lv_value := fnd_number.number_to_canonical(lv_value);
              end if;
              hr_utility.trace('lv_value '       || lv_value);
              hr_utility.trace('lv_name '        || lv_info_type);
              hr_utility.trace('lv_value_type '  || lv_value_type);

              ln_index := pay_emp_action_arch.lrr_act_tab.count;

              pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
                  := 'EMPLOYEE OTHER INFORMATION';
              pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                  := '00-000-0000';
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
                  := p_organization_id;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
                  := lv_info_type;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
                  := nvl(lv_display_name,lv_name) ;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
                  := lv_value_type ;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
                  := lv_value;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
                  := ln_element_type_id;
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
                  := ln_input_value_id;
              -- Bug 5707497
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
                  := lv_uom;
              --Added for bug 8827140
              pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
                  := nvl(lv_display_name,lv_reporting_name);
           end if;
           close c_element_details;

        elsif lv_info_type = 'BALANCE' then
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           open  c_defined_balance_id(ln_balance_type_id
                                     ,ln_balance_dimension_id
                                     ,gv_correspondence_language);
           fetch  c_defined_balance_id into ln_defined_balance_id,
                                            lv_name,
                                            lv_value_type,
                                            lv_uom,
                                            lv_reporting_name;

           hr_utility.trace('lv_name '               || lv_info_type);
           hr_utility.trace('lv_value_type '         || lv_value_type);
           hr_utility.trace('ln_defined_balance_id ' || ln_defined_balance_id);

           if c_defined_balance_id%found then

              if p_ppp_source_action_id is not null then
                 ln_run_action_id := p_ppp_source_action_id;
              else
                 if lv_value_type = 'ASG_PAYMENTS' then
                    ln_run_action_id := p_run_action_id;
                 else
                    ln_run_action_id := nvl(p_ytd_balcall_aaid,p_run_action_id);
                 end if;
              end if;

              hr_utility.trace('p_ppp_source_action_id '||
                                               p_ppp_source_action_id);
              hr_utility.trace('ln_run_action_id '|| ln_run_action_id);

              pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
              lv_value := nvl(pay_balance_pkg.get_value(ln_defined_balance_id,
                                                        ln_run_action_id),0);
              if lv_value <> 0 then
                 hr_utility.set_location(gv_package || lv_procedure_name, 110);
                 ln_index := pay_emp_action_arch.lrr_act_tab.count;

                 pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
                     := 'EMPLOYEE OTHER INFORMATION';
                 pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                     := '00-000-0000';
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
                     := p_organization_id;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
                     := lv_info_type;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
                     := nvl(lv_display_name,lv_name) ;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
                     := lv_value_type ;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
                     := fnd_number.number_to_canonical(lv_value); /*bug 4225799*/
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
                     := ln_balance_type_id;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
                     := ln_balance_dimension_id;
                 -- Bug 5707497
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
                     := lv_uom;
                 --Added for bug 8827140
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
                     := nvl(lv_display_name,lv_reporting_name);
              end if;
           end if;
          close c_defined_balance_id;

        end if;

        hr_utility.trace('ln_index in  get_employee_other_info proc is '
                || pay_emp_action_arch.lrr_act_tab.count);
        hr_utility.trace('lv_info_type is'||lv_info_type);

     end loop;
     close c_organization_info;

     if lv_organization_fetch = 'N' then
        open  c_organization_info(p_business_group_id,
                                  'Business Group:Payslip Info');
        hr_utility.trace('Opened for Business Group:Payslip Info');
        loop
           fetch c_organization_info into lv_info_type
                                         ,ln_element_type_id
                                         ,ln_input_value_id
                                         ,ln_balance_type_id
                                         ,ln_balance_dimension_id
                                         ,lv_message
                                         ,lv_display_name;

           if c_organization_info%notfound then
              exit;
           end if;
           hr_utility.set_location(gv_package || lv_procedure_name, 140);
           hr_utility.trace('lv_info_type '           || lv_info_type);
           hr_utility.trace('ln_element_type_id '     || ln_element_type_id);
           hr_utility.trace('ln_input_value_id '      || ln_input_value_id);
           hr_utility.trace('ln_balance_type_id '     || ln_balance_type_id);
           hr_utility.trace('ln_balance_dimension_id' || ln_balance_dimension_id);
           hr_utility.trace('lv_message '             || lv_message);
           hr_utility.trace('lv_display_name '        || lv_display_name);

           if lv_info_type ='ELEMENT' then
              open c_element_details(ln_element_type_id
                                    ,ln_input_value_id
                                    ,p_assignment_id
                                    ,gv_correspondence_language);
              fetch c_element_details into lv_name,
                                           lv_value,
                                           lv_value_type,
                                           lv_uom,
                                           lv_reporting_name;
              --if c_element_details%notfound then
              if c_element_details%found then

                 hr_utility.trace('lv_uom '        || lv_uom);
                 if lv_uom in ('M', 'N', 'I') then
                    lv_value := fnd_number.number_to_canonical(lv_value);
                 end if;

                 ln_index := pay_emp_action_arch.lrr_act_tab.count;
                 hr_utility.trace('lv_name '       || lv_info_type);
                 hr_utility.trace('lv_value '      || lv_value);
                 hr_utility.trace('lv_value_type ' || lv_value_type);

                 pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
                        := 'EMPLOYEE OTHER INFORMATION';
                 pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                        := '00-000-0000';
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
                        := p_business_group_id;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
                        := lv_info_type;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
                        := nvl(lv_display_name,lv_name) ;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
                        := lv_value_type ;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
                        := lv_value;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
                        := ln_element_type_id;
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
                        := ln_input_value_id;
                 -- Bug 5707497
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
                     := lv_uom;
                 --Added for bug 8827140
                 pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
                     := nvl(lv_display_name,lv_reporting_name);
              end if;
              close c_element_details;
           elsif lv_info_type = 'BALANCE' then
              hr_utility.set_location(gv_package || lv_procedure_name, 210);

              open c_defined_balance_id(ln_balance_type_id
                                       ,ln_balance_dimension_id
                                       ,gv_correspondence_language);

              hr_utility.set_location(gv_package || lv_procedure_name, 220);
              fetch c_defined_balance_id into ln_defined_balance_id,
                                              lv_name,
                                              lv_value_type,
                                              lv_uom,
                                              lv_reporting_name;

              hr_utility.trace('ln_balance_type_id'   || ln_balance_type_id);
              hr_utility.trace('lv_name '                || lv_info_type);
              hr_utility.trace('lv_value_type '          || lv_value_type);
              hr_utility.trace('ln_defined_balance_id  ' || ln_defined_balance_id);
              if c_defined_balance_id%found then

                 if p_ppp_source_action_id is not null then
                    ln_run_action_id := p_ppp_source_action_id;
                 else
                    if lv_value_type = 'ASG_PAYMENTS' then
                       ln_run_action_id := p_run_action_id;
                    else
                       ln_run_action_id := nvl(p_ytd_balcall_aaid,
                                               p_run_action_id);
                    end if;
                 end if;

                 hr_utility.trace('p_ppp_source_action_id '||
                                                  p_ppp_source_action_id);
                 hr_utility.trace('ln_run_action_id '|| ln_run_action_id);

                 pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);

                 lv_value := nvl(pay_balance_pkg.get_value(ln_defined_balance_id,
                                                           ln_run_action_id),0);
                 if lv_value <> 0 then
                    ln_index := pay_emp_action_arch.lrr_act_tab.count;

                    pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
                          := 'EMPLOYEE OTHER INFORMATION';
                    pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                          := '00-000-0000';
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
                          := p_business_group_id;
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
                          := lv_info_type;
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
                          := nvl(lv_display_name,lv_name) ;
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
                          := lv_value_type ;
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
                          := fnd_number.number_to_canonical(lv_value); /*bug 4225799*/
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
                          := ln_balance_type_id;
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
                          := ln_balance_dimension_id;
                    -- Bug 5707497
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
                        := lv_uom;
                    --Added for bug 8827140
                    pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
                        := nvl(lv_display_name,lv_reporting_name);
                 end if; -- lv_value > 0 then
              end if;
              close c_defined_balance_id;

           end if;
        end loop;
        close c_organization_info;
     end if;
  END get_employee_other_info;


  /******************************************************************
   Name      : get_employee_accruals
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_employee_accruals(p_assactid       in number
                                 ,p_run_action_id  in number
                                 ,p_assignment_id  in number
                                 ,p_effective_date in date
                                 ,p_date_earned    in date
                                 )
  IS
    ln_total_acc_category NUMBER;
    ln_index              NUMBER;
    lv_procedure_name     VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_employee_accruals';
     hr_utility.trace('Entered get_employee_accruals');

     pay_us_emp_payslip_accrual_web.get_emp_net_accrual (
                    p_assignment_action_id => p_run_action_id
                   ,p_assignment_id        => p_assignment_id
                   ,p_cur_earned_date      => p_date_earned
                   ,p_total_acc_category   => ln_total_acc_category
                   );

     if pay_us_emp_payslip_accrual_web.ltr_assignment_accruals.count > 0 then
        for i in pay_us_emp_payslip_accrual_web.ltr_assignment_accruals.first ..
                 pay_us_emp_payslip_accrual_web.ltr_assignment_accruals.last loop

            ln_index := pay_emp_action_arch.lrr_act_tab.count;

            pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'EMPLOYEE ACCRUALS';
            pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := '00-000-0000';
            pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
               := pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_category;
            /* Bug 3311866*/
            pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
               := fnd_number.number_to_canonical
                  (pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_cur_value);
            pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
               := fnd_number.number_to_canonical
                  (pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_net_value);
            pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
               := pay_us_emp_payslip_accrual_web.ltr_assignment_accruals(i).accrual_code;
        end loop;
     end if;

     hr_utility.trace('Leaving get_employee_accruals');

  END get_employee_accruals;


  /******************************************************************
   Name      : get_organization_name
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_organization_name(p_organization_id in number)
  RETURN varchar2 IS

    cursor c_organization_name is
      select name
        from hr_organization_units
       where organization_id = p_organization_id;

    lv_organization_name VARCHAR2(240);
    lv_exists            VARCHAR2(1);
    ln_index             NUMBER;
    lv_procedure_name    VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_organization_name';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_organization_name');
     if pay_emp_action_arch.ltr_organizations.count > 0 then
        for i in pay_emp_action_arch.ltr_organizations.first ..
                 pay_emp_action_arch.ltr_organizations.last loop
            if pay_emp_action_arch.ltr_organizations(i).id = p_organization_id then
               lv_organization_name := pay_emp_action_arch.ltr_organizations(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_organization_name;
       fetch c_organization_name into lv_organization_name;
       close c_organization_name;
       ln_index := pay_emp_action_arch.ltr_organizations.count;
       pay_emp_action_arch.ltr_organizations(ln_index).id := p_organization_id;
       pay_emp_action_arch.ltr_organizations(ln_index).name := lv_organization_name;
    end if;

    hr_utility.trace('Leaving get_organization_name');
    return(lv_organization_name);
  EXCEPTION
    when others then
    hr_utility.trace('Error in ' || lv_procedure_name ||
                      to_char(sqlcode) || '-' || sqlerrm);
    raise hr_utility.hr_error;

  END get_organization_name ;


  /******************************************************************
   Name      : get_location
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_location(p_location_id in number)

  RETURN varchar2 IS

    cursor c_location(cp_location_id in number) is
    select location_code
      from hr_locations_all
     where location_id = cp_location_id;

    lv_location_name  VARCHAR2(240);
    lv_exists         VARCHAR2(1);
    ln_index          NUMBER;
    lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_location';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_location');

     if pay_emp_action_arch.ltr_location.count > 0 then
        for i in pay_emp_action_arch.ltr_location.first ..
                 pay_emp_action_arch.ltr_location.last loop
            if pay_emp_action_arch.ltr_location(i).id = p_location_id then
               lv_location_name := pay_emp_action_arch.ltr_location(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_location(p_location_id);
       fetch c_location into lv_location_name;
       close c_location;
       ln_index := pay_emp_action_arch.ltr_location.count;
       pay_emp_action_arch.ltr_location(ln_index).id := p_location_id;
       pay_emp_action_arch.ltr_location(ln_index).name := lv_location_name;
    end if;

    hr_utility.trace('Leaving get_location');

    return(lv_location_name);
  EXCEPTION
     when others then
        return(null);

  END get_location ;


  /******************************************************************
   Name      : get_job_name
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_job_name(p_job_id         in number
                       ,p_effective_date in date)
  RETURN varchar2 IS

    cursor c_job_name(cp_job_id            in number
                     ,cp_effective_date    in date
                     ) is
      select name
        from per_jobs_vl
       where job_id = cp_job_id
         and date_from  <= cp_effective_date
         and nvl(date_to, cp_effective_date) >= cp_effective_date
      order by date_from desc;

    lv_job_name       VARCHAR2(240);
    lv_exists         VARCHAR2(1);
    ln_index          NUMBER;
    lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_job_name';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_job_name');
     if pay_emp_action_arch.ltr_jobs.count > 0 then
        for i in pay_emp_action_arch.ltr_jobs.first ..
                 pay_emp_action_arch.ltr_jobs.last loop
            if pay_emp_action_arch.ltr_jobs(i).id = p_job_id then
               lv_job_name := pay_emp_action_arch.ltr_jobs(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_job_name(p_job_id, p_effective_date);
       fetch c_job_name into lv_job_name;
       close c_job_name;
       ln_index := pay_emp_action_arch.ltr_jobs.count;
       pay_emp_action_arch.ltr_jobs(ln_index).id := p_job_id;
       pay_emp_action_arch.ltr_jobs(ln_index).name := lv_job_name;
    end if;

    hr_utility.trace('Leaving get_job_name');
    return(lv_job_name);

  END get_job_name ;


  /******************************************************************
   Name      : get_position
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_position(p_position_id    in number
                       ,p_effective_date in date)
  RETURN varchar2 IS

    cursor c_position_name(cp_position_id    in number
                          ,cp_effective_date in date) is
      select name
        from per_positions
       where position_id = cp_position_id
         and cp_effective_date between date_effective
                                   and nvl(date_end,cp_effective_date) ;

    lv_position_name  VARCHAR2(240);
    lv_exists         VARCHAR2(1);
    ln_index          NUMBER;
    lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_position';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_position');
     if pay_emp_action_arch.ltr_positions.count > 0 then
        for i in pay_emp_action_arch.ltr_positions.first ..
                 pay_emp_action_arch.ltr_positions.last loop
            if pay_emp_action_arch.ltr_positions(i).id = p_position_id then
               lv_position_name := pay_emp_action_arch.ltr_positions(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_position_name(p_position_id, p_effective_date);
       fetch c_position_name into lv_position_name;
       close c_position_name;
       ln_index := pay_emp_action_arch.ltr_positions.count;
       pay_emp_action_arch.ltr_positions(ln_index).id := p_position_id;
       pay_emp_action_arch.ltr_positions(ln_index).name := lv_position_name;
    end if;

    hr_utility.trace('Leaving get_position');

    return(lv_position_name);

  END get_position ;


  /******************************************************************
   Name      : get_pay_basis
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_pay_basis(p_pay_basis_id   in number
                        ,p_effective_date in date)
  RETURN varchar2 IS

    cursor c_pay_basis(cp_pay_basis_id   in number
                      ,cp_effective_date in date) is
      select ppb.name
        from per_pay_bases ppb,
             pay_input_values_f piv
       where ppb.pay_basis_id = cp_pay_basis_id
         and piv.input_value_id = ppb.input_value_id
         and p_effective_date between piv.effective_start_date
                                  and piv.effective_end_date;

    lv_pay_basis      VARCHAR2(240);
    lv_exists         VARCHAR2(1);
    ln_index          number;
    lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_pay_basis';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_pay_basis');
     if pay_emp_action_arch.ltr_pay_basis.count > 0 then
        for i in pay_emp_action_arch.ltr_pay_basis.first ..
                 pay_emp_action_arch.ltr_pay_basis.last loop
            if pay_emp_action_arch.ltr_pay_basis(i).id = p_pay_basis_id then
               lv_pay_basis := pay_emp_action_arch.ltr_pay_basis(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_pay_basis(p_pay_basis_id, p_effective_date);
       fetch c_pay_basis into lv_pay_basis;
       close c_pay_basis;
       ln_index := pay_emp_action_arch.ltr_pay_basis.count;
       pay_emp_action_arch.ltr_pay_basis(ln_index).id := p_pay_basis_id;
       pay_emp_action_arch.ltr_pay_basis(ln_index).name := lv_pay_basis;
    end if;

    hr_utility.trace('Leaving get_pay_basis');

    return(lv_pay_basis);

  END get_pay_basis ;


  /******************************************************************
   Name      : get_frequency
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_frequency(p_frequency      in varchar2
                        ,p_effective_date in date
                         )
  RETURN varchar2 IS

   cursor c_get_asg_frequency(cp_frequency      in varchar2
                             ,cp_effective_date in date) is
     select meaning
       from hr_lookups hl
      where hl.lookup_type = 'FREQUENCY'
        and hl.enabled_flag = 'Y'
        and hl.lookup_code = cp_frequency
        and cp_effective_date between nvl(hl.start_date_active, cp_effective_date)
                                  and nvl(hl.end_date_active, cp_effective_date);
   lv_frequency_desc VARCHAR2(240);
   lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_frequency';
     hr_utility.trace('Entered get_frequency');
     open c_get_asg_frequency(p_frequency, p_effective_date);
     fetch c_get_asg_frequency into lv_frequency_desc;
     close c_get_asg_frequency;

     hr_utility.trace('Leaving get_frequency');
     return(lv_frequency_desc);

  END get_frequency ;


  /******************************************************************
   Name      : get_grade
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_grade(p_grade_id       in number
                    ,p_effective_date in date
                    )
  RETURN varchar2 IS

    cursor c_grade(cp_grade_id       in number
                  ,cp_effective_date in date) is
      select name
        from per_grades_vl
       where grade_id = cp_grade_id
         and date_from  <= cp_effective_date
         and nvl(date_to, cp_effective_date) >= cp_effective_date;

    lv_grade          VARCHAR2(240);
    lv_exists         VARCHAR2(1);
    ln_index          number;
    lv_procedure_name VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_grade';
     lv_exists         := 'N';
     hr_utility.trace('Entered get_grades');
     if pay_emp_action_arch.ltr_grades.count > 0 then
        for i in pay_emp_action_arch.ltr_grades.first ..
                 pay_emp_action_arch.ltr_grades.last loop
            if pay_emp_action_arch.ltr_grades(i).id = p_grade_id then
               lv_grade := pay_emp_action_arch.ltr_grades(i).name;
               lv_exists := 'Y';
               exit;
            end if;
        end loop;
    end if;

    if lv_exists = 'N' then
       open c_grade(p_grade_id, p_effective_date);
       fetch c_grade into lv_grade;
       close c_grade;
       ln_index := pay_emp_action_arch.ltr_grades.count;
       pay_emp_action_arch.ltr_grades(ln_index).id := p_grade_id;
       pay_emp_action_arch.ltr_grades(ln_index).name := lv_grade;
    end if;

    return(lv_grade);

  END get_grade ;


  /******************************************************************
   Name      : get_bargaining_unit
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_bargaining_unit(p_bargaining_unit in varchar2
                              ,p_effective_date  in date
                              )
  RETURN varchar2 IS

   cursor c_get_bargaining_unit(cp_bargaining_unit in varchar2
                               ,cp_effective_date  in date) is
     select meaning
       from hr_lookups hl
      where hl.lookup_type = 'BARGAINING_UNIT_CODE'
        and hl.enabled_flag = 'Y'
        and hl.lookup_code = cp_bargaining_unit
        and cp_effective_date between nvl(hl.start_date_active, cp_effective_date)
                                  and nvl(hl.end_date_active, cp_effective_date);
    lv_bargaining_unit VARCHAR2(240);
    lv_procedure_name  VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_bargaining_unit';
     hr_utility.trace('Entered get_bargaining_unit');
     open c_get_bargaining_unit(p_bargaining_unit, p_effective_date);
     fetch c_get_bargaining_unit into lv_bargaining_unit;
     close c_get_bargaining_unit;

     hr_utility.trace('Leaving get_bargaining_unit');
     return(lv_bargaining_unit);

  END get_bargaining_unit ;


  /******************************************************************
   Name      : get_collective_agreement
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_collective_agreement(
                     p_collective_agreement_id in number
                    ,p_effective_date          in date
                    )
  RETURN varchar2 IS

   cursor c_get_collective_agreement(cp_collective_agreement_id in number
                                    ,cp_effective_date          in date) is
     select name
       from per_collective_agreements
      where collective_agreement_id = cp_collective_agreement_id
        and start_date  <= cp_effective_date
        and nvl(end_date, cp_effective_date) >= cp_effective_date;

    lv_collective_agreement VARCHAR2(240);
    lv_procedure_name       VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_collective_agreement';
     hr_utility.trace('Entered get_collective_agreement');
     open c_get_collective_agreement(p_collective_agreement_id
                                     ,p_effective_date);
     fetch c_get_collective_agreement into lv_collective_agreement;
     close c_get_collective_agreement;
     hr_utility.trace('Leaving get_collective_agreement');
     return(lv_collective_agreement);

  END get_collective_agreement ;


  /******************************************************************
   Name      : get_contract
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_contract(p_contract_id    in number
                       ,p_effective_date in date
                       )
  RETURN varchar2 IS

   cursor c_get_contract(cp_contract_id    in number
                        ,cp_effective_date in date) is
     select reference
       from per_contracts
      where contract_id = cp_contract_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
    lv_contract       VARCHAR2(240);
    lv_procedure_name VARCHAR2(100);

  BEGIN
    lv_procedure_name := 'get_contract';
    hr_utility.trace('Entered get_contract');
    open c_get_contract(p_contract_id, p_effective_date);
    fetch c_get_contract into lv_contract;
    close c_get_contract;

    hr_utility.trace('Leaving get_contract');
    return(lv_contract);
  END get_contract ;


  /******************************************************************
   Name      : get_hourly_salaried_code
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_hourly_salaried_code(p_hourly_salaried_code in varchar2
                                   ,p_effective_date       in date
                                    )
  RETURN varchar2 IS

   cursor c_get_hourly_salaried_code(cp_hourly_salaried_code in varchar2
                                    ,cp_effective_date       in date) is
     select hl.meaning
       from hr_lookups hl
      where hl.lookup_type='HOURLY_SALARIED_CODE'
        and hl.lookup_code = cp_hourly_salaried_code
        and hl.enabled_flag='Y'
        and cp_effective_date between
                      nvl(hl.start_date_active, cp_effective_date) and
                      nvl(hl.end_date_active, cp_effective_date);

    lv_hourly_salaried_desc VARCHAR2(240);
    lv_procedure_name       VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_hourly_salaried_code';
     hr_utility.trace('Entered get_hourly_salaried_code');
     open c_get_hourly_salaried_code(p_hourly_salaried_code
                                    ,p_effective_date);
     fetch c_get_hourly_salaried_code into lv_hourly_salaried_desc;
     close c_get_hourly_salaried_code;

     hr_utility.trace('Leaving get_hourly_salaried_code');
     return(lv_hourly_salaried_desc);

  END get_hourly_salaried_code ;


  /******************************************************************
   Name      : get_shift
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_shift(p_soft_coding_keyflex_id in number
                    ,p_effective_date         in date
		    ,p_business_group_id      in varchar2
                    )
  RETURN varchar2 IS

    cursor c_get_shift(cp_soft_coding_keyflex_id in number
                      ,cp_effective_date         in date) is
      select segment5
        from hr_soft_coding_keyflex
       where soft_coding_keyflex_id = cp_soft_coding_keyflex_id;

    cursor c_legislation (cp_business_group_id in number) is
      select org_information9
        from hr_organization_information
       where org_information_context = 'Business Group Information'
         and organization_id = cp_business_group_id;

    cursor c_get_shift_desc(cp_shift_code in varchar2
                      ,cp_effective_date  in date) is
         select hl.meaning
         from hr_lookups hl
        where hl.lookup_type='US_SHIFTS'
          and hl.lookup_code = cp_shift_code
          and hl.enabled_flag='Y'
          and hl.application_id = 800
          and cp_effective_date between
               nvl(hl.start_date_active,cp_effective_date)
               and nvl(hl.end_date_active,cp_effective_date)
        order by meaning;

    lv_shift_desc     VARCHAR2(240);
    lv_shift_code     VARCHAR2(240);
    lv_procedure_name VARCHAR2(100);
    lv_legislation_code       VARCHAR2(2);

  BEGIN
     lv_procedure_name := 'get_shift';
     hr_utility.trace('Entered get_shift');

     open c_legislation (p_business_group_id);
     fetch c_legislation into lv_legislation_code ;
     close c_legislation;
     hr_utility.trace('lv_legislation_code '||lv_legislation_code);

 /* bug:9549403 : Corrected and changed the logic
    to archive shift info for US localization. */

   IF lv_legislation_code = 'US' THEN
     open c_get_shift(p_soft_coding_keyflex_id, p_effective_date);
     fetch c_get_shift into lv_shift_code;
     IF c_get_shift%FOUND THEN
       hr_utility.trace('shift_code = ' || lv_shift_code);

       open c_get_shift_desc(lv_shift_code, p_effective_date);
       fetch c_get_shift_desc into lv_shift_desc;
       close c_get_shift_desc;
     END IF;
     close c_get_shift;
   END IF;

     hr_utility.trace('Leaving get_shift');
     return(lv_shift_desc);

  END get_shift ;


  /******************************************************************
   Name      : get_employee_addr
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_employee_addr (p_person_id      in number
                              ,p_effective_date in date
                              )
  IS
     cursor c_addr_line(cp_person_id      in number
                       ,cp_effective_date in date) is
       select address_line1,
              address_line2,
              address_line3,
              town_or_city,
              region_1,
              region_2,
              region_3,
              postal_code,
              country
        from per_addresses pa
       where pa.person_id = cp_person_id
         and pa.primary_flag = 'Y' --is address primary ?
         and cp_effective_date between pa.date_from
                                   and nvl(pa.date_to, cp_effective_date);

     lv_ee_or_er               VARCHAR2(150);
     lv_ee_address_line_1      VARCHAR2(240);
     lv_ee_address_line_2      VARCHAR2(240);
     lv_ee_address_line_3      VARCHAR2(240);
     lv_ee_town_or_city        VARCHAR2(150);
     lv_ee_region_1            VARCHAR2(240);
     lv_ee_region_2            VARCHAR2(240);
     lv_ee_region_3            VARCHAR2(240);
     lv_ee_postal_code         VARCHAR2(150);
     lv_ee_country             VARCHAR2(150);
     ln_index                  NUMBER;
     lv_procedure_name         VARCHAR2(100);

  BEGIN
     lv_ee_or_er       := 'Employee Address';
     lv_procedure_name := 'get_employee_addr';
     open c_addr_line(p_person_id, p_effective_date);
     fetch c_addr_line into lv_ee_address_line_1
                           ,lv_ee_address_line_2
                           ,lv_ee_address_line_3
                           ,lv_ee_town_or_city
                           ,lv_ee_region_1
                           ,lv_ee_region_2
                           ,lv_ee_region_3
                           ,lv_ee_postal_code
                           ,lv_ee_country;
     close c_addr_line;

     ln_index := pay_emp_action_arch.lrr_act_tab.count;

     hr_utility.trace('ln_index in  get_employee_addr proc is '
            || pay_emp_action_arch.lrr_act_tab.count);
     hr_utility.trace('person_id is'||p_person_id);

     pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'ADDRESS DETAILS';
     pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := '00-000-0000';
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
               := p_person_id;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
               := lv_ee_address_line_1 ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
               := lv_ee_address_line_2;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
               := lv_ee_address_line_3;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
               := lv_ee_town_or_city;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
               := lv_ee_region_1;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
               := lv_ee_region_2;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
               := lv_ee_region_3 ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info12
               := lv_ee_postal_code;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info13
               := lv_ee_country;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
               := lv_ee_or_er;
    hr_utility.trace('Leaving  get_employee_addr');
  END get_employee_addr;


  /******************************************************************
   Name      : get_net_pay_distribution
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_net_pay_distribution(
                    p_pre_pay_action_id     in number
                   ,p_assignment_id         in number
                   ,p_curr_pymt_eff_date    in date
                   ,p_ppp_source_action_id  in number
               )
  IS


    cursor c_net_pay(cp_pre_pay_action_id    in number
                    ,cp_assignment_id        in number
                    ,cp_curr_pymt_eff_date   in date
                    ,cp_ppp_source_action_id in number
                    ) is
      select pea.segment1  seg1,
             pea.segment2  seg2,
             pea.segment3  seg3,
             pea.segment4  seg4,
             pea.segment5  seg5,
             pea.segment6  seg6,
             pea.segment7  seg7,
             pea.segment8  seg8,
             pea.segment9  seg9,
             pea.segment10 seg10,
             ppp.value     amount,
             ppp.pre_payment_id,
             popm.org_payment_method_id,
             popm.org_payment_method_name,
             pppm.personal_payment_method_id
        from pay_assignment_actions paa,
             pay_pre_payments ppp,
             pay_org_payment_methods_f popm ,
             pay_personal_payment_methods_f pppm,
             pay_external_accounts pea
       where paa.assignment_action_id = cp_pre_pay_action_id
         and ppp.assignment_action_id = paa.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ( (    ppp.source_action_id is null
                and cp_ppp_source_action_id is null)
              or
               -- is it a Normal or Process Separate specific
               -- Payments should be included in the Standard
               -- SOE. Only Separate Payments should be in
               -- a Separate SOE.
               (ppp.source_action_id is not null
                and cp_ppp_source_action_id is null
                and exists (
                       select ''
                         from pay_run_types_f prt,
                              pay_assignment_actions paa_run,
                              pay_payroll_actions    ppa_run
                        where paa_run.assignment_action_id
                                               = ppp.source_action_id
                          and paa_run.payroll_action_id
                                               = ppa_run.payroll_action_id
                          and paa_run.run_type_id = prt.run_type_id
                          and prt.run_method in ('P', 'N')
                          and ppa_run.effective_date
                                      between prt.effective_start_date
                                          and prt.effective_end_date
                             )
                )
              or
                (cp_ppp_source_action_id is not null
                 and ppp.source_action_id = cp_ppp_source_action_id)
             )
         and ppp.org_payment_method_id = popm.org_payment_method_id
         and popm.defined_balance_id is not null
         and pppm.personal_payment_method_id(+)
                            = ppp.personal_payment_method_id
         and pea.external_account_id = nvl(pppm.external_account_id,popm.external_account_id)
         and cp_curr_pymt_eff_date between popm.effective_start_date
                                       and popm.effective_end_date
         and cp_curr_pymt_eff_date between nvl(pppm.effective_start_date,
                                               cp_curr_pymt_eff_date)
                                       and nvl(pppm.effective_end_date,
                                               cp_curr_pymt_eff_date);

    ln_index                   NUMBER;
    lv_segment1                VARCHAR2(300);
    lv_segment2                VARCHAR2(300);
    lv_segment3                VARCHAR2(300);
    lv_segment4                VARCHAR2(300);
    lv_segment5                VARCHAR2(300);
    lv_segment6                VARCHAR2(300);
    lv_segment7                VARCHAR2(300);
    lv_segment8                VARCHAR2(300);
    lv_segment9                VARCHAR2(300);
    lv_segment10               VARCHAR2(300);
    ln_value                   NUMBER(15,2);
    ln_pre_payment_id          NUMBER;
    ln_org_payment_method_id   NUMBER;
    lv_org_payment_method_name VARCHAR2(300);
    ln_emp_payment_method_id   NUMBER;
    lv_procedure_name          VARCHAR2(100);

   BEGIN


     open  c_net_pay(p_pre_pay_action_id
                    ,p_assignment_id
                    ,p_curr_pymt_eff_date
                    ,p_ppp_source_action_id);
     hr_utility.trace('Opened cursor get_net_pay_distribution ');

     loop
        fetch c_net_pay into lv_segment1
                            ,lv_segment2
                            ,lv_segment3
                            ,lv_segment4
                            ,lv_segment5
                            ,lv_segment6
                            ,lv_segment7
                            ,lv_segment8
                            ,lv_segment9
                            ,lv_segment10
                            ,ln_value
                            ,ln_pre_payment_id
                            ,ln_org_payment_method_id
                            ,lv_org_payment_method_name
                            ,ln_emp_payment_method_id;
        hr_utility.trace('Fetched get_net_pay_distribution ');
        if c_net_pay%notfound then
           exit;
        end if;

        ln_index := pay_emp_action_arch.lrr_act_tab.count;

        hr_utility.trace('ln_index in  get_net_pay_dist proc is '
               || pay_emp_action_arch.lrr_act_tab.count);

        pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
              := 'EMPLOYEE NET PAY DISTRIBUTION';
        pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
              := '00-000-0000';
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
              := ln_org_payment_method_id;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
              := ln_emp_payment_method_id;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
              := null;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
              := lv_segment1;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
              := lv_segment2;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
              := lv_segment3;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
              := lv_segment4;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
              := lv_segment5;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
              := lv_segment6;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
              := lv_segment7 ;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info12
              := lv_segment8;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info13
              := lv_segment9;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
              := lv_segment10;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info15
              := ln_pre_payment_id;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info16
              := fnd_number.number_to_canonical(ln_value);  /* Bug 3311866*/
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info17
              := p_pre_pay_action_id;
        pay_emp_action_arch.lrr_act_tab(ln_index).act_info18
              := lv_org_payment_method_name;
     end loop;
     close c_net_pay;
     hr_utility.set_location(gv_package || lv_procedure_name,100);
  END get_net_pay_distribution;

/******************************************************************
   Name      : get_tp_pay_distribution
   Purpose   : Get the Third Party Pay Distribution
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_3rdparty_pay_distribution(
                    p_pre_pay_action_id     in number
                   ,p_assignment_id         in number
                   ,p_curr_pymt_eff_date    in date
                   ,p_ppp_source_action_id  in number
                   ,p_payroll_id            in number
               )
  IS

    cursor c_child_action (cp_pre_pay_action_id in number
                          ,cp_assignment_id     in number) is
      select paa.assignment_action_id
        from pay_assignment_actions paa
       where paa.source_action_id = cp_pre_pay_action_id
         and paa.assignment_id = cp_assignment_id
         and paa.action_status = 'C';

    cursor c_third_party_pay(cp_pre_pay_action_id    in number
                            ,cp_assignment_id        in number
                            ,cp_curr_pymt_eff_date   in date
                            ,cp_ppp_source_action_id in number
                    ) is
      select pea.segment1  seg1,
             pea.segment2  seg2,
             pea.segment3  seg3,
             pea.segment4  seg4,
             pea.segment5  seg5,
             pea.segment6  seg6,
             pea.segment7  seg7,
             pea.segment8  seg8,
             pea.segment9  seg9,
             pea.segment10 seg10,
             ppp.value     amount,
             ppp.pre_payment_id,
             popm.org_payment_method_id,
             popm.org_payment_method_name,
             pppm.personal_payment_method_id
        from pay_assignment_actions paa,
             pay_pre_payments ppp,
             pay_org_payment_methods_f popm ,
             pay_personal_payment_methods_f pppm,
             pay_external_accounts pea
       where paa.assignment_action_id = cp_pre_pay_action_id
         and ppp.assignment_action_id = paa.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ( (    ppp.source_action_id is null
                and cp_ppp_source_action_id is null)
              or
               -- is it a Normal or Process Separate specific
               -- Payments should be included in the Standard
               -- SOE. Only Separate Payments should be in
               -- a Separate SOE.
               (ppp.source_action_id is not null
                and cp_ppp_source_action_id is null
                and exists (
                       select ''
                         from pay_run_types_f prt,
                              pay_assignment_actions paa_run,
                              pay_payroll_actions    ppa_run
                        where paa_run.assignment_action_id
                                               = ppp.source_action_id
                          and paa_run.payroll_action_id
                                               = ppa_run.payroll_action_id
                          and paa_run.run_type_id = prt.run_type_id
                          and prt.run_method in ('P', 'N')
                          and ppa_run.effective_date
                                      between prt.effective_start_date
                                          and prt.effective_end_date
                             )
                )
              or
                (cp_ppp_source_action_id is not null
                 and ppp.source_action_id = cp_ppp_source_action_id)
             )
         and ppp.org_payment_method_id = popm.org_payment_method_id
         and popm.defined_balance_id is null
         and pppm.personal_payment_method_id(+)
                            = ppp.personal_payment_method_id
         and pea.external_account_id(+) = pppm.external_account_id
         and cp_curr_pymt_eff_date between popm.effective_start_date
                                       and popm.effective_end_date
         and cp_curr_pymt_eff_date between nvl(pppm.effective_start_date,
                                               cp_curr_pymt_eff_date)
                                       and nvl(pppm.effective_end_date,
                                               cp_curr_pymt_eff_date);

    ln_index                   NUMBER;
    lv_segment1                VARCHAR2(300);
    lv_segment2                VARCHAR2(300);
    lv_segment3                VARCHAR2(300);
    lv_segment4                VARCHAR2(300);
    lv_segment5                VARCHAR2(300);
    lv_segment6                VARCHAR2(300);
    lv_segment7                VARCHAR2(300);
    lv_segment8                VARCHAR2(300);
    lv_segment9                VARCHAR2(300);
    lv_segment10               VARCHAR2(300);
    ln_value                   NUMBER(15,2);
    ln_pre_payment_id          NUMBER;
    ln_org_payment_method_id   NUMBER;
    lv_org_payment_method_name VARCHAR2(300);
    ln_emp_payment_method_id   NUMBER;
    k                          NUMBER;

    TYPE actions_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    ltt_actions                actions_tab;

    lv_procedure_name          VARCHAR2(100);

  BEGIN
    lv_procedure_name := 'get_3rdparty_pay_distribution';
    hr_utility.set_location(gv_package || lv_procedure_name,10);
    hr_utility.trace('p_pre_pay_action_id   = ' || p_pre_pay_action_id);
    hr_utility.trace('p_curr_pymt_eff_date = '  || p_curr_pymt_eff_date);
    hr_utility.trace('p_ppp_source_action_id = '|| p_ppp_source_action_id);
    k := 0;

    -- Check if Multi assignment payment is enabled
    if pay_emp_action_arch.gv_multi_payroll_pymt is null then
       pay_emp_action_arch.gv_multi_payroll_pymt
              := pay_emp_action_arch.get_multi_assignment_flag(
                              p_payroll_id       => p_payroll_id
                             ,p_effective_date   => p_curr_pymt_eff_date);
    end if;
    hr_utility.set_location(gv_package || lv_procedure_name,20);

    if nvl(pay_emp_action_arch.gv_multi_payroll_pymt, 'N') = 'Y' then
       -- If Multi Assignment Payment is enabled, get the child prepayment
       -- actions as payment information is stored against child.
       -- Insert this data in pl/sql table.
       for cval in c_child_action(p_pre_pay_action_id, p_assignment_id) loop
           ltt_actions(k) := cval.assignment_action_id;
           k := k + 1;
       end loop;
       hr_utility.set_location(gv_package || lv_procedure_name,30);
    else
       ltt_actions(k) := p_pre_pay_action_id;
       k := k + 1;
       hr_utility.set_location(gv_package || lv_procedure_name,40);
    end if;

    -- Value of k will be zero only if the payroll is enabled for multi
    -- assignment payments and we are processing seperate check action.
    -- In this case, passed assignment action is added to pl/sql table.
    if k = 0 then
       ltt_actions(k) := p_pre_pay_action_id;
    end if;

    for j in ltt_actions.first .. ltt_actions.last loop
        hr_utility.trace('assignment action = ' || ltt_actions(j));
    end loop;

    for j in ltt_actions.first .. ltt_actions.last loop
        open c_third_party_pay(ltt_actions(j)
                              ,p_assignment_id
                              ,p_curr_pymt_eff_date
                              ,p_ppp_source_action_id);

        loop
           fetch c_third_party_pay into lv_segment1
                                       ,lv_segment2
                                       ,lv_segment3
                                       ,lv_segment4
                                       ,lv_segment5
                                       ,lv_segment6
                                       ,lv_segment7
                                       ,lv_segment8
                                       ,lv_segment9
                                       ,lv_segment10
                                       ,ln_value
                                       ,ln_pre_payment_id
                                       ,ln_org_payment_method_id
                                       ,lv_org_payment_method_name
                                       ,ln_emp_payment_method_id;
           hr_utility.trace('Fetched get_3rdparty_pay_distribution ');
           if c_third_party_pay%notfound then
              exit;
           end if;

           ln_index := pay_emp_action_arch.lrr_act_tab.count;

           hr_utility.trace('ln_index in  get_3rdparty_pay_distribution proc is '
                              || pay_emp_action_arch.lrr_act_tab.count);

           pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
                 := 'EMPLOYEE THIRD PARTY PAYMENTS';
           pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                 := '00-000-0000';
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
                 := ln_org_payment_method_id;
           hr_utility.trace('ln_org_payment_method_id'||ln_org_payment_method_id);
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
                 := ln_emp_payment_method_id;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
                 := null;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info5
                 := lv_segment1;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
                 := lv_segment2;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
                 := lv_segment3;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
                 := lv_segment4;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
                 := lv_segment5;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
                 := lv_segment6;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
                 := lv_segment7 ;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info12
                 := lv_segment8;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info13
                 := lv_segment9;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
                 := lv_segment10;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info15
                 := ln_pre_payment_id;
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info16
                 := fnd_number.number_to_canonical(ln_value);  /* Bug 3311866*/
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info17
                 := ltt_actions(j);
           pay_emp_action_arch.lrr_act_tab(ln_index).act_info18
                 := lv_org_payment_method_name;
        end loop;
        close c_third_party_pay;
    end loop;
    hr_utility.set_location(gv_package || lv_procedure_name,100);

  END get_3rdparty_pay_distribution;



  PROCEDURE get_org_other_info(p_organization_id   in number
                              ,p_business_group_id in number)
  IS
    cursor c_get_other_info(cp_organization_id         in number
                           ,cp_org_information_context in varchar2) is
       select hri.org_information1,
              hri.org_information2, hri.org_information3,
              hri.org_information4, hri.org_information5,
              hri.org_information6, hri.org_information7,
              org_information_context ----Bug 7115367
         from hr_organization_information hri
        where hri.organization_id = cp_organization_id
          and hri.org_information_context =  cp_org_information_context
          and hri.org_information1 = 'MESG';

    lv_org_information1         hr_organization_information.org_information1%type;
    lv_org_information2         hr_organization_information.org_information2%type;
    lv_org_information3         hr_organization_information.org_information3%type;
    lv_org_information4         hr_organization_information.org_information4%type;
    lv_org_information5         hr_organization_information.org_information5%type;
    lv_org_information6         hr_organization_information.org_information6%type;
    lv_org_information7         hr_organization_information.org_information7%type;
    lv_org_information_cntxt    hr_organization_information.org_information_context%type; ----Bug 7115367

    ln_index               NUMBER;
    lv_exists              VARCHAR2(1);
    lv_procedure_name      VARCHAR2(100);

  BEGIN
     lv_procedure_name := '.get_org_other_info';
     lv_exists := 'N';

     if p_organization_id is not null then
        open c_get_other_info(p_organization_id
                             ,'Organization:Payslip Info') ;
        loop
           hr_utility.set_location(gv_package || lv_procedure_name, 20);
           fetch c_get_other_info into lv_org_information1
                                      ,lv_org_information2
                                      ,lv_org_information3
                                      ,lv_org_information4
                                      ,lv_org_information5
                                      ,lv_org_information6
                                      ,lv_org_information7
                                      ,lv_org_information_cntxt;
           if  c_get_other_info%notfound then
               hr_utility.set_location(gv_package || lv_procedure_name, 30);
               exit;
           end if;


           hr_utility.set_location(gv_package || lv_procedure_name, 40);
           if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
              for i in pay_emp_action_arch.ltr_ppa_arch.first ..
                       pay_emp_action_arch.ltr_ppa_arch.last loop
                  if pay_emp_action_arch.ltr_ppa_arch(i).act_info1
                             = p_organization_id and
                     pay_emp_action_arch.ltr_ppa_arch(i).act_info2
                             = 'MESG' and
                     pay_emp_action_arch.ltr_ppa_arch(i).act_info6
                             = lv_org_information6 then
                     lv_exists := 'Y';
                     exit;
                  end if;
              end loop;
           end if;

           if lv_exists = 'N' then
              ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                   := 'EMPLOYEE OTHER INFORMATION';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                   := '00-000-0000';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                   := p_organization_id;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info2
                   := 'MESG';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info4
                   := nvl(lv_org_information7,lv_org_information4) ;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                   := lv_org_information5;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                   := lv_org_information6;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info13
                   := lv_org_information_cntxt; ----Bug 7115367
           end if;
        end loop ;
        close c_get_other_info;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);
     if p_business_group_id is not null then
        open c_get_other_info(p_business_group_id
                             ,'Business Group:Payslip Info') ;
        loop
           hr_utility.set_location(gv_package || lv_procedure_name, 110);
           fetch c_get_other_info into lv_org_information1
                                      ,lv_org_information2
                                      ,lv_org_information3
                                      ,lv_org_information4
                                      ,lv_org_information5
                                      ,lv_org_information6
                                      ,lv_org_information7
                                      ,lv_org_information_cntxt; ----Bug 7115367
           if c_get_other_info%notfound then
              hr_utility.set_location(gv_package || lv_procedure_name, 120);
              exit;
           end if;

           hr_utility.set_location(gv_package || lv_procedure_name, 130);
           if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
              for i in pay_emp_action_arch.ltr_ppa_arch.first ..
                       pay_emp_action_arch.ltr_ppa_arch.last loop
                  if pay_emp_action_arch.ltr_ppa_arch(i).act_info1
                             = p_business_group_id and
                     pay_emp_action_arch.ltr_ppa_arch(i).act_info2
                             = 'MESG' and
                     pay_emp_action_arch.ltr_ppa_arch(i).act_info6
                             = lv_org_information6 then
                     lv_exists := 'Y';
                     exit;
                  end if;
              end loop;
           end if;

           if lv_exists = 'N' then
              ln_index  := pay_emp_action_arch.ltr_ppa_arch.count;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                   := 'EMPLOYEE OTHER INFORMATION';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                   := '00-000-0000';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                   := p_business_group_id;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info2
                   := 'MESG';
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info4
                   := nvl(lv_org_information7,lv_org_information4) ;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                   := lv_org_information5 ;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                   := lv_org_information6;
              pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info13
                   := lv_org_information_cntxt; --Bug 7115367
           end if;
        end loop ;
        close c_get_other_info;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 140);

  END get_org_other_info;


  PROCEDURE get_org_address(p_organization_id in number)
  IS
    cursor c_addr_line(cp_organization_id in number) is
       select address_line_1, address_line_2,
              address_line_3, town_or_city,
              region_1,       region_2,
              region_3,       postal_code,
              country,        telephone_number_1
         from hr_locations hl,
              hr_organization_units hou
           where hou.organization_id = cp_organization_id
             and hou.location_id     = hl.location_id;

     lv_ee_or_er            VARCHAR2(150);
     lv_er_address_line_1   VARCHAR2(240);
     lv_er_address_line_2   VARCHAR2(240);
     lv_er_address_line_3   VARCHAR2(240);
     lv_er_town_or_city     VARCHAR2(150);
     lv_er_region_1         VARCHAR2(240);
     lv_er_region_2         VARCHAR2(240);
     lv_er_region_3         VARCHAR2(240);
     lv_er_postal_code      VARCHAR2(150);
     lv_er_country          VARCHAR2(240);
     lv_er_telephone        VARCHAR2(150);

     lv_exists              VARCHAR2(1);
     ln_index               NUMBER;
     lv_procedure_name      VARCHAR2(100);

  BEGIN
     lv_procedure_name := '.get_org_address';
     lv_ee_or_er := 'Employer Address';
     lv_exists   := 'N';
     -- Get Employer address
     hr_utility.set_location(gv_package || lv_procedure_name, 210);
     if p_organization_id is null then
        return;
     end if;
     open c_addr_line(p_organization_id);
     fetch c_addr_line into lv_er_address_line_1
                              ,lv_er_address_line_2
                              ,lv_er_address_line_3
                              ,lv_er_town_or_city
                              ,lv_er_region_1
                              ,lv_er_region_2
                              ,lv_er_region_3
                              ,lv_er_postal_code
                              ,lv_er_country
                              ,lv_er_telephone;
      close c_addr_line;
      hr_utility.set_location(gv_package || lv_procedure_name, 250);

      if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
         for i in pay_emp_action_arch.ltr_ppa_arch.first ..
                  pay_emp_action_arch.ltr_ppa_arch.last loop
             if pay_emp_action_arch.ltr_ppa_arch(i).act_info1
                        = p_organization_id and
                pay_emp_action_arch.ltr_ppa_arch(i).act_info14
                        = 'Employer Address' then
                lv_exists := 'Y';
                exit;
             end if;
         end loop;
      end if;

      if lv_exists = 'N' then
         hr_utility.set_location(gv_package || lv_procedure_name, 260);
         ln_index := pay_emp_action_arch.ltr_ppa_arch.count;

         pay_emp_action_arch.ltr_ppa_arch(ln_index).action_info_category
                      := 'ADDRESS DETAILS';
         pay_emp_action_arch.ltr_ppa_arch(ln_index).jurisdiction_code
                     := '00-000-0000';
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info1
                     := p_organization_id;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info5
                     := lv_er_address_line_1 ;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info6
                     := lv_er_address_line_2;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info7
                     := lv_er_address_line_3;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info8
                     := lv_er_town_or_city;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info9
                  := lv_er_region_1;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info10
                     := lv_er_region_2;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info11
                     := lv_er_region_3 ;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info12
                     := lv_er_postal_code;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info13
                     := lv_er_country;
         pay_emp_action_arch.ltr_ppa_arch(ln_index).act_info14
                     := lv_ee_or_er;
      end if;

  END get_org_address;

 /******************************************************************
   Name      : This procedure archives data at payroll action level.
               This would be called from the archive_data procedure
               (for the first chunk only). The
               action_infomration_categories archived by this are
               EMPLOYEE OTHER INFORMATION for MESG  and
               ADDRESS DETAILS for Employer Address
   Arguments : p_payroll_action_id  Archiver Payroll Action ID
               p_payroll_id         Payroll ID
               p_effective_date     End Date of Archiver
   Notes     :
  ******************************************************************/
  PROCEDURE arch_pay_action_level_data(p_payroll_action_id in number
                                      ,p_payroll_id        in number
                                      ,p_effective_date    in date
                                      )
  IS

   ln_organization_id   NUMBER(15);
   ln_business_group_id NUMBER(15);
   lv_procedure_name    VARCHAR2(100);

   cursor c_get_organization(cp_payroll_id        in number
                            ,cp_effective_date    in date
                            ) is
      select /*+ index(paf PER_ASSIGNMENTS_F_N7)*/
             distinct paf.organization_id,   -- Bug 3354127
                      paf.business_group_id
        from per_all_assignments_f paf
       where paf.payroll_id = cp_payroll_id
         and cp_effective_date between paf.effective_start_date
                                   and paf.effective_end_date;

   BEGIN
       lv_procedure_name := '.arch_pay_action_level_data';
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       open c_get_organization(p_payroll_id, p_effective_date);
       loop
          fetch c_get_organization into ln_organization_id,
                                        ln_business_group_id;
          if c_get_organization%notfound then
             exit;
          end if;

          get_org_other_info(ln_organization_id, ln_business_group_id);
          get_org_address(ln_organization_id);

       end loop;
       close c_get_organization;

       hr_utility.set_location(gv_package || lv_procedure_name, 140);

       -- insert rows in pay_action_information table
       if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
          insert_rows_thro_api_process(
                    p_action_context_id    =>  p_payroll_action_id
                    ,p_action_context_type => 'PA'
                    ,p_assignment_id       => null
                    ,p_tax_unit_id         => null
                    ,p_curr_pymt_eff_date  => p_effective_date
                    ,p_tab_rec_data        => pay_emp_action_arch.ltr_ppa_arch
                    );
       end if;
  EXCEPTION
    when others then
      hr_utility.trace('Error in ' || gv_package || '.' || lv_procedure_name || '-'
                                       || to_char(sqlcode) || '-' || sqlerrm);
      hr_utility.set_location(gv_package || lv_procedure_name, 130);
      raise hr_utility.hr_error;

  END arch_pay_action_level_data;


 /******************************************************************
   Name      : This procedure archives data at payroll action level.
               This is a overloaded function. The function above is
               needs to be called once and it gets all the Orgs and
               BG for an assignment assigned to the payroll passed
               to the procedure.

               The procedure below needs to called from the de-init
               code i.e. it is the last procedure called by the
               archive process. This procedure is dependent on the
               assignment level archive data and archives Employer
               Address for the HR Organization, Tax Unit or
               Business Group assignemnt to the assignments archived.

               The procedure also archives messages defined for a BG
               or Organization.

               action_information_categories archived by this are
               EMPLOYEE OTHER INFORMATION for MESG  and
               ADDRESS DETAILS for Employer Address
   Arguments : p_payroll_action_id  Archiver Payroll Action ID
               p_effective_date     End Date of Archiver
   Notes     :
  ******************************************************************/
  PROCEDURE arch_pay_action_level_data(p_payroll_action_id in number
                                      ,p_effective_date    in date
                                      )
  IS

    cursor c_employer_info (cp_payroll_action_id in number) is
      select distinct
             nvl(pai.tax_unit_id, -1)
            ,pai.action_information2 organization_id
        from pay_action_information pai
            ,pay_assignment_actions paa
       where pai.action_information_category = 'EMPLOYEE DETAILS'
         and pai.action_context_type = 'AAP'
         and pai.action_context_id = paa.assignment_action_id
         and paa.payroll_Action_id = cp_payroll_action_id
         and paa.action_status = 'C';

    cursor c_bg (cp_payroll_action_id in number) is
      select ppa.business_group_id
        from pay_payroll_actions ppa
       where ppa.payroll_action_id = cp_payroll_action_id;

    ln_business_group_id NUMBER;
    ln_organization_id   NUMBER;
    ln_tax_unit_id       NUMBER;

    lv_procedure_name    VARCHAR2(100);

  BEGIN
    lv_procedure_name := '.arch_pay_action_level_data_deinit';
    hr_utility.set_location(gv_package || lv_procedure_name, 1);

    delete from pay_action_information pai
     where pai.action_context_id = p_payroll_action_id
       and pai.action_context_type = 'PA'
       and pai.action_information_category in ('EMPLOYEE OTHER INFORMATION',
                                               'ADDRESS DETAILS')
       and (pai.action_information14 = 'Employer Address' or
            pai.action_information2 = 'MESG');

    /* Get Business Group ID */
    open c_bg(p_payroll_action_id);
    fetch c_bg into ln_business_group_id;
    close c_bg;

    /* Archive Business Group Address and Address */
    get_org_other_info(null, ln_business_group_id);
    get_org_address(ln_business_group_id);

    hr_utility.set_location(gv_package || lv_procedure_name, 5);
    /* Get all the Organization ID and Tax Unit ID for assignment
       archived by the archiver. For the ORganizations get any
       message which needs to be archived and also archive the
       address information */
    open c_employer_info(p_payroll_action_id);
    loop
       fetch c_employer_info into ln_tax_unit_id, ln_organization_id;
       if c_employer_info%notfound then
          exit;
       end if;

       hr_utility.trace('Organization ID = ' || ln_organization_id);
       hr_utility.trace('Tax Unit ID = '     || ln_tax_unit_id);
       /* Archive Organization Message */
       get_org_other_info(ln_organization_id, null);
       get_org_address(ln_organization_id);
       if ln_organization_id <> ln_tax_unit_id and ln_tax_unit_id <> -1 then
          get_org_address(ln_tax_unit_id);
       end if;

    end loop;
    close c_employer_info;

    hr_utility.set_location(gv_package || lv_procedure_name, 100);

    -- insert rows in pay_action_information table
    if pay_emp_action_arch.ltr_ppa_arch.count > 0 then
       insert_rows_thro_api_process(
                    p_action_context_id    =>  p_payroll_action_id
                    ,p_action_context_type => 'PA'
                    ,p_assignment_id       => null
                    ,p_tax_unit_id         => null
                    ,p_curr_pymt_eff_date  => p_effective_date
                    ,p_tab_rec_data        => pay_emp_action_arch.ltr_ppa_arch
                    );
    end if;
    hr_utility.set_location(gv_package || lv_procedure_name, 150);

  EXCEPTION
    when others then
      hr_utility.trace('Error in ' || gv_package || '.' || lv_procedure_name || '-'
                                       || to_char(sqlcode) || '-' || sqlerrm);
      hr_utility.set_location(gv_package || lv_procedure_name, 130);
      raise hr_utility.hr_error;

  END arch_pay_action_level_data;


  PROCEDURE get_personal_information(
                   p_payroll_action_id    in number
                  ,p_assactid             in number
                  ,p_assignment_id        in number
                  ,p_curr_pymt_ass_act_id in number
                  ,p_curr_eff_date        in date
                  ,p_date_earned          in date
                  ,p_curr_pymt_eff_date   in date
                  ,p_tax_unit_id          in number
                  ,p_time_period_id       in number
                  ,p_ppp_source_action_id in number
                  ,p_run_action_id        in number
                  ,p_ytd_balcall_aaid     in number default null
                 )
  IS
    cursor c_employee_details(cp_assignment_id in number
                            , cp_curr_eff_date in date
				    , cp_date_earned in date
                             ) is
      select ppf.full_name,
             ppf.national_identifier,
             ppf.person_id,
             pps.date_start,
             ppf.employee_number,
             ppf.original_date_of_hire,
             pps.adjusted_svc_date,
             paf.assignment_number,
             paf.location_id,
             paf.organization_id,
             paf.job_id,
             paf.position_id,
             paf.pay_basis_id,
             paf.frequency,
             paf.grade_id,
             paf.bargaining_unit_code,
             paf.collective_agreement_id,
             paf.contract_id,
             paf.special_ceiling_step_id,
             paf.people_group_id,
             paf.normal_hours,
             paf.time_normal_start,
             paf.time_normal_finish,
             paf.business_group_id,
             paf.soft_coding_keyflex_id,
             paf.hourly_salaried_code
        from per_assignments_f paf,
             per_all_people_f ppf,
		 per_all_people_f ppf1,
             per_periods_of_service pps
       where paf.person_id = ppf.person_id
         and paf.assignment_id = cp_assignment_id
         and ppf1.person_id = ppf.person_id  /* 8305579 */
         and (( ppf1.person_type_id = 6
         and cp_date_earned between paf.effective_start_date
                                  and paf.effective_end_date)
         or
              ( ppf1.person_type_id <> 6
         and cp_curr_eff_date between paf.effective_start_date
                                  and paf.effective_end_date))
         and cp_date_earned between ppf.effective_start_date
                                  and ppf.effective_end_date
         and pps.person_id = ppf.person_id
         and pps.date_start = (select max(pps1.date_start)
                                 from per_periods_of_service pps1
                                where pps1.person_id = paf.person_id
                                  and pps1.date_start <= cp_date_earned);

    cursor c_period_details (cp_time_period_id in number) is
      select payroll_id, period_type, start_date, cut_off_date
        from per_time_periods
       where time_period_id = cp_time_period_id;

    cursor c_step (cp_sp_ceil_step_id in number,
                   cp_effective_date  in date) is
      select count(*)
        from per_spinal_points psp,
             per_spinal_points psp2,
             per_spinal_point_steps_f psps,
             per_spinal_point_steps_f psps2
       where psps.step_id = cp_sp_ceil_step_id
         and psp.spinal_point_id = psps.spinal_point_id
         and psps.grade_spine_id = psps2.grade_spine_id
         and psp2.spinal_point_id = psps2.spinal_point_id
         and psp.sequence >= psp2.sequence
         and cp_effective_date between psps.effective_start_date
                                   and psps.effective_end_date
         and cp_effective_date between psps2.effective_start_date
                                   and psps2.effective_end_date
        group by psp.spinal_point,
                 psps.step_id,
                 psps.sequence,
                 psps.effective_start_date,
                 psps.effective_end_date;

    CURSOR er_phone_number(cp_organization_id in number) IS
         select telephone_number_1
           from hr_locations hl,
                hr_organization_units hou
          where hou.organization_id = cp_organization_id
            and hou.location_id     = hl.location_id;


    lv_full_name               VARCHAR2(300);
    lv_national_identifier     VARCHAR2(100);
    ln_person_id               NUMBER;
    ln_index                   NUMBER;
    ld_date_start              DATE;
    lv_employee_number         VARCHAR2(50);
    ld_original_date_of_hire   DATE;
    ld_adjusted_svc_date       DATE;
    lv_assignment_number       VARCHAR2(50);
    ln_location_id             NUMBER;
    lv_location_code           VARCHAR2(240);
    ln_organization_id         NUMBER;
    ln_job_id                  NUMBER;
    ln_pay_basis_id            NUMBER;
    lv_frequency               VARCHAR2(30);
    ln_grade_id                NUMBER;
    lv_bargaining_unit_code    VARCHAR2(80);
    ln_collective_agreement_id NUMBER(9);
    ln_contract_id             NUMBER;
    ln_special_ceiling_step_id NUMBER;
    ln_people_group_id         NUMBER;
    ln_normal_hours            NUMBER(22,3);
    lv_time_normal_start       VARCHAR2(5) :=null;
    lv_time_normal_finish      VARCHAR2(5) :=null;
    ln_position_id             NUMBER;
    lv_position_name           VARCHAR2(240) :=null;
    ln_soft_coding_keyflex_id  NUMBER;
    lv_gre_name                VARCHAR2(240) :=null;
    lv_er_phone_number         VARCHAR2(240) :=null;
    ln_business_group_id       NUMBER;
    lv_organization_name       VARCHAR2(240) :=null;
    lv_job_name                VARCHAR2(240) :=null;
    lv_pay_basis               VARCHAR2(240) :=null;
    lv_frequency_desc          VARCHAR2(240) :=null;
    lv_grade                   VARCHAR2(240);
    lv_bargaining_unit         VARCHAR2(240);
    lv_collective_agreement    VARCHAR2(240);
    lv_contract                VARCHAR2(240);
    lv_progression_point       VARCHAR2(240);
    lv_step                    VARCHAR2(240);
    lv_pay_calc_method         VARCHAR2(240);
    lv_shift_desc              VARCHAR2(240);
    lv_hourly_salaried_code    VARCHAR2(240);
    lv_hourly_salaried_desc    VARCHAR2(240);

    ln_payroll_id              NUMBER;
    lv_period_type             VARCHAR2(240);
    ld_period_start_date       DATE;
    ld_period_end_date         DATE;

    ln_proposed_salary          NUMBER(20,5);
    ln_pay_annualization_factor NUMBER(20,5);

    lv_exists VARCHAR2(1);
    ln_index1 number;
    lv_procedure_name           VARCHAR2(100);

  BEGIN
     lv_procedure_name := 'get_personal_information';
     lv_exists := 'N';
     hr_utility.trace('Entered get_personal_information');
     initialization_process;

     hr_utility.trace('p_assactid = '             || p_assactid);
     hr_utility.trace('p_assignment_id = '        || p_assignment_id);
     hr_utility.trace('p_curr_pymt_ass_act_id = ' || p_curr_pymt_ass_act_id);
     hr_utility.trace('p_curr_eff_date = '        || p_curr_eff_date);
     hr_utility.trace('p_date_earned = '          || p_date_earned);
     hr_utility.trace('p_curr_pymt_eff_date = '   || p_curr_pymt_eff_date);
     hr_utility.trace('p_tax_unit_id = '          || p_tax_unit_id);
     hr_utility.trace('p_time_period_id = '       || p_time_period_id);
     hr_utility.trace('p_run_action_id = '        || p_run_action_id);
--Bug 5585331 starts here
--     open c_employee_details(p_assignment_id,p_curr_eff_date);
-- Bug 8305579 modified cursor and passed extra parameter of p_curr_eff_date
     open c_employee_details(p_assignment_id,p_curr_eff_date,p_date_earned);
--Bug 5585331 ends here
     hr_utility.trace('Opened c_employee_details of get_personal_information ');
     fetch c_employee_details into lv_full_name,
                                   lv_national_identifier,
                                   ln_person_id,
                                   ld_date_start,
                                   lv_employee_number,
                                   ld_original_date_of_hire,
                                   ld_adjusted_svc_date,
                                   lv_assignment_number,
                                   ln_location_id,
                                   ln_organization_id,
                                   ln_job_id,
                                   ln_position_id,
                                   ln_pay_basis_id,
                                   lv_frequency,
                                   ln_grade_id,
                                   lv_bargaining_unit_code,
                                   ln_collective_agreement_id,
                                   ln_contract_id,
                                   ln_special_ceiling_step_id,
                                   ln_people_group_id,
                                   ln_normal_hours,
                                   lv_time_normal_start,
                                   lv_time_normal_finish,
                                   ln_business_group_id,
                                   ln_soft_coding_keyflex_id,
                                   lv_hourly_salaried_code;
     if c_employee_details%notfound then
        hr_utility.raise_error;
     end if;

     hr_utility.trace('Opening c_period_details');
     open c_period_details(p_time_period_id);
     fetch c_period_details into ln_payroll_id,
                                 lv_period_type,
                                 ld_period_start_date,
                                 ld_period_end_date;
     if c_period_details%notfound then
        hr_utility.trace('Time Period details not found for time_period_id '
                          ||to_char(p_time_period_id));
        --hr_utility.raise_error;
     end if;
     close c_period_details;


     lv_gre_name := get_organization_name(p_tax_unit_id);
     lv_organization_name := get_organization_name(ln_organization_id);

     if ln_job_id is not null then
        lv_job_name := get_job_name(ln_job_id
                                   ,p_curr_eff_date);
     end if ;

     if ln_position_id is not null then
        lv_position_name  := get_position(ln_position_id
                                         ,p_curr_eff_date);
     end if;

     if ln_pay_basis_id is not null then
        lv_pay_basis := get_pay_basis(ln_pay_basis_id
                                     ,p_curr_eff_date);
     end if;

     if ln_location_id is not null then
        lv_location_code := get_location(ln_location_id);
     end if;

     ln_proposed_salary := get_proposed_emp_salary(p_assignment_id
                                                  ,ln_pay_basis_id
                                                  ,lv_pay_basis
                                                  ,p_date_earned);

     ln_pay_annualization_factor := get_emp_annualization_factor(
                                           ln_pay_basis_id
                                          ,lv_period_type
                                          ,lv_pay_basis
                                          ,p_assignment_id
                                          ,p_date_earned);

     if lv_frequency is not null then
        lv_frequency_desc := get_frequency(lv_frequency
                                          ,p_curr_eff_date);
     end if;

     if ln_grade_id is not null then
        lv_grade := get_grade(ln_grade_id
                             ,p_curr_eff_date);
     end if;

     if lv_bargaining_unit_code is not null then
        lv_bargaining_unit := get_bargaining_unit(lv_bargaining_unit_code
                                                 ,p_curr_eff_date);
     end if;

     if ln_collective_agreement_id is not null then
        lv_collective_agreement := get_collective_agreement(
                                          ln_collective_agreement_id
                                         ,p_curr_eff_date
                                         );
     end if;

     if ln_contract_id is not null then
        lv_contract := get_contract(ln_contract_id
                                   ,p_curr_eff_date) ;
     end if;

     if lv_hourly_salaried_code is not null then
        lv_hourly_salaried_desc := get_hourly_salaried_code(
                                              lv_hourly_salaried_code
                                             ,p_curr_eff_date) ;
     end if;

     /*bug:9549403:Added parameter ln_business_group_id to get_shift function call
       to use it in get_shift function to find legislation_code*/
     if ln_soft_coding_keyflex_id is not null then
        lv_shift_desc := get_shift( ln_soft_coding_keyflex_id
                                   ,p_curr_eff_date,ln_business_group_id) ;
     end if;

     open er_phone_number(ln_organization_id);
     fetch er_phone_number into lv_er_phone_number;
     close er_phone_number;

     if ln_special_ceiling_step_id is not null then
        open c_step(ln_special_ceiling_step_id, p_curr_eff_date);
        fetch c_step into lv_step;
        close c_step;
     end if;

     ln_index := pay_emp_action_arch.lrr_act_tab.count;

     hr_utility.trace('ln_index in get_personal_information proc is '
                || pay_emp_action_arch.lrr_act_tab.count);

     pay_emp_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'EMPLOYEE DETAILS';
     pay_emp_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := '00-000-0000';
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info1
               := lv_full_name;
     hr_utility.trace('lv_full_name is'||lv_full_name);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info2
               := ln_organization_id;
     hr_utility.trace('ln_organization_id is'||ln_organization_id);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info4
               := lv_national_identifier ;

     hr_utility.trace('lv_national_identifier is'||lv_national_identifier);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info5 := lv_pay_basis;

     hr_utility.trace('lv_pay_basis is'||lv_pay_basis);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info6
               := lv_frequency_desc;

     hr_utility.trace('lv_frequency_desc is'||lv_frequency_desc);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info7
               := lv_grade;

     hr_utility.trace('lv_grade is'||lv_grade);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info8
               := lv_bargaining_unit;

     hr_utility.trace('lv_bargaining_unit is'||lv_bargaining_unit);
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info9
               := lv_collective_agreement;

     hr_utility.trace('lv_collective_agreement is'||lv_collective_agreement);
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info10
               := lv_employee_number ;

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info11
               := fnd_date.date_to_canonical(ld_date_start);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info12
               := fnd_date.date_to_canonical(ld_original_date_of_hire);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info13
               := fnd_date.date_to_canonical(ld_adjusted_svc_date);

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info14
               := lv_assignment_number;

     pay_emp_action_arch.lrr_act_tab(ln_index).act_info15
               := lv_organization_name;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info16
               := p_time_period_id;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info17
               := lv_job_name ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info18
               := lv_gre_name;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info19
               := lv_position_name;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info20
               := lv_contract;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info21
               := lv_time_normal_start ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info22
               := lv_time_normal_finish;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info23
               := lv_pay_calc_method;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info24
               := lv_shift_desc;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info25
               := lv_er_phone_number;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info26
               := lv_hourly_salaried_desc;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info27
               := lv_step ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info28
               := fnd_number.number_to_canonical(ln_proposed_salary) ; /* Bug 3311866*/
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info29
               := fnd_number.number_to_canonical(ln_pay_annualization_factor) ;
     pay_emp_action_arch.lrr_act_tab(ln_index).act_info30
               := lv_location_code ;

     close c_employee_details;

     get_employee_accruals(p_assactid       => p_assactid
                          ,p_run_action_id  => p_run_action_id
                          ,p_assignment_id  => p_assignment_id
                          ,p_effective_date => p_curr_pymt_eff_date
                          ,p_date_earned    => p_date_earned);

     get_net_pay_distribution(p_pre_pay_action_id    => p_curr_pymt_ass_act_id
                             ,p_assignment_id        => p_assignment_id
                             ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                             ,p_ppp_source_action_id => p_ppp_source_action_id
                             );

     get_3rdparty_pay_distribution(p_pre_pay_action_id    => p_curr_pymt_ass_act_id
                                  ,p_assignment_id        => p_assignment_id
                                  ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                                  ,p_ppp_source_action_id => p_ppp_source_action_id
                                  ,p_payroll_id           => ln_payroll_id
                            );

     get_employee_other_info(p_run_action_id       => p_curr_pymt_ass_act_id
                           ,p_assignment_id        => p_assignment_id
                           ,p_organization_id      => ln_organization_id
                           ,p_business_group_id    => ln_business_group_id
                           ,p_curr_pymt_eff_date   => p_date_earned
                           ,p_tax_unit_id          => p_tax_unit_id
                           ,p_ppp_source_action_id => p_ppp_source_action_id
                           ,p_ytd_balcall_aaid     => p_ytd_balcall_aaid
                           ) ;

     get_employee_addr (ln_person_id
                       ,p_curr_eff_date);


     if pay_emp_action_arch.lrr_act_tab.count > 0 then
        insert_rows_thro_api_process(
                  p_action_context_id  => p_assactid
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => p_assignment_id
                 ,p_tax_unit_id        => p_tax_unit_id
                 ,p_curr_pymt_eff_date => p_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_emp_action_arch.lrr_act_tab
                 );
     end if;

  END get_personal_information;

BEGIN
  gv_package := 'pay_emp_action_arch';

EXCEPTION
   when others then
    hr_utility.trace('Error in ' || gv_package ||
                      to_char(sqlcode) || '-' || sqlerrm);
    raise hr_utility.hr_error;

END pay_emp_action_arch;

/
