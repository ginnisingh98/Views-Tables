--------------------------------------------------------
--  DDL for Package Body PAY_US_FLS_REPORTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_FLS_REPORTING_PKG" AS
/* $Header: pyusflsp.pkb 120.7.12010000.3 2010/04/28 07:27:46 svannian ship $ */
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

    Name        : pay_us_fls_reporting_pkg

    Description : Generate FLS periodic magnetic reports according to
                  FLS requirements.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    28-JAN-2010 svannian 115.28  9603852  Invalid number error resolved.
    12-JAN-2010 nkjaladi 115.27  9164356  Made changes to functions get_tax_exists,
                                          get_fls_jd_values and
                                          get_fls_tax_type_values to display SDI1
                                          tax values
    17-JUL-2006 ahanda   115.26  5368410  Multiplied ln_r_ee_tax_amt by -1 for EIC
    27-JAN-2006 asasthan 115.25  4969824  Removed unwanted text(typos)
    27-JAN-2006 ahanda   115.24  4969824  added order by to the
                                          range cursor
    20-JAN-2006 asasthan 115.23  4969824  Changed order of table
    20-JAN-2006 asasthan 115.22  4969824  Range cursor passes start_person
                                          end_person instead of start_asg
    20-JUL-2005 ahanda   115.21  4500097  Added Ordered hint for subquery
    08-JUL-2005 pragupta 115.20  4335410  Changed function -
                                          get_fls_tax_type_values
    14-MAR-2005 sackumar 115.19  4222032  Change Range Cursor to remove
                                          redundant use of bind Variable
                                          :payroll_action_id
    29-DEC-2004 ahanda   115.18  4092186  Changed function get_tax_exists
                                          to return N for MA - SDI
    02-SEP-2004 meshah   115.17           Fixed gscc error
    18-AUG-2004 ahanda   115.16  3832605  Added new function
                                          get_jurisdiction_name
    18-FEB-2004 ssmukher 115.14	 3343962  Performance Changes to cursor
                                          c_action_info
    19-FEB-2002 ahanda   115.13  2232320  Changed check_tax_unit_fein
    06-FEB-2002 ahanda   115.12           Changed get_fls_jd_values to assign
                                          each column values in PL/SQL table
                                          instead of assgining the table.
                                          (Workaround for bug 1822467)
    15-AUG-2001 ahanda   115.11           Changed cursor c_action_info
                                          in function get_fls_jd_values
                                          for performance reasons.
    20-JUN-2001 ahanda   115.10           Added check for category in
                                          cursor check_tax_unit_fein.
                                 1849359  Added to_number in select from
                                          pay_action_information to
                                          work around bug 1822467
    22-APR-2001 ahanda   115.9            Changed range code to error out
                                          if FEIN is not 9 chars.
    17-APR-2001 ahanda   115.8            Getting value if SS EE Withhled
                                          from action_information8 instead
                                          of action_information9.
    15-APR-2001 ahanda   115.7            Changed apps.package name to
                                          package name.
    13-APR-2001 ahanda   115.6            Modified functions
                                           - get_tax_exists
                                             to return N for FUTA EE
                                           - get_fls_tax_type_values
                                             to return formated
                                             +ve and - ve values.
    27-MAR-2001 ahanda   115.5            Modified functions
                                           - get_tax_exists
                                           - get_fls_agency_code
                                           - get_fls_tax_type_values
                                          Changed the above function as
                                          agency code is now dependent
                                          on Tax Types.
                                          Also fixed bug 1680396.
    12-MAR-2001 asasthan 115.4            Modified functions:
                                           - get_fls_agency_code
                                           - get_fls_tax_type_values.
    02-MAR-2001 asasthan 115.3            Changed the function to get
                                          the agency code from
                                          sta_information9 of
                                          'State tax limit rate info'
                                          record.
    22-FEB-2001 ahanda   115.3            Changes get_fls_tax_type_values
    20-FEB-2001 ahanda   115.2            Removed comment in range
    19-FEB-2001 ahanda   115.1            Removed comment in range
                                          and action creation.
    28-JAN-2001 ahanda   115.0            Created.

  *******************************************************************/

  /******************************************************************
  ** Package Local Variables
  ******************************************************************/
  gv_package varchar2(50) := 'pay_us_fls_reporting_pkg';


  /*******************************************************************
  ** Procedure to return the values for the Payroll Action of
  ** the Periodic Tax Filing Interface.
  ** This is used in Range Code and Action Creation.
  *******************************************************************/
  PROCEDURE get_payroll_action_info (
       p_payroll_action_id     in number,
       -- Bug 3343962  Performance changes
       p_start_date           out nocopy  date,
       p_end_date             out nocopy date,
       p_report_qualifier     out nocopy varchar2,
       p_report_type          out nocopy varchar2,
       p_report_category      out nocopy varchar2,
       p_business_group_id    out nocopy number,
       p_tax_unit_id          out nocopy number,
       p_payroll_id           out nocopy varchar2,
       p_consolidation_set_id out nocopy number)
  IS

    cursor c_payroll_action(cp_payroll_action_id in number) is
      select ppa.start_date
            ,ppa.effective_date
            ,ppa.business_group_id
            ,ppa.report_qualifier
            ,ppa.report_type
            ,ppa.report_category
            ,ppa.legislative_parameters
       from pay_payroll_actions ppa
      where payroll_action_id = cp_payroll_action_id;

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);
    lv_leg_parameter        VARCHAR2(300);

    ln_tax_unit_id          NUMBER;
    ln_payroll_id           NUMBER;
    ln_consolidation_set_id NUMBER;

  BEGIN
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 10);

    open c_payroll_action(p_payroll_action_id);
    fetch c_payroll_action into
            ld_start_date, ld_end_date, ln_business_group_id,
            lv_report_qualifier, lv_report_type,
            lv_report_category, lv_leg_parameter;
    if c_payroll_action%notfound then
       hr_utility.set_location( gv_package || '.get_payroll_action_info',20);
       hr_utility.raise_error;
    end if;
    close c_payroll_action;
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 30);

    ln_payroll_id           := to_number(rtrim(Pay_Mag_Utils.get_parameter(
                                              'TRANSFER_PAYROLL_ID'
                                             ,'TRANSFER_CONSOLIDATION_SET_ID'
                                             ,lv_leg_parameter)));
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 40);
    ln_consolidation_set_id := to_number(rtrim(Pay_Mag_Utils.get_parameter(
                                              'TRANSFER_CONSOLIDATION_SET_ID'
                                             ,'TRANSFER_TAX_UNIT_ID'
                                             ,lv_leg_parameter)));
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 50);
    ln_tax_unit_id          := to_number(rtrim(Pay_Mag_Utils.get_parameter(
                                              'TRANSFER_TAX_UNIT_ID'
                                             ,null
                                             ,lv_leg_parameter)));

    hr_utility.set_location(gv_package || '.get_payroll_action_info', 60);
    p_start_date           := ld_start_date;
    p_end_date             := ld_end_date;
    p_report_qualifier     := lv_report_qualifier;
    p_report_type          := lv_report_type;
    p_report_category      := lv_report_category;
    p_business_group_id    := ln_business_group_id;
    p_tax_unit_id          := ln_tax_unit_id;
    p_payroll_id           := ln_payroll_id;
    p_consolidation_set_id := ln_consolidation_set_id;

    hr_utility.set_location(gv_package || '.get_payroll_action_info', 100);

  END get_payroll_action_info;

  /*******************************************************************
  ** Procedure to return the values for the Payroll Action of
  ** the Periodic Tax Filing Interface.
  ** This is used in Range Code and Action Creation.
  *******************************************************************/
  FUNCTION check_tax_unit_fein ( p_tax_unit_id       in number
                                ,p_payroll_action_id in number
                                ,p_tax_unit_fein     in varchar2 default null)
  RETURN NUMBER IS

   cursor c_get_fein (cp_tax_unit_id in number) is
    select replace( replace(replace(hoi.org_information1,'-'),'/'),' ')
      from hr_organization_information hoi
     where hoi.organization_id = cp_tax_unit_id
       and hoi.org_information_context = 'Employer Identification';

   cursor c_get_gre_name (cp_tax_unit_id in number) is
    select hou.name
      from hr_all_organization_units hou
     where hou.organization_id = cp_tax_unit_id;

   lv_tax_unit_fein  VARCHAR2(20);
   lv_gre_name       VARCHAR2(80);
   ln_error_count    NUMBER := 0;

  BEGIN

   lv_tax_unit_fein := p_tax_unit_fein;

   if p_tax_unit_fein is null then
      open c_get_fein(p_tax_unit_id);
      fetch c_get_fein into lv_tax_unit_fein;
      close c_get_fein;
   end if;

   if length(lv_tax_unit_fein) <> 9 then
      ln_error_count := 1;
      open c_get_gre_name(p_tax_unit_id);
      fetch c_get_gre_name into lv_gre_name;
      close c_get_gre_name;

      insert  into pay_message_lines
      (line_sequence, payroll_id, message_level,
       source_id, source_type, line_text) values
      (pay_message_lines_s.nextval, NULL, 'F',
       p_payroll_action_id, 'P',
       'FEIN is not 9 charcters for GRE: ' || lv_gre_name);
   end if;

   return (ln_error_count);

  END check_tax_unit_fein;


  /********************************************************
  ** Range Code: Multi Threading
  ********************************************************/
  PROCEDURE range_cursor ( p_payroll_action_id  in number
                          ,p_sql_string  out nocopy  varchar2) -- Bug 3343962
  IS

    cursor c_arch_tax_unit ( cp_business_group_id in number
                            ,cp_start_date        in date
                            ,cp_end_date          in date
                            ) is
      select organization_id,
             replace( replace(replace(hoi.org_information1,'-'),'/'),' ')
        from hr_organization_information hoi
       where org_information_context = 'Employer Identification'
         and exists (select 'x'
                       from pay_assignment_actions paa,
                            pay_payroll_actions ppa
                      where ppa.payroll_action_id = paa.payroll_action_id
                        and ppa.business_group_id  = cp_business_group_id
                        and ppa.effective_date between cp_start_date
                                                   and cp_end_date
                        and ppa.action_type = 'X'
                        and ppa.report_type = 'XFR_INTERFACE'
                        and ppa.action_status = 'C'
                        and paa.action_status = 'C'
                        and paa.tax_unit_id = hoi.organization_id
                     );

    lv_error_message        VARCHAR2(1000);
    ln_error_count          NUMBER := 0;
    ln_arch_tax_unit_id     NUMBER;
    lv_arch_tax_unit_fein   VARCHAR2(80);

    lv_sql_string  varchar2(10000);

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);

    ln_tax_unit_id          NUMBER;
    ln_payroll_id           NUMBER;
    ln_consolidation_set_id NUMBER;

  BEGIN
    hr_utility.set_location(gv_package || '.range_code', 10);
    get_payroll_action_info (
             p_payroll_action_id
            ,ld_start_date
            ,ld_end_date
            ,lv_report_qualifier
            ,lv_report_type
            ,lv_report_category
            ,ln_business_group_id
            ,ln_tax_unit_id
            ,ln_payroll_id
            ,ln_consolidation_set_id);

    hr_utility.trace('ld_start_date = '        || ld_start_date);
    hr_utility.trace('ld_end_date = '          || ld_end_date);
    hr_utility.trace('ln_business_group_id = ' || ln_business_group_id);
    hr_utility.trace('ln_tax_unit_id = '       || ln_tax_unit_id);
    hr_utility.trace('ln_payroll_id = '        || ln_payroll_id);
    hr_utility.trace('lv_report_qualifier = '  || lv_report_qualifier);
    hr_utility.trace('lv_report_type = '       || lv_report_type);
    hr_utility.trace('lv_report_category = '   || lv_report_category);

    hr_utility.set_location(gv_package || '.range_code', 20);

    if ln_tax_unit_id is not null then
       hr_utility.set_location(gv_package || '.range_code', 30);
       ln_error_count := ln_error_count +
                         check_tax_unit_fein(
                                 p_tax_unit_id       => ln_tax_unit_id
                                ,p_payroll_action_id => p_payroll_action_id);
    else
       hr_utility.set_location(gv_package || '.range_code', 40);
       open c_arch_tax_unit( ln_business_group_id
                            ,ld_start_date
                            ,ld_end_date);
       loop
          fetch c_arch_tax_unit into ln_arch_tax_unit_id,
                                     lv_arch_tax_unit_fein;
          if c_arch_tax_unit%notfound then
             exit;
          end if;

          hr_utility.set_location(gv_package || '.range_code', 50);
          hr_utility.trace('ln_arch_tax_unit_id = ' || ln_arch_tax_unit_id);
          hr_utility.trace('lv_arch_tax_unit_fein = ' || lv_arch_tax_unit_fein);
          hr_utility.set_location(gv_package || '.range_code', 60);

          ln_error_count := ln_error_count +
                            check_tax_unit_fein(
                                    p_tax_unit_id       => ln_arch_tax_unit_id
                                   ,p_payroll_action_id => p_payroll_action_id
                                   ,p_tax_unit_fein     => lv_arch_tax_unit_fein);
       end loop;
       close c_arch_tax_unit;
       hr_utility.set_location(gv_package || '.range_code', 70);
    end if;

    hr_utility.trace('Error Count = ' || ln_error_count);
    if ln_error_count > 0 then
       lv_error_message := 'Please check the messages at the Payroll Action Level' ||
                           'to find out the GRE''s with invalid FEIN.';

       hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
       hr_utility.set_message_token('FORMULA_TEXT',lv_error_message);
       commit;
       hr_utility.raise_error;
    end if;

    hr_utility.set_location(gv_package || '.range_code', 60);

    lv_sql_string :=
        'select distinct paf.person_id
           from pay_payroll_actions ppa,
                pay_assignment_actions paa,
                per_assignments_f paf
         where ppa.business_group_id  = ' || ln_business_group_id || '
           and  ppa.effective_date
                 between to_date(''' || to_char(ld_start_date, 'dd/mm/yyyy')
                                     || ''',''dd/mm/yyyy'')
                     and to_date(''' || to_char(ld_end_date, 'dd/mm/yyyy')
                                     || ''',''dd/mm/yyyy'')
           and ppa.action_type = ''X''
           and ppa.report_type = ''XFR_INTERFACE''
           and ppa.action_status =''C''
           and ppa.payroll_action_id = paa.payroll_action_id
           and paa.action_status = ''C''
           and paa.tax_unit_id = nvl('''|| ln_tax_unit_id ||
                                     ''', paa.tax_unit_id)
           and paf.assignment_id = paa.assignment_id
           and ppa.effective_date between paf.effective_start_date
                                      and paf.effective_end_date
           and not exists
              (select /*+ ORDERED */
                      ''x''
                 from pay_action_interlocks pai,
                      pay_assignment_actions paa1,
                      pay_payroll_actions ppa1
                where pai.locked_action_id = paa.assignment_action_id
                  and paa1.assignment_action_id = pai.locking_action_id
                  and ppa1.payroll_action_id = paa1.payroll_action_id
                  and ppa1.action_type =''X''
                  and ppa1.report_type = ''FLS''
                  and ppa1.report_qualifier = ''PERIODIC''
                  and ppa1.report_category = ''RT'')
           and :payroll_action_id is not null
           and rtrim(pay_mag_utils.get_parameter(
                          ''TRANSFER_PAYROLL_ID''
                         ,''TRANSFER_CONSOLIDATION_SET_ID''
                         ,ppa.legislative_parameters)) =
                nvl('''||ln_payroll_id
                       ||''', rtrim(pay_mag_utils.get_parameter(
                                         ''TRANSFER_PAYROLL_ID''
                                        ,''TRANSFER_CONSOLIDATION_SET_ID''
                                        ,ppa.legislative_parameters)))
           and rtrim(pay_mag_utils.get_parameter(
                          ''TRANSFER_CONSOLIDATION_SET_ID''
                         ,null
                         ,ppa.legislative_parameters)) =
                nvl('''||ln_consolidation_set_id
                       ||''', rtrim(pay_mag_utils.get_parameter(
                                     ''TRANSFER_CONSOLIDATION_SET_ID''
                                    ,null
                                    ,ppa.legislative_parameters)))
         order by paf.person_id';

    p_sql_string := lv_sql_string;
    hr_utility.set_location(gv_package || '.range_code', 50);

  END range_cursor;

 /********************************************************
  ** Action Creation Code: Multi Threading
  ********************************************************/
  PROCEDURE action_creation( p_payroll_action_id in number
                            ,p_start_person      in number
                            ,p_end_person        in number
                            ,p_chunk             in number)

  IS

    cursor c_get_fls_emp( cp_tax_unit_id          in number
                         ,cp_payroll_id           in number
                         ,cp_consolidation_set_id in number
                         ,cp_business_group_id    in number
                         ,cp_start_date           in date
                         ,cp_end_date             in date
                         ,cp_start_person_id      in number
                         ,cp_end_person_id        in number
                        ) is
     select paa.assignment_id,
            ppa.effective_date,
            paa.tax_unit_id,
            paa.assignment_action_id
           from pay_payroll_actions ppa,
                pay_assignment_actions paa,
                per_assignments_f paf
         where ppa.business_group_id  = cp_business_group_id
           and ppa.effective_date between cp_start_date
                                      and cp_end_date
           and ppa.action_type = 'X'
           and ppa.report_type = 'XFR_INTERFACE'
           and ppa.action_status = 'C'
           and ppa.payroll_action_id = paa.payroll_action_id
           and paa.action_status = 'C'
           and paa.tax_unit_id = nvl(to_char(cp_tax_unit_id), paa.tax_unit_id)
           and paf.assignment_id = paa.assignment_id
           and paf.person_id between cp_start_person_id
                                 and cp_end_person_id
           and ppa.effective_date between paf.effective_start_date
                                      and paf.effective_end_date
           and not exists
              (select /*+ ORDERED */
                      'x'
                 from pay_action_interlocks pai,
                      pay_assignment_actions paa1,
                      pay_payroll_actions ppa1
                where pai.locked_action_id = paa.assignment_action_id
                  and paa1.assignment_action_id = pai.locking_action_id
                  and ppa1.payroll_action_id = paa1.payroll_action_id
                  and ppa1.action_type = 'X'
                  and ppa1.report_type = 'FLS'
                  and ppa1.report_qualifier = 'PERIODIC'
                  and ppa1.report_category = 'RT')
           and rtrim(pay_mag_utils.get_parameter(
                          'TRANSFER_PAYROLL_ID'
                         ,'TRANSFER_CONSOLIDATION_SET_ID'
                         ,ppa.legislative_parameters)) =
                nvl(to_char(cp_payroll_id),
                    rtrim(pay_mag_utils.get_parameter(
                                         'TRANSFER_PAYROLL_ID'
                                        ,'TRANSFER_CONSOLIDATION_SET_ID'
                                        ,ppa.legislative_parameters)))
           and rtrim(pay_mag_utils.get_parameter(
                          'TRANSFER_CONSOLIDATION_SET_ID'
                         ,null
                         ,ppa.legislative_parameters)) =
                nvl(to_char(cp_consolidation_set_id),
                    rtrim(pay_mag_utils.get_parameter(
                                         'TRANSFER_CONSOLIDATION_SET_ID'
                                        ,null
                                        ,ppa.legislative_parameters))) ;

    ld_start_date           DATE;
    ld_end_date             DATE;
    ln_business_group_id    NUMBER;
    lv_report_qualifier     VARCHAR2(30);
    lv_report_type          VARCHAR2(30);
    lv_report_category      VARCHAR2(30);
    ln_tax_unit_id          NUMBER;
    ln_payroll_id           NUMBER;
    ln_consolidation_set_id NUMBER;

    /* Assignment Record Local Variables */
    ln_assignment_id        NUMBER;
    ld_effective_date       DATE;
    ln_emp_tax_unit_id      NUMBER;
    ln_assignment_action_id NUMBER;

    ln_locking_action_id    NUMBER;

  BEGIN
    hr_utility.set_location(gv_package || '.action_creation', 10);
    get_payroll_action_info (
             p_payroll_action_id
            ,ld_start_date
            ,ld_end_date
            ,lv_report_qualifier
            ,lv_report_type
            ,lv_report_category
            ,ln_business_group_id
            ,ln_tax_unit_id
            ,ln_payroll_id
            ,ln_consolidation_set_id);

    hr_utility.set_location(gv_package || '.action_creation', 20);
    open c_get_fls_emp( ln_tax_unit_id
                       ,ln_payroll_id
                       ,ln_consolidation_set_id
                       ,ln_business_group_id
                       ,ld_start_date
                       ,ld_end_date
                       ,p_start_person
                       ,p_end_person);
    loop
      hr_utility.set_location(gv_package || '.action_creation', 30);
      fetch c_get_fls_emp into ln_assignment_id, ld_effective_date,
                               ln_emp_tax_unit_id, ln_assignment_action_id;
      if c_get_fls_emp%notfound then
         hr_utility.set_location(gv_package || '.action_creation', 40);
         exit;
      end if;

      hr_utility.set_location(gv_package || '.action_creation', 50);
      select pay_assignment_actions_s.nextval
        into ln_locking_action_id
        from dual;

      -- insert into pay_assignment_actions.
      hr_nonrun_asact.insact(ln_locking_action_id, ln_assignment_id,
                             p_payroll_action_id, p_chunk, ln_emp_tax_unit_id);
      hr_utility.set_location(gv_package || '.action_creation', 60);

      -- insert an interlock to this action
      hr_nonrun_asact.insint(ln_locking_action_id, ln_assignment_action_id);

      update pay_assignment_actions paa
         set paa.serial_number = ln_assignment_action_id
       where paa.assignment_action_id = ln_locking_action_id;

      hr_utility.set_location(gv_package || '.action_creation', 60);
    end loop;
    close c_get_fls_emp;

    hr_utility.set_location(gv_package || '.action_creation', 60);
  END action_creation;


  /*******************************************************************
  ** Function called from the Fast Formula.
  ** More detail in Header File.
  *******************************************************************/
  FUNCTION get_fls_org_information(
                           p_tax_unit_id       in number
                          ,p_payroll_action_id in number
                          ,p_effective_date    in varchar2
                          )
  RETURN VARCHAR2
  IS
   lv_org4_short_name  VARCHAR2(15);
   lv_org5_short_name  VARCHAR2(15);
  BEGIN
   lv_org4_short_name := rpad('002', 15, ' ');
   lv_org5_short_name := rpad('Unit1', 15, ' ');

   return(lv_org4_short_name || lv_org5_short_name);

  END get_fls_org_information;


  /*******************************************************************
  ** Function called from the Fast Formula.
  ** More detail in Header File.
  *******************************************************************/
  FUNCTION get_tax_exists( p_jurisdiction_code in varchar2
                          ,p_effective_date    in varchar2
                          ,p_tax_type          in varchar2
                          ,p_tax_type_resp     in varchar2 default NULL
                          )
  RETURN VARCHAR2
  IS
   cursor c_state_tax_exists( cp_jurisdiction_code in varchar2
                             ,cp_effective_date    in date) is
     select pust.sit_exists,
            decode(pust.sdi_ee_wage_limit, null, 'N', 'Y'),
            decode(pust.sdi_er_wage_limit, null, 'N', 'Y'),
            decode(pust.sui_ee_wage_limit, null, 'N', 'Y'),
            decode(pust.sui_er_wage_limit, null, 'N', 'Y')
       from pay_us_state_tax_info_f pust
      where cp_effective_date between pust.effective_start_date
                                  and pust.effective_end_date
        and pust.state_code = substr(cp_jurisdiction_code, 1,2)
        and pust.sta_information_category = 'State tax limit rate info';

/* 9164356 start*/
   cursor c_sdi1_state_tax_exists( cp_jurisdiction_code in varchar2
                                  ,cp_effective_date    in date) is
     select 'Y'
       from pay_us_state_tax_info_f pust
      where cp_effective_date between pust.effective_start_date
                                  and pust.effective_end_date
        and pust.state_code = substr(cp_jurisdiction_code, 1,2)
        and pust.sta_information20 IS NOT NULL
        and pust.sta_information_category = 'State tax limit rate info';
/* 9164356 end*/

   cursor c_county_tax_exists( cp_jurisdiction_code in varchar2
                              ,cp_effective_date    in date) is
     select puct.county_tax, puct.head_tax, puct.school_tax
       from pay_us_county_tax_info_f puct
      where cp_effective_date between puct.effective_start_date
                                  and puct.effective_end_date
        and puct.jurisdiction_code = cp_jurisdiction_code;

   cursor c_city_tax_exists( cp_jurisdiction_code in varchar2
                            ,cp_effective_date    in date) is
     select city_tax, head_tax, school_tax
       from pay_us_city_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and jurisdiction_code = cp_jurisdiction_code;

    ld_effective_date       DATE;

    lv_it_exists            VARCHAR2(1) := 'N';
    lv_sdi_ee_exists        VARCHAR2(1) := 'N';
    lv_sdi_er_exists        VARCHAR2(1) := 'N';
    lv_sdi1_ee_exists       VARCHAR2(1) := 'N'; -- #9164356
    lv_sui_ee_exists        VARCHAR2(1) := 'N';
    lv_sui_er_exists        VARCHAR2(1) := 'N';
    lv_head_tax_exists      VARCHAR2(1) := 'N';
    lv_school_tax_exists    VARCHAR2(1) := 'N';

    lv_return               VARCHAR2(1) := 'N';

  BEGIN

     hr_utility.set_location(gv_package || '.get_tax_exists', 10);
     hr_utility.trace('Effective Date = ' || p_effective_date);
     hr_utility.trace('Tax Type = ' || p_tax_type);
     hr_utility.trace('JD = ' || p_jurisdiction_code);

     ld_effective_date := to_date(p_effective_date, 'MM/DD/YYYY');
     hr_utility.set_location(gv_package || '.get_tax_exists', 20);

     /* If p_tax_type_resp is null, the function is called from
        Wages Cursor so check if there is EE or ER taxes.
        If p_tax_type_resp is not null, the function is called
        from Taxes cursor so check if tax exists for the passed
        EE or ER value
     */

     -- Federal
     if p_jurisdiction_code = '00-000-0000' then
        hr_utility.set_location(gv_package || '.get_tax_exists', 30);
        if p_tax_type = 'UI' and nvl(p_tax_type_resp, 'ER') = 'ER' then
           lv_return := 'Y';
        elsif p_tax_type in ('EIC', 'HI', 'IT', 'OASDI') then
           lv_return := 'Y';
        end if;
     -- State
     elsif length(p_jurisdiction_code) = 11 and
           substr(p_jurisdiction_code,3) = '-000-0000' then
        hr_utility.set_location(gv_package || '.get_tax_exists', 40);
        -- MA has Health Insurance report under SDI so if SDI
        -- is passed return N and Y for HI
        if p_jurisdiction_code = '22-000-0000' and
           p_tax_type = 'HI' and p_tax_type_resp is null then
           lv_return := 'Y';
        elsif p_jurisdiction_code = '22-000-0000' and
              p_tax_type = 'SDI' and p_tax_type_resp is null then
           lv_return := 'N';
        elsif ((p_tax_type not in ('SDI1','OASDI', 'HI', 'EIC', 'OPT')) or --Added SDI1 #9164356
               (p_jurisdiction_code = '22-000-0000' and
                p_tax_type = 'HI' and
                p_tax_type_resp is not null)) then
           open c_state_tax_exists(p_jurisdiction_code, ld_effective_date);
           fetch c_state_tax_exists into lv_it_exists
                                        ,lv_sdi_ee_exists
                                        ,lv_sdi_er_exists
                                        ,lv_sui_ee_exists
                                        ,lv_sui_er_exists;
           close c_state_tax_exists;
/* 9164356 start */
        elsif p_tax_type = 'SDI1'  then
           hr_utility.set_location(gv_package || '.get_tax_exists  ', 42);
           open c_sdi1_state_tax_exists(p_jurisdiction_code, ld_effective_date);
           fetch c_sdi1_state_tax_exists into lv_sdi1_ee_exists;
           if  c_sdi1_state_tax_exists%notfound then
             lv_sdi1_ee_exists := 'N';
             hr_utility.set_location(gv_package || '.get_tax_exists', 44);
           end if;
           hr_utility.set_location(gv_package || '.get_tax_exists | SDI1 flag:'|| lv_sdi1_ee_exists, 46);
           close c_sdi1_state_tax_exists;
/* 9164356 end */
        end if;
   -- County
     elsif substr(p_jurisdiction_code,7,5) = '-0000' and
           substr(p_jurisdiction_code,3,4) <> '-000' then

        hr_utility.set_location(gv_package || '.get_tax_exists', 50);
        if p_tax_type in ('OPT', 'IT') then
           open c_county_tax_exists(p_jurisdiction_code, ld_effective_date);
           fetch c_county_tax_exists into lv_it_exists
                                         ,lv_head_tax_exists
                                         ,lv_school_tax_exists;
           close c_county_tax_exists;
        end if;
     -- City
     elsif length(p_jurisdiction_code) = 11 and
           substr(p_jurisdiction_code,3) <> '-000-0000' then

        hr_utility.set_location(gv_package || '.get_tax_exists', 60);
        if p_tax_type in ('OPT', 'IT') then
           open c_city_tax_exists(p_jurisdiction_code, ld_effective_date);
           fetch c_city_tax_exists into lv_it_exists
                                       ,lv_head_tax_exists
                                       ,lv_school_tax_exists;
           close c_city_tax_exists;
        end if;
     end if;

     if length(p_jurisdiction_code) = 8 and
        p_tax_type in ('IT') then
        hr_utility.set_location(gv_package || '.get_tax_exists', 70);
        lv_return := 'Y';
     elsif p_jurisdiction_code <> '00-000-0000' then
        hr_utility.set_location(gv_package || '.get_tax_exists', 80);
        if p_tax_type = 'IT' then
           lv_return := lv_it_exists;
        elsif ((p_tax_type = 'SDI') or
               (p_jurisdiction_code = '22-000-0000' and
                p_tax_type = 'HI')) then
           if p_tax_type_resp is null then
              if lv_sdi_ee_exists = 'Y' or lv_sdi_er_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           elsif p_tax_type_resp = 'EE' then
              if lv_sdi_ee_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           elsif p_tax_type_resp = 'ER' then
              if lv_sdi_er_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           end if;
        elsif p_tax_type in ('UI', 'HI') then
           if p_tax_type_resp is null then
              if lv_sui_ee_exists = 'Y' or lv_sui_er_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           elsif p_tax_type_resp = 'EE' then
              if lv_sui_ee_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           elsif p_tax_type_resp = 'ER' then
              if lv_sui_er_exists = 'Y' then
                 lv_return := 'Y';
              end if;
           end if;
        elsif p_tax_type = 'OPT' then
           lv_return := lv_head_tax_exists;
/*9164356 start*/
        elsif (p_tax_type = 'SDI1') then
              hr_utility.set_location(gv_package || '.get_tax_exists', 82);
              if (p_tax_type_resp is null or (p_tax_type_resp = 'EE')) then
                if lv_sdi1_ee_exists = 'Y' then
                  hr_utility.set_location(gv_package || '.get_tax_exists', 84);
                  lv_return := 'Y';
                end if;
              end if;
/*9164356 end*/
        end if;
     end if;

     hr_utility.set_location(gv_package || '.get_tax_exists', 90);
     hr_utility.trace('Returned Value = ' || lv_return);
     hr_utility.set_location(gv_package || '.get_tax_exists', 100);

     return(lv_return);

  END get_tax_exists;


  /*******************************************************************
  ** Function called from the Fast Formula.
  ** Returns the Jurisdiction Name.
  *******************************************************************/
  FUNCTION get_jurisdiction_name(p_jurisdiction_code     in varchar2
                                ,p_resident_jurisdiction in varchar2
                                )
  RETURN VARCHAR2
  IS

    lv_jurisdiction_name VARCHAR2(200);

  BEGIN

    hr_utility.set_location(gv_package || '.get_jurisdiction_name', 10);
    hr_utility.trace('JD =' || p_jurisdiction_code);

    if p_jurisdiction_code = '00-000-0000' then
       lv_jurisdiction_name := 'Federal';
    else
       -- if the JD passed is for County, City or School Dst
       -- get the state abbrev and then use add it before the City Name
       if substr(p_jurisdiction_code,4,3) <> '000' then
          lv_jurisdiction_name
             := pay_us_employee_payslip_web.get_jurisdiction_name(
                    substr(p_jurisdiction_code,1,2)||'-000-0000') || '-';
       end if;

       lv_jurisdiction_name
          := lv_jurisdiction_name ||
             pay_us_employee_payslip_web.get_jurisdiction_name(
                  p_jurisdiction_code);
    end if;

    if p_resident_jurisdiction is not null then
       lv_jurisdiction_name
          := lv_jurisdiction_name || '/' ||
             pay_us_employee_payslip_web.get_jurisdiction_name(
                 p_jurisdiction_code);
    end if;

    return(lv_jurisdiction_name);

  END get_jurisdiction_name;


  /*******************************************************************
  ** Function called from the Fast Formula.
  ** More detail in Header File.
  *******************************************************************/
  FUNCTION get_fls_agency_code( p_jurisdiction_code     in varchar2
                               ,p_effective_date        in varchar2
                               ,p_resident_jurisdiction in varchar2
                               ,p_tax_type_code         in varchar2
                               )
  RETURN VARCHAR2
  IS

   cursor c_federal_agency_code( cp_effective_date in date) is
     select puft.fed_information1,
            nvl(puft.fed_information2, puft.fed_information1)
       from pay_us_federal_tax_info_f puft
      where cp_effective_date between puft.effective_start_date
                                  and puft.effective_end_date
        and puft.fed_information_category = 'FLS Interface Mapping';

   cursor c_state_agency_code( cp_jurisdiction_code in varchar2
                              ,cp_effective_date    in date) is
     select pust.sta_information9
       from pay_us_state_tax_info_f pust
      where cp_effective_date between pust.effective_start_date
                                  and pust.effective_end_date
        and pust.state_code = substr(cp_jurisdiction_code, 1,2)
        and pust.sta_information_category = 'State tax limit rate info';


   /*******************************************************************
   ** Cursor returns a not found if agency code is not defined.
   *******************************************************************/
   cursor c_county_agency_code( cp_jurisdiction_code in varchar2
                               ,cp_effective_date    in date) is
     select puct.cnty_attribute1,
            nvl(puct.cnty_attribute2, puct.cnty_attribute1)
       from pay_us_county_tax_info_f puct
      where cp_effective_date between puct.effective_start_date
                                  and puct.effective_end_date
        and puct.jurisdiction_code = cp_jurisdiction_code
        and (puct.cnty_attribute1 is not null or
             puct.cnty_attribute2 is not null);

   /*******************************************************************
   ** Cursor returns a not found if agency code is not defined.
   *******************************************************************/
   cursor c_city_agency_code( cp_jurisdiction_code in varchar2
                             ,cp_effective_date    in date) is
     select city_attribute1,
            nvl(city_attribute2, city_attribute1)
       from pay_us_city_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and jurisdiction_code = cp_jurisdiction_code
        and (city_attribute1 is not null or
             city_attribute2 is not null);

   /*******************************************************************
   ** Cursor returns a not found if agency code is not defined.
   *******************************************************************/
   cursor c_school_agency_code( cp_jurisdiction_code     in varchar2
                               ,cp_resident_jurisdiction in varchar2
                               ,cp_effective_date        in date
                              ) is
     select pusd.sch_information1
       from pay_us_school_dsts_tax_info_f pusd
      where cp_effective_date between pusd.effective_start_date
                                  and pusd.effective_end_date
        and pusd.state_code = substr(cp_jurisdiction_code, 1, 2)
        and pusd.school_dsts_code = substr(cp_jurisdiction_code, 4)
        and pusd.jurisdiction_code = cp_resident_jurisdiction
        and pusd.sch_information_category = 'FLS Interface Mapping'
        and pusd.sch_information1 is not null;

    lv_agency_code       VARCHAR2(30) := lpad(9, 17, 9);
    lv_futa_agency_code  VARCHAR2(30);
    lv_opt_agency_code   VARCHAR2(30);

    ld_effective_date  DATE;

  BEGIN

    hr_utility.set_location(gv_package || '.get_fls_agency_code', 10);
    hr_utility.trace('JD =' || p_jurisdiction_code);
    hr_utility.trace('Eff Date =' || p_effective_date);

    ld_effective_date := to_date(p_effective_date, 'mm/dd/yyyy');

    hr_utility.set_location(gv_package || '.get_fls_agency_code', 20);

    -- Federal
    if p_jurisdiction_code = '00-000-0000' then
       hr_utility.set_location(gv_package || '.get_fls_agency_code', 30);
       open c_federal_agency_code(ld_effective_date);
       fetch c_federal_agency_code into lv_agency_code,
                                        lv_futa_agency_code;
       close c_federal_agency_code;
       /* If Tax Type is UI get agency code from fed_information2 */
       if p_tax_type_code = 'UI' then
          lv_agency_code := lv_futa_agency_code;
       end if;

    -- State
    elsif substr(p_jurisdiction_code,3) = '-000-0000' then
       hr_utility.set_location(gv_package || '.get_fls_agency_code', 40);
       open c_state_agency_code(p_jurisdiction_code, ld_effective_date);
       fetch c_state_agency_code into lv_agency_code;
       close c_state_agency_code;
    -- County
    elsif substr(p_jurisdiction_code,7,5) = '-0000' and
          substr(p_jurisdiction_code,3,4) <> '-000' then
       hr_utility.set_location(gv_package || '.get_fls_agency_code', 50);
       open c_county_agency_code(p_jurisdiction_code, ld_effective_date);
       fetch c_county_agency_code into lv_agency_code,
                                       lv_opt_agency_code;
       close c_county_agency_code;

       /* If Tax Type is OPT get agency code from attribute2.
          If value of attribute2 is null get value of attribute1 as
          agency code is same.
       */
       if p_tax_type_code = 'OPT' then
          lv_agency_code := lv_opt_agency_code;
       end if;

    -- City
    elsif length(p_jurisdiction_code) = 11 and
          substr(p_jurisdiction_code,3) <> '-000-0000' then
       hr_utility.set_location(gv_package || '.get_fls_agency_code', 60);
       open c_city_agency_code(p_jurisdiction_code, ld_effective_date);
       fetch c_city_agency_code into lv_agency_code, lv_opt_agency_code;
       close c_city_agency_code;

       /* If Tax Type is OPT get agency code from attribute2.
          If value of attribute2 is null get value of attribute1 as
          agency code is same.
       */
       if p_tax_type_code = 'OPT' then
          lv_agency_code := lv_opt_agency_code;
       end if;

    -- School
    elsif length(p_jurisdiction_code) = 8 then
       hr_utility.set_location(gv_package || '.get_fls_agency_code', 70);
       open c_school_agency_code( p_jurisdiction_code
                                 ,p_resident_jurisdiction
                                 ,ld_effective_date);
       fetch c_school_agency_code into lv_agency_code;
       close c_school_agency_code;
    end if;
    hr_utility.set_location(gv_package || '.get_fls_agency_code', 100);

    return (lv_agency_code);

  END get_fls_agency_code;


  /*******************************************************************
  ** Function called from the Fast Formula.
  ** More detail in Header File.
  *******************************************************************/
  FUNCTION get_fls_jd_values( p_tax_unit_id       in number
                              ,p_payroll_action_id in number
                              )
  RETURN NUMBER
  IS
  -- Bug : 3343962 Performance Changes
  -- Bug : 9164356 Commented the old definition and added the new definition
   cursor c_action_info( cp_tax_unit_id       in number
                        ,cp_payroll_action_id in number) is
/*
    select jurisdiction_code
          ,nvl(sum(to_number(action_information1)),0) action_information1
          ,nvl(sum(to_number(action_information2)),0) action_information2
          ,nvl(sum(to_number(action_information3)),0) action_information3
          ,nvl(sum(to_number(action_information4)),0) action_information4
          ,nvl(sum(to_number(action_information5)),0) action_information5
          ,nvl(sum(to_number(action_information6)),0) action_information6
          ,nvl(sum(to_number(action_information7)),0) action_information7
          ,nvl(sum(to_number(action_information8)),0) action_information8
          ,nvl(sum(to_number(action_information9)),0) action_information9
          ,nvl(sum(to_number(action_information10)),0) action_information10
          ,nvl(sum(to_number(action_information11)),0) action_information11
          ,nvl(sum(to_number(action_information12)),0) action_information12
          ,nvl(sum(to_number(action_information13)),0) action_information13
          ,nvl(sum(to_number(action_information14)),0) action_information14
          ,nvl(sum(to_number(action_information15)),0) action_information15
          ,nvl(sum(to_number(action_information16)),0) action_information16
          ,nvl(sum(to_number(action_information17)),0) action_information17
          ,nvl(sum(to_number(action_information18)),0) action_information18
          ,nvl(sum(to_number(action_information19)),0) action_information19
          ,nvl(sum(to_number(action_information20)),0) action_information20
          ,nvl(sum(to_number(action_information21)),0) action_information21
          ,nvl(sum(to_number(action_information22)),0) action_information22
          ,nvl(sum(to_number(action_information23)),0) action_information23
          ,nvl(sum(to_number(action_information24)),0) action_information24
          ,nvl(sum(to_number(action_information25)),0) action_information25
          ,nvl(sum(to_number(action_information26)),0) action_information26
          ,nvl(sum(to_number(action_information27)),0) action_information27
          ,nvl(sum(to_number(action_information28)),0) action_information28
          ,nvl(sum(to_number(action_information29)),0) action_information29
          ,action_information30
     from pay_action_information pai,
          pay_assignment_actions paa,
          pay_payroll_actions  ppa -- Bug 3343962
    where pai.tax_unit_id = cp_tax_unit_id
      and paa.payroll_action_id = cp_payroll_action_id
      and ppa.payroll_action_id = cp_payroll_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and pai.action_context_id = paa.serial_number
      and pai.action_context_type = 'AAP'
      and pai.action_information_category in ('US FEDERAL',
                                              'US STATE',
                                              'US COUNTY',
                                              'US CITY',
                                              'US SCHOOL DISTRICT'
                                              )
     group by jurisdiction_code,
              action_information30;*/
/* Added for 9164356 start*/
     select jurisdiction_code
          ,nvl(sum(to_number(decode(pai.action_information_category,'US STATE2',0,action_information1))),0) action_information1
          ,nvl(sum(to_number(action_information2)),0) action_information2
          ,nvl(sum(to_number(action_information3)),0) action_information3
          ,nvl(sum(to_number(action_information4)),0) action_information4
          ,nvl(sum(to_number(action_information5)),0) action_information5
          ,nvl(sum(to_number(action_information6)),0) action_information6
          ,nvl(sum(to_number(action_information7)),0) action_information7
          ,nvl(sum(to_number(action_information8)),0) action_information8
          ,nvl(sum(to_number(action_information9)),0) action_information9
          ,nvl(sum(to_number(action_information10)),0) action_information10
          ,nvl(sum(to_number(action_information11)),0) action_information11
          ,nvl(sum(to_number(action_information12)),0) action_information12
          ,nvl(sum(to_number(action_information13)),0) action_information13
          ,nvl(sum(to_number(action_information14)),0) action_information14
          ,nvl(sum(to_number(action_information15)),0) action_information15
          ,nvl(sum(to_number(action_information16)),0) action_information16
          ,nvl(sum(to_number(action_information17)),0) action_information17
          ,nvl(sum(to_number(action_information18)),0) action_information18
          ,nvl(sum(to_number(action_information19)),0) action_information19
          ,nvl(sum(to_number(action_information20)),0) action_information20
          ,nvl(sum(to_number(action_information21)),0) action_information21
          ,nvl(sum(to_number(action_information22)),0) action_information22
          ,nvl(sum(to_number(action_information23)),0) action_information23
          ,nvl(sum(to_number(action_information24)),0) action_information24
          ,nvl(sum(to_number(action_information25)),0) action_information25
          ,nvl(sum(to_number(action_information26)),0) action_information26
          ,nvl(sum(to_number(action_information27)),0) action_information27
          ,nvl(sum(to_number(action_information28)),0) action_information28
          ,nvl(sum(to_number(action_information29)),0) action_information29
          ,decode(pai.action_information_category,'US STATE2','0',action_information30) action_information30 /* Bug # 9603852 */
          ,nvl(sum(to_number(decode(pai.action_information_category,'US STATE2',action_information1,0))),0) sdi1_ee
     from pay_action_information pai,
          pay_assignment_actions paa,
          pay_payroll_actions  ppa
    where pai.tax_unit_id = cp_tax_unit_id
      and paa.payroll_action_id = cp_payroll_action_id
      and ppa.payroll_action_id = cp_payroll_action_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and pai.action_context_id = paa.serial_number
      and pai.action_context_type = 'AAP'
      and pai.action_information_category in ('US FEDERAL',
                                              'US STATE',
                                              'US STATE2',
                                              'US COUNTY',
                                              'US CITY',
                                              'US SCHOOL DISTRICT'
                                              )
     group by jurisdiction_code,
              decode(pai.action_information_category,'US STATE2','0',action_information30);
/* Added for 9164356 end*/

   i_count  NUMBER := 0;

  BEGIN
   hr_utility.set_location(gv_package || '.get_fls_jd_values', 10);

   /* Reset the PL/SQL tables */
   if pay_us_fls_reporting_pkg.ltr_action_info.count > 0 then
      for i in pay_us_fls_reporting_pkg.ltr_action_info.first ..
               pay_us_fls_reporting_pkg.ltr_action_info.last loop
          pay_us_fls_reporting_pkg.ltr_action_info(i).jurisdiction_code := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information7 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information8 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information9 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information10 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information11 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information12 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information13 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information14 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information15 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information16 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information17 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information18 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information19 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information20 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information21 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information22 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information23 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information24 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information25 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information26 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information27 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information28 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information29 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30 := null;
          pay_us_fls_reporting_pkg.ltr_action_info(i).sdi1_ee := null; --9164356
      end loop;
      pay_us_fls_reporting_pkg.ltr_action_info.delete;
   end if;

   hr_utility.trace('Payroll Action ID=' || p_payroll_action_id);
   hr_utility.trace('Tax Unit ID=' || p_tax_unit_id);
   for action_rec in c_action_info(p_tax_unit_id, p_payroll_action_id)
   loop
     hr_utility.set_location(gv_package || '.get_fls_jd_values', 20);
     /* Commented out because of DB issue. Bug 1822467 */
     --pay_us_fls_reporting_pkg.ltr_action_info(i_count) := action_rec;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).jurisdiction_code
                         := action_rec.jurisdiction_code;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information1
                         := action_rec.action_information1;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information2
                         := action_rec.action_information2;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information3
                         := action_rec.action_information3;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information4
                         := action_rec.action_information4;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information5
                         := action_rec.action_information5;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information6
                         := action_rec.action_information6;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information7
                         := action_rec.action_information7;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information8
                         := action_rec.action_information8;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information9
                         := action_rec.action_information9;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information10
                         := action_rec.action_information10;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information11
                         := action_rec.action_information11;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information12
                         := action_rec.action_information12;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information13
                         := action_rec.action_information13;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information14
                         := action_rec.action_information14;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information15
                         := action_rec.action_information15;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information16
                         := action_rec.action_information16;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information17
                         := action_rec.action_information17;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information18
                         := action_rec.action_information18;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information19
                         := action_rec.action_information19;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information20
                         := action_rec.action_information20;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information21
                         := action_rec.action_information21;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information22
                         := action_rec.action_information22;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information23
                         := action_rec.action_information23;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information24
                         := action_rec.action_information24;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information25
                         := action_rec.action_information25;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information26
                         := action_rec.action_information26;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information27
                         := action_rec.action_information27;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information28
                         := action_rec.action_information28;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information29
                         := action_rec.action_information29;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).action_information30
                         := action_rec.action_information30;
     pay_us_fls_reporting_pkg.ltr_action_info(i_count).sdi1_ee
                         := action_rec.sdi1_ee;   --#9164356
     i_count := i_count + 1;
     hr_utility.set_location(gv_package || '.get_fls_jd_values', 30);
   end loop;

   hr_utility.set_location(gv_package || '.get_fls_jd_values', 40);
   if pay_us_fls_reporting_pkg.ltr_action_info.count > 0 then
      for i in pay_us_fls_reporting_pkg.ltr_action_info.first ..
               pay_us_fls_reporting_pkg.ltr_action_info.last loop
          hr_utility.trace('JD='||pay_us_fls_reporting_pkg.ltr_action_info(i).jurisdiction_code);
      end loop;
   end if;
   hr_utility.trace('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');

   hr_utility.set_location(gv_package || '.get_fls_jd_values', 100);
   return (1);
  END get_fls_jd_values;

  /*******************************************************************
  ** Function called from the Fast Formula.
  ** More detail in Header File.
  ** Function returns:
  **  - Gross_amt
  **  - Subject_amt
  **  - Taxable_amt
  **  - Resident EE Tax Amt
  **  - Resident ER Tax Amt
  **  - Non-Resident EE Tax Amt
  *******************************************************************/
  FUNCTION get_fls_tax_type_values(
                              p_tax_type              in varchar2
                             ,p_jurisdiction          in varchar2
                             ,p_resident_jurisdiction in varchar2
                              )
  RETURN VARCHAR2
  IS

    ln_gross_amt      NUMBER(12,2) := 0;
    ln_subject_amt    NUMBER(12,2) := 0;
    ln_amt1           NUMBER(12,2) := 0;
    ln_amt2           NUMBER(12,2) := 0;
    ln_amt3           NUMBER(12,2) := 0;
    ln_amt4           NUMBER(12,2) := 0;
    ln_amt5           NUMBER(12,2) := 0;
    ln_amt6           NUMBER(12,2) := 0;
    ln_amt7           NUMBER(12,2) := 0;
    ln_taxable_amt    NUMBER(12,2) := 0;
    ln_r_ee_tax_amt   NUMBER(12,2) := 0;
    ln_r_er_tax_amt   NUMBER(12,2) := 0;
    ln_nr_ee_tax_amt  NUMBER(12,2) := 0;
    ln_nr_er_tax_amt  NUMBER(12,2) := 0;

    ln_nr_flag     VARCHAR2(1) := 'N';
    ln_r_flag      VARCHAR2(1) := 'N';

    lv_return      VARCHAR2(200);

  BEGIN
   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 10);
   hr_utility.trace('Tax Type Code=' || p_tax_type);
   hr_utility.trace('Jurisdiction Code=' || p_jurisdiction);
   hr_utility.trace('PL/SQL Count=' || pay_us_fls_reporting_pkg.ltr_action_info.count);

   for i in pay_us_fls_reporting_pkg.ltr_action_info.first ..
            pay_us_fls_reporting_pkg.ltr_action_info.last loop

       hr_utility.trace('PL/SQL Jurisdiction Code=' ||
              pay_us_fls_reporting_pkg.ltr_action_info(i).jurisdiction_code);

       hr_utility.trace('PL/SQL Action30 is= ' ||
              pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30);

       hr_utility.trace('PL/SQL p_jurisdiction is= ' ||
              p_jurisdiction);

       hr_utility.trace('PL/SQL p_resident_jurisdiction is = ' ||
              nvl(p_resident_jurisdiction,'NOT ARCHIVED'));

       if pay_us_fls_reporting_pkg.ltr_action_info(i).jurisdiction_code = p_jurisdiction then

          hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 20);

          if p_jurisdiction = '00-000-0000' then
             hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 30);
              -- Regular Earnings
             ln_amt1 := ln_amt1 +
                        pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
             -- Gross Earnings
             ln_amt2 := ln_amt2 +
                        pay_us_fls_reporting_pkg.ltr_action_info(i).action_information23;
              -- Pre Tax Deduction
             ln_amt3 := ln_amt3 +
                         pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;

             if p_tax_type = 'IT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 40);
                -- Supp Earning for FIT
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- Supp Earning for NWFIT
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                -- Pre Tax Deduction for FIT
                ln_amt6 := ln_amt6 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                -- FIT Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;

             elsif p_tax_type = 'UI' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 50);
                -- Supp Earning for FUTA
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information19;
                -- Pre Tax Deduction for FUTA
                ln_amt6 := ln_amt6 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information20;
                -- Taxable
                ln_amt7 := ln_amt7 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information21;
                -- Liability
                ln_r_er_tax_amt := ln_r_er_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information22;

             elsif p_tax_type = 'OASDI' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 60);
                -- Supp Earning for SS
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information11;
                -- Pre Tax Deduction for SS
                ln_amt6 := ln_amt6 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information12;
                -- Taxable
                ln_amt7 := ln_amt7 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information7;
                -- SS EE Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information8;
                -- SS ER Liability
                ln_r_er_tax_amt := ln_r_er_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information9;
             elsif p_tax_type = 'HI' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 70);
                -- Supp Earning for Medicare
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information17;
                -- Pre Tax Deduction for Medicare
                ln_amt6 := ln_amt6 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information18;
                -- Medicare EE Taxable
                ln_amt7 := ln_amt7 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information13;
                -- Medicare Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information14;
                -- Medicare ER Liability
                ln_r_er_tax_amt := ln_r_er_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information15;
             elsif p_tax_type = 'EIC' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 80);
                ln_amt1 := 0;
                ln_amt2 := 0;
                ln_amt3 := 0;
                -- EIC Advance
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                (-1 * pay_us_fls_reporting_pkg.ltr_action_info(i).action_information26);

             end if;
             exit;
           -- State Jurisdiction code
           elsif substr(p_jurisdiction,3) = '-000-0000' and
                 p_jurisdiction <> '00-000-0000' then

             hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 110);

             if p_tax_type = 'IT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 120);
                --SIT Gross
                ln_amt2 := ln_amt2 +
                        pay_us_fls_reporting_pkg.ltr_action_info(i).action_information17;
                -- SIT Subj Whable
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                -- SIT Subj NWhable
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- SIT Pre Tax Redns
                ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                -- SIT Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;

             elsif p_tax_type = 'UI' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 130);
                /* Always report the ER component if it is there. -- 4335410
                   In case ER is null report EE.
                   SUI and SDI ER Liability is always passed as 0.
                   Doing an if to get EE or ER Wages instead on NVL as the PL/SQL table will
                   have a Zero value if there is a NULL in the table. */

                -- SUI EE Gross, SUI ER Gross
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information29,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 140);
                   ln_amt2 := ln_amt2 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information29;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 150);
                   ln_amt2 := ln_amt2 +
                             pay_us_fls_reporting_pkg.ltr_action_info(i).action_information28;
                end if;

                -- nvl(SUI EE Subj Whable, SUI ER Subj Whable)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information19,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 160);
                   ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information19;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 170);
                   ln_amt4 := ln_amt4 +
                             pay_us_fls_reporting_pkg.ltr_action_info(i).action_information15;
                end if;

                -- nvl(SUI EE Pre Tax Redns, SUI ER Pre Tax Redns)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information20,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 180);
                   ln_amt3 := ln_amt3 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information20;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 190);
                   ln_amt3 := ln_amt3 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information16;
                end if;

                -- nvl(SUI EE Taxable, SUI ER Taxable)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information18,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 200);
                   ln_amt7 := ln_amt7 +
                              pay_us_fls_reporting_pkg.ltr_action_info(i).action_information18;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 210);
                   ln_amt7 := ln_amt7 +
                              pay_us_fls_reporting_pkg.ltr_action_info(i).action_information14;
                end if;

                -- SUI EE Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information13;
                -- SUI ER Liability
                ln_r_er_tax_amt := ln_r_er_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information21;

             elsif p_tax_type in ('SDI','SDI1','HI') then -- Added 'SDI1' bug 9164356
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 220);
                /******************************************************
                   Checking for SDI and HI because for MA the tax_type
                   will be HI. The HI balances are stored in the same SDI
                   balances as all other states.
                   For all other states the tax_type is SDI.
                ********************************************************
                   Always report the ER component if it is there.  -- 4335410
                   In case ER is null report EE.
                   SDI ER Liability is always passed as 0
                *******************************************************/
                --SDI EE Gross, SDI ER Gross
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information27,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 230);
                   ln_amt2 := ln_amt2 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information27;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 240);
                   ln_amt2 := ln_amt2 +
                             pay_us_fls_reporting_pkg.ltr_action_info(i).action_information26;
                end if;

                -- nvl(SDI EE Subj Whable, SDI ER Subj Whable)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information11,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 250);
                   ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information11;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 260);
                   ln_amt4 := ln_amt4 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information7;
                end if;

                -- nvl(SDI EE Pre Tax Redns, SDI ER Pre Tax Redns)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information12,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 270);
                   ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information12;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 280);
                   ln_amt3 := ln_amt3 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information8;
                end if;

                -- nvl(SDI EE Taxable, SDI ER Taxable)
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information10,0) <> 0 then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 290);
                   ln_amt7 := ln_amt7 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information10;
                else
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 300);
                   ln_amt7 := ln_amt7 +
                               pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                end if;

/* Commented bug # 9164356 start
                -- SDI EE Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                -- SDI ER Liability
                ln_r_er_tax_amt := ln_r_er_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information9;
   Commented bug # 9164356  end*/

                if (p_tax_type = 'SDI1') then -- Added if else condition #9164356
                  -- SDI1 EE Withheld
                  ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                     pay_us_fls_reporting_pkg.ltr_action_info(i).sdi1_ee;
                  -- SDI1 ER Liability
                  ln_r_er_tax_amt := ln_r_er_tax_amt +
                                     0;
                else
                  -- SDI EE Withheld
                  ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                     pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                  -- SDI ER Liability
                  ln_r_er_tax_amt := ln_r_er_tax_amt +
                                     pay_us_fls_reporting_pkg.ltr_action_info(i).action_information9;
                end if;
             elsif p_tax_type = 'WC' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 350);
                null;
/*
                -- WC Withheld
                ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                pay_us_fls_reporting_pkg.ltr_action_info(i).action_information22;
*/
             end if;

             exit;
           -- County Jurisdiction code
           elsif substr(p_jurisdiction,7) = '-0000' and
                 substr(p_jurisdiction,3,4) <> '-000'then
             hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 400);
             -- Gross Earnings
             ln_amt2 := ln_amt2 +
                        pay_us_fls_reporting_pkg.ltr_action_info(i).action_information7;

             if p_tax_type = 'IT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 410);
                -- County Subj Whable
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                -- County Subj NWhable
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- County Pre Tax Redns
                ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                -- County Withheld
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R')
                          = 'R' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 420);
                   ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;
                   ln_r_flag := 'Y';
                elsif nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R')
                          = 'NR' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 430);
                   ln_nr_ee_tax_amt := ln_nr_ee_tax_amt +
                                    pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;
                   ln_nr_flag := 'Y';
                end if;

             elsif p_tax_type = 'OPT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 440);
                -- Head Tax Subj Whable
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                -- Head Tax Subj NWhable
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- Head Tax Pre Tax Redns
                ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;

                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R')
                       = 'R' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 450);
                   -- Head Tax Withheld
                   ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                   -- Head Tax Liability
                   ln_r_er_tax_amt := ln_r_er_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                   ln_r_flag := 'Y';
                elsif nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R')
                          = 'NR' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 460);
                   -- Head Tax Withheld
                   ln_nr_ee_tax_amt := ln_nr_ee_tax_amt +
                                    pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                   -- Head Tax Liability
                   ln_nr_er_tax_amt := ln_nr_er_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                   ln_nr_flag := 'Y';
                end if;
             end if;
             if ln_nr_flag = 'Y' and ln_r_flag = 'Y' then
                exit;
             end if;

           -- City Jurisdiction code
           elsif length(p_jurisdiction) = 11 and
                 substr(p_jurisdiction,3) <> '-000-0000'then
             -- Gross Earnings
             hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 500);
             ln_amt2 := ln_amt2 +
                        pay_us_fls_reporting_pkg.ltr_action_info(i).action_information7;

             if p_tax_type = 'IT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 510);
                -- City Subj Whable
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                -- City Subj NWhable
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- City Pre Tax Redns
                ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                -- City Withheld
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R') = 'R' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 520);
                   ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;
                   ln_r_flag := 'Y';
                elsif nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R') = 'NR' then
                   ln_nr_ee_tax_amt := ln_nr_ee_tax_amt +
                                    pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;
                   ln_nr_flag := 'Y';
                end if;

             elsif p_tax_type = 'OPT' then
                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 530);
                -- Head Tax Subj Whable
                ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                -- Head Tax Subj NWhable
                ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                -- Head Tax Pre Tax Redns
                ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                -- Head Tax Withheld
                if nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R') = 'R' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 540);
                   ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                   -- Head Tax Liability
                   ln_r_er_tax_amt := ln_r_er_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                   ln_r_flag := 'Y';
                elsif nvl(pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R') = 'NR' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 550);
                   -- Head Tax Withheld
                   ln_nr_ee_tax_amt := ln_nr_ee_tax_amt +
                                    pay_us_fls_reporting_pkg.ltr_action_info(i).action_information6;
                   -- Head Tax Liability
                   ln_nr_er_tax_amt := ln_nr_er_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;
                   ln_nr_flag := 'Y';
                end if;
             end if;
             if ln_nr_flag = 'Y' and ln_r_flag = 'Y' then
                exit;
             end if;

           -- School Jurisdiction code
           elsif length(p_jurisdiction) = 8 then
             hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 600);
             if nvl(Pay_us_fls_reporting_pkg.ltr_action_info(i).action_information30, 'R')
                         = nvl(p_resident_jurisdiction, 'R') then

                hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 600);
                hr_utility.trace('ANK Gross val = ' ||
                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5);
                -- Gross Earnings
                ln_amt2 := ln_amt2 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information5;

                if p_tax_type = 'IT' then
                   hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 610);
                   -- School Subj Whable
                   ln_amt4 := ln_amt4 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information2;
                   -- School Subj NWhable
                   ln_amt5 := ln_amt5 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information3;
                   -- School Pre Tax Redns
                   ln_amt3 := ln_amt3 +
                           pay_us_fls_reporting_pkg.ltr_action_info(i).action_information4;
                   -- School Withheld
                   ln_r_ee_tax_amt := ln_r_ee_tax_amt +
                                   pay_us_fls_reporting_pkg.ltr_action_info(i).action_information1;
                end if;
                exit;
             end if;

           end if; /* End of Jurisdiction Check */
        end if;    /* End of PL/SQL Table and Parameter JD check */
    end loop;      /* End of PL/SQL Table Loop */

    hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 700);
    hr_utility.trace('Amt1=' || ln_amt1);
    hr_utility.trace('Amt2=' || ln_amt2);
    hr_utility.trace('Amt3=' || ln_amt3);
    hr_utility.trace('Amt4=' || ln_amt4);
    hr_utility.trace('Amt5=' || ln_amt5);
    hr_utility.trace('Amt6=' || ln_amt6);
    hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 710);

    ln_gross_amt   := ln_amt2;
    if p_tax_type in ('IT', 'OPT', 'EIC') then
       ln_subject_amt := ln_amt1 + ln_amt4 + ln_amt5;
       ln_taxable_amt := ln_amt1 + ln_amt4 + ln_amt5 - (ln_amt3 - ln_amt6);
    else
       ln_subject_amt := ln_amt1 + ln_amt4 - (ln_amt3 - ln_amt6);
       ln_taxable_amt := ln_amt7;
    end if;

    if p_tax_type in ('SDI', 'UI') and
       substr(p_jurisdiction,3) = '-000-0000' and
       p_jurisdiction <> '00-000-0000' then
       ln_r_er_tax_amt := 0;
    end if;

    hr_utility.trace('Gross='   || ln_gross_amt);
    hr_utility.trace('Subj='    || ln_subject_amt);
    hr_utility.trace('Taxable=' || ln_taxable_amt);
    hr_utility.trace('Withheld='|| ln_r_ee_tax_amt);

    /* Return the formatted values */
    select ltrim(rtrim(to_char(ln_gross_amt, decode(sign(ln_gross_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00')))) ||
           ltrim(rtrim(to_char(ln_subject_amt, decode(sign(ln_subject_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00')))) ||
           ltrim(rtrim(to_char(ln_taxable_amt, decode(sign(ln_taxable_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00')))) ||
           ltrim(rtrim(to_char(ln_r_ee_tax_amt, decode(sign(ln_r_ee_tax_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00')))) ||
           ltrim(rtrim(to_char(ln_r_er_tax_amt, decode(sign(ln_r_er_tax_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00')))) ||
           ltrim(rtrim(to_char(ln_nr_ee_tax_amt, decode(sign(ln_nr_ee_tax_amt),
                                              -1, '0000000000.00',
                                              '00000000000.00'))))
       into lv_return from dual;

    hr_utility.trace('Return Value=' || lv_return);
    hr_utility.set_location(gv_package || '.get_fls_tax_type_values', 800);
    return(lv_return);
  END get_fls_tax_type_values;

--BEGIN
--  hr_utility.trace_on(null, 'FLSP');

END pay_us_fls_reporting_pkg;

/
