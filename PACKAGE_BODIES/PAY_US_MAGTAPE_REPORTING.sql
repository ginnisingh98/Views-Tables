--------------------------------------------------------
--  DDL for Package Body PAY_US_MAGTAPE_REPORTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MAGTAPE_REPORTING" as
 /* $Header: pyusmrep.pkb 115.8 2002/12/02 21:44:07 sodhingr ship $ */
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_magtape_reporting
  Purpose
    The purpose of this package is to support the generation of magnetic tape
    reports for US legilsative requirements. Specifically this covers federal
    and state W2's and also State Quarterly Wage Listing's.
  Notes
    The generation of each magnetic tape report is a two stage process i.e.

    1. Create a payroll action identifying the magnetic tape report being
       generated. Populate a set of assignment actions with each one
       identifying a person to be included in the report.

    2. Submit a request to run the generic magnetic tape process which will
       drive off the data created in stage one. This will result in the
       production of a structured ascii file which can be transferred to
       magnetic tape and sent to the relevant authority.
  History
	10-Feb-95 	J.S.Hobbs  	40.0  	Date created.

 ============================================================================*/
 --
 g_message_text varchar2(240);
 type g_people_type is table of VARCHAR(80)
         index by binary_integer;
 g_people_text g_people_type;
 g_num_peo number;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   bal_db_item
  -- Purpose
  --   Given the name of a balance DB item as would be seen in a fast formula
  --   it returns the defined_balance_id of the balance it represents.
  -- Arguments
  -- Notes
  --   A defined +balance_id is required by the PLSQL balance function.
  -----------------------------------------------------------------------------
 --
 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number is
   --
   -- Get the defined_balance_id for the specified balance DB item.
   --
   cursor csr_defined_balance is
     select fnd_number.canonical_to_number(UE.creator_id)
     from   ff_database_items         DI,
 	    ff_user_entities          UE
     where  DI.user_name            = p_db_item_name
       and  UE.user_entity_id       = DI.user_entity_id
       and  UE.creator_type         = 'B'
       and  UE.legislation_code     = 'US'; /* Bug: 2296797 */
   --
   l_defined_balance_id pay_defined_balances.defined_balance_id%type;
   --
 begin
   --
   hr_utility.set_location('pay_us_magtape_reporting.bal_db_item - opening cursor', 1);
   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     g_message_text := 'Balance DB item does not exist';
     raise hr_utility.hr_error;
   else
     hr_utility.set_location('pay_us_magtape_reporting.bal_db_item - fetched from cursor', 2);
     close csr_defined_balance;
   end if;
   --
   return (l_defined_balance_id);
   --
 end bal_db_item;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   lookup_jurisdiction_code
  -- Purpose
  --   Given a state code ie. AL it returns the jurisdiction code that
  --   represents that state.
  -- Arguments
  -- Notes
  -----------------------------------------------------------------------------
 --
 function lookup_jurisdiction_code
 (
  p_state varchar2
 ) return varchar2 is
   --
   -- Get the jurisdiction_code for the specified state code.
   --
   cursor csr_jurisdiction_code is
     select SR.jurisdiction_code
     from   pay_state_rules SR
     where  SR.state_code = p_state;
   --
   l_jurisdiction_code pay_state_rules.jurisdiction_code%type;
   --
 begin
   --
   hr_utility.set_location('pay_us_magtape_reporting.lookup_jurisdiction_code - opening cursor', 1);
   open csr_jurisdiction_code;
   fetch csr_jurisdiction_code into l_jurisdiction_code;
   if csr_jurisdiction_code%notfound then
     close csr_jurisdiction_code;
     g_message_text := 'Cannot find jurisdiction code';
     raise hr_utility.hr_error;
   else
     hr_utility.set_location('pay_us_magtape_reporting.lookup_jurisdiction_code - fetched from cursor', 2);
     close csr_jurisdiction_code;
   end if;
   --
   return (l_jurisdiction_code);
   --
 end lookup_jurisdiction_code;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   error_payroll_action
  -- Purpose
  --   Sets the status of a payroll action to 'E'rror.
  -- Arguments
  -- Notes
  --   This should only be used when the magnetic report has failed.
  -----------------------------------------------------------------------------
 --
 procedure error_payroll_action
 (
  p_payroll_action_id number
 ) is
 begin
   --
   -- Sets the payroll action to a status of 'E'rror.
   --
   hr_utility.set_location('pay_us_magtape_reporting.error_payroll_action - updating pay_ payrol_actions', 1);
   update pay_payroll_actions PA
   set    PA.action_status     = 'E'
   where  PA.payroll_action_id = p_payroll_action_id;
   --
   hr_utility.set_location('pay_us_magtape_reporting.error_payroll_action - updated pay_ payrol_actions', 2);
   commit;
   --
 end error_payroll_action;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   update_action_statuses
  -- Purpose
  --   Sets the payroll action to 'C'omplete. Sets all successful assignment
  --   actions to 'C'omplete.
  -- Arguments
  -- Notes
  --   This should only be used when the magnetic report has successfully run.
  --   All the assignment actions are set to 'U'nprocessed before processing
  --   starts. If an error occurs with an assignment action then it is set to
  --   'E'rror by the magnetic tape process. Having finished processing, all
  --   assignment actions left with a status of 'U'nprocessed are assumed to
  --   be successful and therefore set to 'C'omplete.
  -----------------------------------------------------------------------------
 --
 procedure update_action_statuses
 (
  p_payroll_action_id number
 ) is
 begin
   --
   -- Sets the payroll action to a status of 'C'omplete.
   --
   hr_utility.set_location('pay_us_magtape_reporting.update_action_statuses - updating pay_ payrol_actions', 1);
   update pay_payroll_actions PA
   set    PA.action_status     = 'C'
   where  PA.payroll_action_id = p_payroll_action_id;
   --
   -- Sets all successfully processed assignment actions to 'C'omplete.
   --
   hr_utility.set_location('pay_us_magtape_reporting.update_action_statuses - updating pay_ assignment_actions', 2);
   update pay_assignment_actions AA
   set    AA.action_status     = 'C'
   where  AA.payroll_action_id = p_payroll_action_id
     and  AA.action_status     = 'U';
   --
   hr_utility.set_location('pay_us_magtape_reporting.update_action_statuses - commiting', 3);
   commit;
   --
 end update_action_statuses;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   get_selection_information
  -- Purpose
  --   Returns information used in the selection of people to be reported on.
  -- Arguments
  --   The following values are returned :-
  --
  --   p_sql_statement        - the SQL to be run to select the people.
  --   p_period_start         - the start of the period over which to select
  --                            the people.
  --   p_period_end           - the end of the period over which to select
  --                            the people.
  --   p_defined_balance_id   - the balance which must be non zero for each
  --                            person to be included in the report.
  --   p_group_by_gre         - should the people be grouped by GRE.
  --   p_group_by_medicare    - should the people ,be grouped by medicare
  --                            within GRE NB. this is not currently supported.
  --   p_tax_unit_context     - should the TAX_UNIT_ID context be set up for
  --                            the testing of the balance.
  --   p_jurisdiction_context - should the JURISDICTION_CODE context be set up
  --                            for the testing of the balance.
  -- Notes
  --   This routine provides a way of coding explicit rules for individual
  --   reports where they are different from the standard selection criteria
  --   for the report type ie. in NY state the selection of people in the 4th
  --   quarter is different from the first 3.
  -----------------------------------------------------------------------------
 --
 procedure get_selection_information
 (
  --
  -- Identifies the type of report, the authority for which it is being run,
  -- and the period being reported.
  --
  p_report_type          varchar2,
  p_state                varchar2,

  --
  -- Quarter and year start and end dates for the period being reported on.
  --
  p_quarter_start        date,
  p_quarter_end          date,
  p_year_start           date,
  p_year_end             date,
  --
  -- Information returned is used to control the selection of people to
  -- report on.
  --
  p_period_start         in out nocopy date,
  p_period_end           in out nocopy date,
  p_defined_balance_id   in out nocopy number,
  p_group_by_gre         in out nocopy boolean,
  p_group_by_medicare    in out nocopy boolean,
  p_tax_unit_context     in out nocopy  boolean,
  p_jurisdiction_context in out nocopy  boolean
 ) is
   --
   --
 begin
   --
   -- Depending on the report being processed, derive all the information
   -- required to be able to select the people to report on.
   --
   -- Federal W2.
   --
   if    p_report_type = 'W2' and p_state = 'FED' then
     --
     -- Default settings for Federal W2.
     --
     hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - default settings for Federal W2', 1);
     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
     p_defined_balance_id   := bal_db_item('GROSS_EARNINGS_PER_GRE_YTD');
     p_group_by_gre         := TRUE;
     p_group_by_medicare    := TRUE;
     p_tax_unit_context     := TRUE;
     p_jurisdiction_context := FALSE;
   --
   -- State W2's.
   --
   elsif p_report_type = 'W2' and p_state <> 'FED' then
     --
     -- Default settings for State W2.
     --
     hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - default settings for State W2', 2);
     p_period_start         := p_year_start;
     p_period_end           := p_year_end;
     p_defined_balance_id   := bal_db_item('SIT_GROSS_PER_JD_GRE_YTD');
     p_group_by_gre         := TRUE;
     p_group_by_medicare    := TRUE;
     p_tax_unit_context     := TRUE;
     p_jurisdiction_context := TRUE;
   --
   -- State Quarterly Wage Listings.
   --
   elsif p_report_type = 'SQWL' then
     --
     -- New York state settings NB. the difference is that the criteria for
     -- selecting people in the 4th quarter is different to that used for the
     -- furst 3 quarters of the tax year.
     --
     if p_state = 'NY' then
       --
       -- Period is one of the first 3 quarters of tax year.
       --
       if instr(to_char(p_quarter_end,'MM'), '12') = 0 then
         --
         hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - NY last quarter', 3);
         p_period_start         := p_quarter_start;
         p_period_end           := p_quarter_end;
         p_defined_balance_id   := bal_db_item('SUI_ER_GROSS_PER_JD_GRE_QTD');
       --
       -- Period is the last quarter of the year.
       --
       else
         --
         hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - in NY ', 3);
         p_period_start         := p_year_start;
         p_period_end           := p_year_end;
         p_defined_balance_id   := bal_db_item('SIT_GROSS_PER_JD_GRE_YTD');
         --
       end if;
       --
       -- Values are set independent of quarter being reported on.
       --
       p_group_by_gre         := TRUE;
       p_group_by_medicare    := TRUE;
       p_tax_unit_context     := TRUE;
       p_jurisdiction_context := TRUE;
     --
     -- Default settings for State Quarterly Wage Listing.
     --
     else
       --
         hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - defalut setting for SQWL ', 4);
       p_period_start         := p_quarter_start;
       p_period_end           := p_quarter_end;
       p_defined_balance_id   := bal_db_item('SUI_ER_GROSS_PER_JD_GRE_QTD');
       p_group_by_gre         := TRUE;
       p_group_by_medicare    := TRUE;
       p_tax_unit_context     := TRUE;
       p_jurisdiction_context := TRUE;
       --
     end if;
   --
   -- An invalid report type has been passed so fail.
   --
   else
     --
     hr_utility.set_location('pay_us_magtape_reporting.get_selection_information - invalid report ', 4);
     raise hr_utility.hr_error;
     --
   end if;
   --
 end get_selection_information;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   create_payroll_action
  -- Purpose
  --   Creates a payroll action identifying the production of a particular
  --   magnetic tape report i.e. federal W2, etc... The list of people to be
  --   reported on is created as assignment actions for the payroll action.
  -- Arguments
  -- Notes
  --   The effective_date of the payroll action identifies the end of the
  --   period being reported i.e. end of tax year or end of a quarter. The
  --   legislative parameter is used to uniquely identify the report.
  --
  -- SQWLD - add p_media_type parameter
  -----------------------------------------------------------------------------
 --
 function create_payroll_action
 (
  p_report_type       in varchar2,
  p_state             in varchar2,
  p_trans_legal_co_id in varchar2,
  p_business_group_id in number,
  p_period_end        in date,
  p_media_type  		 in varchar2
 ) return number is
   --
   l_payroll_action_id pay_payroll_actions.payroll_action_id%type;
   --
 begin
   --
   -- Get the next payroll_action_id value from the sequence.
     hr_utility.set_location('pay_us_magtape_reporting.create_payroll_action - getting nextval', 1);
   --
   select pay_payroll_actions_s.nextval
   into   l_payroll_action_id
   from   sys.dual;
   --
   -- Create a payroll action dated as of the end of the period being reported
   -- on. Populate the legislative parameter to identify the report being run
   -- NB. the combination of this value and the effective date should uniquely
   -- identify each report e.g. FED-W2 on 31-DEC-1995.
   --

   -- SQWLD - append p_media_type to parameter string, so redo can detect it
     hr_utility.set_location('pay_us_magtape_reporting.create_payroll_action - creating payroll action', 2);
   insert into pay_payroll_actions
   (payroll_action_id
   ,action_type
   ,business_group_id
   ,action_population_status
   ,action_status
   ,effective_date
   ,date_earned
   ,legislative_parameters
   ,object_version_number)
   values
   (l_payroll_action_id
   ,'X'                       -- (X) -> Magnetic Report
   ,p_business_group_id
   ,'U'                       -- (U)npopulated
   ,'U'                       -- (U)nprocessed
   ,p_period_end
   ,p_period_end
   ,'USMAGTAPE'            || '-' ||
    lpad(p_report_type, 5) || '-' ||
    lpad(p_state      , 5) || '-' ||
    lpad(p_trans_legal_co_id, 5)	|| '-' ||
	 lpad(nvl(p_media_type, 'RT'), 5)		-- SQWLD - save media value, 'PD' for PC Diskette
   ,1);
   --
   -- Return id of new row.
   --
   return (l_payroll_action_id);
   --
 end create_payroll_action;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   create_assignment_action
  -- Purpose
  --   Create an assignment action for each person to be reported on within the
  --   magnetic tape report identified by the parent payroll action.
  -- Arguments
  -- Notes
  -----------------------------------------------------------------------------
 --
 function create_assignment_action
 (
  p_payroll_action_id in number,
  p_assignment_id     in number,
  p_tax_unit_id       in number
 ) return number is
   --
   -- Cursor to fetch the newly created assignment_action_id NB. there could
   -- be several assignment actions for the same assignment and the only way
   -- to find the newly created one is to fetch the one that has not had the
   -- tax_unit_id updated yet.
   --
   cursor csr_assignment_action is
     select AA.assignment_action_id
     from   pay_assignment_actions AA
     where  AA.payroll_action_id = p_payroll_action_id
       and  AA.assignment_id     = p_assignment_id
       and  AA.tax_unit_id   is null;
   --
   -- Local variables.
   --
   l_assignment_action_id pay_assignment_actions.assignment_action_id%type;
   --
 begin
   --
   -- Create assignment action to identify a specific person's inclusion in the
   -- magnetic tape report identified by the parent payroll action. The
   -- assignment action has to be sequenced within the other assignment actions
   -- according to the date of the payroll action so that the derivation of
   -- any balances based on the assignment action is correct.
   --
     hr_utility.set_location('pay_us_magtape_reporting.create_assignment_action - creating assignment action', 1);
   hrassact.inassact(p_payroll_action_id, p_assignment_id);
   --
   -- Get the assignment_action_id of the newly created assignment action.
   --
     hr_utility.set_location('pay_us_magtape_reporting.create_assignment_action - opening csr_assignment_action', 2);
   open  csr_assignment_action;
   fetch csr_assignment_action into l_assignment_action_id;
   close csr_assignment_action;
   --
   --
   hr_utility.set_location('pay_us_magtape_reporting.create_assignment_action - updating pay_assignment_actions', 3);
   update pay_assignment_actions AA
   set    AA.tax_unit_id         = p_tax_unit_id
   where  AA.assignment_action_id = l_assignment_action_id;
   --
   -- Return id of new row.
   --
   hr_utility.set_location('pay_us_magtape_reporting.create_assignment_action - updated pay_assignment_actions', 4);
   return (l_assignment_action_id);
   --
 end create_assignment_action;
 --
procedure get_person_name(p_person_id in number,
                          p_full_name in out nocopy  varchar2,
                          p_emp_number in out nocopy  varchar2) is

l_name    varchar2(240);
l_number  varchar2(60);

cursor csr_get_info is
   select full_name, employee_number
   from per_people_f
   where person_id = p_person_id
   and rownum = 1;

begin
open csr_get_info;
fetch csr_get_info into l_name, l_number;
close csr_get_info;

--dbms_output.put_line('l_name is '||l_name||' and l_number is '||l_number);

p_full_name := l_name;
p_emp_number := l_number;

end get_person_name;

  -----------------------------------------------------------------------------
  -- Name
  --   generate_people_list
  -- Purpose
  --   Creates a payroll action and a list of assignment actions detailing the
  --   date of the magnetic tape report along with the list of people to
  --   report on.
  -- Arguments
  -- Notes
  --   The criteria for selecting the people cannot be done simply using SQL.
  --   It is done by first using a PLSQL cursor which makes an educated guess
  --   about the people to include NB. it will always include all the correct
  --   people even though some may not be valid. The second step is to
  --   further check each person found and apply further checks. If these are
  --   passed then they are added to the list (create an assignment action)
  --   otherwise they are discarded.
  --
  -- SQWLD - add p_media_type parameter
  -----------------------------------------------------------------------------
 --
 function generate_people_list
 (
  p_report_type       varchar2,
  p_state             varchar2,
  p_trans_legal_co_id varchar2,
  p_business_group_id number,
  p_period_end        date,
  p_quarter_start     date,
  p_quarter_end       date,
  p_year_start        date,
  p_year_end          date,
  p_media_type        varchar2
 ) return number is
   --
   --
   -- Variables used to hold the select columns from the SQL statement.
   --
   l_person_id              number;
   l_assignment_id          number;
   l_tax_unit_id            number;
   l_effective_end_date     date;
   --
   -- Variables used to hold the values used as bind variables within the
   -- SQL statement.
   --
   l_bus_group_id           number       := p_business_group_id;
   l_state                  varchar2(30) := p_state;
   l_period_start           date;
   l_period_end             date;
   --
   -- Variables used to hold the details of the payroll and assignment actions
   -- that are created.
   --
   l_payroll_action_created boolean := false;
   l_payroll_action_id      pay_payroll_actions.payroll_action_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;
   --
   -- Variable holding the balance to be tested.
   --
   l_defined_balance_id     pay_defined_balances.defined_balance_id%type;
   --
   -- Indicator variables used to control how the people are grouped.
   --
   l_group_by_gre           boolean := FALSE;
   l_group_by_medicare      boolean := FALSE;
   --
   -- Indicator variables used to control which contexts are set up for
   -- balance.
   --
   l_tax_unit_context       boolean := FALSE;
   l_jurisdiction_context   boolean := FALSE;
   --
   -- Variables used to hold the current values returned within the loop for
   -- checking against the new values returned from within the loop on the
   -- next iteration.
   --
   l_prev_person_id         per_people_f.person_id%type;
   l_prev_tax_unit_id       hr_organization_units.organization_id%type;
   --
   -- Variable to hold the jurisdiction code used as a context for state
   -- reporting.
   --
   l_jurisdiction_code      varchar2(30);
   --
   --  Flag to indicate whether assignment is exempt from SUI wages.
   -- Not Needed
   --
   -- l_exempt		    varchar2(150) := 'N';
   --
   -- Variable used to commit after every chunk_size of assignment actions
   -- or after 20, if no chunk size is specified.
   --
   cnt 			    number;
   l_chunk_size             number;

   l_value		    number;
   --
   -- People list for Fed W2 - Federal grouped within GRE.
   --
   CURSOR c_federal IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            fnd_number.canonical_to_number(SCL.segment1)     tax_unit_id,
            max(ASG.effective_end_date) effective_end_date
     FROM   per_assignments_f      ASG,
            hr_soft_coding_keyflex SCL,
            hr_tax_units_v         TUV,
            pay_payrolls_f         PPY
     WHERE  ASG.business_group_id      = l_bus_group_id
       AND  ASG.assignment_type        = 'E'
       AND  ASG.effective_start_date  <= l_period_end
       AND  ASG.effective_end_date    >= l_period_start
       AND  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       AND  fnd_number.canonical_to_number(SCL.segment1) =  TUV.tax_unit_id
       AND  TUV.US_1099R_TRANSMITTER_CODE IS NULL
       AND  PPY.payroll_id             = ASG.payroll_id
       AND  l_state                    = l_state
     GROUP  BY ASG.person_id,
               ASG.assignment_id,
               fnd_number.canonical_to_number(SCL.segment1)
     ORDER  BY 1, 3, 4 DESC, 2;
   --
   -- People list for State W2 - State grouped within GRE.
   --
   CURSOR c_state IS
     SELECT ASG.person_id               person_id,
            ASG.assignment_id           assignment_id,
            fnd_number.canonical_to_number(SCL.segment1)     tax_unit_id,
            max(ASG.effective_end_date) effective_end_date
     FROM   per_assignments_f           ASG,
            hr_soft_coding_keyflex      SCL,
            hr_tax_units_v              TUV,
            pay_payrolls_f              PPY,
            pay_state_rules             SR,
            pay_element_types_f         ET,
            pay_input_values_f          IV,
            pay_element_links_f         EL
     WHERE  ASG.business_group_id + 0   = l_bus_group_id
       AND  ASG.assignment_type         = 'E'
       AND  ASG.effective_start_date   <= l_period_end
       AND  ASG.effective_end_date     >= l_period_start
       AND  SCL.soft_coding_keyflex_id  = ASG.soft_coding_keyflex_id
       AND  fnd_number.canonical_to_number(SCL.segment1) =  TUV.tax_unit_id
       AND  TUV.US_1099R_TRANSMITTER_CODE IS NULL
       AND  PPY.payroll_id              = ASG.payroll_id
       AND  SR.state_code            = l_state
       AND  ET.element_name          = 'VERTEX'
       AND  IV.element_type_id       = ET.element_type_id
       AND  upper(IV.name)           = 'JURISDICTION'
       AND  EL.element_type_id       = ET.element_type_id
       AND  EL.business_group_id + 0 = ASG.business_group_id + 0
       AND  EXISTS (SELECT ''
                    FROM
                        pay_element_entries_f       EE,
                        pay_element_entry_values_f  EEV
                    WHERE  EE.assignment_id         = ASG.assignment_id
                    AND  EE.element_link_id       = EL.element_link_id
                    AND  EEV.element_entry_id     = EE.element_entry_id
                    AND  EEV.input_value_id + 0   = IV.input_value_id
                    AND  substr(SR.jurisdiction_code  ,1,2) =
                             substr(EEV.screen_entry_value,1,2)
                    AND  EE.effective_start_date <= l_period_end
                    AND  EE.effective_end_date   >= l_period_start)
     GROUP  BY ASG.person_id,
               ASG.assignment_id,
               fnd_number.canonical_to_number(SCL.segment1)
     ORDER  BY 1, 3, 4 DESC, 2;
--
   --
   --
 begin
   --
   -- Return details used to control the selection of people to report on ie.
   -- the SQL statement to run, the period over which to look for the people,
   -- how to group the people, etc...
   --
   hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - get selection_information', 1);
   get_selection_information
     (p_report_type,
      p_state,
      p_quarter_start,
      p_quarter_end,
      p_year_start,
      p_year_end,
      l_period_start,
      l_period_end,
      l_defined_balance_id,
      l_group_by_gre,
      l_group_by_medicare,
      l_tax_unit_context,
      l_jurisdiction_context);
   --
   -- Get the jurisdiction code for the state if appropriate.
   --
   if l_jurisdiction_context then
     hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - get jurisdiction code', 2);
     l_jurisdiction_code := lookup_jurisdiction_code(p_state);
   end if;
   --
   -- Open up a cursor for processing a SQL statement.
   --
   IF l_state = 'FED' THEN
      --
      OPEN c_federal;
      --
   ELSE
      --
      OPEN c_state;
      --
   END IF;
   --
   --------------------------------------------------------------------
   -- Get CHUNK_SIZE or default to 20 if CHUNK_SIZE does not exist
   --------------------------------------------------------------------
   BEGIN
     hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - get chunk size', 3);
     SELECT parameter_value
       INTO l_chunk_size
       FROM pay_action_parameters
       WHERE parameter_name = 'CHUNK_SIZE';
   EXCEPTION
     WHEN no_data_found THEN
       l_chunk_size := 20;
   END;
   --
   -- Initialize counter.
   --
   cnt := 0;
   --
   -- Loop for all rows returned for SQL statement.
   --
   LOOP
     --
     -- Commit if l_chunk_size number of assignments have been processed.
     --
     if cnt = l_chunk_size then
        cnt := 0;
        commit;
	hr_utility.trace('COMMITTED');
     end if;
     --
     cnt := cnt + 1;
     hr_utility.trace('CNT:::: '||cnt||'CHUNK SIZE::: '||l_chunk_size);
     --
     -- Fetch next row from the appropriate cursor.
     --
     --
     IF l_state = 'FED' THEN
        --
        hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - fetching from c_federal', 4);
        FETCH c_federal INTO l_person_id,
                             l_assignment_id,
                             l_tax_unit_id,
                             l_effective_end_date;
        EXIT WHEN c_federal%NOTFOUND;
        --
     ELSE
        --
        hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - fetching from c_state', 4);
        FETCH c_state INTO l_person_id,
                           l_assignment_id,
                           l_tax_unit_id,
                           l_effective_end_date;
        EXIT WHEN c_state%NOTFOUND;
        --
     END IF;
     --
     -- If the new row is the same as the previous row according to the way
     -- the rows are grouped then discard the row ie. grouping by GRE
     -- requires a single row for each person / GRE combination.
     --
     if ((l_group_by_gre                     and
          l_person_id   = l_prev_person_id   and
     	  l_tax_unit_id = l_prev_tax_unit_id) or
         (not l_group_by_gre                 and
          l_person_id   = l_prev_person_id)) then
        --
        -- Do nothing.
        --
        null;
        --
        -- Have a new unique row according to the way the rows are grouped.
        -- The inclusion of the person is dependent on having a non zero
	-- balance.
        -- If the balance is non zero then an assignment action is created to
        -- indicate their inclusion in the magnetic tape report.
        --
     else
        --
        -- Set up contexts required to test the balance.
        --
        -- Set up TAX_UNIT_ID context if appropriate.
        --
 	if l_tax_unit_context then
        hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - setting tax_unit_id context', 5);
           pay_balance_pkg.set_context('TAX_UNIT_ID',l_tax_unit_id);
        end if;
        --
        -- Set up JURISDICTION_CODE context if appropriate.
        --
 	if l_jurisdiction_context then
        hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - setting jurisdiction_code context', 6);
           pay_balance_pkg.set_context('JURISDICTION_CODE',l_jurisdiction_code);
        end if;
        --
        --
        -- Check the balance.
	--
        hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - check balance', 7);

        l_value := pay_balance_pkg.get_value
	                     (l_defined_balance_id,
                              l_assignment_id,
                              least(p_period_end,l_effective_end_date));

      if (l_value > 0) then
          --
  	  -- Have found a person that needs to be reported in the federal W2 so
  	  -- need to create an assignment action for it.
  	  --
  	  -- If the payroll action has not been created yet i.e. this is the
  	  -- first assignment action then create it.
  	  --
           if not l_payroll_action_created then
  	    --
  	    -- Create payroll action for the magnetic tape report.
           hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - creating payroll action id', 8);
  	    --
       -- SQWLD - add p_media_type parameter
             l_payroll_action_id := create_payroll_action
                                      (p_report_type,
                                       p_state,
                                       p_trans_legal_co_id,
                                       p_business_group_id,
                                       p_period_end,
													p_media_type);
  	    --
  	    -- Flag the creation of the payroll action.
  	    --
  	    l_payroll_action_created := true;
             --
           end if;
  	  --
  	  -- Create the assignment action to represnt the person / tax unit
  	  -- combination.
  	  --
           hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - creating assignment action id', 9);
           l_assignment_action_id := create_assignment_action
                                       (l_payroll_action_id,
                                        l_assignment_id,
                                        l_tax_unit_id);

           if (p_report_type = 'W2' and p_state <> 'FED' and
               l_value > 9999999.99) then

           update pay_assignment_actions aa
           set    aa.serial_number = 999999
           where  aa.assignment_action_id = l_assignment_action_id;

	   end if;

        end if;

     end if;
     --
     -- Record the current values for the next time around the loop.
     --
     l_prev_person_id   := l_person_id;
     l_prev_tax_unit_id := l_tax_unit_id;
     --
   END LOOP;
   COMMIT;
   --
   -- Close cursor used for processing SQL statement.
   --
   IF l_state = 'FED' THEN
      --
      CLOSE c_federal;
      --
   ELSE
      --
      CLOSE c_state;
      --
   END IF;

   --
   -- A payroll action has been created.
   --
   if l_payroll_action_created then
     --
     -- Update the population status of the payroll action to indicate that all
     -- the assignment actions have been created for it.
     --
     hr_utility.set_location('pay_us_magtape_reporting.generate_people_list - updating pay_payroll_actions', 10);
     update pay_payroll_actions PPA
     set    PPA.action_population_status = 'C'
     where  PPA.payroll_action_id        = l_payroll_action_id;
     --
     -- Make the changes permanent.
     --
     commit;
     --
   end if;
   --
   return (l_payroll_action_id);
   --
 end generate_people_list;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   redo
  -- Purpose
  --   Calls the procedure run_magtape directly from SRS. This procedure
  --   handles the error buffer and return code interface with SRS.
  --   We are going to derive all the  parameters from the vi
  -- Arguments
  -- Notes
  -- SQWLD - add support for media type by parsing leg params for media value 'D' or 'M'
  -----------------------------------------------------------------------------
 procedure redo
 (
  errbuf               out nocopy  varchar2,
  retcode              out nocopy  number,
  p_payroll_action_id  in varchar2
 ) is
   --
    l_effective_date     date;
    l_report_type        varchar2(10);
    l_state              varchar2(10);
    l_reporting_year     varchar2(10);
    l_reporting_quarter  varchar2(10);
    l_trans_legal_co_id  varchar2(10);
    l_media_type  		 varchar2(32);

   begin
     --
     --  Derive the rest of the parameters from the payroll_action_id
     --
     hr_utility.set_location('pay_us_magtape_reporting.redo - get parameters', 1);
     select PA.effective_date,
	    ltrim(substr(PA.legislative_parameters, 11,5)),
	    ltrim(substr(PA.legislative_parameters, 17,5)),
	    to_char(PA.effective_date,'YYYY'),
	    decode(ltrim(substr(PA.legislative_parameters, 11,5)),
        	'W2'  , to_char(PA.effective_date,'YYYY'),
        	'SQWL', to_char(PA.effective_date,'MMYY')),
	    ltrim(substr(PA.legislative_parameters, 23,5)),
	    ltrim(substr(PA.legislative_parameters, 29,5))
 	  into  l_effective_date,
           l_report_type,
           l_state,
           l_reporting_year,
           l_reporting_quarter,
           l_trans_legal_co_id,
			  l_media_type
     from pay_payroll_actions PA
     where PA.payroll_action_id = p_payroll_action_id;

     --
   hr_utility.set_location('pay_us_magtape_reporting.redo - update pay_payroll_actions', 2);
   update pay_payroll_actions pa
   set    PA.action_status     = 'M'
   where  PA.payroll_action_id = p_payroll_action_id;

   hr_utility.set_location('pay_us_magtape_reporting.redo - update pay_assignment_actions', 3);
   update pay_assignment_actions AA
   set    AA.action_status     = 'M'
   where  AA.payroll_action_id = p_payroll_action_id;

   commit;

   FOR i in 1..70 LOOP
   g_people_text(i) := ' ';
   END LOOP;

     -- Start the generic magnetic tape process.
     --
   hr_utility.set_location('pay_us_magtape_reporting.redo - run_magtape', 4);
     run_magtape(l_effective_date,
                 l_report_type,
 	         	  p_payroll_action_id,
 	         	  l_state,
 	         	  l_reporting_year,
	         	  l_reporting_quarter,
 	         	  l_trans_legal_co_id,
 	         	  l_media_type);

   --
   hr_utility.set_location('pay_us_magtape_reporting.redo - update pay_assignment_actions', 5);
   update pay_assignment_actions AA
   set    AA.action_status     = 'C'
   where  AA.payroll_action_id = p_payroll_action_id;

   commit;

   -- Set up success return code.
   --
   retcode := 0;
 --
 -- Traps all exceptions raised within the procedure, extracts the message
 -- text associated with the exception and sets this up for SRS to read.
 --
 exception
   when hr_utility.hr_error then
     --
     -- If a payroll action exists then error it.
     --
     if p_payroll_action_id is not null then
       error_payroll_action(p_payroll_action_id);
     end if;
     --
     -- Set up error message and error return code.
     --
     errbuf  := g_message_text;
     retcode := 2;
     --
   when others then
     --
     -- If a payroll action exists then error it.
     --
     if p_payroll_action_id is not null then
       error_payroll_action(p_payroll_action_id);
     end if;
     --
     -- Set up error message and error return code.
     --
     errbuf  := sqlerrm;
     retcode := 2;
     --
end redo;

  -----------------------------------------------------------------------------
  -- Name
  --   run_magtape
  -- Purpose
  --   Submits the magnetic tape process to be run by the concurrent manager.
  --   We also define the name of the output and the format here
  -- Arguments
  -- Notes
  -- SQWLD - add p_media_type parameter
  -----------------------------------------------------------------------------
 --
 procedure run_magtape
 (
  p_effective_date     date,
  p_report_type        varchar2,
  p_payroll_action_id  varchar2,
  p_state              varchar2,
  p_reporting_year     varchar2,
  p_reporting_quarter  varchar2,
  p_trans_legal_co_id  varchar2,
  p_media_type			  varchar2
 ) is

   l_format            varchar2(30);
   --
   -- Filenames of the output stuff
   --
   l_magfilename   varchar2(8);
   l_sumfilename   varchar2(8);
   --
   -- Request id of the magnetic tape process.
   --
   l_request_id  number;
   --
   -- Variable to hold the result of waiting for the magnetic tape process
   -- to finish.
   --
   l_wait        boolean;
   --
   -- Status information returned from the processing of the magnetic tape
   -- process.
   --
   l_phase       varchar2(30);
   l_status      varchar2(30);
   l_dev_phase   varchar2(30);
   l_dev_status  varchar2(30);
   l_date 	 varchar2(30);
   l_message     varchar2(255);
   --
   l_name                   varchar2(240);
   l_employee_number        varchar2(30);
   l_people_cnt             number;
   l_person_id		    number;

   cursor get_highly_comp is
   select a.person_id
   from pay_assignment_actions aa, per_assignments_f a
   where aa.payroll_action_id = p_payroll_action_id
   and aa.assignment_id = a.assignment_id
   and aa.serial_number is NOT NULL;

 begin

   --
   -- Get the format to be used to produce the report.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - get report format', 1);
   -- SQWLD - pass p_media_type parameter
   l_format := lookup_format(p_effective_date,
		             p_report_type,
		             p_state,
						 p_media_type);
   --
   -- Determine the name of the output filename
   --
   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - determine filename', 2);

   if p_report_type = 'W2' and p_state = 'FED' then

      l_magfilename := p_state || p_report_type || '_' ||
	 		substr(to_char(p_effective_date,'YY'),1,2);
      l_sumfilename := '6559_' || substr(to_char(p_effective_date,'YY'),1,2);

   elsif p_report_type = 'W2' and p_state <> 'FED' then

      l_magfilename := p_state || p_report_type || '_' ||
	 		substr(to_char(p_effective_date,'YY'),1,2);
      l_sumfilename := l_magfilename;

   elsif p_report_type = 'SQWL' then

      l_magfilename := p_state || '_' ||
			substr(to_char(p_effective_date,'MMYY'),1,4);
      l_sumfilename := l_magfilename;
   else

      l_magfilename := p_report_type;
      l_sumfilename := p_report_type;

   end if;

   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - determine reporting quarter', 3);
   if substr(p_reporting_quarter, 1, 2) = '03' then
      l_date := 'March 31';
   elsif substr(p_reporting_quarter, 1, 2) = '06' then
      l_date := 'June 30';
   elsif substr(p_reporting_quarter, 1, 2) = '09' then
      l_date := 'September 30';
   else
      l_date := 'December 31';
   end if;

   l_people_cnt := 0;

   FOR i in 1..70 LOOP
   g_people_text(i) := ' ';
   END LOOP;

   open get_highly_comp;
   loop
      fetch get_highly_comp into l_person_id;
      EXIT WHEN get_highly_comp%NOTFOUND;

      get_person_name(l_person_id, l_name, l_employee_number);

      l_people_cnt := l_people_cnt + 1;

      g_people_text(l_people_cnt) := fnd_global.local_chr(10) || l_name || ' (' || l_employee_number || ')';

   end loop;

   close get_highly_comp;

   g_num_peo := l_people_cnt;

   -- Start the generic magnetic tape process using the concurrent manager NB.
   -- the process is registered with SRS. This process is run as a sub request
   -- of the process running this PLSQL. This should result in the PLSQL
   -- process being paused while the magnetic tape process runs.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - submit request', 4);
   l_request_id :=
     fnd_request.submit_request
       ('PAY'
       ,program     => 'PYUMAG'
       ,description => null
       ,start_time  => null
       ,sub_request => FALSE     -- TRUE
       ,argument1   => 'pay_magtape_generic.new_formula'
       ,argument2   => l_magfilename
       ,argument3   => l_sumfilename
       ,argument4   => fnd_date.date_to_canonical(p_effective_date)
       ,argument5   =>          'MAGTAPE_REPORT_ID=' || l_format
       ,argument6   => 'TRANSFER_PAYROLL_ACTION_ID=' || p_payroll_action_id
       ,argument7   =>             'TRANSFER_STATE=' || p_state
       ,argument8   =>    'TRANSFER_REPORTING_YEAR=' || p_reporting_year
       ,argument9   => 'TRANSFER_REPORTING_QUARTER=' || p_reporting_quarter
       ,argument10  => 'TRANSFER_TRANS_LEGAL_CO_ID=' || p_trans_legal_co_id
       ,argument11  => 'TRANSFER_DATE=' || l_date
       ,argument12  => 'TRANSFER_COUNT=' || to_char(g_num_peo)
       ,argument13  => 'TRANSFER_MESSAGE_1=' || g_people_text(1)
       ,argument14  => 'TRANSFER_MESSAGE_2=' || g_people_text(2)
       ,argument15  => 'TRANSFER_MESSAGE_3=' || g_people_text(3)
       ,argument16  => 'TRANSFER_MESSAGE_4=' || g_people_text(4)
       ,argument17  => 'TRANSFER_MESSAGE_5=' || g_people_text(5)
       ,argument18  => 'TRANSFER_MESSAGE_6=' || g_people_text(6)
       ,argument19  => 'TRANSFER_MESSAGE_7=' || g_people_text(7)
       ,argument20  => 'TRANSFER_MESSAGE_8=' || g_people_text(8)
       ,argument21  => 'TRANSFER_MESSAGE_9=' || g_people_text(9)
       ,argument22  => 'TRANSFER_MESSAGE_10=' || g_people_text(10)
       ,argument23  => 'TRANSFER_MESSAGE_11=' || g_people_text(11)
       ,argument24  => 'TRANSFER_MESSAGE_12=' || g_people_text(12)
       ,argument25  => 'TRANSFER_MESSAGE_13=' || g_people_text(13)
       ,argument26  => 'TRANSFER_MESSAGE_14=' || g_people_text(14)
       ,argument27  => 'TRANSFER_MESSAGE_15=' || g_people_text(15)
       ,argument28  => 'TRANSFER_MESSAGE_16=' || g_people_text(16)
       ,argument29  => 'TRANSFER_MESSAGE_17=' || g_people_text(17)
       ,argument30  => 'TRANSFER_MESSAGE_18=' || g_people_text(18)
       ,argument31  => 'TRANSFER_MESSAGE_19=' || g_people_text(19)
       ,argument32  => 'TRANSFER_MESSAGE_20=' || g_people_text(20)
       ,argument33  => 'TRANSFER_MESSAGE_21=' || g_people_text(21)
       ,argument34  => 'TRANSFER_MESSAGE_22=' || g_people_text(22)
       ,argument35  => 'TRANSFER_MESSAGE_23=' || g_people_text(23)
       ,argument36  => 'TRANSFER_MESSAGE_24=' || g_people_text(24)
       ,argument37  => 'TRANSFER_MESSAGE_25=' || g_people_text(25)
       ,argument38  => 'TRANSFER_MESSAGE_26=' || g_people_text(26)
       ,argument39  => 'TRANSFER_MESSAGE_27=' || g_people_text(27)
       ,argument40  => 'TRANSFER_MESSAGE_28=' || g_people_text(28)
       ,argument41  => 'TRANSFER_MESSAGE_29=' || g_people_text(29)
       ,argument42  => 'TRANSFER_MESSAGE_30=' || g_people_text(30)
       ,argument43  => 'TRANSFER_MESSAGE_31=' || g_people_text(31)
       ,argument44  => 'TRANSFER_MESSAGE_32=' || g_people_text(32)
       ,argument45  => 'TRANSFER_MESSAGE_33=' || g_people_text(33)
       ,argument46  => 'TRANSFER_MESSAGE_34=' || g_people_text(34)
       ,argument47  => 'TRANSFER_MESSAGE_35=' || g_people_text(35)
       ,argument48  => 'TRANSFER_MESSAGE_36=' || g_people_text(36)
       ,argument49  => 'TRANSFER_MESSAGE_37=' || g_people_text(37)
       ,argument50  => 'TRANSFER_MESSAGE_38=' || g_people_text(38)
       ,argument51  => 'TRANSFER_MESSAGE_39=' || g_people_text(39)
       ,argument52  => 'TRANSFER_MESSAGE_40=' || g_people_text(40)
       ,argument53  => 'TRANSFER_MESSAGE_41=' || g_people_text(41)
       ,argument54  => 'TRANSFER_MESSAGE_42=' || g_people_text(42)
       ,argument55  => 'TRANSFER_MESSAGE_43=' || g_people_text(43)
       ,argument56  => 'TRANSFER_MESSAGE_44=' || g_people_text(44)
       ,argument57  => 'TRANSFER_MESSAGE_45=' || g_people_text(45)
       ,argument58  => 'TRANSFER_MESSAGE_46=' || g_people_text(46)
       ,argument59  => 'TRANSFER_MESSAGE_47=' || g_people_text(47)
       ,argument60  => 'TRANSFER_MESSAGE_48=' || g_people_text(48)
       ,argument61  => 'TRANSFER_MESSAGE_49=' || g_people_text(49)
       ,argument62  => 'TRANSFER_MESSAGE_50=' || g_people_text(50)
       ,argument63  => 'TRANSFER_MESSAGE_51=' || g_people_text(51)
       ,argument64  => 'TRANSFER_MESSAGE_52=' || g_people_text(52)
       ,argument65  => 'TRANSFER_MESSAGE_53=' || g_people_text(53)
       ,argument66  => 'TRANSFER_MESSAGE_54=' || g_people_text(54)
       ,argument67  => 'TRANSFER_MESSAGE_55=' || g_people_text(55)
       ,argument68  => 'TRANSFER_MESSAGE_56=' || g_people_text(56)
       ,argument69  => 'TRANSFER_MESSAGE_57=' || g_people_text(57)
       ,argument70  => 'TRANSFER_MESSAGE_58=' || g_people_text(58)
       ,argument71  => 'TRANSFER_MESSAGE_59=' || g_people_text(59)
       ,argument72  => 'TRANSFER_MESSAGE_60=' || g_people_text(60)
       ,argument73  => 'TRANSFER_MESSAGE_61=' || g_people_text(61)
       ,argument74  => 'TRANSFER_MESSAGE_62=' || g_people_text(62)
       ,argument75  => 'TRANSFER_MESSAGE_63=' || g_people_text(63)
       ,argument76  => 'TRANSFER_MESSAGE_64=' || g_people_text(64)
       ,argument77  => 'TRANSFER_MESSAGE_65=' || g_people_text(65)
       ,argument78  => 'TRANSFER_MESSAGE_66=' || g_people_text(66)
       ,argument79  => 'TRANSFER_MESSAGE_67=' || g_people_text(67)
       ,argument80  => 'TRANSFER_MESSAGE_68=' || g_people_text(68)
       ,argument81  => 'TRANSFER_MESSAGE_69=' || g_people_text(69)
       ,argument82  => 'TRANSFER_MESSAGE_70=' || g_people_text(70)

);
   --
   -- Detect if the request was really submitted.
   -- If it has not then handle the error.
   --
   if l_request_id = 0 then
     g_message_text := 'Failed to submit concurrent request';
     raise hr_utility.hr_error;
   end if;
   --
   -- Request has been accepted so update payroll action with the
   -- request details.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - update pay_payroll_actions', 5);
   update pay_payroll_actions PPA
   set    PPA.request_id        = l_request_id
   where  PPA.payroll_action_id = p_payroll_action_id;
   --
   -- Issue a commit to synchronise the concurrent manager.
   --
   commit;
   --
   -- Wait for process to finish and get its status..
   --
   hr_utility.set_location('pay_us_magtape_reporting.run_magtape - wait for process to finish', 6);
--   l_wait := fnd_concurrent.wait_for_request
--               (request_id => l_request_id
--               ,interval   => 5
--               ,max_wait   => 9999999  /* until child finishes */
--               ,phase      => l_phase
--               ,status     => l_status
--               ,dev_phase  => l_dev_phase
--               ,dev_status => l_dev_status
--               ,message    => l_message);
   --
   -- Process has failed.
   --
--   if not (l_dev_phase = 'COMPLETE' and l_dev_status = 'NORMAL') then
--     g_message_text := 'Magnetic tape process has failed';
--     raise hr_utility.hr_error;
--   end if;
   --
 end run_magtape;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   get_dates
  -- Purpose
  --   The dates
  --   are dependent on the report being run i.e. a W2 report shows information
  --   for a tax year while a SQWL report shows information for a quarter
  --   within a tax year.
  -- Arguments
  -- Notes
  -----------------------------------------------------------------------------
 --
 procedure get_dates
 (
  p_report_type   varchar2,
  p_quarter       varchar2,
  p_year          varchar2,
  p_period_end    in out nocopy  date,
  p_quarter_start in out nocopy  date,
  p_quarter_end   in out nocopy  date,
  p_year_start    in out nocopy  date,
  p_year_end      in out nocopy  date,
  p_rep_year      in out nocopy  varchar2,
  p_rep_quarter   in out nocopy  varchar2
 ) is

 l_rep_quarter varchar2(6);

 begin
   --
   -- Report is W2 ie. a yearly report where the identifier indicates the year
   -- eg. 1995. The expected values for the example should be
   --
   -- p_period_end        31-DEC-1995
   -- p_quarter_start     01-OCT-1995
   -- p_quarter_end       31-DEC-1995
   -- p_year_start        01-JAN-1995
   -- p_year_end          31-DEC-1995
   -- p_reporting_year    1995
   -- p_reporting_quarter 1295
   --
   if    p_report_type = 'W2' then
     p_rep_year      := p_year;
     p_rep_quarter   := '12' || to_char(to_date(p_year, 'YYYY'),'YY');
     p_period_end    := to_date('31-12-'||p_rep_year, 'DD-MM-YYYY');
     p_quarter_start := to_date('01-10-'||p_rep_year, 'DD-MM-YYYY');
     p_quarter_end   := to_date('31-12-'||p_rep_year, 'DD-MM-YYYY');
   --
   -- Report is SQWL ie. a quarterly report where the identifier indicates the
   -- quarter eg. 0395.
   --
   -- p_period_end        31-MAR-1995
   -- p_quarter_start     01-JAN-1995
   -- p_quarter_end       31-MAR-1995
   -- p_year_start        01-JAN-1995
   -- p_year_end          31-DEC-1995
   -- p_reporting_year    1995
   -- p_reporting_quarter 0395
   --
   elsif p_report_type = 'SQWL' then
     p_rep_year      := p_year;
     p_rep_quarter   := p_quarter || to_char(to_date(p_year, 'YYYY'),'YY');
hr_utility.set_location('pay_us_magtape_reporting.get dates', 1);
     l_rep_quarter   := p_quarter || to_char(to_date(p_year, 'YYYY'),'YYYY');
hr_utility.set_location('pay_us_magtape_reporting.get dates', 2);
hr_utility.trace('l_rep_quarter'||l_rep_quarter);
     p_period_end    := last_day(to_date(l_rep_quarter, 'MMYYYY'));
hr_utility.set_location('pay_us_magtape_reporting.get dates', 3);
     p_quarter_start := add_months(p_period_end, -3) + 1;
hr_utility.set_location('pay_us_magtape_reporting.get dates', 4);
     p_quarter_end   := last_day(to_date(l_rep_quarter, 'MMYYYY'));
hr_utility.set_location('pay_us_magtape_reporting.get dates', 5);
   end if;
   --
   p_year_start := to_date('01-01-'||p_rep_year, 'DD-MM-YYYY');
   p_year_end   := to_date('31-12-'||p_rep_year, 'DD-MM-YYYY');
   --
 end get_dates;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   check_report_unique
  -- Purpose
  --   Makes sure that a report has not already been run which overlaps with
  --   the report being started.
  -- Arguments
  -- Notes
  --   Each report is uniquely defined by the EFFECTIVE_DATE and the
  --   LEGISLATIVE_PARAMETERS of the payroll action. The LEGISLATIVE_PARAMETERS
  --   is set to report_type || '-' || p_state.  In order to resubmit this report
  --   we need to add transmitter legal company id onto the LEGISLATIVE PARAMETERS.
  --   To ensure that a report with a for the same state and same period is not run
  --   for different transmitters.  I added the '%' to where clause.
  -----------------------------------------------------------------------------
 --
 procedure check_report_unique
 (
  p_business_group_id in number,
  p_period_end        in date,
  p_report_type       in varchar2,
  p_state             in varchar2
 ) is
   --
   -- Select all payroll actions used to report W2 and SQWLs that have an
   -- EFFECTIVE_DATE that matches that of the report being run and have the
   -- same LEGISLATIVE_PARAMETERS value. If a payroll action is found then
   -- the report has already been run.
   --
   cursor csr_payroll_action is
     select PA.payroll_action_id
     from   pay_payroll_actions PA
     where  PA.business_group_id      = p_business_group_id
       and  PA.effective_date         = p_period_end
       and  PA.legislative_parameters like 'USMAGTAPE'            || '-' ||
				           lpad(p_report_type, 5) || '-' ||
				           lpad(p_state      , 5) || '%';
   --
   l_payroll_action_id pay_payroll_actions.payroll_action_id%type;
   --
 begin
   --
   -- Check report has not already been run.
   --
   hr_utility.set_location('pay_us_magtape_reporting.check_report_unique -opening cursor', 1);
   open csr_payroll_action;
   hr_utility.set_location('pay_us_magtape_reporting.check_report_unique -fetching cursor', 2);
   fetch csr_payroll_action into l_payroll_action_id;
   if csr_payroll_action%found then
     close csr_payroll_action;
     g_message_text := 'Report has already been run';
     raise hr_utility.hr_error;
   else
   hr_utility.set_location('pay_us_magtape_reporting.check_report_unique - report unique', 3);
     close csr_payroll_action;
   end if;
   --
 end check_report_unique;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   lookup_format
  -- Purpose
  --   Find the format to be applied when generating the report.
  -- Arguments
  -- Notes
  -- SQWLD - p_media_type param
  -----------------------------------------------------------------------------
 --
 function lookup_format
 (
  p_period_end  in date,
  p_report_type in varchar2,
  p_state       in varchar2,
  p_media_type  in varchar2
 ) return varchar2 is
   --
   -- Find the format to be used by the report.
   --
   -- SQWLD - cursor for tape format expects *no* 'D' at end of format name
   cursor csr_tape_format is
     select RM.report_format
     from   pay_report_format_mappings_f RM
     where  RM.report_type      = p_report_type
       and  RM.report_qualifier = p_state
       and  RM.report_format not like '%D'
       and  p_period_end between RM.effective_start_date
			     and RM.effective_end_date;
   --
   -- SQWLD - cursor for disk format expects 'D' at end of format name
   cursor csr_disk_format is
     select RM.report_format
     from   pay_report_format_mappings_f RM
     where  RM.report_type      = p_report_type
       and  RM.report_qualifier = p_state
       and  RM.report_format like '%D'
       and  p_period_end between RM.effective_start_date
			     and RM.effective_end_date;
   --
   l_format varchar2(30);
   --
 begin
   --

	hr_utility.trace('lookup_format, p_media_type: <' || p_media_type || '>');

   -- BHOMAN _ hard-coded support for SD diskette format
   -- if p_report_type = 'SQWL' AND p_state in ('SD') AND p_media_type = 'PD' then
	  -- return 'SDSQWLD';
   -- end if;

   -- SQLWLD use different cursor depending on p_report_type and p_media_type
   if p_report_type = 'SQWL' AND p_media_type = 'PD' then
     -- Get the diskette format.
     --
     --
     open csr_disk_format;
     hr_utility.set_location('pay_us_magtape_reporting.lookup_format - get format', 1);
     fetch csr_disk_format into l_format;
     if csr_disk_format%notfound then
       close csr_disk_format;
       g_message_text := 'Cannot find format for report';
       raise hr_utility.hr_error;
     else
     hr_utility.set_location('pay_us_magtape_reporting.lookup_format - found format', 2);
       close csr_disk_format;
     end if;
 	else -- not SQWLD and diskette
     -- Get the tape format.
     --
     open csr_tape_format;
     hr_utility.set_location('pay_us_magtape_reporting.lookup_format - get format', 1);
     fetch csr_tape_format into l_format;
     if csr_tape_format%notfound then
       close csr_tape_format;
       g_message_text := 'Cannot find format for report';
       raise hr_utility.hr_error;
     else
     hr_utility.set_location('pay_us_magtape_reporting.lookup_format - found format', 2);
       close csr_tape_format;
     end if;
	end if;
   --
   return (l_format);
   --
 end lookup_format;
 --
  -----------------------------------------------------------------------------
  -- Name
  --   run
  -- Purpose
  --   This is the main procedure responsible for generating the list of
  --   assignment actions and then submitting the request to produce the
  --   magnetic tape report.
  -- Arguments
  --   errbuf              - error message string passed back to SRS.
  --   retcode             - error code passed back to SRS ie.
  --                           0 - Success
  --                           1 - Warning
  --                           2 - Error
  --   p_business_group_id - business group the user is running under when the
  --                         report is generated.
  --   p_report_type       - either 'W2' or 'SQWL'
  --   p_state             - either 'FED' for federal or the state code of a
  --                         state eg. PA for Pennsylvania
  --   p_quarter           - identifies the quarter being reported eg. 03 is
  --                         the 1st quarter.  This is defaulted to '12' for
  --                         the W2 Report
  --   p_year              - identifies the year being reported on.
  --   p_trans_legal_co_id - identifies the Transmitter Tax Unit.

  -- Notes
  --   This procedure is invoked from the SRS screens.
  -----------------------------------------------------------------------------
 --
 procedure run
 (
  errbuf               out nocopy  varchar2,
  retcode              out nocopy  number,
  p_business_group_id   in number,
  p_report_type         in varchar2,
  p_state               in varchar2,
  p_quarter		in varchar2,
  p_year                in varchar2,
  p_trans_legal_co_id   in number,
  p_media_type  		   in varchar2
 ) is
   --

   c_period_end        date;
   c_quarter_start     date;
   c_quarter_end       date;
   c_year_start        date;
   c_year_end          date;
   c_reporting_year    varchar2(4);
   c_reporting_quarter varchar2(4);
   l_payroll_action_id pay_payroll_actions.payroll_action_id%type;
   l_trans_legal_co_id number;
   l_request_id        number;
   l_format	       	  varchar2(30);
   --
 begin
   --
   -- Derive the start and end dates of the period being reported on.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run - get dates', 1);
   get_dates(p_report_type,
	     p_quarter,
             p_year,
             c_period_end,
	     c_quarter_start,
	     c_quarter_end,
	     c_year_start,
	     c_year_end,
             c_reporting_year,
             c_reporting_quarter);
   --
   -- Make sure the report has not already been run.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run - check report unique', 2);
   check_report_unique(p_business_group_id,
                       c_period_end,
                       p_report_type,
                       p_state);


   --
   -- Get the format to be used to produce the report.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run - get report format', 3);
   l_format := lookup_format(c_period_end,
		             p_report_type,
		             p_state,
						 p_media_type);


   --
   -- See if a transmitter legal company was specified NB. it is not
   -- possible to pass NULL parameters to the process so a value has to be
   -- set ie. '-1'.
   --
   l_trans_legal_co_id := nvl(p_trans_legal_co_id, -1);


   --
   -- Generate payroll action and assignment actions for all the people to be
   -- reported on NB. the list of people is dependent on the report being
   -- run. If there are no people to report on then there is no need to
   -- submit the process to produce the report. The variable
   -- l_payroll_action_id holds the ID of the created payroll action.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run - generate people list', 4);
   l_payroll_action_id := generate_people_list(p_report_type,
                                               p_state,
                                               l_trans_legal_co_id,
                                               p_business_group_id,
                                               c_period_end,
                                               c_quarter_start,
                                               c_quarter_end,
                                               c_year_start,
                                               c_year_end,
															  p_media_type);


   --
   -- A payroll action has been created which means that at least one
   -- assignment action has been created so the magnetic tape report has to
   -- be run.  Before we run the magnetic tape proces we will archive
   -- certain DBitems
   --
   if l_payroll_action_id is not null then
     --
     -- Initiate archiving
     --
   hr_utility.set_location('pay_us_magtape_reporting.run - initiate archiving', 5);
     pay_magtape_extract.arch_main('S',
				   l_payroll_action_id);
     --
     -- Start the generic magnetic tape process.
     --
   hr_utility.set_location('pay_us_magtape_reporting.run - run magtape', 6);
     run_magtape(c_period_end,
                 p_report_type,
 	         l_payroll_action_id,
 	         p_state,
 	         c_reporting_year,
	         c_reporting_quarter,
 	         l_trans_legal_co_id,
				p_media_type);
   --
   -- A payroll action has not been created so there are no people to report
   -- on.
   --
   else
     --
     -- Set up message explaining why report was not produced.
     --
     g_message_text := 'There are no employees that match ' ||
		       'the criteria for the report';
     hr_utility.raise_error;
     --
   end if;
   --
   -- Process completed successfully.
   --
   -- Update the status of the payroll and assignments actions.
   --
   hr_utility.set_location('pay_us_magtape_reporting.run - update action status', 6);
   update_action_statuses(l_payroll_action_id);
   --
   -- Set up success return code.
   --
   retcode := 0;
 --
 -- Traps all exceptions raised within the procedure, extracts the message
 -- text associated with the exception and sets this up for SRS to read.
 --
 exception
   when hr_utility.hr_error then
     --
     -- If a payroll action exists then error it.
     --
     if l_payroll_action_id is not null then
       error_payroll_action(l_payroll_action_id);
     end if;
     --
     -- Set up error message and error return code.
     --
     errbuf  := g_message_text;
     retcode := 2;
     --
   when others then
     --
     -- If a payroll action exists then error it.
     --
     if l_payroll_action_id is not null then
       error_payroll_action(l_payroll_action_id);
     end if;
     --
     -- Set up error message and error return code.
     --
     errbuf  := sqlerrm;
     retcode := 2;
     --
 end run;
--
end pay_us_magtape_reporting;

/
