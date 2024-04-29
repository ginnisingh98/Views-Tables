--------------------------------------------------------
--  DDL for Package Body SSP_SMP_SUPPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SMP_SUPPORT_PKG" as
/*      $Header: spsspbsi.pkb 120.10.12010000.6 2008/12/19 09:42:38 pbalu ship $
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	SSP/SMP shared code package
Purpose
	To hold code common to both SSP and SMP business processes.
History
	31 Aug 95       N Simpson       Created
	15 Sep 95	N Simpson	Added function stoppage_overridden
	20 sep 95	N Simpson	Added procedure recalculate_SSP_and_SMP
	27 Oct 95	N Simpson	Replaced hr_ prefix with ssp_
	 3 Nov 95	N Simpson	csr_next_available_period%notfound
					replaced with l_effective_start_date is
					not null in get_entry_details procedure;
					cursor will always return a row because
					of the MIN function.
	27 Nov 95	N Simpson	Removed temporary code from last update
					and changed criteria for selecting
					payroll periods in get_entry_details
	30 Nov 95	N Simpson	Reversed comparison between
					p_last_process_date and p_date_earned
					in get_entry_details cursor
					csr_next_available_period. It was,
					incorrectly, ignoring date earned
					because date earned was always less than
					the end of time.
	 5 dec 95	N Simpson	Added function average_earnings_error.
	 6 Dec 95	N Simpson	Added reference to ssp_smp_support_pkg.
                                         reason_for_no_earnings
	19 Jan 96	N Simpson	Added functions start_of_week and
					end_of_week.
 08-Jan-98  RThirlby 608724  30.24      Altered non-translateable MON format
                                        for dates to MM.
                                        Parameter p_deleting added to procedure
                                        recalculate_ssp_and_smp. If p_deleting
                                        logic to get rid of orphaned stoppages.
                                        Part of SMP entries problem.
 24-Mar-98 RThirlby 563202 30.25	Performance fix to csr_stoppage.
 19-AUG-98 A.Myers  701750 30.26	Amended cursors for affected rows, as
                                        the "where not exists" did not work.
					This existence checking is now done in
                                        SSP_SSP_PKG/SSP_SMP_PKG on the actual
                                        row insert. Added p_deleting to SMP call
                                        to SMP_control.
 06-JAN-2000 ILeath        30.27/       Add call to stop_if_director and
                           110.7        check_payroll_installed within
                                        recalculate_ssp_and_smp. To
                                        ensure that message within
                                        average_earnings_error is always
                                        set. Also default if null
                                        message to 'Cannot derive new
                                        emps pay'.
 12-APR-2000 A.Mills       30.28        Changed NI_Lower_Earnings_Limit
                           =110.8       function to retrieve the Weekly
                                        LEL figure from the Global
                                        'NI_WEEKLY_LEL' rather than the
                                        User Table, which becomes obsolete
                                        as at 6-APR-2000. Bug 871095.
 05-DEC-2001 GButler	   115.7 	Added new procedure update_ssp_smp_entries
 					to allow automatic recalculation of SSP/
					SMP entries over tax year end following
					legislative updates to the corresponding
					SSP/SMP rates. Procedure is called from
					perleggb.sql script after seed data
					install completed
 31-DEC-2001 ABHADURI      115.8       Added a condition to inform user that
                                       employee has been re-hired within 8 weeks.
 15-JAN-2002 GBUTLER	   115.9	Updated update_ssp_smp_entries procedure
 					to exclude all terminated employees whose
 					final process date has already passed
 02-FEB-2002 GBUTLER	   115.10	Bug 2189501. Updated SSP and SMP queries
 					to better handle employee terminations and
 					exclude deceased employees for SMP. Also
 					added exceptions to handle cases where no
 					element entries can be found in new tax year
 05-FEB-2002 GBUTLER	   115.12	Updated queries to retrieve SSP/SMP entries in
 					new tax year so that entries retrieved relate to
 					people who would be retrieved by the main SSP/SMP
 					queries
 14-FEB-2002 GBUTLER	   115.13 	Added close statements to cursors
 26-FEB-2002 GBUTLER	   115.14	Altered update_ssp_smp_entries by adding sub-blocks
 					into loops to detect errors as they occur but not to
 					halt update process because of them. Added p_update_
 					error boolean flag to alert user to absences that
 					could not be updated
 02-DEC-2002 ABLINKO       115.16       Bug 2690305. New SAP/SPP functionality
 10-DEC-2002 GBUTLER	   115.17       Bug 2702282. Commented out section for SMP rate updates
 					for TYE 2002/3
 17-DEC-2002 ABLINKO       115.18       gscc fix
 09-jan-2003 vmkhande      115.19       bug 2706844
                                        Effective start date now retuned from
                                        get_entry_details will be the max of
                                        assignment start date and payroll
                                        period start date.
 24-JAN-2003 GButler	   115.20	nocopy fixes
 06-MAR-2003 GButler	   115.21 	Bug 1681054. Change to csr_assignment cursor in
 					get_entry_details to exclude benefits assignments
 24-OCT-2003 ABlinko       115.22       Replaced hardcoded SATURDAY and SUNDAY references
 08-DEC-2003 RMakhija      115.24       Uncommented SMP element entry update when rate
                                        changes in next tax year. Also added similar
                                        Functionality for SAP, SPP Birth and SPP Adoption.
 17-DEC-2003 RMakhija      115.25       Added detection of SMP/SAP/SPP standard rate
                                        changes and SMP Higher Rate changes to auto
                                        update element entries in next tax year.
 12-FEB-2004 RMakhija      115.26       Bug 3437026. Updated csr_affected_leave
                                        cursor in update_ssp_smp_entries procedure.
 02-MAR-2004 ABlinko       115.27       Bug 3456918 - Added rtrim when deriving
                                        l_saturday_txt and l_sunday_txt
 21-MAR-2006 Kthampan      115.28       Bug 5105039 - Passing the correct date when
                                        fetching element link.
 31-JUL-2006 Kthampan      115.29       Bug 5346648 - Update procedure get_entry_details
                                        to re-fetch the effective_start/end date again
                                        if the assignment start date is > the
                                        period start_date.
 23-AUG-06   KThampan      115.30       Bug  5482199 -  Statutory changes for 2007
                           115.31       Change cursor csr_payroll_period to check
                                        for period.cut_off_date when payment is not
                                        in lump sum.
 19-SEP-06   KThampan      115.33       Bug 5547703 - Amend recalculate_SSP_and_SMP
                                        only to delete stoppage when absence
                                        record = 0
 20-OCT-06   KThampan      115.34       Amend cursor csr_payroll_period to use
                                        p_date_earned <= period.end_date instead of
                                        p_date_earned <= nvl(cut_off_date,end_date)
 09-DEC-06   KThampan      115.35       Amend procedure recalculate_SSP_and_SMP to only
                                        process rows within the same session id
 12-MAR-07   KThampan      115.36       Added distinct when select input id for SSP
                                        cursor csr_first_new_ssp_entry
 21-MAR-07   KThampan      115.37       Amended cursor csr_affected_absences and
                                        csr_affected_leave to check for period of
                                        service id
 20-FEB-07   pbalu         115.38       Added Multi threaded update_ssp_smp_entries
					as part of 6800788.
 27-FEB-07   pbalu         115.39       Error flag is not set in the multithreaded
					update_ssp_smp_entries
 25-AUG-08   pbalu         115.40       Changed the cursor csr_payroll_period to
						    take care of positive cutoff period for bug 6959669
 18-DEC-08   npannamp      115.42       Modified multithreaded update_ssp_smp_entries
                                        to resubmit failed jobs once more as part of
                                        bug 6870415
*/
--------------------------------------------------------------------------------
g_package	constant varchar2 (31) := 'ssp_smp_support_pkg.';


--
cursor csr_entry_value (
	--
	p_element_entry_id	in number,
	p_input_value_name	in varchar2) is
	--
	-- Selects an entry value for a given
	-- element entry and named input value
	--
	select	entry.screen_entry_value,
		inp.uom,
		ele.input_currency_code,
		inp.input_value_id
	from	pay_element_entry_values_f entry,
		pay_input_values_f inp,
		pay_element_types_f ele
	where	entry.element_entry_id = p_element_entry_id
	and	inp.name = p_input_value_name
	and	entry.input_value_id = inp.input_value_id
	and	ele.element_type_id = inp.element_type_id
	and	ele.effective_start_date <= inp.effective_end_date
	and	ele.effective_end_date >= inp.effective_start_date
	and	inp.effective_start_date <= entry.effective_end_date
	and	inp.effective_end_date >= entry.effective_start_date;
	--
--------------------------------------------------------------------------------
function start_of_week (p_date date) return date is
--
-- Returns the date of the last Sunday before the p_date, or the p_date if
-- that is actually a Sunday anyway.
--
l_Sunday	date := p_date;
l_proc		varchar2 (72) := g_package||'start_of_week';
l_sunday_txt    varchar2(100) := rtrim(to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY'));
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
hr_utility.trace('    p_date: '||to_char (p_date));
--
if p_date is not null and p_date <> hr_general.end_of_time
then
   if rtrim (to_char (p_date, 'DAY')) <> l_sunday_txt then
      l_Sunday := next_day (p_date, l_sunday_txt) -7;
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
return l_Sunday;
--
end start_of_week;
--------------------------------------------------------------------------------
function end_of_week (p_date date) return date is
--
-- Returns the date of the Saturday following the p_date, or the p_date if
-- that is actually a Saturday anyway.
--
l_Saturday	date := p_date;
l_proc		varchar2 (72) := g_package||'end_of_week';
l_saturday_txt  varchar2(100) := rtrim(to_char(to_date('06/01/2001','DD/MM/YYYY'),'DAY'));
--
begin
--
hr_utility.set_location('Entering:'||l_proc,1);
--
hr_utility.trace('    p_date: '||to_char (p_date));
--
if p_date is not null and p_date <> hr_general.end_of_time
then
   if rtrim (to_char (p_date, 'DAY')) <> l_saturday_txt then
     l_Saturday := next_day (p_date, l_saturday_txt);
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
return l_Saturday;
--
end end_of_week;
--------------------------------------------------------------------------------
function NI_Lower_Earnings_Limit (p_effective_date in date) return number is
--
cursor csr_LEL is
	--
	-- Get the LEL as at the effective date
	--
        select  to_number(ni.global_value)      LEL
        from    ff_globals_f ni
        where   ni.global_name = 'NI_WEEKLY_LEL'
        and     ni.business_group_id is null
        and     ni.legislation_code = 'GB'
        and     p_effective_date between ni.effective_start_date
                                        and ni.effective_end_date;
	--
l_proc	varchar2 (72) := g_package||'NI_Lower_Earnings_Limit';
l_LEL	number;
--
procedure check_parameters is
	--
	all_parameters_valid constant boolean := (p_effective_date is not null
					and p_effective_date = trunc (p_effective_date));
	--
	begin
	--
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
open csr_LEL;
fetch csr_LEL into l_lel;
close csr_LEL;
--
if l_LEL is null then
   --
   -- The LEL is seeded on to user tables, but we do not seed data for the
   -- tax years before 95/96 so if the customer has need for the LEL value
   -- before this date (eg for historic absences) then we must set the historic
   -- value before returning.
   --
   hr_utility.trace ('  No LEL defined on user tables; hard-coding value');
   --
   if p_effective_date between to_date ('06-04-1991', 'DD-MM-YYYY')
                           and to_date ('05-04-1992', 'DD-MM-YYYY')
   then
      l_LEL := 52.00;      -- Tax Year 91/92
   elsif
      p_effective_date between to_date ('06-04-1992', 'DD-MM-YYYY')
                           and to_date ('05-04-1993', 'DD-MM-YYYY')
   then
      l_LEL := 54.00;      -- Tax Year 92/93
   elsif
      p_effective_date between to_date ('06-04-1993', 'DD-MM-YYYY')
                           and to_date ('05-04-1994', 'DD-MM-YYYY')
   then
      l_LEL := 56.00;       -- Tax Year 93/94
   elsif
      p_effective_date between to_date ('06-04-1994', 'DD-MM-YYYY')
                           and to_date ('05-04-1995', 'DD-MM-YYYY')
   then
      l_LEL := 57.00;       -- Tax Year 94/95
   end if;
end if;
--
hr_utility.set_location('Leaving :'||l_proc, 100);
--
return l_LEL;
--
end NI_Lower_Earnings_Limit;
--------------------------------------------------------------------------------
function entry_already_processed (
	--
	-- Returns TRUE if the entry passed in has already been processed in a
	-- payroll run
	--
	p_element_entry_id	in number) return boolean is
	--
cursor csr_processed is
	select	1
	from	pay_run_results
	where	source_id = p_element_entry_id
	and	status <> 'U';
	--
l_processed	boolean := FALSE;
l_dummy		integer (1);
--
begin
--
open csr_processed;
fetch csr_processed into l_dummy;
--
if csr_processed%found then
  l_processed := TRUE;
end if;
--
close csr_processed;
--
return l_processed;
--
end entry_already_processed;
--------------------------------------------------------------------------------
function value (
--
-- Returns an entry value for a named input value
-- and element entry.
--
	p_element_entry_id	number,
	p_input_value_name	varchar2)
	--
return varchar2 is
--
l_entry_value	csr_entry_value%rowtype;
l_value		varchar2 (80);
--
begin
--
open csr_entry_value (p_element_entry_id,p_input_value_name);
fetch csr_entry_value into l_entry_value;
close csr_entry_value;
--
l_value := hr_chkfmt.changeformat (	l_entry_value.screen_entry_value,
					l_entry_value.uom,
					l_entry_value.input_currency_code);
return l_value;
--
end value;
--------------------------------------------------------------------------------
function element_input_value_id (
--
-- Returns the input value ID for a named
-- input value
--
	p_element_type_id	number,
	p_input_value_name	varchar2)
	--
return number is
--
cursor csr_input_value is
	select	input_value_id
	from	pay_input_values_f
	where	name = p_input_value_name
	and	element_type_id = p_element_type_id;
	--
l_input_value	csr_input_value%rowtype;
--
begin
--
open csr_input_value;
fetch csr_input_value into l_input_value;
close csr_input_value;
--
return l_input_value.input_value_id;
--
end element_input_value_id;
--------------------------------------------------------------------------------
function withholding_reason_id (
--
-- Returns the ID of a withholding reason, given a reason and element type id
--
p_element_type_id	in number,
p_reason		in varchar2
--
) return number is
--
cursor csr_reason_id is
	--
	-- Get the reason id.
	--
	select	reason_id
	from	ssp_withholding_reasons
	where	upper (reason) = upper (p_reason)
	and	element_type_id = p_element_type_id;
	--
l_reason_id	number;
--
begin
--
open csr_reason_id;
fetch csr_reason_id into l_reason_id;
--
if csr_reason_id%notfound then
  --
  fnd_message.set_name ('SSP','SSP_35046_NO_SUCH_REASON');
  fnd_message.set_token ('REASON',p_reason);
  fnd_message.raise_error;
  --
end if;
--
close csr_reason_id;
--
return l_reason_id;
--
end withholding_reason_id;
--------------------------------------------------------------------------------
function stoppage_overridden (
--
-- Returns TRUE if there is a stoppage for the specified reason which has been
-- overridden by the user.
--
p_reason_id	in number,
p_absence_attendance_id	in number default null,
p_maternity_id	in number default null
) return boolean is
--
cursor csr_stoppage is
	--
	-- Return a row if there is a stoppage of the specified type for the
	-- absence.
	--
-- 563202 - by concatenating null to reason_id forces a more efficient index
-- to be used.
	select	1
	from	ssp_stoppages
	where	((p_absence_attendance_id is not null
		and p_absence_attendance_id = absence_attendance_id)
		or (p_maternity_id is not null
		and p_maternity_id = maternity_id))
	and	reason_id||null = p_reason_id
	and	override_stoppage = 'Y';
	--
l_dummy			integer (1);
l_stoppage_overridden	boolean := FALSE;
--
begin
--
open csr_stoppage;
fetch csr_stoppage into l_dummy;
l_stoppage_overridden := csr_stoppage%found;
close csr_stoppage;
--
return l_stoppage_overridden;
--
end stoppage_overridden;
--------------------------------------------------------------------------------
procedure recalculate_SSP_and_SMP (p_deleting in boolean default FALSE) is
--
-- Recalculate SSP and SMP for any rows affected by DML.
--
cursor csr_affected_maternities is
	--
	-- Find all maternity ids which have been inserted by row triggers
	-- because a change to one of their SMP parameters occurred. Exclude
	-- rows which are already being processed (because the process may
	-- cause the row triggers to fire and call this procedure recursively),
	-- and rows which are duplicated.
	--
	select  tar1.maternity_id, nvl(tar1.p_deleting, 'N') l_deleting
	from    ssp_temp_affected_rows TAR1
	where   tar1.maternity_id is not null
	--and	nvl (tar1.locked, 'NULL') <> 'Y'
        and     tar1.locked = to_char(userenv('sessionid'))
	for update;
	--
cursor csr_leave_type (p_maternity_id number) is
    select leave_type
        from ssp_maternities
        where maternity_id = p_maternity_id;

cursor csr_affected_PIWs is
	--
	-- Find all PIW IDs which have been inserted by row triggers
	-- because a change to one of their SSP parameters occurred.
        -- Exclusion of duplicates now done in ssp_ssp_pkg.SSP-Control as
        -- the previous "not exists" did not work... the data is already
        -- selected before they can be updated.
	--
        select  tar1.PIW_id, nvl(tar1.locked,'NULL') locked
          from  ssp_temp_affected_rows TAR1
         where  tar1.PIW_id is not null
         --  and  nvl (tar1.locked,'NULL') <> 'Y'
         and    tar1.locked = to_char(userenv('sessionid'))
for update;
--
cursor csr_count_absences(p_maternity_id number) is
        select count(*)
        from   ssp_maternities mat,
               per_absence_attendances ab
        where  mat.maternity_id = p_maternity_id
        and    ab.person_id = mat.person_id
        and    ab.maternity_id = mat.maternity_id;
--
l_proc	    varchar2 (72) := g_package||'recalculate_SSP_and_SMa';
l_deleting  boolean;
row_deleted exception;
l_count     number;
l_leave_type varchar2 (2);
pragma exception_init (row_deleted, -8006);
--
mutating_table	exception;
pragma exception_init (mutating_table, -4091);
--
-- Oracle error -4091 occurs if a trigger attempts to read or modify a table
-- which is being modified by the code which caused the trigger to fire.
--
BEGIN
--
hr_utility.set_location('Entering:'||l_proc,1);
--
if ssp_ssp_pkg.ssp_is_installed
then
   if csr_affected_PIWs%IsOpen then
      close csr_affected_PIWs;
   end if;
   --
   if csr_affected_maternities%IsOpen then
      close csr_affected_maternities;
   end if;
   --
   -- Recalculate SSP for all PIWs affected by row inserts/updates/deletes
   --
   -- Make sure all the linked PIWs are correctly defined.
   ssp_ssp_pkg.update_linked_absence_IDs;
   --
   for each_PIW in csr_affected_PIWs LOOP
      hr_utility.trace ('    Recalculate SSP for PIW #'||
                        to_char(each_PIW.PIW_ID));
      --
      if each_PIW.locked <> 'Y'
      then
         update ssp_temp_affected_rows
            set locked = 'Y'
          where current of csr_affected_PIWs;
         --
         ssp_ssp_pkg.ssp_control(each_PIW.piw_id);
      end if;
   end loop;
   --
   -- Recalculate SMP for all maternities affected by inserts/updates/deletes
   --
   for each_maternity in csr_affected_maternities LOOP
      hr_utility.trace ('    Recalculate SMP for maternity_id # '
			||to_char (each_maternity.maternity_id));
      --
      update ssp_temp_affected_rows
         set locked = 'Y'
       where current of csr_affected_maternities;
      --
      if each_maternity.l_deleting = 'Y'
      then
         l_deleting := TRUE;
      else
         l_deleting := FALSE;
      end if;
      open csr_leave_type(each_maternity.maternity_id) ;
      fetch csr_leave_type into l_leave_type;
      close csr_leave_type;

      if l_leave_type is null or l_leave_type = 'MA' then
              ssp_SMP_pkg.SMP_control (each_maternity.maternity_id, l_deleting);
      elsif l_leave_type ='AD' then
              ssp_sap_pkg.sap_control (each_maternity.maternity_id, l_deleting);
      elsif l_leave_type ='PA' then
              ssp_pad_pkg.pad_control (each_maternity.maternity_id, l_deleting);
      elsif l_leave_type ='PB' then
              ssp_pab_pkg.pab_control (each_maternity.maternity_id, l_deleting);
      end if;
      --
      -- RT entries prob
      --
      open csr_count_absences(each_maternity.maternity_id);
      fetch csr_count_absences into l_count;
      close csr_count_absences;

      if l_deleting and l_count < 1
      then
         hr_utility.set_location('ssp_del_orphaned_rows:'||l_proc,50);
         --
         delete ssp_stoppages
          where maternity_id = each_maternity.maternity_id;
      end if;
   end loop;
   --
   delete ssp_temp_affected_rows
   where  locked = to_char(userenv('sessionid'))
   or     locked is null
   or     locked not in (select to_char(AUDSID) from v$session);
end if;
--
hr_utility.set_location('Leaving :'||l_proc,100);
--
exception
--
when mutating_table or row_deleted then
  --
  -- If we get a mutating table restriction then we must be firing this code
  -- recursively (eg the user deleted an absence which cascaded to delete the
  -- stoppages for it; both the absence deletion and the stoppage deletion
  -- causing this code to fire). If this occurs then we do not want the
  -- second and subsequent calls to do anything so just exit silently.
  --
  null;
  --
  hr_utility.set_location (l_proc,999);
  --
end recalculate_SSP_and_SMP;
------------------------------------------------------------------------------
procedure get_entry_details(p_date_earned          in date,
                            p_last_process_date	   in date,
                            p_person_id	           in number,
                            p_element_type_id      in number,
                            p_element_link_id      in out nocopy number,
                            p_assignment_id        in out nocopy number,
                            p_effective_start_date out nocopy date,
                            p_effective_end_date   out nocopy date,
                            p_pay_as_lump_sum      in varchar2 default 'N') is
     --
     cannot_derive_payroll_period exception;
     no_payroll	                  exception;
     --
     l_found                boolean := false;
     --
     l_temp_date            date;
     l_assignment_start     date;
     l_assignment_end       date;
     l_closed_period        date;
     l_effective_date       date := null;
     l_effective_start_date date := null;
     l_effective_end_date   date := null;
     l_last_process_date    date := nvl (p_last_process_date,hr_general.end_of_time);
     --
     l_payroll_id           number := null;
     --
     --
     l_proc                 varchar2(72) := g_package||'get_entry_details';
     l_pay_as_lump_sum      varchar2(1) := nvl (p_pay_as_lump_sum, 'N');
     --
     -- Get the user's effective date
     cursor csr_effective_date is
     select effective_date
     from   fnd_sessions
     where  session_id = userenv ('sessionid');
     --
     -- Get the details of the primary assignment as at the date
     -- earned.
     cursor csr_assignment(p_date date,
                           p_lsp  date) is
     select assignment_id,
            payroll_id
     from   per_all_assignments_f
     where  person_id = p_person_id
     and    primary_flag = 'Y'
     and    assignment_type = 'E'
     and    least(p_date,p_lsp) between effective_start_date and effective_end_date;
     --
     -- Get Min(start), Max(end) of assignment on payroll x
     cursor csr_assignment_duration(p_date   date,
                                    p_asg_id number,
                                    p_pay_id number) is
     select min(effective_start_date),
            max(nvl(effective_end_date,hr_general.end_of_time))
     from   per_all_assignments_f
     where  assignment_id = p_asg_id
     and    primary_flag = 'Y'
     and    assignment_type = 'E'
     and    payroll_id = p_pay_id;
     --
     -- Get minimum closed period
     cursor csr_minimum_closed(p_payroll_id number) is
     select nvl(max(period.start_date),to_date('01/01/0001','DD/MM/YYYY'))
     from   per_time_periods period
     where  period.payroll_id = p_payroll_id
     and    period.prd_information_category = 'GB'
     and    period.prd_information1 = 'Closed';
     --
     -- Get period details
     cursor csr_payroll_period is
     select min(period.start_date),
            min(nvl(period.end_date,hr_general.end_of_time))
     from   per_time_periods period
     where  period.payroll_id = l_payroll_id
     and    period.start_date > l_closed_period
--6959669 begin
--     and    nvl(period.cut_off_date,period.end_date) <= l_last_process_date
     and    least(nvl(period.cut_off_date,period.end_date),period.end_date) <= l_last_process_date
--6959669 end
     and   (nvl(period.cut_off_date,period.end_date) >= l_effective_date
            or (    l_effective_date > l_last_process_date
                and l_last_process_date between period.start_date and period.end_date))
     and   (    l_pay_as_lump_sum = 'Y'
             or(      l_pay_as_lump_sum = 'N'
                 and (   p_date_earned <= period.end_date
                      or l_last_process_date < p_date_earned)));

     --
     procedure check_parameters is
          all_parameters_valid constant boolean :=
                      (p_pay_as_lump_sum in ('Y','N') and
                       p_person_id       is not null and
                       p_element_type_id is not null and
                       p_date_earned     is not null and
                       p_date_earned = trunc (p_date_earned) and
                       p_last_process_date = trunc (p_last_process_date));
     begin
          hr_utility.trace ('    p_date_earned = '||to_char (p_date_earned, 'DD-MON-YYYY'));
          hr_utility.trace ('    p_last_process_date = '||to_char (p_last_process_date));
          hr_utility.trace ('    p_person_id = ' ||to_char (p_person_id));
          hr_utility.trace ('    p_element_type_id = '||to_char (p_element_type_id));
          hr_utility.trace ('    p_element_link_id = '||to_char (p_element_link_id));
          hr_utility.trace ('    p_assignment_id = '||to_char (p_assignment_id));
          hr_utility.trace ('    p_pay_as_lump_sum = '||p_pay_as_lump_sum);
          --
          hr_general.assert_condition (all_parameters_valid);
          --
     end check_parameters;
     --
begin
     --
     hr_utility.set_location ('Entering:'||l_proc,1);
     --
     check_parameters;
     --
     -- Get the effective date
     open csr_effective_date;
     fetch csr_effective_date into l_effective_date;
     close csr_effective_date;
     --
     if l_effective_date is null then
        l_effective_date := trunc (sysdate);
     end if;
     --
     hr_utility.trace(l_proc||'    effective date = '||to_char(l_effective_date, 'DD-MON-YYYY'));
     --
     -- 1. Find out which date to use when searching for payroll period
     if l_pay_as_lump_sum = 'Y' then
        l_temp_date := l_effective_date;
     else
        l_temp_date := greatest(p_date_earned,l_effective_date);
     end if;

     while not l_found loop
         -- 2. Get assignemnt info as of l_temp_date
         open csr_assignment(l_temp_date,l_last_process_date);
         fetch csr_assignment into p_assignment_id, l_payroll_id;
         close csr_assignment;

         open csr_assignment_duration(l_temp_date,p_assignment_id,l_payroll_id);
         fetch csr_assignment_duration into l_assignment_start,l_assignment_end;
         close csr_assignment_duration;

         open csr_minimum_closed(l_payroll_id);
         fetch csr_minimum_closed into l_closed_period;
         close csr_minimum_closed;

         -- 3. Check payroll
         if l_payroll_id is null then
            raise no_payroll;
         end if;

         -- 4. Get period details
         open csr_payroll_period;
         fetch csr_payroll_period into l_effective_start_date,
                                       l_effective_end_date;
         close csr_payroll_period;

         -- 5. Check that the period is valid for assignment
         if l_assignment_start > l_effective_start_date then
            l_effective_start_date := l_assignment_start;
            -- bug fix 5346648 - If asg start date is more than the period end date
            -- then we have to fetch the next period
            if l_assignment_start >= l_effective_end_date then
               l_effective_date := l_assignment_start;
               open csr_payroll_period;
               fetch csr_payroll_period into l_effective_start_date,
                                             l_effective_end_date;
               close csr_payroll_period;
            end if;
         end if;

         -- 6. If cannot find any period then, error out
         if (l_effective_start_date is null or l_effective_end_date is null) then
             raise cannot_derive_payroll_period;
         else
             -- period is found but is it > assignment end date
             if l_assignment_end < l_effective_start_date then
                 l_temp_date := l_effective_start_date;
             else
                 l_found := true;
                 p_effective_start_date := l_effective_start_date;
                 p_effective_end_date   := l_effective_end_date;
                 hr_utility.trace(l_proc||'    l_effective_start_date = ' ||to_char(l_effective_start_date, 'DD-MON-YYYY'));
                 hr_utility.trace(l_proc||'    l_effective_end_date = ' ||to_char(l_effective_end_date, 'DD-MON-YYYY'));
             end if;
         end if;
     end loop;
     --
     -- 7. Fetching the link based on the effective start date of the entry.
     p_element_link_id := hr_entry_api.get_link (p_assignment_id   => p_assignment_id,
                                                 p_element_type_id => p_element_type_id,
                                                 p_session_date    => p_effective_start_date);
     --
     hr_utility.set_location ('Leaving :'||l_proc,1);
     --
exception
     when cannot_derive_payroll_period then
          fnd_message.set_name ('SSP', 'SSP_35029_NO_PAYROLL_PERIOD');
          fnd_message.raise_error;
     when no_payroll then
          fnd_message.set_name ('SSP','SSP_35080_NO_PAYROLL');
          fnd_message.set_token ('DATE_EARNED',p_date_earned);
          fnd_message.raise_error;
end get_entry_details;
--------------------------------------------------------------------------------
function average_earnings_error return varchar2 is
--
-- Returns the withholding reason corresponding to the error which was raised
-- by the procedure to calculate average earnings in the event that the figure
-- could not be derived. This withholding reason may be used to create a
-- stoppage of SSP/SMP thus indicating why the entries were not created.
--
-- The message is defaulted  only if ssp_smp_support_pkg returns a
-- null value. This ocurs when a commit is fired within the Absence
-- form, as the recalculate_ssp_and_smp is fired and does not create a
-- 'reason for no earnings', this is only created when
-- calculate_average_earnings is used.
--

l_message_name_on_stack	varchar2 (80) := ssp_smp_support_pkg.reason_for_no_earnings;
l_withholding_reason		varchar2 (80) := null;
--
begin
--
if l_message_name_on_stack = 'SSP_35024_NEED_PAYROLL_FOR_ERN' then
  --
  -- Message is:
  -- "Average Earnings cannot be calculated automatically unless
  -- you have installed Oracle Payroll. You must enter the figure
  -- yourself."
  --
  l_withholding_reason := 'Payroll not installed';
  --
elsif l_message_name_on_stack = 'SSP_35026_NO_NEW_EMP_EARNINGS' then
  --
  -- Message is:
  -- "Oracle Payroll cannot derive average earnings for employees who
  -- have not yet received any pay on which to base a calculation.
  -- Please enter the average earnings figure yourself, based upon the
  -- employee's contracted weekly earnings."
  --
  l_withholding_reason := 'Cannot derive new emps pay';
  --
  -- (abhaduri) added to inform about employees re-hired
  -- within 8 weeks of their termination
elsif l_message_name_on_stack = 'SSP_36076_EMP_REHIRED' then
  --
  -- Message is:
  -- "Average earnings cannot be calculated as the employee is new.
  -- Please take into account the previous period payment while
  -- calculating average earnings manually."
  --
  l_withholding_reason :='Re-hired employee,please check';
  --
elsif l_message_name_on_stack = 'SSP_35025_NO_DIRECTOR_EARNINGS' then
  --
  -- Message is:
  -- "Oracle Payroll is unable to calculate the earnings of directors
  -- because it has no way to distinguish between voted fees and fees
  -- drawn in anticipation of voting. Please enter average earnings
  -- for directors yourself."
  --
  l_withholding_reason := 'Cannot derive directors pay';
  --
  --
elsif l_message_name_on_stack IS NULL then
  --
  l_withholding_reason := 'Cannot derive new emps pay';
  --
end if;
--
-- Reset global variable to avoid later confusion
ssp_smp_support_pkg.reason_for_no_earnings := null;
--
return l_withholding_reason;
--
end average_earnings_error;

--------------------------------------------------------------------------------
--
procedure update_ssp_smp_entries (P_UPDATE_ERROR OUT NOCOPY boolean) is


cursor csr_affected_absences is
	select nvl(paa.linked_absence_id,paa.absence_attendance_id) as absence_id,
	       paa.person_id,
	       nvl(paa.date_start,paa.sickness_start_date) as absence_start_date,
	       nvl(paa.date_end,paa.sickness_end_date) as absence_end_date
	from per_absence_attendances paa,
	     per_absence_attendance_types paat
	where paa.absence_attendance_type_id = paat.absence_attendance_type_id
	and paat.absence_category = 'S'
	and
	/* SSP absences which span tax years or start in old tax year and are open-ended */
	(
		  ((paa.date_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_end is null)
		  )
		  or
		  ((paa.sickness_start_date between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.sickness_end_date > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.sickness_end_date is null)
		  )
		  or
	/* SSP absences which start in the new tax year */
	   	 (
	   	  paa.date_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
	      or paa.date_projected_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
		 )
	)
	/* Do not retrieve terminated employees whose actual termination dates have passed or are null */
	and not exists
	( select 1
	  from per_all_people_f ppf,
	  	   per_person_types ppt,
		   per_periods_of_service pps
	  where ppf.person_id = pps.person_id
	  and ppt.person_type_id = ppf.person_type_id
	  and ppt.system_person_type = 'EX_EMP'
	  and nvl(pps.actual_termination_date,to_date('01/01/0001','DD/MM/YYYY')) <= sysdate
	  and ppf.person_id = paa.person_id
          and pps.date_start = (select max(date_start)
                                from   per_periods_of_service pos
                                where  pos.person_id = pps.person_id)
          and ppf.effective_start_date >= pps.date_start
          and pps.date_start <= paa.sickness_start_date)
	order by nvl(paa.linked_absence_id,paa.absence_attendance_id);


cursor csr_affected_leave(p_leave_type IN VARCHAR2) is
       -- p_leave_type = 'MA' - Maternity, 'AD' - Adoption, 'PA' - Paternity Adoption, 'PB' - Paternity Birth
       select paa.maternity_id,
       	      paa.person_id,
              paa.date_start,
              paa.date_end,
              paa.date_projected_start,
              paa.date_projected_end
	from per_absence_attendances paa,
             ssp_maternities mat
        where paa.maternity_id = mat.maternity_id
        and   nvl(mat.leave_type, 'MA') = p_leave_type
	and
	   /* SMP absences which span tax years or start in old tax year and are open-ended */
	(
		  ((paa.date_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_end is null)
		  )
		  or
		  ((paa.date_projected_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_projected_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_projected_end is null)
                   and paa.date_start IS NULL -- use projected dates only when actual dates not available
		  )
		  or
	/* SMP absences which start in the new tax year */
	   	 (
	   	  paa.date_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
	          or (paa.date_projected_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
                      and paa.date_start IS NULL)  -- use projected dates only when actual dates not available
		 )
	)
	/* Do not retrieve employees whose final process dates have passed */
	and not exists
	( select 1
	  from per_all_people_f ppf,
	  	   per_person_types ppt,
		   per_periods_of_service pps
	  where ppf.person_id = pps.person_id
	  and ppt.person_type_id = ppf.person_type_id
	  and ppt.system_person_type = 'EX_EMP'
	  and pps.final_process_date <= sysdate
	  and ppf.person_id = paa.person_id
          and pps.date_start = (select max(date_start)
                                from   per_periods_of_service pos
                                where  pos.person_id = pps.person_id)
          and ppf.effective_start_date >= pps.date_start
          and pps.date_start <= paa.date_start)
    	/* Do not retrieve employees who are deceased */
    	and not exists
    	( select 1
    	  from per_all_people_f ppf,
    	       per_periods_of_service pps
    	  where ppf.person_id = pps.person_id
    	  and pps.leaving_reason = 'D'
    	  and ppf.person_id = paa.person_id)
      order by paa.maternity_id;


l_count	                NUMBER := 0;
l_mat_count             NUMBER := 0;
l_adop_count            NUMBER := 0;
l_pat_adop_count        NUMBER := 0;
l_pat_birth_count       NUMBER := 0;

e_ssp_rate_not_set      exception;
e_smp_rate_not_set      exception;
e_sap_rate_not_set      exception;
e_sppa_rate_not_set     exception;
e_sppb_rate_not_set     exception;

e_no_new_ssp_entry	exception;
e_no_new_smp_entry	exception;
e_no_new_sap_entry	exception;
e_no_new_sppa_entry	exception;
e_no_new_sppb_entry	exception;

l_update_error		boolean := FALSE;

/* Function to check if SSP entries in new tax year have already been updated  */
/* with new SSP rates and recalculated - returns TRUE if so, FALSE if not      */
function ssp_entries_already_updated return boolean is

cursor csr_new_ssp_rate is
		select piv.default_value
		from pay_input_values_f piv,
		pay_element_types_f petf
		where petf.element_type_id = piv.element_type_id
		and piv.name = 'Rate'
		and petf.element_name = 'Statutory Sick Pay'
		and piv.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate);


cursor csr_first_new_ssp_entry is
	select peev1.screen_entry_value
        from pay_element_entry_values_f peev1,
             pay_element_entry_values_f peev2,
             pay_input_values_f piv,
             pay_element_entries_f peef,
             pay_element_links_f pelf,
             pay_element_types_f petf
        where piv.input_value_id = peev1.input_value_id
        and peev1.element_entry_id = peev2.element_entry_id
        and peev1.element_entry_id = peef.element_entry_id
        and peef.element_link_id = pelf.element_link_id
        and pelf.element_type_id = petf.element_type_id
        and piv.name = 'Rate'
        and petf.element_name = 'Statutory Sick Pay'
        and piv.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate)
        and peev2.element_entry_value_id =
            (select peev3.element_entry_value_id
             from pay_element_entry_values_f peev3
             where input_value_id =
                  (select distinct input_value_id
                   from pay_input_values_f piv,
                        pay_element_types_f petf
                   where petf.element_type_id = piv.element_type_id
                   and petf.element_name = 'Statutory Sick Pay'
                   and piv.name = 'From')
            and peev3.screen_entry_value >
				fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate))
            /* Retrieve only those entries that will be retrieved by main SSP query */
            and peev3.element_entry_id in
				( select peef1.element_entry_id
			  	  from pay_element_entries_f   	peef1,
			  	   per_all_assignments_f   	paf,
				   per_all_people_f 	   	ppf,
				   per_person_types		ppt,
				   per_periods_of_service  	pps
			  	  where peef1.assignment_id = paf.assignment_id
	 	 	  	  and paf.person_id = ppf.person_id
	 	 	  	  and ppf.person_id = pps.person_id
	 	 	  	  and ppt.person_type_id = ppf.person_type_id
	 	 	  	  and peev3.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
				  	  			and fnd_date.date_to_canonical(ppf.effective_end_date)
	 	 	  	  and peev3.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
				  	  		    and fnd_date.date_to_canonical(paf.effective_end_date)
	 	 	  	  and ppt.system_person_type = 'EMP'
  	 	 	  	  and nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 	       		)
	    and rownum = 1);


l_new_SSP_rate          number;
l_first_SSP_entry_rate  number;



begin

hr_utility.trace('Entering ssp_entries_already_updated function');

/* Find SSP rate for new tax year */
open csr_new_ssp_rate;
fetch csr_new_ssp_rate into l_new_SSP_rate;

/* If unable to find new SSP rate, then rate probably not set yet */
/* Make note of this and exit quietly */
if csr_new_ssp_rate%notfound
then
    close csr_new_ssp_rate;
    raise e_ssp_rate_not_set;
end if;

close csr_new_ssp_rate;

hr_utility.trace('New SSP rate: '||l_new_SSP_rate);

/* Find first element entry value holding SSP rate for new tax year */
open csr_first_new_ssp_entry;
fetch csr_first_new_ssp_entry into l_first_SSP_entry_rate;

/* If unable to find SSP entry in new tax year, then warn user */
/* Possible causes are employee terminations or stoppages */
if csr_first_new_ssp_entry%notfound
then
   close csr_first_new_ssp_entry;
   raise e_no_new_ssp_entry;
end if;

close csr_first_new_ssp_entry;

hr_utility.trace('First SSP entry rate: '||l_first_SSP_entry_rate);

if l_new_SSP_rate = l_first_SSP_entry_rate
then

    return true;

else

    return false;

end if;

exception

when others
then raise;


end ssp_entries_already_updated;

/* Function to check if SMP entries in new tax year have already updated  */
/* with new SMP rates and recalculated - returns TRUE if so, FALSE if not */
function smp_rate_changed return boolean is

/* Check for SMP rates beginning on or after April 1st */
cursor csr_new_smp_rate is
       select petf.element_information10, petf.element_information9, petf.element_information16
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;


/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as smp rate therefore it can not be compared with new smp
                         rate to detect the change in smp rate. A new cursor
                         csr_old_smp_rate has been added to find old smp rate
                         and to compare it with new smp rate to detect the change.

cursor csr_first_new_smp_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_element_entry_values_f peev3,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peev3.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main SMP query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    and peev3.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Rate'))
    -- Rate restriction - only retrieve entries on LOW rate for SMP
    and upper(peev3.screen_entry_value) = upper('Low')
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/

cursor csr_old_smp_rate is
       select petf.element_information10, petf.element_information9, petf.element_information16
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;

l_new_SMP_rate              number;
l_old_SMP_rate              number;
l_new_high_smp_rate         number;
l_old_high_smp_rate         number;
l_new_std_smp_rate          number;
l_old_std_smp_rate          number;

begin

   hr_utility.trace('Entering smp_rate_changed function');
   --
   /* Find SMP rate for new tax year */
   open csr_new_smp_rate;
   fetch csr_new_smp_rate into l_new_SMP_rate, l_new_high_smp_rate, l_new_std_smp_rate;
   --
   /* If unable to find new SMP rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_SMP_rate%notfound
   then
       close csr_new_SMP_rate;
       raise e_SMP_rate_not_set;
   end if;
   --
   close csr_new_smp_rate;
   --
   hr_utility.trace('New Lower SMP rate: '||l_new_SMP_rate);
   hr_utility.trace('New Higher SMP rate: '||l_new_high_SMP_rate);
   hr_utility.trace('New Standard SMP rate: '||l_new_std_SMP_rate);
   --
   /* Find SMP rate for current tax year */
   open csr_old_smp_rate;
   fetch csr_old_smp_rate into l_old_SMP_rate, l_old_high_smp_rate, l_old_std_smp_rate;
   close csr_old_smp_rate;
   --
   hr_utility.trace('Old SMP rate: '||l_old_SMP_rate);
   hr_utility.trace('Old Higher SMP rate: '||l_old_high_SMP_rate);
   hr_utility.trace('Old Standard SMP rate: '||l_old_std_SMP_rate);
   --
   if (l_new_SMP_rate = l_old_smp_rate) and (l_new_high_smp_rate = l_old_high_smp_rate) and (l_new_std_smp_rate = l_old_std_smp_rate)
   then
       return false;
   else
       return true;
   end if;
   --
exception
   when others then
      raise;
end smp_rate_changed;


/* Function to check if SAP entries in new tax year have already updated  */
/* with new SAP rates and recalculated - returns TRUE if so, FALSE if not */
function sap_rate_changed return boolean is

   /* Check for SAP rates beginning on or after April 1st */
   cursor csr_new_sap_rate is
       select petf.element_information5, petf.element_information7
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as sap rate therefore it can not be compared with new sap
                         rate to detect the change in sap rate. A new cursor
                         csr_old_sap_rate has been added to find old sap rate
                         and to compare it with new sap rate to detect the change.

   cursor csr_first_new_sap_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main sap query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sap_rate is
       select petf.element_information5, petf.element_information7
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date < hr_gbnicar.uk_tax_yr_end(sysdate) - 4
       order by effective_start_date desc;
   --
   --
   l_new_sap_rate              number;
   l_old_sap_rate              number;
   --
   l_new_std_sap_rate              number;
   l_old_std_sap_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sap_rate_changed function');
   --
   /* Find sap rate for new tax year */
   open csr_new_sap_rate;
   fetch csr_new_sap_rate into l_new_sap_rate, l_new_std_sap_rate;
   --
   /* If unable to find new sap rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sap_rate%notfound then
      close csr_new_sap_rate;
      raise e_sap_rate_not_set;
   end if;
   --
   close csr_new_sap_rate;
   --
   hr_utility.trace('New sap rate: '||l_new_sap_rate);
   hr_utility.trace('New std sap rate: '||l_new_std_sap_rate);
   --
   /* Find sap rate for current tax year */
   open csr_old_sap_rate;
   fetch csr_old_sap_rate into l_old_sap_rate, l_old_std_sap_rate;
   close csr_old_sap_rate;
   --
   hr_utility.trace('Old sap rate: '||l_old_sap_rate);
   hr_utility.trace('Old std sap rate: '||l_old_std_sap_rate);
   --
   if (l_new_sap_rate = l_old_sap_rate) and (l_new_std_sap_rate = l_old_std_sap_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sap_rate_changed;

/* Function to check if SPPA entries in new tax year have already updated  */
/* with new SPPA rates and recalculated - returns TRUE if so, FALSE if not */
function sppa_rate_changed return boolean is

   /* Check for SPPA rates beginning on or after April 1st */
   cursor csr_new_sppa_rate is
       select petf.element_information6, petf.element_information8
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as SPP Adoption rate therefore it can not be compared with new
                         SPP Adoption rate to detect the change. A new cursor
                         csr_old_sppa_rate has been added to find old SPP Adoption  rate
                         and to compare it with new SPP Adoption rate to detect the change.

   cursor csr_first_new_sppa_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
      -- Retrieve only those entries that main sppa query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sppa_rate is
       select petf.element_information6, petf.element_information8
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;

   --
   l_new_sppa_rate              number;
   l_old_sppa_rate              number;
   --
   l_new_std_sppa_rate              number;
   l_old_std_sppa_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sppa_rate_changed function');
   --
   /* Find sppa rate for new tax year */
   open csr_new_sppa_rate;
   fetch csr_new_sppa_rate into l_new_sppa_rate, l_new_std_sppa_rate;
   --
   /* If unable to find new sppa rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sppa_rate%notfound then
      close csr_new_sppa_rate;
      raise e_sppa_rate_not_set;
   end if;
   --
   close csr_new_sppa_rate;
   --
   hr_utility.trace('New sppa rate: '||l_new_sppa_rate);
   hr_utility.trace('New std sppa rate: '||l_new_std_sppa_rate);
   --
   open csr_old_sppa_rate;
   fetch csr_old_sppa_rate into l_old_sppa_rate, l_old_std_sppa_rate;
   close csr_old_sppa_rate;
   --
   hr_utility.trace('Old SPPA rate: '||l_old_sppa_rate);
   hr_utility.trace('Old Std SPPA rate: '||l_old_std_sppa_rate);
   --
   if (l_new_sppa_rate = l_old_sppa_rate) and (l_new_std_sppa_rate = l_old_std_sppa_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sppa_rate_changed;

/* Function to check if SPPB entries in new tax year have already updated  */
/* with new SPPB rates and recalculated - returns TRUE if so, FALSE if not */
function sppb_rate_changed return boolean is

   /* Check for SPPB rates beginning on or after April 1st */
   cursor csr_new_sppb_rate is
       select petf.element_information6, petf.element_information9
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as SPP Birth rate therefore it can not be compared with new
                         SPP Birth rate to detect the change. A new cursor
                         csr_old_sppb_rate has been added to find old SPP Birth rate
                         and to compare it with new SPP Birth rate to detect the change.

   cursor csr_first_new_sppb_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main SPPB query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sppb_rate is
       select petf.element_information6, petf.element_information9
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;
   --
   l_new_sppb_rate              number;
   l_old_sppb_rate              number;
   --
   l_new_std_sppb_rate              number;
   l_old_std_sppb_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sppb_rate_changed function');
   --
   /* Find SPPB rate for new tax year */
   open csr_new_sppb_rate;
   fetch csr_new_sppb_rate into l_new_sppb_rate, l_new_std_sppb_rate;
   --
   /* If unable to find new SPPB rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sppb_rate%notfound then
      close csr_new_sppb_rate;
      raise e_sppb_rate_not_set;
   end if;
   --
   close csr_new_sppb_rate;
   --
   hr_utility.trace('New SPPB rate: '||l_new_sppb_rate);
   hr_utility.trace('New Std SPPB rate: '||l_new_Std_sppb_rate);
   --
   open csr_old_sppb_rate;
   fetch csr_old_sppb_rate into l_old_sppb_rate, l_old_std_sppb_rate;
   close csr_old_sppb_rate;
   --
   hr_utility.trace('old SPPB rate: '||l_old_sppb_rate);
   hr_utility.trace('old Std SPPB rate: '||l_old_Std_sppb_rate);
   --
   if (l_new_sppb_rate = l_old_sppb_rate) and (l_new_std_sppb_rate = l_old_std_sppb_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sppb_rate_changed;

/* Main program body */
begin

hr_utility.trace('Entering: '||g_package||'.update_ssp_smp_entries');

savepoint pre_update_status;
/* Check first whether SSP element entries already updated for new tax year */
/* SSP update block */
begin

  savepoint pre_ssp_update_status;

  if not ssp_entries_already_updated
  then

      hr_utility.trace('SSP element entries not updated, updating ....');

      for r_affected_absences in csr_affected_absences loop

	   /* SSP control call block */
	   begin

	   hr_utility.trace('Processing SSP absence: '||r_affected_absences.absence_id);

	   ssp_ssp_pkg.ssp_control(r_affected_absences.absence_id);

	   l_count := l_count + 1;

	   exception

	     when others then
	      hr_utility.trace('Error occurred while processing SSP absence: '||r_affected_absences.absence_id);
	      hr_utility.trace('SQL error code: '||SQLCODE);
	      hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
	      hr_utility.trace('Person id: '||r_affected_absences.person_id);
	      hr_utility.trace('Absence start date: '||r_affected_absences.absence_start_date);
	      hr_utility.trace('Absence end date: '||r_affected_absences.absence_end_date);
	      l_update_error := true;

	   end;



      end loop;

      hr_utility.trace('Updated entries for '||l_count||' absences');

   else

    hr_utility.trace('SSP element entries already updated for new tax year');

   end if;

   commit;

   exception

     when e_ssp_rate_not_set
     then
       hr_utility.trace('Warning: SSP rate for new tax year not set');
       hr_utility.trace('Unable to proceed with updating SSP entries');


     when e_no_new_ssp_entry
     then
       hr_utility.trace('Warning: Unable to locate SSP entry in new tax year');
       hr_utility.trace('Entries for SSP absences in new tax year may be non-existent');
       hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end dates of absences');

     when others
     then
       hr_utility.trace('Unexpected error occurred inside SSP update block');
       hr_utility.trace('SQL error number: '||SQLCODE);
       hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
       rollback to pre_ssp_update_status;
       l_update_error := true;

   end; /* SSP update block */

/* Now check SMP entries to see if they have been updated */
/* SMP update block */
-- 05/12/2003 rmakhija: Uncommented following section for TYE 2003/4
   begin
     --
     savepoint pre_smp_update_status;
     --
     if smp_rate_changed then
       --
       hr_utility.trace('SMP element entries updating ....');
       for r_affected_maternities in csr_affected_leave('MA') loop
          /* SMP Control call block */
          begin
             hr_utility.trace('Processing SMP absence: '||r_affected_maternities.maternity_id);
             ssp_smp_pkg.smp_control(p_maternity_id => r_affected_maternities.maternity_id,
                                     p_deleting => FALSE);
             l_mat_count := l_mat_count + 1;
          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SMP absence: '||r_affected_maternities.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_maternities.person_id);
   	        hr_utility.trace('Maternity start date: '||r_affected_maternities.date_start);
   	        hr_utility.trace('Maternity end date: '||r_affected_maternities.date_end);
   	        hr_utility.trace('Maternity projected start date: '||r_affected_maternities.date_projected_start);
   	        hr_utility.trace('Maternity projected end date: '||r_affected_maternities.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_mat_count||' maternities');
     else
        hr_utility.trace('SMP element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_smp_rate_not_set then
          hr_utility.trace('Warning: SMP rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SMP entries');
        when e_no_new_smp_entry then
          hr_utility.trace('Warning: Unable to locate SMP entry in new tax year');
          hr_utility.trace('Entries for SMP absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SMP update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_smp_update_status;
          l_update_error := true;
   end; /* SMP update block */
   -- 05/12/2003 rmakhija: Uncommented section ends here
   -- Following code has been added to auto update SAP/SPP Adoption/SPP Birth element entries
   -- Begin SAP Update Block
   BEGIN
     --
     savepoint pre_sap_update_status;
     --
     if sap_rate_changed then
       --
       hr_utility.trace('SAP element entries updating ....');
       for r_affected_adoption in csr_affected_leave('AD') loop
          /* SAP Control call block */
          begin
             hr_utility.trace('Processing SAP absence: '||r_affected_adoption.maternity_id);
             ssp_sap_pkg.sap_control(p_maternity_id => r_affected_adoption.maternity_id,
                                     p_deleting => FALSE);
             l_adop_count := l_adop_count + 1;
          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SAP absence: '||r_affected_adoption.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_adoption.person_id);
   	        hr_utility.trace('Adoption start date: '||r_affected_adoption.date_start);
   	        hr_utility.trace('Adoption end date: '||r_affected_adoption.date_end);
   	        hr_utility.trace('Adoption projected start date: '||r_affected_adoption.date_projected_start);
   	        hr_utility.trace('Adoption projected end date: '||r_affected_adoption.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_adop_count||' adoptions');
     else
        hr_utility.trace('SAP element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sap_rate_not_set then
          hr_utility.trace('Warning: SAP rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SAP entries');
        when e_no_new_sap_entry then
          hr_utility.trace('Warning: Unable to locate SAP entry in new tax year');
          hr_utility.trace('Entries for SAP absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SAP update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sap_update_status;
          l_update_error := true;
   end; /* SAP update block */
   -- Begin SPP Adoption Update Block
   BEGIN
     --
     savepoint pre_sppa_update_status;
     --
     if sppa_rate_changed then
       --
       hr_utility.trace('SPP Adoption element entries updating ....');
       for r_affected_pat_adop in csr_affected_leave('PA') loop
          /* SPP Adoption Control call block */
          begin
             hr_utility.trace('Processing SPP Adoption absence: '||r_affected_pat_adop.maternity_id);
             ssp_pad_pkg.pad_control(p_maternity_id => r_affected_pat_adop.maternity_id,
                                     p_deleting => FALSE);
             l_pat_adop_count := l_pat_adop_count + 1;
          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SPP Adoption absence: '||r_affected_pat_adop.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_pat_adop.person_id);
   	        hr_utility.trace('Paternity Adoption start date: '||r_affected_pat_adop.date_start);
   	        hr_utility.trace('Paternity Adoption end date: '||r_affected_pat_adop.date_end);
   	        hr_utility.trace('Paternity Adoption projected start date: '||r_affected_pat_adop.date_projected_start);
   	        hr_utility.trace('Paternity Adoption projected end date: '||r_affected_pat_adop.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_pat_adop_count||' paternity adoptions');
     else
        hr_utility.trace('SPP Adoption element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sppa_rate_not_set then
          hr_utility.trace('Warning: SPP ADoption rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SPP ADoption entries');
        when e_no_new_sppa_entry then
          hr_utility.trace('Warning: Unable to locate SPP ADoption entry in new tax year');
          hr_utility.trace('Entries for SPP ADoption absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SPP ADoption update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sppa_update_status;
          l_update_error := true;
   end; /* SPP Adoption update block */
   -- Begin SPP Birth Update Block
   BEGIN
     --
     savepoint pre_sppb_update_status;
     --
     if sppb_rate_changed then
       --
       hr_utility.trace('SPP Birth element entries updating ....');
       for r_affected_pat_Birth in csr_affected_leave('PB') loop
          /* SPP Birth Control call block */
          begin
             hr_utility.trace('Processing SPP Birth absence: '||r_affected_pat_Birth.maternity_id);
             ssp_pab_pkg.pab_control(p_maternity_id => r_affected_pat_Birth.maternity_id,
                                     p_deleting => FALSE);
             l_pat_Birth_count := l_pat_birth_count + 1;
          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SPP Birth absence: '||r_affected_pat_Birth.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_pat_Birth.person_id);
   	        hr_utility.trace('Paternity Birth start date: '||r_affected_pat_Birth.date_start);
   	        hr_utility.trace('Paternity Birth end date: '||r_affected_pat_Birth.date_end);
   	        hr_utility.trace('Paternity Birth projected start date: '||r_affected_pat_Birth.date_projected_start);
   	        hr_utility.trace('Paternity Birth projected end date: '||r_affected_pat_Birth.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_pat_birth_count||' paternity births');
     else
        hr_utility.trace('SPP Birth element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sppb_rate_not_set then
          hr_utility.trace('Warning: SPP Birth rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SPP Birth entries');
        when e_no_new_sppb_entry then
          hr_utility.trace('Warning: Unable to locate SPP Birth entry in new tax year');
          hr_utility.trace('Entries for SPP Birth absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SPP Birth update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sppb_update_status;
          l_update_error := true;
   end; /* SPP Birth update block */

hr_utility.trace('Update of SSP, SMP, SAP, SPP Adoption and SPP Birth entries complete');

p_update_error := l_update_error;

hr_utility.trace('Leaving: '||g_package||'.update_ssp_smp_entries');


exception


when others
then
    hr_utility.trace('Unexpected error occurred inside SSP/SMP element entries update procedure');
    hr_utility.trace('SQL error number: '||SQLCODE);
    hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
    rollback to pre_update_status;
    p_update_error := true;




end update_ssp_smp_entries;

--------------------------------------------------------------------------------
--
procedure update_ssp_smp_entries (P_UPDATE_ERROR OUT NOCOPY boolean, p_job_err OUT  NOCOPY l_job_err_typ) is


cursor csr_affected_absences is
	select nvl(paa.linked_absence_id,paa.absence_attendance_id) as absence_id,
	       paa.person_id,
	       nvl(paa.date_start,paa.sickness_start_date) as absence_start_date,
	       nvl(paa.date_end,paa.sickness_end_date) as absence_end_date
	from per_absence_attendances paa,
	     per_absence_attendance_types paat
	where paa.absence_attendance_type_id = paat.absence_attendance_type_id
	and paat.absence_category = 'S'
	and
	/* SSP absences which span tax years or start in old tax year and are open-ended */
	(
		  ((paa.date_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_end is null)
		  )
		  or
		  ((paa.sickness_start_date between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.sickness_end_date > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.sickness_end_date is null)
		  )
		  or
	/* SSP absences which start in the new tax year */
	   	 (
	   	  paa.date_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
	      or paa.date_projected_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
		 )
	)
	/* Do not retrieve terminated employees whose actual termination dates have passed or are null */
	and not exists
	( select 1
	  from per_all_people_f ppf,
	  	   per_person_types ppt,
		   per_periods_of_service pps
	  where ppf.person_id = pps.person_id
	  and ppt.person_type_id = ppf.person_type_id
	  and ppt.system_person_type = 'EX_EMP'
	  and nvl(pps.actual_termination_date,to_date('01/01/0001','DD/MM/YYYY')) <= sysdate
	  and ppf.person_id = paa.person_id
          and pps.date_start = (select max(date_start)
                                from   per_periods_of_service pos
                                where  pos.person_id = pps.person_id)
          and ppf.effective_start_date >= pps.date_start
          and pps.date_start <= paa.sickness_start_date)
	order by nvl(paa.linked_absence_id,paa.absence_attendance_id);


cursor csr_affected_leave(p_leave_type IN VARCHAR2) is
       -- p_leave_type = 'MA' - Maternity, 'AD' - Adoption, 'PA' - Paternity Adoption, 'PB' - Paternity Birth
       select paa.maternity_id,
       	      paa.person_id,
              paa.date_start,
              paa.date_end,
              paa.date_projected_start,
              paa.date_projected_end
	from per_absence_attendances paa,
             ssp_maternities mat
        where paa.maternity_id = mat.maternity_id
        and   nvl(mat.leave_type, 'MA') = p_leave_type
	and
	   /* SMP absences which span tax years or start in old tax year and are open-ended */
	(
		  ((paa.date_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_end is null)
		  )
		  or
		  ((paa.date_projected_start between hr_gbnicar.uk_tax_yr_start(sysdate) and hr_gbnicar.uk_tax_yr_end(sysdate))
		   and (paa.date_projected_end > hr_gbnicar.uk_tax_yr_end(sysdate) or paa.date_projected_end is null)
                   and paa.date_start IS NULL -- use projected dates only when actual dates not available
		  )
		  or
	/* SMP absences which start in the new tax year */
	   	 (
	   	  paa.date_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
	          or (paa.date_projected_start >= hr_gbnicar.uk_tax_yr_end(sysdate)
                      and paa.date_start IS NULL)  -- use projected dates only when actual dates not available
		 )
	)
	/* Do not retrieve employees whose final process dates have passed */
	and not exists
	( select 1
	  from per_all_people_f ppf,
	  	   per_person_types ppt,
		   per_periods_of_service pps
	  where ppf.person_id = pps.person_id
	  and ppt.person_type_id = ppf.person_type_id
	  and ppt.system_person_type = 'EX_EMP'
	  and pps.final_process_date <= sysdate
	  and ppf.person_id = paa.person_id
          and pps.date_start = (select max(date_start)
                                from   per_periods_of_service pos
                                where  pos.person_id = pps.person_id)
          and ppf.effective_start_date >= pps.date_start
          and pps.date_start <= paa.date_start)
    	/* Do not retrieve employees who are deceased */
    	and not exists
    	( select 1
    	  from per_all_people_f ppf,
    	       per_periods_of_service pps
    	  where ppf.person_id = pps.person_id
    	  and pps.leaving_reason = 'D'
    	  and ppf.person_id = paa.person_id)
      order by paa.maternity_id;


l_count	                NUMBER := 0;
l_mat_count             NUMBER := 0;
l_adop_count            NUMBER := 0;
l_pat_adop_count        NUMBER := 0;
l_pat_birth_count       NUMBER := 0;

e_ssp_rate_not_set      exception;
e_smp_rate_not_set      exception;
e_sap_rate_not_set      exception;
e_sppa_rate_not_set     exception;
e_sppb_rate_not_set     exception;

e_no_new_ssp_entry	exception;
e_no_new_smp_entry	exception;
e_no_new_sap_entry	exception;
e_no_new_sppa_entry	exception;
e_no_new_sppb_entry	exception;

l_update_error		boolean := FALSE;

--6800788 begin
l_fail  number;
l_fail_count number :=0;
l_job_no binary_integer;
Type l_job_type is record
(
Job_no number,
Person_id number,
Absence_id number
);
Type l_tbl_job_typ  is table of l_job_type index by binary_integer;
l_tbl_job l_tbl_job_typ;
--6800788 end

/* Function to check if SSP entries in new tax year have already been updated  */
/* with new SSP rates and recalculated - returns TRUE if so, FALSE if not      */
function ssp_entries_already_updated return boolean is

cursor csr_new_ssp_rate is
		select piv.default_value
		from pay_input_values_f piv,
		pay_element_types_f petf
		where petf.element_type_id = piv.element_type_id
		and piv.name = 'Rate'
		and petf.element_name = 'Statutory Sick Pay'
		and piv.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate);


cursor csr_first_new_ssp_entry is
	select peev1.screen_entry_value
        from pay_element_entry_values_f peev1,
             pay_element_entry_values_f peev2,
             pay_input_values_f piv,
             pay_element_entries_f peef,
             pay_element_links_f pelf,
             pay_element_types_f petf
        where piv.input_value_id = peev1.input_value_id
        and peev1.element_entry_id = peev2.element_entry_id
        and peev1.element_entry_id = peef.element_entry_id
        and peef.element_link_id = pelf.element_link_id
        and pelf.element_type_id = petf.element_type_id
        and piv.name = 'Rate'
        and petf.element_name = 'Statutory Sick Pay'
        and piv.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate)
        and peev2.element_entry_value_id =
            (select peev3.element_entry_value_id
             from pay_element_entry_values_f peev3
             where input_value_id =
                  (select distinct input_value_id
                   from pay_input_values_f piv,
                        pay_element_types_f petf
                   where petf.element_type_id = piv.element_type_id
                   and petf.element_name = 'Statutory Sick Pay'
                   and piv.name = 'From')
            and peev3.screen_entry_value >
				fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate))
            /* Retrieve only those entries that will be retrieved by main SSP query */
            and peev3.element_entry_id in
				( select peef1.element_entry_id
			  	  from pay_element_entries_f   	peef1,
			  	   per_all_assignments_f   	paf,
				   per_all_people_f 	   	ppf,
				   per_person_types		ppt,
				   per_periods_of_service  	pps
			  	  where peef1.assignment_id = paf.assignment_id
	 	 	  	  and paf.person_id = ppf.person_id
	 	 	  	  and ppf.person_id = pps.person_id
	 	 	  	  and ppt.person_type_id = ppf.person_type_id
	 	 	  	  and peev3.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
				  	  			and fnd_date.date_to_canonical(ppf.effective_end_date)
	 	 	  	  and peev3.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
				  	  		    and fnd_date.date_to_canonical(paf.effective_end_date)
	 	 	  	  and ppt.system_person_type = 'EMP'
  	 	 	  	  and nvl(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 	       		)
	    and rownum = 1);


l_new_SSP_rate          number;
l_first_SSP_entry_rate  number;



begin

hr_utility.trace('Entering ssp_entries_already_updated function');

/* Find SSP rate for new tax year */
open csr_new_ssp_rate;
fetch csr_new_ssp_rate into l_new_SSP_rate;

/* If unable to find new SSP rate, then rate probably not set yet */
/* Make note of this and exit quietly */
if csr_new_ssp_rate%notfound
then
    close csr_new_ssp_rate;
    raise e_ssp_rate_not_set;
end if;

close csr_new_ssp_rate;

hr_utility.trace('New SSP rate: '||l_new_SSP_rate);

/* Find first element entry value holding SSP rate for new tax year */
open csr_first_new_ssp_entry;
fetch csr_first_new_ssp_entry into l_first_SSP_entry_rate;

/* If unable to find SSP entry in new tax year, then warn user */
/* Possible causes are employee terminations or stoppages */
if csr_first_new_ssp_entry%notfound
then
   close csr_first_new_ssp_entry;
   raise e_no_new_ssp_entry;
end if;

close csr_first_new_ssp_entry;

hr_utility.trace('First SSP entry rate: '||l_first_SSP_entry_rate);

if l_new_SSP_rate = l_first_SSP_entry_rate
then

    return true;

else

    return false;

end if;

exception

when others
then raise;


end ssp_entries_already_updated;

/* Function to check if SMP entries in new tax year have already updated  */
/* with new SMP rates and recalculated - returns TRUE if so, FALSE if not */
function smp_rate_changed return boolean is

/* Check for SMP rates beginning on or after April 1st */
cursor csr_new_smp_rate is
       select petf.element_information10, petf.element_information9, petf.element_information16
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;


/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as smp rate therefore it can not be compared with new smp
                         rate to detect the change in smp rate. A new cursor
                         csr_old_smp_rate has been added to find old smp rate
                         and to compare it with new smp rate to detect the change.

cursor csr_first_new_smp_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_element_entry_values_f peev3,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peev3.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main SMP query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    and peev3.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Rate'))
    -- Rate restriction - only retrieve entries on LOW rate for SMP
    and upper(peev3.screen_entry_value) = upper('Low')
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/

cursor csr_old_smp_rate is
       select petf.element_information10, petf.element_information9, petf.element_information16
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Maternity Pay'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;

l_new_SMP_rate              number;
l_old_SMP_rate              number;
l_new_high_smp_rate         number;
l_old_high_smp_rate         number;
l_new_std_smp_rate          number;
l_old_std_smp_rate          number;

begin

   hr_utility.trace('Entering smp_rate_changed function');
   --
   /* Find SMP rate for new tax year */
   open csr_new_smp_rate;
   fetch csr_new_smp_rate into l_new_SMP_rate, l_new_high_smp_rate, l_new_std_smp_rate;
   --
   /* If unable to find new SMP rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_SMP_rate%notfound
   then
       close csr_new_SMP_rate;
       raise e_SMP_rate_not_set;
   end if;
   --
   close csr_new_smp_rate;
   --
   hr_utility.trace('New Lower SMP rate: '||l_new_SMP_rate);
   hr_utility.trace('New Higher SMP rate: '||l_new_high_SMP_rate);
   hr_utility.trace('New Standard SMP rate: '||l_new_std_SMP_rate);
   --
   /* Find SMP rate for current tax year */
   open csr_old_smp_rate;
   fetch csr_old_smp_rate into l_old_SMP_rate, l_old_high_smp_rate, l_old_std_smp_rate;
   close csr_old_smp_rate;
   --
   hr_utility.trace('Old SMP rate: '||l_old_SMP_rate);
   hr_utility.trace('Old Higher SMP rate: '||l_old_high_SMP_rate);
   hr_utility.trace('Old Standard SMP rate: '||l_old_std_SMP_rate);
   --
   if (l_new_SMP_rate = l_old_smp_rate) and (l_new_high_smp_rate = l_old_high_smp_rate) and (l_new_std_smp_rate = l_old_std_smp_rate)
   then
       return false;
   else
       return true;
   end if;
   --
exception
   when others then
      raise;
end smp_rate_changed;


/* Function to check if SAP entries in new tax year have already updated  */
/* with new SAP rates and recalculated - returns TRUE if so, FALSE if not */
function sap_rate_changed return boolean is

   /* Check for SAP rates beginning on or after April 1st */
   cursor csr_new_sap_rate is
       select petf.element_information5, petf.element_information7
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as sap rate therefore it can not be compared with new sap
                         rate to detect the change in sap rate. A new cursor
                         csr_old_sap_rate has been added to find old sap rate
                         and to compare it with new sap rate to detect the change.

   cursor csr_first_new_sap_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main sap query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sap_rate is
       select petf.element_information5, petf.element_information7
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Adoption Pay'
       and petf.effective_start_date < hr_gbnicar.uk_tax_yr_end(sysdate) - 4
       order by effective_start_date desc;
   --
   --
   l_new_sap_rate              number;
   l_old_sap_rate              number;
   --
   l_new_std_sap_rate              number;
   l_old_std_sap_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sap_rate_changed function');
   --
   /* Find sap rate for new tax year */
   open csr_new_sap_rate;
   fetch csr_new_sap_rate into l_new_sap_rate, l_new_std_sap_rate;
   --
   /* If unable to find new sap rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sap_rate%notfound then
      close csr_new_sap_rate;
      raise e_sap_rate_not_set;
   end if;
   --
   close csr_new_sap_rate;
   --
   hr_utility.trace('New sap rate: '||l_new_sap_rate);
   hr_utility.trace('New std sap rate: '||l_new_std_sap_rate);
   --
   /* Find sap rate for current tax year */
   open csr_old_sap_rate;
   fetch csr_old_sap_rate into l_old_sap_rate, l_old_std_sap_rate;
   close csr_old_sap_rate;
   --
   hr_utility.trace('Old sap rate: '||l_old_sap_rate);
   hr_utility.trace('Old std sap rate: '||l_old_std_sap_rate);
   --
   if (l_new_sap_rate = l_old_sap_rate) and (l_new_std_sap_rate = l_old_std_sap_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sap_rate_changed;

/* Function to check if SPPA entries in new tax year have already updated  */
/* with new SPPA rates and recalculated - returns TRUE if so, FALSE if not */
function sppa_rate_changed return boolean is

   /* Check for SPPA rates beginning on or after April 1st */
   cursor csr_new_sppa_rate is
       select petf.element_information6, petf.element_information8
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as SPP Adoption rate therefore it can not be compared with new
                         SPP Adoption rate to detect the change. A new cursor
                         csr_old_sppa_rate has been added to find old SPP Adoption  rate
                         and to compare it with new SPP Adoption rate to detect the change.

   cursor csr_first_new_sppa_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
      -- Retrieve only those entries that main sppa query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sppa_rate is
       select petf.element_information6, petf.element_information8
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Adoption'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;

   --
   l_new_sppa_rate              number;
   l_old_sppa_rate              number;
   --
   l_new_std_sppa_rate              number;
   l_old_std_sppa_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sppa_rate_changed function');
   --
   /* Find sppa rate for new tax year */
   open csr_new_sppa_rate;
   fetch csr_new_sppa_rate into l_new_sppa_rate, l_new_std_sppa_rate;
   --
   /* If unable to find new sppa rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sppa_rate%notfound then
      close csr_new_sppa_rate;
      raise e_sppa_rate_not_set;
   end if;
   --
   close csr_new_sppa_rate;
   --
   hr_utility.trace('New sppa rate: '||l_new_sppa_rate);
   hr_utility.trace('New std sppa rate: '||l_new_std_sppa_rate);
   --
   open csr_old_sppa_rate;
   fetch csr_old_sppa_rate into l_old_sppa_rate, l_old_std_sppa_rate;
   close csr_old_sppa_rate;
   --
   hr_utility.trace('Old SPPA rate: '||l_old_sppa_rate);
   hr_utility.trace('Old Std SPPA rate: '||l_old_std_sppa_rate);
   --
   if (l_new_sppa_rate = l_old_sppa_rate) and (l_new_std_sppa_rate = l_old_std_sppa_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sppa_rate_changed;

/* Function to check if SPPB entries in new tax year have already updated  */
/* with new SPPB rates and recalculated - returns TRUE if so, FALSE if not */
function sppb_rate_changed return boolean is

   /* Check for SPPB rates beginning on or after April 1st */
   cursor csr_new_sppb_rate is
       select petf.element_information6, petf.element_information9
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date >= trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date;
   --
/* 09/12/2003 rmakhija - commented out following cursor because element entry value
                         for 'Amount' is a calculated value and it is not same
                         as SPP Birth rate therefore it can not be compared with new
                         SPP Birth rate to detect the change. A new cursor
                         csr_old_sppb_rate has been added to find old SPP Birth rate
                         and to compare it with new SPP Birth rate to detect the change.

   cursor csr_first_new_sppb_entry is
       select peev1.screen_entry_value
       from pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2,
            pay_input_values_f piv,
            pay_element_entries_f peef,
            pay_element_links_f pelf,
            pay_element_types_f petf
       where piv.input_value_id = peev1.input_value_id
       and peev1.element_entry_id = peev2.element_entry_id
       and peev1.element_entry_id = peef.element_entry_id
       and peef.element_link_id = pelf.element_link_id
       and pelf.element_type_id = petf.element_type_id
       and piv.name = 'Amount'
       and petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date > hr_gbnicar.uk_tax_yr_end(sysdate) - 5
       -- Time restriction - only rows after tax year end
       and peev2.input_value_id =
                   (select input_value_id
                    from pay_input_values_f piv
                    where petf.element_type_id = piv.element_type_id
                    and upper(piv.name) = upper('Week commencing')
		   )
       and peev2.screen_entry_value > fnd_date.date_to_canonical(hr_gbnicar.uk_tax_yr_end(sysdate) - 5)
       -- Retrieve only those entries that main SPPB query will retrieve
       and exists
	  ( select 1
	    from per_all_assignments_f   paf,
		 per_all_people_f 	 ppf,
		 per_person_types  	 ppt,
		 per_periods_of_service  pps
	    where peef.assignment_id = paf.assignment_id
 	    and paf.person_id = ppf.person_id
 	    and ppf.person_id = pps.person_id
 	    and ppt.person_type_id = ppf.person_type_id
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(ppf.effective_start_date)
			  	  		and fnd_date.date_to_canonical(ppf.effective_end_date)
 	    and peev2.screen_entry_value between fnd_date.date_to_canonical(paf.effective_start_date)
			  	  	    and fnd_date.date_to_canonical(paf.effective_end_date)
 	    and nvl(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY')) >= sysdate
	 )
    -- Get first row that matches all of the above criteria
    and rownum = 1;
*/
   --
   cursor csr_old_sppb_rate is
       select petf.element_information6, petf.element_information9
       from pay_element_types_f petf
       where petf.element_name = 'Statutory Paternity Pay Birth'
       and petf.effective_start_date < trunc(hr_gbnicar.uk_tax_yr_end(sysdate)) - 4
       order by effective_start_date desc;
   --
   l_new_sppb_rate              number;
   l_old_sppb_rate              number;
   --
   l_new_std_sppb_rate              number;
   l_old_std_sppb_rate              number;
   --
begin
   --
   hr_utility.trace('Entering sppb_rate_changed function');
   --
   /* Find SPPB rate for new tax year */
   open csr_new_sppb_rate;
   fetch csr_new_sppb_rate into l_new_sppb_rate, l_new_std_sppb_rate;
   --
   /* If unable to find new SPPB rate, then rate probably not set yet */
   /* Make note of this and exit quietly */
   if csr_new_sppb_rate%notfound then
      close csr_new_sppb_rate;
      raise e_sppb_rate_not_set;
   end if;
   --
   close csr_new_sppb_rate;
   --
   hr_utility.trace('New SPPB rate: '||l_new_sppb_rate);
   hr_utility.trace('New Std SPPB rate: '||l_new_Std_sppb_rate);
   --
   open csr_old_sppb_rate;
   fetch csr_old_sppb_rate into l_old_sppb_rate, l_old_std_sppb_rate;
   close csr_old_sppb_rate;
   --
   hr_utility.trace('old SPPB rate: '||l_old_sppb_rate);
   hr_utility.trace('old Std SPPB rate: '||l_old_Std_sppb_rate);
   --
   if (l_new_sppb_rate = l_old_sppb_rate) and (l_new_std_sppb_rate = l_old_std_sppb_rate) then
      return false;
   else
      return true;
   end if;
   --
exception
   when others then raise;
end sppb_rate_changed;

/* Main program body */
begin

hr_utility.trace('Entering: '||g_package||'.update_ssp_smp_entries');

savepoint pre_update_status;
/* Check first whether SSP element entries already updated for new tax year */
/* SSP update block */
begin

  savepoint pre_ssp_update_status;

  if not ssp_entries_already_updated
  then

      hr_utility.trace('SSP element entries not updated, updating ....');

      for r_affected_absences in csr_affected_absences loop

	   /* SSP control call block */
	   begin

	   hr_utility.trace('Processing SSP absence: '||r_affected_absences.absence_id);
               --6800788 begin
	   --ssp_ssp_pkg.ssp_control(r_affected_absences.absence_id);
	   DBMS_JOB.SUBMIT(l_job_no,'ssp_ssp_pkg.ssp_control('||r_affected_absences.absence_id||');');
	   l_count := l_count + 1;
	   l_tbl_job(l_count).job_no := l_job_no;
	   l_tbl_job(l_count).person_id := r_affected_absences.person_id;
	   l_tbl_job(l_count).absence_id := r_affected_absences.absence_id;
	      if mod(l_count,500) = 0 then
	        commit;
              end if;
   	    --6800788 end
	   exception

	     when others then
	      hr_utility.trace('Error occurred while processing SSP absence: '||r_affected_absences.absence_id);
	      hr_utility.trace('SQL error code: '||SQLCODE);
	      hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
	      hr_utility.trace('Person id: '||r_affected_absences.person_id);
	      hr_utility.trace('Absence start date: '||r_affected_absences.absence_start_date);
	      hr_utility.trace('Absence end date: '||r_affected_absences.absence_end_date);
	      l_update_error := true;

	   end;



      end loop;

      hr_utility.trace('Updated entries for '||l_count||' absences');
--      dbms_output.put_line(' Total SSP absences ='|| l_count);
   else

    hr_utility.trace('SSP element entries already updated for new tax year');

   end if;

   commit;

   exception

     when e_ssp_rate_not_set
     then
       hr_utility.trace('Warning: SSP rate for new tax year not set');
       hr_utility.trace('Unable to proceed with updating SSP entries');


     when e_no_new_ssp_entry
     then
       hr_utility.trace('Warning: Unable to locate SSP entry in new tax year');
       hr_utility.trace('Entries for SSP absences in new tax year may be non-existent');
       hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end dates of absences');

     when others
     then
       hr_utility.trace('Unexpected error occurred inside SSP update block');
       hr_utility.trace('SQL error number: '||SQLCODE);
       hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
       rollback to pre_ssp_update_status;
       l_update_error := true;

   end; /* SSP update block */

/* Now check SMP entries to see if they have been updated */
/* SMP update block */
-- 05/12/2003 rmakhija: Uncommented following section for TYE 2003/4
   begin
     --
     savepoint pre_smp_update_status;
     --
     if smp_rate_changed then
       --
       hr_utility.trace('SMP element entries updating ....');
       for r_affected_maternities in csr_affected_leave('MA') loop
          /* SMP Control call block */
          begin
             hr_utility.trace('Processing SMP absence: '||r_affected_maternities.maternity_id);
           --6800788 begin
      --       ssp_smp_pkg.smp_control(p_maternity_id => r_affected_maternities.maternity_id,
      --                               p_deleting => FALSE);

	   DBMS_JOB.SUBMIT(l_job_no,'ssp_smp_pkg.smp_control('||r_affected_maternities.maternity_id||',FALSE);');
	   l_mat_count := l_mat_count + 1;
	   l_count := l_count + 1;
	   l_tbl_job(l_count).job_no := l_job_no;
	   l_tbl_job(l_count).person_id := r_affected_maternities.person_id;
	   l_tbl_job(l_count).absence_id := r_affected_maternities.maternity_id;
	   	   if mod(l_count,500) = 0 then
		        commit;
		   end if;
   	    --6800788 end

          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SMP absence: '||r_affected_maternities.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_maternities.person_id);
   	        hr_utility.trace('Maternity start date: '||r_affected_maternities.date_start);
   	        hr_utility.trace('Maternity end date: '||r_affected_maternities.date_end);
   	        hr_utility.trace('Maternity projected start date: '||r_affected_maternities.date_projected_start);
   	        hr_utility.trace('Maternity projected end date: '||r_affected_maternities.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_mat_count||' maternities');
--       dbms_output.put_line(' Total SMP absences ='|| l_mat_count);
     else
        hr_utility.trace('SMP element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_smp_rate_not_set then
          hr_utility.trace('Warning: SMP rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SMP entries');
        when e_no_new_smp_entry then
          hr_utility.trace('Warning: Unable to locate SMP entry in new tax year');
          hr_utility.trace('Entries for SMP absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SMP update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_smp_update_status;
          l_update_error := true;
   end; /* SMP update block */
   -- 05/12/2003 rmakhija: Uncommented section ends here
   -- Following code has been added to auto update SAP/SPP Adoption/SPP Birth element entries
   -- Begin SAP Update Block
   BEGIN
     --
     savepoint pre_sap_update_status;
     --
     if sap_rate_changed then
       --
       hr_utility.trace('SAP element entries updating ....');
       for r_affected_adoption in csr_affected_leave('AD') loop
          /* SAP Control call block */
          begin
             hr_utility.trace('Processing SAP absence: '||r_affected_adoption.maternity_id);
	 --6800788 begin
      --       ssp_sap_pkg.sap_control(p_maternity_id => r_affected_adoption.maternity_id,
--                                     p_deleting => FALSE);

          DBMS_JOB.SUBMIT(l_job_no,'ssp_sap_pkg.sap_control('||r_affected_adoption.maternity_id||',FALSE);');
          l_adop_count := l_adop_count + 1;
	     l_count := l_count + 1;
	     l_tbl_job(l_count).job_no := l_job_no;
	     l_tbl_job(l_count).person_id := r_affected_adoption.person_id;
	     l_tbl_job(l_count).absence_id := r_affected_adoption.maternity_id;
	       if mod(l_count,500) = 0 then
	        commit;
              end if;
   	      --6800788 end

          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SAP absence: '||r_affected_adoption.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_adoption.person_id);
   	        hr_utility.trace('Adoption start date: '||r_affected_adoption.date_start);
   	        hr_utility.trace('Adoption end date: '||r_affected_adoption.date_end);
   	        hr_utility.trace('Adoption projected start date: '||r_affected_adoption.date_projected_start);
   	        hr_utility.trace('Adoption projected end date: '||r_affected_adoption.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_adop_count||' adoptions');
--       dbms_output.put_line(' Total SAP absences ='|| l_adop_count);
     else
        hr_utility.trace('SAP element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sap_rate_not_set then
          hr_utility.trace('Warning: SAP rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SAP entries');
        when e_no_new_sap_entry then
          hr_utility.trace('Warning: Unable to locate SAP entry in new tax year');
          hr_utility.trace('Entries for SAP absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SAP update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sap_update_status;
          l_update_error := true;
   end; /* SAP update block */
   -- Begin SPP Adoption Update Block
   BEGIN
     --
     savepoint pre_sppa_update_status;
     --
     if sppa_rate_changed then
       --
       hr_utility.trace('SPP Adoption element entries updating ....');
       for r_affected_pat_adop in csr_affected_leave('PA') loop
          /* SPP Adoption Control call block */
          begin
             hr_utility.trace('Processing SPP Adoption absence: '||r_affected_pat_adop.maternity_id);
       --6800788 begin
--             ssp_pad_pkg.pad_control(p_maternity_id => r_affected_pat_adop.maternity_id,
  --                                   p_deleting => FALSE);

          DBMS_JOB.SUBMIT(l_job_no,'ssp_pad_pkg.pad_control('||r_affected_pat_adop.maternity_id||',FALSE);');
         l_pat_adop_count := l_pat_adop_count + 1;
	     l_count := l_count + 1;
	     l_tbl_job(l_count).job_no := l_job_no;
	     l_tbl_job(l_count).person_id := r_affected_pat_adop.person_id;
	     l_tbl_job(l_count).absence_id := r_affected_pat_adop.maternity_id;
	      if mod(l_count,500) = 0 then
	        commit;
              end if;
   	      --6800788 end

          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SPP Adoption absence: '||r_affected_pat_adop.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_pat_adop.person_id);
   	        hr_utility.trace('Paternity Adoption start date: '||r_affected_pat_adop.date_start);
   	        hr_utility.trace('Paternity Adoption end date: '||r_affected_pat_adop.date_end);
   	        hr_utility.trace('Paternity Adoption projected start date: '||r_affected_pat_adop.date_projected_start);
   	        hr_utility.trace('Paternity Adoption projected end date: '||r_affected_pat_adop.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_pat_adop_count||' paternity adoptions');
--       dbms_output.put_line(' Total SPPA absences ='|| l_pat_adop_count);
     else
        hr_utility.trace('SPP Adoption element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sppa_rate_not_set then
          hr_utility.trace('Warning: SPP ADoption rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SPP ADoption entries');
        when e_no_new_sppa_entry then
          hr_utility.trace('Warning: Unable to locate SPP ADoption entry in new tax year');
          hr_utility.trace('Entries for SPP ADoption absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SPP ADoption update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sppa_update_status;
          l_update_error := true;
   end; /* SPP Adoption update block */
   -- Begin SPP Birth Update Block
   BEGIN
     --
     savepoint pre_sppb_update_status;
     --
     if sppb_rate_changed then
       --
       hr_utility.trace('SPP Birth element entries updating ....');
        --6800788 begin
--       for r_affected_pat_Birth in csr_affected_leave('PA') loop
	for r_affected_pat_Birth in csr_affected_leave('PB') loop
        --6800788 end
          /* SPP Birth Control call block */
          begin
             hr_utility.trace('Processing SPP Birth absence: '||r_affected_pat_Birth.maternity_id);
        --6800788 begin
--             ssp_pab_pkg.pab_control(p_maternity_id => r_affected_pat_Birth.maternity_id,
--                                     p_deleting => FALSE);

          DBMS_JOB.SUBMIT(l_job_no,'ssp_pab_pkg.pab_control('||r_affected_pat_Birth.maternity_id||',FALSE);');
          l_pat_Birth_count := l_pat_birth_count + 1;
	     l_count := l_count + 1;
	     l_tbl_job(l_count).job_no := l_job_no;
	     l_tbl_job(l_count).person_id := r_affected_pat_Birth.person_id;
	     l_tbl_job(l_count).absence_id := r_affected_pat_Birth.maternity_id;
	      if mod(l_count,500) = 0 then
	        commit;
              end if;
      --6800788 end


          exception
             when others then
   	        hr_utility.trace('Error occurred while processing SPP Birth absence: '||r_affected_pat_Birth.maternity_id);
   	        hr_utility.trace('SQL error code: '||SQLCODE);
     	        hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
   	        hr_utility.trace('Person id: '||r_affected_pat_Birth.person_id);
   	        hr_utility.trace('Paternity Birth start date: '||r_affected_pat_Birth.date_start);
   	        hr_utility.trace('Paternity Birth end date: '||r_affected_pat_Birth.date_end);
   	        hr_utility.trace('Paternity Birth projected start date: '||r_affected_pat_Birth.date_projected_start);
   	        hr_utility.trace('Paternity Birth projected end date: '||r_affected_pat_Birth.date_projected_end);
                l_update_error := true;
          end;
       end loop;
       hr_utility.trace('Updated entries for '||l_pat_birth_count||' paternity births');
--       dbms_output.put_line(' Total SPPB absences ='|| l_pat_birth_count);
     else
        hr_utility.trace('SPP Birth element entries already updated for new tax year');
     end if;
     --
     commit;
     --
   exception
        when e_sppb_rate_not_set then
          hr_utility.trace('Warning: SPP Birth rate for new tax year not set');
          hr_utility.trace('Unable to proceed with updating SPP Birth entries');
        when e_no_new_sppb_entry then
          hr_utility.trace('Warning: Unable to locate SPP Birth entry in new tax year');
          hr_utility.trace('Entries for SPP Birth absences in new tax year may be non-existent');
          hr_utility.trace('Check for stoppages and employee terminations, as well as the start/end date of absences');
        when others then
          hr_utility.trace('Unexpected error occurred inside SPP Birth update block');
          hr_utility.trace('SQL error number: '||SQLCODE);
          hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
          rollback to pre_sppb_update_status;
          l_update_error := true;
   end; /* SPP Birth update block */



p_update_error := l_update_error;

--6800788 begin
hr_utility.trace(' Total Absences to be processed '|| l_count);
--DBMS_OUTPUT.PUT_LINE(' Total Absences to be processed '|| l_count);
for I in 1..l_count
loop
   loop
   begin

	select nvl(FAILURES,0) into l_fail from dba_jobs
	where job = l_tbl_job(I).job_no and rownum = 1;

--Bug Fix 6870415 Begin
--	       IF l_fail > 0
	       IF l_fail > 1
--Bug Fix 6870415 End
               THEN
	          l_fail_count := l_fail_count + 1;
                  DBMS_JOB.REMOVE(l_tbl_job(I).job_no);
		  commit;
		  p_job_err(l_fail_count) := ' Process Failed for person id '||l_tbl_job(I).person_id||' with absence id '||l_tbl_job(I).absence_id;
		  hr_utility.trace(' Job '||l_tbl_job(I).job_no||' Failed for person id '||l_tbl_job(I).person_id||' with absence id '||l_tbl_job(I).absence_id);
--		  DBMS_OUTPUT.PUT_LINE(' Job '||l_tbl_job(I).job_no||' Failed for person id '||l_tbl_job(I).person_id||' with absence id '||l_tbl_job(I).absence_id);
		  p_update_error := true;
		  exit;
               ELSE
                  DBMS_LOCK.SLEEP(20);
               END IF;
   Exception
   when no_data_found then
   exit;
   end;
   end loop;
end loop;
hr_utility.trace('Total Absences failed '||l_fail_count);
--DBMS_OUTPUT.PUT_LINE('Total Absences failed '||l_fail_count);
--6800788 end
hr_utility.trace('Update of SSP, SMP, SAP, SPP Adoption and SPP Birth entries complete');
hr_utility.trace('Leaving: '||g_package||'.update_ssp_smp_entries');


exception


when others
then
    hr_utility.trace('Unexpected error occurred inside SSP/SMP element entries update procedure');
    hr_utility.trace('SQL error number: '||SQLCODE);
    hr_utility.trace('SQL error message: '||substr(SQLERRM,1,235));
    rollback to pre_update_status;
    p_update_error := true;




end update_ssp_smp_entries;

end ssp_smp_support_pkg;

/
