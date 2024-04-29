--------------------------------------------------------
--  DDL for Package PQP_GB_OSP_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_OSP_FUNCTIONS" AUTHID CURRENT_USER AS
/* $Header: pqpospfn.pkh 120.8.12010000.3 2008/08/05 14:22:48 ubhat ship $ */
--
--    TYPE r_LOS_based_entitlements IS RECORD
--       (band           VARCHAR2(30)
--       ,meaning        VARCHAR2(80)
--       ,entitlement    NUMBER
--       );

--    TYPE t_LOS_based_entitlements IS TABLE OF r_LOS_based_entitlements
--    INDEX BY BINARY_INTEGER;

  g_end_of_time DATE:= hr_api.g_eot; -- required because perf parser doesnot like g_eot

  TYPE r_entitlement_parameters IS RECORD(
    band                          VARCHAR2(30)
   ,meaning                       VARCHAR2(80)
   ,entitlement                   NUMBER
   ,percentage                    NUMBER
   ,earnings_type                 VARCHAR2(80)
  );

  TYPE t_entitlement_parameters IS TABLE OF r_entitlement_parameters
    INDEX BY BINARY_INTEGER;

-- Cursor to get Lookup Code.
  CURSOR csr_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
  )
  IS
    SELECT lookup_code
    FROM   fnd_lookup_values_vl
    WHERE  lookup_type = p_lookup_type AND meaning = p_lookup_meaning;

-- Cursor to get absence id for a assignment id.
  CURSOR csr_absence_id(p_assignment_id IN NUMBER, p_effective_date IN DATE)
  IS
    SELECT absence_attendance_id
    FROM   per_all_assignments_f asg,
           ben_per_in_ler pil
          ,per_absence_attendances paa
    WHERE  asg.assignment_id = p_assignment_id
      AND  p_effective_date BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
      AND  pil.person_id = asg.person_id
      AND  pil.per_in_ler_stat_cd = 'STRTD'
      AND  paa.absence_attendance_id = pil.trgr_table_pk_id;

-- Cursor to get Medical Id for a given Absence Attendance Id.
  CURSOR csr_medical_id(p_absence_id IN NUMBER)
  IS
    SELECT medical_id
    FROM   ssp_medicals
    WHERE  absence_attendance_id = p_absence_id;

-- Cursor to get Maternity Id for a given Absence Attendance Id.
  CURSOR csr_maternity_id(p_absence_id IN NUMBER)
  IS
    SELECT maternity_id
    FROM   per_absence_attendances
    WHERE  absence_attendance_id = p_absence_id;

-- Cursor to get Absence Type for a Absence Id.
  CURSOR csr_abs_type(p_absence_attendance_id IN NUMBER)
  IS
    SELECT TYPE.NAME
    FROM   per_absence_attendances ABS, per_absence_attendance_types TYPE
    WHERE  ABS.absence_attendance_type_id = TYPE.absence_attendance_type_id
    AND    ABS.absence_attendance_id = p_absence_attendance_id;

-- Cursor to get absence Category for a Absence Id.
  CURSOR csr_abs_cat(p_absence_attendance_id IN NUMBER)
  IS
    SELECT lkp.meaning
    FROM   per_absence_attendances ABS
          ,per_absence_attendance_types TYPE
          ,hr_lookups lkp
    WHERE  ABS.absence_attendance_type_id = TYPE.absence_attendance_type_id
    AND    TYPE.absence_category = lkp.lookup_code
    AND    lkp.lookup_type = 'ABSENCE_CATEGORY'
    AND    ABS.absence_attendance_id = p_absence_attendance_id;

-- Cursor to get Absence Reason for a Absence Id.
  CURSOR csr_abs_rea(p_absence_attendance_id IN NUMBER)
  IS
    SELECT lkp.meaning
    FROM   per_absence_attendances ABS
          ,per_abs_attendance_reasons rea
          ,hr_lookups lkp
    WHERE  ABS.abs_attendance_reason_id = rea.abs_attendance_reason_id
    AND    rea.NAME = lkp.lookup_code
    AND    lookup_type = 'ABSENCE_REASON'
    AND    ABS.absence_attendance_id = p_absence_attendance_id;

-- Cursor to get Element Type ID for Plan Table Functions.
  CURSOR csr_plan_element_type(
    p_pl_id                     IN       NUMBER
   ,p_information_type          IN       VARCHAR2
  )
  IS
    SELECT petei.element_type_id
    FROM   pay_element_type_extra_info petei, ben_pl_f bpl, ben_pl_typ_f bpty
    WHERE  UPPER(petei.eei_information19) = 'ABSENCE INFO'
    AND    petei.information_type = p_information_type
    --'PQP_GB_ABSENCE_PLAN_INFO'
    AND    bpl.pl_typ_id = bpty.pl_typ_id
    AND    bpty.opt_typ_cd = 'ABS'
    AND    petei.eei_information1 = fnd_number.number_to_canonical(bpl.pl_id)
    AND    bpl.pl_id = p_pl_id;

-- Cursor to get Plan Id from Plan Tables for a given Plan Name.
  CURSOR csr_plan_id(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
  )
  IS
    SELECT bpl.pl_id
    FROM   ben_pl_f bpl, ben_pl_typ_f bpty
    WHERE  bpl.pl_typ_id = bpty.pl_typ_id
    AND    bpty.opt_typ_cd = 'ABS'
    AND    bpl.business_group_id = p_business_group_id
    AND    p_effective_date BETWEEN bpl.effective_start_date
                                AND bpl.effective_end_date
    AND    bpl.NAME = p_pl_name;

-- Cursor For Calendar Occurances

  CURSOR csr_cal_occur(
    p_date                      IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_calendar_rules_list       IN       VARCHAR2
   ,p_filter_value              IN       VARCHAR2
   ,p_filter                    IN       VARCHAR2
  )
  IS
    SELECT   pur.row_low_range_or_name
            ,cols.user_column_name
            ,inst.VALUE
    FROM     pay_user_columns cols
            ,pay_user_rows_f pur
            ,pay_user_column_instances_f inst
            ,hr_lookups lookup
    WHERE    cols.user_table_id = p_table_id
    AND      pur.user_table_id = cols.user_table_id
    AND      pur.user_row_id = inst.user_row_id
    AND      cols.user_column_id = inst.user_column_id
    AND      lookup.lookup_type = p_calendar_rules_list
    AND      cols.user_column_name = lookup.meaning
    -- check that the day is marked in the calendar, ie a column instance is
    -- effective on that day
    AND      p_date BETWEEN inst.effective_start_date
                        AND DECODE(
                             inst.effective_end_date
                            -- if the eff end date is the End of Time then
                            -- DECODE it to eff start date such that the column
                            -- instance is treated as effective for only one
                            -- day, ie the start date. e.g.
                            -- a row effective from 01-01-2001 to 31-12-4712
                            -- may represent a holiday of only 01-01-2001
                           , g_end_of_time, inst.effective_start_date
                            -- else this column instance represents a range of
                            -- days (date range) marked in the calendar
                            -- eg a row effective from 01-01-2001 to 14-01-2001
                            -- may represent a 2 week period as a holiday
                           , inst.effective_end_date
                           -- effective end date will never be NULL
                           )
    AND      (
                 (
                      p_filter_value IS NULL
                  AND (
                          (p_filter = 'ALLMATCH'--AND
                                                --(inst.value IS NULL OR inst.value IS NOT NULL)  --redundant
                          )
                       OR (p_filter = 'EXACTMATCH' AND inst.VALUE IS NULL)
                       OR (p_filter = 'EXCEPT' AND inst.VALUE IS NOT NULL)
                       OR (p_filter = 'ALLEXCEPT' AND inst.VALUE IS NOT NULL)
                      ) -- AND p_filter_value IS NULL
                 ) -- OR p_filter_value IS NULL
              OR (
                      p_filter_value IS NOT NULL
                  AND (
                          (
                               p_filter = 'ALLMATCH'
                           AND (
                                   inst.VALUE IS NULL
                                OR inst.VALUE = p_filter_value
                               )
                          )
                       OR (
                               p_filter = 'EXACTMATCH'
                           AND (  --inst.value IS NOT NULL --redundant as the Equality check
                                 --AND
                                inst.VALUE =
                                  p_filter_value --exlcudes NULLs automatically
                               )
                          )
                       OR (
                               p_filter = 'ALLEXCEPT'
                           AND (
                                   inst.VALUE IS NULL
                                OR inst.VALUE <> p_filter_value
                               )
                          )
                       OR (
                               p_filter = 'EXCEPT'
                           AND (  --inst.value IS NOT NULL --redundant as the INequality check
                                 --AND
                                inst.VALUE <>
                                  p_filter_value --exlcudes NULLs automatically
                               )
                          )
                      ) -- AND p_filter_value IS NOT NULL
                 ) -- OR p_filter_value IS NULL or NOT
             ) -- AND in the main WHERE
    ORDER BY lookup.lookup_code;

--  CURSOR c_wp_dets(p_assignment_id NUMBER, p_start_date DATE, p_end_date DATE)
--  IS
--    SELECT   *
--    FROM     pqp_assignment_attributes_f
--    WHERE    assignment_id = p_assignment_id
--    AND      (
--                 (
--                  p_start_date BETWEEN effective_start_date AND effective_end_date
--                 )
--              OR (
--                  p_end_date BETWEEN effective_start_date AND effective_end_date
--                 )
--              OR (effective_start_date BETWEEN p_start_date AND p_end_date)
--              OR (effective_end_date BETWEEN p_start_date AND p_end_date)
--             )
--    ORDER BY effective_start_date;

--  CURSOR c_wp_dets_up(p_assignment_id NUMBER, p_start_date DATE)
--  IS
--    SELECT   *
--    FROM     pqp_assignment_attributes_f
--    WHERE    assignment_id = p_assignment_id
--    AND      (
--                 (
--                  p_start_date BETWEEN effective_start_date AND effective_end_date
--                 )
--              OR (effective_start_date > p_start_date)
--             )
--    ORDER BY effective_start_date;

-- Cursor to get Number of Holidays in absence Period for a given UDT Id.
-- Default is the Default Column that will be seeded in the UDT
-- through Template.
  CURSOR csr_get_hol_abs(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
  IS
    SELECT SUM(
               DECODE(
                 SIGN(effective_end_date - p_abs_end_date)
                ,1, p_abs_end_date
                ,effective_end_date
               )
             - DECODE(
                 SIGN(effective_start_date - p_abs_start_date)
                ,-1, p_abs_start_date
                ,effective_start_date
               )
             + 1
           ) cnt
    FROM   pay_user_column_instances_f inst, pay_user_columns col
    WHERE  col.user_table_id = p_table_id
    AND    inst.user_column_id = col.user_column_id
    AND    col.user_column_name LIKE p_column_name
    AND    (   p_value IS NULL
            OR inst.VALUE = p_value)
    AND    (
               (
                p_abs_start_date BETWEEN inst.effective_start_date
                                     AND inst.effective_end_date
               )
            OR (
                inst.effective_start_date BETWEEN p_abs_start_date
                                              AND p_abs_end_date
               )
            OR (
                p_abs_end_date BETWEEN inst.effective_start_date
                                   AND inst.effective_end_date
               )
            OR (
                inst.effective_end_date BETWEEN p_abs_start_date
                                            AND p_abs_end_date
               )
           )
    AND    inst.business_group_id = p_business_group_id;

-- Cursor to check a date is declared as holiday or not.
  CURSOR csr_get_work_hol(
    p_business_group_id         IN       NUMBER
   ,p_abs_date                  IN       DATE
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
  IS
    SELECT inst.VALUE
    FROM   pay_user_columns col, pay_user_column_instances_f inst
    WHERE  col.user_table_id = p_table_id
    AND    col.user_column_name LIKE p_column_name
    AND    inst.user_column_id = col.user_column_id
    AND    ( p_value IS NULL OR inst.VALUE = p_value )
    AND    p_abs_date BETWEEN inst.effective_start_date
                          AND inst.effective_end_date
    AND    inst.business_group_id = p_business_group_id;

-- Cursor to get Entitlement Days. This cursor returns the number of days the
-- entitlement is like BAND1, BAND2, EXCLUDED etc. This type qualifier is a
-- parameter to the cursor.
  CURSOR csr_entitled_days(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
  )
  IS
    SELECT NVL(SUM(daily.DURATION), 0) days
          ,NVL(SUM(daily.duration_in_hours),0) hours
    FROM   per_absence_attendances attnd
          ,pqp_gap_absence_plans plans
          ,pqp_gap_daily_absences daily
    WHERE  attnd.absence_attendance_id = plans.absence_attendance_id
    AND    plans.gap_absence_plan_id = daily.gap_absence_plan_id
    AND    attnd.absence_attendance_id = p_absence_attendance_id
    AND    plans.pl_id = p_pl_id
    AND    (
               UPPER(daily.level_of_entitlement) = p_level_of_entitlement
            OR p_level_of_entitlement IS NULL
           )
    AND    daily.absence_date BETWEEN GREATEST(
                                       NVL(p_search_start_date
                                        ,attnd.date_start)
                                      ,attnd.date_start
                                     )
                                  AND LEAST(
                                       NVL(p_search_end_date, g_end_of_time)
                                      ,g_end_of_time
                                     );

-- Cursor to get Paid Days. This cursor returns the number of days the
-- absence can be paid like BAND1, BAND2, EXCLUDED etc. This type qualifier
-- is a parameter to the cursor.
  CURSOR csr_paid_days(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_level_of_pay              IN       VARCHAR2
  )
  IS
SELECT NVL(SUM(daily.duration),0) days
-----Added For Hours
      ,NVL(SUM(daily.duration_in_hours),0) hours
    FROM   per_absence_attendances attnd
          ,pqp_gap_absence_plans plans
          ,pqp_gap_daily_absences daily
    WHERE  attnd.absence_attendance_id = plans.absence_attendance_id
    AND    plans.gap_absence_plan_id = daily.gap_absence_plan_id
    AND    attnd.absence_attendance_id = p_absence_attendance_id
    AND    plans.pl_id = p_pl_id
    AND    (   UPPER(daily.level_of_pay) = p_level_of_pay
            OR p_level_of_pay IS NULL)
    AND    daily.absence_date BETWEEN GREATEST(
                                       NVL(p_search_start_date
                                        ,attnd.date_start)
                                      ,attnd.date_start
                                     )
                                  AND LEAST(
                                       NVL(p_search_end_date, g_end_of_time)
                                      ,g_end_of_time
                                     );

-- Cursor to get Work_pattern Types of qualifier type.
  CURSOR csr_wp_days(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_work_pattern_day_type     IN       VARCHAR2
  )
  IS
    SELECT NVL(SUM(daily.DURATION), 0)
    FROM   per_absence_attendances attnd
          ,pqp_gap_absence_plans plans
          ,pqp_gap_daily_absences daily
    WHERE  attnd.absence_attendance_id = plans.absence_attendance_id
    AND    plans.gap_absence_plan_id = daily.gap_absence_plan_id
    AND    attnd.absence_attendance_id = p_absence_attendance_id
    AND    plans.pl_id = p_pl_id
    AND    (
               UPPER(daily.work_pattern_day_type) = p_work_pattern_day_type
            OR p_work_pattern_day_type IS NULL
           )
    AND    daily.absence_date BETWEEN GREATEST(
                                       NVL(p_search_start_date
                                        ,attnd.date_start)
                                      ,attnd.date_start
                                     )
                                  AND LEAST(
                                       NVL(p_search_end_date, g_end_of_time)
                                      ,g_end_of_time
                                     );

-- Cursor to get lookup code information from Lookup Type
  CURSOR csr_get_lookup_info(c_lookup_type VARCHAR2, c_lookup_code VARCHAR2)
  IS
    SELECT   meaning
            ,lookup_code
    FROM     hr_lookups
    WHERE    lookup_type = c_lookup_type
    AND      lookup_code LIKE c_lookup_code
    AND      enabled_flag = 'Y'
    ORDER BY lookup_code;

-- Cursor to get No of level of Paid Days for a date range.
  CURSOR csr_get_level_pay(
    p_assignment_id                      NUMBER
   ,p_business_group_id                  NUMBER
   ,p_search_start_date                  DATE
   ,p_search_end_date                    DATE
   ,p_level_of_pay                       VARCHAR2
  )
  IS
    SELECT NVL(SUM(pgda.DURATION), 0) balance
    FROM   pqp_gap_daily_absences pgda
          ,pqp_gap_absence_plans pgap
          ,per_absence_attendances paa
    WHERE  pgda.gap_absence_plan_id = pgap.gap_absence_plan_id
    AND    pgap.absence_attendance_id = paa.absence_attendance_id
    AND    pgda.absence_date BETWEEN p_search_start_date AND p_search_end_date
    AND    pgap.assignment_id = p_assignment_id
    AND    paa.business_group_id = p_business_group_id
    AND    pgda.level_of_pay = p_level_of_pay;

-- Cursor to get No of level of Entitlement Days for a date range.
  CURSOR csr_get_level_ent(
    p_assignment_id                      NUMBER
   ,p_business_group_id                  NUMBER
   ,p_search_start_date                  DATE
   ,p_search_end_date                    DATE
   ,p_level_of_ent                       VARCHAR2
  )
  IS
    SELECT NVL(SUM(pgda.DURATION), 0) balance
    FROM   pqp_gap_daily_absences pgda
          ,pqp_gap_absence_plans pgap
          ,per_absence_attendances paa
    WHERE  pgda.gap_absence_plan_id = pgap.gap_absence_plan_id
    AND    pgap.absence_attendance_id = paa.absence_attendance_id
    AND    pgda.absence_date BETWEEN p_search_start_date AND p_search_end_date
    AND    pgap.assignment_id = p_assignment_id
    AND    paa.business_group_id = p_business_group_id
    AND    pgda.level_of_entitlement = p_level_of_ent;

-- Cursor to get No of level of Work Pattern Days for a date range.
  CURSOR csr_get_wp_type_days(
    p_assignment_id                      NUMBER
   ,p_business_group_id                  NUMBER
   ,p_search_start_date                  DATE
   ,p_search_end_date                    DATE
   ,p_wp_day_type                        VARCHAR2
  )
  IS
    SELECT NVL(SUM(pgda.DURATION), 0) balance
    FROM   pqp_gap_daily_absences pgda
          ,pqp_gap_absence_plans pgap
          ,per_absence_attendances paa
    WHERE  pgda.gap_absence_plan_id = pgap.gap_absence_plan_id
    AND    pgap.absence_attendance_id = paa.absence_attendance_id
    AND    pgda.absence_date BETWEEN p_search_start_date AND p_search_end_date
    AND    pgap.assignment_id = p_assignment_id
    AND    paa.business_group_id = p_business_group_id
    AND    pgda.work_pattern_day_type = p_wp_day_type;

-- Cursor to get the FTE for a given assignment as of a given date.
CURSOR csr_get_asg_fte_value
  (p_assignment_id  IN NUMBER
  ,p_effective_date IN DATE
  ) IS

SELECT budget.value
FROM   per_assignment_budget_values_f budget
WHERE  budget.assignment_id = p_assignment_id
  AND  budget.unit = 'FTE'
  AND  p_effective_date
         BETWEEN budget.effective_start_date
             AND budget.effective_end_date;

-- SSP SMP Cursors Moved out from body in Aug 2003 release
--
-- Cursor to get the Qualifying Pattern Calendar Usage Exceptions
--
--CURSOR c_usage_exceptions
--  (p_pattern_id hr_patterns.pattern_id%TYPE
--  ) IS
--SELECT hpe.pattern_id
--      ,exception_name
--      ,exception_start_time exception_start_date
--      ,exception_end_time exception_end_date
--FROM   hr_calendars hc
--      ,hr_calendar_usages hcu
--      ,hr_exception_usages heu
--      ,hr_pattern_exceptions hpe
--WHERE  hc.pattern_id = p_pattern_id
--AND    hc.calendar_id = hcu.calendar_id
--AND    hcu.purpose_usage_id = 1
--AND    hcu.calendar_usage_id = heu.calendar_usage_id
--AND    heu.exception_id = hpe.exception_id;
--
-- Cursor to get the Qualifying Pattern Exceptions
--
--CURSOR c_pattern_exceptions
-- (p_pattern_id hr_patterns.pattern_id%TYPE
-- ) IS
--SELECT hpe.pattern_id
--      ,exception_name
--      ,exception_start_time exception_start_date
--      ,exception_end_time exception_end_date
--FROM   hr_calendars hc
--      ,hr_calendar_usages hcu
--      ,hr_exception_usages heu
--      ,hr_pattern_exceptions hpe
--WHERE  hc.pattern_id = p_pattern_id
--AND    purpose_usage_id = 1
--AND    hcu.calendar_id = hc.calendar_id
--AND    hc.calendar_id = heu.calendar_id
--AND    heu.exception_id = hpe.exception_id;
--
-- Define a table to holds the row returned from the above
-- cursor to store the exceptions for BG
--
--TYPE t_pat_exceptions IS TABLE OF c_pattern_exceptions%ROWTYPE
--   INDEX BY BINARY_INTEGER;
--
--CURSOR c_pattern
--  (p_pattern_id hr_patterns.pattern_id%TYPE
--  ) IS
--SELECT hp.pattern_id
--      ,pattern_name
--      ,pattern_start_weekday
--      ,pattern_start_time
--FROM   hr_patterns hp
--WHERE  hp.pattern_id = p_pattern_id;
--
-- Cursor to get the Qualifying pattern constructors
--
--  CURSOR c_pattern_cons
--    (p_pattern_id NUMBER
--    ) IS
--  SELECT   hpc.sequence_no seq_no
--          ,hpc.availability availability
--          ,hpb.pattern_bit_code time_unit
--          ,hpb.time_unit_multiplier time_unit_multiplier
--          ,hpb.base_time_unit base_time_unit
--  FROM     hr_patterns hrp
--          ,hr_pattern_constructions hpc
--          ,hr_pattern_bits hpb
--  WHERE    hrp.pattern_id = p_pattern_id
--    AND    hrp.pattern_id = hpc.pattern_id
--    AND    hpc.pattern_bit_id = hpb.pattern_bit_id
--  ORDER BY sequence_no;
--
---- Define a table based on rowtype of the above cursor
--TYPE pat_cons_t IS TABLE OF c_pattern_cons%ROWTYPE
--  INDEX BY BINARY_INTEGER;
  --
  -- Cursor to get the Pattern associated with a Person
  --
--  CURSOR c_per_pattern
--    (p_person_id per_all_assignments.person_id%TYPE
--    ) IS
--  SELECT pattern_id
--        ,start_date
--        ,end_date
--  FROM   hr_calendar_usages hcu, hr_calendars hc
--  WHERE  primary_key_value = p_person_id
--  AND    purpose_usage_id = 2
--  AND    hcu.calendar_id = hc.calendar_id;
--
-- Cursor gets Input value ids for the element passed as param
--
  CURSOR csr_inputvalue_ids
    (p_element_type_id IN NUMBER
    ,p_effective_date  IN DATE
    ) IS
  SELECT piv.display_sequence
        ,pet.element_type_id
        ,piv.input_value_id  id
  FROM   pay_element_types_f pet
        ,pay_input_values_f  piv
  WHERE  pet.element_type_id = p_element_type_id
    AND  p_effective_date
           BETWEEN pet.effective_start_date
               AND pet.effective_end_date
    AND  piv.element_type_id = pet.element_type_id
    AND  p_effective_date
           BETWEEN piv.effective_start_date
               AND piv.effective_end_date;

  -- Define a table to holds the row returned from the above cursor to store
  -- the input value Ids
  TYPE t_input_value_ids IS TABLE OF csr_inputvalue_ids%ROWTYPE
    INDEX BY BINARY_INTEGER;


  CURSOR csr_seeded_element_type -- cache -- context -- if not populated
    (p_element_name IN pay_element_types_f.element_name%TYPE
    ) IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = p_element_name
    AND  business_group_id IS NULL
    AND  legislation_code = 'GB'
    AND ROWNUM < 2; -- there can be more than effective row
                    -- since we are only interested in the surrogate id
                    -- ROWNUM < 2 will do
--
--
--
  CURSOR csr_element_links
    (p_element_type_id    IN        NUMBER
    ,p_business_group_id  IN        NUMBER
    ) IS
  SELECT ell.element_link_id id
  FROM   pay_element_links_f ell
  WHERE  ell.element_type_id = p_element_type_id
    AND  ell.business_group_id = p_business_group_id;

  TYPE t_element_links IS TABLE OF csr_element_links%ROWTYPE
    INDEX BY BINARY_INTEGER;
--
--
--
  CURSOR csr_ssp_entries
    (p_primary_assignment_id     IN       NUMBER
    ,p_element_link_id           IN       NUMBER
    ,p_piw_id                    IN       NUMBER
--    ,p_amount_iv_id              IN       NUMBER
--    ,p_date_from_iv_id           IN       NUMBER
--    ,p_date_to_iv_id             IN       NUMBER
--    ,p_rate_iv_id                IN       NUMBER
--    ,p_qualifying_days_iv_id     IN       NUMBER
--    ,p_ssp_days_due_iv_id        IN       NUMBER
--    ,p_withheld_days_iv_id       IN       NUMBER
--    ,p_ssp_weeks_iv_id           IN       NUMBER
    ) IS
  SELECT  ele.element_entry_id
         ,ele.effective_start_date
         ,ele.effective_end_date
         ,fnd_date.canonical_to_date('3712/12/31 00:00:00') Date_From
--         ,( SELECT fnd_date.canonical_to_date(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_date_from_iv_id
--          ) Date_From
         ,fnd_date.canonical_to_date('3712/12/31 00:00:00') Date_To
--         ,( SELECT fnd_date.canonical_to_date(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_date_to_iv_id
--          ) Date_To
         ,fnd_number.canonical_to_number('0.0') Amount
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_amount_iv_id
--          ) Amount
         ,fnd_number.canonical_to_number('0.0') Rate
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_rate_iv_id
--          ) Rate
         ,fnd_number.canonical_to_number('0.0') Qualifying_days
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_qualifying_days_iv_id
--          ) Qualifying_days
         ,fnd_number.canonical_to_number('0.0') SSP_days_due
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_ssp_days_due_iv_id
--          ) SSP_days_due
         ,fnd_number.canonical_to_number('0.0') Withheld_days
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_withheld_days_iv_id
--          ) Withheld_days
--         ,fnd_number.canonical_to_number('0.0') SSP_weeks
--         ,( SELECT fnd_number.canonical_to_number(eev.screen_entry_value)
--            FROM   pay_element_entry_values_f eev
--            WHERE  eev.element_entry_id = ele.element_entry_id
--              AND  ele.effective_start_date BETWEEN eev.effective_start_date
--                                                AND eev.effective_end_date
--              AND  eev.input_value_id = p_ssp_week_iv_id
--          ) SSP_weeks
  FROM   pay_element_entries_f ele
  WHERE  ele.assignment_id         = p_primary_assignment_id   -- primary assignment id offline
    AND  ele.element_link_id       = p_element_link_id -- run once for evry bg related link
    AND  ele.creator_type = 'S' -- determine piw_id offline
    AND  ele.creator_id = p_piw_id;
--
--
--
  CURSOR csr_smp_entries
    (p_maternity_id                 IN        NUMBER
    ,p_primary_assignment_id        IN        NUMBER
    ,p_element_link_id              IN        NUMBER
--    ,p_amount_iv_id                 IN        NUMBER
--    ,p_week_commencing_iv_id        IN        NUMBER
--    ,p_rate_iv_id                   IN        NUMBER
--    ,p_recoverable_amount_iv_id     IN        NUMBER
    ) IS
  SELECT ele.element_entry_id
        ,ele.effective_start_date
        ,ele.effective_end_date
        ,fnd_number.canonical_to_number('0.0') amount
--        ,(SELECT fnd_number.canonical_to_number(piv.screen_entry_value)
--          FROM   pay_element_entry_values_f piv
--          WHERE  piv.element_entry_id = ele.element_entry_id
--            AND  ele.effective_start_date
--                   BETWEEN piv.effective_start_date
--                       AND piv.effective_end_date
--            AND  piv.input_value_id = p_amount_iv_id -- g_smp_input_values(1).id
--         ) amount
        ,fnd_date.canonical_to_date('3712/12/31 00:00:00')week_commencing
--        ,(SELECT fnd_date.canonical_to_date(piv.screen_entry_value)
--          FROM   pay_element_entry_values_f piv
--          WHERE  piv.element_entry_id = ele.element_entry_id
--            AND  ele.effective_start_date
--                   BETWEEN piv.effective_start_date
--                       AND piv.effective_end_date
--            AND  piv.input_value_id = p_week_commencing_iv_id -- g_smp_input_values(2).id
--         ) week_commencing
--        ,rpad(' ',60,' ') rate
--        ,(SELECT piv.screen_entry_value rate /* text */
--          FROM   pay_element_entry_values_f piv
--          WHERE  piv.element_entry_id = ele.element_entry_id
--            AND  ele.effective_start_date
--                   BETWEEN piv.effective_start_date
--                       AND piv.effective_end_date
--            AND  piv.input_value_id = p_rate_iv_id -- g_smp_input_values(3).id
--         )
--        ,fnd_number.canonical_to_number(piv.screen_entry_value) recoverable_amount
--        ,(SELECT fnd_number.canonical_to_number(piv.screen_entry_value) recoverable_amount
--          FROM   pay_element_entry_values_f piv
--          WHERE  piv.element_entry_id = ele.element_entry_id
--            AND  ele.effective_start_date
--                   BETWEEN piv.effective_start_date
--                       AND piv.effective_end_date
--            AND  piv.input_value_id = p_recoverable_amount_iv_id -- g_smp_input_values(4).id
--         )
  FROM   pay_element_entries_f ele
  WHERE  ele.assignment_id = p_primary_assignment_id   -- primary assignment id offline
    AND  ele.element_link_id = p_element_link_id
    AND  ele.creator_type = 'M'
    AND  ele.creator_id = p_maternity_id;  -- determine maternity id offline
--
--
--
  CURSOR get_element_entry_value
    (p_element_entry_id         IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_input_value_id           IN      NUMBER
    ) IS
  SELECT eev.screen_entry_value
  FROM   pay_element_entry_values_f eev
  WHERE  eev.element_entry_id = p_element_entry_id
    AND  p_effective_date
           BETWEEN eev.effective_start_date
               AND eev.effective_end_date
    AND  eev.input_value_id = p_input_value_id;
--
--
--
  CURSOR csr_absence_details
    (p_absence_attendance_id      IN      NUMBER
    ) IS
  SELECT person_id
        ,business_group_id
        ,date_start
        ,date_end
        ,sickness_start_date
        ,sickness_end_date
        ,date_projected_start
        ,date_projected_end
        ,maternity_id             -- needed to find SMP element entries
        ,linked_absence_id        -- needed to find SSP element entries
  FROM   per_absence_attendances abs
  WHERE  abs.absence_attendance_id = p_absence_attendance_id;
--
--
--
  CURSOR csr_max_ssp_period
    (p_element_type_id IN NUMBER
    ,p_effective_date  IN DATE
    ) IS
  SELECT (fnd_number.canonical_to_number(element_information1) * 7) max_value
  FROM   pay_element_types_f
  WHERE  element_type_id = p_element_type_id
    AND  p_effective_date
           BETWEEN effective_start_date
               AND effective_end_date;
--
--
--
  CURSOR csr_absence_primary_assignment
    (p_absence_id IN NUMBER
    ) IS
  SELECT asg.assignment_id
  FROM   per_absence_attendances abs
        ,per_all_assignments_f asg
  WHERE  abs.absence_attendance_id = p_absence_id
    AND  asg.person_id = abs.person_id
    AND  NVL(abs.date_start,NVL(abs.sickness_start_date,SYSDATE))
           BETWEEN asg.effective_start_date
               AND asg.effective_end_date
    AND  asg.primary_flag = 'Y';
--
--
--
  CURSOR csr_calendar_usages
    (--p_purpose_usage_id  IN NUMBER
     p_entity_name       IN VARCHAR2
    ,p_primary_key_value IN NUMBER
    ,p_effective_date    IN DATE
    ) IS
  SELECT cu.purpose_usage_id
        ,cu.primary_key_value
  FROM   hr_calendar_usages cu
        ,hr_pattern_purpose_usages ppu
  WHERE  ppu.pattern_purpose = 'QUALIFYING PATTERN'
    AND  ppu.entity_name = p_entity_name
    AND  cu.purpose_usage_id = ppu.purpose_usage_id
    AND  cu.primary_key_value = p_primary_key_value
    AND  p_effective_date BETWEEN cu.start_date and cu.end_date;
--
--
--
    CURSOR csr_smp_info
      (p_smp_element_type_id IN NUMBER
      ,p_effective_date      IN DATE
      ) IS
    SELECT fnd_number.canonical_to_number(elt.element_information1) earliest_start_mpp
          ,fnd_number.canonical_to_number(elt.element_information2) qualifying_week
          ,fnd_number.canonical_to_number(elt.element_information4) max_mpp_weeks
          ,fnd_number.canonical_to_number(elt.element_information9) high_rate
          ,fnd_number.canonical_to_number(elt.element_information10) low_rate
          ,fnd_number.canonical_to_number(elt.element_information14) weeks_higher_rate
    FROM   pay_element_types_f elt
    WHERE  elt.element_type_id = p_smp_element_type_id
      AND  p_effective_date
             BETWEEN elt.effective_start_date
                 AND elt.effective_end_date;
--
--
--
  CURSOR csr_max_smp_period
    (p_element_type_id IN NUMBER
    ,p_effective_date  IN DATE
    ) IS
  SELECT (fnd_number.canonical_to_number(element_information4) * 7) max_value
  FROM   pay_element_types_f
  WHERE  element_type_id = p_element_type_id
    AND  p_effective_date
           BETWEEN effective_start_date
               AND effective_end_date;
--
--
--
------------------pqp_get_absence_attendances--------------------
  FUNCTION pqp_get_absence_attendances(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_absence_further_info----------
  FUNCTION pqp_get_absence_further_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_absence_addnl_attr------------------
  FUNCTION pqp_get_absence_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_ssp_medicals_details--------------------
  FUNCTION pqp_get_ssp_medicals_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_ssp_medical_addnl_attr------------------
  FUNCTION pqp_get_ssp_medical_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_ssp_matrnty_details--------------------
  FUNCTION pqp_get_ssp_matrnty_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_ssp_matrnty_addnl_attr------------------
  FUNCTION pqp_get_ssp_matrnty_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_attendance_id     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------pqp_get_plan_extra_info------------------
  FUNCTION pqp_get_plan_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_other_plan_extra_info------------------
  FUNCTION pqp_get_other_plan_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_information_type          IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_osp_plan_extra_info------------------
  FUNCTION pqp_get_osp_pl_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_osp_oth_plan_extra_info------------------
  FUNCTION pqp_get_osp_oth_pl_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------ben_get_absence_id------------------
  FUNCTION ben_get_absence_id(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
  )
    RETURN NUMBER;

------------------ben_get_per_abs_attendances--------------------
  FUNCTION ben_get_per_abs_attendances(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_absence_further_info----------
  FUNCTION ben_get_absence_further_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_absence_addnl_attr------------------
  FUNCTION ben_get_absence_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_ssp_medical_details--------------------
  FUNCTION ben_get_ssp_medicals_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_ssp_medical_addnl_attr------------------
  FUNCTION ben_get_ssp_medical_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_ssp_matrnty_details--------------------
  FUNCTION ben_get_ssp_matrnty_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_col_name                  IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_ssp_matrnty_addnl_attr------------------
  FUNCTION ben_get_ssp_matrnty_addnl_attr(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------------get_lookup_code---------------------------
  FUNCTION get_lookup_code(
    p_lookup_type               IN       VARCHAR2
   ,p_lookup_meaning            IN       VARCHAR2
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_absence_details--------------------
  FUNCTION get_absence_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------ben_get_absence_details--------------------
  FUNCTION ben_get_absence_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_medical_details--------------------
  FUNCTION get_medical_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_matrnty_details--------------------
  FUNCTION get_matrnty_details(
    p_absence_attendance_id     IN       NUMBER
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------------get_LOS_based_entitlements--------------------

  FUNCTION get_los_based_entitlements
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_band_entitlements         OUT NOCOPY pqp_absval_pkg.t_entitlements --t_band_info
   ,p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_omp_intend_to_return_to_work IN    VARCHAR2 DEFAULT 'X'
   ,p_entitlement_bands_list_name IN     VARCHAR2
        DEFAULT 'PQP_GAP_ENTITLEMENT_BANDS'
   ,p_is_ent_override             IN OUT NOCOPY BOOLEAN
  )
    RETURN NUMBER;

------------------pqp_get_band_ent_parameters--------------------

  FUNCTION pqp_get_band_ent_parameters(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_entitlement_parameters    OUT NOCOPY r_entitlement_parameters
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------get_entitlement_parameters--------------------

  FUNCTION get_entitlement_parameters -- pqp_get_entitlement_parameters
   (p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_absence_pay_plan_class    IN       VARCHAR2
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_entitlement_parameters    OUT NOCOPY t_entitlement_parameters
   ,p_error_msg                 OUT NOCOPY VARCHAR2
   ,p_omp_intend_to_return_to_work IN    VARCHAR2 DEFAULT 'X'
   ,p_entitlement_bands_list_name IN     VARCHAR2
        DEFAULT 'PQP_GAP_ENTITLEMENT_BANDS'
  )
    RETURN NUMBER;

-------------pqp_get_band_ent_value------------------------------

  FUNCTION pqp_get_band_ent_value
    (p_business_group_id           IN            NUMBER
    ,p_effective_date              IN            DATE
    ,p_assignment_id               IN            NUMBER -- Context #3
    ,p_element_type_id             IN            NUMBER -- Context #4
    ,p_entitlement_tab_id          IN            NUMBER
    ,p_benefits_length_of_service  IN            NUMBER
    ,p_band1_entitlement              OUT NOCOPY NUMBER
    ,p_band1_percentage               OUT NOCOPY NUMBER
    ,p_band2_entitlement              OUT NOCOPY NUMBER
    ,p_band2_percentage               OUT NOCOPY NUMBER
    ,p_band3_entitlement              OUT NOCOPY NUMBER
    ,p_band3_percentage               OUT NOCOPY NUMBER
    ,p_band4_entitlement              OUT NOCOPY NUMBER
    ,p_band4_percentage               OUT NOCOPY NUMBER
    ,p_error_msg                      OUT NOCOPY VARCHAR2
    ,p_entitlement_bands_list_name IN            VARCHAR2 DEFAULT
       'PQP_GAP_ENTITLEMENT_BANDS'
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ) RETURN NUMBER;

------------------pqp_get_maternity_id------------------
  FUNCTION pqp_get_maternity_id(
    p_absence_id                IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_medical_id------------------
  FUNCTION pqp_get_medical_id(
    p_absence_id                IN       NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

----------------pqp_gb_get_no_of_holidays---------------
  FUNCTION pqp_gb_get_no_of_holidays(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

----------------pqp_gb_get_calendar_abs_days---------------
  FUNCTION pqp_gb_get_calendar_days(p_start_date IN DATE, p_end_date IN DATE)
    RETURN NUMBER;

----------------pqp_gb_get_cal_abs_hol_days---------------
  FUNCTION pqp_gb_get_cal_abs_hol_days(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

----------------pqp_gb_get_cal_abs_days---------------
  FUNCTION pqp_gb_get_cal_abs_days(
    p_business_group_id         IN       NUMBER
   ,p_abs_start_date            IN       DATE
   ,p_abs_end_date              IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

----------------pqp_gb_get_cal_abs_days---------------
  FUNCTION pqp_gb_get_no_of_work_holidays(
    p_business_group_id         IN       NUMBER
   ,p_work_dates                IN       pqp_schedule_calculation_pkg.t_working_dates
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
  )
    RETURN NUMBER;

----------------pqp_gb_get_work_abs_days_udt---------------
  FUNCTION pqp_gb_get_work_abs_days_udt(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,p_default_wp                IN       VARCHAR2
   ,p_table_id                  IN       NUMBER
   ,p_column_name               IN       VARCHAR2
   ,p_value                     IN       VARCHAR2
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

----------------pqp_gb_get_work_abs_days---------------
  FUNCTION pqp_gb_get_work_abs_days(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_start_date                IN       DATE
   ,p_end_date                  IN       DATE
   ,p_holidays                  OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_default_wp                IN       VARCHAR2
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

-------------pqp_get_omp_band_ent_value------------------------------
  FUNCTION pqp_get_omp_band_ent_value
    (p_business_group_id           IN            NUMBER
    ,p_effective_date              IN            DATE
    ,p_assignment_id               IN            NUMBER -- Context #3
    ,p_element_type_id             IN            NUMBER -- Context #4
    ,p_entitlement_tab_id          IN            NUMBER
    ,p_benefits_length_of_service  IN            NUMBER
    ,p_return_to_work              IN            VARCHAR2
    ,p_band1_entitlement              OUT NOCOPY NUMBER
    ,p_band1_percentage               OUT NOCOPY NUMBER
    ,p_band1_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band2_entitlement              OUT NOCOPY NUMBER
    ,p_band2_percentage               OUT NOCOPY NUMBER
    ,p_band2_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band3_entitlement              OUT NOCOPY NUMBER
    ,p_band3_percentage               OUT NOCOPY NUMBER
    ,p_band3_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_band4_entitlement              OUT NOCOPY NUMBER
    ,p_band4_percentage               OUT NOCOPY NUMBER
    ,p_band4_avg_rec_ind              OUT NOCOPY VARCHAR2
    ,p_error_msg                      OUT NOCOPY VARCHAR2
    ,p_entitlement_bands_list_name IN            VARCHAR2 DEFAULT
       'PQP_GAP_ENTITLEMENT_BANDS'
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ) RETURN NUMBER;

-------------get_next_working_date------------------------------

  FUNCTION get_next_working_date(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_date_start                IN       DATE
   ,p_days                      IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_default_wp                IN       VARCHAR2 DEFAULT NULL
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN DATE;

------------------pqp_get_omp_plan_extra_info------------------
  FUNCTION pqp_get_omp_pl_extra_info(
    p_pl_id                     IN       NUMBER
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------------pqp_get_omp_oth_plan_extra_info------------------
  FUNCTION pqp_get_omp_oth_pl_extra_info(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_name                   IN       VARCHAR2
   ,p_segment_name              IN       VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
   ,p_truncated_yes_no          OUT NOCOPY VARCHAR2
   ,p_error_msg                 OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

------------ PQP_GB_GET_ABSENCE_SSP ----------------------
  FUNCTION pqp_gb_get_absence_ssp
    (p_business_group_id         IN       NUMBER
    ,p_assignment_id             IN       NUMBER
    ,p_absence_id                IN       NUMBER
    ,p_start_date                IN       DATE
    ,p_end_date                  IN       DATE
    ,p_range_total               OUT NOCOPY NUMBER
    ,p_absence_total             OUT NOCOPY NUMBER
    ,p_error_code                OUT NOCOPY NUMBER
    ,p_error_msg                 OUT NOCOPY VARCHAR2
    ) RETURN NUMBER;

------------ PQP_GB_GET_ABSENCE_SMP ----------------------
  FUNCTION pqp_gb_get_absence_smp
    (p_business_group_id         IN       NUMBER
    ,p_assignment_id             IN       NUMBER
    ,p_absence_id                IN       NUMBER
    ,p_start_date                IN       DATE
    ,p_end_date                  IN       DATE
    ,p_range_total               OUT NOCOPY NUMBER
    ,p_absence_total             OUT NOCOPY NUMBER
    ,p_error_code                OUT NOCOPY NUMBER
    ,p_error_msg                 OUT NOCOPY VARCHAR2
    ) RETURN NUMBER;

------------BEN_MATRNTY_DETAILS----------------------
  FUNCTION ben_matrnty_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

------------BEN_MEDICAL_DETAILS----------------------
  FUNCTION ben_medical_details(
    p_assignment_id             IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_title                     IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN VARCHAR2;

-----------------------------------------------------------
--This function have three variants for Entitled, Paid, Work Pattern Columns
--p_search_start_date, p_search_end_date should be checked against absence start
-- date
--and absence end date. For search start date greatest (
-- search_start_date,absence_start_date)
--for search end date least(search_end_date,absence_end_date)
  FUNCTION get_abs_plan_ent_days_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE DEFAULT NULL
   ,p_search_end_date           IN       DATE DEFAULT NULL
   ,p_level_of_entitlement      IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

------------------------------------------------------------
  FUNCTION get_abs_plan_paid_days_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE DEFAULT NULL
   ,p_search_end_date           IN       DATE DEFAULT NULL
   ,p_level_of_pay              IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

------------------------------------------------------------
  FUNCTION get_abs_plan_wp_info(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE DEFAULT NULL
   ,p_search_end_date           IN       DATE DEFAULT NULL
   ,p_work_pattern_day_type     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER;

-----------------------------------------
  FUNCTION get_osp_band_paid_entitlements(
    p_absence_attendance_id     IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_band1_entitled            OUT NOCOPY NUMBER
   ,p_band1_paid                OUT NOCOPY NUMBER
   ,p_band2_entitled            OUT NOCOPY NUMBER
   ,p_band2_paid                OUT NOCOPY NUMBER
   ,p_band3_entitled            OUT NOCOPY NUMBER
   ,p_band3_paid                OUT NOCOPY NUMBER
   ,p_band4_entitled            OUT NOCOPY NUMBER
   ,p_band4_paid                OUT NOCOPY NUMBER
   ,p_noband_entitled           OUT NOCOPY NUMBER
   ,p_noband_paid               OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_search_start_date         IN       DATE DEFAULT NULL
   ,p_search_end_date           IN       DATE DEFAULT NULL
  )
    RETURN NUMBER;

-----------------------------------------------
  FUNCTION chk_calendar_occurance(
    p_date                      IN       DATE
   ,p_calendar_table_id         IN       NUMBER
   ,p_calendar_rules_list       IN       VARCHAR2
   ,p_cal_rul_name              OUT NOCOPY VARCHAR2
   ,p_cal_day_name              OUT NOCOPY VARCHAR2
   ,p_cal_rule_value            OUT NOCOPY VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_cal_value                 IN       VARCHAR2 DEFAULT NULL
   ,p_filter                    IN       VARCHAR2 DEFAULT 'AllMatch'
  )
    RETURN NUMBER;

----------------------------------------------------------------
  FUNCTION get_band_entitlement_balance(
    p_business_group_id        IN       NUMBER
   ,p_effective_date           IN       DATE
   ,p_assignment_id            IN       NUMBER
   ,p_pl_typ_id                IN       NUMBER
   ,p_scheme_calendar_type     IN       VARCHAR2
   ,p_scheme_calendar_duration IN       VARCHAR2
   ,p_scheme_calendar_uom      IN       VARCHAR2
   ,p_scheme_start_date        IN       VARCHAR2
   ,p_scheme_overlap_rule      IN       VARCHAR2
   ,p_level_of_entitlement     IN       VARCHAR2
   ,p_error_code               OUT NOCOPY NUMBER
   ,p_error_message            OUT NOCOPY VARCHAR2
   ,p_days_hours               IN  VARCHAR2 DEFAULT 'DAYS'
--Added for CS
   ,p_default_work_pattern      IN VARCHAR2
   ,p_plan_types_to_extend_period IN VARCHAR2 -- LG/PT
   ,p_entitlement_uom             IN VARCHAR2 -- LG/PT
   ,p_absence_schedule_wp         IN VARCHAR2 -- LG/PT
   ,p_track_part_timers           IN VARCHAR2 -- LG/PT
   ,p_absence_start_date          IN DATE  DEFAULT NULL

  )
    RETURN NUMBER;

-----------------------------------------------------
  FUNCTION get_band_ent_bal_by_ele_typ_id(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2 DEFAULT 'DAYS'
   ,p_absence_start_date        IN       DATE DEFAULT NULL
  )
    RETURN NUMBER;

----------------------------------------------------
  FUNCTION get_all_band_ent_balance(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_band1_ent_bal             OUT NOCOPY NUMBER
   ,p_band2_ent_bal             OUT NOCOPY NUMBER
   ,p_band3_ent_bal             OUT NOCOPY NUMBER
   ,p_band4_ent_bal             OUT NOCOPY NUMBER
   ,p_noband_ent_bal            OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_absence_start_date        IN       DATE  DEFAULT NULL
  )
    RETURN NUMBER;

---------------------------------------------------
  FUNCTION get_band_ent_bal_by_pl_id(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_pl_id                     IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

-------------------------------------------------------------
--function added by sshetty.
  FUNCTION get_paid_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_level_of_pay              IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

--------------------------------------------------------------------
  FUNCTION get_entitled_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

--------------------------------------------------------
  FUNCTION get_wp_days_duration(
    p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_wp_day_type               IN       VARCHAR2
   ,p_search_start_date         IN       DATE
   ,p_search_end_date           IN       DATE
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_message                   OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

--------------------------------------------------------
  FUNCTION get_subpriority(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_payroll_action_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_ler_id                    IN       NUMBER
   ,p_absence_start_date        IN       DATE
  )
    RETURN NUMBER;

---------------------------------------------------
  FUNCTION get_next_cal_date(
    p_business_group_id         IN       NUMBER
   ,p_date_start                IN       DATE
   ,p_days                      IN       NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_table_id                  IN       NUMBER DEFAULT NULL
   ,p_column_name               IN       VARCHAR2 DEFAULT NULL
   ,p_value                     IN       VARCHAR2 DEFAULT NULL
  )
    RETURN DATE;

---------------------------------------------------
-- Added this function for absence DDF context usage
  FUNCTION exists_in_gap_lookup(
    p_business_group_id         IN       NUMBER
   ,p_lookup_code               IN       VARCHAR2
   ,p_effective_date            IN       DATE
   ,p_lookup_type               IN       VARCHAR2
        DEFAULT 'PQP_GAP_ABSENCE_TYPES_LIST'
  )
    RETURN BOOLEAN;

---------------------------------------------------
---- Added for Daily Absences in OMP from here-----
---------------------------------------------------

  FUNCTION get_omp_all_band_ent_balance(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_band1_ent_bal             OUT NOCOPY NUMBER
   ,p_band2_ent_bal             OUT NOCOPY NUMBER
   ,p_band3_ent_bal             OUT NOCOPY NUMBER
   ,p_band4_ent_bal             OUT NOCOPY NUMBER
   ,p_noband_ent_bal            OUT NOCOPY NUMBER
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
  )
    RETURN NUMBER;

-------------------------------------------------------------
  FUNCTION get_omp_band_ent_bal_ele_typ(
    p_business_group_id         IN       NUMBER
   ,p_assignment_id             IN       NUMBER
   ,p_element_type_id           IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2 DEFAULT 'DAYS'
  )
    RETURN NUMBER;

--------------------------------------------------------------
  FUNCTION get_omp_band_ent_bal_pl_typ(
    p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_assignment_id             IN       NUMBER
   ,p_pl_typ_id                 IN       NUMBER
   ,p_level_of_entitlement      IN       VARCHAR2
   ,p_error_code                OUT NOCOPY NUMBER
   ,p_error_message             OUT NOCOPY VARCHAR2
   ,p_days_hours                IN  VARCHAR2
  )
    RETURN NUMBER;
---------------------------------------------------
---- Added for Daily Absences in OMP End here-----
---------------------------------------------------

-------------------------------------------------------
------------- Added for Hours Solution ----------------
-------------------------------------------------------


----------get_osp_hours_band_paid_ent------------------
FUNCTION get_osp_hours_band_paid_ent(
              p_absence_attendance_id IN  NUMBER,
              p_pl_id                 IN  NUMBER,
              p_band1_entitled        OUT NOCOPY NUMBER,
              p_band2_entitled        OUT NOCOPY NUMBER,
              p_band3_entitled        OUT NOCOPY NUMBER,
              p_band4_entitled        OUT NOCOPY NUMBER,
              p_noband_entitled       OUT NOCOPY NUMBER,
              p_error_code            OUT NOCOPY NUMBER,
              p_error_message         OUT NOCOPY VARCHAR2,
              p_search_start_date     IN  DATE DEFAULT NULL,
              p_search_end_Date       IN  DATE DEFAULT NULL )
            RETURN NUMBER ;

--------------get_all_band_hours_ent_balance------------------

FUNCTION get_all_band_hours_ent_balance(
                    p_business_group_id IN  NUMBER
                   ,p_assignment_id     IN  NUMBER
                   ,p_element_type_id   IN  NUMBER
                   ,p_effective_date    IN  DATE
                   ,p_band1_ent_bal     OUT NOCOPY NUMBER
                   ,p_band2_ent_bal     OUT NOCOPY NUMBER
                   ,p_band3_ent_bal     OUT NOCOPY NUMBER
                   ,p_band4_ent_bal     OUT NOCOPY NUMBER
                   ,p_noband_ent_bal    OUT NOCOPY NUMBER
                   ,p_error_code        OUT NOCOPY NUMBER
                   ,p_error_message     OUT NOCOPY VARCHAR2
                   )
        RETURN NUMBER ;
--------------get_omp_all_band_hours_ent_bal------------------
FUNCTION get_omp_all_band_hours_ent_bal(
                     p_business_group_id IN  NUMBER
                    ,p_assignment_id     IN  NUMBER
                    ,p_element_type_id   IN  NUMBER
                    ,p_effective_date    IN  DATE
                    ,p_band1_ent_bal     OUT NOCOPY NUMBER
                    ,p_band2_ent_bal     OUT NOCOPY NUMBER
                    ,p_band3_ent_bal     OUT NOCOPY NUMBER
                    ,p_band4_ent_bal     OUT NOCOPY NUMBER
                    ,p_noband_ent_bal    OUT NOCOPY NUMBER
                    ,p_error_code        OUT NOCOPY NUMBER
                    ,p_error_message     OUT NOCOPY VARCHAR2
                    )
        RETURN NUMBER ;
-------------------------------------------------------
------------- Added for Hours Solution ----------------
-------------------------------------------------------
--
--
--
FUNCTION get_first_paid_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_pay          IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE;
--
FUNCTION get_last_paid_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_pay          IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE;
--
FUNCTION get_first_entitled_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_entitlement  IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE;
--
FUNCTION get_last_entitled_day
  (p_absence_attendance_id IN            NUMBER
  ,p_pl_id                 IN            NUMBER
  ,p_level_of_entitlement  IN            VARCHAR2 DEFAULT NULL
  ) RETURN DATE;
--

PROCEDURE chk_override_entitlements -- AI and AU USER HOOK PROC pepeihcd.sql
  (p_person_extra_info_id          IN      NUMBER
  ,p_person_id                     IN      NUMBER
  ,p_information_type              IN      VARCHAR2
  ,p_pei_information_category      IN      VARCHAR2
  ,p_pei_information1              IN      VARCHAR2
  ,p_pei_information2              IN      VARCHAR2
  ,p_pei_information3              IN      VARCHAR2
  ,p_pei_information11             IN      VARCHAR2
  ,p_pei_information12             IN      VARCHAR2
  ,p_pei_information13             IN      VARCHAR2
  ,p_pei_information14             IN      VARCHAR2
  );

FUNCTION get_absence_ssp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER;

FUNCTION get_period_ssp
  (p_business_group_id         IN       NUMBER -- Context
  ,p_assignment_id             IN       NUMBER -- Context
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER;

FUNCTION get_absence_smp
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_range_start_date          IN       DATE
  ,p_range_end_date            IN       DATE
  ) RETURN NUMBER;

PROCEDURE clear_cache;

FUNCTION get_absence_paid_days_tp
 ( p_assignment_id IN NUMBER
  ,p_start_date    IN DATE
  ,p_end_date      IN DATE
  ,p_level_of_pay  IN VARCHAR2
 ) RETURN NUMBER ;

FUNCTION get_all_band_cs_4_yr_ent_bal
    ( p_business_group_id    IN     NUMBER
     ,p_assignment_id        IN     NUMBER
     ,p_element_type_id      IN     NUMBER
     ,p_effective_date       IN     DATE
     ,p_band1_ent_bal           OUT NOCOPY NUMBER
     ,p_band2_ent_bal           OUT NOCOPY NUMBER
     ,p_band3_ent_bal           OUT NOCOPY NUMBER
     ,p_band4_ent_bal           OUT NOCOPY NUMBER
     ,p_noband_ent_bal          OUT NOCOPY NUMBER
     ,p_error_message           OUT NOCOPY VARCHAR2
     ) RETURN NUMBER ;


------------------ For LG/PT
 PROCEDURE get_entitlements
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_effective_date            IN       DATE
   ,p_pl_id                     IN       NUMBER
   ,p_entitlement_table_id      IN       NUMBER
   ,p_benefits_length_of_service IN      NUMBER
   ,p_band_entitlements         OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_entitlement_bands_list_name IN     VARCHAR2 DEFAULT
      'PQP_GAP_ENTITLEMENT_BANDS'
   ) ;

FUNCTION get_minimum_pay_info
   (p_assignment_id             IN       NUMBER
   ,p_business_group_id         IN       NUMBER
   ,p_absence_id                IN         NUMBER
   ,p_minpay_start_date          OUT NOCOPY DATE
   ,p_minpay_end_date            OUT NOCOPY DATE
    ) RETURN NUMBER ;

------------------
FUNCTION get_osp_minimum_pay_rate
       (p_assignment_id     IN  NUMBER
        ,p_business_group_id IN  NUMBER
        ,p_pl_id             IN  NUMBER
        ,p_effective_date    IN  DATE
       ) RETURN NUMBER ;

------------------

PROCEDURE set_osp_omp_rounding_factors
  (p_pl_id            IN              NUMBER
  ,p_pt_entitl_rounding_type      OUT NOCOPY      VARCHAR2
  ,p_pt_rounding_precision        OUT NOCOPY      NUMBER
  ,p_ft_entitl_rounding_type      OUT NOCOPY      VARCHAR2
  ,p_ft_rounding_precision        OUT NOCOPY      NUMBER
  );


FUNCTION chk_absence_belongs_to_person
 ( p_assignment_id         IN NUMBER
  ,p_business_group_id     IN NUMBER
  ,p_absence_attendance_id IN NUMBER
 ) RETURN BOOLEAN ;

FUNCTION get_absence_statutory_pay
  (p_business_group_id         IN       NUMBER
  ,p_assignment_id             IN       NUMBER
  ,p_absence_attendance_id     IN       NUMBER
  ,p_start_date          IN       DATE
  ,p_end_date            IN       DATE
  ) RETURN NUMBER ;

PROCEDURE decode_round_config
  (p_code                 IN           VARCHAR2
  ,p_rounding_type        OUT NOCOPY   VARCHAR2
  ,p_rounding_precision   OUT NOCOPY   NUMBER
  ,p_enb_prorat           IN VARCHAR2 DEFAULT 'Y'
  );


FUNCTION  get_all_band_ent_used_and_rem(
     p_business_group_id           IN         NUMBER
    ,p_assignment_id               IN         NUMBER
    ,p_element_type_id             IN         NUMBER
    ,p_date_earned                 IN         DATE
    ,p_effective_date              IN         DATE
    ,p_entitlement_tab_id          IN         NUMBER
    ,p_benefits_length_of_service  IN         NUMBER
    ,p_band1_abs_used               IN         NUMBER
    ,p_band2_abs_used               IN         NUMBER
    ,p_band3_abs_used               IN         NUMBER
    ,p_band4_abs_used               IN         NUMBER
    ,p_override_effective_date     IN            DATE DEFAULT NULL
    ,p_scheme_cal_type             IN VARCHAR2 DEFAULT 'FIXED'
    ,p_band1_ent_used	           OUT NOCOPY NUMBER
    ,p_band2_ent_used              OUT NOCOPY NUMBER
    ,p_band3_ent_used              OUT NOCOPY NUMBER
    ,p_band4_ent_used              OUT NOCOPY NUMBER
    ,p_noband_ent_used             OUT NOCOPY NUMBER
    ,p_band1_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band2_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band3_4year_ent_used        OUT NOCOPY NUMBER
    ,p_band4_4year_ent_used        OUT NOCOPY NUMBER
    ,p_noband_4year_ent_used       OUT NOCOPY NUMBER
    ,p_band1_remaining             OUT NOCOPY NUMBER
    ,p_band2_remaining             OUT NOCOPY NUMBER
    ,p_band3_remaining             OUT NOCOPY NUMBER
    ,p_band4_remaining             OUT NOCOPY NUMBER
    ,p_band1_percentage            OUT NOCOPY NUMBER
    ,p_band2_percentage            OUT NOCOPY NUMBER
    ,p_band3_percentage            OUT NOCOPY NUMBER
    ,p_band4_percentage            OUT NOCOPY NUMBER
    ,p_error_msg                   OUT NOCOPY VARCHAR2
    )RETURN NUMBER;


PROCEDURE abs_pension_date_chk( p_date_start             IN DATE
                                 ,p_date_end               IN DATE
				 ,p_absence_attendance_id  IN NUMBER
	                         ,p_abs_information4       IN VARCHAR2
	   	                 ,p_abs_information5       IN VARCHAR2
			         ,p_abs_information6       IN VARCHAR2
				  -- bug 5975119
				 ,p_abs_information_category in VARCHAR2 default null
				 );

PROCEDURE abs_pension_date_check( p_date_start          IN DATE
                                 ,p_date_end            IN DATE
	                         ,p_abs_information4    IN VARCHAR2
	   	                 ,p_abs_information5    IN VARCHAR2
			         ,p_abs_information6    IN VARCHAR2
				 );

FUNCTION get_ssp_smp_paid_days
 ( p_range_start_date IN DATE
  ,p_range_end_date IN DATE
  ,p_assignment_id IN NUMBER
 ) RETURN NUMBER ;

END pqp_gb_osp_functions;

/
