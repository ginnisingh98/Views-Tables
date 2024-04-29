--------------------------------------------------------
--  DDL for Package Body PAY_IN_FORM_24Q_WEB_ADI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_FORM_24Q_WEB_ADI" AS
/* $Header: pyinwadi.pkb 120.17 2007/11/22 06:33:43 rsaharay noship $ */
g_package          CONSTANT VARCHAR2(100) := 'pay_in_form_24q_web_adi.';
g_debug            BOOLEAN ;
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ASSESSMENT_YEAR                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the assessment year              --
--                                                                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_assessment_year
RETURN VARCHAR2
IS
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);

BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_assessment_year';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('Assessment Year is :',g_assessment_year);
        pay_in_utils.trace('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   RETURN g_assessment_year;
END get_assessment_year;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_ASSESSMENT_YEAR                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to set the assessment year                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : VARCHAR2                                            --
---------------------------------------------------------------------------
PROCEDURE set_assessment_year(p_assessment_year  VARCHAR2)
IS
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug         := hr_utility.debug_enabled;
   l_procedure     := g_package ||'set_assessment_year';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   g_assessment_year := p_assessment_year;
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_assessment_year is :',p_assessment_year);
        pay_in_utils.trace('g_assessment_year is :',g_assessment_year);
        pay_in_utils.trace('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
END set_assessment_year;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EE_VALUE                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the element entry value          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--                  p_input_name        VARCHAR2                        --
--                  p_effective_date    DATE                            --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_ee_value
         (p_element_entry_id  IN NUMBER
         ,p_input_name        IN VARCHAR2
         ,p_effective_date    IN DATE
         )
RETURN VARCHAR2
IS
   CURSOR c_entry_value
   IS
   SELECT val.screen_entry_value
   FROM   pay_element_entry_values_f val
         ,pay_input_values_f inputs
   WHERE  val.input_value_id   = inputs.input_value_id
     AND  val.element_entry_id = p_element_entry_id
     AND  inputs.name = p_input_name
     AND  inputs.legislation_code = 'IN'
     AND  p_effective_date between val.effective_start_date AND val.effective_end_date
     AND  p_effective_date between inputs.effective_start_date AND inputs.effective_end_date;
--
   l_screen_entry_value  pay_element_entry_values_f.screen_entry_value%TYPE := NULL;
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);
BEGIN
    g_debug     := hr_utility.debug_enabled;
    l_procedure := g_package ||'get_ee_value';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF (g_debug)
    THEN
         pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_element_entry_id ', p_element_entry_id);
         pay_in_utils.trace('p_input_name       ', p_input_name);
         pay_in_utils.trace('p_effective_date   ', p_effective_date);
    END IF;

    OPEN  c_entry_value;
    FETCH c_entry_value INTO l_screen_entry_value;
    CLOSE c_entry_value;

    IF (g_debug)
    THEN
         pay_in_utils.trace('Screen Entry Value is :',l_screen_entry_value);
         pay_in_utils.trace('**************************************************','********************');
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
    RETURN l_screen_entry_value;
END get_ee_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ORG_ID                                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the organization id               -
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_tan_number   VARCHAR2                             --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_org_id
         (p_tan_number   IN VARCHAR2
         )
RETURN VARCHAR2
IS
   CURSOR c_tan_number
   IS
      SELECT hou.organization_id
      FROM   hr_organization_units hou
            ,hr_organization_information hoi
      WHERE hou.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
        AND hoi.organization_id = hou.organization_id
        AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
        AND hoi.org_information1 = p_tan_number;

   l_organization_id  VARCHAR2(255);
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);
BEGIN
    g_debug     := hr_utility.debug_enabled;
    l_procedure := g_package ||'get_org_id';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF (g_debug)
    THEN
         pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_tan_number ', p_tan_number);
    END IF;

    OPEN  c_tan_number;
    FETCH c_tan_number INTO l_organization_id;
    CLOSE c_tan_number;

    IF (g_debug)
    THEN
         pay_in_utils.trace('l_organization_id',l_organization_id);
         pay_in_utils.trace('**************************************************','********************');
    END IF;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);

    RETURN NVL(l_organization_id,'%');
END get_org_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAN_NUMBER                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tan number for an organization-
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--                  p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tan_number
         (p_assignment_id    IN NUMBER
         ,p_effective_date   IN DATE
         )
RETURN VARCHAR2
IS
   CURSOR  c_tan_number
   IS
      SELECT hoi.org_information1
      FROM   hr_organization_units hou
            ,hr_organization_information hoi
            ,per_assignments_f asg
            ,hr_soft_coding_keyflex scl
      WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
        AND asg.business_group_id = hou.business_group_id
        AND asg.assignment_id = p_assignment_id
        AND TO_NUMBER(scl.segment1) = hoi.organization_id
        AND hoi.organization_id = hou.organization_id
        AND hoi.org_information_context = 'PER_IN_INCOME_TAX_DF'
        AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
        AND p_effective_date BETWEEN hou.date_from AND NVL(date_to,TO_DATE('31-12-4712','DD-MM-YYYY'));
--
  l_tan_number    hr_organization_information.org_information1%TYPE;
  l_procedure     VARCHAR2(250);
  l_message       VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_tan_number';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
         pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
         pay_in_utils.trace('**************************************************','********************');
         pay_in_utils.trace('p_assignment_id  ',p_assignment_id);
         pay_in_utils.trace('p_effective_date ',p_effective_date);
   END IF;

   OPEN  c_tan_number;
   FETCH c_tan_number INTO l_tan_number;
   CLOSE c_tan_number;

   IF (g_debug)
   THEN
         pay_in_utils.trace('l_tan_number',l_tan_number);
         pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
   RETURN l_tan_number;
END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAN_NUMBER_EE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tan number for an organization-
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id NUMBER                           --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tan_number_ee
         (p_element_entry_id    IN NUMBER
         )
RETURN VARCHAR2
IS
  CURSOR c_element_details
  IS
     SELECT effective_start_date
           ,assignment_id
      FROM  pay_element_entries_f
     WHERE element_entry_id = p_element_entry_id;

    l_effective_date    DATE;
    l_assignment_id     NUMBER;
    l_ee_payment_date   DATE;
    l_tan_number        hr_organization_information.org_information1%TYPE;
    l_procedure         VARCHAR2(250);
    l_message           VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_tan_number_ee';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF (g_debug)
   THEN
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
   END IF;

    OPEN  c_element_details;
    FETCH c_element_details INTO l_effective_date,l_assignment_id;
    CLOSE c_element_details;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_effective_date',l_effective_date);
        pay_in_utils.trace('l_assignment_id',l_assignment_id);
   END IF;
    l_ee_payment_date := fnd_date.canonical_to_date
                        (
                         get_ee_value(p_element_entry_id
                                     ,'Payment Date'
                                     ,l_effective_date
                                     )
                        );
    pay_in_utils.trace('l_ee_payment_date',l_ee_payment_date);

    l_tan_number := get_tan_number(l_assignment_id
                                  ,l_ee_payment_date
                                  );
    pay_in_utils.trace('l_tan_number',l_tan_number);
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,30);
    RETURN l_tan_number;
END get_tan_number_ee;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the date earned                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id    NUMBER                    --
--         RETURN : DATE                                                --
---------------------------------------------------------------------------
FUNCTION get_date_earned
         (p_assignment_action_id    IN NUMBER
         )
RETURN DATE
IS

   CURSOR   c_date_earned
   IS
    SELECT NVL(ppa.date_earned,ppa.effective_date)
      FROM pay_payroll_actions ppa
          ,pay_assignment_actions paa
          ,pay_action_interlocks pai
     WHERE pai.locking_action_id = p_assignment_action_id
       AND pai.locked_action_id  = paa.assignment_action_id
       AND paa.payroll_action_id = ppa.payroll_action_Id
       AND ppa.action_type IN ('Q','R','A')
       AND ppa.action_status = 'C'
       ORDER BY TO_NUMBER(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id) DESC ;


   l_date_earned                DATE;
   l_procedure                  VARCHAR2(250);
   l_message                    VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_date_earned';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_action_id ',p_assignment_action_id);
   END IF;

      OPEN  c_date_earned;
      FETCH c_date_earned INTO l_date_earned;
      CLOSE c_date_earned;

   IF (g_debug)
   THEN
        pay_in_utils.trace('l_date_earned',l_date_earned);
   END IF;

      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
      RETURN l_date_earned;
END get_date_earned;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED_EE                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the date earned                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--         RETURN : DATE                                                --
---------------------------------------------------------------------------
FUNCTION get_date_earned_ee
         (p_element_entry_id  IN NUMBER
         )
RETURN DATE
IS
  CURSOR c_element_details
  IS
     SELECT effective_start_date
           ,assignment_id
      FROM  pay_element_entries_f
     WHERE element_entry_id = p_element_entry_id;

  CURSOR c_prepayment_record(p_assignment_id  NUMBER
                            ,p_effective_date DATE
                            )
  IS
     SELECT assignment_action_id
       FROM pay_payroll_actions pre_ppa
           ,pay_assignment_actions pre_paa
      WHERE pre_ppa.payroll_action_id = pre_paa.payroll_action_id
        AND pre_paa.assignment_id = p_assignment_id
        AND pre_ppa.action_type IN ('P','U')
        AND pre_ppa.action_status = 'C'
        AND (pre_ppa.date_earned = p_effective_date
             OR
             pre_ppa.effective_date = p_effective_date
            );

  CURSOR c_prepayment_record_one(p_assignment_id   NUMBER
                                ,p_effective_date  DATE
                                ,p_ee_payment_date DATE
                                )
  IS
     SELECT assignment_action_id
       FROM pay_payroll_actions pre_ppa
           ,pay_assignment_actions pre_paa
      WHERE pre_ppa.payroll_action_id = pre_paa.payroll_action_id
        AND pre_paa.assignment_id = p_assignment_id
        AND pre_ppa.action_type IN ('P','U')
        AND pre_ppa.action_status = 'C'
        AND ((pre_ppa.date_earned <= p_ee_payment_date AND pre_ppa.date_earned >= p_effective_date)
             OR
             (pre_ppa.effective_date <= p_ee_payment_date AND pre_ppa.effective_date >= p_effective_date)
            )
        ORDER BY assignment_action_id desc;

  CURSOR c_prepayment_record_two(p_assignment_id   NUMBER
                                ,p_effective_date  DATE
                                ,p_ee_payment_date DATE
                                )
  IS
     SELECT assignment_action_id
       FROM pay_payroll_actions pre_ppa
           ,pay_assignment_actions pre_paa
      WHERE pre_ppa.payroll_action_id = pre_paa.payroll_action_id
        AND pre_paa.assignment_id = p_assignment_id
        AND pre_ppa.action_type IN ('P','U')
        AND pre_ppa.action_status = 'C'
        AND (pre_ppa.date_earned >= p_ee_payment_date
             OR
             pre_ppa.effective_date >= p_ee_payment_date
            )
        ORDER BY assignment_action_id asc;

  CURSOR c_payroll_run_record(p_assignment_id        NUMBER
                             ,p_assignment_action_id NUMBER
                             )
  IS
     SELECT NVL(date_earned,effective_date)
       FROM pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_action_interlocks pai
      WHERE ppa.payroll_action_id = paa.payroll_action_id
        AND paa.assignment_id = p_assignment_id
        AND ppa.action_type IN ('Q','R','A')
        AND ppa.action_status = 'C'
        AND paa.source_action_id IS NOT NULL
        AND pai.locking_action_id = p_assignment_action_id
        AND pai.locked_action_id  = paa.assignment_action_id
	ORDER BY TO_NUMBER(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id) DESC ;


    l_effective_date    DATE;
    l_assignment_id     NUMBER;
    l_ee_payment_date   DATE;
    l_asg_action_id     NUMBER;
    l_date              DATE;
    l_procedure         VARCHAR2(250);
    l_message           VARCHAR2(250);
BEGIN
    g_debug     := hr_utility.debug_enabled;
    l_procedure := g_package ||'get_date_earned_ee';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    IF (g_debug)
    THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
    END IF;

    OPEN  c_element_details;
    FETCH c_element_details INTO l_effective_date,l_assignment_id;
    CLOSE c_element_details;

    IF (g_debug)
    THEN
        pay_in_utils.trace('l_effective_date',l_effective_date);
        pay_in_utils.trace('l_assignment_id',l_assignment_id);
    END IF;

    l_ee_payment_date := fnd_date.canonical_to_date
                        (
                         get_ee_value(p_element_entry_id
                                     ,'Payment Date'
                                     ,l_effective_date
                                     )
                        );

    IF (g_debug)
    THEN
        pay_in_utils.trace('l_ee_payment_date',l_ee_payment_date);
    END IF;

    OPEN  c_prepayment_record(l_assignment_id,l_ee_payment_date);
    FETCH c_prepayment_record INTO l_asg_action_id;
    CLOSE c_prepayment_record;

    IF (g_debug)
    THEN
        pay_in_utils.trace('l_asg_action_id',l_asg_action_id);
    END IF;

    IF (l_asg_action_id IS NULL)
    THEN
        OPEN  c_prepayment_record_one(l_assignment_id,l_effective_date,l_ee_payment_date);
        FETCH c_prepayment_record_one INTO l_asg_action_id;
        CLOSE c_prepayment_record_one;

        IF (g_debug)
        THEN
                pay_in_utils.trace('l_asg_action_id',l_asg_action_id);
        END IF;

        IF (l_asg_action_id IS NULL)
        THEN
                OPEN  c_prepayment_record_two(l_assignment_id,l_effective_date,l_ee_payment_date);
                FETCH c_prepayment_record_two INTO l_asg_action_id;
                CLOSE c_prepayment_record_two;

                IF (g_debug)
                THEN
                        pay_in_utils.trace('l_asg_action_id',l_asg_action_id);
                END IF;
        END IF;
    END IF;

    OPEN  c_payroll_run_record(l_assignment_id,l_asg_action_id);
    FETCH c_payroll_run_record INTO l_date;
    CLOSE c_payroll_run_record;

    IF (g_debug)
    THEN
            pay_in_utils.trace('l_date',l_date);
    END IF;

    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
    RETURN l_date;

END get_date_earned_ee;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the balance value                --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION  get_balance_value(p_assignment_action_id   IN NUMBER
                           ,p_balance_name           IN VARCHAR2
                           ,p_dimension              IN VARCHAR2
                           )
RETURN VARCHAR2
IS

   CURSOR    c_action_type
   IS
      SELECT ppa.action_type
       FROM  pay_payroll_actions ppa
            ,pay_assignment_actions paa
      WHERE  ppa.payroll_action_id = paa.payroll_action_id
        AND  paa.assignment_action_id = p_assignment_action_id
        AND  ppa.action_status = 'C';

   CURSOR    c_master_asg_action_id
   IS
      SELECT pai.locked_action_id assignment_action_id
            ,paa.assignment_id
       FROM  pay_action_interlocks pai
            ,pay_assignment_actions paa
      WHERE  pai.locking_action_id = p_assignment_action_id
        AND  pai.locked_action_id = paa.assignment_action_id
        AND  paa.action_status = 'C'
        AND  paa.source_action_id IS NULL
      ORDER  BY pai.locked_action_id DESC;

   CURSOR    c_child_asg_actions(p_assignment_id        NUMBER
                                ,p_master_asg_act_id    NUMBER
                                )
   IS
      SELECT assignment_action_id child_actions
        FROM pay_assignment_actions
       WHERE assignment_id = p_assignment_id
         AND action_status = 'C'
         AND source_action_id = p_master_asg_act_id;

   l_action_type                pay_payroll_actions.action_type%TYPE;
   l_assignment_action_id       NUMBER;
   l_balance_value              NUMBER;
   l_procedure                  VARCHAR2(250);
   l_message                    VARCHAR2(250);
BEGIN
      g_debug     := hr_utility.debug_enabled;
      l_procedure := g_package ||'get_balance_value';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
      IF (g_debug)
      THEN
           pay_in_utils.trace('**************************************************','********************');
           pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
           pay_in_utils.trace('p_assignment_action_id',p_assignment_action_id);
           pay_in_utils.trace('p_balance_name',p_balance_name);
           pay_in_utils.trace('p_dimension',p_dimension);
      END IF;

      OPEN  c_action_type;
      FETCH c_action_type INTO l_action_type;
      CLOSE c_action_type;

      IF (g_debug)
      THEN
           pay_in_utils.trace('l_action_type',l_action_type);
      END IF;

      IF (l_action_type IN ('P','U'))
      THEN
         l_balance_value := 0;
         FOR c_rec IN c_master_asg_action_id
         LOOP
             FOR c_record IN c_child_asg_actions(c_rec.assignment_id
                                                ,c_rec.assignment_action_id
                                                )
             LOOP
                     l_balance_value := l_balance_value + pay_in_tax_utils.get_balance_value
                                          (
                                           c_record.child_actions
                                          ,p_balance_name
                                          ,p_dimension
                                          ,'NULL'
                                          ,'NULL'
                                          );
             END LOOP;
         END LOOP;
      ELSE
         l_assignment_action_id := p_assignment_action_id;
         l_balance_value := pay_in_tax_utils.get_balance_value
                           (
                            l_assignment_action_id
                           ,p_balance_name
                           ,p_dimension
                           ,'NULL'
                           ,'NULL'
                           );
      END IF;

      IF (g_debug)
      THEN
           pay_in_utils.trace('l_assignment_action_id',l_assignment_action_id);
           pay_in_utils.trace('l_balance_value',l_balance_value);
      END IF;
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
     RETURN TO_CHAR(l_balance_value);

END get_balance_value;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TOTAL_TAX_DEPOSITED                             --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the total tax deposited          --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_total_tax_deposited(p_assignment_action_id IN NUMBER
                                ,p_element_entry_id     IN NUMBER
                                ,p_effective_date       IN DATE DEFAULT NULL
                                )
RETURN VARCHAR2
IS
l_total_tax     NUMBER;
l_procedure     VARCHAR2(250);
l_message       VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_total_tax_deposited';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_assignment_action_id',p_assignment_action_id);
        pay_in_utils.trace('p_element_entry_id',p_element_entry_id);
        pay_in_utils.trace('p_effective_date',p_effective_date);
   END IF;

   IF (p_element_entry_id IS NULL)
   THEN
   --Use the balance values
      l_total_tax := TO_NUMBER(get_balance_value(p_assignment_action_id
                                                ,'Income Tax This Pay'
                                                ,'_ASG_RUN'
                                                )
                              );
      l_total_tax := l_total_tax +
                     TO_NUMBER(get_balance_value(p_assignment_action_id
                                                ,'Surcharge This Pay'
                                                ,'_ASG_RUN'
                                                )
                               );
      l_total_tax := l_total_tax +
                     TO_NUMBER(get_balance_value(p_assignment_action_id
                                                ,'Education Cess This Pay'
                                                ,'_ASG_RUN'
                                                )
                               );
      l_total_tax := l_total_tax +
                     TO_NUMBER(get_balance_value(p_assignment_action_id
                                                ,'TDS on Direct Payments'
                                                ,'_ASG_RUN'
                                                )
                               );
   ELSE
   -- Use Element Entry ID
      l_total_tax := TO_NUMBER(get_ee_value(p_element_entry_id
                                          ,'Income Tax Deducted'
                                          ,p_effective_date
                                           )
                              );
      l_total_tax := l_total_tax +
                     TO_NUMBER(get_ee_value(p_element_entry_id
                                           ,'Surcharge Deducted'
                                           ,p_effective_date
                                           )
                              );
      l_total_tax := l_total_tax +
                     TO_NUMBER(get_ee_value(p_element_entry_id
                                           ,'Education Cess Deducted'
                                           ,p_effective_date
                                           )
                              );
   END IF;

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_total_tax',l_total_tax);
     END IF;
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

     RETURN (TO_CHAR(NVL(l_total_tax,0),fnd_currency.get_format_mask('INR',40)));
END;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BG_ID                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the business group id            --
--                                                                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_bg_id
RETURN NUMBER
IS
 CURSOR  c_bg
 IS
    SELECT FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    FROM   dual;
--
  l_bg          NUMBER;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_bg_id';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   OPEN  c_bg;
   FETCH c_bg INTO l_bg;
   CLOSE c_bg;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_bg',l_bg);
        pay_in_utils.trace('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

   RETURN l_bg;

 END get_bg_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM_24                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create the element as per the details   --
--                  passed from the Web ADI Excel Sheet.                --
---------------------------------------------------------------------------
PROCEDURE create_form_24
        (p_assessment_year              IN VARCHAR2 DEFAULT NULL
        ,p_payroll_name                 IN VARCHAR2 DEFAULT NULL
        ,p_period                       IN VARCHAR2 DEFAULT NULL
        ,p_earned_date                  IN DATE     DEFAULT NULL
        ,p_pre_payment_date             IN DATE
        ,p_employee_id                  IN VARCHAR2
        ,p_employee_name                IN VARCHAR2 DEFAULT NULL
        ,p_taxable_income               IN NUMBER   DEFAULT NULL
        ,p_income_tax_deducted          IN NUMBER   DEFAULT NULL
        ,p_surcharge_deducted           IN NUMBER   DEFAULT NULL
        ,p_education_cess_deducted      IN NUMBER   DEFAULT NULL
        ,p_total_tax_deducted           IN NUMBER   DEFAULT NULL
        ,p_amount_deposited             IN NUMBER
        ,p_voucher_number               IN VARCHAR2
        ,p_correction_flag              IN VARCHAR2
        ,p_last_updated_date            IN DATE     DEFAULT NULL
        ,p_element_entry_id             IN NUMBER   DEFAULT NULL
        ,p_tan_number                   IN VARCHAR2 DEFAULT NULL
        ,p_purge_record                 IN VARCHAR2 DEFAULT NULL
  	,p_assignment_id                IN NUMBER
        )
IS
   --If element entry id id not null, then use it to determine the element details
   CURSOR c_element_details(p_effective_date    DATE,
                            p_business_group_id NUMBER
                            )
   IS
     SELECT element_type_id
           ,element_link_id
           ,asg.assignment_id
           ,entry.object_version_number
     FROM  pay_element_entries_f entry
          ,per_assignments_f asg
     WHERE asg.business_group_id = p_business_group_id
       AND asg.assignment_id = entry.assignment_id
       AND entry.element_entry_id = p_element_entry_id
       AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
       AND p_effective_date BETWEEN entry.effective_start_date AND entry.effective_end_date;


--Get Element Details (type id and link id)
   CURSOR csr_element_details(p_assignment_id    NUMBER
                             ,p_effective_date    DATE
                             )
   IS
   SELECT types.element_type_id
         ,link.element_link_id
   FROM per_assignments_f assgn
      , pay_element_links_f link
      , pay_element_types_f types
   WHERE assgn.assignment_id  = p_assignment_id
     AND link.element_link_id = pay_in_utils.get_element_link_id(p_assignment_id
                                                                ,p_pre_payment_date
                                                                ,types.element_type_id
                                                                )
     AND (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
     AND link.business_group_id = assgn.business_group_id
     AND link.element_type_id = types.element_type_id
     AND types.element_name = 'Income Tax Challan Information'
     AND p_effective_date BETWEEN assgn.effective_start_date AND assgn.effective_end_date
     AND p_effective_date BETWEEN link.effective_start_date  AND link.effective_end_date
     AND p_effective_date BETWEEN types.effective_start_date AND types.effective_end_date;

-- Creating the input value name,id pair records
   CURSOR c_input_rec(p_element_type_id         NUMBER
                     ,p_effective_date          DATE
                     )
   IS
   SELECT inputs.name                   name
        , inputs.input_value_id         id
     FROM pay_element_types_f types
        , pay_input_values_f inputs
    WHERE types.element_type_id = p_element_type_id
      AND inputs.element_type_id = types.element_type_id
      AND inputs.legislation_code = 'IN'
      AND p_effective_date BETWEEN types.effective_start_date  AND types.effective_end_date
      AND p_effective_date BETWEEN inputs.effective_start_date AND inputs.effective_end_date
    ORDER BY inputs.display_sequence;

-- Cursor to retreive the element effective start date
   CURSOR c_effective_start_date
   IS
      SELECT effective_start_date,object_version_number
       FROM  pay_element_entries_f
      WHERE  element_entry_id = p_element_entry_id
      ORDER BY object_version_number DESC;

-- Cursor to determine the employee number
   CURSOR c_check_emp_number(p_element_entry_id         NUMBER
                            ,p_employee_number          VARCHAR2
                            ,p_effective_date           DATE
                            ,p_busines_group_id         NUMBER
                            )
   IS
      SELECT 1
        FROM per_people_f pep
            ,per_assignments_f asg
            ,pay_element_entries_f entry
       WHERE entry.element_entry_id = p_element_entry_id
         AND asg.assignment_id = entry.assignment_id
         AND asg.person_id = pep.person_id
         AND asg.business_group_id = pep.business_group_id
         AND pep.employee_number = p_employee_number
         AND asg.business_group_id = p_busines_group_id
         AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
         AND p_effective_date BETWEEN pep.effective_start_date AND pep.effective_end_date
         AND p_effective_date BETWEEN entry.effective_start_date AND entry.effective_end_date;

--Variables Initialization
   TYPE t_input_values_rec IS RECORD
        (input_name      pay_input_values_f.name%TYPE
        ,input_value_id  pay_input_values_f.input_value_id%TYPE
        );
   TYPE t_input_values_tab IS TABLE OF t_input_values_rec INDEX BY BINARY_INTEGER;

   l_assignment_id              NUMBER;
   l_element_type_id            NUMBER;
   l_element_link_id            NUMBER;
   l_element_entry_id           NUMBER;
   l_input_values_rec           t_input_values_tab;
   l_count                      NUMBER;
   l_effective_date             DATE;
   l_effective_start_date       DATE;
   l_effective_end_date         DATE;
   l_object_version_number      NUMBER;
   l_warnings                   BOOLEAN;
   l_business_group_id          NUMBER;
   l_pre_payment_date           DATE;
   flag                         BOOLEAN;
   l_flag                       NUMBER := NULL;
   l_procedure                  VARCHAR2(250);
   l_message                    VARCHAR2(250);
BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'create_form_24';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
          pay_in_utils.trace('p_assessment_year        ',p_assessment_year        );
          pay_in_utils.trace('p_payroll_name           ',p_payroll_name           );
          pay_in_utils.trace('p_period                 ',p_period                 );
          pay_in_utils.trace('p_earned_date            ',p_earned_date            );
          pay_in_utils.trace('p_pre_payment_date       ',p_pre_payment_date       );
          pay_in_utils.trace('p_employee_id            ',p_employee_id            );
          pay_in_utils.trace('p_employee_name          ',p_employee_name          );
          pay_in_utils.trace('p_taxable_income         ',p_taxable_income         );
          pay_in_utils.trace('p_income_tax_deducted    ',p_income_tax_deducted    );
          pay_in_utils.trace('p_surcharge_deducted     ',p_surcharge_deducted     );
          pay_in_utils.trace('p_education_cess_deducted',p_education_cess_deducted);
          pay_in_utils.trace('p_total_tax_deducted     ',p_total_tax_deducted     );
          pay_in_utils.trace('p_amount_deposited       ',p_amount_deposited       );
          pay_in_utils.trace('p_voucher_number         ',p_voucher_number         );
          pay_in_utils.trace('p_correction_flag        ',p_correction_flag        );
          pay_in_utils.trace('p_last_updated_date      ',p_last_updated_date      );
          pay_in_utils.trace('p_element_entry_id       ',p_element_entry_id       );
          pay_in_utils.trace('p_tan_number             ',p_tan_number             );
          pay_in_utils.trace('p_purge_record           ',p_purge_record           );
          pay_in_utils.trace('p_assignment_id          ',p_assignment_id          );
     END IF;
     flag := FALSE;
     l_effective_date := pay_in_utils.get_effective_date(p_pre_payment_date);
     l_business_group_id :=  get_bg_id();

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_effective_date',l_effective_date);
          pay_in_utils.trace('l_business_group_id',l_business_group_id);
     END IF;
--Record Deletion Starts
     IF (NVL(p_purge_record,'N')= 'Y')
     THEN

            IF (p_element_entry_id IS NOT NULL)
            THEN
                   OPEN  c_effective_start_date;
                   FETCH c_effective_start_date INTO l_pre_payment_date,l_object_version_number;
                   CLOSE c_effective_start_date;

                   IF (g_debug)
                   THEN
                        pay_in_utils.trace('l_pre_payment_date',l_pre_payment_date);
                        pay_in_utils.trace('l_object_version_number',l_object_version_number);
                   END IF;

                   pay_in_utils.set_location(g_debug,'Calling Deletion API',20);

                  --Delete the element entry id.
                  pay_element_entry_api.delete_element_entry
                  (p_validate                   => FALSE
                  ,p_datetrack_delete_mode      => hr_api.g_delete
                  ,p_effective_date             => l_pre_payment_date
                  ,p_element_entry_id           => p_element_entry_id
                  ,p_object_version_number      => l_object_version_number
                  ,p_effective_start_date       => l_effective_start_date
                  ,p_effective_end_date         => l_effective_end_date
                  ,p_delete_warning             => l_warnings
                  );

                  pay_in_utils.set_location(g_debug,'Deletion API Successful',30);
                  pay_in_utils.trace('**************************************************','********************');
                  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
                  RETURN;
            ELSE
                  pay_in_utils.trace('**************************************************','********************');
                  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
                  RETURN;
            END IF;
     END IF;
--Record Deletion ends

     IF (p_element_entry_id IS NOT NULL)
     THEN
        l_pre_payment_date := fnd_date.canonical_to_date(get_ee_value(p_element_entry_id,'Payment Date',l_effective_date));

        IF (g_debug)
        THEN
             pay_in_utils.trace('l_pre_payment_date',l_pre_payment_date);
        END IF;

        OPEN  c_check_emp_number(p_element_entry_id,p_employee_id,l_effective_date,l_business_group_id);
        FETCH c_check_emp_number INTO l_flag;
        CLOSE c_check_emp_number;

        IF (g_debug)
        THEN
             pay_in_utils.trace('l_flag',l_flag);
        END IF;

        IF ((l_pre_payment_date IS NULL) OR (l_flag IS NULL))
        THEN

            OPEN  c_effective_start_date;
            FETCH c_effective_start_date INTO l_pre_payment_date,l_object_version_number;
            CLOSE c_effective_start_date;

            IF (g_debug)
            THEN
                 pay_in_utils.trace('l_pre_payment_date',l_pre_payment_date);
                 pay_in_utils.trace('l_object_version_number',l_object_version_number);
            END IF;
            pay_in_utils.set_location(g_debug,'Calling Deletion API',20);

             --Delete the element entry id.
             pay_element_entry_api.delete_element_entry
                  (p_validate                   => FALSE
                  ,p_datetrack_delete_mode      => hr_api.g_delete
                  ,p_effective_date             => l_pre_payment_date
                  ,p_element_entry_id           => p_element_entry_id
                  ,p_object_version_number      => l_object_version_number
                  ,p_effective_start_date       => l_effective_start_date
                  ,p_effective_end_date         => l_effective_end_date
                  ,p_delete_warning             => l_warnings
                  );
              pay_in_utils.set_location(g_debug,'Deletion API Successful',30);
              flag := TRUE;

        ELSE
                OPEN  c_element_details(l_effective_date,l_business_group_id);
                FETCH c_element_details INTO l_element_type_id,l_element_link_id,l_assignment_id,l_object_version_number;
                CLOSE c_element_details;

                IF (g_debug)
                THEN
                     pay_in_utils.trace('l_element_type_id',l_element_type_id);
                     pay_in_utils.trace('l_element_link_id',l_element_link_id);
                     pay_in_utils.trace('l_assignment_id',l_assignment_id);
                     pay_in_utils.trace('l_object_version_number',l_object_version_number);
                END IF;
        END IF;
     END IF;

     IF ((p_element_entry_id IS NULL) OR (flag))
     THEN

	l_assignment_id := p_assignment_id ;

        IF (g_debug)
        THEN
             pay_in_utils.trace('l_assignment_id',l_assignment_id);
        END IF;

        OPEN  csr_element_details(l_assignment_id,l_effective_date);
        FETCH csr_element_details INTO l_element_type_id,l_element_link_id;
        CLOSE csr_element_details;

        IF (g_debug)
        THEN
             pay_in_utils.trace('l_element_type_id',l_element_type_id);
             pay_in_utils.trace('l_element_link_id',l_element_link_id);
        END IF;

     END IF;

     IF l_element_link_id IS NULL THEN
         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', 'Income Tax Challan Information');
         hr_utility.raise_error;
      END IF;

     --Populate the input value id, name records
     l_count := 1;
     FOR c_rec IN c_input_rec(l_element_type_id,l_effective_date)
     LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_count := l_count + 1;
     END LOOP;

    IF ((p_element_entry_id IS NULL) OR (flag))
    THEN
         pay_element_entry_api.create_element_entry
                 (p_effective_date        => l_effective_date
                 ,p_business_group_id     => l_business_group_id
                 ,p_assignment_id         => l_assignment_id
                 ,p_element_link_id       => l_element_link_id
                 ,p_entry_type            => 'E'
                 ,p_input_value_id1       => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2       => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3       => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4       => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5       => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6       => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7       => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8       => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9       => l_input_values_rec(9).input_value_id
                 ,p_entry_value1          => p_voucher_number
                 ,p_entry_value2          => p_pre_payment_date
                 ,p_entry_value3          => p_taxable_income
                 ,p_entry_value4          => p_income_tax_deducted
                 ,p_entry_value5          => p_surcharge_deducted
                 ,p_entry_value6          => p_education_cess_deducted
                 ,p_entry_value7          => p_amount_deposited
                 ,p_entry_value8          => NVL(p_correction_flag,'N')
                 ,p_entry_value9          => sysdate
                 ,p_effective_start_date  => l_effective_start_date
                 ,p_effective_end_date    => l_effective_end_date
                 ,p_element_entry_id      => l_element_entry_id
                 ,p_object_version_number => l_object_version_number
                 ,p_create_warning        => l_warnings
                 );

              UPDATE pay_element_entry_values_f
                 SET screen_entry_value = fnd_date.date_to_canonical(sysdate)
               WHERE input_value_id     = l_input_values_rec(9).input_value_id
                 AND element_entry_id   = l_element_entry_id;

    ELSIF ((p_element_entry_id IS NOT NULL) AND (flag  = FALSE))
    THEN
         pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_effective_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => p_element_entry_id
                 ,p_object_version_number    => l_object_version_number
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_input_values_rec(9).input_value_id
                 ,p_entry_value1             => p_voucher_number
                 ,p_entry_value2             => p_pre_payment_date
                 ,p_entry_value3             => p_taxable_income
                 ,p_entry_value4             => p_income_tax_deducted
                 ,p_entry_value5             => p_surcharge_deducted
                 ,p_entry_value6             => p_education_cess_deducted
                 ,p_entry_value7             => p_amount_deposited
                 ,p_entry_value8             => NVL(p_correction_flag,'N')
                 ,p_entry_value9             => sysdate
                 ,p_effective_start_date     => l_effective_start_date
                 ,p_effective_end_date       => l_effective_end_date
                 ,p_update_warning           => l_warnings
                 );

              UPDATE pay_element_entry_values_f
                 SET screen_entry_value = fnd_date.date_to_canonical(sysdate)
               WHERE input_value_id     = l_input_values_rec(9).input_value_id
                 AND element_entry_id   = p_element_entry_id;

    END IF;
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
END create_form_24;

END pay_in_form_24q_web_adi;

/
