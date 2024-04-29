--------------------------------------------------------
--  DDL for Package Body PER_BF_GEN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_GEN_DATA_PUMP" AS
/* $Header: pebgendp.pkb 115.6 2002/09/05 12:56:36 apholt noship $ */

-- Declare local variables
--
l_package_name    VARCHAR2(30) DEFAULT 'PER_BF_GEN_DATA_PUMP.';
-- -------------------------------------------------------------------------
-- --------------------< get_input_value_id >-------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_input_value_id
  (p_reporting_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE)
RETURN BINARY_INTEGER
IS
 l_input_value_id  NUMBER DEFAULT null;
BEGIN
  IF p_reporting_name IS NOT NULL THEN
    SELECT input_value_id
    INTO l_input_value_id
    FROM pay_input_values_f iv
       , pay_element_types_f et
     WHERE et.reporting_name = p_reporting_name
     AND et.business_group_id = p_business_group_id
     AND et.element_type_id = iv.element_type_id
     AND iv.display_sequence=1
     AND iv.name <> 'Pay Value'
     AND p_effective_date
	 BETWEEN et.effective_start_date AND et.effective_end_date
     AND p_effective_date
	 BETWEEN iv.effective_start_date AND iv.effective_end_date;
  END IF;
  --
  RETURN (l_input_value_id);
EXCEPTION
WHEN OTHERS THEN
  -- General Datapump fail procedure
  hr_data_pump.fail('get_input_value_id'
		   ,sqlerrm
		   ,p_reporting_name
		   ,p_business_group_id
		   ,p_effective_date);
  RAISE;
END get_input_value_id;
-- -------------------------------------------------------------------------
-- --------------------< get_balance_type_id >------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_balance_type_id
  (p_balance_type_name  IN VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_effective_date     IN DATE)
RETURN BINARY_INTEGER
IS
  --
  -- Cursor to get the balance_type_id
  --
  CURSOR csr_get_balance_type_id IS
  SELECT balance_type_id
    FROM per_bf_balance_types
   WHERE internal_name  = p_balance_type_name
     AND business_group_id = p_business_group_id
     AND p_effective_date
	 BETWEEN NVL(date_from,to_date('01-01-0001','DD-MM-YYYY'))
             AND NVL(date_to,to_date('31-12-4712','DD-MM-YYYY'));
  --
  l_balance_type_id   NUMBER;
BEGIN
  --
  OPEN csr_get_balance_type_id;
  FETCH csr_get_balance_type_id INTO l_balance_type_id;
  --
  IF csr_get_balance_type_id%FOUND THEN
    --
    CLOSE csr_get_balance_type_id;
    --
    RETURN (l_balance_type_id);
    --
  ELSE
    --
    CLOSE csr_get_balance_type_id;
    --
    -- No ID has been found so raise an error.
    --
    RAISE_APPLICATION_ERROR (-20000,
      'Cannot find balance_type_id');
    --
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  -- General Datapump fail procedure
  hr_data_pump.fail('get_balance_type_id'
		   ,sqlerrm
		   ,p_balance_type_name
		   ,p_business_group_id
		   ,p_effective_date);
  RAISE;
END get_balance_type_id;
-- -------------------------------------------------------------------------
-- --------------------< get_payroll_id >-----------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_payroll_id
(
   p_payroll_name      in varchar2,
   p_business_group_id in number,
   p_effective_date    in date
)
RETURN BINARY_INTEGER IS
  l_payroll_id BINARY_INTEGER;
BEGIN
   SELECT pay.payroll_id
   INTO   l_payroll_id
   FROM   pay_payrolls_f pay
   WHERE  pay.payroll_name          = p_payroll_name
   AND    pay.business_group_id + 0 = p_business_group_id
   AND    p_effective_date BETWEEN
          pay.effective_start_date AND pay.effective_end_date;
   RETURN(l_payroll_id);
EXCEPTION
WHEN OTHERS THEN
   hr_data_pump.fail('get_payroll_id'
		    , sqlerrm
		    , p_payroll_name
		    , p_business_group_id
		    , p_effective_date);
   RAISE;
END get_payroll_id;
-- -------------------------------------------------------------------------
-- --------------------< get_payroll_run_id >-------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_payroll_run_id
  (p_payroll_run_user_key     IN VARCHAR2)
RETURN BINARY_INTEGER
IS
  l_payroll_run_id   NUMBER;
BEGIN
 SELECT unique_key_id
 INTO  l_payroll_run_id
 FROM   hr_pump_batch_line_user_keys
 WHERE  user_key_value = p_payroll_run_user_key;
  --
  RETURN (l_payroll_run_id);
  --
EXCEPTION
WHEN OTHERS THEN
  -- General Datapump fail procedure
  hr_data_pump.fail('get_payroll_run_id'
		   ,sqlerrm
		   ,p_payroll_run_user_key);
  RAISE;
END get_payroll_run_id;
--
-- -------------------------------------------------------------------------
-- --------------------< get_assignment_id >--------------------------------
-- -------------------------------------------------------------------------
FUNCTION get_assignment_id
  (p_employee_number          IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  ,p_effective_date           IN DATE)
RETURN BINARY_INTEGER
IS
  l_assignment_id  NUMBER;
BEGIN
  SELECT pa.assignment_id
  INTO   l_assignment_id
  FROM   per_all_assignments_f pa
      ,  per_all_people_f pp
  WHERE pp.employee_number   = p_employee_number
    AND pp.business_group_id = p_business_group_id
    AND pp.person_id = pa.person_id
    AND pa.primary_flag = 'Y'
    AND pa.assignment_type = 'E'
    AND p_effective_date
	BETWEEN pa.effective_start_date
	    AND pa.effective_end_date
    AND p_effective_date
	BETWEEN pp.effective_start_date
	    AND pp.effective_end_date;
  --
  RETURN (l_assignment_id);
  --
EXCEPTION
WHEN OTHERS THEN
  -- General Datapump fail procedure
  hr_data_pump.fail('get_assignment_id'
		   ,sqlerrm
		   ,p_employee_number
		   ,p_effective_date);
  RAISE;
END get_assignment_id;
-- -------------------------------------------------------------------------
-- ------------------< get_personal_payment_method_id >---------------------
-- -------------------------------------------------------------------------
FUNCTION get_personal_payment_method_id
  (p_employee_number          IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  ,p_effective_date           IN DATE
  ,p_org_payment_method_name  IN VARCHAR2)
RETURN BINARY_INTEGER
IS
  l_personal_payment_method_id NUMBER;
BEGIN
  SELECT personal_payment_method_id
  INTO l_personal_payment_method_id
  FROM PAY_PERSONAL_PAYMENT_METHODS_F ppm
     , PAY_ORG_PAYMENT_METHODS_F_TL opm
     , PER_ALL_PEOPLE_F pp
     , PER_ALL_ASSIGNMENTS_F asg
    WHERE opm.org_payment_method_id = ppm.org_payment_method_id
    AND opm.org_payment_method_name = p_org_payment_method_name
    AND pp.employee_number = p_employee_number
    AND pp.business_group_id = p_business_group_id
    AND pp.person_id = asg.person_id
    AND asg.primary_flag = 'Y'
    AND asg.assignment_id = ppm.assignment_id
    AND p_effective_date
	BETWEEN pp.effective_start_date AND pp.effective_end_date
    AND p_effective_date
	BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND p_effective_date
	BETWEEN ppm.effective_start_date AND ppm.effective_end_date
    AND rownum=1
    ORDER BY priority;
  --
  RETURN (l_personal_payment_method_id);
EXCEPTION
WHEN OTHERS THEN
  -- General Datapump fail procedure
  hr_data_pump.fail('get_personal_payment_method_id'
		   ,sqlerrm
		   ,p_employee_number
		   ,p_org_payment_method_name
		   ,p_effective_date);
  RAISE;
END get_personal_payment_method_id;
END PER_BF_GEN_DATA_PUMP;

/
