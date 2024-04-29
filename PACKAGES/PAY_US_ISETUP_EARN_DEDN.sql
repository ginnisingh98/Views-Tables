--------------------------------------------------------
--  DDL for Package PAY_US_ISETUP_EARN_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ISETUP_EARN_DEDN" AUTHID CURRENT_USER AS
/* $Header: pyusisetup.pkh 120.4 2005/08/25 19:29:39 ndorai noship $ */
-----------------------------------------------------------------------------
--                       CREATE_ISETUP_EARN_ELEMENT
-----------------------------------------------------------------------------
FUNCTION create_isetup_earn_element
         (p_ele_name              in varchar2
         ,p_ele_reporting_name    in varchar2
         ,p_ele_description       in varchar2
         ,p_ele_classification    in varchar2
         ,p_ele_category          in varchar2
         ,p_ele_ot_base           in varchar2
         ,p_flsa_hours            in varchar2
         ,p_ele_processing_type   in varchar2
         ,p_ele_priority          in number
         ,p_ele_standard_link     in varchar2
         ,p_ele_calc_ff_id        in number
         ,p_ele_calc_ff_name      in varchar2
         ,p_sep_check_option      in varchar2
         ,p_dedn_proc             in varchar2
         ,p_mix_flag              in varchar2
         ,p_reduce_regular        in varchar2
         ,p_ele_eff_start_date    in date
         ,p_ele_eff_end_date      in date
         ,p_alien_supp_category   in varchar2
         ,p_bg_id                 in number
         ,p_termination_rule      in varchar2 default 'F'
         ,p_grossup_chk           in varchar2
         ,p_legislation_code      in varchar2
         )
   RETURN NUMBER;
-----------------------------------------------------------------------------
--                       CREATE_ISETUP_DEDN_ELEMENT
-----------------------------------------------------------------------------

FUNCTION create_isetup_dedn_element
         (p_element_name          in varchar2
         ,p_reporting_name        in varchar2
         ,p_description           in varchar2     default NULL
         ,p_classification_name   in varchar2
         ,p_ben_class_id          in number       default NULL
         ,p_category              in varchar2
         ,p_processing_type       in varchar2
         ,p_processing_priority   in number       default NULL
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
         ,p_ele_eff_start_date    in date         default NULL
         ,p_ele_eff_end_date      in date         default NULL
         ,p_business_group_id     in number
         ,p_srs_plan_type         in varchar2     default 'N'
         ,p_srs_buy_back          in varchar2     default 'N'
         ,p_catchup_processing    in varchar2     default 'NONE'
         ,p_termination_rule      in varchar2     default 'F'
         )
   RETURN NUMBER;
--
--
--
--
PROCEDURE compile_formula
           (p_element_type_id IN NUMBER);
--
--
PROCEDURE compile_mig_formula
           (p_formula_id IN NUMBER);
--
--
PROCEDURE bulk_compile_formula;
--
--
FUNCTION uncompiled_formula return number;
--PROCEDURE uncompiled_formula;
--
--
END pay_us_iSetup_earn_dedn;

 

/
