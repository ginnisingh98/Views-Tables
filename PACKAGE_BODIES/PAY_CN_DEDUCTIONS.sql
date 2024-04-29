--------------------------------------------------------
--  DDL for Package Body PAY_CN_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_DEDUCTIONS" AS
/* $Header: pycndedn.pkb 120.12.12010000.14 2009/12/02 05:42:22 dduvvuri ship $ */

g_package_name     CONSTANT VARCHAR2(18):= 'pay_cn_deductions.';
g_procedure_name   VARCHAR2(100);
g_debug            BOOLEAN;

g_start_date       CONSTANT DATE := TRUNC(TO_DATE('01-01-0001','DD-MM-YYYY'));
g_end_date         CONSTANT DATE := TRUNC(TO_DATE('31-12-4712','DD-MM-YYYY'));

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_HIGH_LIMIT_EXEMPT                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the PHF High Limit Exemption flag--
--                  from the GRE/Legal Entity Level                     --
-- Parameters     :                                                     --
--             IN : p_employer_id      VARCHAR2                         --
--                                                                      --
--            OUT :                                                     --
--                                                                      --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   10-Oct-06  abhjain   Created this function                     --
-- 1.1   19-Mar-08  dduvvuri  6828199 - this function will not be used further
--                            as the context 'PER_PHF_STAT_INFO_CN' is removed now
--------------------------------------------------------------------------
FUNCTION get_phf_high_limit_exempt (p_employer_id   IN  VARCHAR2
                                    ,p_contribution_area  IN VARCHAR2
                                   )
RETURN VARCHAR2

IS
    g_procedure_name VARCHAR2(100);
   --
   -- PHF High Limit Exemption check cursor
   --
   CURSOR c_phf_high_limit_exempt
   IS
       SELECT org_information2       -- Y/N
         FROM hr_organization_information hoi
        WHERE hoi.organization_id = p_employer_id
          AND hoi.org_information_context = 'PER_PHF_STAT_INFO_CN'
	  AND hoi.org_information1 = p_contribution_area;

   l_exempt_flag    VARCHAR2(10);

BEGIN

   g_procedure_name := g_package_name||'get_phf_high_limit_exempt';
   hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);

      -- Check if user has eneter values for Employee contribution rates
      OPEN  c_phf_high_limit_exempt;
      FETCH  c_phf_high_limit_exempt INTO l_exempt_flag;
      CLOSE c_phf_high_limit_exempt;

      hr_cn_api.set_location(g_debug,'l_exempt_flag: '|| l_exempt_flag, 15);

         IF g_debug THEN
            hr_utility.trace(' =======================================================');
            hr_utility.trace(' .                 Exempt Flag         : '||l_exempt_flag);
            hr_utility.trace(' =======================================================');
         END IF;

         RETURN NVL(l_exempt_flag, 'N');

END get_phf_high_limit_exempt;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_SPECIAL_TAX_METHOD                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tax method for Special       --
--                  payment types based on the tax area for China       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id        NUMBER                       --
--                  p_date_earned          DATE                         --
--                  p_tax_area             VARCHAR2                     --
--                  p_special_payment_type VARCHAR2                     --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   18-FEB-03  vinaraya  Created this function                     --
-- 1.1   19-MAR-03  vinaraya  Changed the indentation                   --
-- 1.2   20-MAR-03  vinaraya  Changed the tables PER_ALL_ASSIGNMENTS_F  --
--                            to PER_ALL_ASSIGNMENTS and HR_SOFT_CODIN  --
--                            G_KEYFLEX_KFV to HR_SOFT_CODING_KEYFLEX   --
--                            in csr_tax for performance reasons.       --
-- 1.3   20-MAR-03  vinaraya  Changed the p_special_payment_type_id     --
--                            to l_special_payment_type_id in the       --
--                            csr_tax cursor definition.                --
-- 1.4   06-JUN-03  saikrish  Added parameter p_message                 --
-- 1.5   19-Jun-03  statkar   Removed parameter p_message               --
--------------------------------------------------------------------------
FUNCTION get_special_tax_method ( p_assignment_id              IN  NUMBER
                                , p_date_earned                IN  DATE
                                , p_tax_area                   IN  VARCHAR2
                                , p_special_payment_type       IN  VARCHAR2
                                )
RETURN VARCHAR2
IS
    l_tax_method               hr_organization_information.org_information3%type;
    l_special_payment_type_id  pay_element_classifications.classification_id%type;

    CURSOR csr_sp_pay_id ( p_special_payment_type   IN  VARCHAR2 ) IS
      SELECT pri.classification_id
      FROM   pay_element_classifications pri,
             pay_element_classifications sec
      WHERE  sec.legislation_code         = 'CN'
      AND    sec.classification_name      = 'Special Payments'
      AND    pri.parent_classification_id = sec.classification_id
      AND    pri.classification_name      = p_special_payment_type;

    CURSOR csr_tax( p_assignment_id           NUMBER
                  , p_date_earned             DATE
                  , p_tax_area                VARCHAR2
                  , p_special_payment_type_id NUMBER
                  ) IS
      SELECT hoi.org_information3
      FROM   hr_organization_information hoi
            ,per_all_assignments         paf
            ,hr_soft_coding_keyflex      hsc
            ,hr_all_organization_units   hou
      WHERE  paf.assignment_id           = p_assignment_id
      AND    paf.soft_coding_keyflex_id  = hsc.soft_coding_keyflex_id
      AND    hsc.segment1                = hou.organization_id
      AND    hou.business_group_id       = hoi.organization_id
      AND    hoi.org_information_context = 'PER_SPECIAL_TAX_METHODS_CN'
      AND    hoi.org_information1        = p_tax_area
      AND    hoi.org_information2        = p_special_payment_type_id
      AND    p_date_earned  BETWEEN to_date(substr(hoi.org_information4,1,10),'YYYY/MM/DD')
      AND    to_date(NVL(substr(hoi.org_information5,1,10),'4712/12/31'),'YYYY/MM/DD');

BEGIN
    OPEN csr_sp_pay_id(p_special_payment_type);
    FETCH csr_sp_pay_id
    INTO l_special_payment_type_id;
      IF csr_sp_pay_id %NOTFOUND THEN
        l_tax_method:='UNKNOWN';
      CLOSE csr_sp_pay_id;
      RETURN l_tax_method;
      END IF;
    CLOSE csr_sp_pay_id;

    OPEN csr_tax( p_assignment_id
                , p_date_earned
    	        , p_tax_area
	        , l_special_payment_type_id
	        );
    FETCH csr_tax
    INTO l_tax_method;
      IF csr_tax%NOTFOUND THEN
        l_tax_method:='UNKNOWN';
      END IF;
    CLOSE csr_tax;
    RETURN l_tax_method;

EXCEPTION
    WHEN OTHERS THEN
      IF csr_tax%ISOPEN THEN
        CLOSE csr_tax;
      END IF;
      IF csr_sp_pay_id%ISOPEN THEN
        CLOSE csr_sp_pay_id;
      END IF;
      l_tax_method:='UNKNOWN';
      RETURN l_tax_method;


END get_special_tax_method;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ACCRUAL_PLAN                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return the accrual plan id for the      --
--                  specified accrual category.                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id        NUMBER                       --
--                  p_effective_date       DATE                         --
--                  p_plan_category        VARCHAR2                     --
--            OUT : p_message              VARCHAR2                     --
--                  plan_id                NUMBER                       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-APR-03  statkar  Created this function                      --
-- 1.1   06-JUN-03  saikrish Added p_message                            --
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

    OPEN csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category) ;
    FETCH csr_get_accrual_plan_id INTO l_accrual_plan_id;

    IF csr_get_accrual_plan_id%NOTFOUND
    THEN
      --Changes for bug 2995758 start here
      p_message := 'ERROR';
      CLOSE csr_get_accrual_plan_id;
    ELSE
      p_message := 'SUCCESS';
      CLOSE csr_get_accrual_plan_id;
      --End of changes for bug 2995758
    END IF ;


    RETURN l_accrual_plan_id;

END get_accrual_plan;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TERM_NET_ACCRUAL                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the accrued leave for the given  --
--                  accrual plan                                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id        NUMBER                       --
--                  p_payroll_id           NUMBER                       --
--                  p_business_group_id    NUMBER                       --
--                  p_plan_id              NUMBER                       --
--                  p_calculation_date     DATE                         --
--            OUT : p_message              VARCHAR2                     --
--                  accrued_leave          NUMBER                       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   01-APR-03  statkar  Created this function                      --
-- 1.1   06-JUN-03  saikrish Added p_message                            --
--------------------------------------------------------------------------
FUNCTION get_term_net_accrual ( p_assignment_id     IN  NUMBER
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

BEGIN

    l_plan_id := get_accrual_plan ( p_assignment_id    => p_assignment_id
                                   ,p_effective_date   => p_calculation_date
                                   ,p_plan_category    => p_plan_category
                                   ,p_message          => p_message --2995758 Changes
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

    RETURN l_accrued_leave;

END get_term_net_accrual;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_CONT_BASE_METHOD                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the contribute method details  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_cont_base_method            VARCHAR2              --
--                  p_lowest_avg_salary           NUMBER                --
--                  p_average_salary              NUMBER                --
--                  p_fixed_amount                NUMBER                --
--         RETURN : BOOLEAN                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   23-JUN-03  statkar  Bug 3017511 Created this function          --
-- 1.1   03-Jul-03  saikrish Added set location and trace calls,        --
--                           p_ee_or_er,p_return_segment parameters     --
-- 1.2   04-Jul-03  saikrish Removed the p_ee_or_er parameter           --
-- 1.3   14-Mar-08  dduvvuri Bug 6828199 - Added new cont base method of --
--                           'PROV AVE 60'
--------------------------------------------------------------------------
FUNCTION validate_cont_base_method
          ( p_cont_base_method    IN VARCHAR2
           ,p_fixed_amount        IN NUMBER
           ,p_lowest_avg_salary   IN NUMBER
           ,p_average_salary      IN NUMBER
	       ,p_return_segment      OUT NOCOPY VARCHAR2
           )
RETURN BOOLEAN
IS
   l_message VARCHAR2(250);
BEGIN
   g_procedure_name := g_package_name||'validate_cont_base_method';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);

    IF p_cont_base_method in ( 'CITY AVE 60' , 'PROV AVE 60' ) THEN /* modified for 6828199 */

       IF p_average_salary IS NULL THEN
          p_return_segment := 'Average Salary'; --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    ELSIF p_cont_base_method = 'CITY LOW LAST YR' THEN

       IF p_lowest_avg_salary IS NULL THEN
          p_return_segment := 'Lowest Average Salary'; --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    ELSIF p_cont_base_method = 'FIXED' THEN

       IF p_fixed_amount IS NULL THEN
          --Bug#:3034481
          p_return_segment := 'Fixed Amount';
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    END IF;

    hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 30);
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 40);
      hr_utility.trace(l_message);
      RETURN FALSE;

END validate_cont_base_method;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_SWITCH_WITH_CONT_BASE                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to validate Periodicity against            --
--                  the contribute base calc methods.                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_cont_base_method            VARCHAR2              --
--                  p_switch_periodicity          VARCHAR2              --
--         RETURN : BOOLEAN                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   09-JUL-03  sshankar  Bug 3038642 Created this function.        --
-- 1.1   02-SEP-03  vinaraya  Bug 3123334 Included the validation for   --
--                            EE/ER contribution Method being 'N/A'     --
-- 1.2   03-SEP-03  vinaraya  Reverted the changes and moved the check  --
--                            before the function call.                 --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION validate_switch_with_cont_base
          ( p_cont_base_method      IN  VARCHAR2
           ,p_switch_periodicity    IN  VARCHAR2
           )
RETURN BOOLEAN
IS
   l_message VARCHAR2(250);
BEGIN

   g_procedure_name := g_package_name||'validate_switch_with_cont_base';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);


     IF p_switch_periodicity = 'YEARLY'  THEN
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 20);

        IF ( p_cont_base_method = 'AVE MTH' or p_cont_base_method = 'EMP PRIOR SWITCH' )  THEN
           hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 30);
           RETURN TRUE;
        ELSE
           hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 40);
           RETURN FALSE;
        END IF;

     ELSIF p_switch_periodicity = 'MONTHLY'  THEN
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 50);
        IF ( p_cont_base_method = 'AVE MTH' or p_cont_base_method = 'EMP PRIOR SWITCH')  THEN
           hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 60);
           RETURN FALSE;
        ELSE
           hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 70);
           RETURN TRUE;
        END IF;

     END IF;

     hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 80);
     RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 90);
      hr_utility.trace(l_message);
      RETURN FALSE;


END VALIDATE_SWITCH_WITH_CONT_BASE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_LOW_LIMIT_METHOD                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the low limit method details   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_low_limit_method            VARCHAR2              --
--                  p_lowest_avg_salary           NUMBER                --
--                  p_average_salary              NUMBER                --
--                  p_fixed_amount                NUMBER                --
--         RETURN : BOOLEAN                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   23-JUN-03  statkar  Bug 3017511 Created this function          --
-- 1.1   03-Jul-03  saikrish Added set location and trace calls,        --
--                           p_return_segment                           --
-- 1.2   14-Mar-08  dduvvuri Bug 6828199 - Added new low limit method of --
--                           'PROV AVE PREV YEAR'
--------------------------------------------------------------------------
FUNCTION validate_low_limit_method(
            p_low_limit_method    IN VARCHAR2
           ,p_fixed_amount        IN NUMBER
           ,p_lowest_avg_salary   IN NUMBER
           ,p_average_salary      IN NUMBER
	       ,p_return_segment      OUT NOCOPY VARCHAR2
           )
RETURN BOOLEAN
IS
   l_message VARCHAR2(250);
BEGIN

   g_procedure_name := g_package_name||'validate_low_limit_method';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);

    IF p_low_limit_method = 'CITY LOW AVE' THEN

       IF p_lowest_avg_salary IS NULL THEN
          p_return_segment := 'Lowest Average Salary';  --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    ELSIF p_low_limit_method in ( 'MTH AVE PREV YEAR','PROV AVE PREV YEAR') THEN -- bug 6828199

       IF p_average_salary IS NULL THEN
          p_return_segment := 'Average Salary';     --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    ELSIF p_low_limit_method = 'FIXED' THEN

       IF p_fixed_amount IS NULL THEN
          p_return_segment := 'Low Limit Amount';  --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    END IF;

    hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 30);
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 40);
      hr_utility.trace(l_message);
      RETURN FALSE;

END validate_low_limit_method;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_HIGH_LIMIT_METHOD                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the low limit method details   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_high_limit_method            VARCHAR2             --
--                  p_average_salary              NUMBER                --
--                  p_fixed_amount                NUMBER                --
--         RETURN : BOOLEAN                                             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   23-JUN-03  statkar  Bug 3017511 Created this function          --
-- 1.1   03-Jul-03  saikrish Added set location and trace calls         --
--                           ,p_return_segment                          --
-- 1.2   14-Mar-08  dduvvuri Bug 6828199 - Added 2 new high limit methods
--                           'PROV AVE PREV YEAR' , 'CTY AVE PREV YEAR'
--------------------------------------------------------------------------
FUNCTION validate_high_limit_method(
            p_high_limit_method    IN VARCHAR2
           ,p_fixed_amount        IN NUMBER
           ,p_average_salary      IN NUMBER
	       ,p_return_segment      OUT NOCOPY VARCHAR2
           )
RETURN BOOLEAN
IS
   l_message VARCHAR2(250);
BEGIN

   g_procedure_name := g_package_name||'validate_high_limit_method';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);

   IF p_high_limit_method in ( 'MTH AVE PREV YEAR' , 'PROV AVE PREV YEAR' ,'CTY AVE PREV YEAR') THEN -- Bug 6828199

       IF p_average_salary IS NULL THEN
          p_return_segment := 'Average Salary';   --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    ELSIF p_high_limit_method = 'FIXED' THEN

       IF p_fixed_amount IS NULL THEN
          p_return_segment := 'High Limit Amount';    --Bug#:3034481
	      hr_cn_api.set_location(g_debug,' Return Segment : '||p_return_segment,15);
          hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
          RETURN FALSE;
       END IF;

    END IF;

    hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 30);
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 40);
      hr_utility.trace(l_message);
      RETURN FALSE;

END validate_high_limit_method;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ROUNDED_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return the rounded value as per method  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_value                NUMBER                       --
--                  p_rounding_method      VARCHAR2                     --
--         RETURN : NUMBER                                              --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-Apr-06  statkar  Created this function                      --
--------------------------------------------------------------------------
FUNCTION get_rounded_value
                    (p_value              IN  NUMBER
                    ,p_rounding_method    IN VARCHAR2
                    )
RETURN NUMBER
IS
    l_amount    NUMBER ;
    l_message   VARCHAR2(255);
BEGIN
   g_procedure_name := g_package_name||'get_rounded_value';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);
   IF g_debug THEN
     hr_utility.trace('=======================================================');
     hr_utility.trace('   P_Value           : '||TO_CHAR(p_value));
     hr_utility.trace('   P_Rounding_Method : '||p_rounding_method);
   END IF;

/* Possible rounding methods are:
    ROUND CENT     Round to nearest Cent      (0.01)
    ROUNDTO JIAO   Round to nearest Jiao      (0.1)
    ROUND          Round to nearest Yuan      (1)
    ROUND JIAO     Round up to nearest Jiao   (0.1)
    ROUNDUP YUAN   Round up to nearest Yuan   (1)
*/

   IF p_rounding_method = 'ROUND CENT' THEN
      l_amount := round(p_value,2);
   ELSIF p_rounding_method = 'ROUNDTO JIAO' THEN
      l_amount := round(p_value,1);
   ELSIF p_rounding_method = 'ROUND' THEN
      l_amount := round(p_value,0) ;
   ELSIF p_rounding_method = 'ROUND JIAO' THEN
      l_amount := fffunc.round_up(p_value,1) ;
   ELSIF p_rounding_method = 'ROUNDUP YUAN' THEN
      l_amount := fffunc.round_up(p_value,0) ;
   ELSE
     l_amount := round(p_value,2);
   END IF;

   IF g_debug THEN
     hr_utility.trace('   P_Rounded_Value   : '||TO_CHAR(l_amount));
     hr_utility.trace('=======================================================');
   END IF ;
   hr_cn_api.set_location(g_debug,' Leaving : '|| g_procedure_name, 20);
   RETURN l_amount;

EXCEPTION
    WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 40);
      hr_utility.trace(l_message);
      RETURN 0;
END get_rounded_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CONT_BASE_METHODS                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the contribute method details    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id           NUMBER                --
--                  p_contribution_area           VARCHAR2              --
--		            p_phf_si_type                 VARCHAR2              --
--                  p_hukou_type                  VARCHAR2              --
--	                p_effective_date              DATE                  --
--            OUT : p_ee_cont_base_method         VARCHAR2              --
--                  p_er_cont_base_method         VARCHAR2              --
--                  p_low_limit_method            VARCHAR2              --
--                  p_low_limit_amount            NUMBER              --
--                  p_high_limit_method           VARCHAR2              --
--                  p_high_limit_amount           NUMBER              --
--                  p_switch_periodicity          VARCHAR2              --
--                  p_switch_month                VARCHAR2              --
--                  p_rounding_method             VARCHAR2              --
--                  p_lowest_avg_salary           NUMBER              --
--                  p_average_salary              NUMBER              --
--                  p_ee_fixed_amount             NUMBER              --
--                  p_er_fixed_amount             NUMBER              --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-MAY-03  statkar  Created this function                      --
-- 2.0   20-Jun-03  statkar  Bug 3017511 -Coding errors removed changes --
--                           Added validation logic for interdependence --
-- 3.0   03-Jul-03  saikrish Added set location and trace calls         --
--                           ,message calls                             --
-- 4.0   03-SEP-03  vinaraya Included additional checks before the      --
--                           validate method function calls.            --
-- 5.0   15-Mar-05  snekkala Removed the validation for Cont. Basis     --
-- 6.0   14-Mar-08  dduvvuri Bug 6828199 - Modified signature to fetch
--                           EE/ER Tax Threshhold amount
--------------------------------------------------------------------------
FUNCTION  get_cont_base_methods
                 (p_business_group_id           IN   NUMBER
                 ,p_contribution_area           IN   VARCHAR2
		         ,p_phf_si_type                 IN   VARCHAR2
                 ,p_hukou_type                  IN   VARCHAR2
		         ,p_effective_date              IN   DATE
		 --
                 ,p_ee_cont_base_method         OUT  NOCOPY VARCHAR2
                 ,p_er_cont_base_method         OUT  NOCOPY VARCHAR2
                 ,p_low_limit_method            OUT  NOCOPY VARCHAR2
                 ,p_low_limit_amount            OUT  NOCOPY NUMBER
                 ,p_high_limit_method           OUT  NOCOPY VARCHAR2
                 ,p_high_limit_amount           OUT  NOCOPY NUMBER
                 ,p_switch_periodicity          OUT  NOCOPY VARCHAR2
                 ,p_switch_month                OUT  NOCOPY VARCHAR2
                 ,p_rounding_method             OUT  NOCOPY VARCHAR2
                 ,p_lowest_avg_salary           OUT  NOCOPY NUMBER
                 ,p_average_salary              OUT  NOCOPY NUMBER
		         ,p_ee_fixed_amount             OUT  NOCOPY NUMBER
		         ,p_er_fixed_amount             OUT  NOCOPY NUMBER
			 ,p_tax_thrhld_amount           OUT  NOCOPY NUMBER /* added for bug 6828199 */
		 )
RETURN VARCHAR2
IS

   l_message    VARCHAR2(255);

   --
   -- Org Information cursor
   --
--
-- Bug 3017511 changes. Date format changed to HH24:MI:SS from HH:MI:SS
-- in the following two cursors.
--

   CURSOR c_cont1 IS
   --
       SELECT org_information4   -- EE Contribution Base
             ,org_information5   -- ER Contribution Base
	         ,org_information6   -- Low Limit Method
	         ,fnd_number.canonical_to_number(org_information7)   -- Low Limit Amount
	         ,org_information8   -- High Limit Method
	         ,fnd_number.canonical_to_number(org_information9)   -- High Limit Amount
	         ,org_information10  -- Switch Period Periodicity
	         ,org_information11  -- Switch Period Month
	         ,org_information12  -- Rounding Method
	         ,fnd_number.canonical_to_number(org_information13)  -- Lowest Average Salary
	         ,fnd_number.canonical_to_number(org_information14)  -- Average Salary
	         ,fnd_number.canonical_to_number(org_information17)  -- EE Fixed Amount
	         ,fnd_number.canonical_to_number(org_information18)  -- ER Fixed Amount
		 ,fnd_number.canonical_to_number(org_information19)  -- EE/ER Tax Threshold amount for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_CONT_BASE_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information15,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information16,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information2        = p_phf_si_type
       AND   org_information3        = p_hukou_type;

   CURSOR c_cont2 IS
   --
       SELECT org_information4   -- EE Contribution Base
             ,org_information5   -- ER Contribution Base
	         ,org_information6   -- Low Limit Method
	         ,fnd_number.canonical_to_number(org_information7)   -- Low Limit Amount
	         ,org_information8   -- High Limit Method
	         ,fnd_number.canonical_to_number(org_information9)   -- High Limit Amount
	         ,org_information10   -- Switch Period Periodicity
	         ,org_information11  -- Switch Period Month
	         ,org_information12  -- Rounding Method
	         ,fnd_number.canonical_to_number(org_information13)  -- Lowest Average Salary
	         ,fnd_number.canonical_to_number(org_information14)  -- Average Salary
--
-- Bug 3017511 changes. Added these two missed columns
--
	         ,fnd_number.canonical_to_number(org_information17)  -- EE Fixed Amount
	         ,fnd_number.canonical_to_number(org_information18)  -- ER Fixed Amount
		 ,fnd_number.canonical_to_number(org_information19)  -- EE/ER Tax Threshold amount for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_CONT_BASE_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information15,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information16,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information2        = p_phf_si_type
       AND   org_information3        IS NULL;

   l_found_flag     VARCHAR2(1) ;
   l_valid          BOOLEAN := FALSE;
   l_indep_seg      fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
   l_dep_seg        fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
   l_lookup_meaning hr_lookups.meaning%TYPE;
 --
 -- Start Bug 3038642
 --
   l_lookup_meaning_dep  hr_lookups.meaning%TYPE;
 --
 -- End Bug 3038642
 --

   p_return_segment fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE;
   p_ee_or_er       VARCHAR2(2);

BEGIN

   g_procedure_name := g_package_name||'get_cont_base_methods';
   hr_cn_api.set_location(g_debug,' Entering : '|| g_procedure_name, 10);

   l_found_flag := 'Y';
--
-- Check for the given hukou_type
--

   OPEN c_cont1 ;
   FETCH c_cont1 INTO
        p_ee_cont_base_method
       ,p_er_cont_base_method
       ,p_low_limit_method
       ,p_low_limit_amount
       ,p_high_limit_method
       ,p_high_limit_amount
       ,p_switch_periodicity
       ,p_switch_month
       ,p_rounding_method
       ,p_lowest_avg_salary
       ,p_average_salary
       ,p_ee_fixed_amount
       ,p_er_fixed_amount
       ,p_tax_thrhld_amount;  -- added for bug 6828199

   IF c_cont1%NOTFOUND THEN
   --
      OPEN c_cont2 ;
      hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 20);
--
-- Bug 3017511 changes. FETCH c_cont1 changed to FETCH c_cont2
--
      FETCH c_cont2 INTO
          p_ee_cont_base_method
         ,p_er_cont_base_method
         ,p_low_limit_method
         ,p_low_limit_amount
         ,p_high_limit_method
         ,p_high_limit_amount
         ,p_switch_periodicity
         ,p_switch_month
         ,p_rounding_method
         ,p_lowest_avg_salary
         ,p_average_salary
         ,p_ee_fixed_amount
         ,p_er_fixed_amount
	 ,p_tax_thrhld_amount; -- added for bug 6828199

      IF c_cont2%NOTFOUND THEN
      --
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 30);
         l_found_flag := 'N';
      --
      END IF;
      CLOSE c_cont2;
   --
   END IF;
   CLOSE c_cont1;

   hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 40);

   IF g_debug THEN
     hr_utility.trace(' =======================================================');
     hr_utility.trace(' .       EE Cont Base Method : '||p_ee_cont_base_method);
     hr_utility.trace(' .       ER Cont Base Method : '||p_er_cont_base_method);
     hr_utility.trace(' .       Low Limit Method    : '||p_low_limit_method);
     hr_utility.trace(' .       Low Limit Amount    : '||p_low_limit_amount);
     hr_utility.trace(' .       High Limit Method   : '||p_high_limit_method);
     hr_utility.trace(' .       High Limit Amount   : '||p_high_limit_amount);
     hr_utility.trace(' .       Switch Periodicity  : '||p_switch_periodicity);
     hr_utility.trace(' .       Switch Period Month : '||p_switch_month);
     hr_utility.trace(' .       Rounding Method     : '||p_rounding_method);
     hr_utility.trace(' .       Lowest Avg Salary   : '||p_lowest_avg_salary);
     hr_utility.trace(' .       Average Salary      : '||p_average_salary);
     hr_utility.trace(' .       EE Fixed Amount     : '||p_ee_fixed_amount);
     hr_utility.trace(' .       ER Fixed Amount     : '||p_er_fixed_amount);
     hr_utility.trace(' .       Tax Threshold Amount : '||p_tax_thrhld_amount);
     hr_utility.trace(' =======================================================');
   END IF;

   IF l_found_flag = 'N' THEN
         --Bug 3034481
     hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 50);
	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_PHF_SI_CODE'
	                                             ,p_lookup_code =>  p_phf_si_type
					             );
     l_message := hr_cn_api.get_pay_message('HR_374609_CONT_BASE_MISSING','PHFSI:'||l_lookup_meaning);
         --Bug 3034481

-- Bug 3017511 added the following return clause
	 RETURN l_message;

   ELSE
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 60);
         l_message := 'SUCCESS';
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 140);

   RETURN l_message;


EXCEPTION
   WHEN OTHERS THEN
   --
   -- Bug 3017511 changes. Added the two IF..END IF statements for checking open cursors.
   --
      IF c_cont1%ISOPEN THEN
         CLOSE c_cont1;
      END IF;

      IF c_cont2%ISOPEN THEN
         CLOSE c_cont2;
      END IF;

      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);
      RETURN l_message;

END get_cont_base_methods;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_RATES                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the PHF/SI Rates from Org Level  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id          NUMBER                     --
--                  p_contribution_area      VARCHAR2                   --
--                  p_hukou_type             VARCHAR2                   --
--                  p_legal_employer_id      NUMBER                     --
--		            p_phf_si_type            VARCHAR2                   --
--	                p_effective_date         VARCHAR2                   --
--                  p_organization_id        NUMBER                     --
--            OUT : p_ee_rate                NUMBER                     --
--		            p_er_rate                NUMBER                     --
--		            p_ee_percent_or_fixed    VARCHAR2                   --
--		            p_er_percent_or_fixed    VARCHAR2                   --
--		            p_ee_rounding_method     VARCHAR2                   --
--                  p_ee_rounding_method     VARCHAR2                   --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAY-03  statkar  Created this function                      --
-- 1.1   20-Jun-03  statkar  Bug 3017511 Changes                        --
-- 1.2   03-Jul-03  saikrish Added set location and trace calls         --
-- 1.3   04-Jul-03  sshankar Bug 3048748, Validate Hukou type against   --
--                           Organization.                              --
-- 1.4   05-Jul-04  sshankar Bug 3593118. Added Code to support         --
--                           Enterprise Annuity processing.             --
-- 1.5   15-Jul-04  sshankar Modified code as per review comments in Bug--
--                           3593118. And Changed cursor                --
--                           csr_months_of_service and renamed it to    --
--                           csr_years_of_service.                      --
-- 1.6   15-Mar-05  snekkala Removed the validation for Hukuo Type and  --
--                           Organization                               --
-- 1.7   05-Apr-05  rpalli   Bug 4161962. Added Code to support         --
--                           Enterprise Annuity Rounding.               --
-- 1.8   04-Mar-05  snekkala Bug 4303559. Added EE and ER Rounding      --
--                           methods support.                           --
-- 1.9   14-Mar-08  dduvvuri Bug 6828199 - Modified the signature to access
--                           EE and ER Tax threshold rates
-- 2.0   12-May-08  dduvvuri Bug 6943573 - Added cursor c_org4
-- 2.1   27-May-08  dduvvuri Bug 7120765 - Added fnd_number.canonical_to_number
--                           to org_information13 and org_information14 in all
--                           the 4 cursors.
--------------------------------------------------------------------------
FUNCTION get_phf_si_rates    (p_assignment_id               IN  NUMBER
                             ,p_business_group_id           IN  NUMBER
                             ,p_contribution_area           IN  VARCHAR2
			                 ,p_phf_si_type                 IN  VARCHAR2
			                 ,p_employer_id                 IN  VARCHAR2
                             ,p_hukou_type                  IN  VARCHAR2
			                 ,p_effective_date              IN  DATE
			     --
			                 ,p_ee_rate_type         OUT NOCOPY VARCHAR2
			                 ,p_er_rate_type         OUT NOCOPY VARCHAR2
			                 ,p_ee_rate              OUT NOCOPY NUMBER
			                 ,p_er_rate              OUT NOCOPY NUMBER
					 ,p_ee_thrhld_rate       OUT NOCOPY NUMBER  /* for bug 6828199 */
					 ,p_er_thrhld_rate       OUT NOCOPY NUMBER  /* for bug 6828199 */
			                 ,p_ee_rounding_method   OUT NOCOPY VARCHAR2
                             ,p_er_rounding_method   OUT NOCOPY VARCHAR2
			     )
RETURN VARCHAR2

IS
    g_procedure_name VARCHAR2(50);
   --
   -- Org Information cursor
   --
--
-- Bug 3017511 changes. Date format changed to HH24:MI:SS from HH:MI:SS
-- in the following three cursors.
--

   CURSOR c_org1
   IS
       SELECT fnd_number.canonical_to_number(org_information4)   -- EE Rate
	         ,org_information5   -- EE Percent or Fixed
	         ,fnd_number.canonical_to_number(org_information6)   -- EE Rate
	         ,org_information7   -- EE Percent or Fixed
	         ,org_information8   -- EE Rounding Method
             ,org_information12  -- ER Rounding Method
	     ,fnd_number.canonical_to_number(org_information13)  -- EE Tax Threshold rate for bug 6828199
	     ,fnd_number.canonical_to_number(org_information14)  -- ER Tax thershold rate for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_PHF_SI_RATES_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information10,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information11,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information3        = p_phf_si_type
       AND   org_information2        = p_employer_id
       AND   org_information9        = p_hukou_type;

   CURSOR c_org2
   IS
       SELECT fnd_number.canonical_to_number(org_information4)   -- EE Rate
	         ,org_information5   -- EE Percent or Fixed
	         ,fnd_number.canonical_to_number(org_information6)   -- EE Rate
	         ,org_information7   -- EE Percent or Fixed
             ,org_information8   -- EE Rounding Method
             ,org_information12  -- ER Rounding Method
	     ,fnd_number.canonical_to_number(org_information13)  -- EE Tax Threshold rate for bug 6828199
	     ,fnd_number.canonical_to_number(org_information14)  -- ER Tax thershold rate for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_PHF_SI_RATES_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information10,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information11,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information3        = p_phf_si_type
       AND   org_information2        = p_employer_id
       AND   org_information9        IS NULL;

   CURSOR c_org3
   IS
       SELECT fnd_number.canonical_to_number(org_information4)   -- EE Rate
	         ,org_information5   -- EE Percent or Fixed
	         ,fnd_number.canonical_to_number(org_information6)   -- EE Rate
	         ,org_information7   -- EE Percent or Fixed
             ,org_information8   -- EE Rounding Method
             ,org_information12  -- ER Rounding Method
	     ,fnd_number.canonical_to_number(org_information13)  -- EE Tax Threshold rate for bug 6828199
	     ,fnd_number.canonical_to_number(org_information14)  -- ER Tax thershold rate for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_PHF_SI_RATES_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information10,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information11,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information3        = p_phf_si_type
       AND   org_information2        IS NULL
       AND   org_information9        IS NULL;

   CURSOR c_org4
   IS
       SELECT fnd_number.canonical_to_number(org_information4)   -- EE Rate
	         ,org_information5   -- EE Percent or Fixed
	         ,fnd_number.canonical_to_number(org_information6)   -- EE Rate
	         ,org_information7   -- EE Percent or Fixed
	         ,org_information8   -- EE Rounding Method
             ,org_information12  -- ER Rounding Method
	     ,fnd_number.canonical_to_number(org_information13)  -- EE Tax Threshold rate for bug 6828199
	     ,fnd_number.canonical_to_number(org_information14)  -- ER Tax thershold rate for bug 6828199
       FROM hr_organization_information
       WHERE org_information_context = 'PER_CONT_AREA_PHF_SI_RATES_CN'
       AND   organization_id         = p_business_group_id
       AND   p_effective_date BETWEEN to_date(org_information10,'YYYY/MM/DD HH24:MI:SS')
                              AND     to_date(nvl(org_information11,'4712/12/31 00:00:00'),'YYYY/MM/DD HH24:MI:SS')
       AND   org_information1        = p_contribution_area
       AND   org_information3        = p_phf_si_type
       AND   org_information9        = p_hukou_type
       AND   org_information2        IS NULL ;

   l_indep_seg      fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
   l_dep_seg        fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
   l_lookup_meaning hr_lookups.meaning%TYPE;

--
-- End 3048748
--

   l_message        VARCHAR2(255);

   --
   -- Bug 3593118
   -- Enterprise Annuity Starts
   --
   l_yrs_of_srvc    NUMBER;
   l_er_rate        NUMBER;
   l_ee_rate        NUMBER;
   l_count_ut       NUMBER;
   l_ut_message     VARCHAR2(3000);
   --
   -- Cursor to fine number of years of service by the meployee.
   --
   -- Changed the cursor as per review comments in the Bug and renamed the
   -- cursor from csr_months_of_service to csr_years_of_service
   --
   CURSOR csr_years_of_service(c_effective_date DATE, c_assignment_id NUMBER)
   IS
     SELECT fnd_number.canonical_to_number(round(months_between(c_effective_date,min(effective_start_date))/12,2)) mths_of_service
     FROM   per_all_assignments_f
     WHERE  assignment_id = c_assignment_id;   --
   -- Cursor to find number of column instances of user table
   --
   CURSOR csr_count_inst(c_table_name  VARCHAR2
                        ,c_col_name    VARCHAR2
                        ,c_effective_date DATE)
   IS
     SELECT count(inst.user_column_instance_id)
     FROM   pay_user_column_instances_f inst
           ,pay_user_columns user_col
           ,pay_user_tables  user_tab
     WHERE  user_tab.user_table_name = c_table_name
     AND    user_tab.legislation_code = 'CN'
     AND    user_tab.user_table_id   = user_col.user_table_id
     AND    user_col.user_column_name = c_col_name
     AND    user_col.legislation_code = 'CN'
     AND    user_col.user_column_id  = inst.user_column_id
     AND    c_effective_date BETWEEN inst.effective_start_date
                             AND     inst.effective_end_date;


     -- Cursor to find the rounding method for the Enterprise Annuity
     -- Bug 4161962
     CURSOR c_annuity_round
     IS
       SELECT org_information1   -- EE Rounding Method
            , org_information2   -- ER Rounding Method
       FROM hr_organization_information
       WHERE org_information_context = 'PER_ORG_ANNUITY_ROUND_CN'
       AND   organization_id         = p_business_group_id;

   --
   -- End Enterprise Annuity
   --


BEGIN

   g_procedure_name := g_package_name||'get_phf_si_rates';
   hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);

   l_message :='SUCCESS';
   --
   -- Bug 3593118
   -- Enterprise Annuity Starts
   --
   IF p_phf_si_type = 'ENTANN'  THEN
      hr_cn_api.set_location(g_debug,' Enerprise Annuity ', 11);
      --
      -- Find Number of Years of Service for the assignment
      --
      IF p_assignment_id IS NULL THEN
         -- If assignmentd_id is null then assume no of years of srvc as 0.
         l_yrs_of_srvc := 0;
      ELSE
         OPEN csr_years_of_service(p_effective_date, p_assignment_id);
         FETCH csr_years_of_service INTO l_yrs_of_srvc;
         CLOSE csr_years_of_service;
      END IF;

      hr_cn_api.set_location(g_debug,' Years of Service '|| l_yrs_of_srvc, 12);

      -- Check if user has eneter values for Employer contribution rates
      OPEN  csr_count_inst('China Enterprise Annuity Contribution Rate','Employer Rate', p_effective_date);
      FETCH  csr_count_inst INTO l_count_ut;
      CLOSE csr_count_inst;

      hr_cn_api.set_location(g_debug,' Employer rate specified in UT, Num of records '|| l_count_ut, 13);

      IF l_count_ut > 0 THEN
         -- Fetch Employer Contribution Rate
         l_er_rate := fnd_number.canonical_to_number(hr_cn_api.get_user_table_value
                             (p_business_group_id => p_business_group_id
                             ,p_table_name        => 'China Enterprise Annuity Contribution Rate'
                             ,p_column_name       => 'Employer Rate'
			                 ,p_row_name          => 'Employer Rate'
                             ,p_row_value         => fnd_number.number_to_canonical(l_yrs_of_srvc)
                             ,p_effective_date    => p_effective_date
			                 ,p_message           => l_ut_message));

         hr_cn_api.set_location(g_debug,' Employer rate  '|| l_er_rate, 14);

	 IF l_ut_message <> 'SUCCESS' THEN
	    -- If user has not specified matching range values, then
	    -- go on to fetch from PHF/SI rates set up at organization level.
            hr_cn_api.set_location(g_debug,' Returned message Not Success', 14);
	    l_er_rate := NULL;
         END IF;
      END IF;

      -- Check if user has eneter values for Employee contribution rates
      OPEN  csr_count_inst('China Enterprise Annuity Contribution Rate', 'Employee Rate', p_effective_date);
      FETCH  csr_count_inst INTO l_count_ut;
      CLOSE csr_count_inst;

      hr_cn_api.set_location(g_debug,' Employee rate specified in UT, Num of records '|| l_count_ut, 15);

      IF l_count_ut > 0 THEN
         -- Fetch Employee Contribution Rate
         l_ee_rate := fnd_number.canonical_to_number(hr_cn_api.get_user_table_value
                             (p_business_group_id => p_business_group_id
                             ,p_table_name        => 'China Enterprise Annuity Contribution Rate'
                             ,p_column_name       => 'Employee Rate'
			                 ,p_row_name          => 'Employee Rate'
                             ,p_row_value         => fnd_number.number_to_canonical(l_yrs_of_srvc)
                             ,p_effective_date    => p_effective_date
			                 ,p_message           => l_ut_message));

	 hr_cn_api.set_location(g_debug,' Employee rate  '|| l_ee_rate, 16);

	 IF l_ut_message <> 'SUCCESS' THEN
	    -- If user has not specified matching range values, then
	    -- go on to fetch from PHF/SI rates set up at organization level.
        hr_cn_api.set_location(g_debug,' Returned message Not Success', 16);
	    l_ee_rate := NULL;
      END IF;

      END IF;

      IF l_er_rate IS NOT NULL AND l_ee_rate IS NOT NULL THEN
         hr_cn_api.set_location(g_debug,' Both Employee and Employer rate Specified at UT', 17);
         p_er_rate := l_er_rate;
         p_ee_rate := l_ee_rate;
         p_er_rate_type := 'PERCENTAGE';
         p_ee_rate_type := 'PERCENTAGE';

	 --  Bug 4161962
         OPEN  c_annuity_round;
               FETCH  c_annuity_round INTO
		              p_ee_rounding_method
                     ,p_er_rounding_method;
		       IF c_annuity_round%NOTFOUND THEN
		              p_ee_rounding_method:=NULL;
                      p_er_rounding_method:=NULL;
	       	   END IF;
         CLOSE c_annuity_round;


         IF g_debug THEN
            hr_utility.trace(' =======================================================');
            hr_utility.trace(' .       EE Rate             : '||p_ee_rate);
            hr_utility.trace(' .       EE Rate Type        : '||p_ee_rate_type);
            hr_utility.trace(' .       EE Rounding Method  : '||p_ee_rounding_method);
            hr_utility.trace(' .       ER Rate             : '||p_er_rate);
            hr_utility.trace(' .       ER Rate Type        : '||p_er_rate_type);
            hr_utility.trace(' .       ER Rounding Method  : '||p_er_rounding_method);
            hr_utility.trace(' =======================================================');
         END IF;

         RETURN l_message;
      END IF;

   END IF;
   --
   -- End Enterprise Annuity
   --



   OPEN c_org1;
   FETCH c_org1 INTO
        p_ee_rate
       ,p_ee_rate_type
       ,p_er_rate
       ,p_er_rate_type
       ,p_ee_rounding_method
       ,p_er_rounding_method
          ,p_ee_thrhld_rate     -- for bug 6828199
       ,p_er_thrhld_rate;    -- for bug 6828199



   IF c_org1%NOTFOUND THEN
   --
      hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 20);
      OPEN c_org2;
      FETCH c_org2 INTO
        p_ee_rate
       ,p_ee_rate_type
       ,p_er_rate
       ,p_er_rate_type
       ,p_ee_rounding_method
       ,p_er_rounding_method
          ,p_ee_thrhld_rate     -- for bug 6828199
       ,p_er_thrhld_rate;    -- for bug 6828199



      IF c_org2%NOTFOUND THEN

         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 30);
         OPEN c_org3;
	     FETCH c_org3 INTO
               p_ee_rate
              ,p_ee_rate_type
              ,p_er_rate
              ,p_er_rate_type
              ,p_ee_rounding_method
              ,p_er_rounding_method
	         ,p_ee_thrhld_rate     -- for bug 6828199
       ,p_er_thrhld_rate;    -- for bug 6828199


         IF c_org3%NOTFOUND THEN

           hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 40);
               OPEN c_org4;
	     FETCH c_org4 INTO
               p_ee_rate
              ,p_ee_rate_type
              ,p_er_rate
              ,p_er_rate_type
              ,p_ee_rounding_method
              ,p_er_rounding_method
	         ,p_ee_thrhld_rate     -- for bug 6828199
       ,p_er_thrhld_rate;    -- for bug 6828199


         IF c_org4%NOTFOUND THEN
	    hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 50);
           l_message := hr_cn_api.get_pay_message('HR_374608_PHF_SI_RATES_MISSING','PHFSI:'||p_phf_si_type);
	       IF g_debug THEN
	           hr_utility.trace(l_message);
	       END IF;
          END IF;
	    CLOSE c_org4;
	  END IF;

          --  CLOSE c_org4; -- Commented as part of bug 3886042
          --
          -- End 3048748
          --

	  -- END IF;  -- Commented as part of bug 3886042

          CLOSE c_org3;

      END IF;

      CLOSE c_org2;

   END IF;
   CLOSE c_org1;

   --
   -- Bug 3593118
   -- Enterprise Annuity Starts
   --
   IF l_er_rate IS NOT NULL THEN
      p_er_rate := l_er_rate;
      p_er_rate_type := 'PERCENTAGE';
   END IF;
   IF l_ee_rate IS NOT NULL THEN
      p_ee_rate := l_ee_rate;
      p_ee_rate_type := 'PERCENTAGE';
   END IF;
   --
   -- End Enterprise Annuity
   --


   IF g_debug THEN
       hr_utility.trace(' =======================================================');
       hr_utility.trace(' .       EE Rate             : '||p_ee_rate);
       hr_utility.trace(' .       EE Rate Type        : '||p_ee_rate_type);
       hr_utility.trace(' .       EE Rounding Method  : '||p_ee_rounding_method);
       hr_utility.trace(' .       ER Rate             : '||p_er_rate);
       hr_utility.trace(' .       ER Rate Type        : '||p_er_rate_type);
       hr_utility.trace(' .       ER Rounding Method  : '||p_er_rounding_method);
       hr_utility.trace(' .       EE Tax Threshold Rate : '||p_ee_thrhld_rate);
       hr_utility.trace(' .       ER Tax Threshold Rate : '||p_er_thrhld_rate);
       hr_utility.trace(' =======================================================');
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 70);
   RETURN l_message;

EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);

      IF c_org4%ISOPEN THEN
         CLOSE c_org4;
      END IF;

      --
      -- Bug 3886042 Changes End
      --
      IF c_org3%ISOPEN THEN
         CLOSE c_org3;
      END IF;
      IF c_org2%ISOPEN THEN
         CLOSE c_org2;
      END IF;
      IF c_org1%ISOPEN THEN
         CLOSE c_org1;
      END IF;
      RETURN l_message;

END get_phf_si_rates;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CONT_BASE_AMOUNTS                               --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return the contribute base amounts      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_cont_base_method            VARCHAR2              --
--                  p_phf_si_earnings_asg_ptd     NUMBER                --
--                  p_phf_si_earnings_asg_pmth    NUMBER                --
--                  p_phf_si_earnings_asg_avg     NUMBER                --
--                  p_average_salary              NUMBER                --
--                  p_lowest_average_salary       NUMBER                --
--                  p_fixed_amount                NUMBER                --
--            OUT : p_cont_base_amount            NUMBER                --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAY-03  statkar  Created this function                      --
-- 1.1   26-Jun-03  statkar  3017511-Changed SELECT to IF..THEN..ELSE   --
-- 1.2   03-Jul-03  saikrish Added set location and trace calls         --
-- 1.3   07-Jul-03  statkar  Bug 3038490. Changed spelling              --
-- 1.4   14-Mar-08  dduvvuri Bug 6828199 - Added new cont base method of
--                           'PROV AVE 60'
--------------------------------------------------------------------------
FUNCTION get_cont_base_amount
              (p_cont_base_method            IN  VARCHAR2
              ,p_phf_si_earnings_asg_ptd     IN  NUMBER
              ,p_phf_si_earnings_asg_pmth    IN  NUMBER
              ,p_phf_si_earnings_asg_avg     IN  NUMBER
	          ,p_average_salary              IN  NUMBER
	          ,p_lowest_average_salary       IN  NUMBER
	          ,p_fixed_amount                IN  NUMBER
              ,p_cont_base_amount           OUT  NOCOPY NUMBER)
RETURN VARCHAR2
IS
   l_cont_base_amount   NUMBER;
   l_message            VARCHAR2(255);

BEGIN
   g_procedure_name := g_package_name||'get_cont_base_amount';
   hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);

   l_message := '';

   IF p_cont_base_method = 'AVE MTH' THEN
--
-- Bug 3017511 Changed the SELECT DECODE.. to IF..THEN..ELSE conditions
--
      IF p_phf_si_earnings_asg_avg = 0 THEN
	     IF p_phf_si_earnings_asg_pmth = 0 THEN
  		    hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 20);
		    l_cont_base_amount := p_phf_si_earnings_asg_ptd;
         ELSE
  		    hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 30);
		    l_cont_base_amount := p_phf_si_earnings_asg_pmth;
         END IF;
      ELSE
            hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 40);
	        l_cont_base_amount := p_phf_si_earnings_asg_avg;
      END IF;

   ELSIF p_cont_base_method  = 'CURRENT' THEN
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 50);
         l_cont_base_amount:= p_phf_si_earnings_asg_ptd;
--
-- Bug 3038490. Changed the mis-spelt EMP PRIOR SWITCH
--
   ELSIF p_cont_base_method in ('PREVIOUS','EMP PRIOR SWITCH') THEN
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 60);
--
-- Bug 3017511 Changed the SELECT DECODE.. to IF..THEN..ELSE conditions
--
      IF p_phf_si_earnings_asg_pmth = 0 THEN
		 hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 70);
		 l_cont_base_amount := p_phf_si_earnings_asg_ptd;
      ELSE
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 80);
		 l_cont_base_amount := p_phf_si_earnings_asg_pmth;
       END IF;

   ELSIF p_cont_base_method in ( 'CITY AVE 60', 'PROV AVE 60' ) THEN /* modified for 6828199 */
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 90);
        l_cont_base_amount:= 0.6*p_average_salary;

   ELSIF p_cont_base_method = 'CITY LOW LAST YR' THEN
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 100);

        l_cont_base_amount:= p_lowest_average_salary;

   ELSIF p_cont_base_method = 'FIXED' THEN
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 110);

        l_cont_base_amount:= p_fixed_amount;

   ELSIF p_cont_base_method = 'N/A' THEN
        hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 120);

        l_cont_base_amount:= 0;

   END IF;

   p_cont_base_amount := l_cont_base_amount;

   IF g_debug THEN
     hr_utility.trace(' ==============================================');
     hr_utility.trace(' .      Cont Base Method : '||p_cont_base_method);
     hr_utility.trace(' . PHF_SI_EARNINGS (PTD) : '||p_phf_si_earnings_asg_ptd);
     hr_utility.trace(' . PHF_SI_EARNINGS (PMTH): '||p_phf_si_earnings_asg_pmth);
     hr_utility.trace(' . PHF_SI_EARNINGS (AVG) : '||p_phf_si_earnings_asg_avg);
     hr_utility.trace(' .        Average Salary : '||p_average_salary);
     hr_utility.trace(' .     Lowest Avg Salary : '||p_lowest_average_salary);
     hr_utility.trace(' .          Fixed Amount : '||p_fixed_amount);
     hr_utility.trace(' .      Cont Base Amount : '||p_cont_base_amount);
     hr_utility.trace(' ==============================================');
   END IF;

     l_message:='SUCCESS';
     hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 130);
     RETURN l_message;

EXCEPTION
   WHEN OTHERS THEN
      p_cont_base_amount := hr_api.g_number;
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);
      RETURN l_message;
END get_cont_base_amount;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RECALCULATE_FLAG                                --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Procedure to set the recalculation flag             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_switch_periodicity     VARCHAR2                   --
--                  p_switch_month           VARCHAR2                   --
--                  p_calculation_date       DATE                       --
--	                p_process_date           DATE                       --
--            OUT : N/A
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAY-03  statkar  Created this function                      --
-- 1.1   20-Jun-03  statkar  Changes for Bug 3017511                    --
-- 1.2   03-Jul-03  saikrish Added set location and trace calls         --
-- 1.3   04-Jul-03  statkar  Bug 3039614 Changed the logic              --
-- 1.4   15-SEP-03  statkar  Bug 3127638. Changed the logic to handle   --
--                           p_switch_month in 'MM' format instead of   --
--                           'MON' format                               --
-- 1.5   06-APR-04  snekkala Added if condition for recalculate flag    --
-- 1.6   06-Apr-04  statkar  Bug 3555258  Modified trace calls          --
-- 1.7   02-Apr-09  dduvvuri 8328944 Modified Logic for YEARLY periodicity
--                           and removed unnecessary code               --
-- 1.8   02-Nov-09  dduvvuri 8838185 - Removed unnecessary code for MONTHLY --
--                           periodicity and return 'Y' always
--------------------------------------------------------------------------
FUNCTION get_recalculate_flag (p_switch_periodicity     IN VARCHAR2
                              ,p_switch_month           IN VARCHAR2
                              ,p_calculation_date       IN DATE
                              ,p_process_date           IN DATE )
RETURN VARCHAR2
IS
   l_temp_date     DATE;
   l_return_value  VARCHAR2(1);
   l_message                VARCHAR2(255);
BEGIN

   g_procedure_name := g_package_name||'get_recalculate_flag';
   hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);
   l_return_value := 'N';
--
-- Bug 3039614: Calculation Date can either be g_start_date or
-- the last recalculation date as updated by update_element_entry
-- We do not need to check if its either of the two since for
-- g_start_date, adding a year or a month is going to be less than
-- process date for all practical purposes.
--

  IF p_switch_periodicity = 'YEARLY' THEN
  --
     hr_cn_api.set_location(g_debug, g_procedure_name, 30);
--
-- Bug 3127638
-- Changed to incorporate the new lookup of CN_CALENDAR_MONTH being 'MM' in place of 'MON'
     /* 8328944 - Used Process Date instead of calculation date */
     l_temp_date := TO_DATE('01-'||p_switch_month||'-'||TO_CHAR(p_process_date,'YYYY'),'DD-MM-YYYY');

     IF TO_CHAR(l_temp_date,'MM') = TO_CHAR(p_process_date,'MM') THEN
         l_return_value := 'Y';
     ELSE
         l_return_value := 'N';
     END IF;

  --
  ELSIF p_switch_periodicity = 'MONTHLY' THEN
     hr_cn_api.set_location (g_debug, g_procedure_name, 40);
     /* 8838185 - Remove unnecessary code and always return Y always */
        l_return_value := 'Y';
  END IF;

  IF g_debug THEN
     hr_utility.trace(' ==============================================');
     hr_utility.trace(' .     Switch Periodicity : '||p_switch_periodicity);
     hr_utility.trace(' .     Switch Month       : '||p_switch_month);
     hr_utility.trace(' .     Calculation Date   : '||TO_CHAR(p_calculation_date,'DD-MM-YYYY'));
     hr_utility.trace(' .     Process Date       : '||TO_CHAR(p_process_date, 'DD-MM-YYYY'));
     hr_utility.trace(' .     Temporary Date     : '||TO_CHAR(l_temp_date,'DD-MM-YYYY'));
     hr_utility.trace(' .     Recalculate Flag   : '||l_return_value);
     hr_utility.trace(' ==============================================');
  END IF;
--
  hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 50);
  RETURN l_return_value;
--
EXCEPTION
   WHEN OTHERS THEN
     l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
     hr_utility.trace (l_message);
     RETURN 'E';
END get_recalculate_flag;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_IN_LIMIT                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to set the cont bases in limit            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_high_limit_method   VARCHAR2                      --
--                : p_low_limit_method    VARCHAR2                      --
--                  p_high_fixed_amount   NUMBER                        --
--                  p_low_fixed_amount    NUMBER                        --
--                  p_rounding_method     VARCHAR2                      --
--                  p_average_salary      NUMBER                        --
--                  p_lowest_avg_salary   NUMBER                        --
--                  p_amount              NUMBER                        --
--            OUT : p_message             VARCHAR2                      --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAR-04  statkar  Created this function                     --
-- 1.1   14-Mar-08  dduvvuri 6828199 - Modifications due to changes in
--                           cont base low limit , cont base high limit ,
--                           ee/er cont base . Removed parameters p_phf_si_type
--                           and p_phf_high_lim_exemp as they are not required
--------------------------------------------------------------------------
PROCEDURE  get_in_limit
          (p_high_limit_method     IN VARCHAR2
	      ,p_low_limit_method      IN VARCHAR2
	      ,p_high_fixed_amount     IN NUMBER
	      ,p_low_fixed_amount      IN NUMBER
	      ,p_rounding_method       IN VARCHAR2
	      ,p_average_salary        IN NUMBER
	      ,p_lowest_avg_salary     IN NUMBER
	      ,p_amount                IN OUT NOCOPY NUMBER
	      ,p_message               OUT NOCOPY VARCHAR2
	      )
IS

    l_low_limit_amount    NUMBER;
    l_high_limit_amount   NUMBER;
    l_amount              NUMBER;

BEGIN

   g_procedure_name := g_package_name||'get_in_limit';
   p_message := 'SUCCESS';

   hr_cn_api.set_location(g_debug,' Entering : '||g_procedure_name, 10);

--
-- Step 1: Fix the low limit amount
--
  -- Valid Low Limit Methods are
  --
  -- MTH AVE PREV YEAR 60% of city's monthly average salary from last year
  -- PROV AVE PREV YEAR 60% of provincial monthly average salary from last year
  -- FIXED             Fixed Amount
  -- CITY LOW AVE      The city's lowest MONTHLY average salary for last year
  -- N/A               Not Applicable
  --

     IF p_low_limit_method in ( 'MTH AVE PREV YEAR','PROV AVE PREV YEAR' ) THEN -- bug 6828199
	    l_low_limit_amount := 0.6* p_average_salary;

     ELSIF p_low_limit_method = 'FIXED' THEN
	    l_low_limit_amount := p_low_fixed_amount ;

     ELSIF p_low_limit_method  = 'CITY LOW AVE' THEN
	    l_low_limit_amount := p_lowest_avg_salary;

     ELSIF p_low_limit_method = 'N/A' THEN
	    l_low_limit_amount := p_amount;

     END IF;


--
-- Step 2: Fix the high limit amount
--
  -- Valid High Limit Methods are
  --
  -- MTH AVE PREV YEAR Three times the city's monthly average salary from last year
  -- PROV AVE PREV YEAR Three times the provincial monthly average salary from last year
  -- CTY AVE PREV YEAR Five times the city's monthly average salary from last year
  -- FIXED             Fixed Amount
  -- N/A               Not Applicable
  --

        IF p_high_limit_method in ( 'MTH AVE PREV YEAR' , 'PROV AVE PREV YEAR' ) THEN -- bug 6828199
               l_high_limit_amount := 3 * p_average_salary;

        ELSIF p_high_limit_method = 'FIXED' THEN
               l_high_limit_amount :=  p_high_fixed_amount ;

	ELSIF p_high_limit_method = 'CTY AVE PREV YEAR' THEN  -- added for bug 6828199
	       l_high_limit_amount := 5 * p_average_salary ;

        ELSIF p_high_limit_method = 'N/A' THEN
               l_high_limit_amount := p_amount;
        END IF;

-------------------------------------------------------------------------
--
-- Step 3: Fix the amounts in the limit
--

    IF p_amount BETWEEN l_low_limit_amount and l_high_limit_amount THEN

       l_amount := p_amount;

    ELSIF p_amount > l_high_limit_amount THEN

       l_amount := l_high_limit_amount;

    ELSIF p_amount < l_low_limit_amount THEN

       l_amount := l_low_limit_amount;

    END IF;


  p_amount := get_rounded_value(l_amount,p_rounding_method);

   IF g_debug THEN
     hr_utility.trace(' ==============================================');
     hr_utility.trace(' . Low Limit Method     : '||p_low_limit_method);
     hr_utility.trace(' . Low Limit Amount     : '||l_low_limit_amount);
     hr_utility.trace(' . High Limit Method    : '||p_high_limit_method);
     hr_utility.trace(' . High Limit Amount    : '||l_high_limit_amount);
     hr_utility.trace(' . Amount In Limit is   : '||l_amount);
     hr_utility.trace(' . Rounding Method      : '||p_rounding_method);
     hr_utility.trace(' . Rounded Amount       : '||p_amount);
     hr_utility.trace(' ==============================================');
   END IF;
   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 20);

EXCEPTION
   WHEN OTHERS THEN
     p_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
     hr_utility.trace (p_message);

END get_in_limit;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : UPDATE_ELEMENT_ENTRY                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Procedure to update element entry with Calc Date    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id           NUMBER                --
--                  p_element_entry_id            NUMBER                --
--                  p_pay_proc_period_end_date    DATE                  --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04-Jul-03  statkar  Created this function                      --
-- 1.1   07-Jul-03  statkar  Added the CORRECTION mode to handle Re-try --
-- 1.2   14-Jul-03  statkar  Bug 3050951. Added check for termination   --
-- 1.3   16-Jul-03  statkar  Bug 3053186. Added check for end-date      --
-- 1.4   21-Jul-03  statkar  Bug 3057542. Added check for future rows   --
-- 1.5   31-Jul-03  statkar  Bug 3057542  Modified exception handling   --
-- 1.6   15-SEP-03  statkar  Bug 3127638  Modified p_pay_proc_period_end_date
-- 1.7   25-FEB-04  snekkala Bug 3456162  Modified the cursor c_asg_status--
--------------------------------------------------------------------------
FUNCTION update_element_entry
                 (p_business_group_id            IN NUMBER
		         ,p_element_entry_id             IN NUMBER
		         ,p_calculation_date             IN DATE
	         )
RETURN VARCHAR2
IS
--
    CURSOR c_ovn (p_calculation_date IN DATE) IS
    SELECT object_version_number
	FROM   pay_element_entries_f
	WHERE  element_entry_id = p_element_entry_id
	AND    p_calculation_date   BETWEEN effective_start_date
	                            AND     effective_end_date;
--
   l_ovn    pay_element_entries_f.object_version_number%TYPE;
--
   l_effective_start_date   DATE;
   l_effective_end_date     DATE;
   l_warning                BOOLEAN;
--
  CURSOR c_iv IS
      SELECT piv.input_value_id
      FROM   pay_element_entries_f pee,
             pay_element_links_f   pel,
	         pay_input_values_f    piv
      WHERE  pee.element_entry_id  = p_element_entry_id
      AND    pee.element_link_id   = pel.element_link_id
      AND    pel.element_type_id   = piv.element_type_id
      AND    piv.name              = 'Calculation Date'
      AND    p_calculation_date BETWEEN pee.effective_start_date AND pee.effective_end_date
      AND    p_calculation_date BETWEEN pel.effective_start_date AND pel.effective_end_date
      AND    p_calculation_date BETWEEN piv.effective_start_date AND piv.effective_end_date;
--
   l_iv_id   pay_input_values_f.input_value_id%TYPE;
--
-- Bug 3057542 changes for checking future row
--
   CURSOR c_exists (p_input_value_id IN NUMBER) IS
      SELECT effective_start_date
      FROM   pay_element_entry_values_f
      WHERE  element_entry_id = p_element_entry_id
      AND    input_value_id = p_input_value_id
      AND    effective_start_date >= p_calculation_date + 1
      ORDER  by effective_start_date;
--
   l_eff_start_date   pay_element_entry_values_f.effective_start_date%TYPE;

   l_dummy     VARCHAR2(10);
   l_upd_mode  VARCHAR2(30);
--
-- Bug 3050951: Added the c_asg_status cursor
--

--
--Bug 3456162: Changed the cursor to parameterised cursor
--

   CURSOR c_asg_status (l_effective_date IN DATE) IS
       SELECT  past.per_system_status
       FROM    pay_element_entries_f pee,
               per_assignments_f paf,
               per_assignment_status_types past
       WHERE   pee.element_entry_id          = p_element_entry_id
       AND     pee.assignment_id             = paf.assignment_id
       AND     paf.assignment_status_type_id = past.assignment_status_type_id
       AND     l_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date    --Bug 3456162
       AND     l_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date;   --Bug 3456162
--
--Bug 3456162: Changes end.
--
--
   l_asg_status   per_assignment_status_types.per_system_status%TYPE;
--
-- Bug 3050951: Changes end.
--

--
-- Bug 3053186: Added the c_ee_end cursor
--
    CURSOR c_ee_end IS
      SELECT 'exists'
      FROM   pay_element_entries_f
      WHERE  element_entry_id             = p_element_entry_id
      AND    LAST_DAY(effective_end_date) = p_calculation_date;
--
   l_message   VARCHAR2(1000);
   l_days NUMBER;
--
BEGIN
    g_procedure_name :=    g_package_name||'update_element_entry';
    l_message := 'SUCCESS';

    hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);
--
-- Bug 3050951: Added the following check for active assignments
--

--
--Bug 3456162 changes the open cursor
--
    OPEN c_asg_status (p_calculation_date);
    FETCH c_asg_status
    INTO  l_asg_status;
    CLOSE c_asg_status;
--
--Bug 3456162 Changes end
--
--
    IF l_asg_status = 'TERM_ASSIGN' THEN
    --
	hr_cn_api.set_location (g_debug,'Employee is terminated. Not calling pay_element_entry_api.',15);
        hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name,15);
        RETURN l_message;
    --
    END IF;
--
-- Bug 3050951 Changes end
--
    OPEN c_iv;
    FETCH c_iv
    INTO  l_iv_id;

--
-- Bug 3053186 Changes Start for checking the effective_end_date
--
    IF c_iv%NOTFOUND THEN
    --
       OPEN c_ee_end;
       FETCH c_ee_end
       INTO l_dummy;
    --
       IF c_ee_end%FOUND THEN
       --
          CLOSE c_ee_end;
          hr_cn_api.set_location(g_debug,' Element Entry is end-dated this month. Not calling pay_element_entry_api.',18);
          hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name,18);
          RETURN l_message;
       --
       ELSE
       --
          CLOSE c_ee_end;
          hr_cn_api.set_location(g_debug,' Element Entry is active this month. Can call pay_element_entry_api.',19);
          hr_cn_api.set_location(g_debug,' ' || g_procedure_name,19);
       --
       END IF;
    --
    END IF;
--
-- Bug 3053186 Changes end
--
    CLOSE c_iv;
--
    hr_cn_api.set_location(g_debug,' ' || g_procedure_name,20);
    hr_cn_api.set_location(g_debug,'         Input Value ID : '||to_char(l_iv_id),25);
--
    OPEN c_exists (l_iv_id);
    FETCH c_exists
    INTO  l_eff_start_date;
--
    IF c_exists%NOTFOUND THEN
--
        hr_cn_api.set_location (g_debug, g_procedure_name, 32);
--
-- Bug 3456162 added the code
--
        OPEN c_asg_status (p_calculation_date + 1);
        FETCH c_asg_status
        INTO  l_asg_status;

	IF c_asg_status%NOTFOUND THEN
    --
           hr_cn_api.set_location(g_debug,' Employee is terminated on last day. Not calling pay_element_entry_api.',33);
           hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name,33);
           RETURN l_message;
    --
        END IF;
        CLOSE c_asg_status;
--
--Bug 3456162 changes end
--
        OPEN c_ovn (p_calculation_date);
        FETCH c_ovn
        INTO  l_ovn;
        CLOSE c_ovn;
--
        l_upd_mode := 'UPDATE';
--
    ELSE
--
-- Bug 3057542 changes
--
       hr_cn_api.set_location (g_debug, g_procedure_name, 34);

       IF (l_eff_start_date = p_calculation_date + 1) THEN

           OPEN c_ovn (p_calculation_date+1);
           FETCH c_ovn
           INTO  l_ovn;
           CLOSE c_ovn;
--
           l_upd_mode := 'CORRECTION';
--
       ELSE

           hr_cn_api.set_location (g_debug, g_procedure_name, 36);

	   OPEN c_ovn (p_calculation_date);
	   FETCH c_ovn
	   INTO  l_ovn;
	   CLOSE c_ovn;

--
           l_upd_mode := 'UPDATE_CHANGE_INSERT';
--
       END IF;
--
-- Bug 3057542 changes end
--
    END IF;
    CLOSE c_exists;
--
    hr_cn_api.set_location(g_debug,' ' || g_procedure_name,40);
    IF g_debug THEN
      hr_utility.trace(' ==============================================');
      hr_utility.trace ('.    Calling pay_element_entry_api.');
      hr_utility.trace ('.       Element Entry   : '||TO_CHAR(p_element_entry_id));
      hr_utility.trace ('.       Effective Date  : '||TO_CHAR(p_calculation_date+1,'DD-MM-YYYY'));
      hr_utility.trace ('.       Input Value Id  : '||TO_CHAR(l_iv_id));
      hr_utility.trace ('.       Entry Value     : '||TO_CHAR(p_calculation_date,'DD-MM-YYYY'));
      hr_utility.trace ('.       OVN             : '||to_char(l_ovn));
      hr_utility.trace ('.       Date-track Mode : '||l_upd_mode);
      hr_utility.trace(' ==============================================');
    END IF;

    BEGIN
       pay_element_entry_api.update_element_entry
         (p_datetrack_update_mode         => l_upd_mode
         ,p_effective_date                => p_calculation_date + 1
         ,p_business_group_id             => p_business_group_id
         ,p_element_entry_id              => p_element_entry_id
         ,p_object_version_number         => l_ovn
         ,p_input_value_id1               => l_iv_id
         ,p_entry_value1                  => fnd_date.date_to_chardate(p_calculation_date)      -- Bug 3127638
         ,p_effective_start_date          => l_effective_start_date
         ,p_effective_end_date            => l_effective_end_date
         ,p_update_warning                => l_warning
         );

    EXCEPTION
      WHEN OTHERS THEN
      --
        hr_cn_api.set_location(g_debug,' .        Error in pay_element_entry_api.',5);
        hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name,5);
	l_message := SUBSTRB(SQLERRM,1,240);
        RETURN l_message;
      --
     END;
--
    hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name,50);
    RETURN l_message;
--
EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      RETURN l_message;

END update_element_entry;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CONT_AMOUNT                                     --
-- Type           : Function                                            --
-- Access         : Private                                             --
-- Description    : Function to calculate the contribution amounts      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_high_limit                  NUMBER                --
--                  p_low_limit                   NUMBER                --
--                  p_amount                      NUMBER                --
--                  p_rounding_method             VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAR-04  statkar  Created this function                      --
-- 1.1   05-APR-05  rpalli   Bug 4161962. Added Code to round amounts   --
--                           to 2 decimal places for null rounding	--
--			     method passed.				--
--------------------------------------------------------------------------
FUNCTION get_cont_amount
          (p_cont_base          IN NUMBER
	      ,p_rate_type          IN VARCHAR2
	      ,p_rate_amount        IN NUMBER
	      ,p_rounding_method    IN VARCHAR2
	      ,p_message            OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
   l_amount   NUMBER;
BEGIN
   g_procedure_name := g_package_name||'get_cont_amount';
   hr_cn_api.set_location(g_debug,' Entering : '||g_procedure_name, 10);

   p_message := 'SUCCESS';
   IF g_debug THEN
     hr_utility.trace(' ==============================================');
     hr_utility.trace(' . Rate Type            : '||p_rate_type);
     hr_utility.trace(' . Rate                 : '||p_rate_amount);
     hr_utility.trace(' . Contribution Base    : '||p_cont_base);
   END IF;
   IF p_rate_type = 'FIXED' THEN
        l_amount := p_rate_amount;

   ELSIF p_rate_type = 'PERCENTAGE' THEN
        l_amount := p_cont_base * p_rate_amount/100;

   END IF;

   IF g_debug THEN
     hr_utility.trace(' . Contribution Amount  : '||l_amount);
     hr_utility.trace(' . Rounding Method      : '||p_rounding_method);
   END IF;

   l_amount := get_rounded_value(l_amount, p_rounding_method);

   IF g_debug THEN
     hr_utility.trace(' . Rounded Amount       : '||l_amount);
     hr_utility.trace(' ==============================================');
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 40);
   RETURN l_amount;

EXCEPTION
   WHEN OTHERS THEN
      p_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      RETURN hr_api.g_number;

END get_cont_amount;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_DEFERRED_AMOUNTS                         --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Procedure to calculate the deffered phf/si amounts  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pay_proc_period_end_date    DATE                  --
--                  p_actual_probation_end_date   DATE                  --
--                  p_const_probation_end_date    DATE                  --
--                  p_defer_deductions            VARCHAR2              --
--                  p_deduct_in_probation_expiry  VARCHAR2              --
--                  p_taxable_earnings_asg_er_ptd NUMBER                --
--         IN/OUT : p_ee_phf_si_amount            NUMBER                --
--                  p_er_phf_si_amount            NUMBER                --
--                  p_undeducted_ee_phf_ltd       NUMBER                --
--                  p_undeducted_er_phf_ltd       NUMBER                --
--         RETURN : VARCHAR2                                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   12-MAY-03  statkar  Created this function                      --
-- 1.1   20-Jun-03  statkar  Bug 3017511 changes to logic               --
-- 1.2   03-Jul-03  saikrish Added set location and trace calls         --
-- 1.3   09-Jul-03  saikrish Changed code w.r.t to bug 3042788          --
-- 1.4   10-Jul-03  saikrish Remove off TRUNC(TO_DATE()) for the        --
--                           probation end date parameter.              --
--------------------------------------------------------------------------
FUNCTION get_phf_si_deferred_amounts
           (p_pay_proc_period_end_date     IN DATE
	       ,p_actual_probation_end_date    IN DATE
	       ,p_const_probation_end_date     IN DATE
	       ,p_defer_deductions             IN VARCHAR2
	       ,p_deduct_in_probation_expiry   IN VARCHAR2
	       ,p_taxable_earnings_asg_er_ptd  IN  NUMBER
--
	       ,p_ee_phf_si_amount             IN OUT NOCOPY NUMBER
	       ,p_er_phf_si_amount             IN OUT NOCOPY NUMBER
           ,p_undeducted_ee_phf_ltd        IN OUT NOCOPY NUMBER
           ,p_undeducted_er_phf_ltd        IN OUT NOCOPY NUMBER
	       )
RETURN VARCHAR2

IS
   l_defer_date         DATE;
   l_default_date       DATE;
   l_probation_end_date DATE;
   l_message            VARCHAR2(80);
   l_probation_flag     VARCHAR2(1);
   l_temp               NUMBER;
BEGIN
   g_procedure_name := g_package_name||'get_phf_si_deferred_amounts';
   hr_cn_api.set_location(g_debug,' Entering: '||g_procedure_name, 10);

   l_message := 'SUCCESS';
   l_default_date := TO_DATE ('01-01-0001','DD-MM-YYYY');

   IF g_debug THEN
    hr_utility.trace ('==============================================');
    hr_utility.trace ('       Actual Probn End Date : '||p_actual_probation_end_date);
    hr_utility.trace ('       Cont. Probn End Date  : '||p_const_probation_end_date);
    hr_utility.trace ('       Defer Deductions      : '||p_defer_deductions);
    hr_utility.trace ('  Deduct in Probation Expiry : '||p_deduct_in_probation_expiry);
    hr_utility.trace ('       Taxable Earnings      : '||p_taxable_earnings_asg_er_ptd);

    hr_utility.trace ('  Old EE PHF/SI amount       : '||p_ee_phf_si_amount);
    hr_utility.trace ('  Old ER PHF/SI amount       : '||p_er_phf_si_amount);
    hr_utility.trace ('  Old Undeducted EE PHF LTD  : '||p_undeducted_ee_phf_ltd);
    hr_utility.trace ('  Old Undeducted ER PHF LTD  : '||p_undeducted_er_phf_ltd);
    hr_utility.trace ('  p_pay_proc_period_end_date : '||TO_CHAR(p_pay_proc_period_end_date,'DD-MM-YYYY'));
    hr_utility.trace ('==============================================');
  END IF;


   --3042788 Code is modified to consider the defaulting of Actual,Const Probation end dates
   -- in the PHF/SI fast formulae.
   IF p_actual_probation_end_date = pay_cn_deductions.g_start_date THEN
      l_probation_end_date := p_const_probation_end_date;
   ELSE
      l_probation_end_date := p_actual_probation_end_date;
   END IF;

   hr_cn_api.set_location (g_debug,'Probation End Date  :  '||l_probation_end_date,15);

   IF l_probation_end_date = pay_cn_deductions.g_start_date THEN
      hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 20);
      l_probation_flag := 'N';
   END IF;

   hr_cn_api.set_location (g_debug,'Probation Flag After being Set :  '||l_probation_flag,25);
   --3042788
--
-- Bug 3017511 changes. Logic Changed since deduct in probation expiry was not
--    being considered at all
--
   IF p_defer_deductions = 'N' OR
     (    p_defer_deductions ='Y'
      AND
      (
          ( p_deduct_in_probation_expiry= 'Y' AND l_probation_end_date <= p_pay_proc_period_end_date ) OR
          ( p_deduct_in_probation_expiry= 'N' AND add_months(l_probation_end_date,1) <= p_pay_proc_period_end_date ) OR
	  l_probation_flag = 'N'
      )
     )
   THEN

      IF p_undeducted_ee_phf_ltd >0 THEN
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 30);
	 p_ee_phf_si_amount := p_ee_phf_si_amount + p_undeducted_ee_phf_ltd;
         p_undeducted_ee_phf_ltd := 0 - p_undeducted_ee_phf_ltd;

      END IF;

      IF p_undeducted_er_phf_ltd >0 THEN
         hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 40);
	     p_er_phf_si_amount := p_er_phf_si_amount + p_undeducted_er_phf_ltd;
         p_undeducted_er_phf_ltd := 0 - p_undeducted_er_phf_ltd;
      END IF;

   ELSE
--
-- Bug 3017511 changes. Logic Changed since in case of deferment, undeducted phf
-- was getting incorrectly fed.
--
      hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 50);
      p_undeducted_ee_phf_ltd := p_ee_phf_si_amount;
      p_ee_phf_si_amount := 0;

      p_undeducted_er_phf_ltd := p_er_phf_si_amount;
      p_er_phf_si_amount := 0;

   END IF;

   IF g_debug THEN
    hr_utility.trace(' ==============================================');
    hr_utility.trace('   New EE PHF/SI amount       : '||p_ee_phf_si_amount);
    hr_utility.trace('   New ER PHF/SI amount       : '||p_er_phf_si_amount);
    hr_utility.trace('   New Undeducted EE PHF LTD  : '||p_undeducted_ee_phf_ltd);
    hr_utility.trace('   New Undeducted ER PHF LTD  : '||p_undeducted_er_phf_ltd);
    hr_utility.trace(' ==============================================');
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 60);
   RETURN l_message;

EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      RETURN l_message;
END get_phf_si_deferred_amounts;

----------------------------------------------------------------------------
--                                                                        --
-- Name 	: GET_DEF_BAL_ID                                          --
-- Type 	: Function                                                --
-- Access 	: Private                                                 --
-- Description 	: Function to get the defined balance for balance         --
--                                                                        --
-- Parameters   :                                                         --
--           IN : p_phf_si_type                TYPE                       --
--                p_assignment_action_id       TYPE                       --
--       RETURN : NUMBER                                                  --
--                                                                        --
-- Change History :                                                       --
----------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                                 --
----------------------------------------------------------------------------
-- 1.0   16-MAR-04  snekkala  Created this function                       --
----------------------------------------------------------------------------
FUNCTION  get_def_bal_id
           (p_balance_name   IN pay_balance_types.balance_name%TYPE
           ,p_dimension_name IN pay_balance_dimensions.dimension_name%TYPE)
RETURN NUMBER
IS

    CURSOR csr_def_bal_id
    IS
      SELECT pdb.defined_balance_id
       FROM   pay_defined_balances pdb
             ,pay_balance_types pbt
             ,pay_balance_dimensions pbd
       WHERE  pbt.balance_name =    p_balance_name
       AND    pbd.dimension_name =  p_dimension_name
       AND    pdb.balance_type_id = pbt.balance_type_id
       AND    pbt.legislation_code = 'CN'
       AND    pbd.legislation_code = 'CN'
       AND    pdb.legislation_code = 'CN'
       AND    pdb.balance_dimension_id = pbd.balance_dimension_id;

    l_def_bal_id     pay_defined_balances.defined_balance_id%TYPE;
    l_message   VARCHAR2(80);

BEGIN
   l_message := 'SUCCESS';

   OPEN  csr_def_bal_id;
   FETCH csr_def_bal_id
   INTO  l_def_bal_id;
   CLOSE csr_def_bal_id;

   IF g_debug THEN
     hr_utility.trace ('.   '||RPAD(TRIM(p_balance_name||p_dimension_name),35,' ')||' : '||l_def_bal_id);
   END IF;

   RETURN l_def_bal_id;

EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);

END get_def_bal_id ;

----------------------------------------------------------------------------
--                                                                        --
-- Name 	: GET_PHF_SI_BALANCES                                         --
-- Type 	: Function                                                    --
-- Access 	: Private                                                     --
-- Description 	: Function to get the balances of elements                --
--                                                                        --
-- Parameters   :                                                         --
--           IN : p_phf_si_type                VARCHAR2                   --
--                p_assignment_action_id       NUMBER                     --
--                p_tax_unit_id                NUMBER                     --
--                p_date_earned                DATE                       --
--          OUT : p_balance_value_tab          T_BALANCE_VALUE_TAB        --
--                                                                        --
-- Change History :                                                       --
----------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                                 --
----------------------------------------------------------------------------
-- 1.0   16-MAR-04  snekkala   Created this function                      --
-- 1.1   05-JUL-04  sshankar   Added Enterprise Annuity to cursor         --
--                             c_element_name                             --
----------------------------------------------------------------------------
PROCEDURE get_phf_si_balances
           (p_phf_si_type               IN VARCHAR2
           ,p_assignment_action_id      IN NUMBER
	       ,p_tax_unit_id               IN NUMBER
	       ,p_date_earned               IN DATE
           ,p_balance_value_tab         OUT NOCOPY pay_balance_pkg.t_balance_value_tab
           )
IS

    CURSOR c_element_name is
          SELECT decode(p_phf_si_type
                         ,'PHF','PHF'
                         ,'MEDICAL','Medical'
                         ,'PENSION','Pension'
                         ,'SUPPMED','Supp Medical'
                         ,'MATERNITY','Maternity'
                         ,'UNEMPLOYMENT','Unemployment'
                         ,'INJURY','Injury'
                         ,'ENTANN','Enterprise Annuity'
                         )
                 ,decode(p_phf_si_type
                         ,'PHF','PHF'
                         ,'MEDICAL','Medical'
                         ,'PENSION','Pension'
                         ,'SUPPMED','Supplementary Medical'
                         ,'MATERNITY','Maternity Insurance'
                         ,'UNEMPLOYMENT','Unemploy Insurance'
                         ,'INJURY','Injury Insurance'
                         ,'ENTANN','Enterprise Annuity'
                         )
             FROM dual;

    l_element_name    VARCHAR2(50);
    l_insurance_type  VARCHAR2(50);
    l_message         VARCHAR2(80);
BEGIN
   g_procedure_name  := g_package_name||'get_phf_si_balances';

   hr_cn_api.set_location(g_debug,' Entering : '||g_procedure_name, 10);

   l_message := 'SUCCESS';

   --
   -- Fetch the element specific names
   --
   OPEN c_element_name;
   FETCH c_element_name INTO l_element_name,l_insurance_type;
   CLOSE c_element_name;

   IF g_debug THEN
     hr_utility.trace ('===================== Defined Balances =========================');
   END IF;

   p_balance_value_tab(1).defined_balance_id := get_def_bal_id('PHF SI Earnings','_ASG_PTD');
   p_balance_value_tab(2).defined_balance_id := get_def_bal_id('PHF SI Earnings','_ASG_PYEAR');
   p_balance_value_tab(3).defined_balance_id := get_def_bal_id('PHF SI Earnings','_ASG_PMTH');
   p_balance_value_tab(4).defined_balance_id := get_def_bal_id('Taxable Earnings','_ASG_ER_PTD');

   p_balance_value_tab(5).defined_balance_id  := get_def_bal_id(l_element_name||' EE Contribution Base','_ASG_LTD');
   p_balance_value_tab(6).defined_balance_id  := get_def_bal_id(l_element_name||' ER Contribution Base','_ASG_LTD');
   p_balance_value_tab(7).defined_balance_id  := get_def_bal_id(l_insurance_type||' Employee Deductions','_ASG_ER_PTD');
   p_balance_value_tab(8).defined_balance_id  := get_def_bal_id(l_insurance_type||' Employer Deductions','_ASG_ER_PTD');
   p_balance_value_tab(9).defined_balance_id  := get_def_bal_id('Undeducted EE '||l_element_name,'_ASG_LTD');
   p_balance_value_tab(10).defined_balance_id := get_def_bal_id('Undeducted ER '||l_element_name,'_ASG_LTD');
   p_balance_value_tab(11).defined_balance_id := get_def_bal_id('Undeducted EE '||l_element_name,'_ASG_ER_PTD');
   p_balance_value_tab(12).defined_balance_id := get_def_bal_id('Undeducted ER '||l_element_name,'_ASG_ER_PTD');

   IF g_debug THEN
     hr_utility.trace ('===================== Defined Balances =========================');
   END IF;

   IF g_debug THEN
     hr_utility.trace ('===================== Balance Values =========================');
   END IF;

   FOR cnt in p_balance_value_tab.first .. p_balance_value_tab.last
   LOOP
     p_balance_value_tab(cnt).balance_value :=
            pay_balance_pkg.get_value
                    (p_defined_balance_id   => p_balance_value_tab(cnt).defined_balance_id
                    ,p_assignment_action_id => p_assignment_action_id
                    ,p_tax_unit_id          => p_tax_unit_id
                    ,p_jurisdiction_code    => NULL
                    ,p_source_id            => NULL
                    ,p_source_text          => NULL
                    ,p_tax_group            => NULL
                    ,p_date_earned          => NULL
                    ,p_get_rr_route         => NULL
                    ,p_get_rb_route         => 'TRUE');

        hr_utility.trace ('.   Defined balance ID '||p_balance_value_tab(cnt).defined_balance_id||' has balance value '||p_balance_value_tab(cnt).balance_value);
   END LOOP;

   IF g_debug THEN
     hr_utility.trace ('===================== Balance Values =========================');
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 20);

EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace(l_message);

END get_phf_si_balances;


----------------------------------------------------------------------------
--                                                                        --
-- Name 	: CALCULATE_CONT_JAN_2006                                 --
-- Type 	: Function                                                --
-- Access 	: Public                                                  --
-- Description 	: Function to process the PHF/SI elements                 --
--                                                                        --
-- Parameters   :                                                         --
--          IN  :                                                         --
--                  ,p_date_earned                  DATE                  --
--                   p_phf_si_type                  VARCHAR2              --
--                  ,p_ee_rate                      NUMBER                --
--                  ,p_er_rate                      NUMBER                --
--                  ,p_ee_rate_type                 VARCHAR2              --
--                  ,p_er_rate_type                 VARCHAR2              --
--                  ,p_ee_cont_base_method          VARCHAR2              --
--                  ,p_er_cont_base_method          VARCHAR2              --
--                  ,p_ee_fixed_amount              NUMBER                --
--                  ,p_er_fixed_amount              NUMBER                --
--                  ,p_phf_si_earngs_asg_ptd        NUMBER                --
--                  ,p_phf_si_earngs_asg_pmth       NUMBER                --
--                  ,p_phf_si_earngs_asg_pyear      NUMBER                --
--                  ,p_average_salary               NUMBER                --
--                  ,p_lowest_avg_salary            NUMBER                --
--                  ,p_ee_rate_roundg_method        VARCHAR2              --
--                  ,p_er_rate_roundg_method        VARCHAR2              --
--                  ,p_phf_high_lim_exemp           VARCHAR2              --
--                  ,p_ee_hi_cont_type              VARCHAR2              --
--                  ,p_er_hi_cont_type              VARCHAR2              --
--                  ,p_ee_hi_cont_amt               NUMBER                --
--                  ,p_er_hi_cont_amt               NUMBER                --
--                  ,p_ee_hi_cont_base_meth         VARCHAR2              --
--                  ,p_er_hi_cont_base_meth         VARCHAR2              --
--                  ,p_ee_hi_cont_base_amount       NUMBER                --
--                  ,p_er_hi_cont_base_amount       NUMBER                --
--       IN OUT  :
--                  ,p_ee_phf_si_amount             NUMBER                --
--                  ,p_er_phf_si_amount             NUMBER                --
--                  ,p_ee_cont_base_amount          NUMBER                --
--                  ,p_er_cont_base_amount          NUMBER                --
--                  ,p_ee_taxable_cont              NUMBER                --
--                  ,p_er_taxable_cont              NUMBER                --
-----------------------------------------------------------------------------

FUNCTION calculate_cont_jan_2006(
                  p_date_earned                 IN            DATE
                 ,p_phf_si_type                 IN            VARCHAR2
                 ,p_ee_rate                     IN            NUMBER
                 ,p_er_rate                     IN            NUMBER
                 ,p_ee_rate_type                IN            VARCHAR2
                 ,p_er_rate_type                IN            VARCHAR2
                 ,p_ee_cont_base_method         IN            VARCHAR2
                 ,p_er_cont_base_method         IN            VARCHAR2
                 ,p_ee_fixed_amount             IN            NUMBER
                 ,p_er_fixed_amount             IN            NUMBER
                 ,p_phf_si_earnings_asg_ptd     IN            NUMBER
                 ,p_phf_si_earnings_asg_pmth    IN            NUMBER
                 ,p_phf_si_earnings_asg_pyear   IN            NUMBER
                 ,p_average_salary              IN            NUMBER
                 ,p_lowest_avg_salary           IN            NUMBER
                 ,p_ee_rate_rounding_method     IN            VARCHAR2
                 ,p_er_rate_rounding_method     IN            VARCHAR2
                 ,p_ee_hi_cont_type             IN            VARCHAR2
                 ,p_er_hi_cont_type             IN            VARCHAR2
                 ,p_ee_hi_cont_amt              IN            NUMBER
                 ,p_er_hi_cont_amt              IN            NUMBER
                 ,p_ee_hi_cont_base_meth        IN            VARCHAR2
                 ,p_er_hi_cont_base_meth        IN            VARCHAR2
                 ,p_ee_hi_cont_base_amount      IN            NUMBER
                 ,p_er_hi_cont_base_amount      IN            NUMBER
		 ,p_ee_phf_si_amount            IN OUT NOCOPY NUMBER
                 ,p_er_phf_si_amount            IN OUT NOCOPY NUMBER
                 ,p_ee_taxable_cont             IN OUT NOCOPY NUMBER
                 ,p_er_taxable_cont             IN OUT NOCOPY NUMBER
                 ,p_ee_cont_base_amount         IN OUT NOCOPY NUMBER
                 ,p_er_cont_base_amount         IN OUT NOCOPY NUMBER
		 ,p_ee_tax_thrhld_rate          IN            NUMBER -- added for bug 6828199
		 ,p_er_tax_thrhld_rate          IN            NUMBER -- added for bug 6828199
		 ,p_tax_thrhld_amount           IN            NUMBER -- added for bug 6828199
                 )
RETURN  VARCHAR2
IS
   CURSOR c_get_global_value(p_global_name IN VARCHAR2)
   IS
    SELECT fnd_number.canonical_to_number(global_value)
      FROM ff_globals_f
      WHERE legislation_code= 'CN'
      AND global_name = p_global_name
      AND p_date_earned BETWEEN effective_start_date AND effective_end_date;



   l_phf_si_earnings_asg_ptd     NUMBER;
   l_phf_si_earnings_asg_pyear   NUMBER;
   l_phf_si_earnings_asg_pmth    NUMBER;

-------coming from old logic-----
   l_ee_rate                    NUMBER;
   l_er_rate                    NUMBER;
   l_ee_rate_type               VARCHAR2(200);
   l_er_rate_type               VARCHAR2(200);
   l_ee_cont_base_method	VARCHAR2(200);
   l_er_cont_base_method	VARCHAR2(200);
   l_ee_cont_base_amount        NUMBER ;
   l_er_cont_base_amount        NUMBER ;
   l_ee_fixed_amount	    	NUMBER;
   l_er_fixed_amount	    	NUMBER;
   l_average_salary	    	NUMBER;
   l_lowest_avg_salary          NUMBER;
   l_ee_rate_rounding_method	VARCHAR2(200);
   l_er_rate_rounding_method    VARCHAR2(200);

   l_ee_phf_si_amount           NUMBER :=0;
   l_er_phf_si_amount           NUMBER :=0;

   l_message                    VARCHAR2(1000) :='SUCCESS';
   initialize_on_error     EXCEPTION;


   l_ee_hi_cont_type            VARCHAR2(200);
   l_er_hi_cont_type            VARCHAR2(200);
   l_ee_hi_cont_amt             NUMBER := 0;
   l_er_hi_cont_amt             NUMBER := 0;
   l_ee_hi_cont_base_meth       VARCHAR2(200);
   l_er_hi_cont_base_meth       VARCHAR2(200);
   l_ee_hi_cont_base_amount     NUMBER := 0;
   l_er_hi_cont_base_amount     NUMBER := 0;


   l_out_ee_hi_cont_base_amount NUMBER := 0;
   l_out_er_hi_cont_base_amount NUMBER := 0;
   l_ee_stat_fixed_amount       NUMBER :=0;
   l_er_stat_fixed_amount       NUMBER :=0;
   l_ee_phf_si_amount_higher    NUMBER := 0;
   l_er_phf_si_amount_higher    NUMBER := 0;
   l_ee_taxable_cont            NUMBER := 0;
   l_er_taxable_cont            NUMBER := 0;

   l_ee_stat_percentage    NUMBER :=0;
   l_er_stat_percentage    NUMBER :=0;
   l_ee_tax_thrhld_rate    NUMBER :=0; -- added for bug 6828199
   l_er_tax_thrhld_rate    NUMBER :=0; -- added for bug 6828199
   l_tax_thrhld_amount     NUMBER :=0; -- added for bug 6828199



BEGIN


   hr_cn_api.set_location(g_debug,' Entering PHF and SI Enhancements started from 1-Jan-2006 : ', 230);


   IF g_debug THEN
	hr_utility.trace(' =======================================================');
	hr_utility.trace('p_phf_si_type               '||p_phf_si_type);
	hr_utility.trace('p_ee_rate                   '|| p_ee_rate);
	hr_utility.trace('p_er_rate                   '|| p_er_rate);
	hr_utility.trace('p_ee_rate_type              '|| p_ee_rate_type);
	hr_utility.trace('p_er_rate_type              '|| p_er_rate_type);
	hr_utility.trace('p_ee_cont_base_method       '|| p_ee_cont_base_method);
	hr_utility.trace('p_er_cont_base_method       '|| p_er_cont_base_method);
	hr_utility.trace('p_ee_cont_base_amount       '|| p_ee_cont_base_amount);
	hr_utility.trace('p_er_cont_base_amount       '|| p_er_cont_base_amount);
	hr_utility.trace('p_ee_fixed_amount           '|| p_ee_fixed_amount);
	hr_utility.trace('p_er_fixed_amount           '|| p_er_fixed_amount);
	hr_utility.trace('p_average_salary            '|| p_average_salary);
	hr_utility.trace('p_lowest_avg_salary         '|| p_lowest_avg_salary);
	hr_utility.trace('p_ee_rate_rounding_method   '|| p_ee_rate_rounding_method);
	hr_utility.trace('p_er_rate_rounding_method   '|| p_er_rate_rounding_method);

	hr_utility.trace('p_ee_phf_si_amount          '|| p_ee_phf_si_amount);
	hr_utility.trace('p_er_phf_si_amount          '|| p_er_phf_si_amount);

	hr_utility.trace('p_phf_si_earnings_asg_ptd   '|| p_phf_si_earnings_asg_ptd);
	hr_utility.trace('p_phf_si_earnings_asg_pyear '|| p_phf_si_earnings_asg_pyear);
	hr_utility.trace('p_phf_si_earnings_asg_pmth  '|| p_phf_si_earnings_asg_pmth);

	hr_utility.trace('p_ee_hi_cont_type           '||p_ee_hi_cont_type       );
	hr_utility.trace('p_er_hi_cont_type           '||p_er_hi_cont_type       );
	hr_utility.trace('p_ee_hi_cont_amt            '||p_ee_hi_cont_amt        );
	hr_utility.trace('p_er_hi_cont_amt            '||p_er_hi_cont_amt        );
	hr_utility.trace('p_ee_hi_cont_base_meth      '||p_ee_hi_cont_base_meth  );
	hr_utility.trace('p_er_hi_cont_base_meth      '||p_er_hi_cont_base_meth  );
	hr_utility.trace('p_ee_hi_cont_base_amount    '||p_ee_hi_cont_base_amount);
	hr_utility.trace('p_er_hi_cont_base_amount    '||p_er_hi_cont_base_amount);
	hr_utility.trace('p_ee_taxable_cont           '||p_ee_taxable_cont);
	hr_utility.trace('p_er_taxable_cont           '||p_er_taxable_cont);
	hr_utility.trace('p_date_earned               '||p_date_earned);
	hr_utility.trace('p_ee_tax_thrhld_rate               '||p_ee_tax_thrhld_rate);
        hr_utility.trace('p_er_tax_thrhld_rate               '||p_er_tax_thrhld_rate);
        hr_utility.trace('p_tax_thrhld_amount               '||p_tax_thrhld_amount);
	hr_utility.trace(' =======================================================');
   END IF;
---------------------------------------------------------------------------------------------
/* Start Bug 5563042 (PHF and SI Enhancements), check for employee level data  */
---------------------------------------------------------------------------------------------

                 l_ee_rate                   := p_ee_rate;
                 l_er_rate                   := p_er_rate;
                 l_ee_rate_type              := p_ee_rate_type;
                 l_er_rate_type              := p_er_rate_type;
                 l_ee_cont_base_method       := p_ee_cont_base_method;
                 l_er_cont_base_method       := p_er_cont_base_method;
                 l_ee_cont_base_amount       := p_ee_cont_base_amount;
                 l_er_cont_base_amount       := p_er_cont_base_amount;
                 l_ee_fixed_amount           := p_ee_fixed_amount;
                 l_er_fixed_amount           := p_er_fixed_amount;
                 l_average_salary            := p_average_salary;
                 l_lowest_avg_salary         := p_lowest_avg_salary;
                 l_ee_rate_rounding_method   := p_ee_rate_rounding_method;
                 l_er_rate_rounding_method   := p_er_rate_rounding_method;

                 l_ee_phf_si_amount          := p_ee_phf_si_amount;
                 l_er_phf_si_amount          := p_er_phf_si_amount;
                 l_phf_si_earnings_asg_ptd       := p_phf_si_earnings_asg_ptd;
                 l_phf_si_earnings_asg_pyear     := p_phf_si_earnings_asg_pyear;
                 l_phf_si_earnings_asg_pmth      := p_phf_si_earnings_asg_pmth;
                 l_ee_hi_cont_type        := p_ee_hi_cont_type;
                 l_er_hi_cont_type        := p_er_hi_cont_type;
                 l_ee_hi_cont_amt         := p_ee_hi_cont_amt;
                 l_er_hi_cont_amt         := p_er_hi_cont_amt;
                 l_ee_hi_cont_base_meth   := p_ee_hi_cont_base_meth;
                 l_er_hi_cont_base_meth   := p_er_hi_cont_base_meth;
                 l_ee_hi_cont_base_amount := p_ee_hi_cont_base_amount;
                 l_er_hi_cont_base_amount := p_er_hi_cont_base_amount;
                 l_ee_taxable_cont        := p_ee_taxable_cont;
                 l_er_taxable_cont        := p_er_taxable_cont;
		 l_ee_tax_thrhld_rate     := p_ee_tax_thrhld_rate;
		 l_er_tax_thrhld_rate     := p_er_tax_thrhld_rate;
		 l_tax_thrhld_amount      := p_tax_thrhld_amount;


        IF g_debug THEN
                hr_utility.trace(' =======================================================');
		hr_utility.trace(' .       l_ee_rate                   : '||l_ee_rate);
		hr_utility.trace(' .       l_er_rate                   : '||l_er_rate);
		hr_utility.trace(' .       l_ee_rate_type              : '||l_ee_rate_type);
		hr_utility.trace(' .       l_er_rate_type              : '||l_er_rate_type);
		hr_utility.trace(' .       l_ee_cont_base_method       : '||l_ee_cont_base_method);
		hr_utility.trace(' .       l_er_cont_base_method       : '||l_er_cont_base_method);
		hr_utility.trace(' .       l_ee_cont_base_amount       : '||l_ee_cont_base_amount);
		hr_utility.trace(' .       l_er_cont_base_amount       : '||l_er_cont_base_amount);
		hr_utility.trace(' .       l_ee_fixed_amount           : '||l_ee_fixed_amount);
		hr_utility.trace(' .       l_er_fixed_amount           : '||l_er_fixed_amount);
		hr_utility.trace(' .       l_average_salary            : '||l_average_salary);
		hr_utility.trace(' .       l_lowest_avg_salary         : '||l_lowest_avg_salary);
		hr_utility.trace(' .       l_ee_rate_rounding_method   : '||l_ee_rate_rounding_method);
		hr_utility.trace(' .       l_er_rate_rounding_method   : '||l_er_rate_rounding_method);
		hr_utility.trace(' .       l_ee_phf_si_amount          : '||l_ee_phf_si_amount);
		hr_utility.trace(' .       l_er_phf_si_amount          : '||l_er_phf_si_amount);
		hr_utility.trace(' .       l_phf_si_earnings_asg_ptd   : '||l_phf_si_earnings_asg_ptd);
		hr_utility.trace(' .       l_phf_si_earnings_asg_pyear : '||l_phf_si_earnings_asg_pyear);
		hr_utility.trace(' .       l_phf_si_earnings_asg_pmth  : '||l_phf_si_earnings_asg_pmth);
		hr_utility.trace(' .       l_ee_hi_cont_type           : '||l_ee_hi_cont_type       );
		hr_utility.trace(' .       l_er_hi_cont_type           : '||l_er_hi_cont_type       );
		hr_utility.trace(' .       l_ee_hi_cont_amt            : '||l_ee_hi_cont_amt        );
		hr_utility.trace(' .       l_er_hi_cont_amt            : '||l_er_hi_cont_amt        );
		hr_utility.trace(' .       l_ee_hi_cont_base_meth      : '||l_ee_hi_cont_base_meth  );
		hr_utility.trace(' .       l_er_hi_cont_base_meth      : '||l_er_hi_cont_base_meth  );
		hr_utility.trace(' .       l_ee_hi_cont_base_amount    : '||l_ee_hi_cont_base_amount);
		hr_utility.trace(' .       l_er_hi_cont_base_amount    : '||l_er_hi_cont_base_amount);
		hr_utility.trace(' .       l_ee_taxable_cont           : '||l_ee_taxable_cont);
		hr_utility.trace(' .       l_er_taxable_cont           : '||l_er_taxable_cont);
		hr_utility.trace(' .       l_ee_tax_thrhld_rate    : '||l_ee_tax_thrhld_rate);
                hr_utility.trace(' .       l_er_tax_thrhld_rate    : '||l_er_tax_thrhld_rate);
                hr_utility.trace(' .       l_tax_thrhld_amount    : '||l_tax_thrhld_amount);
                hr_utility.trace(' =======================================================');
        END IF;

        IF (p_ee_hi_cont_amt = -1) THEN
                l_ee_hi_cont_amt := l_ee_rate;
                l_ee_hi_cont_type := l_ee_rate_type;
        END IF;

        IF (p_er_hi_cont_amt = -1) THEN
                l_er_hi_cont_amt := l_er_rate;
                l_er_hi_cont_type := l_er_rate_type;
        END IF;

        IF (p_ee_hi_cont_base_meth = 'XX') THEN
                l_ee_hi_cont_base_meth := l_ee_cont_base_method;
                l_ee_hi_cont_base_amount := nvl(l_ee_fixed_amount,l_ee_cont_base_amount); /* Changed for bug 8838185 */
                l_out_ee_hi_cont_base_amount := l_ee_cont_base_amount;
        END IF;

        IF (p_er_hi_cont_base_meth = 'XX') THEN
                l_er_hi_cont_base_meth := l_er_cont_base_method;
                l_er_hi_cont_base_amount := nvl(l_er_fixed_amount,l_er_cont_base_amount); /* Changed for bug 8838185 */
                l_out_er_hi_cont_base_amount := l_er_cont_base_amount;
        END IF;

        IF g_debug THEN
                hr_utility.trace(' =======================================================');
                hr_utility.trace(' .       l_ee_hi_cont_type       : '||l_ee_hi_cont_type       );
                hr_utility.trace(' .       l_er_hi_cont_type       : '||l_er_hi_cont_type       );
                hr_utility.trace(' .       l_ee_hi_cont_amt        : '||l_ee_hi_cont_amt        );
                hr_utility.trace(' .       l_er_hi_cont_amt        : '||l_er_hi_cont_amt        );
                hr_utility.trace(' .       l_ee_hi_cont_base_meth  : '||l_ee_hi_cont_base_meth  );
                hr_utility.trace(' .       l_er_hi_cont_base_meth  : '||l_er_hi_cont_base_meth  );
                hr_utility.trace(' .       l_ee_hi_cont_base_amount: '||l_ee_hi_cont_base_amount);
                hr_utility.trace(' .       l_er_hi_cont_base_amount: '||l_er_hi_cont_base_amount);
                hr_utility.trace(' .       l_out_ee_hi_cont_base_amount: '||l_out_ee_hi_cont_base_amount);
                hr_utility.trace(' .       l_out_er_hi_cont_base_amount: '||l_out_er_hi_cont_base_amount);
                hr_utility.trace(' =======================================================');
        END IF;

        IF (l_out_ee_hi_cont_base_amount = 0) THEN
                l_message :=
                        get_cont_base_amount
                                (p_cont_base_method            => l_ee_hi_cont_base_meth
                                ,p_phf_si_earnings_asg_ptd     => l_phf_si_earnings_asg_ptd
                                ,p_phf_si_earnings_asg_pmth    => l_phf_si_earnings_asg_pmth
                                ,p_phf_si_earnings_asg_avg     => l_phf_si_earnings_asg_pyear
                                ,p_average_salary              => l_average_salary
                                ,p_lowest_average_salary       => l_lowest_avg_salary
                                ,p_fixed_amount                => l_ee_hi_cont_base_amount
                                ,p_cont_base_amount            => l_out_ee_hi_cont_base_amount);
                /* Changes for bug 8838185 start */
                IF l_out_ee_hi_cont_base_amount = -1 THEN
		  l_out_ee_hi_cont_base_amount := 0;
		END IF;
                /* Changes for bug 8838185 end */
                IF l_out_ee_hi_cont_base_amount = hr_api.g_number AND l_message <> 'SUCCESS' THEN
                        hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 240);
                        RAISE initialize_on_error;
                END IF;

        END IF;

        IF (l_out_er_hi_cont_base_amount = 0) THEN
                l_message :=
                        get_cont_base_amount
                                (p_cont_base_method            => l_er_hi_cont_base_meth
                                ,p_phf_si_earnings_asg_ptd     => l_phf_si_earnings_asg_ptd
                                ,p_phf_si_earnings_asg_pmth    => l_phf_si_earnings_asg_pmth
                                ,p_phf_si_earnings_asg_avg     => l_phf_si_earnings_asg_pyear
                                ,p_average_salary              => l_average_salary
                                ,p_lowest_average_salary       => l_lowest_avg_salary
                                ,p_fixed_amount                => l_er_hi_cont_base_amount
                                ,p_cont_base_amount            => l_out_er_hi_cont_base_amount);
               /* Changes for bug 8838185 start */
                IF l_out_er_hi_cont_base_amount = -1 THEN
		  l_out_er_hi_cont_base_amount := 0;
		END IF;
                /* Changes for bug 8838185 end */
                IF l_out_er_hi_cont_base_amount = hr_api.g_number AND l_message <> 'SUCCESS' THEN
                        hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 250);
                        RAISE initialize_on_error;
                END IF;
        END IF;


        l_ee_phf_si_amount_higher :=
                get_cont_amount
                        (p_cont_base          => l_out_ee_hi_cont_base_amount
                        ,p_rate_type          => l_ee_hi_cont_type
                        ,p_rate_amount        => l_ee_hi_cont_amt
                        ,p_rounding_method    => l_ee_rate_rounding_method
                        ,p_message            => l_message);

        hr_cn_api.set_location(g_debug,' l_ee_phf_si_amount_higher : '||l_ee_phf_si_amount_higher, 260);

        IF l_message <> 'SUCCESS' THEN
                l_ee_phf_si_amount_higher := 0;
                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 270);
                RETURN l_message;
        END IF;

        l_er_phf_si_amount_higher :=
                get_cont_amount
                        (p_cont_base          => l_out_er_hi_cont_base_amount
                        ,p_rate_type          => l_er_hi_cont_type
                        ,p_rate_amount        => l_er_hi_cont_amt
                        ,p_rounding_method    => l_er_rate_rounding_method
                        ,p_message            => l_message);

        hr_cn_api.set_location(g_debug,' l_er_phf_si_amount_higher : '||l_er_phf_si_amount_higher, 280);

        IF l_message <> 'SUCCESS' THEN
                l_er_phf_si_amount_higher := 0;
                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 290);
                RETURN l_message;
        END IF;


        IF g_debug THEN
                hr_utility.trace(' =======================================================');
                hr_utility.trace(' .       p_phf_si_type            : '||p_phf_si_type        );
                hr_utility.trace(' .       l_ee_hi_cont_type        : '||l_ee_hi_cont_type    );
                hr_utility.trace(' .       l_er_hi_cont_type        : '||l_er_hi_cont_type    );
                hr_utility.trace(' .       l_ee_hi_cont_amt         : '||l_ee_hi_cont_amt     );
                hr_utility.trace(' .       l_er_hi_cont_amt         : '||l_er_hi_cont_amt     );
                hr_utility.trace(' .       l_ee_rate_type           : '||l_ee_rate_type       );
                hr_utility.trace(' .       l_er_rate_type           : '||l_er_rate_type       );
	        hr_utility.trace(' .       l_ee_phf_si_amount_higher: '||l_ee_phf_si_amount_higher);
	        hr_utility.trace(' .       l_er_phf_si_amount_higher: '||l_er_phf_si_amount_higher);
                hr_utility.trace(' =======================================================');
        END IF;


/* 6828199 - all the 4 phf si types can enter this piece of code now
           - Globals EE_PHF_HIGH_LIMIT and ER_PHF_HIGH_LIMIT are not required anymore
*/

/* Changes for bug 6828199 starts */
                /* Changes for bug 8838185 start */
		IF l_ee_tax_thrhld_rate IS NOT NULL THEN
                      l_ee_stat_percentage := l_ee_tax_thrhld_rate;
                ELSE

                      IF l_ee_hi_cont_type in ('PERCENTAGE','FIXED') THEN
		         IF l_ee_hi_cont_amt = -1 THEN
		              l_ee_stat_percentage := l_ee_rate;
                         ELSE
			      l_ee_stat_percentage := l_ee_hi_cont_amt;
                         END IF;
                      END IF;
                END IF;

		IF l_er_tax_thrhld_rate IS NOT NULL THEN
		      l_er_stat_percentage := l_er_tax_thrhld_rate;
                ELSE

                      IF l_er_hi_cont_type in ('PERCENTAGE','FIXED') THEN
		         IF l_er_hi_cont_amt = -1 THEN
		              l_er_stat_percentage := l_er_rate;
                         ELSE
			      l_er_stat_percentage := l_er_hi_cont_amt;
                         END IF;
                      END IF;

                END IF;
		/* Changes for bug 8838185 end */
                /* 7283402 - Use higher cont base amount l_out_ee_hi_cont_base_amount*/
		IF l_tax_thrhld_amount IS NOT NULL AND l_out_ee_hi_cont_base_amount > l_tax_thrhld_amount THEN
		      l_ee_cont_base_amount := l_tax_thrhld_amount ;
                END IF;
                /* 7283402 - Use higher cont base amount l_out_er_hi_cont_base_amount*/
		IF l_tax_thrhld_amount IS NOT NULL AND l_out_er_hi_cont_base_amount > l_tax_thrhld_amount THEN
		      l_er_cont_base_amount := l_tax_thrhld_amount ;
                END IF;
                /* Changes for bug 8838185 start */
		IF l_tax_thrhld_amount IS NULL THEN
		      l_ee_cont_base_amount := l_out_ee_hi_cont_base_amount;
		      l_er_cont_base_amount := l_out_er_hi_cont_base_amount;
                END IF;
                /* Changes for bug 8838185 end */

/* Changes for bug 6828199 end */

/* 6828199 - Logic for PHF/SI Taxation is driven by Tax Threshold Rates and Threshold base */

                IF( l_ee_tax_thrhld_rate IS NOT NULL OR
		    l_er_tax_thrhld_rate IS NOT NULL OR
		    l_tax_thrhld_amount  IS NOT NULL) THEN
                        IF (l_ee_hi_cont_type = 'PERCENTAGE') THEN
                                IF(l_ee_hi_cont_amt > l_ee_stat_percentage) THEN
                                        l_ee_phf_si_amount :=
                                                get_cont_amount
                                                (p_cont_base          => l_ee_cont_base_amount
                                                ,p_rate_type          => l_ee_rate_type
                                                ,p_rate_amount        => l_ee_stat_percentage
                                                ,p_rounding_method    => l_ee_rate_rounding_method
                                                ,p_message            => l_message);

                                        IF l_message <> 'SUCCESS' THEN
                                                l_ee_phf_si_amount := 0;
                                                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 305);
                                                RETURN l_message;
                                        END IF;

                                ELSE
                                        l_ee_phf_si_amount :=
                                                get_cont_amount
                                                (p_cont_base          => l_ee_cont_base_amount
                                                ,p_rate_type          => 'PERCENTAGE'
                                                ,p_rate_amount        => l_ee_hi_cont_amt
                                                ,p_rounding_method    => l_ee_rate_rounding_method
                                                ,p_message            => l_message);

                                        IF l_message <> 'SUCCESS' THEN
                                                l_ee_phf_si_amount := 0;
                                                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 310);
                                                RETURN l_message;
                                        END IF;
                                END IF;
				hr_cn_api.set_location(g_debug,' l_ee_phf_si_amount : '||l_ee_phf_si_amount, 320);
                        ELSE

			        IF l_ee_tax_thrhld_rate IS NULL THEN

				    l_ee_stat_fixed_amount := l_ee_stat_percentage ;

				ELSE

				    l_ee_stat_fixed_amount :=
					get_cont_amount
					(p_cont_base          => l_ee_cont_base_amount
					,p_rate_type          => 'PERCENTAGE'
					,p_rate_amount        => l_ee_stat_percentage
					,p_rounding_method    => l_ee_rate_rounding_method
					,p_message            => l_message);

                                 END IF;

				IF l_message <> 'SUCCESS' THEN
					l_ee_phf_si_amount := 0;
					hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 330);
					RETURN l_message;
				END IF;

				hr_cn_api.set_location(g_debug,' l_ee_stat_fixed_amount : '||l_ee_stat_fixed_amount, 340);
				hr_cn_api.set_location(g_debug,' l_ee_phf_si_amount_higher : '||l_ee_phf_si_amount_higher, 350);

				IF (l_ee_phf_si_amount_higher >l_ee_stat_fixed_amount) THEN
					l_ee_phf_si_amount := l_ee_stat_fixed_amount;
				ELSE
					l_ee_phf_si_amount := l_ee_phf_si_amount_higher;
				END IF;
				hr_cn_api.set_location(g_debug,' l_ee_phf_si_amount : '||l_ee_phf_si_amount, 360);
			END IF;

                        IF (l_er_hi_cont_type = 'PERCENTAGE') THEN
                                IF(l_er_hi_cont_amt > l_er_stat_percentage) THEN
                                        l_er_phf_si_amount :=
                                                get_cont_amount
                                                (p_cont_base          => l_er_cont_base_amount
                                                ,p_rate_type          => l_er_rate_type
                                                ,p_rate_amount        => l_er_stat_percentage
                                                ,p_rounding_method    => l_er_rate_rounding_method
                                                ,p_message            => l_message);

                                        IF l_message <> 'SUCCESS' THEN
                                                l_er_phf_si_amount := 0;
                                                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 370);
                                                RETURN l_message;
                                        END IF;
                                ELSE
                                        l_er_phf_si_amount :=
                                                get_cont_amount
                                                (p_cont_base          => l_er_cont_base_amount
                                                ,p_rate_type          => 'PERCENTAGE'
                                                ,p_rate_amount        => l_er_hi_cont_amt
                                                ,p_rounding_method    => l_er_rate_rounding_method
                                                ,p_message            => l_message);

                                        IF l_message <> 'SUCCESS' THEN
                                                l_er_phf_si_amount := 0;
                                                hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 380);
                                                RETURN l_message;
                                        END IF;
                                END IF;
				hr_cn_api.set_location(g_debug,' l_er_phf_si_amount : '||l_er_phf_si_amount, 390);
                        ELSE

			        IF l_er_tax_thrhld_rate IS NULL THEN

				   l_er_stat_fixed_amount := l_er_stat_percentage ;

				ELSE

				   l_er_stat_fixed_amount :=
					get_cont_amount
					(p_cont_base          => l_er_cont_base_amount
					,p_rate_type          => 'PERCENTAGE'
					,p_rate_amount        => l_er_stat_percentage
					,p_rounding_method    => l_er_rate_rounding_method
					,p_message            => l_message);

				END IF;

				IF l_message <> 'SUCCESS' THEN
					l_er_phf_si_amount := 0;
					hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 400);
					RETURN l_message;
				END IF;

				hr_cn_api.set_location(g_debug,' l_er_stat_fixed_amount : '||l_er_stat_fixed_amount, 410);
				hr_cn_api.set_location(g_debug,' l_er_phf_si_amount_higher : '||l_er_phf_si_amount_higher, 420);

				IF (l_er_phf_si_amount_higher >l_er_stat_fixed_amount) THEN
					l_er_phf_si_amount := l_er_stat_fixed_amount;
				ELSE
					l_er_phf_si_amount := l_er_phf_si_amount_higher;
				END IF;
				hr_cn_api.set_location(g_debug,' l_er_phf_si_amount : '||l_er_phf_si_amount, 430);
                        END IF;

                        l_ee_taxable_cont := GREATEST(l_ee_phf_si_amount_higher - l_ee_phf_si_amount, 0);
                        l_er_taxable_cont := GREATEST(l_er_phf_si_amount_higher - l_er_phf_si_amount, 0);
                ELSE
                        l_ee_taxable_cont :=0;
                        l_er_taxable_cont :=0;

                END IF;


    hr_cn_api.set_location(g_debug,' l_ee_taxable_cont : '|| l_ee_taxable_cont, 440);
    hr_cn_api.set_location(g_debug,' l_er_taxable_cont : '|| l_er_taxable_cont, 450);

   p_ee_taxable_cont        := l_ee_taxable_cont;
   p_er_taxable_cont        := l_er_taxable_cont;
   p_ee_phf_si_amount := l_ee_phf_si_amount_higher;
   p_er_phf_si_amount := l_er_phf_si_amount_higher;
   p_ee_cont_base_amount := l_out_ee_hi_cont_base_amount;
   p_er_cont_base_amount := l_out_er_hi_cont_base_amount;




   IF g_debug THEN
	hr_utility.trace(' =======================================================');
	hr_utility.trace('p_ee_phf_si_amount      '||p_ee_phf_si_amount       );
	hr_utility.trace('p_er_phf_si_amount      '||p_er_phf_si_amount       );
	hr_utility.trace('p_er_cont_base_amount   '||p_er_cont_base_amount    );
	hr_utility.trace('p_ee_cont_base_amount   '||p_ee_cont_base_amount    );
	hr_utility.trace('p_ee_taxable_cont       '||p_ee_taxable_cont        );
	hr_utility.trace('p_er_taxable_cont       '||p_er_taxable_cont        );
	hr_utility.trace(' =======================================================');
   END IF;

   hr_cn_api.set_location(g_debug,' Leaving PHF and SI Enhancements started from 1-Jan-2006: ', 460);

---------------------------------------------------------------------------------------------
/* End Bug 5563042 (PHF and SI Enhancements) check for employee level data */
---------------------------------------------------------------------------------------------
   RETURN 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
      RETURN l_message;

END calculate_cont_jan_2006;


----------------------------------------------------------------------------
--                                                                        --
-- Name 	: CALCULATE_CONTRIBUTION                                      --
-- Type 	: Function                                                    --
-- Access 	: Public                                                      --
-- Description 	: Function to process the PHF/SI elements                 --
--                                                                        --
-- Parameters   :                                                         --
--          IN  :                                                         --
--               p_business_group_id            NUMBER                    --
--               p_element_entry_id             NUMBER                    --
--               p_assignment_action_id         NUMBER                    --
--               p_assignment_id                NUMBER                    --
--               p_date_earned                  DATE                      --
--               p_contribution_area            VARCHAR2                  --
--               p_phf_si_type                  VARCHAR2                  --
--               p_hukuo_type                   VARCHAR2                  --
--               p_employer_id                  VARCHAR2                  --
--               p_pay_proc_period_end_date     DATE                      --
-- Bug 4522945:Extra input parameters added		                          --
--		         p_phf_si_earnings_asg_ptd      NUMBER                    --
--		         p_phf_si_earnings_asg_pyear	NUMBER                    --
--		         p_phf_si_earnings_asg_pmth	NUMBER                        --
--		         p_taxable_earnings_asg_er_ptd	NUMBER                    --
--		         p_ee_cont_base_asg_ltd		NUMBER                        --
--		         p_er_cont_base_asg_ltd		NUMBER                        --
--		         p_ee_deductions_asg_er_ptd	NUMBER                        --
--		         p_er_deductions_asg_er_ptd	NUMBER                        --
--		         p_undeducted_ee_asg_ltd	NUMBER                        --
--		         p_undeducted_er_asg_ltd	NUMBER                        --
--		         p_undeducted_ee_asg_er_ptd	NUMBER	                      --
--		         p_undeducted_er_asg_er_ptd	NUMBER	                      --
-- Bug 4522945 Changes End					                              --
--       IN/OUT :                                                         --
--               p_calculation_date             DATE                      --
--               p_ee_cont_base_amount          NUMBER                    --
--               p_er_cont_base_amount          NUMBER                    --
--          OUT :                                                         --
--               p_ee_phf_si_amount             NUMBER                    --
--               p_er_phf_si_amount             NUMBER                    --
--               p_undeducted_ee_phf_si_amount  NUMBER                    --
--               p_undeducted_er_phf_si_amount  NUMBER                    --
--               p_new_ee_cont_base_amount      NUMBER                    --
--               p_new_er_cont_base_amount      NUMBER                    --
--       RETURN : VARCHAR2                                                --
--                                                                        --
-- Change History :                                                       --
----------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                                 --
----------------------------------------------------------------------------
-- 1.0   04-MAR-04  snekkala  Created this function                       --
-- 1.1   05-Jul-04  sshankar  Modified call to get_phf_si_rates to support--
--                            Enterprise Annuity processing               --
-- 1.2   09-Aug-05  rpalli    Modified proc to take phfsi balances        --
--			      and dbi CN_PAYROLL_RUN_MONTHS_PREV_YEAR as              --
--                            input parameters, to replace                --
--                            get_phf_si_balances proc.	                  --
-- 1.3   16-Aug-05  rpalli    Removed parameter p_run_months_prev_year    --
--                            as input to proc(as per review comments).   --
-- 1.4   24-Apr-06  rpalli    Bug#5171083 - commented out the code for    --
--                            updating element entry                      --
-- 1.5   14-Mar-08  dduvvuri  Bug 6828199 - Added variables l_tax_thrhld_amount,
--                            l_ee_thrhld_rate and l_er_thrhld_rate and used them
--                            in certain function calls. Also commented out the
--                            function call get_phf_si_high_limit_exempt
-- 1.6   30-sep-2009 dduvvuri Changes done for bug 8838185
-- 1.7   02-Nov-2009 dduvvuri 8838185 - Removed redundancy coding for fetching New Contribution Base Amounts
----------------------------------------------------------------------------
FUNCTION calculate_contribution(
                  p_business_group_id                IN       NUMBER
                 ,p_element_entry_id                 IN       NUMBER
                 ,p_assignment_action_id             IN       NUMBER
                 ,p_assignment_id                    IN       NUMBER
                 ,p_date_earned                      IN       DATE
                 ,p_contribution_area                IN       VARCHAR2
                 ,p_phf_si_type                      IN       VARCHAR2
                 ,p_hukou_type                       IN       VARCHAR2
                 ,p_employer_id                      IN       VARCHAR2
                 ,p_pay_proc_period_end_date         IN       DATE
                 --
                 ,p_phf_si_earnings_asg_ptd          IN       NUMBER
                 ,p_phf_si_earnings_asg_pyear        IN       NUMBER
                 ,p_phf_si_earnings_asg_pmth         IN       NUMBER
                 ,p_taxable_earnings_asg_er_ptd      IN       NUMBER
                 ,p_ee_cont_base_asg_ltd             IN       NUMBER
                 ,p_er_cont_base_asg_ltd             IN       NUMBER
                 ,p_ee_deductions_asg_er_ptd         IN       NUMBER
                 ,p_er_deductions_asg_er_ptd         IN       NUMBER
                 ,p_undeducted_ee_asg_ltd            IN       NUMBER
                 ,p_undeducted_er_asg_ltd            IN       NUMBER
                 ,p_undeducted_ee_asg_er_ptd         IN       NUMBER
                 ,p_undeducted_er_asg_er_ptd         IN       NUMBER
                 --
                 ,p_calculation_date      IN OUT NOCOPY  DATE
                 ,p_ee_cont_base_amount   IN OUT NOCOPY  NUMBER
                 ,p_er_cont_base_amount   IN OUT NOCOPY  NUMBER
                 --
                 ,p_ee_phf_si_amount            OUT NOCOPY NUMBER
                 ,p_er_phf_si_amount            OUT NOCOPY NUMBER
                 ,p_new_ee_cont_base_amount     OUT NOCOPY NUMBER
                 ,p_new_er_cont_base_amount     OUT NOCOPY NUMBER
                 ,p_undeducted_ee_phf_si_amount OUT NOCOPY NUMBER
                 ,p_undeducted_er_phf_si_amount OUT NOCOPY NUMBER
                 ,p_ee_hi_cont_type             IN         VARCHAR2
                 ,p_er_hi_cont_type             IN         VARCHAR2
                 ,p_ee_hi_cont_amt              IN         NUMBER
                 ,p_er_hi_cont_amt              IN         NUMBER
                 ,p_ee_hi_cont_base_meth        IN         VARCHAR2
                 ,p_er_hi_cont_base_meth        IN         VARCHAR2
                 ,p_ee_hi_cont_base_amount      IN         NUMBER
                 ,p_er_hi_cont_base_amount      IN         NUMBER
                 ,p_ee_taxable_cont             OUT NOCOPY NUMBER
                 ,p_er_taxable_cont             OUT NOCOPY NUMBER
                 ,p_lt_ee_taxable_cont_ptd      IN         NUMBER
                 ,p_lt_er_taxable_cont_ptd      IN         NUMBER
                 )
RETURN VARCHAR2
IS

   CURSOR c_get_global_value(p_global_name IN VARCHAR2)
   IS
    SELECT fnd_number.canonical_to_number(global_value)
      FROM ff_globals_f
      WHERE legislation_code = 'CN'
      AND global_name = p_global_name
      AND p_date_earned BETWEEN effective_start_date AND effective_end_date;


   l_ee_stat_percentage    NUMBER;
   l_er_stat_percentage    NUMBER;

   g_procedure_name    VARCHAR2(50);

   l_ee_cont_base_method	    hr_organization_information.org_information1%type;
   l_er_cont_base_method	    hr_organization_information.org_information1%type;
   l_low_limit_method	    	hr_organization_information.org_information1%type;
   l_high_limit_method	    	hr_organization_information.org_information1%type;
   l_low_limit_amount	    	NUMBER;
   l_high_limit_amount	    	NUMBER;
   l_tax_thrhld_amount          NUMBER; -- for bug 6828199
   l_switch_periodicity		    hr_organization_information.org_information1%type;
   l_switch_month		        hr_organization_information.org_information1%type;
   l_base_rounding_method	    hr_organization_information.org_information1%type;
   l_lowest_avg_salary	    	 NUMBER;
   l_average_salary	    	 NUMBER;
   l_ee_fixed_amount	         NUMBER;
   l_er_fixed_amount	        NUMBER;
   l_ee_rate_type               hr_organization_information.org_information1%type;
   l_er_rate_type               hr_organization_information.org_information1%type;
   l_ee_rate                    NUMBER;
   l_er_rate                    NUMBER;
      l_ee_thrhld_rate             NUMBER; -- for bug 6828199
   l_er_thrhld_rate             NUMBER; -- for bug 6828199
   l_ee_rate_rounding_method	hr_organization_information.org_information1%type;
   l_er_rate_rounding_method    hr_organization_information.org_information1%type;
   l_defer_deductions           hr_organization_information.org_information1%type;
   l_deduct_in_probation_expiry hr_organization_information.org_information1%type;

   l_message 		        VARCHAR2(1000);
   l_recalculate_flag	        VARCHAR2(1);

   l_phf_si_earnings_asg_ptd     NUMBER;
   l_phf_si_earnings_asg_pyear   NUMBER;
   l_phf_si_earnings_asg_pmth    NUMBER;
   l_taxable_earnings_asg_er_ptd NUMBER;
   l_ee_cont_base_asg_ltd        NUMBER;
   l_er_cont_base_asg_ltd        NUMBER;
   l_ee_deductions_asg_er_ptd    NUMBER;
   l_er_deductions_asg_er_ptd    NUMBER;
   l_undeducted_ee_asg_ltd       NUMBER;
   l_undeducted_er_asg_ltd       NUMBER;
   l_undeducted_ee_asg_er_ptd    NUMBER;
   l_undeducted_er_asg_er_ptd    NUMBER;

   l_ee_cont_base_amount         NUMBER :=0;
   l_er_cont_base_amount         NUMBER :=0;
   l_new_ee_cont_base_amount     NUMBER :=0;
   l_new_er_cont_base_amount     NUMBER :=0;
   l_ee_phf_si_amount            NUMBER :=0;
   l_er_phf_si_amount            NUMBER :=0;

   l_actual_probation_end_date   DATE;
   l_const_probation_end_date    DATE;
   l_calculation_date            DATE;

   initialize_on_error     EXCEPTION;


   l_ee_hi_cont_base_amount     NUMBER := 0;
   l_er_hi_cont_base_amount     NUMBER := 0;
   l_ee_phf_si_amount_higher    NUMBER := 0;
   l_er_phf_si_amount_higher    NUMBER := 0;
   l_ee_taxable_cont            NUMBER := 0;
   l_er_taxable_cont            NUMBER := 0;
   l_ee_hi_cont_type            VARCHAR2(100);
   l_er_hi_cont_type            VARCHAR2(100);
   l_ee_hi_cont_amt             NUMBER := 0;
   l_er_hi_cont_amt             NUMBER := 0;
   l_ee_hi_cont_base_meth       VARCHAR2(100);
   l_er_hi_cont_base_meth       VARCHAR2(100);
   l_out_ee_hi_cont_base_amount NUMBER := 0;
   l_out_er_hi_cont_base_amount NUMBER := 0;
   l_phf_high_lim_exemp         VARCHAR2(100);
   l_ee_stat_fixed_amount       NUMBER :=0;
   l_er_stat_fixed_amount       NUMBER :=0;
   l_ee_stat_limit              NUMBER :=0;
   l_er_stat_limit              NUMBER :=0;


BEGIN

    g_debug := hr_utility.debug_enabled;
    g_procedure_name := g_package_name || 'calculate_contribution';

    hr_cn_api.set_location(g_debug, ' Entering: '||g_procedure_name, 10);

    l_ee_cont_base_amount := p_ee_cont_base_amount;
    l_er_cont_base_amount := p_er_cont_base_amount;
    l_calculation_date    := p_calculation_date;

/* Changes for bug 8838185 start */
    l_ee_hi_cont_type         := p_ee_hi_cont_type;
    l_er_hi_cont_type         := p_er_hi_cont_type;
    l_ee_hi_cont_amt          := p_ee_hi_cont_amt;
    l_er_hi_cont_amt          := p_er_hi_cont_amt;
    l_ee_hi_cont_base_meth    := p_ee_hi_cont_base_meth;
    l_er_hi_cont_base_meth    := p_er_hi_cont_base_meth;
    l_ee_hi_cont_base_amount  := p_ee_hi_cont_base_amount;
    l_er_hi_cont_base_amount  := p_er_hi_cont_base_amount;
    p_er_taxable_cont :=0;
    p_ee_taxable_cont :=0;

IF ( l_ee_hi_cont_base_meth <> 'XX' OR
      l_er_hi_cont_base_meth <> 'XX') THEN
     IF l_ee_hi_cont_base_amount = -1 THEN
        l_ee_hi_cont_base_amount := 0;
     END IF;
     IF l_er_hi_cont_base_amount = -1 THEN
        l_er_hi_cont_base_amount := 0;
     END IF;
     IF nvl(l_ee_hi_cont_base_amount,0) <> 0 THEN
         l_ee_cont_base_amount := l_ee_hi_cont_base_amount;
     END IF;
     IF nvl(l_er_hi_cont_base_amount,0) <> 0 THEN
         l_er_cont_base_amount := l_er_hi_cont_base_amount;
     END IF;
END IF;
/* Changes for bug 8838185 end */

    l_message := 'SUCCESS';
--
-- Step I: Get Contribution Base Rates
--

--
-- Bug 3593118
-- Enterprise Annuity
-- Added new parameter p_assignment_id in call to get_phf_si_rates
--
    l_message := get_phf_si_rates
                 (p_assignment_id            => p_assignment_id
	         ,p_business_group_id        => p_business_group_id
                 ,p_contribution_area        => p_contribution_area
		 ,p_phf_si_type              => p_phf_si_type
		 ,p_employer_id              => p_employer_id
                 ,p_hukou_type               => p_hukou_type
		 ,p_effective_date           => p_pay_proc_period_end_date
			     --
		 ,p_ee_rate_type             => l_ee_rate_type
		 ,p_er_rate_type             => l_er_rate_type
		 ,p_ee_rate                  => l_ee_rate
		 ,p_er_rate                  => l_er_rate
		 ,p_ee_thrhld_rate           => l_ee_thrhld_rate -- added for bug 6828199
		 ,p_er_thrhld_rate           => l_er_thrhld_rate -- added for bug 6828199
		 ,p_ee_rounding_method       => l_ee_rate_rounding_method
                 ,p_er_rounding_method       => l_er_rate_rounding_method
			     );

     hr_utility.trace(' Calculate_contribution : Message=>' || l_message);
     IF l_message <> 'SUCCESS'
     THEN
	  hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 25);
          RAISE initialize_on_error;
     END IF;

--
-- Step II: Get Contribution Base Methods
--
    l_message := get_cont_base_methods
                               (p_business_group_id           => p_business_group_id
                               ,p_contribution_area           => p_contribution_area
		               ,p_phf_si_type                 => p_phf_si_type
                               ,p_hukou_type                  => p_hukou_type
		               ,p_effective_date              => p_pay_proc_period_end_date
			       --
                               ,p_ee_cont_base_method         => l_ee_cont_base_method
                               ,p_er_cont_base_method         => l_er_cont_base_method
                               ,p_low_limit_method            => l_low_limit_method
                               ,p_low_limit_amount            => l_low_limit_amount
                               ,p_high_limit_method           => l_high_limit_method
                               ,p_high_limit_amount           => l_high_limit_amount
                               ,p_switch_periodicity          => l_switch_periodicity
                               ,p_switch_month                => l_switch_month
                               ,p_rounding_method             => l_base_rounding_method
                               ,p_lowest_avg_salary           => l_lowest_avg_salary
                               ,p_average_salary              => l_average_salary
		               ,p_ee_fixed_amount             => l_ee_fixed_amount
		               ,p_er_fixed_amount             => l_er_fixed_amount
			       ,p_tax_thrhld_amount           => l_tax_thrhld_amount -- added for bug 6828199
			       );

     hr_utility.trace(' get_cont_base_method : Message=>' || l_message);

     IF l_message <> 'SUCCESS'
     THEN
	  hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 45);
          RAISE initialize_on_error;
     END IF;

--
-- Step III: Calculation of Contribution Base Amounts starts here.
--
 --
 -- Step 1 : Get the various balance values
 --
    l_phf_si_earnings_asg_ptd       := p_phf_si_earnings_asg_ptd;
    l_phf_si_earnings_asg_pyear     := p_phf_si_earnings_asg_pyear;
    l_phf_si_earnings_asg_pmth      := p_phf_si_earnings_asg_pmth;
    l_taxable_earnings_asg_er_ptd   := p_taxable_earnings_asg_er_ptd;
    l_ee_cont_base_asg_ltd          := p_ee_cont_base_asg_ltd;
    l_er_cont_base_asg_ltd          := p_er_cont_base_asg_ltd;
    l_ee_deductions_asg_er_ptd      := p_ee_deductions_asg_er_ptd;
    l_er_deductions_asg_er_ptd      := p_er_deductions_asg_er_ptd;
    l_undeducted_ee_asg_ltd         := p_undeducted_ee_asg_ltd;
    l_undeducted_er_asg_ltd         := p_undeducted_er_asg_ltd;
    l_undeducted_ee_asg_er_ptd      := p_undeducted_ee_asg_er_ptd;
    l_undeducted_er_asg_er_ptd      := p_undeducted_er_asg_er_ptd;
 --
 -- Step 2 : Check if Recalculation is necessary
 --

    l_recalculate_flag:=  get_recalculate_flag
                              (p_switch_periodicity  => l_switch_periodicity
                              ,p_switch_month        => l_switch_month
                              ,p_calculation_date    => l_calculation_date
                              ,p_process_date        => p_pay_proc_period_end_date);

     hr_utility.trace(' l_recalculate_flag : Message=>' || l_recalculate_flag);

   IF l_recalculate_flag='N' THEN
    --
    -- Step 3: Assign the contribution base amounts with corresponding
    --         ltd balances if ltd balance is not 0
    --         ptd balances if ltd balance is 0
    --
    /* Changes for bug 8838185 start */
        IF l_ee_cont_base_asg_ltd = 0 THEN
	      if nvl(l_ee_cont_base_amount,0) = 0 THEN
                    l_ee_cont_base_amount := l_phf_si_earnings_asg_ptd ;
              end if;
        ELSE
	      if nvl(l_ee_cont_base_amount,0) = 0 THEN
                    l_ee_cont_base_amount := l_ee_cont_base_asg_ltd ;
              end if;
        END IF;

        IF l_er_cont_base_asg_ltd = 0 THEN
	      if nvl(l_er_cont_base_amount,0) = 0 THEN
                    l_er_cont_base_amount := l_phf_si_earnings_asg_ptd ;
              end if;
        ELSE
	      if nvl(l_er_cont_base_amount,0) = 0 THEN
                    l_er_cont_base_amount := l_er_cont_base_asg_ltd ;
              end if;
        END IF;
      /* Changes for bug 8838185 end */

        l_calculation_date := g_end_date;

    ELSE
     --
     -- Step 4 : Fetch the Contribution Base Amounts
     --

     IF NVL(l_ee_cont_base_amount,0) = 0 THEN

        l_message :=
           get_cont_base_amount
              (p_cont_base_method            => l_ee_cont_base_method
              ,p_phf_si_earnings_asg_ptd     => l_phf_si_earnings_asg_ptd
              ,p_phf_si_earnings_asg_pmth    => l_phf_si_earnings_asg_pmth
              ,p_phf_si_earnings_asg_avg     => l_phf_si_earnings_asg_pyear
	          ,p_average_salary              => l_average_salary
	          ,p_lowest_average_salary       => l_lowest_avg_salary
	          ,p_fixed_amount                => l_ee_fixed_amount
	          ,p_cont_base_amount            => l_ee_cont_base_amount);

        IF l_ee_cont_base_amount = hr_api.g_number AND l_message <> 'SUCCESS' THEN
             hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 105);
             RAISE initialize_on_error;
	END IF;

     END IF;

     /* commented out the call to function as it is not required now */
     -- l_phf_high_lim_exemp := get_phf_high_limit_exempt(p_employer_id,p_contribution_area);

     get_in_limit
          (p_high_limit_method     => l_high_limit_method
	      ,p_low_limit_method      => l_low_limit_method
	      ,p_high_fixed_amount     => l_high_limit_amount
	      ,p_low_fixed_amount      => l_low_limit_amount
	      ,p_rounding_method       => l_base_rounding_method
	      ,p_average_salary        => l_average_salary
	      ,p_lowest_avg_salary     => l_lowest_avg_salary
	      ,p_amount                => l_ee_cont_base_amount
	      ,p_message               => l_message
	      );

	  IF l_message <> 'SUCCESS' THEN
	      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 115);
              RAISE initialize_on_error;
          END IF;

     IF NVL(l_er_cont_base_amount,0) = 0  THEN

         l_message :=
           get_cont_base_amount
              (p_cont_base_method            => l_er_cont_base_method
              ,p_phf_si_earnings_asg_ptd     => l_phf_si_earnings_asg_ptd
              ,p_phf_si_earnings_asg_pmth    => l_phf_si_earnings_asg_pmth
              ,p_phf_si_earnings_asg_avg     => l_phf_si_earnings_asg_pyear
	          ,p_average_salary              => l_average_salary
	          ,p_lowest_average_salary       => l_lowest_avg_salary
	          ,p_fixed_amount                => l_er_fixed_amount
	          ,p_cont_base_amount            => l_er_cont_base_amount);

         IF l_er_cont_base_amount = hr_api.g_number AND l_message <> 'SUCCESS' THEN
               hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 145);
               RAISE initialize_on_error;
         END IF;

     END IF;

     get_in_limit
          (p_high_limit_method     => l_high_limit_method
	      ,p_low_limit_method      => l_low_limit_method
	      ,p_high_fixed_amount     => l_high_limit_amount
	      ,p_low_fixed_amount      => l_low_limit_amount
	      ,p_rounding_method       => l_base_rounding_method
	      ,p_average_salary        => l_average_salary
	      ,p_lowest_avg_salary     => l_lowest_avg_salary
	      ,p_amount                => l_er_cont_base_amount
	      ,p_message               => l_message
	      );

	   IF l_message <> 'SUCCESS' THEN
	      hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 155);
              RAISE initialize_on_error;
           END IF;

     --
     -- Step 5 : As the contribution bases have been recalculated, call update element entry
     --

        l_calculation_date := p_pay_proc_period_end_date;

/*        l_message:= update_element_entry
                            (p_business_group_id   => p_business_group_id
                            ,p_element_entry_id    => p_element_entry_id
                            ,p_calculation_date    => l_calculation_date
              	             );

      IF l_message <> 'SUCCESS'
      THEN
	     hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 90);
             RAISE initialize_on_error;
      END IF; */

    END IF;

--
-- Calculation of Contribution Base Amounts ends here.
--
--
-- Calculation of Contribution Amounts starts here.

  /* Bug 6828199 - commented out code as it is not required .
                   Removed the restriction of stat limits for phf cont rates
		   Globals EE_PHF_HIGH_LIMIT and ER_PHF_HIGH_LIMIT are not required anymore
		   phf high limit exemption functionality removed from system */

 /*    IF (p_phf_si_type = 'PHF' AND l_phf_high_lim_exemp = 'N') AND
        (p_date_earned >= TO_DATE('01-01-2006','DD-MM-YYYY')) THEN

             OPEN c_get_global_value ('EE_PHF_HIGH_LIMIT');
             FETCH c_get_global_value INTO l_ee_stat_limit;
             CLOSE c_get_global_value;

             OPEN c_get_global_value ('ER_PHF_HIGH_LIMIT');
             FETCH c_get_global_value INTO l_er_stat_limit;
             CLOSE c_get_global_value;

             IF (l_ee_rate_type = 'PERCENTAGE') THEN
                l_ee_rate := LEAST(l_ee_rate, l_ee_stat_limit);
             END IF;

             IF (l_er_rate_type = 'PERCENTAGE') THEN
                l_er_rate := LEAST(l_er_rate, l_er_stat_limit);
             END IF;

     END IF;

 */
     hr_utility.trace(' l_ee_rate =>' || l_ee_rate);
     hr_utility.trace(' l_er_rate =>' || l_er_rate);

    l_ee_phf_si_amount :=
     get_cont_amount
          (p_cont_base          => l_ee_cont_base_amount
	  ,p_rate_type          => l_ee_rate_type
	  ,p_rate_amount        => l_ee_rate
	  ,p_rounding_method    => l_ee_rate_rounding_method
	  ,p_message            => l_message);



    IF l_message <> 'SUCCESS' THEN
       l_ee_phf_si_amount := 0;
       hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 210);
       RETURN l_message;
    END IF;

	IF g_debug THEN
		hr_utility.trace(' =======================================================');
		hr_utility.trace(' .       l_er_cont_base_amount     : '||l_er_cont_base_amount );
		hr_utility.trace(' .       l_er_rate_type            : '||l_er_rate_type        );
		hr_utility.trace(' .       l_er_rate                 : '||l_er_rate             );
		hr_utility.trace(' .       l_er_rate_rounding_method : '||l_er_rate_rounding_method  );
		hr_utility.trace(' =======================================================');
	END IF;

   l_er_phf_si_amount :=
     get_cont_amount
          (p_cont_base          => l_er_cont_base_amount
	  ,p_rate_type          => l_er_rate_type
	  ,p_rate_amount        => l_er_rate
	  ,p_rounding_method    => l_er_rate_rounding_method
	  ,p_message            => l_message);

    IF l_message <> 'SUCCESS' THEN
       l_er_phf_si_amount := 0;
       hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 220);
       RETURN l_message;
    END IF;



IF g_debug THEN
                hr_utility.trace(' =======================================================');
		hr_utility.trace(' .       l_ee_rate                   : '||l_ee_rate);
		hr_utility.trace(' .       l_er_rate                   : '||l_er_rate);
		hr_utility.trace(' .       l_ee_rate_type              : '||l_ee_rate_type);
		hr_utility.trace(' .       l_er_rate_type              : '||l_er_rate_type);
		hr_utility.trace(' .       l_ee_cont_base_method       : '||l_ee_cont_base_method);
		hr_utility.trace(' .       l_er_cont_base_method       : '||l_er_cont_base_method);
		hr_utility.trace(' .       l_ee_cont_base_amount       : '||l_ee_cont_base_amount);
		hr_utility.trace(' .       l_er_cont_base_amount       : '||l_er_cont_base_amount);
		hr_utility.trace(' .       l_ee_fixed_amount           : '||l_ee_fixed_amount);
		hr_utility.trace(' .       l_er_fixed_amount           : '||l_er_fixed_amount);
		hr_utility.trace(' .       l_average_salary            : '||l_average_salary);
		hr_utility.trace(' .       l_lowest_avg_salary         : '||l_lowest_avg_salary);
		hr_utility.trace(' .       l_ee_rate_rounding_method   : '||l_ee_rate_rounding_method);
		hr_utility.trace(' .       l_er_rate_rounding_method   : '||l_er_rate_rounding_method);
		hr_utility.trace(' .       l_phf_high_lim_exemp        : '||l_phf_high_lim_exemp);
		hr_utility.trace(' .       l_ee_phf_si_amount          : '||l_ee_phf_si_amount);
		hr_utility.trace(' .       l_er_phf_si_amount          : '||l_er_phf_si_amount);

		hr_utility.trace(' .       l_phf_si_earnings_asg_ptd   : '||l_phf_si_earnings_asg_ptd);
		hr_utility.trace(' .       l_phf_si_earnings_asg_pyear : '||l_phf_si_earnings_asg_pyear);
		hr_utility.trace(' .       l_phf_si_earnings_asg_pmth  : '||l_phf_si_earnings_asg_pmth);

		hr_utility.trace(' .       l_ee_hi_cont_type           : '||l_ee_hi_cont_type       );
		hr_utility.trace(' .       l_er_hi_cont_type           : '||l_er_hi_cont_type       );
		hr_utility.trace(' .       l_ee_hi_cont_amt            : '||l_ee_hi_cont_amt        );
		hr_utility.trace(' .       l_er_hi_cont_amt            : '||l_er_hi_cont_amt        );
		hr_utility.trace(' .       l_ee_hi_cont_base_meth      : '||l_ee_hi_cont_base_meth  );
		hr_utility.trace(' .       l_er_hi_cont_base_meth      : '||l_er_hi_cont_base_meth  );
		hr_utility.trace(' .       l_ee_hi_cont_base_amount    : '||l_ee_hi_cont_base_amount);
		hr_utility.trace(' .       l_er_hi_cont_base_amount    : '||l_er_hi_cont_base_amount);
		hr_utility.trace(' .       l_ee_taxable_cont           : '||l_ee_taxable_cont);
		hr_utility.trace(' .       l_er_taxable_cont           : '||l_er_taxable_cont);
		hr_utility.trace(' .       l_ee_thrhld_rate           : '||l_ee_thrhld_rate);
                hr_utility.trace(' .       l_er_thrhld_rate           : '||l_er_thrhld_rate);
                hr_utility.trace(' .       l_tax_thrhld_amount           : '||l_tax_thrhld_amount);
                hr_utility.trace(' =======================================================');
        END IF;



---------------------------------------------------------------------------------------------
/* Start Bug 5563042 (PHF and SI Enhancements), started from 1-Jan-2006 */
---------------------------------------------------------------------------------------------
   IF (p_date_earned >= TO_DATE('01-01-2006','DD-MM-YYYY')) THEN
	IF (p_phf_si_type IN ('PHF','PENSION','MEDICAL','UNEMPLOYMENT')) THEN
		l_ee_hi_cont_type           := p_ee_hi_cont_type;
		l_er_hi_cont_type           := p_er_hi_cont_type;
		l_ee_hi_cont_amt            := p_ee_hi_cont_amt;
		l_er_hi_cont_amt            := p_er_hi_cont_amt;
		l_ee_hi_cont_base_meth      := p_ee_hi_cont_base_meth;
		l_er_hi_cont_base_meth      := p_er_hi_cont_base_meth;
		l_ee_hi_cont_base_amount    := p_ee_hi_cont_base_amount;
		l_er_hi_cont_base_amount    := p_er_hi_cont_base_amount;

               /*  removed the parameter p_phf_high_lim_exemp as it is not required now */
		l_message:=
			calculate_cont_jan_2006(
				 p_date_earned               => p_date_earned
				,p_phf_si_type               => p_phf_si_type
				,p_ee_rate                   => l_ee_rate
				,p_er_rate                   => l_er_rate
				,p_ee_rate_type              => l_ee_rate_type
				,p_er_rate_type              => l_er_rate_type
				,p_ee_cont_base_method       => l_ee_cont_base_method
				,p_er_cont_base_method       => l_er_cont_base_method
				,p_ee_fixed_amount           => l_ee_fixed_amount
				,p_er_fixed_amount           => l_er_fixed_amount
				,p_phf_si_earnings_asg_ptd   => l_phf_si_earnings_asg_ptd
				,p_phf_si_earnings_asg_pmth  => l_phf_si_earnings_asg_pmth
				,p_phf_si_earnings_asg_pyear => l_phf_si_earnings_asg_pyear
				,p_average_salary            => l_average_salary
				,p_lowest_avg_salary         => l_lowest_avg_salary
				,p_ee_rate_rounding_method   => l_ee_rate_rounding_method
				,p_er_rate_rounding_method   => l_er_rate_rounding_method
				,p_ee_hi_cont_type           => l_ee_hi_cont_type
				,p_er_hi_cont_type           => l_er_hi_cont_type
				,p_ee_hi_cont_amt            => l_ee_hi_cont_amt
				,p_er_hi_cont_amt            => l_er_hi_cont_amt
				,p_ee_hi_cont_base_meth      => l_ee_hi_cont_base_meth
				,p_er_hi_cont_base_meth      => l_er_hi_cont_base_meth
				,p_ee_hi_cont_base_amount    => l_ee_hi_cont_base_amount
				,p_er_hi_cont_base_amount    => l_er_hi_cont_base_amount
				,p_ee_phf_si_amount          => l_ee_phf_si_amount
				,p_er_phf_si_amount          => l_er_phf_si_amount
				,p_ee_taxable_cont           => l_ee_taxable_cont
				,p_er_taxable_cont           => l_er_taxable_cont
				,p_ee_cont_base_amount       => l_ee_cont_base_amount
				,p_er_cont_base_amount       => l_er_cont_base_amount
				,p_ee_tax_thrhld_rate        => l_ee_thrhld_rate -- added for bug 6828199
				,p_er_tax_thrhld_rate        => l_er_thrhld_rate -- added for bug 6828199
				,p_tax_thrhld_amount         => l_tax_thrhld_amount -- added for bug 6828199

				);

		IF l_message <> 'SUCCESS' THEN
			hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 220);
			RETURN l_message;
		END IF;
	END IF;
   END IF;

/* Changes for bug 8838185 start */
	    l_new_ee_cont_base_amount := l_ee_cont_base_amount - l_ee_cont_base_asg_ltd;
	    l_new_er_cont_base_amount := l_er_cont_base_amount - l_er_cont_base_asg_ltd;
/* Changes for bug 8838185 end */

---------------------------------------------------------------------------------------------
/* End Bug 5563042 (PHF and SI Enhancements) */
---------------------------------------------------------------------------------------------

--
-- Verification of Deferred Amounts starts here
--

  --
  -- Step 1: Get the various DBIs
  --
    pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));
    pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);

    l_actual_probation_end_date:= fnd_date.canonical_to_date(
                                   pay_balance_pkg.run_db_item('CTR_CN_ACTUAL_PROBATION_END_DATE',p_business_group_id,'CN'));

    l_const_probation_end_date:= fnd_date.canonical_to_date(
                                   pay_balance_pkg.run_db_item('CTR_CN_CONST_PROBATION_END_DATE',p_business_group_id,'CN'));

    l_defer_deductions := pay_balance_pkg.run_db_item('PER_EMPLOYER_INFO_CN_ORG_DEFER_DEDUCTIONS',p_business_group_id,'CN');

    l_deduct_in_probation_expiry := pay_balance_pkg.run_db_item('PER_EMPLOYER_INFO_CN_ORG_DEDUCT_IN_PROBATION_EXPIRY',p_business_group_id,'CN');

    l_message := get_phf_si_deferred_amounts
               (p_pay_proc_period_end_date     => p_pay_proc_period_end_date
	           ,p_actual_probation_end_date    => NVL(l_actual_probation_end_date,g_start_date)
	           ,p_const_probation_end_date     => NVL(l_const_probation_end_date,g_start_date)
	           ,p_defer_deductions             => NVL(l_defer_deductions,'N')
	           ,p_deduct_in_probation_expiry   => NVL(l_deduct_in_probation_expiry,'Y')
	           ,p_taxable_earnings_asg_er_ptd  => l_taxable_earnings_asg_er_ptd
--
	           ,p_ee_phf_si_amount             => l_ee_phf_si_amount
	           ,p_er_phf_si_amount             => l_er_phf_si_amount
               ,p_undeducted_ee_phf_ltd        => l_undeducted_ee_asg_ltd
               ,p_undeducted_er_phf_ltd        => l_undeducted_er_asg_ltd
	       );

     IF l_message <> 'SUCCESS' THEN
       l_ee_phf_si_amount := 0;
       hr_cn_api.set_location(g_debug,' Leaving : '||g_procedure_name, 285);
       RETURN l_message;
     END IF;

--
-- Verification of Deferred Amounts ends here
--

--
-- In case there is a previous run, subtract the PHF/SI amounts if any
--
    IF g_debug THEN
       hr_utility.trace(' ====================================================================');
       hr_utility.trace(' EE PHF SI Amount (RUN)            : '|| l_ee_phf_si_amount);
       hr_utility.trace(' ER PHF SI Amount (RUN)            : '|| l_er_phf_si_amount);
       hr_utility.trace(' EE PHF SI Amount (PTD)            : '|| l_ee_deductions_asg_er_ptd);
       hr_utility.trace(' ER PHF SI Amount (PTD)            : '|| l_er_deductions_asg_er_ptd);
       hr_utility.trace(' Undeducted EE PHF SI Amount (PTD) : '|| l_undeducted_ee_asg_er_ptd);
       hr_utility.trace(' Undeducted ER PHF SI Amount (PTD) : '|| l_undeducted_er_asg_er_ptd);
    END IF;

    l_ee_phf_si_amount:= l_ee_phf_si_amount - l_ee_deductions_asg_er_ptd - l_undeducted_ee_asg_er_ptd;
    l_er_phf_si_amount:= l_er_phf_si_amount - l_er_deductions_asg_er_ptd - l_undeducted_er_asg_er_ptd;
    l_ee_taxable_cont := l_ee_taxable_cont - p_lt_ee_taxable_cont_ptd;
    l_er_taxable_cont := l_er_taxable_cont - p_lt_er_taxable_cont_ptd;

    IF g_debug THEN
       hr_utility.trace(' EE PHF SI Amount (Final)          : '|| l_ee_phf_si_amount);
       hr_utility.trace(' ER PHF SI Amount (Final)          : '|| l_er_phf_si_amount);
       hr_utility.trace(' ====================================================================');
    END IF;
--

-- Finally set all the output variables
--
    p_ee_phf_si_amount            := l_ee_phf_si_amount;
    p_er_phf_si_amount            := l_er_phf_si_amount;
    p_undeducted_ee_phf_si_amount := l_undeducted_ee_asg_ltd;
    p_undeducted_er_phf_si_amount := l_undeducted_er_asg_ltd;
    p_new_ee_cont_base_amount	  := l_new_ee_cont_base_amount;
    p_new_er_cont_base_amount	  := l_new_er_cont_base_amount;
    p_ee_cont_base_amount	  := l_ee_cont_base_amount;
    p_er_cont_base_amount         := l_er_cont_base_amount;
    p_calculation_date            := l_calculation_date;
    p_ee_taxable_cont             := l_ee_taxable_cont;
    p_er_taxable_cont             := l_er_taxable_cont;

    IF g_debug THEN
       hr_utility.trace(' ====================================================================');
       hr_utility.trace(' Calculation Date                  : '|| p_calculation_date);
       hr_utility.trace(' Employee PHF SI Amount            : '|| p_ee_phf_si_amount);
       hr_utility.trace(' Employer PHF SI Amount            : '|| p_er_phf_si_amount);
       hr_utility.trace(' Undeducted Employee PHF SI Amount : '|| p_undeducted_ee_phf_si_amount);
       hr_utility.trace(' Undeducted Employer PHF SI Amount : '|| p_undeducted_er_phf_si_amount);
       hr_utility.trace(' Employee new cont base Amount     : '|| p_new_ee_cont_base_amount);
       hr_utility.trace(' Employer new cont base Amount     : '|| p_new_er_cont_base_amount);
       hr_utility.trace(' Employee cont base Amount         : '|| p_ee_cont_base_amount);
       hr_utility.trace(' Employer cont base Amount         : '|| p_er_cont_base_amount);
       hr_utility.trace(' =====================================================================');
    END IF;

    hr_cn_api.set_location(g_debug,' Leaving ' || g_procedure_name,300);
    RETURN l_message;


EXCEPTION
    WHEN initialize_on_error THEN
          p_calculation_date            := g_end_date;
          p_ee_phf_si_amount            := NULL;
          p_er_phf_si_amount            := NULL;
          p_new_ee_cont_base_amount     := NULL;
          p_new_er_cont_base_amount     := NULL;
          p_undeducted_ee_phf_si_amount := NULL;
          p_undeducted_er_phf_si_amount := NULL;
          RETURN l_message;
   WHEN OTHERS THEN
          p_calculation_date            := g_end_date;
          p_ee_phf_si_amount            := NULL;
          p_er_phf_si_amount            := NULL;
          p_new_ee_cont_base_amount     := NULL;
          p_new_er_cont_base_amount     := NULL;
          p_undeducted_ee_phf_si_amount := NULL;
          p_undeducted_er_phf_si_amount := NULL;
          l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
          RETURN l_message;
END calculate_contribution;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_CONT_BASE_SETUP                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to Check the Contribution Base Setup      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_organization_id          NUMBER                   --
--                  p_contribution_area        VARCHAR2                 --
--                  p_phf_si_type              VARCHAR2                 --
--                  p_hukou_type               VARCHAR2                 --
--                  p_ee_cont_base_method      VARCHAR2                 --
--                  p_er_cont_base_method      VARCHAR2                 --
--                  p_low_limit_method         VARCHAR2                 --
--                  p_low_limit_amount         NUMBER                 --
--       	        p_high_limit_method        VARCHAR2		            --
--		            p_high_limit_amount        NUMBER		            --
--		            p_switch_periodicity       VARCHAR2		            --
--		            p_switch_month             VARCHAR2		            --
--		            p_rounding_method          VARCHAR2		            --
--		            p_lowest_avg_salary        NUMBER		            --
--		            p_average_salary           NUMBER		            --
--		            p_ee_fixed_amount          NUMBER		            --
--		            p_er_fixed_amount          NUMBER			        --
--		            p_effective_start_date     DATE    			        --
--		            p_effective_end_date       DATE    			        --
--        IN/ OUT :                                                     --
--           OUT :  p_message_name    NOCOPY VARCHAR2                   --
--		            p_token_name      NOCOPY hr_cn_api.char_tab_type    --
--		            p_token_value     NOCOPY hr_cn_api.char_tab_type    --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15-MAR-05  snekkala  Created this Procedure                    --
-- 1.1   28-Apr-05  snekkala  Modified validation for er cont base      --
--                            method from ee to er                      --
--------------------------------------------------------------------------
PROCEDURE check_cont_base_setup
          (p_organization_id         IN NUMBER
          ,p_contribution_area       IN VARCHAR2
          ,p_phf_si_type             IN VARCHAR2
          ,p_hukou_type              IN VARCHAR2
          ,p_ee_cont_base_method     IN VARCHAR2
          ,p_er_cont_base_method     IN VARCHAR2
          ,p_low_limit_method        IN VARCHAR2
          ,p_low_limit_amount        IN NUMBER
          ,p_high_limit_method       IN VARCHAR2
          ,p_high_limit_amount       IN NUMBER
          ,p_switch_periodicity      IN VARCHAR2
          ,p_switch_month            IN VARCHAR2
          ,p_rounding_method         IN VARCHAR2
          ,p_lowest_avg_salary       IN NUMBER
          ,p_average_salary          IN NUMBER
          ,p_ee_fixed_amount         IN NUMBER
          ,p_er_fixed_amount         IN NUMBER
          ,p_effective_start_date    IN DATE
          ,p_effective_end_date      IN DATE
          ,p_message_name            OUT NOCOPY VARCHAR2
          ,p_token_name              OUT NOCOPY hr_cn_api.char_tab_type
          ,p_token_value             OUT NOCOPY hr_cn_api.char_tab_type
          )
AS

  l_flag                BOOLEAN;
  l_return_segment      VARCHAR2(30);
  l_indep_seg           fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
  l_dep_seg             fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
  l_lookup_meaning      hr_lookups.meaning%TYPE;
  l_lookup_meaning_dep  hr_lookups.meaning%TYPE;


BEGIN

     p_message_name := 'HR_374615_INCOMPLETE_CONT_BASE';
     p_token_name(1) := 'INDEP_SEG';
     p_token_name(2) := 'INDEP_VALUE';
     p_token_name(3) := 'DEP_SEG';
     p_token_name(4) := 'DEP_VALUE';

     l_flag := validate_switch_with_cont_base
                (p_cont_base_method      => p_ee_cont_base_method
                ,p_switch_periodicity    => p_switch_periodicity
                );

     IF NOT l_flag THEN

	hr_utility.trace('Invalid Contribution Base Setup');

	l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Switch Period Periodicity'
	                                          ,p_dff              => 'Org Developer DF'
		                                      ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                                 );

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'EE Cont Base Method'
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                     );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_SWITCH_PERIODICITY'
	                                             ,p_lookup_code => p_switch_periodicity
					                              );

         l_lookup_meaning_dep := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_CALC_METHOD'
 	                                                     ,p_lookup_code => p_ee_cont_base_method
					                 );

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

     END IF;

     l_flag := validate_cont_base_method(p_cont_base_method   => p_ee_cont_base_method
                                       ,p_fixed_amount        => p_ee_fixed_amount
                                       ,p_lowest_avg_salary   => p_lowest_avg_salary
                                       ,p_average_salary      => p_average_salary
				                       ,p_return_segment      => l_return_segment
                                       );

     IF NOT l_flag THEN

         l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'EE Cont Base Method'
	                                              ,p_dff              => 'Org Developer DF'
		                                          ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                                       );

	 IF l_return_segment = 'Fixed Amount' THEN
	    l_return_segment := 'EE Fixed Amount';
         END IF;

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => l_return_segment
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                     );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_CALC_METHOD'
	                                             ,p_lookup_code => p_ee_cont_base_method
					             );

	 l_lookup_meaning_dep := 'NULL';

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

   END IF;

   l_flag := validate_switch_with_cont_base
                (p_cont_base_method      => p_er_cont_base_method
                ,p_switch_periodicity    => p_switch_periodicity
                );

   IF NOT l_flag THEN

 	 l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Switch Period Periodicity'
	                                          ,p_dff              => 'Org Developer DF'
		                                      ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                                  );

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'ER Cont Base Method'
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                    );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_SWITCH_PERIODICITY'
	                                             ,p_lookup_code => p_switch_periodicity
					                              );

         l_lookup_meaning_dep := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_CALC_METHOD'
 	                                                     ,p_lookup_code => p_er_cont_base_method
					                 );

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

   END IF;

   l_flag := validate_cont_base_method(p_cont_base_method   => p_er_cont_base_method
                                      ,p_fixed_amount        => p_er_fixed_amount
                                      ,p_lowest_avg_salary   => p_lowest_avg_salary
                                      ,p_average_salary      => p_average_salary
                                      ,p_return_segment      => l_return_segment
                                       );

    IF NOT l_flag  THEN

         l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'ER Cont Base Method'
	                                              ,p_dff              => 'Org Developer DF'
		                                          ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                          );

	 IF l_return_segment = 'Fixed Amount' THEN
	    l_return_segment := 'EE Fixed Amount';
         END IF;

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => l_return_segment
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                 );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_CALC_METHOD'
	                                             ,p_lookup_code => p_er_cont_base_method
					             );

	 l_lookup_meaning_dep := 'NULL';

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

   END IF;

   IF p_low_limit_method <> 'N/A' THEN


      l_flag := validate_low_limit_method(p_low_limit_method    => p_low_limit_method
                                         ,p_fixed_amount        => p_low_limit_amount
                                         ,p_lowest_avg_salary   => p_lowest_avg_salary
                                         ,p_average_salary      => p_average_salary
		                                 ,p_return_segment      => l_return_segment
                                         );

      IF NOT l_flag THEN


         l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Low Limit Method'
	                                              ,p_dff              => 'Org Developer DF'
		                                          ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                                      );

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => l_return_segment
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                     );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_LOW_LIMIT'
	                                             ,p_lookup_code => p_low_limit_method
					             );

	 l_lookup_meaning_dep := 'NULL';

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

      END IF;

   END IF;

   IF p_high_limit_method <> 'N/A' THEN


      l_flag := validate_high_limit_method(p_high_limit_method   => p_high_limit_method
                                          ,p_fixed_amount        => p_high_limit_amount
                                          ,p_average_salary      => p_average_salary
	                                      ,p_return_segment      => l_return_segment
                                          );

     IF NOT l_flag  THEN

         l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'High Limit Method'
	                                              ,p_dff              => 'Org Developer DF'
		                                          ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                          );

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => l_return_segment
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                     );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_CONT_BASE_HIGH_LIMIT'
	                                             ,p_lookup_code => p_high_limit_method
					             );

	 l_lookup_meaning_dep := 'NULL';

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

	 RETURN;

      END IF;

   END IF;

   IF p_switch_periodicity = 'YEARLY' AND p_switch_month IS NULL THEN

	 l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Switch Period Periodicity'
	                                          ,p_dff              => 'Org Developer DF'
		                                      ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
			                                  );

	 l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Switch Period Month'
	                                        ,p_dff              => 'Org Developer DF'
		                                    ,p_dff_context_code => 'PER_CONT_AREA_CONT_BASE_CN'
		                                     );

	 l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_SWITCH_PERIODICITY'
	                                             ,p_lookup_code => p_switch_periodicity
					             );

	 l_lookup_meaning_dep := 'NULL';

	 p_token_value(1) := l_indep_seg;
	 p_token_value(2) := l_lookup_meaning;
	 p_token_value(3) := l_dep_seg;
	 p_token_value(4) := l_lookup_meaning_dep;

         RETURN;

   END IF;

   p_message_name := 'SUCCESS';

END check_cont_base_setup;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PHF_SI_RATES_SETUP                            --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to Check the Contribution Base Setup      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_organization_id          NUMBER                   --
--                  p_contribution_area        VARCHAR2                 --
--                  p_phf_si_type              VARCHAR2                 --
--                  p_hukou_type               VARCHAR2                 --
--		            p_effective_start_date     DATE    			        --
--		            p_effective_end_date       DATE    			        --
--        IN/ OUT :                                                     --
--           OUT :  p_message_name    NOCOPY VARCHAR2                   --
--		            p_token_name      NOCOPY hr_cn_api.char_tab_type    --
--		            p_token_value     NOCOPY hr_cn_api.char_tab_type    --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   15-MAR-05  snekkala  Created this Procedure                    --
-- 1.1   12-May-08  dduvvuri  Bug 6943573 - commented the code as no checking is required now
--------------------------------------------------------------------------
PROCEDURE check_phf_si_rates_setup
          (p_organization_id         IN NUMBER
          ,p_contribution_area       IN VARCHAR2
          ,p_organization            IN VARCHAR2
          ,p_phf_si_type             IN VARCHAR2
          ,p_hukou_type              IN VARCHAR2
          ,p_effective_start_date    IN DATE
          ,p_effective_end_date      IN DATE
          ,p_message_name            OUT NOCOPY VARCHAR2
          ,p_token_name              OUT NOCOPY hr_cn_api.char_tab_type
          ,p_token_value             OUT NOCOPY hr_cn_api.char_tab_type
          )
AS

  l_indep_seg           fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
  l_dep_seg             fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE;
  l_lookup_meaning      hr_lookups.meaning%TYPE;
  l_lookup_meaning_dep  hr_lookups.meaning%TYPE;

BEGIN

   p_message_name := 'SUCCESS';

   -- Code commented for bug 6943573
   /*
     IF p_hukou_type IS NOT NULL AND p_organization IS NULL THEN
     l_indep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Hukou Type'
                                              ,p_dff              => 'Org Developer DF'
     	                                      ,p_dff_context_code => 'PER_CONT_AREA_PHF_SI_RATES_CN'
	       			              );

     l_dep_seg := hr_cn_api.get_dff_tl_value(p_column_name      => 'Organization'
		                                    ,p_dff              => 'Org Developer DF'
			                                ,p_dff_context_code => 'PER_CONT_AREA_PHF_SI_RATES_CN'
			                    );

     l_lookup_meaning := hr_general.decode_lookup(p_lookup_type => 'CN_HUKOU_TYPE'
	       	                                 ,p_lookup_code => p_hukou_type
	       					 );

     l_lookup_meaning_dep := 'NULL';

     p_message_name := 'HR_374616_INVALID_PHF_SI_INFO';
     p_token_name(1) := 'INDEP_SEG';
     p_token_name(2) := 'INDEP_VALUE';
     p_token_name(3) := 'DEP_SEG';
     p_token_name(4) := 'DEP_VALUE';
     p_token_value(1) := l_indep_seg;
     p_token_value(2) := l_lookup_meaning;
     p_token_value(3) := l_dep_seg;
     p_token_value(4) := l_lookup_meaning_dep;

   END IF;
    */

END check_phf_si_rates_setup;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_EARNINGS                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get PYEAR and PMTH values for PHF/SI Earnings --
--                  Called from all 8 PHF/SI formulas                   --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   31-MAR-09  dduvvuri  8328944 - Created this Function           --
--------------------------------------------------------------------------

FUNCTION get_phf_si_earnings
               ( p_business_group_id         IN NUMBER
                ,p_assignment_id             IN NUMBER
                ,p_date_earned               IN DATE
                ,p_pay_proc_period_end_date  IN DATE
                ,p_employer_id               IN VARCHAR2
                ,p_phf_si_earnings_pyear  IN OUT NOCOPY NUMBER
                ,p_phf_si_earnings_pmth   IN OUT NOCOPY NUMBER
                ,p_contribution_area         IN VARCHAR2
                ,p_phf_si_type               IN VARCHAR2
                ,p_hukou_type                IN VARCHAR2
               )
RETURN VARCHAR2
IS
l_message     VARCHAR2(255);
l_dimension   VARCHAR2(10);

l_ee_cont_base_method        hr_organization_information.org_information1%type;
l_er_cont_base_method        hr_organization_information.org_information1%type;
l_low_limit_method           hr_organization_information.org_information1%type;
l_low_limit_amount           NUMBER   ;
l_high_limit_method          hr_organization_information.org_information1%type;
l_high_limit_amount          NUMBER   ;
l_switch_periodicity         hr_organization_information.org_information1%type;
l_switch_month               hr_organization_information.org_information1%type;
l_rounding_method            hr_organization_information.org_information1%type;
l_lowest_avg_salary          NUMBER   ;
l_average_salary             NUMBER   ;
l_ee_fixed_amount            NUMBER   ;
l_er_fixed_amount            NUMBER   ;
l_tax_thrhld_amount          NUMBER   ;
l_temp_date                  DATE;
l_temp_year                  NUMBER;
l_asg_yr_action_id              NUMBER := NULL;
l_pay_runs_prev_yr           NUMBER;
l_asg_mth_action_id              NUMBER := NULL;

initialize_on_error     EXCEPTION;

/* cursor to fetch the latest asg action id in the target year from Jan to Dec */
CURSOR get_prev_yr_asg_act_id(c_assignment_id IN NUMBER,c_date IN DATE) IS
select  /*+ORDERED*/ to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
from    pay_assignment_actions      paa
,       pay_payroll_actions         ppa
where   paa.assignment_id           = c_assignment_id
    and ppa.payroll_action_id   = paa.payroll_action_id
    and ppa.effective_date      <= trunc(c_date,'Y') - 1
    and ppa.effective_date      >= trunc(add_months(c_date,-12),'Y')
    and ppa.action_type         in ('R', 'Q', 'I', 'V', 'B')
    and paa.action_status='C'
    and ppa.action_status='C'
    and paa.tax_unit_id = p_employer_id;

/* cursor to fetch the latest asg action id in the target month */
CURSOR get_prev_mth_asg_act_id(c_assignment_id IN NUMBER,c_date IN DATE) IS
select  /*+ORDERED*/ to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
from    pay_assignment_actions      paa
,       pay_payroll_actions         ppa
where   paa.assignment_id           = c_assignment_id
    and ppa.payroll_action_id   = paa.payroll_action_id
    and ppa.effective_date      <= c_date - 1
    and ppa.effective_date      >= add_months(c_date,-1)
    and ppa.action_type         in ('R', 'Q', 'I', 'V', 'B')
    and paa.action_status='C'
    and ppa.action_status='C'
    and paa.tax_unit_id = p_employer_id;

BEGIN
 l_message := 'SUCCESS';
 l_dimension := 'PYEAR';
     /* useful for fetching the switch periodicity and the switch month. other fetched details
        can be ignored here as they will not be used elsewhere in scope of the function*/
     l_message := get_cont_base_methods
                               (p_business_group_id           => p_business_group_id
                               ,p_contribution_area           => p_contribution_area
                               ,p_phf_si_type                 => p_phf_si_type
                               ,p_hukou_type                  => p_hukou_type
                               ,p_effective_date              => p_pay_proc_period_end_date
                               --
                               ,p_ee_cont_base_method         => l_ee_cont_base_method
                               ,p_er_cont_base_method         => l_er_cont_base_method
                               ,p_low_limit_method            => l_low_limit_method
                               ,p_low_limit_amount            => l_low_limit_amount
                               ,p_high_limit_method           => l_high_limit_method
                               ,p_high_limit_amount           => l_high_limit_amount
                               ,p_switch_periodicity          => l_switch_periodicity
                               ,p_switch_month                => l_switch_month
                               ,p_rounding_method             => l_rounding_method
                               ,p_lowest_avg_salary           => l_lowest_avg_salary
                               ,p_average_salary              => l_average_salary
                               ,p_ee_fixed_amount             => l_ee_fixed_amount
                               ,p_er_fixed_amount             => l_er_fixed_amount
                               ,p_tax_thrhld_amount           => l_tax_thrhld_amount
                               );

     hr_utility.trace(' get_cont_base_method : Message=>' || l_message);

     IF l_message <> 'SUCCESS'
     THEN
          hr_cn_api.set_location(g_debug,' ' || g_procedure_name, 10);
	  RAISE initialize_on_error;
     END IF;

     IF l_switch_periodicity = 'YEARLY' THEN
         l_temp_date := TO_DATE('01-'||l_switch_month ||'-'||TO_CHAR(p_pay_proc_period_end_date,'YYYY'),'DD-MM-YYYY');
         IF p_pay_proc_period_end_date = last_day(l_temp_date)  OR p_pay_proc_period_end_date > l_temp_date THEN
             null;
	     /* Target year is previous year of year in the l_temp_date */
         ELSE
             l_temp_date := add_months(l_temp_date,-12);
	     /* Target year is 2 years previous of year in the l_temp_date */
         END IF;
     ELSE
         /* Contribution Base recalculated in every month */
         l_temp_date := TO_DATE('01-'||TO_CHAR(p_pay_proc_period_end_date,'MM')||'-'||TO_CHAR(p_pay_proc_period_end_date,'YYYY'),'DD-MM-YYYY');
     END IF;


         OPEN get_prev_yr_asg_act_id(p_assignment_id,l_temp_date);
         FETCH get_prev_yr_asg_act_id INTO l_asg_yr_action_id;
         CLOSE get_prev_yr_asg_act_id;

         OPEN get_prev_mth_asg_act_id(p_assignment_id,l_temp_date);
         FETCH get_prev_mth_asg_act_id INTO l_asg_mth_action_id;
         CLOSE get_prev_mth_asg_act_id;

	 hr_utility.trace('Asg Year Action ID' || l_asg_yr_action_id);
	 hr_utility.trace('Asg Mth Action ID' || l_asg_mth_action_id);

         IF l_asg_yr_action_id IS NULL THEN
         /* No latest assignment action exists for the target span */
            p_phf_si_earnings_pyear := 0;
         ELSE
         /* call pay_balance_pkg and fetch the value of the PHF_SI_EARNINGS YTD dimension */
           p_phf_si_earnings_pyear := pay_balance_pkg.get_value
                    (p_defined_balance_id   => get_def_bal_id('PHF SI Earnings','_ASG_YTD')
                    ,p_assignment_action_id => l_asg_yr_action_id
                    ,p_tax_unit_id          => p_employer_id
                    ,p_jurisdiction_code    => NULL
                    ,p_source_id            => NULL
                    ,p_source_text          => NULL
                    ,p_tax_group            => NULL
                    ,p_date_earned          => NULL
                    ,p_get_rr_route         => NULL
                    ,p_get_rb_route         => 'TRUE');
          hr_utility.trace('PHF/SI Earnings Prev Yr' || p_phf_si_earnings_pyear);

              pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_temp_date));
              pay_balance_pkg.set_context('ASSIGNMENT_ID',p_assignment_id);
              l_pay_runs_prev_yr := fnd_number.canonical_to_number(
                                              pay_balance_pkg.run_db_item('CN_PAYROLL_RUN_MONTHS_PREV_YEAR',p_business_group_id,'CN'));
              hr_utility.trace('Payroll runs Prev Yr' || l_pay_runs_prev_yr);
              p_phf_si_earnings_pyear := p_phf_si_earnings_pyear / l_pay_runs_prev_yr ;
         END IF;

	 IF l_asg_mth_action_id IS NULL THEN
         /* No latest assignment action exists for the target month */
            p_phf_si_earnings_pmth := 0;
         ELSE
         /* call pay_balance_pkg and fetch the value of the PHF_SI_EARNINGS MTD dimension */
           p_phf_si_earnings_pmth := pay_balance_pkg.get_value
                    (p_defined_balance_id   => get_def_bal_id('PHF SI Earnings','_ASG_MTD')
                    ,p_assignment_action_id => l_asg_mth_action_id
                    ,p_tax_unit_id          => p_employer_id
                    ,p_jurisdiction_code    => NULL
                    ,p_source_id            => NULL
                    ,p_source_text          => NULL
                    ,p_tax_group            => NULL
                    ,p_date_earned          => NULL
                    ,p_get_rr_route         => NULL
                    ,p_get_rb_route         => 'TRUE');
            hr_utility.trace('PHF/SI Earnings Prev Mth' || p_phf_si_earnings_pmth);
         END IF;


 return l_message;

EXCEPTION
   WHEN initialize_on_error THEN
   l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
   WHEN OTHERS THEN
   l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||g_procedure_name, 'SQLERRMC:'||sqlerrm);
END get_phf_si_earnings;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_YOS_SEV_PAY_TAX_RULE                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get Severance Pay Taxation rule from BG level --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   24-aug-09  dduvvuri  8799060 - Created this Function           --
-- 1.1   26-aug-09  dduvvuri  8799060 - Modified the cursor             --
--------------------------------------------------------------------------
FUNCTION get_yos_sev_pay_tax_rule (
                                  p_date_earned                IN  DATE
                                , p_tax_area                   IN  VARCHAR2
                                )
RETURN VARCHAR2
IS
 l_use_yos_option varchar2(2);

    CURSOR get_rule( p_date_earned             DATE
                  , p_tax_area                VARCHAR2
                   ) IS
      SELECT hoi.org_information2
      FROM   hr_organization_information hoi
      WHERE  hoi.org_information_context = 'PER_SEVERANCE_PAY_TAX_RULE_CN'
      AND    hoi.org_information1        = p_tax_area
      AND    hoi.organization_id         = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
      AND    p_date_earned  BETWEEN to_date(substr(hoi.org_information3,1,10),'YYYY/MM/DD')
      AND    to_date(NVL(substr(hoi.org_information4,1,10),'4712/12/31'),'YYYY/MM/DD');

BEGIN

    l_use_yos_option := null;

    hr_utility.trace('YOS Option' || l_use_yos_option );

    OPEN get_rule(  p_date_earned
    	        , p_tax_area
	        );
    FETCH get_rule INTO l_use_yos_option;
    CLOSE get_rule;

    IF l_use_yos_option is null then
     l_use_yos_option := 'N';
    END IF;

    hr_utility.trace('YOS Option' || l_use_yos_option );

    RETURN l_use_yos_option;

EXCEPTION
 WHEN OTHERS THEN
    null;
END  get_yos_sev_pay_tax_rule;

END pay_cn_deductions;

/
