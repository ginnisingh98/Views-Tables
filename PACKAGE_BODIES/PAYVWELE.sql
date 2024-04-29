--------------------------------------------------------
--  DDL for Package Body PAYVWELE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAYVWELE" AS
/* $Header: payvwele.pkb 115.4 2003/05/09 12:34:49 rsirigir ship $ */
--
--
PROCEDURE forms_startup ( p_assignment_id NUMBER,
                          p_assignment_action_id NUMBER,
			  p_session_date DATE,
                          p_action_date IN OUT NOCOPY DATE,
			  p_per_month IN OUT NOCOPY NUMBER,
			  p_per_qtd IN OUT NOCOPY NUMBER,
			  p_per_ytd IN OUT NOCOPY NUMBER,
			  p_asg_lr IN OUT NOCOPY NUMBER,
			  p_asg_ptd IN OUT NOCOPY NUMBER,
			  p_asg_month IN OUT NOCOPY NUMBER,
			  p_asg_qtd IN OUT NOCOPY NUMBER,
			  p_asg_ytd IN OUT NOCOPY NUMBER,
			  p_asg_itd IN OUT NOCOPY NUMBER,
			  p_asg_gre_itd IN OUT NOCOPY NUMBER,
			  p_tax_unit_id IN OUT NOCOPY NUMBER,
                          p_level      IN VARCHAR2,
                          p_legislation_code IN VARCHAR2) IS
--
-- declare local variables
--
l_session_date DATE;

BEGIN
--
hr_utility.set_location('payvwele.forms_startup', 0);
--
IF p_assignment_action_id = -1 THEN
   l_session_date := get_fpd_or_atd(p_assignment_id, p_session_date);
   IF l_session_date IS NULL THEN   --current employee
      l_session_date := p_session_date;
   ELSIF l_session_date >= p_session_date THEN
      --current employee at p_session_date time
      l_session_date := p_session_date;
   END IF;
ELSE
   l_session_date := p_session_date;
END IF;
--

P_PER_MONTH   := GET_DIM_ID('_PER_'||p_level||'_'||'MONTH',p_legislation_code);
P_PER_QTD     := GET_DIM_ID('_PER_'||p_level||'_'||'QTD',p_legislation_code);
P_PER_YTD     := GET_DIM_ID('_PER_'||p_level||'_'||'YTD',p_legislation_code);
P_ASG_LR      := GET_DIM_ID('_ASG_'||p_level||'_'||'RUN',p_legislation_code);
P_ASG_PTD     := GET_DIM_ID('_ASG_'||p_level||'_'||'PTD',p_legislation_code);
P_ASG_MONTH   := GET_DIM_ID('_ASG_'||p_level||'_'||'MONTH',p_legislation_code);
P_ASG_QTD     := GET_DIM_ID('_ASG_'||p_level||'_'||'QTD',p_legislation_code);
P_ASG_YTD     := GET_DIM_ID('_ASG_'||p_level||'_'||'YTD',p_legislation_code);
P_ASG_ITD     := GET_DIM_ID('_ASG_'||p_level||'_'||'ITD',p_legislation_code);
P_ASG_GRE_ITD := GET_DIM_ID('_ASG_GRE_ITD',p_legislation_code);
--
hr_utility.set_location('payvwele.forms_startup', 1);
--
-- Commented out as the user can now select the GRE in the form,
-- so don't want to be restricted to the GRE of the session date.
--
--p_tax_unit_id := get_tax_unit_id ( p_assignment_id, l_session_date);
--
hr_utility.set_location('payvwele.forms_startup', 2);
--
p_action_date := get_action_date (p_assignment_action_id);
--
hr_utility.set_location('payvwele.forms_startup', 3);
--
END forms_startup;
--
FUNCTION get_tax_unit_id ( p_assignment_id NUMBER,
			   p_session_date  DATE ) RETURN NUMBER IS
--
-- declare local variables
--
l_tax_unit_id NUMBER(9);
--
BEGIN
--
hr_utility.set_location('payvwele.get_tax_unit_id', 0);
--
SELECT	scl.segment1
INTO	l_tax_unit_id
FROM	hr_soft_coding_keyflex scl,
	per_assignments_f paf
where  scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
and    paf.assignment_id = p_assignment_id
and    p_session_date between paf.effective_start_date AND paf.effective_end_date;
--
--
hr_utility.set_location('payvwele.get_tax_unit_id', 1);
--
RETURN l_tax_unit_id;
--
exception
  when NO_DATA_FOUND
  then
  hr_utility.set_message('801', 'PAY_7785_VWELE_NO_GRE');
  hr_utility.raise_error;
END get_tax_unit_id;
--
--
--
FUNCTION get_dim_id (p_dim_suffix IN VARCHAR2, p_legislation_code IN VARCHAR2) RETURN NUMBER is
--
v_dim_id    number(9);
--
begin
--
hr_utility.set_location('payvwele.get_dim_id', 0);
--
select balance_dimension_id
into   v_dim_id
from   pay_balance_dimensions
where  database_item_suffix = p_dim_suffix
and legislation_code = p_legislation_code;  /* bug372487 */

--change for CA use decode
--
hr_utility.set_location('payvwele.get_dim_id', 1);
--
return v_dim_id;
--
exception when no_data_found
 then
  hr_utility.set_message(801, 'PAY_7784_VWELE_NO_BAL_DIM_ID');
  hr_utility.set_message_token('BAL_DIM_ID', p_dim_suffix);
  hr_utility.raise_error;
--
end get_dim_id;
--
--
--
FUNCTION get_action_date (p_assignment_action_id NUMBER) RETURN DATE IS

v_action_date  DATE;

BEGIN
--
--
hr_utility.set_location('payvwele.get_action_date', 0);

IF (p_assignment_action_id = -1) THEN

   hr_utility.set_location('payvwele.get_action_date', 11);
   v_action_date := '';

ELSE

   hr_utility.set_location('payvwele.get_action_date', 12);
   SELECT ppa.effective_date
   INTO   v_action_date
   FROM   pay_payroll_actions ppa,
          pay_assignment_actions paa
   WHERE  paa.assignment_action_id = p_assignment_action_id
   AND    ppa.payroll_action_id = paa.payroll_action_id;

END IF;

hr_utility.set_location('payvwele.get_action_date', 2);
return v_action_date;
--
END get_action_date;
--
--
FUNCTION get_fpd_or_atd(p_assignment_id IN NUMBER,
                        p_session_date IN DATE) RETURN DATE IS

CURSOR get_fpd_or_atd IS
SELECT pps.final_process_date
FROM per_periods_of_service pps
WHERE date_start <= p_session_date
AND pps.period_of_service_id = (
   SELECT DISTINCT(period_of_service_id)
   FROM per_all_assignments_f
   WHERE assignment_id = p_assignment_id
   AND assignment_type = 'E');

--
-- declare local variables
--
l_session_date DATE;


BEGIN
   --get the final processing date or the actual processing date
   OPEN get_fpd_or_atd;
   FETCH get_fpd_or_atd INTO l_session_date;
   CLOSE get_fpd_or_atd;


   RETURN l_session_date;
END get_fpd_or_atd;
--

END payvwele;

/
