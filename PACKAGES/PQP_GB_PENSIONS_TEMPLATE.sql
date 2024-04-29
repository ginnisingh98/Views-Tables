--------------------------------------------------------
--  DDL for Package PQP_GB_PENSIONS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PENSIONS_TEMPLATE" AUTHID CURRENT_USER as
/* $Header: pqgbpatp.pkh 120.1 2005/05/30 00:12:13 rvishwan noship $ */


-- Legislation Subgroup Code for all template elements.
   g_template_leg_code       VARCHAR2(30) := 'GB';
   g_template_leg_subgroup   VARCHAR2(30);
------------------------------------------------------------------------
FUNCTION create_user_template
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_sch_type              in varchar2
           ,p_emp_cont_method       in varchar2
           ,p_emp_contribution      in number       default NULL
           ,p_adl_contribution      in varchar2
           ,p_eer_contribution      in varchar2
           ,p_eer_type              in varchar2
           ,p_eer_rate              in number       default NULL
           ,p_ept_contribution      in varchar2
           ,p_byb_added_years       in varchar2
           ,p_fmwd_benefit          in varchar2
           ,p_avc_percentage        in varchar2
           ,p_avc_per_provider      in varchar2
           ,p_avc_fixed_rate        in varchar2
           ,p_avc_fxdrt_provider    in varchar2
           ,p_life_assurance        in varchar2
           ,p_life_asr_provider     in varchar2
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_bg_id                 in number
           )
   RETURN NUMBER ;
--
PROCEDURE delete_user_template
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date        in date
           );

--
END pqp_gb_pensions_template ;

 

/
