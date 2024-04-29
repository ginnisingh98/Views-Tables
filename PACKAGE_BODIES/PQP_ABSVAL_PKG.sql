--------------------------------------------------------
--  DDL for Package Body PQP_ABSVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ABSVAL_PKG" AS
/* $Header: pqabsbal.pkb 120.16.12010000.5 2009/02/10 07:45:48 vaibgupt ship $ */
--
-- Global Varaibles

g_package_name                VARCHAR2(31):= 'pqp_absval_pkg.';

  g_plan_information            rec_plan_information;
  g_pl_id                       ben_pl_f.pl_typ_id%TYPE;
  g_debug                       BOOLEAN:= hr_utility.debug_enabled;
-- Person Absence Aggregation globals
  g_deduct_absence_for          pqp_configuration_values.PCV_INFORMATION9%TYPE;

-- Cache for rounding of factors
  g_pt_entitl_rounding_type       VARCHAR2(10):=null;
  g_pt_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_ft_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_round_cache_plan_id           NUMBER;
  g_ft_entitl_rounding_type       VARCHAR2(10):=null ;
  g_open_ended_no_pay_days        NUMBER;
  g_log_duration_summary   VARCHAR2(20) := NULL;

--

-- Cursors for processing summary table values

CURSOR csr_pay_level_summary(
                        p_gap_absence_plan_id NUMBER
                       )
    IS
    SELECT    level_of_pay GAP_LEVEL, MIN(absence_date) START_DATE,
              MAX(absence_date) END_DATE, SUM(DURATION) DURATION,
	      SUM(DURATION_IN_HOURS) DURATION_IN_HOURS
    FROM      pqp_gap_daily_absences
    WHERE     gap_absence_plan_id = p_gap_absence_plan_id
    GROUP BY  level_of_pay
    HAVING    level_of_pay LIKE '%BAND%'
              OR level_of_pay LIKE 'NOBANDMIN'
    ORDER BY  level_of_pay ;


CURSOR csr_ent_level_summary(
                        p_gap_absence_plan_id NUMBER
                       )
    IS
    SELECT    level_of_entitlement GAP_LEVEL, MIN(absence_date) START_DATE,
              MAX(absence_date) END_DATE,SUM(DURATION) DURATION,
	      SUM(DURATION_IN_HOURS) DURATION_IN_HOURS
    FROM      pqp_gap_daily_absences
    WHERE     gap_absence_plan_id = p_gap_absence_plan_id
    GROUP BY  level_of_entitlement
    HAVING    level_of_entitlement LIKE '%BAND%'
              OR  level_of_entitlement LIKE 'WAITINGDAY'
    ORDER BY  level_of_entitlement ;


CURSOR csr_level_typ_in_summary(
                         p_gap_absence_plan_id NUMBER
			,p_summary_type VARCHAR2
                       )
    IS
    SELECT    gap_level GAP_LEVEL,gap_duration_summary_id GAP_DURATION_SUMMARY_ID,
              object_version_number OBJECT_VERSION_NUMBER,'D' ACTION_TYPE
    FROM      pqp_gap_duration_summary
    WHERE     summary_type = p_summary_type AND
              gap_absence_plan_id = p_gap_absence_plan_id ;




  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER   DEFAULT NULL
    )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message,p_trace_location);
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number   IN     NUMBER )
  IS
  BEGIN
    pqp_utilities.debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date     IN     DATE )
  IS
  BEGIN
    pqp_utilities.debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2
    ,p_trace_on  IN VARCHAR2 DEFAULT NULL
    )
  IS
--     l_trace_options    VARCHAR2(200);
  BEGIN
    pqp_utilities.debug_enter(p_proc_name,p_trace_on);
  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2
    ,p_trace_off IN VARCHAR2 DEFAULT NULL
    )
  IS
  BEGIN
    pqp_utilities.debug_exit(p_proc_name,p_trace_off);
  END debug_exit;
--
--
--
  PROCEDURE check_error_code
    (p_error_code IN NUMBER
    ,p_message    IN VARCHAR2
    )
  IS
  BEGIN
    pqp_utilities.check_error_code(p_error_code, p_message);
  END check_error_code;
--
--
--
  PROCEDURE debug_others
    (p_proc_name        IN VARCHAR2
    ,p_last_step_number IN NUMBER   DEFAULT NULL
    )
  IS
    l_message  fnd_new_messages.message_text%TYPE;
  BEGIN
      IF g_debug THEN
        debug(p_proc_name,SQLCODE);
        debug(SQLERRM);
      END IF;
      l_message := p_proc_name||'{'||
                   fnd_number.number_to_canonical(p_last_step_number)||'}: '||
                   SUBSTRB(SQLERRM,1,2000);
      IF g_debug THEN
        debug(l_message);
      END IF;
      fnd_message.set_name( 'PQP', 'PQP_230661_OSP_DUMMY_MSG' );
      fnd_message.set_token( 'TOKEN',l_message);
  END debug_others;
--
--
--
  FUNCTION get_scheme_start_date
   (p_assignment_id             IN       NUMBER
   ,p_scheme_period_type        IN       VARCHAR2
   ,p_scheme_period_duration    IN       VARCHAR2
   ,p_scheme_period_uom         IN       VARCHAR2
   ,p_fixed_year_start_date     IN       VARCHAR2
   ,p_balance_effective_date    IN       DATE
   ) RETURN DATE
  IS

    -- Added cursor for anniversary year changes
    CURSOR csr_get_emp_hire_date
    IS
    SELECT service.date_start
      FROM per_all_assignments_f  assign
          ,per_periods_of_service service
     WHERE p_balance_effective_date BETWEEN assign.effective_start_date
                                        AND assign.effective_end_date
       AND assign.assignment_id = p_assignment_id
       AND service.period_of_service_id (+) = assign.period_of_service_id;

    l_scheme_start_date           DATE;

    -- variable to be removed once we change p_fixed_year_start_date to DATE
    l_fixed_year_start_date       DATE:=
      fnd_date.canonical_to_date(p_fixed_year_start_date);

    l_scheme_period_duration      NUMBER(10):=
      fnd_number.canonical_to_number(p_scheme_period_duration);

    l_end_date                    DATE;
    l_temp                        VARCHAR2(25);

    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2( 61 ):=
                                    g_package_name||
                                    'get_scheme_start_date';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_scheme_period_type);
      debug(p_scheme_period_duration);
      debug(p_scheme_period_uom);
      debug(p_fixed_year_start_date);
      debug(p_balance_effective_date);
    END IF;

--    debug('l_scheme_period_duration:');
--    debug(l_scheme_period_duration);
--    IF l_scheme_period_duration IS NULL THEN
--      debug('IS NULL');
--      l_scheme_period_duration :=
--        fnd_number.canonical_to_number(p_scheme_period_duration);
--    END IF;
--    debug('l_scheme_period_duration:');
--    debug(l_scheme_period_duration);

    -- Modified code for annivesary year
    -- to determine the scheme start date we need to know
    -- 1. is the scheme fixed or anniversary or rolling
    -- 2. if its fixed or anniversary
    --    a) scheme start date = DD-MON-YearsOfBalanceDate
    -- 3. if its rolling
    --    a) what is the absence period UOM: days(/weeks) or months(/years) ?
    --    b) scheme start date = BalanceDate - AbsencePeriod

    IF p_scheme_period_type = 'FIXED' OR
       p_scheme_period_type = 'EMPYEAR'
    THEN

        l_proc_step := 10;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;

     -- The logic to calculate the l_scheme start_date is as follows
   -- find the months between the fixed_year_start_date and the absence
   -- start date(P_balance_effective_date),
   -- convert this to years and floor the resultant value.
   -- This gives the difference in yrs. The new
   -- l_scheme_start_date is by adding the number of yrs
   -- with the l_fixed_year_start_date.

   -- This can be understood by the following scenario.(assuming the
  --   scheme is fixed start date.

   --
   --   fixed yr scheme
   --   start date                 Rolling period
   --                             |---------------------------|
   --
   --  |-------------------------|----------------------------|--------------
   --   25-feb-2004               25-feb-2005                 01-nov-2005
   --                             roll back till here         abs start date
   --                            (fixed start date)
   --
   --
   -- In the above scenario, the new l_scheme_start_date should be
   -- 25-feb-2005
   -- The below code handle all scenario, except that when the scheme
   -- is 28-FEB of an non leap year, and the absence is enrolled in
   -- the following year
   -- which is a leap year, so when the date are rolled back from the
   -- absence start date, the fixed year start date should be 28-FEB of the
   -- current year but it rolls back to 29-FEB as its the last day of FEB.
   -- When the scheme start date is 28-FEB-2003 .The absence start date
   -- is 01-nov-2004 its has to be rolled back till 28-FEB-2004
   -- but it roll backs to 29-FEB-2004, as 28-FEB-2003 is the last day
   -- of the months, after rolloing it rolls back to 29-feb-2004, as its the
   -- last day of feb for the current year(2004, which is a leap year).

      IF p_scheme_period_type = 'EMPYEAR'
      THEN
         -- Replace fixed year start date with hire date information
         OPEN csr_get_emp_hire_date;
         FETCH csr_get_emp_hire_date INTO l_fixed_year_start_date;
         CLOSE csr_get_emp_hire_date;
      END IF; -- end if of scheme period type is Anniversary check ...

      l_scheme_start_date:=
      add_months(l_fixed_year_start_date,floor(MONTHS_BETWEEN
      (p_balance_effective_date,l_fixed_year_start_date)/12)*12);

   --l_start_date    := fnd_date.canonical_to_date( l_temp );

   -- if the effective date was 05-FEB-2002
   -- and the scheme start is 01-APR-YYYY
   -- then the prev statement would set the scheme start date as
   -- 01-APR-2002, which would mean that its greater than the eff date
   -- in which case pull the scheme start date back by 1 year (12 months)
   --
   -- |-----------------|---------------|-------------|--------------
   -- 01-APR-2001       05-FEB-2002     01-APR-2002
   -- ^                 ^               ^
   -- ^                 ^EffectiveDate  ^
   -- ^                                 ^
   -- ^                                 ^SchemeStartDate(as per prev calc)
   -- ^SchemeStartDate(should be)       =SchemeStartDate(as per prev calc) - 1 year


      IF l_scheme_start_date > p_balance_effective_date
      THEN
          l_proc_step := 20;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;
        l_scheme_start_date :=
          ADD_MONTHS( l_scheme_start_date, -12 );
      END IF;

    -- the above statement would ensure that the scheme start date is
    -- always the DD-MON preceding the balance effective date, ie it works
    -- fine for fixed years with a duration of 1.

    -- OSP configurations allow fixed years to be more than a year.
    -- so we need to deduct a further "duration - 1" years from the scheme
    -- start date.

    --
    -- |-----------------|---------------|-------------|--------------
    -- 01-APR-2000       01-APR-2001     05-FEB-2002   01-APR-2002
    --                   ^               ^
    --                   ^               ^EffectiveDate
    --                   ^
    --                   ^SchemeStartDate(as per prev calc)
    -- SchemeStartDate   =SchemeStartDate(as per prev calc) - (2-1) years

      IF p_scheme_period_duration > 1
        -- we could do without the if codn also, duration - 1 would be 0
        -- and the date would remain unchanged, but its clearer with the if
        -- and reduces one function call !
      THEN

          l_proc_step := 30;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;

        l_scheme_start_date :=
          ADD_MONTHS(l_scheme_start_date, -12 * (l_scheme_period_duration - 1));

      END IF;

    --
    -- |-----------------|---------------|-------------|--------------
    -- 01-APR-2000       01-APR-2001     05-FEB-2002   01-APR-2002
    --                   ^               ^
    --                   ^               ^EffectiveDate
    --                   ^
    --                   ^SchemeStartDate(as per prev calc)
    -- SchemeStartDate   =SchemeStartDate(as per prev calc) - (2-1) years


    ELSE -- scheme type is ROLLING or DUALROLLING

      -- if the effective date is 05-MAY-2002
      -- the scheme start date is 05-MAY-2002 - absence_period
      -- if the period is 365 days the scheme start date would be 05-MAY-2001
      -- if the period is 52 weeks the scheme start date would be 06-MAY-2001
      -- if the period is 6 months the scheme start date would be 05-NOV-2001
      -- if the period is 1 year(s)the scheme start date would be 05-MAY-2001


      IF    p_scheme_period_uom = 'DAYS'
      THEN

          l_proc_step := 40;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
          --debug(p_balance_effective_date);
          --debug(l_scheme_period_duration);
        END IF;

        l_scheme_start_date:=
         p_balance_effective_date - l_scheme_period_duration;

        --debug(l_scheme_period_duration);

      ELSIF p_scheme_period_uom = 'WEEKS'
      THEN
          l_proc_step := 50;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;

        l_scheme_start_date:=
          p_balance_effective_date - (l_scheme_period_duration * 7);

      ELSIF p_scheme_period_uom = 'MONTHS'
      THEN
          l_proc_step := 60;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;



        l_scheme_start_date:=
          ADD_MONTHS(p_balance_effective_date, ( -l_scheme_period_duration));

      ELSIF p_scheme_period_uom = 'YEARS'
      THEN
          l_proc_step := 70;
        IF g_debug THEN
          debug(l_proc_name,l_proc_step);
        END IF;
        l_scheme_start_date:=
          ADD_MONTHS(p_balance_effective_date, ( -12 * l_scheme_period_duration));

      END IF;

    END IF;

    IF g_debug THEN
      debug('l_scheme_start_date:');
      debug(l_scheme_start_date);
      debug_exit(l_proc_name);
    END IF;

    RETURN l_scheme_start_date;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
        debug_others(l_proc_name,l_proc_step);
        IF g_debug THEN
          debug('Leaving: '||l_proc_name,-999);
        END IF;
        fnd_message.raise_error;
      ELSE
        RAISE;
      END IF;
  END get_scheme_start_date;
--
--
--
FUNCTION pqp_absence_sickness_ytd_ovrld      -- IS FF (analyze use)
  (p_assignment_id             IN       NUMBER
  ,p_business_group_id         IN       NUMBER
  ,p_element_type_id           IN       NUMBER
  ,p_balance_effective_date    IN       DATE
  ,p_calendar_column_name      IN       VARCHAR2
  ,p_calendar_value            IN       VARCHAR2
  ) RETURN NUMBER
IS

  l_balance                     NUMBER(38,5);

BEGIN
  l_balance    :=0;
  RETURN( NVL( l_balance, 0 ));
END pqp_absence_sickness_ytd_ovrld;
--
--
--
  PROCEDURE write_daily_absences
   (p_daily_absences       IN pqp_absval_pkg.t_daily_absences
   ,p_gap_absence_plan_id  IN pqp_gap_absence_plans.gap_absence_plan_id%TYPE
   )
IS

TYPE t_gap_daily_absence_id  IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
TYPE t_gap_absence_plan_id   IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;
TYPE t_absence_date          IS TABLE OF DATE         INDEX BY BINARY_INTEGER;
TYPE t_work_pattern_day_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_level_of_entitlement  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_level_of_pay          IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_duration              IS TABLE OF NUMBER(11,5) INDEX BY BINARY_INTEGER;
TYPE t_duration_in_hours     IS TABLE OF NUMBER(8,5)  INDEX BY BINARY_INTEGER;
TYPE t_working_days_per_week IS TABLE OF NUMBER(15,13) INDEX BY BINARY_INTEGER;
TYPE t_fte                   IS TABLE OF NUMBER(25,5) INDEX BY BINARY_INTEGER;
TYPE t_object_version_number IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;

  l_gap_daily_absence_ids  t_gap_daily_absence_id;
  l_gap_absence_plan_ids   t_gap_absence_plan_id;
  l_absence_dates          t_absence_date;
  l_work_pattern_day_types t_work_pattern_day_type;
  l_level_of_entitlements  t_level_of_entitlement;
  l_level_of_payments      t_level_of_pay;
  l_durations              t_duration;
  l_durations_in_hours     t_duration_in_hours;
  l_working_days_per_week  t_working_days_per_week ;
  l_fte                    t_fte ;
  l_object_version_numbers t_object_version_number;


  l_proc_step             NUMBER(20,10);
  l_proc_name             VARCHAR2(61):=
                          g_package_name||
                          'write_daily_absences';

BEGIN
  IF g_debug THEN
    debug_enter(l_proc_name);
  END IF;

--FORALL i IN 1..5000  -- use FORALL statement
--   INSERT INTO parts VALUES (pnums(i), pnames(i));
--desc pqp_gap_daily_absences
-- Name                            Null?    Type
-- ------------------------------- -------- ----
-- GAP_DAILY_ABSENCE_ID            NOT NULL NUMBER(15)
-- GAP_ABSENCE_PLAN_ID             NOT NULL NUMBER(15)
-- ABSENCE_DATE                    NOT NULL DATE
-- WORK_PATTERN_DAY_TYPE           NOT NULL VARCHAR2(30)
-- LEVEL_OF_ENTITLEMENT            NOT NULL VARCHAR2(30)
-- LEVEL_OF_PAY                    NOT NULL VARCHAR2(30)
-- DURATION                        NOT NULL NUMBER(11,5)
-- LAST_UPDATED_BY                          NUMBER(15)
-- LAST_UPDATE_DATE                         DATE
-- CREATED_BY                               NUMBER(15)
-- CREATION_DATE                            DATE
-- OBJECT_VERSION_NUMBER                    NUMBER(15)
--
-- 8i bulk bind does not support record structures
-- so we need to copy all the record segments into
-- seperate plsql tables. This is unncessary processing
-- but the performance benefit of bulk bind is outweighs
-- this cost.
--
    l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name, 10);
  END IF;

  FOR i IN p_daily_absences.FIRST..p_daily_absences.LAST
  LOOP
    IF g_debug THEN
      debug(l_proc_name, 10+i/1000);
    END IF;

    --l_gap_daily_absence_ids:=  p_daily_absences(i).gap_daily_absence_ids
    l_gap_absence_plan_ids(i)   := p_gap_absence_plan_id;
                                   --p_daily_absences(i).gap_absence_plan_id;
    l_absence_dates(i)          := p_daily_absences(i).absence_date;
    l_work_pattern_day_types(i) := p_daily_absences(i).work_pattern_day_type;
    l_level_of_entitlements(i)  := p_daily_absences(i).level_of_entitlement;
    l_level_of_payments(i)      := p_daily_absences(i).level_of_pay;
    l_durations(i)              := p_daily_absences(i).duration;
    l_durations_in_hours(i)     := p_daily_absences(i).duration_in_hours;
    l_working_days_per_week(i)  := p_daily_absences(i).working_days_per_week;
    l_fte(i)                    := p_daily_absences(i).fte;
    l_object_version_numbers(i) := 1; -- new record

  END LOOP;

    l_proc_step := 20;
  IF g_debug THEN
    debug(l_proc_name, 20);
  END IF;

  FORALL i IN p_daily_absences.FIRST..p_daily_absences.LAST
   INSERT INTO pqp_gap_daily_absences
     (gap_daily_absence_id          --NOT NULL NUMBER(15)
     ,gap_absence_plan_id           --NOT NULL NUMBER(15)
     ,absence_date                  --NOT NULL DATE
     ,work_pattern_day_type         --NOT NULL VARCHAR2(30)
     ,level_of_entitlement          --NOT NULL VARCHAR2(30)
     ,level_of_pay                  --NOT NULL VARCHAR2(30)
     ,duration                      --NOT NULL NUMBER(11,5)
     ,duration_in_hours            --         NUMER(8,5) -- added
     ,working_days_per_week
     ,fte
  --   ,last_updated_by               --         NUMBER(15)
  --   ,last_update_date              --         DATE
  --   ,created_by                    --         NUMBER(15)
  --   ,creation_date                 --         DATE
     ,object_version_number         --         NUMBER(15)
     )
    VALUES
     (pqp_gap_daily_absences_s.NEXTVAL
     ,l_gap_absence_plan_ids(i)           --NOT NULL NUMBER(15)
     ,l_absence_dates(i)                  --NOT NULL DATE
     ,l_work_pattern_day_types(i)         --NOT NULL VARCHAR2(30)
     ,l_level_of_entitlements(i)          --NOT NULL VARCHAR2(30)
     ,l_level_of_payments(i)              --NOT NULL VARCHAR2(30)
     ,l_durations(i)                      --NOT NULL NUMBER(11,5)
     ,l_durations_in_hours(i)             --         NUMBER(8,5)
     ,l_working_days_per_week(i)
     ,l_fte(i)
  --   ,l_last_updated_by                 --         NUMBER(15)
  --   ,l_last_update_date                --         DATE
  --   ,l_created_by                      --         NUMBER(15)
  --   ,l_creation_date                   --         DATE
     ,l_object_version_numbers(i)         --         NUMBER(15)
     );

     l_proc_step := 30;
   IF g_debug THEN
     debug(l_proc_name, 30);
   END IF;

   IF g_debug THEN
     debug_exit(l_proc_name);
   END IF;

END write_daily_absences;
--
--
--
-- Absence Summary Table Changes
-- Process flow ==>

-- 1)Absence created and fresh enrollment
--   create_absence_plan_details
--         => write_absence_summary
--               => create_duration_summary
--                       => write_duration_summary

-- 2)Absence Updated (End Date extended)
--   update_absence_plan_details
--       =>create_absence_plan_details
--             => write_absence_summary
--                  => update_duration_summary
--                         => write_duration_summary

-- 3)Absence Updated (End Date curtailed)
--   update_absence_plan_details
--       =>delete_absence_plan_details
--             => update_duration_summary
--                   => write_duration_summary





PROCEDURE write_duration_summary
   (p_absence_summary_tbl          IN OUT NOCOPY pqp_absval_pkg.t_duration_summary
   )
IS

    l_proc_name  VARCHAR2(61) := g_package_name||'write_duration_summary';
    l_object_version_number NUMBER;
    l_gap_duration_summary_id NUMBER;

    l_proc_step  NUMBER(20,10) ;
    i         BINARY_INTEGER;

BEGIN
    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
   END IF;

     i := p_absence_summary_tbl.FIRST;

       WHILE i IS NOT NULL
       LOOP

	   IF g_debug THEN
	      debug('i' || i);
	      debug('gap_absence_plan_id',p_absence_summary_tbl(i).gap_absence_plan_id);
              debug('assignment_id' ,  p_absence_summary_tbl(i).assignment_id);
              debug('summary_type' || p_absence_summary_tbl(i).summary_type);
	      debug('gap_level' || p_absence_summary_tbl(i).gap_level);
              debug('duration_in_days' ,p_absence_summary_tbl(i).duration_in_days);
              debug('duration_in_hours' ,p_absence_summary_tbl(i).duration_in_hours);
              debug('date_start' || p_absence_summary_tbl(i).date_start);
              debug('date_end' || p_absence_summary_tbl(i).date_end);
              debug('action_type' || p_absence_summary_tbl(i).action_type);
           END IF;

           IF  p_absence_summary_tbl(i).action_type = 'I'
	   THEN


	       pqp_gds_api.create_duration_summary
		 (p_date_start              => p_absence_summary_tbl(i).date_start
		 ,p_date_end                => p_absence_summary_tbl(i).date_end
		 ,p_assignment_id           => p_absence_summary_tbl(i).assignment_id
		 ,p_gap_absence_plan_id     => p_absence_summary_tbl(i).gap_absence_plan_id
		 ,p_duration_in_days        => p_absence_summary_tbl(i).duration_in_days
		 ,p_duration_in_hours       => p_absence_summary_tbl(i).duration_in_hours
		 ,p_summary_type            => p_absence_summary_tbl(i).summary_type
		 ,p_gap_level               => p_absence_summary_tbl(i).gap_level
		 ,p_gap_duration_summary_id => l_gap_duration_summary_id
		 ,p_object_version_number   => l_object_version_number
		  );

	  ELSE -- IF  p_absence_summary_tbl(i).action_type = 'I'

	      pqp_gds_api.update_duration_summary
		 (p_gap_duration_summary_id => p_absence_summary_tbl(i).gap_duration_summary_id
		 ,p_date_start              => p_absence_summary_tbl(i).date_start
		 ,p_date_end                => p_absence_summary_tbl(i).date_end
		 ,p_assignment_id           => p_absence_summary_tbl(i).assignment_id
		 ,p_gap_absence_plan_id     => p_absence_summary_tbl(i).gap_absence_plan_id
		 ,p_duration_in_days        => p_absence_summary_tbl(i).duration_in_days
		 ,p_duration_in_hours       => p_absence_summary_tbl(i).duration_in_hours
		 ,p_summary_type            => p_absence_summary_tbl(i).summary_type
		 ,p_gap_level               => p_absence_summary_tbl(i).gap_level
		 ,p_object_version_number   => p_absence_summary_tbl(i).object_version_number
		  );

	 END IF;

         i := p_absence_summary_tbl.NEXT(i);
       END LOOP;

    IF g_debug THEN
     debug_exit(l_proc_name) ;
    END IF ;
EXCEPTION
WHEN OTHERS THEN

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END write_duration_summary ;


PROCEDURE create_duration_summary
   (p_gap_absence_plan_id           IN NUMBER
   ,p_assignment_id                 IN NUMBER
  )
 IS
    l_proc_name  VARCHAR2(61) := g_package_name||'create_duration_summary';
    l_proc_step  NUMBER(20,10) ;
    k         BINARY_INTEGER;
    l_absence_pay_summary  csr_pay_level_summary%ROWTYPE;
    l_absence_ent_summary  csr_ent_level_summary%ROWTYPE;
    l_ent_summary_existing_rows  pqp_absval_pkg.t_gap_level ;
    l_pay_summary_existing_rows  pqp_absval_pkg.t_gap_level ;
    l_duration_summary pqp_absval_pkg.t_duration_summary ;

BEGIN
    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_gap_absence_plan_id:',p_gap_absence_plan_id);
    debug('p_assignment_id:',p_assignment_id);

   END IF;

    IF g_debug THEN
     debug_exit(l_proc_name) ;
    END IF ;

-- This blocks summarizes the data from pqp_gap_daily_absence table for life
-- time type ENT (probably can us bulk collect in to table).Dint use it as
-- needed to process few attributes and individual level.Need to chk if using
-- bulk collect could be more efficient.

 OPEN csr_ent_level_summary
         (p_gap_absence_plan_id =>p_gap_absence_plan_id);

        k := 1;
        LOOP

         FETCH csr_ent_level_summary INTO l_absence_ent_summary;
            EXIT WHEN csr_ent_level_summary %NOTFOUND ;
            l_duration_summary(k).gap_absence_plan_id := p_gap_absence_plan_id;
   	    l_duration_summary(k).assignment_id := p_assignment_id;
	    l_duration_summary(k).gap_level:=
                               l_absence_ent_summary.gap_level;
            l_duration_summary(k).summary_type:= 'ENT';
            l_duration_summary(k).date_start:= l_absence_ent_summary.START_DATE;
            l_duration_summary(k).date_end:= l_absence_ent_summary.END_DATE;
            l_duration_summary(k).duration_in_days:= l_absence_ent_summary.duration;
            l_duration_summary(k).duration_in_hours:=
                                      l_absence_ent_summary.duration_in_hours;
            l_duration_summary(k).action_type := 'I';
	  k := k+1;
        END LOOP;
    CLOSE csr_ent_level_summary;



   OPEN csr_pay_level_summary
         (p_gap_absence_plan_id =>p_gap_absence_plan_id);

        LOOP

         FETCH csr_pay_level_summary INTO l_absence_pay_summary;
            EXIT WHEN csr_pay_level_summary %NOTFOUND ;
            l_duration_summary(k).gap_absence_plan_id := p_gap_absence_plan_id;
	    l_duration_summary(k).assignment_id := p_assignment_id;
	    l_duration_summary(k).gap_level:=
                               l_absence_pay_summary.gap_level;
            l_duration_summary(k).summary_type:= 'PAY';
            l_duration_summary(k).date_start:=l_absence_pay_summary.START_DATE;
            l_duration_summary(k).date_end:= l_absence_pay_summary.END_DATE;
            l_duration_summary(k).duration_in_days:= l_absence_pay_summary.duration;
            l_duration_summary(k).duration_in_hours:=
                                     l_absence_pay_summary.duration_in_hours;
            l_duration_summary(k).action_type := 'I';
          k := k+1;
        END LOOP;
    CLOSE csr_pay_level_summary;


   write_duration_summary
   (p_absence_summary_tbl      =>   l_duration_summary
   );


EXCEPTION
WHEN OTHERS THEN

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END create_duration_summary ;


PROCEDURE update_duration_summary
   (p_gap_absence_plan_id           IN NUMBER
   ,p_assignment_id                 IN NUMBER
  )
 IS
    l_proc_name  VARCHAR2(61) := g_package_name||'update_duration_summary';
    l_proc_step  NUMBER(20,10) ;
    k         BINARY_INTEGER;
    l         BINARY_INTEGER;
    l_absence_pay_summary  csr_pay_level_summary%ROWTYPE;
    l_absence_ent_summary csr_ent_level_summary%ROWTYPE;
    l_ent_summary_existing_rows  pqp_absval_pkg.t_gap_level ;
    l_pay_summary_existing_rows  pqp_absval_pkg.t_gap_level ;
    l_duration_summary pqp_absval_pkg.t_duration_summary ;

BEGIN
    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_gap_absence_plan_id:',p_gap_absence_plan_id);
    debug('p_assignment_id:',p_assignment_id);

   END IF;

    IF g_debug THEN
     debug_exit(l_proc_name) ;
    END IF ;


        OPEN csr_level_typ_in_summary
                  (p_gap_absence_plan_id =>p_gap_absence_plan_id
                  ,p_summary_type      =>'ENT'
		  );

         FETCH csr_level_typ_in_summary BULK COLLECT
                                 INTO l_ent_summary_existing_rows ;
         CLOSE csr_level_typ_in_summary ;

         OPEN csr_level_typ_in_summary
		 (p_gap_absence_plan_id =>p_gap_absence_plan_id
                  ,p_summary_type      =>'PAY'
		  );

         FETCH csr_level_typ_in_summary BULK COLLECT
                                 INTO l_pay_summary_existing_rows ;
         CLOSE csr_level_typ_in_summary ;



 OPEN csr_ent_level_summary
         (p_gap_absence_plan_id =>p_gap_absence_plan_id);

        k := 1;
        LOOP

         FETCH csr_ent_level_summary INTO l_absence_ent_summary;
            EXIT WHEN csr_ent_level_summary %NOTFOUND ;
            l_duration_summary(k).gap_absence_plan_id := p_gap_absence_plan_id;
   	    l_duration_summary(k).assignment_id := p_assignment_id;
	    l_duration_summary(k).gap_level:=
                               l_absence_ent_summary.gap_level;
            l_duration_summary(k).summary_type:= 'ENT';
            l_duration_summary(k).date_start:= l_absence_ent_summary.START_DATE;
            l_duration_summary(k).date_end:= l_absence_ent_summary.END_DATE;
            l_duration_summary(k).duration_in_days:= l_absence_ent_summary.duration;
            l_duration_summary(k).duration_in_hours:=
                                      l_absence_ent_summary.duration_in_hours;


            l_duration_summary(k).action_type := 'I';

            l := l_ent_summary_existing_rows.FIRST;
            WHILE l IS NOT NULL
            LOOP
	        IF(l_duration_summary(k).gap_level =
		                  l_ent_summary_existing_rows(l).gap_level)
                THEN
                   l_duration_summary(k).action_type := 'U';
		   l_duration_summary(k).gap_duration_summary_id :=
		                l_ent_summary_existing_rows(l).gap_duration_summary_id ;
                   l_duration_summary(k).object_version_number   :=
		               l_ent_summary_existing_rows(l).object_version_number;
                   l_ent_summary_existing_rows(l).action_type := 'U';

		END IF;
              l := l_ent_summary_existing_rows.NEXT(l);
	    END LOOP;
     	  k := k+1;
        END LOOP;
    CLOSE csr_ent_level_summary;




   OPEN csr_pay_level_summary
         (p_gap_absence_plan_id =>p_gap_absence_plan_id);

        LOOP

         FETCH csr_pay_level_summary INTO l_absence_pay_summary;
            EXIT WHEN csr_pay_level_summary %NOTFOUND ;
            l_duration_summary(k).gap_absence_plan_id := p_gap_absence_plan_id;
	    l_duration_summary(k).assignment_id := p_assignment_id;
	    l_duration_summary(k).gap_level:=
                               l_absence_pay_summary.gap_level;
            l_duration_summary(k).summary_type:= 'PAY';
            l_duration_summary(k).date_start:=l_absence_pay_summary.START_DATE;
            l_duration_summary(k).date_end:= l_absence_pay_summary.END_DATE;
            l_duration_summary(k).duration_in_days:= l_absence_pay_summary.duration;
            l_duration_summary(k).duration_in_hours:=
                                      l_absence_pay_summary.duration_in_hours;

            l_duration_summary(k).action_type := 'I';
            l := l_pay_summary_existing_rows.FIRST;
            WHILE l IS NOT NULL
            LOOP
	        IF(l_duration_summary(k).gap_level =
		                  l_pay_summary_existing_rows(l).gap_level)
                THEN
                   l_duration_summary(k).action_type := 'U';
                   l_duration_summary(k).gap_duration_summary_id :=
		                l_pay_summary_existing_rows(l).gap_duration_summary_id ;
                   l_duration_summary(k).object_version_number   :=
		               l_pay_summary_existing_rows(l).object_version_number;
                   l_pay_summary_existing_rows(l).action_type :='U';
		END IF;
              l := l_pay_summary_existing_rows.NEXT(l);
	    END LOOP;
          k := k+1;
        END LOOP;
    CLOSE csr_pay_level_summary;


      l := l_ent_summary_existing_rows.FIRST;
      WHILE l IS NOT NULL
      LOOP
	  IF(l_ent_summary_existing_rows(l).action_type='D')
          THEN
            pqp_gds_api.delete_duration_summary
                 (p_gap_duration_summary_id
		             =>l_ent_summary_existing_rows(l).gap_duration_summary_id
                 ,p_object_version_number
		             =>l_ent_summary_existing_rows(l).object_version_number
                 );
	 END IF;
          l := l_ent_summary_existing_rows.NEXT(l);
      END LOOP;


      l := l_pay_summary_existing_rows.FIRST;
      WHILE l IS NOT NULL
      LOOP
	  IF(l_pay_summary_existing_rows(l).action_type='D')
          THEN
              pqp_gds_api.delete_duration_summary
                 (p_gap_duration_summary_id
		             =>l_pay_summary_existing_rows(l).gap_duration_summary_id
                 ,p_object_version_number
		             =>l_pay_summary_existing_rows(l).object_version_number
                 );
          END IF;
          l := l_pay_summary_existing_rows.NEXT(l);
      END LOOP;


    write_duration_summary
   (p_absence_summary_tbl      =>   l_duration_summary
   );


l_ent_summary_existing_rows.DELETE;
l_pay_summary_existing_rows.DELETE;
l_duration_summary.DELETE;

EXCEPTION
WHEN OTHERS THEN

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END update_duration_summary ;


PROCEDURE write_absence_summary
(p_gap_absence_plan_id           IN NUMBER
,p_assignment_id                 IN NUMBER
,p_entitlement_granted           IN pqp_absval_pkg.t_entitlements
,p_entitlement_used_to_date      IN pqp_absval_pkg.t_entitlements
,p_entitlement_remaining         IN pqp_absval_pkg.t_entitlements
,p_fte                           IN NUMBER DEFAULT 1
,p_working_days_per_week         IN NUMBER DEFAULT NULL
,p_entitlement_uom               IN VARCHAR2
,p_update                        IN BOOLEAN
)
IS

    l_proc_name  VARCHAR2(61) := g_package_name||'write_absence_summary';
    l_proc_step  NUMBER(20,10) ;

BEGIN
    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_gap_absence_plan_id:',p_gap_absence_plan_id);
    debug('p_assignment_id:',p_assignment_id);
    debug('p_fte:',p_fte);
    debug('p_working_days_per_week:',p_working_days_per_week);
   END IF;


   IF p_update
   THEN
       update_duration_summary
       (p_gap_absence_plan_id          => p_gap_absence_plan_id
       ,p_assignment_id                => p_assignment_id
      );
   ELSE
       create_duration_summary
       (p_gap_absence_plan_id          => p_gap_absence_plan_id
       ,p_assignment_id                => p_assignment_id
      );
   END IF ;
    IF g_debug THEN
     debug_exit(l_proc_name) ;
    END IF ;

EXCEPTION
WHEN OTHERS THEN

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END write_absence_summary ;


PROCEDURE delete_absence_plan_details
  (p_assignment_id             IN            NUMBER -- unused
  ,p_business_group_id         IN            NUMBER -- unused
  ,p_plan_id                   IN            NUMBER
  ,p_absence_id                IN            NUMBER
  ,p_delete_start_date        IN            DATE
  ,p_delete_end_date          IN            DATE
  ,p_error_code                   OUT NOCOPY NUMBER
  ,p_message                      OUT NOCOPY VARCHAR2
  )
IS

    CURSOR csr_gap_dur_sum_rows(p_gap_absence_plan_id NUMBER)
    IS
    SELECT    gap_duration_summary_id ,
              object_version_number
    FROM      pqp_gap_duration_summary
    WHERE     gap_absence_plan_id = p_gap_absence_plan_id ;


  l_proc_step                   NUMBER(20,10);
  l_proc_name                   VARCHAR2( 61 ):=
                                  g_package_name||
                                  'delete_absence_plan_details';


  l_error_code                  fnd_new_messages.message_number%TYPE;
  l_error_message               fnd_new_messages.message_text%TYPE;
  l_gap_daily_absences_exists   csr_gap_daily_absences_exists%ROWTYPE;
  l_gap_absence_plan            csr_gap_absence_plan%ROWTYPE;
  l_gap_dur_sum_rows            csr_gap_dur_sum_rows%ROWTYPE;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
  debug_enter(l_proc_name);
  debug(p_assignment_id);
  debug(p_business_group_id);
  debug(p_plan_id);
  debug(p_absence_id);
  debug(p_delete_start_date);
  debug(p_delete_end_date);
  debug(p_error_code);
  debug(p_message);
END IF;


-- Set summary table switch

IF  g_log_duration_summary is NULL
THEN

       IF g_debug THEN
         debug(l_proc_name, 12);
       END IF;

       g_log_duration_summary :=
       PQP_UTILITIES.pqp_get_config_value
               ( p_business_group_id    => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION10'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

       g_log_duration_summary := NVL(g_log_duration_summary,'DISABLE');

       IF g_debug THEN
         debug('g_log_duration_summary' || g_log_duration_summary);
       END IF;

END IF;



 OPEN csr_gap_absence_plan(p_absence_id, p_plan_id);
 FETCH csr_gap_absence_plan INTO l_gap_absence_plan;

 IF csr_gap_absence_plan%FOUND
 THEN
     l_proc_step := 20;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

   DELETE
   FROM   pqp_gap_daily_absences gda
   WHERE  gda.gap_absence_plan_id = l_gap_absence_plan.gap_absence_plan_id
     AND  gda.absence_date
            BETWEEN NVL(p_delete_start_date,gda.absence_date)
                AND NVL(p_delete_end_date,gda.absence_date);

     l_proc_step := 30;
   IF g_debug THEN
     debug(SQL%ROWCOUNT);
     debug('pqp_gap_daily_absences rows deleted.');
     debug(l_proc_name, l_proc_step);
   END IF;

   OPEN csr_gap_daily_absences_exists(l_gap_absence_plan.gap_absence_plan_id);
   FETCH csr_gap_daily_absences_exists INTO l_gap_daily_absences_exists;
   IF csr_gap_daily_absences_exists%NOTFOUND
   THEN

       l_proc_step := 40;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;

     DELETE
     FROM   pqp_gap_absence_plans gap
     WHERE  gap.gap_absence_plan_id = l_gap_absence_plan.gap_absence_plan_id;

-- Call delete using API as we need to log the delete events for all the
-- rows for the summary table


  IF  g_log_duration_summary = 'ENABLE'
  THEN
     IF g_debug THEN
       debug(l_proc_name, 45);
     END IF;

     OPEN csr_gap_dur_sum_rows
         (p_gap_absence_plan_id =>l_gap_absence_plan.gap_absence_plan_id);

      LOOP
         FETCH csr_gap_dur_sum_rows INTO l_gap_dur_sum_rows;
            EXIT WHEN csr_gap_dur_sum_rows %NOTFOUND ;

	     pqp_gds_api.delete_duration_summary
              (p_gap_duration_summary_id
	             => l_gap_dur_sum_rows.gap_duration_summary_id
              ,p_object_version_number
	             => l_gap_dur_sum_rows.object_version_number
              );
          END LOOP;
      CLOSE csr_gap_dur_sum_rows;
    END IF;


       l_proc_step := 50;
     IF g_debug THEN
       debug(SQL%ROWCOUNT);
       debug('pqp_gap_absence_plans rows deleted.');
       debug(l_proc_name, l_proc_step);
     END IF;

   ELSE -- there are still some daily absences left ie was a partial delete
   -- a partial delete takes place when an end date has been changed
   -- such that it is less than the last daily absence date
   -- if it was a partial delete then p_delete_start_date must have been
   -- supplied in which case the new last gap daily absence date would
   -- p_delete_start_date - 1

     pqp_gap_upd.upd
       (p_effective_date              => p_delete_start_date - 1
       ,p_gap_absence_plan_id         => l_gap_absence_plan.gap_absence_plan_id
       ,p_object_version_number       => l_gap_absence_plan.object_version_number
       ,p_assignment_id               => p_assignment_id
       ,p_absence_attendance_id       => p_absence_id
       ,p_pl_id                       => p_plan_id
       ,p_last_gap_daily_absence_date => p_delete_start_date - 1
       );

      IF  g_log_duration_summary = 'ENABLE'
      THEN

	  IF g_debug THEN
             debug(l_proc_name, 55);
          END IF;

	 update_duration_summary
          (p_gap_absence_plan_id           => l_gap_absence_plan.gap_absence_plan_id
          ,p_assignment_id                => p_assignment_id
          );
      END IF;

   END IF; --IF csr_gap_daily_absence%NOTFOUND THEN
   CLOSE csr_gap_daily_absences_exists;

     l_proc_step := 60;
   IF g_debug THEN
     debug(l_proc_name, l_proc_step);
   END IF;

  END IF; --IF csr_gap_absence_plan%FOUND
  CLOSE csr_gap_absence_plan;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   -- Begin Change by Vaibhav Gupta  (VAIBGUPT) on october 21st,2008
   -- Bug noumber- 7434754
   -- Reason .. the scenario of closing cursor in exception section is not
   -- taken care of. Hence if some exception is occurred and if the cursor
   -- is still open then it will be cause of failure of process further.


   IF csr_gap_absence_plan%ISOPEN then
      close csr_gap_absence_plan;
   END IF;

   IF csr_gap_daily_absences_exists%ISOPEN then
       close csr_gap_daily_absences_exists;
   END IF;

   IF csr_gap_dur_sum_rows%ISOPEN then
       close csr_gap_dur_sum_rows;
   END IF;

   --end changes by Vaibhav Gupta

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others(l_proc_name,l_proc_step);
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END delete_absence_plan_details;
--
--This procedure gets all the plan extra information
-- in one go and caches the same by plan id. Given that
-- we need to call this once for every life event and
-- every absence has two life events, it is quite likely
-- that the same information will needed repeatedly.
-- note the cache stores information of one plan at a time
-- it is not a pl/sql table.
--
  PROCEDURE get_plan_extra_info_n_cache_it
  (p_pl_id                     IN            NUMBER
  ,p_plan_information          IN OUT NOCOPY rec_plan_information
  ,p_business_group_id         IN NUMBER
  ,p_assignment_id             IN NUMBER
  ,p_effective_date            IN DATE
  --,p_error_code                   OUT NOCOPY NUMBER
  --,p_message                      OUT NOCOPY VARCHAR2
  )
  IS

    l_trunc_yn                   VARCHAR2(30);
    l_plan_information           rec_plan_information;
    l_error_message              fnd_new_messages.message_text%TYPE;
    l_error_code                 fnd_new_messages.message_number%TYPE;
    l_proc_step                  NUMBER(20,10);
    l_proc_name                  VARCHAR2(61):=
                                    g_package_name||'get_plan_extra_info_n_cache_it';

  BEGIN

    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

    IF g_debug THEN
      debug('Caching check:g_pl_id:'||fnd_number.number_to_canonical(g_pl_id));
      debug('Caching check:p_pl_id:'||fnd_number.number_to_canonical(g_pl_id));
    END IF;

    IF    g_pl_id IS NULL     -- first time the function is called
       OR p_pl_id <> g_pl_id  -- subsequent calls reload cache only if
                              -- the plan id doesn't match
    THEN

      -- these debugs don't require a if debug enabled if condition as these
      -- lines of code are not likely to be executed very frequently.

        l_proc_step := 10;
      IF g_debug THEN
        debug(l_proc_name, 10);
      END IF;

      IF g_debug THEN
        debug('PQP_GB_OSP_ABSENCE_PLAN_INFO');
      END IF;


      IF g_debug THEN
        debug('Before:'||'Absence Entitlement Sick Leave'||':'||
	       p_plan_information.entitlement_parameters_UDT_id);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Entitlement Sick Leave'
          ,p_value => p_plan_information.entitlement_parameters_UDT_id
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Entitlement Sick Leave'||':'||
	       p_plan_information.entitlement_parameters_UDT_id);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn);
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name, 20);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Absence Days'||':'||
	     p_plan_information.absence_days_type);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Days'
          ,p_value                => p_plan_information.absence_days_type
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Days'||':'||
	       p_plan_information.absence_days_type);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn);
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name, 30);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Scheme Calendar Type'||':'||
	         p_plan_information.scheme_period_type);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
        (p_pl_id                => p_pl_id
        ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
        ,p_segment_name         => 'Scheme Calendar Type'
        ,p_value                => p_plan_information.scheme_period_type
        ,p_truncated_yes_no     => l_trunc_yn
        ,p_error_msg            => l_error_message
        );
      IF g_debug THEN
        debug('After:'||'Scheme Calendar Type'||':'||
	     p_plan_information.scheme_period_type);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn);
      END IF;

      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Scheme Calendar Duration'||':'||
	         p_plan_information.scheme_period_duration);
      END IF;
      l_error_code    :=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Scheme Calendar Duration'
          ,p_value        => p_plan_information.scheme_period_duration
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );

      IF g_debug THEN
        debug('After:'||'Scheme Calendar Duration'||':'||
	       p_plan_information.scheme_period_duration);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn);
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 50;
      IF g_debug THEN
        debug(l_proc_name, 50);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Scheme Calendar UOM'||':'||
	       p_plan_information.scheme_period_uom);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Scheme Calendar UOM'
          ,p_value                => p_plan_information.scheme_period_uom
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Scheme Calendar UOM'||':'||
	       p_plan_information.scheme_period_uom);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn  );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 60;
      IF g_debug THEN
        debug(l_proc_name, 60);
      END IF;
--
--      IF g_debug THEN
--        debug('Before:'||'Absence Entitlement Sick Leave'||':'||
--          p_plan_information.entitlement_parameters_UDT_id);
--      END IF;
--      l_error_code:=
--        pqp_gb_osp_functions.pqp_get_plan_extra_info
--          (p_pl_id                => p_pl_id
--          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
--          ,p_segment_name         => 'Absence Entitlement Sick Leave'
--          ,p_value   => p_plan_information.entitlement_parameters_UDT_id
--          ,p_truncated_yes_no     => l_trunc_yn
--          ,p_error_msg            => l_error_message
--          );
--      IF g_debug THEN
--        debug('After:'||'Absence Entitlement Sick Leave'||':'||
--              p_plan_information.entitlement_parameters_UDT_id);
--      END IF;
--      IF g_debug THEN
--        debug(l_trunc_yn );
--      END IF;
--      IF l_error_code <> 0 THEN
--        check_error_code(l_error_code,l_error_message);
--      END IF;
--

        l_proc_step := 70;
      IF g_debug THEN
        debug(l_proc_name, 70);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Scheme Start Date'||':'||
	       p_plan_information.scheme_period_start);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Scheme Start Date'
          ,p_value                => p_plan_information.scheme_period_start
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Scheme Start Date'||':'||
	       p_plan_information.scheme_period_start);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 80;
      IF g_debug THEN
        debug(l_proc_name, 80);
      END IF;
--
--      IF g_debug THEN
--        debug('Before:'||'Absence Types List Name'||':'||
---             p_plan_information.absence_types_list_name);
--      END IF;
--      l_error_code:=
--        pqp_gb_osp_functions.pqp_get_plan_extra_info
--          (p_pl_id                => p_pl_id
--          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
--          ,p_segment_name         => 'Absence Types List Name'
--          ,p_value     => p_plan_information.absence_types_list_name
--          ,p_truncated_yes_no     => l_trunc_yn
--          ,p_error_msg            => l_error_message
--          );
--      IF g_debug THEN
--        debug('After:'||'Absence Types List Name'||':'||p_plan_information.absence_types_list_name);
--      END IF;
--      IF g_debug THEN
--        debug(l_trunc_yn );
--      END IF;
--      IF l_error_code <> 0 THEN
--        check_error_code(l_error_code,l_error_message);
--      END IF;
--
        l_proc_step := 90;
      IF g_debug THEN
        debug(l_proc_name, 90);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Absence Default Work Pattern'||':'||
	   p_plan_information.default_work_pattern_name);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Default Work Pattern'
          ,p_value  => p_plan_information.default_work_pattern_name
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Default Work Pattern'||':'||
	    p_plan_information.default_work_pattern_name);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 100;
      IF g_debug THEN
        debug(l_proc_name, 100);
      END IF;

      IF p_plan_information.default_work_pattern_name =
                         'CONTRACT_LEVEL_WORK_PATTERN'
      THEN

         p_plan_information.default_work_pattern_name :=
        	 get_contract_level_wp
		      (p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_effective_date    => p_effective_date
		      );

          IF g_debug THEN
             debug('After:'||'DEF_WP_CONTRACT_LEVEL_WORK_PATTERN'||':'||
	     p_plan_information.default_work_pattern_name);
          END IF;

          IF p_plan_information.default_work_pattern_name IS NULL
          THEN
             hr_utility.set_message(8303, 'PQP_230000_INVALID_WORK_PAT');
             hr_utility.raise_error ;
          END IF;

        END IF;

        IF g_debug THEN
           debug(l_proc_name, 105);
        END IF;



      IF g_debug THEN
        debug('Before:'||'Absence Entitlement Holidays'||':'||
	         p_plan_information.entitlement_calendar_UDT_id);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Entitlement Holidays'
          ,p_value  => p_plan_information.entitlement_calendar_UDT_id
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Entitlement Holidays'||':'||
	     p_plan_information.entitlement_calendar_UDT_id);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 110;
      IF g_debug THEN
        debug(l_proc_name, 110);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Absence Daily Rate Calculation'||':'||
	     p_plan_information.daily_rate_UOM);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Daily Rate Calculation'
          ,p_value                => p_plan_information.daily_rate_UOM
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Daily Rate Calculation'||':'||
	    p_plan_information.daily_rate_UOM);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 120;
      IF g_debug THEN
        debug(l_proc_name, 120);
      END IF;
--
--      IF g_debug THEN
--        debug('Before:'||'Plan Name'||':'||p_plan_information.plan_name);
--      END IF;
--      l_error_code:=
--        pqp_gb_osp_functions.pqp_get_plan_extra_info
--          (p_pl_id                => p_pl_id
--          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
--          ,p_segment_name         => 'Plan Name'
--          ,p_value                => p_plan_information.plan_name
--          ,p_truncated_yes_no     => l_trunc_yn
--          ,p_error_msg            => l_error_message
--          );
--      IF g_debug THEN
--        debug('After:'||'Plan Name'||':'||p_plan_information.plan_name);
--      END IF;
--      IF g_debug THEN
--        debug(l_trunc_yn );
--      END IF;
--      IF l_error_code <> 0 THEN
--        check_error_code(l_error_code,l_error_message);
--      END IF;
--
        l_proc_step := 130;
      IF g_debug THEN
        debug(l_proc_name, 130);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Absence Overlap Rule'||':'||
	     p_plan_information.absence_overlap_rule);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Overlap Rule'
          ,p_value                => p_plan_information.absence_overlap_rule
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Overlap Rule'||':'||
	  p_plan_information.absence_overlap_rule);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

        l_proc_step := 140;
      IF g_debug THEN
        debug(l_proc_name, 140);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Absence Pay Plan Category'||':'||
	       p_plan_information.absence_pay_plan_category);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Pay Plan Category'
          ,p_value  => p_plan_information.absence_pay_plan_category
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Pay Plan Category'||':'||
	  p_plan_information.absence_pay_plan_category);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;
--
--      IF g_debug THEN
--        debug('Before:'||'Absence Entitlement List Name'||':'||p_plan_information.entitlement_band_names_list);
--      END IF;
--      l_error_code:=
--        pqp_gb_osp_functions.pqp_get_plan_extra_info
--          (p_pl_id                => p_pl_id
--          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
--          ,p_segment_name         => 'Absence Entitlement List Name'
--          ,p_value                => p_plan_information.entitlement_band_names_list
--          ,p_truncated_yes_no     => l_trunc_yn
--          ,p_error_msg            => l_error_message
--          );
--      IF g_debug THEN
--        debug('After:'||'Absence Entitlement List Name'||':'||p_plan_information.entitlement_band_names_list);
--      END IF;
--      IF g_debug THEN
--        debug(l_trunc_yn );
--      END IF;
--      IF l_error_code <> 0 THEN
--        check_error_code(l_error_code,l_error_message);
--      END IF;
--
      IF g_debug THEN
        debug('Before:'||'Absence Entitlement Cal Rules'||':'||
	   p_plan_information.calendar_rule_names_list);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Entitlement Cal Rules'
          ,p_value     => p_plan_information.calendar_rule_names_list
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Entitlement Cal Rules'||':'||
	   p_plan_information.calendar_rule_names_list);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

-- Added the two segments for civil Service Scheme

      IF g_debug THEN
        debug('Before:'||'Dual Rolling Period Duration:'||
	    p_plan_information.dual_rolling_period_duration);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Dual Rolling Period Duration'
          ,p_value  => p_plan_information.dual_rolling_period_duration
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Dual Rolling Period Duration:'||
	     p_plan_information.dual_rolling_period_duration);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;


      IF g_debug THEN
        debug('Before:'||'Dual Rolling Period UOM:'||
	        p_plan_information.dual_rolling_period_uom);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Dual Rolling Period UOM'
          ,p_value      => p_plan_information.dual_rolling_period_uom
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Dual Rolling Period UOM:'||
	     p_plan_information.dual_rolling_period_uom);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

-- FOR LG/PT

      IF g_debug THEN
        debug('Before:'||'Enable Entitlement Proration:'||
	  p_plan_information.track_part_timers);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Enable Entitlement Proration'
          ,p_value                => p_plan_information.track_part_timers
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Enable Entitlement Proration:'||
	       p_plan_information.track_part_timers);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;


      IF g_debug THEN
        debug('Before:'||'Absence Schedule Work Pattern:'||
	         p_plan_information.absence_schedule_work_pattern);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Absence Schedule Work Pattern'
          ,p_value  => p_plan_information.absence_schedule_work_pattern
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Absence Schedule Work Pattern:'||
	       p_plan_information.absence_schedule_work_pattern);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;

      IF p_plan_information.absence_schedule_work_pattern =
                         'CONTRACT_LEVEL_WORK_PATTERN'
      THEN

         p_plan_information.absence_schedule_work_pattern:=
        	 get_contract_level_wp
		      (p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_effective_date    => p_effective_date
		      );

          IF g_debug THEN
             debug('After:'||'ABS_SCHDL_CONTRACT_LEVEL_WORK_PATTERN'||':'||
 	     p_plan_information.absence_schedule_work_pattern);
          END IF;

	 IF p_plan_information.default_work_pattern_name IS NULL
         THEN
             hr_utility.set_message(8303, 'PQP_230000_INVALID_WORK_PAT');
             hr_utility.raise_error ;
         END IF;


      END IF;





      IF g_debug THEN
        debug(l_proc_name, 145);
      END IF;

      IF g_debug THEN
        debug('Before:'||'Plan Types to extend Rolling Period'||
	         p_plan_information.plan_types_to_extend_period);
      END IF;
      l_error_code:=
        pqp_gb_osp_functions.pqp_get_plan_extra_info
          (p_pl_id                => p_pl_id
          ,p_information_type     => 'PQP_GB_OSP_ABSENCE_PLAN_INFO'
          ,p_segment_name         => 'Plan Types to Extend Period'
          ,p_value  => p_plan_information.plan_types_to_extend_period
          ,p_truncated_yes_no     => l_trunc_yn
          ,p_error_msg            => l_error_message
          );
      IF g_debug THEN
        debug('After:'||'Plan Types to extend Rolling Period:'||
	       p_plan_information.plan_types_to_extend_period);
      END IF;
      IF g_debug THEN
        debug(l_trunc_yn );
      END IF;
      IF l_error_code <> 0 THEN
        check_error_code(l_error_code,l_error_message);
      END IF;





        l_proc_step := 150;
      IF g_debug THEN
        debug(l_proc_name, 150);
        debug('Caching Id:g_pl_id:'||fnd_number.number_to_canonical(g_pl_id));
        debug('Caching Id:p_pl_id:'||fnd_number.number_to_canonical(p_pl_id));
      END IF;

      g_pl_id      := p_pl_id; -- set at the end only after calls have passed successfully.
      g_plan_information := p_plan_information;

        l_proc_step := 160;
      IF g_debug THEN
        debug(l_proc_name, 160);
      END IF;

      ELSE -- p_pl_id = g_pl_id matches with the cached one

        -- so return plan_information from the cached copy

        p_plan_information := g_plan_information;

      END IF; -- IF g_pl_id IS NULL OR p_pl_id <> g_pl_id

        l_proc_step := 170;
      IF g_debug THEN
        debug(l_proc_name, 170);
      END IF;
      IF g_debug THEN
        debug_exit(l_proc_name);
      END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_plan_extra_info_n_cache_it;

--
-- Gets value from the plsql table ff_exec
--
PROCEDURE get_param_value
 (p_output_type               IN       ff_exec.outputs_t
 ,p_name                      IN       VARCHAR2
 ,p_datatype                  OUT NOCOPY VARCHAR2
 ,p_value                     OUT NOCOPY VARCHAR2
-- ,p_error_code                OUT NOCOPY NUMBER
-- ,p_message                   OUT NOCOPY VARCHAR2
 )
IS
  l_proc_step                   NUMBER(20,10);
  l_proc_name                   VARCHAR2( 61 )
                                       := g_package_name    ||
                                          'get_param_value';
BEGIN
    l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name, 10);
  END IF;

  FOR i IN 1 .. p_output_type.COUNT
  LOOP
    IF p_output_type( i ).NAME = p_name
    THEN
      p_datatype    := p_output_type( i ).datatype;
      p_value       := p_output_type( i ).VALUE;
    END IF;
    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_param_value;
--
--gets part day absence based on absence id
--
  PROCEDURE get_absence_part_days
   (p_absence_id                IN            NUMBER
   ,p_part_start_day               OUT NOCOPY NUMBER
   ,p_part_end_day                 OUT NOCOPY NUMBER
   ,p_part_day_UOM                 OUT NOCOPY VARCHAR2
  )
  IS
  --
    CURSOR csr_absence_part_days
      (p_absence_attendance_id IN
         per_absence_attendances.absence_attendance_id%TYPE
      )
    IS
      SELECT abs_information1 -- fraction of start day
            ,abs_information2 -- fraction of end day
            ,abs_information3 -- UOM of the fraction
      FROM   per_absence_attendances
      WHERE  abs_information_category = 'GB_PQP_OSP_OMP_PART_DAYS'
      AND    absence_attendance_id = p_absence_attendance_id;


    l_absence_part_days           csr_absence_part_days%ROWTYPE;

    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
                                    g_package_name||
                                    'get_absence_part_days';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_absence_id);
    END IF;

    OPEN csr_absence_part_days(p_absence_id);
    FETCH csr_absence_part_days INTO l_absence_part_days;
    CLOSE csr_absence_part_days;

      l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name, 20);
      debug(l_absence_part_days.abs_information1);
    END IF;

    p_part_start_day :=
      fnd_number.canonical_to_number(l_absence_part_days.abs_information1);

      l_proc_step := 30;
    IF g_debug THEN
      debug(p_part_start_day);
      debug(l_proc_name, 30);
      debug(l_absence_part_days.abs_information2);
    END IF;

    p_part_end_day :=
      fnd_number.canonical_to_number(l_absence_part_days.abs_information2);

      l_proc_step := 40;
    IF g_debug THEN
      debug(p_part_end_day);
      debug(l_proc_name, 40);
      debug(l_absence_part_days.abs_information3);
    END IF;

    p_part_day_UOM :=
      l_absence_part_days.abs_information3;

    IF g_debug THEN
      debug(p_part_day_UOM);
      debug_exit(l_proc_name);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    p_part_start_day := NULL;
    p_part_end_day   := NULL;
    p_part_day_UOM   := NULL;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_absence_part_days;
--
--This function sums up the duration for each level of entitlement
--for a given assignment, plan type and date range.It is the lowest
--level function used to derive the absence balance. The return
--value is an error code, the summed up information is returned
--as an out parameter for .
--
  PROCEDURE get_absences_taken
    (p_assignment_id             IN       NUMBER
    ,p_pl_typ_id                 IN       NUMBER
    ,p_range_from_date           IN       DATE --not absence start and end dates
    ,p_range_to_date             IN       DATE --period for which sum is taken
    ,p_absences_taken            IN OUT NOCOPY pqp_absval_pkg.t_entitlements
--    ,p_message                   OUT NOCOPY VARCHAR2
   ) --RETURN NUMBER
  IS
    --Person level Absence Aggregation changes

    -- declaration of record type for ref cursor return type
    TYPE r_absences_taken_typ IS RECORD
       (
        level_of_entitlement     VARCHAR2(30),
        sum_of_duration          NUMBER,
        sum_of_duration_in_hours NUMBER,
	sum_of_duration_per_week NUMBER,
        sum_of_fte_hours         NUMBER
       );

    TYPE csrv_absences_taken_typ IS REF CURSOR RETURN r_absences_taken_typ;
    csrv_absences_taken   csrv_absences_taken_typ; -- declare cursor variable
    l_asg_abs_rec         r_absences_taken_typ; -- declare record type variable


    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_error_message               fnd_new_messages.message_text%TYPE;

    l_person_id                   per_all_people_f.PERSON_ID%TYPE;
    l_count                       PLS_INTEGER;
    l_prev_date                   DATE;
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
      g_package_name||'get_absences_taken';

-- nocopy changes
    l_absences_taken_nc           pqp_absval_pkg.t_entitlements;

  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_assignment_id);
      debug(p_pl_typ_id);
      debug(p_range_from_date);
      debug(p_range_to_date);
    END IF;

-- nocopy changes
    l_absences_taken_nc := p_absences_taken;
    l_count := 0;
    l_proc_step := 10;

-- Person Level Absence Changes

    -- Retrieve the option chosen for Deduct Absence Taken for in Config Value');

    IF g_debug THEN
       debug(l_proc_name,l_proc_step);
       debug('g_deduct_absence_for:'||g_deduct_absence_for);
    END IF;
    --open the ref cursor as per the value in the g_deduct_absence_for

    IF (g_deduct_absence_for = 'PRIMASGCURPOS')
    THEN
      l_proc_step := 20;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      OPEN csrv_absences_taken FOR
      SELECT gda.level_of_entitlement   level_of_entitlement
            ,SUM(gda.duration)          sum_of_duration
            ,SUM(gda.duration_in_hours) sum_of_duration_in_hours
            ,SUM(gda.duration/gda.working_days_per_week) sum_of_duration_per_week
            ,SUM(gda.duration_in_hours/fte) sum_of_fte_hours
       FROM  pqp_gap_absence_plans   gap
            ,ben_pl_f                pln
            ,pqp_gap_daily_absences  gda
       WHERE gap.assignment_id IN -- automatically makes the assignment list distinct
                 (SELECT other_asg.assignment_id
                    FROM   per_all_assignments_f this_asg
                          ,per_all_assignments_f other_asg
                    WHERE  this_asg.assignment_id = p_assignment_id
                      AND  other_asg.person_id = this_asg.person_id
                      AND  other_asg.primary_flag = 'Y'
                      AND  other_asg.period_of_service_id = this_asg.period_of_service_id
                  )
         AND gda.gap_absence_plan_id = gap.gap_absence_plan_id
         AND pln.pl_id = gap.pl_id
         AND p_range_to_date
             BETWEEN pln.effective_start_date AND pln.effective_end_date
         AND pln.pl_typ_id = p_pl_typ_id
         AND gda.absence_date
             BETWEEN p_range_from_date AND p_range_to_date
         GROUP BY level_of_entitlement;


    ELSIF (g_deduct_absence_for = 'PRIMASGALLPOS')
    THEN
    -- The following ref cursor will pick all the primary assignments in the
    -- all the periods of service for the person and sum up all the absence
    -- entitlements
      l_proc_step := 30;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
      END IF;
      SELECT asg.person_id
        INTO   l_person_id
        FROM   per_all_assignments_f asg
       WHERE  asg.assignment_id = p_assignment_id
         AND ROWNUM < 2;
       IF g_debug THEN
	  debug('l_person_id:' ,l_person_id);
       END IF;
       OPEN csrv_absences_taken FOR
       SELECT        gda.level_of_entitlement   level_of_entitlement
                    ,SUM(gda.duration)          sum_of_duration
                    ,SUM(gda.duration_in_hours) sum_of_duration_in_hours
                    ,SUM(gda.duration/gda.working_days_per_week) sum_of_duration_per_week
                    ,SUM(gda.duration_in_hours/fte) sum_of_fte_hours
              FROM   pqp_gap_absence_plans   gap
                    ,ben_pl_f                pln
                    ,pqp_gap_daily_absences  gda
              WHERE gap.assignment_id IN -- automatically makes the assignment list distinct
              (SELECT asg.assignment_id
                 FROM   per_all_assignments_f asg
                WHERE  asg.person_id = l_person_id
                  AND  asg.primary_flag = 'Y'
               )
           AND gda.gap_absence_plan_id = gap.gap_absence_plan_id
           AND pln.pl_id = gap.pl_id
           AND p_range_to_date
	       BETWEEN pln.effective_start_date AND pln.effective_end_date
           AND pln.pl_typ_id = p_pl_typ_id
           AND gda.absence_date
               BETWEEN p_range_from_date AND p_range_to_date

	  GROUP BY level_of_entitlement;
    ELSE --  IF g_deduct_absence_for = NULL / Current Primary Assignemnt only
     -- The following ref cursor will sum up all the absence
     -- entitlements held against the current primary assignments
     -- This is the default functionality.
      l_proc_step := 40;
      IF g_debug THEN
	 debug(l_proc_name,l_proc_step);
      END IF;
      OPEN csrv_absences_taken FOR
      SELECT  gda.level_of_entitlement   level_of_entitlement
             ,SUM(gda.duration)          sum_of_duration
             ,SUM(gda.duration_in_hours) sum_of_duration_in_hours
             ,SUM(gda.duration/gda.working_days_per_week) sum_of_duration_per_week
             -- LG/PT
             ,SUM(gda.duration_in_hours/fte) sum_of_fte_hours
        FROM  pqp_gap_absence_plans   gap
             ,ben_pl_f                pln
             ,pqp_gap_daily_absences  gda
        WHERE gap.assignment_id = p_assignment_id
          AND gda.gap_absence_plan_id = gap.gap_absence_plan_id
          AND pln.pl_id = gap.pl_id
          AND p_range_to_date
                BETWEEN pln.effective_start_date AND pln.effective_end_date
          AND pln.pl_typ_id = p_pl_typ_id
          AND gda.absence_date BETWEEN p_range_from_date
                                  AND p_range_to_date
         GROUP BY level_of_entitlement;

    END IF;


    l_proc_step := 50;
    IF g_debug THEN
       debug(l_proc_name, 50);
    END IF;

    LOOP
      FETCH csrv_absences_taken INTO l_asg_abs_rec;
      EXIT WHEN csrv_absences_taken%NOTFOUND;

       l_count:= l_count + 1;

       IF g_debug THEN
         debug(l_proc_name, 50+(l_count/1000));
         debug('level_of_entitlement:'||l_asg_abs_rec.level_of_entitlement);
         debug('sum_of_duration:'||l_asg_abs_rec.sum_of_duration);
         debug('sum_of_duration_in_hours:'||
             l_asg_abs_rec.sum_of_duration_in_hours);
         debug('sum_of_duration_per_week:'||
               l_asg_abs_rec.sum_of_duration_per_week);
         debug('sum_of_fte_hours:'||
               l_asg_abs_rec.sum_of_fte_hours);
       END IF;

       p_absences_taken(l_count).band := l_asg_abs_rec.level_of_entitlement;
       p_absences_taken(l_count).duration := l_asg_abs_rec.sum_of_duration;
       p_absences_taken(l_count).duration_in_hours :=
       l_asg_abs_rec.sum_of_duration_in_hours;
       p_absences_taken(l_count).duration_per_week :=
       l_asg_abs_rec.sum_of_duration_per_week ;
       p_absences_taken(l_count).fte_hours :=
       l_asg_abs_rec.sum_of_fte_hours ;
   END LOOP;

   l_proc_step := 60;
   IF g_debug THEN
      debug(l_proc_name, 60);
   END IF;

   IF g_debug THEN
      debug_exit(l_proc_name);
   END IF;
    --RETURN l_error_code;

  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_absences_taken;
--
--
--
  FUNCTION get_adjusted_scheme_start_date
   (p_assignment_id              IN           NUMBER
   ,p_scheme_start_date          IN           DATE
   ,p_pl_typ_id                  IN            NUMBER
   ,p_scheme_period_overlap_rule IN            VARCHAR2
--   ,p_error_code                    OUT NOCOPY NUMBER
--   ,p_message                       OUT NOCOPY VARCHAR2
  ) RETURN DATE
  IS

    CURSOR csr_adjusted_scheme_start_date
     (p_assignment_id     per_all_assignments_f.assignment_id%TYPE
     ,p_pl_typ_id         ben_pl_typ_f.pl_typ_id%TYPE
     ,p_scheme_start_date DATE
     ) IS
    SELECT
           DECODE(p_scheme_period_overlap_rule
                 ,'NC',abs.date_end+1
                 ,'FC',abs.date_start
                 )
    FROM   pqp_gap_absence_plans   gap
          ,per_absence_attendances abs
          ,ben_pl_f                pln
    WHERE  gap.assignment_id = p_assignment_id --an absence for this assignment
      AND  pln.pl_typ_id     = p_pl_typ_id     --which is relevant, ie enrolled
      AND  gap.pl_id         = pln.pl_id       --into a plan of atleast the same
                                               --plan type as the current one
      AND  abs.absence_attendance_id = gap.absence_attendance_id
      AND  abs.date_start < p_scheme_start_date --and which starts before
      AND  abs.date_end   >= p_scheme_start_date-- and ends on or after the
                                                -- scheme start date.
    ;

    l_adjusted_scheme_start_date  DATE;
    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_error_message               fnd_new_messages.message_text%TYPE;
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
                                    g_package_name||'get_adjusted_scheme_start_date';
  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

--
-- to derive the adjusted start date we need to
-- 1. check if the current scheme start date falls in between an absence
--    TAKE note: its not just any overlapping absence,
--    its an absence that was enrolled into a plan of the same plan type.
-- 2. if it does not then adjusted scheme start date is the same
--    as the scheme start date
-- 3. if it does the adjusted scheme start daye depends on the overlap rule
--   a) if the overlap rule is Split (SC)
--   then the adjusted scheme start date is the same the scheme start date
--   b) if the overlap rule is Inlcude (FC)
--   then the adjusted scheme start date is the start of the overlapping absence
--   c) if the overlap rule is Exclude (NC)
--   then the adjusted scheme start date is the first day after the end of the
--   overlapping absence, ie the new year does not begin untill the employee
--   returns to work.
--
   OPEN csr_adjusted_scheme_start_date
    (p_assignment_id      => p_assignment_id
     ,p_pl_typ_id         => p_pl_typ_id
     ,p_scheme_start_date => p_scheme_start_date
    );
   FETCH csr_adjusted_scheme_start_date INTO l_adjusted_scheme_start_date;
   IF csr_adjusted_scheme_start_date%NOTFOUND
   THEN
     -- ie no overlapping absence was found, the scheme start date remains
     -- unchanged.
       l_proc_step := 10;
     IF g_debug THEN
       debug(l_proc_name, l_proc_step);
     END IF;
     l_adjusted_scheme_start_date := p_scheme_start_date;
   END IF;
   CLOSE csr_adjusted_scheme_start_date;
   IF g_debug THEN
      debug('l_adjusted_scheme_start_date:'||
      fnd_date.date_to_canonical(l_adjusted_scheme_start_date));
     debug_exit(l_proc_name);
   END IF;
   RETURN l_adjusted_scheme_start_date;

-- if this cursor finds anything then there are three possibilities
-- | - ^ - | -- the scheme start falls in the middle
-- | - ^|    -- the scheme start fals on the last day of the absence
--     ^|- | -- the scheme start falls on the first day of absence
--
-- from our perspective the last option is good as no overlap, ie
-- the absence is counted and no adjustement is required
-- in the first two cases we need to decide based on FC or NC
-- note for SC we wouldn't bother calling this as in SC
-- in every case we just use the scheme start date
-- we could even save calling this adjustment procedure for SC
--
-- ok so we have now modified cursor for just the first two cases
-- and assuming its not called for SC then
--
-- if the rule is NC...return date end + 1
-- if the rule is FC...return date start

  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_adjusted_scheme_start_date;
--
--
--
  PROCEDURE get_absences_taken_to_date
   (p_assignment_id              IN            NUMBER
--   ,p_absence_date_start         IN            DATE
   ,p_effective_date             IN            DATE
   ,p_business_group_id          IN            NUMBER
   -- Added p_business_group_id for CS
   ,p_pl_typ_id                  IN            NUMBER
   ,p_scheme_period_overlap_rule IN            VARCHAR2
   ,p_scheme_period_type         IN            VARCHAR2
   ,p_scheme_period_duration     IN            VARCHAR2
   ,p_scheme_period_uom          IN            VARCHAR2
   ,p_scheme_period_start        IN            VARCHAR2
   ,p_entitlements               IN OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_absences_taken_to_date     IN OUT NOCOPY pqp_absval_pkg.t_entitlements
--   ,p_message                 OUT NOCOPY VARCHAR2
-- Added for CS
   ,p_dualrolling_4_year          IN BOOLEAN
   ,p_override_scheme_start_date  IN DATE
   ,p_plan_types_to_extend_period IN VARCHAR2 -- LG/PT
   ,p_entitlement_uom             IN VARCHAR2 -- LG/PT
   ,p_default_wp                  IN VARCHAR2 -- LG/PT
   ,p_absence_schedule_wp         IN VARCHAR2 -- LG/PT
   ,p_track_part_timers           IN VARCHAR2 -- LG/PT
   ,p_absence_start_date          IN DATE
  ) --RETURN NUMBER -- error code
  IS


CURSOR csr_ckh_lookup(p_lookup_type VARCHAR2)
    IS
    SELECT *
    FROM   hr_lookups hrl
    WHERE hrl.lookup_type = p_lookup_type ;



    l_flag                        VARCHAR2(30) := 'N';
    l_scheme_start_date           DATE;
    l_adjusted_scheme_start_date  DATE;
    l_error_code                  fnd_new_messages.message_number%TYPE:= 0;
    l_error_message               fnd_new_messages.message_text%TYPE;

--nocopy changes
    l_entitlements_nc             pqp_absval_pkg.t_entitlements;
    l_absences_taken_to_date_nc   pqp_absval_pkg.t_entitlements;
    l_balance_date                DATE;

    i                             BINARY_INTEGER:=0;
    j                             BINARY_INTEGER:=0;
    l_band_has_been_found         BOOLEAN;


    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
                                    g_package_name||
                                    'get_absences_taken_to_date';
    -- Added for LG/PT.
    l_period_start_date DATE ;
    l_period_end_date   DATE ;
    l_calendar_days_to_extend NUMBER ;
    l_current_factor NUMBER ;
    l_ft_factor      NUMBER;
    l_fte_value      NUMBER ;
    l_working_days_per_week NUMBER ;
    l_fte           NUMBER ;
    l_ft_absence_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_ft_working_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_assignment_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_is_full_timer  BOOLEAN ;
    l_cutoff_counter NUMBER ;
    l_csr_ckh_lookup  csr_ckh_lookup%ROWTYPE;
    l_is_assignment_wp BOOLEAN;


  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_assignment_id);
      debug(p_effective_date);
      debug(p_pl_typ_id);
      debug(p_scheme_period_overlap_rule);
      debug(p_scheme_period_type);
      debug(p_scheme_period_duration);
      debug(p_scheme_period_uom);
      debug(p_scheme_period_start);
      debug('p_override_scheme_start_date:'||
       fnd_date.date_to_canonical(p_override_scheme_start_date));
      debug('p_override_scheme_start_date'||p_override_scheme_start_date);
      debug('p_plan_types_to_extend_period'||p_plan_types_to_extend_period);
      debug('p_entitlement_uom'||p_entitlement_uom);
      debug('p_default_wp'||p_default_wp);
      debug('p_absence_schedule_wp'||p_absence_schedule_wp);
      debug('p_track_part_timers'||p_track_part_timers);
    END IF;

    --p_message := l_error_message;

   -- the purpose of this procedure is to determine the entitlement used up
   -- , to date. or in other words the absences taken to date.

      l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
   -- nocopy changes
   --    l_band_info_nc        := p_band_info;
   --    l_band_bal_info_nc    := p_band_bal_info;
    l_absences_taken_to_date_nc := p_absences_taken_to_date;
   -- PERSON LEVEL ABSENCE CHANGES
     -- query configuration value to find out
     -- the option set for deduct absence taken for
     -- set the global as per that for further processing
     -- in the procedure get_absences_taken

    g_deduct_absence_for :=
    PQP_UTILITIES.pqp_get_config_value
               ( p_business_group_id    => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION9'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

    IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('g_deduct_absence_for :' ||g_deduct_absence_for);
    END IF;


   -- to determine the balance as of a given date (in OSP/OMP as of start of absence)
   -- we need to
   -- 1. determine the scheme start and end (eff date)
   -- 2. adjust the scheme start for any overlapping absences
   -- 3. sum duration and hours between the scheme start and eff date
   --    grouped by each level of entitlement which is in the OSP ent lookup
   --    type BAND%
   --
   -- to determine the entitlement remaining we need to deduct (per band)
   -- the duration/hours taken from the entitlement available

   -- NOTE for hours we need to multiply entitlement by FTE
   --

   --
   -- 1. determine the scheme start date
   --    to do that we need to know the rules ie fixed,rolling,duration
   --    ,uom,fixed yr start date
   --
   --
-- Added for CS
   IF p_scheme_period_type = 'DUALROLLING' THEN
      debug(l_proc_name,11);
    -- get_rolling_start_date returns the Rolling period start date
    -- after considering the extensions of periods

      l_adjusted_scheme_start_date :=
        pqp_gb_css_daily_absences.get_rolling_start_date
          (p_rolling_end_date    => p_effective_date
          ,p_scheme_period_duration => p_scheme_period_duration
          ,p_assignment_id      => p_assignment_id
          ,p_business_group_id  => p_business_group_id
          ,p_scheme_period_type => p_scheme_period_type
          ,p_scheme_period_uom  => p_scheme_period_uom
          ,p_pl_typ_id          => p_pl_typ_id
          ,p_4_year_rolling_period => p_dualrolling_4_year
	  ,p_lookup_type           => p_plan_types_to_extend_period
          );

   ELSE --  IF p_scheme_period_type = 'DUALROLLING' THEN

     l_proc_step := 20;

     IF p_override_scheme_start_date IS NULL
     THEN

      l_scheme_start_date:=
      get_scheme_start_date
        (p_assignment_id              => p_assignment_id
        ,p_scheme_period_type         => p_scheme_period_type
        ,p_scheme_period_duration     => p_scheme_period_duration
        ,p_scheme_period_uom          => p_scheme_period_uom
        ,p_fixed_year_start_date      => p_scheme_period_start
        ,p_balance_effective_date     => p_absence_start_date
        );

    -- Get the NOPAID days or Maternity days to extend the assessment period.
    -- l_scheme_stat_date = l_adjusted_scheme_start_date +
    -- sum of nopay days/Maternity days

       l_proc_step := 30;
       l_period_start_date := l_scheme_start_date ;
       l_period_end_date   := p_effective_date ;
       l_cutoff_counter := 0;




       OPEN csr_ckh_lookup(p_lookup_type => p_plan_types_to_extend_period);
       FETCH csr_ckh_lookup INTO l_csr_ckh_lookup;
       IF csr_ckh_lookup %FOUND THEN
         LOOP

		l_cutoff_counter := l_cutoff_counter + 1 ;

                l_calendar_days_to_extend :=
		     pqp_absval_pkg.get_calendar_days_to_extend(
	             p_period_start_date => l_period_start_date
		    ,p_period_end_date   => l_period_end_date
		    ,p_assignment_id     => p_assignment_id
		    ,p_business_group_id => p_business_group_id
		    ,p_pl_typ_id         => p_pl_typ_id
		    ,p_count_nopay_days  => FALSE
	            ,p_plan_types_lookup_type => p_plan_types_to_extend_period
		    )  ;

		IF l_calendar_days_to_extend > 0 THEN
	             l_period_end_date := l_period_start_date -1 ;
		     l_period_start_date := l_period_start_date -l_calendar_days_to_extend ;
	        END IF ;

        EXIT WHEN (l_calendar_days_to_extend <= 0 OR l_cutoff_counter > 100);
        END LOOP ;
       END IF;
       CLOSE csr_ckh_lookup;

     l_scheme_start_date :=  l_period_start_date;

     IF g_debug THEN
      debug(l_proc_name,l_proc_step);
      debug('l_scheme_start_date :' ||l_scheme_start_date);
     END IF;

     --If exited the loop due to safety cut-off
      IF l_cutoff_counter > 100 THEN
        fnd_message.set_name('PQP','PQP_230011_LOOP_MAX_ITERATIONS');
        fnd_message.set_token('PROCNAME',l_proc_name);
        fnd_message.set_token('PROCSTEP',35);
        fnd_message.raise_error;
      END IF;


   --
   -- 2. adjust the scheme start and end for any overlaping absences
   --    to do that we need to first know if there are any overlapping
   --    absences, and then two determine the overlap rule
   --
   --    if the p_scheme_period_overlap_rule = Split(SC) then donot bother
   --    getting the adjusted date as in that we take the split any
   --    overlapping absences exactly down to the scheme start date
   --    boundary.
   --

      l_proc_step := 40;
      IF g_debug THEN
        debug(l_proc_name, 40);
      END IF;

      IF p_scheme_period_overlap_rule = 'SC'--(Split)
      THEN
        l_proc_step := 40;
        IF g_debug THEN
           debug(l_proc_name, 40);
        END IF;

        l_adjusted_scheme_start_date := l_scheme_start_date;

      ELSE -- p_scheme_period_overlap_rule = FC(Include) or NC(Exclude)

        l_proc_step := 50;
        IF g_debug THEN
          debug(l_proc_name, 50);
        END IF;

        l_adjusted_scheme_start_date :=
         get_adjusted_scheme_start_date
         (p_assignment_id              => p_assignment_id
         ,p_pl_typ_id                  => p_pl_typ_id
         ,p_scheme_start_date          => l_scheme_start_date
         ,p_scheme_period_overlap_rule => p_scheme_period_overlap_rule
--         ,p_error_code                 => l_error_code
--         ,p_message                    => l_error_message
         );

      END IF ;--  IF p_scheme_period_overlap_rule = 'SC'--(Split)

   ELSE

      l_adjusted_scheme_start_date := p_override_scheme_start_date;

    END IF; -- IF p_override_scheme_start_date IS NOT NULL

  END IF; --  IF p_scheme_period_type = 'DUALROLLING' THEN


  debug('l_adjusted_scheme_start_date:'||
  fnd_date.date_to_canonical(l_adjusted_scheme_start_date));

  l_proc_step := 60;
  IF g_debug THEN
     debug(l_proc_name, 60);
  END IF;
   -- from this point onwards the adjusted the scheme start date will be
   -- the effective start date for all balance purposes.
   -- the "end date" of the balance year is always the start of the current
   -- absence - which for the perspective of this function is p_effective_date

   -- 3. sum duration and hours between the scheme start and eff date
   --    grouped by each level of entitlement which is in the OSP ent lookup
   --    type BAND%
   -- duplicate functionality we allready have get_absences_taken
   -- doing the same....levarage that.
   --

   -- if the scheme is rolling pass range_to_date as effective_date - 1
   -- if fixed pass the effective date as passed from calling procs


     l_balance_date := p_effective_date - 1;


    --l_error_code:=
   get_absences_taken
       (p_assignment_id   => p_assignment_id
       ,p_pl_typ_id       => p_pl_typ_id
       ,p_range_from_date => l_adjusted_scheme_start_date
       ,p_range_to_date   => l_balance_date
       ,p_absences_taken  => p_absences_taken_to_date
    --   ,p_message         => l_error_message
      );

   l_proc_step := 70;
   IF g_debug THEN
      debug(l_proc_name, 70);
   END IF;

-- code beyond this point: checks here to see if there are more entitlements
-- than there are bands in absence taken ytd
-- if so it inserts rows in the plsql table for the missing ones with 0 duration
--
-- whats a good way of doing this ?..first we need to check whether
-- p_entitlements has a row for every band....checking code...
-- shows it doesn't ... it will contain only those rows which have any
-- entitlements setup in it (currently if the user
-- needs to skip a band he needs to set it up with 0 entitlement)
--
-- do we really need this at all ? so what if bands which have some entitlement
-- setup are not there in the absences taken to date , will need to check
-- logic on the daily absence processing side.
--
-- till then leave in place
--

   IF
    --p_entitlements.COUNT -- if there are more entitlement bands defined
    -- > p_absences_taken_to_date.COUNT -- than there are
     --AND l_count > 0
     -- AND
     p_absences_taken_to_date.COUNT > 0
   THEN

     get_factors (
         p_business_group_id   => p_business_group_id
         ,p_effective_date      => p_effective_date
         ,p_assignment_id       => p_assignment_id
         ,p_entitlement_uom     => p_entitlement_uom
         ,p_default_wp          => p_default_wp
         ,p_absence_schedule_wp => p_absence_schedule_wp
         ,p_track_part_timers   => p_track_part_timers
         ,p_current_factor      => l_current_factor
         ,p_ft_factor           => l_ft_factor
         ,p_working_days_per_week => l_working_days_per_week
         ,p_fte                 => l_fte
         ,p_FT_absence_wp       => l_ft_absence_wp
         ,p_FT_working_wp       => l_ft_working_wp
         ,p_assignment_wp       => l_assignment_wp
         ,p_is_full_timer       => l_is_full_timer
         ,p_is_assignment_wp    => l_is_assignment_wp
                ) ;




      l_proc_step := 80;
      IF g_debug THEN
        debug(l_proc_name, 80);
      END IF;

-- if so for each entitlement band
        --FOR i IN 1 .. p_entitlements.COUNT
        i := p_entitlements.FIRST;
        WHILE i IS NOT NULL
        LOOP

          --l_flag    := 'N';
          l_band_has_been_found := FALSE;

            l_proc_step := 81;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
            debug('Looking to see if '||i||p_entitlements(i).band||' has been taken');
          END IF;

-- check to see if there is such a band in the absence taken ytd
          --FOR j IN 1 .. p_absences_taken_to_date.COUNT
          j := p_absences_taken_to_date.FIRST;
          WHILE j IS NOT NULL
          LOOP

              l_proc_step := 82;
            IF g_debug THEN
              debug(l_proc_name, l_proc_step);
              debug('We know that '||j||p_absences_taken_to_date(j).band||' has been taken.');
            END IF;

            IF p_entitlements(i).band = p_absences_taken_to_date(j).band
            THEN

                l_proc_step := 83;
              IF g_debug THEN
                debug(l_proc_name, l_proc_step);
                debug('This confirms '||i||p_entitlements(i).band||' has been taken.So mark as Yes.');
              END IF;

             -- Here convert the abences taken to date into the current factor
             -- i.e get the numbers into the existing fte terms or
	     -- Work Pattern terms

          IF NVL(p_track_part_timers,'N') = 'Y' THEN
	     IF p_entitlement_UOM = 'H'--ours
	     THEN
               -- Changed LG  p_absences_taken_to_date(j).entitlement :=
                   p_absences_taken_to_date(j).duration_in_hours :=
                             p_absences_taken_to_date(j).fte_hours * l_current_factor ;
             ELSE
               -- Changed LG  p_absences_taken_to_date(j).entitlement :=
                 p_absences_taken_to_date(j).duration :=
                   p_absences_taken_to_date(j).duration_per_week * l_current_factor ;
             END IF; -- IF p_entitlement_UOM = 'H'ours

          ELSE -- i.e. not tracking Part Timers

	    IF p_entitlement_UOM = 'H'--ours
	    THEN
              p_absences_taken_to_date(j).entitlement :=
                   p_absences_taken_to_date(j).duration_in_hours * l_current_factor ;
	    ELSE
              p_absences_taken_to_date(j).entitlement :=
                   p_absences_taken_to_date(j).duration * l_current_factor ;
            END IF; -- IF p_entitlement_UOM = 'H'ours

	  END IF ; -- tracking part timers check


             --l_flag    := 'Y';
              l_band_has_been_found := TRUE;

            END IF;

            j := p_absences_taken_to_date.NEXT(j);
            debug('Next(j):'||j);

          END LOOP; -- j loop

--if a band that is in the entitlements does not exist in the absence taken ytd
--then add it to the absence taken ytd with a sum of duration as 0

          IF --l_flag = 'N'
             NOT l_band_has_been_found
          THEN

              l_proc_step := 84;
            IF g_debug THEN
              debug(l_proc_name, 84);
              debug(i||p_entitlements(i).band||' has NOT been taken');
            END IF;

            j := p_absences_taken_to_date.LAST + 1;
            p_absences_taken_to_date(j).band:= p_entitlements(i).band;
            p_absences_taken_to_date(j).duration:= 0;
            p_absences_taken_to_date(j).duration_in_hours:= 0;
	    p_absences_taken_to_date(j).duration_per_week := 0 ;
	    p_absences_taken_to_date(j).fte_hours := 0 ;
          END IF;

          i := p_entitlements.NEXT(i);
          debug('Next(i):'||i);

        END LOOP; -- i loop

      END IF; -- if ent count > abs count and abs count > 0

      l_proc_step := 100;
    IF g_debug THEN
      debug(l_proc_name, 100);
    END IF;
--
--code beyond this point: if no absences taken ytd were found,
-- still create rows for each band with 0 sum of duration
--this is not needed as the prev loop takes care of that
--left in place as when absences taken count is 0 this is more efficient
--
      IF p_absences_taken_to_date.COUNT = 0 --l_count = 0
      THEN
          l_proc_step := 110;
        IF g_debug THEN
          debug(l_proc_name, 110);
        END IF;
        FOR i IN 1 .. p_entitlements.COUNT
        LOOP
          IF g_debug THEN
            debug(l_proc_name, 120+i);
          END IF;
          p_absences_taken_to_date( i ).band := p_entitlements( i ).band;
          p_absences_taken_to_date( i ).duration := 0;
          p_absences_taken_to_date( i ).duration_in_hours := 0;
          p_absences_taken_to_date( i ).duration_per_week := 0 ;
          p_absences_taken_to_date( i ).fte_hours := 0 ;
        END LOOP;

      END IF; -- if absence taken count = 0

--    END IF;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

  --RETURN l_error_code;

  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      p_absences_taken_to_date    := l_absences_taken_to_date_nc;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_absences_taken_to_date;
--
--This function calculates remaining entitlements
--
  PROCEDURE get_entitlements_remaining
    (p_assignment_id          IN NUMBER -- LG/PT
    ,p_effective_date         IN DATE   -- LG/PT
    ,p_entitlements           IN            pqp_absval_pkg.t_entitlements
    ,p_absences_taken_to_date IN            pqp_absval_pkg.t_entitlements
    ,p_entitlement_UOM        IN            VARCHAR2
    ,p_entitlements_remaining IN OUT NOCOPY pqp_absval_pkg.t_entitlements--t_ent_run_balance
    ,p_is_full_timer          IN BOOLEAN
--    ,p_avg_working_days_assignment IN NUMBER --LG/PT
--    ,p_avg_working_days_standard  IN NUMBER -- LG/PT
--    ,p_message                   OUT NOCOPY VARCHAR2
-- LG/PT
--    ,p_track_part_timers      IN VARCHAR2 DEFAULT 'N'
    ) --RETURN NUMBER
  IS

    l_error_code                  NUMBER:= 0;

    i                             BINARY_INTEGER;
    j                             BINARY_INTEGER;

    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61):=
                                    g_package_name||
                                    'get_entitlements_remaining';

--nocopy changes
    l_entitlements_remaining_nc pqp_absval_pkg.t_entitlements ;
-- LG/PT
    l_absences_taken_to_date    pqp_absval_pkg.t_entitlements
                              := p_absences_taken_to_date ;
    l_fte_value                 pqp_gap_daily_absences.fte%TYPE ;
    l_current_factor            NUMBER ;
    l_ft_factor                 NUMBER ;

  BEGIN
    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;


-- nocopy changes
    l_entitlements_remaining_nc    := p_entitlements_remaining;

      l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;

-- count the number of entitlements actually avaiable
-- the initial assumption that the last band (first band at which no ent
-- would be setup will have the entitlement of -1
-- so say for LOS 5 there was only Band1, Band2
-- then Band3 would be setup as -1
-- this is probably not required as I didn't see in get_LOS_based_entitlements
-- anything which sets the entitlements to -1
--
-- DO NOT DELETE till confirmed
--
--    FOR i IN 1 .. p_entitlements.COUNT
--    LOOP
--    IF g_debug THEN
--      debug(l_proc_name, 10+i/1000);
--    END IF;
--
--      IF p_entitlements(i).entitlement = -1 -- lets say this is never found
--      THEN
--        EXIT;
--      ELSE
--        l_band_count    := i; -- will represent p_entitlements.COUNT
--      END IF;
--    END LOOP;
 --DO NOT DELETE till confirmed

      l_proc_step := 30;
    IF g_debug THEN
      debug(l_proc_name, 30);
    END IF;

-- for every band in p_entitlements
-- 1 BAND1  25
-- 2 BAND2  25
-- 3 BAND3  0
-- 4 BAND4  0
     IF g_debug THEN
       debug('p_absences_taken_to_date.COUNT:'||
         fnd_number.number_to_canonical(p_absences_taken_to_date.COUNT));
     END IF ;

    i := p_entitlements.FIRST;
    WHILE i IS NOT NULL
    --FOR i IN 1..p_entitlements.COUNT
    -- i = 1 (BAND1)
    LOOP
      l_proc_step := 30+i/1000 ;
      IF g_debug THEN
        debug(l_proc_name, 30+i/1000);
      END IF;

-- set the entitlement remaining as the full entitlement remaining
      p_entitlements_remaining(i).band := p_entitlements(i).band;
      p_entitlements_remaining(i).entitlement := p_entitlements(i).entitlement;

--
-- then loop thru every band in p_absences_taken to see how much has been used
-- 1 BAND2  25
-- 2 BAND3  0
-- 3 BAND1  15
-- 4 BAND4  0
-- if no matching bands are found in the inner loop then full entitlement
-- is available for use.
--
      j:= l_absences_taken_to_date.FIRST;
      WHILE j IS NOT NULL
      --FOR j IN  1.. p_absences_taken_to_date.COUNT
      -- j = 3 (BAND1)
      LOOP

        l_proc_Step := 50+j/1000 ;
        IF g_debug THEN
          debug(l_proc_name, 50+j/1000);
          debug(l_absences_taken_to_date(j).band);
          debug(p_entitlements(i).band);
        END IF;

        -- if the the band match
        IF l_absences_taken_to_date(j).band = p_entitlements(i).band
        -- BAND1(j=3) = BAND1(i=1)
        THEN

        -- then ent remaining value = ent value -
          p_entitlements_remaining(i).band := p_entitlements(i).band;
          -- (i=1) = (i=1)BAND1

          IF g_debug THEN
             debug('ent(i):'||
               fnd_number.number_to_canonical
                (p_entitlements(i).entitlement));

             debug('abs(j).duration:'||
               fnd_number.number_to_canonical
                (l_absences_taken_to_date(j).duration));

             debug('abs(j).duration_in_hours:'||
               fnd_number.number_to_canonical
                 (l_absences_taken_to_date(j).duration_in_hours));
          END IF ;


          IF p_entitlement_UOM = 'H'--ours
          THEN

            debug(l_proc_name,60+j/1000);

            -- if the UOM is Hours debit the entitlement by hours duration

            p_entitlements_remaining(i).entitlement :=
              p_entitlements(i).entitlement
              - p_absences_taken_to_date(j).duration_in_hours;

          ELSE

            debug(l_proc_name,70+j/1000);

           -- if the UOM is Days debit the entitlement by days duration

            p_entitlements_remaining(i).entitlement := round((
              p_entitlements(i).entitlement
              - p_absences_taken_to_date(j).duration),8); -- Bug 6335663


             -- the value p_is_full_timer is set only from OSP.
	     -- from OMP this parameter is not passed and this rounding
	     -- is not required for OMP
	     IF p_is_full_timer IS NOT NULL THEN

		  IF p_is_full_timer THEN
                     p_entitlements_remaining(i).entitlement :=
                     pqp_utilities.round_value_up_down
                    ( p_value_to_round => p_entitlements_remaining(i).entitlement
                     ,p_base_value     => g_ft_rounding_precision
                     ,p_rounding_type  => g_ft_entitl_rounding_type
                    ) ;
		 ELSE
                     p_entitlements_remaining(i).entitlement :=
                     pqp_utilities.round_value_up_down
	           ( p_value_to_round => p_entitlements_remaining(i).entitlement
                    ,p_base_value     => g_pt_rounding_precision
                    ,p_rounding_type  => g_pt_entitl_rounding_type
                   ) ;
                 END IF ;
            END IF ;

          END IF; -- IF p_entitlement_UOM = 'H'ours

          --   10(i=1 BAND1) =
          --
          --   25(i=1 BAND1)
          -- - 15(j=3 BAND1)
          --

          -- if the person had used more than he is entitled for
          -- likely to occur in situiations when FTE changes
          -- or when the entitlements at a highler length of
          -- service are lower (for some reason) than they
          -- were at the previous length of service band.

          IF g_debug THEN
            debug('rem(i):'||
                fnd_number.number_to_canonical
                  (p_entitlements_remaining(i).entitlement));
          END IF ;

          IF p_entitlements_remaining(i).entitlement < 0
          --(i=1) 10 < 0 == NOT TRUE
          THEN

            -- if (i=1 BAND1) was -10 then < 0 == TRUE
            p_entitlements_remaining(i).entitlement := 0;
            -- so set (i=1 BAND1) = 0
          END IF;

--          debug('rem(i):'||
--            fnd_number.number_to_canonical
--              (p_entitlements_remaining(i).entitlement));


          --p_entitlements_remaining(i).ent_bal := 0;
          -- (i=1) = 0
          -- this value is used when the day by day debit is done
          -- it probably represents the amount left after each day
          -- is processed

        END IF; -- if j.band = i.band

        j:= l_absences_taken_to_date.NEXT(j);

      END LOOP; -- for j in p_absences_taken_to_date

      i := p_entitlements.NEXT(i);

    END LOOP; -- for i in p_entitlements

    IF g_debug THEN
      debug_exit(l_proc_name);
    END IF;
    --RETURN l_error_code;

  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      p_entitlements_remaining := l_entitlements_remaining_nc;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
  END get_entitlements_remaining;
--
-- Adds a day or part of the day to the cache which is used later to
-- bulk insert to the table.
-- Note it is also in this procedure that we will call the chk procedures
-- of the row handler to ensure that the data is valid prior to the bulk
-- insert call
--
PROCEDURE set_daily_absence_cache
  (p_daily_absences            IN OUT NOCOPY pqp_absval_pkg.t_daily_absences
  ,p_absence_date              IN            pqp_gap_daily_absences.absence_date%TYPE
  ,p_work_pattern_day_type     IN            pqp_gap_daily_absences.work_pattern_day_type%TYPE
  ,p_level_of_entitlement      IN            pqp_gap_daily_absences.level_of_entitlement%TYPE
  ,p_level_of_pay              IN            pqp_gap_daily_absences.level_of_pay%TYPE
  ,p_duration                  IN            pqp_gap_daily_absences.duration%TYPE
  ,p_duration_in_hours         IN            pqp_gap_daily_absences.duration_in_hours%TYPE
  ,p_working_days_per_week     IN            pqp_gap_daily_absences.working_days_per_week%TYPE
  ,p_fte                       IN            pqp_gap_daily_absences.fte%TYPE --LG/PT
--  ,p_error_code                   OUT NOCOPY fnd_new_messages.message_number%TYPE
--  ,p_message                      OUT NOCOPY fnd_new_messages.message_text%TYPE
  )
IS

i INTEGER;

l_proc_step             NUMBER(20,10);
l_proc_name             VARCHAR2(61):=
                          g_package_name||
                          'set_daily_absence_cache';
BEGIN

IF g_debug THEN
  debug_enter(l_proc_name);
END IF;

i := NVL(p_daily_absences.LAST,0)+1;

p_daily_absences(i).absence_date          := p_absence_date;
p_daily_absences(i).work_pattern_day_type := p_work_pattern_day_type;
p_daily_absences(i).level_of_entitlement  := p_level_of_entitlement;
p_daily_absences(i).level_of_pay          := p_level_of_pay;
p_daily_absences(i).duration              := p_duration;
p_daily_absences(i).duration_in_hours     := p_duration_in_hours;
p_daily_absences(i).working_days_per_week := p_working_days_per_week ;
p_daily_absences(i).fte                   := p_fte ; --LG/PT

IF g_debug THEN
  debug(p_daily_absences(i).absence_date);
  debug(p_daily_absences(i).work_pattern_day_type);
  debug(p_daily_absences(i).level_of_entitlement);
  debug(p_daily_absences(i).level_of_pay);
  debug(p_daily_absences(i).duration);
  debug(p_daily_absences(i).duration_in_hours);
  debug(p_daily_absences(i).working_days_per_week);
  debug(p_daily_absences(i).fte);

END IF;


  l_proc_step := 10;
IF g_debug THEN
  debug(l_proc_name, 10);
END IF;

--pqp_gda_bus.insert_validate(p_daily_absences(i));

IF g_debug THEN
  debug_exit(l_proc_name);
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END set_daily_absence_cache;
--
-- The purpose of this procedure is to generate daily absences
-- for the current absence (event) it does not directly write
-- to the daily absences table but stores it into pl/sql tables
-- which then using bulk insert (hopefully) are written to the
-- database.
--
-- becase in this procedure we will loop thru each day
-- all debug calls must be made conditional for performance
-- ideally we should do that everywhere.
--
  PROCEDURE generate_daily_absences
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_absence_attendance_id     IN       NUMBER
   ,p_default_work_pattern_name IN       VARCHAR2
   ,p_calendar_user_table_id    IN       NUMBER
   ,p_calendar_rules_list       IN       VARCHAR2
   ,p_generate_start_date       IN       DATE
   ,p_generate_end_date         IN       DATE
   ,p_absence_start_date        IN       DATE
   ,p_absence_end_date          IN       DATE
   ,p_entitlement_UOM           IN       VARCHAR2
   ,p_payment_UOM               IN       VARCHAR2
   ,p_output_type               IN       ff_exec.outputs_t
   ,p_entitlements_remaining    IN OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_daily_absences            IN OUT NOCOPY pqp_absval_pkg.t_daily_absences
   ,p_error_code                   OUT NOCOPY NUMBER
   ,p_message                      OUT NOCOPY VARCHAR2
   ,p_working_days_per_week     IN       NUMBER
   ,p_fte                       IN NUMBER -- LG/PT
   ,p_override_work_pattern     IN VARCHAR2 DEFAULT NULL
   ,p_pl_id                     IN NUMBER DEFAULT NULL
   ,p_scheme_period_type        IN VARCHAR2 DEFAULT NULL
   ,p_is_assignment_wp          IN BOOLEAN
   )
  IS

    l_part_start_day              pqp_gap_daily_absences.duration%TYPE;
    l_part_end_day                pqp_gap_daily_absences.duration%TYPE;
    l_part_day_UOM                per_absence_attendances.abs_information3%TYPE;

    l_duration                    NUMBER ;
    l_duration_to_process         NUMBER ;
    l_duration_processed          NUMBER ;
    l_number_of_hours_in_the_day  NUMBER ;

    l_current_date                DATE;
    l_end_date                    DATE;

    l_calendar_exclusion          BOOLEAN;
    l_count_for_entitlement       BOOLEAN;
    l_entitled_to_be_paid         BOOLEAN;
    l_is_working_day              BOOLEAN;

    l_work_pattern_day_type       pqp_gap_daily_absences.work_pattern_day_type%TYPE;
    l_level_of_entitlement        pqp_gap_daily_absences.level_of_entitlement%TYPE;
    l_level_of_pay                pqp_gap_daily_absences.level_of_pay%TYPE;

    i                             BINARY_INTEGER;
    dd                            BINARY_INTEGER:=0;
    cc                            BINARY_INTEGER:=0;
    l_first_available_band_index  BINARY_INTEGER;

    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_error_message               fnd_new_messages.message_text%TYPE;

    l_calendar_rule_name          fnd_lookup_values.meaning%TYPE;
    l_cal_day_name                fnd_lookup_values.meaning%TYPE;
    l_cal_rule_value              fnd_lookup_values.meaning%TYPE;
    l_calendar_rule_code          fnd_lookup_values.lookup_code%TYPE;
    l_calendar_filter             fnd_lookup_values.lookup_code%TYPE;
    l_calendar_value              pay_user_column_instances_f.VALUE%TYPE;

    l_datatype                    fnd_lookup_values.lookup_code%TYPE;
    l_override_work_pattern       pay_user_columns.user_column_name%TYPE;
    l_override_work_pattern_yn    fnd_lookup_values.lookup_code%TYPE;

    l_entitlements_remaining_nc   pqp_absval_pkg.t_entitlements;
    l_minimum_pay_defined         NUMBER ;
    l_minimum_pay_rate            NUMBER ;
    ------- Minimum pay rate enhancment --------
    l_minpay_start_date           DATE;
    l_minpay_end_date             DATE;
    -- cache for minimum pay rate
    l_effective_minpay_start_day  DATE ;
    l_effective_minpay_end_day    DATE;
    l_process_min_pay             BOOLEAN := FALSE;
    l_plan_information            rec_plan_information;
    --------Minimum pay rate enhancement -------


     ------Waiting Period enhancements
    l_waiting_days_txt    VARCHAR2(10);--Return Value From Fast Formula.No.of waiting days.
    l_waiting_days_remaining    NUMBER;--Waiting days remaining during the iteration
    l_duration_to_set_as_waiting    NUMBER;--Duration of waiting period processed in one iteration
    l_waiting_entitlement           VARCHAR2(30);
    l_waiting_pay		    VARCHAR2(30)   ;
    l_waiting_days_used          pqp_gap_daily_absences.duration%TYPE;
    negative_value EXCEPTION;
    ------Waiting Period enhancements


    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61)
                                   := g_package_name||
                                    'generate_daily_absences';
    l_open_ended_no_pay_days      NUMBER;
    l_override_wp                 pay_user_columns.user_column_name%TYPE;
    l_is_assignment_wp            BOOLEAN ;
  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_is_assignment_wp := p_is_assignment_wp ;

    IF g_debug THEN
      debug_enter(l_proc_name);
    END IF;

    --
    -- to work thru this first think out what it should be doing
    -- for each day
    --  1. evaluate whether its a holiday (excluded in the calendar)
    --  if so mark the day's level of entitlement as EXCLUDED
    --  mark the level of pay with whatever "rule" the chk_calendar_occurence
    --  returns for that date.
    --
    --  mark the day, date, duration, hours , level of ent and level of pay
    --  and loop to the next day.
    --
    --  2. determine if the day is working or not.
    --
    --
    --  3. if the day is not excluded from entitlement then
    --
    --  a) if the scheme is a working scheme and the day is not working
    --  set the level of entitlement as not else mark as ENTITLED
    --
    --  b) if the scheme is a working paid days scheme and the day is not
    --  working set the level of pay as NOT else mark as ENTITLED
    --
    --  c) if either of levels are marked as ENTITLED then
    --    start the next loop
    --
    --  else mark the day , duration , hours, level of ent, level of pay
    --  and loop to the next day.
    --
    --  c). <start the next loop> (don't actually code like this)
    --  loop thru all the bands of entiltements remaining from BAND1ton
    --  and debit the entitlement by the duration of the day.
    --  if the duration of the day can be covered fully by the entitlement
    --  mark the day
    --  else loop to the next band. (somehere in this optimize such that
    --  when the person enters no band then for the subsequent days do not
    --  waste processing effor in this loop and mark it straight as No Pay)
    --
    --  a day may be covered by more than one entiltement.this could
    --  be done by just calling process_entitlement_for_day (hypothetical)
    --  or by this inner loop. the likely hood that the inner loop
    --  will loop more than once is extremely unlikely however it is a
    --  neater/cleared solution.
    --
    --  special notes: for hours we will need to check UOM
    --  for part days and hours we need to check UOM and convert the
    --  part days into hours or hours into days etc.
    --
    --


      l_proc_step := 10;
    IF g_debug THEN
      debug(l_proc_name, 10);
    END IF;
    --Added by akarmaka to process minband pay
    --reset the variable for effective minimum pay rate start date
    l_effective_minpay_start_day := NULL;
    l_effective_minpay_end_day := NULL;

    -- Set value for open ended absence no pay days
    l_open_ended_no_pay_days :=
         PQP_UTILITIES.pqp_get_config_value(
                 p_business_group_id     => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION8'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

    g_open_ended_no_pay_days :=
                    FND_NUMBER.canonical_to_number(NVL(l_open_ended_no_pay_days,365));

    IF g_debug THEN
      debug('g_open_ended_no_pay_days', g_open_ended_no_pay_days);
    END IF;

--nocopy changes
l_entitlements_remaining_nc := p_entitlements_remaining;



-----Waiting Period Enhancement

     BEGIN

       ---Geting the Number of Waiting Days from the formula variable WAITING_DAYS.
       ---Value for WAITING_DAYS to be set and returned from the formula by the user.
       ---l_waiting_days_remaining is initialized with the waiting days.

         get_param_value
        (p_output_type     => p_output_type
        ,p_name            => 'WAITING_DAYS'
        ,p_datatype        => l_datatype
        ,p_value           => l_waiting_days_txt
        );

        IF g_debug THEN
            debug('l_waiting_days_txt:'||l_waiting_days_txt);
        END IF;

        --To happen only for absences which are being updated
     IF p_absence_start_date <> p_generate_start_date
     THEN
         OPEN  csr_sum_level_entit_duration
               (p_gap_absence_id => p_absence_attendance_id
               ,p_level_of_entitlement     => 'WAITINGDAY'
		       ,p_absence_date    => p_generate_start_date);

         FETCH csr_sum_level_entit_duration  INTO l_waiting_days_used ;
         CLOSE csr_sum_level_entit_duration ;
     END IF;

        IF g_debug THEN
            debug('l_waiting_days_used:',l_waiting_days_used);
        END IF;

        l_waiting_days_remaining:=TO_NUMBER(NVL(l_waiting_days_txt,0));
        l_waiting_days_remaining:=l_waiting_days_remaining - NVL(l_waiting_days_used,0);

        IF g_debug THEN
            debug('l_waiting_days_remaining:',l_waiting_days_remaining);
        END IF;


        IF l_waiting_days_remaining<0
        THEN
          RAISE negative_value;
        END IF;

       EXCEPTION
       WHEN   VALUE_ERROR
              OR negative_value
              OR INVALID_NUMBER
       THEN

         fnd_message.set_name( 'PQP', 'PQP_230167_OSP_NON_NUM_OFFSET' );
         fnd_message.set_token( 'TOKEN1', l_waiting_days_txt);
         fnd_message.raise_error;

      END;
--
--



--
-- 1) to check if  a day exists in the calendar or not we need to
-- call chk_calendar_occurance passing appropriate filter and value.
--
    get_param_value
     (p_output_type     => p_output_type
     ,p_name            => 'CALENDAR_VALUE'
     ,p_datatype        => l_datatype
     ,p_value           => l_calendar_value
     --,p_error_code      => l_error_code
     --,p_message         => l_error_message
     );

    l_calendar_value := TRIM(l_calendar_value); -- maybe to think about

      l_proc_step := 12;
    IF g_debug THEN
      debug(l_proc_name, l_proc_step);
    END IF;

    get_param_value
     (p_output_type     => p_output_type
     ,p_name            => 'CALENDAR_FILTER'
     ,p_datatype        => l_datatype
     ,p_value           => l_calendar_filter
     --,p_error_code      => l_error_code
     --,p_message         => l_error_message
     );

    l_calendar_filter        := UPPER(TRIM( l_calendar_filter ));

    IF l_calendar_filter IS NULL
    THEN
      l_calendar_filter    := 'ALLMATCH';
    END IF;

--
-- 2) to determine if a day is working or not we need to pass
--    the default working pattern the "is working day" function.
--    as a special case for Working/Calendar scheme we also
--    need to pass the override work pattern (if there is any)
--
--
--
-- set up Override Workpattern that is passed from create proc.
-- this is required for full timers that have absence schedule work pattern
-- attached at plan level.

-- changes made here to store the override work pattern for using it
-- later as per the override work pattern functionality.
   l_override_wp := p_override_work_pattern ;
   IF g_debug THEN
     debug('l_override_wp :=' ||l_override_wp  );
   END IF;

-- BUG 2804329 Override work pattern by this way
-- is only limited to Working entitlements and
-- Calendar days paid (Teachers Setup)
    IF p_entitlement_UOM = 'W' AND p_payment_UOM = 'C'
    THEN
      -- NOTE the actual override functionality is meant to be
      -- 1. Check if the user has set override_yn to Y if Yes then
      --   2. check if the user has supplied a work pattner name
      --     3. if not then use the default wp as the override wp
      --     4. if yes then use the named wp as the override wp
      -- As a added convenience we have made the override_yn as implied "Y"
      -- if just the override_wp is passed. Therefore the actual code logic
      -- is to check for the override_wp fisrt.


      -- check if the user has provided a override work pattern
      -- if so then use that as the override wp
      -- if he hasn't then check if he has set the override_work_pattern_yn to Y
      -- if so then use the default as the work pattern

        l_proc_step := 15;
      IF g_debug THEN
        debug(l_proc_name, 15);
      END IF;

      get_param_value
        (p_output_type     => p_output_type
        ,p_name            => 'OVERRIDE_WORK_PATTERN'
        ,p_datatype        => l_datatype
        ,p_value           => l_override_work_pattern
        --,p_error_code      => l_error_code
        --,p_message         => l_error_message
        );
     --IF l_error_code <> 0 THEN
     --  check_error_code(l_error_code,l_error_message);
     --END IF;

      IF g_debug THEN
        debug('l_override_work_pattern:' ||l_override_work_pattern);
      END IF;
      l_override_work_pattern    := TRIM( l_override_work_pattern);

      IF l_override_work_pattern IS NULL
      THEN
        -- else check if the user has indicated to use default as override
        -- if so then set the default wp as the override else override is null

        get_param_value
         (p_output_type     => p_output_type
         ,p_name            => 'OVERRIDE_WORK_PATTERN_YN'
         ,p_datatype        => l_datatype
         ,p_value           => l_override_work_pattern_yn
         --,p_error_code      => l_error_code
         --,p_message         => l_error_message
         );
        --IF l_error_code <> 0 THEN
        --  check_error_code(l_error_code,l_error_message);
        --END IF;

        IF g_debug THEN
          debug('l_override_work_pattern_yn:' ||l_override_work_pattern_yn);
        END IF;
        l_override_work_pattern_yn    :=
                   SUBSTRB( UPPER( TRIM( l_override_work_pattern_yn )), 1, 1 );

        IF l_override_work_pattern_yn = 'Y'
        THEN
          debug('override with p_default_work_pattern_name:' ||
                p_default_work_pattern_name
               );
          l_override_work_pattern    := p_default_work_pattern_name;
	  l_is_assignment_wp := FALSE;

        ELSE
          l_override_work_pattern := l_override_wp;

        END IF; -- IF l_override_work_pattern_yn = 'Y'

      ELSE
        l_is_assignment_wp := FALSE;
      END IF; -- IF l_override_work_pattern IS NULL

    END IF; -- if the scheme is working ent + cal days paid

      l_proc_step := 20;
    IF g_debug THEN
      debug(l_proc_name, 20);
    END IF;
    ----Added by akarmaka to process minband pay
    l_minimum_pay_defined :=
       pqp_gb_osp_functions.get_minimum_pay_info
               (p_assignment_id   =>   p_assignment_id
               ,p_business_group_id  => p_business_group_id
	       ,p_absence_id =>  p_absence_attendance_id
               ,p_minpay_start_date => l_minpay_start_date
               ,p_minpay_end_date => l_minpay_end_date
               ) ;



     -- if l_minimimum pay is defined then
     -- we decide to pay the pension rate
     -- only for CS and LG scheme.
     -- for CS we use the filter criteria of DUAL ROLLING
     -- for LG we use W/C scheme -- further check is reqd
     -- not available now --to be added in future

     debug('p_entitlement_UOM: '|| p_entitlement_UOM);
     debug('p_payment_UOM '|| p_payment_UOM);
     debug('p_scheme_period_type '|| p_scheme_period_type);

     IF   (p_entitlement_UOM = 'W' AND p_payment_UOM = 'C') --LG
       OR (p_scheme_period_type = 'DUALROLLING')     --CS

     THEN
         l_process_min_pay := TRUE;

     END IF ;




    IF g_debug THEN
      debug('l_minpay_start_date:'|| to_char(l_minpay_start_date));
      debug('l_minpay_end_date'|| to_char(l_minpay_end_date));
      debug('l_minimum_pay_rate'|| to_char(l_minimum_pay_rate));
    END IF;





    get_absence_part_days
      (p_absence_id     => p_absence_attendance_id
      ,p_part_start_day => l_part_start_day
      ,p_part_end_day   => l_part_end_day
      ,p_part_day_UOM   => l_part_day_UOM
      );

    l_end_date      := p_generate_end_date;
    l_current_date  := p_generate_start_date;

    --
    -- l_current_date represents the current date
    -- l_end_date represents the date upto which this loop will run for
    -- a given absence. this can only have two values either the absence end date
    -- or eot. if its the eot the process will amend the end date within the loop
    -- to be equal to the 365th day from the first date of no pay.
    -- this is could be a dangerous logic as it means that the process may run
    -- for a very long period of time if some erroneous condition or bug
    -- fails to set the end date correctly. I think we should have a safety cut
    -- out. to check with ljg on possible impact on business rules.

    IF g_debug THEN
      debug('l_current_date:');
      debug(l_current_date);
    END IF;

    IF g_debug THEN
      debug('l_end_date:');
      debug(l_end_date);
    END IF;



    dd := 0;
    WHILE l_current_date <= l_end_date
    -- AND we should have a safety cut out -- dd < l_max_iterations(1000??)
       AND dd < 2001 -- 5 * 365 = 18??
    LOOP

      dd := dd + 1;

        l_proc_step := 25+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
        debug('l_current_date:');
        debug(l_current_date);
      END IF;

      IF g_debug THEN
        l_proc_step := 30+dd/1000;
        debug(l_proc_name, l_proc_step);
      END IF;

-- 1. check if the day is marked in the calendar
--    and if so under what rule of pay is it marked.
      IF p_calendar_user_table_id IS NOT NULL AND
         pqp_gb_osp_functions.chk_calendar_occurance
          (p_date                    => l_current_date
          ,p_calendar_table_id       => p_calendar_user_table_id
          ,p_calendar_rules_list     => 'PQP_GB_OSP_CALENDAR_RULES'
          ,p_cal_rul_name            => l_calendar_rule_name -- column name (level of pay)
          ,p_cal_day_name            => l_cal_day_name -- row name (holiday name)
          ,p_cal_rule_value          => l_cal_rule_value -- value (filter)
          ,p_error_code              => l_error_code
          ,p_error_message           => l_error_message
          ,p_cal_value               => l_calendar_value
          ,p_filter                  => l_calendar_filter
          ) <> -1
      THEN
        l_proc_step := 35+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;
        l_calendar_exclusion := TRUE;
        l_calendar_rule_code    :=
          pqp_gb_osp_functions.get_lookup_code
            (p_lookup_type        => 'PQP_GB_OSP_CALENDAR_RULES'
            ,p_lookup_meaning     => l_calendar_rule_name
            ,p_message            => l_error_message
            );
      ELSE
      IF g_debug THEN
        l_proc_step := 37+dd/1000;
        debug(l_proc_name, l_proc_step);
      END IF;
         check_error_code(l_error_code,l_error_message);
         l_calendar_exclusion := FALSE;

      END IF; -- IF chk_calendar_exclusion <> -1


-- 2. check if the day is a working day or not as we this then
--    decides whether a day is entitled or not.
--    NOTE we only need to working day check if the scheme
--    has either entitlements or payments in working days/hours.
--
--
-- replace the next call to get the number of working hours for this
-- day. Use the fact that hours > 0 represents a working day
--
--
        l_proc_step := 40+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      IF p_entitlement_UOM IN ('W','H') OR p_payment_UOM IN ('W','H')
      THEN

        l_proc_step := 45+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;


--      IF pqp_schedule_calculation_pkg.is_working_day -- get_number_of_hours_worked
--        (p_assignment_id         => p_assignment_id
--        ,p_business_group_id     => p_business_group_id
--        ,p_date                  => l_current_date
--        ,p_error_code            => l_error_code
--        ,p_error_message         => l_error_message
--        ,p_default_wp            => p_default_work_pattern_name
--        ,p_override_wp           => l_override_work_pattern
--        ) = 'Y'
--      THEN
--        IF g_debug THEN
--          debug(l_proc_name, 46+dd/1000);
--        END IF;
--        l_is_working_day := TRUE;
--      ELSE
--        IF g_debug THEN
--          debug(l_proc_name, 47+dd/1000);
--        END IF;
--        check_error_code(l_error_code,l_error_message);
--        l_is_working_day := FALSE;
--      END IF;

      -- populate here l_number_of_hours_in_the_day
      l_number_of_hours_in_the_day := pqp_schedule_calculation_pkg.get_hours_worked
        (p_assignment_id     => p_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_date_start        => l_current_date
        ,p_date_end          => l_current_date
        ,p_error_code        => l_error_code
        ,p_error_message     => l_error_message
        ,p_default_wp        => p_default_work_pattern_name
        ,p_override_wp       => l_override_work_pattern
	,p_is_assignment_wp  => l_is_assignment_wp
        );

      IF l_number_of_hours_in_the_day > 0
      THEN
        l_is_working_day := TRUE;
      ELSE
        l_is_working_day := FALSE;
      END IF;


      ELSE -- for calendar calendar schemes all days are treated as working

          l_proc_step := 49+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

       l_is_working_day:= TRUE;
       --l_number_of_hours_in_the_day := 24; -- pur
       l_number_of_hours_in_the_day := pqp_schedule_calculation_pkg.get_hours_worked
        (p_assignment_id     => p_assignment_id
        ,p_business_group_id => p_business_group_id
        ,p_date_start        => l_current_date
        ,p_date_end          => l_current_date
        ,p_error_code        => l_error_code
        ,p_error_message     => l_error_message
        ,p_default_wp        => p_default_work_pattern_name
        ,p_override_wp       => l_override_work_pattern
	,p_is_assignment_wp  => l_is_assignment_wp
        );


      END IF; -- if p_ent_UOM or p_pay_UOM IN ('W','H')


      IF l_is_working_day THEN
        l_work_pattern_day_type := 'WORKON';
      ELSE
        l_work_pattern_day_type := 'OFFWORK';
      END IF;


      -- l_duration_to_process (set as hours or days as decided by ent UOM)
      -- note for non-working days hours = 0 so better to run the day loop
      -- in days and covert to hours inside it when debitting the ent.
      --
      -- set l_duration_to_process
      --
      l_duration_to_process := 1; --normally

      -- if the date is the absence end date
      -- and it has part day marked then use that as the duration
      -- to process.

        l_proc_step := 50+(dd/1000);
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
        debug(l_current_date);
        debug(p_absence_end_date);
        debug(l_part_end_day);
        debug(l_proc_name, l_proc_step);
      END IF;


      IF l_current_date = p_absence_end_date
      AND l_part_end_day IS NOT NULL
      THEN

          l_proc_step := 51+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        IF l_part_day_UOM = 'HOURS'
        AND l_number_of_hours_in_the_day > 0
        -- if its not a working day and somebody has
        -- recorded a part day in hours -- ignore it
        -- ideally these things should be UI validated
        THEN

            l_proc_step := 52+dd/1000;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          l_duration_to_process
            := l_part_end_day / l_number_of_hours_in_the_day;

        ELSIF l_part_day_UOM = 'DAYS'
        THEN

            l_proc_step := 53+dd/1000;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          l_duration_to_process := l_part_end_day;

        ELSE

            l_proc_step := 54+dd/1000;
          IF g_debug THEN
            debug('!');
            debug(l_proc_name, l_proc_step);
          END IF;

          -- not really sure -- should be an error -- will be ignored
          NULL;

        END IF; -- IF p_part_day_UOM = 'H' THEN

      END IF; -- IF l_current_date = p_absence_end_date

      -- if the date is the absence start date
      -- and it has part day marked then use that as the duration
      -- to process.

        l_proc_step := 50+(dd/1000);
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
        debug(l_current_date);
        debug(p_absence_start_date);
        debug(l_part_start_day);
        --l_proc_step := 50+(dd/1000);
        debug(l_proc_name, l_proc_step);
      END IF;

      IF  l_current_date = p_absence_start_date
      AND l_part_start_day IS NOT NULL
      THEN

          l_proc_step := 55+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;


        IF l_part_day_UOM = 'HOURS'
        AND l_number_of_hours_in_the_day > 0
        -- if its not a working day and somebody has
        -- recorded a part day in hours -- ignore it
        -- ideally these things should be UI validated
        THEN

            l_proc_step := 56+dd/1000;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          l_duration_to_process
            := l_part_start_day / l_number_of_hours_in_the_day;

        ELSIF l_part_day_UOM = 'DAYS'
        THEN

            l_proc_step := 57+dd/1000;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;


          l_duration_to_process := l_part_start_day;

        ELSE

            l_proc_step := 58+dd/1000;
          IF g_debug THEN
            debug(l_proc_name, l_proc_step);
          END IF;

          -- not really sure -- should be an error -- will be ignored
          NULL;

        END IF; -- IF p_part_day_UOM = 'H' THEN

      END IF;

      -- note if it was a single day absence
      -- and the part day information of start will be used
      -- however if the user had entered part day information
      -- in the end date and not in the start field then that
      -- may also be used as part day information.
      -- the order of the if conditions sets the precedence
      -- ie if both part days are entered for a single day
      -- absence then we will use the start day one
      -- and ignore the end day one. validation on the flex
      -- should be tightened.
      --

        l_proc_step := 60+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;


    -- 3 check if the day is entitled -- ie not excluded from entitlement
    IF NOT l_calendar_exclusion
    THEN

        l_proc_step := 65+dd/1000;
      IF g_debug THEN
        debug(l_proc_name, l_proc_step);
      END IF;

      --3a) is the day eligible to be counted towards the absence entitlement
      IF p_entitlement_UOM IN ('W','H') AND NOT l_is_working_day
      THEN
      -- if the scheme has a working entitlement and the current day is not working
      -- then mark this day as NOT entitled.

          l_proc_step := 66+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        l_count_for_entitlement := FALSE;

      ELSE

          l_proc_step := 67+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        l_count_for_entitlement:= TRUE;

      END IF;

      -- 3b) check if the day is entitled to be paid
      IF p_payment_UOM IN ('W','H') AND NOT l_is_working_day
      THEN

      -- if the scheme has a working entitlement and the current day is not working
      -- then mark this day as NOT entitled.
      --
      -- we have W% check because the same applies to Working Days and Working Hours
      -- schemes. Working Days (W) and Working Hours (WH). feedback to lookup design
          l_proc_step := 68+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        l_entitled_to_be_paid := FALSE;

      ELSE

          l_proc_step := 69+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

        l_entitled_to_be_paid := TRUE;

      END IF;

      -- we could have done withou these boolean variables
      -- however since the same condition is checked for again and again
      -- and also by use of boolean variables its possible to give these
      -- conditions a "name" hence making further code more readable.


      --Waiting Days is to be accounted for in the sick leave if the value of
      --l_waiting_days_txt is >0.
      --l_waiting_days_remaining is the reverse counter.It is initialized with l_waiting_days_txt
      --It is decremented by the duration of days used up by the waiting days in
      --every iteration and the waiting days process ends when l_waiting_days_remaining
      --decrements to 0.

     IF l_waiting_days_remaining > 0 THEN

		IF l_count_for_entitlement THEN

          --Enter this block if some waiting days are still left to be accounted
          --for and if the current day is counted for entitlement ......

             --Check if the duration to process in the current day is lees than
             --or greater than the waiting days remaining.
             --Duration to process in a current day will mostly be less than
             --or equal to the waiting days remamining exept
             --(1)Waitng days defined by the user is less than duration to
             --   process of a current day...then the starting day iteration
             --   would enter the ELSE part.
             --(2)The conclusive part of the waiting day would enter the ELSE part
             --   if waiting days remaining is in fraction due to start day
             --   being a part day or the waiting days itself is defined as fraction


             IF l_duration_to_process <= l_waiting_days_remaining  THEN
                     l_duration_to_set_as_waiting:=l_duration_to_process;
            ELSE
                     l_duration_to_set_as_waiting:=l_waiting_days_remaining;
            END IF;

            --Set the values for entitlement and pay variables which would
            --go into the daily absence table.
            IF l_entitled_to_be_paid THEN
                     l_waiting_entitlement := 'WAITINGDAY';
                     l_waiting_pay		 := 'NOBAND';
			ELSE
                     l_waiting_entitlement := 'WAITINGDAY';
                     l_waiting_pay		 := 'NOT';
		    END IF;

        ELSE -- l_count_for_entitlement

             --If the current day is not to be counted as entitled then
             --set the the appropriate values of entitlement and pay.
             --The duration processed in this iteration equals the entire duraiotn
             --of the day.
			IF l_entitled_to_be_paid THEN
                     l_waiting_entitlement := 'NOT';
                     l_waiting_pay		 := 'NOBAND';
			ELSE
                     l_waiting_entitlement := 'NOT';
                     l_waiting_pay		 := 'NOT';
		     END IF ;
             l_duration_to_set_as_waiting:=l_duration_to_process;

		END IF	;-- l_count_for_entitlement

       IF g_debug THEN
            debug('l_current_date:'||l_current_date);
            debug('l_duration_to_process:'||l_duration_to_process);
            debug('l_duration_to_set_as_waiting:'||l_duration_to_set_as_waiting);
            debug('l_waiting_days_remaining:'||l_waiting_days_remaining);
            debug('l_waiting_pay:'||l_waiting_pay);
            debug('l_waiting_entitlement:'||l_waiting_entitlement);
       END IF;

   END IF; -- l_waiting_days_remaining > 0





      -- 3c) if day is either entitled or entitled to be paid
      --     else write to the cache as NOT NOT
      IF l_count_for_entitlement OR l_entitled_to_be_paid THEN

          l_proc_step := 70+dd/1000;
        IF g_debug THEN
          debug(l_proc_name, l_proc_step);
        END IF;

      -- 3d) loop thru all the bands of entiltements remaining from BAND1 to n
      --  and debit the entitlement by the duration of the day.

          -- use this if it gets to messy
         IF l_first_available_band_index IS NULL
         THEN
           i := p_entitlements_remaining.FIRST;
           l_first_available_band_index := i;
         ELSE
           i := l_first_available_band_index;
         END IF;

         -- ensure that the search in the entitlement remaining bands
         -- skips the bands which have been completely used up in the
         -- previous days. read further to see how this is set.
         IF g_debug THEN
           debug('i:'||i);
         END IF;

         IF g_debug THEN
           debug('l_duration_to_process:'||l_duration_to_process);
         END IF;

         cc := 0;

         WHILE l_duration_to_process > 0 -- run this loop always in days
               -- while there is still some part of the day left to be processed
            AND
               i IS NOT NULL
               -- while there are still some entitlement bands remaining
               -- (i) will become once the loop iterates beyond the last
               -- index or entry in the entitlements remaining plsql table.
            AND cc < 11
         LOOP

           cc := cc + 1;

             l_proc_step := 72+(dd/1000)+(cc/100000);
           IF g_debug THEN
             debug(l_proc_name, l_proc_step);
           END IF;

            --Check if the day falls in waiting days period.
            --If yes then
            --(1)Set the daily absence cache with the pre-initialized values
            --   of p_level_of_entitlement  and p_level_of_pay
            --(2)Decrement the value of duration to process by the duration
            --   processed as waiting days i.e. l_duration_to_set_as_waiting
            --(3)If the day is counted as entitiled then decrease the waiting
            --   days remaining by the amount of duration processed as
            --   waiting days
       IF l_waiting_days_remaining > 0 THEN


             IF g_debug THEN
                  debug('l_waiting_days_remaining:',l_waiting_days_remaining);
             END IF;

             set_daily_absence_cache
               (p_daily_absences            => p_daily_absences
               ,p_absence_date              => l_current_date
               ,p_work_pattern_day_type     => l_work_pattern_day_type
               ,p_level_of_entitlement      => l_waiting_entitlement
               ,p_level_of_pay              => l_waiting_pay
               ,p_duration                  => l_duration_to_set_as_waiting
               ,p_duration_in_hours         => (l_duration_to_set_as_waiting * l_number_of_hours_in_the_day)
               ,p_working_days_per_week     => p_working_days_per_week
	           ,p_fte                       => NVL(p_fte,1)
                );

                l_duration_to_process := l_duration_to_process - l_duration_to_set_as_waiting;

            IF l_count_for_entitlement THEN
                l_waiting_days_remaining:= l_waiting_days_remaining - l_duration_to_set_as_waiting;
            END IF;

         ELSE --l_waiting_days_remaining > 0


           IF p_entitlements_remaining(i).entitlement > 0
           THEN

               l_proc_step := 73+(dd/1000)+(cc/100000);
             IF g_debug THEN
               debug(l_proc_name, l_proc_step);
             END IF;

             IF l_count_for_entitlement
             THEN

                 l_proc_step := 74+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;

               IF p_entitlement_UOM = 'H'
               THEN

                   l_proc_step := 75+(dd/1000)+(cc/100000);
                 IF g_debug THEN
                   debug(l_proc_name, l_proc_step);
                 END IF;


                 l_duration_processed :=
                   LEAST(l_duration_to_process*l_number_of_hours_in_the_day
                        ,p_entitlements_remaining(i).entitlement
                        );

                 p_entitlements_remaining(i).entitlement :=
                   p_entitlements_remaining(i).entitlement
                 - l_duration_processed;
                   --LEAST(l_number_of_hours_in_the_day
                   --     ,p_entitlements_remaining(i).entitlement
                   --     );

                 l_duration_processed := -- set duration processed back in days
                   l_duration_processed / l_number_of_hours_in_the_day;


               ELSE -- p_entitlement_UOM = 'D'ays

                   l_proc_step := 76+(dd/1000)+(cc/100000);
                 IF g_debug THEN
                   debug(l_proc_name, l_proc_step);
                 END IF;


                 l_duration_processed :=
                   LEAST(l_duration_to_process
                        ,p_entitlements_remaining(i).entitlement
                        );

                 p_entitlements_remaining(i).entitlement:=
                   p_entitlements_remaining(i).entitlement
                 - l_duration_processed;
                   --LEAST(l_duration_to_process
                   --     ,p_entitlements_remaining(i).entitlement
                   --     );


               END IF; -- IF p_entitlement_UOM = 'H'

             ELSE

                 l_proc_step := 77+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;
             -- the day is not counted for entitlement but the fact that the
             -- control is in here, implies that this day is entitled to be
             -- paid (eg scenario an off day in a Working Calendar scheme).
             -- These days are not affected by part entitlements or
             -- part durations and are always processed completely.

               l_duration_processed := l_duration_to_process;

             END IF; --IF l_count_for_entitlement

             l_duration_to_process := l_duration_to_process - l_duration_processed;

             debug('l_duration_to_process remaining:'||
                  fnd_number.number_to_canonical(l_duration_to_process)
                  );

             -- write the day to the cache
             -- date => l_current_date
             -- work_pattern_day_type => depending on l_is_working_days
             -- level_of_entitlement => 'NOT' if NOT l_counted_for_ent else (i).band
             -- level_of_pay => 'NOT' if NOT l_entitled_to_be_paid else (i).band
             -- duration =>l_duration_processed(converted appropriately)
             -- hours =>l_duration_processed(converted appropriately)

             IF l_count_for_entitlement THEN
                 l_proc_step := 77+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;
               l_level_of_entitlement := p_entitlements_remaining(i).band;
             ELSE
                 l_proc_step := 78+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;
               l_level_of_entitlement := 'NOT';
             END IF;

             IF l_entitled_to_be_paid THEN
                 l_proc_step := 79+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;
               l_level_of_pay := p_entitlements_remaining(i).band;
             ELSE
                 l_proc_step := 80+(dd/1000)+(cc/100000);
               IF g_debug THEN
                 debug(l_proc_name, l_proc_step);
               END IF;
               l_level_of_pay := 'NOT';
             END IF;

               l_proc_step := 81;
             IF g_debug THEN
               debug(l_proc_name, 81);
             END IF;

             set_daily_absence_cache
               (p_daily_absences            => p_daily_absences
               ,p_absence_date              => l_current_date
               ,p_work_pattern_day_type     => l_work_pattern_day_type
               ,p_level_of_entitlement      => l_level_of_entitlement
               ,p_level_of_pay              => l_level_of_pay
               ,p_duration                  => l_duration_processed
               ,p_duration_in_hours         => (l_duration_processed * l_number_of_hours_in_the_day)
               ,p_working_days_per_week     => p_working_days_per_week
	       ,p_fte                       => NVL(p_fte,1)
               --,p_error_code                => l_error_code
               --,p_message                   => l_error_message
               );


           END IF; -- if p_entitlements_remaining(i).ent > 0



           IF p_entitlements_remaining(i).entitlement = 0
           THEN
               l_proc_step := 82+(dd/1000)+(cc/100000);
             IF g_debug THEN
               debug(l_proc_name, l_proc_step);
             END IF;
           -- ie the current band has been completely used up
           -- (either exactly equal to the day or was insufficient)
           -- then set the first available band index to be the next
           -- band to ensure that for the next day this loop
           -- does not iterate for used up bands.

                i := p_entitlements_remaining.NEXT(i);
           -- when i = LAST, NEXT will return null

                l_first_available_band_index := i;
                 --p_entitlements_remaining.NEXT(i);
                 -- when i = LAST, NEXT will return null

           END IF; -- p_entitlements_remaining(i).entitlement = 0
        END IF; --l_waiting_days_remaining > 0


             debug(l_proc_name, 83+cc/1000);
           IF g_debug THEN
             debug('Next(i):'||i);
           END IF;


         END LOOP; --while there is still some duration to process for this day

           l_proc_step := 84;
         IF g_debug THEN
           debug(l_proc_name, 84);
         END IF;

         IF cc = 11 THEN
           fnd_message.set_name('PQP','PQP_230011_LOOP_MAX_ITERATIONS');
           fnd_message.set_token('PROCNAME',l_proc_name);
           fnd_message.set_token('PROCSTEP',85);
           fnd_message.raise_error;
         END IF;

      END IF;

        l_proc_step := 85;
      IF g_debug THEN
        debug(l_proc_name, 85);
      END IF;

    END IF; -- if NOT calendar exclusion

      l_proc_step := 90;
    IF g_debug THEN
      debug(l_proc_name, 90);
    END IF;

    IF l_duration_to_process > 0 -- four possible reasons
    THEN

      -- is a calendar exclusion
      -- is a NOT NOT day
      -- is a day gone partly into NOBAND
      -- is a NOBAND day
        l_proc_step := 91;
      IF g_debug THEN
        debug(l_proc_name, 91);
      END IF;


      IF l_calendar_exclusion
      THEN
          l_proc_step := 92;
        IF g_debug THEN
          debug(l_proc_name, 92);
        END IF;
        l_level_of_entitlement := 'EXCLUDED';
        l_level_of_pay := l_calendar_rule_code;

      ELSE
          l_proc_step := 93;
        IF g_debug THEN
          debug(l_proc_name, 93);
        END IF;
        IF l_count_for_entitlement
        THEN
            l_proc_step := 94;
          IF g_debug THEN
            debug(l_proc_name, 94);
          END IF;
          l_level_of_entitlement := 'NOBAND';

          IF g_debug THEN
            debug('l_end_date:');
            debug(l_end_date);
          END IF;

          IF l_end_date = hr_api.g_eot THEN
          -- this is the first day of No Pay
              l_proc_step := 95;
            IF g_debug THEN
              debug(l_proc_name, 95);
            END IF;
            l_end_date := l_current_date + g_open_ended_no_pay_days;

            IF g_debug THEN
              debug('New l_end_date:');
              debug(l_end_date);
            END IF;
              l_proc_step := 96;
            IF g_debug THEN
              debug(l_proc_name, 96);
            END IF;
          END IF;
            l_proc_step := 97;
          IF g_debug THEN
            debug(l_proc_name, 97);
          END IF;
        ELSE
            l_proc_step := 98;
          IF g_debug THEN
            debug(l_proc_name, 98);
          END IF;
          l_level_of_entitlement := 'NOT';

        END IF;
          l_proc_step := 99;
        IF g_debug THEN
          debug(l_proc_name, 99);
        END IF;
        IF l_entitled_to_be_paid
        THEN
            l_proc_step := 100;
          IF g_debug THEN
            debug(l_proc_name, 100);
          END IF;
            l_level_of_pay := 'NOBAND';
       -- check if minimum pay is defined
       -- and set the level of pay accordingly.


	  -- days which are due to be paid as NOBANDMIN
  -- IF LG or CS | check attribute of scheme (future)
  --  is current date between pension start and end date
  --  if so mark level of pay as nobandmin
  --  else mark as noband
  -- else mark as noband

  -- set the effective start date for payment of pension rate
  -- if start date provided is Null then
  -- start paying the employee with  NOBANDMIN level of pay
  -- from first day of no band.
  -- Similarly, if the pension rate end date is not given then it
  -- wil mark level of pay as nobandmin till the end of the absence
          IF l_process_min_pay THEN

	    IF l_effective_minpay_start_day IS NULL THEN
              l_effective_minpay_start_day:= NVL(l_minpay_start_date,l_current_date);
            END IF;
	    IF l_effective_minpay_end_day  IS NULL THEN
	      l_effective_minpay_end_day := NVL(l_minpay_end_date,p_generate_end_date);
            END IF;

	    IF g_debug THEN
	      debug('l_effective_minpay_start_day:='||l_effective_minpay_start_day);
	      debug('l_effective_minpay_end_day:='||l_effective_minpay_end_day);
	    END IF;
            IF l_minimum_pay_defined <> 0 THEN
               IF ((l_current_date >= l_effective_minpay_start_day)
	          AND (l_current_date <= l_effective_minpay_end_day ) )
	       THEN
	         l_level_of_pay := 'NOBANDMIN';

	       END IF ;

            ELSE -- l_minimum_pay_defined <> 0 THEN
              l_level_of_pay := 'NOBAND';
	    END IF ; -- l_minimum_pay_defined <> 0 THEN
          END IF ;  -- IF l_process_min_pay THEN

        ELSE
            l_proc_step := 101;
          IF g_debug THEN
            debug(l_proc_name, 101);
          END IF;
          l_level_of_pay := 'NOT';

        END IF;
            l_proc_step := 102;
          IF g_debug THEN
            debug(l_proc_name, 102);
          END IF;

     END IF; -- calendar exclusion
            l_proc_step := 103;
          IF g_debug THEN
            debug(l_proc_name, 103);
          END IF;

     --l_shift_duration := l_duration_to_process;
     --l_hours_duration := l_duration_to_process * l_number_of_working_hours;

     -- write the day to the cache
     -- date => l_current_date
     -- work_pattern_day_type => l_work_pattern_day_type
     -- level_of_entitlement => l_level_of_entitlement
     -- level_of_pay => l_level_of_payment
     -- duration => l_shift_duration
     -- hours => l_hours_duration

       set_daily_absence_cache
         (p_daily_absences            => p_daily_absences
         ,p_absence_date              => l_current_date
         ,p_work_pattern_day_type     => l_work_pattern_day_type
         ,p_level_of_entitlement      => l_level_of_entitlement
         ,p_level_of_pay              => l_level_of_pay
         ,p_duration                  => l_duration_to_process
         ,p_duration_in_hours          => (l_duration_to_process * l_number_of_hours_in_the_day)
         ,p_working_days_per_week     => p_working_days_per_week
	 ,p_fte                       => NVL(p_fte,1)
         --,p_error_code                => l_error_code
         --,p_message                   => l_error_message
         );

          l_proc_step := 104;
        IF g_debug THEN
          debug(l_proc_name, 104);
        END IF;

    END IF; -- if l_duration_to_process > 0

  l_current_date := l_current_date + 1;

  END LOOP; -- for each day of absence.

    l_proc_step := 105;
  IF g_debug THEN
    debug(l_proc_name, 105);
  END IF;

  IF dd = 2001 THEN
    fnd_message.set_name('PQP','PQP_230011_LOOP_MAX_ITERATIONS');
    fnd_message.set_token('PROCNAME',l_proc_name);
    fnd_message.set_token('PROCSTEP',105);
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_entitlements_remaining := l_entitlements_remaining_nc;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END generate_daily_absences;
--
--
--
PROCEDURE update_absence_plan_details
  (p_assignment_id             IN            NUMBER
  ,p_person_id                 IN            NUMBER
  ,p_business_group_id         IN            NUMBER
  ,p_absence_id                IN            NUMBER
  ,p_absence_date_start        IN            DATE
  ,p_absence_date_end          IN            DATE
  ,p_pl_id                     IN            NUMBER
  ,p_pl_typ_id                 IN            NUMBER
  ,p_element_type_id           IN            NUMBER
  ,p_update_start_date         IN            DATE
  ,p_update_end_date           IN            DATE
  ,p_output_type               IN            ff_exec.outputs_t
  ,p_error_code                   OUT NOCOPY NUMBER
  ,p_message                      OUT NOCOPY VARCHAR2
  )
IS

  l_absence_start_date            DATE;
  l_absence_end_date              DATE;
  l_absence_dates                 csr_absence_dates%ROWTYPE;
  l_gap_absence_plan              csr_gap_absence_plan%ROWTYPE;
  l_first_entitled_day_of_noband  csr_first_entitled_day_of_band%ROWTYPE;
  l_error_code                    fnd_new_messages.message_number%TYPE:=0;
  l_error_message                 fnd_new_messages.message_text%TYPE;

  l_proc_step                   NUMBER(20,10);
  l_proc_name                   VARCHAR2(61):=
                                    g_package_name||
                                    'update_absence_plan_details';
l_open_ended_no_pay_days  NUMBER;
l_part_start_day              pqp_gap_daily_absences.duration%TYPE;
l_part_end_day                pqp_gap_daily_absences.duration%TYPE;
l_part_day_UOM                per_absence_attendances.abs_information3%TYPE;
BEGIN


  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
    debug_enter(l_proc_name);
    debug(p_assignment_id);
    debug(p_person_id);
    debug(p_business_group_id);
    debug(p_absence_id);
    debug(p_absence_date_start);
    debug(p_absence_date_end);
    debug(p_pl_id);
    debug(p_pl_typ_id);
    debug(p_element_type_id);
    debug(p_update_start_date);
    debug(p_update_end_date);
  END IF; -- IF g_debug THEN

--
-- Update logic
-- an update is effectively a delete and a create
-- however it would be very inefficient if for every update
-- (which would occur once for every absence) we completley delete
-- and recreate. For that reason the delete and create
-- need to be arranged such that they only delete the extra bits
-- and create the missing bits.
-- to keep the logic simple we need design such that
--
-- delete will remove the unwanted part
-- create will create any missing part.
--
-- lets examine the scenarios that this update is called
-- i) end date processing
--
-- ii) end date updated
--
--     a) to a date greater than the current end date
--
--     b) to a date less than the current end date
--
-- iii) start date is updated or a correction takes place
--      which fires a start event.
--
--      In this case the update is called not as part of
--      start event processing but as a part of the reversing
--      out the prev processed life events.
--
-- For case i) we normally wouldn't need to do anything because
-- the start processing would have created everything upto the end date
-- only exception being a) when an open ended absence is ended or b)
-- an end dated absence is "re-opened"
-- ia) delete everything from (new)absence_end_date+1.
-- ib) create from (old)absence_end_date+1
--
-- For case ii)
-- iia) create from old absence_end_date+1
-- iib) delete from new absence_end_date+1
--
-- For case iii) careful, normally we need to do nothing
-- as the data will be deleted when the start is reversed
-- and recreated when the start is re-processed. thats generally
-- true for all start event (updates).
--
--
--
-- so
-- if new_end_date < last_gap_daily_absence_date then
-- delete between new_end_date+1 and last_gap_daily_absence_date
-- if new_end_date > last_gap_daily_absence_date then
-- create between last_gap_daily_absence_date+1 and new_end_date
--
-- how does this logic fit with the above scenarios
-- i) normal end date processing
--   new_end_date = last_gap_daily_absence_date => no action
--
-- ia) open ended absence closed
--    implies new_end_date < last_gap_absence_date hence delete excess
--    may rarely be new_end_date > last_gap_absence_date hence create missing
--
-- ib) closed absence re-opened
--     implies new_date_date(eot)> last_gap_daily_absence_date hence create
-- missing
--
-- ii) end date updates
-- iia) absence end extended
--    new_end_date > last_gap_daily_absence_date => create
-- iib) absence shortened
--    new_end_date < last_gap_daily_absence_date => delete
--
-- iii) Start event (update called with same new start and same end)
--   new_end_date = last_gap_daily_absence_date => no action
--
-- what breaks the logic are open ended absences where it is not possible
-- to determine whether an existing closed absence has been re-opended
-- or has an update being invoked for open ended absences.
--
-- if updates are issued for open ended absences then in the worst case
-- scenarion we need to determin the first date of no-pay and check
-- if the last gap daily absence date = 365+first date of no pay
--
--

    l_proc_step := 10;
  IF g_debug THEN
    debug(l_proc_name, 10);
  END IF;

    -- Set value for open ended absence no pay days
    l_open_ended_no_pay_days :=
         PQP_UTILITIES.pqp_get_config_value(
                 p_business_group_id     => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION8'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

    g_open_ended_no_pay_days :=
                    FND_NUMBER.canonical_to_number(NVL(l_open_ended_no_pay_days,365));

    IF g_debug THEN
      debug('g_open_ended_no_pay_days', g_open_ended_no_pay_days);
    END IF;



  l_absence_end_date   := NVL(p_absence_date_end,hr_api.g_eot);
  --NVL(l_absence_dates.date_end,hr_api.g_eot);

--IF p_absence_date_start IS NOT NULL THEN -- ie absence not deleted

    l_proc_step := 31;
  IF g_debug THEN
    debug(l_proc_name, 31);
  END IF;

  OPEN csr_gap_absence_plan(p_absence_id, p_pl_id);
  FETCH csr_gap_absence_plan INTO l_gap_absence_plan;
  CLOSE csr_gap_absence_plan;

    l_proc_step := 32;
  IF g_debug THEN
    debug(l_proc_name, 32);
  END IF;

  IF l_absence_end_date = hr_api.g_eot -- if its an open ended absence
  THEN

      l_proc_step := 33;
    IF g_debug THEN
      debug(l_proc_name, 33);
    END IF;
    -- if it can be shown that this code does get executed then
    -- we need to have l_absence_end_date
    -- else we can get rid of the absence_end_date also

    OPEN csr_first_entitled_day_of_band
      (l_gap_absence_plan.gap_absence_plan_id
      ,'NOBAND'
      );

      l_proc_step := 34;
    IF g_debug THEN
      debug(l_proc_name, 34);
    END IF;

    FETCH csr_first_entitled_day_of_band INTO l_first_entitled_day_of_noband;

      l_proc_step := 35;
    IF g_debug THEN
      debug(l_proc_name, 35);
    END IF;

    IF csr_first_entitled_day_of_band%FOUND
    THEN

        l_proc_step := 36;
      IF g_debug THEN
        debug(l_proc_name, 36);
      END IF;

      IF l_first_entitled_day_of_noband.absence_date + l_open_ended_no_pay_days --(or 366 bug)
          = l_gap_absence_plan.last_gap_daily_absence_date
      THEN

          l_proc_step := 37;
        IF g_debug THEN
          debug(l_proc_name, 37);
        END IF;

        -- its an update call for an open ended absence.
        -- and needs no action as it has allready been generated to the
        -- maximum extent possible for an open ended absence.
        -- hence set the absence end date = last gap daily abs date
        l_absence_end_date := l_gap_absence_plan.last_gap_daily_absence_date;

      END IF; -- IF l_first_entitled_day_of_noband.absence_date + 365

        l_proc_step := 38;
      IF g_debug THEN
        debug(l_proc_name, 38);
      END IF;

    END IF; -- IF csr_first_entitled_day_of_band%FOUND THEN

      l_proc_step := 39;
    IF g_debug THEN
      debug(l_proc_name, 39);
    END IF;

    CLOSE csr_first_entitled_day_of_band;

  END IF; -- IF l_absence_end_date = hr_api.g_eot

    l_proc_step := 40;
  IF g_debug THEN
    debug(l_proc_name, 40);
  END IF;

    get_absence_part_days
      (p_absence_id     => p_absence_id
      ,p_part_start_day => l_part_start_day
      ,p_part_end_day   => l_part_end_day
      ,p_part_day_UOM   => l_part_day_UOM
      );


   IF l_absence_end_date > l_gap_absence_plan.last_gap_daily_absence_date
  THEN

      l_proc_step := 45;
    IF g_debug THEN
      debug(l_proc_name, 45);
    END IF;
   --Part Day Correction....
   --If Part days then delete current end date
   --Process from previous end date to the modified end date

       IF l_part_end_day IS NOT NULL
       THEN
		delete_absence_plan_details
		(p_assignment_id             => p_assignment_id
		,p_business_group_id         => p_business_group_id
		,p_plan_id                   => p_pl_id
		,p_absence_id                => p_absence_id
		,p_delete_start_date         => l_gap_absence_plan.last_gap_daily_absence_date
		,p_delete_end_date           => l_gap_absence_plan.last_gap_daily_absence_date
		,p_error_code                => l_error_code
		,p_message                   => l_error_message
		);

		create_absence_plan_details
		(p_assignment_id             => p_assignment_id
		,p_person_id                 => p_person_id
		,p_business_group_id         => p_business_group_id
		,p_absence_id                => p_absence_id
		,p_absence_date_start        => p_absence_date_start
		,p_absence_date_end          => p_absence_date_end
		,p_pl_id                     => p_pl_id
		,p_pl_typ_id                 => p_pl_typ_id
		,p_element_type_id           => p_element_type_id
		,p_create_start_date         => l_gap_absence_plan.last_gap_daily_absence_date
		,p_create_end_date           => l_absence_end_date
		,p_output_type               => p_output_type
		,p_error_code                => l_error_code
		,p_message                   => l_error_message
		);
	 ELSE
		create_absence_plan_details
		(p_assignment_id             => p_assignment_id
		,p_person_id                 => p_person_id
		,p_business_group_id         => p_business_group_id
		,p_absence_id                => p_absence_id
		,p_absence_date_start        => p_absence_date_start
		,p_absence_date_end          => p_absence_date_end
		,p_pl_id                     => p_pl_id
		,p_pl_typ_id                 => p_pl_typ_id
		,p_element_type_id           => p_element_type_id
		,p_create_start_date         => l_gap_absence_plan.last_gap_daily_absence_date + 1
		,p_create_end_date           => l_absence_end_date
		,p_output_type               => p_output_type
		,p_error_code                => l_error_code
		,p_message                   => l_error_message
		);

	   END IF;

  ELSIF l_absence_end_date < l_gap_absence_plan.last_gap_daily_absence_date
  THEN

      l_proc_step := 50;
    IF g_debug THEN
      debug(l_proc_name, 50);
    END IF;
   --Part Day Correction....
   --If Part days then delete start date to be l_absence_end_date
   --Process end date again by calling create absence for the end date
      IF l_part_end_day IS NOT NULL
      THEN

	    delete_absence_plan_details
	      (p_assignment_id             => p_assignment_id
	      ,p_business_group_id         => p_business_group_id
	      ,p_plan_id                   => p_pl_id
	      ,p_absence_id                => p_absence_id
	      ,p_delete_start_date         => l_absence_end_date
	      ,p_delete_end_date           => l_gap_absence_plan.last_gap_daily_absence_date
	      ,p_error_code                => l_error_code
	      ,p_message                   => l_error_message
	      );

	    create_absence_plan_details
	     (p_assignment_id             => p_assignment_id
	     ,p_person_id                 => p_person_id
	     ,p_business_group_id         => p_business_group_id
	     ,p_absence_id                => p_absence_id
	     ,p_absence_date_start        => p_absence_date_start
	     ,p_absence_date_end          => p_absence_date_end
	     ,p_pl_id                     => p_pl_id
	     ,p_pl_typ_id                 => p_pl_typ_id
	     ,p_element_type_id           => p_element_type_id
	     ,p_create_start_date         => l_absence_end_date
	     ,p_create_end_date           => l_absence_end_date
	     ,p_output_type               => p_output_type
	     ,p_error_code                => l_error_code
	     ,p_message                   => l_error_message
	    );

	ELSE
	    delete_absence_plan_details
	      (p_assignment_id             => p_assignment_id
	      ,p_business_group_id         => p_business_group_id
	      ,p_plan_id                   => p_pl_id
	      ,p_absence_id                => p_absence_id
	      ,p_delete_start_date         => l_absence_end_date+1
	      ,p_delete_end_date           => l_gap_absence_plan.last_gap_daily_absence_date
	      ,p_error_code                => l_error_code
	      ,p_message                   => l_error_message
	      );
       END IF;
  ELSE -- l_absence_end_date = l_gap_absence_plan.last_gap_daily_absence_date
  -- no action required -- information only step.
      l_proc_step := 55;
    IF g_debug THEN
      debug(l_proc_name, 55);
      NULL; -- no action required
    END IF;

  END IF; -- IF l_absence_end_date > last_gap_daily_absence_date

--END IF; -- IF p_absence_date_start IS NOT NULL THEN -- ie absence not deleted

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END update_absence_plan_details;
--
-- This procedure is called during create absence plans.
--
PROCEDURE create_absence_plan_details
  (p_assignment_id             IN            NUMBER
  ,p_person_id                 IN            NUMBER
  ,p_business_group_id         IN            NUMBER
  ,p_absence_id                IN            NUMBER
  ,p_absence_date_start        IN            DATE
  ,p_absence_date_end          IN            DATE
  ,p_pl_id                     IN            NUMBER
  ,p_pl_typ_id                 IN            NUMBER
  ,p_element_type_id           IN            NUMBER
  ,p_create_start_date         IN            DATE
  ,p_create_end_date           IN            DATE
  ,p_output_type               IN            ff_exec.outputs_t
  ,p_error_code                   OUT NOCOPY NUMBER
  ,p_message                      OUT NOCOPY VARCHAR2
  )
IS

    invalid_length_of_service EXCEPTION;

    l_absence_dates               csr_absence_dates%ROWTYPE;
    l_gap_absence_plan            csr_gap_absence_plan%ROWTYPE;

    l_entitlement_parameters_UDT  pay_user_tables.user_table_id%TYPE:= -1;
    l_length_of_service           NUMBER(38);
    l_absence_start_date          DATE;
    l_absence_end_date            DATE;
    l_generate_start_date         DATE;
    l_generate_end_date           DATE;
    l_band_val                    VARCHAR2(10) := 'NONE';
    l_datatype                    VARCHAR2(6);
    l_value                       VARCHAR2(240);
    l_gap_absence_plan_id         pqp_gap_absence_plans.gap_absence_plan_id%TYPE;

    l_plan_information            rec_plan_information;
    l_entitlements                pqp_absval_pkg.t_entitlements;
    l_absences_taken_to_date      pqp_absval_pkg.t_entitlements;
    l_entitlements_remaining      pqp_absval_pkg.t_entitlements;
    l_daily_absences              pqp_absval_pkg.t_daily_absences;
                                  --table of pqp_gda_shd.g_rec_type
    l_object_version_number       pqp_gap_absence_plans.object_version_number%TYPE;
    l_gap_absence_plan_id         pqp_gap_absence_plans.gap_absence_plan_id%TYPE;

    l_error_code                  fnd_new_messages.message_number%TYPE;
    l_error_message               fnd_new_messages.message_text%TYPE;
    l_calendar_column_name        VARCHAR2(30);
    l_proc_step                   NUMBER(20,10);
    l_proc_name                   VARCHAR2(61)
                            := g_package_name                ||
                               'create_absence_plan_details';

    l_entitlement_UOM   pay_element_type_extra_info.eei_information1%TYPE ;
    l_scheme_category   pay_element_type_extra_info.eei_information1%TYPE ;
    l_working_days_per_week pqp_gap_daily_absences.working_days_per_week%TYPE;

    l_override_scheme_start_date  DATE;
    l_assignment_work_pattern    pqp_assignment_attributes_f.work_pattern%TYPE ;


 --LG/PT
--    l_standard_working_days pqp_gap_daily_absences.working_days_per_week%TYPE;
--    l_standard_ft_work_pattern pqp_assignment_Attributes_f.work_pattern%TYPE ;
--    l_assignment_work_pattern pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_contract_wp pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_current_factor NUMBER ;
    l_ft_factor  NUMBER ;
--    i NUMBER ;
    l_fte           pqp_gap_daily_absences.fte%TYPE ;
    l_FT_absence_wp pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_FT_working_wp pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_is_full_timer BOOLEAN ;
    l_override_wp   pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_assignment_wp pqp_assignment_Attributes_f.work_pattern%TYPE ;
    l_update_summary BOOLEAN;
    l_is_assignment_wp BOOLEAN;

  BEGIN

  g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_assignment_id);
      debug(p_person_id);
      debug(p_business_group_id);
      debug(p_absence_id);
      debug(p_absence_date_start);
      debug(p_absence_date_end);
      debug(p_pl_id);
      debug(p_pl_typ_id);
      debug(p_element_type_id);
      debug(p_create_start_date);
      debug(p_create_end_date);
      l_proc_step := 10;
      debug(l_proc_name, 10);
    END IF;

   -- Set global switch to toggle the summary table logging

   IF  g_log_duration_summary is NULL
   THEN

       IF g_debug THEN
         debug(l_proc_name, 12);
       END IF;

       g_log_duration_summary :=
       PQP_UTILITIES.pqp_get_config_value
               ( p_business_group_id    => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION10'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

       g_log_duration_summary := NVL(g_log_duration_summary,'DISABLE');

       IF g_debug THEN
         debug('g_log_duration_summary' || g_log_duration_summary);
       END IF;

   END IF;



    --Set the global rounding factor cache if the values are not already set

      IF  g_ft_entitl_rounding_type is null OR g_round_cache_plan_id <> p_pl_id THEN
        PQP_GB_OSP_FUNCTIONS.set_osp_omp_rounding_factors
          (p_pl_id                    => p_pl_id
          ,p_pt_entitl_rounding_type  => g_pt_entitl_rounding_type
          ,p_pt_rounding_precision    => g_pt_rounding_precision
          ,p_ft_entitl_rounding_type  => g_ft_entitl_rounding_type
          ,p_ft_rounding_precision    => g_ft_rounding_precision
          );
          g_round_cache_plan_id := p_pl_id ;
    END IF;


   IF g_debug THEN
      debug('p_pt_entitl_rounding_type' || g_pt_entitl_rounding_type);
      debug('p_pt_rounding_precision' , g_pt_rounding_precision);
      debug('p_ft_entitl_rounding_type' || g_ft_entitl_rounding_type);
      debug('p_ft_rounding_precision' , g_ft_rounding_precision);
      debug(l_proc_name, 15);
  END IF;

--
-- To create daily absence details we need to know
--
-- 1. the assignments current entitlement
--    to determine the current entitlement
--    we need to
--    a) know the length of service
--    b) know the entitlement UDT (id or name)
--    c) query the UDT with the length of service as the range
--
-- 2. the entitlement balance, to determine that we need to
--    a) know the absences taken to date (ie in the absence year)
--    b) entitlement remaining = entitlement from 1(c) - absence taken 2(a)
--
-- 3. then start a day by day debit process of the entilements remaining
--    against the current absence and generate daily absence information
--    a) for performance write this information to a pl/sql table
--    b) do a bulk insert.

--OPEN csr_absence_dates(p_absence_id);
--FETCH csr_absence_dates INTO l_absence_dates;
--IF g_debug THEN
--l_proc_step := 20;
debug(l_proc_name, 20);
--END IF;
--CLOSE csr_absence_dates;

--IF g_debug THEN
--  l_proc_step := 30;
  debug(l_proc_name, 30);
--END IF;

-- we need to distinguish between the absence start and end dates
-- and the p_create_start_date and p_create_end_date
-- the p_start and p_end_date represent the range of dates over which
-- the calling procedure wants the daily absence information to be generated
-- which may or may not the whole range of the absence start and end date
-- for eg
-- during update processing
-- if the end date has been extended by say another 10 days
-- then we will call the create for the same absence id
-- but pass a p_create_start_date as (last_end_date+1) and p_end_date
-- as the new end date (last_end_date+10...)
--
-- in all cases three things are important
-- a) the entitlement should always be derived as of the start of the absence
-- b) generate_start_date = GREATEST(p_start,l_absence_start)
-- c) generate_end_date = LEAST(p_end,l_absence_end)
--
-- to ensure a) we need to make sure that when fetching entitlements
-- we pass the effective date as l_absence_start
--
-- when fetching the absences_taken_to_date we need to pass the
-- generate_start_date
--
-- when generating the absences we need to pass the generate_start and end
-- not the absence_start and end
--
-- why all this? to maximize re-usability of this code for update processing.
--
--
-- create should always create between
-- the NVL(last_gap_daily_absence_date+1,absence_start_date)
--and
-- the NVL(absence end date,first_day_of_NOBAND+365)
--
-- no matter what the p_create_start_date and p_end_date are
--
      l_generate_start_date :=
        GREATEST(p_create_start_date,p_absence_date_start);
--
      l_generate_end_date :=
        LEAST(NVL(p_create_end_date,hr_api.g_eot),p_absence_date_end);
--
-- If daily absences exist for the given range for this plan then
-- don't continue with the create process. Exit without error.
-- This would happen in almost every absence, ie when the end
-- life event is encountered and assuming that the end hasn't changed
-- the batch was run
--
      l_proc_step := 50;
    IF g_debug THEN
      debug(l_proc_name, 50);
    END IF;

    IF l_generate_start_date IS NOT NULL
     AND -- both are not needed but just makes it more robust
       l_generate_end_date IS NOT NULL
    THEN

        l_proc_step := 60;
      IF g_debug THEN
        debug(l_proc_name, 60);
      END IF;

--
-- The creation of daily absences is subject to the rules of the plan
-- under which the absence is being processed. Since these rules
-- will be referred to at various points in the process, and
-- also repeatedly for each day of the absence, we upload the
-- plan details into a cache which is repeatedly referred to till
-- such time that the same call is made for a different plan.
---
        l_proc_step := 70;
      IF g_debug THEN
        debug(l_proc_name, 70);
      END IF;

      get_plan_extra_info_n_cache_it
       (p_pl_id            => p_pl_id
       ,p_plan_information => l_plan_information
       ,p_business_group_id   => p_business_group_id
       ,p_assignment_id       => p_assignment_id
       ,p_effective_date      => p_absence_date_start
       --,p_error_code       => l_error_code
       --,p_message          => l_error_message
       );


      -- Copy to local as this then has to be passed as parameters
      -- Note the efficiency achieved is not because we refer
      -- to globals but because the global is not fetched from
      -- the database unless the plan to which it relates is changed.

        l_proc_step := 75;
      IF g_debug THEN
        debug(l_proc_name, 75);
      END IF;


-- Check here if the Scheme is a UNPAID Scheme.
-- If it is unpaid dont need to look at length of service or entitlements
-- Populate the entitlements table with BAND1 and 0
-- and set the remaining values that are required for procedure
-- generate_daily_absences and that should process the schemes

    l_scheme_category := l_plan_information.absence_pay_plan_category ;


--------------

     IF UPPER(l_scheme_category) = 'UNPAID' THEN

       l_entitlements_remaining(1).band := 'BAND1' ;
       l_entitlements_remaining(1).entitlement := 0 ;
       l_entitlement_UOM := l_plan_information.absence_days_type ;
       OPEN  csr_get_wp(p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
		     ,p_effective_date    => l_generate_start_date);

       FETCH csr_get_wp  INTO l_assignment_work_pattern ;
       CLOSE csr_get_wp ;

       IF l_assignment_work_pattern IS NULL
       THEN
           l_is_assignment_wp := FALSE;
           l_assignment_wp    := l_plan_information.default_work_pattern_name;
       ELSE
           l_is_assignment_wp := TRUE;
           l_assignment_wp    := l_assignment_work_pattern;

       END IF;
       l_override_wp := l_assignment_wp;


     ELSE -- else if 'UNPAID' i.e. executed for 'SICKNESS'

-- 1a) retrieve and validate the length of service
      BEGIN

        get_param_value
         (p_output_type     => p_output_type
         ,p_name            => 'LENGTH_OF_SERVICE'
         ,p_datatype        => l_datatype
         ,p_value           => l_value
         --,p_error_code      => l_error_code
         --,p_message         => l_error_message
         );

        l_length_of_service    := TO_NUMBER(l_value);

        IF l_length_of_service IS NULL
        THEN
          RAISE invalid_length_of_service;
        END IF;

      EXCEPTION
       WHEN   VALUE_ERROR
           OR invalid_length_of_service
           OR INVALID_NUMBER -- doesn't arise in PL/SQL
       THEN

         fnd_message.set_name( 'PQP', 'PQP_230012_OSPOMP_INALID_LOS' );
         fnd_message.set_token( 'TOKEN', NVL(l_value,'<Null>'));
         fnd_message.raise_error;

      END;

      BEGIN

        get_param_value
         (p_output_type     => p_output_type
         ,p_name            => 'OVERRIDE_SCHEME_START_DATE'
         ,p_datatype        => l_datatype
         ,p_value           => l_value
         --,p_error_code      => l_error_code
         --,p_message         => l_error_message
         );

        l_override_scheme_start_date := fnd_date.canonical_to_date(l_value);
        debug('l_override_scheme_start_date:'||
          fnd_date.date_to_canonical(l_override_scheme_start_date));

      EXCEPTION
       WHEN VALUE_ERROR
           OR invalid_length_of_service
           OR INVALID_NUMBER -- doesn't arise in PL/SQL
       THEN

         fnd_message.set_name( 'PQP', 'PQP_230012_OSPOMP_INALID_LOS' );
         fnd_message.set_token( 'TOKEN', NVL(l_value,'<Null>'));
         fnd_message.raise_error;

      END;



-- 1b) the entitlement UDT (id or name)
      l_entitlement_parameters_UDT    := l_plan_information.entitlement_parameters_UDT_id;

        l_proc_step := 80;
      IF g_debug THEN
        debug(l_proc_name, 80);
      END IF;

-- 1c) Retrieve the entitlements from the UDT using the LOS
      -- multiply FTE in here.
--      l_error_code:=
--        pqp_gb_osp_functions.get_los_based_entitlements -- ppq_get_los_based_entitlements
--          (p_business_group_id              => p_business_group_id
--          ,p_effective_date                 => p_absence_date_start -- business rule hard coded
--          ,p_assignment_id                  => p_assignment_id
--          ,p_pl_id                          => p_pl_id
--          ,p_absence_pay_plan_class         => 'OSP' -- ?? hard code not good for OMP ??
--          ,p_entitlement_table_id           => l_entitlement_parameters_UDT
--          ,p_benefits_length_of_service     => l_length_of_service
--          ,p_band_entitlements              => l_entitlements
--          ,p_error_msg                      => l_error_message
         -- ,p_entitlement_bands_list_name    => 'PQP_GAP_ENTITLEMENT_BANDS'
         -- default
--          );

        pqp_gb_osp_functions.get_entitlements
            (p_assignment_id              => p_assignment_id
            ,p_business_group_id          => p_business_group_id
            ,p_effective_date             => p_absence_date_start
            ,p_pl_id                      => p_pl_id
            ,p_entitlement_table_id       => l_entitlement_parameters_UDT
            ,p_benefits_length_of_service => l_length_of_service
            ,p_band_entitlements          => l_entitlements
            ) ;

        l_proc_step := 90;
      IF g_debug THEN
        debug(l_proc_name, 90);
      END IF;

      check_error_code(l_error_code,l_error_message);



    IF l_plan_information.scheme_period_type = 'DUALROLLING' THEN

     l_proc_step := 91 ;
     IF g_debug THEN
        debug(l_proc_name,91);
     END IF;

     -- PERSON LEVEL ABSENCE CHANGES FOR CSS
     -- the CSS absence creation calls proc get_absences_taken
     -- to determine the absences taken.
     -- The global is set here for civil services coz the call to
     -- get_absences_taken is direct from it , unlike thru
     -- the get_absences_taken_to_date.

     g_deduct_absence_for :=
     PQP_UTILITIES.pqp_get_config_value
               ( p_business_group_id    => p_business_group_id
                ,p_legislation_code     => 'GB'
                ,p_column_name          => 'PCV_INFORMATION9'
                ,p_information_category => 'PQP_GB_OSP_OMP_CONFIG'
                );

      IF g_debug THEN
         debug(l_proc_name,l_proc_step);
	 debug('g_deduct_absence_for :' ||g_deduct_absence_for);
      END IF;


      --Call the css daily absences procedure here.
      -- is this proc name appropriate now?

     pqp_gb_css_daily_absences.create_absence_plan_details
            ( p_assignment_id      => p_assignment_id
             ,p_business_group_id  => p_business_group_id
             ,p_absence_id         => p_absence_id
             ,p_pl_id              => p_pl_id
             ,p_pl_typ_id          => p_pl_typ_id
             ,p_create_start_date  => l_generate_start_date
             ,p_create_end_date    => l_generate_end_date
             ,p_entitlements       => l_entitlements
             ,p_plan_information   => l_plan_information
             ,p_entitlements_remaining => l_entitlements_remaining
             ,p_entitlement_UOM    => l_entitlement_UOM
             ,p_working_days_per_week => l_working_days_per_week
             ,p_fte  => l_fte
--             ,p_error_code         => l_error_code
--             ,p_message            => l_error_message
            ) ;


    ELSE -- 'DUALROLLING' check

--
-- 2a) Retrieve the entitlements used upto date in this sickness year
-- and then determine the entitlements remaining.

          get_factors (
                p_business_group_id   => p_business_group_id
               ,p_effective_date      => p_absence_date_start
               ,p_assignment_id       => p_assignment_id
               ,p_entitlement_uom     => l_plan_information.absence_days_type
               ,p_default_wp          => l_plan_information.default_work_pattern_name
               ,p_absence_schedule_wp => l_plan_information.absence_schedule_work_pattern
               ,p_track_part_timers   => l_plan_information.track_part_timers
               ,p_current_factor      => l_current_factor
               ,p_ft_factor           => l_ft_factor
               ,p_working_days_per_week => l_working_days_per_week
               ,p_fte                   => l_fte
               ,p_FT_absence_wp         => l_FT_absence_wp
               ,p_FT_working_wp         => l_FT_working_wp
               ,p_assignment_wp         => l_assignment_wp
               ,p_is_full_timer         => l_is_full_timer
	       ,p_is_assignment_wp      => l_is_assignment_wp
                ) ;


	   convert_entitlements
	        ( p_entitlements   => l_entitlements
	         ,p_current_factor => l_current_factor
                 ,p_ft_factor      => l_ft_factor
		) ;


	   IF l_plan_information.absence_schedule_work_pattern IS NOT NULL
	      AND l_is_full_timer THEN
	      l_override_wp := l_FT_absence_wp ;
           ELSE
	      l_override_wp := l_assignment_wp ;
	   END IF ;

--
        get_absences_taken_to_date
          (p_assignment_id                  => p_assignment_id
          ,p_effective_date                 => l_generate_start_date
          ,p_business_group_id              => p_business_group_id -- LG
          ,p_pl_typ_id                      => p_pl_typ_id
          ,p_scheme_period_overlap_rule     => l_plan_information.absence_overlap_rule
          ,p_scheme_period_type             => l_plan_information.scheme_period_type
          ,p_scheme_period_duration         => l_plan_information.scheme_period_duration
          ,p_scheme_period_uom              => l_plan_information.scheme_period_uom
          ,p_scheme_period_start            => l_plan_information.scheme_period_start
          ,p_entitlements                   => l_entitlements
          ,p_absences_taken_to_date         => l_absences_taken_to_date
          ,p_override_scheme_start_date     => l_override_scheme_start_date
          ,p_plan_types_to_extend_period    => l_plan_information.plan_types_to_extend_period
          ,p_entitlement_uom                => l_plan_information.absence_days_type
          ,p_default_wp                     => l_plan_information.default_work_pattern_name
          ,p_absence_schedule_wp            => l_plan_information.absence_schedule_work_pattern
          ,p_track_part_timers              => l_plan_information.track_part_timers
          ,p_absence_start_date             => p_absence_date_start
	  );

        l_proc_step := 100;
      IF g_debug THEN
        debug(l_proc_name, 100);
        debug('l_absences_taken_to_date.COUNT');
        debug(l_absences_taken_to_date.COUNT);
      END IF;

   -- l_entitlements_remaining := l_entitlements - l_absences_taken_to_date

      --l_error_code:=
        get_entitlements_remaining
          (p_assignment_id          => p_assignment_id       --LG/PT
          ,p_effective_date         => l_generate_start_date --LG/PT
          ,p_entitlements           => l_entitlements
          ,p_absences_taken_to_date => l_absences_taken_to_date
          ,p_entitlement_UOM        => l_plan_information.absence_days_type
          ,p_entitlements_remaining => l_entitlements_remaining
	  ,p_is_full_timer          => l_is_full_timer
	  );

--
-- Summarize status at this point
-- 1. we have the entitlements of each band relevant to the LOS in:
--    l_entitlements
-- 2. we have the entitlements remaining for each relevant band in:
--    l_entitlements_remaining
--
-- 3a) we now need to process the current absence day by day
--    and generate daily absence information. this information
--    will be returned in a plsql table l_daily_absences
--
--

    l_entitlement_UOM := l_plan_information.absence_days_type ;

    END IF ;


       l_proc_step := 110;
     IF g_debug THEN
       debug(l_proc_name, 110);
     END IF;

--------------------------
   END IF ; -- end of 'UNPAID' check


     -- dont pass ent UOM directly from plan.get them into local variables and pass down

     generate_daily_absences
       (p_assignment_id                 => p_assignment_id
       ,p_business_group_id             => p_business_group_id
       ,p_absence_attendance_id         => p_absence_id
       ,p_default_work_pattern_name     => NVL(l_FT_working_wp
                                           ,l_plan_information.default_work_pattern_name)
       ,p_calendar_user_table_id        => l_plan_information.entitlement_calendar_UDT_id
       ,p_calendar_rules_list           => l_plan_information.calendar_rule_names_list
       ,p_generate_start_date           => l_generate_start_date
       ,p_generate_end_date             => l_generate_end_date
       ,p_absence_start_date            => p_absence_date_start
       ,p_absence_end_date              => p_absence_date_end
       ,p_entitlement_UOM               => l_entitlement_UOM
       ,p_payment_UOM                   => l_plan_information.daily_rate_UOM
       ,p_output_type                   => p_output_type
       ,p_entitlements_remaining        => l_entitlements_remaining
       ,p_daily_absences                => l_daily_absences
       ,p_error_code                    => l_error_code
       ,p_message                       => l_error_message
       ,p_working_days_per_week         =>l_working_days_per_week
       ,p_fte                           => l_fte
       ,p_override_work_pattern         => l_override_wp
       ,p_pl_id                         => p_pl_id
       ,p_scheme_period_type            => l_plan_information.scheme_period_type
       ,p_is_assignment_wp              => l_is_assignment_wp
       );

    IF g_debug THEN
      l_proc_step := 120;
      debug(l_proc_name, 120);
    END IF;
--
-- 3b) write to the cache (plsql table) to the datbase using bulk insert.
--

    -- write the parent PQP_GAP_ABSENCE_PLANS row
    -- check first if it exists, as this create may
    -- have been called from an update. its actualy ineffecient
    -- to do this again as the update code has allready gap absence plans
    -- in that case gap_absence_plan_id should be a parameter

    OPEN csr_gap_absence_plan(p_absence_id, p_pl_id);
    FETCH csr_gap_absence_plan INTO l_gap_absence_plan;
    CLOSE csr_gap_absence_plan;

      l_proc_step := 130;
    IF g_debug THEN
      debug(l_proc_name, 130);
    END IF;

    IF l_gap_absence_plan.gap_absence_plan_id IS NULL
    THEN

        l_proc_step := 135;
      IF g_debug THEN
        debug(l_proc_name, 135);
      END IF;

      pqp_gap_ins.ins
        (p_effective_date              => l_daily_absences(l_daily_absences.LAST).absence_date
        ,p_assignment_id               => p_assignment_id
        ,p_absence_attendance_id       => p_absence_id
        ,p_pl_id                       => p_pl_id
        ,p_last_gap_daily_absence_date => l_daily_absences(l_daily_absences.LAST).absence_date
        ,p_gap_absence_plan_id         => l_gap_absence_plan.gap_absence_plan_id
        ,p_object_version_number       => l_gap_absence_plan.object_version_number
        );
        l_update_summary := FALSE ;
     ELSE

         l_proc_step := 137;
       IF g_debug THEN
         debug(l_proc_name, 137);
       END IF;

      pqp_gap_upd.upd
        (p_effective_date              => l_daily_absences(l_daily_absences.LAST).absence_date
        ,p_gap_absence_plan_id         => l_gap_absence_plan.gap_absence_plan_id
        ,p_object_version_number       => l_gap_absence_plan.object_version_number
        ,p_assignment_id               => p_assignment_id
        ,p_absence_attendance_id       => p_absence_id
        ,p_pl_id                       => p_pl_id
        ,p_last_gap_daily_absence_date => l_daily_absences(l_daily_absences.LAST).absence_date
        );
        l_update_summary := TRUE ;
     END IF; -- IF l_gap_absence_plan.gap_absence_plan_id IS NULL

    -- write the child PQP_GAP_DAILY_ABSENCES row
      l_proc_step := 140;
    IF g_debug THEN
      debug(l_proc_name, 140);
    END IF;

    write_daily_absences
      (p_daily_absences => l_daily_absences
      ,p_gap_absence_plan_id => l_gap_absence_plan.gap_absence_plan_id
      -- ideally we wouldn't need to pass anything to this procedure
      -- other than the cache that needs to written. However since
      -- the cache does not hold a gap_absence_plan_id we need to
      -- populate it in the cache before calling the bulk bind process.
      -- Since we have to loop through the cache once before to split
      -- it out into seperate scalar plsql tables we use the same loop
      -- to populate all the entries in the cache with these absence plan
      -- ids, hence an additional p_gap_absence_plan_id
      );
--    We feed the summary data for reporting purposes to fill in the
--    summary and balance tables

--Summary Table Changes Feed in to balance table
   IF g_log_duration_summary = 'ENABLE' THEN

      IF g_debug THEN
         debug(l_proc_name, 145);
      END IF;

      write_absence_summary
        (P_GAP_ABSENCE_PLAN_ID           => l_gap_absence_plan.gap_absence_plan_id
        ,P_ASSIGNMENT_ID                 => p_assignment_id
        ,P_ENTITLEMENT_GRANTED           => l_entitlements
        ,P_ENTITLEMENT_USED_TO_DATE      => l_absences_taken_to_date
        ,P_ENTITLEMENT_REMAINING         => l_entitlements_remaining
        ,P_FTE                           => l_fte
        ,P_WORKING_DAYS_PER_WEEK         => l_working_days_per_week
        ,P_ENTITLEMENT_UOM               => l_plan_information.absence_days_type
        ,p_update                        => l_update_summary
        );
  END IF;
--Summary Table Changes
  END IF; -- if chk_record does not exist

  IF g_debug THEN
    debug_exit(l_proc_name);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
--      p_message       := SQLERRM;
--      p_error_code    := -1;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END create_absence_plan_details;
--

FUNCTION get_contract_level_wp (p_business_group_id IN NUMBER
                               ,p_assignment_id     IN NUMBER
                               ,p_effective_date    IN DATE )
    RETURN VARCHAR2 IS
    l_proc_step  NUMBER(20,10);
    l_proc_name  VARCHAR2(61):= g_package_name||'get_contract_level_wp';

    CURSOR csr_get_contract_type(
                    p_business_group_id NUMBER
                   ,p_assignment_id     NUMBER
		   ,p_effective_date    DATE ) IS
    SELECT contract_type
      FROM pqp_assignment_attributes_f
     WHERE business_group_id = p_business_group_id
       AND assignment_id = p_assignment_id
       AND p_effective_date BETWEEN effective_start_date
                        AND effective_end_date ;
    l_contract_type pqp_assignment_attributes_f.contract_type%TYPE ;
    l_contract_level_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_error_code  NUMBER ;
    l_error_message fnd_new_messages.message_text%TYPE ;


BEGIN

    g_debug := hr_utility.debug_enabled;

       l_proc_Step := 10 ;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_business_group_id);
      debug(p_assignment_id);
      debug(p_effective_date);
    END IF ;

      OPEN csr_get_contract_type(
                   p_business_group_id => p_business_group_id
		   ,p_assignment_id    => p_assignment_id
		   ,p_effective_date   => p_effective_date ) ;
      FETCH csr_get_contract_type INTO l_contract_type ;
      CLOSE csr_get_contract_type ;

       l_proc_Step := 20 ;
       IF g_debug THEN
          debug(' Contract type:'||l_contract_type);
       END IF ;

       IF l_contract_type IS NOT NULL THEN

          l_error_code :=
               pqp_utilities.pqp_gb_get_table_value
	          ( p_business_group_id => p_business_group_id
                   ,p_effective_date    => p_effective_date
                   ,p_table_name        => 'PQP_CONTRACT_TYPES'
                   ,p_column_name       => 'Full Time Work Pattern'
                   ,p_row_name          => l_contract_type
                   ,p_value             => l_contract_level_wp
                   ,p_error_msg         => l_error_message
	          ) ;
         l_proc_Step := 30 ;
         IF g_debug THEN
            debug(' Contract Level WP:'||l_contract_level_wp);
         END IF ;

       END IF ;

       IF g_debug THEN
         debug_exit(l_proc_name);
       END IF ;

       RETURN l_contract_level_wp ;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_contract_level_wp ;




FUNCTION get_absence_standard_ft_wp(p_business_group_id   IN  NUMBER
                                     ,p_assignment_id       IN  NUMBER
				     ,p_effective_date      IN  DATE
                                     ,p_absence_schedule_wp IN  VARCHAR2
                                     ,p_default_wp          IN  VARCHAR2
				     ,p_entitlement_uom     IN  VARCHAR2
                                     ,p_contract_wp         OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
   l_proc_step  NUMBER(20,10);
   l_proc_name  VARCHAR2(61):= g_package_name||'get_absence_standard_ft_wp';
   l_standard_ft_work_pattern pqp_assignment_attributes_f.work_pattern%TYPE ;

BEGIN

    g_debug := hr_utility.debug_enabled;

    l_proc_step := 10 ;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_business_group_id);
      debug(p_assignment_id);
      debug(p_effective_date);
      debug(p_absence_schedule_wp);
      debug(p_default_wp);
    END IF ;

    IF p_absence_schedule_wp IS NOT NULL THEN
       l_proc_step := 20 ;
       l_standard_ft_work_pattern := p_absence_schedule_wp ;
    ELSIF p_default_wp IS NOT NULL THEN
       l_proc_step := 30 ;
       l_standard_ft_work_pattern := p_default_wp ;
    ELSE
       l_proc_step := 40 ;
       l_standard_ft_work_pattern :=
                 get_contract_level_wp (
		       p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
		      ,p_effective_date    => p_effective_date ) ;

       p_contract_wp := l_standard_ft_work_pattern ;

    END IF ;

   IF l_standard_ft_work_pattern IS NULL THEN
        IF p_entitlement_uom <> 'H' THEN
         l_standard_ft_work_pattern := 'PQP_MON_FRI_8_HOURS';
       ELSE
        -- Raise Error.
        hr_utility.set_message(8303, 'PQP_230000_INVALID_WORK_PAT');
        hr_utility.raise_error ;
       END IF ;
    END IF ;

       l_proc_step := 50 ;
       IF g_debug THEN
         debug('l_standard_ft_work_pattern:'||l_standard_ft_work_pattern);
	 debug_exit(l_proc_name);
       END IF ;

    RETURN l_standard_ft_work_pattern ;

EXCEPTION
  WHEN OTHERS THEN
    p_contract_wp := NULL ;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_absence_standard_ft_wp ;


-- Move to pqp_schedule_calc_pkg and llok at caching options at a correct level
FUNCTION get_average_days_per_week(
                       p_business_group_id IN NUMBER
		      ,p_effective_date    IN DATE
		      ,p_work_pattern      IN VARCHAR2 )
RETURN NUMBER IS
   l_proc_step  NUMBER(20,10);
   l_proc_name  VARCHAR2(61):= g_package_name||'get_average_days_per_week';
   l_standard_ft_work_pattern pqp_assignment_attributes_f.work_pattern%TYPE ;
   l_average_days_per_week NUMBER ;
BEGIN

    g_debug := hr_utility.debug_enabled;

    l_proc_step := 10 ;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_business_group_id);
      debug(p_effective_date);
      debug(p_work_pattern);
    END IF ;

-- cache this results at this level.
-- do we need to consider effective_Date for caching.
-- if we, lets say the standard work pattern is same for most of the employees
-- but as effective date will vary ( its absence start date ),
-- the caching may not be effective....

    l_average_days_per_week :=
        pqp_schedule_calculation_pkg.get_working_days_in_week (
           p_assignment_id     => NULL
          ,p_business_group_id => p_business_group_id
          ,p_effective_date    => p_effective_date
          ,p_override_wp       => p_work_pattern
          ) ;

     IF l_average_days_per_week <= 0 THEN
        fnd_message.set_name( 'PQP', 'PQP_23000_INV_WORK_PATTERN' );
        fnd_message.raise_error ;
     END IF ;

     IF g_debug THEN
        debug('l_average_days_per_week:'||l_average_days_per_week);
        debug_exit(l_proc_name);
     END IF ;

     RETURN l_average_days_per_week ;


EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_average_days_per_week ;



FUNCTION get_assignment_work_pattern (p_business_group_id IN  NUMBER
                                     ,p_assignment_id     IN  NUMBER
				     ,p_effective_date    IN  DATE
                                     ,p_default_wp        IN  VARCHAR2
                                     ,p_contract_wp       IN VARCHAR2
 				     ,p_is_assignment_wp  OUT NOCOPY BOOLEAN)
RETURN VARCHAR2 IS
   l_proc_step  NUMBER(20,10);
   l_proc_name  VARCHAR2(61):= g_package_name||'get_assignment_work_pattern';
   l_assignment_work_pattern pqp_assignment_attributes_f.work_pattern%TYPE ;


BEGIN

    g_debug := hr_utility.debug_enabled;

    l_proc_step := 10 ;
    IF g_debug THEN
      debug_enter(l_proc_name);
      debug(p_business_group_id);
      debug(p_assignment_id);
      debug(p_effective_date);
      debug(p_default_wp);
      debug(p_contract_wp);
    END IF ;

    OPEN  csr_get_wp (p_business_group_id => p_business_group_id
                      ,p_assignment_id     => p_assignment_id
                      ,p_effective_date    => p_effective_date);
    FETCH csr_get_wp  INTO l_assignment_work_pattern ;
    CLOSE csr_get_wp ;

    IF l_assignment_work_pattern IS NULL
    THEN
        l_assignment_work_pattern := NVL(p_default_wp,p_contract_wp);
        p_is_assignment_wp := FALSE;
    ELSE
        p_is_assignment_wp := TRUE;
    END IF;

    IF g_debug THEN
      debug('l_assignment_work_pattern:'||l_assignment_work_pattern);
      debug_exit(l_proc_name);
    END IF ;

    RETURN l_assignment_work_pattern ;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_assignment_work_pattern ;


FUNCTION get_calendar_days_to_extend(
          p_period_start_date IN DATE
         ,p_period_end_date   IN DATE
	 ,p_assignment_id     IN NUMBER
	 ,p_business_group_id IN NUMBER
	 ,p_pl_typ_id         IN NUMBER
	 ,p_count_nopay_days  IN BOOLEAN
	 ,p_plan_types_lookup_type IN VARCHAR2
	 ) RETURN NUMBER IS
    l_tot_pay_days     NUMBER ;
    l_tot_no_pay_days NUMBER ;
    l_tot_no_pay_days_extend NUMBER ;
    l_person_id  NUMBER;
    l_proc_name  VARCHAR2(61) := g_package_name||'get_calendar_days_to_extend';
    l_proc_step  NUMBER(20,10) ;


-- the comment below was applicable till 115.70..
		-- This cursor gets the NOPAID days only
		-- for Civil Service Scheme, as in 4 years
		-- for the current primary assignmeng.
		-- This is the defaulty functionality


-- Changes done for 115.71 correspond to 7585452
	-- now this cursor is getting total paid absences taken for the plan that are to be included in extension rule
	-- wherever the query is changed the comment is wriiten accordingly.
CURSOR csr_css_no_pay_days IS
  select NVL(SUM(gda.duration),0)
  from  pqp_gap_daily_absences gda
       ,pqp_gap_absence_plans gap
       ,ben_pl_f pl
        ,hr_lookups hrl					 --added extra 7585452
  where pl.pl_id = gap.pl_id
    and pl.pl_typ_id = p_pl_typ_id
    and gap.gap_absence_plan_id = gda.gap_absence_plan_id
    and gap.assignment_id = p_assignment_id
    and gda.level_of_pay like 'BAND%'			 --changed from NOBAND to BAND% 7585452
     and hrl.lookup_code=pl.pl_typ_id			--added extra 7585452
     and hrl.lookup_type=p_plan_types_lookup_type	--added extra 7585452
    and gda.absence_date between p_period_start_date
                           and   (p_period_end_date - 1); -- bug 7110645

  --

-- the comment below was applicable till 115.70..

	 -- This cursor gets all the NOPAID Days
	 -- for the civil service scheme , as in 4 years
	 -- for all the primary assignments' absences
	 -- in the current period of service

-- Changes done for 115.71 correspond to 7585452
	-- now this cursor is getting total paid absences taken for the plan that are to be included in extension rule
	-- wherever the query is changed the comment is wriiten accordingly.

 CURSOR csr_css_no_pay_curpos IS
  select NVL(SUM(gda.duration),0)
  from  pqp_gap_daily_absences gda
       ,pqp_gap_absence_plans gap
       ,ben_pl_f pl
         ,hr_lookups hrl			--added extra 7585452
  where  gap.assignment_id  IN
      -- automatically makes the assignment list distinct
         (SELECT   other_asg.assignment_id
            FROM   per_all_assignments_f this_asg
                  ,per_all_assignments_f other_asg
           WHERE  this_asg.assignment_id = p_assignment_id
             AND  other_asg.person_id = this_asg.person_id
             AND  other_asg.primary_flag = 'Y'
             AND  other_asg.period_of_service_id = this_asg.period_of_service_id
             )
    and pl.pl_id = gap.pl_id
    and pl.pl_typ_id = p_pl_typ_id
    and gap.gap_absence_plan_id = gda.gap_absence_plan_id
    and gda.level_of_pay like 'BAND%'			--changed from NOBAND to BAND% 7585452
    and hrl.lookup_code=pl.pl_typ_id			--added extra 7585452
    and hrl.lookup_type=p_plan_types_lookup_type	 --added extra 7585452
    and gda.absence_date between p_period_start_date
                           and   (p_period_end_date - 1) ; -- bug 7110645


 --



-- the comment below was applicable till 115.70..
	 -- This cursor gets all the NOPAID Days
	 -- for the civil service scheme , as in 4 years
	 -- for all the primary assignments' absences
	 -- in all the period of service for the person

-- Changes done for 115.71 correspond to 7585452
	-- now this cursor is getting total paid absences taken for the plan that are to be included in extension rule
	-- wherever the query is changed the comment is written accordingly.

  CURSOR csr_css_no_pay_allpos(p_person_id IN NUMBER) IS
    select NVL(SUM(gda.duration),0)
      from  pqp_gap_daily_absences gda
           ,pqp_gap_absence_plans gap
           ,ben_pl_f pl
	     ,hr_lookups hrl				--added extra 7585452
     where gap.assignment_id  IN
      -- automatically makes the assignment list distinct
      (SELECT asg.assignment_id
         FROM per_all_assignments_f asg
         WHERE asg.person_id = p_person_id
           AND asg.primary_flag = 'Y'
        )

    and pl.pl_id = gap.pl_id
    and pl.pl_typ_id = p_pl_typ_id
    and gap.gap_absence_plan_id = gda.gap_absence_plan_id
    and gda.level_of_pay like 'BAND%'			--changed from NOBAND to BAND% 7585452
    and hrl.lookup_code=pl.pl_typ_id			--added extra 7585452
    and hrl.lookup_type=p_plan_types_lookup_type	--added extra 7585452
    and gda.absence_date between p_period_start_date
                           and   (p_period_end_date - 1);  -- bug 7110645


  l_pl_typ_id ben_pl_f.pl_typ_id%TYPE ;
BEGIN

 g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_period_start_date:'||p_period_start_date);
    debug('p_period_end_date:'||p_period_end_date);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_pl_typ_id:'||p_pl_typ_id);
    debug('p_plan_types_lookup_type:'||p_plan_types_lookup_type);
   END IF;

-- the number of days to be extended are returned by this function
-- for both 4-year and 1-year we have to roll back by all paid absences
-- and nopiad absences of absences other than CS.
-- only exception being for 1-year we have to extend even the NOPAID days
-- of CS.
-- So assume that the plan types are stored for all the absence categories
-- that needs to be considered in extending in a lookup
-- PQP_GAP_PLAN_TYPES_TO_EXTEND. This is required as there is no UI option
-- yet to support the selection of such plan types.
-- if it is for 4-year return the sum of those plan types absences
-- if for 1-year include even the CS NOPAID days and return.

   l_proc_step := 10 ;

   OPEN csr_get_days_to_extend (
             p_business_group_id => p_business_group_id
            ,p_assignment_id     => p_assignment_id
            ,p_period_start_date => p_period_start_date
            ,p_period_end_date   => p_period_end_date
            ,p_lookup_type       => p_plan_types_lookup_type --'PQP_GAP_PLAN_TYPES_TO_EXTEND'
	    ) ;
   FETCH csr_get_days_to_extend INTO l_tot_pay_days ;
   CLOSE csr_get_days_to_extend ;
   l_tot_no_pay_days := NVL(l_tot_pay_days,0);
   l_proc_step := 20 ;
   -- p_dont_chk_pl_typ_id should have FALSE for 1-year rolling period
   -- and TRUE for 4-year rolling period
   IF p_count_nopay_days THEN

      l_proc_step := 30 ;
      IF g_debug THEN
        debug(l_proc_name,l_proc_step);
	debug('g_deduct_absence_for'||g_deduct_absence_for);
      END IF;

      -- find out the option chosen for Deduct Absence Taken For
      -- from the global and open the appropriate cursor

      IF (g_deduct_absence_for = 'PRIMASGCURPOS') THEN
        OPEN csr_css_no_pay_curpos ;
        FETCH csr_css_no_pay_curpos INTO l_tot_no_pay_days_extend ;
        CLOSE csr_css_no_pay_curpos ;
      ELSIF (g_deduct_absence_for = 'PRIMASGALLPOS') THEN
        SELECT asg.person_id
          INTO   l_person_id
          FROM   per_all_assignments_f asg
         WHERE  asg.assignment_id = p_assignment_id
         AND ROWNUM < 2;
        IF g_debug THEN
	   debug('l_person_id:' ,l_person_id);
        END IF;
        OPEN csr_css_no_pay_allpos(p_person_id => l_person_id) ;
        FETCH csr_css_no_pay_allpos INTO l_tot_no_pay_days_extend ;
        CLOSE csr_css_no_pay_allpos ;
      ELSE
        OPEN csr_css_no_pay_days ;
        FETCH csr_css_no_pay_days INTO l_tot_no_pay_days_extend ;
        CLOSE csr_css_no_pay_days ;
      END IF;
        debug(to_char(l_tot_no_pay_days)||'-vaibhav-'||to_char(l_tot_no_pay_days_extend));

--changed for 7585452 Please note variable understanding may be wrong here by their names.
-- So new meaning of variables as follows...
	--l_tot_no_pay_days_extend   -- it is now paid days taken for under the plan type that should be considered for extension rule.
					   -- initial it was total no_pay taken (all without constraint of particulatr plan type like extension rule etc.)
	--l_tot_no_pay_days          --same as before
	--l_tot_no_pay_days         --same as before

      l_tot_no_pay_days := l_tot_no_pay_days - NVL(l_tot_no_pay_days_extend,0)  ;

--initially it was..(till 115.70)
	-- l_tot_no_pay_days := NVL(l_tot_no_pay_days_extend,0) + l_tot_no_pay_days ;

      l_proc_step := 40 ;
      IF g_debug THEN
        debug('4-Year Rolling Period no pay days:'||l_tot_no_pay_days);
      ENd IF;
   END IF;

    IF g_debug THEN
      debug('No Pay Days:'||l_tot_no_pay_days);
      debug_exit(l_proc_name) ;
    END IF ;

   RETURN NVL(l_tot_no_pay_days,0) ;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_calendar_days_to_extend;


PROCEDURE get_factors (
            p_business_group_id     IN NUMBER
	   ,p_effective_date        IN DATE
	   ,p_assignment_id         IN NUMBER
	   ,p_entitlement_uom       IN VARCHAR2
	   ,p_default_wp            IN VARCHAR2
	   ,p_absence_schedule_wp   IN VARCHAR2
	   ,p_track_part_timers     IN VARCHAR2
	   ,p_current_factor        OUT NOCOPY NUMBER
	   ,p_ft_factor             OUT NOCOPY NUMBER
	   ,p_working_days_per_week OUT NOCOPY NUMBER
	   ,p_fte                   OUT NOCOPY NUMBER
	   ,p_FT_absence_wp         OUT NOCOPY VARCHAR2
	   ,p_FT_working_wp         OUT NOCOPY VARCHAR2
	   ,p_assignment_wp         OUT NOCOPY VARCHAR2
	   ,p_is_full_timer         OUT NOCOPY BOOLEAN
  	   ,p_is_assignment_wp      OUT NOCOPY BOOLEAN
           ) IS
    l_proc_name  VARCHAR2(61) := g_package_name||'get_factors';
    l_proc_step  NUMBER(20,10) ;

    l_FT_absence_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_FT_working_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_contract_wp pqp_assignment_attributes_f.work_pattern%TYPE ;
    l_assignment_wp pqp_assignment_attributes_f.work_pattern%TYPE ;

    l_FT_working_dpw  NUMBER ;
    l_FT_absence_wp_dpw  NUMBER ;
    l_assignment_wp_dpw  NUMBER ;
    l_fte_value NUMBER ;
    l_current_factor NUMBER ;
    l_ft_factor      NUMBER ;
BEGIN

    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_effective_date:'||p_effective_date);
    debug('p_default_wp:'||p_default_wp);
    debug('p_absence_schedule_wp:'||p_absence_schedule_wp);
    debug('p_track_part_timers:'||p_track_part_timers);
   END IF;

     p_is_full_timer := FALSE ;

     IF p_entitlement_uom = 'H' THEN
        l_fte_value :=
                 pqp_fte_utilities.get_fte_value
                    (p_assignment_id    => p_assignment_id
                    ,p_calculation_date => p_effective_date ) ;
        l_fte_value := NVL(l_fte_value,1) ;
      END IF ;

--     ELSE  -- IF l_plan_information.absence_days_type IN ('C','W') THEN
    -- This information is available for Hours too as they have
    -- Work Pattern attached.
       l_FT_absence_wp :=
          get_absence_standard_ft_wp(
             p_business_group_id   => p_business_group_id
            ,p_assignment_id       => p_assignment_id
            ,p_effective_date      => p_effective_date
            ,p_absence_schedule_wp => p_absence_schedule_wp
            ,p_default_wp          => p_default_wp
            ,p_entitlement_uom     => p_entitlement_uom
            ,p_contract_wp         => l_contract_wp ) ;


      l_FT_working_wp := NVL(p_default_wp,l_contract_wp);

       l_assignment_wp :=
           get_assignment_work_pattern (
              p_business_group_id => p_business_group_id
             ,p_assignment_id     => p_assignment_id
             ,p_effective_date    => p_effective_date
             ,p_default_wp        => p_default_wp
             ,p_contract_wp       => l_contract_wp
             ,p_is_assignment_wp  => p_is_assignment_wp
	     );

       l_assignment_wp_dpw :=
           get_average_days_per_week(
                p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_work_pattern      => l_assignment_wp );

       l_FT_absence_wp_dpw :=
            get_average_days_per_week(
                p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_work_pattern      => l_FT_absence_wp );

	l_FT_working_dpw :=
            get_average_days_per_week(
                p_business_group_id => p_business_group_id
               ,p_effective_date    => p_effective_date
               ,p_work_pattern      => l_FT_working_wp );


	 IF g_debug THEN
          debug('l_assignment_wp_dpw:'||l_assignment_wp_dpw);
	  debug('l_FT_absence_wp_dpw:'||l_FT_absence_wp_dpw);
	  debug('l_FT_working_dpw:'||l_FT_working_dpw);

         END IF ;
--     END IF ; -- IF l_plan_information.absence_days_type IN ('C','W') THEN



-- decide whether a FT or PT
    IF l_assignment_wp_dpw >= l_FT_working_dpw THEN
       p_is_full_timer  := TRUE ;
       -- IF the employee is FT then the work pattern shud be
       l_FT_working_dpw := l_FT_absence_wp_dpw ;
       l_assignment_wp_dpw := l_FT_absence_wp_dpw ;
    END IF ;

          IF NVL(p_track_part_timers,'N') = 'Y' THEN

	     IF p_entitlement_UOM = 'H'--ours
	     THEN
                 l_current_factor := l_fte_value ;
                 l_ft_factor := 1 ;
             ELSE
               l_current_factor := l_assignment_wp_dpw ;
	       l_ft_factor := l_FT_absence_wp_dpw ;
	       l_fte_value:=l_current_factor/l_ft_factor;

             END IF; -- IF p_entitlement_UOM = 'H'ours

          ELSE -- i.e. not tracking Part Timers

	    IF p_entitlement_UOM = 'H'--ours
	    THEN
              l_current_factor := 1.0 ;
	      l_ft_factor := 1/l_fte_value ;
	    ELSE
              l_current_factor := 1.0 ;
	      l_ft_factor := 1.0 ;
            END IF; -- IF p_entitlement_UOM = 'H'ours

	  END IF ; -- tracking part timers check

     p_current_factor := l_current_factor ;
     p_ft_factor      := l_ft_factor ;
     p_fte		:=l_fte_value;
     p_working_days_per_week := l_assignment_wp_dpw ;
     p_assignment_wp  := l_assignment_wp ;
     p_FT_absence_wp  := l_FT_absence_wp ;
     p_FT_working_wp  := l_FT_working_wp ;

    IF g_debug THEN
     debug('p_current_factor:'||p_current_factor);
     debug('p_ft_factor:'||p_ft_factor);
     debug_exit(l_proc_name) ;
    END IF ;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END get_factors ;

PROCEDURE convert_entitlements
            ( p_entitlements   IN OUT NOCOPY pqp_absval_pkg.t_entitlements
	     ,p_current_factor IN NUMBER
             ,p_ft_factor      IN NUMBER
            ) IS
    l_proc_name  VARCHAR2(61) := g_package_name||'convert_entitlements';
    l_proc_step  NUMBER(20,10) ;
    l_entitlements_nc pqp_absval_pkg.t_entitlements ;
    i NUMBER ;

BEGIN
    g_debug := hr_utility.debug_enabled;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_current_factor:'||p_current_factor);
    debug('p_ft_factor:'||p_ft_factor);
   END IF;

    i := p_entitlements.FIRST ;

    WHILE i IS NOT NULL LOOP
      l_proc_step := 10 + i ;
      p_entitlements(i).entitlement := (p_entitlements(i).entitlement
                                     * p_current_factor)/p_ft_factor ;

     /*     IF p_current_factor>=p_ft_factor THEN
               p_entitlements(i).entitlement := pqp_utilities.round_value_up_down
	                     (
                              p_value_to_round => p_entitlements(i).entitlement
                             ,p_base_value     => 0.5
                             ,p_rounding_type  => 'UPPER'
                             ) ;
	   ELSE
               p_entitlements(i).entitlement := pqp_utilities.round_value_up_down
	                     (
                              p_value_to_round => p_entitlements(i).entitlement
                             ,p_base_value     => 0.5
                             ,p_rounding_type  => 'LOWER'
                             ) ;
	   END IF ;*/



      i := p_entitlements.NEXT(i) ;
   END LOOP ;

    IF g_debug THEN
     debug_exit(l_proc_name) ;
    END IF ;


EXCEPTION
WHEN OTHERS THEN
   p_entitlements := l_entitlements_nc ;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;
END convert_entitlements ;


END pqp_absval_pkg;

/
