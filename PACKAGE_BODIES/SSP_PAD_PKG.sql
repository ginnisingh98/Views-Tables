--------------------------------------------------------
--  DDL for Package Body SSP_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_PAD_PKG" as
/*$Header: sppadapi.pkb 120.2.12000000.3 2007/03/12 13:54:33 kthampan noship $
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Statutory Paternity Pay Adoption Business Process
--
Purpose
	To perform calculation of entitlement and payment for PAD purposes
--
History
	30 Oct 02       ABlinko   2690305  Created from SSP_SMP_PKG
	27 Jan 03 	GButler		   Nocopy fix to average_earnings -
					   created 2nd dummy variable to act
					   as placeholder for OUT param from
					   ssp_ern_ins
        11 Feb 03       ABlinko   2772479  Late absence notification stoppage
                                           no longer created
        18 Jul 03       npershad  2959482  Rectified Misleading stoppage date
                                           for 'Some work done' stoppage
        24 Oct 03       ABlinko   3208325  Replaced hardcoded SATURDAY and
                                           SUNDAY references
        17 mar 04       npershad  3509432  Modified the call to create_stoppage
	                                   to rectify misleading stoppage date
                                           for 'Some work done' stoppage
	29 Mar 04       skhandwa  3516539  Added condition in the cursor to fetch
					   termination date for latest assignment
        07 Jun 04       ABlinko   3598838  Now only first absence is recognised
        13 Jul 04       ABlinko   3682122  Changes for recalculating lump sum
                                           updates
	11 Oct 05       npershad  4621910  Fixed two problems with date conversion,
                                           one in the cursor csr_existing_entries
                                           and twice when calling insert_element_entry
        09 Feb 06       kthampan  4891953  Fixed performance bug.
        23 Aug 06       Kthampan  5482199  Change from per_people_f and per_assignments_f
                                           to per_all_people_f and per_all_assignments_f
        19 Sep 06       Kthampan  5547703  Amend pad_control to call generate_payments
                                           with insert-mode if absence is > 0 and
                                           also change csr_check_if_existing_entries
                                           not to reference from per_absence_attendances
                                           table
        12 Mar 07       Kthampan  5925760  Amend the cursor csr_existing_entries to
                                           use ssp_pad_pkg.c_week_commencing_name
*/
--------------------------------------------------------------------------------
g_package  varchar2(33) := '  ssp_pad_pkg.';  -- Global package name
--

--------------------------------------------------------------------------------
-- Get details of initial paternity leave for a paternity
--
cursor csr_absence_details (p_maternity_id in number) is
select	absence.absence_attendance_id,
	absence.date_start,
	nvl (absence.date_end, hr_general.end_of_time) date_end,
	absence.date_notification,
	absence.accept_late_notification_flag
from    per_absence_attendances	ABSENCE
where   absence.maternity_id = p_maternity_id
and     absence.absence_attendance_id =
         (select min(paa_tab.absence_attendance_id)
          from per_absence_attendances paa_tab
          where paa_tab.maternity_id = absence.maternity_id);
--------------------------------------------------------------------------------
--
-- Get details of the maternal woman
--
cursor csr_personal_details (p_maternity_id in number) is
select	maternity.person_id,
	maternity.due_date,
	ssp_pad_pkg.MATCHING_WEEK_OF_ADOPTION (MATCHING_DATE) MW,
	MATCHING_DATE MATCHING_DATE,
        PLACEMENT_DATE PLACEMENT_DATE,
        DISRUPTED_PLACEMENT_DATE DISRUPTED_PLACEMENT_DATE,
	maternity.maternity_id,
	maternity.actual_birth_date,
	maternity.live_birth_flag,
	maternity.start_date_with_new_employer,
	maternity.MPP_start_date APP_start_date,
	maternity.notification_of_birth_date,
	maternity.start_date_maternity_allowance,
	maternity.pay_SMP_as_lump_sum pay_PAD_as_lump_sum,
	person.date_of_death,
        service.date_start,
	nvl (service.final_process_date, hr_general.end_of_time) FINAL_PROCESS_DATE
from   	ssp_maternities				MATERNITY,
	per_all_people_f				PERSON,
	per_periods_of_service			SERVICE
where   person.person_id = maternity.person_id
and	person.person_id = service.person_id
and	maternity.maternity_id = p_maternity_id
and	service.date_start between person.effective_start_date
				and person.effective_end_date
and     service.date_start = (select max(serv.date_start)
                              from   per_periods_of_service serv
                              where  serv.person_id = person.person_id);
--------------------------------------------------------------------------------
person	                 csr_personal_details%rowtype;
g_PAD_element            csr_PAD_element_details%rowtype;
g_PAD_Correction_element csr_PAD_element_details%rowtype;
--------------------------------------------------------------------------------
l_sunday  varchar2(100) := to_char(to_date('07/01/2001','DD/MM/YYYY'),'DAY');

function MATCHING_WEEK_OF_ADOPTION (p_matching_date in date) return date is
--
-- Returns the date on which the MW starts
--
-- p_matching_date comes from the person's maternity record
-- MW is the Sunday prior to MATCHING_WEEK DATE
--
l_MW  date := (next_day (p_matching_date,l_sunday) -7);
--
begin
--
  return l_MW;
--
end MATCHING_WEEK_OF_ADOPTION;
--------------------------------------------------------------------------------
Function CONTINUOUS_EMPLOYMENT_DATE (p_matching_date in date) return date is
--
l_PAD_element			csr_PAD_element_details%rowtype;
l_Continuously_employed_since	date;
l_saturday varchar2(100) := to_char(to_date('06/01/2001','DD/MM/YYYY'),'DAY');
--
begin
--
  open  csr_PAD_element_details (p_matching_date,c_PAD_element_name);
  fetch csr_PAD_element_details into l_PAD_element;
  close csr_PAD_element_details;
  --
  l_Continuously_employed_since :=
          next_day(next_day(
                    MATCHING_WEEK_OF_ADOPTION (p_matching_date) ,l_saturday)
          - (l_PAD_element.continuous_employment_period),l_saturday);
  --
  return l_Continuously_employed_since;
  --
end continuous_employment_date;
--------------------------------------------------------------------------------
procedure get_PAD_correction_element (p_effective_date in date) is
--
l_proc        varchar2(72) := g_package||'get_PAD_correction_element';
--
  procedure check_parameters is
  begin
  --
    hr_utility.trace (l_proc||'	p_effective_date = '
	||to_char (p_effective_date));
  --
    hr_api.mandatory_arg_error (
		p_api_name	=> l_proc,
		p_argument	=> 'effective_date',
		p_argument_value=> p_effective_date);
  end check_parameters;
  --
begin
--
  hr_utility.set_location (l_proc,1);
  --
  check_parameters;
  --
  open  csr_PAD_element_details (p_effective_date,c_PAD_Corr_element_name);
  fetch csr_PAD_element_details into g_PAD_Correction_element;
  close csr_PAD_element_details;
  --
  hr_utility.set_location (l_proc,100);
  --
end get_PAD_correction_element;
--------------------------------------------------------------------------------
procedure get_PAD_element (p_effective_date in date) is
--
l_proc        varchar2(72) := g_package||'get_PAD_element';
--
  procedure check_parameters is
  begin
  --
    hr_utility.trace (l_proc||'     p_effective_date = '
		||to_char (p_effective_date));
    --
	hr_api.mandatory_arg_error (
		p_api_name	=> l_proc,
		p_argument	=> 'effective_date',
		p_argument_value=> p_effective_date);
    --
  end check_parameters;
--
begin
--
  hr_utility.set_location (l_proc,1);
  --
  check_parameters;
  --
  open  csr_PAD_element_details (p_effective_date,c_PAD_element_name);
  fetch csr_PAD_element_details into g_PAD_element;
  close csr_PAD_element_details;
  --
  hr_utility.set_location (l_proc,100);
  --
end get_PAD_element;
--------------------------------------------------------------------------------
function EARLIEST_PPP_START_DATE (p_due_date in date) return date is
--
l_earliest_PPP_start	date;
l_PAD_element		csr_PAD_element_details%rowtype;
--
begin
--
  open  csr_PAD_element_details (p_due_date,c_PAD_element_name);
  fetch csr_PAD_element_details into l_PAD_element;
  close csr_PAD_element_details;
  --
  l_earliest_PPP_start := p_due_date
				- (l_PAD_element.earliest_start_of_PPP);
  return l_earliest_PPP_start;
--
end earliest_PPP_start_date;
--------------------------------------------------------------------------------
function LATEST_PPP_START_DATE (p_placement_date in date) return date is
--
l_latest_PPP_start	date;
l_PAD_element		csr_PAD_element_details%rowtype;
--
begin
--
  open  csr_PAD_element_details (p_placement_date,c_PAD_element_name);
  fetch csr_PAD_element_details into l_PAD_element;
  close csr_PAD_element_details;
  --
  l_latest_PPP_start := p_placement_date
				+ (l_PAD_element.latest_end_of_PPP - 7);
  return l_latest_PPP_start;
--
end latest_PPP_start_date;
--------------------------------------------------------------------------------
function MATERNITY_RECORD_EXISTS (p_person_id in number) return boolean is
--
cursor maternity_record is
select 1
from   ssp_maternities
where  person_id = p_person_id;
--
l_dummy	                  number (1);
l_maternity_record_exists boolean;
--
begin
--
  open  maternity_record;
  fetch maternity_record into l_dummy;
  l_maternity_record_exists := maternity_record%found;
  close maternity_record;
  --
  return l_maternity_record_exists;
--
end maternity_record_exists;
--------------------------------------------------------------------------------
function AVERAGE_EARNINGS return number is
--
l_average_earnings  number       := null;
l_effective_date    date         := null;
l_dummy		    number;
l_dummy2	    number; -- nocopy fix, placeholder variable
l_user_entered	    varchar2(30) := 'N';  --DFoster 1304683
l_absence_category  varchar2(30) := 'GB_PAT_ADO';  --DFoster 1304683
l_payment_periods   number       := null; --DFoster 1304683
l_proc		    varchar2(72) := g_package||'average_earnings';
--
cursor csr_average_earnings is
select average_earnings_amount
from   ssp_earnings_calculations
where  person_id = person.person_id
and    effective_date = l_effective_date;
--
begin
--
  hr_utility.set_location ('Entering '||l_proc,1);
  --
  l_effective_date := greatest(person.MW, person.date_start);
  --
  open csr_average_earnings;
  fetch csr_average_earnings into l_average_earnings;

  if csr_average_earnings%notfound
  then
    ssp_ern_ins.ins (p_earnings_calculations_id  => l_dummy,
                     p_object_version_number     => l_dummy2,
                     p_person_id                 => person.person_id,
                     p_effective_date            => l_effective_date,
                     p_average_earnings_amount   => l_average_earnings,
        	     p_user_entered	         => l_user_entered,     --DFoster 1304683
        	     p_absence_category		 => l_absence_category, --DFoster 1304683
        	     p_payment_periods		 => l_payment_periods); --DFoster 1304683
  end if;
  --
  close csr_average_earnings;
  --
  hr_utility.set_location ('Leaving '||l_proc,10);
  --
  return l_average_earnings;
--
end average_earnings;
--------------------------------------------------------------------------------
function entitled_to_PAD (p_maternity_id in number) return boolean is
--
-- See header for description of this procedure.
--
no_prima_facia_entitlement	exception;
invalid_absence_date		exception;
l_work_start_date		date := hr_general.end_of_time;
stoppage_end_date		date := null;
no_of_absence_periods		integer := 0;
l_proc                  	varchar2(72) := g_package||'entitled_to_PAD';
l_keep_stoppages                boolean default FALSE;
--
--
cursor csr_no_of_absences is
select count (*)
from   per_absence_attendances
where  person_id = person.person_id
and    maternity_id = p_maternity_id
and    absence_attendance_id =
        (select min(paa_tab.absence_attendance_id)
         from per_absence_attendances paa_tab
         where paa_tab.maternity_id = p_maternity_id);
--
cursor csr_check_if_existing_entries is
select /*+ ORDERED use_nl(paa,paaf,etype,entry) */
       entry.element_entry_id,
       entry.effective_start_date
from   per_all_assignments_f   PAAF,
       pay_element_types_f     ETYPE,
       pay_element_entries_f   ENTRY
where  PAAF.person_id = person.person_id
and    ETYPE.element_name = c_PAD_element_name
and    ETYPE.legislation_code = 'GB'
and    ENTRY.element_type_id = ETYPE.element_type_id
and    ENTRY.creator_type = c_PAD_creator_type
and    ENTRY.creator_id = p_maternity_id
and    ENTRY.assignment_id = PAAF.assignment_id
and not exists (
               --
               -- Do not select entries which have already had reversal action
               -- taken against them because they are effectively cancelled out.
               --
               select 1
               from   pay_element_entries_f ENTRY2
               where  entry.element_entry_id  = entry2.target_entry_id
               and    entry.assignment_id     = entry2.assignment_id)
                 --
and not exists (
               --
               -- Do not select reversal entries
               --
               select 1
               from   pay_element_links_f LINK,
                      pay_element_types_f TYPE
               where  link.element_link_id = entry.element_link_id
               and    entry.effective_start_date between link.effective_start_date and link.effective_end_date
               and    link.element_type_id = type.element_type_id
               and    link.effective_start_date between type.effective_start_date and type.effective_end_date
               and    type.element_name = c_PAD_Corr_element_name);
--
l_existing_entries              csr_check_if_existing_entries%rowtype;
--
  procedure create_stoppage (
  --
  -- Create a stoppage of payment for PAD
  --
  p_reason        in varchar2,
  p_withhold_from in date,
  p_withhold_to	  in date default null) is
  --
  l_proc        varchar2(72) := g_package||'create_stoppage';
  l_dummy       number;
  l_reason_id	number;
	--
    procedure check_parameters is
    --
    begin
    --
      hr_utility.trace (l_proc||'	p_reason = '||p_reason);
      hr_utility.trace (l_proc||'	withhold from '||to_char (p_withhold_from));
      hr_utility.trace (l_proc||'	withhold to '||to_char (p_withhold_to));
      --
      hr_api.mandatory_arg_error (
			p_api_name	=> l_proc,
			p_argument	=> 'reason',
			p_argument_value=> p_reason);
			--
      hr_api.mandatory_arg_error (
			p_api_name      => l_proc,
			p_argument      => 'withhold_from',
			p_argument_value=> p_withhold_from);
			--
    end check_parameters;
		--
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    check_parameters;
    --
    l_reason_id := ssp_smp_support_pkg.withholding_reason_id (
      	                        g_PAD_element.element_type_id,
				p_reason);
    --
    if not ssp_smp_support_pkg.stoppage_overridden (
                          	p_maternity_id => p_maternity_id,
				p_reason_id => l_reason_id)
    then
    --
    -- Only create the stoppage if there is not already a stoppage marked
    -- as overridden. Thus, overriding a stoppage effectively blocks that
    -- reason being used to withhold payment for this person.
    --
      ssp_stp_ins.ins (p_withhold_from => p_withhold_from,
                       p_withhold_to   => p_withhold_to,
		       p_stoppage_id   => l_dummy,
		       p_object_version_number => l_dummy,
		       p_maternity_id	=> p_maternity_id,
		       p_user_entered  => 'N',
		       p_reason_id     => l_reason_id);
    else
      hr_utility.trace (l_proc||'	Stoppage is overridden');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end create_stoppage;
  --
  procedure remove_stoppages is
  --
  -- Remove old system, non-overridden stoppages
  --
  cursor csr_stoppages is
  select stoppage_id
  from   ssp_stoppages
  where  user_entered <>'Y'
  and    override_stoppage <> 'Y'
  and    maternity_id = p_maternity_id;
  --
  l_dummy number;
  l_proc  varchar2 (72) := g_package||'remove_stoppages';
  --
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    for each_stoppage in csr_stoppages LOOP
       ssp_stp_del.del (p_stoppage_id => each_stoppage.stoppage_id,
                        p_object_version_number => l_dummy);
    end loop;
    --
    hr_utility.set_location (l_proc,100);
    --
  end remove_stoppages;
  --
  procedure check_employment_end is

  cursor csr_termination_date is
  select actual_termination_date
  from   per_periods_of_service
  where  person_id = person.person_id
  -- 3516539 Added condition to obtain termination date for latest assignment
  and    period_of_service_id = (select max(period_of_service_id)
    				 from   per_periods_of_service ppos
                                 where  ppos.person_id = person.person_id);
  --
  l_termination_date date := null;
  l_proc  varchar2 (72)   := g_package||'check_employment_end';
  --
  begin
    --
    hr_utility.set_location (l_proc,1);
    --
    open  csr_termination_date;
    fetch csr_termination_date into l_termination_date;
    close csr_termination_date;
    --
    if l_termination_date < person.placement_date then
      --
      -- Stop all PAD payment for the Adoption because the person left
      -- before the APP start date.
      --
      create_stoppage (p_withhold_from => person.placement_date,
                       p_reason        => 'Not employed on Placement Date');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_employment_end;
  --
  procedure check_continuity_rule is
  --
  -- Check that the person has the right amount of continuous service to
  -- qualify for PAD
  --
  cursor period_of_service is
  --
  -- Check the period of service length up to the MW start date
  --
  select 1
  from   per_periods_of_service
  where  person_id = person.person_id
  and    date_start <= ssp_pad_pkg.continuous_employment_date
			        	(person.matching_date)
  and    nvl (actual_termination_date, hr_general.end_of_time)
				>= person.MW;
  --
  l_dummy number (1);
  l_proc  varchar2 (72) := g_package||'check_continuity_rule';
  --
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    open period_of_service;
    fetch period_of_service into l_dummy;
    --
    if period_of_service%notfound then
      --
      -- Stop all PAD payment for the Adoption because the person has not
      -- been continuously employed for long enough.
      --
      create_stoppage (p_withhold_from => person.APP_start_date,
                       p_reason        => 'Insufficient employment');
    end if;
    --
    close period_of_service;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_continuity_rule;
  --
  procedure check_start_date is

  l_proc varchar2 (72) := g_package||'check_start_date';
  --
  l_latest_PPP_start    date;
  l_PAD_element         csr_PAD_element_details%rowtype;
  --
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    open  csr_PAD_element_details (person.placement_date,c_PAD_element_name);
    fetch csr_PAD_element_details into l_PAD_element;
    close csr_PAD_element_details;
    --
    if person.app_start_date > person.placement_date
                               + (l_PAD_element.latest_end_of_PPP - 14)
    then
      --
      create_stoppage (p_withhold_from => person.APP_start_date + 7,
                       p_reason        => 'Max PPP Period Exceeded');
      --
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_start_date;
  --
  procedure check_new_employer is
  --
  -- Check the person has not been employed by a new employer after the
  -- child placement
  --
  l_proc varchar2 (72) := g_package||'check_new_employer';
  --
  begin
    --
    hr_utility.set_location (l_proc,1);
    --
    --
    -- Stop PAD payment from the start of the week in which the person
    -- started work for a new employer after the placement of her child.
    --
    if person.start_date_with_new_employer >= person.placement_date then
      create_stoppage (p_withhold_from => ssp_smp_support_pkg.start_of_week
                                         (person.start_date_with_new_employer),
                       p_reason => 'Worked for another employer');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_new_employer;
  --
  procedure check_maternity_allowance is
  --
  -- PAD ceases when SMA starts.
  --
  l_proc varchar2 (72) := g_package||'check_maternity_allowance';
  --
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    -- Stop PAD payment from the start of the week in which SMA was first
    -- paid.
    --
    if person.start_date_maternity_allowance is not null then
       create_stoppage (p_withhold_from => ssp_smp_support_pkg.start_of_week
                                         (person.start_date_maternity_allowance),
                        p_reason => 'Employee is receiving SMA');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_maternity_allowance;
  --
  procedure check_death is
  --
  -- PAD ceases after the death of the woman.
  --
  l_proc varchar2 (72) := g_package||'check_death';
  --
  cursor csr_check_death is
  select ppf.date_of_death
  from   per_all_people_f ppf
  where  ppf.person_id = person.person_id
  and    ppf.date_of_death is not null;

  l_death_date date;

  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    -- PAD ceases on the Saturday following death
    --
    l_death_date := null;
    --
    open  csr_check_death;
    fetch csr_check_death into l_death_date;
    close csr_check_death;
    --
    if l_death_date is not null then
       create_stoppage (p_withhold_from => next_day (l_death_date,
                                                        l_sunday),
                        p_reason => 'Employee died');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  end check_death;
  --
  procedure check_average_earnings is
  --
  -- The person must earn enough to qualify for PAD
  --
  l_proc                   varchar2 (72) := g_package||'check_average_earnings';
  l_average_earnings       number := average_earnings;
  l_reason_for_no_earnings varchar2 (80) := null;
  earnings_not_derived     exception;
  --
  begin
  --
    hr_utility.set_location (l_proc,1);
    --
    -- If the average earnings figure returned is zero then check that
    -- no error message was set. Error messages will be set for system-
    -- generated average earnings when the earnings could not be derived
    -- for some reason, but to allow this procedure to continue, no error
    -- will be raised.
    --
    if l_average_earnings = 0
    then
      l_reason_for_no_earnings:=ssp_smp_support_pkg.average_earnings_error;
      --
      if l_reason_for_no_earnings is not null then
         create_stoppage (p_withhold_from => person.aPP_start_date,
                          p_reason => l_reason_for_no_earnings);
      --
         raise earnings_not_derived;
      end if;
    end if;
    --
    -- Stop PAD payment from the APP start date
    --
    if l_average_earnings
            < ssp_smp_support_pkg.NI_Lower_Earnings_Limit (person.MW)
    then
      create_stoppage (p_withhold_from => person.APP_start_date,
                       p_reason => 'Earnings too low');
    end if;
    --
    hr_utility.set_location (l_proc,100);
    --
  exception
  --
    when earnings_not_derived then
      --
      -- Exit silently from this procedure
      --
      hr_utility.trace (l_proc||'	Earnings not derived');
      null;
      --
  end check_average_earnings;
  --
  procedure check_parameters is
  --
  begin
  --
    hr_utility.trace (l_proc||'	p_maternity_id = '
                      	||to_char (p_maternity_id));
    --
    hr_api.mandatory_arg_error (
                p_api_name	=> l_proc,
		p_argument	=> 'maternity_id',
		p_argument_value=> p_maternity_id);
    --
  end check_parameters;
  --
  begin
  --

    hr_utility.set_location (l_proc,1);
    --
    check_parameters;
    --
    -- Get the details of the woman and her maternity.
    --
    open csr_personal_details (p_maternity_id);
    fetch csr_personal_details into person;
    --
    -- If no maternity record exists then there can be no entitlement to PAD
    --
    if csr_personal_details%notfound
    then
      close csr_personal_details;
      --
      hr_utility.trace (l_proc||'	Person has no maternity record - exiting');
      --
      raise no_prima_facia_entitlement;
    end if;
    --
    close csr_personal_details;
    --
    -- If the APP has not started then there is no entitlement to PAD.
    --
    if person.APP_start_date is null then
      hr_utility.trace (l_proc||'	Person has no APP start date - exiting');
      --
      raise no_prima_facia_entitlement;
    end if;
    --
    -- Count how many absences there are for the maternity.
    --
    open csr_no_of_absences;
    fetch csr_no_of_absences into no_of_absence_periods;
    close csr_no_of_absences;
    --
    -- check if entries exist despite there being no absence
    --
    if no_of_absence_periods = 0
    then
      open csr_check_if_existing_entries;
      fetch csr_check_if_existing_entries into l_existing_entries;
      --
      if csr_check_if_existing_entries%NOTFOUND
      then
        hr_utility.trace (l_proc||'    Person has not stopped work - exiting');
        raise no_prima_facia_entitlement;
      end if;
      --
      -- if entries are found then the absence has been deleted and entries remain
      -- that must be dealt with
      --
      while csr_check_if_existing_entries%FOUND LOOP
        fetch csr_check_if_existing_entries into l_existing_entries;
      end loop;
      --
      close csr_check_if_existing_entries;
      l_keep_stoppages := TRUE;
    end if;
    --
    -- Having established a prima facia entitlement to PAD, perform checks which
    -- may lead to creation of stoppages for particular periods.
    --
    hr_utility.set_location ('ssp_smp_pkg.entitled_to_PAD',2);
    --
    -- Get the PAD legislative parameters.
    --
    get_PAD_element (person.due_date);
    --
    -- Clear stoppages created by previous calculations of PAD but if an absence
    -- is being deleted, then must keep stoppages so that when later comparison of
    -- old_entry and hypothetical_entry is done then stoppages are still there.
    --
    if not l_keep_stoppages then
      remove_stoppages;
    end if;
    --
    for absence in csr_absence_details (p_maternity_id) LOOP
    --
    -- Check that sufficient notification of absence was given
    --
    if (absence.date_notification > absence.date_start
				- g_PAD_element.MPP_notice_requirement
    and absence.accept_late_notification_flag = 'N')
    or (absence.date_notification > person.placement_date
				+ g_PAD_element.MPP_notice_requirement)
    then
      --
      -- Stop PAD payment from the start of the week in which the absence
      -- starts, to the end of the notice period
      --
      stoppage_end_date := g_PAD_element.MPP_notice_requirement
     	                         + absence.date_start - 1;
      --
/* Bug 2772479 - stoppage no longer required, but may be reintroduced

      create_stoppage (
          	p_withhold_from => ssp_smp_support_pkg.start_of_week
        							(absence.date_start),
          	p_withhold_to => ssp_smp_support_pkg.end_of_week (stoppage_end_date),
          	p_reason => 'Late absence notification');
*/
    end if;
    --
    hr_utility.set_location ('ssp_pad_pkg.entitled_to_PAD',3);
    --
    -- Check for any work done during the APP.
    --
    -- if this is the first absence period in the APP
    -- and the absence starts after the APP start date

    if  csr_absence_details%rowcount = 1
    and absence.date_start > person.APP_start_date

    then

      create_stoppage (p_reason => 'Some work was done',
                       p_withhold_from => person.APP_start_date,
                       p_withhold_to => ssp_smp_support_pkg.end_of_week
                                                       (absence.date_start -1));
    end if;
    --
    -- this is the last absence period in the MPP
    -- and the absence period ends before the end of the MPP
    if csr_absence_details%rowcount = no_of_absence_periods
    and absence.date_end < (g_PAD_element.maximum_PPP * 7)
				+ person.APP_start_date
    then

     --Bug 2959482 start
     --Added plus 1 to (absence.date_end - absence.date_start) for bug fix 3509432
     --Only one week is paid, if absence is for > 1 week  but < 2 weeks
     if (absence.date_end - absence.date_start) + 1 > 7 and (absence.date_end - absence.date_start) + 1 < 14 then

           create_stoppage (p_reason => 'Some work was done',
                            p_withhold_from => person.APP_start_date + 7);

     --no weeks are paid,if absence < 1 week
     elsif (absence.date_end - absence.date_start) + 1 < 7 then

     	   create_stoppage (p_reason => 'Some work was done',
                            p_withhold_from => person.APP_start_date);

     elsif (absence.date_end - absence.date_start) + 1 = 7 then

     	   create_stoppage (p_reason => 'Some work was done',
                            p_withhold_from => person.APP_start_date + 7);

     --no stoppage created if absence is equal to 14 days
     elsif absence.date_start is not null and absence.date_end is not null then

    	if  (absence.date_end - absence.date_start) + 1 = 14 then
    	     null;
    	end if;
     end if;
     --Bug 2959482 End

     --Commented code for Bug Fix 2959482
      /*create_stoppage (p_reason => 'Some work was done',
                       p_withhold_from => ssp_smp_support_pkg.start_of_week
							(absence.date_end+1));*/
    elsif
      -- there is a period of work between two absences
      l_work_start_date < absence.date_start
      and l_work_start_date < (g_PAD_element.maximum_PPP * 7)
                                         + person.APP_start_date

    then

      create_stoppage (p_reason => 'Some work was done',
                       p_withhold_from => ssp_smp_support_pkg.start_of_week
					(l_work_start_date),
                       p_withhold_to => ssp_smp_support_pkg.end_of_week
					(absence.date_start -1));
      --
      if absence.date_end <> hr_general.end_of_time
      then
        l_work_start_date := absence.date_end + 1;
      else
        --
        -- This is not the last absence in the maternity but it has no end date.
        --
        hr_utility.trace (l_proc||'    ERROR: Invalid null absence end date');
        --

        raise invalid_absence_date;
      end if;
    end if;
  end loop;
  --
  check_continuity_rule;
  check_start_date;
  check_employment_end;
  check_new_employer;
  check_maternity_allowance;
  check_death;
  --check_medical_evidence;
  --check_birth_confirmation;
  check_average_earnings;
  --
  -- If we get this far the person is entitled to PAD (though stoppages may apply)
  --
  return TRUE;
  --
exception
--
  when invalid_absence_date then
    fnd_message.set_name ('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token ('PROCEDURE','ssp_smp_pkg.entitled_to_PAD');
    fnd_message.set_token ('STEP','3');
    --
  when no_prima_facia_entitlement then
    --
    -- Exit silently; this will allow us to call this procedure with impunity
    -- from absences which are not maternity absences (e.g. via a row trigger)
    --
    return FALSE;
    --
end entitled_to_PAD;
--------------------------------------------------------------------------------
procedure generate_payments (p_maternity_id in number,
                             p_deleting     in boolean default FALSE) is
--
type date_table    is table of date index by binary_integer;
type number_table  is table of number index by binary_integer;
type varchar_table is table of varchar2 (80) index by binary_integer;
l_proc varchar2(72) := g_package||'generate_payments';
--
type PAD_entry is record (
	--
	element_entry_id	number_table,
	element_link_id		number_table,
	assignment_id		number_table,
	effective_start_date	date_table,
	effective_end_date	date_table,
	amount			number_table,
	rate			varchar_table,
	week_commencing		date_table,
	recoverable_amount	number_table,
	stopped			varchar_table,
	dealt_with		varchar_table);
	--
--
-- A store for all the PAD entries that potentially may be
-- granted to the person.
--
hypothetical_entry	PAD_entry;
--
-- A tally of the number of weeks of the APP which are subject to stoppages.
--
l_stopped_weeks		number := 0;
--
l_high_rate	varchar2 (80) := null;
l_low_rate	varchar2 (80) := null;
-- RT entries prob
l_no_of_absence_periods  integer := 0;
  --
  -- p_deleting passed into save_hypothetical_entries, so that logic can be
  -- dealt with for deleted absences.
  --
  procedure save_hypothetical_entries (p_deleting in boolean default false) is
  --
  -- Having generated the potential PAD entries, reconcile them with any
  -- previously granted entries for the same maternity.
  --
  cursor csr_existing_entries is
  --
  -- Get all entries and entry values for the Adoption
  --
  -- Decode the rate code to give the meaning using local variables
  -- populated earlier by Calculate_correct_PAD_rate
  -- these can then be passed directly into the hr_entry_api's and
  -- simplifies comparison with hypo entries
  --
  select entry.element_entry_id,
         entry.element_link_id,
         entry.assignment_id,
         entry.effective_start_date,
         entry.effective_end_date,
         -- if in future we get two different rates then a decode can be added here
         l_high_rate RATE,
         /*to_date (ssp_smp_support_pkg.value
            (entry.element_entry_id,
            ssp_pad_pkg.c_week_commencing_name),
            'DD-MON-YYYY') WEEK_COMMENCING,*/
	 fnd_date.chardate_to_date(ssp_smp_support_pkg.value
	  (entry.element_entry_id,
	   ssp_pad_pkg.c_week_commencing_name)) WEEK_COMMENCING,
         to_number(ssp_smp_support_pkg.value (entry.element_entry_id,
            ssp_pad_pkg.c_amount_name)) AMOUNT,
         to_number(ssp_smp_support_pkg.value (entry.element_entry_id,
            ssp_pad_pkg.c_recoverable_amount_name)) RECOVERABLE_AMOUNT
  from	 pay_element_entries_f ENTRY,
         per_all_assignments_f     asg
  where	 creator_type = c_PAD_creator_type
  and    creator_id = p_maternity_id
  and    asg.person_id     = person.person_id
  and    asg.assignment_id = entry.assignment_id
  and    entry.effective_start_date between asg.effective_start_date
                                               and asg.effective_end_date
  and not exists (
        --
        -- Do not select entries which have already had reversal action taken
        -- against them because they are effectively cancelled out.
        --
        select 1
        from   pay_element_entries_f	ENTRY2
        where  entry.element_entry_id= entry2.target_entry_id
        and    entry.assignment_id   = entry2.assignment_id)
        --
  and not exists (
        --
        -- Do not select reversal entries
        --
        select 1
        from	pay_element_links_f LINK,
                pay_element_types_f TYPE
        where link.element_link_id = entry.element_link_id
        and	entry.effective_start_date between link.effective_start_date
                and link.effective_end_date
        and link.element_type_id = type.element_type_id
        and	link.effective_start_date between type.effective_start_date
                and type.effective_end_date
        and type.element_name = c_PAD_Corr_element_name);
	--
  cursor csr_no_of_absences is
  --
  select count (*)
  from   per_absence_attendances
  where  person_id = person.person_id
  and    maternity_id = p_maternity_id
  and    absence_attendance_id =
          (select min(paa_tab.absence_attendance_id)
           from per_absence_attendances paa_tab
           where paa_tab.maternity_id = p_maternity_id);
  --
  l_ins_corr_ele  boolean;
  l_dummy         number;
  Entry_number    integer;
  l_ern_calc_id   number;
  l_ob_v_no       number;
  l_new_ob_v_no   number;
  l_proc varchar2 (72) := g_package||'save_hypothetical_entries';
  --
  -- This procedure was a private procedure in the function entitled_to_pad. I
  -- wanted to call it within this procedure (generate_payments) aswell, so
  -- instead of making it a public procedure I have copied the procedure to here.
  --
    procedure remove_stoppages is
    --
    -- Remove old system, non-overridden stoppages
    --
    cursor csr_stoppages is
    --
    select stoppage_id
    from   ssp_stoppages
    where  user_entered <>'Y'
    and    override_stoppage <> 'Y'
    and    maternity_id = p_maternity_id;
    --
    l_dummy number;
    l_proc varchar2 (72) := g_package||'.remove_stoppages';
    --
    begin
    --
      hr_utility.set_location (l_proc,1);
      --
      for each_stoppage in csr_stoppages LOOP
        ssp_stp_del.del (p_stoppage_id => each_stoppage.stoppage_id,
                         p_object_version_number => l_dummy);
      end loop;
      --
      hr_utility.set_location (l_proc,100);
      --
    end remove_stoppages;
    --
  begin
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    get_PAD_correction_element (person.due_date);
    --
    -- Check each existing SaP entry in turn against all the potential new ones.
    --
    <<OLD_ENTRIES>>
    for old_entry in csr_existing_entries
    LOOP
      --First loop through the hypothetical entries to see if there is one
      --which covers the same week as the old entry and is not subject to
      --a stoppage.  If there isn't one, invalidate the old entry.
      --Assume we don't need to correct the entry until we discover otherwise:
      --
      l_ins_corr_ele := FALSE;
      begin
        entry_number := 0;
        if p_deleting then
           raise no_data_found; -- enter exception handler
        end if;
        LOOP
          entry_number := entry_number +1;
          -- Exit the loop when we find a hypothetical entry covering the
          -- same week as the old entry, which is not subject to a stoppage.
          -- If no such match is found, then we will reach the end of the
          -- pl/sql table and attempt to read beyond the existing rows; this
          -- will cause us to enter the exception handler and indicate that
          -- no match was found.
          exit when ((old_entry.week_commencing
             = hypothetical_entry.week_commencing (entry_number)
             and not hypothetical_entry.stopped (entry_number) = 'TRUE'
             and ssp_smp_pkg.g_smp_update = 'N')
             or (old_entry.effective_start_date
                   = hypothetical_entry.effective_start_date (entry_number)
                 and old_entry.week_commencing
                   = hypothetical_entry.week_commencing (entry_number)
                 and not hypothetical_entry.stopped (entry_number) = 'TRUE'
                 and ssp_smp_pkg.g_smp_update = 'Y'));
        end loop;
        hr_utility.trace (l_proc||' Old entry / Hypo entry time Match with values:');
        hr_utility.trace (l_proc||'        Rate: ' ||old_entry.rate||' / '
          ||hypothetical_entry.rate (Entry_number));
        hr_utility.trace (l_proc||'      Amount: '
          ||old_entry.amount||' / '
          ||hypothetical_entry.amount (entry_number));
        hr_utility.trace (l_proc||' Recoverable: '
          ||old_entry.recoverable_amount||' / '
          ||hypothetical_entry.recoverable_amount (entry_number));
        hr_utility.trace (l_proc||'   Week Comm: '
          ||hypothetical_entry.week_commencing (entry_number) );
        --A hypo entry covers the same week as the old one
        if    old_entry.rate   = hypothetical_entry.rate (entry_number)
          and old_entry.amount = hypothetical_entry.amount(entry_number)
          and old_entry.recoverable_amount
                   = hypothetical_entry.recoverable_amount (entry_number)
        then
          -- the hypo entry has the same values as the old one
          -- don't create a correction element.
          -- don't create a new entry
          hypothetical_entry.dealt_with (entry_number) := 'TRUE';
          hr_utility.trace (l_proc||' leave unchanged');
        else
          if ssp_smp_support_pkg.entry_already_processed
                                            (old_entry.element_entry_id)
          then l_ins_corr_ele := TRUE;
          hr_utility.trace (l_proc||' processed - correct it');
          else
            -- update old entry
            hr_utility.trace (l_proc||' unprocessed - update it');
            hr_entry_api.update_element_entry (
              p_dt_update_mode => 'CORRECTION',
              p_session_date => old_entry.effective_start_date,
              p_element_entry_id => old_entry.element_entry_id,
              p_input_value_id1 => g_PAD_element.rate_id,
              p_input_value_id2 => g_PAD_element.amount_id,
              p_input_value_id3 => g_PAD_element.recoverable_amount_id,
              p_entry_value1=> hypothetical_entry.rate (entry_number),
              p_entry_value2=> hypothetical_entry.amount(entry_number),
              p_entry_value3=>
                      hypothetical_entry.recoverable_amount (entry_number));
            --
            --prevent insertion of new entry
            --
            hypothetical_entry.dealt_with (entry_number) := 'TRUE';
          end if;
        end if;
      exception
        when no_data_found then
          -- There was no new entry which exactly matched the old entry.
          -- or we are deleting.
          entry_number := null;
          hr_utility.trace (l_proc||' No Old entry - Hypo entry time Match');
          hr_utility.trace (l_proc||' or p_deleting is true');
          hr_utility.trace (l_proc||' Old entry values:');
          hr_utility.trace (l_proc||'        Rate: '||old_entry.rate);
          hr_utility.trace (l_proc||'      Amount: '||old_entry.amount);
          hr_utility.trace (l_proc||' Recoverable: '
                                        ||old_entry.recoverable_amount);
          if ssp_smp_support_pkg.entry_already_processed
                                            (old_entry.element_entry_id)
          then l_ins_corr_ele := TRUE;
            hr_utility.trace (l_proc||' Old entry already processed');
          else
            hr_utility.trace (l_proc||' Old entry NOT already processed');
            --Old entry not already processed so delete it
            hr_entry_api.delete_element_entry (
              p_dt_delete_mode => 'ZAP',
              p_session_date => old_entry.effective_start_date,
              p_element_entry_id => old_entry.element_entry_id);
          end if;
      end;
      if l_ins_corr_ele
      then
        -- Create a correction element to reverse the old entry. Then create a
        -- brand new entry with the correct values.
        --
        hr_utility.trace (l_proc ||
                          ' Inserting CORRECTION entry for week commencing ' ||
                          to_char (old_entry.week_commencing));
        hr_utility.trace (l_proc||'              Old value / New value:');
        if entry_number is null then
          hr_utility.trace (l_proc||'        Rate: '
            ||old_entry.rate||' / NA');
          hr_utility.trace (l_proc||'      Amount: '
            ||old_entry.amount||' / NA');
          hr_utility.trace (l_proc||' Recoverable: '
            ||old_entry.recoverable_amount||' / NA');
        else
          hr_utility.trace (l_proc||'        Rate: '
            ||old_entry.rate||' / '
            ||hypothetical_entry.rate (Entry_number));
          hr_utility.trace (l_proc||'      Amount: '
            ||old_entry.amount||' / '
            ||hypothetical_entry.amount (entry_number));
          hr_utility.trace (l_proc||' Recoverable: '
            ||old_entry.recoverable_amount||' /'
            ||hypothetical_entry.recoverable_amount (entry_number));
        end if;
        --
        -- Determine the next available period in which to place the
        -- correction entry
        --
        ssp_smp_support_pkg.get_entry_details (
          p_date_earned  => old_entry.week_commencing,
          p_last_process_date => person.final_process_date,
          p_person_id  => person.person_id,
          p_element_type_id => g_PAD_Correction_element.element_type_id,
          p_element_link_id => old_entry.element_link_id,
          p_assignment_id  => old_entry.assignment_id,
          p_effective_start_date => old_entry.effective_start_date,
          p_effective_end_date => old_entry.effective_end_date,
          p_pay_as_lump_sum => person.pay_PAD_as_lump_sum);
        --
        -- hr_entry_api's take the lookup meanings not the lookup codes.
        -- converted rate codes to meanings before calling the
        -- api.  Later fix made old_entry (csr_existing_entries) return
        -- the meaning, so rate passed directly.
        --
        hr_entry_api.insert_element_entry (
          p_effective_start_date=> old_entry.effective_start_date,
          p_effective_end_date => old_entry.effective_end_date,
          p_element_entry_id  => l_dummy,
          p_target_entry_id  => old_entry.element_entry_id,
          p_assignment_id  => old_entry.assignment_id,
          p_element_link_id  => old_entry.element_link_id,
          p_creator_type  => c_PAD_creator_type,
          p_creator_id  => p_maternity_id,
          p_entry_type  => c_PAD_entry_type,
          p_input_value_id1=> g_PAD_correction_element.rate_id,
          p_input_value_id2=> g_PAD_correction_element.week_commencing_id,
          p_input_value_id3=> g_PAD_correction_element.amount_id,
          p_input_value_id4=> g_PAD_correction_element.recoverable_amount_id,
          p_entry_value1=> old_entry.rate,
--          p_entry_value2=> old_entry.week_commencing,
       -- p_entry_value2  => to_char(old_entry.week_commencing,'DD-MON-YYYY'),
	  p_entry_value2  => fnd_date.date_to_chardate(old_entry.week_commencing),
          p_entry_value3=> old_entry.amount * -1,
          p_entry_value4=> old_entry.recoverable_amount * -1);
        --
        --New entry will be created by brand_new_entries loop if not p_deleting
      end if;
      --
    end loop old_entries;
    --
    -- Having been through all the existing entries, we now check that we
    -- have dealt with all the newly derived entries by inserting any which
    -- were not flagged as dealt with during the above actions.
    --
    hr_utility.set_location (l_proc,20);
    --
    <<BRAND_NEW_ENTRIES>>
    begin
      if p_deleting then
        hr_utility.trace('Deleting an absence so don''t insert entries');
      else
        for new_entry in 1..g_PAD_element.maximum_PPP LOOP
          if (not hypothetical_entry.dealt_with (new_entry) = 'TRUE')
            and (not hypothetical_entry.stopped (new_entry) = 'TRUE')
          then
            hr_entry_api.insert_element_entry (
              p_effective_start_date =>
                          hypothetical_entry.effective_start_date (new_entry),
              p_effective_end_date =>
                          hypothetical_entry.effective_end_date (new_entry),
              p_element_entry_id => l_dummy,
              p_assignment_id  => hypothetical_entry.assignment_id (new_entry),
              p_element_link_id => hypothetical_entry.element_link_id (new_entry),
              p_creator_type  => c_PAD_creator_type,
              p_creator_id  => p_maternity_id,
              p_entry_type  => c_PAD_entry_type,
              p_input_value_id1 => g_PAD_element.rate_id,
              p_input_value_id2 => g_PAD_element.week_commencing_id,
              p_input_value_id3 => g_PAD_element.amount_id,
              p_input_value_id4 => g_PAD_element.recoverable_amount_id,
              p_entry_value1  => hypothetical_entry.rate (new_entry),
--            p_entry_value2  => hypothetical_entry.week_commencing (new_entry),
              p_entry_value2  => to_char(hypothetical_entry.week_commencing(new_entry),'DD-MON-YYYY'),
              p_entry_value3  => hypothetical_entry.amount (new_entry),
              p_entry_value4  =>
                          hypothetical_entry.recoverable_amount (new_entry));
          end if;
        end loop brand_new_entries;
      end if;
    exception
      when no_data_found then
        --
        -- We have run out of hypothetical entries to insert
        --
        null;
        --
    end;
    --
    -- Orphaned stoppages, associated with deleted absence can now be deleted
    -- This replaces cross product constraints that are no longer allowed.
    --
    open csr_no_of_absences;
    fetch csr_no_of_absences into l_no_of_absence_periods;
    close csr_no_of_absences;
    --
    if l_no_of_absence_periods = 0 then
      remove_stoppages;
    end if;
    --
    hr_utility.set_location(' Leaving: '||l_proc,100);
    --
  end save_hypothetical_entries;
	--
procedure derive_PAD_week (p_week_number in integer) is
	--
	-- Derive the start and end dates of the week covered by the PAD
	-- payment. This is done by finding out how many weeks into the APP
	-- we are and finding the offset from the start date.
	--
	begin
	--
	hr_utility.set_location ('Entering: ssp_pad_pkg.derive_PAD_week',1);
	hr_utility.trace ('Entry number = '||to_char (p_week_number));
	--
	hypothetical_entry.week_commencing (p_week_number)
		:= (person.APP_start_date + ((p_week_number -1) * 7));
	--
	hypothetical_entry.dealt_with (p_week_number) := 'FALSE';
	hypothetical_entry.stopped (p_week_number) := 'FALSE';
	hypothetical_entry.element_link_id (p_week_number) := null;
	hypothetical_entry.assignment_id (p_week_number) := null;
	--
	hr_utility.trace ('week_commencing = '
		||to_char (hypothetical_entry.week_commencing (p_week_number)));
		--
	hr_utility.set_location ('Leaving : ssp_pad_pkg.derive_PAD_week',100);
	--
	end derive_PAD_week;
	--
procedure Check_PAD_stoppages (p_week_number in integer) is
	--
	-- Find any PAD stoppage for the Adoption which overlaps a date range
	--
	employee_died varchar2 (30) := 'Employee died';
	--
	cursor csr_stoppages (p_start_date in date, p_end_date in date) is
		--
		-- Find any non-overridden stoppages
		--
		select	1
		from	ssp_stoppages STP,
			ssp_withholding_reasons WRE
		where	stp.override_stoppage <> 'Y'
		--
		-- and the stoppage ovelaps the period or the stoppage is for
		-- death and is prior to the period
		--
		and	((wre.reason <> employee_died
			   and stp.withhold_from <= p_end_date
			   and nvl (stp.withhold_to, hr_general.end_of_time)
				>= p_start_date)
			--
			or (wre.reason = employee_died
			   and stp.withhold_from < p_start_date))
		--
		and	stp.maternity_id = p_maternity_id
		and	stp.reason_id = wre.reason_id;
		--
	l_dummy	integer (1);
	--
	begin
	--
	hr_utility.set_location ('ssp_pad_pkg.Check_PAD_stoppages',1);
	--
	hypothetical_entry.stopped (p_week_number) := 'FALSE';
	--
	open csr_stoppages (
		hypothetical_entry.week_commencing (p_week_number),
		ssp_smp_support_pkg.end_of_week
			(hypothetical_entry.week_commencing (p_week_number)));
	--
	fetch csr_stoppages into l_dummy;
	--
	if csr_stoppages%found
	then
	  --
	  -- There is an overlap between the PAD week and a stoppage so no PAD
	  -- is payable.
	  --
	  hypothetical_entry.stopped (p_week_number) := 'TRUE';
	  --
	  hr_utility.trace ('Entry is STOPPED');
	  --
	  -- Keep a tally of the number of stopped weeks
	  --
	  l_stopped_weeks := l_stopped_weeks +1;
	end if;
	--
	close csr_stoppages;
	--
	hr_utility.set_location ('ssp_pad_pkg.Check_PAD_stoppages',10);
	--
	end Check_PAD_stoppages;
	--
procedure Calculate_correct_PAD_rate (p_week_number in number) is
	--
	-- The entry API takes the lookup meanings so we must find
	-- the meanings rather than the codes for PAD rates.
	--
	cursor csr_rate_meaning (p_rate_band varchar2) is
		--
	        select	meaning
		from	hr_lookups
		where	lookup_type = 'SPP_RATES'
		and	lookup_code = p_rate_band;
		--
	begin
	--
	hr_utility.set_location ('ssp_pad_pkg.Calculate_correct_PAD_rate',1);
	--
	if l_high_rate is null then
	  --
	  -- Get the meanings for the rate bands
	  --
	  -- Get the higher rate band
	  --
	  open csr_rate_meaning ('STD');
	  fetch csr_rate_meaning into l_high_rate;
	  close csr_rate_meaning;

	end if;
	--
/*
	if (p_week_number - l_stopped_weeks)
		<= g_SMP_element.period_at_higher_rate
	then
	  hr_utility.set_location ('ssp_smp_pkg.Calculate_correct_SMP_rate',1);
	  --
	  -- We have not yet given the employee all their higher rate weeks
	  --
*/
	  hypothetical_entry.rate (p_week_number) := l_high_rate;
/*
	else
	  hypothetical_entry.rate (p_week_number) := l_low_rate;
	end if;
*/
	--
	hr_utility.trace ('PAD Rate = '
		||hypothetical_entry.rate (p_week_number));
		--
	hr_utility.set_location ('ssp_pad_pkg.Calculate_correct_PAD_rate',10);
	--
	end Calculate_correct_PAD_rate;
	--
procedure Calculate_PAD_amounts (p_week_number in integer, p_APP_start_date in date) is
	--
	begin
	--
	hr_utility.set_location('Entering: ssp_sAp_pkg.Calculate_SaP_amounts',1);
	--
	-- Get the PAD element for each week in case the PAD rate has changed
	--
	get_PAD_element (hypothetical_entry.week_commencing (p_week_number));
	--
    hypothetical_entry.amount (p_week_number)
		:= least (round (
			(average_earnings * g_PAD_element.SPP_rate)
				+ 0.0049,2),
			g_PAD_element.STANDARD_RATE);
	--
	hypothetical_entry.recoverable_amount (p_week_number)
		:= round (hypothetical_entry.amount (p_week_number)
			* g_PAD_element.recovery_rate,2);
	--
	hr_utility.trace ('PAD amount = '
		||to_char (hypothetical_entry.amount (p_week_number)));
	hr_utility.trace ('Recoverable amount = '
	||to_char (hypothetical_entry.recoverable_amount (p_week_number)));
	--
	hr_utility.set_location('Leaving : ssp_pad_pkg.Calculate_PAD_amounts',100);
	--
	end calculate_PAD_amounts;
	--
	procedure check_parameters is
	begin
	hr_api.mandatory_arg_error (
		p_api_name	=> l_proc,
		p_argument	=> 'maternity_id',
		p_argument_value=> p_maternity_id);
		--
	end check_parameters;
	--
begin
--
hr_utility.set_location ('ssp_pad_pkg.generate_payments',1);
--
check_parameters;
--
<<PAD_WEEKS>>
--
if person.APP_start_date is not null then
   for week_number in 1..g_PAD_element.maximum_PPP
   LOOP
      --
      -- Derive hypothetical entries ie those entries which would be applied for a
      -- completely new maternity. Store them internally because we must check
      -- previously created entries before applying the hypothetical entries to the
      -- database.
      --
      Derive_PAD_week			(week_number);
      Check_PAD_stoppages			(week_number);
      Calculate_correct_PAD_rate		(week_number);
      Calculate_PAD_amounts		(week_number, person.APP_start_date);
      --
      if (hypothetical_entry.stopped (week_number) = 'FALSE') then
      --
      -- Get the entry details unless the entry has been stopped (in which case
      -- we do not need the entry details and errors may occur if we call the
      -- procedure; eg the woman's assignment ends)
      --
         ssp_smp_support_pkg.get_entry_details	(
            p_date_earned          => hypothetical_entry.week_commencing
                                                (week_number),
            p_pay_as_lump_sum      => person.pay_PAD_as_lump_sum,
            p_last_process_date    => person.final_process_date,
            p_person_id            => person.person_id,
            p_element_type_id      => g_PAD_element.element_type_id,
            p_element_link_id      => hypothetical_entry.element_link_id
                                                (week_number),
            p_assignment_id        => hypothetical_entry.assignment_id
                                                (week_number),
            p_effective_start_date => hypothetical_entry.effective_start_date
                                                (week_number),
            p_effective_end_date   => hypothetical_entry.effective_end_date
                                                (week_number));
      end if;
   end loop PAD_weeks;
end if;
--
Save_hypothetical_entries(p_deleting);
--
end generate_payments;
--
--------------------------------------------------------------------------------
procedure PAD_control (p_maternity_id	in number,
                       p_deleting       in boolean default FALSE) is
--
-- p_deleting parameter added to deal with absences being deleted, without
-- maternity being deleted.
--

-- Find out if the maternity exists
--
cursor csr_maternity is
select 1
from   ssp_maternities
where  maternity_id = p_maternity_id;

--
-- Get all element entries associated with a maternity
--
cursor csr_entries is
select entry.element_entry_id,
       entry.effective_start_date
from   per_absence_attendances PAA,
       per_all_assignments_f   PAAF,
       pay_element_entries_f   entry
where  PAA.maternity_id = p_maternity_id
and    PAAF.person_id = PAA.person_id
and    entry.creator_type = 'M'
and    entry.creator_id = p_maternity_id
and    entry.assignment_id = paaf.assignment_id;
--
cursor csr_count_absences is
select count(*)
from   ssp_maternities mat,
       per_absence_attendances ab
where  mat.maternity_id = p_maternity_id
and    ab.person_id = mat.person_id
and    ab.maternity_id = mat.maternity_id;
        --
l_count number;
l_dummy	number;
l_proc	varchar2 (72) := g_package||'PAD_control';
--
begin
--
  hr_utility.set_location (l_proc,1);
  --
  open csr_maternity;
  fetch csr_maternity into l_dummy;

  --
  -- Recalculate PAD
  --
  if csr_maternity%found then
     if entitled_to_PAD (p_maternity_id) then
        open csr_count_absences;
        fetch csr_count_absences into l_count;
        close csr_count_absences;
        if l_count > 0 then
            generate_payments (p_maternity_id, false);
        else
            generate_payments (p_maternity_id, p_deleting);
        end if;
     elsif p_deleting then
        -- not entitled but deleting absence then
        generate_payments (p_maternity_id, p_deleting);
     end if;
  else
    --
    -- The maternity may have been deleted. Remove any element entries associated
    -- with it (the absences, stoppages and medicals are handled by constraints).
    --
    for obsolete in csr_entries LOOP
      hr_utility.trace (l_proc||'	Deleting element entry_id '||
                        to_char (obsolete.element_entry_id));
      hr_utility.trace (l_proc||'-------------------------------------------');
      --
      hr_entry_api.delete_element_entry (
                           p_dt_delete_mode    => 'ZAP',
                           p_session_date      => obsolete.effective_start_date,
                           p_element_entry_id  => obsolete.element_entry_id);
    end loop;
  end if;
  --
  hr_utility.set_location (l_proc,100);
  --
end PAD_control;
--------------------------------------------------------------------------------
end ssp_PAD_pkg;

/
