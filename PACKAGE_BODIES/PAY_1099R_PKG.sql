--------------------------------------------------------
--  DDL for Package Body PAY_1099R_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_1099R_PKG" as
 /* $Header: pyus109r.pkb 120.12.12010000.2 2008/10/29 10:04:46 kagangul ship $*/
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
   ******************************************************************   */
/*
    Name        : pyus109r.pkb
   Description  : This package defines the cursors needed to run
                     1099R Information Return Multi-Threaded

 Change List
 -----------
   Date         Name        Vers   Description
   ----         -----       -----  ------------
  08-SEP-2000   Fusman      115.0    Created
  03-OCT-2000   Fusman      115.1   Changed the Range and Action creation
                                     cursor for performance.
  18-JAN-2002   meshah      115.2   Changed the sort cursor.
  19-JAN-2002   meshah      115.3   dbdrv.
  20-JAN-2002   ahanda      115.4   Changed sort_action to pass the full
                                    date format.
  11-SEP-2002   jgoswami    115.6   Changed sort cursor , changed for update
                                    clause.
  17-SEP-2002   jgoswami    115.7   Changed action cursor , removed for update
                                    clause.

  01-09-20032   asasthan    115.8   Fixes for terminated employee
                                    Changed sort_action, removed join with paf
                                    so that terminated ees get picked and
                                    removed for update of clause.
  01-09-20032   asasthan    115.9   Nocopy changes made
  20-JAN-2003   jgoswami    115.10  Changed the action_creation cursor to
                                    check for Reduced Subject (A_WAGES) >0 from
                                    Gross (A_W2_GROSS_1099R) >0
  22-JAN-2003   jgoswami    115.11  Commented out the code which locks the Year
                                    End Pre-Process when a 1099r Paper
                                    assignment action are created.
  11-SEP-2003   jgoswami    115.12  Changed date format in sort cursor as the
                                    EFFECTIVE_DATE value in the legislative parameter
                                    is changed form DD-MON-YYYY to YYYY/MM/DD.
  16-JAN-2003   jgoswami    115.14  Changed the action_creation cursor to
                                    check for Gross (A_W2_GROSS_1099R) >0 from
                                    Reduced Subject (A_WAGES) >0.Fix bug 3381162
  14-MAR-2005   sackumar    115.15  4222032 Change in the Range Cursor removing
                                    redundant use of bind Variable (:pactid)
  14-MAR-2006   jgoswami    115.16  Changed the action_creation procedure for
                                    performance, split c_action cursor to
                                    multiple cursors and added range person
                                    functionality. Multiple cursors created are
                                    c_actions_with_location,
                                    c_actions_with_org, c_actions_with_state,
                                    c_actions_with_person,
                                    c_actions_with_assign_sql
                                    based on the SRS parameters.

  24-MAR-2006   jgoswami    115.17  fix gscc errors
  01-SEP-2006   saurgupt    115.18  Bug 3913757 : Modified the order by clause in sort_action.
  21-SEP-2006   jgoswami    115.19  fix sort cursor exceed length issue
  21-SEP-2006   jgoswami    115.20  fix gscc errors
  09-NOV-2006   alikhar     115.21  Modified for 1099R PDF. (Bug 5440136)
  24-NOV-2006   alikhar     115.22  Added tag PAYER_ADDR_CT_ST_ZP for 1099R PDF
  22-DEC-2006   alikhar     115.23  Added tag PRINT_INSTRUCTION for 1099R PDF (5717266)
  26-DEC-2006   alikhar     115.24  Fixed GSCC warnings.
  15-JUN-2007   vaprakas    115.25  5979491 Corrected the difference between paper
                                    and pdf report
  07-SEP-2007  vaprakas  115.26 Modified changes for bug fix 5979491
  21-SEP-2007  vaprakas  115.27 Modified code to display the DESIG. ROTH CONTRIB
  29-OCT-2008  kagangul	    115.28  Bug 7443863
				    Printing the YEAR parameter in the XML file
				    in order the make the Year stamp dynamic in the
				    RTF Template.
*/

/******************************************************************
  ** private package global declarations
  ******************************************************************/

  g_package               VARCHAR2(50)  := 'pay_1099r_pkg.';
  g_debug                 boolean       := FALSE;
  g_print_instr           VARCHAR2(1)   := 'Y';

----------------------------------- range_cursor -------------------------------
---
--
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  ln_assign_set  number;
  ln_year        number;
  ln_gre_id      number;
  l_procedure_name   VARCHAR2(100);
--
begin
      l_procedure_name := g_package||'range_cursor';
    --hr_utility.trace_on(null,'pyus109r');
   hr_utility.trace('Before the range cursor');
   hr_utility.trace('Entering :'||l_procedure_name);

   select pay_1099R_pkg.get_parameter('YEAR',ppa.legislative_parameters),
          pay_1099R_pkg.get_parameter('TAX_ID',ppa.legislative_parameters),
          pay_1099R_pkg.get_parameter('ASSIGN_SET',ppa.legislative_parameters)
     into ln_year,
          ln_gre_id,
          ln_assign_set
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

  --  hr_us_w2_rep.initialize_assignment_set(ln_assign_set);

    sqlstr :=
        'SELECT distinct to_number(paa_arch.serial_number)
           FROM PAY_ASSIGNMENT_ACTIONS paa_arch,
                PAY_PAYROLL_ACTIONS ppa_arch
          WHERE :pactid is not null
            AND ppa_arch.report_type = ''YREND''
            AND to_char(ppa_arch.effective_date,''YYYY'')= '''||ln_year||'''
            AND  pay_yrend_reports_pkg.get_parameter(''TRANSFER_GRE'',
                   ppa_arch.legislative_parameters)= '''||ln_gre_id||'''
            AND ppa_arch.action_status = ''C''
            AND ppa_arch.payroll_action_id = paa_arch.payroll_action_id
         order by to_number(paa_arch.serial_number) ';

    hr_utility.trace('After the range cursor');

   hr_utility.trace('Leaving :'||l_procedure_name);
end range_cursor;



---------------------------- action_creation -----------------------------

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is
-- jatin
-- new cursors start here


  lockingactid  number;
  lockedactid   number;
  assignid      number;
  greid         number;

  num           number;
  l_effective_end_date DATE;
  l_effective_date    DATE;
  l_report_type       pay_payroll_actions.report_type%type;
  l_report_category   pay_payroll_actions.report_category%type;
  l_report_qualifier  pay_payroll_actions.report_qualifier%type;
  l_report_format     pay_report_format_mappings_f.report_format%type;
  l_range_person_on   BOOLEAN;
  l_subj_whable     ff_user_entities.user_entity_name%TYPE;
  l_subj_nwhable    ff_user_entities.user_entity_name%TYPE;
  l_tuid_context    ff_contexts.context_id%TYPE;
  l_juri_context    ff_contexts.context_id%TYPE;

  l_procedure_name   VARCHAR2(100);
  l_session_date     date;
  l_year             number ;
  l_gre_id           pay_assignment_actions.tax_unit_id%type;
  l_org_id           per_assignments_f.organization_id%type;
  l_loc_id           per_assignments_f.location_id%type;
  l_per_id           per_assignments_f.person_id%type;
  l_ssn              per_people_f.national_identifier%type;
  l_state_code       pay_us_states.state_code%type;
  l_asg_set_id       number;
  l_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type;
  l_eoy_start_date   date;
  ln_gross_bal       number;


  cursor c_payroll_param (cp_pactid in number) is
  select to_number(pay_1099R_pkg.get_parameter('YEAR',ppa1.legislative_parameters)),
         to_number(pay_1099R_pkg.get_parameter('TAX_ID',ppa1.legislative_parameters)),
         to_number(pay_1099R_pkg.get_parameter('ORG_ID',ppa1.legislative_parameters)),
         to_number(pay_1099R_pkg.get_parameter('LOC_ID',ppa1.legislative_parameters)),
         to_number(pay_1099R_pkg.get_parameter('PER_ID',ppa1.legislative_parameters)),
         pay_1099R_pkg.get_parameter('SSN',ppa1.legislative_parameters),
         pay_1099R_pkg.get_parameter('ST_COD',ppa1.legislative_parameters),
         to_number(pay_1099R_pkg.get_parameter('ASSIGN_SET',ppa1.legislative_parameters)),
         ppa.effective_date,
         ppa.payroll_action_id,
         ppa.start_date,
         ppa1.effective_date,
         ppa1.report_type,
         ppa1.report_qualifier,
         ppa1.report_category
    from pay_payroll_actions ppa,   /* EOY payroll action id */
         pay_payroll_actions ppa1   /* PYUGEN payroll action id */
   where ppa1.payroll_action_id = cp_pactid
     and ppa.effective_date = ppa1.effective_date
     and ppa.report_type = 'YREND'
     and pay_1099R_pkg.get_parameter
                  ('TAX_ID',ppa1.legislative_parameters) =
                       pay_1099R_pkg.get_parameter
                                ('TRANSFER_GRE',ppa.legislative_parameters);


/*      cursor c_payroll_param (cp_pactid in number) is
           select pay_1099R_pkg.get_parameter('YEAR',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('TAX_ID',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('ORG_ID',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('LOC_ID',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('PER_ID',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('SSN',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('ST_COD',ppa.legislative_parameters),
                  pay_1099R_pkg.get_parameter('ASSIGN_SET',ppa.legislative_parameters),
                  effective_date,
                  report_type,
                  report_qualifier,
                  report_category
             from pay_payroll_actions ppa
            where ppa.payroll_action_id = cp_pactid;
*/

  /* when person or ssn  selected */
  CURSOR c_actions_with_person  is
       SELECT paa_arch.assignment_action_id,
              paa_arch.assignment_id,
              paa_arch.tax_unit_id,
         paf.effective_end_date
       FROM  per_assignments_f paf,
             pay_assignment_actions paa_arch
       WHERE paa_arch.payroll_action_id = l_eoy_payroll_action_id
         AND paa_arch.action_status = 'C'
         AND paf.PERSON_ID = l_per_id
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                           and paf2.effective_start_date <= l_session_date)
         AND paf.effective_end_date >= l_eoy_start_date
         AND paf.assignment_type = 'E'
         AND paf.person_id between stperson and endperson;

  CURSOR c_state_context (p_context_name varchar2) is
       select context_id from ff_contexts
       where context_name = p_context_name;



  CURSOR c_state_ueid (p_user_entity_name varchar2) is
       select user_entity_id
         from ff_user_entities
        where user_entity_name = p_user_entity_name
          and legislation_code = 'US';



  TYPE RefCurType is REF CURSOR;
  c_actions_no_selection    RefCurType;
  c_actions_with_location   RefCurType;
  c_actions_with_org        RefCurType;
  c_actions_with_state      RefCurType;
  c_actions_with_assign_set RefCurType;

  c_actions_no_selection_sql  varchar2(10000);
  c_actions_with_location_sql varchar2(10000);
  c_actions_with_org_sql      varchar2(10000);
  c_actions_with_state_sql    varchar2(10000);
  c_actions_with_assign_sql   varchar2(10000);

-- new cursors end here
-- jatin


   begin

      l_procedure_name := g_package||'action_creation';

    --hr_utility.trace_on(null,'pyus109r');
      hr_utility.trace('Entering :'||l_procedure_name);
      hr_utility.set_location('action_cursor',1);
      hr_utility.trace('In  the action cursor');

      open c_payroll_param(pactid);
      fetch c_payroll_param into  l_year,
                                  l_gre_id,
                                  l_org_id,
                                  l_loc_id,
                                  l_per_id,
                                  l_ssn,
                                  l_state_code,
                                  l_asg_set_id,
                                  l_session_date,
                                  l_eoy_payroll_action_id,
                                  l_eoy_start_date,
                                  l_effective_date,
                                  l_report_type,
                                  l_report_qualifier,
                                  l_report_category;

      close c_payroll_param;

    Begin
      select report_format
        into l_report_format
        from pay_report_format_mappings_f
       where report_type = l_report_type
         and report_qualifier = l_report_qualifier
         and report_category = l_report_category
         and l_effective_date between
                   effective_start_date and effective_end_date;
    Exception
       When Others Then
          l_report_format := Null ;
    End ;

    hr_utility.set_location(l_procedure_name, 2);
    l_range_person_on := pay_ac_utility.range_person_on
                                    ( p_report_type      => l_report_type,
                                      p_report_format    => l_report_format,
                                      p_report_qualifier => l_report_qualifier,
                                      p_report_category  => l_report_category);
    /* when no selection is entered */
    if((l_loc_id is null ) and
       (l_org_id is null ) and
       (l_per_id is null ) and
       (l_ssn    is null ) and
       (l_state_code is null ) and
       (l_asg_set_id is null ))       then

       hr_utility.set_location(l_procedure_name, 5);
       if l_range_person_on = TRUE Then
          hr_utility.set_location(l_procedure_name, 10);
          hr_utility.trace('Range Person ID Functionality is enabled') ;
          c_actions_no_selection_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                    paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id +0= ' || l_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                           (select max(paf2.effective_start_date)
                              from per_assignments_f paf2
                             where paf2.assignment_id = paf.assignment_id
                               and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                and paf.primary_flag = ''Y''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                and paf.person_id = to_number(paa_arch.serial_number)';
       else
          hr_utility.set_location(l_procedure_name, 15);
          c_actions_no_selection_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                    paf.effective_end_date
                    FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id +0= ' || l_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                         (select max(paf2.effective_start_date)
                            from per_assignments_f paf2
                           where paf2.assignment_id = paf.assignment_id
                             and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                and paf.primary_flag = ''Y''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                and paf.person_id = to_number(paa_arch.serial_number)';
       end if ;

       hr_utility.set_location(l_procedure_name, 20);
       OPEN c_actions_no_selection FOR c_actions_no_selection_sql;
       num := 0;

       loop
          fetch c_actions_no_selection into lockedactid,assignid,greid,l_effective_end_date;
          if c_actions_no_selection%found then
             num := num + 1;
             hr_utility.trace('In the c_actions_no_selection%found in action cursor');
          else
             hr_utility.trace('In the c_actions_no_selection%notfound in action cursor');
             exit;
          end if;

         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
         if ln_gross_bal > 0 then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
            hr_utility.set_location(l_procedure_name, 25);
            hr_utility.trace('Before inserting the action record');

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_no_selection;

      end if;
      hr_utility.set_location(l_procedure_name, 30);


      /* when location is entered */
      if l_loc_id is not null then
         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 35);
            c_actions_with_location_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                  paf.effective_end_date
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
                    /* disabling the index for performance reason  */
             WHERE  paa_arch.payroll_action_id + 0 = ' || l_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || l_session_date || ''')
                    between paf.effective_start_date
                    and paf.effective_end_date
               AND  paf.location_id = ' || l_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id' ;
         else
            hr_utility.set_location(l_procedure_name, 40);
            c_actions_with_location_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch
              /* disabling the index for performance reason  */
             WHERE  paa_arch.payroll_action_id + 0 = ' || l_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || l_session_date || ''')
                    between paf.effective_start_date
                    and paf.effective_end_date
               AND  paf.location_id = ' || l_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || l_session_date || ''' )
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND paf.person_id between ' || stperson || ' and ' || endperson || '';
         end if ;

         hr_utility.set_location(l_procedure_name, 40);
         OPEN c_actions_with_location FOR c_actions_with_location_sql;
         num := 0;

         loop
            fetch c_actions_with_location into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_location%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_location%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_location%notfound in action cursor');
              exit;
            end if;

         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
         if ln_gross_bal > 0 then

            hr_utility.set_location(l_procedure_name, 45);
            hr_utility.trace('Before inserting the action record');

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_with_location;

      end if;
      hr_utility.set_location(l_procedure_name, 50);


      /* when org is entered */
      if l_org_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 60);
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_org_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
              /* disabling the index for performance reason */
             WHERE  paa_arch.payroll_action_id +0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND nvl(pps.final_process_date,''' || l_session_date || ''')
                    between paf.effective_start_date
                    and paf.effective_end_date
                AND paf.organization_id = ' || l_org_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                      (select max(paf2.effective_start_date)
                       from per_assignments_f paf2
                       where paf2.assignment_id = paf.assignment_id
                       and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id';
         else
            hr_utility.set_location(l_procedure_name, 70);
            c_actions_with_org_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch
              /* disabling the index for performance reason */
             WHERE  paa_arch.payroll_action_id +0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND nvl(pps.final_process_date,''' || l_session_date || ''')
                    between paf.effective_start_date
                    and paf.effective_end_date
                AND paf.organization_id = ' || l_org_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                      (select max(paf2.effective_start_date)
                       from per_assignments_f paf2
                       where paf2.assignment_id = paf.assignment_id
                       and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND paf.person_id between ' || stperson || ' and ' || endperson ||'';
         end if ;

         hr_utility.set_location(l_procedure_name, 80);
         OPEN c_actions_with_org FOR c_actions_with_org_sql;
         num := 0;

         loop
            fetch c_actions_with_org into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_org%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_org%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_org%notfound in action cursor');
              exit;
            end if;


         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
         if ln_gross_bal > 0 then

            hr_utility.set_location(l_procedure_name, 90);
            hr_utility.trace('Before inserting the action record');

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_with_org;

      end if;

      hr_utility.set_location(l_procedure_name, 100);

      /* when person or SSN is entered */

      if (l_ssn is not null and l_per_id is null ) then
          select person_id into l_per_id
            from per_people_f ppf
           where national_identifier = l_ssn
             and l_effective_date between effective_start_date
                                      and effective_end_date;
      end if;

      if (l_per_id is not null ) then
         open c_actions_with_person;
         num := 0;
         loop
            hr_utility.set_location('procpyr',2);
            hr_utility.trace('after  the loop in c_actions_with_person');
            fetch c_actions_with_person into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_person%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_person%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_person%notfound in action cursor');
              exit;
            end if;

         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
         if ln_gross_bal > 0 then

            hr_utility.set_location(l_procedure_name, 110);
            hr_utility.trace('Before inserting the action record');

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_with_person;

      end if;

      hr_utility.set_location(l_procedure_name, 120);
      /* when state is entered */
      if l_state_code is not null then
         hr_utility.set_location(l_procedure_name, 130);

         hr_utility.trace('l_state_code  = ' || l_state_code);
         open c_state_context('TAX_UNIT_ID');
         fetch c_state_context into l_tuid_context;
         close c_state_context;

         open c_state_context('JURISDICTION_CODE');
         fetch c_state_context into l_juri_context;
         close c_state_context;

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 140);
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_state_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
             WHERE  paa_arch.payroll_action_id +0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                       (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                         where paf2.assignment_id = paf.assignment_id
                           and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id ';
         else
            hr_utility.set_location(l_procedure_name, 150);
            c_actions_with_state_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch
             WHERE  paa_arch.payroll_action_id +0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                       (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                         where paf2.assignment_id = paf.assignment_id
                           and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson;
         end if;

         hr_utility.set_location(l_procedure_name, 160);

            open c_state_ueid('A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_whable;
            close c_state_ueid;

            open c_state_ueid('A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_nwhable;
            close c_state_ueid;

            hr_utility.set_location(l_procedure_name, 170);
            c_actions_with_state_sql := c_actions_with_state_sql ||
                ' AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in (' || l_subj_whable || ',
                                                          ' || l_subj_nwhable || ')
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || l_state_code || ' ))';
         --
         hr_utility.set_location(l_procedure_name, 210);


         num := 0;
         OPEN c_actions_with_state FOR c_actions_with_state_sql;
         loop
            fetch c_actions_with_state into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_state%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_state%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_state%notfound in action cursor');
              exit;
            end if;


         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
         if ln_gross_bal > 0 then

            hr_utility.set_location(l_procedure_name, 220);
            hr_utility.trace('Before inserting the action record');

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_with_state;

      end if;
      hr_utility.set_location(l_procedure_name, 230);

      /* when assignment set is entered */
      if l_asg_set_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 240);
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_assign_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || l_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'')';
         else
            hr_utility.set_location(l_procedure_name, 250);
            c_actions_with_assign_sql :=
         'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                   paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || l_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || l_session_date || ''')
                AND paf.effective_end_date >= ''' || l_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || l_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'')';
        end if ;

        hr_utility.set_location(l_procedure_name, 260);
        OPEN c_actions_with_assign_set FOR c_actions_with_assign_sql;
        num := 0;

         loop
            fetch c_actions_with_assign_set into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_assign_set%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_assign_set%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_assign_set%notfound in action cursor');
              exit;
            end if;


         ln_gross_bal :=  hr_us_w2_rep.get_w2_arch_bal(
                                  lockedactid,
                                  'A_W2_GROSS_1099R',
                                  greid,
                                  '00-000-0000',
                                  0);

         -- we need to create assignment_actions only if the GROSS
         -- is greater than ZERO.
         hr_utility.trace('Before IF Check for GROSS > 0 ');
           if ln_gross_bal > 0 then

            hr_utility.set_location(l_procedure_name, 270);
            hr_utility.trace('Before inserting the action record');

            hr_utility.set_location('procpyr',3);

            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- insert the action record.
            hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

            -- Update serial_numbrt of Pay_assignment_actions with the
            -- assignment_action_id .
            update pay_assignment_actions
            set serial_number = lockedactid
            where assignment_action_id = lockingactid;
            end if;
         end loop;
         close c_actions_with_assign_set;

      end if;

      hr_utility.set_location(l_procedure_name, 300);
/* } 4946225 */

      hr_utility.trace('End of the action cursor');
      hr_utility.trace('Leaving :'||l_procedure_name);

end action_creation;

---------------------------------- sort_action ------------------------------

procedure sort_action
(
   payactid   in     varchar2,     /* payroll action id */
   sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
   len        out nocopy number        /* length of the sql string */
) is

--l_session_date    varchar2(11);
l_session_date    varchar2(11);
l_effective_date  varchar2(11);
l_procedure_name   VARCHAR2(100);

   begin
      l_procedure_name := g_package||'sort_action';
      hr_utility.trace('Entering :'||l_procedure_name);
     hr_utility.trace('Beginning of the sort_action cursor');
     select to_char(ppa.effective_date, 'DD-MON-YYYY'),
            to_char(fnd_date.canonical_to_date(pay_1099R_pkg.get_parameter('EFFECTIVE_DATE',
                    ppa.legislative_parameters)),'DD-MON-YYYY')
       into l_effective_date, l_session_date
       from pay_payroll_actions ppa
      where payroll_action_id = payactid;

     if to_date(l_session_date,'DD-MM-YYYY') > to_date(l_effective_date,'DD-MM-YYYY') then
        l_effective_date := l_session_date;
     end if;

     sqlstr :=
     'select paa1.rowid
              /* we need the row id of the assignment actions
                 that are created by PYUGEN */
           from pay_assignment_actions paa,
                pay_assignment_actions paa1, /* PYUGEN assignment action */
                pay_payroll_actions    ppa1  /* PYUGEN payroll action id */
          where ppa1.payroll_action_id = :pactid
            and paa1.payroll_action_id = ppa1.payroll_action_id
            and paa.assignment_action_id = paa1.serial_number
order by
 decode(pay_1099R_pkg.get_parameter(''SORT_1'',ppa1.legislative_parameters),
''Employee_Name'',
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES'' ),
       null, null,
       substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1)),
''Social_Security_Number'',
nvl(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_NATIONAL_IDENTIFIER''),''Applied For''),
''Zip_Code'',
hr_us_w2_rep.get_w2_postal_code(to_number(paa.serial_number),to_date('''||l_effective_date||''',''DD-MM-YYYY'')),
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item( paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),
       null, null,
       substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1))),
decode(pay_1099R_pkg.get_parameter(''SORT_2'',ppa1.legislative_parameters),
''Employee_Name'',
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES'' ),
       null, null,
       substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1)),
''Social_Security_Number'',
nvl(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
''Zip_Code'',
hr_us_w2_rep.get_w2_postal_code( to_number(paa.serial_number),
                                 to_date('''||l_effective_date||''',''DD-MM-YYYY'')),
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item( paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),
             null, null,
             substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1))),
decode(pay_1099R_pkg.get_parameter(''SORT_3'',ppa1.legislative_parameters),
''Employee_Name'',
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES'' ),
       null, null,
       substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1)),
''Social_Security_Number'',
nvl(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
''Zip_Code'',
hr_us_w2_rep.get_w2_postal_code( to_number(paa.serial_number),
                                 to_date('''||l_effective_date||''',''DD-MM-YYYY'')),
hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_LAST_NAME'') ||
hr_us_w2_rep.get_per_item( paa.assignment_action_id,''A_PER_FIRST_NAME'') ||
decode(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),
       null, null,
       substr(hr_us_w2_rep.get_per_item(paa.assignment_action_id,''A_PER_MIDDLE_NAMES''),1,1)))';

       len := length(sqlstr); -- return the length of the string.
       hr_utility.trace('length of Sort Cursor '||len);

       hr_utility.trace('End of the sort_Action cursor');
      hr_utility.trace('Leaving :'||l_procedure_name);
   end sort_action;
--
------------------------------ get_parameter -------------------------------
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;

-------------------------- load_xml ----------------------------
PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    l_proc_name     varchar2(100) := 'pay_1099r_pkg.load_xml';
    l_data          varchar2(500);
BEGIN

    hr_utility.trace('Entering : '||l_proc_name);

    IF p_node_type = 'CS' THEN
        pay_core_files.write_to_magtape_lob('<'||p_node||'>');
    ELSIF p_node_type = 'CE' THEN
        pay_core_files.write_to_magtape_lob('</'||p_node||'>');
    ELSIF p_node_type = 'D' THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        pay_core_files.write_to_magtape_lob('<'||p_node||'>'||l_data||'</'||p_node||'>');
    END IF;

    hr_utility.trace('Leaving : '||l_proc_name);

END LOAD_XML;

------------------------------ generate_header_xml -------------------------------
PROCEDURE generate_header_xml is

l_proc_name varchar2(50) := 'pay_1099r_pkg.generate_header_xml';

BEGIN
      hr_utility.trace('Entering : '||l_proc_name);

      load_xml('CS','US_1099R','');
      load_xml('CE','US_1099R','');

      hr_utility.trace('Leaving : '||l_proc_name);


END generate_header_xml;

------------------------------ generate_footer_xml -------------------------------

PROCEDURE generate_footer_xml is
l_proc_name varchar2(50) := 'pay_1099r_pkg.generate_footer_xml';

BEGIN
      hr_utility.trace('Entering : '||l_proc_name);

      load_xml('CS','US_1099R','');
      load_xml('CE','US_1099R','');

      hr_utility.trace('Leaving : '||l_proc_name);


END generate_footer_xml;

------------------------------ get_person_address -------------------------------

PROCEDURE get_person_address(p_fed_aaid         in number,
                             p_effective_date   in date,
                             p_year_end_date    in date,
                             p_addr_line1       out nocopy varchar2,
                             p_addr_line2       out nocopy varchar2,
                             p_city_state_zip   out nocopy varchar2) IS

CURSOR c_person_id IS
   SELECT to_number(serial_number)
   FROM pay_assignment_actions
   WHERE assignment_action_id = p_fed_aaid;

addr pay_us_get_item_data_pkg.person_name_address;

l_employee_address   VARCHAR2(300);
l_address_line1      per_addresses.address_line1%TYPE;
l_address_line2      per_addresses.address_line2%TYPE;
l_address_line3      per_addresses.address_line3%TYPE;
l_town_or_city       per_addresses.town_or_city%TYPE;
l_province_or_state  per_addresses.region_1%TYPE;
l_region_1           per_addresses.region_1%TYPE;
l_region_2           per_addresses.region_2%TYPE;
l_postal_code        per_addresses.postal_code%TYPE;
l_country            per_addresses.country%TYPE;
l_country_name       varchar2(240);
l_person_id          per_people_f.person_id%type;
l_validate           varchar2(1) := 'Y';

BEGIN

     open c_person_id;
     fetch c_person_id into l_person_id;
     close c_person_id;

-- p_effective_date is the session_date and
-- p_year_end_date will be the last day of the year for which the report is run.
-- we want to fetch the address as of 31-dec if the session date is less than 31-dec of the year.

   addr := pay_us_get_item_data_pkg.GET_PERSON_NAME_ADDRESS(
                                 'REPORT',
                                 l_person_id,
                                 NULL,
                                 p_year_end_date,
                                 p_effective_date,
                                 l_validate,
                                 NULL);

   l_address_line1      := addr.addr_line_1;
   l_address_line2      := addr.addr_line_2;
   l_address_line3      := addr.addr_line_3;
   l_town_or_city       := addr.city;
   l_province_or_state  := addr.province_state;
   l_region_1           := addr.region_1;
   l_region_2           := addr.region_2;
   l_postal_code        := addr.postal_code;
   l_country            := addr.country;
   l_country_name       := addr.country_name;

   if l_address_line1 is not null then
      p_addr_line1  := rpad(substr(l_address_line1,1,30),31,' ');
   end if;

   if l_address_line2 is not null then
      p_addr_line2 := rpad(substr(l_address_line2,1,30),31,' ');

   else
     /* address_line2 is null then show addres_line3 if address_line3
        is not null else address_line2 is blank.
     */
      if l_address_line3 is not null then
         p_addr_line2 := rpad(substr(l_address_line3,1,30),31,' ');
      end if;
   end if;

   if l_town_or_city is not null then
       if l_country = 'CA' then
         p_city_state_zip := substr(l_town_or_city,1,23)||' ';
       else
         p_city_state_zip := substr(l_town_or_city,1,29)||' ';
       end if;
   end if;

   if l_province_or_state is not null then
      p_city_state_zip := p_city_state_zip||substr(l_province_or_state,1,2)||' ';
   end if;

   if l_postal_code is not null then
      p_city_state_zip := p_city_state_zip||substr(l_postal_code,1,10);
   end if;

   if l_country = 'CA' then
      p_city_state_zip := p_city_state_zip||' '||substr(l_country_name,1,6);
   end if;

End get_person_address;

------------------------------ gen_state_tax_details -------------------------------

PROCEDURE gen_state_tax_details (p_asg_actid in number,
                                 pactid      in number) is

CURSOR c_state_tax  IS
SELECT  tax_unit_id st_tax_unit_id,
               assignment_id st_assign_id,
               decode(state_abbrev, 'NJ', state_abbrev||nvl(replace(replace(state_ein,'-'),'/'),'NO STATE EIN'), state_abbrev||' '||nvl(state_ein,'NO STATE EIN')) state_ein,
               w2_box_17 sit_subject,
               w2_box_18 sit_withheld
FROM
           pay_us_w2_state_v pws
WHERE  state_abbrev  NOT IN ( 'AK','FL', 'NH','NV','SD','TN','TX','WA','WY')
AND (w2_box_17 <> 0 OR w2_box_18 <> 0)
AND assignment_action_id = p_asg_actid
AND payroll_action_id = pactid
ORDER BY state_abbrev;

l_count number;

BEGIN

    l_count := 0;

    For i in c_state_tax loop

   if l_count = 0 then
      load_xml('D','SIT_WH',i.sit_withheld);
      load_xml('D','STATE_EIN',i.state_ein);
      load_xml('D','STATE_DIST',i.sit_subject);
   else
      load_xml('D','SIT_WH1',i.sit_withheld);
      load_xml('D','STATE_EIN1',i.state_ein);
      load_xml('D','STATE_DIST1',i.sit_subject);
   end if;

   l_count := l_count + 1;
   if l_count >= 2 then
      Exit;
   end if;

    End Loop;

END gen_state_tax_details;

------------------------------ gen_loc_tax_details -------------------------------

PROCEDURE gen_loc_tax_details (p_asg_actid   in number,
                               pactid        in number) is

CURSOR c_locality_tax IS
SELECT  locality_name,
        assignment_id lit_assign_id,
        tax_unit_id lit_tax_unit_id,
        w2_box_20 lit_subject,
        w2_box_21 lit_withheld
FROM
        pay_us_w2_locality_v
WHERE
        w2_box_21 <> 0
AND assignment_action_id = p_asg_actid
AND payroll_action_id = pactid;

l_count number;

BEGIN

    l_count := 0;

    For i in c_locality_tax loop
      if l_count = 0 then
         load_xml('D','LIT_WH',i.lit_withheld);
         load_xml('D','NAME_LOCAL',i.locality_name);
         load_xml('D','LOCAL_DIST',i.lit_subject);
      else
         load_xml('D','LIT_WH1',i.lit_withheld);
         load_xml('D','NAME_LOCAL1',i.locality_name);
         load_xml('D','LOCAL_DIST1',i.lit_subject);
      end if;

      l_count := l_count + 1;
      if l_count >= 2 then
         Exit;
      end if;

    End Loop;

END gen_loc_tax_details;

------------------------------ generate_detail_xml -------------------------------
PROCEDURE generate_detail_xml IS

CURSOR csr_get_details (p_asg_actid in number) IS
SELECT
to_number(pay_1099R_pkg.get_parameter('YREND_PACTID',ppa.legislative_parameters)) yrend_pactid,
to_number(paa.serial_number) fed_aaid,
v1099r.year year,
v1099r.gross_1099r gross_1099r,
v1099r.wages_tips_compensation fit_subject,
v1099r.taxable_amt_1099r taxable_amt_1099r,
v1099r.fed_it_withheld fit_withheld,
v1099r.ssn ssn,
v1099r.first_name ||' '||v1099r.middle_name||' ' ||v1099r.pre_name_adjunt ||' '||v1099r.last_name employee_name,
v1099r.federal_ein federal_ein,
v1099r.tax_unit_name tax_unit_name,
 rpad(substr(hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ADDR1'),1,30),31,' ')
      ||decode( hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ADDR2'),null,null,
        rpad(substr( hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ADDR2') ,1,30),31,' '))
      ||decode( hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ADDR3') ,null,null,
        rpad(substr( hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ADDR3') ,1,30),31,' ')) tax_unit_address,
 substr( hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'CITY') ,1,29)||', '||
     hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'STATE') ||' '||
     hr_us_w2_rep.get_tax_unit_addr_line(paa.tax_unit_id,'ZIP') ct_st_zp,
decode(v1099r.taxable_amount_unknown,'Y','X',null) taxable_amt_unknown,
decode(v1099r.total_distributions,'Y','X',null) total_distributions,
v1099r.employee_distribution_percent ee_dstr_pr,
v1099r.total_distribution_percent tot_dstr_pr,
v1099r.capital_gain,
v1099r.ee_contributions_or_premiums ee_cont_prem,
v1099r.unrealized_net_er_security un_net_er,
v1099r.other_ee_annuity_contract_amt ee_anuity,
v1099r.total_ee_contributions tot_ee_contr,
nvl(hr_us_w2_rep.get_per_item(v1099r.assignment_action_id, 'A_DISTRIBUTION_CODE_FOR_1099R'),'7') ee_distribution_code,
v1099r.defferal_year defferal_year
from
PAY_ASSIGNMENT_ACTIONS PAA, --PYUGEN
PAY_PAYROLL_ACTIONS PPA, --PYUGEN
PAY_US_WAGES_1099r_v v1099r
 WHERE
 paa.assignment_action_id = p_asg_actid
 AND ppa.payroll_action_id = paa.payroll_action_id
 AND paa.serial_number = v1099r.assignment_action_id;


  CURSOR c_parameters (asg_actid in NUMBER) IS
   SELECT ppa.legislative_parameters,
          fnd_date.canonical_to_date(pay_1099r_pkg.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters)),
          pay_1099r_pkg.get_parameter('PRINT_INSTRUCTION',ppa.legislative_parameters)
     FROM pay_payroll_actions ppa,
     pay_assignment_actions paa
    WHERE paa.assignment_action_id = asg_actid
    and ppa.payroll_action_id = paa.payroll_action_id;

l_assignment_action_id	number;

l_yrend_pactid          number;
l_fed_aaid              number;
l_year                  number;
l_gross_1099r           number;
l_fit_subject           number;
l_taxable_amt_1099r     number;
l_fit_withheld          number;
l_ssn                   per_all_people_f.national_identifier%TYPE;
l_employee_name         per_all_people_f.full_name%TYPE;
l_federal_ein           varchar2(50);
l_tax_unit_name         varchar2(100);
l_tax_unit_address      varchar2(100);
l_ct_st_zp              varchar2(100);
l_taxable_amt_unknown   varchar2(3);
l_total_distributions   varchar2(3);
l_ee_dstr_pr            number;
l_tot_dstr_pr           number;
l_capital_gain          number;
l_ee_cont_prem          number;
l_un_net_er             number;
l_ee_anuity             number;
l_tot_ee_contr          number;
l_ee_distribution_code  varchar2(50);
l_addr_line1            per_addresses.address_line1%TYPE;
l_addr_line2            per_addresses.address_line2%TYPE;
l_city_state_zip        varchar2(100);
l_eff_date              date;
l_leg_param             pay_payroll_actions.legislative_parameters%TYPE;
l_st_tax_unit_id        number;
l_st_assign_id          number;
l_state_ein             varchar2(50);
l_sit_subject           number;
l_sit_withheld          number;
l_locality_name         varchar2(100);
l_lit_assign_id         number;
l_lit_tax_unit_id       number;
l_lit_subject           number;
l_lit_withheld          number;
l_defferal_year         varchar2(100);

BEGIN

   l_assignment_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

   open c_parameters(l_assignment_action_id);
   fetch c_parameters into
      l_leg_param,
      l_eff_date,
      g_print_instr;
   close c_parameters;

   IF (g_print_instr IS NULL) OR (g_print_instr = '') THEN
       g_print_instr := 'Y';
   END IF;

   open csr_get_details(l_assignment_action_id);
   fetch csr_get_details into
      l_yrend_pactid,
      l_fed_aaid,
      l_year,
      l_gross_1099r,
      l_fit_subject,
      l_taxable_amt_1099r,
      l_fit_withheld,
      l_ssn,
      l_employee_name,
      l_federal_ein,
      l_tax_unit_name,
      l_tax_unit_address,
      l_ct_st_zp,
      l_taxable_amt_unknown,
      l_total_distributions,
      l_ee_dstr_pr,
      l_tot_dstr_pr,
      l_capital_gain,
      l_ee_cont_prem,
      l_un_net_er,
      l_ee_anuity,
      l_tot_ee_contr,
      l_ee_distribution_code,
      l_defferal_year;
   close csr_get_details;

   -- bug 5979491
   if l_taxable_amt_unknown = 'X'
   then
   l_taxable_amt_1099r := '';
   end if;
   -- end bug 5979491

   /* Get Person Address*/
   get_person_address(l_fed_aaid,
         l_eff_date,
         fnd_date.canonical_to_date(to_char(l_year)||'/12/31'),
         l_addr_line1,
         l_addr_line2,
         l_city_state_zip);

   load_xml('CS','G_EMPLOYEE','');
   load_xml('D','GROSS_DIST',l_gross_1099r);
   load_xml('D','TAX_AMT',l_taxable_amt_1099r);
   load_xml('D','TAX_AMT_ND', l_taxable_amt_unknown);
   load_xml('D','TOT_DIST', l_total_distributions);
   load_xml('D','PAYER_NAME',l_tax_unit_name);
   load_xml('D','PAYER_ADDRESS',l_tax_unit_address);
   load_xml('D','PAYER_ADDR_CT_ST_ZP',l_ct_st_zp);
   load_xml('D','PAYER_FEIN',l_federal_ein);
   load_xml('D','EMP_SSN',l_ssn);
   load_xml('D','EMP_NAME',l_employee_name);
   load_xml('D','EMP_ADDR_LN1',l_addr_line1);
   load_xml('D','EMP_ADDR_LN2',l_addr_line2);
   load_xml('D','EMP_ADDR_CT_ST_ZP',l_city_state_zip);
   load_xml('D','CAP_GAIN',l_capital_gain);
   load_xml('D','FIT_WH',l_fit_withheld);
   load_xml('D','EMP_CONTR_INS',l_ee_cont_prem);
   load_xml('D','NET_APPR_ER_SEC',l_un_net_er);
   load_xml('D','DIST_CODE',l_ee_distribution_code);
   load_xml('D','IRA_SEP_SIMP',' ');
   load_xml('D','OTHER',l_ee_anuity);
   load_xml('D','PERCENT',l_ee_dstr_pr);
   load_xml('D','PERC_TOTL_DIST',l_tot_dstr_pr);
   load_xml('D','TOT_EE_CONTR',l_tot_ee_contr);
   load_xml('D','FIRST_YR_ROTH',l_defferal_year);

   gen_state_tax_details(l_fed_aaid,l_yrend_pactid);
   gen_loc_tax_details(l_fed_aaid,l_yrend_pactid);
   load_xml('D','PRINT_INSTRUCTION',g_print_instr);
   /* Bug 7443863 : Start */
   load_xml('D','YEAR',l_year);
   /* Bug 7443863 : End */
   load_xml('CE','G_EMPLOYEE','');

END generate_detail_xml;

--begin

--hr_utility.trace_on(null, 'pyus109r');

end pay_1099R_pkg;

/
