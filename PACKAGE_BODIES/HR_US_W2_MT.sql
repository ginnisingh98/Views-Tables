--------------------------------------------------------
--  DDL for Package Body HR_US_W2_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_W2_MT" AS
/* $Header: pyusw2mt.pkb 120.13.12010000.9 2010/02/11 01:20:08 asgugupt ship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : pyusw2mt.pkb
Description : This package contains functions and procedures which are
              used to return values for the W2 US Payroll reports.

Change List
-----------

Version Date      Author     ER/CR No. Description of Change
-------+---------+----------+---------+--------------------------
 40.0             AAsthana             Created for multi-threaded report.
115.4   20-JUL-01 irgonzal             Modified action_creation and sort_
                                       action procedures. Bug fixes:
                                       1850043, 1488083, 1894165.
115.5   01-AUG-01 irgonzal             Modified ACTION_CREATION cursor:
                                       Removed a)'order by' and 'for update'
                                       clauses, b) calls to hr_us_w2_rep
                                       functions (added queries to retrieve
                                       the values).
                                       Modified RANGE_CURSOR and removed
                                       calls to get_parameter function.

115.6   10-AUG-01 irgonzal             Modified action_creation cursor and
                                       removed reference to
                                       hr_us_w2_rep.get_w2_arch_bal function.
115.7   30-AUG-01 irgonzal             Modified range_cursor and added
                                       condition that includes :payroll_action_id
                                       parameter.
                                       Remove identation in SORT cursor.
                                       Replaced 'YEAR' by 'Year'.
115.9   31-AUG-01 ssarma               added to_char to tax_unit_id join to
                                       fic1.context
115.10  09-SEP-01 kthirmiy             added ppa.payroll_action_id in the action_creation
                                       procedure while selecting the l_eoy_payroll_action_id
                                       Also changed to ppa.effective_date=ppa1.effective_date
                                       instead of
			               ppa.effective_date = to_date('31-DEC-'||
                                       hr_us_w2_mt.get_parameter
                                          ('Year',ppa1.legislative_parameters), 'DD-MON-YYYY')
115.11  11-DEC-01 meshah               changed the assignment_action cursor for
                                       performance reason. There was a dramatic performance
                                       gain at inhouse. No each selection criteria are
                                       a seperate cursor.
115.14  12-DEC-01 rsirigir             GSCC COMPLIANCE CHECK, added
                                       REM checkfile:~PROD:~PATH:~FILE
                                       changed date format from
                                       select to_date('31-DEC-'||to_char(l_year),
                                       'DD-MON-YYYY')  to
                                       select to_date('31-DEC-'||to_char(l_year),
                                       'DD/MM/YYYY')
                                       changed date format from
                                       where to_date('31-DEC-'||to_char(l_year),'DD-MON-YYYY')
                                             > l_dt  to
                                       where to_date('31-DEC-'||to_char(l_year),'DD/MM/YYYY')
                                                > l_dt

115.15  10-Jan-02 kthirmiy             For TAR 1874418.995 to improve performance changed in
                                       sort_action function . Removed the tables
                                       pay_payroll_actions ppa_arch and
                                       pay_assignment_actions and to go directly to
                                       pay_assignment_actions mt table.
115.16 18-JAN-02  meshah               changed the sort cursor again. Need to fetch
                                       zip code for the live address.
115.20 12-FEB-02  meshah               changed the action_creation cursor. Now seperate
                                       procedures are called for Employee and Employer
                                       W2. This is because state paramter is required
                                       for Employer W2 and optional for Employee W2.
115.21 19-Aug-02  fusman               Added Puerto Rico W-2 report type.
115.22 10-SEP-02  kthirmiy             Added hr_us_w2_rep.get_agent_tax_unit_id
                                       for Agent GRE setup validation check
                                       in the range_cursor
115.23 11-SEP-02  kthirmiy             changed ppa1.report_type instead of ppa.report_type
                                       changed update of mt.assignment_action_id instead of
                                       paf.assignment_id in sort_action
115.24 12-Sep-02  fusman               Bug:2565342
                                       Changed the ssn datatype from number to varchar2.
115.25 17-SEP-02  kthirmiy             Removed Pre-Process Check - Agent GRE setup
                                       for Bug 2573499
115.26 31-JUL-03  meshah     2576942   modified cursors c_actions_with_location,
                                       c_actions_with_org and c_actions_with_state.
                                       A new cursor c_state_ueid has been created to
                                       fetch the user_entity_id only once.
                                       Same cursors have been modified for ee and er.
115.26 08-AUG-03  meshah     3052020   passing report_type as a parameter to
                                       action_creation_for_ee. We do not print paper
                                       W2 for employee who have opted not to receive a
                                       paper W2.
115.28 29-SEP-03  meshah               backed out the call to
                                       pay_us_employee_payslip_web.
115.29 03-OCT-03  meshah               changed the c_actions_no_selection cursor for
                                       ee and er for performance reason.
115.30 20-JUL-2004  asasthan NO CODE CHANGES Only comments have been added
                                             BUG: 3343607, 3624090
                                             Changes for action_creation
                                             with state and org was done
                                             by meshah earlier.
                                             Action Creation with SSN
                                             seems to be taking optimal
                                             path.
                                             Sort Action: put on hold
                                             after discussing with meshah.
115.31 30-JUL-2004  asasthan 3343607   cursor c_actions_with_ssn is not
                                       used at all. Removing the cursor
                                       from the code for EE W2 Report.
115.32 03-RAUG2004  asasthan 3343607   cursor c_actions_with_ssn is not
                                       used for ER W2 Report. Removing
                                       cursor and commented out code.
115.34 06-AUG-2004  rsethupa 3052020   Changes for optionally printing W2
115.35 19-AUG-2004  meshah             there was a to_char on serial_number
                                       when comparing with person_id.
                                       this will cause the package to be
                                       invalid on 8.1.7.4x DB. Changed to
                                       to_number.
115.36 01-SEP-2004  asasthan 3052020   Employer W2 should print
                                       irrespective of Self-Service
                                       Preferences set for W2.
115.37 14-MAR-2005  sackumar 4222032   Change in the Range Cursor removing redundant
				       use of bind Variable (:payroll_action_id)
115.40 24-AUG-2005  pragupta 4152323   Range Person ID functionality enhancement:
                                       The cursors for action_creation_for_ee and
                                       action_creation_for_er have been replaced by
                                       ref cursors. The aim is to improve the
                                       performance of the cursor queries.
115.41 07-SEP-2005  ynegoro  2538173   Support new parameter, locality
115.42 12-SEP-2005  sodhingr 3688789   Added W2_XML report format for action
                                       creation
115.43 21-SEP-2005  ahanda             Changed action creation to support
                                       locality
115.44 22-SEP-2005  ahanda             Changed select stmt for locality param.
115.55 26-OCT-2005  kvsankar 4645408   Added the check for the User Entity
                                       'A_CITY_WK_WITHHELD_PER_JD_GRE_YTD'
                                       as employees who have both Wages and Taxes
                                       withheld should only be reported for the
                                       specified locality
115.46 04-JAN-2006  pragupta 4886044   Added the check for the User Entity
                                       'A_COUNTY_WITHHELD_PER_JD_GRE_YTD'
                                       and 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
                                       as employees who have both Wages and Taxes
                                       withheld should only be reported for the
                                       specified locality
115.47 24-JAN-2006  asasthan 4951715   Removed suppression of index
                                       on per_assignments_f in sort cursor
115.48 10-AUG-2006  sodhingr 5169849   Changed action_creation for EE report to
                                       print the W-2 for terminated EE only
115.49 29-AUG-2006  saurgupt 5169849   Changed the function action_creation_term_ee. Removed
                                       condition which checks that the actual_termination_date should
                                       be between eoy_start_date and session_date.
115.50 07-SEP-2006  jdevasah 5513289   Commented the cursor c_actions_with_person of
				       action_creation_for_ee procedure. This cursor is
				       no longer required since this is replaced by a dymanic
				       cursor.
115.51 20-02-2008  svannian  6809739   action creation cursor of ER will pick up employees
                                       when either sit wages or sit tax is greater than zero
115.53 23-12-2008  svannian  7604712   Employee terminated in the year after the reporting year should
                                       also be picked up in the Employeer W2 and Employer W2
115.54 02-02-2009  svannian  8216180   all assignments archived should be picked by W2,
                                       not only the primary assignments.
115.55 08-JUL-2009  skpatil  6712851   Included EMP_W2PDF to be called for action_creation_forer
115.56 31-Jul-2009  skpatil  6712851   Included functionality of printing terminated ee for ER W2 PDF
115.57 14-Sep-2009  kagangul 8353425   Display name of the employee based on the application session date.
115.58 09-Feb-2009  asgugupt  9048249  Inserted space between from and where clause
********************************************************************************/

----------------------------------- range_cursor -------------------------------
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_eoy_payroll_action_id pay_payroll_actions.payroll_action_id%type;

  l_business_group_id  pay_payroll_actions.business_group_id%type;

  l_agent_tax_unit_id  pay_assignment_actions.tax_unit_id%type;
  l_error_mesg         varchar2(100);
  l_year               number ;
  l_report_type        varchar2(30) ;

begin

   l_error_mesg := null ;

   begin
     select ppa.payroll_action_id
          , ppa.business_group_id
          , to_number(hr_us_w2_mt.get_parameter('Year',ppa1.legislative_parameters))
          , ppa1.report_type
     into   l_eoy_payroll_action_id
           ,l_business_group_id
           ,l_year
           ,l_report_type
     from pay_payroll_actions ppa,   /* EOY payroll action id */
          pay_payroll_actions ppa1   /* PYUGEN payroll action id */
    where ppa1.payroll_action_id = pactid
      and ppa.effective_date = ppa1.effective_date
      and ppa.report_type = 'YREND'
      and hr_us_w2_mt.get_parameter
                 ('GRE_ID',ppa1.legislative_parameters) =
                            hr_us_w2_mt.get_parameter
                                ('TRANSFER_GRE',ppa.legislative_parameters);
   exception
     when others then
      hr_utility.trace('Legislative parameters not found for pactid '||to_char(pactid));
      raise;
   end;

   -- If it is not a PR W2 Report then only do the preprocess Agent GRE check
   if l_report_type <> 'PRW2PAPER' then
      hr_utility.trace('Checking for Preprocess Agent GRE setup');
      hr_us_w2_rep.get_agent_tax_unit_id ( l_business_group_id
                                       ,l_year
                                       ,l_agent_tax_unit_id
                                       ,l_error_mesg   ) ;

      if l_error_mesg is not null then

         if substr(l_error_mesg,1,45) is not null then
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',' ');
            pay_core_utils.push_token('description',substr(l_error_mesg,1,45));
         end if;

         if substr(l_error_mesg,46,45) is not null then
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',' ');
            pay_core_utils.push_token('description',substr(l_error_mesg,46,45));
         end if;

         if substr(l_error_mesg,91,45) is not null then
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',' ');
            pay_core_utils.push_token('description',substr(l_error_mesg,91,45));


         end if;

         if substr(l_error_mesg,136,45) is not null then
            pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
            pay_core_utils.push_token('record_name',' ');
            pay_core_utils.push_token('description',substr(l_error_mesg,136,45));
         end if;

         hr_utility.raise_error;
      end if;

   end if;


   hr_utility.trace('Before the range cursor');
   hr_utility.trace('EOY Payroll action id = '||l_eoy_payroll_action_id);

   sqlstr :=

      'SELECT
        to_number(paa_arch.serial_number)
       FROM
        PAY_ASSIGNMENT_ACTIONS paa_arch
       WHERE paa_arch.payroll_action_id = ' || l_eoy_payroll_action_id ||
     ' AND :payroll_action_id is not null
       AND paa_arch.action_status = ''C''
       order by to_number(paa_arch.serial_number) ';

  hr_utility.trace('After the range cursor');

end range_cursor;


FUNCTION action_creation_term_ee (p_select IN varchar2,
                                  p_where  IN varchar2,
                                  p_eoy_start_date IN date,
                                  p_session_date IN date)
RETURN VARCHAR2 IS
     c_select        varchar2(32767);
     c_where         varchar2(32767);
     c_complete_sql  varchar2(32767);
begin
      c_select := p_select || ',per_periods_of_service PDS ';
      c_where :=  p_where ||
                   ' and pds.actual_termination_date is not null
                     and pds.period_of_service_id	= paf.period_of_service_id ';

-- Bug 5169849 : This is not needed as employee is already archived by Year End Pre Process. Also, the
--               actual_termination_date can be prior to p_eoy_start_date. But it cannot be null.
/*
      c_where :=  p_where ||
                   ' and nvl(pds.actual_termination_date,paf.effective_end_date) between ' ||
                   '''' || p_eoy_start_date || ''' and '''
                   || p_session_date
                  ||''' and pds.period_of_service_id	= paf.period_of_service_id ';
*/
     c_complete_sql := c_select|| c_where;
     return c_complete_sql;


end;


---------------------------------- action_creation_for_ee -----------------------------
procedure action_creation_for_ee(
               pactid            in number,
               stperson          in number,
               endperson         in number,
               chunk             in number,
               p_year            in number,
               p_gre_id          in number,
               p_org_id          in number,
               p_loc_id          in number,
               p_per_id          in number,
               p_ssn             in varchar2,
               p_state_code      in pay_us_states.state_code%type,
               p_asg_set_id      in number,
               p_session_date    in date,
               p_eoy_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
               p_eoy_start_date  in date,
               p_report_type     in varchar2 ,
               p_locality_code   in varchar2,
               p_print_term      in varchar2)  is

  lockingactid  number;
  lockedactid   number;
  assignid      number;
  greid         number;
  num           number;
  l_effective_end_date DATE;

  l_effective_date    DATE;  /* 4152323 variables definitions start */
  l_report_type       pay_payroll_actions.report_type%type;
  l_report_category   pay_payroll_actions.report_category%type;
  l_report_qualifier  pay_payroll_actions.report_qualifier%type;
  l_report_format     pay_report_format_mappings_f.report_format%type;
  l_range_person_on   BOOLEAN;

  l_procedure_name    VARCHAR2(100);

  /* when person is selected */
  -- Bug# 5513289 : This cursor is not needed. A dynamic cursor created to replace
  --                 this to fix this bug.
/*  CURSOR c_actions_with_person  is
       SELECT paa_arch.assignment_action_id,
              paa_arch.assignment_id,
              paa_arch.tax_unit_id,
	      paf.effective_end_date
       FROM  per_assignments_f paf,
             pay_assignment_actions paa_arch
       WHERE paa_arch.payroll_action_id = p_eoy_payroll_action_id
         AND paa_arch.action_status = 'C'
         AND paf.PERSON_ID = p_per_id
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                           and paf2.effective_start_date <= p_session_date)
         AND paf.effective_end_date >= p_eoy_start_date
         AND paf.assignment_type = 'E'
         AND paf.person_id between stperson and endperson;
*/
  CURSOR c_state_context (p_context_name varchar2) is
       select context_id from ff_contexts
       where context_name = p_context_name;

  l_tuid_context    ff_contexts.context_id%TYPE;
  l_juri_context    ff_contexts.context_id%TYPE;

  CURSOR c_state_ueid (p_user_entity_name varchar2) is
       select user_entity_id
         from ff_user_entities
        where user_entity_name = p_user_entity_name
          and legislation_code = 'US';

  l_city_wk_whld   ff_user_entities.user_entity_name%TYPE;
  l_subj_whable    ff_user_entities.user_entity_name%TYPE;
  l_subj_nwhable   ff_user_entities.user_entity_name%TYPE;
  l_county_wheld   ff_user_entities.user_entity_name%TYPE;
  l_school_wheld   ff_user_entities.user_entity_name%TYPE;

  TYPE RefCurType is REF CURSOR;
  c_actions_no_selection    RefCurType;
  c_actions_with_location   RefCurType;
  c_actions_with_org        RefCurType;
  c_actions_with_state      RefCurType;
  c_actions_with_assign_set RefCurType;
  c_actions_with_person     RefCurType;

  c_actions_no_selection_sql  varchar2(10000);
  c_actions_with_location_sql varchar2(10000);
  c_actions_with_org_sql      varchar2(10000);
  c_actions_with_state_sql    varchar2(10000);
  c_actions_with_assign_sql   varchar2(10000);
  c_actions_with_person_sql   varchar2(10000);
  c_print_term_employee       varchar2(10000);
  c_actions_where             varchar2(10000);

begin
    l_procedure_name := 'action_creation_for_ee';
    hr_utility.set_location(l_procedure_name, 1);
    /* 4152323 { */
    select effective_date,
           report_type,
           report_qualifier,
	   report_category
    into   l_effective_date,
           l_report_type,
           l_report_qualifier,
	   l_report_category
    from   pay_payroll_actions
    where  payroll_action_id = pactid;

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
   /* } 4152323 */


    /* when no selection is entered */
    if((p_loc_id is null ) and
       (p_org_id is null ) and
       (p_per_id is null ) and
       (p_ssn    is null ) and
       (p_state_code is null ) and
       (p_asg_set_id is null ))       then

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
                    pay_population_ranges ppr ';

           c_actions_where :=
             ' WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id +0= ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                           (select max(paf2.effective_start_date)
                              from per_assignments_f paf2
                             where paf2.assignment_id = paf.assignment_id
                               and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
              /*  and paf.primary_flag = ''Y'' */
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                and paf.person_id = to_number(paa_arch.serial_number)';

            IF nvl(p_print_term,'N') = 'Y' THEN
          /*      c_actions_no_selection_sql := c_actions_no_selection_sql ||
                                              ',per_periods_of_service PDS ';
                c_actions_where := c_actions_where ||
                                  ' and nvl(pds.actual_termination_date,paf.effective_end_date) between ' ||
                                    '''' || p_eoy_start_date || ''' and '''
                                       || p_session_date
                                       ||''' and pds.period_of_service_id	= paf.period_of_service_id ';
            */
               c_actions_no_selection_sql := action_creation_term_ee (c_actions_no_selection_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
            ELSE
               c_actions_no_selection_sql := c_actions_no_selection_sql || c_actions_where;
            END IF;


           -- c_actions_no_selection_sql := c_actions_no_selection_sql || c_actions_where;
             hr_utility.trace(' c_actions_no_selection_sql' ||c_actions_no_selection_sql);
         else
          hr_utility.set_location(l_procedure_name, 15);
          c_actions_no_selection_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                    paf.effective_end_date
                    FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch ';

          c_actions_where :=   '  WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id +0= ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                         (select max(paf2.effective_start_date)
                            from per_assignments_f paf2
                           where paf2.assignment_id = paf.assignment_id
                             and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
              /*  and paf.primary_flag = ''Y'' */
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                and paf.person_id = to_number(paa_arch.serial_number) ';

            IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_no_selection_sql := action_creation_term_ee (c_actions_no_selection_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
            ELSE
               c_actions_no_selection_sql := c_actions_no_selection_sql || c_actions_where;
            END IF;
            hr_utility.trace(' c_actions_no_selection_sql' ||c_actions_no_selection_sql);

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

          if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

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
      if p_loc_id is not null then
         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 35);
            c_actions_with_location_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
    	            paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr ';
            c_actions_where := '
                    /* disabling the index for performance reason  */
             WHERE  paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  paf.location_id = ' || p_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id ' ;

         else
            hr_utility.set_location(l_procedure_name, 40);
            c_actions_with_location_sql :=
            'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch ';
             c_actions_where := '
              /* disabling the index for performance reason  */
             WHERE  paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  paf.location_id = ' || p_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_session_date || ''' )
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '';

         end if ;

         IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_location_sql := action_creation_term_ee (c_actions_with_location_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_location_sql := c_actions_with_location_sql || c_actions_where;
         END IF;
            hr_utility.trace(' c_actions_with_location_sql ' ||c_actions_with_location_sql);


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

	    if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
      if p_org_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 60);
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_org_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr ';
             c_actions_where := '
              /* disabling the index for performance reason */
             WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paf.organization_id = ' || p_org_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                      (select max(paf2.effective_start_date)
                       from per_assignments_f paf2
                       where paf2.assignment_id = paf.assignment_id
                       and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id ';


         else
            hr_utility.set_location(l_procedure_name, 70);
            c_actions_with_org_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch ';
             c_actions_where := '
              /* disabling the index for performance reason */
             WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paf.organization_id = ' || p_org_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                      (select max(paf2.effective_start_date)
                       from per_assignments_f paf2
                       where paf2.assignment_id = paf.assignment_id
                       and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson ||'';
         end if ;

         IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_org_sql := action_creation_term_ee (c_actions_with_org_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_org_sql := c_actions_with_org_sql || c_actions_where;
         END IF;
         hr_utility.trace(' c_actions_with_org_sql ' ||c_actions_with_org_sql);


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

	    if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
      if (p_per_id is not null OR p_ssn is not null ) then

      /* Bug# 5513289: If p_print_term is set to 'Y' then assignment_action_ids
                       of terminated employees alone are selected  */
       c_actions_with_person_sql :=  'SELECT paa_arch.assignment_action_id,
              paa_arch.assignment_id,
              paa_arch.tax_unit_id,
	      paf.effective_end_date
       FROM  per_assignments_f paf,
             pay_assignment_actions paa_arch';

       c_actions_where := '
         WHERE paa_arch.payroll_action_id = ' || p_eoy_payroll_action_id ||'
         AND paa_arch.action_status = ''C''
         AND paf.PERSON_ID = '|| p_per_id || '
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                           and paf2.effective_start_date <= ''' ||p_session_date ||''')
         AND paf.effective_end_date >='''||  p_eoy_start_date || '''
         AND paf.assignment_type = ''E''
         AND paf.person_id between ' || stperson || ' and ' || endperson ||' ';

	IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_person_sql := action_creation_term_ee (c_actions_with_person_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_person_sql := c_actions_with_person_sql || c_actions_where;
         END IF;
         hr_utility.trace(' c_actions_with_person_sql ' ||c_actions_with_person_sql);


         open c_actions_with_person for c_actions_with_person_sql;
	     /* Bug# 5513289 :Ending here  */
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

	    if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
      if p_state_code is not null then
         hr_utility.set_location(l_procedure_name, 130);

         hr_utility.trace('p_state_code  = ' || p_state_code);
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
                    pay_population_ranges ppr ';
            c_actions_where := '
             WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                       (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                         where paf2.assignment_id = paf.assignment_id
                           and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
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
                    pay_assignment_actions paa_arch ';
             c_actions_where := '
             WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date =
                       (select max(paf2.effective_start_date)
                          from per_assignments_f paf2
                         where paf2.assignment_id = paf.assignment_id
                           and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson;
         end if;

         IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_state_sql := action_creation_term_ee (c_actions_with_state_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_state_sql := c_actions_with_state_sql || c_actions_where;
         END IF;
         hr_utility.trace(' c_actions_with_state_sql ' ||c_actions_with_state_sql);


         hr_utility.set_location(l_procedure_name, 160);
         if p_locality_code is null then
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
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || ' ))';
         --
         -- County
         --
         elsif length(p_locality_code) = 11 and
               substr(p_locality_code, 8,4) = '0000' then
            hr_utility.set_location(l_procedure_name, 180);
            --Bug #4886044
            -- Added the check for the User Entity 'A_COUNTY_WITHHELD_PER_JD_GRE_YTD'
            -- Only employees who have both Wages and Taxes withheld
            -- from the specified locality shoule be reported for that
            -- The below exist clause will check the Tax part. The following exist clause
            -- checks the Wages part of the query.
            open c_state_ueid('A_COUNTY_WITHHELD_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_county_wheld;
            close c_state_ueid;

            c_actions_with_state_sql := c_actions_with_state_sql ||
                    ' AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in (' || l_county_wheld || ')
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,6) = substr(''' || p_locality_code || ''',1,6) ))';

            open c_state_ueid('A_COUNTY_SUBJ_WHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_whable;
            close c_state_ueid;

            open c_state_ueid('A_COUNTY_SUBJ_NWHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_nwhable;
            close c_state_ueid;

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
                               and substr(ltrim(rtrim(fic2.context)),1,6) = substr(''' || p_locality_code || ''',1,6) ))';
         --
         -- City
         --
         elsif length(p_locality_code) = 11 and
               substr(p_locality_code, 8,4) <> '0000' then
            hr_utility.set_location(l_procedure_name, 190);

            -- Bug 4645408
            -- Added the check for the User Entity 'A_CITY_WK_WITHHELD_PER_JD_GRE_YTD'
            -- Only employees who have both Wages and Taxes withheld
            -- from the specified locality shoule be reported for that
            -- The below exist clause will check the Tax part. The following exist clause
            -- checks the Wages part of the query.
           -- open c_state_ueid('A_CITY_WK_WITHHELD_PER_JD_GRE_YTD');
	    open c_state_ueid('A_CITY_WITHHELD_PER_JD_GRE_YTD'); /* 6909926 */
            fetch c_state_ueid into l_city_wk_whld;
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
                               and fai.user_entity_id in (' || l_city_wk_whld || ')
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,11) = ''' || p_locality_code || ''' ))';

            open c_state_ueid('A_CITY_SUBJ_WHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_whable;
            close c_state_ueid;

            open c_state_ueid('A_CITY_SUBJ_NWHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_nwhable;
            close c_state_ueid;

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
                               and substr(ltrim(rtrim(fic2.context)),1,11) = ''' || p_locality_code || ''' ))';
         --
         -- School District
         --
         elsif length(p_locality_code) = 8 then
            hr_utility.set_location(l_procedure_name, 200);
            --Bug #4886044
            -- Added the check for the User Entity 'A_SCHOOL_WITHHELD_PER_JD_GRE_YTD'
            -- Only employees who have both Wages and Taxes withheld
            -- from the specified locality shoule be reported for that
            -- The below exist clause will check the Tax part. The following exist clause
            -- checks the Wages part of the query.
            open c_state_ueid('A_SCHOOL_WITHHELD_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_school_wheld;
            close c_state_ueid;

            c_actions_with_state_sql := c_actions_with_state_sql ||
                    ' AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in (' || l_school_wheld || ')
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,8) = ''' || p_locality_code || '''))';

            open c_state_ueid('A_SCHOOL_SUBJ_WHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_whable;
            close c_state_ueid;

            open c_state_ueid('A_SCHOOL_SUBJ_NWHABLE_PER_JD_GRE_YTD');
            fetch c_state_ueid into l_subj_nwhable;
            close c_state_ueid;

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
                               and substr(ltrim(rtrim(fic2.context)),1,8) = ''' || p_locality_code || '''))';
         end if;
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

	    if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
      if p_asg_set_id is not null then

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
                    pay_population_ranges ppr ';
            c_actions_where := '
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || p_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'') ';
         else
            hr_utility.set_location(l_procedure_name, 250);
            c_actions_with_assign_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch ';
            c_actions_where := '
             WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || p_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'') ';
        end if ;

         IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_assign_sql := action_creation_term_ee (c_actions_with_assign_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_assign_sql := c_actions_with_assign_sql || c_actions_where;
         END IF;
         hr_utility.trace(' c_actions_with_assign_sql  ' ||c_actions_with_assign_sql);

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

	    if pay_us_employee_payslip_web.get_doc_eit('W-2',
                                                       'PRINT',
                                                       'ASSIGNMENT',
                                                       assignid,
                                                       l_effective_end_date) = 'Y' then

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
      hr_utility.trace('End of the action cursor');

end action_creation_for_ee;

---------------------------------- action_creation_for_er -----------------------------
-----
--
procedure action_creation_for_er(pactid            in number,
                                 stperson          in number,
                                 endperson         in number,
                                 chunk             in number,
                                 p_year            in number,
                                 p_gre_id          in number,
                                 p_org_id          in number,
                                 p_loc_id          in number,
                                 p_per_id          in number,
                                 p_ssn             in varchar2,
                                 p_state_code      in pay_us_states.state_code%type,
                                 p_asg_set_id      in number,
                                 p_session_date    in date,
                                 p_eoy_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
                                 p_eoy_start_date  in date,
					   p_print_term      in varchar2)  is --6712851

  lockingactid  number;
  lockedactid   number;
  assignid      number;
  greid         number;
  num           number;
  l_effective_end_date DATE;

  l_effective_date    DATE;  /* 4152323 variables definitions start */
  l_report_type       pay_payroll_actions.report_type%type;
  l_report_category   pay_payroll_actions.report_category%type;
  l_report_qualifier  pay_payroll_actions.report_qualifier%type;
  l_report_format     pay_report_format_mappings_f.report_format%type;
  l_range_person_on   BOOLEAN;
  /* 4152323 variables definitions end */

CURSOR c_state_context (p_context_name varchar2) is

       select context_id from ff_contexts
       where context_name = p_context_name;

l_tuid_context    ff_contexts.context_id%TYPE;
l_juri_context    ff_contexts.context_id%TYPE;

CURSOR c_state_ueid (p_user_entity_name varchar2) is

       select user_entity_id
       from ff_user_entities
       where user_entity_name = p_user_entity_name
         and legislation_code = 'US';

l_sit_subj_whable    ff_user_entities.user_entity_name%TYPE;
l_sit_subj_nwhable   ff_user_entities.user_entity_name%TYPE;
l_sit_withheld       ff_user_entities.user_entity_name%TYPE; /* 6809739 */

/* when person is selected */

/*CURSOR c_actions_with_person  is  --6712851
       SELECT paa_arch.assignment_action_id,
              paa_arch.assignment_id,
              paa_arch.tax_unit_id,
	      paf.effective_end_date
       FROM  per_assignments_f paf,
             pay_assignment_actions paa_arch
       WHERE paa_arch.payroll_action_id = p_eoy_payroll_action_id
         AND paa_arch.action_status = 'C'
         AND paf.PERSON_ID = p_per_id
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                           and paf2.effective_start_date <= p_session_date)
         AND paf.effective_end_date >= p_eoy_start_date
         AND paf.assignment_type = 'E'
         AND paf.person_id between stperson and endperson
         AND exists ( select 1 from dual
                      where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( l_sit_subj_whable,
                                                l_sit_subj_nwhable,
						l_sit_withheld) /* 6809739 */
                             /*  and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = l_tuid_context
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = l_juri_context
                               and substr(ltrim(rtrim(fic2.context)),1,2) = p_state_code )) ; */

TYPE RefCurType is REF CURSOR;
c_actions_no_selection    RefCurType;
c_actions_with_location   RefCurType;
c_actions_with_org        RefCurType;
c_actions_with_assign_set RefCurType;
c_actions_with_person     RefCurType; --6712851

c_actions_no_selection_sql  varchar2(10000);
c_actions_with_location_sql varchar2(10000);
c_actions_with_org_sql      varchar2(10000);
c_actions_with_assign_sql   varchar2(10000);
c_actions_with_person_sql   varchar2(10000); --6712851
c_actions_where             varchar2(10000); --6712851

begin
    hr_utility.set_location('procpyr',1);
    hr_utility.trace('In the ER action cursor');

    /* 4152323 { */
    select effective_date,
           report_type,
           report_qualifier,
	   report_category
    into   l_effective_date,
           l_report_type,
           l_report_qualifier,
	   l_report_category
    from   pay_payroll_actions
    where  payroll_action_id = pactid;

    Begin
            select report_format
            into   l_report_format
            from   pay_report_format_mappings_f
            where  report_type = l_report_type
            and    report_qualifier = l_report_qualifier
            and    report_category = l_report_category
            and    l_effective_date between
                   effective_start_date and effective_end_date;
       Exception
            When Others Then
                l_report_format := Null ;
       End ;

    l_range_person_on := pay_ac_utility.range_person_on
                                    ( p_report_type      => l_report_type,
                                      p_report_format    => l_report_format,
                                      p_report_qualifier => l_report_qualifier,
                                      p_report_category  => l_report_category);
   /* } 4152323 */

    open c_state_context('TAX_UNIT_ID');
    fetch c_state_context into l_tuid_context;
    close c_state_context;

    open c_state_context('JURISDICTION_CODE');
    fetch c_state_context into l_juri_context;
    close c_state_context;

    open c_state_ueid('A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD');
    fetch c_state_ueid into l_sit_subj_whable;
    close c_state_ueid;

    open c_state_ueid('A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD');
    fetch c_state_ueid into l_sit_subj_nwhable;
    close c_state_ueid;

    open c_state_ueid('A_SIT_WITHHELD_PER_JD_GRE_YTD'); /* 6809739 */
    fetch c_state_ueid into l_sit_withheld;
    close c_state_ueid;

      /* when no selection is entered */

      if((p_loc_id is null ) and
         (p_org_id is null ) and
         (p_per_id is null ) and
         (p_ssn    is null ) and
         (p_asg_set_id is null ))       then

         if l_range_person_on = TRUE Then
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_no_selection_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                    paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr ';
		c_actions_where :=
             'WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                            from per_assignments_f paf2
                                            where paf2.assignment_id = paf.assignment_id
                                            and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                /* and paf.primary_flag = ''Y'' */
                --AND paf.person_id between stperson and endperson
                and paf.person_id = to_number(paa_arch.serial_number)
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context  || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || ' )) ';

	            IF nvl(p_print_term,'N') = 'Y' THEN  --6712851
          /*      c_actions_no_selection_sql := c_actions_no_selection_sql ||
                                              ',per_periods_of_service PDS ';
                c_actions_where := c_actions_where ||
                                  ' and nvl(pds.actual_termination_date,paf.effective_end_date) between ' ||
                                    '''' || p_eoy_start_date || ''' and '''
                                       || p_session_date
                                       ||''' and pds.period_of_service_id	= paf.period_of_service_id ';
            */
               c_actions_no_selection_sql := action_creation_term_ee (c_actions_no_selection_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
            ELSE
               c_actions_no_selection_sql := c_actions_no_selection_sql || c_actions_where;
            END IF;
         else
            c_actions_no_selection_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
                    paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch ';
		c_actions_where :=
             'WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                            from per_assignments_f paf2
                                            where paf2.assignment_id = paf.assignment_id
                                            and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                /* and paf.primary_flag = ''Y'' */
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                and paf.person_id = to_number(paa_arch.serial_number)
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context  || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || ' )) ';

	     IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_no_selection_sql := action_creation_term_ee (c_actions_no_selection_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
            ELSE
               c_actions_no_selection_sql := c_actions_no_selection_sql || c_actions_where;
            END IF;
            hr_utility.trace(' c_actions_no_selection_sql' ||c_actions_no_selection_sql);

         end if ;

         OPEN c_actions_no_selection for c_actions_no_selection_sql;
         num := 0;

         loop
            hr_utility.set_location('procpyr',2);
            hr_utility.trace('after  the loop in action cursor');
            fetch c_actions_no_selection into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_no_selection%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_no_selection%found in action cursor');
            else
              hr_utility.trace('In the c_actions_no_selection%notfound in action cursor');
              exit;
            end if;
            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
         end loop;
         close c_actions_no_selection;

      end if;

      /* when location is entered */

      if p_loc_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_location_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
              /* disabling the index for performance reason */ ';
		  c_actions_where :=
             'WHERE  paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
                AND paf.location_id = ' || p_loc_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                         and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
              --AND paf.person_id between stperson and endperson
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                                      ( ' || l_sit_subj_whable || ',
                                                        ' || l_sit_subj_nwhable || ',
							' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || '  ))';
         else
            c_actions_with_location_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch
              /* disabling the index for performance reason */ ';
		  c_actions_where :=
             'WHERE  paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
               AND  paa_arch.action_status = ''C''
                AND paf.location_id = ' || p_loc_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                         and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND  paf.person_id between ' || stperson || ' and ' || endperson || '
                AND  exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                                      ( ' || l_sit_subj_whable || ',
                                                        ' || l_sit_subj_nwhable || ',
							' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || '  ))';
         end if ;

	    IF nvl(p_print_term,'N') = 'Y' THEN   --6712851
               c_actions_with_location_sql := action_creation_term_ee (c_actions_with_location_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_location_sql := c_actions_with_location_sql || c_actions_where;
         END IF;
            hr_utility.trace(' c_actions_with_location_sql ' ||c_actions_with_location_sql);


         OPEN c_actions_with_location for c_actions_with_location_sql;
         num := 0;

         loop
            hr_utility.set_location('procpyr',2);
            hr_utility.trace('after  the loop in action cursor');
            fetch c_actions_with_location into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_location%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_location%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_location%notfound in action cursor');
              exit;
            end if;


            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
         end loop;
         close c_actions_with_location;

      end if;


      /* when org is entered */

      if p_org_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_org_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr
              /* disabling the index for performance reason */ ';
		 c_actions_where :=
             'WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paf.organization_id = ' || p_org_id  || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
              --AND paf.person_id between stperson and endperson
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ')  /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || '))';
         else
            c_actions_with_org_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch
              /* disabling the index for performance reason */ ';
		c_actions_where :=
             'WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paf.organization_id = ' || p_org_id  || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ')  /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || '))';
         end if ;

	   IF nvl(p_print_term,'N') = 'Y' THEN --6712851
               c_actions_with_org_sql := action_creation_term_ee (c_actions_with_org_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_org_sql := c_actions_with_org_sql || c_actions_where;
         END IF;

         OPEN c_actions_with_org for c_actions_with_org_sql;
         num := 0;

         loop
            hr_utility.set_location('procpyr',2);
            hr_utility.trace('after  the loop in c_actions_with_org');
            fetch c_actions_with_org into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_org%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_org%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_org%notfound in action cursor');
              exit;
            end if;


            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
         end loop;
         close c_actions_with_org;

      end if;

      /* when person is entered */

      if ( p_per_id is not null  OR p_ssn is not null ) then /* 6712851 */

	         c_actions_with_person_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM
                    per_assignments_f paf,
                    pay_assignment_actions paa_arch
			    /* disabling the index for performance reason */ ';
              c_actions_where :=
             'WHERE  paa_arch.payroll_action_id +0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.action_status = ''C''
                AND paf.PERSON_ID = '|| p_per_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson ||'
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ')  /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || '))';

      	IF nvl(p_print_term,'N') = 'Y' THEN
               c_actions_with_person_sql := action_creation_term_ee (c_actions_with_person_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_person_sql := c_actions_with_person_sql || c_actions_where;
		 END IF;


         open c_actions_with_person for c_actions_with_person_sql;
	     /* Bug# 5513289 :Ending here  */
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

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
         end loop;
         close c_actions_with_person;

      end if;

      /* when assignment set is entered */

      if p_asg_set_id is not null then

         if l_range_person_on = TRUE Then
            hr_utility.trace('Range Person ID Functionality is enabled') ;
            c_actions_with_assign_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch,
                    pay_population_ranges ppr ';
	      c_actions_where :=
             'WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
              --AND paf.person_id between stperson and endperson
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id       = ' || p_asg_set_id || '
                        and hasa.assignment_id             = paa_arch.assignment_id
                        and upper(hasa.include_or_exclude) = ''I'')
                AND exists ( select 1 from dual
                             where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || ' ))';
         else
            c_actions_with_assign_sql :=
			'SELECT paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id,
	                paf.effective_end_date
              FROM  per_assignments_f paf,
                    pay_assignment_actions paa_arch ';
	      c_actions_where :=
             'WHERE  paa_arch.action_status = ''C''
                AND paa_arch.payroll_action_id + 0 = ' || p_eoy_payroll_action_id || '
                AND paa_arch.assignment_id = paf.assignment_id
                AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_session_date || ''')
                AND paf.effective_end_date >= ''' || p_eoy_start_date || '''
                AND paf.assignment_type = ''E''
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || p_asg_set_id || '
                        and hasa.assignment_id             = paa_arch.assignment_id
                        and upper(hasa.include_or_exclude) = ''I'')
                AND exists ( select 1 from dual
                      where 1 =
                            (select decode(sign(nvl(sum(to_number(fai.value)),0)),-1,1,0,0,1)
                             from ff_archive_items fai,
                                  ff_archive_item_contexts fic1,
                                  ff_archive_item_contexts fic2
                             where fai.context1 = paa_arch.assignment_action_id
                               and fai.user_entity_id in
                                              ( ' || l_sit_subj_whable || ',
                                                ' || l_sit_subj_nwhable || ',
						' || l_sit_withheld || ') /* 6809739 */
                               and fai.archive_item_id = fic1.archive_item_id
                               and fic1.context_id = ' || l_tuid_context || '
                               and ltrim(rtrim(fic1.context)) = to_char(paa_arch.tax_unit_id)
                               and fai.archive_item_id = fic2.archive_item_id
                               and fic2.context_id = ' || l_juri_context || '
                               and substr(ltrim(rtrim(fic2.context)),1,2) = ' || p_state_code || ' ))';
         end if ;

	   IF nvl(p_print_term,'N') = 'Y' THEN  --6712851
               c_actions_with_assign_sql := action_creation_term_ee (c_actions_with_assign_sql,
                                                                      c_actions_where,
                                                                      p_eoy_start_date,
                                                                      p_session_date);
         ELSE
               c_actions_with_assign_sql := c_actions_with_assign_sql || c_actions_where;
         END IF;

         OPEN c_actions_with_assign_set for c_actions_with_assign_sql;
         num := 0;

         loop
            hr_utility.set_location('procpyr',2);
            hr_utility.trace('after  the loop in c_actions_with_assign_set');
            fetch c_actions_with_assign_set into lockedactid,assignid,greid,l_effective_end_date;

            if c_actions_with_assign_set%found then
              num := num + 1;
              hr_utility.trace('In the c_actions_with_assign_set%found in action cursor');
            else
              hr_utility.trace('In the c_actions_with_assign_set%notfound in action cursor');
              exit;
            end if;

            -- we need to insert one action for each of the
            -- rows that we return from the cursor (i.e. one
            -- for each assignment/pre-payment/reversal).
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
         end loop;
         close c_actions_with_assign_set;

      end if;
  hr_utility.trace('End of the action cursor');

end action_creation_for_er;

---------------------------------- action_creation -----------------------------
-----
--
/* CHANGED THE ACTION_CREATION CURSOR. NOW SEPERATE PROCEDURES ARE CALLED FOR
   EMPLOYEE AND EMPLOYER W2. THIS IS BECAUSE STATE PARAMTER IS REQUIRED FOR
   EMPLOYER W2 AND OPTIONAL FOR EMPLOYEE W2.
   MAKE SURE CHANGES ARE MADE IN BOTH THE PROCEDURES.
*/

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

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
  l_eoy_start_date date;
  -- BUG2538173
  l_locality_code    varchar2(20);
  l_print_term       varchar2(2);


  l_report_type      pay_payroll_actions.report_type%TYPE;

  begin
  -- hr_utility.trace_on(null,'ORACLE');
    hr_utility.set_location('procpyr',1);
    hr_utility.trace('In  the action cursor');
      Begin
         select to_number(hr_us_w2_mt.get_parameter('Year',ppa1.legislative_parameters)),
                to_number(hr_us_w2_mt.get_parameter('GRE_ID',ppa1.legislative_parameters)),
                to_number(hr_us_w2_mt.get_parameter('ORG_ID',ppa1.legislative_parameters)),
                to_number(hr_us_w2_mt.get_parameter('LOC_ID',ppa1.legislative_parameters)),
                to_number(hr_us_w2_mt.get_parameter('PER_ID',ppa1.legislative_parameters)),
                hr_us_w2_mt.get_parameter('SSN',ppa1.legislative_parameters),
                hr_us_w2_mt.get_parameter('STATE',ppa1.legislative_parameters),
                to_number(hr_us_w2_mt.get_parameter('ASG_SET',ppa1.legislative_parameters)),
                ppa.effective_date,
                ppa.payroll_action_id,
                ppa.start_date,
                ppa1.report_type
                --,ppa1.legislative_parameters
               ,hr_us_w2_mt.get_parameter('LOCALITY',ppa1.legislative_parameters)
               ,hr_us_w2_mt.get_parameter('PRINT_TERM',ppa1.legislative_parameters)
         into   l_year,
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
                l_report_type
               ,l_locality_code -- BUG2538173
               ,l_print_term
         from pay_payroll_actions ppa,   /* EOY payroll action id */
              pay_payroll_actions ppa1   /* PYUGEN payroll action id */
         where ppa1.payroll_action_id = pactid
           and ppa.effective_date = ppa1.effective_date
           and ppa.report_type = 'YREND'
           and hr_us_w2_mt.get_parameter
                      ('GRE_ID',ppa1.legislative_parameters) =
                                 hr_us_w2_mt.get_parameter
                                     ('TRANSFER_GRE',ppa.legislative_parameters);
      Exception
          when no_data_found then
          hr_utility.trace('Legislative parameters not found for pactid '||to_char(pactid));
          raise;
      End ;
      hr_utility.trace('report_type     = '||l_report_type);
      hr_utility.trace('l_locality_code = '||l_locality_code);


/* Now the SSN value set return person_id. Since the submittion is based on
   selection citeria only only value can be entered so in case l_ssn is not
   null then it is safe to assume l_per_id is null */

      if l_ssn is not null then
         l_per_id := l_ssn;
      end if;


      if l_report_type in ('EMP_W2PAPER', 'EMP_W2PDF') then /* Employer W2 */ -- added EMP_W2PDF, l_print_term for ENH. 6712851

         action_creation_for_er(pactid,stperson,endperson,chunk,l_year,
                                l_gre_id,l_org_id,l_loc_id,l_per_id,
                                l_ssn,l_state_code,l_asg_set_id,
                                l_session_date,l_eoy_payroll_action_id,
                                l_eoy_start_date,l_print_term );

      elsif l_report_type in ('W2_XML', 'W2PAPER') then /*Employee W2 paper/XML */

         action_creation_for_ee(pactid,stperson,endperson,chunk,l_year,
                                l_gre_id,l_org_id,l_loc_id,l_per_id,
                                l_ssn,l_state_code,l_asg_set_id,
                                l_session_date,l_eoy_payroll_action_id,
                                l_eoy_start_date,l_report_type
                                ,l_locality_code,l_print_term);


      elsif l_report_type = 'PRW2PAPER' then /*Puerto Rico Employee W2*/

         l_state_code :=null;

         hr_utility.trace('Action creation for Puerto Rico Employee W2');
         hr_utility.trace('stperson ' ||to_char(stperson));
         hr_utility.trace('endperson ' ||to_char(endperson));
         hr_utility.trace('l_eoy_payroll_action_id = '||to_char(l_eoy_payroll_action_id));

         hr_utility.trace('pactid = '||to_char(pactid));
         action_creation_for_ee(pactid,stperson,endperson,chunk,l_year,
                                l_gre_id,l_org_id,l_loc_id,l_per_id,
                                l_ssn,l_state_code,l_asg_set_id,
                                l_session_date,l_eoy_payroll_action_id,
                                l_eoy_start_date,l_report_type ,l_locality_code
								,l_print_term);

      end if;

end action_creation;

---------------------------------- sort_action ------------------------------

procedure sort_action
(
   payactid   in     varchar2,
   sqlstr     in out nocopy varchar2,
   len        out   nocopy number
) is

  l_dt               date;
  l_year             number ;
  l_gre_id           pay_assignment_actions.tax_unit_id%type;
  l_org_id           per_assignments_f.organization_id%type;
  l_loc_id           per_assignments_f.location_id%type;
  l_per_id           per_assignments_f.person_id%type;
  l_ssn              per_people_f.national_identifier%type;
  l_state_code       pay_us_states.state_code%type;
  l_sort1            varchar2(60);
  l_sort2            varchar2(60);
  l_sort3            varchar2(60);
  l_year_start         date;
  l_year_end         date;
  l_bg_id pay_payroll_actions.business_group_id%type ;

begin

   begin
   select hr_us_w2_mt.get_parameter('Year',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('GRE_ID',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('ORG_ID',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('LOC_ID',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('PER_ID',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('SSN',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('STATE',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('S1',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('S2',ppa.legislative_parameters),
          hr_us_w2_mt.get_parameter('S3',ppa.legislative_parameters),
          to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD'),
          ppa.effective_date,
          ppa.business_group_id
   into   l_year,
          l_gre_id,
          l_org_id,
          l_loc_id,
          l_per_id,
          l_ssn,
          l_state_code,
          l_sort1 ,
          l_sort2,
          l_sort3,
          l_dt, --session_date
          l_year_end,
          l_bg_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = payactid;

    exception when no_data_found then
            hr_utility.trace('Error in Sort Procedure - getting legislative param');
            raise;
    end;
    /* changed this with the if statement below
      begin
      select to_date('31-DEC-'||to_char(l_year),'DD/MM/YYYY')
        into l_dt
        from dual
       where to_date('31-DEC-'||to_char(l_year),'DD/MM/YYYY') > l_dt;
      exception
        when others then null;
      end;
    */
/*
    if  to_date('31-DEC-'||to_char(l_year),'DD/MM/YYYY') > l_dt
    then
        l_dt := to_date('31-DEC-'||to_char(l_year),'DD/MM/YYYY') ;
    end if;
*/


    if  l_year_end > l_dt then
        l_dt := l_year_end;
    end if;

    hr_utility.trace('Beginning of the sort_action cursor');

 sqlstr :=
'select mt.rowid
 from hr_organization_units hou, hr_locations_all hl, per_periods_of_service pps,
 per_assignments_f paf, pay_assignment_actions mt
 where mt.payroll_action_id = :pactid and paf.assignment_id = mt.assignment_id
 and paf.effective_start_date = (select max(paf2.effective_start_date)
				 from per_assignments_f paf2
				 where paf2.assignment_id = paf.assignment_id
				 and paf2.effective_start_date <= to_date(''31-DEC-''||'''||l_year||''',''DD/MM/YYYY''))
 and paf.effective_end_date >= to_date(''01-JAN-''||'''||l_year||''',''DD/MM/YYYY'')
 and paf.assignment_type = ''E'' and pps.period_of_service_id = paf.period_of_service_id
 and pps.person_id = paf.person_id and hl.location_id = paf.location_id
 and hou.organization_id = paf.organization_id and hou.business_group_id + 0 = '''||l_bg_id||'''
 order by decode('''||l_sort1||''', ''Employee_Name'',
 /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||'''),
 ''SSN'',nvl(hr_us_w2_rep.get_per_item( to_number(mt.serial_number), ''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
 ''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,'''||l_dt||'''),
 ''Organization'',hou.name, ''Location'',hl.location_code,
 ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',hr_us_w2_rep.get_leav_reason(leaving_reason)),
  /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||''')),
 decode('''||l_sort2||''', ''Employee_Name'',
  /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||'''),
 ''SSN'',nvl(hr_us_w2_rep.get_per_item(to_number(mt.serial_number), ''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
 ''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,'''||l_dt||'''),
 ''Organization'',hou.name, ''Location'',hl.location_code,
 ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',hr_us_w2_rep.get_leav_reason(leaving_reason)),
  /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||''')),
 decode('''||l_sort3||''', ''Employee_Name'',
  /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||'''),
 ''SSN'',nvl(hr_us_w2_rep.get_per_item( to_number(mt.serial_number), ''A_PER_NATIONAL_IDENTIFIER''), ''Applied For''),
 ''Zip_Code'',hr_us_w2_rep.get_w2_postal_code( paf.person_id,'''||l_dt||'''),
 ''Organization'',hou.name, ''Location'',hl.location_code, ''Termination_Reason'',decode(leaving_reason,null,''ZZ'',hr_us_w2_rep.get_leav_reason(leaving_reason)),
  /* Bug 8353425 */
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,'''||l_dt||'''))
 for update of mt.assignment_action_id' ;

-- changed on 11sep02
-- for update of paf.assignment_id';

      len := length(sqlstr); -- return the length of the string.
      hr_utility.trace('End of the sort_Action cursor');
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

end hr_us_w2_mt;

/
