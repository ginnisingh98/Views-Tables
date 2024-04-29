--------------------------------------------------------
--  DDL for Package PAY_US_DEDN_TEMPLATE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DEDN_TEMPLATE_WRAPPER" AUTHID CURRENT_USER as
/* $Header: pytmpdde.pkh 120.1 2005/07/28 18:32:58 rpinjala noship $ */
-- =============================================================================
-- create_deduction_element
-- =============================================================================
Function create_deduction_element
         (p_element_name          in varchar2
         ,p_reporting_name        in varchar2
         ,p_description           in varchar2     default null
         ,p_classification_name   in varchar2
         ,p_ben_class_id          in number       default null
         ,p_category              in varchar2
         ,p_processing_type       in varchar2
         ,p_processing_priority   in number       default null
         ,p_standard_link_flag    in varchar2     default 'N'
         ,p_processing_runtype    in varchar2
         ,p_start_rule            in varchar2
         ,p_stop_rule             in varchar2
         ,p_amount_rule           in varchar2
         ,p_series_ee_bond        in varchar2
         ,p_payroll_table         in varchar2
         ,p_paytab_column         in varchar2
         ,p_rowtype_meaning       in varchar2
         ,p_arrearage             in varchar2
         ,p_deduct_partial        in varchar2
         ,p_employer_match        in varchar2     default 'N'
         ,p_aftertax_component    in varchar2     default 'N'
         ,p_ele_eff_start_date    in date         default null
         ,p_ele_eff_end_date      in date         default null
         ,p_business_group_id     in number
         ,p_srs_plan_type         in varchar2     default 'N'
         ,p_srs_buy_back          in varchar2     default 'N'
         ,p_roth_contribution     in varchar2     default 'N'
         ,p_userra_contribution   in varchar2     default 'N'
         ,p_catchup_processing    in varchar2     default 'NONE'
         ,p_termination_rule      in varchar2     default 'F'
         )
   Return Number;
-- =============================================================================
-- delete_deduction_element
-- =============================================================================
Procedure delete_deduction_element
         (p_business_group_id       in  number
         ,p_element_type_id         in  number
         ,p_element_name            in  varchar2
         ,p_classification_name     in  varchar2
         ,p_category                in  varchar2
         ,p_processing_priority     in  number
         ,p_amount_rule             in  varchar2
         ,p_series_ee_bond          in  varchar2
         ,p_arrearage               in  varchar2
         ,p_stop_rule               in  varchar2
         ,p_calculation_ele_id      in  number
         ,p_vol_dedns_baltype_id    in  number
         ,p_primary_baltype_id      in  number
         ,p_accrued_baltype_id      in  number
         ,p_arrears_baltype_id      in  number
         ,p_not_taken_baltype_id    in  number
         ,p_tobondpurch_baltype_id  in  number
         ,p_able_baltype_id         in  number
         ,p_additional_baltype_id   in  number
         ,p_replacement_baltype_id  in  number
         ,p_special_inputs_ele_id   in  number
         ,p_special_features_ele_id in  number
         ,p_verifier_ele_id         in  number
         ,p_eff_start_date          in  date
         ,p_eff_end_date            in  date
         );

End pay_us_dedn_template_wrapper;

 

/
