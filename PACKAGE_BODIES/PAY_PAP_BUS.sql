--------------------------------------------------------
--  DDL for Package Body PAY_PAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAP_BUS" as
/* $Header: pypaprhi.pkb 120.0 2005/05/29 07:14:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package         VARCHAR2(33) := 'pay_pap_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< return_ff_name >-----------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        return_ff_name
--
--    DESCRIPTION Validates that the Fast Formula exists, is effective and
--                visible to the business group and legislation.
--
--    NOTES       The name of the Fast Formula is returned.
--
FUNCTION return_ff_name
  (p_effective_date           IN DATE
  ,p_business_group_id        IN NUMBER
  ,p_formula_id               IN NUMBER
  ,p_formula_type_name        IN VARCHAR2) RETURN VARCHAR2
IS

  l_proc             VARCHAR2(72) := g_package||'return_ff_name';
  l_legislation_code per_business_groups.legislation_code%TYPE;
  l_formula_name     ff_formulas_f.formula_name%TYPE;

  --
  -- Fetches the legislation code of the business group.
  --
  CURSOR csr_get_leg_code IS
  SELECT pbg.legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id = p_business_group_id;

  --
  -- Fetches the FF name whilst verifying that the formula type
  -- matches, the formula is effective and the business group or
  -- legislation code are visible.
  --
  CURSOR csr_chk_and_return_ff IS
  SELECT ff.formula_name
  FROM   ff_formulas_f ff
        ,ff_formula_types ft
  WHERE  ff.formula_id = p_formula_id
  AND    ff.formula_type_id = ft.formula_type_id
  AND    ft.formula_type_name = p_formula_type_name
  AND    p_effective_date BETWEEN
         ff.effective_start_date and ff.effective_end_date
  AND   (ff.business_group_id IS NULL OR
         (ff.business_group_id IS NOT NULL AND
          ff.business_group_id = p_business_group_id))
  AND   (ff.legislation_code IS NULL OR
         (ff.legislation_code IS NOT NULL AND
          ff.legislation_code = l_legislation_code));

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  OPEN  csr_get_leg_code;
  FETCH csr_get_leg_code INTO l_legislation_code;
  CLOSE csr_get_leg_code;

  OPEN  csr_chk_and_return_ff;
  FETCH csr_chk_and_return_ff INTO l_formula_name;
  CLOSE csr_chk_and_return_ff;

  hr_utility.set_location('Leaving: '||l_proc, 20);

  --
  -- If no formula is found, l_formula_name will return NULL.  This function
  -- returns null, instead of erroring, because the calling procedure may
  -- raise specific (rather than general) error messages.
  --
  RETURN l_formula_name;

END return_ff_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_accrual_plan_name >----------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_accrual_plan_name
--
--    DESCRIPTION Validates the accrual plan name.  The name must not be
--                duplicated within the accrual plans table; the name must
--                not cause any clashes with the element type names that the
--                plan will create and the name is mandatory.
--
--    NOTES       none
--
PROCEDURE chk_accrual_plan_name
  (p_accrual_plan_id       IN NUMBER
  ,p_accrual_plan_name     IN VARCHAR2
  ,p_business_group_id     IN NUMBER)
IS

  l_proc         VARCHAR2(72) := g_package||'chk_accrual_plan_name';
  l_name_exists  VARCHAR2(2)  := 'N';
  l_api_updating BOOLEAN;

  CURSOR csr_check_name IS
  SELECT 'Y'
  FROM   pay_accrual_plans pap
  WHERE  UPPER(pap.accrual_plan_name) = UPPER(p_accrual_plan_name)
  AND    pap.business_group_id = p_business_group_id
  AND  ((p_accrual_plan_id is null)
   OR   (p_accrual_plan_id is not null and
         pap.accrual_plan_id <> p_accrual_plan_id));

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_accrual_plan_name',
                             p_argument_value => p_accrual_plan_name);

  --
  -- Determine whether the plan name has been duplicated.  If a record is found
  -- then the local variable will be set to 'Y', otherwise it will remain 'N'
  --
  OPEN  csr_check_name;
  FETCH csr_check_name INTO l_name_exists;
  CLOSE csr_check_name;

  --
  -- Check the value of the local variable.
  --
  IF (l_name_exists = 'Y') THEN

    hr_utility.set_location(l_proc, 20);
    fnd_message.set_name('PAY', 'HR_13163_PTO_DUP_PLAN_NAME');
    fnd_message.raise_error;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 30);

END chk_accrual_plan_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_accrual_category >-----------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_accrual_category
--
--    DESCRIPTION Validates that the accrual category is valid and effective.
--
--    NOTES       none
--
PROCEDURE chk_accrual_category
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_category         IN VARCHAR2)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_accrual_category';
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.accrual_category, hr_api.g_varchar2)
    = NVL(p_accrual_category, hr_api.g_varchar2)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_accrual_category',
                             p_argument_value => p_accrual_category);

  --
  -- Bug 1744331: use leg_lookups.
  --
  IF hr_api.not_exists_in_leg_lookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'US_PTO_ACCRUAL'
    ,p_lookup_code    => p_accrual_category) THEN

    --
    -- The accrual category does not exist in the lookup.
    --
    hr_utility.set_location(l_proc, 20);
    fnd_message.set_name('PER', 'HR_289325_LEG_ACC_NOT_EXISTS');
    fnd_message.raise_error;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_accrual_category;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_accrual_start >--------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_accrual_start
--
--    DESCRIPTION Validates that the accrual start is valid and effective.
--
--    NOTES       none
--
PROCEDURE chk_accrual_start
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_start            IN VARCHAR2)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_accrual_start';
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.accrual_start, hr_api.g_varchar2)
    = NVL(p_accrual_start, hr_api.g_varchar2)) THEN
    RETURN;
  END IF;

  IF p_accrual_start IS NOT NULL THEN

    hr_utility.set_location(l_proc, 20);

    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'US_ACCRUAL_START_TYPE'
      ,p_lookup_code    => p_accrual_start) THEN

      --
      -- The accrual start does not exist in the lookup.
      --
      hr_utility.set_location(l_proc, 30);
      fnd_message.set_name('PER', 'HR_289814_PAP_START_INVALID');
      fnd_message.raise_error;

    END IF;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_accrual_start;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_accrual_units_of_measure >---------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_accrual_units_of_measure
--
--    DESCRIPTION Validates that the accrual UOM is valid and effective.
--
--    NOTES       none
--
PROCEDURE chk_accrual_units_of_measure
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_accrual_units_of_measure IN VARCHAR2)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_accrual_units_of_measure';
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_accrual_units_of_measure',
                             p_argument_value => p_accrual_units_of_measure);

  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'HOURS_OR_DAYS'
    ,p_lookup_code    => p_accrual_units_of_measure) THEN

    --
    -- The accrual UOM does not exist in the lookup.
    --
    hr_utility.set_location(l_proc, 20);
    fnd_message.set_name('PER', 'HR_289815_PAP_UOM_INVALID');
    fnd_message.raise_error;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_accrual_units_of_measure;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_accrual_formula_id >---------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_accrual_formula_id
--
--    DESCRIPTION Validates that the accrual formula exists in ff_formulas_f
--                globally, for the business group or for the legislation.
--
--    NOTES       none
--
PROCEDURE chk_accrual_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_formula_id       IN NUMBER)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_accrual_formula_id';
  l_accrual_formula ff_formulas_f.formula_name%TYPE;
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.accrual_formula_id, hr_api.g_number)
    = NVL(p_accrual_formula_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_accrual_formula_id',
                             p_argument_value => p_accrual_formula_id);

  hr_utility.set_location(l_proc, 20);

  l_accrual_formula := return_ff_name
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_formula_id        => p_accrual_formula_id
    ,p_formula_type_name => 'Accrual');

  hr_utility.set_location(l_proc, 30);

  IF l_accrual_formula IS NULL THEN

    --
    -- The formula is not valid so error.
    --
    hr_utility.set_location(l_proc, 40);
    fnd_message.set_name('PER', 'HR_289817_PAP_ACCRUAL_FF');
    fnd_message.raise_error;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_accrual_formula_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_co_formula_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_co_formula_id
--
--    DESCRIPTION Validates that the carry over formula exists in ff_formulas_f
--                globally, for the business group or for the legislation.
--
--    NOTES       none
--
PROCEDURE chk_co_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_formula_id       IN NUMBER
  ,p_co_formula_id            IN NUMBER)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_co_formula_id';
  l_accrual_formula ff_formulas_f.formula_name%TYPE;
  l_co_formula      ff_formulas_f.formula_name%TYPE;
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.accrual_formula_id, hr_api.g_number)
    = NVL(p_accrual_formula_id, hr_api.g_number)
  AND NVL(pay_pap_shd.g_old_rec.co_formula_id, hr_api.g_number)
    = NVL(p_co_formula_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_co_formula_id',
                             p_argument_value => p_co_formula_id);

  hr_utility.set_location(l_proc, 20);

  l_co_formula := return_ff_name
    (p_effective_date    => p_effective_date
    ,p_business_group_id => p_business_group_id
    ,p_formula_id        => p_co_formula_id
    ,p_formula_type_name => 'Accrual Carryover');

  IF l_co_formula IS NULL THEN

    --
    -- The formula is not valid so error.
    --
    hr_utility.set_location(l_proc, 30);
    fnd_message.set_name('PER', 'HR_289817_PAP_ACCRUAL_FF');
    fnd_message.raise_error;

  ELSIF l_co_formula IN ('PTO_PAYROLL_CARRYOVER'
                        ,'PTO_SIMPLE_CARRYOVER'
                        ,'PTO_ROLLING_CARRYOVER'
                        ,'PTO_HD_ANNIVERSARY_CARRYOVER') THEN

    --
    -- This plan is using a seeded carry over formula,
    -- get the accrual formula to check compatibility
    -- (where possible).
    --
    hr_utility.set_location(l_proc, 40);

    --
    -- First get the accrual formula.
    -- This function call should always return a value because
    -- the accrual formula has been validated in a previous
    -- chk procedure.
    --
    l_accrual_formula := return_ff_name
      (p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_formula_id        => p_accrual_formula_id
      ,p_formula_type_name => 'Accrual');

    hr_utility.set_location(l_proc, 50);

    IF l_accrual_formula IN ('PTO_PAYROLL_CALCULATION'
                            ,'PTO_PAYROLL_BALANCE_CALCULATION'
                            ,'PTO_SIMPLE_MULTIPLIER'
                            ,'PTO_SIMPLE_BALANCE_MULTIPLIER'
                            ,'PTO_HD_ANNIVERSARY_BALANCE'
                            ,'PTO_ROLLING_ACCRUAL') THEN

      hr_utility.set_location(l_proc, 60);
      --
      -- Seeded formula are being used for both the accrual and
      -- carry over formulae. Check that the two are compatible.
      --
      IF  (l_co_formula = 'PTO_PAYROLL_CARRYOVER' AND
           l_accrual_formula NOT IN ('PTO_PAYROLL_CALCULATION'
                                   ,'PTO_PAYROLL_BALANCE_CALCULATION'))
       OR (l_co_formula = 'PTO_SIMPLE_CARRYOVER' AND
           l_accrual_formula NOT IN ('PTO_SIMPLE_MULTIPLIER'
                                    ,'PTO_SIMPLE_BALANCE_MULTIPLIER'))
       OR (l_co_formula = 'PTO_HD_ANNIVERSARY_CARRYOVER' AND
           l_accrual_formula <> 'PTO_HD_ANNIVERSARY_BALANCE')
       OR (l_co_formula = 'PTO_ROLLING_CARRYOVER' AND
           l_accrual_formula <> 'PTO_ROLLING_ACCRUAL') THEN

        hr_utility.set_location(l_proc, 70);
        --
        -- The carryover and accrual formulae are incompatible.
        --
        fnd_message.set_name('PER','HR_289819_PAP_FF_INCOMPATIBLE');
        fnd_message.set_token('CO_FF', l_co_formula);
        fnd_message.set_token('ACCRUAL_FF', l_accrual_formula);
        fnd_message.raise_error;

      END IF;

    END IF;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_co_formula_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_pto_input_value_id >---------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_pto_input_value_id
--
--    DESCRIPTION Validates that the nominated absence element is a valid
--                input value and has a corresponding absence type.
--
--    NOTES       none
--
PROCEDURE chk_pto_input_value_id
  (p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_pto_input_value_id       IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_accrual_units_of_measure IN VARCHAR2)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_pto_input_value_id';
  l_valid           BOOLEAN      := TRUE;
  l_api_updating    BOOLEAN;
  l_dummy           NUMBER;
  l_element_type_id NUMBER;
  l_legislation_code VARCHAR2(30);

  --
  -- Checks the format of the input value and fetches the element type.
  --
  CURSOR csr_chk_input_value IS
  SELECT pet.element_type_id
  FROM   pay_element_types_f pet
        ,pay_input_values_f piv
  WHERE  piv.input_value_id = p_pto_input_value_id
  AND    (piv.business_group_id = p_business_group_id
       OR (piv.business_group_id is null
           AND piv.legislation_code = l_legislation_code))
  AND    piv.element_type_id = pet.element_type_id
  AND  ((piv.uom = 'ND' AND
         p_accrual_units_of_measure = 'D')
   OR   ((piv.uom like 'H_DECIMAL_%' OR
          piv.uom like 'H_HH%') AND
         p_accrual_units_of_measure = 'H'));

  --
  -- Checks that a valid absence type exists or that the DDF is set to Absences.
  -- The UOM is again validated, but this time against the absence type's UOM.
  --
  CURSOR csr_chk_pet_and_paat IS
  SELECT null
  FROM   pay_element_types_f pet
        ,pay_element_classifications pec
  WHERE  pet.element_type_id = l_element_type_id
  AND    pet.classification_id = pec.classification_id
  AND   (pet.processing_type = 'N'
   OR    (pet.processing_type = 'R' AND pet.proration_group_id IS NOT NULL))
  AND    (pet.business_group_id = p_business_group_id
        OR (pet.business_group_id is null
          AND pet.legislation_code = l_legislation_code))
  AND  ((upper(pec.classification_name) = 'INFORMATION' AND
         pet.element_information1 = 'ABS' AND
         p_accrual_units_of_measure = 'H')
   OR   (EXISTS (SELECT null
                 FROM   per_absence_attendance_types paat
                 WHERE  paat.input_value_id IS NOT NULL
                 AND    paat.input_value_id = p_pto_input_value_id
                 AND    paat.business_group_id = p_business_group_id
                 AND  ((paat.hours_or_days = 'D' AND
                        p_accrual_units_of_measure = 'D')
                  OR   (paat.hours_or_days = 'H' AND
                        p_accrual_units_of_measure = 'H')))));
-- Defining a cursor to get the legislation_code of the business group
--
CURSOR csr_get_leg_code IS
  SELECT pbg.legislation_code
  FROM   per_business_groups pbg
  WHERE  pbg.business_group_id = p_business_group_id;
--
BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.pto_input_value_id, hr_api.g_number)
    = NVL(p_pto_input_value_id, hr_api.g_number)
  AND NVL(pay_pap_shd.g_old_rec.accrual_units_of_measure, hr_api.g_varchar2)
    = NVL(p_accrual_units_of_measure, hr_api.g_varchar2)) THEN
    RETURN;
  END IF;

  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_pto_input_value_id',
                             p_argument_value => p_pto_input_value_id);

  hr_utility.set_location(l_proc, 20);

  --
  -- Fetch the legislation code
  OPEN csr_get_leg_code;
  FETCH csr_get_leg_code INTO l_legislation_code;
  CLOSE csr_get_leg_code;
  --
  -- Check the input value and fetch the element type.
  --
  OPEN  csr_chk_input_value;
  FETCH csr_chk_input_value INTO l_element_type_id;
  CLOSE csr_chk_input_value;

  IF l_element_type_id IS NULL THEN

    hr_utility.set_location(l_proc, 20);
    l_valid := FALSE;

  ELSE

    hr_utility.set_location(l_proc, 30);

    --
    -- Check the element type and corresponding absence element.
    --
    OPEN  csr_chk_pet_and_paat;
    FETCH csr_chk_pet_and_paat INTO l_dummy;

    IF csr_chk_pet_and_paat%NOTFOUND THEN

      hr_utility.set_location(l_proc, 40);
      l_valid := FALSE;

    END IF;

  END IF;

  CLOSE  csr_chk_pet_and_paat;

  IF NOT l_valid THEN

    fnd_message.set_name('PER','HR_289813_PAP_INVALID_INPT_VAL');
    fnd_message.raise_error;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_pto_input_value_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_defined_balance_id >---------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_defined_balance_id
--
--    DESCRIPTION Validates that the defined balance is valid and that it is
--                compatible with the Accrual formula.
--
--    NOTES       none
--
PROCEDURE chk_defined_balance_id
  (p_effective_date           IN  DATE
  ,p_accrual_plan_id          IN  NUMBER
  ,p_object_version_number    IN  NUMBER
  ,p_business_group_id        IN  NUMBER
  ,p_accrual_formula_id       IN  NUMBER
  ,p_defined_balance_id       IN  NUMBER
  ,p_check_accrual_ff         OUT NOCOPY BOOLEAN)
IS

  l_proc             VARCHAR2(72) := g_package||'chk_defined_balance_id';
  l_accrual_formula  ff_formulas_f.formula_name%TYPE;
  l_api_updating     BOOLEAN;
  l_dimension_name   pay_balance_dimensions.dimension_name%TYPE;
  l_balance_type     hr_organization_information.org_information1%TYPE;

  --
  -- Get the balance dimension given the defined balance.
  --
  CURSOR csr_get_dim_name IS
  SELECT pbd.dimension_name
  FROM   pay_balance_dimensions pbd
        ,pay_defined_balances pdb
  WHERE  pdb.defined_balance_id = p_defined_balance_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;

  --
  -- Get the balance type against the BG.
  --
  CURSOR csr_get_bg_balance_type IS
  SELECT hoi.org_information1
  FROM   hr_organization_information hoi
  WHERE  hoi.organization_id = p_business_group_id
  AND    hoi.org_information_context = 'PTO Balance Type';

  --
  -- Get the balance type against the legislation.
  --
  CURSOR csr_get_leg_balance_type IS
  SELECT plr.rule_mode
  FROM   pay_legislation_rules plr
  WHERE  plr.rule_type = 'PTO_BALANCE_TYPE'
  AND    plr.legislation_code =
           (SELECT pbg.legislation_code
            FROM   per_business_groups pbg
            WHERE  pbg.business_group_id = p_business_group_id);

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  p_check_accrual_ff := FALSE;
  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.accrual_formula_id, hr_api.g_number)
    = NVL(p_accrual_formula_id, hr_api.g_number)
  AND NVL(pay_pap_shd.g_old_rec.defined_balance_id, hr_api.g_number)
    = NVL(p_defined_balance_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_utility.set_location(l_proc, 20);

  IF p_defined_balance_id IS NOT NULL THEN

    hr_utility.set_location(l_proc, 30);

    IF l_api_updating
     AND NVL(pay_pap_shd.g_old_rec.defined_balance_id, hr_api.g_number)
             <> hr_api.g_number THEN

      --
      -- The balance dimension has previously been set and is trying
      -- to be updated.  This is not allowed so error.
      --
      hr_utility.set_location(l_proc, 40);
      fnd_message.set_name('PER','HR_289823_PAP_BAL_DIM_UPDATE');
      fnd_message.raise_error;


    END IF;

    hr_utility.set_location(l_proc, 50);

    --
    -- Fetch the name of the accrual formula for later use.  This
    -- should never error or return null because the accrual formula
    -- has already been validated prior to this chk procedure.
    --
    l_accrual_formula := return_ff_name
      (p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_formula_id        => p_accrual_formula_id
      ,p_formula_type_name => 'Accrual');

    hr_utility.set_location(l_proc, 60);

    --
    -- Fetch the balance dimension name.
    --
    OPEN  csr_get_dim_name;
    FETCH csr_get_dim_name INTO l_dimension_name;
    CLOSE csr_get_dim_name;

    hr_utility.set_location(l_proc, 70);

    IF l_dimension_name IS NULL THEN

      --
      -- The defined balance does not exist (the defined
      -- balance has already been validated at this stage
      -- so this would only occur when there is an internal
      -- error with creating the defined balance).
      --
      hr_utility.set_location(l_proc, 80);
      fnd_message.set_name('PER','HR_289820_PAP_DEF_BAL_INVALID');
      fnd_message.raise_error;

    ELSIF l_dimension_name IN ('_ASG_PTO_SM_YTD'
                              ,'_ASG_PTO_DE_SM_YTD'
                              ,'_ASG_PTO_YTD'
                              ,'_ASG_PTO_DE_YTD'
                              ,'_ASG_PTO_HD_YTD'
                              ,'_ASG_PTO_DE_HD_YTD') THEN

      --
      -- This is a seed dimension name, check it is compatible
      -- with the accrual formula.
      --
      hr_utility.set_location(l_proc, 90);

      IF  (l_dimension_name IN ('_ASG_PTO_SM_YTD'
                               ,'_ASG_PTO_DE_SM_YTD') AND
           l_accrual_formula IN ('PTO_PAYROLL_CALCULATION'
                                ,'PTO_PAYROLL_BALANCE_CALCULATION'
                                ,'PTO_SIMPLE_MULTIPLIER'
                                ,'PTO_HD_ANNIVERSARY_BALANCE'
                                ,'PTO_ROLLING_ACCRUAL'))
       OR (l_dimension_name IN ('_ASG_PTO_YTD'
                               ,'_ASG_PTO_DE_YTD') AND
           l_accrual_formula IN ('PTO_PAYROLL_CALCULATION'
                                ,'PTO_SIMPLE_MULTIPLIER'
                                ,'PTO_SIMPLE_BALANCE_MULTIPLIER'
                                ,'PTO_HD_ANNIVERSARY_BALANCE'
                                ,'PTO_ROLLING_ACCRUAL'))
       OR (l_dimension_name IN ('_ASG_PTO_HD_YTD'
                               ,'_ASG_PTO_DE_HD_YTD') AND
           l_accrual_formula IN ('PTO_PAYROLL_CALCULATION'
                                ,'PTO_PAYROLL_BALANCE_CALCULATION'
                                ,'PTO_SIMPLE_MULTIPLIER'
                                ,'PTO_SIMPLE_BALANCE_MULTIPLIER'
                                ,'PTO_ROLLING_ACCRUAL')) THEN

        --
        -- The balance dimension conflicts with the accrual
        -- formula.
        --
        hr_utility.set_location(l_proc, 100);
        fnd_message.set_name('PER', 'HR_289821_PAP_BAL_DIM_CONFLICT');
        fnd_message.raise_error;

      END IF;

      --
      -- Check that the balance dimension matches the balance type.
      -- First get the balance type.
      --
      OPEN  csr_get_bg_balance_type;
      FETCH csr_get_bg_balance_type INTO l_balance_type;
      CLOSE csr_get_bg_balance_type;

      hr_utility.set_location(l_proc, 110);

      IF l_balance_type IS NULL THEN
        --
        -- Check for a balance type at legislative level.
        --
        OPEN  csr_get_leg_balance_type;
        FETCH csr_get_leg_balance_type INTO l_balance_type;
        CLOSE csr_get_leg_balance_type;

        hr_utility.set_location(l_proc, 120);

      END IF;

      IF  (l_balance_type = 'DE' AND
           l_dimension_name NOT IN ('_ASG_PTO_DE_YTD'
                                   ,'_ASG_PTO_DE_SM_YTD'
                                   ,'_ASG_PTO_DE_HD_YTD'))
       OR (NVL(l_balance_type, hr_api.g_varchar2) <> 'DE' AND
           l_dimension_name IN ('_ASG_PTO_DE_YTD'
                               ,'_ASG_PTO_DE_SM_YTD'
                               ,'_ASG_PTO_DE_HD_YTD')) THEN

        hr_utility.set_location(l_proc, 130);
        fnd_message.set_name('PER', 'HR_289822_PAP_BAL_TYPE_DIM');
        fnd_message.raise_error;

      END IF;

    END IF;

    --
    -- If this is not a seeded core Accrual formula then warn.
    -- A balance dimension is being set for the first time so
    -- the Accrual formula must support payroll balances.
    --
    IF l_accrual_formula NOT IN ('PTO_PAYROLL_CALCULATION'
                                ,'PTO_PAYROLL_BALANCE_CALCULATION'
                                ,'PTO_SIMPLE_MULTIPLIER'
                                ,'PTO_SIMPLE_BALANCE_MULTIPLIER'
                                ,'PTO_HD_ANNIVERSARY_BALANCE'
                                ,'PTO_ROLLING_ACCRUAL') THEN

      p_check_accrual_ff := TRUE;

    END IF;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 140);

END chk_defined_balance_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ineligible_period_type >-----------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_ineligible_period_type
--
--    DESCRIPTION Validates that the ineligible period type is valid
--                and effective.
--
--    NOTES       none
--
PROCEDURE chk_ineligible_period_type
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_ineligible_period_type   IN VARCHAR2)
IS

  l_proc            VARCHAR2(72) := g_package||'chk_ineligibile_period_type';
  l_api_updating    BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.ineligible_period_type, hr_api.g_varchar2)
    = NVL(p_ineligible_period_type, hr_api.g_varchar2)) THEN
    RETURN;
  END IF;

  IF p_ineligible_period_type IS NOT NULL THEN

    hr_utility.set_location(l_proc, 20);

    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'PROC_PERIOD_TYPE'
      ,p_lookup_code    => p_ineligible_period_type) THEN

      --
      -- The ineligible period type does not exist in the lookup.
      --
      hr_utility.set_location(l_proc, 30);
      fnd_message.set_name('PER', 'HR_289816_PAP_INELIG_INVALID');
      fnd_message.raise_error;

    END IF;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_ineligible_period_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ineligibility_formula_id >---------------|
-- ----------------------------------------------------------------------------
--
--    NAME        chk_ineligibility_formula_id
--
--    DESCRIPTION Validates that the ineligibility formula exists in
--                ff_formulas_f globally, for the business group or for the
--                legislation.
--
--    NOTES       none
--
PROCEDURE chk_ineligibility_formula_id
  (p_effective_date           IN DATE
  ,p_accrual_plan_id          IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_business_group_id        IN NUMBER
  ,p_ineligibility_formula_id IN NUMBER)
IS

  l_proc               VARCHAR2(72) := g_package||'chk_ineligibility_formula_id';
  l_ineligible_formula ff_formulas_f.formula_name%TYPE;
  l_api_updating       BOOLEAN;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Only proceed with validation if:
  --  a) inserting or
  --  b) updating and the parameters used within this chk procedure
  --     have not changed.
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id       => p_accrual_plan_id
    ,p_object_version_number => p_object_version_number);

  IF (l_api_updating
  AND NVL(pay_pap_shd.g_old_rec.ineligibility_formula_id, hr_api.g_number)
    = NVL(p_ineligibility_formula_id, hr_api.g_number)) THEN
    RETURN;
  END IF;

  hr_utility.set_location(l_proc, 20);

  IF p_ineligibility_formula_id IS NOT NULL THEN

    hr_utility.set_location(l_proc, 30);
    l_ineligible_formula := return_ff_name
      (p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_formula_id        => p_ineligibility_formula_id
      ,p_formula_type_name => 'Accrual Ineligibility');

    hr_utility.set_location(l_proc, 40);

    IF l_ineligible_formula IS NULL THEN

      --
      -- The formula is not valid so error.
      --
      hr_utility.set_location(l_proc, 50);
      fnd_message.set_name('PER', 'HR_289818_PAP_INELIG_FF');
      fnd_message.raise_error;

    END IF;

  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

END chk_ineligibility_formula_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pay_pap_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.accrual_plan_id is not null)  and (
    nvl(pay_pap_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(pay_pap_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) ))
    or (p_rec.accrual_plan_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Accrual Plan Developer DF'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;

--
-- ----------------------------------------------------------------------------
-- |------< chk_ddf_context >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the ddf_context passed into the API
--   is equal to the business group_id\222s legislation_code concatenated with \221_\222
--   and the accrual category.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   accrual_plan_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_ddf_context( p_business_group_id           in number
                          ,p_information_category        in varchar2
                          ,p_accrual_category            in varchar2
                          ,p_accrual_plan_id             in number
                          ,p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ddf_context';
  l_api_updating boolean;
  l_legislation_code varchar2(30);
  cursor csr_leg_code is select legislation_code
                         from per_business_Groups
                         where business_group_id = p_business_Group_id;
  l_accrual_meaning varchar2(80);
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_pap_shd.api_updating
    (p_accrual_plan_id                => p_accrual_plan_id,
     p_object_version_number          => p_object_version_number);
  --

  if (l_api_updating
     and (nvl(p_information_category,hr_api.g_varchar2)
          <>  nvl(pay_pap_shd.g_old_rec.information_category, hr_api.g_varchar2)
         )
         OR
         (nvl(p_accrual_category, hr_api.g_varchar2)
         <> nvl(pay_pap_shd.g_old_rec.accrual_category, hr_api.g_varchar2)
         ))
     OR not l_api_updating
    --
    -- it is an update with values changing, or it is an insert
    --
    then
      Open csr_leg_code;
      Fetch csr_leg_code into l_legislation_code;
      Close csr_leg_code;
      --
      -- error if accrual_category is not set (it may be null on insert)
      -- and ddf context is set
      -- error if leg_code + accrual_cat <> ddf context

      if (not l_api_updating
          and (p_accrual_category is null and p_information_category is not null ))
          OR
            (p_information_category is not null and l_legislation_code ||'_'||
                                    p_accrual_category <> p_information_category)
      then
         fnd_message.set_name('PER','HR_289740_PAP_BAD_INFO_CONTEXT');
         fnd_message.raise_error;
      end if;
    -- error if accrual category is changing and ddf is already used.
     if (l_api_updating and nvl(p_accrual_category, hr_api.g_varchar2)
         <> nvl(pay_pap_shd.g_old_rec.accrual_category, hr_api.g_varchar2)
        and pay_pap_shd.g_old_rec.information_category is not null )
     then
        fnd_message.set_name('PER','HR_289741_PAP_CHANGE_CATEGORY');
        fnd_message.raise_error;
     end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 100);
  --
End chk_ddf_context;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_effective_date   IN  DATE
  ,p_rec              IN  pay_pap_shd.g_rec_type
  ,p_check_accrual_ff OUT NOCOPY BOOLEAN)
IS

  l_proc  varchar2(72) := g_package||'insert_validate';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp

  --
  -- Call all supporting business operations
  --
  --
  -- Check the accrual plan name.
  --
  chk_accrual_plan_name
    (p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_accrual_plan_name            => p_rec.accrual_plan_name
    ,p_business_group_id            => p_rec.business_group_id);

  hr_utility.set_location(l_proc, 20);

  --
  -- Check the accrual category.
  --
  chk_accrual_category
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_accrual_category             => p_rec.accrual_category);

  hr_utility.set_location(l_proc, 30);

  --
  -- Check the accrual start.
  --
  chk_accrual_start
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_accrual_start                => p_rec.accrual_start);

  hr_utility.set_location(l_proc, 40);

  --
  -- Check the accrual UOM.
  --
  chk_accrual_units_of_measure
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_accrual_units_of_measure     => p_rec.accrual_units_of_measure);

  hr_utility.set_location(l_proc, 50);

  --
  -- Check the accrual formula.
  --
  chk_accrual_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id);

  hr_utility.set_location(l_proc, 60);

  --
  -- Check the carry over formula.
  --
  chk_co_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id
    ,p_co_formula_id                => p_rec.co_formula_id);

  hr_utility.set_location(l_proc, 70);

  --
  -- Check the absence element's input value
  --
  chk_pto_input_value_id
    (p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_pto_input_value_id           => p_rec.pto_input_value_id
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_units_of_measure     => p_rec.accrual_units_of_measure);

  hr_utility.set_location(l_proc, 80);

  --
  -- Check the defined balance.
  --
  chk_defined_balance_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id
    ,p_defined_balance_id           => p_rec.defined_balance_id
    ,p_check_accrual_ff             => p_check_accrual_ff);

  hr_utility.set_location(l_proc, 90);

  --
  -- Check the ineligible period type.
  --
  chk_ineligible_period_type
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_ineligible_period_type       => p_rec.ineligible_period_type);

  hr_utility.set_location(l_proc, 100);

  --
  -- Check the ineligibility formula.
  --
  chk_ineligibility_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_ineligibility_formula_id     => p_rec.ineligibility_formula_id);

  hr_utility.set_location(l_proc, 110);

  --
  -- Check the flexfields.
  --
  pay_pap_bus.chk_ddf (p_rec);

  hr_utility.set_location(l_proc, 120);

  pay_pap_bus.chk_ddf_context
    (p_business_group_id           => p_rec.business_group_id
    ,p_information_category        => p_rec.information_category
    ,p_accrual_category            => p_rec.accrual_category
    ,p_accrual_plan_id             => p_rec.accrual_plan_id
    ,p_object_version_number       => p_rec.object_version_number);

  hr_utility.set_location(' Leaving:'||l_proc, 130);

END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
  (p_effective_date   IN  DATE
  ,p_rec              IN  pay_pap_shd.g_rec_type
  ,p_check_accrual_ff OUT NOCOPY BOOLEAN)
IS

  l_proc  varchar2(72) := g_package||'update_validate';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 10);

  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp

  --
  -- Call all supporting business operations
  --

  hr_utility.set_location(l_proc, 20);

  --
  -- Check the accrual category.
  --
  chk_accrual_category
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_accrual_category             => p_rec.accrual_category);

  hr_utility.set_location(l_proc, 30);

  --
  -- Check the accrual start.
  --
  chk_accrual_start
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_accrual_start                => p_rec.accrual_start);

  hr_utility.set_location(l_proc, 40);

  --
  -- Check the accrual formula.
  --
  chk_accrual_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id);

  hr_utility.set_location(l_proc, 50);

  --
  -- Check the carry over formula.
  --
  chk_co_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id
    ,p_co_formula_id                => p_rec.co_formula_id);

  hr_utility.set_location(l_proc, 60);

  --
  -- Check the absence element's input value
  --
  chk_pto_input_value_id
    (p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_pto_input_value_id           => p_rec.pto_input_value_id
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_units_of_measure     => p_rec.accrual_units_of_measure);

  hr_utility.set_location(l_proc, 70);

  --
  -- Check the defined balance.
  --
  chk_defined_balance_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_accrual_formula_id           => p_rec.accrual_formula_id
    ,p_defined_balance_id           => p_rec.defined_balance_id
    ,p_check_accrual_ff             => p_check_accrual_ff);

  hr_utility.set_location(l_proc, 80);

  --
  -- Check the ineligible period type.
  --
  chk_ineligible_period_type
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_ineligible_period_type       => p_rec.ineligible_period_type);

  hr_utility.set_location(l_proc, 90);

  --
  -- Check the ineligibility formula.
  --
  chk_ineligibility_formula_id
    (p_effective_date               => p_effective_date
    ,p_accrual_plan_id              => p_rec.accrual_plan_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_business_group_id            => p_rec.business_group_id
    ,p_ineligibility_formula_id     => p_rec.ineligibility_formula_id);

  hr_utility.set_location(l_proc, 100);

  --
  -- Check the flexfields.
  --
  pay_pap_bus.chk_ddf (p_rec);

  hr_utility.set_location(l_proc, 110);

  pay_pap_bus.chk_ddf_context
    (p_business_group_id           => p_rec.business_group_id
    ,p_information_category        => p_rec.information_category
    ,p_accrual_category            => p_rec.accrual_category
    ,p_accrual_plan_id             => p_rec.accrual_plan_id
    ,p_object_version_number       => p_rec.object_version_number);

  hr_utility.set_location(' Leaving:'||l_proc, 120);

END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_pap_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_accrual_plan_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_accrual_plans b
    where b.accrual_plan_id      = p_accrual_plan_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'accrual_plan_id',
                             p_argument_value => p_accrual_plan_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
--
/*
procedure set_security_group_id
(p_accrual_plan_id            in     pay_accrual_plans.accrual_plan_id%TYPE
) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups  pbg
         , pay_accrual_plans    pap
     where pap.accrual_plan_id   = p_accrual_plan_id
       and pbg.business_group_id = pap.business_group_id
  order by pap.accrual_plan_name;
  --
  -- Local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) := g_package||'set_security_group_id';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'accrual_plan_id',
                             p_argument_value => p_accrual_plan_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
end set_security_group_id;
--
*/
end pay_pap_bus;

/
