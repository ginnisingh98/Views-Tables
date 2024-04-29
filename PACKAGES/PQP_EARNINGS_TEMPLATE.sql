--------------------------------------------------------
--  DDL for Package PQP_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EARNINGS_TEMPLATE" AUTHID CURRENT_USER AS
/* $Header: pqeetdrv.pkh 115.3 2003/04/22 21:32:35 tmehra ship $ */

/*========================================================================
*  CREATE_ELE_TEMPLATE_OBJECTS
*=======================================================================*/
FUNCTION create_ele_template_objects
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_category          in varchar2     default NULL
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_ele_ot_base           in varchar2     default 'N'
           ,p_flsa_hours            in varchar2
           ,p_ele_calc_ff_name      in varchar2
           ,p_sep_check_option      in varchar2     default 'N'
           ,p_dedn_proc             in varchar2
           ,p_reduce_regular        in varchar2     default 'N'
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
   -- p_ele_classification    - 'Alien/Expat Earnings'
   -- p_ele_category          - alien/expat categories
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
/*===========================================================================
*  FUNCTION get_obj_id
*==========================================================================*/
--
-- function used to fetch the object ids for balance, input values and
-- elements
--
FUNCTION get_obj_id (p_object_type   in varchar2,
                     p_object_name   in varchar2,
                     p_object_id     in number    default NULL)
RETURN NUMBER;

/*===========================================================================
*  Add_Flsa_Reduce_Reg_Feeds procedure
*==========================================================================*/
--
-- Procedure used to create the feeds for the reduce regular and FLSA hours
--
PROCEDURE add_flsa_reduce_reg_feeds
         (p_ele_ot_base        in varchar2
         ,p_flsa_hours         in varchar2
         ,p_reduce_regular     in varchar2
         ,p_pri_ele_type_id    in number
         ,p_ssf_ele_type_id    in number
         ,p_asf_ele_type_id    in number
         ,p_ele_eff_start_date in date );

/*===========================================================================
 *  Deletion procedure
 *==========================================================================*/
--
PROCEDURE delete_ele_template_objects
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date		in date
           );
--
END pqp_earnings_template;

 

/
