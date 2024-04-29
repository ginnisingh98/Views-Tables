--------------------------------------------------------
--  DDL for Package Body SSP_SSP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSP_PKG" as
/* $Header: spsspapi.pkb 120.18.12010000.4 2009/04/09 05:29:56 npannamp ship $
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Statutory Sick Pay Business Process
--
Purpose
	To perform calculation of entitlement and payment for SSP purposes.
--
History
	11 Sep 95	N Simpson	Created
	19 Sep 95	N Simpson	Removed LEL constant and replaced it
					with ssp_SMP_pkg.c_LEL. Added procedure
					check_sickness_date_change.
	27 Oct 95	N Simpson	Renamed all ssp objects to begin with
					ssp_ instead of hr_
	31 Oct 95	N Simpson	Added workaround for 10.6 to check
					pay_legislation_rules for indication
					of SSP installation. This fix should
					be removed from the code after 10.7.
					See ssp_is_installed function.
	 3 Nov 95	N Simpson	Modified function linked_PIW_end_date.
					The check on whether the cursor
					returned a row or not was not valid
					because MAX ensures a row is always
					returned. Changed the test to look for
					a value in the return variable.
	15 Nov 95	N Simpson	Removed hr_utility.trace from
					linked_PIW_end_date because of pragma
					added to header.
	16 Nov 95	N Simpson	Renamed parameter call to
					get_entry_details
	29 Nov 95	N Simpson	Added error trapping to
					get_SSP...element procedures.
	29 Nov 95	N Simpson	Added to_char to convert date pl/sql
					variables prior to insert into entry
					values in insert_element_entry calls.
	29 Nov 95	N Simpson	Changed value placed in qualifying days
					entry value from qualifying days in the
					calendar week to qualifying days in the
					absence period.
	 5 Dec 95	N Simpson	Removed test for length of absence from
					cursor PIW because it was restricting
					unnecessarily to absences longer than
					the PIW threshhold. If an absence has
					a linked_absence_id then it must be a
					PIW anyway, even if it is too short to
					be a PIW in its own right.
	9 Feb 96	N Simpson	When calculating amount of SSP, add
					0.004 before rounding instead of 0.0049
					so that decimal places after the third
					one are ignored.
	4 Apr 96	N Simpson	Modified absence_is_a_PIW to take
					account of contiguous absences AFTER
					the one being checked as well as
					those prior to it.
					Modified linked_absence_id to cascade
					a linked_absence_id to contiguous
					absences which become part of a PIW
					by virtue of the insertion of a new
					absence which takes the total unbroken
					absence period over the threshhold.
	9 Apr 96	N Simpson	New procedure update_linked_absence_IDs
	24 Aug 96       C Barbieri      Changed the select stmt in the
                                        csr_missing_links cursor definition in
                                        order to use index per_absence_attendan
                                        ces_fk4.
        13 Nov 96       C Barbieri      Bug. 418895: changed the check about the
                                        SSP entitlement. Now when an absence is
                                        entered that is not in a PIW, we delete
                                        all the old entries and stoppages.
        21 Jan 97       C Barbieri      Bg 441738: Changed this_week.date_earned
                                        to pick up the absence start_date,
                                        instead of the previous Sunday.
Change List
===========
Version Date       BugNo      Author     Comment
-------+----------+----------+----------+-------------------------------------
30.42   02-May-97  467870     Khabibul  Changes in check_for_break_in_linked_PIW
					csr_previous_absence. Removed NVL around
					the indexed column and replaced it with
					'OR'. The sql is then more efficient,
					with no full table scan.
					***Same fix was applied to version 30.41
					which was a backport of Prod14 (taken
					from 30.12) ****
					This is the latest version of package
					for any latest Prod releases.  ****
					Also added new 'Change List' header to
					comply with PKM standards.
30.43  09-jun-97  502108     RThirlby   Forced SSP_rate_figure to be based
                                        on the sickness_start_date instead
                                        of the PIW_start_date.
30.44  18-jul-97  513292     RThirlby   Altered qualifying_days_in_period to
                                        return default BG qualifying pattern
                                        if a person has a default as well as
                                        personal pattern at any time during
                                        their absence (linked or not).
30.45  12-Sep-97  550269     RThirlby	Explicitly open csr_qualifying_pattern
					to prevent invalid_cursor error.
30.46  29-Sep-97  504386     RThirlby   Call qualifying_days_in_period for the
                                        absence as a whole so that the pl/sql
                                        table in hr_calendar_pkg is populated
                                        once for the whole sickness absence.
30.47  03-Dec-97  589806     RThirlby	Made allowance for open ended absence
                                        in call to qualifying_days_in_period.
30.48  05-Dec-97  593097     RThirlby   Forces end_date to be the next
					Saturday, after the Sunday before
 					the sickness_start_date.
30.49  11-dec-97  555505     RThirlby   Added <= rather than < so that one
                                        day absences are accounted for.
30.50  24-mar-98  563202     RThirlby   Performance fix on cursor PIW and
					csr_qualifying_pattern.
30.51  04-Jun-98  668368     AMyers     Change so that previous stoppages are
                                        retrieved if the id is either the PIW
                                        OR the absence id and actioned
30.52  19-Jun-98  563202     AParkes    Re-wrote absence_is_a_PIW to avoid
                                        calling unnecessary sql.
                                        Changed csr_existing_entries to avoid
                                        using dt views and stop calling
                                        ssp_smp_support_pkg.value
                                        Added history for 30.51
30.53  19-AUG-98  563202     A.Myers    Loads of changes to improve efficiency,
                 /701750                such as using pl/sql tables, creating
                                        calendar for the whole PIW, not just
                                        for each absence. Also added standard
                                        trace.
110.13 16-AUG-99 886707      MVilrokx   The initialisation of l_stopage_found
                                        parameter was not correct. Moved it
                                        inside the loop so it is reset every
                                        time.  This assurs that a wating days
                                        are still generated after a user
                                        created stoppage.
115.9  08-NOV-99 1020757     MVilrokx   Fixed two problems with date conversion,
                                        one in the cursor csr_existing_entries
                                        and twice when calling insert_element_entry
115.10 04-AUG-00 1320737     DFoster	Amended the logic of the
					check_disqualifying_period which was
					causing the update of the MPP start
					date to be calculated incorrectly where
					a period of sickness went over the sixth
					week prior to the EWC
115.11 14-AUG-00 1304683     DFoster	Amended the check_average_earnings
					procedure so that it calls the new
					version of the procedure to calculate
					average earnings so that Sicknesses
					and Maternities can be dealt with
					differently.
115.14 31-JUL-01 1754802    GButler     Changed ssp_is_installed procedure.
					Procedure was checking PAY_LEGISLATION_
					RULES table for evidence that ssp was
					installed. This check was made obsolete
					in 10.7 and was causing incorrect results
					to be returned when checking for SSP
					installation
115.16 22-FEB-02 1310170   ABhaduri     Added cursor csr_previous_reason to populate
                                        the ssp_smp_support_pkg.reason_for_no_earnings
                                        variable when the employee is rehired and the
                                        absence is getting saved for the second time.
115.21 05-NOV-02 2620894   srjadhav	Changed the code so that MPP start date is
					the next day after first working day
					of (EWC - sickness_trigger_weeks) week.
115.22 12-DEC-02           AMills       nocopy addition.
115.23 27-JAN-03 	   GButler	further nocopy change to check_average
					_earnings to include 2nd dummy variable
					to act as placeholder for OUT param from
					ssp_ern_ins
115.24 03-FEB-03           ABlinko      added further restriction to maternity_details
                                        cursor. Only returns records with a leave_type
                                        of MA or null
115.25 12-MAY-03	   GButler	Changes for SSP Legislative Requirements 2003.
					Commented out stoppage code for Fixed Contract Too
					Short stoppage and changed check_service procedure
					accordingly. Also added new check_link_letter
					procedure
115.26 13-JUN-03	   GButler	Bug 2984845 - changes to do_PIW_calculations to
					fix issue where PIW lasted max time stoppage not
					being raised correctly
115.27 21-JUL-03	   ASENGAR	BUG 2984577- Added exception evidence_not_available
                                        to the procedure ENTITLED_TO_SSP to raise
                                        exception when sickness end date is not mentioned.

115.28 07-AUG-03           SSEKHAR      BUG 2984458- Added another column to csr_person
                                        cursor(leaving_reason) to give a stoppage as
                                        'Employee Died' when the employee has deceased.

115.29 08-AUG-03           SSEKHAR      BUG 2984458- The check_sql utility was not run
                                        last time when the file was arcsed in.
115.32 21-OCT-03           ASENGAR      BUG 2984577- Added code to handle linked absences
                                        when evidence is not present.
115.33 24-OCT-03           ABLINKO      BUG 3208325- Removed hardcoded SATURDAY and
                                        SUNDAY references
115.34 03-DEC-03           SSEKHAR      BUG 2984458 - Added condition to check if the
                                        Employee is deceased before raising the exception
                                        piw_max_length_reached
115.35 02-MAR-04           ABLINKO      BUG 3456918 - Added rtrim when deriving
                                        l_saturday and l_sunday
115.36 22-MAR-04 3466672   ABLINKO      Added procedure medical_control
115.37 08-JUL-04 3750125   ABLINKO      Added g_absence_del to limit use of
                                        medical_control during absence deletion
115.38 12-JUL-04           ABLINKO      check_evidence now resets last_entitled_day to
                                        stoppage start date - 1
115.39 21-JUL-04 3769536   ABLINKO      Amended person_control to work with open-ended
                                        absences
115.40 12-APR-06 5126163   KTHAMPAN     Amended do_PIW_calculation to check for total_SSP_weeks
115.41 04-AUG-06 5444012   KTHAMPAN     Amended do_PIW_calculation to reset days_remaining
115.42 23-AUG-06 5482199   KTHAMPAN     Statutory Changes for 2007.
115.45 25-AUG-06 5482199   KTHAMPAN     Amend function check_average_earnings to
                                        update the effective_date of the earnings calculations
                                        for employee over 65.
                                        Also change function check_employee_too_old to
                                        check for stoppage on the main absence.
115.46 31-AUG-06 5504380   KTHAMPAN     Added overload function linked_piw_start_date
                                        and linked_piw_end_date.
115.49 06-SEP-06 5510601   KTHAMPAN     Amend linked_PIW_start_date/end_date functions.
                                        Added overload function linked_PIW_start_date,
                                        linked_PIW_end_date and absence_is_a_PIW.
                 5517272   KTHAMPAN     Amend check_age to pass the least of PIW_end_date
                                        and 1 0ctober 2006 to the stoppage end date.
115.51 08-SEP-06 5517272   KTHAMPAN     Amend the check_age to use the absence end date
                                        instead of 1 October 2006.
115.52 09-SEP-06 5517272   HWINSOR      Changed nocopy declaration
115.53 19-SEP-06 5550795   KTHAMPAN     Amend the check_age
115.54 12-OCT-06 5583730   NPERSHAD     Modified the function absence_is_a_PIW with 4 parameters.
115.55 09-DEC-06 5706912   KTHAMPAN     Amend procedure ins_ssp_temp_affected_rows_PIW,
                                        update_linked_absence_ids and person_control
115.56 19-MAR-07 5932995   HWINSOR      Arcs in KTHAMPAN changes. Employees starting
                                        post 1-Oct-06 have correct PIW start dates.
115.57 23-DEC-07 6658285   PBALU        Changed a For loop in qualifying_days_in_period to use
					PL/sql table instead of cursor as the cursor is opened/closed
					inside the for loop.
115.58 19-Sep-08 6860926   EMUNISEK     Changed the less than zero condition on weeks_remaining to
                                        account for the rounding error of decimal values
115.60 03-Feb-09 7688727   NPANNAMP     When creating SSP correction element previously LSP was passed
				        now it is changed to Final Process date similar to SMP/SAP corrections
115.61 09-Apr-09 8356706   NPANNAMP     variables l_saturday, l_sunday moved from package body level to
                                        ENTITLED_TO_SSP function variables, to avoid issues of package state
                                        not resetting when used in OA Pages.
===============================================================================
*/
g_package               constant varchar2 (31) := 'SSP_SSP_pkg.';
g_SSP_is_installed      boolean;
g_SSP_legislation      	ssp_SSP_pkg.csr_SSP_element_details%rowtype;
g_SSP_correction        ssp_SSP_pkg.csr_SSP_element_details%rowtype;
g_PIW_id                number := null;
g_absence_del           varchar2(1) := 'N';
PIW_start_date          date;
PIW_end_date            date;
all_pat_calendar_days   number;
perf_start_date         date;
perf_end_date           date;
/* Bug Fix 8356706 Begin
l_saturday  varchar2(100) := rtrim(to_char(to_date('06/01/2001','DD/MM/YYYY'),'DAY'));
l_sunday    varchar2(100) := rtrim(to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY'));
-- These variables moved inside of ENTITLED_TO_SSP function
Bug Fix 8356706 End */
--
attempt_to_add_to_end_of_time	exception;
pragma exception_init (attempt_to_add_to_end_of_time,-01841);
--
-- Bug 2984458 Column leaving_reason has been included in this cursor
cursor csr_person (
	--
	-- Personal details of absentee, including their current period of
	-- service, their age etc.
	--
	p_date_start	in date,
	p_person_id	in number) is
	--
	select	person.date_of_birth,
		person.date_of_death,
		person.person_id,
		person.sex,
		person.full_name,
		service.date_start,
		service.prior_employment_SSP_weeks,
		service.prior_employment_SSP_paid_to,
		nvl (service.projected_termination_date,
			hr_general.end_of_time) PROJECTED_TERMINATION_DATE,
		nvl (service.actual_termination_date,
			hr_general.end_of_time) ACTUAL_TERMINATION_DATE,
		nvl (service.last_standard_process_date,
			hr_general.end_of_time) LAST_STANDARD_PROCESS_DATE,
/* 7688727 begin */
                nvl (service.final_process_date,
                        hr_general.end_of_time) FINAL_PROCESS_DATE,
/* 7688727 End */
		service.leaving_reason
	from	per_all_people_f	PERSON,
		per_periods_of_service	SERVICE
	where	person.person_id = p_person_id
	and	service.person_id = person.person_id
	and	p_date_start between service.date_start
				and nvl (service.actual_termination_date,
					hr_general.end_of_time);
--
absentee        csr_person%rowtype;
--
cursor csr_absence_details (p_absence_attendance_id in number) is
	--
	-- Get the details of an absence, given its ID.
	--
	select	*
	from	per_absence_attendances
	where	absence_attendance_id = p_absence_attendance_id;
	--
g_absence	per_absence_attendances%rowtype;
--
cursor PIW is
	--
	-- Get all the PIWs which link to this one
	--
-- 563202 nvl removed from the where clause as was implicitly causing the
-- index to be removed.
        select	sickness_start_date,
                nvl(sickness_end_date,hr_general.end_of_time) sickness_end_date,
                business_group_id,
                absence_attendance_id,
                pregnancy_related_illness
          from  per_absence_attendances
         where (g_PIW_id = absence_attendance_id and linked_absence_id is null)
            or  g_PIW_ID = linked_absence_id
        order by sickness_start_date;
--
type number_table is table of number index by binary_integer;
type date_table is table of date index by binary_integer;
type varchar_table is table of varchar2 (255) index by binary_integer;
--
type SSP_info is record (
	--
	element_entry_id	number_table,
	effective_start_date	date_table,
	effective_end_date	date_table,
	element_link_id		number_table,
	assignment_id		number_table,
	date_from		date_table,
	date_to			date_table,
	amount			number_table,
	rate			number_table,
	qualifying_days		number_table,
	SSP_days_due		number_table,
	withheld_days		number_table,
	SSP_weeks		number_table,
	dealt_with		varchar_table);
--
-- A store for all the SSP entries that may be granted to the absentee.
--
new_entry	SSP_info;
empty_record	SSP_info; -- Used to initialise SSP_info records
--------------------------------------------------------------------------------
procedure get_absence_details (p_absence_attendance_id in number) is
--
-- Get the details of the absence from the absence id passed in.
--
l_proc	varchar2 (72) := g_package||'get_absence_details';
--
procedure check_parameters is
	--
	begin
	--
	hr_utility.trace (l_proc||'   p_absence_attendance_id = ' ||
                          to_char (p_absence_attendance_id));
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'absence_attendance_id',
		p_argument_value=> p_absence_attendance_id);
		--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
open csr_absence_details (p_absence_attendance_id);
fetch csr_absence_details into g_absence;
--
if csr_absence_details%notfound
then
   --
   -- The cursor unexpectedly returned no rows.
   --
   close csr_absence_details;
   fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.set_token ('PROCEDURE','ssp_ssp_pkg.get_absence_details');
   fnd_message.set_token ('STEP','1');
   fnd_message.raise_error;
else
   close csr_absence_details;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end get_absence_details;
--------------------------------------------------------------------------------
function Standard_week_fraction (
--
-- Returns the legislative standard fraction to be used for a specified number
-- of qualifying days in a week.
--
p_qualifying_days	in integer)
--
return number is
--
standard_fraction	number;
l_proc			varchar2 (72) := g_package||'Standard_week_fraction';
--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_qualifying_days is not null
				and p_qualifying_days in (1,2,3,4,5,6,7));
	--
	begin
	--
	hr_utility.trace (l_proc||'    p_qualifying_days = ' ||
                          to_char (p_qualifying_days));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
if    p_qualifying_days = 1 then standard_fraction := 1;
elsif p_qualifying_days = 2 then standard_fraction := 0.5;
elsif p_qualifying_days = 3 then standard_fraction := 0.334;
elsif p_qualifying_days = 4 then standard_fraction := 0.25;
elsif p_qualifying_days = 5 then standard_fraction := 0.2;
elsif p_qualifying_days = 6 then standard_fraction := 0.167;
elsif p_qualifying_days = 7 then standard_fraction := 0.143;
end if;
--
hr_utility.trace (l_proc||'  standard_fraction = '||to_char(standard_fraction));
hr_utility.set_location('Leaving :'||l_proc,100);
--
return standard_fraction;
--
end standard_week_fraction;
--------------------------------------------------------------------------------
procedure get_SSP_element (p_effective_date in date) is
--
-- Get the SSP element legislative parameters
--
begin
--
if g_SSP_legislation.element_type_id is null or
   p_effective_date not between g_SSP_legislation.effective_start_date
                            and g_SSP_legislation.effective_end_date
then
   --
   -- If we have not already done so, do the following:
   --
   open ssp_SSP_pkg.csr_SSP_element_details (p_effective_date);
   fetch ssp_SSP_pkg.csr_SSP_element_details into g_SSP_legislation;
   close ssp_SSP_pkg.csr_SSP_element_details;
end if;
--
/* Commented out to comply with pragma
-- Check element returned expected values (this is belt and braces checking
-- because if the check fails then it was seed data which has been incorrectly
-- set up. However, failing here may prevent more inexplicable errors
-- elsewhere).
--
if g_SSP_legislation.element_type_id is null
then
  fnd_message.set_name ('SSP', 'SSP_35077_NO_SSP_ELEMENT');
  fnd_message.set_token ('EFFECTIVE_DATE',p_effective_date);
  fnd_message.raise_error;
else
  --
  -- The element type exists
  --
  if (g_SSP_legislation.SSP_DAYS_DUE_ID is null
     or g_SSP_legislation.AMOUNT_ID is null
     or g_SSP_legislation.FROM_ID is null
     or g_SSP_legislation.TO_ID is null
     or g_SSP_legislation.RATE_ID is null
     or g_SSP_legislation.WITHHELD_DAYS_ID is null
     or g_SSP_legislation.SSP_WEEKS_ID is null
     or g_SSP_legislation.QUALIFYING_DAYS_ID is null)
  then
    --
    -- One of the input values is missing.
    --
    fnd_message.set_name ('SSP','SSP_36071_INCORRECT_INPUT_VALS');
    fnd_message.set_token ('ELEMENT_NAME',c_SSP_element_name);
    fnd_message.raise_error;
  end if;
  --
  if (g_SSP_legislation.MAXIMUM_SSP_PERIOD is null
     or g_SSP_legislation.MAXIMUM_AGE is null
     or g_SSP_legislation.LINKING_PERIOD_DAYS is null
     or g_SSP_legislation.WAITING_DAYS is null
     or g_SSP_legislation.PIW_THRESHHOLD is null
     or g_SSP_legislation.MAXIMUM_LINKED_PIW_YEARS is null
     or g_SSP_legislation.PERCENTAGE_THRESHHOLD is null)
  then
    --
    -- One of the DDF segments has not been entered.
    --
    fnd_message.set_name ('SSP','SSP_36070_MISSING_DDF_SEGMENT');
    fnd_message.set_token ('ELEMENT_NAME',c_SSP_element_name);
    fnd_message.raise_error;
  end if;
end if;
--
*/
end get_SSP_element;
--------------------------------------------------------------------------------
procedure get_SSP_correction_element (p_effective_date in date) is
--
-- Get the SSP element legislative parameters
--
l_proc	varchar2 (72) := g_package||'get_SSP_correction_element';
--
procedure check_parameters is
	--
	begin
	--
	hr_utility.trace (l_proc||'    p_effective_date = ' ||
                          to_char (p_effective_date));
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'effective_date',
		p_argument_value=> p_effective_date);
		--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
hr_utility.set_location(l_proc,2);
if g_SSP_correction.element_type_id is null or
   p_effective_date not between g_SSP_correction.effective_start_date
			and g_SSP_correction.effective_end_date
then
   --
   -- If we have not already done so, do the following:
   --
   hr_utility.set_location(l_proc,3);
   open ssp_SSP_pkg.csr_SSP_element_details (p_effective_date,
                                             c_SSP_correction_element_name);
   fetch ssp_SSP_pkg.csr_SSP_element_details into g_SSP_correction;
   close ssp_SSP_pkg.csr_SSP_element_details;
end if;
hr_utility.trace(l_proc||'  g_SSP_correction.element_type_id		:'||g_SSP_correction.element_type_id);
hr_utility.trace(l_proc||'  g_SSP_correction.effective_start_date	:'||g_SSP_correction.effective_start_date);
hr_utility.trace(l_proc||'  g_SSP_correction.effective_end_date		:'||g_SSP_correction.effective_end_date);
hr_utility.trace(l_proc||'  g_SSP_correction.MAXIMUM_SSP_PERIOD		:'||g_SSP_correction.MAXIMUM_SSP_PERIOD);
hr_utility.trace(l_proc||'  g_SSP_correction.MAXIMUM_AGE			:'||g_SSP_correction.MAXIMUM_AGE);
hr_utility.trace(l_proc||'  g_SSP_correction.LINKING_PERIOD_DAYS		:'||g_SSP_correction.LINKING_PERIOD_DAYS);
hr_utility.trace(l_proc||'  g_SSP_correction.WAITING_DAYS		:'||g_SSP_correction.WAITING_DAYS);
hr_utility.trace(l_proc||'  g_SSP_correction.PIW_THRESHHOLD		:'||g_SSP_correction.PIW_THRESHHOLD);
hr_utility.trace(l_proc||'  g_SSP_correction.MAXIMUM_LINKED_PIW_YEARS	:'||g_SSP_correction.MAXIMUM_LINKED_PIW_YEARS);
hr_utility.trace(l_proc||'  g_SSP_correction.PERCENTAGE_THRESHHOLD	:'||g_SSP_correction.PERCENTAGE_THRESHHOLD);
hr_utility.trace(l_proc||'  g_SSP_correction.SSP_DAYS_DUE_ID		:'||g_SSP_correction.SSP_DAYS_DUE_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.AMOUNT_ID			:'||g_SSP_correction.AMOUNT_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.FROM_ID			:'||g_SSP_correction.FROM_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.TO_ID			:'||g_SSP_correction.TO_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.RATE_ID			:'||g_SSP_correction.RATE_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.WITHHELD_DAYS_ID		:'||g_SSP_correction.WITHHELD_DAYS_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.SSP_WEEKS_ID		:'||g_SSP_correction.SSP_WEEKS_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.QUALIFYING_DAYS_ID		:'||g_SSP_correction.QUALIFYING_DAYS_ID);
hr_utility.trace(l_proc||'  g_SSP_correction.input_currency_code		:'||g_SSP_correction.input_currency_code);

--
-- Check element returned expected values (this is belt and braces checking,
-- if the check fails then it was seed data which has been incorrectly set up.
-- However, failing here may prevent more inexplicable errors elsewhere.
--
if g_SSP_correction.element_type_id is null
then
   fnd_message.set_name ('SSP', 'SSP_35078_NO_SSP_CORR_ELEMENT');
   fnd_message.set_token ('EFFECTIVE_DATE',p_effective_date);
   fnd_message.raise_error;
else
   --
   -- The element type exists
   --
   if (g_SSP_correction.SSP_DAYS_DUE_ID is null
      or g_SSP_correction.AMOUNT_ID is null
      or g_SSP_correction.FROM_ID is null
      or g_SSP_correction.TO_ID is null
      or g_SSP_correction.RATE_ID is null
      or g_SSP_correction.WITHHELD_DAYS_ID is null
      or g_SSP_correction.SSP_WEEKS_ID is null
      or g_SSP_correction.QUALIFYING_DAYS_ID is null)
   then
      --
      -- One of the input values is missing.
      --
      fnd_message.set_name ('SSP','SSP_36071_INCORRECT_INPUT_VALS');
      fnd_message.set_token ('ELEMENT_NAME',c_SSP_element_name);
      fnd_message.raise_error;
   end if;
   --
   if (g_SSP_correction.MAXIMUM_SSP_PERIOD is null
      or g_SSP_correction.MAXIMUM_AGE is null
      or g_SSP_correction.LINKING_PERIOD_DAYS is null
      or g_SSP_correction.WAITING_DAYS is null
      or g_SSP_correction.PIW_THRESHHOLD is null
      or g_SSP_correction.MAXIMUM_LINKED_PIW_YEARS is null
      or g_SSP_correction.PERCENTAGE_THRESHHOLD is null)
   then
      --
      -- One of the DDF segments has not been entered.
      --
      fnd_message.set_name ('SSP','SSP_36070_MISSING_DDF_SEGMENT');
      fnd_message.set_token ('ELEMENT_NAME',c_SSP_element_name);
      fnd_message.raise_error;
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end get_SSP_correction_element;
--------------------------------------------------------------------------------
procedure update_linked_absence_ids is
--
-- Updates linked_absence_IDs where the absence has either become part of a
-- series or dropped out of a series due to date changes on the absence.
--
l_proc constant varchar2 (72) := g_package||'update_linked_absence_ids';
l_new_linked_absence_id		number (15) := null;
absence_links_but_shouldnt	boolean := FALSE;
absence_doesnt_link_but_should	boolean := FALSE;
--
cursor csr_missing_links is
	--
	-- Get all the absences affected by the current transaction.
	--
	select	absence.*
	from	per_absence_attendances ABSENCE,
		ssp_temp_affected_rows	TRANSACTION
	where
	(	(transaction.PIW_ID = absence.absence_attendance_id and
		 absence.linked_absence_id IS NULL)
	or
		transaction.piw_id = absence.linked_absence_id)
        and     transaction.locked = to_char(userenv('sessionid'));
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
for new_link in csr_missing_links
LOOP
   --
   -- For each absence affected by the current transaction, check that it has
   -- the correct linked_absence_id.
   --
   -- Get the linked_absence_id the absence SHOULD have.
   l_new_linked_absence_id := ssp_ssp_pkg.linked_absence_id (
						new_link.person_id,
						new_link.sickness_start_date,
						new_link.sickness_end_date);
   --
   absence_links_but_shouldnt := (l_new_linked_absence_id is null and
                                  new_link.linked_absence_id is not null);
   --
   absence_doesnt_link_but_should := (l_new_linked_absence_id is not null and
                                      new_link.linked_absence_id is null);
   --
   if (absence_links_but_shouldnt or absence_doesnt_link_but_should)
   then
      --
      -- update the absence's linked absence ID to the calculated one
      --
      update per_absence_attendances
         set linked_absence_id = l_new_linked_absence_id
       where absence_attendance_id = new_link.absence_attendance_id;
      --
      if l_new_linked_absence_id is not null
         --
         -- if the absence has been updated from being a whole PIW series in
         -- its own right to being just one of another series.
      then
         --
         -- Update the list of PIWs affected by the current transaction to
         -- reflect the PIW series actually affected.
         --
         update ssp_temp_affected_rows
            set PIW_ID = l_new_linked_absence_id
          where PIW_ID = new_link.absence_attendance_id;
      end if;
   end if;
end loop;
--
hr_utility.set_location('Leaving :'||l_proc, 100);
--
end update_linked_absence_ids;
--------------------------------------------------------------------------------
--
-- Return the absence_attendance_id of the first absence in a series of
-- sickness absences which are separated by less than a defined period.
--
function linked_absence_id(p_person_id in number,
                           p_sickness_start_date in date,
                           p_sickness_end_date in date) return number is
     l_proc	varchar2 (72) := g_package||'linked_absence_id';
     --
     -- Get all sickness absences prior to the current one, that do not have
     -- a linked_absence_id and are not the start absence of the PIW.
     cursor csr_contiguous_absences is
     select absence_attendance_id,
            sickness_start_date,
            sickness_end_date
     from   per_absence_attendances
     where  person_id = p_person_id
     and    sickness_start_date is not null
     and    sickness_start_date < p_sickness_start_date
     and    linked_absence_id is null
     order by sickness_start_date desc
     for update;
     --
     cursor csr_linked_absence (x_sickness_start_date date) is
     select absence_attendance_id
     from   per_absence_attendances
     where  sickness_start_date = x_sickness_start_date
     and    person_id = p_person_id;
     --
     l_PIW_id    number := null;
     l_PIW_start date := null;
     l_current_sickness_start date := p_sickness_start_date;
     --
     procedure check_parameters is
          all_parameters_valid constant boolean :=
               (p_person_id is not null and
                p_sickness_start_date <= p_sickness_end_date and
                p_sickness_start_date = trunc (p_sickness_start_date) and
                p_sickness_end_date = trunc (p_sickness_end_date));
     begin
          hr_utility.trace(l_proc||'    p_person_id = '||to_char (p_person_id));
          hr_utility.trace(l_proc||'    p_sickness_start_date = '||to_char (p_sickness_start_date));
          hr_utility.trace(l_proc||'    p_sickness_end_date = '||to_char (p_sickness_end_date));
          hr_general.assert_condition (all_parameters_valid);
     end check_parameters;
begin
     --
     hr_utility.set_location('Entering:'||l_proc,1);
     --
     check_parameters;
     --
     -- If the sickness start date is null then this cannot be a sickness absence.
     -- If SSP is not installed then this functionality is not available.
     if p_sickness_start_date is null or (not SSP_is_installed) then
        -- Return null as no linked absence is possible.
        l_PIW_id := null;
     else
        -- Get the absence_attendance_id of the first PIW in the series
        l_PIW_start := (ssp_ssp_pkg.linked_PIW_start_date(p_person_id => p_person_id,
                                                          p_sickness_start_date => p_sickness_start_date,
                                                          p_sickness_end_date => p_sickness_end_date));
        -- if there is a PIW start date
        -- and the PIW start date is not the start date for the current absence
        if l_PIW_start is not null and l_PIW_start <> p_sickness_start_date then
           open csr_linked_absence (l_PIW_start);
           fetch csr_linked_absence into l_PIW_id;
           close csr_linked_absence;
           --
           -- It is possible to enter separate but contiguous sickness absences. That
           -- means that a series of absences could be entered consisting of four,
           -- one-day absences. Each individual day would not itself comprise a PIW,
           -- but taken together, a PIW is formed. Since absences must be entered in
           -- chronological order, this would be detected on entry of the fourth one.
           -- However, if the PIW thus formed links to a previous absence, then the
           -- PIW ID must be applied to all four of the absences, not just the fourth
           -- one as it is inserted.
           for previous in csr_contiguous_absences loop
               -- previous absence is not in a contiguous series with the current one
               -- or the previous absence is the first in the current PIW
               exit when(previous.sickness_end_date <> l_current_sickness_start - 1 or
                         previous.absence_attendance_id = l_PIW_ID);
               --
               -- Set the PIW ID of the previous absence the same as the current one
               update per_absence_attendances
               set linked_absence_id = l_PIW_ID
               where current of csr_contiguous_absences;
               --
               l_current_sickness_start := previous.sickness_start_date;
           end loop;
        end if;
     end if;
     --
     hr_utility.set_location('Leaving :'||l_proc||', l_PIW_id = '||to_char (l_PIW_id),100);
     --
     return l_PIW_id;
     --
end linked_absence_id;
--------------------------------------------------------------------------------
--
-- Returns TRUE if the parameter absence constitutes a PIW in its own right
-- or if it forms part of a contiguous set of rows which together form a PIW
--
-- NB Do not add hr_utility calls in here because this function is used by
-- other functions which must maintain purity level WNDS, WNPS.
--
function absence_is_a_PIW(p_person_id           number,
                          p_sickness_start_date	date,
                          p_sickness_end_date   date) return boolean is
    --
    --select the number of days, within the period specified,
    --for which the person has absences
    cursor csr_abs_days(p_start date, p_end date) is
    select  nvl(sum(nvl(least(sickness_end_date,p_end),p_end) -
            greatest(sickness_start_date,p_start) + 1),0)
    from    per_absence_attendances
    where   person_id = p_person_id
    and     sickness_start_date <= p_end
    and     nvl(sickness_end_date,hr_general.end_of_time) >= p_start;
    --
    cursor csr_contig_abs(p_start date, p_end date,
                          p_start2 date, p_end2 date) is
    -- select the dates for the continuous absence formed by the parameter
    -- absence and any absences adjacent to it.
    select  least(min(sickness_start_date),p_start),
            greatest(max(nvl(sickness_end_date,hr_general.end_of_time)),p_end)
    from    per_absence_attendances
    where   person_id           = p_person_id
    and     (sickness_end_date  = p_start2 or sickness_start_date = p_end2);
    --
    l_days_absent         number := 0;
    l_prev_sickness_start date := null;
    l_prev_sickness_end   date := null;
    l_sickness_start_date date := p_sickness_start_date;
    l_sickness_end_date   date := nvl (p_sickness_end_date,hr_general.end_of_time);
    l_absence_is_a_PIW    boolean := FALSE;
    --
begin
     get_SSP_element (p_sickness_start_date);
     if (l_sickness_end_date - p_sickness_start_date) + 1 >= g_SSP_legislation.PIW_threshhold then
         l_absence_is_a_PIW := TRUE; -- The absence is a PIW in its own right
     else
         -- Check if the absence has contiguous absences which effectively
         -- extend the sickness start and end dates (and thus may cause a PIW to
         -- be formed).
         <<loop_form_PIW>>
         loop
             l_prev_sickness_start := l_sickness_start_date;
             l_prev_sickness_end   := l_sickness_end_date;

             -- Find contiguous absences which may contribute to a PIW
             open csr_contig_abs(l_prev_sickness_start, l_prev_sickness_end,
                                 l_prev_sickness_start - 1, l_prev_sickness_end + 1);
             fetch csr_contig_abs into l_sickness_start_date,
                                       l_sickness_end_date;

             --No contiguous absences (null returned by max function)
             if l_sickness_start_date is null then
                exit loop_form_PIW;
             elsif (l_sickness_end_date - l_sickness_start_date) +1
                    >= g_SSP_legislation.PIW_threshhold then
                -- The absence formed is a PIW
                l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                exit loop_form_PIW;
             elsif l_prev_sickness_end = l_sickness_end_date then
                -- There is no contiguous future absence so look for number of days
                -- absent within threshold period before PIW formed so far
                open csr_abs_days(l_sickness_end_date - g_SSP_legislation.PIW_threshhold +1,
                                  l_sickness_start_date -1);
                fetch csr_abs_days into l_days_absent;
                close csr_abs_days;
                --
                if (l_sickness_end_date - l_sickness_start_date) +1 +
                   l_days_absent >= g_SSP_legislation.PIW_threshhold then
                   l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                end if;
                exit loop_form_PIW;
             elsif l_prev_sickness_start = l_sickness_start_date then
                -- There is no contiguous past absence so look for number of days
                -- absent within threshold period after PIW formed so far
                open csr_abs_days(l_sickness_end_date +1,l_sickness_start_date -1
                                  + g_SSP_legislation.PIW_threshhold);
                fetch csr_abs_days into l_days_absent;
                close csr_abs_days;
                if (l_sickness_end_date - l_sickness_start_date) +1 + l_days_absent
                    >= g_SSP_legislation.PIW_threshhold then
                   l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                end if;
                exit loop_form_PIW;
             end if;
             --else two contiguous abs, so search for past and future
             --contiguous abs again
             close csr_contig_abs;
         end loop loop_form_PIW;
         close csr_contig_abs;
     end if;
     --
     return l_absence_is_a_PIW;
end absence_is_a_PIW;
--------------------------------------------------------------------------------
--
-- Overload function for the absence_is_a_PIW
function absence_is_a_PIW(p_person_id             number,
                          p_sickness_start_date	  date,
                          p_sickness_end_date     date,
                          p_absence_attendance_id number) return boolean is
    --
    --select the number of days, within the period specified,
    --for which the person has absences
    cursor csr_abs_days(p_start date, p_end date) is
    select  nvl(sum(nvl(least(sickness_end_date,p_end),p_end) -
            greatest(sickness_start_date,p_start) + 1),0)
    from    per_absence_attendances
    where   person_id = p_person_id
    and     sickness_start_date <= p_end
    and     nvl(sickness_end_date,hr_general.end_of_time) >= p_start;
    --
    cursor csr_contig_abs(p_start date, p_end date,
                          p_start2 date, p_end2 date) is
    -- select the dates for the continuous absence formed by the parameter
    -- absence and any absences adjacent to it.
    select  least(min(sickness_start_date),p_start),
            greatest(max(nvl(sickness_end_date,hr_general.end_of_time)),p_end)
    from    per_absence_attendances
    where   person_id           = p_person_id
    and     (sickness_end_date  = p_start2 or sickness_start_date = p_end2);
    --
    cursor csr_linked_id is
    select linked_absence_id
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_attendance_id;
    --
    l_days_absent         number := 0;
    l_linked              number := null;
    l_prev_sickness_start date := null;
    l_prev_sickness_end   date := null;
    l_sickness_start_date date := p_sickness_start_date;
    l_sickness_end_date   date := nvl (p_sickness_end_date,hr_general.end_of_time);
    l_absence_is_a_PIW    boolean := FALSE;
    --
begin
     get_SSP_element (p_sickness_start_date);
     if (l_sickness_end_date - p_sickness_start_date) + 1 >= g_SSP_legislation.PIW_threshhold then
         l_absence_is_a_PIW := TRUE; -- The absence is a PIW in its own right
     else
         open csr_linked_id;
         fetch csr_linked_id into l_linked;
         --if csr_linked_id%found then
	 if l_linked is not null then  --for bug fix 5583730
            l_absence_is_a_PIW := TRUE;
         else
             -- Check if the absence has contiguous absences which effectively
             -- extend the sickness start and end dates (and thus may cause a PIW to
             -- be formed).
             <<loop_form_PIW>>
             loop
                 l_prev_sickness_start := l_sickness_start_date;
                 l_prev_sickness_end   := l_sickness_end_date;

                 -- Find contiguous absences which may contribute to a PIW
                 open csr_contig_abs(l_prev_sickness_start, l_prev_sickness_end,
                                     l_prev_sickness_start - 1, l_prev_sickness_end + 1);
                 fetch csr_contig_abs into l_sickness_start_date,
                                           l_sickness_end_date;

                 --No contiguous absences (null returned by max function)
                 if l_sickness_start_date is null then
                    exit loop_form_PIW;
                 elsif (l_sickness_end_date - l_sickness_start_date) +1
                        >= g_SSP_legislation.PIW_threshhold then
                    -- The absence formed is a PIW
                    l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                    exit loop_form_PIW;
                 elsif l_prev_sickness_end = l_sickness_end_date then
                    -- There is no contiguous future absence so look for number of days
                    -- absent within threshold period before PIW formed so far
                    open csr_abs_days(l_sickness_end_date - g_SSP_legislation.PIW_threshhold +1,
                                      l_sickness_start_date -1);
                    fetch csr_abs_days into l_days_absent;
                    close csr_abs_days;
                    --
                    if (l_sickness_end_date - l_sickness_start_date) +1 +
                       l_days_absent >= g_SSP_legislation.PIW_threshhold then
                       l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                    end if;
                    exit loop_form_PIW;
                 elsif l_prev_sickness_start = l_sickness_start_date then
                    -- There is no contiguous past absence so look for number of days
                    -- absent within threshold period after PIW formed so far
                    open csr_abs_days(l_sickness_end_date +1,l_sickness_start_date -1
                                      + g_SSP_legislation.PIW_threshhold);
                    fetch csr_abs_days into l_days_absent;
                    close csr_abs_days;
                    if (l_sickness_end_date - l_sickness_start_date) +1 + l_days_absent
                        >= g_SSP_legislation.PIW_threshhold then
                       l_absence_is_a_PIW := TRUE; -- The absence formed is a PIW
                    end if;
                    exit loop_form_PIW;
                 end if;
                 --else two contiguous abs, so search for past and future
                 --contiguous abs again
                 close csr_contig_abs;
             end loop loop_form_PIW;
             close csr_contig_abs;
         end if;
     end if;
     --
     return l_absence_is_a_PIW;
end absence_is_a_PIW;
--------------------------------------------------------------------------------
procedure check_sickness_date_change (
--
-- Called from AFTER update of sickness_start_date, sickness_end_date trigger.
-- Prevents update if the change would invalidate the linked_absence_id of
-- either this row or the next one.
--
p_person_id			in number,-- :old.person_id
p_linked_absence_id		in number,-- :old.linked_absence_id
p_absence_attendance_id		in number,-- :old.absence_attendance_id
p_new_sickness_start_date	in date,-- :new.sickness_start_date
p_new_sickness_end_date		in date, -- :new.sickness_end_date
p_old_sickness_end_date		in date -- :old.sickness_end_date
) is
--
cursor csr_next_absence is
	--
	-- Get the chronologically next sickness absence
	--
	select	abs.linked_absence_id,
		abs.sickness_start_date,
		abs.sickness_end_date
	from	per_absence_attendances ABS
	where	abs.sickness_start_date is not null
	and	person_id = p_person_id
	and	abs.sickness_start_date = (
		--
		select min (abs2.sickness_start_date)
		from per_absence_attendances ABS2
		where abs2.sickness_start_date >= p_old_sickness_end_date
		and person_id = p_person_id);
	--
l_proc		varchar2 (72) := g_package||'check_sickness_date_change';
l_next_absence	csr_next_absence%rowtype;
PIW_broken	exception;
--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_person_id is not null and
				           p_absence_attendance_id is not null);
	--
	begin
	--
	hr_utility.trace ('    p_person_id = '||to_char (p_person_id));
	hr_utility.trace ('    p_linked_absence_id = '
		||to_char (p_linked_absence_id));
	hr_utility.trace ('    p_absence_attendance_id = '
		||to_char (p_absence_attendance_id));
	hr_utility.trace ('    p_new_sickness_start_date = '
		||to_char (p_new_sickness_start_date));
	hr_utility.trace ('    p_new_sickness_end_date = '
		||to_char (p_new_sickness_end_date));
	hr_utility.trace ('    p_old_sickness_end_date = '
		||to_char (p_old_sickness_end_date));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
open csr_next_absence;
fetch csr_next_absence into l_next_absence;
--
-- Compare the current values of the linked absence ids with the values they
-- are recalculated to have after the update has gone through
--
if
  -- if there is a future sickness absence
  csr_next_absence%found
  --
  -- and if the PIW series to which the updated absence belongs will change
  and (nvl (p_linked_absence_id,-1) <> nvl (linked_absence_id (p_person_id,
								p_new_sickness_start_date,
								p_new_sickness_end_date),
						nvl (p_linked_absence_id,-1))
  -- or the PIW series to which the following absence belongs will change
  or (csr_next_absence%found
     and nvl (l_next_absence.linked_absence_id, -1)
				<> nvl (linked_absence_id (p_person_id,
					l_next_absence.sickness_start_date,
					l_next_absence.sickness_end_date), -1)))
then
  --
  -- The change in sickness dates will change the PIW of the current or next
  -- sickness absence and so the update must be prevented.
  --
  close csr_next_absence;
  raise PIW_broken;
else
  close csr_next_absence;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
exception
--
when PIW_broken then
  --
  fnd_message.set_name ('SSP','SSP_35037_PIW_BROKEN');
  fnd_message.raise_error;
  --
end check_sickness_date_change;
--------------------------------------------------------------------------------
procedure CHECK_FOR_BREAK_IN_LINKED_PIW
--
-- Check the effect of removal of a sickness absence from a linked PIW.
-- See header for full description of this procedure.
--
(
p_sickness_start_date	in date,
p_sickness_end_date	in date,
p_linked_absence_id	in number,
p_absence_attendance_id	in number
)
is
--
l_proc		varchar2 (72) := g_package||'check_for_break_in_linked_PIW';
l_PIW_id	number := nvl (p_linked_absence_id, p_absence_attendance_id);
l_next_start_date	date := null;
l_previous_end_date	date := null;
l_dummy			integer (1) := null;
break_in_PIW		exception;
--
cursor csr_PIW is
	--
	-- Return a row if there are any sickness absences in a series of
	-- which this absence is first.
	--
	select	1
	from	per_absence_attendances
	where	linked_absence_id = p_absence_attendance_id;
	--
cursor csr_next_absence is
	--
	-- Get the absence which is next in the linked series of which this
	-- absence is a part.
	--
	select	max (sickness_end_date)
	from	per_absence_attendances
	where	p_linked_absence_id = linked_absence_id
	and	sickness_end_date <= p_sickness_start_date;
	--
cursor csr_previous_absence is
	--
	-- Get the absence which is the previous one in the linked series of
	-- which this absence is a part.
	--
	select	min (sickness_start_date)
	from	per_absence_attendances
	where	(l_PIW_id = linked_absence_id and absence_attendance_id is null)
             or (l_PIW_id = absence_attendance_id and linked_absence_id is null)
 	and	sickness_start_date >= p_sickness_end_date;
	--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_absence_attendance_id is not null
					and p_sickness_start_date <= p_sickness_end_date
					and p_sickness_start_date = trunc (p_sickness_start_date)
					and p_sickness_end_date = trunc (p_sickness_end_date)
					and p_linked_absence_id <> p_absence_attendance_id);
	--
	begin
	--
	hr_utility.trace (l_proc||'	p_sickness_start_date = '
		||to_char (p_sickness_start_date));
	hr_utility.trace (l_proc||'	p_sickness_end_date = '
		||to_char (p_sickness_end_date));
	hr_utility.trace (l_proc||'	p_linked_absence_id = '
		||to_char (p_linked_absence_id));
	hr_utility.trace (l_proc||'	p_absence_attendance_id = '
		||to_char (p_absence_attendance_id));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
if SSP_is_installed and p_sickness_start_date is not null
then
   --
   -- The SSP functionality is available and the absence is a sickness absence.
   --
   -- Is the absence the first in a linked series of absences?
   --
   open csr_PIW;
   fetch csr_PIW into l_dummy;
   --
   if csr_PIW%found then
      --
      -- This is the first absence in a linked series and may not be removed
      --
      close csr_PIW;
      raise break_in_PIW;
   else
      --
      -- This is not the first absence in a linked series
      --
      close csr_PIW;
      --
      -- Is the absence the last in a linked series?
      --
      open csr_next_absence;
      fetch csr_next_absence into l_next_start_date;
      --
      if csr_next_absence%found then
         --
         -- The absence is between other absences in a linked series.
         --
         close csr_next_absence;
         --
         -- Find the previous absence
         --
         open csr_previous_absence;
         fetch csr_previous_absence into l_previous_end_date;
         --
         -- Get the legislative parameters for SSP
         --
         get_SSP_element (p_sickness_start_date);
         --
         -- Can the next absence link directly to the previous absence without
         -- the current absence in the middle?
         --
         if l_previous_end_date
		<= (l_next_start_date - g_SSP_legislation.linking_period_days)
         then
            --
            -- The linked series will be broken by removal of this absence
            --
            raise break_in_PIW;
         end if;
      end if;
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
exception
when break_in_PIW then
   --
   -- Stop, with the message:
   -- "You may not delete this sickness absence record because to do so would
   -- result in a linked Period of Incapacity for Work (PIW) being broken. To
   -- get round this, you must first remove all the later sickness absences in
   -- the same PIW."
   --
   hr_utility.set_location('Leaving :'||l_proc||', Error',999);
   fnd_message.set_name ('SSP','SSP_35037_PIW_BROKEN');
   fnd_message.raise_error;
   --
end check_for_break_in_linked_PIW;
--------------------------------------------------------------------------------
function get_age_at_PIW(p_person_id     in number,
                        p_date          in date,
                        p_date_of_birth in date default null) return number is
     l_age number;

     cursor get_age is
     select months_between(p_date,date_of_birth)/12
     from   per_all_people_f
     where  person_id = p_person_id
     and    effective_end_date = (select max(effective_end_date)
                                  from   per_all_people_f
                                  where  person_id = p_person_id);

     cursor get_age2 is
     select months_between(p_date,p_date_of_birth)/12
     from   dual;

begin
     if p_date_of_birth is null then
        open get_age;
        fetch get_age into l_age;
        close get_age;
     else
        open get_age2;
        fetch get_age2 into l_age;
        close get_age2;
     end if;

     return l_age;
end get_age_at_PIW;
--------------------------------------------------------------------------------
function check_linked_absence(p_absence_attendance_id  in number,
                              p_start_date             out nocopy date,
                              p_end_date               out nocopy  date) return boolean is
    --
    l_linked_id  number;
    l_start_date date;
    l_end_date   date;
    l_found      boolean;
    --
    -- Get the linked ID from the absence
    cursor csr_linked_id(p_absence_id number) is
    select linked_absence_id
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_id;
    --
    cursor csr_start_date(p_absence_id number) is
    select sickness_start_date
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_id;
    --
    cursor csr_end_date(p_absence_id number) is
    select sickness_end_date
    from   per_absence_attendances
    where  (absence_attendance_id = p_absence_id
            or
            linked_absence_id = p_absence_id)
    order  by sickness_end_date desc;
    --
begin
     l_found := false;
     open csr_linked_id(p_absence_attendance_id);
     fetch csr_linked_id into l_linked_id;
     if csr_linked_id%found and l_linked_id is not null then
        l_found := true;
     end if;
     close csr_linked_id;

     if l_found then
        open csr_start_date(l_linked_id);
        fetch csr_start_date into l_start_date;
        close csr_start_date;
        --
        open csr_end_date(l_linked_id);
        fetch csr_end_date into l_end_date;
        close csr_end_date;
        --
        p_start_date := l_start_date;
        p_end_date   := l_end_date;
     end if;

     return l_found;
end check_linked_absence;
--------------------------------------------------------------------------------
function linked_PIW_start_date(p_person_id           in number,
                               p_sickness_start_date in date,
                               p_sickness_end_date   in date,
                               p_date_of_birth       in date) return date is
    --
    PIW_start date := null;
    l_01_October_06 date := to_date('01/10/2006','DD/MM/YYYY');
    l_proc varchar2(72) := g_package||'linked_PIW_start_date';
    l_sickness_end_date date := nvl(p_sickness_end_date,hr_general.end_of_time);
    l_age       number;
    l_s_date    date;
    l_e_date    date;
    --
    -- Get the linked series of sickness absences
    cursor PIW_series(p_start_date date) is
    select sickness_start_date,
           sickness_end_date,
           absence_attendance_id
    from   per_absence_attendances
    where  person_id = p_person_id
    and    sickness_start_date is not null
    and    sickness_start_date < p_sickness_start_date
    and    (p_start_date is null or
            sickness_start_date >= p_start_date)
    order by sickness_start_date desc;
    --
begin
     if p_sickness_start_date is not null then
     --
     -- This is a sickness absence
     --
        if ssp_ssp_pkg.absence_is_a_PIW(p_person_id => p_person_id,
                                        p_sickness_start_date => p_sickness_start_date,
                                        p_sickness_end_date => p_sickness_end_date) then
           -- The current absence is a PIW
           --
           PIW_start := p_sickness_start_date;
           --
           get_SSP_element (p_sickness_start_date);
           --
           l_age := get_age_at_PIW(p_person_id, l_01_October_06, p_date_of_birth);
           -----------------------------------------
           -- Age < 16 and sick after 01-Oct-2006 --
           -----------------------------------------
           if l_age < 16 and p_sickness_start_date >= l_01_October_06 then
              for preceeding in PIW_series(l_01_October_06) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date => preceeding.sickness_start_date,
                                                   p_sickness_end_date => preceeding.sickness_end_date,
                                                   p_person_id => p_person_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;

           ---------------
           -- Other Age --
           ---------------
           if (l_age >= 16) or (p_sickness_start_date < l_01_October_06) then
              for preceeding in PIW_series(null) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date => preceeding.sickness_start_date,
                                                   p_sickness_end_date => preceeding.sickness_end_date,
                                                   p_person_id => p_person_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;
        --
		end if;
        --
     end if;
     --
     return PIW_start;
     --
end linked_PIW_start_date;
--------------------------------------------------------------------------------
function linked_PIW_start_date(p_person_id           in number,
                               p_sickness_start_date in date,
                               p_sickness_end_date   in date) return date is
    --
    PIW_start date := null;
    l_01_October_06 date := to_date('01/10/2006','DD/MM/YYYY');
    l_proc varchar2(72) := g_package||'linked_PIW_start_date';
    l_sickness_end_date date := nvl(p_sickness_end_date,hr_general.end_of_time);
    l_age       number;
    l_linked_id number;
    l_s_date    date;
    l_e_date    date;
    --
    -- Get the linked series of sickness absences
    cursor PIW_series(p_start_date date) is
    select sickness_start_date,
           sickness_end_date,
           absence_attendance_id
    from   per_absence_attendances
    where  person_id = p_person_id
    and    sickness_start_date is not null
    and    sickness_start_date < p_sickness_start_date
    and    (p_start_date is null or
            sickness_start_date >= p_start_date)
    order by sickness_start_date desc;
    --
begin
     if p_sickness_start_date is not null then
     --
     -- This is a sickness absence
     --
        if ssp_ssp_pkg.absence_is_a_PIW(p_person_id => p_person_id,
                                        p_sickness_start_date => p_sickness_start_date,
                                        p_sickness_end_date => p_sickness_end_date) then
           -- The current absence is a PIW
           --
           PIW_start := p_sickness_start_date;
           --
           get_SSP_element (p_sickness_start_date);
           --
           l_age := get_age_at_PIW(p_person_id, l_01_October_06);
           -----------------------------------------
           -- Age < 16 and sick after 01-Oct-2006 --
           -----------------------------------------
           if l_age < 16 and p_sickness_start_date >= l_01_October_06 then
              for preceeding in PIW_series(l_01_October_06) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date => preceeding.sickness_start_date,
                                                   p_sickness_end_date => preceeding.sickness_end_date,
                                                   p_person_id => p_person_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;

           ---------------
           -- Other Age --
           ---------------
           if (l_age >= 16) or (p_sickness_start_date < l_01_October_06) then
              for preceeding in PIW_series(null) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date => preceeding.sickness_start_date,
                                                   p_sickness_end_date => preceeding.sickness_end_date,
                                                   p_person_id => p_person_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;
        --
		end if;
        --
     end if;
     --
     return PIW_start;
     --
end linked_PIW_start_date;
--------------------------------------------------------------------------------
--
-- Overload function with absence_attendance_id
function linked_PIW_start_date(p_person_id           in number,
                               p_sickness_start_date in date,
                               p_sickness_end_date   in date,
                               p_absence_attendance_id number) return date is
    --
    PIW_start date := null;
    l_01_October_06 date := to_date('01/10/2006','DD/MM/YYYY');
    l_proc varchar2(72) := g_package||'linked_PIW_start_date';
    l_sickness_end_date date := nvl(p_sickness_end_date,hr_general.end_of_time);
    l_age  number;
    l_s_date    date;
    l_e_date    date;
    --
    -- Get the linked series of sickness absences
    cursor PIW_series(p_start_date date) is
    select sickness_start_date,
           sickness_end_date,
           absence_attendance_id
    from   per_absence_attendances
    where  person_id = p_person_id
    and    sickness_start_date is not null
    and    sickness_start_date < p_sickness_start_date
    and    (p_start_date is null or
            sickness_start_date >= p_start_date)
    order by sickness_start_date desc;
    --
begin
     if p_sickness_start_date is not null then
     --
     -- This is a sickness absence
     --
        if ssp_ssp_pkg.absence_is_a_PIW(p_person_id => p_person_id,
                                        p_sickness_start_date   => p_sickness_start_date,
                                        p_sickness_end_date     => p_sickness_end_date,
                                        p_absence_attendance_id => p_absence_attendance_id) then
           -- The current absence is a PIW
           --
           PIW_start := p_sickness_start_date;
           --
           get_SSP_element (p_sickness_start_date);
           --
           l_age := get_age_at_PIW(p_person_id, l_01_October_06);
           -----------------------------------------
           -- Age < 16 and sick after 01-Oct-2006 --
           -----------------------------------------
           if l_age < 16 and p_sickness_start_date >= l_01_October_06 then
              for preceeding in PIW_series(l_01_October_06) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date   => preceeding.sickness_start_date,
                                                   p_sickness_end_date     => preceeding.sickness_end_date,
                                                   p_person_id             => p_person_id,
                                                   p_absence_attendance_id => preceeding.absence_attendance_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;

           ---------------
           -- Other Age --
           ---------------
           if (l_age >= 16) or (p_sickness_start_date < l_01_October_06) then
              for preceeding in PIW_series(null) LOOP
                  if (PIW_start - preceeding.sickness_end_date) <= g_SSP_legislation.linking_period_days and
                      ssp_ssp_pkg.absence_is_a_PIW(p_sickness_start_date   => preceeding.sickness_start_date,
                                                   p_sickness_end_date     => preceeding.sickness_end_date,
                                                   p_person_id             => p_person_id,
                                                   p_absence_attendance_id => preceeding.absence_attendance_id) then
                      --
                      -- The previous absence links to the current one
                      -- Decrement the PIW start to the start of the previous absence
                      --
                      if check_linked_absence(preceeding.absence_attendance_id,
                                              l_s_date, l_e_date) then
                         PIW_start := l_s_date;
                         exit;
                      end if;
                      PIW_start := preceeding.sickness_start_date;
                  end if;
              end loop;
           end if;
        --
		end if;
        --
     end if;
     --
     return PIW_start;
     --
end linked_PIW_start_date;
--------------------------------------------------------------------------------
function linked_PIW_end_date(p_person_id            in number,
                             p_sickness_start_date  in date,
                             p_sickness_end_date    in date,
                             p_date_of_birth        in date) return date is
     PIW_end	     date    := null;
     l_01_October_06 date    := to_date('01/10/2006','DD/MM/YYYY');
     l_limit_date    date    := null;
     l_age           number;
     l_s_date        date;
     l_e_date        date;
     --
     -- Get all sicknesses for the person which follow the parameter dates
     cursor PIW_series(p_start_date date) is
     select sickness_start_date,
            sickness_end_date,
            absence_attendance_id
     from   per_absence_attendances
     where  person_id = p_person_id
     and    sickness_start_date is not null
     and    sickness_start_date > p_sickness_start_date
     and    (p_start_date is null or
            sickness_start_date < p_start_date)
     order by sickness_start_date;
begin
     if (p_sickness_start_date is null or p_sickness_end_date is null) then
         PIW_end := null;
     else
         if ssp_ssp_pkg.absence_is_a_PIW(p_person_id           => p_person_id,
                                         p_sickness_start_date => p_sickness_start_date,
                                         p_sickness_end_date   => p_sickness_end_date) then
            PIW_end := p_sickness_end_date;
            --
            get_SSP_element (p_sickness_start_date);
            --
            l_age := get_age_at_PIW(p_person_id, l_01_October_06,p_date_of_birth);
            --
            if (l_age < 16) and p_sickness_start_date < l_01_October_06 then
               l_limit_date := l_01_October_06;
            end if;
            --
            --
            for next in PIW_series(l_limit_date) LOOP
                -- if the next sickness period links to the current one
                -- and the next sickness period is a PIW
                if (next.sickness_start_date - PIW_end) <= g_SSP_legislation.linking_period_days and
                   ssp_ssp_pkg.absence_is_a_PIW (p_person_id => p_person_id,
                                                 p_sickness_start_date  => next.sickness_start_date,
                                                 p_sickness_end_date    => next.sickness_end_date)then
                   --
                   -- Increment the end date to that of the next sickness period
                   --
                   if check_linked_absence(next.absence_attendance_id,
                                           l_s_date, l_e_date) then
                      PIW_end := l_e_date;
                      exit;
                   end if;
                   PIW_end := next.sickness_end_date;
                end if;
            end loop;
         end if;
     end if;
     --
     return PIW_end;
     --
end linked_PIW_end_date;
--------------------------------------------------------------------------------
function linked_PIW_end_date(p_person_id            in number,
                             p_sickness_start_date  in date,
                             p_sickness_end_date    in date) return date is
     PIW_end	     date    := null;
     l_01_October_06 date    := to_date('01/10/2006','DD/MM/YYYY');
     l_limit_date    date    := null;
     l_age           number;
     l_s_date        date;
     l_e_date        date;
     --
     -- Get all sicknesses for the person which follow the parameter dates
     cursor PIW_series(p_start_date date) is
     select sickness_start_date,
            sickness_end_date,
            absence_attendance_id
     from   per_absence_attendances
     where  person_id = p_person_id
     and    sickness_start_date is not null
     and    sickness_start_date > p_sickness_start_date
     and    (p_start_date is null or
            sickness_start_date < p_start_date)
     order by sickness_start_date;
begin
     if (p_sickness_start_date is null or p_sickness_end_date is null) then
         PIW_end := null;
     else
         if ssp_ssp_pkg.absence_is_a_PIW(p_person_id           => p_person_id,
                                         p_sickness_start_date => p_sickness_start_date,
                                         p_sickness_end_date   => p_sickness_end_date) then
            PIW_end := p_sickness_end_date;
            --
            get_SSP_element (p_sickness_start_date);
            --
            l_age := get_age_at_PIW(p_person_id, l_01_October_06);
            --
            if (l_age < 16) and
               p_sickness_start_date < l_01_October_06 then
               l_limit_date := l_01_October_06;
            end if;
            --
            --
            for next in PIW_series(l_limit_date) LOOP
                -- if the next sickness period links to the current one
                -- and the next sickness period is a PIW
                if (next.sickness_start_date - PIW_end) <= g_SSP_legislation.linking_period_days and
                   ssp_ssp_pkg.absence_is_a_PIW (p_person_id => p_person_id,
                                                 p_sickness_start_date  => next.sickness_start_date,
                                                 p_sickness_end_date    => next.sickness_end_date)then
                   --
                   -- Increment the end date to that of the next sickness period
                   --
                   if check_linked_absence(next.absence_attendance_id,
                                           l_s_date, l_e_date) then
                      PIW_end := l_e_date;
                      exit;
                   end if;
                   PIW_end := next.sickness_end_date;
                end if;
            end loop;
         end if;
     end if;
     --
     return PIW_end;
     --
end linked_PIW_end_date;
--------------------------------------------------------------------------------
--
-- Overload function with absence_attendance_id
function linked_PIW_end_date(p_person_id            in number,
                             p_sickness_start_date  in date,
                             p_sickness_end_date    in date,
                             p_absence_attendance_id number) return date is
     PIW_end	     date    := null;
     l_01_October_06 date    := to_date('01/10/2006','DD/MM/YYYY');
     l_limit_date    date    := null;
     l_age           number;
     l_s_date        date;
     l_e_date        date;
     --
     -- Get all sicknesses for the person which follow the parameter dates
     cursor PIW_series(p_start_date date) is
     select sickness_start_date,
            sickness_end_date,
            absence_attendance_id
     from   per_absence_attendances
     where  person_id = p_person_id
     and    sickness_start_date is not null
     and    sickness_start_date > p_sickness_start_date
     and    (p_start_date is null or
            sickness_start_date < p_start_date)
     order by sickness_start_date;
begin
     if (p_sickness_start_date is null or p_sickness_end_date is null) then
         PIW_end := null;
     else
         if ssp_ssp_pkg.absence_is_a_PIW(p_person_id             => p_person_id,
                                         p_sickness_start_date   => p_sickness_start_date,
                                         p_sickness_end_date     => p_sickness_end_date,
                                         p_absence_attendance_id => p_absence_attendance_id) then
            PIW_end := p_sickness_end_date;
            --
            get_SSP_element (p_sickness_start_date);
            --
            l_age := get_age_at_PIW(p_person_id, l_01_October_06);
            --
            if (l_age < 16) and
               p_sickness_start_date < l_01_October_06 then
               l_limit_date := l_01_October_06;
            end if;
            --
            --
            for next in PIW_series(l_limit_date) LOOP
                -- if the next sickness period links to the current one
                -- and the next sickness period is a PIW
                if (next.sickness_start_date - PIW_end) <= g_SSP_legislation.linking_period_days and
                   ssp_ssp_pkg.absence_is_a_PIW (p_person_id => p_person_id,
                                                 p_sickness_start_date   => next.sickness_start_date,
                                                 p_sickness_end_date     => next.sickness_end_date,
                                                 p_absence_attendance_id => next.absence_attendance_id)then
                   --
                   -- Increment the end date to that of the next sickness period
                   --
                   if check_linked_absence(next.absence_attendance_id,
                                           l_s_date, l_e_date) then
                      PIW_end := l_e_date;
                      exit;
                   end if;
                   PIW_end := next.sickness_end_date;
                end if;
            end loop;
         end if;
     end if;
     --
     return PIW_end;
     --
end linked_PIW_end_date;
--------------------------------------------------------------------------------
function qualifying_days_in_period
--
-- Returns the number of SSP qualifying days in a specified period.
--
(
p_period_from        in date,
p_period_to          in date,
p_person_id          in number,
p_business_group_id  in number,
p_processing_level   in number default 0
)
return integer is
--
l_person_purpose_usage_id	number := NULL;
l_bg_purpose_usage_id           number := NULL;
l_purpose_usage_id   		number;
l_qualifying_days       	integer := 0;
l_person_primary_key_value	number := NULL;
l_bg_primary_key_value          number := NULL;
l_primary_key_value		number;
l_dummy_start_date		date;
l_dummy_end_date		date;
l_proc			varchar2 (72) := g_package||'qualifying_days_in_period';
l_first_absence                 boolean;
l_save_end_date                 date;
--
no_SSP_pattern		exception;
invalid_SSP_pattern	exception;
--
cursor csr_qualifying_pattern is
	--
-- 563202 - by concatanating null to purpose_usage_id in the where clause the
-- use of a better index is forced.
	-- Returns those patterns that exist at some stage within the absence
	-- It will be person or BG pattern depending on the variables passed in
        --
	select  start_date
        ,       end_date
	from	hr_calendar_usages
	where	purpose_usage_id||null = l_purpose_usage_id
	and     primary_key_value = l_primary_key_value
        and     end_date >= p_period_from
        and     start_date <= p_period_to;
	--
  --6658285 begin
  Type csr_qua_pattern is record( start_date date,end_date date);
  Type csr_qua_pat_tab is table of csr_qua_pattern index by binary_integer;
  csr_qualifying_pattern_PLtable csr_qua_pat_tab;
  cont number:=0;
  --6658285 end
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_period_from is not null
					and p_period_to is not null
					and p_period_from <= p_period_to
					and p_period_from = trunc(p_period_from)
					and p_period_to = trunc (p_period_to)
					and p_person_id is not null
					and p_business_group_id is not null);
	--
	begin
	--
	hr_utility.trace('    p_period_from: '||to_char(p_period_from));
	hr_utility.trace('    p_period_to: '||to_char(p_period_to));
	hr_utility.trace('    p_person_id: '||to_char(p_person_id));
	hr_utility.trace('    p_business_group_id: '||to_char(p_business_group_id));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
-- Look for a personal SSP qualifying pattern.
--
l_primary_key_value := p_person_id;
l_person_primary_key_value := l_primary_key_value;
l_purpose_usage_id := hr_calendar_pkg.purpose_usage_id ('PERSON',
                                                        'QUALIFYING PATTERN');
l_person_purpose_usage_id := l_purpose_usage_id;
--
l_first_absence := TRUE;
--
--6658285 begin
for I in csr_qualifying_pattern loop
cont := cont+1;
csr_qualifying_pattern_PLtable(cont).start_date := I.start_date;
csr_qualifying_pattern_PLtable(cont).end_date := I.end_date;
end loop;
--for pattern in csr_qualifying_pattern loop
for pattern in 1..csr_qualifying_pattern_PLtable.count loop
--6658285 end
   if l_first_absence
   then
   /*6658285 Begin
      if pattern.start_date > p_period_from
      then
      close csr_qualifying_pattern; */
    if csr_qualifying_pattern_PLtable(pattern).start_date > p_period_from
      then
   --6658285 end
         l_primary_key_value := p_business_group_id;
         l_bg_primary_key_value := l_primary_key_value;
         l_purpose_usage_id := hr_calendar_pkg.purpose_usage_id(
                                                          'ORGANIZATION',
                                                          'QUALIFYING PATTERN');
         l_bg_purpose_usage_id := l_purpose_usage_id;
         --
         open csr_qualifying_pattern;
         fetch csr_qualifying_pattern into l_dummy_start_date, l_dummy_end_date;
         --
         if csr_qualifying_pattern%notfound
         then
         -- there was no qualifying pattern for the bg
            raise no_SSP_pattern;
         end if;
         --
         close csr_qualifying_pattern;
         --
      /*6658285 Begin
      elsif pattern.end_date < p_period_to
      then
         l_save_end_date := pattern.end_date;*/
      elsif csr_qualifying_pattern_PLtable(pattern).end_date < p_period_to
      then
	 l_save_end_date := csr_qualifying_pattern_PLtable(pattern).end_date;
       --6658285 end
         l_first_absence := FALSE;
      end if;
   else  -- not l_first_absence
      /*6658285 Begin
      if pattern.start_date > l_save_end_date + 1
      then
         close csr_qualifying_pattern;
	 */
       if csr_qualifying_pattern_PLtable(pattern).start_date > l_save_end_date + 1
       then
       --6658285 end
         l_primary_key_value := p_business_group_id;
         l_bg_primary_key_value := l_primary_key_value;
         l_purpose_usage_id :=hr_calendar_pkg.purpose_usage_id(
                                         'ORGANIZATION',
                                         'QUALIFYING PATTERN');
         l_bg_purpose_usage_id := l_purpose_usage_id;
         --
         open csr_qualifying_pattern;
         fetch csr_qualifying_pattern into l_dummy_start_date, l_dummy_end_date;
         if csr_qualifying_pattern%notfound
         then
         -- there was no qualifying pattern for the bg
            raise no_SSP_pattern;
         end if;
         close csr_qualifying_pattern;
         --
       /*6658285 Begin
      elsif pattern.end_date < p_period_to
      then
         l_save_end_date := pattern.end_date;  */
      elsif csr_qualifying_pattern_PLtable(pattern).end_date < p_period_to
      then
      l_save_end_date := csr_qualifying_pattern_PLtable(pattern).end_date;
      --6658285 end
      end if;
      --
      l_first_absence := FALSE;
   end if;
   --
   l_first_absence := FALSE;
--
/*6658285 Begin	 commenting the fix done for bug 550269
-- Fix for Bug 550269
   if not(csr_qualifying_pattern%ISOPEN)
   then
      open csr_qualifying_pattern;
   end if;
--
6658285 end*/
end loop;
--
if l_first_absence
then
   l_person_primary_key_value := null;
   l_person_purpose_usage_id := null;
   l_primary_key_value:= p_business_group_id;
   l_bg_primary_key_value := l_primary_key_value;
   l_purpose_usage_id := hr_calendar_pkg.purpose_usage_id(
                                       'ORGANIZATION',
                                       'QUALIFYING PATTERN');
   l_bg_purpose_usage_id := l_purpose_usage_id;
  --
   open csr_qualifying_pattern;
   fetch csr_qualifying_pattern into l_dummy_start_date, l_dummy_end_date;
   --
   if csr_qualifying_pattern%notfound
   then
      raise no_SSP_pattern;
   end if;
   close csr_qualifying_pattern;
end if;
--
-- Having found the purpose usage, determine the number of qualifying days
-- in the period according to the appropriate calendar
--
hr_utility.trace('PERSON PATTERN USAGE ID: '||l_person_purpose_usage_id);
hr_utility.trace('PERSON PRIMARY KEY VAL:  '||l_person_primary_key_value);
hr_utility.trace('BG PATTERN USAGE ID:     '||l_bg_purpose_usage_id);
hr_utility.trace('BG PRIMARY KEY VALUE:    '||l_bg_primary_key_value);
hr_utility.trace('PERIOD FROM/TO:          '||p_period_from||' -> '||p_period_to);
--
-- call new overloaded version of hr_calendar_pkg.total_availability
--
l_qualifying_days := hr_calendar_pkg.total_availability (
      p_availability               => 'QUALIFYING',
      p_person_purpose_usage_id    => l_person_purpose_usage_id,
      p_person_primary_key_value   => l_person_primary_key_value,
      p_bg_purpose_usage_id        => l_bg_purpose_usage_id,
      p_bg_primary_key_value       => l_bg_primary_key_value,
      p_period_from                => p_period_from,
      p_period_to                  => p_period_to + 1,
      p_processing_level           => p_processing_level);
--
hr_utility.set_location('Leaving :'||l_proc||
                        '.  Qual days: '||to_char(l_qualifying_days),100);
--
return l_qualifying_days;
--
exception
--
when no_SSP_pattern then
   hr_utility.set_location('Leaving :'||l_proc||', Error',999);
   fnd_message.set_name ('SSP','SSP_35048_NO_SSP_QUAL_PATTERN');
   fnd_message.raise_error;
--
end qualifying_days_in_period;
--
--------------------------------------------------------------------------------
function SSP_is_installed return boolean is
--
-- Checks that SSP is installed before SSP functionality is performed.
-- This code was copied and modified from hrapiapi.pkb
--
l_pa_installed		fnd_product_installations.status%TYPE;
l_industry		fnd_product_installations.industry%TYPE;
l_pa_appid		fnd_product_installations.application_id%TYPE;
--
l_SSP_installed	boolean := FALSE;
l_proc		varchar2 (72) := g_package||'SSP_is_installed';
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
if g_SSP_is_installed is null
then
   -- We need to determine if SSP is installed.
   --
   begin

   select application_id
   into l_pa_appid
   from fnd_application
   where upper(application_short_name) = upper('SSP');

   if (fnd_installation.get(appl_id     => l_pa_appid,
                            dep_appl_id => l_pa_appid,
                            status      => l_pa_installed,
                            industry    => l_industry))
   then
      --
      -- Check to see if status = 'I'
      --
      if (l_pa_installed = 'I') then
         l_SSP_installed := TRUE;
      else
         l_SSP_installed := FALSE;
      end if;
   else
      l_SSP_installed := FALSE;

   end if;
   --
   g_SSP_is_installed := l_SSP_installed;

   exception

   when too_many_rows then
   hr_utility.trace('Error: more than 1 row on FND_APPLICATION table for SSP');

   when others then
   raise;

   end;

end if;
--
if g_SSP_is_installed
then
   hr_utility.trace('SSP is installed');
else
   hr_utility.trace('SSP is NOT installed');
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
return g_SSP_is_installed;
--
end SSP_is_installed;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ENTITLED_TO_SSP(p_absence per_absence_attendances%rowtype)
--
-- See header for description of this function.
--
return boolean is
     --
     l_proc varchar2(72)    := g_package||'entitled_to_ssp';
     last_entitled_day date := hr_general.end_of_time;
     max_PIW_end_date  date := null;
     l_01_October_06 date := to_date('01/10/2006','DD/MM/YYYY');
     --
     no_prima_facia_entitlement exception;
     employee_too_old exception;
     earnings_too_low exception;
     /*BUG 2984577 Added exception*/
     evidence_not_available exception;

--Bug Fix 8356706 Begin
l_saturday  varchar2(100) := rtrim(to_char(to_date('06/01/2001','DD/MM/YYYY'),'DAY'));
l_sunday    varchar2(100) := rtrim(to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY'));
--Bug Fix 8356706 End

     -- System-created stoppages for the PIW which have not been overridden
     cursor csr_old_stoppages is
     select stp.*
     from   ssp_stoppages STP
     where  stp.absence_attendance_id = g_PIW_id
     and    ((stp.override_stoppage <> 'Y' and stp.user_entered <> 'Y')
            or
            (stp.withhold_from > PIW_end_date));
     --
     /*--------------------------------------*/
     /* Create a stoppage of payment for SSP */
     /*--------------------------------------*/
     procedure create_stoppage(p_withhold_from in date,
                              p_withhold_to   in date default null,
                              p_reason        in varchar2,
                              p_overridden    out nocopy boolean) is
          l_dummy     number;
          l_reason_id	number;
          l_proc      varchar2 (72) := g_package||'create_stoppage';

          procedure check_parameters is
               all_parameters_valid constant boolean :=
                             (p_withhold_from is not null
                              and p_withhold_from = trunc (p_withhold_from)
                              and p_withhold_to = trunc (p_withhold_to)
                              and p_withhold_from <= p_withhold_to
                              and p_reason is not null);
          begin
               hr_utility.trace('    p_reason: ' || p_reason);
               hr_utility.trace('    withhold_from/to: ' ||
               to_char(p_withhold_from)||', '||to_char(p_withhold_to));
               hr_general.assert_condition (all_parameters_valid);
          end check_parameters;
          --
	 begin
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          check_parameters;
          --
          l_reason_id := ssp_smp_support_pkg.withholding_reason_id(
                         g_SSP_legislation.element_type_id,p_reason);
          --
          if not ssp_smp_support_pkg.stoppage_overridden(p_absence_attendance_id => g_PIW_id,
                                                         p_reason_id => l_reason_id) then
             -- the withholding reason is not overridden for this PIW
	         --
	         -- Create a stoppage for the PIW
	         --
             ssp_stp_ins.ins (p_withhold_from         => p_withhold_from,
                              p_withhold_to           => p_withhold_to,
                              p_stoppage_id            => l_dummy,
                              p_object_version_number => l_dummy,
                              p_absence_attendance_id => g_PIW_id,
                              p_user_entered          => 'N',
                              p_reason_id             => l_reason_id);
             --
             p_overridden := FALSE;
          else
             --
             -- Inform the calling procedure that the stoppage could not be
             -- created because it has been overridden by the user.
             --
             p_overridden := TRUE;
          end if;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end create_stoppage;
	 --

     /*---------------------------------------------------*/
     /* Check that the absentee is not too old to qualify */
     /* for SSP. The date on which age is measured is     */
     /* the start of the linked PIW.                      */
     /*---------------------------------------------------*/
     procedure check_age is
          l_proc varchar2(72) := g_package||'check_age';
          l_stoppage_overridden boolean := FALSE;
          age_at_PIW_start_date number := floor (months_between (PIW_start_date,
                                          absentee.date_of_birth) / 12);
          l_end_date date;

          cursor get_end_date is
          select nvl(sickness_end_date, l_01_October_06 - 1)
          from   per_absence_attendances
          where  ((sickness_end_date is null and sickness_start_date < l_01_October_06)
                  or
                  sickness_end_date < l_01_October_06)
          and    person_id = p_absence.person_id
          and    sickness_start_date is not null
          order by sickness_end_date DESC;
     begin
	      hr_utility.set_location('Entering:'||l_proc,1);
          --
          hr_utility.trace('Age at PIW start date: '||to_char(Age_at_PIW_start_date));
          hr_utility.trace('g_SSP_legislation.maximum_age: '||to_char(g_SSP_legislation.maximum_age));
          --
          -- Calculate the absentee's age as at the PIW start date
          --
          if age_at_PIW_start_date >= g_SSP_legislation.maximum_age then
          --
          -- Stop SSP payment because absentee is too old
          --
             open get_end_date;
             fetch get_end_date into l_end_date;
             close get_end_date;
             hr_utility.trace(l_proc||'l_end_date: '||l_end_date);
             hr_utility.trace(l_proc||'PIW_end_date: '||PIW_end_date);

             create_stoppage(p_withhold_from => PIW_start_date,
                             p_withhold_to   => least(PIW_end_date,l_end_date),
                             p_reason        => 'Employee too old',
                             p_overridden    => l_stoppage_overridden);
          --
             if not l_stoppage_overridden and PIW_end_date < l_01_October_06 then
                raise employee_too_old;
             end if;
          end if;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end check_age;
     --
     /*--------------------------------------------------*/
     /* Create a stoppage of SSP from the date following */
     /* the date of death.                               */
     /*--------------------------------------------------*/
     procedure check_death is
          l_proc varchar2(72) := g_package||'check_death';
          l_stoppage_overridden   boolean := FALSE;
     begin
          --
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          -- Bug 2984458 to display 'Employee Died' when the employee is
          -- deceased
          if absentee.actual_termination_date is not null and
             absentee.leaving_reason='D' then
             create_stoppage (p_withhold_from => absentee.actual_termination_date +1,
                              p_reason        => 'Employee died',
                              p_overridden    => l_stoppage_overridden);
          end if;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end check_death;
     --
     /*------------------------------------------------*/
     /* Return the last day before the first permanent */
     /* stoppage date to affect the PIW                */
     /*------------------------------------------------*/
     procedure get_last_entitled_day is
          l_proc varchar2 (72) := g_package||'get_last_entitled_day';
          --
          -- Get the first permanent stoppage date to affect the
          -- PIW. Return the day before the stoppage is
          -- effective because that is the last day of payment.
          --
          cursor csr_last_entitled_day is
          select nvl (min (withhold_from),hr_general.end_of_time) -1
          from   ssp_stoppages
          where  absence_attendance_id = g_PIW_id
          and    override_stoppage <> 'Y'
          and    withhold_to is null;
          --
     begin
          --
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          open csr_last_entitled_day;
          fetch csr_last_entitled_day into last_entitled_day;
          close csr_last_entitled_day;
          --
          -- The SSP stops with either the first stoppage, or the end of
          -- the employment, whichever is sooner.
          --
          last_entitled_day := least (last_entitled_day,max_PIW_end_date -1,
                                      absentee.actual_termination_date);
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end get_last_entitled_day;
     --
     /*----------------------------------------------------------------*/
     /* Check that the number of waiting days specified by legislation */
     /* have been served within the PIW. Also check that the number of */
     /* weeks of SSP paid is within the legislative limit and that the */
     /* PIW is within its legislative maximum length.                  */
     /*----------------------------------------------------------------*/
     procedure do_PIW_calculations is
          l_proc  varchar2(72) := g_package||'do_PIW_calculations';
          l_pregnancy_related_illness varchar2(30);
          weeks_remaining            number := g_SSP_legislation.maximum_SSP_period;
          waiting_days_left          number := g_SSP_legislation.waiting_days;
          start_disqualifying_period date;
          end_disqualifying_period   date;
          start_pregnancy_illness    date;
          end_pregnancy_illness      date;
          first_sunday_of_sickness   date;
          cal_start_date             date;
          cal_end_date               date;
          rate_start_date            date;
          rate_end_date              date;
          l_max_absence_start_date   date;
          l_max_absence_end_date     date;
          l_sickness_start_date      date;
          l_sickness_end_date        date;
          l_min_withheld_from        date;
          l_max_withheld_to          date;
          l_PIW_end_date             date := null;
          stoppage_date	             date := hr_general.end_of_time;
          min_cal_start_date         date := hr_general.end_of_time;
          max_cal_end_date           date := hr_general.start_of_time;
          l_nos_absences             number;
          l_business_group_id        number;
          l_absence_attendance_id    number;
          l_nos_stoppages            number;
          SSP_rate_figure            number;
          l_age                      number;
          waiting_days_this_period   number := 0;
          total_SSP_weeks            number := 0;
          days_remaining             number := weeks_remaining * 7;
          daily_rate                 number(9,4) := null;
          N                          integer := 0;
          maximum_SSP_paid           exception;
          PIW_max_length_reached     exception;
          stoppage_invoked           exception;
          l_stoppage_overridden      boolean := FALSE;
          l_SMP_element              ssp_SMP_pkg.csr_SMP_element_details%rowtype;
          --
          type stoppage_table_type is record (t_withheld_from date_table,
                                              t_withheld_to   date_table);
          --
          stoppage_table             stoppage_table_type;
          empty_stoppage_table       stoppage_table_type;
          --
          type absence_table_type is record (
             t_sickness_start_date         date_table,
             t_sickness_end_date           date_table,
             t_business_group_id           number_table,
             t_absence_attendance_id       number_table,
             t_pregnancy_related_illness   varchar_table,
             t_linked_absence_id           number_table);
          --
          absence_table absence_table_type;
          empty_absence_table absence_table_type;
          --
          -- Return rows if the period in question is covered by stoppages
          cursor csr_stoppages(p_effective_start_date in date,
                               p_effective_end_date in date) is
          select withhold_from, withhold_to
          from   ssp_stoppages
          where  absence_attendance_id = g_PIW_id
          and 	 override_stoppage = 'N'
          and    withhold_to is not null
          and    ((p_effective_start_date <= withhold_from and
                   p_effective_end_date >= nvl(withhold_to,hr_general.end_of_time)
                  )
                 or
                  (p_effective_end_date >= withhold_from and
                   p_effective_start_date <= nvl(withhold_to,hr_general.end_of_time)
                 ))
          union all
          select withhold_from, withhold_to
          from  ssp_stoppages ss,
                per_absence_attendances paa
          where paa.linked_absence_id = g_PIW_id
          and   paa.absence_attendance_id = ss.absence_attendance_id
          and   override_stoppage = 'N'
          and   withhold_to is not null
          and   ((p_effective_start_date <= withhold_from and
                  p_effective_end_date >= nvl(withhold_to,hr_general.end_of_time)
                 )
                 or
                 (p_effective_end_date >= withhold_from and
                  p_effective_start_date <= nvl(withhold_to,hr_general.end_of_time)
                 ));
          --
          function SSP_rate (p_effective_date date) return number is
               --
               -- Get the SSP rate as at a given effective date.
               cursor csr_rate is
               select piv.default_value,
                      piv.effective_start_date,
                      piv.effective_end_date
               from   pay_input_values_f  PIV,
                      pay_element_types_f ELT
               where  elt.element_type_id = piv.element_type_id
               and    elt.element_type_id = g_SSP_legislation.element_type_id
               and    p_effective_date between piv.effective_start_date and piv.effective_end_date
               and    p_effective_date between elt.effective_start_date	and elt.effective_end_date
               and    piv.input_value_id = g_SSP_legislation.rate_id;
               --
               l_proc varchar2 (72) := g_package||'SSP_rate';
               l_rate number;

               cannot_get_SSP_rate exception;
               --
               procedure check_parameters is
                    all_parameters_valid constant boolean
                                  :=(p_effective_date is not null and
                                     p_effective_date = trunc (p_effective_date));
               begin
                    hr_utility.trace (l_proc||'  p_effective_date = '||to_char (p_effective_date));
                    --
                    hr_general.assert_condition (all_parameters_valid);
                    --
               end check_parameters;
               --
          begin
               hr_utility.set_location('Entering:'||l_proc,1);
               check_parameters;
               if rate_start_date is null or
                  p_effective_date NOT between rate_start_date and rate_end_date then
                  --
                  -- The rate already retrieved is not the one we want so
                  -- get the right one from the database.
                  --
                  open csr_rate;
                  fetch csr_rate into SSP_rate_figure,
                                      rate_start_date, rate_end_date;
                  close csr_rate;
               end if;
               --
               l_rate := SSP_rate_figure;
               --
               if l_rate is null then
                  raise cannot_get_SSP_rate;
               end if;
               --
               hr_utility.set_location('Leaving :'||l_proc,100);
               --
               return l_rate;
               --
          exception
               when cannot_get_SSP_rate then
                   hr_utility.set_location('Leaving :'||l_proc||', Error',999);
                   fnd_message.set_name ('SSP','SSP_35079_NO_SSP_RATE');
                   fnd_message.set_token ('EFFECTIVE_DATE',p_effective_date);
                   fnd_message.raise_error;
          end SSP_rate;
          --
          /*--------------------------------------------------------------*/
          /* Calculate number of temporary stoppage days within a period. */
          /*--------------------------------------------------------------*/
          function stopped_days(p_start_date in date,
                                p_end_date   in date,
                                p_PIW_id     in number) return number is
               l_proc varchar2 (72) := g_package||'stopped_days';
               l_stopped_days_in_period number := 0;
               l_this_day		 date := p_start_date;
               l_stoppage_overridden	 boolean := FALSE;
               l_stoppage_found         boolean;
               --
               procedure check_parameters is
                    all_parameters_valid constant boolean :=
                           (p_start_date is not null and
                            p_end_date is not null and
                            p_PIW_id is not null and
                            p_start_date = trunc(p_start_date) and
                            p_end_date = trunc(p_end_date) and
                            p_start_date <= p_end_date);
               begin
                    hr_utility.trace ('    p_start_date = '||to_char (p_start_date));
                    hr_utility.trace ('    p_end_date = '||to_char (p_end_date));
                    hr_utility.trace ('    p_PIW_id = '||to_char (p_PIW_id));
                    hr_general.assert_condition (all_parameters_valid);
               end check_parameters;
          begin
               hr_utility.set_location('Entering:'||l_proc,1);
               --
               check_parameters;
               --
               -- moved inside loop for bug 886707
               -- l_stoppage_found := FALSE;
               --
               -- Cycle through the days of the period passed in, checking
               -- each day for a temporary stoppage covering a qualifying day.
               --
               while l_this_day <= p_end_date loop
                   -- 886707: Added initialisation of l_stoppage_found here so
                   -- so that it is reset at every loop.
                   l_stoppage_found := FALSE;
                   --
                   if 1 = qualifying_days_in_period(l_this_day, l_this_day,
                                                    p_absence.person_id,
                                                    p_absence.business_group_id,
                                                    p_processing_level => 3)then
                      --
                      -- The current day is a qualifying day, so
                      -- check for a stoppage covering this day.
                      --
                      for each_stoppage in 1..l_nos_stoppages loop
                          if l_this_day
                             between stoppage_table.t_withheld_from(each_stoppage)
                                 and stoppage_table.t_withheld_to(each_stoppage) then
                             l_stoppage_found := TRUE;
                             l_stopped_days_in_period :=l_stopped_days_in_period + 1;
                          end if;
                      end loop;
                      --
                      if not l_stoppage_found and waiting_days_left > 0 then
                         --
                         -- This day is not covered by a stoppage and there are
                         -- waiting days to create.
                         --
                         create_stoppage(p_withhold_from => l_this_day,
                                         p_withhold_to => l_this_day,
                                         p_reason => 'Waiting day',
                                         p_overridden => l_stoppage_overridden);
                         --
                         if not l_stoppage_overridden then
                            -- the waiting day stoppage is not user-overridden
                            --
                            waiting_days_left := waiting_days_left - 1;
                            waiting_days_this_period :=waiting_days_this_period+1;
                         else
                            waiting_days_left := 0;
                         end if;
		              end if;
                   end if;
                   --
                   l_this_day := l_this_day + 1;
               end loop;
               --
               hr_utility.trace('Stopped Days in Period:'||
                                 to_char(l_stopped_days_in_period));
               hr_utility.set_location('Leaving :'||l_proc,100);
               --
               return l_stopped_days_in_period;
               --
          end stopped_days;
          --
          procedure check_disqualifying_period(p_sickness_start_date date,
                                               p_sickness_end_date   date,
                                               p_pregnancy_related_illness varchar2) is
               -- Select the maternity records for the person.
               --
               cursor maternity_details is
               select maternity_id,
                      object_version_number,
                      MPP_start_date,
                      due_date, -- Need due_date to decide on value of sickness_trigger_weeks
                      ssp_smp_pkg.expected_week_of_confinement(due_date) EWC
               from   ssp_maternities
               where  person_id = p_absence.person_id
               and    nvl(leave_type,'MA') = 'MA';

               l_proc varchar2 (72) := g_package||'check_disqualifying_period';
               l_stoppage_overridden	boolean := FALSE;
               sickness_trigger_weeks		integer;
               --
               procedure check_parameters is
                    all_parameters_valid constant boolean :=
                        (p_sickness_start_date is not null and
                         p_sickness_start_date <= p_sickness_end_date and
                         p_sickness_start_date = trunc(p_sickness_start_date) and
                         p_sickness_end_date = trunc(p_sickness_end_date) and
                         p_pregnancy_related_illness is not null and
                         p_pregnancy_related_illness in ('Y','N'));
               begin
                    hr_utility.trace(l_proc||'    p_sickness_start_date = '
                                           ||to_char (p_sickness_start_date));
                    hr_utility.trace(l_proc||'    p_sickness_end_date = '
                                           ||to_char (p_sickness_end_date));
                    hr_utility.trace(l_proc||'    p_pregnancy_related_illness = '
                                           ||p_pregnancy_related_illness);
                    hr_general.assert_condition (all_parameters_valid);
			   end check_parameters;
          begin
               hr_utility.set_location('Entering:'||l_proc,1);
               --
               check_parameters;
               --
               for maternity in maternity_details loop
                   if maternity.due_date >=
                      fnd_date.canonical_to_date('2003/04/06 00:00:00') then
                      sickness_trigger_weeks := 28;
                   else
                      sickness_trigger_weeks := 42;
                   end if;
                   --
                   -- the illness is pregnancy-related
                   -- and the sickness ends sickness trigger weeks
                   -- (six weeks before 06-APR-2003, four weeks after)
                   -- before the EWC or later
                   -- and the sickness starts before the EWC
                   if p_pregnancy_related_illness = 'Y' and
                      (maternity.EWC - sickness_trigger_weeks) <= p_sickness_end_date and
                      maternity.EWC  >= p_sickness_start_date then
                      --
                      hr_utility.trace(l_proc||'Condition 1 true');
                      --
                      -- the illness starts before sickness trigger weeks
                      -- (6 weeks before 06-APR-2003, four weeks after)
                      -- prior to the EWC
                      if (maternity.EWC - sickness_trigger_weeks) >=
                          p_sickness_start_date then
                         --
                         hr_utility.trace(l_proc||'Condition 2 true');
                         --
                         -- there is no recored start_date OR
                         -- the start date is later than
                         -- the fourth or sixth week prior to the EWC
                         -- depending on whether the due date of the
                         -- maternity is on or after 06-APR-2003
                         if maternity.MPP_start_date is null or
                            maternity.MPP_start_date >
                            (maternity.EWC - sickness_trigger_weeks) then
                            --
                            -- force the MPP to start on the Sunday of the
                            -- sixth week prior to the EWC
                            if maternity.due_date <
                               fnd_date.canonical_to_date('2003/04/06 00:00:00') then
                               --
                               hr_utility.trace(l_proc||'Condition 3 true');
                               --
                               if rtrim (to_char (maternity.EWC, 'DAY')) = l_sunday then
                                  hr_utility.trace(l_proc||'Condition 4 true');
                                  maternity.MPP_start_date:=
                                    (maternity.EWC - sickness_trigger_weeks);
                               else
                                  --
                                  hr_utility.trace(l_proc||'Condition 4 untrue');
                                  --
                                  maternity.MPP_start_date :=
                                  next_day((maternity.EWC - sickness_trigger_weeks), l_sunday);
                               end if;
                               --
                            else
                               --
                               -- Maternity due date is on or after 06-APR-2003,
                               -- therefore start MPP on the date 4 weeks before
                               -- EWC regardless of whether it is a Sunday
                               --
                               -- Bug No. 2620894: Changed the code so that MPP start date
                               -- is the next day after first working day
                               -- of (EWC - sickness_trigger_weeks) week.
                               if rtrim(to_char((maternity.EWC - sickness_trigger_weeks),'DAY')) = l_sunday then
                                  maternity.MPP_start_date := (maternity.EWC - sickness_trigger_weeks) + 2;
                               elsif rtrim(to_char ((maternity.EWC - sickness_trigger_weeks),'DAY')) = l_saturday
                               then
                                   maternity.MPP_start_date := (maternity.EWC - sickness_trigger_weeks) + 3;
                               else
                                   maternity.MPP_start_date := (maternity.EWC - sickness_trigger_weeks) + 1;
                               end if;
                            end if;
                            --
                            hr_utility.trace(l_proc||'About to update MPP Start Date');
                            ssp_mat_upd.upd(p_maternity_id => maternity.maternity_id,
                                            p_MPP_start_date => maternity.MPP_start_date,
                                            p_object_version_number => maternity.object_version_number);
                            hr_utility.trace(l_proc||'Back from updating MPP Start Date');
                         end if;
                      else
                         if maternity.due_date < fnd_date.canonical_to_date('2003/04/06 00:00:00') then
                            --
                            -- Start the MPP on the first Sunday of the sickness
                            -- as due date before 06-APR-2003
                            --
                            hr_utility.trace(l_proc||'Condition 2 untrue');
                            if rtrim(to_char (p_sickness_start_date,'DAY')) = l_sunday then
                               hr_utility.trace(l_proc||'Condition 5 true');
                               first_sunday_of_sickness := p_sickness_start_date;
                            else
                               hr_utility.trace(l_proc||'Condition 5 untrue');
                               first_sunday_of_sickness := next_day(p_sickness_start_date,l_sunday);
                            end if;
                            --
                            -- there is no recorded MPP start date or
                            -- the MPP start date is later than the first Sunday
                            if (maternity.MPP_start_date is null or
                                maternity.MPP_start_date > first_sunday_of_sickness) then
                                --
                                hr_utility.trace(l_proc||'Condition 6 true');
                                --
                                -- Update the recorded MPP start date.
                                --
                                maternity.MPP_start_date := first_sunday_of_sickness;
                                --
                                hr_utility.trace(l_proc||'About to update MPP Start Date');
                                ssp_mat_upd.upd (p_maternity_id => maternity.maternity_id,
                                                 p_MPP_start_date => maternity.MPP_start_date,
                                                 p_object_version_number=> maternity.object_version_number);
                                hr_utility.trace(l_proc||'Back from updating MPP Start Date');
                            end if;
                         else
                            --
                            -- Due date after 06-APR-2003, therefore MPP starts
                            -- on sickness start date, regardless of whether
                            -- it is a Sunday
                            --
                            -- there is no recorded MPP start date
                            -- or the MPP_start_date is later than the
                            -- sickness start date
                            if (maternity.MPP_start_date is null or
                                maternity.MPP_start_date > p_sickness_start_date) then
                               --
                               -- Bug No. 2620894: Changed the code so that MPP start date
                               -- is the next day after first working day of p_sickness_start_date.
                               if rtrim(to_char (p_sickness_start_date,'DAY')) = l_sunday then
                                  maternity.MPP_start_date := p_sickness_start_date + 2;
                               elsif rtrim(to_char (p_sickness_start_date,'DAY')) = l_saturday then
                                  maternity.MPP_start_date := p_sickness_start_date + 3;
                               else
                                  maternity.MPP_start_date:= p_sickness_start_date + 1;
                               end if;
                               --
                               hr_utility.trace(l_proc||'About to update MPP Start Date');
                               ssp_mat_upd.upd (p_maternity_id => maternity.maternity_id,
                                                p_MPP_start_date => maternity.MPP_start_date,
                                                p_object_version_number => maternity.object_version_number);
                               hr_utility.trace(l_proc||'Back from updating MPP Start Date');
                            end if;
                         end if;
                      end if;
                   end if;
                   --
                   start_disqualifying_period := maternity.MPP_start_date;
                   --
                   if start_disqualifying_period is not null then
                      hr_utility.trace(l_proc||'Condition 7 true');
                      begin
                           --
                           -- The disqualifying period lasts for the period of time
                           -- allowed by legislation for the Maternity Pay Period
                           -- (the figure is expressed in weeks so must be converted
                           -- to days before deriving end date).
                           --
                           end_disqualifying_period := start_disqualifying_period
                                                       + (l_SMP_element.Maximum_MPP * 7) -1;
                           hr_utility.trace('start_disqualifying_period : '||
                                             fnd_date.date_to_canonical(start_disqualifying_period));
                           hr_utility.trace('end_disqualifying_period : '||
                                             fnd_date.date_to_canonical(end_disqualifying_period));
                           --
                      exception
                           when attempt_to_add_to_end_of_time then
                              --
                              -- Handle the case where the end date would exceed the
                              -- maximum date that Oracle can deal with.
                              --
                              end_disqualifying_period := hr_general.end_of_time;
                              --
                      end;
                      --
                      -- the previously calculated last entitlement day is
                      -- not already the day before the start of the
                      -- disqualifying period (because we have already been
                      -- round this loop and created a stoppage before)
                      -- and the disqualifying period overlaps with the PIW
                      if (last_entitled_day <> start_disqualifying_period - 1 and
                          start_disqualifying_period <= PIW_end_date and
                          end_disqualifying_period >= PIW_start_date) then
                          create_stoppage(p_withhold_from => start_disqualifying_period,
                                          p_reason        => 'Woman in disqualifying period',
                                          p_overridden	=> l_stoppage_overridden);
                          --
                          -- the previously calculated last entitlement day is
                          -- later than the day before the start of the
                          -- disqualifying period
                          -- and the withholding reason is not overridden
                          if (last_entitled_day > start_disqualifying_period -1 and
                              not l_stoppage_overridden) then
                              last_entitled_day := start_disqualifying_period -1;
                          end if;
                      end if;
                   end if;
               end loop;
               --
               hr_utility.set_location('Leaving :'||l_proc,100);
               --
          end check_disqualifying_period;
          --
          procedure check_SSP1L is
               l_proc varchar2 (72) := g_package||'check_SSP1L';
          begin
               --
               hr_utility.set_location('Entering:'||l_proc,1);
               --
               -- take prior employment SSP into account in total liability.
               if (PIW_start_date - absentee.prior_employment_SSP_paid_to)
		           <= g_SSP_legislation.linking_period_days then
		           --
                   hr_utility.trace('There is prior employment SSP');
                   --
                   total_SSP_weeks := absentee.prior_employment_SSP_weeks;
               end if;
               --
               hr_utility.set_location('Leaving :'||l_proc,100);
               --
          end check_SSP1L;
          --
          function check_emp_too_old(p_start date,
                                     p_end   date) return boolean is
               l_temp  number;
               l_found boolean;

               cursor csr_old_stp is
               select 1
               from   ssp_stoppages stp,
                      ssp_withholding_reasons rea
               where  stp.absence_attendance_id = g_PIW_id
               and    stp.withhold_from <= p_start
               and    stp.withhold_to >= p_end
               and    stp.reason_id = rea.reason_id
               and    rea.reason = 'Employee too old';
          begin
               l_found := false;
               if l_age >= 65 then
                  open csr_old_stp;
                  fetch csr_old_stp into l_temp;
                  if csr_old_stp%found then
                     l_found := true;
                  end if;
                  close csr_old_stp;
               end if;
               return l_found;
          end check_emp_too_old;
          --
     begin
          -- Start of do_PIW_calculations
          hr_utility.set_location ('Entering:'||l_proc,1);
          --
          open ssp_SMP_pkg.csr_SMP_element_details(p_effective_date => PIW_start_date);
          fetch ssp_SMP_pkg.csr_SMP_element_details into l_SMP_element;
          close ssp_SMP_pkg.csr_SMP_element_details;
          --
          start_disqualifying_period := null;
          end_disqualifying_period := null;
          --
          check_SSP1L;
          --
          l_age := get_age_at_PIW(p_absence.person_id,l_01_October_06);
          --
          SSP_rate_figure := SSP_rate (PIW_start_date);
          --
          l_nos_absences := 0;
          absence_table := empty_absence_table;
          l_max_absence_end_date := hr_general.start_of_time;
          --
          for each_abs_tab in PIW loop
              l_max_absence_start_date := each_abs_tab.sickness_start_date;
              l_max_absence_end_date := each_abs_tab.sickness_end_date;
              l_nos_absences := l_nos_absences + 1;
              --
              hr_utility.trace('PIWl: dates: ' || to_char(l_max_absence_start_date)
                               || ' -> ' || to_char(l_max_absence_end_date));
              --
              absence_table.t_sickness_start_date(l_nos_absences) :=
                            each_abs_tab.sickness_start_date;
              absence_table.t_sickness_end_date(l_nos_absences) :=
                            each_abs_tab.sickness_end_date;
              absence_table.t_business_group_id(l_nos_absences) :=
                            each_abs_tab.business_group_id;
              absence_table.t_absence_attendance_id(l_nos_absences) :=
                            each_abs_tab.absence_attendance_id;
              absence_table.t_pregnancy_related_illness(l_nos_absences) :=
                            each_abs_tab.pregnancy_related_illness;
          end loop;
          --
          for each_absence in 1..l_nos_absences loop
              l_sickness_start_date       :=
                        absence_table.t_sickness_start_date(each_absence);
              l_sickness_end_date         :=
                        absence_table.t_sickness_end_date(each_absence);
              l_business_group_id         :=
                        absence_table.t_business_group_id(each_absence);
              l_absence_attendance_id     :=
                        absence_table.t_absence_attendance_id(each_absence);
              l_pregnancy_related_illness :=
                        absence_table.t_pregnancy_related_illness(each_absence);
              --
	          hr_utility.trace('In PIW Loop');
	          hr_utility.trace('    for sickness dated: ' ||
                               to_char(l_sickness_start_date) || ' -> ' ||
                               to_char(l_sickness_end_date));
              --
	          if ssp_ssp_pkg.absence_is_a_PIW (p_person_id => p_absence.person_id,
                                               p_sickness_start_date => l_sickness_start_date,
                                               p_sickness_end_date => l_sickness_end_date,
                                               p_absence_attendance_id => l_absence_attendance_id) then
                  --
                  -- Check for a disqualifying period from SSP because of maternity
                  --
                  check_disqualifying_period(p_sickness_start_date => l_sickness_start_date,
                                             p_sickness_end_date   => l_sickness_end_date,
                                             p_pregnancy_related_illness => l_pregnancy_related_illness);
                  --
                  <<THIS_WEEK>>
                  --
                  -- Calculate weekly figures for SSP, accumulating the totals as we
	              -- go so that we can find the amounts of liability both within each
	              -- week and over all.
                  --
                  declare
                  -- Bug 441738
                  -- start_date date := next_day (each_absence.sickness_start_date,
                  --                    l_sunday) - 7;
                  --
                  -- Bug 502108 - start_date/end_date initialisation moved after begin.
                  --
                       start_date              date;
                       end_date                date;
                       SSP_rate_figure         number;
                       qualifying_days         number;
                       gross_SSP_days_due      number;
                       SSP_days_due            number;
                       withheld_days           number;
                       SSP_week_fraction       number;
                  begin
                       start_date      := l_sickness_start_date;
                       SSP_rate_figure := SSP_rate(start_date);
                       --
                       -- Bug 593097 - force the end_date to be the next Saturday,
                       -- after the Sunday before the sickness_start_date, rather
                       -- than the Saturday after the sickness_start_date, which
                       -- causes an error if the sickness_start_date is itself a
                       -- Saturday.
                       end_date := least(next_day(next_day(l_sickness_start_date,l_sunday) -7, l_saturday),
                                   nvl (rate_end_date, hr_general.end_of_time),last_entitled_day);
                       --
                       if start_date > last_entitled_day then
                       -- There is a stoppage which prevents the entry creation
                       --
                          if start_date > max_PIW_end_date then
                             raise PIW_max_length_reached;
                          else
                             raise stoppage_invoked;
                          end if;
                       end if;
                       --
                       -- Bug 504386 - Call qualifying_days_in_period for the whole sickness absence,
                       -- so that the pl/sql table normal_pattern in hr_calendar_pkg only need be
                       -- populated once.
                       --
                       -- Bug 655707 - Calling qualifying_days_in_period with PIW start/end dates, thus
                       -- if there is more than absence then the calendar doesn't have to be rederived.
                       --
                       -- Bug 589806 -  If an open ended absence is entered then
                       -- each_absence.sickness_end_date is defaulted to the 'end_of_time'. Hence
                       -- performance is terrible. Now, if the is sickness_end_date is the end_of_time
                       -- then 203 days are added to the sickness_start_date. 203 days will allow the
                       -- pl/sql table normal_pattern in hr_calendar_pkg to be populated with the
                       -- dates to cover the whole open ended absence.
                       --
                       -- Bug 655707 - Changed 203 to be Max SSP period, unless this is null, so that
                       --              this is not legislation specific.
                       --
                       cal_end_date := l_max_absence_end_date;
                       --
                       if cal_end_date is null or cal_end_date = hr_general.end_of_time then
                          cal_end_date := l_max_absence_start_date +
                          ((nvl(g_SSP_legislation.MAXIMUM_SSP_PERIOD,28) + 1) * 7);
                       else
                          cal_end_date := ssp_smp_support_pkg.end_of_week(l_max_absence_end_date);
                       end if;
                       --
                       hr_utility.trace('Calendar end date: '||to_char(cal_end_date));
                       cal_start_date := ssp_smp_support_pkg.start_of_week(nvl(PIW_start_date, start_date));
                       --
                       if cal_end_date > max_cal_end_date or
                          cal_start_date < min_cal_start_date then
                          all_pat_calendar_days := qualifying_days_in_period(
                                                       cal_start_date, cal_end_date,
                                                       p_absence.person_id,
                                                       p_absence.business_group_id,
                                                       p_processing_level => 1);
                          --
                          max_cal_end_date := cal_end_date;
                          min_cal_start_date := cal_start_date;
                       end if;
                       --
                       -- Bug 655707 - build a PL/SQL table of stoppages only once for
                       --              each absence, so we don't have to keep calling
                       --              csr_stoppages cursor for every single day of each
                       --              absence. Also, if no stoppages are found for the
                       --              whole absence then we do not have to keep calling
                       --              qualifying_days_in_period so many times.
                       --
                       stoppage_table := empty_stoppage_table;
                       l_nos_stoppages := 0;
                       l_min_withheld_from := hr_general.end_of_time;
                       l_max_withheld_to := hr_general.start_of_time;
                       --
                       for each_stoppage in csr_stoppages(PIW_start_date, cal_end_date)
                       loop
                           l_nos_stoppages := l_nos_stoppages + 1;
                           stoppage_table.t_withheld_from(l_nos_stoppages):=
                                   each_stoppage.withhold_from;
                           stoppage_table.t_withheld_to(l_nos_stoppages):=
                                   each_stoppage.withhold_to;
                           --
                           if each_stoppage.withhold_from < l_min_withheld_from
                           then
                              l_min_withheld_from := each_stoppage.withhold_from;
                           end if;
                           --
                           if each_stoppage.withhold_to > l_max_withheld_to
                           then
                              l_max_withheld_to := each_stoppage.withhold_to;
                           end if;
                       end loop;
                       --
	                   hr_utility.trace('No of stoppages between ' ||
	                                    to_char(l_min_withheld_from) ||
	                                    ' and ' || to_char(l_max_withheld_to) ||
                                        ': ' || to_char(l_nos_stoppages));
                       --
                       -- Cycle through each week of the absence until the end of the
                       -- sickness.
                       --
                       -- Bug 555505 - made start_date <= rather than < each_ab.. so that
                       -- a one day absence will be accounted for.
                       --
                       -- Bug 5444012 - check for total day left
                       days_remaining := g_SSP_legislation.maximum_SSP_period * 7;
                       days_remaining := greatest(0, days_remaining - (total_SSP_weeks * 7));
                       --
                       while start_date <= l_sickness_end_date loop
                          N := N + 1;
                          --
                          -- Find number of qualifying days in the current calendar week.
                          --
	                      hr_utility.trace('Finding qualifying days in current week...');
                          qualifying_days := greatest (1,qualifying_days_in_period(
                                             ssp_smp_support_pkg.start_of_week(start_date),
                                             ssp_smp_support_pkg.end_of_week(start_date),
                                             p_absence.person_id,
                                             p_absence.business_group_id,
                                             p_processing_level => 2));
                          --
                          if weeks_remaining <= 1 then
                             --
                             -- We are in the final week of the employer's SSP liability.
                             -- We must work out how many days of liability remain.
                             --
                             days_remaining := ceil(weeks_remaining /
                                               ---------------------------------------
                                               standard_week_fraction (qualifying_days));
                             --
                             -- Now drag the end date back to the date on which
                             -- SSP ceases to be payable.
                             --
                             while qualifying_days_in_period(start_date,
                                                 end_date,
                                                 p_absence.person_id,
                                                 p_absence.business_group_id,
                                                 p_processing_level => 2) > days_remaining loop
                                   end_date := end_date -1;
                             end loop;
                             --
                          end if;
                          --
                          -- Calculate the number of qualifying days the person was sick.
                          --
                          -- Calculate the absent qualifying days.
                          --
                          -- The gross number of SSP days due is the number of qualifying
                          -- days in the period of absence being examined.
                          --
                          gross_SSP_days_due :=
                                        qualifying_days_in_period(
                                                 greatest (start_date,
                                                          l_sickness_start_date),
                                                 least (end_date,
                                                          l_sickness_end_date),
                                                 p_absence.person_id,
                                                 p_absence.business_group_id,
                                                 p_processing_level => 2);
                          --
                          -- Calculate how many of the qualifying days were covered by a
                          -- waiting day or temporary stoppage. NB withheld_days do not
                          -- include waiting days but the calculation of waiting days is
                          -- done within the stopped_days function and stored in a
                          -- variable.
                          --
                          perf_start_date := greatest(start_date, l_sickness_start_date);
                          perf_end_date := least(end_date, l_sickness_end_date);
                          waiting_days_this_period := 0;
                          --
                          if (l_nos_stoppages > 0 and
                              perf_start_date <= l_max_withheld_to and
                              perf_end_date   >= l_min_withheld_from)
                             or waiting_days_left > 0
                          then
                             withheld_days := stopped_days(perf_start_date,
                                                           perf_end_date,
                                                           p_absence.person_id);
                          else
                             withheld_days := 0;
                          end if;
                          --
                          SSP_days_due := gross_SSP_days_due - withheld_days;
                          --
                          -- Calculate the fraction of an SSP week which this week's absence
                          -- constitutes
                          --
                          if SSP_days_due >= days_remaining then
                            --
                            -- We must have done the final week calculations and found that
                            -- the absentee was sick for as long or longer than the period
                            -- for which SSP is payable. Make this week's fraction equal
                            -- the weeks remaining so that we come to exactly the correct
                            -- total_SSP_weeks figure.
                            --
                            SSP_week_fraction := g_SSP_legislation.maximum_SSP_period - total_SSP_weeks;
                          else
                            SSP_week_fraction := (SSP_days_due - waiting_days_this_period) /
                                        	     -----------------------------------------
                                                  qualifying_days;
                          end if;
                          --
                          -- Find the daily rate by dividing the weekly SSP rate by the
                          -- number of qualifying days in the calendar week.
                          --
                          daily_rate := SSP_rate (this_week.start_date)/
          		                        --------------------------------
          		                        qualifying_days;
                          --
                          -- Determine which payroll period to put the new entry in
                          --
                          -- Initialise in/out parameters to get_entry_details procedure
                          --
                          new_entry.assignment_id (N) := null;
                          new_entry.element_link_id (N) := null;
                          --
                          ssp_smp_support_pkg.get_entry_details(p_date_earned => this_week.start_date,
                                                                /*p_date_earned => this_week.end_date,*/
                                                                p_last_process_date	=> absentee.last_standard_process_date,
                                                                p_person_id		=> p_absence.person_id,
                                                                p_element_type_id	=> g_SSP_legislation.element_type_id,
                                                                p_assignment_id		=> new_entry.assignment_id (N),
                                                                p_element_link_id	=> new_entry.element_link_id (N),
                                                                p_effective_start_date	=> new_entry.effective_start_date (N),
                                                                p_effective_end_date	=> new_entry.effective_end_date (N));
                          --
                          -- Store this week's figures in the hypothetical entry
                          --
                          new_entry.date_from(N) := greatest (this_week.start_date,l_sickness_start_date);
                          new_entry.date_to(N) := least (this_week.end_date,l_sickness_end_date);
                          new_entry.qualifying_days(N) := this_week.gross_SSP_days_due;
                          new_entry.SSP_weeks(N) := round (this_week.SSP_week_fraction,3);
                          new_entry.SSP_days_due(N) := this_week.gross_SSP_days_due - waiting_days_this_period;
                          new_entry.withheld_days(N) := this_week.withheld_days;
                          new_entry.rate(N) := SSP_rate (this_week.start_date);
                          new_entry.amount(N) := round (((SSP_days_due - waiting_days_this_period)
                                                        * daily_rate)+0.004,2);
                          new_entry.dealt_with(N) := 'FALSE';
                          --
                          if check_emp_too_old(l_sickness_start_date, l_sickness_end_date) then
                             total_SSP_weeks := total_SSP_weeks + (this_week.withheld_days/qualifying_days);
                          end if;
                          --
                          -- Increment the total of SSP weeks by this week's figures.
                          --
                          total_SSP_weeks := total_SSP_weeks + SSP_week_fraction;
                          weeks_remaining := g_SSP_legislation.maximum_SSP_period - total_SSP_weeks;
                          --
                          -------------------------------------------------
                          -- Trace the calculations for debugging purposes
                          begin
                               hr_utility.trace ('----------------------------');
                               hr_utility.trace (l_proc||'Entry number ' ||to_char (N));
                               hr_utility.trace (l_proc||'	Payroll period '||to_char (new_entry.effective_start_date (N)) ||' to '
                               ||to_char (new_entry.effective_end_date (N)));
                               hr_utility.trace (l_proc||'	from = '||to_char (new_entry.date_from (N))||' to = ' ||to_char ( new_entry.date_to (N)));
                               hr_utility.trace (l_proc||'	qualifying_days = '||to_char (new_entry.qualifying_days (N)));
                               hr_utility.trace (l_proc||'	SSP_weeks = '||to_char (new_entry.SSP_weeks (N)));
                               hr_utility.trace (l_proc||'	SSP_days_due = '||to_char (new_entry.SSP_days_due (N)));
                               hr_utility.trace (l_proc||'	withheld_days = '||to_char (new_entry.withheld_days (N)));
                               hr_utility.trace (l_proc||'	rate = '||to_char (new_entry.rate (N)));
                               hr_utility.trace (l_proc||'	amount ' || to_char (daily_rate)
                                        ||' ( ' || to_char (new_entry.SSP_days_due (N))
                                        ||' - ' || to_char (new_entry.withheld_days (N))
                                        ||') = '|| to_char (new_entry.amount (N)));
                               hr_utility.trace (l_proc||'	Total SSP weeks = '||to_char (total_ssp_weeks));
                               hr_utility.trace (l_proc||'	weeks remaining = '||to_char (weeks_remaining));
                               hr_utility.trace (l_proc||' waiting_days_left = '||to_char (waiting_days_left));
                               hr_utility.trace (l_proc||'	waiting_days_this_period = '||to_char (waiting_days_this_period));
                               hr_utility.trace (l_proc||'	Element_link_id = '||to_char (new_entry.element_link_id (N)));
                               hr_utility.trace (l_proc||'	Assignment_id = '||to_char (new_entry.assignment_id (N)));
                               hr_utility.trace ('----------------------------');
                          exception
                               when not_logged_on or program_error or storage_error then
                               -- a serious error must be indicated.
                                    raise;
                               when others then
                               -- Do not let minor errors in debugging code stop the process
                                    null;
                          end;
                          hr_utility.trace ('Weeks remaining:'||to_char(weeks_remaining));
                          hr_utility.trace ('      end date :'||to_char(end_date));
                          hr_utility.trace ('  last ent day :'||to_char(last_entitled_day));
                          --
                          --if weeks_remaining <= 0 then --old line
			  if weeks_remaining <= 0.00000000000000000000000000000000000001 then    --line added for bug 6860926
                            raise maximum_SSP_paid;
                          end if;
                          --
                          if end_date = last_entitled_day  then
                             -- Stop processing SSP if we have reached the date when a
                             -- stoppage precludes any further payment.
                             --
                             -- bug 2984845 - check if entitlement has ended due to
                             -- max PIW length being reached
                             -- the original check will never work as
                             -- end_date will never equal max_piw_end_date
                             -- so check if max PIW end date between start and end
                             -- dates of current sickness
                             -- IF end_date = max_piw_end_date
                             --
                             -- Bug 2984458 Added condition to check if max_piw_end_date
                             -- is less than Actual Termination Date to raise the exception
                             if ((max_piw_end_date between l_sickness_start_date and l_sickness_end_date) and
                                (max_piw_end_date < absentee.actual_termination_date)) then
                                raise piw_max_length_reached;
                             else
                                raise stoppage_invoked;
                             end if;
                          end if;
                          --
                          -- Move on to the next week of absence.
                          --
                          if rate_end_date between start_date and end_date then
                             --
                             -- The SSP rate changes during this week so we move on to
                             -- the latter part of the week for the new rate.
                             --
                             start_date := rate_end_date + 1;
                             --
                             -- The end of the next period to be examined is the lesser of
                             -- the end of the week and the first permanent stoppage date.
                             --
                             end_date := least (ssp_smp_support_pkg.end_of_week (start_date),
          			                            last_entitled_day);
                             --
                          else
                             --
                             -- There is no rate change during the current week, but there
                             -- may be one next week so move the dates to the beginning
                             -- of next week and the greater of the rate end date and the
                             -- calendar week end date and the withholding date.
                             --
                             start_date := next_day (start_date, l_sunday);
                             end_date := least (next_day (start_date,l_saturday),
                                         nvl (rate_end_date,hr_general.end_of_time),
                                         nvl (last_entitled_day,hr_general.end_of_time));
                          end if;
                          --
                       end loop;
                  end;
	          end if;
          end loop;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
	      --
     exception
	      when stoppage_invoked then
               --
               -- Stop processing SSP as we have reached the end of the entitlement.
               --
               null;
               --
          when maximum_SSP_paid then
               create_stoppage(p_withhold_from => new_entry.date_to (N) + 1,
                               p_reason        => 'Maximum weeks SSP paid',
                               p_overridden    => l_stoppage_overridden);
               --
          when PIW_max_length_reached then
               create_stoppage(p_withhold_from => max_PIW_end_date,
               p_reason        => 'PIW lasted maximum time',
               p_overridden    => l_stoppage_overridden);
               --
          when zero_divide then
               --
               -- One of the calculations must have gone wrong
               --
               fnd_message.set_name ('PAY','HR_6153_ALL_PROCEDURE_FAIL');
               fnd_message.set_token ('PROCEDURE',l_proc);
               fnd_message.set_token ('STEP','1');
               fnd_message.raise_error;
               --
     end do_PIW_calculations;
     --
     /*-------------------------------------------------------*/
     /* Check that the person earns enough to qualify for SSP */
     /*-------------------------------------------------------*/
     procedure check_average_earnings is
          --
		  -- Get the defined average earnings
		  --
          cursor csr_average_earnings is
          select average_earnings_amount
          from  ssp_earnings_calculations
          where	person_id = p_absence.person_id
          and   effective_date = PIW_start_date;
          --
          l_proc                   varchar2(72):= g_package||'check_average_earnings';
          l_average_earnings       number := null;
          l_dummy                  number;
          l_dummy2                 number; -- nocopy fix, placeholder variable
          l_payment_periods        number := null; --DFoster 1304683
          l_absence_category       varchar2(30) := 'S'; --DFoster
          l_user_entered           varchar2(30); --DFoster 1304683
          l_reason_for_no_earnings varchar2 (80);
          l_stoppage_overridden    boolean := FALSE;
          l_01_October_06          date := to_date('01/10/2006','DD/MM/YYYY');
          l_PIW_date               date;
     begin
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          -- Look on the table for previously-calculated earnings figure
          --
          open csr_average_earnings;
          fetch csr_average_earnings into l_average_earnings;
          --
          -- No average earnings are recorded
          if csr_average_earnings%notfound then
             --
             -- Calculate and save the average earnings.
             --
             ssp_ern_ins.ins(p_earnings_calculations_id  => l_dummy,
                             p_object_version_number     => l_dummy2,
                             p_person_id                 => p_absence.person_id,
                             p_effective_date            => PIW_start_date,
                             p_average_earnings_amount   => l_average_earnings,
                             p_user_entered              => l_user_entered,     --1304683
                             p_absence_category	         => l_absence_category, --1304683
                             p_payment_periods	         => l_payment_periods); --1304683
             --
          end if;
          --
          close csr_average_earnings;
          --
          if l_average_earnings = 0 then
             --
             -- If the average earnings figure returned is zero then we must
             -- check that no error message was set. Error messages will be set
             -- for system-generated average earnings when the earnings could not
             -- be derived for some reason, but to allow this procedure to
             -- continue, no error will be raised.
             --
             l_reason_for_no_earnings :=ssp_smp_support_pkg.average_earnings_error;
             --
             if l_reason_for_no_earnings is not null then
                create_stoppage (p_withhold_from  => PIW_start_date,
                                 p_reason         => l_reason_for_no_earnings,
                                 p_overridden     => l_stoppage_overridden);
                --
                if not l_stoppage_overridden then
                   raise earnings_too_low;
                end if;
             end if;
          end if;
          --
          -- the average earnings are lower than the NI Lower Earnings Limit
          if l_average_earnings < ssp_smp_support_pkg.NI_Lower_Earnings_Limit(PIW_start_date) then
             --
             -- The person does not earn enough to qualify for SSP
             --
             create_stoppage (p_withhold_from  => PIW_start_date,
                              p_reason         => 'Earnings too low',
                              p_overridden     => l_stoppage_overridden);
             --
             if not l_stoppage_overridden then
                raise earnings_too_low;
             end if;
	      end if;
	      --
	      hr_utility.set_location('Leaving :'||l_proc,100);
	      --
     end check_average_earnings;
     --
     /*----------------------------------------*/
     /* Check for medical evidence of sickness */
     /*----------------------------------------*/
     procedure check_evidence is

          --
          -- Return a row if evidence exists.
          cursor csr_evidence (c_absence_id number) is
          select 1
          from   ssp_medicals
          where	 absence_attendance_id = c_absence_id
          and    evidence_status = 'CURRENT';
          --
          -- Returns the setting of the flag which notes the user's
          -- requirement for medical evidence
          cursor csr_user_requirement (c_business_id number) is
          select org_information1 EVIDENCE_REQUIRED
          from   hr_organization_information
          where  organization_id = c_business_id
          and    org_information_context = 'Sickness Control Rules';
          --
          l_proc varchar2(72):= g_package||'check_evidence';
          l_evidence_required varchar2 (30) := 'N';
          l_dummy integer (1);
          l_stoppage_overridden	boolean := FALSE;
          --
     begin
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          /*BUG 2984577- Added code to handle linked absences.*/
          for each_absence in PIW loop
              -- Determine whether or not the user requires medical evidence of
              -- incapacity to be presented by employees
              --
              open csr_user_requirement(each_absence.business_group_id);
              fetch csr_user_requirement into l_evidence_required;
              close csr_user_requirement;
              --
              -- the user requires medical evidence of incapacity
              if l_evidence_required = 'Y' then
                 --
                 -- Look for a sick note.
                 open csr_evidence(each_absence.absence_attendance_id);
                 fetch csr_evidence into l_dummy;
                 hr_utility.set_location('Entering:'||l_dummy,5555);
                 --
                 -- no medical evidence was found for this absence
                 if csr_evidence%notfound then
                    /*BUG 2984577 Added exception */
                    if each_absence.sickness_end_date = hr_general.end_of_time then
                       create_stoppage (p_withhold_from	=> each_absence.sickness_start_date,
                                        p_reason        => 'No acceptable evidence in time',
                                        p_overridden	=> l_stoppage_overridden);
                       last_entitled_day := least(last_entitled_day,each_absence.sickness_start_date - 1);
                    else
                       create_stoppage (p_withhold_from	=> each_absence.sickness_start_date,
                                        p_withhold_to => each_absence.sickness_end_date,
                                        p_reason => 'No acceptable evidence in time',
                       p_overridden	=> l_stoppage_overridden);
                    end if;
                    --
                 end if;
                 close csr_evidence;
              end if;
          end loop;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end check_evidence;
     --
     /*--------------------------------------------------------------*/
     /* Check that the person's period of service is long enough to  */
     /* qualify for SSP                                              */
     /*--------------------------------------------------------------*/
     procedure check_service is
          l_stoppage_overridden boolean := FALSE;
          l_proc varchar2 (72) := g_package||'check_service';
     begin
          --
          hr_utility.set_location('Entering:'||l_proc,1);
          -- the employment is scheduled to end
          -- bug 2984458 to avoid displaying 'Contract ends' when
          -- employee is deceased
          if (absentee.actual_termination_date < hr_general.end_of_time) and
              absentee.leaving_reason <>'D' then
              create_stoppage(p_withhold_from => absentee.actual_termination_date +1,
                              p_reason => 'Contract ends',
                              p_overridden => l_stoppage_overridden);
          end if;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end check_service;
     --
     /*-----------------------------------------------------------*/
     /* Check that if the person has a DSS linking letter and if  */
     /* so, is the end date after the start date of current PIW ? */
     /*-----------------------------------------------------------*/
     procedure check_linking_letter is
          l_stoppage_overridden boolean := FALSE;
          l_proc varchar2(80) := g_package||'check_linking_letter';
          --
          -- Get current linking letter end date off the person record
          cursor csr_link_letter is
          select fnd_date.canonical_to_date(ppf.per_information11)
          from per_all_people_f ppf
          where ppf.person_id = p_absence.person_id
          and ppf.per_information_category = 'GB'
          and sysdate between ppf.effective_start_date and ppf.effective_end_date;

          l_link_letter_end_date  date;
          --
     begin
          --
          hr_utility.set_location('Entering:'||l_proc,1);
          --
          open csr_link_letter;
          fetch csr_link_letter into l_link_letter_end_date;
          close csr_link_letter;

          hr_utility.trace('Linking letter end date: '||l_link_letter_end_date);
          --
          -- check if link letter end date is after start date of current PIW
          if l_link_letter_end_date is not null and
             l_link_letter_end_date > PIW_start_date then
             -- create stoppage from the start of the current PIW to the end
             create_stoppage(p_withhold_from => PIW_start_date,
                             p_withhold_to   => PIW_end_date,
                             p_reason        => 'Linking letter',
                             p_overridden     => l_stoppage_overridden);
          end if;
          --
          hr_utility.set_location('Leaving :'||l_proc,100);
          --
     end check_linking_letter;
--
--
begin
--
-- Start of Entitled_to_SSP
--
     hr_utility.set_location('Entering:'||l_proc,1);
     --
     new_entry := empty_record;
     --
     -- SSP not installed or the absence is not sick leave
     if ((not SSP_is_installed) or p_absence.sickness_start_date is null) then
         raise no_prima_facia_entitlement;
     else
         --
         -- Get details of the absentee
         --
         open csr_person (p_absence.sickness_start_date, p_absence.person_id);
         fetch csr_person into absentee;
         --
         -- the person does not exist or has no current period of service
         if csr_person%notfound then
            close csr_person;
            raise no_prima_facia_entitlement;
         end if;
         --
         close csr_person;
         --
         -- Calculate the start and end of the linked series of PIWs.
         --
         PIW_start_date := linked_PIW_start_date (p_absence.person_id,
		                                  p_absence.sickness_start_date,
                                                  p_absence.sickness_end_date,
                                                  p_absence.absence_attendance_id);
         --
         hr_utility.trace('Piw_start_date ' || to_char(PIW_start_date,'DD-MON-YYYY'));
         --
         -- The absence passed in is not a PIW
         if PIW_start_date is null then
            -- Start Bug 418895 fixing
            --
            -- Set paramenters to delete all the associated entries
            --
            g_PIW_id := p_absence.absence_attendance_id;
            new_entry := empty_record;
            PIW_start_date := p_absence.sickness_start_date;
            PIW_end_date := hr_general.end_of_time;
            --
            -- Delete stoppages
            --
            for obsolete_stoppage in csr_old_stoppages loop
                ssp_stp_del.del(p_stoppage_id => obsolete_stoppage.stoppage_id,
                                p_object_version_number => obsolete_stoppage.object_version_number);
            end loop;
            -- End Bug 418895 fixing
            raise no_prima_facia_entitlement;
         end if;
         --
         PIW_end_date := nvl (linked_PIW_end_date (p_absence.person_id,
                                                   p_absence.sickness_start_date,
                                                   p_absence.sickness_end_date,
                                                   p_absence.absence_attendance_id),
                              hr_general.end_of_time);
         --
         hr_utility.trace('Piw_end_date ' || to_char(PIW_end_date,'DD-MON-YYYY'));
         --
         g_PIW_id := nvl(p_absence.linked_absence_id,p_absence.absence_attendance_id);
         --
         hr_utility.trace('Piw_id ' || to_char(g_PIW_id));
         --
         -- Get the legislative parameters for SSP
         --
         get_SSP_element (p_absence.sickness_start_date);
         --
         max_PIW_end_date := add_months (PIW_start_date,(12 * g_SSP_legislation.maximum_linked_PIW_years));
         --
         -- Remove any previously created stoppages (excluding user-entered ones and
         -- overridden ones)
         --
         for obsolete_stoppage in csr_old_stoppages loop
             --
             -- Delete stoppage
             --
            ssp_stp_del.del(p_stoppage_id => obsolete_stoppage.stoppage_id,
                            p_object_version_number => obsolete_stoppage.object_version_number);
         end loop;
         --
         get_last_entitled_day;
         --
         if last_entitled_day < p_absence.sickness_start_date then
            --
            -- The PIW is after a permanent stoppage
            --
            raise no_prima_facia_entitlement;
         end if;
         --
         -- Check entitlement to SSP
         --
         check_service;
         check_age;
         check_death;
         check_average_earnings;
         check_evidence;
         check_linking_letter;
         --
         -- Work out the amounts of SSP due in entries covering approx. one week each.
         --
         do_PIW_calculations;
         --
         hr_utility.set_location('Leaving :'||l_proc,100);
         --
         -- If we have got this far then the person is entitled to SSP
         -- (though stoppages may apply).
         --
         return TRUE;
     end if;
exception
     when no_prima_facia_entitlement or employee_too_old or
          earnings_too_low or evidence_not_available then
          hr_utility.set_location('Leaving :'||l_proc||', Exception',999);
          --
          return FALSE; -- employee not entitled to SSP
     --
end entitled_to_SSP;
--------------------------------------------------------------------------------
procedure generate_payments (p_entitled_to_SSP in boolean) is
--
-- Turn SSP entries in the internal data structure into actual element entries.
-- Take account of entries which have already been created for the PIW.
--
cursor csr_existing_entries is
  --
  -- The entries previously created for this PIW
  --
  select  entry.element_entry_id,
    entry.element_link_id,
    entry.assignment_id,
    entry.effective_start_date,
    entry.effective_end_date,
    max(decode(inp.name,c_rate_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) RATE,
      /* Use the SSP_correction's input_currency_code as *
       * the SSP_legislation global may not be populated */
   -------------------------------------------------------------------------
   -- Changes for bug 1020757:                                            --
   --                                                                     --
   -- The changeformat function will return the screen_entry_value in the --
   -- external display format.  This is not always 'DD-MON-YYYY' so that  --
   -- should not be hardcoded.  Better to use fnd_date.chardate_to_date   --
   -- which will convert the display format to a date.                    --
   -- This will fix bug 1020757.                                          --
   -------------------------------------------------------------------------
   /* max(decode(inp.name,c_from_name, */
   /*   to_date(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom, */
   /*   g_SSP_correction.input_currency_code),'DD-MON-YYYY'),null)) DATE_FROM, */
   /* max(decode(inp.name,c_to_name, */
   /*   to_date(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom, */
   /*   g_SSP_correction.input_currency_code),'DD-MON-YYYY'),null)) DATE_TO, */
    max(decode(inp.name,c_from_name,
      fnd_date.chardate_to_date(hr_chkfmt.changeformat(eev.screen_entry_value,
      inp.uom,g_SSP_correction.input_currency_code)),null)) DATE_FROM,
    max(decode(inp.name,c_to_name,
      fnd_date.chardate_to_date(hr_chkfmt.changeformat(eev.screen_entry_value,
      inp.uom,g_SSP_correction.input_currency_code)),null)) DATE_TO,
    -- End of Changes for bug 1020757
    ------------------------------------------------------------------------
    max(decode(inp.name,c_amount_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) AMOUNT,
    max(decode(inp.name,c_withheld_days_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) WITHHELD_DAYS,
    max(decode(inp.name,c_SSP_weeks_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) SSP_WEEKS,
    max(decode(inp.name,c_SSP_days_due_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) SSP_DAYS_DUE,
    max(decode(inp.name,c_qualifying_days_name,
      to_number(hr_chkfmt.changeformat(eev.screen_entry_value,inp.uom,
      g_SSP_correction.input_currency_code)),null)) QUALIFYING_DAYS
  from pay_input_values_f inp,
    pay_element_entry_values_f eev,
    pay_element_entries_f  ENTRY,
    per_all_assignments_f  ASGT /* adding this join speeds up the entry query */
  where creator_type = c_SSP_creator_type
  and creator_id = g_PIW_id
  and asgt.person_id = absentee.person_id
  and asgt.assignment_id = entry.assignment_id
  and entry.effective_start_date between asgt.effective_start_date
                                     and asgt.effective_end_date
  and eev.element_entry_id = entry.element_entry_id
  and eev.effective_start_date between entry.effective_start_date
                                   and entry.effective_end_date
  and eev.input_value_id +0 = inp.input_value_id
  and inp.name in (c_rate_name,c_from_name,c_to_name,c_amount_name,
                   c_withheld_days_name,c_SSP_weeks_name,
                   c_SSP_days_due_name,c_qualifying_days_name)
  and inp.effective_start_date <= eev.effective_end_date
  and inp.effective_end_date >= eev.effective_start_date
  and not exists (
    /* Do not select entries which have already had reversal action  *
     * taken against them because they are effectively cancelled out */
    select  1
    from  pay_element_entries_f  ENTRY2
    where entry.element_entry_id = entry2.target_entry_id
    and entry.assignment_id = entry2.assignment_id)
  and inp.element_type_id <> g_SSP_correction.element_type_id
    /* Do not select reversal entries */
  group by entry.element_entry_id, entry.element_link_id, entry.assignment_id,
    entry.effective_start_date, entry.effective_end_date;
  --
l_proc varchar2 (72) := g_package||'generate_payments';
l_invalid_entry boolean;
l_dummy         number;
Y		integer := 0;
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
hr_utility.trace(l_proc||'   PIW_START_DATE:'||PIW_start_date);
--
if PIW_start_date is not null
then
--   begin
--      Y:=0;
--      loop
--         Y:=Y+1;
--         hr_utility.trace('NEW ENTRY '||to_char(Y));
--         hr_utility.trace(' Date From: '||to_char(new_entry.date_from(Y)));
--         hr_utility.trace(' Date To  : '||to_char(new_entry.date_to(Y)));
--         hr_utility.trace(' Amount   : '||to_char(new_entry.amount(Y)));
--         hr_utility.trace(' Days Due : '||to_char(new_entry.ssp_days_due(Y)));
--         hr_utility.trace(' Weeks    : '||to_char(new_entry.ssp_weeks(Y)));
--         hr_utility.trace(' Withheld : '||to_char(new_entry.withheld_days(Y)));
--         hr_utility.trace(' Rate     : '||to_char(new_entry.rate(Y)));
--      end loop;
--      --
--      exception
--      when no_data_found then
--         null;
--   end;
   --
   hr_utility.set_location(l_proc,2);
   get_SSP_correction_element (PIW_start_date);
   hr_utility.set_location(l_proc,3);
   --
   -- Check each existing SSP entry in turn against all the potential new ones.
   --
   <<OLD_ENTRIES>>
   for old_entry in csr_existing_entries
   LOOP
      hr_utility.trace(l_proc||'OLD ENTRY');
      hr_utility.trace(l_proc||'Ele_entryid: '||to_char(old_entry.element_entry_id));
      hr_utility.trace(l_proc||'Ele_link_id: '||to_char(old_entry.element_link_id));
      hr_utility.trace(l_proc||'Assgment_id: '||to_char(old_entry.assignment_id));
      hr_utility.trace(l_proc||'Eff_star_dt: '||to_char(old_entry.effective_start_date));
      hr_utility.trace(l_proc||' Eff_end_dt: '||to_char(old_entry.effective_end_date));
      hr_utility.trace(l_proc||'  Date From: '||to_char(old_entry.date_from));
      hr_utility.trace(l_proc||'  Date To  : '||to_char(old_entry.date_to));
      hr_utility.trace(l_proc||'  Amount   : '||to_char(old_entry.amount));
      hr_utility.trace(l_proc||'  Days Due : '||to_char(old_entry.ssp_days_due));
      hr_utility.trace(l_proc||'  Weeks    : '||to_char(old_entry.ssp_weeks));
      hr_utility.trace(l_proc||'  Withheld : '||to_char(old_entry.withheld_days));
      hr_utility.trace(l_proc||'  Rate     : '||to_char(old_entry.rate));
      --
      -- See if the existing entry exactly matches one we are going to insert.
      -- If it does, then we do not need to change it or insert the new one.
      -- If there is no exact match, then we must reverse the existing entry.
      --
      l_invalid_entry := FALSE;
      --
      <<FIND_MATCH>>
      begin
         Y := 0;
         --
         LOOP
            Y := Y + 1;
            --
            exit when (old_entry.date_from = new_entry.date_from (Y) and
                       old_entry.date_to = new_entry.date_to (Y) and
                       old_entry.amount = new_entry.amount (Y) and
                       old_entry.ssp_days_due = new_entry.ssp_days_due (Y) and
                       old_entry.ssp_weeks = new_entry.ssp_weeks (Y) and
                       old_entry.withheld_days = new_entry.withheld_days (Y) and
                       old_entry.rate = new_entry.rate (Y));
         end loop;
      --
      exception
      when no_data_found then
         --
         -- There was no new entry which exactly matched the old entry.
         --
         l_invalid_entry := TRUE;
         --
      end;
      --
      if not l_invalid_entry then
         --
         -- The existing entry is OK so leave it alone. Simply mark the new one
         -- so that we do not attempt to insert it.
         --
         new_entry.dealt_with (Y) := 'TRUE';
         hr_utility.trace(l_proc||' Inside not l_invalid_entry');
      else
         --
         -- The existing entry has been superseded by a new one.
         --
         hr_utility.set_location(l_proc,5);
         if (ssp_smp_support_pkg.entry_already_processed(old_entry.element_entry_id))
         then
            --
            -- The processed entry must be reversed, its values are superseded.
            --
            -- Insert an entry for SSP correction element in the next payroll
            -- period, with the old entry's amounts reversed in sign so that it
            -- will cancel out the old entry.
            --
            --Changed the last_process_date to FINAL_PROCESS_DATE for debug purpose
            hr_utility.set_location(l_proc,6);
            ssp_smp_support_pkg.get_entry_details (
                  p_date_earned          => old_entry.date_from,
                  p_person_id            => absentee.person_id,
                  p_last_process_date    => absentee.final_process_date, /*7688727 changed from LSP date to FPD */
                  p_element_type_id      => g_SSP_correction.element_type_id,
                  p_element_link_id      => old_entry.element_link_id,
                  p_assignment_id        => old_entry.assignment_id,
                  p_effective_start_date => old_entry.effective_start_date,
                  p_effective_end_date   => old_entry.effective_end_date);
            --
            hr_utility.set_location(l_proc,20);
            hr_utility.trace(l_proc||' OLD: Before calling hr_entry_api.insert_element_entry');
            hr_utility.trace(l_proc||' old_entry.effective_start_date'||old_entry.effective_start_date);
            hr_utility.trace(l_proc||' old_entry.effective_end_date'||old_entry.effective_end_date);
            --
            hr_entry_api.insert_element_entry (
                  p_effective_start_date => old_entry.effective_start_date,
                  p_effective_end_date => old_entry.effective_end_date,
                  p_element_entry_id => l_dummy,
                  p_target_entry_id => old_entry.element_entry_id,
                  p_assignment_id => old_entry.assignment_id,
                  p_element_link_id => old_entry.element_link_id,
                  p_creator_type => c_SSP_creator_type,
                  p_creator_id => g_PIW_id,
                  p_entry_type => 'E',
                  p_input_value_id1 => g_SSP_correction.rate_id,
                  p_input_value_id2 => g_SSP_correction.from_id,
                  p_input_value_id3 => g_SSP_correction.to_id,
                  p_input_value_id4 => g_SSP_correction.amount_id,
                  p_input_value_id5 => g_SSP_correction.withheld_days_id,
                  p_input_value_id6 => g_SSP_correction.SSP_weeks_id,
                  p_input_value_id7 => g_SSP_correction.SSP_days_due_id,
                  p_input_value_id8 => g_SSP_correction.qualifying_days_id,
                  p_entry_value1 => old_entry.rate,
                  -- The following two lines will implicitly convert the dates
                  -- to varchar values. This will use the default format (NLS
                  -- setting) for a date which is what the date_from and
                  -- data_to UoM is set to in 11i (=Date).
                  p_entry_value2 => old_entry.date_from,
                  p_entry_value3 => old_entry.date_to,
                  p_entry_value4 => old_entry.amount * -1,
                  p_entry_value5 => old_entry.withheld_days * -1,
                  p_entry_value6 => old_entry.SSP_weeks * -1,
                  p_entry_value7 => old_entry.SSP_days_due * -1,
                  p_entry_value8 => old_entry.qualifying_days * -1);
            --
            hr_utility.set_location(l_proc,25);
         else
            --
            -- Delete the unprocessed, invalid entry
            --
            hr_utility.set_location (l_proc,30);
            --
            hr_entry_api.delete_element_entry (
                  p_dt_delete_mode => 'ZAP',
                  p_session_date => old_entry.effective_start_date,
                  p_element_entry_id => old_entry.element_entry_id);
            --
            hr_utility.set_location (l_proc,35);
         end if;
      end if;
   end loop;
   --
   if p_entitled_to_SSP then
      --
      -- The person is entitled to SSP so we can create new entries for him.
      --
      <<INSERT_NEW_ENTRIES>>
      --
      -- Now go through the new entries, inserting any which are not marked as
      -- having been dealt with already.
      --
      hr_utility.set_location (l_proc,4);
      --
      begin
         Y := 0;
         --
         LOOP
            Y := Y + 1;
            --
            if not new_entry.dealt_with (Y) = 'TRUE' and
               new_entry.ssp_weeks (Y) > 0 and
              (new_entry.withheld_days (Y) < new_entry.SSP_days_due (Y)
               or new_entry.SSP_days_due (Y) = 0)
            then
               --
               -- Insert an entry for each week where there is not already a
               -- correct, processed entry and where the stoppage days are less
               -- than the due days or the due days are zero (because of waiting
               -- days) and where the entry is for part or all of an SSP week.
               --
               hr_utility.set_location(l_proc,40);
               hr_utility.trace(l_proc||' NEW: Before calling hr_entry_api.insert_element_entry');
               hr_utility.trace(l_proc||' new_entry.effective_start_date('||Y||') :'||new_entry.effective_start_date(Y));
               hr_utility.trace(l_proc||' new_entry.effective_end_date('||Y||') :'||new_entry.effective_end_date(Y));
               --
               hr_entry_api.insert_element_entry (
                   p_effective_start_date => new_entry.effective_start_date (Y),
                   p_effective_end_date => new_entry.effective_end_date (Y),
                   p_element_entry_id => l_dummy,
                   p_assignment_id => new_entry.assignment_id (Y),
                   p_element_link_id => new_entry.element_link_id (Y),
                   p_creator_type => c_SSP_creator_type,
                   p_creator_id => g_PIW_id,
                   p_entry_type => 'E',
                   p_input_value_id1 => g_SSP_legislation.rate_id,
                   p_input_value_id2 => g_SSP_legislation.from_id,
                   p_input_value_id3 => g_SSP_legislation.to_id,
                   p_input_value_id4 => g_SSP_legislation.amount_id,
                   p_input_value_id5 => g_SSP_legislation.withheld_days_id,
                   p_input_value_id6 => g_SSP_legislation.SSP_weeks_id,
                   p_input_value_id7 => g_SSP_legislation.SSP_days_due_id,
         	   p_input_value_id8 => g_SSP_legislation.qualifying_days_id,
                   p_entry_value1 => new_entry.rate (Y),
                   -- Fix for bug 1020757:
                   -- This explicit conversion is not possible anymore since we don't know
                   -- what the format is going to be. We need to use fnd_date,date_to_chardate
                   -- p_entry_value2 => to_char(new_entry.date_from(Y),'DD-MON-YYYY'),
                   -- p_entry_value3 => to_char(new_entry.date_to(Y),'DD-MON-YYYY'),
                   p_entry_value2 => fnd_date.date_to_chardate(new_entry.date_from(Y)),
                   p_entry_value3 => fnd_date.date_to_chardate(new_entry.date_to(Y)),
                   p_entry_value4 => new_entry.amount (Y),
                   p_entry_value5 => new_entry.withheld_days (Y),
                   p_entry_value6 => new_entry.SSP_weeks (Y),
                   p_entry_value7 => new_entry.SSP_days_due (Y),
                   p_entry_value8 => new_entry.qualifying_days (Y));
               --
               hr_utility.set_location(l_proc,45);
            end if;
         end loop;
         --
         exception
         when no_data_found then
            --
            -- There are no more new entries to be inserted.
            --
            null;
            --
      end;
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end generate_payments;
--------------------------------------------------------------------------------
procedure ins_ssp_temp_affected_rows_PIW(p_absence_id in number,
                                         p_deleting in boolean default false) is
--
-- Inserts a row in ssp_temp_affected_rows for the PIW id, if not already there
--
l_proc	varchar2 (72) := g_package||'ins_ssp_temp_affected_rows_PIW';
l_deleting_ch  varchar2(1);
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
if p_deleting then
   l_deleting_ch := 'Y';
else
   l_deleting_ch := 'N';
end if;
--
if p_absence_id is not null then
   hr_utility.trace('inserting record for absence '||to_char(p_absence_id)||
                    'deleting is '||l_deleting_ch);
   --
   insert into ssp_temp_affected_rows (PIW_id, p_deleting, locked)
   select p_absence_id, l_deleting_ch, userenv('sessionid')
     from sys.dual
    where not exists
          (select null
             from ssp_temp_affected_rows t2
            where t2.PIW_id = p_absence_id);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end ins_ssp_temp_affected_rows_PIW;
--------------------------------------------------------------------------------
procedure SSP1L_control (
--
-- If prior employment details are updated then we must recalculate SSP
-- This procedure is called from the after update row-level trigger on
-- PER_PERIODS_OF_SERVICE.
--
p_person_id  in number,
p_date_start in date
) is
--
cursor affected_PIW is
	--
	-- Get any PIW which may have been linked to the prior employment SSP.
	--
	select	nvl (linked_absence_id, absence_attendance_id) PIW_ID
	from	per_absence_attendances
	where	sickness_start_date
		<= (p_date_start + g_SSP_legislation.linking_period_days)
	and	person_id = p_person_id;
	--
l_proc varchar2 (72) := g_package||'SSP1L_control';
l_PIW_ID	number := null;
--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_person_id is not null
						and p_date_start = trunc (p_date_start)
						and p_date_start is not null);
	--
	begin
	--
	hr_utility.trace (l_proc||'    p_person_id: '||to_char(p_person_id));
	hr_utility.trace (l_proc||'    p_date_start: ' ||to_char(p_date_start));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
get_SSP_element (p_date_start);
--
-- Get details of PIW which may be affected by changes in SSP1L details
--
open affected_PIW;
fetch affected_PIW into l_PIW_ID;
close affected_PIW;
--
if l_PIW_ID is not null then
   --
   -- Store the PIW ID for later use in the recalculate_SSP_and_SMP procedure
   --
   ins_ssp_temp_affected_rows_PIW (l_PIW_ID, p_deleting => FALSE);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end SSP1L_control;
--------------------------------------------------------------------------------
--
-- If the person dies or the date of birth is modified then we need to
-- recalculate SSP. This procedure is called from the after row-level update
-- trigger of PER_PEOPLE_F.
procedure person_control(p_person_id     in number,
                         p_date_of_death in date,
                         p_date_of_birth in date) is
     --
     -- Get any sickness absences which may be affected by the change in age
     -- or the death.
     cursor affected_PIWs is
     select linked_absence_id,
            absence_attendance_id,
            sickness_start_date,
            sickness_end_date
     from   per_absence_attendances
     where  person_id = p_person_id
     and    sickness_start_date is not null;
     --
     l_proc	varchar2(72)  := g_package||'person_control';
     l_65th_birthday date := add_months(p_date_of_birth, (65 *12));
     l_16th_birthday date := add_months(p_date_of_birth, (16 *12));
     l_01_October_06 date := to_date('01/10/2006','DD/MM/YYYY');
     l_employee_age number:= months_between(l_01_October_06,p_date_of_birth)/12;
     --
     procedure check_parameters is
          all_parameters_valid constant boolean :=
                       (p_person_id is not null and
                        p_date_of_death >= p_date_of_birth);
     begin
          hr_utility.trace (l_proc||'    p_person_id = '||to_char (p_person_id));
          hr_utility.trace (l_proc||'    p_date_of_death = '||to_char (p_date_of_death));
          hr_utility.trace (l_proc||'    p_date_of_birth = '||to_char (p_date_of_birth));
          --
          hr_general.assert_condition (all_parameters_valid);
          --
     end check_parameters;
     --
begin
     hr_utility.set_location('Entering:'||l_proc,1);
     --
     check_parameters;
     --
     for l_absence in affected_PIWs LOOP
         if(-- the PIW starts on or after the person's 65th birthday
            l_65th_birthday <= linked_PIW_start_date (p_person_id,
                                                      l_absence.sickness_start_date,
                                                      l_absence.sickness_end_date,
                                                      p_date_of_birth)
            -- or the PIW start on or before the person's 16th birthday
            or
            (l_16th_birthday > linked_PIW_start_date (p_person_id,
                                                     l_absence.sickness_start_date,
                                                     l_absence.sickness_end_date,
                                                     p_date_of_birth) and
             l_employee_age < 16)
            -- or the PIW ends on or after the person's death
            or p_date_of_death <= nvl(linked_PIW_end_date(p_person_id,
                                                          l_absence.sickness_start_date,
                                                          l_absence.sickness_end_date,
                                                          p_date_of_birth),
                                      p_date_of_death))
         then
             if l_employee_age < 16 then
                ins_ssp_temp_affected_rows_PIW (l_absence.absence_attendance_id,
                                                p_deleting => FALSE);
             else
                ins_ssp_temp_affected_rows_PIW (nvl(l_absence.linked_absence_id,
                                                    l_absence.absence_attendance_id),
                                                p_deleting => FALSE);
             end if;
         end if;
     end loop;
     --
     -- Call the ssp_smp_support_pkg.recalculate_ssp_and_smp directly.
     ssp_smp_support_pkg.recalculate_ssp_and_smp(p_deleting => FALSE);
     --
     hr_utility.set_location('Leaving :'||l_proc,100);
     --
end person_control;
--------------------------------------------------------------------------------
-- If absence details are updated then we must recalculate SSP.
procedure absence_control(p_absence_attendance_id in number,
                          p_linked_absence_id     in number,
                          p_person_id             in number,
                          p_sickness_start_date   in date,
                          p_deleting              in boolean default FALSE) is
     l_proc varchar2 (72) := g_package||'absence_control';
     --
     procedure check_parameters is
          all_parameters_valid constant boolean :=
               (p_person_id is not null and
                p_absence_attendance_id is not null and
                p_deleting is not null and
                p_sickness_start_date = trunc (p_sickness_start_date) and
                p_absence_attendance_id <> p_linked_absence_id);
     begin
          --
          hr_utility.trace (l_proc||'   p_absence_attendance_id = '||to_char (p_absence_attendance_id));
          hr_utility.trace (l_proc||'   p_linked_absence_id'||to_char (p_linked_absence_id));
          hr_utility.trace ('p_person_id'||to_char (p_person_id));
          hr_utility.trace ('p_sickness_start_date'	||to_char (p_sickness_start_date));
          if p_deleting then
             hr_utility.trace (l_proc||'    p_deleting is TRUE');
          else
             hr_utility.trace (l_proc||'    p_deleting is FALSE');
          end if;
          --
          hr_general.assert_condition (all_parameters_valid);
          --
      end check_parameters;
begin
     hr_utility.set_location('Entering:'||l_proc,1);
     --
     check_parameters;
     --
     if p_deleting then
        g_absence_del := 'Y';
     else
        g_absence_del := 'N';
     end if;
     --
     -- The parent PIW is being deleted. Remove any associated entries.
     if p_deleting and p_linked_absence_id is null then
        g_PIW_id := p_absence_attendance_id;
        new_entry := empty_record;
        PIW_start_date := p_sickness_start_date;
        --
        hr_utility.trace('Deleting parent absence, id '||to_char(g_PIW_id));
        --
        open csr_person (p_sickness_start_date, p_person_id);
        fetch csr_person into absentee;
        close csr_person;
        --
        generate_payments (p_entitled_to_SSP => FALSE);
        --
        delete ssp_temp_affected_rows
        where PIW_id = g_PIW_id;
     else
        --
        -- The PIW series must have been updated or inserted. Recalculate SSP.
        ins_ssp_temp_affected_rows_PIW (nvl(p_linked_absence_id,p_absence_attendance_id)
                                        ,p_deleting);
     end if;
     --
     hr_utility.set_location('Leaving :'||l_proc,100);
     --
end absence_control;
--------------------------------------------------------------------------------
procedure earnings_control (
--
-- If average earnings are altered then we must recalculate SSP.
--
p_person_id         in number,
p_effective_date    in date
) is
--
cursor affected_PIW is
	--
	-- Find the PIW whose start date is the same as the date of the
	-- average earnings calculation.
	--
	select	*
	from	per_absence_attendances
	where	sickness_start_date = p_effective_date
	and	person_id = p_person_id;
	--
l_proc	varchar2 (72) := g_package||'earnings_control';
--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_person_id is not null
						and p_effective_date is not null
						and p_effective_date = trunc (p_effective_date));
	--
	begin
	--
	hr_utility.trace (l_proc||'    p_person_id = '||to_char (p_person_id));
	hr_utility.trace (l_proc||'    p_effective_date = '
		||to_char (p_effective_date));
	--
	hr_general.assert_condition (all_parameters_valid);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
check_parameters;
--
open affected_PIW;
fetch affected_PIW into g_absence;
close affected_PIW;
--
if g_absence.absence_attendance_id is not null
then
   hr_utility.set_location (l_proc,10);
   --
   ins_ssp_temp_affected_rows_PIW (g_absence.absence_attendance_id,
                                   p_deleting => FALSE);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end earnings_control;
--------------------------------------------------------------------------------
procedure stoppage_control (p_absence_id in number) is
--
-- If the user modifies stoppages then we must recalculate the SSP entitlement.
--
l_proc	varchar2 (72) := g_package||'stoppage_control';
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
if p_absence_id is not null
then
   ins_ssp_temp_affected_rows_PIW (p_absence_id, p_deleting => FALSE);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end stoppage_control;

--------------------------------------------------------------------------------
procedure medical_control (p_absence_id in number) is
--
-- If the user modifies medical evidence  then recalculate the SSP entitlement.
--
l_proc	varchar2 (72) := g_package||'medical_control';
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
if p_absence_id is not null and g_absence_del = 'N'
then
   ins_ssp_temp_affected_rows_PIW (p_absence_id, p_deleting => FALSE);
end if;

g_absence_del := 'N';
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
end medical_control;

--------------------------------------------------------------------------------
procedure SSP_control(p_absence_attendance_id in number) is
     l_proc	varchar2 (72) := g_package||'SSP_control';
     --
     l_rows_reason  number:=0;
     --
     cursor csr_previous_reason is
     select count(*)
     from   ssp_withholding_reasons swr,
            ssp_stoppages stp
     where  stp.absence_attendance_id = p_absence_attendance_id
     and    stp.reason_id = swr.reason_id
     and    upper(swr.reason) = 'RE-HIRED EMPLOYEE,PLEASE CHECK';
     --
     procedure check_parameters is
          all_parameters_valid constant boolean := (p_absence_attendance_id is not null);
     begin
          hr_utility.trace (l_proc||'	p_absence_attendance_id = '||to_char (p_absence_attendance_id));
          --
          hr_general.assert_condition (all_parameters_valid);
          --
     end check_parameters;
begin
     hr_utility.set_location('Entering:'||l_proc,1);
     hr_utility.trace(l_proc||'---------PARAMS------------');
     hr_utility.trace(l_proc||'p_absence_attendance_id:'||p_absence_attendance_id);
     hr_utility.trace(l_proc||'---------------------------');
     --
     check_parameters;
     hr_utility.set_location(l_proc,2);
     --
     get_absence_details (p_absence_attendance_id);
     --
     open csr_previous_reason;
     fetch csr_previous_reason into l_rows_reason;
     if l_rows_reason > 0 then
        hr_utility.set_location(l_proc,3);
        ssp_smp_support_pkg.reason_for_no_earnings:='SSP_36076_EMP_REHIRED';
        hr_utility.set_location(l_proc,4);
     end if;
     close csr_previous_reason;
     --
     hr_utility.set_location(l_proc,5);
     generate_payments (entitled_to_SSP (g_absence));
     --
     hr_utility.set_location('Leaving :'||l_proc,100);
     --
end SSP_control;
--------------------------------------------------------------------------------
end ssp_SSP_pkg;

/
