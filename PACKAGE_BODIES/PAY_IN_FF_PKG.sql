--------------------------------------------------------
--  DDL for Package Body PAY_IN_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_FF_PKG" AS
/* $Header: pyindedn.pkb 120.13.12010000.3 2008/10/10 07:26:15 mdubasi ship $ */

   g_debug BOOLEAN;
   g_package     CONSTANT VARCHAR2(100) := 'pay_in_ff_pkg.';
   p_token_name   pay_in_utils.char_tab_type;
   p_token_value  pay_in_utils.char_tab_type;

--------------------------------------------------------------------------
-- Name           : CHECK_RETAINER                                      --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function checks if the employee is excluded or      --
--                  or not. Returns 1 if excluded elso 0                --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id       IN NUMBER                     --
--                  p_payroll_action_id   IN VARCHAR2                   --
--                  p_effective_date      IN DATE                       --
--                                                                      --
-- Version    Date     Author   Bug      Description                    --
-- =====================================================================--
-- 1.0   15-Jun-04   ABHJAIN  3683543  Initial Version                  --
-- 1.1   02-Aug-04   VGSRINIV 3807912 Changed the lookup code for       --
--                                    Employee Category and increased   --
--                                    the size of l_emp_cat to 10       --
--------------------------------------------------------------------------
FUNCTION check_retainer (p_assignment_id     IN NUMBER
                        ,p_payroll_action_id IN NUMBER)
         RETURN NUMBER IS
  CURSOR c_emp_cat IS
  SELECT nvl(paa.employee_category,'X')
    FROM per_all_assignments_f paa,
         pay_payroll_actions ppa
   WHERE paa.assignment_id = p_assignment_id
     AND ppa.payroll_action_id = p_payroll_action_id
     AND paa.payroll_id = ppa.payroll_id
     AND ppa.effective_date BETWEEN paa.effective_start_date
                                AND paa.effective_end_date;

  l_emp_cat       VARCHAR2(10);
  l_procedure     VARCHAR2(100);
  l_message       VARCHAR2(1000);
BEGIN
  g_debug:= hr_utility.debug_enabled;
  l_procedure:= g_package ||'check_retainer';

  pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id',p_assignment_id);
     pay_in_utils.trace('p_payroll_action_id',p_payroll_action_id);
     pay_in_utils.trace('**************************************************','********************');
 END IF;
  OPEN c_emp_cat;
    FETCH c_emp_cat INTO l_emp_cat;
  CLOSE c_emp_cat;

  IF g_debug THEN
    pay_in_utils.trace('l_emp_cat',l_emp_cat);
  END IF;

  IF (l_emp_cat = 'IN_RE') THEN
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
    RETURN 1;
  ELSE
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,40);
    RETURN 0;
  END IF;

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       hr_utility.trace(l_message);
       RETURN NULL;
END check_retainer;

--------------------------------------------------------------------------
-- Name           : CHECK_EDLI                                          --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function finds if the EDLI option is Yes or No      --
--                  for the employer             .                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id       IN NUMBER                     --
--                  p_effective_date      IN DATE                       --
--                                                                      --
--                                                                      --
-- Version    Date     Author   Bug      Description                    --
-- =====================================================================--
-- 115.0   15-Jun-04   ABHJAIN  3683543  Initial Version                --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION check_edli(p_assignment_id  IN NUMBER
                   ,p_effective_date IN DATE)
         RETURN VARCHAR2 IS
  CURSOR c_get_edli IS
  SELECT hoi.org_information7
    FROM hr_organization_information hoi,
         hr_soft_coding_keyflex hsk,
         per_all_assignments_f paa
   WHERE hoi.org_information_context = 'PER_IN_PF_DF'
     AND hoi.organization_id = hsk.segment2
     AND hsk.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
     AND paa.assignment_id = p_assignment_id
     AND p_effective_date BETWEEN paa.effective_start_date
                              AND paa.effective_end_date;
  l_procedure     VARCHAR2(100);
  l_edli VARCHAR2(1);
  l_message       VARCHAR2(1000);
BEGIN
  g_debug:= hr_utility.debug_enabled;
  l_procedure:= g_package ||'check_retainer';

  pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

 IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id',p_assignment_id);
     pay_in_utils.trace('p_effective_date',to_char(p_effective_date,'dd/mm/yyyy'));
     pay_in_utils.trace('**************************************************','********************');
 END IF;
  OPEN  c_get_edli;
    FETCH c_get_edli INTO l_edli;
  CLOSE c_get_edli;

   IF g_debug THEN
     pay_in_utils.trace('l_edli',l_edli);
   END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);
  RETURN l_edli;

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       hr_utility.trace(l_message);
       RETURN NULL;
END check_edli;

--------------------------------------------------------------------------
-- Name           : GET_ESI_CONT_AMT                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function finds the ESI Eligibile salary at the      --
--                  start of Contribution period/first pay period       --
--                  whichever falls later                               --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id IN NUMBER                    --
--                  p_assignment_id        IN NUMBER                    --
--                  p_date_earned          IN DATE                      --
--                  p_eligible_amt         IN NUMBER                    --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    04-Aug-2004 lnagaraj 3723655  Initial Version               --
-- 115.1    12-Aug-2004 lnagaraj          Changed cusor get_date        --
--                                     used _ASG_MTD instead of _ASG_RUN--
-- 115.2    25-Aug-2004 lnagaraj 3844554  Used _ASG_PTD instead of      --
--                                        _ASG_MTD                      --
-- 115.3    23-Sep-2004 statkar  3861752  Support for +ve offsets       --
-- 115.4    21-Oct-2005 lnagaraj 4680066  Added 'csr_bal_init' to       --
--                                        consider balance init         --
-- 115.5    07-Jun-2006 lnagaraj 6116283  Included last_day function    --
--------------------------------------------------------------------------
FUNCTION get_esi_cont_amt(p_assignment_action_id IN NUMBER
                         ,p_assignment_id        IN NUMBER
                         ,p_date_earned          IN DATE
                         ,p_eligible_amt         IN NUMBER
                          )
RETURN NUMBER IS

 /* This cursor returns the defined balance id of 'ESI_ELIGIBLE_SALARY_ASG_PTD' */
 CURSOR get_defined_bal_id IS
 SELECT pdb.defined_balance_id
  FROM  pay_defined_balances pdb,
        pay_balance_dimensions pbd,
        pay_balance_types pbt
 WHERE pbt.balance_name ='ESI Eligible Salary'
   AND pbd.database_item_suffix='_ASG_PTD' /* Bugfix 3844554 */
   AND pbt.legislation_code='IN'
   AND pdb.balance_type_id =pbt.balance_type_id
   AND pdb.balance_dimension_id =pbd.balance_dimension_id;

/* This cursor returns the latest of first pay period date  and contribution period start date */
 CURSOR get_date(l_start date) IS
        SELECT GREATEST( MIN(ppa.date_earned),l_start)
        FROM    pay_payroll_actions ppa,
                pay_assignment_actions paa,
                per_all_assignments_f paf
        WHERE paf.assignment_id =p_assignment_id
        AND   paf.assignment_id=paa.assignment_id
        AND   paa.payroll_action_id =ppa.payroll_action_id;

-- Cursor for Max Assignment Action ID for the contribution period
  CURSOR csr_casact (l_virtual_date IN DATE) IS
    SELECT paa.assignment_action_id
    FROM   pay_payroll_actions ppa
          ,pay_assignment_actions paa
    WHERE  paa.payroll_action_id = ppa.payroll_action_id
    AND    paa.assignment_id     = p_assignment_id
    AND    last_day(ppa.date_earned)  = l_virtual_date
    AND    paa.source_action_id IS NULL
    AND    ppa.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')-- Added as a part of bug fix 4774108
    AND    ppa.action_type in ('Q','R','I','B')
    ORDER BY paa.action_sequence DESC ;


-- Store the contribution Start Periods
  l_half_year_start1 VARCHAR2(7);
  l_half_year_start2 VARCHAR2(7);

  l_month NUMBER;
  l_year NUMBER;
  l_start DATE;
  l_esi_cont_date DATE;
  l_esi_contr_month DATE;
  l_esi_eligible_amt   NUMBER;
  l_defined_balance_id NUMBER;
  l_date_earned DATE;
  l_start_period DATE;

  l_procedure VARCHAR2(100);
  l_virtual_asact_id NUMBER;
  l_message VARCHAR2(1000);

BEGIN
  g_debug:= hr_utility.debug_enabled;
  l_procedure := g_package ||'get_esi_cont_amt';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure, 10);

  l_half_year_start1:='01-04-';
  l_half_year_start2:='01-10-';

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace ('p_assignment_action_id ',to_char(p_assignment_action_id));
    pay_in_utils.trace ('p_assignment_id        ',to_char(p_assignment_id));
    pay_in_utils.trace ('p_date_earned          ',to_char(p_date_earned,'DD-MM-YYYY'));
    pay_in_utils.trace ('p_eligible_amt         ',to_char(p_eligible_amt));
    pay_in_utils.trace('**************************************************','********************');
  END IF;

  l_month :=TO_NUMBER(TO_CHAR(p_date_earned,'mm'));
  l_year := TO_NUMBER(TO_CHAR(p_date_earned,'yyyy'));

  pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF l_month BETWEEN 4 AND 9 THEN
       l_start := TO_DATE(l_half_year_start1||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSIF l_month BETWEEN 10 and 12 THEN
       l_start := TO_DATE(l_half_year_start2||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSE
       l_start := TO_DATE(l_half_year_start2||TO_CHAR(l_year-1),'dd-mm-yyyy');
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure, 30);

  OPEN get_date(l_start);
  FETCH get_date INTO l_esi_cont_date;
  CLOSE get_date;

  pay_in_utils.set_location(g_debug,l_procedure, 40);

  --Get the last date of the month to be considered for ESI Eligibility
  l_esi_contr_month := last_day(l_esi_cont_date);

  --Get the last date of the current pay period
  l_start_period    := last_day(p_date_earned);

  IF g_debug THEN
    pay_in_utils.trace ('l_esi_contr_month : ' , to_char(l_esi_contr_month,'DD-MM-YYYY'));
    pay_in_utils.trace ('l_start_period : ' , to_char(l_start_period,'DD-MM-YYYY'));
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure, 50);

--
-- IF  Current month is to considered for finding ESI Eligibility
--     THEN return back the input value(p_eligible_amt)
--   ELSE
--      Call pay_balance_pkg.get_value
--

  IF l_start_period =l_esi_contr_month THEN

    l_esi_eligible_amt :=p_eligible_amt;
    pay_in_utils.set_location(g_debug,l_procedure, 60);

  ELSE
    pay_in_utils.set_location(g_debug,l_procedure, 70);
    OPEN get_defined_bal_id;
    FETCH get_defined_bal_id INTO l_defined_balance_id;
    CLOSE get_defined_bal_id;


    OPEN csr_casact (l_esi_contr_month);
    FETCH csr_casact
    INTO  l_virtual_asact_id;
    CLOSE csr_casact;


    pay_in_utils.set_location(g_debug,'Virtual ASACT ID : '||to_char(l_virtual_asact_id),80);

    l_esi_eligible_amt := pay_balance_pkg.get_value(
                               p_defined_balance_id   => l_defined_balance_id,
                               p_assignment_action_id => l_virtual_asact_id
                             );

    pay_in_utils.set_location(g_debug,l_procedure, 80);

   END IF;

  IF g_debug THEN
    pay_in_utils.trace ('l_esi_eligible_amt : ' , l_esi_eligible_amt);
  END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 90);
   RETURN l_esi_eligible_amt;

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 100);
       hr_utility.trace(l_message);
       RETURN NULL;
END get_esi_cont_amt;


--------------------------------------------------------------------------
-- Name           : GET_ESI_DISABILITY_DETAILS                          --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function finds the Disability Details at the        --
--                  start of Contribution period/first pay period       --
--                  whichever falls later                               --
-- Parameters     :                                                     --
--             IN : p_assignment_id        IN NUMBER                    --
--                  p_date_earned          IN DATE                      --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    04-Sep-2008  mdubasi 7357358  Initial Version               --
--------------------------------------------------------------------------
FUNCTION get_esi_disability_details( p_assignment_id in number
                                    ,p_date_earned in date
                                    ,p_disable_proof out  NOCOPY varchar2)
Return Number is

 /* This cursor returns the Disable Proof */
  Cursor c_disab_details(l_esi_cont_date date) is
   select pdf.dis_information1
     from per_disabilities_f pdf,
          per_all_assignments_f paa
    where paa.assignment_id = p_assignment_id
      and paa.person_id = pdf.person_id
      and l_esi_cont_date between paa.effective_start_date and paa.effective_end_date
      and l_esi_cont_date between pdf.effective_start_date and pdf.effective_end_date
      order by nvl(pdf.dis_information1,'N') desc;

    /* This cursor returns the latest of first pay period date  and contribution period start date */
 CURSOR get_date(l_start date) IS
        SELECT GREATEST( MIN(ppa.date_earned),l_start)
        FROM    pay_payroll_actions ppa,
                pay_assignment_actions paa,
                per_all_assignments_f paf
        WHERE paf.assignment_id =p_assignment_id
        AND   paf.assignment_id=paa.assignment_id
        AND   paa.payroll_action_id =ppa.payroll_action_id;

-- Store the contribution Start Periods
  l_half_year_start1 VARCHAR2(7);
  l_half_year_start2 VARCHAR2(7);

  l_month NUMBER;
  l_year NUMBER;
  l_start DATE;
  l_esi_cont_date DATE;
  l_proof Varchar2(10);
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_esi_disability_details';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_half_year_start1:='01-04-';
  l_half_year_start2:='01-10-';

  IF g_debug THEN
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.trace ('p_assignment_id        ',to_char(p_assignment_id));
    pay_in_utils.trace ('p_date_earned          ',to_char(p_date_earned,'DD-MM-YYYY'));
    pay_in_utils.trace('**************************************************','********************');
  END IF;

  l_month := TO_NUMBER(TO_CHAR(p_date_earned,'mm'));
  l_year := TO_NUMBER(TO_CHAR(p_date_earned,'yyyy'));

  pay_in_utils.set_location(g_debug,l_procedure, 20);

  IF l_month BETWEEN 4 AND 9 THEN
       l_start := TO_DATE(l_half_year_start1||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSIF l_month BETWEEN 10 and 12 THEN
       l_start := TO_DATE(l_half_year_start2||TO_CHAR(l_year),'dd-mm-yyyy');
  ELSE
       l_start := TO_DATE(l_half_year_start2||TO_CHAR(l_year-1),'dd-mm-yyyy');
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure, 30);

 /*To get latest of first pay period date  and contribution period start date*/

  OPEN get_date(l_start);
  FETCH get_date INTO l_esi_cont_date;
  CLOSE get_date;

  pay_in_utils.set_location(g_debug,l_procedure, 40);

  IF g_debug THEN
    pay_in_utils.trace ('l_esi_cont_date : ' , to_char(l_esi_cont_date,'DD-MM-YYYY'));
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure, 50);

  l_proof := 'N';

  Open c_disab_details(l_esi_cont_date);
  Fetch c_disab_details into l_proof;
  Close c_disab_details;

  p_disable_proof := l_proof;

  pay_in_utils.set_location(g_debug,l_procedure, 60);


  IF g_debug THEN
   pay_in_utils.trace('p_disable_proof',p_disable_proof);
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure, 70);


  pay_in_utils.trace('**************************************************','********************');
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
  Return 0;

END get_esi_disability_details;


--------------------------------------------------------------------------
-- Name           : ROUND_TO_5PAISE                                     --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to round to next higher multiple of 5 paise--
-- Parameters     :                                                     --
--             IN : p_number               IN NUMBER                    --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    04-Aug-2004 lnagaraj 3723655  Initial Version               --
-- 115.1    25-Aug-2004 lnagaraj 3849905  Rounded the number to 2 places--
--                                        before rounding to the next   --
--                                        five paise                    --

--------------------------------------------------------------------------

FUNCTION round_to_5paise( p_number in number)
RETURN NUMBER IS
  n       NUMBER;
  l_number NUMBER;
  l_procedure            VARCHAR2(100);
BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'round_to_5paise';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
     pay_in_utils.trace('p_number',to_char(p_number));
  END IF;

  l_number := ROUND(p_number,2);
  N        := CEIL (l_number*10)/10;

  IF g_debug THEN
     pay_in_utils.trace('N',to_char(N));
  END IF;

  IF (N-l_number) >= 0.05 THEN
    RETURN (N-0.05);
  ELSE
    RETURN N;
  END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

END ROUND_TO_5PAISE;

--------------------------------------------------------------------------
-- Name           : GET_ACCRUAL_PLAN                                    --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function  to fetch the Accrual Plan id of the       --
--                  accrual category passed                             --
--             IN : p_assignment_id          NUMBER                     --
--                  p_effective_date         DATE                       --
--                  p_plan_category          VARCHAR2                   --
--            OUT : p_message                VARCHAR2                   --
--                  plan_id                  NUMBER                     --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    19-Oct-2004 Vgsriniv  3847355  Initial Version              --

--------------------------------------------------------------------------
FUNCTION get_accrual_plan ( p_assignment_id    IN    NUMBER
                           ,p_effective_date   IN    DATE
                           ,p_plan_category    IN    VARCHAR2
                           ,p_message          OUT   NOCOPY VARCHAR2
                          )
RETURN NUMBER
IS

    l_accrual_plan_id      NUMBER := NULL;
    l_dummy                NUMBER ;
    l_procedure            VARCHAR2(100);
    l_message              VARCHAR2(1000);

  CURSOR csr_get_accrual_plan_id(p_assignment_id    NUMBER
                                ,p_effective_date   DATE
                                ,p_plan_category    VARCHAR2) IS
    SELECT pap.accrual_plan_id
    FROM   pay_accrual_plans pap,
           pay_element_entries_f pee,
           pay_element_links_f pel,
           pay_element_types_f pet
    WHERE  pee.assignment_id = p_assignment_id
    AND    p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
    AND    pel.element_link_id = pee.element_link_id
    AND    pel.element_type_id = pet.element_type_id
    AND    pap.accrual_plan_element_type_id = pet.element_type_id
    AND    pap.accrual_category = p_plan_category ;

  BEGIN
   g_debug          := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_accrual_plan';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id ',to_char(p_assignment_id ));
     pay_in_utils.trace('p_effective_date',to_char(p_effective_date));
     pay_in_utils.trace('p_plan_category ',to_char(p_plan_category ));
     pay_in_utils.trace('**************************************************','********************');
  END IF;

    OPEN csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category) ;
    FETCH csr_get_accrual_plan_id INTO l_accrual_plan_id;

    IF csr_get_accrual_plan_id%NOTFOUND
    THEN
      p_message := 'ERROR';
      CLOSE csr_get_accrual_plan_id;
    ELSE
      p_message := 'SUCCESS';
      CLOSE csr_get_accrual_plan_id;
    END IF ;

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_message ',p_message);
     pay_in_utils.trace('l_accrual_plan_id ',to_char(l_accrual_plan_id ));
     pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

   RETURN l_accrual_plan_id;

    EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
       hr_utility.trace(l_message);
       RETURN NULL;

END get_accrual_plan;

--------------------------------------------------------------------------
-- Name           : GET_NET_ACCRUAL                                     --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the accrued leave balance as of   --
--                  the date passed                                     --
--             IN : p_assignment_id          NUMBER                     --
--                  p_payroll_id             NUMBER                     --
--                  p_business_group_id      NUMBER                     --
--                  p_calculation_date       DATE                       --
--                  p_plan_category          VARCHAR2                   --
--            OUT : p_message                VARCHAR2                   --
--                  accrual                  NUMBER                     --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    19-Oct-2004 Vgsriniv  3847355  Initial Version              --

--------------------------------------------------------------------------

FUNCTION get_net_accrual ( p_assignment_id     IN  NUMBER
                          ,p_payroll_id        IN  NUMBER
                          ,p_business_group_id IN  NUMBER
                          ,p_calculation_date  IN  DATE
                          ,p_plan_category     IN  VARCHAR2
                          ,p_message           OUT NOCOPY VARCHAR2
                         )
RETURN NUMBER
IS
    l_plan_id          NUMBER;
    l_accrued_leave    NUMBER   := NULL;
    l_start_date       DATE     := NULL;
    l_end_date         DATE     := NULL;
    l_accrual_end_date DATE     := NULL;
    l_accrual          NUMBER   := NULL;
    l_procedure    VARCHAR2(100);
    l_message      VARCHAR2(1000);

BEGIN

   g_debug:= hr_utility.debug_enabled;
   l_procedure := g_package ||'get_net_accrual';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id    ',to_char(p_assignment_id    ));
     pay_in_utils.trace('p_payroll_id       ',to_char(p_payroll_id       ));
     pay_in_utils.trace('p_business_group_id',to_char(p_business_group_id));
     pay_in_utils.trace('p_calculation_date ',to_char(p_calculation_date,'yyyy-mm-dd'));
     pay_in_utils.trace('p_plan_category    ',p_plan_category);
     pay_in_utils.trace('**************************************************','********************');

  END IF;

    l_plan_id := get_accrual_plan ( p_assignment_id    => p_assignment_id
                                   ,p_effective_date   => p_calculation_date
                                   ,p_plan_category    => p_plan_category
                                   ,p_message          => p_message
                                   );

    per_accrual_calc_functions.get_net_accrual(
                          p_assignment_id      =>   p_assignment_id
                         ,p_plan_id            =>   l_plan_id
                         ,p_payroll_id         =>   p_payroll_id
                         ,p_business_group_id  =>   p_business_group_id
                         ,p_calculation_date   =>   p_calculation_date
                         ,p_start_date         =>   l_start_date
                         ,p_end_date           =>   l_end_date
                         ,p_accrual_end_date   =>   l_accrual_end_date
                         ,p_accrual            =>   l_accrual
                         ,p_net_entitlement    =>   l_accrued_leave) ;

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_accrued_leave ',to_char(l_accrued_leave));
     pay_in_utils.trace('p_message    ',p_message);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
    RETURN l_accrued_leave;
    EXCEPTION
      WHEN OTHERS THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
        hr_utility.trace(l_message);
        RETURN NULL;


END get_net_accrual;
--------------------------------------------------------------------------
-- Name           : GET_PERIOD_NUMBER                                   --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the period number of the date     --
--                  passed                                              --
--             IN : p_payroll_id             NUMBER                     --
--                  p_date                   DATE                       --
--            OUT : Period Number            NUMBER                     --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- =====================================================================--
-- 115.0    19-Oct-2004 Vgsriniv  3847355  Initial Version              --
-- 115.1    12-May-2005 rpalli    3919203  Modified code to support     --
--                                         offset payrolls              --
--------------------------------------------------------------------------

FUNCTION get_period_number (p_payroll_id IN NUMBER
                           ,p_term_date IN DATE )
RETURN NUMBER IS

CURSOR c_period_number IS
SELECT  decode(to_char(TPERIOD.end_date,'MM'),'04',1,'05',2,'06',3,
                                              '07',4,'08',5,'09',6,
                                              '10',7,'11',8,'12',9,
                                              '01',10,'02',11,'03',12)
    FROM per_time_periods TPERIOD,
         per_time_period_types TPTYPE
   WHERE TPERIOD.payroll_id = p_payroll_id
     AND TPTYPE.period_type = TPERIOD.period_type
     AND p_term_date between TPERIOD.start_date and TPERIOD.end_date;

l_period_num   NUMBER;
l_procedure    VARCHAR2(100);
l_message      VARCHAR2(1000);

BEGIN
    g_debug          := hr_utility.debug_enabled;
    l_procedure := g_package ||'get_period_number';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_payroll_id',to_char(p_payroll_id    ));
     pay_in_utils.trace('p_term_date ',to_char(p_term_date,'yyyy-mm-dd'));
     pay_in_utils.trace('**************************************************','********************');
  END IF;

    l_period_num := 12;

    OPEN c_period_number;
    FETCH c_period_number INTO l_period_num;
    CLOSE c_period_number;

    IF g_debug THEN
     pay_in_utils.trace('l_period_num',to_char(l_period_num    ));
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

    RETURN l_period_num;

    EXCEPTION
      WHEN OTHERS THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
        hr_utility.trace(l_message);
        RETURN NULL;


END get_period_number;

--------------------------------------------------------------------------
-- Name           : SEC_80DD_PERCENT                                   --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to check if Sec 80 DD element is attached  --
--                  with 80-100 percent disability                      --
--             IN : p_assignment_id          NUMBER                     --
--                  p_date                   DATE                       --
--            OUT : Y/N                      VARCHAR2                   --
--                                                                      --
-- Version    Date      Author   Bug      Description                   --
-- ========|============|=======|========|==================================--
-- 115.0    04-Nov-2004 Vgsriniv 3936280  Initial Version              --

--------------------------------------------------------------------------

FUNCTION sec_80dd_percent ( p_assignment_id IN per_all_assignments_f.assignment_id%type
                           ,p_date_earned IN date)
RETURN VARCHAR2 IS

  CURSOR c_80dd_80_percent is
    SELECT count (*)
      FROM pay_element_entry_values_f pev,
           pay_element_entries_f pee,
           pay_element_types_f pet,
           pay_input_values_f piv
     WHERE pet.element_name like 'Deduction under Section 80DD'
       AND pet.legislation_code = 'IN'
       AND pet.element_type_id = piv.element_type_id
       AND piv.name = 'Disability Percentage'
       AND piv.input_value_id = pev.input_value_id
       AND pev.screen_entry_value = '80100'
       AND pev.element_entry_id = pee.element_entry_id
       AND pee.assignment_id = p_assignment_id
       AND pee.element_type_id = pet.element_type_id
       AND pee.entry_type = 'E'
       AND p_date_earned BETWEEN pev.effective_start_date AND pev.effective_end_date
       AND p_date_earned BETWEEN pee.effective_start_date AND pee.effective_end_date
       AND p_date_earned BETWEEN pet.effective_start_date AND pet.effective_end_date
       AND p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;

  l_80_percent number;
  l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'sec_80dd_percent';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id',to_char(p_assignment_id    ));
     pay_in_utils.trace('p_date_earned ',to_char(p_date_earned,'yyyy-mm-dd'));
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  OPEN c_80dd_80_percent;
  FETCH c_80dd_80_percent INTO l_80_percent;
  CLOSE c_80dd_80_percent;


  IF g_debug THEN
     pay_in_utils.trace('l_80_percent',l_80_percent);
  END IF;

  IF l_80_percent > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END sec_80dd_percent;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : check_father_husband_name                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to check contact details as the case maybe--
-- Parameters     :                                                     --
--             IN : p_effective_date          DATE                      --
--                  p_assignment_id           NUMBER                    --
--                  p_calling_procedure       VARCHAR2                  --
--             OUT:                                                     --
--                  p_message_name            VARCHAR2                  --
--                  p_token_value             VARCHAR2                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-Jan-05  aaagarwa  Created this procedure                    --
-- 1.1   25-Jul-05  snekkala  Modified to make father name mandatory of --
--                            gender and spouse mandatory if gender is  --
--                            Female and Marital Status is Married      --
-- 1.2   25-Jul-05  snekkala  Removed GSCC Errors                       --
--------------------------------------------------------------------------
PROCEDURE check_father_husband_name
             (p_assignment_id           IN NUMBER
             ,p_effective_date          IN DATE
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_value             OUT NOCOPY VARCHAR2)
IS
/* Cursor to find the contact details */
  CURSOR csr_contacts
  IS
    SELECT DISTINCT(DECODE(pcr.contact_type,'JP_FT','Father','F','Father','S','Spouse')) relation_type
         , ppf.sex                                                                       sex
	 , ppf.marital_status                                                            marital_status
      FROM per_people_f               ppf
         , per_assignments_f          paf
         , per_contact_relationships  pcr
     WHERE paf.assignment_id  = p_assignment_id
       AND paf.person_id      = ppf.person_id
       AND pcr.person_id      = ppf.person_id
       AND pcr.contact_type   IN ('JP_FT','F',DECODE(ppf.marital_status,'M','S'))
       AND p_effective_date   BETWEEN ppf.effective_start_date AND ppf.effective_end_date
       AND p_effective_date   BETWEEN paf.effective_start_date AND ppf.effective_end_date
       AND p_effective_date   BETWEEN pcr.date_start           AND NVL(pcr.date_end,TO_DATE('4712/12/31','YYYY/MM/DD'))
  ORDER BY DECODE(pcr.contact_type,'JP_FT','Father','F','Father','S','Spouse');

  l_sex            VARCHAR2(10);
  l_name           VARCHAR2(100);
  l_procedure      VARCHAR2(100);
  l_marital_status VARCHAR2(10);
  l_father_exists  NUMBER;
  l_spouse_exists  NUMBER;

BEGIN

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package||'check_father_husband_name' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id  ',to_char(p_assignment_id));
     pay_in_utils.trace('p_effective_date ',to_char(p_effective_date,'yyyy-mm-dd'));
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  p_message_name := 'SUCCESS';
  p_token_value:=NULL;

  l_father_exists :=0;
  l_spouse_exists :=0;

  FOR i in csr_contacts
  LOOP
     IF i.sex ='F' AND i.marital_status = 'M' AND i.relation_type ='Spouse' THEN
        l_spouse_exists := 1;
     ELSIF i.relation_type = 'Father' THEN
        l_father_exists := 1;
     END IF;
     l_sex := i.sex;
     l_marital_status := i.marital_status;
  END LOOP;

  IF l_father_exists = 0 THEN
     p_message_name := 'PER_IN_CONTACT_DETAILS';
     p_token_value := 'Father';
  ELSIF l_sex = 'F' AND l_marital_status = 'M' AND l_spouse_exists = 0 THEN
     p_message_name := 'PER_IN_CONTACT_DETAILS';
     p_token_value := 'Spouse';
  END IF;

   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_message_name   ',p_message_name);
     pay_in_utils.trace('p_token_value    ',p_token_value);
     pay_in_utils.trace('**************************************************','********************');
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  RETURN;

END check_father_husband_name;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_GRE_UPDATE                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate GRE/Legal Entity Changes      --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                  p_dt_mode             VARCHAR2                      --
--                  p_assignment_id       NUMBER                        --
--                  p_gre_org             VARCHAR2                      --
--            OUT : p_message             VARCHAR2                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
PROCEDURE check_gre_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_gre_org          IN  VARCHAR2
	 ,p_pf_org           IN  VARCHAR2
	 ,p_esi_org          IN  VARCHAR2
         ,p_gre              IN NUMBER
	 ,p_pf               IN NUMBER
	 ,p_esi              IN NUMBER
         ,p_message          OUT NOCOPY VARCHAR2
	 ,p_token_name       OUT NOCOPY pay_in_utils.char_tab_type
	 ,p_token_value      OUT NOCOPY pay_in_utils.char_tab_type
         )
IS
-- The cursor to obtain the maximum payroll run date for an assignment in a BG.
   CURSOR c_max_pay_date
   IS
      SELECT ppa.date_earned
      FROM   pay_payroll_actions    ppa
            ,pay_assignment_actions paa
      WHERE  ppa.payroll_action_id  = paa.payroll_action_id
      AND    ppa.action_type IN ('Q','R')
      AND    ppa.action_status = 'C'
      AND    paa.source_action_id IS NULL
      AND    ppa.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND    paa.assignment_id = p_assignment_id
      ORDER BY ppa.date_earned DESC;
-- The cursor to obtain start and end date of the effective date's month.
   CURSOR c_payroll_month_dates
   IS
      SELECT ADD_MONTHS(LAST_DAY(p_effective_date),-1)+1
            ,LAST_DAY(p_effective_date)
      FROM   dual;


-- The cursor to find out the total no of GRE/Legal entity chnages in a given month.
   CURSOR c_gre_changes(p_start_date DATE
                       ,p_end_date   DATE
                       )
   IS
      SELECT COUNT(DISTINCT scl.segment1)
      FROM   per_all_assignments_f asg
            ,hr_soft_coding_keyflex scl
      WHERE  asg.assignment_id = p_assignment_id
      AND    scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
      AND    asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND (  asg.effective_start_date BETWEEN p_start_date AND p_end_date
          OR
             asg.effective_end_date BETWEEN p_start_date AND p_end_date
          );

-- The cursor to find the organization id of the GRE/Legal entity id
   CURSOR c_org_id(p_org_name hr_organization_units.name%type)
   IS
      SELECT organization_id
      FROM  hr_organization_units
      WHERE NAME = p_org_name
      AND   business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');

-- The cursor to find the most recent 'assignment start date' for the effective date
 CURSOR c_asg_start_date
 IS
     SELECT asg.effective_start_date
     FROM per_all_assignments_f asg
     WHERE p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND asg.assignment_id = p_assignment_id;

-- The cursor to find the presence of an employee in the now selected GRE/Legal
-- entity id in earlier part of the current month.
   CURSOR c_flag(p_latest_org_id  NUMBER
                ,p_start_date     DATE
                ,p_end_date       DATE

		)
   IS
      SELECT 1
      FROM   per_all_assignments_f asg
            ,hr_soft_coding_keyflex scl
      WHERE  asg.assignment_id = p_assignment_id
      AND    scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
      AND    asg.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND    scl.segment1          = p_latest_org_id
      AND  ( asg.effective_start_date BETWEEN p_start_date AND p_end_date
          OR
             asg.effective_end_date BETWEEN p_start_date AND  p_end_date
            );

    l_max_date_earned        DATE;
    l_start_date             DATE;
    l_end_date               DATE;
    l_org_id                 NUMBER;
    l_gre_org_id             NUMBER;
    l_pf_org_id              NUMBER;
    l_esi_org_id             NUMBER;
    l_count                  NUMBER;
    l_le_start_date          DATE;
    l_le_end_date            DATE;
    l_flag                   NUMBER;
    l_asg_start_date         DATE;
    l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'check_gre_update';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_effective_date',to_char(p_effective_date,'yyyy-mm-dd'));
     pay_in_utils.trace('p_dt_mode       ',p_dt_mode);
     pay_in_utils.trace('p_assignment_id ',to_char(p_assignment_id));
     pay_in_utils.trace('p_gre_org       ',p_gre_org);
     pay_in_utils.trace('p_pf_org        ',p_pf_org );
     pay_in_utils.trace('p_esi_org       ',p_esi_org);
     pay_in_utils.trace('p_gre           ',to_char(p_gre));
     pay_in_utils.trace('p_pf            ',to_char(p_pf));
     pay_in_utils.trace('p_esi           ',to_char(p_esi));
     pay_in_utils.trace('**************************************************','********************');
END IF;

  OPEN  c_max_pay_date;
  FETCH c_max_pay_date INTO l_max_date_earned;
  CLOSE c_max_pay_date;

  OPEN c_asg_start_date;
  FETCH c_asg_start_date INTO l_asg_start_date;
  CLOSE c_asg_start_date;



  OPEN  c_payroll_month_dates;
  FETCH c_payroll_month_dates INTO l_start_date,l_end_date;
  CLOSE c_payroll_month_dates;

  OPEN  c_org_id(p_gre_org);--Current GRE Organization
  FETCH c_org_id INTO l_gre_org_id;
  CLOSE c_org_id;

  OPEN  c_org_id(p_pf_org);--Current PF Organization
  FETCH c_org_id INTO l_pf_org_id;
  IF c_org_id%NOTFOUND THEN
    l_pf_org_id := -99;
  END IF;
  CLOSE c_org_id;

  OPEN  c_org_id(p_esi_org);--Current ESI Organization
  FETCH c_org_id INTO l_esi_org_id;
  IF c_org_id%NOTFOUND THEN
    l_esi_org_id := -99;
  END IF;
  CLOSE c_org_id;

  OPEN  c_gre_changes(l_start_date,l_end_date);--Total Changes in the GRE
  FETCH c_gre_changes INTO l_count;
  CLOSE c_gre_changes;

  p_message := 'SUCCESS';


  IF (l_max_date_earned > l_asg_start_date)
  THEN
          IF (p_gre IS NOT NULL) AND (p_gre <> l_gre_org_id)
          THEN
                  p_message := 'PER_IN_GRE_CHANGE_FORBIDDEN';
          ELSIF (p_pf IS NOT NULL) AND (p_pf <> l_pf_org_id)
	  THEN
	          p_message        := 'PER_IN_SCL_CHANGE_FORBIDDEN';
		  p_token_name(1)  := 'ORG';
		  p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','PF_ORG');
          ELSIF (p_esi IS NOT NULL) AND (p_esi <> l_esi_org_id)
	  THEN
            hr_utility.trace('ven_Inside ESI Error message condition');
	          p_message        := 'PER_IN_SCL_CHANGE_FORBIDDEN';
		  p_token_name(1)  := 'ORG';
		  p_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','ESI_ORG');
          ELSE
          IF g_debug THEN
	     pay_in_utils.trace('p_message       ',p_message);
	  END IF;
          pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
                  RETURN;
          END IF;
  ELSIF (l_count > 2)
  THEN
          p_message := 'PER_IN_GRE_CHANGE_FORBIDDEN';
  ELSIF (l_count = 2)
  THEN
          l_le_start_date := pay_in_tax_utils.le_start_date(l_org_id,p_assignment_id,p_effective_date);
          l_le_end_date   := pay_in_tax_utils.le_end_date(l_org_id,p_assignment_id,p_effective_date);

          OPEN  c_flag(l_org_id,l_start_date,l_le_start_date - 1);
          FETCH c_flag INTO l_flag;
          CLOSE c_flag;

          IF (l_flag IS NULL)
          THEN
                OPEN  c_flag(l_org_id,l_le_end_date + 1,l_end_date);
                FETCH c_flag INTO l_flag;
                CLOSE c_flag;

                IF (l_flag IS NULL) THEN
		  IF g_debug THEN
		     pay_in_utils.trace('p_message       ',p_message       );
		  END IF;
		  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,30);
                   RETURN;
                ELSE
                   p_message := 'PER_IN_GRE_CHANGE_FORBIDDEN';
                END IF;
          ELSE
                p_message := 'PER_IN_GRE_CHANGE_FORBIDDEN';
          END IF;
  ELSE
         IF g_debug THEN
	     pay_in_utils.trace('p_message       ',p_message       );
	  END IF;
          pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,40);
          RETURN;
  END IF;

END check_gre_update;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PF_UPDATE                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create PF ELement Entries              --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                  p_dt_mode             VARCHAR2                      --
--                  p_assignment_id       NUMBER                        --
--                  p_pf_org              VARCHAR2                      --
--            OUT : p_message             VARCHAR2                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Dec-04  statkar   Created this function                     --
-- 1.1   27-Dec-04  lnagaraj  Used pay_in_utils.chk_element_link        --
-- 1.2   24-Mar-05  aaagarwa  Modified cursor c_pf                      --
-- 1.3   10-Apr-05  abhjain   Removed the automatic element entry code  --
-- 1.4   25-Jul-05  snekkala  Removed check for PF organization         --
-- 1.5   18-Aug-05  abhjain   Commented the call to check_father_husband_name--
--------------------------------------------------------------------------
PROCEDURE check_pf_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_gre_org          IN  VARCHAR2
	 ,p_pf_org           IN  VARCHAR2
	 ,p_esi_org          IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
         ,p_gre              IN NUMBER
	 ,p_pf               IN NUMBER
	 ,p_esi              IN NUMBER
         )
IS

    l_procedure              VARCHAR2(100);
    l_message_name           VARCHAR2(100);
    l_token_value            VARCHAR2(10);

BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure := g_package ||'check_pf_update';
    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    IF g_debug THEN
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_effective_date',to_char(p_effective_date,'yyyy-mm-dd'));
         pay_in_utils.trace('p_dt_mode      ',p_dt_mode      );
	 pay_in_utils.trace('p_assignment_id',to_char(p_assignment_id));
	 pay_in_utils.trace('p_gre_org      ',p_gre_org      );
	 pay_in_utils.trace('p_pf_org       ',p_pf_org       );
	 pay_in_utils.trace('p_esi_org      ',p_esi_org      );
	 pay_in_utils.trace('p_gre          ',to_char(p_gre));
	 pay_in_utils.trace('p_pf           ',to_char(p_pf));
	 pay_in_utils.trace('p_esi          ',to_char(p_esi));
	 pay_in_utils.trace('**************************************************','********************');
   END IF;

   l_message_name:='SUCCESS';
   pay_in_utils.null_message(p_token_name, p_token_value);
/*
   check_father_husband_name
           (p_assignment_id  =>p_assignment_id
           ,p_effective_date =>p_effective_date
           ,p_message_name   =>l_message_name
           ,p_token_value    =>l_token_value
           );
   IF l_message_name = 'PER_IN_CONTACT_DETAILS' THEN
           hr_utility.set_message(800, 'PER_IN_CONTACT_DETAILS');
           hr_utility.set_message_token('RELATION',l_token_value);
           hr_utility.raise_error;
   ELSIF l_message_name <> 'SUCCESS' THEN
           hr_utility.set_message(800, l_message_name);
           hr_utility.raise_error;
   END IF;
*/
   check_gre_update
         (p_effective_date  => p_effective_date
         ,p_dt_mode         => p_dt_mode
         ,p_assignment_id   => p_assignment_id
         ,p_gre_org         => p_gre_org
	 ,p_pf_org          => p_pf_org
	 ,p_esi_org         => p_esi_org
         ,p_gre             => p_gre
	 ,p_pf              => p_pf
	 ,p_esi             => p_esi
         ,p_message         => l_message_name
 	 ,p_token_name      => p_token_name
	 ,p_token_value     => p_token_value
         );

   IF l_message_name <> 'SUCCESS' THEN
           pay_in_utils.raise_message(800, l_message_name, p_token_name, p_token_value);
   END IF;

   IF g_debug THEN
   	 pay_in_utils.trace('p_message',p_message);
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,170);

END check_pf_update;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ESI_UPDATE                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create PF ELement Entries              --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                  p_dt_mode             VARCHAR2                      --
--                  p_assignment_id       NUMBER                        --
--                  p_esi_org             VARCHAR2                      --
--            OUT : p_message             VARCHAR2                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   05-Dec-04  statkar   Created this function                     --
-- 1.1   14-Dec-04  aaagarwa  Added code for deleting ESI element entry --
--                            when payroll has not been run.            --
-- 1.2   27-Dec-04  lnagaraj  Used pay_in_utils.chk_element_link        --
-- 1.3   24-Mar-05  aaagarwa  Modified the cursor c_esi                 --
-- 1.4   10-Apr-05  abhjain   NULLed out the procedure                  --
--------------------------------------------------------------------------
PROCEDURE check_esi_update
         (p_effective_date   IN  DATE
         ,p_dt_mode          IN  VARCHAR2
         ,p_assignment_id    IN  NUMBER
         ,p_esi_org          IN  VARCHAR2
         ,p_message          OUT NOCOPY VARCHAR2
         )
IS
BEGIN

  NULL;

END check_esi_update;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : in_reset_input                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Procedure to reset remarks of PF Information element--
-- Parameters     :                                                     --
--             IN : p_assignment_id           NUMBER                    --
--                  p_element_entry_id        NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_element_type_id         NUMBER                    --
--                  p_date_earned             DATE                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   02-Jan-05  aaagarwa  Created this procedure                    --
--------------------------------------------------------------------------

Function in_reset_input_values(
		       p_assignment_id     NUMBER
                      ,p_business_group_id NUMBER
                      ,p_element_type_id   NUMBER
                      ,p_element_entry_id  NUMBER
                      ,p_date              DATE
                      ,p_input_value       VARCHAR2)
RETURN NUMBER IS
   Cursor c_ovn
   IS
   Select object_version_number
   From  pay_element_entries_f
   Where element_type_id = p_element_type_id
   And   assignment_id   = p_assignment_id
   And   p_date Between effective_start_date and effective_end_date;

   Cursor c_input_value_id
   IS
   Select input_value_id
   From pay_input_values_f
   Where element_type_id  = p_element_type_id
   And   p_date Between effective_start_date AND effective_end_date
   And   name=p_input_value;

   l_input_val_id           NUMBER;
   l_ovn                    NUMBER;
   l_effective_start_date   DATE;
   l_effective_end_date     DATE;
   l_warning                BOOLEAN;
   l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'in_reset_input_values';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id    ',to_char(p_assignment_id    ));
     pay_in_utils.trace('p_business_group_id',to_char(p_business_group_id));
     pay_in_utils.trace('p_element_type_id  ',to_char(p_element_type_id  ));
     pay_in_utils.trace('p_element_entry_id ',to_char(p_element_entry_id ));
     pay_in_utils.trace('p_date             ',to_char(p_date,'yyyy-mm-dd'));
     pay_in_utils.trace('p_input_value      ',p_input_value);
     pay_in_utils.trace('**************************************************','********************');
END IF;

   OPEN  c_ovn;
   FETCH c_ovn INTO  l_ovn;
   CLOSE c_ovn;

   OPEN  c_input_value_id;
   FETCH c_input_value_id INTO l_input_val_id;
   CLOSE c_input_value_id;

     pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode         =>  'UPDATE'
         ,p_effective_date                =>  p_date+1
         ,p_business_group_id             =>  p_business_group_id
         ,p_element_entry_id              =>  p_element_entry_id
         ,p_object_version_number         =>  l_ovn
         ,p_input_value_id4               =>  l_input_val_id
         ,p_entry_value4                  =>  ' '
         ,p_effective_start_date          =>  l_effective_start_date
         ,p_effective_end_date            =>  l_effective_end_date
         ,p_update_warning                =>  l_warning
         );

   IF g_debug THEN
     pay_in_utils.trace('1','1');
   END IF;

   pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

    RETURN 1;
    EXCEPTION
      When OTHERS THEN
      BEGIN
	      IF g_debug THEN
		pay_in_utils.trace('0','0');
	     END IF;

	     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

     RETURN 0;
     END;
END in_reset_input_values;

--------------------------------------------------------------------------
-- Name           : check_pf_location                                   --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Proc to be called for validation                    --
-- Parameters     :                                                     --
--             IN : p_organization_id      IN NUMBER                    --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   24-Jan-05  aaagarwa  Created this procedure for validating loc --
--------------------------------------------------------------------------
PROCEDURE check_pf_location
            (p_organization_id    IN  NUMBER
            ,p_calling_procedure  IN  VARCHAR2
            ,p_message_name       OUT NOCOPY VARCHAR2
            ,p_token_name         OUT NOCOPY pay_in_utils.char_tab_type
            ,p_token_value        OUT NOCOPY pay_in_utils.char_tab_type)
IS
   l_procedure  VARCHAR2(100);

  CURSOR csr_loc IS
   SELECT location_id
   FROM   hr_all_organization_units
   WHERE  organization_id = p_organization_id;

   l_location_id    hr_all_organization_units.location_id%TYPE;

BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'check_pf_location';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);


 IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_organization_id  ',to_char(p_organization_id));
     pay_in_utils.trace('p_calling_procedure',p_calling_procedure);
     pay_in_utils.trace('**************************************************','********************');
 END IF;

  OPEN csr_loc ;
  FETCH csr_loc
  INTO  l_location_id;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF l_location_id IS NULL THEN
    CLOSE csr_loc;
    pay_in_utils.set_location(g_debug,l_procedure,30);
    p_message_name := 'PER_IN_NO_STATE_ENTERED';
    RETURN;
  END IF;
  CLOSE csr_loc;

  IF g_debug THEN
     pay_in_utils.trace('p_message_name     ',p_message_name     );
  END IF;
 pay_in_utils.set_location(g_debug,l_procedure,40);
 RETURN;

 EXCEPTION
     WHEN OTHERS THEN
       p_message_name   := 'PER_IN_ORACLE_GENERIC_ERROR';
       p_token_name(1)  := 'FUNCTION';
       p_token_value(1) := l_procedure;
       p_token_name(2)  := 'SQLERRMC';
       p_token_value(2) := sqlerrm;
       RETURN;

END check_pf_location;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LWF_STATE                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the state associated with factory--
--                   /Establishement Org                                --
-- Parameters     :                                                     --
--             IN : p_org               VARCHAR2                        --
--            OUT : N/A                                                 --
--         Return : VARCHAR2                                            --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   25-OCT-07  sivanara   Created this function                    --
--------------------------------------------------------------------------

  FUNCTION get_lwf_state (p_organization_id  IN NUMBER)
  RETURN VARCHAR2
  IS
     l_message          VARCHAR2(255);
     CURSOR csr_state IS
       SELECT  hl.loc_information16
        FROM    hr_all_organization_units hou
	              ,hr_locations hl
        WHERE  hou.organization_id = p_organization_id
        AND    hou.location_id = hl.location_id
        AND    hl.style = 'IN';
--
    l_state   hr_lookups.lookup_code%TYPE;
    l_procedure VARCHAR2(100);
  BEGIN
     l_procedure := g_package||'get_lwf_state';
     g_debug          := hr_utility.debug_enabled;
     pay_in_utils.set_location(g_debug,'Entering : '||l_procedure, 10);
     OPEN csr_state ;
     FETCH csr_state INTO l_state;
     pay_in_utils.set_location (g_debug,'l_state = '||l_state,20);
     CLOSE csr_state;
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
     RETURN l_state;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,' Leaving : '||l_procedure, 40);
       hr_utility.trace(l_message);
       RETURN NULL;
  END get_lwf_state;

--------------------------------------------------------------------------
-- Name           : get_org_id                                          --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get the Org Id of PF/ESI/PT Organization--
--                  on a particular date                                --
-- Parameters     :                                                     --
--             IN : p_assignment_id        IN NUMBER                    --
--                  p_business_group_id    IN NUMBER                    --
--                  p_date                 IN DATE                      --
--                  p_org_type             IN VARCHAR2                  --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   08-Apr-05  abhjain   Created this function to get the org id   --
--------------------------------------------------------------------------
FUNCTION get_org_id(p_assignment_id     IN NUMBER
                   ,p_business_group_id IN NUMBER
                   ,p_date              IN DATE
                   ,p_org_type          IN VARCHAR2)
RETURN NUMBER
IS
  CURSOR cur_org (p_assignment_id      NUMBER
                 ,p_business_group_id  NUMBER
                 ,p_date               DATE)
       IS
   SELECT hsc.segment2
         ,hsc.segment3
         ,hsc.segment4
     FROM per_assignments_f      paf
         ,hr_soft_coding_keyflex hsc
    WHERE paf.assignment_id = p_assignment_id
      AND paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
      AND paf.business_group_id = p_business_group_id
      AND p_date BETWEEN paf.effective_start_date
                     AND paf.effective_end_date;

  l_segment2 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment3 hr_soft_coding_keyflex.segment1%TYPE;
  l_segment4 hr_soft_coding_keyflex.segment1%TYPE;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

BEGIN

  l_procedure := g_package||'get_org_id';
  g_debug          := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug,'Entering : '||l_procedure, 10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('p_assignment_id    ',to_char(p_assignment_id));
     pay_in_utils.trace('p_business_group_id',to_char(p_business_group_id));
     pay_in_utils.trace('p_date             ',to_char(p_date,'yyyy-mm-dd'));
     pay_in_utils.trace('p_org_type         ',p_org_type         );
     pay_in_utils.trace('**************************************************','********************');
END IF;

  OPEN cur_org (p_assignment_id
               ,p_business_group_id
               ,p_date);
  FETCH cur_org into l_segment2
                    ,l_segment3
                    ,l_segment4;
  pay_in_utils.set_location (g_debug,'l_segment2 = '||l_segment2,20);
  pay_in_utils.set_location (g_debug,'l_segment3 = '||l_segment3,30);
  pay_in_utils.set_location (g_debug,'l_segment4 = '||l_segment4,40);
  CLOSE cur_org;

  IF p_org_type = 'PF' THEN
     return to_number(l_segment2);
  ELSIF p_org_type = 'PT' THEN
     return to_number(l_segment3);
  ELSIF p_org_type = 'ESI' THEN
     return to_number(l_segment4);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

EXCEPTION
     WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,' Leaving : '||l_procedure, 30);
       hr_utility.trace(l_message);
       RETURN NULL;


END get_org_id;

END pay_in_ff_pkg;


/
