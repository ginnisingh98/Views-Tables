--------------------------------------------------------
--  DDL for Package Body PAY_IN_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_TERMINATION_PKG" as
/* $Header: pyinterm.pkb 120.24.12010000.4 2010/03/12 07:30:41 mdubasi ship $ */

  g_package          CONSTANT VARCHAR2(100) := 'pay_in_termination_pkg.' ;
  g_debug            BOOLEAN ;
  g_legislation_code CONSTANT VARCHAR2(2) := 'IN';

  g_assignment_id    per_assignments_f.assignment_id%TYPE;
  g_payroll_id       pay_payrolls_f.payroll_id%TYPE;
  g_hire_date        per_people_f.start_date%TYPE;
  g_notified_date    per_periods_of_service.NOTIFIED_TERMINATION_DATE%TYPE;

  g_notice_et        CONSTANT VARCHAR2(80):= 'Notice Period Information';
  g_notice_cn        CONSTANT VARCHAR2(80):= 'Notice Period Pay';
  g_retrenchment_et  CONSTANT VARCHAR2(80):= 'Retrenchment Compensation Information';
  g_retrenchment_cn  CONSTANT VARCHAR2(80):= 'Retrenchment';
  g_vrs_et           CONSTANT VARCHAR2(80):= 'Voluntary Retirement Information';
  g_vrs_cn           CONSTANT VARCHAR2(80):= 'Voluntary Retirement';
  g_pension_et       CONSTANT VARCHAR2(80):= 'Commuted Pension Information';
  g_pension_cn       CONSTANT VARCHAR2(80):= 'Commuted Pension';
  g_pf_et            CONSTANT VARCHAR2(80):= 'PF Settlement Information';
  g_pf_cn            CONSTANT VARCHAR2(80):= 'PF Settlement';
  g_loan_et          CONSTANT VARCHAR2(80):= 'Loan Recovery';
  g_loan_cn          CONSTANT VARCHAR2(80):= 'Loan Recovery';
  g_gratuity_et      CONSTANT VARCHAR2(80):= 'Gratuity Information';
  g_gratuity_cn      CONSTANT VARCHAR2(80):= 'Gratuity';

  TYPE t_input_values_rec IS RECORD
          (input_name      pay_input_values_f.name%TYPE
          ,input_value_id  pay_input_values_f.input_value_id%TYPE);

  TYPE t_entry_values_rec IS RECORD
          (entry_value     pay_element_entry_values.screen_entry_value%TYPE);

  TYPE t_input_values_tab IS TABLE OF t_input_values_rec
     INDEX BY BINARY_INTEGER;

  TYPE t_entry_values_tab IS TABLE OF t_entry_values_rec
     INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
-- Name           : check_notice_period                                 --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id        NUMBER                     --
--                  p_org_info_type_code     VARCHAR2                   --
--                  p_emp_category           VARCHAR2                   --
--                  p_notice_period          VARCHAR2                   --
--                  p_calling_procedure      VARCHAR2                   --
--            OUT : p_message_name           VARCHAR2                   --
--                  p_token_name             pay_in_utils.char_tab_type --
--                  p_token_value            pay_in_utils.char_tab_type --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27-Oct-04  statkar   Created this procedure                    --
-- 1.1   23-Nov-04  rpalli    Modified the "check for uniqueness"	--
--			      functionality to work for updations	--
--			      Bug Fix :3951465				--
--------------------------------------------------------------------------
PROCEDURE check_notice_period
          (p_organization_id     IN NUMBER
          ,p_org_information_id  IN NUMBER
          ,p_org_info_type_code  IN VARCHAR2
	      ,p_emp_category        IN VARCHAR2
      	  ,p_notice_period       IN VARCHAR2
	      ,p_calling_procedure   IN VARCHAR2
    	  ,p_message_name        OUT NOCOPY VARCHAR2
    	  ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
	      ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type)
IS

   l_procedure  VARCHAR2(100);
   l_message    VARCHAR2(255);
   l_dummy      VARCHAR2(1);

   CURSOR c_dup_comb IS
      SELECT 'X'
      FROM   hr_organization_information
      WHERE  organization_id         = p_organization_id
      AND    org_information_context = p_org_info_type_code
      AND    org_information1        = p_emp_category
      AND    org_information_id     <> NVL(p_org_information_id,0);

BEGIN
  l_procedure := g_package ||'check_pt_frequency';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

--
-- Validations are as follows:
--
--  1. Check for mandatory parameters
--  2. Check for lookups
--  3. Check for uniqueness
--  4. Check if Start Date > End Date
--
--
  IF p_emp_category IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_EMP_CATEGORY';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_notice_period IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'P_NOTICE_PERIOD';
     RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF hr_general.decode_lookup('EMPLOYEE_CATG',p_emp_category) IS NULL THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_emp_category;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_EMP_CATEGORY';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,50);

  IF to_number(p_notice_period) > 999 THEN
      p_message_name   := 'PER_IN_INVALID_LOOKUP_VALUE';
      p_token_name(1)  := 'VALUE';
      p_token_value(1) := p_notice_period;
      p_token_name(2)  := 'FIELD';
      p_token_value(2) := 'P_NOTICE_PERIOD';
      RETURN;
  END IF;
  pay_in_utils.set_location(g_debug,l_procedure,60);

  OPEN c_dup_comb;
  FETCH c_dup_comb
  INTO l_dummy;
  IF c_dup_comb%FOUND THEN
      p_message_name := 'PER_IN_NON_UNIQUE_COMBINATION';
  END IF;
  CLOSE c_dup_comb;
  pay_in_utils.set_location(g_debug,l_procedure,70);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);

END check_notice_period;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_GRATUITY		                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate gratuity as required for India--
--                  Localization.                                       --
--                                                                      --
-- Parameters     :							--
--             IN : p_element_entry_id        NUMBER                    --
--                  p_effective_date          DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   17-Nov-04  aaagarwa  Created this procedure                    --
-- 1.1   18-Nov-04  aaagarwa  Changed the message name and cursor name in
--                            If clause.
--------------------------------------------------------------------------
PROCEDURE check_gratuity
             (p_element_entry_id        IN NUMBER
             ,p_effective_date          IN DATE
	         ,p_calling_procedure       IN VARCHAR2
    	     ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type)
IS
/* Cursor to find the element id of the current element entry */
        CURSOR c_element_type_id(p_element_entry_id NUMBER
				 ,p_effective_date  DATE)
	IS
        SELECT pet.element_type_id
        FROM pay_element_types_f pet
             ,pay_element_entries_f pee
	WHERE pet.element_type_id = pee.element_type_id
	AND pee.element_entry_id = p_element_entry_id
	AND pet.element_name = 'Gratuity Information'
	AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
	AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

/* Cursor to find the Screen entry value for Forfeiture Amount */
	CURSOR c_gratuity_forfeiture_amount(p_element_entry_id NUMBER
		  			    ,p_element_type_id NUMBER
					    ,p_effective_date  DATE)
	IS
	SELECT  'TRUE'
 	FROM  pay_element_entry_values_f peev
	     ,pay_input_values_f piv
	WHERE  peev.element_entry_id = p_element_entry_id
	AND  piv.element_Type_id = p_element_type_id
	AND  peev.input_value_id = piv.input_value_id
	AND  piv.name = 'Forfeiture Amount'
	AND  peev.screen_entry_value IS NOT NULL
	AND  p_effective_date BETWEEN piv.effective_start_date
			      AND piv.effective_end_date
	AND  p_effective_date BETWEEN peev.effective_start_date
			      AND peev.effective_end_date;



/* Cursor to find the Screen entry value for Forfeiture Reason */
	CURSOR c_gratuity_forfeiture_reason(p_element_entry_id NUMBER
		  			    ,p_element_type_id NUMBER
					    ,p_effective_date  DATE)
	IS
	SELECT 'TRUE'
	FROM  pay_element_entry_values_f peev
	     ,pay_input_values_f piv
	WHERE  peev.element_entry_id = p_element_entry_id
	AND  piv.element_Type_id = p_element_type_id
	AND  peev.input_value_id = piv.input_value_id
	AND  piv.name = 'Forfeiture Reason'
	AND  peev.screen_entry_value IS NOT NULL
	AND  p_effective_date BETWEEN piv.effective_start_date
			      AND piv.effective_end_date
	AND  p_effective_date BETWEEN peev.effective_start_date
			      AND peev.effective_end_date;

    l_procedure        VARCHAR2(100);
    l_element_type_id  NUMBER;
    l_dummy_amount     VARCHAR2(10);
    l_dummy_reason     VARCHAR2(10);

BEGIN
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package||'check_gratuity' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message(p_token_name, p_token_value);

  /* Check for Gratuity Information element*/
  OPEN  c_element_type_id(p_element_entry_id,p_effective_date);
  FETCH c_element_type_id INTO l_element_type_id;

  IF l_element_type_id IS NOT NULL THEN
     /*Element Found*/
     OPEN  c_gratuity_forfeiture_amount(p_element_entry_id,l_element_type_id,p_effective_date);
     FETCH c_gratuity_forfeiture_amount INTO l_dummy_amount;
     IF (c_gratuity_forfeiture_amount%FOUND and l_dummy_amount IS NOT NULL)THEN
     /* Amount Found*/
        OPEN  c_gratuity_forfeiture_reason(p_element_entry_id,l_element_type_id,p_effective_date);
        FETCH c_gratuity_forfeiture_reason INTO l_dummy_reason;
        /*Find Reason*/
        IF (c_gratuity_forfeiture_reason%NOTFOUND and l_dummy_reason IS NULL)THEN
	    /*Reason Not Found*/
            p_message_name := 'PER_IN_FORFEITURE_REASON';
        END IF;
       CLOSE  c_gratuity_forfeiture_reason;
     END IF;
    CLOSE  c_gratuity_forfeiture_amount;
  END IF;
  CLOSE c_element_type_id;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END check_gratuity;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : YEARS_OF_SERVICE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return the number of years of service   --
--                  for a  terminated employee.                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date_start                   DATE                 --
--                  p_act_term_date                DATE                 --
--                  p_flag                         VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar  Created this function                      --
-- 1.1   28-OCT-04  statkar  Modified to cater to Retrenchment          --
-- 1.2   01-Nov-04  statkar  Modified as per Testing Issues 3980777     --
--------------------------------------------------------------------------
FUNCTION years_of_service(p_start_date            IN DATE
                         ,p_end_date              IN DATE
                         ,p_flag                  IN VARCHAR2
                         )
RETURN NUMBER
IS
--

 l_procedure      VARCHAR2(100) ;
 l_years          NUMBER ;
 l_yrs_of_service NUMBER ;
 l_days           NUMBER ;
 l_months         NUMBER;
 l_temp_date      DATE;

--
BEGIN
--
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'years_of_service' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_years := months_between(p_end_date, p_start_date)/12 ;
  l_yrs_of_service := trunc(l_years) ;
  l_temp_date := add_months(p_start_date,l_yrs_of_service*12)-1;
  l_days := p_end_date - l_temp_date;

  IF g_debug THEN
     pay_in_utils.trace('Years ',to_char(l_years));
     pay_in_utils.trace('Yrs of Service ',to_char(l_yrs_of_service));
     pay_in_utils.trace('Days = ',to_char(l_days));
  END IF;
  --
  -- Chech IF flag is 'N', means employee is not covered
  -- under Payment of Gratuity Act, 1972
  --

  IF p_flag = 'N' THEN
  --
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
     RETURN l_yrs_of_service ;
  --
  END IF ;

  -- Check if the flag is 'R', this means that the employee's
  -- Years of Service has to be calculated for Retrenchment
  --
  IF p_flag = 'R' THEN
  --
     l_months := months_between(p_end_date, l_temp_date);

     IF g_debug THEN
        pay_in_utils.trace('Temp Date ',to_char(l_temp_date,'DD-MM-YYYY'));
        pay_in_utils.trace('Months  ',to_char(l_months));
     END IF;

     IF l_months > 6 THEN
        l_yrs_of_service := l_yrs_of_service + 1;
     END IF;
     RETURN l_yrs_of_service ;
  END IF;

  --
  -- The rest of the code is for employees covered under rule,
  -- i.e. when p_flag = Y
  --
  --
  -- Check IF employee is falling between 4-5 years of service
  --

  IF l_yrs_of_service = 4 AND l_days >= 240 THEN
  --
     pay_in_utils.set_location(g_debug,l_procedure,30);
     l_yrs_of_service := 5 ;
  --
  ELSIF l_yrs_of_service >= 5 AND l_days >= 183 THEN
  --
     pay_in_utils.set_location(g_debug,l_procedure,40);
     l_yrs_of_service := l_yrs_of_service + 1;
  --
  END IF ;
  pay_in_utils.set_location(g_debug,'Years of Service : '||l_yrs_of_service,50);
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);
  RETURN l_yrs_of_service ;

--
END years_of_service ;

------------------------------------------------------------------------------------
--                                                                                --
-- Name           : GET_AVERAGE_SALARY                                            --
-- Type           : FUNCTION                                                      --
-- Access         : Public                                                        --
-- Description    : Function to return average salary for a duration              --
--                                                                                --
-- Parameters     :                                                               --
--             IN : p_assignment_id                NUMBER                         --
--                  p_assignment_action_id         NUMBER                         --
--                  p_payroll_id                   NUMBER                         --
--                  p_balance_name                 VARCHAR2                       --
--                  p_end_date                     DATE                           --
--                  p_duration                     NUMBER                         --
--                                                                                --
--  Version     Author      Date   Bug        Description                         --
--  --------------------------------------------------------------------------------
--  1.0        vgsriniv                       Created                             --
--  1.1        rsaharay    28/02/2007 5889645 Removed cursor csr_date and csr_asg --
--                                            The asg effectivity is checked in   --
--                                            the formula itself.
------------------------------------------------------------------------------------
FUNCTION get_average_salary
     (p_assignment_id        IN NUMBER
 	 ,p_assignment_action_id IN NUMBER
	 ,p_payroll_id           IN NUMBER
	 ,p_balance_name         IN VARCHAR2
	 ,p_end_date             IN DATE
	 ,p_duration             IN NUMBER
	 )
RETURN NUMBER
IS
  l_procedure      VARCHAR2(100);

  l_asact_id        NUMBER;
  l_effective_date  DATE;
  l_date_earned     DATE;
  l_start_date      DATE;
  l_end_date        DATE;
  l_salary          NUMBER;
  l_days            NUMBER;
  l_days_in_month   NUMBER;
  l_bal_start_date  DATE;
  l_bal_end_date    DATE;
  l_total_salary    NUMBER;
  l_average_salary  NUMBER;
  l_total_divisor   NUMBER;
  i                 NUMBER;
  l_def_bal_id      NUMBER;


  CURSOR csr_tp (p_start_date DATE, p_end_date DATE)
  IS
  SELECT
     paa.assignment_action_id,
     ppa.date_earned,
     ppa.effective_date,
     ptp.start_date,
     ptp.end_date
  FROM
     per_time_periods ptp,
     pay_payroll_actions ppa,
     pay_assignment_actions paa
  WHERE ptp.payroll_id = p_payroll_id
  AND   ptp.start_date between TRUNC(p_start_date,'MM') AND  p_end_date
  AND   ptp.payroll_id = ppa.payroll_id
  AND   ptp.time_period_id = ppa.time_period_id
  AND   ppa.action_status = 'C'
  AND   ppa.action_type IN ('R','Q','I','B')
  AND   ppa.payroll_action_id = paa.payroll_action_id
  AND   paa.assignment_id = p_assignment_id
  AND   paa.source_action_id IS NULL
  UNION
  SELECT
     paa.assignment_action_id,
     ppa.date_earned,
     ppa.effective_date,
     ptp.start_date,
     ptp.end_date
  FROM
     per_time_periods ptp,
     pay_payroll_actions ppa,
     pay_assignment_actions paa
  WHERE ptp.payroll_id = p_payroll_id
  AND   ptp.payroll_id = ppa.payroll_id
  AND   ptp.time_period_id = ppa.time_period_id
  AND   ppa.payroll_action_id = paa.payroll_action_id
  AND   paa.assignment_id = p_assignment_id
  AND   paa.payroll_action_id = ppa.payroll_action_id
  AND   paa.assignment_action_id = p_assignment_action_id
  ORDER BY 2;




BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'get_average_salary' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('Payroll ID    ',to_char(p_payroll_id));
     pay_in_utils.trace('Assignment ID ',to_char(p_assignment_id));
     pay_in_utils.trace('AsAct ID      ',to_char(p_assignment_action_id));
     pay_in_utils.trace('Balance Name  ',p_balance_name);
     pay_in_utils.trace('End Date      ',to_char(p_end_date));
     pay_in_utils.trace('Duration      ',to_char(p_duration));
  END IF;

  l_bal_end_date := p_end_date;
  l_bal_start_date := add_months(l_bal_end_date,(-1)*p_duration)+1;
  l_days_in_month := 30;
  l_start_date := l_bal_start_date;
  l_end_date   := l_bal_end_date;

  l_def_bal_id  := pay_in_tax_utils.get_defined_balance (p_balance_name, '_ASG_PTD');

  l_total_salary := 0;
  l_average_salary := 0;
  l_total_divisor := 10;

  pay_in_utils.set_location(g_debug,l_procedure,20);
  IF g_debug THEN
     pay_in_utils.trace('Bal Start     ',to_char(l_bal_start_date,'DD-MM-YYYY'));
     pay_in_utils.trace('Bal End       ',to_char(l_bal_end_date,'DD-MM-YYYY'));
     pay_in_utils.trace('Def Bal ID    ',to_char(l_def_bal_id));
  END IF;



  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF g_debug THEN
     pay_in_utils.trace('Bal Start     ',to_char(l_bal_start_date,'DD-MM-YYYY'));
     pay_in_utils.trace('Bal End       ',to_char(l_bal_end_date,'DD-MM-YYYY'));
     pay_in_utils.trace('**************************************************','********************');
  END IF;

  i:=0;
  OPEN csr_tp(l_bal_start_date, l_bal_end_date);
  LOOP
     i:=i+1;
     FETCH csr_tp
     INTO l_asact_id,
          l_date_earned,
	  l_effective_date,
	  l_start_date,
	  l_end_date;
     EXIT WHEN csr_tp%NOTFOUND;

     l_days := LEAST(l_bal_end_date, l_end_date) - GREATEST(l_bal_start_date,l_start_date) + 1;
     IF l_days = l_end_date - l_start_date + 1
     THEN
        l_days := l_days_in_month;
     END IF;

     l_salary := l_days/l_days_in_month *
         pay_balance_pkg.get_value
          (p_defined_balance_id   => l_def_bal_id
	      ,p_assignment_action_id => l_asact_id
	      ,p_tax_unit_id          => NULL
	      ,p_jurisdiction_code    => NULL
	      ,p_source_id            => NULL
	      ,p_source_text          => NULL
	      ,p_tax_group            => NULL
	      ,p_date_earned          => NULL
	      ,p_get_rr_route         => 'TRUE'
	      ,p_get_rb_route         => 'FALSE');

     IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('AsActID     : '||i||' ',to_char(l_asact_id));
        pay_in_utils.trace('Date Earned : '||i||' ',to_char(l_date_earned));
        pay_in_utils.trace('Date Paid   : '||i||' ',to_char(l_effective_date));
        pay_in_utils.trace('Start Date  : '||i||' ',to_char(l_start_date));
        pay_in_utils.trace('End Date    : '||i||' ',to_char(l_end_date));
        pay_in_utils.trace('Month Days  : '||i||' ',to_char(l_days_in_month));
        pay_in_utils.trace('Days        : '||i||' ',to_char(l_days));
        pay_in_utils.trace('Salary      : '||i||' ',to_char(l_salary));
        pay_in_utils.trace('**************************************************','********************');
     END IF;
     l_total_salary := l_total_salary + l_salary;

  END LOOP;
  CLOSE csr_tp;
  pay_in_utils.set_location(g_debug,l_procedure,40);

  l_average_salary := ROUND(l_total_salary /l_total_divisor,2);
  IF g_debug THEN
      pay_in_utils.trace('Tot Salary  ',to_char(ROUND(l_total_salary,2)));
      pay_in_utils.trace('Divisor     ',to_char(ROUND(l_total_divisor,2)));
      pay_in_utils.trace('Avg Salary  ',to_char(ROUND(l_average_salary,2)));
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,100);
  RETURN l_average_salary;

END get_average_salary;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_POS_DTLS                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch ASG Details for Period of Service--
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_type_id        NUMBER                     --
--                  p_effective_date         DATE                       --
--            OUT : p_input_values           t_input_values_tab         --
--                  p_expected_entries       NUMBER                     --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
-- 1.1   25-SEP-07  rsaharay  Modified c_pos_dtls                       --
--------------------------------------------------------------------------
PROCEDURE get_pos_dtls
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_effective_date          IN DATE
	     )
IS
  CURSOR c_pos_dtls IS
     SELECT paf.assignment_id
           ,paf.payroll_id
	   ,pos.date_start
	   ,pos.leaving_reason
	   ,pos.notified_termination_date
     FROM   per_periods_of_service pos
	   ,per_assignments_f paf
	   ,per_people_f ppf
     WHERE  pos.period_of_service_id = p_period_of_service_id
     AND    pos.business_group_id    = p_business_group_id
     AND    pos.period_of_service_id = paf.period_of_service_id
     AND    paf.person_id            = ppf.person_id
     AND    p_effective_date  BETWEEN ppf.effective_start_date
                              AND     ppf.effective_end_date
     AND    p_effective_date  BETWEEN paf.effective_start_date
                              AND     paf.effective_end_date;

  l_procedure      VARCHAR2(100);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_pos_dtls' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('Period of service id ',to_char(p_period_of_service_id));
     pay_in_utils.trace('Business Group  ID   ',to_char(p_business_group_id));
     pay_in_utils.trace('Effective Date       ',to_char(p_effective_date, 'DD-MM-YYYY'));
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,20);

  OPEN c_pos_dtls;
  FETCH c_pos_dtls
  INTO  g_assignment_id, g_payroll_id, g_hire_date, g_leaving_reason, g_notified_date;
  CLOSE c_pos_dtls;

  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF g_debug THEN
        pay_in_utils.trace('Assignment ID      ',to_char(g_assignment_id));
        pay_in_utils.trace('Payroll ID         ',to_char(g_payroll_id));
        pay_in_utils.trace('Hire Date          ',to_char(g_hire_date, 'DD-MM-YYYY'));
  	    pay_in_utils.trace('Leaving Reason     ',g_leaving_reason);
	    pay_in_utils.trace('Notified Date      ',to_char(g_notified_date,'DD-MM-YYYY'));
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END get_pos_dtls;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_INPUT_VALUE_IDS                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch Input Value details for Element  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_type_id        NUMBER                     --
--                  p_effective_date         DATE                       --
--            OUT : p_input_values           t_input_values_tab         --
--                  p_expected_entries       NUMBER                     --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE get_input_value_ids
                (p_element_type_id  IN NUMBER
                ,p_effective_date   IN DATE
                ,p_expected_entries OUT NOCOPY NUMBER
                ,p_input_values     OUT NOCOPY t_input_values_tab
                ,p_business_group_id IN NUMBER)
IS

   CURSOR csr_element_inputs
   IS
   SELECT inputs.name
        , inputs.input_value_id
     FROM pay_element_types_f types
        , pay_input_values_f inputs
    WHERE types.element_type_id  = p_element_type_id
      AND inputs.element_type_id = types.element_type_id
      AND (inputs.legislation_code = g_legislation_code OR inputs.business_group_id = p_business_group_id)
      AND p_effective_date BETWEEN types.effective_start_date
                           AND types.effective_end_date
      AND p_effective_date BETWEEN inputs.effective_start_date
                           AND inputs.effective_end_date
    ORDER BY inputs.display_sequence;

  l_procedure      VARCHAR2(100);
  l_count          NUMBER;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_input_value_ids' ;

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_count := 0;

  FOR rec_input_values IN csr_element_inputs
  LOOP

     l_count := l_count+1;
     p_input_values(l_count).input_value_id := rec_input_values.input_value_id;
     pay_in_utils.trace('Input Name: ' || rec_input_values.name, '['||rec_input_values.input_value_id||']');

  END LOOP;

  p_expected_entries:= l_count;
  pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure, 20);

END get_input_value_ids;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ENTRY_DETAILS                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to fetch Element Entry details for create --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date         DATE                       --
--                  p_element_name           VARCHAR2                   --
--                  p_assignment_id          NUMBER                     --
--                  p_payroll_id             NUMBER                     --
--            OUT : p_element_type_id        NUMBER                     --
--                  p_element_link_id        NUMBER                     --
--                  p_object_version_number  NUMBER                     --
--                  p_input_values           t_input_values_tab         --
--                  p_expected_entries       NUMBER                     --
--                  p_message_name           VARCHAR2                   --
--                  p_token_name             pay_in_utils.char_tab_type --
--                  p_token_value            pay_in_utils.char_tab_type --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-Sep-06  lnagaraj   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE get_entry_details
   (p_effective_date        IN  DATE
   ,p_element_name          IN  VARCHAR2
   ,p_element_type_id       OUT NOCOPY NUMBER
   ,p_element_link_id       OUT NOCOPY NUMBER
   ,p_input_values          OUT NOCOPY t_input_values_tab
   ,p_expected_entries      OUT NOCOPY NUMBER
   ,p_message_name          OUT NOCOPY VARCHAR2
   ,p_token_name            OUT NOCOPY pay_in_utils.char_tab_type
   ,p_token_value           OUT NOCOPY pay_in_utils.char_tab_type
   ,p_business_group_id     IN  NUMBER
   )
IS

   CURSOR c_element_link
   IS
   SELECT pel.element_link_id
         ,pet.element_type_id
     FROM pay_element_links_f pel,
          pay_element_types_f pet,
	  per_assignments_f   paf
    WHERE pet.element_name      = p_element_name
      AND paf.assignment_id     = g_assignment_id
      AND pet.element_type_id   = pel.element_type_id
      AND (pel.payroll_id       = g_payroll_id or pel.payroll_id IS NULL)
      AND pel.business_group_id = paf.business_group_id
      AND p_effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
      AND p_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date
      AND p_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date;

   CURSOR c_element_type_id
   IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  (
            legislation_code = 'IN'
           OR
            business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
          )
   AND    element_name = p_element_name
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

  l_procedure      VARCHAR2(100);
  l_link_flag       VARCHAR2(100);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_entry_details' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN c_element_type_id;
  FETCH c_element_type_id INTO p_element_type_id;
  CLOSE c_element_type_id;

  l_link_flag := pay_in_utils.chk_element_link
                   (p_element_name,
		    g_assignment_id,
		    p_effective_date,
		    p_element_link_id);

  IF l_link_flag <> 'SUCCESS' OR p_element_link_id IS NULL THEN
     p_message_name  := 'PER_IN_MISSING_LINK';
     p_token_name(1) := 'ELEMENT_NAME';
     p_token_value(1):= p_element_name;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
     RETURN;
  END IF;
/*
  OPEN c_element_link;
  FETCH c_element_link INTO p_element_link_id
                          , p_element_type_id;
  pay_in_utils.set_location(g_debug,l_procedure,20);

  IF p_element_link_id is NULL OR c_element_link%NOTFOUND THEN
     CLOSE c_element_link;
     p_message_name  := 'PER_IN_MISSING_LINK';
     p_token_name(1) := 'ELEMENT_NAME';
     p_token_value(1):= p_element_name;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
     RETURN;
  END IF;
  CLOSE c_element_link;
*/

  IF g_debug THEN
      pay_in_utils.trace('Element link ID ', p_element_link_id);
      pay_in_utils.trace('Element Type ID ', p_element_type_id);
  END IF;
  pay_in_utils.set_location(g_debug, l_procedure, 40);

  get_input_value_ids(p_element_type_id  => p_element_type_id
                     ,p_effective_date   => p_effective_date
                     ,p_expected_entries => p_expected_entries
                     ,p_input_values     => p_input_values
                     ,p_business_group_id     => p_business_group_id);

  pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure, 50);

END get_entry_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_ENTRY                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Generic Procedure to create Element Entries         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date         DATE                       --
--                  p_business_group_id      VARCHAR2                   --
--                  p_assignment_id          NUMBER                     --
--                  p_payroll_id             NUMBER                     --
--                  p_element_name           VARCHAR2                   --
--                  p_entry_values           pay_in_utils.char_tab_type --
--                  p_calling_procedure      VARCHAR2                   --
--            OUT : p_message_name           VARCHAR2                   --
--                  p_token_name             pay_in_utils.char_tab_type --
--                  p_token_value            pay_in_utils.char_tab_type --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-Sep-06  lnagaraj   Created this procedure                   --
--------------------------------------------------------------------------
PROCEDURE create_entry(p_effective_date           IN DATE
                      ,p_business_group_id        IN NUMBER
                      ,p_entry_values             IN t_entry_values_tab
                      ,p_element_name             IN VARCHAR2
                      ,p_calling_procedure        IN VARCHAR2
                      ,p_message_name            OUT NOCOPY VARCHAR2
                      ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
                      ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
                       )
IS
    l_procedure              VARCHAR2(100) ;
    l_element_type_id        pay_element_types_f.element_type_id%TYPE;
    l_element_link_id        pay_element_links_f.element_link_id%TYPE;
    l_input_values           t_input_values_tab;
    l_expected_entries       NUMBER;
    l_effective_start_date   DATE;
    l_effective_end_date     DATE;
    l_element_entry_id       NUMBER;
    l_object_version_number  NUMBER;
    l_warning                CHAR(10);

    l_statem                 VARCHAR2(5000);
    sql_cursor               NUMBER;
    l_rows                   NUMBER;


BEGIN

  l_procedure := g_package || 'create_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_payroll_id is null THEN

/*   p_message_name   := 'PER_IN_MISSING_LINK';
     p_token_name(1)  := 'ELEMENT_NAME';
     p_token_value(1) := p_element_name;
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
*/   RETURN;

  END IF ;

  pay_in_utils.set_location(g_debug,l_procedure,30);

  get_entry_details
     (p_effective_date        => p_effective_date
     ,p_element_name          => p_element_name
     ,p_element_type_id       => l_element_type_id
     ,p_element_link_id       => l_element_link_id
     ,p_input_values          => l_input_values
     ,p_expected_entries      => l_expected_entries
     ,p_message_name          => p_message_name
     ,p_token_name            => p_token_name
     ,p_token_value           => p_token_value
     ,p_business_group_id     => p_business_group_id
     ) ;

  IF p_message_name <> 'SUCCESS' THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
     RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,50);

--
-- Dynamic SQL Cursor
--
     l_statem := NULL;
     l_statem := l_statem||'DECLARE ';
     l_statem := l_statem||'    l_warning   BOOLEAN; ';
     l_statem := l_statem||'BEGIN ';
     l_statem := l_statem||'pay_element_entry_api.create_element_entry';
     l_statem := l_statem||'(p_effective_date =>'''||p_effective_date||'''';
     l_statem := l_statem||',p_business_group_id => '||p_business_group_id;
     l_statem := l_statem||',p_assignment_id => '||g_assignment_id;
     l_statem := l_statem||',p_element_link_id => '||l_element_link_id;
     l_statem := l_statem||',p_entry_type => ''E''';
     l_statem := l_statem||',p_creator_type => ''F''';
     l_statem := l_statem||',p_effective_start_date => :l_eff_start_date';
     l_statem := l_statem||',p_effective_end_date => :l_eff_end_date';
     l_statem := l_statem||',p_element_entry_id => :l_ee_id';
     l_statem := l_statem||',p_object_version_number => :l_ovn';
     l_statem := l_statem||',p_create_warning => l_warning';
     l_statem := l_statem||',p_override_user_ent_chk => ''Y''';
     pay_in_utils.set_location(g_debug,l_procedure,60);

     FOR i IN 1..l_expected_entries
     LOOP
        l_statem := l_statem||',p_input_value_id'||i||'=> '||l_input_values(i).input_value_id;
	IF p_entry_values(i).entry_value IS NULL THEN
            l_statem := l_statem||',p_entry_value'||i||'=> ''''';
	ELSE
	    l_statem := l_statem||',p_entry_value'||i||'=> '''||p_entry_values(i).entry_value||'''';
	END IF;
     END LOOP;

     l_statem := l_statem||');';
     l_statem := l_statem||'IF l_warning THEN :l_warn := ''TRUE''; ELSE :l_warn := ''FALSE''; END IF;';
     l_statem := l_statem||'END;';
     pay_in_utils.trace(substr(l_statem,1,250),1);
     pay_in_utils.trace(substr(l_statem,251,250),2);
     pay_in_utils.trace(substr(l_statem,501,250),3);
     pay_in_utils.trace(substr(l_statem,751,250),4);

     pay_in_utils.set_location(g_debug,l_procedure,70);

     sql_cursor := dbms_sql.open_cursor;
     pay_in_utils.set_location(g_debug,l_procedure,80);

     dbms_sql.parse(sql_cursor, l_statem, dbms_sql.native);
     pay_in_utils.set_location(g_debug,l_procedure,90);

     dbms_sql.bind_variable(sql_cursor, 'l_eff_start_date', l_effective_start_date);
     dbms_sql.bind_variable(sql_cursor, 'l_eff_end_date',   l_effective_end_date);
     dbms_sql.bind_variable(sql_cursor, 'l_ee_id',          l_element_entry_id);
     dbms_sql.bind_variable(sql_cursor, 'l_ovn',            l_object_version_number);
     dbms_sql.bind_variable_char(sql_cursor, 'l_warn', l_warning,10);

     pay_in_utils.set_location(g_debug,l_procedure,100);

     l_rows := dbms_sql.execute(sql_cursor);
     pay_in_utils.set_location(g_debug,l_procedure,110);

     dbms_sql.close_cursor(sql_cursor);

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,120);
--
END create_entry ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EE_EXISTS                                     --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to check if EE already exists for an ET   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_name                 VARCHAR2             --
--                  p_assignment_id                NUMBER               --
--                  p_effective_date               DATE                 --
--            OUT : p_element_entry_id             NUMBER               --
--                : p_start_date                   DATE                 --
--                  p_ee_ovn                       NUMBER               --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar  Created this procedure                     --
--------------------------------------------------------------------------
FUNCTION check_ee_exists(p_element_name   IN VARCHAR2
                        ,p_assignment_id  IN NUMBER
			            ,p_effective_date IN DATE
            			,p_element_entry_id OUT NOCOPY NUMBER
             			,p_start_date       OUT NOCOPY DATE
             			,p_ee_ovn           OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  CURSOR csr_asg_details
  IS
    SELECT  asg.business_group_id
           ,asg.payroll_id
    FROM   per_assignments_f asg
    WHERE  asg.assignment_id     = p_assignment_id
    AND    asg.primary_flag      = 'Y'
    AND    p_effective_date  BETWEEN asg.effective_start_date
                            AND      asg.effective_end_date ;

  CURSOR csr_element_link (l_business_group_id IN NUMBER,
                           l_payroll_id        IN NUMBER)
  IS
    SELECT pel.element_link_id
    FROM   pay_element_links_f pel,
           pay_element_types_f pet
    WHERE  pet.element_name      = p_element_name
    AND    pet.element_type_id   = pel.element_type_id
    AND    (pel.payroll_id       = l_payroll_id
           OR (pel.payroll_id IS NULL
              AND pel.link_to_all_payrolls_flag = 'Y' ) )
    AND    pel.business_group_id = l_business_group_id
    AND    p_effective_date  BETWEEN pet.effective_start_date
                             AND     pet.effective_end_date
    AND    p_effective_date  BETWEEN pel.effective_start_date
                             AND     pel.effective_end_date ;


  CURSOR csr_element_entry (c_element_link_id IN NUMBER)
  IS
    SELECT element_entry_id
          ,object_version_number
          ,effective_start_date
    FROM   pay_element_entries_f
    WHERE  assignment_id   = p_assignment_id
    AND    element_link_id = c_element_link_id
    AND    p_effective_date BETWEEN effective_start_date
                            AND     effective_end_date ;

  l_business_group_id      NUMBER;
  l_element_link_id        NUMBER;
  l_payroll_id             NUMBER;
  l_link_flag              VARCHAR2(100);

BEGIN
   p_element_entry_id := NULL;
   p_ee_ovn := NULL;
   g_debug := hr_utility.debug_enabled;

   OPEN csr_asg_details;
   FETCH csr_asg_details
   INTO  l_business_group_id, l_payroll_id;
   CLOSE csr_asg_details;

   IF g_debug THEN
      pay_in_utils.trace('Business Group ID ',l_business_group_id);
      pay_in_utils.trace('Payroll ID ',l_payroll_id);
   END IF;

   l_link_flag := pay_in_utils.chk_element_link
                          (p_element_name,
			   p_assignment_id,
			   p_effective_date,
			   l_element_link_id);

   IF l_link_flag <> 'SUCCESS' OR l_element_link_id IS NULL THEN
      RETURN FALSE;
/*
   OPEN csr_element_link (l_business_group_id, l_payroll_id);
   FETCH csr_element_link INTO l_element_link_id;

   IF csr_element_link%NOTFOUND OR l_element_link_id IS NULL THEN
       CLOSE csr_element_link;
       RETURN FALSE;
*/
   ELSE
       IF g_debug THEN
          pay_in_utils.trace('Element Link ID ',l_element_link_id);
       END IF;

--       CLOSE csr_element_link;
     --
       OPEN csr_element_entry(l_element_link_id) ;
       FETCH csr_element_entry INTO p_element_entry_id, p_ee_ovn, p_start_date ;
       IF g_debug then
          pay_in_utils.trace('Element Entry ID ',p_element_entry_id);
       END IF;

       IF p_element_entry_id IS NULL OR csr_element_entry%NOTFOUND
       THEN
          CLOSE csr_element_entry;
	  RETURN FALSE;
       END IF;
   END IF;
   RETURN TRUE;
--
END check_ee_exists;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EE_EXISTS                                     --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to check if EE already exists for an ET   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_name                 VARCHAR2             --
--                  p_input_value_name             VARCHAR2             --
--                  p_input_value                  VARCHAR2             --
--                  p_assignment_id                NUMBER               --
--                  p_effective_date               DATE                 --
--            OUT : p_element_entry_id             NUMBER               --
--                : p_start_date                   DATE                 --
--                  p_ee_ovn                       NUMBER               --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar  Created this procedure                     --
--------------------------------------------------------------------------
FUNCTION check_ee_exists
              (p_element_name      IN VARCHAR2
              ,p_input_value_name  IN VARCHAR2
              ,p_input_value       IN VARCHAR2
              ,p_assignment_id     IN NUMBER
 			  ,p_effective_date    IN DATE
			  ,p_element_entry_id OUT NOCOPY NUMBER
			  ,p_start_date       OUT NOCOPY DATE
			  ,p_ee_ovn           OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  CURSOR csr_asg_details
  IS
    SELECT  asg.business_group_id
           ,asg.payroll_id
    FROM   per_assignments_f asg
    WHERE  asg.assignment_id     = p_assignment_id
    AND    asg.primary_flag      = 'Y'
    AND    p_effective_date  BETWEEN asg.effective_start_date
                            AND      asg.effective_end_date ;

  CURSOR csr_element_link (l_business_group_id IN NUMBER,
                           l_payroll_id        IN NUMBER)
  IS
    SELECT pel.element_link_id
    FROM   pay_element_links_f pel,
           pay_element_types_f pet
    WHERE  pet.element_name      = p_element_name
    AND    pet.element_type_id   = pel.element_type_id
    AND    (pel.payroll_id       = l_payroll_id
           OR (pel.payroll_id IS NULL
              AND pel.link_to_all_payrolls_flag = 'Y' ) )
    AND    pel.business_group_id = l_business_group_id
    AND    p_effective_date  BETWEEN pet.effective_start_date
                             AND     pet.effective_end_date
    AND    p_effective_date  BETWEEN pel.effective_start_date
                             AND     pel.effective_end_date ;


  CURSOR csr_element_entry (c_element_link_id IN NUMBER)
  IS
    SELECT pef.element_entry_id
          ,pef.object_version_number
	  ,pef.effective_start_date
    FROM   pay_element_entries_f pef
          ,pay_element_entry_values_f pev
	  ,pay_input_values_f piv
    WHERE  pef.assignment_id      = p_assignment_id
    AND    pef.element_link_id    = c_element_link_id
    AND    pef.element_entry_id   = pev.element_entry_id
    AND    pev.input_value_id     = piv.input_value_id
    AND    piv.NAME               = p_input_value_name
    AND    pev.screen_entry_value = p_input_value
    AND    p_effective_date BETWEEN pef.effective_start_date
                            AND     pef.effective_end_date
    AND    p_effective_date BETWEEN pev.effective_start_date
                            AND     pev.effective_end_date
    AND    p_effective_date BETWEEN piv.effective_start_date
                            AND     piv.effective_end_date;

  l_business_group_id      NUMBER;
  l_element_link_id        NUMBER;
  l_payroll_id             NUMBER;
  l_link_flag              VARCHAR2(100);

BEGIN
   p_element_entry_id := NULL;
   p_ee_ovn := NULL;
   g_debug := hr_utility.debug_enabled;

   OPEN csr_asg_details;
   FETCH csr_asg_details
   INTO  l_business_group_id, l_payroll_id;
   CLOSE csr_asg_details;

   IF g_debug THEN
      pay_in_utils.trace('Business Group ID ',l_business_group_id);
      pay_in_utils.trace('Payroll ID ',l_payroll_id);
   END IF;

   l_link_flag := pay_in_utils.chk_element_link
                          (p_element_name,
			   p_assignment_id,
			   p_effective_date,
			   l_element_link_id);

   IF l_link_flag <> 'SUCCESS' OR l_element_link_id IS NULL THEN
      RETURN FALSE;

/*   OPEN csr_element_link (l_business_group_id, l_payroll_id);
   FETCH csr_element_link INTO l_element_link_id;

   IF csr_element_link%NOTFOUND OR l_element_link_id IS NULL THEN
       CLOSE csr_element_link;
       RETURN FALSE;
*/
   ELSE
       IF g_debug THEN
          pay_in_utils.trace('Element Link ID ',l_element_link_id);
       END IF;

--       CLOSE csr_element_link;
     --
       OPEN csr_element_entry(l_element_link_id) ;
       FETCH csr_element_entry INTO p_element_entry_id, p_ee_ovn, p_start_date ;
       IF g_debug then
          pay_in_utils.trace('Element Entry ID ',p_element_entry_id);
       END IF;

       IF p_element_entry_id IS NULL OR csr_element_entry%NOTFOUND
       THEN
          CLOSE csr_element_entry;
	  RETURN FALSE;
       END IF;
   END IF;
   RETURN TRUE;
--
END check_ee_exists;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_ELEMENT_PROCESSED                                   --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return whether element is processed     --
--                  for a  terminated employee.                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                   NUMBER            --
--                  p_element_name                    VARCHAR2          --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   20-apr-07  rsaharay  Created this function                     --

--------------------------------------------------------------------------
FUNCTION is_element_processed(p_assignment_id      IN NUMBER,
                              p_element_name       IN VARCHAR2
                         )
RETURN BOOLEAN
IS
--
 CURSOR csr_element_proc  IS
 SELECT 1
   FROM pay_run_results prr,
        pay_assignment_actions paa,
        pay_element_types_f pet,
        pay_payroll_Actions ppa
  WHERE paa.assignment_id = p_assignment_id
   AND  paa.assignment_action_id = prr.assignment_action_id
   AND  paa.payroll_action_id= ppa.payroll_action_id
   AND  ppa.action_type in('R','Q','B')
   AND  ppa.action_status = 'C'
   AND  paa.action_status = 'C'
   AND  prr.element_type_id=pet.element_type_id
   AND  pet.element_name=p_element_name;


 l_procedure      VARCHAR2(100) ;
 l_count          NUMBER ;


--
BEGIN
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'is_element_processed' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  OPEN csr_element_proc;
  FETCH csr_element_proc INTO l_count;
  IF csr_element_proc%FOUND THEN
   pay_in_utils.set_location(g_debug,'Leaving: True'||l_procedure,60);
   CLOSE csr_element_proc;
   RETURN TRUE ;
  END IF ;
  CLOSE csr_element_proc;
  pay_in_utils.set_location(g_debug,'Leaving: False'||l_procedure,60);
  RETURN FALSE ;
--
END is_element_processed ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADVANCE_EXISTS                                --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to check if EE already exists for an ET   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_name                 VARCHAR2             --
--                  p_input_value_name             VARCHAR2             --
--                  p_input_value                  VARCHAR2             --
--                  p_assignment_id                NUMBER               --
--                  p_effective_date               DATE                 --
--            OUT : p_element_entry_id             NUMBER               --
--                : p_start_date                   DATE                 --
--                  p_ee_ovn                       NUMBER               --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar  Created this procedure                     --
--------------------------------------------------------------------------
FUNCTION check_advance_exists
              (p_component_name  IN VARCHAR2
              ,p_assignment_id     IN NUMBER
              ,p_effective_date    IN DATE
              ,p_element_entry_id OUT NOCOPY NUMBER
              ,p_start_date       OUT NOCOPY DATE
              ,p_ee_ovn           OUT NOCOPY NUMBER
              )
RETURN BOOLEAN
IS
  CURSOR csr_asg_details
  IS
    SELECT  asg.business_group_id
           ,asg.payroll_id
    FROM   per_assignments_f asg
    WHERE  asg.assignment_id     = p_assignment_id
    AND    asg.primary_flag      = 'Y'
    AND    p_effective_date  BETWEEN asg.effective_start_date
                            AND      asg.effective_end_date ;



  CURSOR csr_element_entry(l_business_group_id IN NUMBER)
  IS
   SELECT pee.element_entry_id
        , pee.object_version_number
        ,pee.effective_start_date
    FROM pay_element_types_f pet,
         pay_element_classifications pec,
         pay_element_entries_f pee,
         pay_element_entry_values_f peev,
         pay_input_values_f piv
   WHERE pet.classification_id = pec.classification_id
     AND pec.classification_name = 'Information'
     AND pet.element_name LIKE '%Excess Advance'
     AND pet.element_type_id = piv.element_type_id
     AND piv.name ='Component Name'
     AND piv.default_value = p_component_name
     AND peev.input_value_id = piv.input_value_id
     AND peev.element_entry_id = pee.element_entry_id
     AND p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
     AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
     AND p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
     AND p_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
     AND pee.assignment_id = p_assignment_id
     AND pee.element_type_id = pet.element_type_id
     AND pet.business_group_id = l_business_group_id;

  l_business_group_id      NUMBER;
  l_element_link_id        NUMBER;
  l_payroll_id             NUMBER;

BEGIN
   p_element_entry_id := NULL;
   p_ee_ovn := NULL;
   g_debug := hr_utility.debug_enabled;

   OPEN csr_asg_details;
   FETCH csr_asg_details
   INTO  l_business_group_id, l_payroll_id;
   CLOSE csr_asg_details;

   IF g_debug THEN
      pay_in_utils.trace('Business Group ID ',l_business_group_id);
      pay_in_utils.trace('Payroll ID ',l_payroll_id);
   END IF;


     --
       OPEN csr_element_entry(l_business_group_id) ;
       FETCH csr_element_entry INTO p_element_entry_id, p_ee_ovn, p_start_date ;
       IF g_debug then
          pay_in_utils.trace('Element Entry ID ',p_element_entry_id);
       END IF;

       IF p_element_entry_id IS NULL OR csr_element_entry%NOTFOUND
       THEN
          CLOSE csr_element_entry;
       RETURN FALSE;
       END IF;
       CLOSE csr_element_entry;

   RETURN TRUE;
--
END check_advance_exists;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_GRATUITY_IVS                                    --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to set the IVs of Gratuity Information    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_actual_termination_date      DATE                 --
--            OUT : p_continuous_service_flag      VARCHAR2             --
--                : p_years_of_service             NUMBER               --
--                  p_create_ee                    BOOLEAN              --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar  Created this procedure                     --
--------------------------------------------------------------------------
PROCEDURE get_gratuity_ivs
             (p_actual_termination_date  IN DATE
		     ,p_continuous_service_flag OUT NOCOPY VARCHAR2
		     ,p_years_of_service        OUT NOCOPY NUMBER
		     ,p_create_ee               OUT NOCOPY BOOLEAN
                      )
IS
   l_procedure      VARCHAR2(100);

 CURSOR csr_asg_details
 IS
   SELECT scl.segment8
   FROM   per_assignments_f asg
         ,hr_soft_coding_keyflex  scl
   WHERE  asg.assignment_id    = g_assignment_id
   AND    asg.primary_flag     = 'Y'
   AND    p_actual_termination_date
                           BETWEEN asg.effective_start_date
                           AND     asg.effective_end_date
   AND    scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
   AND    scl.enabled_flag           = 'Y' ;

 l_e_date         CONSTANT DATE := to_date('01-04-2004','DD-MM-YYYY');
 l_coverage_flag  hr_soft_coding_keyflex.segment8%TYPE;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_gratuity_ivs' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  pay_in_utils.set_location(g_debug,l_procedure,20);

  OPEN csr_asg_details;
  FETCH csr_asg_details
  INTO l_coverage_flag;
  CLOSE csr_asg_details;

  pay_in_utils.set_location(g_debug,l_procedure,30);

  IF l_coverage_flag = 'Y' AND p_actual_termination_date > l_e_date
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,40);
     p_years_of_service := years_of_service(p_start_date => g_hire_date
                                           ,p_end_date   => p_actual_termination_date
                                           ,p_flag       => 'Y'
                                           ) ;
     p_continuous_service_flag:='Y';
     IF g_debug THEN
        pay_in_utils.trace('Years of Service ',p_years_of_service);
     END IF;
     pay_in_utils.set_location(g_debug,l_procedure,50);

     IF g_leaving_reason IN ( 'PDD', 'PDA', 'D' ) OR p_years_of_service >=5
     THEN
        pay_in_utils.set_location(g_debug,l_procedure,60);
	p_create_ee := TRUE;
     ELSE
        pay_in_utils.set_location(g_debug,l_procedure,70);
        p_create_ee := FALSE;
     END IF;
     --
   END IF; --End of IF block for Covered under Gratuity and act_term_date check.

   pay_in_utils.set_location(g_debug,'Leaving :'||l_procedure,90);

END get_gratuity_ivs;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_GRATUITY_ENTRY                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to handle creation of Gratuity entry for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
-- 1.1   19-Nov-04  statkar   4015962 Removed Base Salary Input Value   --
--------------------------------------------------------------------------
PROCEDURE create_gratuity_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
    	     ,p_calling_procedure       IN VARCHAR2
	         ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_create_ee         BOOLEAN;
  l_element_processed BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_gratuity_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_ee_exists := check_ee_exists
                    (p_element_name     => g_gratuity_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_gratuity_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
--
-- Element Name : Gratuity Information
--
-- Input Value are:
--
-- 1. Gratuity Amount         - Null
-- 2. Continuous Service      - Yes/No
-- 3. Completed Service Years - Calculate
-- 4. Forfeiture Amount       - Null
-- 5. Forfeiture Reason       - Null
-- 6. Component Name          - 'Gratuity'
-- 7. Salary for the Period   - Null
  l_entry_values(1).entry_value := null;
  get_gratuity_ivs
           (p_actual_termination_date  => p_actual_termination_date
		   ,p_continuous_service_flag  => l_entry_values(2).entry_value
		   ,p_years_of_service         => l_entry_values(3).entry_value
		   ,p_create_ee                => l_create_ee
            );

  l_entry_values(4).entry_value := null;
  l_entry_values(5).entry_value := null;
  l_entry_values(6).entry_value := g_gratuity_cn;
  l_entry_values(7).entry_value := null;
  l_element_name := g_gratuity_et;

  IF l_create_ee THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );
     pay_in_utils.set_location(g_debug,l_procedure,30);
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END create_gratuity_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_GRATUITY_ENTRY                                 --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete 'Gratuity Information' Entry      --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_gratuity_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_gratuity_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_gratuity_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;

     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_gratuity_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_NOTICE_IVS                                      --
-- Type           : Procedure                                           --
-- Access         : Private                                             --
-- Description    : Procedure to set the IVs of Notice Information      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_actual_termination_date      DATE                 --
--            OUT : p_notice_period_days           NUMBER               --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
-- 1.1.  28-Oct-04  statkar   Changed the logic for notice days         --
-- 1.2.  28-Oct-04  rsaharay  To consider the Notice Period &           --
--                            Units mentioned in the Assignment Form    --
--------------------------------------------------------------------------
PROCEDURE get_notice_ivs
                     (p_actual_termination_date  IN DATE
		             ,p_business_group_id        IN NUMBER
        		     ,p_notice_period_days      OUT NOCOPY NUMBER
                      )
IS
   l_procedure      VARCHAR2(100);

   CURSOR csr_emp_catg IS
     SELECT NVL(paf.employee_category,'IN_DEF'),
            paf.notice_period,paf.notice_period_uom
     FROM   per_assignments_f paf
     WHERE  paf.assignment_id           = g_assignment_id
     AND    p_actual_termination_date BETWEEN paf.effective_start_date
                                    AND     paf.effective_end_date;

   CURSOR csr_np (p_emp_category IN VARCHAR2) IS
     SELECT hoi.org_information2
     FROM   hr_organization_information hoi
     WHERE  hoi.organization_id         = p_business_group_id
     AND    hoi.org_information_context = 'PER_IN_NOTICE_DF'
     AND    hoi.org_information1        = p_emp_category;

   l_emp_category     per_assignments_f.employee_category%TYPE;
   l_notice_duration   NUMBER;
   l_notice_uom        VARCHAR2(2);
   l_shortfall         NUMBER;
   l_message         VARCHAR2(1000);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package ||'get_notice_ivs' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

--
-- Step 1. To fetch the Notice Period Days from the Assignment Form
--
  OPEN csr_emp_catg;
  FETCH csr_emp_catg
  INTO  l_emp_category,l_notice_duration,l_notice_uom;
  CLOSE csr_emp_catg;

  IF g_debug THEN
     pay_in_utils.trace('Employee Category ',l_emp_category);
  END IF;

--
-- Step 2. To fetch the Notice Period Days from the DFF
--
  IF l_notice_duration IS NULL THEN
   OPEN csr_np (l_emp_category);
   FETCH csr_np
   INTO  l_notice_duration;

   IF csr_np%NOTFOUND THEN
      CLOSE csr_np;
      OPEN csr_np ('IN_DEF');
      FETCH csr_np INTO l_notice_duration;
         IF csr_np%NOTFOUND OR l_notice_duration IS NULL THEN
            CLOSE csr_np;
            l_notice_duration := 0;
            p_notice_period_days := 0;
            RETURN;
         END IF;
      CLOSE csr_np;
   ELSE
      CLOSE csr_np;
   END IF;
  END IF ;

 IF l_notice_uom IS NULL OR l_notice_uom = 'D' THEN
   IF g_debug THEN
      pay_in_utils.trace('Notice Period Duration ',l_notice_duration);
   END IF;
  --Bug 3977010. Added +1
   l_shortfall := ROUND(l_notice_duration - (p_actual_termination_date - g_notified_date + 1),0);
   IF l_shortfall < 0 THEN
         p_notice_period_days := 0;
   ELSE
         p_notice_period_days := l_shortfall;
   END IF;
 ELSE
   p_notice_period_days := 0;
 END IF ;
 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);

END get_notice_ivs;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_NOTICE_ENTRY                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of Gratuity entry for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_notice_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_notice_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_ee_exists := check_ee_exists
                    (p_element_name     => g_notice_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_notice_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
--
-- Element Name : Notice Period Information
--
-- Input Value are:
--
-- 1. Notice Period Amount - Null
-- 2. Notice From          - EE
-- 3. Notice Period Days   - Calculate
-- 4. Period Days          - 30
-- 5. Component Name       - 'Notice Period Pay'
--
  l_entry_values(1).entry_value := null;
  l_entry_values(2).entry_value := 'EE';
  get_notice_ivs (p_actual_termination_date => p_actual_termination_date
                 ,p_business_group_id       => p_business_group_id
  		         ,p_notice_period_days      => l_entry_values(3).entry_value
                 );
  l_entry_values(4).entry_value := '30';
  l_entry_values(5).entry_value := g_notice_cn;
  l_element_name := g_notice_et;

-- Bug 3977010
  IF l_entry_values(3).entry_value <= 0 THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
     RETURN;
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,30);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END create_notice_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_NOTICE_ENTRY                                   --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'Notice Period Information' EE    --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_notice_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_notice_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_notice_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_notice_entry;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_RETRENCMENT_ENTRY                            --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of Retrenchment EE for --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
--------------------------------------------------------------------------
PROCEDURE create_retrenchment_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_retrenchment_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_ee_exists := check_ee_exists
                    (p_element_name     => g_retrenchment_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_retrenchment_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
--
-- Element Name : Retrenchment Compensation Information
--
-- Input Value are:
--
-- 1. Taxable Amount      - Null
-- 2. Non Taxable Amount  - Null
-- 3. Component Name      - 'Retrenchment'
--
  l_entry_values(1).entry_value := null;
  l_entry_values(2).entry_value := null;
  l_entry_values(3).entry_value := g_retrenchment_cn;
  l_element_name := g_retrenchment_et;

  pay_in_utils.set_location(g_debug,l_procedure,20);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END create_retrenchment_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_RETRENCMENT_ENTRY                              --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'Retrencment Information' EE      --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_retrenchment_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_start_date         DATE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_delete_warning     BOOLEAN;
  l_assignment_id      NUMBER;
  l_payroll_id         NUMBER;
  l_hire_date          DATE;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_retrenchment_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_retrenchment_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_retrenchment_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_VRS_ENTRY                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of VRS elem entry for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_vrs_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;
  l_prev_earn	      NUMBER;
  l_prev_tds            NUMBER;
  l_prev_pt             NUMBER;
  l_prev_ent            NUMBER;
  l_prev_pf             NUMBER;
  l_prev_super          NUMBER;
  l_govt_ent_alw        NUMBER;
  l_prev_grat           NUMBER;
  l_leave_enc           NUMBER;
  l_retr_pay            NUMBER;
  l_designation         VARCHAR2(100);
  l_annual_sal          NUMBER;
  l_pf_number           VARCHAR2(30);
  l_pf_estab_code       VARCHAR2(15);
  l_epf_number          VARCHAR2(30);
  l_emplr_class         VARCHAR2(10);
  l_ltc_curr_block      NUMBER;
  l_vrs_amount          NUMBER;
  l_prev_sc             NUMBER;
  l_prev_cess           NUMBER;
  l_dummy               NUMBER;
  l_prev_exemp_80gg      NUMBER;
  l_prev_exemp_80ccd      NUMBER;
  l_prev_med_reimburse  NUMBER;
  l_prev_sec_and_he_cess NUMBER;
  l_prev_cghs_exemp_80d NUMBER;


BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_vrs_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  -- Fix for Bug 4027040 Start

  l_prev_earn := 0;
  l_prev_tds  := 0;
  l_prev_pt   := 0;
  l_prev_ent  := 0;
  l_prev_pf   := 0;
  l_prev_super := 0;
  l_govt_ent_alw := 0;
  l_prev_grat := 0;
  l_leave_enc := 0;
  l_retr_pay := 0;
  l_designation := 'X';
  l_annual_sal := 0;
  l_pf_number := 'X';
  l_pf_estab_code := 'X';
  l_epf_number := 'X';
  l_emplr_class := 'X';
  l_ltc_curr_block := 0;
  l_vrs_amount := 0;
  l_prev_sc := 0;
  l_prev_cess := 0;
  l_dummy := 0;
  l_prev_exemp_80gg:=0;
  l_prev_exemp_80ccd:=0;
  l_prev_med_reimburse := 0;
  l_prev_sec_and_he_cess :=0;
  l_prev_cghs_exemp_80d := 0;

  l_dummy := pay_in_tax_utils.prev_emplr_details(g_assignment_id,
						 p_actual_termination_date,
						 l_prev_earn,
		                 l_prev_tds,
						 l_prev_pt,
						 l_prev_ent,
						 l_prev_pf,
						 l_prev_super,
						 l_govt_ent_alw,
						 l_prev_grat,
						 l_leave_enc,
						 l_retr_pay,
						 l_designation,
						 l_annual_sal,
						 l_pf_number,
						 l_pf_estab_code,
						 l_epf_number,
						 l_emplr_class,
						 l_ltc_curr_block,
						 l_vrs_amount,
                         l_prev_sc,
                         l_prev_cess,
			 l_prev_exemp_80gg,
                         l_prev_med_reimburse,
			 l_prev_sec_and_he_cess,
			 l_prev_exemp_80ccd,
			 l_prev_cghs_exemp_80d);
  IF l_vrs_amount <> 0 THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

  -- Fix for Bug 4027040 End
  l_ee_exists := check_ee_exists
                    (p_element_name     => g_vrs_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_vrs_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
--
-- Element Name : Voluntary Retirement Information
--
-- Input Value are:
--
-- 1. Taxable Amount     - Null
-- 2. Non Taxable Amount - Null
-- 3. Component Name     - 'Voluntary Retirement'

  l_entry_values(1).entry_value := null;
  l_entry_values(2).entry_value := null;
  l_entry_values(3).entry_value := g_vrs_cn;
  l_element_name := g_vrs_et;

  pay_in_utils.set_location(g_debug,l_procedure,20);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );


  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END create_vrs_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_VRS_ENTRY                                      --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'Voluntary Retirement Information'--
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_vrs_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;
  l_assignment_id      NUMBER;
  l_payroll_id         NUMBER;
  l_hire_date          DATE;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_vrs_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_vrs_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;

     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_vrs_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_PENSION_ENTRY                                --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of Comm Pension EE for --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_pension_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_pension_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_ee_exists := check_ee_exists
                    (p_element_name     => g_pension_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_pension_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

--
-- Element Name : Commuted Pension Information
--
-- Input Value are:
--
-- 1. Commuted Pension  - Null
-- 2. Normal Pension    - Null
-- 3. Component Name    - 'Commuted Pension'
--
  l_entry_values(1).entry_value := null;
  l_entry_values(2).entry_value := null;
  l_entry_values(3).entry_value := g_pension_cn;
  l_element_name := g_pension_et;

  pay_in_utils.set_location(g_debug,l_procedure,20);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );


  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END create_pension_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_PENSION_ENTRY                                  --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'Commuted Pension Information' EE --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_pension_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;
  l_assignment_id      NUMBER;
  l_payroll_id         NUMBER;
  l_hire_date          DATE;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_pension_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_pension_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);
  END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_pension_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : create_advances_entry                                 --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete 'Gratuity Information' Entry      --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_advances_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;
  l_def_bal_id        NUMBER;
  l_asact_id          NUMBER;
  l_adv_element_name  pay_element_types_f.element_name%TYPE ;
  p_element_link_id   NUMBER;

  CURSOR csr_element IS
   SELECT pet.element_name
        ,piv1.default_value
        ,pbt.balance_name
    FROM pay_element_types_f pet,
         pay_element_classifications pec,
         pay_balance_feeds_f pbf,
         pay_balance_types pbt,
         pay_input_values_f piv,
         pay_input_values_f piv1,
         pay_element_types_f pet2
   WHERE pet.classification_id = pec.classification_id
     AND pec.classification_name = 'Voluntary Deductions'
     AND pec.legislation_code = 'IN'
     AND pet.element_name LIKE '%Recover'
     AND pbf.input_value_id = piv.input_value_id
     AND pbt.balance_type_id = pbf.balance_type_id
     AND pbt.balance_name IN ('Outstanding Advance for Allowances',
                              'Outstanding Advance for Earnings',
                              'Outstanding Advance for Fringe Benefits')
     AND pbt.legislation_code='IN'
     AND piv1.element_type_id = pet.element_type_id
     AND piv.name = 'Pay Value'
     AND piv.element_type_id = pet.element_type_id
     AND piv1.name ='Component Name'
     AND p_actual_termination_date BETWEEN pbf.effective_start_date AND pbf.effective_end_date
     AND p_actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
     AND p_actual_termination_date BETWEEN piv1.effective_start_date AND piv1.effective_end_date
     AND p_actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
     AND piv.business_group_id  = p_business_group_id
     AND piv1.business_group_id = p_business_group_id
     AND pet.business_group_id  = p_business_group_id
     AND pet2.business_group_id = p_business_group_id
     AND pet2.element_name = SUBSTR(pet.element_name,1,INSTR(pet.element_name,' Recover',-1))||'Advance'
     AND p_actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
     AND EXISTS (SELECT '1'
                   FROM pay_run_results prr,
                        pay_assignment_actions paa,
                        pay_payroll_Actions ppa
                  WHERE paa.assignment_id = g_assignment_id
                    AND paa.assignment_action_id = prr.assignment_action_id
                    AND paa.payroll_action_id= ppa.payroll_action_id
                    AND ppa.action_type in('R','Q','B')
                    AND prr.element_type_id = pet2.element_type_id
                    AND ROWNUM =1
                    AND ppa.action_status = 'C'
                    AND paa.action_status = 'C'
                    AND ppa.business_group_id = p_business_group_id
                 );

  CURSOR csr_asact_id IS
     SELECT MAX(paa.assignment_action_id)
     FROM   pay_assignment_actions paa
           ,pay_payroll_actions ppa
     WHERE  paa.assignment_id = g_assignment_id
     AND    paa.payroll_action_id = ppa.payroll_action_id
     AND    paa.action_status = 'C'
     AND    paa.source_action_id IS NULL
     AND    ppa.action_type in ('R','Q')
     AND    ppa.action_status = 'C' ;


BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_advances_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);



  FOR i in csr_element LOOP


          l_def_bal_id := pay_in_tax_utils.get_defined_balance
                        ( p_balance_type    => i.balance_name
                         ,p_dimension_name  => '_ASG_COMP_LTD');

            OPEN csr_asact_id;
            FETCH csr_asact_id INTO l_asact_id;
            CLOSE csr_asact_id;

        l_entry_values(1).entry_value :=
        pay_balance_pkg.get_value
            (p_defined_balance_id   => l_def_bal_id
            ,p_assignment_action_id => l_asact_id
            ,p_tax_unit_id          => ''
            ,p_jurisdiction_code    => ''
            ,p_source_id            => ''
            ,p_source_text          => ''
            ,p_source_text2          => i.default_value
            ,p_tax_group            => ''
            ,p_date_earned          => ''
            ,p_get_rr_route         => 'TRUE'
            ,p_get_rb_route         => ''
            );

          pay_in_utils.set_location(g_debug,l_procedure,20);

        IF(l_entry_values(1).entry_value > 0) THEN
          l_entry_values(1).entry_value := 'RECOVER' ;
          l_entry_values(2).entry_value := i.default_value;
          l_element_name := substr(i.element_name,1,instr(i.element_name,' Recover',-1))||'Excess Advance';

          pay_in_utils.set_location(g_debug,l_procedure,30);

          l_ee_exists := check_advance_exists
                    (p_component_name   => i.default_value
                    ,p_assignment_id    => g_assignment_id
                    ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn
                    );

         l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name);


          IF l_ee_exists OR l_element_processed THEN
             pay_in_utils.set_location(g_debug,l_procedure,40);
          ELSE
             pay_in_utils.set_location(g_debug,l_procedure,50);
             create_entry
                  (p_effective_date         => p_actual_termination_date
                  ,p_business_group_id      => p_business_group_id
                  ,p_element_name           => l_element_name
                  ,p_entry_values           => l_entry_values
                  ,p_calling_procedure      => p_calling_procedure
                  ,p_message_name           => p_message_name
                  ,p_token_name             => p_token_name
                  ,p_token_value            => p_token_value
                  );
          END IF;
          pay_in_utils.set_location(g_debug,l_procedure,60);
        END IF;

   END LOOP;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,60);

END create_advances_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : delete_advances_entry                                 --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete 'Gratuity Information' Entry      --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_advances_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;

  CURSOR csr_element IS
  SELECT pet.element_name
    FROM pay_element_types_f pet,
         pay_element_classifications pec
   WHERE pet.classification_id = pec.classification_id
     AND pec.classification_name = 'Information'
     AND pet.element_name LIKE '%Excess Advance'
     AND pet.business_group_id = p_business_group_id
     and p_actual_termination_date between pet.effective_start_date and pet.effective_end_date;


BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_advances_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  FOR i in csr_element loop

  IF check_ee_exists
                    (p_element_name     => i.element_name
                    ,p_assignment_id    => g_assignment_id
                    ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>i.element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  END LOOP;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_advances_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_PF_ENTRY                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of PF Settlement EE for--
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_pf_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_pf_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_ee_exists := check_ee_exists
                    (p_element_name     => g_pf_et--l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

  IF l_ee_exists THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>g_pf_et);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
--
-- Element Name : PF Settlement Information
--
-- Input Value are:
--
-- 1. PF Settlement Amount   - Null
-- 2. Continuous Service     - Calculate
-- 3. Employee Contribution  - Null
-- 4. Component Name         - 'PF Settlement'
--
  l_entry_values(1).entry_value := null;
  IF (months_between(p_actual_termination_date, g_hire_date)/12 ) > 5 THEN
     l_entry_values(2).entry_value := 'Y';
  ELSE
     l_entry_values(2).entry_value := 'N';
  END IF;
  l_entry_values(3).entry_value := null;
  l_entry_values(4).entry_value := g_pf_cn;
  l_element_name := g_pf_et;

  pay_in_utils.set_location(g_debug,l_procedure,20);
     create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

END create_pf_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_PF_ENTRY                                       --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'PF Settlement Information' EE    --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_pf_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;
  l_assignment_id      NUMBER;
  l_payroll_id         NUMBER;
  l_hire_date          DATE;

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_pf_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_pf_et;

  IF check_ee_exists
                    (p_element_name     => l_element_name
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
  THEN
     pay_in_utils.set_location(g_debug,l_procedure,20);
     IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
     END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
     pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
     END IF ;
     pay_in_utils.set_location(g_debug,l_procedure,30);

  END IF;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,40);

END delete_pf_entry;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_LOAN_ENTRY                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                              --
-- Description    : Procedure to handle creation of Loan Recovery EE for--
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_loan_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure         VARCHAR2(100);
  l_element_name      pay_element_types_f.element_name%TYPE ;
  l_entry_values      t_entry_values_tab;
  l_element_entry_id  pay_element_entries_f.element_entry_id%TYPE;
  l_start_date        DATE;
  l_ee_ovn            pay_element_entries_f.object_version_number%TYPE;
  l_ee_exists         BOOLEAN;
  l_element_processed BOOLEAN;

  CURSOR c_ee_dtls IS
  SELECT pee.element_entry_id
  FROM   pay_element_entries_f pee
	    ,pay_input_values_f piv
        ,pay_element_entry_values_f peev
  WHERE  pee.assignment_id = g_assignment_id
  AND    pee.element_entry_id = peev.element_entry_id
  AND    peev.input_value_id = piv.input_value_id
  AND    piv.name = 'Component Name'
  AND    peev.screen_entry_value = 'Loan at Concessional Rate'
  AND    p_actual_termination_date BETWEEN pee.effective_start_date
                                   AND     pee.effective_end_date
  AND    p_actual_termination_date BETWEEN piv.effective_start_date
                                   AND     piv.effective_end_date
  AND    p_actual_termination_date BETWEEN peev.effective_start_date
                                   AND     peev.effective_end_date;

  l_ee_id    pay_element_entries_f.element_entry_id%TYPE;

  CURSOR c_iv_dtls (p_element_entry_id IN NUMBER
                  , p_name IN VARCHAR2)
  IS
  SELECT peev.screen_entry_value
  FROM   pay_element_entry_values_f peev
	    ,pay_input_values_f piv
  WHERE  peev.element_entry_id = p_element_entry_id
  AND    peev.input_value_id  = piv.input_value_id
  AND    piv.NAME = p_name
  AND    p_actual_termination_date BETWEEN peev.effective_start_date
                                   AND     peev.effective_end_date
  AND    p_actual_termination_date BETWEEN piv.effective_start_date
                                   AND     piv.effective_end_date;

  l_loan_number    pay_element_entry_values_f.screen_entry_value%TYPE;
  l_loan_type      pay_element_entry_values_f.screen_entry_value%TYPE;

  l_def_bal_id     pay_defined_balances.defined_balance_id%TYPE;

  CURSOR csr_asact_id IS
     SELECT max(paa.assignment_action_id)
     FROM   pay_assignment_actions paa
           ,pay_payroll_actions ppa
     WHERE  paa.assignment_id = g_assignment_id
     AND    paa.payroll_action_id = ppa.payroll_action_id
     AND    paa.action_status = 'C'
     AND    paa.source_action_id IS NULL
     AND    ppa.action_type in ('R','Q')
     AND    ppa.action_status = 'C' ;

  l_asact_id     pay_assignment_actions.assignment_action_id%TYPE;
BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_loan_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

--
-- Fetch the Loan Number and Loan Type for each loan
--
  l_element_name := g_loan_et;
  OPEN c_ee_dtls;
  LOOP
     FETCH c_ee_dtls
     INTO  l_ee_id;
     EXIT WHEN c_ee_dtls%NOTFOUND;

     OPEN c_iv_dtls (l_ee_id, 'Loan Number');
     FETCH c_iv_dtls INTO l_loan_number;
     CLOSE c_iv_dtls;

     OPEN c_iv_dtls (l_ee_id, 'Loan Type');
     FETCH c_iv_dtls INTO l_loan_type;
     CLOSE c_iv_dtls;

     l_ee_exists := check_ee_exists
                    (p_element_name     => l_element_name
		            ,p_input_value_name => 'Loan Number'
		            ,p_input_value      => l_loan_number
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn);

     IF NOT l_ee_exists THEN
        pay_in_utils.set_location(g_debug,l_procedure,20);

 l_element_processed := is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name);

  IF l_element_processed THEN
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,15);
     RETURN;
  END IF;
        --
        -- Element Name : Loan Recovery
        --
        -- Input Value are:
        --
        -- 1. Pay Value    - Calculate
        -- 2. Loan Number  - Associate
        -- 3. Loan Type    - Associate
        -- 4. Component Name - 'Loan Recovery'

        l_def_bal_id := pay_in_tax_utils.get_defined_balance
                        ( p_balance_type    => 'Maximum Outstanding Amount'
                         ,p_dimension_name  => '_ASG_SRC_LTD');

        OPEN csr_asact_id;
	    FETCH csr_asact_id INTO l_asact_id;
	    CLOSE csr_asact_id;

        l_entry_values(1).entry_value :=
	    pay_balance_pkg.get_value
	    (p_defined_balance_id   => l_def_bal_id
	    ,p_assignment_action_id => l_asact_id
	    ,p_tax_unit_id          => ''
	    ,p_jurisdiction_code    => ''
	    ,p_source_id            => ''
	    ,p_source_text          => l_loan_number
	    ,p_tax_group            => ''
	    ,p_date_earned          => ''
	    ,p_get_rr_route         => 'TRUE'
	    ,p_get_rb_route         => ''
	    );

        l_entry_values(1).entry_value := (-1)*l_entry_values(1).entry_value ;
        l_entry_values(2).entry_value := l_loan_number;
        l_entry_values(3).entry_value := l_loan_type;
        l_entry_values(4).entry_value := g_loan_cn;

        pay_in_utils.set_location(g_debug,l_procedure,30);
        create_entry
          (p_effective_date         => p_actual_termination_date
	      ,p_business_group_id      => p_business_group_id
	      ,p_element_name           => l_element_name
	      ,p_entry_values           => l_entry_values
	      ,p_calling_procedure      => p_calling_procedure
          ,p_message_name           => p_message_name
          ,p_token_name             => p_token_name
          ,p_token_value            => p_token_value
 	       );

        pay_in_utils.set_location(g_debug,l_procedure,40);
     END IF;
  END LOOP;
  CLOSE c_ee_dtls;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,50);

END create_loan_entry;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_LOAN_ENTRY                                     --
-- Type         : Procedure                                             --
-- Access       : Private                                                --
-- Description 	: Procedure to delete 'Loan Recovery' EE                --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_loan_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure          VARCHAR2(100);
  l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  l_ee_ovn             pay_element_entries_f.object_version_number%TYPE;
  l_eff_start_date     DATE;
  l_eff_end_date       DATE;
  l_start_date         DATE;
  l_delete_warning     BOOLEAN;

  CURSOR c_ee_dtls IS
  SELECT pee.element_entry_id
  FROM   pay_element_entries_f pee
	    ,pay_input_values_f piv
        ,pay_element_entry_values_f peev
  WHERE  pee.assignment_id = g_assignment_id
  AND    pee.element_entry_id = peev.element_entry_id
  AND    peev.input_value_id = piv.input_value_id
  AND    piv.name = 'Component Name'
  AND    peev.screen_entry_value = 'Loan at Concessional Rate'
  AND    p_actual_termination_date BETWEEN pee.effective_start_date
                                   AND     pee.effective_end_date
  AND    p_actual_termination_date BETWEEN piv.effective_start_date
                                   AND     piv.effective_end_date
  AND    p_actual_termination_date BETWEEN peev.effective_start_date
                                   AND     peev.effective_end_date;

  l_ee_id    pay_element_entries_f.element_entry_id%TYPE;

  CURSOR c_iv_dtls (p_element_entry_id IN NUMBER
                  , p_name IN VARCHAR2)
  IS
  SELECT peev.screen_entry_value
  FROM   pay_element_entry_values_f peev
	    ,pay_input_values_f piv
  WHERE  peev.element_entry_id = p_element_entry_id
  AND    peev.input_value_id  = piv.input_value_id
  AND    piv.NAME = p_name
  AND    p_actual_termination_date BETWEEN peev.effective_start_date
                                   AND     peev.effective_end_date
  AND    p_actual_termination_date BETWEEN piv.effective_start_date
                                   AND     piv.effective_end_date;

  l_loan_number    pay_element_entry_values_f.screen_entry_value%TYPE;
  l_loan_type      pay_element_entry_values_f.screen_entry_value%TYPE;


BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_loan_entry' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_element_name := g_loan_et;

--
-- Fetch the Loan Number and Loan Type for each loan
--
  OPEN c_ee_dtls;
  LOOP
     FETCH c_ee_dtls
     INTO  l_ee_id;
     EXIT WHEN c_ee_dtls%NOTFOUND;

     OPEN c_iv_dtls (l_ee_id, 'Loan Number');
     FETCH c_iv_dtls INTO l_loan_number;
     CLOSE c_iv_dtls;

     OPEN c_iv_dtls (l_ee_id, 'Loan Type');
     FETCH c_iv_dtls INTO l_loan_type;
     CLOSE c_iv_dtls;

     IF check_ee_exists
                    (p_element_name     => l_element_name
		            ,p_input_value_name => 'Loan Number'
		            ,p_input_value      => l_loan_number
                    ,p_assignment_id    => g_assignment_id
    	            ,p_effective_date   => p_actual_termination_date
                    ,p_element_entry_id => l_element_entry_id
                    ,p_start_date       => l_start_date
                    ,p_ee_ovn           => l_ee_ovn)
     THEN
        pay_in_utils.set_location(g_debug,l_procedure,20);
        IF g_debug THEN
          pay_in_utils.trace('Element Entry ID ',to_char(l_element_entry_id));
        END IF;
     IF NOT is_element_processed
                              (p_assignment_id    =>g_assignment_id,
                               p_element_name     =>l_element_name)
     THEN
        pay_element_entry_api.delete_element_entry
              (p_datetrack_delete_mode => hr_api.g_zap
              ,p_effective_date        => l_start_date
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ee_ovn
              ,p_effective_start_date  => l_eff_start_date
              ,p_effective_end_date    => l_eff_end_date
              ,p_delete_warning        => l_delete_warning
               ) ;
        END IF ;
        pay_in_utils.set_location(g_debug,l_procedure,30);

     END IF;
  END LOOP;
  CLOSE c_ee_dtls;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

END delete_loan_entry;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PF_LEAV_REASONS                               --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Internal Proc to be called for validating the PF    --
--                  leaving reason before termination                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id        NUMBER                --
--                  p_business_group_id           NUMBER                --
--                  p_actual_termination_date     DATE                  --
--                  p_assignment_id               NUMBER                --
--                  p_calling_procedure           VARCHAR2              --
--            OUT : p_message_name           VARCHAR2                   --
--                  p_token_name             pay_in_utils.char_tab_type --
--                  p_token_value            pay_in_utils.char_tab_type --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   28-Aug-07  sivanara   Created this procedure                   --
-- 1.1   25-Sep-07  rsaharay   Modified c_emp_mon_pf_pos_dtls           --
--------------------------------------------------------------------------
PROCEDURE check_PF_leav_reasons(p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
	     ,p_assignment_id           IN NUMBER
	     ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
CURSOR c_emp_mon_pf_pos_dtls IS
     SELECT ppf.per_information15
	   ,pos.pds_information1
	   ,pos.pds_information2
     FROM   per_periods_of_service pos
	   ,per_assignments_f paf
	   ,per_people_f ppf
	   ,hr_soft_coding_keyflex  scl
     WHERE  pos.period_of_service_id = p_period_of_service_id
     AND    pos.business_group_id    = p_business_group_id
     AND    paf.assignment_id        = p_assignment_id
     AND    pos.period_of_service_id = paf.period_of_service_id
     AND    paf.person_id            = ppf.person_id
     AND    scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
     AND    scl.enabled_flag = 'Y'
     AND    scl.segment2 IS NOT NULL
     AND    ppf.per_information15 IS NOT NULL
     AND   (to_char(paf.effective_start_date,'Month-YYYY')=to_char(p_actual_termination_date,'Month-YYYY')
         OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(p_actual_termination_date,'Month-YYYY')
         OR  p_actual_termination_date between paf.effective_start_date and paf.effective_end_date)
     AND    p_actual_termination_date  BETWEEN ppf.effective_start_date
                              AND     ppf.effective_end_date;

  l_procedure      VARCHAR2(100);
  l_NSSN           per_people_f.per_information15%TYPE;
  l_print_leav_reas VARCHAR2(50);
  l_efile_leav_reas VARCHAR2 (50);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'check_PF_leav_reasons' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
     pay_in_utils.trace('Period of service id ',to_char(p_period_of_service_id));
     pay_in_utils.trace('Business Group  ID   ',to_char(p_business_group_id));
     pay_in_utils.trace('Effective Date       ',to_char(p_actual_termination_date, 'DD-MM-YYYY'));
     pay_in_utils.trace('Assignment ID        ',to_char(p_assignment_id));
      pay_in_utils.trace('Calling Procedure   ',p_calling_procedure);
  END IF;

  pay_in_utils.set_location(g_debug,l_procedure,20);

  OPEN c_emp_mon_pf_pos_dtls;
  FETCH c_emp_mon_pf_pos_dtls
  INTO  l_NSSN, l_print_leav_reas, l_efile_leav_reas;
  CLOSE c_emp_mon_pf_pos_dtls;

  IF l_NSSN IS NOT NULL AND  (l_print_leav_reas IS NULL OR l_efile_leav_reas IS NULL) THEN
     p_message_name  := 'PER_IN_PF_LEAV_REASON';
     pay_in_utils.set_location(g_debug,l_procedure,30);
  END IF;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
END check_PF_leav_reasons;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_TERMINATION_ELEMENTS                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to handle creation of Termination EE for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
-- 1.1   28-AUG-07  sivanara  Added code for validation of Monthly PF   --
--                            returns leaving reasons                   --
--------------------------------------------------------------------------
PROCEDURE create_termination_elements
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     )
IS
  l_procedure          VARCHAR2(100);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'create_termination_elements' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  get_pos_dtls(p_period_of_service_id    => p_period_of_service_id
              ,p_business_group_id       => p_business_group_id
              ,p_effective_date          => p_actual_termination_date
	      );

  IF g_debug THEN
     pay_in_utils.trace('Period of service id ',to_char(p_period_of_service_id));
     pay_in_utils.trace('Business Group  ID   ',to_char(p_business_group_id));
     pay_in_utils.trace('Act Term Date        ',to_char(p_actual_termination_date, 'DD-MM-YYYY'));
     pay_in_utils.trace('Assignment ID        ',to_char(g_assignment_id));
     pay_in_utils.trace('Payroll ID           ',to_char(g_payroll_id));
     pay_in_utils.trace('Hire Date            ',to_char(g_hire_date,'DD-MM-YYYY'));
     pay_in_utils.trace('Notified Term Date   ',to_char(g_notified_date,'DD-MM-YYYY'));
  END IF;

  IF g_notified_date IS NULL THEN
     p_message_name   := 'HR_7207_API_MANDATORY_ARG';
     p_token_name(1)  := 'API_NAME';
     p_token_value(1) := p_calling_procedure;
     p_token_name(2)  := 'ARGUMENT';
     p_token_value(2) := 'Notified Termination Date';
     RETURN;
  END IF;

  check_PF_leav_reasons(p_period_of_service_id    => p_period_of_service_id
                       ,p_business_group_id       => p_business_group_id
                       ,p_actual_termination_date => p_actual_termination_date
	               ,p_assignment_id           => g_assignment_id
	               ,p_calling_procedure       => p_calling_procedure
                       ,p_message_name            => p_message_name
                       ,p_token_name              => p_token_name
                       ,p_token_value             => p_token_value
	                );

  pay_in_utils.set_location(g_debug,l_procedure,15);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_notice_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,l_procedure,20);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_retrenchment_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,l_procedure,30);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_vrs_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,l_procedure,40);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_pension_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,l_procedure,50);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_pf_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,l_procedure,60);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_loan_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );
  pay_in_utils.set_location(g_debug,l_procedure,70);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  create_gratuity_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
 	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);

  create_advances_entry
          (p_period_of_service_id    => p_period_of_service_id
          ,p_business_group_id       => p_business_group_id
          ,p_actual_termination_date => p_actual_termination_date
          ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
           );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);



END create_termination_elements;

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_TERMINATION_ELEMENTS                           --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete all Termination Element entries   --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_termination_elements
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              )
IS
  l_procedure      VARCHAR2(100);

BEGIN
  g_debug     := hr_utility.debug_enabled ;
  l_procedure := g_package || 'delete_termination_elements' ;
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  get_pos_dtls(p_period_of_service_id    => p_period_of_service_id
              ,p_business_group_id       => p_business_group_id
              ,p_effective_date          => p_actual_termination_date
	      );


  delete_notice_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,20);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_retrenchment_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,30);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_vrs_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,40);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_pension_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,50);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_pf_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,60);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_loan_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,70);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

  delete_gratuity_entry
          (p_period_of_service_id    => p_period_of_service_id
	      ,p_business_group_id       => p_business_group_id
	      ,p_actual_termination_date => p_actual_termination_date
	      ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,l_procedure,80);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);
  p_message_name := 'SUCCESS';
  pay_in_utils.null_message (p_token_name, p_token_value);

    delete_advances_entry
          (p_period_of_service_id    => p_period_of_service_id
          ,p_business_group_id       => p_business_group_id
          ,p_actual_termination_date => p_actual_termination_date
          ,p_calling_procedure       => p_calling_procedure
          ,p_message_name            => p_message_name
          ,p_token_name              => p_token_name
          ,p_token_value             => p_token_value
          );

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
  pay_in_utils.raise_message(800, p_message_name, p_token_name, p_token_value);


END delete_termination_elements;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_value_on_termination                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return balance value as of the          --
--                  termination month.                                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                NUMBER               --
--                  p_end_date                     DATE                 --
--                  p_balance_name                 VARCHAR2             --
--                  p_dimension_name               VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06-Jan-05  lnagaraj   Created this function                    --
--------------------------------------------------------------------------
FUNCTION get_value_on_termination
    (p_assignment_id      IN NUMBER
    ,p_end_date IN DATE
    ,p_balance_name IN VARCHAR2
    ,p_dimension_name IN VARCHAR2
    )
RETURN NUMBER
IS

CURSOR c_max_asact IS
SELECT MAX(paa.assignment_action_id)
  FROM pay_payroll_Actions ppa
      ,pay_assignment_actions paa
 WHERE paa.assignment_id =p_assignment_id
   AND paa.payroll_action_id = ppa.payroll_Action_id
   AND ppa.action_type in('R','Q')
   AND TRUNC(ppa.date_earned,'MM') = TRUNC(p_end_date,'MM')
   AND ppa.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')-- Added as a part of bug fix 4774108
   AND paa.source_action_id IS NULL;


   l_asg_action_id NUMBER;
   l_def_bal_id NUMBER;
   l_value NUMBER;
   g_debug BOOLEAN;
   l_procedure      VARCHAR2(100);
   g_package VARCHAR2(100);

BEGIN
   --
   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package||'get_value_on_termination';
   pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

   l_def_bal_id := pay_in_tax_utils.get_defined_balance(p_balance_name, p_dimension_name);
   pay_in_utils.set_location(g_debug, l_procedure,20);
   IF g_debug THEN
      pay_in_utils.trace('l_def_bal_id ',l_def_bal_id);
   END IF ;

   OPEN c_max_asact;
   FETCH c_max_asact INTO l_asg_action_id;
   CLOSE c_max_asact;
   pay_in_utils.set_location(g_debug, l_procedure,30);
   IF g_debug THEN
      pay_in_utils.trace('l_asg_action_id ',l_asg_action_id);
   END IF ;

   l_value := pay_balance_pkg.get_value(l_def_bal_id,l_asg_action_id);
   pay_in_utils.set_location(g_debug, l_procedure,40);
   IF g_debug THEN
      pay_in_utils.trace('l_value ',l_value);
   END IF ;

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);

   RETURN l_value;
   --
EXCEPTION
   WHEN OTHERS THEN
        RETURN null;

END get_value_on_termination;

--

END pay_in_termination_pkg;

/
