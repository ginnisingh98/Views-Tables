--------------------------------------------------------
--  DDL for Package NTG_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."NTG_EARNINGS_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pyusntgf.pkh 115.3 2003/08/14 12:29:59 ekim noship $ */

/*========================================================================
 *                        CREATE_ELE_TEMPLATE_OBJECTS
 *=======================================================================*/
FUNCTION create_ele_ntg_objects
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_category          in varchar2     default NULL
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_ele_ot_base           in varchar2     default 'N'
           ,p_flsa_hours            in varchar2     default 'N'
           ,p_sep_check_option      in varchar2     default 'N'
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_supp_category         in varchar2
           ,p_legislation_code      in varchar2
           ,p_bg_id                 in number
           ,p_termination_rule      in varchar2     default 'F'
           )
   RETURN NUMBER;
   --
   ----------------------------------------------------------------------
   -- Input-Name              Valid Values/Explaination
   -- ----------              --------------------------------------
   -- p_ele_name              - User i/p Element name
   -- p_ele_reporting_name    - User i/p reporting name
   -- p_ele_description       - User i/p Description
   -- p_ele_classification    - Supp/Regular Earnings
   -- p_ele_category          - Supp/Regular categories
   -- p_ele_processing_type   - R/N (Recurring/Non-recurring)
   -- p_ele_priority          - User i/p priority
   -- p_ele_standard_link     - Y/N  (default N)
   -- p_ele_ot_base           - Y/N (INCLUDE_IN_OT_BASE)
   -- p_flsa_hours            - FLSA hours
   -- p_ele_calc_ff_name      - current earnings formulas
   -- p_sep_check_option      - Y/N
   -- p_dedn_proc             - A-All, T-Tax, PTT-Pretax
   -- p_reduce_regular        - Y/N
   -- p_ele_eff_start_date    - Trunc(start date)
   -- p_ele_eff_end_date      - Trunc(end date)
   -- p_supp_category         - Supplemental element category
   -- p_legislation_code      - legislation code
   -- p_bg_id                 - Business group id
   --
--===========================================================================
--                             Deletion procedure
--===========================================================================
--
PROCEDURE delete_user_template_objects
           (p_business_group_id     in number
           ,p_ele_name              in varchar2
           );
--
END ntg_earnings_template;

 

/
