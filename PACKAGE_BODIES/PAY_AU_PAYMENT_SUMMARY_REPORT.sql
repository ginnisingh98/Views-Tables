--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYMENT_SUMMARY_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYMENT_SUMMARY_REPORT" as
/* $Header: pyaupsrp.pkb 120.4.12010000.5 2009/12/16 14:20:26 dduvvuri ship $*/
/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_payment_summary_report (Package Body)
***
*** Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 01 MAR 01  kaverma     1.0           Initial version
*** 28 Nov 01  nnaresh     1.1           Updated for GSCC Standards
*** 29 Nov 01  nnaresh     1.2           Replaced REM with ***
*** 03 DEC 02  Ragovind    1.7           Added NOCOPY for the function range_code.
*** 18 FEB 03  nanuradh    1.8  2786549  Removed number_of_copies parameter when setting
***                                      printer options
*** 25 FEB 03  nanuradh    1.9  2786549  Removed the fix done for the bug #2786549
*** 29 MAY 03  apunekar    1.10 2920725  Corrected base tables to support security model
*** 17 NOV 03  avenkatk    1.11 3132172  Added support for printing report on
***                                      duplex printers.
*** 10 FEB 04  punmehta    1.12 3098353  Added check for archive flag
*** 21 JUL 04  srrajago    1.13 3768288  Modified cursor 'csr_get_print_options' to fetch value 'number_of_copies'
***                                      and the same is passed to fnd_request.set_print_options.Resolved GSCC warning in
***                                      assigning value -1 to ps_request_id.
*** 09 AUG 04  abhkumar    1.14 2610141  Legal Employer Enhancement
*** 09 DEC 04  ksingla     1.15 3937976  Added check for archive flag X_CURR_TERM_0_BAL_FLAG
*** 06 DEC 05  avenkatk    1.16 4859876  Added support for XML Publisher PDF Template
*** 02 JAN 06  avenkatk    1.17 4891196  Added support for PDF and Postscript generation of report.
*** 03 Jan 06  abhargav    1.18 4726357  Added function to get the self serivce option.
*** 28_feb-07  abhargav    1.20 5743270  Added check so that empty self printed report will not be generated
***                                      for cases where for all the assignment Self Printed flag is set 'Yes'.
*** 09-Jan-08  avenkatk    115.21 6470581  Added Changes for Amended Payment Summary
*** 23-Jan-08  avenkatk    115.22 6470581  Resolved GSCC Errors
*** 26 May 09  avenkatk    115.23 8501365  Added RANGE_PERSON_ID for Self Printed Payment Summary
*** 11 Dec 09  dduvvuri    115.25 9113084  Added RANGE_PERSON_ID for Amended Self Printed Payment Summary
*** ------------------------------------------------------------------------+
*/

  g_debug       boolean;  /* Bug 6470581 */

  -------------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archive report process.
  -------------------------------------------------------------------------

  procedure range_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_sql                 out NOCOPY varchar2) is
  begin
     hr_utility.set_location('Start of range_code',1);

    /*Bug2920725   Corrected base tables to support security model*/

      p_sql := ' select distinct p.person_id'                                     ||
             ' from   per_people_f p,'                                        ||
                    ' pay_payroll_actions pa'                                     ||
             ' where  pa.payroll_action_id = :payroll_action_id'                  ||
             ' and    p.business_group_id = pa.business_group_id'                 ||
             ' order by p.person_id';

     hr_utility.set_location('End of range_code',2);
  end range_code;


/*
    Bug 8501365 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
   Bug 9113084 - Check if Range Person is enabled for Self Printed Payment Summary
*/

FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_PAYMENT_SUMMARY_REPORT'
  and    map.report_format = 'AU_PAYMENT_SUMMARY_REPORT'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID';

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;

  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     IF g_debug THEN
         hr_utility.set_location('Range Person = True',1);
     END IF;
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;


 -------------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code and locks the Assignment Actions for which
  -- a Payment Summry Report has been printed.
 -------------------------------------------------------------------------


-- this procedure filters the assignments selected by range_code procedure
-- it then calls hr_nonrun.insact to create an assignment  id
-- the cursor to select assignment action selects assignment id for which
-- archival has been done.

procedure assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number) is

    v_next_action_id  pay_assignment_actions.assignment_action_id%type;

    /*Bug2920725   Corrected base tables to support security model*/


      cursor process_assignments
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_start_person_id    in per_all_people_f.person_id%type,
         c_end_person_id      in per_all_people_f.person_id%type) is
         select  distinct a.assignment_id,
                 pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters) archive_action_id,
                 ppac.assignment_action_id
                from   per_assignments_f a,
                       per_people_f p,
                       pay_payroll_actions pa,
                       pay_payroll_actions ppa,
                       pay_assignment_actions ppac
                where  pa.payroll_action_id   = c_payroll_action_id
                 and    p.person_id             between c_start_person_id and c_end_person_id
                 and    p.person_id           = a.person_id
                 and    p.business_group_id   = pa.business_group_id
                 and    ppa.payroll_action_id = ppac.payroll_action_id
                 and    a.assignment_id       = ppac.assignment_id
                 and    ppa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters)
                 And    ppa.action_type       = 'X'
                 and    ppa.action_status     = 'C'
                 and    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG', ppac.assignment_action_id)='YES'   --3098353
                 and    pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG', ppac.assignment_action_id)='NO'   --3937976
                 and  not exists
                            (select locked_action_id
                             FROM   pay_action_interlocks pail
                           WHERE pail.locked_action_id=ppac.assignment_action_id)
                 and ppac.assignment_action_id in
                         (select max(ppac1.assignment_action_id)
                          from pay_assignment_actions ppac1,
                               pay_payroll_Actions    ppaa
                          where ppaa.action_type       ='X'
                           and  ppaa.action_status     ='C'
                           and  pay_core_utils.get_parameter('REGISTERED_EMPLOYER', ppaa.legislative_parameters) =
                                pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pa.legislative_parameters) --2610141
                           and  ppaa.report_type       ='AU_PAYMENT_SUMMARY'
                           and  ppaa.payroll_Action_id = ppac1.payroll_action_id
                          group by ppac1.assignment_id);

/*
   Bug 8501365 - Added Cursor for Range Person
               - Uses person_id in pay_population_ranges
  --------------------------------------------------------------------+
  -- Cursor      : range_process_assignments
  -- Description : Fetches assignments For Payment Summary
  --               Returns DISTINCT assignment_id
  --               Used when RANGE_PERSON_ID feature is enabled
  --------------------------------------------------------------------+
*/


CURSOR range_process_assignments
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_chunk              in NUMBER)
IS
SELECT  DISTINCT a.assignment_id,
        pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters) archive_action_id,
        ppac.assignment_action_id
FROM    per_assignments_f a,
        per_people_f p,
        pay_payroll_actions pa,
        pay_population_ranges ppr,
        pay_payroll_actions ppa,
        pay_assignment_actions ppac
WHERE  pa.payroll_action_id  = c_payroll_action_id
AND   ppr.payroll_action_id  = pa.payroll_action_id
AND   ppr.chunk_number       = c_chunk
AND   p.person_id            = ppr.person_id
AND   p.person_id            = a.person_id
AND   p.business_group_id    = pa.business_group_id
AND   ppa.payroll_action_id  = ppac.payroll_action_id
AND   a.assignment_id        = ppac.assignment_id
AND   ppa.payroll_action_id  = pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters)
AND   ppa.report_type        = 'AU_PAYMENT_SUMMARY'
AND   ppa.report_qualifier   = 'AU'
AND   ppa.report_category    = 'REPORT'
AND   ppa.action_type        = 'X'
AND   ppa.action_status      = 'C'
AND   pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG', ppac.assignment_action_id)='YES'
AND   pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG', ppac.assignment_action_id)='NO'
AND  NOT EXISTS
           (SELECT locked_action_id
            FROM   pay_action_interlocks pail
            WHERE  pail.locked_action_id   = ppac.assignment_action_id)
AND ppac.assignment_action_id IN
        (SELECT MAX(ppac1.assignment_action_id)
         FROM pay_assignment_actions ppac1,
              pay_payroll_Actions    ppaa
         where ppaa.action_type       ='X'
          AND  ppaa.action_status     ='C'
          AND  pay_core_utils.get_parameter('REGISTERED_EMPLOYER', ppaa.legislative_parameters) =
               pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pa.legislative_parameters)
          AND  ppaa.report_type       = 'AU_PAYMENT_SUMMARY'
          AND  ppaa.report_qualifier  = 'AU'
          AND  ppaa.report_category   = 'REPORT'
          AND  ppac1.assignment_id    = ppac.assignment_id
          AND  ppaa.payroll_Action_id = ppac1.payroll_action_id
         GROUP BY ppac1.assignment_id);



  cursor next_action_id is
        select pay_assignment_actions_s.nextval
        from   dual;


/* Bug 6470581 - Added the Following cursors to get Payment Summary Information
   and asignments eligible for Self Printed process for Amended PS
*/

CURSOR c_get_paysum_details
        (c_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE)
IS
SELECT to_number(pay_core_utils.get_parameter('REGISTERED_EMPLOYER', ppa.legislative_parameters)) registered_employer
      ,pay_core_utils.get_parameter('ARCHIVE_ID', ppa.legislative_parameters)           archive_id
      ,NVL(pay_core_utils.get_parameter('PAY_SUM_TYPE', ppa.legislative_parameters),'O')       payment_summary_type
      ,pay_core_utils.get_parameter('FINANCIAL_YEAR', ppa.legislative_parameters)       fin_year
FROM pay_payroll_actions ppa
WHERE ppa.payroll_action_id = c_payroll_action_id;


CURSOR c_amend_process_assignments
        (c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
        ,c_start_person_id    IN per_all_people_f.person_id%TYPE
        ,c_end_person_id      IN per_all_people_f.person_id%TYPE
        ,c_archive_id         IN pay_payroll_actions.payroll_action_id%TYPE
        ,c_reg_emp            IN pay_assignment_actions.tax_unit_id%TYPE
        ,c_financial_year     VARCHAR2)
IS
SELECT  DISTINCT a.assignment_id
        ,pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters) archive_action_id
        ,ppac.assignment_action_id
        ,pmaa.assignment_action_id datafile_action_id
FROM     per_assignments_f a
        ,per_people_f p
        ,pay_payroll_actions pa
        ,pay_payroll_actions ppa
        ,pay_assignment_actions ppac
        ,pay_assignment_actions pmaa
        ,pay_payroll_actions pmpa
WHERE  pa.payroll_action_id   = c_payroll_action_id
AND    p.person_id             between c_start_person_id and c_end_person_id
AND    p.person_id           = a.person_id
AND    p.business_group_id   = pa.business_group_id
AND    ppa.payroll_action_id = ppac.payroll_action_id
AND    a.assignment_id       = ppac.assignment_id
AND    ppa.payroll_action_id = c_archive_id
AND    ppa.action_type       = 'X'
AND    ppa.action_status     = 'C'
AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG', ppac.assignment_action_id)='YES'
AND    pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG', ppac.assignment_action_id)='NO'
AND    pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE', ppac.assignment_action_id)='A'   /* Indicates something has changed */
AND    pmaa.assignment_id    = ppac.assignment_id
AND    pmaa.payroll_action_id = pmpa.payroll_action_id
AND    pmpa.report_type       = 'AU_PS_DATA_FILE'
AND    pmpa.action_type       = 'X'
AND    pmpa.action_status     = 'C'
AND    pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pmpa.legislative_parameters) = c_reg_emp
AND    pay_core_utils.get_parameter('FINANCIAL_YEAR', pmpa.legislative_parameters) = c_financial_year
AND  NOT EXISTS
        (SELECT locked_action_id
         FROM  pay_action_interlocks pail
         WHERE pail.locked_action_id=ppac.assignment_action_id)
AND ppac.assignment_action_id IN
                        (SELECT MAX(ppac1.assignment_action_id)
                         FROM   pay_assignment_actions ppac1,
                                pay_payroll_Actions    ppaa
                         WHERE ppaa.action_type       ='X'
                         AND   ppaa.action_status     ='C'
                         AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER', ppaa.legislative_parameters) =
                                pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pa.legislative_parameters) --2610141
                         AND  ppaa.report_type       ='AU_PAY_SUMM_AMEND'
                         AND  ppaa.payroll_Action_id = ppac1.payroll_action_id
                         GROUP BY ppac1.assignment_id);

/* 9113084 - Added new cursor for above cursor c_amend_process_assignments */
/* 9113084 - Cursor to fetch assignments for Self Printed Amended Payment Summary when RANGE_PERSON_ID is enabled */
CURSOR rg_amend_process_assignments
        (c_payroll_action_id  IN pay_payroll_actions.payroll_action_id%TYPE
        ,c_chunk IN NUMBER
        ,c_archive_id         IN pay_payroll_actions.payroll_action_id%TYPE
        ,c_reg_emp            IN pay_assignment_actions.tax_unit_id%TYPE
        ,c_financial_year     VARCHAR2)
IS
SELECT  DISTINCT a.assignment_id
        ,pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters) archive_action_id
        ,ppac.assignment_action_id
        ,pmaa.assignment_action_id datafile_action_id
FROM     per_assignments_f a
        ,per_people_f p
        ,pay_payroll_actions pa
        ,pay_payroll_actions ppa
        ,pay_assignment_actions ppac
        ,pay_assignment_actions pmaa
        ,pay_payroll_actions pmpa
	,pay_population_ranges ppr
WHERE  pa.payroll_action_id   = c_payroll_action_id
AND    ppr.payroll_action_id = pa.payroll_action_id
AND    ppr.chunk_number = c_chunk
AND    p.person_id             = ppr.person_id
AND    p.person_id           = a.person_id
AND    p.business_group_id   = pa.business_group_id
AND    ppa.payroll_action_id = ppac.payroll_action_id
AND    a.assignment_id       = ppac.assignment_id
AND    ppa.payroll_action_id = c_archive_id
AND    ppa.action_type       = 'X'
AND    ppa.action_status     = 'C'
AND    pay_au_payment_summary.get_archive_value('X_REPORTING_FLAG', ppac.assignment_action_id)='YES'
AND    pay_au_payment_summary.get_archive_value('X_CURR_TERM_0_BAL_FLAG', ppac.assignment_action_id)='NO'
AND    pay_au_payment_summary.get_archive_value('X_PAYMENT_SUMMARY_TYPE', ppac.assignment_action_id)='A'
AND    pmaa.assignment_id    = ppac.assignment_id
AND    pmaa.payroll_action_id = pmpa.payroll_action_id
AND    pmpa.report_type       = 'AU_PS_DATA_FILE'
AND    pmpa.action_type       = 'X'
AND    pmpa.action_status     = 'C'
AND    pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pmpa.legislative_parameters) = c_reg_emp
AND    pay_core_utils.get_parameter('FINANCIAL_YEAR', pmpa.legislative_parameters) = c_financial_year
AND  NOT EXISTS
        (SELECT locked_action_id
         FROM  pay_action_interlocks pail
         WHERE pail.locked_action_id=ppac.assignment_action_id)
AND ppac.assignment_action_id IN
                        (SELECT MAX(ppac1.assignment_action_id)
                         FROM   pay_assignment_actions ppac1,
                                pay_payroll_Actions    ppaa
                         WHERE ppaa.action_type       ='X'
                         AND   ppaa.action_status     ='C'
                         AND   pay_core_utils.get_parameter('REGISTERED_EMPLOYER', ppaa.legislative_parameters) =
                                pay_core_utils.get_parameter('REGISTERED_EMPLOYER', pa.legislative_parameters)
                         AND  ppaa.report_type       ='AU_PAY_SUMM_AMEND'
                         AND  ppaa.payroll_Action_id = ppac1.payroll_action_id
                         GROUP BY ppac1.assignment_id);

l_get_paysum_details c_get_paysum_details%ROWTYPE;

/* End Bug 6470581 */

  BEGIN

  g_debug := hr_utility.debug_enabled;

        IF g_debug
        THEN
               hr_utility.set_location('Start of assignment_action_code',3);
               hr_utility.set_location('The payroll_action_id passed  '|| p_payroll_action_id,4);
               hr_utility.set_location('The p_start_person_id  '|| p_start_person_id,5);
               hr_utility.set_location('The p_end_person_id '|| p_end_person_id,6);
               hr_utility.set_location('The p_chunk number '|| p_chunk ,7);
        END IF;

        /* Bug 6470581 - Fetch the Payment Summary Type details.
                         If Type is 'O' (Original), lock only Archive action
                         If Type is 'A' (Amended) , lock Archive and Original Data file actions
        */

        OPEN c_get_paysum_details(p_payroll_action_id);
        FETCH c_get_paysum_details INTO l_get_paysum_details;
        CLOSE c_get_paysum_details;

IF l_get_paysum_details.payment_summary_type = 'O'
THEN
        /* Bug 8501365 - Added Changes for Range Person
                       - Call Cursor using pay_population_ranges if Range Person Enabled
            Else call Old Cursor
         */
        IF range_person_on
        THEN

               FOR csr_rec IN range_process_assignments(p_payroll_action_id
                                                       ,p_chunk)
                LOOP
                        OPEN next_action_id;
                        FETCH next_action_id into v_next_action_id;
                        CLOSE next_action_id;
                        hr_nonrun_asact.insact(v_next_action_id,
                                               csr_rec.assignment_id,
                                               p_payroll_action_id,
                                               p_chunk,
                                               null);
                        hr_nonrun_asact.insint(v_next_action_id,csr_rec.assignment_action_id);
                        IF g_debug
                        THEN
                                hr_utility.set_location('Assignment_ID                  '||csr_rec.assignment_id,35);
                                hr_utility.set_location('New Ass Action ID              '||v_next_action_id,40);
                                hr_utility.set_location('Locked Archive Action ID       '||csr_rec.assignment_action_id,45);
                        END IF;
                END LOOP;

        ELSE

           for process_rec in process_assignments (p_payroll_action_id,
                                                   p_start_person_id,
                                                   p_end_person_id)
           loop
            hr_utility.set_location('LOOP STARTED   '|| process_rec.assignment_id ,14);
            open next_action_id;
            fetch next_action_id into v_next_action_id;
            close next_action_id;
            hr_utility.set_location('before calling insact  '|| v_next_action_id ,14);
            hr_nonrun_asact.insact(v_next_action_id,
                                     process_rec.assignment_id,
                                     p_payroll_action_id,
                                     p_chunk,
                                   null);
            hr_utility.set_location('inserted assigment action assignment '|| process_rec.assignment_id ,15);
            hr_utility.set_location('Before calling hr_nonrun_asact.insint archive ' || process_rec.archive_action_id,16);
            hr_utility.set_location('v_next_action_id' || v_next_action_id,16);
            hr_nonrun_asact.insint(v_next_action_id,process_rec.assignment_action_id);
            hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
           end loop;
           hr_utility.set_location('End of assignment_action_code',5);
        END IF;

ELSIF l_get_paysum_details.payment_summary_type = 'A'
THEN
       IF range_person_on THEN /* 9113084 - Use new Range Person Cursor if Range Person is enabled */
           IF g_debug THEN
                hr_utility.set_location('Using Range Person Cursor for fetching assignments',30);
           END IF;
       FOR csr_rec IN rg_amend_process_assignments(p_payroll_action_id
                                                 ,p_chunk
                                                 ,l_get_paysum_details.archive_id
                                                 ,l_get_paysum_details.registered_employer
                                                 ,l_get_paysum_details.fin_year)
        LOOP

                OPEN next_action_id;
                FETCH next_action_id into v_next_action_id;
                CLOSE next_action_id;
                hr_nonrun_asact.insact(v_next_action_id,
                                csr_rec.assignment_id,
                                p_payroll_action_id,
                                p_chunk,
                               null);
                hr_nonrun_asact.insint(v_next_action_id,csr_rec.assignment_action_id);
                hr_nonrun_asact.insint(v_next_action_id,csr_rec.datafile_action_id);

                IF g_debug
                THEN
                        hr_utility.set_location('Assignment_ID                  '||csr_rec.assignment_id,35);
                        hr_utility.set_location('New Ass Action ID              '||v_next_action_id,40);
                        hr_utility.set_location('Locked Archive Action ID       '||csr_rec.assignment_action_id,45);
                        hr_utility.set_location('Locked Data file Action ID     '||csr_rec.datafile_action_id,50);
                END IF;
        END LOOP;
       ELSE /* 9113084 - Use Old logic if Range Person is disabled */

       FOR csr_rec IN c_amend_process_assignments(p_payroll_action_id
                                                 ,p_start_person_id
                                                 ,p_end_person_id
                                                 ,l_get_paysum_details.archive_id
                                                 ,l_get_paysum_details.registered_employer
                                                 ,l_get_paysum_details.fin_year)
        LOOP

                OPEN next_action_id;
                FETCH next_action_id into v_next_action_id;
                CLOSE next_action_id;
                hr_nonrun_asact.insact(v_next_action_id,
                                csr_rec.assignment_id,
                                p_payroll_action_id,
                                p_chunk,
                               null);
                hr_nonrun_asact.insint(v_next_action_id,csr_rec.assignment_action_id);
                hr_nonrun_asact.insint(v_next_action_id,csr_rec.datafile_action_id);

                IF g_debug
                THEN
                        hr_utility.set_location('Assignment_ID                  '||csr_rec.assignment_id,35);
                        hr_utility.set_location('New Ass Action ID              '||v_next_action_id,40);
                        hr_utility.set_location('Locked Archive Action ID       '||csr_rec.assignment_action_id,45);
                        hr_utility.set_location('Locked Data file Action ID     '||csr_rec.datafile_action_id,50);
                END IF;
        END LOOP;
	END IF;
END IF;

 exception
    when others then
    hr_utility.set_location('error raised in assignment_action_code procedure ',5);
    raise;
 end assignment_action_code;


 --------------------------------------------------------------------------
  -- This Procedure Actually Calls the Payment Summary Report.
 --------------------------------------------------------------------------

procedure spawn_archive_reports
  is
 l_count                number :=0;
 ps_request_id          NUMBER;
 l_formula_id           ff_formulas_f.formula_id%TYPE;
 l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
 l_sort_order1		varchar2(40);
 l_sort_order2		varchar2(40):=null;
 l_sort_order3		varchar2(40):=null;
 l_sort_order4		varchar2(40):=null;
 l_passed_sort_order    varchar2(40);
 l_print_style          VARCHAR2(2);
 l_current_chunk_number pay_payroll_actions.current_chunk_number%TYPE;
 l_print_together       VARCHAR2(80);
 l_print_return         BOOLEAN;
 l_duplex_print_flag    varchar2(2);
 l_template_name  varchar2(80);      -- Bug 4859876
 l_program_name  varchar2(80);       -- Bug 4891196



 cursor csr_get_current_chunk_number(p_payroll_action_id number) is
 select p.current_chunk_number
 from pay_payroll_actions p
 where payroll_action_id = p_payroll_action_id;


 cursor csr_get_formula_id(p_formula_name VARCHAR2) IS
 SELECT a.formula_id
 FROM     ff_formulas_f a,
          ff_formula_types t
 WHERE a.formula_name      = p_formula_name
          AND business_group_id   IS NULL
          AND legislation_code    = 'AU'
          AND a.formula_type_id   = t.formula_type_id
          AND t.formula_type_name = 'Oracle Payroll';


 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output,
          number_of_copies  /* Bug: 3768288 */
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

  /*Bug# 5743270
    Cursor checks whether any assignment exist for which Printed Payment Summary(PUI) need to be produced
    */
  cursor csr_is_assignemnt_exist (p_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE) is
  select count(ppav.assignment_id)
    from   pay_au_eoy_values_v ppav,
           pay_payroll_actions ppa,
           pay_assignment_actions pac
           where ppa.payroll_action_id= p_payroll_action_id
           and   ppav.payroll_action_id =pay_core_utils.get_parameter('ARCHIVE_ID',ppa.legislative_parameters)
           and   ppa.report_type='AU_PAYMENT_SUMMARY_REPORT'
           and   ppav.assignment_id=pac.assignment_id
           and   ppav.X_REPORTING_FLAG = 'YES'
           and   ppav.X_CURR_TERM_0_BAL_FLAG='NO'
           and   pac.payroll_action_id=p_payroll_action_id
           and decode(pay_core_utils.get_parameter('SS_PREF',ppa.legislative_parameters),'N',ss_pref(pac.assignment_id),'N') ='N'
           ;


 rec_print_options  csr_get_print_options%ROWTYPE;
  l_assignment_exist number;  /* Bug#5743270 */
 Function get_sort_order_value(l_passed_sort_order in varchar2)
 return varchar2 is
 l_sort_order varchar2(40);
 begin
   if    l_passed_sort_order  = 'EMPLOYEE_TYPE'
   then  l_sort_order := 'employee_type';
   elsif l_passed_sort_order  = 'ASSIGNMENT_LOCATION'
   then  l_sort_order := 'assignment_location';
   elsif l_passed_sort_order  = 'EMPLOYEE_NUMBER'
   then  l_sort_order := 'employee_number';
   elsif l_passed_sort_order  = 'PAYROLL'
   then  l_sort_order := 'payroll';
   elsif l_passed_sort_order  = 'EMPLOYEE_SURNAME'
   then  l_sort_order := 'employee_last_name';
   else
         l_sort_order:=null;
   end if;
   return l_sort_order;
 end get_sort_order_value;


Begin
  ps_request_id := -1;

  Begin
     LOOP
       l_count := l_count + 1;
       hr_utility.set_location('Before payroll action' , 25);
       hr_utility.set_location('mag_internal ' || pay_mag_tape.internal_prm_names(l_count) , 105);
       hr_utility.set_location('mag_internal ' || pay_mag_tape.internal_prm_values(l_count) , 115);
       l_passed_sort_order:=pay_mag_tape.internal_prm_names(l_count);
       IF    pay_mag_tape.internal_prm_names(l_count)  = 'TRANSFER_PAYROLL_ACTION_ID'
       THEN
             l_payroll_action_id := to_number(pay_mag_tape.internal_prm_values(l_count));
             hr_utility.set_location('payroll_action ',0);
       ELSIF l_passed_sort_order= 'SORT_ORDER1'
       THEN
             l_sort_order1 := pay_mag_tape.internal_prm_values(l_count);
                          hr_utility.set_location('in sort order1 ',1);
       ELSIF l_passed_sort_order= 'SORT_ORDER2'
       THEN
             l_sort_order2 := pay_mag_tape.internal_prm_values(l_count);
             hr_utility.set_location('in sort_order 2 ',2);
       ELSIF l_passed_sort_order= 'SORT_ORDER3'
       THEN
             hr_utility.set_location('in sort_order3 ',3);
             l_sort_order3 := pay_mag_tape.internal_prm_values(l_count);
       ELSIF l_passed_sort_order= 'SORT_ORDER4'
       THEN
          l_sort_order4 := pay_mag_tape.internal_prm_values(l_count);
             hr_utility.set_location('in sort_orderr4 ',4);
    /* Bug 3132172 Duplex Printing Support*/
       ELSIF pay_mag_tape.internal_prm_names(l_count)  = 'DUPLEX_PRINT_FLAG'
       THEN
         l_duplex_print_flag := pay_mag_tape.internal_prm_values(l_count);
             hr_utility.set_location('in duplex_print_flag',5);
     /* Bug 4859876 - Template Code for PDF Output */
       ELSIF pay_mag_tape.internal_prm_names(l_count) = 'TMPL'
       THEN
         l_template_name := pay_mag_tape.internal_prm_values(l_count);
            hr_utility.set_location('in Template Names'||l_template_name,6);
       END IF;

     END LOOP;
     EXCEPTION
       WHEN no_data_found THEN
            -- Use this exception to exit loop as no. of plsql tab items
            -- is not known beforehand. All values should be assigned.
       NULL;
       WHEN value_error THEN
       NULL;
   End;


 l_sort_order1:=get_sort_order_value(l_sort_order1);
 hr_utility.set_location('getting sort_order1'||l_sort_order1, 121);
 l_sort_order2:=get_sort_order_value(l_sort_order2);
 hr_utility.set_location('getting sort_order2'||l_sort_order2, 122);
 l_sort_order3:=get_sort_order_value(l_sort_order3);
 hr_utility.set_location('getting sort_order3'||l_sort_order3, 123);
 l_sort_order4:=get_sort_order_value(l_sort_order4);
 hr_utility.set_location('getting sort_order4'||l_sort_order4, 124);



hr_utility.set_location('getting current chunk_number ', 125);

 OPEN csr_get_current_chunk_number(l_payroll_action_id);
 fetch csr_get_current_chunk_number into l_current_chunk_number;
 CLOSE csr_get_current_chunk_number;

 /* Bug#5743270
    Cursor checks whether any assignment exist for which Printed Payment Summary(PUI) need to be produced
 */
 OPEN csr_is_assignemnt_exist(l_payroll_action_id);
 fetch csr_is_assignemnt_exist into l_assignment_exist;
 CLOSE csr_is_assignemnt_exist;


 if l_current_chunk_number <> 0  and  l_assignment_exist > 0
 then

      hr_utility.set_location('Afer payroll action ' || l_payroll_action_id , 125);
      --hr_utility.set_location('sort ' || l_sort_order,166);
      hr_utility.set_location('Before calling report',24);

       OPEN csr_get_print_options(l_payroll_action_id);
       FETCH csr_get_print_options INTO rec_print_options;
       CLOSE csr_get_print_options;
       --
       l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');
       --
       -- Set printer options
       l_print_return := fnd_request.set_print_options
                           (printer        => rec_print_options.printer,
                            style          => rec_print_options.print_style,
                            copies         => rec_print_options.number_of_copies, /* Bug: 3768288 */
                            save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                            print_together => l_print_together);
    -- Submit report
      hr_utility.set_location('payroll_action id    '|| l_payroll_action_id,25);

      /* Bug 4891196 - Determine Report to be submitted,
         i.  If Template is Null, then Postscript output
         ii. If Template is NOT Null, then XML/PDF output.
      */

      if  l_template_name is NULL
      then
            l_program_name := 'PYAUPSRP_PS';
      else
            l_program_name := 'PYAUPSRP';
      end if;

ps_request_id := fnd_request.submit_request
 ('PAY',
  l_program_name,                               -- Bug 4891196
   null,
   null,
   false,
   'P_PAYROLL_ACTION_ID='||to_char(l_payroll_action_id),
   'P_SORT_ORDER1='||l_sort_order1,
   'P_SORT_ORDER2='||l_sort_order2,
   'P_SORT_ORDER3='||l_sort_order3,
   'P_SORT_ORDER4='||l_sort_order4,
   'P_DUPLEX_PRINT_FLAG='|| l_duplex_print_flag, -- Bug 3132172
   'P_TEMPLATE_NAME='||l_template_name,          -- Bug 4859876
   'BLANKPAGES=NO',
   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,
   NULL,   NULL,   NULL,   NULL,   NULL
);

      hr_utility.set_location('After calling report',24);


end if;

        hr_utility.set_location('Before calling formula',22);

       OPEN csr_get_formula_id('AU_PS_REPORT');
       FETCH csr_get_formula_id INTO l_formula_id;
       CLOSE csr_get_formula_id;

    pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
    pay_mag_tape.internal_prm_values(1) := '5';
    pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
    pay_mag_tape.internal_prm_values(2) := to_char(l_formula_id);
    pay_mag_tape.internal_prm_names(3) := 'PS_REQUEST_ID';
    pay_mag_tape.internal_prm_values(3) := to_char(ps_request_id);
    pay_mag_tape.internal_prm_names(4) := 'PAYROLL_ACTION_ID';
    pay_mag_tape.internal_prm_values(4) := to_char(l_payroll_action_id);
    pay_mag_tape.internal_prm_names(5) := 'SORT_ORDER1';
    pay_mag_tape.internal_prm_values(5) :=l_sort_order1;
    pay_mag_tape.internal_prm_names(6) := 'SORT_ORDER2';
    pay_mag_tape.internal_prm_values(6) :=l_sort_order2;
    pay_mag_tape.internal_prm_names(7) := 'SORT_ORDER3';
    pay_mag_tape.internal_prm_values(7) :=l_sort_order3;
    pay_mag_tape.internal_prm_names(8) := 'SORT_ORDER4';
    pay_mag_tape.internal_prm_values(8) :=l_sort_order4;
--  hr_utility.trace_off;
end spawn_archive_reports;

---
-- Bug 4726357 Added to check whether Self Service Option is enabled for the employee
---

function ss_pref(p_assignemnt_id per_assignments_f.assignment_id%type) return varchar2
is

l_bg_id number;
l_loc_id number;
l_org_id number;
l_person_id number;
l_online_opt char(1);

/* Cursor to get the business group id, location id, organization id and person id */
cursor asg_info is
select  paf.business_group_id, paf.location_id, paf.organization_id,paf.person_id
from per_assignments_f paf
where paf.assignment_id = p_assignemnt_id
  and   paf.effective_start_date =
    (select max(effective_start_date)
     from per_assignments_f paf2
     where paf2.assignment_id = paf.assignment_id
     );

/* Cursor to get the option sets at different level i.e Person level, Location Level, Organization Level and
Business group level. The cursor fetches option in hierarchy . The person level will override location.
Location overrides HR Organization, and HR Organization overrides the option defined at Business Group */

cursor ss_pref (c_bg_id number,c_loc_id number,c_org_id number, c_person_id number)
is
SELECT online_opt
FROM
(
       Select PEI_INFORMATION2 online_opt, 1 sort_col
        from PER_PEOPLE_EXTRA_INFO ppit
        where   ppit.person_id=c_person_id
          and  ppit.pei_information1= 'PAYMENTSUMMARY'
	  and  ppit.information_type='HR_SELF_SERVICE_PER_PREFERENCE'
        union
        Select LEI_INFORMATION2 online_opt, 2 sort_col
        FROM hr_location_extra_info hlei
        WHERE hlei.location_id = c_loc_id
	  And hlei.lei_information1= 'PAYMENTSUMMARY'
          AND hlei.information_type = 'HR_SELF_SERVICE_LOC_PREFERENCE'
        UNION
        SELECT org_information2 online_opt,
               3 sort_col
        FROM hr_organization_information hoi
        WHERE hoi.organization_id = c_org_id
	  and hoi.org_information1 = 'PAYMENTSUMMARY'
          AND hoi.org_information_context = 'HR_SELF_SERVICE_ORG_PREFERENCE'
         UNION
         SELECT org_information2 online_opt,
                4 sort_col
         FROM hr_organization_information hoi
         WHERE hoi.organization_id = c_bg_id
	       And hoi.org_information1 = 'PAYMENTSUMMARY'
               AND hoi.org_information_context = 'HR_SELF_SERVICE_BG_PREFERENCE'
    )
    WHERE online_opt IS NOT NULL
    ORDER BY sort_col;
Begin
 open asg_info;
 fetch asg_info into l_bg_id,l_loc_id,l_org_id,l_person_id;
 close asg_info;


 open ss_pref (l_bg_id,l_loc_id,l_org_id,l_person_id);
 fetch ss_pref into l_online_opt;

/*If no option set at any level online option will be set as No */
 if ss_pref%NOTFOUND THEN
  l_online_opt := 'N';
 end if;
  close ss_pref;

return l_online_opt;
end;

END pay_au_payment_summary_report;

/
