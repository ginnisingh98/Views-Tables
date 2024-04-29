--------------------------------------------------------
--  DDL for Package Body PAY_FI_TAX_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_TAX_CARD_PKG" as
 /* $Header: pyfitaxr.pkb 120.0 2005/05/29 04:54:28 appldev noship $ */
 g_package                  varchar2(33) := 'PAY_FI_TAX_CARD_PKG.';

  -- Global Variables
 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
 FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1):=' ';
   l_proc VARCHAR2(60):= g_package||'get_parameter ';
 BEGIN
   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   end if;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   RETURN l_parameter;
 END get_parameter;
 --

PROCEDURE range_code(p_payroll_action_id     IN  NUMBER,
                     p_sqlstr OUT NOCOPY VARCHAR2)

IS
BEGIN

p_sqlstr := 'SELECT DISTINCT person_id
      FROM  per_people_f ppf
           ,pay_payroll_actions ppa
      WHERE ppa.payroll_action_id = :payroll_action_id
      AND   ppa.business_group_id = ppf.business_group_id
      ORDER BY ppf.person_id';

END range_code;

FUNCTION get_employment_status(
			 p_assignment_id	IN	NUMBER
			,p_effective_date	IN	DATE)	RETURN	VARCHAR2
IS

CURSOR csr_primary_employment( l_assignment_id NUMBER, l_effective_date DATE) IS
select peev.SCREEN_ENTRY_VALUE
from
pay_element_types_f pet
,pay_element_entries_f  pee
,pay_input_values_f piv
,pay_element_entry_values_f peev
where pee.element_type_id = pet.element_type_id
and pet.element_name = 'Tax'
and pet.legislation_code='FI'
and l_effective_date between pet.effective_start_date and pet.effective_end_date
and l_effective_date between pee.effective_start_date and pee.effective_end_date
and pet.element_type_id = piv.element_type_id
and l_effective_date between piv.effective_start_date and piv.effective_end_date
and piv.name = 'Primary Employment'
and piv.input_value_id = peev.input_value_id
and peev.element_entry_id = pee.element_entry_id
and l_effective_date between peev.effective_start_date and peev.effective_end_date
and assignment_id =  l_assignment_id;

l_primary_employment VARCHAR2(1) := 'X';

BEGIN

	OPEN csr_primary_employment( p_assignment_id, p_effective_date);

	IF csr_primary_employment%NOTFOUND THEN
		l_primary_employment := 'X';
		CLOSE csr_primary_employment;
	ELSE

		FETCH csr_primary_employment INTO l_primary_employment;
		CLOSE csr_primary_employment;
	END IF;

	RETURN l_primary_employment;
END get_employment_status;


PROCEDURE assignment_action_code(
                          pactid    IN NUMBER,
                          stperson  IN NUMBER,
                          endperson IN NUMBER,
                          chunk     IN NUMBER)
IS
BEGIN

null;

END assignment_action_code;
--
END PAY_FI_TAX_CARD_PKG;

/
