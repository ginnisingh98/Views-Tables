--------------------------------------------------------
--  DDL for Package Body PAY_SG_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_EXC" AS
/* $Header: pysgexch.pkb 120.0 2005/05/29 08:46:02 appldev noship $ */
/*
  PRODUCT
     Oracle*Payroll
  NAME
     pysgexch.pkb - Payroll SG legislation Expiry Checking code.
  DESCRIPTION
     Contains the expiry checking code associated with the SG
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
   jbailie    25/04/00 - first created. Based on PAYUSEXC (115)

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
      Expiry checking code for the Singapore dimensions:
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
   p_expiry_information            out nocopy number    -- dimension expired flag.
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

  ELSIF p_dimension_name like '%QTD' THEN
    l_expiry_date := next_quarter(p_owner_effective_date);

  ELSIF p_dimension_name like '%YTD' THEN
    l_expiry_date := next_year(p_owner_effective_date);

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


/*------------------------------ date_ec  ------------------------------------

   NAME
      date_ec
   DESCRIPTION
      Expiry checking code for the Singapore dimensions:
   NOTES
      This procedure assumes the date portion of the dimension name
      is always at the end to allow accurate identification since
      this is used for many dimensions.
      This procedure has been added for Balance Adjustment Process Enhancement,
      Bug 2797863
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

   p_expiry_information         out    nocopy date -- dimension expired date.

) is

  l_beg_of_fiscal_year DATE := NULL;
  l_expiry_date        DATE := NULL;

BEGIN

  hr_utility.set_location('Entering: date_ec', 10);
  hr_utility.set_location('p_owner_payroll_action_id :'||p_owner_payroll_action_id, 20);
  hr_utility.set_location('p_user_payroll_action_id :'||p_user_payroll_action_id, 20);
  hr_utility.set_location('p_owner_assignment_action_id :'||p_owner_assignment_action_id, 20);
  hr_utility.set_location('p_user_assignment_action_id :'||p_user_assignment_action_id, 20);
  hr_utility.set_location('p_owner_effective_date :'||p_owner_effective_date, 20);
  hr_utility.set_location('p_user_effective_date :'||p_user_effective_date, 20);
  hr_utility.set_location('p_dimension_name :'||p_dimension_name, 20);

  IF p_dimension_name like '%RUN' THEN
-- must check for special case:  if payroll action id's are the same,
-- then don't expire.  This facilitates meaningful access of these
-- balances outside of runs.

    p_expiry_information := p_owner_effective_date;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%PAYMENTS' THEN

    p_expiry_information := p_owner_effective_date;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%PTD' THEN

    p_expiry_information := next_period(p_owner_payroll_action_id,
                                p_owner_effective_date) - 1;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%MONTH' THEN

    p_expiry_information := next_month(p_owner_effective_date) -1 ;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

 ELSIF p_dimension_name like '%FQTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    p_expiry_information := next_fiscal_quarter(l_beg_of_fiscal_year,
         p_owner_effective_date) - 1;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%FYTD' THEN
    SELECT fnd_date.canonical_to_date(org_information11)
    INTO   l_beg_of_fiscal_year
    FROM   pay_payroll_actions PACT,
           hr_organization_information HOI
    WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'

    AND    HOI.organization_id = PACT.business_group_id
    AND    PACT.payroll_action_id = p_owner_payroll_action_id;

    p_expiry_information := next_fiscal_year(l_beg_of_fiscal_year, p_owner_effective_date) - 1;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%QTD' THEN

    p_expiry_information := next_quarter(p_owner_effective_date) - 1;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%YTD' THEN

    p_expiry_information := next_year(p_owner_effective_date) - 1;
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSIF p_dimension_name like '%LTD' THEN

    p_expiry_information := fnd_date.canonical_to_date('4712/12/31');
    hr_utility.set_location('p_expiry_information'||p_dimension_name||':'||p_expiry_information, 30);

  ELSE

    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_DIMENSION');
    hr_utility.raise_error;

  END IF;

  hr_utility.set_location('Ending: date_ec', 40);

END date_ec; /* bug 2797863 */


FUNCTION get_expiry_date
(
   p_defined_balance_id         in     number,   -- defined balance.
   p_assignment_action_id       in     number    -- assact created balance.
) RETURN DATE is

  l_dimension_name     VARCHAR2(160);
  l_payroll_action_id  NUMBER;
  l_effective_date     DATE := NULL;
  l_beg_of_fiscal_year DATE := NULL;
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

  ELSIF l_dimension_name like '%QTD' THEN
    RETURN next_quarter(l_effective_date) - 1;

  ELSIF l_dimension_name like '%YTD' THEN
    RETURN next_year(l_effective_date) - 1;

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
   p_assignment_action_id       in     number,    -- assact created balance.
   p_tax_unit_id                in     number,
   p_session_date               in     date
) RETURN NUMBER is

  l_calculated_value   NUMBER;
  l_expiry_date        DATE := NULL;

BEGIN

    l_calculated_value := pay_balance_pkg.get_value(p_defined_balance_id
                                                   ,p_assignment_action_id
                                                   ,p_tax_unit_id
                                                   ,null --jurisdiction
                                                   ,null --source_id
                                                   ,null --tax_group
                                                   ,null --date_earned
                                                   );

    l_expiry_date := get_expiry_date(p_defined_balance_id, p_assignment_action_id);

    IF p_session_date > l_expiry_date THEN
       l_calculated_value := 0;
    END IF;

    RETURN l_calculated_value;

END calculated_value;



END pay_sg_exc;

/
