--------------------------------------------------------
--  DDL for Package Body PAY_HK_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_EXC" AS
/* $Header: pyhkexch.pkb 120.1 2007/11/16 10:35:48 vamittal noship $ */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pyhkexch.pkb - PaYroll HK legislation EXpiry Checking code.
  DESCRIPTION
     Contains the expiry checking code associated with the HK
     balance dimensions.  Following the change
     to latest balance functionality, these need to be contained
     as packaged procedures.
  PUBLIC FUNCTIONS
     <none>
  PRIVATE FUNCTIONS
     <none>
  NOTES
     <none>
  MODIFIED (DD/MM/YY)
   jbailie    21/09/00 - first created. Based on PAYSGEXC (115)

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
   l_return_val DATE := NULL;
BEGIN
   select TP.end_date + 1
   into   l_return_val
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid
   and    PACT.payroll_id = TP.payroll_id
   and    p_date between TP.start_date and TP.end_date;

   RETURN l_return_val;

END next_period;

/*---------------------------- next_ri_period  -----------------------------------
   NAME
      next_ri_period
   DESCRIPTION
      Given a payroll action id, returns the date of the day after
      the end of the containing pay period.
   NOTES
      <none>
*/
FUNCTION next_ri_period
(
   p_pactid      IN  NUMBER
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   select TP.end_date + 1
   into   l_return_val
   from   per_time_periods TP,
          pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid
   and    PACT.payroll_id = TP.payroll_id
   and    PACT.date_earned between TP.start_date and TP.end_date;

   RETURN l_return_val;

END next_ri_period;

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

/*---------------------------- next_ri_month  ------------------------------------
   NAME
      next_ri_month
   DESCRIPTION
      Given a date, returns the date of the first day of the next month.
   NOTES
      <none>
*/
FUNCTION next_ri_month
(
   p_pactid      IN  NUMBER
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   select trunc(add_months(PACT.date_earned,1),'MM')
   into   l_return_val
   from   pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid;

  RETURN l_return_val;

END next_ri_month;

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

/*--------------------------- next_ri_quarter  -----------------------------------
   NAME
      next_ri_quarter
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      quarter.
   NOTES
      <none>
*/
FUNCTION next_ri_quarter
(
   p_pactid      IN  NUMBER
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   select trunc(add_months(PACT.date_earned,3),'Q')
   into   l_return_val
   from   pay_payroll_actions PACT
   where  PACT.payroll_action_id = p_pactid;

  RETURN l_return_val;

END next_ri_quarter;

/*---------------------------- next_calendar_year  ------------------------------------
   NAME
      next_calendar_year
   DESCRIPTION
      Given a date, returns the date of the first day of the next calendar
      year.
   NOTES
      <none>
*/
FUNCTION next_calendar_year
(
   p_date        IN  DATE
) RETURN DATE is
BEGIN

  RETURN trunc(add_months(p_date,12),'Y');

END next_calendar_year;

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

BEGIN

  RETURN (add_months(p_beg_of_fiscal_year, 3*(ceil(months_between(p_date+1,p_beg_of_fiscal_year)/3))));

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

BEGIN

  RETURN (add_months(p_beg_of_fiscal_year, 12*(ceil(months_between(p_date+1,p_beg_of_fiscal_year)/12))));

END next_fiscal_year;
/*------------------------------ date_ec  ------------------------------------
   NAME
      date_ec
   DESCRIPTION
      Expiry checking code for the Hong Kong dimensions:
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
   p_expiry_information         out nocopy number    -- dimension expired flag.
) is

  l_beg_of_fiscal_year DATE := NULL;
  l_expiry_date        DATE := NULL;

BEGIN

  IF p_dimension_name like '%RUN' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
      l_expiry_date := p_user_effective_date; -- always must expire.
    ELSE
      p_expiry_information := 0;
      RETURN;
    END IF;

  ELSIF p_dimension_name like '%PAYMENTS' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.
    IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
      l_expiry_date := p_user_effective_date; -- always must expire.
    ELSE
      p_expiry_information := 0;
      RETURN;
    END IF;

  ELSIF p_dimension_name like '%MPF_PTD' THEN
    l_expiry_date := next_ri_period(p_owner_payroll_action_id);

  ELSIF p_dimension_name like '%MPF_MONTH' THEN
    l_expiry_date := next_ri_month(p_owner_payroll_action_id);

  ELSIF p_dimension_name like '%MPF_QTD' THEN
    l_expiry_date := next_ri_quarter(p_owner_payroll_action_id);

  ELSIF p_dimension_name like '%MPF_YTD' THEN
    SELECT to_date('01-04-'||to_char(fnd_number.canonical_to_number(
           to_char(PACT.date_earned,'YYYY'))+ decode(sign(PACT.date_earned
            - to_date('01-04-'||to_char(PACT.date_earned,'YYYY'),'DD-MM-YYYY'))
            ,-1,0,1)),'DD-MM-YYYY')
    INTO   l_expiry_date
    FROM   pay_payroll_actions PACT
    WHERE  PACT.payroll_action_id = p_owner_payroll_action_id;

  ELSIF p_dimension_name like '%PTD' THEN
    l_expiry_date := next_period(p_owner_payroll_action_id,
 p_owner_effective_date);

  ELSIF p_dimension_name like '%MONTH' THEN
    l_expiry_date := next_month(p_owner_effective_date);

  ELSIF p_dimension_name like '%FQTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    l_expiry_date := next_fiscal_quarter(l_beg_of_fiscal_year,
         p_owner_effective_date);

  ELSIF p_dimension_name like '%FYTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    l_expiry_date := next_fiscal_year(l_beg_of_fiscal_year,
      p_owner_effective_date);

  ELSIF p_dimension_name like '%_CAL_YTD' THEN
    l_expiry_date := next_calendar_year(p_owner_effective_date);

  ELSIF p_dimension_name like '%QTD' THEN
    l_expiry_date := next_quarter(p_owner_effective_date);

  ELSIF p_dimension_name like '%YTD' THEN
    SELECT to_date('01-04-'||to_char(fnd_number.canonical_to_number(
           to_char(PACT.effective_date,'YYYY'))+ decode(sign(PACT.effective_date
            - to_date('01-04-'||to_char(PACT.effective_date,'YYYY'),'DD-MM-YYYY'))
            ,-1,0,1)),'DD-MM-YYYY')
    INTO   l_expiry_date
    FROM   pay_payroll_actions PACT
    WHERE  PACT.payroll_action_id = p_owner_payroll_action_id;

  ELSIF p_dimension_name like '%LTD' THEN
    p_expiry_information := 0;
    RETURN;

  ELSE
    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_DIMENSION');
    hr_utility.raise_error;

  END IF;

  IF p_user_effective_date >= l_expiry_date THEN
    p_expiry_information := 1;
  ELSE
    p_expiry_information := 0;
  END IF;

END date_ec;


FUNCTION get_expiry_date
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number    -- assact created balance.
) RETURN DATE is

  l_dimension_name     VARCHAR2(160);
  l_payroll_action_id  NUMBER;
  l_effective_date     DATE := NULL;
  l_beg_of_fiscal_year DATE := NULL;
  l_beg_of_tax_year    DATE := NULL;
  l_end_of_time        CONSTANT DATE := to_date('31/12/4712','DD/MM/YYYY');

  cursor dimension_name( c_defined_balance_id in number ) is
  SELECT dimension_name
  FROM   pay_defined_balances pdb
       , pay_balance_dimensions pbd
  WHERE  pdb.balance_dimension_id = pbd.balance_dimension_id
  AND    pdb.defined_balance_id = c_defined_balance_id;

  cursor pact_effective_date( c_assignment_action_id in number ) is
  SELECT ppa.payroll_action_id, ppa.effective_date
  FROM   pay_payroll_actions ppa, pay_assignment_actions paa
  WHERE  ppa.payroll_action_id = paa.payroll_action_id
  AND    paa.assignment_action_id = c_assignment_action_id;

BEGIN
--
  open dimension_name ( p_defined_balance_id );
  fetch dimension_name into l_dimension_name;
  close dimension_name;
--
  open pact_effective_date ( p_assignment_action_id );
  fetch pact_effective_date into l_payroll_action_id, l_effective_date;
  close pact_effective_date;
--
  IF l_dimension_name like '%RUN' THEN
-- must check for special case:  Will always expire on date of run.
    RETURN l_effective_date; -- always must expire.

  ELSIF l_dimension_name like '%PAYMENTS' THEN
-- must check for special case:  Will always expire on date of run.
    RETURN l_effective_date; -- always must expire.

  ELSIF l_dimension_name like '%MPF_PTD' THEN
-- this will expire at the end of the period
    RETURN next_ri_period(l_payroll_action_id) - 1;

  ELSIF l_dimension_name like '%MPF_MONTH' THEN
-- this will expire at the end of the month
    RETURN next_ri_month(l_payroll_action_id) - 1;

  ELSIF l_dimension_name like '%MPF_QTD' THEN
    RETURN next_ri_quarter(l_payroll_action_id) - 1;

  ELSIF l_dimension_name like '%MPF_YTD' THEN
    SELECT to_date('01-04-'||to_char(fnd_number.canonical_to_number(
           to_char(PACT.date_earned,'YYYY'))+ decode(sign(PACT.date_earned
            - to_date('01-04-'||to_char(PACT.date_earned,'YYYY'),'DD-MM-YYYY'))
            ,-1,0,1)),'DD-MM-YYYY')
    INTO   l_beg_of_tax_year
    FROM   pay_payroll_actions PACT
    WHERE  PACT.payroll_action_id = l_payroll_action_id;

    RETURN l_beg_of_tax_year - 1;

  ELSIF l_dimension_name like '%PTD' THEN
-- this will expire at the end of the period
    RETURN next_period(l_payroll_action_id, l_effective_date) - 1;

  ELSIF l_dimension_name like '%MONTH' THEN
-- this will expire at the end of the month
    RETURN next_month(l_effective_date) - 1;

  ELSIF l_dimension_name like '%FQTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = l_payroll_action_id;

    RETURN next_fiscal_quarter(l_beg_of_fiscal_year, l_effective_date) - 1;

  ELSIF l_dimension_name like '%FYTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = l_payroll_action_id;

    RETURN next_fiscal_year(l_beg_of_fiscal_year, l_effective_date) - 1;

  ELSIF l_dimension_name like '%_CAL_YTD' THEN
    RETURN next_calendar_year(l_effective_date) - 1;

  ELSIF l_dimension_name like '%QTD' THEN
    RETURN next_quarter(l_effective_date) - 1;

  ELSIF l_dimension_name like '%YTD' THEN
    SELECT to_date('01-04-'||to_char(fnd_number.canonical_to_number(
           to_char(PACT.effective_date,'YYYY'))+ decode(sign(PACT.effective_date
            - to_date('01-04-'||to_char(PACT.effective_date,'YYYY'),'DD-MM-YYYY'))
            ,-1,0,1)),'DD-MM-YYYY')
    INTO   l_beg_of_tax_year
    FROM   pay_payroll_actions PACT
    WHERE  PACT.payroll_action_id = l_payroll_action_id;

    RETURN l_beg_of_tax_year - 1;

  ELSIF l_dimension_name like '%LTD' THEN
    RETURN l_end_of_time;

  ELSE
    hr_utility.set_message(801, 'NO_EXPIRY_DATE_FOR_DIMENSION');
    hr_utility.raise_error;

  END IF;

END get_expiry_date;


FUNCTION calculated_value
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number,   -- assact created balance.
   p_tax_unit_id                in     number,   -- tax_unit
   p_source_id                  in     number,   -- source_id
   p_session_date               in     date
) RETURN NUMBER is

  l_calculated_value   NUMBER;
  l_expiry_date        DATE := NULL;

BEGIN

    l_calculated_value := pay_balance_pkg.get_value(p_defined_balance_id
                                                   ,p_assignment_action_id
                                                   ,p_tax_unit_id
                                                   ,null -- jurisdiction
                                                   ,p_source_id
                                                   ,null -- tax_group
                                                   ,null -- effective_date
                                                   );

    l_expiry_date := get_expiry_date(p_defined_balance_id, p_assignment_action_id);

    IF p_session_date > l_expiry_date THEN
       l_calculated_value := 0;
    END IF;

    RETURN l_calculated_value;

END calculated_value;


PROCEDURE date_ec
(
   p_owner_payroll_action_id    in         number,   -- run created balance.
   p_user_payroll_action_id     in         number,   -- current run.
   p_owner_assignment_action_id in         number,   -- assact created balance.
   p_user_assignment_action_id  in         number,   -- current assact.
   p_owner_effective_date       in         date,     -- eff date of balance.
   p_user_effective_date        in         date,     -- eff date of current run.
   p_dimension_name             in         varchar2, -- balance dimension name.
   p_expiry_date                out nocopy date      -- dimension expired date.
) is

   l_dimension_name     VARCHAR2(160);
   l_payroll_action_id  NUMBER;
   l_effective_date     DATE := NULL;
   l_beg_of_fiscal_year DATE := NULL;
   l_beg_of_tax_year    DATE := NULL;
   l_end_of_time        CONSTANT DATE := to_date('31/12/4712','DD/MM/YYYY');

BEGIN

   hr_utility.trace('Entered the procedure date_ec');
   hr_utility.trace('p_owner_payroll_action_id    ===>' || p_owner_payroll_action_id);
   hr_utility.trace('p_user_payroll_action_id     ===>' || p_user_payroll_action_id);
   hr_utility.trace('p_owner_assignment_action_id ===>' || p_owner_assignment_action_id);
   hr_utility.trace('p_user_assignment_action_id  ===>' || p_user_assignment_action_id);
   hr_utility.trace('p_owner_effective_date       ===>' || p_owner_effective_date);
   hr_utility.trace('p_user_effective_date        ===>' || p_user_effective_date);
   hr_utility.trace('p_dimension_name             ===>' || p_dimension_name);

   IF p_dimension_name like '%MPF_PTD' THEN
      p_expiry_date := next_ri_period(p_owner_payroll_action_id) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%MPF_MONTH' THEN
      p_expiry_date := next_ri_month(p_owner_payroll_action_id) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%MPF_QTD' THEN
      p_expiry_date := next_ri_quarter(p_owner_payroll_action_id) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%MPF_YTD' THEN
      SELECT  to_date('01-04-'||to_char(fnd_number.canonical_to_number(
              to_char(PACT.date_earned,'YYYY'))+ decode(sign(PACT.date_earned
              - to_date('01-04-'||to_char(PACT.date_earned,'YYYY'),'DD-MM-YYYY'))
              ,-1,0,1)),'DD-MM-YYYY') - 1
        INTO  p_expiry_date
        FROM  pay_payroll_actions PACT
       WHERE  PACT.payroll_action_id = p_owner_payroll_action_id;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%PTD' THEN
      p_expiry_date := next_period(p_owner_payroll_action_id,p_owner_effective_date) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%MONTH' THEN
      p_expiry_date := next_month(p_owner_effective_date) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%FQTD' THEN
      SELECT  fnd_date.canonical_to_date(org_information11)
        INTO  l_beg_of_fiscal_year
        FROM  pay_payroll_actions PACT,
              hr_organization_information HOI
       WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
         AND  HOI.organization_id = PACT.business_group_id
         AND  PACT.payroll_action_id = p_owner_payroll_action_id;
      p_expiry_date := next_fiscal_quarter(l_beg_of_fiscal_year,p_owner_effective_date) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%FYTD' THEN
      SELECT  fnd_date.canonical_to_date(org_information11)
        INTO  l_beg_of_fiscal_year
        FROM  pay_payroll_actions PACT,
              hr_organization_information HOI
       WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
         AND  HOI.organization_id = PACT.business_group_id
         AND  PACT.payroll_action_id = p_owner_payroll_action_id;

   p_expiry_date := next_fiscal_year(l_beg_of_fiscal_year,p_owner_effective_date) - 1;
   hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%_CAL_YTD' THEN
      p_expiry_date := next_calendar_year(p_owner_effective_date) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%QTD' THEN
      p_expiry_date := next_quarter(p_owner_effective_date) - 1;
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSIF p_dimension_name like '%YTD' THEN
      SELECT  to_date('01-04-'||to_char(fnd_number.canonical_to_number(
              to_char(PACT.effective_date,'YYYY'))+ decode(sign(PACT.effective_date
              - to_date('01-04-'||to_char(PACT.effective_date,'YYYY'),'DD-MM-YYYY'))
              ,-1,0,1)),'DD-MM-YYYY') - 1
        INTO  p_expiry_date
        FROM  pay_payroll_actions PACT
       WHERE  PACT.payroll_action_id = p_owner_payroll_action_id;

   ELSIF p_dimension_name like '%LTD' THEN
      p_expiry_date :=  fnd_date.canonical_to_date('4712/12/31');
      hr_utility.trace('p_expiry_date                ===>' || p_expiry_date);

   ELSE
      hr_utility.trace('Entered Exception section');
      hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_DIMENSION');
      hr_utility.raise_error;

   END IF;

END date_ec;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_12MTHS_PREV                              --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for dimension  _ASG_12MTHS_PREV      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date       DATE                         --
--                  p_payroll_id           NUMBER                       --
--                  p_bus_grp              NUMBER                       --
--                  p_asg_action           NUMBER                       --
--            OUT : p_start_date           DATE                         --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
--      10-oct-2007  vamittal    Initial Version                        --
--------------------------------------------------------------------------
PROCEDURE start_code_12mths_prev( p_effective_date  IN         DATE
                                , p_start_date      OUT NOCOPY DATE
                                , p_payroll_id      IN         NUMBER
                                , p_bus_grp         IN         NUMBER
                                , p_asg_action      IN         NUMBER
                                )
IS
     l_start_date       DATE :=  NULL ;
     l_date_earned      DATE;
     l_assignment_id    pay_assignment_actions.assignment_id%TYPE;

     CURSOR get_date_earned
     IS
     SELECT ppa.date_earned,paa.assignment_id
     FROM
     pay_payroll_actions ppa,
     pay_assignment_actions paa
     WHERE paa.assignment_action_id = p_asg_action
     AND   ppa.payroll_action_id=paa.payroll_action_id;

BEGIN

    OPEN get_date_earned;
    FETCH get_date_earned INTO l_date_earned,l_assignment_id;
    CLOSE get_date_earned;

    /* To fetch the start_date from absence element*/
    l_start_date := pay_hk_avg_pay.specified_date_absence(l_date_earned,l_assignment_id);
    IF l_start_date IS NULL
       THEN
       /* If absence is not present then fetch the start_date from Specified Date element*/
       l_start_date := pay_hk_avg_pay.specified_date_element(l_date_earned,l_assignment_id);
       IF l_start_date IS NULL
           THEN
	   /* If absence is not present then consider start_date as the effectice_date */
           l_start_date := l_date_earned;

       END IF;
    END IF;

    l_start_date := add_months(l_start_date,-13);
    l_start_date := last_day(l_start_date) + 1;

END start_code_12mths_prev;

END pay_hk_exc;

/
