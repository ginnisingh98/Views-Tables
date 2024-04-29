--------------------------------------------------------
--  DDL for Package PAY_AU_PAYE_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PAYE_FF" AUTHID CURRENT_USER AS
/*  $Header: pyaufmla.pkh 120.11.12010000.9 2009/10/09 05:40:18 avenkatk ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in NZ tax calculations
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  ====================================================
**  24-SEP-1999 makelly  115.0     Created for AU
**  31-JAN-2000 sclarke  115.0     Added Terminations
**  16-SEP-2000 sclarke  115.1     Removed Terminations, now in pay_au_terminations
**  20-DEC-2000 srikrish 115.2     Created function paid_periods_since_hire_date
**                                 which returns number of paid pay periods
**  19-DEC-2000 abajpai  115.2     Added new function convert_to_period_amt, round_amount
**  ============== Formula Fuctions ====================
**  Package containing addition processing required by
**  formula in AU localisatons.
**  28-NOV-2001 nnaresh  115.5     Updated for GSCC Standards
**  8-JAN-2002 apunekar  115.6     Additional functions added.
**  18-May-2002 apunekar  115.6     Additional function added.
**  17-Sep-2002 Ragovind 115.13     Modified the function check_fixed_deduction declaration
**  03-Dec-2002 Ragovind 115.14     Added NOCOPY for the function get_retro_period.
**  14-Apr-2003 Vgsriniv 115.15     Added the extra parameter to the function
**                                  periods_since_hire_date
**  22-Aug-2003 srrajago 115.16     Added a new formula function 'validate_data_magtape'.
**                                  Bug reference : 3091834
**  03-Nov-2003 punmehta 115.17     Bug# 2977425 - Added the new formula function
**  23-Dec-2003 punmehta 115.18     Bug# 3306112 - Added the new formula function
**  06-Feb-2004 punmehta 115.19     Bug# 3245909 - Added a new function get_pp_action for AU_Payments route
**  09-AUG-2004 abhkumar 115.20     Bug# 2610141 - Modfied the code to support Legal Employer changes for an assignment.
**  08-SEP-2004 abhkumar 115.21     Bug# 2610141 - Added a new parameter to functions periods_since_hire_date and paid_periods_since_hire_date
*** 26-Apr-2005 abhkumar 115.22     Bug# 3935471  - Changes due to Retro Tax enhancement.
**  07-Jun-2005 abhkumar 115.23     Bug# 4415795 - Added new parameter to count_retro_periods.
*** 23-Jun-2005 abhkumar 115.24     Bug#4438644  - Modified function paid_periods_since_hire_date
*** 26-Jun-2005 avenkatk 115.25     Bug#4451088  - Modified function paid_periods_since_hire_date
*** 27-Jun-2005 ksingla  115.26     Bug#4456720  - Added a new function CALCULATE_ASG_PREV_VALUE for negative retro earnings
*** 05-JuL-2005 abhkumar 115.27     Bug#4467198 - Modified function CALCULATE_ASG_PREV_VALUE for zero average earnings
*** 13-Jul-2005 abhargav 115.28     Bug#4363057 - Modified function CALCULATE_ASG_PREV_VALUE to include fix for bug# 3855355 .
**  14-Jul-2005 abhkumar 115.29     Bug#4418107 - Added new context (tax_unit_id) to function count_retro_periods and get_retro_periods
**  05-Oct-2006 avenkatk 115.30     Bug#5556260 - Introduced new function - get_enhanced_retro_period to get the dates and time spans
**                                                for Enhanced Retropay.
**  17-Jan-2006 avenkatk 115.31     Bug#5846272 - Introduced new functions,
**                                                i.  check_if_enhanced_retro
**                                                ii. get_retro_time_span
**  10-Apr-2007 abhargav 115.33     Bug#5934468    Added new function get_spread_earning() this function gets called from
                                                   formula AU_HECS_DEDUCTION and AU_SFSS_DEDUCTION.
**  17-Jan-2008 skshin   115.34     Bug#6669058    Added new function get_retro_spread_earning() this function gets called from
                                                   formula AU_HECS_DEDUCTION and AU_SFSS_DEDUCTION.
**  15-FEB-2008 skshin   115.35     Bug#6809877    Added new function get_etp_pay_component.
**  29-APR-2009 skshin   115.38     Bug#7665727    Created count_retro_periods_2009 function
**  21-MAY-2009 skshin   115.39     Bug#8406009    Added calc_average_earnings and calc_lt12_prev_spread_tax functions
**  30-JUL-2009 skshin   115.40     Bug#8725341    Added Earnings_Leave_Loading balance to c_get_ytd_def_bal_ids cursor
**  08-Oct-2009 avenkatk 115.41     Bug#8765082    Added New Function get_retro_leave_load
*/

/*
 *  round_to_5c = rounds values to nearest 5c using
 *  ATO rules
 */

cursor c_get_creator_type(c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
                          c_date_earned in pay_payroll_actions.date_earned%TYPE
                         ) is
SELECT creator_type
FROM pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and c_date_earned between pee.effective_start_date and pee.effective_end_date;



function  round_to_5c
          (
            p_actual_amt  in  number
          )
          return number;

/*
 *  convert_to_period - converts weekly equivalents
 *  back to the period amounts using ATO rules.
 */

function  convert_to_period
          (
            p_ann_freq    in  number,
            p_amt_week    in  number
          )
          return number;
/*
 *  convert_to_week - converts period amounts to equivalents
 *  weekly equivalents using ATO rules.
 */

function  convert_to_week
          (
            p_ann_freq    in  number,
            p_amt_period  in  number
          )
          return number;
/*
 *  periods_since_hire_date - returns the number of periods in the
 *  current tax year since the hire date.
 */

/* Bug:2900253. Added the extra context parameter p_assignment_id */
function  periods_since_hire_date
          (
            p_payroll_id        in number,
            p_assignment_id     in per_all_assignments_f.assignment_id%type,
            p_tax_unit_id       in pay_assignment_actions.tax_unit_id%type,      --2610141
            p_assignment_action_id IN pay_assignment_actions.assignment_action_id%type, /*Bug 4451088 */
            p_period_num        in number,
            p_period_start      in date,
            p_emp_hire_date     in date,
	    p_use_tax_flag      IN VARCHAR2 --2610141
          )
          return number;

function  paid_periods_since_hire_date
          (
            p_payroll_id        in number,
            p_assignment_id     in number,
	    p_tax_unit_id       in number, --2610141
       p_assignment_action_id IN number, /*Bug 4438644 */
            p_period_num        in number,
            p_period_start      in date,
            p_emp_hire_date     in date,
	    p_use_tax_flag      IN VARCHAR2 --2610141
          )
  	  return number;

/* Bug 4456720  - Added a new function to calculate the earnings_total and
  per tax spread deductions for the previous year when total average earnings are negative */
/* Bug#4467198 - Modified the function to take care of legal employer changes. Introduced following
                 parameters in the function p_use_tax_flag, p_payroll_id, p_assignment_action_id*/
FUNCTION calculate_asg_prev_value
  ( p_assignment_id 	in 	per_all_assignments_f.assignment_id%TYPE,
    p_business_group_id in 	hr_all_organization_units.organization_id%TYPE,
    p_date_earned 	in 	date,
    p_tax_unit_id 	in 	hr_all_organization_units.organization_id%TYPE,
    p_assignment_action_id IN number, /* Bug#4467198*/
    p_payroll_id IN NUMBER, /* Bug#4467198*/
    p_period_start_date in 	date,
    p_case 		out 	NOCOPY varchar2,
    p_earnings_standard	out 	NOCOPY number,
    p_pre_tax_spread 	out 	NOCOPY number,
    p_pre_tax_fixed 	out 	NOCOPY number, /*bug4363057*/
    p_pre_tax_prog 	out 	NOCOPY number,  /*bug4363057*/
    p_paid_periods  	out 	NOCOPY number,
    p_use_tax_flag      IN      VARCHAR2 /* Bug#4467198*/
  )
  return NUMBER ;

-----------------------------------------------------------------------
  -- Cursor 	   : c_get_ytd_def_bal_ids
  -- Description   : To get the YTD defined balance ids for the balances
  --		     Earnings_Standard and Pre Tax Deductions
  --
  -----------------------------------------------------------------------
  CURSOR c_get_ytd_def_bal_ids (c_db_item_suffix IN pay_balance_dimensions.DATABASE_ITEM_SUFFIX%type)
  IS
  SELECT  pdb.defined_balance_id, pbt.balance_name, pbd.DIMENSION_NAME
  FROM pay_balance_types pbt,
         	 pay_balance_dimensions pbd,
         	 pay_defined_balances pdb
      WHERE pbt.balance_name in ( 'Earnings_Standard'
                                 ,'Pre Tax Spread Deductions'
                                 ,'Pre Tax Fixed Deductions'       /*bug4363057*/
                                 ,'Pre Tax Progressive Deductions'
                                 ,'Earnings_Leave_Loading') /*bug8725341*/
  	AND pbt.balance_type_id = pdb.balance_type_id
  	AND pdb.balance_dimension_id = pbd.balance_dimension_id
  	AND pbd.DATABASE_ITEM_SUFFIX = c_db_item_suffix --2610141
  	AND pbt.legislation_code = 'AU'
  	and pbt.legislation_code = pbd.legislation_code
  	AND pbd.legislation_code = 'AU';


  TYPE g_ytd_tab_bals IS TABLE OF c_get_ytd_def_bal_ids%rowtype INDEX BY BINARY_INTEGER;
  g_ytd_bals g_ytd_tab_bals;

  g_ytd_def_bals_populated  BOOLEAN;

  -- BBR Tables to store YTD balance details
  --
  g_ytd_input_table		pay_balance_pkg.t_balance_value_tab;
  g_ytd_result_table		pay_balance_pkg.t_detailed_bal_out_tab;
  g_ytd_context_table		pay_balance_pkg.t_context_tab;






/*
 *  round_amount  rounds values to nearest dollar
 *  new ATO Rounding  rules effective from year 2000
 */

function  round_amt
          (
            	p_actual_amt  in  number,
 		p_tax_scale   in   number
          )
          return number;

/*
 *  convert_to_period - converts weekly equivalents
 *  back to the period amounts using new ATO rules  effective from year 2000
 */

function  convert_to_period_amt
          (
            	p_ann_freq    in  number,
            	p_amt_week    in  number,
 		p_tax_scale   in   number
          )
          return number;

function check_if_retro
         (
                p_element_entry_id  in pay_element_entries_f.element_entry_id%TYPE,
                p_date_earned in pay_payroll_actions.date_earned%TYPE

         )return varchar2;


function get_retro_period
        (
             p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE,
             p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE, /*Bug 4418107*/
             p_retro_start_date out NOCOPY date,
             p_retro_end_date out NOCOPY date
        )return number;

function count_retro_periods
        (
           p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE,
           p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE, /*Bug 4418107*/
           p_use_tax_flag      IN VARCHAR2, --4415795
           p_mode IN VARCHAR2 DEFAULT 'E'  --7665727
        )return number;

/*bug 7665727*/
function count_retro_periods_2009
        (
           p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE,
           p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE, /*Bug 4418107*/
           p_use_tax_flag      IN VARCHAR2, --4415795
           p_mode IN VARCHAR2  --7665727
        )return number;



function calculate_tax(p_date_earned in pay_payroll_actions.date_earned%TYPE,
                       p_period_amount in number,
                       p_period_frequency in number,
                       p_tax_scale in number,
                       p_a1_variable in number,
                       p_b1_variable in number
                       )return number;


function check_fixed_deduction(p_assignment_id in per_all_assignments_f.assignment_id%TYPE, p_date_earned in date)
return varchar2;

/* Bug No : 2977425 - Added the new formula function */
FUNCTION get_table_value (BUSINESS_GROUP_ID IN hr_organization_units.business_group_id%TYPE,EARN_NAME IN VARCHAR2, scale IN varchar2,EARNING_VALUE IN number,PERIOD_DATE in date,a OUT NOCOPY varchar2, b OUT NOCOPY varchar2)
RETURN VARCHAR2;

/* Bug No : 3091834 - Added the new formula function below */

FUNCTION validate_data_magtape
(
   p_data   varchar2
) RETURN varchar2;


/* Bug No : 3306112 - The new function will be called from view "pay_au_asg_element_payments_v"
		 It return value of Hours in case the element_id passed is attached to the Salary Basis
*/
FUNCTION get_salary_basis_hours
(
   p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id in pay_element_entries_f.element_entry_id%TYPE,
   p_pay_bases_id    in per_all_assignments_f.pay_basis_id%TYPE
)
RETURN NUMBER;

/* Bug :3245909 - This function wil be used in AU_PAYMENTs route to get the pre payemnt actin id
*/
FUNCTION get_pp_action_id
(
   p_action_type in varchar2,
   p_action_id   in number
) RETURN number;

/*Bug# 3935471*/
FUNCTION check_tax_unit_id
(
   p_assignment_action_id NUMBER,
   p_tax_unit_id NUMBER
) RETURN VARCHAR2;

/* Bug 5556260 - In Enhanced Retropay, this function will be called to get the retro period
   and other related information for an element entry
*/
FUNCTION get_enhanced_retro_period
        (
             p_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned IN pay_payroll_actions.date_earned%TYPE,
             p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,
             p_retro_start_date OUT NOCOPY date,
             p_retro_end_date OUT NOCOPY date,
             p_orig_effective_date OUT NOCOPY date,
             p_retro_effective_date OUT NOCOPY date,
             p_time_span            OUT NOCOPY varchar2
        )return number;


/* Bug 5846272 - Function checks if Enhanced Retropay is enabled in system.
*/

FUNCTION check_if_enhanced_retro
        (
          p_business_group_id IN per_business_groups.business_group_id%TYPE
        )RETURN VARCHAR2;

/* Bug 5846272 - Function checks and returns the Retro time span
                 for element entry for Enhanced Retropay
*/

FUNCTION get_retro_time_span
         (
             p_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned IN pay_payroll_actions.date_earned%TYPE,
             p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,
             p_retro_start_date OUT NOCOPY date,
             p_retro_end_date OUT NOCOPY date,
             p_orig_effective_date OUT NOCOPY date,
             p_retro_effective_date OUT NOCOPY date,
             p_time_span            OUT NOCOPY varchar2,
             p_retro_type           OUT NOCOPY varchar2
             )return number;
/* Bug#5934468 */
function get_spread_earning
          ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
            p_date_paid in date,
            p_pre_tax in number,
            p_spread_earning in number) return number;

function get_retro_spread_earning
          ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
            p_date_paid in date,
            p_pre_tax in number,
            p_spread_earning in number) return number;

function get_etp_pay_component
          ( p_assignment_id in per_all_assignments_f.assignment_id%type,
            p_date_earned in date) return varchar2;

FUNCTION calc_average_earnings
                        (p_assignment_id            IN pay_assignment_actions.assignment_id%TYPE
                        ,p_assignment_action_id     IN pay_assignment_actions.assignment_action_id%TYPE
                        ,p_payroll_id               IN pay_payroll_actions.payroll_id%TYPE
                        ,p_tax_unit_id              IN pay_assignment_actions.tax_unit_id%TYPE
                        ,p_business_group_id        IN per_business_groups.business_group_id%TYPE
                        ,p_date_earned              IN pay_payroll_actions.date_earned%TYPE
                        ,p_period_start_date        IN DATE
                        ,p_emp_hire_date            IN DATE
                        ,p_earnings_std_ytd         IN NUMBER
                        ,p_earnings_std_ptd         IN NUMBER
                        ,p_taxable_value            IN NUMBER
                        ,p_average_earnings         OUT NOCOPY NUMBER
                        ,p_case                     OUT NOCOPY VARCHAR2)
RETURN NUMBER;

FUNCTION calc_lt12_prev_spread_tax
                        (p_assignment_id            IN pay_assignment_actions.assignment_id%TYPE
                        ,p_assignment_action_id     IN pay_assignment_actions.assignment_action_id%TYPE
                        ,p_tax_unit_id              IN pay_assignment_actions.tax_unit_id%TYPE
                        ,p_date_earned              IN pay_payroll_actions.date_earned%TYPE
                        ,p_business_group_id        IN pay_payroll_actions.business_group_id%TYPE
                        ,p_average_earnings         IN NUMBER
                        ,p_tax_scale                IN VARCHAR2
                        ,p_period_frequency         IN NUMBER
                        ,p_spread_tax               OUT NOCOPY NUMBER
                        )
RETURN VARCHAR2;


FUNCTION  get_retro_leave_load
            (p_assignment_action_id     IN         NUMBER
            ,p_tax_unit_id              IN         NUMBER
            ,p_retro_adj_leave_load     OUT NOCOPY NUMBER)
RETURN NUMBER;


end pay_au_paye_ff;

/
