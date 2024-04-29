--------------------------------------------------------
--  DDL for Package Body PAY_CN_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_EXC" AS
/* $Header: pycnexc.pkb 120.0 2005/05/29 01:58:35 appldev noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_PERIOD                                         --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date and a payroll action id, returns the   --
--                  date of the day after the end of the                --
--                  containing pay period.                              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pactid        NUMBER                              --
--                  p_date          DATE                                --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_period ( p_pactid      IN  NUMBER
                     , p_date        IN  DATE
                     )
RETURN DATE
IS

   l_return_val DATE := NULL;

   CURSOR cur_end_date ( p_pactid NUMBER
                       , p_date   DATE
                       ) IS
   SELECT   TP.end_date + 1
     FROM   per_time_periods    TP
          , pay_payroll_actions PACT
    WHERE   PACT.payroll_action_id = p_pactid
      AND   PACT.payroll_id        = TP.payroll_id
      AND   p_date BETWEEN TP.start_date AND TP.end_date;

BEGIN

   OPEN cur_end_date ( p_pactid
                     , p_date
                     );
   FETCH cur_end_date INTO l_return_val;
   CLOSE cur_end_date;

   RETURN l_return_val;

EXCEPTION
   WHEN OTHERS THEN
      IF cur_end_date%ISOPEN THEN
         CLOSE cur_end_date;
      END IF;

   RAISE;
END next_period;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_MONTH                                          --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the next month.                                     --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date          DATE                                --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_month ( p_date  IN  DATE
                    )
RETURN DATE
IS

BEGIN

  RETURN TRUNC(add_months(p_date,1),'MM');

END next_month;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_FISCAL_QUARTER                                 --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date and fiscal year start returns the date --
--                  of the first day of the next fiscal quarter.        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_beg_of_fiscal_year  DATE                          --
--                : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_fiscal_quarter ( p_beg_of_fiscal_year  IN  DATE
                             , p_date                IN  DATE
                             )
RETURN DATE
IS

BEGIN

  RETURN (ADD_MONTHS( p_beg_of_fiscal_year
                    , 3*(CEIL(MONTHS_BETWEEN(p_date+1,p_beg_of_fiscal_year)/3))));

END next_fiscal_quarter;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_QUARTER                                        --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date and fiscal year start returns the date --
--                  of the first day of the next fiscal year.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_beg_of_fiscal_year  DATE                          --
--                : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_quarter ( p_date  IN  DATE
                      )
RETURN DATE
IS

BEGIN

  RETURN TRUNC(ADD_MONTHS(p_date,3),'Q');

END next_quarter;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_FISCAL_YEAR                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date and fiscal year start returns the date --
--                  of the first day of the next fiscal year.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_beg_of_fiscal_year  DATE                          --
--                : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_fiscal_year ( p_beg_of_fiscal_year  IN  DATE
                          , p_date                IN  DATE
                          )
RETURN DATE
IS

BEGIN

  RETURN (ADD_MONTHS( p_beg_of_fiscal_year
                    , 12*(CEIL(MONTHS_BETWEEN( p_date+1
                                             , p_beg_of_fiscal_year)/12))));

END next_fiscal_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_CALENDAR_YEAR                                  --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the next calendar year.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_calendar_year ( p_date        IN  DATE
                            )
RETURN DATE
IS

BEGIN

  RETURN TRUNC(ADD_MONTHS(p_date,12),'Y');

END next_calendar_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DATE_EC                                             --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure assumes the date portion of the      --
--                  dimension name is always at the end to allow        --
--                  accurate identification since this is used for many --
--                  dimensions.                                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_owner_payroll_action_id      NUMBER               --
--		    p_user_payroll_action_id       NUMBER               --
--		    p_owner_assignment_action_id   NUMBER               --
--		    p_user_assignment_action_id    NUMBER               --
--		    p_owner_effective_date         DATE                 --
--		    p_user_effective_date          DATE                 --
--		    p_dimension_name               VARCHAR2             --
--            OUT : p_expiry_information           NUMBER               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAR-03  saikrish  Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE date_ec ( p_owner_payroll_action_id    IN  NUMBER
                  , p_user_payroll_action_id     IN  NUMBER
                  , p_owner_assignment_action_id IN  NUMBER
                  , p_user_assignment_action_id  IN  NUMBER
                  , p_owner_effective_date       IN  DATE
                  , p_user_effective_date        IN  DATE
                  , p_dimension_name             IN  VARCHAR2
                  , p_expiry_information         OUT NOCOPY NUMBER
                  )
IS

   l_beg_of_fiscal_year DATE := NULL;
   l_expiry_date        DATE := NULL;

   CURSOR cur_beg_of_fiscal_year ( p_owner_payroll_action_id NUMBER ) IS
     SELECT fnd_date.canonical_to_date(org_information11)
     FROM   pay_payroll_actions PACT
          , hr_organization_information HOI
     WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
     AND    HOI.organization_id                = PACT.business_group_id
     AND    PACT.payroll_action_id             = p_owner_payroll_action_id;

BEGIN

   IF p_dimension_name LIKE '%RUN' THEN
   -- must check for special case:  if payroll action id's are the same,
   -- then don't expire.  This facilitates meaningful access of these
   -- balances outside of runs.

      IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
         l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
         p_expiry_information := 0;
         RETURN;
      END IF;

   ELSIF p_dimension_name LIKE '%PAYMENTS' THEN
   -- must check for special case:  if payroll action id's are the same,
   -- then don't expire.  This facilitates meaningful access of these
   -- balances outside of runs.

      IF p_owner_payroll_action_id <> p_user_payroll_action_id THEN
         l_expiry_date := p_user_effective_date; -- always must expire.
      ELSE
         p_expiry_information := 0;
         RETURN;
      END IF;

   ELSIF p_dimension_name LIKE '%PTD' THEN
      l_expiry_date := next_period ( p_owner_payroll_action_id
                                   , p_owner_effective_date
                                   );

   ELSIF p_dimension_name LIKE '%MTD' THEN
      l_expiry_date := next_month ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%FY_QTD' THEN
      OPEN cur_beg_of_fiscal_year ( p_owner_payroll_action_id);
      FETCH cur_beg_of_fiscal_year
      INTO l_beg_of_fiscal_year;
      CLOSE cur_beg_of_fiscal_year;

      l_expiry_date := next_fiscal_quarter ( l_beg_of_fiscal_year
                                           , p_owner_effective_date
                                           );

   ELSIF p_dimension_name LIKE '%QTD' THEN
      l_expiry_date := next_quarter ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%FY_YTD' THEN
      OPEN cur_beg_of_fiscal_year ( p_owner_payroll_action_id);
      FETCH cur_beg_of_fiscal_year
      INTO l_beg_of_fiscal_year;
      CLOSE cur_beg_of_fiscal_year;

      l_expiry_date := next_fiscal_year ( l_beg_of_fiscal_year
                                        , p_owner_effective_date
                                        );

   ELSIF p_dimension_name LIKE '%YTD' THEN
      l_expiry_date := next_calendar_year ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%LTD' THEN
      p_expiry_information := 0;
      RETURN;

   ELSE
      hr_utility.set_message(801,'NO_EXP_CHECK_FOR_DIMENSION');
      hr_utility.raise_error;

   END IF;

   IF p_user_effective_date >= l_expiry_date THEN
      p_expiry_information := 1;
   ELSE
      p_expiry_information := 0;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cur_beg_of_fiscal_year%ISOPEN THEN
         CLOSE cur_beg_of_fiscal_year;
      END IF;

   RAISE;
END date_ec;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DATE_EC                                             --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure assumes the date portion of the      --
--                  dimension name is always at the end to allow        --
--                  accurate identification since this is used for many --
--                  dimensions.                                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_owner_payroll_action_id      NUMBER               --
--	                p_user_payroll_action_id       NUMBER               --
--                  p_owner_assignment_action_id   NUMBER               --
--                  p_user_assignment_action_id    NUMBER               --
--	                p_owner_effective_date         DATE                 --
--                  p_user_effective_date          DATE                 --
--                  p_dimension_name               VARCHAR2             --
--            OUT : p_expiry_information           DATE                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-MAY-03  bramajey  Created this procedure                    --
--------------------------------------------------------------------------

PROCEDURE date_ec ( p_owner_payroll_action_id    IN  NUMBER
                  , p_user_payroll_action_id     IN  NUMBER
                  , p_owner_assignment_action_id IN  NUMBER
                  , p_user_assignment_action_id  IN  NUMBER
                  , p_owner_effective_date       IN  DATE
                  , p_user_effective_date        IN  DATE
                  , p_dimension_name             IN  VARCHAR2
                  , p_expiry_information         OUT NOCOPY DATE
                  )
IS

   l_beg_of_fiscal_year DATE := NULL;
   l_expiry_date        DATE := NULL;

   CURSOR cur_beg_of_fiscal_year ( p_owner_payroll_action_id NUMBER ) IS
     SELECT fnd_date.canonical_to_date(org_information11)
     FROM   pay_payroll_actions PACT
          , hr_organization_information HOI
     WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
     AND    HOI.organization_id                = PACT.business_group_id
     AND    PACT.payroll_action_id             = p_owner_payroll_action_id;

BEGIN

   IF p_dimension_name LIKE '%RUN' THEN
   -- must check for special case:  if payroll action id's are the same,
   -- then don't expire.  This facilitates meaningful access of these
   -- balances outside of runs.

      p_expiry_information := p_owner_effective_date;

   ELSIF p_dimension_name LIKE '%PAYMENTS' THEN

      p_expiry_information := p_owner_effective_date;

   ELSIF p_dimension_name LIKE '%PTD' THEN
      p_expiry_information := next_period ( p_owner_payroll_action_id
                                   , p_owner_effective_date
                                   ) - 1 ;

   ELSIF p_dimension_name LIKE '%MTD' THEN
      p_expiry_information := next_month ( p_owner_effective_date) - 1 ;

   ELSIF p_dimension_name LIKE '%FY_QTD' THEN
      OPEN cur_beg_of_fiscal_year ( p_owner_payroll_action_id);
      FETCH cur_beg_of_fiscal_year
      INTO l_beg_of_fiscal_year;
      CLOSE cur_beg_of_fiscal_year;

      p_expiry_information := next_fiscal_quarter ( l_beg_of_fiscal_year
                                           , p_owner_effective_date
                                           ) - 1 ;

   ELSIF p_dimension_name LIKE '%QTD' THEN
      p_expiry_information := next_quarter ( p_owner_effective_date) - 1 ;

   ELSIF p_dimension_name LIKE '%FY_YTD' THEN
      OPEN cur_beg_of_fiscal_year ( p_owner_payroll_action_id);
      FETCH cur_beg_of_fiscal_year
      INTO l_beg_of_fiscal_year;
      CLOSE cur_beg_of_fiscal_year;

      p_expiry_information := next_fiscal_year ( l_beg_of_fiscal_year
                                        , p_owner_effective_date
                                        ) - 1 ;

   ELSIF p_dimension_name LIKE '%YTD' THEN
      p_expiry_information := next_calendar_year ( p_owner_effective_date) - 1 ;

   ELSIF p_dimension_name LIKE '%LTD' THEN
      p_expiry_information := fnd_date.canonical_to_date('4712/12/31');

   ELSE
      hr_utility.set_message(801,'NO_EXP_CHECK_FOR_DIMENSION');
      hr_utility.raise_error;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF cur_beg_of_fiscal_year%ISOPEN THEN
         CLOSE cur_beg_of_fiscal_year;
      END IF;

   RAISE;
END date_ec;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_P12MTH                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_P12MTH   --
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
-- 1.0  23-Jul-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_p12mth ( p_effective_date     IN         DATE
                            , p_start_date         OUT NOCOPY DATE
			    , p_payroll_id         IN         NUMBER
			    , p_bus_grp            IN         NUMBER
			    , p_asg_action         IN         NUMBER
			    )
IS
BEGIN
    p_start_date := last_day(add_months(p_effective_date, -13))+1;
END start_code_p12mth;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_PMTH                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_PMTH     --
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
-- 1.0  23-Jul-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_pmth ( p_effective_date     IN         DATE
                          , p_start_date         OUT NOCOPY DATE
			  , p_payroll_id         IN         NUMBER
			  , p_bus_grp            IN         NUMBER
			  , p_asg_action         IN         NUMBER
			  )
IS
BEGIN
    p_start_date := last_day(add_months(p_effective_date, -2))+1;
END start_code_pmth;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_PYEAR                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_PYEAR    --
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
-- 1.0  23-Jul-2004  snekkala    Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_pyear ( p_effective_date     IN         DATE
                           , p_start_date         OUT NOCOPY DATE
			   , p_payroll_id         IN         NUMBER
			   , p_bus_grp            IN         NUMBER
			   , p_asg_action         IN         NUMBER
			   )
IS
BEGIN
    p_start_date := trunc(add_months(p_effective_date, -12), 'Y');
END start_code_pyear;

END pay_cn_exc;

/
