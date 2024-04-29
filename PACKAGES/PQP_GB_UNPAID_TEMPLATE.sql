--------------------------------------------------------
--  DDL for Package PQP_GB_UNPAID_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_UNPAID_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqpgbupd.pkh 120.0 2005/05/29 02:03:26 appldev noship $ */


-- Legislation Subgroup Code for all core objects
   g_template_leg_code       VARCHAR2(30):= 'GB';
   g_template_leg_subgroup   VARCHAR2(30);

------------------------------------------------------------------------
FUNCTION create_user_template
           (p_plan_id                       in number
           ,p_plan_description              in varchar2   default null
           ,p_abs_days                      in varchar2
           ,p_abs_ent_sick_leaves           in number
           ,p_abs_ent_holidays              in number
           ,p_abs_daily_rate_calc_method    in varchar2
           ,p_abs_daily_rate_calc_period    in varchar2
           ,p_abs_daily_rate_calc_divisor   in number
           ,p_abs_working_pattern           in varchar2
           ,p_abs_ele_name                  in varchar2
           ,p_abs_ele_reporting_name        in varchar2
           ,p_abs_ele_description           in varchar2
           ,p_abs_ele_processing_priority   in number     default 500
           ,p_abs_primary_yn                in varchar2   default 'N'
           ,p_pay_ele_reporting_name        in varchar2
           ,p_pay_ele_description           in varchar2   default null
           ,p_pay_ele_processing_priority   in number     default 550
           ,p_pay_src_pay_component         in varchar2
           ,p_ele_eff_start_date            in date       default null
           ,p_ele_eff_end_date              in date       default null
           ,p_abs_type_lookup_type          in varchar2   default null
           ,p_abs_type_lookup_value         in pqp_gb_osp_template.t_abs_types
           ,p_security_group_id             in number     default null
           ,p_bg_id                         in number
           )
   RETURN NUMBER;

PROCEDURE delete_user_template
           (p_plan_id                      in number
           ,p_business_group_id            in number
           ,p_abs_ele_name                 in varchar2
           ,p_abs_ele_type_id              in number
           ,p_abs_primary_yn               in varchar2
           ,p_security_group_id            in number
           ,p_effective_date               in date
           );
END pqp_gb_unpaid_template;

 

/
