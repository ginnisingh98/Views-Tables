--------------------------------------------------------
--  DDL for Package PAY_US_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_USER_INIT_DEDN" AUTHID CURRENT_USER as
/* $Header: pyusdtmp.pkh 120.1.12000000.1 2007/01/18 02:19:38 appldev noship $ */
-- Legislation Subgroup Code for all template elements.
   g_template_leg_code       varchar2(30);
   g_template_leg_subgroup   varchar2(30);
-- =============================================================================
-- create_user_init_template:
-- =============================================================================
function create_user_init_template
        (p_ele_name              in varchar2
        ,p_ele_reporting_name    in varchar2
        ,p_ele_description       in varchar2     default NULL
        ,p_ele_classification    in varchar2
        ,p_ben_class_id          in number       default NULL
        ,p_ele_category          in varchar2     default NULL
        ,p_ele_processing_type   in varchar2
        ,p_ele_priority          in number       default NULL
        ,p_ele_standard_link     in varchar2     default 'N'
        ,p_ele_proc_runtype      in varchar2
        ,p_ele_calc_rule         in varchar2
        ,p_ele_start_rule        in varchar2
        ,p_ele_stop_rule         in varchar2
        ,p_ele_partial_deduction in varchar2
        ,p_ele_arrearage         in varchar2
        ,p_ele_eff_start_date    in date         default NULL
        ,p_ele_eff_end_date      in date         default NULL
        ,p_employer_match        in varchar2     default 'N'
        ,p_after_tax_component   in varchar2     default 'N'
        ,p_ele_srs_plan_type     in varchar2     default 'N'
        ,p_ele_srs_buy_back      in varchar2     default 'N'
        ,p_roth_contribution     in varchar2     default 'N'
        ,p_userra_contribution   in varchar2     default 'N'
        ,p_bg_id                 in number
        ,p_catchup_processing    in varchar2     default 'NONE'
        ,p_termination_rule      in varchar2     default 'F'
        )
return number;
--
-- =============================================================================
-- delete_user_init_template:
-- =============================================================================
procedure delete_user_init_template
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date	      	in date
           );

--
end pay_us_user_init_dedn;

 

/
