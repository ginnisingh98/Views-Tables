--------------------------------------------------------
--  DDL for Package Body PAY_US_RSRW_UPGREV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_RSRW_UPGREV" AS
/* $Header: payusrsrwupg.pkb 120.0.12010000.5 2009/07/06 05:44:27 sudedas noship $ */
/*****************************************************************************
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_regsal_upgrade

    Description : This package is called by a concurrent program.
                  In this package we upgrade Old Seeded Earnings
                  Elements Regular Salary and Regular Wages
                  to New Architecture (with Enabled Functionality
                  of Core Proration) for US Legislation.

                  NOTE : Customer needs to recompile Fast Formula
                  'REGULAR_SALARY', 'REGULAR_WAGES' after Upgradation.

    Change List
    -----------
        Date       Name     Ver     Bug No    Description
     ----------- -------- -------  ---------  -------------------------------
     11-Aug-2008 sudedas  115.0    5895804
                                   3556204
                                ER 3855241    Created.
     17-Sep-2008 sudedas  115.1               Corrected GSCC Errors.
     20-Oct-2008 sudedas  115.2               Corrected chksql Errors.
     27-Apr-2009 sudedas  115.3    8464127    Added functions get_upgrade_flag
                                              and get_payprd_per_fiscal_yr.
                                              Modified procedures to make the
                                              changes permanent except for
                                              proration group.
     22-Jun-2009 sudedas  115.4               Added function to check status
                                              type by get_assignment_status.
                                              Added assignment_status_type_id
                                              in Proration Event Group.
     06-Jul-2009 sudedas  115.7    8637053    Added context element_type_id to
                                              function get_payprd_per_fiscal_yr
*****************************************************************************/

 /************************************************************
  ** Local Package Variables
  ************************************************************/

  gv_package_name        varchar2(50) := 'pay_us_regsal_upgrade';
  gv_location            number;

/*****************************************************************************
  Name        : modify_formula_text

  Description : This function modifies the text of the 'REGULAR_SALARY'
                and 'REGULAR_WAGES' Fast Formula.
*****************************************************************************/
PROCEDURE modify_formula_text(p_ele_name IN VARCHAR2
                             ,p_mode IN VARCHAR2 DEFAULT 'OLD')  IS

-- Get Formula Text for modification
cursor c_formula_id(cp_formula_name varchar2) IS
select ff.formula_id
  from ff_formulas_f ff
      ,ff_formula_types ft
 where ff.formula_name = cp_formula_name
   and ff.formula_type_id = ft.formula_type_id
   and ft.formula_type_name = 'Oracle Payroll'
   and ff.business_group_id IS NULL
   and ff.legislation_code = 'US';

l_formula_id        number;
l_formula_name      varchar2(100);
l_old_formula_text  varchar2(32700);
l_new_formula_text  varchar2(32700);

BEGIN
 hr_utility.trace('Entering ' || gv_package_name || '.modify_formula_text');
 hr_utility.trace('Passed Parameter p_ele_name := ' || p_ele_name);
 hr_utility.trace('Passed Parameter p_mode := ' || p_mode);

 -- Modification of Fast Formula Text of Regular_Salary

 IF p_ele_name = 'Regular Salary' THEN
      l_formula_name := 'REGULAR_SALARY';
      hr_utility.trace('Modifying Formula ' || l_formula_name);

      open c_formula_id(l_formula_name);
      fetch c_formula_id into l_formula_id ;
      close c_formula_id;

      hr_utility.trace('l_formula_id := ' || l_formula_id);

      l_old_formula_text := NULL;
      l_new_formula_text := NULL;

      l_new_formula_text := '
/* ***************************************************************
$Header: payusrsrwupg.pkb 120.0.12010000.5 2009/07/06 05:44:27 sudedas noship $
FORMULA NAME:   REGULAR_SALARY
FORMULA TYPE:   Payroll

Change History
29 Sep 1993     hparicha        Created.
14 Oct 1993     hparicha        Moved skip rule formulae to separate
                                file ".SKIP".
30 Nov 1993     hparicha        G187
06 Dec 1993     jmychale        G305. Renamed Convert_Figure to Convert_
                                Period_Type; reference TIME_ENTRY_WAGES
                                temporarily in search for timecards until
                                information hours element is defined
07 Jan 1994     jmychale        G491. Removed actual hours worked
                                parameter from
                                Calculate_Period_Earnings()
13 Jan 1994     hparicha        G497. Reverted calc period earnings
                                to us ACTUAL_HOURS_WORKED!  Used by
                                Statement of Earnings report. Replace
                                TIME_ENTR_WAGES_COUNT with
                                LABOR_RECORDING_COUNT for timecard
                                req''d employees.
24 Feb 1994	hparicha	G560. ASS -> ASG; TU -> GRE
24 Feb 1994	hparicha	G581. Handles negative earnings.
09 Jun 1994	hparicha	G907. New implementation of generated and
				startup earnings and deductions using
				"<ELE_NAME> Special Features" shadow element
				to feed balances and handle Addl/Repl Amounts.
04 Jan 1995	hparicha	Vacation/Sick correlation to Regular Pay.
				New results need to be passed when vac/sick
				pay are present.
04 May 1995	hparicha	Defaulted values for PAY_PROC_PERIOD_START/
                                END_DATE.  Default dates should be obvious
                                when default is used.
10 Jan 1996	hparicha	323639	Major cleanup effort involving
                                proration and other user defined functions
                                and formulae changes.
16 Apr 1996	ssdesai		Latest balances creation.
25 Apr 1996	hparicha	344018.  Replacing reference to
                                TIME_ENTRY_WAGES_COUNT with new dbi for
                                USER_ENTERED_TIME which looks for any time
                                entered for regular pay which should override
				Regular Salary and Regular Wages...ie. not
                                just the seeded Time Entry Wages element is
                                able to override Regular.
11 Jun 1996	hparicha	330341.  Ensures that the sum of salary in pay
                                periods adds up to monthly amount when pay
                                basis is monthly.  We may want to add checks
                                for other pay basis types - ie.
				annual pay basis, period pay basis.
3 SEP 1997	lwthomps	392177.  Check if weekly or biweekly payroll
                                before caping salary to monthly salary basis.
17 Mar 1997     djeng           465454, modified PAY_PROC_PERIOD_END_DATE
                                and PAY_PROC_PERIOD_END_DATE to
                                PAY_EARNED_START_DATE / PAY_EARNED_END_DATE
13 AUG 1997     Lwhtomps        BUG 525859. Payments dimension can not be held
                                as a latest balance.
21-JAN-1999     RAMURTHY        BUG 803578 - no monthly cap for semi-monthly
                                except for a penny difference.
24-Apr-2002     ekim            Changed Terminated Employee logic, added
                                PAYROLL_TERMINATION_TYPE and
                                BG_TERMINATION_TYPE
24-MAY-2005     asasthan        Added Reduce Regula logic
14-MAR-2006     asasthan        Modifed Reduce Regular to use ASG_GRE_RUN dbi
01-Mar-2007     kvsankar        Modified the formula to take care of
                                round off issues in Reduce Regular
26-Mar-2007     kvsankar        Modified the formula to use _ASG_GRE_RUN
                                dimension for Replacement and Additional
                                balances
25-Aug-2008     sudedas         Updated Formula Text to enable Core Proration
                                Functionality. Related Bugs 3556204, 5895804
                                And ER 3855241.
--
INPUTS:         Monthly_Salary
--
DBI Required:   ASG_SALARY_BASIS
                TERMINATED_EMPLOYEE
                FINAL_PAY_PROCESSED
                PAYROLL_TERMINATION_TYPE
                BG_TERMINATION_TYPE
                SCL_ASG_US_WORK_SCHEDULE
                ASG_HOURS
                SCL_ASG_US_TIMECARD_REQUIRED
                LABOR_RECORDING_COUNT
                PAY_PERIOD_TYPE
--
******************************************************************
DESCRIPTION:
******************************************************************
Computes earnings per pay period for salaried employees.
Proration function must be available to determine if employee worked entire
period - earnings will be adjusted accordingly by proration fn to account
for new hire, termination, leave of absence, etc.

*** Handling Salaried Earnings ***
Monthly earnings for salaried employees are processed every pay-period.
Salaried employees may or may not be required to submit a
timecard for days worked.  If timecard is not required,
then the normal hours worked used for calculating employee pay are
derived from the Work Schedule they are ASGigned to or by the Standard
Hours entered on the ASGignment.

The Monthly Salary input value will be boiled down to an hourly rate in
order to utilize the pro-ration capabilities of the system(Issue 1).
The formula will make use of the pro-ration function for handling
adjustment of employee pay in case of mid-period events such as
termination, leave of absence, change of salary, etc.  So an employee
is only paid for the days actually worked in a period with no
calculations or adjustments required by the user prior to or after
the payroll run (for a detailed discussion of Work Schedules and
Pro-Ration, see the Work Schedules - High Level Design).

When a timecard is submitted for an employee NOT REQUIRED to submit one,
then the "timecard" element entry (or entries) is treated as an override to
normal salary processing for the employee - IF the timecard entry has
a Rate or Rate Code entered(Issue 2).  When a timecard is required
for a salaried employee and one is not submitted by the payroll cutoff
date, then the employee'' s pay will not be processed - and will have to wait
for a subsequent run.

NOTE: On a timecard submitted for a Salaried-Timecard Required employee,
a Rate (or Rate Code and Table) can be entered - ELSE the Monthly Salary input
value will be converted to an hourly rate using Convert_Figure function.

If this is the Final Pay run for the employee'' s ASGignment, then the
Regular Salary element will be discontinued after this run.
******************************************************************
ALGORITHM:
******************************************************************

If timecard required and time entries NOT FOUND, then
  message= ''No timecards entered for Salaried, Timecard Required employee.''
  return message
  -- NOTE: If tc was req''d and time entries WERE found - then the skip rule
  --       for this Regular Salary element would have skipped this processing.
Endif

Convert monthly salary to an hourly rate;
Call proration function with hourly rate; --> Regular_Salaried_Earnings

If this is final pay for employee(ASGignment), then
  discontinue further processing of this element -- This is last time.
endif

Return REGULAR_SALARIED_EARNINGS
******************************************************************
--
The earnings calculation for salaried employees will primarily be
performed by the "calculate_period_earnings" function.  This function
has its'' own hld (in Work Schedules Functionality doc) and lld to be
called calc_period_earnings.lld
--
For a Salaried employee, if a timecard is entered (ie. a time entry
with "Hours" AND a "Rate" or "Rate Code - then this formula
will be skipped.
Note: there is an element used solely for the entry of hours worked
for SALARIED employees.
--
******************************************************************
FORMULA_TEXT: REGULAR SALARY
**************************************************************** */

/* Alias Section */
ALIAS SCL_ASG_US_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_US_TIMECARD_REQUIRED AS Timecard_Required

/* DBI Defaults */
DEFAULT FOR     ASG_SALARY_BASIS                IS ''NOT ENTERED''
/* 330341 FIX GOES HERE */
DEFAULT FOR     ASG_SALARY		IS 0
DEFAULT FOR     ASG_SALARY_BASIS_CODE  IS ''NOT ENTERED''
/* 330341 FIX END */
DEFAULT FOR     TERMINATED_EMPLOYEE             IS ''N''
DEFAULT FOR     FINAL_PAY_PROCESSED             IS ''N''
DEFAULT FOR     PAYROLL_TERMINATION_TYPE   IS ''L''
DEFAULT FOR     BG_TERMINATION_TYPE        IS ''L''
default for     LAST_STANDARD_PROCESS_DATE_PROCESSED IS ''N''

default for	PAY_PROC_PERIOD_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_PROC_PERIOD_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)
default for	PAY_EARNED_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_EARNED_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)

DEFAULT FOR     LABOR_RECORDING_COUNT       IS 0
DEFAULT FOR     Work_Schedule               IS ''NOT ENTERED''
DEFAULT FOR     ASG_HOURS                   IS 0
DEFAULT FOR	ASG_FREQ		    IS ''NOT ENTERED''  /* WWBug 323639 */
DEFAULT FOR     Timecard_Required           IS ''N''
DEFAULT FOR 	REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD	IS 0
DEFAULT FOR 	REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN	IS 0
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_RUN		IS 0
/* 330341
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_MONTH	IS 0
*/
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_YTD		IS 0
DEFAULT FOR	REGULAR_HOURS_WORKED_ASG_GRE_RUN	IS 0

DEFAULT FOR 	USER_ENTERED_TIME            IS ''N''
DEFAULT FOR 	PAY_PERIOD_TYPE              IS ''MONTH'' /*added for 392177*/

/* Input Value Defaults */
DEFAULT FOR     Monthly_Salary                  IS 0
DEFAULT FOR 	REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REDUCE_REGULAR_HOURS_ASG_GRE_RUN	IS 0
/* Added For Enabling Core Proration */
DEFAULT FOR     PRORATE_START IS ''1900/01/01 00:00:00'' (DATE)
DEFAULT FOR     PRORATE_END IS   ''1900/01/02 00:00:00'' (DATE)
DEFAULT FOR     PAY_PERIODS_PER_FISCAL_YEAR IS 1
DEFAULT FOR     MESG IS '' ''


INPUTS ARE      Monthly_Salary,
                prorate_start (date),
		    prorate_end (date)

/* Monthly salary must be converted to an hourly rate - using
        1) work schedule hours, or
        2) standard hours on ASGignment as hours per week
   In either case, Convert_Period_Type function will handle it.

At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups will be updated with Actual Termination
Date for the termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.

The skip rule is changed so that for the New payroll or
business group created since July FP/2002, seeded skip
rule will skip element processing using LSP date and
the existing payroll/business group, it will continue
to use Actual Termination date.
*/

MESG = '' ''

/* Why is this check not performed in skip formula? */
IF Timecard_Required = ''Y'' AND LABOR_RECORDING_COUNT = 0 THEN
 (MESG = ''No timecards entered for Salaried, Timecard Required employee''
  	soe_run = REGULAR_SALARY_ASG_GRE_RUN
	soe_ytd = REGULAR_SALARY_ASG_GRE_YTD
	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN
  RETURN MESG
  )

IF REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN WAS DEFAULTED OR
REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN = 0 THEN
 (

  actual_hours_worked = 0
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0

  IF ASG_SALARY_BASIS WAS DEFAULTED THEN
    MESG = ''Pay Basis MUST be entered for Regular Salary calculation.''

/* Start of Proration Logic */

           IF PRORATE_START was defaulted THEN
              PRORATE_START = PAY_PROC_PERIOD_START_DATE

           IF PRORATE_END was defaulted THEN
              PRORATE_END = PAY_PROC_PERIOD_END_DATE

/* Initializing Local variables */
t_schedule_source = '' ''
t_schedule = '' ''
t_return_status = -1
t_return_message = '' ''

hours_in_proration = 0
hours_in_period = 1
earnings_factor = 1
regular_salaried_earnings = 0

           hours_in_proration = HOURS_BETWEEN(PRORATE_START
	                                      , PRORATE_END
					              , ''WORK''
					              ,''N''
					              ,''BUSY''
					              ,''US''
					              ,t_schedule_source
					              ,t_schedule
					              ,t_return_status
					              ,t_return_message
					              ,''H'')

           hours_in_period = HOURS_BETWEEN( PAY_PROC_PERIOD_START_DATE
	                                    , PAY_PROC_PERIOD_END_DATE
					            , ''WORK''
					            ,''N''
					            ,''BUSY''
					            ,''US''
					            ,t_schedule_source
					            ,t_schedule
					            ,t_return_status
					            ,t_return_message
					            ,''H'')

           earnings_factor = hours_in_proration/hours_in_period
           regular_salaried_earnings = earnings_factor * ( ( Monthly_Salary * 12 ) / PAY_PERIODS_PER_FISCAL_YEAR )
           actual_hours_worked = hours_in_proration

/* End Proration Logic */
/* For Sick and Vacation Pay */

hourly_rate = 0
hourly_rate = get_hourly_rate()

t_sick_pay = calc_sick_pay(PAY_PROC_PERIOD_END_DATE
                          ,PRORATE_START
                          ,PRORATE_END
                          ,hourly_rate
                          ,t_sick_hours_taken)

t_vac_pay = calc_vac_pay(PAY_PROC_PERIOD_END_DATE
                        ,PRORATE_START
                        ,PRORATE_END
                        ,hourly_rate
                        ,t_vac_hours_taken)

/* 330341 FIX GOES HERE */
/* 392177 added the and PAY_PERIOD_TYPE ... portion of if below */

  IF (ASG_SALARY_BASIS_CODE = ''MONTHLY'' AND PAY_PERIOD_TYPE NOT LIKE ''%Week%'') THEN

/*IF REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings > ASG_SALARY  THEN */

  IF REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings - ASG_SALARY <= 0.01 AND (REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings) > ASG_SALARY THEN
  regular_salaried_earnings = ASG_SALARY - REGULAR_SALARY_ASG_GRE_MONTH

/* 392177 END */
/* 330341 END */

 )
ELSE
 (regular_salaried_earnings = REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN
  clear_repl_amt = -1 * REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN

  /*  WWBug 323639 */
  actual_hours_worked = 0
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0
 )

regular_salaried_earnings = regular_salaried_earnings
                            + REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN
			          + REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD

/* Reduce Regular Changes Start Here */

RED_REG_ADJUST_AMOUNT = 0.05
RED_REG_ADJUST_HOURS  = 0.01


t_reduce_regular_earnings = REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN
t_reduce_regular_hours = REDUCE_REGULAR_HOURS_ASG_GRE_RUN

t_return = REDUCED_REGULAR_CALC(PAY_PROC_PERIOD_END_DATE
                               ,PRORATE_START
                               ,PRORATE_END
                               ,t_reduce_regular_earnings
			             ,t_reduce_regular_hours)

reduce_regular_earnings = t_reduce_regular_earnings
reduce_regular_hours = t_reduce_regular_hours

diff_earnings = regular_salaried_earnings - reduce_regular_earnings + RED_REG_ADJUST_AMOUNT
diff_hours = actual_hours_worked - reduce_regular_hours + RED_REG_ADJUST_HOURS

/* Reduce Regular Changes Start Here */

IF Timecard_Required = ''N'' AND
   reduce_regular_earnings <> 0 THEN
(
   /*
    * We need to carry over reduce regular Earnings/Hours to the next Pay
    * Period if it is more than regular salaried earnings so that we
    * never have regular salaried earnings less than ZERO
    */
   IF diff_earnings >= 0 THEN
   (
      regular_salaried_earnings = regular_salaried_earnings - reduce_regular_earnings
      if regular_salaried_earnings < 0 then
      (
         regular_salaried_earnings = 0
      )
   )
   ELSE
   (
      /* reduce_regular_earnings = regular_salaried_earnings */
      regular_salaried_earnings = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )

   IF diff_hours >= 0 THEN
   (
      actual_hours_worked = actual_hours_worked - reduce_regular_hours
      if actual_hours_worked < 0 then
      (
         actual_hours_worked  = 0
      )
   )
   ELSE
   (
      /* reduce_regular_hours = actual_hours_worked */
      actual_hours_worked = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )
)
ELSE
(
   reduce_regular_earnings = 0
   reduce_regular_hours = 0
)

/* Reduce Regular Changes End Here */

/*
At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups (prior to July Family Pack 2002)
will be updated with Actual Termination Date for the
termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.
*/

IF regular_salaried_earnings < 0 THEN
 (IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND BG_TERMINATION_TYPE = ''A'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''A'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND BG_TERMINATION_TYPE = ''L'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'')
     OR
     (PAYROLL_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'') THEN
    neg_earn = 0
  ELSE
   (neg_earn = regular_salaried_earnings - REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD
    regular_salaried_earnings = 0
   )
 )
ELSE
 (IF REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD <> 0 THEN
    neg_earn = -1 * REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD
 )

IF REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN <> 0 THEN
  clear_addl_amt = -1 * REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN

IF t_vac_pay <> 0 THEN
  (vac_pay = t_vac_pay
   vac_hours_taken = t_vac_hours_taken
   regular_salaried_earnings = regular_salaried_earnings - vac_pay
   actual_hours_worked = actual_hours_worked - vac_hours_taken
  )

IF t_sick_pay <> 0 THEN
  (sick_pay = t_sick_pay
   sick_hours_taken = t_sick_hours_taken
   regular_salaried_earnings = regular_salaried_earnings - sick_pay
   actual_hours_worked = actual_hours_worked - sick_hours_taken
  )

/* Create latest balances */
/* There is no RUN level leatest balances
   and REGULAR_SALARY_ASG_GRE_YTD is added to to latest balance script.
	soe_run = REGULAR_SALARY_ASG_GRE_RUN
	soe_ytd = REGULAR_SALARY_ASG_GRE_YTD
	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN
*/

IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
    BG_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'' ) OR
   (PAYROLL_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') THEN
      (STOP_ENTRY = ''Y''
       mesg = ''Regular Salary being stopped after Final Pay.''
       RETURN regular_salaried_earnings, actual_hours_worked,
              clear_repl_amt, clear_addl_amt, neg_earn, vac_pay,
              vac_hours_taken, sick_pay, sick_hours_taken,
              STOP_ENTRY, mesg, reduce_regular_earnings,
              reduce_regular_hours
      )
ELSE
    RETURN regular_salaried_earnings, actual_hours_worked,
           clear_repl_amt, clear_addl_amt, neg_earn,
           vac_pay, vac_hours_taken, sick_pay, sick_hours_taken,
           reduce_regular_earnings, reduce_regular_hours, mesg
';

      l_old_formula_text := '
/* ***************************************************************
$Header: payusrsrwupg.pkb 120.0.12010000.5 2009/07/06 05:44:27 sudedas noship $
FORMULA NAME:   REGULAR_SALARY
FORMULA TYPE:   Payroll

Change History
29 Sep 1993     hparicha        Created.
14 Oct 1993     hparicha        Moved skip rule formulae to separate
                                file ".SKIP".
30 Nov 1993     hparicha        G187
06 Dec 1993     jmychale        G305. Renamed Convert_Figure to Convert_
                                Period_Type; reference TIME_ENTRY_WAGES
                                temporarily in search for timecards until
                                information hours element is defined
07 Jan 1994     jmychale        G491. Removed actual hours worked
                                parameter from
                                Calculate_Period_Earnings()
13 Jan 1994     hparicha        G497. Reverted calc period earnings
                                to us ACTUAL_HOURS_WORKED!  Used by
                                Statement of Earnings report. Replace
                                TIME_ENTR_WAGES_COUNT with
                                LABOR_RECORDING_COUNT for timecard
                                req''d employees.
24 Feb 1994	hparicha	G560. ASS -> ASG; TU -> GRE
24 Feb 1994	hparicha	G581. Handles negative earnings.
09 Jun 1994	hparicha	G907. New implementation of generated and
				startup earnings and deductions using
				"<ELE_NAME> Special Features" shadow element
				to feed balances and handle Addl/Repl Amounts.
04 Jan 1995	hparicha	Vacation/Sick correlation to Regular Pay.
				New results need to be passed when vac/sick
				pay are present.
04 May 1995	hparicha	Defaulted values for PAY_PROC_PERIOD_START/
                                END_DATE.  Default dates should be obvious
                                when default is used.
10 Jan 1996	hparicha	323639	Major cleanup effort involving
                                proration and other user defined functions
                                and formulae changes.
16 Apr 1996	ssdesai		Latest balances creation.
25 Apr 1996	hparicha	344018.  Replacing reference to
                                TIME_ENTRY_WAGES_COUNT with new dbi for
                                USER_ENTERED_TIME which looks for any time
                                entered for regular pay which should override
				Regular Salary and Regular Wages...ie. not
                                just the seeded Time Entry Wages element is
                                able to override Regular.
11 Jun 1996	hparicha	330341.  Ensures that the sum of salary in pay
                                periods adds up to monthly amount when pay
                                basis is monthly.  We may want to add checks
                                for other pay basis types - ie.
				annual pay basis, period pay basis.
3 SEP 1997	lwthomps	392177.  Check if weekly or biweekly payroll
                                before caping salary to monthly salary basis.
17 Mar 1997     djeng           465454, modified PAY_PROC_PERIOD_END_DATE
                                and PAY_PROC_PERIOD_END_DATE to
                                PAY_EARNED_START_DATE / PAY_EARNED_END_DATE
13 AUG 1997     Lwhtomps        BUG 525859. Payments dimension can not be held
                                as a latest balance.
21-JAN-1999     RAMURTHY        BUG 803578 - no monthly cap for semi-monthly
                                except for a penny difference.
24-Apr-2002     ekim            Changed Terminated Employee logic, added
                                PAYROLL_TERMINATION_TYPE and
                                BG_TERMINATION_TYPE
24-MAY-2005     asasthan        Added Reduce Regula logic
14-MAR-2006     asasthan        Modifed Reduce Regular to use ASG_GRE_RUN dbi
01-Mar-2007     kvsankar        Modified the formula to take care of
                                round off issues in Reduce Regular
26-Mar-2007     kvsankar        Modified the formula to use _ASG_GRE_RUN
                                dimension for Replacement and Additional
                                balances
--
INPUTS:         Monthly_Salary
--
DBI Required:   ASG_SALARY_BASIS
                TERMINATED_EMPLOYEE
                FINAL_PAY_PROCESSED
                PAYROLL_TERMINATION_TYPE
                BG_TERMINATION_TYPE
                SCL_ASG_US_WORK_SCHEDULE
                ASG_HOURS
                SCL_ASG_US_TIMECARD_REQUIRED
                LABOR_RECORDING_COUNT
                PAY_PERIOD_TYPE
--
******************************************************************
DESCRIPTION:
******************************************************************
Computes earnings per pay period for salaried employees.
Proration function must be available to determine if employee worked entire
period - earnings will be adjusted accordingly by proration fn to account
for new hire, termination, leave of absence, etc.

*** Handling Salaried Earnings ***
Monthly earnings for salaried employees are processed every pay-period.
Salaried employees may or may not be required to submit a
timecard for days worked.  If timecard is not required,
then the normal hours worked used for calculating employee pay are
derived from the Work Schedule they are ASGigned to or by the Standard
Hours entered on the ASGignment.

The Monthly Salary input value will be boiled down to an hourly rate in
order to utilize the pro-ration capabilities of the system(Issue 1).
The formula will make use of the pro-ration function for handling
adjustment of employee pay in case of mid-period events such as
termination, leave of absence, change of salary, etc.  So an employee
is only paid for the days actually worked in a period with no
calculations or adjustments required by the user prior to or after
the payroll run (for a detailed discussion of Work Schedules and
Pro-Ration, see the Work Schedules - High Level Design).

When a timecard is submitted for an employee NOT REQUIRED to submit one,
then the "timecard" element entry (or entries) is treated as an override to
normal salary processing for the employee - IF the timecard entry has
a Rate or Rate Code entered(Issue 2).  When a timecard is required
for a salaried employee and one is not submitted by the payroll cutoff
date, then the employee''s pay will not be processed - and will have to wait
for a subsequent run.

NOTE: On a timecard submitted for a Salaried-Timecard Required employee,
a Rate (or Rate Code and Table) can be entered - ELSE the Monthly Salary input
value will be converted to an hourly rate using Convert_Figure function.

If this is the Final Pay run for the employee''s ASGignment, then the
Regular Salary element will be discontinued after this run.
******************************************************************
ALGORITHM:
******************************************************************

If timecard required and time entries NOT FOUND, then
  message=''No timecards entered for Salaried, Timecard Required employee.''
  return message
  -- NOTE: If tc was req''d and time entries WERE found - then the skip rule
  --       for this Regular Salary element would have skipped this processing.
Endif

Convert monthly salary to an hourly rate;
Call proration function with hourly rate; --> Regular_Salaried_Earnings

If this is final pay for employee(ASGignment), then
  discontinue further processing of this element -- This is last time.
endif

Return REGULAR_SALARIED_EARNINGS
******************************************************************
--
The earnings calculation for salaried employees will primarily be
performed by the "calculate_period_earnings" function.  This function
has its'' own hld (in Work Schedules Functionality doc) and lld to be
called calc_period_earnings.lld
--
For a Salaried employee, if a timecard is entered (ie. a time entry
with "Hours" AND a "Rate" or "Rate Code - then this formula
will be skipped.
Note: there is an element used solely for the entry of hours worked
for SALARIED employees.
--
******************************************************************
FORMULA_TEXT: REGULAR SALARY
**************************************************************** */

/* Alias Section */
ALIAS SCL_ASG_US_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_US_TIMECARD_REQUIRED AS Timecard_Required

/* DBI Defaults */
DEFAULT FOR     ASG_SALARY_BASIS                IS ''NOT ENTERED''
/* 330341 FIX GOES HERE */
DEFAULT FOR     ASG_SALARY		IS 0
DEFAULT FOR     ASG_SALARY_BASIS_CODE  IS ''NOT ENTERED''
/* 330341 FIX END */
DEFAULT FOR     TERMINATED_EMPLOYEE             IS ''N''
DEFAULT FOR     FINAL_PAY_PROCESSED             IS ''N''
DEFAULT FOR     PAYROLL_TERMINATION_TYPE   IS ''L''
DEFAULT FOR     BG_TERMINATION_TYPE        IS ''L''
default for     LAST_STANDARD_PROCESS_DATE_PROCESSED IS ''N''

default for	PAY_PROC_PERIOD_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_PROC_PERIOD_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)
default for	PAY_EARNED_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_EARNED_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)

DEFAULT FOR     LABOR_RECORDING_COUNT       IS 0
DEFAULT FOR     Work_Schedule               IS ''NOT ENTERED''
DEFAULT FOR     ASG_HOURS                   IS 0
DEFAULT FOR	ASG_FREQ		    IS ''NOT ENTERED''  /* WWBug 323639 */
DEFAULT FOR     Timecard_Required               IS ''N''
DEFAULT FOR 	REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD	IS 0
DEFAULT FOR 	REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN	IS 0
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_RUN		IS 0
/* 330341
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_MONTH	IS 0
*/
DEFAULT FOR	REGULAR_SALARY_ASG_GRE_YTD		IS 0
DEFAULT FOR	REGULAR_HOURS_WORKED_ASG_GRE_RUN	IS 0

DEFAULT FOR 	USER_ENTERED_TIME            IS ''N''
DEFAULT FOR 	PAY_PERIOD_TYPE              IS ''MONTH'' /*added for 392177*/

/* Input Value Defaults */
DEFAULT FOR     Monthly_Salary                  IS 0
DEFAULT FOR 	REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REDUCE_REGULAR_HOURS_ASG_GRE_RUN	IS 0

INPUTS ARE      Monthly_Salary

/* Monthly salary must be converted to an hourly rate - using
        1) work schedule hours, or
        2) standard hours on ASGignment as hours per week
   In either case, Convert_Period_Type function will handle it.


At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups will be updated with Actual Termination
Date for the termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.

The skip rule is changed so that for the New payroll or
business group created since July FP/2002, seeded skip
rule will skip element processing using LSP date and
the existing payroll/business group, it will continue
to use Actual Termination date.
*/

/* Changed for new Termination Rule
   There will be no stop entry using USER_ENTERED_TIME
   as of July FP/2002
MESG = '' ''

IF TERMINATED_EMPLOYEE = ''Y'' AND USER_ENTERED_TIME = ''Y'' THEN
 (STOP_ENTRY = ''Y''
  mesg = ''Regular Salary being stopped after Final Pay.''
  	soe_run = REGULAR_SALARY_ASG_GRE_RUN
	soe_ytd = REGULAR_SALARY_ASG_GRE_YTD

	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN

  RETURN STOP_ENTRY, mesg
  )
*/
/* Why is this check not performed in skip formula? */
IF Timecard_Required = ''Y'' AND LABOR_RECORDING_COUNT = 0 THEN
 (mesg = ''No timecards entered for Salaried, Timecard Required employee''
  	soe_run = REGULAR_SALARY_ASG_GRE_RUN
	soe_ytd = REGULAR_SALARY_ASG_GRE_YTD

	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN

  RETURN mesg
  )

IF REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN WAS DEFAULTED OR
REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN = 0 THEN
 (hourly_rate = get_hourly_rate()
                /*Convert_Period_Type(  Work_Schedule,
                                    ASG_HOURS,
                                    Monthly_Salary,
                                    ASG_SALARY_BASIS,
                                    ''HOURLY'',
		       PAY_EARNED_START_DATE,
		       PAY_EARNED_END_DATE,
		       ASG_FREQ)*/
/*  WWBug 323639 */

  actual_hours_worked = 0
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0

  IF ASG_SALARY_BASIS WAS DEFAULTED THEN
    mesg = ''Pay Basis MUST be entered for Regular Salary calculation.''

  regular_salaried_earnings =   Calc_Period_Earnings (
                                       ASG_SALARY_BASIS,
                                        ''MONTHLY SALARY'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        actual_hours_worked,
		                        t_vac_hours_taken,
		                        t_vac_pay,
		                        t_sick_hours_taken,
                		        t_sick_pay,
                                        ''Y'',
                                       ASG_FREQ)

                               /*Calculate_Period_Earnings(
                                        ASG_SALARY_BASIS,
                                        ''MONTHLY SALARY'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        Work_Schedule,
                                        ASG_HOURS,
                                        actual_hours_worked,
                 			t_vac_hours_taken,
		                	t_vac_pay,
                  			t_sick_hours_taken,
		                	t_sick_pay,
                                        ''Y'',
                			ASG_FREQ) */
/*  WWBug 323639 */

/* 330341 FIX GOES HERE */
/* 392177 added the and PAY_PERIOD_TYPE ... portion of if below */
  IF (ASG_SALARY_BASIS_CODE = ''MONTHLY'' AND PAY_PERIOD_TYPE NOT LIKE ''%Week%'') THEN

/*IF REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings > ASG_SALARY  THEN */
    IF REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings - ASG_SALARY <= 0.01 AND (REGULAR_SALARY_ASG_GRE_MONTH + regular_salaried_earnings) > ASG_SALARY THEN

      regular_salaried_earnings = ASG_SALARY - REGULAR_SALARY_ASG_GRE_MONTH

/* 392177 END */
/* 330341 END */


 )
ELSE
 (regular_salaried_earnings = REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN
  clear_repl_amt = -1 * REGULAR_SALARY_REPLACEMENT_ASG_GRE_RUN

  /*  WWBug 323639 */
  actual_hours_worked = 0
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0
 )

regular_salaried_earnings = regular_salaried_earnings
                            + REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN
			    + REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD

/* Reduce Regular Changes Start Here */

RED_REG_ADJUST_AMOUNT = 0.05
RED_REG_ADJUST_HOURS  = 0.01

reduce_regular_earnings = -1 * REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN
reduce_regular_hours = -1 * REDUCE_REGULAR_HOURS_ASG_GRE_RUN
diff_earnings = regular_salaried_earnings - reduce_regular_earnings
                + RED_REG_ADJUST_AMOUNT
diff_hours = actual_hours_worked - reduce_regular_hours
             + RED_REG_ADJUST_HOURS

/* Reduce Regular Changes Start Here */

IF Timecard_Required = ''N'' AND
   reduce_regular_earnings <> 0 THEN
(
   /*
    * We need to carry over reduce regular Earnings/Hours to the next Pay
    * Period if it is more than regular salaried earnings so that we
    * never have regular salaried earnings less than ZERO
    */
   IF diff_earnings >= 0 THEN
   (
      regular_salaried_earnings = regular_salaried_earnings - reduce_regular_earnings
      if regular_salaried_earnings < 0 then
      (
         regular_salaried_earnings = 0
      )
   )
   ELSE
   (
      /* reduce_regular_earnings = regular_salaried_earnings */
      regular_salaried_earnings = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )

   IF diff_hours >= 0 THEN
   (
      actual_hours_worked = actual_hours_worked - reduce_regular_hours
      if actual_hours_worked < 0 then
      (
         actual_hours_worked  = 0
      )
   )
   ELSE
   (
      /* reduce_regular_hours = actual_hours_worked */
      actual_hours_worked = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )
)
ELSE
(
   reduce_regular_earnings = 0
   reduce_regular_hours = 0
)

/* Reduce Regular Changes End Here */

/*
At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups (prior to July Family Pack 2002)
will be updated with Actual Termination Date for the
termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.
*/

IF regular_salaried_earnings < 0 THEN
 (IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND BG_TERMINATION_TYPE = ''A'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''A'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND BG_TERMINATION_TYPE = ''L'' AND
     TERMINATED_EMPLOYEE = ''Y'' AND LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'')
     OR
     (PAYROLL_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'')
      THEN
    neg_earn = 0
  ELSE
   (neg_earn = regular_salaried_earnings
               - REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD
    regular_salaried_earnings = 0
   )
 )
ELSE
 (IF REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD <> 0 THEN
    neg_earn = -1 * REGULAR_SALARY_NEG_EARNINGS_ASG_GRE_ITD
 )

IF REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN <> 0 THEN
  clear_addl_amt = -1 * REGULAR_SALARY_ADDITIONAL_ASG_GRE_RUN

IF t_vac_pay <> 0 THEN
  (vac_pay = t_vac_pay
   vac_hours_taken = t_vac_hours_taken
   regular_salaried_earnings = regular_salaried_earnings - vac_pay
   actual_hours_worked = actual_hours_worked - vac_hours_taken
  )

IF t_sick_pay <> 0 THEN
  (sick_pay = t_sick_pay
   sick_hours_taken = t_sick_hours_taken
   regular_salaried_earnings = regular_salaried_earnings - sick_pay
   actual_hours_worked = actual_hours_worked - sick_hours_taken
  )

/* Create latest balances */
/* There is no RUN level leatest balances
   and REGULAR_SALARY_ASG_GRE_YTD is added to to latest balance script.
	soe_run = REGULAR_SALARY_ASG_GRE_RUN
	soe_ytd = REGULAR_SALARY_ASG_GRE_YTD
	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN
*/
IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
    BG_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'' ) OR
   (PAYROLL_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') THEN
      (STOP_ENTRY = ''Y''
       mesg = ''Regular Salary being stopped after Final Pay.''
       RETURN regular_salaried_earnings, actual_hours_worked,
              clear_repl_amt, clear_addl_amt, neg_earn, vac_pay,
              vac_hours_taken, sick_pay, sick_hours_taken,
              STOP_ENTRY, mesg, reduce_regular_earnings,
              reduce_regular_hours
      )
ELSE
    RETURN regular_salaried_earnings, actual_hours_worked,
           clear_repl_amt, clear_addl_amt, neg_earn,
           vac_pay, vac_hours_taken, sick_pay, sick_hours_taken,
           reduce_regular_earnings, reduce_regular_hours, mesg
';

   -- Modification of Fast Formula Text of Regular_Wages

 ELSIF p_ele_name = 'Regular Wages' THEN
      l_formula_name := 'REGULAR_WAGES';

      hr_utility.trace('Modifying Formula ' || l_formula_name);

      open c_formula_id(l_formula_name);
      fetch c_formula_id into l_formula_id ;
      close c_formula_id;

      hr_utility.trace('l_formula_id := ' || l_formula_id);

      l_old_formula_text := NULL;
      l_new_formula_text := NULL;

      l_new_formula_text :=
   '/* ***************************************************************
$Header: payusrsrwupg.pkb 120.0.12010000.5 2009/07/06 05:44:27 sudedas noship $
FORMULA NAME:   REGULAR_WAGES
FORMULA TYPE:   Payroll
Change History
29 Sep 1993     hparicha        Created.
14 Oct 1993     hparicha        Moved skip rule formulae to separate
                                file ".SKIP".
30 Nov 1993     hparicha        G187
06 Dec 1993     jmychale        G305. Added aliases, entered database items
                                and tidied up formula
07 Jan 1994     jmychale        G491. Removed actual hours worked

                                parameter from Calculate_Period_
                                Earnings ()
13 Jan 1994     hparicha        G497. Reverted calc period earnings to
                                use ACTUAL_HOURS_WORKED!  Used by
                                Statement of Earnings report. Replaced
                                TIME_ENTRY_WAGES_COUNT with
                                LABOR_RECORDING_COUNT for timecard
                                req''d employees.
24 Feb 1994	hparicha	G560. ASS -> ASG; TU -> GRE
24 Feb 1994	hparicha	G581. Handles negative earnings.
09 Jun 1994	hparicha	G907. New implementation of generated and
				startup earnings and deductions using
				"<ELE_NAME> Special Features" shadow element
				to feed balances and handle Addl/Repl Amounts.
04 Jan 1995	hparicha	Vacation/Sick correlation to Regular Pay.
				New results need to be passed when vac/sick
				pay are present.
04 May 1995	hparicha	Defaulted values for PAY_PROC_PERIOD_
				START/END_DATE.  Default dates should
				be obvious when default is used.
10 Jan 1996	hparicha	323639	Major cleanup effort involving
                                proration and other user
				defined functions and formulae changes.
16 Apr 1996	ssdesai		Latest balances creation.
25 Apr 1996	hparicha	344018	Added check for USER_ENTERED_TIME.
17 Apr 1996     djeng           Changed PAY_PROC_PERIOD_START_DATE, and
                                PAY_PROC_PERIOD_END_DATE to
				PAY_EARNED_START_DATE and PAY_EARNED_END_DATE
13 AUG 1997     Lwhtomps        BUG 525859. Payments dimension can not be held
                                as a latest balance.
21 MAY 2001     ssarma          3 formula result rules added for Hours by rate
                                calculation. bug#1550323. They are:
                                ELEMENT_TYPE_ID_PASSED
                                RATE_PASSED
                                HOURS_PASSED
24 AUG 2001     pganguly        Changed the default for USER_ENTERED_TIME
                                from Y to N
24-AUG-2002     ekim            Changed the logic of Terminated employee.
24-MAY-2005     kvsankar        Cheanged the formula to use New Balance
                                ''Reduce Regular Earnings'' and ''Reduce Regular
                                Hours'' for Reduce Regular functionality
14-MAR-2006     asasthan        Modifed Reduce Regular to use ASG_GRE_RUN dbi
01-Mar-2007     kvsankar        Modified the formula to take care of
                                round off issues in Reduce Regular
26-Mar-2007     kvsankar        Modified the formula to use _ASG_GRE_RUN
                                dimension for Replacement and Additional
                                balances
25-Aug-2008     sudedas         Updated Formula Text to enable Core Proration
                                Functionality. Related Bugs 3556204, 5895804
                                And ER 3855241.
--
--
INPUTS:         Rate
                Rate Code (text)
--
DBI Required:   ASG_SALARY_BASIS
                TERMINATED_EMPLOYEE
                FINAL_PAY_PROCESSED
                PAYROLL_TERMINATION_TYPE
                BG_TERMINATION_TYPE

                LABOR_RECORDING_COUNT
                SCL_ASG_US_WORK_SCHEDULE
                ASG_HOURS
                SCL_ASG_US_TIMECARD_REQUIRED

                CURRENT_ELEMENT_TYPE_ID
******************************************************************
DESCRIPTION:
******************************************************************
Computes earnings per pay period for hourly employees.
Proration function must be available to determine if employee worked entire
period - earnings will be adjusted accordingly by proration fn to account
for new hire, termination, leave of absence, etc.
*** Hourly handling ***
Regular wages earned per pay period for employees paid by the hour.

Hourly employees can either be "Hourly-Automatic" (ie. timecard not
required) or "Hourly-Timecard" where a timecard is required for pay.  The
hourly rate for an employee is entered as the input value for this element.
This rate is used with the number of hours worked to calculate earnings.
Hours worked will be indicated by one of the following:
     - time entry or entries (ie. timecard)
     - ASGigned Work Schedule
     - standard hours entered at the Organization and ASGignment levels.
For an Hourly-Timecard or "timecard required" employee, when a timecard
is not submitted by the payroll input cutoff date - the wages for that
employee will not be calculated and will have to wait for a subsequent
payroll run for processing.  When a timecard is submitted for an Hourly-
Automatic employee, then the time entry (or entries) is treated as the source
for Hours - if a rate is entered on the time entry, then this rate is used
along with the hours to compute pay, otherwise the normal rate (Regular
Wages rate) is used for computation.
If this is the Final Pay run for the employee''s ASGignment, then the
Regular Wages element will be discontinued after this run.
******************************************************************
ALGORITHM:
******************************************************************
If timecard required and time entries NOT FOUND, then
  message=''No timecards entered for Hourly, Timecard Required employee.''
  return message
  -- NOTE: If tc was req''d and time entries WERE found - then the skip rule
  --       for this Regular Salary element would have skipped this processing.


Endif
Call proration function with hourly rate; --> Regular_Wage_Earnings
If this is final pay for employee(ASGignment), then
  discontinue further processing of this element -- This is last time.
endif
Return Regular_Wage_Earnings
-- The earnings calculation for hourly employees will primarily be
calculated by the calculate_period_earnings() function.  This function
has its'' own hld (in Work Schedules Functionality doc) and lld to be
called calc_period_earnings.lld
******************************************************************
FORMULA_TEXT:

*******************************************************************/
/* Alias Section */
ALIAS SCL_ASG_US_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_US_TIMECARD_REQUIRED AS Timecard_Required
/* dbi defaults */
DEFAULT FOR     ASG_SALARY_BASIS                IS ''NOT ENTERED''
DEFAULT FOR     TERMINATED_EMPLOYEE             IS ''N''
DEFAULT FOR     FINAL_PAY_PROCESSED             IS ''N''
DEFAULT FOR     PAYROLL_TERMINATION_TYPE     IS ''L''
DEFAULT FOR     BG_TERMINATION_TYPE          IS ''L''
default for     LAST_STANDARD_PROCESS_DATE_PROCESSED IS ''N''
DEFAULT FOR     LABOR_RECORDING_COUNT           IS 0
DEFAULT FOR     USER_ENTERED_TIME               IS ''N''

default for	PAY_PROC_PERIOD_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_PROC_PERIOD_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)
default for	PAY_EARNED_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_EARNED_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)

DEFAULT FOR     Work_Schedule                   IS ''NOT ENTERED''
DEFAULT FOR     ASG_HOURS                       IS 0
DEFAULT FOR     ASG_FREQ		IS ''NOT ENTERED''  /* WWBug 323639 */
DEFAULT FOR     Timecard_Required               IS ''N''
DEFAULT FOR 	REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD	IS 0
DEFAULT FOR 	REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN	IS 0
DEFAULT FOR	REGULAR_WAGES_ASG_GRE_RUN		IS 0
DEFAULT FOR	REGULAR_HOURS_WORKED_ASG_GRE_RUN	IS 0
DEFAULT FOR     CURRENT_ELEMENT_TYPE_ID                 IS 0
DEFAULT FOR     REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN   IS  0
DEFAULT FOR     REDUCE_REGULAR_HOURS_ASG_GRE_RUN  IS  0

/* inpval defaults */
DEFAULT FOR     Rate                            IS 0
DEFAULT FOR     Rate_Code (text)                IS ''NOT ENTERED''

/* Added For Enabling Core Proration */
DEFAULT FOR     PRORATE_START IS ''1900/01/01 00:00:00'' (DATE)
DEFAULT FOR     PRORATE_END IS   ''1900/01/02 00:00:00'' (DATE)
DEFAULT FOR     PAY_PERIODS_PER_FISCAL_YEAR IS 1

INPUTS ARE      Rate,
                Rate_Code (text),
                prorate_start (date),
		    prorate_end (date)

/* Updatable Values */
RATE_TABLE              =  ''WAGE RATES''
RATE_TABLE_COLUMN       =  ''Wage Rate''

MESG = '' ''
/* Changed for new Termination Rule
IF TERMINATED_EMPLOYEE = ''Y'' AND USER_ENTERED_TIME = ''Y'' THEN
 (STOP_ENTRY = ''Y''
  mesg = ''Regular Wages being stopped after Final Pay.''
  RETURN STOP_ENTRY, mesg
  )
*/
IF Timecard_Required = ''Y'' AND LABOR_RECORDING_COUNT = 0 THEN
 (mesg = ''No timecards entered for Hourly, Timecard Required employee''
  RETURN mesg

  )

ELEMENT_TYPE_ID_PASSED = CURRENT_ELEMENT_TYPE_ID
RATE_PASSED = 0
HOURS_PASSED = 0

/* Start of Proration Logic */

IF PRORATE_START was defaulted THEN
   PRORATE_START = PAY_PROC_PERIOD_START_DATE

IF PRORATE_END was defaulted THEN
   PRORATE_END = PAY_PROC_PERIOD_END_DATE

/* Initializing Local variables */

t_schedule_source = '' ''
t_schedule = '' ''
t_return_status = -1
t_return_message = '' ''

hours_in_proration = 0
hours_in_period = 1
earnings_factor = 1
regular_salaried_earnings = 0
actual_hours_worked = 0

hours_in_proration = HOURS_BETWEEN(PRORATE_START
                                 , PRORATE_END
                                 , ''WORK''
                                 ,''N''
                                 ,''BUSY''
                                 ,''US''
                                 ,t_schedule_source
                                 ,t_schedule
                                 ,t_return_status
                                 ,t_return_message
                                 ,''H'')

hours_in_period = HOURS_BETWEEN(   PAY_PROC_PERIOD_START_DATE
	                          , PAY_PROC_PERIOD_END_DATE
				        , ''WORK''
				        ,''N''
				        ,''BUSY''
				        ,''US''
				        ,t_schedule_source
				        ,t_schedule
				        ,t_return_status
				        ,t_return_message
				        ,''H'')

earnings_factor = hours_in_proration/hours_in_period
actual_hours_worked = hours_in_proration

IF REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN WAS DEFAULTED OR
   REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN = 0 THEN
  IF Rate WAS NOT DEFAULTED THEN
   (hourly_rate = Rate
    t_vac_hours_taken = 0
    t_vac_pay = 0
    t_sick_hours_taken = 0
    t_sick_pay = 0

    regular_wage_earnings = earnings_factor * ( Rate * hours_in_period )
    RATE_PASSED = hourly_rate
   )

  ELSE
    IF Rate_Code WAS NOT DEFAULTED THEN
     (hourly_rate = To_Number(Get_Table_Value( RATE_TABLE,
                                             RATE_TABLE_COLUMN,
                                             Rate_Code))
      t_vac_hours_taken = 0
      t_vac_pay = 0
      t_sick_hours_taken = 0
      t_sick_pay = 0
      RATE_PASSED = hourly_rate

    regular_wage_earnings = earnings_factor * ( hourly_rate * hours_in_period )
     )

    ELSE
     (mesg = ''No Hourly Rate or Rate Code entered for this employee''
      RETURN mesg
     )
ELSE
 (regular_wage_earnings = REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN
  clear_repl_amt = -1 * REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN
  /*  WWBug 323639 */
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0
 )
regular_wage_earnings = regular_wage_earnings
                        + REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN
                        + REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD
/*
At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups (prior to July Family Pack 2002)
will be updated with Actual Termination Date for the
termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.
*/

t_sick_pay = calc_sick_pay(PAY_PROC_PERIOD_END_DATE
                          ,PRORATE_START
                          ,PRORATE_END
                          ,hourly_rate
                          ,t_sick_hours_taken)

t_vac_pay = calc_vac_pay(PAY_PROC_PERIOD_END_DATE
                        ,PRORATE_START
                        ,PRORATE_END
                        ,hourly_rate
                        ,t_vac_hours_taken)

RED_REG_ADJUST_AMOUNT = 0.05
RED_REG_ADJUST_HOURS  = 0.01

/* Replacing with below code for Enabling Proration */
/*
reduce_regular_earnings = -1 * REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN
reduce_regular_hours = -1 * REDUCE_REGULAR_HOURS_ASG_GRE_RUN
diff_earnings = regular_wage_earnings - reduce_regular_earnings
                + RED_REG_ADJUST_AMOUNT
diff_hours = actual_hours_worked - reduce_regular_hours
             + RED_REG_ADJUST_HOURS
*/

t_reduce_regular_earnings = REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN
t_reduce_regular_hours = REDUCE_REGULAR_HOURS_ASG_GRE_RUN

t_return = REDUCED_REGULAR_CALC(PAY_PROC_PERIOD_END_DATE
                               ,PRORATE_START
                               ,PRORATE_END
                               ,t_reduce_regular_earnings
			             ,t_reduce_regular_hours)

reduce_regular_earnings = t_reduce_regular_earnings
reduce_regular_hours = t_reduce_regular_hours

diff_earnings = regular_wage_earnings - reduce_regular_earnings
                + RED_REG_ADJUST_AMOUNT

diff_hours = actual_hours_worked - reduce_regular_hours
             + RED_REG_ADJUST_HOURS

/* Reduce Regular Changes Start Here */

IF Timecard_Required = ''N'' AND
   reduce_regular_earnings <> 0 THEN
(
   /*
    * We need to carry over reduce regular Earnings/Hours to the next Pay
    * Period if it is more than regular salaried earnings so that we
    * never have regular salaried earnings less than ZERO
    */
   IF diff_earnings >= 0 THEN
   (
      regular_wage_earnings = regular_wage_earnings - reduce_regular_earnings
      if regular_wage_earnings < 0 then
      (
         regular_wage_earnings = 0
      )
   )
   ELSE
   (
     /* reduce_regular_earnings = regular_wage_earnings */
      regular_wage_earnings = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )

   IF diff_hours >= 0 THEN
   (
      actual_hours_worked = actual_hours_worked - reduce_regular_hours
      if actual_hours_worked < 0 then
      (
         actual_hours_worked  = 0
      )
   )
   ELSE
   (
      /* reduce_regular_hours = actual_hours_worked */
      actual_hours_worked = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )
)
ELSE
(
   reduce_regular_earnings = 0
   reduce_regular_hours = 0
)

/* Reduce Regular Changes End Here */

IF regular_wage_earnings < 0 THEN
 (IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
      BG_TERMINATION_TYPE = ''A'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''A'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
      BG_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'') THEN
    neg_earn = 0
  ELSE
   (neg_earn = regular_wage_earnings
    regular_wage_earnings = 0
   )
 )
ELSE

 (IF REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD <> 0 THEN
    neg_earn = -1 * REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD
 )
IF REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN <> 0 THEN
  clear_addl_amt = -1 * REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN
IF t_vac_pay <> 0 THEN
  (vac_pay = t_vac_pay
   vac_hours_taken = t_vac_hours_taken
   regular_wage_earnings = regular_wage_earnings - vac_pay
   actual_hours_worked = actual_hours_worked - vac_hours_taken
  )
IF t_sick_pay <> 0 THEN
  (sick_pay = t_sick_pay

   sick_hours_taken = t_sick_hours_taken
   regular_wage_earnings = regular_wage_earnings - sick_pay
   actual_hours_worked = actual_hours_worked - sick_hours_taken
  )
/* Create latest balances */
	soe_run = REGULAR_WAGES_ASG_GRE_RUN
	soe_ytd = REGULAR_WAGES_ASG_GRE_YTD
	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN

HOURS_PASSED = actual_hours_worked

IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
    BG_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR

   (PAYROLL_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') THEN
 ( STOP_ENTRY = ''Y''
   if RATE_PASSED = 0 then
      ( RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
               clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
               sick_hours_taken, STOP_ENTRY, reduce_regular_earnings,
               reduce_regular_hours,mesg
      )
   else
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
              clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
              sick_hours_taken, STOP_ENTRY,ELEMENT_TYPE_ID_PASSED,
              RATE_PASSED,HOURS_PASSED,reduce_regular_earnings,reduce_regular_hours,
              mesg
      )
 )
ELSE
  (
   if RATE_PASSED = 0 then
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
               clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
               sick_hours_taken, reduce_regular_earnings, reduce_regular_hours,
               mesg
      )
   else
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
              clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
              sick_hours_taken,ELEMENT_TYPE_ID_PASSED,RATE_PASSED,HOURS_PASSED,
              reduce_regular_earnings, reduce_regular_hours, mesg
      )
   )';


      l_old_formula_text :=
   '/* ***************************************************************
$Header: payusrsrwupg.pkb 120.0.12010000.5 2009/07/06 05:44:27 sudedas noship $
FORMULA NAME:   REGULAR_WAGES
FORMULA TYPE:   Payroll
Change History
29 Sep 1993     hparicha        Created.
14 Oct 1993     hparicha        Moved skip rule formulae to separate
                                file ".SKIP".
30 Nov 1993     hparicha        G187
06 Dec 1993     jmychale        G305. Added aliases, entered database items
                                and tidied up formula
07 Jan 1994     jmychale        G491. Removed actual hours worked

                                parameter from Calculate_Period_
                                Earnings ()
13 Jan 1994     hparicha        G497. Reverted calc period earnings to
                                use ACTUAL_HOURS_WORKED!  Used by
                                Statement of Earnings report. Replaced
                                TIME_ENTRY_WAGES_COUNT with
                                LABOR_RECORDING_COUNT for timecard
                                req''d employees.
24 Feb 1994	hparicha	G560. ASS -> ASG; TU -> GRE
24 Feb 1994	hparicha	G581. Handles negative earnings.
09 Jun 1994	hparicha	G907. New implementation of generated and
				startup earnings and deductions using
				"<ELE_NAME> Special Features" shadow element
				to feed balances and handle Addl/Repl Amounts.
04 Jan 1995	hparicha	Vacation/Sick correlation to Regular Pay.
				New results need to be passed when vac/sick
				pay are present.
04 May 1995	hparicha	Defaulted values for PAY_PROC_PERIOD_
				START/END_DATE.  Default dates should
				be obvious when default is used.
10 Jan 1996	hparicha	323639	Major cleanup effort involving
                                proration and other user
				defined functions and formulae changes.
16 Apr 1996	ssdesai		Latest balances creation.
25 Apr 1996	hparicha	344018	Added check for USER_ENTERED_TIME.
17 Apr 1996     djeng           Changed PAY_PROC_PERIOD_START_DATE, and
                                PAY_PROC_PERIOD_END_DATE to
				PAY_EARNED_START_DATE and PAY_EARNED_END_DATE
13 AUG 1997     Lwhtomps        BUG 525859. Payments dimension can not be held
                                as a latest balance.
21 MAY 2001     ssarma          3 formula result rules added for Hours by rate
                                calculation. bug#1550323. They are:
                                ELEMENT_TYPE_ID_PASSED
                                RATE_PASSED
                                HOURS_PASSED
24 AUG 2001     pganguly        Changed the default for USER_ENTERED_TIME
                                from Y to N
24-AUG-2002     ekim            Changed the logic of Terminated employee.
24-MAY-2005     kvsankar        Cheanged the formula to use New Balance
                                ''Reduce Regular Earnings'' and ''Reduce Regular
                                Hours'' for Reduce Regular functionality
14-MAR-2006     asasthan        Modifed Reduce Regular to use ASG_GRE_RUN dbi
01-Mar-2007     kvsankar        Modified the formula to take care of
                                round off issues in Reduce Regular
26-Mar-2007     kvsankar        Modified the formula to use _ASG_GRE_RUN
                                dimension for Replacement and Additional
                                balances

--
--
INPUTS:         Rate
                Rate Code (text)
--
DBI Required:   ASG_SALARY_BASIS
                TERMINATED_EMPLOYEE
                FINAL_PAY_PROCESSED
                PAYROLL_TERMINATION_TYPE
                BG_TERMINATION_TYPE

                LABOR_RECORDING_COUNT
                SCL_ASG_US_WORK_SCHEDULE
                ASG_HOURS
                SCL_ASG_US_TIMECARD_REQUIRED

                CURRENT_ELEMENT_TYPE_ID
******************************************************************
DESCRIPTION:
******************************************************************
Computes earnings per pay period for hourly employees.
Proration function must be available to determine if employee worked entire
period - earnings will be adjusted accordingly by proration fn to account
for new hire, termination, leave of absence, etc.
*** Hourly handling ***
Regular wages earned per pay period for employees paid by the hour.

Hourly employees can either be "Hourly-Automatic" (ie. timecard not
required) or "Hourly-Timecard" where a timecard is required for pay.  The
hourly rate for an employee is entered as the input value for this element.
This rate is used with the number of hours worked to calculate earnings.
Hours worked will be indicated by one of the following:
     - time entry or entries (ie. timecard)
     - ASGigned Work Schedule
     - standard hours entered at the Organization and ASGignment levels.
For an Hourly-Timecard or "timecard required" employee, when a timecard
is not submitted by the payroll input cutoff date - the wages for that
employee will not be calculated and will have to wait for a subsequent
payroll run for processing.  When a timecard is submitted for an Hourly-
Automatic employee, then the time entry (or entries) is treated as the source
for Hours - if a rate is entered on the time entry, then this rate is used
along with the hours to compute pay, otherwise the normal rate (Regular
Wages rate) is used for computation.
If this is the Final Pay run for the employee''s ASGignment, then the
Regular Wages element will be discontinued after this run.
******************************************************************
ALGORITHM:
******************************************************************
If timecard required and time entries NOT FOUND, then
  message=''No timecards entered for Hourly, Timecard Required employee.''
  return message
  -- NOTE: If tc was req''d and time entries WERE found - then the skip rule
  --       for this Regular Salary element would have skipped this processing.


Endif
Call proration function with hourly rate; --> Regular_Wage_Earnings
If this is final pay for employee(ASGignment), then
  discontinue further processing of this element -- This is last time.
endif
Return Regular_Wage_Earnings
-- The earnings calculation for hourly employees will primarily be
calculated by the calculate_period_earnings() function.  This function
has its'' own hld (in Work Schedules Functionality doc) and lld to be
called calc_period_earnings.lld
******************************************************************
FORMULA_TEXT:

*******************************************************************/
/* Alias Section */
ALIAS SCL_ASG_US_WORK_SCHEDULE AS Work_Schedule
ALIAS SCL_ASG_US_TIMECARD_REQUIRED AS Timecard_Required
/* dbi defaults */
DEFAULT FOR     ASG_SALARY_BASIS                IS ''NOT ENTERED''
DEFAULT FOR     TERMINATED_EMPLOYEE             IS ''N''
DEFAULT FOR     FINAL_PAY_PROCESSED             IS ''N''
DEFAULT FOR     PAYROLL_TERMINATION_TYPE     IS ''L''
DEFAULT FOR     BG_TERMINATION_TYPE          IS ''L''
default for     LAST_STANDARD_PROCESS_DATE_PROCESSED IS ''N''
DEFAULT FOR     LABOR_RECORDING_COUNT           IS 0
DEFAULT FOR     USER_ENTERED_TIME               IS ''N''

default for	PAY_PROC_PERIOD_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_PROC_PERIOD_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)
default for	PAY_EARNED_START_DATE 	is ''1900/01/01 00:00:00'' (DATE)
default for	PAY_EARNED_END_DATE 	is ''1900/01/02 00:00:00'' (DATE)

DEFAULT FOR     Work_Schedule                   IS ''NOT ENTERED''
DEFAULT FOR     ASG_HOURS                       IS 0
DEFAULT FOR     ASG_FREQ		IS ''NOT ENTERED''  /* WWBug 323639 */
DEFAULT FOR     Timecard_Required               IS ''N''
DEFAULT FOR 	REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD	IS 0
DEFAULT FOR 	REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN	IS 0
DEFAULT FOR 	REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN	IS 0
DEFAULT FOR	REGULAR_WAGES_ASG_GRE_RUN		IS 0
DEFAULT FOR	REGULAR_HOURS_WORKED_ASG_GRE_RUN	IS 0
DEFAULT FOR     CURRENT_ELEMENT_TYPE_ID                 IS 0
DEFAULT FOR     REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN   IS  0
DEFAULT FOR     REDUCE_REGULAR_HOURS_ASG_GRE_RUN  IS  0

/* inpval defaults */
DEFAULT FOR     Rate                            IS 0
DEFAULT FOR     Rate_Code (text)                IS ''NOT ENTERED''

INPUTS ARE      Rate,
                Rate_Code (text)
/* Updatable Values */
RATE_TABLE              =  ''WAGE RATES''
RATE_TABLE_COLUMN       =  ''Wage Rate''

MESG = '' ''
/* Changed for new Termination Rule
IF TERMINATED_EMPLOYEE = ''Y'' AND USER_ENTERED_TIME = ''Y'' THEN
 (STOP_ENTRY = ''Y''
  mesg = ''Regular Wages being stopped after Final Pay.''
  RETURN STOP_ENTRY, mesg
  )
*/
IF Timecard_Required = ''Y'' AND LABOR_RECORDING_COUNT = 0 THEN
 (mesg = ''No timecards entered for Hourly, Timecard Required employee''
  RETURN mesg

  )

ELEMENT_TYPE_ID_PASSED = CURRENT_ELEMENT_TYPE_ID
RATE_PASSED = 0
HOURS_PASSED = 0

IF REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN WAS DEFAULTED OR
   REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN = 0 THEN
  IF Rate WAS NOT DEFAULTED THEN
   (hourly_rate = Rate
    actual_hours_worked = 0
    t_vac_hours_taken = 0
    t_vac_pay = 0
    t_sick_hours_taken = 0
    t_sick_pay = 0
    regular_wage_earnings =  Calc_Period_Earnings (
                                        ASG_SALARY_BASIS,
                                        ''RATE'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        actual_hours_worked,
		                        t_vac_hours_taken,
		                        t_vac_pay,
		                        t_sick_hours_taken,
		                        t_sick_pay,
                                        ''Y'',
                                       ASG_FREQ)
                             /*Calculate_Period_Earnings(
                                        ASG_SALARY_BASIS,
                                        ''RATE'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        Work_Schedule,
                                        ASG_HOURS,
                                        actual_hours_worked,
					t_vac_hours_taken,
					t_vac_pay,
					t_sick_hours_taken,
					t_sick_pay,
                                        ''Y'',
                 			ASG_FREQ)*/
/*  WWBug 323639 */
    RATE_PASSED = hourly_rate
   )

  ELSE
    IF Rate_Code WAS NOT DEFAULTED THEN
     (hourly_rate = To_Number(Get_Table_Value( RATE_TABLE,
                                             RATE_TABLE_COLUMN,
                                             Rate_Code))
      actual_hours_worked = 0
      t_vac_hours_taken = 0
      t_vac_pay = 0
      t_sick_hours_taken = 0
      t_sick_pay = 0
      RATE_PASSED = hourly_rate
      regular_wage_earnings =  Calc_Period_Earnings (
                                        ''HOURLY'',
                                        ''RATE CODE'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        actual_hours_worked,
                                        t_vac_hours_taken,
                                        t_vac_pay,
                                        t_sick_hours_taken,
                                        t_sick_pay,
                                        ''Y'',
                                       ASG_FREQ)
                             /*Calculate_Period_Earnings(
                                        ''HOURLY'',
                                        ''RATE CODE'',
                                        hourly_rate,
                                        PAY_EARNED_START_DATE,
                                        PAY_EARNED_END_DATE,
                                        Work_Schedule,
                                        ASG_HOURS,
                                        actual_hours_worked,
                                        t_vac_hours_taken,
		                	t_vac_pay,
                			t_sick_hours_taken,
		                	t_sick_pay,
                                        ''Y'',
                			ASG_FREQ)*/
/*  WWBug 323639 */
     )

    ELSE
     (mesg = ''No Hourly Rate or Rate Code entered for this employee''
      RETURN mesg
     )
ELSE
 (regular_wage_earnings = REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN
  clear_repl_amt = -1 * REGULAR_WAGES_REPLACEMENT_ASG_GRE_RUN
  /*  WWBug 323639 */
  actual_hours_worked = 0
  t_vac_hours_taken = 0
  t_vac_pay = 0
  t_sick_hours_taken = 0
  t_sick_pay = 0
 )
regular_wage_earnings = regular_wage_earnings
                        + REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN
                        + REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD
/*
At the Business Group and Organization level, termination
rule is determined which all terminated employees will
follow for the payment. All existing payrolls and/or
business groups (prior to July Family Pack 2002)
will be updated with Actual Termination Date for the
termination rule and for new Business Group
or payroll, user can decide whether to use Actual Term date
or Last Standard Process Date.  When no term rule is
specified, it defaults to Last Standard Process date.
*/

RED_REG_ADJUST_AMOUNT = 0.05
RED_REG_ADJUST_HOURS  = 0.01

reduce_regular_earnings = -1 * REDUCE_REGULAR_EARNINGS_ASG_GRE_RUN
reduce_regular_hours = -1 * REDUCE_REGULAR_HOURS_ASG_GRE_RUN
diff_earnings = regular_wage_earnings - reduce_regular_earnings
                + RED_REG_ADJUST_AMOUNT
diff_hours = actual_hours_worked - reduce_regular_hours
             + RED_REG_ADJUST_HOURS

/* Reduce Regular Changes Start Here */

IF Timecard_Required = ''N'' AND
   reduce_regular_earnings <> 0 THEN
(
   /*
    * We need to carry over reduce regular Earnings/Hours to the next Pay
    * Period if it is more than regular salaried earnings so that we
    * never have regular salaried earnings less than ZERO
    */
   IF diff_earnings >= 0 THEN
   (
      regular_wage_earnings = regular_wage_earnings - reduce_regular_earnings
      if regular_wage_earnings < 0 then
      (
         regular_wage_earnings = 0
      )
   )
   ELSE
   (
     /* reduce_regular_earnings = regular_wage_earnings */
      regular_wage_earnings = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )

   IF diff_hours >= 0 THEN
   (
      actual_hours_worked = actual_hours_worked - reduce_regular_hours
      if actual_hours_worked < 0 then
      (
         actual_hours_worked  = 0
      )
   )
   ELSE
   (
      /* reduce_regular_hours = actual_hours_worked */
      actual_hours_worked = 0
      mesg = GET_MESG(''PAY'',''PAY_74069_HIGH_REDUCE_REG_EARN'')
   )
)
ELSE
(
   reduce_regular_earnings = 0
   reduce_regular_hours = 0
)

/* Reduce Regular Changes End Here */

IF regular_wage_earnings < 0 THEN
 (IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
      BG_TERMINATION_TYPE = ''A'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''A'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      FINAL_PAY_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
      BG_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'') OR
     (PAYROLL_TERMINATION_TYPE = ''L'' AND
      TERMINATED_EMPLOYEE = ''Y'' AND
      LAST_STANDARD_PROCESS_DATE_PROCESSED = ''N'') THEN
    neg_earn = 0
  ELSE
   (neg_earn = regular_wage_earnings
    regular_wage_earnings = 0
   )
 )
ELSE

 (IF REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD <> 0 THEN
    neg_earn = -1 * REGULAR_WAGES_NEG_EARNINGS_ASG_GRE_ITD
 )
IF REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN <> 0 THEN
  clear_addl_amt = -1 * REGULAR_WAGES_ADDITIONAL_ASG_GRE_RUN
IF t_vac_pay <> 0 THEN
  (vac_pay = t_vac_pay
   vac_hours_taken = t_vac_hours_taken
   regular_wage_earnings = regular_wage_earnings - vac_pay
   actual_hours_worked = actual_hours_worked - vac_hours_taken
  )
IF t_sick_pay <> 0 THEN
  (sick_pay = t_sick_pay

   sick_hours_taken = t_sick_hours_taken
   regular_wage_earnings = regular_wage_earnings - sick_pay
   actual_hours_worked = actual_hours_worked - sick_hours_taken
  )
/* Create latest balances */
	soe_run = REGULAR_WAGES_ASG_GRE_RUN
	soe_ytd = REGULAR_WAGES_ASG_GRE_YTD
	soe_hrs = REGULAR_HOURS_WORKED_ASG_GRE_RUN

HOURS_PASSED = actual_hours_worked

IF (PAYROLL_TERMINATION_TYPE WAS DEFAULTED AND
    BG_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') OR

   (PAYROLL_TERMINATION_TYPE = ''A'' AND
    TERMINATED_EMPLOYEE = ''Y'' AND FINAL_PAY_PROCESSED = ''N'') THEN
 ( STOP_ENTRY = ''Y''
   if RATE_PASSED = 0 then
      ( RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
               clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
               sick_hours_taken, STOP_ENTRY, reduce_regular_earnings,
               reduce_regular_hours,mesg
      )
   else
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
              clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
              sick_hours_taken, STOP_ENTRY,ELEMENT_TYPE_ID_PASSED,
              RATE_PASSED,HOURS_PASSED,reduce_regular_earnings,reduce_regular_hours,
              mesg
      )
 )
ELSE
  (
   if RATE_PASSED = 0 then
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
               clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
               sick_hours_taken, reduce_regular_earnings, reduce_regular_hours,
               mesg
      )
   else
      (RETURN regular_wage_earnings, actual_hours_worked, clear_repl_amt,
              clear_addl_amt, neg_earn, vac_pay, vac_hours_taken, sick_pay,
              sick_hours_taken,ELEMENT_TYPE_ID_PASSED,RATE_PASSED,HOURS_PASSED,
              reduce_regular_earnings, reduce_regular_hours, mesg
      )
   )';

  END IF; -- Regular Salary / Regular Wages

  IF p_mode = 'NEW' THEN

        hr_utility.trace('Updating Formula Text in Mode := ' || p_mode);

        BEGIN
        update ff_formulas_f
           set formula_text = l_new_formula_text
         where formula_name = l_formula_name
           and business_group_id IS NULL
           and legislation_code = 'US';

           hr_utility.trace('Formula Updated.');
           COMMIT;
           hr_utility.trace('Formula Update Commited!');
        EXCEPTION
        WHEN OTHERS THEN
          hr_utility.trace('SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
       END;

  ELSIF p_mode = 'OLD' THEN

        hr_utility.trace('Updating Formula Text in Mode := ' || p_mode);
        BEGIN
        update ff_formulas_f
           set formula_text = l_old_formula_text
         where formula_name = l_formula_name
           and business_group_id IS NULL
           and legislation_code = 'US';
           hr_utility.trace('Formula Updated.');
           COMMIT;
           hr_utility.trace('Formula Update Commited!');
        EXCEPTION
        WHEN OTHERS THEN
          hr_utility.trace('SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
       END;

  END IF;

   /*
    * Removing Entry from ff_compiled_info and ff_fdi_usages for both the formulas
    * that are created for the seeded elements. Customer needs to recompile all the
    * formulae after running this process.
    */
   delete
     from ff_compiled_info_f
    where formula_id = l_formula_id;

   delete
     from ff_fdi_usages_f
    where formula_id = l_formula_id;

   hr_utility.trace('Leaving ' || gv_package_name || '.modify_formula_text');

END modify_formula_text;

/*****************************************************************************
  Name        : create_proration_group
  Description : This Function creates a Proration Group called
               'Proration Group for Regular Salary'.
*****************************************************************************/
FUNCTION create_proration_group
RETURN NUMBER IS

TYPE typ_col_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
col_name_tbl typ_col_name;

CURSOR get_dated_table_id(p_application_id IN NUMBER
                         ,p_table_name   IN VARCHAR2) IS
SELECT dated_table_id
  FROM pay_dated_tables pdt
 WHERE pdt.application_id = p_application_id
   AND pdt.table_name = p_table_name
   AND pdt.legislation_code IS NULL
   AND pdt.business_group_id IS NULL;

ln_event_group_id          pay_event_groups.event_group_id%TYPE;
ln_event_grp_ovn           pay_event_groups.object_version_number%TYPE;
ln_eef_dt_ovn              pay_datetracked_events.object_version_number%TYPE;
ln_eevf_dt_ovn             pay_datetracked_events.object_version_number%TYPE;
ln_paaf_dt_ovn             pay_datetracked_events.object_version_number%TYPE;

ln_eef_dt_event_id         pay_datetracked_events.datetracked_event_id%TYPE;
ln_eevf_dt_event_id        pay_datetracked_events.datetracked_event_id%TYPE;
ln_paaf_dt_event_id        pay_datetracked_events.datetracked_event_id%TYPE;

ln_eef_dt_tbl_id           pay_dated_tables.dated_table_id%TYPE;
ln_eevf_dt_tbl_id          pay_dated_tables.dated_table_id%TYPE;
ln_paaf_dt_tbl_id          pay_dated_tables.dated_table_id%TYPE;

ln_index                   NUMBER;

BEGIN
    hr_utility.trace('Entering into create_proration_group.');
    hr_utility.trace('col_name_tbl.count() := ' || col_name_tbl.count());

    IF col_name_tbl.count() > 0 THEN
       col_name_tbl.delete;
    END IF;

    hr_utility.trace('Before Event Group Creation.');
    pay_event_groups_api.create_event_group(FALSE
                                           ,fnd_date.canonical_to_date('0001/01/01')
                                           ,'Proration Group for Regular Salary'
                                           ,'P'
                                           ,'P'
                                           ,NULL
                                           ,'US'
                                           ,ln_event_group_id
                                           ,ln_event_grp_ovn
                                           ,NULL);

    hr_utility.trace('After Event Group Creation.');

    OPEN get_dated_table_id(801, 'PAY_ELEMENT_ENTRIES_F');
    FETCH get_dated_table_id INTO ln_eef_dt_tbl_id;
    CLOSE get_dated_table_id;
    hr_utility.trace('ln_eef_dt_tbl_id := ' || ln_eef_dt_tbl_id);

    ln_index := 1;
    col_name_tbl(ln_index) := 'EFFECTIVE_START_DATE';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'DATE_EARNED';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'ELEMENT_TYPE_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'EFFECTIVE_END_DATE';

    hr_utility.trace('col_name_tbl.count() := ' || col_name_tbl.count());
    hr_utility.trace('Before Creating Date-Tracked Events for PAY_ELEMENT_ENTRIES_F.');

    FOR i IN 1..col_name_tbl.count()
    LOOP
    hr_utility.trace('Within create_datetracked_event i := ' || i);
    hr_utility.trace('ln_event_group_id := ' || ln_event_group_id);
    hr_utility.trace('ln_eef_dt_tbl_id := ' || ln_eef_dt_tbl_id);
    hr_utility.trace('col_name_tbl(i) := ' || col_name_tbl(i));

    pay_datetracked_events_api.create_datetracked_event(FALSE
                                                       ,fnd_date.canonical_to_date('0001/01/01')
                                                       ,ln_event_group_id
                                                       ,ln_eef_dt_tbl_id
                                                       ,'U'
                                                       ,col_name_tbl(i)
                                                       ,NULL
                                                       ,'US'
                                                       ,NULL
                                                       ,ln_eef_dt_event_id
                                                       ,ln_eef_dt_ovn);
    END LOOP;
    hr_utility.trace('After Creating Date-Tracked Events for PAY_ELEMENT_ENTRIES_F.');

    OPEN get_dated_table_id(801, 'PAY_ELEMENT_ENTRY_VALUES_F');
    FETCH get_dated_table_id INTO ln_eevf_dt_tbl_id;
    CLOSE get_dated_table_id;

    hr_utility.trace('ln_eevf_dt_tbl_id := ' || ln_eevf_dt_tbl_id);

    col_name_tbl.delete;
    ln_index := 1;
    col_name_tbl(ln_index) := 'ELEMENT_ENTRY_VALUE_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'ELEMENT_ENTRY_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'SCREEN_ENTRY_VALUE';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'EFFECTIVE_END_DATE';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'EFFECTIVE_START_DATE';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'INPUT_VALUE_ID';

    hr_utility.trace('col_name_tbl.count() := ' || col_name_tbl.count());
    hr_utility.trace('Before Creating Date-Tracked Events for PAY_ELEMENT_ENTRY_VALUES_F.');

    FOR i IN 1..col_name_tbl.count()
    LOOP
    hr_utility.trace('Within create_datetracked_event i := ' || i);
    hr_utility.trace('ln_event_group_id := ' || ln_event_group_id);
    hr_utility.trace('ln_eevf_dt_tbl_id := ' || ln_eevf_dt_tbl_id);
    hr_utility.trace('col_name_tbl(i) := ' || col_name_tbl(i));

    pay_datetracked_events_api.create_datetracked_event(FALSE
                                                       ,fnd_date.canonical_to_date('0001/01/01')
                                                       ,ln_event_group_id
                                                       ,ln_eevf_dt_tbl_id
                                                       ,'U'
                                                       ,col_name_tbl(i)
                                                       ,NULL
                                                       ,'US'
                                                       ,NULL
                                                       ,ln_eevf_dt_event_id
                                                       ,ln_eevf_dt_ovn);
    END LOOP;

    hr_utility.trace('After Creating Date-Tracked Events for PAY_ELEMENT_ENTRY_VALUES_F.');

    OPEN get_dated_table_id(800, 'PER_ALL_ASSIGNMENTS_F');
    FETCH get_dated_table_id INTO ln_paaf_dt_tbl_id;
    CLOSE get_dated_table_id;

    hr_utility.trace('ln_paaf_dt_tbl_id := ' || ln_paaf_dt_tbl_id);
    hr_utility.trace('Before Creating Date-Tracked Events for PER_ALL_ASSIGNMENTS_F');

    col_name_tbl.delete;
    ln_index := 1;
    col_name_tbl(ln_index) := 'PAY_BASIS_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'SOFT_CODING_KEYFLEX_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'PAYROLL_ID';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'NORMAL_HOURS';
    ln_index := ln_index + 1;
    col_name_tbl(ln_index) := 'ASSIGNMENT_STATUS_TYPE_ID';

    hr_utility.trace('col_name_tbl.count() := ' || col_name_tbl.count());
    hr_utility.trace('Before Creating Date-Tracked Events for PER_ALL_ASSIGNMENTS_F.');

    FOR i IN 1..col_name_tbl.count()
    LOOP
    hr_utility.trace('Within create_datetracked_event i := ' || i);
    hr_utility.trace('ln_event_group_id := ' || ln_event_group_id);
    hr_utility.trace('ln_paaf_dt_tbl_id := ' || ln_paaf_dt_tbl_id);
    hr_utility.trace('col_name_tbl(i) := ' || col_name_tbl(i));

    pay_datetracked_events_api.create_datetracked_event(FALSE
                                                       ,fnd_date.canonical_to_date('0001/01/01')
                                                       ,ln_event_group_id
                                                       ,ln_paaf_dt_tbl_id
                                                       ,'U'
                                                       ,col_name_tbl(i)
                                                       ,NULL
                                                       ,'US'
                                                       ,NULL
                                                       ,ln_paaf_dt_event_id
                                                       ,ln_paaf_dt_ovn);
    END LOOP;
    hr_utility.trace('After Creating Date-Tracked Events for PER_ALL_ASSIGNMENTS_F.');
    COMMIT;
    hr_utility.trace('Returning ln_event_group_id := ' || ln_event_group_id);
    RETURN ln_event_group_id;

END create_proration_group;

/*****************************************************************************
  Name        : delete_proration_group
  Description : This Function deletes the Proration Group called
               'Proration Group for Regular Salary'.
*****************************************************************************/

PROCEDURE delete_proration_group IS

CURSOR get_proration_event_grp(cp_event_grp_nm IN VARCHAR2) IS
      SELECT event_group_id
            ,object_version_number
      FROM   pay_event_groups peg
     WHERE   peg.event_group_name = cp_event_grp_nm
       AND   peg.event_group_type = 'P'
       AND   peg.proration_type = 'P'
       AND   peg.legislation_code = 'US'
       AND   peg.business_group_id IS NULL;

   ln_event_grp_id    pay_event_groups.event_group_id%TYPE;
   ln_obj_ver_num     pay_event_groups.object_version_number%TYPE;

BEGIN

     hr_utility.trace('Entered into pay_us_rsrw_upgrev.delete_proration_group');

     open get_proration_event_grp('Proration Group for Regular Salary');
     fetch get_proration_event_grp into ln_event_grp_id, ln_obj_ver_num;
     close get_proration_event_grp;

     hr_utility.trace('ln_event_grp_id := ' || ln_event_grp_id);
     hr_utility.trace('ln_obj_ver_num := ' || ln_obj_ver_num);

     delete from pay_datetracked_events
           where event_group_id = ln_event_grp_id;

     pay_event_groups_api.delete_event_group(p_event_group_id => ln_event_grp_id
                                            ,p_object_version_number => ln_obj_ver_num);

     commit;
END delete_proration_group;

/*****************************************************************************
  Name        : upgrade_reg_salarywages

  Description : This procedure is called from the Concurrent Request. Based on
                element name passed in as a parameter, we will execute the
                procedure that will migrate the element in ine request.
*****************************************************************************/
PROCEDURE upgrade_reg_salarywages(errbuf out nocopy varchar2
                                 ,retcode out nocopy number)
IS

-- Get the element type id

CURSOR get_ele_typ_id(cp_ele_name IN VARCHAR2) IS
     SELECT element_type_id
           ,element_name
           ,proration_group_id
       FROM pay_element_types_f
      WHERE element_name = cp_ele_name
        AND legislation_code = 'US'
        AND business_group_id IS NULL
        AND element_information_category = 'US_EARNINGS'
        AND element_information1 = 'REG';

-- Get Upgrade Status
CURSOR get_upg_status is
       select  pus.status
         from  pay_upgrade_definitions pud
              ,pay_upgrade_status pus
         where pud.short_name = 'US_REG_EARNINGS_UPGRADE'
           and pud.legislation_code = 'US'
           and pud.upgrade_definition_id = pus.upgrade_definition_id
           and pus.legislation_code = 'US';

-- Get Proration Event Group
CURSOR get_proration_event_grp(cp_event_grp_nm IN VARCHAR2) IS
      SELECT event_group_id
      FROM   pay_event_groups peg
     WHERE   peg.event_group_name = cp_event_grp_nm
       AND   peg.event_group_type = 'P'
       AND   peg.proration_type = 'P'
       AND   peg.legislation_code = 'US'
       AND   peg.business_group_id IS NULL;

-- Local Variable Declaration
l_date_of_mig              date;
ln_proration_event_grp_id  pay_event_groups.event_group_id%TYPE;
ln_rs_ele_typ_id           number;
lv_rs_ele_name             pay_element_types_f.element_name%TYPE;
ln_rs_proration_grp_id     pay_element_types_f.proration_group_id%TYPE;
ln_rw_ele_typ_id           number;
lv_rw_ele_name             pay_element_types_f.element_name%TYPE;
ln_rw_proration_grp_id     pay_element_types_f.proration_group_id%TYPE;
lv_upg_status              varchar2(30);
ln_dbg_step                number;

begin

   --hr_utility.trace_on(NULL, 'Oracle');

   /*
    * Initialization Code
    */
   gv_package_name          := 'pay_us_rsrw_upgrev';
-- Initialise Variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error

   /*
    * Initial Trace
    */

   hr_utility.trace('Entering ' || gv_package_name || '.upgrade_regular_salary');

   /*
    * Legislation Level Migration
    */

   l_date_of_mig := fnd_date.canonical_to_date(trunc(sysdate));
   hr_utility.trace('Date of Migration ' || l_date_of_mig);

   /*
    * STEP 1
   */

   open get_ele_typ_id('Regular Salary');
   fetch get_ele_typ_id into ln_rs_ele_typ_id, lv_rs_ele_name, ln_rs_proration_grp_id;
   close get_ele_typ_id;

   open get_ele_typ_id('Regular Wages');
   fetch get_ele_typ_id into ln_rw_ele_typ_id, lv_rw_ele_name, ln_rw_proration_grp_id;
   close get_ele_typ_id;

   hr_utility.trace('ln_rs_ele_typ_id := ' || ln_rs_ele_typ_id);
   hr_utility.trace('ln_rs_proration_grp_id := ' || ln_rs_proration_grp_id);
   hr_utility.trace('ln_rw_ele_typ_id := ' || ln_rw_ele_typ_id);
   hr_utility.trace('ln_rw_proration_grp_id := ' || ln_rw_proration_grp_id);

   lv_upg_status := NULL;

   open get_upg_status;
   fetch get_upg_status into lv_upg_status;
   close get_upg_status;

   hr_utility.trace('lv_upg_status := ' || lv_upg_status);

   IF nvl(lv_upg_status, 'N') <> 'C' THEN
   /*
    * STEP 2
   */

      OPEN get_proration_event_grp('Proration Group for Regular Salary');
      FETCH get_proration_event_grp INTO ln_proration_event_grp_id;

      IF get_proration_event_grp%FOUND THEN
         delete_proration_group();
      END IF;
      CLOSE get_proration_event_grp;

      ln_proration_event_grp_id := create_proration_group();
      commit;

      hr_utility.trace('ln_proration_event_grp_id := ' || ln_proration_event_grp_id);

    /* Update Proration Group */

      BEGIN

      ln_dbg_step := 1;

      update pay_element_types_f
      set    proration_group_id = ln_proration_event_grp_id
      where  element_name in ('Regular Salary', 'Regular Wages')
       AND   business_group_id IS NULL
       AND   legislation_code = 'US'
       AND   element_information_category = 'US_EARNINGS'
       AND   element_information1 = 'REG';

      /* Insert records into pay_upgrade_definitions and pay_upgrade_status */

      ln_dbg_step := 2;

      insert into pay_upgrade_definitions(UPGRADE_DEFINITION_ID
                                         ,SHORT_NAME
                                         ,NAME
                                         ,LEGISLATION_CODE
                                         ,DESCRIPTION
                                         ,UPGRADE_LEVEL
                                         ,CRITICALITY
                                         ,THREADING_LEVEL
                                         ,FAILURE_POINT
                                         ,LEGISLATIVELY_ENABLED
                                         ,UPGRADE_METHOD
                                         ,UPGRADE_PROCEDURE
                                         ,LAST_UPDATE_DATE
                                         ,LAST_UPDATED_BY
                                         ,LAST_UPDATE_LOGIN
                                         ,CREATED_BY
                                         ,CREATION_DATE
                                         ,ADDITIONAL_INFO)
                                  select PAY_UPGRADE_DEFINITIONS_S.nextval
                                        ,'US_REG_EARNINGS_UPGRADE'
                                        ,'Upgrade Regular Earnings Elements for all US Business Groups'
                                        ,'US'
                                        ,'Upgrade Regular Earnings Elements for all US Business Groups'
                                        ,'L'
                                        ,'R'
                                        ,'PET'
                                        ,'N'
                                        ,'N'
                                        ,'PYUGEN'
                                        ,'pay_us_rsrw_upgrev.upgrade_reg_salarywages'
                                        ,sysdate
                                        ,1
                                        ,-1
                                        ,1
                                        ,sysdate
                                        ,'Run through separate conc program' from sys.dual;

       ln_dbg_step := 3;

       insert into pay_upgrade_status(UPGRADE_DEFINITION_ID
                                     ,STATUS
                                     ,LEGISLATION_CODE)
                              select PAY_UPGRADE_DEFINITIONS_S.currval
                                    ,'C'
                                    ,'US' from sys.dual;

       EXCEPTION
       WHEN OTHERS THEN
          hr_utility.trace('Error Occured in Step = ' || ln_dbg_step || ', ' || 'SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
      END;
      COMMIT;
      hr_utility.trace('Insertion Commited!');

   ELSIF nvl(lv_upg_status, 'N') = 'C'
     AND (ln_rs_proration_grp_id IS NULL OR ln_rw_proration_grp_id IS NULL) THEN

     /* Following scenario will occur when hrglobal is run
        after running Upgrade seeded Regular Earnings
     */

      OPEN get_proration_event_grp('Proration Group for Regular Salary');
      FETCH get_proration_event_grp INTO ln_proration_event_grp_id;

      IF get_proration_event_grp%NOTFOUND THEN
         ln_proration_event_grp_id := create_proration_group();
         COMMIT;
      END IF;
      CLOSE get_proration_event_grp;

      hr_utility.trace('ln_proration_event_grp_id := ' || ln_proration_event_grp_id);

    /* Update Proration Group */

      BEGIN

      ln_dbg_step := 4;

      update pay_element_types_f
      set    proration_group_id = ln_proration_event_grp_id
      where  element_name in ('Regular Salary', 'Regular Wages')
       AND   business_group_id IS NULL
       AND   legislation_code = 'US'
       AND   element_information_category = 'US_EARNINGS'
       AND   element_information1 = 'REG';

       EXCEPTION
       WHEN OTHERS THEN
          hr_utility.trace('Error Occured in Step = ' || ln_dbg_step || ', ' || 'SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
      END;
      COMMIT;
      hr_utility.trace('Update of proration group Commited!');

   ELSE
      fnd_file.put_line(FND_FILE.LOG,'Elements ''Regular Salary'' and ''Regular Wages'' have already been upgraded for Legislation ''US''.');
      hr_utility.trace('Elements ''Regular Salary'' and ''Regular Wages'' have already been upgraded for Legislation ''US''.');
   END IF;

   fnd_file.put_line(FND_FILE.LOG, 'Regular Salary and Regular Wages have been successfully upgraded for ''US''.');

   hr_utility.trace('Leaving ' || gv_package_name || '.upgrade_reg_salarywages');

EXCEPTION
WHEN OTHERS THEN
   fnd_file.put_line(FND_FILE.LOG, '''Regular Salary''/''Regular Wages'' Element upgradation failed for Legislation ''US''.');
   hr_utility.raise_error;
          hr_utility.trace('SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
end upgrade_reg_salarywages;

/*****************************************************************************
  Name        : revert_upg_reg_salarywages

  Description : This Procedure is responsible for Reverting Back the Upgradation
                of Seeded Earnings Elements "Regular Salary" and "Regula Wages"
                done by the earlier Upgradation Process. This is called by
                Concurrent Program "Revert back upgradation of Seeded Earnings
                Elements for US"
*****************************************************************************/
PROCEDURE revert_upg_reg_salarywages(errbuf out nocopy varchar2
                                ,retcode out nocopy number) IS
-- Get the element type id

CURSOR get_ele_typ_id(cp_ele_name IN VARCHAR2) IS
     SELECT element_type_id
           ,element_name
           ,proration_group_id
       FROM pay_element_types_f
      WHERE element_name = cp_ele_name
        AND legislation_code = 'US'
        AND business_group_id IS NULL
        AND element_information_category = 'US_EARNINGS'
        AND element_information1 = 'REG';

-- Get Upgrade Status
CURSOR get_upg_status is
       select  pus.status
              ,pud.upgrade_definition_id
         from  pay_upgrade_definitions pud
              ,pay_upgrade_status pus
         where pud.short_name = 'US_REG_EARNINGS_UPGRADE'
           and pud.legislation_code = 'US'
           and pud.upgrade_definition_id = pus.upgrade_definition_id
           and pus.legislation_code = 'US';

-- Local Variable Declaration
l_date_of_mig          date;
ln_rs_ele_typ_id           number;
lv_rs_ele_name             pay_element_types_f.element_name%TYPE;
ln_rs_proration_grp_id     pay_element_types_f.proration_group_id%TYPE;
ln_rw_ele_typ_id           number;
lv_rw_ele_name             pay_element_types_f.element_name%TYPE;
ln_rw_proration_grp_id     pay_element_types_f.proration_group_id%TYPE;
ln_proration_event_grp_id  pay_event_groups.event_group_id%TYPE;
lv_upg_status          varchar2(30);
ln_upg_defn_id         NUMBER;
ln_dbg_step            NUMBER;

begin
   /*
    * Initialization Code
    */
   gv_package_name          := 'pay_us_rsrw_upgrev';
-- Initialise Variable - 0 is SRS Success, 1 is SRS Warning, 2 is SRS Error

   /*
    * Initial Trace
    */
   hr_utility.trace('Entering ' || gv_package_name || '.revert_upg_reg_salary');

   /*
    * Legislation Level Migration
    */

   l_date_of_mig := fnd_date.canonical_to_date(trunc(sysdate));
   hr_utility.trace('Date of Migration ' || l_date_of_mig);

   /*
    * STEP 1
   */

   open get_ele_typ_id('Regular Salary');
   fetch get_ele_typ_id into ln_rs_ele_typ_id, lv_rs_ele_name, ln_rs_proration_grp_id;
   close get_ele_typ_id;

   open get_ele_typ_id('Regular Wages');
   fetch get_ele_typ_id into ln_rw_ele_typ_id, lv_rw_ele_name, ln_rw_proration_grp_id;
   close get_ele_typ_id;

   hr_utility.trace('ln_rs_ele_typ_id := ' || ln_rs_ele_typ_id);
   hr_utility.trace('ln_rs_proration_grp_id := ' || ln_rs_proration_grp_id);
   hr_utility.trace('ln_rw_ele_typ_id := ' || ln_rw_ele_typ_id);
   hr_utility.trace('ln_rw_proration_grp_id := ' || ln_rw_proration_grp_id);

   lv_upg_status := NULL;

   open get_upg_status;
   fetch get_upg_status into lv_upg_status, ln_upg_defn_id;
   close get_upg_status;

   hr_utility.trace('lv_upg_status := ' || lv_upg_status);
   hr_utility.trace('ln_upg_defn_id := ' || ln_upg_defn_id);

   IF nvl(lv_upg_status, 'N') = 'C' THEN
   /*
    * STEP 2
   */

      BEGIN

      /* Update Proration Group */

      ln_dbg_step := 1;

      update pay_element_types_f
      set    proration_group_id = NULL
      where  element_name in ('Regular Salary', 'Regular Wages')
       and   business_group_id is null
       and   legislation_code = 'US'
       AND   element_information_category = 'US_EARNINGS'
       AND   element_information1 = 'REG';

      ln_dbg_step := 2;

      delete from pay_upgrade_status
       where upgrade_definition_id = ln_upg_defn_id;

      ln_dbg_step := 3;

      delete from pay_upgrade_definitions
       where  upgrade_definition_id = ln_upg_defn_id
         and  short_name like 'US_REG_EARNINGS_UPGRADE'
         and  legislation_code = 'US';


      EXCEPTION
      WHEN OTHERS THEN
          hr_utility.trace('Error Occured in Step = ' || ln_dbg_step || ', ' || 'SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));
      END;

      COMMIT;
      hr_utility.trace('Update/Delete Commited!');

   ELSE
      fnd_file.put_line(FND_FILE.LOG, 'Elements Regular Salary and Regular Wages have not been upgraded for Legislation ''US''.');
      hr_utility.trace('Elements Regular Salary and Regular Wages have not been upgraded for Legislation ''US''.');
   END IF;

   fnd_file.put_line(FND_FILE.LOG, '''Regular Salary'' and ''Regular Wages'' has been successfully reverted back for ''US''.');
   hr_utility.trace('Leaving ' || gv_package_name || '.revert_upg_reg_salarywages');

EXCEPTION
WHEN OTHERS THEN
   fnd_file.put_line(FND_FILE.LOG, 'Reverting back upgradation of ''Regular Salary''/''Regular Wages'' Element failed for Legislation ''US''.');
   hr_utility.raise_error;
          hr_utility.trace('SQLCODE := ' || TO_CHAR(SQLCODE));
          hr_utility.trace('SQLERRM := ' || SUBSTR(SQLERRM, 1, 200));

END revert_upg_reg_salarywages;

/*****************************************************************************
  Name        : get_upgrade_flag

  Description : This Function checks record from pay_upgrade_status and
                pay_upgrade_definitions tables for Upgrade of seeded
                Regular Earnings elements "Regular Salary" and "Regular
                Wages" and return 'Y' or 'N' to be used by respective
                Fast Formula to determine what logic is to be used.
*****************************************************************************/

FUNCTION get_upgrade_flag(p_ctx_ele_typ_id IN NUMBER)
RETURN VARCHAR2 IS

  -- Get Upgrade Status
  CURSOR get_upg_status is
       select  pus.status
              ,pud.upgrade_definition_id
         from  pay_upgrade_definitions pud
              ,pay_upgrade_status pus
         where pud.short_name = 'US_REG_EARNINGS_UPGRADE'
           and pud.legislation_code = 'US'
           and pud.upgrade_definition_id = pus.upgrade_definition_id
           and pus.legislation_code = 'US';

  lv_upg_flag       VARCHAR2(20);
  lv_upg_status     varchar2(30);
  ln_upg_defn_id    number;

BEGIN

  hr_utility.trace('Entered into pay_us_rsrw_upgrev.get_upgrade_flag');

  lv_upg_status := NULL;
  ln_upg_defn_id := NULL;

  open get_upg_status;
  fetch get_upg_status into lv_upg_status, ln_upg_defn_id;
  close get_upg_status;

  hr_utility.trace('lv_upg_status := ' || lv_upg_status);
  hr_utility.trace('ln_upg_defn_id := ' || ln_upg_defn_id);

  lv_upg_flag := 'N';

  if NVL(lv_upg_status, 'N') = 'C' then
    lv_upg_flag := 'Y';
  else
    lv_upg_flag := 'N';
  end if;

  hr_utility.trace('Before returning lv_upg_flag := ' || lv_upg_flag);
  return lv_upg_flag;

END get_upgrade_flag;

/*****************************************************************************
  Name        : get_payprd_per_fiscal_yr

  Description : This Function returns number of pay periods in the current
                fiscal year. This can be different from standard number
                of pay periods per fiscal year especially in case of
                "Weekly" and "Bi-Weekly" payroll.
*****************************************************************************/

FUNCTION get_payprd_per_fiscal_yr(p_ctx_bg_id in number
                                 ,p_ctx_payroll_id in number
                                 ,p_eletyp_ctx_id in number
                                 ,p_period_end_date in date) RETURN NUMBER IS


    CURSOR csr_get_ele_xtra_info(cp_eletyp_ctx_id in number)
    IS
      SELECT petei.eei_information11
      FROM pay_element_types_f pet
          ,pay_element_type_extra_info petei
      where pet.element_type_id = cp_eletyp_ctx_id
      and pet.element_type_id = petei.element_type_id
      and petei.information_type = 'US_EARNINGS'
      and petei.eei_information_category = 'US_EARNINGS';

    CURSOR csr_get_prd_num(ctx_bg_id in number
                            ,ctx_payroll_id in number
                            ,period_end_date in date) is
      select max(PTP.period_num)
      from per_time_periods  PTP
          ,pay_payrollS_f    PRL
      where PTP.payroll_id = ctx_payroll_id
        and PTP.payroll_id = PRL.payroll_id
        and PRL.business_group_id = ctx_bg_id
        and to_char(period_end_date, 'YYYY') = to_char(PTP.start_date, 'YYYY');

      CURSOR csr_get_num_prd(ctx_bg_id in number
                            ,ctx_payroll_id in number) IS
            select TPT.number_per_fiscal_year
            from per_time_period_types   TPT,
                 pay_payrolls_f           PRL
            WHERE TPT.period_type	= PRL.period_type
            AND   PRL.business_group_id + 0 = ctx_bg_id
            AND   PRL.payroll_id	= ctx_payroll_id;


      ln_max_period_num NUMBER;
      ln_period_num     NUMBER;
      lv_ele_xtra_info           PAY_ELEMENT_TYPE_EXTRA_INFO.eei_information11%TYPE;

BEGIN

   hr_utility.trace('Entering into pay_us_rsrw_upgrev.get_payprd_per_fiscal_yr');

   lv_ele_xtra_info := NULL;

   open csr_get_ele_xtra_info(cp_eletyp_ctx_id => p_eletyp_ctx_id);
   fetch csr_get_ele_xtra_info into lv_ele_xtra_info;
   close csr_get_ele_xtra_info;

   open csr_get_num_prd(ctx_bg_id => p_ctx_bg_id
                       ,ctx_payroll_id => p_ctx_payroll_id);
   fetch csr_get_num_prd into ln_period_num;
   close csr_get_num_prd;

   hr_utility.trace('ln_period_num := ' || ln_period_num);

   IF NVL(lv_ele_xtra_info, 'N') = 'N' THEN
      return ln_period_num;
   ELSE

      open csr_get_prd_num(ctx_bg_id => p_ctx_bg_id
                          ,ctx_payroll_id => p_ctx_payroll_id
                          ,period_end_date => p_period_end_date);
      fetch csr_get_prd_num into ln_max_period_num;
      close csr_get_prd_num;

      hr_utility.trace('ln_max_period_num := ' || ln_max_period_num);

      return GREATEST(ln_max_period_num, ln_period_num);

   END IF;

END get_payprd_per_fiscal_yr;

/*****************************************************************************
  Name        : get_assignment_status

  Description : This Function checks system status type for assignment
                effective on the prorate_end date passed to it as parameter.
*****************************************************************************/

FUNCTION get_assignment_status(p_ctx_asg_id IN NUMBER
                              ,p_prorate_end_dt IN DATE) RETURN VARCHAR2 IS

      CURSOR csr_get_asg_status(p_ctx_asg_id IN NUMBER
                               ,p_prorate_end_dt IN DATE) IS
      SELECT past.per_system_status
        FROM per_assignments_f paf
            ,per_assignment_status_types past
       WHERE paf.assignment_id = p_ctx_asg_id
         AND paf.assignment_status_type_id = past.assignment_status_type_id
         AND p_prorate_end_dt between paf.effective_start_date and paf.effective_end_date;

       lv_asg_status    per_assignment_status_types.per_system_status%TYPE;

BEGIN
    lv_asg_status := NULL;

    open csr_get_asg_status(p_ctx_asg_id, p_prorate_end_dt);
    fetch csr_get_asg_status into lv_asg_status;
    close csr_get_asg_status;

    hr_utility.trace('lv_asg_status := ' || lv_asg_status);
    return lv_asg_status;

end get_assignment_status;

end pay_us_rsrw_upgrev;

/
