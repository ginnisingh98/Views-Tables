--------------------------------------------------------
--  DDL for Package Body PAY_MX_ISR_FORMAT37
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_ISR_FORMAT37" AS
/* $Header: paymxformat37mt.pkb 120.2 2005/11/15 13:13:42 kthirmiy noship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : paymxisrformat37mt.pkb
Description : This package contains functions and procedures which are
              used to return values for the Format 37 MX ISR Tax report.

Change List
-----------

Version Date      Author     ER/CR No. Description of Change
-------+---------+----------+---------+--------------------------
115.0   26-Sep-05 kthirmiy             Created
115.1   03-Nov-05 kthirmiy             Modified range_cursor and
                                       Action creation.
115.2   14-Nov-05 kthirmiy             Bug fix 4728549
********************************************************************************/
   --
   -- < PRIVATE GLOBALS > ---------------------------------------------------
   --

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




/******************************************************************
Name      : get_parameter
Purpose   : returns the parameter value
******************************************************************/
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
     token_val := name||'=';
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);

     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;

     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
     return par_value;

end get_parameter;


/******************************************************************
Name      : range_cursor
Purpose   : range_cursor to select personids for format37
******************************************************************/
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  l_year               number ;
  l_legal_employer_id  pay_assignment_actions.tax_unit_id%type;
  l_org_id             per_assignments_f.organization_id%type;
  l_loc_id             per_assignments_f.location_id%type;
  l_per_id             per_assignments_f.person_id%type;
  l_curp               per_people_f.national_identifier%type;
  l_asg_set_id         number;
  l_effective_date     date;

begin

    g_debug_flag          := 'Y' ;
--    g_concurrent_flag     := 'Y' ;

   begin
         select to_number(pay_mx_isr_format37.get_parameter('Year',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('LEGAL_EMPLOYER_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('ORG_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('LOC_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('PER_ID',ppa.legislative_parameters)),
                pay_mx_isr_format37.get_parameter('CURP',ppa.legislative_parameters),
                to_number(pay_mx_isr_format37.get_parameter('ASG_SET',ppa.legislative_parameters)),
                ppa.effective_date
         into   l_year,
                l_legal_employer_id,
                l_org_id,
                l_loc_id,
                l_per_id,
                l_curp,
                l_asg_set_id,
                l_effective_date
         from  pay_payroll_actions ppa   /* PYUGEN payroll action id */
         where ppa.payroll_action_id = pactid ;
      Exception
          when no_data_found then
          dbg('Legislative parameters not found for pactid '||to_char(pactid));
          raise;
    end ;

    dbg('Before the range cursor');

    sqlstr := 'select distinct to_number(paa.serial_number)
              from pay_payroll_actions ppa,
                   pay_assignment_actions paa
              where ppa.report_type = ''MX_YREND_ARCHIVE''
                and ppa.action_status = ''C''
                and pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa.legislative_parameters) = '                           || l_legal_employer_id ||
        ' and to_number(to_char(ppa.effective_date,''YYYY'')) = ' || l_year ||
        ' and paa.payroll_action_id = ppa.payroll_action_id
        and paa.action_status =''C''
        and :payroll_action_id is not null
        and NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
        AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                     || l_legal_employer_id ||
        ' AND to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || l_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa.assignment_action_id  )
        order by to_number(paa.serial_number) ';

  dbg('After the range cursor');
  dbg(sqlstr) ;

end range_cursor;

/******************************************************************
Name      : action_creation_format37
Purpose   : action creation procedure for format37
******************************************************************/
procedure action_creation_format37(
               pactid            in number,
               stperson          in number,
               endperson         in number,
               chunk             in number,
               p_year            in number,
               p_legal_employer_id in number,
               p_org_id          in number,
               p_loc_id          in number,
               p_per_id          in number,
               p_curp            in varchar2,
               p_asg_set_id      in number,
               p_effective_date  in date,
               p_report_type     in varchar2,
               p_report_category in varchar2,
               p_report_qualifier in varchar2 )
  is

  l_procedure_name    VARCHAR2(100);
  l_report_format     pay_report_format_mappings_f.report_format%type;
  l_range_person_on   BOOLEAN;

  lockingactid    number;
  lockedactid     number;
  assignid        number;
  greid           number;
  l_serial_number number;
  l_person_id     number;
  l_eff_date      date ;
  l_pai_eff_date  date ;
  num             number;

  TYPE RefCurType is REF CURSOR;
  c_actions    RefCurType;

  c_actions_sql  varchar2(10000);

begin
    l_procedure_name := 'action_creation_format37';
    hr_utility.set_location(l_procedure_name, 1);

    Begin
      select report_format
        into l_report_format
        from pay_report_format_mappings_f
       where report_type = p_report_type
         and report_qualifier = p_report_qualifier
         and report_category = p_report_category
         and p_effective_date between
                   effective_start_date and effective_end_date;
    Exception
       When Others Then
          l_report_format := Null ;
    End ;

    hr_utility.set_location(l_procedure_name, 2);
    l_range_person_on := pay_ac_utility.range_person_on
                                    ( p_report_type      => p_report_type,
                                      p_report_format    => l_report_format,
                                      p_report_qualifier => p_report_qualifier,
                                      p_report_category  => p_report_category);

    /* when no selection is entered */
    if((p_loc_id is null ) and
       (p_org_id is null ) and
       (p_per_id is null ) and
       (p_curp    is null ) and
       (p_asg_set_id is null ))       then

       hr_utility.set_location(l_procedure_name, 5);
       dbg('Selection criteria is Null') ;

       if l_range_person_on = TRUE Then
          hr_utility.set_location(l_procedure_name, 10);
          dbg('Range Person ID Functionality is enabled') ;
          c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai,
                    pay_population_ranges ppr
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
        ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND ppr.person_id = to_number(paa_arch.serial_number)
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
       ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
      order by paa_arch.serial_number ';

       else
          hr_utility.set_location(l_procedure_name, 20);
          dbg('Range Person ID Functionality is NOT enabled') ;
          c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai
     WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
     AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
        ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
                AND to_number(paa_arch.serial_number) between ' || stperson || ' and ' || endperson || '
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
      order by paa_arch.serial_number ';

       end if ; -- l_range_person_on

      end if;     /* End of when no selection is entered */

      /* when location is entered */

      if p_loc_id is not null then

         hr_utility.set_location(l_procedure_name, 30);
         dbg('Selection criteria is Location') ;

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 35);
            c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai,
                    pay_population_ranges ppr
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
        ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || p_effective_date || ''')
                    between paf.effective_start_date and paf.effective_end_date
               AND  paf.location_id = ' || p_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_effective_date || ''')
                AND paf.effective_end_date >= ppa_arch.start_date
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
       ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
          order by paa_arch.serial_number ';

         else
            hr_utility.set_location(l_procedure_name, 40);
            c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai
      WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
      AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
              ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || p_effective_date || ''')
                    between paf.effective_start_date and paf.effective_end_date
               AND  paf.location_id = ' || p_loc_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_effective_date || ''')
                AND paf.effective_end_date >= ppa_arch.start_date
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
         order by paa_arch.serial_number  ';

         end if ;

      end if;       /* End of when location is entered */


      /* when org is entered */
      if p_org_id is not null then

         hr_utility.set_location(l_procedure_name, 50);
         dbg('Selection criteria is Organization') ;

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 60);
            dbg('Range Person ID Functionality is enabled') ;
            c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai,
                    pay_population_ranges ppr
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
       ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || p_effective_date || ''')
                    between paf.effective_start_date and paf.effective_end_date
               AND  paf.organization_id = ' || p_org_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_effective_date || ''')
                AND paf.effective_end_date >= ppa_arch.start_date
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND ppr.payroll_action_id = ' || pactid || '
                AND ppr.chunk_number = ' || chunk || '
                AND paf.person_id = ppr.person_id
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
             order by paa_arch.serial_number ';

         else

            hr_utility.set_location(l_procedure_name, 70);
            c_actions_sql :=
            'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_periods_of_service pps,
                    per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
       ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
              ' AND ppa_arch.action_status =''C''
                AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
                AND paa_arch.action_status =''C''
               AND  paa_arch.assignment_id = paf.assignment_id
               AND  nvl(pps.final_process_date,''' || p_effective_date || ''')
                    between paf.effective_start_date and paf.effective_end_date
               AND  paf.location_id = ' || p_org_id  || '
               AND  paf.effective_start_date =
                    (select max(paf2.effective_start_date)
                     from per_assignments_f paf2
                     where paf2.assignment_id = paf.assignment_id
                     and paf2.effective_start_date <= ''' || p_effective_date || ''')
                AND paf.effective_end_date >= ppa_arch.start_date
                AND paf.assignment_type = ''E''
                AND pps.period_of_service_id = paf.period_of_service_id
                AND paf.person_id between ' || stperson || ' and ' || endperson || '
                and pai.action_information_category = ''MX YREND EE DETAILS''
                and pai.action_context_id = paa_arch.assignment_action_id
                AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
            order by paa_arch.serial_number ';

         end if ;

      end if; /* End of when org is entered */


      /* when person or CURP is entered */
      if (p_per_id is not null OR p_curp is not null ) then

         hr_utility.set_location(l_procedure_name, 80);
         dbg('Selection criteria is either Employee Name or CURP') ;

         c_actions_sql := 'SELECT paa_arch.serial_number,
                                  pai.effective_date,
                                  paa_arch.assignment_action_id,
              paa_arch.assignment_id,
              paa_arch.tax_unit_id
       FROM  per_assignments_f paf,
             pay_payroll_actions    ppa_arch,
             pay_assignment_actions paa_arch,
             pay_action_information pai
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
         AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
       ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
       ' AND ppa_arch.action_status =''C''
         AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
         AND paa_arch.action_status =''C''
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.PERSON_ID = ' || p_per_id  || '
         AND paa_arch.assignment_id = paf.assignment_id
         AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_assignments_f paf2
                                         where paf2.assignment_id = paf.assignment_id
                                           and paf2.effective_start_date <= ''' || p_effective_date || ''')
         AND paf.effective_end_date >= ppa_arch.start_date
         AND paf.assignment_type = ''E''
         AND paf.person_id between ' || stperson || ' and ' || endperson || '
         and pai.action_information_category = ''MX YREND EE DETAILS''
         and pai.action_context_id = paa_arch.assignment_action_id
         AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
         order by paa_arch.serial_number ';

      end if; /* End of when person or CURP is entered */

      /* when assignment set is entered */
      if p_asg_set_id is not null then

         hr_utility.set_location(l_procedure_name, 90);
         dbg('Selection criteria is Assignment set') ;

         if l_range_person_on = TRUE Then
            hr_utility.set_location(l_procedure_name, 100);
            dbg('Range Person ID Functionality is enabled') ;
            c_actions_sql :=
  	      'SELECT paa_arch.serial_number,
                      pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai,
                    pay_population_ranges ppr
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
       ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
            ' AND ppa_arch.action_status =''C''
              AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
              AND paa_arch.action_status =''C''
              AND paa_arch.assignment_id = paf.assignment_id
              AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_effective_date || ''')
              AND paf.effective_end_date >= ppa_arch.start_date
              AND paf.assignment_type = ''E''
              AND ppr.payroll_action_id = ' || pactid || '
              AND ppr.chunk_number = ' || chunk || '
              AND paf.person_id = ppr.person_id
              and pai.action_information_category = ''MX YREND EE DETAILS''
              and pai.action_context_id = paa_arch.assignment_action_id
              AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
              AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || p_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'')
            order by paa_arch.serial_number ';

         else
            hr_utility.set_location(l_procedure_name, 110);
            c_actions_sql :=
			'SELECT paa_arch.serial_number,
                    pai.effective_date,
                    paa_arch.assignment_action_id,
                    paa_arch.assignment_id,
                    paa_arch.tax_unit_id
              FROM  per_assignments_f paf,
                    pay_payroll_actions    ppa_arch,
                    pay_assignment_actions paa_arch,
                    pay_action_information pai
       WHERE  ppa_arch.report_type=''MX_YREND_ARCHIVE''
       AND to_number(pay_mx_isr_format37.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',ppa_arch.legislative_parameters)) = '
                   ||  p_legal_employer_id ||
            ' and to_number(to_char(ppa_arch.effective_date,''YYYY'')) = ' || p_year ||
            ' AND ppa_arch.action_status =''C''
              AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
              AND paa_arch.action_status =''C''
              AND paa_arch.assignment_id = paf.assignment_id
              AND paf.effective_start_date = (select max(paf2.effective_start_date)
                                          from per_assignments_f paf2
                                          where paf2.assignment_id = paf.assignment_id
                                          and paf2.effective_start_date <= ''' || p_effective_date || ''')
              AND paf.effective_end_date >= ppa_arch.start_date
              AND paf.assignment_type = ''E''
              AND paf.person_id between ' || stperson || ' and ' || endperson || '
              and pai.action_information_category = ''MX YREND EE DETAILS''
              and pai.action_context_id = paa_arch.assignment_action_id
              AND NOT EXISTS(
                    SELECT ''x''
                    FROM pay_payroll_actions    ppa1,
                         pay_assignment_actions paa1,
                         pay_action_interlocks  palock
                   WHERE paa1.payroll_action_id    = ppa1.payroll_action_id
                     AND ppa1.report_type          = ''ISR_TAX_FORMAT37''
                     AND ppa1.report_qualifier     = ''DEFAULT''
                     AND ppa1.report_category      = ''REPORT''
                     AND paa1.action_status        = ''C''
          AND to_number(pay_mx_isr_format37.get_parameter(''LEGAL_EMPLOYER_ID'',ppa1.legislative_parameters)) ='
                 || p_legal_employer_id ||
        ' and to_number(to_char(ppa1.effective_date,''YYYY'')) = ' || p_year ||
        ' AND palock.locking_action_id = paa1.assignment_action_id
          and palock.locked_action_id = paa_arch.assignment_action_id  )
              AND exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         = ' || p_asg_set_id || '
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = ''I'')
                order by paa_arch.serial_number ';
        end if ;

      end if; /* End of when assignment set is entered */


       hr_utility.set_location(l_procedure_name, 120);
       dbg('Opening c_actions cursor');
       dbg(c_actions_sql);

       l_serial_number := null ;
       l_eff_date      := null ;

       OPEN c_actions FOR c_actions_sql;
       num := 0;
       loop
          fetch c_actions into l_person_id, l_pai_eff_date, lockedactid,assignid,greid;
          if c_actions%found then
             num := num + 1;
             dbg('In the c_actions%found in action cursor');
          else
             dbg('In the c_actions%notfound in action cursor');
             exit;
          end if;

           hr_utility.set_location(l_procedure_name, 125);

           dbg( to_char(l_serial_number)) ;
           dbg( to_char(l_eff_date,'DD-MON-YYYY') ) ;
           dbg( to_char(l_person_id)) ;
           dbg( to_char(l_pai_eff_date,'DD-MON-YYYY') ) ;


           if l_serial_number is null or
              l_eff_date is null or
              l_serial_number <> l_person_id or
              l_eff_date <> l_pai_eff_date  then

              dbg('Inserting action record');
              dbg('Record ' || to_char(num) );
              select pay_assignment_actions_s.nextval
              into   lockingactid
              from   dual;

              -- insert the action record.
              hr_nonrun_asact.insact(lockingactid,assignid,pactid,chunk,greid);

              dbg('Updating serial number');

              -- Update serial_number of Pay_assignment_actions with the
              -- assignment_action_id .
              update pay_assignment_actions
              set serial_number = lockedactid
              where assignment_action_id = lockingactid;

              l_serial_number := l_person_id ;
              l_eff_date      := l_pai_eff_date ;

           end if;

           dbg('Before Inserting action interlock record');
           dbg('lockingactionid ' || to_char(lockingactid) );
           dbg('lockedactionid  ' || to_char(lockedactid) );

           -- insert record in action interlocks
     	   hr_nonrun_asact.insint(lockingactid, lockedactid);

           dbg('After Inserting action interlock record');

         end loop;
         close c_actions;

      hr_utility.set_location(l_procedure_name, 300);
      dbg('End of the action creation format37');

end action_creation_format37;


/******************************************************************
Name      : action_creation
Purpose   : main action creation procedure
******************************************************************/
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is


  l_year               number ;
  l_legal_employer_id  pay_assignment_actions.tax_unit_id%type;
  l_org_id             per_assignments_f.organization_id%type;
  l_loc_id             per_assignments_f.location_id%type;
  l_per_id             per_assignments_f.person_id%type;
  l_curp               per_people_f.national_identifier%type;
  l_asg_set_id         number;
  l_effective_date     date;
  l_report_type      pay_payroll_actions.report_type%TYPE;
  l_report_category   pay_payroll_actions.report_category%type;
  l_report_qualifier  pay_payroll_actions.report_qualifier%type;

  begin

     g_debug_flag          := 'Y' ;
--     g_concurrent_flag     := 'Y' ;

  -- hr_utility.trace_on(null,'ORACLE');
    hr_utility.set_location('procpyr',1);
    dbg('In  the action cursor');
      Begin
         select to_number(pay_mx_isr_format37.get_parameter('Year',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('LEGAL_EMPLOYER_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('ORG_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('LOC_ID',ppa.legislative_parameters)),
                to_number(pay_mx_isr_format37.get_parameter('PER_ID',ppa.legislative_parameters)),
                pay_mx_isr_format37.get_parameter('CURP',ppa.legislative_parameters),
                to_number(pay_mx_isr_format37.get_parameter('ASG_SET',ppa.legislative_parameters)),
                ppa.effective_date,
                ppa.report_type,
                ppa.report_category,
                ppa.report_qualifier
         into   l_year,
                l_legal_employer_id,
                l_org_id,
                l_loc_id,
                l_per_id,
                l_curp,
                l_asg_set_id,
                l_effective_date,
                l_report_type,
                l_report_category,
                l_report_qualifier
         from  pay_payroll_actions ppa   /* PYUGEN payroll action id */
         where ppa.payroll_action_id = pactid ;
      Exception
          when no_data_found then
          dbg('Legislative parameters not found for pactid '||to_char(pactid));
          raise;
      End ;
      dbg('report_type     = '||l_report_type);


/* Now the CURP value set return person_id. Since the submission is based on
   selection citeria only one value can be entered so in case l_curp is not
   null then it is safe to assume l_per_id is null */

      if l_curp is not null then
         l_per_id := l_curp;
      end if;

      if l_report_type = 'ISR_TAX_FORMAT37' then /* Format 37 */

         action_creation_format37(pactid,
                                  stperson,
                                  endperson,
                                  chunk,
                                  l_year,
                                  l_legal_employer_id,
                                  l_org_id,
                                  l_loc_id,
                                  l_per_id,
                                  l_curp,
                                  l_asg_set_id,
                                  l_effective_date,
                                  l_report_type,
                                  l_report_category,
                                  l_report_qualifier
                                );
      end if;

end action_creation;


end pay_mx_isr_format37;

/
