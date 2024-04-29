--------------------------------------------------------
--  DDL for Package PQP_GB_OMP_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_OMP_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqpgbomd.pkh 115.4 2004/01/06 05:19:37 cchappid noship $ */

-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';
   g_template_leg_subgroup   VARCHAR2(30);

/*   TYPE rt_abs_types IS RECORD
        (abs_type_id     NUMBER
        ,abs_type_name   PER_ABSENCE_ATTENDANCE_TYPES.NAME%TYPE
        );

   TYPE t_abs_types IS TABLE OF pqp_gb_osp_template.rt_abs_types
   INDEX BY BINARY_INTEGER; */

    TYPE t_ele_name IS TABLE OF pay_element_types_f.element_name%TYPE
           INDEX BY BINARY_INTEGER;


   CURSOR csr_get_element_type_id(p_template_id NUMBER) IS
   SELECT core_object_id element_type_id
   FROM   pay_template_core_objects
   WHERE  template_id = p_template_id
     and  core_object_type = 'ET' ;

   CURSOR csr_get_element_name(p_element_type_id NUMBER)
   IS
   SELECT element_name
   FROM   PAY_ELEMENT_TYPES_F
   WHERE  element_type_id = p_element_type_id ;



------------------------------------------------------------------------
FUNCTION create_user_template
           (p_plan_id                       IN NUMBER
           ,p_plan_description              IN VARCHAR2   DEFAULT NULL
           ,p_abse_days_def                 IN VARCHAR2
           ,p_maternity_abse_ent_udt        IN NUMBER
           ,p_holidays_udt                  IN NUMBER
           ,p_daily_rate_calc_method        IN VARCHAR2
           ,p_daily_rate_calc_period        IN VARCHAR2
           ,p_daily_rate_calc_divisor       IN NUMBER
           ,p_working_pattern               IN VARCHAR2
           ,p_los_calc                      IN VARCHAR2
           ,p_los_calc_uom                  IN VARCHAR2
           ,p_los_calc_duration             IN VARCHAR2
           ,p_avg_earnings_duration         IN VARCHAR2
           ,p_avg_earnings_uom              IN VARCHAR2
           ,p_avg_earnings_balance          IN VARCHAR2
           ,p_pri_ele_name                  IN VARCHAR2
           ,p_pri_ele_reporting_name        IN VARCHAR2
           ,p_pri_ele_description           IN VARCHAR2
           ,p_pri_ele_processing_priority   IN NUMBER     DEFAULT 500
           ,p_abse_primary_yn               IN VARCHAR2   DEFAULT 'N'
           ,p_pay_ele_reporting_name        IN VARCHAR2
           ,p_pay_ele_description           IN VARCHAR2   DEFAULT NULL
           ,p_pay_ele_processing_priority   IN NUMBER     DEFAULT 550
           ,p_pay_src_pay_component         IN VARCHAR2
           ,p_band1_ele_base_name           IN VARCHAR2   DEFAULT NULL
           ,p_band2_ele_base_name           IN VARCHAR2   DEFAULT NULL
           ,p_band3_ele_base_name           IN VARCHAR2   DEFAULT NULL
           ,p_band4_ele_base_name           IN VARCHAR2   DEFAULT NULL
           ,p_effective_start_date          IN DATE       DEFAULT NULL
           ,p_effective_end_date            IN DATE       DEFAULT NULL
           ,p_abse_type_lookup_type         IN VARCHAR2   DEFAULT NULL
           ,p_abse_type_lookup_value        IN PQP_GB_OSP_TEMPLATE.T_ABS_TYPES
           ,p_security_group_id             IN NUMBER     DEFAULT NULL
           ,p_bg_id                         IN NUMBER
           )
   RETURN NUMBER;
--
PROCEDURE delete_user_template
           (p_plan_id                      IN NUMBER
           ,p_business_group_id            IN NUMBER
           ,p_pri_ele_name                 IN VARCHAR2
           ,p_abse_ele_type_id             IN NUMBER
           ,p_abse_primary_yn              IN VARCHAR2
           ,p_security_group_id            IN NUMBER
           ,p_effective_date               IN DATE
           );

PROCEDURE create_element_links
                     ( p_business_group_id    IN NUMBER
 	              ,p_effective_start_date IN DATE
                      ,p_effective_end_date   IN DATE
                    --,p_legislation_code     IN VARCHAR2
                    --,p_base_name            IN VARCHAR2
                    --,p_abs_type             IN VARCHAR2
		      ,p_template_id          IN NUMBER
		     ) ;

PROCEDURE delete_element_links
                     ( p_business_group_id    IN NUMBER
		      ,p_effective_start_date IN DATE
		      ,p_effective_end_date   IN DATE
                    --,p_base_name            IN VARCHAR2
                    --,p_abs_type             IN VARCHAR2
		      ,p_template_id          IN NUMBER
		      ) ;
--
PROCEDURE check_ben_standard_rates_link (
                      p_business_group_id IN NUMBER
                     ,p_plan_id           IN NUMBER
	             ,p_element_type_id   IN NUMBER ) ;

END pqp_gb_omp_template;

 

/
