--------------------------------------------------------
--  DDL for Package PAY_CORE_FF_UDFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_FF_UDFS" AUTHID CURRENT_USER as
/* $Header: paycoreffudfs.pkh 120.3.12010000.5 2009/07/06 05:34:07 sudedas ship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : pay_core_ff_udfs
    Filename	: paycoreffudfs.sql
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    01-May-2005 sodhingr        115.0           Defines user defined function
                                                used by international payroll
    14-JUN-2005 sodhingr        115.1           Added the function
                                                get_hourly_rate that returns
                                                the hourly rate based on Salary
                                                Basis.also added the function
                                                calculate_actual_hours_worked
                                                that calculates the hours
                                                worked based on ATG/
                                                workschedule/Std hrs
   16-JUN-2005   pganguly        115.2           Fixed the GSCC issue.
   07-OCT-2005  sodhingr        115.3           removed convert_period_type and added
                                                p_days_or_hours to calculate_actual_hours_worked

   07-FEB-2005  sodhingr        115.4           added convert_period_type and calculate_period_earnings
                                                that can be used by the localization team and take care
                                                of proration if core proration is not enabled.
   08-Jan-2008  sudedas         115.4   6718164 Added new Function term_skip_rule_rwage
   25-Aug-2008  sudedas         115.5   5895804 Added Functions hours_between, calc_reduced_reg
                                        3556204 calc_vacation_pay, calc_sick_pay
                                      ER#3855241
   22-Jun-2009  sudedas         115.7           Added function get_asg_status_typ.
   06-Jul-2009  sudedas         115.8   8637053 Added context element_type_id to function
                                                get_num_period_curr_year.
*/


FUNCTION get_hourly_rate(
	 p_bg		            IN NUMBER -- context
        ,p_assignment_id        IN NUMBER -- context
	,p_payroll_id		    IN NUMBER -- context
        ,p_element_entry_id     IN NUMBER -- context
        ,p_date_earned          IN DATE -- context
        ,p_assignment_action_id IN NUMBER)
RETURN NUMBER ;

FUNCTION calculate_actual_hours_worked
          (assignment_action_id   IN number   --Context
           ,assignment_id         IN number   --Context
           ,business_group_id     IN number   --Context
           ,element_entry_id      IN number   --Context
           ,date_earned           IN date     --Context
           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  default 'WORK'-- 'WORK'/'PAGER'
           ,p_include_exceptions  IN varchar2  default ''
           ,p_busy_tentative_as   IN varchar2  default 'FREE'-- 'BUSY'/FREE/NULL
           ,p_legislation_code    IN varchar2  default ''
           ,p_schedule_source     IN OUT nocopy varchar2 -- 'PER_ASG' for asg
           ,p_schedule            IN OUT nocopy varchar2 -- schedule
           ,p_return_status       OUT nocopy number
           ,p_return_message      OUT nocopy varchar2
           ,p_days_or_hours       IN VARCHAR2 default 'H' -- 'D' for days, 'H' for hours
           )
 RETURN NUMBER;

 FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER;

 FUNCTION Calculate_Period_Earnings (
			p_bus_grp_id		in NUMBER,
			p_asst_id		in NUMBER,
			p_payroll_id		in NUMBER,
			p_ele_entry_id		in NUMBER,
			p_tax_unit_id		in NUMBER,
			p_date_earned		in DATE,
			p_assignment_action_id  in NUMBER,
			p_pay_basis 		in VARCHAR2	default NULL,
			p_inpval_name		in VARCHAR2	default NULL,
			p_ass_hrly_figure	in NUMBER,
			p_period_start 		in DATE,
			p_period_end 		in DATE,
			p_actual_hours_worked	in out nocopy NUMBER,
			p_vac_hours_worked	    in out nocopy NUMBER,
			p_vac_pay		        in out nocopy NUMBER,
			p_sick_hours_worked	    in out nocopy NUMBER,
			p_sick_pay	        	in out nocopy NUMBER,
			p_prorate 	        	in VARCHAR2	default 'Y',
			p_asst_std_freq		    in VARCHAR2	default NULL)
 RETURN NUMBER;
--

FUNCTION Convert_Period_Type(
    	 p_bg		            in NUMBER -- context
        ,p_assignment_id        in NUMBER -- context
    	,p_payroll_id		    in NUMBER -- context
        ,p_element_entry_id     in NUMBER -- context
        ,p_date_earned          in DATE -- context
        ,p_assignment_action_id in NUMBER -- context
        ,p_period_start_date    IN DATE
        ,p_period_end_date      IN DATE
        /*,p_schedule_category    IN varchar2  --Optional
        ,p_include_exceptions   IN varchar2  --Optional
        ,p_busy_tentative_as    IN varchar2   --Optional
        ,p_schedule_source      IN varchar2
        ,p_schedule             IN varchar2*/
    	,p_figure	            in NUMBER
    	,p_from_freq		    in VARCHAR2
    	,p_to_freq		        in VARCHAR2
        ,p_asst_std_freq		in VARCHAR2 default NULL
        ,p_rate_calc_override    in VARCHAR2 default 'NOT ENTERED')
RETURN NUMBER;
--
-- Added For Skip Rule for "Regular Wages" Element, "REGULAR_PAY"

FUNCTION term_skip_rule_rwage(ctx_payroll_id             NUMBER
			     ,ctx_assignment_id          NUMBER
			     ,ctx_date_earned            DATE
			     ,p_user_entered_time        VARCHAR2
			     ,p_final_pay_processed      VARCHAR2
			     ,p_lspd_pay_processed       VARCHAR2
			     ,p_payroll_termination_type VARCHAR2
			     ,p_bg_termination_type      VARCHAR2
			     ,p_already_processed        VARCHAR2)
RETURN VARCHAR2;

-- Following Functions have been added as part of Enabling Core Proration
-- for "Regular Salary" and "Regular Wages" elements.
-- hours_between will be called by 'REGULAR_SALARY', 'REGULAR_WAGES'
-- Fast Formulas by Formula Function HOURS_BETWEEN
-- Similarly calc_reduced_reg is by REDUCED_REGULAR_CALC
-- calc_vacation_pay by CALC_VAC_PAY
-- calc_sick_pay by CALC_SICK_PAY Formula Functions respectively.

Function hours_between( business_group_id     IN number   --Context
           ,assignment_id         IN number   --Context
           ,assignment_action_id   IN number   --Context
           ,date_earned           IN date     --Context
           ,element_entry_id      IN number   --Context
           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  default 'WORK'-- 'WORK'/'PAGER'
           ,p_include_exceptions  IN varchar2  default ''
           ,p_busy_tentative_as   IN varchar2  default 'FREE'-- 'BUSY'/FREE/NULL
           ,p_legislation_code    IN varchar2  default ''
           ,p_schedule_source     IN OUT nocopy varchar2 -- 'PER_ASG' for asg
           ,p_schedule            IN OUT nocopy varchar2 -- schedule
           ,p_return_status       OUT nocopy number
           ,p_return_message      OUT nocopy varchar2
           ,p_days_or_hours       IN VARCHAR2 default 'H' -- 'D' for days, 'H' for hours
	   ) RETURN NUMBER;

FUNCTION calc_reduced_reg(ctx_assignment_id IN NUMBER
                         ,ctx_assignment_action_id IN NUMBER
                         ,p_period_end_dt IN DATE
                         ,p_prorate_start_dt IN DATE
                         ,p_prorate_end_dt IN DATE
                         ,p_red_reg_earn  IN OUT NOCOPY NUMBER
                         ,p_red_reg_hrs IN OUT NOCOPY NUMBER
                         )
RETURN VARCHAR2;

FUNCTION calc_vacation_pay (ctx_asg_id 	IN NUMBER
                           ,p_period_end_dt IN DATE
                           ,p_prorate_start_dt IN DATE
                           ,p_prorate_end_dt IN DATE
			         ,p_curr_rate	IN NUMBER
                           ,p_vac_hours	IN OUT NOCOPY NUMBER)
RETURN NUMBER;

FUNCTION  calc_sick_pay (ctx_asg_id 	IN NUMBER
                        ,p_period_end_dt IN DATE
                        ,p_prorate_start_dt IN DATE
                        ,p_prorate_end_dt IN DATE
			      ,p_curr_rate	IN NUMBER
                        ,p_sick_hours 	IN OUT NOCOPY NUMBER)
RETURN NUMBER;

FUNCTION get_upgrade_flag(ctx_ele_typ_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_num_period_curr_year(ctx_bg_id in NUMBER
                                 ,ctx_payroll_id in NUMBER
                                 ,ctx_ele_type_id in NUMBER
                                 ,period_end_date in DATE)
RETURN NUMBER;

-- Following function is called from
-- Formula Function FF IS_ASSIGNMENT_ACTIVE

FUNCTION get_asg_status_typ(ctx_asg_id IN NUMBER
                           ,prorate_end_dt IN DATE)
RETURN VARCHAR2;

g_normal_hours     NUMBER DEFAULT 0;

END pay_core_ff_udfs ;

/
