--------------------------------------------------------
--  DDL for Package Body PER_PCE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_BUS" as
/* $Header: pepcerhi.pkb 120.1 2006/10/18 09:19:34 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  per_pce_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            VARCHAR2(150)  DEFAULT NULL;
g_cagr_entitlement_id         NUMBER         DEFAULT NULL;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id
  (p_cagr_entitlement_id     IN NUMBER
  ,p_collective_agreement_id IN per_cagr_entitlements.collective_agreement_ID%TYPE
  ) IS
  --
  -- Declare cursor
  --
  CURSOR csr_sec_grp IS
    SELECT pbg.security_group_id
      FROM per_business_groups pbg,
           per_cagr_entitlements pce,
           per_collective_agreements pca
     WHERE pce.cagr_entitlement_id     = p_cagr_entitlement_id
	   AND pca.collective_agreement_id = p_collective_agreement_id
	   AND pbg.business_group_id       = pca.business_group_id;

  --
  -- Declare local variables
  --
  l_security_group_id NUMBER;
  l_proc              VARCHAR2(72)  :=  g_package||'set_security_group_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not NULL
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_entitlement_id'
    ,p_argument_value     => p_cagr_entitlement_id
    );
  --
  OPEN csr_sec_grp;
  FETCH csr_sec_grp INTO l_security_group_id;
  --
  IF csr_sec_grp%notfound THEN
     --
     CLOSE csr_sec_grp;
     --
     -- The primary key IS invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  END IF;
  CLOSE csr_sec_grp;
  --
  -- Set the security_group_id IN CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION return_legislation_code
  (p_cagr_entitlement_id     IN NUMBER
  ,p_collective_agreement_id IN per_cagr_entitlements.collective_agreement_ID%TYPE
  )
  RETURN VARCHAR2 IS
  --
  -- Declare cursor
  --

  CURSOR csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups   pbg,
           per_cagr_entitlements pce,
		   per_collective_agreements pca
     WHERE pce.cagr_entitlement_id     = p_cagr_entitlement_id
	   AND pca.collective_agreement_id = p_collective_agreement_id
	   AND pbg.business_group_id       = pca.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  VARCHAR2(150);
  l_proc              VARCHAR2(72)  :=  g_package||'return_legislation_code';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not NULL
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_entitlement_id'
    ,p_argument_value     => p_cagr_entitlement_id
    );
  --
  IF ( nvl(per_pce_bus.g_cagr_entitlement_id, hr_api.g_number)
       = p_cagr_entitlement_id) THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value IN the global
    -- variable.
    --
    l_legislation_code := per_pce_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID IS different to the last call to this function
    -- or this IS the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key IS invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_pce_bus.g_cagr_entitlement_id         := p_cagr_entitlement_id;
    per_pce_bus.g_legislation_code  := l_legislation_code;
  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  RETURN l_legislation_code;
END return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure IS used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error IS generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently IN
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error IS raised if any of the non updatable attributes
--   have been altered.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_non_updateable_args
  (p_effective_date IN DATE
  ,p_rec            IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc     VARCHAR2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument VARCHAR2(30);
--
BEGIN
  --
  -- Only proceed with the validation if a row exists for the current
  -- record IN the HR Schema.
  --
  IF NOT per_pce_shd.api_updating
      (p_cagr_entitlement_id                  => p_rec.cagr_entitlement_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
    --
    fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE ', l_proc);
    fnd_message.set_token('STEP ', '5');
    fnd_message.raise_error;
	--
  END IF;
  --
  IF nvl(p_rec.collective_agreement_id, hr_api.g_number) <>
     nvl(per_pce_shd.g_old_rec.collective_agreement_id,hr_api.g_number) THEN
    --
    l_argument := 'collective_agreement_id';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.cagr_entitlement_item_id, hr_api.g_number) <>
     nvl(per_pce_shd.g_old_rec.cagr_entitlement_item_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_entitlement_item_id';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.formula_criteria, hr_api.g_varchar2) <>
     nvl(per_pce_shd.g_old_rec.formula_criteria,hr_api.g_varchar2) THEN
    --
    l_argument := 'formula_criteria';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.cagr_entitlement_item_id, hr_api.g_number) <>
     nvl(per_pce_shd.g_old_rec.cagr_entitlement_item_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_entitlement_item_id';
    RAISE l_error;
    --
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  --
END chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_status >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the status exists in HR_LOOKUPS for the
--    lookup type 'CAGR_STATUS'
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_effective_date
--    p_status
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_status
  (p_cagr_entitlement_id IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_effective_date      IN DATE
  ,p_status              IN per_cagr_entitlements.status%TYPE
  ) IS
  --
  -- Declare Local variables
  --
  l_proc     VARCHAR2(72) := g_package||'chk_status';
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter IS set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'status'
    ,p_argument_value => p_status
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for status has changed
  --
  IF ( (p_cagr_entitlement_id IS NULL) OR
       ((p_cagr_entitlement_id IS NOT NULL) AND
        (per_pce_shd.g_old_rec.status <> p_status))) THEN
	--
	hr_utility.set_location(l_proc,30);
	--
    -- Check that the status exists IN HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CAGR_STATUS'
      ,p_lookup_code           => p_status) THEN
      --
      hr_utility.set_location(l_proc, 40);
      --
      hr_utility.set_message(800, 'HR_289267_STATUS_INVALID');
      hr_utility.raise_error;
      --
    END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_status;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_message_level >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the message_level exists in HR_LOOKUPS for the
--    lookup type 'CAGR_MESSAGE_LEVEL'
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_effective_date
--    p_message_level
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_message_level
  (p_cagr_entitlement_id IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_effective_date      IN DATE
  ,p_message_level       IN per_cagr_entitlements.message_level%TYPE
  ) IS
  --
  -- Declare Local variables
  --
  l_proc     VARCHAR2(72) := g_package||'chk_message_level';
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  IF p_message_level IS NOT NULL THEN
    --
    -- Check mandatory parameter IS set
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective_date'
      ,p_argument_value => p_effective_date
      );
    --
    hr_utility.set_location(l_proc,20);
    --
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for message level has changed
    --
    IF ( (p_cagr_entitlement_id IS NULL) OR
         ((p_cagr_entitlement_id IS NOT NULL) AND
          (per_pce_shd.g_old_rec.message_level <> p_message_level))) THEN
	  --
	  hr_utility.set_location(l_proc,30);
	  --
      -- Check that the unit_of_measure exists IN HR_LOOKUPS
      --
      IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'CAGR_MESSAGE_LEVEL'
        ,p_lookup_code           => p_message_level) THEN
        --
        hr_utility.set_location(l_proc, 40);
        --
        hr_utility.set_message(800, 'HR_289268_MESSAGE_LEVEL_INV');
        hr_utility.raise_error;
        --
      END IF;
	  --
	END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_message_level;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_formula_criteria_mismatch >-------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the formula_criteria, and formula_id match. So
--    if the formula_criteria is 'F' then formula_id must be populated and
--    if the formula_criteria is 'C' then formula_id must be null.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_formula_id
--    p_formula_criteria
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_formula_criteria_mismatch
  (p_formula_id          IN per_cagr_entitlements.formula_id%TYPE
  ,p_formula_criteria    IN per_cagr_entitlements.formula_criteria%TYPE
  ) IS
  --
  -- Declare Local variables
  --
  l_proc     VARCHAR2(72) := g_package||'chk_formula_criteria_mismatch';
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check that if the formula_id IS populated then the
  -- formula_criteria value should be 'F'
  --
  IF p_formula_criteria = 'F' AND p_formula_id IS NULL THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    hr_utility.set_message(800, 'HR_289264_FORMULA_CRITERIA_INV');
    hr_utility.raise_error;
	--
  ELSIF p_formula_criteria = 'C' AND p_formula_id IS NOT NULL THEN
	--
	hr_utility.set_location(l_proc, 30);
    --
    hr_utility.set_message(800, 'HR_289265_CRITERIA_FORMULA_MIS');
    hr_utility.raise_error;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_formula_criteria_mismatch;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_formula_criteria >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the formula_criteria exists in HR_LOOKUPS for the
--    lookup_type 'CAGR_CRITERIA_TYPE'
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_effective_date
--    p_formula_id
--    p_formula_criteria
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_formula_criteria
  (p_cagr_entitlement_id IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_effective_date      IN DATE
  ,p_formula_id          IN per_cagr_entitlements.formula_id%TYPE
  ,p_formula_criteria    IN per_cagr_entitlements.formula_criteria%TYPE
  ) IS
  --
  -- Declare Local variables
  --
  l_proc     VARCHAR2(72) := g_package||'chk_formula_criteria';
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter IS set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'formula_criteria'
    ,p_argument_value => p_formula_criteria
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only validate if we are inserting
  --
    IF ( (p_cagr_entitlement_id IS NULL) OR
       ((p_cagr_entitlement_id IS NOT NULL) AND
        (per_pce_shd.g_old_rec.formula_id <> p_formula_id))) THEN
	--
	hr_utility.set_location(l_proc,30);
	--
    -- Check that the formula_criteria exists IN HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CAGR_CRITERIA_TYPE'
      ,p_lookup_code           => p_formula_criteria) THEN
      --
      hr_utility.set_location(l_proc, 40);
      --
      hr_utility.set_message(800, 'HR_289354_INV_FORM_CRITERIA');
      hr_utility.raise_error;
      --
    END IF;
	--
	hr_utility.set_location(l_proc, 50);
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_formula_criteria;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_cagr_entitlement_item_id >------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the cagr_entitlement_item_id exists in
--    PER_CAGR_ENTITLEMENT_ITEMS.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_cagr_entitlement_item_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_cagr_entitlement_item_id
  (p_cagr_entitlement_id      IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_cagr_entitlement_item_id IN NUMBER) IS
  --
  -- Declare Cursors
  --
  CURSOR chk_id IS
    SELECT cei.cagr_entitlement_item_id
	FROM   per_cagr_entitlement_items cei
	WHERE  cei.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
  -- Declare Local variables
  --
  l_proc    VARCHAR2(72) := g_package||'chk_cagr_entitlement_item_id';
  l_item_id per_cagr_entitlements.cagr_entitlement_item_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only validate if we are inserting a record
  --
  IF p_cagr_entitlement_id IS NULL THEN
    --
	hr_utility.set_location(l_proc,20);
	--
	OPEN chk_id;
	FETCH chk_id INTO l_item_id;
	--
	-- If the entitlement item id does not exists
	-- then raise an error.
	--
	IF chk_id%NOTFOUND THEN
	  --
	  CLOSE chk_id;
	  --
	  hr_utility.set_message(800, 'HR_289353_ITEM_ID_INVALID');
      hr_utility.raise_error;
	  --
	ELSE
	  --
	  CLOSE chk_id;
	  --
	END IF;
	--
  END IF;
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_cagr_entitlement_item_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_collective_agreement_id >-------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the collective_agreement_id exists in the
--    PER_COLLECTIVE_AGREEMENTS table.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_cagr_collective_agreement_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_collective_agreement_id
  (p_cagr_entitlement_id     IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_business_group_id       IN NUMBER
  ,p_collective_agreement_id IN NUMBER) IS
  --
  -- Declare Cursors
  --
  CURSOR chk_id IS
    SELECT cag.collective_agreement_id
	FROM   per_collective_agreements cag
	WHERE  cag.business_group_id       = p_business_group_id
	AND    cag.collective_agreement_id = p_collective_agreement_id;
  --
  -- Declare Local variables
  --
  l_proc    VARCHAR2(72) := g_package||'chk_collective_agreement_id';
  l_item_id per_cagr_entitlements.collective_agreement_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only validate if we are inserting a record
  --
  IF p_cagr_entitlement_id IS NULL THEN
    --
	hr_utility.set_location(l_proc,20);
	--
	OPEN  chk_id;
	FETCH chk_id INTO l_item_id;
	--
	-- If the entitlement item id does not exists
	-- then raise an error.
	--
	IF chk_id%NOTFOUND THEN
	  --
	  CLOSE chk_id;
	  --
	  hr_utility.set_message(800, 'PER_52816_COLLECTIVE_AGREEMENT');
      hr_utility.raise_error;
	  --
	ELSE
	  --
	  CLOSE chk_id;
	  --
	END IF;
	--
  END IF;
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_collective_agreement_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_formula_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the formula_id exists IN FF_FORMULAS_F and is of
--    the new collective agreement type.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_effective_date
--    p_formula_id
--    p_formula_criteria
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_formula_id
  (p_cagr_entitlement_id IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_effective_date      IN DATE
  ,p_business_group_id   IN NUMBER
  ,p_formula_id          IN per_cagr_entitlements.formula_id%TYPE
  ,p_formula_criteria    IN per_cagr_entitlements.formula_criteria%TYPE
  ) IS
  --
  -- Declare Cursors
  --
  CURSOR chk_formula_id IS
    SELECT ff.formula_id
	FROM   ff_formulas_f ff,
	       ff_formula_types ft,
		   per_business_groups pg
	WHERE  NVL(ff.legislation_code, pg.legislation_code) =
	       pg.legislation_code
	AND    NVL(ff.business_group_id,p_business_group_id) =
	       pg.business_group_id
	AND    pg.business_group_id   = p_business_group_id
	AND    ft.formula_type_name   = 'CAGR'
	AND    ft.formula_type_id     = ff.formula_type_id
	AND    ff.formula_id          = p_formula_id
	AND    p_effective_date BETWEEN ff.effective_start_date
	                            AND ff.effective_end_date;
  --
  -- Declare Local variables
  --
  l_proc     VARCHAR2(72) := g_package||'chk_formula_id';
  l_dummy_id per_cagr_entitlements.formula_id%TYPE;
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter IS set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'formula_criteria'
    ,p_argument_value => p_formula_criteria
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for formula id has changed
  --
  IF ( (p_cagr_entitlement_id IS NULL) OR
       ((p_cagr_entitlement_id IS NOT NULL) AND
        (per_pce_shd.g_old_rec.formula_id <> p_formula_id))) THEN
	--
	hr_utility.set_location(l_proc,30);
	--
	-- Only check the ff_formula_f table if the
	-- p_formula_id has a values
	--
	IF p_formula_id IS NOT NULL THEN
	  --
	  OPEN  chk_formula_id;
	  FETCH chk_formula_id INTO l_dummy_id;
	  --
	  IF chk_formula_id%NOTFOUND THEN
	    --
		hr_utility.set_location(l_proc, 40);
        --
		CLOSE chk_formula_id;
		--
        hr_utility.set_message(800, 'HR_289263_FORMULA_ID_INVALID');
        hr_utility.raise_error;
		--
	  ELSE
	    --
		hr_utility.set_location(l_proc, 50);
		--
		CLOSE chk_formula_id;
		--
      END IF;
	  --
    END IF;
	--
	hr_utility.set_location(l_proc, 60);
	--
	-- Check that if the formula_id IS populated then the
	-- formula_criteria field IS set to 'FORMULA' and that
	-- if the formula_id IS NULL then the formula_criteria
	-- field IS set to 'CRITERIA'
	--
	chk_formula_criteria_mismatch
      (p_formula_id       => p_formula_id
      ,p_formula_criteria => p_formula_criteria
      );
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_formula_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_start_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the start_date is not before the start_date of the
--    collective agreement and after the end_date for the entitlement record
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_start_Date
--    p_end_Date
--    p_collective_agreement_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_start_date
  (p_cagr_entitlement_id     IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_start_date              IN per_cagr_entitlements.start_date%TYPE
  ,p_end_date                IN per_cagr_entitlements.end_date%TYPE
  ,p_collective_Agreement_id IN per_cagr_entitlements.collective_agreement_id%TYPE
  ) IS
  --
  -- Define cursors
  --
  CURSOR chk_collective_agreement_date IS
    SELECT pca.start_date
	FROM   per_collective_agreements pca
	WHERE  p_start_date < pca.start_date
	AND    pca.collective_Agreement_id = p_collective_agreement_id;
  --
  l_proc       VARCHAR2(72) := g_package||'chk_start_date';
  l_dummy_date per_cagr_entitlements.start_date%TYPE;
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter IS set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check that the start_date IS not before the
  -- start_date for the collective agreements.
  --
  OPEN chk_collective_agreement_date;
  FETCH chk_collective_agreement_date INTO l_dummy_date;
  --
  IF chk_collective_agreement_date%FOUND THEN
    --
    CLOSE chk_collective_agreement_date;
    --
    hr_utility.set_message(800, 'HR_289261_ST_DATE_BEFORE_CAGR');
    hr_utility.raise_error;
	--
  ELSE
	--
	hr_utility.set_location(l_proc,40);
	--
	CLOSE chk_collective_agreement_date;
	--
  END IF;
  --
  -- Check that start_date IS not after the end_date
  --
  IF p_start_date > p_end_date THEN
    --
	hr_utility.set_message(800, 'HR_289262_ST_DATE_BEFORE_EDATE');
    hr_utility.raise_error;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_start_date;
--
--  ---------------------------------------------------------------------------
--  |--------------------------------< chk_end_date >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the end_date IS not after the end_date of the
--    collective agreement and not before the start_date for the entitlement
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_start_Date
--    p_end_Date
--    p_collective_agreement_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_end_date
  (p_cagr_entitlement_id     IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_start_date              IN per_cagr_entitlements.start_date%TYPE
  ,p_end_date                IN per_cagr_entitlements.end_date%TYPE
  ,p_effective_date          IN DATE
  ) IS
  --
  -- Declare Cursors
  --
  CURSOR csr_check_line_end_dates IS
    SELECT 'X'
	FROM   per_cagr_entitlement_lines_f pcl
	WHERE  pcl.cagr_entitlement_id = p_cagr_entitlement_id
	AND    DECODE(pcl.effective_end_date
	             ,hr_general.end_of_time,hr_general.start_of_time
				 ,pcl.effective_end_date) > NVL(p_end_date,hr_general.end_of_time);
  --
  l_proc  VARCHAR2(72) := g_package||'chk_end_date';
  l_dummy VARCHAR2(1);
  --
BEGIN
 --
  hr_utility.set_location('Entering : '||p_end_date||'/'||l_proc,10);
  --
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for formula id has changed
  --
/*
  IF ( (p_cagr_entitlement_id IS NULL) OR
       ((p_cagr_entitlement_id IS NOT NULL) AND
        (per_pce_shd.g_old_rec.end_date <>
		 NVL(p_end_date,hr_general.end_of_time)))) THEN*/
    --
    hr_utility.set_location(l_proc,20);
    --
    -- Check that start_date IS not after the end_date
    --
    IF NVL(p_end_date,hr_general.end_of_time) < p_start_date THEN
      --
      hr_utility.set_message(800, 'HR_289271_EDATE_AFTER_ST_DATE');
      hr_utility.raise_error;
      --
	END IF;
	--
	-- Check that the end_date is not before any end dates for
	-- any per_cagr_entitlement_lines_f
	--
	OPEN csr_check_line_end_dates;
	FETCH csr_check_line_end_dates INTO l_dummy;
	--
	IF csr_check_line_end_dates%FOUND THEN
	  --
	  CLOSE csr_check_line_end_dates;
	  --
      hr_utility.set_message(800, 'HR_289393_INV_END_DATE');
      hr_utility.raise_error;
      --
	ELSE
	  --
	  CLOSE csr_check_line_end_dates;
	  --
	END IF;
	--
	-- Check that the end_date is not being set
	-- to a date before the effective date
	--
	IF NVL(p_end_date,hr_general.end_of_time) < p_effective_date THEN
	  --
      hr_utility.set_message(800, 'HR_289394_EDATE_BEFORE_EFF_DAT');
      hr_utility.raise_error;
      --
	END IF;
	--
 -- END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_end_date;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_entitlement_uniqueness >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Ensures that the entitlement item for the entitlement record has not
--    already been defined for the collective agreement that the entitlement
--    is linked to.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_id
--    p_cagr_entitlement_item_id
--    p_collective_agreement_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing IS
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {END of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_entitlement_uniqueness
  (p_cagr_entitlement_id      IN per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlements.cagr_entitlement_item_id%TYPE
  ,p_collective_agreement_id  IN per_cagr_entitlements.collective_agreement_id%TYPE
  ) IS
  --
  -- Declare Cursors
  --
  CURSOR csr_chk_uniqueness IS
    SELECT pce.cagr_entitlement_id
	FROM   per_cagr_entitlements pce
	WHERE  pce.collective_agreement_id  = p_collective_agreement_id
	AND    pce.cagr_entitlement_item_id = p_cagr_entitlement_item_id;
  --
  l_proc      VARCHAR2(72) := g_package||'chk_end_date';
  l_dummy_id  per_cagr_entitlements.cagr_entitlement_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter IS set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'collective_agreement_id'
    ,p_argument_value => p_collective_agreement_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'cagr_entitlement_item_id'
    ,p_argument_value => p_cagr_entitlement_item_id
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Validate that the entitlement item has not already
  -- been defined within the collective agreement.
  --
  OPEN  csr_chk_uniqueness;
  FETCH csr_chk_uniqueness INTO l_dummy_id;
  --
  IF csr_chk_uniqueness%FOUND THEN
    --
	CLOSE csr_chk_uniqueness;
	--
    hr_utility.set_message(800, 'HR_289272_ENTITLEMENT_NOT_UNIQ');
    hr_utility.raise_error;
	--
  ELSE
    --
	hr_utility.set_location(l_proc,30);
	--
	CLOSE csr_chk_uniqueness;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc, 999);
  --
END chk_entitlement_uniqueness;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN per_pce_shd.g_rec_type
  ) IS
  --
  l_proc              VARCHAR2(72) := g_package||'insert_validate';
  l_business_group_id NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call procedure that returns the business_group_id
  -- that will be used in the chk procedures
  --
  per_pce_shd.retrieve_cagr_info
    (p_collective_agreement_id => p_rec.collective_agreement_id
    ,p_business_group_id       => l_business_group_id);
  --
  --
  -- Call all supporting business operations
  --
  /*per_pce_bus.set_security_group_id
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_collective_agreement_id => p_rec.collective_agreement_id
    );  */
  --
  hr_utility.set_location(l_proc,20);
  --
  per_pce_bus.chk_start_date
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date
    ,p_collective_Agreement_id => p_rec.collective_agreement_id
    );
  --
  hr_utility.set_location(l_proc,25);
  --
  per_pce_bus.chk_end_date
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date
	,p_effective_date          => p_effective_date
	);
  --
  hr_utility.set_location(l_proc,30);
  --
  per_pce_bus.chk_formula_id
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_formula_id          => p_rec.formula_id
	,p_business_group_id   => l_business_group_id
	,p_formula_criteria    => p_rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,40);
  --
  per_pce_bus.chk_formula_criteria
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_formula_id          => p_rec.formula_id
    ,p_formula_criteria    => p_rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,50);
  --
  per_pce_bus.chk_formula_criteria_mismatch
    (p_formula_id       => p_rec.formula_id
    ,p_formula_criteria => p_rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,60);
  --
  per_pce_bus.chk_status
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_status              => p_rec.status
    );
  --
  hr_utility.set_location(l_proc,70);
  --
  per_pce_bus.chk_message_level
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_message_level       => p_rec.message_level
    );
  --
  hr_utility.set_location(l_proc,80);
  --
  per_pce_bus.chk_cagr_entitlement_item_id
  (p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
  ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id);
  --
  hr_utility.set_location(l_proc,90);
  --
  per_pce_bus. chk_entitlement_uniqueness
    (p_cagr_entitlement_id      => p_rec.cagr_entitlement_id
    ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_collective_agreement_id  => p_rec.collective_agreement_id
    );
  --
  hr_utility.set_location(l_proc,100);
  --
  per_pce_bus.chk_collective_agreement_id
  (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
  ,p_business_group_id       => l_business_group_id
  ,p_collective_agreement_id => p_rec.collective_agreement_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 900);
  --
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_validate
  (p_effective_date IN DATE
  ,p_rec            IN per_pce_shd.g_rec_type
  ) IS
  --
  l_proc              VARCHAR2(72) := g_package||'update_validate';
  l_business_group_id NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  per_pce_bus.set_security_group_id
    (p_cagr_entitlement_id     => p_rec.cagr_entitlement_id
    ,p_collective_agreement_id => p_rec.collective_agreement_id
    );
  --
  -- Call procedure that returns the business_group_id
  -- that will be used in the chk procedures
  --
  per_pce_shd.retrieve_cagr_info
    (p_collective_agreement_id => p_rec.collective_agreement_id
    ,p_business_group_id       => l_business_group_id);
  --
  hr_utility.set_location(l_proc,20);
  --
  chk_non_updateable_args
    (p_effective_date => p_effective_date
    ,p_rec            => p_rec
    );
  --
  hr_utility.set_location(l_proc,30);
  --
  per_pce_bus.chk_formula_id
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
	,p_business_group_id   => l_business_group_id
    ,p_formula_id          => p_rec.formula_id
	,p_formula_criteria    => p_Rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,50);
  --
  per_pce_bus.chk_formula_criteria
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_formula_id          => p_rec.formula_id
    ,p_formula_criteria    => p_rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,60);
  --
  per_pce_bus.chk_formula_criteria_mismatch
    (p_formula_id       => p_rec.formula_id
    ,p_formula_criteria => p_rec.formula_criteria
    );
  --
  hr_utility.set_location(l_proc,70);
  --
  per_pce_bus.chk_status
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_status              => p_rec.status
    );
  --
  hr_utility.set_location(l_proc,80);
  --
  per_pce_bus.chk_message_level
    (p_cagr_entitlement_id => p_rec.cagr_entitlement_id
    ,p_effective_date      => p_effective_date
    ,p_message_level       => p_rec.message_level
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec                          IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'delete_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END delete_validate;
--
END per_pce_bus;

/
