--------------------------------------------------------
--  DDL for Package PQP_GB_CSS_DAILY_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_CSS_DAILY_ABSENCES" AUTHID CURRENT_USER AS
/* $Header: pqgbdcss.pkh 120.0 2005/05/29 01:49:05 appldev noship $ */



-- Through out this Package wherever any parameter/variable if defined as
-- p_entitlements or l_entitlements will be used to store or pass a persons
-- Entitltments Band Wise.
-- Variable/Parameter p_absences_taken_to_date stores the entitlememts
-- used up
--Variable/paramter p_entitlements_remaining stores the entitlements
-- that are avaialable at that point of time Band wise

     CURSOR csr_get_days_to_extend ( p_business_group_id NUMBER
                                    ,p_assignment_id NUMBER
				    ,p_rolling_start_date DATE
				    ,p_rolling_end_date DATE
				    ,p_lookup_type VARCHAR2)
     IS
     SELECT SUM(
               DECODE(
                 SIGN(paa.date_end - p_rolling_end_date)
                ,1, p_rolling_end_date
                ,paa.date_end
               )
             - DECODE(
                 SIGN(paa.date_start - p_rolling_start_date)
                ,1, paa.date_start
                ,p_rolling_start_date
               )
             + 1
           ) cnt
    FROM   per_absence_attendances paa
          ,hr_lookups hrl
	  ,ben_pl_f bp
	  ,pqp_gap_absence_plans gap
    WHERE  gap.assignment_id = p_assignment_id
      and  gap.pl_id = bp.pl_id
      and  hrl.lookup_type = p_lookup_type --'PQP_GAP_PLAN_TYPES_TO_EXTEND'
      and  bp.pl_typ_id = hrl.lookup_code
      and  ( p_rolling_start_date between
             NVL(hrl.start_date_active, p_rolling_start_date)
	    and NVL(hrl.end_date_active, p_rolling_end_date)
            OR
             p_rolling_end_date between
             NVL(hrl.start_date_active, p_rolling_start_date)
             and NVL(hrl.end_date_active, p_rolling_end_date)
	   )
      and  gap.absence_attendance_id = paa.absence_attendance_id
      and  paa.business_group_id = p_business_group_id
      and  ( paa.date_start  between
             p_rolling_start_date and p_rolling_end_date
	     OR
             paa.date_end between
             p_rolling_start_date and p_rolling_end_date
	   ) ;


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

-------------create_absence_plan_details--------------
    PROCEDURE create_absence_plan_details
            ( p_assignment_id      IN  NUMBER
             ,p_business_group_id  IN  NUMBER
             ,p_absence_id         IN  NUMBER
             ,p_pl_id              IN  NUMBER
             ,p_pl_typ_id          IN  NUMBER
             ,p_create_start_date  IN  DATE
             ,p_create_end_date    IN  DATE
	     ,p_entitlements       IN pqp_absval_pkg.t_entitlements
	     ,p_plan_information   IN pqp_absval_pkg.rec_plan_information
	     ,p_entitlements_remaining OUT NOCOPY pqp_absval_pkg.t_entitlements
	     ,p_entitlement_UOM    OUT NOCOPY VARCHAR2
	     ,p_working_days_per_week OUT NOCOPY NUMBER
	     ,p_fte  OUT NOCOPY NUMBER
            ) ;
------------------------------------------------------------

FUNCTION get_review_date (
           p_absence_start_date     IN DATE
          ,p_absence_end_date       IN DATE
          ,p_assignment_id          IN NUMBER
	  ,p_business_group_id      IN NUMBER
          ,p_pl_typ_id              IN NUMBER
	  ,p_scheme_period_duration IN NUMBER
	  ,p_scheme_period_type     IN VARCHAR2
	  ,p_scheme_period_uom      IN VARCHAR2
	  ,p_total_entitlement      IN NUMBER
	  ,p_total_remaining        IN OUT NOCOPY NUMBER
	  ,p_4_year_rolling_period  IN BOOLEAN --TRUE for 4 year
-- PT Changes cchappid
	  ,p_working_days_in_week   IN NUMBER
	  ,p_standard_work_days_in_week IN NUMBER
	  ,p_fulltime               IN BOOLEAN
          ,p_lookup_type            IN VARCHAR2
          ) RETURN DATE ;
---------------------------------------------------------
FUNCTION get_no_pay_days ( p_rolling_start_date        IN DATE
                          ,p_rolling_end_date          IN DATE
			  ,p_assignment_id             IN NUMBER
			  ,p_business_group_id         IN NUMBER
			  ,p_pl_typ_id                 IN NUMBER
			  ,p_dont_count_css_nopay_days IN BOOLEAN
			  ,p_lookup_type               IN VARCHAR2
			 ) RETURN NUMBER ;
----------------------------------------------------------------
FUNCTION get_rolling_start_date (
            p_rolling_end_date IN DATE
           ,p_scheme_period_duration IN NUMBER
           ,p_assignment_id      IN NUMBER
           ,p_business_group_id  IN NUMBER
   	   ,p_scheme_period_type IN VARCHAR2
           ,p_scheme_period_uom  IN VARCHAR2
	   ,p_pl_typ_id          IN NUMBER
	   ,p_4_year_rolling_period IN BOOLEAN
           ,p_lookup_type           IN VARCHAR2
          )  RETURN DATE ;
-----------------------------------------------------

END pqp_gb_css_daily_absences ;

 

/
