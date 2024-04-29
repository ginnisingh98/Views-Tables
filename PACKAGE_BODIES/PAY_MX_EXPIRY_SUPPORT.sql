--------------------------------------------------------
--  DDL for Package Body PAY_MX_EXPIRY_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_EXPIRY_SUPPORT" AS
/*$Header: paymxbalexpccode.pkb 120.0 2005/05/29 11:49:44 appldev noship $
*/
/*---------------------------- next_bimonth_period  ----------------------------
   NAME
      next_bimonth_period
   DESCRIPTION
      Given a date and a payroll action id, returns the date of the day after
      the end of the containing pay period.
   NOTES
      <none>
*/
FUNCTION next_bimonth_period
(
   p_pactid      IN  NUMBER,
   p_date        IN  DATE
) RETURN DATE is
   l_return_val DATE := NULL;
BEGIN
   SELECT TRUNC(ADD_MONTHS(p_date, DECODE(MOD(TO_CHAR(p_date, 'MM'),2),
                                    0, 1,
                                       2)), 'MM')
   INTO   l_return_val
   FROM   pay_payroll_actions
   WHERE  payroll_action_id = p_pactid
   AND    effective_date = p_date;

   RETURN l_return_val;

END next_bimonth_period;
/*------------------------------ date_ec  ------------------------------------
   NAME
      date_ec
   DESCRIPTION
      Mexico specific Expiry checking code for the following date-related
      dimensions:
        Person and GRE and Bi-Month.
      The Expiry checking code for the rest of the dimensions uses functions
      delivered in PAY_IP_EXPIRY_SUPPORT.


   NOTES
      This procedure assumes the date portion of the dimension name
      is always at the end to allow accurate identification since
      this is used for many dimensions.
*/
PROCEDURE date_ec
(
   p_owner_payroll_action_id    IN     NUMBER,   -- run created balance.
   p_user_payroll_action_id     IN     NUMBER,   -- current run.
   p_owner_assignment_action_id IN     NUMBER,   -- assact created balance.
   p_user_assignment_action_id  IN     NUMBER,   -- current assact..
   p_owner_effective_date       IN     DATE,     -- eff date of balance.
   p_user_effective_date        IN     DATE,     -- eff date of current run.
   p_dimension_name             IN     VARCHAR2, -- balance dimension name.
   p_expiry_information         OUT NOCOPY NUMBER-- dimension expired flag.
) is

  l_beg_of_fiscal_year DATE := NULL;
  l_expiry_date DATE := NULL;

BEGIN

  IF p_dimension_name like '%Social Security Bi-Month' THEN
    l_expiry_date := next_bimonth_period(p_owner_payroll_action_id,
                                         p_owner_effective_date);
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
   p_owner_payroll_action_id    IN     NUMBER,   -- run created balance.
   p_user_payroll_action_id     IN     NUMBER,   -- current run.
   p_owner_assignment_action_id IN     NUMBER,   -- assact created balance.
   p_user_assignment_action_id  IN     NUMBER,   -- current assact..
   p_owner_effective_date       IN     DATE,     -- eff date of balance.
   p_user_effective_date        IN     DATE,     -- eff date of current run.
   p_dimension_name             IN     VARCHAR2, -- balance dimension name.
   p_expiry_information        OUT NOCOPY DATE   -- dimension expired date.
) is

  l_beg_of_fiscal_year DATE := NULL;
  l_expiry_date DATE := NULL;

BEGIN


  IF p_dimension_name like '%Social Security Bi-Month' THEN
    p_expiry_information := next_bimonth_period(p_owner_payroll_action_id,
                                                p_owner_effective_date);
  ELSE

    hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_THIS_DIMENSION');
    hr_utility.raise_error;

  END IF;


END date_ec;  /* date p_expiry information procedure overloaded function */
END pay_mx_expiry_support;

/
