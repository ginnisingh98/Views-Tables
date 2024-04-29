--------------------------------------------------------
--  DDL for Package PQP_GB_OSP_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_OSP_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqpgbosd.pkh 120.0 2005/05/29 02:00:25 appldev noship $ */


-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';
   g_template_leg_subgroup   VARCHAR2(30);

   TYPE rt_abs_types IS RECORD
        (abs_type_id     NUMBER
        ,abs_type_name   per_absence_attendance_types.name%TYPE
        );

   TYPE t_abs_types IS TABLE OF rt_abs_types
   INDEX BY BINARY_INTEGER;

   -- LG
   TYPE rt_plan_types IS RECORD
        (plan_type_id   ben_pl_typ_f.PL_TYP_ID%TYPE
        ,name   ben_pl_typ_f.name%TYPE
        );

   TYPE t_plan_types IS TABLE OF rt_plan_types
   INDEX BY BINARY_INTEGER;

   -- LG

------------------------------------------------------------------------
FUNCTION create_user_template
           (p_plan_id                       in number
           ,p_plan_description              in varchar2   default null
           ,p_sch_cal_type                  in varchar2
           ,p_sch_cal_duration              in number
           ,p_sch_cal_uom                   in varchar2
           ,p_sch_cal_start_date            in date
           ,p_sch_cal_end_date              in date
           ,p_abs_days                      in varchar2
           ,p_abs_ent_sick_leaves           in number
           ,p_abs_ent_holidays              in number
           ,p_abs_daily_rate_calc_method    in varchar2
           ,p_abs_daily_rate_calc_period    in varchar2
           ,p_abs_daily_rate_calc_divisor   in number
           ,p_abs_working_pattern           in varchar2
           ,p_abs_overlap_rule              in varchar2
           ,p_abs_ele_name                  in varchar2
           ,p_abs_ele_reporting_name        in varchar2
           ,p_abs_ele_description           in varchar2
           ,p_abs_ele_processing_priority   in number     default 500
           ,p_abs_primary_yn                in varchar2   default 'N'
           ,p_pay_ele_reporting_name        in varchar2
           ,p_pay_ele_description           in varchar2   default null
           ,p_pay_ele_processing_priority   in number     default 550
           ,p_pay_src_pay_component         in varchar2
           ,p_bnd1_ele_sub_name             in varchar2   default null
           ,p_bnd2_ele_sub_name             in varchar2   default null
           ,p_bnd3_ele_sub_name             in varchar2   default null
           ,p_bnd4_ele_sub_name             in varchar2   default null
           ,p_ele_eff_start_date            in date       default null
           ,p_ele_eff_end_date              in date       default null
           ,p_abs_type_lookup_type          in varchar2   default null
           ,p_abs_type_lookup_value         in t_abs_types
           ,p_security_group_id             in number     default null
           ,p_bg_id                         in number
	   ,p_plan_type_lookup_type         in varchar2   default null -- LG
           ,p_plan_type_lookup_value        in t_plan_types -- LG
	   ,p_enable_ent_proration          in varchar2   default null -- LG
           ,p_scheme_type                     in varchar2   default null -- LG
	   ,p_abs_schedule_wp               in varchar2   default null -- LG
           ,p_dual_rolling_duration      in number     default null
           ,p_dual_rolling_UOM           in varchar2   default null
	   ,p_ft_round_config            in varchar2   default null
	   ,p_pt_round_config            in varchar2   default null
           )
   RETURN NUMBER;
--
PROCEDURE delete_user_template
           (p_plan_id                      in number
           ,p_business_group_id            in number
           ,p_abs_ele_name                 in varchar2
           ,p_abs_ele_type_id              in number
           ,p_abs_primary_yn               in varchar2
           ,p_security_group_id            in number
           ,p_effective_date               in date
           );

--

PROCEDURE create_udt_entry
    (p_bg_id                  IN NUMBER
    ,p_band		          IN VARCHAR2
    ,p_entit			  IN VARCHAR2
    ,p_lower		  IN VARCHAR2
    ,p_user_tbl_id	  IN NUMBER
      );
  --
   PROCEDURE create_gap_lookup (p_security_group_id  IN NUMBER
                               ,p_ele_eff_start_date IN DATE
                               ,p_lookup_type        IN VARCHAR2
                               ,p_lookup_meaning     IN VARCHAR2
                               ,p_lookup_values      IN t_abs_types
                               ) ;

  PROCEDURE automate_plan_setup
     (p_pl_id                        IN             NUMBER
     ,p_business_group_id            IN             NUMBER
     ,p_element_type_id              IN             NUMBER  --
     ,p_effective_date               IN             DATE
     ,p_base_name                    IN             VARCHAR2
     ,p_plan_class                   IN             VARCHAR2 DEFAULT 'OSP'
     );

PROCEDURE del_automated_plan_setup_data
     (p_pl_id                        IN             NUMBER
     ,p_business_group_id            IN             NUMBER
     ,p_effective_date               IN             DATE
     ,p_base_name                    IN             VARCHAR2
     );

END pqp_gb_osp_template;

 

/
