--------------------------------------------------------
--  DDL for Package Body PER_ABS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABS_BUS" as
/* $Header: peabsrhi.pkb 120.17.12010000.9 2010/03/23 06:49:45 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abs_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_absence_attendance_id       number         default null;

--
--  ---------------------------------------------------------------------------
--  |---------------------<  get_running_totals  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    This procedure gets the year to date totals and running totals for
--    both days and hours.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_absence_attendance_type_id
--    p_effective_date
--
--  Out Arguments:
--    p_running_total_hours
--    p_running_total_days
--    p_year_to_date_hours
--    p_year_to_date_days
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    If validation fails, an error is raised and processing stops.
--
--  Access Status:
--    Internal Table Handler Use Only. API updating is not required as this
--    is called from other chk procedures that use API updating.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure get_running_totals
  (p_person_id                  in  number
  ,p_absence_attendance_type_id in  number
  ,p_effective_date             in  date
  ,p_running_total_hours        out nocopy number
  ,p_running_total_days         out nocopy number
  ,p_year_to_date_hours         out nocopy number
  ,p_year_to_date_days          out nocopy number)
is

  l_proc    varchar2(72)  :=  g_package||'get_running_totals';
  l_absence_hours            number;
  l_absence_days             number;
  l_absence_year             date;
  l_effective_year           date;
  l_hours_or_days            varchar2(1);
  l_increasing_or_decreasing varchar2(1);
  l_screen_entry_value       number;
  l_effective_start_date     date;
  l_effective_end_date       date;

  cursor c_get_running_totals is
  select nvl(abs.absence_hours, 0),
         nvl(abs.absence_days, 0),
         to_date('01/01/'||
                 to_char(abs.date_end,'YYYY'),'DD/MM/YYYY'),
         abt.hours_or_days,
         abt.increasing_or_decreasing_flag
  from   per_absence_attendances abs,
         per_absence_attendance_types abt
  where  abs.person_id = p_person_id
  and    abs.absence_attendance_type_id = abt.absence_attendance_type_id
  and    abs.date_end is not null
  and    abs.date_end <= p_effective_date
  and    abt.input_value_id is not null
  and    abt.input_value_id = (select abt2.input_value_id
                               from   per_absence_attendance_types abt2
                               where  abt2.absence_attendance_type_id
                                       = p_absence_attendance_type_id);

  cursor c_get_hours_or_days is
  select abt.hours_or_days
  from   per_absence_attendance_types abt
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id;

  cursor c_get_upload_elements is
  -- select /*+ leading(PAA) */ nvl(fnd_number.canonical_to_number(pev.screen_entry_value), 0),
  select nvl(fnd_number.canonical_to_number(pev.screen_entry_value), 0),     -- bug 7579341, hint removed
         pev.effective_start_date,
         pev.effective_end_date
    from pay_element_entry_values_f pev,
         pay_element_entries_f pee,
         per_all_assignments_f paa,
         per_absence_attendance_types abt
   where pev.element_entry_id = pee.element_entry_id
     and pev.input_value_id = abt.input_value_id
     and pee.assignment_id = paa.assignment_id
     and paa.person_id = p_person_id
     and abt.absence_attendance_type_id = p_absence_attendance_type_id
--     and pee.creator_type <> 'A'  -- Bug 4422696
     and pee.creator_type not in('A','EE','NR','PR','R','RR')  -- Bug 4422696
     and pee.element_type_id =
         (select pet.element_type_id
            from pay_element_types_f pet,
                 pay_input_values_f piv
           where abt.input_value_id = piv.input_value_id
             and piv.element_type_id = pet.element_type_id
             and p_effective_date between piv.effective_start_date
             and piv.effective_end_date
             and p_effective_date between pet.effective_start_date
             and pet.effective_end_date)
     and p_effective_date between paa.effective_start_date
     and paa.effective_end_date
     and paa.primary_flag = 'Y';

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Initialise all out parameters to zero.
  --
  p_running_total_hours := 0;
  p_running_total_days  := 0;
  p_year_to_date_hours  := 0;
  p_year_to_date_days   := 0;

  --
  -- Set the effective year.
  --
  l_effective_year := to_date('01/01/'||
                               to_char(p_effective_date,'YYYY'), 'DD/MM/YYYY');

  hr_utility.set_location(l_proc, 20);

  --
  -- Get the running totals for this element type for this person.
  -- Both the year to dates and running totals are collected in the
  -- same loop construct.
  -- A loop is required because for each absence, its type could
  -- have a different unit of measure and a different increasing
  -- or decreasing flag.
  --
  open  c_get_running_totals;
  loop

    fetch c_get_running_totals into l_absence_hours,
                                    l_absence_days,
                                    l_absence_year,
                                    l_hours_or_days,
                                    l_increasing_or_decreasing;

    exit when c_get_running_totals%notfound;

    if l_hours_or_days = 'H'
    and l_increasing_or_decreasing = 'D' then

      hr_utility.set_location(l_proc, 25);

      p_running_total_hours := p_running_total_hours - l_absence_hours;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_hours := p_year_to_date_hours - l_absence_hours;
        end if;

    elsif l_hours_or_days = 'H'
    and   l_increasing_or_decreasing = 'I' then

      hr_utility.set_location(l_proc, 30);

      p_running_total_hours := p_running_total_hours + l_absence_hours;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_hours := p_year_to_date_hours + l_absence_hours;
        end if;

    elsif l_hours_or_days is null
    and   l_increasing_or_decreasing = 'I' then

      hr_utility.set_location(l_proc, 35);

      p_running_total_hours := p_running_total_hours + l_absence_hours;
      p_running_total_days  := p_running_total_days + l_absence_days;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_hours := p_year_to_date_hours + l_absence_hours;
           p_year_to_date_days := p_year_to_date_days + l_absence_days;
        end if;

    elsif l_hours_or_days = 'D'
    and   l_increasing_or_decreasing = 'D' then

      hr_utility.set_location(l_proc, 40);

      p_running_total_days := p_running_total_days - l_absence_days;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_days := p_year_to_date_days - l_absence_days;
        end if;

    elsif l_hours_or_days = 'D'
    and   l_increasing_or_decreasing = 'I' then

      hr_utility.set_location(l_proc, 45);

      p_running_total_days := p_running_total_days + l_absence_days;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_days := p_year_to_date_days + l_absence_days;
        end if;

    elsif l_hours_or_days is null
    and   l_increasing_or_decreasing = 'D' then

      hr_utility.set_location(l_proc, 50);

      p_running_total_hours := p_running_total_hours - l_absence_hours;
      p_running_total_days  := p_running_total_days - l_absence_days;

        --
        -- If the current absence is in the same year as the effective
        -- date, the year to date balance is adjusted.
        --
        if l_absence_year = l_effective_year then
           p_year_to_date_hours := p_year_to_date_hours - l_absence_hours;
           p_year_to_date_days := p_year_to_date_days - l_absence_days;
        end if;

    end if;

  end loop;
  close c_get_running_totals;

  hr_utility.set_location(l_proc, 55);

  --
  -- Is this absence type in hours or days?
  --
  open  c_get_hours_or_days;
  fetch c_get_hours_or_days into l_hours_or_days;
  close c_get_hours_or_days;

  hr_utility.set_location(l_proc, 60);

  --
  -- Add any upload elements to the balance.  Upload elements
  -- are elements linked to the absence type but do not
  -- have an associated absence record. We ADD the upload
  -- elements to the balance regardless of whether the
  -- absence type is increasing or decreasing. This is
  -- because the element could be linked to n number of absence
  -- types (1/2 could be increasing and 1/2 could be decreasing).
  --
  open  c_get_upload_elements;
  loop

    fetch c_get_upload_elements into l_screen_entry_value
                                    ,l_effective_start_date
                                    ,l_effective_end_date;

    exit when c_get_upload_elements%notfound;

    --
    -- Add to the running total balance.
    --
    if l_hours_or_days = 'D' then

      hr_utility.set_location(l_proc, 65);
      p_running_total_days := p_running_total_days + l_screen_entry_value;

    elsif l_hours_or_days = 'H' then

      hr_utility.set_location(l_proc, 70);
      p_running_total_hours := p_running_total_hours + l_screen_entry_value;

    end if;

    --
    -- If its in the current year add the year to date balance.
    --
    if to_char(l_effective_start_date, 'YYYY') = to_char(p_effective_date, 'YYYY')
      and to_char(l_effective_end_date, 'YYYY') = to_char(p_effective_date, 'YYYY')
    then

      hr_utility.set_location(l_proc, 75);

      if l_hours_or_days = 'D' then
        p_year_to_date_days := p_year_to_date_days + l_screen_entry_value;

      elsif l_hours_or_days = 'H' then
        p_year_to_date_hours := p_year_to_date_hours + l_screen_entry_value;

      end if;

    end if;

  end loop;

  hr_utility.set_location(l_proc, 80);
  --
  -- Null out any irrelevant balances.
  --
  if l_hours_or_days = 'D' then
    p_running_total_hours := null;
    p_year_to_date_hours  := null;

  elsif l_hours_or_days = 'H' then
    p_running_total_days  := null;
    p_year_to_date_days   := null;

  else
    p_running_total_hours := null;
    p_year_to_date_hours  := null;
    p_running_total_days  := null;
    p_year_to_date_days   := null;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 85);

end get_running_totals;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  per_valid_for_absence  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    This function validates that the person exists and that they have
--    a valid period of service or period of placement for the entire absence
--    duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type
--    p_date_projected_start
--    p_date_projected_end
--    p_date_start
--    p_date_end
--
--  Post Success:
--    If validation passes, the function returns TRUE.
--
--  Post Failure:
--    IF validation fails, the function returns FALSE.
--
--  Access Status:
--    Internal Table Handler Use Only. API updating is not required as this
--    is called from other chk procedures that use API updating.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function per_valid_for_absence
  (p_person_id            in number
  ,p_business_group_id    in number
  ,p_date_projected_start in date
  ,p_date_projected_end   in date
  ,p_date_start           in date
  ,p_date_end             in date) return boolean
is

  --
  -- Check the person is valid for the entire absence term.
  -- For contingent workers there is a join to per_all_workforce_v
  -- so that contingent workers are only included when the profile
  -- option HR_TREAT_CWK_AS_EMP is Yes.
  --
  cursor c_per_valid_for_absence is
  select null
  from   per_all_people_f ppf,
         per_periods_of_service pos
  where  ppf.person_id = p_person_id
  and    ppf.person_id = pos.person_id
  and    ppf.current_employee_flag = 'Y'
  and  ((nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'N' and
         ppf.business_group_id = p_business_group_id)
   or    nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'Y')
  and   (p_date_projected_start is null or p_date_projected_start
         between pos.date_start and nvl(pos.actual_termination_date,hr_api.g_eot))
  and   (p_date_projected_end is null or p_date_projected_end
         between pos.date_start and nvl(pos.actual_termination_date,hr_api.g_eot))
  and   (p_date_start is null or p_date_start
         between pos.date_start and nvl(pos.actual_termination_date,hr_api.g_eot))
  and   (p_date_end is null or p_date_end
         between pos.date_start and nvl(pos.actual_termination_date,hr_api.g_eot))
  union select null
  from   per_all_people_f ppf,
         per_periods_of_placement pop,
         per_all_workforce_v pawv
  where  ppf.person_id = p_person_id
  and    ppf.person_id = pop.person_id
  and    ppf.person_id = pawv.person_id
  and    ppf.current_npw_flag = 'Y'
  and  ((nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'N' and
         ppf.business_group_id = p_business_group_id)
   or    nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'Y')
  and   (p_date_projected_start is null or p_date_projected_start
         between pop.date_start and nvl(pop.actual_termination_date,hr_api.g_eot))
  and   (p_date_projected_end is null or p_date_projected_end
         between pop.date_start and nvl(pop.actual_termination_date,hr_api.g_eot))
  and   (p_date_start is null or p_date_start
         between pop.date_start and nvl(pop.actual_termination_date,hr_api.g_eot))
  and   (p_date_end is null or p_date_end
         between pop.date_start and nvl(pop.actual_termination_date,hr_api.g_eot));

  --
  l_proc    varchar2(72)  :=  g_package||'per_valid_for_absence';
  l_exists  varchar2(1);
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Check that the person exists and that they have a valid period of
  -- service for the entire absence duration.
  --
  open  c_per_valid_for_absence;
  fetch c_per_valid_for_absence into l_exists;

  if c_per_valid_for_absence%found then
    --
    -- Person is found and they have a valid period of service.
    --
    return TRUE;
  else
    --
    -- Person is invalid or the period of service is not valid
    -- for the duration of the absence.
    --
    return FALSE;
  end if;

  close c_per_valid_for_absence;

  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);

end per_valid_for_absence;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  convert_to_minutes >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Converts two times into duration minutes.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_time_start
--    p_time_end
--
--  Post Success:
--    The function returns duration minutes and processing continues.
--
--  Post Failure:
--    The function errors and processing stops.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function convert_to_minutes
  (p_time_start in varchar2
  ,p_time_end   in varchar2) return number
is
  --
  l_proc           varchar2(72)  :=  g_package||'convert_to_minutes';
  l_time_duration  number;

  cursor c_get_time_duration is
  select ((substr(p_time_end,1,2) * 60) + substr(p_time_end,4,2)) -
         ((substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2))
  from   dual;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Calculate the total time in minutes between the start time
  -- and the end time.
  --
  open  c_get_time_duration;
  fetch c_get_time_duration into l_time_duration;
  close c_get_time_duration;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  return l_time_duration;

end convert_to_minutes;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_time_format >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Checks that the time format is valid.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_time
--
--  Post Success:
--    If the time format is valid, processing continues.
--
--  Post Failure:
--    If the time format is invalid processing stops and an error is raised.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_time_format
  (p_time in varchar2)
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_time_format';
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  if p_time is not null then
     if not (substr(p_time,1,2) between '00' and '23'
        and substr(p_time,4,2) between '00' and '59'
        and substr(p_time,3,1) = ':'
        and length(p_time) = 5) then
        fnd_message.set_name('PAY','HR_6004_ALL_FORMAT_HHMM');
        fnd_message.raise_error;
     end if;
  end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_time_format;
--
--  +-------------------------------------------------------------------------+
--  |-----------------<      good_time_format       >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Tests CHAR values for valid time.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_time VARCHAR2
--
--  Out Arguments:
--    BOOLEAN
--
--  Post Success:
--    Returns TRUE or FALSE depending on valid time or not.
--
--  Post Failure:
--    Returns FALSE for invalid time.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
FUNCTION good_time_format ( p_time IN VARCHAR2 ) RETURN BOOLEAN IS
--
BEGIN
  --
  IF p_time IS NOT NULL THEN
    --
    IF NOT (SUBSTR(p_time,1,2) BETWEEN '00' AND '23' AND
            SUBSTR(p_time,4,2) BETWEEN '00' AND '59' AND
            SUBSTR(p_time,3,1) = ':' AND
            LENGTH(p_time) = 5) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
    --
  ELSE
    RETURN FALSE;
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    RETURN FALSE;
  --
END good_time_format;
--
--  +-------------------------------------------------------------------------+
--  |-----------------<     calc_sch_based_dur      >-------------------------|
--  +-------------------------------------------------------------------------+
--  Description:
--    Calculate the absence duration in hours/days based on the work schedule.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_days_or_hours VARCHAR2
--    p_date_start    DATE
--    p_date_end      DATE
--    p_time_start    VARCHAR2
--    p_time_end      VARCHAR2
--    p_assignment_id NUMBER
--
--  Out Arguments:
--    p_duration NUMBER
--
--  Post Success:
--    Value returned for absence duration.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE calc_sch_based_dur ( p_days_or_hours IN VARCHAR2,
                               p_date_start    IN DATE,
                               p_date_end      IN DATE,
                               p_time_start    IN VARCHAR2,
                               p_time_end      IN VARCHAR2,
                               p_assignment_id IN NUMBER,
                               p_duration      IN OUT NOCOPY NUMBER
                             ) IS
  --
  l_idx             NUMBER;
  l_ref_date        DATE;
  l_first_band      BOOLEAN;
  l_day_start_time  VARCHAR2(5);
  l_day_end_time    VARCHAR2(5);
  l_start_time      VARCHAR2(5);
  l_end_time        VARCHAR2(5);
  --
  l_start_date      DATE;
  l_end_date        DATE;
  l_schedule        cac_avlblty_time_varray;
  l_schedule_source VARCHAR2(10);
  l_return_status   VARCHAR2(1);
  l_return_message  VARCHAR2(2000);
  --
  l_time_start      VARCHAR2(5);
  l_time_end        VARCHAR2(5);
  --
  e_bad_time_format EXCEPTION;
  --
BEGIN
  hr_utility.set_location('Entering '||g_package||'.calc_sch_based_dur',10);
  p_duration := 0;
  l_time_start := p_time_start;
  l_time_end := p_time_end;
  --
  IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    IF NOT good_time_format(l_time_start) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  /*
  IF l_time_end IS NULL THEN
    l_time_end := '23:59';  --changed for bug #6274821
  ELSE
    IF NOT good_time_format(l_time_end) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  */
  -- fix for the bug 6711896
   IF l_time_end IS NULL THEN

   IF p_days_or_hours = 'D' THEN
      l_time_end := '00:00';
  else
    l_time_end := '23:59';
 --  l_time_end := '00:00';
   END IF;

  ELSE
    IF NOT good_time_format(l_time_end) THEN
      RAISE e_bad_time_format;
    END IF;
  END IF;
  --fix for the bug 6711896
  l_start_date := TO_DATE(TO_CHAR(p_date_start,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
  l_end_date := TO_DATE(TO_CHAR(p_date_end,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
  IF p_days_or_hours = 'D' THEN
    l_end_date := l_end_date + 1;
  END IF;
  --
  -- Fetch the work schedule
  --
  hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => p_assignment_id
  , p_period_start_date    => l_start_date
  , p_period_end_date      => l_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
  --
  IF l_return_status = '0' THEN
    --
    -- Calculate duration
    --
    l_idx := l_schedule.first;
    --
    IF p_days_or_hours = 'D' THEN
      --
      l_first_band := TRUE;
      l_ref_date := NULL;
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_first_band THEN
              l_first_band := FALSE;
              l_ref_date := TRUNC(l_schedule(l_idx).START_DATE_TIME);
              IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
              ELSE
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              END IF;
            ELSE -- not first time
              IF TRUNC(l_schedule(l_idx).START_DATE_TIME) = l_ref_date THEN
                p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
              ELSE
                l_ref_date := TRUNC(l_schedule(l_idx).END_DATE_TIME);
                IF (TRUNC(l_schedule(l_idx).END_DATE_TIME) = TRUNC(l_schedule(l_idx).START_DATE_TIME)) THEN
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) + 1);
                ELSE
                  p_duration := p_duration + (TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME));
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      --
    ELSE -- p_days_or_hours is 'H'
      --
      l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
            IF l_schedule(l_idx).END_DATE_TIME < l_schedule(l_idx).START_DATE_TIME THEN
              -- Skip this invalid slot which ends before it starts
              NULL;
            ELSE
              IF TRUNC(l_schedule(l_idx).END_DATE_TIME) > TRUNC(l_schedule(l_idx).START_DATE_TIME) THEN
                -- Start and End on different days
                --
                -- Get first day hours
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_day_end_time,1,2)*60 + SUBSTR(l_day_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get last day hours
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_day_start_time,1,2)*60 + SUBSTR(l_day_start_time,4,2)) + 1)/60)
                INTO p_duration
                FROM DUAL;
                --
                -- Get between full day hours
                SELECT p_duration + ((TRUNC(l_schedule(l_idx).END_DATE_TIME) - TRUNC(l_schedule(l_idx).START_DATE_TIME) - 1) * 24)
                INTO p_duration
                FROM DUAL;
              ELSE
                -- Start and End on same day
                l_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'HH24:MI');
                l_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'HH24:MI');
                SELECT p_duration + (((SUBSTR(l_end_time,1,2)*60 + SUBSTR(l_end_time,4,2)) -
                                      (SUBSTR(l_start_time,1,2)*60 + SUBSTR(l_start_time,4,2)))/60)
                INTO p_duration
                FROM DUAL;
              END IF;
            END IF;
          END IF;
        END IF;
        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
      END LOOP;
      p_duration := ROUND(p_duration,2);
      --
    END IF;
  END IF;
  --
  hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',20);
EXCEPTION
  --
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
  --
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving '||g_package||'.calc_sch_based_dur',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
  --
END calc_sch_based_dur;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration -old>-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--
--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration -old>-------------------------|
--  ---------------------------------------------------------------------------
--
--
procedure calculate_absence_duration
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy boolean)
  is

  l_proc                 varchar2(72) := g_package||
                                        'calculate_absence_duration';
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_assignment_id        number;
  l_hours_or_days        varchar2(1);
  l_element_type_id      number;
  l_legislation_code     varchar2(150);
  l_formula_id           number;
  l_inputs               ff_exec.inputs_t;
  l_outputs              ff_exec.outputs_t;
  l_user_message         varchar2(1) := 'N';
  l_invalid_message      fnd_new_messages.message_text%TYPE;

  /*Added for the bug 6790565 - starts here*/
  l_invalid_message_txt fnd_new_messages.message_text%TYPE;
  l_invalid_message_num number;
  /*Added for the bug 6790565 - ends here*/

  wrong_parameters       exception;
  l_normal_time_start    varchar2(5);
  l_normal_time_end      varchar2(5);
  l_normal_day_minutes   number;
  l_first_day_minutes    number;
  l_last_day_minutes     number;
  l_same_day_minutes     number;
  l_absence_days         number;
  l_absence_hours        number;

  -- For schedule based calculation
  l_sch_based_dur        VARCHAR2(1);
  l_sch_based_dur_found  BOOLEAN;
  l_absence_duration     NUMBER;

  --3093970 starts here. comment out the code introduced by 2820155.
  --2820155 change starts
  -- l_eff_time_start varchar2(5);
  -- l_eff_time_end varchar2(5);
  --2820155 change ends
  --3093970 ends here.

  cursor c_get_absence_info is
  select abt.hours_or_days,
         piv.element_type_id
  from   per_absence_attendance_types abt,
         pay_input_values_f piv
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.input_value_id = piv.input_value_id(+);
  --
  cursor c_get_normal_hours (p_assignment_id in number) is
  select nvl(nvl(asg.time_normal_start, pbg.default_start_time), '00:00'),
         nvl(nvl(asg.time_normal_finish, pbg.default_end_time), '23:59')
  FROM   per_all_assignments_f asg,
         per_business_groups pbg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = pbg.business_group_id
  AND    p_effective_date between asg.effective_start_date
                          and     asg.effective_end_date;

--

  l_use_formula              boolean;

begin

  hr_utility.set_location('Entering Old:'|| l_proc, 10);
  per_abs_bus.calculate_absence_duration
	(p_absence_attendance_id      => p_absence_attendance_id
       ,p_absence_attendance_type_id => p_absence_attendance_type_id
       ,p_business_group_id          => p_business_group_id
       ,p_object_version_number      => p_object_version_number
       ,p_effective_date             => p_effective_date
       ,p_person_id                  => p_person_id
       ,p_date_start                 => p_date_start
       ,p_date_end                   => p_date_end
       ,p_time_start                 => p_time_start
       ,p_time_end                   => p_time_end
	,p_ABS_INFORMATION_CATEGORY   => NULL
        ,p_ABS_INFORMATION1          => NULL
        ,p_ABS_INFORMATION2          => NULL
	,p_ABS_INFORMATION3          => NULL
	,p_ABS_INFORMATION4          => NULL
	,p_ABS_INFORMATION5          => NULL
	,p_ABS_INFORMATION6          => NULL
        ,p_absence_days               => l_absence_days
        ,p_absence_hours              => l_absence_hours
        ,p_use_formula                => l_use_formula);

 p_absence_hours := l_absence_hours;
 p_absence_days := l_absence_days;
 p_use_formula :=l_use_formula;

 hr_utility.set_location('leaving old:'|| l_proc, 10);
end;
--  ---------------------------------------------------------------------------
--  |-----------------<  calculate_absence_duration -new>-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calculates the absence duration in hours and / or days and sets
--    the duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_start
--    p_date_end
--    p_time_start
--    p_time_end
--    p_ABS_INFORMATION_CATEGORY
--    p_ABS_INFORMATION1
--    p_ABS_INFORMATION2
--    p_ABS_INFORMATION3
--    p_ABS_INFORMATION4
--    p_ABS_INFORMATION5
--    p_ABS_INFORMATION6

--  Out Arguments:
--    p_absence_days
--    p_absence_hours
--    p_use_formula
--
--  Post Success:
--    The absence duration in days and hours is returned.
--
--  Post Failure:
--    If a failure occurs, an application error is raised and
--    processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure calculate_absence_duration
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_effective_date             in  date
 ,p_person_id                  in  number
 ,p_date_start                 in  date
 ,p_date_end                   in  date
 ,p_time_start                 in  varchar2
 ,p_time_end                   in  varchar2
 ,p_ABS_INFORMATION_CATEGORY   in varchar2
 ,p_ABS_INFORMATION1          in varchar2
 ,p_ABS_INFORMATION2          in varchar2
 ,p_ABS_INFORMATION3          in varchar2
 ,p_ABS_INFORMATION4          in varchar2
 ,p_ABS_INFORMATION5          in varchar2
 ,p_ABS_INFORMATION6          in varchar2
 ,p_absence_days               out nocopy number
 ,p_absence_hours              out nocopy number
 ,p_use_formula                out nocopy boolean)
  is

  l_proc                 varchar2(72) := g_package||
                                        'calculate_absence_duration';
  l_exists               varchar2(1);
  l_api_updating         boolean;
  l_assignment_id        number;
  l_hours_or_days        varchar2(1);
  l_element_type_id      number;
  l_legislation_code     varchar2(150);
  l_formula_id           number;
  l_inputs               ff_exec.inputs_t;
  l_outputs              ff_exec.outputs_t;
  l_user_message         varchar2(1) := 'N';
  l_invalid_message      fnd_new_messages.message_text%TYPE;

  /*Added for the bug 6790565 - starts here*/
  l_invalid_message_txt fnd_new_messages.message_text%TYPE;
  l_invalid_message_num number;
  /*Added for the bug 6790565 - ends here*/

  wrong_parameters       exception;
  l_normal_time_start    varchar2(5);
  l_normal_time_end      varchar2(5);
  l_normal_day_minutes   number;
  l_first_day_minutes    number;
  l_last_day_minutes     number;
  l_same_day_minutes     number;
  l_absence_days         number;
  l_absence_hours        number;

  -- For schedule based calculation
  l_sch_based_dur        VARCHAR2(1);
  l_sch_based_dur_found  BOOLEAN;
  l_absence_duration     NUMBER;

  --3093970 starts here. comment out the code introduced by 2820155.
  --2820155 change starts
  -- l_eff_time_start varchar2(5);
  -- l_eff_time_end varchar2(5);
  --2820155 change ends
  --3093970 ends here.

  cursor c_get_absence_info is
  select abt.hours_or_days,
         piv.element_type_id
  from   per_absence_attendance_types abt,
         pay_input_values_f piv
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.input_value_id = piv.input_value_id(+);
  --
  cursor c_get_normal_hours (p_assignment_id in number) is
  select nvl(nvl(asg.time_normal_start, pbg.default_start_time), '00:00'),
         nvl(nvl(asg.time_normal_finish, pbg.default_end_time), '23:59')
  FROM   per_all_assignments_f asg,
         per_business_groups pbg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = pbg.business_group_id
  AND    p_effective_date between asg.effective_start_date
                          and     asg.effective_end_date;

--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_start, hr_api.g_varchar2)
    = nvl(p_time_start, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.time_end, hr_api.g_varchar2)
    = nvl(p_time_end, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.absence_days, hr_api.g_number)
    = nvl(p_absence_days, hr_api.g_number)
  and nvl(per_abs_shd.g_old_rec.absence_hours, hr_api.g_number)
    = nvl(p_absence_hours, hr_api.g_number)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 15);

  --
  -- See if a Fast Formula exists. Here the Fast Formula names
  -- are hard-coded. Fast Formulas with these exact names can
  -- be defined at one of three levels to default the absence
  -- duration:
  --
  --  1. Business group (customer-definable)
  --  2. Legislation (Oracle internal legislation-specific)
  --  3. Core (Oracle internal core product)
  --

  --
  -- Get the varous additional values that are required for use later.
  --

  l_assignment_id := hr_person_absence_api.get_primary_assignment
      (p_person_id         => p_person_id
      ,p_effective_date    => p_effective_date);

  l_legislation_code := hr_api.return_legislation_code
      (p_business_group_id => p_business_group_id);

  open  c_get_absence_info;
  fetch c_get_absence_info into l_hours_or_days,
                                l_element_type_id;
  close c_get_absence_info;

  l_sch_based_dur := NVL(FND_PROFILE.Value('HR_SCH_BASED_ABS_CALC'),'N');
  l_sch_based_dur_found := FALSE;
  --
  IF l_sch_based_dur = 'Y' THEN
    --
    hr_utility.set_location(l_proc, 16);
    p_use_formula := TRUE; -- set to display
    --
    calc_sch_based_dur (p_days_or_hours => l_hours_or_days,
                        p_date_start    => p_date_start,
                        p_date_end      => p_date_end,
                        p_time_start    => p_time_start,
                        p_time_end      => p_time_end,
                        p_assignment_id => l_assignment_id,
                        p_duration      => l_absence_duration
                       );
    --
    IF l_absence_duration IS NOT NULL THEN
      --
      l_sch_based_dur_found := TRUE;
      --
      IF l_hours_or_days = 'H' THEN
        hr_utility.set_location(l_proc, 17);
        p_absence_hours := l_absence_duration;
      ELSIF l_hours_or_days = 'D' THEN
        hr_utility.set_location(l_proc, 18);
        p_absence_days := l_absence_duration;
      ELSE
        hr_utility.set_location(l_proc, 19);
        l_sch_based_dur_found := FALSE;
      END IF;
      --
    END IF;
    --
  END IF; -- sch_based_dur is 'Y'

  IF l_sch_based_dur <> 'Y' OR (l_sch_based_dur = 'Y' AND NOT l_sch_based_dur_found) THEN
  --
  hr_utility.set_location(l_proc, 20);

  begin
    --
    -- Look for a customer-defined formula
    --
    select ff.formula_id
    into   l_formula_id
    from   ff_formulas_f ff
    where  ff.formula_name = 'BG_ABSENCE_DURATION'
    and    ff.business_group_id = p_business_group_id
    and    p_effective_date between ff.effective_start_date and
                                    ff.effective_end_date;
  exception

    when no_data_found then
      --
      -- There is no customer defined formula so look for
      -- a legislative formula.
      --
      begin

        hr_utility.set_location(l_proc, 25);

        select ff.formula_id
        into   l_formula_id
        from   ff_formulas_f ff
        where  ff.formula_name = 'LEGISLATION_ABSENCE_DURATION'
        and    ff.legislation_code = l_legislation_code
        and    ff.business_group_id is null
        and    p_effective_date between ff.effective_start_date and
                                        ff.effective_end_date;

      exception

        when no_data_found then
          --
          -- If none of the two above then select the core formula
          --
          begin

            hr_utility.set_location(l_proc, 30);

            select ff.formula_id
            into   l_formula_id
            from   ff_formulas_f ff
            where  ff.formula_name = 'CORE_ABSENCE_DURATION'
            and    ff.legislation_code is null
            and    ff.business_group_id is null
            and    p_effective_date between ff.effective_start_date and
                                            ff.effective_end_date;

          exception

            when no_data_found then
              --
              -- No formula is found. We capture the error and do nothing.
              --
              null;

          end;
      end;
  end;

  hr_utility.set_location(l_proc, 35);

  if l_formula_id is not null then
    --
    -- An absence duration Fast Formula should be used so the
    -- formula is called. First, the formula is initialised.
    --
    p_use_formula := TRUE;

    hr_utility.set_location(l_proc, 40);

    --
    -- Initalise the formula.
    --
    ff_exec.init_formula
      (p_formula_id     => l_formula_id
      ,p_effective_date => p_effective_date
      ,p_inputs         => l_inputs
      ,p_outputs        => l_outputs);

    hr_utility.set_location(l_proc, 45);

    --
    -- Assign the inputs.
    --
    for i_input in l_inputs.first..l_inputs.last
    loop

      if l_inputs(i_input).name    = 'DAYS_OR_HOURS' then
         l_inputs(i_input).value  := l_hours_or_days;
      elsif l_inputs(i_input).name = 'DATE_START' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical(p_date_start);
      elsif l_inputs(i_input).name = 'DATE_END' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical(p_date_end);
      elsif l_inputs(i_input).name = 'TIME_START' then
         l_inputs(i_input).value  := p_time_start;
      elsif l_inputs(i_input).name = 'TIME_END' then
         l_inputs(i_input).value  := p_time_end;
      elsif l_inputs(i_input).name = 'DATE_EARNED' then
         l_inputs(i_input).value  := fnd_date.date_to_canonical
                                     (p_effective_date);
      elsif l_inputs(i_input).name = 'BUSINESS_GROUP_ID' then
         l_inputs(i_input).value  := p_business_group_id;
      elsif l_inputs(i_input).name = 'LEGISLATION_CODE' then
         l_inputs(i_input).value  := l_legislation_code;
      elsif l_inputs(i_input).name = 'ASSIGNMENT_ID' then
         l_inputs(i_input).value  := l_assignment_id;
      elsif l_inputs(i_input).name = 'ELEMENT_TYPE_ID' then
         l_inputs(i_input).value  := l_element_type_id;
      elsif l_inputs(i_input).name = 'ABSENCE_ATTENDANCE_TYPE_ID' then
         l_inputs(i_input).value  := p_absence_attendance_type_id;
      elsif l_inputs(i_input).name = 'ABS_INFORMATION_CATEGORY' then
         l_inputs(i_input).value  := p_ABS_INFORMATION_CATEGORY;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION1' then
         l_inputs(i_input).value  := p_ABS_INFORMATION1;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION2' then
         l_inputs(i_input).value  := p_ABS_INFORMATION2;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION3' then
         l_inputs(i_input).value  := p_ABS_INFORMATION3;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION4' then
         l_inputs(i_input).value  := p_ABS_INFORMATION4;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION5' then
         l_inputs(i_input).value  := p_ABS_INFORMATION5;
    elsif l_inputs(i_input).name = 'ABS_INFORMATION6' then
         l_inputs(i_input).value  := p_ABS_INFORMATION6;


      else
         raise wrong_parameters;
      end if;

    end loop;

    hr_utility.set_location(l_proc, 50);

    --
    -- Run the formula.
    --
    ff_exec.run_formula(l_inputs, l_outputs);

    hr_utility.set_location(l_proc, 55);

    --
    -- Assign the outputs.
    --
    for i_output in l_outputs.first..l_outputs.last
    loop

      if l_outputs(i_output).name = 'DURATION' then

        if l_outputs(i_output).value = 'FAILED' then
          l_user_message := 'Y';
        else
          --
          -- The absence hours / days out parameter is set. If no UOM
          -- is set but the start or end time have been entered, the output
          -- is returned in hours.
          --
          if l_hours_or_days = 'H'
          or (p_time_start is not null and p_time_end is not null) then
            p_absence_hours := round(fnd_number.canonical_to_number(l_outputs(i_output).value),2);
          else
            p_absence_days := round(fnd_number.canonical_to_number(l_outputs(i_output).value),2);
          end if;
        end if;

      elsif l_outputs(i_output).name = 'INVALID_MSG' then
           --
           -- Here any customer-defined messages are set and
           -- raised after this loop.
           --
           l_invalid_message := l_outputs(i_output).value;

        null;
      else
        raise wrong_parameters;
      end if;

    end loop;

    hr_utility.set_location(l_proc, 60);
    hr_utility.trace('l_user_message: '||l_user_message);
    hr_utility.trace('l_invalid_message: '||l_invalid_message);


    /*Added for the bug 6790565 - starts here*/
    -- Displays the error message text if text is given
    -- directly in the fast formula
    -- Displays the error message text if the error message
    -- name is  given
    -- This is done as SSHR supports both text as well as name
    select instr(l_invalid_message,' ',1,1)
    into l_invalid_message_num from dual;

    if l_invalid_message_num = 0
    then
    l_invalid_message_txt := fnd_message.get_string('PER',l_invalid_message);
    else
    l_invalid_message_txt := l_invalid_message;
    end if;

    /*Added for the bug 6790565 - ends here*/
    --
    -- If the Fast Formula raises a user-defined error message,
    -- raise the error back to the user.
    --
    if l_user_message = 'Y' then
      -- Start of fix 3553741
      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
            /*Added for the bug 6790565 - starts here*/
      -- hr_utility.set_message_token('FORMULA_TEXT', l_invalid_message);
      hr_utility.set_message_token('FORMULA_TEXT', l_invalid_message_txt);
      /*Added for the bug 6790565 - ends here*/
      hr_utility.raise_error;
      -- End of fix 3553741
    end if;

    hr_utility.set_location(l_proc, 63);

  else
    --
    -- No formula could be located so we calculate based on the
    -- standard hours of the assignment or business group.
    --
    p_use_formula := FALSE;

    hr_utility.set_location(l_proc, 65);

    --
    -- Get the default start and end times. First check the assignment, then
    -- the business group. If neither of these, assume 24 hours a day.
    --
    open  c_get_normal_hours (l_assignment_id);
    fetch c_get_normal_hours into l_normal_time_start,
                                  l_normal_time_end;
    close c_get_normal_hours;

    -- #2734822: verify the time format

    hr_dbchkfmt.is_db_format(p_value            => l_normal_time_start
                            ,p_formatted_output => l_normal_time_start
                            ,p_arg_name         => 'time_normal_start'
                            ,p_format           => 'TIMES');


    hr_dbchkfmt.is_db_format(p_value            => l_normal_time_end
                            ,p_formatted_output => l_normal_time_end
                            ,p_arg_name         => 'time_normal_finish'
                            ,p_format           => 'TIMES');

    -- end #2734822

    hr_utility.set_location(l_proc, 70);

    --
    -- Calculate the number of minutes in each day.
    --
    -- 3093970 starts here. comment out code introduced by 2820155.
    --2820155 changes start
    -- Start time and end time should be adjusted to fall between
    -- normal start time and end time.
  /*
    l_eff_time_start :=p_time_start;
    l_eff_time_end :=p_time_end;

    IF (
    	( (substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2)) <
         ( (substr(l_normal_time_start,1,2) * 60) + substr(l_normal_time_start,4,2))
    	)    THEN
    l_eff_time_start := l_normal_time_start;

    END IF;

    IF (
       	( (substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2)) >
             ( (substr(l_normal_time_end,1,2) * 60) + substr(l_normal_time_end,4,2))
        	)    THEN
        l_eff_time_start := l_normal_time_end;

    END IF;


    IF (
       	( (substr(p_time_end,1,2) * 60) + substr(p_time_end,4,2)) <
             ( (substr(l_normal_time_start,1,2) * 60) + substr(l_normal_time_start,4,2))
        	)    THEN
        l_eff_time_end := l_normal_time_start;

    END IF;


    IF (
       	( (substr(p_time_end,1,2) * 60) + substr(p_time_end,4,2)) >
             ( (substr(l_normal_time_end,1,2) * 60) + substr(l_normal_time_end,4,2))
        	)    THEN
        l_eff_time_end := l_normal_time_end;

    END IF;

    -- Pass effective start and end time instead of received start and end time

    l_normal_day_minutes := convert_to_minutes(l_normal_time_start,
                                            l_normal_time_end);
    l_first_day_minutes := convert_to_minutes(nvl(l_eff_time_start,
                                               l_normal_time_start),
                                           l_normal_time_end);
    l_last_day_minutes := convert_to_minutes(l_normal_time_start,
                                          nvl(l_eff_time_end,
                                              l_normal_time_end));
    l_same_day_minutes := convert_to_minutes(nvl(l_eff_time_start,
                                              l_normal_time_start),
                                          nvl(l_eff_time_end,
                                          l_normal_time_end));

    --2820155 changes end
    */
    --
    -- Calculate the number of minutes in each day.
    --
    l_normal_day_minutes := convert_to_minutes(l_normal_time_start,
                                            l_normal_time_end);
    l_first_day_minutes := convert_to_minutes(nvl(p_time_start,
                                               l_normal_time_start),
                                               l_normal_time_end);
    l_last_day_minutes := convert_to_minutes(l_normal_time_start,
                                             nvl(p_time_end,
                                              l_normal_time_end));
    --
    -- Bug3093970 starts here.
    --
    if l_first_day_minutes <= 0 OR l_first_day_minutes > l_normal_day_minutes
       OR l_last_day_minutes <= 0 OR l_last_day_minutes > l_normal_day_minutes  THEN
       --
       -- The leave timings are out off the standard timings.
       -- So use 24 hours rule to calculate the first day and last day minutes.
       --
       hr_utility.set_location(l_proc, 72);
       l_first_day_minutes := convert_to_minutes(nvl(p_time_start,
                                                 l_normal_time_start),
                                                '24:00');
       l_last_day_minutes := convert_to_minutes('00:00', nvl(p_time_end,
                                              l_normal_time_end));

    end if;
    --
    -- Bug3093970 ends here.
    --
    l_same_day_minutes := convert_to_minutes(nvl(p_time_start,
                                              l_normal_time_start),
                                          nvl(p_time_end,
                                              l_normal_time_end));
    --2943479 changes start
    if l_normal_time_end = '23:59'
    then
       l_normal_day_minutes := l_normal_day_minutes +1;
       l_first_day_minutes := l_first_day_minutes +1;
       --3075512 changes start
       if (p_time_end is null or p_time_end = '') then
         l_last_day_minutes := l_last_day_minutes +1;
         l_same_day_minutes := l_same_day_minutes +1;
       end if;
       --3075512 changes end
    end if;
    --2943479 changes end

    hr_utility.trace('Normal Day Minutes: ' || to_char(l_normal_day_minutes));
    hr_utility.trace('First Day Minutes: ' || to_char(l_first_day_minutes));
    hr_utility.trace('Last Day Minutes: ' || to_char(l_last_day_minutes));
    hr_utility.trace('Same Day Minutes: ' || to_char(l_same_day_minutes));

    hr_utility.set_location(l_proc, 75);

    --
    -- Calculate the absence days.
    --
    l_absence_days := (p_date_end - p_date_start) + 1;

    hr_utility.trace('Absence Days: ' || to_char(l_absence_days));

    --
    -- Calculate the absence hours.
    --
    if l_absence_days = 1 then
      --
      -- The absence starts and ends on the same day.
      --
      l_absence_hours := l_same_day_minutes / 60;

    elsif l_absence_days = 2 then
      --
      -- The absence ends the day after another.
      --
      l_absence_hours := (l_first_day_minutes + l_last_day_minutes) / 60;

    else
      --
      -- The absence is n number of days.
      --
      l_absence_hours := (l_first_day_minutes + l_last_day_minutes +
                          ((l_absence_days - 2) * l_normal_day_minutes)) / 60;

    end if;

    hr_utility.set_location(l_proc, 80);

    --
    -- Check that the absence hours are not less than zero. This could
    -- happen if the entered start time is after the normal start time or
    -- the entered end time is after the normal end time.
    --
    If l_absence_hours < 0 then
      l_absence_hours := 0;
    end if;

    --
    -- Set the absence days and hours out parameters.
    --
    if l_hours_or_days = 'H' then
      -- Start of fix 3156665
      /* If the standard working hours is not defined at Assignment or
         Organization level, then system will take the default start time
         as 00:00 and end time as 23:59. Duration of this times will reach
         upto 23.983333' only. So if system is using default timings then
         rounding the calculated hours to get the default as 24 hours.
         Else rounding with 2 decimal places.
      */
      --
      --p_absence_hours := round(l_absence_hours,2);
      if p_time_start = '00:00' and p_time_end = '23:59' then
         p_absence_hours := round(l_absence_hours);
       else
         p_absence_hours := round(l_absence_hours,2);
      end if;
      -- End of fix 3156665
    elsif l_hours_or_days = 'D' then
      p_absence_days := round(l_absence_days,2);

    else
      p_absence_hours := round(l_absence_hours,2);
      p_absence_days := round(l_absence_days,2);

    end if;

  end if;

  END IF; -- Schedule based calculation not used

  hr_utility.set_location(' Leaving:'|| l_proc, 85);

exception

  when wrong_parameters then
    --
    -- The inputs / outputs of the Fast Formula are incorrect
    -- so raise an error.
    --
    hr_utility.set_location(l_proc, 90);

    hr_utility.set_message(800,'HR_34964_BAD_FF_DEFINITION');
    hr_utility.raise_error;

end calculate_absence_duration;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_person_id
  (p_absence_attendance_id in number
  ,p_person_id             in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date)
is

  --
  l_proc          varchar2(72)  :=  g_package||'chk_person_id';
  l_api_updating  boolean;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_person_id'
          ,p_argument_value => p_person_id
          );
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_business_group_id'
          ,p_argument_value => p_business_group_id
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.date_projected_start, hr_api.g_date)
    = nvl(p_date_projected_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_projected_end, hr_api.g_date)
    = nvl(p_date_projected_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)) then
     return;
  end if;

  --
  -- Check that the person exists and that their period of service
  -- is valid for the entire absence duration.
  --
  if not per_valid_for_absence
      (p_person_id            => p_person_id
      ,p_business_group_id    => p_business_group_id
      ,p_date_projected_start => p_date_projected_start
      ,p_date_projected_end   => p_date_projected_end
      ,p_date_start           => p_date_start
      ,p_date_end             => p_date_end)
  then

      fnd_message.set_name('PER', 'PER_7715_ABS_TERM_PROJ_DATE');
      fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_attendance_type_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the absence_attendance_type_id exists in
--    per_absence_attendance_types for the same business group and that it
--    is effective for the entire absence duration.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_business_group_id
--    p_absence_attendance_type_id
--    p_object_version_number
--
--  Post Success:
--    If absence_attendance_type_id exists and is valid,
--    processing continues.
--
--  Post Failure:
--    If absence_attendance_type_id is invalid,
--    an application error is raised and processing terminates.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_absence_attendance_type_id
 (p_absence_attendance_id      in  number
 ,p_absence_attendance_type_id in  number
 ,p_business_group_id          in  number
 ,p_object_version_number      in  number
 ,p_date_projected_start       in  date
 ,p_date_projected_end         in  date
 ,p_date_start                 in  date
 ,p_date_end                   in  date)
  is

  l_exists       varchar2(1);
  l_proc         varchar2(72)  :=  g_package||'chk_absence_attendance_type_id';
  l_api_updating boolean;
--

  cursor c_absence_within_type_dates is
  select null
  from   per_absence_attendance_types abt
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.business_group_id = p_business_group_id
  and   (p_date_projected_start is null or p_date_projected_start
         between abt.date_effective and nvl(abt.date_end,hr_api.g_eot))
  and   (p_date_projected_end is null or p_date_projected_end
         between abt.date_effective and nvl(abt.date_end,hr_api.g_eot))
  and   (p_date_start is null or p_date_start
         between abt.date_effective and nvl(abt.date_end,hr_api.g_eot))
  and   (p_date_end is null or p_date_end
         between abt.date_effective and nvl(abt.date_end,hr_api.g_eot));

--
begin

 hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_absence_attendance_type_id'
    ,p_argument_value => p_absence_attendance_type_id
    );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.date_projected_start, hr_api.g_date)
    = nvl(p_date_projected_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_projected_end, hr_api.g_date)
    = nvl(p_date_projected_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)) then
     return;
  end if;

  hr_utility.set_location(l_proc, 15);

  --
  -- Check that all the dates are within the effective dates of the
  -- absence type.
  --
  open  c_absence_within_type_dates;
  fetch c_absence_within_type_dates into l_exists;

  if c_absence_within_type_dates%notfound then
    fnd_message.set_name('PER', 'HR_6457_ABS_DET_DATES');
    fnd_message.raise_error;
  end if;

  close c_absence_within_type_dates;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_absence_attendance_type_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_abs_attendance_reason_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an abs_attendance_reason_id exists in table
--    per_abs_attendance_reasons, also valid in hr_lookups
--    where lookup_type is 'ABSENCE_REASON' and enabled_flag is 'Y'
--    and effective_date is between the active dates (if they are not null).
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_abs_attendance_reason_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    If a row does exist; processing continues.
--
--  Post Failure:
--    If a row does not exist in per_abs_attendance_reason and hr_lookups for
--    a given reason id then an error will be raised and processing terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_abs_attendance_reason_id
  (p_absence_attendance_id      in number
  ,p_absence_attendance_type_id in number
  ,p_abs_attendance_reason_id   in number
  ,p_business_group_id          in number
  ,p_object_version_number      in number
  ,p_effective_date             in date
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_abs_attendance_reason_id';
  --
  l_api_updating      boolean;
  l_business_group_id number;
  --
  cursor csr_valid_abs_reason is
     select null
     from   per_abs_attendance_reasons abr,
            hr_lookups hrl
     where  abr.business_group_id = p_business_group_id
     and    abr.absence_attendance_type_id = p_absence_attendance_type_id
     and    abr.abs_attendance_reason_id = p_abs_attendance_reason_id
     and    abr.name = hrl.lookup_code
     and    hrl.lookup_type = 'ABSENCE_REASON'
     and    p_effective_date between
                 nvl(hrl.start_date_active,hr_api.g_sot)
                 and nvl(hrl.end_date_active,hr_api.g_eot)
     and    hrl.enabled_flag = 'Y';
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_abs_attendance_reason_id is null then
     return;
  end if;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for abs_attendance_reason_id has changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating and nvl(per_abs_shd.g_old_rec.abs_attendance_reason_id,
     hr_api.g_number) = nvl(p_abs_attendance_reason_id, hr_api.g_number)) then
     return;
  end if;

  open csr_valid_abs_reason;
  fetch csr_valid_abs_reason into l_exists;
  if csr_valid_abs_reason%notfound then
      --
      fnd_message.set_name('PER', 'PER_52749_ABS_REASON_INVALID');
      fnd_message.raise_error;
      --
  end if;
  close csr_valid_abs_reason;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_abs_attendance_reason_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_period old>---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the projected dates, actual dates, times and the duration.
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_projected_start
--    p_time_projected_start
--    p_date_projected_end
--    p_time_projected_end
--    p_date_start
--    p_time_start
--    p_date_end
--    p_time_end
--
--  In Out Arguments:
--    p_absence_days
--    p_absence_hours
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    IF validation fails, the appropriate error or warning is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}

procedure chk_absence_period
  (p_absence_attendance_id      in     number
  ,p_absence_attendance_type_id in     number
  ,p_business_group_id          in     number
  ,p_object_version_number      in     number
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_date_projected_start       in     date
  ,p_time_projected_start       in     varchar2
  ,p_date_projected_end         in     date
  ,p_time_projected_end         in     varchar2
  ,p_date_start                 in     date
  ,p_time_start                 in     varchar2
  ,p_date_end                   in     date
  ,p_time_end                   in     varchar2
  ,p_absence_days               in out nocopy number
  ,p_absence_hours              in out nocopy number
  ,p_dur_dys_less_warning       out nocopy    boolean
  ,p_dur_hrs_less_warning       out nocopy    boolean
  ,p_exceeds_pto_entit_warning  out nocopy    boolean
  ,p_exceeds_run_total_warning  out nocopy    boolean
  ,p_abs_overlap_warning        out nocopy    boolean
  ,p_abs_day_after_warning      out nocopy    boolean
  ,p_dur_overwritten_warning    out nocopy    boolean)
is

   --
  l_proc   varchar2(72)  :=  g_package||'chk_absence_period';
  l_api_updating             boolean;
  l_exists                   varchar2(1);
  l_hours_or_days            varchar2(1);
  l_increasing_or_decreasing varchar2(1);
  l_absence_days             number;
  l_absence_hours            number;
  l_use_formula              boolean;
  l_auto_overwrite           varchar(30);
  l_assignment_id            number;
  l_payroll_id               number;
  l_accrual_plan_id          number;
  l_dummy_date               date;
  l_dummy_number             number;
  l_net_entitlement          number;
  l_accrual_msg              boolean;
  l_running_total_hours      number;
  l_running_total_days       number;
  l_year_to_date_hours       number;
  l_year_to_date_days        number;
  l_absence_overlap_flag     varchar2(1);
  --
  -- ************* Added for Bug 272978 *************
  -- ********* Added for AU,NZ by APAC team *********
  l_legislation_code varchar2(3);
  l_apac_dummy_number number;
  l_apac_entitlement number;
  l_apac_accrual number;

  cursor csr_legislation(p_business_group_id number) is
  select pbg.legislation_code
  from   per_business_groups pbg
  where  pbg.business_group_id = p_business_group_id;

  -- ********* End Bug 272978 *************

  -- fix for the bug 8492746 starts here
  l_dur_ent_hours number;
  l_dur_calc_hours number;
  -- fix for the bug 8492746 ends here


begin

  hr_utility.set_location('Entering: old'|| l_proc, 5);

  --
   chk_absence_period
    (p_absence_attendance_id      => p_absence_attendance_id
    ,p_absence_attendance_type_id => p_absence_attendance_type_id
    ,p_business_group_id          => p_business_group_id
    ,p_object_version_number      => p_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_person_id                  => p_person_id
    ,p_date_projected_start       => p_date_projected_start
    ,p_time_projected_start       => p_time_projected_start
    ,p_date_projected_end         => p_date_projected_end
    ,p_time_projected_end         => p_time_projected_end
    ,p_date_start                 => p_date_start
    ,p_time_start                 => p_time_start
    ,p_date_end                   => p_date_end
    ,p_time_end                   => p_time_end
    ,p_ABS_INFORMATION_CATEGORY   => NULL
,p_ABS_INFORMATION1          => NULL
,p_ABS_INFORMATION2          => NULL
,p_ABS_INFORMATION3          => NULL
,p_ABS_INFORMATION4          => NULL
,p_ABS_INFORMATION5          => NULL
,p_ABS_INFORMATION6          => NULL
    ,p_absence_days               => per_abs_shd.g_absence_days
    ,p_absence_hours              => per_abs_shd.g_absence_hours
    ,p_dur_dys_less_warning       => p_dur_dys_less_warning
    ,p_dur_hrs_less_warning       => p_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning  => p_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning  => p_exceeds_run_total_warning
    ,p_abs_overlap_warning        => p_abs_overlap_warning
    ,p_abs_day_after_warning      => p_abs_day_after_warning
    ,p_dur_overwritten_warning    => p_dur_overwritten_warning);



  hr_utility.set_location('Leaving old:'|| l_proc, 5);
end;
--  ---------------------------------------------------------------------------
--  |-----------------<  chk_absence_period -new >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the projected dates, actual dates, times and the duration.
--
--  Pre-conditions:
--    absence_attendance_type_id must be valid.
--    business_group_id must be valid.
--    effective_date must be valid.
--
--  In Arguments:
--    p_absence_attendance_id
--    p_absence_attendance_type_id
--    p_business_group_id
--    p_object_version_number
--    p_effective_date
--    p_person_id
--    p_date_projected_start
--    p_time_projected_start
--    p_date_projected_end
--    p_time_projected_end
--    p_date_start
--    p_time_start
--    p_date_end
--    p_time_end
--    p_ABS_INFORMATION_CATEGORY
--    p_ABS_INFORMATION1
--    p_ABS_INFORMATION2
--    p_ABS_INFORMATION3
--    p_ABS_INFORMATION4
--    p_ABS_INFORMATION5
--    p_ABS_INFORMATION6
--
--  In Out Arguments:
--    p_absence_days
--    p_absence_hours
--
--  Post Success:
--    If validation passes, processing continues.
--
--  Post Failure:
--    IF validation fails, the appropriate error or warning is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_absence_period
  (p_absence_attendance_id      in     number
  ,p_absence_attendance_type_id in     number
  ,p_business_group_id          in     number
  ,p_object_version_number      in     number
  ,p_effective_date             in     date
  ,p_person_id                  in     number
  ,p_date_projected_start       in     date
  ,p_time_projected_start       in     varchar2
  ,p_date_projected_end         in     date
  ,p_time_projected_end         in     varchar2
  ,p_date_start                 in     date
  ,p_time_start                 in     varchar2
  ,p_date_end                   in     date
  ,p_time_end                   in     varchar2
  ,p_ABS_INFORMATION_CATEGORY   in varchar2
 ,p_ABS_INFORMATION1          in varchar2
 ,p_ABS_INFORMATION2          in varchar2
 ,p_ABS_INFORMATION3          in varchar2
 ,p_ABS_INFORMATION4          in varchar2
 ,p_ABS_INFORMATION5          in varchar2
 ,p_ABS_INFORMATION6          in varchar2
  ,p_absence_days               in out nocopy number
  ,p_absence_hours              in out nocopy number
  ,p_dur_dys_less_warning       out nocopy    boolean
  ,p_dur_hrs_less_warning       out nocopy    boolean
  ,p_exceeds_pto_entit_warning  out nocopy    boolean
  ,p_exceeds_run_total_warning  out nocopy    boolean
  ,p_abs_overlap_warning        out nocopy    boolean
  ,p_abs_day_after_warning      out nocopy    boolean
  ,p_dur_overwritten_warning    out nocopy    boolean)
is

  cursor c_get_absence_type_info is
  select abt.hours_or_days,
         abt.increasing_or_decreasing_flag,
         abt.absence_overlap_flag
  from   per_absence_attendance_types abt
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id;

  cursor c_abs_overlap_another is
  select null
  from   per_absence_attendances abs
  where  abs.person_id = p_person_id
  and   (p_absence_attendance_id is null or
         p_absence_attendance_id <> abs.absence_attendance_id)
  and    abs.date_start is not null
  and    p_date_start is not null
  and   ((
        to_date(to_char(nvl(abs.date_start,hr_api.g_eot),'YYYY-MM-DD')|| ' ' || -- Bug 4163165
          nvl(abs.time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
        between
          to_date(to_char(nvl(p_date_start,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
          nvl(p_time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
        AND
          to_date(to_char(nvl(p_date_end,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
          nvl(p_time_end,'23:59'),'YYYY-MM-DD HH24:MI:SS')) OR
       (
       to_date(to_char(nvl(p_date_start,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
         nvl(p_time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
       between
         to_date(to_char(nvl(abs.date_start,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
         nvl(abs.time_start,'00:00'),'YYYY-MM-DD HH24:MI:SS')
       AND
         to_date(to_char(nvl(abs.date_end,hr_api.g_eot),'YYYY-MM-DD')|| ' ' ||
         nvl(abs.time_end,'23:59'),'YYYY-MM-DD HH24:MI:SS')
       ));

  cursor c_abs_day_after_another is
  select null
  from   per_absence_attendances abs,
         per_absence_attendance_types abt
  where  abs.person_id = p_person_id
  and    abs.absence_attendance_type_id = abt.absence_attendance_type_id
  and   (p_absence_attendance_id is null or
         p_absence_attendance_id <> abs.absence_attendance_id)
  and    abs.date_end = p_date_end -1
  and    abt.absence_category = 'S';

  cursor c_get_accrual_plans (p_assignment_id in number) is
  select pap.accrual_plan_id, asg.payroll_id
  from   pay_element_entries_f pee,
         pay_element_links_f pel,
         pay_element_types_f pet,
         pay_input_values_f piv,
         per_all_assignments_f asg,
         per_absence_attendance_types abt,
         pay_accrual_plans pap
  where  abt.absence_attendance_type_id = p_absence_attendance_type_id
  and    abt.input_value_id = piv.input_value_id
  and    piv.input_value_id = pap.pto_input_value_id
  and    asg.assignment_id = p_assignment_id
  and    pee.assignment_id = asg.assignment_id
  and    pee.element_link_id = pel.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pet.element_type_id = pap.accrual_plan_element_type_id
  and    p_effective_date between asg.effective_start_date and
                                  asg.effective_end_date
  and    p_effective_date between pee.effective_start_date and
                                  pee.effective_end_date
  and    p_effective_date between pel.effective_start_date and
                                  pel.effective_end_date
  and    p_effective_date between pet.effective_start_date and
                                  pet.effective_end_date
  and    p_effective_date between piv.effective_start_date and
                                  piv.effective_end_date;

  --

  -- code change for ER 7688779 starts here

  cursor csr_get_abs_type_name is
  select abtl.name from PER_ABS_ATTENDANCE_TYPES_TL abtl
  where abtl.absence_attendance_type_id = p_absence_attendance_type_id
  and abtl.language = userenv('LANG');

  p_abs_type_name varchar2(30);

  -- code change for ER 7688779 ends here

  l_proc   varchar2(72)  :=  g_package||'chk_absence_period';
  l_api_updating             boolean;
  l_exists                   varchar2(1);
  l_hours_or_days            varchar2(1);
  l_increasing_or_decreasing varchar2(1);
  l_absence_days             number;
  l_absence_hours            number;
  l_use_formula              boolean;
  l_auto_overwrite           varchar(30);
  l_assignment_id            number;
  l_payroll_id               number;
  l_accrual_plan_id          number;
  l_dummy_date               date;
  l_dummy_number             number;
  l_net_entitlement          number;
  l_accrual_msg              boolean;
  l_running_total_hours      number;
  l_running_total_days       number;
  l_year_to_date_hours       number;
  l_year_to_date_days        number;
  l_absence_overlap_flag     varchar2(1);
  --
  -- ************* Added for Bug 272978 *************
  -- ********* Added for AU,NZ by APAC team *********
  l_legislation_code varchar2(3);
  l_apac_dummy_number number;
  l_apac_entitlement number;
  l_apac_accrual number;

  cursor csr_legislation(p_business_group_id number) is
  select pbg.legislation_code
  from   per_business_groups pbg
  where  pbg.business_group_id = p_business_group_id;

  -- ********* End Bug 272978 *************

  -- fix for the bug 8492746 starts here
  l_dur_ent_hours number;
  l_dur_calc_hours number;
  -- fix for the bug 8492746 ends here


begin

  hr_utility.set_location('Entering:'|| l_proc, 5);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date and time values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.date_projected_start, hr_api.g_date)
    = nvl(p_date_projected_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_projected_start, hr_api.g_varchar2)
    = nvl(p_time_projected_start, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.date_projected_end, hr_api.g_date)
    = nvl(p_date_projected_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_projected_end, hr_api.g_varchar2)
    = nvl(p_time_projected_end, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_start, hr_api.g_varchar2)
    = nvl(p_time_start, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.time_end, hr_api.g_varchar2)
    = nvl(p_time_end, hr_api.g_varchar2)
  and nvl(per_abs_shd.g_old_rec.absence_days, hr_api.g_number)
    = nvl(p_absence_days, hr_api.g_number)
  and nvl(per_abs_shd.g_old_rec.absence_hours, hr_api.g_number)
    = nvl(p_absence_hours, hr_api.g_number)) then
     return;
  end if;

  --
  -- Initialise the warning messages to false.
  --
  p_dur_dys_less_warning       := FALSE;
  p_dur_hrs_less_warning       := FALSE;
  p_exceeds_pto_entit_warning  := FALSE;
  p_exceeds_run_total_warning  := FALSE;
  p_abs_overlap_warning        := FALSE;
  p_abs_day_after_warning      := FALSE;
  p_dur_overwritten_warning    := FALSE;

  --
  -- Get the absence type values for use later.
  --
  open  c_get_absence_type_info;
  fetch c_get_absence_type_info into l_hours_or_days,
                                     l_increasing_or_decreasing,
                                     l_absence_overlap_flag;
  close c_get_absence_type_info;

  hr_utility.set_location(l_proc, 10);

  --
  -- Check the time formats
  --
  chk_time_format (p_time => p_time_projected_start);
  chk_time_format (p_time => p_time_projected_end);
  chk_time_format (p_time => p_time_start);
  chk_time_format (p_time => p_time_end);

  --
  -- Check that the start dates are entered if the end dates are entered.
  --
  if (p_date_projected_start is null and p_date_projected_end is not null)
  or (p_date_start is null and p_date_end is not null) then
    fnd_message.set_name('PER','HR_289294_ABS_SD_NOT_ENTERED');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc, 15);

  --
  -- Check that the end dates are after the start dates. If they are the same
  -- day, check that the end time is after the start time.
  --
  if p_date_projected_end < p_date_projected_start then
    fnd_message.set_name('PER','PAY_7617_EMP_ABS_DATE_AFTER');
    fnd_message.raise_error;

  elsif p_date_end < p_date_start then
    fnd_message.set_name('PER','PAY_7616_EMP_ABS_DATE_AFTER');
    fnd_message.raise_error;

  elsif p_date_projected_end = p_date_projected_start
  and   p_time_projected_end < p_time_projected_start then
    fnd_message.set_name('PER','PER_7619_EMP_ABS_END_TIME');
    fnd_message.raise_error;

  elsif p_date_end = p_date_start
  and   p_time_end < p_time_start then
    fnd_message.set_name('PER','PER_7618_EMP_ABS_END_TIME');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(l_proc, 20);

  --
  -- Check that times have / have not been entered depending on the
  -- UOM of the absence type.
  --
  if l_hours_or_days = 'D' and
   (p_time_projected_start is not null or
    p_time_projected_end is not null or
    p_time_start is not null or
    p_time_end is not null) then
     --
     -- Times should not have been entered.
     --
     fnd_message.set_name('PER','HR_289299_ABS_TIME_DISALLOWED');
     fnd_message.raise_error;

  else
     --
     -- The unit of measure is either just hours or both days and hours
     -- so check that the times have only been entered when the dates have.
     --
     if p_time_projected_start is not null
     and p_date_projected_start is null then
       fnd_message.set_name('PER','HR_289297_ABS_PROJ_START_DATE'); -- Fix 2647747
       fnd_message.raise_error;

     elsif p_time_projected_end is not null
     and p_date_projected_end is null then
       fnd_message.set_name('PER','PER_7621_EMP_ABS_END_TIME');
       fnd_message.raise_error;

     elsif p_time_start is not null and p_date_start is null then
       fnd_message.set_name('PER','PER_7143_EMP_ABS_START_TIME');
       fnd_message.raise_error;

     elsif p_time_end is not null and p_date_end is null then
       fnd_message.set_name('PER','PER_7620_EMP_ABS_END_TIME');
       fnd_message.raise_error;

     end if;

  end if;

  hr_utility.set_location(l_proc, 25);

  --
  -- If the end date is entered, the duration in days and / or hours
  -- must be entered. This can be calculated automatically in some
  -- circumstances.
  --
  if p_date_end is not null then
    --
    -- Calculate the absence duration.
    --
    calculate_absence_duration
       (p_absence_attendance_id      => p_absence_attendance_id
       ,p_absence_attendance_type_id => p_absence_attendance_type_id
       ,p_business_group_id          => p_business_group_id
       ,p_object_version_number      => p_object_version_number
       ,p_effective_date             => p_effective_date
       ,p_person_id                  => p_person_id
       ,p_date_start                 => p_date_start
       ,p_date_end                   => p_date_end
       ,p_time_start                 => p_time_start
       ,p_time_end                   => p_time_end
       ,p_ABS_INFORMATION_CATEGORY   =>  p_ABS_INFORMATION_CATEGORY
	,p_ABS_INFORMATION1          => p_ABS_INFORMATION1
	,p_ABS_INFORMATION2          => p_ABS_INFORMATION2
	,p_ABS_INFORMATION3          => p_ABS_INFORMATION3
	,p_ABS_INFORMATION4          => p_ABS_INFORMATION4
	,p_ABS_INFORMATION5          => p_ABS_INFORMATION5
	,p_ABS_INFORMATION6          => p_ABS_INFORMATION6
       ,p_absence_days               => l_absence_days
       ,p_absence_hours              => l_absence_hours
       ,p_use_formula                => l_use_formula);

    hr_utility.trace ('Calc dys: '||to_char(l_absence_days));
    hr_utility.trace ('Calc hrs: '||to_char(l_absence_hours));

    --
    -- The absence duration is only set if the results returned are
    -- from the Fast Formula and the durations are null or
    -- auto-overwrite is set to Yes.
    --
    l_auto_overwrite :=
     nvl(fnd_profile.value('PER_ABSENCE_DURATION_AUTO_OVERWRITE'),'N');

    hr_utility.set_location(l_proc, 30);

    If (l_use_formula)
     and ((l_auto_overwrite = 'Y') or
          (p_absence_days is null and p_absence_hours is null)) then
      --
      -- Set the absence duration in days and hours. If the UOM is set
      -- to days, only days are populated, if the UOM is hours, only
      -- hours are populated and if no UOM is set, both days and hours
      -- are set.
      --

      hr_utility.trace ('Use Formula = TRUE');

      p_absence_days            := l_absence_days;
      p_absence_hours           := l_absence_hours;
      p_dur_overwritten_warning := TRUE;

    end if;

    hr_utility.set_location(l_proc, 35);


    --
    -- Check that the duration days and / or hours have been entered if the
    -- element type is not recurring (recurring entries do not have an
    -- input value so do not require the duration days / hours).
    --
    if hr_person_absence_api.get_processing_type
    (p_absence_attendance_type_id) <> 'R' then

      if l_hours_or_days = 'D' then
         --
         -- The UOM is Days so the days duration should be entered, but not
         -- the hours duration.
         --
         if p_absence_days is null then
           fnd_message.set_name('PER','HR_51059_ABS_DUR_NOT_ENTERED');
           fnd_message.raise_error;

         elsif p_absence_hours is not null then
           fnd_message.set_name('PER','HR_289298_ABS_HRS_DISALLOWED');
           fnd_message.raise_error;

         end if;

      elsif l_hours_or_days = 'H' then
         --
         -- The UOM is Hours so the hours duration should be entered, but not
         -- the days duration.
         --
        if p_absence_hours is null then
          fnd_message.set_name('PER','HR_51059_ABS_DUR_NOT_ENTERED');
          fnd_message.raise_error;

        elsif p_absence_days is not null then
          fnd_message.set_name('PER','HR_289300_ABS_DYS_DISALLOWED');
          fnd_message.raise_error;

        end if;

      else
         --
         -- No UOM is set so either days or hours can be entered (or both).
         --
        if p_absence_hours is null and p_absence_days is null then
          fnd_message.set_name('PER','HR_51059_ABS_DUR_NOT_ENTERED');
          fnd_message.raise_error;
        end if;

      end if;

    end if;

  end if;

  hr_utility.set_location(l_proc, 40);

  -- fix for the bug 8492746 starts here

  l_dur_ent_hours := nvl(p_absence_hours,l_absence_hours);

  l_dur_calc_hours := (fffunc.days_between(p_date_end,p_date_start)+1)*24;

  if (l_dur_ent_hours > l_dur_calc_hours)
  then

  fnd_message.set_name('PER','PER_449852_ABS_HOUR_DUR');
  hr_utility.set_message_token('START', p_date_start);
  hr_utility.set_message_token('END', p_date_end);
  fnd_message.raise_error;

  end if;

  -- fix for the bug 8492746 ends here

  --
  -- Check that the dates and / or times have been entered if the duration
  -- has been entered.
  --
  if p_absence_days is not null
  and (p_date_start is null or p_date_end is null) then
    fnd_message.set_name('PER','PER_7714_ABS_CALC_DURATION');
    fnd_message.raise_error;
/*
  elsif p_absence_hours is not null
  and (p_time_start is null or p_time_end is null) then
    fnd_message.set_name('PER','PER_7145_EMP_ABS_UNPAID_HOURS');
    fnd_message.raise_error;
*/
  end if;

  hr_utility.set_location(l_proc, 45);

  --
  -- Check if the absence duration in days differs from
  -- the amount of time absent.
  --
  if (p_absence_days <> l_absence_days) then
    --
    -- Set the warning message.
    --
    p_dur_dys_less_warning := TRUE;


 -- Commented as a fix for the bug 4606467
 /*
  elsif p_absence_days > l_absence_days then
    --
    -- Raise the error message.  The duration cannot be greater than
    -- the system calculated duration.
    --
    fnd_message.set_name('PER','PER_7622_EMP_ABS_LONG_DURATION');
    fnd_message.raise_error;*/

  end if;

  --
  -- Check if the absence duration in hours differs from
  -- the amount of time absent.
  --
  if (p_absence_hours <> l_absence_hours) then
    --
    -- Set the warning message.
    --
    p_dur_hrs_less_warning := TRUE;


-- Commented as a fix for the bug 4606467
/*  elsif p_absence_hours > l_absence_hours then
    --
    -- Raise the error message.  The duration cannot be greater than
    -- the system calculated duration.
    --
    fnd_message.set_name('PER','PER_7623_EMP_ABS_LONG_DURATION');
    fnd_message.raise_error;*/

  end if;

  hr_utility.set_location(l_proc, 50);

  --
  -- Check if this absence exceeds the net entitlement on any of the
  -- employee's accrual plans.  First the assignment id and plan id(s)
  -- are required.
  --
  if p_absence_days is not null or p_absence_hours is not null then

    l_assignment_id := hr_person_absence_api.get_primary_assignment
       (p_person_id      => p_person_id
       ,p_effective_date => p_effective_date);

    declare

      l_message_text fnd_new_messages.message_text%TYPE;

    begin

      open c_get_accrual_plans (l_assignment_id);
      loop

        fetch c_get_accrual_plans into l_accrual_plan_id, l_payroll_id;
        exit when c_get_accrual_plans%notfound;

        --
        -- Get the net entitlement of each plan.
        --

        -- ****************** Added for Bug 2729784 ***************
        -- ************** Added for AU,NZ by APAC team ************

        open csr_legislation(p_business_group_id);
        fetch csr_legislation into l_legislation_code;
        if csr_legislation%notfound
        then
          close csr_legislation;
          --
          -- The primary key is invalid therefore we must error
          --
          fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
          fnd_message.raise_error;
        end if;
        close csr_legislation;

        if l_legislation_code = 'AU'
        then
          hr_utility.set_location('APAC code - '||l_proc,52);
          l_net_entitlement := hr_au_holidays.get_net_accrual
                                 (p_assignment_id        => l_assignment_id
                                 ,p_payroll_id           => l_payroll_id
                                 ,p_business_group_id    => p_business_group_id
                                 ,p_plan_id              => l_accrual_plan_id
                                 ,p_calculation_date     => nvl(p_date_start, p_effective_date)
                                 );
        elsif l_legislation_code = 'NZ'
        then
          hr_utility.set_location(l_proc,53);
          l_net_entitlement := hr_nz_holidays.get_net_accrual
                                 (p_assignment_id        => l_assignment_id
                                 ,p_payroll_id           => l_payroll_id
                                 ,p_business_group_id    => p_business_group_id
                                 ,p_plan_id              => l_accrual_plan_id
                                 ,p_calculation_date     => nvl(p_date_start, p_effective_date)
                                 );

        else
          hr_utility.set_location('APAC code - '||l_proc,54);
          -- ********** existing code wrapped by if statement from bug 2729784 *************
          per_accrual_calc_functions.get_net_accrual
           (p_assignment_id         => l_assignment_id
           ,p_plan_id               => l_accrual_plan_id
           ,p_payroll_id            => l_payroll_id
           ,p_business_group_id     => p_business_group_id
           ,p_calculation_date      => nvl(p_date_start, p_effective_date)
           ,p_start_date            => l_dummy_date
           ,p_end_date              => l_dummy_date
           ,p_accrual_end_date      => l_dummy_date
           ,p_accrual               => l_dummy_number
           ,p_net_entitlement       => l_net_entitlement);
          -- ********** end existing code ***************

        end if;
        hr_utility.trace('Ent = '||to_char(l_net_entitlement));

        -- ****************** End Bug 2729784 *********************



        --
        -- The duration value in g_old_rec is first added to the net
        -- entitlement. This prevents absence records that are being
        -- updated from being double counted (get_net_accrual has already
        -- included the absence in the calculation of the net entitlement).
        --
        if l_hours_or_days = 'H' then
          l_net_entitlement := l_net_entitlement
                               + nvl(per_abs_shd.g_old_rec.absence_hours, 0)
                               - p_absence_hours;

        elsif l_hours_or_days = 'D' then
          l_net_entitlement := l_net_entitlement
                               + nvl(per_abs_shd.g_old_rec.absence_days, 0)
                               - p_absence_days;
        end if;

        --
        -- Check if the new net entitlement is less than zero.
        --
        if l_net_entitlement < 0 then
          --
          -- Instead of raising the message here, the boolean value is set.
          -- This prevents the message appearing multiple times.
          --
          l_accrual_msg := TRUE;
        end if;

      end loop;
      close c_get_accrual_plans;

    exception

      when others then

        l_message_text := fnd_message.get;
        hr_utility.trace('Unable to execute the PTO formula.  '||l_message_text);

    end;

    if (l_accrual_msg) then
    -- code change for 7688779  starts here
	if (nvl(fnd_profile.value('HR_ALLOW_NEG_ABS_BAL'),'Y') = 'N') then

		open csr_get_abs_type_name;
		fetch csr_get_abs_type_name into p_abs_type_name;
		close csr_get_abs_type_name;

		fnd_message.set_name('PER','PER_449875_ABS_NEGBAL');
		fnd_message.set_token('ABSTYPE',p_abs_type_name);
		fnd_message.raise_error;
	else

		p_exceeds_pto_entit_warning := TRUE;
	end if;
       -- code change for 7688779  ends here
    end if;

  end if;

  hr_utility.set_location(l_proc, 55);

  --
  -- Get the running totals and check that the values do not
  -- decrease to less than zero.
  --
  get_running_totals
     (p_person_id                  => p_person_id
     ,p_absence_attendance_type_id => p_absence_attendance_type_id
     ,p_effective_date             => p_effective_date
     ,p_running_total_hours        => l_running_total_hours
     ,p_running_total_days         => l_running_total_days
     ,p_year_to_date_hours         => l_year_to_date_hours
     ,p_year_to_date_days          => l_year_to_date_days);

  --
  -- Here the value of g_old_rec is subtracted first. This prevents
  -- records already included in l_running_total_hours / days
  -- being double counted (this would occur during update only).
  --
  if l_increasing_or_decreasing = 'D'
  and (l_running_total_hours +
       nvl(per_abs_shd.g_old_rec.absence_hours, 0) - p_absence_hours < 0
   or  l_running_total_days +
       nvl(per_abs_shd.g_old_rec.absence_days, 0) - p_absence_days < 0)
  then

    -- code change for 7688779  starts here
	if (nvl(fnd_profile.value('HR_ALLOW_NEG_ABS_BAL'),'Y') = 'N') then

		open csr_get_abs_type_name;
		fetch csr_get_abs_type_name into p_abs_type_name;
		close csr_get_abs_type_name;

		fnd_message.set_name('PER','PER_449875_ABS_NEGBAL');
		fnd_message.set_token('ABSTYPE',p_abs_type_name);
		fnd_message.raise_error;
	else

		p_exceeds_run_total_warning := TRUE;
	end if;
       -- code change for 7688779  ends here

    hr_utility.set_location(l_proc, 57);

  end if;

  hr_utility.set_location(l_proc, 60);

  --
  -- Check if this absence overlaps another absence for the same person.
  --
  open  c_abs_overlap_another;
  fetch c_abs_overlap_another into l_exists;

  if c_abs_overlap_another%found then
  if nvl(l_absence_overlap_flag,'N') = 'N' then  -- bug 8269612
    --
    -- Set the warning message
    --
    p_abs_overlap_warning := TRUE;

  end if;
  end if;

  hr_utility.set_location(l_proc, 65);

  --
  -- Check if this is a sickness absence that starts the day after another
  -- sickness absence for this person.
  --
  open  c_abs_day_after_another;
  fetch c_abs_day_after_another into l_exists;

  if c_abs_day_after_another%found then
    --
    -- Set the warning message
    --
    p_abs_day_after_warning := TRUE;

  end if;

  --
  hr_utility.set_location('Leaving:'|| l_proc, 70);

end chk_absence_period;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_replacement_person_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_replacement_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_replacement_person_id
  (p_absence_attendance_id in number
  ,p_replacement_person_id in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date)
is

  --
  l_proc          varchar2(72)  :=  g_package||'chk_replacement_person_id';
  l_api_updating  boolean;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_business_group_id'
          ,p_argument_value => p_business_group_id
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.replacement_person_id, hr_api.g_number)
    = nvl(p_replacement_person_id, hr_api.g_number)
  and nvl(per_abs_shd.g_old_rec.date_projected_start, hr_api.g_date)
    = nvl(p_date_projected_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_projected_end, hr_api.g_date)
    = nvl(p_date_projected_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)) then
     return;
  end if;

  if p_replacement_person_id is not null then
    --
    -- Check that the replacement exists and that their period of service
    -- is valid for the entire absence duration.
    --
    if not per_valid_for_absence
        (p_person_id            => p_replacement_person_id
        ,p_business_group_id    => p_business_group_id
        ,p_date_projected_start => p_date_projected_start
        ,p_date_projected_end   => p_date_projected_end
        ,p_date_start           => p_date_start
        ,p_date_end             => p_date_end)
    then

      fnd_message.set_name('PER', 'HR_7553_ASS_REP_INVALID');
      fnd_message.raise_error;

    end if;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_replacement_person_id;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_authorising_person_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the person exists, that they have a valid period of
--    service and that they match the business group id being passed.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_absence_attendance_id
--    p_replacement_person_id
--    p_business_group_id
--
--  Post Success:
--    If the person and their period of service are valid, processing
--    continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_authorising_person_id
  (p_absence_attendance_id in number
  ,p_authorising_person_id in number
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ,p_date_projected_start  in date
  ,p_date_projected_end    in date
  ,p_date_start            in date
  ,p_date_end              in date)
is

  --
  l_proc          varchar2(72)  :=  g_package||'chk_authorising_person_id';
  l_api_updating  boolean;
  --

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_business_group_id'
          ,p_argument_value => p_business_group_id
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_abs_shd.api_updating
         (p_absence_attendance_id  => p_absence_attendance_id
         ,p_object_version_number  => p_object_version_number);
  --
  if (l_api_updating
  and nvl(per_abs_shd.g_old_rec.authorising_person_id, hr_api.g_number)
    = nvl(p_authorising_person_id, hr_api.g_number)
  and nvl(per_abs_shd.g_old_rec.date_projected_start, hr_api.g_date)
    = nvl(p_date_projected_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_projected_end, hr_api.g_date)
    = nvl(p_date_projected_end, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_start, hr_api.g_date)
    = nvl(p_date_start, hr_api.g_date)
  and nvl(per_abs_shd.g_old_rec.date_end, hr_api.g_date)
    = nvl(p_date_end, hr_api.g_date)) then
     return;
  end if;

  if p_authorising_person_id is not null then
    --
    -- Check that the authorisor exists and that their period of service
    -- is valid for the entire absence duration.
    --
    if not per_valid_for_absence
        (p_person_id            => p_authorising_person_id
        ,p_business_group_id    => p_business_group_id
        ,p_date_projected_start => p_date_projected_start
        ,p_date_projected_end   => p_date_projected_end
        ,p_date_start           => p_date_start
        ,p_date_end             => p_date_end)
    then

        fnd_message.set_name('PER', 'HR_7552_ASS_AUTH_INVALID');
        fnd_message.raise_error;

    end if;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_authorising_person_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_absence_attendance_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_absence_attendances abs
     where abs.absence_attendance_id = p_absence_attendance_id
       and pbg.business_group_id = abs.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'absence_attendance_id'
    ,p_argument_value     => p_absence_attendance_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_absence_attendance_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_absence_attendances abs
     where abs.absence_attendance_id = p_absence_attendance_id
       and pbg.business_group_id = abs.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'absence_attendance_id'
    ,p_argument_value     => p_absence_attendance_id
    );
  --
  if ( nvl(per_abs_bus.g_absence_attendance_id, hr_api.g_number)
       = p_absence_attendance_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_abs_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_abs_bus.g_absence_attendance_id:= p_absence_attendance_id;
    per_abs_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec in per_abs_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_attendance_id is not null)  and (
    nvl(per_abs_shd.g_old_rec.abs_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information_category, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information1, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information1, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information2, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information2, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information3, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information3, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information4, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information4, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information5, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information5, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information6, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information6, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information7, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information7, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information8, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information8, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information9, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information9, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information10, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information10, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information11, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information11, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information12, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information12, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information13, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information13, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information14, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information14, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information15, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information15, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information16, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information16, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information17, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information17, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information18, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information18, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information19, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information19, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information20, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information20, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information21, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information21, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information22, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information22, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information23, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information23, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information24, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information24, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information25, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information25, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information26, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information26, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information27, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information27, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information28, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information28, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information29, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information29, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.abs_information30, hr_api.g_varchar2) <>
    nvl(p_rec.abs_information30, hr_api.g_varchar2) ))
    or (p_rec.absence_attendance_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ABS_DEVELOPER_DF'
      ,p_attribute_category              => p_rec.abs_information_category
      ,p_attribute1_name                 => 'ABS_INFORMATION1'
      ,p_attribute1_value                => p_rec.abs_information1
      ,p_attribute2_name                 => 'ABS_INFORMATION2'
      ,p_attribute2_value                => p_rec.abs_information2
      ,p_attribute3_name                 => 'ABS_INFORMATION3'
      ,p_attribute3_value                => p_rec.abs_information3
      ,p_attribute4_name                 => 'ABS_INFORMATION4'
      ,p_attribute4_value                => p_rec.abs_information4
      ,p_attribute5_name                 => 'ABS_INFORMATION5'
      ,p_attribute5_value                => p_rec.abs_information5
      ,p_attribute6_name                 => 'ABS_INFORMATION6'
      ,p_attribute6_value                => p_rec.abs_information6
      ,p_attribute7_name                 => 'ABS_INFORMATION7'
      ,p_attribute7_value                => p_rec.abs_information7
      ,p_attribute8_name                 => 'ABS_INFORMATION8'
      ,p_attribute8_value                => p_rec.abs_information8
      ,p_attribute9_name                 => 'ABS_INFORMATION9'
      ,p_attribute9_value                => p_rec.abs_information9
      ,p_attribute10_name                => 'ABS_INFORMATION10'
      ,p_attribute10_value               => p_rec.abs_information10
      ,p_attribute11_name                => 'ABS_INFORMATION11'
      ,p_attribute11_value               => p_rec.abs_information11
      ,p_attribute12_name                => 'ABS_INFORMATION12'
      ,p_attribute12_value               => p_rec.abs_information12
      ,p_attribute13_name                => 'ABS_INFORMATION13'
      ,p_attribute13_value               => p_rec.abs_information13
      ,p_attribute14_name                => 'ABS_INFORMATION14'
      ,p_attribute14_value               => p_rec.abs_information14
      ,p_attribute15_name                => 'ABS_INFORMATION15'
      ,p_attribute15_value               => p_rec.abs_information15
      ,p_attribute16_name                => 'ABS_INFORMATION16'
      ,p_attribute16_value               => p_rec.abs_information16
      ,p_attribute17_name                => 'ABS_INFORMATION17'
      ,p_attribute17_value               => p_rec.abs_information17
      ,p_attribute18_name                => 'ABS_INFORMATION18'
      ,p_attribute18_value               => p_rec.abs_information18
      ,p_attribute19_name                => 'ABS_INFORMATION19'
      ,p_attribute19_value               => p_rec.abs_information19
      ,p_attribute20_name                => 'ABS_INFORMATION20'
      ,p_attribute20_value               => p_rec.abs_information20
      ,p_attribute21_name                => 'ABS_INFORMATION21'
      ,p_attribute21_value               => p_rec.abs_information21
      ,p_attribute22_name                => 'ABS_INFORMATION22'
      ,p_attribute22_value               => p_rec.abs_information22
      ,p_attribute23_name                => 'ABS_INFORMATION23'
      ,p_attribute23_value               => p_rec.abs_information23
      ,p_attribute24_name                => 'ABS_INFORMATION24'
      ,p_attribute24_value               => p_rec.abs_information24
      ,p_attribute25_name                => 'ABS_INFORMATION25'
      ,p_attribute25_value               => p_rec.abs_information25
      ,p_attribute26_name                => 'ABS_INFORMATION26'
      ,p_attribute26_value               => p_rec.abs_information26
      ,p_attribute27_name                => 'ABS_INFORMATION27'
      ,p_attribute27_value               => p_rec.abs_information27
      ,p_attribute28_name                => 'ABS_INFORMATION28'
      ,p_attribute28_value               => p_rec.abs_information28
      ,p_attribute29_name                => 'ABS_INFORMATION29'
      ,p_attribute29_value               => p_rec.abs_information29
      ,p_attribute30_name                => 'ABS_INFORMATION30'
      ,p_attribute30_value               => p_rec.abs_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec in per_abs_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_attendance_id is not null)  and (
    nvl(per_abs_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_abs_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.absence_attendance_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ABSENCE_ATTENDANCES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in per_abs_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_abs_shd.api_updating
      (p_absence_attendance_id                => p_rec.absence_attendance_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 2);
  if nvl(p_rec.absence_attendance_id,hr_api.g_number) <>
     per_abs_shd.g_old_rec.absence_attendance_id then
     l_argument := 'absence_attendance_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 3);
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     per_abs_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 4);
  if nvl(p_rec.person_id, hr_api.g_number) <>
     per_abs_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 5);
  if nvl(p_rec.absence_attendance_type_id,hr_api.g_number) <>
     per_abs_shd.g_old_rec.absence_attendance_type_id then
     l_argument := 'absence_attendance_type_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  if nvl(p_rec.occurrence,hr_api.g_number) <>
     per_abs_shd.g_old_rec.occurrence then
     l_argument := 'occurrence';
     raise l_error;
  end if;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in  date
  ,p_rec                          in  per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy boolean
  ,p_dur_hrs_less_warning         out nocopy boolean
  ,p_exceeds_pto_entit_warning    out nocopy boolean
  ,p_exceeds_run_total_warning    out nocopy boolean
  ,p_abs_overlap_warning          out nocopy boolean
  ,p_abs_day_after_warning        out nocopy boolean
  ,p_dur_overwritten_warning      out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_effective_date date;  -- Added for bug 3371960

  ----Check the gender of the person in case of maternity leave bug# 6505054

  cursor c_absence_cat(p_absence_attendance_type_id in number) is
   select absence_category from per_absence_attendance_types
   where absence_attendance_type_id = p_absence_attendance_type_id;

  l_ssp_installed boolean;
  l_absence_category varchar2(30);

--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Assign the durations to the global variables.
  --
  per_abs_shd.g_absence_days  := p_rec.absence_days;
  per_abs_shd.g_absence_hours := p_rec.absence_hours;

  --
  -- Fix for bug 3371960 starts here. Use the l_effective_date
  -- in chk procedures.
  --
  l_effective_date := NVL(p_rec.date_start, p_effective_date);
  --
  -- Fix for bug 3371960 ends here.
  --
  -- Check the business group id.
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);

  hr_utility.set_location(l_proc, 10);

  ----Check the gender of the person in case of maternity leave bug# 6505054

  open c_absence_cat(p_rec.absence_attendance_type_id);
   fetch c_absence_cat into l_absence_category;
  close c_absence_cat;

  l_ssp_installed := ssp_ssp_pkg.ssp_is_installed;

  if l_ssp_installed and l_absence_category = 'M' then

    ssp_mat_bus.validate_female_sex(p_rec.person_id);

  end if;

-- end for bug# 6505054

  --
  -- Check person ID.
  --
  chk_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_person_id                  => p_rec.person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check absence attendance type ID
  --
  chk_absence_attendance_type_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check the absence reason ID.
  --
  chk_abs_attendance_reason_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_abs_attendance_reason_id   => p_rec.abs_attendance_reason_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => l_effective_date);

  --
  -- Check absence period.
  --
  -- Check the absence period (this includes all duration validation).
  -- The durations are in out parameters and are assigned to global
  -- variables.  This is because they will be over-written during
  -- pre insert / pre update if the Fast Formula Auto-Overwrite duration
  -- profile option is set to yes during pre_insert.
  --
  chk_absence_period
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => l_effective_date
    ,p_person_id                  => p_rec.person_id
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_time_projected_start       => p_rec.time_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_time_projected_end         => p_rec.time_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_time_start                 => p_rec.time_start
    ,p_date_end                   => p_rec.date_end
    ,p_time_end                   => p_rec.time_end
    ,p_ABS_INFORMATION_CATEGORY   =>p_rec.ABS_INFORMATION_CATEGORY
    ,p_ABS_INFORMATION1		=>p_rec.ABS_INFORMATION1
    ,p_ABS_INFORMATION2		=>p_rec.ABS_INFORMATION2
    ,p_ABS_INFORMATION3		=>p_rec.ABS_INFORMATION3
    ,p_ABS_INFORMATION4		=>p_rec.ABS_INFORMATION4
    ,p_ABS_INFORMATION5		=>p_rec.ABS_INFORMATION5
    ,p_ABS_INFORMATION6		=>p_rec.ABS_INFORMATION6
    ,p_absence_days               => per_abs_shd.g_absence_days
    ,p_absence_hours              => per_abs_shd.g_absence_hours
    ,p_dur_dys_less_warning       => p_dur_dys_less_warning
    ,p_dur_hrs_less_warning       => p_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning  => p_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning  => p_exceeds_run_total_warning
    ,p_abs_overlap_warning        => p_abs_overlap_warning
    ,p_abs_day_after_warning      => p_abs_day_after_warning
    ,p_dur_overwritten_warning    => p_dur_overwritten_warning);

  --
  -- Check the replacement person ID
  --
  chk_replacement_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_replacement_person_id      => p_rec.replacement_person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check the authorising person ID
  --
  chk_authorising_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_authorising_person_id      => p_rec.authorising_person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);


  hr_utility.set_location(l_proc, 24);
  --
  per_abs_bus.chk_ddf(p_rec);
  --
  per_abs_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in  date
  ,p_rec                          in  per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy boolean
  ,p_dur_hrs_less_warning         out nocopy boolean
  ,p_exceeds_pto_entit_warning    out nocopy boolean
  ,p_exceeds_run_total_warning    out nocopy boolean
  ,p_abs_overlap_warning          out nocopy boolean
  ,p_abs_day_after_warning        out nocopy boolean
  ,p_dur_overwritten_warning      out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_effective_date date; -- Added for bug 3371960.
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Fix for bug 3371960 starts here.
  -- Use l_effective_date in different chk proceudre.
  --
  l_effective_date := NVL(p_rec.date_start, p_effective_date);
  --
  -- Fix for bug 3371960 ends here.
  --
  -- Assign the durations to the global variables.
  --
  per_abs_shd.g_absence_days  := p_rec.absence_days;
  per_abs_shd.g_absence_hours := p_rec.absence_hours;

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc, 14);

  --
  -- Check person ID. This procedure is called during update_validate
  -- because the person must be valid for the entire absence period
  -- (which can be updated).
  --
  chk_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_person_id                  => p_rec.person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check absence attendance type ID. This is called from
  -- update_validate because the absence type must be valid for
  -- the entire absence period (which can be updated).
  --
  chk_absence_attendance_type_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check the absence reason ID.
  --
  chk_abs_attendance_reason_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_abs_attendance_reason_id   => p_rec.abs_attendance_reason_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => l_effective_date);

  --
  -- Check absence period.
  --
  -- Check the absence period (this includes all duration validation).
  -- The durations are in out parameters and are assigned to global
  -- variables.  This is because they will be over-written during
  -- pre insert / pre update if the Fast Formula Auto-Overwrite duration
  -- profile option is set to yes during pre-update.
  --
  chk_absence_period
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_absence_attendance_type_id => p_rec.absence_attendance_type_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => l_effective_date
    ,p_person_id                  => p_rec.person_id
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_time_projected_start       => p_rec.time_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_time_projected_end         => p_rec.time_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_time_start                 => p_rec.time_start
    ,p_date_end                   => p_rec.date_end
    ,p_time_end                   => p_rec.time_end
    ,p_ABS_INFORMATION_CATEGORY   =>p_rec.ABS_INFORMATION_CATEGORY
    ,p_ABS_INFORMATION1		   =>p_rec.ABS_INFORMATION1
    ,p_ABS_INFORMATION2		=>p_rec.ABS_INFORMATION2
    ,p_ABS_INFORMATION3		=>p_rec.ABS_INFORMATION3
    ,p_ABS_INFORMATION4		=>p_rec.ABS_INFORMATION4
    ,p_ABS_INFORMATION5		=>p_rec.ABS_INFORMATION5
    ,p_ABS_INFORMATION6		=>p_rec.ABS_INFORMATION6
    ,p_absence_days               => per_abs_shd.g_absence_days
    ,p_absence_hours              => per_abs_shd.g_absence_hours
    ,p_dur_dys_less_warning       => p_dur_dys_less_warning
    ,p_dur_hrs_less_warning       => p_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning  => p_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning  => p_exceeds_run_total_warning
    ,p_abs_overlap_warning        => p_abs_overlap_warning
    ,p_abs_day_after_warning      => p_abs_day_after_warning
    ,p_dur_overwritten_warning    => p_dur_overwritten_warning);


  --
  -- Check the replacement person ID
  --
  chk_replacement_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_replacement_person_id      => p_rec.replacement_person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);

  --
  -- Check the authorising person ID
  --
  chk_authorising_person_id
    (p_absence_attendance_id      => p_rec.absence_attendance_id
    ,p_authorising_person_id      => p_rec.authorising_person_id
    ,p_business_group_id          => p_rec.business_group_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_date_projected_start       => p_rec.date_projected_start
    ,p_date_projected_end         => p_rec.date_projected_end
    ,p_date_start                 => p_rec.date_start
    ,p_date_end                   => p_rec.date_end);


  hr_utility.set_location(l_proc, 24);
  --
  per_abs_bus.chk_ddf(p_rec);
  --
  per_abs_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_abs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_abs_bus;

/
