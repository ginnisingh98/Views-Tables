--------------------------------------------------------
--  DDL for Package Body PQP_SCHEDULE_CALCULATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_SCHEDULE_CALCULATION_PKG" AS
/* $Header: pqschcal.pkb 120.2.12000000.1 2007/01/16 04:32:45 appldev noship $ */

  -- IMPORTANT : Declarations global within package body

  --TYPE t_wp_days_type IS TABLE OF NUMBER
  --INDEX BY BINARY_INTEGER;



--User Defined Table Name, to be treated as a constant unless table name
--changes
--  g_udt_name VARCHAR2(50) := 'PQP_COMPANY_WORK_PATTERNS';
--  g_default_start_day VARCHAR2(10) := 'sunday';
  g_days_worked NUMBER;

  g_legislation_code pay_user_tables.legislation_code%TYPE := NULL;

  --g_wp_days t_wp_days_type;

  g_package_name VARCHAR2(31) := 'pqp_schedule_calculation_pkg.' ;
  g_debug        BOOLEAN      := hr_utility.debug_enabled ;


  -- cache for load_work_pattern_into_cache
  g_last_business_group_id       pay_user_tables.business_group_id%TYPE;
  g_last_max_effective_start_dt  DATE;
  g_last_min_effective_end_dt    DATE;
  g_last_used_work_pattern       pay_user_columns.user_column_name%TYPE;
  g_asg_work_pattern_start_day_n BINARY_INTEGER;
  g_asg_work_pattern_start_date  DATE;
  g_work_pattern_cache           t_work_pattern_cache_type;


  -- cache for get_legislation_code
  g_business_group_id        pay_user_rows_f.business_group_id%TYPE;
--
--
--
  PROCEDURE debug(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message, p_trace_location);
  END debug;

--
--
--
  PROCEDURE debug(p_trace_number IN NUMBER)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_number);
  END debug;

--
--
--
  PROCEDURE debug(p_trace_date IN DATE)
  IS
  BEGIN
    pqp_utilities.debug(p_trace_date);
  END debug;

--
--
--
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_enter(p_proc_name, p_trace_on);
  END debug_enter;

--
--
--
  PROCEDURE debug_exit(
    p_proc_name                 IN       VARCHAR2
   ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_exit(p_proc_name, p_trace_off);
  END debug_exit;

--
--
--
  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       NUMBER DEFAULT NULL
  )
  IS
  BEGIN
    pqp_utilities.debug_others(p_proc_name, p_proc_step);
  END debug_others;
--
--
--
  PROCEDURE check_error_code
    (p_error_code               IN       NUMBER
    ,p_error_message            IN       VARCHAR2
    )
  IS
  BEGIN
    pqp_utilities.check_error_code(p_error_code, p_error_message);
  END;
--
--
--
PROCEDURE clear_cache
IS

  --l_empty_wp_days_type        t_wp_days_type;
  l_empty_work_patterns_cache t_work_pattern_cache_type;

BEGIN

  g_days_worked                  := NULL;

  --g_wp_days                      := l_empty_wp_days_type;

  -- cache for load_work_pattern_into_cache
  g_last_business_group_id       := NULL;
  g_last_max_effective_start_dt  := NULL;
  g_last_min_effective_end_dt    := NULL;
  g_last_used_work_pattern       := NULL;
  g_asg_work_pattern_start_day_n := NULL;
  g_asg_work_pattern_start_date  := NULL;
  g_work_pattern_cache           := l_empty_work_patterns_cache;


  -- cache for get_legislation_code
  g_business_group_id            := NULL;
  g_legislation_code             := NULL;

END clear_cache;

FUNCTION get_legislation_code
 (p_business_group_id            IN       NUMBER
 ) RETURN pay_user_rows_f.legislation_code%TYPE
IS

  l_legislation_code   pay_user_rows_f.legislation_code%TYPE;

BEGIN

  IF g_legislation_code IS NULL
    OR
     g_business_group_id IS NULL
    OR
     g_business_group_id <> p_business_group_id
  THEN

    g_business_group_id := p_business_group_id;

    OPEN c_get_legcode(p_business_group_id);
    FETCH c_get_legcode INTO l_legislation_code;
    CLOSE c_get_legcode;

    g_legislation_code := l_legislation_code;


  ELSE

    l_legislation_code := g_legislation_code;

  END IF;

  RETURN l_legislation_code;

END get_legislation_code;




PROCEDURE get_day_dets(p_wp_dets        IN c_wp_dets%ROWTYPE
                      ,p_calc_stdt      IN  DATE
                      ,p_calc_edt       IN  DATE
                      ,p_day_no         OUT NOCOPY NUMBER
                      ,p_days_in_wp     OUT NOCOPY NUMBER
                      ) IS

  -- Local Declarations

  -- Bug  : 2732955
  -- Date : 02/01/2003
  -- Name : rtahilia
  -- Desc : Added this cursor to get Leg. code for the BG
  -- Moved to header -- RRAZDAN

  -- Bug  : 2732955
  -- Date : 02/01/2003
  -- Name : rtahilia
  -- Desc : Modified cursor, added legislation code check
  -- Legislation Heirarchy
  -- Table of Work Patterns : Legislatively Seeded
  -- Implies that work patterns in that table can either be
  -- legislatively seeded or belong to a specific business group
  -- A work pattern is represented by a user column name
  -- ie for a given table id (guaranteed leg specific) if a matching user
  -- column name it could either itself be seeded of specific to a bg
  -- so check for bg/leg in user columns
  -- If the column was seeded (seeded work pattern) then it could have
  -- column instances (day values) which were either also seeded or
  -- specific to the bg. This last bit implies that a user may have
  -- extended a seeded work patterns. While evaluating a particular wp
  -- both the seeded and the values in that row must be evaluated.
  -- so check for bg/leg in the user column instances also.
  -- Note the user rows (the actual days themselves) can only be seeded
  -- the user may extend those but functionally such extensions would have no
  -- impact.
  --            PQP_CWP(GB)                    PQP_CWP (NL)           UT
  --                |                             |
  --        |-------|-------|             |-------|--------|
  --     WP1(GB)  WP2(bg1)  WP3(bg2)      WP4(NL) WP5(bg3) WP6(bg4)   UC
  --        |                                     |
  --  |-----|----|                                |
  --  D1-7(GB)  D8(bg1)                         D1-14(bg3)            UCI
  --
  --
  -- So when counting distinct user_rows for bg1 (WP1) we should get 8
  -- = D1-7 (seeded) + 1 (D8 bg1)
  --
  -- When counting distinct user_rows for bg2 (WP1) we should get 7
  -- = D1-7 (seeded)
  --
  -- When counting distinct user rows for bg3 (WP5) we should get 14
  -- = D1-14 , ie for a bg specific work pattern the would only exist in
  -- the business group itself.
  --
  -- NOTE: D1-D28 themselves are seeded repectively in each legislation
  -- as user rows (UR)


  CURSOR c_get_days IS
  SELECT COUNT(pur.row_low_range_or_name)
  FROM   pay_user_rows_f pur
  WHERE  pur.user_row_id IN
          (SELECT DISTINCT uci.user_row_id
           FROM   pay_user_tables put,
                  pay_user_columns puc,
                  pay_user_column_instances_f uci
           WHERE put.user_table_name  = g_udt_name
             AND put.legislation_code = g_legislation_code -- Added on 02/01/2003
             AND puc.user_table_id    = put.user_table_id
             AND puc.user_column_name = p_wp_dets.work_pattern
             AND (
                   puc.business_group_id = p_wp_dets.business_group_id
                 OR
                  (puc.business_group_id IS NULL
                    AND puc.legislation_code = g_legislation_code)
               --OR global
                 -- CANNOT BE as the table itself is legislatively seeded.
                 )
             AND uci.user_column_id   = puc.user_column_id
             AND (
                   uci.business_group_id = p_wp_dets.business_group_id
                  OR
                   (uci.business_group_id IS NULL
                    AND uci.legislation_code = g_legislation_code)
                 --OR global
                   -- CANNOT BE as the work pattern itself is either
                   -- legislative or business group specific
                 )
             AND (p_calc_stdt BETWEEN uci.effective_start_date
                                  AND uci.effective_end_date
                  OR
                  p_calc_edt BETWEEN uci.effective_start_date
                                 AND uci.effective_end_date)

          )    AND pur.row_low_range_or_name like
           'Day __';

  l_days_in_wp                  NUMBER;
  l_day_no                      NUMBER;
  l_diff_days                   NUMBER;
  l_diff_CalcStDt_DtOnDay1      NUMBER;
  l_diff_temp                   NUMBER;
  l_dt_on_day1                  DATE;

BEGIN /* get_day_dets */

  -- Get the legislation code for this business group,
  -- if not already populated.

  hr_utility.trace('in get_day_dets:'||p_wp_dets.work_pattern);

  if g_legislation_code is NULL then
    open c_get_legcode(p_wp_dets.business_group_id);
    fetch c_get_legcode into g_legislation_code;
    close c_get_legcode;
  end if;

  /* Get the number of days in the Work Pattern */
  open c_get_days;
  fetch c_get_days into l_days_in_wp;
  hr_utility.trace('get_days_dets:l_days_in_wp:'||
  fnd_number.number_to_canonical(l_days_in_wp));
  close c_get_days;

  /* Find number of days to be added to effective date to get next date on 'Day
  01' */
  --hr_utility.trace('get_days_dets:p_wp_dets.start_day:'||
  --p_wp_dets.start_day);

  l_diff_days := l_days_in_wp - to_number(substr(p_wp_dets.start_day,5,2)) + 1;

  --hr_utility.trace('get_days_dets:l_diff_days:'||
  --fnd_number.number_to_canonical(l_diff_days));


  /* Find the next date that would be 'Day 01' w.r.t. the p_wp_dets record */
  l_dt_on_day1 := p_wp_dets.effective_start_date + l_diff_days;

  --hr_utility.trace('get_days_dets:l_dt_on_day1:'||
  --fnd_date.date_to_canonical(l_dt_on_day1));


  /* Find difference between calculation start_date and date on 'Day 01' */
  l_diff_temp :=  p_calc_stdt - l_dt_on_day1;

  hr_utility.trace('get_days_dets:l_diff_temp:'||
  fnd_number.number_to_canonical(l_diff_temp));


  /* If difference is negative, multiply by -1 to make it positive */
  l_diff_CalcStDt_DtOnDay1 :=  l_diff_temp * sign(l_diff_temp);

  --hr_utility.trace('get_days_dets:l_diff_CalcStDt_DtOnDay1:'||
  --fnd_number.number_to_canonical(l_diff_CalcStDt_DtOnDay1));


  /* Calculate Day Number on Calculation Start Date */
  if l_diff_temp < 0
  then
    l_day_no := l_days_in_wp - l_diff_CalcStDt_DtOnDay1 + 1;
    --hr_utility.trace('get_days_dets:l_day_no1:'||
    --fnd_number.number_to_canonical(l_day_no));

  else
    l_day_no := mod(l_diff_CalcStDt_DtOnDay1,l_days_in_wp)  + 1;
    --hr_utility.trace('get_days_dets:l_day_no2:'||
    --fnd_number.number_to_canonical(l_day_no));
  end if;

  /* Assign values to be returned */

  hr_utility.trace('get_days_dets:l_day_no:'||
  fnd_number.number_to_canonical(l_day_no));

  p_day_no := l_day_no;
  p_days_in_wp := l_days_in_wp;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('in get_day_dets: Exception block');
       p_day_no := NULL;
       p_days_in_wp := NULL;
       raise;

END get_day_dets;


FUNCTION calculate_time_worked(p_assignment_id          IN NUMBER
                              ,p_date_start             IN DATE
                              ,p_date_end               IN DATE
                              ) RETURN NUMBER IS


  /* Local variable declarations */
  l_calc_stdt           DATE;
  l_calc_endt           DATE;
  l_curr_date           DATE;

  l_day_no              NUMBER;
  l_curr_day_no         NUMBER;
  l_days_in_wp          NUMBER;
  l__curr_day_no        NUMBER;
  l_hours               NUMBER := 0;
  l_total_hours         NUMBER := 0;

  l_day                 VARCHAR2(30);

  r_wp_dets             c_wp_dets%ROWTYPE;


BEGIN /* calculate_time_worked */

  hr_utility.set_location('Entered calculate_time_worked', 10);
  hr_utility.set_location('UDT Name :'||g_udt_name, 15);

  /* If start date is greater than end date then return zero hours */
  if p_date_start > p_date_end
  then
    return l_total_hours;
  end if;

  for r_wp_dets in c_wp_dets(p_assignment_id, p_date_start, p_date_end)
  loop   /* Get Work Pattern Details */


    hr_utility.set_location('Inside Loop to get WP detail', 20);

    /* Determine Calculation Start Date for this Work Pattern */
    if p_date_start > r_wp_dets.effective_start_date
    then
      l_calc_stdt := p_date_start;
    else
      l_calc_stdt := r_wp_dets.effective_start_date;
    end if;

    /* Determine Calculation End Date for this Work Pattern */
    if p_date_end < r_wp_dets.effective_end_date
    then
      l_calc_endt := p_date_end;
    else
      l_calc_endt := r_wp_dets.effective_end_date;
    end if;



    /* Get day number on calculation start date and number of days in Work
    Pattern */
    get_day_dets(p_wp_dets      => r_wp_dets
                ,p_calc_stdt    => l_calc_stdt
                ,p_calc_edt     => l_calc_endt
                ,p_day_no       => l_day_no     /* OUT NOCOPY */
                ,p_days_in_wp   => l_days_in_wp /* OUT NOCOPY */
                );


    l_curr_day_no := l_day_no;
    l_curr_date   := l_calc_stdt;

    hr_utility.set_location('l_curr_day_no :'||l_curr_day_no, 30);
    hr_utility.set_location('l_curr_date :'||l_curr_date, 35);
    hr_utility.set_location('Work Pattern :'||r_wp_dets.work_pattern, 40);

    for l_loopindx in 1..(l_calc_endt - l_calc_stdt + 1)
    loop /* Process dates in range */

      l_day := 'Day '||lpad(l_curr_day_no,2,0);

      begin
        l_hours := hruserdt.get_table_value
                    (p_bus_group_id      => r_wp_dets.business_group_id
                    ,p_table_name        => g_udt_name
                    ,p_col_name          => r_wp_dets.work_pattern
                    ,p_row_value         => l_day
                    ,p_effective_date    => l_curr_date
                    );

      exception
        when no_data_found then

          /*
           * No data was entered. Do not add to total
           * or count the day in the loop.
           */
          l_hours := 0;

      end;

      hr_utility.set_location('Hours on '||l_day||' = '||l_hours, 50);

      l_total_hours := l_total_hours + l_hours;

      -- add this date to the number of days in the date range.
      if l_hours > 0 then

        g_days_worked := g_days_worked + 1;
        hr_utility.set_location('Adding day for date :'||to_char(l_curr_date,
        'DD/MM/YYYY'), 60);

      end if;

      /* Calculate next day no */
      if l_curr_day_no = l_days_in_wp then
        l_curr_day_no := 1;
      else
        l_curr_day_no := l_curr_day_no + 1;
      end if;

      l_curr_date := l_curr_date + 1;

    end loop; /* Process dates in range */

  end loop; /* Get Work Pattern Details */

  return l_total_hours;

END calculate_time_worked;


-- This procedure calculates and returns the hours and days
-- worked given the WP details and the start and end dates
PROCEDURE calculate_time_worked_wp
  (p_date_start    IN            DATE
  ,p_date_end      IN            DATE
  ,p_wp_dets       IN            c_wp_dets%ROWTYPE
  ,p_hours_worked     OUT NOCOPY        NUMBER
  ,p_days_worked      OUT NOCOPY        NUMBER
  ,p_working_dates IN OUT NOCOPY        t_working_dates
  )
IS
  /* Local variable declarations */
  l_calc_stdt           DATE;
  l_calc_endt           DATE;
  l_curr_date           DATE;

  l_day_no              NUMBER;
  l_curr_day_no         NUMBER;
  l_days_in_wp          NUMBER;
  l_hours               NUMBER := 0;
  l_total_hours         NUMBER := 0;
  l_days_worked         NUMBER := 0;
  l_day                 VARCHAR2(30);

  r_wp_dets             c_wp_dets%ROWTYPE;
  l_working_dates       t_working_dates;

BEGIN -- calculate_time_worked_wp

  hr_utility.set_location('Entered calculate_time_worked_wp', 10);

  r_wp_dets := p_wp_dets;
  l_working_dates := p_working_dates;

  /* Determine Calculation Start Date for this Work Pattern */
  if p_date_start > r_wp_dets.effective_start_date
  then
    l_calc_stdt := p_date_start;
  else
    l_calc_stdt := r_wp_dets.effective_start_date;
  end if;

  /* Determine Calculation End Date for this Work Pattern */
  if p_date_end < r_wp_dets.effective_end_date
  then
    l_calc_endt := p_date_end;
  else
    l_calc_endt := r_wp_dets.effective_end_date;
  end if;

  /* Get day number on calculation start date and number of days in Work Pattern
  */
  get_day_dets(p_wp_dets      => r_wp_dets
              ,p_calc_stdt    => l_calc_stdt
              ,p_calc_edt     => l_calc_endt
              ,p_day_no       => l_day_no     /* OUT NOCOPY */
              ,p_days_in_wp   => l_days_in_wp /* OUT NOCOPY */
              );


  l_curr_day_no := l_day_no;
  l_curr_date   := l_calc_stdt;

  hr_utility.set_location('l_curr_day_no :'||l_curr_day_no, 20);
  hr_utility.set_location('l_curr_date :'||l_curr_date, 30);
  hr_utility.set_location('Work Pattern :'||r_wp_dets.work_pattern, 40);

  for l_loopindx in 1..(l_calc_endt - l_calc_stdt + 1)
  loop /* Process dates in range */

    hr_utility.set_location('Processing date :'||to_char(l_curr_date,
    'DD/MM/YYYY'), 60);

    l_day := 'Day '||lpad(l_curr_day_no,2,0);

    begin
      l_hours := hruserdt.get_table_value
                   (p_bus_group_id   => r_wp_dets.business_group_id
                   ,p_table_name     => g_udt_name
                   ,p_col_name       => r_wp_dets.work_pattern
                   ,p_row_value      => l_day
                   ,p_effective_date => l_curr_date
                   );
    exception
      when no_data_found then
        /*
         * No data was entered. Do not add to total
         * or count the day in the loop.
         */
        l_hours := 0;
    end;

    hr_utility.set_location('Hours on '||l_day||' = '||l_hours, 70);

    l_total_hours := l_total_hours + l_hours;

    -- add this date to the number of days in the date range.
    if l_hours > 0 then

      l_days_worked := l_days_worked + 1;
      p_working_dates(p_working_dates.COUNT + 1) := l_curr_date;

    end if;

    /* Calculate next day no */
    if l_curr_day_no = l_days_in_wp then
      l_curr_day_no := 1;
    else
      l_curr_day_no := l_curr_day_no + 1;
    end if;

    l_curr_date := l_curr_date + 1;

  end loop; /* Process dates in range */

  p_hours_worked        := l_total_hours;
  p_days_worked         := l_days_worked;
--  p_working_dates       := l_working_dates;

  hr_utility.set_location('Leaving calculate_time_worked_wp', 100);
  RETURN;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:', 110);
       p_hours_worked := NULL;
       p_days_worked  := NULL;
       p_working_dates := l_working_dates;
       raise;

END calculate_time_worked_wp;


-- This function returns the time worked as specified in p_dimension(DAYS or
-- HOURS)
-- If the assignment does not have a WP then the default work pattern is used
FUNCTION get_time_worked
  (p_assignment_id     IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_date_start        IN DATE
  ,p_date_end          IN DATE
  ,p_dimension         IN VARCHAR2   -- DAYS OR HOURS
  ,p_default_wp        IN VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN VARCHAR2 DEFAULT NULL
  ,p_working_dates     OUT NOCOPY t_working_dates
  ,p_error_code        OUT NOCOPY NUMBER
  ,p_error_message     OUT NOCOPY VARCHAR2
  ,p_is_assignment_wp  IN     BOOLEAN DEFAULT FALSE
  ) RETURN NUMBER IS


  /* Local variable declarations */
  l_calc_stdt           DATE;
  l_calc_endt           DATE;
  l_curr_date           DATE;

  l_day_no              NUMBER;
  l_curr_day_no         NUMBER;
  l_days_in_wp          NUMBER;
  l__curr_day_no        NUMBER;
  l_hours               NUMBER := 0;
  l_hours_worked        NUMBER := 0;
  l_total_hours         NUMBER := 0;
  l_days_worked         NUMBER := 0;
  l_total_days          NUMBER := 0;
  l_retval              NUMBER := 0;

  l_asg_wp_found        BOOLEAN := FALSE;

  l_day                 VARCHAR2(30);

  r_wp_dets             c_wp_dets%ROWTYPE;
  r_def_wp_dets         c_wp_dets%ROWTYPE;
  r_tmp_wp_dets         c_wp_dets%ROWTYPE;
  l_working_dates       t_working_dates;
  l_alt_work_pattern    pay_user_columns.user_column_name%TYPE;

  l_error_code          NUMBER := 0;
  l_err_msg_name        fnd_new_messages.message_name%TYPE;
  l_working_dates_nc    t_working_dates;

BEGIN /* get_time_worked */

  hr_utility.set_location('Entered get_time_worked', 10);
  hr_utility.set_location('UDT Name :'||g_udt_name, 20);
  hr_utility.trace('get_time_worked:p_override_wp:'||p_override_wp);

  -- nocopy changes tmehra
  l_working_dates_nc := p_working_dates;

  /* If start date is greater than end date then return zero hours */
  IF p_date_start > p_date_end
  THEN
    RETURN l_hours_worked;
  END IF;

IF p_is_assignment_wp = FALSE THEN
-- If an override work pattern is supplied then no matter
-- whether the person had a work pattern or work pattern changes
-- or regardless of what the default work pattern is always use the
-- override the same
      hr_utility.trace('p_is_assignment_wp FALSE:'||p_override_wp);
      r_def_wp_dets := NULL;
      r_def_wp_dets.effective_start_date := p_date_start;
      r_def_wp_dets.effective_end_date   := p_date_end;
      r_def_wp_dets.business_group_id    := p_business_group_id;
      IF p_override_wp IS NULL THEN
         r_def_wp_dets.work_pattern         := p_default_wp;
      ELSE
      r_def_wp_dets.work_pattern         := p_override_wp;
      END IF;
      hr_utility.trace('r_def_wp_dets.work_pattern:'||
                       r_def_wp_dets.work_pattern);

      r_def_wp_dets.start_day
        := 'Day '||LPAD
                    (TO_CHAR
                      (8 - (NEXT_DAY
                             (p_date_start, g_default_start_day)
                            - p_date_start
                           )
                      )
                    ,2,'0');

      hr_utility.set_location('Start Day :'||r_def_wp_dets.start_day, 100);

      calculate_time_worked_wp
        (p_date_start    => p_date_start
        ,p_date_end      => p_date_end
        ,p_wp_dets       => r_def_wp_dets
        ,p_hours_worked  => l_hours_worked  -- OUT
        ,p_days_worked   => l_days_worked   -- OUT
        ,p_working_dates => l_working_dates -- IN OUT
        );

      l_total_hours := l_total_hours + l_hours_worked;
      l_total_days  := l_total_days  + l_days_worked;


ELSE -- IF p_override_wp IS NOT NULL THEN

  l_curr_date := p_date_start;


  FOR r_wp_dets IN c_wp_dets(p_assignment_id, p_date_start, p_date_end)
  LOOP   /* GET WORK PATTERN DETAILS */

    -- Only if this aat record contains a work pattern
    IF r_wp_dets.work_pattern IS NOT NULL THEN

      l_calc_stdt := l_curr_date;

      hr_utility.set_location('Asg WP Found', 30);
      l_asg_wp_found := TRUE;

      -- And Calc Start Date is between ESD and EED
      IF l_calc_stdt BETWEEN r_wp_dets.effective_start_date
                         AND r_wp_dets.effective_end_date THEN

        -- Use only the AAT work pattern
        hr_utility.set_location('Using only Asg WP', 40);

        l_calc_endt := LEAST(p_date_end, r_wp_dets.effective_end_date);

        hr_utility.trace(fnd_date.date_to_canonical(l_calc_stdt));
        calculate_time_worked_wp
         (p_date_start       => l_calc_stdt
         ,p_date_end         => l_calc_endt
         ,p_wp_dets          => r_wp_dets
         ,p_hours_worked     => l_hours_worked  -- OUT
         ,p_days_worked      => l_days_worked   -- OUT
         ,p_working_dates    => l_working_dates -- IN OUT
         );

        l_total_hours := l_total_hours + l_hours_worked;
        l_total_days  := l_total_days  + l_days_worked;

      ELSIF p_default_wp IS NOT NULL THEN
        -- Use the default work pattern for the period where there is no
        -- work pattern on assignment and then use the asg work pattern

        hr_utility.set_location('Using default and Asg WP', 50);

        -- Step 1) Get working hours and days for the default work pattern
        l_calc_endt := LEAST(p_date_end, (r_wp_dets.effective_start_date - 1));

        r_def_wp_dets := NULL;
        r_def_wp_dets.effective_start_date := l_calc_stdt;
        r_def_wp_dets.effective_end_date := l_calc_endt;
        r_def_wp_dets.business_group_id := p_business_group_id;
        r_def_wp_dets.work_pattern := p_default_wp;
        r_def_wp_dets.start_day := 'Day '||LPAD(TO_CHAR(8 -
                                   (NEXT_DAY(l_calc_stdt, g_default_start_day) -
                                   l_calc_stdt)),2,'0');

        hr_utility.set_location('Start Day :'||r_def_wp_dets.start_day, 60);

        hr_utility.trace(fnd_date.date_to_canonical(l_calc_stdt));
        calculate_time_worked_wp
         (p_date_start    => l_calc_stdt
         ,p_date_end      => l_calc_endt
         ,p_wp_dets       => r_def_wp_dets
         ,p_hours_worked  => l_hours_worked  -- OUT
         ,p_days_worked   => l_days_worked   -- OUT
         ,p_working_dates => l_working_dates -- IN OUT
         );

        l_total_hours := l_total_hours + l_hours_worked;
        l_total_days  := l_total_days  + l_days_worked;

        -- Step 2) Get working hours and days for the assignment work pattern

        -- If still there are dates to be dealth with
        IF l_calc_endt < p_date_end THEN
          --
          l_calc_stdt := l_calc_endt + 1;
          l_calc_endt := LEAST(p_date_end, r_wp_dets.effective_end_date);

          calculate_time_worked_wp
           (p_date_start       => l_calc_stdt
           ,p_date_end         => l_calc_endt
           ,p_wp_dets          => r_wp_dets
           ,p_hours_worked     => l_hours_worked  -- OUT
           ,p_days_worked      => l_days_worked   -- OUT
           ,p_working_dates    => l_working_dates -- IN OUT
           );

          l_total_hours := l_total_hours + l_hours_worked;
          l_total_days  := l_total_days  + l_days_worked;
          --
        END IF; -- l_calc_endt < p_date_end then
        --
      ELSE -- No default work pattern found, raise error and exit the loop.
        l_error_code := -1;
        l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
        EXIT;
      END IF; -- l_calc_stdt between r_wp_dets.effective_start_date

      -- Set up the next start date
      l_curr_date := l_calc_endt + 1;

    END IF; -- r_wp_dets.work_pattern is not null then
    --
  END LOOP; /* Get Work Pattern Details */

  -- If ASG Work Pattern not found at AAT level or WP history not sufficient on
  -- AAT then do the calculation using the default work pattern if it has been
  -- passed
  IF l_error_code = 0 --  No errors have occured
     AND
     ( -- No WP found on AAT
      NOT l_asg_wp_found
      OR
      -- not enough WP history on AAT
      l_curr_date <= p_date_end
     ) THEN

    IF p_default_wp IS NOT NULL THEN

      hr_utility.set_location('Default WP available', 70);

      -- Set the start and end dates
      IF NOT l_asg_wp_found THEN
        hr_utility.set_location('Asg WP was NOT Found', 80);
        l_calc_stdt := p_date_start;
      ELSE
        hr_utility.set_location('Asg WP history insufficient or incomplete',
        90);
        l_calc_stdt := l_curr_date;
      END IF;
      --
      l_calc_endt := p_date_end;

      r_def_wp_dets := NULL;
      r_def_wp_dets.effective_start_date := l_calc_stdt;
      r_def_wp_dets.effective_end_date := l_calc_endt;
      r_def_wp_dets.business_group_id := p_business_group_id;
      r_def_wp_dets.work_pattern := p_default_wp;
      r_def_wp_dets.start_day := 'Day '||LPAD(TO_CHAR(8 -
                             (NEXT_DAY(l_calc_stdt, g_default_start_day) -
                             l_calc_stdt)),2,'0');

      hr_utility.set_location('Start Day :'||r_def_wp_dets.start_day, 100);

      calculate_time_worked_wp
        (p_date_start       => l_calc_stdt
        ,p_date_end         => l_calc_endt
        ,p_wp_dets          => r_def_wp_dets
        ,p_hours_worked     => l_hours_worked  -- OUT
        ,p_days_worked      => l_days_worked   -- OUT
        ,p_working_dates    => l_working_dates -- IN OUT
        );

      l_total_hours := l_total_hours + l_hours_worked;
      l_total_days  := l_total_days  + l_days_worked;

    ELSE -- no default wp and no wp on assignment, raise error
      l_error_code := -1;
      l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
    END IF;
    --
  END IF; -- l_error_code = 0 AND (NOT l_asg_wp_found...

END IF; -- IF p_override_wp IS NOT NULL THEN ... ELSE ...

  -- Check for errors

hr_utility.trace('l_error_code:'||
                 fnd_number.number_to_canonical(l_error_code));
  IF l_error_code <> 0 THEN
    l_retval := 0;
  ELSE -- No errors, assign the value
    -- Decide what to return
hr_utility.trace('p_dimension:'||p_dimension);

    IF p_dimension = 'DAYS' THEN
hr_utility.trace('l_total_days:'||
                 fnd_number.number_to_canonical(l_total_days));
      l_retval := l_total_days;
    ELSIF p_dimension = 'HOURS' THEN
hr_utility.trace('l_total_hours:'||
                 fnd_number.number_to_canonical(l_total_hours));
      l_retval := l_total_hours;
    END IF;
    --
    p_working_dates := l_working_dates;
    --
  END IF; -- l_error_code <> 0 then
  --
  p_error_code := l_error_code;
  --
  IF l_err_msg_name IS NOT NULL THEN
    p_error_message := substr(fnd_message.get_string('PQP',l_err_msg_name)
                             ,255 -- Bugfix 3405270
                             );
  END IF;
  --
hr_utility.trace('get_time_worked:l_retval:'||
                 fnd_number.number_to_canonical(l_retval));

  RETURN l_retval;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       p_working_dates := l_working_dates_nc;
       raise;


END get_time_worked;


FUNCTION get_days_worked
  (p_assignment_id     IN     NUMBER
  ,p_business_group_id IN     NUMBER
  ,p_date_start        IN     DATE
  ,p_date_end          IN     DATE
  ,p_working_dates        OUT NOCOPY t_working_dates
  ,p_error_code           OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS

  l_days_worked         NUMBER := 0;
  l_working_dates       t_working_dates;
  l_working_dates_nc    t_working_dates;

BEGIN

hr_utility.trace('get_days_worked2:p_override_wp:'||p_override_wp);

  -- nocopy changes tmehra
  l_working_dates_nc := p_working_dates;

  l_days_worked := get_time_worked
                     (p_assignment_id          => p_assignment_id
                     ,p_business_group_id      => p_business_group_id
                     ,p_date_start             => p_date_start
                     ,p_date_end               => p_date_end
                     ,p_dimension              => 'DAYS'
                     ,p_default_wp             => p_default_wp
                     ,p_override_wp            => p_override_wp
                     ,p_working_dates          => l_working_dates -- OUT
                     ,p_error_code             => p_error_code -- OUT
                     ,p_error_message          => p_error_message -- OUT
                     ,p_is_assignment_wp       => TRUE
                     );

  -- Check for errors
  if p_error_code <> 0 then
    l_days_worked := 0;
  else --  No errors, assign values
    p_working_dates := l_working_dates;
  end if;

  RETURN l_days_worked;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       p_working_dates := l_working_dates_nc;
       raise;
END get_days_worked;

-- OVERLOADED get_days_worked
-- Returns the number  of days worked in the given date range
-- Uses Default Work Pattern if Assignment does not have a WP
FUNCTION get_days_worked
  (p_assignment_id     IN     NUMBER
  ,p_business_group_id IN     NUMBER
  ,p_date_start        IN     DATE
  ,p_date_end          IN     DATE
  ,p_error_code           OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER IS

  l_days_worked         NUMBER := 0;
  l_working_dates       t_working_dates;

BEGIN

  hr_utility.trace('get_days_worked1:p_override_wp:'||p_override_wp);

  l_days_worked := get_days_worked
                     (p_assignment_id     => p_assignment_id
                     ,p_business_group_id => p_business_group_id
                     ,p_date_start        => p_date_start
                     ,p_date_end          => p_date_end
                     ,p_default_wp        => p_default_wp
                     ,p_override_wp       => p_override_wp
                     ,p_working_dates     => l_working_dates -- OUT
                     ,p_error_code        => p_error_code -- OUT
                     ,p_error_message     => p_error_message -- OUT
                     );

  RETURN l_days_worked;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       raise;

END get_days_worked;


FUNCTION get_hours_worked
  (p_assignment_id     IN     NUMBER
  ,p_business_group_id IN     NUMBER
  ,p_date_start        IN     DATE
  ,p_date_end          IN     DATE
  ,p_error_code           OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
  ,p_is_assignment_wp  IN     BOOLEAN DEFAULT FALSE
  ) RETURN NUMBER
IS

  l_hours_worked         NUMBER := 0;
  l_working_dates       t_working_dates;
  l_error_code          VARCHAR2(10) := NULL;

BEGIN

  l_hours_worked := get_time_worked
                      (p_assignment_id     => p_assignment_id
                      ,p_business_group_id => p_business_group_id
                      ,p_date_start        => p_date_start
                      ,p_date_end          => p_date_end
                      ,p_dimension         => 'HOURS'
                      ,p_default_wp        => p_default_wp
		      ,p_override_wp       => p_override_wp
                      ,p_working_dates     => l_working_dates -- OUT
                      ,p_error_code        => p_error_code -- OUT
                      ,p_error_message     => p_error_message -- OUT
		      ,p_is_assignment_wp  => p_is_assignment_wp
                      );
  -- Check for errors
  IF p_error_code <> 0 THEN
    l_hours_worked := 0;
  END IF;

  RETURN l_hours_worked;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       raise;

END get_hours_worked;

FUNCTION is_working_day
  (p_assignment_id     IN     NUMBER
  ,p_business_group_id IN     NUMBER
  ,p_date              IN     DATE
  ,p_error_code           OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2
IS

  l_days_worked         NUMBER := 0;
  l_is_working_day      VARCHAR2(1) := 'N';
  l_working_dates       t_working_dates;

BEGIN /*is_working_day*/

  hr_utility.trace('Entered Is Working Day?'||
    fnd_date.date_to_canonical(p_date));
  hr_utility.trace('p_assignment_id:'||
    fnd_number.number_to_canonical(p_assignment_id));
  hr_utility.trace('p_override_wp:'||p_override_wp);

  l_days_worked := get_days_worked
                     (p_assignment_id     => p_assignment_id
                     ,p_business_group_id => p_business_group_id
                     ,p_date_start        => p_date
                     ,p_date_end          => p_date
                     ,p_default_wp        => p_default_wp
                     ,p_override_wp       => p_override_wp
                     ,p_working_dates     => l_working_dates -- OUT
                     ,p_error_code        => p_error_code    -- OUT
                     ,p_error_message     => p_error_message -- OUT
                     );

  IF l_days_worked = 1 AND p_error_code = 0 THEN
    l_is_working_day := 'Y';
  END IF;

  hr_utility.trace('p_assignment_id:'||
    fnd_number.number_to_canonical(p_assignment_id));
  hr_utility.trace('Leaving Is Working Day?'||
    fnd_date.date_to_canonical(p_date));



  RETURN l_is_working_day;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       raise;


END is_working_day; /*is_working_day*/
--
--
--
PROCEDURE add_working_days_wp
  (p_wp_dets      IN            c_wp_dets%ROWTYPE
  ,p_curr_date    IN OUT NOCOPY DATE
  ,p_balance_days IN OUT NOCOPY NUMBER
  )
IS

  l_calc_stdt           DATE;
  l_calc_endt           DATE;
  l_day_no              NUMBER;
  l_days_in_wp          NUMBER;
  l_curr_day_no         NUMBER;
  l_day                 VARCHAR2(30);
  l_hours               NUMBER := 0;
  l_continue            VARCHAR2(1) := 'Y';

  l_curr_date_nc       DATE;
  l_balance_days_nc    NUMBER;


BEGIN -- add_working_days_wp

  hr_utility.set_location('Entered get_next_working_date_WP', 10);

  -- nocopy changes tmehra
  l_curr_date_nc     := p_curr_date;
  l_balance_days_nc  := p_balance_days;

  /* Determine Calculation Start Date for this Work Pattern */
  if p_curr_date > p_wp_dets.effective_start_date
  then
    l_calc_stdt := p_curr_date;
  else
    l_calc_stdt := p_wp_dets.effective_start_date;
  end if;

  /* Set Calculation End Date for this Work Pattern */
  l_calc_endt := p_wp_dets.effective_end_date;

  /* Get day number on calculation start date and number of days in Work Pattern
  */
  get_day_dets
    (p_wp_dets    => p_wp_dets
    ,p_calc_stdt  => l_calc_stdt
    ,p_calc_edt   => l_calc_endt
    ,p_day_no     => l_day_no     /* OUT NOCOPY */
    ,p_days_in_wp => l_days_in_wp /* OUT NOCOPY */
    );

  l_curr_day_no := l_day_no;

  hr_utility.set_location('l_curr_day_no :'||l_curr_day_no, 20);
  hr_utility.set_location('p_curr_date :'||p_curr_date, 30);
  hr_utility.set_location('Work Pattern :'||p_wp_dets.work_pattern, 40);

  -- Loop throug the dates starting from p_curr_date
  -- PS : we don't know till when to loop, so p_balance_days
  --          will be used as a balance counter
  loop -- Through dates starting with p_curr_date

    l_day := 'Day '||lpad(l_curr_day_no,2,0);

    hr_utility.set_location('Processing date :'||to_char(p_curr_date,
    'DD/MM/YYYY'), 60);

    begin
      l_hours := hruserdt.get_table_value
                   (p_bus_group_id   => p_wp_dets.business_group_id
                   ,p_table_name     => g_udt_name
                   ,p_col_name       => p_wp_dets.work_pattern
                   ,p_row_value      => l_day
                   ,p_effective_date => p_curr_date
                   );
    exception
      when no_data_found then
        /*
         * No data was entered. Do not add to total
         * or count the day in the loop.
         */
        l_hours := 0;
    end;

    hr_utility.set_location('Hours on '||l_day||' = '||l_hours, 70);

    -- Decrement working days balance if l_curr_day_no
    -- is a working day
    if l_hours > 0 then

      p_balance_days := p_balance_days - 1;

    end if;

    -- If we have counted down all the working days then exit
    if p_balance_days = 0 then
      l_continue := 'N';
      exit;
    end if;

    /* Calculate next day no */
    if l_curr_day_no = l_days_in_wp then
      l_curr_day_no := 1;
    else
      l_curr_day_no := l_curr_day_no + 1;
    end if;

    -- Increment to the next date
    p_curr_date := p_curr_date + 1;

    -- The WP has changed, exit, but continue process using the next
    -- effective work pattern row
    if p_curr_date > p_wp_dets.effective_end_date then
      l_continue := 'Y';
      exit;
    end if;

  end loop; -- Through dates starting with p_curr_date

  hr_utility.set_location('Leaving get_next_working_date_wp', 100);
  RETURN;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Exception Block : When others',110);
       p_curr_date := l_curr_date_nc;
       p_balance_days := l_balance_days_nc;
       raise;


END add_working_days_wp;

FUNCTION add_working_days
 (p_assignment_id     IN     NUMBER
 ,p_business_group_id IN     NUMBER
 ,p_date_start        IN     DATE
 ,p_days              IN     NUMBER
 ,p_error_code           OUT NOCOPY NUMBER
 ,p_error_message        OUT NOCOPY VARCHAR2
 ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
 ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
 ) RETURN DATE
IS

  l_balance_days        NUMBER;
  l_curr_date           DATE;
  l_calc_stdt           DATE;
  l_calc_endt           DATE;
  l_day_no              NUMBER;
  l_days_in_wp          NUMBER;
  l_curr_day_no         NUMBER;
  l_day                 VARCHAR2(30);
  l_hours               NUMBER := 0;
  l_continue            VARCHAR2(1) := 'Y';
  l_asg_wp_found        BOOLEAN := FALSE;
  l_error_code          NUMBER := 0;
  l_err_msg_name        fnd_new_messages.message_name%TYPE;

  r_wp_dets             c_wp_dets%ROWTYPE;
  r_def_wp_dets         c_wp_dets%ROWTYPE;

BEGIN /*add_working_days*/

  hr_utility.set_location('Entered add_working_days', 10);
  hr_utility.set_location('UDT Name :'||g_udt_name, 20);

  -- Add 1 to working days and assign to balance days
  -- We need to this as we want to return the date
  -- prior to the NEXT working day after p_days working days
  -- have been added to start date
  l_balance_days := floor(p_days) + 1;

  l_curr_date := p_date_start;

  for r_wp_dets in c_wp_dets_up(p_assignment_id, p_date_start)
  loop   /* Get Work Pattern Details */

    -- Only if this aat record contains a work pattern
    if r_wp_dets.work_pattern is not null then

      hr_utility.set_location('Asg WP Found', 30);
      l_asg_wp_found := TRUE;

      if l_curr_date between r_wp_dets.effective_start_date
                         and r_wp_dets.effective_end_date then

        add_working_days_wp
          (p_wp_dets      => r_wp_dets
          ,p_curr_date    => l_curr_date    -- IN OUT
          ,p_balance_days => l_balance_days  -- IN OUT
          );
        --
      elsif p_default_wp IS NOT NULL then
        -- Use the default work pattern for the period where there is no
        -- work pattern on assignment and then use the asg work pattern

        hr_utility.set_location('Using default and Asg WP', 50);

        -- Step 1) Add days for the default work pattern
        r_def_wp_dets := NULL;
        r_def_wp_dets.effective_start_date := l_curr_date;
        -- set effective end date as the day before the Asg WP becomes effective
        r_def_wp_dets.effective_end_date := (r_wp_dets.effective_start_date -
        1);
        r_def_wp_dets.business_group_id := p_business_group_id;
        r_def_wp_dets.work_pattern := p_default_wp;
        r_def_wp_dets.start_day := 'Day '||LPAD(TO_CHAR(8 -
                               (NEXT_DAY(l_curr_date, g_default_start_day) -
                               l_curr_date)),2,'0');

        hr_utility.set_location('Start Day :'||r_def_wp_dets.start_day, 50);

        add_working_days_wp
         (p_wp_dets                => r_def_wp_dets
         ,p_curr_date              => l_curr_date    -- IN OUT
         ,p_balance_days           => l_balance_days  -- IN OUT
         );

        -- Step 2) Add days for the assignment work pattern
        -- But, only if there are more days to be added
        if l_balance_days > 0 then
          add_working_days_wp
           (p_wp_dets => r_wp_dets
           ,p_curr_date              => l_curr_date    -- IN OUT
           ,p_balance_days           => l_balance_days  -- IN OUT
           );
        end if;
        --
      else -- No default work pattern found, raise error and exit the loop.
        l_error_code := -1;
        l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
        exit;
      end if; -- l_calc_stdt between r_wp_dets.effective_start_date
      --
    end if; -- if r_wp_dets.work_pattern is not null then
    -- Exit the loop if there are no more days to add
    if l_balance_days = 0 then
      exit;
    end if;
    --
  end loop; /* Get Work Pattern Details */

  if l_error_code = 0 --  No errors have occured
     AND
     ( -- No WP found on AAT
      NOT l_asg_wp_found
      OR
      -- not enough WP history on AAT so more days still to be added
      l_balance_days > 0
     ) then

    if p_default_wp IS NOT NULL then

      hr_utility.set_location('Asg WP NOT Found, default WP available', 40);

      r_def_wp_dets := NULL;
      r_def_wp_dets.effective_start_date := l_curr_date;
      r_def_wp_dets.effective_end_date := hr_api.g_eot; -- End of Time
      r_def_wp_dets.business_group_id := p_business_group_id;
      r_def_wp_dets.work_pattern := p_default_wp;
      r_def_wp_dets.start_day := 'Day '||LPAD(TO_CHAR(8 -
                             (NEXT_DAY(l_curr_date, g_default_start_day) -
                             l_curr_date)),2,'0');

      hr_utility.set_location('Start Day :'||r_def_wp_dets.start_day, 50);

      add_working_days_wp
        (p_wp_dets      => r_def_wp_dets
        ,p_curr_date    => l_curr_date    -- IN OUT
        ,p_balance_days => l_balance_days  -- IN OUT
        );
    else
      l_error_code := -1;
      l_err_msg_name := 'PQP_230589_NO_WORK_PATTERN';
    end if;
    --
  end if; -- if NOT l_asg_wp_found the

  -- Check for errors
  if l_error_code = 0 then

    -- Check if balance has been zeroed, if not, error.
    if l_balance_days > 0 then
      l_error_code := -2;
      l_err_msg_name := 'PQP_230590_WP_HIST_INCOMPLETE';
    else -- No errors
      l_curr_date := l_curr_date - 1; -- previous day to next working day
    end if;
    --
  end if; -- l_error_code = 0 then

  p_error_code := l_error_code;
  --
  if l_err_msg_name IS NOT NULL then
    p_error_message := substr(fnd_message.get_string('PQP',l_err_msg_name)
                             ,255 -- Bugfix 3405270
                             );
  end if;

  return l_curr_date;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.trace('Exception Block : When others');
       p_error_code := SQLCODE;
       p_error_message := SQLERRM;
       raise;


END add_working_days;

FUNCTION calculate_days_worked
  (p_assignment_id          IN    NUMBER
  ,p_date_start             IN    DATE
  ,p_date_end               IN    DATE
  ) RETURN NUMBER
IS

  l_hours_worked        NUMBER;

BEGIN /*calculate_days_worked*/

  -- Reset g_days_worked
  g_days_worked := 0;

  -- Call the time(hours) worked function.
  -- This function calculatea the days worked and stores it in g_days_worked
  l_hours_worked := calculate_time_worked
                        (p_assignment_id        => p_assignment_id
                        ,p_date_start           => p_date_start
                        ,p_date_end             => p_date_end
                        );

  RETURN g_days_worked;

END calculate_days_worked;

-- Returns the number of Working Days in a Workpattern
-- as on the effective date
-- it takes 2 optional parameters p_override_wp, p_default_wp
-- Order of precedence is Override->Assignment->Default
FUNCTION get_working_days_in_week (
                 p_assignment_id     IN NUMBER
                ,p_business_group_id IN NUMBER
                ,p_effective_date    IN DATE
                ,p_default_wp        IN VARCHAR2
                ,p_override_wp       IN VARCHAR2
                ) RETURN NUMBER
IS
  l_retval number ;
  l_value pay_user_column_instances_f.value%TYPE ;
  l_error_message fnd_new_messages.message_text%TYPE ;
  l_proc_name  VARCHAR2(61) := g_package_name||'get_working_days_in_week';
  l_proc_step  NUMBER(20,10) ;
  l_work_pattern pqp_assignment_attributes_f.work_pattern%TYPE ;
  l_errbuff    VARCHAR2(200);
  l_retcode    NUMBER;

  --l_count number ;

  CURSOR csr_get_wp IS
  select work_pattern
  from   pqp_assignment_attributes_f paa
  where  assignment_id = p_assignment_id
    and  business_group_id = p_business_group_id
    and  p_effective_date between paa.effective_start_date
                              and paa.effective_end_date ;
begin
   IF g_debug THEN
    pqp_utilities.debug_enter(l_proc_name);
    pqp_utilities.debug('p_assignment_id:'||p_assignment_id);
    pqp_utilities.debug('p_business_group_id:'||p_business_group_id);
    pqp_utilities.debug('p_effective_date:'||p_effective_date);
   END IF;

  IF p_override_wp IS NOT NULL THEN
    l_proc_step := 10 ;
    IF g_debug THEN
      pqp_utilities.debug(' Override WP:'||p_override_wp);
    END IF;
    l_work_pattern := p_override_wp ;
  ELSE
    l_proc_step := 20 ;

    OPEN  csr_get_wp ;
    FETCH csr_get_wp  INTO l_work_pattern ;
    CLOSE csr_get_wp ;

  END IF;

    l_work_pattern := NVL(l_work_pattern,p_default_wp);

  l_proc_step := 30 ;
  IF g_debug THEN
    pqp_utilities.debug('Work Pattern:'||l_work_pattern);
  END IF ;

  IF l_work_pattern IS NOT NULL THEN

--    FOR i in 1..7 loop
     l_retval := pqp_utilities.pqp_gb_get_table_value(
                   p_business_group_id => p_business_group_id
                  ,p_effective_date    => p_effective_date
                  ,p_table_name        => 'PQP_COMPANY_WORK_PATTERNS'
                  ,p_column_name       => l_work_pattern
                  ,p_row_name          => 'Average Working Days Per Week'
		                          --'Day 0'||i
                  ,p_value             => l_value
                  ,p_error_msg         => l_error_message
                   ) ;


--      if l_value > 0 then
--         l_count := nvl(l_count,0) + 1 ;
--      end if ;
--    end loop ;
         -- If the value for Average working days per week does not exist
	 -- calculate the same and update the udt and refetch the value.
         IF l_value IS NULL THEN

	    l_proc_step := 35 ;
            IF g_debug THEN
                pqp_utilities.debug(l_proc_step);
                pqp_utilities.debug('p_assignment_id:'||p_assignment_id);
            END IF;

	    pqp_update_work_pattern_table.update_working_days_in_week
             (errbuf                => l_errbuff
             ,retcode               => l_retcode
             ,p_column_name         => l_work_pattern
             ,p_business_group_id   => p_business_group_id
             ,p_overwrite_if_exists => 'Y'
             );

	    l_proc_step := 40 ;
            IF g_debug THEN
                pqp_utilities.debug(l_proc_step);
                pqp_utilities.debug('errbuf:'||l_errbuff);
                pqp_utilities.debug('retcode:',l_retcode);
            END IF;

	    l_retval :=
	    pqp_utilities.pqp_gb_get_table_value
	    (p_business_group_id => p_business_group_id
            ,p_effective_date    => p_effective_date
            ,p_table_name        => 'PQP_COMPANY_WORK_PATTERNS'
            ,p_column_name       => l_work_pattern
            ,p_row_name          => 'Average Working Days Per Week'
	    ,p_value             => l_value
            ,p_error_msg         => l_error_message
            ,p_refresh_cache     =>'Y'
            ) ;

	    l_proc_step := 45 ;
            IF g_debug THEN
                pqp_utilities.debug(l_proc_step);
                pqp_utilities.debug('l_error_message:'||l_error_message);
                pqp_utilities.debug('l_retval:',l_retval);
                pqp_utilities.debug('l_value:',l_value);
            END IF;

           IF l_value IS NULL THEN
              fnd_message.set_name( 'PQP', 'PQP_230138_INV_WORK_PATTERN' );
              fnd_message.set_token( 'WORKPATTERN ',l_work_pattern);
	      fnd_message.raise_error ;
           END IF;


	 END IF ;

   END IF; -- l_work_pattern IS NOT NULL THEN


    IF g_debug THEN
      pqp_utilities.debug_exit(l_proc_name) ;
    END IF ;

  RETURN l_value ; -- l_count ;

  EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        pqp_utilities.debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_working_days_in_week ;
--
--
--
FUNCTION get_day_index_for_date
  (p_asg_work_pattern_start_date  IN DATE
  ,p_asg_work_pattern_start_day_n IN NUMBER
  ,p_total_days_in_work_pattern   IN NUMBER
  ,p_date_to_index                IN DATE
  ) RETURN NUMBER
IS

l_date_index                   BINARY_INTEGER;
l_days_to_first_day_of_Day01   BINARY_INTEGER;
l_first_date_of_asg_on_Day01   DATE;
l_days_between_start_and_first NUMBER;

l_proc_step          NUMBER(20,10):=0;
l_proc_name          VARCHAR2(61):= g_package_name||'get_day_index_for_date';

BEGIN

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

  IF p_asg_work_pattern_start_date IS NULL
  THEN
  -- then it was either the default or override
  -- so use the 7 day week logic with wp starting on Sunday(or preset global day of week) on Day 1

    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_date_index := NEXT_DAY(p_date_to_index, g_default_start_day) - p_date_to_index;

  ELSE
  -- it is assignment level work patter, duplicate get_day_dets logic
  -- save on the perf issue in this function

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_days_to_first_day_of_Day01 := p_total_days_in_work_pattern - p_asg_work_pattern_start_day_n + 1;
    l_first_date_of_asg_on_Day01 := p_asg_work_pattern_start_date + l_days_to_first_day_of_Day01;
    l_days_between_start_and_first :=  p_date_to_index - l_first_date_of_asg_on_Day01;

    IF l_days_between_start_and_first < 0  THEN
      l_proc_step := 22;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_date_index := p_total_days_in_work_pattern - ABS(l_days_between_start_and_first) + 1;
    ELSE
      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_date_index := MOD(ABS(l_days_between_start_and_first),p_total_days_in_work_pattern)  + 1;
    END IF;

  END IF; -- IF p_asg_work_pattern_start_date IS NULL

  IF g_debug THEN
    debug('l_date_index:'||l_date_index);
    debug_exit(l_proc_name);
  END IF;

  RETURN l_date_index;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_day_index_for_date;
--
--
--
PROCEDURE load_work_pattern_into_cache
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ,p_work_pattern_used              OUT NOCOPY VARCHAR2
  ,p_asg_work_pattern_start_day_n   OUT NOCOPY BINARY_INTEGER
  ,p_asg_work_pattern_start_date    OUT NOCOPY DATE
  ,p_date_start_day_index           OUT NOCOPY BINARY_INTEGER
  )
IS

  l_work_pattern_to_use          pay_user_columns.user_column_name%TYPE;
  l_user_column_id               pay_user_columns.user_column_id%TYPE;
  l_pqp_assignment_attributes    c_wp_dets_up%ROWTYPE;
  l_day_NN_name                  pay_user_rows_f.row_low_range_or_name%TYPE;
  l_asg_work_pattern_start_day_n BINARY_INTEGER;
  i                              BINARY_INTEGER;
  j                              BINARY_INTEGER;
  l_asg_work_pattern_start_date  DATE;
  l_date_start_day_index         BINARY_INTEGER;
  l_legislation_code             pay_user_rows_f.legislation_code%TYPE;
  l_next_working_day_found       BOOLEAN;
  l_hours                        NUMBER;

  l_proc_step          NUMBER(20,10):=0;
  l_proc_name          VARCHAR2(61):= g_package_name||'load_work_pattern_into_cache';


  CURSOR csr_get_user_column_id
    (p_user_table_name          VARCHAR2
    ,p_user_column_name         VARCHAR2
    ,p_business_group_id        NUMBER
    ,p_legislation_code         VARCHAR2
    ) IS
  SELECT ucs.user_column_id
  FROM   pay_user_tables    uts
        ,pay_user_columns   ucs
  WHERE  uts.user_table_name = p_user_table_name -- PQP_COMPANY_WORK_PATTERNS
    AND  uts.business_group_id IS NULL
    AND  uts.legislation_code = p_legislation_code -- as one table is seeded per legislation
    AND  ucs.user_table_id   = uts.user_table_id -- only work patterns that belong to the above table
    AND  ucs.user_column_name = p_user_column_name -- which match this name work_pattern_name
    AND  ( ucs.business_group_id = p_business_group_id -- in the users bg
          OR
           (ucs.business_group_id IS NULL  -- or seeded
            AND
            ucs.legislation_code = p_legislation_code -- for the users legislation code
           )
         );


  --local cursor to pull work pattern this will looped and cached into t_work_pattern_cache_type
  --

  CURSOR csr_work_pattern_hours
    (p_user_column_id    pay_user_columns.user_column_id%TYPE
    ,p_business_group_id NUMBER
    ,p_legislation_code  VARCHAR2
    ,p_effective_date    DATE
    ) IS
  SELECT  uci.user_row_id
         ,uci.value hours_in_text
         ,uci.effective_start_date
         ,uci.effective_end_date
  FROM    pay_user_column_instances_f uci
  WHERE   uci.user_column_id = p_user_column_id -- represents the work pattern
    AND   p_effective_date
            BETWEEN uci.effective_start_date
                AND uci.effective_end_date
    AND   ( uci.business_group_id = p_business_group_id
           OR
            ( uci.business_group_id IS NULL
             AND
              uci.legislation_code = p_legislation_code
            )
          );

  CURSOR csr_work_pattern_days
    (p_user_row_id       pay_user_rows_f.user_row_id%TYPE
    ,p_effective_date    DATE

    ) IS
  SELECT  urw.row_low_range_or_name day_name
  FROM    pay_user_rows_f  urw
  WHERE   urw.user_row_id = p_user_row_id
    AND   p_effective_date
            BETWEEN urw.effective_start_date
                AND urw.effective_end_date
    AND   urw.row_low_range_or_name like
           'Day __';


BEGIN
--/*
--1. Determine the required working pattern, ie assignment, default or override
--2. Cache if not allready (and if not effective as if date_start)
--*/

--1. Determine the required working pattern, ie assignment, default or override

  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;


  IF p_override_wp IS NOT NULL
  THEN

    l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    l_work_pattern_to_use := p_override_wp;

  ELSE
    --1. Is there an assignment level work pattern effective as of date start
    --2. If use the default work pattern
    -- ideally from a CS perspective this shouldn't happen
    -- but the function is generic so we code for default also.

    l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
    END IF;

    OPEN c_wp_dets_up(p_assignment_id, p_date_start);
    FETCH c_wp_dets_up INTO l_pqp_assignment_attributes;
    IF c_wp_dets_up%FOUND
      AND
       l_pqp_assignment_attributes.work_pattern IS NOT NULL
    THEN
      l_proc_step := 22;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_work_pattern_to_use := l_pqp_assignment_attributes.work_pattern;
      l_asg_work_pattern_start_day_n
        := fnd_number.canonical_to_number(TRIM(SUBSTR(l_pqp_assignment_attributes.start_day,5,2)));
      l_asg_work_pattern_start_date := l_pqp_assignment_attributes.effective_start_date;
    ELSE
      l_proc_step := 25;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      l_work_pattern_to_use := NVL(p_default_wp,'PQP_MON_FRI_8_HOURS');
    END IF;
    CLOSE c_wp_dets_up;

  END IF; -- IF p_override_wp IS NOT NULL

  IF g_debug THEN
    debug('Cache Reload Check');
    debug('g_last_business_group_id:'||g_last_business_group_id);
    debug('g_last_used_work_pattern:'||g_last_used_work_pattern);
    debug('l_work_pattern_to_use:'||l_work_pattern_to_use);
    debug('p_date_start:'||fnd_date.date_to_canonical(p_date_start));
    debug('g_last_max_effective_start_dt:'||
      fnd_date.date_to_canonical(g_last_max_effective_start_dt));
    debug('g_last_min_effective_end_dt:'||
      fnd_date.date_to_canonical(g_last_min_effective_end_dt));
  END IF;

--2. Cache if not allready (and if not effective as if date_start)

IF g_last_business_group_id IS NULL
  OR
   g_last_used_work_pattern IS NULL
  OR
   g_last_max_effective_start_dt IS NULL
  OR
   g_last_min_effective_end_dt IS NULL
  OR
   g_last_business_group_id <> p_business_group_id -- if the bg has changed reload
  OR
   ( p_business_group_id = g_last_business_group_id -- OR if the bg is the same but the
    AND
     (
      l_work_pattern_to_use <> g_last_used_work_pattern -- work pattern has changed
     OR
      NOT p_date_start BETWEEN g_last_max_effective_start_dt -- or new cache may not be effective
                              AND g_last_min_effective_end_dt   --

     )
   )
THEN

  l_proc_step := 35;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;

   -- reload cache
   g_last_business_group_id := p_business_group_id;
   g_last_max_effective_start_dt := NULL;
   g_last_min_effective_end_dt := NULL;

   g_last_used_work_pattern      := l_work_pattern_to_use;
   g_asg_work_pattern_start_day_n:= l_asg_work_pattern_start_day_n;
   g_asg_work_pattern_start_date := l_asg_work_pattern_start_date;


  -- at this time l_work_pattern_to_use represents the work pattern to be cached

  l_legislation_code := get_legislation_code(p_business_group_id);

  OPEN csr_get_user_column_id
    (p_user_table_name          => g_udt_name
    ,p_user_column_name         => l_work_pattern_to_use
    ,p_business_group_id        => p_business_group_id
    ,p_legislation_code         => l_legislation_code
    );
  FETCH csr_get_user_column_id INTO l_user_column_id;
  -- IF not found raise some error -- most probably override is misspelt
  CLOSE csr_get_user_column_id;

  --g_user_column_id := l_user_column_id;
  --g_effective_date_of_wp := p_date_start;

  l_proc_step := 40;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;


  i := 0;
  FOR this_day IN
    csr_work_pattern_hours
       (p_user_column_id    => l_user_column_id
       ,p_business_group_id => p_business_group_id
       ,p_legislation_code  => l_legislation_code
       ,p_effective_date    => p_date_start
       )
  LOOP

   i := i + 1;

   l_proc_step := 40+i/10000;
   IF g_debug THEN
     debug_enter(l_proc_name,40+i/10000);
   END IF;


    l_hours := fnd_number.canonical_to_number(this_day.hours_in_text);

    g_last_max_effective_start_dt
     := NVL(GREATEST(this_day.effective_start_date,g_last_max_effective_start_dt)
           ,this_day.effective_start_date);

    g_last_min_effective_end_dt
      := NVL(LEAST(this_day.effective_end_date,g_last_min_effective_end_dt)
            ,this_day.effective_end_date);

    --IF l_hours > 0 THEN --?? upload only working days --should we ??
      -- this is done in two steps to keep out of perf issues / being flagged
      OPEN csr_work_pattern_days
        (p_user_row_id       => this_day.user_row_id
        ,p_effective_date    => p_date_start
        );
      FETCH csr_work_pattern_days INTO l_day_NN_name;

      IF csr_work_pattern_days%FOUND THEN
        l_proc_step := 45+i/10000;
        IF g_debug THEN
          debug_enter(l_proc_name,40+i/10000);
        END IF;
      -- l_day := 'Day '||lpad(l_curr_day_no,2,0);
      j := fnd_number.canonical_to_number(TRIM(SUBSTR(l_day_NN_name,5,2)));
      g_work_pattern_cache(j).hours := l_hours;
      END IF;
      CLOSE csr_work_pattern_days;
    --END IF; -- IF l_hours > 0 THEN

  END LOOP; -- FOR every day in this work pattern load into cache

  l_proc_step := 50;
  IF g_debug THEN
    debug(l_proc_name,l_proc_step);
  END IF;


  i := g_work_pattern_cache.FIRST;
  WHILE i IS NOT NULL
  LOOP

  l_proc_step := 55+i/10000;
  IF g_debug THEN
    debug_enter(l_proc_name,55+i/10000);
  END IF;

   j := g_work_pattern_cache.NEXT(i);

   IF j IS NULL -- i is the last entry
   THEN
     -- so loop j around to the beginning
     j := g_work_pattern_cache.FIRST;
   END IF;

   l_next_working_day_found := FALSE;

    l_proc_step := 60+i/10000;
    IF g_debug THEN
      debug_enter(l_proc_name,65+i/10000);
    END IF;

   WHILE j <> i -- if j is NULL and its a one day work pattern (j=i) this loop won't start
   LOOP

    l_proc_step := 65+(i/10000)+(j/1000000);
    IF g_debug THEN
      debug_enter(l_proc_name,65+(i/10000)+(j/1000000));
    END IF;

      g_work_pattern_cache(i).days_to_next_working_day :=
         NVL(g_work_pattern_cache(i).days_to_next_working_day,0) + 1;

     IF g_work_pattern_cache(j).hours > 0 THEN
      l_proc_step := 67+(i/10000)+(j/1000000);
      IF g_debug THEN
        debug_enter(l_proc_name,67+(i/10000)+(j/1000000));
      END IF;
       g_work_pattern_cache(i).next_working_day_index := j;
       l_next_working_day_found := TRUE;
       EXIT; -- a working day has been found
     END IF;

     j := g_work_pattern_cache.NEXT(j);
     IF j IS NULL THEN
      l_proc_step := 69+(i/10000)+(j/1000000);
      IF g_debug THEN
        debug_enter(l_proc_name,69+(i/10000)+(j/1000000));
      END IF;
       -- prev j was the last so loop around to the beginning
       j := g_work_pattern_cache.FIRST;
     END IF;

   END LOOP; -- inner loop find next working day

   l_proc_step := 70+(i/10000);
   IF g_debug THEN
     debug_enter(l_proc_name,70+(i/10000));
   END IF;

   IF NOT l_next_working_day_found THEN
   -- we have looped around and no other working days were found and are back to the same day
   -- or that it was a one day work pattern
   -- in either case if this is the only working day so set i itself as its next index
   -- and one more to the days to next working day figure
   -- if this day itself is not a working day then it means that all days in this
   -- work pattern have been setup with 0, so exit loop, don't bother populating other days

     l_proc_step := 72+(i/10000);
     IF g_debug THEN
       debug_enter(l_proc_name,72+(i/10000));
     END IF;

     IF g_work_pattern_cache(i).hours > 0 THEN
       l_proc_step := 75+(i/10000);
       IF g_debug THEN
         debug_enter(l_proc_name,75+(i/10000));
       END IF;
       g_work_pattern_cache(i).days_to_next_working_day :=
         NVL(g_work_pattern_cache(i).days_to_next_working_day,0) + 1;
       g_work_pattern_cache(i).next_working_day_index := i;
     ELSE
       l_proc_step := 77+(i/10000);
       IF g_debug THEN
         debug_enter(l_proc_name,77+(i/10000));
       END IF;
       -- clear the days to next working day because there is no next working day
       g_work_pattern_cache(i).days_to_next_working_day := NULL;
       EXIT; -- outer loop
     END IF;

   END IF;

   l_proc_step := 80+(i/10000);
   IF g_debug THEN
     debug_enter(l_proc_name,80+(i/10000));
   END IF;

   i := g_work_pattern_cache.NEXT(i);

  END LOOP; -- loop thru each loaded day in prev step

END IF; --IF g_last_business_group_id <> p_business_group_id -- if the bg has changed reload

   l_proc_step := 90;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;


  p_work_pattern_used             := l_work_pattern_to_use;
  p_asg_work_pattern_start_day_n  := l_asg_work_pattern_start_day_n;
  p_asg_work_pattern_start_date   := l_asg_work_pattern_start_date;

   l_proc_step := 95;
   IF g_debug THEN
     debug(l_proc_name,l_proc_step);
   END IF;

  l_date_start_day_index          :=
    get_day_index_for_date
      (p_asg_work_pattern_start_date  => l_asg_work_pattern_start_date
      ,p_asg_work_pattern_start_day_n => l_asg_work_pattern_start_day_n
      ,p_total_days_in_work_pattern   => g_work_pattern_cache.COUNT
      ,p_date_to_index                => p_date_start
      );

  p_date_start_day_index := l_date_start_day_index;

  IF g_debug THEN
    debug('p_work_pattern_used:'||l_work_pattern_to_use);
    debug('p_asg_work_pattern_start_day_n:'||l_asg_work_pattern_start_day_n);
    debug('p_asg_work_pattern_start_date:'||
      fnd_date.date_to_canonical(l_asg_work_pattern_start_date));
    debug('p_date_start_day_index:'||l_date_start_day_index);
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END load_work_pattern_into_cache;


FUNCTION add_working_days_using_one_wp
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_working_days_to_add    IN     NUMBER
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ) RETURN DATE
IS

l_work_pattern_days             t_work_pattern_cache_type;
l_work_pattern_used             pay_user_columns.user_column_name%TYPE;
l_asg_work_pattern_start_day_n  BINARY_INTEGER;
l_asg_work_pattern_start_date   DATE;
l_date_start_day_index          BINARY_INTEGER;
i                               BINARY_INTEGER;
l_days_remaining_to_add         NUMBER(20);
l_total_calendar_days           NUMBER(20);
l_date_after_n_working_days     DATE;

l_proc_step          NUMBER(20,10):=0;
l_proc_name          VARCHAR2(61):= g_package_name||'add_working_days_using_one_wp';

BEGIN
/*
--3. Deterime the day index for date_start
--4. Decrement the p_days by 1 as we add one day less
--5. Loop thru the cache adding up the index offsets (stored or derived at run time)
--6. With each jump decrement p_days by 1 more
--7. Exit the loop when p_days is 0
--8. Add the sum of index offsets to date_start and return that as the date
--
--9. part p_days is rounded down...ie adding 0.5 returns the same date as adding 1
--10. special check for p_days
*/

g_debug := hr_utility.debug_enabled;
IF g_debug THEN
  debug_enter(l_proc_name);
END IF;

load_work_pattern_into_cache
  (p_assignment_id          => p_assignment_id
  ,p_business_group_id      => p_business_group_id
  ,p_date_start             => p_date_start
  ,p_default_wp             => p_default_wp
  ,p_override_wp            => p_override_wp
  ,p_work_pattern_used             => l_work_pattern_used
  ,p_asg_work_pattern_start_day_n  => l_asg_work_pattern_start_day_n
  ,p_asg_work_pattern_start_date   => l_asg_work_pattern_start_date
  ,p_date_start_day_index          => l_date_start_day_index
  );

l_proc_step := 10;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
END IF;

-- never use g_work_pattern_cache without first calling load_work_pattern_into_cache
l_work_pattern_days := g_work_pattern_cache;
-- always assign cache to locally and then use it

-- now find out the day of the work pattern that date_start corresponds to
-- if this work pattern was the override or the default wp then we simply need to know
-- the day of week and determine the offset assuming Sunday (or a pre-se global) as Day 01
-- if this work pattern was the assignment level work pattern then we need to use the logic in
-- get_day_dets to determine the starting offset

l_proc_step := 20;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
END IF;


l_days_remaining_to_add := CEIL(p_working_days_to_add);
  -- adding 0.5 working day is same adding 1 working day
  -- adding 1.5 working day is same as adding 2 working days

l_total_calendar_days := 0;
i := l_date_start_day_index;

l_proc_step := 30;
IF g_debug THEN
  debug(l_proc_name,l_proc_step);
END IF;

  WHILE l_days_remaining_to_add > 0
       AND i IS NOT NULL -- for wp with all 0 days this will become NULL
       --AND l_total_calendar_days IS NOT NULL -- for wp will all 0 days this will become NULL
  LOOP

    l_proc_step := 32+i/10000;
    IF g_debug THEN
      debug(l_proc_name,32+i/10000);
    END IF;

   IF l_work_pattern_days(i).hours > 0 THEN

     l_proc_step := 35+i/10000;
     IF g_debug THEN
       debug(l_proc_name,35+i/10000);
     END IF;

     l_days_remaining_to_add := l_days_remaining_to_add - 1;

   END IF;

   l_total_calendar_days :=
     l_total_calendar_days +
     l_work_pattern_days(i).days_to_next_working_day;

   i := l_work_pattern_days(i).next_working_day_index;

  END LOOP; -- loop thru each loaded day in prev step

l_proc_step := 40;
IF g_debug THEN
  debug(l_proc_name,40);
END IF;

l_date_after_n_working_days := p_date_start + l_total_calendar_days;

IF g_debug THEN
  debug('l_date_after_n_working_days:'||
         fnd_date.date_to_canonical(l_date_after_n_working_days));
  debug_exit(l_proc_name);
END IF; -- IF g_debug THEN

RETURN l_date_after_n_working_days;

EXCEPTION
  WHEN OTHERS THEN
    clear_cache;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END add_working_days_using_one_wp;


END pqp_schedule_calculation_pkg;

/
