--------------------------------------------------------
--  DDL for Package PAY_US_EARN_TEMPL_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EARN_TEMPL_WRAPPER" AUTHID CURRENT_USER AS
/* $Header: pyuseewr.pkh 120.0.12000000.1 2007/01/18 02:23:41 appldev noship $ */
-----------------------------------------------------------------------------
--                       CREATE_EARNINGS_ELEMENT
-----------------------------------------------------------------------------

-- =======================================================================
--  DECLARE THE GLOBAL variables
-- =======================================================================
   g_ele_type_id          NUMBER;

FUNCTION create_earnings_element
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
         ,p_stop_reach_rule       in varchar2 default 'N'
         ,p_student_earning       IN varchar2 default 'N'
         ,p_special_input_flag    IN varchar2 default 'N'
         ,p_special_feature_flag  IN varchar2 default 'Y'
         )
RETURN NUMBER;
------------------------------------------------------------------------------
--                        DELETE_EARNINGS_ELEMENT
------------------------------------------------------------------------------
PROCEDURE delete_earnings_element
                       (p_business_group_id       in number
                       ,p_ele_type_id             in number
                       ,p_ele_name                in varchar2
                       ,p_ele_priority            in number
                       ,p_ele_primary_baltype_id  in varchar2     default null
                       ,p_ele_info_12             in varchar2     default null
                       ,p_session_date            in date
                       ,p_eff_start_date          in date
                       ,p_eff_end_date            in date
                       ,p_ele_classification      in varchar2 );
--
END pay_us_earn_templ_wrapper;

 

/
