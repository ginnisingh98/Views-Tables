--------------------------------------------------------
--  DDL for Package PQP_GB_OMP_DAILY_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_OMP_DAILY_ABSENCES" AUTHID CURRENT_USER AS
/* $Header: pqgbdomp.pkh 120.0.12000000.1 2007/01/16 03:44:16 appldev noship $ */



-- Through out this Package wherever any parameter/variable if defined as
-- p_entitlements or l_entitlements will be used to store or pass a persons
-- Entitltments Band Wise.
-- Variable/Parameter p_absences_taken_to_date stores the entitlememts
-- used up
--Variable/paramter p_entitlements_remaining stores the entitlements
-- that are avaialable at that point of time Band wise



-- Record to store the EIT Information of the Plan.
    TYPE rec_plan_information  IS RECORD
      ( plan_name
        pay_element_type_extra_info.eei_information1%TYPE
       ,Absence_Entitlement_Days_Type
        pay_element_type_extra_info.eei_information9%TYPE
       ,Absence_Entitlement_Parameters
        pay_element_type_extra_info.eei_information11%TYPE
       ,Absence_Entitlement_Holidays
        pay_element_type_extra_info.eei_information12%TYPE
       ,Daily_Rate_Divisor_Type
        pay_element_type_extra_info.eei_information13%TYPE
       ,Daily_Rate_Divisor_Duration
        pay_element_type_extra_info.eei_information15%TYPE
       ,default_work_pattern
        pay_element_type_extra_info.eei_information18%TYPE
       ,calendar_rules_list
        pay_element_type_extra_info.eei_information27%TYPE
       );



    --  Cursor to get the Absence Information.

      CURSOR csr_absence_info ( p_absence_id IN NUMBER ) IS
      SELECT paa.date_start
            ,paa.date_end
        FROM per_absence_attendances paa
       WHERE paa.absence_attendance_id = p_absence_id ;

-- The Cursor gets the used Entitlements Band wise
      CURSOR csr_get_band_bal ( p_assignment_id     IN NUMBER
                             ,p_business_group_id IN NUMBER
                             ,p_absence_id        IN NUMBER
                             ,p_lookup_type       IN VARCHAR2
                             ,p_pl_typ_id         IN NUMBER) IS
       SELECT pgda.level_of_entitlement
             ,SUM (pgda.duration) consumed
             ,SUM (pgda.duration_in_hours) consumed_in_hours
         FROM pqp_gap_daily_absences pgda
             ,pqp_gap_absence_plans pgap
             ,per_absence_attendances paa
             ,ben_pl_f bpf
        WHERE pgda.gap_absence_plan_id   = pgap.gap_absence_plan_id
          AND pgap.absence_attendance_id = paa.absence_attendance_id
          AND pgap.assignment_id         = p_assignment_id
              AND paa.absence_attendance_id  = p_absence_id
          AND bpf.pl_id                  = pgap.pl_id
          AND bpf.pl_typ_id              = p_pl_typ_id
          AND bpf.business_group_id      = p_business_group_id
          AND bpf.business_group_id      = paa.business_group_id
          AND ( pgda.level_of_entitlement <> 'NOT'
                AND pgda.level_of_entitlement <> 'NOBAND'
                AND pgda.level_of_entitlement NOT IN
                      ( SELECT lookup_code
                          FROM hr_lookups --fnd_common_lookups
			  -- changed to hr_lookups for bug 3780751
                         WHERE lookup_type = p_lookup_type )
                 )
         GROUP BY level_of_entitlement
         ORDER BY level_of_entitlement ;

    -- Cursor to get the Part Days Information

    CURSOR c_part_days ( p_absence_id  IN NUMBER
                        ,p_lookup_type IN VARCHAR2 ) IS
    SELECT NVL(abs_information1,1) part_st_dt
          ,NVL(abs_information2,1) Part_end_dt
      FROM per_absence_attendances
     WHERE abs_information_category = p_lookup_type
       AND absence_attendance_id    = p_absence_id ;



     CURSOR c_get_abs_id ( p_plan_id    IN NUMBER
                          ,p_absence_id IN NUMBER ) IS
     SELECT pgap.gap_absence_plan_id abs_id
           ,pgap.object_version_number
       FROM pqp_gap_absence_plans pgap
      WHERE pgap.absence_attendance_id = p_absence_id
        AND pgap.pl_id                 = p_plan_id ;

-------------debug------------------------------
   PROCEDURE debug
    (p_trace_message  IN     VARCHAR2,
     p_trace_location IN     NUMBER   DEFAULT NULL
    ) ;

-------------debug_enter-----------------------
   PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2 DEFAULT NULL,
     p_trace_on  IN VARCHAR2 DEFAULT NULL
    ) ;

-------------debug_exit-----------------------
   PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2 DEFAULT NULL,
     p_trace_off IN VARCHAR2 DEFAULT NULL
    ) ;

-------------create_daily_absences--------------
  PROCEDURE create_absence_plan_details -- create_daily_absences
       (p_assignment_id     IN  NUMBER
       ,p_person_id         IN  NUMBER
       ,p_business_group_id IN  NUMBER
       ,p_absence_id        IN  NUMBER
       ,p_absence_date_start IN DATE
       ,p_absence_date_end   IN DATE
       ,p_pl_id             IN  NUMBER
       ,p_pl_typ_id         IN  NUMBER
       ,p_element_type_id   IN  NUMBER
       ,p_create_start_date IN  DATE
       ,p_create_end_date   IN  DATE
       ,p_output_type       IN  ff_exec.outputs_t
       ,p_error_code        OUT NOCOPY NUMBER
       ,p_message           OUT NOCOPY VARCHAR2
        ) ;

---------------get_plan_extra_info_n_cache_it----------------
   PROCEDURE get_plan_extra_info_n_cache_it(
        p_pl_id       IN  NUMBER
       ,p_plan_information IN OUT NOCOPY rec_plan_information
       ,p_pl_typ_id   IN  NUMBER
       ,p_error_code  OUT NOCOPY NUMBER
       ,p_message     OUT NOCOPY VARCHAR2
       ) ;
-----------get_entitlement_info-------------------
   PROCEDURE get_entitlement_info
       (
     p_business_group_id          IN  NUMBER
    ,p_effective_date             IN  DATE
    ,p_assignment_id              IN  NUMBER
    ,p_pl_id                      IN  NUMBER -- added RR
    ,p_entitlement_tab_id         IN  NUMBER
    ,p_absence_id                 IN  NUMBER
    ,p_absence_ent_uom            IN  VARCHAR2
    ,p_start_date                 IN  DATE
    ,p_benefits_length_of_service IN  NUMBER
    ,p_entitlements               IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
    ,p_error_code                 OUT NOCOPY NUMBER
    ,p_message                    OUT NOCOPY VARCHAR2
     ) ;
---------------get_entitlements_consumed--------------
PROCEDURE get_entitlements_consumed
   (
    p_assignment_id     IN  NUMBER
   ,p_business_group_id IN  NUMBER
   ,p_effective_date    IN  DATE
   ,p_absence_id        IN  NUMBER
   ,p_pl_typ_id         IN  NUMBER
   ,p_entitlements      IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_absences_taken_to_date IN  OUT NOCOPY pqp_absval_pkg.t_entitlements
   ,p_lookup_type       IN  VARCHAR2
   ,p_error_code        OUT NOCOPY NUMBER
   ,p_message           OUT NOCOPY VARCHAR2
   ) ;
---------update_absence_plan_details  --------------
PROCEDURE update_absence_plan_details
      ( p_assignment_id      IN NUMBER
       ,p_person_id          IN NUMBER
       ,p_business_group_id  IN NUMBER
       ,p_absence_id         IN NUMBER
       ,p_absence_date_start IN DATE
       ,p_absence_date_end   IN DATE
       ,p_pl_id              IN NUMBER
       ,p_pl_typ_id          IN NUMBER
       ,p_element_type_id    IN NUMBER
       ,p_update_start_date  IN date
       ,p_update_end_date    IN date
       ,p_output_type        IN ff_exec.outputs_t
       ,p_error_code         OUT NOCOPY NUMBER
       ,p_message            OUT NOCOPY VARCHAR2 ) ;

-----------------------get_entitlements_remaining----------------
PROCEDURE get_entitlements_remaining
       (p_entitlements     IN pqp_absval_pkg.t_entitlements
       ,p_absences_taken_to_date IN pqp_absval_pkg.t_entitlements
       ,p_entitlement_UOM         IN VARCHAR2
       ,p_entitlements_remaining  IN OUT NOCOPY pqp_absval_pkg.t_entitlements
       ,p_error_code    OUT NOCOPY NUMBER
       ,p_message       OUT NOCOPY VARCHAR2 ) ;
-----------------------get_entitlement_balance----------------
PROCEDURE get_entitlement_balance (
        p_assignment_id          IN NUMBER
       ,p_business_group_id      IN NUMBER
       ,p_pl_typ_id              IN NUMBER
       ,p_effective_date         IN DATE
       ,p_absences_taken_to_date IN OUT NOCOPY pqp_absval_pkg.t_entitlements
       ,p_error_code             OUT NOCOPY NUMBER
       ,p_message                OUT NOCOPY VARCHAR2
        ) ;

END pqp_gb_omp_daily_absences ;

 

/
