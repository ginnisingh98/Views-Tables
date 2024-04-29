--------------------------------------------------------
--  DDL for Package Body PAY_US_EMPLOYEE_PAYSLIP_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMPLOYEE_PAYSLIP_WEB" 
/* $Header: pyusempw.pkb 120.3.12010000.20 2010/05/04 16:16:33 mikarthi ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : pay_us_employee_payslip_web

    Description : Package contains functions and procedures used
                  by the Online Payslip Views.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    03-May-2010 mikarthi 115.63  9555144 check_emp_personal_payment made generic
                                         which can be used by all localizations
    21-Feb-2010 mikarthi 115.62  9394861 Making sure cursor get_choose_payslip is closed before
                                         opening for the first time
    21-Feb-2010 mikarthi 115.61  9394861 Moved java VO Logic to cursor get_choose_payslip
    21-Feb-2010 mikarthi 115.60  9394861 NOCOPY hint added
    21-Feb-2010 mikarthi 115.59  9394861 Payslip Perf Enhancement
                                         a) New function check_us_emp_personal_payment
                                         b) New Function check_emp_personal_payment
    23-Jul-2009 vijranga  115.58  8522324  Added a new function
                               check_ie_emp_personal_payment
                               and also modified the function
                               check_emp_personal_payment to
                               address purge-payslip issue for IE localisation.
    01-Jul-2009 jvaradra 115.57  8643214 Added a new cursor c_get_business_group_id
                                         and made use of get_legislation_code function.
    28-May-2009 krreddy  115.56  7648285 Added a new function
                                         check_sa_emp_personal_payment
                               and also modified the function
                               check_emp_personal_payment to
                               address purge-payslip issue.
    27-May-2009 mikarthi 115.55  8550075 Modified check_emp_personal_payment
                                         to fix payslip view issue for
                                         supplemental run
    23-Apr-2009 mikarthi 115.54  8245514 Modified get_netpaydistr_segment
    26-Mar-2009 krreddy  115.53      8303577 Modified check_emp_personal_payment
                               to fix the payslip displaying before
                               process completion issue.
    09-Feb-2009 npannamp 115.52  8197823 Modified get_netpaydistr_segment
                                         function to include 'GB' localization
                                         also.
    05-Dec-2008 krreddy  115.51  7171712 Added a new cursor c_get_archived
                               to check whether archive data
                               exists for the current
                               assignment_action_id.
    11-Nov-2008 krreddy  115.50  7171712 Modified the function
                               check_emp_personal_payment to update
                               the validations.
    10-Nov-2008 krreddy  115.49  7171712 Added a new function
                                         check_gb_emp_personal_payment
                               and also modified the function
                               check_emp_personal_payment
    05-MAR-2008 sudedas  115.45  6739242 Added new Function
                                         get_netpaydistr_segment.
    22-SEP-2005 ahanda   115.17  4622911 Added code for SD for Function
                                         "get_full_jurisdiction_name"
    08-SEP-2005 ppanda   115.16          Function "get_full_jurisdiction_name"
                               added to derive the full jurisdiction
                               (State, County, City) using existing
                               function get_jurisdiction_nmame
    07-JUN-2005 ahanda   115.42  4417645 Changed code to check for sysdate
                                         to be greater then payslip offset
                                         to show Payslip
    05-MAY-2005 ahanda   115.41  4246280 Changed Payslip code to check for
                                         View Payslip offset before showing
                                         Payslip for an employee.
                                         Added overloaded function -
                                         check_emp_personal_payment with
                                         parameter of p_time_period_id
    22-FEB-2005 sodhingr 115.40  4186737 changed the get_term_info to use
                                         format_to_date function to compare the
                                         date.
    17-FEB-2005 sodhingr 115.39  4186737 changed get_term_info to fix the error
                                         due to date format.
    28-JAN-2005 sodhingr 115.38  4132132 Changed get_term_info to stop the
                                         payslip if the terminationdate = period
                                         end date
    19-JAN-2005 sodhingr 115.37  4132132 Changed the function get_term_info
    24-AUG-2004 rsethupa 115.36  3722370 Changed cursor c2 in function
                                         get_term_info. This will select 'Y' for
                               all pay periods upto actual termination
                               date.
    27-MAY-2004 rsethupa 115.35  3487250 Changed cursor c_currency_code to
                                         fetch by hou.organization_id instead
                               of hou.business_group_id
    28-MAR-2004 ahanda   115.34          Changed check_emp_personal_payment
                                         to check if archiver is locking
                                         prepay or run action.
    07-JAN-2004 kaverma  115.33  3350023 Modified cursor c_hourly_salary to remove
                                         MERGE JOIN CARTESIAN
    22-DEC-2003 ahanda   115.32  3331020 Changed cursor c_check_for_reversal.
    06-Nov-2003 pganguly 115.31          Changed the procedure get_term_info
                                         so that it caches the legislation
                                         _code, legislation_rule.
    18-Sep-2003 sdahiya  115.30  2976050 Modified the
                                         check_emp_personal_payment procedure
                                         so that it calls
                                         get_payment_status_code
                                         instead of get_payment_status.
    02-Sep-2003 meshah   115.29  3124483 using actual_termination_date instead
                                         of final_prcess_date.
    02-Sep-2003 meshah   115.28  3124483 the cursor get_person_info in
                                         get_doc_eit function has been changed.
                                         Now joining to per_periods_of_service
                                         to find out if the employee is
                                         terminated.
    19-JUL-2003 ahanda   115.27          Added function format_to_date.
    23-May-03   ekim     115.26  2897743 Added c_get_lookup_for_paid.
    30-APR-03   asasthan 115.25  2925411 Added to_char in c_check_number
                                         cursor
    07-Feb-03   ekim     115.24  2716253 Performance fix on c_regular_salary.
    23-JAN-2002 ahanda   115.23  2764088 Changed cursor get_bg_eit in
                                         function get_doc_eit for performance.
    15-NOV-2002 ahanda   115.22          Modified function get_jurisdiction_name
                                         Changed c_get_state to return
                                         state_abbrev.
    14-NOV-2002 tclewis  115.21          Modified the order of parameters
                                         on the get_check_number function
                                         now pass pp_ass_act , pre_pay_id.
    21-OCT-2002 tclewis  115.19          changed get_check_no, to return a
                                         deposit advice number.  Either,
                                         pre-payment assignment action id
                                         for Master payment or Run AAID for
                                         the sep payment AAID.
    09-OCT-2002 ahanda   115.18  2474524 Changed check_emp_personal_payment
    15-AUG-2002 ahanda   115.17          Changed get_proposed_emp_salary for
                                         performance.
    18-JUL-2002 ahanda   115.16          Changed the get_jurisdiction_name
                                         function to return NULL is not a US
                                         jurisdiction.
    16-JUN-2002 sodhingr 115.15          Added a new function get_term_info
                                         to check
                                         the terminated employee based
                                         on the legislation_field_info

    13-MAY-2002 pganguly 115.13  2363857 Added a new function
                                         get_legislation_code.
    01-MAY-2002 ahanda   115.12  2352332 Changed get_check_number to check
                                         for Void.
    23-MAR-2002 ahanda   115.11          Fixed compilation errors
    22-MAR-2002 ekim     115.10          Removed trace_on.
    21-MAR-2002 ekim     115.9           Changed get_doc_eit function.
    15-FEB-2002 ahanda   115.7   2229092 Changed get_check_number to check for
                                         External Manual Payments.
    24_JAN-2002 dgarg    115.6           Added get_jurisdiction_name
                                         function.
    05-OCT-2001 ekim     115.5           Added get_doc_eit function.
    21-SEP-2001 ekim     115.4           Added get_format_value function.
    17-SEP-2001 assathan 115.3           Added get_check_number for payslip
    09-FEB-2001 ahanda   115.2           Changed the procedure
                                         check_emp_personal_payment for
                                         performance.
    14-DEC-2000 ahanda   115.1  1343941/ Changed the procedure
                                1494453  check_emp_personal_payment to go of pre
                                         payments instead of personal payment
                                         methods. This will also fix issue of
                                         Payslip not printing Zero net.
    10-FEB-2000 ahanda   115.0           Changed proposed_salary to
                                         proposed_salary_n for function
                                         get_proposed_emp_salary.
    ****************************************************************************
    01-FEB-2000 ahanda   110.3           Changed function to get School Dst
                                         Name from city if it is not there
                                         in county dsts table.
    01-FEB-2000 ahanda   110.2           Added function to get School Dst Name.
    24-DEC-1999 ahanda   110.1  1117470  Changed get_proposed_emp_salary to get
                                1116604  proposed salary effective on period end
                                         date. Changed the check_for_paid cursor
                                         to check for if checkwriter has been
                                         locked for of Void Pymt and Run in
                                         case of Reversal.
    01-JUL-1999 ahanda   110.0           Created.
  ****************************************************************************/
  AS

  gv_package VARCHAR2(100);

  -- Added for Testing
 /*****************************************************************************
  **        Name: FUNCTION check_emp_personal_payment
  **   Arguments: p_assignment_id        => Assignemnt ID
  **              p_payroll_id           => Payroll ID
  **              p_time_period_id       => Time Period ID
  **              p_assignment_action_id => See below for details
  **              p_effective_date       => Payment Date
  **              p_payment_category     => Payment Category
  **              p_legislation_code     => Territory_code
  ** Description: Overloaded function with the parameter for time_period_id
  **
  **              Function to find out if all the personal payment methods
  **              for the employee have been processed.
  **
  **              The function returns 'Y' if the Payroll has been processed
  **              completely i.e.
  **              Payroll Run   -> Quick Pay Pre-Payment -> Check Writer/BACS
  **              Quick Payment -> Pre-Payment           -> Nacha/ Ext. Manual Payment
  **
  **              If the Payroll has been revered the function returns 'N'
  **
  **              Assignment_action_id passed to it can be the action for
  **              archive process or payroll run. Both both action, we get
  **              the prepayment_action_id and use it to check payment methods.
  **
  *****************************************************************************/
  FUNCTION check_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_time_period_id       number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  ,p_payment_category     varchar2
                  ,p_legislation_code     varchar2
                  )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    cursor c_view_offset(cp_time_period_id in number) is
      select payslip_view_date
        from per_time_periods ptp
       where time_period_id = cp_time_period_id;

    /* Cursor to get the how employee is paid */
    cursor c_pre_payment_method
                    (cp_assignment_action_id number
                    ,cp_payment_category varchar2
                    ,cp_legislation_code varchar2) is
      select ppp.pre_payment_id
        from pay_payment_types ppt,
             pay_org_payment_methods_f popm,
             pay_pre_payments ppp
       where ppp.assignment_action_id = cp_assignment_action_id
         and popm.org_payment_method_id = ppp.org_payment_method_id
         and popm.defined_balance_id is not null
         and ppt.payment_type_id = popm.payment_type_id
         and ppt.category = cp_payment_category
         and ppt.territory_code = cp_legislation_code;


    cursor c_check_for_reversal(cp_assignment_action_id in number) is
      select 1
        from pay_action_interlocks pai_pre
       where pai_pre.locking_action_id = cp_assignment_action_id
         and exists (
                 select 1
                   from pay_payroll_actions ppa,
                        pay_assignment_actions paa,
                        pay_action_interlocks pai_run
                        /* Get the run assignment action id locked by pre-payment */
                  where pai_run.locked_action_id = pai_pre.locked_action_id
                        /* Check if the Run is being locked by Reversal */
                    and pai_run.locking_action_id = paa.assignment_action_id
                    and ppa.payroll_action_id = paa.payroll_action_id
                    and paa.action_status = 'C'
                    and ppa.action_type = 'V');

    /****************************************************************
    ** If archiver is locking the pre-payment assignment_action_id,
    ** we get it from interlocks and use it to check if all payments
    ** have been made fro the employee.
    ****************************************************************/
    cursor c_prepay_arch_action(cp_assignment_action_id in number) is
      select paa.assignment_action_id
        from pay_action_interlocks paci,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where paci.locking_action_id = cp_assignment_action_id
         and paa.assignment_action_id = paci.locked_action_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('P', 'U');

    /****************************************************************
    ** If archiver is locking the run assignment_action_id, we get
    ** the corresponding run assignment_action_id and then get
    ** the pre-payment assignemnt_action_id.
    ** This cursor is only required when there are child action which
    ** means there is a seperate check.
    * ***************************************************************/
    cursor c_prepay_run_arch_action(cp_assignment_action_id in number) is
      select paa_pre.assignment_action_id
        from pay_action_interlocks pai_run,
             pay_action_interlocks pai_pre,
             pay_assignment_actions paa_pre,
             pay_payroll_actions ppa_pre
       where pai_run.locking_action_id = cp_assignment_action_id
         and pai_pre.locked_action_id = pai_run.locked_action_id
         and paa_pre.assignment_Action_id = pai_pre.locking_action_id
         and ppa_pre.payroll_action_id = paa_pre.payroll_action_id
         and ppa_pre.action_type in ('P', 'U');

    cursor c_get_date_earned(cp_assignment_action_id in number) is
      select nvl(max(ppa.date_earned), max(ppa.effective_date))
        from pay_payroll_actions ppa
            ,pay_assignment_actions paa
            ,pay_action_interlocks pai
       where ppa.payroll_action_id = paa.payroll_action_id
         and pai.locked_action_id = paa.assignment_action_id
         and pai.locking_action_id = cp_assignment_action_id
         and ppa.action_type in ('R', 'Q', 'B', 'V');

    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

   cursor c_no_prepayments (cp_prepayment_action_id in number) is
     select 1
       from dual
      where not exists
                 (select 1
                from pay_pre_payments ppp
               where ppp.assignment_action_id = cp_prepayment_action_id
             );

    lv_reversal_exists          VARCHAR2(1);
    ln_prepay_action_id         NUMBER;
    ln_pre_payment_id           NUMBER;
    lv_payment_status           VARCHAR2(50);
    lv_paid_lookup_meaning      VARCHAR2(10);
    lv_return_flag              VARCHAR2(1);
    lc_no_prepayment_flag       VARCHAR2(1);

    ld_view_payslip_offset_date DATE;
    ld_earned_date              DATE;
    ln_time_period_id           NUMBER;

  BEGIN

  hr_utility.trace('Entering check_emp_personal_payment');
  hr_utility.trace('p_effective_date='||p_effective_date);
  hr_utility.trace('p_time_period_id='||p_time_period_id);

  IF p_payment_category IS NOT NULL THEN

    lv_return_flag := 'Y';
    open c_prepay_arch_action(p_assignment_action_id);
    fetch c_prepay_arch_action into ln_prepay_action_id;
    if c_prepay_arch_action%notfound then
       open c_prepay_run_arch_action(p_assignment_action_id);
       fetch c_prepay_run_arch_action into ln_prepay_action_id;
       if c_prepay_run_arch_action%notfound then
          return('N');
       end if;
       close c_prepay_run_arch_action;
    end if;
    close c_prepay_arch_action;

    ln_time_period_id := p_time_period_id;
    if ln_time_period_id is null then
       open c_get_date_earned(ln_prepay_action_id);
       fetch c_get_date_earned into ld_earned_date;
       if c_get_date_earned%found then
          open c_time_period(p_payroll_id, ld_earned_date);
          fetch c_time_period into ln_time_period_id;
          close c_time_period;
       end if;
       close c_get_date_earned;
    end if;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    open c_view_offset(ln_time_period_id);
    fetch c_view_offset into ld_view_payslip_offset_date;
    close c_view_offset;
    hr_utility.trace('ld_view_payslip_offset_date='||trunc(ld_view_payslip_offset_date));
    hr_utility.trace('p_effective_date='||trunc(p_effective_date));
    hr_utility.trace('sysdate='||trunc(sysdate));

    /* check if the Payslip view date is populated. If it is, check the value
       and make sure it is > sysdate otherwise don't show payslip */
    if ld_view_payslip_offset_date is not null and
       trunc(ld_view_payslip_offset_date) > trunc(sysdate) then
       hr_utility.trace('View offset return N');
       return('N');
    end if;

    open c_check_for_reversal(ln_prepay_action_id);
    fetch c_check_for_reversal into lv_reversal_exists;
    if c_check_for_reversal%found then
       lv_return_flag := 'N';
    else
       open c_pre_payment_method (ln_prepay_action_id
                                 ,p_payment_category
                                 ,p_legislation_code);
       loop
          /* fetch all the pre payment records for the asssignment
             other than 3rd party payment */
          fetch c_pre_payment_method into ln_pre_payment_id;

          if c_pre_payment_method%notfound then
             exit;
          end if;

          lv_payment_status := ltrim(rtrim(
                                  pay_assignment_actions_pkg.get_payment_status_code
                                       (ln_prepay_action_id,
                                        ln_pre_payment_id)));

          if lv_payment_status <> 'P' then
             lv_return_flag := 'N';
             exit;
          else
             lv_return_flag := 'Y';
          end if;

       end loop;
       IF lv_payment_status IS NULL THEN
          lv_return_flag := 'N' ;
       END IF ;
       close c_pre_payment_method;

    end if;
    close c_check_for_reversal;

    IF p_payment_category = 'MT' and p_legislation_code = 'US' THEN
      OPEN c_no_prepayments(ln_prepay_action_id);
      FETCH c_no_prepayments INTO lc_no_prepayment_flag;
      IF c_no_prepayments%found THEN
         lv_return_flag := 'Y';
      END IF;
      CLOSE c_no_prepayments;
    END IF;

    hr_utility.trace('lv_return_flag='||lv_return_flag);
    hr_utility.trace('Leaving check_emp_personal_payment');

    return lv_return_flag;
  ELSE
    return(check_emp_personal_payment(
           p_assignment_id        => p_assignment_id
          ,p_payroll_id           => p_payroll_id
          ,p_time_period_id       => p_time_period_id
          ,p_assignment_action_id => p_assignment_action_id
          ,p_effective_date       => p_effective_date));
  END IF;
  END check_emp_personal_payment;

--Start of changes
    /****************************************************************
    ** Below function is added for the bug# 7171712.
    ** It returns 'N' if offset date exists and its greater than
    ** sysdate.
    *****************************************************************/

FUNCTION check_gb_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_time_period_id       number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    cursor c_view_offset(cp_time_period_id in number) is
      select payslip_view_date
        from per_time_periods ptp
       where time_period_id = cp_time_period_id;

    /* Cursor to get date earned for a payroll */
    cursor c_get_date_earned(cp_assignment_action_id in number) is
      select max(effective_date)
        from pay_action_information
       where action_context_id = cp_assignment_action_id
         and action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION';

    /* Cursor to get time period for a payroll */
    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

    /* Cursor to check whether archive data exists or not*/
    cursor c_get_archived is
         select count(*)
           from pay_action_information
          where action_context_id = p_assignment_action_id
            and action_information_category ='GB ELEMENT PAYSLIP INFO';

    lv_return_flag              VARCHAR2(1);
    ld_view_payslip_offset_date DATE;
    ld_earned_date              DATE;
    ln_time_period_id           NUMBER;
    ln_count                    NUMBER;

  BEGIN
    hr_utility.trace('Entering check_gb_emp_personal_payment');
    hr_utility.trace('p_assignment_id='||p_assignment_id);
    hr_utility.trace('p_payroll_id='||p_payroll_id);
    hr_utility.trace('p_assignment_action_id='||p_assignment_action_id);
    hr_utility.trace('p_effective_date='||p_effective_date);
    hr_utility.trace('p_time_period_id='||p_time_period_id);

    lv_return_flag := 'Y';

    ln_time_period_id := p_time_period_id;
    if ln_time_period_id is null then
       open c_get_date_earned(p_assignment_action_id);
       fetch c_get_date_earned into ld_earned_date;
       if c_get_date_earned%found then
          open c_time_period(p_payroll_id, ld_earned_date);
          fetch c_time_period into ln_time_period_id;
          close c_time_period;
       end if;
       close c_get_date_earned;
    end if;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    open c_view_offset(ln_time_period_id);
    fetch c_view_offset into ld_view_payslip_offset_date;
    close c_view_offset;
    hr_utility.trace('ld_view_payslip_offset_date='||trunc(ld_view_payslip_offset_date));
    hr_utility.trace('p_effective_date='||trunc(p_effective_date));
    hr_utility.trace('sysdate='||trunc(sysdate));

    /* check if the Payslip view date is populated. If it is, check the value
       and make sure it is > sysdate otherwise don't show payslip */
    if ld_view_payslip_offset_date is not null and
       trunc(ld_view_payslip_offset_date) > trunc(sysdate) then
       hr_utility.trace('View offset return N');
       return('N');
    end if;

    ln_count := 0;
    open c_get_archived;
    fetch c_get_archived into ln_count;
    /*Check whether archive data exists for this assignment_action_id*/
        if (ln_count = 0)
            then return('N');
        end if;
    close c_get_archived;

    hr_utility.trace('lv_return_flag='||lv_return_flag);
    hr_utility.trace('Leaving check_gb_emp_personal_payment');

    return lv_return_flag;

  END check_gb_emp_personal_payment;

--Start of changes
    /****************************************************************
    ** Below function is added for the bug# 7648285.
    ** It returns 'N' if offset date exists and its greater than
    ** sysdate.
    *****************************************************************/

FUNCTION check_sa_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_time_period_id       number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    cursor c_view_offset(cp_time_period_id in number) is
      select payslip_view_date
        from per_time_periods ptp
       where time_period_id = cp_time_period_id;

    /* Cursor to get date earned for a payroll */
    cursor c_get_date_earned(cp_assignment_action_id in number) is
      select max(effective_date)
        from pay_action_information
       where action_context_id = cp_assignment_action_id
         and action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION';

    /* Cursor to get time period for a payroll */
    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

    /* Cursor to check whether archive data exists or not*/
    cursor c_get_archived is
         select count(*)
           from pay_action_information
          where action_context_id = p_assignment_action_id
            and action_information_category = 'EMEA ELEMENT INFO'
                  and action_information3 in ('E','D');

    lv_return_flag              VARCHAR2(1);
    ld_view_payslip_offset_date DATE;
    ld_earned_date              DATE;
    ln_time_period_id           NUMBER;
    ln_count                    NUMBER;

  BEGIN
    hr_utility.trace('Entering check_sa_emp_personal_payment');
    hr_utility.trace('p_assignment_id='||p_assignment_id);
    hr_utility.trace('p_payroll_id='||p_payroll_id);
    hr_utility.trace('p_assignment_action_id='||p_assignment_action_id);
    hr_utility.trace('p_effective_date='||p_effective_date);
    hr_utility.trace('p_time_period_id='||p_time_period_id);

    lv_return_flag := 'Y';

    ln_time_period_id := p_time_period_id;
    if ln_time_period_id is null then
       open c_get_date_earned(p_assignment_action_id);
       fetch c_get_date_earned into ld_earned_date;
       if c_get_date_earned%found then
          open c_time_period(p_payroll_id, ld_earned_date);
          fetch c_time_period into ln_time_period_id;
          close c_time_period;
       end if;
       close c_get_date_earned;
    end if;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    open c_view_offset(ln_time_period_id);
    fetch c_view_offset into ld_view_payslip_offset_date;
    close c_view_offset;
    hr_utility.trace('ld_view_payslip_offset_date='||trunc(ld_view_payslip_offset_date));
    hr_utility.trace('p_effective_date='||trunc(p_effective_date));
    hr_utility.trace('sysdate='||trunc(sysdate));

    /* check if the Payslip view date is populated. If it is, check the value
       and make sure it is > sysdate otherwise don't show payslip */
    if ld_view_payslip_offset_date is not null and
       trunc(ld_view_payslip_offset_date) > trunc(sysdate) then
       hr_utility.trace('View offset return N');
       return('N');
    end if;

    ln_count := 0;
    open c_get_archived;
    fetch c_get_archived into ln_count;
    /*Check whether archive data exists for this assignment_action_id*/
        if (ln_count = 0)
            then return('N');
        end if;
    close c_get_archived;

    hr_utility.trace('lv_return_flag='||lv_return_flag);
    hr_utility.trace('Leaving check_sa_emp_personal_payment');

    return lv_return_flag;

  END check_sa_emp_personal_payment;

--8522324 fix start
    /****************************************************************
    ** Below function is added for the bug# 8522324.
    ** It returns 'N' if offset date exists and its greater than
    ** sysdate.
    *****************************************************************/

FUNCTION check_ie_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_time_period_id       number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    cursor c_view_offset(cp_time_period_id in number) is
      select payslip_view_date
        from per_time_periods ptp
       where time_period_id = cp_time_period_id;

    /* Cursor to get date earned for a payroll */
    cursor c_get_date_earned(cp_assignment_action_id in number) is
      select max(effective_date)
        from pay_action_information
       where action_context_id = cp_assignment_action_id
         and action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION';

    /* Cursor to get time period for a payroll */
    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

    /* Cursor to check whether archive data exists or not*/
    cursor c_get_archived is
         select count(*)
           from pay_action_information
          where action_context_id = p_assignment_action_id
            and action_information_category = 'EMEA ELEMENT INFO'
                  and action_information3 in ('E','D');

    lv_return_flag              VARCHAR2(1);
    ld_view_payslip_offset_date DATE;
    ld_earned_date              DATE;
    ln_time_period_id           NUMBER;
    ln_count                    NUMBER;

  BEGIN
    hr_utility.trace('Entering check_ie_emp_personal_payment');
    hr_utility.trace('p_assignment_id='||p_assignment_id);
    hr_utility.trace('p_payroll_id='||p_payroll_id);
    hr_utility.trace('p_assignment_action_id='||p_assignment_action_id);
    hr_utility.trace('p_effective_date='||p_effective_date);
    hr_utility.trace('p_time_period_id='||p_time_period_id);

    lv_return_flag := 'Y';

    ln_time_period_id := p_time_period_id;
    if ln_time_period_id is null then
       open c_get_date_earned(p_assignment_action_id);
       fetch c_get_date_earned into ld_earned_date;
       if c_get_date_earned%found then
          open c_time_period(p_payroll_id, ld_earned_date);
          fetch c_time_period into ln_time_period_id;
          close c_time_period;
       end if;
       close c_get_date_earned;
    end if;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    open c_view_offset(ln_time_period_id);
    fetch c_view_offset into ld_view_payslip_offset_date;
    close c_view_offset;
    hr_utility.trace('ld_view_payslip_offset_date='||trunc(ld_view_payslip_offset_date));
    hr_utility.trace('p_effective_date='||trunc(p_effective_date));
    hr_utility.trace('sysdate='||trunc(sysdate));

    /* check if the Payslip view date is populated. If it is, check the value
       and make sure it is > sysdate otherwise don't show payslip */
    if ld_view_payslip_offset_date is not null and
       trunc(ld_view_payslip_offset_date) > trunc(sysdate) then
       hr_utility.trace('View offset return N');
       return('N');
    end if;

    ln_count := 0;
    open c_get_archived;
    fetch c_get_archived into ln_count;
    /*Check whether archive data exists for this assignment_action_id*/
        if (ln_count = 0)
            then return('N');
        end if;
    close c_get_archived;

    hr_utility.trace('lv_return_flag='||lv_return_flag);
    hr_utility.trace('Leaving check_ie_emp_personal_payment');

    return lv_return_flag;

  END check_ie_emp_personal_payment;
--8522324 fix end

  /*****************************************************************************
  **        Name: FUNCTION check_emp_personal_payment
  **   Arguments: p_assignment_id        => Assignemnt ID
  **              p_payroll_id           => Payroll ID
  **              p_time_period_id       => Time Period ID
  **              p_assignment_action_id => See below for details
  **              p_effective_date       => Payment Date
  ** Description: Overloaded function with the parameter for time_period_id
  **
  **              Function to find out if all the personal payment methods
  **              for the employee have been processed.
  **
  **              The function returns 'Y' if the Payroll has been processed
  **              completely i.e.
  **              Payroll Run   -> Quick Pay Pre-Payment -> Check Writer/BACS
  **              Quick Payment -> Pre-Payment           -> Nacha/ Ext. Manual Payment
  **
  **              If the Payroll has been revered the function returns 'N'
  **
  **              Assignment_action_id passed to it can be the action for
  **              archive process or payroll run. Both both action, we get
  **              the prepayment_action_id and use it to check payment methods.
  **
  *****************************************************************************/
  FUNCTION check_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_time_period_id       number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    --Added REGULAR_PAYMENT_DATE for bug 8550075
  CURSOR c_view_offset(cp_time_period_id IN NUMBER) IS
    SELECT payslip_view_date, REGULAR_PAYMENT_DATE
      FROM per_time_periods ptp
     WHERE time_period_id = cp_time_period_id;

    /* Cursor to get the how employee is paid */
    cursor c_pre_payment_method
                    (cp_assignment_action_id number) is
      select ppp.pre_payment_id
        from pay_payment_types ppt,
             pay_org_payment_methods_f popm,
             pay_pre_payments ppp
       where ppp.assignment_action_id = cp_assignment_action_id
         and popm.org_payment_method_id = ppp.org_payment_method_id
         and popm.defined_balance_id is not null
         and ppt.payment_type_id = popm.payment_type_id;


    cursor c_check_for_reversal(cp_assignment_action_id in number) is
      select 1
        from pay_action_interlocks pai_pre
       where pai_pre.locking_action_id = cp_assignment_action_id
         and exists (
                 select 1
                   from pay_payroll_actions ppa,
                        pay_assignment_actions paa,
                        pay_action_interlocks pai_run
                        /* Get the run assignment action id locked by pre-payment */
                  where pai_run.locked_action_id = pai_pre.locked_action_id
                        /* Check if the Run is being locked by Reversal */
                    and pai_run.locking_action_id = paa.assignment_action_id
                    and ppa.payroll_action_id = paa.payroll_action_id
                    and paa.action_status = 'C'
                    and ppa.action_type = 'V');

    /****************************************************************
    ** If archiver is locking the pre-payment assignment_action_id,
    ** we get it from interlocks and use it to check if all payments
    ** have been made fro the employee.
    ****************************************************************/
    cursor c_prepay_arch_action(cp_assignment_action_id in number) is
      select paa.assignment_action_id
        from pay_action_interlocks paci,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where paci.locking_action_id = cp_assignment_action_id
         and paa.assignment_action_id = paci.locked_action_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('P', 'U');

    /****************************************************************
    ** If archiver is locking the run assignment_action_id, we get
    ** the corresponding run assignment_action_id and then get
    ** the pre-payment assignemnt_action_id.
    ** This cursor is only required when there are child action which
    ** means there is a seperate check.
    * ***************************************************************/
    cursor c_prepay_run_arch_action(cp_assignment_action_id in number) is
      select paa_pre.assignment_action_id
        from pay_action_interlocks pai_run,
             pay_action_interlocks pai_pre,
             pay_assignment_actions paa_pre,
             pay_payroll_actions ppa_pre
       where pai_run.locking_action_id = cp_assignment_action_id
         and pai_pre.locked_action_id = pai_run.locked_action_id
         and paa_pre.assignment_Action_id = pai_pre.locking_action_id
         and ppa_pre.payroll_action_id = paa_pre.payroll_action_id
         and ppa_pre.action_type in ('P', 'U');

  --Modified Cursor for bug 8550075
  CURSOR c_get_date_earned(cp_assignment_action_id IN NUMBER) IS
    SELECT nvl(MAX(ppa.date_earned), MAX(ppa.effective_date)), MAX(ppa.effective_date), BUSINESS_GROUP_ID
      FROM pay_payroll_actions ppa
          , pay_assignment_actions paa
          , pay_action_interlocks pai
     WHERE ppa.payroll_action_id = paa.payroll_action_id
       AND pai.locked_action_id = paa.assignment_action_id
       AND pai.locking_action_id = cp_assignment_action_id
       AND ppa.action_type IN ('R', 'Q', 'B', 'V')
               GROUP BY BUSINESS_GROUP_ID;

    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

    /****************************************************************
    ** Below cursor added for bug 7171712 returns true, if purge is run
    ** corresponding to the current assignment id.
    *****************************************************************/

     cursor c_purge_run(cp_assignment_action_id in number) is
            select 1
              from pay_assignment_actions paa
             where paa.assignment_action_id = cp_assignment_action_id
               and not exists
                  (select 1
                     from pay_action_interlocks ai
                    where ai.locking_action_id = paa.assignment_action_id )
               and exists
                   (select 1 from pay_assignment_actions paa2,
                           pay_payroll_actions ppa2
                     where paa2.assignment_id = paa.assignment_id
                       and paa2.payroll_action_id = ppa2.payroll_action_id
                       and ppa2.action_type = 'Z');

    /****************************************************************
    ** Below cursor added for bug 7171712 gets the localization code for the
    ** corresponding assignment id.
    *****************************************************************/

     cursor c_get_localization(cp_assignment_id in number) is
         select legislation_code
           from per_business_groups
          where business_group_id in
                (select business_group_id
                   from per_all_people_f
                  where person_id in
                       (select person_id
                          from per_all_assignments_f
                         where assignment_id = cp_assignment_id));

    /****************************************************************
    ** Below cursor added for bug 8643214 gets the business group id
    *****************************************************************/

     cursor c_get_business_group_id (cp_payroll_id in number) is
         select business_group_id
           from pay_all_payrolls_f
          where payroll_id = cp_payroll_id
            and p_effective_date between effective_start_date and effective_end_date;

    /****************************************************************
    ** Below cursor added for bug 8303577 gets the status whether
    ** payslip generation - self service process is completed or not.
    *****************************************************************/

    cursor c_get_completion_status(cp_assignment_action_id in number) is
        select 1
              from pay_assignment_actions paa,
                   pay_payroll_actions ppa
             where paa.assignment_action_id = cp_assignment_action_id
               and paa.payroll_action_id = ppa.payroll_action_id
               and paa.assignment_id = p_assignment_id
               and paa.action_status = 'C'
               and ppa.action_status = 'C';

    lv_reversal_exists          VARCHAR2(1);
    ln_prepay_action_id         NUMBER;
    ln_pre_payment_id           NUMBER;
    lv_payment_status           VARCHAR2(50);
    lv_paid_lookup_meaning      VARCHAR2(10);
    lv_return_flag              VARCHAR2(1);
    lv_gb_return_flag           VARCHAR2(1);
    lv_sa_return_flag           VARCHAR2(1);
    lv_ie_return_flag           VARCHAR2(1);

    ld_view_payslip_offset_date DATE;
    ld_date_paid DATE;
    ld_reg_payment_date DATE;
    ld_earned_date              DATE;
    ln_time_period_id           NUMBER;
    ln_localization_code        VARCHAR2(10);
    ln_offset_value NUMBER;

    ld_payslip_view_date    DATE;
    ln_bg_id                NUMBER;
    is_dynamic_view_date VARCHAR2(1);
    lv_purge_run                VARCHAR2(1);
    lv_completion_status        number;         -- Added for the bug 8303577

    ln_business_group_id    NUMBER;  -- Added for bug 8643214

  --New cursor defined for bug 8550075
  CURSOR c_get_view_date_criteria (cp_bg_id IN NUMBER) IS
    SELECT 'Y' FROM hr_organization_information hoi
  WHERE hoi.organization_id = cp_bg_id
   AND hoi.org_information_context = 'HR_SELF_SERVICE_BG_PREFERENCE'
       AND ORG_INFORMATION12 = 'DATE_PAID'
       AND ORG_INFORMATION1 = 'PAYSLIP';

  BEGIN

    hr_utility.trace('Entering check_emp_personal_payment');
    hr_utility.trace('p_effective_date='||p_effective_date);
    hr_utility.trace('p_time_period_id='||p_time_period_id);

   -- BEGIN For bug 8643214
   open c_get_business_group_id(p_payroll_id);
   fetch c_get_business_group_id into ln_business_group_id;
   close c_get_business_group_id;

   hr_utility.trace('ln_business_group_id='||ln_business_group_id);

   ln_localization_code := get_legislation_code(ln_business_group_id);

   hr_utility.trace('ln_localization_code='||ln_localization_code);

   -- END For bug 8643214

    lv_return_flag := 'Y';
    lv_gb_return_flag := 'Y';

    open c_prepay_arch_action(p_assignment_action_id);
    fetch c_prepay_arch_action into ln_prepay_action_id;
    if c_prepay_arch_action%notfound then
       open c_prepay_run_arch_action(p_assignment_action_id);
       fetch c_prepay_run_arch_action into ln_prepay_action_id;
       if c_prepay_run_arch_action%notfound then
--Start of changes for bug# 7171712
            open c_purge_run(p_assignment_action_id);
            fetch c_purge_run into lv_purge_run;
            if c_purge_run%found then
                -- Commented for bug 8643214
                /*open c_get_localization(p_assignment_id);
                  fetch c_get_localization into ln_localization_code; */

                   hr_utility.trace('c_purge_run%found');

                    if (ln_localization_code = 'GB') then
                        lv_gb_return_flag :=
                        check_gb_emp_personal_payment(
                        p_assignment_id
                         ,p_payroll_id
                         ,p_time_period_id
                        ,p_assignment_action_id
                        ,p_effective_date
                         );
                        if (lv_gb_return_flag = 'Y') then
                            hr_utility.trace('lv_gb_return_flag='||lv_gb_return_flag);
                            return('Y');
                        else
                            hr_utility.trace('lv_gb_return_flag='||lv_gb_return_flag);
                            return('N');
                        end if;
                    end if;

--Start modifications for the bug# 7648285
                    if (ln_localization_code = 'SA') then
                        lv_sa_return_flag :=
                        check_sa_emp_personal_payment(
                        p_assignment_id
                        ,p_payroll_id
                        ,p_time_period_id
                        ,p_assignment_action_id
                        ,p_effective_date
                         );
                        if (lv_sa_return_flag = 'Y') then
                            hr_utility.trace('lv_sa_return_flag='||lv_sa_return_flag);
                            return('Y');
                        else
                            hr_utility.trace('lv_sa_return_flag='||lv_sa_return_flag);
                            return('N');
                        end if;
                    end if;
--End modifications for the bug# 7648285

--Start modifications for the bug# 8522324
                    if (ln_localization_code = 'IE') then
                        lv_ie_return_flag :=
                        check_ie_emp_personal_payment(
                        p_assignment_id
                        ,p_payroll_id
                        ,p_time_period_id
                        ,p_assignment_action_id
                        ,p_effective_date
                         );
                        if (lv_ie_return_flag = 'Y') then
                            hr_utility.trace('lv_ie_return_flag='||lv_ie_return_flag);
                            return('Y');
                        else
                            hr_utility.trace('lv_ie_return_flag='||lv_ie_return_flag);
                            return('N');
                        end if;
                    end if;
--End modifications for the bug# 8522324
              -- Commented for bug 8643214
                /*close c_get_localization; */
            end if;
            close c_purge_run;
            return('N');
--End of changes for bug# 7171712
       end if;
       close c_prepay_run_arch_action;
    end if;
    close c_prepay_arch_action;

    ln_time_period_id := p_time_period_id;
    if ln_time_period_id is null then
       open c_get_date_earned(ln_prepay_action_id);
      FETCH c_get_date_earned INTO ld_earned_date, ld_date_paid, ln_bg_id;
       if c_get_date_earned%found then
          open c_time_period(p_payroll_id, ld_earned_date);
          fetch c_time_period into ln_time_period_id;
          close c_time_period;
       end if;
       close c_get_date_earned;
    end if;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    open c_view_offset(ln_time_period_id);
    FETCH c_view_offset INTO ld_view_payslip_offset_date, ld_reg_payment_date;
    close c_view_offset;
    hr_utility.trace('ld_view_payslip_offset_date='||trunc(ld_view_payslip_offset_date));
    hr_utility.trace('p_effective_date='||trunc(p_effective_date));
    hr_utility.trace('sysdate='||trunc(sysdate));


--Commented out for bug 8550075. This has been handled below
    /* check if the Payslip view date is populated. If it is, check the value
       and make sure it is > sysdate otherwise don't show payslip */
    /*if ld_view_payslip_offset_date is not null and
       trunc(ld_view_payslip_offset_date) > trunc(sysdate) then
       hr_utility.trace('View offset return N');
       return('N');
    end if;*/

    --Starting Fix for bug 8550075
      /* If for US legislation, in the self service preference, offset_criteria
      is set as "Date Paid", then calclate the payslip view date using Date_paid
      of the payroll run. Else go with the default behaviour*/
    IF ld_date_paid IS NULL THEN
      OPEN c_get_date_earned(ln_prepay_action_id);
      FETCH c_get_date_earned INTO ld_earned_date, ld_date_paid, ln_bg_id;
      CLOSE c_get_date_earned;
    END IF;


    IF ld_view_payslip_offset_date IS NOT NULL THEN

      IF ln_bg_id IS NOT NULL THEN
        OPEN c_get_view_date_criteria(ln_bg_id);
        FETCH c_get_view_date_criteria INTO is_dynamic_view_date;
            CLOSE c_get_view_date_criteria;
      END IF;

        if g_legislation_code is null then
            g_legislation_code := get_legislation_code(ln_bg_id);
        end if;

      hr_utility.TRACE('g_legislation_code=' || g_legislation_code);
        hr_utility.TRACE('is_dynamic_view_date=' || is_dynamic_view_date);

        --If Date_paid preference is set and legislation_code is 'US'
      IF is_dynamic_view_date = 'Y' AND ld_date_paid IS NOT NULL  and g_legislation_code = 'US' THEN

        ln_offset_value := trunc(ld_view_payslip_offset_date - ld_reg_payment_date);

        hr_utility.TRACE('ln_offset_value=' || ln_offset_value);
        hr_utility.TRACE('ld_view_payslip_offset_date=' || ld_view_payslip_offset_date);

        ld_payslip_view_date := trunc(ld_date_paid) + ln_offset_value;
        hr_utility.TRACE('ld_payslip_view_date=' || ld_payslip_view_date);

        IF trunc(ld_payslip_view_date) > trunc(SYSDATE) THEN
          hr_utility.TRACE('View offset return N');
              RETURN('N');
        END IF;
      --Default Behaviour
        ELSE
        hr_utility.TRACE('Offset Criteria is not Date_paid ');
        IF trunc(ld_view_payslip_offset_date) > trunc(SYSDATE) THEN
                  hr_utility.TRACE('View offset return N');
                  RETURN('N');
            END IF;
      END IF;

    END IF;
   --End of Fix for bug 8550075

    open c_check_for_reversal(ln_prepay_action_id);
    fetch c_check_for_reversal into lv_reversal_exists;
    if c_check_for_reversal%found then
       lv_return_flag := 'N';
    else
       open c_pre_payment_method (ln_prepay_action_id);
       loop
          /* fetch all the pre payment records for the asssignment
             other than 3rd party payment */
          fetch c_pre_payment_method into ln_pre_payment_id;

          if c_pre_payment_method%notfound then
             exit;
          end if;

          lv_payment_status := ltrim(rtrim(
                                  pay_assignment_actions_pkg.get_payment_status_code
                                       (ln_prepay_action_id,
                                        ln_pre_payment_id)));

          if lv_payment_status <> 'P' then
             lv_return_flag := 'N';
             exit;
          else
             lv_return_flag := 'Y';
          end if;

       end loop;
       close c_pre_payment_method;

    end if;
    close c_check_for_reversal;

/* Modifications for the bug 8303577 starts */
-- Commented for bug 8643214
/* open c_get_localization(p_assignment_id);
   hr_utility.trace('Inside new get_localization ');
   fetch c_get_localization into ln_localization_code; */
                    if (ln_localization_code = 'GB') then
                        open c_get_completion_status(p_assignment_action_id);
                            lv_completion_status := 0;
                            fetch c_get_completion_status into lv_completion_status;
                            hr_utility.trace('Inside c_get_completion_status ');
                            hr_utility.trace('lv_completion_status '||lv_completion_status);
                            if (lv_completion_status = 0) then
                            hr_utility.trace('Inside c_get_completion_status if condition');
                            return('N');
                          end if;
                        close c_get_completion_status;
                    end if;
-- Commented for bug 8643214
-- close c_get_localization;
/* Modifications for the bug 8303577 ends */

    hr_utility.trace('lv_return_flag='||lv_return_flag);
    hr_utility.trace('Leaving check_emp_personal_payment');

    return lv_return_flag;

  END check_emp_personal_payment;



  /*****************************************************************************
  **        Name: FUNCTION check_emp_personal_payment
  **   Arguments: p_assignment_id        => Assignemnt ID
  **              p_payroll_id           => Payroll ID
  **              p_assignment_action_id => Prepayment Action
  **              p_effective_date       => Payment Date
  ** Description: Overloaded function without the parameter for
  **              time_period_id.
  **
  **              As time_period_id is not passed, the function expects the
  **              prepayment action_id to be passed to it. It then gets the
  **              max date_earned for the run locked by the prepayment process
  **              and then gets the corresponding time_period_id
  **              This is passed to the overloaded function which checks for
  **              Payslip view date
  **              If prepayment action is not passed but instead archive or
  **              run action is passed, the main function will handle it
  *****************************************************************************/
  FUNCTION check_emp_personal_payment(
                   p_assignment_id        number
                  ,p_payroll_id           number
                  ,p_assignment_action_id number
                  ,p_effective_date       date
                  )
  RETURN VARCHAR2 IS

    cursor c_get_date_earned(cp_assignment_action_id in number) is
      select nvl(max(ppa.date_earned), max(ppa.effective_date))
        from pay_payroll_actions ppa
            ,pay_assignment_actions paa
            ,pay_action_interlocks pai
       where ppa.payroll_action_id = paa.payroll_action_id
         and pai.locked_action_id = paa.assignment_action_id
         and pai.locking_action_id = cp_assignment_action_id
         and ppa.action_type in ('R', 'Q', 'B', 'V');

    cursor c_time_period(cp_payroll_id  in number
                        ,cp_date_earned in date) is
      select ptp.time_period_id
        from per_time_periods ptp
       where cp_date_earned between ptp.start_date
                                and ptp.end_Date
         and ptp.payroll_id = cp_payroll_id;

    ld_earned_date     DATE;
    ln_time_period_id  NUMBER;

  BEGIN

    hr_utility.trace('Entering check_emp_personal_payment without time period');
    open c_get_date_earned(p_assignment_action_id);
    fetch c_get_date_earned into ld_earned_date;
    if c_get_date_earned%found then
       open c_time_period(p_payroll_id, ld_earned_date);
       fetch c_time_period into ln_time_period_id;
       close c_time_period;
    end if;
    close c_get_date_earned;

    hr_utility.trace('ln_time_period_id='||ln_time_period_id);
    return(check_emp_personal_payment(
           p_assignment_id        => p_assignment_id
          ,p_payroll_id           => p_payroll_id
          ,p_time_period_id       => ln_time_period_id
          ,p_assignment_action_id => p_assignment_action_id
          ,p_effective_date       => p_effective_date));

  END check_emp_personal_payment;


  /************************************************************
    Function gets the proposed employee salary from
    per_pay_proposals. If the Salary Proposal is not specified
    then it checks the Salary Basis for the employee, find out
    the element associated with the Salary Basis and get the
    value from the run results for the given period.
    If the element associated with the Salary Basis is Regular
    wages, then we get the value for input value of 'Rate'
  ************************************************************/
  FUNCTION get_proposed_emp_salary (
                           p_assignment_id     in number
                          ,p_pay_basis_id      in number
                          ,p_pay_bases_name    in varchar2
                          ,p_period_start_date in date
                          ,p_period_end_date   in date
                          )
  RETURN VARCHAR2 IS

   cursor c_salary_proposal (cp_assignment_id     in number,
                             cp_period_start_date in date,
                             cp_period_end_date   in date) is
     select ppp.proposed_salary_n
       from per_pay_proposals ppp
      where ppp.assignment_id = cp_assignment_id
        and ppp.change_date =
               (select max(change_date)
                 from per_pay_proposals ppp1
                where ppp1.assignment_id = cp_assignment_id
                  and ppp1.approved = 'Y'
                  and ppp1.change_date <= cp_period_end_date);


   cursor c_bases_element (cp_pay_basis_id     in number,
                           cp_period_to_date   in date) is
     select piv.element_type_id, piv.input_value_id
       from pay_input_values_f piv,
            per_pay_bases ppb
      where ppb.pay_basis_id = cp_pay_basis_id
        and ppb.input_value_id = piv.input_value_id
        and cp_period_to_date between piv.effective_start_date
                                  and piv.effective_end_date;

   cursor c_regular_salary (cp_input_value_id  in number,
                            cp_assignment_id   in number,
                            cp_period_to_date  in date ) is
     select prrv.result_value
       from pay_run_results prr,
            pay_run_result_values prrv,
            pay_input_values_f piv,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where prr.element_type_id = piv.element_type_id
        and prr.run_result_id = prrv.run_result_id
        and prr.source_type = 'E'
        and piv.input_value_id = prrv.input_value_id
        and piv.input_value_id = cp_input_value_id
        and ppa.effective_date between piv.effective_start_date
                                  and piv.effective_end_date
        and paa.assignment_action_id = prr.assignment_action_id
        and paa.assignment_id = cp_assignment_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.effective_date = cp_period_to_date;

   cursor c_hourly_salary (cp_element_type_id  in number,
                           cp_input_value_name in varchar2,
                           cp_assignment_id    in number,
                           cp_period_to_date   in date ) is
     select prrv.result_value
       from pay_run_results prr,
            pay_run_result_values prrv,
            pay_input_values_f piv,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
      where prr.element_type_id = piv.element_type_id
        and prr.run_result_id = prrv.run_result_id
        and prr.source_type = 'E'
        and piv.input_value_id = prrv.input_value_id
        and piv.element_type_id = cp_element_type_id
        and piv.name = cp_input_value_name
        and ppa.effective_date between piv.effective_start_date --Bug 3350023
                                   and piv.effective_end_date
        and paa.assignment_action_id = prr.assignment_action_id
        and paa.assignment_id = cp_assignment_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.effective_date = cp_period_to_date;

   ln_element_type_id number;
   ln_input_value_id  number;
   ln_proposed_salary number;

  BEGIN

   open c_salary_proposal(p_assignment_id,
                          p_period_start_date,
                          p_period_end_date);
   fetch c_salary_proposal into ln_proposed_salary;
   if c_salary_proposal%notfound then
      open c_bases_element(p_pay_basis_id, p_period_end_date);
      fetch c_bases_element into ln_element_type_id, ln_input_value_id;
      if c_bases_element%found then
         if p_pay_bases_name <> 'HOURLY' then
            open c_regular_salary(ln_input_value_id,
                                  p_assignment_id,
                                  p_period_end_date);
            fetch c_regular_salary into ln_proposed_salary;
            if c_regular_salary%notfound then
               ln_proposed_salary := 0;
            end if;
            close c_regular_salary;
         else
            open c_hourly_salary(ln_element_type_id,
                                 'Rate',
                                 p_assignment_id,
                                 p_period_end_date);
            fetch c_hourly_salary into ln_proposed_salary;
            if c_hourly_salary%notfound then
               ln_proposed_salary := 0;
            end if;
            close c_hourly_salary;
         end if;
      end if;
      close c_bases_element;

   end if;
   close c_salary_proposal;

   return (ln_proposed_salary);

  END get_proposed_emp_salary;


  /************************************************************
   Gets the Annualized factor for the Payroll
     i.e. frequency of the Payroll
     e.g.  Week = 52
           Semi-Month = 24
           Month      = 12
           Hourly     = No of working hours/day   * 365
                        No of working hours/week  * 52
                        No of working hours/month * 12
                        No of working hours/year  * 1
  ************************************************************/
  FUNCTION get_emp_annualization_factor (
                                p_pay_basis_id    in number
                               ,p_period_type     in varchar2
                               ,p_pay_bases_name  in varchar2
                               ,p_assignment_id   in number
                               ,p_period_end_date in date
                               )
  return number is

   cursor c_salary_details (cp_pay_basis_id  in number) is
     select ppb.pay_annualization_factor
       from per_pay_bases ppb
      where ppb.pay_basis_id = cp_pay_basis_id;

   cursor c_payroll (cp_period_type in varchar2) is
     select ptpt.number_per_fiscal_year
       from per_time_period_types ptpt
      where ptpt.period_type = cp_period_type;

   ln_pay_annualization_factor   number;

  BEGIN

   open c_salary_details(p_pay_basis_id);
   fetch c_salary_details into ln_pay_annualization_factor;
   if c_salary_details%found then

      if p_pay_bases_name ='PERIOD' and
         ln_pay_annualization_factor is null then

         open c_payroll(p_period_type);
         fetch c_payroll into ln_pay_annualization_factor;
         close c_payroll;

      elsif p_pay_bases_name = 'HOURLY' and
            (p_assignment_id is not null and p_period_end_date is not null) then

         ln_pay_annualization_factor :=
                            pay_us_employee_payslip_web.get_asgn_annual_hours
                                            (p_assignment_id,
                                             p_period_end_date);
      end if;
   end if;
   close c_salary_details;

   return (ln_pay_annualization_factor);

  END get_emp_annualization_factor;


  /************************************************************
  The function gets the annual working hours for an assignment.
     The function looks for Standarg Working Conditions for an
     assignment. If is has not been specified then it gets the
     information for the assignment in the following order.
          Assignment
          Position
          Organization
          Business Group
  ************************************************************/
  FUNCTION get_asgn_annual_hours (
                     p_assignment_id   in number
                    ,p_period_end_date in date
                    )
  RETURN NUMBER IS

    cursor c_get_asg_hours (cp_assignment_id   in number,
                            cp_period_end_date in date) is
      select paf.normal_hours,
             decode(paf.frequency,'Y', 1,
                                  'M', 12,
                                  'W', 52,
                                  'D', 365, 1)
       from per_assignments_f paf
      where paf.assignment_id = cp_assignment_id
        and cp_period_end_date between paf.effective_start_date
                                   and paf.effective_end_date;

    cursor c_get_pos_hours (cp_assignment_id   in number,
                            cp_period_end_date in date) is
      select pos.working_hours,
             decode(pos.frequency, 'Y', 1,
                                   'M', 12,
                                   'W', 52,
                                   'D', 365, 1)
       from per_positions pos,
            per_assignments_f paf
      where paf.assignment_id = cp_assignment_id
        and cp_period_end_date between paf.effective_start_date
                                   and paf.effective_end_date
        and paf.position_id = pos.position_id;

    cursor c_get_org_hours (cp_assignment_id   in number,
                            cp_period_end_date in date) is
      select pou.working_hours,
             decode(pou.frequency, 'Y', 1,
                                   'M', 12,
                                   'W', 52,
                                   'D', 365, 1)
       from per_organization_units pou,
            per_assignments_f paf
      where paf.assignment_id = cp_assignment_id
        and cp_period_end_date between paf.effective_start_date
                                   and paf.effective_end_date
        and paf.organization_id = pou.organization_id;

    cursor c_get_bus_hours (cp_assignment_id   in number,
                            cp_period_end_date in date) is
      select pbg.working_hours,
             decode(pbg.frequency, 'Y', 1,
                                   'M', 12,
                                   'W', 52,
                                   'D', 365, 1)
       from per_business_groups pbg,
            per_assignments_f paf
      where paf.assignment_id = cp_assignment_id
        and cp_period_end_date between paf.effective_start_date
                                   and paf.effective_end_date
        and paf.business_group_id = pbg.business_group_id;

   ln_hours          number;
   ln_frequency      number;
   ln_hours_per_year number;

  BEGIN

    open c_get_asg_hours (p_assignment_id,
                          p_period_end_date);
    fetch c_get_asg_hours into ln_hours,ln_frequency;

    if c_get_asg_hours%found and ln_hours is not null then
       close c_get_asg_hours;
    else
       close c_get_asg_hours;
       open c_get_pos_hours (p_assignment_id,
                             p_period_end_date);
       fetch c_get_pos_hours into ln_hours, ln_frequency;

       if c_get_pos_hours%found and ln_hours is not null then
          close c_get_pos_hours;
       else
          close c_get_pos_hours;
          open c_get_org_hours (p_assignment_id,
                                p_period_end_date);
          fetch c_get_org_hours into ln_hours, ln_frequency;

          if c_get_org_hours%found and ln_hours is not null then
             close c_get_org_hours;
             open c_get_bus_hours (p_assignment_id,
                                   p_period_end_date);
             fetch c_get_bus_hours into ln_hours, ln_frequency;
             close c_get_bus_hours;
          end if;
       end if;

    end if;

    ln_hours_per_year := nvl(ln_hours, 0) * ln_frequency;

    return (ln_hours_per_year);

  END get_asgn_annual_hours;

  /************************************************************
   The function gets the School District Name for the passed
   Jurisdiction Code.
   The name is being reteived from the School Dsts table
   depending on the following :
    - get the School District Name from PAY_US_COUNTY_SCHOOL_DSTS.
    - If not found then get the School District Name from
      PAY_US_CITY_SCHOOL_DSTS.
   If the School Dsts Code passed is not in the table then
   NULL is passed.
  ************************************************************/
  Function get_school_dsts_name
          (p_jurisdiction_code in varchar2)
  RETURN varchar2 is

   Cursor c_city_school_dsts
          (cp_jurisdiction_code in varchar2) is
     select initcap(pcisd.school_dst_name)
       from pay_us_city_school_dsts pcisd
      where pcisd.state_code = substr(cp_jurisdiction_code,1,2)
        and pcisd.school_dst_code = substr(cp_jurisdiction_code,4);

   Cursor c_county_school_dsts
          (cp_jurisdiction_code in varchar2) is
     select initcap(pcosd.school_dst_name)
       from pay_us_county_school_dsts pcosd
      where pcosd.state_code = substr(cp_jurisdiction_code,1,2)
        and pcosd.school_dst_code = substr(cp_jurisdiction_code,4);

   lv_school_dst_name varchar2(100);

  BEGIN

       open c_county_school_dsts (p_jurisdiction_code);
       fetch c_county_school_dsts into lv_school_dst_name;
       if c_county_school_dsts%notfound then
          open c_city_school_dsts (p_jurisdiction_code);
          fetch c_city_school_dsts into lv_school_dst_name;
          close c_city_school_dsts;
       end if;
       close c_county_school_dsts;

    return (lv_school_dst_name);

  END get_school_dsts_name;


  /************************************************************

     Name      : get_check_number
     Purpose   : This returns the check number
     Arguments : Pre_payment_id and pre_payment assignment_action.
     Notes     :
 *****************************************************************/
 FUNCTION get_check_number(p_pre_payment_assact in number
                         ,p_pre_payment_id in number)
 RETURN varchar2 is

  lv_check_number varchar2(60);

  Cursor c_check_number(cp_pre_payment_action in number
                       ,cp_pre_payment_id in number) is
    select decode(ppa_pymt.action_type,
                  'M', to_char(NVL(ppp.source_action_id,cp_pre_payment_action)),
                  paa_pymt.serial_number)
      from pay_pre_payments       ppp,
           pay_assignment_actions paa_pymt,
           pay_payroll_actions ppa_pymt,
           pay_action_interlocks pai
     where pai.locked_action_id = cp_pre_payment_action
       and paa_pymt.assignment_action_id = pai.locking_action_id
       and ppa_pymt.payroll_action_id = paa_pymt.payroll_action_id
       and ppa_pymt.action_type in ('M','H', 'E')
       and paa_pymt.pre_payment_id = cp_pre_payment_id
       and ppp.pre_payment_id = paa_pymt.pre_payment_id
       and not exists (
             select 1
               from pay_payroll_actions ppa,
                    pay_assignment_actions paa,
                    pay_action_interlocks pai_void
                    /* Assignment Action of Payment Type - NACHA/Check */
              where pai_void.locked_action_id = paa_pymt.assignment_action_id --Void
               /* Check if the locking is that of Void Pymt */
               and pai_void.locking_action_id = paa.assignment_action_id
               and ppa.payroll_action_id = paa.payroll_action_id
               and paa.action_status = 'C'
               and ppa.action_status = 'C'
               and ppa.action_type = 'D');

 BEGIN

    open c_check_number(p_pre_payment_assact, p_pre_payment_id);
    fetch c_check_number into lv_check_number;
    if c_check_number%notfound then
       lv_check_number := null;
    end if;
    close c_check_number;

    RETURN lv_check_number;

 END get_check_number;

 /************************************************************
  Name      : get_format_value
  purpuse   : given a value, it formats the value to a given
              currency_code and precision.
  arguments : p_business_group_id, p_value
  notes     :
 *************************************************************/
 FUNCTION get_format_value(p_business_group_id in number,
                           p_value in number)
 RETURN varchar2 IS

  lv_formatted_number varchar2(50);

  CURSOR c_currency_code is
  select hoi.org_information10
  from hr_organization_units hou,
       hr_organization_information hoi
  where hou.organization_id = p_business_group_id  /* Bug 3487250 */
    and hou.organization_id = hoi.organization_id
    and hoi.org_information_context = 'Business Group Information';

  BEGIN
    IF g_currency_code is null THEN
       OPEN c_currency_code;
       FETCH c_currency_code into g_currency_code;
       CLOSE c_currency_code;
    END IF;
    IF g_currency_code is not null THEN
       lv_formatted_number := to_char(p_value,
                                     fnd_currency.get_format_mask(
                                         g_currency_code,40));
    ELSE
       lv_formatted_number := p_value;
    END IF;

    return lv_formatted_number;

  EXCEPTION
    when others then
      return p_value;
  END get_format_value;

 /************************************************************
  Name      : format_to_date
  Purpuse   : The function formats the value in date format
  Arguments : p_value
  Notes     :
 *************************************************************/
 FUNCTION format_to_date(p_char_date in varchar2)
 RETURN date IS

    ld_return_date DATE;

 BEGIN
    if length(p_char_date) = 19 then
       ld_return_date := fnd_date.canonical_to_date(p_char_date);
    else
      begin
         ld_return_date := fnd_date.chardate_to_date(p_char_date);

      exception
         when others then
           ld_return_date := null;
      end;

    end if;

    return(ld_return_date);

 END format_to_date;

 /************************************************************
  Name      : get_doc_eit
  Purpuse   : returns whether any documents should be printed
              or viewed online.
  Arguments : p_doc_type = (i.e PAYSLIP, W4...)
              p_mode  = PRINT or ONLINE
              p_level = PERSON, ORGANIZATION, BUSINESS GROUP,
                        LOCATION
              p_id    = appropriate id for p_level.
                        person_id, organization_id, business_group_id,
                        location_id
  Notes     : Priority for levels (high to low)
              Person
              Location
              Organization
              Business Group
 *************************************************************/
 FUNCTION get_doc_eit(p_doc_type in varchar,
                      p_mode    in varchar,
                      p_level  in varchar,
                      p_id     in number,
                      p_effective_date date)
 RETURN varchar2 IS

  CURSOR get_person_eit (l_person_id Number) IS
   select pei_information2, pei_information3
     from  per_people_extra_info
    where information_type =  'HR_SELF_SERVICE_PER_PREFERENCE'
      and person_id = l_person_id
      and pei_information1 = upper(p_doc_type);

  CURSOR get_loc_eit (l_location_id number) IS
   select lei_information2, lei_information3
     from hr_location_extra_info
    where information_type = 'HR_SELF_SERVICE_LOC_PREFERENCE'
      and location_id = l_location_id
      and lei_information1 = upper(p_doc_type);

  CURSOR get_org_eit (l_organization_id number) IS
   select org_information2,org_information3
     from hr_organization_information
    where org_information_context = 'HR_SELF_SERVICE_ORG_PREFERENCE'
      and org_information1 = upper(p_doc_type)
      and organization_id = l_organization_id;

  CURSOR get_bg_eit (l_business_group_id number) IS
   select org_information2, org_information3
     from hr_organization_information hoi
    where hoi.organization_id = l_business_group_id
      and hoi.org_information_context = 'HR_SELF_SERVICE_BG_PREFERENCE'
      and hoi.org_information1 = upper(p_doc_type) ;

/* adding a join to per_periods_of_service. If the employee is terminated then
   the person does not have access to online doc, so we should always return a
   N.
*/

  CURSOR get_person_info(l_assignment_id number) IS
  select paf.business_group_id, paf.organization_id,
         paf.location_id, paf.person_id
    from per_assignments_f paf, per_periods_of_service pps
   where paf.assignment_id = l_assignment_id
     and p_effective_date between paf.effective_start_date
                              and paf.effective_end_date
     and pps.period_of_service_id = paf.period_of_service_id
     and pps.actual_termination_date is null;

  l_mesg              varchar2(250);

  l_online        varchar2(1);
  l_print         varchar2(1);

  l_value         varchar2(1);
  l_count         number;
  l_rowcount          number;
  l_bg_id             number;
  l_org_id            number;
  l_loc_id            number;
  l_person_id         number;

  l_location_cache    varchar2(10);
  l_org_cache         varchar2(10);
  l_bg_cache          varchar2(10);

 BEGIN
  l_mesg := 'pay_us_employee_payslip_web.get_doc_eit';
  hr_utility.set_location(l_mesg,5);
  l_location_cache := 'NOT FOUND';
  l_org_cache      := 'NOT FOUND';
  l_bg_cache       := 'NOT FOUND';
  l_rowCount       := pay_us_employee_payslip_web.eit_tab.count;

  IF upper(p_level) = 'ASSIGNMENT' THEN
    hr_utility.set_location(l_mesg, 10);
    OPEN get_person_info(p_id);
    FETCH get_person_info INTO l_bg_id, l_org_id, l_loc_id, l_person_id;
    CLOSE get_person_info;

    OPEN get_person_eit(l_person_id);
    FETCH get_person_eit INTO l_online, l_print;

    IF get_person_eit%FOUND THEN
      If p_mode = 'PRINT' THEN
        l_value := l_print;
      ELSIF p_mode = 'ONLINE' THEN
        l_value := l_online;
      END IF;
    ELSE /* Person Level EIT not found, look for location level */
      OPEN get_loc_eit(l_loc_id);
      FETCH get_loc_eit INTO l_online, l_print;

      IF get_loc_eit%FOUND THEN
        IF p_mode = 'ONLINE' THEN
          l_value := l_online;
        ELSIF p_mode = 'PRINT' THEN
          l_value := l_print;
        END IF;
      ELSE /* Location Level EIT not found */
        OPEN get_org_eit(l_org_id);
        FETCH get_org_eit into l_online, l_print;
        IF get_org_eit%FOUND THEN
          IF p_mode = 'ONLINE' THEN
            l_value := l_online;
          ELSIF p_mode = 'PRINT' THEN
            l_value := l_print;
          END IF;
        ELSE /* Organization Level not found */
          OPEN get_bg_eit(l_bg_id);
          FETCH get_bg_eit into l_online,l_print;
          IF get_bg_eit%FOUND THEN
            IF p_mode = 'ONLINE' THEN
              l_value := l_online;
            ELSIF p_mode = 'PRINT' THEN
              l_value := l_print;
            END IF;
          ELSE
              l_value := 'Y';
          END IF; /* Bg not found */
  CLOSE get_bg_eit;
        END IF; /* Org not found */
  CLOSE get_org_eit;
      END IF; /* Loc not found */
  CLOSE get_loc_eit;
    END IF; /* Person not found */
  CLOSE get_person_eit;

  return l_value;

  END IF; /* p_level = assignment */

  IF upper(p_level) = 'PERSON' THEN
  hr_utility.set_location(l_mesg,20);
    OPEN get_person_eit(p_id);
    FETCH get_person_eit INTO l_online, l_print;

    IF get_person_eit%FOUND THEN
      If p_mode = 'PRINT' THEN
        l_value := l_print;
      ELSIF p_mode = 'ONLINE' THEN
        l_value := l_online;
      END IF;
    ELSE
      l_value := 'Y';
    END IF;

    CLOSE get_person_eit;
    RETURN l_value;
  END IF;

  IF upper(p_level) = 'LOCATION' THEN
  hr_utility.set_location(l_mesg,30);
  hr_utility.trace('Before LOOP l_location_cache = '||l_location_cache);
    IF (l_rowCount > 0) THEN
      FOR i in pay_us_employee_payslip_web.eit_tab.first ..
             pay_us_employee_payslip_web.eit_tab.last
      LOOP
         IF (pay_us_employee_payslip_web.eit_tab(i).t_id = p_id AND
             pay_us_employee_payslip_web.eit_tab(i).t_level = 'Location') THEN

           l_location_cache := 'FOUND';

           IF p_mode = 'ONLINE' THEN
            l_value := pay_us_employee_payslip_web.eit_tab(i).t_online;
           ELSIF p_mode = 'PRINT' THEN
            l_value := pay_us_employee_payslip_web.eit_tab(i).t_print;
           END IF;
         END IF;
      END LOOP;
     END IF; -- l_rowCount > 0
   hr_utility.trace('AFter LOOP l_location_cache = '||l_location_cache);

   IF l_location_cache = 'NOT FOUND' THEN
   hr_utility.set_location(l_mesg,40);
   ---- Location Level is not cached so find it ----

      OPEN get_loc_eit(p_id);
      FETCH get_loc_eit INTO l_online, l_print;
      hr_utility.trace('l_online = '||l_online);
      hr_utility.trace('l_print = '||l_print);
      l_count := pay_us_employee_payslip_web.eit_tab.count + 1 ;
      pay_us_employee_payslip_web.eit_tab(l_count).t_id := p_id;
      pay_us_employee_payslip_web.eit_tab(l_count).t_level := 'Location';

      IF get_loc_eit%FOUND THEN
        pay_us_employee_payslip_web.eit_tab(l_count).t_online := l_online;
        pay_us_employee_payslip_web.eit_tab(l_count).t_print := l_print;
      ELSE
        pay_us_employee_payslip_web.eit_tab(l_count).t_online := 'Y';
        pay_us_employee_payslip_web.eit_tab(l_count).t_print := 'Y';
      END IF;

      hr_utility.trace('eit_tab(l_count).t_online = '||
                        pay_us_employee_payslip_web.eit_tab(l_count).t_online);
      hr_utility.trace('eit_tab(l_count).t_print = '||
                        pay_us_employee_payslip_web.eit_tab(l_count).t_print);
      IF p_mode = 'ONLINE' THEN
        l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_online;
      ELSIF p_mode = 'PRINT' THEN
        l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_print;
      END IF;
      CLOSE get_loc_eit;
   END IF;
   return l_value;
  END IF; -- if p_level = Location

  IF upper(p_level) = 'ORGANIZATION' THEN
   hr_utility.set_location(l_mesg,50);
       IF (l_rowCount > 0) THEN
          FOR i in pay_us_employee_payslip_web.eit_tab.first ..
                   pay_us_employee_payslip_web.eit_tab.last
          LOOP
            IF (pay_us_employee_payslip_web.eit_tab(i).t_id = p_id AND
                pay_us_employee_payslip_web.eit_tab(i).t_level
                               = 'Organization') THEN
              l_org_cache := 'FOUND';
              IF p_mode = 'ONLINE' THEN
                l_value := pay_us_employee_payslip_web.eit_tab(i).t_online;
              ELSIF p_mode = 'PRINT' THEN
                l_value := pay_us_employee_payslip_web.eit_tab(i).t_print;
              END IF;
           END IF;
         END LOOP;
       END IF;

    ---- Organization Level is not cached so find it ----

     IF l_org_cache = 'NOT FOUND' THEN
       hr_utility.trace('Org cache NOT FOUND');
       hr_utility.set_location(l_mesg,60);
       OPEN get_org_eit(p_id);
       FETCH get_org_eit INTO l_online, l_print;
       l_count := pay_us_employee_payslip_web.eit_tab.count + 1 ;
       pay_us_employee_payslip_web.eit_tab(l_count).t_id := p_id;
       pay_us_employee_payslip_web.eit_tab(l_count).t_level := 'Organization';

       IF get_org_eit%FOUND THEN
         pay_us_employee_payslip_web.eit_tab(l_count).t_online := l_online;
         pay_us_employee_payslip_web.eit_tab(l_count).t_print := l_print;
       ELSE
         pay_us_employee_payslip_web.eit_tab(l_count).t_online := 'Y';
         pay_us_employee_payslip_web.eit_tab(l_count).t_print := 'Y';
       END IF;

       IF p_mode = 'PRINT' THEN
           l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_print;
       ELSIF p_mode = 'ONLINE' THEN
           l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_online;
       END IF;
       CLOSE get_org_eit;
     END IF;
    return l_value;
  END IF; --if p_level = Organization

  --- So look for Cached Business Group EIT ---

  IF upper(p_level) = 'BUSINESS GROUP' THEN
    hr_utility.set_location(l_mesg,70);
    IF (l_rowCount > 0) THEN
       FOR i in pay_us_employee_payslip_web.eit_tab.first ..
                pay_us_employee_payslip_web.eit_tab.last LOOP
         IF (pay_us_employee_payslip_web.eit_tab(i).t_id = p_id AND
             pay_us_employee_payslip_web.eit_tab(i).t_level = 'Business Group')
         THEN
           l_bg_cache := 'FOUND';
           IF p_mode = 'ONLINE' THEN
             l_value := pay_us_employee_payslip_web.eit_tab(i).t_online;
           ELSIF p_mode = 'PRINT' THEN
             l_value := pay_us_employee_payslip_web.eit_tab(i).t_print;
           END IF;
         END IF;
       END LOOP;
    END IF;

    --- business Group Level EIT not cached ----

    IF l_bg_cache = 'NOT FOUND' THEN
     hr_utility.set_location(l_mesg,80);

      OPEN get_bg_eit(p_id);
      FETCH get_bg_eit INTO l_online, l_print;
      l_count := pay_us_employee_payslip_web.eit_tab.count + 1;
      pay_us_employee_payslip_web.eit_tab(l_count).t_id := p_id;
      pay_us_employee_payslip_web.eit_tab(l_count).t_level := 'Business Group';

      IF get_bg_eit%FOUND THEN
        pay_us_employee_payslip_web.eit_tab(l_count).t_online := l_online;
        pay_us_employee_payslip_web.eit_tab(l_count).t_print := l_print;
      ELSE
        pay_us_employee_payslip_web.eit_tab(l_count).t_online := 'Y';
        pay_us_employee_payslip_web.eit_tab(l_count).t_print := 'Y';
      END IF;

      IF p_mode = 'ONLINE' THEN
           l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_online;
      ELSIF p_mode = 'PRINT' THEN
           l_value := pay_us_employee_payslip_web.eit_tab(l_count).t_print;
      END IF;

      CLOSE get_bg_eit;
    END IF; -- bg_cache not found
    return l_value;
  END IF; -- p_level = Business Group

 END get_doc_eit;

 /*********************************************************************
   Name      : get_jurisdiction_name
   Purpose   : This function returns the name of the jurisdiction
               If Jurisdiction_code is like 'XX-000-0000' then
                  it returns State Name from py_us_states
               If Jurisdiction_code is like 'XX-XXX-0000' then
                   it returns County Name from paY_us_counties
               If Jurisdiction_code is like 'XX-XXX-XXXX' then
                   it returns City Name from pay_us_city_name
               If Jurisdiction_code is like 'XX-XXXXX' then
                   it returns School Name from pay_us_school_dsts
               In case jurisdiction code could not be found relevent
               table then NULL is returned.
   Arguments : p_jurisdiction_code
   Notes     :
  *********************************************************************/
  FUNCTION get_jurisdiction_name(p_jurisdiction_code in varchar2)

  RETURN VARCHAR2
  IS

    cursor c_get_state(cp_state_code in varchar2) is
       select state_abbrev
         from pay_us_states
        where state_code  = cp_state_code;

    cursor c_get_county( cp_state_code in varchar2
                         ,cp_county_code in varchar2
                       ) is
       select county_name
         from pay_us_counties
        where state_code  = cp_state_code
          and county_code = cp_county_code;

    cursor c_get_city( cp_state_code  in varchar2
                      ,cp_county_code in varchar2
                      ,cp_city_code   in varchar2
                       ) is
       select city_name
         from pay_us_city_names
        where state_code    = cp_state_code
          and county_code   = cp_county_code
          and city_code     = cp_city_code
          and primary_flag  = 'Y';

    lv_state_code        VARCHAR2(2);
    lv_county_code       VARCHAR2(3);
    lv_city_code         VARCHAR2(4);
    lv_jurisdiction_name VARCHAR2(240);

    lv_procedure_name    VARCHAR2(50);
  BEGIN
      lv_procedure_name    := '.get_jurisdiction_name' ;
      lv_state_code        := substr(p_jurisdiction_code,1,2);
      lv_county_code       := substr(p_jurisdiction_code,4,3);
      lv_city_code         := substr(p_jurisdiction_code,8,4);
      lv_jurisdiction_name := null;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);

      if p_jurisdiction_code like '__-000-0000' then
         open c_get_state(lv_state_code);
         fetch c_get_state into lv_jurisdiction_name;
         close c_get_state;
      elsif p_jurisdiction_code like '__-___-0000' then
         open c_get_county(lv_state_code
                           ,lv_county_code);
         fetch c_get_county into lv_jurisdiction_name;
         close c_get_county;
      elsif p_jurisdiction_code like '__-___-____' then
         open c_get_city( lv_state_code
                         ,lv_county_code
                         ,lv_city_code);
         fetch c_get_city into lv_jurisdiction_name;
         close c_get_city;
      elsif p_jurisdiction_code like '__-_____' then
          -- this is school district make a function call
         lv_jurisdiction_name
                 := pay_us_employee_payslip_web.get_school_dsts_name(p_jurisdiction_code);
      end if;

      hr_utility.set_location(gv_package || lv_procedure_name, 30);
      return (lv_jurisdiction_name);
  END get_jurisdiction_name;


  FUNCTION get_legislation_code( p_business_group_id in number)
  RETURN VARCHAR2 is

  CURSOR cur_legislation_code is
  select
    org_information9
  from
    hr_organization_information
  where
    org_information_context = 'Business Group Information'
    and organization_id = p_business_group_id;

  l_legislation_code     hr_organization_information.org_information9%TYPE;

  BEGIN

    OPEN  cur_legislation_code;
    FETCH cur_legislation_code
    INTO  l_legislation_code;

    IF cur_legislation_code%NOTFOUND THEN
      l_legislation_code := ' ';
    END IF;

    CLOSE cur_legislation_code;

    RETURN l_legislation_code;

 END get_legislation_code;


 FUNCTION get_term_info (p_business_group_id    number,
                         p_person_id            number,
                         p_action_context_id    number)
                        /* for bug 4132132
                         p_effective_start_date date,
                         p_effective_end_date   date) */
 RETURN varchar2 IS

 CURSOR c_get_legislation_rule(p_legislation_code varchar2) is
     select rule_mode
       from pay_legislative_field_info plf
      WHERE validation_name = 'ITEM_PROPERTY'
        and rule_type = 'PAYSLIP_STOP_TERM_EMP'
        and field_name = 'CHOOSE_PAYSLIP'
        and legislation_code = p_legislation_code;
        --get_legislation_code(p_business_group_id);

  cursor c_get_terminate_date is
      select actual_termination_date,  pai.action_information16
      from per_periods_of_service pps,
            pay_action_information pai
      where pps.person_id = p_person_id
      and pai.action_context_id  = p_action_context_id
      and pai.action_information_category = 'EMPLOYEE DETAILS'
     /* and fnd_date.canonical_to_date(pai.action_information11) = pps.date_start;*/
      and format_to_date(pai.action_information11) =  pps.date_start;

/* Bug 3722370 - Introduced decode statement in WHERE clause */
  cursor c_get_term_details(p_actual_termination_date varchar2,
                            p_time_period_id number) is
     /* Changed this for bug 4132132
       select 'Y'
       from per_periods_of_service pps
      where person_id = p_person_id
        and decode(actual_termination_date,NULL,date_start,p_effective_start_date)
            between date_start
              and nvl(actual_termination_date,p_effective_end_date) ;
      */
      /*  don't show the payslip if the employee is terminated in the given pay period
          or prior to the given pay period */
      select 'N' from per_time_periods ptp
      where ptp.time_period_id = p_time_period_id
      and ( p_actual_termination_date between  ptp.start_date
                                     and ptp.end_date
           or
            p_actual_termination_date < ptp.start_date);
  l_rule_mode       varchar2(10);
  l_val             varchar2(10);
  l_terminate_date  date;
  l_time_period_id  number;

 BEGIN

   l_val := 'Y' ;
   if g_legislation_code is null then
     g_legislation_code := get_legislation_code(p_business_group_id);
   end if;

   if g_legislation_rule is null then
     open c_get_legislation_rule(g_legislation_code);
     fetch c_get_legislation_rule into l_rule_mode;
     close c_get_legislation_rule;
   end if;

   if l_rule_mode = 'Y' then

      open c_get_terminate_date;
      fetch c_get_terminate_date
      into l_terminate_date, l_time_period_id;
      close c_get_terminate_date;

      if l_terminate_date IS NULL then
          return 'Y';
      else
         open  c_get_term_details(l_terminate_date,l_time_period_id) ;
         fetch c_get_term_details into l_val;
         close c_get_term_details;
         if l_val is null then
             l_val := 'Y';
         end if;
      end if;
   else
      return 'Y';
   end if;

   return l_val;

 END get_term_info;


 FUNCTION get_meaning_payslip_label(p_leg_code    VARCHAR2,
                                    p_lookup_code VARCHAR2)
 RETURN Varchar2 IS
  CURSOR csr_hr_lookup
    ( p_lookup_type     VARCHAR2
    , p_lookup_code     VARCHAR2
    )
  IS
    SELECT hr_general_utilities.Get_lookup_Meaning(p_lookup_type,p_lookup_code)
    FROM DUAL;

    l_meaning hr_lookups.meaning%TYPE;

 BEGIN
        OPEN csr_hr_lookup(p_leg_code||'_PAYSLIP_LABEL',p_leg_code||'_'||p_lookup_code);
      FETCH csr_hr_lookup INTO l_meaning;
      CLOSE csr_hr_lookup;

      IF l_meaning IS NULL THEN
          OPEN csr_hr_lookup('PAYSLIP_LABEL',p_leg_code||'_'||p_lookup_code);
          FETCH csr_hr_lookup INTO l_meaning;
            CLOSE csr_hr_lookup;
        END IF;

        return l_meaning;
 END get_meaning_payslip_label;


 /*********************************************************************
   Name      : get_full_jurisdiction_name
   Purpose   : This function returns the name of the jurisdiction
               If Jurisdiction_code is like 'XX-000-0000' then
                   it returns "State Name" using function get_jurisdiction_name
               If Jurisdiction_code is like 'XX-XXX-0000' then
                   it returns "State Name, County Name"
                                            using function get_jurisdiction_name
               If Jurisdiction_code is like 'XX-XXX-XXXX' then
                   it returns "State Name, County Name, City Name"
                                            using function get_jurisdiction_name
               In case jurisdiction code could not be found relevent
               table then NULL is returned.
   Arguments : p_jurisdiction_code
   Notes     :
  *********************************************************************/
  FUNCTION get_full_jurisdiction_name(p_jurisdiction_code in varchar2)

  RETURN VARCHAR2
  IS
    lv_state_code          VARCHAR2(2);
    lv_county_code         VARCHAR2(3);
    lv_city_code           VARCHAR2(4);
    lv_jurisdiction_name   VARCHAR2(240);
    lv_procedure_name      VARCHAR2(50);

    lv_state_abbrev        VARCHAR2(240);
    lv_county_name         VARCHAR2(240);
    lv_city_name           VARCHAR2(240);
    lv_school_dst          VARCHAR2(240);

  BEGIN
    lv_procedure_name      := '.get_jurisdiction_name' ;
    lv_state_code          := substr(p_jurisdiction_code,1,2);
    lv_county_code         := substr(p_jurisdiction_code,4,3);
    lv_city_code           := substr(p_jurisdiction_code,8,4);
    lv_jurisdiction_name   := null;

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    if p_jurisdiction_code like '__-000-0000' then
       lv_jurisdiction_name := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (lv_state_code || '-000-0000');

    elsif p_jurisdiction_code like '__-___-0000' then
       lv_state_abbrev := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (lv_state_code || '-000-0000');
       lv_county_name := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (p_jurisdiction_code);

       lv_jurisdiction_name := lv_state_abbrev ||', '||lv_county_name;

    elsif p_jurisdiction_code like '__-___-____' then
       lv_state_abbrev := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (lv_state_code || '-000-0000');

       lv_county_name := pay_us_employee_payslip_web.get_jurisdiction_name
                                    (lv_state_code || '-' || lv_county_code || '-0000');
       lv_city_name := pay_us_employee_payslip_web.get_jurisdiction_name
                                    (p_jurisdiction_code);

       hr_utility.set_location('p_jurisdiction_code -> '||p_jurisdiction_code, 30);
       hr_utility.set_location('lv_state_abbrev     -> '|| lv_state_abbrev, 30);
       hr_utility.set_location('lv_county_name      -> '|| lv_county_name, 30);
       hr_utility.set_location('lv_city_name        -> '|| lv_city_name, 30);

       lv_jurisdiction_name := lv_state_abbrev ||', '||
                               lv_county_name  ||', '||
                               lv_city_name;
    elsif length(p_jurisdiction_code) = 8 then
       lv_state_abbrev := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (lv_state_code || '-000-0000');
       lv_school_dst := pay_us_employee_payslip_web.get_jurisdiction_name
                                   (p_jurisdiction_code);
       lv_jurisdiction_name := lv_state_abbrev || ', ' ||
                               lv_school_dst;

    end if;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    return (lv_jurisdiction_name);
  END get_full_jurisdiction_name;

  -- This Function will be called from View Definition of
  -- PAY_EMP_NET_DIST_ACTION_INFO_V
  -- California OT Enhancement Started Populating pay_action_information
  -- Table with Account Details for Payment Method Check
  -- We need to hide those Details in Self Service Payslip

  FUNCTION get_netpaydistr_segment(p_business_grp_id IN NUMBER
                                  ,p_org_pay_meth_id IN NUMBER)
  RETURN VARCHAR2 IS

    cursor cur_legislation(p_business_grp_id in number) is
        select hoi.org_information9
        from hr_organization_information hoi
        where hoi.organization_id = p_business_grp_id
          and hoi.org_information_context = 'Business Group Information';

     cursor cur_payment_typ(p_legislation_code in varchar2
                           ,p_org_pay_meth_id IN NUMBER) is
        select '1'
        from pay_payment_types ppt
            ,pay_org_payment_methods_f popm
        where popm.org_payment_method_id = p_org_pay_meth_id
          and popm.payment_type_id = ppt.payment_type_id
          and ppt.territory_code = p_legislation_code
          and ppt.category = 'CH';

     lv_legislation_code          VARCHAR2(100);
     lv_exists                    VARCHAR2(10);

  BEGIN
      hr_utility.trace('Entering into pay_us_employee_payslip_web.get_netpaydistr_segment');
      hr_utility.trace('p_business_grp_id := ' || p_business_grp_id);
      hr_utility.trace('p_org_pay_meth_id := ' || p_org_pay_meth_id);

      open cur_legislation(p_business_grp_id);
      fetch cur_legislation into lv_legislation_code;
      close cur_legislation;

      hr_utility.trace('lv_legislation_code := ' || lv_legislation_code);

      -- Legislation Check Should not be needed here and Added for Safer Side
      -- Can be removed if it can be confirmed that for All Localizations
      -- Payment category is 'CH' for Check / Cheque

      -- Bug Fix for 8197823 Begin
      -- IF lv_legislation_code = 'US' THEN
      --commenting the if condiaion as, irrespective of legislation code, account number should not be displayed
      --in online payslip when payment method is cheque, Bug 8245514
      --IF lv_legislation_code in ('US','GB') THEN
      -- Bug Fix for 8197823 End

        OPEN cur_payment_typ(lv_legislation_code
                            ,p_org_pay_meth_id);
        FETCH cur_payment_typ INTO lv_exists;
        CLOSE cur_payment_typ;

        hr_utility.trace('lv_exists := ' || lv_exists);

        IF lv_exists = '1' THEN
         RETURN 'TRUE';
        ELSE
         RETURN 'FALSE';
        END IF;

      --ELSE
      --   return 'FALSE';
      --END IF;
      --End of Bug Fix 8245514

  END get_netpaydistr_segment;

  PROCEDURE check_emp_personal_payment(p_effective_date VARCHAR2,
                                       p_enable_term VARCHAR2,
                                       p_business_group_id VARCHAR2,
                                       p_person_id VARCHAR2,
                                       p_first_call VARCHAR2 DEFAULT 'N',
                                       p_last_fetch OUT NOCOPY VARCHAR2,
                                       pay_ret_table OUT NOCOPY pay_payslip_list_table)
  IS

  is_valid_payslip VARCHAR2(10) := NULL;
  row_count NUMBER := 1;
  numlistrows NUMBER := 10;
  l_term_flag VARCHAR2(1) := 'N';
  action_context_id VARCHAR2(40);
  payroll_id VARCHAR2(50);
  time_period_id  VARCHAR2(50);
	assignment_id VARCHAR2(50);
	action_information14 VARCHAR2(255);
	check_count VARCHAR2(5);
	v_effective_date 	date;

  BEGIN

   hr_utility.TRACE('Entering check_emp_personal_payment Wrapper');

    pay_ret_table := pay_payslip_list_table();

    IF g_legislation_code IS NULL THEN
      g_legislation_code := get_legislation_code (p_business_group_id);
    END IF;

    IF p_first_call = 'Y' THEN
      hr_utility.TRACE('check_emp_personal_payment - First Call');
      numlistrows := numlistrows + 1;
      g_job_label := pay_us_employee_payslip_web.get_meaning_payslip_label(g_legislation_code || '', 'JOB');
      g_check_label := pay_us_employee_payslip_web.get_meaning_payslip_label(g_legislation_code || '', 'CHECK');

      --check if the cursor was closed. If there was an exception of sort, then it may lead to
      --cursor remaining in open status
      IF get_choose_payslip%ISOPEN THEN
        close get_choose_payslip;
      END IF;
      OPEN get_choose_payslip(p_person_id, p_effective_date);


    END IF;

    hr_utility.TRACE('p_person_id ' || p_person_id);
    hr_utility.TRACE('p_effective_date ' || p_effective_date);
    hr_utility.TRACE('g_legislation_code ' || g_legislation_code);

    loop

      fetch get_choose_payslip into action_context_id,
                                     v_effective_date,
                                     payroll_id,
                                     time_period_id,
                                     assignment_id,
                                     action_information14,
                                     check_count;

      if get_choose_payslip%notfound then
        CLOSE get_choose_payslip;
        p_last_fetch := 'Y';
        return;
      end if;
      p_last_fetch := 'N';

      IF g_legislation_code = 'US' THEN

       hr_utility.TRACE('check_emp_personal_payment - Legislation Code is US');
       hr_utility.TRACE('v_effective_date ' || v_effective_date);
       hr_utility.TRACE('payroll_id ' || payroll_id);
       hr_utility.TRACE('time_period_id ' || time_period_id);
       hr_utility.TRACE('action_context_id ' || action_context_id);
       hr_utility.TRACE('assignment_id ' || assignment_id);
       hr_utility.TRACE('action_information14 ' || action_information14);
       hr_utility.TRACE('check_count ' || check_count);

        --Calling the US sepecific Validations
        is_valid_payslip := check_us_emp_personal_payment(
                                                       p_assignment_id =>to_number(assignment_id)
                                                       , p_payroll_id => to_number(payroll_id)
                                                       , p_time_period_id => to_number(time_period_id)
                                                       , p_assignment_action_id => to_number(action_context_id)
                                                       , p_effective_date => v_effective_date
                                                       );
      ELSE
       hr_utility.TRACE('check_emp_personal_payment - Calling Generic');
       hr_utility.TRACE('v_effective_date ' || v_effective_date);
       hr_utility.TRACE('payroll_id ' || payroll_id);
       hr_utility.TRACE('time_period_id ' || time_period_id);
       hr_utility.TRACE('action_context_id ' || action_context_id);
       hr_utility.TRACE('assignment_id ' || assignment_id);
       hr_utility.TRACE('action_information14 ' || action_information14);
       hr_utility.TRACE('check_count ' || check_count);

        is_valid_payslip := check_emp_personal_payment(
                                                     p_assignment_id   =>to_number(assignment_id)
                                                    ,p_payroll_id      => to_number(payroll_id)
                                                    ,p_time_period_id  => to_number(time_period_id)
                                                    ,p_assignment_action_id => to_number(action_context_id)
                                                    ,p_effective_date    => v_effective_date
                                                    );
      END IF;

        IF is_valid_payslip = 'Y' THEN

          hr_utility.TRACE('Before Term Check');
          hr_utility.TRACE('check_emp_personal_payment - Valid Payslip found for t_assignment_action_id ' ||action_context_id);

        --Now check for Termination
          IF p_enable_term = 'N' THEN
            l_term_flag := pay_us_employee_payslip_web.get_term_info(p_business_group_id, p_person_id, action_context_id);
          END IF;

          IF (p_enable_term = 'N' AND l_term_flag = 'Y') OR (p_enable_term <> 'N') THEN

            hr_utility.TRACE('After Term Check');
            hr_utility.TRACE('check_emp_personal_payment - Valid Payslip found for t_assignment_action_id ' || action_context_id);
            --if row_count > 1 then
            pay_ret_table.EXTEND(1);

            --insert the payslip in to the table to be returned.
            pay_ret_table(row_count) := pay_payslip_list_rec(v_effective_date
                                        || g_job_label
                                        ||' '
                                        ||action_information14
                                        ||' - '
                                        ||g_check_label
                                        ||' '
                                        || check_count,
                                        action_context_id,
                                        to_char(v_effective_date, 'YYYY-MM-DD'));


            --Return if 10 valid payslips are fetched
            IF numlistrows <= row_count THEN
              RETURN;
            END IF;

          ELSE
            hr_utility.TRACE('Terminated Employee Payslip');
          END IF;

          row_count := row_count + 1;

        END IF;

    END LOOP;

  END;

  /*9394861 Payslip Validations specific to US Legislation. Earlier these validations
    were included in check_emp_personal_payment
  */
  FUNCTION check_us_emp_personal_payment(
                                         p_assignment_id NUMBER
                                         , p_payroll_id NUMBER
                                         , p_time_period_id NUMBER
                                         , p_assignment_action_id NUMBER
                                         , p_effective_date DATE
                                         )
  RETURN VARCHAR2 IS

    /* Cursor to get Payslip offset date for a payroll */
    --Added REGULAR_PAYMENT_DATE for bug 8550075
  CURSOR c_view_offset(cp_time_period_id IN NUMBER) IS
    SELECT payslip_view_date, REGULAR_PAYMENT_DATE
    FROM per_time_periods ptp
    WHERE time_period_id = cp_time_period_id;

    /* Cursor to get the how employee is paid */
  CURSOR c_pre_payment_method
    (cp_assignment_action_id NUMBER) IS
    SELECT ppp.pre_payment_id
    FROM pay_payment_types ppt,
    pay_org_payment_methods_f popm,
    pay_pre_payments ppp
    WHERE ppp.assignment_action_id = cp_assignment_action_id
    AND popm.org_payment_method_id = ppp.org_payment_method_id
    AND popm.defined_balance_id IS NOT NULL
    AND ppt.payment_type_id = popm.payment_type_id;


  CURSOR c_check_for_reversal(cp_assignment_action_id IN NUMBER) IS
    SELECT 1
    FROM pay_action_interlocks pai_pre
    WHERE pai_pre.locking_action_id = cp_assignment_action_id
    AND EXISTS (
                SELECT 1
                FROM pay_payroll_actions ppa,
                pay_assignment_actions paa,
                pay_action_interlocks pai_run
                /* Get the run assignment action id locked by pre-payment */
                WHERE pai_run.locked_action_id = pai_pre.locked_action_id
                /* Check if the Run is being locked by Reversal */
                AND pai_run.locking_action_id = paa.assignment_action_id
                AND ppa.payroll_action_id = paa.payroll_action_id
                AND paa.action_status = 'C'
                AND ppa.action_type = 'V');

    /****************************************************************
    ** If archiver is locking the pre-payment assignment_action_id,
    ** we get it from interlocks and use it to check if all payments
    ** have been made fro the employee.
    ****************************************************************/
  CURSOR c_prepay_arch_action(cp_assignment_action_id IN NUMBER) IS
    SELECT paa.assignment_action_id
    FROM pay_action_interlocks paci,
    pay_assignment_actions paa,
    pay_payroll_actions ppa
    WHERE paci.locking_action_id = cp_assignment_action_id
    AND paa.assignment_action_id = paci.locked_action_id
    AND ppa.payroll_action_id = paa.payroll_action_id
    AND ppa.action_type IN ('P', 'U');

    /****************************************************************
    ** If archiver is locking the run assignment_action_id, we get
    ** the corresponding run assignment_action_id and then get
    ** the pre-payment assignemnt_action_id.
    ** This cursor is only required when there are child action which
    ** means there is a seperate check.
    * ***************************************************************/
  CURSOR c_prepay_run_arch_action(cp_assignment_action_id IN NUMBER) IS
    SELECT paa_pre.assignment_action_id
    FROM pay_action_interlocks pai_run,
    pay_action_interlocks pai_pre,
    pay_assignment_actions paa_pre,
    pay_payroll_actions ppa_pre
    WHERE pai_run.locking_action_id = cp_assignment_action_id
    AND pai_pre.locked_action_id = pai_run.locked_action_id
    AND paa_pre.assignment_Action_id = pai_pre.locking_action_id
    AND ppa_pre.payroll_action_id = paa_pre.payroll_action_id
    AND ppa_pre.action_type IN ('P', 'U');

  --Modified Cursor for bug 8550075
  CURSOR c_get_date_earned(cp_assignment_action_id IN NUMBER) IS
    SELECT nvl(MAX(ppa.date_earned), MAX(ppa.effective_date)), MAX(ppa.effective_date), BUSINESS_GROUP_ID
    FROM pay_payroll_actions ppa
    , pay_assignment_actions paa
    , pay_action_interlocks pai
    WHERE ppa.payroll_action_id = paa.payroll_action_id
    AND pai.locked_action_id = paa.assignment_action_id
    AND pai.locking_action_id = cp_assignment_action_id
    AND ppa.action_type IN ('R', 'Q', 'B', 'V')
    GROUP BY BUSINESS_GROUP_ID;

  CURSOR c_time_period(cp_payroll_id IN NUMBER
                       , cp_date_earned IN DATE) IS
    SELECT ptp.time_period_id
    FROM per_time_periods ptp
    WHERE cp_date_earned BETWEEN ptp.start_date
    AND ptp.end_Date
    AND ptp.payroll_id = cp_payroll_id;


  --New cursor defined for bug 8550075
  CURSOR c_get_view_date_criteria (cp_bg_id IN NUMBER) IS
    SELECT 'Y' FROM hr_organization_information hoi
    WHERE hoi.organization_id = cp_bg_id
    AND hoi.org_information_context = 'HR_SELF_SERVICE_BG_PREFERENCE'
    AND ORG_INFORMATION12 = 'DATE_PAID'
    AND ORG_INFORMATION1 = 'PAYSLIP';


  lv_reversal_exists VARCHAR2(1);
  ln_prepay_action_id NUMBER;
  ln_pre_payment_id NUMBER;
  lv_payment_status VARCHAR2(50);
  lv_return_flag VARCHAR2(1);

  ld_view_payslip_offset_date DATE;
  ld_date_paid DATE;
  ld_reg_payment_date DATE;
  ld_earned_date DATE;
  ln_time_period_id NUMBER;
  ln_offset_value NUMBER;

  ld_payslip_view_date DATE;
  ln_bg_id NUMBER;
  is_dynamic_view_date VARCHAR2(1);


  BEGIN

    hr_utility.TRACE('Entering check_emp_personal_payment');
    hr_utility.TRACE('p_effective_date=' || p_effective_date);
    hr_utility.TRACE('p_time_period_id=' || p_time_period_id);


   -- END For bug 8643214

    lv_return_flag := 'Y';

    OPEN c_prepay_arch_action(p_assignment_action_id);
    FETCH c_prepay_arch_action INTO ln_prepay_action_id;
    IF c_prepay_arch_action%notfound THEN
      OPEN c_prepay_run_arch_action(p_assignment_action_id);
      FETCH c_prepay_run_arch_action INTO ln_prepay_action_id;
      if c_prepay_run_arch_action%notfound then
          return('N');
      end if;
      close c_prepay_run_arch_action;
    END IF;
    CLOSE c_prepay_arch_action;

    ln_time_period_id := p_time_period_id;
    IF ln_time_period_id IS NULL THEN
      OPEN c_get_date_earned(ln_prepay_action_id);
      FETCH c_get_date_earned INTO ld_earned_date, ld_date_paid, ln_bg_id;
      IF c_get_date_earned%found THEN
        OPEN c_time_period(p_payroll_id, ld_earned_date);
        FETCH c_time_period INTO ln_time_period_id;
        CLOSE c_time_period;
      END IF;
      CLOSE c_get_date_earned;
    END IF;

    hr_utility.TRACE('ln_time_period_id=' || ln_time_period_id);
    OPEN c_view_offset(ln_time_period_id);
    FETCH c_view_offset INTO ld_view_payslip_offset_date, ld_reg_payment_date;
    CLOSE c_view_offset;

    hr_utility.TRACE('ld_view_payslip_offset_date=' || trunc(ld_view_payslip_offset_date));
    hr_utility.TRACE('p_effective_date=' || trunc(p_effective_date));
    hr_utility.TRACE('sysdate=' || trunc(SYSDATE));

    IF ld_date_paid IS NULL THEN
      OPEN c_get_date_earned(ln_prepay_action_id);
      FETCH c_get_date_earned INTO ld_earned_date, ld_date_paid, ln_bg_id;
      CLOSE c_get_date_earned;
    END IF;

    IF ld_view_payslip_offset_date IS NOT NULL THEN

      IF ln_bg_id IS NOT NULL THEN
        OPEN c_get_view_date_criteria(ln_bg_id);
        FETCH c_get_view_date_criteria INTO is_dynamic_view_date;
        CLOSE c_get_view_date_criteria;
      END IF;

        if g_legislation_code is null then
          g_legislation_code := get_legislation_code(ln_bg_id);
        end if;

      hr_utility.TRACE('g_legislation_code=' || g_legislation_code);
      hr_utility.TRACE('is_dynamic_view_date=' || is_dynamic_view_date);

        --If Date_paid preference is set and legislation_code is 'US'
      IF is_dynamic_view_date = 'Y' AND ld_date_paid IS NOT NULL AND g_legislation_code = 'US' THEN

        ln_offset_value := trunc(ld_view_payslip_offset_date - ld_reg_payment_date);

        hr_utility.TRACE('ln_offset_value=' || ln_offset_value);
        hr_utility.TRACE('ld_view_payslip_offset_date=' || ld_view_payslip_offset_date);

        ld_payslip_view_date := trunc(ld_date_paid) + ln_offset_value;
        hr_utility.TRACE('ld_payslip_view_date=' || ld_payslip_view_date);

        IF trunc(ld_payslip_view_date) > trunc(SYSDATE) THEN
          hr_utility.TRACE('View offset return N');
          RETURN('N');
        END IF;
      --Default Behaviour
      ELSE
        hr_utility.TRACE('Offset Criteria is not Date_paid ');
        IF trunc(ld_view_payslip_offset_date) > trunc(SYSDATE) THEN
          hr_utility.TRACE('View offset return N');
          RETURN('N');
        END IF;
      END IF;

    END IF;
   --End of Fix for bug 8550075

    OPEN c_check_for_reversal(ln_prepay_action_id);
    FETCH c_check_for_reversal INTO lv_reversal_exists;
    IF c_check_for_reversal%found THEN
      lv_return_flag := 'N';
    ELSE
      OPEN c_pre_payment_method (ln_prepay_action_id);
      LOOP
          /* fetch all the pre payment records for the asssignment
             other than 3rd party payment */
        FETCH c_pre_payment_method INTO ln_pre_payment_id;

        IF c_pre_payment_method%notfound THEN
          EXIT;
        END IF;

        lv_payment_status := ltrim(rtrim(
                                         pay_assignment_actions_pkg.get_payment_status_code
                                         (ln_prepay_action_id,
                                          ln_pre_payment_id)));

        IF lv_payment_status <> 'P' THEN
          lv_return_flag := 'N';
          EXIT;
        ELSE
          lv_return_flag := 'Y';
        END IF;

      END LOOP;
      CLOSE c_pre_payment_method;

    END IF;
    CLOSE c_check_for_reversal;

    hr_utility.TRACE('lv_return_flag=' || lv_return_flag);
    hr_utility.TRACE('Leaving check_emp_personal_payment');

    RETURN lv_return_flag;

  END check_us_emp_personal_payment;

BEGIN
  gv_package := 'pay_us_employee_payslip_web';
--  hr_utility.trace_on(null, 'PAYSLIP');
END pay_us_employee_payslip_web;

/
