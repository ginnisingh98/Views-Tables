--------------------------------------------------------
--  DDL for Package PQP_ABSVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ABSVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: pqabsbal.pkh 120.6.12000000.1 2007/01/16 03:29:39 appldev noship $ */

  TYPE rec_plan_information IS RECORD(
    plan_name                      pay_element_type_extra_info.eei_information1%TYPE
   ,scheme_period_type             pay_element_type_extra_info.eei_information3%TYPE
   ,scheme_period_duration         pay_element_type_extra_info.eei_information4%TYPE
   ,scheme_period_uom              pay_element_type_extra_info.eei_information5%TYPE
   ,scheme_period_start            pay_element_type_extra_info.eei_information6%TYPE
   ,scheme_period_end              pay_element_type_extra_info.eei_information7%TYPE
   ,absence_days_type              pay_element_type_extra_info.eei_information8%TYPE
   ,entitlement_parameters_UDT_id  pay_element_type_extra_info.eei_information9%TYPE
   ,entitlement_calendar_UDT_id    pay_element_type_extra_info.eei_information10%TYPE
   ,daily_rate_UOM                 pay_element_type_extra_info.eei_information11%TYPE
   ,daily_rate_earnings_period     pay_element_type_extra_info.eei_information12%TYPE
   ,daily_rate_divisor             pay_element_type_extra_info.eei_information13%TYPE
   ,element_type                   pay_element_type_extra_info.eei_information14%TYPE
   ,absence_pay_info_src_pay_comp  pay_element_type_extra_info.eei_information15%TYPE
   ,primary_absence_info_ele       pay_element_type_extra_info.eei_information16%TYPE
   ,default_work_pattern_name      pay_element_type_extra_info.eei_information17%TYPE
   ,absence_types_list_name        pay_element_type_extra_info.eei_information18%TYPE
   ,absence_overlap_rule           pay_element_type_extra_info.eei_information26%TYPE
   ,entitlement_band_names_list    pay_element_type_extra_info.eei_information28%TYPE
   ,calendar_rule_names_list       pay_element_type_extra_info.eei_information27%TYPE
   ,absence_pay_plan_category      pay_element_type_extra_info.eei_information30%TYPE -- Added for CS
   ,dual_rolling_period_duration   pay_element_type_extra_info.eei_information20%TYPE
   ,dual_rolling_period_uom        pay_element_type_extra_info.eei_information21%TYPE
-- Adding for LG/PT
   ,track_part_timers              pay_element_type_extra_info.eei_information21%TYPE
   ,absence_schedule_work_pattern  pay_element_type_extra_info.eei_information21%TYPE
   ,plan_types_to_extend_period    pay_element_type_extra_info.eei_information21%TYPE
  );

  TYPE r_entitlements
  IS RECORD(
    band                          VARCHAR2(30)
   ,meaning                       VARCHAR2(80)
   ,entitlement                   NUMBER
   ,duration                      NUMBER
   ,duration_in_hours             NUMBER
   ,duration_per_week             NUMBER
   -- LG/PT
   ,fte_hours                     NUMBER
  );

TYPE r_duration_summary
  IS RECORD(
    assignment_id           pqp_gap_duration_summary.assignment_id%type
   ,gap_absence_plan_id     pqp_gap_duration_summary.gap_absence_plan_id%type
   ,summary_type            pqp_gap_duration_summary.summary_type%type
   ,gap_level               pqp_gap_duration_summary.gap_level%type
   ,date_start              pqp_gap_duration_summary.date_start%type
   ,date_end                pqp_gap_duration_summary.date_end%type
   ,duration_in_days        pqp_gap_duration_summary.duration_in_days%type
   ,duration_in_hours       pqp_gap_duration_summary.duration_in_hours%type
   ,gap_duration_summary_id pqp_gap_duration_summary.gap_duration_summary_id%type
   ,object_version_number   pqp_gap_duration_summary.object_version_number%type
   ,action_type             VARCHAR2(2)
   );

TYPE r_absence_balance
  Is Record(
    gap_absence_plan_id           pqp_gap_duration_summary.gap_absence_plan_id%Type
   ,gap_level                     pqp_gap_duration_summary.gap_level%Type
   ,entitlement_granted           NUMBER(10,5)
   ,entitlement_used_to_date      NUMBER(10,5)
   ,entitlement_used_by_abs       NUMBER(10,5)
   ,entitlement_remaining         NUMBER(10,5)
   ,fte                           NUMBER(25,5)
   ,working_days_per_week         NUMBER(10,5)
   ,action_type                   VARCHAR2(2)
   );

TYPE r_gap_level
  IS RECORD(
    gap_level                VARCHAR2(100)
   ,gap_duration_summary_id  NUMBER(15,0)
   ,object_version_number    NUMBER(15,0)
   ,action_type              VARCHAR2(2)
    );


  TYPE t_entitlements IS TABLE OF r_entitlements
    INDEX BY BINARY_INTEGER;


  TYPE t_daily_absences IS TABLE OF pqp_gda_shd.g_rec_type
    INDEX BY BINARY_INTEGER;

 TYPE t_duration_summary IS TABLE OF r_duration_summary
    INDEX BY BINARY_INTEGER;

  TYPE t_absence_balance IS TABLE OF r_absence_balance
    INDEX BY BINARY_INTEGER;

  TYPE t_gap_level IS TABLE OF r_gap_level
    INDEX BY BINARY_INTEGER;

--
  CURSOR csr_absence_dates
    (p_absence_attendance_id IN NUMBER
    )
  IS
  SELECT paa.date_start
        ,paa.date_end
  FROM   per_absence_attendances paa
  WHERE  paa.absence_attendance_id = p_absence_attendance_id;
--
  CURSOR csr_gap_absence_plan
    (p_absence_attendance_id IN NUMBER
    ,p_pl_id                 IN NUMBER
    )
  IS
  SELECT gap.gap_absence_plan_id
        ,gap.last_gap_daily_absence_date
        ,gap.object_version_number
  FROM   pqp_gap_absence_plans gap
  WHERE  gap.absence_attendance_id = p_absence_attendance_id
    AND  gap.pl_id = p_pl_id;
--
  CURSOR csr_gap_daily_absences_exists
    (p_gap_absence_plan_id IN NUMBER
    )
  IS
  SELECT gda.gap_absence_plan_id
  FROM   pqp_gap_daily_absences gda
  WHERE  gda.gap_absence_plan_id = p_gap_absence_plan_id
    AND  ROWNUM < 2;
--
  CURSOR csr_first_entitled_day_of_band
    (p_gap_absence_plan_id   IN NUMBER
    ,p_level_of_entitlement  IN VARCHAR2
    )
  IS
  SELECT gda.absence_date
  FROM   pqp_gap_daily_absences gda
  WHERE  gda.gap_absence_plan_id = p_gap_absence_plan_id
    AND  gda.level_of_entitlement = p_level_of_entitlement
  ORDER BY gda.absence_date ASC;


--
-- the perf version of this query would be
-- query the table using gap_absence_plan_id
-- and absence_date between sot and eot
-- and rownum < 2
-- because these two columns are indexed
-- and by default Oracle always reads the index
-- from the ascending end it would return the
-- minimum date of a given level of ent
--
-- but this approach is not guranteed hence
-- use of ORDER BY asc
--




CURSOR csr_get_days_to_extend ( p_business_group_id NUMBER
                               ,p_assignment_id NUMBER
                               ,p_period_start_date DATE
                               ,p_period_end_date DATE
                               ,p_lookup_type VARCHAR2)
     IS
     SELECT SUM(
               DECODE(
                 SIGN(paa.date_end - p_period_end_date)
                ,1, p_period_end_date
                ,paa.date_end
               )
             - DECODE(
                 SIGN(paa.date_start - p_period_start_date)
                ,1, paa.date_start
                ,p_period_start_date
               )
             + 1
           ) cnt
    FROM   hr_lookups hrl
	  ,ben_pl_f bp
          ,per_absence_attendances paa
	  ,pqp_gap_absence_plans gap
    WHERE hrl.lookup_type = p_lookup_type --'PQP_GAP_PLAN_TYPES_TO_EXTEND'
          and  (p_period_start_date between
                NVL(hrl.start_date_active, p_period_start_date)
	        and NVL(hrl.end_date_active, p_period_end_date)
                OR
                p_period_end_date   between
                NVL(hrl.start_date_active, p_period_start_date)
                and NVL(hrl.end_date_active, p_period_end_date)
	       )
          and  bp.pl_typ_id = hrl.lookup_code
          and  paa.business_group_id = p_business_group_id
          and  (p_period_start_date between
                paa.date_start      and paa.date_end
	        OR
                p_period_end_date   between
                paa.date_start      and paa.date_end
                OR
                paa.date_end        between
                p_period_start_date and p_period_end_date
	       )

	  --and  (paa.date_start      between
          --      p_period_start_date and p_period_end_date
	  --      OR
          --      paa.date_end        between
          --      p_period_start_date and p_period_end_date
	  --      )
          and  gap.pl_id = bp.pl_id
          and  gap.absence_attendance_id = paa.absence_attendance_id
          and  gap.assignment_id = p_assignment_id ;



    CURSOR csr_get_wp ( p_assignment_id NUMBER
                       ,p_business_group_id NUMBER
                       ,p_effective_date   DATE)
    IS
    SELECT work_pattern
    FROM   pqp_assignment_attributes_f paa
    WHERE  assignment_id     = p_assignment_id
    AND  business_group_id = p_business_group_id
    AND  p_effective_date BETWEEN paa.effective_start_date
                              AND paa.effective_end_date ;

    CURSOR csr_sum_level_entit_duration
          (p_gap_absence_id           IN NUMBER
          ,p_level_of_entitlement     IN VARCHAR
          ,p_absence_date             IN DATE
          )
   IS
  SELECT SUM(gda.duration)
  FROM   pqp_gap_daily_absences gda
        ,pqp_gap_absence_plans plans
  WHERE gda.gap_absence_plan_id = plans.gap_absence_plan_id
  AND   plans.absence_attendance_id    = p_gap_absence_id
  AND   gda.level_of_entitlement = p_level_of_entitlement
  AND   gda.absence_date <= p_absence_date ;

 FUNCTION get_scheme_start_date
   (p_assignment_id             IN       NUMBER
   ,p_scheme_period_type        IN       VARCHAR2
   ,p_scheme_period_duration    IN       VARCHAR2
   ,p_scheme_period_uom         IN       VARCHAR2
   ,p_fixed_year_start_date     IN       VARCHAR2
   ,p_balance_effective_date    IN       DATE
   ) RETURN DATE;

  PROCEDURE get_plan_extra_info_n_cache_it
   (p_pl_id                     IN            NUMBER
   ,p_plan_information          IN OUT NOCOPY rec_plan_information
   ,p_business_group_id         IN NUMBER
   ,p_assignment_id             IN NUMBER
   ,p_effective_date            IN DATE
   );

  PROCEDURE get_param_value
   (p_output_type               IN       ff_exec.outputs_t
   ,p_name                      IN       VARCHAR2
   ,p_datatype                  OUT NOCOPY VARCHAR2
   ,p_value                     OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_absence_part_days
   (p_absence_id                IN            NUMBER
   ,p_part_start_day               OUT NOCOPY NUMBER
   ,p_part_end_day                 OUT NOCOPY NUMBER
   ,p_part_day_UOM                 OUT NOCOPY VARCHAR2
   );

  FUNCTION get_adjusted_scheme_start_date
   (p_assignment_id              IN            NUMBER
   ,p_scheme_start_date          IN            DATE
   ,p_pl_typ_id                  IN            NUMBER
   ,p_scheme_period_overlap_rule IN            VARCHAR2
  ) RETURN DATE;

  PROCEDURE get_absences_taken_to_date
   (p_assignment_id              IN            NUMBER
--   ,p_absence_date_start         IN            DATE
   ,p_effective_date             IN            DATE
   ,p_business_group_id          IN NUMBER DEFAULT NULL
   -- Added p_business_group_id for CS
   ,p_pl_typ_id                  IN            NUMBER
   ,p_scheme_period_overlap_rule IN            VARCHAR2
   ,p_scheme_period_type         IN            VARCHAR2
   ,p_scheme_period_duration     IN            VARCHAR2
   ,p_scheme_period_uom          IN            VARCHAR2
   ,p_scheme_period_start        IN            VARCHAR2
   ,p_entitlements               IN OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_absences_taken_to_date     IN OUT NOCOPY pqp_absval_pkg.t_entitlements -- Added for CS
   ,p_dualrolling_4_year         IN            BOOLEAN DEFAULT FALSE
   ,p_override_scheme_start_date IN            DATE    DEFAULT NULL
   ,p_plan_types_to_extend_period IN           VARCHAR2 DEFAULT NULL --LG/PT
   ,p_entitlement_uom             IN VARCHAR2 DEFAULT NULL
   ,p_default_wp                  IN VARCHAR2 DEFAULT NULL
   ,p_absence_schedule_wp         IN VARCHAR2 DEFAULT NULL
   ,p_track_part_timers           IN VARCHAR2 DEFAULT NULL
   ,p_absence_start_date          IN DATE
   );

-- PROCEDURE get_entitlements_remaining
--  (p_entitlements           IN            pqp_absval_pkg.t_entitlements
--  ,p_absences_taken_to_date IN            pqp_absval_pkg.t_entitlements
--  ,p_entitlement_UOM        IN            VARCHAR2
--  ,p_entitlements_remaining IN OUT NOCOPY pqp_absval_pkg.t_entitlements
-- LG/PT
--  ,p_track_part_timers      IN VARCHAR2 DEFAULT 'N'
--  );


PROCEDURE get_entitlements_remaining
    (p_assignment_id          IN NUMBER -- LG/PT
    ,p_effective_date         IN DATE   -- LG/PT
    ,p_entitlements           IN            pqp_absval_pkg.t_entitlements
    ,p_absences_taken_to_date IN            pqp_absval_pkg.t_entitlements
    ,p_entitlement_UOM        IN            VARCHAR2
    ,p_entitlements_remaining IN OUT NOCOPY pqp_absval_pkg.t_entitlements--t_ent_run_balance
    ,p_is_full_timer          IN BOOLEAN DEFAULT NULL
--    ,p_avg_working_days_assignment IN NUMBER --LG/PT
--    ,p_avg_working_days_standard  IN NUMBER -- LG/PT
--    ,p_message                   OUT NOCOPY VARCHAR2
-- LG/PT
--    ,p_track_part_timers      IN VARCHAR2 DEFAULT 'N'
    ) ;


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
   ,p_working_days_per_week     IN NUMBER DEFAULT NULL
   ,p_fte                       IN NUMBER DEFAULT 1 -- LG/PT
   ,p_override_work_pattern     IN VARCHAR2 DEFAULT NULL
   ,p_pl_id                     IN NUMBER DEFAULT NULL
   ,p_scheme_period_type        IN VARCHAR2 DEFAULT NULL
   ,p_is_assignment_wp          IN BOOLEAN
   );

  PROCEDURE write_daily_absences
   (p_daily_absences       IN pqp_absval_pkg.t_daily_absences
   ,p_gap_absence_plan_id  IN pqp_gap_absence_plans.gap_absence_plan_id%TYPE
   );

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
  );

  PROCEDURE delete_absence_plan_details
   (p_assignment_id             IN            NUMBER
   ,p_business_group_id         IN            NUMBER
   ,p_plan_id                   IN            NUMBER
   ,p_absence_id                IN            NUMBER
   ,p_delete_start_date         IN            DATE
   ,p_delete_end_date           IN            DATE
   ,p_error_code                   OUT NOCOPY NUMBER
   ,p_message                      OUT NOCOPY VARCHAR2
  );

  PROCEDURE update_absence_plan_details
   (p_assignment_id             IN            NUMBER
   ,p_person_id                 IN            NUMBER
   ,p_business_group_id         IN            NUMBER
   ,p_absence_id                IN            NUMBER
   ,p_absence_date_start        IN                 DATE
   ,p_absence_date_end          IN                 DATE
   ,p_pl_id                     IN            NUMBER
   ,p_pl_typ_id                 IN            NUMBER
   ,p_element_type_id           IN            NUMBER
   ,p_update_start_date         IN            DATE
   ,p_update_end_date           IN            DATE
   ,p_output_type               IN            ff_exec.outputs_t
   ,p_error_code                   OUT NOCOPY NUMBER
   ,p_message                      OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_absences_taken
    (p_assignment_id             IN       NUMBER
    ,p_pl_typ_id                 IN       NUMBER
    ,p_range_from_date           IN       DATE --not absence start and end dates
    ,p_range_to_date             IN       DATE --period for which sum is taken
    ,p_absences_taken            IN OUT NOCOPY pqp_absval_pkg.t_entitlements
--    ,p_message                   OUT NOCOPY VARCHAR2
   ) ;

------------------ For LG/PT
-- FUNCTION get_entitlements
--   (p_assignment_id             IN       NUMBER
--   ,p_business_group_id         IN       NUMBER
--   ,p_effective_date            IN       DATE
--   ,p_pl_id                     IN       NUMBER
--   ,p_entitlement_table_id      IN       NUMBER
--   ,p_benefits_length_of_service IN      NUMBER
--   ,p_band_entitlements         OUT NOCOPY pqp_absval_pkg.t_entitlements
--   ,p_entitlement_bands_list_name IN     VARCHAR2 DEFAULT
--      'PQP_GAP_ENTITLEMENT_BANDS'
--   ) RETURN NUMBER ;

FUNCTION get_assignment_work_pattern (
      p_business_group_id IN  NUMBER
     ,p_assignment_id     IN  NUMBER
     ,p_effective_date    IN  DATE
     ,p_default_wp        IN  VARCHAR2
     ,p_contract_wp       IN VARCHAR2
     ,p_is_assignment_wp  OUT NOCOPY BOOLEAN)
RETURN VARCHAR2 ;

FUNCTION get_average_days_per_week(
            p_business_group_id IN NUMBER
	   ,p_effective_date    IN DATE
	   ,p_work_pattern      IN VARCHAR2 )
RETURN NUMBER ;

FUNCTION get_absence_standard_ft_wp(
           p_business_group_id   IN  NUMBER
          ,p_assignment_id       IN  NUMBER
	  ,p_effective_date      IN  DATE
          ,p_absence_schedule_wp IN  VARCHAR2
          ,p_default_wp          IN  VARCHAR2
          ,p_entitlement_uom     IN  VARCHAR2
          ,p_contract_wp         OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 ;

FUNCTION get_contract_level_wp (
           p_business_group_id IN NUMBER
          ,p_assignment_id     IN NUMBER
          ,p_effective_date    IN DATE )
    RETURN VARCHAR2 ;

FUNCTION get_calendar_days_to_extend(
          p_period_start_date IN DATE
         ,p_period_end_date   IN DATE
	 ,p_assignment_id     IN NUMBER
	 ,p_business_group_id IN NUMBER
	 ,p_pl_typ_id         IN NUMBER
	 ,p_count_nopay_days  IN BOOLEAN
	 ,p_plan_types_lookup_type IN VARCHAR2
	 )
    RETURN NUMBER ;


PROCEDURE get_factors (
            p_business_group_id   IN NUMBER
	   ,p_effective_date      IN DATE
	   ,p_assignment_id       IN NUMBER
	   ,p_entitlement_uom     IN VARCHAR2
	   ,p_default_wp          IN VARCHAR2
	   ,p_absence_schedule_wp IN VARCHAR2
	   ,p_track_part_timers   IN VARCHAR2
	   ,p_current_factor      OUT NOCOPY NUMBER
	   ,p_ft_factor           OUT NOCOPY NUMBER
	   ,p_working_days_per_week OUT NOCOPY NUMBER
	   ,p_fte                   OUT NOCOPY NUMBER
	   ,p_FT_absence_wp         OUT NOCOPY VARCHAR2
	   ,p_FT_working_wp         OUT NOCOPY VARCHAR2
	   ,p_assignment_wp         OUT NOCOPY VARCHAR2
	   ,p_is_full_timer         OUT NOCOPY BOOLEAN
	   ,p_is_assignment_wp      OUT NOCOPY BOOLEAN
	   ) ;

PROCEDURE convert_entitlements
            ( p_entitlements   IN OUT NOCOPY pqp_absval_pkg.t_entitlements
	     ,p_current_factor IN NUMBER
             ,p_ft_factor      IN NUMBER
            ) ;




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
  );

------------------


END pqp_absval_pkg;

 

/
