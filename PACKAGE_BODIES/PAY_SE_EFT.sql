--------------------------------------------------------
--  DDL for Package Body PAY_SE_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_EFT" as
 /* $Header: pyseeftp.pkb 120.0.12000000.1 2007/01/18 01:19:51 appldev noship $ */
 l_package        CONSTANT varchar2(33) := 'PAY_SE_PAYFILE.';

  -- Global Variables
 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
 FUNCTION get_parameter(p_payroll_action_id   NUMBER,
                       p_token_name          VARCHAR2) RETURN VARCHAR2 AS

CURSOR csr_parameter_info(p_pact_id IN NUMBER) IS
SELECT legislative_parameters
FROM   pay_payroll_actions
WHERE  payroll_action_id = p_pact_id;

l_token_value                     VARCHAR2(50);
l_parameter  pay_payroll_actions.legislative_parameters%TYPE := NULL;
l_delimiter  varchar2(1);
l_start_pos  NUMBER;
--

BEGIN
--
   l_delimiter :=' ';
  hr_utility.set_location('p_token_name = ' || p_token_name,20);
  OPEN csr_parameter_info(p_payroll_action_id);
  FETCH csr_parameter_info INTO l_parameter;
  CLOSE csr_parameter_info;
  l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
 IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||l_parameter,l_delimiter||p_token_name||'=');
  end if;
  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + length(p_token_name||'=');
    l_token_value := substr(l_parameter,
                          l_start_pos,
                          instr(l_parameter||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
                          end if;

--
     l_token_value := trim(l_token_value);
--
  hr_utility.set_location('l_token_value = ' || l_token_value,20);
  hr_utility.set_location('Leaving         ' || 'get_parameters',30);

  RETURN l_token_value;

END get_parameter;
end PAY_SE_EFT;

/
