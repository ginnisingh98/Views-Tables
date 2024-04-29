--------------------------------------------------------
--  DDL for Package Body BE_CALL_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BE_CALL_FF_PKG" AS
  -- $Header: pebeclff.pkb 115.6 2003/02/07 09:48:53 atrivedi noship $
  --
  --
  -- Package constants
  --
  c_pkg_name CONSTANT VARCHAR2(30) := 'be_call_ff_pkg';
  --
  --
  -- Service routine to return information on the formula.
  --
  PROCEDURE formula_details
  (p_session_date             DATE
  ,p_formula_name             VARCHAR2
  ,o_formula_id           OUT NOCOPY NUMBER
  ,o_effective_start_date OUT NOCOPY DATE) IS
    --
    --
    -- Cursor to find the formula.
    --
    CURSOR csr_formula_details
      (p_session_date DATE
      ,p_formula_name VARCHAR2) IS
      SELECT formula_id, effective_start_date
      FROM   ff_formulas_f
      WHERE  formula_name     = p_formula_name
        AND  legislation_code = 'BE'
        AND  p_session_date   BETWEEN effective_start_date
                                  AND effective_end_date;
    --
    --
    -- Local variables
    --
    l_rec           csr_formula_details%ROWTYPE;
    formula_missing exception;
  BEGIN
    --
    --
    -- Get details on the formula.
    --
    OPEN csr_formula_details
           (p_session_date => p_session_date
           ,p_formula_name => p_formula_name);
    FETCH csr_formula_details INTO l_rec;
    IF csr_formula_details%NOTFOUND THEN
      CLOSE csr_formula_details;
      RAISE formula_missing;
    END IF;
    CLOSE csr_formula_details;
    --
    --
    -- Return the details.
    --
    o_formula_id           := l_rec.formula_id;
    o_effective_start_date := l_rec.effective_start_date;
  EXCEPTION
    WHEN formula_missing THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.FORMULA_DETAILS');
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;
  END formula_details;
  --
  --
  -- Service routine to return information on the business group
  --
  PROCEDURE business_group_details
  (p_business_group_id  IN NUMBER
  ,o_currency_code     OUT NOCOPY VARCHAR2) IS
    --
    --
    -- Curosr to find the business group.
    --
    CURSOR csr_bg_details
      (p_business_group_id NUMBER) IS
      SELECT currency_code
      FROM   per_business_groups
      WHERE  business_group_id = p_business_group_id;
    --
    --
    -- Local variables
    --
    l_rec      csr_bg_details%ROWTYPE;
    bg_missing exception;
  BEGIN
    --
    --
    -- Get details on the business group.
    --
    OPEN csr_bg_details(p_business_group_id => p_business_group_id);
    FETCH csr_bg_details INTO l_rec;
    IF csr_bg_details%NOTFOUND THEN
      CLOSE csr_bg_details;
      RAISE bg_missing;
    END IF;
    CLOSE csr_bg_details;
    --
    --
    -- Return the details.
    --
    o_currency_code := l_rec.currency_code;
  EXCEPTION
    WHEN bg_missing THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.BUSINESS_GROUP_DETAILS');
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;
  END business_group_details;
  --
  --
  -- Computes the employee's notice period
  --
  PROCEDURE calculate_notice_period
  (p_service_years           IN NUMBER
  ,p_service_months          IN NUMBER
  ,p_age_years               IN NUMBER
  ,p_age_months              IN NUMBER
  ,p_salary                  IN NUMBER
  ,p_notice_type             IN VARCHAR2
  ,p_derivation_method       IN VARCHAR2
  ,p_assignment_id           IN NUMBER
  ,p_business_group_id       IN NUMBER
  ,p_legislation_code        IN VARCHAR2
  ,p_session_date            IN DATE
  ,p_notice_period           IN OUT NOCOPY NUMBER
  ,p_counter_notice          IN OUT NOCOPY NUMBER
  ,p_leave_days              IN OUT NOCOPY VARCHAR2) IS
    --
    --
    -- Local constants
    --
    c_proc_name CONSTANT VARCHAR2(61) := c_pkg_name || '.calculate_notice_period';
    --
    --
    -- Local variables.
    --
    l_formula_id           ff_formulas_f.formula_id%TYPE;
    l_effective_start_date ff_formulas_f.effective_start_date%TYPE;
    l_bg_currency_code     VARCHAR2(30);
    l_inputs               ff_exec.inputs_t;
    l_outputs              ff_exec.outputs_t;
    wrong_input_params     exception;
    wrong_output_params    exception;
  BEGIN
    --
    --
    -- Get the details for the formula.
    --
    hr_utility.set_location(c_proc_name, 10);
    formula_details
      (p_session_date         => p_session_date
      ,p_formula_name         => 'BE_DERIVE_NOTICE_PERIOD'
      ,o_formula_id           => l_formula_id
      ,o_effective_start_date => l_effective_start_date);
    --
    --
    -- Get the details for the business group.
    --
    hr_utility.set_location(c_proc_name, 15);
    business_group_details
      (p_business_group_id => p_business_group_id
      ,o_currency_code     => l_bg_currency_code);
    --
    --
    -- Prepare to run the formula.
    --
    hr_utility.set_location(c_proc_name, 20);
    ff_exec.init_formula
      (l_formula_id
      ,l_effective_start_date
      ,l_inputs
      ,l_outputs);
    --
    --
    -- Setup the inputs to the formula.
    --
    hr_utility.set_location(c_proc_name, 30);
    FOR l_in_cnt IN l_inputs.first..l_inputs.last LOOP
      IF l_inputs(l_in_cnt).name = 'BE_EMP_SERV_YEARS' THEN
         l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(p_service_years);
      ELSIF l_inputs(l_in_cnt).name = 'BE_EMP_SERV_MONTHS' THEN
         l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(p_service_months);
      ELSIF l_inputs(l_in_cnt).name = 'BE_EMP_AGE_YEARS' THEN
         l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(p_age_years);
      ELSIF l_inputs(l_in_cnt).name = 'BE_EMP_AGE_MONTHS' THEN
         l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(p_age_months);
      ELSIF l_inputs(l_in_cnt).name = 'BE_EMP_SALARY' THEN
         l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(p_salary);
      ELSIF l_inputs(l_in_cnt).name = 'BE_NOTICE_TYPE' THEN
         l_inputs(l_in_cnt).value := p_notice_type;
      ELSIF l_inputs(l_in_cnt).name = 'BE_DERIVATION_METHOD' THEN
         l_inputs(l_in_cnt).value := p_derivation_method;
      ELSIF l_inputs(l_in_cnt).name = 'BE_CURRENCY_CODE' THEN
         l_inputs(l_in_cnt).value := l_bg_currency_code;
      ELSIF l_inputs(l_in_cnt).name = 'BUSINESS_GROUP_ID' THEN
         l_inputs(l_in_cnt).value := p_business_group_id;
      ELSIF l_inputs(l_in_cnt).name = 'EFFECTIVE_START_DATE' THEN
         l_inputs(l_in_cnt).value := TO_CHAR(sysdate,'DD/MM/YYYY');
      ELSIF l_inputs(l_in_cnt).name = 'ASSIGNMENT_ID' THEN
         l_inputs(l_in_cnt).value := p_assignment_id;
      ELSE
         RAISE wrong_input_params;
      END IF;
    END LOOP;
    --
    --
    -- Run the formula.
    --
    hr_utility.set_location(c_proc_name, 40);
    ff_exec.run_formula
      (l_inputs
      ,l_outputs);
    --
    --
    -- Extract all the outputs.
    --
    hr_utility.set_location(c_proc_name, 50);
    FOR l_out_cnt IN l_outputs.first..l_outputs.last LOOP
      IF l_outputs(l_out_cnt).name = 'BE_NOTICE_PERIOD' THEN
        p_notice_period := fnd_number.canonical_to_number(l_outputs(l_out_cnt).value);
      ELSIF l_outputs(l_out_cnt).name = 'BE_COUNTER_NOTICE' THEN
        p_counter_notice := fnd_number.canonical_to_number(l_outputs(l_out_cnt).value);
      ELSIF l_outputs(l_out_cnt).name = 'BE_LEAVE_DAYS' THEN
        p_leave_days := l_outputs(l_out_cnt).value;
      ELSE
        RAISE wrong_output_params;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN wrong_input_params THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.CALCULATE_NOTICE_PERIOD');
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;
    WHEN wrong_output_params THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.CALCULATE_NOTICE_PERIOD');
      hr_utility.set_message_token('STEP', '20');
      hr_utility.raise_error;
  END calculate_notice_period;
  --
  --
  -- Validates the NI Number.
  --
  FUNCTION check_ni
  (p_national_identifier     IN VARCHAR2
  ,p_birth_date              IN DATE
  ,p_gender                  IN VARCHAR2
  ,p_event                   IN VARCHAR2
  ,p_person_id               IN NUMBER
  ,p_business_group_id       IN NUMBER
  ,p_legislation_code        IN VARCHAR2 DEFAULT 'BE'
  ,p_session_date            IN DATE) RETURN VARCHAR2 IS
    --
    --
    -- Local constants
    --
    c_proc_name            CONSTANT VARCHAR2(61) := c_pkg_name || '.check_ni';
    --
    --
    -- Local variables.
    --
    l_formula_id           ff_formulas_f.formula_id%type;
    l_effective_start_date ff_formulas_f.effective_start_date%type;
    l_inputs               ff_exec.inputs_t;
    l_outputs              ff_exec.outputs_t;
    l_return_value         VARCHAR(240) := p_national_identifier;
    l_invalid_mesg         VARCHAR(240);
    wrong_input_params     exception;
    wrong_output_params    exception;
  BEGIN
    --
    --
    -- Get the details for the formula.
    --
    formula_details
      (p_session_date         => p_session_date
      ,p_formula_name         => 'NI_VALIDATION'
      ,o_formula_id           => l_formula_id
      ,o_effective_start_date => l_effective_start_date);
    --
    --
    -- Prepare to run the formula.
    --
    ff_exec.init_formula
      (l_formula_id
      ,l_effective_start_date
      ,l_inputs
      ,l_outputs);
    --
    --
    -- Setup the inputs to the formula.
    --
    FOR l_in_cnt IN l_inputs.first..l_inputs.last LOOP
      IF l_inputs(l_in_cnt).name = 'NATIONAL_IDENTIFIER' THEN
         l_inputs(l_in_cnt).value := p_national_identifier;
      ELSIF l_inputs(l_in_cnt).name = 'BIRTH_DATE' THEN
         l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_birth_date);
      ELSIF l_inputs(l_in_cnt).name = 'GENDER' THEN
         l_inputs(l_in_cnt).value := p_gender;
      ELSIF l_inputs(l_in_cnt).name = 'EVENT' THEN
         l_inputs(l_in_cnt).value := p_event;
      ELSE
         RAISE wrong_input_params;
      END IF;
    END LOOP;
    --
    --
    -- Run the formula.
    --
    ff_exec.run_formula
      (l_inputs
      ,l_outputs);
    --
    --
    -- Extract all the outputs.
    --
    FOR l_out_cnt IN l_outputs.first..l_outputs.last LOOP
      IF l_outputs(l_out_cnt).name = 'RETURN_VALUE' THEN
        l_return_value := l_outputs(l_out_cnt).value;
      ELSIF l_outputs(l_out_cnt).name = 'INVALID_MESG' THEN
        l_invalid_mesg := l_outputs(l_out_cnt).value;
      ELSE
        RAISE wrong_output_params;
      END IF;
    END LOOP;
    --
    --
    -- If the format was not correct then raise an error.
    --
    IF l_return_value = 'INVALID_ID' THEN
      hr_utility.set_message(801, l_invalid_mesg);
      hr_utility.raise_error;
    END IF;
    --
    --
    -- Pass back the result.
    --
    RETURN l_return_value;
  EXCEPTION
    WHEN wrong_input_params THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.CHECK_NI');
      hr_utility.set_message_token('STEP', '10');
      hr_utility.raise_error;
    WHEN wrong_output_params THEN
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', 'BE_CALL_FF_PKG.CHECK_NI');
      hr_utility.set_message_token('STEP', '20');
      hr_utility.raise_error;
  END check_ni;
  --
end be_call_ff_pkg;

/
