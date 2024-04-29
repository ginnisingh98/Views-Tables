--------------------------------------------------------
--  DDL for Package Body HR_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ENTRY" as
/* $Header: pyeentry.pkb 120.14.12010000.12 2009/10/07 11:59:30 priupadh ship $ */
--
-- NAME
-- hr_entry.return_termination_date
--
-- DESCRIPTION
-- Returns the actual_termination_date if an assignment has been
-- terminated.
-- If the assignment has not been terminated then the returned
-- actual_termination_date date will be null.
--
 g_debug boolean := hr_utility.debug_enabled;
 function return_termination_date(p_assignment_id in number,
                                  p_session_date  in date)
          return date is
   l_actual_termination_date    date;
 begin
--
-- Select the actual termination date is the assignment has been
-- terminated.
--
   if g_debug then
      hr_utility.set_location('hr_entry.return_termination_date', 1);
      hr_utility.trace('        p_assignment_id : '|| p_assignment_id);
      hr_utility.trace('        p_session_date : '|| p_session_date);
   end if;
   begin
     select  pos.actual_termination_date
     into    l_actual_termination_date
     from    per_periods_of_service pos,
             per_assignments_f      pa
     where   pos.person_id     = pa.person_id
     and     pa.assignment_id  = p_assignment_id
     and     p_session_date
     between pa.effective_start_date
     and     pa.effective_end_date
     and     pos.actual_termination_date is not null;
  exception
    when NO_DATA_FOUND then
      null;
  end;
--
  return(l_actual_termination_date);
--
 end return_termination_date;
--
-- NAME
-- hr_entry.get_nonrecurring_dates
--
-- DESCRIPTION
-- Called when a nonrecurring entry is about to be created. Makes sure that
-- the assignment is to a payroll and also a time period exists. Returns the
-- start and end dates of the nonrecurring entry taking into account
-- changes in payroll.
--
 procedure get_nonrecurring_dates
 (
  p_assignment_id         in     number,
  p_session_date          in     date,
  p_effective_start_date     out nocopy date,
  p_effective_end_date       out nocopy date,
  p_payroll_id               out nocopy number,
  p_period_start_date        out nocopy date,
  p_period_end_date          out nocopy date
 ) is
--
   -- Local Variables
   v_payroll_id                number;
   v_asg_effective_start_date  date;
   v_asg_effective_end_date    date;
   v_time_period_start_date    date;
   v_time_period_end_date      date;
   v_start_date                date;
   v_end_date                  date;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hr_entry.get_nonrecurring_dates',5);
      hr_utility.trace('        p_assignment_id : '|| p_assignment_id);
      hr_utility.trace('        p_session_date : '|| p_session_date);
   end if;
--
   -- Retrieve the payroll for the assignment on the date the nonrecurring
   -- entry is being created NB if there is no payroll then it is invalid to
   -- create a nonrecurring entry.
   begin
--
     select asg.payroll_id,
            asg.effective_start_date,
            asg.effective_end_date
     into   v_payroll_id,
            v_asg_effective_start_date,
            v_asg_effective_end_date
     from   per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
       and  asg.payroll_id is not null
       and  p_session_date between asg.effective_start_date
                               and asg.effective_end_date;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6047_ELE_ENTRY_NO_PAYROLL');
       hr_utility.raise_error;
   end;
--
   if g_debug then
      hr_utility.set_location('hr_entry.get_nonrecurring_dates',10);
      hr_utility.trace('        v_payroll_id : '|| v_payroll_id);
      hr_utility.trace('        v_asg_effective_start_date : '|| v_asg_effective_start_date);
      hr_utility.trace('        v_asg_effective_end_date : '|| v_asg_effective_end_date);
   end if;
--
   -- Retrieve the start and end dates of the period for the payroll on the
   -- date on which the nonrecurring entry is being created NB. a payroll
   -- period must exist for a nonrecurring entry to be created.
   begin
--
     select tim.start_date,
            tim.end_date
     into   v_time_period_start_date,
            v_time_period_end_date
     from   per_time_periods tim
     where  tim.payroll_id = v_payroll_id
       and  p_session_date between tim.start_date
                               and tim.end_date;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6614_PAY_NO_TIME_PERIOD');
       hr_utility.raise_error;
   end;
--
   if g_debug then
      hr_utility.set_location('hr_entry.get_nonrecurring_dates',15);
      hr_utility.trace('        v_time_period_start_date : '|| v_time_period_start_date);
      hr_utility.trace('        v_time_period_end_date : '|| v_time_period_end_date);
   end if;
--
   -- Current assignment record starts after the beginning of the time period.
   -- 8798020 Removed date track joins from below query
   if v_asg_effective_start_date > v_time_period_start_date then
--
     loop
--
       begin
--
         select asg.effective_start_date
         into   v_start_date
         from   per_assignments_f asg
         where  asg.assignment_id = p_assignment_id
           and  asg.effective_end_date = v_asg_effective_start_date - 1
           and  asg.assignment_type = 'E' ;

     -- bug 6485636
--         and  asg.payroll_id + 0 = v_payroll_id;
--
       exception
         when no_data_found then exit;
       end;
--
       v_asg_effective_start_date := v_start_date;
--
     end loop;
--
   end if;
--
   if g_debug then
      hr_utility.set_location('hr_entry.get_nonrecurring_dates',20);
      hr_utility.trace('        v_start_date : '|| v_start_date);
   end if;
--
   -- Current assignment record ends before the finish of the time period.
   -- 8798020 Removed date track joins from below query
   if v_asg_effective_end_date < v_time_period_end_date then
--
     loop
--
       begin
--
         select asg.effective_end_date
         into   v_end_date
         from   per_assignments_f asg
         where  asg.assignment_id = p_assignment_id
           and  asg.effective_start_date - 1 = v_asg_effective_end_date
           and  asg.assignment_type = 'E' ;

     -- bug 6485636
--         and  asg.payroll_id + 0 = v_payroll_id;
--
       exception
         when no_data_found then exit;
       end;
--
       v_asg_effective_end_date := v_end_date;
--
     end loop;
--
   end if;
--
   if g_debug then
      hr_utility.set_location('hr_entry.get_nonrecurring_dates',25);
      hr_utility.trace('        v_end_date : '|| v_end_date);
   end if;
--
   -- Return the start and end dates of the nonrecurring entry.
   p_effective_start_date := greatest(v_asg_effective_start_date,
                                      v_time_period_start_date);
   p_effective_end_date   := least(v_asg_effective_end_date,
                                   v_time_period_end_date);

   if g_debug then
      hr_utility.trace('        p_effective_start_date : '|| p_effective_start_date);
      hr_utility.trace('        p_effective_end_date : '|| p_effective_end_date);
   end if;
--
   -- Return the payroll and the start and end dates for the period.
   p_payroll_id           := v_payroll_id;
   p_period_start_date    := v_time_period_start_date;
   p_period_end_date      := v_time_period_end_date;
--
 end get_nonrecurring_dates;
--
-- NAME
-- hr_entry.chk_entry_overlap
--
-- DESCRIPTION
-- When multiple entries are not allowed then make sure there are no overlaps
-- of normal entries of ther same type ie. entry_type = 'E'. For nonrecurring
-- it is important to check for nonrecurring entries within the period as it
-- it is now possible to have nonrecurring entriesthat can exist for part of
-- a period eg.
--
-- ASG      |---P1----|---P2---|---P1---|
-- EL       |-------------------------P1---------------------> (nonrecurring)
-- Period   |-------------------------------------------|
-- EE       |---------|
--
-- Try to add                  |--------|
--
-- NB. this actually clashes with the existing EE although they do not overlap.
--
 procedure chk_entry_overlap
 (
  p_element_entry_id          in number,
  p_assignment_id             in number,
  p_element_link_id           in number,
  p_processing_type           in varchar2,
  p_entry_type                in varchar2,
  p_mult_entries_allowed_flag in varchar2,
  p_validation_start_date     in date,
  p_validation_end_date       in date,
  p_period_start_date         in date,
  p_period_end_date           in date
 ) is
--
   -- Local variables
   v_overlap_occurred varchar2(1) := 'N';
--
 begin
--
   if g_debug then
      hr_utility.set_location('hr_entry.chk_entry_overlap',5);
      hr_utility.trace('        p_element_entry_id : '|| p_element_entry_id);
      hr_utility.trace('        p_assignment_id : '|| p_assignment_id);
      hr_utility.trace('        p_element_link_id : '|| p_element_link_id);
      hr_utility.trace('        p_processing_type : '|| p_processing_type);
      hr_utility.trace('        p_entry_type : '|| p_entry_type);
      hr_utility.trace('        p_mult_entries_allowed_flag : '|| p_mult_entries_allowed_flag);
      hr_utility.trace('        p_validation_start_date : '|| p_validation_start_date);
      hr_utility.trace('        p_validation_end_date : '|| p_validation_end_date);
      hr_utility.trace('        p_period_start_date : '|| p_period_start_date);
      hr_utility.trace('        p_period_end_date : '|| p_period_end_date);
   end if;
--
   -- Only do check if the entry being altered is a normal entry ie. not
   -- adjustment, additional etc ... If multiple concurrent entries are not
   -- allowed then it is invalid for two recurring entries of the same type
   -- to overlap or for two nonrecurring entries of the same type to exist
   -- within the same period.
   if p_entry_type = 'E' and p_mult_entries_allowed_flag = 'N' then
--
     begin
       -- INDEX hint added following NHS project recommendation
       select 'Y'
       into   v_overlap_occurred
       from   sys.dual
       where  exists
                (select /*+ INDEX(ee, pay_element_entries_f_n51) */ null
                 from   pay_element_entries_f ee
                 where  ee.entry_type = 'E'
                   and  ee.element_entry_id <> nvl(p_element_entry_id,0)
                   and  ee.assignment_id   = p_assignment_id
                   and  ee.element_link_id = p_element_link_id
                   and  ((p_processing_type = 'R' and
                          ee.effective_start_date <= p_validation_end_date and
                          ee.effective_end_date   >= p_validation_start_date)
                    or   (p_processing_type = 'N' and
                          ee.effective_start_date >= p_period_start_date and
                          ee.effective_end_date   <= p_period_end_date)));
--
     exception
       when no_data_found then null;
     end;
--
   end if;
--
   if v_overlap_occurred = 'Y' then
--
     hr_utility.set_message(801, 'HR_6956_ELE_ENTRY_OVERLAP');
     hr_utility.raise_error;
--
   end if;
--
 end chk_entry_overlap;
--
-- --------------------- return_qualifying_conditions -------------------------
--
-- Name: return_qualifying_conditions
--
-- Description: If the element entry link is discretionary and has
--              qualifying conditions then check the length of
--              service and age conditions.
--
-- Returns: p_los_date --> date at which the los is eligible.
--          p_age_date --> date at which the age is eligible.
--
--          If dates return null then check is not valid.
--
procedure return_qualifying_conditions
(
 p_assignment_id        in        number,
 p_element_link_id      in        number,
 p_session_date         in        date,
 p_los_date            out nocopy date,
 p_age_date            out nocopy date
) is
--
  l_status              varchar2(1) := 'S'; -- returning function status
  l_qualifying_age      number(2);
  l_qualifying_los      number(6,2);
  l_qualifying_units    varchar2(30);
  l_warning_or_error    varchar2(30);
  l_fail                varchar2(1) := 'N';
--
--WWbugs 414903 and 407604
--Single select statements for both qualifying conditions changed to explicit
--cursors and therefore eliminated p_session_date from this queries.(mlisieck)
--
  cursor csr_los_date is
  -- calculate the element entry start date according to the lenght of service
  -- qualifying condition
      select  decode(l_qualifying_units,
                     'H', p.date_start + trunc(l_qualifying_los/24),
                     'D', p.date_start + l_qualifying_los,
                     'Y', add_months(p.date_start,(12 * l_qualifying_los)),
                     'W', p.date_start + (l_qualifying_los * 7),
                      add_months(p.date_start,l_qualifying_los))
      from    per_periods_of_service p,
              per_all_assignments_f a
      where   a.assignment_id        = p_assignment_id
      and     p.period_of_service_id = a.period_of_service_id;
--
  cursor csr_age_date is
  -- calculate the element entry start date according to the qualifying age
  -- condition
     select  add_months(p.date_of_birth, (l_qualifying_age * 12))
     from    per_all_people_f  p,
             per_assignments_f asg
     where   p.person_id = asg.person_id
     and     p.date_of_birth is not null
     and     asg.assignment_id = p_assignment_id
     -- session_date comparison has been removed, so ensure that
     -- looking at the recent data.
     and p.effective_start_date = (select max(papf.effective_start_date)
                                        from per_all_people_f papf
                                        where papf.person_id = asg.person_id);
--
begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then
     hr_utility.trace(' p_assignment_id : '|| p_assignment_id);
     hr_utility.trace(' p_element_link_id : '|| p_element_link_id);
     hr_utility.trace(' p_session_date : '|| p_session_date);
   end if;
--
-- Ensure all the passed parameters exist
--
  if (p_assignment_id   is null or
      p_element_link_id is null or
      p_session_date    is null) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hr_entry.return_qualifying_conditions');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
--
-- select the qualifying conditions for los.
--
  begin
    if g_debug then
       hr_utility.set_location('hr_entry.return_qualifying_conditions', 5);
    end if;
    select  pel.qualifying_age,
            pel.qualifying_length_of_service,
            pel.qualifying_units
    into    l_qualifying_age,
            l_qualifying_los,
            l_qualifying_units
    from    pay_element_links_f pel
    where   pel.element_link_id = p_element_link_id
    and     p_session_date
    between pel.effective_start_date
    and     pel.effective_end_date;
  exception
  when NO_DATA_FOUND then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',
                                 'hr_entry.return_qualifying_conditions');
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  end;
--
  if (l_qualifying_los is not null) then
--
-- Need to select the valid los date
--
    begin
      if g_debug then
         hr_utility.set_location('hr_entry.return_qualifying_conditions', 10);
      end if;
      open csr_los_date;
      fetch csr_los_date into p_los_date;
      close csr_los_date;
    exception
    when NO_DATA_FOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_entry.return_qualifying_conditions');
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    end;
--
  end if;
--
-- Need to check the age qualification.
-- If the select does not return any rows then we can assume that the
-- DOB is null.
-- If the DOB is null then this check will be invalid and the returning
-- p_age_date will be NULL.
--
  if (l_qualifying_age is not null) then
--
    begin
     if g_debug then
        hr_utility.set_location('hr_entry.return_qualifying_conditions', 15);
     end if;
     open csr_age_date;
     fetch csr_age_date into p_age_date;
     close csr_age_date;
    exception
    when NO_DATA_FOUND then
      NULL;
    end;
--
  end if;
--
end return_qualifying_conditions;
--
-- NAME
-- hr_entry.generate_entry_id
--
-- DESCRIPTION
-- Generates then next sequence value for inserting an element entry into the
-- PAY_ELEMENT_ENTRIES_F base table.
--
 FUNCTION generate_entry_id return number is
 v_element_entry_id    number;
--
 begin
--
-- Select the next element_entry_id unique primary key id
--
   begin
     SELECT PAY_ELEMENT_ENTRIES_S.NEXTVAL
     INTO   v_element_entry_id
     FROM   SYS.DUAL;
   exception
     when NO_DATA_FOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','hr_entry.generate_entry_id');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end;
--
-- Return the next element_entry_id unique primary key id
--
    return v_element_entry_id;
--
 end generate_entry_id;
--
-- NAME
-- hr_entry.generate_run_result_id
--
-- DESCRIPTION
-- Generates then next sequence value for inserting a run result into the
-- PAY_RUN_RESULTS base table.
--
 FUNCTION generate_run_result_id return number is
 v_run_result_id    number;
--
 begin
--
-- Select the next run_result_id unique primary key id
--
   begin
     SELECT PAY_RUN_RESULTS_S.NEXTVAL
     INTO   v_run_result_id
     FROM   SYS.DUAL;
   exception
     when NO_DATA_FOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','hr_entry.generate_run_result_id');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end;
--
-- Return the next run_result_id unique primary key id
--
    return v_run_result_id;
--
 end generate_run_result_id;
--
-- NAME
-- hr_entry.entry_process_in_run
--
-- DESCRIPTION
-- This function return a boolean value for the specified
-- element_type_id depending on the process_in_run_flag attribute.
-- The function returns TRUE if the process_in_run_flag = 'Y' or
-- FALSE if the process_in_run_flag
--
 FUNCTION entry_process_in_run (p_element_type_id in number,
                                p_session_date    in date) return boolean is
 v_process_in_run_flag varchar2(1);
-- bugfix 703103 change select into to cursor in order to rmove the need for
-- the session_date restriction that was used to ensure only one row would
-- be returned. This allow the employee termination procedure to proceed
-- for elements only defined after the termination date.
cursor c1 is select  pet.process_in_run_flag
     from    pay_element_types_f pet
     where   pet.element_type_id = p_element_type_id;
--
 begin

   if g_debug then
     hr_utility.trace('         p_element_type_id : '|| p_element_type_id);
     hr_utility.trace('         p_session_date : '|| p_session_date);
   end if;

   begin
   open c1;
   fetch c1 into v_process_in_run_flag;
   if c1%NOTFOUND then
     close c1;
     hr_utility.set_message(801, 'HR_6884_ELE_ENTRY_NO_ELEMENT');
     hr_utility.set_message_token('DATE_SUPPLIED',p_session_date);
     hr_utility.raise_error;
   end if;
   close c1;
   end;
--
  return (v_process_in_run_flag = 'Y');
 end entry_process_in_run;
--------------------------------------------------------------------------------
--
-- NAME
-- hr_entry.Assignment_eligible_for_link
--
-- DESCRIPTION
-- Returns 'Y' if the specified assignment and link match as at the
-- specified date. A match indicates that the assignment is eligible for
-- the link as at that date. This function may be called from within SQL.
-- If no match is found then 'N' will be returned (it never returns NULL).
-- NB The reason this function does not return BOOLEAN is that the boolean
-- datatype is not supported in SQL statements.
--
function assignment_eligible_for_link (
--
p_assignment_id         in natural,
p_element_link_id       in natural,
p_effective_date        in date,
p_creator_type          in varchar2) return varchar2 is
--
lpi_effective_date constant date := trunc (p_effective_date);
        /*
        || Make sure that code will work even if user passes a time portion in the
        || p_effective_date. Refer to lpi_effective_date instead of p_effective_date
        || throughout the code.
        */
all_parameters_are_valid constant boolean :=
        (
        p_assignment_id is not null
        and p_element_link_id is not null
        and p_effective_date is not null
        );
--
cursor csr_eligibility is
        --
        -- Return a row if a match is found between the element link criteria
        -- and the attributes of the assignment as at the effective date
        --
        select  'Y' ROW_RETURNED
        from    per_assignments_f ASG,
                pay_element_links_f   PEL
        where   lpi_effective_date between pel.effective_start_date
                                        and pel.effective_end_date
        and     lpi_effective_date between asg.effective_start_date
                                        and asg.effective_end_date
        and     pel.element_link_id = P_ELEMENT_LINK_ID
        and     asg.assignment_id = P_ASSIGNMENT_ID
        and   ((pel.payroll_id is not null
        and     asg.payroll_id = pel.payroll_id)
        or     (pel.link_to_all_payrolls_flag = 'Y'
        and     asg.payroll_id is not null)
        or     (pel.payroll_id is null
        and     pel.link_to_all_payrolls_flag = 'N'))
        and    (pel.organization_id = asg.organization_id
        or      pel.organization_id is null)
        and    (pel.position_id = asg.position_id
        or      pel.position_id is null)
        and    (pel.job_id = asg.job_id
        or      pel.job_id is null)
        and    (pel.grade_id = asg.grade_id
        or      pel.grade_id is null)
        and    (pel.location_id = asg.location_id
        or      pel.location_id is null)
-- start of change 115.20 --
        and    (
                pel.pay_basis_id = asg.pay_basis_id
                or
                --
                -- if EL is associated with a pay basis then this clause fails
                --
                pel.pay_basis_id is null and
                NOT EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    p_effective_date between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                    )
                or
                --
                -- if EL is associated with a pay basis then the associated
                -- PB_ID must match the PB_ID on ASG
                --
                pel.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    p_effective_date between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.pay_basis_id = asg.pay_basis_id
                    )
-- change 115.23
                or
                pel.pay_basis_id is null and
                asg.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    p_effective_date between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                    )
 -- bug 7434613
                OR
                 pel.pay_basis_id is null and
                 p_creator_type IN ('RR','EE')
               )
-- end of change 115.20 --
        and    (pel.employment_category = asg.employment_category
        or      pel.employment_category is null)
        and    (pel.people_group_id is null
        or     exists
                (select  1
                from    pay_assignment_link_usages_f palu
                where   palu.assignment_id   = P_ASSIGNMENT_ID
                and     palu.element_link_id = P_ELEMENT_LINK_ID
                and     lpi_effective_date between palu.effective_start_date
                                                and palu.effective_end_date))
;
        --
l_eligibility   varchar2 (1) := 'N';
--
begin

if g_debug then
  hr_utility.trace('In hr_entry.assignment_eligible_for_link');
  hr_utility.trace('    p_assignment_id : '|| p_assignment_id);
  hr_utility.trace('    p_element_link_id : '|| p_element_link_id);
  hr_utility.trace('    p_effective_date : '|| p_effective_date);
  hr_utility.trace('    p_creator_type : '|| p_creator_type);
end if;
--
hr_general.assert_condition (all_parameters_are_valid);
--
open csr_eligibility;
fetch csr_eligibility into l_eligibility;
close csr_eligibility;
--
hr_utility.trace('      l_eligibility : '|| l_eligibility);
--
return l_eligibility;
--
end assignment_eligible_for_link;
--------------------------------------------------------------------------------
-- NAME
-- hr_entry.assignment_eligible_for_link
--
-- DESCRIPTION
-- Bugfix 7434613
-- Overloaded version provided for backwards compatibility.
--
function assignment_eligible_for_link (
  --
p_assignment_id         in natural,
p_element_link_id       in natural,
p_effective_date        in date) return varchar2 is
--
l_eligibility varchar2 (1) := 'N';
--
begin
   --
   -- Call the new assignment_eligible_for_link procedure, passing in null
   -- for the p_creator_type
   --
  l_eligibility := assignment_eligible_for_link
                     (
                        p_assignment_id      => p_assignment_id,
                        p_element_link_id    => p_element_link_id,
                        p_effective_date     => p_effective_date,
                        p_creator_type       => null
                        );
   --
   return l_eligibility; /*Bug 8798020 Added missing return statement */
end assignment_eligible_for_link;
--------------------------------------------------------------------------------
--
-- NAME
-- hr_entry.chk_asg_visible
--
-- DESCRIPTION
-- Raise error PAY_34811_ENTRY_MAINT_SEC_ASG if the user does not have the
-- appropriate privileges to see the assignment identifed by p_assignment_id.
--
procedure chk_asg_visible (p_assignment_id in number, p_session_date in date)
is
  --
  cursor csr_sec_asg(p_asg_id number, p_session_date date) is
  select 1
  from per_assignments_f
  where assignment_id = p_asg_id
  and p_session_date between effective_start_date and effective_end_date;
  --
  v_asg_visible number;
begin
  --
  if g_debug then
    hr_utility.set_location('hr_entry.chk_asg_visible', 1);
    hr_utility.trace('  p_assignment_id : '|| p_assignment_id);
    hr_utility.trace('  p_session_date : '|| p_session_date);
  end if;
  --
  -- Check to see if this assignment is visible to a secure user.
  -- If not then raise error.
  -- Bug 5867658.
  --
  open csr_sec_asg(p_assignment_id, p_session_date);
  fetch csr_sec_asg into v_asg_visible;

  hr_utility.trace('    v_asg_visible : '|| v_asg_visible);
  --
  if csr_sec_asg%notfound then
    --
    if g_debug then
      hr_utility.set_location('hr_entry.chk_asg_visible', 2);
      hr_utility.trace('        Assignment ID Not Found: '||p_assignment_id);
    end if;
    --
    -- The user is not authorized to process this assignment.
    --
    close csr_sec_asg;
    --
    hr_utility.set_message(801,'PAY_34811_ENTRY_MAINT_SEC_ASG');
    hr_utility.raise_error;
    --
  end if;
  --
  close csr_sec_asg;
  --
  if g_debug then
    hr_utility.set_location('hr_entry.chk_asg_visible', 3);
  end if;
  --
end chk_asg_visible;
--------------------------------------------------------------------------------
-- NAME
-- hr_entry.get_eligibility_period
--
-- DESCRIPTION
-- This procedure selects the minimum or maximum (or both) effective assignment
-- dates where the assignment is eligible for a given element link.
--
procedure get_eligibility_period (
--
p_assignment_id         in number, -- Assignment being given the element entry
                                   --
p_element_link_id       in number, -- Link through which the eligibility for the
                                   -- element is granted
                                   --
p_session_date          in date, -- Context date for datetrack selection.
                                 --
-- Bugfix 5135065
-- Added parameters p_time_period_start_date and p_time_period_end_date.
p_creator_type IN varchar2, -- Bug 7434613. Creator type used in assignment_eligible for link
                            -- to skip pay_basis criteria validation for retro entry creation
p_time_period_start_date in date, -- Beginning of the time period under
                                  -- consideration, should contain the
                                  -- payroll period start date if a non-
                                  -- recurring entry is being created
                                  --
p_time_period_end_date   in date, -- End of the time period under
                                  -- consideration, should contain the
                                  -- payroll period end date if a non-
                                  -- recurring entry is being created
                                  --
p_min_eligibility_date in out nocopy date, -- The earliest date that the assignment is eligible
                                    -- for the element, in an unbroken period encompassing
                                    -- the session date (See explanation below).
                                    --
p_max_eligibility_date in out nocopy date  -- The latest date that the assignment is eligible
                                    -- for the element, in an unbroken period encompassing
                                    -- the session date (See explanation below).
                                    --
) is
--
cursor  csr_link_bounds is
        --
        -- Get the outer boundaries of the link date effectivity
        -- NB The aggregate functions mean that this cursor will
        -- ALWAYS return a row.
        --
        select  min (effective_start_date) LINK_START,
                max (effective_end_date) LINK_END
        from    pay_element_links_f
        where   element_link_id = P_ELEMENT_LINK_ID;
--
cursor csr_assignment_bounds is
        --
        -- Get the outer boundaries of the assignment date effectivity
        -- NB The aggregate functions mean that this cursor will
        -- ALWAYS return a row

        select  min (paf.effective_start_date) ASGT_START,
                max (paf.effective_end_date) ASGT_END
        from    per_assignments_f paf
        where   paf.assignment_id = P_ASSIGNMENT_ID
        and     paf.assignment_type in ('E','B','C') ; 	 -- Added assignment_type 'C' in the check for bug 8792107
	 -- Added assignment_type 'B' in the check for bug 8371393
         --and   paf.assignment_type = 'E' ;              -- Added assignment_type check for bug 7648259
--
cursor csr_minimum (p_assignment_id number, lpi_session_date date, p_time_period_start_date date) is
        --
        select  asg1.effective_end_date
        from    per_assignments_f   asg1
        where   asg1.assignment_id = p_assignment_id
        -- Removed the following predicate as it is redundant
        -- i.e. If assignment end date is less than session date then it
        -- follows that the assignment start date must be less than
        -- session date.
        --and     asg1.effective_start_date <= lpi_session_date
        and     asg1.effective_end_date <= lpi_session_date
        -- Bugfix 5135065
        -- Exclude any pieces of the assignment that end before the time period
        -- start date
        and     asg1.effective_end_date >= p_time_period_start_date
        order by asg1.effective_end_date desc;
--
cursor csr_maximum (p_assignment_id number, lpi_session_date date, p_time_period_end_date date) is
        select  asg1.effective_start_date
        from    per_assignments_f   asg1
        where   asg1.assignment_id       = p_assignment_id
        and     asg1.effective_end_date >= lpi_session_date
        -- Bugfix 5135065
        -- Exclude any pieces of the assignment that start after the time
        -- period end date
        and     asg1.effective_start_date <= p_time_period_end_date
        order by asg1.effective_start_date;
        --
l_link                  csr_link_bounds%rowtype;
l_assignment            csr_assignment_bounds%rowtype;
-- Bugfix 5135065
-- Local time period start and end date variables
l_time_period_start_date date;
l_time_period_end_date   date;
--
no_current_eligibility  exception;
--
l_procedure_name constant varchar2 (80) := 'hr_entry.get_eligibility_period';
lpi_session_date constant date := trunc (p_session_date);
--
all_parameters_are_valid constant boolean :=
        (
        p_assignment_id is not null
        and p_element_link_id is not null
        and p_session_date is not null
        );
--
begin
--
if g_debug then
   hr_utility.set_location(l_procedure_name,1);
   hr_utility.trace('   p_assignment_id : '|| p_assignment_id);
   hr_utility.trace('   p_element_link_id : '|| p_element_link_id);
   hr_utility.trace('   p_session_date : '|| p_session_date);
   hr_utility.trace('   p_creator_type : '|| p_creator_type);
   hr_utility.trace('   p_time_period_start_date : '|| p_time_period_start_date);
   hr_utility.trace('   p_time_period_end_date : '|| p_time_period_end_date);
   hr_utility.trace('   p_min_eligibility_date : '|| p_min_eligibility_date);
   hr_utility.trace('   p_max_eligibility_date : '|| p_max_eligibility_date);
end if;
--
-- Initialize "out" parameters
--
P_MIN_ELIGIBILITY_DATE := null;
P_MAX_ELIGIBILITY_DATE := null;
--
if g_debug then
   hr_utility.set_location(l_procedure_name,2);
end if;
--
-- Get the outer bounds of the link
--
open csr_link_bounds;
fetch csr_link_bounds into l_link;
close csr_link_bounds;
--
-- Get the outer bounds of the assignment
--
open csr_assignment_bounds;
fetch csr_assignment_bounds into l_assignment;
close csr_assignment_bounds;
--
if g_debug then
  hr_utility.trace('    l_link.LINK_START : '|| l_link.LINK_START);
  hr_utility.trace('    l_link.LINK_END : '|| l_link.LINK_END);
  hr_utility.trace('    l_assignment.ASGT_START : '|| l_assignment.ASGT_START);
  hr_utility.trace('    l_assignment.ASGT_END : '|| l_assignment.ASGT_END);
end if;
--
if
   -- if the link does not exist as at session date
   (lpi_session_date NOT between l_link.link_start and l_link.link_end)
or
   -- or if the link and assignment never overlap
   NOT (l_link.link_end >= l_assignment.asgt_start
       and l_link.link_start <= l_assignment.asgt_end)
then
  --
  raise no_current_eligibility;
  --
end if;
--
if g_debug then
   hr_utility.set_location(l_procedure_name,3);
end if;
--
-- Check that the parameters are valid (doing it here allows us to
-- encompass a check that the cursors returned values correctly)
--
hr_general.assert_condition (all_parameters_are_valid
                        and l_assignment.asgt_start is not null -- p_assignment_id is a valid row
                        and l_link.link_start is not null -- p_element_link_id is a valid row
                              );
--
if not
  (p_session_date between l_assignment.asgt_start and l_assignment.asgt_end)
then
  --
  -- Assignment does not exist at session date, or the user does not have
  -- the appropriate privileges to edit the assignment as at the session
  -- date, raise an error
  --
  if g_debug then
     hr_utility.set_location(l_procedure_name,4);
  end if;
  hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE',
                               'hr_entry.get_eligibility_period');
  hr_utility.set_message_token('STEP','4');
  hr_utility.raise_error;
  --
end if;
--
if g_debug then
   hr_utility.set_location(l_procedure_name,5);
end if;
--
-- Get the minimum date on which the assignment is eligible for the
-- link in an unbroken period encompassing the session date. The cursor
-- looks for the latest date prior to the session date on which there is
-- NO eligibility for the link, then adds one to that date. This is done to
-- cater for the following situation:
--
-- Asgt +---------+---------------+--------+-------------->
-- Link      |-------------------------------------------->
--
-- Eligible?      |----YES--------|  NO    |-----YES------>
--
-- Session date                                 X
--
-- Ref Points     A                        B
--
-- If we selected the minimum start date on which the assignment
-- IS eligible for the link, we would not take account of the gap
-- in eligibility which occurs prior to the session date. In other
-- words, we would get the date at point A instead of at point B,
-- which is the correct date. If the session date is such that
-- there is no row prior to the session date that is not eligible
-- for the link, then we must take the start date of the assignment
-- as the returned date. However, also remember that the link may
-- start between the returned date and the session date so use
-- the greater of these dates as the minimum eligibility date.
--
-- We return all date track assignment pieces
-- backwards in time, looking for the first
-- piece that is not eligible. This gives us
-- our minimum eligibility date.
--
-- Bugfix 5135065
-- Initialize time period start and end dates
--
-- NOTE:
-- The time period dates should only have been passed in from chk_element_-
-- entry_main where they will have been derived for a non-recurring
-- entry, or an equivalent entry type that behaves like a non-recurring
-- entry, e.g. a retropay entry, and hence will represent the start and end
-- dates of the payroll period. The time period dates should be null in all
-- other cases, and will be initialized to appropriate start of time/end of
-- time values below.
--
-- We want to consider the time period start and end dates when dealing
-- specifically with non-recurring entries in order to reduce the number of
-- 'assignment pieces' that need to be examined and hence reduce the number
-- of calls to the expensive assignment_eligibile_for_link procedure. For
-- example, we are not interested in assignment pieces that end before the
-- start date of the time period, or that begin after the end date of the
-- time period, since non-recurring entries CANNOT exist beyond the time
-- period they are created in.
--
-- Default the time period start date to the 'start of time' if null...
l_time_period_start_date := nvl(p_time_period_start_date, hr_general.start_of_time);
-- Default the time period end date to the 'end of time' if null...
l_time_period_end_date   := nvl(p_time_period_end_date, hr_general.end_of_time);
--
if g_debug then
   hr_utility.trace('  l_time_period_start_date: '||to_char(l_time_period_start_date,'DD-MON-YYYY'));
   hr_utility.trace('  l_time_period_end_date: '||to_char(l_time_period_end_date,'DD-MON-YYYY'));
end if;
-- Bugfix 5135065
-- We are not interested in assignment pieces that end before the beginning
-- of the time period, so we pass the time period start date to csr_minimum
for c1rec in csr_minimum(p_assignment_id, lpi_session_date, l_time_period_start_date) loop
   if(hr_entry.assignment_eligible_for_link(
                  p_assignment_id,
                  p_element_link_id,
                  least (c1rec.effective_end_date, l_link.link_end),
                  p_creator_type) = 'N')
   then
      -- As soon as we have found an assignment row
      -- that exists but is not eligible, we set
      -- the minimum date and exit the loop.
      P_MIN_ELIGIBILITY_DATE := greatest ((c1rec.effective_end_date + 1),
                                           l_link.link_start);
      exit;
   end if;
end loop;

if g_debug then
  hr_utility.trace('    After csr_minimum, P_MIN_ELIGIBILITY_DATE : '|| P_MIN_ELIGIBILITY_DATE);
end if;
--
-- Bugfix 4114282, handle the potentially null min eligibility date...
--
if(P_MIN_ELIGIBILITY_DATE is null) then
   P_MIN_ELIGIBILITY_DATE := greatest (l_assignment.asgt_start, l_link.link_start);
end if;
--
if g_debug then
   hr_utility.trace ('  P_MIN_ELIGIBILITY_DATE = '||to_char (P_MIN_ELIGIBILITY_DATE));
end if;
if P_MIN_ELIGIBILITY_DATE > lpi_session_date then
  raise no_current_eligibility;
end if;
--
if g_debug then
   hr_utility.set_location(l_procedure_name,6);
end if;
--
-- Get the maximum date on which the assignment is eligible for the
-- link in an unbroken period encompassing the session date. See above
-- for an explanation of the approach taken in this cursor; obviously we
-- are looking for the other end of the eligibility period. The two cursors
-- cannot be combined because we need to reverse the session date restriction.
--

--
-- We return all date track assignment pieces
-- forwards in time, looking for the first
-- piece that is not eligible. This gives us
-- our maximum eligibility date.

-- Bugfix 5135065
--
-- NOTE:
-- We are not interested in assignment pieces that start after the end
-- of the time period, so we pass the time period end date to csr_maximum.
-- This should reduce the number of times we need to call the expensive
-- assignment_eligible_for_link function.
-- See above explanation.
for c1rec in csr_maximum(p_assignment_id, lpi_session_date, l_time_period_end_date) loop
   if(hr_entry.assignment_eligible_for_link(
               p_assignment_id,
               p_element_link_id,
               greatest (c1rec.effective_start_date, l_link.link_start),
               p_creator_type) = 'N')
   then
      -- As soon as we have found an assignment row
      -- that exists but is not eligible, we set
      -- the minimum date and exit the loop.
      P_MAX_ELIGIBILITY_DATE := least ((c1rec.effective_start_date - 1),
                                        l_link.link_end);
      exit;
   end if;
end loop;

if g_debug then
  hr_utility.trace('    After csr_maximum, P_MAX_ELIGIBILITY_DATE : '|| P_MAX_ELIGIBILITY_DATE);
end if;

-- If the max date is null, there were no rows returned.
if(P_MAX_ELIGIBILITY_DATE is null) then
   P_MAX_ELIGIBILITY_DATE := least (l_assignment.asgt_end, l_link.link_end);
end if;

--
if g_debug then
   hr_utility.trace ('  P_MAX_ELIGIBILITY_DATE = '||to_char (P_MAX_ELIGIBILITY_DATE));
end if;
if P_MAX_ELIGIBILITY_DATE < lpi_session_date then
  raise no_current_eligibility;
end if;
--
if g_debug then
   hr_utility.set_location(l_procedure_name,7);
end if;
--
exception
--
when no_current_eligibility
then
  --
  -- Provide a helpful error message explaining which assignment
  -- and element failed, and on what date.
  --
  if g_debug then
     hr_utility.set_location (l_procedure_name,999);
  end if;
  --
  declare
  --
  cursor csr_error_element is
        --
        -- Get the name of the element for which there was no eligibility.
        -- NB We know p_element_link_id and lpi_session_date are valid because
        -- a value_error would have been raised by the assert_condition call
        -- in the main body code otherwise.
        --
        select  elt_tl.element_name
        from    pay_element_types_f_tl  ELT_TL,
                pay_element_types_f     ELT,
                pay_element_links_f     LINK
        where   elt.element_type_id = link.element_type_id
        and     elt_tl.element_type_id = elt.element_type_id
        and     P_ELEMENT_LINK_ID = link.element_link_id
        and     userenv('LANG') = elt_tl.language
        and     lpi_session_date between link.effective_start_date
                                and link.effective_end_date
        and     lpi_session_date between elt.effective_start_date
                                and elt.effective_end_date;
        --
  cursor csr_error_assignment is
        --
        -- Get the number of the assignment which was not eligible.
        -- NB We know p_assignment_id and lpi_session_date are valid because
        -- a value_error would have been raised by the assert_condition call
        -- in the main body code otherwise.
        --
        select  assignment_number
        from    per_assignments_f
        where   assignment_id = P_ASSIGNMENT_ID
        and     lpi_session_date between effective_start_date
                                and effective_end_date;
        --
  l_assignment  csr_error_assignment%rowtype;
  l_element     csr_error_element%rowtype;
  --
  begin
  --
  open csr_error_element;
  fetch csr_error_element into l_element;
  close csr_error_element;
  --
  open csr_error_assignment;
  fetch csr_error_assignment into l_assignment;
  close csr_error_assignment;
  --
  hr_utility.set_message(801, 'HR_51271_ELE_NOT_ELIGIBLE');
  hr_utility.set_message_token ('ELEMENT_NAME', l_element.element_name);
  hr_utility.set_message_token ('ASSIGNMENT_NUMBER', l_assignment.assignment_number);
  hr_utility.set_message_token ('SESSION_DATE', to_char (lpi_session_date));
  hr_utility.raise_error;
  --
  end;
  --
end get_eligibility_period;
--------------------------------------------------------------------------------
-- NAME
-- hr_entry.get_eligibility_period
--
-- DESCRIPTION
-- Bugfix 5135065
-- Overloaded version provided for backwards compatibility. Refer to new
-- get_eligibility_period procedure for description.
--
procedure get_eligibility_period (
  p_assignment_id         in number,
  p_element_link_id       in number,
  p_session_date          in date,
  p_min_eligibility_date  in out nocopy date,
  p_max_eligibility_date  in out nocopy date
) is
begin
   --
   -- Call the new get_eligibility_period procedure, passing in null
   -- for the time period start and end dates
   --
   get_eligibility_period (
     p_assignment_id          => p_assignment_id
    ,p_element_link_id        => p_element_link_id
    ,p_session_date           => p_session_date
    -- Bugfix 5135065
    -- Set time period start and end dates to null
    ,p_creator_type           => null
    ,p_time_period_start_date => null
    ,p_time_period_end_date   => null
    ,p_min_eligibility_date   => p_min_eligibility_date
    ,p_max_eligibility_date   => p_max_eligibility_date
   );
   --
end get_eligibility_period;
--------------------------------------------------------------------------------
-- NAME
-- hr_entry.entry_asg_pay_link_dates
--
-- DESCRIPTION
-- This procedure returns the min(effective_start/end_date) for a specified
-- element link and payroll. Also, if the specified employee assignment has
-- been terminated the element termination date as of the termination rule is
-- returned.
--
procedure entry_asg_pay_link_dates (
  p_assignment_id            in            number,
  p_element_link_id          in            number,
  p_session_date             in            date,
  p_element_term_rule_date      out nocopy date,
  p_element_link_start_date     out nocopy date,
  p_element_link_end_date       out nocopy date,
  p_payroll_start_date          out nocopy date,
  p_payroll_end_date            out nocopy date,
  p_entry_mode               in            boolean default true
)
is
  --
  v_element_term_rule_date     date;
  v_element_link_start_date    date;
  v_element_link_end_date      date;
  v_payroll_start_date         date;
  v_payroll_end_date           date;
  v_asg_term_date              date;
  v_post_termination_rule      varchar2(30);
  v_processing_type            varchar2(30);
  v_period_of_service_id       number;
  -- Bugfix 5616075
  v_actual_termination_date    date;
  v_last_standard_process_date date;
  v_final_process_date         date;
  v_employee_terminated        boolean := false;
  v_orig_term_rule_date_func   varchar2(30); -- value of 'EE_ORIG_TERM_RULE_DATE_FUNC' action parameter
  v_action_param_found         boolean;
  --
  v_primary_flag               varchar2(30);
  --
  -- Procedure Parameter Name    Description
  -- ==========================  ==================================================
  -- p_assignment_id             Holds the employee assignment id.
  -- p_element_link_id           Holds the element link id.
  -- p_session_date              Holds the current session effective date.
  -- p_element_term_rule_date    Holds the element termination date.
  -- p_element_link_start_date   Holds the element link start date.
  -- p_element_link_end_date     Holds the element link end date.
  -- p_payroll_start_date        Holds the payroll start date.
  -- p_payroll_end_date          Holds the payroll end date.
  --
  -- Local Parameter Name        Description
  -- ==========================  ==================================================
  -- v_element_term_rule_date    Holds the element termination date.
  -- v_element_link_start_date   Holds the element link start date.
  -- v_element_link_end_date     Holds the element link end date.
  -- v_payroll_start_date        Holds the payroll start date.
  -- v_payroll_end_date          Holds the payroll end date.
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  -- Ensure all mandatory parameters exist.
  --
  hr_general.assert_condition (p_assignment_id is not null
                           and p_element_link_id is not null
                           and p_session_date is not null
                           and p_session_date = trunc (p_session_date));
  --
  if g_debug then
     --
     hr_utility.trace('begin hr_entry.entry_asg_pay_link_dates');
     hr_utility.trace('  p_session_date:'           || To_Char(p_session_date,'DD-MON-YYYY'));
     hr_utility.trace('  p_assignment_id:'          || p_assignment_id);
     hr_utility.trace('  p_element_link_id:'        || p_element_link_id);
     --
  end if;
  --
  -- Select the element termination processing rule, assignment period of
  -- service and assignment primary flag
  --
  if g_debug then
     hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 1);
  end if;
  --
  begin
    --
    select  asg.period_of_service_id,
            asg.primary_flag,
            -- Bugfix 5616075
            pos.actual_termination_date,
            pos.last_standard_process_date,
            pos.final_process_date
    into    v_period_of_service_id,
            v_primary_flag,
            v_actual_termination_date,
            v_last_standard_process_date,
            v_final_process_date
    from    per_assignments_f asg,
            per_periods_of_service pos
    where   asg.assignment_id = p_assignment_id
    and     asg.period_of_service_id = pos.period_of_service_id (+)
    and     p_session_date between asg.effective_start_date
                           and     asg.effective_end_date;

   if g_debug then
     hr_utility.trace('         v_period_of_service_id : '|| v_period_of_service_id);
     hr_utility.trace('         v_primary_flag : '|| v_primary_flag);
     hr_utility.trace('         v_actual_termination_date : '|| v_actual_termination_date);
     hr_utility.trace('         v_last_standard_process_date : '|| v_last_standard_process_date);
     hr_utility.trace('         v_final_process_date : '|| v_final_process_date);
   end if;
    --
    select  pet.post_termination_rule,
            pet.processing_type
    into    v_post_termination_rule,
            v_processing_type
    from    pay_element_types_f pet,
            pay_element_links_f pel
    where   p_session_date between pel.effective_start_date
                           and     pel.effective_end_date
    and     pel.element_link_id = p_element_link_id
    and     pet.element_type_id = pel.element_type_id
    and     p_session_date between pet.effective_start_date
                           and     pet.effective_end_date;
    --
  exception
    --
    when NO_DATA_FOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',
                                   'hr_entry.entry_asg_pay_link_dates');
      hr_utility.set_message_token('STEP','2');
    end;
  --
  if g_debug then
    --
    hr_utility.trace('  v_post_termination_rule :' || v_post_termination_rule);
    hr_utility.trace('  v_processing_type :' || v_processing_type);
    --
    -- Actual termination date...
    if v_actual_termination_date is not null then
      hr_utility.trace('  v_actual_termination_date>' ||
        to_char(v_actual_termination_date, 'DD-MON-YYYY') || '<');
    else
      hr_utility.trace('  v_actual_termination_date><');
    end if;
    --
    -- Last standard process date...
    if v_last_standard_process_date is not null then
      hr_utility.trace('  v_last_standard_process_date>' ||
        to_char(v_last_standard_process_date, 'DD-MON-YYYY') || '<');
    else
      hr_utility.trace('  v_last_standard_process_date><');
    end if;
    --
    -- Final process date...
    if v_final_process_date is not null then
      hr_utility.trace('  v_final_process_date>' ||
        to_char(v_final_process_date, 'DD-MON-YYYY') || '<');
    else
      hr_utility.trace('  v_final_process_date><');
    end if;
    --
  end if; -- if g_debug.
  --
  -- Bugfix 5616075
  -- Get value of EE_ORIG_TERM_RULE_DATE_FUNC action parameter
  --
  pay_core_utils.get_action_parameter (
    'EE_ORIG_TERM_RULE_DATE_FUNC',
    v_orig_term_rule_date_func,
    v_action_param_found
  );
  --
  if not v_action_param_found then
    -- Default to 'N' so we use the new behaviour
    v_orig_term_rule_date_func := 'N';
  end if;
  --
  if g_debug then
    hr_utility.trace('  v_orig_term_rule_date_func: '||v_orig_term_rule_date_func);
  end if;
  --
  v_employee_terminated :=
    (v_actual_termination_date is not null or
     v_last_standard_process_date is not null or
     v_final_process_date is not null);
  --
  -- Original behaviour:
  -- -------------------
  -- If the employee assignment is primary then check to see if terminated then
  -- select the correct element termination date.
  --
  -- New behaviour:
  -- --------------
  -- Since bug 5616075...
  -- Treat primary and secondary assignments the same when the employee is
  -- terminated.
  --
  if (v_orig_term_rule_date_func = 'N' and v_employee_terminated) or -- New behaviour
     (v_orig_term_rule_date_func = 'Y' and v_primary_flag = 'Y') then -- Old behaviour
    --
    if g_debug then
       hr_utility.trace('  employee terminated');
       hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 2);
       hr_utility.trace('       v_post_termination_rule :' || v_post_termination_rule);
    end if;
    --
    -- Get the termination rule date
    --
    if v_post_termination_rule = 'L' then
      v_element_term_rule_date := nvl(v_last_standard_process_date, hr_general.end_of_time);
    elsif v_post_termination_rule = 'F' then
      v_element_term_rule_date := nvl(v_final_process_date, hr_general.end_of_time);
    else
      v_element_term_rule_date := nvl(v_actual_termination_date, hr_general.end_of_time);
    end if;
    --
    -- Bug 382760. If termination rule is Actual Termination or Last Standard
    -- Process and element is Nonrecurring then entries close down on the last day
    -- of the pay period. Only recurring entries close down on the termination
    -- date.
    --
    if v_post_termination_rule in ('A','L') and v_processing_type = 'N' then
      --
      begin
        --
        -- Bugfix 5487637
        -- Get the end date of the period in which the element termination
        -- rule date occurs...
        --
        select ptp.end_date
        into v_element_term_rule_date
        from per_all_assignments_f asg,
             per_time_periods ptp
        where asg.assignment_id = p_assignment_id
        and   p_session_date between asg.effective_start_date and asg.effective_end_date
        and   asg.payroll_id = ptp.payroll_id
        and   v_element_term_rule_date between ptp.start_date and ptp.end_date;
        --
      exception
        --
        when no_data_found then
          -- It's possible a NO_DATA_FOUND error was raised by the period end
          -- date fetch, in which case we want to retain the (unmodified)
          -- v_element_term_rule_date. A 'NVL' achieves this for us...
          v_element_term_rule_date := nvl(v_element_term_rule_date,hr_general.end_of_time);
          --
      end;
      --
    end if;
    --
    -- Bug 7555483
    -- A primary assignment can become secondary in future and can get terminated afterwards.
    -- If an Element Entry is made in period when it was primary ,Entry End date was not populating
    -- as the code checks the future assignmnet status of TERM/END only for secondary assignment.
    -- Commented the check "elsif v_primary_flag <> 'Y'" and the else part
    -- Now code will check for future TERM/END status for both primary and secondary assignment .

/* Commenting for Bug 7555483 elsif v_primary_flag <> 'Y' then  */
  else
    --
    -- Logic for non-terminated, primary/Secondary assignment...
    --
    if g_debug then
       hr_utility.trace('  employee NOT terminated');
       hr_utility.trace('  primary/Secondary assignment');
    end if;
    --
    -- The assignment is NOT a PRIMARY assignment therefore we need to check
    -- if the current or future assignment has an assignment status of
    -- 'TERM_ASSIGN' or 'END_ASSIGN'
    --
    -- First we need to check if the current or future assignment rows have
    -- a 'TERM_ASSIGN' status.
    --
    if g_debug then
       hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 3);
    end if;
    begin
      select  min(asg.effective_start_date)
      into    v_asg_term_date
      from    per_assignments_f           asg,
              per_assignment_status_types ast
      where   asg.assignment_id             = p_assignment_id
      and     asg.effective_end_date       >= p_session_date
      and     asg.assignment_status_type_id = ast.assignment_status_type_id
      and     ast.per_system_status         = 'TERM_ASSIGN';
    end;
    --
    -- If the employee assignment does NOT have a 'TERM_ASSIGN' then we must check
    -- to see if an 'END' exists.
    --
    if v_asg_term_date is null then
      --
      if g_debug then
         hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 4);
      end if;
      --
      begin
        select  asg.effective_start_date
        into    v_asg_term_date
        from    per_assignments_f           asg,
                per_assignment_status_types ast
        where   asg.assignment_id             = p_assignment_id
        and     asg.effective_end_date       >= p_session_date
        and     asg.assignment_status_type_id = ast.assignment_status_type_id
        and     ast.per_system_status         = 'END';
      exception
        when NO_DATA_FOUND then NULL;
      end;
      --
      -- As the employee assignment does have the 'END' status the element
      -- termination processing rule will always be the effective_start_date.
      --
      if v_asg_term_date is null then
        v_element_term_rule_date := hr_general.end_of_time;
      else
        v_element_term_rule_date := v_asg_term_date;
      end if;
      --
      -- As the employee assignment does have the 'TERM_ASSIGN' status we must
      -- derive the element termination processing rule from the following rules:
      -- If ((termination processing rule = 'A') or
      --     (termination processing rule = 'L' and
      --      assignment is not to a payroll) then
      --   termination processing date = the min(asg.effective_start_date)
      -- ElsIf (the termination processing rule = 'L' and
      --        assignment is to payroll) then
      --   termination processing date = last date of current period as of
      --                                 the min(asg.effective_start_date)
      -- ElsIf the termination processing rule = 'F' then
      --   termination processing date = max(aasg.effective_end_date)
      -- End If
      --
    else
      --
      if (v_post_termination_rule = 'A') then
        --
        -- Bugfix  4710356
        -- Set the term rule end date to the last day of the payroll
        -- period for non-recurring entries. This will allow the
        -- entry to be created for the entire payroll period, even
        -- though the assignment is 'terminated' in the middle of
        -- the period. This new behaviour is consistent with the rules
        -- for creating non-recurring entries against terminated
        -- primary assignments.
        --
        if v_processing_type = 'N' then
          begin
            select  ptp.end_date
            into    v_element_term_rule_date
            from    per_time_periods  ptp,
                    per_assignments_f asg
            where   asg.assignment_id = p_assignment_id
            and     v_asg_term_date between asg.effective_start_date and asg.effective_end_date
            and     asg.payroll_id is not null
            and     ptp.payroll_id = asg.payroll_id
            and     v_asg_term_date between ptp.start_date and ptp.end_date;
          exception
            when NO_DATA_FOUND then
              v_element_term_rule_date := v_asg_term_date - 1;
          end;
        else
          v_element_term_rule_date := v_asg_term_date - 1;
        end if;
      elsif (v_post_termination_rule = 'F') then
        if g_debug then
           hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 5);
        end if;
        begin
          select max(asg.effective_end_date)
          into   v_element_term_rule_date
          from   per_assignments_f asg
          where  asg.assignment_id         = p_assignment_id
          and    asg.effective_start_date >= v_asg_term_date;
        end;
      elsif (v_post_termination_rule = 'L') then
        if g_debug then
           hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 6);
        end if;
        /*
          begin
            select  ptp.end_date
            into    v_element_term_rule_date
            from    per_time_periods  ptp,
                    per_assignments_f asg
            where   asg.assignment_id = p_assignment_id
            and     v_asg_term_date
            between asg.effective_start_date
            and     asg.effective_end_date
            and     asg.payroll_id is not null
            and     ptp.payroll_id = asg.payroll_id
            and     v_asg_term_date
            between ptp.start_date
            and     ptp.end_date;
          exception
            when NO_DATA_FOUND then
              v_element_term_rule_date := v_asg_term_date - 1;
          end;
        */
        --
        -- bugfix 1010165,
        -- when creating ALUs on TERM assignments, periodicity is not a concern,
        -- previously the code was trying to get the beginning of the TERM assignment,
        -- find the period effective at this date, and return the end date of this
        -- period as the element termination rule,
        -- this could be less the ED (the ESD of the EL), thus error
        -- HR_6370_ELE_ENTRY_NO_TERM was returned,
        --
        -- for Last Standard Process entries on TERM assignments, periods do not
        -- apply, the entry can span out to the EED of the TERM assignment,
        -- nb. the EED of the ALU is limited by the EED of the EL and TERM assignment
        --
        /*v_element_term_rule_date := v_asg_term_date;  Added for Bug 8485543 and commented below*/

        begin
          select max(asg.effective_end_date)
          into   v_element_term_rule_date
          from   per_assignments_f asg
          where  asg.assignment_id         = p_assignment_id
          and    asg.effective_start_date >= v_asg_term_date;
        end;
        --
      end if;
      --
    end if;
    --
/*Commented for Bug 7555483 Begin comment */
--  else
    --
    -- Logic for non-terminated, primary assignment...
    --
--    if g_debug then
--       hr_utility.trace('  employee NOT terminated');
--       hr_utility.trace('  PRIMARY assignment');
--    end if;
    --
--    v_element_term_rule_date := hr_general.end_of_time;
    --
/*End Comment*/
  end if;
  --
  if g_debug then
     hr_utility.trace('  v_element_term_rule_date: ' || to_char(v_element_term_rule_date,'DD-MON-YYYY'));
  end if;
  --
  -- check to see if the v_element_term_rule_date is being set to before
  -- the session date.
  --
  if ((v_element_term_rule_date <> hr_general.end_of_time) and
      (v_element_term_rule_date < p_session_date) and p_entry_mode) then
    --
    hr_utility.set_message(801, 'HR_6370_ELE_ENTRY_NO_TERM');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Select the minimum and maximum element link dates.
  --
  if g_debug then
     hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 7);
  end if;
  --
  begin
    select min(pel.effective_start_date),
           max(pel.effective_end_date)
    into   v_element_link_start_date,
           v_element_link_end_date
    from   pay_element_links_f pel
    where  pel.element_link_id = p_element_link_id;
  end;
  --
  if (v_element_link_start_date > p_session_date) or
     (v_element_link_end_date   < p_session_date) then
    hr_utility.set_message(801, 'HR_6132_ELE_ENTRY_LINK_MISSING');
    hr_utility.raise_error;
  end if;
  --
  -- If the assignment is to a payroll then,
  -- we must select the minimum and maximum effective dates of the payroll.
  --
  if g_debug then
     hr_utility.set_location('hr_entry.entry_asg_pay_link_dates', 8);
  end if;
  begin
    select  min(pay.effective_start_date),
            max(pay.effective_end_date)
    into    v_payroll_start_date,
            v_payroll_end_date
    from    pay_all_payrolls_f    pay,
            per_all_assignments_f asg
    where   p_session_date
    between asg.effective_start_date
    and     asg.effective_end_date
    and     asg.assignment_id             = p_assignment_id
    and     asg.payroll_id is not null
    and     pay.payroll_id                = asg.payroll_id;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if ((v_payroll_start_date is not null        and
       v_payroll_end_date   is not null)       and
      (v_payroll_start_date > p_session_date   or
       v_payroll_end_date   < p_session_date)) then
    hr_utility.set_message(801, 'HR_6399_ELE_ENTRY_NO_PAYROLL');
    hr_utility.raise_error;
  end if;
  --
  -- Set values to be returned by procedure.
  --
  p_element_term_rule_date  := v_element_term_rule_date;
  p_element_link_start_date := v_element_link_start_date;
  p_element_link_end_date   := v_element_link_end_date;
  p_payroll_start_date      := v_payroll_start_date;
  p_payroll_end_date        := v_payroll_end_date;
  --
  if g_debug then
     hr_utility.trace(' end   hr_entry.entry_asg_pay_link_dates');
  end if;
  --
end entry_asg_pay_link_dates;
--
-- NAME
-- hr_entry.recurring_entry_end_date
--
-- DESCRIPTION
-- This function is used to return the valid effective end of a recurring entry.
-- The effective end date is determined by selecting the least date of:
-- 1) If the p_overlap_chk is set to 'Y' then we must check to see if any
--    recurring entries of the same link for the assignment exist in the future.
--    If yes, then we must take the min(effective_start_date) -1
-- 2) Selecting the minimum (effective_start_date - 1) from the
--    employee assignment
--    where the employee assignment is NOT eligible to the element.
--    e.g.
--                                        A         B
--    |---------------------------|-------|---------|-----------> assignment
--    |---------------------------------------------------------> element link
--    Between positions A, B the assignment has been updated and is not
--    eligible for the element link. The employee assignment is only
--    eligible to the element link upto position A and past position B.
--    Therefore, it the session date was before position A the date returned
--    would be (position A effective_start_date - 1).
-- 3) Selecting the termination processing rule end date if the current or
--    future employee assignment has been terminated.
-- 4) Selecting the effective_end_date of the element link.
--
 function recurring_entry_end_date
 (
  p_assignment_id             in number,
  p_element_link_id           in number,
  p_session_date              in date,
  p_overlap_chk               in varchar2 default 'Y',
  p_mult_entries_allowed_flag in varchar2,
  p_element_entry_id          in number,
  p_original_entry_id         in number
 ) return date is
--
 v_out_date_not_required      date;
 v_asg_max_eligibility_date   date;
 v_element_term_rule_date     date;
 v_element_link_end_date      date;
 v_recurring_end_date         date;
 v_min_max_all                varchar2(3);
 v_future_recurring_end_date  date;
 v_error_flag                 varchar2(1);
 v_current_effective_end_date date;
--
-- Function Parameter Name     Description
-- ==========================  ==================================================
-- p_assignment_id             Holds the employee assignment id.
-- p_element_link_id           Holds the element link id.
-- p_session_date              Holds the current session effective date.
--
-- Local Parameter Name        Description
-- ==========================  ==================================================
-- v_out_date_not_required     Holds a returned out date from sub-procedures
--                             which is not required.
-- v_asg_max_eligibility_date  Holds the maximum assignment eligibility date.
-- v_element_term_rule_date    Holds the element's termination processing rule
--                             date.
-- v_element_link_end_date     Holds the maximum effective_end_date of the
--                             specified element link.
-- v_recurring_end_date        Holds the end date of the recurring entry which is
--                             returned by the function.
--
 begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then
     hr_utility.trace('In hr_entry.recurring_entry_end_date');
     hr_utility.trace('         p_assignment_id : '|| p_assignment_id);
     hr_utility.trace('         p_element_link_id : '|| p_element_link_id);
     hr_utility.trace('         p_session_date : '|| p_session_date);
     hr_utility.trace('         p_overlap_chk : '|| p_overlap_chk);
     hr_utility.trace('         p_mult_entries_allowed_flag : '|| p_mult_entries_allowed_flag);
     hr_utility.trace('         p_element_entry_id : '|| p_element_entry_id);
     hr_utility.trace('         p_original_entry_id : '|| p_original_entry_id);
   end if;
--
-- Initialiize local parameters
--
   v_future_recurring_end_date := hr_general.end_of_time;
   v_error_flag                := 'N';
--
-- Ensure all mandatory parameters exist.
--
hr_general.assert_condition (p_assignment_id is not null
                        and p_element_link_id is not null
                        and p_session_date is not null
                        and p_session_date = trunc (p_session_date));
--
-- If the element_entry_id exists then we must be doing a date-effective
-- delete next/future changes therefore set the current_effective_end_date
--
   if p_element_entry_id is not null then
     if g_debug then
        hr_utility.set_location('hr_entry.recurring_entry_end_date', 0);
     end if;
     begin
       select  e.effective_end_date
       into    v_current_effective_end_date
       from    pay_element_entries_f e
       where   e.element_entry_id = p_element_entry_id
       and     p_session_date
       between e.effective_start_date
       and     e.effective_end_date;
     exception
       when NO_DATA_FOUND then NULL;
     end;
   end if;

   hr_utility.trace('   v_current_effective_end_date : '|| v_current_effective_end_date);
--
-- If the p_overlap_chk is set to 'Y' then we must check to see if any
-- recurring entries of the same link for the assignment exist in the future.
-- If yes, then we must take the min(effective_start_date) -1
--
   if upper (p_overlap_chk) = 'Y' then
     if g_debug then
        hr_utility.set_location('hr_entry.recurring_entry_end_date', 1);
     end if;
     begin
       -- INDEX hint added following NHS project recommendation
       select /*+ INDEX(pee, pay_element_entries_f_n51) */
              nvl(min(pee.effective_start_date) - 1, hr_general.end_of_time)
       into   v_future_recurring_end_date
       from   pay_element_entries_f pee
       where  pee.entry_type          = 'E'
       and    pee.assignment_id       = p_assignment_id
       and    pee.element_link_id     = p_element_link_id
       and    pee.element_entry_id <> nvl(p_element_entry_id,0)
       and    ((p_mult_entries_allowed_flag = 'Y' and
                nvl(pee.original_entry_id,pee.element_entry_id) =
                nvl(p_original_entry_id,p_element_entry_id))
        or     (p_mult_entries_allowed_flag = 'N'))
       and    pee.effective_start_date > p_session_date;
     end;

     hr_utility.trace('         v_future_recurring_end_date : '|| v_future_recurring_end_date);
--
-- If we are doing a date-effective delete then we must ensure that the
-- date returned is not the same as the current effective_end_date.
--
      if ((v_current_effective_end_date is not null and
           v_current_effective_end_date = v_future_recurring_end_date) or
           v_future_recurring_end_date < p_session_date) then
        hr_utility.set_message(801, 'HR_7699_ELE_ENTRY_REC_EXISTS');
        hr_utility.raise_error;
      end if;
--
   end if;
--
-- Bug 5867658.
-- Ensure assignment is visible to (possibly secure) user before continuing.
-- If the assignment is not visible then we want to raise a helpful message.
-- This might happen when a secure user is hiring an applicant and the
-- appropriate security has not yet been setup on the assignment, previously
-- an obsure error message (ORA-06502: PL/SQL: Numeric or Value Error ) was
-- being raised.
--
   chk_asg_visible(p_assignment_id, p_session_date);
--
-- Get the end date of the link.
--
   hr_entry.entry_asg_pay_link_dates (p_assignment_id,
                                      p_element_link_id,
                                      p_session_date,
                                      v_element_term_rule_date,
                                      v_out_date_not_required,
                                      v_element_link_end_date,
                                      v_out_date_not_required,
                                      v_out_date_not_required);
--
--
-- Find the minimum assignment (effective_start_date - 1) when the current or
-- future assignment changes is NOT eligible to the element link.
--
   hr_entry.get_eligibility_period (p_assignment_id,
                                    p_element_link_id,
                                    p_session_date,
                                    v_out_date_not_required,
                                    v_asg_max_eligibility_date);
--
-- Now set the recurring end date to be returned.
-- Note: We use the NVL function on v_payroll_end_date because if the
--       assignment is not to a payroll then the v_payroll_end_date is
--       going to be null.
--
   v_recurring_end_date := least(v_asg_max_eligibility_date,
                                 v_element_term_rule_date,
                                 v_element_link_end_date,
                                 v_future_recurring_end_date);
--
-- If the v_recurring_end_date = v_current_effective_end_date then we know
-- that the end date is trying to be set to the current effective end date.
-- We must error, being specific as to why you cannot extend the effective
-- end.
--
   if (v_current_effective_end_date is not null             and
       v_recurring_end_date = v_current_effective_end_date) then
--
-- Check to see if the error was at the element link.
--
     if v_element_link_end_date = v_current_effective_end_date then
       hr_utility.set_message(801, 'HR_6281_ELE_ENTRY_DT_DEL_LINK');
       hr_utility.raise_error;
     end if;
--
-- Check to see if the error was at the element termination processing rule.
--
     if v_element_term_rule_date = v_current_effective_end_date then
       hr_utility.set_message(801, 'HR_6283_ELE_ENTRY_DT_ELE_DEL');
       hr_utility.raise_error;
     end if;
--
-- Check to see if the error was at the eligibility level.
--
     if v_asg_max_eligibility_date = v_current_effective_end_date then
       hr_utility.set_message(801, 'HR_6284_ELE_ENTRY_DT_ASG_DEL');
       hr_utility.raise_error;
     end if;
   end if;
--
-- Return the recurring effective end date
--
   return v_recurring_end_date;
--
 end recurring_entry_end_date;
--
-- NAME
-- hr_entry.chk_element_entry_eligibility
--
-- DESCRIPTION
-- This procedure is used to check if entries (which are defined below) are
-- eligble to be inserted/deleted.
--
-- The checks performed within this procedure are as follows:
-- 1) Ensure that the entry exists within the duration of the element link.
-- 2) If the employee assignment has been terminated then ensure that the
--    entry does not exist past the termination processing rule date.
-- 3) Ensure that the element entry which is being inserted is eligible
--    through its link/assignment criteria.
--
-- This procedure should never be called when:
-- 1) Insert RECURRING element entries (because these checks are done when
--    generating the effective_end_date of the recurring entry).
-- 2) When Updating an ENTRY.
-- 3) When deleting an entry which is 'ZAP' or 'DELETE'.
--
-- This procedure is only called when:
-- 1) Inserting an NONRECURRING element entry
--    (which is defined as: Nonrecurring, Additional, Override, Adjustment,
--     Balance Adjustment etc).
--    e.g. when (p_usage = 'INSERT'         and
--             ((p_processing_type  = 'R'   and
--               p_entry_type      <> 'E')  or
--               p_processing_type  = 'N'))
--
-- 2) DateTrack deleting (Next/Future Changes) of a RECURRING element entry.
--    e.g. (p_dt_delete_mode    = 'DELETE_NEXT_CHANGE' or
--          p_dt_delete_mode    = 'FUTURE_CHANGE')
--
-- Parameter Passing when calling the procedure:
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Parameter               Description
-- ======================= ====================================================
-- p_assignment_id         The current employee asignment id.
-- p_element_link_id       The current element link id for the entry.
-- p_session_date          The current session or effective date of operation.
-- p_usage                 Set to either 'INSERT' if check is for NONRECURRING
--                         entry or 'DELETE' for DateTrack delete operations.
-- p_validation_start_date The start date for the checks.
-- p_validation_end_date   The end date for the checks.
-- p_time_period_start_date The start date of the time period in which we should
--                          check the eligibility of the assignment for the link
--                          Should be the payroll period start date for a non-recurring entry
--                          Should be NULL otherwise.
-- p_time_period_end_date   The start date of the time period in which we should
--                          check the eligibility of the assignment for the link
--                          Should be the payroll period start date for a non-recurring entry
--                          Should be NULL otherwise.
--
 PROCEDURE chk_element_entry_eligibility (p_assignment_id         in number,
                                         p_element_link_id       in number,
                                         p_session_date          in date,
                                         p_usage                 in varchar2,
                                         p_creator_type          in varchar2,
                                         p_validation_start_date in date,
                                         p_validation_end_date   in date,
                                         -- Bugfix 5135065
                                         -- Added time period start and end date parameters
                                         p_time_period_start_date in date,
                                         p_time_period_end_date in date,
                                         p_min_eligibility_date out nocopy date,
                                         p_max_eligibility_date out nocopy date) is
 v_element_term_rule_date       date;
 v_element_link_start_date      date;
 v_element_link_end_date        date;
 v_min_eligibility_date         date;
 v_max_eligibility_date         date;
 v_out_date_not_required        date;
--
-- Procedure Parameter Name     Description
-- ==========================  =================================================
-- p_assignment_id             Holds the current employee assignment id.
-- p_element_link_id           Holds the element link id.
-- p_session_date              Holds the current session effective date.
-- p_usage                     Holds either 'INSERT' or 'DELETE'.
-- p_validation_start_date     Holds the validation start date of entry.
-- p_validation_end_date       Holds the validation end date of entry.
--
-- Local Parameter Name        Description
-- ==========================  =================================================
-- v_element_term_rule_date    Holds the element termination date.
-- v_element_link_start_date   Holds the element link start date.
-- v_element_link_end_date     Holds the element link end date.
-- v_min_eligibility_date      Holds the minimum assignment link eligibility
--                             date.
-- v_max_eligibility_date      Holds the maximum assignment link eligibility
--                             date.
 begin

 if g_debug then
   hr_utility.trace('In hr_entry.chk_element_entry_eligibility');
   hr_utility.trace('   p_assignment_id : '|| p_assignment_id);
   hr_utility.trace('   p_element_link_id : '|| p_element_link_id);
   hr_utility.trace('   p_session_date : '|| p_session_date);
   hr_utility.trace('   p_usage : '|| p_usage);
   hr_utility.trace('   p_creator_type : '|| p_creator_type);
   hr_utility.trace('   p_validation_start_date : '|| p_validation_start_date);
   hr_utility.trace('   p_validation_end_date : '|| p_validation_end_date);
   hr_utility.trace('   p_time_period_start_date : '|| p_time_period_start_date);
   hr_utility.trace('   p_time_period_end_date : '|| p_time_period_end_date);
 end if;
--
-- Bug 5867658.
-- Ensure assignment is visible to (possibly secure) user before continuing.
-- If the assignment is not visible then we want to raise a helpful message.
--
     chk_asg_visible(p_assignment_id, p_session_date);
--
-- We must ensure that the entry is eligible through the payroll and link dates.
--
     hr_entry.entry_asg_pay_link_dates (p_assignment_id,
                                        p_element_link_id,
                                        p_session_date,
                                        v_element_term_rule_date,
                                        v_element_link_start_date,
                                        v_element_link_end_date,
                                        v_out_date_not_required,
                                        v_out_date_not_required);
--
-- Ensure that the element entry which is being inserted is eligible
-- through its link/assignment criteria.
--
     hr_entry.get_eligibility_period (p_assignment_id,
                                          p_element_link_id,
                                          p_session_date,
                                          -- Bugfix 5135065
                                          p_creator_type,
                                          p_time_period_start_date,
                                          p_time_period_end_date,
                                          v_min_eligibility_date,
                                          v_max_eligibility_date);

     p_min_eligibility_date := v_min_eligibility_date;
     p_max_eligibility_date := v_max_eligibility_date;
--
     if p_usage = 'INSERT' then
--
-- Bugfix 4114282
-- We now allow for a nonrecurring entry to be created for part of a
-- payroll period, even when the link only exists for part of that
-- period, as long as there is eligibility for the element.
-- Therefore, we no longer need this check...
/*
--
-- Ensure that the link exists for the duration of the entry
-- when inserting an nonrecurring entry.
--
       if (greatest(p_validation_start_date,v_min_eligibility_date) < v_element_link_start_date) or
          (least(p_validation_end_date,v_max_eligibility_date) > v_element_link_end_date)   then
         hr_utility.set_message(801, 'HR_6132_ELE_ENTRY_LINK_MISSING');
         hr_utility.raise_error;
       end if;
*/
--
-- If the employee assignment has been terminated then we must ensure that
-- the validation end date is before the element termination date.
--
       if (v_element_term_rule_date is not null and
          (v_element_term_rule_date < p_validation_end_date)) then
         hr_utility.set_message(801, 'HR_6370_ELE_ENTRY_NO_TERM');
         hr_utility.raise_error;
       end if;
--
     else
--
-- Ensure that the element link does not terminate before the
-- validation_end_date.
--
       if (p_validation_end_date > v_element_link_end_date) then
          hr_utility.set_message(801, 'HR_6281_ELE_ENTRY_DT_DEL_LINK');
          hr_utility.raise_error;
       end if;
--
-- If the employee assignment has been terminated then we must ensure that
-- the validation end date is before the element termination date.
--
       if (v_element_term_rule_date is not null and
          (v_element_term_rule_date < p_validation_end_date)) then
         hr_utility.set_message(801, 'HR_6283_ELE_ENTRY_DT_ELE_DEL');
         hr_utility.raise_error;
       end if;
--
     end if;
--
     -- Only check eligibility date against validation end date
     -- for non INSERT cases.  This is part of a change to
     -- fix bug 2183279.
     if(p_usage <> 'INSERT') then
       if (v_max_eligibility_date < p_validation_end_date) then
          hr_utility.set_message(801, 'HR_6284_ELE_ENTRY_DT_ASG_DEL');
          hr_utility.raise_error;
       end if;
     end if;
--
 end chk_element_entry_eligibility;
--
-- NAME
-- hr_entry.chk_element_entry_eligbility
--
-- DESCRIPTION
-- Bugfix 5135065
-- Overloaded version provided for backwards compatibility
-- See new chk_element_entry_eligibility [sic] for description
--
 PROCEDURE chk_element_entry_eligbility (p_assignment_id         in number,
                                         p_element_link_id       in number,
                                         p_session_date          in date,
                                         p_usage                 in varchar2,
                                         p_validation_start_date in date,
                                         p_validation_end_date   in date,
                                         p_min_eligibility_date out nocopy date,
                                         p_max_eligibility_date out nocopy date) is
 begin
   --
   -- Call the new chk_element_entry_eligibility procedure, passing in null
   -- for the time period start and end dates
   --
   chk_element_entry_eligibility (
     p_assignment_id          => p_assignment_id
    ,p_element_link_id        => p_element_link_id
    ,p_session_date           => p_session_date
    ,p_usage                  => p_usage
    ,p_creator_type           => null
    ,p_validation_start_date  => p_validation_start_date
    ,p_validation_end_date    => p_validation_end_date
    -- Bugfix 5135065
    -- Set the time period start and end dates to NULL
    ,p_time_period_start_date => null
    ,p_time_period_end_date   => null
    ,p_min_eligibility_date   => p_min_eligibility_date
    ,p_max_eligibility_date   => p_max_eligibility_date
   );
   --
 end chk_element_entry_eligbility;
--
-- NAME
-- hr_entry.chk_element_entry_open
--
-- DESCRIPTION
-- This procedure does the following checks:
-- 1) Ensure that the element type is not closed for entry currently
--    or in the future by determining the value of the
--    CLOSED_FOR_ENTRY_FLAG attribute on PAY_ELEMENT_TYPES_F.
-- 2) If the employee assignment is to a payroll then ensure that
--    the current and future periods as of session date are open.
--    If the period is closed, you can only change entries providing
--    they are not to be processed in a payroll run.
--
 procedure chk_element_entry_open
 (
  p_element_type_id       in number,
  p_session_date          in date,
  p_validation_start_date in date,
  p_validation_end_date   in date,
  p_assignment_id         in number
 ) is
--
   l_element_name          pay_element_types_f.element_name%TYPE;
   l_legislation_code      pay_element_types_f.legislation_code%TYPE;
   l_us_except             boolean := FALSE;

   cursor csr_element_type
          (
           p_element_type_id       number,
           p_validation_start_date date,
           p_validation_end_date   date
          ) is
     select et_tl.element_name,
            et.closed_for_entry_flag,
            et.legislation_code
     from   pay_element_types_f_tl et_tl,
            pay_element_types_f    et
     where  et.element_type_id = et_tl.element_type_id
       and  et.element_type_id = p_element_type_id
       and  userenv('LANG') = et_tl.language
       and  et.effective_start_date <= p_validation_end_date
       and  et.effective_end_date   >= p_validation_start_date;
--
   cursor csr_time_period
          (
           p_assignment_id         number,
           p_validation_start_date date,
           p_validation_end_date   date
          ) is
     select tp.status
     from   per_time_periods tp,
            per_assignments_f asg
     where  asg.assignment_id = p_assignment_id
       and  asg.payroll_id is not null
       and  asg.effective_start_date <= p_validation_end_date
       and  asg.effective_end_date   >= p_validation_start_date
       and  tp.payroll_id = asg.payroll_id
       and  tp.end_date >= p_validation_start_date
       and  tp.start_date <= p_validation_end_date
       and  tp.end_date   >= asg.effective_start_date
       and  tp.start_date <= asg.effective_end_date
       and  tp.status='C';
--
 begin
--
  if g_debug then
    hr_utility.trace('In hr_entry.chk_element_entry_open');
    hr_utility.trace('  p_element_type_id : '|| p_element_type_id);
    hr_utility.trace('  p_session_date : '|| p_session_date);
    hr_utility.trace('  p_validation_start_date : '|| p_validation_start_date);
    hr_utility.trace('  p_validation_end_date : '|| p_validation_end_date);
    hr_utility.trace('  p_assignment_id : '|| p_assignment_id);
  end if;
   -- LOCK the element type table in share mode so that no other user can take
   -- out an exclusive lock to change the data. This provides a stable view
   -- of the element type table. See if the element type has been closed for
   -- entry over the period of change. If it has then error !
   --lock table pay_element_types_f in share mode;
--
   for v_element_type in csr_element_type(p_element_type_id,
                                          p_validation_start_date,
                                          p_validation_end_date) loop
--
     if v_element_type.closed_for_entry_flag = 'Y' then
--
       hr_utility.set_message(801, 'HR_6064_ELE_ENTRY_CLOSED_ELE');
       hr_utility.set_message_token('element_name',v_element_type.element_name);
       hr_utility.raise_error;
--
     end if;
     l_element_name := v_element_type.element_name;
     l_legislation_code := v_element_type.legislation_code;
--
   end loop;
--
   -- LOCK the payroll table in share mode so that no other user can take
   -- out an exclusive lock to change the data. As all changes to time periods
   -- require an exclusive lock to be taken out on the payroll it provides a
   -- stable view of the time period table. See if a time period has been
   -- closed over the period of change. If it has then error !
   --lock table pay_payrolls_f in share mode;
--
   if hr_entry.entry_process_in_run(p_element_type_id, p_session_date) then
--
     for v_time_period in csr_time_period(p_assignment_id,
                                          p_validation_start_date,
                                          p_validation_end_date) loop
--
       if csr_time_period%found then
--
-- Error will not be raised for VERTEX, Workers Compensation element with
-- Legislation code as US. Bug No 506819
-- Handle the fact the legislation_code may be null. Bug 1633313.

         l_us_except := FALSE;

         if (l_legislation_code is not null AND
             l_legislation_code = 'US' AND
             l_element_name in ('US_TAX_VERTEX','VERTEX','Workers Compensation')) then
            l_us_except := TRUE;
         end if;

         if not l_us_except then
             hr_utility.set_message(801, 'HR_6074_ELE_ENTRY_CLOSE_PERIOD');
             hr_utility.raise_error;
         end if;
--
       end if;
--
     end loop;
--
   end if;
--
 end chk_element_entry_open;
--
-- NAME
-- hr_entry.derive_default_value
--
-- DESCRIPTION
-- This procedure is used to return default screen and database formatted
-- values in either a cold or hot format for the specified link and
-- input value. The default value can be for Minimum, Maximum or Default
-- values.
-- Therefore, it hot defaults are being used the returned database value
-- will be null but, the return screen value will be encapsulated in
-- double-quotation marks.
--
 PROCEDURE derive_default_value (p_element_link_id         in number,
                                 p_input_value_id          in number,
                                 p_session_date            in date,
                                 p_input_currency_code     in varchar2,
                                 p_min_max_def             in varchar2
                                                              default 'DEF',
                                 v_screen_format_value    out nocopy varchar2,
                                 v_database_format_value  out nocopy varchar2) is
 v_hot_default_flag      varchar2(30);
 v_default_value         varchar2(60);
 v_minimum_value         varchar2(60);
 v_maximum_value         varchar2(60);
 v_uom                   varchar2(60);
 v_value_format_in       varchar2(60);
-- --
 -- Enhancement 2793978
 -- Size of v_value_format_out increased to handle screen format of
 -- value set validated entry values.
 v_value_format_out      varchar2(240);
-- --
 v_lookup_type           varchar2(30);
 v_value_set_id          number(10);
--
-- Procedure Parameter Name     Description
-- ==========================  =================================================
-- p_element_link_id           Holds the element link id.
-- p_input_value_id            Holds the input value id.
-- p_session_date              Holds the current session effective date.
-- p_input_currency_code       Holds the input currency code for money uom's.
-- p_min_max_def               Determines which default value is to be
--                             specified. Valid values are MINL, MAXL,
--                             DEF or DEFL.
--                             DEFL, MINL and MAXL are used to return the
--                             default value to be used at link level.
--                             DEF is used to return the default value at
--                             entry level.
-- v_screen_format_value       Returns the screen format value.
-- v_database_format_value     Returns the database format value.
--
-- Local Parameter Name        Description
-- ==========================  ==================================================
-- v_hot_default_flag          Determines if the input value is hot defaulted.
-- v_default_value             Holds the default value.
-- v_minimum_value             Holds the minimum default value.
-- v_maximum_value             Holds the maximum default value.
-- v_uom                       Holds the unit of measure for the specified
--                             input value.
-- v_value_format_in           Holds the selected database format value to
--                             be converted into a screen format.
-- v_value_format_out          Holds the screen format value which has been
--                             converted.
 begin
   g_debug := hr_utility.debug_enabled;
--
-- Ensure that the p_min_max_def parameters contains either MINL, MAXL, DEF
-- oe DEFL as a value.
--
   if (p_min_max_def = 'MINL'  or
       p_min_max_def = 'MAXL'  or
       p_min_max_def = 'DEFL'  or
       p_min_max_def = 'DEF')  then
     null;
   else
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_entry.derive_default_value');
      hr_utility.set_message_token('STEP',1);
      hr_utility.raise_error;
   end if;
--
-- Need to determine the input value unit of measure and if it is using
-- hot or cold defaults.
--
   if g_debug then
      hr_utility.set_location('hr_entry.derive_default_value', 2);
   end if;
   begin
     select  iv.uom,
             iv.hot_default_flag,
             iv.lookup_type,
             iv.value_set_id
     into    v_uom,
             v_hot_default_flag,
             v_lookup_type,
             v_value_set_id
     from    pay_input_values_f iv
     where   iv.input_value_id = p_input_value_id
     and     p_session_date
     between iv.effective_start_date and iv.effective_end_date;
   exception
     when NO_DATA_FOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'hr_entry.derive_default_value');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
   end;
--
-- If using cold defaults then, we must select the value at the link level.
--
   if v_hot_default_flag = 'N' then
     if g_debug then
        hr_utility.set_location('hr_entry.derive_default_value', 3);
     end if;
     begin
       -- INDEX hint added following NHS project recommendation
       select  /*+ INDEX(l, pay_link_input_values_f_n2) */
               l.default_value,
               l.min_value,
               l.max_value
       into    v_default_value,
               v_minimum_value,
               v_maximum_value
       from    pay_link_input_values_f l
       where   l.input_value_id  = p_input_value_id
       and     l.element_link_id = p_element_link_id
       and     p_session_date
       between l.effective_start_date and l.effective_end_date;
     exception
       when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry.derive_default_value');
       hr_utility.set_message_token('STEP','3');
       hr_utility.raise_error;
     end;
   else
--
-- The input is hot defaulted therefore we can deduce that the values held
-- on the database are going to be null. However, we still need to select
-- the hot default values and encapsulated in quotations (").
--
     if (p_min_max_def = 'DEF') then
       if g_debug then
          hr_utility.set_location('hr_entry.derive_default_value', 4);
       end if;
       begin
         select decode(l.default_value,
                       '',i.default_value,
                       l.default_value)
         into    v_default_value
         from    pay_link_input_values_f l,
                 pay_input_values_f      i
         where   i.input_value_id  = p_input_value_id
         and     l.input_value_id  = i.input_value_id
         and     l.element_link_id = p_element_link_id
         and     p_session_date
         between i.effective_start_date and i.effective_end_date
         and     p_session_date
         between l.effective_start_date and l.effective_end_date;
       exception
         when NO_DATA_FOUND then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_entry.derive_default_value');
         hr_utility.set_message_token('STEP','4');
         hr_utility.raise_error;
       end;
     else
       if g_debug then
          hr_utility.set_location('hr_entry.derive_default_value', 5);
       end if;
       begin
         select  i.default_value,
                 i.min_value,
                 i.max_value
         into    v_default_value,
                 v_minimum_value,
                 v_maximum_value
         from    pay_input_values_f i
         where   i.input_value_id  = p_input_value_id
         and     p_session_date
         between i.effective_start_date and i.effective_end_date;
       exception
         when NO_DATA_FOUND then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_entry.derive_default_value');
         hr_utility.set_message_token('STEP','5');
         hr_utility.raise_error;
       end;
     end if;
--
   end if;
--
-- Set the format value in parameter.
--
   if   (p_min_max_def = 'DEF'   or
         p_min_max_def = 'DEFL') then
         v_value_format_in := v_default_value;
   elsif p_min_max_def = 'MINL' then
         v_value_format_in := v_minimum_value;
   elsif p_min_max_def = 'MAXL' then
         v_value_format_in := v_maximum_value;
   end if;
--
-- Now format the required valued to the display value required.
-- If the value is a lookup then we must select the meaning from the
-- lookup table.
--
   if (v_lookup_type is not null      and
       v_value_format_in is not null) then
     if g_debug then
        hr_utility.set_location('hr_entry.derive_default_value', 6);
     end if;
     begin
       select h.meaning
       into   v_value_format_out
       from   hr_lookups h
       where  h.lookup_type = v_lookup_type
       and    h.lookup_code = v_value_format_in;
     exception
       when NO_DATA_FOUND then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
                                      'hr_entry.derive_default_value');
         hr_utility.set_message_token('STEP','6');
         hr_utility.raise_error;
     end;
   --
   -- Enhancement 2793978
   -- If the value uses a value set for validation we need to decode
   -- the value to its corresponding value set meaning
   --
   elsif (v_value_set_id is not null and
          v_value_format_in is not null) then
     if g_debug then
       hr_utility.set_location('hr_entry.derive_default_value', 7);
     end if;
     v_value_format_out := pay_input_values_pkg.decode_vset_value(
       v_value_set_id,v_value_format_in);
     if v_value_format_out is null then
       --
       -- The value must have been invalid for the value set since no
       -- corresponding meaning was found, raise an error
       --
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry.derive_default_value');
       hr_utility.set_message_token('STEP','7');
       hr_utility.raise_error;
     end if;
   else
     hr_chkfmt.changeformat (v_value_format_in,
                             v_value_format_out,
                             v_uom,
                             p_input_currency_code);
   end if;
--
-- If the element is hot defaulted then
--    set the display value  = encapsulate the formatted value in '"'
--    set the database value = null
-- else
--    set the display value  = formatted value
--    set the database value = format in value
-- End If;
--
   if v_hot_default_flag = 'Y' then
     if v_value_format_out is NULL then
       v_screen_format_value  := v_value_format_out;
     else
       v_screen_format_value   := '"'||v_value_format_out||'"';
     end if;
     v_database_format_value := '';
   else
      v_screen_format_value   := v_value_format_out;
      v_database_format_value := v_value_format_in;
   end if;
--
 end derive_default_value;
--
-- NAME
-- hr_entry.chk_mandatory_input_value
--
-- DESCRIPTION
-- This procedure produces an error is any input value which is defined as
-- having a mandatory value is null.
--
 PROCEDURE chk_mandatory_input_value (p_input_value_id  in number,
                                      p_entry_value     in varchar2,
                                      p_session_date    in date,
                                      p_element_link_id in number) is
 v_hot_default_flag     varchar2(30);
 v_mandatory_flag       varchar2(30);
 v_name                 varchar2(80);
 v_default_value        varchar2(60);
--
 begin
 g_debug := hr_utility.debug_enabled;
 if g_debug then
    hr_utility.set_location ('hr_entry.chk_mandatory_input_value',1);
 end if;
 hr_general.assert_condition (p_session_date = trunc (p_session_date)
                        and p_input_value_id is not null
                        and p_session_date is not null);
                        --
   if (p_input_value_id is not null and
       p_entry_value    is null)    then
     if g_debug then
        hr_utility.set_location('hr_entry.chk_mandatory_input_value', 1);
     end if;
--
-- Select the hot/mandatory flag details.
--
     begin
       select  i.hot_default_flag,
               i.mandatory_flag,
               i_tl.name
       into    v_hot_default_flag,
               v_mandatory_flag,
               v_name
       from    pay_input_values_f_tl i_tl,
               pay_input_values_f i
       where   i.input_value_id = i_tl.input_value_id
       and     i.input_value_id = p_input_value_id
       and     userenv('LANG') = i_tl.language
       and     p_session_date
       between i.effective_start_date
       and     i.effective_end_date;
     exception
       when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry.chk_mandatory_input_value');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     end;
--
-- If the input value is mandatory ensure a value exists.
--
     if v_mandatory_flag = 'Y' then
       if v_hot_default_flag = 'N' then
--
-- Cold check.
--
         hr_utility.set_message(801, 'HR_6127_ELE_ENTRY_VALUE_MAND');
         hr_utility.set_message_token('INPUT_VALUE_NAME',v_name);
         hr_utility.raise_error;
       else
--
-- Hot check.
--
         if g_debug then
            hr_utility.set_location('hr_entry.chk_mandatory_input_value', 5);
         end if;
         begin
           select nvl(l.default_value,i.default_value)
           into    v_default_value
           from    pay_link_input_values_f l,
                   pay_input_values_f      i
           where   i.input_value_id  = p_input_value_id
           and     l.input_value_id  = i.input_value_id
           and     l.element_link_id = p_element_link_id
           and     p_session_date
           between i.effective_start_date and i.effective_end_date
           and     p_session_date
           between l.effective_start_date and l.effective_end_date;
         end;
--
         if v_default_value is null then
           hr_utility.set_message(801, 'HR_6128_ELE_ENTRY_MAND_HOT');
           hr_utility.set_message_token('INPUT_VALUE_NAME',v_name);
           hr_utility.raise_error;
         end if;
       end if;
     end if;
   end if;
 end chk_mandatory_input_value;
--
 procedure chk_mandatory_entry_values
 (
  p_element_link_id       number,
  p_validation_start_date date,
  p_num_entry_values      number,
  p_input_value_id_tbl    hr_entry.number_table,
  p_entry_value_tbl       hr_entry.varchar2_table
 ) is
--
 begin
 if g_debug then
    hr_utility.set_location ('hr_entry.chk_mandatory_entry_values',1);
 end if;
 hr_general.assert_condition (
        p_validation_start_date = trunc (p_validation_start_date));
        --
   -- For every entry value make sure that a value has been supplied if it
   -- is mandatory.
   if p_num_entry_values > 0 then
--
     for v_loop in 1..p_num_entry_values loop
--
       hr_entry.chk_mandatory_input_value(p_input_value_id_tbl(v_loop),
                                          p_entry_value_tbl(v_loop),
                                          p_validation_start_date,
                                          p_element_link_id);
--
     end loop;
--
   end if;
--
 end chk_mandatory_entry_values;
--
-- NAME
-- hr_entry.chk_element_entry
--
-- DESCRIPTION
-- This procedure is used for referential/standard checks when inserting/
-- updating or deleteing element enries.
--
-- Procedure Parameter Name    Description
-- ==========================  =================================================
-- p_element_entry_id          Holds the element entry id.
-- p_session_date              Holds the current session effective date.
-- p_element_link_id           Holds the element link id.
-- p_assignment_id             Holds the current employee assignment id.
-- p_entry_type                Holds the entry type of the entry.
-- p_effective_start_date      Holds the effective start date of entry.
-- p_effective_end_date        Holds the effective end date of entry.
-- p_validation_start_date     Holds the validation start date of entry.
-- p_validation_end_date       Holds the validation end date of entry.
-- p_dt_update_mode            If entry is being date effectively updated then
--                             the update mode is set.
-- p_dt_delete_mode            If entry is being date effectively deleted then
--                             the delete mode is set.
-- p_usage                     Determines the commit operation. Valid values are
--                             INSERT, UPDATE or DELETE.
-- p_target_entry_id           If the entry is an adjustment for a recurring
--                             entry then the target entry id holds the parent
--                             entry id.
--
 procedure chk_element_entry
 (
  p_element_entry_id         in number,
  p_original_entry_id        in number,
  p_session_date             in date,
  p_element_link_id          in number,
  p_assignment_id            in number,
  p_entry_type               in varchar2,
  p_effective_start_date     in out nocopy date,
  p_effective_end_date       in out nocopy date,
  p_validation_start_date    in date,
  p_validation_end_date      in date,
  p_dt_update_mode           in varchar2,
  p_dt_delete_mode           in varchar2,
  p_usage                    in varchar2,
  p_target_entry_id          in number
 ) is
begin
   g_debug := hr_utility.debug_enabled;

   if g_debug then

   hr_utility.trace('In hr_entry.chk_element_entry');
   hr_utility.trace('   p_element_entry_id : '|| p_element_entry_id);
   hr_utility.trace('   p_original_entry_id : '|| p_original_entry_id);
   hr_utility.trace('   p_session_date : '|| p_session_date);
   hr_utility.trace('   p_element_link_id : '|| p_element_link_id);
   hr_utility.trace('   p_assignment_id : '|| p_assignment_id);
   hr_utility.trace('   p_entry_type : '|| p_entry_type);
   hr_utility.trace('   p_effective_start_date : '|| p_effective_start_date);
   hr_utility.trace('   p_effective_end_date : '|| p_effective_end_date);
   hr_utility.trace('   p_validation_start_date : '|| p_validation_start_date);
   hr_utility.trace('   p_validation_end_date : '|| p_validation_end_date);
   hr_utility.trace('   p_dt_update_mode : '|| p_dt_update_mode);
   hr_utility.trace('   p_dt_delete_mode : '|| p_dt_delete_mode);
   hr_utility.trace('   p_usage : '|| p_usage);
   hr_utility.trace('   p_target_entry_id : '|| p_target_entry_id);

   end if;
   --
   -- simply call chk_element_entry_main with a null p_creator_type
   --
   chk_element_entry_main
   (
      p_element_entry_id,
      p_original_entry_id,
      p_session_date,
      p_element_link_id,
      p_assignment_id,
      p_entry_type,
      p_effective_start_date,
      p_effective_end_date,
      p_validation_start_date,
      p_validation_end_date,
      p_dt_update_mode,
      p_dt_delete_mode,
      p_usage,
      p_target_entry_id,
      null
   );
   --
 end chk_element_entry;
--
-- NAME
-- hr_entry.chk_element_entry_main
--
-- DESCRIPTION
-- This procedure is used for referential/standard checks when inserting/
-- updating or deleteing element enries.
--
-- Procedure Parameter Name    Description
-- ==========================  =================================================
-- p_element_entry_id          Holds the element entry id.
-- p_session_date              Holds the current session effective date.
-- p_element_link_id           Holds the element link id.
-- p_assignment_id             Holds the current employee assignment id.
-- p_entry_type                Holds the entry type of the entry.
-- p_effective_start_date      Holds the effective start date of entry.
-- p_effective_end_date        Holds the effective end date of entry.
-- p_validation_start_date     Holds the validation start date of entry.
-- p_validation_end_date       Holds the validation end date of entry.
-- p_dt_update_mode            If entry is being date effectively updated then
--                             the update mode is set.
-- p_dt_delete_mode            If entry is being date effectively deleted then
--                             the delete mode is set.
-- p_usage                     Determines the commit operation. Valid values are
--                             INSERT, UPDATE or DELETE.
-- p_target_entry_id           If the entry is an adjustment for a recurring
--                             entry then the target entry id holds the parent
--                             entry id.
-- p_creator_type              If the creator type is RetroPay Element ('EE', 'RR'),
--                             allow more than one additional entry per period.
--
 procedure chk_element_entry_main
 (
  p_element_entry_id         in number,
  p_original_entry_id        in number,
  p_session_date             in date,
  p_element_link_id          in number,
  p_assignment_id            in number,
  p_entry_type               in varchar2,
  p_effective_start_date     in out nocopy date,
  p_effective_end_date       in out nocopy date,
  p_validation_start_date    in date,
  p_validation_end_date      in date,
  p_dt_update_mode           in varchar2,
  p_dt_delete_mode           in varchar2,
  p_usage                    in varchar2,
  p_target_entry_id          in number,
  p_creator_type             in varchar2
 ) is
   --
   -- Local Variables
   --
   v_error_flag                varchar2(1) := 'N';
   v_validation_start_date     date;
   v_validation_end_date       date;
   v_payroll_id                number;
   v_period_start_date         date;
   v_period_end_date           date;
   v_loop_counter              number;
   v_mand_input_value_id       number;
   v_mand_entry_value          varchar2(60);
   v_number_of_input_values    number;
   v_counter_not_required      number;
   v_element_type_id           number;
   v_processing_type           varchar2(30);
   v_mult_entries_allowed_flag varchar2(30);
   v_third_party_pay_only_flag varchar2(30);
   v_element_name              varchar2(80);
   v_classification_name       varchar2(80);
   v_assignment_number         varchar2(30);
   v_assignment_type           varchar2(1);
   v_min_date                  date;
   v_max_date                  date;

   v_max_eligible_date         date;--8798020
   v_min_eligible_date         date;--8798020

   -- wmcveagh, bug 493056
   v_element_effective_start_date date;
   --
   cursor c_element_start_date is
      select effective_start_date
      from pay_element_entries_f
        where element_entry_id = p_target_entry_id;
   --
   cursor c_cwk_element_check is
      -- Should not allow these PTO elements for CWKs
      select 'Y'
      from    pay_element_links_f pel
             ,pay_element_types_f pet
             ,pay_accrual_plans pap
      where   pel.element_link_id = p_element_link_id
      and     p_session_date between pel.effective_start_date
                                 and pel.effective_end_date
      and     pel.element_type_id = pet.element_type_id
      and     p_session_date between pet.effective_start_date
                                 and pet.effective_end_date
      and     pet.element_type_id = pap.accrual_plan_element_type_id
      union all
      -- Should not allow these absence elements for CWKs
      select 'Y'
      from   pay_element_links_f pel
            ,pay_element_types_f pet
            ,pay_input_values_f piv
            ,per_absence_attendance_types abt
      where  pel.element_link_id = p_element_link_id
      and    p_session_date between pel.effective_start_date
                                and pel.effective_end_date
      and    pel.element_type_id = pet.element_type_id
      and    p_session_date between pet.effective_start_date
                                and pet.effective_end_date
      and    pet.element_type_id = piv.element_type_id
      and    p_session_date between piv.effective_start_date
                                and piv.effective_end_date
      and    piv.input_value_id = abt.input_value_id
      and    abt.input_value_id is not null;
   --
   v_dummy                varchar2(1);

 begin
   g_debug := hr_utility.debug_enabled;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.chk_element_entry_main', 5);
   end if;
   --
   -- Fetch element type information relevent to the creation of element
   -- entries
   --
   begin
     select et.element_type_id,
            et.processing_type,
            et.multiple_entries_allowed_flag,
            et.third_party_pay_only_flag,
            -- Bugfix 2866619
            -- Need element classification for comparison purposes
            et.element_name,
            ec.classification_name
     into   v_element_type_id,
            v_processing_type,
            v_mult_entries_allowed_flag,
            v_third_party_pay_only_flag,
            v_element_name,
            v_classification_name
     from   pay_element_links_f el,
            pay_element_types_f et,
            pay_element_classifications ec
     where  el.element_link_id = p_element_link_id
       and  et.element_type_id = el.element_type_id
       and  et.classification_id = ec.classification_id
       and  p_session_date between el.effective_start_date
                               and el.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;

      if g_debug then
        hr_utility.trace('      v_element_type_id : '|| v_element_type_id);
        hr_utility.trace('      v_processing_type : '|| v_processing_type);
        hr_utility.trace('      v_mult_entries_allowed_flag : '|| v_mult_entries_allowed_flag);
        hr_utility.trace('      v_third_party_pay_only_flag : '|| v_third_party_pay_only_flag);
        hr_utility.trace('      v_element_name : '|| v_element_name);
        hr_utility.trace('      v_classification_name : '|| v_classification_name);
      end if;
       --
       -- Bugfix 2866619
       -- Need assignment type for comparison purposes
       --
       select asg.assignment_type, asg.assignment_number
       into   v_assignment_type, v_assignment_number
       from   per_all_assignments_f asg
       where  asg.assignment_id = p_assignment_id
       and    p_session_date between asg.effective_start_date
                                 and asg.effective_end_date;
       --

       if g_debug then
        hr_utility.trace('      v_assignment_type : '|| v_assignment_type);
        hr_utility.trace('      v_assignment_number : '|| v_assignment_number);
      end if;

   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry.chk_element_entry');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
   --
   -- Bugfix 2866619
   -- Check the assignment type to ensure assignment is eligible for
   -- entry
   --
   if v_assignment_type = 'C' and (v_processing_type <> 'R'
     or v_classification_name <> 'Information') then
     --
     -- Contingent workers can only have recurring entries of
     -- 'Information' classification
     --
     hr_utility.set_message(801, 'HR_33155_ENTRY_INVALID_FOR_CWK');
     hr_utility.set_message_token('ELEMENT_NAME',v_element_name);
     hr_utility.set_message_token('ASSIGNMENT_NUMBER',v_assignment_number);
     hr_utility.set_message_token('SESSION_DATE',to_char(p_session_date));
     hr_utility.raise_error;
     --
   elsif v_assignment_type = 'C' and v_processing_type = 'R'
       and  v_classification_name = 'Information' then
       --
       -- Contingent workers have some exception to few PTO and Absece elements.
       --
       open c_cwk_element_check;
       fetch c_cwk_element_check into v_dummy;
       --
       if c_cwk_element_check%found then
          close c_cwk_element_check;
          --
          hr_utility.set_message(801, 'HR_33155_ENTRY_INVALID_FOR_CWK');
          hr_utility.set_message_token('ELEMENT_NAME',v_element_name);
          hr_utility.set_message_token('ASSIGNMENT_NUMBER',v_assignment_number);
          hr_utility.set_message_token('SESSION_DATE',to_char(p_session_date));
          hr_utility.raise_error;
          --
       end if;
       close c_cwk_element_check;
       --
   end if;
   --
   -- If the commit usage is insert then set the validation start and end dates
   -- to the effective start and end dates.
   --
   if (p_entry_type      = 'E'  and
       v_processing_type = 'R') then
     --
     -- As the entry is recurring:
     --
     if ((p_usage           = 'INSERT'              or
          p_dt_delete_mode  = 'FUTURE_CHANGE')      or
         (p_dt_delete_mode  = 'DELETE_NEXT_CHANGE'  and
          p_validation_end_date = hr_general.end_of_time))           then
       --
       if g_debug then
          hr_utility.set_location('hr_entry.chk_element_entry_main', 10);
       end if;
       --
       -- If we are inserting or doing date-effective delete next/future
       -- changes then we must set the effective_end_date to be passed back
       -- to the form and, also set the validation_end_date NB. this will take
       -- into account if multiple entries are allowed.
       --
       v_validation_end_date := hr_entry.recurring_entry_end_date
                                  (p_assignment_id,
                                   p_element_link_id,
                                   p_session_date,
                                   'Y',
                                   v_mult_entries_allowed_flag,
                                   p_element_entry_id,
                                   p_original_entry_id);
       --
       if p_usage = 'INSERT' then
         v_validation_start_date := p_session_date;
       else
         v_validation_start_date := p_validation_start_date;
       end if;
     --
     -- We must be doing either a date-effective update or ZAP therefore
     -- set the validation_start/end_date to the validation_start/end_date
     -- passed in through the form.
     --
     else
       v_validation_start_date := p_validation_start_date;
       v_validation_end_date   := p_validation_end_date;
     end if;

     if g_debug then
       hr_utility.trace('       v_validation_start_date : '|| v_validation_start_date);
       hr_utility.trace('       v_validation_end_date : '|| v_validation_end_date);
     end if;
   --
   -- As the entry is nonrecurring:
   --
   else
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 15);
     end if;
     /*Bug 8798020 Added below call to get the eligibility dates */
     If nvl(p_dt_delete_mode,'NULL') <> 'ZAP' then
      hr_entry.chk_element_entry_eligibility (p_assignment_id          =>p_assignment_id,
                                           p_element_link_id        =>p_element_link_id,
                                           p_session_date           =>p_session_date,
                                           p_usage                  =>p_usage,
                                           p_creator_type           => null,
                                           p_validation_start_date  =>v_validation_start_date,
                                           p_validation_end_date    =>v_validation_end_date,
                                           p_time_period_start_date =>v_period_start_date,
                                           p_time_period_end_date   =>v_period_end_date,
                                           p_min_eligibility_date   =>v_min_eligible_date,
                                           p_max_eligibility_date   =>v_max_eligible_date
                                          );

     if g_debug then
       hr_utility.trace('       v_min_eligible_date : '|| to_char(v_min_eligible_date,'DD-MON-YYYY'));
       hr_utility.trace('       v_max_eligible_date : '|| to_char(v_max_eligible_date,'DD-MON-YYYY'));
     end if;

     --
     -- Validate that it is OK to create a nonrecurring entry ie. assignment
     -- is to a payroll and also a time period exists. Also calculate the start
     -- and end dates of the nonrecurring entry taking into account changes in
     -- payroll.
     --
     hr_entry.get_nonrecurring_dates(p_assignment_id,
                                     p_session_date,
                                     v_validation_start_date,
                                     v_validation_end_date,
                                     v_payroll_id,
                                     v_period_start_date,
                                     v_period_end_date);
     --
     if g_debug then
       hr_utility.trace('  v_payroll_id : '|| v_payroll_id);
       hr_utility.trace('  v_period_start_date: '||to_char(v_period_start_date,'DD-MON-YYYY'));
       hr_utility.trace('  v_period_end_date: '||to_char(v_period_end_date,'DD-MON-YYYY'));
       hr_utility.trace('  v_validation_start_date: '||to_char(v_validation_start_date,'DD-MON-YYYY'));
       hr_utility.trace('  v_validation_end_date: '||to_char(v_validation_end_date,'DD-MON-YYYY'));
     end if;

     /*Bug 8798020 Added below code to take the eligible dates  */
     v_validation_start_date :=greatest(v_validation_start_date,nvl(v_min_eligible_date,v_validation_start_date));
     v_validation_end_date   :=least(v_validation_end_date,nvl(v_max_eligible_date,v_validation_end_date));

    end if; /*Bug 8816456 Extended end if for p_dt_delete_mode <> 'ZAP' as in ZAP mode we dont need non_recurring_dates call*/
     --
     -- wmcveagh, bug 493056. Use element effective start date rather than
     --                         validation start date if vsd is later.
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 17);
     end if;
     --
     open c_element_start_date ;
     fetch c_element_start_date into v_element_effective_start_date;
     close c_element_start_date;
     --
     hr_utility.trace(' v_element_effective_start_date : '|| v_element_effective_start_date);
     --
     if v_validation_start_date < v_element_effective_start_date then
        if g_debug then
           hr_utility.set_location('hr_entry.chk_element_entry_main', 18);
        end if;
        v_validation_start_date := v_element_effective_start_date;
     end if;
     --
   end if;

   hr_utility.trace('   v_validation_start_date : '|| v_validation_start_date);
  --
  -- Only do check when the entry is being created or extended.
  --
  if ((p_usage           = 'INSERT'              or
       p_dt_delete_mode  = 'FUTURE_CHANGE')      or
      (p_dt_delete_mode  = 'DELETE_NEXT_CHANGE'  and
       p_validation_end_date = hr_general.end_of_time))           then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 20);
     end if;
-- start 115.26
-- bugfix 1827998
declare
    l_validation_start_date date;
    l_validation_end_date   date;
begin
    if p_usage = 'INSERT' then
        dt_api.validate_dt_mode(
         p_effective_date          => p_session_date  --*
        ,p_datetrack_mode          => 'INSERT'  --*
        ,p_base_table_name         => 'pay_element_entries_f'
        ,p_base_key_column         => 'element_entry_id'
        ,p_base_key_value          => p_element_entry_id  --*
        ,p_parent_table_name1      => 'per_all_assignments_f'
        ,p_parent_key_column1      => 'assignment_id'
        ,p_parent_key_value1       => p_assignment_id
        ,p_enforce_foreign_locking => true
        ,p_validation_start_date   => l_validation_start_date
        ,p_validation_end_date     => l_validation_end_date);
    end if;
end;
-- end 115.26
     --
     -- Make sure the entry does not overlap if multiple entries are not
     -- allowed.
     --
     if p_creator_type not in ('EE', 'RR', 'AD', 'AE', 'NR', 'PR') then
        hr_entry.chk_entry_overlap(p_element_entry_id,
                                   p_assignment_id,
                                   p_element_link_id,
                                   v_processing_type,
                                   p_entry_type,
                                   v_mult_entries_allowed_flag,
                                   v_validation_start_date,
                                   v_validation_end_date,
                                   v_period_start_date,
                                   v_period_end_date);
        --
     end if;
   end if;
   --
   if g_debug then
      hr_utility.set_location('hr_entry.chk_element_entry_main', 25);
   end if;
   --
   -- Call the procedure: chk_element_entry_open
   -- This procedure does common checks for insert/update/delete
   -- commit actions.
   --
   hr_entry.chk_element_entry_open(v_element_type_id,
                                   p_session_date,
                                   v_validation_start_date,
                                   v_validation_end_date,
                                   p_assignment_id);

   --
   -- If inserting an entry which is NOT a standard Recurring entry then
   -- perform various date validation.
   --
   if (p_usage = 'INSERT'         and
     ((v_processing_type  = 'R'   and
       p_entry_type      <> 'E')  or
       v_processing_type  = 'N')) then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 30);
     end if;
     --
     -- We must ensure that the entry is eligible to be inserted.
     --
     -- Bugfix 5135065
     -- Pass v_period_start_date and v_period_end_date to
     -- chk_element_entry_eligibility
     -- These should only have been derived if the entry is non-recurring
     -- In this case we can greatly reduce the number of calls made
     -- by get_eligibility_period to the expensive assignment_eligible_for_link
     -- function.
     hr_entry.chk_element_entry_eligibility(p_assignment_id,
                                           p_element_link_id,
                                           p_session_date,
                                           p_usage,
                                           p_creator_type,
                                           v_validation_start_date,
                                           v_validation_end_date,
                                           v_period_start_date,
                                           v_period_end_date,
                                           v_min_date,
                                           v_max_date);
     --
   end if;
   --
   -- Additional entry insert checks.
   --
   if (p_entry_type = 'D' and
       p_creator_type not in ('EE', 'RR', 'AD', 'AE', 'NR', 'PR') and
       p_usage      = 'INSERT') then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 35);
     end if;
     --
     -- Additional Entry is trying to be inserted therefore, check for
     -- another existing Additional Entry within the current period.
     begin
       -- INDEX and FIRST_ROWS hints added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select  /*+ FIRST_ROWS(1)
                           INDEX(pee, pay_element_entries_f_n51 */ 1
               from    pay_element_entries_f pee
               where   pee.entry_type      = p_entry_type
               and     pee.assignment_id   = p_assignment_id
               and     pee.element_link_id = p_element_link_id
               and     pee.effective_start_date >= v_period_start_date
               and     pee.effective_end_date   <= v_period_end_date);
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
        hr_utility.set_message(801, 'HR_7700_ELE_ENTRY_REC_EXISTS');
        hr_utility.raise_error;
     end if;
     --
   end if;
   --
   -- Standard recurring entry checks.
   --
   if ((p_entry_type      = 'E'       and
        v_processing_type = 'R')      and
       (p_dt_delete_mode  = 'ZAP'     or
        p_dt_delete_mode = 'DELETE')) then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 40);
     end if;
     --
     -- If the p_dt_delete_mode is not null then need to ensure that
     -- the entry being deleted does not orphan any adjustments.
     begin
       -- INDEX and FIRST_ROWS hints added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select  /*+ FIRST_ROWS(1)
                           INDEX(pee, pay_element_entries_f_n51 */ 1
               from    pay_element_entries_f pee
               where   pee.target_entry_id = p_element_entry_id
               and     pee.element_link_id = p_element_link_id
               and     pee.assignment_id   = p_assignment_id
               and     pee.effective_start_date <= v_validation_end_date
               and     pee.effective_end_date   >= v_validation_start_date);
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
       hr_utility.set_message(801, 'HR_6304_ELE_ENTRY_DT_DEL_ADJ');
       hr_utility.raise_error;
     end if;
     --
   end if;
   --
   -- Override entry checks.
   --
   if (p_entry_type = 'S' and
       p_usage      = 'INSERT') then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 45);
     end if;
     --
     -- Ensure that no other override exists within the current
     -- period for the same element for the assignment.
     begin
       -- INDEX and FIRST_ROWS hints added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select  /*+ FIRST_ROWS(1)
                           INDEX(pee, pay_element_entries_f_n51 */ 1
               from    pay_element_entries_f pee
               where   pee.entry_type      = 'S'
               and     pee.assignment_id   = p_assignment_id
               and     pee.element_link_id = p_element_link_id
               and     pee.effective_start_date >= v_period_start_date
               and     pee.effective_end_date   <= v_period_end_date);
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
        hr_utility.set_message(801, 'HR_6187_ELE_ENTRY_OVER_EXISTS');
        hr_utility.raise_error;
     end if;
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 50);
     end if;
     --
     -- Ensure that an adjustment entry does not exist when trying to
     -- insert override.
     --
     begin
       -- INDEX and FIRST_ROWS hints added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select /*+ FIRST_ROWS(1)
                          INDEX(pee, pay_element_entries_f_n51 */ 1
               from   pay_element_entries_f pee
               where  pee.entry_type in ('R','A')
               and    pee.assignment_id   = p_assignment_id
               and    pee.element_link_id = p_element_link_id
               and    pee.effective_start_date >= v_period_start_date
               and    pee.effective_end_date   <= v_period_end_date);
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
        hr_utility.set_message(801, 'HR_6189_ELE_ENTRY_ADJ_EXISTS');
        hr_utility.raise_error;
     end if;
     --
     -- You are not allowed to insert an override entry
     -- for an element type that has the third party only
     -- flag set to 'Y'.
     if v_third_party_pay_only_flag = 'Y' then
        hr_utility.set_message(801, 'PAY_289106_CANT_OVER_THIRD');
        hr_utility.raise_error;
     end if;
     --
   end if;
   --
   -- Standard adjustment entry insert checks.
   --
   if ((p_entry_type = 'R'  or
        p_entry_type = 'A') and
        p_usage      = 'INSERT') then
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 55);
     end if;
     --
     -- Ensure that the parent entry of the adjustment exists for the
     -- duration of the adjustment.
     --
     begin
       -- FIRST_ROWS hint added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  not exists
              (select /*+ FIRST_ROWS(1) */ 1
               from   pay_element_entries_f pee
               where  pee.assignment_id    = p_assignment_id
               and    pee.element_entry_id = p_target_entry_id
               having min(pee.effective_start_date) <=
                      v_validation_start_date
               and    max(pee.effective_end_date)   >=
                      v_validation_end_date);
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
        hr_utility.set_message(801, 'HR_6194_ELE_ENTRY_ADJ_PARENT');
        hr_utility.raise_error;
     end if;
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 60);
     end if;
     --
     -- Ensure that an override does not exist for the entry which is to be
     -- adjusted.
     begin
       -- INDEX and FIRST_ROWS hints added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select /*+ FIRST_ROWS(1)
                          INDEX(pee, pay_element_entries_f_n51 */ 1
               from   pay_element_entries_f pee
               where  pee.entry_type       = 'S'
               and    pee.assignment_id    = p_assignment_id
               and    pee.element_link_id  = p_element_link_id
               and    pee.effective_start_date >= v_period_start_date
               and    pee.effective_end_date   <= v_period_end_date);
     --
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
       hr_utility.set_message(801, 'HR_6195_ELE_ENTRY_OADJ_EXISTS');
       hr_utility.raise_error;
     end if;
     --
     if g_debug then
        hr_utility.set_location('hr_entry.chk_element_entry_main', 65);
     end if;
     --
     -- Ensure that an existing adjustment for this entry does not exist for
     -- the current period/assignment.
     begin
       -- FIRST_ROWS hint added following NHS project recommendation
       select 'Y'
       into   v_error_flag
       from   sys.dual
       where  exists
              (select /*+ FIRST_ROWS(1) */ 1
               from   pay_element_entries_f pee
               where  pee.entry_type in ('R','A')
               and    pee.assignment_id    = p_assignment_id
               and    pee.target_entry_id  = p_target_entry_id
               and    pee.effective_start_date >= v_period_start_date
               and    pee.effective_end_date   <= v_period_end_date);
     --
     exception
       when no_data_found then null;
     end;
     --
     if v_error_flag = 'Y' then
        hr_utility.set_message(801, 'HR_6196_ELE_ENTRY_ADJ_EXISTS');
        hr_utility.raise_error;
     end if;
     --
   end if;
   --
   -- Return the effective start and end dates of the entry being
   -- vslidated NB. this is only valid in certain circumstances ie.
   --
   -- DT Mode = INSERT
   --            Valid dates = p_effective_start_date / p_effective_end_date
   --   ''    = DELETE_NEXT_CHANGE and validation_end_date = EOT
   --            Valid dates = p_effective_end_date
   --   ''    = DELETE_FUTURE_CHANGES
   --            Valid dates = p_effective_end_date
   --
   -- In all other cases the dates are not valid and should not beused to
   -- populate EFECTIVE_START_DATE and EFFECTIVE_END_DATE of the row being
   -- processed.
   --
   if p_entry_type       = 'E' and
      v_processing_type  = 'R' and
      ((p_usage          = 'INSERT' or
        p_dt_delete_mode = 'FUTURE_CHANGE') or
       (p_dt_delete_mode = 'DELETE_NEXT_CHANGE' and
        p_validation_end_date = hr_general.end_of_time)) then
     p_effective_end_date   := v_validation_end_date;
   elsif (p_entry_type = 'E' and v_processing_type = 'N') or
          p_entry_type <> 'E' then
     p_effective_start_date := greatest(v_validation_start_date,
                               nvl(v_min_date, v_validation_start_date));
     p_effective_end_date   := least(v_validation_end_date,
                               nvl(v_max_date, v_validation_end_date));
   end if;
   --
 end chk_element_entry_main;
--
-- NAME
-- hr_entry.ins_3p_ent_values
--
-- DESCRIPTION
-- This function is used for third party inserts into:
-- PAY_ELEMENT_ENTRIES_F      (If an abscence, or DT functions are being used).
-- PAY_ELEMENT_ENTRY_VALUES_F (Entry Values are always inserted).
-- PAY_RUN_RESULTS            (If nonrecurring).
-- PAY_RUN_RESULT_VBALUES     (If nonrecurring).
--
--
 procedure ins_3p_ent_values
 (
  p_element_link_id    number,
  p_element_entry_id   number,
  p_session_date       date,
  p_num_entry_values   number,
  p_input_value_id_tbl hr_entry.number_table,
  p_entry_value_tbl    hr_entry.varchar2_table
 ) is
--
   -- cursor to fetch balance adjustment element entry values
   cursor get_b_eevs(p_element_entry_id number,
                     p_session_date     date ) is
   select peev.input_value_id,
          piv.uom,
          peev.screen_entry_value value
   from   pay_input_values_f piv,
          pay_element_entry_values_f peev
   where  peev.element_entry_id = p_element_entry_id
   and    piv.input_value_id = peev.input_value_id
   and    p_session_date between peev.effective_start_date
                             and peev.effective_end_date
   and    p_session_date between piv.effective_start_date
                             and piv.effective_end_date;
   -- Local variables
   v_run_result_id               number;
   v_status                      varchar2(1);
   v_exchange_rate               number(20,10);
   v_element_entry_id            number;
   v_assignment_id               number;
   v_entry_type                  varchar2(30);
   v_creator_type                varchar2(30);
   v_creator_id                  number;
   v_effective_start_date        date;
   v_effective_end_date          date;
   v_cost_allocation_keyflex_id  number;
   v_element_type_id             number;
   v_processing_type             varchar2(30);
   v_input_currency_code         varchar2(30);
   v_output_currency_code        varchar2(30);
   v_entry_count                 number := 0;
   v_jurisdiction                varchar2(30);
   v_currency_type               varchar2(30);
   v_bg_id                       number(16);
   v_amount                      number;


--
 begin
--
   if g_debug then
      hr_utility.set_location('hr_entry.ins_3p_entry_values', 1);
   end if;
   begin
--
     select ee.element_entry_id,
            ee.assignment_id,
            ee.entry_type,
            ee.creator_type,
            ee.creator_id,
            ee.effective_start_date,
            ee.effective_end_date,
            ee.cost_allocation_keyflex_id,
            et.element_type_id,
            et.processing_type,
            et.input_currency_code,
            et.output_currency_code
     into   v_element_entry_id,
            v_assignment_id,
            v_entry_type,
            v_creator_type,
            v_creator_id,
            v_effective_start_date,
            v_effective_end_date,
            v_cost_allocation_keyflex_id,
            v_element_type_id,
            v_processing_type,
            v_input_currency_code,
            v_output_currency_code
     from   pay_element_entries_f ee,
            pay_element_links_f el,
            pay_element_types_f et
     where  ee.element_entry_id = p_element_entry_id
       and  el.element_link_id  = ee.element_link_id
       and  et.element_type_id  = el.element_type_id
       and  p_session_date between ee.effective_start_date
                               and ee.effective_end_date
       and  p_session_date between el.effective_start_date
                               and el.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
--
   exception
     when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                        'hr_entry.ins_3p_entry_values');
       hr_utility.set_message_token('STEP','6');
       hr_utility.raise_error;
   end;
--
   if g_debug then
      hr_utility.set_location('hr_entry.ins_3p_entry_values', 2);
   end if;
--
   -- Insert all the entry values if there are any.
   if p_num_entry_values > 0 then
--
     -- NB. mandatory checks are not applied to adjustments.
     if not v_entry_type in ('A','R') then
--
       hr_entry.chk_mandatory_entry_values
         (p_element_link_id,
          p_session_date,
          p_num_entry_values,
          p_input_value_id_tbl,
          p_entry_value_tbl);
--
     end if;
--
     -- See how many entry rows currently exist NB. if there is more than one
     -- then the the entry is being updated otherwise it is being inserted.
     begin
       select count(*)
       into   v_entry_count
       from   pay_element_entries_f ee
       where  ee.element_entry_id = p_element_entry_id;
     exception
       when no_data_found then null;
     end;
--
     -- Element entry is being created so need to create new element entry
     -- values.
     if v_entry_count = 1 then
--
       -- Bug 4347283. Changed to use forall for bulk insert.
       --
       forall v_loop in 1..p_num_entry_values
--
         insert into pay_element_entry_values_f
         (element_entry_value_id,
          effective_start_date,
          effective_end_date,
          input_value_id,
          element_entry_id,
          screen_entry_value)
         values
         (pay_element_entry_values_s.nextval,
          v_effective_start_date,
          v_effective_end_date,
          p_input_value_id_tbl(v_loop),
          p_element_entry_id,
          p_entry_value_tbl(v_loop));
--
     -- Element entry is being updated so need to copy the element entry
     -- values.
     else
--
       -- Bug 4347283. Changed to use forall for bulk insert.
       --
       forall v_loop in 1..p_num_entry_values
--
         --
         -- WWbug 273821
         -- Added + 0 to eev.input_value_id to disable the use of
         -- index PAY_ELEMENT_ENTRY_VALUES_F_N1
         --
         insert into pay_element_entry_values_f
         (element_entry_value_id,
          effective_start_date,
          effective_end_date,
          input_value_id,
          element_entry_id,
          screen_entry_value)
         select
          eev.element_entry_value_id,
          v_effective_start_date,
          v_effective_end_date,
          eev.input_value_id,
          p_element_entry_id,
          p_entry_value_tbl(v_loop)
         from  pay_element_entry_values_f eev
         where eev.element_entry_id = p_element_entry_id
           and eev.input_value_id + 0 = p_input_value_id_tbl(v_loop)
           and p_session_date - 1 between eev.effective_start_date
                                      and eev.effective_end_date;
--
     end if;
--
   end if;
--
   -- If the entry is nonrecurring ONLY or is a balance adjustment then insert
   -- run result and run result values providing the input currency =
   -- output currency and the element can be processed in a run.
   --
   -- Enhancement 3205906
   -- We no longer wish to create run results automatically for nonrecurring
   -- entries or balance adjustments.
   --
   /*
   if ((v_entry_type          = 'E'   and
        v_processing_type     = 'N'   and
        v_input_currency_code = v_output_currency_code)  or
        v_entry_type          = 'B') then
--
     -- Ensure that the entry can be processed in a run.
     if hr_entry.entry_process_in_run(v_element_type_id, p_session_date) then
--
       -- Set the processing status. If the entry is a balance adjustment then
       -- the run result status must be set to processed.
       if v_entry_type = 'B' then
--
         v_status := 'P';
--
         -- If the input currency <> output currency then select the exchange
         -- rate
         if v_input_currency_code <> v_output_currency_code then
         begin
           if g_debug then
              hr_utility.set_location('hr_entry.ins_3p_entry_values', 4);
           end if;
--
           select business_group_id
           into v_bg_id
           from per_assignments_f pas
           where pas.assignment_id      = v_assignment_id
           and p_session_date between pas.effective_start_date
                                  and pas.effective_end_date
           and rownum=1;
--
           v_currency_type:=hr_currency_pkg.get_rate_type
                                             (v_bg_id,p_session_date,'P');
           if (v_currency_type is NULL)
           then
             hr_utility.set_message(801,'HR_52349_NO_RATE_TYPE');
             hr_utility.raise_error;
           end if;
         end;
--
         end if;
--
       else
--
         v_status := 'U';
--
       end if;
--
       -- Get the next sequenced run_result_id. Step 5.
       v_run_result_id := hr_entry.generate_run_result_id;
--
       -- Insert Run Result. Step 6.
       if g_debug then
          hr_utility.set_location('hr_entry.ins_3p_entry_values', 6);
       end if;
       -- First get the Jurisdiction if one exists.
       begin
         select eev.screen_entry_value
           into v_jurisdiction
           from pay_element_entry_values_f eev,
                pay_input_values_f         piv,
                pay_element_entries_f      pee
           where pee.element_entry_id = v_element_entry_id
           and   eev.element_entry_id = pee.element_entry_id
           and   eev.input_value_id   = piv.input_value_id
           and   piv.name             = 'Jurisdiction'
           and   p_session_date between pee.effective_start_date
                                    and pee.effective_end_date
           and   p_session_date between eev.effective_start_date
                                    and eev.effective_end_date
           and   p_session_date between piv.effective_start_date
                                    and piv.effective_end_date;
       exception
            when no_data_found then
               v_jurisdiction := null;
       end;
--
       begin
--
         insert into pay_run_results
         (run_result_id,
          element_type_id,
          assignment_action_id,
          entry_type,
          source_id,
          source_type,
          status,
          jurisdiction_code)
         values
         (v_run_result_id,
          v_element_type_id,
          null,
          v_entry_type,
          v_element_entry_id,
          'E',
          v_status,
          v_jurisdiction);
--
       exception
         when NO_DATA_FOUND then
           hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message_token('PROCEDURE',
                                        'hr_entry.ins_3p_entry_values');
           hr_utility.set_message_token('STEP','6');
           hr_utility.raise_error;
       end;
--
       -- Insert Run Result Values. Step 7.
       if (v_entry_type = 'B' and
           v_input_currency_code <> v_output_currency_code) then
--
         -- insert run results values converting all money uom's to the output
         -- currency value.
         if g_debug then
            hr_utility.set_location('hr_entry.ins_3p_entry_values', 7);
         end if;
         begin

           for peev in get_b_eevs(p_element_entry_id, p_session_date) loop

              if (peev.uom='M')
              then
               begin
               v_amount:=hr_currency_pkg.convert_amount(v_input_currency_code,
                                                    v_output_currency_code,
                                                    p_session_date,
                                                    peev.value,
                                                    v_currency_type);
               exception
                when gl_currency_api.NO_RATE then
                  hr_utility.set_message(801,'HR_6405_PAYM_NO_EXCHANGE_RATE');
                  hr_utility.set_message_token('RATE1', v_input_currency_code);
                  hr_utility.set_message_token('RATE2', v_output_currency_code);
                  hr_utility.raise_error;
                when gl_currency_api.INVALID_CURRENCY then
                  hr_utility.set_message(801,'HR_52350_INVALID_CURRENCY');
                  hr_utility.set_message_token('RATE1', v_input_currency_code);
                  hr_utility.set_message_token('RATE2', v_output_currency_code);
                  hr_utility.raise_error;
                end;
               else
                   v_amount:=peev.value;
               end if;
--
              insert into pay_run_result_values
              (input_value_id,
               run_result_id,
               result_value)
              values
              (peev.input_value_id,
               v_run_result_id,
               v_amount);
         end loop;
--
         exception
           when no_data_found then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
                                       'hr_entry.ins_3p_entry_values');
             hr_utility.set_message_token('STEP','7');
             hr_utility.raise_error;
         end;

--
       -- insert run result values which do not have to be converted.
       else
--
         if g_debug then
            hr_utility.set_location('hr_entry.ins_3p_entry_values', 8);
         end if;
         begin
--
           insert into pay_run_result_values
           (input_value_id,
            run_result_id,
            result_value)
           select
            peev.input_value_id,
            v_run_result_id,
            peev.screen_entry_value
           from  pay_element_entry_values_f peev
           where peev.element_entry_id = v_element_entry_id
           and   p_session_date between peev.effective_start_date
                                    and peev.effective_end_date;
--
         exception
           when no_data_found then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
                                          'hr_entry.ins_3p_entry_values');
             hr_utility.set_message_token('STEP','8');
             hr_utility.raise_error;
         end;
--
       end if;
--
     end if;
--
   end if;
   */
    -- End of Enhancement 3205906
--
 end ins_3p_ent_values;
--
 procedure ins_3p_entry_values
 (
  p_element_link_id    number,
  p_element_entry_id   number,
  p_session_date       date,
  p_num_entry_values   number,
  p_input_value_id_tbl hr_entry.number_table,
  p_entry_value_tbl    hr_entry.varchar2_table
 ) is
--
   -- Local Variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
--
 begin
--
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
--
--     hr_entry_api.conv_table_to_table
--       ('DB',
--        p_session_date,
--        null,
--        p_element_link_id,
--        v_num_entry_values,
--        v_input_value_id_tbl,
--        v_entry_value_tbl);
--
   hr_entry.ins_3p_ent_values
     (p_element_link_id,
      p_element_entry_id,
      p_session_date,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
 end ins_3p_entry_values;
--
 procedure ins_3p_entry_values
 (
  p_element_link_id  number,
  p_element_entry_id number,
  p_session_date     date,
/** sbilling **/
  p_creator_type     varchar2,
  p_entry_type       varchar2,
  p_input_value_id1  number,
  p_input_value_id2  number,
  p_input_value_id3  number,
  p_input_value_id4  number,
  p_input_value_id5  number,
  p_input_value_id6  number,
  p_input_value_id7  number,
  p_input_value_id8  number,
  p_input_value_id9  number,
  p_input_value_id10 number,
  p_input_value_id11 number,
  p_input_value_id12 number,
  p_input_value_id13 number,
  p_input_value_id14 number,
  p_input_value_id15 number,
  p_entry_value1     varchar2,
  p_entry_value2     varchar2,
  p_entry_value3     varchar2,
  p_entry_value4     varchar2,
  p_entry_value5     varchar2,
  p_entry_value6     varchar2,
  p_entry_value7     varchar2,
  p_entry_value8     varchar2,
  p_entry_value9     varchar2,
  p_entry_value10    varchar2,
  p_entry_value11    varchar2,
  p_entry_value12    varchar2,
  p_entry_value13    varchar2,
  p_entry_value14    varchar2,
  p_entry_value15    varchar2
 ) is
--
   -- Local variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
--
 begin
--
   -- Convert entry value details ie. INPUT_VALUE_ID and SCREEN_ENTRY_VALUE
   -- into two tables to be passed into the overloaded version of
   -- ins_3p_entry_values. The overloaded version is capable of handling
   -- unlimited numbers of entry values.
   hr_entry_api.conv_entry_values_to_table
     ('DB',
      null,
      p_element_link_id,
      p_session_date,
/** sbilling **/
      p_creator_type,
      p_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry.ins_3p_ent_values
     (p_element_link_id,
      p_element_entry_id,
      p_session_date,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
 end ins_3p_entry_values;
--

-------------------------------------------------------------------------
-- NAME  delete_covered_dependants
--
-- DESCRIPTION Deals with calls to update the covered dependents of an
--             Element entry.
--             Called by : hr_entry.del_3p_entry_values
--                       : hrentmnt.validate_adjust_entry
--
----------------------------------------------------------------------------

procedure delete_covered_dependants

   (p_validation_start_date date,
    p_element_entry_id number,
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL) is
   --
   -- Set of covered dependants which are children of the deleted element entry
   -- and which overlap or are later than the deletion date
   -- (in the case of zap this will be all children because
   -- p_validation_start_date will be the beginning of time).
   -- If p_end_date is NULL change the start date of the covered dependent
   cursor csr_covered_dependents is
        select  rowid,
                dep.*
        from    ben_covered_dependents_f DEP
        where   dep.effective_end_date >= p_validation_start_date
        and     dep.element_entry_id = p_element_entry_id;
        --

   v_start_date date;
   v_end_date date;

   begin
   --
   for dependant in csr_covered_dependents LOOP
     --
     if dependant.effective_start_date >= p_validation_start_date then
       --
       -- If the dependant starts after the entry deletion date then delete it
       --
       ben_covered_dependents_pkg.delete_row (dependant.rowid);
       --
     else
       --
       -- The dependant must overlap the entry deletion date so update it to
       -- have the same end date. NB This will only apply to DELETE mode
       -- because ZAP will have a validation_start_date of the beginning of
       -- time and so this condition will never be satisfied.
       --

       v_start_date := NVL(p_start_date,dependant.effective_start_date);
       v_end_date   := NVL(p_end_date,dependant.effective_end_date);

       ben_covered_dependents_pkg.update_row (
         --
         p_covered_dependent_id         => dependant.covered_dependent_id,
         p_rowid                        => dependant.rowid,
         p_contact_relationship_id      => dependant.contact_relationship_id,
         p_element_entry_id             => dependant.element_entry_id,
         p_effective_start_date         => v_start_date,
         p_effective_end_date           => v_end_date);
         --
     end if;
     --
   end loop;
   --
   end delete_covered_dependants;

----------------------------------------------------------------------------
--
-- NAME hr_entry.delete_beneficiaries
--
-- DESCRIPTION deals with calls to update the beneficiaries of a given
--             element entry.
--             Called by :- hr_entry.del_3p_entry_values
--                          hrentmnt.validate_adjust_entry
--
----------------------------------------------------------------------------

   procedure delete_beneficiaries
   (p_validation_start_date date,
    p_element_entry_id number,
    p_start_date date DEFAULT NULL,
    p_end_date date DEFAULT NULL)

     is
   --
   -- Set of beneficiaries which are children of the deleted element entry
   -- and which overlap or are later than the deletion date
   -- (in the case of zap this will be all children because
   -- p_validation_start_date will be the beginning of time).
   -- If p_end_date is null change the start date of the covered beneficiary

   cursor csr_beneficiaries is
        select  rowid,
                ben.*
        from    ben_beneficiaries_f BEN
        where   ben.effective_end_date >= p_validation_start_date
        and     ben.element_entry_id = p_element_entry_id;
        --
   v_start_date date;
   v_end_date   date;

   begin
   --
   for entry_beneficiary in csr_beneficiaries LOOP
     --
     if entry_beneficiary.effective_start_date >= p_validation_start_date then
       --
       -- If the beneficiary starts after the entry deletion date then delete it
       --
       ben_beneficiaries_pkg.delete_row (entry_beneficiary.rowid);
       --
     else
       --
       -- The beneficiary must overlap the entry deletion date so update it to
       -- have the same end date. NB This will only apply to DELETE mode
       -- because ZAP will have a validation_start_date of the beginning of
       -- time and so this condition will never be satisfied.
       --

     v_start_date := NVL(p_start_date,entry_beneficiary.effective_start_date);
     v_end_date   := NVL(p_end_date,entry_beneficiary.effective_end_date);

       ben_beneficiaries_pkg.update_row (
         --
         p_rowid                => entry_beneficiary.rowid,
         p_source_type          => entry_beneficiary.source_type,
         p_source_id            => entry_beneficiary.source_id,
         p_element_entry_id     => entry_beneficiary.element_entry_id,
         p_benefit_level        => entry_beneficiary.benefit_level,
         p_proportion           => entry_beneficiary.proportion,
         p_beneficiary_id       => entry_beneficiary.beneficiary_id,
         p_effective_start_date => v_start_date,
         p_effective_end_date   => v_end_date);
         --
     end if;
     --
   end loop;
   --
   end delete_beneficiaries;
   -------------------------

-- NAME
-- hr_entry.del_3p_entry_values
--
-- DESCRIPTION
-- This procedure is used for third party deletes from:
-- PAY_ELEMENT_ENTRIES_F      (If an abscence, or DT functions are being used).
-- PAY_ELEMENT_ENTRY_VALUES_F (Entry Values are always deleted).
-- PAY_RUN_RESULTS            (If nonrecurring, and exist).
-- PAY_RUN_RESULT_VALUES      (If nonrecurring, and exist).
-- BEN_COVERED_DEPENDENTS_F (sic)
-- BEN_BENEFICIARIES_F
--

PROCEDURE del_3p_entry_values
 (
  p_assignment_id         in number,
  p_element_entry_id      in number,
  p_element_type_id       in number,
  p_element_link_id       in number,
  p_entry_type            in varchar2,
  p_processing_type       in varchar2,
  p_creator_type          in varchar2,
  p_creator_id            in varchar2,
  p_dt_delete_mode        in varchar2,
  p_session_date          in date,
  p_validation_start_date in date,
  p_validation_end_date   in date
 ) is
   --------------------------------------
   --
   -- Local Variables
   --
   v_dt_delete_mode      varchar2(30);
   v_status              varchar2(30);
   v_process_in_run_flag varchar2(1);
   --------------------------------------

procedure extend_beneficiaries is
        --
        -- Extend the end dates of child beneficiaries
        --
        cursor csr_beneficiaries is
        --
        -- Fetch all child beneficiaries which have an end date the same as the
        -- parent entry's end date prior to the extension of the end date.
        --
        select  rowid,
                ben.*
        from    ben_beneficiaries_f     BEN
        where   ben.element_entry_id = p_element_entry_id
        and     ben.effective_end_date = p_validation_start_date -1;
        --
        begin
        --
        if p_validation_end_date = hr_general.end_of_time then
          --
          -- If the validation end date is the end of time then we are on the
          -- last date-effective row and we must be extending it out to the end
          -- of time. In this case only, also extend the child beneficiary rows
          -- which end on the same date as the entry.
          --
          for entry_beneficiary in csr_beneficiaries LOOP
            --
            ben_beneficiaries_pkg.update_row (
              --
                p_rowid                 => entry_beneficiary.rowid,
                p_source_type           => entry_beneficiary.source_type,
                p_source_id             => entry_beneficiary.source_id,
                p_element_entry_id      => entry_beneficiary.element_entry_id,
                p_benefit_level         => entry_beneficiary.benefit_level,
                p_proportion            => entry_beneficiary.proportion,
                p_beneficiary_id        => entry_beneficiary.beneficiary_id,
                p_effective_start_date =>entry_beneficiary.effective_start_date,
                p_effective_end_date    => p_validation_end_date);
        --
          end loop;
          --
        end if;
        --
        end extend_beneficiaries;
        -------------------------
procedure extend_dependants is
        --
        -- Extend the end dates of the child dependants
        --
        cursor csr_dependants is
        --
        -- Fetch all child dependants which have an end date the same as the
        -- parent entry's end date prior to the extension of the end date.
        --
        select  rowid,
                dep.*
        from    ben_covered_dependents_f        DEP
        where   dep.element_entry_id = p_element_entry_id
        and     dep.effective_end_date = p_validation_start_date -1;
        --
        begin
        --
        if p_validation_start_date = hr_general.end_of_time then
          --
          -- If the validation end date is the end of time then we are on the
          -- last date-effective row and we must be extending it out to the end
          -- of time. In this case only, also extend the child dependant rows
          -- which end on the same date as the entry.
          --
          for dependant in csr_dependants LOOP
            --
            ben_covered_dependents_pkg.update_row (
                --
                p_covered_dependent_id  => dependant.covered_dependent_id,
                p_rowid                 => dependant.rowid,
                p_contact_relationship_id=> dependant.contact_relationship_id,
                p_element_entry_id      => dependant.element_entry_id,
                p_effective_start_date  => dependant.effective_start_date,
                p_effective_end_date    => p_validation_end_date);
                --
          end loop;
          --
        end if;
        --
        end extend_dependants;
        ----------------------
begin
g_debug := hr_utility.debug_enabled;
--
if g_debug then
   hr_utility.set_location('hr_entry.del_3p_entry_values', 1);
end if;
--
-- Fix for 1904110.
-- The delete mode is always set to the parameter passed in because
-- the delete of the entry values should always use the same mode
-- as the entry.  See hr_entry_api.del_ele_entry_param_val
--
v_dt_delete_mode := p_dt_delete_mode;
--
if (v_dt_delete_mode = 'ZAP'
or v_dt_delete_mode = 'DELETE') then
  --
  -- Delete rows in child tables which would be orphaned by the entry deletion
  --
  -- Bug fix 519738 - call procedure with new list of parameters, p_start_date defaults to null
  hr_entry.delete_beneficiaries(
        p_element_entry_id => p_element_entry_id,
        p_end_date => p_session_date,
        p_validation_start_date => p_validation_start_date);
  -- Bug fix 519738 - call procedure with new list of parameters, p_start_date defaults to NULL
  hr_entry.delete_covered_dependants(
        p_element_entry_id => p_element_entry_id,
        p_end_date => p_session_date,
        p_validation_start_date => p_validation_start_date);
  --
  -- Find out if the element is processable in a payroll run
  --
  if hr_entry.entry_process_in_run(p_element_type_id, p_session_date) then
    v_process_in_run_flag := 'Y';
  else
    v_process_in_run_flag := 'N';
  end if;
  --
  if v_dt_delete_mode = 'ZAP' then
    --
    -- Enhancement 3205906
    -- No longer need to delete run results for nonrecurring entries and
    -- balance adjustments. These are no longer automatically created.
    /*
    if (p_processing_type = 'N'  or
      p_entry_type      = 'B') then
      --
      -- Check to see if the entry is a balance adjustment. If, yes then
      -- set the status to 'P' for processed.
      --
      if p_entry_type = 'B' then
        v_status := 'P';
      else
        v_status := 'U';
      end if;
      --
      -- delete any run result values providing the entry can be processed
      -- in a payroll run.
      --
      -- DT_DELETE_MODE: ZAP
      -- Step 2:
      --
      if v_process_in_run_flag = 'Y' then
        if g_debug then
           hr_utility.set_location('hr_entry.del_3p_entry_values', 2);
        end if;
        begin
        delete from pay_run_result_values rrv
        where  rrv.run_result_id =
                   (select rr.run_result_id
                    from   pay_run_results rr
                    where  rr.element_type_id + 0 = p_element_type_id
                    and    rr.entry_type          = p_entry_type
                    and    rr.source_id           = p_element_entry_id
                    and    rr.source_type         = 'E'
                    and    rr.status              = v_status);
        end;
        --
        -- delete any unprocessed run results.
        -- DT_DELETE_MODE: ZAP
        -- Step 3:
        --
        if g_debug then
           hr_utility.set_location('hr_entry.del_3p_entry_values', 3);
        end if;
        begin
        delete from pay_run_results rr
        where  rr.element_type_id + 0 = p_element_type_id
        and    rr.entry_type          = p_entry_type
        and    rr.source_id           = p_element_entry_id
        and    rr.source_type         = 'E'
        and    rr.status              = v_status;
        end;
      end if;
    end if;
    */
    -- End of Enhancement 3205906
    --
    -- delete element entry values.
    -- DT_DELETE_MODE: ZAP
    -- Step 4:
    --
    if (p_creator_type = 'F'
    or p_element_entry_id is not null) then
      if g_debug then
         hr_utility.set_location('hr_entry.del_3p_entry_values', 4);
      end if;
      begin
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id = p_element_entry_id;
      end;
    else
      --
      -- As the entry being deleted was not created by the entry form
      -- (e.g. absence) we must delete the entry values.
      -- DT_DELETE_MODE: ZAP
      -- Notes:
      -- 1) Sql needs to be tuned.
      -- 2) This is specific to absences.
      -- Step 5:
      --
      if g_debug then
         hr_utility.set_location('hr_entry.del_3p_entry_values', 5);
      end if;
      begin
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id in
                 (select ee.element_entry_id
                  from   pay_element_entries_f ee
                  where  ee.creator_type    = p_creator_type
                  and    ee.creator_id      = p_creator_id
                  and    ee.entry_type      = p_entry_type
                  and    ee.element_link_id = p_element_link_id
                  and    ee.assignment_id   = p_assignment_id);
      end;
    end if;
    --
    -- We only need to delete from element entries where the entry is a
    -- standard recurring entry which could be datetracked.
    --
    if (p_processing_type = 'R' and
      p_entry_type      = 'E') then
      --
      -- delete element entry
      -- DT_DELETE_MODE: ZAP
      -- Step 6:
      --
      if g_debug then
         hr_utility.set_location('hr_entry.del_3p_entry_values', 6);
      end if;
      begin
      delete from pay_element_entries_f ee
      where  ee.element_entry_id = p_element_entry_id;
      exception
      when NO_DATA_FOUND then NULL;
      end;
      --
    elsif p_creator_type = 'A' then
      --
      -- As the entry is an absence then delete all entries for the absence
      -- attendence.
      --
      if g_debug then
         hr_utility.set_location('hr_entry.del_3p_entry_values', 7);
      end if;
      begin
      delete from pay_element_entries_f ee
      where  ee.creator_type    = p_creator_type
      and    ee.creator_id      = p_creator_id
      and    ee.entry_type      = p_entry_type
      and    ee.element_link_id = p_element_link_id
      and    ee.assignment_id   = p_assignment_id;
      end;
    end if;
    --
  elsif v_dt_delete_mode = 'DELETE' then
    --
    -- set the effective end date on element entry values.
    -- DT_DELETE_MODE: DELETE
    -- Step 8:
    --
    if g_debug then
       hr_utility.set_location('hr_entry.del_3p_entry_values', 8);
    end if;
    begin
    update  pay_element_entry_values_f eev
    set     eev.effective_end_date = p_session_date
    where   eev.element_entry_id   = p_element_entry_id
    and     p_session_date between eev.effective_start_date
                        and     eev.effective_end_date;
    exception
    when NO_DATA_FOUND then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','hr_entry.del_3p_entry_values');
      hr_utility.set_message_token('STEP','8');
      hr_utility.raise_error;
    end;
    --
    if g_debug then
       hr_utility.set_location('hr_entry.del_3p_entry_values', 9);
    end if;
    begin
    delete from pay_element_entry_values_f eev
    where  eev.element_entry_id      = p_element_entry_id
    and    eev.effective_start_date >= p_validation_start_date;
    end;
    --
  end if;
  --
elsif (v_dt_delete_mode = 'DELETE_NEXT_CHANGE'
or v_dt_delete_mode = 'FUTURE_CHANGE') then
  --
  -- delete element entry values between the validation start/end dates.
  -- DT_DELETE_MODE: DELETE_NEXT_CHANGE/FUTURE_CHANGE
  -- Step 9:
  --
  if g_debug then
     hr_utility.set_location('hr_entry.del_3p_entry_values', 9);
  end if;
  begin
  delete from pay_element_entry_values_f eev
  where eev.element_entry_id = p_element_entry_id
  and (
       (eev.effective_end_date between p_validation_start_date
                                        and p_validation_end_date)
    or (eev.effective_start_date between p_validation_start_date
                                        and p_validation_end_date));
  end;
  --
  -- Update the current effective_end_date on the entry values rows.
  -- DT_DELETE_MODE: DELETE_NEXT_CHANGE/FUTURE_CHANGE
  -- Step 10:
  if g_debug then
     hr_utility.set_location('hr_entry.del_3p_entry_values', 10);
  end if;
  begin
  update  pay_element_entry_values_f eev
  -- bug 384948. Changed set clouse to supply effective_end_date of the
  -- element entry as opposite to p_validation_end_date.
  set     eev.effective_end_date =  (select effective_end_date
                                        from pay_element_entries_f
                                        where element_entry_id = p_element_entry_id
                                          and effective_start_date = eev.effective_start_date)
  where   eev.element_entry_id   = p_element_entry_id
  and     p_session_date between eev.effective_start_date
                                and eev.effective_end_date;
  exception
  when NO_DATA_FOUND then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','hr_entry.del_3p_entry_values');
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  end;
  --
  extend_beneficiaries;
  extend_dependants;
  --
end if;
--
end del_3p_entry_values;
--
 procedure upd_3p_ent_values
 (
  p_element_entry_id           number,
  p_element_type_id            number,
  p_element_link_id            number,
  p_cost_allocation_keyflex_id number,
  p_entry_type                 varchar2,
  p_processing_type            varchar2,
  p_creator_type               varchar2,
  p_creator_id                 number,
  p_assignment_id              number,
  p_input_currency_code        varchar2,
  p_output_currency_code       varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date,
  p_session_date               date,
  p_dt_update_mode             varchar2,
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
 ) is
--
   -- Local Variables
   v_return_entry_id    number;
--
 begin
 if g_debug then
    hr_utility.set_location('hr_entry.upd_3p_entry_values', 1);
 end if;
 hr_general.assert_condition (p_processing_type is not null
                        and p_dt_update_mode is not null
                        and p_element_entry_id is not null
                        and p_element_type_id is not null
                        and p_element_link_id is not null
                        and p_entry_type is not null
                        and p_assignment_id is not null
                        and p_validation_start_date is not null
                        and p_validation_end_date is not null
                        and p_session_date is not null
                        and p_validation_start_date = trunc
                                                (p_validation_start_date)
                        and p_validation_end_date = trunc
                                                (p_validation_end_date)
                        and p_session_date = trunc (p_session_date));
                        --
--
-- If the entry is nonrecurring, additional, adjustment, override or the
-- update mode is 'CORRECTION' then:
-- Step 1:
--
   if (p_dt_update_mode  = 'CORRECTION' or  -- DT Correction
       p_processing_type = 'N'          or  -- Nonrecurring Entry
       p_entry_type      = 'D'          or  -- Additional
       p_entry_type      = 'S'          or  -- Override
       p_entry_type      = 'R'          or  -- Replacement Adjustment
       p_entry_type      = 'A')       then  -- Additive Adjustment
--
     if p_num_entry_values > 0 then
--
       -- NB. mandatory checks are not applied to adjustments.
       if not p_entry_type in ('A','R') then
--
         hr_entry.chk_mandatory_entry_values
           (p_element_link_id,
            p_session_date,
            p_num_entry_values,
            p_input_value_id_tbl,
            p_entry_value_tbl);
--
       end if;
--
       for v_loop in 1..p_num_entry_values loop
--
         begin
--
           --
           -- WWbug 273821
           -- Added + 0 to eev.input_value_id to disable the use of
           -- index PAY_ELEMENT_ENTRY_VALUES_F_N1
           --
           update  pay_element_entry_values_f eev
           set     eev.screen_entry_value = p_entry_value_tbl(v_loop)
           where   eev.element_entry_id = p_element_entry_id
             and   eev.input_value_id + 0 = p_input_value_id_tbl(v_loop)
             and   p_validation_start_date between eev.effective_start_date
                                               and eev.effective_end_date;
--
         exception
           when NO_DATA_FOUND then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
                                        'hr_entry.upd_3p_entry_values');
             hr_utility.set_message_token('STEP','1');
             hr_utility.raise_error;
         end;
--
       end loop;
--
     end if;
--
   end if;
--
-- If the entry which has been updated is just nonrecurring
-- and has not been processed and the input currency = output currency then
-- update the run result values.
-- Step 3:
--
   if (p_processing_type     = 'N' and
--       p_creator_type       <> 'A' and
       p_entry_type          = 'E' and
       p_input_currency_code = p_output_currency_code and
       hr_entry.entry_process_in_run(p_element_type_id, p_session_date)) then
     if g_debug then
        hr_utility.set_location('hr_entry.upd_3p_entry_values', 3);
     end if;
     begin
       UPDATE  PAY_RUN_RESULT_VALUES PRRV1
       SET     PRRV1.RESULT_VALUE =
               (SELECT  PEEV1.SCREEN_ENTRY_VALUE
                FROM    PAY_ELEMENT_ENTRY_VALUES_F PEEV1
                WHERE   p_session_date
                BETWEEN PEEV1.EFFECTIVE_START_DATE
                AND     PEEV1.EFFECTIVE_END_DATE
                AND     PEEV1.ELEMENT_ENTRY_ID    = p_element_entry_id
                AND     PEEV1.INPUT_VALUE_ID + 0  = PRRV1.INPUT_VALUE_ID)
        WHERE   PRRV1.RUN_RESULT_ID =
                (SELECT PRR1.RUN_RESULT_ID
                 FROM   PAY_RUN_RESULTS PRR1
                 WHERE  PRR1.SOURCE_ID       = p_element_entry_id
                 AND    PRR1.SOURCE_TYPE     = 'E'
                 AND    PRR1.STATUS          = 'U'
                 AND    PRR1.ELEMENT_TYPE_ID +0 = p_element_type_id);
     exception
       when NO_DATA_FOUND then NULL;
     end;
   end if;
--
-- If a datetrack UPDATE or UPDATE_CHANGE_INSERT or UPDATE_OVERRIDE
-- has taken place then:
-- Step 4:
--
   if ((p_dt_update_mode  = 'UPDATE' or
        p_dt_update_mode  = 'UPDATE_CHANGE_INSERT' or
        p_dt_update_mode  = 'UPDATE_OVERRIDE') and
        p_processing_type = 'R') then
     if g_debug then
        hr_utility.set_location('hr_entry.upd_3p_entry_values', 4);
     end if;
     begin
       UPDATE  PAY_ELEMENT_ENTRY_VALUES_F PEEV1
       SET     PEEV1.EFFECTIVE_END_DATE = p_validation_start_date - 1
       WHERE   PEEV1.ELEMENT_ENTRY_ID   = p_element_entry_id
       AND     p_session_date
       BETWEEN PEEV1.EFFECTIVE_START_DATE AND PEEV1.EFFECTIVE_END_DATE;
     exception
     when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','hr_entry.upd_3p_entry_values');
       hr_utility.set_message_token('STEP','4');
       hr_utility.raise_error;
     end;
--
-- If the update mode = 'UPDATE_OVERRIDE' then delete all entry values that
-- are greater or equal to the validation_start_date
-- Step 4:
--
     if p_dt_update_mode = 'UPDATE_OVERRIDE' then
       if g_debug then
          hr_utility.set_location('hr_entry.upd_3p_entry_values', 5);
       end if;
       begin
         DELETE FROM PAY_ELEMENT_ENTRY_VALUES_F PEEV1
         WHERE  PEEV1.ELEMENT_ENTRY_ID      = p_element_entry_id
         AND    PEEV1.EFFECTIVE_START_DATE >= p_validation_start_date;
       end;
     end if;
--
-- Insert new updated element entry rows.
--
     hr_entry.ins_3p_entry_values
       (p_element_link_id,
        p_element_entry_id,
        p_session_date,
        p_num_entry_values,
        p_input_value_id_tbl,
        p_entry_value_tbl);
--
   end if;
--
 end upd_3p_ent_values;
--
-- NAME
-- hr_entry.upd_3p_entry_values
--
-- DESCRIPTION
-- This procedure is used for third party updates into:
-- PAY_ELEMENT_ENTRY_VALUES_F
-- PAY_RUN_RESULTS           (If nonrecurring).
-- PAY_RUN_RESULT_VALUES     (If nonrecurring).
--
-- NB. this procedure is OVERLOADED !
--
 procedure upd_3p_entry_values
 (
  p_element_entry_id           number,
  p_element_type_id            number,
  p_element_link_id            number,
  p_cost_allocation_keyflex_id number,
  p_entry_type                 varchar2,
  p_processing_type            varchar2,
  p_creator_type               varchar2,
  p_creator_id                 number,
  p_assignment_id              number,
  p_input_currency_code        varchar2,
  p_output_currency_code       varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date,
  p_session_date               date,
  p_dt_update_mode             varchar2,
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
 ) is
--
   -- Local Variables
   v_return_entry_id    number;
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
--
 begin
--
   v_num_entry_values   := p_num_entry_values;
   v_input_value_id_tbl := p_input_value_id_tbl;
   v_entry_value_tbl    := p_entry_value_tbl;
--
   hr_entry_api.conv_table_to_table
     ('DB',
      p_session_date,
      p_element_entry_id,
      null,
      v_num_entry_values,
/** sbilling **/
      p_creator_type,
      p_entry_type,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   hr_entry.upd_3p_ent_values
     (p_element_entry_id,
      p_element_type_id,
      p_element_link_id,
      p_cost_allocation_keyflex_id,
      p_entry_type,
      p_processing_type,
      p_creator_type,
      p_creator_id,
      p_assignment_id,
      p_input_currency_code,
      p_output_currency_code,
      p_validation_start_date,
      p_validation_end_date,
      p_session_date,
      p_dt_update_mode,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
 end upd_3p_entry_values;
--
-- NAME
-- hr_entry.upd_3p_entry_values
--
-- DESCRIPTION
-- This procedure is used for third party updates into:
-- PAY_ELEMENT_ENTRY_VALUES_F
-- PAY_RUN_RESULTS           (If nonrecurring).
-- PAY_RUN_RESULT_VALUES     (If nonrecurring).
--
-- NB. this Procedure is OVERLOADED !
--
 procedure upd_3p_entry_values
 (
  p_element_entry_id           number,
  p_element_type_id            number,
  p_element_link_id            number,
  p_cost_allocation_keyflex_id number,
  p_entry_type                 varchar2,
  p_processing_type            varchar2,
  p_creator_type               varchar2,
  p_creator_id                 number,
  p_assignment_id              number,
  p_input_currency_code        varchar2,
  p_output_currency_code       varchar2,
  p_validation_start_date      date,
  p_validation_end_date        date,
  p_session_date               date,
  p_dt_update_mode             varchar2,
  p_input_value_id1            number,
  p_input_value_id2            number,
  p_input_value_id3            number,
  p_input_value_id4            number,
  p_input_value_id5            number,
  p_input_value_id6            number,
  p_input_value_id7            number,
  p_input_value_id8            number,
  p_input_value_id9            number,
  p_input_value_id10           number,
  p_input_value_id11           number,
  p_input_value_id12           number,
  p_input_value_id13           number,
  p_input_value_id14           number,
  p_input_value_id15           number,
  p_entry_value1               varchar2,
  p_entry_value2               varchar2,
  p_entry_value3               varchar2,
  p_entry_value4               varchar2,
  p_entry_value5               varchar2,
  p_entry_value6               varchar2,
  p_entry_value7               varchar2,
  p_entry_value8               varchar2,
  p_entry_value9               varchar2,
  p_entry_value10              varchar2,
  p_entry_value11              varchar2,
  p_entry_value12              varchar2,
  p_entry_value13              varchar2,
  p_entry_value14              varchar2,
  p_entry_value15              varchar2
 ) is
--
   -- Local variables
   v_num_entry_values   number;
   v_input_value_id_tbl hr_entry.number_table;
   v_entry_value_tbl    hr_entry.varchar2_table;
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hr_entry.upd_3p_entry_values',100);
   end if;
--
   -- Convert entry value details ie. INPUT_VALUE_ID and SCREEN_ENTRY_VALUE
   -- into two tables to be passed into the overloaded version of
   -- upd_3p_entry_values. The overloaded version is capable of handling
   -- unlimited numbers of entry values.
   hr_entry_api.conv_entry_values_to_table
     ('DB',
      p_element_entry_id,
      null,
      p_session_date,
/** sbilling **/
      p_creator_type,
      p_entry_type,
      p_input_value_id1,
      p_input_value_id2,
      p_input_value_id3,
      p_input_value_id4,
      p_input_value_id5,
      p_input_value_id6,
      p_input_value_id7,
      p_input_value_id8,
      p_input_value_id9,
      p_input_value_id10,
      p_input_value_id11,
      p_input_value_id12,
      p_input_value_id13,
      p_input_value_id14,
      p_input_value_id15,
      p_entry_value1,
      p_entry_value2,
      p_entry_value3,
      p_entry_value4,
      p_entry_value5,
      p_entry_value6,
      p_entry_value7,
      p_entry_value8,
      p_entry_value9,
      p_entry_value10,
      p_entry_value11,
      p_entry_value12,
      p_entry_value13,
      p_entry_value14,
      p_entry_value15,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
   if g_debug then
      hr_utility.set_location('hr_entry.upd_3p_entry_values',105);
   end if;
--
   hr_entry.upd_3p_ent_values
     (p_element_entry_id,
      p_element_type_id,
      p_element_link_id,
      p_cost_allocation_keyflex_id,
      p_entry_type,
      p_processing_type,
      p_creator_type,
      p_creator_id,
      p_assignment_id,
      p_input_currency_code,
      p_output_currency_code,
      p_validation_start_date,
      p_validation_end_date,
      p_session_date,
      p_dt_update_mode,
      v_num_entry_values,
      v_input_value_id_tbl,
      v_entry_value_tbl);
--
 end upd_3p_entry_values;
--
-- NAME
-- hr_entry.trigger_workload_shifting
--
-- DESCRIPTION
-- This procedure is used for triggering workload shifting.
--
 PROCEDURE trigger_workload_shifting(p_mode varchar2,
                                     p_assignment_id          number,
                                     p_effective_start_date   date,
                                     p_effective_end_date     date) is
 v_assignment_action_id  number;
--
 begin
 -- Workload shifting is NOT used.
 return;
--
-- Find the latest assignment action for the assignment.
--
-- If it is
--
-- 1. A Payroll Run
-- 2. It is Completed ie. processed.
-- 3. The period in which it was earned overlaps with a change in
--    assignment or element entry criteria.
-- 4. The payroll has workload shifting enabled and matches the type of
--    change ie. Element Entry or Assignment.
-- 5. The change does not cross more than one payroll run in the latest
--    period.
--
-- then Mark for Retry the assignment action
--
/* -- irrelevant, commented out.
   update pay_assignment_actions paa
   set    paa.action_status = 'M'
   where  paa.assignment_action_id =
    (select aa.assignment_action_id
     from   pay_assignment_actions aa,
            pay_payroll_actions pa,
            per_assignments_f asg,
            per_time_periods tim,
            pay_payrolls_f pp
     where  pa.effective_date =
                (select max(pa2.effective_date)
                 from   pay_payroll_actions pa2,
                        pay_assignment_actions aa2
                 where  aa2.assignment_id     = p_assignment_id
                   and  pa2.payroll_action_id = aa2.payroll_action_id)
       and  pa.action_sequence =
                (select max(pa3.action_sequence)
                 from   pay_payroll_actions pa3,
                        pay_assignment_actions aa3
                 where  aa3.assignment_id     = p_assignment_id
                   and  pa3.payroll_action_id = aa3.payroll_action_id
                   and  pa3.effective_date    = pa.effective_date)
       and  not exists
              (select null
               from   pay_payroll_actions pa4,
                      pay_assignment_actions aa4
               where  aa4.assignment_id     = p_assignment_id
                 and  aa4.payroll_action_id = pa4.payroll_action_id
                 and  pa4.action_type       = 'R'
                 and  pa4.action_sequence   < pa.action_sequence
                 and  nvl(pa4.date_earned,pa4.effective_date) between
                         greatest(tim.start_date,p_effective_start_date) and
                         pa.effective_date)
       and  pa.action_type       = 'R'
       and  aa.payroll_action_id = pa.payroll_action_id
       and  aa.action_status     = 'C'
       and  aa.assignment_id     = p_assignment_id
       and  asg.assignment_id    = aa.assignment_id
       and  pp.payroll_id        = asg.payroll_id
       and  tim.payroll_id       = pp.payroll_id
       and  nvl(pa.date_earned,pa.effective_date)
                           between asg.effective_start_date
                               and asg.effective_end_date
       and  nvl(pa.date_earned,pa.effective_date)
                           between pp.effective_start_date
                               and pp.effective_end_date
       and  nvl(pa.date_earned,pa.effective_date)
                           between tim.start_date
                               and tim.end_date
       and  nvl(pa.date_earned,pa.effective_date)
                           between p_effective_start_date
                               and p_effective_end_date
       and  p_effective_start_date <= tim.end_date
       and  p_effective_end_date   >= tim.start_date
       and ((p_mode = 'ELEMENT_ENTRY'
             and (pp.workload_shifting_level = 'E' or
                  pp.workload_shifting_level = 'A'))
        or  (p_mode = 'ASSIGNMENT'
             and pp.workload_shifting_level  = 'A')));
*/
--
 end trigger_workload_shifting;
--
-- NAME
-- hr_entry.check_format
--
-- DESCRIPTION
-- Makes sure that the entry value is correct for the UOM and also convert the
-- screen value into the database value ie. internal format.
--
 procedure check_format
 (
  p_element_link_id     in            number,
  p_input_value_id      in            number,
  p_session_date        in            date,
  p_formatted_value     in out nocopy varchar2,
  p_database_value      in out nocopy varchar2,
  p_nullok              in            varchar2 default 'Y',
  p_min_max_failure     in out nocopy varchar2,
  p_warning_or_error       out nocopy varchar2,
  p_minimum_value          out nocopy varchar2,
  p_maximum_value          out nocopy varchar2
 ) is
--
   -- Local Variables
   v_checkformat_error   boolean := false;
-- --
   --v_message_text        varchar2(80);
   v_message_text     HR_LOOKUPS.meaning%TYPE;
-- --
   v_uom                 varchar2(30);
   v_hot_default_flag    varchar2(30);
   v_input_currency_code varchar2(30);
   v_minimum_value       varchar2(60);
   v_maximum_value       varchar2(60);
   v_warning_or_error    varchar2(30);
   v_formatted_min_value varchar2(60);
   v_formatted_max_value varchar2(60);
--
 begin
   g_debug := hr_utility.debug_enabled;
--
   if g_debug then
      hr_utility.set_location('hr_entry.check_format',5);
      hr_utility.trace('        p_element_link_id : '|| p_element_link_id);
      hr_utility.trace('        p_input_value_id : '|| p_input_value_id);
      hr_utility.trace('        p_session_date : '|| p_session_date);
      hr_utility.trace('        p_formatted_value : '|| p_formatted_value);
      hr_utility.trace('        p_database_value : '|| p_database_value);
      hr_utility.trace('        p_nullok : '|| p_nullok);
      hr_utility.trace('        p_min_max_failure : '|| p_min_max_failure);
   end if;
--
   -- Get uom , min / max and hot default details for the entry value
   -- being validated.
   begin
--
-- Dave Harris, 13-Oct-1994
-- Bug G1420: restricted pay_element_types_f using date effective dates.
--
     -- INDEX hint added following NHS project recommendation
     select /*+ INDEX(liv, pay_link_input_values_f_n2) */
            iv.uom,
            iv.hot_default_flag,
            et.input_currency_code,
            decode(iv.hot_default_flag,
                     'Y',nvl(liv.min_value,
                             iv.min_value)
                        ,liv.min_value),
            decode(iv.hot_default_flag,
                     'Y',nvl(liv.max_value,
                             iv.max_value)
                        ,liv.max_value),
            decode(iv.hot_default_flag,
                     'Y',nvl(liv.warning_or_error,
                             iv.warning_or_error)
                        ,liv.warning_or_error)
     into   v_uom,
            v_hot_default_flag,
            v_input_currency_code,
            v_minimum_value,
            v_maximum_value,
            v_warning_or_error
     from   pay_link_input_values_f liv,
            pay_input_values_f iv,
            pay_element_types_f et
     where  liv.element_link_id = p_element_link_id
       and  liv.input_value_id  = p_input_value_id
       and  iv.input_value_id   = liv.input_value_id
       and  et.element_type_id  = iv.element_type_id
       and  p_session_date between liv.effective_start_date
                               and liv.effective_end_date
       and  p_session_date between iv.effective_start_date
                               and iv.effective_end_date
       and  p_session_date between et.effective_start_date
                               and et.effective_end_date;
--
     -- Bug 1123084, always set up this value.
     p_warning_or_error := v_warning_or_error;
--
   exception
     when no_data_found then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry.check_format');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
   end;
--
   if g_debug then
      hr_utility.set_location('hr_entry.check_format',10);
      hr_utility.trace('        v_uom : '|| v_uom);
      hr_utility.trace('        v_hot_default_flag : '|| v_hot_default_flag);
      hr_utility.trace('        v_input_currency_code : '|| v_input_currency_code);
      hr_utility.trace('        v_minimum_value : '|| v_minimum_value);
      hr_utility.trace('        v_maximum_value : '|| v_maximum_value);
      hr_utility.trace('        v_warning_or_error : '|| v_warning_or_error);
   end if;
--
   IF ((v_uom = 'M') AND (v_input_currency_code IS NULL)) THEN
     hr_utility.set_message (801,'HR_51106_ELEMENT_CURR_REQ');
     hr_utility.raise_error;
   END IF;
--
   if v_minimum_value is not null then
--
     hr_chkfmt.changeformat(v_minimum_value,
                            v_formatted_min_value,
                            v_uom,
                            v_input_currency_code);
--
   end if;
--
   if v_maximum_value is not null then
--
     hr_chkfmt.changeformat(v_maximum_value,
                            v_formatted_max_value,
                            v_uom,
                            v_input_currency_code);
--
   end if;
--
   -- Now format the value.
   begin
     hr_chkfmt.checkformat(p_formatted_value,
                           v_uom,
                           p_database_value,
                           v_minimum_value,
                           v_maximum_value,
                           p_nullok,
                           p_min_max_failure,
                           v_input_currency_code);
   exception
     when hr_utility.hr_error then
        v_checkformat_error := true;
   end;
--
   if g_debug then
      hr_utility.set_location('hr_entry.check_format',10);
   end if;
--
   -- Value is not correct for unit of measure
   if (v_checkformat_error) then
--
     begin
--
       select meaning
       into   v_message_text
       from   hr_lookups
       where  lookup_type = 'UNITS'
       and    lookup_code = v_uom;
--
     exception
       when no_data_found then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', 'hr_entry.check_format');
         hr_utility.set_message_token('STEP', '2');
         hr_utility.raise_error;
     end;
--
     hr_utility.set_message(801, 'PAY_6306_INPUT_VALUE_FORMAT');
     hr_utility.set_message_token('UNIT_OF_MEASURE', v_message_text);
     hr_utility.raise_error;
--
   end if;
--
   if g_debug then
      hr_utility.set_location('hr_entry.check_format',15);
   end if;
--
   -- Minimum / maximum conditions have been broken by value
   if p_min_max_failure = 'F' then
--
     if g_debug then
        hr_utility.set_location('hr_entry.check_format',20);
     end if;
--
     -- If minimum value was specified, translate into screen format for use
     -- in error meessages
     if v_minimum_value is not null then
       p_minimum_value := v_formatted_min_value;
     end if;
--
     if g_debug then
        hr_utility.set_location('hr_entry.check_format',25);
     end if;
--
     -- If maximum value was specified, translate into screen format for use
     -- in error meessages
     if v_maximum_value is not null then
       p_maximum_value := v_formatted_max_value;
     end if;
--
   end if;
--
 end check_format;
--
-- NAME
-- hr_entry.maintain_cost_keyflex
--
-- DESCRIPTION
--
 function maintain_cost_keyflex(
            p_cost_keyflex_structure     in number,
            p_cost_allocation_keyflex_id in number,
            p_concatenated_segments      in varchar2,
            p_summary_flag               in varchar2,
            p_start_date_active          in date,
            p_end_date_active            in date,
            p_segment1                   in varchar2,
            p_segment2                   in varchar2,
            p_segment3                   in varchar2,
            p_segment4                   in varchar2,
            p_segment5                   in varchar2,
            p_segment6                   in varchar2,
            p_segment7                   in varchar2,
            p_segment8                   in varchar2,
            p_segment9                   in varchar2,
            p_segment10                  in varchar2,
            p_segment11                  in varchar2,
            p_segment12                  in varchar2,
            p_segment13                  in varchar2,
            p_segment14                  in varchar2,
            p_segment15                  in varchar2,
            p_segment16                  in varchar2,
            p_segment17                  in varchar2,
            p_segment18                  in varchar2,
            p_segment19                  in varchar2,
            p_segment20                  in varchar2,
            p_segment21                  in varchar2,
            p_segment22                  in varchar2,
            p_segment23                  in varchar2,
            p_segment24                  in varchar2,
            p_segment25                  in varchar2,
            p_segment26                  in varchar2,
            p_segment27                  in varchar2,
            p_segment28                  in varchar2,
            p_segment29                  in varchar2,
            p_segment30                  in varchar2)
          return number is
--
   cursor csr_cost_alloc_exists is
     select pca.cost_allocation_keyflex_id
     from   pay_cost_allocation_keyflex pca
     where  pca.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;
--
   cursor get_seg_order is
     select substr(application_column_name,8,2)
     from   fnd_id_flex_segments_vl
     where  id_flex_code = 'COST'
     and    id_flex_num  = p_cost_keyflex_structure
     and    application_id = 801
     and    enabled_flag = 'Y'
     and    display_flag = 'Y'
     order by segment_num;
--
   l_dummy number;
   l_cost_allocation_keyflex_id number := p_cost_allocation_keyflex_id;
--
   type segment_table is table of varchar2(60)
        index by binary_integer;
   segment            segment_table;
   i                  number;
   sql_curs           number;
   rows_processed     integer;
   statem             varchar2(2000);
--
   l_delimiter         varchar2(1);
   l_concat_string     varchar2(2000);
-- l_concatenated_segments      varchar2(240);
-- bugfix 1856433
   l_concatenated_segments      varchar2(2000);
   l_disp_no       number;
   first_seg       boolean;
--
   v_cal_cost_segs varchar2(3); -- user profile
   l_are_dynamic_inserts_allowed varchar2(2) := null;
--
 begin
   g_debug := hr_utility.debug_enabled;

   -- A cost_keyflex_id has been specified so confirm it still is valid.
   if (l_cost_allocation_keyflex_id is not null and
       l_cost_allocation_keyflex_id <> -1) then
--
     open csr_cost_alloc_exists;
     fetch csr_cost_alloc_exists into l_dummy;
--
     -- Keyflex does not exist so need to rederive a cost_keyflex_id.
     if csr_cost_alloc_exists%notfound then
       l_cost_allocation_keyflex_id := -1;
     -- Keyflex does exist.
     else
       l_cost_allocation_keyflex_id := p_cost_allocation_keyflex_id;
     end if;
--
     close csr_cost_alloc_exists;
--
   end if;

   if (l_cost_allocation_keyflex_id = -1) then
--
-- Need to check for a partial value.
--
    if g_debug then
       hr_utility.set_location('hr_entry.maintain_cost_keyflex', 1);
    end if;
--
      segment(1) := p_segment1;
      segment(2) := p_segment2;
      segment(3) := p_segment3;
      segment(4) := p_segment4;
      segment(5) := p_segment5;
      segment(6) := p_segment6;
      segment(7) := p_segment7;
      segment(8) := p_segment8;
      segment(9) := p_segment9;
      segment(10) := p_segment10;
      segment(11) := p_segment11;
      segment(12) := p_segment12;
      segment(13) := p_segment13;
      segment(14) := p_segment14;
      segment(15) := p_segment15;
      segment(16) := p_segment16;
      segment(17) := p_segment17;
      segment(18) := p_segment18;
      segment(19) := p_segment19;
      segment(20) := p_segment20;
      segment(21) := p_segment21;
      segment(22) := p_segment22;
      segment(23) := p_segment23;
      segment(24) := p_segment24;
      segment(25) := p_segment25;
      segment(26) := p_segment26;
      segment(27) := p_segment27;
      segment(28) := p_segment28;
      segment(29) := p_segment29;
      segment(30) := p_segment30;
      --
      statem := '
      select cost_allocation_keyflex_id
      from   pay_cost_allocation_keyflex c
      where  c.id_flex_num   = :p_cost_keyflex_structure
      and    c.enabled_flag  = ''Y''';
      --
      for i in 1..30 loop
        if segment(i) is null then
           statem := statem || ' and c.segment'||i||' is null';
        else
           statem := statem || ' and c.segment'||i||' = :p_segment'||i;
        end if;
      end loop;
      --
      if g_debug then
         hr_utility.set_location('hr_entry.maintain_cost_keyflex', 2);
      end if;
      --
      sql_curs := dbms_sql.open_cursor;
      --
      dbms_sql.parse(sql_curs,
                      statem,
                     dbms_sql.v7);
      --
      dbms_sql.bind_variable(sql_curs, 'p_cost_keyflex_structure', p_cost_keyflex_structure);
      --
      for i in 1..30 loop
        if segment(i) is not null then
           dbms_sql.bind_variable(sql_curs, 'p_segment'||i, segment(i));
        end if;
      end loop;
      dbms_sql.define_column(sql_curs, 1, l_cost_allocation_keyflex_id);
      --
      if g_debug then
         hr_utility.set_location('hr_entry.maintain_cost_keyflex', 3);
      end if;
      --
      rows_processed := dbms_sql.execute(sql_curs);
      --
      if g_debug then
         hr_utility.set_location('hr_entry.maintain_cost_keyflex ', 4);
      end if;
      --
      if dbms_sql.fetch_rows(sql_curs) > 0 then
      --
        if g_debug then
           hr_utility.set_location('hr_entry.maintain_cost_keyflex', 5);
        end if;
        dbms_sql.column_value(sql_curs, 1, l_cost_allocation_keyflex_id);
      --
        if (l_cost_allocation_keyflex_id is null)
        then
           if g_debug then
              hr_utility.set_location('hr_entry.maintain_cost_keyflex', 6);
           end if;
           l_cost_allocation_keyflex_id := -1;
        end if;
      else
          if g_debug then
             hr_utility.set_location('hr_entry.maintain_cost_keyflex', 7);
          end if;
          l_cost_allocation_keyflex_id := -1;
      end if;
      --
      dbms_sql.close_cursor(sql_curs);
      --
--
-- Check to see if the cost allocation keyflex combination already
-- exists.
-- If it doesn't then, insert the required row.
--
    if (l_cost_allocation_keyflex_id = -1) THEN

   --Bug # 5860023
   --Check whether dynamice inserts are allowed.
   --If not allowed then raise a suitable error message.

   BEGIN

        select 'Y' into l_are_dynamic_inserts_allowed
        from   fnd_id_flex_structures_vl
        where  id_flex_code = 'COST'
        and    id_flex_num  = p_cost_keyflex_structure
        and    application_id = 801
        and    enabled_flag = 'Y'
        and    dynamic_inserts_allowed_flag = 'Y';

   exception
        when no_data_found then
        hr_utility.set_location('hr_entry.maintain_cost_keyflex', 7);
        hr_utility.set_message(801, 'PAY_34809_CANT_INS_INTO_CSTKFF');
        hr_utility.raise_error;
   end;

--
-- Select the next sequence value for the cost allocation keyflex.
--
      if g_debug then
         hr_utility.set_location('hr_entry.maintain_cost_keyflex', 8);
      end if;
      begin
        select pay_cost_allocation_keyflex_s.nextval
        into   l_cost_allocation_keyflex_id
        from   sys.dual;
      exception
        when NO_DATA_FOUND then
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE',
                                       'hr_entry.maintain_cost_keyflex');
          hr_utility.set_message_token('STEP','5');
          hr_utility.raise_error;
      end;
--
-- Calculate concatenated_segments if a null value was passed in
--
      if p_concatenated_segments is null then
        --
        if g_debug then
           hr_utility.set_location('hr_entry.maintain_cost_keyflex', 15);
        end if;
        -- get delimiter
        l_delimiter := fnd_flex_ext.get_delimiter
                     ('PAY'
                     ,'COST'
                     ,p_cost_keyflex_structure
                     );
        --
        if g_debug then
           hr_utility.set_location('hr_entry.maintain_cost_keyflex', 20);
        end if;
        --
        first_seg := true;

        open get_seg_order;
        loop
          fetch get_seg_order into l_disp_no;
          exit when get_seg_order%NOTFOUND;

          if first_seg = false then
             l_concat_string := l_concat_string || l_delimiter;
          else
             first_seg := false;
          end if;

          if segment(l_disp_no) is not null then
             l_concat_string := l_concat_string || segment(l_disp_no);
          end if;

        end loop;
        close get_seg_order;
        --
        l_concatenated_segments := substr(l_concat_string, 1, 240);
      else
        --
        if g_debug then
           hr_utility.set_location('hr_entry.maintain_cost_keyflex', 25);
        end if;
        --
        l_concatenated_segments := p_concatenated_segments;
      end if;
--
-- Perform Flexfield Validation: if COST_VAL_SEGS pay_action_parameter = 'Y'
--
      begin
         select parameter_value
         into v_cal_cost_segs
         from pay_action_parameters
         where parameter_name = 'COST_VAL_SEGS';
      exception
         when others then
            v_cal_cost_segs := 'N';
      end;

      if (v_cal_cost_segs = 'Y') then
--
         if fnd_flex_keyval.validate_segs
                (operation        => 'CHECK_SEGMENTS'
                ,appl_short_name  => 'PAY'
                ,key_flex_code    => 'COST'
                ,structure_number => p_cost_keyflex_structure
                ,concat_segments  => l_concatenated_segments
                ,allow_nulls      => TRUE
                ,values_or_ids    => 'V'
                ) = FALSE
         then
           --
           if g_debug then
              hr_utility.set_location('hr_entry.maintain_cost_keyflex', 27);
           end if;
           --
           -- Handle error raised to create a nice error message!
           --
           hr_message.parse_encoded(p_encoded_error =>
                                    FND_FLEX_KEYVAL.encoded_error_message);
           fnd_message.raise_error;
         else
           if g_debug then
              hr_utility.set_location('hr_entry.maintain_cost_keyflex', 28);
           end if;

         end if;
      end if;
--
-- Insert the new row.
--
      if g_debug then
         hr_utility.set_location('hr_entry.maintain_cost_keyflex', 30);
      end if;
      begin
        insert into pay_cost_allocation_keyflex
        (cost_allocation_keyflex_id
        ,concatenated_segments
        ,id_flex_num
        ,last_update_date
        ,last_updated_by
        ,summary_flag
        ,enabled_flag
        ,start_date_active
        ,end_date_active
        ,segment1
        ,segment2
        ,segment3
        ,segment4
        ,segment5
        ,segment6
        ,segment7
        ,segment8
        ,segment9
        ,segment10
        ,segment11
        ,segment12
        ,segment13
        ,segment14
        ,segment15
        ,segment16
        ,segment17
        ,segment18
        ,segment19
        ,segment20
        ,segment21
        ,segment22
        ,segment23
        ,segment24
        ,segment25
        ,segment26
        ,segment27
        ,segment28
        ,segment29
        ,segment30)
        values
        (l_cost_allocation_keyflex_id
        ,l_concatenated_segments
        ,p_cost_keyflex_structure
        ,null
        ,null
        ,p_summary_flag
        ,'Y'
        ,p_start_date_active
        ,p_end_date_active
        ,p_segment1
        ,p_segment2
        ,p_segment3
        ,p_segment4
        ,p_segment5
        ,p_segment6
        ,p_segment7
        ,p_segment8
        ,p_segment9
        ,p_segment10
        ,p_segment11
        ,p_segment12
        ,p_segment13
        ,p_segment14
        ,p_segment15
        ,p_segment16
        ,p_segment17
        ,p_segment18
        ,p_segment19
        ,p_segment20
        ,p_segment21
        ,p_segment22
        ,p_segment23
        ,p_segment24
        ,p_segment25
        ,p_segment26
        ,p_segment27
        ,p_segment28
        ,p_segment29
        ,p_segment30);
      end;
--
    end if;
--
  return(l_cost_allocation_keyflex_id);
--
  end if;
--
  return(l_cost_allocation_keyflex_id);
--
 end maintain_cost_keyflex;
--
--
-- NAME
-- hr_entry.return_entry_display_status
--
-- DESCRIPTION
-- Used by PAYEEMEE/PAYWSMEE to return current entry statuses during a
-- post-query.
--
 procedure return_entry_display_status(p_element_entry_id  in number,
                                       p_element_type_id   in number,
                                       p_element_link_id   in number,
                                       p_assignment_id     in number,
                                       p_entry_type        in varchar2,
                                       p_session_date      in date,
                                       p_additional       out nocopy varchar2,
                                       p_adjustment       out nocopy varchar2,
                                       p_overridden       out nocopy varchar2,
                                       p_processed        out nocopy varchar2) is
   l_run_result_id              number;
   l_payroll_id                 number;
   l_overridden                 varchar2(30) := 'N';
   l_start_date                 date;
   l_end_date                   date;
   l_skip_further_checks        varchar2(30) := 'N';
   l_run_result_status          varchar2(30);
 begin
   g_debug := hr_utility.debug_enabled;
--
-- We need to get the standard assignment payroll and time period details
--
   if g_debug then
      hr_utility.set_location('hr_entry.return_entry_display_status', 1);
   end if;
   begin
     select  a.payroll_id,
             t.start_date,
             t.end_date
     into    l_payroll_id,
             l_start_date,
             l_end_date
     from    per_time_periods  t,
             per_assignments_f a
     where   a.assignment_id = p_assignment_id
     and     p_session_date
     between a.effective_start_date
     and     a.effective_end_date
     and     a.payroll_id is not null
     and     t.payroll_id = a.payroll_id
     and     p_session_date
     between t.start_date
     and     t.end_date;
   exception
     when NO_DATA_FOUND then
       NULL;
   end;
--
-- 1: lets set the additional value.
--
   if g_debug then
      hr_utility.set_location('hr_entry.return_entry_display_status', 5);
   end if;
   if (p_entry_type = 'D') then
     p_additional := 'Y';
   else
     p_additional := 'N';
   end if;
--
-- 2: lets see if current entry has been processed.
--
   if g_debug then
      hr_utility.set_location('hr_entry.return_entry_display_status', 10);
   end if;
   if (l_payroll_id is not null) then
     begin
       select  max(ppr.run_result_id)
       into    l_run_result_id
       from    pay_run_results            ppr,
               pay_assignment_actions     paa,
               pay_payroll_actions        ppa,
               pay_action_classifications pac
       where   ppr.source_id            = p_element_entry_id
       and     ppr.source_type          = 'E'
       and     ppr.entry_type           = p_entry_type
       and     ppr.status              <> 'U'
       and     ppr.element_type_id      = p_element_type_id
       and     ppr.assignment_action_id = paa.assignment_action_id
       and     paa.assignment_id        = p_assignment_id
       and     paa.action_status        = 'C'
       and     paa.payroll_action_id    = ppa.payroll_action_id
       and     ppa.payroll_id           = l_payroll_id
       and     pac.classification_name  = 'QP_PAYRUN'
       and     ppa.action_type          = pac.action_type
       and     ppa.effective_date
       between l_start_date
       and     l_end_date;
     end;
--
-- If the run result does not exist then set l_processed to 'N'.
-- If the run result was processed and is an override then it cannot itself
-- be overridden or adjusted.
--
     if g_debug then
        hr_utility.set_location('hr_entry.return_entry_display_status', 15);
     end if;
     if (l_run_result_id is not null and
         p_entry_type = 'S') then
       p_processed   := 'Y';
       p_overridden  := 'N';
       p_adjustment  := 'N';
       l_skip_further_checks := 'Y';
     elsif (l_run_result_id is null) then
       p_processed := 'N';
     else
       p_processed := 'Y';
--
-- As the entry was processed we need to check if it was overridden or
-- Adjusted.
--
       if g_debug then
          hr_utility.set_location('hr_entry.return_entry_display_status', 20);
       end if;
       begin
         select  prr.status
         into    l_run_result_status
         from    pay_run_results prr
         where   prr.run_result_id = l_run_result_id;
       exception
         when NO_DATA_FOUND then
           l_run_result_status := 'UNKNOWN';
       end;
--
-- If the l_run_result_status is NOT in 'PA', 'R', 'O' then set the
-- l_override, l_adjusted to 'N' and to don't do any further checks.
--
       if g_debug then
          hr_utility.set_location('hr_entry.return_entry_display_status', 25);
       end if;
       if (l_run_result_status <> 'PA' or
           l_run_result_status <> 'R'  or
           l_run_result_status <> 'O') then
         p_overridden  := 'N';
         p_adjustment  := 'N';
         l_skip_further_checks := 'Y';
       end if;
     end if;
   end if;
--
-- If we need to do further checks then we must check to see if the entry
-- is overridden or adjusted.
--
   if (l_skip_further_checks = 'N') then
--
-- 3: Check to see if the entry is overridden.
--
    if g_debug then
       hr_utility.set_location('hr_entry.return_entry_display_status', 30);
    end if;
     begin
       select  'Y'
       into    l_overridden
       from    pay_element_entries_f pee
       where   p_session_date
       between pee.effective_start_date
       and     pee.effective_end_date
       and     pee.entry_type = 'S'
       and     pee.assignment_id   = p_assignment_id
       and     pee.element_link_id = p_element_link_id;
     exception
       when NO_DATA_FOUND then
         p_overridden := 'N';
     end;
--
     p_overridden := l_overridden;
--
-- 4: If the entry is NOT overridden then check to see if has been adjusted.
--
     if (l_overridden = 'N') then
       if g_debug then
          hr_utility.set_location('hr_entry.return_entry_display_status', 35);
       end if;
       begin
         select  'Y'
         into    p_adjustment
         from    pay_element_entries_f pee
         where   p_session_date
         between pee.effective_start_date
         and     pee.effective_end_date
         and     (pee.entry_type = 'R'
         or       pee.entry_type = 'A')
         and     pee.assignment_id   = p_assignment_id
         and     pee.element_link_id = p_element_link_id
         and     pee.target_entry_id = p_element_entry_id;
       exception
         when NO_DATA_FOUND then
           p_adjustment := 'N';
       end;
     end if;
   end if;
--
 end return_entry_display_status;
--
-- NAME
-- hr_entry.chk_creator_type
--
-- DESCRIPTION
-- Used by PAYEEMEE/PAYWSMEE to restrict DT operations according to the
-- creator type ie. cannot update a balance adjustment etc ...
--
procedure chk_creator_type(p_element_entry_id      in number,
                           p_creator_type          in varchar2,
                           p_quickpay_mode         in varchar2,
                           p_dml_operation         in varchar2,
                           p_dt_update_mode        in varchar2,
                           p_dt_delete_mode        in varchar2,
                           p_validation_start_date in date,
                           p_validation_end_date   in date) is
-- --
--l_creator_meaning     varchar2(80);
  l_creator_meaning     HR_LOOKUPS.meaning%TYPE;
-- --
  l_error_flag          varchar2(30) := 'N';
  l_dt_update_mode      varchar2(30) := nvl(p_dt_update_mode, 'CORRECTION');
  l_dt_delete_mode      varchar2(30) := nvl(p_dt_delete_mode, 'ZAP');
begin
  g_debug := hr_utility.debug_enabled;
  if (p_creator_type  = 'A'  or
      p_creator_type  = 'M'  or
      p_creator_type  = 'S'  or
      p_creator_type  = 'UT' or
      p_creator_type  = 'B'  or
     (p_creator_type  = 'Q'  and
      p_quickpay_mode = 'E') or
     (p_creator_type  = 'SP' and
        ((p_dml_operation   = 'DELETE' and
          l_dt_delete_mode  = 'ZAP')   or
         (p_dml_operation   = 'UPDATE' and
          l_dt_update_mode  = 'CORRECTION')))) then
--
-- We must error because we cannot Update or Delete an entry which is for:
-- A:  Absence
-- M:  SMP
-- S:  SSP
-- Q:  QuickPay
-- UT: Us Tax
-- B:  Balance Adjustment
-- SP: Salary Admin
--
    if g_debug then
       hr_utility.set_location('hr_entry.chk_creator_type', 5);
    end if;
    begin
      select h.meaning
      into   l_creator_meaning
      from   hr_lookups h
      where  h.lookup_type = 'CREATOR_TYPE'
      and    h.lookup_code = p_creator_type;
    exception
      when NO_DATA_FOUND then
        null;
    end;
--
    if (p_dml_operation = 'UPDATE') then
      hr_utility.set_message(801, 'HR_7014_ELE_ENTRY_CREATOR_UPD');
      hr_utility.set_message_token('CREATOR_MEANING', l_creator_meaning);
      hr_utility.raise_error;
    else
      hr_utility.set_message(801, 'HR_7015_ELE_ENTRY_CREATOR_DEL');
      hr_utility.set_message_token('CREATOR_MEANING', l_creator_meaning);
      hr_utility.raise_error;
    end if;
--
-- If the creator_type = 'F' then we need to ensure that we are NOT extending
-- or removing entries where a parent 'SP' (Salary Admin) record exists.
--

--
-- If the creator type = 'F' then we need to ensure that we are NOT extending
-- or removing entries where a parent 'SP' (Salary Admin) record exists.
-- Also,
-- If the creator type = 'SP' then we need to ensure that we are NOT extending
-- or removing entries where a parent 'SP' (Salary Admin) record exists.
--
  elsif ((p_creator_type    = 'F'       and
         (p_dml_operation   = 'DELETE'  or
         (p_dml_operation   = 'UPDATE'  and
          l_dt_update_mode  = 'UPDATE_OVERRIDE'))) or
         (p_creator_type    = 'SP'      and
        ((p_dml_operation   = 'DELETE' and
          l_dt_delete_mode <> 'ZAP')   or
         (p_dml_operation   = 'UPDATE' and
          l_dt_update_mode  = 'UPDATE_OVERRIDE')))) then
--
    if g_debug then
       hr_utility.set_location('hr_entry.chk_creator_type', 10);
    end if;
    begin
      select  'Y'
      into    l_error_flag
      from    sys.dual
      where   exists
              (select  1
               from    pay_element_entries_f pee
               where   pee.element_entry_id = p_element_entry_id
               and     pee.creator_type     = 'SP'
               and     pee.effective_start_date >= p_validation_start_date);
    exception
      when NO_DATA_FOUND then
        NULL;
    end;
--
-- Check to see if the Salary Admin Entry exists:
--
    if (l_error_flag = 'Y') then
      hr_utility.set_message(801, 'HR_7017_ELE_ENTRY_SP_CORRECT');
      hr_utility.raise_error;
    end if;
  end if;
--
end chk_creator_type;
--
end hr_entry;

/
