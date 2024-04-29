--------------------------------------------------------
--  DDL for Package Body PAY_NO_TC_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_TC_REQ" as
/* $Header: pynotcrq.pkb 120.0 2005/05/29 07:02:21 appldev noship $ */
--
-- Globals
l_package    CONSTANT VARCHAR2(20):= 'PAY_NO_TC_REQ.';
--

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

l_delimiter := ' ';
--

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


  --------------------------------------------------------------------------------+
  -- Range cursor returns the ids of the assignments to be archived
  --------------------------------------------------------------------------------+
  PROCEDURE range_cursor(
                       p_payroll_action_id IN  NUMBER,
                       p_sqlstr            OUT NOCOPY VARCHAR2)
  IS
    l_proc_name VARCHAR2(100);

  BEGIN

    l_proc_name := l_package || 'range_code';


    hr_utility.set_location(l_proc_name, 10);
    p_sqlstr := 'SELECT DISTINCT person_id
                FROM   per_all_people_f    ppf,
                       pay_payroll_actions ppa
                WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND  ppa.business_group_id = ppf.business_group_id
             ORDER BY  ppf.person_id';
    hr_utility.set_location(l_proc_name, 20);
  END range_cursor;
--
 --------------------------------------------------------------------------------+
  -- Creates assignment action id for all the valid person id's in
  -- the range selected by the Range code.
  --------------------------------------------------------------------------------+
  PROCEDURE assignment_action_code(
                                   p_payroll_action_id  IN NUMBER,
                                   p_start_person_id    IN NUMBER,
                                   p_end_person_id      IN NUMBER,
                                   p_chunk_number       IN NUMBER)
  IS
    l_proc_name                VARCHAR2(100);

  BEGIN

  l_proc_name   := l_package || 'assignment_action_code';

    hr_utility.set_location(l_proc_name, 10);

   END assignment_action_code;


end  PAY_NO_TC_REQ;

/
