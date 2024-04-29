--------------------------------------------------------
--  DDL for Package Body PAY_PYR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_BUS" AS
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pay_pyr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            VARCHAR2(150)  DEFAULT NULL;
g_rate_id                     NUMBER         DEFAULT NULL;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_basis >---------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_rate_basis
  (p_rate_basis            IN pay_rates.rate_basis%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE) IS
 --
  l_api_updating BOOLEAN;
  l_proc         VARCHAR2(72) := g_package||'chk_rate_basis';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The rate_basis is changing or new
  -- b) The value for rate_uom is changing and not null
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.rate_basis, hr_api.g_varchar2) <>
       NVL(p_rate_basis, hr_api.g_varchar2) AND (p_rate_basis IS NOT NULL)) OR
      (NOT l_api_updating and p_rate_basis IS NOT NULL)) THEN
	--
hr_utility.set_location('g_old_rec.rate_basis'||pay_pyr_shd.g_old_rec.rate_basis,888);
hr_utility.set_location('p_rate_basis'||p_rate_basis,888);
    -- Check that the rate basis exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'RATE_BASIS'
      ,p_lookup_code           => p_rate_basis) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289581_RATE_BASIS_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_RATES.RATE_BASIS') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_rate_basis;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_rate_uom >----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_rate_uom
  (p_rate_uom              IN pay_rates.rate_uom%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE) IS
 --
  l_api_updating BOOLEAN;
  l_proc         VARCHAR2(72) := g_package||'chk_rate_uom';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The rate_uom is changing or new
  -- b) The value for rate_uom is changing and not null
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.rate_uom, hr_api.g_varchar2) <>
       NVL(p_rate_uom, hr_api.g_varchar2) AND (p_rate_uom IS NOT NULL)) OR
      (NOT l_api_updating and p_rate_uom IS NOT NULL)) THEN
	--
    -- Check that the rate uom exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'UNITS'
      ,p_lookup_code           => p_rate_uom) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289582_RATE_UOM_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_RATES.RATE_UOM') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_rate_uom;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_rate_type >----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_rate_type
  (p_rate_type             IN pay_rates.rate_type%TYPE
  ,p_effective_date        IN DATE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE) IS
  --
  l_api_updating BOOLEAN;
  l_proc         VARCHAR2(72) := g_package||'chk_rate_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Only proceed with validation if :
  -- a) The rate_type is changing or new
  -- b) The value for rate_type is changing and not null
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.rate_type, hr_api.g_varchar2) <>
       NVL(p_rate_type, hr_api.g_varchar2) AND (p_rate_type IS NOT NULL)) OR
      (NOT l_api_updating and p_rate_type IS NOT NULL)) THEN
	--
    -- Check that the rate type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'RATE_TYPE'
      ,p_lookup_code           => p_rate_type) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289589_INV_ASG_RATE_TYPE');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_RATES.RATE_TYPE') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_rate_type;
--
--  ---------------------------------------------------------------------------
--  |--------------------------------< chk_name >-----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_name
  (p_name                  IN pay_rates.name%TYPE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_business_group_id     IN pay_rates.business_group_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE
  ,p_rate_type             IN pay_rates.rate_type%TYPE
  ,p_asg_rate_type         IN pay_rates.asg_rate_type%TYPE) IS
  --
  CURSOR chk_duplicate_name IS
    SELECT pr.name
	FROM   pay_rates pr
	WHERE  pr.name = p_name
          AND  pr.rate_type = p_rate_type
	  AND  business_group_id = p_business_group_id
	  AND  ((p_rate_id IS NULL) OR
	        (p_rate_id IS NOT NULL AND
			 pr.rate_id <> p_rate_id))
          AND (p_rate_type <> 'A'
               OR
               (p_rate_type = 'A'  AND
                 (   (p_asg_rate_type is not null
                      AND pr.asg_rate_type is not null
                      AND pr.asg_rate_type=p_asg_rate_type)
                  OR (p_asg_rate_type is null
                      AND pr.asg_rate_type is null))
               ));
  --
  l_proc         VARCHAR2(72):= g_package || 'chk_name';
  l_name         pay_rates.name%TYPE;
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'name'
    ,p_argument_value => p_name);
  --
  -- Only proceed with validation if :
  -- a) The name is changing or new
  -- b) The value for name is changing and not null
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc||'/'||p_business_group_id, 20);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.name, hr_api.g_varchar2) <>
       NVL(p_name, hr_api.g_varchar2) AND (p_Name IS NOT NULL)) OR
      (NOT l_api_updating and p_name IS NOT NULL)) THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
	-- Check to see if the name already
	-- exists for the business group
	--
	OPEN chk_duplicate_name;
	FETCH chk_duplicate_name INTO l_name;
	--
	-- If the name already exists for the
	-- business group then raise an error
	--
	IF chk_duplicate_name%FOUND THEN
	  --
	  CLOSE chk_duplicate_name;
	  --
	  hr_utility.set_message(800, 'PAY_6703_DEF_GRD_RATE_EXISTS');
      hr_utility.raise_error;
	  --
    ELSE
	  --
	  CLOSE chk_duplicate_name;
	  --
    END IF;
	--
	hr_utility.set_location(l_proc, 40);
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
	    (p_associated_column1 => 'PAY_RATES.NAME') THEN
		--
		hr_utility.set_location(' Leaving : '||l_proc,998);
		--
		RAISE;
		--
	  END IF;
	  --
	  hr_utility.set_location(' Leaving : '||l_proc,999);
	  --
END chk_name;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_for_child_records >-----------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_for_child_records
  (p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_rate_type             IN pay_rates.rate_type%TYPE) IS
  --
  CURSOR chk_for_records IS
    SELECT 'X'
	FROM   pay_grade_rules_f pgr
	WHERE  pgr.rate_id = p_rate_id;
  --
  l_proc         VARCHAR2(72):= g_package || 'chk_for_child_records';
  l_dummy        CHAR;
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'rate_id'
    ,p_argument_value => p_rate_id);
  --
  OPEN chk_for_records;
  FETCH chk_for_records INTO l_dummy;
  --
  hr_utility.set_location(l_proc||'/'||p_rate_type,20);
  --
  -- If child records exists then the delete
  -- cannot be performed until these child records
  -- have been deleted. So raise an error.
  --
  IF chk_for_records%FOUND THEN
    --
	hr_utility.set_location(l_proc,30);
	--
    CLOSE chk_for_records;
    --
	IF p_rate_type = 'G' THEN
	  --
      hr_utility.set_message(800, 'HR_289594_GRADE_RULES_EXIST');
      hr_utility.raise_error;
      --
	ELSIF p_rate_type = 'SP' THEN
	  --
      hr_utility.set_message(800, 'HR_289595_POINT_VALUES_EXIST');
      hr_utility.raise_error;
      --
    ELSIF p_rate_type = 'A' THEN
	  --
      hr_utility.set_message(800, 'HR_289596_ASG_RATE_VAL_EXISTS');
      hr_utility.raise_error;
      --
    END IF;
	--
  ELSE
	--
    CLOSE chk_for_records;
    --
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
END chk_for_child_records;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_field_combinations >-----------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_field_combinations
  (p_rate_type             IN pay_rates.rate_type%TYPE
  ,p_rate_uom              IN pay_rates.rate_uom%TYPE
  ,p_rate_basis            IN pay_rates.rate_basis%TYPE
  ,p_parent_spine_id       IN pay_rates.parent_spine_id%TYPE
  ,p_asg_rate_type         IN pay_rates.asg_rate_type%TYPE) IS
  --
  l_proc         VARCHAR2(72):= g_package || 'chk_correct_rate';
  l_name         pay_rates.name%TYPE;
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  -- If the rate type is an Assignment then
  -- check the correct fields have been set
  -- and that they have the correct value
  --
  IF p_rate_type = 'A' THEN
    --
	hr_utility.set_location(l_proc, 20);
    --
	-- If the rate_uom has not been set
	-- to M (Money) then raise an error
	--
	IF p_rate_uom <> 'M' THEN
	  --
	  hr_utility.set_message(800, 'HR_289590_INV_ASG_RATE_UOM');
      hr_utility.raise_error;
	 --
	-- If the parent spine id has been populated
	-- then raise an error.
	--
	ELSIF p_parent_spine_id IS NOT NULL THEN
	  --
	  hr_utility.set_message(800, 'HR_289591_SPINE_ID_POPULATED');
      hr_utility.raise_error;
	--
	-- If the pay basis field has not been populated
	-- then raise an error as for Assignment Rates
	-- the pay basis field is mandatory.
	--
	ELSIF p_rate_basis IS NULL THEN
	  --
	  hr_utility.set_message(800, 'HR_289592_RATE_BASIS_IS_NULL');
      hr_utility.raise_error;
	  --
	END IF;
  --
  -- If the Rate is a Grade Rate then check that the
  -- Rate_Basis has not been populated, and that the
  -- Parent Spine ID has not been populated.
  --
  ELSIF p_rate_type = 'G' THEN
    --
	IF p_rate_basis IS NOT NULL THEN
      --
	  hr_utility.set_message(800, 'HR_289593_RATE_BASIS_NOT_NULL');
          hr_utility.raise_error;
	  --
        ELSIF p_parent_spine_id IS NOT NULL THEN
	  --
          hr_utility.set_message(800, 'HR_289743_PARENT_SPINE_NOT_NUL');
          hr_utility.raise_error;
	  --
        ELSIF p_asg_rate_type IS NOT NULL THEN
          hr_utility.set_message(800, 'HR_449033_ASGRAT_TYPE_NOT_NULL');
          hr_utility.raise_error;
          --
	END IF;
  --
  -- If the Rate is a Scale Rate then check that the rate_basis
  -- has not been populated and the parent spine id (Pay Scale)
  -- has been populated.
  --
  ELSIF p_rate_type = 'SP' THEN
    --
        IF p_rate_basis IS NOT NULL THEN
         --
          hr_utility.set_message(800, 'HR_289593_RATE_BASIS_NOT_NULL');
          hr_utility.raise_error;
          --
	ELSIF p_parent_spine_id IS NULL THEN
	  --
          hr_utility.set_message(800, 'HR_289744_PARENT_SPINE_NULL');
          hr_utility.raise_error;
	  --
        ELSIF p_asg_rate_type IS NOT NULL THEN
          hr_utility.set_message(800, 'HR_449033_ASGRAT_TYPE_NOT_NULL');
          hr_utility.raise_error;
          --
	END IF;
	--
  END IF;
  --
  hr_utility.set_location('Leaving : '||l_proc,999);
  --
END chk_field_combinations;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_parent_spine_id >------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_parent_spine_id
  (p_parent_spine_id       IN pay_rates.parent_spine_id%TYPE
  ,p_rate_id               IN pay_rates.rate_id%TYPE
  ,p_object_version_number IN pay_rates.object_version_number%TYPE ) IS
  --
  -- Declare Cursors
  --
  CURSOR csr_chk_parent_spine_fk IS
    SELECT 'Y'
      FROM per_parent_spines  pps
     WHERE pps.parent_spine_id = p_parent_spine_id;
  --
  -- Declare local variables
  --
  l_proc         VARCHAR2(72) := g_package || 'chk_parent_spine_id';
  l_dummy        VARCHAR2(1);
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The parent_spine_id is changing or new
  -- b) The value for parent_spine_id is changing and not null
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.rate_id, hr_api.g_number) <>
       NVL(p_rate_id, hr_api.g_number) AND (p_rate_id IS NOT NULL)) OR
      (NOT l_api_updating and p_rate_id IS NOT NULL)) THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Check if  parent_spine_id is not null
    --
    OPEN  csr_chk_parent_spine_fk;
    FETCH csr_chk_parent_spine_fk INTO l_dummy;
    --
    IF csr_chk_parent_spine_fk%NOTFOUND THEN
      --
 	  CLOSE csr_chk_parent_spine_fk;
	  --
	  hr_utility.set_message(800, 'HR_289286_PARENT_SPINE_INVALID');
      hr_utility.raise_error;
      --
    ELSE
      --
	  hr_utility.set_location(l_proc, 40);
	  --
	  CLOSE csr_chk_parent_spine_fk;
	  --
    END IF;
	--
  END IF;
  --
  hr_utility.set_location(' Leaving: '||l_proc,997);
  --
  EXCEPTION
    --
	WHEN app_exception.application_exception THEN
	  --
	  IF hr_multi_message.exception_add
        (p_associated_column1 => 'PAY_RATES.PARENT_SPINE_ID') THEN
	    --
		hr_utility.set_location(' Leaving: '|| l_proc,998);
		RAISE;
		--
      END IF;
	  --
	  hr_utility.set_location(' Leaving: '||l_proc,999);
	  --
END chk_parent_spine_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_asg_rate_type >------------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_asg_rate_type
  (p_rate_id                              IN VARCHAR2
  ,p_object_version_number                IN NUMBER
  ,p_effective_date                       IN DATE
  ,p_asg_rate_type                        IN VARCHAR2
  ,p_rate_type                            IN VARCHAR2
  ) IS
  --
  l_proc              VARCHAR2(72)  :=  g_package||'chk_asg_rate_type';
  l_dummy             VARCHAR2(1);
  l_api_updating BOOLEAN;
  --
  cursor csr_matching_children is
  SELECT 'y' from dual where exists
  (select 'y'
   from pay_grade_rules_f pgr1
       ,pay_grade_rules_f pgr2
       ,pay_rates pyr1
       ,pay_rates pyr2
   where pgr1.rate_id=pyr1.rate_id
   and   pgr2.rate_id=pyr2.rate_id
   and   pgr1.grade_or_spinal_point_id=pgr2.grade_or_spinal_point_id
   and   pgr1.effective_start_date
         between pgr2.effective_start_date and pgr2.effective_end_date
   and   pgr1.rate_type='A'
   and   pgr2.rate_type='A'
   and   pyr2.asg_rate_type=p_asg_rate_type
   and   pyr1.rate_id=p_rate_id
   and   pyr1.rate_id <> pyr2.rate_id);
  --
  cursor csr_price_differentials is
  select 'Y' from dual where exists
  (SELECT 'Y'
   FROM fnd_lookups
   WHERE lookup_type='PRICE DIFFERENTIALS'
   AND lookup_code=p_asg_rate_type
   AND enabled_flag='Y'
   AND p_effective_date between nvl(start_date_active,hr_api.g_sot)
                        and nvl(end_date_active,hr_api.g_eot));
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Updating and the asg_rate_type is changing
  -- b) Inserting
  --
  l_api_updating := pay_pyr_shd.api_updating
    (p_rate_id                => p_rate_id
    ,p_object_version_number  => p_object_version_number);
  --
  IF ((l_api_updating AND
       NVL(pay_pyr_shd.g_old_rec.asg_rate_type, hr_api.g_varchar2) <>
       NVL(p_asg_rate_type, hr_api.g_varchar2) AND (p_asg_rate_type IS NOT NULL)) OR
          (NOT l_api_updating and p_rate_id IS NULL AND p_asg_rate_type IS NOT NULL)) THEN
    --
    -- check the asg_rate_type is valid in the lookup
    --
    open csr_price_differentials;
    fetch csr_price_differentials into l_dummy;
    IF csr_price_differentials%notfound then
      close csr_price_differentials;
      hr_utility.set_message(800, 'HR_449034_ASGRAT_TYPE_INVALID');
      hr_utility.raise_error;
    ELSE
      close csr_price_differentials;
    END IF;
    --
    -- check the change in asg_rate_type does not result in an assignment
    -- having more than one row of the same asg_rate_type at any given date
    --
    open csr_matching_children;
    fetch csr_matching_children into l_dummy;
    if csr_matching_children%found then
      close csr_matching_children;
      fnd_message.set_name('PER','HR_449035_ASGRAT_INV_CHILD');
      hr_multi_message.add
        (p_associated_column1
         => 'ASG_RATE_TYPE');
    else
      close csr_matching_children;
    end if;
    --
  END IF;
  hr_utility.set_location('Leaving:'|| l_proc, 10);
END chk_asg_rate_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id
  (p_rate_id                              IN NUMBER
  ,p_associated_column1                   IN VARCHAR2 DEFAULT NULL
  ) IS
  --
  -- Declare cursor
  --
  CURSOR csr_sec_grp IS
    SELECT pbg.security_group_id
      FROM per_business_groups pbg
         , pay_rates pyr
     WHERE pyr.rate_id = p_rate_id
       AND pbg.business_group_id = pyr.business_group_id;
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
    ,p_argument           => 'rate_id'
    ,p_argument_value     => p_rate_id
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
     hr_multi_message.add
       (p_associated_column1
        => NVL(p_associated_column1,'RATE_ID')
       );
     --
  ELSE
    CLOSE csr_sec_grp;
    --
    -- Set the security_group_id IN CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  END IF;
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
  (p_rate_id                              IN     NUMBER
  )
  RETURN Varchar2 IS
  --
  -- Declare CURSOR
  --
 CURSOR csr_leg_code IS
    SELECT pbg.legislation_code
      FROM per_business_groups pbg
         , pay_rates pyr
     WHERE pyr.rate_id = p_rate_id
       AND pbg.business_group_id = pyr.business_group_id;
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
    ,p_argument           => 'rate_id'
    ,p_argument_value     => p_rate_id
    );
  --
  IF ( NVL(pay_pyr_bus.g_rate_id, hr_api.g_number)
       = p_rate_id) THEN
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just RETURN the value IN the global
    -- variable.
    --
    l_legislation_code := pay_pyr_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  ELSE
    --
    -- The ID IS different to the last call to this function
    -- or this IS the first call to this function.
    --
    OPEN csr_leg_code;
    FETCH csr_leg_code INTO l_legislation_code;
    --
    IF csr_leg_code%notfound THEN
      --
      -- The primary key IS invalid therefore we must error
      --
      CLOSE csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    END IF;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    CLOSE csr_leg_code;
    pay_pyr_bus.g_rate_id           := p_rate_id;
    pay_pyr_bus.g_legislation_code  := l_legislation_code;
  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  RETURN l_legislation_code;
END return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step FROM insert_validate AND update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   IF the Descriptive Flexfield structure column AND data values are
--   all valid this procedure will END normally AND processing will
--   continue.
--
-- Post Failure:
--   IF the Descriptive Flexfield structure column value or any of
--   the data values are invalid THEN an application error IS raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc   VARCHAR2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.rate_id IS not NULL)  AND (
    NVL(pay_pyr_shd.g_old_rec.attribute_category, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute_category, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute1, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute1, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute2, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute2, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute3, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute3, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute4, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute4, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute5, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute5, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute6, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute6, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute7, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute7, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute8, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute8, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute9, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute9, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute10, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute10, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute11, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute11, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute12, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute12, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute13, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute13, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute14, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute14, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute15, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute15, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute16, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute16, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute17, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute17, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute18, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute18, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute19, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute19, hr_api.g_VARCHAR2)  or
    NVL(pay_pyr_shd.g_old_rec.attribute20, hr_api.g_VARCHAR2) <>
    NVL(p_rec.attribute20, hr_api.g_VARCHAR2) ))
    or (p_rec.rate_id IS NULL)  THEN
    --
    -- Only execute the validation IF absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_RATES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      );
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure IS used to ensure that non updateable attributes have
--   not been updated. IF an attribute has been updated an error IS generated.
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
--   Processing continues IF all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error IS raised IF any of the non updatable attributes
--   have been altered.
--
-- {END OfComments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_non_updateable_args
  (p_effective_date               IN DATE
  ,p_rec IN pay_pyr_shd.g_rec_type
  ) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument VARCHAR2(30);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with the validation IF a row exists for the current
  -- record IN the HR Schema.
  --
  IF NOT pay_pyr_shd.api_updating
      (p_rate_id                           => p_rec.rate_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pyr_shd.g_old_rec.business_group_id,hr_api.g_number) THEN
    --
    l_argument := 'business_group_id';
    RAISE l_error;
    --
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc,999);
  --
  EXCEPTION
    WHEN l_error THEN
	  --
      hr_api.argument_changed_error
        (p_api_name => l_proc
        ,p_argument => l_argument);
	  --
    WHEN OTHERS THEN
	  --
      RAISE;
	  --
END chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'insert_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pyr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- IF Multiple Message detection IS enabled AND at least
  -- one error has been found THEN abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Validate Dependent Attributes
  --
  pay_pyr_bus.chk_parent_spine_id
    (p_parent_spine_id       => p_rec.parent_spine_id
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,30);
  --
  pay_pyr_bus.chk_rate_type
    (p_rate_type             => p_rec.rate_type
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,40);
  --
  pay_pyr_bus.chk_rate_uom
    (p_rate_uom              => p_rec.rate_uom
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,50);
  --
  pay_pyr_bus.chk_rate_basis
    (p_rate_basis            => p_rec.rate_basis
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,60);
  --
  pay_pyr_bus.chk_name
    (p_name                  => p_rec.name
	,p_rate_id               => p_rec.rate_id
	,p_business_group_id     => p_rec.business_group_id
	,p_object_version_number => p_rec.object_version_number
        ,p_rate_type            => p_rec.rate_type
        ,p_asg_rate_type         => p_rec.asg_rate_type);
  --
  hr_utility.set_location(l_proc,70);
  --
  pay_pyr_bus.chk_field_combinations
    (p_rate_type               => p_rec.rate_type
    ,p_rate_uom                => p_rec.rate_uom
    ,p_rate_basis              => p_rec.rate_basis
    ,p_parent_spine_id         => p_rec.parent_spine_id
    ,p_asg_rate_type           => p_rec.asg_rate_type);
  --
  hr_utility.set_location(l_proc,80);
  --
  pay_pyr_bus.chk_asg_rate_type
  (p_rate_id                   => p_rec.rate_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_asg_rate_type             => p_rec.asg_rate_type
  ,p_rate_type                 => p_rec.rate_type
  );
  --
  hr_utility.set_location(l_proc,90);
  --
  pay_pyr_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_validate
  (p_effective_date               IN DATE
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'update_validate';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pyr_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- IF Multiple Message detection IS enabled AND at least
  -- one error has been found THEN abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec );
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Validate Dependent Attributes
  --
  pay_pyr_bus.chk_parent_spine_id
    (p_parent_spine_id       => p_rec.parent_spine_id
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,40);
  --
  pay_pyr_bus.chk_rate_type
    (p_rate_type             => p_rec.rate_type
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,50);
  --
  pay_pyr_bus.chk_rate_uom
    (p_rate_uom              => p_rec.rate_uom
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,60);
  --
  pay_pyr_bus.chk_rate_basis
    (p_rate_basis            => p_rec.rate_basis
    ,p_effective_date        => p_effective_date
    ,p_rate_id               => p_rec.rate_id
    ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,70);
  --
  pay_pyr_bus.chk_name
    (p_name                  => p_rec.name
	,p_rate_id               => p_rec.rate_id
	,p_business_group_id     => p_rec.business_group_id
	,p_object_version_number => p_rec.object_version_number
        ,p_rate_type            => p_rec.rate_type
        ,p_asg_rate_type         => p_rec.asg_rate_type);
  --
  hr_utility.set_location(l_proc,80);
  --
  pay_pyr_bus.chk_field_combinations
    (p_rate_type               => p_rec.rate_type
    ,p_rate_uom                => p_rec.rate_uom
    ,p_rate_basis              => p_rec.rate_basis
    ,p_parent_spine_id         => p_rec.parent_spine_id
    ,p_asg_rate_type           => p_rec.asg_rate_type);
  --
  hr_utility.set_location(l_proc,90);
  --
  pay_pyr_bus.chk_asg_rate_type
  (p_rate_id                   => p_rec.rate_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_asg_rate_type             => p_rec.asg_rate_type
  ,p_rate_type                 => p_rec.rate_type
  );
  --
  hr_utility.set_location(l_proc,100);
  --
  pay_pyr_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_validate
  (p_rec                          IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'delete_validate';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pyr_bus.chk_for_child_records
    (p_rate_id               => p_rec.rate_id
	,p_rate_type             => p_rec.rate_type);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END delete_validate;
--
END pay_pyr_bus;

/
