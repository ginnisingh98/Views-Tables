--------------------------------------------------------
--  DDL for Package Body PER_CPA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPA_BUS" as
/* $Header: pecparhi.pkb 115.4 2002/12/04 15:03:48 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_cpa_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cagr_api_param_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cagr_api_param_id                    in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_cagr_api_parameters and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_cagr_api_parameters cpa
     where cpa.cagr_api_param_id = p_cagr_api_param_id;
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
    ,p_argument           => 'cagr_api_param_id'
    ,p_argument_value     => p_cagr_api_param_id
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
  (p_cagr_api_param_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- per_cagr_api_parameters and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_cagr_api_parameters cpa
     where cpa.cagr_api_param_id = p_cagr_api_param_id;
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
    ,p_argument           => 'cagr_api_param_id'
    ,p_argument_value     => p_cagr_api_param_id
    );
  --
  if ( nvl(per_cpa_bus.g_cagr_api_param_id, hr_api.g_number)
       = p_cagr_api_param_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_cpa_bus.g_legislation_code;
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
    per_cpa_bus.g_cagr_api_param_id := p_cagr_api_param_id;
    per_cpa_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_cagr_api_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert cagr_api_id is not null and that
--    it exists in per_cagr_apis.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_id
--    p_cagr_api_param_id
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
  (p_cagr_api_id       IN per_cagr_api_parameters.cagr_api_id%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE) is
  --
  l_proc  VARCHAR2(72) := g_package||'chk_cagr_api_id';
  l_dummy NUMBER       := NULL;
  --
  CURSOR csr_cagr_api_id IS
    SELECT null
    FROM   per_cagr_apis per
    WHERE  per.cagr_api_id = p_cagr_api_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory cagr_api_id is set
  --
  if p_cagr_api_id is null then
    --
    hr_utility.set_message(800, 'HR_289135_CAGR_API_ID_NULL');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) on insert (cagr_api_id is a non-updateable param)
  --
  if (p_cagr_api_param_id is null) then
     --
     hr_utility.set_location(l_proc, 30);
     --
     -- Check that the person_id is in the per_people_f view on the effective_date.
     --
     open  csr_cagr_api_id;
     fetch csr_cagr_api_id into l_dummy;
     --
     if csr_cagr_api_id%notfound then
       --
       close csr_cagr_api_id;
       --
       hr_utility.set_message(800, 'HR_289136_CAGR_API_ID_INV');
       hr_utility.raise_error;
       --
     end if;
     --
     close csr_cagr_api_id;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_cagr_api_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_display_name >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert display_name is not null and that
--    it is unique within the API.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_id
--    p_display_name
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
PROCEDURE chk_display_name
  (p_cagr_api_id       IN per_cagr_api_parameters.cagr_api_id%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_display_name      IN per_cagr_api_parameters.display_name%TYPE) IS
  --
  CURSOR csr_chk_display_name IS
    SELECT display_name
    FROM   per_cagr_api_parameters cpa
    WHERE  display_name = p_display_name
    AND    cagr_api_id  = p_cagr_api_id
    AND    ( (cagr_api_param_id <> p_cagr_api_param_id) OR
	         (p_cagr_api_param_id IS NULL));
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_display_name';
  l_dummy    per_cagr_api_parameters.display_name%TYPE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check Display_Name is not null
  --
  IF p_display_name IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289137_DISPLAY_NAME_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (per_cpa_shd.g_old_rec.display_name <> p_display_name))) THEN
    --
    --
    -- Check Display Name is unique within the API.
    --
    OPEN  csr_chk_display_name;
    FETCH csr_chk_display_name INTO l_dummy;
    --
    IF csr_chk_display_name%FOUND THEN
      --
      CLOSE csr_chk_display_name;
      --
      hr_utility.set_message(800, 'HR_289138_DISPLAY_NAME_INVALID');
      hr_utility.raise_error;
      --
    ELSE
      --
      CLOSE csr_chk_display_name;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 30);
  --
END chk_display_name;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_parameter_name >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert parameter_name is not null and that
--    it is unique within the API.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_id
--    p_parameter_name
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
PROCEDURE chk_parameter_name
  (p_parameter_name    IN per_cagr_api_parameters.parameter_name%TYPE
  ,p_cagr_api_id       IN per_cagr_api_parameters.cagr_api_id%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_id%TYPE) IS
  --
    --
  CURSOR csr_chk_parameter_name IS
    SELECT parameter_name
    FROM   per_cagr_api_parameters cpa
    WHERE  parameter_name = p_parameter_name
    AND    cagr_api_id  = p_cagr_api_id
    AND    ((cagr_api_param_id <> p_cagr_api_param_id) OR
	        (p_cagr_api_param_id IS NULL));
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_parameter_name';
  l_dummy    per_cagr_api_parameters.parameter_name%TYPE;
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check parameter_name is not null
  --
  IF p_parameter_name IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289200_PARAMETER_NAME_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (per_cpa_shd.g_old_rec.parameter_name <> p_parameter_name))) THEN
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check parameter_name is unique within the API.
    --
    OPEN  csr_chk_parameter_name;
    FETCH csr_chk_parameter_name INTO l_dummy;
    --
    IF csr_chk_parameter_name%FOUND THEN
      --
      CLOSE csr_chk_parameter_name;
      --
      hr_utility.set_message(800, 'HR_289201_PARAMETER_NAME_INVAL');
      hr_utility.raise_error;
      --
    ELSE
      --
      CLOSE csr_chk_parameter_name;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
END chk_parameter_name;
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_hidden >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert the HIDDEN parameter exists in the YES_NO lookup
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_param_id
--    p_hidden
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
PROCEDURE chk_hidden
  (p_hidden            IN per_cagr_api_parameters.hidden%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_effective_date    IN DATE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_hidden';
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'HIDDEN'
    ,p_argument_value => p_hidden);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (per_cpa_shd.g_old_rec.hidden <> p_hidden))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_hidden) THEN
      --
      hr_utility.set_message(800, 'HR_289472_HIDDEN_VALUE_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 999);
  --
END chk_hidden;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_column_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert type is not null and that
--    it exists in hr_lookups.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_param_id
--    p_type
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
  (p_column_type       IN per_cagr_api_parameters.column_type%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_effective_date    IN DATE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_column_type';
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  IF p_column_type IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289204_COLUMN_TYPE_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (per_cpa_shd.g_old_rec.column_type <> p_column_type))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the type exists in HR_LOOKUPS
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
  hr_utility.set_location('Leaving '||l_proc, 40);
  --
END chk_column_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_column_size >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert column_size is not null.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_column_size
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
  (p_column_size IN per_cagr_api_parameters.column_size%TYPE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_column_size';
  --
BEGIN
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  -- Check column_size is not null
  --
  IF p_column_size IS NULL THEN
    --
    hr_utility.set_message(800, 'HR_289202_COLUMN_SIZE_NULL');
    hr_utility.raise_error;
    --
  END IF;
  --
  hr_utility.set_location('Leaving '||l_proc, 30);
  --
END chk_column_size;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_uom_parameter >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that uom_parameter is unique for the API.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_uom_parameter
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
PROCEDURE chk_uom_parameter
  (p_uom_parameter     IN per_cagr_api_parameters.uom_parameter%TYPE
  ,p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_cagr_api_id       IN per_cagr_api_parameters.cagr_api_id%TYPE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_uom_parameter';
  l_dummy    per_cagr_api_parameters.uom_parameter%TYPE;
  --
  CURSOR csr_get_uom_parameter IS
    SELECT cap.uom_parameter
    FROM   per_cagr_api_parameters cap
    WHERE  cap.cagr_api_id     = p_cagr_api_id
    AND    cap.uom_parameter = p_uom_parameter
	AND    ((cap.cagr_api_param_id <> p_cagr_api_param_id) OR
	        (p_cagr_api_param_id IS NULL));
  --
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (per_cpa_shd.g_old_rec.uom_parameter <> p_uom_parameter))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    OPEN csr_get_uom_parameter;
    FETCH csr_get_uom_parameter INTO l_dummy;
    --
    IF csr_get_uom_parameter%FOUND THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      CLOSE csr_get_uom_parameter;
      --
      hr_utility.set_message(800, 'HR_289206_UOM_PARAMETER_INVAL');
      hr_utility.raise_error;
      --
    ELSE
      --
      hr_utility.set_location(l_proc, 40);
      --
      CLOSE csr_get_uom_parameter;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  :'||l_proc, 50);
  --
END chk_uom_parameter;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_uom_lookup >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that uom_lookup is a valid lookup.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_uom_lookup
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
PROCEDURE chk_uom_lookup
  (p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_uom_lookup        IN per_cagr_api_parameters.uom_lookup%TYPE
  ,p_default_uom       IN per_cagr_api_parameters.default_uom%TYPE
  ,p_effective_date    IN DATE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_uom_lookup';
  l_dummy    per_cagr_api_parameters.uom_lookup%TYPE;
  --
  CURSOR csr_get_lookup_type IS
    SELECT hl.lookup_type
    FROM   hr_standard_lookups hl
    WHERE  lookup_type = p_uom_lookup
    AND    p_effective_date BETWEEN NVL(hl.start_date_active,hr_general.start_of_time)
                            AND     NVL(hl.end_date_active,hr_general.end_of_time);
  --
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  IF p_uom_lookup IS NOT NULL THEN
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (NVL(per_cpa_shd.g_old_rec.uom_lookup,hr_api.g_varchar2) <>
		 NVL(p_uom_lookup,hr_api.g_varchar2)))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the type exists in HR_LOOKUPS
    --
    OPEN csr_get_lookup_type;
    FETCH csr_get_lookup_type INTO l_dummy;
    --
    IF csr_get_lookup_type%NOTFOUND THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      CLOSE csr_get_lookup_type;
      --
      hr_utility.set_message(800, 'HR_289207_UOM_LOOKUP_INVALID');
      hr_utility.raise_error;
      --
    ELSE
      --
      hr_utility.set_location(l_proc, 40);
      --
      CLOSE csr_get_lookup_type;
      --
    END IF;
    --
	--
	-- Check that the default_uom has not also been populated
	--
	IF p_default_uom IS NOT NULL AND
	   p_uom_lookup  IS NOT NULL THEN
	  --
	  hr_utility.set_message(800, 'HR_289512_DFLT_UOM_UOM_LOOKUP');
      hr_utility.raise_error;
	  --
	END IF;
	--
  END IF;
  --
  END IF;
  --
  hr_utility.set_location('Leaving  :'||l_proc,50);
  --
END chk_uom_lookup;
--
--  ---------------------------------------------------------------------------
--  |-----------------------------< chk_default_uom >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that default_uom exists in the UNITS lookup and that the
--    uom_lookup has not also been populated.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_param_id
--    p_uom_lookup
--    p_default_uom
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
PROCEDURE chk_default_uom
  (p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE
  ,p_default_uom       IN per_cagr_api_parameters.default_uom%TYPE
  ,p_uom_lookup        IN per_cagr_api_parameters.uom_lookup%TYPE
  ,p_effective_date    IN DATE) IS
  --
  l_proc     VARCHAR2(72) := g_package || 'chk_uom_lookup';
  l_dummy    per_cagr_api_parameters.uom_lookup%TYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering :'||l_proc,10);
  --
  IF p_default_uom IS NOT NULL THEN
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for consultation type has changed
  --
  IF ( (p_cagr_api_param_id IS NULL) OR
       ((p_cagr_api_param_id IS NOT NULL) AND
        (NVL(per_cpa_shd.g_old_rec.default_uom,hr_api.g_varchar2) <>
		 NVL(p_default_uom,hr_api.g_varchar2)))) THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the default_uom exists in HR_LOOKUPS
	-- for the UNITS lookup type
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'UNITS'
      ,p_lookup_code           => p_default_uom) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      hr_utility.set_message(800, 'HR_289511_DEFAULT_UOM_INVALID');
      hr_utility.raise_error;
      --
    END IF;
    --
	-- Check that the uom_lookup has not also been populated
	--
	IF p_default_uom IS NOT NULL AND
	   p_uom_lookup  IS NOT NULL THEN
	  --
	  hr_utility.set_message(800, 'HR_289512_DFLT_UOM_UOM_LOOKUP');
      hr_utility.raise_error;
	  --
	END IF;
	--
  END IF;
  --
  END IF;
  --
  hr_utility.set_location('Leaving  :'||l_proc,50);
  --
END chk_default_uom;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_parameter_use >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on delete that the parameter is not being referenced
--    by a entitlement item.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_cagr_api_param_id
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
PROCEDURE chk_parameter_use
  (p_cagr_api_param_id IN per_cagr_api_parameters.cagr_api_param_id%TYPE) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_parameter_use';
  l_dummy    per_cagr_entitlement_items.item_name%TYPE;
  --
  CURSOR csr_get_entitlement_item IS
    SELECT cei.item_name
    FROM   per_cagr_entitlement_items cei
    WHERE  cei.cagr_api_param_id = p_cagr_api_param_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  OPEN csr_get_entitlement_item;
  FETCH csr_get_entitlement_item INTO l_dummy;
  --
  IF csr_get_entitlement_item%FOUND THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    CLOSE csr_get_entitlement_item;
    --
    hr_utility.set_message(800, 'HR_289208_PARAMETER_IN_USE');
    hr_utility.raise_error;
    --
  ELSE
    --
    hr_utility.set_location(l_proc,30);
    --
    CLOSE csr_get_entitlement_item;
    --
  END IF;
  --
  hr_utility.set_location('Leaving  : '||l_proc,100);
  --
END chk_parameter_use;
  --
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
  ,p_rec in per_cpa_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_cpa_shd.api_updating
      (p_cagr_api_param_id                    => p_rec.cagr_api_param_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.cagr_api_param_id, hr_api.g_number) <>
     nvl(per_cpa_shd.g_old_rec.cagr_api_param_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_api_params_id';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.cagr_api_id, hr_api.g_number) <>
     nvl(per_cpa_shd.g_old_rec.cagr_api_id,hr_api.g_number) THEN
    --
    l_argument := 'cagr_api_id';
    RAISE l_error;
    --
  END IF;
  --
  IF nvl(p_rec.parameter_name, hr_api.g_varchar2) <>
     nvl(per_cpa_shd.g_old_rec.parameter_name,hr_api.g_varchar2) THEN
    --
    l_argument := 'parameter_name';
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
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate cagr_api_id
  --
  per_cpa_bus.chk_cagr_api_id
    (p_cagr_api_id       => p_rec.cagr_api_id
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate Display Name
  --
  per_cpa_bus.chk_display_name
    (p_cagr_api_id       => p_rec.cagr_api_id
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_display_name      => p_rec.display_name);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate Parameter Name
  --
  per_cpa_bus.chk_parameter_name
    (p_parameter_name    => p_rec.parameter_name
    ,p_cagr_api_id       => p_rec.cagr_api_id
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate Column Type
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Validate Column Type
  --
  per_cpa_bus.chk_column_type
    (p_column_type       => p_rec.column_type
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Validate Column Size
  --
  per_cpa_bus.chk_column_size
    (p_column_size => p_rec.column_size);
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Validate uom parameter
  --
  per_cpa_bus.chk_uom_parameter
    (p_uom_parameter     => p_rec.uom_parameter
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_cagr_api_id       => p_rec.cagr_api_id);
  --
  hr_utility.set_location(l_proc,70);
  --
  -- Validate uom lookup
  --
  per_cpa_bus.chk_uom_lookup
    (p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_uom_lookup        => p_rec.uom_lookup
	,p_default_uom       => p_rec.default_uom
    ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(l_proc,80);
  --
  per_cpa_bus.chk_hidden
  (p_hidden            => p_rec.hidden
  ,p_cagr_api_param_id => p_rec.cagr_api_param_id
  ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(l_proc,90);
  --
  per_cpa_bus.chk_default_uom
  (p_cagr_api_param_id => p_rec.cagr_api_param_id
  ,p_default_uom       => p_rec.default_uom
  ,p_uom_lookup        => p_rec.uom_lookup
  ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
  --
  -- Validate Display Name
  --
  per_cpa_bus.chk_display_name
    (p_cagr_api_id       => p_rec.cagr_api_id
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_display_name      => p_rec.display_name);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate Parameter Name
  --
  per_cpa_bus.chk_parameter_name
    (p_parameter_name    => p_rec.parameter_name
    ,p_cagr_api_id       => p_rec.cagr_api_id
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate Column Type
  --
  hr_utility.set_location(l_proc, 40);
  --
  per_cpa_bus.chk_column_type
    (p_column_type       => p_rec.column_type
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_effective_date    => p_effective_date);
  --
  -- Validate Column Size
  --
  hr_utility.set_location(l_proc, 50);
  --
  per_cpa_bus.chk_column_size
    (p_column_size => p_rec.column_size);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate uom parameter
  --
  per_cpa_bus.chk_uom_parameter
    (p_uom_parameter     => p_rec.uom_parameter
    ,p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_cagr_api_id       => p_rec.cagr_api_id);
  --
  hr_utility.set_location(l_proc,70);
  --
  -- Validate uom lookup
  --
  per_cpa_bus.chk_uom_lookup
    (p_cagr_api_param_id => p_rec.cagr_api_param_id
    ,p_uom_lookup        => p_rec.uom_lookup
	,p_default_uom       => p_rec.default_uom
    ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(l_proc,80);
  --
  per_cpa_bus.chk_hidden
  (p_hidden            => p_rec.hidden
  ,p_cagr_api_param_id => p_rec.cagr_api_param_id
  ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(l_proc,90);
  --
  per_cpa_bus.chk_default_uom
  (p_cagr_api_param_id => p_rec.cagr_api_param_id
  ,p_default_uom       => p_rec.default_uom
  ,p_uom_lookup        => p_rec.uom_lookup
  ,p_effective_date    => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_cpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check the parameter is not being referenced
  --
  per_cpa_bus.chk_parameter_use
    (p_cagr_api_param_id => p_rec.cagr_api_param_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_cpa_bus;

/
