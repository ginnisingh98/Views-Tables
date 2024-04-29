--------------------------------------------------------
--  DDL for Package Body PAY_AU_PAYE_FF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_PAYE_FF" AS
/*  $Header: pyaufmla.pkb 120.32.12010000.15 2009/10/09 05:41:22 avenkatk ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU tax calculations
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  =========================================================
**  24-SEP-1999 makelly  115.0     Created for AU
**  31-JAN-2000 sclarke  115.1     Termination Taxation added
**  03-MAR-2000 sclarke  115.2     Changes to Terminations after testing
**  22-MAR-2000 sclarke  115.3     Changed calculate_marginal_tax to use
**                                 correct amount when tax variation is
**                                 percentage.
**  16-SEP-2000 sclarke  115.1     Removed Terminations, now in pay_au_terminations
**  20-DEC-2000 srikrish 115.5     Created function paid_periods_since_hire_date
**                                 which returns number of paid pay periods
**  19-DEC-2000 abajpai  115.6     Added new function convert_to_period_amt, round_amount
**  02-JAN-2001 abajpai  115.8     Added new parameter tax_scale for convert_to_period_amt, round_amount
**  function to check for existance of another current
**  payroll assignment for the employee
**
**  Package containing addition processing required by
**  formula in AU localisatons.
**
**  round_to_5c = rounds values to nearest 5c using
**  ATO rules
**  28-NOV-2001           115.10     Updated for GSCC Standards
**  07-DEC-2001 rsirigir  115.12     Update for GSCC Standards, added
**                                   REM checkfile:~PROD:~PATH:~FILE
**  8-JAN-2002 apunekar  115.13     Added new functions
**  18-May-2002 apunekar  115.14     Added new function
**  20-May-2002 apunekar  115.15     Updated function due to review
**  13-Jun-2002 nanuradh  115.21     Changed the cursor get_retro_period_ee (Bug 2415213)
**  10-Jul-2002 srussell  115.22   Change periods_since_hire_date to allow for
**                                 payrolls which go across financial year.
**                                 Bug 2450059.
**  06-Aug-2002 shoskatt  115.23     Cursor check_fixed_deduction has been tuned for
**                                   improving performance. Bug #2491328
**  17-Sep-2002 Ragovind  115.24     Modified the cursor check_fixed_deduction for performance. Bug#2563515
**  03-Dec-2002 Ragovind  115.25     Added NOCOPY for the function get_retro_period.
**  14-Apr-2003 Vgsriniv  115.26     Modified the function periods_since_hire_date. Bug:2900253
**  19-Aug-2003 punmehta  115.27     Modified conversion functions to support Quarterly Payroll. Bug:2888114
**  22-Aug-2003 srrajago  115.28     Added the new function 'validate_data_magtape'. Refer to Bug no : 3091834
**                                   This function will be used by Payment Summary Data File.
**  26-Aug-2003 srrajago  115.29     Modified function 'validate_data_magtape'.If the return value is null then
**                                   space is returned.
**  27-Aug-2003 srrajago  115.30     Function 'validate_data_magtape' has been modified to return ' '(space)
**                                   if value of the input string 'p_data' passed is Null.
**  03-Nov-2003 punmehta  115.31     Bug# 2977425 - Added the new formula function
**  19-Nov-2003 punmehta  115.32     Bug# 2977425 - Modified message name.
**  11-Dec-2003 jkarouza  115.33     Bug# 3172950 - Removed blank spaces from addresses when two or more
**                                   spaces between words.
**  23-Dec-2003 punmehta  115.34     Bug# 3306112 - Added the new formula function
**  24-Dec-2003 punmehta  115.35     Bug# 3306112 - Used cursor in the new function 'get_salary_basis_hours'
**  06-Feb-2004 punmehta  115.36     Bug# 3245909 - Added a new function get_pp_action for AU_Payments route
**  09-Feb-2004 punmehta  115.37     Bug# 3245909 - Coding Standards in get_pp_action
**  02-FEB-2004 abhkumar  115.38     Bug# 3665680 - Coding Standards in Cr_element_type_id
**  02-FEB-2004 abhkumar  115.39     Bug# 3665680 - Modfied Code to remove gscc warnings
**  07-JUL-2004 srrajago  115.40     Bug# 3724089 - Modified the cursor 'c_get_unprocessed_periods_num' to include table
**                                   per_assignments_f and its joins in the sub-query - Performance Fix.
**  09-AUG-2004 abhkumar  115.41     Bug# 2610141 - Modfied the code to support Legal Employer changes for an assignment.
**  12-AUG-2004 abhkumar  115.42     Bug# 2610141 - Modfied the code to use cursors instead of select query
**  08-SEP-2004 abhkumar  115.43     Bug# 2610141 - Added a flag "p_use_tax_flag" to function periods_since_hire_date and paid_periods_since_hire_date
**				     to support the versioning of the payroll tax formula.
*** 26-Apr-2005 abhkumar  115.44     Bug#3935471  - Changes due to Retro Tax enhancement.
*** 05-May-2005 abhkumar  115.45     Bug#3935471  - File Modified to put proper comments.
*** 10-May-2005 abhkumar  115.46     Bug#4357306  - Modified function count_retro_periods.
*** 06-Jun-1005 srussell  115.47     Bug#4412537  - Modified count_retro_periods
                so that INDEX BY is binary_integer, not varchar2 so that it
                doesnt get compile error on 8.1.7.4 data bases.
*** 06-Jun-1005 srussell  115.48     Bug#4412537  - Updated comments.
*** 06-Jun-2005 avenkatk  115.49     Bug#4412537  - Changed to_number to to_number(to_char()) to get l_retro_end_date.
*** 06-Jun-2005 avenkatk  115.50     Bug#4412537  - Removed commented code and Removed redundant to_date() to resolve gscc errors.
*** 07-Jun-2005 abhkumar  115.51     Bug#4415795  - Added new parameter to function count_retro_periods.
*** 23-Jun-2005 abhkumar  115.52     Bug#4438644  - Modified function paid_periods_since_hire_date
*** 26-Jun-2005 avenkatk  115.53     Bug#4451088  - Modified function periods_since_hire_date
*** 26-Jun-2005 avenkatk  115.54     Bug#4451088  - Removed the trace fucntion call.
*** 27-Jun-2005 abhkumar  115.55     Bug#4456941  - Modified function count_retro_periods
*** 27-Jun-2005 ksingla   115.56     Bug#4456720  - Added a new function CALCULATE_ASG_PREV_VALUE for negative retro earnings
*** 05-JuL-2005 abhkumar  115.57     Bug#4467198 - Modified function CALCULATE_ASG_PREV_VALUE for zero average earnings
*** 05-JuL-2005 abhkumar  115.58     Bug#4467198 - Modified cursor c_get_paid_periods and c_check_payroll_run for performance fix.
*** 13-Jul-2005 abhargav  115.59     Bug#4363057 - Modified function CALCULATE_ASG_PREV_VALUE to include fix for bug# 3855355 .
*** 14-Jul-2005 abhkumar  115.60     Bug#4418107  - Modified function count_retro_periods and get_retro_periods to consider Legal Employer changes
*** 08-Aug-2005 abhargav  115.62     Bug#4521653  - Modified the function CALCULATE_ASG_PREV_VALUE .
*** 01-SEP-2005 abhkumar  115.63     Bug#4474896 - Average Earnings enhancement
*** 09-Sep-2005 avenkatk  115.64     Bug#4374115  - Added check in check_fixed_deduction for Reverse Runs.
*** 05-Oct-2005 abhargav  115.65     Bug#4588483  - Modified Cursor check_fixed_deduction.
*** 05-Jul-2006 srussell  115.66     Bug#5374076  - Modified function count_retro_periods to check the retro amounts for each
***                                                 period. If they're zero then don't count the period.
***10-JUL-2006 hnainani  115.67      Bug#5371901    Removed Date_Earned check from function Periods_Since_Hire_date to force
***                                                 code to use Effective Date to calculate numberof periods
*** 11-JUl-2006 hnainani 115.68     Bug#5371901     Modified Comments in function Periods_Since_Hire_Date to correctly
**
**                                                  reflect reason for changes.
*** 19-Jul-2006 hnainani 115.69      Bug#5397711    Changed tot_period_amount_type in Countr_Retro_Periods to Number
                                                    instead of  Number(10) to cater for decimals
*** 09-Oct-2006 avenkatk 115.71      Bug#5586445    Included function get_enhanced_retro_period.
*** 01-Dec-2006 priupadh 115.72      Bug#5676709    Added debug messages to functions
*** 01-Dec-2006 priupadh 115.73      Bug#5676709    removed the occurence of to_date and dd-mon-yyyy format from debug message for GSCC compliance.
*** 17-Jan-2006 avenkatk 115.74      Bug#5846272    Introduced new functions,
**                                                   i.  check_if_enhanced_retro
**                                                   ii. get_retro_time_span
**  16-FEB-2006 priupadh 115.75      N/A            Version to restore triple maintanence between 11i,R12 Branch and R12 Mainline
**  10-Apr-2007 abhargav 115.77      Bug#5934468    Added new function get_spread_earning() this function gets called from
                                                     formula AU_HECS_DEDUCTION and AU_SFSS_DEDUCTION.
**  18-Apr-2007 avenkatk 115.78      Bug#6001930    Modified Function periods_since_hire_date for
**                                                  Postive Offset Payrolls.
**  18-Jun-2007 avenkatk 115.79      Bug#6139035    Modified Function count_retro_periods and get_enhanced_retro_perio - Function
**                                                  modified to mark retro time spans based on Date Paid(Effective Date) of
**                                                  Payroll run/Quickpay.
**  17-Jan-2008 skshin   115.80      Bug#6669058    Modified function get_spread_earning and added new function get_retro_spread_earning.
**  18-FEB-2008 skshin   115.81      Bug#6809877    Added new function get_etp_pay_component.
**  09-OCT-2008 skshin   115.83      Bug#7228256    Removed DISTINCT from c_get_le_period_num cursor
**  20-APR-2009 skshin   115.85      Bug#7665727    Created count_retro_periods_2009 called from count_retro_periods and modified get_spread_earning function for HECS/SFSS calculation after 01-JUL-2009.
**  20-APR-2009 skshin   115.87      Bug#8406009    Added new function calc_average_earnings and calc_lt12_prev_spread_tax
**  15-JUL-2009 skshin   115.89      Bug#8630738    Modified cursor get_element_entries in count_retro_periods_2009 to return rows for Pre Tax Deduction
**  15-JUL-2009 skshin   115.90      Bug#8682739    Modified cursor c_get_le_period_num in periods_since_hire_date to be based on date_earned
**  30-JUL-2009 skshin   115.91      Bug#8725341    Added Earnings_Leave_Loading balance to be retrieved effective from 01-JUL-2009 in calculate_asg_prev_value function
**  01-SEP-2009 skshin   115.92      Bug#8847457    Added check to select assignment action_status = 'C' to check_fixed_deduction cursor in check_fixed_deduction function
**  08-Oct-2009 avenkatk 115.93      Bug#8765082    Added New Function get_retro_leave_load
*/

g_debug boolean;

  function  round_to_5c
  (
    p_actual_amt   in   number
  )
  return number is


  l_cents          number;
  l_rnd_amt        number;


  begin
    g_debug := hr_utility.debug_enabled;
    l_cents := p_actual_amt - trunc(p_actual_amt,1);

    if l_cents <= 0.025 then
      l_rnd_amt := 0;
    elsif l_cents > 0.075 then
      l_rnd_amt := 0.1;
    else
      l_rnd_amt := 0.05;
    end if;

    return (trunc(p_actual_amt,1) + l_rnd_amt);

    exception
      when others then
        null;

  end round_to_5c;


/*
 *  convert_to_period - converts weekly equivalents
 *  back to the period amounts using ATO rules.
 */

  function  convert_to_period
  (
    p_ann_freq   in   number,
    p_amt_week   in   number
  )
  return number is

  l_amt_period          number;

  begin
    g_debug := hr_utility.debug_enabled;
    if p_ann_freq = 52 then
      l_amt_period := p_amt_week;
    elsif p_ann_freq = 26 then
      l_amt_period := (p_amt_week * 2);
    elsif p_ann_freq = 24 then
      l_amt_period := round_to_5c (p_amt_week * 13 / 6);
    elsif p_ann_freq = 12 then
      l_amt_period := round_to_5c (p_amt_week * 13 / 3);
    elsif p_ann_freq = 4 then	/*Bug : 2888114*/
      l_amt_period := p_amt_week * 13;
    end if;

    return (l_amt_period);

    exception
      when others then
        null;

  end convert_to_period;


/*
 *  convert_to_week - converts period amounts to equivalents
 *  weekly equivalents using ATO rules.
 */

  function  convert_to_week
  (
    p_ann_freq    in   number,
    p_amt_period  in   number
  )
  return number is

  l_amt_week          number    := 0;
  l_new_amt           number;

  begin
    g_debug := hr_utility.debug_enabled;
    if p_ann_freq = 52 then
      l_amt_week := trunc (p_amt_period) + 0.99;
    elsif p_ann_freq = 26 then
      l_amt_week := trunc (p_amt_period / 2) + 0.99;
    elsif p_ann_freq = 24 then
      if (p_amt_period - trunc (p_amt_period)) = 0.33 then
        l_new_amt := p_amt_period + 0.01;
      else
        l_new_amt := p_amt_period;
      end if;
      l_amt_week := trunc (l_new_amt * 6 / 13) + 0.99;
    elsif p_ann_freq = 12 then
      if (p_amt_period - trunc (p_amt_period)) = 0.33 then
        l_new_amt := p_amt_period + 0.01;
      else
        l_new_amt := p_amt_period;
      end if;
      l_amt_week := trunc (l_new_amt * 3 / 13) + 0.99;
    elsif p_ann_freq = 4 then  	/*Bug : 2888114*/
          l_amt_week := trunc (p_amt_period/13) + 0.99;
    end if;

    return (l_amt_week);

    exception
      when others then
        null;

  end convert_to_week;


/*
 *  periods_since_hire_date - returns the number of periods in the
 *  current tax year since the hire date.
 */


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
          return number is

  l_year_start              date;
  l_month_no                number;
  l_year                    number;
  l_period_num              number;
  /* Bug#2900253 */
  l_leg_emp_date            date;
  l_check_date              date;
  l_period_end              date;
  l_procedure               varchar2(80);
  /* Bug:2900253 Added following cursor to get the date on which this assignment is
     Enrolled into the legal employer existing as of this period start date */

 /*Bug 4474896 - Modified cursor to pick the correct effective start date for the legal employer*/

  cursor get_legal_emp_start_date (c_assignment_id per_all_assignments_f.assignment_id%type) is
     select min(effective_start_date)
       from per_all_assignments_f paf,
            hr_soft_coding_keyflex hsck
      where paf.assignment_id = c_assignment_id
        and paf.SOFT_CODING_KEYFLEX_ID = hsck.soft_coding_keyflex_id
        and hsck.segment1 = p_tax_unit_id
        AND paf.effective_start_date <= l_period_end
        AND paf.effective_end_date >= l_year_start;

/*Bug 2610141 - Cursor added to get the number of periods in the current year for an assignment assigned to a legal
  employer */

 /*Bug# 4474896 - Cursor modified to count periods on the basis of current payroll id
   Bug# 6001930 - Modified Cursor for postive offset payrolls. Now periods will be
                  counted based on the Regular Payment Date.
    Bug 8682739 - Modified for positve offset payrolls as  l_period_end is now based on
                          date_earned. */

  cursor c_get_le_period_num is
      select count(ptp1.time_period_id) /*Bug 4438644, 6001930, 7228256*/
        from  per_time_periods ptp
             ,per_time_periods ptp1
        where exists (select 'EXISTS' from
             per_assignments_f   paf,
             hr_soft_coding_keyflex hsck
       where paf.assignment_id = p_assignment_id
        and  paf.SOFT_CODING_KEYFLEX_ID = hsck.soft_coding_keyflex_id
        and  hsck.segment1 = p_tax_unit_id
        AND  paf.effective_start_date <= l_period_end
        AND  paf.effective_end_date >= l_year_start
        AND  paf.effective_start_date <= ptp.end_date
        AND  paf.effective_end_date >= ptp.start_date)
        AND  ptp.payroll_id = p_payroll_id
        AND  ptp.start_date <= l_period_end
--        AND  ptp.end_date >= l_year_start  /* Commented Bug 6001930 */
        /* Bug 6001930 - Start Changes */
        AND  ptp.regular_payment_date >= l_year_start
        AND  ptp.payroll_id     = ptp1.payroll_id
        AND  ptp.regular_payment_date BETWEEN ptp1.start_date AND ptp1.end_date;
--        AND  ptp1.start_date  >= l_year_start /* Commented Bug 6139035 */
--        AND  ptp1.end_date    <= l_period_end; /* Commented bug 8682739 */
        /* Bug 6001930 - End Changes */

  cursor c_get_period_num (v_payroll_id number,
                           v_hire_date  date) is
      select period_num
        from per_time_periods
       where payroll_id = v_payroll_id
         and v_hire_date between start_date and end_date;


/* Bug 2610141 - Cursor to Get the Period END date
   Bug 4451088 - Changed Cursor to return end dates based in Input Date
   */

 CURSOR c_get_period_end_date(c_date date)
    IS
   select ptp.end_date
    from per_time_periods ptp
    where ptp.payroll_id = p_payroll_id
    and  c_date between
         ptp.start_date and ptp.end_date;

/* Bug 4451088 - The following cursors have been introduced */

l_date_earned date;
l_effective_date date;
l_date_earn_yr_start   date;


CURSOR csr_get_pay_dates
IS
select ppa.date_earned,
       ppa.effective_date
from   pay_payroll_actions ppa,
       pay_assignment_actions paa
where ppa.payroll_action_id = paa.payroll_action_id
and   paa.assignment_action_id = p_assignment_action_id;


cursor get_period_num(c_start_date date,
                      c_end_date date)
is
select count(*)
from per_time_periods ptp
where payroll_id = p_payroll_id
and   ptp.end_date
  between c_start_date and c_end_date;

  begin
     g_debug := hr_utility.debug_enabled;

 if g_debug then
    l_procedure :='pay_au_paye_ff.periods_since_hire_date';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN  p_payroll_id          '||p_payroll_id,20);
  hr_utility.set_location('IN  p_assignment_id       '||p_assignment_id,25);
  hr_utility.set_location('IN  p_tax_unit_id         '||p_tax_unit_id,30);
  hr_utility.set_location('IN  p_assignment_action_id'||p_assignment_action_id,35);
  hr_utility.set_location('IN  p_period_num          '||p_period_num,40);
  hr_utility.set_location('IN  p_period_start        '||to_char(p_period_start,'dd/mm/yyyy'),45);
  hr_utility.set_location('IN  p_emp_hire_date       '||to_char(p_emp_hire_date,'dd/mm/yyyy'),50);
  hr_utility.set_location('IN  p_use_tax_flag        '||p_use_tax_flag,55);

 end if;

    l_check_date := p_emp_hire_date;
 /* Bug# 2450059 Always return 1 if payroll period is 1 */

/* Bug 4451088 - Introduced the following logic to get number of period  ,
    1. IF Date Earrned and Eff Date in Same Fin Year,
       Start Date : Financial Year Start Date (Effective Date)
       End Date   : End Date ( Date Earned)
    2. IF Date Earrned and Eff Date in Different Fin Year,
       Start Date : Financial Year Start Date (Effective Date)
       End Date   : End Date ( Effective Date)

       Count No of periods in per_time_periods between Start Date/End Date
*/

/* Bug# 5371901 - Changed the above logic to take out "Date_Earned" if Condition
                  and instead use only "Effective Date"
                  Checked with PM , In AU for all Payments we should only look at Effective Date .
                  We can have cases wherein the Date_Earned Falls in the Previous Year -
                  their Effective Date still falls in the current Year (due to Offsets) -

                  e.g  Pay Period : 17-Jun-2006 to 30-JUN-2006 (Offsets +6)
                  Date_Earned   :- 30-JUN-2006
                  Effective Date:- 06-JUL-2006

                  This means that the Earnings should be considered for the Current Year.
*/


     open csr_get_pay_dates;
     fetch csr_get_pay_dates into l_date_earned,l_effective_date;
     close csr_get_pay_dates;

    l_month_no     := to_number(to_char(l_effective_date,'MM'));
    l_year         := to_number(to_char(l_effective_date,'YYYY'));

    if l_month_no > 6 then
      l_year_start := to_date('01-07-'||to_char(l_year),'DD-MM-YYYY');
    else
      l_year_start := to_date('01-07-'||to_char(l_year - 1),'DD-MM-YYYY');
    end if;

    l_month_no     := to_number(to_char(l_date_earned,'MM'));
    l_year         := to_number(to_char(l_date_earned,'YYYY'));

    if l_month_no > 6 then
      l_date_earn_yr_start := to_date('01-07-'||to_char(l_year),'DD-MM-YYYY');
    else
      l_date_earn_yr_start := to_date('01-07-'||to_char(l_year - 1),'DD-MM-YYYY');
    end if;


/* Bug# 5371901 */
  /*  if (l_year_start = l_date_earn_yr_start) then */
         /* bug 8682739
             when Date Paid in Quickpay is entered within the period for postive offset payroll,
             number of periods is returned as one less than the expected.
             Now it is changed to return period end date based on Date Earned instead of Date Paid */
         open c_get_period_end_date(l_date_earned);
         fetch c_get_period_end_date into l_period_end;
         close c_get_period_end_date;
--    else
/* bug 8682739
         open c_get_period_end_date(l_effective_date);
         fetch c_get_period_end_date into l_period_end;
         close c_get_period_end_date; */
--    end if;

    /* Bug:2900253 Get the Legal Employer start date. If the employee
       changes Legal Employer then, Period number should be counted
       starting from Legal Employer start date instead of Hire Date */

    open get_legal_emp_start_date(p_assignment_id);
    fetch get_legal_emp_start_date into l_leg_emp_date;
    close get_legal_emp_start_date;

    if l_leg_emp_date > p_emp_hire_date then
       l_check_date := l_leg_emp_date;
    else
       l_check_date := p_emp_hire_date;
    end if;

    /* End of Bug:2900253 */


  IF p_use_tax_flag = 'N' THEN

     open get_period_num(greatest(l_check_date,l_year_start),
                         l_period_end);
     fetch get_period_num into l_period_num;
     close get_period_num;

     if g_debug then
          hr_utility.trace('Value to be returned l_period_num =='||l_period_num);
      hr_utility.set_location('Exiting '||l_procedure,70);
     end if;

     return l_period_num;

  ELSE

     open c_get_le_period_num; /*Bug 2610141 - It will give us the correct pay periods for a particular le
                                       legal employer change has taken place in the year.*/
     fetch c_get_le_period_num into l_period_num;
     close c_get_le_period_num;


     if g_debug then
          hr_utility.trace('Value to be returned l_period_num =='||l_period_num);
      hr_utility.set_location('Exiting '||l_procedure,70);
     end if;

      return l_period_num;
  end if;

    exception
      when others then
        null;

end periods_since_hire_date;


/* Bug 4456720  - Added a new function to calculate the earnings_total and
  per tax spread deductions for the previous year when total average earnings are negative */
/* Bug#4467198 - Modified the function to take care of legal employer changes. Introduced following
                 parameters in the function p_use_tax_flag, p_payroll_id, p_assignment_action_id*/
 FUNCTION calculate_asg_prev_value
  ( p_assignment_id 	in 	per_all_assignments_f.assignment_id%TYPE,
    p_business_group_id in 	hr_all_organization_units.organization_id%TYPE,
    p_date_earned 	in 	date,
    p_tax_unit_id 	in 	hr_all_organization_units.organization_id%TYPE,
    p_assignment_action_id IN number,
    p_payroll_id IN NUMBER,
    p_period_start_date in 	date,
    p_case 		out 	NOCOPY varchar2,
    p_earnings_standard	out 	NOCOPY number,
    p_pre_tax_spread 	out 	NOCOPY number,
    p_pre_tax_fixed 	out 	NOCOPY number, /*bug4363057*/
    p_pre_tax_prog 	out 	NOCOPY number,  /*bug4363057*/
    p_paid_periods  	out 	NOCOPY number,
    p_use_tax_flag      IN      VARCHAR2 --2610141
  )
  return NUMBER is
  -----------------------------------------------------------------------
  -- Variables
  -----------------------------------------------------------------------
  g_debug 	boolean;
  l_procedure 	varchar2(80);

  -- This year Financial Start and End Dates
  --
  l_fin_start_date date;
  l_fin_end_date date;

  -- Last Year Financial Start and End Dates
  --
  l_prev_yr_fin_start_date 	date ;
  l_prev_yr_fin_end_date 	date ;
  l_eff_date DATE; /* Bug#4467198*/


  -- Variable to store the maximum previous year assignment action id and its corresponding
  -- tax_unit_id (legal Employer).
  l_asg_act_id 		pay_assignment_actions.assignment_action_id%TYPE;
  l_tax_unit_id 	pay_assignment_actions.tax_unit_id%TYPE;


  -- Total Earnings variable
  --
  l_total_earnings 	number;

  -- Loop Counter variable
  --
  i number;


  -----------------------------------------------------------------------
  -- Cursor 	 : c_get_prev_year_max_asg_act_id
  -- Description : To get the Previous Year Maximum Assignment Action ID
  --		   for a given Assignment_id in a Financial Year.
  --               If there exists any LE changes, then it gets the max
  -- 		   Assignment Action ID .
  -----------------------------------------------------------------------
  CURSOR c_get_prev_year_max_asg_act_id
  ( c_assignment_id 	in per_all_assignments_f.assignment_id%TYPE,
    c_business_group_id in hr_all_organization_units.organization_id%TYPE,
    c_fin_start_date 	in date,
    c_fin_end_date 	in date)
  IS
  SELECT paa.assignment_action_id, paa.tax_unit_id, ppa.payroll_id
  FROM 	pay_assignment_actions paa
       ,pay_payroll_actions ppa
  WHERE paa.assignment_id = c_assignment_id
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.business_group_id = c_business_group_id
  AND   paa.action_sequence in
               (
		SELECT MAX(paa.action_sequence)
		  FROM 	pay_assignment_actions paa,
			pay_payroll_actions ppa,
			per_all_assignments_f paaf
		  WHERE ppa.business_group_id = c_business_group_id
		  AND paaf.assignment_id = c_assignment_id
		  AND paa.assignment_id = paaf.assignment_id
                  AND paa.action_status='C'
		  AND ppa.payroll_action_id = paa.payroll_action_id
		  AND ppa.action_type in ('Q','R','B','I','V') --2610141
		  AND ppa.effective_date between c_fin_start_date AND c_fin_end_date /*4521653 replaced the date_earned with effective date*/
		  AND paa.tax_unit_id = p_tax_unit_id --2610141
  	 	)
   ORDER BY date_earned desc;


  CURSOR c_get_pre_le_max_asg_act_id
  ( c_assignment_id 	in per_all_assignments_f.assignment_id%TYPE,
    c_business_group_id in hr_all_organization_units.organization_id%TYPE,
    c_fin_start_date 	in date,
    c_fin_end_date 	in date)
  IS
  SELECT paa.assignment_action_id, paa.tax_unit_id, ppa.payroll_id, ppa.effective_date
  FROM 	pay_assignment_actions paa
       ,pay_payroll_actions ppa
  WHERE paa.assignment_id = c_assignment_id
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.business_group_id = c_business_group_id
  AND   paa.action_sequence in
               (
		SELECT MAX(paa.action_sequence)
		  FROM 	pay_assignment_actions paa,
			pay_payroll_actions ppa,
			per_all_assignments_f paaf
		  WHERE ppa.business_group_id = c_business_group_id
		  AND paaf.assignment_id = c_assignment_id
                  AND paa.action_status='C'
		  AND paa.assignment_id = paaf.assignment_id
		  AND ppa.payroll_action_id = paa.payroll_action_id
		  AND ppa.action_type in ('Q','R','B','I','V')
		  AND ppa.effective_date between c_fin_start_date AND c_fin_end_date /*4521653 replaced the date_earned with effective date*/
  	 	)
   ORDER BY date_earned desc;


  ---
  -----------------------------------------------------------------------
    -- Cursor 	   : c_get_paid_period_no_prev_year
    -- Description : To get the Previous Year number of periods paid to the
    --		     given Assignment_id in previous Financial Year
    /* Bug#4467198 -  Modified the name of cursor to c_get_paid_periods
                      Logic of the cursor has been changed to pick correct paid
                      periods on the basis of the current payroll id*/
  -----------------------------------------------------------------------


/*Bug 4474896 - Cursor c_get_paid_periods changed to c_get_periods and logic for the cursor modified
                to count number of pay periods between greatest of (employee's hire date, financial year start date,
                Legal Employer start date) and current period end date*/

  cursor c_get_periods
  (c_tax_unit_id 		in hr_all_organization_units.organization_id%TYPE,
   c_payroll_id  		in pay_payrolls_f.payroll_id%TYPE,
   c_start_date 	in date,
   c_end_date 	in date)
  is
  select count(DISTINCT ptp.time_period_id)
        from per_time_periods ptp
        where exists (select 'EXISTS' from
             per_assignments_f   paf,
             hr_soft_coding_keyflex hsck
       where paf.assignment_id = p_assignment_id
        and  paf.SOFT_CODING_KEYFLEX_ID = hsck.soft_coding_keyflex_id
        and  hsck.segment1 = c_tax_unit_id
        AND  paf.effective_start_date <= c_end_date
        AND  paf.effective_end_date >= c_start_date
        AND  paf.effective_start_date <= ptp.end_date
        AND  paf.effective_end_date >= ptp.start_date)
        AND  ptp.payroll_id = c_payroll_id
        AND  ptp.start_date <= c_end_date
        AND  ptp.end_date >= c_start_date;

/* Bug#4467198 - Cursor below gives the payroll effective date for the current payroll run*/

  CURSOR c_get_payroll_effective_date
  IS
  SELECT ppa.effective_date
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa
  WHERE paa.assignment_action_id  = p_assignment_action_id
  AND ppa.payroll_action_id = paa.payroll_action_id;

/* Bug#4467198 - Use the below cursor to check if this is the first for the assignment in this year*/

  CURSOR c_check_payroll_run (c_assignment_id 		in per_all_assignments_f.assignment_id%TYPE,
   c_business_group_id 		in hr_all_organization_units.organization_id%TYPE,
   c_start_date 	in date,
   c_end_date 	in date)
  IS
  SELECT count(paa.assignment_action_id)
  FROM pay_assignment_actions paa,
       pay_payroll_actions ppa,
	    per_assignments_f paf
  WHERE ppa.effective_date BETWEEN c_start_date AND c_end_date
  AND   ppa.business_group_id = c_business_group_id
  AND   ppa.payroll_action_id = paa.payroll_action_id
  AND   paa.assignment_id = c_assignment_id
  AND   paa.assignment_id = paf.assignment_id
  AND   ppa.effective_date between paf.effective_start_date and paf.effective_end_date
  AND   paa.action_status = 'C'
  AND   paa.source_action_id IS NULL /*Bug 4418107 - This join added to only pick master assignment action id*/
  AND   ppa.action_type IN ('Q','R');



  c_ytd_input_table c_get_ytd_def_bal_ids%rowtype;
  l_use_le_balances varchar2(50);
  l_db_item_suffix pay_balance_dimensions.database_item_suffix%type;
  l_payroll_id number;
  l_pay_eff_date DATE;
  l_flag number;
  l_counter number;
  l_leave_loading number := 0;  /*bug8725341*/

  BEGIN


  g_ytd_def_bals_populated  	:= FALSE;
  l_flag                        := -1;
  p_earnings_standard 		:= 0;
  p_pre_tax_spread 		:= 0;
  p_pre_tax_fixed 		:= 0; /*bug4363057*/
  p_pre_tax_prog 		:= 0;
  i 				:= 1;
  p_case                        :='USE_PREV_EARNINGS';
  g_debug 			:= hr_utility.debug_enabled;

  OPEN c_get_payroll_effective_date; /* Bug#4467198 */
  FETCH c_get_payroll_effective_date INTO l_eff_date; /* Bug#4467198 */
  CLOSE c_get_payroll_effective_date; /* Bug#4467198 */

  IF g_debug THEN
    l_procedure 			:= 'pay_au_paye_ff.calculate_asg_prev_value';
    hr_utility.set_location('Entering    '||l_procedure, 		10);
    hr_utility.set_location('IN     p_assignment_id :      ' ||p_assignment_id,20);
    hr_utility.set_location('IN     p_business_group_id    ' ||p_business_group_id,25);
    hr_utility.set_location('IN     p_date_earned          ' ||p_date_earned,30);
    hr_utility.set_location('IN     p_tax_unit_id          ' ||p_tax_unit_id,35);
    hr_utility.set_location('IN     p_period_start_date    ' ||p_period_start_date,40);
    hr_utility.set_location('IN     p_case                 ' ||p_case,45);
    hr_utility.set_location('IN     p_date_earned          ' ||to_char(p_date_earned,'dd/mm/yyyy'),50);
    hr_utility.set_location('IN     p_use_tax_flag         ' ||p_use_tax_flag,50);
  END IF;

  /*Bug#4467198 Find the Financial Year Start and End Dates on the basis of effective date of the current payroll run.*/

  IF MONTHS_BETWEEN(l_eff_date,TRUNC(l_eff_date,'Y')) < 6 THEN
     l_fin_start_date := to_date('01-07-'||to_char(add_months(trunc(l_eff_date,'Y'),-9),'YYYY'),'DD-MM-YYYY');
     l_fin_end_date   := to_date('30-06-'||to_char(add_months(trunc(l_eff_date,'Y'),+3),'YYYY'),'DD-MM-YYYY');
     -- For Previous Fin Year
     l_prev_yr_fin_start_date := to_date('01-07-'||to_char(add_months(trunc(l_eff_date,'Y'),-9-12),'YYYY'),'DD-MM-YYYY');
     l_prev_yr_fin_end_date   := to_date('30-06-'||to_char(add_months(trunc(l_eff_date,'Y'),+3-12),'YYYY'),'DD-MM-YYYY');
  ELSE
     l_fin_start_date := to_date('01-JUL-'||to_char(l_eff_date,'YYYY'),'DD-MM-YYYY');
     l_fin_end_date   := to_date('30-JUN-'||to_char(add_months(l_eff_date,12),'YYYY'),'DD-MM-YYYY');
     -- For Previous Fin Year
     l_prev_yr_fin_start_date := to_date('01-07-'||to_char(add_months(l_eff_date,-12),'YYYY'),'DD-MM-YYYY');
     l_prev_yr_fin_end_date   := to_date('30-06-'||to_char(trunc(l_eff_date,'Y'),'YYYY'),'DD-MM-YYYY');

  END IF;

  IF g_debug THEN
    hr_utility.set_location('l_fin_start_date: '|| l_fin_start_date, 55);
    hr_utility.set_location('l_fin_end_date:   '|| l_fin_end_date, 60);

    hr_utility.set_location('l_prev_yr_fin_start_date: '|| l_prev_yr_fin_start_date, 65);
    hr_utility.set_location('l_prev_yr_fin_end_date:   '|| l_prev_yr_fin_end_date, 70);
  END IF;

/* Bug#4467198 - Use the below cursor to check if this is the first for the assignment in this year*/
  OPEN c_check_payroll_run(p_assignment_id,
            p_business_group_id,
  	         l_fin_start_date,
  	         l_eff_date);
  FETCH c_check_payroll_run INTO l_counter;
  CLOSE c_check_payroll_run;




/* Bug 2610141 - Get the Maximum assignment action id for the Previous Financial Year for the current
   Legal Employer or the maximum assignment action id for previous legal employer for the
   current year*/

IF l_counter = 0 OR p_use_tax_flag = 'N' THEN
     OPEN c_get_prev_year_max_asg_act_id(p_assignment_id, p_business_group_id, l_prev_yr_fin_start_date, l_prev_yr_fin_end_date);
     FETCH c_get_prev_year_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id;
     CLOSE c_get_prev_year_max_asg_act_id;
     IF nvl(l_asg_act_id,-99999) <> -99999 THEN /*Bug 4418107*/
        l_flag := 1; /* Flag is set to 1 when we take YTD earnings for previous year for the current legal employer*/
     END IF;
ELSE
     OPEN c_get_pre_le_max_asg_act_id(p_assignment_id, p_business_group_id, l_fin_start_date, l_eff_date - 1 ); /*4521653 replaced  p_period_start_date with l_eff_date */
     FETCH c_get_pre_le_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id, l_pay_eff_date;
     CLOSE c_get_pre_le_max_asg_act_id;
     IF nvl(l_asg_act_id,-99999) <> -99999 THEN /*Bug 4418107*/
        l_flag := 2; /* Flag is set to 2 when we take YTD earnings for current year for the previous legal employer*/
     END IF;
END IF;


IF l_flag <> 1 AND l_flag <> 2 THEN
     OPEN c_get_pre_le_max_asg_act_id(p_assignment_id, p_business_group_id, l_prev_yr_fin_start_date, l_prev_yr_fin_end_date);
     FETCH c_get_pre_le_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id, l_pay_eff_date;
     CLOSE c_get_pre_le_max_asg_act_id;
     l_flag := 3; /* Flag is set to 3 when we take YTD earnings for previous year for the legal employer effective on               on the last run of year*/
END IF;


     IF g_debug THEN
     	hr_utility.set_location('l_flag:                         '|| l_flag, 75);
     	hr_utility.set_location('l_asg_act_id:                   '|| l_asg_act_id, 75);
     	hr_utility.set_location('g_context_table(1).tax_unit_id: '|| l_tax_unit_id, 80);
     	hr_utility.set_location('l_payroll_id:                   '||l_payroll_id, 85);
     	hr_utility.set_location('p_tax_unit_id :                 '||p_tax_unit_id, 90);
     END IF;


     IF nvl(l_asg_act_id,-99999) = -99999 THEN
     /* There is no payroll actions exist in the previous financial year and also there is no
        actions present in the current year. This means the customer go live and this is the
        first payroll action
        For this case, need to populate message to the user in order to process the Termination
        Payments Manually. For this set the p_case to 'POPULATE_MSG'
        Average_Earnings will not be calculated.
     */
        p_case := 'POPULATE_MSG';
        IF g_debug THEN
	    hr_utility.set_location('p_case: '|| p_case, 95);
	    hr_utility.set_location('Exiting '||l_procedure,105);
	END IF;
        RETURN 110;

     ELSE

       /* Bug 2610141 - Get the Total Number of Paid Periods for the Previous Financial Year for the current
          Legal Employer or the number of paid periods of the previous legal employer for the
	  current year*/
       IF l_flag = 1 OR l_flag = 3 THEN
       	OPEN c_get_periods
           (l_tax_unit_id,
            l_payroll_id,
  	         l_prev_yr_fin_start_date,
  	         l_prev_yr_fin_end_date);
	      FETCH c_get_periods INTO p_paid_periods;
	      CLOSE c_get_periods;
       ELSE
	      OPEN c_get_periods
           (l_tax_unit_id,
            l_payroll_id,
  	         l_fin_start_date,
  	         p_period_start_date - 1);
	      FETCH c_get_periods INTO p_paid_periods;
	      CLOSE c_get_periods;
      END IF;

       IF g_debug THEN
       	   hr_utility.set_location('p_paid_periods: '|| p_paid_periods, 100);
        END IF;


       IF NOT g_ytd_def_bals_populated THEN
       -- Fetch the defined balance ids for the required balances
       --

      IF p_use_tax_flag = 'Y' THEN
		   l_db_item_suffix := '_ASG_LE_YTD';
   	ELSE
	   	l_db_item_suffix := '_ASG_YTD';
   	END IF ;

   	OPEN c_get_ytd_def_bal_ids(l_db_item_suffix);
	   LOOP
	     FETCH c_get_ytd_def_bal_ids into c_ytd_input_table;
	     EXIT WHEN c_get_ytd_def_bal_ids%NOTFOUND;

	     -- Populate the Defined Balances Input Values Table
	     g_ytd_input_table(i).defined_balance_id 	:= c_ytd_input_table.defined_balance_id;
	     g_ytd_input_table(i).balance_value  	:= null;

	     -- Populate the contexts Table

             /*bug 2610141*/
	     IF p_use_tax_flag = 'Y' THEN
		     g_ytd_context_table(1).tax_unit_id  	:= l_tax_unit_id;
	     ELSE
		     g_ytd_context_table(1).tax_unit_id  	:= null;
	     END IF;

	     -- Populate the Global Defined Balances Table
	     g_ytd_bals(i).defined_balance_id := c_ytd_input_table.defined_balance_id;
	     g_ytd_bals(i).balance_name       := c_ytd_input_table.balance_name;
	     g_ytd_bals(i).dimension_name     := c_ytd_input_table.dimension_name;

	     i := i+1;
	     END LOOP;
	     CLOSE c_get_ytd_def_bal_ids;
	     g_ytd_def_bals_populated 	:= TRUE;

	END IF;

	-- Use BBR for retrieving the balance values for the previous financial year.
	--
	pay_balance_pkg.get_value(P_ASSIGNMENT_ACTION_ID =>l_asg_act_id,
				  P_DEFINED_BALANCE_LST => g_ytd_input_table,
				  P_CONTEXT_LST => g_ytd_context_table,
				  P_OUTPUT_TABLE  => g_ytd_result_table);


	FOR i in g_ytd_result_table.first .. g_ytd_result_table.last
	LOOP
		IF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
	           and g_ytd_bals(i).balance_name = 'Earnings_Standard'
	        THEN
	           p_earnings_standard := nvl(g_ytd_result_table(i).balance_value,0);
		   IF g_debug THEN
		      hr_utility.set_location('p_earnings_standard: '||p_earnings_standard, 60);
		   END IF;
                   ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
		      and g_ytd_bals(i).balance_name = 'Pre Tax Spread Deductions'
		   THEN
		   p_pre_tax_spread := nvl(g_ytd_result_table(i).balance_value,0);
		   IF g_debug THEN
		      hr_utility.set_location('p_pre_tax_spread_deductions: '||p_pre_tax_spread, 60);
		   END IF;

   	           ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
		     and g_ytd_bals(i).balance_name = 'Pre Tax Fixed Deductions' and p_use_tax_flag = 'Y'
                     /*bug4363057*/
		    THEN
		   p_pre_tax_fixed := nvl(g_ytd_result_table(i).balance_value,0);
		   IF g_debug THEN
		      hr_utility.set_location('p_pre_tax_fixed_deductions: '||p_pre_tax_fixed, 60);
		   END IF;
		   ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
		      and g_ytd_bals(i).balance_name = 'Pre Tax Progressive Deductions'  and p_use_tax_flag = 'Y'
                        /*bug4363057*/
		   THEN
		   p_pre_tax_prog := nvl(g_ytd_result_table(i).balance_value,0);
		   IF g_debug THEN
		      hr_utility.set_location('p_pre_tax_progressive_deductions: '||p_pre_tax_prog, 60);
		   END IF;

           ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
              and g_ytd_bals(i).balance_name = 'Earnings_Leave_Loading'  and p_use_tax_flag = 'Y'
                /*bug8725341*/
           THEN
           l_leave_loading := nvl(g_ytd_result_table(i).balance_value,0);
             IF g_debug THEN
              hr_utility.set_location('l_earnings_leave_loading: '||l_leave_loading, 60);
           END IF;

		END IF;
	END LOOP;

     IF to_char(l_eff_date,'dd/mm/yyyy') >= '01/07/2009' THEN /*bug8725341*/
          p_earnings_standard := p_earnings_standard + l_leave_loading;
     END IF;

  if g_debug then
      hr_utility.set_location('OUT  p_paid_periods:              '|| p_paid_periods, 100);
      hr_utility.set_location('OUT  p_earnings_standard:         '||p_earnings_standard, 60);
      hr_utility.set_location('OUT  p_pre_tax_spread_deductions: '||p_pre_tax_spread, 60);
      hr_utility.set_location('OUT  p_pre_tax_fixed_deductions:  '||p_pre_tax_fixed, 60);
      hr_utility.set_location('OUT  p_pre_tax_progressive_deductions: '||p_pre_tax_prog, 60);
      hr_utility.set_location('Exiting '||l_procedure,105);
  end if;

	return 1000;
  END IF;


  END calculate_asg_prev_value;





/*
 *  paid_periods_since_hire_date - returns the number of periods in the
 *  current tax year since the hire date.
 */

function  paid_periods_since_hire_date
          (
            p_payroll_id        in number,
            p_assignment_id     in number,
	    p_tax_unit_id       in number, --2610141
            p_assignment_action_id IN number, /*Bug 4438644*/
            p_period_num        in number,
            p_period_start      in date,
            p_emp_hire_date     in date,
	    p_use_tax_flag      IN VARCHAR2 --2610141
          )
          return number is

  l_year_start              date;
  l_month_no                number;
  l_year                    number;
  l_period_num              number;
  l_time_period_id     number;
  l_start_date              date;
  l_eff_date            DATE;
  l_count_period            NUMBER;
  l_eff_period_num          NUMBER;
  v_curr_time_period_id          NUMBER;
  l_procedure               varchar2(80);

 /*Bug 4438644 - Cursor introduced to return time period of the current payroll period*/
  cursor c_get_period_id
  is
      select time_period_id
        from per_time_periods
       where payroll_id = p_payroll_id
         and start_Date = p_period_start;

  /* Bug: 3724089 - Performance Fix in the Cursor below. Added table per_assignments_f and its joins in the inner sub-query */

  cursor c_get_processed_periods_num (v_payroll_id number,
                           v_start_date  date,
                           v_end_date date,
                           v_assignment_id number,
			   v_tax_unit_id number --2610141
                            ) is
      select DISTINCT ptp.time_period_id, ptp.period_num /*Bug 4438644*/
        from per_time_periods ptp
        where exists (select 'EXISTS' from
             per_assignments_f   paf,
             pay_payroll_actions ppa,
             pay_assignment_actions paa
       where ppa.payroll_id = v_payroll_id
        and  ppa.action_type in ('R','Q')
        and  paa.action_status =  'C'
        and  ppa.payroll_action_id = paa.payroll_action_id
        and  paf.assignment_id = v_assignment_id
        and  paa.assignment_id = paf.assignment_id
	     and  paa.tax_unit_id  = decode(p_use_tax_flag,'N',paa.tax_unit_id,v_tax_unit_id) --2610141
        AND  ppa.effective_date BETWEEN v_start_date and v_end_date      /*Bug 4438644*/
        AND  ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date      /*Bug 4438644*/
        and  ppa.date_earned between paf.effective_start_date and paf.effective_end_date)
        and  ptp.payroll_id = v_payroll_id;
--        and  ptp.regular_payment_date between v_start_date and v_end_date; /*Bug 4438644*/


/* Bug 4438644 - Two new cursors introduced, c_get_payroll_effective_date gives the effective date of the payroll
                 bein run.*/

  CURSOR c_get_payroll_effective_date
  IS
  SELECT ppa.effective_date
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa
  WHERE paa.assignment_action_id  = p_assignment_action_id
  AND ppa.payroll_action_id = paa.payroll_action_id;



  begin
    g_debug := hr_utility.debug_enabled;

  if g_debug then
     l_procedure   :='pay_au_paye_ff.paid_periods_since_hire_date';
    hr_utility.set_location('Entering                    '||l_procedure,10);
    hr_utility.set_location('IN  p_payroll_id            '||p_payroll_id,20);
    hr_utility.set_location('IN  p_assignment_id         '||p_assignment_id,25);
    hr_utility.set_location('IN  p_tax_unit_id           '||p_tax_unit_id,30);
    hr_utility.set_location('IN  p_assignment_action_id  '||p_assignment_action_id,35);
    hr_utility.set_location('IN  p_period_num            '||p_period_num,40);
    hr_utility.set_location('IN  p_period_start          '||to_char(p_period_start,'dd/mm/yyyy'),45);
    hr_utility.set_location('IN  p_emp_hire_date         '||to_char(p_emp_hire_date,'dd/mm/yyyy'),50);
    hr_utility.set_location('IN  p_use_tax_flag          '||p_use_tax_flag,55);

 end if;

    OPEN c_get_payroll_effective_date; /*Bug 4438644*/
    FETCH c_get_payroll_effective_date INTO l_eff_date; /*Bug 4438644*/
    CLOSE c_get_payroll_effective_date; /*Bug 4438644*/

/*Bug 4438644 - Code given below gets the current time period id based on date earned*/
    OPEN c_get_period_id;
    FETCH c_get_period_id INTO v_curr_time_period_id;
    CLOSE c_get_period_id;

/*Bug 4438644 - Financial year now gets calculated on the basis of the payroll effective date*/
    l_month_no     := to_number(to_char(l_eff_date,'MM'));
    l_year         := to_number(to_char(l_eff_date,'YYYY'));

 /* Bug# 2166742 Added the following if clause */
 /* Bug 4438644 - This piece of code has been removed*/
 /*    if p_period_num = 1 then
       return 1;
    end if; */

    if l_month_no > 6 then
      l_year_start := to_date('01-07-'||to_char(l_year),'DD-MM-YYYY');
    else
      l_year_start := to_date('01-07-'||to_char(l_year - 1),'DD-MM-YYYY');
    end if;

    if p_emp_hire_date <= l_year_start then
          l_start_date := l_year_start;
    else
          l_start_date := p_emp_hire_date;
    end if;


l_count_period := 0;

      open c_get_processed_periods_num (p_payroll_id
                            ,l_start_date
                            ,l_eff_date /*Bug 4438644 -Payroll effective date as argument*/
                            ,p_assignment_id
			    ,p_tax_unit_id); --2610141
      LOOP
         fetch c_get_processed_periods_num into l_time_period_id,l_period_num;
         EXIT WHEN c_get_processed_periods_num%NOTFOUND;
         IF l_time_period_id <> v_curr_time_period_id THEN /*Bug 4438644 - This condition put to exclude the increment
                                                                           for current payroll period.*/
            l_count_period := l_count_period + 1;
         END IF;
      END LOOP;

      close c_get_processed_periods_num;

l_count_period := l_count_period + 1; /*Bug 4438644 - Increment done for current payroll period*/

 if g_debug then
    hr_utility.set_location('Return l_count_period '||l_count_period,60);
    hr_utility.set_location('Exiting '||l_procedure,70);
 end if ;

RETURN l_count_period;

    exception
      when others then
        null;

end paid_periods_since_hire_date;


/*
 *  convert_to_period - converts weekly equivalents
 *  back to the period amounts using new ATO rules
 */

  function  convert_to_period_amt
  (
    p_ann_freq   in   number,
    p_amt_week   in   number,
    p_tax_scale   in   number
  )
  return number is

  l_amt_period          number;

  begin
    g_debug := hr_utility.debug_enabled;
  If(p_tax_scale <> 4) then
    if p_ann_freq = 52 then
      l_amt_period := p_amt_week;
    elsif p_ann_freq = 26 then
      l_amt_period := (p_amt_week * 2);
    elsif p_ann_freq = 24 then
      l_amt_period := round_amt (p_amt_week * 13 / 6,p_tax_scale);
    elsif p_ann_freq = 12 then
      l_amt_period := round_amt (p_amt_week * 13 / 3,p_tax_scale);
    elsif p_ann_freq = 4 then /*Bug : 2888114*/
      l_amt_period := round_amt (p_amt_week * 13 ,p_tax_scale);
    end if;
  else
    if p_ann_freq = 52 then
      l_amt_period := p_amt_week;
    elsif p_ann_freq = 26 then
      l_amt_period := (p_amt_week * 2);
    elsif p_ann_freq = 24 then
      l_amt_period := trunc (p_amt_week * 13 / 6);
    elsif p_ann_freq = 12 then
      l_amt_period := trunc (p_amt_week * 13 / 3);
    elsif p_ann_freq = 4 then /*Bug : 2888114*/
      l_amt_period := trunc (p_amt_week * 13) ;
    end if;
  end if;
    return (l_amt_period);

    exception
      when others then
        null;

  end convert_to_period_amt;


  function  round_amt
  (
    p_actual_amt   in   number,
    p_tax_scale   in   number
  )
  return number is

  begin
    g_debug := hr_utility.debug_enabled;
  If(p_tax_scale <> 4) then
	    return (round(p_actual_amt));
   else
	    return (trunc(p_actual_amt));
   end if;

   exception
      when others then
        null;

  end round_amt;


function check_if_retro
         (
                p_element_entry_id  in pay_element_entries_f.element_entry_id%TYPE,
                p_date_earned in pay_payroll_actions.date_earned%TYPE

         )return varchar2 is


l_creator_type pay_element_entries_f.creator_type%TYPE;
IS_retro_payment varchar2(10);
l_procedure               varchar2(80);
begin
    g_debug := hr_utility.debug_enabled;

 if g_debug then
 l_procedure  :='pay_au_paye_ff.check_if_retro';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_element_entry_id '||p_element_entry_id,20);
  hr_utility.set_location('IN p_date_earned      '||to_char(p_date_earned,'dd/mm/yyyy'),30);
 end if;

   OPEN  c_get_creator_type(p_element_entry_id,p_date_earned);
   FETCH c_get_creator_type INTO l_creator_type ;
   CLOSE c_get_creator_type;
   if l_creator_type = 'RR' or l_creator_type = 'EE' then
       IS_retro_payment:='Y';
   else
       IS_retro_payment:='N';
   end if;

if g_debug then
  hr_utility.set_location('Return IS_retro_payment '||IS_retro_payment,40);
  hr_utility.set_location('Exiting '||l_procedure,50);
end if;

  return IS_retro_payment;

   EXCEPTION
      when others then
      null;


end check_if_retro;



function get_retro_period
        (
             p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE,
             p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,/*Bug 4418107*/
             p_retro_start_date out NOCOPY date,
             p_retro_end_date out NOCOPY date
        )return number is


cursor get_retro_period_rr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date,ptp.end_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
AND paa.tax_unit_id = p_tax_unit_id /*Bug 4418107*/
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='RR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;



cursor get_retro_period_ee
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date,ptp.end_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and  paa.assignment_action_id=pee.source_asg_action_id
AND paa.tax_unit_id = p_tax_unit_id /*Bug 4418107*/
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='EE'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_creator_type pay_element_entries_f.creator_type%TYPE;
l_period_obtained_flag number;
 l_procedure               varchar2(80);


begin
g_debug := hr_utility.debug_enabled;

IF g_debug THEN
 l_procedure     :='pay_au_paye_ff.get_retro_period';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_element_entry_id '||p_element_entry_id,20);
  hr_utility.set_location('IN p_date_earned      '||to_char(p_date_earned,'dd/mm/yyyy'),30);
  hr_utility.set_location('IN p_tax_unit_id      '||p_tax_unit_id ,40);

END IF;


l_period_obtained_flag:=1;
IF g_debug THEN
    hr_utility.set_location('l_period_obtained_flag '||l_period_obtained_flag,45);
END IF;

   OPEN  c_get_creator_type(p_element_entry_id,p_date_earned);
   FETCH c_get_creator_type INTO l_creator_type ;
   CLOSE c_get_creator_type;


if l_creator_type = 'RR' then
  OPEN get_retro_period_rr(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_rr into  p_retro_start_date,p_retro_end_date;
  CLOSE get_retro_period_rr;
  l_period_obtained_flag:=1;
end if;

if l_creator_type = 'EE' then
  OPEN get_retro_period_ee(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_ee into  p_retro_start_date,p_retro_end_date;
  CLOSE get_retro_period_ee;
  l_period_obtained_flag:=1;
end if;

IF g_debug THEN

  hr_utility.set_location('OUT p_retro_start_date     '||to_char(p_retro_start_date,'dd/mm/yyyy'),50);
  hr_utility.set_location('OUT p_retro_end_date       '||to_char(p_retro_end_date,'dd/mm/yyyy'),55);
  hr_utility.set_location('OUT l_period_obtained_flag '||l_period_obtained_flag,60);
  hr_utility.set_location('Exiting '||l_procedure,70);

END IF;

return  l_period_obtained_flag;



end get_retro_period;

/* Bug 5586445
    Function    : get_enhanced_retro_period
    Description : This function is to be used for Enhanced Retropay implementation.
                  Function returns details about Retro Element entry and the retropay time
                  span for which the entry is created.
    Inputs      : p_element_entry_id     - Element Entry ID
                  p_date_earned          - Date Earned of the Run
                  p_tax_unit_id          - Tax Unit ID of Assignment
    Outputs     : p_retro_start_date     - Period Start Date of Original period
                  p_retro_end_date       - Period End Date of Original period
                  p_orig_effective_date  - Effective Date of Original Run
                  p_retro_effective_date - Effective Date of Retropay Run that created element entry
                  p_time_span            - Character String indicating the retro time span. Values are,
                                           'LT12 Curr','LT12 Prev','GT12'
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
        )return number
IS

/* Bug 5586445  - Cursor get_retropay_run_details
   Get Effective Date of the Enhanced Retropay process
*/
CURSOR get_retropay_run_details
(c_element_entry_id pay_element_entries_f.element_entry_id%TYPE)
IS
SELECT pee.creator_type,
       ppa.effective_date
FROM   pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_entries_f  pee
WHERE  ppa.payroll_action_id    = paa.payroll_action_id
AND    paa.assignment_action_id = pee.creator_id
AND    pee.element_entry_id     = c_element_entry_id
AND    ppa.action_type          ='L';

CURSOR get_retro_period_rr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           )
IS
SELECT  ptp.start_date
       ,ptp.end_date
       ,ppa.effective_date
FROM   per_time_periods ptp,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_run_results prr,
       pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
AND    prr.run_result_id = pee.source_id
AND    paa.assignment_action_id=prr.assignment_action_id
AND    paa.tax_unit_id = p_tax_unit_id
AND    ppa.payroll_action_id=paa.payroll_action_id
AND    ptp.payroll_id=ppa.payroll_id
AND    pee.creator_type='RR'
AND    ppa.date_earned between ptp.start_date and ptp.end_date
AND    c_date_earned between pee.effective_start_date and pee.effective_end_date;


CURSOR get_retro_period_ee
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           )
IS
SELECT  ptp.start_date
       ,ptp.end_date
       ,ppa.effective_date
FROM   per_time_periods ptp,
       pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
AND    paa.assignment_action_id=pee.source_asg_action_id
AND    paa.tax_unit_id = p_tax_unit_id
AND    ppa.payroll_action_id=paa.payroll_action_id
AND    ptp.payroll_id=ppa.payroll_id
AND    pee.creator_type='EE'
AND    ppa.date_earned between ptp.start_date and ptp.end_date
AND    c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_period_obtained_flag number;

l_procedure VARCHAR2(80);
l_creator_type pay_element_entries_f.creator_type%TYPE;
l_fin_year_start  DATE;
l_month_start     DATE;
l_orig_month_start DATE;
l_time_span       VARCHAR2(80);


BEGIN

g_debug :=  hr_utility.debug_enabled;
l_period_obtained_flag := 1;

IF g_debug THEN
    l_procedure  := 'pay_au_payee_ff.get_enhanced_retro_period';
    hr_utility.set_location('Entering '||l_procedure,10);
    hr_utility.set_location('IN p_element_entry_id '||p_element_entry_id,20);
    hr_utility.set_location('IN p_date_earned      '||p_date_earned,30);
    hr_utility.set_location('IN p_tax_unit_id      '||p_tax_unit_id,30);
END IF;

OPEN  get_retropay_run_details(p_element_entry_id);
FETCH get_retropay_run_details INTO l_creator_type,p_retro_effective_date;
CLOSE get_retropay_run_details;

l_fin_year_start := hr_au_routes.span_start(p_retro_effective_date,1,'01-07');
l_month_start    := hr_au_routes.span_start(p_retro_effective_date,12,'01-01');

IF l_creator_type = 'RR'
THEN
    OPEN get_retro_period_rr(p_element_entry_id,p_date_earned);
    FETCH get_retro_period_rr INTO  p_retro_start_date,p_retro_end_date,p_orig_effective_date;
    IF get_retro_period_rr%FOUND
    THEN
        l_orig_month_start := hr_au_routes.span_start(p_orig_effective_date,12,'01-01');
        l_period_obtained_flag:=1;
    END IF;
    CLOSE get_retro_period_rr;
END IF;

IF l_creator_type = 'EE' then
    OPEN get_retro_period_ee(p_element_entry_id,p_date_earned);
    FETCH get_retro_period_ee INTO  p_retro_start_date,p_retro_end_date,p_orig_effective_date;
    IF get_retro_period_ee%FOUND
    THEN
        l_orig_month_start := hr_au_routes.span_start(p_orig_effective_date,12,'01-01');
        l_period_obtained_flag:=1;
    END IF;
    CLOSE get_retro_period_ee;
END IF;

p_time_span := NULL;
/* Set Time Span */

    IF (p_orig_effective_date >= l_fin_year_start)
    THEN
        l_time_span := 'LT12 Curr';
    ELSIF  (p_orig_effective_date < l_fin_year_start)  AND
           (trunc(months_between(l_month_start,l_orig_month_start)) <= 12)
    THEN
        l_time_span := 'LT12 Prev';
    ELSIF  (p_orig_effective_date < l_fin_year_start)  AND
           (trunc(months_between(l_month_start,l_orig_month_start)) > 12)
    THEN
        l_time_span := 'GT12';
    END IF;

        p_time_span := l_time_span;

IF g_debug
THEN
    hr_utility.set_location('OUT p_retro_start_date       '||p_retro_start_date,40);
    hr_utility.set_location('OUT p_retro_end_date         '||p_retro_end_date,50);
    hr_utility.set_location('OUT p_orig_effective_date    '||p_orig_effective_date,60);
    hr_utility.set_location('OUT p_retro_effective_date   '||p_retro_effective_date,70);
    hr_utility.set_location('OUT p_time_span              '||p_time_span,80);
    hr_utility.set_location('Exiting '||l_procedure,90);
END IF;

RETURN l_period_obtained_flag;

END get_enhanced_retro_period;


/*  Bug 5846272 - Functions added for Enhanced Retropay in 11i.
    Function    : check_if_enhanced_retro
    Description : This function checks the Legislation Rule for Enhanced Retropay and
                  returns value indicating if Enhanced Retropay is enabled in system or not.
    Inputs      : p_business_group_id    - Business Group ID
*/

FUNCTION check_if_enhanced_retro
        (
          p_business_group_id IN per_business_groups.business_group_id%TYPE
        )RETURN VARCHAR2
IS

CURSOR get_legislation_rule
       (c_business_group_id IN per_business_groups.business_group_id%TYPE)
IS
SELECT rule_mode
FROM  pay_legislation_rules plr
     ,per_business_groups  pbg
WHERE plr.legislation_code = pbg.legislation_code
AND   pbg.business_group_id = c_business_group_id
AND   plr.rule_type = 'ADVANCED_RETRO'
AND   pbg.legislation_code = 'AU';

l_return    VARCHAR2(10);
l_proc_name VARCHAR2(80);

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
    l_proc_name     := 'pay_au_paye_ff.check_if_enhanced_retro';
    hr_utility.set_location('Entering '||l_proc_name,10);
    hr_utility.set_location('IN p_business_group_id =>  '||p_business_group_id,20);
END IF;

OPEN get_legislation_rule(p_business_group_id);
FETCH get_legislation_rule INTO l_return;
CLOSE get_legislation_rule;

IF g_debug THEN
    hr_utility.set_location('OUT Return Value   =>'||l_return,30);
    hr_utility.set_location('Exiting '||l_proc_name,40);
END IF;

RETURN NVL(l_return,'N');

END check_if_enhanced_retro;


/* Bug 5846272
    Function    : get_retro_time_span
    Description : This function is to be used for Enhanced Retropay implementation.
                  Function returns details about Retro Element entry and the retropay time
                  span for which the entry is created.
    Inputs      : p_element_entry_id     - Element Entry ID
                  p_date_earned          - Date Earned of the Run
                  p_tax_unit_id          - Tax Unit ID of Assignment
    Outputs     : p_retro_start_date     - Period Start Date of Original period
                  p_retro_end_date       - Period End Date of Original period
                  p_orig_effective_date  - Effective Date of Original Run
                  p_retro_effective_date - Effective Date of Retropay Run that created element entry
                  p_time_span            - Character String indicating the retro time span. Values are,
                                           'LT12 Curr','LT12 Prev','GT12'
                  p_retro_type           - String indicating the type of retropay used to create element.
                                           Values are - 'RETRO_ELE' and 'ADVANCED_RETRO'
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
             )RETURN NUMBER
IS

CURSOR get_retro_entry_details
        (c_element_entry_id pay_element_entries_f.element_entry_id%TYPE
        ,c_date_earned pay_payroll_actions.date_earned%TYPE)
IS
SELECT  pee.element_entry_id
       ,ppa.retro_definition_id
       ,pepd.retro_component_id
FROM  pay_element_entries_f pee
     ,pay_assignment_actions paa
     ,pay_payroll_actions ppa
     ,pay_entry_process_details pepd
WHERE pee.element_entry_id  = c_element_entry_id
AND   pee.element_entry_id  = pepd.element_entry_id
AND   pee.creator_id        = paa.assignment_action_id
AND   paa.payroll_action_id = ppa.payroll_action_id
AND   ppa.action_type = 'L'
AND   c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_retro_type        VARCHAR2(80);
l_proc_name         VARCHAR2(100);
l_retro_period      NUMBER;
l_fin_year_start    DATE;

l_entry_details get_retro_entry_details%ROWTYPE;

l_temp NUMBER;

BEGIN

g_debug := hr_utility.debug_enabled;

IF g_debug THEN
    l_proc_name := 'pay_au_paye_ff.get_retro_time_span';
    hr_utility.set_location('Entering  '||l_proc_name,10);
    hr_utility.set_location('IN p_element_entry_id '||p_element_entry_id,30);
    hr_utility.set_location('IN p_date_earned      '||p_date_earned,30);
    hr_utility.set_location('IN p_tax_unit_id      '||p_tax_unit_id,30);
END IF;

l_retro_type     := NULL;

  OPEN get_retro_entry_details(p_element_entry_id,p_date_earned);
  FETCH get_retro_entry_details INTO l_entry_details;
  CLOSE get_retro_entry_details;

  IF (l_entry_details.retro_definition_id IS NOT NULL
      AND l_entry_details.retro_component_id IS NOT NULL)
  THEN
            /* Entry Created using Enhanced Retropay */
            IF g_debug THEN
                hr_utility.set_location('Entry created by Enhanced Retropay ',40);
                hr_utility.set_location('Retro Component ID =>'||l_entry_details.retro_component_id,40);
            END IF;
            l_retro_type := 'ADVANCED_RETRO';
            l_temp := get_enhanced_retro_period
                            (
                            p_element_entry_id     => p_element_entry_id,
                            p_date_earned          => p_date_earned,
                            p_tax_unit_id          => p_tax_unit_id,
                            p_retro_start_date     => p_retro_start_date,
                            p_retro_end_date       => p_retro_end_date,
                            p_orig_effective_date  => p_orig_effective_date,
                            p_retro_effective_date => p_retro_effective_date,
                            p_time_span            => p_time_span);
  ELSE
    /* Entry Created Using Retropay by Element
       The Effective Dates are set to NULL as its irrelevent and not required
       for Retropay by element processing */

            IF g_debug THEN
                hr_utility.set_location('Entry created by Retropay by Element',50);
            END IF;

          l_retro_type  := 'RETRO_ELE';
          p_orig_effective_date  := NULL;
          p_retro_effective_date := NULL;

            l_temp := get_retro_period
                        (
                         p_element_entry_id => p_element_entry_id,
                         p_date_earned      => p_date_earned,
                         p_tax_unit_id      => p_tax_unit_id,
                         p_retro_start_date => p_retro_start_date,
                         p_retro_end_date   => p_retro_end_date
                         );

            l_retro_period := months_between(p_date_earned,p_retro_end_date);
            IF l_retro_period > 12
            THEN
                p_time_span :=  'GT12';
            ELSE
                l_fin_year_start := hr_au_routes.span_start(p_date_earned,1,'01-07');
                IF p_retro_end_date < l_fin_year_start
                THEN
                    p_time_span := 'LT12 Prev';
                ELSE
                    p_time_span := 'LT12 Curr';
                END IF;
            END IF;
 END IF;

p_retro_type    := l_retro_type;

IF g_debug
THEN
    hr_utility.set_location('OUT p_retro_start_date       '||p_retro_start_date,80);
    hr_utility.set_location('OUT p_retro_end_date         '||p_retro_end_date,80);
    hr_utility.set_location('OUT p_orig_effective_date    '||p_orig_effective_date,80);
    hr_utility.set_location('OUT p_retro_effective_date   '||p_retro_effective_date,80);
    hr_utility.set_location('OUT p_time_span              '||p_time_span,80);
    hr_utility.set_location('OUT l_retro_type             '||l_retro_type,80);
    hr_utility.set_location('Exiting '||l_proc_name,90);
END IF;

return 1;
END get_retro_time_span;

function count_retro_periods
        (
           p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE,
           p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE, /*Bug 4418107*/
           p_use_tax_flag      IN VARCHAR2, --4415795
           p_mode IN VARCHAR2 DEFAULT 'E'  --7665727
        )return number
is

-- Need to get the pay value amount so we can check totals in each period.
/*
cursor get_element_entries
is
select pee.element_entry_id from pay_element_entries_f pee,
  pay_assignment_actions paa
  where paa.assignment_action_id=p_assignment_action_id
  and   pee.assignment_id=paa.assignment_id
  and pee.creator_type IN ('EE','RR')
  and p_date_earned between pee.effective_start_date and pee.effective_end_date;
*/
cursor get_element_entries
is
select pee.element_entry_id,
       peev.screen_entry_value retro_amount,
       pec.classification_name
   from pay_element_entries_f pee,
        pay_element_entry_values_f peev,
        pay_element_links_f pelf,
        pay_element_types_f pet,
        pay_element_classifications pec,
        pay_input_values_f piv,
        pay_assignment_actions paa
   where paa.assignment_action_id = p_assignment_action_id
   and   pee.assignment_id = paa.assignment_id
   and   pee.creator_type IN ('EE','RR')
   and   p_date_earned between pee.effective_start_date and pee.effective_end_date
-- Only Earnings.
and   pelf.element_link_id = pee.element_link_id
and   p_date_earned between pelf.effective_start_date and pelf.effective_end_date
and   pet.element_type_id = pelf.element_type_id
and   p_date_earned between pet.effective_start_date and pet.effective_end_date
and   pec.classification_id = pet.classification_id
and   pec.classification_name in ('Earnings', 'Pre Tax Deductions')
-- Only Pay Value
   and   peev.element_entry_id = pee.element_entry_id
   and   p_date_earned between peev.effective_start_date and peev.effective_end_date
   and   peev.input_value_id = piv.input_value_id
   and   p_date_earned between piv.effective_start_date and piv.effective_end_date
   and   piv.name = 'Pay Value';

/* Bug 5846272 - Cursor to read the Advanced Retropay Legislation Rule */
CURSOR get_legislation_rule
IS
SELECT plr.rule_mode
FROM   pay_legislation_rules plr
WHERE  plr.legislation_code = 'AU'
AND    plr.rule_type ='ADVANCED_RETRO';

/* Bug 6139035 - Cursor to fetch Effective Date */
CURSOR c_get_effective_date(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT ppa.effective_date
FROM   pay_payroll_actions ppa
      ,pay_assignment_actions paa
WHERE paa.assignment_action_id = c_assignment_action_id
AND   paa.payroll_action_id    = ppa.payroll_action_id;

l_count number;
l_retro_periods number;
is_retro_payment varchar2(10);
retro_start_date date;
retro_end_date date;
financial_year_span_start date;
l_retro_end_date number;
x varchar2(100);
l_procedure               varchar2(80);
TYPE num_tab_type IS TABLE OF NUMBER(10) INDEX BY binary_integer; -- Bug 4412537
num_tab num_tab_type;

-- This table introduced to allow totalling of the retro amounts in each retro period. Bug 5374076.
TYPE tot_period_amount_type IS TABLE OF NUMBER INDEX BY binary_integer; /* Bug# 5397711*/
tot_period_amount tot_period_amount_type;

/* Bug 5846272 - Introduced variables for Enhanced Retropay processing */
l_adv_retro_flag VARCHAR2(10);
l_retro_eff_date DATE;
l_orig_effective_date DATE;
l_time_span varchar2(80);
l_retro_type varchar2(80);

/* Bug 6139035 - Introduced variables for Effective Date */
l_eff_date_yr_start     DATE;
l_pay_effective_date    DATE;

--
begin

g_debug := hr_utility.debug_enabled;

if g_debug then
l_procedure     :='pay_au_paye_ff.count_retro_periods';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN  p_assignment_action_id '||p_assignment_action_id,20);
  hr_utility.set_location('IN  p_date_earned          '||to_char(p_date_earned,'dd/mm/yyyy'),20);
  hr_utility.set_location('IN  p_tax_unit_id          '||p_tax_unit_id,20);
  hr_utility.set_location('IN  p_use_tax_flag         '||p_use_tax_flag,20);
end if;


    OPEN  c_get_effective_date(p_assignment_action_id);
    FETCH c_get_effective_date INTO l_pay_effective_date;
    CLOSE c_get_effective_date;

    IF g_debug THEN
        hr_utility.set_location('Pay Effective Date =>'||to_char(l_pay_effective_date,'dd/mm/yyyy'),30);
    END IF;

/*bug7665727 -  Based on Effective Date because +ve Offset payrolls may have Pay Date in the next
                               financial year for a period in current financial year. */
IF to_char(l_pay_effective_date,'dd/mm/yyyy') >= '01/07/2009' THEN

   l_retro_periods := count_retro_periods_2009
                                    ( p_assignment_action_id => p_assignment_action_id,
                                      p_date_earned => p_date_earned,
                                      p_tax_unit_id => p_tax_unit_id,
                                      p_use_tax_flag => p_use_tax_flag,
                                      p_mode => p_mode);

ELSE

    l_retro_periods:=0;

/* Bug 6139035 - Get Financial Year Information based on Effective Date of run */
    l_eff_date_yr_start := hr_au_routes.span_start(l_pay_effective_date,1,'01-07');
    financial_year_span_start:=hr_au_routes.span_start(p_date_earned,1,'01-07');

/* Bug 5846272 - Read the Legislation Rule value for Enhanced Retropay. If
   rule not found,set the flag to 'N' */
    OPEN get_legislation_rule;
    FETCH get_legislation_rule INTO l_adv_retro_flag;
        IF  get_legislation_rule%NOTFOUND THEN
            l_adv_retro_flag := 'N';
        END IF;
    CLOSE get_legislation_rule;

    IF g_debug THEN
        hr_utility.set_location('Enhanced Retropay Rule Value =>'||l_adv_retro_flag,50);
    END IF;


for process_element in get_element_entries
loop
    /* Bug 5846272 - Use Existing Logic if Enh Retro Rule is 'N' ELSE
       use Enhanced Retropay functionality
    */
    IF l_adv_retro_flag = 'N'
    THEN
--   is_retro_payment:=check_if_retro(process_element.element_entry_id,p_date_earned);
--   if is_retro_payment='Y' then
--   Note this processing is only done for retro less than 12 months, in prev fin year.

/*Bug 4418107 - The following piece of code has been introduced to count retro periods on the basis
                of Legal Employer.*/

     x:=get_retro_period(process_element.element_entry_id,p_date_earned,p_tax_unit_id, retro_start_date,retro_end_date); /*Bug 4418107*/

     if p_use_tax_flag = 'Y' then
     /* Bug 6139035 - Commented code - Check for Retro LT12 Prev should be based on Date Paid(Effective Date)
                       and not Date Earned
         if months_between(p_date_earned,retro_end_date) <= 12  and p_date_earned >= financial_year_span_start
         and retro_end_date < financial_year_span_start */
         IF  months_between(l_pay_effective_date,retro_end_date) <= 12 AND l_pay_effective_date >=
             l_eff_date_yr_start AND retro_end_date < l_eff_date_yr_start
         THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM')); -- Bug 4412537
            /*Bug 4357306 - Logic given below has been implemented to count the retro end dates.
                            If the customer pays for two different retro elements for the same retro
                            period then the dates were counted twice, so to avoid that a table has been
                            created where the values get stored in the index. If there is already a index
                            for retro end dates the counter l_retro_periods is not incremented and a new index
                            is not created, but if a new retro end date is being processed then the counter is
                            incremented and index is also created in the table num_tab.*/
            IF num_tab.EXISTS(l_retro_end_date) THEN
               num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
            ELSE
               num_tab(l_retro_end_date) := 1;
               l_retro_periods:=l_retro_periods + 1;
            END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               end if;
            ELSE
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               end if;
            END IF;

         end if;
    elsif p_use_tax_flag = 'N' then
    /*Bug 4415795 - This portion has been introduced so that the count_retro_periods
                    return the value for current year case before 01-JUL-2005 and for
                    less than 12 months previous year case after 01-JUL-2005*/

         if months_between(p_date_earned,retro_end_date) <= 12  and p_date_earned >= financial_year_span_start
         and retro_end_date >= financial_year_span_start
          then
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM')); -- Bug 4412537
            IF num_tab.EXISTS(l_retro_end_date) THEN
               num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
            ELSE
               num_tab(l_retro_end_date) := 1;
               l_retro_periods:=l_retro_periods + 1;
            END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               end if;
            ELSE
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               end if;
            END IF;

         end if;
    end if;
    ELSE
    /* Bug 5846272
       Section for Enhanced Retropay -  l_adv_retro_flag = 'Y'
       Logic check for p_use_tax_flag is not implemented here because Enhanced Retropay
       was not supported prior to Jul-2005.
    */

         x := get_retro_time_span
              (
              p_element_entry_id     => process_element.element_entry_id,
              p_date_earned          => p_date_earned,
              p_tax_unit_id          => p_tax_unit_id,
              p_retro_start_date     => retro_start_date,
              p_retro_end_date       => retro_end_date,
              p_orig_effective_date  => l_orig_effective_date,
              p_retro_effective_date => l_retro_eff_date,
              p_time_span            => l_time_span,
              p_retro_type           => l_retro_type
             );

          IF l_time_span = 'LT12 Prev'
          THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM')); -- Bug 4412537

                IF num_tab.EXISTS(l_retro_end_date) THEN
                   num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
                ELSE
                   num_tab(l_retro_end_date) := 1;
                   l_retro_periods:=l_retro_periods + 1;
                END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               IF process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               END IF;
            ELSE
               IF process_element.classification_name = 'Pre Tax Deductions' THEN
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               END IF;
            END IF;
          END IF;

    END IF; /* End of Enhanced Retropay part */

end loop;

-- Check if any periods have 0 total retro amount. If they do then don't count the retro period.

l_count := tot_period_amount.FIRST;
while l_count is not null loop

  if tot_period_amount(l_count) = 0 then
    l_retro_periods := l_retro_periods - 1;
  end if;
  l_count := tot_period_amount.NEXT(l_count);
end loop;

END IF;

if g_debug then
  hr_utility.set_location('Return l_retro_periods '||l_retro_periods,60);
  hr_utility.set_location('Exiting '||l_procedure,70);
end if;

return l_retro_periods;

end count_retro_periods;

function count_retro_periods_2009
        (
           p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE,
           p_tax_unit_id IN pay_assignment_actions.tax_unit_id%TYPE,
           p_use_tax_flag      IN VARCHAR2,
           p_mode IN VARCHAR2  --7665727
        )return number
is

/*bug7665727 - element entries for each p_mode case */
cursor get_element_entries /* retro earnings only */
is
select pee.element_entry_id,
       peev.screen_entry_value retro_amount,
       pec.classification_name
   from pay_element_entries_f pee,
        pay_element_entry_values_f peev,
        pay_element_links_f pelf,
        pay_element_types_f pet,
        pay_element_classifications pec,
        pay_input_values_f piv,
        pay_assignment_actions paa,
        pay_sub_classification_rules_f psc
   where paa.assignment_action_id = p_assignment_action_id
   and   pee.assignment_id = paa.assignment_id
   and   pee.creator_type IN ('EE','RR')
   and   p_date_earned between pee.effective_start_date and pee.effective_end_date
and   pelf.element_link_id = pee.element_link_id
and   p_date_earned between pelf.effective_start_date and pelf.effective_end_date
and   pet.element_type_id = pelf.element_type_id
and   p_date_earned between pet.effective_start_date and pet.effective_end_date
and   pec.classification_id = pet.classification_id
and   pec.classification_name in ('Earnings', 'Pre Tax Deductions')
and   pet.element_type_id = psc.element_type_id(+)
and  not exists ( select null from pay_element_classifications pec2 /*bug8630738*/
                         where psc.classification_id = pec2.classification_id
                         and pec2.classification_name = 'Spread'
                        )
-- Only Pay Value
   and   peev.element_entry_id = pee.element_entry_id
   and   p_date_earned between peev.effective_start_date and peev.effective_end_date
   and   peev.input_value_id = piv.input_value_id
   and   p_date_earned between piv.effective_start_date and piv.effective_end_date
   and   piv.name = 'Pay Value';

cursor get_element_entries_spread /*retro earnings spread only*/
is
select pee.element_entry_id,
       peev.screen_entry_value retro_amount,
       pec.classification_name
   from pay_element_entries_f pee,
        pay_element_entry_values_f peev,
        pay_element_links_f pelf,
        pay_element_types_f pet,
        pay_element_classifications pec,
        pay_input_values_f piv,
        pay_assignment_actions paa,
        pay_sub_classification_rules_f psc,
        pay_element_classifications pec2
   where paa.assignment_action_id = p_assignment_action_id
   and   pee.assignment_id = paa.assignment_id
   and   pee.creator_type IN ('EE','RR')
   and   p_date_earned between pee.effective_start_date and pee.effective_end_date
-- Only Earnings Spread
and   pelf.element_link_id = pee.element_link_id
and   p_date_earned between pelf.effective_start_date and pelf.effective_end_date
and   pet.element_type_id = pelf.element_type_id
and   p_date_earned between pet.effective_start_date and pet.effective_end_date
and   pec.classification_id = pet.classification_id
and   pec.classification_name = 'Earnings'
and   pet.element_type_id = psc.element_type_id
and   psc.classification_id = pec2.classification_id
and   pec2.classification_name = 'Spread'
-- Only Pay Value
   and   peev.element_entry_id = pee.element_entry_id
   and   p_date_earned between peev.effective_start_date and peev.effective_end_date
   and   peev.input_value_id = piv.input_value_id
   and   p_date_earned between piv.effective_start_date and piv.effective_end_date
   and   piv.name = 'Pay Value';

cursor get_element_entries_all /* retro earnings+retro earnings spread */
is
select pee.element_entry_id,
       peev.screen_entry_value retro_amount,
       pec.classification_name
   from pay_element_entries_f pee,
        pay_element_entry_values_f peev,
        pay_element_links_f pelf,
        pay_element_types_f pet,
        pay_element_classifications pec,
        pay_input_values_f piv,
        pay_assignment_actions paa
   where paa.assignment_action_id = p_assignment_action_id
   and   pee.assignment_id = paa.assignment_id
   and   pee.creator_type IN ('EE','RR')
   and   p_date_earned between pee.effective_start_date and pee.effective_end_date
and   pelf.element_link_id = pee.element_link_id
and   p_date_earned between pelf.effective_start_date and pelf.effective_end_date
and   pet.element_type_id = pelf.element_type_id
and   p_date_earned between pet.effective_start_date and pet.effective_end_date
and   pec.classification_id = pet.classification_id
and   pec.classification_name in ('Earnings', 'Pre Tax Deductions')
-- Only Pay Value
   and   peev.element_entry_id = pee.element_entry_id
   and   p_date_earned between peev.effective_start_date and peev.effective_end_date
   and   peev.input_value_id = piv.input_value_id
   and   p_date_earned between piv.effective_start_date and piv.effective_end_date
   and   piv.name = 'Pay Value';


CURSOR get_legislation_rule
IS
SELECT plr.rule_mode
FROM   pay_legislation_rules plr
WHERE  plr.legislation_code = 'AU'
AND    plr.rule_type ='ADVANCED_RETRO';


CURSOR c_get_effective_date(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT ppa.effective_date
FROM   pay_payroll_actions ppa
      ,pay_assignment_actions paa
WHERE paa.assignment_action_id = c_assignment_action_id
AND   paa.payroll_action_id    = ppa.payroll_action_id;

l_count number;
l_retro_periods number;
is_retro_payment varchar2(10);
retro_start_date date;
retro_end_date date;
financial_year_span_start date;
l_retro_end_date number;
x varchar2(100);
l_procedure               varchar2(80);
TYPE num_tab_type IS TABLE OF NUMBER(10) INDEX BY binary_integer;
num_tab num_tab_type;


TYPE tot_period_amount_type IS TABLE OF NUMBER INDEX BY binary_integer;
tot_period_amount tot_period_amount_type;


l_adv_retro_flag VARCHAR2(10);
l_retro_eff_date DATE;
l_orig_effective_date DATE;
l_time_span varchar2(80);
l_retro_type varchar2(80);

l_eff_date_yr_start     DATE;
l_pay_effective_date    DATE;

--
begin

g_debug := hr_utility.debug_enabled;

if g_debug then
l_procedure     :='pay_au_paye_ff.count_retro_periods_2009';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN  p_assignment_action_id '||p_assignment_action_id,20);
  hr_utility.set_location('IN  p_date_earned          '||to_char(p_date_earned,'dd/mm/yyyy'),30);
  hr_utility.set_location('IN  p_tax_unit_id          '||p_tax_unit_id,40);
  hr_utility.set_location('IN  p_use_tax_flag         '||p_use_tax_flag,50);
  hr_utility.set_location('IN  p_mode                 '||p_mode,60);
end if;


OPEN get_legislation_rule;
FETCH get_legislation_rule INTO l_adv_retro_flag;
    IF  get_legislation_rule%NOTFOUND THEN
        l_adv_retro_flag := 'N';
    END IF;
CLOSE get_legislation_rule;

IF g_debug THEN
    hr_utility.set_location('Enhanced Retropay Rule Value =>'||l_adv_retro_flag,70);
END IF;

l_retro_periods:=0;
financial_year_span_start:=hr_au_routes.span_start(p_date_earned,1,'01-07');

    OPEN  c_get_effective_date(p_assignment_action_id);
    FETCH c_get_effective_date INTO l_pay_effective_date;
    CLOSE c_get_effective_date;

    l_eff_date_yr_start := hr_au_routes.span_start(l_pay_effective_date,1,'01-07');

/* bug7665727 - if clause as per p_mode */
IF p_mode = 'E' THEN /*retro earnings only */

for process_element in get_element_entries
loop

    IF l_adv_retro_flag = 'N'
    THEN

     x:=get_retro_period(process_element.element_entry_id,p_date_earned,p_tax_unit_id, retro_start_date,retro_end_date);

     if p_use_tax_flag = 'Y' then

         IF  months_between(l_pay_effective_date,retro_end_date) <= 12 AND l_pay_effective_date >=
             l_eff_date_yr_start AND retro_end_date < l_eff_date_yr_start
         THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

            IF num_tab.EXISTS(l_retro_end_date) THEN
               num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
            ELSE
               num_tab(l_retro_end_date) := 1;
               l_retro_periods:=l_retro_periods + 1;
            END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               end if;
            ELSE
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               end if;
            END IF;

         end if;
    end if;

    ELSE

         x := get_retro_time_span
              (
              p_element_entry_id     => process_element.element_entry_id,
              p_date_earned          => p_date_earned,
              p_tax_unit_id          => p_tax_unit_id,
              p_retro_start_date     => retro_start_date,
              p_retro_end_date       => retro_end_date,
              p_orig_effective_date  => l_orig_effective_date,
              p_retro_effective_date => l_retro_eff_date,
              p_time_span            => l_time_span,
              p_retro_type           => l_retro_type
             );

          IF l_time_span = 'LT12 Prev'
          THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

                IF num_tab.EXISTS(l_retro_end_date) THEN
                   num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
                ELSE
                   num_tab(l_retro_end_date) := 1;
                   l_retro_periods:=l_retro_periods + 1;
                END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               IF process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               END IF;
            ELSE
               IF process_element.classification_name = 'Pre Tax Deductions' THEN
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               END IF;
            END IF;
          END IF;

    END IF; /* End of Enhanced Retropay part */

end loop;

ELSIF p_mode = 'S' THEN /* retro earnings spread only */

for process_element in get_element_entries_spread
loop

    IF l_adv_retro_flag = 'N'
    THEN

     x:=get_retro_period(process_element.element_entry_id,p_date_earned,p_tax_unit_id, retro_start_date,retro_end_date);

     if p_use_tax_flag = 'Y' then /* p_use_tax_flag = 'Y' only */

         IF  months_between(l_pay_effective_date,retro_end_date) <= 12 AND l_pay_effective_date >=
             l_eff_date_yr_start AND retro_end_date < l_eff_date_yr_start
         THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

            IF num_tab.EXISTS(l_retro_end_date) THEN
               num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
            ELSE
               num_tab(l_retro_end_date) := 1;
               l_retro_periods:=l_retro_periods + 1;
            END IF;


            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
            ELSE
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
            END IF;

         end if;
    end if;

    ELSE

         x := get_retro_time_span
              (
              p_element_entry_id     => process_element.element_entry_id,
              p_date_earned          => p_date_earned,
              p_tax_unit_id          => p_tax_unit_id,
              p_retro_start_date     => retro_start_date,
              p_retro_end_date       => retro_end_date,
              p_orig_effective_date  => l_orig_effective_date,
              p_retro_effective_date => l_retro_eff_date,
              p_time_span            => l_time_span,
              p_retro_type           => l_retro_type
             );

          IF l_time_span = 'LT12 Prev'
          THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

                IF num_tab.EXISTS(l_retro_end_date) THEN
                   num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
                ELSE
                   num_tab(l_retro_end_date) := 1;
                   l_retro_periods:=l_retro_periods + 1;
                END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
            ELSE
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
            END IF;
          END IF;

    END IF; /* End of Enhanced Retropay part */

end loop;

ELSE /* retro earnings + retro earnings spread */

for process_element in get_element_entries_all
loop

    IF l_adv_retro_flag = 'N'
    THEN

     x:=get_retro_period(process_element.element_entry_id,p_date_earned,p_tax_unit_id, retro_start_date,retro_end_date);

     if p_use_tax_flag = 'Y' then /* p_use_tax_flag = 'Y' only */

         IF  months_between(l_pay_effective_date,retro_end_date) <= 12 AND l_pay_effective_date >=
             l_eff_date_yr_start AND retro_end_date < l_eff_date_yr_start
         THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

            IF num_tab.EXISTS(l_retro_end_date) THEN
               num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
            ELSE
               num_tab(l_retro_end_date) := 1;
               l_retro_periods:=l_retro_periods + 1;
            END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               end if;
            ELSE
               if process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               else
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               end if;
            END IF;

         end if;
    end if;

    ELSE

         x := get_retro_time_span
              (
              p_element_entry_id     => process_element.element_entry_id,
              p_date_earned          => p_date_earned,
              p_tax_unit_id          => p_tax_unit_id,
              p_retro_start_date     => retro_start_date,
              p_retro_end_date       => retro_end_date,
              p_orig_effective_date  => l_orig_effective_date,
              p_retro_effective_date => l_retro_eff_date,
              p_time_span            => l_time_span,
              p_retro_type           => l_retro_type
             );

          IF l_time_span = 'LT12 Prev'
          THEN
            l_retro_end_date := to_number(to_char(retro_end_date,'DDMM'));

                IF num_tab.EXISTS(l_retro_end_date) THEN
                   num_tab(l_retro_end_date) := num_tab(l_retro_end_date) + 1;
                ELSE
                   num_tab(l_retro_end_date) := 1;
                   l_retro_periods:=l_retro_periods + 1;
                END IF;

            -- Add up the amounts. If it's a pre tax deduction then need to subtract.
            IF tot_period_amount.EXISTS(l_retro_end_date) THEN
               IF process_element.classification_name = 'Pre Tax Deductions' then
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := tot_period_amount(l_retro_end_date) + to_number(process_element.retro_amount);
               END IF;
            ELSE
               IF process_element.classification_name = 'Pre Tax Deductions' THEN
                 tot_period_amount(l_retro_end_date) := 0 - to_number(process_element.retro_amount);
               ELSE
                 tot_period_amount(l_retro_end_date) := to_number(process_element.retro_amount);
               END IF;
            END IF;
          END IF;

    END IF; /* End of Enhanced Retropay part */

end loop;

END IF;

-- Check if any periods have 0 total retro amount. If they do then don't count the retro period.

l_count := tot_period_amount.FIRST;
while l_count is not null loop

  if tot_period_amount(l_count) = 0 then
    l_retro_periods := l_retro_periods - 1;
  end if;
  l_count := tot_period_amount.NEXT(l_count);
end loop;

if g_debug then
  hr_utility.set_location('Return l_retro_periods '||l_retro_periods,80);
  hr_utility.set_location('Exiting '||l_procedure,90);
end if;

return l_retro_periods;

end count_retro_periods_2009;


function calculate_tax(p_date_earned in pay_payroll_actions.date_earned%TYPE,
                       p_period_amount in number,
                       p_period_frequency in number,
                       p_tax_scale in number,
                       p_a1_variable in number,
                       p_b1_variable in number
                       )return number is

pay_per_week number;
tax_on_weekly number;
tax_on_total_period number;
l_procedure               varchar2(80);

begin
g_debug := hr_utility.debug_enabled;

if g_debug then
  l_procedure      :='pay_au_paye_ff.calculate_tax';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_date_earned        '||to_char(p_date_earned,'dd/mm/yyyy'),20);
  hr_utility.set_location('IN p_period_amount      '||p_period_amount,25);
  hr_utility.set_location('IN p_period_frequency   '||p_period_frequency,30);
  hr_utility.set_location('IN p_tax_scale          '||p_tax_scale,35);
  hr_utility.set_location('IN p_al_variable        '||p_a1_variable,40);
  hr_utility.set_location('IN p_bl_variable        '||p_a1_variable,45);

end if;

pay_per_week:=convert_to_week(p_period_frequency,p_period_amount);

tax_on_weekly:=(p_a1_variable*pay_per_week)- p_b1_variable;

if p_tax_scale <> 4 then
  tax_on_weekly:=round(tax_on_weekly);

else
  tax_on_weekly:=trunc(tax_on_weekly);

end if;


tax_on_total_period:=convert_to_period_amt(p_period_frequency,tax_on_weekly,p_tax_scale);

if g_debug then
  hr_utility.set_location('Return tax_on_total_period '||tax_on_total_period,50);
  hr_utility.set_location('Exiting '||l_procedure,60);
end if ;

return tax_on_total_period;

end calculate_tax;



function check_fixed_deduction(p_assignment_id in per_all_assignments_f.assignment_id%TYPE, p_date_earned in date)
return varchar2 is
/* Bug 4374115 - Added check for Reverse Runs */
cursor check_fixed_deduction(p_assignment_id in number, p_date_earned in date)
is
select  'Y'
from
pay_element_types_f pet,
pay_input_values_f piv,
pay_run_result_values prrv,
pay_run_results prr,
pay_assignment_actions paa,
pay_payroll_actions ppa,
per_time_periods ptp,
per_all_assignments_f paaf
where pet.element_name = 'Extra Withholding Payments'
and piv.name='Withholding Amount'
and pet.element_type_id=piv.element_type_id
and piv.input_value_id=prrv.input_value_id
and prrv.run_result_id=prr.run_result_id
and nvl(prrv.result_value,'0') > '0'  /*Bug 4588483 */
and prr.assignment_action_id=paa.assignment_action_id
and paa.payroll_action_id=ppa.payroll_action_id
and ptp.payroll_id = ppa.payroll_id
and paa.assignment_id = p_assignment_id  /* Bug#2563515 */
and paa.assignment_id = paaf.assignment_id /* Bug#2563515 */
and p_date_earned between paaf.effective_start_date and paaf.effective_end_date /* Bug#2563515 */
and p_date_earned between ptp.start_date and ptp.end_date
and ppa.date_earned between ptp.start_date and ptp.end_date
/* Bug - 2491328 Join added for improving the performance */
and pet.element_type_id = prr.element_type_id
and pet.legislation_code = 'AU'
and piv.legislation_code = 'AU'
and paa.action_status = 'C'  /*bug 8847457*/
/* Bug - 2491328 Join added for improving the performance */
/* Bug 4374115  - Start */
and not exists(
         select pai.locking_action_id
            from pay_assignment_actions paa1,
                 pay_payroll_actions ppa1,
                 pay_action_interlocks pai
            where ppa1.payroll_action_id = paa1.payroll_action_id
            and   ppa1.action_type = 'V'
            and   paa1.assignment_id    = p_assignment_id
            and   pai.locking_action_id = paa1.assignment_action_id
            and   pai.locked_action_id  = paa.assignment_action_id
)
/* Bug 4374115  - End */
and not exists(
     select piv.name
     from
     pay_element_types_f pet,
     pay_input_values_f piv,
     pay_input_values_f piv1,
     pay_element_links_f pel, /* Bug#2563515 */
     pay_element_entries_f peef, /* Bug#2563515 */
     pay_element_entry_values_f peev,
     pay_element_entry_values_f peev1
     where pet.element_name = 'Extra Withholding Payments'
     and pet.element_type_id= piv.element_type_id
     and pet.element_type_id = pel.element_type_id /* Bug#2563515 */
     and pel.element_link_id = peef.element_link_id /* Bug#2563515 */
     and peef.element_entry_id = peev.element_entry_id /* Bug#2563515 */
     and peef.element_entry_id = peev1.element_entry_id /* Bug#2563515 */
     and piv.name='Withholding Percentage'
     and piv.input_value_id=peev.input_value_id
     and piv1.name='Withholding Amount'
     and nvl(peev1.screen_entry_value,'0') ='0'
     and piv1.input_value_id=peev1.input_value_id
     and peev.screen_entry_value is not null
     and peef.assignment_id = paaf.assignment_id /* Bug#2563515 */
     and p_date_earned between pet.effective_start_date and pet.effective_end_date
     and p_date_earned between peef.effective_start_date and peef.effective_end_date /* Bug#2563515 */
     and p_date_earned between pel.effective_start_date and pel.effective_end_date /* Bug#2563515 */
     and p_date_earned between peev1.effective_start_date and peev1.effective_end_date
     and p_date_earned between peev.effective_start_date and peev.effective_end_date
     /*Bug - 2491328 Join added for improving the performance */
     and pet.element_type_id=piv1.element_type_id
     );

l_deduction_flag varchar2(10);

l_procedure               varchar2(80);

begin
g_debug := hr_utility.debug_enabled;

 if g_debug then
  l_procedure :='pay_au_paye_ff.check_fixed_deduction';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_assignment_id '||p_assignment_id,20);
  hr_utility.set_location('IN p_date_earned   '||to_char(p_date_earned,'dd/mm/yyyy'),30);
 end if ;

OPEN check_fixed_deduction(p_assignment_id , p_date_earned);
FETCH check_fixed_deduction into l_deduction_flag;
CLOSE check_fixed_deduction;

if l_deduction_flag is null then
  l_deduction_flag:='N';
end if;

 if g_debug then
  hr_utility.set_location('OUT l_deduction_flag '||l_deduction_flag,35);
  hr_utility.set_location('Exiting '||l_procedure,40);
 end if ;

return l_deduction_flag;

end check_fixed_deduction;

FUNCTION   validate_data_magtape
   (p_data in varchar2)
RETURN   varchar2 is

   l_pos_value     VARCHAR2(1)  := NULL ;
   l_data          VARCHAR2(300):= NULL ;
   l_data_substr   VARCHAR2(300):= NULL ;
   l_ins_result    NUMBER := 0 ;
   l_counter       NUMBER := 0 ;
   l_length        NUMBER := 0 ;
   l_blank_counter NUMBER := 0 ;

BEGIN
   g_debug := hr_utility.debug_enabled;
   IF g_debug THEN
	   hr_utility.trace('Entered function pay_au_paye_ff.validate_data_magtape');
           hr_utility.trace('IN p_data '||p_data);
   END IF;

   IF (p_data IS NULL) THEN
       IF g_debug THEN
	   hr_utility.trace('Exiting function pay_au_paye_ff.validate_data_magtape');
       END IF;

      RETURN ' ';
   END IF;

   IF g_debug THEN
       hr_utility.trace('Value of the in parameter p_data ==>' || p_data);
   END IF;
   l_data     :=   replace(p_data,'_','-');

   l_length   :=   length(p_data);
   IF g_debug THEN
	   hr_utility.trace('Length of the input data passed ==>' || l_length);
   END IF;
   FOR   l_counter IN 1..l_length
      LOOP
         IF g_debug THEN
		 hr_utility.trace('Counter value ==>' || l_counter);
	 END IF;
         l_pos_value  := upper(substr(l_data,l_counter,1));
         IF g_debug THEN
		 hr_utility.trace('Value at position ' || l_counter || '==>' || l_pos_value);
	 END IF;
	 IF (l_pos_value = ' ' and l_counter > 1) THEN      /* No need to check first character */
  	    IF (l_blank_counter = l_counter - 1) THEN
               IF g_debug THEN
		       hr_utility.trace('Value ' || l_pos_value || 'is invalid. More than one space between words.');
	       END IF;
	       /* Remove all blank spaces after the first. */
	       l_data_substr := substr(l_data, l_counter, l_length);
	       l_data := substr(l_data, 1, l_blank_counter);
               l_data_substr := ltrim(l_data_substr);
	       l_data := concat(l_data, l_data_substr);
               /* We have now reduced the length of the string therefore we need to reset
                  l_length and check the new character in the current value of l_counter
                  as we cannot reassign value of l_counter. */
               l_pos_value  := upper(substr(l_data,l_counter,1));
               l_length := length(l_data);
   	    END IF;
	    l_blank_counter := l_counter;
	 END IF;

         l_ins_result := instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ()&/"''-',l_pos_value);

         IF l_ins_result = 0 THEN
            IF g_debug THEN
		    hr_utility.trace('Value ' || l_pos_value || 'is invalid');
            END IF;
	    l_data := replace(l_data,l_pos_value,' ');
         ELSE
            IF g_debug THEN
		    hr_utility.trace('Value ' || l_pos_value || 'is valid');
	    END IF;
         END IF;
      END LOOP;

   IF (ltrim(l_data) IS NULL) THEN
    IF g_debug THEN
	   hr_utility.trace('Exiting function pay_au_paye_ff.validate_data_magtape');
   END IF;
      RETURN ' ';
   ELSE
      IF g_debug THEN
	  hr_utility.trace('Final validated value ==>' || ltrim(l_data));
          hr_utility.trace('Exiting function pay_au_paye_ff.validate_data_magtape');
      END IF;
      RETURN ltrim(l_data);
   END IF;

END validate_data_magtape;

/* Bug No : 2977425 - Added the new formula function */
FUNCTION get_table_value (BUSINESS_GROUP_ID IN hr_organization_units.business_group_id%TYPE,EARN_NAME IN VARCHAR2, scale IN varchar2,EARNING_VALUE IN number,PERIOD_DATE in date,a OUT NOCOPY varchar2, b OUT NOCOPY varchar2)
RETURN VARCHAR2 IS
msg varchar2(1000);
l_procedure               varchar2(80);
BEGIN
g_debug := hr_utility.debug_enabled;

 if g_debug then
  l_procedure :='pay_au_paye_ff.get_table_value';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN BUSINESS_GROUP_ID '||BUSINESS_GROUP_ID ,20);
  hr_utility.set_location('IN EARN_NAME         '||EARN_NAME,25);
  hr_utility.set_location('IN scale             '||scale,30);
  hr_utility.set_location('IN EARNING_VALUE     '||EARNING_VALUE,35);
  hr_utility.set_location('IN PERIOD_DATE       '||to_char(PERIOD_DATE,'dd/mm/yyyy'),40);

 end if;

	IF EARNING_VALUE < 0 then
		msg := fffunc.gfm('PAY', 'HR_AU_NEGATIVE_EARNINGS','EARN_NAME',EARN_NAME, 'EARNING_VALUE',to_char(EARNING_VALUE));
                  if g_debug then
                      hr_utility.set_location('Return msg '||msg,50);
                      hr_utility.set_location('Exiting '||l_procedure,60);
                  end if;

		RETURN msg;
	ELSE
		a := hruserdt.get_table_value (BUSINESS_GROUP_ID, scale, scale||'a', TO_CHAR(EARNING_VALUE), PERIOD_DATE);
		b := hruserdt.get_table_value (BUSINESS_GROUP_ID, scale, scale||'b', TO_CHAR(EARNING_VALUE), PERIOD_DATE);

                  if g_debug then
                      hr_utility.set_location('OUT a '||a,45);
                      hr_utility.set_location('OUT b '||b,50);
                      hr_utility.set_location('Exiting '||l_procedure,60);
                  end if;

		RETURN 'ZZZ';
	END IF;


 END;


/* Bug No : 3306112 - The new function will be called from view "pay_au_asg_element_payments_v"
		 It return value of Hours in case the element_id passed is attached to the Salary Basis
*/
FUNCTION get_salary_basis_hours
(
   p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id in pay_element_entries_f.element_entry_id%TYPE,
   p_pay_bases_id    in per_all_assignments_f.pay_basis_id%TYPE
)
RETURN NUMBER IS

	l_element_type_id  pay_element_entries_f.element_entry_id%TYPE;
	l_result number := NULL;
	 l_procedure               varchar2(80);

	CURSOR Cr_value IS (
		SELECT prv.result_value
		from   pay_run_results prr,
			   pay_run_result_values prv,
			   pay_element_types_f pet,
			   pay_input_values_f piv
		where     prr.assignment_action_id = p_assignment_action_id
		and	  prv.run_result_id = prr.run_result_id
		and	  prv.input_value_id = piv.input_value_id
		and	  prr.element_type_id = pet.element_type_id
		and       piv.uom like 'H_%'
		and       piv.element_type_id= pet.element_type_id
		and       pet.element_name= 'Normal Hours');

	CURSOR Cr_element_type_id IS (
		SELECT pivf.element_type_id                     /*Bug# 3665680*/
		FROM   pay_input_values_f pivf, per_pay_bases ppb
		WHERE  pivf.input_value_id = ppb.input_value_id
		AND    ppb.pay_basis_id = p_pay_bases_id);

BEGIN
    g_debug := hr_utility.debug_enabled;

    if g_debug then
       l_procedure :='pay_au_paye_ff.get_salary_basis_hours';
       hr_utility.set_location('Entering '||l_procedure,10);
       hr_utility.set_location('IN p_assignment_action_id '||p_assignment_action_id,20);
       hr_utility.set_location('IN p_element_type_id      '||p_element_type_id,30);
       hr_utility.set_location('IN p_pay_bases_id         '||p_pay_bases_id,40);
    end if ;

	OPEN Cr_element_type_id;
	FETCH Cr_element_type_id INTO l_element_type_id;
	CLOSE Cr_element_type_id;

	IF p_element_type_id = l_element_type_id THEN
		OPEN Cr_value;
		FETCH Cr_value INTO l_result;
		CLOSE Cr_value;
	END IF;

	if g_debug then
           hr_utility.set_location('OUT l_result '||l_result,50);
           hr_utility.set_location('Exiting '||l_procedure,60);
       end if ;

 RETURN l_result;



END;


/* Bug No : 3245909 - To get prepayment locking action_id for AU_PAYMENTS route */
function get_pp_action_id(p_action_type in varchar2,
                          p_action_id   in number
                         ) return number
is
CURSOR Cr_action IS
	select INTLK.locking_action_id
	 from pay_action_interlocks INTLK,
	      pay_assignment_actions paa,
	      pay_payroll_actions    ppa
	where INTLK.locked_action_id = p_action_id
	  and INTLK.locking_action_id = paa.assignment_action_id
	  and paa.payroll_action_id = ppa.payroll_action_id
	  and ppa.action_type in ('P', 'U')
	  and paa.source_action_id is null;

l_action_id number;
l_procedure               varchar2(80);

begin
    g_debug := hr_utility.debug_enabled;
 if g_debug then
  l_procedure:='pay_au_paye_ff.get_pp_action_id';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_action_type '||p_action_type,20);
  hr_utility.set_location('IN p_action_id   '|| p_action_id,30);
 end if;

--
    if (p_action_type in ('P', 'U')) then
      l_action_id := p_action_id;
    elsif (p_action_type in ('R', 'Q','I','B')) then
--
--     Always return the master prepayment action.
--
		OPEN Cr_action;
		FETCH Cr_action INTO l_action_id;
		CLOSE Cr_action;
    else
        l_action_id := null;
    end if;

    if g_debug then
	  hr_utility.set_location('OUT l_action_id '||l_action_id,40);
	  hr_utility.set_location('Exiting '||l_procedure,50);
    end if;
--
    return l_action_id;
--

end get_pp_action_id;

/*Bug# 3935471
  The purpose of this function is to check whether child assignment action has the same tax unit id as compared
  to the master assignment action id. If the tax unit id is same it returns 'Y' else it returns 'N'.
  If the assignment action id passed to this function dosen't have a child then this function returns 'Y'.
  */

FUNCTION check_tax_unit_id
(
   p_assignment_action_id in NUMBER,
   p_tax_unit_id IN NUMBER
)
RETURN VARCHAR2 IS

CURSOR c_get_master_tax_unit_id
IS
SELECT paa_master.tax_unit_id
FROM pay_assignment_actions paa_child,
     pay_assignment_actions paa_master
WHERE paa_child.assignment_action_id = p_assignment_action_id
AND paa_master.assignment_action_id = paa_child.source_action_id;

l_flag VARCHAR2(10);
l_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE;
l_procedure               varchar2(80);

BEGIN
g_debug := hr_utility.debug_enabled;
if g_debug then
  l_procedure :='pay_au_paye_ff.check_tax_unit_id';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_assignment_action_id '||p_assignment_action_id,20);
  hr_utility.set_location('IN p_tax_unit_id          '|| p_tax_unit_id,30);
end if;
   OPEN c_get_master_tax_unit_id;
   FETCH c_get_master_tax_unit_id INTO l_tax_unit_id;
   IF c_get_master_tax_unit_id%NOTFOUND THEN
      l_flag := 'Y';

      if g_debug then
	  hr_utility.set_location('Return l_flag '||l_flag,40);
	  hr_utility.set_location('Exiting '||l_procedure,50);
      end if;
      RETURN l_flag;
   ELSE
      IF l_tax_unit_id <> p_tax_unit_id THEN
         l_flag := 'N';

	 if g_debug then
	      hr_utility.set_location('Return l_flag '||l_flag,40);
	      hr_utility.set_location('Exiting '||l_procedure,50);
         end if;

	 RETURN l_flag;
      ELSE
         l_flag := 'Y';

	 if g_debug then
               hr_utility.set_location('Return l_flag '||l_flag,40);
               hr_utility.set_location('Exiting '||l_procedure,50);
         end if;

	 RETURN l_flag;
      END IF;
   END IF;

   CLOSE c_get_master_tax_unit_id;

end check_tax_unit_id;

/* Bug#5934468 Function returns ths spread earning. This earning gets used in
                formula AU_HECS_DEDUCTION and AU_SFSS_DEDUCTION
*/

function get_spread_earning
          ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
            p_date_paid in date,
            p_pre_tax in number,
            p_spread_earning in number) return number is

cursor get_period_spread_over is
select prv.RESULT_VALUE period_spread_over, prr.run_result_id, pee.creator_type
from pay_element_types_f pet,
     pay_input_values_f piv,
     pay_run_result_values prv,
     pay_run_results prr,
     pay_element_entries_f pee
where prr.assignment_action_id=p_assignment_action_id
  and prr.RUN_RESULT_ID = prv.RUN_RESULT_ID
  and prv.input_value_id = piv.input_value_id
  and piv.name ='Periods Spread Over'
  and piv.legislation_code='AU'
  and piv.element_type_id = pet.element_type_id
  and pet.legislation_code='AU'
  and pet.element_type_id = prr.element_type_id
  and pet.element_name='Spread Deduction'
  and prr.source_id = pee.element_entry_id
  and prr.status in ('P','PA')  /* bug7665727 to ensure to pick up processed run results only */
  and pee.creator_type not in ('EE','RR')
  and p_date_paid between pet.effective_start_date and pet.effective_end_date
  and p_date_paid between piv.effective_start_date and piv.effective_end_date
  and p_date_paid between pee.effective_start_date and pee.effective_end_date;

cursor get_spread_earning(p_run_result_id pay_run_results.run_result_id%type) is
select prv.RESULT_VALUE
from pay_input_values_f piv,
     pay_run_result_values prv,
     pay_run_results prr
 where prr.RUN_RESULT_ID = p_run_result_id
   and prr.RUN_RESULT_ID = prv.RUN_RESULT_ID
   and prv.input_value_id = piv.input_value_id
   and piv.name ='Total Payment'
   and piv.legislation_code='AU'
   and p_date_paid between piv.effective_start_date and piv.effective_end_date;

/* new cursor for bug 6669058 */
cursor get_retro_spread_earning is
select nvl(sum(prv.RESULT_VALUE),0)
from pay_element_types_f pet,
     pay_input_values_f piv,
     pay_run_result_values prv,
     pay_run_results prr,
     pay_element_entries_f pee
where prr.assignment_action_id=p_assignment_action_id
  and prr.RUN_RESULT_ID = prv.RUN_RESULT_ID
  and prv.input_value_id = piv.input_value_id
   and piv.name ='Total Payment'
  and piv.legislation_code='AU'
  and piv.element_type_id = pet.element_type_id
  and pet.legislation_code='AU'
  and pet.element_type_id = prr.element_type_id
  and pet.element_name='Spread Deduction'
  and prr.source_id = pee.element_entry_id
  and pee.creator_type in ('EE','RR')
  and p_date_paid between pet.effective_start_date and pet.effective_end_date
  and p_date_paid between piv.effective_start_date and piv.effective_end_date
  and p_date_paid between pee.effective_start_date and pee.effective_end_date;

l_total_spread_earning number;
l_spread_earning  number;
l_spread_percent number;
l_retro_spread_earning number;
l_spread_earning_total number;

l_procedure               varchar2(80);

begin

g_debug := hr_utility.debug_enabled;
if g_debug then
  l_procedure :='pay_au_paye_ff.get_spread_earning';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_assignment_action_id '||p_assignment_action_id,20);
  hr_utility.set_location('IN p_date_paid            '|| p_date_paid,20);
  hr_utility.set_location('IN p_pre_tax              '|| p_pre_tax,20);
  hr_utility.set_location('IN p_spread_earning       '|| p_spread_earning,20);
end if;

l_total_spread_earning := 0;
l_spread_earning  := 0;
l_retro_spread_earning := 0;
l_spread_earning_total := 0;

if to_char(p_date_paid, 'dd/mm/yyyy') < '01/07/2009' then

/* Calculate spread earning for current period only - bug 6669058 */
     open   get_retro_spread_earning;
     fetch  get_retro_spread_earning into l_retro_spread_earning;
     close  get_retro_spread_earning;

l_spread_earning_total := p_spread_earning -l_retro_spread_earning;

    if l_spread_earning_total = 0 then
       return l_total_spread_earning;
    else
         for rec in get_period_spread_over
         loop

             open   get_spread_earning(rec.run_result_id);
             fetch  get_spread_earning into l_spread_earning;
             close  get_spread_earning;

             l_spread_percent := l_spread_earning/l_spread_earning_total;
             l_spread_earning :=  (l_spread_earning-  p_pre_tax * l_spread_percent )/rec.period_spread_over  ;
             l_total_spread_earning := l_total_spread_earning + l_spread_earning;

         end loop;
    end if;

else /* bug 7665727 - after 01-JUL-2009 */

l_spread_earning_total := p_spread_earning;

    if l_spread_earning_total = 0 then
       return l_total_spread_earning;
    else
         for rec in get_period_spread_over
         loop

             open   get_spread_earning(rec.run_result_id);
             fetch  get_spread_earning into l_spread_earning;
             close  get_spread_earning;

             l_spread_percent := l_spread_earning/l_spread_earning_total;
             l_spread_earning :=  (l_spread_earning-  p_pre_tax * l_spread_percent )/rec.period_spread_over  ;
             l_total_spread_earning := l_total_spread_earning + l_spread_earning;

         end loop;
    end if;

end if;

if g_debug then
  hr_utility.set_location('OUT p_spread_earning      '|| l_total_spread_earning,30);
  hr_utility.set_location('Leaving '||l_procedure,10);
end if;


 return l_total_spread_earning;
end;

/* new function for bug#6669058 */
function get_retro_spread_earning
          ( p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
            p_date_paid in date,
            p_pre_tax in number,
            p_spread_earning in number) return number is

cursor get_retro_spread_earning is
select nvl(sum(prv.RESULT_VALUE),0)
from pay_element_types_f pet,
     pay_input_values_f piv,
     pay_run_result_values prv,
     pay_run_results prr,
     pay_element_entries_f pee
where prr.assignment_action_id=p_assignment_action_id
  and prr.RUN_RESULT_ID = prv.RUN_RESULT_ID
  and prv.input_value_id = piv.input_value_id
   and piv.name ='Total Payment'
  and piv.legislation_code='AU'
  and piv.element_type_id = pet.element_type_id
  and pet.legislation_code='AU'
  and pet.element_type_id = prr.element_type_id
  and pet.element_name='Spread Deduction'
  and prr.source_id = pee.element_entry_id
  and pee.creator_type in ('EE','RR')
  and p_date_paid between pet.effective_start_date and pet.effective_end_date
  and p_date_paid between piv.effective_start_date and piv.effective_end_date
  and p_date_paid between pee.effective_start_date and pee.effective_end_date;

l_retro_spread_earning number;

l_procedure               varchar2(80);

begin

g_debug := hr_utility.debug_enabled;
if g_debug then
  l_procedure :='pay_au_paye_ff.get_retro_spread_earning';
  hr_utility.set_location('Entering '||l_procedure,10);
  hr_utility.set_location('IN p_assignment_action_id '||p_assignment_action_id,20);
  hr_utility.set_location('IN p_date_paid            '|| p_date_paid,20);
  hr_utility.set_location('IN p_pre_tax              '|| p_pre_tax,20);
  hr_utility.set_location('IN p_spread_earning       '|| p_spread_earning,20);
end if;

l_retro_spread_earning := 0;

     open   get_retro_spread_earning;
     fetch  get_retro_spread_earning into l_retro_spread_earning;
     close  get_retro_spread_earning;

if g_debug then
  hr_utility.set_location('OUT p_retro_spread_earning      '|| l_retro_spread_earning,30);
  hr_utility.set_location('Leaving '||l_procedure,10);
end if;


 return l_retro_spread_earning;
end;

/* bug6809877 - Adeed new function get_etp_pay_component */
function get_etp_pay_component
          ( p_assignment_id in per_all_assignments_f.assignment_id%type,
            p_date_earned in date) return varchar2 is

cursor etp_pay_csr ( c_assignment_id per_all_assignments_f.assignment_id%type,
                     c_date_earned date) is
select peev.screen_entry_value
from pay_element_types_f pet,
     pay_input_values_f piv,
     pay_element_entries_f pee,
     pay_element_entry_values_f peev
where pee.assignment_id = c_assignment_id
  and piv.name ='Pay ETP Components'
  and piv.legislation_code='AU'
  and piv.element_type_id = pet.element_type_id
  and pet.legislation_code='AU'
  and pet.element_name='ETP on Termination'
  and piv.input_value_id = peev.input_value_id
  and peev.element_entry_id = pee.element_entry_id
  and c_date_earned between pet.effective_start_date and pet.effective_end_date
  and c_date_earned between piv.effective_start_date and piv.effective_end_date
  and c_date_earned between pee.effective_start_date and pee.effective_end_date
  and c_date_earned between peev.effective_start_date and peev.effective_end_date
  and rownum = 1;

l_etp_pay  pay_element_entry_values_f.screen_entry_value%type;

begin

  open etp_pay_csr (p_assignment_id, p_date_earned);
  fetch etp_pay_csr into l_etp_pay;
    if etp_pay_csr%notfound then
      l_etp_pay := 'zzz';
  end if;
  close etp_pay_csr;

 return l_etp_pay;

end;

/*bug8406009 - calc_average_earnings function to calculate the average earnings.*/
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
RETURN NUMBER
AS

l_procedure                 VARCHAR2(80);
l_periods                   NUMBER;
l_average_earnings          NUMBER;
l_check_tax_unit            VARCHAR2(10);
l_total_avg_earn            NUMBER;
l_case                      VARCHAR2(80);
l_error                     VARCHAR2(80);

l_prev_earnings_standard    NUMBER;
l_prev_pre_tax_spread       NUMBER;
l_prev_pre_tax_fixed        NUMBER;
l_prev_pre_tax_prog         NUMBER;
l_prev_paid_periods         NUMBER;

l_dummy                     NUMBER;


BEGIN

    g_debug             := hr_utility.debug_enabled;
    l_case              := NULL;
    l_average_earnings  := 0;

    IF g_debug
    THEN
        l_procedure     := 'pay_au_paye_ff.calc_average_earnings';
        hr_utility.set_location('Entering procedure         '||l_procedure,1000);
        hr_utility.set_location('p_assignment_id            '||p_assignment_id,1000);
        hr_utility.set_location('p_assignment_action_id     '||p_assignment_action_id,1000);
        hr_utility.set_location('p_payroll_id               '||p_payroll_id,1000);
        hr_utility.set_location('p_tax_unit_id              '||p_tax_unit_id,1000);
        hr_utility.set_location('p_earnings_std_ytd         '||p_earnings_std_ytd,1000);
        hr_utility.set_location('p_earnings_std_ptd         '||p_earnings_std_ptd,1000);
        hr_utility.set_location('p_taxable_value            '||p_taxable_value,1000);
    END IF;

    l_periods   := pay_au_paye_ff.periods_since_hire_date(p_payroll_id
                                                         ,p_assignment_id
                                                         ,p_tax_unit_id
                                                         ,p_assignment_action_id
                                                         ,1                     /* p_period_num defaulted to 1 */
                                                         ,p_period_start_date
                                                         ,p_emp_hire_date
                                                         ,'Y');

    IF ((l_periods <= 1) OR (p_earnings_std_ytd = p_earnings_std_ptd))
    THEN
        l_average_earnings      := 0;
    ELSE
        l_check_tax_unit        := pay_au_paye_ff.check_tax_unit_id(p_assignment_action_id,p_tax_unit_id);
        IF (l_check_tax_unit = 'Y')
        THEN
            l_periods   := l_periods - 1;
        END IF;
        l_average_earnings  :=  (p_earnings_std_ytd - p_earnings_std_ptd)/l_periods;
    END IF;


    IF g_debug
    THEN
        hr_utility.set_location('Point 1                    ',1100);
        hr_utility.set_location('l_average_earnings         '||l_average_earnings,1100);
        hr_utility.set_location('l_periods                  '||l_periods,1100);
    END IF;

    l_total_avg_earn    := l_average_earnings + p_taxable_value;
    IF ( (l_total_avg_earn < 0) OR l_average_earnings = 0)
    THEN

            l_dummy := pay_au_paye_ff.calculate_asg_prev_value
                        (p_assignment_id
                        ,p_business_group_id
                        ,p_date_earned
                        ,p_tax_unit_id
                        ,p_assignment_action_id
                        ,p_payroll_id
                        ,p_period_start_date
                        ,l_case
                        ,l_prev_earnings_standard
                        ,l_prev_pre_tax_spread
                        ,l_prev_pre_tax_fixed
                        ,l_prev_pre_tax_prog
                        ,l_prev_paid_periods
                        ,'Y');

            IF (l_prev_paid_periods > 0)
            THEN
                l_average_earnings  := (l_prev_earnings_standard + l_prev_pre_tax_spread + l_prev_pre_tax_fixed + l_prev_pre_tax_prog)/l_prev_paid_periods;
            END IF;
    END IF;

    IF g_debug
    THEN
        hr_utility.set_location('Point 2                        ',1100);
        hr_utility.set_location('l_average_earnings             '||l_average_earnings,1200);
        hr_utility.set_location('l_prev_earnings_standard       '||l_prev_earnings_standard,1200);
        hr_utility.set_location('l_prev_paid_periods            '||l_prev_paid_periods,1200);
    END IF;

        p_average_earnings    := l_average_earnings;
        p_case                := l_case;

    IF g_debug
    THEN
        hr_utility.set_location('p_average_earnings             '||p_average_earnings,1300);
        hr_utility.set_location('p_case                         '||p_case,1300);
        hr_utility.set_location('Leaving function               '||l_procedure,1300);
    END IF;

    RETURN (1);

END calc_average_earnings;

/*bug8406009 - calc_lt12_prev_spread_tax function is added for retro spread deduction in previous financial year less than 12 months*/
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
RETURN VARCHAR2
IS
CURSOR get_retro_spread_entries
        (c_assignment_id        IN pay_assignment_actions.assignment_id%TYPE
        ,c_date_earned          IN pay_payroll_actions.date_earned%TYPE)
IS
SELECT  pee.element_entry_id,
        peev.screen_entry_value retro_amount,
        pee.creator_type
FROM    pay_element_entries_f pee,
        pay_element_entry_values_f peev,
        pay_element_links_f pelf,
        pay_element_types_f pet,
        pay_element_classifications pec,
        pay_input_values_f piv,
        pay_sub_classification_rules_f psc,
        pay_element_classifications pec2
WHERE pee.assignment_id = c_assignment_id
AND   pee.creator_type IN ('EE','RR')
AND   c_date_earned BETWEEN pee.effective_start_date AND pee.effective_end_date
AND   pelf.element_link_id = pee.element_link_id
AND   c_date_earned BETWEEN pelf.effective_start_date AND pelf.effective_end_date
AND   pet.element_type_id = pelf.element_type_id
AND   c_date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date
AND   pec.classification_id = pet.classification_id
AND   pec.classification_name = 'Earnings'
AND   pet.element_type_id = psc.element_type_id
AND   psc.classification_id = pec2.classification_id
AND   pec2.classification_name = 'Spread'
AND   peev.element_entry_id = pee.element_entry_id
AND   c_date_earned BETWEEN peev.effective_start_date AND peev.effective_end_date
AND   peev.input_value_id = piv.input_value_id
AND   c_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date
AND   piv.name = 'Pay Value';


CURSOR get_spread_over_ee
        (c_element_entry_id     IN pay_element_entries_f.element_entry_id%TYPE
        ,c_assignment_id        IN pay_assignment_actions.assignment_id%TYPE
        ,c_date_earned          IN DATE )
IS
SELECT peev.screen_entry_value
FROM  pay_element_entries_f pee
     ,pay_element_entry_values_f  peev
     ,pay_input_values_f    pivf
WHERE pee.element_entry_id  = c_element_entry_id
AND   pee.assignment_id     = c_assignment_id
AND   pee.creator_type      = 'EE'
AND   pee.element_entry_id  = peev.element_entry_id
AND   pee.element_type_id   = pivf.element_type_id
AND   pivf.name             = 'Periods Spread Over'
AND   peev.input_value_id   = pivf.input_value_id
AND   c_date_earned         BETWEEN pee.effective_start_date  AND pee.effective_end_date
AND   c_date_earned         BETWEEN peev.effective_start_date AND peev.effective_end_date
AND   c_date_earned         BETWEEN pivf.effective_start_date AND pivf.effective_end_date;

CURSOR get_spread_over_rr
        (c_element_entry_id     IN pay_element_entries_f.element_entry_id%TYPE
        ,c_assignment_id        IN pay_assignment_actions.assignment_id%TYPE
        ,c_date_earned          IN DATE )
IS
SELECT prrv.result_value
FROM   pay_run_results prr
      ,pay_run_result_values prrv
      ,pay_input_values_f pivf
      ,pay_element_entries_f pee
WHERE pee.element_entry_id     = c_element_entry_id
AND   pee.assignment_id        = c_assignment_id
AND   pee.creator_type         = 'RR'
AND   prr.run_result_id        = pee.source_id
AND   prr.run_result_id        = prrv.run_result_id
AND   prr.assignment_action_id = pee.source_asg_action_id
AND   prrv.input_value_id      = pivf.input_value_id
AND   pivf.name                = 'Periods Spread Over'
AND   c_date_earned         BETWEEN pee.effective_start_date and pee.effective_end_date;

CURSOR get_legislation_rule
IS
SELECT plr.rule_mode
FROM   pay_legislation_rules plr
WHERE  plr.legislation_code = 'AU'
AND    plr.rule_type ='ADVANCED_RETRO';


CURSOR c_get_effective_date(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT ppa.effective_date
FROM   pay_payroll_actions ppa
      ,pay_assignment_actions paa
WHERE paa.assignment_action_id = c_assignment_action_id
AND   paa.payroll_action_id    = ppa.payroll_action_id;


l_procedure                VARCHAR2(80);
l_adv_retro_flag           VARCHAR2(10);
l_retro_start_date         DATE;
l_retro_end_date           DATE;
l_dummy                    VARCHAR2(1000) := 'ZZZ';
l_pay_effective_date       DATE;
l_eff_date_yr_start        DATE;
l_retro_eff_date           DATE;
l_orig_effective_date      DATE;
l_time_span                VARCHAR2(80);
l_retro_type               VARCHAR2(80);
l_weekly_earnings          NUMBER;
l_period_earnings          NUMBER;

l_avg_tax                  NUMBER;
l_spread_tax               NUMBER;
l_spred_tax_period         NUMBER;
l_total_spread_tax         NUMBER;


TYPE num_tab_type  IS TABLE OF NUMBER INDEX BY binary_integer;
TYPE char_tab_type IS TABLE OF VARCHAR2(10) INDEX BY binary_integer;

l_element_entry_tab num_tab_type;
l_entry_value_tab   num_tab_type;
l_creator_type_tab  char_tab_type;

i_index                     NUMBER;
l_spread_over               NUMBER;
l_a1                        NUMBER;
l_b1                        NUMBER;
l_a2                        NUMBER;
l_b2                        NUMBER;



BEGIN

g_debug     := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure     := 'pay_au_paye_ff.calc_lt12_prev_spread_tax';
        hr_utility.set_location('Entering procedure         '||l_procedure,1000);
        hr_utility.set_location('p_assignment_id            '||p_assignment_id,1000);
        hr_utility.set_location('p_assignment_action_id     '||p_assignment_action_id,1000);
        hr_utility.set_location('p_date_earned              '||p_date_earned,1000);
        hr_utility.set_location('p_average_earnings         '||p_average_earnings,1000);
END IF;



OPEN get_legislation_rule;
FETCH get_legislation_rule INTO l_adv_retro_flag;
    IF  get_legislation_rule%NOTFOUND THEN
        l_adv_retro_flag := 'N';
    END IF;
CLOSE get_legislation_rule;

OPEN  c_get_effective_date(p_assignment_action_id);
FETCH c_get_effective_date INTO l_pay_effective_date;
CLOSE c_get_effective_date;

l_eff_date_yr_start := hr_au_routes.span_start(l_pay_effective_date,1,'01-07');

IF g_debug THEN
    hr_utility.set_location('Enhanced Retropay Rule Value =>'||l_adv_retro_flag,70);
END IF;

i_index := 0;

FOR csr_rec IN get_retro_spread_entries(p_assignment_id,p_date_earned)
LOOP

    IF (l_adv_retro_flag = 'N')
    THEN
    /* Retropay by element scenario */
        l_dummy     :=  pay_au_paye_ff.get_retro_period
                            (csr_rec.element_entry_id
                            ,p_date_earned
                            ,p_tax_unit_id
                            ,l_retro_start_date
                            ,l_retro_end_date);

         IF  (months_between(l_pay_effective_date,l_retro_end_date) <= 12
             AND l_pay_effective_date >= l_eff_date_yr_start
             AND l_retro_end_date < l_eff_date_yr_start)
         THEN
                l_element_entry_tab(i_index)    := csr_rec.element_entry_id;
                l_entry_value_tab(i_index)      := csr_rec.retro_amount;
                l_creator_type_tab(i_index)     := csr_rec.creator_type;
                i_index := i_index + 1;
         END IF;
    ELSE
    /* Enhanced Retropay Scenario */
        l_dummy  := pay_au_paye_ff.get_retro_time_span
                      (
                      p_element_entry_id     => csr_rec.element_entry_id,
                      p_date_earned          => p_date_earned,
                      p_tax_unit_id          => p_tax_unit_id,
                      p_retro_start_date     => l_retro_start_date,
                      p_retro_end_date       => l_retro_end_date,
                      p_orig_effective_date  => l_orig_effective_date,
                      p_retro_effective_date => l_retro_eff_date,
                      p_time_span            => l_time_span,
                      p_retro_type           => l_retro_type
                     );

          IF l_time_span = 'LT12 Prev'
          THEN
                l_element_entry_tab(i_index)    := csr_rec.element_entry_id;
                l_entry_value_tab(i_index)      := csr_rec.retro_amount;
                l_creator_type_tab(i_index)     := csr_rec.creator_type;
                i_index := i_index + 1;
          END IF;
    END IF;

END LOOP;

IF (l_element_entry_tab.COUNT > 0)
THEN
    l_total_spread_tax  := 0;
    l_weekly_earnings   := pay_au_paye_ff.convert_to_week(p_period_frequency,p_average_earnings);
    l_dummy             := pay_au_paye_ff.get_table_value
                                            (p_business_group_id
                                            ,'Average Earnings'
                                            ,'TAX_SCALE_'||p_tax_scale
                                            ,l_weekly_earnings
                                            ,l_pay_effective_date
                                            ,l_a1
                                            ,l_b1);
    IF l_dummy <> 'ZZZ' THEN
        return l_dummy;
    END IF;

    l_avg_tax           := pay_au_paye_ff.calculate_tax
                                            (p_date_earned
                                            ,p_average_earnings
                                            ,p_period_frequency
                                            ,p_tax_scale
                                            ,l_a1
                                            ,l_b1);

IF g_debug THEN
    hr_utility.set_location('l_avg_tax '||l_avg_tax,1001);
END IF;

    FOR i IN l_element_entry_tab.FIRST..l_element_entry_tab.LAST
    LOOP
        IF l_creator_type_tab(i) ='EE'
        THEN
            /* New entry comes from an Inserted entry, get the
            Periods spread over from retro entry
            Assumption: The retro entry has the input 'Periods Spread Over' */
            OPEN get_spread_over_ee(l_element_entry_tab(i)
                                    ,p_assignment_id
                                    ,p_date_earned);
            FETCH get_spread_over_ee INTO l_spread_over;
            CLOSE get_spread_over_ee;
        ELSE /* Creator Case 'RR' - fetch periods from run results */
            OPEN get_spread_over_rr(l_element_entry_tab(i)
                                    ,p_assignment_id
                                    ,p_date_earned);
            FETCH get_spread_over_rr INTO l_spread_over;
            CLOSE get_spread_over_rr;
        END IF;

        IF l_spread_over = 0
        THEN
                l_spread_over := 1;                          /* Avoid Divide by 0 errors. If we do not find any periods, we tax them as paid in a period */
        END IF;
        l_period_earnings   := p_average_earnings + TRUNC(l_entry_value_tab(i)/l_spread_over);
        l_weekly_earnings   := pay_au_paye_ff.convert_to_week(p_period_frequency,l_period_earnings);
        l_dummy             := pay_au_paye_ff.get_table_value
                                            (p_business_group_id
                                            ,'Total Average Earnings'
                                            ,'TAX_SCALE_'||p_tax_scale
                                            ,l_weekly_earnings
                                            ,l_pay_effective_date
                                            ,l_a2
                                            ,l_b2);

        IF l_dummy <> 'ZZZ' THEN
             return l_dummy;
        END IF;

        l_spread_tax         := pay_au_paye_ff.calculate_tax
                                            (p_date_earned
                                            ,l_period_earnings
                                            ,p_period_frequency
                                            ,p_tax_scale
                                            ,l_a2
                                            ,l_b2);
        l_spred_tax_period   := (l_spread_tax - l_avg_tax) * l_spread_over;
        l_total_spread_tax   := l_total_spread_tax + l_spred_tax_period;

        IF g_debug
        THEN
            hr_utility.set_location('Element Entry ID               '||l_element_entry_tab(i),1000);
            hr_utility.set_location('Entry Value                    '||l_entry_value_tab(i),1000);
            hr_utility.set_location('Creator Type                   '||l_creator_type_tab(i),1000);
            hr_utility.set_location('Periods Spread Over            '||l_spread_over,1000);
            hr_utility.set_location('l_period_earnings              '||l_period_earnings,1000);
            hr_utility.set_location('l_spread_tax                   '||l_spread_tax,1000);
            hr_utility.set_location('l_spred_tax_period             '||l_spred_tax_period,1000);
        END IF;
    END LOOP;
END IF;

        p_spread_tax := l_total_spread_tax;

        IF g_debug
        THEN
            hr_utility.set_location('p_spread_tax             '||p_spread_tax,1200);
            hr_utility.set_location('Leaving function         '||l_procedure,1200);
        END IF;

return l_dummy;

END calc_lt12_prev_spread_tax;

/*  Bug 8765082 - Functions added for Retropay Leave Loading Taxation
    Function    : get_retro_leave_load
    Description : This function is to be used during a Retropay recalculation run.
                  AU has RETRO_DELETE legislation rule enabled, therefore all results are marked
                  with status 'B' during Retropay recalculation.
                  This function checks if any Retro Leave Loading GT12, LT12 Prev have been processed
                  until now and if so, adjust it against the Retro Tax Free annual amount ($320)
    Inputs      : p_assignment_action_id    - Assignment Action ID
                  p_tax_unit_id             - Tax Unit ID
    Outputs     : p_retro_adj_leave_load    - Retro Leave Loading Amount
*/

FUNCTION  get_retro_leave_load
            (p_assignment_action_id     IN         NUMBER
            ,p_tax_unit_id              IN         NUMBER
            ,p_retro_adj_leave_load     OUT NOCOPY NUMBER)
RETURN NUMBER
AS
/* Cursor replicates RR Route for _ASG_LE_YTD with status = 'B' check added */
CURSOR  get_retro_ytd_results(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE
                             ,c_tax_unit_id          pay_assignment_actions.tax_unit_id%TYPE
                             ,c_balance_type_id      pay_balance_types.balance_type_id%TYPE
                             )
IS
                      SELECT  SUM(NVL(TARGET.result_value,0))
                       FROM
                               pay_balance_feeds_f      FEED
                            ,  pay_run_result_values    TARGET
                            ,  pay_run_results          prr
                            ,  pay_payroll_actions      ppa
                            ,  pay_assignment_actions   paa
                            ,  pay_payroll_actions      ppas
                            ,  pay_assignment_actions   paas
                        where  paas.assignment_action_id   = c_assignment_action_id
                          and  paas.payroll_action_id      = ppas.payroll_action_id
                          and  FEED.input_value_id         = TARGET.input_value_id
                          and  TARGET.run_result_id        = prr.run_result_id
                          and  nvl(TARGET.result_value,'0') <> '0'
                          and  prr.assignment_action_id    = paa.assignment_action_id
                          and  paa.payroll_action_id       = ppa.payroll_action_id
                          and  ppa.effective_date  between  FEED.effective_start_date and FEED.effective_end_date
                          and  prr.status                  = 'B'
                          and  ppa.effective_date         >= hr_au_routes.span_start(ppas.effective_date, 1, '01-07-')
                          and  paa.action_sequence        <= paas.action_sequence
                          and  paa.assignment_id           = paas.assignment_id
                          and  paa.tax_unit_id             = c_tax_unit_id
                          and  FEED.balance_type_id        = c_balance_type_id ;


CURSOR c_get_balance_details
IS
SELECT  PBT.balance_name
       ,PBT.balance_type_id
FROM    pay_balance_types  PBT
WHERE  PBT.balance_name IN  ('Retro Earnings Leave Loading LT 12 Mths Prev Yr Amount'
                            ,'Retro Earnings Leave Loading GT 12 Mths Amount')
AND    PBT.legislation_code ='AU';

CURSOR check_retro_run(c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
IS
SELECT COUNT(*)
FROM  pay_assignment_actions paa
WHERE paa.assignment_action_id = c_assignment_action_id
AND   paa.action_status = 'B';

l_adj_retro_value       NUMBER;
l_fetched_value         NUMBER;
l_gen                   NUMBER;
l_exists                NUMBER;
l_procedure             VARCHAR2(80);


BEGIN

g_debug         := hr_utility.debug_enabled;

IF g_debug
THEN
        l_procedure     := 'pay_au_paye_ff.get_retro_leave_load';
        hr_utility.set_location('Entering procedure         '||l_procedure,1000);
        hr_utility.set_location('IN p_assignment_action_id  '||p_assignment_action_id,1000);
        hr_utility.set_location('IN p_tax_unit_id           '||p_tax_unit_id,1000);
END IF;

l_adj_retro_value       := 0;

/* Since we are running the data intensive Run Result route, confirm this is a Retro Run */
    OPEN check_retro_run(p_assignment_action_id);
    FETCH check_retro_run INTO l_exists;
    CLOSE check_retro_run;

IF l_exists <> 0
THEN

    FOR csr_rec IN  c_get_balance_details
    LOOP

        OPEN get_retro_ytd_results(p_assignment_action_id
                                  ,p_tax_unit_id
                                  ,csr_rec.balance_type_id
                                  );
        FETCH get_retro_ytd_results INTO l_fetched_value;
        CLOSE get_retro_ytd_results;

        IF g_debug THEN
                    hr_utility.set_location('Balance Name        '||csr_rec.balance_name,1000);
                    hr_utility.set_location('l_fetched_value     '||l_fetched_value,1000);
        END IF;

        l_adj_retro_value   := l_adj_retro_value + NVL(l_fetched_value,0);
    END LOOP;
END IF;

p_retro_adj_leave_load  := l_adj_retro_value;

IF g_debug THEN
            hr_utility.set_location('p_retro_adj_leave_load     '||p_retro_adj_leave_load,1000);
            hr_utility.set_location('Leaving procedure          '||l_procedure,1000);
END IF;

RETURN 0;

END get_retro_leave_load;

end pay_au_paye_ff;

/
