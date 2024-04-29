--------------------------------------------------------
--  DDL for Package Body PAY_MX_SSAFFL_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SSAFFL_SALARY" AS
/* $Header: paymxsalary.pkb 120.2 2005/08/01 12:34:05 kthirmiy noship $ */
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

    Name        : per_mx_ssaffl_salary

    Description : This package is used by the Social Security Affiliation
                  Salary Modification report to
                  1) Archive Salary affiliation records in
                     pay_action_information table
                  2) Produce salary modification dispmag tape report

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    15-NOV-2004 kthirmiy   115.0            Created.
    02-DEC-2004 kthirmiy   115.1            round idw to 2 decimal and archive
    03-Jan-2005 kthirmiy   115.2   4084628  IDW is limited to 25 times of minimum wages
                                            of Zone A for reporting purposes
    07-Jan-2005 kthirmiy   115.3   4104743  Default Implementation date is derived from
                                            pay_mx_legislation_info_f table.
    20-Jan-2005 ardsouza   115.4   4129001  Added business_group_id parameter in
                                            calls to procedure "per_mx_ssaffl_
                                            archive.derive_gre_from_loc_scl".
    16-Feb-2005 kthirmiy   115.5   4184215  Changed MXIDWF and to MXIDWV to
                                            MX_IDWF and MX_IDWV
    24-Feb-2005 kthirmiy   115.6   4201693  increased lv_idw_mode to 20 characters
    06-May-2005 kthirmiy   115.7   4353084  removed the redundant use of bind variable
                                            payroll_action_id
    31-May-2005 ardsouza   115.8   4403044  Corrected condition to default impl
                                            date in get_start_date procedure.
    01-Aug-2005 kthirmiy   115.9   4528984  Added where condition to get the correct
                                            minimum wage based on the effective_date
  ******************************************************************************/


   --
   -- < PRIVATE GLOBALS > ---------------------------------------------------
   --

   gv_package          VARCHAR2(100)   ;

   gv_event_group      VARCHAR2(40)    ;

   g_ambiguous_error   VARCHAR2(100)   ;
   g_missing_gre_error VARCHAR2(100)   ;

   g_report_imp_date   DATE ;

   g_event_group_id    NUMBER ;

   g_action_salary_category VARCHAR2(100) ;
   g_action_sep_category  VARCHAR2(100) ;

   -- flag to write the debug messages in the concurrent program log file
   g_concurrent_flag      VARCHAR2(1)  ;
   -- flag to write the debug messages in the trace file
   g_debug_flag           VARCHAR2(1)  ;



  /******************************************************************************
   Name      : msg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
  ******************************************************************************/

  PROCEDURE msg(p_text  VARCHAR2)
  IS
  --
  BEGIN
    -- Write to the concurrent request log
    fnd_file.put_line(fnd_file.log, p_text);

  END msg;

  /******************************************************************************
   Name      : dbg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
               if debuggging is enabled
  ******************************************************************************/
  PROCEDURE dbg(p_text  VARCHAR2) IS

  BEGIN

   IF (g_debug_flag = 'Y') THEN
     IF (g_concurrent_flag = 'Y') THEN
        -- Write to the concurrent request log
        fnd_file.put_line(fnd_file.log, p_text);
     ELSE
         -- Use HR trace
         hr_utility.trace(p_text);
     END IF;
   END IF;

  END dbg;


FUNCTION get_start_date( p_business_group_id in varchar2
                        ,p_tran_gre_id  in varchar2
                        ,p_gre_id       in varchar2
                       ) RETURN VARCHAR2
   IS

   cursor c_get_start_date(cp_tax_unit_id in number)
   is
   select  fnd_date.canonical_to_date(ltrim(rtrim(substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,
                         'END_DATE=')
                + length('END_DATE='),
                (instr(ppa.legislative_parameters,
                         'TRANS_GRE=') - 1 )
              - (instr(ppa.legislative_parameters,
                         'END_DATE=')
              + length('END_DATE='))))))
   from pay_assignment_actions paa,
       pay_payroll_actions ppa
   where paa.tax_unit_id = cp_tax_unit_id
    and ppa.payroll_action_id=paa.payroll_action_id
    and ppa.report_type='SS_AFFILIATION'
    and ppa.report_qualifier ='SALARY'
   order by paa.payroll_action_id desc ;


   cursor c_get_imp_date(cp_organization_id in number)
    is
    select fnd_date.canonical_to_date(org_information6)
    from hr_organization_information
    where org_information_context= 'MX_TAX_REGISTRATION'
    and organization_id = cp_organization_id ;

    ld_report_imp_date   date ;
    ld_start_date        date ;
    lv_start_date        varchar2(50);
    ln_tax_unit_id       NUMBER;
    ln_legal_emp_id      NUMBER;

    begin


    -- get the legal employer id  from p_trans_gre_id

    ln_legal_emp_id := hr_mx_utility.get_legal_employer(p_business_group_id,
                                p_tran_gre_id) ;


    -- get the report Implementation Date from p_legal_emp_id
    open c_get_imp_date(ln_legal_emp_id) ;
    fetch c_get_imp_date into ld_report_imp_date ;
    -- Bug 4403044 - Corrected condition
    --
    if (c_get_imp_date%notfound) OR (ld_report_imp_date IS NULL) then
       -- defaulting to Report Implementation Date from mx pay legislation info table
       ld_report_imp_date := fnd_date.canonical_to_date(per_mx_ssaffl_archive.get_default_imp_date) ;
    end if;
    close c_get_imp_date;

    if p_gre_id is not null then
       ln_tax_unit_id := to_number(p_gre_id) ;
    else
       ln_tax_unit_id := to_number(p_tran_gre_id) ;
    end if ;

    open c_get_start_date(ln_tax_unit_id);
    fetch c_get_start_date into ld_start_date ;
    if c_get_start_date%notfound then
       -- assign the ld_start_date from rep imp date
       ld_start_date := ld_report_imp_date ;
    end if;
    close c_get_start_date;

    lv_start_date := fnd_date.date_to_canonical(ld_start_date) ;

    return lv_start_date ;

    end get_start_date;



  /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This procedue returns the Payroll Action level parameter
               information for SS Affiliation Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_report_mode       - Fixed Salary, Bimonthly Salary
               p_period_start_date - Bimonthly period start date
               p_period_end_date   - Bimonthly period end date
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_tran_gre_id       - Transmiter GRE Id
               p_gre_id            - GRE Id
               p_event_group_id    - Event Group Id

  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in        number
                                   ,p_report_mode          out nocopy varchar2
                                   ,p_period_start_date    out nocopy date
                                   ,p_period_end_date      out nocopy date
                                   ,p_start_date           out nocopy date
                                   ,p_end_date             out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_tran_gre_id          out nocopy number
                                   ,p_gre_id               out nocopy number
                                   ,p_event_group_id       out nocopy number
                                   )
  IS
      -- cursor to get all the parameters from pay_payroll_actions table

      cursor c_payroll_Action_info(cp_payroll_action_id in number) is
      select business_group_id,
             to_number(substr(legislative_parameters,
                    instr(legislative_parameters,
                    'GRE_ID=')
                + length('GRE_ID='))) , -- gre_id
             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANS_GRE=')
                + length('TRANS_GRE='),
                (instr(legislative_parameters,
                         'GRE_ID=') - 1 )
              - (instr(legislative_parameters,
                         'TRANS_GRE=')
              + length('TRANS_GRE=')))))) , -- trans_gre

             fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'END_DATE=')
                + length('END_DATE='),
                (instr(legislative_parameters,
                         'TRANS_GRE=') - 1 )
              - (instr(legislative_parameters,
                         'END_DATE=')
              + length('END_DATE=')))))),  -- end_date

             fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'START_DATE=')
                + length('START_DATE='),
                (instr(legislative_parameters,
                         'END_DATE=') - 1 )
              - (instr(legislative_parameters,
                         'START_DATE=')
              + length('START_DATE=')))))),  -- start_date


              fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'PERIOD_ENDING_DATE=')
                + length('PERIOD_ENDING_DATE='),
                (instr(legislative_parameters,
                         'START_DATE=') - 1 )
              - (instr(legislative_parameters,
                         'PERIOD_ENDING_DATE=')
              + length('PERIOD_ENDING_DATE=')))))), -- period_ending_date

              trunc( add_months (
              fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'PERIOD_ENDING_DATE=')
                + length('PERIOD_ENDING_DATE='),
                (instr(legislative_parameters,
                         'START_DATE=') - 1 )
              - (instr(legislative_parameters,
                         'PERIOD_ENDING_DATE=')
              + length('PERIOD_ENDING_DATE=')))))) , -1 ),'MM'), -- period_start_date

             ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'REPORT_MODE=')
                + length('REPORT_MODE='),
                (instr(legislative_parameters,
                         'PERIOD_ENDING_DATE=') - 1 )
              - (instr(legislative_parameters,
                         'REPORT_MODE=')
              + length('REPORT_MODE=')))))  -- report_mode

      from pay_payroll_actions
      where payroll_action_id = cp_payroll_action_id;

    cursor c_get_imp_date(cp_organization_id in number)
    is
    select fnd_date.canonical_to_date(org_information6)
    from hr_organization_information
    where org_information_context= 'MX_TAX_REGISTRATION'
    and organization_id = cp_organization_id ;


    cursor c_get_event_group (cp_event_group_name in varchar2) is
    select event_group_id
    from pay_event_groups
    where event_group_name = cp_event_group_name ;

    lv_report_mode        VARCHAR2(1);
    ld_period_start_date  DATE;
    ld_period_end_date    DATE;
    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tran_gre_id       NUMBER;
    ln_gre_id            NUMBER;

    ln_tax_unit_id       NUMBER;
    ln_legal_emp_id      NUMBER;
    ln_event_group_id    NUMBER;

    ld_report_imp_date   DATE;

    lv_procedure_name    VARCHAR2(100) ;
    lv_error_message     VARCHAR2(200) ;
    ln_step              NUMBER;

   BEGIN

       lv_procedure_name    := '.get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       dbg('Entering get_payroll_action_info .......');

       -- open the cursor to get all the parameters from pay_payroll_actions table
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_business_group_id,
                                        ln_gre_id,
                                        ln_tran_gre_id,
                                        ld_end_date,
                                        ld_start_date,
                                        ld_period_end_date,
                                        ld_period_start_date,
                                        lv_report_mode
                                        ;
       close c_payroll_action_info;

       ln_legal_emp_id := hr_mx_utility.get_legal_employer(ln_business_group_id,
                              ln_tran_gre_id ) ;

       -- get the report Implementation Date from ln_legal_emp_id and set it to the
       -- global variable g_report_imp_date
       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       ln_step := 2;
       dbg('Get report Impl date for Legal employer id ' ||to_char(ln_legal_emp_id) );

       open c_get_imp_date(ln_legal_emp_id) ;
       fetch c_get_imp_date into ld_report_imp_date ;
       if c_get_imp_date%notfound then
          dbg('WARNING : Report Implementaton date is not entered for legal employer ' );
          dbg('so defaulting to Report Implementation Date from pay mx legislation info table');
          ld_report_imp_date := fnd_date.canonical_to_date(per_mx_ssaffl_archive.get_default_imp_date) ;
       end if;
       close c_get_imp_date;
       dbg('report impl date is '||to_char(ld_report_imp_date) );
       g_report_imp_date := ld_report_imp_date;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       ln_step := 3;
       dbg('Get Event Group Id ' );

       open c_get_event_group(gv_event_group) ;
       fetch c_get_event_group into ln_event_group_id ;
       close c_get_event_group ;


       p_report_mode       := lv_report_mode;
       p_period_start_date := ld_period_start_date;
       p_period_end_date   := ld_period_end_date;
       p_start_date        := ld_start_date;
       p_end_date          := ld_end_date;
       p_business_group_id := ln_business_group_id;
       p_tran_gre_id       := ln_tran_gre_id;
       p_gre_id            := ln_gre_id;
       p_event_group_id    := ln_event_group_id ;

       dbg('Parameters.....');

       dbg('report mode        : ' || p_report_mode ) ;
       dbg('period start date  : ' || fnd_date.date_to_canonical(p_period_start_date)) ;
       dbg('period end date    : ' || fnd_date.date_to_canonical(p_period_end_date)) ;
       dbg('start date         : ' || fnd_date.date_to_canonical(p_start_date)) ;
       dbg('end date           : ' || fnd_date.date_to_canonical(p_end_date)) ;
       dbg('bus group id       : ' || to_char(p_business_group_id)) ;
       dbg('trans gre id       : ' || to_char(p_tran_gre_id)) ;
       dbg('gre id             : ' || to_char(p_gre_id)) ;
       dbg('event group id     : ' || to_char(p_event_group_id) );

       hr_utility.set_location(gv_package || lv_procedure_name, 40);
       ln_step := 4;

       dbg('Exiting get_payroll_action_info .......');

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END get_payroll_action_info;


  /******************************************************************
   Name      : range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               Social Security Affiliation Archiver.
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_cursor( p_payroll_action_id in        number
                         ,p_sqlstr           out nocopy varchar2)
  IS

    CURSOR c_chk_dyn_triggers_enabled(cp_func_area in VARCHAR2)
    IS
    select pte.short_name
    from pay_functional_areas pfa,
         pay_functional_triggers pft,
         pay_trigger_events     pte
    where pfa.short_name = cp_func_area
    and   pfa.area_id = pft.area_id
    and   pft.event_id = pte.event_id
    and ( pte.generated_flag <> 'Y' or pte.enabled_flag <> 'Y' ) ;

    lv_report_mode        VARCHAR2(1);
    ld_period_start_date  DATE;
    ld_period_end_date    DATE;

    ld_start_date         DATE;
    ld_end_date           DATE;
    ln_business_group_id  NUMBER;
    ln_tran_gre_id        NUMBER;
    ln_gre_id             NUMBER;
    ln_event_group_id     NUMBER;

    lv_sql_string         VARCHAR2(32000);
    lv_procedure_name     VARCHAR2(100)  ;

    lv_func_area          VARCHAR2(40);
    lv_trigger_name       VARCHAR2(100);
  BEGIN

    dbg('Entering range_cursor ....... ') ;

    gv_package            := 'per_mx_ssaffl_salary'  ;
    gv_event_group        := 'MX_SALARY_EVG' ;
    g_ambiguous_error     := '1' ; -- Multiple GRE found
    g_missing_gre_error   := '2' ; -- Location is not in the hierarchy';
    g_debug_flag          := 'Y' ;
--    g_concurrent_flag     := 'Y' ;

    lv_procedure_name     := '.range_cursor';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    lv_func_area          := 'SS Affiliation Salary Events' ;

    -- Get all the parameter information from pay_payroll_actions table
    dbg('Get parameter information from pay_payroll_actions table' ) ;

    get_payroll_action_info( p_payroll_action_id    => p_payroll_action_id
                            ,p_report_mode          => lv_report_mode
                            ,p_period_start_date    => ld_period_start_date
                            ,p_period_end_date      => ld_period_end_date
                            ,p_start_date           => ld_start_date
                            ,p_end_date             => ld_end_date
                            ,p_business_group_id    => ln_business_group_id
                            ,p_tran_gre_id          => ln_tran_gre_id
                            ,p_gre_id               => ln_gre_id
                            ,p_event_group_id       => ln_event_group_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     -- Check the dynamic triggers are enable for functional area
     dbg('Check dynamic triggers enabled' ) ;

     open c_chk_dyn_triggers_enabled(lv_func_area );
     fetch c_chk_dyn_triggers_enabled into lv_trigger_name  ;

     if c_chk_dyn_triggers_enabled%found then
        close c_chk_dyn_triggers_enabled;

        dbg('Error : Dynamic triggers NOT enabled' ) ;
        lv_sql_string := null;

        hr_utility.raise_error;

     else

        dbg('Dynamic triggers Enabled' ) ;
        close c_chk_dyn_triggers_enabled ;

        if lv_report_mode = 'F' then  -- Fixed Salary

           lv_sql_string := 'select distinct paf.person_id
   from pay_process_events      ppe,
     pay_datetracked_events  pde,
     pay_event_updates       peu,
     pay_element_entries_f   pee,
     pay_element_types_f     pet,
     pay_element_type_extra_info petei,
     per_all_assignments_f  paf
     where ppe.creation_date between
        fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_start_date) || ''')
        and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_end_date) || ''')
        and   peu.event_update_id =ppe.event_update_id
        and   peu.dated_table_id = pde.dated_table_id
        and   pde.event_group_id = ''' ||ln_event_group_id || '''
        and   ppe.business_group_id = ''' ||ln_business_group_id || '''
        and   nvl(peu.column_name,1) = nvl(pde.column_name,1)
        and   decode(pde.update_type,''I'',''INSERT'',''U'',''UPDATE'',pde.update_type) = peu.event_type
        and   peu.change_type = ''DATE_EARNED''
        and   pee.element_entry_id = ppe.surrogate_key
        and   pet.element_type_id = pee.element_type_id
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category=''PQP_UK_RATE_TYPE''
        and   petei.eei_information1=''MX_IDWF''
        and   ppe.effective_date between pee.effective_start_date and pee.effective_end_date
        and  paf.assignment_id = ppe.assignment_id
        and ppe.effective_date between paf.effective_start_date and paf.effective_end_date
   and (( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -1 )
   or ( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -2 )
   or ( ''' ||ln_tran_gre_id || ''' is not null and ''' ||ln_gre_id || ''' is not null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)=''' ||ln_gre_id || '''      )
  or ( ''' ||ln_tran_gre_id || ''' is not null and ''' ||ln_gre_id || ''' is null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)
       in
       (select organization_id
          from hr_organization_information hoi
          where  hoi.org_information_context = ''MX_SOC_SEC_DETAILS''
and ((org_information6 = ''' ||ln_tran_gre_id || ''' ) OR
  ( organization_id = ''' ||ln_tran_gre_id || ''' and org_information3=''Y'')))))
        and :payroll_action_id > 0  ' ;

        elsif lv_report_mode = 'P' then -- Bi-monthly Salary

   lv_sql_string := 'select paf1.person_id
   from
   (
   select distinct paf.assignment_id
   from pay_process_events      ppe,
     pay_datetracked_events  pde,
     pay_event_updates       peu,
     pay_element_entries_f   pee,
     pay_element_types_f     pet,
     pay_element_type_extra_info petei,
     per_all_assignments_f  paf
     where ppe.creation_date between
        fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_start_date) || ''')
        and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_end_date) || ''')
        and   peu.event_update_id =ppe.event_update_id
        and   peu.dated_table_id = pde.dated_table_id
        and   pde.event_group_id = ''' ||ln_event_group_id || '''
        and   ppe.business_group_id = ''' ||ln_business_group_id || '''
        and   nvl(peu.column_name,1) = nvl(pde.column_name,1)
        and   decode(pde.update_type,''I'',''INSERT'',''U'',''UPDATE'',pde.update_type) = peu.event_type
        and   peu.change_type = ''DATE_EARNED''
        and   pee.element_entry_id = ppe.surrogate_key
        and   pet.element_type_id = pee.element_type_id
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category=''PQP_UK_RATE_TYPE''
        and   petei.eei_information1=''MX_IDWF''
        and   ppe.effective_date between pee.effective_start_date and pee.effective_end_date
        and  paf.assignment_id = ppe.assignment_id
        and ppe.effective_date between paf.effective_start_date and paf.effective_end_date
        union
        select distinct pee.assignment_id
        from pay_element_entries_f pee,
             pay_element_type_extra_info petei
        where pee.effective_start_date between
        fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_start_date) || ''')
        and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || ''')
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category=''PQP_UK_RATE_TYPE''
        and   petei.eei_information1=''MX_IDWV''
         ) x,
         per_all_assignments_f paf1
     where x.assignment_id = paf1.assignment_id
     and  fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || ''')
     between  paf1.effective_start_date and paf1.effective_end_date
     and (( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
     fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || ''')) = -1 )
   or ( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
   fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || ''')) = -2 )
   or ( ''' ||ln_tran_gre_id || ''' is not null and ''' ||ln_gre_id || ''' is not null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
       fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || '''))=''' ||ln_gre_id || ''')
  or ( ''' ||ln_tran_gre_id || ''' is not null and ''' ||ln_gre_id || ''' is null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_period_end_date) || '''))
       in
       (select organization_id
          from hr_organization_information hoi
          where  hoi.org_information_context = ''MX_SOC_SEC_DETAILS''
          and ((org_information6 = ''' ||ln_tran_gre_id || ''' ) OR
( organization_id = ''' ||ln_tran_gre_id || ''' and org_information3=''Y'')))))
 and :payroll_action_id > 0 ' ;


       end if;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Exiting range_cursor .......') ;

  END range_cursor;


  /************************************************************
   Name      : action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the SS Affiliation Salary Modification Report.
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id in number
                ,p_end_person_id   in number
                ,p_chunk               in number)
  IS

   cursor c_get_fix_sal_asg( cp_start_person_id in number
                    ,cp_end_person_id   in number
                    ,cp_tran_gre_id         in number
                    ,cp_gre_id              in number
                    ,cp_business_group_id   in number
                    ,cp_start_date          in date
                    ,cp_end_date            in date
                    ,cp_event_group_id      in number
                        ) is
       select distinct ppe.assignment_id
       from pay_process_events      ppe,
     pay_datetracked_events  pde,
     pay_event_updates       peu,
     pay_element_entries_f   pee,
     pay_element_types_f     pet,
     pay_element_type_extra_info petei,
     per_all_assignments_f  paf
     where ppe.creation_date between cp_start_date and cp_end_date
        and   peu.event_update_id =ppe.event_update_id
        and   peu.dated_table_id = pde.dated_table_id
        and   pde.event_group_id = cp_event_group_id
        and   ppe.business_group_id = cp_business_group_id
        and   nvl(peu.column_name,1) = nvl(pde.column_name,1)
        and   decode(pde.update_type,'I','INSERT','U','UPDATE',pde.update_type) = peu.event_type
        and   peu.change_type = 'DATE_EARNED'
        and   pee.element_entry_id = ppe.surrogate_key
        and   pet.element_type_id = pee.element_type_id
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category='PQP_UK_RATE_TYPE'
        and   petei.eei_information1='MX_IDWF'
        and   ppe.effective_date between pee.effective_start_date and pee.effective_end_date
        and   paf.assignment_id = ppe.assignment_id
        and   paf.person_id between cp_start_person_id and cp_end_person_id
        and ppe.effective_date between paf.effective_start_date and paf.effective_end_date
   and (( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -1 )
   or ( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -2 )
   or ( cp_tran_gre_id is not null and cp_gre_id is not null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)=cp_gre_id       )
  or ( cp_tran_gre_id is not null and cp_gre_id is null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)
       in
       (select organization_id
          from hr_organization_information hoi
          where  hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
          and ((org_information6 = cp_tran_gre_id ) OR ( organization_id = cp_tran_gre_id and org_information3='Y')))))
         ;


     cursor c_get_all_sal_asg( cp_start_person_id in number
                    ,cp_end_person_id   in number
                    ,cp_tran_gre_id         in number
                    ,cp_gre_id              in number
                    ,cp_business_group_id   in number
                    ,cp_start_date          in date
                    ,cp_end_date            in date
                    ,cp_event_group_id      in number
                    ,cp_period_start_date   in date
                    ,cp_period_end_date     in date
                        ) is
     select x.assignment_id
     from
      (
       select distinct paf.assignment_id
       from pay_process_events      ppe,
            pay_datetracked_events  pde,
            pay_event_updates       peu,
            pay_element_entries_f   pee,
            pay_element_types_f     pet,
            pay_element_type_extra_info petei,
            per_all_assignments_f  paf
        where ppe.creation_date between cp_start_date and cp_end_date
        and   peu.event_update_id =ppe.event_update_id
        and   peu.dated_table_id = pde.dated_table_id
        and   pde.event_group_id = cp_event_group_id
        and   ppe.business_group_id = cp_business_group_id
        and   nvl(peu.column_name,1) = nvl(pde.column_name,1)
        and   decode(pde.update_type,'I','INSERT','U','UPDATE',pde.update_type) = peu.event_type
        and   peu.change_type = 'DATE_EARNED'
        and   pee.element_entry_id = ppe.surrogate_key
        and   pet.element_type_id = pee.element_type_id
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category='PQP_UK_RATE_TYPE'
        and   petei.eei_information1='MX_IDWF'
        and   ppe.effective_date between pee.effective_start_date and pee.effective_end_date
        and  paf.assignment_id = ppe.assignment_id
        and ppe.effective_date between paf.effective_start_date and paf.effective_end_date
        union
        select distinct pee.assignment_id
        from pay_element_entries_f pee,
             pay_element_type_extra_info petei
        where pee.effective_start_date between cp_period_start_date and cp_period_end_date
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category='PQP_UK_RATE_TYPE'
        and   petei.eei_information1='MX_IDWV'
         ) x,
         per_all_assignments_f paf1
    where x.assignment_id = paf1.assignment_id
    and  paf1.person_id between cp_start_person_id and cp_end_person_id
    and  cp_period_end_date between paf1.effective_start_date and paf1.effective_end_date
    and (( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
           cp_period_end_date) = -1 )
   or ( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
   cp_period_end_date) = -2 )
   or ( cp_tran_gre_id is not null and cp_gre_id is not null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,
       cp_period_end_date)=cp_gre_id  )
   or ( cp_tran_gre_id is not null and cp_gre_id is null and
       per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf1.location_id,paf1.business_group_id,paf1.soft_coding_keyflex_id,cp_period_end_date)
       in
       (select organization_id
          from hr_organization_information hoi
          where  hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
          and ((org_information6 = cp_tran_gre_id )
     OR ( organization_id = cp_tran_gre_id and org_information3='Y'))))) ;


    lv_report_mode        VARCHAR2(1);
    ld_period_start_date  DATE;
    ld_period_end_date    DATE;
    ld_start_date         DATE;
    ld_end_date           DATE;
    ln_business_group_id  NUMBER;
    ln_tran_gre_id        NUMBER;
    ln_gre_id             NUMBER;
    ln_person_id          NUMBER;
    ln_tax_unit_id        NUMBER;
    ln_event_group_id     NUMBER;
    ln_assignment_id      NUMBER;
    ln_action_id          NUMBER;
    lv_procedure_name     VARCHAR2(100) ;
    lv_error_message      VARCHAR2(200);
    ln_step               NUMBER;

  begin

     dbg('Entering Action creation ..............') ;

     gv_package            := 'per_mx_ssaffl_salary'  ;
     gv_event_group        := 'MX_SALARY_EVG' ;
     g_debug_flag          := 'Y' ;
--     g_concurrent_flag     := 'Y' ;

     lv_procedure_name    := '.action_creation';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     dbg('Get parameter information from pay_payroll_actions table' ) ;

    get_payroll_action_info( p_payroll_action_id    => p_payroll_action_id
                            ,p_report_mode          => lv_report_mode
                            ,p_period_start_date    => ld_period_start_date
                            ,p_period_end_date      => ld_period_end_date
                            ,p_start_date           => ld_start_date
                            ,p_end_date             => ld_end_date
                            ,p_business_group_id    => ln_business_group_id
                            ,p_tran_gre_id          => ln_tran_gre_id
                            ,p_gre_id               => ln_gre_id
                            ,p_event_group_id       => ln_event_group_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Action creation Query parameters') ;
     dbg('Start person id     : ' || to_char(p_start_person_id));
     dbg('End   person id     : ' || to_char(p_end_person_id));
     dbg('tansmitter gre id   : ' || to_char(ln_tran_gre_id));
     dbg('gre id              : ' || to_char(ln_gre_id));
     dbg('event group id      : ' || to_char(ln_event_group_id));
     dbg('business_group_id   : ' || to_char(ln_business_group_id));
     dbg('start date is       : ' || fnd_date.date_to_canonical(ld_start_date)) ;
     dbg('end date is         : ' || fnd_date.date_to_canonical(ld_end_date)) ;

     if lv_report_mode = 'F' then  -- Fixed Salary

        open c_get_fix_sal_asg( p_start_person_id
                               ,p_end_person_id
                               ,ln_tran_gre_id
                               ,ln_gre_id
                               ,ln_business_group_id
                               ,ld_start_date
                               ,ld_end_date
                               ,ln_event_group_id);

     elsif lv_report_mode = 'P' then -- Bimonthly Salary

        open c_get_all_sal_asg( p_start_person_id
                               ,p_end_person_id
                               ,ln_tran_gre_id
                               ,ln_gre_id
                               ,ln_business_group_id
                               ,ld_start_date
                               ,ld_end_date
                               ,ln_event_group_id
                               ,ld_period_start_date
                               ,ld_period_end_date );

     end if ;


     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;

     loop

        if lv_report_mode  = 'F' then

           fetch c_get_fix_sal_asg into ln_assignment_id  ;
           exit when c_get_fix_sal_asg%notfound;


        elsif lv_report_mode = 'P' then -- Bimonthly Salary

           fetch c_get_all_sal_asg into ln_assignment_id  ;
           exit when c_get_all_sal_asg%notfound;

        end if;
        -- if gre_id is not null then tax_unit_id= gre_id
        -- if tran_gre_id is not null then tax_unit_id = tran_gre_id

        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        ln_step := 4;
        dbg('creating aaid for assignment_id = ' || to_char(ln_assignment_id) ||
            ' Tax Unit Id = ' || to_char(nvl(ln_gre_id,ln_tran_gre_id)) ) ;

        select pay_assignment_actions_s.nextval
        into ln_action_id
        from dual;

        -- insert into pay_assignment_actions.
        hr_nonrun_asact.insact(ln_action_id,
                               ln_assignment_id,
                               p_payroll_action_id,
                               p_chunk,
                               nvl(ln_gre_id,ln_tran_gre_id),
                               null,
                               'U',
                               null);
        dbg('assignment action id is ' || to_char(ln_action_id)  );


     end loop;


     if lv_report_mode  = 'F' then

        close c_get_fix_sal_asg ;

     elsif lv_report_mode = 'P' then -- Bimonthly Salary

        close c_get_all_sal_asg ;

     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 5;

     dbg('Exiting Action creation ..............') ;


  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END action_creation;

  /******************************************************************************
   Name      : archinit
   Purpose   : This procedure performs all the required initialization.
  ******************************************************************************/
  PROCEDURE archinit( p_payroll_action_id in number)
  IS

    ln_step                   NUMBER;
    lv_procedure_name         VARCHAR2(100) ;

  BEGIN


     dbg('Entering archinit .............');

     gv_package              := 'per_mx_ssaffl_salary'  ;
     gv_event_group          := 'MX_SALARY_EVG' ;
     g_ambiguous_error       := '1' ; -- Multiple GRE found
     g_missing_gre_error     := '2' ; -- Location is not in the hierarchy';
     g_action_salary_category  := 'MX SS SALARY DETAILS' ;
     g_debug_flag            := 'Y' ;
--     g_concurrent_flag       := 'Y' ;

     lv_procedure_name     := '.archinit';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     dbg('Exiting archinit .............');

  END archinit;


  /******************************************************************************
   Name      : get_rww_ind
   Purpose   : This function returns the reduced working week indicator
  ******************************************************************************/

  PROCEDURE get_rww_ind(p_workschedule    in        varchar2
                       ,p_rww_ind        out nocopy varchar2)
  is

  cursor c_rww(cp_workschedule in varchar2)  is
  select sum(decode(to_number(puci.value),0,0,1))
  from pay_user_column_instances_f puci,
        pay_user_columns puc
  where puc.user_column_name = cp_workschedule
  and puc.legislation_code='MX'
  and puc.user_column_id = puci.user_column_id ;

  ln_rww number ;

  BEGIN

   if p_workschedule is not null then

      open c_rww(p_workschedule) ;
      fetch c_rww into ln_rww ;
      close c_rww ;

      if ln_rww = 7  then
         -- can not be 7 if it is 7 then just assign it to 6
         -- need to check the sum logic will it work for all the values
         ln_rww := 6 ;
      end if;

      p_rww_ind := to_char(ln_rww) ;
   else
      p_rww_ind := null ;
   end if;

  END ;


  /*************************************************************************
   Name      : archive_salary_details
   Purpose   : This procedure Archives salary details for the passed
               assignment_action_id and assignment_id
  **************************************************************************/
  PROCEDURE archive_salary_details( p_assignment_action_id  in number
                                 ,p_assignment_id         in number
                                 ,p_effective_date        in date
                                 ,p_tax_unit_id           in number
                                 ,p_report_mode           in varchar2
                                 ,p_arch_status           in varchar2
                                 ,p_arch_reason           in varchar2
                                )
  IS
  cursor c_get_salary_details (cp_assignment_id in number
                           , cp_effective_date in date )
  is
  select replace(ppf.per_information3,'-','')   emp_ss_number
        ,ppf.last_name            paternal_last_name
        ,per_information1         maternal_last_name
        ,ppf.first_name || ' ' || ppf.middle_names   name
        ,substr(employment_category,3,1) worker_type
        ,hsc.segment6             salary_type
        ,puc.user_column_name     work_schedule
        ,per_information4         med_center
        ,employee_number          worker_id
        ,national_identifier      CURP
  from per_all_assignments_f paf,
       per_all_people_f ppf,
       hr_soft_coding_keyflex hsc,
       pay_user_columns puc
  where paf.assignment_id = cp_assignment_id
    and paf.person_id = ppf.person_id
    and paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id (+)
    and hsc.segment4 = puc.user_column_id(+)
    and trunc(cp_effective_date) between paf.effective_start_date and paf.effective_end_date
    and trunc(cp_effective_date) between ppf.effective_start_date and ppf.effective_end_date ;

  cursor c_get_er_ss_number(cp_gre_id in number )
  is
  select replace(org_information1,'-','')
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_gre_id ;

  cursor c_get_org_information ( cp_organization_id in number)
  is
  select org_information3,org_information5, org_information6
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_organization_id ;

  -- cursor to get the minimum wage for Zone A
  cursor c_minimum_wage_zonea (cp_effective_date in date )
  is
  select legislation_info2
  from pay_mx_legislation_info_f
  where legislation_info_type='MX Minimum Wage Information'
  and legislation_info1='MWA'
  and cp_effective_date between effective_start_date and effective_end_date ;

    lv_emp_ss_number         varchar2(240);
    lv_er_ss_number          varchar2(240);
    lv_paternal_last_name    varchar2(240);
    lv_maternal_last_name    varchar2(240);
    lv_name                  varchar2(240);
    lv_worker_type           varchar2(240);
    lv_salary_type           varchar2(240);
    lv_work_schedule         varchar2(240);
    lv_rww_indicator         varchar2(240);
    lv_med_center            varchar2(240);
    lv_worker_id             varchar2(240);
    lv_CURP                  varchar2(240);
    lv_type_of_tran          varchar2(240);
    lv_imss_way_bill         varchar2(240);
    lv_layout_identifier     varchar2(240);

    ln_idw                   NUMBER;
    ln_min_wage              NUMBER;

    lv_idw_mode              VARCHAR2(20);

    ln_fixed_idw             NUMBER;
    ln_variable_idw          NUMBER;

    lv_transmitter           VARCHAR2(1);
    ln_way_bill              NUMBER;
    ln_tr_gre_id             NUMBER;

    ln_action_information_id NUMBER ;
    ln_object_version_number NUMBER ;

    lv_procedure_name     VARCHAR2(100) ;
    lv_error_message      VARCHAR2(200);
    ln_step               NUMBER;

  BEGIN

    lv_procedure_name     := '.archive_salary_details';

    dbg('Entering Archive Salary details.........');

    lv_type_of_tran          := '07' ;
    lv_layout_identifier     := '9' ;


    ln_step := 1;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    dbg('Get employer ssid ');
    -- get employer ss id for p_tax_unit_id
    open c_get_er_ss_number(p_tax_unit_id) ;
    fetch c_get_er_ss_number into lv_er_ss_number ;
    close c_get_er_ss_number ;

    ln_step := 2;
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    dbg('Get IMSS waybill for gre '|| to_char(p_tax_unit_id) );

    -- get IMSS Waybill for p_tax_unit_id
    open c_get_org_information ( p_tax_unit_id ) ;
    fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
    close c_get_org_information ;

    dbg('Transmitter flag for this GRE is '|| lv_transmitter);

    if lv_transmitter = 'Y' then
       lv_imss_way_bill:= ln_way_bill ;
    else

       dbg('Null or No then get the waybill number from the trans gre' );
       open c_get_org_information ( ln_tr_gre_id ) ;
       fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
       lv_imss_way_bill:= ln_way_bill ;
       close c_get_org_information ;
    end if;

    dbg('way bill number is ' || lv_imss_way_bill );

    ln_step := 3;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);

    dbg('Get salary details from assignment ' );
    dbg('Assignment Id  : ' || to_char(p_assignment_id) );
    dbg('Effective Date : ' || to_char(p_effective_date,'DD-MON-YYYY'));

    -- get the asg details from the base table
    open c_get_salary_details(p_assignment_id
                           ,p_effective_date ) ;
    fetch c_get_salary_details into
             lv_emp_ss_number
            ,lv_paternal_last_name
            ,lv_maternal_last_name
            ,lv_name
            ,lv_worker_type
            ,lv_salary_type
            ,lv_work_schedule
            ,lv_med_center
            ,lv_worker_id
            ,lv_CURP ;

     close c_get_salary_details ;

     ln_step := 4;
     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Get reduced working week indicator from workschedule ' );

     -- derive Reduced Working-week indicator from workschedule
     if lv_work_schedule is not null then
        get_rww_ind(lv_work_schedule,lv_rww_indicator );
     else
        lv_rww_indicator := null ;
     end if;


     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

     dbg('Get IDW' );

     if p_report_mode = 'F' then -- Fixed Salary
        lv_idw_mode  := 'REPORT' ;
     elsif p_report_mode ='P' then -- Bimonthly Salary
        lv_idw_mode  := 'BIMONTH_REPORT' ;
     end if;

     dbg('Assignment Id   '||to_char(p_assignment_id) );
     dbg('Tax unit Id     '||to_char(p_tax_unit_id) );
     dbg('Effective Date  '||to_char(p_effective_date) );
     dbg('Mode            '||lv_idw_mode );


     ln_min_wage := 0 ;

     -- get the minimum wage for Zone A
     /* bug fix 4528984 */
     open c_minimum_wage_zonea (p_effective_date) ;
     fetch c_minimum_wage_zonea into ln_min_wage ;
     close c_minimum_wage_zonea ;

     dbg('Zone A Minimum Wage  '||to_char(ln_min_wage) );

     ln_idw := 0 ;
     ln_idw := pay_mx_ff_udfs.get_idw( p_assignment_id  => p_assignment_id
             ,p_tax_unit_id    => p_tax_unit_id
             ,p_effective_date => p_effective_date
             ,p_mode           => lv_idw_mode
             ,p_fixed_idw      => ln_fixed_idw
             ,p_variable_idw   => ln_variable_idw
             ) ;

     dbg('Calulated IDW from get_idw  '||to_char(ln_idw) );

     -- check the IDW with 25 times of zone A minimum wage
     -- if idw is greater than 25 times of zone A minimum wage then
     --    idw = 25 times of zone A minimum wage
     -- else
     --    idw = calculated one
     -- end if

     if ln_idw > ( 25 * ln_min_wage ) then
        ln_idw := 25 * ln_min_wage ;
     end if;

     dbg('IDW after compared with min wage '||to_char(ln_idw) );

     -- round to 2 decimal and archive
     ln_idw := round(ln_idw,2) ;

     dbg('IDW with 2 decimal  '||to_char(ln_idw) );

     ln_step := 6;
     hr_utility.set_location(gv_package || lv_procedure_name, 60);

     dbg('call api to insert the record in pay action information with parameters' );
     msg('Action_information_category : ' || 'MX SS SALARY DETAILS' );
     msg('Action Context Id           : ' || to_char(p_assignment_action_id) );
     msg('ER SS Number is    : ' || lv_er_ss_number );
     msg('EE SS Number is    : ' || lv_emp_ss_number );
     msg('Paternal Last Name : ' || lv_paternal_last_name );
     msg('Maternal Last Name : ' || lv_maternal_last_name );
     msg('Name               : ' || lv_name );
     msg('IDW                : ' || to_char(ln_idw) );
     msg('Worker Type        : ' || lv_worker_type );
     msg('Salary Type        : ' || lv_salary_type );
     msg('RWW Indicator      : ' || lv_rww_indicator);
     msg('Salary Modification Date : ' || to_char(p_effective_date,'DDMMYYYY'));
     msg('transaction type   : ' || lv_type_of_tran );
     msg('IMSS Waybill       : ' || lv_imss_way_bill );
     msg('Worker ID          : ' || lv_worker_id );
     msg('CURP               : ' || lv_curp );
     msg('Layout Identifier  : ' || lv_layout_identifier );


     -- call the api to insert the record in pay_action_information
     pay_action_information_api.create_action_information(
                p_action_information_id => ln_action_information_id
               ,p_object_version_number => ln_object_version_number
               ,p_action_information_category => 'MX SS SALARY DETAILS'
               ,p_action_context_id    => p_assignment_action_id
               ,p_action_context_type  => 'AAP'
               ,p_jurisdiction_code    => null
               ,p_assignment_id        => p_assignment_id
               ,p_tax_unit_id          => p_tax_unit_id
               ,p_effective_date       => p_effective_date
               ,p_action_information1  => substr(lv_er_ss_number,1,10)
               ,p_action_information2  => substr(lv_er_ss_number,length(lv_er_ss_number),1)
               ,p_action_information3  => substr(lv_emp_ss_number,1,10)
               ,p_action_information4  => substr(lv_emp_ss_number,length(lv_emp_ss_number),1)
               ,p_action_information5  => lv_paternal_last_name
               ,p_action_information6  => lv_maternal_last_name
               ,p_action_information7  => lv_name
               ,p_action_information8  => to_char(ln_idw)
               ,p_action_information9  => null    -- filler1
               ,p_action_information10 => lv_worker_type
               ,p_action_information11 => lv_salary_type
               ,p_action_information12 => lv_rww_indicator
               ,p_action_information13 => to_char(p_effective_date,'DDMMYYYY')
               ,p_action_information15 => null -- filler2
               ,p_action_information16 => lv_type_of_tran
               ,p_action_information17 => lv_imss_way_bill
               ,p_action_information18 => lv_worker_id
               ,p_action_information19 => null -- filler3
               ,p_action_information20 => lv_curp
               ,p_action_information21 => lv_layout_identifier
               ,p_action_information22 => p_arch_status
               ,p_action_information23 => p_arch_reason
                );

     msg('Successfully Archived. Action Information Id is : ' || to_char(ln_action_information_id) );

    ln_step := 7;
    hr_utility.set_location(gv_package || lv_procedure_name, 70);

    dbg('Exiting archive_salary_details .........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END archive_salary_details ;


  /************************************************************
   Name      : archive_data
   Purpose   : This procedure Archives data
  ************************************************************/
  PROCEDURE archive_data(p_assignment_action_id  in number
                        ,p_effective_date in date)
  IS

    cursor c_asg_action_info (cp_assignment_action in number) is
      select paa.payroll_action_id,
             paa.assignment_id,
             paa.tax_unit_id
        from pay_assignment_actions paa
       where paa.assignment_action_id = cp_assignment_action;


    cursor c_get_fix_sal_date( cp_assignment_id in number
                    ,cp_business_group_id   in number
                    ,cp_start_date          in date
                    ,cp_end_date            in date
                    ,cp_event_group_id      in number
                      ) is
     select max(ppe.effective_date)
     from pay_process_events      ppe,
          pay_datetracked_events  pde,
     pay_event_updates       peu,
     pay_element_entries_f   pee,
     pay_element_types_f     pet,
     pay_element_type_extra_info petei
     where ppe.assignment_id = cp_assignment_id
        and ppe.creation_date between cp_start_date and cp_end_date
        and   peu.event_update_id =ppe.event_update_id
        and   peu.dated_table_id = pde.dated_table_id
        and   pde.event_group_id = cp_event_group_id
        and   ppe.business_group_id = cp_business_group_id
        and   nvl(peu.column_name,1) = nvl(pde.column_name,1)
        and   decode(pde.update_type,'I','INSERT','U','UPDATE',pde.update_type) = peu.event_type
        and   peu.change_type = 'DATE_EARNED'
        and   pee.element_entry_id = ppe.surrogate_key
        and   pet.element_type_id = pee.element_type_id
        and   petei.element_type_id = pee.element_type_id
        and   petei.eei_information_category='PQP_UK_RATE_TYPE'
        and   petei.eei_information1='MX_IDWF'
        and   ppe.effective_date between pee.effective_start_date and pee.effective_end_date
    group by ppe.assignment_id ;

    cursor chk_asg_error( cp_assignment_id in number
                         ,cp_effective_date in date )
    is
    select location_code ,
           assignment_number,
           per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,cp_effective_date)
    from per_all_assignments_f paf,
         hr_locations       hrl
    where paf.assignment_id = cp_assignment_id
    and   cp_effective_date between paf.effective_start_date and paf.effective_end_date
    and   hrl.location_id = paf.location_id ;


    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;

    ln_payroll_action_id     NUMBER;
    ln_assignment_action_id  NUMBER;
    ln_assignment_iD         NUMBER;
    ln_tax_unit_id           NUMBER;

    lv_report_mode        VARCHAR2(1);
    ld_period_start_date  DATE;
    ld_period_end_date    DATE;
    ld_start_date            DATE;
    ld_end_date              DATE;
    ln_business_group_id     NUMBER;
    ln_tran_gre_id           NUMBER;
    ln_gre_id                NUMBER;
    ln_id                    NUMBER;
    ln_event_group_id        NUMBER;
    ld_effective_date        DATE;
    lv_location_code         VARCHAR2(100);
    lv_assignment_number     VARCHAR2(100);

  BEGIN

     dbg('Entering archive data ...........');
     dbg('assignment action id is ' || to_char(p_assignment_action_id) );

     lv_procedure_name       := '.archive_data';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     dbg('Get Payroll Action Id ');
     open  c_asg_action_info (p_assignment_action_id);
     fetch c_asg_action_info into ln_payroll_action_id,
                                  ln_assignment_id,
                                  ln_tax_unit_id ;
     close c_asg_action_info;
     dbg('Payroll action id' || to_char(ln_payroll_action_id) );

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Get parameter information from pay_payroll_actions table' ) ;
     get_payroll_action_info( p_payroll_action_id    => ln_payroll_action_id
                            ,p_report_mode          => lv_report_mode
                            ,p_period_start_date    => ld_period_start_date
                            ,p_period_end_date      => ld_period_end_date
                            ,p_start_date           => ld_start_date
                            ,p_end_date             => ld_end_date
                            ,p_business_group_id    => ln_business_group_id
                            ,p_tran_gre_id          => ln_tran_gre_id
                            ,p_gre_id               => ln_gre_id
                            ,p_event_group_id       => ln_event_group_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;


     if lv_report_mode = 'F' then  -- Fixed Salary

        -- get the max effective date from ppe table
        open c_get_fix_sal_date ( ln_assignment_id
                                 ,ln_business_group_id
                                 ,ld_start_date
                                 ,ld_end_date
                                 ,ln_event_group_id  ) ;

        fetch c_get_fix_sal_date into ld_effective_date ;

        close c_get_fix_sal_date ;


     elsif lv_report_mode = 'P' then  -- Bimonthly Salary

        -- set the effective_date = period_end_date

        ld_effective_date := ld_period_end_date ;

     end if ;

     -- check to see the assignment has any error as of effective date
     -- ie check asg has the valid location to scl to derive the GRE

     open chk_asg_error( ln_assignment_id
                        ,ld_effective_date  ) ;

     fetch chk_asg_error into lv_location_code,lv_assignment_number, ln_id ;

     if ln_id = -1 and ln_id = -2 then

        pay_core_utils.push_token('LOC_CODE',lv_location_code) ;
        pay_core_utils.push_token('ASG_NUMBER',lv_assignment_number) ;

        if ln_id = -1 then
           msg('Error : ' || lv_assignment_number || ' assignment ' || lv_location_code
                    || ' location is assigned to multiple GREs in the Generic Hierarchy' );
           pay_core_utils.push_message(800,'HR_MX_GRE_AMBIGUOUS','F') ;
        else

           msg('Error : ' || lv_assignment_number || ' assignment ' || lv_location_code
                    || ' location is not assigned to a GRE in the Generic Hierarchy' );
           pay_core_utils.push_message(800,'HR_MX_LOC_MISSING_GEN_HIER','F') ;

        end if;

     else
        -- no error then  call the archive_salary_details

        -- call the archive_salary_details to insert into pay_action_information table
        archive_salary_details( p_assignment_action_id  => p_assignment_action_id
                             ,p_assignment_id         => ln_assignment_id
                             ,p_effective_date        => ld_effective_date
                             ,p_tax_unit_id           => nvl(ln_gre_id,ln_tran_gre_id)
                             ,p_report_mode           => lv_report_mode
                             ,p_arch_status           => 'A'
                             ,p_arch_reason           => 'Archived'
                            ) ;

     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Exiting archive data ...........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  end archive_data;


--begin
--hr_utility.trace_on (null, 'SSAFFLSAL');

end pay_mx_ssaffl_salary;

/
