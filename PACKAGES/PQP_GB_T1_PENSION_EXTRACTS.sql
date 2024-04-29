--------------------------------------------------------
--  DDL for Package PQP_GB_T1_PENSION_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_T1_PENSION_EXTRACTS" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbtp1.pkh 120.5.12010000.13 2010/03/10 05:35:17 dchindar ship $ */
--
-- Debug Variables.
--
  g_proc_name              VARCHAR2(61):= 'pqp_gb_t1_pension_extracts.';
  g_nested_level           NUMBER:= 0;
--
-- Global Varibales
--
  g_business_group_id      NUMBER:= NULL; -- IMPORTANT TO KEEP NULL
  g_master_bg_id           NUMBER:= NULL;
  g_legislation_code       VARCHAR2(10):= 'GB';
  g_effective_date         DATE;

  g_extract_type                VARCHAR2(30);
  g_last_effective_date         DATE;
  g_next_effective_date         DATE;
  g_effective_run_date          DATE;

  -- Introduced for Type 1 only
  g_pension_year_start_date     DATE;
  g_pension_year_end_date       DATE;

  g_extract_udt_name            VARCHAR2(80);
  g_criteria_location_code      VARCHAR2(20);
  g_lea_number                  VARCHAR2(3):=RPAD(' ',3,' ');
  g_crossbg_enabled             VARCHAR2(1) := 'N';
  g_cross_per_enabled           VARCHAR2(1);
  g_estb_number                 VARCHAR2(4):='0000';
  g_originators_title           VARCHAR2(16);
  g_header_system_element       VARCHAR2(200);

  g_reporting_mode              VARCHAR2(10);
  g_trace                       VARCHAR2(1) := NULL;

  g_oth_rate_type             pay_user_column_instances_f.value%type;
  g_sal_rate_type             pay_user_column_instances_f.value%type;
  g_sf_rate_type              pay_user_column_instances_f.value%type;
  g_lon_rate_type             pay_user_column_instances_f.value%type;
  g_asg_emp_cat_cd            per_all_assignments_f.employment_category%TYPE;
  g_ext_emp_cat_cd            per_all_assignments_f.employment_category%TYPE;
  g_ext_emp_wrkp_cd           per_all_assignments_f.employment_category%TYPE;
--  g_abs_bal_type_id           pay_balance_types.balance_type_id%type;
--  g_sal_bal_type_id           pay_balance_types.balance_type_id%type;
  g_primary_assignment_id     per_all_assignments_f.assignment_id%TYPE;
  g_equal_sal_rate            VARCHAR2(1);
  -- Added for bugfix 3073562:GAP1:GAP2
  g_multiperson_mode            VARCHAR2(1) := 'N';

  -- Added for bugfix 3073562:GAP9b
  g_supply_asg_count            NUMBER;

  -- Added for bugfix 3641851:ENH6
  g_part_time_asg_count         NUMBER;

  -- Added for bugfix 3803760:TERMASG
  g_asg_count                   NUMBER;

  -- Added for bugfix 3803760:FTSUPPLY
  g_override_ft_asg_id          per_all_assignments_f.assignment_id%TYPE;

  --added for raising warning for FT asg.
  g_person_count                NUMBER := 0;

  g_teach_asg_count             NUMBER;

  g_gtc_payments                NUMBER :=0;



  --Added to check if person has been reported earlier : PERIODIC Report
  -- PER_LVR change
  -- this global not required now
  -- coz, we need to check each leaver event in the results.
  --g_person_already_reported     VARCHAR2(1) := NULL ;

  -- PER_LVR : Person LEaver changes
  -- new date variable to keep track of the latest start date
  -- associated with a person record,
  -- after which there is no person leaver event
  g_latest_start_date           DATE;

  --TERM_LSP:BUG :4135481 -- added a global to check for terminated employees
  g_terminated_person          VARCHAR2(1) := 'N';


  -- RETRO:BUG: 4135481
  -- defined balance id for the designaetd Balance type
  --g_def_bal_id                 NUMBER := NULL ;

  -- RETRO:BUG: 4135481
  -- used for raising a warning for a person
  -- if there are prorated/retro payments found
  -- over thesame line of Service.
  g_raise_retro_warning        VARCHAR2(1):= 'N';

  --CALC_PT_SAL_OPTIONS: BUG : 4135481
  -- Two new rows are now seeded in the UDT for the role of switches
  -- 1. "Part Time Salary Paid - Enable Date Earned Mode"
  -- 2. "Part Time Salary Paid - Enable Calendar Day Proration"
  -- First switch is for enabling / disabling the new logic for calculating part
  -- time salary (based on date earned) or revert back to previous logic (date paid).
  -- The second switch is for enabling / disabling calendar averaging, in case NO
  -- matching proration events are found.

  -- The following globals will be used to provide additional options for part
  -- time salary computation methods in calc_part_time_sal function

  g_calc_sal_new                VARCHAR2(1):= NULL; -- use old/new method
  g_proration                   VARCHAR2(1):= NULL; -- enable proration
  g_calendar_avg                VARCHAR2(1):= NULL; -- use calendar averaging
  g_date_work_mode              VARCHAR2(1):= NULL; -- date worked mode

  g_supp_teacher     VARCHAR2(1) := 'N';
  -- Bug 3889646
  TYPE asg_salary_rate_type IS RECORD
       ( salary_rate    NUMBER
       , eff_start_date DATE
       , eff_end_date   DATE
       , fte            NUMBER   );
  TYPE t_asg_salary_rate_type IS TABLE OF asg_salary_rate_type INDEX BY BINARY_INTEGER;

  -- 4336613 : no longer in use,replaced by local variables
  -- g_asg_sal_rate t_asg_salary_rate_type ;

-- Increased size of event_type from 8K to 24K on 25/04/2002 as more events are now being
-- logged then previously planned
-- Bugfix 3073562:GAP10
--  Renamed new_value column to new_ext_emp_cat_cd
--  Added new column new_est_number
  TYPE stored_events_type IS RECORD
        (event_date             DATE
        ,event_type             VARCHAR2(24000)
        ,assignment_id          per_all_assignments_f.assignment_id%TYPE
        ,new_ext_emp_cat_cd     ben_ext_rslt_dtl.val_01%TYPE
        -- Bugfix 3470242:BUG1 : Now storing location_id as estb_number can
        --       always be sought using location id
        -- ,new_estb_number        ben_ext_rslt_dtl.val_01%TYPE
        ,new_location_id        per_all_assignments_f.location_id%TYPE
        ,pt_asg_count_change    NUMBER
        -- Added for bugfix 3803760:TERMASG
        ,asg_count_change       NUMBER
        );


  TYPE t_asg_events_type IS TABLE OF stored_events_type
    INDEX BY BINARY_INTEGER;


  TYPE leaver_dates_type IS RECORD
        (start_date      DATE
        ,leaver_date     DATE
        ,restarter_date  DATE
        ,assignment_id  per_all_assignments_f.assignment_id%TYPE
        );

  TYPE t_leaver_dates_type IS TABLE OF leaver_dates_type
    INDEX BY BINARY_INTEGER;


  -- 4336613 : PERF_ENHANC_3A : Performance Enhancements
  -- this table of records will be used in recalc_data_elements to store
  -- details corresponding of assignment IDs. Instead of calling parttime and FT
  -- salary function multiple times, this data collection will be used
  TYPE asg_recalc_details IS RECORD
       ( assignment_id          per_all_assignments_f.assignment_id%TYPE
       , eff_start_date         DATE
       , eff_end_date           DATE
       , effective_status       VARCHAR2(1)
       , part_time_sal_paid     NUMBER
       , full_time_sal_rate     NUMBER   );
  TYPE t_asg_recalc_details IS TABLE OF asg_recalc_details INDEX BY BINARY_INTEGER;

  g_asg_recalc_details t_asg_recalc_details ;


  -- this global will hold the events for a person (including secondary assignments)
  -- it will be reset to null after the person has been processed by the ext criteria
  g_asg_events t_asg_events_type;

  -- 8iComp Changes: IMORTANT NOTE
  -- Removing the following definition for Table Of Table datastructure
  -- as Oracle 8i does not support this.
  -- Later as Oracle 9i becomes the minimum pre requisite for Apps
  -- we can move back to this logic
  -- till then we will use a common table for keeping Leaver-restarter dates
  -- for all the assignmets together.

  -- The new solution is not as performant as the older one.

  -- MULT-LR new type Added for storing all the leaevr/restarter events for a person
  -- TYPE t_asg_leaver_events_table IS TABLE OF t_leaver_dates_type
  -- INDEX BY BINARY_INTEGER;

  -- MULT-LR new variable to store the events.
  -- g_asg_leaver_events_table  t_asg_leaver_events_table ;

  -- 8iComp changes
  -- This global will hold all the leaver restarter dates for all
  -- the assignments for a person.
  -- this will be used in place of g_asg_leaver_events_table
  -- as this table of tables is not Oracle 8i compliant.
  -- some time in the future we may revert back to the
  -- Table of Table solution.
  g_per_asg_leaver_dates t_leaver_dates_type;

  -- Added the following global variable for extended criteria
  g_ext_dtl_rcd_id        ben_ext_rcd.ext_rcd_id%TYPE;

  -- this global will hold the set of leaver and restarter dates of the primary assignment.
  -- PS : this global can only hold one primary asg at a time and is used inside multiple
  --      service lines functionality, but it should not be refered to elsewhere
  g_primary_leaver_dates t_leaver_dates_type;


  -- this global will hold the set of leaver and restarter dates of the secondary assignment.
  -- PS : this global can only hold one secodary asg at a time and is used inside multiple
  --      service lines functionality, but it should not be refered to elsewhere
  g_sec_leaver_dates  t_leaver_dates_type;


--
-- Global Cursors
--

--
-- Effective assignment attributes
--
/* Uncomment if needed
   CURSOR csr_pqp_asg_attributes -- effective
     (p_assignment_id   NUMBER
     ,p_effective_date  DATE DEFAULT NULL
     ) IS
   SELECT eaat.assignment_attribute_id  assignment_attribute_id
         ,eaat.assignment_id            assignment_id
         ,eaat.effective_start_date     effective_start_date
         ,eaat.effective_end_date       effective_end_date
         ,eaat.tp_is_teacher            tp_is_teacher
         ,eaat.tp_safeguarded_grade     tp_safeguarded_grade
         ,eaat.tp_safeguarded_rate_type tp_safeguarded_rate_type
         ,eaat.tp_safeguarded_rate_id   tp_safeguarded_rate_id
         ,eaat.tp_safeguarded_spinal_point_id tp_safeguarded_spinal_point_id
         ,eaat.tp_elected_pension       tp_elected_pension
         ,eaat.tp_fast_track            tp_fast_track
         ,eaat.creation_date            creation_date
     FROM pqp_assignment_attributes_f eaat -- effective aat
    WHERE eaat.assignment_id = p_assignment_id
      AND ( -- retrieve the effective row
            (NVL(p_effective_date,g_effective_date)
              BETWEEN eaat.effective_start_date
                 AND eaat.effective_end_date
            )
          )
     ORDER BY eaat.effective_start_date; -- effective first
*/
TYPE t_leaver_asgs_type IS TABLE OF per_all_assignments_f.assignment_id%TYPE INDEX BY BINARY_INTEGER;

--
-- Secondary Assignments which are Effective and future
--
CURSOR csr_sec_assignments
   (p_primary_assignment_id     NUMBER
   ,p_person_id                 NUMBER
   ,p_effective_date            DATE
   ) IS
SELECT DISTINCT asg.person_id         person_id
               ,asg.assignment_id     assignment_id
               ,asg.business_group_id business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_assignments_f asg, per_assignment_status_types pss
 WHERE asg.person_id = p_person_id
   AND asg.assignment_id <> p_primary_assignment_id
   AND asg.assignment_type = 'E'  --only employee assignments
   AND pss.assignment_status_type_id = asg.assignment_status_type_id
   AND pss.per_system_status NOT IN ('TERM_ASSIGN','SUSP_ASSIGN','END')
   AND ((p_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
        )
        OR
        ( -- Must have started on or after pension year start date
          asg.effective_start_date >= p_effective_date
          AND
          -- must have started within the reporting period
          asg.effective_start_date <= g_effective_run_date
        )
       )
UNION
SELECT DISTINCT per.person_id            person_id
               ,asg.assignment_id        assignment_id
               ,asg.business_group_id    business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_people_f per, per_all_assignments_f asg
      ,per_assignment_status_types pss
 WHERE per.person_id <> p_person_id
   AND ((p_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date)
        -- ENH3: Cross Person Reporting.
        -- Person record may be starting in between a report period.
              OR
        ( -- Must have started on or after pension year start date
          per.effective_start_date >= p_effective_date
          AND
          -- must have started within the reporting period
          per.effective_start_date <= g_effective_run_date
         )
        )
   AND g_cross_per_enabled = 'Y' -- Cross Person is enabled
   AND (g_crossbg_enabled = 'Y' -- get CrossBG multiple per recs
        OR
        (g_crossbg_enabled = 'N' -- get multiple per recs only in this BG
         AND
         per.business_group_id = g_business_group_id
        )
       )
   AND national_identifier IN
         (SELECT national_identifier
          FROM per_all_people_f per2
          WHERE per2.person_id = p_person_id
            AND ((p_effective_date BETWEEN per2.effective_start_date
                                     AND per2.effective_end_date)
                -- ENH3: Cross Person Reporting.
                -- Person record may be starting in between a report period.
                 OR
                 ( -- Must have started on or after pension year start date
                    per2.effective_start_date >= p_effective_date
                    AND
                   -- must have started within the reporting period
                    per2.effective_start_date <= g_effective_run_date
                  )
                 )
          )
   AND asg.person_id = per.person_id
   AND asg.assignment_type = 'E'  --only employee assignments
   AND pss.assignment_status_type_id = asg.assignment_status_type_id
   AND pss.per_system_status NOT IN ('TERM_ASSIGN','SUSP_ASSIGN','END')
   AND ((p_effective_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
        )
        OR
        ( -- Must have started on or after pension year start date
          asg.effective_start_date >= p_effective_date
          AND
          -- must have started within the reporting period
          asg.effective_start_date <= g_effective_run_date
        )
       )
ORDER BY bizgrpcol ASC, person_id;

-- Added a copy of the above cursor to pick up just the secondary assignments
-- that are effective
--
-- Secondary Assignments which are Effective
--
  CURSOR csr_eff_sec_assignments
   (p_primary_assignment_id     NUMBER
   ,p_person_id                 NUMBER
   ,p_effective_date            DATE
   ) IS
SELECT DISTINCT asg.person_id         person_id
               ,asg.assignment_id     assignment_id
               ,asg.business_group_id business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_assignments_f asg
 WHERE asg.person_id = p_person_id
   AND asg.assignment_id <> p_primary_assignment_id
   AND p_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
UNION
SELECT DISTINCT per.person_id            person_id
               ,asg.assignment_id        assignment_id
               ,asg.business_group_id    business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_people_f per, per_all_assignments_f asg
 WHERE per.person_id <> p_person_id
   AND p_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND g_cross_per_enabled = 'Y' -- Cross Person is enabled
   AND (g_crossbg_enabled = 'Y' -- get CrossBG multiple per recs
        OR
        (g_crossbg_enabled = 'N' -- get multiple per recs only in this BG
         AND
         per.business_group_id = g_business_group_id
        )
       )
   AND national_identifier in
         (SELECT national_identifier
          FROM per_all_people_f per2
          WHERE person_id = p_person_id
--            AND p_effective_date BETWEEN per2.effective_start_date
--                                   AND per2.effective_end_date
         )
   AND asg.person_id = per.person_id
   AND p_effective_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
ORDER BY bizgrpcol ASC, person_id;

/*  SELECT DISTINCT asg.assignment_id                      assignment_id
--        ,asg.effective_start_date               start_date
--        ,asg.effective_end_date                 effective_end_date
    FROM per_all_assignments_f asg
   WHERE asg.person_id = p_person_id
     AND asg.assignment_id <> p_primary_assignment_id
     AND ( ( nvl(p_effective_date,g_pension_year_start_date)
                              BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date )
          OR
           ( -- Must have started on or after pension year start date
             asg.effective_start_date >= nvl(p_effective_date,g_pension_year_start_date)
             AND
             -- must have started within the reporting period
             asg.effective_start_date <= g_effective_run_date
           )
         )
--   ORDER BY asg.effective_start_date ASC
   ; -- effective first then future rows
*/
TYPE t_sec_asgs_type IS TABLE OF csr_sec_assignments%ROWTYPE
  INDEX BY BINARY_INTEGER;

-- Added for bugfix 3803760:FTSUPPLY
g_tab_sec_asgs t_sec_asgs_type;

--
-- Effective and future assignment details
--
  -- Bugfix 3073562:GAP1:GAP2
  --  1 Added default null to p_effective_date
  --  2 Added business_group_id to select list
  -- Bugfix 3073562:GAP6
  --  1 Added report_asg and secondary_assignment_id to select list
  -- Bugfix 3641851:CBF1
  --  Added teacher_start_date to select list
  CURSOR csr_asg_details_up -- effective first then future rows
   (p_assignment_id     NUMBER
   ,p_effective_date    DATE  DEFAULT NULL  -- Effective Teaching Start Date
   ) IS
  SELECT asg.person_id                          person_id
        ,asg.assignment_id                      assignment_id
        ,asg.business_group_id                  business_group_id
        ,asg.effective_start_date               start_date
        ,asg.effective_end_date                 effective_end_date
        ,asg.creation_date                      creation_date
        ,asg.location_id                        location_id
        ,NVL(asg.employment_category,'FT')      asg_emp_cat_cd
        ,'F'                                    ext_emp_cat_cd
        ,'0000'                                 estb_number
        ,'   '                                  tp_safeguarded_grade
        ,asg.assignment_status_type_id          status_type_id
        ,'                              '       status_type
        ,to_date('01/01/0001','dd/mm/yyyy')     leaver_date
        ,to_date('01/01/0001','dd/mm/yyyy')     restarter_date
        ,'Y'                                    report_asg
        ,asg.assignment_id                      secondary_assignment_id
        ,asg.effective_start_date               teacher_start_date
        -- added for compatibility with tp4. csr_asg_details.
        ,0                                      tp_sf_spinal_point_id
    FROM per_all_assignments_f asg

   WHERE asg.assignment_id = p_assignment_id
     AND ( ( nvl(p_effective_date,g_pension_year_start_date)
                              BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date )
          OR
           ( asg.effective_start_date > nvl(p_effective_date,g_pension_year_start_date) )
         )
   ORDER BY asg.effective_start_date ASC; -- effective first then future rows

--
-- Effective and history of assignment details
--
  -- Bugfix 3073562:GAP1:GAP2
  --  1 Added default null to p_effective_date
  --  2 Added business_group_id to select list
  -- Bugfix 3073562:GAP6
  --  1 Added report_asg and secondary_assignment_id to select list
  -- Bugfix 3641851:CBF1
  --  Added teacher_start_date to select list
  CURSOR csr_asg_details_dn -- effective first then history rows
   (p_assignment_id     NUMBER
   ,p_effective_date    DATE
   ) IS
  SELECT asg.person_id                          person_id
        ,asg.assignment_id                      assignment_id
        ,asg.business_group_id                  business_group_id
        ,asg.effective_start_date               start_date
        ,asg.effective_end_date                 effective_end_date
        ,asg.creation_date                      creation_date
        ,asg.location_id                        location_id
        ,NVL(asg.employment_category,'FT')      asg_emp_cat_cd
        ,'F'                                    ext_emp_cat_cd
        ,'0000'                                 estb_number
        ,'   '                                  tp_safeguarded_grade
        ,asg.assignment_status_type_id          status_type_id
        ,'                              '       status_type
        ,to_date('01/01/0001','dd/mm/yyyy')     leaver_date
        ,to_date('01/01/0001','dd/mm/yyyy')     restarter_date
        ,'Y'                                    report_asg
        ,asg.assignment_id                      secondary_assignment_id
        ,asg.effective_start_date               teacher_start_date
        -- added for compatibility with tp4. csrasg_details.
        ,0                                      tp_sf_spinal_point_id
    FROM per_all_assignments_f asg
   WHERE asg.assignment_id = p_assignment_id
     AND ( ( nvl(p_effective_date,g_pension_year_start_date)
                              BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date )
          OR
           ( asg.effective_end_date < nvl(p_effective_date,g_effective_run_date) )
         )
   ORDER BY asg.effective_start_date DESC; -- effective first then history rows

TYPE t_ext_asg_details_type IS TABLE OF csr_asg_details_dn%ROWTYPE
  INDEX BY BINARY_INTEGER;

  g_ext_asg_details t_ext_asg_details_type;



--
-- csr_pqp_asg_attributes_up
--
-- Bugfix 2551059, added column tp_safeguarded_grade_id
--
   CURSOR csr_pqp_asg_attributes_up -- up
     (p_assignment_id   NUMBER
     ,p_effective_date  DATE DEFAULT NULL
     ) IS
   SELECT eaat.assignment_attribute_id  assignment_attribute_id
         ,eaat.assignment_id            assignment_id
         ,eaat.effective_start_date     effective_start_date
         ,eaat.effective_end_date       effective_end_date
         ,eaat.tp_is_teacher            tp_is_teacher
         ,eaat.tp_safeguarded_grade     tp_safeguarded_grade
         ,eaat.tp_safeguarded_grade_id  tp_safeguarded_grade_id
         ,eaat.tp_safeguarded_rate_type     tp_safeguarded_rate_type
         ,eaat.tp_safeguarded_rate_id       tp_safeguarded_rate_id
         ,eaat.tp_safeguarded_spinal_point_id     tp_safeguarded_spinal_point_id
         ,eaat.tp_elected_pension       tp_elected_pension
         ,eaat.tp_fast_track            tp_fast_track
         ,eaat.creation_date            creation_date
     FROM pqp_assignment_attributes_f eaat -- effective aat
    WHERE eaat.assignment_id = p_assignment_id
      AND ( -- retrieve the effective row
            (NVL(p_effective_date,g_pension_year_start_date)
              BETWEEN eaat.effective_start_date
                 AND eaat.effective_end_date
            )
            OR -- any future rows
            (eaat.effective_start_date > NVL(p_effective_date,g_effective_date)
            )
          )
     ORDER BY eaat.effective_start_date ASC; -- effective first

  TYPE t_ext_asg_attributes_type IS TABLE OF csr_pqp_asg_attributes_up%ROWTYPE
  INDEX BY BINARY_INTEGER;

  g_ext_asg_attributes t_ext_asg_attributes_type;

--
Type t_udt_element_rec Is Record
      ( allowance_code   varchar2(1)
       ,element_name     varchar2(80)
       ,input_value_name varchar2(30)
       );
--
Type t_udt_tab Is Table of t_udt_element_rec Index by binary_integer;
--
g_udt_element_LondAll t_udt_tab;
g_udt_element_SpcAll  t_udt_tab;
--
-- added for 5743209
  TYPE r_allowance_eles IS RECORD
      (element_type_id            NUMBER
      ,salary_scale_code          VARCHAR2(1)
      ,element_type_extra_info_id NUMBER -- RET : added for changes in
                                         -- fetch_allow_eles_frm_udt for
                                         -- retention allowance rate calculations
      );

  TYPE t_allowance_eles IS TABLE OF r_allowance_eles
  INDEX BY BINARY_INTEGER;

  g_tab_lon_aln_eles t_allowance_eles;
  g_tab_spl_aln_eles t_allowance_eles;

  g_spl_all_grd_src varchar2(1);
  g_lon_all_grd_src varchar2(1);


Type t_udt_rec Is record (
 column_name  pay_user_columns.user_column_name%TYPE,
 row_name     pay_user_rows_f.row_low_range_or_name%TYPE,
 matrix_value pay_user_column_instances_f.value%TYPE,
 start_date   date,
 end_date     date);
--

Type t_udt_array is table of t_udt_rec Index by Binary_Integer;
g_udt_rec          t_udt_array;

--
-- c_multiper Gets multi persons records for the same NI no.
--
  CURSOR c_multiper
                (p_person_id            NUMBER
                ,p_effective_start_date DATE
                ,p_effective_end_date   DATE
                ,p_assignment_id        NUMBER DEFAULT NULL
                ) IS
  SELECT per.person_id
        ,per.national_identifier
        ,per.business_group_id
        ,asg.assignment_id assignment_id
        ,NVL(asg.employment_category,'FT') asg_emp_cat_cd
    FROM per_all_people_f per, per_all_assignments_f asg
   WHERE per.person_id = p_person_id
     AND asg.assignment_id <> p_assignment_id
     AND asg.assignment_type ='E'
     --AND p_effective_date BETWEEN per.effective_start_date
       --                       AND per.effective_end_date
       AND (
           (per.effective_start_date BETWEEN p_effective_start_date
                                         AND p_effective_end_date
            ) OR
            ( p_effective_start_date BETWEEN per.effective_start_date
                                         AND per.effective_end_date
            )
          )
     AND (g_crossbg_enabled = 'Y' -- get CrossBG multiple per recs
          OR
          (g_crossbg_enabled = 'N' -- get multiple per recs only in this BG
           AND
           per.business_group_id = g_business_group_id
          )
         )
     AND asg.person_id = per.person_id
     --AND p_effective_date BETWEEN asg.effective_start_date
     --                       AND asg.effective_end_date
     AND (
           (asg.effective_start_date BETWEEN p_effective_start_date
                                         AND p_effective_end_date
            ) OR
           ( p_effective_start_date BETWEEN asg.effective_start_date
                                        AND asg.effective_end_date
           )
         )
  UNION
  SELECT per.person_id
        ,per.national_identifier
        ,per.business_group_id
        ,asg.assignment_id assignment_id
        ,NVL(asg.employment_category,'FT') asg_emp_cat_cd
    FROM per_all_people_f per, per_all_assignments_f asg
   WHERE per.person_id <> p_person_id
    -- AND p_effective_date BETWEEN per.effective_start_date
      --                        AND per.effective_end_date
     AND (
           (per.effective_start_date BETWEEN p_effective_start_date
                                         AND p_effective_end_date
            ) OR
            ( p_effective_start_date BETWEEN per.effective_start_date
                                         AND per.effective_end_date
            )
          )
     AND (g_crossbg_enabled = 'Y' -- get CrossBG multiple per recs
          OR
          (g_crossbg_enabled = 'N' -- get multiple per recs only in this BG
           AND
           per.business_group_id = g_business_group_id
          )
         )
     AND national_identifier IN -- changed from = to IN as the query
                                -- return multiple records, in case there are
                                --  date track updates on person record.
           (SELECT national_identifier
            FROM per_all_people_f per2
            WHERE person_id = p_person_id
              --AND p_effective_date BETWEEN per2.effective_start_date
                --                       AND per2.effective_end_date
             AND (
                    (per2.effective_start_date BETWEEN p_effective_start_date
                                                  AND p_effective_end_date
                     ) OR
                    ( p_effective_start_date BETWEEN per2.effective_start_date
                                                 AND per2.effective_end_date
                     )
                   )
             )
     AND asg.person_id = per.person_id
     AND asg.assignment_type ='E'
    -- AND p_effective_date BETWEEN asg.effective_start_date
      --                        AND asg.effective_end_date ;
      AND (
           (asg.effective_start_date BETWEEN p_effective_start_date
                                         AND p_effective_end_date
            ) OR
           ( p_effective_start_date BETWEEN asg.effective_start_date
                                        AND asg.effective_end_date
           )
         ) ;

TYPE typ_multiper IS TABLE OF c_multiper%ROWTYPE
  INDEX BY BINARY_INTEGER;




--
-- Global values
  Type t_number is table of number
  index by binary_integer;

  Type t_varchar is table of varchar2(2000)
  index by binary_integer;

  g_other_allowance   t_number;
  g_annual_rate       t_number;
  g_abs_bal_type_id   t_number;
  g_sal_bal_type_id   t_number;
  g_cl_bal_type_id    t_number;
  -- 4336613 : OSLA_3A : OSLA balance type id
  g_osla_bal_type_id   t_number;
  g_osla_cl_bal_type_id t_number;
  g_gtc_bal_type_id   t_number;
  -- 4336613 : changed to a table of numbers, indexed by balance type ids
  g_def_bal_id         t_number;

-- Cursor to retrieve rate_id

  cursor csr_ele_rate_id (c_rate_name varchar2
                         ,c_rate_type varchar2) is
  select rate_id
    from pay_rates
  where  upper(name) = upper(c_rate_name)
    and  rate_type   = decode(c_rate_type,'GR','G',c_rate_type);

  -- Cursor to retrieve rate_id from pqp_assignment_attributes_f

  cursor csr_paa_rate_id (c_assignment_id  number
                         ,c_effective_date date) is
  select tp_safeguarded_grade
        ,tp_safeguarded_rate_id
	 -- added safeguarded rate type column for new logic for
	 -- calculating the safeguarded salary scale check.
	,tp_safeguarded_rate_type
        ,assignment_attribute_id
    from pqp_assignment_attributes_f
  where  assignment_id = c_assignment_id
    and  c_effective_date between effective_start_date
                            and effective_end_date;

  -- Cursor to retrieve grade rate value

  -- Bugfix : 2551059, Date : 20/09/2002
  --   Changed cursor to join with tp_safeguarded_grade_id
  --   Also, effectiveness check on paa was missing, added it.
  cursor csr_grade_rate (c_attribute_id   number
                        ,c_effective_date date) is
  select to_number(pgr.value)
    from pqp_assignment_attributes_f paa
        ,pay_grade_rules_f           pgr
  where  paa.assignment_attribute_id  = c_attribute_id
    and  pgr.grade_or_spinal_point_id = paa.tp_safeguarded_grade_id
    and  pgr.rate_id                  = paa.tp_safeguarded_rate_id
    and c_effective_date between pgr.effective_start_date
                           and pgr.effective_end_date
    and c_effective_date between paa.effective_start_date
                           and paa.effective_end_date;

  -- Cursor to retrieve scale rate value

  -- Idendified prob during Bugfix : 2551059, Date : 20/09/2002
  --   Changed cursor, added effectiveness check on paa, it was missing
  cursor csr_scale_rate (c_attribute_id   number
                        ,c_effective_date date) is
  select to_number(pgr.value)
    from pqp_assignment_attributes_f  paa
        ,pay_grade_rules_f            pgr
  where  paa.assignment_attribute_id  = c_attribute_id
    and  pgr.rate_id                  = paa.tp_safeguarded_rate_id
    and  pgr.grade_or_spinal_point_id = paa.tp_safeguarded_spinal_point_id
    and  c_effective_date between pgr.effective_start_date
                            and pgr.effective_end_date
    and  c_effective_date between paa.effective_start_date
                            and paa.effective_end_date;

  -- Cursor to retrieve element attribution info

  cursor csr_element_set (c_name  varchar2
                         ,c_eff_date DATE
                         ,c_business_group_id NUMBER DEFAULT NULL
                         ) is
  select eei2.element_type_extra_info_id
        ,eei1.element_type_id
    from pay_element_type_extra_info eei1
        ,pay_element_type_extra_info eei2
        ,hr_lookups hrl
        ,pay_element_types_f petf
  where  hrl.lookup_type       = 'PQP_RATE_TYPE'
    and  hrl.meaning           = c_name
    and  eei1.eei_information1 = hrl.lookup_code
    and  eei1.information_type = 'PQP_UK_RATE_TYPE'
    and  eei1.element_type_id  = eei2.element_type_id
    and  eei2.information_type = 'PQP_UK_ELEMENT_ATTRIBUTION'
    and  petf.element_type_id = eei1.element_type_id
    and  c_eff_date BETWEEN petf.effective_start_date
                       AND petf.effective_end_date
    and  (
          (petf.business_group_id IS NOT NULL
           AND
           petf.business_group_id = nvl(c_business_group_id, g_business_group_id)
          )
          OR
          (petf.business_group_id IS NULL
           AND
           petf.legislation_code = g_legislation_code
          )
          OR
          (petf.business_group_id IS NULL
           AND
           petf.legislation_code IS NULL
          )
         );

  -- Cursor to retrieve end_dates from per_time_periods

  Cursor csr_get_end_date
    (c_assignment_id         number
    ,c_effective_start_date  date
    ,c_effective_end_date    date) is
  select distinct(ptp.end_date) end_date
    from per_time_periods       ptp
        ,pay_payroll_actions    ppa
        ,pay_assignment_actions paa
  where  ptp.time_period_id    = ppa.time_period_id
    and  ppa.payroll_action_id = paa.payroll_action_id
    and  ppa.effective_date between c_effective_start_date
                              and c_effective_end_date
    and  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
    and  paa.assignment_id     = c_assignment_id
  order by ptp.end_date;


  /* bugfix 9445720 */
  -- Previouly this cursor was not giving correct results when payroll has an off set
    Cursor csr_get_pre_end_date
    (c_assignment_id         number
    ,c_effective_start_date  date
    ,c_effective_end_date    date) is
  select distinct(ptp.end_date) end_date
    from per_time_periods       ptp
        ,pay_payroll_actions    ppa
        ,pay_assignment_actions paa
  where  ptp.time_period_id    = ppa.time_period_id
    and  ppa.payroll_action_id = paa.payroll_action_id
  --  and  ppa.effective_date between c_effective_start_date
  --                            and c_effective_end_date
    and  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
    and  paa.assignment_id     = c_assignment_id
    and  c_effective_start_date between ptp.start_date and ptp.end_date
  order by ptp.end_date;

  -- Cursor to get balance type id for a balance

  Cursor csr_get_pay_bal_id
    (c_balance_name      varchar2
    ,c_business_group_id number
    ) is
  select balance_type_id, legislation_code -- 4336613 : added leg_code
    from pay_balance_types
  where balance_name     = c_balance_name
    and (
         (business_group_id IS NOT NULL AND
          business_group_id = NVL(c_business_group_id, g_business_group_id)
         )
         OR
         (business_group_id IS NULL AND
          legislation_code = g_legislation_code
         )
         OR
         (business_group_id IS NULL AND
          legislation_code IS NULL
         )
        );

  -- Cursor to get element type ids from balance

  Cursor csr_get_pay_ele_ids_from_bal
    (c_balance_type_id      number
    ,c_effective_date       date
    ,c_business_group_id    number
    ) is
  select pet.element_type_id element_type_id
        ,piv.input_value_id  input_value_id --Vibhor : PTS
    from pay_element_types_f pet
        ,pay_input_values_f  piv
        ,pay_balance_feeds_f pbf
  where  pet.element_type_id   = piv.element_type_id
    and  pet.business_group_id = NVL(c_business_group_id, g_business_group_id)
    and  piv.input_value_id    = pbf.input_value_id
    and  pbf.balance_type_id   = c_balance_type_id
    and  ((c_effective_date between pbf.effective_start_date
                               and pbf.effective_end_date)
          or
          c_effective_date <= pbf.effective_end_date
         );

  type t_ele_ids_from_bal is table of csr_get_pay_ele_ids_from_bal%rowtype
  index by binary_integer;

  g_tab_abs_ele_ids  t_ele_ids_from_bal;
  -- Bug 3015917 : Adding this as we need to cache PET Ids for Sal Balance
  g_tab_sal_ele_ids  t_ele_ids_from_bal;

  --4336613 : OSLA_3A : added for OSLA information
  g_tab_osla_ele_ids t_ele_ids_from_bal;

  g_tab_cl_ele_ids  t_ele_ids_from_bal;

  g_tab_osla_cl_ele_ids t_ele_ids_from_bal;

  g_tab_gtc_ele_ids  t_ele_ids_from_bal;
  -- Cursor to get element entries information

-- As element type id is available as a new column in
-- pay_element_entries_f table from HR_FP G onwards
-- we can fetch element type id from this table directly
-- so modified this cursor as a part of Bug fix 3163458

   Cursor csr_get_eet_info
     (c_assignment_id        number
     ,c_effective_start_date date
     ,c_effective_end_date   date
     ) is
   select pel.element_type_id
         ,pee.element_entry_id
     from pay_element_entries_f pee
         ,pay_element_links_f   pel
   where  pee.assignment_id = c_assignment_id
     and  (pee.effective_start_date between c_effective_start_date
                                      and c_effective_end_date
           or
           pee.effective_end_date between c_effective_start_date
                                    and c_effective_end_date
           or
           c_effective_start_date between pee.effective_start_date
                                    and pee.effective_end_date
           or
           c_effective_end_date between pee.effective_start_date
                                  and pee.effective_end_date
          )
     and  pel.element_link_id = pee.element_link_id
   order by pee.effective_start_date;


  -- Cursor to retrieve input value id

  Cursor csr_get_iv_info
    (c_element_type_id  number
    ,c_input_value_name varchar2
    ) is
  select input_value_id
    from pay_input_values_f
  where  element_type_id = c_element_type_id
    and  name            = c_input_value_name;

  -- Cursor to get value from element entry values table

  Cursor csr_get_eev_info
    (c_element_entry_id     number
    ,c_input_value_id       number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select screen_entry_value
        ,effective_start_date
        ,effective_end_date
    from pay_element_entry_values_f pee
  where  pee.element_entry_id = c_element_entry_id
    and  pee.input_value_id   = c_input_value_id
    and  (pee.effective_start_date between c_effective_start_date
                                     and c_effective_end_date
          or
          pee.effective_end_date between c_effective_start_date
                                   and c_effective_end_date
          or
          c_effective_start_date between pee.effective_start_date
                                   and pee.effective_end_date
          or
          c_effective_end_date between pee.effective_start_date
                                 and pee.effective_end_date
         )
  order by pee.effective_start_date;

  -- Cursor to get eev info for date

  Cursor csr_get_eev_info_date
    (c_element_entry_id     number
    ,c_input_value_id       number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select screen_entry_value
        ,effective_start_date
        ,effective_end_date
    from pay_element_entry_values_f pee
  where  pee.element_entry_id     = c_element_entry_id
    and  pee.input_value_id       = c_input_value_id
    and  pee.effective_start_date = c_effective_start_date
    and  pee.effective_end_date   = c_effective_end_date;

--
-- csr_element_entries
--

 CURSOR csr_element_entries(p_assignment_id      IN NUMBER
                           ,p_effective_date     IN DATE
                           ,p_element_type_id    IN NUMBER ) IS
 SELECT   pee.element_entry_id
    FROM  pay_element_entries_f pee
         ,pay_element_links_f   pel
   WHERE  pee.assignment_id   = p_assignment_id
     AND  pel.element_link_id = pee.element_link_id
     AND  pel.element_type_id = p_element_type_id
     AND  ((p_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
           )
           OR
           (pee.effective_start_date BETWEEN p_effective_date
                                         AND g_effective_run_date
           )
          )
     AND  ((p_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date

           )
           OR
           (pel.effective_start_date BETWEEN p_effective_date
                                         AND g_effective_run_date
           )
          );

-- Cursor to fetch the record if of the details record, but not the hidden one
-- WARNING : This works only if there is one displayed detail record.
-- Do we need to raise an error if there are 2 diplayed detail records??
-- If yes, then Fetch ... , check .. and raise error
-- Alternatively, modify the cursor to return the required id by querying on name.
CURSOR csr_ext_rcd_id(p_hide_flag       IN VARCHAR2
                     ,p_rcd_type_cd     IN VARCHAR2
                     ) IS
SELECT rcd.ext_rcd_id
FROM ben_ext_rcd rcd
    ,ben_ext_rcd_in_file RinF
    ,ben_ext_dfn dfn
WHERE dfn.ext_dfn_id = ben_ext_thread.g_ext_dfn_id
  AND RinF.ext_file_id = dfn.ext_file_id
  AND RinF.hide_flag = p_hide_flag
  AND RinF.ext_rcd_id = rcd.ext_rcd_id
  AND rcd.rcd_type_cd = p_rcd_type_cd;

-- Cursor to fetch the details record results
CURSOR csr_rslt_dtl(p_person_id    IN NUMBER
                   ,p_ext_rslt_id  IN NUMBER
                   ) IS
SELECT *
  FROM ben_ext_rslt_dtl dtl
 WHERE dtl.ext_rslt_id = p_ext_rslt_id
   AND dtl.person_id = p_person_id
   AND dtl.ext_rcd_id = g_ext_dtl_rcd_id;

-- Cursor to check the new line of service.
CURSOR csr_chk_los_change(p_prev_new_rec IN csr_rslt_dtl%ROWTYPE
                          ,p_new_rec     IN csr_rslt_dtl%ROWTYPE
			 ) IS
SELECT 0
  FROM dual
  WHERE (p_prev_new_rec.val_10 = p_new_rec.val_10 OR (p_prev_new_rec.val_10 is null and p_new_rec.val_10 is null))
    AND (p_prev_new_rec.val_11 = p_new_rec.val_11 OR (p_prev_new_rec.val_11 is null and p_new_rec.val_11 is null))
    AND (p_prev_new_rec.val_12 = p_new_rec.val_12 OR (p_prev_new_rec.val_12 is null and p_new_rec.val_12 is null))
    AND (p_prev_new_rec.val_15 = p_new_rec.val_15 OR (p_prev_new_rec.val_15 is null and p_new_rec.val_15 is null))
    AND (p_prev_new_rec.val_17 = p_new_rec.val_17 OR (p_prev_new_rec.val_17 is null and p_new_rec.val_17 is null))
    AND (p_prev_new_rec.val_20 = p_new_rec.val_20 OR (p_prev_new_rec.val_20 is null and p_new_rec.val_20 is null))
    AND (p_prev_new_rec.val_21 = p_new_rec.val_21 OR (p_prev_new_rec.val_21 is null and p_new_rec.val_21 is null))
    AND (p_prev_new_rec.val_22 = p_new_rec.val_22 OR (p_prev_new_rec.val_22 is null and p_new_rec.val_22 is null))
    AND (p_prev_new_rec.val_23 = p_new_rec.val_23 OR (p_prev_new_rec.val_23 is null and p_new_rec.val_23 is null))
    AND (p_prev_new_rec.val_24 = p_new_rec.val_24 OR (p_prev_new_rec.val_24 is null and p_new_rec.val_24 is null))
    AND (p_prev_new_rec.val_27 = p_new_rec.val_27 OR (p_prev_new_rec.val_27 is null and p_new_rec.val_27 is null));


-- This cursor returns multiple person data and master BG data
-- for cross BG reporting
-- If p_record_type :
--  a) M - Master Bg Id
--  b) X - Cross BG reporting National Identifier Data
CURSOR csr_multiproc_data(p_record_type         VARCHAR2
                         ,p_national_identifier VARCHAR2 DEFAULT NULL
                         -- Bugfix 3671727:ENH1:ENH2 Added p_lea_number and
                         --     p_ext_dfn_id param
                         ,p_lea_number          VARCHAR2 DEFAULT NULL
                         ,p_ext_dfn_id          NUMBER DEFAULT NULL
                         ) IS
SELECT *
FROM pqp_ext_cross_person_records emd
WHERE emd.record_type = p_record_type
  AND (p_national_identifier IS NULL
       OR
       (p_national_identifier IS NOT NULL
        AND
        emd.national_identifier = p_national_identifier
       )
      )
  AND emd.ext_dfn_id = nvl(p_ext_dfn_id, ben_ext_thread.g_ext_dfn_id) --ENH3
  AND emd.lea_number = nvl(p_lea_number, g_lea_number);               --ENH3


-- This cursor returns all BGs which have the p_lea_number
/*CURSOR csr_all_business_groups(p_lea_number IN VARCHAR2
                              ,p_business_group_id IN NUMBER DEFAULT NULL
                              ) IS
SELECT hoi1.organization_id business_group_id -- this is not BG id...
      ,hoi1.org_information1 lea_number
      ,hoi1.org_information2 lea_name
      ,nvl(hoi1.org_information3,'N') CrossBG_Enabled
      ,0                              Request_Id
      ,' '                            Status
  FROM hr_organization_information hoi1
 WHERE hoi1.organization_id <> nvl(p_business_group_id, g_business_group_id)
   AND hoi1.org_information_context = 'PQP_GB_EDU_AUTH_LEA_INFO'
   AND hoi1.org_information1 = p_lea_number
   AND nvl(hoi1.org_information3,'N') = 'Y' -- Enabled for CrossBG reporting
   AND EXISTS
        (SELECT 1
         FROM hr_organization_information hoi2
         WHERE hoi2.org_information_context='CLASS'
           AND hoi2.organization_id = hoi1.organization_id
           AND hoi2.org_information1 = 'HR_BG' -- is a BG
           AND hoi2.org_information2 = 'Y' -- Enabled
        );*/

-- This cursor returns all BGs which have the p_lea_number
-- ENH1 : Multiple LEAs with in a BG.
-- Changed as now the education authority can be at
-- org level, and need not be an HR_BG.
CURSOR csr_all_business_groups(p_lea_number IN VARCHAR2
                              ,p_business_group_id IN NUMBER DEFAULT NULL
                              ) IS
-- removing the lea numebr and lea name from the select clause
-- as these are not used any where in the code and
-- and we need a distinct list of BG's...
SELECT DISTINCT hou.business_group_id business_group_id
    -- ,hoi1.org_information1    lea_number
    -- ,hoi1.org_information2    lea_name
      ,nvl(hoi1.org_information3,'N') CrossBG_Enabled
      ,0                              Request_Id  --used in ext process
      ,' '                            Status      --used in ext process
  FROM hr_organization_information hoi1
      ,hr_organization_units hou --added this to join org's with the respective BG.
 WHERE hoi1.organization_id          = hou.organization_id
   AND hou.business_group_id        <> nvl(p_business_group_id, g_business_group_id)
   AND hoi1.org_information_context  = 'PQP_GB_EDU_AUTH_LEA_INFO'
   AND hoi1.org_information1         = p_lea_number
   AND nvl(hoi1.org_information3,'N')= 'Y'; -- Enabled for CrossBG reporting

TYPE t_all_bgs_type IS TABLE OF csr_all_business_groups%ROWTYPE
  INDEX BY BINARY_INTEGER;

g_lea_business_groups   t_all_bgs_type;


Cursor Get_Matrix_Value ( c_user_table_name  in varchar
                         ,c_user_column_name in varchar
                         ,c_user_row_name    in varchar
                         ,c_effective_date   in date
                         ,c_business_group_id in number DEFAULT NULL
                         ) Is
 select  put.user_table_name
        ,puc.user_column_name
        ,pur.row_low_range_or_name
        ,pci.value
        ,pci.user_column_instance_id
 from    pay_user_tables             put
        ,pay_user_columns            puc
        ,pay_user_rows_f             pur
        ,pay_user_column_instances_f pci
 where   put.user_table_name       = c_user_table_name
   and   puc.user_table_id         = put.user_table_id
   and   puc.user_column_name      = c_user_column_name
   and   pur.row_low_range_or_name = c_user_row_name
   and   pur.user_table_id         = put.user_table_id
   and   pci.user_column_id        = puc.user_column_id
   and   pci.user_row_id           = pur.user_row_id
   and   Trunc(c_effective_date) between pur.effective_start_date
                                     and pur.effective_end_date
   and   Trunc(c_effective_date) between pci.effective_start_date
                                     and pci.effective_end_date
    and ((pci.business_group_id is null and pci.legislation_code is null)
                      or (pci.legislation_code is not null
                            and pci.legislation_code = 'GB')
                      or (pci.business_group_id is not null
                            and pci.business_group_id = NVL(c_business_group_id, g_business_group_id))
        )
 order by put.user_table_name, puc.user_column_name, pur.display_sequence;

--
-- Cursor to get details for a given request id
--
CURSOR csr_request_dets(p_request_id IN NUMBER DEFAULT NULL) IS
SELECT req.parent_request_id
      ,req.concurrent_program_id
      ,con.concurrent_program_name
  FROM fnd_concurrent_requests req, fnd_concurrent_programs con
 WHERE request_id = nvl(p_request_id, fnd_global.conc_request_id)
  AND con.concurrent_program_id = req.concurrent_program_id;

-- PTS: BUG 4135481: Added for Part Time salary Paid changes
-- The cursor gets the assignment action id
-- for the assignment for the Date Earned
CURSOR csr_get_asg_act_id
       ( p_assignment_id NUMBER
        ,p_date_earned   DATE
       )
IS
 SELECT fnd_number.canonical_to_number(substr(min(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
        --paa.assignment_action_id
   FROM pay_assignment_actions paa
       ,pay_payroll_actions    ppa
  WHERE paa.assignment_id        = p_assignment_id
    AND ppa.action_status        = 'C'
    AND paa.action_status        = 'C'
    AND paa.payroll_action_id    = ppa.payroll_action_id
    AND ppa.date_earned          = p_date_earned
    AND ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
    AND (paa.source_action_id IS NOT NULL OR ppa.action_type in ('B','I'));
--    AND paa.source_action_id IS NULL ;
-- Following are the codes - meanings
-- B-Balance adjustment, I-Balance Initialization,
-- Q-QuickPay Run, R-Run, V-Reversal



-- PTS: BUG 4135481: Added for Part Time salary Paid changes
-- Get run Result values for the
-- prorated payments for the assignment
CURSOR csr_get_run_result_value
       (  p_start_date      DATE
         ,p_end_date        DATE
         ,p_element_type_id NUMBER
         ,p_input_value_id  NUMBER
         ,p_asg_act_id      NUMBER
       )
  IS
  SELECT to_number(prrv.result_value) result
         ,prr.start_date
         ,prr.end_date
    FROM pay_run_result_values prrv
        ,pay_run_results       prr
   WHERE prrv.run_result_id       = prr.run_result_id
     AND prr.assignment_action_id = p_asg_act_id
     AND prr.start_date          >= p_start_date
     AND prr.end_date            <= p_end_date
     AND prr.element_type_id      = p_element_type_id
     AND prrv.input_value_id      = p_input_value_id ;


-- Get run Result values for the
-- payments for the assignment
   CURSOR csr_get_run_results
       (  p_start_date      DATE
         ,p_end_date        DATE
         ,p_asg_act_id      NUMBER
	 ,p_balance_type_id NUMBER
       )
  IS
 SELECT fnd_number.canonical_to_number(TARGET.result_value) result
            ,nvl(RR.start_date,p_start_date) start_date
            ,nvl(RR.end_date,p_end_date) end_date
            ,FEED.scale scale
	    ,RR.run_result_id
   FROM             pay_assignment_actions   BAL_ASSACT
 		  ,pay_payroll_actions      BACT
 		  ,pay_assignment_actions   ASSACT
 		  ,pay_payroll_actions      PACT
 		  ,pay_run_results          RR
 		  ,pay_run_result_values    TARGET
 		  ,pay_balance_feeds_f     FEED
 		  ,per_time_periods         PTP
 WHERE  BAL_ASSACT.assignment_action_id = p_asg_act_id
  and   BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
  and   FEED.balance_type_id    = p_balance_type_id + DECODE(TARGET.input_value_id,null,0,0) -- 10510987
  and   FEED.input_value_id     = TARGET.input_value_id
  and   nvl(TARGET.result_value,'0') <> '0'
  and   TARGET.run_result_id    = RR.run_result_id
  and   RR.assignment_action_id = ASSACT.assignment_action_id
  and   ASSACT.payroll_action_id = PACT.payroll_action_id
  and   PACT.effective_date between FEED.effective_start_date and FEED.effective_end_date
  and   PACT.action_type <> 'V'
  and   RR.status in ('P','PA')
  and   ASSACT.action_sequence >= BAL_ASSACT.action_sequence
  and   ASSACT.assignment_id = BAL_ASSACT.assignment_id
  and   PACT.time_period_id = ptp.time_period_id
  and   nvl(RR.start_date,ptp.start_date) >= p_start_date
  and   nvl(RR.end_date,ptp.end_date) <= p_end_date
  and  FEED.effective_start_date < p_end_date
  and  p_start_date < FEED.effective_end_date;

  -- PTS:BUG 4135481: Added for Part Time salary Paid changes
  -- get the previous payroll period payroll perios date to
  -- get the starting point of the next payroll period.

  CURSOR csr_get_previous_payroll_date
        (p_assignment_id        NUMBER
        ,p_effective_start_date DATE
        )
  IS
  SELECT max(ptp.end_date) previous_payroll_date
    FROM per_time_periods       ptp
        ,per_all_assignments_f  paaf
   WHERE ptp.payroll_id     = paaf.payroll_id
     AND paaf.assignment_id = p_assignment_id
     AND ptp.end_date      < p_effective_start_date ;


-- PTS: BUG 4135481: Added for Part Time salary Paid changes
-- get the next payroll period payroll date to
-- get the date_earned.
CURSOR csr_get_next_payroll_date
         (p_assignment_id NUMBER
         ,p_effective_start_date  DATE
         )
  IS
  SELECT min(ptp.end_date) next_payroll_date
    FROM per_time_periods       ptp
        ,per_all_assignments_f  paaf
   WHERE ptp.payroll_id     = paaf.payroll_id
     AND paaf.assignment_id = p_assignment_id
     AND ptp.end_date      >= p_effective_start_date ;

-- TERM_LSP:BUG 4135481: added a cursor to fetch
-- Last Standard Process Date and Final Close Date
-- for terminated employees

 CURSOR csr_get_termination_details
            (p_assignment_id         NUMBER
            ,p_effective_end_date    DATE
            ,p_business_group_id     NUMBER
	    )
 IS
 SELECT paa.assignment_id               assignment_id
       ,pps.date_start		              start_date
       ,pps.actual_termination_date     actual_termination_date
       ,pps.last_standard_process_date  last_standard_process_date
       ,pps.final_process_date          final_process_date
 FROM   per_periods_of_service_v pps
       ,per_all_assignments_f    paa
 WHERE  paa.person_id               = pps.person_id
   AND paa.assignment_id            = p_assignment_id
   AND paa.effective_end_date       = pps.actual_termination_date
   AND pps.date_start              <= p_effective_end_date
   AND pps.business_group_id        = nvl(p_business_group_id,g_business_group_id)
   -- following condn no longer mandatory as LSP date and Final Close Date can be left Null.
   --AND pps.actual_termination_date <> pps.last_standard_process_date
   AND pps.actual_termination_date  = p_effective_end_date
 ORDER BY pps.date_start DESC;

--
  -- RETRO:BUG: 4135481
-- cursor gets the defined balance id
CURSOR csr_get_defined_balance_id
( p_balance_type_id   NUMBER
 ,p_dimension_name    VARCHAR2
 ,p_business_group_id NUMBER DEFAULT NULL
)IS

SELECT defined_balance_id
FROM   pay_defined_balances    pdb
      ,pay_balance_dimensions  pbd
WHERE  pdb.balance_type_id = p_balance_type_id
  AND  dimension_name      = p_dimension_name --'_RGT_ASG_RETROELE_RUN'
  AND  pbd.balance_dimension_id = pdb.balance_dimension_id
  AND (
        ( pdb.business_group_id IS NOT NULL AND
          pdb.business_group_id = NVL(p_business_group_id, g_business_group_id)
        )
        OR
        ( pdb.business_group_id IS NULL AND
          pdb.legislation_code = g_legislation_code
        )
        OR
        ( pdb.business_group_id IS NULL AND
          pdb.legislation_code IS NULL
        )
      )
  AND (
        ( pbd.business_group_id IS NOT NULL AND
          pbd.business_group_id = NVL(p_business_group_id, g_business_group_id)
        )
        OR
        ( pbd.business_group_id IS NULL AND
          pbd.legislation_code = g_legislation_code
        )
        OR
        ( pbd.business_group_id IS NULL AND
          pbd.legislation_code IS NULL
        )
      ) ;

-- RETRO:BUG: 4135481
-- Get the assignment action id for master assignment actions
CURSOR csr_get_asg_act_id_retro
( p_assignment_id        NUMBER
 ,p_effective_start_date DATE
 ,p_effective_end_date   DATE
)IS

SELECT fnd_number.canonical_to_number(substr(min(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
      ,ppa.date_earned
  FROM pay_assignment_actions paa
      ,pay_payroll_actions    ppa
 WHERE paa.assignment_id        = p_assignment_id
   AND ppa.action_status        = 'C'
   AND paa.action_status        = 'C'
   AND paa.payroll_action_id    = ppa.payroll_action_id
   AND ppa.action_type IN ('R', 'Q', 'I', 'B')
   AND ppa.date_earned BETWEEN p_effective_start_date
                           AND p_effective_end_date
   AND (paa.source_action_id IS NOT NULL OR ppa.action_type in ('B','I'))
 GROUP BY ppa.date_earned
ORDER BY fnd_number.canonical_to_number(substr(min(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) ;

-- Get the assignment action id for child assignment actions
CURSOR csr_get_asg_act_id_dw
( p_assignment_id        NUMBER
 ,p_effective_start_date DATE
 ,p_effective_end_date   DATE
)
IS
SELECT fnd_number.canonical_to_number(substr(min(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
      ,ppa.date_earned
  FROM pay_assignment_actions paa
      ,pay_payroll_actions    ppa
 WHERE paa.assignment_id        = p_assignment_id
   AND ppa.action_status        = 'C'
   AND paa.action_status        = 'C'
   AND paa.payroll_action_id    = ppa.payroll_action_id
   AND ppa.action_type IN ('R', 'Q', 'I', 'B')
   AND ppa.date_earned >= p_effective_start_date
   AND (paa.source_action_id IS NOT NULL OR ppa.action_type in ('B','I'))
 GROUP BY ppa.date_earned
ORDER BY ppa.date_earned ;

-- RETRO:BUG: 4135481
-- The following cursor gets the date earned
-- for any retro entries for an assignment
-- over a period
CURSOR csr_get_date_earned_retro
(p_assignment_id  NUMBER
,p_start_date     DATE
,p_end_date       DATE
)
IS
SELECT  peef.element_entry_id
       ,peef.element_type_id
       ,peef.effective_start_date
       ,peef.effective_end_date
       ,peef.creator_type
       ,peef.source_start_date
       ,peef.source_end_date
       ,ppa.date_earned
  FROM  pay_entry_process_details perd
       ,pay_assignment_actions    paa
       ,pay_payroll_actions       ppa
       ,pay_element_entries_f     peef
  WHERE peef.assignment_id        = p_assignment_id
    AND perd.element_entry_id     = peef.element_entry_id
    AND perd.source_asg_action_id = paa.assignment_action_id
    AND paa.payroll_action_id     = ppa.payroll_action_id
    AND peef.creator_type IN ('RR', 'EE') -- Retro entries
    AND ppa.date_earned BETWEEN p_start_date
                            AND p_end_date ;

--
-- Functions and Procedures
--
Procedure Get_Elements_Frm_UDT (p_assignment_id    IN  NUMBER
                               );

--
Procedure Get_Udt_Data ( p_udt_name       in varchar2
                        ,p_effective_date in date );

--
-- Added param business_group_id

Function Get_Udt_Value( p_table_name        in varchar2 Default Null
                       ,p_column_name       in varchar2
                       ,p_row_name          in varchar2
                       ,p_effective_date    in date Default Null
                       ,p_business_group_id in NUMBER DEFAULT NULL)
Return varchar2;

--
  function process_element (p_assignment_id    in   number
                           ,p_calculation_date in   date
                           ,p_rate_name        in   varchar2
                           ,p_rate_type        in   varchar2
                           ,p_from_time_dim    in   varchar2
                           ,p_to_time_dim      in   varchar2
                           ,p_fte              in   varchar2
                           ,p_term_time_yes_no in   varchar2
                           )
    return number;

  --
  function rates_history (p_assignment_id    in     number
                         ,p_calculation_date in     date
                         ,p_rate_type_name   in     varchar2
                         ,p_fte              in     varchar2
                         ,p_to_time_dim      in     varchar2
                         ,p_safeguarded_yn   in     varchar2
                         ,p_rate             in out nocopy number)
    return number;

  --
  function calc_annual_sal_rate (p_assignment_id        in     number
                                ,p_calculation_date     in     date
                                ,p_safeguarded_yn       in     varchar2
                                ,p_fte                  in     varchar2
                                ,p_to_time_dim          in     varchar2
                                ,p_rate                 in out nocopy number
                                ,p_effective_start_date in     date
                                ,p_effective_end_date   in     date
                                )
    return number;

  --
  function get_safeguarded_info (p_assignment_id  in    number
                                ,p_effective_date in    date
                                )
    return varchar2;

  --
  function get_annual_sal_rate_date (p_assignment_id        in     number
                                    ,p_effective_start_date in     date
                                    ,p_effective_end_date   in     date
                                    ,p_rate                 in out nocopy number
                                    )
    return number;

  --
  function calc_part_time_sal (p_assignment_id        in     number
                              ,p_effective_start_date in     date
                              ,p_effective_end_date   in     date
                              ,p_business_group_id    in     number
                              -- 4336613 : OSLA_3A : new params
                              ,p_sal_bal_type_id      IN     NUMBER DEFAULT NULL
                              ,p_cl_bal_type_id       IN     NUMBER DEFAULT NULL
                              ,p_tab_bal_ele_ids      IN     t_ele_ids_from_bal DEFAULT g_tab_sal_ele_ids
                              )
    return number;

  --
  function get_part_time_sal_date (p_assignment_id        in     number
                                  ,p_effective_start_date in    date
                                  ,p_effective_end_date   in    date
                                  )
    return number;

  --
  function calc_days_worked (p_assignment_id        in     number
                            ,p_effective_start_date in     date
                            ,p_effective_end_date   in     date
                            ,p_annual_sal_rate      in     number
                            )
    return number;

  --
  function get_pay_bal_id
    (p_balance_name      IN         VARCHAR2
    ,p_business_group_id IN         NUMBER
    ,p_legislation_code  OUT NOCOPY VARCHAR2 -- bug 4336613 : new parameter added
    )
    return number;

  --
  procedure get_pay_ele_ids_from_bal
    (p_assignment_id        in     number
    ,p_balance_type_id      in     number
    ,p_effective_date       in     date
    ,p_error_text           in     varchar2
    ,p_error_number         in     number
    ,p_business_group_id    in     number
    ,p_tab_ele_ids          out nocopy t_ele_ids_from_bal
    ,p_token                in varchar2 default null
    );

  --
  procedure get_eev_info (p_element_entry_id     in     number
                         ,p_input_value_id       in     number
                         ,p_effective_start_date in     date
                         ,p_effective_end_date   in     date
                         ,p_tab_eev_info         out nocopy csr_get_eev_info_date%rowtype
                         );

  --
  function get_days_absent (p_element_type_id      in     number
                           ,p_element_entry_id     in     number
                           ,p_effective_start_date in     date
                           ,p_effective_end_date   in     date
                           )
    return number;

  --
  function get_eet_info (p_assignment_id        in     number
                        ,p_tab_ele_ids          in     t_ele_ids_from_bal
                        ,p_effective_start_date in     date
                        ,p_effective_end_date   in     date
                        )
    return number;

  --
  function get_ft_days_excluded (p_assignment_id        in     number
                                ,p_effective_start_date in     date
                                ,p_effective_end_date   in     date
                                )
    return number;

  --
  function get_pt_days_excluded (p_assignment_id        in     number
                                ,p_effective_start_date in     date
                                ,p_effective_end_date   in     date
                                ,p_days                    out nocopy number
                                )
    return number;

  --
  -- Added a new param p_emp_cat_cd

  function get_days_excluded_date (p_assignment_id        in     number
                                  ,p_effective_start_date in     date
                                  ,p_effective_end_date   in     date
                                  ,p_emp_cat_cd           in     varchar2 default null
                                  ,p_days                 out nocopy number
                                  )
    return number;

--
Function Get_Translate_Asg_Emp_Cat_Code (p_asg_emp_cat_cd   in varchar2
                                        ,p_effective_date   in Date
                                        ,p_udt_column_name  in varchar2
                                        ,p_business_group_id IN NUMBER
                                        ) Return Varchar2;

--
Function Get_Special_ClassRule (p_assignment_id   in number
                               ,p_effective_date  in date)
Return varchar2 ;

--
Function Get_Allowance_Code   (p_assignment_id   in number
                              ,p_effective_date  in date
                              ,p_allowance_type  in varchar2 )
Return varchar2;

--
Function Get_Grade_Fasttrack_Info (p_assignment_id  in number
                                  ,p_effective_date in date)
Return char;

--
-- Criteria for Type 1 Periodic Leavers
--
  FUNCTION chk_tp1_criteria_periodic
    (p_business_group_id        IN      NUMBER  -- context
    ,p_effective_date           IN      DATE    -- context
    ,p_assignment_id            IN      NUMBER  -- context
    )
    RETURN VARCHAR2; -- Y or N

--
-- Criteria for Type 1 Annual
--
  FUNCTION chk_tp1_criteria_annual
    (p_business_group_id        IN      NUMBER  -- context
    ,p_effective_date           IN      DATE    -- context
    ,p_assignment_id            IN      NUMBER  -- context
    )
    RETURN VARCHAR2; -- Y or N
--
-- Start Date
--
  FUNCTION get_tp1_start_date
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- End Date
--
  FUNCTION get_tp1_end_date
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Withdrawal Confirmation
--
  FUNCTION get_tp1_withdrawal_conf
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Days Excluded
--
  FUNCTION get_tp1_days_excluded
    (p_assignment_id in     number
    ,p_days_excluded    out nocopy varchar2
    )
    RETURN number;

--
-- Annual Full-time Salary Rate
--
  FUNCTION get_tp1_annual_ft_sal_rate
    (p_assignment_id in     number
    ,p_annual_rate      out nocopy varchar2
    )
    RETURN number;
--
-- Part-time Salary Paid
--
  FUNCTION get_tp1_pt_sal_paid
    (p_assignment_id     IN      NUMBER
    ,p_part_time_sal        out nocopy  VARCHAR2
    )
    RETURN number;
--
-- Career Indicator
--
  FUNCTION get_tp1_career_indicator
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- London Allowance
--
  FUNCTION get_tp1_london_allowance
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Special Priority Allowance
--
  FUNCTION get_tp1_sp_allowance
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Special Class Addition (Part-time indicator)
--
  FUNCTION get_tp1_pt_contract_indicator
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Other Allowances
--
  FUNCTION get_tp1_other_allowances
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- Record Serial Number
--
  FUNCTION get_tp1_record_serial_number
    (p_assignment_id     IN      NUMBER
    )
    RETURN VARCHAR2;
--
-- set_pay_proc_events_to_process
--
PROCEDURE set_pay_proc_events_to_process
  (p_assignment_id    IN      NUMBER
  ,p_status           IN      VARCHAR2 DEFAULT 'P'
  ,p_start_date       IN      DATE     DEFAULT NULL
  ,p_end_date         IN      DATE     DEFAULT NULL
  );
--
-- set_pay_proc_events_to_process
-- Overloaded procedure, this one has an extra parameter p_element_entry_id
--
PROCEDURE set_pay_proc_events_to_process
            (p_assignment_id    IN      NUMBER
            ,p_element_entry_id IN      NUMBER
            ,p_status           IN      VARCHAR2 DEFAULT 'P'
            ,p_start_date       IN      DATE     DEFAULT NULL
            ,p_end_date         IN      DATE     DEFAULT NULL
            );

--
-- Extended Criteria to generate new lines of service
--
FUNCTION create_service_lines
  (p_assignment_id            IN      NUMBER  -- context
  ) RETURN VARCHAR2;
--
-- type1_post_proc_rule
--
FUNCTION type1_post_proc_rule
                (p_ext_rslt_id  IN ben_ext_rslt_dtl.ext_rslt_id%TYPE
                ) RETURN VARCHAR2;

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug
  (p_trace_message  IN     VARCHAR2
  ,p_trace_location IN     NUMBER   DEFAULT NULL
  );

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug_enter
  (p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_trace_on  IN VARCHAR2 DEFAULT NULL
  );

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE debug_exit
  (p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_trace_off IN VARCHAR2 DEFAULT NULL
  );

--
-- Added this function to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This function is for private use inside the package body only.
--
FUNCTION get_events(p_event_group               IN VARCHAR2
                   ,p_assignment_id             IN NUMBER
                   ,p_element_entry_id          IN NUMBER DEFAULT NULL
                   ,p_business_group_id         IN NUMBER DEFAULT NULL
                   ,p_start_date                IN DATE
                   ,p_end_date                  IN DATE
                   ,t_proration_dates           OUT NOCOPY pay_interpreter_pkg.t_proration_dates_table_type
                   ,t_proration_changes         OUT NOCOPY pay_interpreter_pkg.t_proration_type_table_type
                   ) RETURN NUMBER;

--
-- Added this procedure to the header as there was a GSCC
-- warning due to the use of DEFAULT values in body.
-- WARNING : This procedure is for private use inside the package body only.
--
PROCEDURE set_pay_process_events(p_grade_id      IN  NUMBER
                                 ,p_status       IN  VARCHAR2
                                 ,p_start_date   IN  DATE     DEFAULT NULL
                                 ,p_end_date     IN  DATE     DEFAULT NULL
                                 );

--
-- chk_grd_change_affects_asg
--
-- Bug 3015917 : This new function is used to chk if a grade rule
-- change event affects the assignment. This function is called
-- from the event qualifier : GB Grade Rule Change
--
FUNCTION chk_grd_change_affects_asg
                (p_assignment_id        IN NUMBER
                ,p_grade_rule_id        IN NUMBER
                ,p_effective_date       IN DATE
                ) RETURN BOOLEAN;

--
-- chk_report_assignment - overloaded
--
FUNCTION chk_report_assignment
    (p_assignment_id            IN  NUMBER
    -- Bugfix 3641851:CBF1 : Added new parameter effective date
    ,p_effective_date           IN  DATE DEFAULT NULL
    ,p_secondary_assignment_id  OUT NOCOPY NUMBER
    ) RETURN VARCHAR2;

--
-- chk_report_assignment - overloaded
--
FUNCTION chk_report_assignment
    (p_assignment_id            IN  NUMBER
    -- Bugfix 3641851:CBF1 : Added new parameter effective date
    ,p_effective_date           IN  DATE DEFAULT NULL
    ,p_report_assignment        OUT NOCOPY VARCHAR2
    ) RETURN NUMBER;

-- This procedure will find all BGs which have the same
-- LEA number and have been enabled for cross BG reporting
-- and store them in global collection
PROCEDURE store_cross_bg_details ;

--
-- chk_report_person
--
FUNCTION chk_report_person
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ) RETURN BOOLEAN ;

--
-- Check if the teacher's is a leaver
--
FUNCTION chk_is_teacher_a_leaver
  (p_business_group_id        IN      NUMBER
  ,p_effective_start_date     IN      DATE
  ,p_effective_end_date       IN      DATE
  ,p_assignment_id            IN      NUMBER
  ,p_leaver_date             OUT NOCOPY      DATE
  ) RETURN VARCHAR2 ;-- Y or N

--
-- Check if the leaver teacher is also a re-starter
--
FUNCTION chk_is_leaver_a_restarter
  (p_business_group_id        IN      NUMBER
  ,p_effective_start_date     IN      DATE
  ,p_effective_end_date       IN      DATE
  ,p_assignment_id            IN      NUMBER
  ,p_restarter_date          OUT NOCOPY      DATE
  ) RETURN VARCHAR2 ;-- Y or N

--
-- Check if the assignment satisfies the basic criteria
--
FUNCTION chk_has_tchr_elected_pension
  (p_business_group_id        IN      NUMBER  -- context
  ,p_effective_date           IN      DATE    -- context
  ,p_assignment_id            IN      NUMBER  -- context
  ,p_asg_details              OUT NOCOPY     csr_asg_details_up%ROWTYPE
  ,p_asg_attributes           OUT NOCOPY     csr_pqp_asg_attributes_up%ROWTYPE
  ) RETURN VARCHAR2 ;-- Y or N

PROCEDURE reset_proc_status;

PROCEDURE warn_anthr_tchr_asg (p_assignment_id IN NUMBER) ;

PROCEDURE store_leaver_restarter_dates (p_assignment_id IN NUMBER ) ;

FUNCTION get_all_secondary_asgs
   (p_primary_assignment_id     IN NUMBER
   ,p_effective_date            IN DATE
   ) RETURN t_sec_asgs_type ;

PROCEDURE sort_stored_events ;

FUNCTION chk_has_teacher_been_reported
   (p_person_id         IN NUMBER
   ,p_leaver_date          IN DATE
   ) RETURN VARCHAR2 ;

-- RET:BUG 4135481: Added for Retention Allowance changes.
FUNCTION get_tp1_retention_allow_rate
    (p_assignment_id in     number
    ,p_ret_allow      out nocopy varchar2
    )
    RETURN NUMBER;

-- RET:BUG 4135481:Added for Retention Allowance changes.
FUNCTION calc_tp1_retention_allow_rate
			(p_assignment_id        in     number
			,p_effective_start_date in     date
			,p_effective_end_date   in     date
			,p_rate                 in out nocopy number
			)
			RETURN NUMBER;


-- 4336613 : OSLA_3A : new function to compute grossed up OSLA payments
function get_grossed_osla_payments (p_assignment_id        in     number
                                   ,p_effective_start_date in     date
                                   ,p_effective_end_date   in     date
                                   ,p_business_group_id    in     number
                                    )
return number;

function get_gtc_payments (p_assignment_id        in     number
                                   ,p_effective_start_date in     date
                                   ,p_effective_end_date   in     date
                                   ,p_business_group_id    in     number
                                    )
return number;

CURSOR csr_get_dw_value(p_bal_type_id NUMBER,
                        p_assignment_action_id NUMBER,
                        p_start_date DATE,
                        p_end_date DATE
                       ) IS
SELECT  /*+ ORDERED */nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
/* Assignment with Date worked for Run */
     FROM          pay_assignment_actions   BAL_ASSACT
		  ,pay_payroll_actions      BACT
		  ,pay_assignment_actions   ASSACT
		  ,pay_payroll_actions      PACT
		  ,pay_run_results          RR
		  ,pay_element_types_f pet
		  ,pay_input_values_f       process_iv
		  ,pay_run_result_values    process
		  ,pay_run_result_values    TARGET
		  ,pay_balance_feeds_f     FEED
        where  BAL_ASSACT.assignment_action_id = p_assignment_action_id
        and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
        and    FEED.balance_type_id    = p_bal_type_id + DECODE(TARGET.input_value_id,null,0,0)
        and    FEED.input_value_id     = TARGET.input_value_id
	and    nvl(TARGET.result_value,'0') <> '0'
        and    TARGET.run_result_id    = RR.run_result_id
        and    RR.assignment_action_id = ASSACT.assignment_action_id
        and    RR.element_type_id = pet.element_type_id
        and    pet.element_type_id = process_iv.element_type_id
        and    ASSACT.payroll_action_id = PACT.payroll_action_id
        and    PACT.effective_date between
                  FEED.effective_start_date and FEED.effective_end_date
	and    PACT.action_type <> 'V'
        and    RR.status in ('P','PA')
        and    ASSACT.action_sequence >= BAL_ASSACT.action_sequence
        and    ASSACT.assignment_id = BAL_ASSACT.assignment_id
	and    process.run_result_id = RR.run_result_id
	and    process.input_value_id = process_iv.input_value_id
	and    process_iv.name = 'Date Worked'
	and    PACT.effective_date between
	          process_iv.effective_start_date and process_iv.effective_end_date
        and   PACT.effective_date between
	          pet.effective_start_date and pet.effective_end_date
	and    fnd_date.canonical_to_date(process.result_value) between
	                     p_start_date and p_end_date;


CURSOR csr_get_supp_ded(p_bal_type_id NUMBER,
                        p_assignment_id NUMBER,
                        p_start_date DATE,
                        p_end_date DATE
                       ) IS
SELECT  /*+ ORDERED */nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
/* Assignment with Date worked for Run */
     FROM          pay_assignment_actions   ASSACT
		  ,pay_payroll_actions      PACT
		  ,pay_run_results          RR
		  ,pay_input_values_f       process_iv
		  ,pay_run_result_values    process
		  ,pay_run_result_values    TARGET
		  ,pay_balance_feeds_f     FEED
        where  FEED.balance_type_id    = p_bal_type_id + DECODE(TARGET.input_value_id,null,0,0)
        and    FEED.input_value_id     = TARGET.input_value_id
	and    nvl(TARGET.result_value,'0') <> '0'
        and    TARGET.run_result_id    = RR.run_result_id
        and    RR.assignment_action_id = ASSACT.assignment_action_id
        and    ASSACT.payroll_action_id = PACT.payroll_action_id
        and    PACT.effective_date between
                  FEED.effective_start_date and FEED.effective_end_date
	and    PACT.action_type <> 'V'
        and    RR.status in ('P','PA')
        and    PACT.action_type in ('R','Q','I','B')
        and    ASSACT.assignment_id = p_assignment_id
        and    PACT.date_earned between p_start_date and p_end_date
	and    process.run_result_id = RR.run_result_id
	and    process.input_value_id = process_iv.input_value_id
	and    process_iv.name = 'Date Worked'
	and    PACT.effective_date between
	          process_iv.effective_start_date and process_iv.effective_end_date
	and    fnd_date.canonical_to_date(process.result_value) not between
	                     p_start_date and p_end_date;

CURSOR csr_is_supp_claim(p_run_result_id NUMBER, -- changed for bug 7278398
                         p_start_date DATE,
                         p_end_date DATE
                         ) IS
SELECT /*+ ORDERED */ 'N'
  FROM pay_run_results prr,
       pay_element_types_f pet,
       pay_input_values_f process_iv,
       pay_run_result_values process
 WHERE prr.run_result_id = p_run_result_id
   and prr.run_result_id = process.run_result_id
   and prr.element_type_id = pet.element_type_id
   and pet.element_type_id = process_iv.element_type_id
   AND process_iv.name = 'Date Worked'
   AND process_iv.input_value_id = process.input_value_id
   and (process_iv.effective_start_date between p_start_date
                                      and p_end_date
           or
           process_iv.effective_end_date between p_start_date
                                    and p_end_date
           or
           p_start_date between process_iv.effective_start_date
                                    and process_iv.effective_end_date
           or
           p_end_date between process_iv.effective_start_date
                                  and process_iv.effective_end_date
         )
   and process_iv.effective_start_date between pet.effective_start_date and pet.effective_end_date
   AND fnd_date.canonical_to_date(process.result_value) not between
	                     p_start_date and p_end_date;


-- added for 5743209
PROCEDURE fetch_allow_eles_frm_udt
               (p_assignment_id  IN NUMBER
               ,p_effective_date IN DATE
               );
Function Get_Allowance_Code_New ( p_assignment_id   in number
                             ,p_effective_date  in date
                             ,p_allowance_type  in varchar2 ) Return varchar2;



END pqp_gb_t1_pension_extracts;

/
