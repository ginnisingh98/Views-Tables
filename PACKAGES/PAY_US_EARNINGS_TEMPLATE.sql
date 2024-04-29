--------------------------------------------------------
--  DDL for Package PAY_US_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EARNINGS_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: payusearningtemp.pkh 120.0.12010000.1 2008/07/27 21:55:10 appldev ship $ */

-- =======================================================================
--  CREATE_ELE_TEMPLATE_OBJECTS
-- =======================================================================
FUNCTION create_ele_template_objects
           (p_ele_name              IN VARCHAR2
           ,p_ele_reporting_name    IN VARCHAR2
           ,p_ele_description       IN VARCHAR2     DEFAULT NULL
           ,p_ele_classification    IN VARCHAR2
           ,p_ele_category          IN VARCHAR2     DEFAULT NULL
           ,p_ele_processing_type   IN VARCHAR2
           ,p_ele_priority          IN NUMBER       DEFAULT NULL
           ,p_ele_standard_link     IN VARCHAR2     DEFAULT 'N'
           ,p_ele_ot_base           IN VARCHAR2     DEFAULT 'N'
           ,p_flsa_hours            IN VARCHAR2
           ,p_ele_calc_ff_name      IN VARCHAR2
           ,p_sep_check_option      IN VARCHAR2     DEFAULT 'N'
           ,p_dedn_proc             IN VARCHAR2
           ,p_reduce_regular        IN VARCHAR2     DEFAULT 'N'
           ,p_ele_eff_start_date    IN DATE         DEFAULT NULL
           ,p_ele_eff_end_date      IN DATE         DEFAULT NULL
           ,p_supp_category         IN VARCHAR2
           ,p_legislation_code      IN VARCHAR2
           ,p_bg_id                 IN NUMBER
           ,p_termination_rule      IN VARCHAR2     DEFAULT 'F'
           ,p_stop_reach_rule       IN VARCHAR2     DEFAULT 'N'
           ,p_student_earning       IN VARCHAR2     DEFAULT 'N'
           ,p_special_input_flag    IN VARCHAR2     DEFAULT 'N'
           ,p_special_feature_flag  IN VARCHAR2     DEFAULT 'Y'
           )
   RETURN NUMBER;
   --
   ----------------------------------------------------------------------
   -- Input-Name              Valid Values/Explaination
   -- ----------              --------------------------------------
   -- p_ele_name              - Element name entered by the user.
   -- p_ele_reporting_name    - Reporting name entered by the user.
   -- p_ele_description       - Description entered by the user.
   -- p_ele_classification    - classification entered by the user. For example
   --                           'Earnings'/'Supplemental Earnings' etc.
   -- p_ele_category          - Categories
   -- p_ele_processing_type   - R/N (Recurring/Non-recurring)
   -- p_ele_priority          - Priority
   -- p_ele_standard_link     - Y/N  ( N)
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
   -- p_termination_rule      - Termination Rule     'F'
   -- p_stop_reach_rule       - Element processing stops when the limit is
   --                           reached and this is 'Y'.  'N'
   -- p_student_earning       - Student Earning input values will be created
   --                           if 'Y'.  'N'.
   -- p_special_input_flag    - Special Inputs element will be created if 'Y'.
   --                            'N'
   -- p_special_feature_flag  - Special Features element will be created if 'Y'.
   --                            'Y'
-- ==========================================================================
--   FUNCTION get_obj_id
-- ==========================================================================
--
-- function used to fetch the object ids for balance, input values and
-- elements
--
FUNCTION get_obj_id (p_object_type   IN VARCHAR2,
                     p_object_name   IN VARCHAR2,
                     p_object_id     IN NUMBER DEFAULT NULL)
RETURN NUMBER;

-- ==========================================================================
--   Deletion procedure
-- ==========================================================================
--
PROCEDURE delete_ele_template_objects
           (p_business_group_id     IN NUMBER
           ,p_ele_type_id           IN NUMBER
           ,p_ele_name              IN VARCHAR2
           ,p_effective_date		IN DATE);
--
END pay_us_earnings_template;

/
