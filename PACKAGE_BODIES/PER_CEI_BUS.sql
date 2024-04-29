--------------------------------------------------------
--  DDL for Package Body PER_CEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEI_BUS" as
/* $Header: peceirhi.pkb 120.1 2006/10/18 08:58:46 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cei_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_entitlement_item_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_entitlement_item_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_entitlement_items cei
     where cei.cagr_entitlement_item_id = p_cagr_entitlement_item_id
       and pbg.business_group_id = cei.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_entitlement_item_id'
    ,p_argument_value     => p_cagr_entitlement_item_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
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
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_cagr_entitlement_item_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_cagr_entitlement_items cei
     where cei.cagr_entitlement_item_id = p_cagr_entitlement_item_id
       and pbg.business_group_id = cei.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'cagr_entitlement_item_id'
    ,p_argument_value     => p_cagr_entitlement_item_id
    );
  --
  if ( nvl(per_cei_bus.g_cagr_entitlement_item_id, hr_api.g_number)
       = p_cagr_entitlement_item_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cei_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
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
    per_cei_bus.g_cagr_entitlement_item_id := p_cagr_entitlement_item_id;
    per_cei_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
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
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in per_cei_shd.g_rec_type
  ) IS
  --
  l_proc        varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  l_item_in_use BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_cei_shd.api_updating
    (p_cagr_entitlement_item_id             => p_rec.cagr_entitlement_item_id
     ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- If the item has been seeded by development then
  -- raise an error as updates are not allowed of
  -- seeded items.
  --
  IF ((p_rec.business_group_id IS NULL) AND
      (p_rec.legislation_code  IS NULL)) OR
	 ((p_rec.business_group_id IS NULL) AND
	  (p_rec.legislation_code IS NOT NULL)) THEN
	--
	hr_utility.set_message(800, 'HR_289362_UPD_INV_FOR_SEEDED_I');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_cei_shd.g_old_rec.business_group_id,hr_api.g_number) THEN
    --
    l_argument := 'business_group_id';
    RAISE l_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(per_cei_shd.g_old_rec.legislation_code,hr_api.g_varchar2) THEN
    --
    l_argument := 'legislation_code';
    RAISE l_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  -- Check to see if the entitlement item has
  -- been used by any collective agreements
  --
  l_item_in_use := per_cei_shd.entitlement_item_in_use
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id);
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- If the Entitlement ITem has been used by Collective Agreement
  -- then the following fields are now not updatable and so
  -- should an error should be raised.
  --
  IF l_item_in_use THEN
    --
    IF nvl(p_rec.mult_entries_allowed_flag , hr_api.g_varchar2) <>
       nvl(per_cei_shd.g_old_rec.mult_entries_allowed_flag,hr_api.g_varchar2) THEN
      --
      l_argument := 'mult_entries_allowed_flag';
      RAISE l_error;
      --
    END IF;
	--
    hr_utility.set_location(l_proc||'/'||p_rec.column_type||'/', 50);
    --
	IF nvl(p_rec.column_type, hr_api.g_varchar2) <>
       nvl(per_cei_shd.g_old_rec.column_type,hr_api.g_varchar2) THEN
       --
      l_argument := 'column_type';
      RAISE l_error;
      --
	END IF;
	--
    hr_utility.set_location(l_proc, 60);
    --
    IF nvl(p_rec.flex_value_set_id, hr_api.g_number) <>
       nvl(per_cei_shd.g_old_rec.flex_value_set_id,hr_api.g_number) THEN
       --
      l_argument := 'flex_value_set_id';
      RAISE l_error;
      --
	END IF;
	--
    hr_utility.set_location(l_proc, 70);
    --
    IF nvl(p_rec.category_name, hr_api.g_varchar2) <>
       nvl(per_cei_shd.g_old_rec.category_name,hr_api.g_varchar2) THEN
       --
      l_argument := 'category_name';
      RAISE l_error;
      --
	END IF;
    --
    hr_utility.set_location(l_proc, 80);
    --
    IF nvl(p_rec.input_value_id, hr_api.g_number) <>
       nvl(per_cei_shd.g_old_rec.input_value_id,hr_api.g_number) THEN
       --
      l_argument := 'input_value_id';
      RAISE l_error;
      --
	END IF;
    --
    hr_utility.set_location(l_proc, 90);
    --
    IF nvl(p_rec.element_type_id, hr_api.g_number) <>
       nvl(per_cei_shd.g_old_rec.element_type_id,hr_api.g_number) THEN
       --
      l_argument := 'element_type_id';
      RAISE l_error;
      --
	END IF;
	--
    IF nvl(p_rec.cagr_api_id, hr_api.g_number) <>
       nvl(per_cei_shd.g_old_rec.cagr_api_id,hr_api.g_number) THEN
      --
      l_argument := 'cagr_api_id';
      RAISE l_error;
      --
	END IF;
	--
    IF nvl(p_rec.cagr_api_param_id, hr_api.g_number) <>
       nvl(per_cei_shd.g_old_rec.cagr_api_param_id,hr_api.g_number) THEN
      --
      l_argument := 'cagr_api_param_id';
      RAISE l_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 999);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_item_name >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the entitlement item name is unique within the
--    category for business group, legislation and global.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_item_id
--    p_item_name
--    p_category_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_item_name
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_item_name                IN per_cagr_entitlement_items.item_name%TYPE
  ,p_category_name            IN per_cagr_entitlement_items.category_name%TYPE
  ,p_legislation_code         IN per_cagr_entitlement_items.legislation_code%TYPE
  ,p_business_group_id        IN per_cagr_entitlement_items.business_group_id%TYPE) IS
  --
  -- Declare Cursors
  --
  CURSOR chk_for_global_item IS
  SELECT cei.item_name
  FROM   per_cagr_entitlement_items cei
  WHERE  cei.item_name         = p_item_name
  AND    cei.category_name     = p_category_name
  AND    cei.business_group_id IS NULL
  AND    cei.legislation_code  IS NULL;
  --
  CURSOR chk_for_legislation_item IS
  SELECT cei.item_name
  FROM   per_cagr_entitlement_items cei
  WHERE  cei.item_name         = p_item_name
  AND    cei.category_name     = p_category_name
  AND    cei.business_group_id IS NULL
  AND    cei.legislation_code  = p_legislation_code;
  --
  CURSOR chk_for_customer_item IS
  SELECT cei.item_name
  FROM   per_cagr_entitlement_items cei
  WHERE  cei.item_name         = p_item_name
  AND    cei.category_name     = p_category_name
  AND    cei.business_group_id = p_business_group_id
  AND    cei.legislation_code  = p_legislation_code;
  --
  l_proc      VARCHAR2(72) := g_package||'chk_item_name';
  l_item_name per_cagr_entitlement_items.item_name%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  IF p_item_name IS NULL THEN
    --
    hr_utility.set_message(800,'HR_289220_ITEM_NAME_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for item name has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.item_name <> p_item_name))) THEN
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Check to see if a Global Item has already been defined
  --
  OPEN chk_for_global_item;
  FETCH chk_for_global_item INTO l_item_name;
  --
  IF chk_for_global_item%FOUND THEN
    --
    CLOSE chk_for_global_item;
    --
    hr_utility.set_message(800,'HR_289219_ITEM_NAME_INVALID');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE chk_for_global_item;
  --
  -- Check to see if a Localisation Item has already been defined
  --
  OPEN  chk_for_legislation_item;
  FETCH chk_for_legislation_item INTO l_item_name;
  --
  IF chk_for_legislation_item%FOUND THEN
    --
    CLOSE chk_for_legislation_item;
    --
    hr_utility.set_message(800,'HR_289219_ITEM_NAME_INVALID');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE chk_for_legislation_item;
  --
  -- Check to see if a Customer Item has already been defined
  --
  OPEN  chk_for_customer_item;
  FETCH chk_for_customer_item INTO l_item_name;
  --
  IF chk_for_customer_item%FOUND THEN
    --
    CLOSE chk_for_customer_item;
    --
    hr_utility.set_message(800,'HR_289219_ITEM_NAME_INVALID');
    hr_utility.raise_error;
    --
  END IF;
  --
  CLOSE chk_for_customer_item;
  --
  END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
END chk_item_name;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_legilsation_code >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the legislation code exists on the database.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_legislation_code
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_legislation_code
  (p_legislation_code IN per_cagr_entitlement_items.legislation_code%TYPE) IS
  --
  --   Local declarations
  --
  l_proc               VARCHAR2(72) := g_package||'chk_legislation_code';
  l_territory_code     fnd_territories.territory_code%TYPE;
  --
  -- Setup cursor for valid legislation code check
  --
  CURSOR csr_valid_legislation_code is
    SELECT territory_code
    FROM   fnd_territories ft
    WHERE  ft.territory_code = p_legislation_code;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Only continue if the legislation code has been populated
  --
  IF p_legislation_code IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    -- Validate legislation code
    --
    OPEN  csr_valid_legislation_code;
    FETCH csr_valid_legislation_code INTO l_territory_code;
    --
    IF csr_valid_legislation_code%notfound THEN
      --
      hr_utility.set_location(l_proc,30);
      --
      CLOSE csr_valid_legislation_code;
      --
      hr_utility.set_message(800,'PER_52123_AMD_LEG_CODE_INV');
      hr_utility.raise_error;
      --
    ELSE
      --
      hr_utility.set_location(l_proc,40);
      --
      CLOSE csr_valid_legislation_code;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,50);
  --
END chk_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_beneficial_rule >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the beneficial rule exists in HR_LOOKUPS for the
--    lookup type "CAGR_BENEFICIAL_RULE"
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_effective_date
--    p_beneficial_rule
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_beneficial_rule
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_beneficial_rule          IN per_cagr_entitlement_items.beneficial_rule%TYPE
  ,p_ben_rule_value_set_id    IN NUMBER
  ,p_effective_date           IN DATE) IS
  --
  --   Local declarations
  --
  l_proc               VARCHAR2(72) := g_package||'chk_beneficial_rule';
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for beneficial rule has changed
  --
  IF p_beneficial_rule IS NOT NULL OR
     NVL(per_cei_shd.g_old_rec.beneficial_rule,hr_api.g_varchar2) <>
	 NVL(p_beneficial_rule, hr_api.g_varchar2)  THEN
    --
    hr_utility.set_location(l_proc, 20);
	--
	-- Check that if a beneficial value set has been entered
	-- that the beneficial rule has also been entered.
	--
	IF p_ben_rule_value_set_id IS NOT NULL AND
	   p_beneficial_rule IS NULL THEN
	  --
          hr_utility.set_message(800, 'HR_289583_BEN_RULE_NULL');
          hr_utility.raise_error;
	  --
	END IF;
    --
    -- Check that the category exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CAGR_BENEFICIAL_RULE'
      ,p_lookup_code           => p_beneficial_rule) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289221_BENEFICIAL_RULE_INV');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_beneficial_rule;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_column_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    If the entitlement item has been linked to a api parameter then ensure
--    that the column_type is the same as the column type for the api
--    parameter. Otherwise ensure that the column type exists HR_LOOKUPS
--    for the lookup_type of 'CAGR_PARAM_TYPES'
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_effective_date
--    p_entitlement_item_id
--    p_column_type
--    p_api_param_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_column_type
  (p_cagr_entitlement_item_id IN NUMBER
  ,p_column_type              IN OUT NOCOPY per_cagr_entitlement_items.column_type%TYPE
  ,p_uom                      IN per_cagr_entitlement_items.uom%TYPE
  ,p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_category_name            IN per_cagr_entitlement_items.category_name%TYPE
  ,p_effective_date           IN DATE) IS
  --
  -- Declare Cursors
  --
  CURSOR csr_chk_api_param_type IS
    SELECT column_type
	  FROM per_cagr_api_parameters p
	 WHERE p.cagr_api_param_id = p_cagr_api_param_id
	  AND  p.column_type = p_column_type;
  --
  --   Local declarations
  --
  l_proc            VARCHAR2(72) := g_package||'chk_column_type';
  l_api_column_type per_cagr_api_parameters.column_type%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for column_type has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
      ((p_cagr_entitlement_item_id IS NOT NULL) AND
       (per_cei_shd.g_old_rec.column_type <> p_column_type))) THEN
    --
    hr_utility.set_location(l_proc, 20);
	--
	-- IF the item is a payroll item or a non-denormalised item
	---then derive the column typefrom the UOM by calling
	-- the convert_uom_to_data_type procedure.
	--
	IF (p_category_name = 'PAY') OR
	   (p_input_value_id IS NULL AND p_cagr_api_param_id IS NULL) THEN
	  --
	  hr_utility.set_location(l_proc, 30);
	  --
	  p_column_type := per_cagr_utility_pkg.convert_uom_to_data_type
	                    (p_uom => p_uom);
	  --
	ELSE
	  --
	  hr_utility.set_location(l_proc, 40);
	  --
	  -- If the entitlement item has been linked to to a
	  -- api parameter then check to see if the column type matches
	  -- the column type passed into this procedure
	  --
	  IF p_cagr_api_param_id IS NOT NULL THEN
	    --
		hr_utility.set_location(l_proc, 50);
		--
	    OPEN  csr_chk_api_param_type;
	    FETCH csr_chk_api_param_type INTO l_api_column_type;
	    --
	    -- IF no records have been found then the column types
	    -- do not match so raise an error
	    --
	    IF csr_chk_api_param_type%NOTFOUND THEN
	      --
		  CLOSE csr_chk_api_param_type;
	      --
		  hr_utility.set_message(800, 'HR_289336_COL_TYPE_MISMATCH');
          hr_utility.raise_error;
		  --
	    END IF;
	    --
	    CLOSE csr_chk_api_param_type;
	    --
	  END IF;
	  --
	END IF;
	--
	hr_utility.set_location(l_proc, 60);
	--
    -- Check that the category exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CAGR_PARAM_TYPES'
      ,p_lookup_code           => p_column_type) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289205_COLUMN_TYPE_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_column_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_column_size >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    If the entitlement item has been linked to a api parameter then ensure
--    that the column_size is the same as the column size for the api
--    parameter.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entitlement_item_id
--    p_column_size
--    p_api_param_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_column_size
  (p_cagr_entitlement_item_id IN NUMBER
  ,p_column_size              IN NUMBER
  ,p_cagr_api_param_id        IN NUMBER) IS
  --
  -- Declare Cursors
  --
  CURSOR csr_chk_api_param_size IS
    SELECT column_size
	  FROM per_cagr_api_parameters p
	 WHERE p.cagr_api_param_id = p_cagr_api_param_id
	  AND  p.column_size = p_column_size;
  --
  --   Local declarations
  --
  l_proc            VARCHAR2(72) := g_package||'chk_column_size';
  l_api_column_size NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'column_size'
    ,p_argument_value => p_column_size
    );
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for column_size has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
      ((p_cagr_entitlement_item_id IS NOT NULL) AND
       (per_cei_shd.g_old_rec.column_size <> p_column_size))) THEN
    --
    hr_utility.set_location(l_proc, 20);
	--
	-- If the entitlement item has been linked to to a
	-- api parameter then check to see if the column size matches
	-- the column size passed into this procedure
	--
	IF p_cagr_api_param_id IS NOT NULL THEN
	  --
	  OPEN  csr_chk_api_param_size;
	  FETCH csr_chk_api_param_size INTO l_api_column_size;
	  --
	  -- IF no records have been found then the column types
	  -- do not match so raise an error
	  --
	  IF csr_chk_api_param_size%NOTFOUND THEN
	    --
		CLOSE csr_chk_api_param_size;
	    --
		hr_utility.set_message(800, 'HR_289337_COL_SIZE_MISMATCH');
        hr_utility.raise_error;
		--
	  END IF;
	  --
	  CLOSE csr_chk_api_param_size;
	  --
	END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_column_size;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_cagr_api_id >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the cagr_api_id exists in PER_CAGR_APIS, and that the
--    cagr_api_param_id has also been populated. Also ensure that the
--    element_type_id is blank.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_id
--    p_cagr_api_param_id
--    p_cagr_entitlement_item_id
--    p_element_type_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_cagr_api_id
  (p_cagr_api_id              IN per_cagr_entitlement_items.cagr_api_id%TYPE
  ,p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_element_type_id          IN per_cagr_entitlement_items.element_type_id%TYPE) IS
  --
  --   Local declarations
  --
  l_proc        VARCHAR2(72) := g_package||'chk_cagr_api_id';
  l_cagr_api_id per_cagr_entitlement_items.cagr_api_id%TYPE;
  --
  CURSOR csr_cagr_api_id IS
    SELECT cagr_api_id
    FROM   per_cagr_apis pca
    WHERE  pca.cagr_api_id = p_cagr_api_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for cagr api id has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (NVL(per_cei_shd.g_old_rec.cagr_api_id, hr_api.g_number) <>
		 NVL(p_cagr_api_id,hr_api.g_number)))) THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    IF p_cagr_api_id IS NOT NULL THEN
      --
      -- Check that the ELEMENT_TYPE_ID has not been populated
      -- as well as the CAGR_API_ID.
      --
      IF p_element_type_id IS NOT NULL THEN
        --
        hr_utility.set_message(800, 'HR_289231_CAGR_ELEMENT_COMB_IN');
        hr_utility.raise_error;
        --
      END IF;
      --
	  -- Check that the CAGR API PARAM ID is populated as well.
	  --
	  IF p_cagr_api_param_id IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289389_API_OR_PARAM_NULL');
        hr_utility.raise_error;
        --
      END IF;
	  --
      hr_utility.set_location(l_proc,30);
      --
      -- Check that the cagr_api_id exists in PER_CAGR_APIS
      --
      OPEN  csr_cagr_api_id;
      FETCH csr_cagr_api_id INTO l_cagr_api_id;
      --
      IF csr_cagr_api_id%NOTFOUND THEN
        --
        CLOSE csr_cagr_api_id;
        --
        hr_utility.set_message(800, 'HR_289230_CAGR_API_ID_INVALID');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,40);
        --
        CLOSE csr_cagr_api_id;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_cagr_api_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_cagr_api_param_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the cagr_api_param_id exists in PER_CAGR_API_PARAMS
--    and that the APi Param ID has been populated as well. Also ensure that
--    the Input_Value_ID has not been populated.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_param_id
--    p_input_value_id
--    p_cagr_entitlement_item_id
--    p_cagr_api_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_cagr_api_param_id
  (p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_cagr_api_id              IN per_cagr_entitlement_items.cagr_api_id%TYPE) IS
  --
  --   Local declarations
  --
  l_proc              VARCHAR2(72) := g_package||'chk_cagr_api_param_id';
  l_cagr_api_param_id per_cagr_entitlement_items.cagr_api_param_id%TYPE;
  --
  CURSOR csr_cagr_api_param_id IS
    SELECT cagr_api_param_id
    FROM   per_cagr_api_parameters cap
    WHERE  cap.cagr_api_param_id = p_cagr_api_param_id
    AND    cap.cagr_api_id       = p_cagr_api_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for cagr api param id has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.cagr_api_param_id <> p_cagr_api_param_id))) THEN
    --
	hr_utility.set_location(l_proc,30);
	--
    IF p_cagr_api_param_id IS NOT NULL THEN
	  --
	  hr_utility.set_location(l_proc,40);
      --
      -- Check that the INPUT_VALUE has not been populated
      -- as well as the CAGR_API_PARAM_ID.
      --
      IF p_input_value_id  IS NOT NULL THEN
        --
        hr_utility.set_message(800, 'HR_289233_PARAM_INP_VAL_COMB');
        hr_utility.raise_error;
        --
      END IF;
      --
	  -- Check that the CAGR API ID is populated as well.
	  --
	  IF p_cagr_api_id IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289389_API_OR_PARAM_NULL');
        hr_utility.raise_error;
        --
      END IF;
	  --
      hr_utility.set_location(l_proc,50);
      --
      -- Check that the cagr_api_param_id exists in PER_CAGR_API_PARAMS
      --
      OPEN  csr_cagr_api_param_id;
      FETCH csr_cagr_api_param_id INTO l_cagr_api_param_id;
      --
      IF csr_cagr_api_param_id%NOTFOUND THEN
        --
        CLOSE csr_cagr_api_param_id;
        --
        hr_utility.set_message(800, 'HR_289232_CAGR_API_PARAM_ID_IN');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,60);
        --
        CLOSE csr_cagr_api_param_id;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_cagr_api_param_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_category_name >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the category_name exists in HR_LOOKUPS.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_effective_date
--    p_category_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_category_name
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_category_name            IN per_cagr_entitlement_items.category_name%TYPE
  ,p_effective_date           IN DATE) IS
  --
  --   Local declarations
  --
  l_proc  VARCHAR2(72) := g_package||'chk_category_name';
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'category_name'
    ,p_argument_value => p_category_name);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for category_name has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.category_name <> p_category_name))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the category  exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'CAGR_CATEGORIES'
      ,p_lookup_code           => p_category_name) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289212_CATEGORY_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,100);
  --
END chk_category_name;
--
--  ---------------------------------------------------------------------------
--  |--------------------------------< chk_uom >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the uom exists in either the UNITS lookup type or
--    the uom defined for the api_parameter in the uom_lookup column. The UOM
--    is also mandatory if the the api_parameter has a uom_lookup seeded.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_effective_date
--    p_uom
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_uom
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_uom                      IN OUT NOCOPY  per_cagr_entitlement_items.uom%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_effective_date           IN DATE) IS
  --
  CURSOR csr_get_param_uom IS
    SELECT p.uom_lookup,
	       p.default_uom
    FROM   per_cagr_api_parameters p
    WHERE  p.cagr_api_param_id = p_cagr_api_param_id;
  --
  CURSOR csr_get_pay_default_uom IS
    SELECT piv.uom
	  FROM pay_input_values_f piv
	 WHERE piv.input_value_id = p_input_value_id
	   AND p_effective_date BETWEEN piv.effective_start_date
	                           AND piv.effective_end_date;
  --
  --   Local declarations
  --
  l_proc        VARCHAR2(72) := g_package||'chk_uom';
  l_uom_lookup  per_cagr_api_parameters.uom_lookup%TYPE;
  l_default_uom per_cagr_api_parameters.default_uom%TYPE;
  l_uom         pay_input_values_f.uom%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for uom has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.uom <> NVL(p_uom,hr_api.g_varchar2)))) THEN
	--
	hr_utility.set_location(l_proc, 20);
	--
	-- If the item has been defined as a denormalised payroll item
	-- then derive the correct UOM from the input value definition.
	-- If a UOM has been specified then overright it with the
	-- correct uom.
	--
	IF p_input_value_id IS NOT NULL THEN
	  --
	  hr_utility.set_location(l_proc, 30);
	  --
	  OPEN csr_get_pay_default_uom;
	  FETCH csr_get_pay_default_uom INTO p_uom;
	  --
	  IF csr_get_pay_default_uom%NOTFOUND THEN
	    --
		CLOSE csr_get_pay_default_uom;
		--
        hr_utility.set_message(800, 'HR_289253_INPUT_VALUE_INV');
        hr_utility.raise_error;
        --
	  END IF;
	  --
	  CLOSE csr_get_pay_default_uom;
	--
	-- If the item has been defined as a non-denormalised item
	-- then check that the UOM exists in the UNITS lookup.
	--
	ELSIF p_input_value_id IS NULL AND
	      p_cagr_api_param_id IS NULL THEN
	  --
	  hr_utility.set_location(l_proc, 40);
	  --
	  IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => NVL(l_uom_lookup,'UNITS')
        ,p_lookup_code           => p_uom) THEN
        --
        hr_utility.set_message(800, 'HR_289242_UOM_INVALID');
        hr_utility.raise_error;
        --
      END IF;
    --
	-- If the item has been defined as a denormalised item
	-- then check to see that the UOM has not been set for
	-- items that have not been linked to parameters defined
	-- with a lookup type. If the parameter does have a
	-- lookup defined check that the UOM is present and
	-- exists for that lookup.
	--
    ELSIF p_cagr_api_param_id IS NOT NULL THEN
      --
      hr_utility.set_location(l_proc, 50);
	  --
      OPEN  csr_get_param_uom;
      FETCH csr_get_param_uom INTO l_uom_lookup, l_default_uom;
      --
      -- If the parameter does not exists then an raise error.
      --
	  IF csr_get_param_uom%NOTFOUND THEN
        --
        CLOSE csr_get_param_uom;
        --
        hr_utility.set_message(800, 'HR_289232_CAGR_API_PARAM_ID_IN');
        hr_utility.raise_error;
        --
	  END IF;
	  --
	  CLOSE csr_get_param_uom;
	  --
	  hr_utility.set_location(l_proc||'/'||l_uom_lookup||'/'||p_uom, 60);
      --
	  -- If the api parameter has been seeded with a uom_lookup
	  -- and the uom has no value against it then raise an
	  -- error as the uom should have a value in this case.
	  --
	  IF l_uom_lookup IS NOT NULL AND
	     p_uom IS NULL THEN
	    --
	    hr_utility.set_message(800, 'HR_289335_UOM_MANDATORY');
        hr_utility.raise_error;
	  --
	  -- If the lookup is null and the uom has been passed into
	  -- this procedure then raise an error, as the UOM cannot be
	  -- set if the parameter lookup has also not been set.
	  --
	  ELSIF p_uom         IS NOT NULL AND
	        l_uom_lookup  IS NULL AND
			l_default_UOM IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289401_UOM_NOT_NULL');
        hr_utility.raise_error;
      --
	  -- If both the UOM and Lookup have been popoulated then
	  -- check to see that the UOM exists in the Lookup.
	  --
	  ELSIF p_uom IS NOT NULL AND
	        l_uom_lookup IS NOT NULL THEN
		--
		hr_utility.set_location(l_proc, 70);
	    --
	    IF hr_api.not_exists_in_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_lookup_type           => l_uom_lookup
            ,p_lookup_code           => p_uom) THEN
          --
          hr_utility.set_message(800, 'HR_289242_UOM_INVALID');
          hr_utility.raise_error;
          --
		END IF;
      --
	  -- If the item has got a default_uom and the uom passed
	  -- in does not match this default uom then raise an error.
	  --
	  ELSIF l_default_uom IS NOT NULL AND
	        p_uom <> l_default_uom THEN
	    --
        hr_utility.set_message(800, 'HR_289401_UOM_NOT_NULL');
        hr_utility.raise_error;
	  --
	  -- If the item has got a default_uom and the UOM is blank
	  -- then copy the value of the default_uom to the uom.
	  --
	  ELSIF l_default_uom IS NOT NULL AND
	        p_uom IS NULL THEN
	    --
		p_uom := l_default_uom;
		--
	   END IF;
	   --
	END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc,999);
  --
END chk_uom;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_item_use >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on delete that the item is not being referenced
--    by a cagr.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entitlement_item_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_item_use
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE) IS
  --
  l_proc        varchar2(72) := g_package || 'chk_item_use';
  l_item_in_use BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'cagr_entitlement_item_id'
    ,p_argument_value => p_cagr_entitlement_item_id
    );
  --
  l_item_in_use := per_cei_shd.entitlement_item_in_use
    (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id);
  --
  IF l_item_in_use THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    hr_utility.set_message(800, 'HR_289234_ENT_ITEM_IN_USE');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,100);
  --
END chk_item_use;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_multiple_entries_flag >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Validate that the correct combination of element being allowed for
--  multiple entries and the entitlement item having the correct value set for
--  the multiple entries allowed flag. Correct combinations are:
--
--  Element Allowed    Entitlment Items
--  Multiple Entries   Multiple Entries Flag   Valid
--  ================   =====================   =====
--
--         N                   Y                NO
--         N                   N                NO
--         N                  NULL              YES
--
--         Y                   Y                YES
--         Y                   N                YES
--         Y                  NULL              NO
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_mult_entries_allowed_flag
--    p_cagr_entitlement_item_id
--    p_category_name
--    p_element_type_id
--    p_business_group_id
--    p_legislation_code
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_multiple_entries_flag
  (p_mult_entries_allowed_flag IN per_cagr_entitlement_items.multiple_entries_allowed_flag%TYPE
  ,p_cagr_entitlement_item_id  IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_category_name             IN per_cagr_entitlement_items.category_name%TYPE
  ,p_element_type_id           IN per_cagr_entitlement_items.element_type_id%TYPE
  ,p_business_group_id         IN per_cagr_entitlement_items.business_group_id%TYPE
  ,p_legislation_code          IN per_cagr_entitlement_items.legislation_code%TYPE
  ,p_effective_date            IN DATE) IS
  --
  CURSOR csr_get_pay_element IS
    SELECT multiple_entries_allowed_flag
    FROM   pay_element_types_f p --pay_element_types_x p
    WHERE  ((p.business_group_id  = p_business_group_id) OR
	        (p.business_group_id IS NULL))
    AND    ((p.legislation_code   = p_legislation_code) OR
	        (p.legislation_code   IS NULL))
    AND    p.element_type_id    = p_element_type_id
    AND    p_effective_date between p.effective_start_date and p.effective_end_date;
  --
  l_proc        VARCHAR2(72) := g_package || 'chk_multiple_entries_flag';
  l_multi_flag  VARCHAR2(15);
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,5);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
   	,p_argument_value => p_effective_date);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for item name has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.mult_entries_allowed_flag <>
		 NVL(p_mult_entries_allowed_flag,hr_api.g_varchar2)))) THEN
    --
	hr_utility.set_location(l_proc,20);
    --
	-- Check that the category is correct
	--
	IF p_category_name <> 'PAY' AND
	   P_element_type_id IS NOT NULL THEN
	  --
      hr_utility.set_message(800, 'HR_289390_MULTI_CAT_COMB_INV');
      hr_utility.raise_error;
      --
    END IF;
	--
	-- If the element type id is populated then
	-- fetch the multi_entries_allowed_flag
	--
	IF p_element_type_id IS NOT NULL THEN
	  --
	  hr_utility.set_location(l_proc,30);
      --
      OPEN  csr_get_pay_element;
      FETCH csr_get_pay_element INTO l_multi_flag;
	  --
	  -- Fetch the multiple_entries_allowed_flag for the element.
	  -- If it does not exist then raise an appropiate error.
	  --
      IF csr_get_pay_element%NOTFOUND THEN
	    --
	    CLOSE csr_get_pay_element;
	    --
	    hr_utility.set_message(800, 'HR_289252_ELEMENT_TYPE_INV');
        hr_utility.raise_error;
	    --
	  ELSE
	    --
	    CLOSE csr_get_pay_element;
	    --
	  END IF;
	--
	-- If the element type id is not populated then
	-- set the multi_entries_allowed_flag to N
	--
	ELSE
	  --
	  hr_utility.set_location(l_proc,40);
      --
	  l_multi_flag := 'N';
	  --
	END IF;
	--
	hr_utility.set_location(l_proc||'/'||l_multi_flag,45);
	--
	-- If the Element is allowed multiple entries and the multi
	-- entries allowed flag for the entitlement item is not either
	-- Y or N then raise an error.
	--
	IF l_multi_flag = 'Y' AND
	   (p_mult_entries_allowed_flag NOT IN ('Y','N') OR
	    p_mult_entries_allowed_flag IS NULL)   THEN
	  --
	  hr_utility.set_message(800, 'HR_289278_INV_MULT_ENTRY_FLAG');
      hr_utility.raise_error;
      --
	ELSIF l_multi_flag = 'N' AND
	      p_mult_entries_allowed_flag IS NOT NULL THEN
      --
	  hr_utility.set_message(800, 'HR_289387_MULTI_FLAG_NOT_NULL');
      hr_utility.raise_error;
      --
	END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_multiple_entries_flag;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_auto_create_entries_flag >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--  Validate that a value (Y/N) is supplied for category payroll i.e. when the
--  category name is 'PAY'.
--
--  (Added for CEI Enhancement)
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_auto_create_entries_flag
--    p_category_name
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_auto_create_entries_flag
  (p_auto_create_entries_flag IN OUT NOCOPY per_cagr_entitlement_items.auto_create_entries_flag%TYPE
  ,p_category_name            IN per_cagr_entitlement_items.category_name%TYPE
  ,p_effective_date           IN DATE) IS
  --
  l_proc VARCHAR2(72) := g_package || 'chk_auto_create_entries_flag';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check conditionally mandatory parameter is set else default.
  --
  IF p_category_name = 'PAY' THEN
    --
    IF p_auto_create_entries_flag IS NULL THEN
      --
      hr_utility.set_location(l_proc,20);
      --
      p_auto_create_entries_flag := 'N';
      --
    END IF;
    --
  ELSE -- category is not payroll
    --
    hr_utility.set_location(l_proc,30);
    --
    p_auto_create_entries_flag := NULL;
    --
  END IF;
  --
  -- Check value is valid, if supplied
  --
  IF p_auto_create_entries_flag IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc,40);
    --
    IF (hr_api.not_exists_in_hr_lookups
              (p_effective_date => p_effective_date
              ,p_lookup_type    => 'YES_NO'
              ,p_lookup_code    => p_auto_create_entries_flag
              )
       ) THEN
      hr_utility.set_location('Entering : '||l_proc,40);
      -- p_auto_create_entries_flag does not exist in lookup, thus error.
      hr_utility.set_message(800,'HR_289472_HIDDEN_VALUE_INVALID');
      hr_utility.raise_error;
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_auto_create_entries_flag;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_item_is_unique >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update that the item is unique within the
--    business_group, legilsation and  category.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entitlement_item_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_item_is_unique
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_category_name            IN per_cagr_entitlement_items.category_name%TYPE
  ,p_cagr_api_id              IN per_cagr_entitlement_items.cagr_api_id%TYPE
  ,p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_element_type_id          IN per_cagr_entitlement_items.element_type_id%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_legislation_code         IN VARCHAR2
  ,p_business_group_id        IN NUMBER
  ) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_item_is unique';
  l_dummy    per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE;
  --
  -- Define a cursor that will check that an item as not already
  -- been defined for the same API and API Param. The cursor checks
  -- at the GLOBAL (NULL BG and LEG), LOCALISATION (NULL BG AND
  -- LEG equal to the Legislation Code) and CUSTOMER (BG and LEG
  -- both populated).
  --
  CURSOR csr_chk_api_item IS
   SELECT pce.cagr_entitlement_item_id
    FROM   per_cagr_entitlement_items pce
    WHERE  pce.category_name      = 'ASG'
	AND    ((p_cagr_entitlement_item_id IS NULL) OR
	        (pce.cagr_entitlement_item_id <> p_cagr_entitlement_item_id))
    AND    ((pce.business_group_id IS NULL  AND
	         pce.legislation_code  IS NULL) OR
	        (pce.business_group_id IS NULL  AND
			 pce.legislation_code  = p_legislation_code) OR
			(pce.business_group_id = p_business_group_id AND
			 pce.legislation_code  = p_legislation_code))
    AND    pce.cagr_api_id        = p_cagr_api_id
    AND    pce.cagr_api_param_id  = p_cagr_api_param_id;
  --
  CURSOR csr_chk_pay_item IS
    SELECT pce.cagr_entitlement_item_id
    FROM   per_cagr_entitlement_items pce
    WHERE  ((p_cagr_entitlement_item_id IS NULL) OR
	        (pce.cagr_entitlement_item_id <> p_cagr_entitlement_item_id))
	AND    ((pce.business_group_id IS NULL  AND
	         pce.legislation_code  IS NULL) OR
	        (pce.business_group_id IS NULL  AND
			 pce.legislation_code  = p_legislation_code) OR
			(pce.business_group_id = p_business_group_id AND
			 pce.legislation_code  = p_legislation_code))
    AND    pce.element_type_id = p_element_type_id
    AND    pce.input_value_id  = p_input_value_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check that an item has not been entered
  -- for the same api, and parameter name
  --
  IF p_cagr_api_param_id IS NOT NULL THEN
    --
	hr_utility.set_location(l_proc,15);
	--
	-- If the item is being inserted or the api or parameter
	-- have been changed (thus updating) then check to see if
	-- if the entitlement item is unique.
	--
	IF ( (p_cagr_entitlement_item_id IS NULL) OR
         ((p_cagr_entitlement_item_id IS NOT NULL) AND
          ((per_cei_shd.g_old_rec.cagr_api_id  <> p_cagr_api_id) OR
		   (per_cei_shd.g_old_rec.cagr_api_param_id  <> p_cagr_api_param_id)
		  )
		 )
	    ) THEN
	  --
      hr_utility.set_location(l_proc,20);
      --
      OPEN csr_chk_api_item;
      FETCH csr_chk_api_item INTO l_dummy;
      --
      IF csr_chk_api_item%FOUND THEN
        --
        hr_utility.set_location(l_proc,30);
        --
        CLOSE csr_chk_api_item;
        --
        hr_utility.set_message(800, 'HR_289251_ITEM_NOT_UNIQUE');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,40);
        --
        CLOSE csr_chk_api_item;
        --
      END IF;
	  --
	END IF;
  --
  -- Check that an item has not been entered with
  -- the same element and input values
  --
  ELSIF p_element_type_id IS NOT NULL THEN
    --
    hr_utility.set_location(l_proc,50);
    --
	IF ( (p_cagr_entitlement_item_id IS NULL) OR
         ((p_cagr_entitlement_item_id IS NOT NULL) AND
          ((per_cei_shd.g_old_rec.element_type_id  <> p_element_type_id) OR
		   (per_cei_shd.g_old_rec.input_value_id  <> p_input_value_id)
		  )
		 )
	    ) THEN
	  --
	  hr_utility.set_location(l_proc,55);
	  --
      OPEN csr_chk_pay_item;
      FETCH csr_chk_pay_item INTO l_dummy;
      --
      IF csr_chk_pay_item%FOUND THEN
        --
        hr_utility.set_location(l_proc,60);
        --
        CLOSE csr_chk_pay_item;
        --
        hr_utility.set_message(800, 'HR_289251_ITEM_NOT_UNIQUE');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,70);
        --
        CLOSE csr_chk_pay_item;
        --
      END IF;
	  --
	END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,100);
  --
END chk_item_is_unique;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_element_type_id>------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update that the element type id is valid,
--    that the input_value_id is also populated and the cagr_api_id is blank.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entitlement_item_id
--    p_cagr_api_id
--    p_element_type_id
--    p_input_value_id
--    p_effective_date
--    p_legislation_code
--    p_business_group_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_element_type_id
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_cagr_api_id              IN per_cagr_entitlement_items.cagr_api_id%TYPE
  ,p_element_type_id          IN per_cagr_entitlement_items.element_type_id%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_effective_date           IN DATE
  ,p_legislation_code         IN pay_element_types_f.legislation_code%TYPE
  ,p_business_group_id        IN pay_element_types_f.business_group_id%TYPE
  ) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_element_type_id';
  l_dummy    pay_element_types_f.element_type_id%TYPE;
  --
  CURSOR csr_chk_element IS
    SELECT pat.element_type_id
    FROM   pay_element_types_f pat
    WHERE  pat.element_type_id = p_element_type_id
	AND    ( ( pat.business_group_id IS NULL AND
	           pat.legislation_code  IS NULL) OR
	         ( pat.business_group_id IS NULL AND
			   pat.legislation_code  = p_legislation_code) OR
			 ( pat.business_group_id = p_business_group_id AND
			   pat.legislation_code  = p_legislation_code) OR
			 ( pat.business_group_id = p_business_group_id AND
			   pat.legislation_code  IS NULL)
		   )
    AND    p_effective_date BETWEEN pat.effective_start_date
                                AND pat.effective_end_date;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for element_type_id has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.element_type_id <> p_element_type_id))) THEN
    --
    hr_utility.set_location(l_proc,30);
    --
    IF p_element_type_id IS NOT NULL THEN
      --
      hr_utility.set_location(l_proc,40);
      --
      -- Check that the ELEMENT_TYPE_ID has not been populated
      -- as well as the CAGR_API_ID.
      --
      IF p_cagr_api_id IS NOT NULL THEN
        --
        hr_utility.set_message(800, 'HR_289231_CAGR_ELEMENT_COMB_IN');
        hr_utility.raise_error;
        --
      END IF;
      --
	  -- Check that a INPUT value is also populated.
	  --
	  IF p_input_value_id IS NULL THEN
        --
        hr_utility.set_message(800, 'HR_289388_EE_OR_IV_NULL');
        hr_utility.raise_error;
        --
      END IF;
      --
      OPEN csr_chk_element;
      FETCH csr_chk_element INTO l_dummy;
      --
      IF csr_chk_element%NOTFOUND THEN
        --
        hr_utility.set_location(l_proc,50);
        --
        CLOSE csr_chk_element;
        --
        hr_utility.set_message(800, 'HR_289252_ELEMENT_TYPE_INV');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,60);
        --
        CLOSE csr_chk_element;
        --
      END IF;
	  --
    ELSIF p_element_type_id IS NULL THEN
	  --
	  hr_utility.set_location(l_proc,70);
      --
	  -- If the input_value is not null then raise an
	  -- error as the element type must be populated as well.
	  --
	  IF p_input_value_id IS NOT NULL THEN
	    --
		hr_utility.set_message(800, 'HR_289388_EE_OR_IV_NULL');
        hr_utility.raise_error;
		--
	  END IF;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_element_type_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_input_value_id>-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update that the input value id is valid,
--    the element_type_id contains a value and the car_api_param_id is blank.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entitlement_item_id
--    p_input_value_id
--    p_element_type_id
--    p_cagr_api_param_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_input_value_id
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_element_type_id          IN per_cagr_entitlement_items.element_type_id%TYPE
  ,p_input_value_id           IN per_cagr_entitlement_items.input_value_id%TYPE
  ,p_cagr_api_param_id        IN per_cagr_entitlement_items.cagr_api_param_id%TYPE
  ,p_effective_date           IN DATE
  ) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_input_value_id';
  l_dummy    pay_input_values_f.input_value_id%TYPE;
  --
  CURSOR csr_chk_input_value IS
    SELECT piv.input_value_id
    FROM   pay_input_values_f piv
    WHERE  piv.input_value_id = p_input_value_id
    AND    piv.element_type_id = p_element_type_id
    AND    p_effective_date BETWEEN piv.effective_start_date
                                AND piv.effective_end_date;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Check mandatory parameter is set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc||'/'||NVL(p_input_value_id,hr_api.g_number),20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for input_value_id has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (per_cei_shd.g_old_rec.input_value_id <>
		 NVL(p_input_value_id,hr_api.g_number)))) THEN
    --
	hr_utility.set_location(l_proc,30);
	--
    IF p_input_value_id IS NOT NULL THEN
	  --
	  hr_utility.set_location(l_proc,40);
      --
      -- Check that the INPUT_VALUE has not been populated
      -- as well as the CAGR_API_PARAM_ID.
      --
      IF p_cagr_api_param_id IS NOT NULL THEN
        --
        hr_utility.set_message(800, 'HR_289233_PARAM_INP_VAL_COMB');
        hr_utility.raise_error;
        --
      END IF;
	  --
	  -- Check that the ELEMENT_TYPE has been
	  -- populated as well as the input value.
	  --
	  IF p_element_type_id IS NULL THEN
	    --
		hr_utility.set_message(800, 'HR_289388_EE_OR_IV_NULL');
        hr_utility.raise_error;
		--
	  END IF;
	  --
      OPEN csr_chk_input_value;
      FETCH csr_chk_input_value INTO l_dummy;
      --
      IF csr_chk_input_value%NOTFOUND THEN
        --
        CLOSE csr_chk_input_value;
        --
        hr_utility.set_message(800, 'HR_289253_INPUT_VALUE_INV');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,50);
        --
        CLOSE csr_chk_input_value;
        --
      END IF;
      --
	ELSIF p_input_value_id IS NULL THEN
	  --
	  hr_utility.set_location(l_proc,60);
      --
	  -- If the element type is not null then raise an
	  -- error as the input value must be populated as well.
	  --
	  IF p_element_type_id IS NOT NULL THEN
	    --
		hr_utility.set_message(800, 'HR_289388_EE_OR_IV_NULL');
        hr_utility.raise_error;
		--
	  END IF;
	  --
    END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,999);
  --
END chk_input_value_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_flex_value_set_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the flex_value_set_id exists in the
--    FND_FLEX_VALUE_SETS_F for records that have a
--    flex_value_set_name that begins with 'CAGR_%' and have a
--    validation_type type of 'F'
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_item_id
--    p_flex_value_set_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_flex_value_set_id
  (p_cagr_entitlement_item_id IN per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE
  ,p_flex_value_set_id        IN per_cagr_entitlement_items.flex_value_set_id%TYPE) IS
  --
  CURSOR c_chk_id IS
  SELECT flex_value_set_id
  FROM   fnd_flex_value_sets F
  WHERE  f.flex_value_set_id = p_flex_value_set_id
  AND    ((f.flex_value_set_name LIKE 'CAGR%') AND
          ((f.flex_value_set_name NOT LIKE 'CAGR_BR_%') AND
										 (f.flex_value_set_name <> 'CAGR_EMPLOYMENT_CATEGORY')))
  AND    f.validation_type = 'F';
  --
  l_proc      VARCHAR2(72) := g_package||'chk_flex_value_set_id';
  l_dummy_id  per_cagr_entitlement_items.flex_value_set_id%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for flex_value_set_id has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (NVL(per_cei_shd.g_old_rec.flex_value_set_id, hr_api.g_number) <>
		 NVL(p_flex_value_set_id, hr_api.g_number)))) THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    IF p_flex_value_set_id IS NOT NULL THEN
      --
      OPEN  c_chk_id;
      FETCH c_chk_id INTO l_dummy_id;
      --
      IF c_chk_id%NOTFOUND THEN
        --
        CLOSE c_chk_id;
        --
        hr_utility.set_message(800,'HR_289255_VALUE_SET_INV');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,30);
        --
        CLOSE c_chk_id;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
END chk_flex_value_set_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_ben_rule_value_set_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that that the beneficial_rule_value_set_id exists in the
--    FND_FLEX_VALUE_SETS_F for records that have a
--    flex_value_set_name that begins with 'CAGR_%' and have a
--    validation_type type of 'F'
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_entitlement_item_id
--    p_beneficial_rule_value_set_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_ben_rule_value_set_id
  (p_cagr_entitlement_item_id IN NUMBER
  ,p_ben_rule_value_set_id    IN NUMBER) IS
  --
  CURSOR c_chk_id IS
  SELECT flex_value_set_id
  FROM   fnd_flex_value_sets F
  WHERE  f.flex_value_set_id = p_ben_rule_value_set_id
  AND    f.flex_value_set_name like 'CAGR_BR_%'
  AND    f.validation_type = 'F';
  --
  l_proc      VARCHAR2(72) := g_package||'chk_beneficial_rule_value_set_id';
  l_dummy_id  NUMBER;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for ben rule value set has changed
  --
  IF ( (p_cagr_entitlement_item_id IS NULL) OR
       ((p_cagr_entitlement_item_id IS NOT NULL) AND
        (NVL(per_cei_shd.g_old_rec.ben_rule_value_set_id, hr_api.g_number) <>
		 NVL(p_ben_rule_value_set_id, hr_api.g_number)))) THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    IF p_ben_rule_value_set_id IS NOT NULL THEN
      --
      OPEN  c_chk_id;
      FETCH c_chk_id INTO l_dummy_id;
      --
      IF c_chk_id%NOTFOUND THEN
        --
        CLOSE c_chk_id;
        --
        hr_utility.set_message(800,'HR_289584_BEN_VALUE_SET_INV');
        hr_utility.raise_error;
        --
      ELSE
        --
        hr_utility.set_location(l_proc,30);
        --
        CLOSE c_chk_id;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
END chk_ben_rule_value_set_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in     date
  ,p_rec                          in out nocopy per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  -- Validate Bus Grp if one has been entered.
  --
--  IF p_rec.business_group_id IS NOT NULL THEN
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);
	--
--  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  per_cei_bus.chk_item_name
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_item_name                => p_rec.item_name
    ,p_category_name            => p_rec.category_name
	,p_legislation_code         => p_rec.legislation_code
    ,p_business_group_id        => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc,30);
  --
  per_cei_bus.chk_legislation_code
    (p_legislation_code => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc,40);
  --
  per_cei_bus.chk_beneficial_rule
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_beneficial_rule          => p_rec.beneficial_rule
	,p_ben_rule_value_set_id    => p_rec.ben_rule_value_set_id
    ,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc,50);
  --
  per_cei_bus.chk_cagr_api_id
    (p_cagr_api_id              => p_rec.cagr_api_id
    ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
    ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_element_type_id          => p_rec.element_type_id);
  --
  hr_utility.set_location(l_proc,60);
  --
  per_cei_bus.chk_cagr_api_param_id
    (p_cagr_api_param_id        => p_rec.cagr_api_param_id
    ,p_input_value_id           => p_rec.element_type_id
    ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_cagr_api_id              => p_rec.cagr_api_id
    );
  --
  hr_utility.set_location(l_proc,70);
  --
  per_cei_bus.chk_multiple_entries_flag
    (p_mult_entries_allowed_flag => p_rec.mult_entries_allowed_flag
	,p_cagr_entitlement_item_id  => p_rec.cagr_entitlement_item_id
    ,p_category_name             => p_rec.category_name
    ,p_element_type_id  	     => p_rec.element_type_id
    ,p_business_group_id	     => p_rec.business_group_id
    ,p_legislation_code          => p_rec.legislation_code
    ,p_effective_date		     => p_effective_date
    );
  --
  hr_utility.set_location(l_proc,80);
  --
  per_cei_bus.chk_category_name
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_category_name            => p_rec.category_name
  ,p_effective_date           => p_effective_date);
  --                                                              -- CEI Enh
  hr_utility.set_location(l_proc,85);                             -- CEI Enh
  --                                                              -- CEI Enh
  per_cei_bus.chk_auto_create_entries_flag                        -- CEI Enh
    (p_auto_create_entries_flag => p_rec.auto_create_entries_flag -- CEI Enh
    ,p_category_name            => p_rec.category_name            -- CEI Enh
    ,p_effective_date           => p_effective_date               -- CEI Enh
    );                                                            -- CEI Enh
  --
  hr_utility.set_location(l_proc,90);
  --
  per_cei_bus.chk_uom
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_uom                      => p_rec.uom
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc,100);
  --
  per_cei_bus.chk_item_is_unique
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_category_name            => p_rec.category_name
  ,p_cagr_api_id              => p_rec.cagr_api_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_legislation_code         => p_rec.legislation_code
  ,p_business_group_id        => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc,110);
  --
  per_cei_bus.chk_element_type_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_id              => p_rec.cagr_api_id
  ,p_effective_date           => p_effective_date
  ,p_legislation_code         => p_rec.legislation_code
  ,p_business_group_id        => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc,120);
  --
  per_cei_bus.chk_input_value_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_effective_date           => p_effective_date
  );
  --
  hr_utility.set_location(l_proc,130);
  --
  per_Cei_bus.chk_flex_value_set_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_flex_value_set_id        => p_rec.flex_value_set_id);
  --
  hr_utility.set_location(l_proc,140);
  --
  per_cei_bus.chk_ben_rule_value_set_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_ben_rule_value_set_id    => p_rec.ben_rule_value_set_id);
  --
  hr_utility.set_location(l_proc,150);
  --
  per_cei_bus.chk_column_type
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_column_type              => p_rec.column_type
  ,p_uom                      => p_rec.uom
  ,p_input_value_id           => p_rec.input_value_id
  ,p_category_name            => p_rec.category_name
  ,p_effective_date           => p_effective_date
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc,160);
  --
  per_cei_bus.chk_column_size
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_column_size              => p_rec.column_size
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
  --
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in     date
  ,p_rec                          in out nocopy per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
 -- Validate Bus Grp if one has been entered.
  --
  IF p_rec.business_group_id IS NOT NULL THEN
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);
	--
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  chk_non_updateable_args
    (p_effective_date => p_effective_date
    ,p_rec            => p_rec);
  --
  hr_utility.set_location(l_proc,30);
  --
  per_cei_bus.chk_item_name
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_item_name                => p_rec.item_name
    ,p_category_name            => p_rec.category_name
	,p_legislation_code         => p_rec.legislation_code
    ,p_business_group_id        => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc,40);
  --
  per_cei_bus.chk_legislation_code
    (p_legislation_code => p_rec.legislation_code);
  --
  hr_utility.set_location(l_proc,50);
  --
  per_cei_bus.chk_beneficial_rule
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_beneficial_rule          => p_rec.beneficial_rule
	,p_ben_rule_value_set_id    => p_rec.ben_rule_value_set_id
    ,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc,60);
  --
  per_cei_bus.chk_cagr_api_id
    (p_cagr_api_id              => p_rec.cagr_api_id
    ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
    ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_element_type_id          => p_rec.element_type_id);
  --
  hr_utility.set_location(l_proc,70);
  --
  per_cei_bus.chk_cagr_api_param_id
    (p_cagr_api_param_id        => p_rec.cagr_api_param_id
    ,p_input_value_id           => p_rec.element_type_id
    ,p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
    ,p_cagr_api_id              => p_rec.cagr_api_id
    );
  --
  hr_utility.set_location(l_proc,80);
  --
  per_cei_bus.chk_category_name
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_category_name            => p_rec.category_name
  ,p_effective_date           => p_effective_date);
  --                                                              -- CEI Enh
  hr_utility.set_location(l_proc,85);                             -- CEI Enh
  --                                                              -- CEI Enh
  per_cei_bus.chk_auto_create_entries_flag                        -- CEI Enh
    (p_auto_create_entries_flag => p_rec.auto_create_entries_flag -- CEI Enh
    ,p_category_name            => p_rec.category_name            -- CEI Enh
    ,p_effective_date           => p_effective_date               -- CEI Enh
    );                                                            -- CEI Enh
  --
  hr_utility.set_location(l_proc,90);
  --
  per_cei_bus.chk_uom
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_uom                      => p_rec.uom
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_effective_date           => p_effective_date);
  --
  hr_utility.set_location(l_proc,100);
  --
  per_cei_bus.chk_item_is_unique
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_category_name            => p_rec.category_name
  ,p_cagr_api_id              => p_rec.cagr_api_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_legislation_code         => p_rec.legislation_code
  ,p_business_group_id        => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc,110);
  --
  per_cei_bus.chk_element_type_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_id              => p_rec.cagr_api_id
  ,p_effective_date           => p_effective_date
  ,p_legislation_code         => p_rec.legislation_code
  ,p_business_group_id        => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc,120);
  --
  per_cei_bus.chk_input_value_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_element_type_id          => p_rec.element_type_id
  ,p_input_value_id           => p_rec.input_value_id
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id
  ,p_effective_date           => p_effective_date
  );
  --
  hr_utility.set_location(l_proc,130);
  --
  per_cei_bus.chk_flex_value_set_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_flex_value_set_id        => p_rec.flex_value_set_id);
  --
  hr_utility.set_location(l_proc,140);
  --
  per_cei_bus.chk_ben_rule_value_set_id
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_ben_rule_value_set_id    => p_rec.ben_rule_value_set_id);
  --
  hr_utility.set_location(l_proc,150);
  --
   per_cei_bus.chk_column_type
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_column_type              => p_rec.column_type
  ,p_uom                      => p_rec.uom
  ,p_input_value_id           => p_rec.input_value_id
  ,p_category_name            => p_rec.category_name
  ,p_effective_date           => p_effective_date
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc,160);
  --
  per_cei_bus.chk_column_size
  (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id
  ,p_column_size              => p_rec.column_size
  ,p_cagr_api_param_id        => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc,160);
  --
  per_cei_bus.chk_multiple_entries_flag
    (p_mult_entries_allowed_flag => p_rec.mult_entries_allowed_flag
	,p_cagr_entitlement_item_id  => p_rec.cagr_entitlement_item_id
    ,p_category_name             => p_rec.category_name
    ,p_element_type_id  	     => p_rec.element_type_id
    ,p_business_group_id	     => p_rec.business_group_id
    ,p_legislation_code          => p_rec.legislation_code
    ,p_effective_date		     => p_effective_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_cei_bus.chk_item_use
    (p_cagr_entitlement_item_id => p_rec.cagr_entitlement_item_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_cei_bus;

/
