--------------------------------------------------------
--  DDL for Package Body PAY_IN_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_EXC" AS
/* $Header: pyinexc.pkb 120.4 2008/06/03 14:14:10 lnagaraj noship $ */
 g_package    CONSTANT VARCHAR2(100) := 'pay_in_exc.';
 g_debug      BOOLEAN;

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
--         RETURN : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-04  lnagaraj  Created this function                     --
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
--         RETURN : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-2004  lnagaraj  Created this function                     --
--------------------------------------------------------------------------
FUNCTION next_month ( p_date  IN  DATE
                    )
RETURN DATE
IS
l_procedure VARCHAR2(100);
BEGIN

  RETURN TRUNC(add_months(p_date,1),'MM');

END next_month;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_QUARTER                                        --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date returns the first day of the next      --
--                  quarter.                                            --
-- Parameters     :                                                     --
--             IN :  p_date                DATE                         --
--         RETURN : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0  16-JUL-2004  lnagaraj  Created this function                   --
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
-- Name           : NEXT_TAX_YEAR                                       --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the next tax year.                                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-2004 lnagaraj  Created this function                    --
--------------------------------------------------------------------------
FUNCTION next_tax_year ( p_date        IN  DATE
                            )
RETURN DATE
IS
  l_year  number(4);
  l_start DATE;
  l_start_dd_mm VARCHAR2(6);
BEGIN
  l_year := TO_NUMBER(TO_CHAR(p_date,'yyyy'));
  l_start_dd_mm := '01-04-';

  IF p_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy') THEN
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year+1),'dd-mm-yyyy');
  ELSE
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy');
  END IF;
  RETURN l_start;
END next_tax_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_CAL_YEAR                                       --
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
-- 1.0   16-JUL-2004  lnagaraj  Created this function                    --
--------------------------------------------------------------------------
FUNCTION next_cal_year ( p_date        IN  DATE
                            )
RETURN DATE
IS
  BEGIN
   RETURN TRUNC(ADD_MONTHS(p_date,12),'Y');
END next_cal_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_MAR_FEB_YEAR                                  --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the next Mar-Feb year.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-2004  lnagaraj  Created this function                   --
--------------------------------------------------------------------------
FUNCTION next_mar_feb_year ( p_date        IN  DATE
                            )
RETURN DATE
IS
  l_year  number(4);
  l_start DATE;
  l_start_dd_mm VARCHAR2(6);
BEGIN
  l_year := TO_NUMBER(TO_CHAR(p_date,'yyyy'));
  l_start_dd_mm := '01-03-';

  IF p_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy') THEN
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year+1),'dd-mm-yyyy');
  ELSE
    l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year ),'dd-mm-yyyy');
  END IF;
  RETURN l_start;
END next_mar_feb_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_HALF_YEAR                                      --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the NEXT Half Tax year.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-2004  lnagaraj  Created this function                   --
--------------------------------------------------------------------------
FUNCTION next_half_year ( p_date        IN  DATE
                            )
RETURN DATE
IS
  l_year  number(4);
  l_month number(2);
  l_start DATE;
  l_half_start1  constant VARCHAR2(6) := '01-04-';
  l_half_start2  constant VARCHAR2(6) := '01-10-';
BEGIN
  l_year := TO_NUMBER(TO_CHAR(p_date,'yyyy'));
  l_month:= TO_NUMBER(TO_CHAR(p_date,'mm'));

  IF l_month BETWEEN 4 AND 9 THEN
     l_start := TO_DATE(l_half_start2||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSIF l_month BETWEEN 10 and 12 THEN
     l_start := TO_DATE(l_half_start1||TO_CHAR(l_year+1),'dd-mm-yyyy');
  ELSE
     l_start := TO_DATE(l_half_start1||TO_CHAR(l_year),'dd-mm-yyyy');
  END IF;


  RETURN l_start;
END next_half_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_CAL_HALF_YEAR                                      --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Given a date, returns the date of the first day of  --
--                  the NEXT Half Tax year.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date                DATE                          --
--            OUT : date                                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   02-JUN-2008  rsaharay  Created this function                   --
--------------------------------------------------------------------------
FUNCTION next_cal_half_year ( p_date        IN  DATE
                            )
RETURN DATE
IS
  l_year  number(4);
  l_month number(2);
  l_start DATE;
  l_half_start1  constant VARCHAR2(6) := '01-01-';
  l_half_start2  constant VARCHAR2(6) := '01-07-';
BEGIN
  l_year := TO_NUMBER(TO_CHAR(p_date,'yyyy'));
  l_month:= TO_NUMBER(TO_CHAR(p_date,'mm'));

  IF l_month BETWEEN 1 AND 6 THEN
     l_start := TO_DATE(l_half_start2||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSE
     l_start := TO_DATE(l_half_start1||TO_CHAR(l_year+1),'dd-mm-yyyy');
  END IF;


  RETURN l_start;
END next_cal_half_year;

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
-- 1.0   16-JUL-04  lnagaraj  Created this procedure                    --
-- 1.1   07-OCT-04  lnagaraj  Added Code for LTD dimensions             --
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

   l_message   VARCHAR2(255);
   l_expiry_date        DATE := NULL;
   l_procedure VARCHAR2(100);


BEGIN

   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'date_ec1';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Owner Payroll Action id     ',p_owner_payroll_action_id);
       pay_in_utils.trace('User Payroll Action id      ',p_user_payroll_action_id);
       pay_in_utils.trace('Owner Assignment Action id  ',p_owner_assignment_action_id);
       pay_in_utils.trace('User Assignment Action id   ',p_user_assignment_action_id);
       pay_in_utils.trace('Owner Effective Date        ',p_owner_effective_date);
       pay_in_utils.trace('User Effective Date         ',p_user_effective_date);
       pay_in_utils.trace('Dimension Name              ',p_dimension_name);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

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

   ELSIF p_dimension_name LIKE '%QTD' THEN
      l_expiry_date := next_quarter ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%CYTD' THEN

      l_expiry_date := next_cal_year ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%MAR_FEB_YTD' THEN

      l_expiry_date := next_mar_feb_year ( p_owner_effective_date);
   ELSIF p_dimension_name LIKE '%CHYTD' THEN

      l_expiry_date := next_cal_half_year ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%HYTD' THEN

      l_expiry_date := next_half_year ( p_owner_effective_date);

   ELSIF p_dimension_name LIKE '%YTD' THEN
      l_expiry_date := next_tax_year ( p_owner_effective_date);
  /* Changes for 3839878 Start */
   ELSIF p_dimension_name LIKE '%LTD' THEN
      p_expiry_information := 0;
      RETURN;
  /* Changes for 3839878 End */

   ELSE
      hr_utility.set_message(801,'NO_EXP_CHECK_FOR_DIMENSION');
      hr_utility.raise_error;

   END IF;

   IF p_user_effective_date >= l_expiry_date THEN
      p_expiry_information := 1;
   ELSE
      p_expiry_information := 0;
   END IF;

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Expiry Date                 ',l_expiry_date);
       pay_in_utils.trace('Expiry Information          ',p_expiry_information);
       pay_in_utils.trace('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

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
--	            p_user_payroll_action_id       NUMBER               --
--                  p_owner_assignment_action_id   NUMBER               --
--                  p_user_assignment_action_id    NUMBER               --
--	            p_owner_effective_date         DATE                 --
--                  p_user_effective_date          DATE                 --
--                  p_dimension_name               VARCHAR2             --
--            OUT : p_expiry_information           DATE                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   16-JUL-04  lnagaraj  Created this procedure                    --
-- 1.1   07-OCT-04  lnagaraj  Added Code for LTD dimension              --
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


   l_expiry_date        DATE := NULL;
   l_procedure VARCHAR2(100);
   l_message   VARCHAR2(255);


BEGIN

   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'date_ec2';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Owner Payroll Action id     ',p_owner_payroll_action_id);
       pay_in_utils.trace('User Payroll Action id      ',p_user_payroll_action_id);
       pay_in_utils.trace('Owner Assignment Action id  ',p_owner_assignment_action_id);
       pay_in_utils.trace('User Assignment Action id   ',p_user_assignment_action_id);
       pay_in_utils.trace('Owner Effective Date        ',p_owner_effective_date);
       pay_in_utils.trace('User Effective Date         ',p_user_effective_date);
       pay_in_utils.trace('Dimension Name              ',p_dimension_name);
       pay_in_utils.trace('**************************************************','********************');
   END IF;


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

   ELSIF p_dimension_name LIKE '%QTD' THEN
      p_expiry_information := next_quarter ( p_owner_effective_date) - 1 ;

   ELSIF p_dimension_name LIKE '%CYTD' THEN

      p_expiry_information := next_cal_year ( p_owner_effective_date)-1;

   ELSIF p_dimension_name LIKE '%CHYTD' THEN

      p_expiry_information := next_cal_half_year ( p_owner_effective_date)-1;


   ELSIF p_dimension_name LIKE '%MAR_FEB_YTD' THEN

      p_expiry_information := next_mar_feb_year ( p_owner_effective_date)-1;
   ELSIF p_dimension_name LIKE '%HYTD' THEN

      p_expiry_information := next_half_year ( p_owner_effective_date)-1;

   ELSIF p_dimension_name LIKE '%YTD' THEN
      p_expiry_information := next_tax_year ( p_owner_effective_date) - 1 ;
   /* Changes for 3839878 Start */
   ELSIF p_dimension_name LIKE '%LTD' THEN
      p_expiry_information := fnd_date.canonical_to_date('4712/12/31');
  /* Changes for 3839878 End */
   ELSE
      hr_utility.set_message(801,'NO_EXP_CHECK_FOR_DIMENSION');
      hr_utility.raise_error;

   END IF;

    IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('Expiry Information          ',p_expiry_information);
       pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END date_ec;

PROCEDURE cal_hy_start(p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_action_type     IN  VARCHAR2 DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL)
AS

l_year NUMBER(4);
l_month NUMBER(2);
l_half_start1 CONSTANT VARCHAR2(6):='01-01-';
l_half_start2 CONSTANT VARCHAR2(6):= '01-07-';
l_procedure VARCHAR2(100);
l_message   VARCHAR2(255);

BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'cal_hy_start';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  p_start_date :=NULL;
  l_year := TO_NUMBER (TO_CHAR(p_effective_date,'yyyy'));
  l_month := TO_NUMBER (TO_CHAR(p_effective_date,'mm'));

  IF l_month BETWEEN 1 and 6 THEN
    p_start_date:=TO_DATE(l_half_start1||TO_CHAR(l_year),'DD-MM-YYYY');
  ELSE
    p_start_date:=TO_DATE(l_half_start2||TO_CHAR(l_year),'DD-MM-YYYY');
  END IF;

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace('Effective Date  ',p_effective_date);
    pay_in_utils.trace('Start Date  ',p_start_date);
    pay_in_utils.trace('**************************************************','********************');
  END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END;




PROCEDURE prov_ytd_start(p_effective_date  IN  DATE     ,
                         p_start_date      OUT NOCOPY DATE,
                         p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                         p_payroll_id      IN  NUMBER   DEFAULT NULL,
                         p_bus_grp         IN  NUMBER   DEFAULT NULL,
                         p_action_type     IN  VARCHAR2 DEFAULT NULL,
                         p_asg_action      IN  NUMBER   DEFAULT NULL)
AS

l_year NUMBER(4);
l_message   VARCHAR2(255);
l_procedure VARCHAR2(100);

BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'prov_ytd_start';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  p_start_date :=NULL;
  l_year := TO_NUMBER (TO_CHAR(p_effective_date,'yyyy'));

  IF p_effective_date>=TO_DATE('01-03-'||TO_CHAR(l_year),'DD-MM-YYYY') THEN
     p_start_date := TO_DATE('01-03-'||TO_CHAR(l_year),'DD-MM-YYYY');
  ELSE
     p_start_date := TO_DATE('01-03-'||TO_CHAR(l_year-1),'DD-MM-YYYY');
  END IF;

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('Effective Date  ',p_effective_date);
     pay_in_utils.trace('Start Date  ',p_start_date);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END;

PROCEDURE hytd_start(p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_action_type     IN  VARCHAR2 DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL)
AS

l_year NUMBER(4);
l_month NUMBER(2);
l_half_start1 CONSTANT VARCHAR2(6):='01-04-';
l_half_start2 CONSTANT VARCHAR2(6):= '01-10-';
l_procedure VARCHAR2(100);
l_message   VARCHAR2(255);

BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'hytd_start';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  p_start_date :=NULL;
  l_year := TO_NUMBER (TO_CHAR(p_effective_date,'yyyy'));
  l_month := TO_NUMBER (TO_CHAR(p_effective_date,'mm'));

  IF l_month BETWEEN 4 and 9 THEN
    p_start_date:=TO_DATE(l_half_start1||TO_CHAR(l_year),'DD-MM-YYYY');
  ELSIF l_month BETWEEN 10 and 12 THEN
    p_start_date:=TO_DATE(l_half_start2||TO_CHAR(l_year),'DD-MM-YYYY');
  ELSE
    p_start_date:=TO_DATE(l_half_start2||TO_CHAR(l_year-1),'DD-MM-YYYY');
  END IF;

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace('Effective Date  ',p_effective_date);
    pay_in_utils.trace('Start Date  ',p_start_date);
    pay_in_utils.trace('**************************************************','********************');
  END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END;



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
-- 1.0  15-Sep-2004  abhjain     Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_pmth ( p_effective_date     IN         DATE
                          , p_start_date         OUT NOCOPY DATE
			  , p_payroll_id         IN         NUMBER
			  , p_bus_grp            IN         NUMBER
			  , p_asg_action         IN         NUMBER
			  )
IS
  l_procedure VARCHAR2(100);
  l_message   VARCHAR2(255);
BEGIN
  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'start_code_pmth';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  p_start_date := last_day(add_months(p_effective_date, -2))+1;

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace('Effective Date  ',p_effective_date);
    pay_in_utils.trace('Start Date  ',p_start_date);
    pay_in_utils.trace('**************************************************','********************');
  END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);


END start_code_pmth;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : START_CODE_P10MTH                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure finds the start date based on the    --
--                  effective date for the dimension name _ASG_P10MTH     --
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
-- 1.0  14-Oct-2004  lnagaraj     Created the procedure                  --
--------------------------------------------------------------------------
PROCEDURE start_code_p10mth ( p_effective_date     IN         DATE
                            , p_start_date         OUT NOCOPY DATE
			    , p_payroll_id         IN         NUMBER
			    , p_bus_grp            IN         NUMBER
			    , p_asg_action         IN         NUMBER
			  )
IS
  l_procedure VARCHAR2(100);
  l_message   VARCHAR2(255);
BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure := g_package ||'start_code_p10mth';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    p_start_date := last_day(add_months(p_effective_date, -11))+1;

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace('Effective Date  ',p_effective_date);
    pay_in_utils.trace('Start Date  ',p_start_date);
    pay_in_utils.trace('**************************************************','********************');
  END IF;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END start_code_p10mth;


END pay_in_exc;

/
