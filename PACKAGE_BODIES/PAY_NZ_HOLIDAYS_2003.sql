--------------------------------------------------------
--  DDL for Package Body PAY_NZ_HOLIDAYS_2003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_HOLIDAYS_2003" as
  --  $Header: pynzhl2003.pkb 120.2.12010000.3 2008/09/12 12:20:38 lnagaraj ship $
  --
  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Change List
  --  ===========
  --
  --  Date        Author      Reference Description
  --  -----------+-----------+---------+--------------------------------------------
  --  03 FEB 2003 sclarke     3417767   Adjustments now taken off entitlement before accrual
  --  19 NOV 2003 sclarke     3064179   Created
  --  04 DEC 2003 sclarke               Updates after testing
  --  30 DEC 2003 sclarke               Changed parameters to annual_leave_calc_1
  --  08 JAN 2004 sclarke               Removed tables of records
  --  28 JAN 2004 sclarke     3392071   changed get_accrual_entitlement logic regarding
  --                                    adjustment elements
  --  11 FEB 2004 sclarke     3435633   get_working_days_balance cursor changed
  --                                    so that the max ass action fetches
  --                                    the currently processing action
  --  12 FEB 2004 sclarke     3435633   Need to handle when viewing accruals
  --                                    for actual time worked and there are no runs
  --                                    in period.  Better error handling required.
  --  12 Mar 2004 sclarke     3547116   Recurring absences
  --  02 APR 2004 sclarke     3541500   Anniversary Date is not moved the initial 7 days
  --  15 APR 2004 sclarke     3541500   Do not accrue leave on the initial 7 days
  --  11 MAY 2004 puchil      3592923   Performance fix for cursor csr_ass_action.
  --                          3620398   1) Changed function get_working_days_balance
  --                                    2) Added return statement to function get_previous_rate
  --  13 MAY 2004 statkar     3620398   Reverted back the changes to
  --                                    csr_ass_action done in the previous version
  --  21 MAY 2004 sclarke     3632528   added extra action_status to get_working_days_balance
  --  11 JUN 2004 puchil      3654766   Changed the cursor csr_get_rate to return the value
  --                                    based on the assignment_action_id.
  --  07 JUL 2004 puchil      3654766   Changed the cursor csr_get_rate to consider
  --                                    leaves spanning multiple pay periods.
  --  23 JUL 2004 bramajey    3608752   Added functions is_parental_leave_taken,get_entitled_amount
  --                                    ,get_recur_abs_prev_period and get_leave_taken
  --  17 AUG 2004 bramajey    3608752   Modified cursor csr_parental_leave_taken
  --                                    and csr_get_count_leave.
  --  05 AUG 2005 rpalli      4536217   As part of bug 4536217(performance issue):
  --					Added overloaded function determine_work_week.
  --					Added is_leap_year function.
  --                                    Removed eligible_for_accrual function.
  --				        Modified calculate_daily_accrual function.
  --				        Modified daily_accrual_loop function.
  --  02 SEP 2005 snekkala    4259438   Modified cursor csr_hire_date as Part of Performance
  --                                    Modified csr_ass_action in get_working_days_balance
  --                                    for performance
  --  21 JUL 2008 vamittal    7254820   Modified function annual_leave_rate_calc_2 and get_annual_leave_percentage.
  --  30-Jul-2008 avenkatk    7260523   Modified function annual_leave_rate_calc_1 - condition for months_between
  --  ------------------------------------------------------------------------------
  --
  g_package                 constant varchar2(60) := 'pay_nz_holidays_2003.';
  g_debug                   boolean;
  g_legislation_code        constant varchar2(3) := 'NZ';
  g_unpaid_absence_category     constant varchar2(4) := 'NZUL';
  --
  -- An absence is taken given a start and end date with the two days the given
  -- dates fall on being included in the absence taken.  Unpaid absences greater
  -- than 1 week move the anniversary date.  To determine the 1 weeks duration
  -- we are subtracting the start_date from the end_date of the absence and moving
  -- the anniversary when the difference is > than 6 days (Note, not 7 days).
  --
  g_unpaid_absence_days     constant number := 6;
  --
  type t_person_rec2 is record
  (person_id                number
  ,calculation_date         date
  ,anniversary_start_date   date
  ,anniversary_end_date     date
  ,years_of_service         number
  );
  type t_person_tab2 is table of t_person_rec2 index by binary_integer;

  p_anniversary_table2 t_person_tab2;
  --
  -- Cursor to retrieve days where the assignment
  -- is not active
  --
  cursor csr_inactive_days
  (p_assignment_id number
  ,p_period_sd     date
  ,p_period_ed     date
  ) is
  -- need to add 1 as to include the finale day
  -- e.g. 01-JAN-2000 minus 01-JAN-2000 is actually 1 day but the arithmetic returns 0
  select sum(asg.effective_end_date - asg.effective_start_date + 1) days_inactive
    from per_assignments_f asg
    ,    per_assignment_status_types ast
   where asg.assignment_id = p_assignment_id
     and ((asg.effective_start_date between p_period_sd and p_period_ed
         or asg.effective_end_date between p_period_sd and p_period_ed)
           or (p_period_sd between asg.effective_start_date and asg.effective_end_date))
     and asg.assignment_status_type_id = ast.assignment_status_type_id
     and ast.per_system_status <> 'ACTIVE_ASSIGN';
  --
  cursor csr_person_id
  (p_assignment_id number
  ,p_calculation_date date
  ) is
  select person_id
    from per_assignments_f
   where assignment_id = p_assignment_id
     and p_calculation_date between effective_start_date and effective_end_date;
  --
  -- Cursor to retrieve the input value of
  -- element entry for LEAVE_INFORMATION -> STANDARD WORK WEEK
  --
  cursor csr_work_week
  (p_assignment_id number
  ,p_effective_date date
  ) is
  select nvl(to_number(val.screen_entry_value),0)
  from   pay_element_entries_f      ent
  ,      pay_element_types_f        el
  ,      pay_input_values_f         piv
  ,      pay_element_entry_values_f val
  ,      pay_element_links_f        link
  where  ent.assignment_id    = p_assignment_id
  and    ent.element_entry_id = val.element_entry_id
  and    p_effective_date     between ent.effective_start_date and ent.effective_end_date
  and    ent.element_link_id  = link.element_link_id
  and    link.element_type_id = el.element_type_id
  and    el.element_name      = 'Leave Information'
  and    el.legislation_code  = g_legislation_code
  and    p_effective_date     between el.effective_start_date and el.effective_end_date
  and    el.element_type_id   = piv.element_type_id
  and    piv.name             = 'Standard Work Week'
  and    p_effective_date     between piv.effective_start_date and piv.effective_end_date
  and    val.input_value_id   = piv.input_value_id
  and    p_effective_date     between val.effective_start_date and val.effective_end_date;
  --
  -- Cursor to retrieve the input value of
  -- element entry for Leave Information -> USE ASSIGNMENT WORK HOURS
  --
  cursor csr_use_asg_hours
  (p_assignment_id number
  ,p_effective_date date
  ) is
  select nvl(val.screen_entry_value,'Y')
  from   pay_element_entries_f      ent
  ,      pay_element_types_f        el
  ,      pay_input_values_f         piv
  ,      pay_element_entry_values_f val
  ,      pay_element_links_f        link
  where  ent.assignment_id    = p_assignment_id
  and    ent.element_entry_id = val.element_entry_id
  and    p_effective_date     between ent.effective_start_date and ent.effective_end_date
  and    ent.element_link_id  = link.element_link_id
  and    link.element_type_id = el.element_type_id
  and    el.element_name      = 'Leave Information'
  and    el.legislation_code  = g_legislation_code
  and    p_effective_date     between el.effective_start_date and el.effective_end_date
  and    el.element_type_id   = piv.element_type_id
  and    piv.name             = 'Use Assignment Working Hours'
  and    p_effective_date     between piv.effective_start_date and piv.effective_end_date
  and    val.input_value_id   = piv.input_value_id
  and    p_effective_date     between val.effective_start_date and val.effective_end_date;

  --
  -- Comparison on dates uses the > 6
  -- as an alternative to => 7
  --
  cursor csr_get_unpaid_absences
  (p_person_id per_all_people_f.person_id%type
  ,p_start_date date
  ,p_end_date   date
  ) is
  select ab.absence_attendance_id
  ,      ab.person_id
  ,      ab.absence_days
  ,      ab.absence_hours
  ,      abt.hours_or_days
  ,      ab.date_start
  ,      ab.date_end
  ,      ((ab.date_end - ab.date_start) - g_unpaid_absence_days) add_days
  --     however, do not move the initial qualifying period
  from   per_absence_attendances        ab
  ,      per_absence_attendance_types   abt
  where  ab.absence_attendance_type_id  = abt.absence_attendance_type_id
    and  ab.person_id                   = p_person_id
    and  abt.absence_category           = g_unpaid_absence_category
    and  ab.date_start between p_start_date and p_end_date
    and  ((ab.date_end - ab.date_start) > g_unpaid_absence_days);
  --
  -----------------------------
  -- GET_ACCRUAL_PLAN_UOM
  -----------------------------
  function get_accrual_plan_uom
  (p_accrual_plan_id number
  ) return varchar2 is
    --
    l_uom varchar2(60);
    --
    cursor csr_get_uom
    (p_accrual_plan_id number
    ) is
    select accrual_units_of_measure
    from   pay_accrual_plans
    where  accrual_plan_id = p_accrual_plan_id;
    --
  begin
    open csr_get_uom(p_accrual_plan_id);
    fetch csr_get_uom into l_uom;
    close csr_get_uom;
    --
    return l_uom;
  end get_accrual_plan_uom;

  ---------------------------
  -- GET_WORKING_DAYS_BALANCE
  ---------------------------
  --
  function get_working_days_balance
  (p_assignment_id          in number
  ,p_effective_date         in date
  ) return number is

    l_balance_name          constant varchar2(100) := 'Days or Hours Worked';
    l_dimension_name        constant varchar2(100) := '_ASG_PTD';
    l_value                 number;
    l_defined_balance_id    number;
    l_procedure             constant varchar2(100) := g_package||'get_working_days_balance';

    cursor csr_def_bal
    (p_balance_name varchar2
    ,p_dimension_name varchar2
    )is
    select defined_balance_id
    from   pay_defined_balances     pdb
    ,      pay_balance_types        pbt
    ,      pay_balance_dimensions   dim
     where pdb.balance_type_id      = pbt.balance_type_id
       and pdb.balance_dimension_id = dim.balance_dimension_id
       and pbt.balance_name         = p_balance_name
       and dim.dimension_name       = p_dimension_name
       and dim.legislation_code     = g_legislation_code
       and pbt.legislation_code     = g_legislation_code;

    /* Bug 4259438 : Modified cursor as part of performance */
    CURSOR csr_ass_action
    (p_assignment_id  NUMBER
    ,p_effective_date DATE
    ) IS
        SELECT MAX(paa.assignment_action_id)
          FROM pay_assignment_actions paa
             , per_assignments_f      paf
             , pay_payrolls_f         ppf
             , pay_payroll_actions    ppa
             , per_time_periods       ptp
         WHERE paf.assignment_id = p_assignment_id
           AND ppa.action_type in ('R','Q')
           AND p_effective_date      BETWEEN paf.effective_start_date
	                                 AND paf.effective_end_date
           AND ppa.payroll_action_id = paa.payroll_action_id
           AND ppf.payroll_id        = paf.payroll_id
           AND ppa.time_period_id    = ptp.time_period_id
           AND ppf.payroll_id        = ppa.payroll_id
           AND ppa.effective_date    BETWEEN ptp.start_date
	                                 AND ptp.end_date
           AND p_effective_date      BETWEEN ptp.start_date
	                                 AND ptp.end_date
           AND ppf.payroll_id        = ppa.payroll_id
           AND ppf.payroll_id        = ptp.payroll_id
           AND paf.assignment_id     = paa.assignment_id
           AND paa.action_status     IN ('C','P','U')
           AND ppa.action_status     IN ('C','P','U')
      GROUP BY paa.assignment_action_id
        HAVING paa.assignment_action_id = MAX(paa.assignment_action_id);

    --
    l_assignment_action_id number;
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
    end if;
    --
    open csr_ass_action(p_assignment_id, p_effective_date);
    fetch csr_ass_action into l_assignment_action_id;
    close csr_ass_action;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 10);
      hr_utility.trace('l_assignment_action_id = *'||to_char(nvl(l_assignment_action_id,99))||'*');
    end if;
    --
    if l_assignment_action_id is null then
      hr_utility.set_message(801,'HR_NZ_WORKING_HRS_MISSING');
      hr_utility.raise_error;
    end if;
    --
    open csr_def_bal(l_balance_name, l_dimension_name);
    fetch csr_def_bal into l_defined_balance_id;
    if csr_def_bal%notfound then
      if g_debug then
        hr_utility.set_location(l_procedure, 7);
      end if;
      --
      l_value := 0;
    else
      --
      l_value := pay_balance_pkg.get_value
                (p_defined_balance_id =>l_defined_balance_id
                ,p_assignment_action_id => l_assignment_action_id
                );
    end if;
    close csr_def_bal;
      --
    --
    ----
    --l_value := pay_balance_pkg.get_value
    --(p_defined_balance_id => l_defined_balance_id
    --,p_assignment_id      => p_assignment_id
    --,p_virtual_date       => p_effective_date
    --);
    --
    if g_debug then
      hr_utility.set_location(l_procedure,999);
    end if;
    --
    return l_value;
  end get_working_days_balance;
  ---------------------------
  -- GET_BALANCE
  ---------------------------
  --
  function get_balance
  (p_assignment_id          in number
  ,p_effective_date         in date
  ,p_balance_name           varchar2
  ,p_dimension_name        varchar2
  ) return number is

    l_value                 number;
    l_defined_balance_id    number;
    l_procedure             constant varchar2(100) := g_package||'get_balance';

    cursor csr_def_bal
    (p_balance_name varchar2
    ,p_dimension_name varchar2
    )is
    select defined_balance_id
      from pay_defined_balances     pdb
    ,      pay_balance_types        pbt
    ,      pay_balance_dimensions   dim
     where pdb.balance_type_id      = pbt.balance_type_id
       and pdb.balance_dimension_id = dim.balance_dimension_id
       and pbt.balance_name         = p_balance_name
       and dim.dimension_name       = p_dimension_name
       and dim.legislation_code     = g_legislation_code
       and pbt.legislation_code     = g_legislation_code;
  begin
    --
    open csr_def_bal(p_balance_name, p_dimension_name);
    fetch csr_def_bal into l_defined_balance_id;
    close csr_def_bal;
    --
    l_value := nvl(pay_balance_pkg.get_value
    (p_defined_balance_id => l_defined_balance_id
    ,p_assignment_id      => p_assignment_id
    ,p_virtual_date       => p_effective_date
    ),0);
    --
    return l_value;
  end get_balance;
  --
  --------------------
  -- GET_STANDARD_WORK_WEEK
  --------------------
  --
  function get_standard_work_week
  (p_assignment_id      in number
  ,p_effective_date     in date
  ) return number is
    l_procedure constant varchar2(100) := g_package||'get_standard_week';
    l_standard_days_per_week number;
  begin
    --
    open csr_work_week(p_assignment_id, p_effective_date);
    fetch csr_work_week
    into  l_standard_days_per_week;
    if csr_work_week%notfound then
      l_standard_days_per_week := 0;
    end if;
    close csr_work_week;
    --
    return l_standard_days_per_week;
  end get_standard_work_week;
  --
  -------------------
  -- MOVE_ANNIVERSARY
  -------------------
  --
  function move_anniversary
  (p_person_id          number
  ,p_calculation_date   date
  ,p_start_date         in out nocopy date
  ,p_end_date           in out nocopy date
  ) return date is
    --
    g_absences_found boolean;
    l_tmp_anniversary_end_date date;
    l_procedure constant varchar2(60) := g_package||'move anniversary';
    l_date_moved boolean;
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --
    l_tmp_anniversary_end_date := p_end_date;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
    end if;
    --
    if g_debug then
      hr_utility.set_location('Entering '||l_procedure,1);
      hr_utility.set_location('p_start_date '||to_char(p_start_date,'DD-MON-YYYY'),1);
      hr_utility.set_location('p_end_date '||to_char(p_end_date,'DD-MON-YYYY'),1);
    end if;
    --
    -- Check for more absence unless we have gone beyond the calculation date
    while not l_tmp_anniversary_end_date > p_end_date
    loop
      if g_debug then
        hr_utility.set_location(l_procedure,2);
      end if;
      -- initialise variable to false before we actually check absences
      g_absences_found := false;
      --
      -- now check for absences
      for abs_rec in csr_get_unpaid_absences(p_person_id, p_start_date, p_end_date)
      loop
        -- add the number of days the absence was taken over
        g_absences_found := true;
        l_tmp_anniversary_end_date := l_tmp_anniversary_end_date + abs_rec.add_days;
      end loop;

      if g_absences_found then
        l_tmp_anniversary_end_date := move_anniversary(p_person_id, p_calculation_date, p_end_date, l_tmp_anniversary_end_date);
      else
        if g_debug then
          hr_utility.set_location('no absences',1);
        end if;
        --
        -- exit when absence not found
        exit;
      end if;
    end loop;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,999);
    end if;
    --
    return l_tmp_anniversary_end_date;
  end move_anniversary;
  --
  ---------------------------
  -- INITIALISE_ANNIVERSARIES
  ---------------------------
  -- Sets the first anniversary start date for an employee
  -- If p_service_date is not entered then the first anniversary start date
  -- will be set to the hire date of the employee...
  -- p_service_date is provided so continuous_service_date can be considered
  -- it is expected that this parameter has already been validated.
  --
  procedure initialise_dates
  (p_assignment_id          in number
  ,p_service_start_date     in out nocopy date
  ,p_anniversary_start_date out nocopy date
  ) is
    l_procedure constant varchar2(60) := g_package||'initialise_anniversaries';
    l_anniversary_start_date date;
    --
    -- Bug 4259438 : Modified the Select clause of the cursor as part of Performance
    --
    CURSOR csr_hire_date
    IS
      SELECT date_start
        FROM per_periods_of_service   pps
           , per_assignments_f        paf
       WHERE pps.period_of_service_id = paf.period_of_service_id
         AND pps.person_id            = paf.person_id
         AND paf.assignment_id        = p_assignment_id;
    --
    -- End Bug 4259438
    --
  begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('..p_assignment_id = '||to_char(nvl(p_assignment_id,0)));
      hr_utility.trace('..p_service_start_date = '||to_char(p_service_start_date,'DD/MM/RRRR'));
    end if;
    --
    -- If the service start date is entered
    -- then we assume validation of dates has
    -- already been done.
    --
    if p_service_start_date is null then
      --
      -- get hire_date and termination_date for future use
      open csr_hire_date;
      fetch csr_hire_date into l_anniversary_start_date;
      close csr_hire_date;
      --
      p_service_start_date := l_anniversary_start_date;
    else
      l_anniversary_start_date := p_service_start_date;
    end if;
    --
    p_anniversary_start_date := l_anniversary_start_date;
    --
    if g_debug then
      hr_utility.trace('..l_anniversary_start_date = '||to_char(l_anniversary_start_date,'DD/MM/RRRR'));
      hr_utility.set_location(l_procedure, 999);
    end if;
  end initialise_dates;
  --
  --------------------------
  -- CACE_ANNIVERSARY_DETAILS
  --------------------------
  --
  -- This function fetches anniversary dates
  -- for the lifetime of the employee up to the calculation date
  -- Since this function is for the accrual formula it is assumed
  -- the data passed in has already been validated so we do no
  -- validate again.
  --
  function cache_anniversary_details
  (p_payroll_id             in number
  ,p_assignment_id          in number
  ,p_accrual_plan_id        in number
  ,p_calculation_date       in date
  ,p_service_start_date     in date
  ,p_anniversary_start_date out nocopy date
  ,p_anniversary_end_date   out nocopy date
  ,p_years_of_service       out nocopy number
  ) return number is
    l_procedure                 constant varchar2(60) := g_package||'cache_anniversary_details';
    l_person_counter            integer;
    l_counter                   integer;
    l_anniversary_start_date    date;
    l_anniversary_end_date      date;
    l_years_of_service          number;
    l_person_id                 number;
    l_date_start                date;
    l_cached                    boolean;
    l_anniversary_not_found     boolean;
    l_actual_termination_date   date;
    l_calculation_date          date;
    l_service_start_date        date;
  begin
    l_person_counter := 1;
    l_counter := 1;
    l_years_of_service := 0;
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
    end if;
    --
    open csr_person_id(p_assignment_id, p_calculation_date);
    fetch csr_person_id into l_person_id;
    close csr_person_id;
    --
    if g_debug then
      hr_utility.trace('l_person_id.=.'||to_char(l_person_id));
    end if;
    --
    -- Has the information been cached?
    -- Note: Anniversaries apply to the person... not each assignment
    --
    if (p_anniversary_table2.count > 0) then
      for x in 1..p_anniversary_table2.count loop
        if (p_anniversary_table2(x).person_id = l_person_id)
           and
           (p_anniversary_table2(x).calculation_date = p_calculation_date) then
          l_cached := true;
        else
          l_cached := false;
        end if;
      end loop;
    else
      l_cached := false;
    end if;
    --
    if not l_cached then
      --
      -- Anniversaries have not yet been cached
      --
      if g_debug then
        hr_utility.set_location(l_procedure, 30);
      end if;
      --
      -- Initialise the first anniversary
      -- and start from there.
      --
      initialise_dates
      (p_assignment_id          => p_assignment_id
      ,p_service_start_date     => l_service_start_date
      ,p_anniversary_start_date => l_anniversary_start_date
      );
      l_anniversary_end_date    := l_anniversary_start_date;
      --
      if g_debug then
        hr_utility.set_location(l_procedure, 40);
        hr_utility.trace('l_anniversary_start_date..=.'||to_char(l_anniversary_start_date));
        hr_utility.trace('p_calculation_date........=.'||to_char(p_calculation_date));
      end if;
      --
      -- Initialise Person Table
      --
      if p_anniversary_table2.exists(1) then
        --
        -- Some records exist... we have already confirmed
        -- that one does not exist for this person above
        -- so set the person counter index after the last
        --
        l_person_counter := p_anniversary_table2.last + 1;
        --
        if g_debug then
          hr_utility.set_location(l_procedure, 45);
        end if;
      end if;
      --
      --
      -- Start at l_anniversary_start and loop thru until the next anniversary is after calculation date
      --
      while (not l_anniversary_start_date > p_calculation_date) and (l_anniversary_end_date <= p_calculation_date)
      loop
        --
        -- Initialise Anniversary Table
        --
        -- Note, the anniversary dates cannot be on the same day
        -- Assuming no time off without pay, the anniversary end date
        -- will actually be 12mths - 1 day from the anniversary start date
        --
        p_anniversary_table2(l_person_counter).person_id        := l_person_id;
        p_anniversary_table2(l_person_counter).calculation_date := p_calculation_date;
        --
        if l_service_start_date = l_anniversary_end_date then
          p_anniversary_table2(l_person_counter).anniversary_start_date := l_anniversary_end_date;
          p_anniversary_table2(l_person_counter).anniversary_end_date := add_months(l_anniversary_end_date,12) - 1;
        else
          p_anniversary_table2(l_person_counter).anniversary_start_date := l_anniversary_end_date + 1;
          p_anniversary_table2(l_person_counter).anniversary_end_date := add_months(l_anniversary_end_date,12);
        end if;
        p_anniversary_table2(l_person_counter).years_of_service := l_years_of_service;
        --
        p_anniversary_table2(l_person_counter).anniversary_end_date :=
              move_anniversary
              (l_person_id
              , p_calculation_date
              , p_anniversary_table2(l_person_counter).anniversary_start_date
              , p_anniversary_table2(l_person_counter).anniversary_end_date
              );
        if g_debug then
          hr_utility.set_location(l_procedure, 50);
          hr_utility.trace('........................');
          hr_utility.trace('anniversary_start_date..=.'||to_char(p_anniversary_table2(l_person_counter).anniversary_start_date));
          hr_utility.trace('anniversary_end_date....=.'||to_char(p_anniversary_table2(l_person_counter).anniversary_end_date));
          hr_utility.trace('years_of_service........=.'||to_char(p_anniversary_table2(l_person_counter).years_of_service));
          hr_utility.trace('........................');
        end if;
        --
        -- Has the next anniversary been moved after the calculation date
        if l_anniversary_end_date > p_calculation_date then
          if g_debug then
            hr_utility.set_location(l_procedure, 60);
          end if;
           exit;
        end if;
        l_anniversary_start_date := p_anniversary_table2(l_person_counter).anniversary_start_date;
        l_anniversary_end_date   := p_anniversary_table2(l_person_counter).anniversary_end_date;
        --
        -- Years of service cannot equal to l_counter
        -- because it can be zero, whereas the index for a plsql table
        -- starts at 1
        --
        l_years_of_service := l_years_of_service + 1;
        --
        -- Increment table counter and initialise next anniversaries
        --
        l_counter := l_counter + 1;
        l_person_counter := l_person_counter + 1;
        --
        if g_debug then
          hr_utility.set_location(l_procedure, 70);
        end if;
        --
      end loop;
      p_anniversary_start_date    := l_anniversary_start_date;
      p_anniversary_end_date      := l_anniversary_end_date;
      --
      -- Years of service is zero until 1 complete year of employment is reached
      -- This being the case then because the table counter is initialised at 1
      -- we need to subtract 1 from the count to get the correct result...
      -- unless of course the counter is less than  1 (which can happen when the
      -- calculation date is on the service_start_date
      --
      if l_counter > 0 then
        p_years_of_service := l_counter - 1;
      else
        p_years_of_service := 0;
      end if;
      --
      l_cached := true;
    end if;
    --
    if l_cached then
      for x in 1..p_anniversary_table2.count loop
        if (p_anniversary_table2(x).person_id = l_person_id)
        then
          --
          -- Information has been cached
          -- so we retrieve it from the cache
          --
          if g_debug then
            hr_utility.set_location(l_procedure||' CACHE', 10);
          end if;
          --
          -- looking for where the calculation_date is between ann_start and ann_end
          -- for the given person
          --
          if ((p_calculation_date > p_anniversary_table2(x).anniversary_start_date)
             or(p_calculation_date = p_anniversary_table2(x).anniversary_start_date))
             and
             ((p_calculation_date < p_anniversary_table2(x).anniversary_end_date)
             or (p_calculation_date = p_anniversary_table2(x).anniversary_end_date))
          then
            if g_debug then
              hr_utility.set_location(l_procedure||' CACHE', 20);
            end if;
            p_anniversary_start_date := p_anniversary_table2(x).anniversary_start_date;
            p_anniversary_end_date   := p_anniversary_table2(x).anniversary_end_date;
            p_years_of_service       := p_anniversary_table2(x).years_of_service;
            if g_debug then
              hr_utility.set_location('p_anniversary_start_date = '||to_char(p_anniversary_start_date,'DD-MON-YYYY'), 20);
              hr_utility.set_location('p_anniversary_end_date.. = '||to_char(p_anniversary_end_date,'DD-MON-YYYY'), 20);
              hr_utility.set_location('p_years_of_service...... = '||to_char(p_years_of_service), 20);
            end if;
            --
            -- Exit loop so that the counter is not incremented
            --
            exit;
          end if; -- p_calculation_date
        end if;
      end loop;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,999);
    end if;
    --
    return 0;
    --
  end cache_anniversary_details;
  --
  --------------------------
  -- CALCULATE_DAILY_ACCRUAL
  --------------------------
  --
  function calculate_daily_accrual
  (p_person_id	        in number
  ,p_accrual_plan_id    in number
  ,p_start_date         in date
  ,p_end_date           in date
  ,p_annual_accrual     in number
  ,p_work_week          in number
  )
  return number is
    --
    l_days              number;
    l_daily_accrual     number;
    l_days_inactive     number;
    l_days_total        number;
    l_days_unpaid       number;
    l_procedure         constant varchar2(60) := g_package||'calculate_daily_accrual';
    --
  begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('p_start_date = '||to_char(p_start_date,'DD-MON-YYYY'));
      hr_utility.trace('p_end_date...= '||to_char(p_end_date,'DD-MON-YYYY'));
    end if;
    --
    -- 1.
    -- Get the number of days between start and end
    -- we include the end day which is why we add 1
    l_days := (p_end_date + 1) - p_start_date;
    --
    --
    -- 2.
    -- Get the number of days of unpaid absence where the total each seperate absence was > 1 week
    -- between these 2 dates
    l_days_unpaid := 0;
    --
    for abs_rec in csr_get_unpaid_absences(p_person_id, p_start_date, p_end_date)
    loop
      l_days_unpaid := l_days_unpaid + abs_rec.add_days;
    end loop;
    --
    -- total = 1-2
    l_days_total := l_days - l_days_unpaid;
    --
    -- The Annual Accrual is held in 'work weeks' therefore
    -- we need the multiplication by work week
    l_daily_accrual := (p_annual_accrual * p_work_week)/l_days_total;

    if g_debug then
      hr_utility.trace('l_days...........= '||to_char(l_days));
      hr_utility.trace('l_days_unpaid....= '||to_char(l_days_unpaid));
      hr_utility.trace('l_days_total.....= '||to_char(l_days_total));
      hr_utility.trace('l_daily_accrual..= '||to_char(l_daily_accrual));
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return l_daily_accrual;
    --
  end calculate_daily_accrual;
  --
  ----------------------
  -- DETERMINE_WORK_WEEK
  ----------------------
  --
  function determine_work_week
  (p_assignment_id      in number
  ,p_current_day        in date
  ,p_uom                in varchar2
  ,p_annual_accrual     in number
  ,p_chg_asg_hours      IN boolean
  ,p_asg_hours          IN number
  ,p_freq               IN varchar2
  ) return number is
    l_procedure             constant varchar2(60) := g_package||'determine_work_week';
    l_work_week             number;
    l_work_frequency        varchar2(30);
    l_use_asg_hours         varchar2(3);
    l_weeks_in_period       number;
    l_days_in_period        number;
    l_working_time          number;
    --
    cursor csr_asg_hours(p_effective_date date) is
    select normal_hours
    ,      frequency
      from per_assignments_f
     where assignment_id = p_assignment_id
       and p_effective_date between effective_start_date and effective_end_date;
    --
    cursor csr_get_days_in_period is
    select ptp.end_date - ptp.start_date days_in_period
    from   per_time_periods ptp
    ,      per_assignments_f paf
    where  paf.assignment_id = p_assignment_id
    and    p_current_day between paf.effective_start_date and paf.effective_end_date
    and    paf.payroll_id = ptp.payroll_id
    and    p_current_day between ptp.start_date and ptp.end_date;
    --
  begin
    l_use_asg_hours := 'N';
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('p_assignment_id = '||to_char(p_assignment_id));
      hr_utility.trace('p_current_day.. = '||to_char(p_current_day,'DD-MON-YYYY'));
    end if;
    --
    -- Check how to calculate accrual
    --
    open csr_use_asg_hours(p_assignment_id, p_current_day);
    fetch csr_use_asg_hours into l_use_asg_hours;
    close csr_use_asg_hours;
    --
    if g_debug then
      hr_utility.trace('l_use_asg_hours = '||l_use_asg_hours);
    end if;

    if l_use_asg_hours = 'Y' then
      --
      -- Get work week from ASG_HOURS on this current day
      -- because ASG_HOURS can be datetracked we need to check it
      -- each day
      --
   IF p_chg_asg_hours THEN
      l_work_week:=p_asg_hours;
      l_work_frequency:=p_freq;
   ELSE
      open csr_asg_hours(p_current_day);
      fetch csr_asg_hours into l_work_week, l_work_frequency;
      if csr_asg_hours%notfound then
        hr_utility.set_message(801,'HR_NZ_WORKING_HRS_MISSING');
        hr_utility.raise_error;
      end if;
      close csr_asg_hours;
   END IF;
      --
      -- ASG_FREQ must be Week
      --
      if l_work_frequency <> 'W' then
        hr_utility.set_message(801,'HR_NZ_BAD_WORKING_FREQ');
        hr_utility.raise_error;
      end if;
      --
      -- Validate date to use work week from ASG_HOURS
      -- Note: this can only be used to accrue in HOURS
      -- so we also check the UOM of the accrual plan
      -- matches this.
      --
      if ((l_work_week is not null) or (l_work_week = 0)) then
        if g_debug then
          hr_utility.set_location(l_procedure,20);
          hr_utility.trace('l_work_week comes from ASG_HOURS');
          hr_utility.trace('l_work_week = '||to_char(l_work_week));
          hr_utility.trace('p_uom.......= '||p_uom);
        end if;
        --
      else
        hr_utility.set_message(801,'HR_NZ_WORKING_HRS_MISSING');
        hr_utility.raise_error;
      end if;
      --
    else
      --
      --------------------------------------------
      -- Work week is not determined from ASG_HOURS
      --------------------------------------------
      --
      if g_debug then
        hr_utility.set_location(l_procedure,35);
      end if;
      --
      l_work_week := get_standard_work_week(p_assignment_id => p_assignment_id, p_effective_date => p_current_day);
      --
      -- If the 'Standard Work Week' is not available
      -- then we use the balance DAYS_OR_HOURS_WORKED
      --
      if (l_work_week is null) or (l_work_week = 0) then
        --
        open csr_get_days_in_period;
        fetch csr_get_days_in_period into l_days_in_period;
        close csr_get_days_in_period;
        --
        l_weeks_in_period := l_days_in_period / 7;

        l_working_time := get_working_days_balance
                        (p_assignment_id  => p_assignment_id
                        ,p_effective_date => p_current_day
                        );

        l_work_week := l_working_time / l_weeks_in_period;

        if g_debug then
          hr_utility.set_location(l_procedure,40);
          hr_utility.trace('..l_work_week comes from DAYS_OR_HOURS_WORKED');
          hr_utility.trace('..l_work_week = '||to_char(l_work_week));
          hr_utility.trace('..l_working_time = '||to_char(l_working_time));
          hr_utility.trace('..l_weeks_in_period = '||to_char(l_weeks_in_period));
          hr_utility.trace('..p_annual_accrual = '||to_char(p_annual_accrual));
          hr_utility.trace('..l_days_in_period = '||to_char(l_days_in_period));
        end if;

      end if;
      --
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return l_work_week;
  end determine_work_week;
  ---------------------------------------------------------------------
  -- is_leap_year function					     --
  -- function called in daily_accrual_loop function                  --
  -- This function finds whether 29-feb of leap year present between --
  -- the dates given					             --
  ---------------------------------------------------------------------
  function is_leap_year
    (p_start_date      in   date
    ,p_end_date        in   date)
     return number
     is

   l_date          date;
   l_year_date     date;
   l_curr_year     varchar2(4);
   l_mon           number;

begin

   l_mon :=to_char(p_start_date,'MM');

   IF l_mon<=2 THEN
      l_curr_year := to_char(p_start_date,'YYYY');
      l_year_date := p_start_date;
   ELSE
      l_curr_year := to_char(p_end_date,'YYYY');
      l_year_date := p_end_date;
   END IF;

    if ((to_number(l_curr_year)/4 = trunc( to_number(l_curr_year)/4))
        and not((to_number(l_curr_year)/100 = trunc(to_number(l_curr_year)/100))))
       or (to_number(l_curr_year)/400 = trunc(to_number(l_curr_year)/400) )
    then
         l_date := to_date('29-02'||to_char(l_year_date,'YYYY'),'DD-MM-YYYY');
            if l_date between p_start_date and p_end_date then
              return 1;
            else
              return 0;
            end if;
    else
          return 0;
    end if;

end is_leap_year;
  --
  --------------------------
  -- DETERMINE_WORK_WEEK_OLD
  --------------------------
  --
  function determine_work_week
  (p_assignment_id      in number
  ,p_current_day        in date
  ,p_uom                in varchar2
  ,p_annual_accrual     in number
  ) return number is
    l_procedure             constant varchar2(60) := g_package||'determine_work_week';
    l_work_week             number;
    l_work_frequency        varchar2(30);
    l_use_asg_hours         varchar2(3);
    l_weeks_in_period       number;
    l_days_in_period        number;
    l_working_time          number;
    --
    cursor csr_asg_hours(p_effective_date date) is
    select normal_hours
    ,      frequency
      from per_assignments_f
     where assignment_id = p_assignment_id
       and p_effective_date between effective_start_date and effective_end_date;
    --
    cursor csr_get_days_in_period is
    select ptp.end_date - ptp.start_date days_in_period
    from   per_time_periods ptp
    ,      per_assignments_f paf
    where  paf.assignment_id = p_assignment_id
    and    p_current_day between paf.effective_start_date and paf.effective_end_date
    and    paf.payroll_id = ptp.payroll_id
    and    p_current_day between ptp.start_date and ptp.end_date;
    --
  begin
    l_use_asg_hours := 'N';
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('p_assignment_id = '||to_char(p_assignment_id));
      hr_utility.trace('p_current_day.. = '||to_char(p_current_day,'DD-MON-YYYY'));
    end if;
    --
    -- Check how to calculate accrual
    --
    open csr_use_asg_hours(p_assignment_id, p_current_day);
    fetch csr_use_asg_hours into l_use_asg_hours;
    close csr_use_asg_hours;
    --
    if g_debug then
      hr_utility.trace('l_use_asg_hours = '||l_use_asg_hours);
    end if;

    if l_use_asg_hours = 'Y' then
      --
      -- Get work week from ASG_HOURS on this current day
      -- because ASG_HOURS can be datetracked we need to check it
      -- each day
      --
      open csr_asg_hours(p_current_day);
      fetch csr_asg_hours into l_work_week, l_work_frequency;
      if csr_asg_hours%notfound then
        hr_utility.set_message(801,'HR_NZ_WORKING_HRS_MISSING');
        hr_utility.raise_error;
      end if;
      close csr_asg_hours;
      --
      -- ASG_FREQ must be Week
      --
      if l_work_frequency <> 'W' then
        hr_utility.set_message(801,'HR_NZ_BAD_WORKING_FREQ');
        hr_utility.raise_error;
      end if;
      --
      -- Validate date to use work week from ASG_HOURS
      -- Note: this can only be used to accrue in HOURS
      -- so we also check the UOM of the accrual plan
      -- matches this.
      --
      if ((l_work_week is not null) or (l_work_week = 0)) then
        if g_debug then
          hr_utility.set_location(l_procedure,20);
          hr_utility.trace('l_work_week comes from ASG_HOURS');
          hr_utility.trace('l_work_week = '||to_char(l_work_week));
          hr_utility.trace('p_uom.......= '||p_uom);
        end if;
        --
      else
        hr_utility.set_message(801,'HR_NZ_WORKING_HRS_MISSING');
        hr_utility.raise_error;
      end if;
      --
    else
      --
      --------------------------------------------
      -- Work week is not determined from ASG_HOURS
      --------------------------------------------
      --
      if g_debug then
        hr_utility.set_location(l_procedure,35);
      end if;
      --
      l_work_week := get_standard_work_week(p_assignment_id => p_assignment_id, p_effective_date => p_current_day);
      --
      -- If the 'Standard Work Week' is not available
      -- then we use the balance DAYS_OR_HOURS_WORKED
      --
      if (l_work_week is null) or (l_work_week = 0) then
        --
        open csr_get_days_in_period;
        fetch csr_get_days_in_period into l_days_in_period;
        close csr_get_days_in_period;
        --
        l_weeks_in_period := l_days_in_period / 7;

        l_working_time := get_working_days_balance
                        (p_assignment_id  => p_assignment_id
                        ,p_effective_date => p_current_day
                        );

        l_work_week := l_working_time / l_weeks_in_period;

        if g_debug then
          hr_utility.set_location(l_procedure,40);
          hr_utility.trace('..l_work_week comes from DAYS_OR_HOURS_WORKED');
          hr_utility.trace('..l_work_week = '||to_char(l_work_week));
          hr_utility.trace('..l_working_time = '||to_char(l_working_time));
          hr_utility.trace('..l_weeks_in_period = '||to_char(l_weeks_in_period));
          hr_utility.trace('..p_annual_accrual = '||to_char(p_annual_accrual));
          hr_utility.trace('..l_days_in_period = '||to_char(l_days_in_period));
        end if;

      end if;
      --
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return l_work_week;
  end determine_work_week;
  --
  ---------------------
  -- DAILY_ACCRUAL_LOOP
  ---------------------
  --
  function daily_accrual_loop
  (p_payroll_id         in number
  ,p_assignment_id      in number
  ,p_accrual_plan_id    in number
  ,p_service_start_date in date
  ,p_start_date         in date
  ,p_end_date           in date
  )
  return number is
    l_procedure             constant varchar2(60) := g_package||'daily_accrual_loop';
    l_current_day           date;
    l_anniversary_start_date date;
    l_anniversary_end_date date;

    l_person_id		    number;
    l_years_of_service      number;
    l_prev_years_of_service number;
    l_tmp_number            number;
    l_period_accrual        number;
    l_asg_hours             number;
    l_annual_accrual        number;
    l_daily_accrual         number;
    l_work_week             number;
    l_temp_week             number;
    l_temp_accrual          number;
    l_uom                   varchar2(2);
    l_eligible_inactive     boolean;
    l_eligible_abs          boolean;
    l_chg_asg_hours         boolean;
    l_tmp_asg_hours         number;
    l_tmp_freq              varchar2(1);
    l_is_leap_year          number;
    l_temp_leap_year          number;


    type t_system_status is table of varchar2(30) index by binary_integer ;
    type t_eff_start_date  is table of date index by binary_integer ;
    type t_eff_end_date  is table of date index by binary_integer ;

    l_system_status t_system_status;
    l_eff_start_date t_eff_start_date;
    l_eff_end_date t_eff_end_date;

    type t_abs_start_date  is table of date index by binary_integer ;
    type t_abs_end_date  is table of date index by binary_integer ;

    l_abs_start_date t_abs_start_date;
    l_abs_end_date t_abs_end_date;

    type t_normal_hours is table of number index by binary_integer ;
    type t_frequency is table of varchar2(1) index by binary_integer ;
    type t_wrk_eff_start_date  is table of date index by binary_integer ;
    type t_wrk_eff_end_date  is table of date index by binary_integer ;

    l_normal_hours t_normal_hours;
    l_frequency t_frequency;
    l_wrk_eff_start_date t_wrk_eff_start_date;
    l_wrk_eff_end_date t_wrk_eff_end_date;

    --
    cursor csr_get_accrual_band
    (p_number_of_years number
    ,p_accrual_plan_id         number
    ) is
    select bnd.annual_rate                   annual_rate
    ,      acc.accrual_units_of_measure      uom
      from pay_accrual_bands bnd
      ,    pay_accrual_plans acc
     where p_number_of_years    >= bnd.lower_limit
       and p_number_of_years    <  bnd.upper_limit
       and bnd.accrual_plan_id  =  p_accrual_plan_id
       and bnd.accrual_plan_id  =  acc.accrual_plan_id;

  begin

    open csr_person_id(p_assignment_id, p_start_date);
    fetch csr_person_id into l_person_id;
    close csr_person_id;

    select ast.per_system_status,asg.EFFECTIVE_START_DATE,asg.EFFECTIVE_END_DATE
    bulk collect into l_system_status, l_eff_start_date, l_eff_end_date
    from per_assignments_f asg
        ,per_assignment_status_types ast
       where asg.assignment_id = p_assignment_id
             and asg.assignment_status_type_id = ast.assignment_status_type_id
             and ast.per_system_status <> 'ACTIVE_ASSIGN';

    select (ab.date_start + g_unpaid_absence_days + 1), ab.date_end
    bulk collect into l_abs_start_date, l_abs_end_date
    from   per_absence_attendances        ab
    ,      per_absence_attendance_types   abt
    where  ab.absence_attendance_type_id  = abt.absence_attendance_type_id
      and  ab.person_id                   = l_person_id
      and  abt.absence_category           = g_unpaid_absence_category
      and  ((ab.date_end - ab.date_start) > g_unpaid_absence_days);

    select normal_hours,frequency,effective_start_date,effective_end_date
    bulk collect into l_normal_hours,l_frequency,l_wrk_eff_start_date,l_wrk_eff_end_date
    from per_assignments_f
    where assignment_id = p_assignment_id;

    l_eligible_inactive:= true;
    l_eligible_abs:= true;
    l_chg_asg_hours:= false;

    l_years_of_service := 0;
    l_prev_years_of_service := -1;

    l_annual_accrual := 0;
    l_work_week := 0;
    l_period_accrual := 0;
    l_is_leap_year:=0;

    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.set_location('p_payroll_id......= '||to_char(p_payroll_id),1);
      hr_utility.set_location('p_assignment_id...= '||to_char(p_assignment_id),1);
      hr_utility.set_location('p_accrual_plan_id.= '||to_char(p_accrual_plan_id),1);
      hr_utility.set_location('p_start_date......= '||to_char(p_start_date,'DD-MON-YYYY'),1);
      hr_utility.set_location('p_end_date........= '||to_char(p_end_date,'DD-MON-YYYY'),1);
    end if;
    --l_period_accrual := 0;
    --
    -- Loop thru each day of the period given
    -- from first to last day of period
    --
    l_current_day := p_start_date;
    --
    loop
      exit when l_current_day > p_end_date;
      if g_debug then
        hr_utility.set_location(l_procedure,5);
        hr_utility.trace('l_current_day = '||to_char(l_current_day,'DD-MON-YYYY'));
      end if;
      --
      -- Is this day eligible to accrue Annual Leave
      --
      --
      -- Check if the present day is present in the inactive days periods
       if l_system_status.count>0 then
           for i in 1..l_system_status.count loop
                if l_current_day between  l_eff_start_date(i) and l_eff_end_date(i)
		then
                   l_eligible_inactive:= false;
  		   exit;
 		else
     		   l_eligible_inactive:= true;
                end if;
           end loop;
       end if;

       -- Check if the present day is present in the absences
       if l_abs_start_date.count>0 then
           for i in 1..l_abs_start_date.count loop
                if l_current_day between  l_abs_start_date(i) and l_abs_end_date(i)
		then
                   l_eligible_abs:= false;
		   exit;
 		else
     		   l_eligible_abs:= true;
                end if;
           end loop;
       end if;

      -- Check if assignment hours has changed
       if l_frequency.count>0 then
           for i in 1..l_frequency.count loop
                if l_current_day between l_wrk_eff_start_date(i) and l_wrk_eff_end_date(i)
		then
                   l_chg_asg_hours := true;
		   l_tmp_asg_hours := l_normal_hours(i);
		   l_tmp_freq      := l_frequency(i);
		   exit;
                end if;
           end loop;
       end if;

      if (l_eligible_inactive) and (l_eligible_abs)
      then
        --
        -- Set temporary holder for years of service
        -- so that we can check to see if it has changed
        -- from day to day... if it has not changed, this
        -- means that the accrual band cannot change and
        -- this can save us checking the accrual band
        -- for every day.
        --
        if l_prev_years_of_service <> -1 then
          l_prev_years_of_service := l_years_of_service;
        end if;
        --
        -- We only need to get the anniversary details
        -- once for each anniversary period
        -- So we only execute this code if anniversary has
        -- not been initialised or if the current processing
        -- day has advanced into the next anniversary period
        --
        if ((l_anniversary_start_date is null) or (l_current_day > l_anniversary_end_date)) then
          --
          -- Get the anniversary details for this day
          --
          l_tmp_number := cache_anniversary_details
                          (p_payroll_id             => p_payroll_id
                          ,p_assignment_id          => p_assignment_id
                          ,p_accrual_plan_id        => p_accrual_plan_id
                          ,p_calculation_date       => l_current_day
                          ,p_service_start_date     => p_service_start_date
                          ,p_anniversary_start_date => l_anniversary_start_date
                          ,p_anniversary_end_date   => l_anniversary_end_date
                          ,p_years_of_service       => l_years_of_service
                          );
          --
          if g_debug then
            hr_utility.set_location(l_procedure,10);
            hr_utility.trace('l_anniversary_start_date = '||to_char(l_anniversary_start_date,'DD-MON-YYYY'));
            hr_utility.trace('l_anniversary_end_date...= '||to_char(l_anniversary_end_date,'DD-MON-YYYY'));
          end if;
          --
        end if;
        --

        l_temp_accrual:=l_annual_accrual;

        if l_years_of_service <> l_prev_years_of_service then
          --
          -- Now get the accrual band for this day
          --
          if g_debug then
            hr_utility.set_location(l_procedure,23);
            hr_utility.trace('l_uom...... ='||l_uom);
          end if;
          --
          open csr_get_accrual_band(l_years_of_service, p_accrual_plan_id);
          fetch csr_get_accrual_band into l_annual_accrual, l_uom;
          close csr_get_accrual_band;
          --
        end if;
        --
        -- Get the work week
        --
	l_temp_week :=l_work_week;

        l_work_week := nvl(determine_work_week
                       (p_assignment_id    => p_assignment_id
                       ,p_current_day      => l_current_day
                       ,p_uom              => l_uom
                       ,p_annual_accrual   => l_annual_accrual
                       ,p_chg_asg_hours    => l_chg_asg_hours
                       ,p_asg_hours        => l_tmp_asg_hours
                       ,p_freq             => l_tmp_freq
                       ),0);
        --
        if g_debug then
          hr_utility.set_location(l_procedure,30);
          hr_utility.trace('l_work_week ='||to_char(l_work_week));
        end if;
        --
	l_temp_leap_year:=l_is_leap_year;
        l_is_leap_year:=is_leap_year(l_anniversary_start_date,l_anniversary_end_date);

	IF (l_temp_week <> l_work_week)	OR (l_temp_accrual<>l_annual_accrual)
	   OR (l_temp_leap_year <> l_is_leap_year)
	THEN
        l_daily_accrual := nvl(calculate_daily_accrual
                           (p_person_id              => l_person_id
                           ,p_accrual_plan_id        => p_accrual_plan_id
                           ,p_start_date             => l_anniversary_start_date
                           ,p_end_date               => l_anniversary_end_date
                           ,p_annual_accrual         => l_annual_accrual
                           ,p_work_week              => l_work_week
                           ),0);
        END IF;
        --
        l_period_accrual := l_period_accrual + l_daily_accrual;
        if g_debug then
          hr_utility.set_location(l_procedure,40);
          hr_utility.trace('...l_period_accrual = '||to_char(l_period_accrual));
        end if;
      end if;
      --
      l_current_day := l_current_day + 1;
    end loop;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return nvl(l_period_accrual,0);
    --
  end daily_accrual_loop;
  --
  ------------------------------
  -- GET_ANNUAL_LEAVE_PERCENTAGE
  ------------------------------
  --
  function get_annual_leave_percentage(p_accrual_plan_id number)
  return number is
    --
    cursor csr_percentage(p_accrual_plan_id number) is
    select fnd_number.canonical_to_number(information1)
      from pay_accrual_plans pap
     where information_category = 'NZ_NZAL'
       and pap.accrual_plan_id = p_accrual_plan_id;
    --
    l_percentage number;
    l_procedure  constant varchar2(60) := g_package||'get_annual_leave_percentage';
    --
  begin
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
    end if;
    --
    open csr_percentage(p_accrual_plan_id);
    fetch csr_percentage into l_percentage;
    if csr_percentage%notfound then
      l_percentage := 0;
    end if;
    close csr_percentage;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return l_percentage;
    --
  end get_annual_leave_percentage;
  --
  --
  -- Function used by formula function
  -- only required to save on duplication of code
  -- due to multiple calls.
  --
  --
  -- Ordinary rate has already been converted to appropriate UOM
  --
  function annual_leave_rate_calc_1
  (p_ordinary_rate              in number
  ,p_earnings_prev_12mths       in number
  ,p_earnings_td                in number
  ,p_time_worked_prev_12mths    in number
  ,p_time_worked_td             in number
  ,p_work_week                  in number
  ,p_hire_date                  in date
  ,p_period_start_date          in date
  ,p_period_end_date            in date
  )
  return number is
    l_rate number;
    l_procedure constant varchar2(60) := g_package||'annual_leave_rate_calc_1';
    l_average_weekly_rate number;
    --

  begin
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('...p_ordinary_rate = '||to_char(p_ordinary_rate));
      hr_utility.trace('...p_earnings_prev_12mths = '||to_char(p_earnings_prev_12mths));
      hr_utility.trace('...p_time_worked_prev_12mths = '||to_char(p_time_worked_prev_12mths));
      hr_utility.trace('...p_work_week = '||to_char(p_work_week));
      hr_utility.trace('...p_period_start_date = '||to_char(p_period_start_date,'DD/MM/RRRR'));
      hr_utility.trace('...p_period_end_date = '||to_char(p_period_end_date,'DD/MM/RRRR'));
      hr_utility.trace('...p_hire_date = '||to_char(p_hire_date,'DD/MM/RRRR'));
    end if;
    --
    -- Check to see if the Employees work period is more than 12 months
    --
    /* Bug 7260523 - Changed dates order for months_between condition */
    if months_between(p_period_end_date,p_hire_date) < 12 then
      if (p_hire_date = p_period_start_date or p_hire_date > p_period_start_date)
      and (p_hire_date = p_period_end_date or p_hire_date < p_period_end_date)
      then
        if g_debug then
          hr_utility.set_location(l_procedure, 20);
        end if;
        l_rate := greatest(p_ordinary_rate, p_earnings_td/p_time_worked_td);
      else
        if g_debug then
          hr_utility.set_location(l_procedure, 30);
        end if;
        l_rate := greatest(p_ordinary_rate, p_earnings_prev_12mths/p_time_worked_prev_12mths);
      end if;
    else
      --
      -- Calculate the rate per week
      --

      --
      -- Check to ensure we do not get divide by zero error
      --
      if p_time_worked_prev_12mths = 0 then
        l_rate := p_ordinary_rate;
      else
        l_average_weekly_rate := p_earnings_prev_12mths/52;
        l_rate := greatest(p_ordinary_rate, (l_average_weekly_rate / p_work_week));
        if g_debug then
          hr_utility.set_location(l_procedure, 40);
        end if;
      end if;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    return l_rate;
  end annual_leave_rate_calc_1;
  --
  -- Function used by formula function
  -- only required to save on duplication of code
  -- due to multiple calls.
  --
  function annual_leave_rate_calc_2
  (p_percentage            in number
  ,p_gross_earnings        in number
  ,p_advance_leave_earnings in number
  ) return number is
    l_rate number;
    l_procedure constant varchar2(60) := g_package||'annual_leave_rate_calc_2';
  begin
    l_rate := p_percentage * p_gross_earnings - p_advance_leave_earnings;   /*Bug 7254820 */
    return l_rate;
  end annual_leave_rate_calc_2;
  --
  -- PREVIOUS_PERIOD_END_DATE
  --
  function previous_period_end_date
  (p_payroll_id         in number
  ,p_time_period_id     in number
  ) return date is
    l_date          date;
    l_number            number;
    --
    cursor csr_get_payment_date is
    --select pptp.end_date
    select pptp.regular_payment_date
    from   per_time_periods bptp
    ,      per_time_periods pptp
    where  bptp.payroll_id      = p_payroll_id          -- identify driving period
    and    bptp.time_period_id  = p_time_period_id      -- identify driving period
    and    pptp.payroll_id      = p_payroll_id          -- match payroll
    and    bptp.start_date      = pptp.end_date + 1;    -- idenfity previous period
    --
  begin
    open csr_get_payment_date;
    fetch csr_get_payment_date into l_date;
    close csr_get_payment_date;
    --
    return l_date;
  end previous_period_end_date;
  --
  --
  --------------------------------------------------------------
  --
  --  get_accrual_entitlement
  --
  --  This function is required mainly by the NZ local library
  --  and will return the net accrual and net entitlement for a
  --  given person on a given day.
  --
  --  These values will be displayed in the forms PAYWSACV and
  --  PAYWSEAD.
  --
  --------------------------------------------------------------
  --
  FUNCTION get_accrual_entitlement
  (p_assignment_id        IN    NUMBER
  ,p_payroll_id           IN    NUMBER
  ,p_business_group_id    IN    NUMBER
  ,p_plan_id              IN    NUMBER
  ,p_calculation_date     IN    DATE
  ,p_net_accrual          OUT NOCOPY NUMBER
  ,p_net_entitlement      OUT NOCOPY NUMBER
  ,p_calc_start_date      OUT NOCOPY DATE
  ,p_last_accrual         OUT NOCOPY DATE
  ,p_next_period_end      OUT NOCOPY DATE
  ) RETURN NUMBER IS
    --  The stages of the calculation are as follows
    --
    --  1. Find the anniversary dates for the given calculation date
    --     using the get_carryover_values...this will allow us to
    --     obtain entitlement end date
    --
    --  2: Find net leave at entitlement end date using the core
    --     get_net_accrual Function.
    --
    --  3: Find the total net leave up to the calculation date using
    --     the core get_net_accrual function.
    --
    --  4: Find Leave Accrual Initialise during period
    --
    --  5: Find Leave Entitlement Initialise during period
    --
    --  6: Net entitlement = step 2 + step 5
    --
    --  7: Net accrual = (step 3 + step 5 - step 6)
    --
    l_procedure                     constant varchar2(72) := g_package||'.get_accrual_entitlement';
    l_adjustment_element            varchar2(100);
    l_initialise_element            varchar2(100);
    --
    l_anniversary_start_date        date;
    l_anniversary_end_date          date;
    l_start_date                    date;
    l_end_date                      date;
    l_accrual_end_date              date;
    l_entitlement_period_end_date   date;
    l_accrual_period_start_date     date;
    l_continuous_service_date       date;

    --
    l_co_formula_id                 number;
    l_max_co                        number;
    l_accrual_adj                   number;
    l_accrual_ent                   number;
    l_entitlement_adj               number;
    l_net_accrual                   number;
    l_net_entitlement               number;
    l_accrual                       number;
    l_leave_entitlement             number;
    l_leave_total                   number;
    l_others_entitlement            number;
    l_others_accrual                number;
    l_accrual_absences              number;
    l_leave_accrual                 number;
    --
    l_accrual_period_end_date date;
    l_calculation_date              date;
    --
    cursor c_get_co_formula
    (p_accrual_plan_id number) is
    select co_formula_id
    from   pay_accrual_plans
    where  accrual_plan_id = p_accrual_plan_id;
    --
  BEGIN
    --
    g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure, 0);
      hr_utility.trace('p_calculation_date = '||to_char(p_calculation_date,'DD-MON-YYYY'));
    end if;
    --
    l_calculation_date := p_calculation_date;
    --
    --  Step 1 Find entitlement end date
    --  first get the carryover formula then call it
    --  to get the prev and next anniversary dates.
    --  Entitlement end date and accrual end dates are
    --  actually the day before the anniversary dates.
    --
    open  c_get_co_formula (p_plan_id);
    fetch c_get_co_formula into l_co_formula_id;
    close c_get_co_formula;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 10);
    end if;
    --
    --------------------------------------------------------
    --
    -- GET ENTITLEMENT PERIOD DETAILS
    --
    --------------------------------------------------------
    -- The carryover formula's have been written to
    -- get the anniversary start and anniversary end dates
    -- for the anniversary period as of the calculation date
    -- when called in the mode NZ_FORM
    --------------------------------------------------------
    --

    per_accrual_calc_functions.get_carry_over_values
    (p_co_formula_id      =>   l_co_formula_id
    ,p_assignment_id      =>   p_assignment_id
    ,p_calculation_date   =>   l_calculation_date
    ,p_accrual_plan_id    =>   p_plan_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_accrual_term       =>   'NZ_FORM'
    ,p_effective_date     =>   l_anniversary_start_date      --l_accrual_period_start_date
    ,p_session_date       =>   l_calculation_date
    ,p_max_carry_over     =>   l_max_co
    ,p_expiry_date        =>   l_anniversary_end_date        --l_accrual_period_end_date
    );
    --
    -- The entitlement end date is the day before the start
    -- of the current anniversary period... unless the current anniversary
    -- period is the first anniversary period, in which case there will be
    -- no entitlement only accrual.
    --
    --  Before first anniversary date accrual_period_start_date = start_date
    --  in this case l_max_co will be set to 1 (for sick leave only)
    --
    l_accrual_period_start_date   := l_anniversary_start_date;
    l_accrual_period_end_date     := l_anniversary_end_date;
    --
    if l_max_co = 1 then
      l_entitlement_period_end_date := l_accrual_period_start_date;
    else
      l_entitlement_period_end_date := (l_accrual_period_start_date - 1);
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,5);
      hr_utility.trace('l_entitlement_period_end_date = '||to_char(l_entitlement_period_end_date,'DD-MON-YYYY'));
      hr_utility.trace('l_accrual_period_start_date.. = '||to_char(l_accrual_period_start_date,'DD-MON-YYYY'));
      hr_utility.trace('l_accrual_period_endt_date... = '||to_char(l_accrual_period_end_date,'DD-MON-YYYY'));
      hr_utility.trace('l_continuous_service_date.... = '||to_char(l_continuous_service_date,'DD-MON-YYYY'));
    end if;
    --
    -------------------------------------------------------
    --
    -- GET THE NET LEAVE AMOUNT FOR THE ENTITLEMENT PERIOD
    --
    -------------------------------------------------------
    --  Step two find the Net leave at entitlement end date

    -- Get the amount of leave which goes toward ENTITLEMENT
    -- Sum from start of plan until day before start of
    -- current anniversary period
    --
    -------------------------------------------------------
    --

    per_accrual_calc_functions.get_net_accrual
    (p_assignment_id      =>   p_assignment_id
    ,p_plan_id            =>   p_plan_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_calculation_date   =>   l_entitlement_period_end_date
    ,p_start_date         =>   l_start_date
    ,p_end_date           =>   l_end_date
    ,p_accrual_end_date   =>   l_accrual_end_date
    ,p_accrual            =>   l_accrual
    ,p_net_entitlement    =>   l_leave_entitlement
    );
    --
    -- Net Entitlement is not used because the net calculation
    -- of leave is done manually to allow for absences to be taken
    -- from entitlement before accrual
    --
    l_leave_entitlement := l_accrual;
    --
    l_others_entitlement := per_accrual_calc_functions.get_other_net_contribution
            (p_assignment_id     => p_assignment_id
            ,p_plan_id           => p_plan_id
            ,p_start_date        => l_start_date
            ,p_calculation_date  => l_entitlement_period_end_date
            ) ;

    --
    -------------------------------------------------------
    --
    -- GET THE NET LEAVE TOTAL
    --
    -------------------------------------------------------
    --  Find the Net leave at the calculation_date
    -------------------------------------------------------
    --
    per_accrual_calc_functions.get_net_accrual
    (p_assignment_id      =>   p_assignment_id
    ,p_plan_id            =>   p_plan_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_calculation_date   =>   l_calculation_date
    ,p_start_date         =>   l_start_date
    ,p_end_date           =>   l_end_date
    ,p_accrual_end_date   =>   l_accrual_end_date
    ,p_accrual            =>   l_accrual
    ,p_net_entitlement    =>   l_leave_total
    );
    --
    -- Net Entitlement is not used because the net calculation
    -- of leave is done manually to allow for absences to be taken
    -- from entitlement before accrual
    --
    l_leave_total := l_accrual;
    --
    ------------------------------------------------
    --
    -- GET THE ADJUSTMENT VALUES FOR ENTITLEMENT
    -- We search the entrie accrual period
    -- for entitlement adjustments since entitlement
    -- is always entitlement.
    -- Note: also if the accruals are being run
    -- before the entitlement period is reached
    -- then the function get_net_accrual does not
    -- return a start and end date.
    --
    ------------------------------------------------
    --
    -- We search the entire date range since entitlement
    -- adjustments are always entitlement
    --
    l_adjustment_element:= 'Entitlement Adjustment Element';
    l_entitlement_adj:= hr_nz_holidays.get_adjustment_values
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => p_plan_id
                        ,p_calc_end_date       => l_calculation_date
                        ,p_adjustment_element  => l_adjustment_element
                        ,p_start_date          => l_start_date
                        ,p_end_date            => l_end_date
                        );
    if g_debug then
      hr_utility.set_location(l_procedure, 40);
      hr_utility.trace('l_start_date = '||to_char(l_start_date));
      hr_utility.trace('l_end_date = '||to_char(l_end_date));
      hr_utility.trace('l_calculation_date = '||to_char(l_calculation_date));
      hr_utility.trace('l_entitlement_adj = '||to_char(l_entitlement_adj));
    end if;
    --

    ------------------------------------------------
    --
    -- GET THE ADJUSTMENT VALUES FOR ACCRUAL
    --
    ------------------------------------------------
    --
    -- We need to check for adjustments within
    -- the accrual period (ie accrual_period_start_date until calculation_date
    -- and the entitlement period (ie start_date until entitlement_period_end_date)
    --
    l_adjustment_element := 'Accrual Adjustment Element';
    l_accrual_adj:= hr_nz_holidays.get_adjustment_values
                    (p_assignment_id       => p_assignment_id
                    ,p_accrual_plan_id     => p_plan_id
                    ,p_calc_end_date       => l_calculation_date
                    ,p_adjustment_element  => l_adjustment_element
                    ,p_start_date          => l_entitlement_period_end_date
                    ,p_end_date            => l_calculation_date
                    );
    if g_debug then
      hr_utility.set_location(l_procedure, 50);
      hr_utility.trace('l_accrual_adj = '||to_char(l_accrual_adj));
    end if;

    --
    -- Accrual Adjustments which occured during the
    -- entitlement period become entitlement
    -- Add to the existing entitlement adjustments
    --
    l_accrual_ent := hr_nz_holidays.get_adjustment_values
                    (p_assignment_id       => p_assignment_id
                    ,p_accrual_plan_id     => p_plan_id
                    ,p_calc_end_date       => l_calculation_date
                    ,p_adjustment_element  => l_adjustment_element
                    ,p_start_date          => l_start_date
                    ,p_end_date            => l_end_date
                    );
    --
    if g_debug then
      hr_utility.trace('l_entitlement_adj = '||to_char(l_entitlement_adj));
      hr_utility.trace('l_accrual_adj.... = '||to_char(l_accrual_adj));
    end if;
    l_others_accrual := per_accrual_calc_functions.get_other_net_contribution
            (p_assignment_id     => p_assignment_id
            ,p_plan_id           => p_plan_id
            ,p_start_date        => l_accrual_period_start_date
            ,p_calculation_date  => p_calculation_date
            ) ;
    --
    --  Find out the numder of hours taken during the accrual period
    --  If max_co  is 1 then no accrual only entitlement
    --
    if l_max_co = 1
    then
      l_accrual_absences := per_accrual_calc_functions.get_absence
                            (p_assignment_id    => p_assignment_id
                            ,p_plan_id          => p_plan_id
                            ,p_start_date       => l_accrual_period_start_date
                            ,p_calculation_date => p_calculation_date
                            );
      if g_debug then
        hr_utility.set_location(l_procedure, 60);
        hr_utility.trace('..l_accrual_absences = '||to_char(l_accrual_absences));
        hr_utility.trace('..l_start_date = '||to_char(l_start_date,'dd/mm/rrrr'));
        hr_utility.trace('..l_calculation_date = '||to_char(l_calculation_date,'dd/mm/rrrr'));
      end if;
      l_leave_entitlement := l_leave_total - l_accrual_absences;
      l_leave_accrual     := 0;
      --
    else
      l_accrual_absences := per_accrual_calc_functions.get_absence
                          (p_assignment_id       => p_assignment_id
                          ,p_plan_id             => p_plan_id
                          ,p_start_date          => l_start_date
                          ,p_calculation_date    => p_calculation_date
                          );
      if g_debug then
        hr_utility.set_location(l_procedure, 70);
        hr_utility.trace('..l_start_date = '||to_char(l_start_date,'dd/mm/rrrr'));
        hr_utility.trace('..l_calculation_date = '||to_char(l_calculation_date,'dd/mm/rrrr'));
        hr_utility.trace('..l_accrual_absences = '||to_char(l_accrual_absences));
      end if;
      --
      -- Get the net entitlement and accrual before checking for absences
      -- Determine the amount to go towards accrual portion by subtracting
      -- entitlement portion from total
      --
      if g_debug then
        hr_utility.set_location(l_procedure, 75);
        hr_utility.trace('l_leave_total = '||to_char(l_leave_total));
        hr_utility.trace('l_leave_entitlement = '||to_char(l_leave_entitlement));
      end if;

      l_leave_accrual := l_leave_total - l_leave_entitlement;
      --
      l_leave_accrual := l_leave_accrual + l_others_accrual + l_accrual_adj;

      -- First year is accrual, not entitlement l_accrual_adj is subtracted.
      -- As l_accrual_adj returns value only in the first anniversary year,
      -- l_accrual_adj and l_accrual_ent is nullified in the first year and from
      -- second year onwards adjusted accrual value is added to the entitlement

      l_leave_entitlement := l_leave_entitlement + l_others_entitlement + l_entitlement_adj + l_accrual_ent - l_accrual_adj;
      if g_debug then
        hr_utility.set_location(l_procedure, 80);
        hr_utility.trace('..l_leave_entitlement = '||to_char(l_leave_entitlement));
        hr_utility.trace('..l_others_entitlement = '||to_char(l_others_entitlement));
        hr_utility.trace('..l_entitlement_adj = '||to_char(l_entitlement_adj));
        hr_utility.trace('..l_accrual_ent = '||to_char(l_accrual_ent));
        hr_utility.trace('..l_accrual_adj = '||to_char(l_accrual_adj));
        hr_utility.trace('..l_leave_accrual = '||to_char(l_leave_accrual));
      end if;

      -- have to subtract absences taken to calculate net entitlement
      -- absences must come off entitlement before accrual
      --
      if l_leave_entitlement > l_accrual_absences
      then
        l_leave_entitlement := l_leave_entitlement - l_accrual_absences;
      else
        -- Subtract from entitlement and leftovers from accrual
        l_leave_accrual := l_leave_accrual - (l_accrual_absences - l_leave_entitlement);
        l_leave_entitlement := 0;
      end if;

    end if;

    --
    --  set up return values
    --
    p_net_accrual        := round(nvl(l_leave_accrual,     0), 3);
    p_net_entitlement    := round(nvl(l_leave_entitlement, 0), 3);
    p_calc_start_date    := l_start_date;
    p_last_accrual       := l_accrual_end_date;
    p_next_period_end    := l_accrual_period_end_date;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,999);
    end if;
    --
    RETURN (0);
    --
  END get_accrual_entitlement;
  --
  ---------------------------------------------------------------------
  --
  --  ANNUAL_LEAVE_NET_ENTITLEMENT
  --
  --  Purpose : Wraps get_accrual_entitlement with parameters
  --            to match the Leave liability process.
  --  Returns : Total entitlement
  --
  ---------------------------------------------------------------------

  PROCEDURE annual_leave_net_entitlement
  (p_assignment_id                  IN  NUMBER
  ,p_payroll_id                     IN  NUMBER
  ,p_business_group_id              IN  NUMBER
  ,p_plan_id                        IN  NUMBER
  ,p_calculation_date               IN  DATE
  ,p_start_date                     OUT NOCOPY DATE
  ,p_end_date                       OUT NOCOPY DATE
  ,p_net_entitlement                OUT NOCOPY NUMBER
  ) IS
    --
    -- Local Variables
    --
    l_proc                          CONSTANT VARCHAR2(72) := g_package||'annual_leave_net_entitlement';
    l_net_accrual                   NUMBER;
    l_net_entitlement               NUMBER;
    l_calc_start_date               DATE;
    l_last_accrual                  DATE;
    l_next_period_end               DATE;
    l_dummy_number                  NUMBER;
    --
  BEGIN
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
      hr_utility.trace(' In: ' || l_proc) ;
    end if;
    --
    l_dummy_number := get_accrual_entitlement
                    (p_assignment_id
                    ,p_payroll_id
                    ,p_business_group_id
                    ,p_plan_id
                    ,p_calculation_date
                    ,l_net_accrual
                    ,l_net_entitlement
                    ,l_calc_start_date
                    ,l_last_accrual
                    ,l_next_period_end
                    );
    --
    p_net_entitlement := l_net_entitlement;
    p_start_date      := l_calc_start_date;
    p_end_date        := p_calculation_date;
    if g_debug then
      hr_utility.trace('Out: ' || l_proc);
    end if;

  END annual_leave_net_entitlement;
  --

  function get_previous_rate
  (p_element_type_id number
  ,p_assignment_action_id number
  ,p_rate_name varchar2
  ) return number is
    --
    l_procedure constant varchar2(72) := g_package||'get_previous_rate';
    --
    /*Bug 3654766 - Changed the cursor to improve performance and also
                    to consider the assignment action id into account.*/
    cursor csr_get_rate is
    select to_number(result.result_value)
      from pay_run_results runs
         , pay_input_values_f input
         , pay_run_result_values result
         , pay_assignment_actions paa
         , pay_assignment_actions cur_paa
         , pay_payroll_actions cur_ppa
         , pay_element_entries_f entry
         , per_time_periods ptp
     where runs.element_type_id = p_element_type_id
       and input.element_type_id = runs.element_type_id
       and input.name = p_rate_name
       and result.run_result_id = runs.run_result_id
       and result.input_value_id = input.input_value_id
       and cur_paa.assignment_action_id = p_assignment_action_id
       and cur_ppa.payroll_action_id = cur_paa.payroll_action_id
       and paa.assignment_action_id = runs.assignment_action_id
       and paa.assignment_id = cur_paa.assignment_id
       and entry.assignment_id = cur_paa.assignment_id
       and entry.element_entry_id = runs.source_id
       and ptp.time_period_id = cur_ppa.time_period_id
       and cur_ppa.effective_date between input.effective_start_date
                                  and input.effective_end_date
       and (ptp.start_date between entry.effective_start_date
                               and entry.effective_end_date
       or  ptp.end_date between entry.effective_start_date
                            and entry.effective_end_date);

    l_previous_rate number;
    --
  begin
    --
    g_debug := hr_utility.debug_enabled;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 0) ;
    end if;
    --
    open csr_get_rate;
    fetch csr_get_rate into l_previous_rate;
    if csr_get_rate%notfound then
      l_previous_rate := 0;
    end if;
    close csr_get_rate;
    --
    if g_debug then
      hr_utility.trace('l_previous_rate = '||to_char(l_previous_rate));
      hr_utility.set_location(l_procedure, 999);
    end if;
    --
    --Bug 3620398: Changed the function to return l_previous_rate.
    --
    return l_previous_rate;
    --
  end get_previous_rate;
  --

 -- Bug 3608752
 -- Parental leave changes
 FUNCTION is_parental_leave_taken(
                                   p_assignment_id      IN NUMBER
                                  ,p_business_group_id  IN NUMBER
                                  ,p_start_date         IN DATE
                                  ,p_end_date           IN DATE
                                  )
  RETURN NUMBER
  IS
  --
    CURSOR csr_parental_leave_taken(c_assignment_id     IN NUMBER
                                   ,c_business_group_id IN NUMBER
                                   ,c_start_date        IN DATE
                                   ,c_end_date          IN DATE)
    IS
    --
      SELECT 1
      FROM   per_absence_attendances          paa
            ,per_absence_attendance_types     paat
            ,per_assignments_f                paf
      WHERE  paa.person_id                  = paf.person_id
      AND    paf.assignment_id              = p_assignment_id
      AND    paa.business_group_id          = c_business_group_id
      AND    paa.business_group_id          = paat.business_group_id
      AND    paa.absence_attendance_type_id = paat.absence_attendance_type_id
      AND    paat.absence_category          = 'NZPL'
      AND    (paa.date_start                BETWEEN c_start_date
                                            AND     c_end_date
      OR     paa.date_end                   BETWEEN c_start_date
                                            AND     c_end_date )
      AND    c_end_date                     BETWEEN paf.effective_start_date
                                            AND     paf.effective_end_date;
    --
    l_pleave_taken  NUMBER;
    l_procedure     CONSTANT VARCHAR2(100) := g_package||'.is_parental_leave_taken';
  --
  BEGIN
  --
    l_pleave_taken  := 0;
    hr_utility.set_location('NZ   Entering            : ' || l_procedure,10);
    hr_utility.set_location('NZ   p_assignment_id     : ' || to_char(p_assignment_id),10) ;
    hr_utility.set_location('NZ   p_business_group_id : ' || to_char(p_business_group_id),10);
    hr_utility.set_location('NZ   p_start_date        : ' || to_char(p_start_date,'dd Mon yyyy'),10) ;
    hr_utility.set_location('NZ   p_end_date          : ' || to_char(p_end_date,'dd Mon yyyy'),10) ;

    OPEN csr_parental_leave_taken(p_assignment_id
                                 ,p_business_group_id
                                 ,p_start_date
                                 ,p_end_date);
    FETCH csr_parental_leave_taken
      INTO l_pleave_taken;

    IF csr_parental_leave_taken%FOUND THEN
    --
      CLOSE csr_parental_leave_taken;
      hr_utility.set_location('NZ  l_pleave_taken     : ' || to_char(l_pleave_taken),20);
      hr_utility.set_location('NZ  Leaving            : ' || l_procedure,20);
      RETURN 1;
    --
    END IF;
    --
    CLOSE csr_parental_leave_taken;
    hr_utility.set_location('NZ  No parental leave taken',30);
    hr_utility.set_location('NZ  Leaving            : ' || l_procedure,30);
    RETURN 0;
  --
  EXCEPTION
  --
    WHEN others THEN
    --
      IF csr_parental_leave_taken%ISOPEN THEN
      --
        CLOSE csr_parental_leave_taken;
      --
      END IF;
      hr_utility.set_location('NZ  Error in            : ' || l_procedure,40);
      RAISE;
    --
  --
  END is_parental_leave_taken;

  FUNCTION  get_recur_abs_prev_period(
                                      p_assignment_id        IN NUMBER
                                     ,p_payroll_id           IN NUMBER
                                     ,p_absence_start_date   IN DATE
                                     ,p_curr_aniv_start      IN DATE
                                     ,p_prev_period_end_date IN DATE
                                     ,p_plan_id              IN NUMBER
                                     )
  RETURN NUMBER
  IS
  --
    CURSOR get_pay_period_details(c_eff_date IN DATE) IS
    --
      SELECT ptp.time_period_id
            ,ptp.end_date
      FROM   per_time_periods ptp
      WHERE  ptp.payroll_id         = p_payroll_id
      AND    c_eff_date             BETWEEN ptp.start_date
                                    AND     ptp.end_date;
    --

    CURSOR get_period_assg_act_id(c_time_period_id IN NUMBER)
    IS
    --
      SELECT max(paa.assignment_action_id)
      FROM   pay_payroll_actions    ppa
            ,pay_assignment_actions paa
      WHERE  ppa.payroll_id         = p_payroll_id
      AND    ppa.time_period_id     = c_time_period_id
      AND    ppa.action_type        IN ('R','Q')
      AND    ppa.action_status      = 'C'
      AND    ppa.payroll_action_id  = paa.payroll_action_id
      AND    paa.assignment_id      = p_assignment_id
      AND    paa.action_status      = 'C';
    --

    CURSOR   csr_get_recurr_absence(c_assignment_action_id IN NUMBER
                                   ,c_prev_period_end_date IN DATE)
    IS
    --
      SELECT to_number(nvl(prrv.result_value,0))
      FROM   pay_run_result_values       prrv
            ,pay_run_results             prr
            ,pay_element_types_f         alp_pet
            ,pay_input_values_f          alp_piv
            ,pay_element_entries_f       pee
            ,pay_element_links_f         pel
            ,pay_element_types_f         abs_pet
            ,pay_input_values_f          abs_piv
            ,pay_accrual_plans           pap
      WHERE  prr.run_result_id        =  prrv.run_result_id
      AND    prr.assignment_action_id =  c_assignment_action_id
      AND    prr.element_type_id      =  alp_pet.element_type_id
      AND    alp_pet.element_name     = 'Annual Leave Payment'
      AND    alp_pet.element_type_id  =  alp_piv.element_type_id
      AND    alp_piv.name             = 'Leave Taken'
      AND    alp_piv.input_value_id   =  prrv.input_value_id
      AND    prr.source_id            =  pee.element_entry_id
      AND    pee.creator_type         = 'A'
      AND    pee.effective_end_date   >  c_prev_period_end_date
      AND    pee.element_link_id      =  pel.element_link_id
      AND    pel.element_type_id      =  abs_pet.element_type_id
      AND    abs_pet.processing_type  = 'R'
      AND    abs_pet.element_type_id  = abs_piv.element_type_id
      AND    abs_piv.input_value_id   = pap.pto_input_value_id
      AND    pap.accrual_plan_id      = p_plan_id
      AND    c_prev_period_end_date   BETWEEN alp_pet.effective_start_date
                                      AND     alp_pet.effective_end_date
      AND    c_prev_period_end_date   BETWEEN alp_piv.effective_start_date
                                      AND     alp_piv.effective_end_date
      AND    c_prev_period_end_date   BETWEEN pel.effective_start_date
                                      AND     pel.effective_end_date
      AND    c_prev_period_end_date   BETWEEN abs_pet.effective_start_date
                                      AND     abs_pet.effective_end_date
      AND    c_prev_period_end_date   BETWEEN abs_piv.effective_start_date
                                      AND     abs_piv.effective_end_date;
    --
    l_eff_date           DATE;
    l_recurr_leave_taken NUMBER;
    l_leave_taken        NUMBER;
    l_period_assg_act_id NUMBER;
    l_time_period_id     NUMBER;
    l_period_end_date    DATE;
    l_procedure          CONSTANT VARCHAR2(100) := g_package||'.get_recur_abs_prev_period';
  --
  BEGIN
  --
    hr_utility.set_location('NZ Entering              : ' ||l_procedure,10 );
    hr_utility.set_location('NZ p_absence_start_date  : ' ||p_absence_start_date,10 );
    hr_utility.set_location('NZ p_curr_aniv_start     : ' ||p_curr_aniv_start ,10 );
    hr_utility.set_location('NZ p_prev_period_end_date: ' ||p_prev_period_end_date ,10);
    hr_utility.set_location('NZ p_plan_id             : ' ||p_plan_id ,10);
    l_recurr_leave_taken := 0;
    IF (p_curr_aniv_start <= p_absence_start_date  ) THEN
    --
      -- Loop through starting from the absence start date
      -- Till Previous period end date to find the recurring
      -- absence processed in the previous runs
      l_eff_date := p_absence_start_date;
      WHILE (l_eff_date <= p_prev_period_end_date)
      LOOP
      --
        OPEN get_pay_period_details(l_eff_date);
        FETCH get_pay_period_details
          INTO l_time_period_id,l_period_end_date;
        CLOSE get_pay_period_details;

        hr_utility.set_location('NZ   l_time_period_id         : ' || l_time_period_id,20);
        hr_utility.set_location('NZ   l_prev_period_end_date   : ' || l_period_end_date,20);

        OPEN get_period_assg_act_id(l_time_period_id);
        FETCH get_period_assg_act_id
          INTO l_period_assg_act_id;
        CLOSE get_period_assg_act_id;

        hr_utility.set_location('NZ   l_prev_period_assg_act_id   : ' || l_period_assg_act_id,30);

        OPEN csr_get_recurr_absence(l_period_assg_act_id
                                   ,p_prev_period_end_date);
        FETCH csr_get_recurr_absence
          INTO l_leave_taken;

        IF csr_get_recurr_absence%FOUND THEN
        --
          hr_utility.set_location('NZ   l_leave_taken : ' || l_leave_taken,40);

          l_recurr_leave_taken := l_recurr_leave_taken + l_leave_taken;
        --
        ELSE
        --
          hr_utility.set_location('NZ No recurring absence in previous periods ',50);
        --
        END IF;

        CLOSE csr_get_recurr_absence;

        -- Move to next period
        l_eff_date := l_period_end_date +1;
      --
      END LOOP;
    --
    END IF;
    hr_utility.set_location('NZ Leaving              : ' ||l_procedure,60 );
    RETURN l_recurr_leave_taken;
  --
  EXCEPTION
  --
    WHEN others THEN
    --
      IF get_pay_period_details%ISOPEN THEN
      --
        CLOSE get_pay_period_details;
      --
      END IF;
      IF get_period_assg_act_id%ISOPEN THEN
      --
        CLOSE get_period_assg_act_id;
      --
      END IF;
      IF csr_get_recurr_absence%ISOPEN THEN
      --
        CLOSE csr_get_recurr_absence;
      --
      END IF;

      hr_utility.set_location('NZ Error in              : ' ||l_procedure,70 );
      RAISE;
  --
  END get_recur_abs_prev_period;

  FUNCTION get_leave_taken (
                            p_assignment_id      IN NUMBER
                           ,p_payroll_id         IN NUMBER
                           ,p_business_group_id  IN NUMBER
                           ,p_start_date         IN DATE
                           ,p_end_date           IN DATE
                           ,p_curr_aniv_start    IN DATE
                           ,p_plan_id            IN NUMBER
                           ,p_absence_start_date IN DATE
                           )
  RETURN NUMBER
  IS
  --
    CURSOR   csr_get_count_leave(c_assignment_id     IN NUMBER
                                ,c_business_group_id IN NUMBER
                                ,c_start_date        IN DATE
                                ,c_end_date          IN DATE)
    IS
    --
      SELECT nvl(nvl(sum(absence_days),sum(absence_hours)),0)   cnt_abs
      FROM   per_absence_attendances          paa
            ,per_absence_attendance_types     paat
            ,pay_accrual_plans                pap
            ,per_assignments_f                paf
      WHERE  paa.person_id                  = paf.person_id
      AND    paf.assignment_id              = c_assignment_id
      AND    paa.business_group_id          = c_business_group_id
      AND    paa.absence_attendance_type_id = paat.absence_attendance_type_id
      AND    pap.accrual_plan_id            = p_plan_id
      AND    pap.accrual_category           = 'NZAL'
      AND    paa.date_start                 BETWEEN c_start_date
                                            AND     c_end_date
      AND    paa.date_end                   BETWEEN c_start_date
                                            AND     c_end_date
      AND    c_end_date                     BETWEEN paf.effective_start_date
                                            AND     paf.effective_end_date;
    --


    l_days                      NUMBER;
    l_hours                     NUMBER;
    l_leave_taken               NUMBER;
    l_recurr_leave_prev_period  NUMBER;
    l_time_period_id            NUMBER;
    l_period_end_date           DATE;
    l_period_assg_act_id        NUMBER;
    l_recurr_leave_taken        NUMBER;
    l_eff_date                  DATE;
    l_procedure                 CONSTANT VARCHAR2(100) := g_package||'.get_leave_taken';
  --
  BEGIN
  --
    hr_utility.set_location('NZ   Entering            : ' || l_procedure,10);
    hr_utility.set_location('NZ   p_assignment_id     : ' || to_char(p_assignment_id),10);
    hr_utility.set_location('NZ   p_payroll_id        : ' || p_payroll_id,10);
    hr_utility.set_location('NZ   p_business_group_id : ' ||to_char(p_business_group_id),10);
    hr_utility.set_location('NZ   p_start_date        : ' || to_char(p_start_date,'dd Mon yyyy'),10);
    hr_utility.set_location('NZ   p_end_date          : ' || to_char(p_end_date,'dd Mon yyyy'),10);

    OPEN csr_get_count_leave(p_assignment_id
                            ,p_business_group_id
                            ,p_start_date
                            ,p_end_date);
    FETCH csr_get_count_leave
      INTO l_leave_taken;
    CLOSE csr_get_count_leave;

    -- Now find out whether there is any recurring absence that
    -- got processed in previous period
    -- If the recurring absence started in the previous Anniversary then
    -- it will get included in the Net Accrual of the previous Year.
    -- So the following calculation need not be done

    l_recurr_leave_taken := pay_nz_holidays_2003.get_recur_abs_prev_period
                             (
                              p_assignment_id        => p_assignment_id
                             ,p_payroll_id           => p_payroll_id
                             ,p_absence_start_date   => p_absence_start_date
                             ,p_curr_aniv_start      => p_curr_aniv_start
                             ,p_prev_period_end_date => p_end_date
                             ,p_plan_id              => p_plan_id
                             );
    l_leave_taken := l_leave_taken + l_recurr_leave_taken;
    hr_utility.set_location('NZ   l_leave_taken   : ' || l_leave_taken,20);
    hr_utility.set_location('NZ   Leaving         : ' || l_procedure,30);

    RETURN l_leave_taken;

  --
  EXCEPTION
  --
    WHEN others THEN
    --
      IF csr_get_count_leave%ISOPEN THEN
      --
        CLOSE csr_get_count_leave;
      --
      END IF;

      hr_utility.set_location('NZ   Erroring in        : ' || l_procedure,40);
      RAISE;
    --
  --
  END get_leave_taken;



  FUNCTION get_entitled_amount(
                               p_payroll_id           NUMBER
                              ,p_payroll_action_id    NUMBER
                              ,p_assignment_id        NUMBER
                              ,p_business_group_id    NUMBER
                              ,p_accrual_plan_id      NUMBER
                              ,p_absence_start_date   DATE
                              ,p_period_start_date    DATE
                              ,p_period_end_date      DATE
                              ,p_entitled_leave_taken NUMBER
                              ,p_curr_rate            NUMBER
                              ,p_hire_date            DATE
                              ,p_average_rate_p12mths NUMBER
                              )
  RETURN NUMBER
  IS
  --

    CURSOR get_curr_period_start
    IS
    --
      SELECT ptp.start_date
      FROM   per_time_periods ptp
            ,pay_payroll_actions ppa
      WHERE  ppa.payroll_action_id = p_payroll_action_id
      AND    ppa.time_period_id    = ptp.time_period_id;
    --
    l_eff_date               DATE;
    l_amt                    NUMBER;
    l_dummy                  NUMBER;
    l_anniversary_start_date DATE;
    l_anniversary_end_date   DATE;
    l_years_of_service       NUMBER;
    l_net_accrual            NUMBER;
    l_net_entitlement        NUMBER;
    l_calc_start_date        DATE;
    l_last_accrual           DATE;
    l_next_period_end        DATE;
    l_has_taken_pl           NUMBER;
    l_rate                   NUMBER;
    l_period_rate            NUMBER;
    l_def_bal_id             NUMBER;
    l_gross_earnings_ytd     NUMBER;
    l_time_worked_ytd        NUMBER;
    l_std_work_hours         NUMBER;
    l_entitled_leave_taken   NUMBER;
    l_leave_taken            NUMBER;
    l_curr_start_date        DATE;
    l_leave_available        NUMBER;
    l_procedure              CONSTANT VARCHAR2(100) := g_package||'get_entitled_amount';
  --
  BEGIN
  --
    hr_utility.set_location('NZ Entering               : ' || l_procedure ,10);
    hr_utility.set_location('NZ p_payroll_id           : ' || p_payroll_id ,10);
    hr_utility.set_location('NZ p_assignment_id        : ' || p_assignment_id ,10);
    hr_utility.set_location('NZ p_business_group_id    : ' || p_business_group_id ,10);
    hr_utility.set_location('NZ p_accrual_plan_id      : ' || p_accrual_plan_id,10);
    hr_utility.set_location('NZ p_period_start_date    : ' || p_period_start_date ,10);
    hr_utility.set_location('NZ p_period_end_date      : ' || p_period_end_date ,10);
    hr_utility.set_location('NZ p_entitled_leave_taken : ' || p_entitled_leave_taken ,10);
    hr_utility.set_location('NZ p_curr_rate            : ' || p_curr_rate,10);
    hr_utility.set_location('NZ p_hire_date            : ' || p_hire_date,10);
    hr_utility.set_location('NZ p_average_rate_p12mths : ' || p_average_rate_p12mths,10);

    -- Initialize Variables
    l_eff_date             := p_hire_date;
    l_amt                  := 0;
    l_entitled_leave_taken := p_entitled_leave_taken;

    -- This loop when be executed for each anniversary starting from
    -- First anniversary to the anniversary before the current anniversary
    --
    WHILE ( l_eff_date < p_period_start_date)
    LOOP
    --
      hr_utility.set_location('NZ l_eff_Date             : ' || l_eff_Date,20);

      -- Get Anniversary details for l_eff_date
      l_dummy := cache_anniversary_details
                   (p_payroll_id             => p_payroll_id
                   ,p_assignment_id          => p_assignment_id
                   ,p_accrual_plan_id        => p_accrual_plan_id
                   ,p_calculation_date       => l_eff_date
                   ,p_service_start_date     => p_hire_date
                   ,p_anniversary_start_date => l_anniversary_start_date
                   ,p_anniversary_end_date   => l_anniversary_end_date
                   ,p_years_of_service       => l_years_of_service
                   );
      hr_utility.set_location('NZ l_anniversary_start_date   : ' || l_anniversary_start_date,30);
      hr_utility.set_location('NZ l_anniversary_end_date     : ' || l_anniversary_end_date,30);
      hr_utility.set_location('NZ l_years_of_service         : ' || l_years_of_service,30);

      -- Get the Net Accrual for this anniversary
      l_dummy := get_accrual_entitlement
                   (
                    p_assignment_id        => p_assignment_id
                   ,p_payroll_id           => p_payroll_id
                   ,p_business_group_id    => p_business_group_id
                   ,p_plan_id              => p_accrual_plan_id
                   ,p_calculation_date     => l_anniversary_end_date
                   ,p_net_accrual          => l_net_accrual
                   ,p_net_entitlement      => l_net_entitlement
                   ,p_calc_start_date      => l_calc_start_date
                   ,p_last_accrual         => l_last_accrual
                   ,p_next_period_end      => l_next_period_end
                   );
      hr_utility.set_location('NZ l_net_accrual : ' || l_net_accrual,40);

      IF (l_net_accrual > 0) THEN
      --
        hr_utility.set_location('NZ l_net_accrual is greater than 0',50);
        OPEN get_curr_period_start;
        FETCH get_curr_period_start
          INTO l_curr_start_date;
        CLOSE get_curr_period_start;
        hr_utility.set_location('NZ after cursor get_curr_period_start',50);

        -- Net accrual in this period has to accommodate absences that are
        -- taken after this anniversary and before the current payroll period.

        -- Leave taken needs to be found only once when the control reaches
        -- this point of code for the first time.
        IF (l_leave_taken is NULL) THEN -- If it is first anniversary
        --
          IF (l_anniversary_end_date < l_curr_start_date) THEN
          --
            hr_utility.set_location('NZ l_leave taken is null',40);
            l_leave_taken := get_leave_taken
                              (
                               p_assignment_id      => p_assignment_id
                              ,p_payroll_id         => p_payroll_id
                              ,p_business_group_id  => p_business_group_id
                              ,p_start_date         => (l_anniversary_end_date + 1)
                              ,p_end_date           => (l_curr_start_date -1)
                              ,p_curr_aniv_start    => p_period_start_date
                              ,p_plan_id            => p_accrual_plan_id
                              ,p_absence_start_date => p_absence_start_date
                              );
          --
          ELSE
          --
            -- Anniversary has ended in current period
            -- Leave taken should be made 0
            l_leave_taken := 0;
          --
          END IF;
        --
        END IF;
        hr_utility.set_location('NZ l_leave_taken : ' || l_leave_taken,50);

        -- If 'Net Accrual in this Anniversary is less than 'Leave Taken'
        -- Then
        --   There is no leave available in this anniversary.
        --   Leave Taken = Leave Taken - Net Accrual
        -- Else
        --   There is leave available in this anniversary.
        --   Leave Available = Net Accrual - Leave Taken
        --   Leave Taken = 0 as all 'Leave Taken' has been accommodated now.
        IF (l_net_accrual <= l_leave_taken ) THEN
        --
          hr_utility.set_location('NZ Leave not Available in this year',60);
          l_leave_taken := l_leave_taken - l_net_accrual;
        --
        ELSE
        --
          hr_utility.set_location('NZ Leave Available in this year',70);

          l_leave_available := l_net_accrual - l_leave_taken;
          l_leave_taken     := 0;

          hr_utility.set_location('NZ Leave Available : '||l_leave_available,80);

          -- Check whether Assignment has taken any parental leave in this
          -- anniversary
          l_has_taken_pl := is_parental_leave_taken
                             (
                              p_assignment_id
                             ,p_business_group_id
                             ,l_anniversary_start_date
                             ,l_anniversary_end_date
                             );
          hr_utility.set_location('NZ l_has_taken_pl : ' || l_has_taken_pl,90);

          -- If Assignment has taken parental leave
          -- Then
          --   Rate as of this anniversary should be computed
          -- Else
          --   Current Rate should be used
          IF (l_has_taken_pl = 1) THEN
          --
            hr_utility.set_location('NZ Parental leave taken',100);
            l_rate := p_average_rate_p12mths;
          --
          ELSE
          --
            l_rate := p_curr_rate;
          --
          END IF;
          --
          hr_utility.set_location('NZ l_rate                 : '|| l_rate,130);
          hr_utility.set_location('NZ l_entitle_leave_Taken  : '|| l_entitled_leave_Taken,130);
          hr_utility.set_location('NZ l_net_accrual          : '|| l_net_accrual,130);
          hr_utility.set_location('NZ l_leave_available      : '|| l_leave_available,130);

          -- If Entitled Leave taken is less than Leave Available
          -- Then
          --   Compute the Amount and return
          -- Else
          --   Need to compute the amount for this anniversary and
          --   added it to l_amt
          --   Entitled Leave Taken = Entitled Leave Taken - Leave Available
          IF ( l_entitled_leave_taken <= l_leave_available ) THEN
          --
            l_amt := l_amt + l_entitled_leave_taken * l_rate;
            hr_utility.set_location('NZ l_amt                  : ' || l_amt,140);
            hr_utility.set_location('NZ l_entitled_leave_taken : ' || l_entitled_leave_taken,140);
            hr_utility.set_location('NZ Leaving',140);
            RETURN l_amt;
          --
          ELSE
          --
            hr_utility.set_location('NZ leave available less than entitled',150);
            l_entitled_leave_taken := l_entitled_leave_taken - l_leave_available;
            l_amt                  := l_amt + l_rate * l_leave_available;
            hr_utility.set_location('NZ l_amt                  : ' || l_amt,150);
            hr_utility.set_location('NZ l_entitled_leave_taken : ' || l_entitled_leave_taken,150);
          --
          END IF;
        --
        END IF; -- 'If leaves available in this year' block
      --
      END IF;   -- 'If NET Accrual <0 ' Block
      -- Move to Next Anniversary
      l_eff_date := l_anniversary_end_date +1;
    --
    END LOOP;
    hr_utility.set_location('NZ Leaving                : ' || l_procedure ,160);
    RETURN l_amt;
  --
  EXCEPTION
  --
    WHEN others THEN
    --
      IF get_curr_period_start%ISOPEN THEN
      --
        CLOSE get_curr_period_start ;
      --
      END IF;
      hr_utility.set_location('NZ Error in               : ' || l_procedure ,170);
      RAISE;
    --
  --
  END get_entitled_amount;


--
end pay_nz_holidays_2003;

/
