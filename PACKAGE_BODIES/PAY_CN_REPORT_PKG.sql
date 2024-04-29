--------------------------------------------------------
--  DDL for Package Body PAY_CN_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_REPORT_PKG" AS
/* $Header: pycnrept.pkb 120.4 2006/12/22 07:09:25 rpalli noship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the value of a particular        --
--                  balance from PAY_ACTION_INFORMATION                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_balance_name                VARCHAR2              --
--                  p_dimension_name              VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 13-SEP-2003    statkar   Initial Version                       --
-- 115.1 12-May-2006    rpalli    Bug#5219815:Modified code to return   --
--                                correct value based on session lang   --
-- 115.2 19-Dec-2006    rpalli    Bug#5724500:Modified code to return   --
--                                balance reporting name                --
-- 115.3 22-Dec-2006    rpalli    Bug#5724500:Removed to_number error   --
--------------------------------------------------------------------------
FUNCTION get_balance_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_balance_name              IN VARCHAR2
                       ,p_dimension_name            IN VARCHAR2 DEFAULT 'PTD'
		       )
RETURN NUMBER
IS

     CURSOR csr_bal(c_balance_name VARCHAR2) IS
            SELECT DECODE(p_dimension_name,
	                     'PTD', action_information5,
	                     'YTD', action_information4) value
            FROM   pay_action_information pai
	    WHERE  pai.action_context_id = p_assignment_action_id
	    AND    pai.action_context_type = 'AAP'
	    AND    pai.action_information_category = 'APAC BALANCES'
	    AND    pai.action_information1 = c_balance_name;

     CURSOR csr_bal_name IS
         SELECT nvl(pbtl.reporting_name,pbtl.balance_name)
         FROM  pay_balance_types pbt,
               pay_balance_types_tl pbtl
         WHERE pbt.balance_name  = p_balance_name
         AND   pbt.legislation_code = 'CN'
         AND   pbt.balance_type_id = pbtl.balance_type_id
         AND   pbtl.language = userenv('LANG');

     l_value   pay_action_information.action_information4%TYPE;
     l_procedure_name VARCHAR2(50);
     l_message        VARCHAR2(255);
     l_balance_name   VARCHAR2(255);
BEGIN

   l_procedure_name := g_package_name||'get_balance_value';
   hr_utility.set_location( 'Entering:'|| l_procedure_name, 10);

   OPEN csr_bal_name;
   FETCH csr_bal_name
   INTO  l_balance_name;
   CLOSE csr_bal_name;

   OPEN csr_bal(l_balance_name);
   FETCH csr_bal
   INTO  l_value;
   CLOSE csr_bal;

   hr_utility.trace ('      Balance Value : '||l_value);
   hr_utility.set_location( 'Leaving:'|| l_procedure_name, 20);
   RETURN fnd_number.canonical_to_number(NVL(l_value,'0'));

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location( 'Leaving:'|| l_procedure_name, 30);
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace (l_message);
      RAISE;
END get_balance_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ELEMENT_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the 'Pay Value' of a particular  --
--                  element from PAY_ACTION_INFORMATION                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_element_name                VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 13-SEP-2003    statkar   Initial Version                       --
-- 115.1 12-May-2006    rpalli    Bug#5219815:Modified code to return   --
--                                correct value based on session lang   --
-- 115.2 18-Dec-2006    rpalli    Bug#5717755:Modified code to return   --
--                                single value in cursor                --
-- 115.3 22-Dec-2006    rpalli    Bug#5724500:Removed to_number error   --
--------------------------------------------------------------------------
FUNCTION get_element_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_element_name              IN VARCHAR2
		       )
RETURN NUMBER
IS

     CURSOR csr_elem(c_element_name VARCHAR2) IS
            SELECT action_information5 value
            FROM   pay_action_information pai
	    WHERE  pai.action_context_id = p_assignment_action_id
	    AND    pai.action_context_type = 'AAP'
	    AND    pai.action_information_category = 'APAC ELEMENTS'
	    AND    pai.action_information1 = c_element_name
	    AND    pai.action_information7 IS NULL;

     CURSOR csr_elem_name IS
         SELECT petl.element_name
         FROM  pay_element_types_f pet,
               pay_element_types_f_tl petl
         WHERE pet.element_name  = p_element_name
         AND   pet.legislation_code = 'CN'
         AND   pet.element_type_id = petl.element_type_id
         AND   petl.language = userenv('LANG');

     l_value   pay_action_information.action_information4%TYPE;
     l_procedure_name VARCHAR2(50);
     l_message        VARCHAR2(255);
     l_element_name   VARCHAR2(255);
BEGIN

   l_procedure_name := g_package_name||'get_element_value_1';
   hr_utility.set_location( 'Entering:'|| l_procedure_name, 10);

   OPEN csr_elem_name;
   FETCH csr_elem_name
   INTO  l_element_name;
   CLOSE csr_elem_name;

   OPEN csr_elem(l_element_name);
   FETCH csr_elem
   INTO  l_value;
   CLOSE csr_elem;

   hr_utility.trace ('      Element Value : '||l_value);
   hr_utility.set_location( 'Leaving:'|| l_procedure_name, 20);

   RETURN fnd_number.canonical_to_number(NVL(l_value,'0'));

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location( 'Leaving:'|| l_procedure_name, 30);
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace (l_message);
      RAISE;
END get_element_value;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ELEMENT_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the specified input value of a   --
--                  particular element from PAY_ACTION_INFORMATION      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_element_name                VARCHAR2              --
--                  p_input_value_name            VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 13-SEP-2003    statkar   Initial Version                       --
-- 115.1 12-May-2006    rpalli    Bug#5219815:Modified code to return   --
--                                correct value based on session lang   --
-- 115.2 22-Dec-2006    rpalli    Bug#5724500:Removed to_number error   --
--------------------------------------------------------------------------
FUNCTION get_element_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_element_name              IN VARCHAR2
		       ,p_input_value_name          IN VARCHAR2
		       )
RETURN NUMBER
IS

     CURSOR csr_elem(c_element_name VARCHAR2) IS
            SELECT action_information5 value
            FROM   pay_action_information pai
	    WHERE  pai.action_context_id = p_assignment_action_id
	    AND    pai.action_context_type = 'AAP'
	    AND    pai.action_information_category = 'APAC ELEMENTS'
	    AND    pai.action_information1 = c_element_name
	    AND    pai.action_information7 = p_input_value_name;

     CURSOR csr_elem_name IS
         SELECT petl.element_name
         FROM pay_element_types_f pet,
              pay_element_types_f_tl petl
         WHERE pet.element_name  = p_element_name
         AND   pet.legislation_code = 'CN'
         AND   pet.element_type_id = petl.element_type_id
         AND   petl.language = userenv('LANG');

     l_value   pay_action_information.action_information4%TYPE;
     l_procedure_name VARCHAR2(50);
     l_message        VARCHAR2(255);
     l_element_name   VARCHAR2(255);
BEGIN

   l_procedure_name := g_package_name||'get_element_value_2';
   hr_utility.set_location( 'Entering:'|| l_procedure_name, 10);

   OPEN csr_elem_name;
   FETCH csr_elem_name
   INTO  l_element_name;
   CLOSE csr_elem_name;

   OPEN csr_elem(l_element_name);
   FETCH csr_elem
   INTO  l_value;
   CLOSE csr_elem;

   hr_utility.trace ('      Element Value : '||l_value);
   hr_utility.set_location( 'Leaving:'|| l_procedure_name, 20);

   RETURN fnd_number.canonical_to_number(NVL(l_value,'0'));

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location( 'Leaving:'|| l_procedure_name, 30);
      l_message := hr_cn_api.get_pay_message('HR_374610_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure_name, 'SQLERRMC:'||sqlerrm);
      hr_utility.trace (l_message);
      RAISE;
END get_element_value;

END pay_cn_report_pkg;

/
