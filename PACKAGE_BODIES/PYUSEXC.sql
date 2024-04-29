--------------------------------------------------------
--  DDL for Package Body PYUSEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYUSEXC" AS
/* $Header: pyusexc.pkb 120.0.12010000.2 2009/01/09 12:15:10 sudedas ship $ */
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

    Name        : pyusexc.pkb

    Description : PaYroll US legislation EXpiry Checking code.
                  Contains the expiry checking code associated with the US
                  balance dimensions.  Following the change
                  to latest balance functionality, these need to be contained
                  as packaged procedures.

    Change List
    -----------
    Date        Name       Vers   Bug No  Description
    ----------- ---------- ------ ------- --------------------------------------
    23-SEP-1994 spanwar                   First created.
    10-JUL-1995 spanwar                   Changed RUN level check to not expire
                                          if the user and owner payroll action
                                          id's are the same.
    21-NOV-1995 hparicha                  Now handles "Lifetime to Date" dim
			                        without failure.
    27-FEB-1996 ssdesai           333439  Date format was dd-mon-yy.
    30-JUL-1996 jalloun                   Added error handling.
    19-SEP-2000 djoshi                    Added overloded date_ec funtion
                                          and modified the file to pass
                                          check_sql tests.
    14-JUN-2001 mreid             1808057 Changed date in LTD check to canonical
    14-MAR-2005 saurgupt          4100637 Changed the function next_fiscal_year
                                          Modified the code to work for leap
                                          year. Also, made the gscc changes.
    18-MAY-2005 ahanda     115.6          Added procedure start_tdptd_date.
    09-Jan-2009 sudedas    115.7  7029830 Modified next_fiscal_year to
                                          consider both Leap Year and Non Leap
                                          Year scenarios.

*/

/*---------------------------- next_period  -----------------------------------
   NAME
      next_period
   DESCRIPTION
      Given a date and a payroll action id, returns the date of the day after
      the end of the containing pay period.
   NOTES
      <none>
*/
FUNCTION next_period
(
   p_pactid      IN  NUMBER,
   p_date        IN  DATE
) RETURN DATE is
   l_return_val DATE;
BEGIN

   l_return_val := NULL;

   select TP.end_date + 1
   into   l_return_val
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid
   and    PACT.payroll_id = TP.payroll_id
   and    p_date between TP.start_date and TP.end_date;

   RETURN l_return_val;

END next_period;

/*---------------------------- next_month  ------------------------------------
   NAME
      next_month
   DESCRIPTION
      Given a date, returns the date of the first day of the next month.
   NOTES
      <none>
*/
FUNCTION next_month
(
   p_date        IN  DATE
) return DATE is
BEGIN

  RETURN trunc(add_months(p_date,1),'MM');

END next_month;

/*--------------------------- next_quarter  -----------------------------------
   NAME
      next_quarter
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      quarter.
   NOTES
      <none>
*/
FUNCTION next_quarter
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,3),'Q');

END next_quarter;

/*---------------------------- next_year  ------------------------------------
   NAME
      next_year
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      year.
   NOTES
      <none>
*/
FUNCTION next_year
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,12),'Y');

END next_year;

/*------------------------- next_fiscal_quarter  -----------------------------
   NAME
      next_fiscal_quarter
   DESCRIPTION
      Given a date, returns the date of the first day of the next fiscal
      quarter.
   NOTES
      <none>
*/
FUNCTION next_fiscal_quarter
(
   p_beg_of_fiscal_year  IN  DATE,
   p_date                IN  DATE
) RETURN DATE is

-- get offset of fiscal year start in relative months and days
  l_fy_rel_month NUMBER(2);
  l_fy_rel_day   NUMBER(2);

BEGIN

  l_fy_rel_month := to_char(p_beg_of_fiscal_year, 'MM') - 1;
  l_fy_rel_day   := to_char(p_beg_of_fiscal_year, 'DD') - 1;

  RETURN (add_months(next_quarter(add_months(p_date, -l_fy_rel_month)
                                  - l_fy_rel_day),
                     l_fy_rel_month) + l_fy_rel_day);

END next_fiscal_quarter;

/*--------------------------- next_fiscal_year  ------------------------------
   NAME
      next_fiscal_year
   DESCRIPTION
      Given a date, returns the date of the first day of the next fiscal year.
   NOTES
      <none>
*/
FUNCTION next_fiscal_year
(
   p_beg_of_fiscal_year  IN  DATE,
   p_date                IN  DATE
) RETURN DATE is

-- get offset of fiscal year start relative to calendar year
  l_fiscal_year_offset   NUMBER(3);
  ln_bal_yr              PLS_INTEGER;
  ln_bg_fiscal_yr        PLS_INTEGER;
  lb_bal_yr_leapyr       BOOLEAN DEFAULT FALSE;
  lb_bg_fiscal_yr_leapyr BOOLEAN DEFAULT FALSE;

BEGIN
  ln_bal_yr := fnd_number.canonical_to_number(TO_CHAR(p_date, 'YYYY'));
  ln_bg_fiscal_yr := fnd_number.canonical_to_number(TO_CHAR(p_beg_of_fiscal_year, 'YYYY'));

  -- Checking whether year of balance is Leap Year

  if mod(ln_bal_yr, 100) = 0 then
    if mod(ln_bal_yr, 400) = 0 then
       lb_bal_yr_leapyr := TRUE;
    else
       lb_bal_yr_leapyr := FALSE;
    end if;
  else
     if mod(ln_bal_yr, 4) = 0 then
        lb_bal_yr_leapyr := TRUE;
     else
        lb_bal_yr_leapyr := FALSE;
     end if;
  end if;

  -- Checking whether business group fiscal year is Leap Year

  if mod(ln_bg_fiscal_yr, 100) = 0 then
    if mod(ln_bg_fiscal_yr, 400) = 0 then
       lb_bg_fiscal_yr_leapyr := TRUE;
    else
       lb_bg_fiscal_yr_leapyr := FALSE;
    end if;
  else
     if mod(ln_bg_fiscal_yr, 4) = 0 then
        lb_bg_fiscal_yr_leapyr := TRUE;
     else
        lb_bg_fiscal_yr_leapyr := FALSE;
     end if;
  end if;

  --l_fiscal_year_offset := to_char(p_beg_of_fiscal_year, 'DDD') - 1;

   /* Four possible scenarios
   Balance year Leap Yr + BG Fiscal Year Leap Yr
   Balance year NOT Leap Yr + BG Fiscal Year NOT Leap Yr
   Balance year NOT Leap Yr + BG Fiscal Year Leap Yr
   Balance year Leap Yr + BG Fiscal Year NOT Leap Yr
   */

  if (lb_bal_yr_leapyr and lb_bg_fiscal_yr_leapyr) or
     (NOT(lb_bal_yr_leapyr) and NOT(lb_bg_fiscal_yr_leapyr)) or
     (NOT(lb_bal_yr_leapyr) and lb_bg_fiscal_yr_leapyr) then

     l_fiscal_year_offset := to_char(p_beg_of_fiscal_year, 'DDD') - 1;

  elsif (lb_bal_yr_leapyr and NOT(lb_bg_fiscal_yr_leapyr)) then
     l_fiscal_year_offset := to_char(p_beg_of_fiscal_year, 'DDD');
  end if;

  -- Bug 4100637: Instead of adding the offset to get the next
  -- fiscal year date, just concatenated the current year
  -- with the fiscal start month and date. Adding offset gives
  -- one day less in case of leap year.

  RETURN fnd_date.canonical_to_date(
            to_char(next_year(p_date - l_fiscal_year_offset),'RRRR')||
            substr(fnd_date.date_to_canonical(p_beg_of_fiscal_year),5,6));
--  RETURN (next_year(p_date - l_fiscal_year_offset) + l_fiscal_year_offset);

END next_fiscal_year;

/*------------------------------ date_ec  ------------------------------------
   NAME
      date_ec
   DESCRIPTION
      Expiry checking code for the following date-related dimensions:
        Assignment/Person/neither and GRE/not GRE and
        Run/Period TD/Month/Quarter TD/Year TD/Fiscal Quarter TD/
          Fiscal Year TD
   NOTES
      This procedure assumes the date portion of the dimension name
      is always at the end to allow accurate identification since
      this is used for many dimensions.
*/
PROCEDURE date_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information        out nocopy number    -- dimension expired flag.
) is

  l_beg_of_fiscal_year DATE;
  l_expiry_date DATE;

BEGIN

  l_beg_of_fiscal_year := NULL;
  l_expiry_date := NULL;

  IF p_dimension_name like '%Run' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
      l_expiry_date := p_user_effective_date; -- always must expire.
    ELSE
      p_expiry_information := 0;
      RETURN;
    END IF;

  ELSIF p_dimension_name like '%Payments%' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
      l_expiry_date := p_user_effective_date; -- always must expire.
    ELSE
          p_expiry_information := 0;    -- daj
      RETURN;
    END IF;

  ELSIF p_dimension_name like '%Period to Date' THEN
    l_expiry_date := next_period(p_owner_payroll_action_id,
                                 p_owner_effective_date);

  ELSIF p_dimension_name like '%Month' THEN
    l_expiry_date := next_month(p_owner_effective_date);

  ELSIF p_dimension_name like '%Fiscal Quarter to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    l_expiry_date := next_fiscal_quarter(l_beg_of_fiscal_year,
                                         p_owner_effective_date);

  ELSIF p_dimension_name like '%Fiscal Year to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    l_expiry_date := next_fiscal_year(l_beg_of_fiscal_year,
                                      p_owner_effective_date);

  ELSIF p_dimension_name like '%Quarter to Date' THEN
    l_expiry_date := next_quarter(p_owner_effective_date);

  ELSIF p_dimension_name like '%Year to Date' THEN
    l_expiry_date := next_year(p_owner_effective_date);

  ELSIF p_dimension_name like '%Lifetime to Date' THEN
    p_expiry_information := 0;
    RETURN;

  ELSE
    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_THIS_DIMENSION');
    hr_utility.raise_error;

  END IF;

  IF p_user_effective_date >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
      p_expiry_information := 0;
  END IF;

END date_ec;


/* This procedure is the overlaoded function that will take care of the
   of the requirement of Balance adjustment process.*/
PROCEDURE date_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information        out   nocopy  Date       -- dimension expired date.
) is

  l_beg_of_fiscal_year DATE;
  l_expiry_date DATE;

BEGIN

  l_beg_of_fiscal_year := NULL;
  l_expiry_date := NULL;

  If p_dimension_name like '%Run' THEN

-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.

      p_expiry_information := p_owner_effective_date;

  ELSIF p_dimension_name like '%Payments%' THEN

      p_expiry_information  := p_owner_effective_date;


  ELSIF p_dimension_name like '%Period to Date' THEN

    p_expiry_information  := next_period(p_owner_payroll_action_id,
                                 p_owner_effective_date) -  1;

  ELSIF p_dimension_name like '%Month' THEN

    p_expiry_information  := next_month(p_owner_effective_date) - 1;

  ELSIF p_dimension_name like '%Fiscal Quarter to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    p_expiry_information  := next_fiscal_quarter(l_beg_of_fiscal_year,
                                         p_owner_effective_date) - 1;

  ELSIF p_dimension_name like '%Fiscal Year to Date' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    p_expiry_information  := next_fiscal_year(l_beg_of_fiscal_year,
                                      p_owner_effective_date) - 1;


  ELSIF p_dimension_name like '%Quarter to Date' THEN

      p_expiry_information  := next_quarter(p_owner_effective_date) - 1;

  ELSIF p_dimension_name like '%Year to Date' THEN

    p_expiry_information  := next_year(p_owner_effective_date) -1;

  ELSIF p_dimension_name like '%Lifetime to Date' THEN

    p_expiry_information := fnd_date.canonical_to_date('4712/12/31');

  ELSE

    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_THIS_DIMENSION');
    hr_utility.raise_error;

  END IF;

END date_ec;  /* date p_expiry information procedure overloaded function */


/*************************************************************************
** Description - Procedure returns the start date for Time Definition
**               Period to Date which is run for validation the Run
**               Balance validation date
**   Arguments -
**               p_start_date - effective date of payroll action
**               p_payroll_id - payroll_id
**               p_bus_grp    - Business Group ID
**               p_asg_action - Assignment Action ID
*************************************************************************/
PROCEDURE start_tdptd_date(p_effective_date IN  DATE
                          ,p_start_date     OUT NOCOPY DATE
                          ,p_payroll_id     IN  NUMBER DEFAULT NULL
                          ,p_bus_grp        IN  NUMBER DEFAULT NULL
                          ,p_asg_action     IN  NUMBER DEFAULT NULL)
IS

  cursor c_asg_data(cp_asg_action in number) is
    select nvl(ppa.date_earned, ppa.effective_date)
          ,paa.assignment_id
      from pay_assignment_actions paa
          ,pay_payroll_actions ppa
     where paa.assignment_action_id = cp_asg_action
       and ppa.payroll_action_id = paa.payroll_Action_id;

  cursor c_td_start_date(cp_time_definition_id number
                        ,cp_date_earned        date) is
    select ptp.start_date
      from per_time_periods ptp
     where ptp.time_definition_id = cp_time_definition_id
       and cp_date_earned between ptp.start_date
                              and ptp.end_date;

  ln_time_definition_id  NUMBER;
  ln_assignment_id       NUMBER;
  ld_date_earned         DATE;
  ld_start_date          DATE;

BEGIN
  ld_date_earned := p_effective_date;

  open c_asg_data(p_asg_action);
  fetch c_asg_data into ld_date_earned, ln_assignment_id;
  close c_asg_data;

  pay_us_rules.get_time_def_for_entry (
                p_element_entry_id     => null
               ,p_assignment_id        => ln_assignment_id
               ,p_assignment_action_id => p_asg_action
               ,p_business_group_id    => p_bus_grp
               ,p_time_definition_id   => ln_time_definition_id);

  open c_td_start_date(ln_time_definition_id, ld_date_earned);
  fetch c_td_start_date into ld_start_date;
  close c_td_start_date;

  p_start_date := ld_start_date;

END start_tdptd_date;

end pyusexc;

/
