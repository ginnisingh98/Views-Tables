--------------------------------------------------------
--  DDL for Package Body PAY_HK_IR56_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_IR56_REPORT" as
/* $Header: pyhk56rp.pkb 115.7 2003/05/30 08:21:10 kaverma ship $ */
-----------------------------------------------------------------------------
-- Program:     pay_hk_ir56_report (Package Body)
--
-- Description: Various procedures/functions to submit the HK IR56B Year
--              End Report.
--
-- Change History
-- Date       Changed By  Version  Description of Change
-- ---------  ----------  -------  ------------------------------------------
-- 05 Jul 01  S. Russell  115.0    Initial Version
-- 08 Aug 01  S. Russell  115.1    Update change history section. Add join
--                                 of ppa and ppa2 tables in
--                                 get_full_report_runs cursor.
-- 12 Nov 01  J.Lin       115.2    Defined l_error in assignment_action_code
--                                 function to replace g_error which is
--                                 removed from package header. Removed
--                                 variable g_error from submit_report
--                                 function. Bug 2087384
--                                 Added dbdrv line
-- 02 Dec 02  srrajago    115.3    Included 'nocopy' option for the 'OUT'
--                                 parameter of the procedure 'range_code'
--                                 Included checkfile command too.
-- 19 Feb 03 apunekar     115.4    Bug#2810178   Removed no. of copies passed to fnd_request.set_print_options
-- 25 Feb 03 apunekar     115.6    Bug#2810178   Reverted fix
-- 29 May 03 kaverma      115.7    Bug#2920731   Replaced per_all_assignments_f and per_all_people_f
--                                 by secured views per_assignments_f and per_people_f resp from queries.
-----------------------------------------------------------------------------

  ------------------------------------------------------------------------
  -- The SELECT statement in this procedure returns the Person Ids for
  -- Assignments that require the report process to create an Assignment
  -- Action.
  -- Core Payroll recommends the select has minimal restrictions.
  ------------------------------------------------------------------------
  procedure range_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2) is
  begin
    --hr_utility.trace_on(null, 'pay_hk_ir56_report');
    hr_utility.set_location('Start of range_code',1);

    p_sql := 'select distinct person_id '                            ||
             'from   per_people_f ppf, '                             ||
                    'pay_payroll_actions ppa '                       ||
             'where  ppa.payroll_action_id = :payroll_action_id '    ||
             'and    ppa.business_group_id = ppf.business_group_id ' ||
             'order by ppf.person_id';

    hr_utility.set_location('End of range_code',2);
  end range_code;
  ------------------------------------------------------------------------
  -- This procedure is used to restrict the Assignment Action Creation.
  -- It calls the procedure that actually inserts the Assignment Actions.
  -- The cursor selects the assignments that have had any payroll
  -- processing for the Legal Entity within the Reporting Year.
  -- The person must not have had any Magtape File produced for the same
  -- Business Group, Legal Entity and Reporting Year. If they want to
  -- re-report a person, they must ROLLBACK the magtape first, or use the
  -- standard Re-try, Rollback payroll process.
  ------------------------------------------------------------------------
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number) is

    v_next_action_id  pay_assignment_actions.assignment_action_id%type;

    l_x_hk_archive_message  varchar2(100);
    l_full_or_partial       varchar2(15);
    l_reporting_year        varchar2(4);
    l_legal_entity_id       number;
    l_full_found            number;
    l_error                 number;


    cursor next_action_id is
      select pay_assignment_actions_s.nextval
      from   dual;
--
-- Cursor to select the parameters for the current IR56B run.
--
    cursor get_full_or_partial
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
        select pay_core_utils.get_parameter('FULL_OR_PARTIAL', ppa.legislative_parameters),
        pay_core_utils.get_parameter('REPORTING_YEAR', ppa2.legislative_parameters),
        pay_core_utils.get_parameter('LEGAL_ENTITY_ID', ppa2.legislative_parameters)
          from pay_payroll_actions ppa,  -- report payroll action
               pay_payroll_actions ppa2  -- archive payroll action
          where ppa.payroll_action_id = c_payroll_action_id
          and   ppa2.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa.legislative_parameters);
--
-- Cursor to check if there are any other FULL runs.
--
    cursor get_full_report_runs
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_reporting_year     in varchar2,
       c_legal_entity_id    in number) is
        select 1
          from pay_payroll_actions ppa,  -- report payroll action
               pay_payroll_actions ppa2  -- archive payroll action
          where pay_core_utils.get_parameter('FULL_OR_PARTIAL', ppa.legislative_parameters) = 'FULL'
          and   ppa.action_type        = 'X'
          and   ppa.action_status      = 'C'
          and   ppa.report_type        = 'HK_IR56B_REPORT'
          and   ppa.payroll_action_id <> c_payroll_action_id
          and   ppa2.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa.legislative_parameters)
          and   pay_core_utils.get_parameter('REPORTING_YEAR', ppa2.legislative_parameters) = c_reporting_year
          and   pay_core_utils.get_parameter('LEGAL_ENTITY_ID', ppa2.legislative_parameters) = c_legal_entity_id;
--
-- Cursor to process all assignments.
--
    cursor process_assignments
      (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       c_start_person_id    in per_all_people_f.person_id%type,
       c_end_person_id      in per_all_people_f.person_id%type) is
    select distinct paaf.assignment_id,
             paa.assignment_action_id,
             pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa.legislative_parameters) archive_action_id,
             pay_core_utils.get_parameter('LEGAL_ENTITY_ID', ppa2.legislative_parameters) legal_entity_id
      from   per_assignments_f paaf,
             per_people_f papf,
             pay_payroll_actions ppa,      -- report payroll action
             pay_payroll_actions ppa2,     -- archive payroll action
             pay_assignment_actions paa
      where  ppa.payroll_action_id  = c_payroll_action_id
      and    papf.person_id  between c_start_person_id and c_end_person_id
      and    papf.person_id         = paaf.person_id
      and    papf.business_group_id = ppa.business_group_id
      and    ppa2.payroll_action_id = paa.payroll_action_id
      and    paaf.assignment_id     = paa.assignment_id
      and    ppa2.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa.legislative_parameters)
      and    ppa2.action_type       = 'X'
      and    ppa2.action_status     = 'C'
--
-- if assignment_id was supplied for a partial run only return that
-- assignment else return them all for the archive action.
--
      and    paa.assignment_id = nvl(pay_core_utils.get_parameter('EMPLOYEE_NAME', ppa.legislative_parameters), paa.assignment_id)
--
-- don't process locked assignments
--
      and    not exists
            (select locked_action_id
               FROM   pay_action_interlocks pai
               WHERE pai.locked_action_id = paa.assignment_action_id)
;

begin
    --hr_utility.trace_on(null, 'pay_hk_ir56_report');
    hr_utility.set_location('Start of assignment_action_code '||
       p_payroll_action_id || ':' ||
       p_start_person_id || ':' || p_end_person_id,3);

--
-- If user is submitting FULL report then no previous FULL must have been run.
-- Also, if run is PARTIAL then a FULL run must have been done before.
-- If either of these situations arise flag an error and don't submit the
-- report.

    open get_full_or_partial(p_payroll_action_id);
    fetch get_full_or_partial
      into l_full_or_partial,
           l_reporting_year,
           l_legal_entity_id;
    if get_full_or_partial%NOTFOUND then
        l_full_or_partial := null;
    end if;
    close get_full_or_partial;

    open get_full_report_runs(p_payroll_action_id,
                              l_reporting_year,
                              l_legal_entity_id);
    fetch get_full_report_runs into l_full_found;
    if get_full_report_runs%NOTFOUND then
        l_full_found := 0;
    end if;
    close get_full_report_runs;

    l_error := 0;
    if l_full_or_partial = 'FULL' then
        if l_full_found = 1 then
            l_error := 1;
        end if;
    end if;

    if l_full_or_partial = 'PARTIAL' then
        if l_full_found = 0 then
            l_error := 2;
        end if;
    end if;

-- loop through the assignments returned from the main cursor and for each
-- one that has no errors create the pay_assignment_actions entry.

  if l_error = 0 then

    for process_rec in process_assignments (p_payroll_action_id,
                                            p_start_person_id,
                                            p_end_person_id)
    loop

        hr_utility.set_location('Before calling hr_nonrun_asact.insact',4);

        l_x_hk_archive_message :=
             pay_hk_ir56_report.get_archive_value('X_HK_ARCHIVE_MESSAGE',
                 process_rec.assignment_action_id);

        if l_x_hk_archive_message is null then

-- get the next assignment action id

          open next_action_id;
          fetch next_action_id into v_next_action_id;
          close next_action_id;

-- create the pay assignment action record. Don't create the action_interlock
-- until the report has run (create in the after report trigger) because the
-- report also needs to update the archive sheet number (through
-- ff_archive_api) and it cannot do this if the assignment action is locked.

          hr_nonrun_asact.insact(v_next_action_id,
                                 process_rec.assignment_id,
                                 p_payroll_action_id,
                                 p_chunk,
                                 null);
        end if;

        hr_utility.set_location('After calling hr_nonrun_asact.insint',4);

    end loop;
  elsif l_error = 1 then
        raise_application_error(-20001, 'Cannot submit FULL IR56B report, Full Run Already Submitted') ;
  elsif l_error = 2 then
        raise_application_error(-20001, 'Cannot submit Partial IR56B report, No Previous Full Run') ;
  else
        raise_application_error(-20001, 'Cannot submit IR56B report') ;
  end if;

  hr_utility.set_location('End of assignment_action_code',5);
  --hr_utility.trace_off;

end assignment_action_code;

-----------------------------------------------------------------------------
-- Submit the report.
-----------------------------------------------------------------------------
procedure submit_report is

  l_count                NUMBER := 0;
  l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
  l_archive_action_id    pay_payroll_actions.payroll_action_id%TYPE;
  l_full_or_partial      varchar2(15);
  l_assignment_id        pay_assignment_actions.assignment_id%TYPE;

  l_number_of_copies     NUMBER := 0; /*Reverted fix for 2810178 */
  l_request_id           NUMBER := 0;
  l_print_return         BOOLEAN;
  l_report_short_name    varchar2(30);

  l_formula_id   number ;

  l_error_text          varchar2(255) ;
  e_missing_formula     exception ;
  e_submit_error        exception ;

-- Cursor to get the report print options.

  cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
    SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;

  rec_print_options  csr_get_print_options%ROWTYPE;

-- Cursor to obtain the formula id.

  cursor c_formula (p_formula_name varchar2) is
    select formula_id
    from   ff_formulas_f
    where  formula_name = p_formula_name
    and    business_group_id is null
    and    legislation_code = 'HK' ;

begin
    --hr_utility.trace_on(null, 'pay_hk_ir56_report');

-- Get all of the parameters needed to submit the report. Parameters defined
-- in the concurrent program definition are passed through here by the PAR
-- process. End the loop by the exception clause because we don't know
-- what order the parameters will be in.

-- Default the parameters in case they are not found.

  hr_utility.set_location('Start submit_report',1);
  l_archive_action_id := 0;
  l_full_or_partial   := ' ';
  l_assignment_id     := 0;

-- Only process if no errors were found in regards to FULL and PARTIAL
-- processing.

  begin
    loop

      l_count := l_count + 1;
      if pay_mag_tape.internal_prm_names(l_count) =
                     'TRANSFER_PAYROLL_ACTION_ID' then
         l_payroll_action_id :=
                  to_number(pay_mag_tape.internal_prm_values(l_count));
      end if;

      if pay_mag_tape.internal_prm_names(l_count) = 'ARCHIVE_ACTION_ID' THEN
          l_archive_action_id :=
                  to_number(pay_mag_tape.internal_prm_values(l_count));
      end if;

      if pay_mag_tape.internal_prm_names(l_count) = 'FULL_OR_PARTIAL' THEN
          l_full_or_partial := pay_mag_tape.internal_prm_values(l_count);
      end if;

      if pay_mag_tape.internal_prm_names(l_count) = 'EMPLOYEE_NAME' THEN
          l_assignment_id :=
                  to_number(pay_mag_tape.internal_prm_values(l_count));
      end if;

      hr_utility.set_location(' prm_names (' || l_count || ') : ' ||
                  pay_mag_tape.internal_prm_names(l_count), 10);
      hr_utility.set_location(' prm_values (' || l_count || ') : ' ||
                  pay_mag_tape.internal_prm_values(l_count), 10);

    end loop;
  exception
      when no_data_found then
        hr_utility.set_location('No data found',1);
        null;
      when value_error then
        hr_utility.set_location('Value error',1);
        null;
  end;

  hr_utility.set_location('submit_report : Parameters obtained',1);
  hr_utility.set_location(' payroll action id : ' || l_payroll_action_id,1);
  hr_utility.set_location(' archive action id : ' || l_archive_action_id,1);
  hr_utility.set_location(' full or partial   : ' || l_full_or_partial,1);
  hr_utility.set_location(' assignment id     : ' || l_assignment_id, 2);

-- Default the number of report copies to 0.

  l_number_of_copies := 0;/*Reverted fix for 2810178 */

-- Set up the printer options.

  OPEN csr_get_print_options(l_payroll_action_id);
  FETCH csr_get_print_options INTO rec_print_options;
  CLOSE csr_get_print_options;
/*Reverted fix for 2810178 */
  l_print_return := fnd_request.set_print_options
                    (printer        => rec_print_options.printer,
                     style          => rec_print_options.print_style,
                     copies         => l_number_of_copies,
                     save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                     print_together => 'N');

  l_report_short_name := 'PAYHK56B';

-- Submit the report

  begin
    hr_utility.set_location('submit_report : Submit request',3);

-- Need to supply the parameters with keywords because it's a postscript report
-- and the option version=2.0b set in the SRS definition uses a keyword, hence
-- all the parameters need to as well.
-- Pass in assignment_id if it's been supplied.

    if l_assignment_id <> 0 then
      l_request_id := fnd_request.submit_request
            (application => 'PAY',
             program     => l_report_short_name,
             argument1  =>  'P_ARCHIVE_ACTION_ID=' || l_archive_action_id,
             argument2   => 'P_FULL_OR_PARTIAL=' || l_full_or_partial,
             argument3   => 'P_PAYROLL_ACTION_ID=' || l_payroll_action_id,
             argument4   => 'P_ASSIGNMENT_ID=' || l_assignment_id,
             argument5   => 'BLANKPAGES=NO');
    else
      l_request_id := fnd_request.submit_request
            (application => 'PAY',
             program     => l_report_short_name,
             argument1  =>  'P_ARCHIVE_ACTION_ID=' || l_archive_action_id,
             argument2   => 'P_FULL_OR_PARTIAL=' || l_full_or_partial,
             argument3   => 'P_PAYROLL_ACTION_ID=' || l_payroll_action_id,
             argument4   => 'BLANKPAGES=NO');
    end if;

-- If an error submitting report then get message and put to log.

    IF l_request_id = 0 THEN
      raise e_submit_error;
    END IF;

  exception
    when e_submit_error then
      rollback ;
      raise_application_error(-20001, 'Unable to submit IR56B report') ;
    when others then
      rollback ;
      raise_application_error(-20001, sqlerrm) ;
  end;

-- Set up the details for the formula which will be invoked at the
-- end of the procedure. this formula is automatically invoked by the
-- PAR process after the magnetic_code procedure (submit_report in our case).

-- Setup some of the internal table values for the magtape.
-- Position 1 is reserved for No of Parameters.
-- Position 2 is reserved for formula id.
----------------------------

----------------------------
-- Get Formula ID for hk_end_submit
----------------------------
  begin
    open c_formula ('HK_END_SUBMIT') ;
    fetch c_formula into l_formula_id ;
    if c_formula%notfound then
      close c_formula ;
      l_error_text := 'HK_END_SUBMIT' ;
      raise e_missing_formula ;
    end if ;
    close c_formula ;

  exception
    when e_missing_formula then
      rollback ;
      raise_application_error(-20001, 'Missing formula: ' || l_error_text) ;
    when others then
      rollback ;
      raise_application_error(-20001, sqlerrm) ;
  end ;

  pay_mag_tape.internal_prm_names(1) := 'NO_OF_PARAMETERS';
  pay_mag_tape.internal_prm_values(1) := '2';
  pay_mag_tape.internal_prm_names(2) := 'NEW_FORMULA_ID';
  pay_mag_tape.internal_prm_values(2) := l_formula_id;

  hr_utility.set_location('end submit_report', 5);
  --hr_utility.trace_off;

end submit_report;

-----------------------------------------------------------------------------
-- Retrieve an archive value.
-----------------------------------------------------------------------------

function get_archive_value
   (p_archive_name in ff_user_entities.user_entity_name%type,
    p_assignment_action_id in pay_assignment_actions.assignment_action_id%type)
   return ff_archive_items.value%type is

  l_value            ff_archive_items.value%type;
  e_no_value_found   exception;

  -- cursor to fetch the archive value

 cursor   csr_get_archive_value(c_archive_name varchar2,
                      c_assignment_action_id number) is
   select   fai.value
     from   ff_archive_items fai,
            ff_user_entities fue
     where   fai.context1       = c_assignment_action_id
     and   fai.user_entity_id   = fue.user_entity_id
     and   fue.user_entity_name = c_archive_name;

begin

  hr_utility.set_location('Start of get archive value ',1);

  open   csr_get_archive_value(p_archive_name,
                               p_assignment_action_id);
  fetch  csr_get_archive_value into l_value;

  if  csr_get_archive_value%notfound then
      l_value := null;
  end if;

  close csr_get_archive_value;

  hr_utility.set_location('End of get archive value ',2);

  return(l_value);

  exception
    when others then
      return (null);

end  get_archive_value;

-----------------------------------------------------------------------------
end pay_hk_ir56_report;

/
