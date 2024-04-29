--------------------------------------------------------
--  DDL for Package PAY_IE_PAYE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYE_PKG" AUTHID CURRENT_USER as
/* $Header: pyietax.pkh 120.5.12010000.4 2009/12/04 11:23:07 abraghun ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package header
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  20 JUN 2001 jmhatre  N/A       Created
**  18 OCT 2001 abhaduri N/A       Changes due to SOE form requirement
                                   added p_assess_basis and
                                   p_certificate_issue_date as OUT parameters
                                   to function get_paye_details for feeding
                                   them to PAYE details
**  05 DEC 2001 gpadmasa  N/A      Added dbdrv Commands
**  11 FEB 2002 abhaduri  N/A      Added input parameters - Reduced Tax Credit,
                                   Reduced Std Rate Cut Off and Benefit amt.
                                   for P45 data archiving and display.
**  26 JUN 2002 abhaduri  N/A      Added function get_calculated_period_values
                                   for calculating tax credits and cut offs
                                   according to user entered values and
                                   period types.
**  09-DEC-2002 smrobins  N/A      Added function get_pps_number, if no pps
                                   number exists for the person record
                                   linked to the assignment or if the tax
                                   basis emergency no pps is specifically
                                   selected for the assignment return 1.
**  16-MAY-2003 nsugavan  2943335  Added function Valid_Work_incidents.
**                                 This would return true if the work incident
**                                 entered on the screen exists for the person
**  04-jul-2003 asengar   3030621  Added two procedures insert_element_entry
**                                 and update_element_entry.
**  30-JUL-2003 asengar   3030616  Added four functions get_weekly_tax_credit
**                                 get_weekly_std_rate_cut_off,get_monthly_tax_credit
**                                 get_monthly_std_rate_cut_off.
**  09-FEB-2005 aashokan  4080773  Added a new procedure to create  new tax record
**				   if pay frequency is changed.
**  10-FEB-2005 aashokan           Modified dbdrv command.
**  10-Feb-2005 vikgupta  4080773  Modified the proc update_paye_change_freq (included
**                                 P_DATETRACK_UPDATE_MODE)
**  14-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq .
				   Passing all P45 items to hr_api.g_number. Also added
				   validation before Future Change.
** 15-Feb-2005  vikgupta  4080773  Removed dbdrv checkfile for pyietaxd.sql
** 22-Feb-2005  skhandwa  4080773  Added old_payroll_id variable handling
** 15-Dec-2005  vikgupta  4878630  Modified the signature of update_paye_change_freq
**                                 for tax credit upload process.
** 09-Jan-2006  vikgupta  5678929  Made decode_value_char, decode_value_date and
**                                 decode_value_number public
** 19-Feb-2007  vikgupta           SR 17140460.6, change the parameter passed to
**                                 update_paye_change_freq
** 09-Apr-2007  rbhardwa  5867343  Modified code to include new functions get_paye_tax_basis,
**                                 get_diff_tax_basis and get_ie_exclude_tax_basis.
** 05-May-2008  knadhan   6929566  Added new parameter to update_paye_change_frequency
** 05-Dec-2008  rrajaman  7622221  Ireland Budget 2009 New formula function
** 23-Dec-2008  rrajaman  7665572  get_age_date_paid for offset payroll support
** 03-Dec-2009  rrajaman  9177545  added get_periods_between function.
-------------------------------------------------------------------------------
*/

Function get_old_payroll_id return number;
Procedure set_old_payroll_id(
			      p_old_payroll_id number
			    );
Procedure unset_old_payroll_id;


Function get_paye_tax_basis (p_assignment_id              in           number         /* 5867343 */
                            ,p_payroll_action_id          in           number
                            ,p_tax_basis                  out nocopy  varchar2)
return number;

Function get_diff_tax_basis(p_assignment_id              in          number         /* 5867343 */
                            ,p_payroll_id                 in          number
			    ,p_date_earned                in          date)
return number;


Function get_ie_exclude_tax_basis(p_assignment_id              in          number         /* 5867343 */
                                 ,p_payroll_id                 in          number
			         ,p_date_earned                in          date)
 return number;


Function get_paye_details( p_assignment_id                in           number
                            ,p_payroll_action_id          in           number
                            ,p_info_source                out nocopy  varchar2
                            ,p_tax_basis                  out nocopy  varchar2
                            ,p_weekly_tax_credit          out nocopy  number
			    ,p_monthly_tax_credit	  out nocopy  number
                            ,p_weekly_std_rate_cutoff	  out nocopy  number
			    ,p_monthly_std_rate_cutoff	  out nocopy  number
			    ,p_certificate_start_date	  out nocopy  date
                            ,p_certificate_end_date	  out nocopy  date
                            /*changes for SOE form requirements*/
                            ,p_assess_basis               out nocopy  varchar2
                            ,p_certificate_issue_date     out nocopy  date
                            /***********************************************/
                            ,p_reduced_tax_credit         out nocopy  number
                            ,p_reduced_std_rate_cutoff    out nocopy  number
                            ,p_benefit_amount             out nocopy  number)
return number;

Function get_payroll_details( p_payroll_id            in            number
                           ,p_payroll_action_id       in            number
                           ,p_period_num              out nocopy  number
                           ,p_payroll_type            out nocopy  varchar2)
return number;

Function get_calculated_period_values(p_period_type in varchar2,
                                      p_period_ind in varchar2,
                                      p_actual_value in number)
return number;

Function get_pps_number( p_assignment_id              in           number
                        ,p_payroll_action_id          in           number)
return number;
-- Bug 2943335 added function to see if work incident exist for the person
-- This would return true if the work incident
-- entered on the screen exists for the person
function Valid_Work_incidents
(p_assignment_id                  in number
,p_date_earned                    in date
,p_reference                      in varchar2)
return varchar2;

/* Added following two procedures for BUG 3030621 */
--  -------------------------------------------------------------------
  --   procedure insert_element_entry
  --  -------------------------------------------------------------------

  procedure insert_element_entry
 (
  p_element_entry_id           in number
  );
--

  --  -------------------------------------------------------------------
  --  procedure update_element_entry
  --  -------------------------------------------------------------------

 procedure update_element_entry
 (
   p_element_entry_id           in number
 );
/* End of BUG 3030621 */
/*ADDED FOUR FUNCTIONS FOR BUG 3030616 */
function get_weekly_tax_credit
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number;
--
function get_weekly_std_rate_cut_off
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number;
--
function get_monthly_tax_credit
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number;
--
function get_monthly_std_rate_cut_off
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number;
/* End of BUG 3030616 */

/*Bug 4080773*/
PROCEDURE update_paye_change_freq(p_assignment_id			number
                                 ,p_effective_date			date
					   ,p_payroll_id				number
					   ,P_DATETRACK_UPDATE_MODE		VARCHAR2
					   ,p_tax_upload_flag			varchar2 default 'X'
					   ,p_tax_basis				varchar2 default null
					   ,p_cert_start_date			date default null -- 17140460.6
					   ,p_cert_end_date			date default null
					   ,p_weekly_tax_credit			number default null
				         ,p_monthly_tax_credit		number default null
			               ,p_weekly_std_rate_cut_off		number default null
					   ,p_monthly_std_rate_cut_off	number default null
					   ,p_tax_deducted_to_date		number default null
					   ,p_pay_to_date				number default null
					   ,p_cert_date                date); -- Bug 6929566

function decode_value_char(p_expression boolean,
                           p_true	     varchar2,
            		   p_false      varchar2) return varchar2;

function decode_value_date(p_expression boolean,
				   p_true	     date,
			         p_false      date) return date;

function decode_value_number(p_expression boolean,
				     p_true	     number,
				     p_false      number) return number;

FUNCTION get_age_payroll_period(p_assignment_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_date_earned     IN  DATE) RETURN NUMBER;

FUNCTION get_age_paid_year(p_assignment_id number,
                               p_payroll_action_id number) RETURN NUMBER;

FUNCTION get_periods_between(p_payroll_id number,
                               p_start_date date,
                               p_end_date date) RETURN NUMBER;

end;


/
