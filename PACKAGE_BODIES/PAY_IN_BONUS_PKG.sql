--------------------------------------------------------
--  DDL for Package Body PAY_IN_BONUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_BONUS_PKG" AS
/* $Header: pyinbonp.pkb 120.1 2006/04/27 03:52:10 rpalli noship $ */

--
-- Globals
--
g_package   constant VARCHAR2(100) := 'pay_in_bonus_pkg.' ;
g_debug     BOOLEAN ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return earn date                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date_earned         DATE                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev# Date        Userid   Bug       Description                      --
--------------------------------------------------------------------------
-- 1.0  29-Sep-2004 abhjain  3826333   Created                          --
--------------------------------------------------------------------------
FUNCTION get_date_earned
            (p_date_earned      IN DATE)
RETURN DATE
IS
l_procedure VARCHAR2(100);
--
BEGIN
  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'get_date_earned' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_date_earned            : ',p_date_earned);
  pay_in_utils.trace('******************************','********************');
end if;

  RETURN trunc(p_date_earned);
END get_date_earned;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to balance value for bonus                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id    number                           --
--                : p_date_earned      date                             --
--            OUT : p_last_earn_date   date                             --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0  29-Sep-2004 abhjain  3826333   Created                          --
--------------------------------------------------------------------------
FUNCTION get_balance_value
            (p_date_earned      IN DATE
            ,p_assignment_id    IN NUMBER
            ,p_last_earn_date   OUT NOCOPY DATE)
RETURN NUMBER
IS
CURSOR c_defined_balance_id IS
SELECT pdb.defined_balance_id
  FROM pay_defined_balances   pdb
      ,pay_balance_types      pbt
      ,pay_balance_dimensions pbd
 WHERE pdb.legislation_code = 'IN'
   AND pbt.legislation_code = 'IN'
   AND pbd.legislation_code = 'IN'
   AND pdb.balance_type_id = pbt.balance_type_id
   AND pbt.balance_name = 'F16 Gross Salary less Allowances'
   AND pdb.balance_dimension_id = pbd.balance_dimension_id
   AND pbd.database_item_suffix = '_ASG_RUN';

CURSOR c_assign_action(p_fy_start_date DATE) IS
select paa1.assignment_action_id
      ,ppa1.date_earned
  from pay_assignment_actions paa1
      ,pay_payroll_actions    ppa1
 where ppa1.payroll_action_id = paa1.payroll_action_id
    and assignment_action_id = (SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions paa
      ,pay_payroll_actions    ppa
 WHERE paa.assignment_id = p_assignment_id
   AND ppa.payroll_action_id = paa.payroll_action_id
   AND ppa.date_earned BETWEEN p_fy_start_date
                           AND p_date_earned
   AND ppa.action_type IN ('Q','R','B','V','I')
   AND ppa.action_status  = 'C'
   AND paa.action_status  = 'C') ;

l_assignment_action_id NUMBER;
l_balance_value        NUMBER := 0;
l_defined_balance_id   NUMBER;
l_last_earn_date       DATE;
l_fy_start_date        DATE;
l_procedure            VARCHAR2(100);
l_message     VARCHAR2(255);

BEGIN

  g_debug := hr_utility.debug_enabled ;
  l_procedure := g_package || 'get_date_earned' ;
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('p_date_earned              : ',p_date_earned);
  pay_in_utils.trace('p_assignment_id            : ',p_assignment_id);
  pay_in_utils.trace('******************************','********************');
end if;

IF to_number(to_char(p_date_earned,'mm')) > 3 THEN
  l_fy_start_date := to_date('01-04-'||to_char(p_date_earned,'YYYY'),'dd-mm-yyyy');
ELSE
  l_fy_start_date := add_months(to_date('01-04-'||to_char(p_date_earned,'YYYY'),'dd-mm-yyyy'),-12);
END IF;

if g_debug then
  pay_in_utils.trace('l_fy_start_date            : ',l_fy_start_date);
end if;

OPEN c_assign_action(l_fy_start_date);
  FETCH c_assign_action INTO l_assignment_action_id, l_last_earn_date;
CLOSE c_assign_action;

if g_debug then
  pay_in_utils.trace('l_assignment_action_id            : ',l_assignment_action_id);
  pay_in_utils.trace('l_last_earn_date                  : ',l_last_earn_date);
end if;

OPEN c_defined_balance_id;
  FETCH c_defined_balance_id INTO l_defined_balance_id;
CLOSE c_defined_balance_id;

if g_debug then
  pay_in_utils.trace('l_defined_balance_id                  : ',l_defined_balance_id);
end if;

l_balance_value := pay_balance_pkg.get_value(p_defined_balance_id   => l_defined_balance_id
                                            ,p_assignment_action_id => l_assignment_action_id);

if g_debug then
  pay_in_utils.trace('******************************','********************');
  pay_in_utils.trace('l_balance_value                  : ',l_balance_value);
  pay_in_utils.trace('l_last_earn_date                 : ',l_last_earn_date);
  pay_in_utils.trace('******************************','********************');
end if;

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

p_last_earn_date := NVL(l_last_earn_date, to_date('31-12-4712','dd-mm-yyyy'));
RETURN l_balance_value;

Exception
  when others then
    p_last_earn_date := to_date('31-12-4712','dd-mm-yyyy');
    l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
    pay_in_utils.trace(l_message,l_procedure);
    RETURN 0;

END get_balance_value;


END pay_in_bonus_pkg;

/
